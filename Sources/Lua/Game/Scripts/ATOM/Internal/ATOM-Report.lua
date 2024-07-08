ATOMReports = {
	cfg = {
		-- Maximum reports from user per game
		MaximumReports = 3,
		ManageReports = MODERATOR
	},
	savedReports = (ATOMReports ~= nil and ATOMReports.savedReports or {}),
	--------------
	Init = function(self)
		-- Something
		
		eRM_Removed = 0;
		eRM_Loaded	= 1;
		eRM_Flushed	= 2;
		
		self:LoadFile();
	end,
	--------------
	Report = function(self, player, target, reason)
	
		if (not target) then
			return false, "no target specified"
		end
		
		local reason = reason or "N/A"
	
		if (player == target) then
			return false, "cannot report yourself";
		elseif (not target.reports) then
			target.reports = {};
		elseif ((target.reports[player.id] or 0) > self.cfg.MaximumReports) then
			return false, "you already reported this player " .. self.cfg.MaximumReports .. (self.cfg.MaximumReports>0 and " times" or " time");
		end;
		target.reports[player.id] = (target.reports[player.id] or 0) + 1;
		SendMsg(CHAT_REPORT, player, "(%s: Has been reported to Admins)", target:GetName(), player:GetName());
		SendMsg(CHAT_ADMIN, self.cfg.ManageReports, "(%s: Has been reported by %s, use !reports to view report)", target:GetName(), player:GetName());
		ATOMLog:LogReport(self.cfg.ManageReports, "%s$9 has been reported by %s$9 ($4%s$9)", target:GetName(), player:GetName(), reason);
		self:WriteReport(player, target:GetName(), reason, target:GetProfile(), player:GetProfile());
	end,
	--------------
	WriteReport = function(self, player, name, reason, profile0, profile1)
		local ts = atommath:Get("timestamp");
		table.insert(self.savedReports, {
			Reporter 	= player:GetName(),
			Date 		= os.date(),
			Timestamp	= ts,
			Name		= name,
			Reason		= reason,
			ProfileID0	= profile0,
			ProfileID1	= profile1,
			Read		= false
		});
		self:SaveFile();
	end,
	--------------
	GetReports = function(self, unread)
		local reports = 0;
		for i, r in pairs(self.savedReports) do
			if (not unread or r.Read == false) then
				reports = reports + 1;
			end;
		end;
		return reports;
	end,
	--------------
	IsReported = function(self, Id)
		for i, report in pairs(self.savedReports) do
			if (report.ProfileID0 and report.ProfileID0 ~= "0" and report.ProfileID0 == Id) then
				return true;
			end;
		end;
		return false;
	end,
	--------------
	OnConnected = function(self, player)
		Script.SetTimer(5000, function()
			if (player:HasAccess(self.cfg.ManageReports)) then
				local reports = self:GetReports(true);
				if (reports > 0) then
					SendMsg(CHAT_REPORT, player, "There are [ %d ] new unread reports, use !reports to read them", reports);
				end;
			end;
		end);
	end,
	--------------
	Msg = function(self, type, p1, p2, p3)
		if (type == eRM_Removed) then
			ATOMLog:LogReport(self.cfg.ManageReports, "Report %s$9 has been removed ($4%s$9)", p1, p2);
		elseif (type == eRM_Loaded) then
			ATOMLog:LogReport(self.cfg.ManageReports, "Loaded %d Reports", p1);
		elseif (type == eRM_Flushed) then
			ATOMLog:LogReport(self.cfg.ManageReports, "Flushed %d Reports ($4%s$9)", p1, p2);
		end;
	end,
	--------------
		ListReports = function(self, player, index, option)

			local reports = arrSize(self.savedReports);
			if (reports < 1) then
				return false, "no reports found";
			end;
			if (index and index == 'flush' and player:HasAccess(self.cfg.ManageReports)) then
				self.savedReports = {};
				self:SaveFile();
				self:Msg(eRM_Flushed, reports, 'Admin Decision');
				SendMsg(CHAT_REPORT, player, "(Reports: Flushed [ " .. reports .. " ] Reports)");
				return true;
			end;
			
			local index_num = tonumber(index);
			if (index_num and self.savedReports[index_num]) then
				local report = self.savedReports[index_num];
				
				local option = tostr(option):lower();
				if (option == "del") then
					if (player:HasAccess(self.cfg.ManageBans)) then
						table.remove(self.savedReports, index_num);
						SendMsg(CHAT_REPORT, player, "(" .. report.Name .. ": Report Entry #" .. index_num .. " Removed)");
						self:SaveFile();
						return true, self:Msg(eRM_Removed, report.Name, 'Admin Decision');
					else
						return false, "insufficient access";
					end;
				end;
				
				local before	= report.Timestamp;
				local today 	= atommath:Get('timestamp');
				
				local timeAgo 	= calcTime(tonumber(math_sub(today, before)), unpack(GetTime_CSMHD));
				
				
				SendMsg(CHAT_REPORT, player, "Open console to view the Report Entry #" .. index .. " (" .. report.Name .. ")");
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9[           Name | $1' .. string.lenprint(report.Name, 24) 					.. ' $9]          Profile | $4' .. string.lenprint((report.ProfileID0 or "N/A"), 45) 	..  ' $9]');
				SendMsg(CONSOLE, player, '$9[    Reported By | $9' .. string.lenprint(report.Reporter, 24) 				.. ' $9]          Profile | $4' .. string.lenprint((report.ProfileID1 or "N/A"), 45) 	..  ' $9]');
				SendMsg(CONSOLE, player, '$9[         Reason | $9' .. string.lenprint(report.Reason, 24) 				.. ' $9]                    $5' .. string.lenprint("", 45) 								..  ' $9]');
				SendMsg(CONSOLE, player, '$9[      Timestamp | $4' .. string.lenprint(toDate(before), 24) 				.. ' $9]         Time Ago | $4' .. string.lenprint(timeAgo, 45) 						..  ' $9]');
				
				if (not self.savedReports[index_num].Read) then
					self.savedReports[index_num].Read = true;
					self:SaveFile();
				end;
				SendMsg(CONSOLE, player, '$9================================================================================================================');
			else
				
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CONSOLE, player, '$9      Name                   Reason                Reported by           Date                    Time Ago');
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				
				
				for i, report in pairs(self.savedReports) do
				
					
				
					local before	= report.Timestamp;
					local today 	= atommath:Get('timestamp');
				
					local timeAgo 	= calcTime(tonumber(math_sub(today, before)), unpack(GetTime_CSMHD));
					--[[local today 	= atommath:Get('timestamp');
					local expire 	= ban.Expire;
	
					local remaining = math_sub(expire, today);
					local elapsed 	= math_sub(math_sub(expire, date), remaining);
					
					remaining 		= calcTime(tonumber(math_sub(expire, today)), true, unpack(GetTime_CSMHD));
					elapsed 		= calcTime(tonumber(elapsed), true, unpack(GetTime_CSMHD));--]]
					
				
					local msg = formatString('$9[ $1%s $9] $9%s $9| $4%s $9| $9%s $9| $9%s $9| $4%s',
						i 			.. repStr(1, i),
						report.Name:sub(1, 20) 	.. repStr(20, report.Name:sub(1, 20)),
						report.Reason:sub(1, 19) 	.. repStr(19, report.Reason:sub(1, 19)),
						report.Reporter:sub(1, 19) 	.. repStr(19, report.Reporter:sub(1, 19)),
						toDate(before)		.. repStr(21, toDate(before)),
						timeAgo
					);
				SendMsg(CONSOLE, player,msg);
				end;
				SendMsg(CONSOLE, player, '$9================================================================================================================');
				SendMsg(CHAT_REPORT, player, "Open console to view the Report List");
			end;
		end,
	--------------
	LoadReport = function(self, Reporter, Date, Timestamp, Name, Reason, ProfileID0, ProfileID1, Read)
		table.insert(self.savedReports, {
			Reporter 	= Reporter,
			Date 		= Date,
			Timestamp	= Timestamp,
			Name		= Name,
			Reason		= Reason,
			ProfileID0	= ProfileID0,
			ProfileID1	= ProfileID1,
			Read		= Read
		});
	end,
	--------------
	SaveFile = function(self)
		local t = {};
		for i, v in pairs(self.savedReports) do
			t[arrSize(t)+1] = {
				v.Reporter,
				v.Date,
				v.Timestamp,
				v.Name,
				v.Reason,
				v.ProfileID0,
				v.ProfileID1,
				v.Read
			};
		end;
		SaveFile("ATOMReports", "Reports.lua", "ATOMReports:LoadReport", t);
	end,
	--------------
	LoadFile = function(self)
		self.savedReports = {}; -- reset
		LoadFile("ATOMReports", "Reports.lua");
		local reportCount = arrSize(self.savedReports);
		if (reportCount > 0) then
			self:Msg(eRM_Loaded, reportCount);
		end;
	end
};
ATOMReports:Init();