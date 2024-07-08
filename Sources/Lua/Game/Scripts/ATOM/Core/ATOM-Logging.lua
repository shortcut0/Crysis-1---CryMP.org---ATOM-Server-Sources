ATOMLog = {
	cfg = {
		UseCVarVerbosity = true; -- if true, uses log_verbosity and log_fileVerbosity as values
	
		MessagePosition = 30;
	
		Verbosity	  = 4;
		FileVerbosity = 4;
		
		LogEntityKills = false;
		
		FileLoad = {
			Core = { -- does not work
				Access	  		 = DEVELOPER,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			
			Plugin = {
				Access	  		 = SUPERADMIN,
				ServerVerbosity	 = 3,
				PlayerVerbosity	 = 5,
			};
			
			Commands = {
				Access	  		 = ADMINISTRATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			
			Other = {
				Access	  		 = SUPERADMIN,
				ServerVerbosity	 = 3,
				PlayerVerbosity	 = 5,
			};
		};
		
		General = {
			Access	  		 = ADMINISTRATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Errors = {
			Access	  		 = ADMINISTRATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Warnings = {
			Access	  		 = ADMINISTRATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Connection = {
			AdditionalAccess = MODERATOR, -- access required to view additional information such as profiles etc
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		ModifiedFiles = {	
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Rename = {
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Achievements = {
			Access			 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		PersistantScore = {
			Restore = {
				Access			 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Save = {
				Access			 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 5,
			};
		};
		
		Bans = {
			Ban = {
				Access			 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Update = {
				Access			 = ADMINISTRATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
		};
		
		Reports = {
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Mutes = {
			Mute = {
				Access			 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Update = {
				Access			 = ADMINISTRATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Message = {
				Access			 = MODERATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
		};

		Kills = {
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		
		};

		Cheats = {
			AdditionalAccess = MODERATOR,
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		
		};
		
		Kicks = {
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		GameUtils = {
			HQHits = {
				Access	  		 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			LevelScan = {
				Access	  		 = MODERATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			MapChange = {
				Access	  		 = GUEST,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Admin = {
				Access	  		 = MODERATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			SuperAdmin = {
				Access	  		 = SUPERADMIN,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			Misc = {
				Access	  		 = MODERATOR,
				ServerVerbosity	 = 0,
				PlayerVerbosity	 = 0,
			};
			----
			Access	  		 = GUEST,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Users = {
			Access	  		 = ADMINISTRATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		RCA = {
			Access	  		 = ADMINISTRATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Commands = {
			--Access = MODERATOR, -- Uncomment to use global access, else logs to specified access in .LogCommand()
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Swearing = {
			Access = MODERATOR, -- Uncomment to use global access, else logs to specified access in .LogCommand()
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
		
		Debug = {
			Access = ADMINISTRATOR, -- Uncomment to use global access, else logs to specified access in .LogCommand()
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};

		Aliases = {
			Access	  		 = MODERATOR,
			ServerVerbosity	 = 0,
			PlayerVerbosity	 = 0,
		};
	};
	-------------
	logTypes = {};
	-------------
	Init = function(self)
		local cfg = self.cfg;
		
		---------------------
		if (cfg.UseCVarVerbosity) then
			cfg.Verbosity	  = System.GetCVar('log_verbosity');
			cfg.FileVerbosity = System.GetCVar('log_fileVerbosity');
		end;
		
		---------------------
		self.verb	  = cfg.Verbosity or 4;
		self.fileVerb = cfg.FileVerbosity or 4;
		
		---------------------
		DEFAULT_CONSOLE_GREY = "$9";
		SYS_COLOR = "$9"; -- "System(...)"
		
		---------------------
		local logTypes = {
			['LOG_ERROR']		= { "$4", "Error",	 		"$4" };
			['LOG_WARNING']		= { "$8", "Warning",		"$8" };
			['LOG_LOAD' ] 		= { "$5", "Scripts", 		DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_CONNECTION' ] = { "$5", "Network", 		DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_SCRIPT']		= { "$5", "Scripts", 		DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_RENAME']		= { "$5", "Ent",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_ACHIEVE']		= { "$5", "PermaScore", 	DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_SCORE']		= { "$5", "PermaScore", 	DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_BAN']			= { "$4", "BanSystem",		DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_KILL']		= { "$5", "Ent",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_MUTE']		= { "$4", "Mute", 			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_CHEAT']		= { "$4", "ServerDefense", 	DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_KICK']		= { "$4", "ATOM", 			DEFAULT_CONSOLE_GREY or "$9", true };
			['LOG_GAMEUTIL']	= { "$5", "Game",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_USERS']		= { "$5", "Ent",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_RCA']			= { "$5", "RCA",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_COMMAND']		= { "$5", "Chat-Commands",	DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_REPORT']		= { "$4", "Report",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_WARN']		= { "$4", "Warn",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_SWEAR']		= { "$4", "ChatProtect",	DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_HQ']			= { "$5", "HQ-Mod",			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_ATOM']		= { "$4", "ATOM", 			DEFAULT_CONSOLE_GREY or "$9", true };
			['LOG_FILE']		= { "$4", "Files", 			"$4" };
			['LOG_DEBUG']		= { "$3", "Debug", 			DEFAULT_CONSOLE_GREY or "$9" };
			['LOG_ALIAS']		= { "$3", "Alias", 			DEFAULT_CONSOLE_GREY or "$9" };
		};
		
		---------------------
		LONGEST_LOG_ENTITY_NAME = 0
		for i, aEntityInfo in pairs(logTypes) do
			local iLen = string.len(aEntityInfo[2])
			if (iLen > LONGEST_LOG_ENTITY_NAME) then
				LONGEST_LOG_ENTITY_NAME = iLen end
		end
		
		---------------------
		if (OPEN_LOG_FILES == nil) then
			OPEN_LOG_FILES = {} end
		
		---------------------
		if (LOG_FILES_SIZE == nil) then
			LOG_FILES_SIZE = {} end
		
		---------------------
		if (CRYTEK_LOG_FILES_SIZE == nil) then
			CRYTEK_LOG_FILES_SIZE = {} end
		
		---------------------
		LAST_LOGGED_MESSAGES = {}
		
		---------------------
		LOG_REOPEN_TIMES = {}
		
		---------------------
		LOG_FILE_COMMANDS 	= 1
		LOG_FILE_CHAT 		= 2
		LOG_FILE_DEFENSE 	= 3
		LOG_FILE_SYSTEM 	= 4
		LOG_FILE_ATOM	 	= 5
		LOG_FILE_CONNECT 	= 6
		
		self.logRoot = ATOM.ServerRootDir
		self.logFilePathShort = "LogFiles/"
		self.logFilePath = self.logRoot .. self.logFilePathShort
		self.logFilePathRetired = self.logFilePath .. "Retired/"
		self.logFilePathRetiredRelative = ATOM:GetRelativeServerFolder(self.logFilePathRetired)
		
		self.logFiles = {
			[LOG_FILE_COMMANDS] = "CommandsLog.txt", 
			[LOG_FILE_CHAT	  ] = "ChatLog.txt", 
			[LOG_FILE_DEFENSE ] = "CheatLog.txt", 
			[LOG_FILE_SYSTEM  ] = "SystemLog.txt", 
			[LOG_FILE_ATOM    ] = "ModLog.txt", 
			[LOG_FILE_CONNECT ] = "ConnectionLog.txt", 
		}
		
		self:OpenLogFile(LOG_FILE_COMMANDS, true)
		self:OpenLogFile(LOG_FILE_CHAT, 	true)
		self:OpenLogFile(LOG_FILE_DEFENSE, 	true)
		self:OpenLogFile(LOG_FILE_SYSTEM, 	true)
		self:OpenLogFile(LOG_FILE_ATOM, 	true)
		self:OpenLogFile(LOG_FILE_CONNECT, 	true)
		
		--self:LogToLogFile(LOG_FILE_COMMANDS, "File Created")
		--self:LogToLogFile(LOG_FILE_CHAT, "File Created")
		
		---------------------
		ONE_B  = 1;
		ONE_KB = 1024;
		ONE_MB = 1048576;
		ONE_GB = 1073741824;

		---------------------
		for i, t in pairs(logTypes) do
			self.logTypes [ arrSize(self.logTypes) + 1 ] = t;
			_G[tostr(i)] = arrSize(self.logTypes);
		end;
		
		---------------------
		ATOMDLL:SetVerbosity(self.verb);
		
		---------------------
		if (self.cfg.CryLogVerbosity) then
			System.SetCVar("log_verbosity", tostring(self.cfg.CryLogVerbosity));
			System.SetCVar("log_fileVerbosity", tostring(self.cfg.CryLogVerbosity));
		end;
		
		---------------------
		function getPlayerToLogTo(t)
			if (type(t) == "table") then
				if (t.id and GetEnt(t.id)) then
					return GetEnt(t.id):GetName()
				else
					local x="";
					for i,v in pairs(t) do
						x=x..v:GetName() ..(i<arrSize(t)and", "or"")
					end;
					return x
				end;
			elseif (type(t) == "number") then
				if (t == ALL) then
					return "ALL";
				elseif ( t == TEAM) then
					return "TEAM " .. (t==1 and "NK" or t==2 and "US" or "Neutral");
				end;
				if (GetGroupData(t)) then
					return GetGroupData(t)[2];
				else
					return "Unknown Targets"
				end;
			elseif (type(t) == "userdata") then
				return GetEnt(t):GetName();
			else
				return tostring(t);
			end;
		end;
		
		if (CON_COLOR_ENTITY == nil) then
			CON_COLOR_ENTITY = "$3";
		end;
	end,
	-------------
	LogLogFile = function(self, sMsg, ...)
		System.LogAlways("<ATOM> : " .. string.format(tostring(sMsg), ...))
	end,
	-------------
	RetireLogFile = function(self, iLogFile)
		local sLogFile = self.logFiles[iLogFile]
		if (not sLogFile) then
			self:LogLogFile("Attempt to retire invalid Log File %s", tostring(iLogFile))
			return end
			
		local sOldHome = self.logFilePath
		local sRetirementHome = self.logFilePathRetired
		os.execute("if not exist \"" .. sRetirementHome .. "\" md \"" .. sRetirementHome .. "\"")

		--System.LogAlways("->" .. sLogFile)
		--System.LogAlways("->" .. tostring(FileGetName(sLogFile)))
		sRetirementHome = sRetirementHome .. "/" .. FileGetName("X:\\" .. sLogFile) .. "/"
		os.execute("if not exist \"" .. sRetirementHome .. "\" md \"" .. sRetirementHome .. "\"")

		local sPath = self.logFilePath
		local sRetirementAddress = sRetirementHome .. string.format("%s - %s.txt", sLogFile, os.date("Date(%d %b %Y) Time(%H %M %S)"))
		local hRetiredFile = io.open(sRetirementAddress, "w+")
		local hCurrentFile = io.open(sPath .. sLogFile, "r+")

		System.LogAlways("to ->" .. sRetirementAddress)
		
		local sDate = string.format("%s.txt", os.date("Date(%d %b %Y) Time(%H %M %S)"))
		hRetiredFile:write(string.rep("*", string.len(sDate)) .. "\n")
		hRetiredFile:write(string.format("Retired Log File %s", sLogFile, sLogFile) .. "\n")
		hRetiredFile:write(sDate .. "\n")
		hRetiredFile:write(string.rep("*", string.len(sDate)) .. "\n")
		hRetiredFile:write("" .. "\n")
		
		if (hCurrentFile) then
			for line in hCurrentFile:lines() do
				hRetiredFile:write(line .. "\n")
			end
		end
		
		if (hRetiredFile) then
			hRetiredFile:close() end

		--self:LogLogFile("Retired Log File %s (%s)", tostring(sLogFile), fileutils.getnameex(sRetirementAddress))
		--os.execute(string.format("move \"%s\" \"%s\"", (sOldHome .. sLogFile), sRetirementAddress))
	end,
	-------------
	OpenLogFile = function(self, iLogFile, bNoReopen)
		local sLogFile = self.logFiles[iLogFile]
		if (not sLogFile) then
			self:LogLogFile("Attempt to open invalid Log File %s", tostring(iLogFile))
			return end
		
		if (OPEN_LOG_FILES[iLogFile]) then
			if (bNoReopen) then
				--self:LogLogFile("Log File %s is Already Open", tostring(sLogFile))
				return end
			self:CloseLogFile(iLogFile) end
			
		self:RetireLogFile(iLogFile)
		
		local sPath = self.logFilePath
		os.execute("if not exist \"" .. sPath .. "\" md \"" .. sPath .. "\"")
		
		--self:LogLogFile("Opening Log File %s (%s)", tostring(sLogFile), (self.logFilePathShort .. sLogFile))
		OPEN_LOG_FILES[iLogFile] = io.open(sPath .. sLogFile, "w+")
		LOG_FILES_SIZE[iLogFile] = 0
		
		local sDate = string.format("%s - %s.txt", sLogFile, os.date("Date(%d %b %Y) Time(%H %M %S)"))
		self:WriteToLogFile(iLogFile, string.rep("*", string.len(sDate)))
		self:WriteToLogFile(iLogFile, sDate)
		self:WriteToLogFile(iLogFile, string.rep("*", string.len(sDate)))
		self:WriteToLogFile(iLogFile, "")
	end,
	-------------
	CloseLogFile = function(self, iLogFile)
		local sLogFile = self.logFiles[iLogFile]
		if (not sLogFile) then
			self:LogLogFile("Attempt to close invalid Log File %s", tostring(iLogFile))
			return end
		
		if (not OPEN_LOG_FILES[iLogFile]) then
			self:LogLogFile("Attempt to close Log File %s which is not open", tostring(sLogFile))
			return end
			
		OPEN_LOG_FILES[iLogFile]:close()
		OPEN_LOG_FILES[iLogFile] = nil
	end,
	-------------
	RefreshLogFiles = function(self)
		
		local aOpen = OPEN_LOG_FILES
		for iFile, hFile in pairs(aOpen) do
			self:CloseLogFile(iFile)
			self:OpenLogFile(iFile)
		end
		
		self:LogLogFile("Refreshed %d Log Files", #(aOpen))
	end,
	-------------
	WriteToLogFile = function(self, iLogFile, sMessage)
		local sLogFile = self.logFiles[iLogFile]
		if (not sLogFile) then
			self:LogLogFile("Attempt to write to invalid Log File %s", tostring(iLogFile))
			return end
		
		if (not OPEN_LOG_FILES[iLogFile]) then
			self:LogLogFile("Attempt to write to invalid Log File %s which is not open", tostring(iLogFile))
			return end
			
		-- System.LogAlways(string.format("Logged Message with %d bytes to log file %s", string.len(sMessage), sLogFile))
		OPEN_LOG_FILES[iLogFile]:write(sMessage .. string.char(10))
		-- OPEN_LOG_FILES[iLogFile]:write(string.char(10))
		
		LAST_LOGGED_MESSAGES[iLogFile] = _time
	end,
	-------------
	LogToLogFile = function(self, iLogFile, sMessage, ...)
	
		if (not self.logFiles) then
			return end
	
		local sLogFile = self.logFiles[iLogFile]
		if (not sLogFile) then
			self:LogLogFile("Attempt to log to invalid Log File %s", tostring(iLogFile))
			return end
			
		self:WriteToLogFile(iLogFile, self:GetLogTimeStamp() .. self:FormatLogMessage(iLogFile, string.formatex(sMessage, ...)))
	end,
	-------------
	FormatLogMessage = function(self, iLogFile, sMessage)
		
		
		local sTimeDifference = string.lspace("+0s", 13)
		local iLastMessage = LAST_LOGGED_MESSAGES[iLogFile]
		if (iLastMessage) then
			sTimeDifference = string.lspace("+" .. SimpleCalcTime((_time - iLastMessage)), 13) end
		
		local aReplace = {
			{ "timediffer", sTimeDifference },
			{ "timestamp", self:GetLogTimeStamp() },
		}
		
		local sMessageNew = sMessage
		for i, aRep in pairs(aReplace) do
			sMessageNew = string.gsub(sMessageNew, "{" .. aRep[1] .. "}", aRep[2])
		end
		
		return sMessageNew
	end,
	-------------
	GetLogTimeStamp = function(self)
		return (os.date("[%H:%M:%S] "))
	end,
	-------------
	LogDebug = function(self, hUsers, msg, ...) -- why is this here?
		
		---------
		local aCfg = checkVar(self.cfg.Debug, {})
		local sMessage = formatString(msg, ...)
		
		---------
		if (self.verb >= aCfg.ServerVerbosity) then
			self:LogToFile(LOG_DEBUG, sMessage)
		end
		
		---------
		if (self.verb >= aCfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_DEBUG, checkVar(hUsers, aCfg.Access), sMessage)
			if (aCfg.InfoMessage) then
				SendMsg(INFO, toWho or aCfg.Access, subColor(sMessage))
			end
		end
	end,
	-------------
	LogHQHit = function(self, toWho, msg, ...) -- why is this here?
		
		
		local cfg = self.cfg.GameUtils['HQHits'];
		if (not cfg) then
			cfg = self.cfg.GameUtils;
		end;

		local message = formatString(msg, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_HQ, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_HQ, toWho or cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, toWho or cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogGameUtil = function(self, msg, ...) -- why is this here?
		
		do return self:LogGameUtils("LevelScan", msg, ...); end;
		
		local cfg = self.cfg.GameUtils['LevelScan'];
		if (not cfg) then
			cfg = self.cfg.GameUtils;
		end;

		local message = formatString(msg, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_GAMEUTIL, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_GAMEUTIL, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogGameUtils = function(self, case, msg, ...)
		local cfg = self.cfg.GameUtils[case];
		if (not cfg) then
			if (type(case) == "number" and IsUserGroup(case)) then
				cfg = {
					PlayerVerbosity = 0,
					ServerVerbosity = 0,
					Access = case;
				};
				--Debug("changed to access")
			else
				cfg = self.cfg.GameUtils;
			end;
		end;

		local message = formatString(msg, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_GAMEUTIL, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_GAMEUTIL, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	
	end,
	-------------
	LogATOM = function(self, target, msg, ...)
		local cfg = self.cfg.ATOM or {};

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_ATOM, message, getPlayerToLogTo(target or cfg.Access));
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_ATOM, target or cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, target or cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	
	end,
	-------------
	LogRCA = function(self, msg, ...)
		local cfg = self.cfg.RCA;

		local message = formatString(msg, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_RCA, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_RCA, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	
	end,
	-------------
	LogAlias = function(self, sMsg, ...)
		local aCfg = self.cfg.Aliases
		local sMessage = formatString(sMsg, ...)


		if (self.verb >= aCfg.ServerVerbosity) then
			self:LogToFile(LOG_ALIAS, sMessage)
		end

		if (self.verb >= aCfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_ALIAS, aCfg.Access, sMessage)
			if (aCfg.InfoMessage) then
				SendMsg(INFO, aCfg.Access, subColor(sMessage))
			end
		end

	end,
	-------------
	LogUser = function(self, access, msg, ...)
		local cfg = self.cfg.Users;

		local message = formatString(msg, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_USERS, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_USERS, (access or cfg.Access), message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, (access or cfg.Access), subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogChatMessage = function(self, msgType, senderId, targetId, message) -- Messy, as always
		local cfg = self.cfg.ChatMessages;
		
		local player, target = GetEnt(senderId), GetEnt(targetId);
		if (player) then
			if (player.isPlayer) then
				self.logTypes [ arrSize(self.logTypes) + 1 ] = { -- hack
					(player:IsInGodMode() and "$4" or (player.chatColor or "$1")),  player:GetName() .. ((player:IsSpectating() and " (spec)") or (player:IsDead() and " (dead)") or ""), "$1", true
				};
				_G['LOG_CHAT'] = arrSize(self.logTypes);
				
				if (msgType == ChatToAll) then
					Debug("Cmd Response0!",player.CmdMsg)
					self:LogToPlayer(LOG_CHAT, GetPlayers(), message);
				elseif (msgType == ChatToTarget) then
					--Debug("Cmd Response1!",player.CmdMsg)
					if (player.CmdMsg) then
					--	Debug("Fuk")
						return;
					end;
					if (target.id == player.id and not player.CmdMsg) then
					--	self.logTypes[LOG_CHAT][2] = self.logTypes[LOG_CHAT][2] .. "$9( " .. self.logTypes[LOG_CHAT][1] .. "self $9)";
						self:LogToPlayer(LOG_CHAT, { player }, message);
					elseif (not player.CmdMsg) then
						self:LogToPlayer(LOG_CHAT, { player, target }, message);
					--	Debug("PM?")
					else
					end;
					--Debug("now,",player.CmdMsg)
					player.CmdMsg = false;
				elseif (msgType == ChatToTeam) then
				--	Debug("Cmd Response2!",player.CmdMsg)
					local playerTeamPlayers = {};
					for i, tplayer in pairs(GetPlayers()) do
						if (g_game:GetTeam(tplayer.id) == g_game:GetTeam(senderId)) then
							table.insert(playerTeamPlayers, tplayer);
						end;
					end;
					self.logTypes[LOG_CHAT][2] = self.logTypes[LOG_CHAT][2] .. " $9(team)";
					self:LogToPlayer(LOG_CHAT, playerTeamPlayers, message);
				end;
			--	Debug("Type:",msgType)
				self.logTypes [ arrSize(self.logTypes) ] = nil;
				_G['LOG_CHAT'] = nil;
			else
				-- From Server
			end;
		end;
	end,
	-------------
	LogChatMessageToPlayer = function(self, iType, hPlayer, sMessage) -- Messy, as always

		local aCfg = self.cfg.ChatMessages
		if (hPlayer) then
			if (hPlayer.isPlayer) then

				self.logTypes [ arrSize(self.logTypes) + 1 ] = { -- hack
					(hPlayer:IsInGodMode() and "$4" or (hPlayer.chatColor or "$1")),  hPlayer:GetName() .. ((hPlayer:IsSpectating() and " (spec)") or (hPlayer:IsDead() and " (dead)") or ""), "$1", true
				}
				_G['LOG_CHAT'] = arrSize(self.logTypes)

				if (iType == ChatToAll) then
					self:LogToPlayer(LOG_CHAT, { hPlayer }, sMessage)
				elseif (iType == ChatToTarget) then

				elseif (iType == ChatToTeam) then
					self.logTypes[LOG_CHAT][2] = self.logTypes[LOG_CHAT][2] .. " $9(Team)"
					self:LogToPlayer(LOG_CHAT, { hPlayer }, sMessage)
				end;
				self.logTypes [ arrSize(self.logTypes) ] = nil
				_G['LOG_CHAT'] = nil
			end
		end
	end,
	-------------
	LogModifiedFile = function(self, iAccess, sMessage, ...)
		local cfg = self.cfg.ModifiedFiles;

		local sMessage = formatString(sMessage, ...)

		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_FILE, message2);
		end;

		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_FILE, iAccess, sMessage);
			if (cfg.InfoMessage) then
				SendMsg(INFO, iAccess, subColor(sMessage));
			end;
		end;
	end,
	-------------
	LogCheat = function(self, playerName, cheat, info, sure, lagger, logAccess1, logAccess2)
		local cfg = self.cfg.Cheats;

		local access1 = logAccess1 or cfg.Access;
		local access2 = logAccess2 or cfg.AdditionalAccess;

		local guestMessage = "Detected " .. (lagger and "(LAG)" or "") .. "%s$9 Using %s$9";
		local adminMessage = "%s $9($4%s, %s$9)";

		local message1 = formatString(guestMessage, playerName, cheat);
		local message2 = formatString(adminMessage, message1,   info, tostring(sure==true));
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_CHEAT, message2);
		end;

		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_CHEAT, access1, message1, access2, message2, nil, access1 == access2);
			if (cfg.InfoMessage) then
				SendMsg(INFO, GetPlayers(access2, false, player.id), subColor(message2));
				SendMsg(INFO, GetPlayers(access2, true,  player.id), subColor(message1));
			end;
		end;
		
		SysLog("ATOMLog::LogCheat Access1 = %d, Access2 = %d", access1, access2)
	end,
	-------------
	LogDefense = function(self, sMessage, ...)
		local aCfg = self.cfg.Cheats

		local iAccessA = aCfg.Access
		local iAccessB = aCfg.AdditionalAccess

		local guestMessage = "Detected " .. (lagger and "(LAG)" or "") .. "%s$9 Using %s$9";
		local adminMessage = "%s $9($4%s, %s$9)";

		local sMessage = string.formatex(sMessage, ...)

		if (self.verb >= aCfg.ServerVerbosity) then
			self:LogToFile(LOG_CHEAT, sMessage)
		end;

		if (self.verb >= aCfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_CHEAT, iAccessA, sMessage)
		end

		SysLog("ATOMLog::LogCheat Access1 = %d, Access2 = %d", access1, access2)
	end,
	-------------
	LogCommand = function(self, access, player, command, message)
		local cfg = self.cfg.Commands;

		local access = cfg.Access or access;
		--Debug(access)
		local message = formatString("%s$9 executed %s$9 (%s$9)", player, command, message);

		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_COMMAND, message);
		end;

		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_COMMAND, access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, access, subColor(message));
			end;
		end;
	end,
	-------------
	Log = function(self, log, ...)
	
		local cfg = self.cfg.General;

		local message = formatString(log, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_LOAD, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_LOAD, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogLoad = function(self, type, fileMessage, ...)
	
		local cfg = self.cfg.FileLoad[type];
		if (not cfg) then
			cfg = self.cfg.FileLoad.Other;
		end;

		local message = formatString(fileMessage, ...);
		
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_LOAD, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_LOAD, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogWarning = function(self, msg, ...)
	
		local cfg = self.cfg.Warnings;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_WARNING, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_WARNING, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogErrorNoDebug = function(self, sError, ...)

		--------
		local aCfg = self.cfg.Errors
		local sMessage = string.formatex(sError, ...)

		--------
		if (self.verb >= aCfg.ServerVerbosity) then
			self:LogToFile(LOG_ERROR, sMessage)
		end

		--------
		if (self.verb >= aCfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_ERROR, aCfg.Access, sMessage)
			if (aCfg.InfoMessage) then
				SendMsg(INFO, aCfg.Access, subColor(sMessage))
			end
		end
	end,
	-------------
	LogError = function(self, errorMessage, ...)
	
		--------
		NEW_ERRORS = (NEW_ERRORS or 0) + 1;
		
		--------
		local cfg = self.cfg.Errors;

		--------
		local message = string.formatex(errorMessage, ...);
		
		--------
		LOGGED_ERRORS = LOGGED_ERRORS or {};
		table.insert(LOGGED_ERRORS, { message, _time });
		
		if (arrSize(LOGGED_ERRORS) > 2500) then
			table.remove(LOGGED_ERRORS, 1)
		end
		
		--------
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_ERROR, message);
		end;
		
		--------
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_ERROR, cfg.Access, message);
			if (not LAST_ERROR or _time - LAST_ERROR > 120) then
				SendMsg(CHAT_ERROR, cfg.Access, "[ %d ] New Script Error(s) Occured, Open Console!", NEW_ERRORS);
				LAST_ERROR = _time;
				NEW_ERRORS = 0;
			end;
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
		
		--------
		SysLog("Error Stack Traceback: %s", (debug.traceback() or string.TBFAILED))
	end,
	-------------
	LogScript = function(self, scriptMessage, ...)
		local cfg = self.cfg.Scripts;

		local message = formatString(scriptMessage, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_SCRIPT, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_SCRIPT, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogConnect = function(self, player)
		local cfg = self.cfg.Connection;

		player.connectionLogged = true;

		local guestMessage = "Player %s$9 connecting on slot %d";
		local adminMessage = "%s ($4%s, %d, %ss$9)"

		local message1 = formatString(guestMessage, player:GetName(), player:GetChannel());
		local message2 = formatString(adminMessage, message1,         (player.LuaClient and (player.LuaClient[1] .. player.LuaClient[2]) or "Unknown"), player:GetProfile(), cutNum(player.conTime or 00.00, 2));
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_CONNECTION, message2);
		end;
		
		--Debug("Logging NOW!")

		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_CONNECTION, cfg.Access, message1, cfg.AdditionalAccess, message2);
			if (cfg.InfoMessage) then
				SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, false, player.id), subColor(message2));
				SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true,  player.id), subColor(message1));
			end;
		end;
	end,
	-------------
	LogConnection = function(self, msg, ...)
		local cfg = self.cfg.Connection;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_CONNECTION, message);
		end;

		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_CONNECTION, cfg.AdditionalAccess, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, false), subColor(message));
			end;
		end;
	end,
	-------------
	LogDisconnect = function(self, player, reason)
		local cfg = self.cfg.Connection;

		local guestMessage = "Player %s$9 disconnecting on slot %d";
		local adminMessage = "%s, profile: %d"

		local message1 = formatString(guestMessage, player:GetName(), player.actor:GetChannel());
		local message2 = formatString(adminMessage, message1,         player.actor:GetProfileId());
		
		if (reason and string.len(reason) > 3) then
			message1 = message1 .. "$9 ($4" .. reason .. "$9)";
			message2 = message2 .. "$9 ($4" .. reason .. "$9)";
		end;
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_CONNECTION, message2);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_CONNECTION, cfg.Access, message1, cfg.AdditionalAccess, message2, player.id);
			if (cfg.InfoMessage) then
				SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, false), subColor(message2));
				SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogAchievement = function(self, player, msg, ...)
		local cfg = self.cfg.Achievements;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_ACHIEVE, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_ACHIEVE, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogRename = function(self, player, oldName, newName, reason)
		local cfg = self.cfg.Rename;

		local message = formatString("'%s$9' renamed to '%s$9' ($4%s$9)", oldName, newName, reason);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_RENAME, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_RENAME, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
			if (cfg.ChatMessage) then
				if (reason) then
					SendMsg(CHAT_ATOM, cfg.Access, "(%s: Renamed to %s (%s))", oldName, newName, reason);
				else
					SendMsg(CHAT_ATOM, cfg.Access, "(%s: Renamed to %s)", oldName, newName);
				end;
			end;
		end;
	end,
	-------------
	LogReport = function(self, access, msg, ...)
		local cfg = self.cfg.Reports;

		local message = formatString(msg, ...);
		
		if ((self.verb or 0) >= (cfg.ServerVerbosity or 0)) then
			self:LogToFile(LOG_REPORT, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_REPORT, access or cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, access or cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogKick = function(self, msg, ...)
		local cfg = self.cfg.Kicks;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_KICK, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_KICK, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogBan = function(self, msg, ...)
		local cfg = self.cfg.Bans.Ban;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_BAN, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_BAN, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogMute = function(self, msg, ...)
		local cfg = self.cfg.Mutes.Mute;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_MUTE, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_MUTE, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogWarn = function(self, msg, ...)
		local cfg = self.cfg.Warns.Warn;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_WARN, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_WARN, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogMuteMsg = function(self, msg, ...)
		local cfg = self.cfg.Mutes.Message;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_MUTE, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_MUTE, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogSwearing = function(self, access, msg, ...)
		local cfg = self.cfg.Swearing;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_SWEAR, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_SWEAR, access or cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, access or cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogKill = function(self, player, shooter, killType, headShot, weaponClass, sKills, tKills)
		if (not shooter or not player or (not player.isPlayer and not self.cfg.LogEntityKills)) then
			return false;
		end;
		
		if (not weaponClass) then
			weaponClass = player:GetCurrentItem() and player:GetCurrentItem().class or nil;
		end;
		
		local cfg = self.cfg.Kills;
		
		local message;
		local sClass = (not shooter.isPlayer and shooter.class or shooter:GetName());
		if (player == shooter) then
			message = formatString('%s commited suicide', player:GetName());
		else
			message = formatString('$9%s$9 killed $9%s$9 ($4%s$9, HeadShot: $4%s$9)', sClass, player:GetName(), (weaponClass or "Null"), tostr(headShot));
		end;
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_KILL, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			if (cfg.LogToAll) then
				self:LogToPlayer(LOG_KILL, cfg.Access, message);
			else
				local logToThese = {};
				for i, v in pairs(GetPlayers())do
					if (v.KillLogs) then
					--	Debug("kill log")
						table.insert(logToThese, v);
					end;
				end;
				self:LogToPlayer(LOG_KILL, logToThese, message);
			end;
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
			if (cfg.ChatMessage) then
				if (player ~= shooter) then
					if (shooter.isPlayer) then
						if (player.bKillMessages) then
							-- SendMsg(CHAT_ATOM, player, "(%s: Killed you%s (Health: %s%%, Energy: %s%%))", shooter:GetName(), (weaponClass and " with " .. weaponClass or ""), cutNum((shooter.actor:GetHealth()/100)*100,2), cutNum((shooter.actor:GetNanoSuitEnergy()/200)*100,2));
							SendMsg(CHAT_ATOM, player, "(%s: Killed you%s (HP: %s%%, Energy: %s%%))",  shooter:GetName(), (weaponClass and " with " .. weaponClass or ""), cutNum((shooter.actor:GetHealth()/100)*100,2), cutNum((shooter.actor:GetNanoSuitEnergy()/200)*100,2));
						end;
						if (not shooter.bKillMessages) then
							--SendMsg(CHAT_ATOM, shooter, "(%s: Killed%s (HP: %s%%, Energy: %s%%))", player:GetName(), (weaponClass and " with " .. weaponClass or ""), cutNum((shooter.actor:GetHealth()/100)*100,2), cutNum((shooter.actor:GetNanoSuitEnergy()/200)*100,2));
						end;
					elseif (not player.bKillMessages) then
					--	SendMsg(CHAT_ATOM, player, "(%s: Crushed you%s)", sClass, (weaponClass and " with " .. weaponClass or ""));
					end;
				end;
			end;
		else
			for i, tPlayer in pairs(GetPlayers()) do
				if (tPlayer.LogKills and tPlayer:LogKills()) then
					self:LogToPlayer(LOG_KILL, tPlayer, message);
				end;
			end;
		end;
	end,
	-------------
	LogMuteUpdate = function(self, msg, ...)
		local cfg = self.cfg.Mutes.Update;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_MUTE, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_MUTE, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogBanUpdate = function(self, msg, ...)
		local cfg = self.cfg.Bans.Update;

		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_BAN, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_BAN, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogScoreRestore = function(self, case, msg, ...)
		local cfg = self.cfg.PersistantScore[case];
		if (not cfg) then
			return;
		end;
		local message = formatString(msg, ...);
		
		if (self.verb >= cfg.ServerVerbosity) then
			self:LogToFile(LOG_SCORE, message);
		end;
		
		if (self.verb >= cfg.PlayerVerbosity) then
			self:LogToPlayer(LOG_SCORE, cfg.Access, message);
			if (cfg.InfoMessage) then
				SendMsg(INFO, cfg.Access, subColor(message));
				--SendMsg(INFO, GetPlayers(cfg.AdditionalAccess, true),  subColor(message1));
			end;
		end;
	end,
	-------------
	LogToPlayer = function(self, case, access, message, access2, message2, exeptThisPlayer, onlyAccess2) -- this function is a big mess
		local entity, color, msgColor, noSystem = self:GetCaseData(case);
		
		if (CON_COLOR_ENTITY and color == "$5") then
			color = CON_COLOR_ENTITY;
		end;
		
		local syscolor = ""..SYS_COLOR;
		
		if (CON_COLOR_MSG and syscolor == "$9") then
			syscolor = CON_COLOR_MSG;
		end;
		
		local players_1;
		local players_2;
		
		if (access2) then
			players_1 = IsUserGroup(access) and GetPlayers(access2, true, exeptThisPlayer) or access or {};-- or access;
			players_2 = IsUserGroup(access2) and GetPlayers(access2, nil,  exeptThisPlayer) or access2 or {};-- or access2;
			
			if ((players_1 and arrSize(players_1) >= 1) or (players_2 and arrSize(players_2) >= 1)) then
			
				local message_   = not noSystem and syscolor.."System (" .. color .. entity .. syscolor..")" or  color .. entity .. msgColor;-- .. message;
				message  = repStr(self.cfg.MessagePosition, message_, " ") .. message_ .. " $9: " .. msgColor .. message .. msgColor;
				
				local message2_ = not noSystem and syscolor.."System (" .. color .. entity .. syscolor .. ")" or color .. entity;-- .. message2;
				message2 = repStr(self.cfg.MessagePosition, message2_, " ") .. message2_ .. " " ..syscolor .. ": " .. msgColor .. message2;
				
				
				if (not onlyAccess2) then
					SendMsg(CONSOLE, players_1, message);
				end;
				SendMsg(CONSOLE, players_2, message2);
				
			--	Debug("Message to players_1:", message);
			--	Debug("Message to players_2:", message2);
				-- send message
			end;
		else
			--Debug("Logging 1",access)
			players_1 = IsUserGroup(access) and GetPlayers(access, nil, exeptThisPlayer) or access or {};-- or access;
			--Debug(arrSize(players_1))
			if (players_1 and (type(players_1)=="table" and arrSize(players_1) > 0 or true)) then
			--	Debug("???")
			
				local message_   = not noSystem and syscolor.."System (" .. color .. entity .. syscolor..")" or color .. entity .. msgColor;-- .. message;
				message  = repStr(self.cfg.MessagePosition, message_, " ") .. message_ .. " "..syscolor..": " .. msgColor .. message;
				
				--message = "$9System (" .. color .. entity .. "$9) " .. message;
				--message = repStr(self.cfg.MessagePosition, message, " ") .. message;
				if (SendMsg) then
					SendMsg(CONSOLE, players_1, message);
				end;
				--SendMsg(CONSOLE, players_1[1], message);
				--Debug(CONSOLE,players_1[1]:GetName())
				--Debug(players_1[1]:GetAccessString())
				--Debug("Message to players_1:", message, "example:",players_1[1]:GetName());
				-- send message
			else
			--	Debug("??? >>>",players_1)
			end;
		end;
		
	end,
	-------------
	LogToFile = function(self, case, message, toPlayer)
		local entity, color = self:GetCaseData(case)
		if (entity and color) then
			self:LogToLogFile(LOG_FILE_ATOM, "[CONSOLE] (%2d): [%s]%s%s", case, string.lspace(entity, LONGEST_LOG_ENTITY_NAME), (toPlayer and "(To: " .. toPlayer .. "): " or ": "), subColor(message))
			SysLog("CONSOLE (" .. color .. entity .. "$9 %s) $1" .. subColor(message), (toPlayer and "to " .. toPlayer or ""))
		end
	end,
	-------------
	GetCaseData = function(self, case)
		local data = self.logTypes[case];
		if (data) then
			return data[2], data[1], data[3], data[4];
		end;
	end,
	-------------
	CheckServerLog = function(self)
	
		local iSize, iGrowth, sGrowth
		local aCrytekLogs = {
			ATOM.ServerRootDir .. "Server.log",
		}

		local fLogger = PuttyLog
		
		fLogger("$1CryTek trash: (Retirement Home: $4%s$1)", ByteSuffix(DirGetSize(ATOM.ServerRootDir .. "LogBackups")))
		for i, sFile in pairs(aCrytekLogs) do
		
			--------
			iSize = FileGetSize(sFile)
			iGrowth = (iSize - checkNumber(CRYTEK_LOG_FILES_SIZE[i], 0))
			sGrowth = string.format("+$4%s$1 ", string.rspace(ByteSuffix(iGrowth), 9))
			
			--------
			fLogger("$1	-> [%02d] $4%s$1 (%s%s)", i, string.rspace(ByteSuffix(iSize), 9), sGrowth, FileGetNameEx(sFile))
			
			--------
			CRYTEK_LOG_FILES_SIZE[i] = iSize
		end
		
		fLogger("$1ATOM trash: (Retirement Home: $4%s$1)", ByteSuffix(DirGetSize(self.logFilePathRetiredRelative)))
		for i, v in pairs(OPEN_LOG_FILES) do
		
			--------
			iSize = FileGetSize(v)
			iGrowth = (iSize - checkNumber(LOG_FILES_SIZE[i], 0))
			sGrowth = string.format("+$4%s$1 ", string.rspace(ByteSuffix(iGrowth), 9))
			
			--------
			fLogger("$1	-> [%02d] $4%s$1 (%s%s)", i, string.rspace(ByteSuffix(iSize), 9), sGrowth, self.logFiles[i])
			
			--------
			LOG_FILES_SIZE[i] = iSize
		end
	
		if (self.cfg.UseAutoVerbosity) then
			if (g_game:GetPlayerCount() < 1) then
				if (not OLD_LOG_VERB) then
					OLD_LOG_VERB = tostr(System.GetCVar("log_verbosity"))
					System.SetCVar("log_verbosity", "0");
			--		Debug("Zero")
				end;
			elseif (OLD_LOG_VERB) then
				System.SetCVar("log_verbosity", OLD_LOG_VERB);
			--	Debug("Restoreed")
				OLD_LOG_VERB = nil;
			end;
		end;
	

		local file, err = io.open(ATOM.ServerRootDir.."Server.log", "r");
		if (not file or err) then
			self:LogError("Can't open Server.log for checking size");
			return;
		end;

		local size = file:seek("end");
		
		if (not _LAST_LOG_SIZE_GROWTH or _time - _LAST_LOG_SIZE_GROWTH > (60 * 60 * 1)) then
			_LAST_LOG_SIZE_GROWTH = _time;
			LOG_GROWTH = 0;
		elseif (LAST_LOG_SIZE) then
			LOG_GROWTH = (LOG_GROWTH or 0) + (size - LAST_LOG_SIZE)
		end;
		
		self.logSize = size;
		LAST_LOG_SIZE = size;
		
		file:close();
		local max = ONE_MB * self.cfg.MaxLogSize;
		if (size > max and self.cfg.RetireLog) then
			self:RetireServerLog();
		elseif (self.verb >= 2) then
			SysLog("Log Size (%fMB / %fMB)", size / ONE_MB, self.cfg.MaxLogSize);
		end;
		
		SysLogVerb(1, "Log grew by %0.4fMB in the last hour", LOG_GROWTH / ONE_MB);
		if (LOG_GROWTH > 5) then
			SendMsg(CHAT_WARNING, ADMINISTRATOR, "Log Growth above 5MB (%0.2fMB)", LOG_GROWTH / ONE_MB);
		end;
		

	end,
	-------------
	RetireServerLog = function(self)

		LOG_RETIREMENTS = (LOG_RETIREMENTS or 0) + 1;

		local serverRootDir = ATOM.ServerRootDir;

		local version = "6156";
		local newName = "Server Build("..version..") "..os.date("Date(%d %b %Y) Time(%H %M %S)").." - Retired.log";
		local oldLog, err = io.open(serverRootDir.."Server.log", "r");
		local newLog, err = io.open(serverRootDir.."LogBackups/"..newName, "w");
		if (not oldLog or not newLog or err) then
			self:LogError("Can't open files for log retiring");
			return;
		end;

		SysLog("Retiring Server log (exceeded maximum Size (%fMB > %fMB))", self.logSize/ONE_MB, self.cfg.MaxLogSize);
		for line in oldLog:lines() do
			newLog:write(line);
			newLog:write("\n");
		end;
		oldLog:close();
		newLog:close();
		Debug(serverRootDir.."Server.log")
		local oldLog2, err = io.open(serverRootDir.."Server.log", "w");
		if (not oldLog2 or err) then
			self:LogError("Can't open Server.log for retiring (%s)", (err or "null"));
			return;
		end;
		oldLog2:write("*********************************************************************************************************************\n");
		oldLog2:write("<ATOM> : Log Retired as " .. newName .. "\n");
		oldLog2:write("*********************************************************************************************************************\n");
		oldLog2:close();
		
		if (LOG_RETIREMENTS > 15) then
			SysLog("Warning: already %d Log retirements, please consider checking for spammy messages. (max size = %fbytes)", LOG_RETIREMENTS, self.cfg.MaxLogSize * ONE_MB);
		end;

	end,
	-------------
};


ATOMLog:Init();