ATOM_Usergroups = {
	cfg = {
		Groups = { -- lower position means higher access
			--long name      short name      console color
			{ "Guest",			"Guest",		"$3" };
			{ "Premium",		"Premium",		"$5" };
			{ "Moderator",		"Mod",			"$8" };
			{ "Administrator",  "Admin",		"$4" };
			{ "SuperAdmin",    "SuperAdmin",   "$1" };
			{ "Developer",      "Dev",			"$7" };
		};
		RegisteredUsers = {};
		
		ManageApplications = 7,
	};
	----------
	Users  = {};
	----------
	Groups = {};
	----------
	Applications = {}; -- Users who applied for Staff (Moderator)
	----------
	IsUserGroup = function(self, ID)
		return self.Groups[ID]
	end,
	----------
	IsPriorityGroup = function(self, iGroup)
		local aGroup = self:IsUserGroup(iGroup)
		if (not aGroup) then
			return false
		end

		return (aGroup[5] == true)
	end,
	----------
	SuspendPlayer = function(self, player, target, time, reason)
		if (not target) then
			return false, "no player specified"
		end
		
		local time = (ATOMPunish:ParseTime(time or ONE_DAY, true) or ONE_DAY * 7)
		if (time and time ~= "infinite") then
			if (tonumber(time) > (ONE_DAY * 91)) then
				time = ONE_DAY * 91
			end
		end
		
		local time = atommath:Get("timestamp") + time
		local reason = reason or "N/A"
		
		local iProfile
		local hTarget = GetPlayer(target)
		if (hTarget) then
			iProfile = hTarget:GetProfile()
			if (not iProfile or tostring(iProfile) == "0") then
				return false, "player does not have a profile"
			end
			if (hTarget:GetAccess() <= GUEST) then
				return false, "player already a guest"
			end
			
			Debug("hTarget:IsSuspended()",hTarget:IsSuspended())
			if (hTarget:IsSuspended()) then
				SendMsg(CHAT_ATOM, player, "(%s: Suspension for (%s) Liftet)", hTarget:GetName(), hTarget:GetSuspensionReason())
				self:DoUnsuspendUser(iProfile)
				self:SaveFile()
				return true
			end
			
			Debug(iProfile)
			SendMsg(CHAT_ATOM, player, "(%s: Has Been Suspended (%s))", hTarget:GetName(), (reason))
			self:DoSuspendUser(iProfile, time, reason)
			self:SaveFile()
		else
			local aTarget = self:GetRegUserByName(target)
			if (not aTarget) then
				return false, "user not found"
			end
			if (aTarget.Access <= GUEST) then
				return false, "user is already a guest"
			end
			
			if (self:IsSuspended(aTarget.Profile)) then
				SendMsg(CHAT_ATOM, player, "(%s: Suspension for (%s) Liftet)", (aTarget.Name or "N/A"), self:GetSuspensionReason(aTarget.Profile))
				self:DoUnsuspendUser(aTarget.Profile)
				self:SaveFile()
				return true
			end
			
			SendMsg(CHAT_ATOM, player, "(%s: Has Been Suspended (%s))", (aTarget.Name or "N/A"), (reason))
			self:DoSuspendUser(aTarget.Profile, time, reason)
			self:SaveFile()
		end
		
	end,
	----------
	AddGroup = function(self, name, shortName, color, bPriority)
	
		if (not name) then
			return false, ATOMLog:LogError("No name specified for AddGroup() in ATOM_Usergroups");
		end;
		if (tonumber(name:sub(1, 1))) then
			return false, ATOMLog:LogError("First character of user group name must be a letter");
		end;
		if (not shortName) then
			shortName = name;
		end;
		if (not color) then
			local color = "$1";
		end;
		
		name = cleanString(name, "([%-%.%$(%d+)]*)");
		
		local nextGroup = arrSize(self.Groups) + 1;
		self.Groups[ nextGroup ] = { nextGroup, name, shortName, color or "$1", bPriority };
		_G[name:upper()] = nextGroup;
		
		--Debug("Added group:", name, "short name:", shortName, "id:", nextGroup, "color:", color)
	end;
	----------
	GetGroupData = function(self, ID)
		return self:IsUserGroup(ID);
	end;
	----------
	Init = function(self, fromConfig, nolog)
		local cfg = self.cfg;
		
		if (fromConfig) then
			self.Groups = {};
		end;
		
		AddUser = function(...)
			return self:AddUser(...)
		end
		
		local group;
		
		if (Config and Config.UserGroups and Config.UserGroups.Groups) then
			cfg.Groups = Config.UserGroups.Groups;
			if (not cfg.Groups or arrSize(cfg.Groups) < 1) then
				cfg.Groups = {
					{ "Default", "Def", "$9" };
				};
			end;
		end;

		for i = 1, arrSize(cfg.Groups) do
			group = cfg.Groups [ i ]

			if (group) then
				self:AddGroup(group[1], group[2], group[3], group[4])
				if (fromConfig) then
				--	ATOM:Log(5, "Registered new user group %s (archive: %s)", group[1], string.bool(group[4]))
				end
			else
				ATOM:Log(4, "Failed to get group by ID: " .. i)
			end
		end

		self:LoadGroups();
		
		if (Config and Config.UserGroups) then
			cfg.Groups = Config.UserGroups;
			if (not cfg.Groups or arrSize(cfg.Groups) < 1) then
				cfgs.Groups = {
					{ "Default", "Def", "$9" };
				};
			end;
			if (Config.UserGroups.RegisteredUsers) then
				local changed = true;
				for i, user in pairs(Config.UserGroups.RegisteredUsers or{}) do
					if (user.Profile and user.Name and user.Access) then
						--table.insert(self.Users, user);
						changed = changed and self:LoadUser(user.Name, user.Access, user.Profile, user.ProtectName, user.Password, user.AddedDate, false, 0, "No Reason Specified");
					end;
				end;
				if (changed) then
					self:SaveFile();
				end;
			end;
		end;
		
		self:LoadStaffApplications();
		
		if (not nolog and arrSize(Users or{}) >0) then
			ATOMLog:LogUser(MODERATOR, "Loaded %d Users", arrSize(Users or{}));
		end;
		if (not nolog and arrSize(self.Applications or{}) >0) then
			ATOMLog:LogUser(MODERATOR, "Loaded %d Staff-Applications", arrSize(self.Applications or{}));
		end;
	end;
	----------
	NewUser = function(self, player, target, access, bForce)

		if (not access) then
			return false, "no access specified"
		end
	
		local targetAccess = target:GetAccess();
		local playerAccess = player:GetAccess();
	
		if (tostr(target:GetIdentifier()) == "0") then
			return false, "Null profile cannot be added"
		end

		local aAccessList = {}
		for i = GetLowestAccess(), GetHighestAccess() do
			local sRank = GetGroupData(i)[2]
			if (not player:HasAccess(i)) then
				sRank = string.censor(sRank)
			end
			aAccessList[i] = { sRank }
		end

		local iAccess = tonumber(access) or tonumber(_G[string.upper(access)])
		if (not IsUserGroup(iAccess)) then
			SendMsg(CHAT_ATOM, player, "Open Console to view the list of Possible Ranks")
			ListToConsole(player, aAccessList, "Server Ranks")
			return false, "Invalid Access";
		end

		if (targetAccess > playerAccess and not bForce) then
			return false, "Insufficient Access"
		end
	
		if (iAccess == targetAccess) then
			return false, "Player is already " .. GetGroupData(iAccess)[2]
		end
		
		self:AddUser(target, iAccess, true, true)
		--self:SaveFile();
		
		ATOMLog:LogUser(iAccess, "%s$9 has been " .. ((iAccess > targetAccess) and "Promoted" or "Demoted") .. " to " .. GetGroupData(iAccess)[4] .. GetGroupData(iAccess)[2], target:GetName());
		SendMsg(CENTER, target, "You have been " .. ((iAccess > targetAccess) and "Promoted" or "Demoted") .. " to " .. GetGroupData(iAccess)[2]);
		SendMsg(CENTER, player, "(%s: %s to %s)", target:GetName(), ((iAccess > targetAccess) and "Promoted" or "Demoted"), GetGroupData(iAccess)[2]);
		
		-- FIXME: USER BUG
		--self.Users = {};
		--self:LoadGroups();
	end;
	----------
	TempAccess = function(self, player, target, access)
	
		local targetAccess = target:GetAccess();
		local playerAccess = player:GetAccess();

		local iAccess = checkNumber(tonumber(access), -1)
		if (not IsUserGroup(iAccess)) then
			return false, "Invalid Access";
		end;
		--Debug(playerAccess .. " >> " .. targetAccess)
		if (--[[playerAccess > targetAccess or ]]targetAccess > playerAccess) then
			return false, "Insufficient Access";
		end;
	
		if (iAccess == targetAccess) then
			return false, "Player is already " .. GetGroupData(iAccess)[2];
		end;
		
		target.Info.Access = access;
		--self:AddUser(target, access, true, true);
		--self:SaveFile();
		
		ATOMLog:LogUser(iAccess, "%s$9 has been temporarily " .. ((iAccess > targetAccess) and "Promoted" or "Demoted") .. " to " .. GetGroupData(iAccess)[4] .. GetGroupData(iAccess)[2], target:GetName());
		SendMsg(CENTER, target, "You have been temporarily " .. ((iAccess > targetAccess) and "Promoted" or "Demoted") .. " to " .. GetGroupData(iAccess)[2]);
		
		if (player ~= ATOM.Server) then
			SendMsg(CENTER, player, "(%s: Temporarily %s to %s)", target:GetName(), ((iAccess > targetAccess) and "Promoted" or "Demoted"), GetGroupData(iAccess)[2]);
		end
		-- FIXME: USER BUG
		--self.Users = {};
		--self:LoadGroups();
	end;
	----------
	DelUser = function(self, player, ID)
		--Debug(tostr(player),ID)
		local playerAccess = player:GetAccess();
	
		local regUser = self:GetRegUserByName(ID) or self:GetRegUser(ID, true);
		if (not regUser) then
			return false, "invalid user";
		end;
		
		local targetAccess = regUser.Access;
		if (targetAccess >= playerAccess) then
			return false, "Insufficient Access";
		end;
	
		self:RemoveUser(regUser.Profile);
		
		ATOMLog:LogUser(targetAccess, "%s$9 has been removed from Registered Users", regUser.Name);
		
		local target = GetPlayerByProfileID(ID);
		if (target) then
			SendMsg(CENTER, target, "You have been removed from Registered Users");
			SendMsg(CENTER, player, "(%s: removed from Registered Users)", target:GetName());
			target.Info.Access = GetLowestAccess();
		else
			SendMsg(CENTER, player, "(%s: removed from Registered Users)", regUser.Name);
		end;
		
	end;
	-----------------
	GetAccessByID = function(self, sID)
		for i, aUser in pairs(self.Users) do
			if (aUser.Profile == sID) then
				return tonumber(aUser.Access) end
		end
	end,
	
	-----------------
	RegUser = function(self, player, Name, ID, Access)
		--Debug(tostr(player),ID)
		Debug(Access)

		local aAccessList = {}
		for i = GetLowestAccess(), GetHighestAccess() do
			local sRank = GetGroupData(i)[2]
			if (not player:HasAccess(i)) then
				sRank = string.censor(sRank)
			end
			aAccessList[i] = { sRank }
		end

		local iAccess = tonumber(_G[string.upper(Access)])
		if (not iAccess or iAccess < GetLowestAccess() or iAccess > GetHighestAccess()) then
			SendMsg(CHAT_ATOM, player, "Open Console to view the list of Possible Ranks")
			ListToConsole(player, aAccessList, "Server Ranks")
			return false, "invalid access"
		end
		local playerAccess = player:GetAccess();
		if (player.isServer) then
			playerAccess = DEVELOPER
		end
	
		local regUser = self:GetRegUserByName(ID) or self:GetRegUser(ID, true);
		if (regUser) then
			return false, "user already exists";
		end;
		
		if (iAccess > playerAccess) then
			return false, "Insufficient Access";
		elseif (iAccess == GetLowestAccess()) then
			return false, "to remove an account, please use !deluser"
		elseif (tostring(ID) == "0") then
			return false, "cannot register null profile"
		end;
		
		table.insert(self.Users, {
			Name		= Name,
			Access		= iAccess,
			Profile		= tostring(ID),
			ProtectName = true,
			Password	= self:GetRndPassword(),
			AddedDate	= atommath:Get("timestamp"),
			Suspended 	= {
				IsSuspended = false,
				Time = 0,
				Reason = "No Reason Specified"
			}
		});

		self:SaveFile();
		
		ATOMLog:LogUser(iAccess, "%s$9 has been registered as %s (%s)", Name, GetGroupData(iAccess)[2], tostring(ID));
		
		local target = GetPlayerByProfileID(ID);
		if (target) then
			SendMsg(CENTER, target, "You have been Registered as %s", GetGroupData(iAccess)[2]);
			SendMsg(CENTER, player, "(%s: Registered As User %s (%s))", target:GetName(), GetGroupData(iAccess)[2], ID);
			target.Info.Access = GetLowestAccess();
		else
			SendMsg(CENTER, player, "(%s: Registered As User %s (%s))", Name, GetGroupData(iAccess)[2], ID);
		end;
		
	end;
	----------
	--[[RemoveUser = function(self, ID)
		Debug(self.Users)
		Debug("X")
		for i, user in ipairs(self.Users) do
			Debug(user.Profile, ID)
			if (user.Profile == ID) then
				table.remove(self.Users, i);
				self:SaveFile();
			end;
		end;
	end;--]]
	----------
	AddUser = function(self, player, access, protectName, force)
		local identifer = player:GetIdentifier();
		if (not player:HasAccess(access) or force) then
			if (identifer and tostring(identifer) ~= "0") then
				if (access > GetLowestAccess()) then
					table.insert(self.Users, {
						Name		= player:GetName(),
						Access		= access,
						Profile		= tostring(identifer),
						ProtectName = (protectName == nil and true or protectName),
						Password	= self:GetRndPassword(),
						AddedDate	= atommath:Get("timestamp"),
						Suspended 	= {
							IsSuspended = false,
							Time = 0,
							Reason = ""
						}
					});
				else
					self:RemoveUser(identifer)
				end;
			end;
			player.Info.Access = access
		end
		self:SaveFile()
	end,
	----------
	Login = function(self, player, name, password)
		if (player.LoginTries and player.LoginTries < 1) then
			return false, "please try again later";
		end;
		local Id = player:GetIdentifier();
		local reg = self:GetRegUserByName(name);
		if (not reg) then
			return false, "no such account was found";
		end;
		local acc = player:GetAccess();
		local pw = reg.Password;
		if (not pw) then
			self.Users[reg.Profile].Password = self:GetRndPassword();
			return false, "login failed, please try again";
		end;
		if (pw ~= password) then
			player.LoginTries = (player.LoginTries or 3) - 1;
			return false, "wrong password";
		end;
		reg.Access = max(GetHighestAccess(), reg.Access);
		if (acc > reg.Access) then
		--	return false, "lower access";
		end;
		player.Info.Access = reg.Access;
		SendMsg(CHAT_ATOM, player, "You have logged into Account %s (%s)", reg.Name, reg.Profile);
		ATOMLog:LogUser(reg.Access, "%s$9 has logged into Account %s (%s, %s)", player:GetName(), reg.Name, (GetGroupData(reg.Access) and GetGroupData(reg.Access)[2] or "<error>"), reg.Profile);
		
		player.Info.Id = reg.Profile;
		player.actor:SetProfileId(tonum(reg.Profile));
		
		ATOM:InitPlayer(player)
	end,
	----------
	ChangePassword = function(self, player, password)
		local Id = player:GetIdentifier();
		local reg = self:GetRegUser(Id, true);
		if (not reg) then
			return false, "you are not a registered user";
		end;
		local pw = reg.Password;
		if (pw == password) then
			return false, "choose a new password";
		end;
		reg.Password = password;
		SendMsg(CHAT_ATOM, player, "You Account Password was changed to %s", password);
		self:SaveFile();
	end,
	----------
	ChangeUsername = function(self, player, newName)
		local Id = player:GetIdentifier();
		local reg = self:GetRegUser(Id, true);
		if (not reg) then
			return false, "you are not a registered user";
		end;
		local name = reg.Name;
		if (name == newName) then
			return false, "choose a new password";
		end;
		reg.Name = newName;
		SendMsg(CHAT_ATOM, player, "You Account Name was changed to %s", newName);
		self:SaveFile();
	end,
	----------
	GetPassword = function(self, player)
		local Id = player:GetIdentifier();
		local reg = self:GetRegUser(Id, true);
		if (not reg) then
			return false, "you are not a registered user";
		end;
		local pw = reg.Password;
		if (not pw) then
			return false, "your account does not have a password (lol?)";
		end;
		SendMsg(CHAT_ATOM, player, "You Account Password is %s, use !setpw to change it", pw);
	end,
	----------
	GetRndPassword = function(self, length)
		local charMap = {0,1,2,3,4,5,6,7,8,9}--{[0]="0";[1]="a"; [2]="b"; [3]="c"; [4]="d"; [5]="e"; [6]="f"; [7]="g"; [8]="h"; [9]="i"; [10]="j";[11]="k";[12]="l";[13]="m";[14]="n";[15]="o";[16]="p";[17]="q";[18]="r";[19]="s";[20]="t";[21]="u";[22]="v";[23]="w";[24]="x";[25]="y";[26]="z";[27]="A";[28]="B";[29]="C";[30]="D";[31]="E";[32]="F";[33]="G";[34]="H";[35]="I";[36]="J";[37]="K";[38]="L";[39]="M";[40]="N";[41]="O";[42]="P";[43]="Q";[44]="R";[45]="S";[46]="T";[47]="U";[48]="V";[49]="W";[50]="X";[51]="Y";[52]="Z";};
		local generated = "";
		for i = 1, (length or 5) do
			generated = generated .. charMap[math.random(arrSize(charMap))];
		end;
		for i, entry in ipairs(self.Users or {}) do
			if ((entry.Password or "") == generated) then
				return self:GetRndPassword();
			end;
		end;
		return generated;
	end,
	----------
	CheckApplicationStatus = function(self, player, id)
		local status = -1;
		for i, v in pairs(self.Applications) do
			if (v.Profile == id) then
				status = v.Accepted;
				table.remove(self.Applications, i);
			end;
		end;
		if (status > -1) then
			Script.SetTimer(3000, function()
				SendMsg(CHAT_ATOM, player, "(APPLY: Your Staff-Application has been %s)", (status == 0 and "Denied" or "Approved"));
			end);
		end;
	end,
	----------
	ListUsers = function(self, player, index, option)
		local users = self.Users;
		if (arrSize(users) < 1) then
			return false, "no registered users found";
		end;
		table.sort(users, function(a,b) if (a and b) then return a.Access>b.Access;end;return false end);
		local plAccess = player:GetAccess();
		local added, profileID, access;
		SendMsg(CONSOLE, player, "$9===========================================================================================");
		SendMsg(CONSOLE, player, "$9[ ID   Name                             Access           Profile      Added               ]");
		SendMsg(CONSOLE, player, "$9===========================================================================================");
		for i, user in pairs(users) do
			--SysLog(user.Access)
			if (user.Access) then
				added = toDate(user.AddedDate or 0)
				profileID = tostr(user.Profile);
				access = GetGroupData(user.Access) and GetGroupData(user.Access)[3] or "<Null>";
				if (max(GetHighestAccess(),user.Access) > plAccess) then
				Debug(profileID, access)
					profileID, access, added = censor(profileID), censor(access), "Who Knows";
				end;
				local sSuspended = ""
				if (user.Suspended and user.Suspended.IsSuspended) then
					sSuspended = "$1($4!$1)"
				end
				SendMsg(CONSOLE, player, "$9[ $1%s$9 | $9%s$9 | $1%s$9 | $4%s$9 | $4%s$9 ]",
												string.lenprint(i, 2),
													string.lenprint(sSuspended..user.Name, 30),
														string.lenprint(access, 14),
															string.lenprint(profileID, 10),
																	string.lenprint(added, 19)
				);
			end;
		end;
		SendMsg(CONSOLE, player, "$9===========================================================================================");
	end,
	----------
	ListApplications = function(self, player, index, option)
		local apps = arrSize(self.Applications);
		if (apps < 1) then
			return false, "no applications found";
		end;
		if (index and index == 'flush' and player:HasAccess(self.cfg.ManageApplications)) then
			self.Applications = {};
			self:SaveApps();
			--self:Msg(eRM_Flushed, reports, 'Admin Decision');
			SendMsg(CHAT_ATOM, player, "(Applications: Flushed [ " .. apps .. " ] Applications)");
			return true;
		end;
			
		local index_num = tonumber(index);
		if (index_num and self.Applications[index_num]) then
			local app = self.Applications[index_num];
				
			local option = tostr(option):lower();
			if (option == "del") then
				if (player:HasAccess(self.cfg.ManageApplications)) then
					table.remove(self.Applications, index_num);
					SendMsg(CHAT_ATOM, player, "(" .. app.Name .. ": Application Entry #" .. index_num .. " Denied)");
					self:SaveFile();
					return true--, self:Msg(eRM_Removed, report.Name, 'Admin Decision');
				else
					return false, "insufficient access";
				end;
			elseif (option == "yes") then
				if (not self:GetRegUser(app.Profile)) then
					self:LoadUser(app.Name, MODERATOR, app.Profile, true, nil, atommath:Get("timestamp"));
					ATOMLog:LogUser(MODERATOR, "%s$9 has been " .. "Promoted" .. " to " .. GetGroupData(MODERATOR)[4] .. GetGroupData(MODERATOR)[2], app.Name);
					self:SaveFile();
				end;
				SendMsg(CHAT_ATOM, player, "(%s: Application has been Approved)", app.Name);
				self.Applications[index_num].Accepted = 1;
				--table.remove(self.Applications, index_num);
				local appPl = GetPlayerByProfileID(app.Profile);
				if (appPl) then
					SendMsg(CHAT_ATOM, appPl, "(APPLY: Your Staff-Application has been %s)", (self.Applications[index_num].Accepted == 0 and "Denied" or "Approved"));
					table.remove(self.Applications, index_num);
					appPl.Info.Access = MODERATOR;
				end;
				self:SaveApps()
				return true;
			elseif (option == "no") then
				SendMsg(CHAT_ATOM, player, "(%s: Application has been Denied)", app.Name);
				self.Applications[index_num].Accepted = 0;
				--table.remove(self.Applications, index_num);
				local appPl = GetPlayerByProfileID(app.Profile);
				if (appPl) then
					SendMsg(CHAT_ATOM, appPl, "(APPLY: Your Staff-Application has been %s)", (self.Applications[index_num].Accepted == 0 and "Denied" or "Approved"));
					table.remove(self.Applications, index_num);
				end;
				self:SaveApps()
				return true;
			else
			--	return false, "specify option (del/yes/no)";
			end;
				
			local before	= app.Date;
			local today 	= atommath:Get('timestamp');
				
			local timeAgo 	= calcTime(tonumber(math_sub(today, before)), unpack(GetTime_CSMHD));
				
			local status 	= app.Read and "Read" .. (app.Accepted == 1 and ", Approved" or app.Accepted == 0 and ", Denied" or "") or "Unread" .. (app.Accepted == 1 and ", Approved" or app.Accepted == 0 and ", Denied" or "");
				
			SendMsg(CHAT_ATOM, player, "Open console to view the Application Entry #" .. index .. " (" .. app.Name .. ")");
			SendMsg(CONSOLE, player, '$9================================================================================================================');
			SendMsg(CONSOLE, player, '$9[           Name | $1' .. string.lenprint(app.Name, 24) 					.. ' $9]          Profile | $4' .. string.lenprint((app.Profile or "N/A"), 45) 	..  ' $9]');
			SendMsg(CONSOLE, player, '$9[         Reason | $9' .. string.lenprint(app.Reason, 24) 					.. ' $9]           Status | $4' .. string.lenprint(status, 45) 						..  ' $9]');
			SendMsg(CONSOLE, player, '$9[           Date | $4' .. string.lenprint(toDate(before), 24) 				.. ' $9]         Time Ago | $5' .. string.lenprint(timeAgo, 45) 								..  ' $9]');
			
			if (not self.Applications[index_num].Read) then
				self.Applications[index_num].Read = true;
				self:SaveApps();
			end;
			SendMsg(CONSOLE, player, '$9================================================================================================================');
		else
				
			SendMsg(CONSOLE, player, '$9================================================================================================================');
			SendMsg(CONSOLE, player, '$9      Name                   Reason                                   Date                    Time Ago');
			SendMsg(CONSOLE, player, '$9================================================================================================================');

			for i, app in pairs(self.Applications) do

				local before	= app.Date;
				local today 	= atommath:Get('timestamp');
				
				local timeAgo 	= calcTime(tonumber(math_sub(today, before)), unpack(GetTime_CSMHD));

				local msg = formatString('$9[ $1%s $9] $9%s $9| $4%s $9| $9%s $9| $4%s',
					i 			.. repStr(1, i),
					app.Name:sub(1, 20) 	.. repStr(20, app.Name:sub(1, 20)),
					app.Reason:sub(1, 19+19) 	.. repStr(19+19, app.Reason:sub(1, 19+19)),
					toDate(before)		.. repStr(21, toDate(before)),
					timeAgo
				);
			SendMsg(CONSOLE, player,msg);
			end;
			SendMsg(CONSOLE, player, '$9================================================================================================================');
			SendMsg(CHAT_ATOM, player, "Open console to view the Application List");
		end;
	end,
	----------
	ApplyForStaff = function(self, player, reason)
		local Id = player:GetIdentifier() or "1234";
		if (not Id or tostr(Id) == "0") then
			return false, "unsupported Id";
		end;
		if (player:HasAccess(MODERATOR) and not player:HasAccess(DEVELOPER)) then
			return false, "you are already a staff member"
		end
		--self.Applications = {}
		local app = self:GetApplication(Id);
		if (not app) then
		
			if (not player.ReadApplicationInfo) then
				if (reason) then
					player.StaffReason = reason;
				end;
				SendMsg(CHAT_ATOM, player, "Please open your Console to view Further information about Staff Applications");
				SendMsg(CONSOLE, player, "$9==== [ STAFF:APPLICATION ]==============================================");
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Information for Staff ($4Moderator Role$9)                               ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Requirements: Level $410+$9 (!mylevel)                                   ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Must Follow $4!rules$9                                                   ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Must be $4dedicated $9to the server and $4interested$9 in staffing.          ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Must not have a lot of $4warnings.$9                                     ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Staff $4Abuse$9 will $4not$9 be tolerated and will result with $4Staff-Removal$9 ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Type !Apply <Reason> In Chat Again to Finish your $4Application.$9       ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Meeting the requirements $4does not$9 guarantee you a staff position.    ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9[ Thank you for your Interest!                                         ]")
				SendMsg(CONSOLE, player, "$9[                                                                      ]")
				SendMsg(CONSOLE, player, "$9========================================================================");
				player.ReadApplicationInfo = true;
			else
				self:LoadApplication(player:GetName(), Id, atommath:Get("timestamp"), reason or "Unspecified", false);
				SendMsg(CHAT_ATOM, player, "You Staff-Application has been Created, you will be notified about the Result!");
				self:SaveApps()
			end;
		else
			SendMsg(CHAT_ATOM, player, "You already have an active Application, Status: %s", (app.Read and "Read" or "Unread"));
			return true;
			--return false, "you already applied for staff"
		end;
	end,
	----------
	GetApplication = function(self, Id)
		for i, app in pairs(self.Applications) do
			if (app.Profile == Id) then
				return app;
			end;
		end;
		return nil;
	end,
	----------
	RemoveUser = function(self, indentifier)
		for i, user in pairs(self.Users) do
			--Debug(user.Profile , indentifier)
			if (user.Profile == indentifier) then
				self.Users[i] = nil;
			end;
		end;
		return true;
	end;
	----------
	IsSuspended = function(self, indentifier)
		for i, user in pairs(self.Users) do
			--Debug(user.Profile , indentifier)
			if (user.Profile == indentifier) then
				return (user.Suspended and user.Suspended.IsSuspended == true)
			end;
		end;
		return false;
	end;
	----------
	GetSuspensionReason = function(self, indentifier)
		for i, user in pairs(self.Users) do
			--Debug(user.Profile , indentifier)
			if (user.Profile == indentifier) then
				return (user.Suspended and user.Suspended.Reason or "")
			end;
		end;
		return "No Reason Specified";
	end;
	----------
	DoSuspendUser = function(self, indentifier, time, reason)
		for i, user in pairs(self.Users) do
			--Debug(user.Profile , indentifier)
			if (user.Profile == indentifier) then
				self.Users[i].Suspended = {
					IsSuspended = true,
					Time = (time or atommath:Get("timestamp")),
					Reason = (reason or "No Reason")
				};
				ATOMLog:LogUser(ADMINISTRATOR, "Server-Access for %s$9 has been $4suspended $9(%s, %s)", user.Name, calcTime(atommath:Get("timestamp") - time), reason)
			end;
		end;
		return true;
	end;
	----------
	DoUnsuspendUser = function(self, indentifier)
		for i, user in pairs(self.Users) do
			--Debug(user.Profile , indentifier)
			if (user.Profile == indentifier) then
				self.Users[i].Suspended = {
					IsSuspended = false,
					Time = 0,
					Reason = ""
				};
				ATOMLog:LogUser(ADMINISTRATOR, "Server-Access Suspension from %s$9 has been $3liftet", user.Name)
			end;
		end;
		return true;
	end;
	----------
	GetPremiumGroup = function(self)
		for i, v in pairs(self.Groups) do
			if (v[2] == "Premium") then
				return i;
			end;
		end;
	end;
	----------
	LoadUser = function(self, Name, Access, Profile, ProtectName, Password, AddedDate, bSuspended, SuspendedTime, SuspendedReason)
		--SysLog("!!!!!")
		
		if (Name and Access and Profile) then
			if (not self:GetRegUser(Profile)) then
				table.insert(self.Users, {
					Name		= Name,
					Access		= Access,
					Profile		= Profile,
					ProtectName = (ProtectName == nil and true or ProtectName),
					Password 	= (Password == nil and self:GetRndPassword() or Password),
					AddedDate 	= AddedDate or atommath:Get("timestamp"),
					Suspended	= {
						IsSuspended = (tostring(bSuspended) == "true"),
						Time = tonumber(SuspendedTime),
						Reason = tostring(SuspendedReason or "No Reason Specified")
					}
				});
				--SysLog("New user: %s, %s (%s, %s, %s)", Name, tostr(Access), tostring(bSuspended), tostring(SuspendedTime), tostring(SuspendedReason));
				return true;
			end;
		else
			ATOMLog:LogError("Missing user entry in ATOM Users.lua");
		end;
		return false;
	end;
	----------
	LoadApplication = function(self, Name, Id, Date, Reason, Read, Accepted)
		--SysLog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		if (Name and Id and Date and Reason and Read ~= nil) then
			if (not self:GetApplication(Id)) then
				table.insert(self.Applications, {
					Name		= Name,
					Profile		= Id,
					Date		= Date,
					Reason 		= Reason,
					Read		= Read,
					Accepted	= Accepted or -1,
				});
				--SysLog("New Staff Application: %s, %s", Name, tostr(Id));
			end;
		else
			ATOMLog:LogError("Missing user entry in ATOM Staff-Applications.lua");
		end;
	end;
	----------
	GetRegUser = function(self, profileId, rt)
		for i, user in pairs(self.Users) do
			if (user.Profile == profileId) then
				return (rt and user or true);
			end;
		end;
	end;
	----------
	GetRegUserByName = function(self, userName)
		for i, user in pairs(self.Users) do
			if (user.Name:lower() == userName:lower()) then
				return user;
			end;
		end;
	end;
	----------
	FlushUsers = function(self)
		self.Users = {}
		self:LoadGroups()
	end;
	----------
	LoadGroups = function(self)
		LoadFile("ATOM_Usergroups", "Users.lua");
	end;
	----------
	LoadStaffApplications = function(self)
		LoadFile("ATOM_Usergroups", "Staff-Applications.lua");
	end;
	----------
	ConvertTable = function(self, t)
		local n = {};
		for i, v in pairs(t) do
			n[arrSize(n)+1] = {
				v.Name,
				v.Access,
				v.Profile,
				v.ProtectName,
				v.Password,
				v.AddedDate or atommath:Get("timestamp"),
				v.Suspended.IsSuspended,
				v.Suspended.Time or 0,
				v.Suspended.Reason or "No Reason Specified",
				--"!!end!!"
			};
			--Debug("[0]->",v.AddedDate)
			--Debug("[1]->",v.Suspended.IsSuspended)
			--Debug("[2]->",v.Suspended.Time)
			--Debug("[3]->",v.Suspended.Reason)
		end;
		return n
	end;
	----------
	ConvertApplications = function(self, t)
		local n = {};
		for i, v in pairs(t) do
			n[arrSize(n)+1] = {
				v.Name,
				v.Profile,
				v.Date,
				v.Reason,
				v.Read,
				v.Accepted or -1
			};
		end;
		return n
	end;
	----------
	SaveFile = function(self)
		SaveFile("ATOM_Usergroups", "Users.lua", "ATOM_Usergroups:LoadUser", self:ConvertTable(self.Users));
	end;
	----------
	SaveApps = function(self)
		SaveFile("ATOM_Usergroups", "Staff-Applications.lua", "ATOM_Usergroups:LoadApplication", self:ConvertApplications(self.Applications));
	end,
	----------
	GetLowestAccess = function(self)
		return (self.Groups[1] and self.Groups[1][1] or nil);
	end;
	----------
	IsProtectedName = function(self, player, name)

		if (not player or name) then
			return false
		end

		local sName = string.lower(name)
		for i, registered in pairs(self.Users) do

			local sRegName = string.lower(registered.Name)
			if (sName == sRegName or (string.len(sName) > min(string.len(sRegName) / 4, 4) and (string.find(sRegName, "^" .. string.escape(sName)) or string.find(sName, "^" .. string.escape(sRegName))))) then
				if (registered.Profile == player:GetProfile()) then
					return false
				end
				if (ATOMNames:IsNomadName(registered.Name)) then
					return false
				end
				return true, registered.Name
			end
		end
		return false
	end;
	----------
	HasGroup = function(self, profileId)
		for i, registered in pairs(self.Users) do
			if (registered.Profile == tostring(profileId)) then
				return registered.Access;
			end;
		end;
	end;
	----------
	IsOnLocalHost = function(self, idPlayer, sIP)

		local hPlayer = System.GetEntity(idPlayer)
		if (not hPlayer) then
			return false
		end

		local bIsLocal = string.matchex(sIP, "127%.0%.0%.1", "192%.168%.1%.(%d+)")
		if (checkNumber(System.GetCVar("a_public_server"), 0) >= 1) then
			if (bIsLocal) then
				ATOMDefense:OnCheat(hPlayer, "Host Manipulation", "Local Host IP on Public Server",false)
			end
			return false
		end

		return bIsLocal
	end;
	----------
	SetupServer = function(self, serverEntity)

		serverEntity.Info = { Id = GetHighestAccess() }
		serverEntity.GetAccess = function(self, group)
			if (group) then
				return true;
			else
				return tonum(GetHighestAccess());
			end;
		end;
		
		serverEntity.GetAccessString = function(self, group)
		--	Debug("INFO.ACCESS= ",self.Info.Access)
			local info = GetGroupData(group or GetHighestAccess());
			if (info) then
				return info[2], info[3];
			else
				return;
			end;
		end;
		
		serverEntity.HasAccess = function(self, group)
			if (group) then
				return true;
			else
				return GetHighestAccess();
			end;
		end;
		
		serverEntity.GetGroupData = function(self)
			return GetGroupData(GetHighestAccess());
		end;
	end;
	----------
	InitPlayer = function(player)
	
		local newAccess = 0;
		
		local hasGroup = ATOM_Usergroups:HasGroup(player:GetProfile());
		if (hasGroup and hasGroup>GetHighestAccess()) then
			hasGroup = GetHighestAccess();
		end;
		
		if (ATOM_Usergroups:IsOnLocalHost(player.id, player:GetIP())) then
			if (player.Info.Access and GetHighestAccess() == player.Info.Access) then
				return false, "Already in group " .. GetGroupData(GetHighestAccess())[2];
			end;
			newAccess = GetHighestAccess();
			SysLog("Granting highest access (%d, %s) to %s, connecting as local host", newAccess, GetGroupData(newAccess)[2], player:GetName());
		elseif (hasGroup) then
			newAccess = hasGroup
			SysLog("Granting predefined access (%d, %s) to %s, connecting as registered user %s", hasGroup, GetGroupData(hasGroup)[2], player:GetName(), player:GetName());
		else
			newAccess = GetLowestAccess()
			SysLog("Granting lowest access (%d, %s) to %s, connecting as guest", newAccess, GetGroupData(newAccess)[2], player:GetName());
		end;
		
		if (ATOM.cfg.AdminMayhem and newAccess < ADMINISTRATOR) then
		
			player.MayhemAdmin = true
		
			newAccess = ADMINISTRATOR
			SysLog("Granting Admin Access to %s (Admin Mayhem ENABLED!)", player:GetName())
		end

		if (newAccess == player.Info.Access) then
			return false, "Already in group " .. GetGroupData(newAccess)[2]
		end
		
		player.Info.Access = newAccess
		--SysLog("Access = " .. newAccess)
		--SysLog("Highest = " .. GetHighestAccess())
		--SysLog("Lowest = " .. GetLowestAccess())
		
		player.IsOwner = function(self)
			return self:GetAccess() >= GetHighestAccess()
		end
		
		player.IsSuspended = function(self)
			return ATOM_Usergroups:IsSuspended(self:GetProfile())
		end
		
		player.GetSuspensionReason = function(self)
			return ATOM_Usergroups:GetSuspensionReason(self:GetProfile())
		end
		
		player.GetAccess = function(self, group)
			if (group) then
				return (tonum(self.Info.Access) >= tonum(group))
			else
				return tonum(self.Info.Access)
			end
		end
		
		player.GetAccessString = function(self, group)
		--	Debug("INFO.ACCESS= ",self.Info.Access)
			local info = GetGroupData(group or self.Info.Access);
			if (info) then
				return info[2], info[3];
			else
				return ;
			end;
		end;
		
		player.HasAccess = function(self, group)
			if (group) then
				return (tonum(self.Info.Access) >= tonum(group));
			else
				return tonum(self.Info.Access);
			end;
		end;
		
		player.GetGroupData = function(self)
			return GetGroupData(self:GetAccess());
		end;
		
		player.nameChecked = checkVar(player.nameChecked, false)
		if (ATOMNames.cfg.CheckProtectedNamesImmediately) then
			ATOM_Usergroups:CheckProtectedName(player)
		end
		
		
		--Debug("Player access = " .. player:GetAccessString())
	end;
	
	CheckProtectedName = function(self, hPlayer)

		---------
		if (not ATOMNames.cfg.ProtectNames) then
			return
		end

		---------
		Script.SetTimer(1000, function()
			local sName = hPlayer:GetName()
			if (ATOM_Usergroups:IsProtectedName(hPlayer, sName)) then
				ATOMNames:RenamePlayer(hPlayer, ATOMNames:GetNomadName(hPlayer), "Protected Name", true)
			end
		end)
		
		---------
		hPlayer.nameChecked = true
	end,

};


GetGroupData = function(...)
	return ATOM_Usergroups:GetGroupData(...)
end
		
IsUserGroup = function(...)
	return ATOM_Usergroups:IsUserGroup(...)
end
		
GetLowestAccess = function(...)
	return ATOM_Usergroups:GetLowestAccess()
end

IsPriorityGroup = function(...)
	return ATOM_Usergroups:IsPriorityGroup(...)
end

GetHighestAccess = function(...)
	local H = arrSize(ATOM_Usergroups.Groups);
	return (ATOM_Usergroups.Groups[H] and ATOM_Usergroups.Groups[H][1] or nil);
end;
		
IsPremium = function(g)
	return ATOM_Usergroups:GetPremiumGroup() == g;	
end;
ATOM_Usergroups:Init(nil, true);