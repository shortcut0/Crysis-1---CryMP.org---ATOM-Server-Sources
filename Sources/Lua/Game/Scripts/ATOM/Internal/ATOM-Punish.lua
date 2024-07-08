ATOMPunish = {
	cfg = {
	
	};
	-----------
	ATOMBan = {
		cfg = {
			ManageBans = ADMINISTRATOR;
			DefaultBanTime = 1; -- default/unspecified ban time
			MaxBanTime = 365; -- days
			BanClasses = {
				[4] = false; -- can't ban users with this access or higher
			};
		};
		-----------
		bans = ATOMPunish~=nil and ATOMPunish.ATOMBan.bans or {};
		-----------
		Init = function(self)
			eBM_UpdatedList = 0;
			eBM_Added		= 1;
			eBM_Removed		= 2;
			eBM_Loaded		= 3;
			eMM_Flushed		= 4;
			
			self:LoadFile();
		end;
		-----------
		LoadFile = function(self, t)
		--	Debug("Lodding?")
			LoadFile("ATOMBan", "Bans.lua");
			local banCunt = arrSize(self.bans);
			if (banCunt > 0) then
				self:Msg(eBM_Loaded, banCunt);
			end;
		end;
		----------
		LoadBan = function(self, Name, IPs, HostNames, Profiles, Extras, Date, Time, Reason, Country, Admin)
			if (Name and (IPs or HostNames or Profiles or Extras)) then
				--Debug("Loaded ban:", Name);
				if (not self:GetBan(IPs, HostNames, Profiles, Extras)) then
					self.bans[arrSize(self.bans)+1] = {
						Name 		= Name,
						IP			= IPs,
						HostName	= HostNames,
						Profile		= Profiles,
						Extra		= Extras,
						Date		= Date,
						Expire		= Time,
						Reason		= Reason,
						Country		= Country,
						Admin		= Admin,
						Time 		= Time
					};
				else
					for i, ip in pairs(IPs) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(HostNames) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(Profiles) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(Extras) do
						self:UpdateBanEntiries(ip);
					end;
				end;
			end;
		end;
		------------
		SaveFile = function(self, t)
			SaveFile("ATOMBan", "Bans.lua", "ATOMPunish.ATOMBan:LoadBan", self:ConvertTable(self.bans));
		end;
		-----------
		ConvertTable = function(self, t)
			local n = {};
			for i, v in pairs(t) do
				n[arrSize(n)+1] = {
					v.Name,
					v.IP,
					v.HostName,
					v.Profile,
					v.Extra,
					v.Date,
					v.Expire,
					v.Reason,
					v.Country,
					v.Admin,
					v.Time
				};
			--	Debug("Save ban:",v.Name,"R",v.Reason)
			end;
			return n;
		end;
		-----------
		BanPlayer = function(self, player, target, sTime, reason)

			local sTime = checkString(sTime, "")
			local bInfinite = (string.matchex(string.lower(sTime), "infinite", "-1"))
			local iTime = "Infinite"
			local iTimeLog = iTime
			if (not bInfinite) then
				iTime = ATOMPunish:ParseTime(time or self.cfg.DefaultBanTime, true)
				if ((iTime / ONE_DAY) >= self.cfg.MaxBanTime) then
					iTime = (ONE_DAY * self.cfg.MaxBanTime)
				end

				iTimeLog = SimpleCalcTime(iTime)
			end

			local sReason = reason
			if (string.empty(sReason)) then
				sReason = "Server Decision"
			end

			if (self:WriteBan(target:GetName(), target:GetIP(), target:GetHostName(), target:GetProfile(), target:GetIdentifier(), iTime, sReason, target:GetCountry(), player:GetName())) then
				player.wasKicked = true;
				ATOMDLL:Ban(target:GetChannel(), sReason)
				SendMsg(ERROR, ALL, "[ SERVER : DEFENSE ] %s WAS BANNED FROM THE SERVER (%s)", target:GetName(), (sReason or "Fucking Nab"))
				self:Msg(eBM_Added, target:GetName(), iTimeLog, sReason)
				return true
			else
				return false, "player already banned"
			end
		end;
		-----------
		OnMidTick = function(self)
			self:CheckBans();
		end;
		-----------
		CheckBans = function(self)
			local expired = false
			for i, ban in pairs(self.bans) do
				if (ban.Expire ~= "Infinite" and self:BanExpired(ban.Expire)) then
					expired = true
					if (self:RemoveBanByName(ban.Name)) then
						self:Msg(eBM_Removed, ban.Name, "Ban Expired")
						self:SaveFile()
					end
				end
			end
			return expired
		end;
		-----------
		BanExpired = function(self, expireDate)
			return math_leq(expireDate, atommath:Get('timestamp'));
		end;
		-----------
		UnbanPlayer = function(self, playerName, reason)
			local reason = reason;
			if (emptyString(reason)) then
				reason = "Server Decision";
			end;
			
			if (self:RemoveBanByName(playerName)) then
				return true, self:Msg(eBM_Removed, playerName, reason);
			end;
			return false, "ban not found";
		end;
		-----------
		RemoveBanByName = function(self, banName)
			for i, ban in pairs(self.bans) do
				if (ban.Name:lower() == banName:lower()) then
					return true, self:RemoveBan(ban.Name, ban.IP[1], ban.HostName[1], ban.Profile[1], ban.Extra[1])
				end;
			end;
		end;
		-----------
		GetBanByName = function(self, banName)
			for i, ban in pairs(self.bans) do
				if (ban.Name:lower() == banName:lower()) then
					return ban;
				end;
			end;
		end;
		-----------
		RemoveBan = function(self, Name, IP, HostName, Profile, extras)
			local ban, banId = self:GetBan(IP, HostName, Profile, extra);
			if (ban and banId) then
				self.bans[banId] = nil;
				self:RestructureBans();
				return true;
			else
				return false, "Ban not found";
			end;
		end;
		-----------
		RestructureBans = function(self)
			local newBans = {};
			for i, v in pairs(self.bans) do
				newBans[ arrSize(newBans)+1 ] = v;
			end;
			self.bans = newBans;
		end;
		-----------
		ListBans = function(self, player, index, option)

			local banCount = arrSize(self.bans);
			if (banCount < 1) then
				return false, "no bans found";
			end;
			if (index and index == 'flush' and player:HasAccess(self.cfg.ManageBans)) then
				self.bans = {};
				self:SaveFile();
				self:Msg(eBM_Flushed, banCount, 'Admin Decision');
				SendMsg(CHAT_BANSYS, player, "(BanSystem: Reset [ " .. banCount .. " ] Bans)");
				return true;
			end;
			if (index and index == 'update' and player:HasAccess(self.cfg.ManageBans)) then
				for i, v in pairs(GetPlayers())do
					local ban, banId = self:GetBan(v:GetIP(), v:GetHostName(), v:GetProfile(), v:GetIdentifier())
					if (ban) then
						ATOMPunish.ATOMPunish:Msg(ePM_Kicked, v:GetName(), ban.Reason);
						ATOMDLL:Ban(v:GetChannel(), ban.Reason);
					end;
				end;
				SendMsg(CHAT_BANSYS, player, "(BanSystem: Reloading Bans)");
				return true;
			end;
			
			
			
			local index_num = tonumber(index);
			if (index_num and self.bans[index_num]) then
				local ban = self.bans[index_num];
				
				local option = tostr(option):lower();
				if (option == "del") then
					if (player:HasAccess(self.cfg.ManageBans)) then
						local removed = self:RemoveBan(ban.IP[1], ban.HostName[1], ban.Profile[1], ban.Extra[1]);
						if (removed) then
							SendMsg(CHAT_BANSYS, player, "(" .. ban.Name .. ": Ban Entry #" .. index_num .. " Removed)");
							self:SaveFile();
							return removed, self:Msg(eBM_Removed, ban.Name, 'Admin Decision');
						end;
					else
						return false, "insufficient access";
					end;
				end;
				
				--[[local date		= ban.Date;
				local banDate 	= toDate(date);
				
				local expire = ban.Expire;
				local elapsed = "NULL";
				if (expire ~= "Infinite") then
				
					local today 	= atommath:Get('timestamp');
					--local expire 	= ban.Expire;
	
					elapsed 	= math_sub(math_sub(ban.Expire, date), math_sub(expire, today));
				
					expire		= calcTime(tonumber(math_sub(ban.Expire, today)), true, 1, 1, 1, 1, "$8");
					local elapsedpercentage = math_div(elapsed, math_sub(ban.Expire, today))
					Debug(elapsedpercentage)
					elapsed 	= calcTime(tonumber(elapsed), true,  1, 1, 1, 1, "$8") .. " $9($4" .. elapsedpercentage .. "%$9)";
				else
					elapsed = calcTime(0, true,  1, 1, 1, 1, "$8") .. " $9($400%$9)";
				end;--]]
				
				local date		= ban.Date;
				local banDate 	= toDate(date);
				
				local expire 	= ban.Expire;
				local today 	= atommath:Get('timestamp');
				
				--local remaining = math_sub(expire, today);
				--local elapsed 	= math_sub(math_sub(expire, date), remaining);
					
				--	remaining 		= calcTime(tonumber(math_sub(expire, today)), true, unpack(GetTime_SMHD));
				--	elapsed 		= calcTime(tonumber(elapsed), true, unpack(GetTime_SMHD));
					
				--	Debug(remaining)
				--	Debug(elapsed)
				
				local elapsed = "NULL";
				if (expire ~= "Infinite") then
					elapsed 	= math_sub(math_sub(ban.Expire, date), math_sub(expire, today));
					expire		= calcTime(tonumber(math_sub(ban.Expire, today)), true, 1, 1, 1, 1, "$8");
					--Debug("1", math_mul(elapsed, 100))
					--Debug("2", ban.Time)
					local elapsedpercentage = tonumber(math_div(math_mul(elapsed, 100), ban.Time))
					if (elapsedpercentage < 10) then
						elapsedpercentage = "0" .. elapsedpercentage
					end;
					elapsedpercentage = cutNum(elapsedpercentage, 2)
					elapsed 	= calcTime(tonumber(elapsed), true,  1, 1, 1, 1, "$8") .. " $9($4" .. elapsedpercentage .. "%$9)";
				else
					elapsed = calcTime(0, true,  1, 1, 1, 1, "$8") .. " $9($400%$9)";
				end;
				
				SendMsg(CHAT_BANSYS, player, "Open console to view the Ban Entry #" .. index .. " (" .. ban.Name .. ")");
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9[           Name | $1' .. string.lenprint(ban.Name, 24) 					.. ' $9]            Entry | #$8' .. string.lenprint(index_num, 44) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9[             IP | $9' .. string.lenprint((ban.IP[1] or "N/A"), 24)			.. ' $9]           Domain | $9' .. string.lenprint((ban.HostName[1] or "N/A"), 45) ..  ' $9]');
				SendMsg(CONSOLE, player, '$9[        Profile | $9' .. string.lenprint((ban.Profile[1] or "N/A"), 24)	.. ' $9]          Elapsed | $4' .. string.lenprint(elapsed, 45) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9[         Reason | $4' .. string.lenprint(ban.Reason, 24) 					.. ' $9]           Expiry | $4' .. string.lenprint(expire, 45) 			..  ' $9]');
				SendMsg(CONSOLE, player, '$9[      Timestamp | $9' .. string.lenprint(banDate, 24) 						.. ' $9]        Banned by | $5' .. string.lenprint(ban.Admin, 45) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9================================================================================================================');
			else
				
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9      Name                   Reason                Admin                 Date                    Expiry');
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				--[[================================================================================================================
				[$5003$9] $9[7Ox.EU]::[#0540]   $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 11/08/20 | 17:02:46   $5|$9 $4Infinite
				[$5004$9] $9Devchonka           $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 11/10/20 | 09:38:01   $5|$9 $4Infinite
				[$5005$9] $9FAG                 $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 12/06/20 | 14:34:13   $5|$9 $4Infinite
				[$5006$9] $9[7Ox.BG]::[#0053]   $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 01/22/21 | 17:04:40   $5|$9 $4Infinite
				[$5007$9] $9demon54rus          $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 03/08/21 | 12:35:21   $5|$9 $4Infinite
				[$5008$9] $9Fisting is 300 bucks$5|$9 No Spread             $5|$9 $4nCX                 $5|$9 03/16/21 | 16:45:44   $5|$9 $4Infinite
				[$5009$9] $9[7Ox.HR]::[#0066]   $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 03/18/21 | 13:55:06   $5|$9 $4Infinite
				[$5010$9] $9demon_54rus         $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 03/24/21 | 15:17:37   $5|$9 $4Infinite
				[$5011$9] $9JL [VlP]            $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 04/18/21 | 20:57:06   $5|$9 $4Infinite
				[$5012$9] $9ABOBA               $5|$9 No Spread             $5|$9 $4nCX                 $5|$9 05/08/21 | 02:19:01   $5|$9 $4Infinite
				[$5013$9] $9desertjrp(2)        $5|$9 Freeze                $5|$9 $4nCX                 $5|$9 05/12/21 | 02:47:34   $5|$9 $4Infinite
				================================================================================================================--]]
				
				for i, ban in pairs(self.bans) do
				
					
					local date		= ban.Date;
					local banDate 	= toDate(date);
					--[[local today 	= atommath:Get('timestamp');
					local expire 	= ban.Expire;
	
					local remaining = math_sub(expire, today);
					local elapsed 	= math_sub(math_sub(expire, date), remaining);
					
					remaining 		= calcTime(tonumber(math_sub(expire, today)), true, unpack(GetTime_CSMHD));
					elapsed 		= calcTime(tonumber(elapsed), true, unpack(GetTime_CSMHD));--]]
					
					local expire = ban.Expire;
					if (expire ~= "Infinite") then
						expire = calcTime(tonumber(math_sub(ban.Expire, atommath:Get('timestamp'))), true, 1, 1, 1, 1, "$4")
					end;
				
					local msg = formatString('$9[ $1%s $9] $9%s $9| $4%s $9| $9%s $9| $9%s $9| $4%s',
						i 			.. repStr(1, i),
						ban.Name:sub(1, 20) 	.. repStr(20, ban.Name:sub(1, 20)),
						ban.Reason:sub(1, 19) 	.. repStr(19, ban.Reason:sub(1, 19)),
						ban.Admin:sub(1, 19) 	.. repStr(19, ban.Admin:sub(1, 19)),
						banDate		.. repStr(21, banDate),
						expire
					);
				SendMsg(CONSOLE, player,msg);
				end;
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CHAT_BANSYS, player, "Open console to view the Ban List");
			end;
		end;
		-----------
		WriteBan = function(self, Name, IP, HostName, Profile, extra, Time, Reason, Country, Admin)
			if (not self:GetBan(IP, HostName, Profile, extra)) then

				local iTimestamp = atommath:Get('timestamp')
				local bInfinite = (string.matchex(string.lower(Time), "infinite", "-1"))
				local idExpire = "Infinite"
				if (not bInfinite) then
					idExpire = (iTimestamp + Time)
				end


				--while tonumber(Time) > 500000 do
				--	Expire = math_add(Expire, 500000);
				--	Debug("Million",Time)
				--	Time = Time - 500000;
				--end;
				--if (Time > 0) then
				--	Debug("Under million: ",Time)
				--	Expire = math_add(Expire, Time);
				--end;
				self.bans [ arrSize(self.bans)+1 ] = {
					Name 		= Name,
					IP			= { IP },
					HostName	= { HostName },
					Profile		= { Profile },
					Extra		= { extra },
					Date		= iTimestamp,
					Expire		= idExpire,
					Reason		= Reason,
					Country		= Country,
					Admin		= Admin,
					Time		= Time
				};
				self:SaveFile();
				return true;
			else
				self:UpdateBanEntiries(IP, HostName, Profile, extra);
				return false;
			end;
		end;
		-----------
		GetPlayerBan = function(self, player)
			return self:GetBan(player:GetIP(), player:GetHostName(), player:GetProfile(), player:GetIdentifier());
		end;
		-----------
		GetBan = function(self, IP, HostName, Profile, extra)
			for i, v in pairs(self.bans) do
				for j, k in pairs(v.IP) do
					if (type(IP)=="table") then
						for x, y in pairs(IP) do
							if (tostring(k) == y) then
								return v, i;
							end;
						end;
					else
						if (tostring(k) == tostring(IP)) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.HostName) do
					if (type(HostName)=="table") then
						for x, y in pairs(HostName) do
							if (tostring(k) == y) then
								return v, i;
							end;
						end;
					else
						if (tostring(k) == tostring(HostName)) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.Profile) do
					if (type(Profile)=="table") then
						for x, y in pairs(Profile) do
							if (tostring(k) == tostring(y)) then
								return v, i;
							end;
						end;
					else
						if (tostring(k) == tostring(Profile)) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.Extra) do
					if (type(extra)=="table") then
						for x, y in pairs(extra) do
							if (k == y) then
								return v, i;
							end;
						end;
					else
						if (k == extra) then
							return v, i;
						end;
					end;
				end;
			end;
		end;
		-----------
		UpdateBanEntiries = function(self, IP, HostName, Profile, extra)
			local ban, banId = self:GetBan(IP, HostName, Profile, extra);
			if (banId) then
			
				local add = true;
				if (not emptyString(IP)) then
					for i, ip in pairs(ban.IP) do
						if (ip == IP) then
							add = false;
						end;
					end;
					if (add) then
						add = false;
						self:Msg(eBM_UpdatedList, ban.Name, "IP: ", IP);
						self.bans[banId].IP[arrSize(ban.IP)+1] = IP;
					end;
				end;
				add = true;
				if (not emptyString(HostName)) then
					for i, ip in pairs(ban.HostName) do
						if (ip == HostName) then
							add = false;
						end;
					end;
					if (add) then
						add = false;
						self:Msg(eBM_UpdatedList, ban.Name, "IP: ", IP);
						self.bans[banId].IP[arrSize(ban.IP)+1] = IP;
					end;
				end;
				add = true;
				if (not emptyString(Profile)) then
					for i, ip in pairs(ban.Profile) do
						if (ip == Profile) then
							add = false;
						end;
					end;
					if (add) then
						add = false;
						self:Msg(eBM_UpdatedList, ban.Name, "IP: ", IP);
						self.bans[banId].IP[arrSize(ban.IP)+1] = IP;
					end;
				end;
				add = true;
				if (not emptyString(extra)) then
					for i, ip in pairs(ban.Extra) do
						if (ip == extra) then
							add = false;
						end;
					end;
					if (add) then
						add = false;
						self:Msg(eBM_UpdatedList, ban.Name, "IP: ", IP);
						self.bans[banId].IP[arrSize(ban.IP)+1] = IP;
					end;
				end;
				
			end;
			if (add) then
			--	Debug("Nothing Updated")
			else
				self:SaveFile();
			end;
		end;
		-----------
		Msg = function(self, case, p1, p2, p3)
			if (case == eBM_UpdatedList) then
				ATOMLog:LogBanUpdate("Updated Ban %s$9 ($4%s%s$9)", p1, p2, p3);
			elseif (case == eBM_Added) then
				ATOMLog:LogBan("Added Ban %s$9 ($4%s, %s$9)", p1, p2, p3);
			elseif (case == eBM_Removed) then
				ATOMLog:LogBan("Removed Ban %s$9 ($4%s$9)", p1, p2);
			elseif (case == eBM_Loaded) then
				ATOMLog:LogBan("Successfully loaded $4%d$9 Bans", p1);
			elseif (case == eBM_Flushed) then
				ATOMLog:LogBan("Flushed $4%d$9 Bans ($4%s$9)", p1, p2);
			end;
		end;
		-----------
		-----------
	};
	-----------
	ATOMMute = {
		cfg = {
			ManageMutes = ADMINISTRATOR;
			DefaultMuteTime = 1; -- default/unspecified ban time
			MaxMuteTime = 365; -- days
			MuteClasses = {
				[4] = false; -- can't ban users with this access or higher
			};
		};
		-----------
		mutes = ATOMPunish~=nil and ATOMPunish.ATOMMute.mutes or {};
		-----------
		Init = function(self)
			eMM_UpdatedList = 0;
			eMM_Added		= 1;
			eMM_Removed		= 2;
			eMM_Loaded		= 3;
			eMM_Flushed		= 4;
			
			self:LoadFile();
		end;
		-----------
		LoadFile = function(self, t)
		--	Debug("Lodding?")
			LoadFile("ATOMMute", "Mutes.lua");
			local banCunt = arrSize(self.mutes);
			if (banCunt > 0) then
				self:Msg(eBM_Loaded, banCunt);
			end;
		end;
		----------
		LoadMute = function(self, Name, IPs, HostNames, Profiles, Extras, Date, Time, Reason, Country, Admin)
			if (Name and (IPs or HostNames or Profiles or Extras)) then
				--Debug("Loaded ban:", Name);
				if (not self:GetBan(IPs, HostNames, Profiles, Extras)) then
					self.mutes[arrSize(self.mutes)+1] = {
						Name 		= Name,
						IP			= IPs,
						HostName	= HostNames,
						Profile		= Profiles,
						Extra		= Extras,
						Date		= Date,
						Expire		= Time,
						Reason		= Reason,
						Country		= Country,
						Admin		= Admin,
						Time		= Time
					};
				else
					for i, ip in pairs(IPs) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(HostNames) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(Profiles) do
						self:UpdateBanEntiries(ip);
					end;
					for i, ip in pairs(Extras) do
						self:UpdateBanEntiries(ip);
					end;
				end;
			end;
		end;
		------------
		SaveFile = function(self, t)
			SaveFile("ATOMute", "Mutes.lua", "ATOMPunish.ATOMMute:LoadMute", self:ConvertTable(self.mutes));
		end;
		-----------
		ConvertTable = function(self, t)
			local n = {};
			for i, v in pairs(t) do
				n[arrSize(n)+1] = {
					v.Name,
					v.IP,
					v.HostName,
					v.Profile,
					v.Extra,
					v.Date,
					v.Expire,
					v.Reason,
					v.Country,
					v.Admin,
					v.Time
				};
			--	Debug("Save ban:",v.Name,"R",v.Reason)
			end;
			return n;
		end;
		-----------
		MutePlayer = function(self, player, target, time, reason)
			local time	 = ATOMPunish:ParseTime(time or self.cfg.DefaultMuteTime, true);
			if (tonumber(time) > ONE_DAY and time / ONE_DAY > self.cfg.MaxMuteTime) then
				time = tostr(self.cfg.MaxMuteTime * ONE_DAY);
			end;
			--Debug("1>",time)
			local reason = reason;
			if (emptyString(reason)) then
				reason = "Server Decision";
			end;
			--Debug("2>",time)
			if (self:WriteMute(target:GetName(), target:GetIP(), target:GetHostName(), target:GetProfile(), target:GetIdentifier(), time, reason, target:GetCountry(), player:GetName())) then
				--ATOMDLL:Ban(target:GetChannel(), reason);
				return true, self:Msg(eMM_Added, target:GetName(), calcTime(time, true, unpack(GetTime_SMHD)), reason);
			else
				return false, "player already muted";
			end;
		end;
		-----------
		UnmutePlayer = function(self, player, playerName, reason)
			local reason = reason;
			if (emptyString(reason)) then
				reason = "Server Decision";
			end;
			
			local p = GetPlayer(playerName);
			if (p and self:RemoveMuteByName(p:GetName())) then
				return true, self:Msg(eMM_Removed, player:GetName(), reason);
			end;
			
			if (self:RemoveMuteByName(playerName)) then
				return true, self:Msg(eMM_Removed, player:GetName(), reason);
			end;
			return false, "mute not found";
		end;
		-----------
		RemoveMuteByName = function(self, banName)
			for i, ban in pairs(self.mutes) do
				if (ban.Name:lower() == banName:lower()) then
					return true, self:RemoveMute(ban.Name, ban.IP[1], ban.HostName[1], ban.Profile[1], ban.Extra[1])
				end;
			end;
		end;
		-----------
		RemoveMute = function(self, Name, IP, HostName, Profile, extras)
			local ban, banId = self:GetBan(IP, HostName, Profile, extra);
			if (ban and banId) then
				self.mutes[banId] = nil;
				self:RestructureBans();
				self:SaveFile();
				return true;
			else
				return false, "Ban not found";
			end;
		end;
		-----------
		OnMidTick = function(self)
			self:CheckMutes();
		end;
		-----------
		CheckMutes = function(self, id)
			local expired = {};
			for i, mute in pairs(self.mutes) do
				--Debug("Expire in:",mute.Expire,atommath:Get('timestamp')) 
				--Debug("Expired:",self:BanExpired(mute.Expire)) 
				if (mute.Expire ~= "Infinite" and self:BanExpired(mute.Expire)) then
					expired[i] = true;
					if (self:RemoveMuteByName(mute.Name)) then
						self:Msg(eMM_Removed, mute.Name, "Mute Expired");
						self:SaveFile();
					end;
				end;
			end;
			return expired and id and expired[id];
		end;
		-----------
		BanExpired = function(self, expireDate)
			return expireDate <= tonumber(atommath:Get('timestamp')); --math_leq(expireDate, atommath:Get('timestamp'));
		end;
		-----------
		CheckMute = function(self, t, playerId, targetId, message)
			local player = GetEnt(playerId);
			if (not player) then
				return false;
			end;
			local mute, muteId = self:GetBan(player:GetIP(), player:GetHostName(), player:GetProfile(), player:GetIdentifier());
			--Debug(player.CmdMsg)
			if (mute and not player.CmdMsg) then
				if (self:CheckMutes(muteId)) then
					return false;
				end;
				local remaining = calcTime(mute.Expire - tonumber(atommath:Get('timestamp'))--[[tonumber(math_sub(mute.Expire, atommath:Get('timestamp')))--]], true, 1, 1, 1, 1);
				SendMsg(CHAT_MUTESYS, player, "You are Muted, " .. remaining .. " | " .. mute.Reason);
				if (not player.MegaMute) then
					ATOMLog:LogMuteMsg("Blocked Message '%s$9' from %s$9", message, player:GetName())
					SendMsg(CHAT_MUTESYS, GetPlayers(min(MODERATOR, player:GetAccess())), "(%s: %s)", player:GetName(), message)
				else
					SysLog("<ATOM> : (Mute) : Completely Blocked message '%s' from '%s'", message, player:GetName());
				end;
				return true;
			end;
			--player.CmdMsg = false;
			return false;
		end;
		-----------
		IsMuted = function(self, player)
			return self:GetBan(player:GetIP(), player:GetHostName(), player:GetProfile(), player:GetIdentifier());
		end;
		-----------
		RestructureBans = function(self)
			local newBans = {};
			for i, v in pairs(self.mutes) do
				newBans[ arrSize(newBans)+1 ] = v;
			end;
			self.mutes = newBans;
		end;
		-----------
		ListMutes = function(self, player, index, option)

			local banCount = arrSize(self.mutes);
			if (banCount < 1) then
				return false, "no mutes found";
			end;
			if (index and index == 'flush' and player:HasAccess(self.cfg.ManageBans)) then
				self.mutes = {};
				self:SaveFile();
				self:Msg(eMM_Flushed, banCount, 'Admin Decision');
				SendMsg(CHAT_MUTESYS, player, "(MuteSystem: Reset [ " .. banCount .. " ] Mutes)");
				return true;
			end;
			
			
			
			local index_num = tonumber(index);
			if (index_num and self.mutes[index_num]) then
				local ban = self.mutes[index_num];
				
				local option = tostr(option):lower();
				if (option == "del") then
					if (player:HasAccess(self.cfg.ManageBans)) then
						local removed = self:RemoveMute(ban.IP[1], ban.HostName[1], ban.Profile[1], ban.Extra[1]);
						if (removed) then
							SendMsg(CHAT_MUTESYS, player, "(" .. ban.Name .. ": Mute Entry #" .. index_num .. " Removed)");
							self:SaveFile();
							return removed, self:Msg(eMM_Removed, ban.Name, 'Admin Decision');
						end;
					else
						return false, "insufficient access";
					end;
				end;
				
				local date		= ban.Date;
				local banDate 	= toDate(date);
				
				local expire 	= ban.Expire;
				local today 	= atommath:Get('timestamp');
				
				--local remaining = math_sub(expire, today);
				--local elapsed 	= math_sub(math_sub(expire, date), remaining);
					
				--	remaining 		= calcTime(tonumber(math_sub(expire, today)), true, unpack(GetTime_SMHD));
				--	elapsed 		= calcTime(tonumber(elapsed), true, unpack(GetTime_SMHD));
					
				--	Debug(remaining)
				--	Debug(elapsed)
				
				local elapsed = "NULL";
				if (expire ~= "Infinite") then
					elapsed 	= math_sub(math_sub(ban.Expire, date), math_sub(expire, today));
					expire		= calcTime(tonumber(math_sub(ban.Expire, today)), true, 1, 1, 1, 1, "$8");
					local elapsedpercentage = tonumber(math_div(math_mul((elapsed), 100), tonumber(ban.Time)))
					if (elapsedpercentage < 10) then
						elapsedpercentage = "0" .. elapsedpercentage
					end;
					elapsedpercentage = cutNum(elapsedpercentage, 2)
					elapsed 	= calcTime(tonumber(elapsed), true,  1, 1, 1, 1, "$8") .. " $9($4" .. elapsedpercentage .. "%$9)";
				else
					elapsed = calcTime(0, true,  1, 1, 1, 1, "$8") .. " $9($400%$9)";
				end;
				
				SendMsg(CHAT_MUTESYS, player, "Open console to view the Mute Entry #" .. index .. " (" .. ban.Name .. ")");
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9[           Name | $1' .. string.lenprint(ban.Name, 24) 		.. ' $9]            Entry | #$7' .. string.lenprint(index_num, 44) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9[             IP | $9' .. string.lenprint(ban.IP[1], 24) 		.. ' $9]           Domain | $9' .. string.lenprint(ban.HostName[1], 45) ..  ' $9]');
				SendMsg(CONSOLE, player, '$9[        Profile | $9' .. string.lenprint(ban.Profile[1], 24) 	.. ' $9]          Elapsed | $4' .. string.lenprint(elapsed, 45) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9[         Reason | $4' .. string.lenprint(ban.Reason, 24) 		.. ' $9]           Expiry | $4' .. string.lenprint(expire, 45) 			..  ' $9]');
				SendMsg(CONSOLE, player, '$9[      Timestamp | $9' .. string.lenprint(banDate, 24) 			.. ' $9]        Banned by | $5' .. string.lenprint(ban.Admin, 45) 		..  ' $9]');
				SendMsg(CONSOLE, player, '$9================================================================================================================');
			else
				
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9      Name                   Reason                Admin                 Date                    Expiry');
				SendMsg(CONSOLE, player, '$9================================================================================================================');
		
				for i, ban in pairs(self.mutes) do
				
					
					local date		= ban.Date;
					local banDate 	= toDate(date);
					--[[local today 	= atommath:Get('timestamp');
					local expire 	= ban.Expire;
	
					local remaining = math_sub(expire, today);
					local elapsed 	= math_sub(math_sub(expire, date), remaining);
					
					remaining 		= calcTime(tonumber(math_sub(expire, today)), true, unpack(GetTime_CSMHD));
					elapsed 		= calcTime(tonumber(elapsed), true, unpack(GetTime_CSMHD));--]]
					
					local expire = ban.Expire;
					if (expire ~= "Infinite") then
						expire = calcTime(tonumber(math_sub(ban.Expire, atommath:Get('timestamp'))), true, 1, 1, 1, 1, "$4")
					end;
				
					local msg = formatString('$9[ $1%s $9] $9%s $9| $4%s $9| $9%s $9| $9%s $9| $4%s',
						i 			.. repStr(1, i),
						ban.Name:sub(1, 20) 	.. repStr(20, ban.Name:sub(1, 20)),
						ban.Reason:sub(1, 19) 	.. repStr(19, ban.Reason:sub(1, 19)),
						ban.Admin:sub(1, 19) 	.. repStr(19, ban.Admin:sub(1, 19)),
						banDate		.. repStr(21, banDate),
						expire
					);
				SendMsg(CONSOLE, player,msg);
				end;
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CHAT_MUTESYS, player, "Open console to view the Mute List");
			end;
		end;
		-----------
		WriteMute = function(self, Name, IP, HostName, Profile, extra, Time, Reason, Country, Admin)
			if (not self:GetBan(IP, HostName, Profile, extra)) then
				local Timestamp = atommath:Get('timestamp');
				local Expire = tonumber(Timestamp) + Time;
				--while Time > 500000 do
				--	Expire = math_add(Expire, 500000);
				--	Debug("Million",Time)
				--	Time = Time - 500000;
				--end;
				--if (Time > 0) then
				--	Debug("Under million: ",Time)
				--	Expire = math_add(Expire, Time);
				--end;
				--
			--	Debug(Expire)
				--Debug(math_sub(Expire, Timestamp));
				
				self.mutes [ arrSize(self.mutes)+1 ] = {
					Name 		= Name,
					IP			= { IP },
					HostName	= { HostName },
					Profile		= { Profile },
					Extra		= { extra },
					Date		= Timestamp,
					Expire		= Expire,
					Reason		= Reason,
					Country		= Country,
					Admin		= Admin,
					Time		= Time
				};
				self:SaveFile();
				return true;
			else
				self:UpdateBanEntiries(IP, HostName, Profile, extra);
				return false;
			end;
		end;
		-----------
		GetPlayerBan = function(self, player)
			return self:GetBan(player:GetIP(), player:GetHostName(), player:GetProfile(), player:GetIdentifier());
		end;
		-----------
		GetBan = function(self, IP, HostName, Profile, extra)
			for i, v in pairs(self.mutes) do
				for j, k in pairs(v.IP) do
					if (type(IP)=="table") then
						for x, y in ipairs(IP) do
							if (k == y) then
								return v, i;
							end;
						end;
					else
						if (k == IP) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.HostName) do
					if (type(HostName)=="table") then
						for x, y in ipairs(HostName) do
							if (k == y) then
								return v, i;
							end;
						end;
					else
						if (k == HostName) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.Profile) do
					if (type(Profile)=="table") then
						for x, y in ipairs(Profile) do
							if (k == y) then
								return v, i;
							end;
						end;
					else
						if (k == Profile) then
							return v, i;
						end;
					end;
				end;
				for j, k in pairs(v.Extra) do
					if (type(extra)=="table") then
						for x, y in ipairs(extra) do
							if (k == y) then
								return v, i;
							end;
						end;
					else
						if (k == extra) then
							return v, i;
						end;
					end;
				end;
			end;
		end;
		-----------
		UpdateBanEntiries = function(self, IP, HostName, Profile, extra)
			local ban, banId = self:GetBan(IP, HostName, Profile, extra);
			if (banId) then
				local add = true;
				for i, ip in pairs(ban.IP) do
					if (ip == IP or EmptyString(IP)) then
						add = false;
					end;
				end;
				if (add) then
					add = false;
					self:Msg(eMM_UpdatedList, ban.Name, "IP: ", IP);
					self.mutes[banId].IP[arrSize(ban.IP)+1] = IP;
				else
					add = true;
					for i, hn in pairs(ban.HostName) do
						if (hn == HostName or EmptyString(HostName)) then
							add = false;
						end;
					end;
					if (add) then
						add = false;
						self:Msg(eMM_UpdatedList, ban.Name, "Host: ", HostName);
						self.mutes[banId].HostName[arrSize(ban.HostName)+1] = HostName;
					else
						add = true;
						for i, pf in pairs(ban.Profile) do
							if (pf == Profile or EmptyString(Profile)) then
								add = false;
							end;
						end;
						if (add) then
							add = false;
							self:Msg(eMM_UpdatedList, ban.Name, "ID: ", Profile);
							self.mutes[banId].Profile[arrSize(ban.Profile)+1] = Profile;
						else
							add = true;
							for i, ex in pairs(ban.Extra) do
								if (ex == extra or EmptyString(extra)) then
									add = false;
								end;
							end;
							if (add) then
								add = false;
								self:Msg(eMM_UpdatedList, ban.Name, "", extra);
								self.mutes[banId].Extra[arrSize(ban.Extra)+1] = extra;
							end;
						end;
					end;
				end;
			end;
			if (add) then
			--	Debug("Nothing Updated")
			else
				self:SaveFile();
			end;
		end;
		-----------
		Msg = function(self, case, p1, p2, p3)
			if (case == eMM_UpdatedList) then
				ATOMLog:LogMuteUpdate("Updated Mute %s$9 ($4%s%s$9)", p1, p2, p3);
			elseif (case == eMM_Added) then
				ATOMLog:LogMute("Added Mute %s$9 ($4%s, %s$9)", p1, p2, p3);
			elseif (case == eMM_Removed) then
				ATOMLog:LogMute("Removed Mute %s$9 ($4%s$9)", p1, p2);
			elseif (case == eMM_Loaded) then
				ATOMLog:LogMute("Successfully loaded $4%d$9 Mutes", p1);
			elseif (case == eMM_Flushed) then
				ATOMLog:LogMute("Flushed $4%d$9 Mutes ($4%s$9)", p1, p2);
			end;
		end;
	};
	-----------
	AutoWarns = {
		
		--------------
		AutoWarns = {},
		
		--------------
		Init = function(self)
			self:LoadAutoWarns()
		end,
		
		--------------
		InitPlayer = function(self, hPlayer)
			self:CheckAutoWarns(hPlayer)
		end,
		
		--------------
		CheckAutoWarns = function(self, hPlayer)
			
			--------------
			local sID = hPlayer:GetProfile()
			
			--------------
			local aWarns = self:GetWarns(sID)
			if (table.empty(aWarns)) then
				return true end
			
			--------------
			for i, aWarn in pairs(aWarns) do
				ATOMPunish.ATOMWarn:WarnPlayerEx(aWarn.Admin, aWarn.ID, hPlayer, aWarn.Reason, aWarn.Date)
				self:DeleteWarn(sID, i)
			end
			
			--------------
			self:SaveAutoWarns()
			
		end,
		
		--------------
		GetWarns = function(self, sID)
			return (self.AutoWarns[sID])
		end,
		
		--------------
		GetAllWarns = function(self)
		
			------------
			local aAllWarns = {}
			for sID, aWarns in pairs(self.AutoWarns) do
				for i, aWarn in pairs(aWarns) do
					table.insert(aAllWarns, aWarn) end end
				
			------------
			return aAllWarns
		end,
		
		--------------
		LoadAutoWarns = function(self)
			LoadFile("AutoWarns", "AutoWarns.lua")
			
			local iLoaded = table.count(self:GetAllWarns())
			if (iLoaded > 0) then
				ATOMLog:LogWarn("Successfully loaded %d Auto-Warnings", iLoaded) end
		end,
		
		--------------
		SaveAutoWarns = function(self)
			local aData = {}
			for sID, aWarns in pairs(self.AutoWarns) do
				for i, aWarn in pairs(aWarns) do
					aData[table.count(aData) + 1] = {
						sID,
						aWarn.Admin,
						aWarn.ID,
						aWarn.Date,
						aWarn.Reason
					}
				end
			end
			
			SaveFile("AutoWarns", "AutoWarns.lua", "ATOMPunish.AutoWarns:LoadWarn", aData)
		end,
		
		--------------
		LoadWarn = function(self, sID, sAdmin, iAdminID, sDate, sReason)
			self:AddWarn(sID, sAdmin, iAdminID, sDate, sReason)
		end,
		
		--------------
		Warn = function(self, hPlayer, sID, sReason)
		
			--------------
			local iTimestamp = atommath:Get("timestamp")
			local sReason = checkVar(sReason, "Admin Decision")
			
			--------------
			local sAdmin = hPlayer:GetName()
			local iAdminID = checkFunc(hPlayer.GetProfile, "-1", hPlayer)
			
			--------------
			ATOMLog:LogWarn("Adding Autowarn for %s (%s)", sID, sReason)
			self:AddWarn(sID, sAdmin, iAdminID, iTimestamp, sReason)
			
			--------------
			self:SaveAutoWarns()
		
		end,
		
		--------------
		AddWarn = function(self, sID, sAdmin, iAdminID, sDate, sReason)
			
			--------------
			self.AutoWarns = checkVar(self.AutoWarns, {})
			self.AutoWarns[sID] = checkVar(self.AutoWarns[sID], {})
			
			--------------
			table.insert(self.AutoWarns[sID], {
				Admin = sAdmin,
				ID = iAdminID,
				Date = sDate,
				Reason = sReason
			})
			
			--------------
			SysLog("Adding auto warn for id %s (%s)", sID, sReason)
		end,
		
		--------------
		DeleteWarn = function(self, sID, iIndex)
			
			--------------
			self.AutoWarns = checkVar(self.AutoWarns, {})
			
			--------------
			if (not isNull(self.AutoWarns[sID])) then
				if (iIndex) then
					self.AutoWarns[sID][iIndex] = nil
					else
						self.AutoWarns[sID] = nil end
			
				--------------
				SysLog("Removed auto warn(s) for id %s (%s)", sID, checkVar(iIndex, "<All>"))
			end
			
		end,
		
		
		--------------
		
	
	},
	-----------
	ATOMWarn = {
		cfg = {
			ManageWarns = ADMINISTRATOR;
			MuteWarns = 3,
			MuteTime = 60 * 60,
			BanMutes = 3,
			BanTime = 60 * 60 * 24,
			AutoWarn = {
				Spectator = false, -- Warn if spamming spectator mode
				ChatSpam = true, -- Warn if chat spamming
				ChatFlood = true, -- Warn if chat flooding
			}
		};
		-----------
		warns = ATOMPunish~=nil and (ATOMPunish.ATOMWarn or {}).warns or {};
		-----------
		Init = function(self)
			eWM_UpdatedList = 0;
			eWM_Added		= 1;
			eWM_Removed		= 2;
			eWM_Loaded		= 3;
			eWM_Flushed		= 4;
			
			self:LoadFile();
			
			WarnPlayer = function(...)
				return self:WarnPlayer(...);
			end;
		end;
		-----------
		LoadFile = function(self, t)
		--	Debug("Lodding?")
			self.warns = {};
			LoadFile("ATOMWarn", "Warns.lua");
			local warnCunt = arrSize(self.warns);
			if (warnCunt > 0) then
			--	Debug(warnCunt)
				self:Msg(eWM_Loaded, warnCunt);
			end;
		end;
		----------
		LoadWarn = function(self, Name, Profile1, Admin, Profile2, Reason, Date)
			--Reason=Reason or "why not"
			--Debug("Loaded warn:", Reason);
			if (Name and Reason and Date and Profile1) then
				table.insert(self.warns, {
					Name 		= Name,
					Profile1 	= Profile1,
					Admin 		= Admin,
					Profile2 	= Profile2,
					Reason 		= Reason,
					Date 		= Date
				});
			end;
		end;
		------------
		SaveFile = function(self, t)
			SaveFile("ATOMWarn", "Warns.lua", "ATOMPunish.ATOMWarn:LoadWarn", self:ConvertTable(self.warns));
		end;
		-----------
		ConvertTable = function(self, t)
			local n = {};
			for i, v in pairs(t) do
				n[arrSize(n)+1] = {
					v.Name,
					v.Profile1,
					v.Admin,
					v.Profile2,
					v.Reason,
					v.Date
				};
			--	Debug("Save warn:",v.Name,"R",v.Reason)
			end;
			return n;
		end;
		-----------
		OnMidTick = function(self)
			self:CheckWarnTime();
		end,
		-----------
		CheckWarnTime = function(self)
			local expired = false;
			local timestamp = atommath:Get("timestamp");
			local timeout = self.cfg.WarnLifetime or 60*60*24;
			for i, warn in pairs(self.warns) do
				--warn.Date=timestamp-ONE_DAY-1
				if (tonum(timestamp) > tonum(warn.Date) + timeout) then
					self:Msg(eWM_Removed, self:GetWarnCount(warn.Profile1), warn.Name, "Warn Expired");
					self.warns[i] = nil;
					expired = true;
				end;
				--Debug("expires in ",calcTime((tonum(warn.Date) + timeout)-tonum(timestamp), true, 1, 1, 1, 1))
			end;
			if (expired) then
				self:ReconstructureWarns();
				self:SaveFile();
			end;
		end,
		-----------
		WarnPlayer = function(self, player, target, reason)
			if (emptyString(reason)) then
				return false, "specify reason";
			end;
			self:Msg(eWM_Added, target:GetName(), player:GetName(), reason);
			self:WriteWarn(target:GetName(), target:GetIdentifier(), player:GetName(), (player.isServer and "-1" or player:GetIdentifier()), reason);
			self:CheckWarns(target, player, reason);
		end;
		-----------
		WarnPlayerEx = function(self, sAdmin, iAdminID, hTarget, sReason, sDate)

			--------------
			local sDate = checkVar(sDate, atommath:Get("timestamp"))
			local sReason = checkVar(sReason, "Admin Decision")

			--------------
			self:Msg(eWM_Added, hTarget:GetName(), sAdmin, sReason)
			
			--------------
			self:WriteWarn(hTarget:GetName(), hTarget:GetIdentifier(), sAdmin, iAdminID, sReason, sDate);
			self:CheckWarns(hTarget, ATOM.Server, sReason);
		end;
		-----------
		CheckWarns = function(self, player, admin, reason)
			local warnCunt, maxCunt = self:GetWarnCount(player:GetIdentifier()) or 0, self.cfg.BanWarns;
			-- if (not admin.isServer) then
				SendMsg(CHAT_WARNSYS, player, "(WARNINGS: (%d/%d) You have been Warned by %s (%s))", warnCunt, maxCunt, admin:GetName(), reason);
			-- end;
			if (warnCunt >= maxCunt) then
				ATOMPunish.ATOMBan:BanPlayer(ATOM.Server, player, self.cfg.BanTime, "Too many Warnings");
				--Debug("ban WARN")
				self:ClearWarns(player:GetIdentifier());
			elseif (warnCunt >= self.cfg.MuteWarns) then
				ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, player, self.cfg.MuteTime, "Too many Warnings");
				--Debug("Mute WARN")
			
			end;
		end,
		-----------
		ClearWarns = function(self, Id, Log)
			local cleared = 0;
			for i, warn in pairs(self.warns) do
				if (tostring(warn.Profile1) == tostring(Id)) then
					cleared = cleared + 1;
					--Debug("Removed",i)
					self.warns[i] = nil;
				end;
			end;
			--Debug(cleared," warns reset",Id)
			
			return cleared, (cleared>0 and self:SaveFile()), self:ReconstructureWarns();
		end,
		-----------
		ReconstructureWarns = function(self)
			local new = {};
			for i, v in pairs(self.warns) do
				new[ arrSize(new)+1 ] = v;
			end;
			self.warns = new;
		end,
		-----------
		WriteWarn = function(self, Name, Profile1, Admin, Profile2, Reason, sDate)
			local Timestamp = checkVar(sDate, atommath:Get('timestamp'))
			self.warns [ arrSize(self.warns)+1 ] = {
				Name 		= Name,
				Profile1 	= Profile1,
				Admin 		= Admin,
				Profile2 	= Profile2,
				Reason		= Reason,
				Date 		= Timestamp
			};
			self:SaveFile();
			return true;
		end;
		-----------
		IsWarned = function(self, player)
			return self:GetWarnCount(player:GetIdentifier()) >= 1;
		end;
		-----------
		GetWarnCount = function(self, Id)
			local warnCunt = 0;
			for i, v in pairs(self.warns) do
				if (tostring(v.Profile1) == tostring(Id)) then
					--Debug("found new",v.Profile1,Id)
					warnCunt = warnCunt + 1;
				end;
			end;
			--Debug("WARNS",warnCunt)
			return warnCunt;
		end;
		-----------
		ListWarns = function(self, player, index_warn, index, option)

			local warnCunt = arrSize(self.warns);
			if (warnCunt < 1) then
				return false, "no warnings found";
			end;
			local timestamp = atommath:Get('timestamp');
			
			if (index_warn and tostr(index_warn):lower() == 'flush' and player:HasAccess(self.cfg.ManageWarns)) then
				self.warns = {};
				self:SaveFile();
				self:Msg(eWM_Flushed, warnCunt, 'Admin Decision');
				SendMsg(CHAT_WARNSYS, player, "(WARNINGS: Flushed [ " .. warnCunt .. " ] Warnings)");
				return true;
			end;
			
			local temp = function(t, id)
				for i,v in ipairs(t) do
					if (v.id==id) then
						--Debug("FOUND!!!!")
						return i
					end;
				end;
				return 0
			end;
			
			local found = false;
			local themWarns = {};
			for i, warn in pairs(self.warns) do
				local ii=temp(themWarns,warn.Profile1);
				if (not themWarns[ii]) then
					ii=arrSize(themWarns)+1
					--Debug("NEW FUCKIN TAB:",ii,"ID",warn.Profile1)
					themWarns[ii] = {warns={},id=warn.Profile1,uid=i};
					
				end;
				table.insert(themWarns[ii].warns, warn);
			--	Debug(themWarns)
			end;
			table.sort(themWarns, function(a, b)
				return arrSize(a.warns) > arrSize(b.warns);
			end);
			for i, warn in pairs(themWarns) do
				table.sort(warn.warns, function(a, b)
					return a.Date>b.Date;
				end);
			end;
		
			--Debug(arr2str(themWarns))
			local index_warn = tonumber(index_warn);
			if (index_warn and themWarns[index_warn]) then
				local warns = themWarns[index_warn];
				local index2_num = tonumber(index);
				if (index2_num and warns.warns[index2_num]) then
					local warn = warns.warns[index2_num];
				
					local option = tostr(option):lower();
					if (option == "del") then
						if (player:HasAccess(self.cfg.ManageWarns)) then
							self.warns[warns.uid] = nil;
							self:ReconstructureWarns();
							SendMsg(CHAT_WARNSYS, player, "(" .. warn.Name .. ": Removed Warn #" .. index2_num .. ")");
							self:SaveFile();
							return true, self:Msg(eWM_Removed, self:GetWarnCount(warn.Profile1), warn.Name, 'Admin Decision');
						else
							return false, "insufficient access";
						end;
					end;
				
					local date		= warn.Date;
					local banDate 	= toDate(tonumber(date));
					
					local expire 	= calcTime((tonum(date) + (self.cfg.WarnLifetime or ONE_DAY))-tonum(timestamp), true, 1, 1, 1, 1, "$4");
					local today 	= timestamp;
					local elapsed 	= calcTime(today - date, true, 1, 1, 1, 1, "$8"); --tonumber(tonum(date)+(self.cfg.WarnLifetime or ONE_DAY)) - tonum(date); --math_sub(expire, today));
					
					--[[
					local elapsedpercentage = tonumber(math_div(math_mul((elapsed), 100), tonumber(warn.Time)))
					if (elapsedpercentage < 10) then
						elapsedpercentage = "0" .. elapsedpercentage
					end;
					elapsedpercentage = cutNum(elapsedpercentage, 2)
					elapsed 	= calcTime(tonumber(elapsed), true,  1, 1, 1, 1, "$8") .. " $9($4" .. elapsedpercentage .. "%$9)";
					--]]
					
					SendMsg(CHAT_WARNSYS, player, "Open console to view the Warn Entry #" .. index .. " (" .. warn.Name .. ")");
					SendMsg(CONSOLE, player, '$9================================================================================================================');
					SendMsg(CONSOLE, player, '$9[           Name | $1' .. string.lenprint(warn.Name, 24) 		.. ' $9]          Profile | $4' .. string.lenprint(warn.Profile1, 45)	..  ' $9]');
					SendMsg(CONSOLE, player, '$9[          Admin | $1' .. string.lenprint(warn.Admin, 24) 		.. ' $9]          Profile | $4' .. string.lenprint(warn.Profile2, 45)	..  ' $9]');
					SendMsg(CONSOLE, player, '$9[         Reason | $4' .. string.lenprint(warn.Reason, 24)		.. ' $9]            Entry | $4' .. string.lenprint(index2_num .. "/" .. self.cfg.BanWarns, 45) 		..  ' $9]');
					SendMsg(CONSOLE, player, '$9[         Expiry | $4' .. string.lenprint(expire, 24)	 		.. ' $9]          Elapsed | $4' .. string.lenprint(elapsed, 45) 		..  ' $9]');
					SendMsg(CONSOLE, player, '$9[      Timestamp | $9' .. string.lenprint(banDate, 24) 			.. ' $9]                    $5' .. string.lenprint("", 45) 		..  ' $9]');
					SendMsg(CONSOLE, player, '$9================================================================================================================');
				elseif (tostring(index):lower() == "flush") then
					Debug("Flush all from", warns.Name)
				else
					Debug("List all from ",warns.Name)
					
					SendMsg(CONSOLE, player, '$9================================================================================================================');
					SendMsg(CONSOLE, player, '$9  ID   Name                   Reason                 Admin                  Date               Expiry        ');
					SendMsg(CONSOLE, player, '$9================================================================================================================');
					
					
					for i, warn in pairs(warns.warns) do
					
						local date		= warn.Date;
						local banDate, trash  = toDate(tonumber(date)):match("(.*):(%d+)");
						local expire = calcTime((tonum(date) + (self.cfg.WarnLifetime or ONE_DAY))-tonum(timestamp), true, 1, 1, 1, 1, "$4"); --calcTime(timestamp-tonumber(date), true, 1, 1, 1, 1, "$4")
						
						local msg = formatString('$9[ $1%s$9 | $9%s$9 | $4%s$9 | $9%s$9 | $9%s$9 | $4%s $9]',
														string.lenprint(i, 2),
																string.lenprint(warn.Name:sub(1,20),20),
																		string.lenprint(warn.Reason:sub(1,20), 20),
																			string.lenprint(warn.Admin:sub(1,20), 20),
																				string.lenprint(banDate, 16),
																					string.lenprint(expire, 12)
						);
						SendMsg(CONSOLE, player,msg);
					end;
					SendMsg(CONSOLE, player, '$9================================================================================================================');
					SendMsg(CHAT_WARNSYS, player, "Open console to view the [ %d ] Warnings of %s", arrSize(warns.warns), warns.id);
				end;
			else
				SendMsg(CONSOLE, player, "$9==============================================================================================");
				SendMsg(CONSOLE, player, "$9  ID   Name                                 Profile    Warnings     Last Warning              ");
				SendMsg(CONSOLE, player, "$9==============================================================================================");
				for i, warn in pairs(themWarns) do
					local lastWarn = calcTime(atommath:Get("timestamp")-warn.warns[1].Date, true, 1, 1, 1, 1, "$4");
					SendMsg(CONSOLE, player, "$9[ $1%s$9 | %s$9 | $4%s$9 | %s$9 | %s$9 ]",
													string.lenprint(i, 2),
														string.lenprint(warn.warns[1].Name, 34),
															string.lenprint(warn.id, 8),
																string.lenprint(arrSize(warn.warns) .. "/" .. self.cfg.BanWarns, 10),
																	string.lenprint(lastWarn .. " Ago", 24)
					);
				end;
				SendMsg(CONSOLE, player, "$9==============================================================================================");
				SendMsg(CHAT_MUTESYS, player, "Open console to view the List of [ %d ] Warnings", arrSize(self.warns));
			end;
		end;
		-----------
		ShouldWarn = function(self, case)
			return self.cfg.AutoWarn[case]
		end,
		-----------
		Msg = function(self, case, p1, p2, p3)
			if (case == eWM_UpdatedList) then
			--	ATOMLog:LogMuteUpdate("Updated Mute %s$9 ($4%s%s$9)", p1, p2, p3);
			elseif (case == eWM_Added) then
				ATOMLog:LogWarn("%s$9 Has been Warned by %s$9 (%s)", p1, p2, p3);
			elseif (case == eWM_Removed) then
				ATOMLog:LogWarn("Removed Warning #%d from %s ($4%s$9)", p1, p2, p3);
			elseif (case == eWM_Loaded) then
				ATOMLog:LogWarn("Successfully loaded $4%d$9 Warnings", p1);
			elseif (case == eWM_Flushed) then
				ATOMLog:LogWarn("Flushed $4%d$9 Warnings ($4%s$9)", p1, p2);
			end;
		end;
	};
	-----------
	ATOMPunish = {
		cfg = {
		
		};
		-----------
		Init = function(self)
			ePM_Kicked = 0;
			
			KickPlayer = function(...)
				return self:KickPlayer(...);
			end;
		end;
		-----------
		KickPlayer = function(self, kickedBy, player, reason)
			
			local sReason = checkString(sReason, ADMIN_DECISION)

			player.wasKicked = true
			self:Msg(ePM_Kicked, player:GetName(), sReason)
			return true, self:Kick(player.actor:GetChannel(), sReason)
		end;
		-----------
		Kick = function(self, channel, reason)
			PuttyLog("CATOM::KickPlayer ($4Channel: %d$9)", channel)
			Script.SetTimer(10, function(self)
				ATOMDLL:Kick(channel, reason)
			end)
		end;
		-----------
		Msg = function(self, case, p1, p2, p3)
			if (case == ePM_Kicked) then
				if (p2) then
					SendMsg(ERROR, ALL, "[ SERVER : DEFENSE ] :: %s WAS KICKED FROM THE SERVER :: [ %s ]", p1:upper(), p2:upper());
					ATOMLog:LogKick("%s$9 was kicked from the Server ($4%s$9)", p1, p2);
				else
					SendMsg(ERROR, ALL, "[ SERVER : DEFENSE ] :: %s WAS KICKED FROM THE SERVER", p1:upper());
					ATOMLog:LogKick("%s$9 was kicked from the Server", p1);
				end;
			end;
		end;
	};
	-----------
	Init = function(self)
	
		self.ATOMBan:Init	()
		self.ATOMMute:Init	()
		self.ATOMWarn:Init	()
		self.AutoWarns:Init	()
		self.ATOMPunish:Init()
		
		g_warnSystem 	= self.ATOMWarn;
		g_banSystem  	= self.ATOMBan;
		g_muteSystem 	= self.ATOMMute;
		g_punishSystem  = self.ATOMPunish;
		
	end;
	-----------
	ParseTime = function(self, s, stringVal)
		return parseTime(s, stringVal);
	end;
	-----------
	OnMidTick = function(self)
		self.ATOMBan:OnMidTick	();
		self.ATOMMute:OnMidTick	();
		self.ATOMWarn:OnMidTick	();
	end;
};