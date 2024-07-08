NULL_ENT = { id = NULL_ENTITY };
IP_DB = IP_DB or {};
LOGGED_DISCONNECTS = LOGGED_DISCONNECTS or {};
LOGGED_CONNECTIONS = LOGGED_CONNECTIONS or {};
-- test test 21
ATOM_SysLog = function(sMessage, ...)

	---------
	local sMsg = sMessage
	if (#{...} > 0) then
		sMsg = string.format(sMessage, ...) end

	---------
	if (string.find(sMsg, "\n")) then
		for i, sLine in pairs(string.split(sMsg, "\n")) do
			System.LogAlways("<ATOM> : " .. sLine)
		end
	else
		System.LogAlways("<ATOM> : " .. sMsg)
	end

	---------
	if (ATOMLog ~= nil) then
		ATOMLog:LogToLogFile(LOG_FILE_SYSTEM, sMsg) end
end;
ATOM_SysLogVerb = function(iVerb, ...)

	---------
	if (System.GetCVar("log_Verbosity") >= iVerb) then
		ATOM_SysLog(...)
	end
end;
SysLog = ATOM_SysLog
SysLogVerb = ATOM_SysLogVerb

GetEntity = function(idEntity)

	-------------
	local hEntity
	if (type(idEntity) == "table") then
		hEntity = System.GetEntity(idEntity.id)
		elseif (type(idEntity) == "userdata" or type(idEntity) == "number") then
			hEntity = System.GetEntity(idEntity)
			elseif (type(idEntity) == "string") then
				hEntity = System.GetEntityByName(idEntity)
				elseif (type(idEntity) == "function") then
					hEntity = idEntity() end
					
	-------------
	if (hEntity and type(hEntity) == "table" and hEntity.id) then
		return hEntity end
	
	-------------
	return
end

EntityName = function(idEntity)

	-------------
	local hEntity = GetEntity(idEntity)
	if (hEntity) then
		return hEntity:GetName() end

	-------------
	return ""
end

local eTID_Frame = 0
local eTID_Second = 1
local eTID_Minute = 2
local eTID_10Mins = 3
local eTID_Unknown = 4
local eTID_Hour = 5

ATOM = {
	loadedFiles = { Plugins = { }, Commands = { }, Includes = { } },
	initialized = (ATOM~=nil and ATOM.initialized~=nil) and ATOM.initialized or false;
	gameStarted = (ATOM~=nil and ATOM.gameStarted~=nil) and ATOM.gameStarted or false;
	channelIPs  = (ATOM~=nil and ATOM.channelIPs~=nil)  and ATOM.channelIPs  or {   };
	channelCCs	= (ATOM~=nil and ATOM.channelCCs~=nil)  and ATOM.channelCCs  or {   };
	activeConnections	= (ATOM~=nil and ATOM.activeConnections~=nil)  and ATOM.activeConnections  or {   };
	RESTART_QUENED = (ATOM~=nil and  ATOM.RESTART_QUENED~=nil) and ATOM.RESTART_QUENED;
	IP_DB = (ATOM~=nil and ATOM.IP_DB~=nil) and ATOM.IP_DB or nil;
	--------------
	GrenadeMap = { },
	PostInits = { },
	AfterInits = { },
	AutoSaveFiles = (ATOM and ATOM.AutoSaveFiles or {}),
	--------------
	cfg = {
		MapConfig = {};
		--------------
		GamePlayConfig = {
		};
		--------------
		AISystem = false; -- doesn't work for now
		--------------
		LogVerbosity = 0;
		--------------
		PluginConfig = {};
		--------------
		CommandConfig = {};
		--------------
		IncludesConfig = {};
		--------------
		MapSetup = {};
		--------------
		CalculateScriptRAM = true;
		--------------
		GlobalData = false;
		--------------
		Connection = {
			LogWhenProfileReceived = true; -- log player connect when profile was received
			--------------
			ChatMessage 		   = {
				SendMessage = true,
				Access		= 3, -- Admin
			};
		};
		--------------
		Server = {
			ServerDescription = "New Server running TysonSSM - ATOM 0.0a";
			DynamicName		  = false;
			UseModName = false;
			ModInfo = {
				Name = "ATOM ~ ka digga";
				Version = "1.0.0";
			};
		};
		--------------
		HidePings = false;
		--------------
		PingMultiplier = 1;
		--------------
		DamageConfig = {
		
			FallDamage = 0.1,
			DamageMultipliers = {
				['GaussRifle'] = 1.0
			};
			
		};
	};
	--------------
	scriptRAM = {};
	--------------
	LoadedScripts = (ATOM~=nil and ATOM.LoadedScripts~=nil)  and ATOM.LoadedScripts  or {   };
	--------------
	coreFiles = { -- core files with load order
		"ATOM-Utilities";
		"ATOM-Broadcaster";
		"ATOM-Logging";
		"ATOM-Usergroups";
		"ATOM-PlayerUtilities";
	};
	--------------
	Server = NULL_ENT; -- ?
	--------------
	modFiles = {
		"ATOM-GameUtilities";
		"ATOM-Chat";
		"ATOM-FeatureHandler";
		"ATOM-CmdArchiver";
		"ATOM-Punish";
		"ATOM-NameSystem";
		"ATOM-CommandSystem";
		--"ATOM-BasicCommands";
		"ATOM-Defense";
		"ATOM-PermaScore";
		"ATOM-Equipment";
		"ATOM-Patcher";
		"ATOM-Setup";
		"ATOM-Vehicles";
		"ATOM-Report";
		"ATOM-Buying";
		"ATOM-AFKManager";
		"ATOM-Statistics";
		"ATOM-PlayerPreferences";
		"ATOM-Aliases";
		"ATOM-Jail";
		"ATOM-Boxing",
		"ATOM-FootBall",
		"ATOM-Voting"
	};
	--------------
	gameData = {
		"ATOM-GameRules";
		"ATOM-Item";
		"ATOM-Actor";
		"ATOM-HQ";
	};
	--------------
	modPlugins       = nil; -- created by AddPlugins
	--------------
	serverPlugins    = nil; -- created by AddPlugins
	--------------
	ServerRootDir    = nil;
	RootDir    		 = ATOM~=nil and ATOM.RootDir or nil; -- set by DLL
	ModDir   	     = nil; -- set later in OnInit
	ScriptDir		 = nil;
	GloablFileDir	 = nil; -- shared between all servers
	LocalFileDir 	 = nil; -- only for this server
	ServerPluginsDir = nil;
	GameDataDir		 = nil;
	SetupDir		 = nil; -- map setups
	--------------
	waitingForProfiles = {};
	--------------
	ticks = {
		[1] = {	3, 		3,	 "OnMidTick" };
		[2] = {	0.5, 	0.5, "QTick" };
	};
	--------------
	GetRelativeServerFolder = function(self, sPath)
		-- local sServerFolderName = self.ServerFolderName or string.match(self.ServerRootDir, ".*\\(.*)") or string.match(self.ServerRootDir, ".*/(.*)")
		-- return sServerFolderName .. string.gsub(sPath, string.escape(self.ServerRootDir)or"", "")
		
		---------
		local sRootFolder = self.ServerRootDir
		
		---------
		local sServerFolder
		sServerFolder = string.ridtrailex(sRootFolder, "/", "\\")
		sServerFolder = string.matchex(sServerFolder, ".*\\(.*)", ".*/(.*)")
		
		---------
		local sRelativeFolder
		sRelativeFolder = string.gsub(sPath, string.escape(sRootFolder), "")
		sRelativeFolder = sServerFolder .. "/" .. sRelativeFolder
		
		---------
		-- SysLog("Root Folder: %s", self.ServerRootDir)
		-- SysLog("Server Folder: %s", sServerFolder)
		-- SysLog("Folder: %s", sPath)
		-- SysLog("Relative: %s", sRelativeFolder)
		
		return string.ridtrailex(sRelativeFolder, "/", "\\")
	end,
	--------------
	OnTimer = function(self, timerId, player)
	
		-----------
		if (timerId == eTID_Frame) then
			
			local last = LAST_UPDATE_TIME
			if (last) then
				self.FrameTime = (timerdiff(last))
				self.FrameRate = (1 / timerdiff(last))
				
				-- SysLog("Rate: %f, FPS: %0.2f", self.FrameTime, self.FrameRate)
			end
			LAST_UPDATE_TIME = timerinit()
			g_gameRules:PostUpdate(System.GetFrameTime())
			
		end
		
		-----------
		if (self.error) then
			return end
			
		-----------
		if (self.initialized and ATOMBroadCaster ~= nil) then
		
			if (timerId == eTID_Frame) then -- frame

				--SysLog("Update")

				-----------
				if (g_utils) then
					g_utils:Update() end
				
				-----------
				ATOMBroadcastEvent("OnUpdate",   System.GetFrameTime())
				
				-----------
				for i, tick in pairs(self.ticks) do
					if (_time - tick[1] >= tick[2]) then
						tick[1] = _time;
						ATOMBroadcastEvent(tick[3], System.GetFrameTime());
						g_utils:Timer(tick[3]);
					end;
				end;
				
				-----------
				if (ATOMChat) then
					ATOMChat:UpdateQuene() end
					
				-----------
				if (RCA and CLIENT_MOD) then
					RCA:UpdateQuene() end
				
			elseif (timerId == eTID_Second) then 
			
				-----------
				-- g_utils:OnTick()
			
				-----------
				local hPlayer
				for idPlayer, aQuene in pairs(self.waitingForProfiles) do
					hPlayer = System.GetEntity(idPlayer);
					if (hPlayer and not hPlayer.connectionLogged) then
						if (aQuene and _time - aQuene.time >= 5) then
							self:InitPlayer(hPlayer)
							ATOMLog:LogConnect(hPlayer)
							self.waitingForProfiles[idPlayer] = nil
							ATOM_Usergroups:CheckProtectedName(hPlayer)
						end;
					else
						self.waitingForProfiles[idPlayer] = nil
					end
				end
				
				-----------
				if (g_gameRules and g_gameRules.HandlePings) then
					g_gameRules:Tick()
					g_gameRules:HandlePings()
					g_gameRules:CheckPerimeter() end
				
				-----------
				ATOMPunish:OnMidTick()
				ATOMChat:OnTick()
				g_utils:OnTick()
				
				-----------
				ATOMBroadcastEvent("OnTick",     System.GetFrameTime())
				
				-----------
				if (self.ServerActor) then
					self.ServerActor:SetPos(self.ServerActor.spawnPosition) end
				
			elseif (timerId == eTID_Minute) then -- minute;

				-----------
				if (isNumber(self.TotalDamage)) then
					--Debug("Add self.TotalDamage", self.TotalDamage)
					g_statistics:AddToValue('DamageDealt', self.TotalDamage)
					self.TotalDamage = 0
				end
				if (isNumber(self.ShotsFired)) then
					--Debug("Add self.ShotsFired", self.ShotsFired)
					g_statistics:AddToValue('BulletsFired', self.ShotsFired)
					self.ShotsFired = 0
				end
				if (isNumber(self.HitsLanded)) then
					--Debug("Add self.HitsLanded", self.HitsLanded)
					g_statistics:AddToValue('HitsLanded', self.HitsLanded)
					self.HitsLanded = 0
				end
				self:CheckServerName()
				ATOMBroadcastEvent("OnMinTimer", System.GetFrameTime())
				
			elseif (timerId == eTID_10Mins) then -- 10 minutes;
			
				-----------
				ATOMBroadcastEvent("OnSeqTimer", System.GetFrameTime())
				
			elseif (timerId == eTID_Unknown) then
				ATOMStats:OnTick(player)
				
			elseif (timerId == eTID_Hour) then
				if (g_game:GetPlayerCount() < 1 and table.count((self.activeConnections or {})) == 0) then -- Only check logs if there are no players online to prevent lagspikes
					self:LogStatus() 
					--ATOMLog:CheckServerLog()
				end
			end
		end
		
	end;
	--------------
	LogStatus = function(self)
		local fCPUTotal   = g_dll:GetTotalCPU()
		local fCPUCurrent = g_dll:GetProcessCPU()
		local iRAMTotal   = g_dll:GetTotalRAM()
		local iRAMCurrent = g_dll:GetProcessRAM()
		local iSystemTime = g_dll:GetSystemTime()

		local fLogger = PuttyLog
		fLogger("$1Status: CPU: $4%0.2f%%$1 ($4%0.2f%%$1), RAM: $8%s $1($8%s$1), System Running for $4%s",
			fCPUCurrent,
			fCPUTotal,
			ByteSuffix(iRAMCurrent),
			ByteSuffix(iRAMTotal),
			SimpleCalcTime(iSystemTime)
		)
		fLogger("FrameTime: $4%fs$1, FrameRate: $4%0.2f FPS$1", (self.FrameTime or 0.0), (self.FrameRate or 0.0))
	end,
	--------------
	NeedsBinding = function(self, projectieClass, w, p)
		local RF = w and w.RapidFire or false;
		local bindThis = {
			["c4explosive"] = true,
			["tank125"] = true,
			["helicoptermissile"] = true,
			["a2ahomingmissile"] = true,
			["tacprojectile"] = true,
		};
		return projectieClass == "rocket" or (RF ~= false and bindThis[projectieClass] == true) or w.weapon:IsServerShoot();
	end;
	--------------
	HookGameRules = function()
		
		function g_gameRules:Reset(forcePregame)
			SysLog("********************* RESETING GAME")
			ATOM.HookGameRules()
			ATOM.GameEnd = false
			self:ResetTime()
			
			self:GotoState("InGame")
			self.forceInGame = nil
			self.works = {}
			
			ATOM:OnGameReset()
		end
		
		function g_gameRules:RestartGame(forceInGame)
		
			SysLog("********************* RESETING GAME")
			ATOM.HookGameRules()
			ATOM.GameEnd = false
			
			self:GotoState("Reset")
			self.game:ResetEntities()
			self.forceInGame = true
			
			SysLog("Game Restarting ...")
			if (ATOMChat) then
				ATOMChat:ResetEntities()
			end
			
		end
	end;
	--------------
	OnGameReset = function(self)
		NEW_MAP = true;
		SysLog("ATOM::OnGameReset Calling OnGameRestart Now");
		self:OnGameRestart()
		
	end;
	--------------
	OnGameRestart = function(self)
	
		_START_ANNOUNCED = false
		SysLog("Game Reset.")
		if (g_gameRules:GetState() ~= "PreGame") then
			Script.SetTimer(100, function()
				_RESTART = true;
				self:OnInit()
				SysLog("ATOM Game Init")
				if (ATOMBroadCaster ~= nil) then
					ATOMBroadcastEvent("OnMapRestart", self:GetMapName(), self:GetMapName(true))
				end
			end)
		end
	end;
	--------------
	OnGameStart = function(self, reload)
		
		----------
		if (NEW_MAP == nil) then
			NEW_MAP = true
		end
		
		----------
		local hStart = (timerinit and timerinit() or os.clock())
		--SysLog("OnGameRestart (%0.2fs)", (os.clock() - hStart))
		
		----------
		self.HookGameRules()
		
		----------
		--SysLog("OnInit (%0.2fs)", (os.clock() - hStart))
		self:OnInit()
		--SysLog("OnInitComplete (%0.2fs)", timerdiff(hStart))
		
		----------
		local sMapName, sMapNameShort = self:GetMapName(), self:GetMapName(true)
		if (NEW_MAP) then
			--SysLog("-> New Map Detected")
			
			if (ATOMBroadCaster ~= nil) then
				ATOMBroadcastEvent("OnMapStart", sMapName, sMapNameShort)
				ATOMBroadcastEvent("OnMapRestart", sMapName, sMapNameShort)
			end
			
			self:CheckServerName()
			MapStartTime = _time
		end
		
		----------
		if (_REBOOT or NEW_MAP) then
			if (ATOMSetup ~=nil) then
				ATOMSetup:OnMapStart(sMapNameShort, sMapName)
			end
		end
		
		----------
		--SysLog("Checking Mod Data (%0.2fs)", timerdiff(hStart))
		self:CheckModName()
		self:CheckPAK()
		self:CheckPlayerLimit()
		self:CheckServerReportInfo()
		self:CheckCVars()
		--SysLog("Mod Data Checked (%0.2fs)", timerdiff(hStart))
		
		----------
		_REBOOT = false
		_RESTART = false
		
		----------
		--SysLog("Game Restart Complete (%0.2fs)", timerdiff(hStart))
		
		----------
		local sState = (g_gameRules and g_gameRules:GetState() or nil)
		if (sState and sState ~= "InGame") then
		
			SysLog("Skipping Pre-Game (Current: %s)", sState)
			if (self.cfg.SkipPreGame) then
				Script.SetTimer(100, function()
					g_gameRules:GotoState("InGame")
					--SysLog("Skipped Pre-Game (%0.2fs, Current State: %s)", timerdiff(hStart), g_gameRules:GetState())
				end)
			end
		end
		
		----------
		NEW_MAP = false
		self:CheckMapLink()
		self:InitServerEntity()
		
		----------
		SysLog("System initialized in %0.2fs", timerdiff(hStart))
		return true
	end;
	--------------
	CheckMapLink = function(self)

		local hFile, sErr = io.open("mods/atom/maplinks.txt")
		if (not hFile) then
			return ATOMLog:LogError(sErr)
		end

		local sMap = g_dll:GetMapName()
		local sRules, sMapShort
		local sLink
		local iLinks = 0
		local iPS, iIA, iOther = 0, 0, 0

		for sLine in hFile:lines() do

			sRules, sMapShort = string.match(sLine, "/(.*)/(.*)(%s+)")
			if (string.match(string.lower(sLine), "^" .. string.lower(sMap) .. "(%S?)")) then
				sLink = string.sub(sLine, (string.len(sMap) + 1))
				sLink = string.ridtrail(sLink, "(%s+)", 1)
				sLink = string.ridlead(sLink, "(%s+)", 1)

				if (string.empty(sLink)) then
					ATOMLog:LogGameUtil("Empty link found for Map %s", (sMapShort or sLine))
					SysLog("Empty link found for Map %s", (sMapShort or sLine))
					sLink = nil
				end
			end

			if (not string.empty(sLine)) then
				iLinks = iLinks + 1
			end

			if (string.match(string.lower(sLine), "^multiplayer/ps/(.*)(%s+)(.*)")) then
				iPS = iPS + 1
			elseif (string.match(string.lower(sLine), "^multiplayer/ia/(.*)(%s+)(.*)")) then
				iIA = iIA + 1
			elseif (not string.empty(sLine)) then
				iOther = iOther + 1
				ATOMLog:LogGameUtil("Link for Map %s has Invalid Game Rules (%s)", sLine, (sRules or string.UNKNOWN))
				SysLog("Link for Map %s has Invalid Game Rules (%s)", sLine, (sRules or string.UNKNOWN))
			end
		end

		ATOMLog:LogGameUtil("Found %d Map Links (PS: %d, IA: %d, Others: %d)", iLinks, iPS, iIA, iOther)
		SysLog("Found %d Map Links (PowerStruggle: %d, InstantAction: %d, Others: %d)", iLinks, iPS, iIA, iOther)
		sRules, sMapShort = string.match(sMap, "/(.*)/(.*)$")

		if (sLink) then
			ATOMLog:LogGameUtil("Found Map link for Map %s (%s)", sMapShort, sRules)
			SysLog("Found Map link for Map %s (%s, (%s))", sMapShort, sRules, sLink)
		else
			ATOMLog:LogGameUtil("No Map link was found for Map %s (%s)", sMapShort, sRules)
			SysLog("No Map link was found for Map %s (%s)", sMapShort, sRules)
		end
	end,
	--------------
	CheckPlayerLimit = function(self)
		local cfg = self.cfg.Server;
		if (cfg) then
			if (cfg.MaxPlayers) then
				System.SetCVar("sv_maxplayers", cfg.MaxPlayers) end
				
			self.cfg.DynamicMaxPlayers = cfg.DynamicMaxPlayers
			NO_PLAYER_LIMIT = checkVar(cfg.NoPlayerLimit, false)
		end
	end;
	--------------
	CheckModName = function(self)
		local cfg = self.cfg.Server;
		if (cfg) then
			if (cfg.UseModName) then
				local modInfo = cfg.ModInfo;
				if (modInfo.Name and modInfo.Version) then
					ATOMDLL:SetModInfo(modInfo.Name, modInfo.Version);
					--self:Log(0, formatString("Setting Mod Name to %s (%s)", modInfo.Name, modInfo.Version));
				end;
			end;
		end;
	end;
	--------------
	CheckPAK = function(self)
		local cfg = self.cfg.Server;
		if (cfg and cfg.UsePAK) then
			local pak_info = cfg.ClientPAK;
			if (pak_info.Link and string.len(pak_info.Link) > 0) then
				local currentLink = System.GetCVar("atom_client_pak");
				if (currentLink == "" or currentLink ~= pak_info.Link) then
					System.SetCVar("atom_client_pak", tostring(pak_info.Link));
					SysLog("Client Pak = %s", pak_info.Link);
				end;
			end;
		else
			System.SetCVar("atom_client_pak", "");
		end;
	end;
	--------------
	CheckCVars = function(self)
		local cfg = self.cfg.Server;
		if (cfg) then
			if (cfg.CVars) then
				for cvar, value in pairs(cfg.CVars) do
					ATOMDLL:ForceSetCVar(cvar, tostr(value));
				end;
				if (arrSize(cfg.CVars) > 0) then
					SysLog("Force changed %d CVars", arrSize(cfg.CVars));
				end;
			end;
		end;
	end,
	--------------
	CheckServerReportInfo = function(self)
		local cfg = self.cfg.Server;
		if (cfg) then
			if (cfg.UseReportInfo) then
				local repInfo = cfg.ServerReport;
				if (repInfo.MapName) then
					System.SetCVar("atom_svreport_mapName", tostring(repInfo.MapName));
				end;
				if (repInfo.OSStream) then
					System.SetCVar("atom_svreport_players", tostring(repInfo.OSStream));
				end;
				if (repInfo.ReportDelay) then
					System.SetCVar("a_sv_reportdelay", tostring(repInfo.ReportDelay));
				end;
				if (repInfo.MaxPlayers) then
					System.SetCVar("atom_svreport_maxpl", tostring(repInfo.MaxPlayers));
				end;
				if (repInfo.Players) then
					System.SetCVar("atom_svreport_numpl", tostring(repInfo.Players));
				end;
				if (repInfo.TimeLimit) then
					System.SetCVar("atom_svreport_remTime", tostring(repInfo.TimeLimit));
				end;
			end; --HideOnEmptyServer
			
			if (cfg.DynamicInfo) then
				local svInfo = cfg.ReportInfo;
				if ( svInfo ) then
					if ( svInfo.GameVer ) then
						System.SetCVar("atom_svreport_gamever", tostring(svInfo.GameVer));
						SysLog("Game Version: %s", System.GetCVar("atom_svreport_gamever"));
					end;
					if ( svInfo.GameType ) then
						local mapName = self:GetMapName(true);
						local g_type = svInfo.GameType:gsub("$MAPNAME", mapName);
						System.SetCVar("atom_svreport_gametype", g_type);
						SysLog("Game Type: %s", System.GetCVar("atom_svreport_gametype"));
					end;
				end;
			end;
		end;
		
		
	end;
	--------------
	CheckServerName = function(self)
		local cfg = self.cfg.Server;
		if (cfg) then
		
			local description = cfg.ServerDescription;
			if (not self.OLD_DESC) then
				self.OLD_DESC = description
			end
			local description_modified = self.OLD_DESC or ""; --description;
			local aReplacers = {
				["%$CHAT"] = function()
					return (fmtNum(g_statistics:GetValue("ChatTotal") / 1, 1) .. "") end,
				
				-----------
				["%$KILL"] = function()
					return (fmtNum(g_statistics:GetValue("KillsTotal") / 1, 1) .. "") end,
				
				-----------
				["%$DEATH"] = function()
					return (fmtNum(g_statistics:GetValue("DeathsTotal") / 1, 1) .. "") end,
				
				-----------
				
				["%$HITS"] = function()
					return (fmtNum(g_statistics:GetValue("HitsLanded") / 1, 1) .. "") end,
				
				-----------
				["%$DMG"] = function()
					return (fmtNum(g_statistics:GetValue("DamageDealt") / 1, 1)) end,
				
				-----------
				["%$BULLET"] = function()
					return (fmtNum(g_statistics:GetValue("BulletsFired") / 1, 1) .. "") end,
				
				-----------
				
				["%$MWALKED"] = function()
					return (fmtNum(g_statistics:GetValue("MetersWalked"), 1, true) .. "") end,
				
				-----------
				["%$MDRIVEN"] = function()
					return (fmtNum(g_statistics:GetValue("MetersDriven"), 1, true) .. "") end,
				
				-----------
				
				["%$DESKTOP"] = function()
					return self:RandomDesktop() end,
				
				-----------
				["%$SLOT"] = function()
					return (HIGHEST_SLOT or 0) end,
				
				-----------
				["%$TOTAL"] = function()
					return (HIGHEST_SLOT or 0) end,
				
				-----------
				["%$CURRENT"] = function()
					return arrSize(GetPlayers()) end,
				
				-----------
				["%$RANDOM_NUMBER"] = function()
					return math.random(1, 100) end,
				
				-----------
				["%$NEXT_LEVEL"] = function()
					if (NEXT_LEVEL and NEXT_LEVEL ~= "") then
						local l, r = NEXT_LEVEL:sub(16), g_utils:ParseRules(NEXT_LEVEL)
						return l .. " (" .. r .. ")"
					end
					return string.UNKNOWN
				end,
				
				-----------
				["%$MAXIMUM"] = function()
					return (g_statistics:GetValue("Maximum")or 0) end,
				
				-----------
				["%$PLAYER_ALL_TIME"] = function()
					return (g_statistics:GetValue("PlayerTotal")or 0) end,
				
				-----------
				["%$TIME_PLAYER"] = function()
					return SimpleCalcTime(g_statistics:GetValue("TimeTotal")) end,
				
				-----------
				["%$TIME_SERVER"] = function()
					return SimpleCalcTime(g_statistics:GetValue("Runtime")) end,
				
				-----------
				["%$RUNTIME_SESSION"] = function()
					return SimpleCalcTime(_G["_time"]) end,
				
				
			};
			for i, v in pairs(aReplacers) do
				if (v()) then
					description_modified = description_modified:gsub(i, v());
				end;
				--Debug("i=",v())
			end;
			--Debug(description)
			--Debug(description_modified)
			--if (description_modified ~= description) then
			if (not DESC_MODIFIED) then
				--SysLog("Desc changed.")
				self.cfg.Server.ServerDescription = description_modified;
			end;
			--Debug("MODIFIED UWU")
			--end;
		
			--SysLog("Server Description: %s", self.cfg.Server.ServerDescription)
		
			if (DYNAMIC_SERVER_NAME == false) then
				return;
			end;
			if (cfg.DynamicName) then
				--local mapName
				System.SetCVar("sv_servername", "ATOM ~ " .. makeCapital(self:GetMapName(true)) .. " (" .. (HIGHEST_SLOT or 0) .. ")");
			elseif (cfg.ServerName) then
				local name = cfg.ServerName;
				if (name:find("%%")) then
					name = formatString(name, self:RandomDesktop());
				end;
				local r = {
					["%$DESKTOP"] = function()return self:RandomDesktop()end,
					["%$SLOT"] = function()return HIGHEST_SLOT or 0;end,
					["%$MAP"] = function()return makeCapital(self:GetMapName(true));end,
				};
				for i, v in pairs(r) do
					--Debug("i=",v())
					if (v()) then
						name = name:gsub(i, v());
					end;
				end;
				System.SetCVar("sv_servername", name);
			end;
		end;
	end;
	--------------
	RandomDesktop = function(self)
		local Alpha = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 }
		local desktop = "";
		for i = 1, 8 do
			desktop = desktop .. Alpha[math.random(arrSize(Alpha))];
		end;
		return desktop;
	end;
	--------------
	GetMapName = function(self, short)
		local map, rules = ATOMDLL:GetMapName(), ATOMDLL:GetMapName():lower():match("multiplayer/(.*)/(.*)");
		if (short) then
			rules, map = map:match("Multiplayer/(.*)/(.*)");
		end;
		return map, rules;
	end;
	--------------
	GetPlayerStream = function(self)
	
		---------
		local sStream = "";
		local name, rank, kills, deaths, profileId, teamId;
		local getValue = g_game.GetSynchedEntityValue;
		local cfg = self.cfg.Server;
		local ReportCfg = cfg.ServerReport;
		
		---------
		-- collect entities
		local aPlayers = g_game:GetPlayers() or {}
		local aExtraEnts = {}
		
		---------
		-- add other classes if needed..
		if (cfg and cfg.UseReportInfo and cfg.ServerReport.Report) then
			for _, sClass in pairs(cfg.ServerReport.Report or {}) do
				aExtraEnts = checkVar(System.GetEntitiesByClass(sClass), {})
				
				for __, ent in pairs(aExtraEnts) do
					if (sClass ~= "Player" or not v.actor:IsPlayer()) then
						table.insert(aPlayers, ent) end end

				local iExtra = table.count(aExtraEnts)
				if (iExtra > 0) then
					SysLog("Adding %d entities of class %s to Server-Report", iExtra, sClass)
				end
			end
		end
		
		---------
		local cc;
		local iTimestamp = atommath:Get("timestamp")
		for i, v in pairs(aPlayers or{}) do
		
			-- the profile of the player
			local sProfile = checkFunc(v.GetProfile, "0", v)
		
			-- °.°*. special tags for special players <3 .*°.°
			local sTag = checkVar(ReportCfg.ProfileTags, {})[sProfile]
			
			-- cheater tag
			--Debug("v.perfs.flaggedCount",v.perfs.flaggedCount)
			--Debug("v.perfs.flaggedTime",v.perfs.flaggedTime)
			--Debug("math_sub(iTimestamp, v.perfs.flaggedTime)",math_sub(iTimestamp, v.perfs.flaggedTime))
			if (not sTag and v.perfs and v.perfs.flaggedTime and v.perfs.flaggedCount > 6) then
				if (math_sub(iTimestamp, v.perfs.flaggedTime) < (ONE_DAY * 1)) then
					sTag = "(FLAGGED) "
					--Debug("Cheater")
				end
			end
		
			-- do not report players with this tag
			if (not v.AssHidden) then
				-- collect required info
				cc			= v:GetCountryCode()
				name 		= v:GetName()
				name		= (sTag or v.Timeouting and "(TIMEOUT) " or v:IsSpectating() and "(SPEC) " or v:IsSpectating() and "(DEAD) " or v:IsAFK() and "" or "(" .. (cc and (cc .. ", ") or "") .. v:GetPing() .. "ms) ") .. name
				rank 		= checkNumber(getValue(g_game, v.id, 202), 1)
				kills 		= checkNumber(getValue(g_game, v.id, 100), 0)
				deaths 		= checkNumber(getValue(g_game, v.id, 101), 0)
				profileId 	= sProfile
				teamId		= checkNumber(g_game:GetTeam(v.id), 0)
				
				-- this is what player entry must look like
				-- osstream << '@' << name << '%' << rank << '%' << kills << '%' << deaths << '%' << (profileId ? profileId : "0");
				sStream = formatString("%s@%s%%%d%%%d%%%d%%%s%%%d", sStream, name, rank, kills, deaths, profileId, teamId)
			end
		end
		
		---------
		local sExtraStream = ""
		local aStreamTable = ReportCfg.OSStreamArray
		if (ReportCfg.UseArray and isArray(aStreamTable) and (not ReportCfg.HideOnEmptyServer or g_game:GetPlayerCount() >= 1)) then
			for i, aPlayer in pairs(aStreamTable) do
				local sRandomCountry = getrandom({"BD", "RU", "DE", "ML", "MK", "SE", "IE", "LK", "HK", "MN", "MH", "NE"})
				local iRandomNumber = getrandom(10, 300)
				
				local sName = aPlayer.Name
				sName = string.gsub(sName, "%${country_random}", sRandomCountry)
				sName = string.gsub(sName, "%${number_random}", iRandomNumber)
				
				local iKills = aPlayer.Kills
				if (iKills == RANDOM_NUMBER) then
					iKills = getrandom(1, 100) end
				
				local iDeaths = aPlayer.Deaths
				if (iDeaths == RANDOM_NUMBER) then
					iDeaths = getrandom(1, 100) end
				
				local iRank = checkNumber(aPlayer.Rank, RANDOM_NUMBER)
				if (iRank == RANDOM_NUMBER) then
					iRank = getrandom(1, 8) end
					
				local sProfile = checkVar(aPlayer.Profile, "-1")
				
				sExtraStream = string.format("%s@%s%%%d%%%d%%%d%%%s", sExtraStream, sName, iRank, iKills, iDeaths, sProfile);
			end
		end
		
		---------
		-- add CVar-value if nec
		sStream = formatString("%s%s%s", sStream, checkVar(System.GetCVar("atom_svreport_players"), ""), sExtraStream)
		
		---------
		-- useless check ..
		--SysLog("Player Stream: \n%s", sStream)
		
		---------
		System.SetCVar("atom_svreport_numpl", string.count(sStream, "@") + checkNumber(ReportCfg.Players, 0))
		return (sStream)
	end,
	--------------
	InitGlobals = function(self)
		OpenFileParams  = { true, nil, true }; -- commonly used parameters
		
		GetTime_S		= { true, false, false, false 	};--, false, false };
		GetTime_SM		= { true, true,  false, false 	};--, false, false };
		GetTime_SMH		= { true, true,  true,  false 	};--, false, false };
		GetTime_SMHD	= { true, true,  true,  true 	};--,  false, false };
		
		GetTime_CS		= { true, false, false, false, true 	};--, false, false };
		GetTime_CSM		= { true, true,  false, false, true 	};--, false, false };
		GetTime_CSMH	= { true, true,  true,  false, true 	};--, false, false };
		GetTime_CSMHD	= { true, true,  true,  true,  true	 	};--,  false, false };
		--GetTime_SMHDM	= { true, true,  true,  true,  true,  false };
		--GetTime_All		= { true, true,  true,  true,  true,  true  };
		
		ONE_MINUTE 	= 60;
		ONE_HOUR 	= ONE_MINUTE * 60;
		ONE_DAY 	= ONE_HOUR * 24;
		ONE_WEEK 	= ONE_DAY * 7;
	end;
	--------------
	SaveFiles = function(self)
		ATOMStats.PermaScore:SaveFile()
		ATOMStats.PersistantScore:SaveFile()
		if (ATOMLevelSystem) then
			ATOMLevelSystem:SaveFile()
		end
		if (ATOMBank) then
			ATOMBank:SaveFile()
		end
		if (ATOMEquip) then
			ATOMEquip:SaveFile()
			ATOMEquip:SaveFile2()
		end
		if (ATOMAlias) then
			ATOMAlias:SaveFile()
		end
		g_statistics:SaveFile()
		g_features:SaveFile()
		ATOM_Usergroups:SaveFile()

		for i, aProps in pairs(self.AutoSaveFiles) do
			loadstring(string.format([[
				%s(%s)
			]], aProps[1], aProps[2]))()
			--SysLog("SaveFile(%s)", aProps[1])
		end
	end;
	--------------
	Shutdown = function(self)
		System.LogAlways("SERVER SHUT DOWN!!!");
	end,
	--------------
	Reboot = function(self)
	
		--------------
		_REBOOT = true
		
		--------------
		SendMsg({CENTER, CHAT_ATOM}, ADMINISTRATOR, "(System: Reloading ...)")
		local hStart = timerinit()
		
		--------------
		System.ExecuteCommand("a_Reboot 1")
		local iTime = timerdiff(hStart)
		local iSpeed = (0.05 / iTime) * 100
		
		--------------
		Script.SetTimer(2000, function()
			SendMsg({CENTER, CHAT_ATOM}, ADMINISTRATOR, "(System: Reloaded (%0.2fs, %0.2f%%)", iTime, iSpeed)
		end)
		
		--------------
		_REBOOT = false
		return true
	end;
	--------------
	GetLuaMaxNumber = function(self)

		local iMax = 0
		local iMaxInt = 0
		local iLast, iLastInt

		--while (not string.find(tostring(iMax + 1), "e")) do
		--	iLast = iMax
		--	iMax = tonumber(iMax .. "9")
		--end

		for i = 1, 100 do

			if (not string.find(tostring(iMax + 1), "e")) then
				iLast = iMax
				iMax = tonumber(iMax .. "9")
			end


			if (iMaxInt >= 0 and not (string.find(tostring(iMaxInt + 1), "e") or string.find(string.format("%d", iMaxInt + 1), "%-"))) then
				iLastInt = iMaxInt
				iMaxInt = tonumber(iMaxInt .. "9")
			end


		end

		MAXIMUM_NUMBER = iLast
		MAXIMUM_NUMBER_FLOAT = iLast
		MAXIMUM_NUMBER_INTEGER = iLastInt
		MAXIMUM_NUMBER_DISPLAY = 999999

		return MAXIMUM_NUMBER, MAXIMUM_NUMBER_INTEGER, MAXIMUM_NUMBER_DISPLAY
	end,
	--------------
	OnInit = function(self, reload)

		--------------
		local hStart = os.clock() --timerinit()
		ATOM_INITIALIZED = false
		DEBUG_MODE = false
	
		--------------
		SysLog("Lua max number is %0.0f (Int %d, Display %d)", self:GetLuaMaxNumber())

		--------------
		g_dll = ATOMDLL
	
		--------------
		g_dll:SetTickTimeMultiplier(30 / System.GetCVar("sv_dedicatedMaxRate"))
		g_dll:SetScriptUpdateRate(15)
	
		--------------
		if (self.LoadedScripts and (#self.LoadedScripts > 0)) then
			self.LoadedScripts = {}
		end
		
		--------------
		ATOMCommands = nil
		
		--------------
		self.announcedReload = false
		self:InitGlobals()
	
		--------------
		self.ServerRootDir    	 = System.GetCVar("sys_root")
		if (self.ServerRootDir:sub(-1) ~= "/" and self.ServerRootDir:sub(-1) ~= "\\") then
			self.ServerRootDir 	 = self.ServerRootDir .. "/"
		end
		
		--------------
		self.ServerFolderName	 = string.match(self.ServerRootDir, ".*\\(.*)") or string.match(self.ServerRootDir, ".*/(.*)")
		self.ServerDir		  	 = self.ServerRootDir .. "ATOM"
		self.ModDir           	 = "Game/Scripts/ATOM"
		self.RealModDir			 = "Mods/ATOM/" .. self.ModDir
		self.ScriptDir        	 = "Scripts/ATOM"
		self.ModPluginsDir    	 = self.ModDir		.. "/Plugins"
		self.ServerPluginsDir 	 = self.ServerDir	.. "/Plugins"
		self.IncludesDir 	 	 = self.ModDir		.. "/Includes"
		self.ServerIncludesDir	 = self.ServerDir	.. "/Includes"
		self.GloablFileDir	  	 = self.ModDir		.. "/Data"
		self.LocalFileDir	   	 = self.ServerDir	.. "/Data"
		self.GameDataDir	 	 = self.ScriptDir	.. "/GameData"
		self.ModCommandsDir		 = self.ModDir		.. "/Commands"
		self.ServerCommandsDir	 = self.ServerDir	.. "/Commands"
		self.SetupDir			 = self.ModDir		.. "/Setups"

		--------------
		if (SCRIPT_INIT) then
			--SysLog("AutoSaving Script Data Files")
			local bSuccess, sError = pcall(self.SaveFiles, self)
			if (not bSuccess or sError) then
				if (ATOMLog) then
					ATOMLog:LogError(sError)
				end
				SysLog("Error while trying to save files (%s)", tostring(sError))
			end
			self.AutoSaveFiles = {}
		end
		
		--------------
		self.error = false
		local bQuit, sFile = false, nil
		
		--------------
		self:AddIncludes()
		if (not self:LoadIncludes(reload)) then
			bQuit = false
			sFile = "MOD-Includes"
		elseif (not self:LoadCoreFiles(reload)) then
			bQuit = false
			sFile = "Core"
		elseif (not self:LoadFiles(reload)) then
			bQuit = false
			sFile = "Essential"
		elseif (not self:LoadGameDataFiles(reload)) then
			bQuit = false
			sFile = "GameHooks"
		elseif (not self:LoadConfig(reload)) then
			bQuit = false
			sFile = "Config"
		elseif (not self:LoadMODPlugins(reload)) then
		--	bQuit = false
		--	sFile = "MOD-Plugin"
		elseif (not self:LoadServerPlugins(reload)) then
		--	bQuit = false
		--	sFile = "Server-Plugin"
		elseif (not self:LoadMODCommands(reload)) then
		--	bQuit = false;
		--	sFile = "MOD-Command"
		elseif (not self:LoadServerCommands(reload)) then
		--	bQuit = false
		--	sFile = "Server-Command"
		elseif (not self:LoadMapSetups(reload)) then
		--	bQuit = false
		--	sFile = "Server-Command"
		end
		
		--------------
		self:LoadIPDB()
		
		--------------
		if (bQuit or sFile) then
			local sMsg = string.format("Failed to load %s Script File%s", (sFile or "Important"), (bQuit and ", Aborting MOD Init" or ""))
			SysLog(sMsg)
			if (bQuit) then
				System.Quit()
			end;
			self.error = true
			return false, sMsg
		end
		
		--------------
		self.initialized = true
		
		--------------
		ATOMCommands:RegisterCommands()
		ATOMGameRules:Init()
		ATOMPatcher:Init()
		
		--------------
		self:CallLogFunctions()
		
		--------------
		if (ATOMBank) then
			ATOMBank:Init()
		end
		
		--------------
		if (ATOMLevelSystem) then
			ATOMLevelSystem:Init()
		end
		
		--------------
		if (ATOMItem_Init) then
			ATOMItem_Init()
		end
		
		--------------
		if (ATOMActor_Init) then
			ATOMActor_Init()
		end
		
		--------------
		if (self.cfg.AISystem or System.GetCVar("atom_aisystem") == 1) then
			ATOMDLL:ForceSetCVar("atom_aisystem", "1")
			if (NEW_MAP) then
				self:InitAI(AI_ENABLED or System.GetCVar("atom_aisystem") == 1)
			end
		end
		
		--------------
		SCRIPT_INIT = true
		
		--------------
		g_dll:SetTickTimeMultiplier(System.GetCVar("sv_dedicatedMaxRate") / 30)
		
		--------------
		if (self.cfg.CalculateScriptRAM) then
			local iTotal = collectgarbage("count")
			--SysLog("Lua Memory: %0.2fKb (%0.2fMb)", (iTotal), (iTotal / 1024))
		end
		
		--------------
		NEXT_LEVEL = g_gameRules:NextLevel(true)
		
		--------------
		PuttyLog = function(...) SysLog(...) end
		if (g_dll.PuttyLog) then
			PuttyLog = function(sPuttyMsg, ...)
				local sPuttyMsg = sPuttyMsg
				if (...) then
					sPuttyMsg = string.format(sPuttyMsg, ...)
				end

				if (not g_dll:PuttyLog(sPuttyMsg)) then
					SysLog(string.format("%s", string.gsub(sPuttyMsg, string.COLOR_CODE, "")))
				end
			end
		end
		
		--------------
		for i, aProps in pairs(self.AfterInits) do
			loadstring(string.format([[
				%s(%s)
			]], aProps[1], aProps[2]))()
		--	SysLog("OnAfterInit(%s)", aProps[1])
		end

		--------------
		ATOM_INITIALIZED = true
		PuttyLog("OnInit Took %0.5fms", timerdiff(hStart))
	end;
	--------------
	CheckEntitySpawnParameters = function(self, p)
		local isVehicle = p.class:find("US_*") or p.class:find("Asian_*") or p.class:find("Civ_*");
		if (isVehicle) then
			local oldName = p.name;
			if (oldName) then
				while(System.GetEntityByName(p.name))do
					p.name = oldName .. formatString("(%d)", g_utils:SpawnCounter());
					SysLog("[CheckEntitySpawnParameters] Fixed vehicle name: %s", p.name)
				end;
			end;
		end;
		return p
	end;
	--------------
	Quit = function(self)
		self:Log("Server quitting, disconnecting all players and saving files.");
		PuttyLog("Server Quit. Kicking all Players and saving Data.")
		for i, player in pairs(GetPlayers()or{})do
			self:OnDisconnect(player, player:GetChannel(), "Server Quit", nil, false);
			ATOMDLL:Kick(player:GetChannel(), "Server Quit");
		end;
		self:SaveFiles();
	end;
	
	--------------
	LoadIPDB = function(self)
	
		local hStart = timerinit()
		local hFile, sError = io.open(self.RealModDir .. "/Data/IPDatabase.ipdb", "r")
		if (not hFile) then
			return self:Log("Failed to open IP Database (%s)", (sError or "N/A"))
		end
	
		loadstring(hFile:read("*all"))()
		hFile:close()
	
		self:Log("Loaded ( %d ) Entries from IP Database file (Operation took %0.4fs)", table.count(IP_DB), timerdiff(hStart))
		self:SaveIPDB()
	end,
	
	--------------
	SaveIPDB = function(self)
		if (not IP_DB) then
			IP_DB = {}
			self:Log("IP Database is empty")
		end
		
		local hStart = timerinit()
		local hFile, sError = io.open(self.RealModDir .. "/Data/IPDatabase.ipdb", "w+")
		if (not hFile) then
			return self:Log("Failed to open IP Database (%s)", (sError or "N/A"))
		end
		
		hFile:write(arr2str(IP_DB, "IP_DB"))
		hFile:close()
		
		self:Log("Saved ( %d ) Entries into IP Database file (Operation took %0.4fs)", table.count(IP_DB), timerdiff(hStart))
		
	end,
	--api.db-ip.com/v2/free/
	---------
	GetCountry = function(self, ip, channel)
		--SysLog(">>>"..(tonumber(channel or 0) or 0))

		local hPlayer = g_game:GetPlayerByChannelId(channel)

		if (string.match(ip, "127.0.0.1")) then
			local aData = {
				ChannelId	= channel,
				Country		= "Crysisville",
				countryName	= "Crysisville",
				CountryCode = "CV",
				countryName = "CV",
				Conti		= "Lingshan Islands",
				continentName = "Lingshan Islands",
				ContiCode 	= "LI",
				City 		= "Village",
				continentCode = "LI"
			}

			IP_DB[ip] = aData
			self.channelCCs[channel] = aData
			if (hPlayer) then
				hPlayer.Info.IPData = aData
			end

			self:Log("Skipping IP lookup for localhost on channel %d", (tonumber(channel or 0) or 0))
			return
		end

		self:Log("Looking up IP Information for %s on channel %d", ip, (tonumber(channel or 0) or 0));
		ATOMDLL:HTTP_Get("api.db-ip.com", 80, "/v2/free/" .. ip, {}, function(netStatus, httpStatus, respHeaders, ipdata)
			if (ipdata) then
				if (string.len(ipdata) > 10) then
					local data = json.decode(ipdata or "{}");
					if (hPlayer) then
						hPlayer.Info.IPData	= {
							Country		= data.countryName		or "Crysisville",
							CountryCode = data.countryCode		or "CV",
							Conti		= data.continentName	or "Lingshan Islands",
							ContiCode 	= data.continentCode	or "LI"
						};
						if (hPlayer.Info.IPData.CountryCode == "CL") then
							hPlayer.LatinoPower = true;
						end;
					else
					--	SysLog("Player on channel %d left ")
					end;

					data.ChannelId = channel
					data.City = data.city
					data.Country = data.countryName
					data.CountryCode = data.countryCode

					self.channelCCs[channel] = data;
					--if (#(data) > 2) then
						IP_DB[ip] = data;
					--end;
					self:Log("Received information for IP Address %s of channel %d (%s, %s)", ip, channel, (data.countryName or "N/A"), (data.continentName or "N/A"));
					
					--data.countryName = "Chile"
					
					self:CheckCountry(data, channel);
					
					return data;
				else
					self:Log("Failed to lookup IP Infomartion for %s of channel %d",ip, channel)
				end;
			else
				self:Log("Failed to lookup IP Address %s of channel %d", ip, channel);
			end;
		end);
	end;
	--------------
	InitAI = function(self, skipInit)
		SysLog("AI : Config AI System enabled");
		local mapname, rules = self:GetMapName(true);
		if (not mapname or not rules) then
			return false, "Failed to Init AI", SysLog("ATOM : AI : Invalid mapname or rules, cannot load navmesh.");
		end;
		local AIFiles = {};
		local path = self.ModDir .. "/AISystem/NavMesh/" .. rules .. "/" .. mapname;
		for i, file in pairs(System.ScanDirectory(path, 1)or{}) do
			if (file:sub(-4):lower()~='.bai') then
				SysLog("AI : Invalid file found in navmesh folder (%s, not valid bai file).", file);
			else
				table.insert(AIFiles, { file = file, size = fileutils.size(self.RealModDir.. "/AISystem/NavMesh/" .. rules .. "/" .. mapname..'/'..file) });
			end;
		end;
		if (arrSize(AIFiles) == 0) then
			return false, "No NavMesh files found for this map", SysLog("AI : No NavMesh found for map %s (%s).", mapname, rules);
		else
			local totalfiles = 0;
			for i, v in pairs(AIFiles) do
				totalfiles = totalfiles + v.size;
			end;
			SysLog("AI : Found %d NavMesh files (%dkb) for map %s (%s).", arrSize(AIFiles), totalfiles/1024, mapname, rules);
		end;
		if (not skipInit) then
			SysLog("AI : All checks done, loading AI ...");
			ATOMDLL:InitAI();
		else
			SysLog("AI : Not loading AI");
		end;
		SysLog("AI : All checks done, loading navmesh ...");
		ATOMDLL:LoadNavMesh(path, 'mission0');
		SysLog("AI : All checks done, setting globals ...");
		AI_ENABLED = true;
		AI.Enabled = true;
		SysLog("AI : Process done.");
		return true;
	end;
	--------------
	InitServerEntity = function(self)

		local hServer = self.Server
		if (not hServer) then
			return
		end

		ATOMPlayerUtils:InitServer(self.Server)
		ATOM_Usergroups:SetupServer(self.Server)
	end,
	--------------
	SetupServerEntity = function(self)
		local name = "ATOM_SERVER_ENTITY"
		
		if (not _G[name] or not GetEnt(_G[name].id)) then
			_G[name] = nil;
		end;
		if (not _G[name]) then
			Script.SetTimer(50, function()
				local class		  = "Reflex";
				local position	  = { x = 0, y = 0, z = 3000 };
				local orientation = { x = 0, y = 0, z = 1 };
				
				local spawnParams = {
					name		  = "ATOM",
					class		  = class,
					position	  = position,
					orientation	  = orientation
				};
				
				local serverEntity  = System.SpawnEntity(spawnParams);
				
				local actorSpawnParams = spawnParams;
				actorSpawnParams.class = "Player";
				
				--local serverActorEntity  = System.SpawnEntity(actorSpawnParams);
				
				_G[name] = serverEntity;
				--_G[name .. "_actor"] = serverActorEntity;
		
				self.Server = _G[name];
				self.Server.isServer = true;
		
				if (g_localActor) then
				--	ATOMPlayerUtils.InitPlayer(g_localActor);
				end;
		
				--[[
				self.ServerActor = _G[name .. "_actor"];
				self.ServerActor.isServer = true;
				self.ServerActor.invulnerable = true;
				self.ServerActor.spawnPosition = actorSpawnParams.position;
				self.ServerActor:SetFlags(4, 1)
				--]]

			end)
		else
			self.Server = _G[name]
			self.Server.isServer = true
		end
		ATOMPlayerUtils:InitServer(self.Server)
		ATOM_Usergroups:SetupServer(self.Server)
	end;
	--------------
	CallLogFunctions = function(self)
		ATOMCommands:LogLoadedCommands()
		
		local iIncludes = 0
		for i, v in pairs(self.loadedFiles.Includes or{})do
			if (v[2]) then
				iIncludes = iIncludes + 1 end
		end
		ATOMLog:LogLoad("Commands", "Successfully Loaded %d Includes", iIncludes)
		
		local iPlugins = 0
		for i, v in pairs(self.loadedFiles.Plugins or{})do
			if (v[2]) then
				iPlugins = iPlugins + 1 end
		end
		ATOMLog:LogLoad("Commands", "Successfully Loaded %d Plugins", iPlugins)
	end;
	--------------
	GetServerFolderName = function(self)
		local root = self.RootDir;
		return root:match("Crysis/(.*)/(.*)");
	end;
	--------------
	AddSetups = function(self)
		self.mapSetups = {};
		local cfg = self.cfg.MapSetup
		for i, file in ipairs(System.ScanDirectory(self.SetupDir, 1)or{}) do
			self.mapSetups   [#self.mapSetups + 1]    = file;
		end
		
		if (#self.mapSetups > 0) then
			if (self.cfg.LogVerbosity >= 2) then
				self:Log(2, "Added " .. #self.mapSetups .. " Map-Setups");
			end
		end
	end;
	--------------
	AddIncludes = function(self)
		self.modIncludes   = {}
		
		-- local cfg = self.cfg.IncludesConfig;
		
		for i, file in ipairs(System.ScanDirectory(self.IncludesDir, 1)or{}) do
			self.modIncludes[#self.modIncludes + 1] = file
		end
		
		if (#self.modIncludes > 0) then
			self:Log(2, "Added " .. #self.modIncludes .. " Server-Includes")
		end
	end;
	--------------
	AddServerIncludes = function(self)
		self.serverIncludes   = {}
		
		local cfg = self.cfg.IncludesConfig;
		
		for i, file in ipairs(System.ScanDirectory(self.IncludesDir, 1)or{}) do
			self.serverIncludes[#self.serverIncludes + 1] = file
		end
		
		if (#self.serverIncludes > 0) then
			self:Log(2, "Added " .. #self.serverIncludes .. " Server-Includes")
				
			if (cfg.SortIncludes) then
				table.sort(self.serverIncludes, function(a, b)
					return b > a;
				end)
			end
		end
	end;
	--------------
	AddPlugins = function(self)
		self.modPlugins    = {};
		self.serverPlugins = {};
		
		--local m, s = 0, 0;
		local cfg = self.cfg.PluginConfig;
		
		for i, file in ipairs(System.ScanDirectory(self.ModPluginsDir, 1)or{}) do
		--	System.LogAlways("self.modPlugins[" .. #self.modPlugins+1 .. "] = " .. file)
			self.modPlugins   [#self.modPlugins + 1]    = file;
		end;

		for i, file in ipairs(System.ScanDirectory(self.ServerPluginsDir, 1)or{}) do
		--	System.LogAlways("self.serverPlugins[" .. #self.serverPlugins+1 .. "] = " .. file)
			self.serverPlugins[#self.serverPlugins + 1] = file;
		end;
		
		if (#self.modPlugins > 0) then
			self:Log(2, "Added " .. #self.modPlugins .. " MOD-Plugins");
			if (cfg.SortPlugins) then
			--	DebugTable(self.modPlugins);
				table.sort(self.modPlugins, function(a, b)
			--		System.LogAlways(tostring(a) .. ">" .. tostring(b))
					return b > a;
				end);
			--	DebugTable(self.modPlugins);
			end;
		end;
		if (#self.serverPlugins > 0) then
			self:Log(2, "Added " .. #self.serverPlugins .. " Server-Plugins");
			
			if (cfg.SortPlugins) then
			--	DebugTable(self.modPlugins);
				table.sort(self.serverPlugins, function(a, b)
			--		System.LogAlways(tostring(a) .. ">" .. tostring(b))
					return b > a;
				end);
			--	DebugTable(self.modPlugins);
			end;
		end;
	end;
	--------------
	AddCommands = function(self)
	
		self.modCommands    = {};
		self.serverCommands = {};
		
		--local m, s = 0, 0;
		local cfg = self.cfg.CommandConfig;
		
		for j, folder in pairs(cfg.ScanFolders) do
			for i, file in ipairs(System.ScanDirectory(self.ModCommandsDir .. "\\" .. folder, 1)or{}) do
			--	System.LogAlways("self.modCommands[" .. #self.modCommands+1 .. "] = " .. file)
				self.modCommands   [#self.modCommands + 1]    = { folder, file };
			end;

			for i, file in ipairs(System.ScanDirectory(self.ServerCommandsDir.. "\\" .. folder, 1)or{}) do
			--	System.LogAlways("self.serverCommands[" .. #self.serverCommands+1 .. "] = " .. file)
				self.serverCommands[#self.serverCommands + 1] = { folder, file };
			end;
		end;
		
		if (#self.modCommands > 0) then
			self:Log(2, "Added " .. #self.modCommands .. " MOD-Commands");
			
			if (cfg.SortPlugins) then
			--	DebugTable(self.modCommands);
				table.sort(self.modCommands, function(a, b)
			--		System.LogAlways(tostring(a) .. ">" .. tostring(b))
					return b[2] > a[2];
				end);
			--	DebugTable(self.modCommands);
			end;
		end;
		
		if (#self.serverCommands > 0) then
			self:Log(2, "Added " .. #self.serverCommands .. " Server-Plugins");
			
			if (cfg.SortPlugins) then
			--	DebugTable(self.modCommands);
				table.sort(self.serverCommands, function(a, b)
			--		System.LogAlways(tostring(a) .. ">" .. tostring(b))
					return b[2] > a[2];
				end);
			--	DebugTable(self.modCommands);
			end;
		end;
	end;
	--------------
	LoadCoreFiles = function(self, reload)
		local corePath = self.ModDir;
		local file;
		for i = 1, #self.coreFiles do
			file = self.coreFiles[i];
			if (not self:LoadFile("Core/" .. file .. self:GetFileExtentsion(file), "Core")) then
				return false;
			else
				--[[if (file == "ATOM-Logging") then
					self:LoadLoggingConfig(self.ServerRootDir);
				end;--]]
			--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
			end;
		end;
		return true;
	end;
	--------------
	LoadGameDataFiles = function(self, reload)
		local corePath = self.ModDir;
		local file;
		for i = 1, #self.gameData do
			file = self.gameData[i];
			if (not self:LoadFile("GameData/" .. file .. self:GetFileExtentsion(file), "GameData")) then
				return false;
			else
				--[[if (file == "ATOM-Logging") then
					self:LoadLoggingConfig(self.ServerRootDir);
				end;--]]
			--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
			end;
		end;
		return true;
	end;
	--------------
	LoadLoggingConfig = function(self, corePath)
	end;
	--------------
	LoadFiles = function(self, reload)
		local corePath = self.ModDir;
		local file;
		for i = 1, #self.modFiles do
			file = self.modFiles[i];
			if (not self:LoadFile("Internal/" .. file .. self:GetFileExtentsion(file), "Internal")) then
				return false;
			else
			--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
			end;
		end;
		return true;
	end;
	--------------
	LoadConfig = function(self, reload)
		local corePath = self.ServerRootDir
		if (not self:LoadFile("ATOM/Config/Config.lua", "Configuration", corePath:sub(1, #corePath-1))) then
			return false
		end
		
		--self:Log(0, "Adding Script Files")
		self:AssignConfig()
		self:AddCommands()
		self:AddPlugins() -- must be done after loading config and AFTER ASSIGNING CONFIGS!!!
		self:AddSetups()
		self:SetupNetworkConfig()
		
		return true
	end;
	--------------
	SetupNetworkConfig = function(self)
		local cfg = self.cfg.Network;
		if (cfg) then
			if (cfg.CryTekAntiLag) then
				ATOMDLL:ForceSetCVar("a_crytek_anti_lag", "1");
			else
				ATOMDLL:ForceSetCVar("a_crytek_anti_lag", "0");
			end;
			if (cfg.PhysicsLagSmooth) then
				ATOMDLL:ForceSetCVar("net_phys_lagsmooth", tostr(cfg.PhysicsLagSmooth));
			end;
			if (cfg.PacketRate) then
				ATOMDLL:ForceSetCVar("sv_PacketRate", tostr(cfg.PacketRate));
			end;
			if (cfg.PingLagSmooth) then
				ATOMDLL:ForceSetCVar("net_phys_pingsmooth", tostr(cfg.PingLagSmooth));
			end;
			if (cfg.Bandwidth) then
				ATOMDLL:ForceSetCVar("sv_bandwidth", tostr(cfg.Bandwidth));
			end;
			if (cfg.ConnectionTimeout) then
				ATOMDLL:ForceSetCVar("net_inactivitytimeout", tostr(cfg.ConnectionTimeout));
			end;
			if (cfg.Log) then
				ATOMDLL:ForceSetCVar("net_log", tostr(cfg.Log));
			end;
			if (cfg.LogRMI) then
				ATOMDLL:ForceSetCVar("net_log_remote_methods", tostr(cfg.LogRMI));
			end;
			if (cfg.TickRate) then
				ATOMDLL:ForceSetCVar("sv_dedicatedMaxRate", tostr(cfg.TickRate));
			end;
			if (cfg.NetSignTreshold) then
				SysLogVerb(2, "High latency treshold: %f (%dms)", cfg.NetSignTreshold/1000, cfg.NetSignTreshold);
				ATOMDLL:ForceSetCVar("net_highlatencythreshold", tostr(cfg.NetSignTreshold/1000));
			end;
			if (cfg.NetSignHighTime) then
				SysLogVerb(2, "High latency time limit: %0.2fs", cfg.NetSignHighTime);
				ATOMDLL:ForceSetCVar("net_highlatencytimelimit", tostr(cfg.NetSignHighTime));
			end;
			if (cfg.GameSpyService ~= nil and cfg.GameSpyService == false) then -- For some reason this hangs the server, so I added a CVar to disable GS Network Service which must be added to the autoexec.cfg
			--	ATOMDLL:EnableGameSpyService(); -- Actually disables it :D
			end;
		end;
	end;
	--------------
	AssignConfig = function(self)
	
		if (Config) then
			local s;	
			if (Config.AI) then
				self.cfg.AISystem = Config.AI.LoadAI;
			end;
			
			if (Config.DamageConfig) then
				self.cfg.DamageConfig = mergeTables(self.cfg.DamageConfig, Config.DamageConfig);
				if (Config.DamageConfig.ExplodeC4) then
					System.SetCVar("a_c4_hits", "1");
				else
					System.SetCVar("a_c4_hits", "0");
				end;
				if (Config.DamageConfig.FriendlyFireRatio) then
					System.SetCVar("g_friendlyfireratio", tostr(Config.DamageConfig.FriendlyFireRatio));
				end;
				if (Config.DamageConfig.HQSettings) then
					--DebugTable(ATOMHQ.cfg)
					ATOMHQ.cfg = mergeTables(ATOMHQ.cfg, Config.DamageConfig.HQSettings);
					--Debug("now----------------------")
					--DebugTable(ATOMHQ.cfg)
				end;
			end;
			
			if (Config.Maps) then	
				--SysLog("MAPS!!")
				self.cfg.MapConfig = mergeTables(self.cfg.MapConfig or {}, Config.Maps);
				--Debug(self.cfg.MapConfig)
			end;
			
			if (Config.ModifiedFiles) then	
				--SysLog("MAPS!!")
				self.cfg.ModifiedFiles = mergeTables(self.cfg.ModifiedFiles or {}, Config.ModifiedFiles);
				--Debug(self.cfg.MapConfig)
			end;
			
			if (Config.ATOM) then
				if (Config.ATOM.DebugMode) then
					DEBUG_MODE = Config.ATOM.DebugMode;
					Config.ATOM.DebugMode = nil;
				end;
				
				if (not Config.ForbiddenAreas) then
					for i, v in pairs(System.GetEntitiesByClass("ForbiddenArea")or{}) do
						System.RemoveEntity(v.id);
					end;
					--SysLog("Disabling forbidden areas");
				end;
				
				if (Config.ATOM.Vehicles) then
					ATOMVehicles.cfg = mergeTables(ATOMVehicles.cfg, Config.ATOM.Vehicles);
					Config.ATOM.Vehicles = nil;
				end;
				
				self.cfg = mergeTables(self.cfg, Config.ATOM);
				
				self:CheckServerName();
				
				if (self.cfg.FOV) then
					ATOMDLL:ForceSetCVar("cl_fov", tostr(self.cfg.FOV));
				end;
				
				------
				self.cfg.Immersion = self.cfg.Immersion or {};
				
				------
				if (self.cfg.Immersion.StealthOMeter and g_gameRules.class ~= "InstantAction") then
					ATOMDLL:ForceSetCVar("g_enablempStealthOMeter", "1") end
				
				------
				if (self.cfg.Immersion.MeleeWhileSprinting) then
					ATOMDLL:ForceSetCVar("g_meleeWhileSprinting", "1") end
					
				------
				if (self.cfg.Immersion.ClassicNanoSuit) then
					ATOMDLL:ForceSetCVar("a_classic_nanosuit", "0") else
					ATOMDLL:ForceSetCVar("a_classic_nanosuit", "1") end
				
				------
				local iWallJump = checkNumber(self.cfg.Immersion.WallJumpMultiplier, 1)
				ATOMDLL:ForceSetCVar("mp_wallJump", tostring(iWallJump))
				
				------
				local iCircleJump = ((self.cfg.Immersion.EnableCircleJumping == true) and 1 or 0)
				ATOMDLL:ForceSetCVar("mp_circlejump", tostring(iCircleJump))
				
				------
				local iThirdPerson = ((self.cfg.Immersion.EnableThirdPerson == true) and 1 or 0)
				ATOMDLL:ForceSetCVar("mp_thirdPerson", tostring(iThirdPerson))
				
				------
				local iPickupObjects = ((self.cfg.Immersion.EnablePickupObjects == true) and 1 or 0)
				ATOMDLL:ForceSetCVar("mp_pickupobjects", tostring(iPickupObjects))
				
				------
				local iPickupVehicles = ((self.cfg.Immersion.EnablePickupVehicles == true) and 1 or 0)
				ATOMDLL:ForceSetCVar("mp_pickupvehicles", tostring(iPickupVehicles))
				
				------
				local iKillMessages = ((self.cfg.Immersion.ShowKillMessages == true) and 1 or 0)
				ATOMDLL:ForceSetCVar("mp_killMessages", tostring(iKillMessages))
				
				------
				self.cfg.GamePlayConfig = mergeTables(self.cfg.GamePlayConfig, Config.ATOM.GamePlay);
				
				------
				s = self.cfg.GamePlayConfig;
				if (s) then
					if (s.LyingItemLimit) then
						ATOMDLL:ForceSetCVar("i_lying_item_limit", tostring(s.LyingItemLimit));
					end;
					if (s.SuitSpeedMultiplier) then
						ATOMDLL:ForceSetCVar("g_suitSpeedMultMultiplayer", tostring(s.SuitSpeedMultiplier));
					end;
					if (s.SuitEnergyConsumption) then
						ATOMDLL:ForceSetCVar("g_suitSpeedEnergyConsumptionMultiplayer", tostring(s.SuitEnergyConsumption));
					end;
				end;
			end;
			
			if (Config.GamePlay) then
				self.cfg.GamePlayConfig = mergeTables(self.cfg.GamePlayConfig, Config.GamePlay);
			end;
			
			if (Config.GamePlay.Buying) then
				ATOMBuying.cfg.Buying = mergeTables(ATOMBuying.cfg.Buying, Config.GamePlay.Buying);
			end;
			
			if (Config.Score) then
				ATOMStats.cfg = mergeTables(ATOMStats.cfg, Config.Score);
			end;
			
			if (Config.Connection) then
				self.cfg.Connection = mergeTables(self.cfg.Connection, Config.Connection);
			end;
			

			if (Config.ScriptFiles) then
				if (Config.ScriptFiles.Plugins) then
					self.cfg.PluginConfig = Config.ScriptFiles.Plugins;
				end;
				if (Config.ScriptFiles.Commands) then
					self.cfg.CommandConfig = Config.ScriptFiles.Commands;
				end;
				if (Config.ScriptFiles.MapSetup) then
					self.cfg.MapSetup = Config.ScriptFiles.MapSetup;
				end;
				if (Config.ScriptFiles.Includes) then
					self.cfg.IncludesConfig = Config.ScriptFiles.Includes;
				end;
			end;
			
			if (Config.Logging) then
				ATOMLog.cfg = mergeTables(ATOMLog.cfg, Config.Logging);
			end;

			
			if (Config.Chat) then
				ATOMChat.cfg = mergeTables(ATOMChat.cfg, Config.Chat);
			end;
			
			if (Config.Broadcast) then
				ATOMBroadCaster.cfg = mergeTables(ATOMBroadCaster.cfg, Config.Broadcast);
			end;
			
			if (Config.Commands) then
				ATOMCommands.cfg = mergeTables(ATOMCommands.cfg, Config.Commands);
			end;
		
			if (Config.Names) then
				ATOMNames.cfg = mergeTables(ATOMNames.cfg, Config.Names);
			end;
		
			if (Config.Equipment) then
				ATOMEquip.cfg = mergeTables(ATOMEquip.cfg, Config.Equipment);
			end;
		
			if (Config.Punishment) then
				if (Config.Punishment.Bans) then
					ATOMPunish.ATOMBan.cfg = mergeTables(ATOMPunish.ATOMBan.cfg, Config.Punishment.Bans);
				end;
				if (Config.Punishment.Mutes) then
					ATOMPunish.ATOMMute.cfg = mergeTables(ATOMPunish.ATOMMute.cfg, Config.Punishment.Mutes);
				end;
				if (Config.Punishment.Warns) then
					ATOMPunish.ATOMWarn.cfg = mergeTables(ATOMPunish.ATOMWarn.cfg, Config.Punishment.Warns);
				end;
			end;
		end;

		self:InitCore(true)
		self:SetupServerEntity()
		self:InitInternals()
		
	end;
	--------------
	ReadCode = function(self, ...)
		local code = table.concat({...}, " ");
		if (not code or emptyString(code)) then
			return false, "specify code";
		end;
		local success, error = pcall(loadstring(code));
		if (not success) then
			ATOMLog:LogError("Failed to load Code, " .. error);
			return false, error;
		end;
		return true;
	end;
	--------------
	NextLevel = function(self)
		return g_gameRules:NextLevel();
	end,
	--------------
	SetPostInit = function(self, sFunc, sParam)
		table.insert(self.PostInits, { sFunc, sParam })
	end,
	--------------
	SetAfterInit = function(self, sFunc, sParam)
		table.insert(self.AfterInits, { sFunc, sParam })
	end,
	--------------
	AutoSaveFile = function(self, sFunc, sParam)
		table.insert(self.AutoSaveFiles, { sFunc, sParam })
	end,
	--------------
	InitInternals = function(self, reload)
	
		ATOMChat:Init();
		ATOMEquip:Init();
		ATOMPunish:Init();
		ATOMDefense:Init();
		ATOMGameUtils:Init();

		for i, aProps in pairs(self.PostInits) do
			loadstring(string.format([[
				%s(%s)
			]], aProps[1], aProps[2]))()
			--SysLog("PostInit(%s)", aProps[1])
		end
		
		if (g_gameRules.class == "PowerStruggle") then
			ATOMHQ:Init();
		end;
		--if (not reload) then
		--	ATOMChat:Init();
		--end;
	end;
	--------------
	InitCore = function(self, conf)
		ATOM_Utils:InitLater(conf);
		ATOM_Usergroups:Init(conf);
		ATOMNames:Init();
		--ATOMCommands:Init();
	end;
	--------------
	LoadMODCommands = function(self)
	
		local cfg = self.cfg.CommandConfig;
		if (cfg.UseMODCommands == false) then
			self:Log(2, "Skipping MOD-Commands, MOD-Commands are disabled");
			return true;
		end;
		
		local corePath = self.ModCommandsDir;
		local file, folderm doLoad = "", "";
		for i = 1, #self.modCommands do
			file = self.modCommands[i];
			if (file) then
				if (type(file) == "table") then
					folder = file[1] .. "/";
					file = file[2];
				else
					folder = "";
				end;
				doLoad = cfg.LoadAllMODCommands or self:CanLoadFile(file, cfg.MOD);
				if (doLoad) then
					--System.LogAlways("MOD COMMAND: ".. "Commands/" .. folder .. file)
					if (not self:LoadFile("Commands/" .. folder .. file .. self:GetFileExtentsion(file), "MOD-Command")) then
					--	return false;
					else
					--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
					end;
				end;
				table.insert(self.loadedFiles.Commands, { "MOD", doLoad, file, getFileSize(self.RealModDir .. "/Commands/" .. folder .. file .. self:GetFileExtentsion(file)), folder });

			end;
		end;
		return true;
	end;
	--------------
	LoadServerCommands = function(self)
	
		local cfg = self.cfg.CommandConfig;
		if (cfg.UseMODCommands == false) then
			self:Log(2, "Skipping Server-Commands, Server-Commands are disabled");
			return true;
		end;
		
		local corePath = self.ServerCommandsDir;
		local file, folder, doLoad = "", "";
		for i = 1, #self.serverCommands do
			file = self.serverCommands[i];
			if (file) then
				if (type(file) == "table") then
					folder = file[1] .. "/";
					file = file[2];
				else
					folder = "";
				end;
				doLoad = cfg.LoadAllServerCommands or self:CanLoadFile(file, cfg.Server);
				if (doLoad) then
					--[[if (type(file) == "table") then
						folder = file[1] .. "/";
						file = file[2];
					else
						folder = "";
					end;--]]
					--System.LogAlways("SERVER COMMAND: ".. "Commands/" .. folder .. file)
					if (not self:LoadFile(folder .. file .. self:GetFileExtentsion(file), "Server-Command", corePath)) then
					--	return false;
					else
					--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
					end;
				end;
				table.insert(self.loadedFiles.Commands, { "Server", doLoad, file, getFileSize(corePath .. "/" .. folder .. file .. self:GetFileExtentsion(file)), folder });
			end;
		end;
		return true;
	end;
	--------------
	LoadMapSetups = function(self)
	
		local cfg = self.cfg.MapSetup;
		if (cfg.UseSetups == false) then
			self:Log(2, "Skipping MapSetups, MapSetups are disabled");
			return true;
		end;


		local corePath = self.SetupDir;
		local file, folder = "", "";

		if (cfg.UseGlobalSetup) then
			ATOMSetup:AddMapSetupScript("Global.lua", corePath .. "/Global.lua")
		end

		for i = 1, #self.mapSetups do
			file = self.mapSetups[i];
			if (cfg.LoadAllSetups or self:CanLoadFile(file, cfg.Setups)) then
				ATOMSetup:AddMapSetupScript(file .. self:GetFileExtentsion(file), corePath .. "/" .. file .. self:GetFileExtentsion(file));
				--[[
				if (type(file) == "table") then
					folder = file[1] .. "/";
					file = file[2];
				else
					folder = "";
				end;
				--System.LogAlways("SERVER COMMAND: ".. "Commands/" .. folder .. file)
				if (not self:LoadFile(folder .. file .. self:GetFileExtentsion(file), "Map-Setup", corePath)) then
					return false;
				else
				--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
				end;
				--]]
			end;
		end;
		return true;
	end;
	--------------
	LoadIncludes = function(self)
	
		----------
		-- local cfg = self.cfg.IncludesConfig;
		-- if (not cfg or cfg.UseIncludes == false) then
			-- self:Log(2, "Skipping Server-Includes, Server-Includes are disabled");
			-- return true end
		
		----------
		local corePath = self.ServerIncludesDir;
		local file, doLoad;
		for i = 1, #self.modIncludes do
			file = self.modIncludes[i]
			doLoad = true --cfg.LoadAllIncludes or self:CanLoadFile(file, cfg.LoadIncludes)
			if (doLoad) then
				self:LoadFile("Includes/" .. file .. self:GetFileExtentsion(file), "Server-Include")
			end
			table.insert(self.loadedFiles.Includes, { "Include", doLoad, file, 0 or getFileSize(self.RealModDir .. "/Includes/" .. file .. self:GetFileExtentsion(file)) });
		end
		
		----------
		fileutils.LUA_5_3 = true
		string.LUA_POPEN_SUPPORTED = false
		--SysLog("Changing FileUtils handler")
		
		----------
		return true
	end,
	--------------
	LoadServerIncludes = function(self)
	
		----------
		local cfg = self.cfg.IncludesConfig;
		if (not cfg or cfg.UseIncludes == false) then
			self:Log(2, "Skipping Server-Includes, Server-Includes are disabled");
			return true end
		
		----------
		local corePath = self.IncludesDir;
		local file, doLoad;
		for i = 1, #self.serverIncludes do
			file = self.serverIncludes[i]
			doLoad = cfg.LoadAllIncludes or self:CanLoadFile(file, cfg.LoadIncludes)
			if (doLoad) then
				self:LoadFile("Includes/" .. file .. self:GetFileExtentsion(file), "Server-Include")
			end
			table.insert(self.loadedFiles.Includes, { "Include", doLoad, file, getFileSize(self.RealModDir .. "/Includes/" .. file .. self:GetFileExtentsion(file)) });
		end
		
		----------
		return true
	end,
	--------------
	LoadMODPlugins = function(self)
	
		local cfg = self.cfg.PluginConfig;
		if (cfg.UseModPlugins == false) then
			self:Log(2, "Skipping MOD-Plugins, MOD-Plugins are disabled");
			return true;
		end;
		
		local corePath = self.ModPluginsDir;
		local file, doLoad;
		for i = 1, #self.modPlugins do
			file = self.modPlugins[i];
			doLoad = cfg.LoadAllMODPlugins or self:CanLoadFile(file, cfg.MOD);
			if (doLoad) then
				if (not self:LoadFile("Plugins/" .. file .. self:GetFileExtentsion(file), "MOD-Plugin")) then
				--	return false;
				else
				--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
				end;
			else
			end;
			table.insert(self.loadedFiles.Plugins, { "MOD", doLoad, file, getFileSize(self.RealModDir .. "/Plugins/" .. file .. self:GetFileExtentsion(file)) });
		end;
		return true;
	end;
	--------------
	LoadServerPlugins = function(self)
	
		local cfg = self.cfg.PluginConfig;
		if (cfg.UseServerPlugins == false) then
			self:Log(2, "Skipping Server-Plugins, Server-Plugins are disabled");
			return true;
		end;
		
		local corePath = self.ServerPluginsDir;
		--Debug(corePath)
		local file, doLoad;
		local err = false;
		for i = 1, #self.serverPlugins do
			file = self.serverPlugins[i];
			doLoad = cfg.LoadAllServerPlugins or self:CanLoadFile(file, cfg.Server);
			if (doLoad) then
				if (not self:LoadFile(file .. self:GetFileExtentsion(file), "Server-Plugin", corePath)) then
					--if (ATOMLog) then
					--	ATOMLog:LogError("Failed to file " .. file .. self:GetFileExtentsion(file));
					--end;
					--self:LogError();
					err = true;
				--	return false;
				else
				--	self:LogLoad("Loaded Core File Core/" .. self.coreFiles[i] .. ".lua");
				end;
			end;
			table.insert(self.loadedFiles.Plugins, { "Server", doLoad, file, getFileSize(corePath .. "/" .. file .. self:GetFileExtentsion(file)) });
		end;
		return not err;
	end;
	--------------
	GetFileExtentsion = function(self, fileName)
		return fileName:sub(-4) ~= ".lua" and ".lua" or "";
	end;
	--------------
	CanLoadFile = function(self, file, aFileList)
	
		local sFile = string.lower(file)
		for i, allowed in pairs(aFileList or{}) do
		
		
			local sIndex = string.lower(i)
			if ((sFile .. self:GetFileExtentsion(sFile)) == (sIndex .. self:GetFileExtentsion(sIndex))) then
				return true end
			
			local sAllowed = string.lower(allowed)
			if ((sFile .. self:GetFileExtentsion(sFile)) == (sAllowed .. self:GetFileExtentsion(sAllowed))) then
				return true end
			
			--SysLog("[1] %s == %s", (sFile .. self:GetFileExtentsion(sFile)), (sIndex .. self:GetFileExtentsion(sIndex)))
			--SysLog("[2] %s == %s", (sFile .. self:GetFileExtentsion(sFile)), (sAllowed .. self:GetFileExtentsion(sAllowed)))
		end
		return false
	end;
	--------------
	DoDebug = function(self, what)
		SysLog("game state: %s (%s)", g_gameRules:GetState(), tostring(what))
	end,
	--------------
	DebugFacTeams = function(self, fromwhere)
		if (g_gameRules.class == "PowerStruggle") then
			local entities = System.GetEntitiesByClass("Factory");
			if (entities) then
				local g_game = g_gameRules.game;
				for i,v in pairs(entities) do
					if (v:GetName():find("Proto")) then
						SysLog("[%s] %s = team %s", fromwhere, v:GetName(), tostring(g_game:GetTeam(v.id)))
						break;
					end
				end;
			end;
		end;
	end,
	--------------
	LoadFile = function(self, file, t, dir)
		local dir = dir or self.RealModDir; -- ScriptDir
		local status, result;
		local func, message = loadfile(dir .. "/" .. file); -- loadfile requires real directory
		--self:Log(tostring("Game/"..dir .. "/" .. file))
		
		--self:DebugFacTeams("before:"..file)
		
		if (func) then
			if (DebugMode) then
				result = func();
				status = true;
			else
				status, result = pcall(func);
				--if (not status) then
				--	status = false;
				--else
				--	status = true;
				--end;
			end;
		else
			status = false;
		end;
		--self:DebugFacTeams("after:"..file)
		--[[
		status, result = Script.UnloadScript(dir .. "/" .. file);
		if (not _RELOAD) then
			status, result = Script.LoadScript(dir .. "/" .. file, true);
		else
			status, result = Script.ReloadScript(dir .. "/" .. file, true);
		end;--]]
		
		--System.LogAlways(tostring(status) .. tostring(result))
		if (status) then
			table.insert(self.LoadedScripts, dir .. "/" .. file);
			--if (DebugMode) then
			local logType = 'Other';
			if (t == "Core") then
				logType = nil;
			elseif (t == "Internal") then
				logType = nil;
			elseif (t == 'MOD-Plugin' or t == 'Server-Plugin') then
				logType = 'Plugin';
			end;
			if (ATOMLog ~= nil and logType) then
				ATOMLog:LogLoad(logType, "%s File %s loaded successfully", t, file);
			else
				self:LogLoad("Loaded " .. t .. " file " .. file .. " successfully");
			end;
			--end;
			return true;
		else
			--if (not DebugMode) then  -- with DebugMode there is log_verbosity=3, which already tells enough information
			
			local trash, line = tostring(message):match("(.*):(%d+):");
			System.LogAlways("ERROR >>> " .. tostring(message) .. " " .. tostring(result));
			self:LogError("Failed to load " .. t .. " file " .. file .. ", result = line:"..(line or -1)..":"..tostring(message):gsub("^(.*)%.(.*):", ""));
			--end;
			if (ATOMLog) then
				ATOMLog:LogError("Failed to load " .. t .. " file " .. file .. " (line = " .. (line or -1)..", " .. tostring(message):gsub("^(.*)%.(.*):", "") .. ")");
			end;
			return false;
		end;
	end;
	--------------
	Log = function(self, verb, message, ...)
		local message, verb = message, verb;
		local fmt = {...};
		if (type(verb) == "string") then
			fmt		= { message, ... };
			message = verb;
			verb    = 0;
		end;
		if (true or verb <= self.cfg.LogVerbosity) then
			if (#fmt>0) then
				System.LogAlways("<ATOM> : " .. string.format(message, unpack(fmt)));
			else
				System.LogAlways("<ATOM> : " .. message);
			end;
		end;
		
		if (ATOMLog) then
			ATOMLog:LogToLogFile(LOG_FILE_SYSTEM, string.format("[%s] : %s", tostring(verb), string.format(message, unpack(fmt)))) end
	end;
	--------------
	LogLoad = function(self, message, ...)
		self:Log(0, message, ...);
	end;
	--------------
	LogError = function(self, message, ...)
		self:Log(0, "ERROR : " .. message, ...);
	end;
	--------------
	OnCheat = function(self, player, cheat, info, sure)
		-- quick hax 
		if (cheat == "Hit Spoof" and player:GetVehicle() and player:GetVehicle().class == "Asian_aaa") then
			SysLog("Prevented Asian AAA Hit spoof spam shit!");
			return;
		end;
		if (player and player.actor) then
		
			if (cheat == "Freeze") then
				if (not timerexpired(player.LastFreezeCheat, 1)) then
					return end
				player.LastFreezeCheat = timerinit()
			end
		
		
			ATOMDefense:OnCheat(player, cheat, info, sure);
		else
			System.LogAlways("WTF, entity " .. player.class .. " is Cheating???");
		end;
	end;
	--------------
	OnValidating = function(self, player, profileId, uID, accountName)
	--	Debug("GOT VALIDATE", profileId, uID, accountName)
	--	Script.SetTimer(5000, function()
	--		
	--	end);
	end,
	--------------
	OnProfileReceived = function(self, player, profileId, accountName)
		--Debug("onprofilereceived",profileId);
		if (not profileId or profileId == "0") then
			profileId = player.specialProfile or "0";
		end;
		local accountName = accountName or "Nomad";
		if (not player.Info) then
			player.profileId   = profileId;
			player.accountName = accountName;
		else
			player.Info.Id   = profileId;
			player.Info.Name = accountName
		end;
		
		player.IDReceived  = true;
		player.IDValidated = false;
		
		self:InitPlayer(player);
		
		local cfg = self.cfg.Connection;
		if (cfg and cfg.LogWhenProfileReceived) then
			if (not player.connectionLogged) then
				player.connectionLogged = true;
				ATOMLog:LogConnect(player);
				self:SendInfoMessages(player);
				ATOM_Usergroups:CheckProtectedName(player)
			end;
		end;
		
		
		if (player:HasAccess(ADMINISTRATOR)) then
			PuttyLog("$3Administration Online")
		end
		
	end;
	--------------
	InitPlayer = function(self, player, nr, all)

		player._initialized = _time

		--if (not nr) then
		--ATOM_Usergroups.InitPlayer(player);
			ATOMStats:InitPlayer(player, true);
			ATOMLevelSystem:OnConnect(player);
			ATOMBank:OnConnect(player);
			ATOMNames:OnConnect(player);
			ATOM_Usergroups.InitPlayer(player);
		--end;
		
		if (all) then
			
			local countryData = self.channelCCs[player:GetChannel()];
			ATOM_Utils.InitPlayer(player, player:GetChannel(), (self.channelIPs[player:GetChannel()] or player:GetIP()), player:GetHostName(), player:GetPort(), player:GetProfile(), player.accountName, (countryData and countryData.countryName), (countryData and countryData.countryCode), (countryData and countryData.continentName), (countryData and countryData.continentCode), (countryData and countryData.city));
			ATOMPlayerUtils.InitPlayer(player, player:GetChannel());
			ATOMEquip:InitPlayer(player)
			ATOM_Usergroups.InitPlayer(player)
			ATOMLevelSystem:InitPlayer(player)
			ATOMBank:InitPlayer(player)
			if (CLIENT_MOD) then
				RCA:InitPlayer(player)
			end
		end
		
		ATOMPunish.AutoWarns:InitPlayer(player)
		
		player.Initialized = true
		ATOMBroadcastEvent("OnPlayerInit", player)
		
		if (ATOMFootBall and ATOMFootBall.STADIUM_PARTY) then
			if (not player.InStadium) then
				ATOMFootBall:EnterStadium(player)
			end
		end
	end;
	--------------
	TurretTargetEntity = function(self, turret, entity) -- not called anymore, add entity.turretsShootMe=true and entity.CanTarget=function(self,tId)end instead.
		
		if (turret and entity and (entity.actor or entity.vehicle)) then
			if (g_game:GetTeam(entity.id) ~= g_game:GetTeam(turret.id)) then
				if (not entity.godMode) then
					return true;
				end;
			end;
			if (entity.isPlayer) then
				SysLog(entity.class)
			end;
			return false;
		end;
		
		return false;
	end;
	--------------
	OnTurretFire = function(self, turret, turretId, gunPos, gunDir, targetPos, aimPos) -- not called anymore, add entity.turretsShootMe=true and entity.CanTarget=function(self,tId)end instead.
		if (not turret.luaFire or _time - turret.luaFire > 0.2) then
		
			turret.luaFire = _time;
			
			--NormalizeVector(aimLoc);
			--NormalizeVector(targetPos);
			--NormalizeVector(aimPos);
			
			--Debug(gunPos)
			--Debug(gunDir)
			
			local dir = turret:GetDirectionVector();
			
			--shooter, weapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId)
			if (turret.gunName) then
				if (GunSystem:GetItem(turret.gunName)) then
					GunSystem:ProcessShot(turret, GunSystem:GetItem(turret.gunName), turret, CalcPos(gunPos, gunDir, 3), gunDir, CalcPos(gunPos, gunDir, 100), g_Vectors.up, 100, false, turret.weapon:GetAmmoType(), nil);
				end;
			else
				Debug("Fire Projectile WTF huh lol whaaaaaaaaaaaat ok???")
				ATOMItems:AddProjectile(
				mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
					Owner = turret,
					Weapon = turret,
					Pos = CalcPos(gunPos, gunDir, 3),
					Dir = gunDir,
					Hit = CalcPos(gunPos, gunDir, 100),
					Normal = g_Vectors.up,
				}));
			end;
		end;
		
		return false;
	end;
	--------------
	GetPlugins = function(self)
		return self.loadedFiles.Plugins;
	end,
	--------------
	GetCommands = function(self)
		return self.loadedFiles.Commands;
	end,
	--------------
	GetIncludes = function(self)
		return self.loadedFiles.Includes;
	end,
	--------------
	
	RapidFireShooting = function(self, hShooter, hWeapon)

		if (hShooter:GetPing() >= 300) then
			return
		end

		if (not hWeapon or not hWeapon.class) then
			return end

		if (not hShooter.isPlayer) then
			return end

		local aClasses = {
			["FY71"] = 15,
			["SCAR"] = 15,
			["SMG"] = 15,
			["Hellfire"] = 5,
			["Hurricane"] = 100,
			["Shotgun"] = 3,
			["SOCOM"] = 5,
			["TACGun"] = 3,
			["Sidewinder"] = 3,
			["LAW"] = 3,
			["DSG1"] = 3,
			["GaussRifle"] = 3,
		}

		local sClass = hWeapon.class
		local iThreshold = aClasses[sClass]
		if (not iThreshold) then
			return
		end

		if (sClass ~= hShooter.sLastWeaponClass) then
			hShooter.iRapidFireCounter = 0
			Debug("Reset ok")
		end
		hShooter.sLastWeaponClass = sClass

		if (not hWeapon.iLastFireTime) then
			hWeapon.iLastFireTime = _time
		end

		--Debug(_time - hWeapon.iLastFireTime,",",iTime)
		local iTime = (1 / (hWeapon.weapon:GetFireRate() / 60))
		local iFireTime = (_time - hWeapon.iLastFireTime)
		if (iFireTime < iTime) then
			hWeapon.iRapidFireShots = (hWeapon.iRapidFireShots or 0) + 1
			if (hWeapon.iRapidFireShots >= iThreshold) then
				hShooter.iRapidFireCounter = (hShooter.iRapidFireCounter or 0) + 1
				if (hShooter.iRapidFireCounter >= 3) then
					ATOMDefense:OnCheat(hShooter, "Weapon Manipulation", string.format("Rapid Fire (%d, Threshold %d)", hWeapon.iRapidFireShots, iThreshold), false, true)
				--else
				--	ATOMLog:LogDefense("Critical Weapon Rate on %s$9 (%s: $4%d, %d$9)", hShooter:GetName(), hWeapon.class, iFireTime, hWeapon.iRapidFireShots)
				end
				Debug("Counter: ",hShooter.iRapidFireCounter)
			elseif (hWeapon.iRapidFireShots >= (iThreshold / 2)) then
				ATOMLog:LogDefense("Critical Weapon Rate on %s$9 (%s: $4%ds, %d$9)", hShooter:GetName(), hWeapon.class, iFireTime, hWeapon.iRapidFireShots)
			end
		else
			hWeapon.iRapidFireShots = 0
		end

	end,
	--------------

	OnOutOfAmmoShoot = function(self, hShooter, hWeapon)

		if (hShooter:GetPing() >= 250) then
			return
		end

		if (not hWeapon or not hWeapon.class) then
			return end

		if (not hShooter.isPlayer) then
			return end

		local aClasses = {
			["FY71"] = 1,
			["SCAR"] = 1,
			["SMG"] = 1,
			["Hellfire"] = 1,
			["Hurricane"] = 1,
			["Shotgun"] = 1,
			["SOCOM"] = 1,
			["TACGun"] = 1,
			["Sidewinder"] = 1,
			["LAW"] = 1,
			["DSG1"] = 1,
			["GaussRifle"] = 1,
		}
		local aThresholds = {
			["DSG1"] = 3,
			["GausRifle"] = 3,
			["Shotgun"] = 3,
			["TACGun"] = 3,
			["SOCOM"] = 3,
			["SOCOM"] = 3,
		}

		local iThreshold = (aThresholds[hWeapon.class] or 7)

		hWeapon.outOfAmmoShots = (hWeapon.outOfAmmoShots or 0) + 1
		hWeapon.outOfAmmoShotsTrigger = (hWeapon.outOfAmmoShotsTrigger or 0) + 1
		if (hWeapon.outOfAmmoShotsTrigger >= 5 and hWeapon.outOfAmmoShots >= iThreshold) then
			hWeapon.outOfAmmoShotsTrigger = 0

			if (not aClasses[hWeapon.class]) then
				return SysLog("Out of Ammo shots from blacklisted weapon %s (%d)", hWeapon.class, hWeapon.outOfAmmoShotsTrigger)
			end
			ATOMDefense:OnCheat(hShooter, "Weapon Manipulation", string.format("Out of ammo Shots: %d (%s)", hWeapon.outOfAmmoShots, hWeapon.class or "N/A"), false, (hWeapon.outOfAmmoShots >= 30))
		end
	
	end,
	
	--------------
	OnShoot = function(self, hShooter, hWeapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId)

		---------
		if (not hWeapon) then
			return false end

		---------
		self:RapidFireShooting(hShooter, hWeapon)
		g_utils:ProcessShoot(hShooter)

		---------
		hWeapon.outOfAmmoShots = 0
		hWeapon.iLastFireTime = _time
	
		---------
		if (hWeapon.BindProjectile) then
			CryAction.CreateGameObjectForEntity(ammoId.id)
			CryAction.BindGameObjectToNetwork(ammoId.id)
			CryAction.ForceGameObjectUpdate(ammoId.id, true)
		end
		
		---------
		local bOk = ATOMDefense:HandleShoot(hShooter, hWeapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId)
		if (not bOk) then
			return false end
		
		---------
		ATOMBroadcastEvent("OnShoot", hShooter, hWeapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId)

		---------
		if (hShooter.isPlayer) then
			self.ShotsFired = (self.ShotsFired or 0) + 1
		end

		---------
		if (hShooter.megaGod or hShooter.unlimitedAmmo) then
			Script.SetTimer(1, function()
				-- hWeapon.weapon:SetAmmoCount(nil, hWeapon.weapon:GetClipSize() + 1);
				ATOMEquip:RefillAmmo(hShooter, hWeapon.id, false)
			end)
		end
		
		---------
		local vHit = hit
		local vDir = hitNormal
		local aCfg = self.cfg.Immersion

		---------
		if (ammoClass and ammoId and (string.matchex(ammoClass, "scargrenade", "explosivegrenade"))) then
			self.GrenadeMap[ammoId] = ammoClass
		end

		---------
		if (aCfg) then
			local aEffects = aCfg.Effects;
			if (aEffects) then
				for i, aEffect in pairs(aEffects) do
					if (aEffect.Class == hWeapon.class and (not aEffect.Requires or hWeapon[aEffect.Requires] ~= nil) and not aEffect.Projectile) then
					
						---------
						if (aEffect.FirePos) then
							vHit = hShooter:GetPos() 
							vDir = g_Vectors.up end
					
						---------
						local vFixedPos
						local sEffectName = aEffect.Name
						if (type(sEffectName) == "function") then
							sEffectName, vFixedPos = sEffectName(hShooter, hWeapon, vHit) end
					
						---------
						if (vFixedPos) then
							vHit = vFixedPos end
					
						---------
						if (sEffectName) then
							if (aEffect.Damage) then
								Explosion(sEffectName, vHit, aEffect.Radius or 1, aEffect.Damage, vDir, hShooter, hWeapon, 1) else
								g_utils:SpawnEffect_Limited(tostring(hWeapon.id), sEffectName, vHit, vDir, aEffect.Scale) end
						end
						
						---------
						if (aEffect.Sound) then
							if (not aEffect.Delay or timerexpired(aEffect.Last, aEffect.Delay)) then
								aEffect.Last = timerinit()
								PlaySound((type(aEffect.Sound) == "table" and GetRandom(aEffect.Sound) or aEffect.Sound), vHit, aEffect.SoundVol)
							end
						end
					end
				end
			end
		end
		
		---------
		if (hWeapon.ShotgunFire and not hWeapon.ShotgunFiring) then
			hWeapon.ShotgunFiring = true
			local p = hWeapon.ShotgunFire
			local pellets = p.Pellets or 8
			local spread = (p.Spread or 0.08) * 100
			for i = 1, pellets do
				local tDir = add2Vec(dir, math.random(-spread, spread) / 100, math.random(-spread, spread) / 100, math.random(-spread, spread) / 100)
				hWeapon.weapon:ServerShoot(hWeapon.weapon:GetAmmoType() or "bullet", pos, tDir, tDir, CalcPos(pos, tDir, 2024), 0, 0, 0, 0, false)
			end;
			hWeapon.ShotgunFiring = false
		end
		
		---------
		local vehicle = hShooter.GetVehicle and hShooter:GetVehicle();
		if (vehicle and hWeapon.weapon:GetClipSize() ~= -1) then
			local vehicleWeapon = hShooter:GetVehicleWeapon(hWeapon.id);
			if (vehicleWeapon) then
				if (hShooter.megaGod or hShooter.unlimitedAmmo) then
					Script.SetTimer(1, function()
						local max = vehicle.inventory:GetAmmoCapacity(hWeapon.weapon:GetAmmoType());
						hWeapon.weapon:SetAmmoCount(hWeapon.weapon:GetAmmoType(), max)
						vehicle.vehicle:SetAmmoCount(hWeapon.weapon:GetAmmoType(), max);
					end)
				end
			end
		end
		
		---------
		if (hShooter.AimDebug) then
			hShooter.Shots = ((hShooter.Shots or 0) + 1) end
		
		---------
		hShooter.LastActivity = _time
		hShooter.LastShot = _time
		
		---------
		
		--for i, hPlayer in pairs(GetPlayers()) do
		--	if (GetDistance(hPlayer, hShooter) > 300) then
		--		if (timerexpired(hPlayer.LastBattleSound, 60)) then
		--			Debug("battle sound ??")
		--			hPlayer.LastBattleSound = timerinit()
		--			ExecuteOnPlayer(hPlayer, [[HE(eCE_Sound,g_localActor,"]]..GetRandom({"sounds/environment:island_sfx:koreans_fighting_scout_1", "sounds/environment:island_sfx:koreans_fighting_scout_2"})..[[");]]);
		--		end
		--	end
		--end
	end;
	--------------
	WaitForProfile = function(self, player)
		self.waitingForProfiles[player.id] = { time = _time, player = player.id };
	end;
	--------------
	OnChatMessage = function(self, t, idSender, tId, m)
		
		--------------
		local hSender = GetEnt(idSender);
		if (not hSender) then 
			SysLog("Invalid entity tried to send a chat message! (msg = %s)", tostring(m))
			return false end
		
		--------------
		local sMessage = m
		local sSender = hSender:GetName()
		local sTarget = "<Unknown>"
		if (t == ChatToTeam) then
			sTarget = "Team"
			elseif (t == ChatToAll) then
				sTarget = "All"
				else
					sTarget = EntityName(tId)
					end
		
		--------------
		ATOMLog:LogToLogFile(LOG_FILE_CHAT, "[{timediffer}] %s: (To: %s): %s", sSender, sTarget, sMessage)
		
		--------------
		if (not hSender.isPlayer) then
			return true end
		
		--------------
		RCA:OnResponse(hSender, 123);
		local isCommand = not ATOMCommands:IsCommand(t, idSender, tId, m);
		if (isCommand) then
			ATOMLog:LogToLogFile(LOG_FILE_CHAT, "                ^ Message Not Forwarded (Was Command)")
			return false end
		
		--------------
		local isMuted = ATOMPunish.ATOMMute:CheckMute(t, idSender, tId, m)
		if (isMuted) then
			ATOMLog:LogToLogFile(LOG_FILE_CHAT, "                ^ Message Not Forwarded (Player Muted)")
			return false end
		
		--------------
		if (not ATOMDefense:OnChatMessage(t, hSender, GetEnt(tId), m)) then
			ATOMLog:LogToLogFile(LOG_FILE_CHAT, "                ^ Message Not Forwarded (AntiCheat)")
			return false end
		
		--------------
		if (ATOMBroadcastEvent("OnChatMessage", t, idSender, tId, m) == false) then
			ATOMLog:LogToLogFile(LOG_FILE_CHAT, "                ^ Message Not Forwarded (Script Event)")
			return false end
		
		--------------
		if (not ATOMChat:OnChatMessage(t, idSender, tId, m)) then
			ATOMLog:LogToLogFile(LOG_FILE_CHAT, "                ^ Message Not Forwarded (ChatHandler)")
			return false end
		
		--------------
		if (t == ChatToTeam and hSender and hSender.CurrentMapCoords ~= "") then
			if (self.cfg.Immersion and self.cfg.Immersion.AppendSectorToChat) then
				--Debug("append it!")
				if (not string.match(m, "^%(Coords, [ABCDEF][0-9]%): (.*)")) then
					--Debug("not appended")
					m = "(Coords, " .. hSender.CurrentMapCoords .. "): " .. m
					g_game:SendChatMessage(ChatToTeam, idSender, tId, m)
					return false
				end
			end
		end
		
		--------------
		ATOMLog:LogChatMessage(t, idSender, tId, m)
		if (m == "bb" or m == "bye" or m == "cya") then
			hSender.RageQuitImpossible = true end
		
		--------------
		local bGiveExp, iExp = shouldGiveEXP("Chat")
		if (bGiveExp) then
			hSender:GiveEXP(iExp, false, nil) end
		
		--------------
		return true
	end;
	--------------
	CheckItemHit = function(self, item, hit)
		local cfg = self.cfg.DamageConfig
		if (item.class == "Claymore") then
			if (cfg.ExplodeClaymore and (item.clayHP or 50) > 0) then
				item.clayHP = (item.clayHP or 50) - hit.damage
				if (item.clayHP <= 0) then
					Explosion(ePE_Claymore, item:GetPos(), 4, 200)
					g_game:ScheduleEntityRespawn(item.id, false, checkNumber(item.Properties.Respawn.fTimer, 30))
					System.RemoveEntity(item.id)
				end
			end
		end
		
		local shooter = hit.shooter;
		if (shooter and (shooter.megaGod or shooter.Superman)) then
			item:AddImpulse(-1, hit.pos, hit.dir, 100000, 1)
		end
		
		return true
	end;
	--------------
	ProcessHit = function(self, hit)
		
		---------
		-- SysLog("Process hit %d", hit.damage)
		
		---------
		local iExecuteStart = timerinit()
		
		---------
		local cfg = self.cfg.DamageConfig;
	
		---------
		if (not ATOMDefense:OnHit(hit)) then
			return false end
		
		---------
		local hWeapon = hit.weapon
		local hShooter = hit.shooter
		local hTarget = hit.target
		local bIsSame = (hShooter == hTarget)
		
		local bShooterPlayer = hShooter and hShooter.isPlayer
		local bTargetPlayer = hTarget and hTarget.isPlayer
		
		local hCurrWeapon = (bShooterPlayer and hShooter:GetCurrentItem())
		local sCurrWeapon = (hCurrWeapon and hCurrWeapon.class)
		local sWeaponClass = (hWeapon and hWeapon.class)
		
		local vPos = hit.pos
		local vDir = hit.dir
		
		local bGod = (hShooter and hShooter.InGodMode and hShooter:InGodMode())
		local bMegaGod = (hShooter and hShooter.megaGod)

		local iDamage = hit.damage;
		local sHitType = hit.type;
		local sHitPart = hit.part;
		local sMaterial = hit.material_type;
		
		if (not sHitType or #sHitType < 3) then
			if (hit.explosion) then
				sHitType = "explosion"
			elseif (hShooter and hShooter == hTarget and iDamage <= 1000 and hShooter.isPlayer and not sMaterial and not weapon and sHitType == "") then
				sHitType = "fall"
			elseif (hShooter and weapon and hShooter == hTarget and hTarget == weapon and hShooter.isPlayer and iDamage == 8190 and hit.radius == 0 and not sMaterial and sHitType == "") then
				sHitType = "suicide"
			else
				sHitType = nil
			end
		end
		
		local bHeadshot = (sMaterial == "head")
		local hVehicle = (bShooterPlayer) and hShooter:GetVehicle()
		
		local iShooterTeam = g_game:GetTeam(hit.shooterId)
		local iTargetTeam = g_game:GetTeam(hit.targetId)
		
		---------
		if (hWeapon) then
			local idNewOwner = hWeapon.new_ownerId
			if (idNewOwner) then
				hit.shooterId = idNewOwner
				hit.shooter = GetEnt(idNewOwner)
			end
		end
		
		---------
		if (hCurrWeapon) then
			
			if (sCurrWeapon == "LAW" and sHitType == "explosion" and not sWeaponClass and not hWeapon) then
				hWeapon = sCurrWeapon
				sWeaponClass = sCurrWeapon
			end
		end
		
		---------
		if (hShooter and hShooter.OneHitKill) then
			hit.damage = 9999
			--Debug(">One hit kill!!")
		end
		
		if (hShooter and hTarget and hShooter.OnlyKillId and hShooter.OnlyKillId ~= hTarget.id) then
			hit.damage = 0
			--Debug(">invalid targt !!")
		end
		
		---------
		if (hTarget and g_localActor and hTarget.id == g_localActorId) then
			hit.damage = 0
			return end
		
		---------
		if (hShooter) then
		
			---------
			if (hShooter.nextHitDamage and iDamage == 0 and not hit.explosion and hWeapon and hWeapon.weapon) then
				hit.damage = hShooter.nextHitDamage
				iDamage = hit.damage
				hShooter.nextHitDamage = nil
			end
			
		
			---------
			if (GetEnt(hShooter.LastShooter)) then
				g_gameRules:CreateHit(hit.targetId, hShooter.LastShooter, hit.shooterId, hit.damage, hit.radius or 1, hit.material_type or 'mat_default', hit.part or -1, hit.type or "normal", hit.pos, hit.dir, hit.normal)
				return end
		
			---------
			if (hTarget) then
				if (not bIsSame) then
					if (bShooterPlayer) then
						if (sWeaponClass == "Fists") then
							if (hShooter.SuperBoxer and not hTarget.falling) then
								hTarget.actor:Fall(vPos)
								hTarget.lastFallTime = _time
								hTarget.falling = true
								hTarget:AddImpulse_All(-1, vPos, vDir, hShooter.SuperBoxerStrength, 1)
							end
							if ((hShooter.megaGod or hShooter.Superman)) then
								hTarget:AddImpulse(-1, vPos, vDir, 10000, 1)
							end
						end
					end
				end
				
				if (g_gameRules.class ~= "InstantAction" and g_game:GetTeam(hTarget.id) ~= g_game:GetTeam(hShooter.id)) then
					hTarget.LastHitTime = _time;
				end
			end
		
			---------
			if (bShooterPlayer) then
				self.HitsLanded = (self.HitsLanded or 0) + 1
				
				if (hShooter.AFK) then
					hit.damage = 0
					SendMsg(CENTER, hShooter, "CANNOT KILL IN AFK MODE")

					if (hShooter.InStadium) then
						hit.damae = 0
						SendMsg(CENTER, hShooter, "Cannot kill while being in the Stadium!")
					end
					
				elseif (hShooter.GlassGrenades and hit.type == "frag") then
					hit.damage = hit.damage / 2.3
				end
			end
			
		end
		
		---------
		if (hTarget) then
		
			---------
			if (not bIsSame and (bShooterPlayer and bTargetPlayer)) then
				if (hTarget.AFK) then
					hit.damage = 0
					SendMsg(CENTER, hShooter, "%s Is AFK", hTarget:GetName())
				end
			end
			
			---------
			if (hTarget.invulnerable or hTarget.isServer) then
				-- Debug("God mode ?")
				return end
			
			---------
			if (bTargetPlayer) then
				
				---------
				if (hTarget:IsInGodMode()) then
					hit.damage = 0 end
				
				---------
				-- if (hVehicle and not bIsSame and (hTarget.actor:GetHealth() - iDamage) <= 0) then
					-- if (cfg.KillMessages) then
						-- local sVTOLMsg = (hVehicle.class == "US_vtol") and cfg.KillMessages[hVehicle.class];
						-- if (timerexpired(hTarget.hVtolRapeTimer, 60)) then
							-- SendMsg(CHAT_ATOM, hTarget, sVTOLMsg);
							-- hTarget.hVtolRapeTimer = timerinit()
						-- end
					-- end
				-- end
				
				---------
				local aRapingProtection = cfg.RapingProtection
				if (aRapingProtection.Bunker) then
					
					if (g_gameRules.class == "PowerStruggle") then
						if (iShooterTeam ~= iTargetTeam) then
						
							local hBunker = g_utils:GetClosestBuilding(hTarget:GetPos(), aRapingProtection.BunkerRadius, "bunker");
							if (hBunker) then
								local iBunkerTeam = g_game:GetTeam(hBunker.id)
								
								if (iBunkerTeam ~= 0 and iBunkerTeam == iTargetTeam) then
									
									local bProtect = true
									local sProtect = ""
									for sClass, bBlacklisted in pairs(aRapingProtection.BlacklistenItems) do
										if (bBlacklisted == true and hTarget.inventory:GetItemByClass(sClass)) then
											sProtect = i
											bProtect = false
											break
										end
									end
									
									local aProtect = aRapingProtection.ProtectFrom
									if ((hVehicle and aProtect[hVehicle.class]) or (hWeapon and aProtect[hWeapon.class])) then
										if (bProtect) then
											if (aRapingProtection.BlockDamage) then
												SendMsg(CENTER, hShooter, "Damage from %s Disabled near Bunkers!", (hVehicle and hVehicle.class or hWeapon.class))
												SendMsg(CENTER, hTarget, "You are protected against Spawn Killing")
												hit.damage = 0
											else
												SendMsg(CENTER, hShooter, "Damage from %s Reduced near bunkers!", (hVehicle and hVehicle.class or hWeapon.class))
												SendMsg(CENTER, hTarget, "You are protected against Spawn Killing")
												hit.damage = hit.damage * max(1, aRapingProtection.DamageMultiplier)
											end
										else
											SendMsg(CENTER, hTarget, "You are not protected with %s", sProtect)
										end
									end
								end
							end
						end
					end
				end
				
				---------
				if (bHeadshot and hTarget.HelmetShots) then
					if (hTarget.HelmetShots > 0) then
						hTarget.HelmetShots = hTarget.HelmetShots - 1
						hit.damage = 0
					else
						hTarget.HelmetShots = nil
						
						local hHelmet = GetEnt(hTarget.helmetID)
						if (hHelmet) then
						
							---------
							hTarget.__BOUGHT["HELMET"] = nil;
							hTarget:ResetAttachment(0, hHelmet.NAME)
							
							---------
							hHelmet:DestroyPhysics()
							hHelmet:Physicalize(0, PE_RIGID, {mass = 5})
							hHelmet:SetPos(hTarget.actor:GetHeadPos())
							hHelmet:AwakePhysics(1)
							hHelmet:EnablePhysics(true)
							RCA:Unsync(hHelmet, hHelmet.helmetSyncID)
							ExecuteOnAll([[
								local h=GetEnt(']]..hHelmet:GetName()..[[');
								local p=GP(]] .. hTarget:GetChannel() .. [[);
								if (h) then
									p:ResetAttachment(0,h.NAME);
									h:DestroyPhysics()
									h:Physicalize(0, PE_RIGID, {mass = 5});
									h:SetPos(p.actor:GetHeadPos());
									h:AwakePhysics(1);
									h:EnablePhysics(true)
									h:AddImpulse(-1,h:GetPos(),]]..arr2str_(hit.dir)..[[,400,1);
									h:AddImpulse(-1,h:GetPos(),]]..arr2str_(hit.dir)..[[,400,1);
								end;
							]])
							
							---------
							Script.SetTimer(10000, function()
								System.RemoveEntity(hHelmet.id) end)
						end
					end
				end
				
				if (hTarget and hTarget.ExitVehicleTime and _time - hTarget.ExitVehicleTime < 2.5 and hWeapon and hWeapon.vehicle and hWeapon.id == hTarget.ExitVehicleId) then
					hit.damage = 0
				end
				
			end
		end
		
		
		
		--Debug(hit.type)
		--Debug(hit.shooter.class)
	
		--Debug(shooter and target ~= shooter and weaponClass and shooter.AimDebug)
		-- if (shooter and target ~= shooter and weaponClass and shooter.AimDebug) then
			-- shooter.Hits = (shooter.Hits or {});
			-- shooter.Hits[weaponClass] = (shooter.Hits[weaponClass] or 0) +1;
			
			-- g_gameRules:CalculateAccuracy(shooter, false);
		-- end;
		--Debug("OO")
		
		---------
		if (bTargetPlayer and hTarget.InMeeting) then
			hit.damage = 0

		---------
		elseif (cfg.NoKillMode) then
			if (bTargetPlayer or cfg.NoKillAll) then
				hit.damage = 0
				
				if (bShooterPlayer and not bIsSame) then
					if (timerexpired(hShooter.KillBlockedMsgTimer, 5)) then
						SendMsg(CENTER, hShooter, "(NO KILL MODE IS ENABLED)")
						hShooter.KillBlockedMsgTimer = timerinit()
					end
				end
			end
			
		---------
		elseif (hShooter and hShooter.NoKill and not bIsSame) then
			hit.damage = 0
			
			if (bShooterPlayer) then
				if (timerexpired(hShooter.KillBlockedMsgTimer, 5)) then
					SendMsg(CENTER, hShooter, "(YOU HAVE NO KILL MODE ENABLED)")
					hShooter.KillBlockedMsgTimer = timerinit()
				end
			end
			
		---------
		elseif (bShooterPlayer and not bIsSame) then
			if (hShooter.HitInfo) then
				local iHealth = (hTarget.actor:GetHealth())
				local iEnergy = (hTarget.actor:GetNanoSuitEnergy() / 2)

				SendMsg(CENTER, hShooter, "(Health: %0.2f%%, Energy: %0.2f%%)", iHealth, iEnergy / 2) 

			end
		end
		
		---------
		if (sHitType == "fall") then
			hit.damage = hit.damage * checkNumber(cfg.FallDamage, 1) end
		
		---------
		local iDamageMult = cfg.PartMultipliers[(sMaterial or "unknown"):lower()];
		if (iDamageMult) then
			hit.damage = hit.damage * iDamageMult end
		
		---------
		if (sWeaponClass) then
		
			local aAutoDamage = cfg.AutoHealth
			if (aAutoDamage) then
			
				local aDamageProps = aAutoDamage[sWeaponClass]
				if (aDamageProps) then
				
					---------
					local iHealth = hTarget.actor:GetHealth()
					local iEnergy = hTarget.actor:GetNanoSuitEnergy()
					if (hTarget.actor:GetNanoSuitMode() == NANOMODE_DEFENSE) then
						iHealth = iHealth + (iEnergy / 2) end
					
					---------
					if (isArray(aDamageProps)) then
						if (iHealth > aDamageProps[2]) then
							hit.damage = iHealth - aDamageProps[1]
						end
					else
						hit.damage = iHealth - aDamageProps
					end
				end
			end
			
			---------
			if (cfg.OnlyDamageMode) then
				local bCanDamage = cfg.OnlyDamageFrom[sWeaponClass]
				if (not bCanDamage) then
					hit.damage = 0
					
					if (bShooterPlayer and timerexpired(hShooter.KillBlockedMsgTimer, 5)) then
						SendMsg(CENTER, hShooter, "(%s: Weapon Damage Disabled)", sWeaponClass)
						hShooter.KillBlockedMsgTimer = timerinit()
					end
				end
			else
				iDamageMult = cfg.DamageMultipliers[sWeaponClass]
				if (iDamageMult) then
					hit.damage = hit.damage * iDamageMult
				end
			end
		end
		
		---------
		if (hTarget and hTarget.InStadium) then
			hit.damage = 0 end
		
		---------
		if (bGod and not bMegaGod and (bTargetPlayer)) then
			SendMsg(CENTER, hShooter, "Cannot kill in normal God Mode");
			hit.damage = 0 end

		---------
		if (ATOMBroadcastEvent("OnHit", hit) == false) then
			return false end

		---------
		if (hit.hitBlocked) then
			return false end

		---------
		if (bTargetPlayer) then
			self.TotalDamage = (self.TotalDamage or 0) + checkNumber(hit.damage, 0)
		end

		---------
		if (hit.OneHitKill == true) then
			hit.damage = 999999 end
		
		---------
		if (ATOMTaunt) then
			ATOMTaunt:OnHit(hShooter, hTarget, hit) end
		
		---------
		g_utils:ProcessHit(hShooter, hTarget, hit)

		---------
		--[[
		local iExecuteEnd = timerdiff(iExecuteStart)
		self.debugHitTimers = checkArray(self.debugHitTimers, {}) 
		table.insert(self.debugHitTimers, iExecuteEnd)
		
		if (table.count(self.debugHitTimers) > 60) then
			
			local iTimeAvg = 0
			local sLast10 = ""
			for i, iHitTime in pairs(self.debugHitTimers) do
			
				iTimeAvg = iTimeAvg + iHitTime
				
				if (i <= 10) then
					sLast10 = sLast10 .. iHitTime .. ","
				end
			end
			
			PuttyLog("$1Speedtest Result: $4%d Samples$1, Time Avg: $4%f$1, Last 10: $8%s$1", table.count(self.debugHitTimers), iTimeAvg, string.ridtrail(sLast10, ","))
			
			self.debugHitTimers = {}
		end
		]]
		---------
		return true;
	end;
	--------------
	OnModifiedFile = function(self, idPlayer, sFile)
	
		SysLog("Player %s is using modified file %s", idPlayer:GetName(), sFile)
		
		local aCfg = ATOM.cfg.ModifiedFiles
		local iFileCount = aCfg.MaxModifiedFiles
		
		idPlayer.MODIFIED_FILES = (idPlayer.MODIFIED_FILES or 0) + 1
		
		if (aCfg.KickModifiedFiles) then
			if (iFileCount <= 0) then
				return KickPlayer(self.Server, idPlayer, "Modified Files") end
				
			if (idPlayer.MODIFIED_FILES >= iFileCount) then
				return KickPlayer(self.Server, idPlayer, string.format("Limit %d of Modified Files reached", iFileCount)) end
		end
		
		
		if (aCfg.SendMessage) then
			--Debug("messae !!")
			--Debug("access->", minimum(idPlayer:GetAccess() + 1, aCfg.Access))
			SendMsg(CHAT_DEFENSE, minimum(idPlayer:GetAccess() + 1, aCfg.Access), "(%d\\%d) - %s Is Using a Modified file (%s)", idPlayer.MODIFIED_FILES, iFileCount, idPlayer:GetName(), sFile)
			ATOMLog:LogModifiedFile(minimum(idPlayer:GetAccess() + 1, aCfg.ConsoleAccess or aCfg.Access), "%s$9 Is Using a Modified file ($4%s$9)", idPlayer:GetName(), sFile)
		end
	end,	
	--------------
	OnSpectating = function(self, player, target)
		if (player.LastSpecTime and not player:HasAccess(MODERATOR)) then
			local cfg = self.cfg.Spectator;
			local time = cfg.Time;
			local timeout = cfg.Timeout or 10;
			local max = cfg.Limit;
			if (_time - player.LastSpecTime < time) then
				player.SpectatorSpam = (player.SpectatorSpam or 0) + 1;
			else
				player.SpectatorSpam = 0;
			end;
			if (player.SpectatorSpam > max) then
				player.SpectatorTimeoutReason = "Spamming";
				player.SpectatorTimeout = _time;
				player.SpectatorTimeoutDur = timeout;
				SendMsg(CHAT_WARN, MODERATOR, "(%s: Is Spamming Spectator mode (%d in %0.2fs))", player:GetName(), player.SpectatorSpam, _time - player.LastSpecTime);
				player.SpectatorSpam  = 0;
				return false;--, SendMsg(ERROR, player, "Do not Spam Spectator");
			--elseif (player.SpectatorTimeout and _time - player.SpectatorTimeout < timeout) then
			--	return false, formatString("Spectator mode blocked for %0.2fs (Spam)", _time - player.SpectatorTimeout);
			end;
		else
			player.SpectatorSpam  = 0
		end
		return g_utils:OnSpectating(player, target);
	end,
	--------------
	OnCollision = function(self, entity, target, ...) --entity, target, normal, radius)
		--Debug("Ups")
		if (target and target == 0) then
			target = nil; -- C++ Fix
		end;
		if (target) then
			local p = {...};
			if (target.class == "Door" and entity.vehicle and not target:IsOpen()) then
				local relative = target.Properties.Rotation.bRelativeToUser;
				target.Properties.Rotation.bRelativeToUser = 1;
				target.Server.SvRequestOpen(target, (entity:GetDriver()or ATOM.Server).id, true, true);
				target.Properties.Rotation.bRelativeToUser = relative;
				SpawnEffect("explosions.Deck_sparks.VTOL_explosion", p[2], GetDir(entity, p[2]), 0.05)
			end;
		end;
		ATOMBroadcastEvent("OnCollision", entity, target, ...); --entity,  target, normal, radius);
	end;
	--------------
	SendInfoMessages = function(self, player)
		
		Script.SetTimer((player.IDReceived and 0 or 3) * 1000, function()
			local ATOMLOGO = { -- this is fucking handmade :)
	--[[
				[01]  = '$4    ___  __________  __  ___     _____ __________ _    __',
				[02]  = '$4   /   |/_  __/ __ \\/  |/  /    / ___// ____/ __ \\ |  / /',
				[03]  = '$4  / /| | / / / / / / /|_/ /_____\\__ \\/ __/ / /_/ / | / / ',
				[04]  = '$4 / ___ |/ / / /_/ / /  / /_____/__/ / /___/ _, _/| |/ /  ',
				[05]  = '$4/_/  |_/_/  \\____/_/  /_/     /____/_____/_/ |_| |___/   ',
														  
	--]]
				
				--[01]  = '$9' .. space(1),
				--[02]  = '$4       ________  _________  ________  _____ ______           ________   _______   ________  ___      ___ ',
				--[03]  = '$4      |\\   __  \\|\\___   ___\\\\   __  \\|\\   _ \\  _   \\        |\\    ____\\|\\  ___ \\ |\\   __  \\|\\  \\    /  /|',
				--[04]  = '$4      \\ \\  \\|\\  \\|___ \\  \\_\\ \\  \\|\\  \\ \\  \\\\\\__\\ \\  \\  ______\\ \\  \\___|\\ \\   __/|\\ \\  \\|\\  \\ \\  \\  /  / /',
				--[05]  = '$4       \\ \\   __  \\   \\ \\  \\ \\ \\  \\\\\\  \\ \\  \\\\|__| \\  \\|\\______\\ \\_____  \\ \\  \\_|/_\\ \\   _  _\\ \\  \\/  / / ',
				--[06]  = '$4        \\ \\  \\ \\  \\   \\ \\  \\ \\ \\  \\\\\\  \\ \\  \\    \\ \\  \\|______|\\|____|\\  \\ \\  \\_|\\ \\ \\  \\\\  \\\\ \\    / /  ',
				--[07]  = '$4         \\ \\__\\ \\__\\   \\ \\__\\ \\ \\_______\\ \\__\\    \\ \\__\\         ____\\_\\  \\ \\_______\\ \\__\\\\ _\\\\ \\__/ /   ',
				--[08]  = '$4          \\|__|\\|__|    \\|__|  \\|_______|\\|__|     \\|__|        |\\_________\\|_______|\\|__|\\|__|\\|__|/ v0.0a',
				--[09]  = '$4                                                                \\|_________|                             ',
				[1]  = '$9' .. space(112, "="),
				[2]  = '$9' .. space(32) .. "Welcome, $5" .. (player:GetName() or "Nomad").. "$9, To the ATOM-Server!" .. space(50),
				[3]  = '$9' .. space(112, "="),

				
				
				--[[
				[01]  = ' ________  _________  ________  _____ ______                           ________  _______   ________  ___      ___ _______   ________     ',
				[02]  = '|\\   __  \\|\\___   ___\\\\   __  \\|\\   _ \\  _   \\         ___ ___        |\\   ____\\|\\  ___ \\ |\\   __  \\|\\  \\    /  /|\\  ___ \\ |\\   __  \\    ',
				[03]  = '\\ \\  \\|\\  \\|___ \\  \\_\\ \\  \\|\\  \\ \\  \\\\\\__\\ \\  \\       |\\__\\\\__\\       \\ \\  \\___|\\ \\   __/|\\ \\  \\|\\  \\ \\  \\  /  / | \\   __/|\\ \\  \\|\\  \\   ',
				[04]  = ' \\ \\   __  \\   \\ \\  \\ \\ \\  \\\\\\  \\ \\  \\\\|__| \\  \\      \\|__\\|__|        \\ \\_____  \\ \\  \\_|/_\\ \\   _  _\\ \\  \\/  / / \\ \\  \\_|/_\\ \\   _  _\\  ',
				[05]  = '  \\ \\  \\ \\  \\   \\ \\  \\ \\ \\  \\\\\\  \\ \\  \\    \\ \\  \\         ___ ___       \\|____|\\  \\ \\  \\_|\\ \\ \\  \\\\  \\\\ \\    / /   \\ \\  \\_|\\ \\ \\  \\\\  \\| ',
				[06]  = '   \\ \\__\\ \\__\\   \\ \\__\\ \\ \\_______\\ \\__\\    \\ \\__\\       |\\__\\\\__\\        ____\\_\\  \\ \\_______\\ \\__\\\\ _\\\\ \\__/ /     \\ \\_______\\ \\__\\\\ _\\ ',
				[07]  = '    \\|__|\\|__|    \\|__|  \\|_______|\\|__|     \\|__|       \\|__\\|__|       |\\_________\\|_______|\\|__|\\|__|\\|__|/       \\|_______|\\|__|\\|__|',
				[08]  = '                                                                         \\|_________|                                                    ',
				--]]
			};
			
			for i = arrSize(ATOMLOGO), 1, -1 do
				SendMsg(CONSOLE_NOQUENE, player, ATOMLOGO[i]);
			end;
		end);
		
		local access = player:GetAccess();
		local accessString = GetGroupData(access);

		if (not player.WB) then
			local ts = atommath:Get("timestamp")
			local LastSeen = player.GetLastSeen and player:GetLastSeen() or nil; --calcTime(target:GetLastSeen(), false, false, false, false, true);
			
			if (not LastSeen) then
				LastSeen = "Never"
			elseif (tonum(math_sub(ts,LastSeen)) < ONE_DAY) then
				LastSeen = "Today";
			elseif (tonum(math_sub(ts,LastSeen)) < ONE_DAY * 2) then
				LastSeen = "Yesterday"
			elseif (tonum(math_sub(ts,LastSeen)) < ONE_DAY * 4) then
				LastSeen = "A Few Days Ago"
			else
				LastSeen = round(math_div(math_sub(ts, LastSeen), ONE_DAY)) .. " Days ago"; --round(tonumber(math_div(ONE_DAY, math_sub(ts, LastSeen)))) .. " Days ago";			
			end;
			if (access and access > PREMIUM) then
				accessString = accessString[2];
				SendMsg(CHAT_ATOM, player, "Welcome Back, " .. accessString .. " " .. player:GetName() .. " " .. (LastSeen and "Your last Visit: " .. LastSeen or ""));
			else
				SendMsg(CHAT_ATOM, player, "Welcome, " .. player:GetName() .. ", To our Server " .. (LastSeen and "Your last Visit: " .. LastSeen or ""));
			end;
			player.WB = true;
		end;

	end;
	--------------
	OnConnected = function(self, player, channelId, ip, host, port, isReset)

		if (player and g_localActor and player == g_localActor) then
			return;
		end;

		local aConnection = self.activeConnections[channelId]
		if (not aConnection) then
			self.activeConnections[channelId] = {
				_time, ip, g_statistics:GetValue("ConnTotal")
			}
			aConnection = self.activeConnections[channelId]
		end

		player.TotalChannelID = aConnection[3]
		player.conTime = _time - aConnection[1]
		self.activeConnections[channelId] = nil
		player.isPlayer = true

		PuttyLog("CATOM::NewPlayer %d", channelId)
		g_statistics:AddToValue("PlayerTotal", 1)
		CONNECTED = (CONNECTED or 0) + 1


	
		local countryData = self.channelCCs[channelId] or {}
		
		
	
		local specialProfile = self.cfg.IPProfiles[(self.channelIPs[channelId] or ip)];
		--Debug("ip",(self.channelIPs[channelId] or ip))
		--Debug("host",host)
		--Debug("specialProfile",specialProfile)
		--Debug("player.profileId",player.profileId)
		-- specialProfile must be a number
		if ((not player.profileId or player.profileId == "0") and specialProfile and tonumber(specialProfile)) then
			player.profileId = specialProfile;
			player.specialProfile = specialProfile;
			player.actor:SetProfileId(tonum(specialProfile));
			SysLog("Assigning special profile to player %s on channel %d (Id: %s)", player:GetName(), channelId, specialProfile)
			PuttyLog("$4No ID found for %d, using emergency ID %d", channelId, specialProfile)
		end
	
		--self:InitPlayer(player, true)
		ATOM_Utils.InitPlayer(player, channelId, (self.channelIPs[channelId] or ip), host, port, player.profileId, player.accountName, (countryData and countryData.countryName), (countryData and countryData.countryCode), (countryData and countryData.continentName), (countryData and countryData.continentCode));
		ATOMPlayerUtils.InitPlayer(player, channelId)
		ATOMEquip:InitPlayer(player)
		ATOM_Usergroups.InitPlayer(player)
		ATOMLevelSystem:InitPlayer(player)
		ATOMBank:InitPlayer(player)
		ATOMReports:OnConnected(player)
		
		if (CLIENT_MOD) then
			RCA:InitPlayer(player)
		end
		
		ATOMPunish.AutoWarns:InitPlayer(player)
		ATOMBroadcastEvent("InitPlayer", player, channelId);
		
		table.insert(LOGGED_CONNECTIONS, {
			name = player:GetName(),
			con_time = player.conTime,
			id = player:GetProfile(),
			client = (player.LuaClient and player.LuaClient[2] or "Unknown"),
			time = _time,
		});
		
		
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTED]  [{timediffer}] Player %s Connected On Channel %d (Took %s)", (player:GetName()), channelId, SimpleCalcTime(player.conTime))
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTED]                  -> Country: %s (%s)", (countryData and countryData.countryName or "<Unknown>"), (countryData and countryData.continentName or "<Unknown>"))
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTED]                  -> Profile: %s", (tostring(player:GetProfile())))
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTED]                  ->  Access: %s", (tostring(player:GetAccessString())))
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTED]                  ->  Client: %s", (player.LuaClient and player.LuaClient[2] or "<Unknown>"))

		
		local aBan, idBan = ATOMDefense:IsBanned(nil, (self.channelIPs[channelId] or ip), host, player.profileId, player:GetIdentifier());
		if (aBan) then
			return true, ATOMDLL:Ban(channelId, aBan.Reason)
		end
		
		local bReported = ATOMReports:IsReported(player.profileId)
		if (bReported) then
			player.IsReported = true
		end;
		
		local aCfg = self.cfg.Connection
		if (not aCfg or (aCfg and (not aCfg.LogWhenProfileReceived or player.IDReceived))) then
			player.connectionLogged = true
			ATOMStats:InitPlayer(player)
			ATOMLog:LogConnect(player)
			self:SendInfoMessages(player)
			ATOM_Usergroups:CheckProtectedName(player)
		else
			self:WaitForProfile(player)
		end
		
		local country = countryData.countryCode and "(" .. countryData.countryCode .. ")" or "";
		
		local aMsgCfg = self.cfg.Connection.ChatMessage;
		if (aMsgCfg and aMsgCfg.Access and aMsgCfg.SendMessage) then
			local conStr = isReset and "Reconnected" or "Connected";
			SendMsg(CHAT_ATOM, GetPlayers(aMsgCfg.Access, true, player.id), "(%s: %s on slot %d, %s)", player:GetName(), conStr, channelId, (player.LuaClient and player.LuaClient[2] or "Unknown Client"));
			SendMsg(CHAT_ATOM, GetPlayers(aMsgCfg.Access, false, player.id), "(%s%s: %s on slot %d, %s)", (player.IsReported and "(REPORT)" or ""), player:GetName(), conStr, channelId, (player.LuaClient and player.LuaClient[2] or "Unknown Client"));
		end;

		local aLogCfg = self.cfg.Connection.BattleLog;
		if (aLogCfg and aLogCfg.SendMessage) then
			if (not CryAction.IsChannelOnHold(channelId)) then
				g_gameRules:ResetScore(player.id);
				g_gameRules.otherClients:ClClientConnect(channelId, country .. player:GetName(), false)
			else
				g_gameRules.otherClients:ClClientConnect(channelId, country .. player:GetName(), true)
			end;
		end;
		--Debug("cfg",cfg,"Access",cfg.Access)
		--Debug("??")
		ATOMBroadcastEvent("OnConnected", player, channelId);
		
		if (player:HasAccess(SUPERADMIN) and LOGGED_ERRORS and arrSize(LOGGED_ERRORS)>1) then
			Script.SetTimer(5000, function()
				if (arrSize(LOGGED_ERRORS)>1) then
					SendMsg(CHAT_ERROR, player, "Found [ %d ] New Logged Script Errors, use !errors to check them", arrSize(LOGGED_ERRORS));
				end;
			end);
		end;
		
		if (ATOMSpawns) then
			ATOMSpawns:Init();
		end;
		
		player.CONNECTED_TIME = _time
	end;
	--------------
	GetReason = function(self, reason, player)
		local real   = checkVar(reason, "N/A")
		local reason = string.lower(real)

		if (reason:find("user left the game")) then
			real 	 = "User decision";
			if (player and type(player) == "table" and player.LastDeathTime and _time - player.LastDeathTime < 10 and not player.RageQuitImpossible) then
				real = "Rage Quit";
			end;
		elseif (reason:find("timeout")) then
			real 	 = "Connection Timeout";
			if (player and type(player) == "table" and player.LastDeathTime and _time - player.LastDeathTime - self.cfg.Network.ConnectionTimeout < 10 and not player.RageQuitImpossible) then
				real = "Rage Quit";
			end;
		elseif (reason:find("physics")) then
			real 	 = "CryPhysics Error";
		elseif (reason:find("aspect") or reason:find("object") or reason:find("entity")) then
			real 	 = "Game Error";
		elseif (reason:find("rmi")) then
			real 	 = "RMI Error";
		elseif (reason:find("unreachable")) then
			real 	 = "Connection Lost";
		elseif (reason:find("differs")) then
			real 	 = "Modifed Map";
		elseif (reason:find("nub destroyed")) then
			real 	 = "Fatal Game Error";
		elseif (reason:find("password")) then
			real 	 = "Invalid Password";
		else
			local x, rules, map = reason:match("(.*)/(.*)/(.*)");
			if (x and rules and map) then
				real = formatString("Missing map (%s)", map);
			end;
		--	real 	 = "Unknown Cause";
		end;
		return real;
	end;
	--------------
	GiveItem = function(self, hPlayer, sClass, iCount, bDrawWeapon)
	
		if (not ATOMDLL:IsValidEntityClass(sClass)) then
			return nil
		end
	
		local iIndex
		local aGuns = {}
		local idLastGun
		local iCount = max(min(checkNumber(iCount, 1), 1), 999)
		
		-- if we have the gun already, just stock up ammo
		local hInvWeapon = GetEnt(hPlayer.inventory:GetItemByClass(sClass))
		if (hInvWeapon and hInvWeapon.weapon) then
			local sInvAmmo = hInvWeapon.weapon:GetAmmoType()
			if (sInvAmmo) then
				iIndex = ATOM:GetAmmoCapacityIndex(sInvAmmo)
				Debug( ATOM:GetAmmoCapacity()[iIndex][2])
				if (iIndex and iCount ~= ATOM:GetAmmoCapacity()[iIndex][2] ) then
					self:ChangeCapacity(hPlayer, { [iIndex] = { sInvAmmo, iCount, iIndex } })
				else
					self:ChangeCapacity(hPlayer)
				end
				
				if (bDrawWeapon) then
					hPlayer.actor:SelectItemByNameRemote(hInvWeapon.class)
				end
				
				ATOMEquip:RefillAmmo(hPlayer, hInvWeapon.id)
			end
			return { hInvWeapon }, hInvWeapon
		end
		
		
		for i = 1, (iCount) do
			
			idLastGun = ItemSystem.GiveItem(sClass, hPlayer.id, true)
			if (not idLastGun) then
				SysLog("Attempt to Equip Player with Invalid Weapon (%s)", sClass) 
				return
			end
			
			table.insert(aGuns, System.GetEntity(idLastGun))
		end
		
		local hWeapon = aGuns[1]
		if (hWeapon.weapon) then
		
			local sAmmoClass = (hWeapon.weapon:GetAmmoType())
			iIndex = ATOM:GetAmmoCapacityIndex(sAmmoClass)
			
			if (hPlayer.isPlayer and hPlayer.aAmmoCapacity[iIndex]) then
				if (hPlayer.aAmmoCapacity[iIndex][2] < (iCount)) then
					self:ChangeCapacity(hPlayer, { [iIndex] = { sAmmoClass, iCount, iIndex } })
				else
					self:ChangeCapacity(hPlayer)
				end
			end
		end
		
		local hGun = System.GetEntity(idLastGun)
		if (hGun and hGun.weapon and bDrawWeapon) then
			hPlayer.actor:SelectItemByNameRemote(sClass)
		end
		
		return aGuns, hGun
	
		-- local guns = {};
		-- if (ATOMDLL:IsValidEntityClass(class)) then
			-- local lastGunId;
			-- for i = 1, (count or 1) do
				-- lastGunId = ItemSystem.GiveItem(class, player.id, true);
				-- table.insert(guns, GetEnt(lastGunId));
			-- end;
			-- if (not guns[1]) then
				-- return SysLog("attemp to give invalid weapon to player (was %s)", class);
			-- end;
			-- if (guns[1].weapon) then
				-- local at = guns[1].weapon:GetAmmoType();
				-- if (player.isPlayer) then
					-- if (  player.ammoCapacity_string[at] and(count or 1) > player.ammoCapacity_string[at][1]) then
				
						-- self:ChangeCapacity(player, { [player.ammoCapacity_string[at][2]]=(count or 1)*minimum(1,guns[1].weapon:GetClipSize()) }); --player.ammoCapacity_string[at][1]
					-- else
				
						-- self:ChangeCapacity(player);
					-- end;
				-- end;
			-- end;
			-- local gun = GetEnt(lastGunId);
			-- if (gun and gun.weapon) then
				-- if (doDraw) then
					-- player.actor:SelectItemByNameRemote(class);
				-- end;
			-- end;
			-- return guns, gun;
		-- end;
	end;
	--------------
	
	GetAmmoCapacity = function(self)
	
		----------
		local aAmmoCapacity = {
			{ "bullet",				300,  1 },
			{ "fybullet",			300,  2 },
			{ "lightbullet",		300,  3 },
			{ "smgbullet",			300,  4 },
			{ "explosivegrenade",	3, 	  5 },
			{ "flashbang",			3,	  6 },
			{ "smokegrenade",		3,	  7 },
			{ "empgrenade",			3,	  8 },
			{ "scargrenade",		6,	  9 },
			{ "rocket",				6,	  10 },
			{ "sniperbullet",		60,	  11 },
			{ "tacbullet",			3,	  12 },
			{ "tagbullet",			15,	  13 },
			{ "gaussbullet",		30,	  14 },
			{ "hurricanebullet",	2000, 15 },
			{ "incendiarybullet",	240,  16 },
			{ "shotgunshell",		120,  17 },
			{ "avexplosive",		3,	  18 },
			{ "c4explosive",		3,	  19 },
			{ "claymoreexplosive",	3,	  20 },
			{ "rubberbullet",		120,  21 },
			{ "tacgunprojectile",	4,	  22 },
		}
		
		----------
		return aAmmoCapacity
	end,
	
	--------------
	
	GetAmmoCapacityIndex = function(self, sAmmoName)
		
		----------
		local aAmmoCapacity = self:GetAmmoCapacity()
		return table.lookupI(aAmmoCapacity, sAmmoName, 1)
	end,
	
	--------------
	ChangeCapacity = function(self, hPlayer, aCustomCapacity, iForcedCapacity)
	
		----------
		local aAmmoCapacity = self:GetAmmoCapacity()
	
		----------
		if (hPlayer.aCustomCapacity and not hPlayer.megaGod) then
			aAmmoCapacity = mergeTables(aAmmoCapacity, hPlayer.aCustomCapacity)
		end
	
		----------
		if (aCustomCapacity) then
			aAmmoCapacity = mergeTables(aAmmoCapacity, aCustomCapacity)
		end
	
		----------
		if (not hPlayer.inventory or not hPlayer.actor) then
			return false end
			
		----------
		local sCapacity = ""
		local iCapacity = 0
		local iSize = table.count(aAmmoCapacity)
		
		----------
		hPlayer.aAmmoCapacity = {}
		if (hPlayer.megaGod) then
			iForcedCapacity = 999
		end
		
		----------
		for i = 1, iSize do
			iCapacity = (checkNumber(iForcedCapacity, aAmmoCapacity[i][2]))
			sCapacity = sCapacity .. (iCapacity) .. (i < iSize and "," or "")
			sAmmoName = aAmmoCapacity[i][1]
			
			hPlayer.inventory:SetAmmoCapacity(sAmmoName, iCapacity)
			if (hPlayer.inventory:GetAmmoCount(sAmmoName) > iCapacity) then
				hPlayer.inventory:SetAmmoCount(sAmmoName, iCapacity)
				hPlayer.actor:SetInventoryAmmo(sAmmoName, iCapacity)
			end
			
			hPlayer.aAmmoCapacity[i] = { sAmmoName, iCapacity, i }
			-- Debug(sAmmoName,"=",iCapacity)
		end
		
		----------
		hPlayer.allCap = sCapacity
		hPlayer.sAmmoCapacity = sCapacity
		hPlayer.aAmmoCapacity = aAmmoCapacity
		
		----------
		if (hPlayer.ATOM_Client) then
			ExecuteOnPlayer(hPlayer, "HE(8," .. (hPlayer.sAmmoCapacity) .. ")")
		end
		
		----------
		return true
	end;
	--------------
	HandleDetonate = function(self, player, detonator)
		local C4Timer = self.cfg.C4ExplosionDelay or 80;
		local allExplosives = player.placedExplosives[2];
		if (allExplosives) then
			for i, explosiveId in pairs(allExplosives) do
				--Debug(explosiveId)
				--Debug(g_game:ExplodeProjectile(explosiveId, true, false));
				Script.SetTimer(i * (i == 1 and 0 or C4Timer), function()
					g_game:ExplodeProjectile(explosiveId, true, false);
				--	HitEntity(explosiveId, 1000);
				end);
			end;
		end;
	end;
	--------------
	ProjectileExplosion = function(self, weapon, weaponClass, projectileId, effect, pos, dir, normal)

		LAST_PROJECTILE_REMOVED = false
		SKIP_PROJECTILE_EXPLOSION = false

		local weaponClass = weaponClass
		if (self.GrenadeMap[projectileId] and (string.empty(weaponClass) or (string.matchex(weaponClass, "OffHand", "FY71", "SCAR", "M4A1")))) then
			weaponClass = self.GrenadeMap[projectileId]
		end

		if (string.empty(weaponClass)) then
			weaponClass = ""
		end

		--SysLog("projectile exploded with class -> %s with effect -> %s on pos -> %s",weaponClass or "NULL",effect or "NULL",Vec2Str(pos) or "NULL")
		Debug("projectileId", projectileId)
		Debug("projectileId2", tostring(System.GetEntity(projectileId)or"<null>"))
		Debug("weaponClass", weaponClass)
		Debug("weapon", tostring(weapon))

		---------
		local vHit = pos
		local vDir = normal
		local aCfg = self.cfg.Immersion

		---------
		if (aCfg) then
			local aEffects = aCfg.Effects;
			if (aEffects) then
				for i, aEffect in pairs(aEffects) do
					if (aEffect.Class == weaponClass and (not aEffect.Requires or weapon[aEffect.Requires] ~= nil) and aEffect.Projectile) then
					
						---------
						if (aEffect.NoExplosion) then
							SKIP_PROJECTILE_EXPLOSION = true
							--Debug("Removed Projectile !!")
						end

						---------
						local vFixedPos
						local sEffectName = aEffect.Name
						local iEffectScale = checkNumber(aEffect.Scale, 1)
						if (type(sEffectName) == "function") then
							sEffectName, vFixedPos = sEffectName(weapon, vHit) end
					
						---------
						if (vFixedPos) then
							vHit = vFixedPos end
					
						---------
						local bUnderWater = g_utils:IsUnderwater({ x = vHit.x, y = vHit.y, z = vHit.z - 0.85 })
						if (bUnderWater) then
							-- Debug("its UNDERWATER")
							sEffectName = aEffect.WaterEffect
							iEffectScale = checkNumber(aEffect.WaterScale, iEffectScale)
						end
						---------
						if (aEffect.RemoveProjectile and (not aEffect.OnlyOnGround or not bUnderWater)) then
							--System.RemoveEntity(projectileId)
							LAST_PROJECTILE_REMOVED = true
							--Debug("Removed Projectile !!")
						end

						---------
						if (bUnderWater and aEffect.WaterRemoveProjectile) then
							--System.RemoveEntity(projectileId)
							LAST_PROJECTILE_REMOVED = true
							--Debug("Removed Projectile !!")
						end
					
						---------
						if (sEffectName) then
							if (type(sEffectName) == "table") then
								local sEffect, iScale
								for i, aTEffect in pairs(sEffectName) do
									if (type(aTEffect) == "table") then
										sEffect = aTEffect[1]
										iScale = aTEffect[2]
									else
										sEffect = aTEffect
										iScale = (aEffect.Scale or 1)
									end

									g_utils:SpawnEffect(sEffect, vHit, vDir, iScale)
								end
							else
								if (aEffect.Damage) then
									Explosion(sEffectName, vHit, aEffect.Radius or 1, aEffect.Damage, vDir, (weapon.weapon:GetOwner() or weapon), hWeapon, 1) else
									g_utils:SpawnEffect(sEffectName, vHit, vDir, iEffectScale)
								end
							end
						end

						---------
						local bWaterSoundPlayed = false
						if (bUnderWater and (aEffect.WaterSound or aEffect.WaterSound)) then
							if (not aEffect.WaterDelay or timerexpired(aEffect.LastWater, aEffect.WaterDelay)) then
								aEffect.LastWater = timerinit()

								local sWaterSound = aEffect.WaterSound
								if (isArray(sWaterSound)) then
									sWaterSound = GetRandom(sWaterSound)
								end
								PlaySound((sWaterSound or aEffect.Sound), vHit, aEffect.SoundVol)
								bWaterSoundPlayed = true
							end
						end
						
						---------
						if (aEffect.Sound and not bWaterSoundPlayed) then
							if (not aEffect.Delay or timerexpired(aEffect.Last, aEffect.Delay)) then
								aEffect.Last = timerinit()
								PlaySound((type(aEffect.Sound) == "table" and GetRandom(aEffect.Sound) or aEffect.Sound), vHit, aEffect.SoundVol)
							end
						end
					end
				end
			end
		end
		
		--[[
		local effects = self.cfg.Immersion;
		if (effects) then
			effects = effects.Effects;
			if (effects) then
				for i, effect in pairs(effects) do
					if (effect.Class == weaponClass) then
						if (effect.Projectile) then
							if (effect.WaterEffect and g_utils:IsUnderwater({ x = pos.x, y = pos.y, z = pos.z - 0.5 })) then
								g_utils:SpawnEffect(effect.WaterEffect, g_utils:GetWaterSurfacePos(pos), normal, effect.Scale)
							else
								g_utils:SpawnEffect(effect.Name, pos, normal, effect.Scale)
							end
						end
					end
				end
				--local effect = effects[weaponClass];
				--if (effect and 
				--if (weaponClass == "LAW") then
				--	g_utils:SpawnEffect("explosions.rocket_terrain.exocet", pos, normal);
				--end;
			end;
		end;
		]]

		self.GrenadeMap[projectileId] = nil

		if (ATOMTaunt) then
			ATOMTaunt:OnProjectileExplosion(weaponClass, projectileId);
		end


		local aSpawnCracks = {
			["rocket"] = true,
			["LAW"] = true,
			["Hellfire"] = true,
			["SideWinder"] = true,
			["explosivegrenade"] = false,
			["scargrenade"] = true
		}

		if (aCfg.UseExplosionCracks and aSpawnCracks[weaponClass] and pos.z > CryAction.GetWaterInfo(pos)) then
			local aRayHit = RayHit(add2Vec(pos, makeVec(0,0,0.3)), g_Vectors.down, 1)
			if (aRayHit and (aRayHit.surface == 140)) then

				EXPLOSION_CRACKS = checkArray(EXPLOSION_CRACKS)

				local bSpace = true
				for i, v in pairs(EXPLOSION_CRACKS or {}) do
					if (_time - v[1] < 60) then
						if (GetDistance(v[2], aRayHit.pos) < 5) then
							bSpace = false
							break
						end
					else
						table.remove(EXPLOSION_CRACKS, i)
					end
				end

				if (bSpace) then
					ExecuteOnAll([[ATOMClient:RegisterExplosionCrack(]] .. arr2str_(aRayHit.pos) .. [[)]]);
				end
				table.insert(EXPLOSION_CRACKS, { _time, aRayHit.pos })
			end
		end

		if (aCfg.EnhanceUnderwaterExplosions and (string.matchex(checkString(weaponClass,""), "C4", "explosivegrenade")) and CryAction.GetWaterInfo(pos) > pos.z) then
			g_utils:SpawnEffect("explosions.Grenade_SCAR.water", makeVec(pos.x, pos.y, (CryAction.GetWaterInfo(pos) or 0)), g_Vectors.up)
		end
	end;
	--------------
	OnProjectileCollision = function(self, proj, projId, owner, projClass, projPos)
		if (projClass == "explosivegrenade") then
			--Debug(owner.GlassGreandes)
			--Debug(proj)
			if (self.cfg.Immersion.GlassGrenades or (owner and owner.GlassGrenades)) then
				g_game:ExplodeProjectile(projId, true, false);
			end;
			--g_game:ExplodeProjectile(projId,true,false);
		end;
	end;
	--------------
	OnExplosiveHit = function(self, shooterId, projectileId, weaponId, damage, pos, dir, normal)
		local shooter = GetEnt(shooterId);
		local explosive = GetEnt(explosiveId);
		local weapon = GetEnt(weaponIdweaponId);
		
		if (weapon and damage > 0) then
			local explosiveTeam = g_game:GetTeam(projectileId);
			local shooterTeam = g_game:GetTeam(shooterId);
			
			if (explosiveTeam ~= 0) then
				if (explosiveTeam ~= shooterTeam) then
					--SendMsg(CENTER, shooter, "lol");
				else
					SendMsg(CENTER, shooter, "This is a friendly explosive!");
				end;
			end;
		end;
		--Debug("Hit :(")
	end;
	--------------
	HandleExplosive = function(self, t, player, explosive, t2)
		local types = {
			[0] = { "Claymore", System.GetCVar("g_claymore_limit")	or 5  },
			[1] = { "AVMine", 	System.GetCVar("g_avmine_limit")	or 4  },
			[2]	= { "C4", 		System.GetCVar("g_c4_limit")		or 50 }
		};
		local name, limit = types[t2][1], types[t2][2];
		player.placedExplosives = player.placedExplosives or { [0] = {}, [1] = {}, [2] = {} };
		
		
		if (t == 0) then
		
			if (not ATOMDefense:HandleExplosive(player, t2, explosive.id)) then
				SysLog("Explosive %s from %s was blocked.", explosive.class, player:GetName())
				return false
			end
		
			if (t2 == 2) then
				local strengthMode = player.actor:GetNanoSuitMode() == NANOMODE_STRENGTH;
				if (strengthMode) then
					local energyLeft = --[[100 * ]](player.actor:GetNanoSuitEnergy() / 200);
					local impulse = 500 * (player:InGodMode() and 1 or energyLeft) * (player.megaGod and 10 or 1);
					explosive:AddImpulse(-1, explosive:GetCenterOfMassPos(), player.actor:GetHeadDir(), impulse, 1);
				end;
				if (ATOMTaunt) then
					ATOMTaunt:OnExplosivePlaced(player, explosive, explosive:GetPos());
				end;
			end;
			table.insert(player.placedExplosives[t2], explosive.id);
			while (arrSize(player.placedExplosives[t2]) > limit) do
				local toRem = player.placedExplosives[t2][1];
				System.RemoveEntity(toRem);
				table.remove(player.placedExplosives[t2], 1);
			end;
			local cloak = (player:GetSuitMode() == NANOMODE_CLOAK) and t2 ~= 2;
			if (explosive and GetEnt(explosive.id)) then
				SendMsg(CENTER, player, "(%s" .. name:upper() .. ": PLACED (" .. arrSize(player.placedExplosives[t2]) .. " / " .. limit .. "))", (cloak and "CLOAKED-"or"")); 
				if (cloak) then
					local vPos = explosive:GetPos()
					local c = [[
						local vp1 = {x=]]..vPos.x..[[,y=]]..vPos.y..[[,z=]]..vPos.z..[[};local vc = ']]..explosive.class ..[[';local m = string.match;local e;for i, v in pairs(System.GetEntities()) do if (v.class == vc) then local vp2 = v:GetPos()  if (m(vp1.x, vp2.x) and m(vp1.y, vp2.y) and m(vp1.z, vp2.z)) then e=v break end end end if (e) then e:EnableMaterialLayer(true, 4) end
					]];
					Script.SetTimer(350, function()
						ExecuteOnAll(c)
						explosive.syncID = RCA:SetSync(explosive, { client = c, link = true });
					end)
				end;
			end;
			
			if (g_gameRules.class == "PowerStruggle" and t2 == 1) then
				g_gameRules.placed_avmines[explosive.id] = explosive; 
			end;
			
		elseif (t == 1) then
			for i, explosiveId in pairs(player.placedExplosives[t2]or{}) do
				if (explosiveId == explosive.id) then
					table.remove(player.placedExplosives[t2], i);
				end;
			end;
			
			local arr = arrSize(player.placedExplosives[t2]);
			
			--table.insert(player.placedExplosives[t2], explosive.id);
			--[[while (arrSize(player.placedExplosives[t2]) > limit) do
				local toRem = player.placedExplosives[t2][1];
				System.RemoveEntity(toRem);
				table.remove(player.placedExplosives[t2], 1);
			end;--]]
			if (t2 ==2 and player.lastExplosiveMessage and _time - player.lastExplosiveMessage < 0.1) then
			--	return;
			end;
			
			
			if (explosive and not explosive.WAS_DISARMED and GetEnt(explosive.id)) then
				--Debug(explosive:GetName())
				if (arr < limit) then
					SendMsg(CENTER, player, "(" .. name:upper() .. ": DETONATED (" .. arrSize(player.placedExplosives[t2]) .. " / " .. limit .. ") left)");
					player.lastExplosiveMessage = _time;
					
					if (t2 == 2) then
						if (player.MegaC4) then
							ATOMGameUtils:SpawnEffect("explosions.C4_explosion.fleet_reactor_wall", explosive:GetWorldPos());
						else
							ATOMGameUtils:SpawnEffect(GetRandom({ "ATOM_Effects.Explosions.C4_Explosion", "ATOM_Effects.Explosions.C4_Explosion", "ATOM_Effects.Explosions.C4_Explosion", "ATOM_Effects.Explosions.C4_Explosion", ePE_C4Explosive}), explosive:GetWorldPos(), g_Vectors.up, GetRandom(60, 80) / 100);
						end
					end
				else
				--	Debug("Last removed");
				end;
			end;
			
			if (g_gameRules.class == "PowerStruggle" and t2 == 1) then
				g_gameRules.placed_avmines[explosive.id] = nil; 
			end;
		end;
	end,
	
	--------------
	OnEntitySpawn = function(self, hEntity, aSpawnParams)
	
		--------
		if (aSpawnParams and (aSpawnParams.bLogSpawn or (aSpawnParams.properties and aSpawnParams.properties.bLogSpawn))) then
			SysLogVerb(1, "Spawning New Entity with name '%s'", (aSpawnParams.name or string.UNKNOWN))
		else
			--SysLog("No Params to .OnEntitySpawn")
		end

		if (not self.initialized) then
			return
		end

		ATOMPatcher:InitEntity(hEntity)

		if (not timerexpired(LAST_ENTITY_SPAWN, 0.1)) then
			if ((ENTITIES_SPAWNED or 0) >= 16) then

				if (timerexpired(LAST_ENTITY_SPAWN_LOG, 0.25)) then
					LAST_ENTITY_SPAWN_LOG = timerinit()
					SysLog("[Warning] Too many entities spawning ( %d )", ENTITIES_SPAWNED)
				end
				if (timerexpired(LAST_ENTITY_SPAWN_LOG_CONSOLE, 5)) then
					LAST_ENTITY_SPAWN_LOG_CONSOLE = timerinit()
					ATOMLog:LogWarning("Too many entities spawning ( %d )", ENTITIES_SPAWNED)
				end
			end

			--SysLog(aSpawnParams.name)
		else
			ENTITIES_SPAWNED = 0
			LAST_ENTITY_SPAWN = timerinit()
		end

		ENTITIES_SPAWNED = (ENTITIES_SPAWNED or 0) + 1
	end,
	
	--------------
	OnBeforeEntitySpawn = function(self, aSpawnParams)
	
		--------
		LAST_ENTITY_SPAWNED_NAME = nil
	
		--------
		if (not ATOM_INITIALIZED) then
			return true end
	
		--------
		if (aSpawnParams and (aSpawnParams.bLogSpawn or (aSpawnParams.properties and aSpawnParams.properties.bLogSpawn))) then
			SysLogVerb(1, "Spawning New Entity with name '%s'", (aSpawnParams.name or string.UNKNOWN)) 
		else
			--SysLog("No Params to .OnEntitySpawn")
		end
		
		--------
		-- SysLog("Flags: %d (CL = %d)", aSpawnParams.flags, ENTITY_FLAG_CLIENT_ONLY)
		if (aSpawnParams.flags == ENTITY_FLAG_CLIENT_ONLY) then
			return false end
		
		--------
		aSpawnParams = self:CheckEntitySpawnParameters(aSpawnParams)
		
		--------
		local sName = aSpawnParams.name
		local sClass = aSpawnParams.class
		local bIsVehicle = (string.findex(sClass, "US_*", "Asian_*", "Civ_*"))
		local bIsExplosive = (string.matchex(sClass, "c4explosive", "avexplosive", "claymoreexplosive"))
		
		--------
		if ((bIsExplosive or bIsVehicle) and (System.GetEntityByName(sName) or sName == "ammo")) then
			aSpawnParams.name = sName .. "_" .. sClass .. "_" .. g_utils:SpawnCounter() end
		
		--------
		LAST_ENTITY_SPAWNED_NAME = aSpawnParams.name
		return true
	end,
	
	--------------
	ActorRequest = function(self, request, player, p1, p2, p3, p4, p5, p6, p6, p8)
	
		local eAR_DropItem 		= 1
		local eAR_PickupItem 	= 2
		local eAR_UseItem 		= 3
		local eAR_SendRadio 	= 4
		local eAR_ExplosivePlaced 	= 5
		local eAR_ExplosiveRemoved 	= 6
		local eAR_Unfreeze 		= 7
		local eAR_HitAssistance = 8
		local eAR_Jump 			= 9
		local eAR_LockTarget 	= 10
		local eAR_DetonateExplosives = 11
		local eAR_ProjectileLaunched = 12
		local eAR_ZoomWeapon 	= 13
		local eAR_EnterFreefall = 14
		local eAR_OnFreeze 		= 15
		local eAR_Melee 		= 16
		local eAR_ReloadDone 	= 17
		local eAR_ReloadWeapon 	= 18
		local eAR_Lean 		= 19
		local eAR_FireMode 	= 20
		local eAR_Scanned 	= 21
		local eAR_Walljump 	= 22
		local eAR_Movement	= 23
		local eAR_PickupObject	= 24
		local eAR_ForwardPickup	= 25
		local eAR_DropObject	= 26
		local eAR_OnRevived		= 27
		local eAR_ShootSPoof		= 28

		local player = player
		if (player and type(player) == "userdata") then
			player = System.GetEntity(player)
		end
		
		local bStatus = true
		local bResetChat = false
		local bMoved = false
		
		if (player and request) then
		
			---------------------------
			if (type(player) ~= "table") then
				SysLog("DLL send %s to ActorRequest with requestId %d", type(player), request);
				player = System.GetEntity(player) 
				if (not player) then
					SysLog("DLL send invalid actor (%s) to ActorRequest with requestId %d", tostring(player), request)
				end
			end
			
			---------------------------
			if (type(request) ~= "number") then
				SysLog("DLL send request %s to ActorRequest", type(request)) end
			
			---------------------------
			local curr = player.actor and player.inventory:GetCurrentItem() or nil

			---------------------------
			if (request == eAR_DropItem) then

				Debug("drop")

				if (p1.class == "LAW") then
					--Debug(p1.weapon:GetAmmoCount())
					if (p1.weapon:GetAmmoCount() == 0 and not p1.dropAttempt) then
						p1.dropAttempt = true;
						--Debug("blocked drop");
						return false;
					end;
				end;
				if (ATOMDefense:CanDrop(player, p1)) then
					if (self.cfg.FixItemBugs) then
						if (curr) then
							local RH = player:GetHitPos(2.5);
							if (RH) then
								if ((curr.class == "DSG1" or curr.class == "Hurricane" or curr.class == "AlienMount") or (RH.surfaceName and RH.surfaceName:find("mat_glass"))) then -- prevent bugging factory windows by dropping items in it
									bStatus = false;
								end;
								--Debug("Drop >",bStatus)
							end;
						end;
					end;

					if (ATOMAttach) then
						for i, aItem in pairs(checkArray(player._fakeItems)) do
							if (aItem.parent == p1.id) then
								--Debug("Dropped attached item !!")
								ATOMAttach:Detach(player, p1, true)
							end
						end
					end

					if (bStatus) then
						bStatus = ATOMBroadcastEvent("CanDropItem", player, p1);
					end;
				else
					bStatus = false;
				end

				---------------------------
			elseif (request == eAR_PickupItem) then
				player.LastInteractiveActivity = _time;
				if (ATOMDefense:CanPickup(player, p1)) then

					if (p1.OnUse) then
						p1.OnUse(p1, player) end

					if (p1.unpickable or p1.Unpickable) then
						bStatus = false
					else

						bStatus = ATOMBroadcastEvent("CanPickupItem", player, p1)

						if (p1.OnPrePickup) then
							bStatus = p1:OnPrePickup(player, p1) end

						if (bStatus) then
							ATOMEquip:CheckItem(player, p1, nil, true, (g_gameRules.class == "PowerStruggle")) end

					end
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_UseItem) then

				if (ATOMDefense:CanUse(player, p1)) then
					bStatus = ATOMBroadcastEvent("CanUseItem", player, p1)
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_SendRadio) then

				if (not ATOMDefense:CheckRadio(player, p1)) then
					bStatus = false
				else
					bStatus = ATOMBroadcastEvent("CanSendRadio", player, p1)
				end

				---------------------------
			elseif (request == eAR_ExplosivePlaced) then

				self:HandleExplosive(0, player, p1, p2)
				ATOMBroadcastEvent("OnExplosivePlaced", player, p1, p2)

				---------------------------
			elseif (request == eAR_ExplosiveRemoved) then

				self:HandleExplosive(1, player, p1, p2)
				ATOMBroadcastEvent("OnExplosiveRemoved", player, p1, p2)

				---------------------------
			elseif (request == eAR_Unfreeze) then

				bStatus = ATOMBroadcastEvent("CanUnfreeze", player, p1, p2)

				---------------------------
			elseif (request == eAR_HitAssistance) then
				if (self.cfg.KickHitAssistance) then
					KickPlayer(self.Server, player, "Hit Assistance not Allowed")
					bStatus = false
				else
					SysLog("%s now using hit assistance !!", player:GetName())
					ATOMLog:LogGameUtils("Admin", "%s$9 Request Hit Assistance!", player:GetName())

					SendMsg(CHAT_ATOM, minimum(MODERATOR, player:GetAccess()), "(%s: Requested to use Hit Assistance!)", player:GetName())
					bStatus = ATOMBroadcastEvent("CanUseHitAssistance", player, p1, p2)

					player.HitAssistance = true

					if (not self.cfg.CanUseHitAssistance) then
						bStatus = false end
				end

				---------------------------
			elseif (request == eAR_Jump) then

				if (player.MenuSuicide) then
					HitEntity(player, 9999, player)
				end

				bMoved = true
				bResetChat = true
				bStatus = ATOMBroadcastEvent("CanJump", player, p1)

				---------------------------
			elseif (request == eAR_LockTarget) then
				if (ATOMDefense:CanLockTarget(player, p1, p2, p3, p4)) then
					bStatus = ATOMBroadcastEvent("CanLockTarget", player, p1, p2, p3, p4)
					if (bStatus) then
						g_utils:OnLockedTarget(player, p1, p2, p3) end
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_DetonateExplosives) then
				self:HandleDetonate(player, p1)

				---------------------------
			elseif (request == eAR_ProjectileLaunched) then
				if (not self:HandleProjectileLaunch(player, p1)) then
					bStatus = true
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_ZoomWeapon) then

				bResetChat = true
				if (not ATOMDefense:HandleZoom(player, p1)) then
					bStatus = true
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_EnterFreefall) then

				player.freeFall = true

				---------------------------
			elseif (request == eAR_OnFreeze) then

				ATOMBroadcastEvent("OnPlayerFroze", player, g_game:IsFrozen(player.id));

				---------------------------
			elseif (request == eAR_Melee) then

				bMoved = true
				bResetChat = true
				ExecuteOnAll("local p=GP(" .. player:GetChannel() .. ")if(p)then p:ClAnimationEvent(eCE_AnimMelee)end")
				ATOMBroadcastEvent("OnMelee", player, p1, p2, p3)

				---------------------------
			elseif (request == eAR_ReloadDone) then

				bResetChat = true

				--ATOMBroadcastEvent("OnReloadingWeapon", player, p1, p2, p3);
				local sAmmoType = curr.weapon:GetAmmoType()
				if (curr and sAmmoType) then
					if (sAmmoType == "scargrenade" and (g_gameRules.class == "InstantAction" or player.HasDoubleGrenadeAttachment)) then
						Script.SetTimer(100, function()
							curr.weapon:SetAmmoCount("scargrenade", 2)
						end)
						--	curr.weapon:SetAmmoCount(2);
						--end;
						--Debug("gluck")
					end
				end

				player.Shots = 0
				player.Hits = player.Hits or {}
				if (curr) then
					player.Hits[curr.class] = 0 end


				---------------------------
			elseif (request == eAR_ReloadWeapon) then

				--Debug("Reload")
				--ATOMBroadcastEvent("OnReloadingWeapon", player, p1, p2, p3);
				if (ATOMTaunt) then
					ATOMTaunt:OnEvent(eAT_EventReload, player) end

				---------------------------
			elseif (request == eAR_Lean) then

				bResetChat = true
				player.Leaning = p1 == true
				player.LeaningDirection = p2

				---------------------------
			elseif (request == eAR_FireMode) then

				bResetChat = true
				if (ATOMDefense:CheckFireMode(player, p1, p2)) then
					-- Debug(p1.weapon:SupportsAccessory("GrenadeLauncher"))
					if (p2 == 3 and p1.weapon:SupportsAccessory("GrenadeLauncher")) then
						Script.SetTimer(1, function()
							Debug(p1.weapon:GetAmmoCount())
							Debug(player.inventory:GetAmmoCount("scargrenade"))
							if (p1.weapon:GetAmmoCount() == 0 and player.inventory:GetAmmoCount("scargrenade") >= 1 and not p1.FirstNadeRefill) then
								-- Debug("fuggin nades :D");
								Script.SetTimer(1, function()
									p1.weapon:SetAmmoCount("scargrenade", 2);
								end)
								p1.FirstNadeRefill = true;
							end;
						end);
					end;
				else
					bStatus = false
				end

				---------------------------
			elseif (request == eAR_Scanned) then
				--Debug("ok lol now scanned")

				--------------
				local aTag = {
					["explosivegrenade"] = 1, ["c4explosive"] = 1,
					["claymoreexplosive"] = 1, ["avexplosive"] = 1
				}

				--------------
				local iTeam = player:GetTeam()
				local aEntities = System.GetEntities()

				--------------
				for i, entity in pairs(aEntities) do
					if (aTag[entity.class] and g_game:GetTeam(entity.id) ~= iTeam) then
						if (GetDistance(entity, p2) < (p3 / 2)) then
							entity.scannedTime = _time
							g_utils.taggedExplosives[entity.id] = entity
						end
					end
				end

				--------------
				if (g_gameRules.class == "PowerStruggle") then
					g_gameRules:AwardScanPP(player) end

				---------------------------
			elseif (request == eAR_Walljump) then
				player.hSvWallJumpTimer = timerinit()
				if (p1 and p1.class == "Fists") then
					player.hTimerWallJump = _time end
			elseif (request == eAR_Movement) then

				bResetChat = true
				bMoved = true
				player.iTimeLastMoved = _time
				player.bIsMoving = (p2 == true)

			elseif (request == eAR_PickupObject) then

				bResetChat = true
				if (p1.IsMountable) then
					bStatus = false
				else

					RCA:OnPickupObject(player, p1)
					bStatus = true
				end

			elseif (request == eAR_ForwardPickup) then

				Debug("Pickup on all")
				bStatus = true
				--if (GetBetaFeatureStatus("objectgrab")) then
				--	bStatus = false
				--end

			elseif (request == eAR_DropObject) then

				bResetChat = true
				RCA:OnDropObject(player, player.hPickedupObject)
				bStatus = true

			elseif (request == eAR_OnRevived) then

				-- Player, Pos, Ang, TeamID, ResetInventory, InVehicle, Vehicle
				g_utils:OnRevive(player, p1, p2, p3, p4, p5, p6, p7)

			elseif (request == eAR_ShootSPoof) then
				ATOMDefense:OnShootSpoof(player, p1)

			else
				SysLog("Invalid Request to ATOM.ActorRequest(%s)", tostring(request))
			end
		end
		
		if (bMoved) then
			-- Debug("player moved!")
			if (ATOMAnimations) then
				ATOMAnimations:StopAll(player)
			end
		end
		
		if (bResetChat) then
			-- Debug("reset chat !!!")
			RCA:HandleChat(player, 0)
		end
	
		return (not (bStatus == false))
	end;
	--------------
	HandleProjectileLaunch = function(self)
		return true
	end;
	--------------
	OnDisconnect = function(self, player, channelId, reason, keepClient, ghost)
	
		--------------------
		if (self.cfg.DynamicMaxPlayers) then
			System.SetCVar("sv_maxPlayers", g_game:GetPlayerCount() + 1) end
	
		--------------------
		ghost = ghost or player == nil or type(player)~="table";
	
		--------------------
		local realReason = self:GetReason(reason, player) or reason;
		if (not ghost and player and type(player) == "table" and player.Reconnecting) then
			realReason = "User Reconnecting";
		end;
		
		--------------------
		if (not ghost) then
			ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[DISCONNECT] [{timediffer}] Player %s Disconnecting From Channel %d (%s, %s)", (player:GetName()), channelId, (player.GetIP and player:GetIP() or "<Unknown>"), (realReason or "<Unknown>"), (reason or "<Unknown>"))
			ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[DISCONNECT]                 -> Connection Time: %s", SimpleCalcTime((player.GetPlayTime and player:GetPlayTime() or 0)))
		else
			ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[DISCONNECT] [{timediffer}] Channel %d Disconnecting (%s, %s)", channelId, (realReason or "<Unknown>"), (reason or "<Unknown>"))
		end
		
		--------------------
		DISCONNECTED = (DISCONNECTED or 0) + 1;
		if (realReason == "Game Error") then
			DISCONNECTED_ASPECT = (DISCONNECTED_ASPECT or 0) + 1
		else
			realReason = string.escape(realReason)
		end
		
		--------------------
		table.insert(LOGGED_DISCONNECTS, {
			name = type(player)=="table" and player:GetName() or "Unknown",
			play_time = type(player)=="table" and (player.GetPlayTime and player:GetPlayTime()) or 0,
			id = type(player)=="table" and player:GetProfile() or -1,
			client = type(player)=="table" and (player.LuaClient and player.LuaClient[2] or "Unknown") or "Unknown",
			time = _time,
		});
		
		--------------------
		local cfg = self.cfg.Connection.ChatMessage;
		if (not ghost) then

			--------------------
			PuttyLog("CATOM::RemovePlayer %d (Cause: %s)", player.actor:GetChannel(), string.escape(reason or realReason))
			
			--------------------
			if (player:HasAccess(ADMINISTRATOR)) then
				PuttyLog("$4Administration Offline") end
			
			--------------------
			local idExplosives = player.placedExplosives
			if (idExplosives and arrSize(idExplosives) > 0) then
				if (g_game:GetPlayerCount() >= 2) then
					if (g_gameRules.class == "PowerStruggle") then
						local idOtherPlayer = DoGetPlayers({ sameTeam = true, teamId = g_game:GetTeam(player.id), except = player.id })[1]
						if (idOtherPlayer) then
							SendMsg(CENTER, idOtherPlayer, "You Gained ownership of [ %d ] Explosives from %s", arrSize(idExplosives), player:GetName())
							
							for i, explosives in pairs(idExplosives) do
								for ii, explosiveId in pairs(explosives) do
									local explosive = GetEnt(explosiveId)
									if (explosive) then
										if (g_game.SetProjectileOwner) then
											g_game:SetProjectileOwner(explosiveId, idOtherPlayer.id)
										else
											explosive.new_ownerId = idOtherPlayer.id
										end
									end
								end
							end
							player.placedExplosives = nil
						end
					end
				end
			end
			
			--------------------
			for i, tplayer in pairs(GetPlayers()) do
				if (tplayer.PMGroup and tplayer.PMGroup[player.id]) then
					tplayer.PMGroup[player.id] = nil;
					if (arrSize(tplayer.PMGroup) == 0) then
						tplayer.PMGroup = nil;
						SendMsg(INFO, tplayer, "[ PM:SYSTEM ]-CONVERSATION ENDED (No Receivers)", player:GetName());
					else
						SendMsg(INFO, tplayer, "[ PM:SYSTEM ]-[ %s ]-REMOVED FROM CONVERSATION (Left The Game)", player:GetName());
					end;
				end;
			end;
			
			--------------------
			if (ATOMAttach) then
				ATOMAttach:ResetPlayer(player) end
				
			--------------------
			if (ATOMPack) then
				ATOMPack:Remove(player) end
				
			--------------------
			if (not player.noLogDisco and not player.wasKicked) then
				ATOMLog:LogDisconnect(player, realReason or "N/A") end
				
			--------------------
			if (player.ProtectionSphere) then
				System.RemoveEntity(player.ProtectionSphere.id) end
				
			--------------------
			if (player.GetChannel) then
				ATOMStats.PersistantScore:Save(player)
				ATOMStats.PermaScore:OnDisconnect(player)
				ATOMNames:OnDisconnect(player)
				ATOMLevelSystem:OnEXPChange(player)
				ATOMBank:OnBankChange(player)
				
				--------------------
				if (cfg and cfg.Access and cfg.SendMessage and not player.wasKicked) then
					SendMsg(CHAT_ATOM, GetPlayers(cfg.Access), "(%s: Disconnected (%s, %s))", player:GetName(), calcTime((player.GetPlayTime and player:GetPlayTime() or 0), true, unpack(GetTime_SMH)), realReason);
				end;
				
				--------------------
				ATOMBroadcastEvent("OnDisconnect", player, channelId, realReason);
			end;
		else
			if (realReason ~= "Connection denied") then 
				if (cfg and cfg.Access and cfg.SendMessage) then
					SendMsg(CHAT_ATOM, GetPlayers(cfg.Access), "(%s: Connection failed (%s))", tostr(self.channelIPs[channelId]), tostr(realReason));
					ATOMLog:LogToPlayer(LOG_CONNECTION, cfg.Access, formatString("Connection on slot %d Closed ($4%s, %s$9)", channelId, (self.channelIPs[channelId] or "<Unknown>"), realReason));
				end
			end
			
			--------------------
			if (reason:find("Aspect") or reason:find("ReconfigureObject")) then
				if (g_game:GetPlayerCount() < 1) then
					SysLog("Detected ObjectAspect Disconnection Error. Forcing server restart!")
					System.ExecuteCommand("sv_restart");
				end
			end
			
			--------------------
			SysLog("%s on channel %d failed to connect (%s, %s)", tostr(self.channelIPs[channelId]), tonum(channelId), tostr(realReason), tostr(reason))
		end
		
		--------------------
		if (ATOMSpawns) then
			ATOMSpawns:Init() end
		
		--------------------
		if (g_game:GetPlayerCount() == 0) then
			self:SaveIPDB() end
			
		--------------------
		g_gameRules.Server.OnClientDisconnect(g_gameRules, channelId, realReason)
	end;
	--------------
	OnBotConnection = function(self, bot)
		if (not self.cfg.AllowBots) then
			ATOMDLL:Kick(bot:GetChannel(), "Bots not Allowed.");
			return false;
		end;
		return true;
	end;
	--------------
	CheckCountry = function(self, aIPData, iChannel)
	
		local aBlacklist = self.cfg.BlacklistenCountries
		local aKicklist = self.cfg.RandomKickCountries
		local sCountry = aIPData and aIPData.countryName
		local sIP = aIPData and aIPData.ipAddress or "<null_ip>"
	
		if (sCountry) then
			local idPlayer = g_game:GetPlayerByChannelId(iChannel)
			
			if (aBlacklist[sCountry]) then
				if (idPlayer) then
					KickPlayer(self.Server, idPlayer, "Blacklisten Country");
				else
					ATOMDLL:Ban(iChannel, "Blacklisten Country");
					ATOMLog:LogConnection("Denied new Connection on slot %d ($4Blacklisten Country$9)", iChannel, sIP);
				end
				
			elseif (aKicklist[sCountry]) then
				if (GetRandom(1, 3) == 2) then
					if (idPlayer) then
						KickPlayer(self.Server, idPlayer, "Failed ReconfigureObject" .. GetRandom(1, 9))
					else
						ATOMDLL:Ban(iChannel, "Failed ReconfigureObject" .. GetRandom(1, 9))
						ATOMLog:LogConnection("Denied new Connection on slot %d ($4Game Error$9)", iChannel, sIP)
					end
				end
				SysLog("Kicking Blacklisted Country %s (channel %d)", sCountry, iChannel)
			end
		end
	end,
	--------------
	GetIPData = function(self, IP)
		if (not IP_DB) then
			return
		end

		return IP_DB[IP]
	end;
	--------------
	OnConnection = function(self, channelId, IP)
	
		--------------------
		if (self.cfg.DynamicMaxPlayers) then
			System.SetCVar("sv_maxPlayers", tonumber(channelId) + 1) end
	
		--------------------
		g_statistics:AddToValue("ConnTotal", 1);
		g_statistics:AddToValue("Channels", 1);

		--------------------
		CONNECTIONS = (CONNECTIONS or 0) + 1;
		HIGHEST_SLOT = channelId;
	
		--------------------
		self.channelIPs[channelId] = IP;
				
		--------------------
		local sAlias
		if (ATOMAlias) then
			sAlias = ATOMAlias:GetAliasByID(IP) end
	
		--------------------
		ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTION] [{timediffer}] New Connection on Slot %d (%s)", channelId, IP)
		if (not string.empty(sAlias)) then
			ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "[CONNECTION]                 -> Alias: %s", checkVar(sAlias, string.UNKNOWN)) 
		end
		
		--------------------
		local data
		
		--------------------
		local ban, banId = ATOMDefense:IsBanned(nil, IP)
		if (ban) then
			local sTime = ban.Expire
			if (string.lower(sTime) ~= "infinite") then
				sTime = SimpleCalcTime(tonumber(ban.Expire) - atommath:Get('timestamp'))
			end

			ATOMDLL:Ban(channelId, string.format("[%s] %s)", sTime, ban.Reason))
		else
			if (not NO_PLAYER_LIMIT) then
				local iPlayerCount = g_game:GetPlayerCount();
				if (iPlayerCount >= System.GetCVar("sv_maxplayers")) then
					ATOMLog:LogConnection("Denied new Connection on slot %d ($4%s, Server is Full$9)", channelId, IP);
					return ATOMDLL:Kick(channelId, "Server full");
				end
			end
			if (not self:GetIPData(IP)) then
				self:GetCountry(IP, channelId);
			else
				SysLog("Found IP Data for %s on channel %d in local database, skipping HTTP request and saving query", IP, channelId);
				self.channelCCs[channelId] = self:GetIPData(IP);
				self:CheckCountry(self.channelCCs[channelId], channelId);
				data = self.channelCCs[channelId];
				
				if (data and data.Country) then
					ATOMLog:LogToLogFile(LOG_FILE_CONNECT, "                -> Country: %s (%s)", checkString(data.Country, "N/A"), checkString(data.Conti, "N/A"))
					if (self.cfg.BlacklistenCountries[data.Country]) then
						ATOMLog:LogBan("Denied new Connection on slot %d $9($4%s$9)", channelId, "Blacklisted Country");
						ATOMDLL:Ban(channelId, "Blacklisted Country");
						return;
					end;
				end;
			end;
			
			ATOMBroadcastEvent("OnConnection", channelId, IP);
			self.activeConnections[channelId] = { _time, IP, g_statistics:GetValue("ConnTotal") };
		end;
		
		--------------------
		local cfg = self.cfg.Connection.ChatMessage;
		if (cfg and cfg.Access and cfg.SendMessage) then
			if (ban) then
				ATOMLog:LogBan("Denied new Connection on slot %d $9($4%s$9)", channelId, ban.Reason);
				SendMsg(CHAT_ATOM, cfg.Access, "(%s: Banned new Connection on slot %d, %s)", IP, channelId, ban.Reason);
				
				local expire 	= ban.Expire;
				local today 	= atommath:Get('timestamp');
				if (expire ~= "Infinite") then
					expire		= calcTime(tonumber(math_sub(ban.Expire, today)), true, 1, 1, 1, 1, "$8");
				end;
				
				SysLog("Banning new connection on slot %d (%s, expire: %s, remaining: %s)",channelId,ban.Reason,SimpleCalcTime(tonumber(math_sub(ban.Expire, ban.Date))),expire);
				ExecuteOnAll([[HUD.BattleLogEvent(eBLE_Information, "Denied new Connection on Channel ]] .. channelId .. [[!")]]);
			else
				ATOMLog:LogConnection("Received new Connection on slot %d ($4%s$9)", channelId, IP);


				Script.SetTimer(1000, function()
					local aData = checkArray(self.channelCCs[channelId], { City = "Unknown", Country = "Unknown", CountryCode = "Unknown"})
					local sCity = aData.City
					local sCountry = aData.Country
					local sCountryCode = aData.CountryCode

					if (sAlias) then
						SendMsg(CHAT_ATOM, cfg.Access, "(%s: Is Connecting (%s))", sAlias, (sCountry .. ", " .. sCity))
					else
						SendMsg(CHAT_ATOM, cfg.Access, "(%s: New Connection on slot %d)", IP, channelId)
					end

					local aCfg = self.cfg.Connection.BattleLog;
					if (aCfg and aCfg.SendMessage) then
						if (not sAlias) then
							ExecuteOnAll(formatString([[HUD.BattleLogEvent(eBLE_Information, "New Connection on Channel ]] .. channelId .. [[ from %s")]], sCountry))
						else
							ExecuteOnAll(formatString([[HUD.BattleLogEvent(eBLE_Information, "%s: Is Connecting (%s)")]], sAlias, (sCountryCode .. ", " .. sCity)))
						end
					end
				end)
			end
		end
		
		--------------------
		
	end;
};

