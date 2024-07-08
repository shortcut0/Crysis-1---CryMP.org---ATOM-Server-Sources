ATOMCommands = {
	cfg = {
		CommandPrefix = { "!", "/" };
		PrefixCorrection = { "1" };
	};

	-------------
	DefaultCommandProperties = {
		-- unspecific
		NoLogging 	 = false,
		Maps		 = "(.*)", -- all maps
		Timer		 = 0,
		
		-- player specific
		Alive		 = false,
		Level 		 = 0,
		
		-- ps specific
		Cost		 = 0, -- prestige
		
		-- object
		Self 	 	 = nil
	};

	-------------
	Commands = ATOMCommands ~= nil and ATOMCommands.Commands or {};

	-------------
	toAddCommands = {};

	-------------
	ArgumentInfo = {};

	-------------
	CommandBans = {};

	-------------
	Init = function(self)
	
		--self.Commands = {};
		
		-------
		eFR_ManyMatches 	= 0
		eFR_NoMatch			= 1
		eFR_Premium			= 2
		eFR_Access			= 3
		eFR_Disabled		= 4
		eFR_Broken			= 5
		eFR_Failed			= 6
		eFR_Success			= 7
		eFR_NoFeedback		= 8
		eFR_FailedBLE		= 9
		eFR_CmdBroke		= 10
		eFR_Validating		= 11 -- used by DLL
		eFR_Validated		= 12
		eFR_NoConsole		= 13
		eFR_SOS				= 14
		eFR_FailedNil		= 15
		eFR_DisabledYou		= 16
		eFR_DisabledYouAll	= 17
		eFR_Banned			= 18
		eFR_Suspended		= 19
		eFR_LackAuth		= 20
		eFR_FeatureMissing	= 21

		-------
		NewCommand = function(...)
			--for i, command in pairs(self.Commands) do
			--	Debug(i)
			--end;
			return self:Add(...);
		end;
		
		-------
		if (type(self.cfg.CommandPrefix) == "table" and arrSize(self.cfg.CommandPrefix) < 1) then
			self.cfg.CommandPrefix = "!" end
		
		-------
		self:AddArgumentInfo('player', 	"Name of the player, can be patrial value");
		self:AddArgumentInfo('name', 	"Name of the player, can be patrial value");
		self:AddArgumentInfo('value', 	"A Number value");
		self:AddArgumentInfo('reason', 	"A Brief explanation for your Action");
		self:AddArgumentInfo('time', 	"The Amount of time for the action, example: 2min30s");
		self:AddArgumentInfo('BanName', "The Name of the ban");

		-------
		self:LoadBannedCommands()
	end;

	-------------
	LoadBannedCommands = function(self)
		LoadFile("ATOMCommands", "CommandBans.lua")
	end,

	-------------
	SaveCommandBans = function(self)
	
		-- self.CommandBans = {
			-- ["6666666"] = {
				-- ["goto"] = {
					-- Date = atommath:Get("timestamp"),
					-- Reason = "stop fucking up my server",
					-- Name = "Mariza",
					-- ID = "1008858",
				-- }
			-- }
		-- }
	
		local aData = {}
		for id, aBans in pairs(self.CommandBans) do
			for sCommand, aBan in pairs(aBans) do
				aData[table.count(aData) + 1] = {
					id,
					sCommand,
					checkVar(aBan.Date),
					checkVar(aBan.Reason),
					checkVar(aBan.Name),
					checkVar(aBan.ID),
				}
			end
		end
		
		SaveFile("ATOMCommands", "CommandBans.lua", "ATOMCommands:LoadBan", aData)
	end,

	-------------
	BanCommand = function(self, hPlayer, sCommand, idTarget, sReason)
		
		--------
		local iTimestamp = atommath:Get("timestamp")
		local sBannedBy  = hPlayer:GetName()
		local iBannedBy  = hPlayer:GetProfile()
		local sReason 	 = checkVar(sReason, "Admin Decision")
		local sCommand 	 = string.lower(sCommand)
		
		--------
		local sTargetID = idTarget
		if (isArray(sTargetID)) then
			sTargetID = sTargetID:GetProfile() 
			if (sTargetID == "0") then
				return false, "target has no profile" end end
			
		--------
		local aCommandBan = self:GetBan(sTargetID, sCommand)
		if (aCommandBan) then
			return false, string.format("target already banned (%s)", aCommandBan.Reason) end
			
		--------
		ATOMLog:LogBan("Command %s Banned for %s$9 ($4%s$9)", string.upper(sCommand), sTargetID, sReason)
		self:AddBan(sTargetID, sCommand, iTimestamp, sReason, sBannedBy, iBannedBy)
		
	end,

	-------------
	UnbanCommand = function(self, hPlayer, sCommand, idTarget)
		
		--------
		local sReason	 = "Admin Decision"
		local sCommand 	 = string.lower(sCommand)
		
		--------
		local sTargetID = idTarget
		if (isArray(sTargetID)) then
			sTargetID = sTargetID:GetProfile() 
			if (sTargetID == "0") then
				return false, "target has no profile" end end
			
		--------
		local aCommandBan = self:GetBan(sTargetID, sCommand)
		if (not isArray(aCommandBan)) then
			return false, "command not banned for target" end
			
		--------
		local iAccess = checkNumber(aCommandBan.ID, 0)
		if (iAccess >= hPlayer:GetAccess()) then
			return false, "Insufficient Access" end
			
		--------
		ATOMLog:LogBan("Removed Ban for Command %s from %s$9 ($4%s$9)", string.upper(sCommand), sTargetID, sReason)
		self:DeleteBan(sTargetID, sCommand)
		
		--------
		return true
	end,

	-------------
	ListBans = function(self, hPlayer, iIndex, idTarget)
		
		--------
		local aBans = self.CommandBans
		local iBans = table.count(aBans)
		if (iBans == 0) then
			return false, "no bans found" end
		
		--------
		local sFilter = checkVar(idTarget, nil)
		if (sFilter) then
			if (table.empty(self:GetBansByFilter(idTarget))) then
				return false, "no bans matching filter " .. sFilter .. " found" end end
		
		--------
		local iMaxLen = 52
		local iTimeStamp = atommath:Get("timestamp")
		local iBan = 0
		
		--------
		local aIndexedBan = table.index(aBans, iIndex)
		if (isNull(aIndexedBan)) then
			SendMsg(CONSOLE, hPlayer, "")
			SendMsg(CONSOLE, hPlayer, "$9==============================================================================")
			SendMsg(CONSOLE, hPlayer, "$9   #  ID      Bans  Last Ban              Time Ago")
			SendMsg(CONSOLE, hPlayer, "$9==============================================================================")
			for sID, aCmdBans in pairs(aBans) do
				if (table.count(aCmdBans) > 0) then
					if (isNull(sFilter) or (string.match(sID, sFilter))) then
						local iLastBan = checkNumber(table.getmax(aCmdBans, "Date"), 0)
						local sLastBan = string.rspace(toDate(iLastBan), 19)
						local sLastAgo = string.rspace(SimpleCalcTime(iTimeStamp - iLastBan), 20)
						iBan = iBan + 1
						SendMsg(CONSOLE, hPlayer, "$9[$1%s$9] $4%s $9%s $9($1%s $9: $5%s$9) %s]",
							string.lspace(iBan, 3),
							string.rspace(sID, 7),
							string.rspace(table.count(aCmdBans), 4),
							sLastBan,
							sLastAgo,
							string.repeats(" ", iMaxLen - (string.len(sLastBan) + string.len(sLastAgo)))
						)
					end
				end
			end
			SendMsg(CONSOLE, hPlayer, "$9==============================================================================")
			SendMsg(CONSOLE, hPlayer, "")
			SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the ( %d ) Command-Bans", iBans)
		else
			SendMsg(CONSOLE, hPlayer, "")
			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")
			SendMsg(CONSOLE, hPlayer, "$9   #  Command         Admin           ID      Reason                                         Time Ago           ")
			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")
			for sCmd, aCmdBan in pairs(aIndexedBan) do
				if (isNull(sFilter) or (string.match(sCmd, sFilter))) then
					local iLastBan = tonumber(aCmdBan.Date)
					local sLastAgo = string.rspace(SimpleCalcTime(iTimeStamp - iLastBan), 17)
					iBan = iBan + 1
					SendMsg(CONSOLE, hPlayer, "$9[$1%s$9] $5%s $1%s $4%s $4%s $5%s $9]",
						string.lspace(iBan, 3),
						string.rspace(sCmd, 15),
						string.rspace(aCmdBan.Name, 15),
						string.rspace(aCmdBan.ID, 7),
						string.rspace(aCmdBan.Reason, 46),
						sLastAgo
					)
				end
			end
			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")
			SendMsg(CONSOLE, hPlayer, "")
			SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the ( %d ) bans of ( %s )", table.count(aIndexedBan), table.indexname(aBans, iIndex))
		end
		--------
		
		--------
		return true
	end,

	-------------
	DeleteBan = function(self, idTarget, sCommand)
		
		--------
		self.CommandBans = checkVar(self.CommandBans, {})
		self.CommandBans[idTarget] = checkVar(self.CommandBans[idTarget], {})
		
		--------
		if (self.CommandBans[idTarget][sCommand]) then
			self.CommandBans[idTarget][sCommand] = nil
			if (table.empty(self.CommandBans[idTarget])) then
				self.CommandBans[idTarget] = nil end
				
			---------
			SysLog("Removed command ban for %s for command %s", idTarget, sCommand)
			self:SaveCommandBans()
		end
	end,

	-------------
	AddBan = function(self, idTarget, sCommand, iTimestamp, sReason, sBannedBy, iBannedBy)
		
		--------
		self.CommandBans = checkVar(self.CommandBans, {})
		self.CommandBans[idTarget] = checkVar(self.CommandBans[idTarget], {})
		
		--------
		self.CommandBans[idTarget][sCommand] = {
			Date = iTimestamp,
			Name = sBannedBy,
			Reason = sReason,
			ID = iBannedBy
		}
		
		--------
		self:SaveCommandBans()
		
		--------
		SysLog("Added command ban for %s for command %s (%s)", idTarget, sCommand, sReason)
	end,
	

	-------------
	LoadBan = function(self, idTarget, sCommand, sDate, sReason, sBannedBy, iBannedBy)
		self:AddBan(idTarget, sCommand, sDate, sReason, sBannedBy, iBannedBy)
	end,
	

	-------------
	GetBan = function(self, idTarget, sCommand)
		 
		--------
		self.CommandBans = checkVar(self.CommandBans, {})
		
		--------
		if (isNull(self.CommandBans[idTarget])) then
			return end
		
		--------
		local sCommand = string.lower(sCommand)
		return (self.CommandBans[idTarget][sCommand])
		
	end,
	

	-------------
	GetBansByFilter = function(self, sFilter)
		
		--------
		local aBans = self.CommandBans
		local iBans = table.count(aBans)
		if (iBans == 0) then
			return {} end
		
		--------
		local aFilteredBans = {}
		for sID, aCmdBans in pairs(aBans) do
			if (string.match(sID, sFilter)) then
				aFilteredBans[sID] = aCmdBans end
		end
		
		--------
		return aFilteredBans
	end,
	

	-------------
	AddArgumentInfo = function(self, arg, info)
		if (self:GetArgDescription(arg, true)) then
			ATOMLog:LogError("Attempt to add Argument Info " .. arg .. " twice");
		else
			self.ArgumentInfo[arg:lower()] = info;
		end;
	end;
	

	-------------
	RegisterCommands = function(self)
		for i, command in pairs(self.toAddCommands) do
			self:InsertCommand(command[1], command[2], command[3], command[4], command[5], command[6], command[7]);
		end;
	end;

	-------------
	Add = function(self, properties)
		if (not properties) then
			return doError("Attempted to add new command without properties");
		end;
		local props  = properties;
		local name	 = props.Name;
		local access = props.Access;
		local desc	 = tostr(props.Description or "No Description");
		local args	 = props.Arguments or props.Args;
		local func	 = props.func;
		local prop	 = props.Properties;
		local con	 = props.Console;
		
		if (not self:ValidateArguments(name, access, args, func, prop, desc)) then
			return false;
		end;
		
		table.insert(self.toAddCommands, {
			name,
			access,
			args,
			func,
			prop,
			desc,
			con
		});

		--self:InsertCommand(name, access, args, func, prop, desc, con)
	end;

	-------------
	GetCommand = function(self, commandName)
		if (not commandName) then
		--	Debug("No Name")
			return;
		end;
		--Debug("Yes Name",commandName)
		return self.Commands[commandName:lower()];
	end;

	-------------
	InsertCommand = function(self, name, access, args, func, prop, desc, console)
		
		local name = tostr(name):lower();
		if (self:GetCommand(name)) then
			return false, doError("Attempt to add command %s twice", name);
		else
			self.Commands[name] = {
				name,
				access,
				args,
				func,
				prop,
				desc,
				access
			};
			if (prop and prop.Self and type(prop.Self) ~= "string") then
				ATOMLog:LogWarning("Property '%s' in Command %s is not a string, this is a performance issue", "Self", name);
			end;
			if (DISABLED_COMMANDS and DISABLED_COMMANDS[name]) then
				self.Commands[name].isDisabled = DISABLED_COMMANDS[name];
			end;
			if (console) then
				local luaCode;
				if (args and arrSize(args) > 0) then
					luaCode = [[ATOMCommands.SERVER_COMMAND = "]]..name..[[";ATOMCommands:ConsoleCommand(%%)]];
				else
					luaCode = [[ATOMCommands.SERVER_COMMAND = "]]..name..[[";ATOMCommands:ConsoleCommand()]];
				end;
				System.AddCCommand("a_" .. name, luaCode, desc);
			end;
		end;
		return true;
	end;

	-------------
	LogLoadedCommands = function(self)
		local commands = arrSize(self.Commands);
		--local files	= arrSize(ATOM.loadedFiles.Commands);--(arrSize(ATOM.modCommands) or 0) + (arrSize(ATOM.serverCommands) or 0)
		
		local files = 0;
		for i, v in pairs(ATOM.loadedFiles.Commands or{})do
			if (v[2]) then
				files = files + 1;
			end;
		end;
		
		ATOMLog:LogLoad("Commands", "Successfully Loaded %d Commands from %d files", commands, files);
	end;

	-------------
	ValidateArguments = function(self, name, access, args, func, prop, desc, console)
		if (not name) then
			return false, doError("No name specified to NewCommand()");
		end;
		name = cleanString(name, "([%%%-%.%$(%d+)]*)");
		if (not name) then
			return false, doError("Invalid name specified to NewCommand(\"" .. name .. "\")");
		end;
		if (not access) then
			return false, doError("No Access specified to NewCommand(\"" .. name .. "\")");
		end;
		if (not GetGroupData(access)) then
			return false, doError("Invalid Access specified to NewCommand(\"" .. name .. "\")");
		end;
		args = totable(args);
		if (not func) then
			return false, doError("No Function specified to NewCommand(\"" .. name .. "\")");
		end;
		prop = totable(prop);
		desc = tostr(desc, "No Description");
		return true;
	end;

	-------------
	IsCommand = function(self, msgType, sender, receiver, message)--, isServer)
		--if (isServer) then
		--	local sender, receiver = ATOM.Server, ATOM.Server;
		--end;
		
	-- 	Debug("Chat message LOL")
		
		local sender, receiver = GetEnt(sender), GetEnt(receiver);
		if (not sender or (not sender.isPlayer and not sender.isServer)) then
			--Debug("sender=",sender,"isServer=",(sender and sender.isServer))
			return true;
		end;
		
		local fromCon = msgType == 0 and sender.id == receiver.id;
		
		--Debug(message)
		local prefixes = self.cfg.CommandPrefix;
		local corrections = self.cfg.PrefixCorrection;
		local isCommand = false;
		local prefixLen = 0;
		local newMsg = message;
		
		if (type(corrections) == "table") then
			for i, correction in pairs(corrections) do
				prefixLen = string.len(i);
				if (newMsg:sub(1, prefixLen):lower() == i:lower()) then
				--	Debug("newMsg", correction..newMsg:sub(prefixLen+1))
					newMsg = correction .. newMsg:sub(prefixLen+1)
				end;
			end;
		else
			prefixLen = string.len(corrections);
			if (newMsg:sub(1, 1+prefixLen):lower() == corrections:lower()) then
				newMsg = corrections .. newMsg:sub(prefixLen+1)
			end;
		end;
		
		if (type(prefixes) == "table") then
			for i, prefix in pairs(prefixes) do
				prefixLen = string.len(prefix);
				usedPreFix = prefix;
				if (newMsg:sub(1, prefixLen):lower() == prefix:lower()) then
					isCommand = true;
					break;
				end;
			end;
		else
			prefixLen = string.len(prefixes);
			if (newMsg:sub(1, prefixLen):lower() == prefixes:lower()) then
				isCommand = true;
				usedPreFix = prefixes;
			end;
		end;

		if (isCommand) then
			if (not self:OnCommand(sender, newMsg, prefixLen, usedPreFix, fromCon)) then
				isCommand = false;
			else
			end;
		end;
		return not isCommand;
	end;

	-------------
	ConsoleCommand = function(self, ...)
		
		return self:ProcessCommand(ATOM.Server, self.SERVER_COMMAND, false, ...);
	end;

	-------------
	OnCommand = function(self, player, message, prefixLen, prefix, fromCon)
	
		if (not player or (not player.isPlayer and not player.isServer)) then
			return false end
		
		local commandName = string.match(message, "^" .. prefix .. "(%w+).*");
		
		if (not commandName) then
			return false end
		
		
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "--------------------------")
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "User: %s (Access: %s)", (player:GetName()), (player:GetAccessString()))
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   -> Message: %s", (message))
		
		
		local oldMsg = message
		
		--if (not noAccess) then
			local args = {};
			message = string.gsub(message, "^" .. prefix .. "%w+%s*", "", 1);
			for word in string.gmatch(message, "[^%s]+") do -- split the chat message into words
				table.insert(args, word);
			end;
		--end;
		
		local playerAccess = player:GetAccess();
		
		local command = self:GetCommand(commandName);
		if (command) then
		--	Debug("Real: ", command[1])
			SysLog("ATOM : (Command) : Got command !" .. (command[1]) .. " from message " .. oldMsg .. " | Arguments: " .. table.concat(args, ", "))
			ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   -> Command: %s", (command[1]), oldMsg)
			return true, self:ProcessCommand(player, command[1], fromCon, unpack(args));
		else
			local status, guessed = self:GetCommandByGuess(commandName, playerAccess);
			if (status == 1 or status == 2) then
			--	Debug("Guessed: ", guessed[1])
				SysLog("ATOM : (Command) : Got command !" .. ( guessed[1]) .. " from message " .. oldMsg .. " | Arguments: " .. table.concat(args, ", "))
			ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   -> Command: %s", (guessed[1]), oldMsg)
				return true, self:ProcessCommand(player, guessed[1], fromCon, unpack(args));
			elseif (status == 3) then
				self:ListMatches(player, guessed);
				
				ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   -> Command: %d Matches", arrSize(guessed))
				return true, self:Msg(player, eFR_ManyMatches, commandName, arrSize(guessed));
			end;
		end;
		
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   -> Command: %s", "Not Found")
		self:Msg(player, eFR_NoMatch, commandName);
		return true;
		
	end;

	-------------
	GetCommandByGuess = function(self, commandName, playerAccess)
		local exists = self:GetCommand(commandName);
		if (exists) then
			return 1, exists;
		end;
		--Debug("Guess: " , commandName)
		local commandGuesses = self:GuessCommand(commandName, playerAccess);
		if (commandGuesses and arrSize(commandGuesses) == 1) then
			return 2, self:GetCommand(commandGuesses[1]); --true, self:ProcessCommand(player, commandGuesses[1], args);
		elseif (arrSize(commandGuesses) > 1) then
			return 3, commandGuesses;
		end;
		return nil;
	end;

	-------------
	ListMatches = function(self, player, matches)
		table.sort(matches,function(a,b)
			return self:GetCommand(a)[2]>self:GetCommand(b)[2]
		end);
		SendMsg(CONSOLE, player, "$9"  .. space(112, "="));
		SendMsg(CONSOLE, player, "$9        NAME                ACCESS          DESCRIPTION");
		SendMsg(CONSOLE, player, "$9"  .. space(112, "="));
		local access, accessColor, accessName, desc, cmd;
		for i, match in pairs(matches) do
		cmd = self:GetCommand(match);
		access = GetGroupData(cmd[2]);
		accessName = access[2];
		accessColor = access[4];
		desc = (cmd[6] or "No Description");
		SendMsg(CONSOLE, player, "$9[ $1" .. i .. repStr(2, i) .. " $9] $1!$9" .. cmd[1]:upper() .. repStr(19, cmd[1]) .. " $9" .. accessColor .. accessName .. repStr(15, accessName) .. " $9" .. desc .. repStr(66, desc) .. " $9]");
		end;
		SendMsg(CONSOLE, player, "$9"  .. space(112, "="));
	end;

	-------------
	GetMapName = function(self, str)
		if (str:match("^multiplayer/ps/(.*)")) then
			return "PS Maps";
		elseif (str:match("^multiplayer/ia/(.*)")) then
			return "IA Maps";
		end;
		return makeCapital(cleanString(str:lower(), "multiplayer/([(ps)(ia)]*)/")) .. " Map";
	end;

	-------------
	CanUseDisabledCommand = function(self, disabledData, access)
		if (access == GetHighestAccess()) then
			return true;
		end;
		if (access == SUPERADMIN and disabledData.access < access) then
			return true;
		end;
		return false;
	end;

	-------------
	DisableCommand = function(self, player, commandName)
		DISABLED_COMMANDS = DISABLED_COMMANDS or {};
		local status, command = self:GetCommandByGuess(commandName, player:GetAccess());
		if (status == 1 or status == 2) then
			if (command[2] > player:GetAccess()) then
				return false, "invalid command";
			end;
			if (command.isDisabled) then
				DISABLED_COMMANDS[command[1]] = nil;
				command.isDisabled = nil;
				SendMsg(CHAT_ATOM, player, "(%s: Enabled)", command[1]:upper());
				SysLog("(Chat-Commands) : Command %s was enabled by %s (%s Cmd)", command[1], player:GetName(), GetGroupData(command[2])[2]);
			else
				command.isDisabled = {
					player = player.id,
					access = player:GetAccess()
				};
				DISABLED_COMMANDS[command[1]] = command.isDisabled;
				SysLog("(Chat-Commands) : Command %s was disabled by %s (%s Cmd)", command[1], player:GetName(), GetGroupData(command[2])[2]);
				SendMsg(CHAT_ATOM, player, "(%s: Disabled)", command[1]:upper());
			end;
			return true;
		elseif (status == 3) then
			self:ListMatches(player, command);
			return true, self:Msg(player, eFR_ManyMatches, commandName, arrSize(command));
		end;
		return false, "invalid command";
	end;

	-------------
	GetMemberName = function(self, access)
		
	end;

	-------------
	SortCommands = function(self, t, access)
		local newCommands = {};
		for i, command in pairs(t) do
			newCommands[command[2]] = newCommands[command[2]] or {};
			if (command[6].Hidden) then
				if (access > MODERATOR) then
					table.insert(newCommands[command[2]], command);
				end;
			else
				table.insert(newCommands[command[2]], command);
			end;
		end;
		local newNewCommands = {};
		for i, v in pairs(newCommands) do
			table.sort(v, function(a, b)
				--SysLog("i = %d, a[1]=%s",i,tostring(a [1]))
				return a[1] < b[1];
			end)
			newNewCommands[i] = v;
		end;

		local iCount = 0
		local iTotal = table.count(newNewCommands)
		local aSortedList = {}
		local aPriorityList = {}

		for i, v in pairs(newNewCommands) do
			SysLog("%s %d>=%d", tostring(IsPriorityGroup(i)),access,i )
			if (IsPriorityGroup(i)) then
				aPriorityList[i]=v
			end
		end

		return newNewCommands, aPriorityList
	end;

	-------------
	ListCommands = function(self, player, access)
		--Debug(MODERATOR,",,.,.",access,"_--",tonum(access))
		local listFrom = IsUserGroup(tonum(access)) and tonum(access) or false;
		--Debug(listFrom)
		if (listFrom) then
			if (tonum(access) > player:GetAccess()) then
				return false, "Invalid Users";
			end;
		end;
		local commands, priority = self:SortCommands(self.Commands, player:GetAccess())

		local cmdColor = "$1";
		
		if (listFrom) then
			local cmdsFrom = GetGroupData(listFrom)[2];
			local cmdsFromLen = makeEven(cmdsFrom:len() / 2);
			local cmdsColor = GetGroupData(listFrom)[4];
			local cmdList = commands[listFrom];
			if (not cmdList) then
				return false, "no " .. cmdsFrom .. " commands found";
			end;
			SendMsg(CONSOLE, player, " ");
			SendMsg(CONSOLE, player, "$9" .. space(52-cmdsFromLen+1, "=") .. " [ ~ " .. cmdsColor .. cmdsFrom .. " $9~ ] " .. space(52-cmdsFromLen, "="));
			
			local currentCommand = 0;
			local line = "     ";
			local total = 0;
			for j, command in pairs(cmdList) do
					

				cmdColor = "$9";
				if (command.isDisabled) then
					cmdColor = "$4";
				elseif (command[5].Hidden) then
					cmdColor = "$6";
				elseif (command.isBroken) then
					cmdColor = "$8";
				elseif (command[2] > 1 and player:IsSuspended()) then
					cmdColor = "$4"
				end;
						
				if (not command[5].Hidden or player:HasAccess(SUPERADMIN)) then
					total = total + 1;
					currentCommand = currentCommand + 1;
					line = line .. "$1!" .. cmdColor .. command[1] .. space(15-string.len(command[1]));
				end;
				if (currentCommand >= 7 or j == arrSize(cmdList)) then
					SendMsg(CONSOLE, player, line);
					line = "     ";
					currentCommand = 0;
				end;
			end;
			SendMsg(CONSOLE, player, "$9" .. space(112, "="));
			SendMsg(CHAT_ATOM, player, "(Commands: Open console to view the [ " .. arrSize(cmdList) .. " ] " .. cmdsFrom .. " Commands)");
		else

			local total = 0;
			local nameSpace = 15;
			local groupName, groupNameLen, groupColor, cmdColor, cmdExtra;
			local function DOLIST(aList,ball)
				--total = 0;
				SendMsg(CONSOLE, player, " ");
				for i, access in pairs(aList) do
					SysLog("%d    access: %s, prio: %s", i,tostring(player:HasAccess(i)), tostring(IsPriorityGroup(i)))
					if (player:HasAccess(i) and (ball or not IsPriorityGroup(i))) then

						groupColor = GetGroupData(i)[4];
						groupName = GetGroupData(i)[2];
						groupNameLen = makeEven(groupName:len() / 2);

						SendMsg(CONSOLE, player, "$9" .. space(54-groupNameLen+1, "=") .. " [ ~ " .. groupColor .. groupName .. " $9~ ] " .. space(52-groupNameLen, "="));

						local currentCommand = 0;
						local line = "     ";
						for j, command in pairs(access) do


							cmdExtra = ""
							cmdColor = "$9";
							if (command.isDisabled) then
								cmdColor = "$4";
							elseif (command[5].Hidden) then
								cmdColor = "$6";
							elseif (command.isBroken) then
								cmdColor = "$8";
							elseif (i > 1 and player:IsSuspended()) then
								--	cmdColor = "$4"
							end;

							if ((i > 1 and player:IsSuspended()) or self:GetBan(checkFunc(player.GetProfile, nil, player), string.lower(command[1]))) then
								cmdExtra = "$9($4x$9)"
							end

							if (not command[5].Hidden or player:HasAccess(SUPERADMIN)) then
								total = total + 1;
								currentCommand = currentCommand + 1;
								line = line .. cmdExtra .. "$1!" .. cmdColor .. command[1] .. space(15-string.len(command[1])-(cmdExtra~=""and 3 or 0));
							end;
							if (currentCommand >= 7 or j == arrSize(access)) then
								SendMsg(CONSOLE, player, line);
								line = "     ";
								currentCommand = 0;
							end;
						end;
						if (i ~= arrSize(commands)) then
							SendMsg(CONSOLE, player, " ");
						end;
					end;
				end;
			end
			DOLIST(commands)
			DOLIST(priority,1)
			SendMsg(CHAT_ATOM, player, "(Commands: Open console to view the [ " .. total .. " ] Commands)");
			SendMsg(CONSOLE, player, " ");
			SendMsg(CONSOLE, player, "     $1!$9COMMAND <$1Help/?$9> For Command Info");
		end;
		return true;
	end;

	-------------
	ProcessCommand = function(self, player, command, fromConsole, ...)
			
		g_statistics:AddToValue("CommandsTotal", 1);
	
		------------
		local commandData	 = self:GetCommand(command);
		local commandProps	 = commandData[5];
		local commandAccess	 = GetGroupData(commandData[2]);
		local commandArgs	 = commandData[3];
		
		------------
		local args = {...};
		
		------------
		local playerAccess = (player.isServer and 999 or player:GetAccess()) --commandData[2]-1; --player:GetAccess();
		
		------------
		local sCommandAccess = commandAccess[2]
		local iCommandAccess = commandData[2]
		local sCommandAccessDiff = "=="
		if (playerAccess > iCommandAccess) then
			sCommandAccessDiff = "-" .. (playerAccess - iCommandAccess) elseif (playerAccess < iCommandAccess) then
				sCommandAccessDiff = "+" .. (iCommandAccess - playerAccess) end
		
		------------
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   ->  Access: %s (%s)", tostring(iCommandAccess), sCommandAccessDiff)
		
		------------
		local aBan = self:GetBan(checkFunc(player.GetProfile, nil, player), string.lower(command))
		if (aBan) then
			local sBanReason = checkVar(aBan.Reason, string.UNKNOWN)
			local sBannedBy  = checkVar(aBan.Name, string.UNKNOWN)
			local iBannedBy  = checkVar(aBan.ID, string.UNKNOWN)
			
			ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   ->  Banned: %s (%s)", "Yes", sBanReason)
			ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "       ->  By: %s (%s)", sBannedBy, iBannedBy)
			
			self:Msg(player, eFR_Banned, command, sBanReason, sBannedBy)
			return true
		end
		
		------------
		--Debug("commandProps",commandProps)
		--Debug(fromConsole)
		if (commandProps.SendHelp) then
			player.sendHelp = true;
		else
			player.sendHelp = false;
		end;
		
		------------
		if (player.rCOM) then
			playerAccess = player.rCOM;
			player.rCOM = nil;
		end;
		local noAccess = playerAccess < commandData[2];
		
		if (not noAccess) then
			if (args[1] and (args[1] == "-h" or args[1] == "-help" or args[1] == "-?" or args[1] == "?" or args[1] == "/?")) then
				self:Msg(player, eFR_SOS, command);
				self:SendHelp(player, command);
				self:ChatHelp(player, command);
				return true;
			end;
		end;
		
		--SysLog("ATOM : (Command) : " .. player:GetName() .. " Executing " .. command .. " >> " .. table.concat({...}, ", "));
		
		--Debug("PL ACCESS + ", playerAccess,"<",commandData[2])
		if (player.isPlayer) then
			
			if (commandData[2] > 1 and playerAccess > 1 and player:IsSuspended() and commandProps.IgnoreSuspension ~= true) then
				return self:Msg(player, eFR_Suspended, command, player:GetSuspensionReason())
			end
			
			if (noAccess) then
				
				local isPrem = IsPremium(commandData[2]);
				local isChild = playerAccess + 1 == commandData[2] and commandData[2] ~= GetHighestAccess();
				
				if (isPrem) then
					return self:Msg(player, eFR_Premium, command, "Premium", "Members");
				elseif (isChild) then
					return self:Msg(player, eFR_Premium, command, GetGroupData(commandData[2])[2] .. "s", "");
				else
					return self:Msg(player, eFR_Access, command);
				end;
			end;


			local sAuth = commandProps.RequiredAuth
			local sFeature = commandProps.RequiredFeature
			local iSkipAuth = commandProps.SkipAuth
			local iSkipFeature = commandProps.SkipFeature
			local bSkipAuth = false
			local bSkipFeature = false
			if (iSkipAuth and player:HasAccess(iSkipAuth)) then
				bSkipAuth = true
			end
			if (iSkipFeature and player:HasAccess(iSkipFeature)) then
				bSkipFeature = true
			end

			if (not bSkipAuth and not string.empty(sAuth) and not player:HasAuthorization(sAuth)) then
				return self:Msg(player, eFR_LackAuth, command, player:GetAuthName(sAuth)); -- same as eFR_DisabledYou
			end

			if (not bSkipFeature and not string.empty(sFeature) and not GetBetaFeatureStatus(sFeature)) then
				return self:Msg(player, eFR_FeatureMissing, command, GetFeatureName(sFeature, true)); -- same as eFR_DisabledYou
			end

			local ignore = commandProps.IgnoreUsers and player:HasAccess(commandProps.IgnoreUsers);
		
			if (player.NoCommands) then
				return self:Msg(player, eFR_DisabledYouAll, command); -- same as eFR_DisabledYou
			end;
		
			if (player.NoCommand and player.NoCommand[command]) then
				return self:Msg(player, eFR_DisabledYou, command);
			end;
		
			if (commandData.isDisabled and not self:CanUseDisabledCommand(commandData.isDisabled, playerAccess)) then
				return self:Msg(player, eFR_Disabled, command);
			end;
			
			if (commandData.isBroken and playerAccess < GetHighestAccess() - 1) then
				return self:Msg(player, eFR_Broken, command);
			end;
			
			local ATOMClient = commandProps.RequireRCA;
			if (ATOMClient) then
				if (not player.ATOM_Client) then
					return self:Msg(player, eFR_Failed, command, "ATOMClient Required for this Command");
				end;
			end;
			
			local NoVehicle = commandProps.NoVehicle;
			if (NoVehicle) then
				local vehicleId = player.actor:GetLinkedVehicleId();
				if (vehicleId) then
					return self:Msg(player, eFR_Failed, command, "Not in vehicle");
				end;
			end;
			
			if (fromConsole) then
				--Debug("FC")
				local canUseFromCon = commandProps.FromConsole;
				if ((canUseFromCon == false or command[7] == false) and not player:HasAccess(SUPERADMIN)) then--) then-- 
					return self:Msg(player, eFR_NoConsole, command);
				end;
			end;
			
			local rules = commandProps.GameRules;
			if (rules and not ignore) then
				if (rules:lower() ~= g_gameRules.class:lower()) then
					return self:Msg(player, eFR_Failed, command, "Only in " .. rules);
				end;
			end;
			
			local level = commandProps.Level;
			if (level and player.GetLevel and not ignore) then
				if (level > player:GetLevel()) then
					return self:Msg(player, eFR_FailedBLE, command, "Requires Level " .. level);
				end;
			end;
			
			local maps = commandProps.Maps;
			if (maps and not ATOM:GetMapName():lower():match(maps:lower()) and not ignore) then
				return self:Msg(player, eFR_FailedBLE, command, "Only in " .. self:GetMapName(maps));
			end;
			
			local alive = commandProps.Alive;
			if (alive and not ignore) then
				if (not player:IsAlive()) then
					return self:Msg(player, eFR_FailedBLE, command, "Only Alive");
				end;
			end;
			
			local notAFK = commandProps.NotAFK;
			if (notAFK and not ignore) then
				if (player:IsAFK()) then
					return self:Msg(player, eFR_FailedBLE, command, "Not while AFK");
				end;
			end;
			
			local onlyAFK = commandProps.OnlyAFK;
			if (onlyAFK and not ignore) then
				if (not player:IsAFK()) then
					return self:Msg(player, eFR_FailedBLE, command, "Only while AFK");
				end;
			end;
			
			local isIndoors = System.IsPointIndoors(player:GetPos());
			
			local inDoors = commandProps.Indoors;
			if (inDoors == true and not isIndoors and not ignore) then
				return self:Msg(player, eFR_FailedBLE, command, "Only Indoors");
			elseif (inDoors == false and isIndoors and not ignore) then
				return self:Msg(player, eFR_FailedBLE, command, "Not Indoors");
			end;
			
			local onGround = commandProps.OnGround;
			if (onGround and not ignore) then
				if (player.actor:IsFlying()) then
					return self:Msg(player, eFR_FailedBLE, command, "Cannt be used in Air");
				end;
			end;
			
			--local isArgPlayer = false;
			--[[if (arrSize(args) > 0 and arrSize(commandArgs) > 0) then
				for i, arg in pairs(args) do
					if (commandArgs[i]) then
						if (commandArgs[i].Target) then
							if (not GetPlayer(arg)) then
								return self:Msg(player, eFR_FailedBLE, command, "invalid player");
							elseif (GetPlayer(arg).id == player.id and commandArgs[i].NotPlayer) then
								return self:Msg(player, eFR_Failed, command, "cannot be used on yourself");
							else
								args[i] = GetPlayer(arg);
							end;
						end;
					end;
				end;
			end;--]]

			
			local idIsDev = player:HasAccess(DEVELOPER)
			for i, cmdArg in pairs(commandArgs or {}) do
				local thisArg = args[i];
				local skipPlayer = false;
				local argAccess = cmdArg.Access;
				
				if (argAccess and argAccess>playerAccess) then
				--	Debug("no access for argument",i)
					args[i] = nil;
				else
					if (cmdArg) then
						if (thisArg) then
							if (cmdArg.AcceptThis) then
								--Debug("si")
								local argOK = cmdArg.AcceptThis[thisArg:lower()] or cmdArg.AcceptThis[tonum(thisArg)]
								if (cmdArg.AcceptThis and argOK and argOK == true) then
									args[i] = args[i]:lower();
									skipPlayer = true;
								--	Debug(":D")
								elseif (cmdArg.AcceptThis) then
									if (not cmdArg.Target) then
										local canBe = "(<";
										local i = 0;
										for j, cb in pairs(cmdArg.AcceptThis) do
											i = i + 1;
											canBe = canBe .. tostr(j):upper() .. (i~=arrSize(cmdArg.AcceptThis)and ">, <" or ">)");
										end;
										return self:Msg(player, eFR_Failed, command, "Argument " .. cmdArg[1] .. " can be " .. canBe);
									end;
								end;
							end;
						end;
						if (not skipPlayer and cmdArg.Target and (cmdArg.Required or args[i])) then
							
							if (not args[i]) then
								return true, self:Msg(player, eFR_FailedBLE, command, "specify player");
							end;
							if (false) then --
							else
								if (cmdArg.AcceptAll) then
									cmdArg.AcceptALL = cmdArg.AcceptAll;
								end;
								if (not cmdArg.AcceptALL or args[i]:lower() ~= "all") then
									if (cmdArg.AcceptSelf and args[i]:lower() == "self") then
										args[i] = player;
									else
										--Debug(args[i])
										local argTgt = GetPlayer(args[i]);
										--Debug(argTgt)

										
										local GEQAccess;
										local GTRAccess;
										local bSameAccess = true
										
										if (argTgt and argTgt.GetAccess) then
											GEQAccess = argTgt:GetAccess() >= playerAccess;
											GTRAccess = argTgt:GetAccess() >  playerAccess + (GetHighestAccess()==playerAccess and 1 or 0);
											bSameAccess = (argTgt:GetAccess() <= playerAccess)
										end;
										if (not argTgt) then
											return true, self:Msg(player, eFR_FailedBLE, command, "invalid player");
										elseif (argTgt.id == player.id and commandArgs[i].NotPlayer and not idIsDev) then
											return true, self:Msg(player, eFR_Failed, command, "cannot be used on yourself"); -- skip devs, they can do whatever they want c:
										elseif (cmdArg.SameAccess and not bSameAccess) then
											return true, self:Msg(player, eFR_FailedBLE, command, "insufficient access");
										elseif (cmdArg.EqualAccess and GTRAccess) then
											return true, self:Msg(player, eFR_FailedBLE, command, "insufficient access");
										elseif (cmdArg.MaxAccess and isNumber(cmdArg.MaxAccess) and argTgt:HasAccess(cmdArg.MaxAccess) and argTgt.id~=player.id and not argTgt:HasAccess(DEVELOPER)) then
											return true, self:Msg(player, eFR_Failed, command, "not on " .. GetGroupData(cmdArg.MaxAccess)[2])
										elseif (cmdArg.TargetAlive and (argTgt:IsDead() or argTgt:IsSpectating())) then
											return true, self:Msg(player, eFR_Failed, command, "target must be alive");
										--elseif (cmdArg.TargetAlive and not argTgt:IsAlive()) then
										--	return true, self:Msg(player, eFR_Failed, command, "target
										else
											args[i] = argTgt;
										end;
									end;
								elseif (cmdArg.AcceptALL and args[i]:lower() == "all") then
									args[i] = "all";
								end;
							end;
						end;
						if (not args[i] and cmdArg.Default) then
							args[i] = cmdArg.Default;
							--Debug("Default:",args[i])
						end;
								
						if (cmdArg.Required) then
							if (not args[i]) then
								--if (cmdArg.Default) then
								--	args[i] = cmdArg.Default;
								--	Debug("Default:",args[i])
								--else
								--if (commandProps.SendHelp) then
								--	return true, self:ChatHelp(player, command, commandArgs);
								--end;
									return true, self:Msg(player, eFR_FailedBLE, command, "specify argument <" .. cmdArg[1] .. ">");
								--end;
							end;
						end;
						if (args[i]) then
						--	Debug("SPecified but no neccessary!")
							local argNum = tonumber(args[i]) or tonumber(_G[string.upper(tostr(args[i]))]);
							if ((cmdArg.Integer or cmdArg.IsInteger)) then
								if ((not args[i] or not argNum)) then
									return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> must be a number");
								elseif (argNum < 0 and cmdArg.PositiveNumber) then
									return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> must be a positive number");
								elseif (argNum > 0 and cmdArg.NegativeNumber) then
									return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> must be a negative number");
								elseif (cmdArg.Range) then
									local min = cmdArg.Range[1] or cmdArg.Range.Min;
									local max = cmdArg.Range[2] or cmdArg.Range.Max;
									if (min and argNum < min and not player:HasAccess(DEVELOPER)) then -- Devs have the Power!
										return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> number must be greater than " .. min);
									elseif (max and argNum > max and not player:HasAccess(DEVELOPER)) then -- Devs have the Power!
										return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> number must be lesser than " .. max);
									end;
								end;
								args[i] = argNum;
							else
								if (cmdArg.Concat) then
									local all = "";
									--Debug("Concat:",args[i]); 
									for ii, vv in pairs(args) do
										if (ii >= i) then
									--		Debug(vv)
											--all = all .. ((ii < arrSize(args) and ii > 1 and all~="") and " "or"") .. vv
											all = all .. vv .. (ii < arrSize(args) and " " or "")
										end;
									end;
									args[i] = all;
									--Debug("ALL = ",all)
									--Debug("Concat:",args[i]); 
								end;
							end;
							
							if (cmdArg.Length and not player:HasAccess(SUPERADMIN)) then -- Supers have the Power too!
								local strMin = cmdArg.Length[1] or cmdArg.Length.Min or 0;
								local strMax = cmdArg.Length[2] or cmdArg.Length.Max or 100;
								local strLen = string.len(args[i]);
								if (strLen < strMin) then
									return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> argument too short");
								elseif (strLen > strMax) then
									return true, self:Msg(player, eFR_Failed, command, "argument <"..cmdArg[1].."> argument too long");
								end;
							end;
						end;
					end;
				end;
			end;
			
			local timer = commandProps.Timer;

			player.lastUsedCommands = player.lastUsedCommands or {};
			if (timer and timer > 0 and playerAccess < GetHighestAccess()-1) then --
				player.lastUsedCommands[commandData[1]] = player.lastUsedCommands[commandData[1]] or _time - (timer + 1);
				
				local remaining = _time - player.lastUsedCommands[commandData[1]];
				
				if (remaining <= timer) then
					return self:Msg(player, eFR_FailedBLE, command, "Wait " .. calcTime(timer - remaining, true, unpack(GetTime_SM)));
				else

				end;
			end;
			
			local cost = commandProps.Cost;
			if (cost and cost > 0 and g_gameRules.class == "PowerStruggle") then
				local hasToPay = not player:IsTesting();
				if (hasToPay) then
					local ppLeft = player:GetPrestige() - cost;
					local canPay = ppLeft >= 0;
					if (canPay) then
						player:PayPrestige(cost);
					else
						return true, self:Msg(player, eFR_FailedBLE, command, "You need " .. (ppLeft*-1) .. " more Prestige");
					end;
				end;
			end;
			
			local NeedVehicle = commandProps.RequireVehicle;
			local MustBeDriver = commandProps.RequireDriver or commandProps.OnlyAsDriver or commandProps.OnlyDriver;
			if (NeedVehicle) then
				local vehicleId = player.actor:GetLinkedVehicleId();
				if (not vehicleId) then
					return self:Msg(player, eFR_Failed, command, "Only in vehicle");
				elseif (MustBeDriver and System.GetEntity(vehicleId):GetDriverId() ~= player.id) then
					return self:Msg(player, eFR_Failed, command, "Only as driver");
				else
					-- Bugged Argument processing
					local nArgs = {
						System.GetEntity(vehicleId);
					};
					for i, v in pairs(args) do
						table.insert(nArgs, v);
					--	Debug("Added %d (%s) Arg again.",i,v);
					end;
					args = nArgs;
				end;
			end;
			
			local CVarDependency = commandProps.RequiresCVar;
			
			if (CVarDependency) then
				local is, requires, msg;
				for i, dependency in pairs(CVarDependency) do
					is = dependency[1];
					requires = dependency[2];
					msg = dependency[3] or "CVar changes required";
					if (is and requires) then
						is = System.GetCVar(is);
						if (is) then
							if (tostr(is)~=tostr(requires)) then
								return self:Msg(player, eFR_Failed, command, msg);
							end;
						end;
					end;
				end;
			end;
		end;
		
		if (commandProps.OpenConsole) then
			ExecuteOnPlayer(player, "System.ShowConsole(1)");
		end;

		if (player.isPlayer) then
			player.lastUsedCommands[commandData[1]] = _time
		end

		local funcToDo = commandData[4];
		local luaSuccess, return1, return2, return3;
		local _SELF;
		if (commandProps.Self) then
			if (type(commandProps.Self) == "string") then
				local P1, P2 = commandProps.Self:match("(.*)%.(.*)");
				if (P1 and P2) then
					_SELF = _G[P1][P2];
				else
					_SELF = _G[commandProps.Self];
				end;
			else
				_SELF = commandProps.Self;
			end;
			if (DEBUG_MODE) then
				return1, return2, return3 = funcToDo(_SELF, player, unpack(args));
				luaSuccess = true;
			else
				luaSuccess, return1, return2, return3 = pcall(funcToDo, _SELF, player, unpack(args));
			end;
		else
			if (DEBUG_MODE) then
				return1, return2, return3 = funcToDo(player, unpack(args));
				luaSuccess = true;
			else
				luaSuccess, return1, return2, return3 = pcall(funcToDo, player, unpack(args));
			end;
		end;
		
		
		
		if (not luaSuccess) then
			self:Msg(player, eFR_CmdBroke, command);
			self:BreakCommand(command)
			ATOMLog:LogError(return1)
			return false
		elseif (return1 == true) then
			if (self:IsBroken(command)) then
				self:RepairCommand(command);
			end;
			if (command == "validate") then
				return true, self:Msg(player, (player.IDValidated and eFR_Validated or eFR_Validating), command);
			end;
			return true, self:Msg(player, eFR_Success, command);
		elseif (return1 == false) then
		--	Debug("F")
			return false, self:Msg(player, (return2 == nil and eFR_FailedNil or eFR_Failed), command, return2);
		else
			return self:Msg(player, eFR_NoFeedback, command);
		end;
		Debug("WTF, HOW ???")
	end;
	--[[
			self.Commands[name] = {
				name,
				access,
				args,
				func,
				prop
			};
	]]

	-------------
	GetArgDescription = function(self, argName, nodesc)
		return self.ArgumentInfo[argName:lower()] or (not nodesc and "No Description" or nil);
	end;

	-------------
	SendHelp = function(self, player, commandName)
		local command = self.Commands[commandName:lower()];
		if (command) then
			local args = command[3];
			local desc = (command[6] or "No Description");
			SendMsg(CONSOLE, player, "$9"  .. space(112, "="));
			SendMsg(CONSOLE, player, "$9[ " .. desc .. space(109 - string.len(desc)) .. "]");
			SendMsg(CONSOLE, player, "$9"  .. space(112, "="));
			if (arrSize(args) > 0) then
				local spacer = "";
				local argColor = "$1";
				for i, v in pairs(args) do
					argColor = "$1";
					if (v.Required) then
						argColor = "$3";
					elseif (v.Optional) then
						argColor = "$5";
					end;
					--local argType = "";
					--if (v.Integer or v.IsInteger) then
					--	argType = "Integer";
					--elseif (v.Target) then
					--	argType = "Player";
					--elseif (v.Concat) then
					--	argType = "String"
					--end;
					local argDesc = (v[2] or self:GetArgDescription(v[1]));
					local sign = (i ~= arrSize(args) and "+" or "");
					local newLine = spacer .. "[ " .. argColor .. v[1] .. " $9]" .. sign .. " :: $1" .. argDesc;
					SendMsg(CONSOLE, player, "$9" .. newLine .. space(111-string.len(subColor(newLine))) .. "$9]");-- .. space(100-string.len(subColor(v[1]))-string.len(subColor(sign))-4-string.len(subColor(spacer))-string.len(subColor(argDesc))-string.len(argType)) .. "()");
					spacer = spacer .. space(string.len(v[1]) + 4, "-");
				end;
				SendMsg(CONSOLE, player, "$9" .. space(112, "="));
			end;
		end;
	end;

	-------------
	ChatHelp = function(self, player, commandName)
		local command = self.Commands[commandName:lower()];
		if (command) then
			local args = command[3];
			local argMsg;
			for i, arg in pairs(args) do
				argMsg = (argMsg or "") .. (i~=1 and ", " or "") .. "<" .. arg[1] .. ">";
			end;
			if (not argMsg) then
				argMsg = "No Arguments";
			else
				argMsg = "[ " .. argMsg .. " ]";
			end;
			SendMsg(CHAT_HELP, player, "(" .. commandName:upper() .. ": " .. argMsg .. ", ".. (command[6] or "No Description") .. ")");
		end;
	end;

	-------------
	BreakCommand = function(self, commandName)
		self.Commands[commandName].isBroken = true;
	end;

	-------------
	IsBroken = function(self, commandName)
		return self.Commands[commandName].isBroken;
	end;

	-------------
	RepairCommand = function(self, commandName)
		self.Commands[commandName].isBroken = false;
	end;

	-------------
	LogCommand = function(self, command)
		return self:GetCommand(command) and (self:GetCommand(command)[5].NoLogging or self:GetCommand(command)[5].NoLog) or true;
	end;

	-------------
	Msg = function(self, player, case, p1, p2, p3, p4)

		if (not isArray(player) or not player.id) then
			return SysLog("Invalid parameter to Msg()")
		end
	
		player.CmdMsg = true;
		local plAccess = (player.GetAccess and player:GetAccess() or 999) + 1;
		if (plAccess > GetHighestAccess()) then
			plAccess = GetHighestAccess();
		end;
		local playersExept = GetPlayers(plAccess, nil, player.id);
		if (not self:LogCommand(p1)) then
			return false;
		end;
		
		local props = self:GetCommand(p1) and self:GetCommand(p1)[5];
		
		local message;
		
		if (case == eFR_SOS) then
			SendMsg(CONSOLE_NOQUENE , player, "  $9($1!%s$1: $3Help sent to console $9)", p1);
			
		--------------
		elseif (case == eFR_Banned) then
			SendMsg(CONSOLE_NOQUENE , player, "  $9($1!%s$1: $4Banned $9($4%s$9)$9)", p1, p2);
			SendMsg(CHAT_ATOM, player, "(%s: Banned (%s))", string.upper(p1), p2);
			message = "$4Banned"
			
		--------------
		elseif (case == eFR_Suspended) then
			SendMsg(CONSOLE_NOQUENE , player, "  $9($1!%s$1: $4Access Suspended $9($4%s$9)$9)", p1, p2);
			SendMsg(CHAT_ATOM, player, "(%s: You are Temporarily Suspended from using this Command (%s))", string.upper(p1), p2);
			message = "$4Banned"

		--------------
		elseif (case == eFR_LackAuth) then
			SendMsg(CONSOLE_NOQUENE , player, "  $9($1!%s$1: $4Failed (Lack of Authorization: %s)$9)", p1, p2, p3);
			SendMsg(CHAT_ATOM, player, "(%s: You Lack Authorization to Use this Command)", string.upper(p1), p2);
			message = "$4Failed"

		--------------
		elseif (case == eFR_FeatureMissing) then
			SendMsg(CONSOLE_NOQUENE , player, "  $9($1!%s$1: $4Failed (Feature Disabled)$9)", p1, p2, p3);
			SendMsg(CHAT_ATOM, player, "(%s: This command Requires a certain Feature to be Enabled)", string.upper(p1), p2);
			message = "$4Failed"
			
		--------------
		elseif (case == eFR_Success) then
			SendMsg(CONSOLE_NOQUENE  , player, "  $9($1!%s$1: $3Success $9)", p1);
			if (not props.NoChatLog) then
				player.CmdMsg = true;
				SendMsg(player,		playersExept, "(%s : Success)", p1:upper());
			end;
			--SysLog("ATOM : (Command) : " .. player:GetName() .. " Executed " .. p1 .. " (SUCCESS)");
			message = "$3Success";
			
		--------------
		elseif (case == eFR_NoFeedback) then
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $8No Feedback $9)", p1);
			if (not props.NoChatLog) then
				player.CmdMsg = true;
				SendMsg(player,		playersExept, "(%s : No Response)", p1:upper());
			end;
			--SysLog("ATOM : (Command) : " .. player:GetName() .. " Executed " .. p1 .. " (NO FEEDBACK)");
			message = "$8No Feedback";
			
		elseif (case == eFR_ManyMatches) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Open console to view the [ %d ] results)", p2); -- maybe add all to config
			if (not p3) then -- p3 == do not log command
				SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $3Open console to view the [ %d ] results$9)", p1, p2);
			end;
		elseif (case == eFR_NoMatch) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Unknown Command)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4%s$9)", p1, "Unknown Command");
		elseif (case == eFR_Access) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Unknown Command)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4%s$9)", p1, "Unknown Command");
			message = "$4Insufficient Access";
		elseif (case == eFR_Broken) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Command Unavailable)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Command Unavailable");
			message = "$4Command Unavailable";
		elseif (case == eFR_CmdBroke) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Failed: Script Error)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Script Error");
			message = "$4Command Broken";
		elseif (case == eFR_Disabled) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Command Disabled)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Command Disabled");
			message = "$4Command Disabled";
		elseif (case == eFR_DisabledYou) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": You cannot use this command)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Command Disabled For You");
			message = "$4Command Disabled On Player";
		elseif (case == eFR_DisabledYouAll) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": You cannot use this command)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Command Disabled For You");
			message = "$4Command Disabled On Player";
		elseif (case == eFR_FailedBLE) then
			-- !!TODO battle log event
			SendMsg(CONSOLE_NOQUENE  , player, "  $9($1!%s$1: $4failed: %s$9)", p1, p2);
			--if (not props.NoChatLog) then
				player.CmdMsg = true;
				SendMsg(player,		 playersExept, "(%s : Failed (%s))", p1:upper(), p2);
			--end;
			if (player.sendHelp) then
				self:ChatHelp(player, p1, self:GetCommand(p1)[3]);
				player.sendHelp = false;
			else
				SendMsg({ CHAT_ATOM, BLE_ERROR }, player, "(" .. p1:upper() .. ": Failed, %s)", p2);
			end;
			message = "$4Failed: " .. p2;
		elseif (case == eFR_Failed) then
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, p2);
			--if (not props.NoChatLog) then
				player.CmdMsg = true;
				SendMsg(player,		 playersExept, "(%s : Failed (%s))", p1:upper(), p2);
			--end;
			if (player.sendHelp) then
				self:ChatHelp(player, p1, self:GetCommand(p1)[3]);
				player.sendHelp = false;
			else
				SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Failed, %s)", p2);
			end;
			message = "$4Failed: " .. p2;
		elseif (case == eFR_FailedNil) then
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed$9)", p1);
			--if (not props.NoChatLog) then
				player.CmdMsg = true;
				SendMsg(player,		 playersExept, "(%s : Failed)", p1:upper());
			--end;
			if (player.sendHelp) then
				self:ChatHelp(player, p1, self:GetCommand(p1)[3]);
				player.sendHelp = false;
			else
				SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Failed)");
			end;
			message = "$4Failed";
		elseif (case == eFR_Premium) then
			SendMsg(CHAT_ATOM,	 player, "(" .. p1:upper() .. ": Reserved for %s %s)", p2, p3);
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: Reserved for %s %s$9)", p1, p2, p3);
			message = "$4Insufficient Access";
		elseif (case == eFR_Validating) then
			--SendMsg(CHAT_ATOM,	 player, "(" .. p1:upper() .. ": Reserved for %s %s)", p2, p3);
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $8Validating$9)", p1);
			message = "$3Success";
		elseif (case == eFR_Validated) then
			--SendMsg(CHAT_ATOM,	 player, "(" .. p1:upper() .. ": Reserved for %s %s)", p2, p3);
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $3Validated$9)", p1);
			message = "$3Success";
		elseif (case == eFR_NoConsole) then
			SendMsg(CHAT_ATOM, player, "(" .. p1:upper() .. ": Cannot use from Console)");
			SendMsg(CONSOLE_NOQUENE, player, "  $9($1!%s$1: $4failed: %s$9)", p1, "Cannot use from Console");
			message = "$4Failed: Cannot use from Console";
		end;
		
		if (message) then
			ATOMLog:LogCommand(GetPlayers(plAccess, nil, player.id), player:GetName(), p1, message);
		end;
		
		SysLog("(Command) %s: %s executed !%s (result = %s)", player:GetName(),(player.WasRemoteExecution and "(REMOTE) :"or""),p1,(message or "No feedback"));
		-- ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "%s Executed Command %s%s (Returned: %s)", player:GetName(), (player.WasRemoteExecution and "(REMOTE) :"or""), p1, (message or "No feedback"))
		
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   ->  Status: %s", (message or "<Unknown>"))
		ATOMLog:LogToLogFile(LOG_FILE_COMMANDS, "   ->  Remote: %s", (player.WasRemoteExecution and "Yes" or "No"))
		
		player.WasRemoteExecution = false
		player.CmdMsg = false
	end;

	-------------
	GuessCommand = function(self, commandName, playerAccess)
		local allCommands, correctCommands = self.Commands, {};
		local commandName = tostr(commandName):lower();
		for ii = 1, 2 do
			for i, v in pairs(allCommands or{}) do
				--DebugTable(v[2])
				--Debug(v[2] <= playerAccess)
				if (v[2] <= playerAccess) then
					local name = tostr(i):lower();
					local subName = name:sub(1, commandName:len());
				--	Debug(name, subName, commandName)
					--                                                        try again with cutting command name
					if (subName == commandName or self:AdvancedGuess(name, commandName, i == 2)) then
						table.insert(correctCommands, tostring(i));
					end;
				end;
			end;
			if (#correctCommands >= 1) then
				break;
			end;
		end;
		return correctCommands;
	end;

	-------------
	AdvancedGuess = function(self, a, b, ADV) -- totally sucked
		
		--for i=1,5 do
		--	if (a==b:sub(1,string.len(b)-i)) then
		--		return true
		--	end;
		--end;
		local l = string.len(a);
		--SysLog("B=%s>%s",b,a)
		return a:lower():match("^"..b:lower())--:lower().."(.*)")
		or (ADV and l>2 and b:match("^"..a:lower():sub(1, l-1).."(.*)"))
		--or b:match("^"..a:lower():sub(1, l-2).."(.*)")
		--or b:match("^"..a:lower():sub(1, l-3).."(.*)")
		--[[for i = 0, 3 do
		--	Debug(a:sub(1, a:len() - i), "==", b:sub(1, b:len() - i))
			if (b:sub(1, b:len() - i) ~= "" and a:sub(1, a:len() - i)  == b:sub(1, b:len() - i)) then
				return true;
			end;
		end;--]]
	end;

	-------------
	

	-------------
	

	-------------
};
ATOMCommands:Init();
