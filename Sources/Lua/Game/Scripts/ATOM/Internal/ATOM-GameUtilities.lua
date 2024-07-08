ATOMGameUtils = {
	SpectatorTraffic = ATOMGameUtils ~= nil and ATOMGameUtils.SpectatorTraffic or {},
	cfg = {
		LogGroup = ADMINISTRATOR;
		
		Vehicles = {	
			['trolley']		= { "US_trolley",			Mod = "MP",			Radius = { 5,  1, 0 } };
			['civ'] 		= { "Civ_car1", 			Mod = "",			Radius = { 10, 1, 0 } };
			['vtol'] 		= { "US_vtol", 				Mod = "", 			Radius = { 10, 8, 4 } };
			['tank'] 		= { "US_tank", 				Mod = "", 			Radius = { 10, 2, 0 } };
			['tactank'] 	= { "US_tank", 				Mod = "TACCannon", 	Radius = { 10, 2, 0 } };
			['heli'] 		= { "Asian_helicopter", 	Mod = "", 			Radius = { 10, 5, 0 } };
			['heliside'] 	= { "Asian_helicopter", 	Mod = "SideWinder", Radius = { 10, 5, 0 } };
			['ltv'] 		= { "US_ltv", 				Mod = "MP",			Radius = { 5,  1, 0 } };
			['boat'] 		= { "US_smallboat", 		Mod = "MP",			Radius = { 5,  1, 0 } };
			['pboat'] 		= { "Asian_patrolboat", 	Mod = "MP",			Radius = { 5,  1, 0 } };

			['singtank'] 	= { "US_tank", 				Mod = "Singularity", Radius = { 10, 2, 0 } };
		};
	};
	--------------------
	buildings = {};
	portals = {};
	taggedExplosives = {};
	--------------------
	ActiveAnims = {},
	AUTOMATIC_GUNS = {},
	RECENT_EXPLOSIONS = {},
	--------------------
	maps = ATOMGameUtils~=nil and ATOMGameUtils.maps or {
		["PS"] = {};
		["IA"] = {};
	};
	--------------------
	Init = function(self)
	
		SERVER_TIME_OLD = SERVER_TIME_OLD or nil
		SERVER_OSSTREAM_OLD = SERVER_OSSTREAM_OLD or nil
		RAGDOLL_SYNC_ENTITIES = RAGDOLL_SYNC_ENTITIES or {}
	
		----------------
		ADMIN_DECISION = "Admin Decision"
		SERVER_DECISION = "Server Decision"
		ACCESS_ERROR = "Insufficient Access"

		----------------
		TEAM_NEUTRAL = 0
		TEAM_NK		 = 1
		TEAM_US		 = 2
		
		----------------
		teamNames = {
			[0] = "Neutral",
			[1] = "NK",
			[2] = "US",
		};
	
		----------------
		eML_Scanned = 0;
		
		----------------
		ePE_Light		= "explosions.light.portable_light";
		ePE_Flare		= "explosions.flare.a";
		ePE_FlareNight	= "explosions.flare.night_time";
		ePE_Firework	= "misc.extremly_important_fx.celebrate";
		ePE_C4Explosive = "explosions.C4_explosion.ship_door";
		ePE_Claymore	= "explosions.mine.claymore";
		ePE_AlienBeam	= "alien_weapons.singularity.Tank_Singularity_Spinup";
		
		
		----------------
		self:ScanLevels();
		
		----------------
		g_gameRules.Utils = self
		g_utils = self
		
		
		----------------
		if (g_gameRules.class == "PowerStruggle") then
			self.buildings = {};
			self.sorted_buildings = {
				["bunker"] 	= {},
				["base"]	= {},
				["alien"]	= System.GetEntitiesByClass("AlienEnergyPoint") or {},
				["hqs"]		= System.GetEntitiesByClass("HQ") or {},
				["air"]		= {},
				["small"]	= {},
				["war"]		= {},
				["boat"] 	= {},
				["proto"] 	= {}
			};
			local entities = System.GetEntitiesByClass("Factory");
			if (entities) then
				for i, factory in pairs(entities) do
					table.insert(self.buildings, factory);
					local factory_type;
					if (factory.Properties.buyOptions.bPrototypes == 1) then
						factory_type = "proto"
					elseif (factory:GetName():lower():find("air")) then
						factory_type = "air"
					elseif (factory:GetName():lower():find("naval")) then
						factory_type = "boat"
					elseif (factory:GetName():lower():find("small")) then
						factory_type = "small"
					else
						factory_type = "war"
					end;
					factory._buildType = factory_type;
					if (factory_type) then
						table.insert(self.sorted_buildings[factory_type], factory);
					end;
				end;
			end;
			entities = System.GetEntitiesByClass("SpawnGroup");
			if (entities) then
				
				for i, spawn in pairs(entities) do
					table.insert(self.buildings, spawn);
					--Debug(spawn.Properties)
					local spawn_type;
					if ((spawn.Properties.teamName == "tan" or spawn.Properties.teamName == "black") and not spawn.Properties.bCaptureable) then
						spawn_type = "base"
					else
						spawn_type = "bunker"
					end;
					spawn._buildType = spawn_type;
					if (spawn_type) then
						table.insert(self.sorted_buildings[spawn_type], spawn);
					end;
				end;
			end;
			entities = System.GetEntitiesByClass("AlienEnergyPoint");
			if (entities) then
				for i, alien in pairs(entities) do
					alien._buildType = "Energy Point";
					table.insert(self.buildings, alien);
				end;
			end;
		end;
		
		------------
		TEAMS_ARG = {
			[0] = true,
			[1] = true,
			[2] = true,
			["us"] = true,
			["nk"] = true,
			["neutral"] = true
		};
		
		------------
		SpawnEffect = function(...) return self:SpawnEffect(...) end
		
		------------
		Helmet_Attach = function(...) return self:Helmet_Attach(...) end
		
		------------
		fixPos = function(pos) self:GetAdjustedPosition(pos) return pos end
		adjustPos = fixPos
		adjustPosInPlace = function(...) return self:GetAdjustedPosition(...) end;
	
		------------
		function removeHeliMiniguns(v)
			Debug("Miniguns REMOVEDF FROM heli ",v:GetName())
			if (v and v.HeliMiniguns) then
				local minigun_1 = v.HeliMiniguns[1]
				local minigun_2 = v.HeliMiniguns[2]
			
				if (minigun_1) then System.RemoveEntity(minigun_1.id) end
				if (minigun_2) then System.RemoveEntity(minigun_2.id) end
				
			end
			
			if (v) then 
				v.HeliMiniguns = nil 
				HELI_MINIGUNS[v.id] = nil;
			end
		end
	
		------------
		function addHeliMiniguns(v)
		
			Debug("Miniguns added for heli ",v:GetName())
		
			local Minigun1 = System.SpawnEntity({ class = "Hurricane", position = v:GetPos(), name = v:GetName() .. "_minigun_" .. g_utils:SpawnCounter() });
			local Minigun2 = System.SpawnEntity({ class = "Hurricane", position = v:GetPos(), name = v:GetName() .. "_minigun_" .. g_utils:SpawnCounter() });
			
			Minigun1.unpickable = true;
			Minigun2.unpickable = true;
			
			v.HeliMiniguns = {
				Minigun1,
				Minigun2
			};
			
			v:AttachChild(Minigun1.id, 1);
			v:AttachChild(Minigun2.id, 1);
					
			local vdir = v:GetDirectionVector();
					
			Minigun1:SetDirectionVector(vdir);
			Minigun2:SetDirectionVector(vdir);
					
			Minigun1:SetLocalPos({x=3.05,y=-0.65,z=0.25})
			Minigun2:SetLocalPos({x=-3.05,y=-0.65,z=0.25})
					
			local code = [[
				local v=GetEnt(']] .. v:GetName() .. [[');
				local g1, g2 = GetEnt(']] .. Minigun1:GetName() .. [['), GetEnt(']] .. Minigun2:GetName() .. [[');
				if (v and not v.vehicle:IsDestroyed() and g1 and g2) then
					v:AttachChild(g1.id, 1);
					v:AttachChild(g2.id, 1);
					
					local vdir = v:GetDirectionVector();
					
					g1:SetDirectionVector(vdir);
					g2:SetDirectionVector(vdir);
					
					g1:SetLocalPos({x=3.05,y=-0.65,z=0.25})
					g2:SetLocalPos({x=-3.05,y=-0.65,z=0.25})
				end;
			]];
			
			Script.SetTimer(1000, function()
				ExecuteOnAll(code);
			end)
			
            if (v.GunSyncID) then
                RCA:StopSync(v, v.GunSyncID)
                v.GunSyncID = nil
            end

			v.GunSyncID = RCA:SetSync(v, { client = code, link = true });
			v.OnMousePress = function(self, driver, release)
				--Debug("PRESSED!")
				if (not self.vehicle:IsDestroyed()) then
					if (driver or release) then
						if (driver and not release) then
							self.InFiring = true;
						elseif (self.InFiring) then
							self.InFiring = false;
						end;
					end;
				end;
			end;
			
			HELI_MINIGUNS[v.id] = v;
		
		end;
	
		------------
		function addPortal(pos, dir, dest, where, to, conditionFunc)
			local protoPos = dest or g_utils:GetBuilding("proto");
			if (not protoPos) then
				return;
			end;
			
			local string_where = where or "the Prototype Factory";
			local string_to = to or "the Prototype Factory";
			
			local portal_main = SpawnGUINew({ Model = "Objects/library/alien/props/gravity_stream_rings/gravity_stream_ring_main.cgf", bStatic = true, Mass = -1, Pos = pos, Dir = dir });
			local portal_support = SpawnGUINew({ Model = "Objects/library/alien/props/gravity_stream_rings/gravity_stream_ring_support.cgf", bStatic = true, Mass = -1, Pos = pos, Dir = dir });
			local portal_forcefield = SpawnGUINew({ Model = "Objects/library/alien/props/forcefield/forcefield_small.cgf", bStatic = true, Mass = -1, Pos = pos, Dir = dir });
			
			portal_main:SetScale(0.5);
			portal_support:SetScale(0.5);
			portal_forcefield:SetScale(0.37 * 0.5);
			
			
			portal_main.isPortal = true
			portal_support.isPortal = true
			portal_forcefield.isPortal = true
			
			local hATOMTrigger = self:CreatePortal({
				Pos = pos,
				Range = 2.5,
				Out = add2Vec(protoPos, makeVec(0, 0, 100)),
				OutRandom = makeVec(3, 3, 0),
				Msg = "You were teleported to " .. string_where,
				Enter = "Portal to " .. string_to .. " [ %0.2fm ]",
				linked = portal_main.id,
				Entity = portal_main,
				AllowVehicles = true,
				ConditionFunc = conditionFunc
			});

			return portal_main, portal_support, portal_forcefield, hATOMTrigger;
		
		end;
	
		------------
		AUTOMATIC_GUNS 	 = checkVar(AUTOMATIC_GUNS, {})
		HELI_MINIGUNS 	 = checkVar(HELI_MINIGUNS, {})
		CLOAKED_VEHICLES = checkVar(CLOAKED_VEHICLES, {})
		REMOVE_OBJECTS 	 = checkVar(REMOVE_OBJECTS, {})
		ORIG_CVARS 		 = checkVar(ORIG_CVARS, {})
		ANTI_AIR_GUNS 	 = checkVar(ANTI_AIR_GUNS, {})
		TEMP_RAYWORLD_RESULTS 	 = checkVar(TEMP_RAYWORLD_RESULTS, {})

		------------
		
		------------
		SaveCVar = function(sCVar, iValue)
			local iValue = checkVar(iValue, System.GetCVar(sCVar))
			if (isNull(ORIG_CVARS[sCVar])) then
				ORIG_CVARS[sCVar] = iValue
			end
		end
		
		------------
		RestoreCVar = function(sCVar)
			if (not isNull(ORIG_CVARS[sCVar])) then
				return ORIG_CVARS[sCVar]
			end
			return (System.GetCVar(sCVar))
		end
	end;
	--------------------
	GetMapDownloadLink = function(self, sMapName)
	
		----------
		local fLinks, sErr = io.open("mods/atom/maplinks.txt")
		if (not fLinks) then
			SysLog("Failed to Open File mods/atom/maplinks.txt (%s)", (sErr or "N/A"))
			return false, "file not found or error trying to read it"
		end
		
		----------
		local sCurrentMap = string.lower(checkVar(sMapName, g_dll:GetMapName()))
		local sRules, sMap, sLink
		
		----------
		for sLine in fLinks:lines() do
			
			if (string.find(string.lower(sLine), sCurrentMap)) then
				sLink = string.gsubex(string.lower(sLine), { sCurrentMap, " " }, "")
				break
			end
		end
		
		----------
		if (string.empty(sLink)) then
			return false
		end
		return true, sLink
	end;
	--------------------
	ListMaps = function(self, hPlayer, sFilter)
		
		----------
		local sFilter = string.lower(checkVar(sFilter, ""))
		if (string.findex(sFilter, "po", "pow", "power", "power+struggle")) then
			sFilter = "ps"
		elseif (string.findex(sFilter, "ins", "inst", "instant", "instant+action", "action", "iaction")) then
			sFilter = "ia"
		end
		
		----------
		local aMaps = self:GetMapList()
		if (not string.empty(sFilter)) then
			aMaps = { [sFilter] = aMaps[string.upper(sFilter)] }
			if (table.countRec(aMaps) == 0) then
				return false, "no '" .. self:ReverseRules(sFilter) .. "' maps found"
			end
		else
			if (table.countRec(aMaps) == 0) then
				return false, "no maps found on the server"
			end
		end
		
		----------
		local iMaps = table.countRec(aMaps)
		local sIMaps = string.lspace(iMaps, 3, nil, "0")
		SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the [ %d ]%s Maps", iMaps, (not string.empty(sFilter) and (" " .. self:ReverseRules(sFilter)) or ""))
		SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")
		
		local bLink = false
		local sLink = ""
		local sMapPath = ""
		local sMapColor = ""
		local sLine = ""
		local sRulesFixed = ""
		local iIndex = 0
		local iCounter = 0
		local iMapCount = 0
		
		for sRules, aAllMaps in pairs(aMaps) do
			sRulesFixed = self:ReverseRules(string.lower(sRules))
		
			SendMsg(CONSOLE, hPlayer, "$9" .. space(59 - string.len(sRulesFixed), "=") .. " [ ~ " .. "$4" .. sRulesFixed .. " $9~ ] " .. space(57 - string.len(sRulesFixed), "="))
			
			sLink = ""
			sLine = "     "
			iIndex = 0
			iCounter = 0
			iMapCount = table.count(aAllMaps)
			
			for i, sMap in pairs(aAllMaps) do
				iIndex = iIndex + 1
				iCounter = iCounter + 1
				
				sMapPath = "multiplayer/" .. sRules .. "/" .. sMap
				sMapColor = "$9"
				bLink, sLink = self:GetMapDownloadLink(sMapPath)
				if (self:IsMapForbidden(sMapPath)) then
					sMapColor = "$4"
				elseif (not bLink) then
					sMapColor = "$6"
				end
				
				sLine = sLine .. "$1" .. string.lspace(iCounter, 2, nil, " ") .. ") " .. sMapColor .. sMap .. space(25 - string.len(sMap))

				if (iIndex >= 4 or iIndex == iMapCount) then
					SendMsg(CONSOLE, hPlayer, sLine)
					sLine = "     "
					iIndex = 0
				end
			end
			
			SendMsg(CONSOLE, hPlayer, "")
		end
		
		SendMsg(CONSOLE, hPlayer, "     $9=======================================")
		SendMsg(CONSOLE, hPlayer, "     $9Note: $6YELLOW$9 Maps have $4NO$9 Download-Link")
		SendMsg(CONSOLE, hPlayer, "     $9Note: $4RED$9 Maps Are $4FORBIDDEN")
		SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")
	end;
	--------------------
	IsMapForbidden = function(self, sMapPath)
		
		local bForbidden = false
		for sMap, bAllowed in pairs((Config and (Config.Maps or{}).ForbiddenMaps or {})) do
			if (string.lower(sMap) == string.lower(sMapPath)) then
				bForbidden = bAllowed
				break
			end
		end
		return bForbidden
		
	end;
	--------------------
	GetMapList = function(self, sRules)
		
		if (sRules) then
			return self.maps[sRules]
		end
		return self.maps
		
	end;
	--------------------
	ReverseRules = function(self, sRules)
		local aRules = {
			["ia"] = "Instant Action",
			["ps"] = "Power Struggle",
			["tia"]= "Team Instant Action"
		}
		
		return checkVar(aRules[sRules], string.upper(sRules))
	end;
	--------------------
	ResetLevels = function(self)
		self.maps = {
			["PS"] = {};
			["IA"] = {};
		};
	end;
	--------------------
	ScanLevels = function(self, reset)
	
		if (reset) then
			self:ResetLevels();
		end;
		
		local mapsRootDir = "Game/Levels/Multiplayer";
		
		local PS, IA = "PS", "IA";
		local PSCount, IACount = arrSize(self.maps[PS]), arrSize(self.maps[IA]);
		
		if (IACount < 1 or reset) then
			for i, map in pairs(System.ScanDirectory(mapsRootDir .. "/" .. IA .. "/", 0)or{}) do
				self.maps[IA][map:lower()] = map;
			end
		end;
		
		if (PSCount < 1 or reset) then
			for i, map in pairs(System.ScanDirectory(mapsRootDir .. "/" .. PS .. "/", 0)or{}) do
				self.maps[PS][map:lower()] = map;
			end
		end;
		
		PSCount, IACount = arrSize(self.maps[PS]), arrSize(self.maps[IA]);
		
		self:Msg(eML_Scanned, PS, PSCount);
		self:Msg(eML_Scanned, IA, IACount);
	end;
	--------------------
	Msg = function(self, case, p1, p2, p3, p4)
		if (case == eML_Scanned) then
			ATOMLog:LogGameUtil("Loaded %d %s Maps into the System", tonum(p2), p1);
		end;
	end;
	--------------------
	GetMapRules = function(self, mapName, sv)
		if (self.maps['IA'][mapName:lower()]) then
			return sv and "IA" or 'InstantAction';
		elseif (self.maps['PS'][mapName:lower()]) then
			return sv and "PS" or 'PowerStruggle';
		end;
	end;
	--------------------
	EndGame = function(self)
		if (g_gameRules.GameEnding) then
			return false, "Game already ended"
		end
		
		if (g_gameRules.class == "PowerStruggle") then
			g_gameRules:EndGameWithWinner_PS()
		else
			g_gameRules:EndGameWithWinner_IA()
		end
	end,
	--------------------
	NextLevel = function(self, timer)
		self:EndGame()
		do return end
		local NextLevel, NextRules = ATOMDLL:GetNextLevel();
		if (NextLevel:lower() == ATOM:GetMapName():lower()) then
			return false, makeCapital(ATOM:GetMapName(true)) .. " is the last map in rotation";
		end;
		return self:StartMap(NextLevel, NextRules, timer);
	end;
	--------------------
	SetTimeLimit = function(self, hPlayer, sLimit, bNoLog)
	
		if (not g_game:IsTimeLimited()) then
			return false, "Time is Unlimited"
		end

		local sChar = string.sub(sLimit, 1, 1)
		local iAmount = tonumber(checkString(string.sub(sLimit, 2)))
		local bAdd = (sChar == "+")
		local bDel = (sChar == "-")

		local iRemaining = (g_game:GetRemainingGameTime() / 60)
		local iNewTime = 0
		local iLimit = 25000

		if ((bAdd or bDel) and not iAmount) then
			return false, "invalid time specified"
		end

		if (bAdd) then
			iNewTime = math.maxex(iRemaining + iAmount, iLimit)
			if (not bNoLog) then
				ATOMLog:LogGameUtils('MapChange', "Added %d Minutes to Game Time", iAmount)
				SendMsg(CHAT_ATOM, hPlayer, "(GAMETIME: Added %d Minutes to Game Time)", iAmount)
			end
		elseif (bDel) then
			iNewTime = math.minex(iRemaining - iAmount, 1)
			if (not bNoLog) then
				ATOMLog:LogGameUtils('MapChange', "Deducted %d Minutes from Game Time", iAmount)
				SendMsg(CHAT_ATOM, hPlayer, "(GAMETIME: Deducted %d Minutes from Game Time)", iAmount)
			end
		else
			iAmount = tonumber(sLimit)
			if (not iAmount) then
				return false, "invalid time specified"
			end
			iNewTime = math.limit(iAmount, 1, iLimit)
			if (not bNoLog) then
				ATOMLog:LogGameUtils('MapChange', "Remaining Game Time set to %d minutes", iNewTime)
				SendMsg(CHAT_ATOM, hPlayer, "(GAMETIME: Set to %d Minutes)", iNewTime)
			end
		end

		local oldTime = System.GetCVar("g_timelimit")
		System.SetCVar("g_timelimit", iNewTime)
		g_game:ResetGameTime()

		return true
	end,
	--------------------
	Teleport = function(self, hPlayer, iDistance, bFollowTerrain)
		local iDistance = checkNumber(iDistance, 3)
		local vPos = hPlayer:CalcSpawnPos(iDistance)

		if (bFollowTerrain) then
			vPos.z = System.GetTerrainElevation(vPos)
		end
		
		g_game:MovePlayer(hPlayer.id, vPos, hPlayer:GetAngles())
		self:SpawnEffect(ePE_Light, vPos, nil, 0.5)
		SendMsg(CHAT_ATOM, player, "You were Teleported ( %d ) Meters forward", iDistance)
	end,
	--------------------
	Teleport_Up = function(self, hPlayer, iDistance)
		local iDistance = checkNumber(iDistance, 5)
		local vPos = hPlayer:GetPos()

		vPos.z = vPos.z + iDistance
		
		g_game:MovePlayer(hPlayer.id, vPos, hPlayer:GetAngles())
		self:SpawnEffect(ePE_Light, vPos, nil, 0.5)
		SendMsg(CHAT_ATOM, player, "You were Teleported ( %d ) Meters upwards", iDistance)
	end;
	--------------------
	GetCorrectMapName = function(self, sMap)

		local sMap = string.lower(sMap)
		local sRules, sName = string.match(sMap, "multiplayer/(.*)/(.*)")
		if (sRules and sName) then
			return sName, sMap, sRules
		end

		sRules = self:GetMapRules(sMap)
		if (not sRules) then
			return
		end

		sName = string.format("Multiplayer/%s/%s", self:GetMapRules(sMap, true), sMap)
		return sMap, sName, sRules

		--[[


		if (m:lower():match("multiplayer/(.*)/(.*)")) then
			local a, b = m:lower():match("multiplayer/(.*)/(.*)")
			return b, m, a
		end;
		local rules = self:GetMapRules(m);
		if (not rules) then
			return false;
		end;
		local longName = "Multiplayer/" .. self:GetMapRules(m, true) .. "/" .. m;
		return m, longName, rules;
		--]]
	end;
	--------------------
	ChangeMap = function(self, sMap, iTimer)

		local sName, sNameLong, sRules = self:GetCorrectMapName(sMap)
		if (not sName) then
			return false, "invalid map"
		end

		MAP_CHANGED_BY_COMMAND = { g_gameRules.class, 0, LAST_MAP_NAME }
		return self:StartMap(sNameLong, sRules, iTimer)
	end,
	--------------------
	IsValidMap = function(self, sMap, sRules)

		local sMap = string.lowerex(sMap)
		if (self:GetMapRules(sMap)) then
			return true
		end

		local sRules = string.lowerex(sRules)
		if (not sRules) then
			return 1
		end

		local aMaps = self.maps[sRules]
		if (not aMaps) then
			return 2
		end

		local aMap = aMaps[sMap]
		if (not aMap) then
			return 3
		end

		return true

		--return (rules and self.maps[rules:lower()] and self.maps[rules:lower()][mapName:lower()]) ~= nil or self:GetMapRules(mapName) ~= nil;
	end,
	--------------------
	GetRules = function(self, sRules)
		if (string.lower(sRules) == "powerstruggle") then
			return "PS"
		end
		return "IA"
	end,
	--------------------
	ParseRules = function(self, sMap)

		return (string.matchex(string.lower(sMap), "multiplayer/ps/(.*)") and "PowerStruggle" or "InstantAction")
		--return (m:lower():match("(.*)/ps/(.*)") and "PowerStruggle" or "InstantAction");
	end;
	--------------------
	LevelExists = function(self, m, r)
		local r = self:GetRules(r);
		return (self.maps[r] and self.maps[r][m]);
	end;
	--------------------
	StartMap = function(self, mapName, mapRules, timer, skipGCMN)
		local logS, longL, logR
		if (skipGCMN) then
			logS, longL, logR = mapName, mapName, mapRules
		else
			logS, longL, logR = self:GetCorrectMapName(mapName)
		end

		if (self.mapChangeTimer) then
			return false, "map change already initiated"
		end

		local timer = math.max(1, math.min(60, (timer or 0)));
		if (mapName and mapRules) then
			if (timer and timer > 1) then
				ATOMLog:LogGameUtils('MapChange', "Changing map to %s$9 ($4%s, %ds$9)", makeCapital(logS), self:GetMapRules(logS), timer);
				self.mapChangeTimer = true;
				Script.SetTimer(timer * 1000, function()
					self.mapChangeTimer = false;
					self:DoChangeMap(mapName, mapRules)
				end)
			else
				ATOMLog:LogGameUtils('MapChange', "Changing map to %s$9 ($4%s$9)", makeCapital(logS), self:GetMapRules(logS))
				return self:DoChangeMap(mapName, mapRules)
			end
		end
	--	Debug("Woff")
	end;
	--------------------
	DoChangeMap = function(self, map, rules)

		ATOM:SaveFiles()
		System.ExecuteCommand("sv_gameRules " .. rules)
		Script.SetTimer(10, function()
			System.ExecuteCommand("map " .. map:lower())
		end)
		
		return true
	end;
	--------------------
	PCall = function(self, func, ...)
		local s, e = pcall(func, ...);
		if (not s) then
			ATOMLog:LogError(e);
			SysLog("error in pcall: %s", e or "<null>");
			SysLog(" traceback:");
			SysLog("  %s", debug.traceback()or"<error>");
		end;
	end;
	--------------------
	StartMovement = function(self, params)
		if (params.name and (params.pos or params.dir) and params.handle and params.duration) then
			params.start = _time;

			local ent = System.GetEntityByName(params.name)
			if (ent) then
				if (params.pos) then
					ent:SetWorldPos(params.pos.from);
				end;
				if (params.dir) then
					ent:SetDirectionVector(params.dir.from);
				end
				
				params.entity = ent;
				
				self.ActiveAnims[params.handle] = params;
				Debug("new anim: ", params.handle);
			else
				Debug("no entity for anim", params.handle)
			end
		else
			Debug("cant add anim");
		end;
	end,
	--------------------
	OnMidTick = function(self)
		LAST_SECOND = _time;
		local spectgt;
				for i, tplayer in pairs(GetPlayers()or{}) do
				
							--if (tplayer.PongTime and _time - tplayer.PongTime > 60) then
							--	tplayer.timeouting = true;
							--	if (not tplayer.LastTimeoutMsg or _time - tplayer.LastTimeoutMsg >= 5) then
							--		SysLog("%s is Timeouting (last pong %0.2fs ago)", tplayer:GetName(), _time-tplayer.PongTime);
							--		SendMsg(CHAT_ATOM, ADMINISTRATOR, "(%s: Timeouting (Last Pong: %0.2fs Ago))", tplayer:GetName(),  _time-tplayer.PongTime);
							--	end;
							--else
							--	tplayer.timeouting = false;
							--end;
							
					if (tplayer.Initialized) then


						tplayer.inventory:SetAmmoCount("tagbullet", 0)
						tplayer.actor:SetInventoryAmmo("tagbullet", 0)

						local bSprinting = tplayer.actorStats.bSprinting
						if (tplayer.HasSuperSwim and tplayer.bIsMoving and bSprinting and tplayer.actorStats.stance == STANCE_SWIM and not tplayer:IsSpectating() and tplayer:IsAlive() and not tplayer:GetVehicle()) then
							if (not tplayer.LoadedSwimCode) then
								tplayer.LoadedSwimCode = true
								ExecuteOnAll([[local p=GP(]]..tplayer:GetChannel()..[[)if(p)then p.SuperSwimmer=true;end]])
							end
						elseif (tplayer.LoadedSwimCode) then
							tplayer.LoadedSwimCode = nil
							ExecuteOnAll([[local p=GP(]]..tplayer:GetChannel()..[[)if(p)then p.SuperSwimmer=false;end]])
						end

						if (tplayer.actorStats.bSprinting and tplayer.walkInfo) then
							SendMsg(CENTER, tplayer, "[ SPRINTING :   SPEED-[ " .. cutNum(tplayer:GetSpeed(), 2) .. "m/s ]-ENERGY-[ " .. cutNum((tplayer.actor:GetNanoSuitEnergy()/200)*100, 2) .. "% ]-SUIT-[ " .. tplayer:GetSuitName():upper() .. " ]  ]");
						elseif (tplayer.actor:GetLinkedVehicleId()and tplayer.walkInfo) then
							local v = System.GetEntity(tplayer.actor:GetLinkedVehicleId());
							if (v and v:GetDriverId() == tplayer.id) then
								SendMsg(CENTER, tplayer, "[ VEHICLE :   SPEED-[ " .. cutNum((v:GetSpeed()*60*60)/1000, 2) .. "KM/h ]-DAMAGE-[ " .. cutNum((v.vehicle:GetRepairableDamage())*100, 2) .. "% ]-BOOST-[ " .. (v.Boost and "TRUE" or "FALSE") .. " ]  ]");
							end; --v:GetSpeed()*3.7409067
						elseif (true) then
							if (tplayer.LastFallPos and _time - (tplayer.LastWallJump or _time-5) >= 5) then
								local groundHeight = tplayer:GetPos().z - System.GetTerrainElevation(tplayer:GetPos());	
								--Debug(GetDistance(tplayer, tplayer.LastFallPos, false, false, true))
								if (GetDistance(tplayer, tplayer.LastFallPos, false, false, true) > 4) then
									if (tplayer.actorStats.inFreeFall == 1) then
										if (tplayer.walkInfo) then
											SendMsg(CENTER, tplayer, "[ FLYING :   SPEED-[ " .. cutNum(tplayer:GetSpeed(), 2) .. "m/s ]-HEIGHT-[ " .. cutNum(groundHeight, 2) .. "m ] ]");
										end;
									end;
									--player.IsFlying = true;
								elseif (tplayer.actor:IsFlying()) then
									if (tplayer.walkInfo) then
										SendMsg(CENTER, tplayer, "[ FALLING :   SPEED-[ " .. cutNum(tplayer:GetSpeed(), 2) .. "m/s ]-HEIGHT-[ " .. cutNum(groundHeight, 2) .. "m ] ]");
									end;
									--player.false = true;
									tplayer.Falling = true;
									tplayer.FallStart = tplayer.FallStart or _time;
									tplayer.FallingTime = _time - (tplayer.FallStart or _time);
								else
									tplayer.Falling=false;
									tplayer.FallStart=0;
									tplayer.FallingTime=nil
								end;
							else
								--Debug("NIO FALL :S(S((S")
							end;
							
							
							tplayer.LastFallPos = tplayer:GetPos();
						end;
						if (tplayer:IsInGodMode() and tplayer.died) then
							--g_game:RevivePlayer(tplayer.id, tplayer:GetPos(), tplayer:GetAngles(), g_game:GetTeam(tplayer.id), true);
							g_utils:RevivePlayer(tplayer, tplayer);
							tplayer.died = false;
						end;
						
						--[[if tplayer:IsSpectating() then
							spectgt = tplayer:GetSpectatorTarget();
							if (spectgt) then
								if not tplayer.SpecMsg or (spectgt.id ~= tplayer.LastSpecTgt) then
									tplayer.LastSpecTgt = spectgt.id;
									SysLog("%s started spectating %s", tplayer:GetName(), spectgt:GetName());
									if (spectgt.isPlayer and spectgt:HasAccess(tplayer:GetAccess())) then
										SendMsg(BLE_CURRENCY, spectgt, "%s: Started Spectating You ...", tplayer:GetName());
										if (ATOM.cfg.Spectator.ChatMessage and spectgt:HasAccess(ATOM.cfg.Spectator.ChatAccess)) then
											SendMsg(CHAT_ATOM, spectgt, "(%s: Started Spectating You)", tplayer:GetName());
										end;
									end;
									tplayer.SpecMsg = true
								end;
							else
								tplayer.SpecMsg = false;
							end;
						else
							tplayer.SpecMsg = false;
						end;]]
						
						local clays = System.GetEntitiesInSphereByClass(tplayer:GetPos(), 5, "claymoreexplosive");
						if (clays and arrSize(clays) > 0) then
							local all = 0;
							for i, clay in pairs(clays) do
								if (g_game:GetTeam(clay.id) ~= tplayer:GetTeam() or g_gameRules.class == "InstantAction") then
								--	g_utils:SpawnEffect("misc.static_lights.red_flickering", clay:GetWorldPos(), g_Vectors.up, 0.3);
									all = all + 1;
								end;
							end;
							--SendMsg(CENTER, tplayer, "CAUTION : CLAYMORES DETECTED");
						end;
						
						
				
				local v = tplayer:GetVehicle();
				if (v and v.IsTrans and not v.TransCargo) then
					local RH = self:RayCheck(v:GetPos(), g_Vectors.down, v.TransDist or 10, v.id);
					local available = {
						["US_tank"] = true,
						["Asian_tank"] = true,
						["US_ltv"] = true,
						["Asian_ltv"] = true,
						["Civ_car1"] = true,
						["Asian_speedboat"] = true,
						["Asian_truck"] = true,
						["Asian_aaa"] = true,
						["US_truck"] = true,
						["GUI"] = true,
					};
					--Debug(v:GetSpeed())
					if (RH and RH.entity and RH.entity.vehicle and available[RH.entity.class]) then
						v.PossibleTransCargo = RH.entity;
						--De bug("Cargo found, press F3 to attach!!!");
						SendMsg(CENTER, tplayer, "Transportable Cargo found, Press [F3] To Attach!");
					else
						v.PossibleTransCargo = nil;
					end;
				elseif (v) then
					-- Debug("v but no",tostring(v.TransCargo))
					if (v.TransCargo and not System.GetEntity(v.TransCargo)) then
						v.TransCargo = nil
					end
					v.PossibleTransCargo = nil;
				end;
						
					end;
					local curr = tplayer:GetCurrentItem();
					if (curr) then
						--Debug(tplayer.Hits)
						local shots, hits = tplayer.Shots or 0, (tplayer.Hits or {})[curr.class] or 0;
						if (tplayer.AimDebug) then
							SendMsg(CENTER, tplayer, "Shots: %d, Hits: %d, Hit Rate: %0.2f%% (Accuracy: %0.2f%%)", shots, hits, (hits/shots)*100, tplayer.CurrentAccuracy or .0)
						end;
					end;
					
					if (tplayer.PMGroup and (not tplayer.LastConvMsg or _time - tplayer.LastConvMsg >= 30)) then
						if (arrSize(tplayer.PMGroup) == 0) then
							tplayer.PMGroup = nil;
							SendMsg(INFO, tplayer, "[ PM:SYSTEM ]-CONVERSATION ENDED (No Receivers)");
						else
							local conv;
							if (arrSize(tplayer.PMGroup) < 3) then
								for i, v in pairs(tplayer.PMGroup) do
									conv = (conv ~= nil and conv .. ", " or "") .. v;
								end;
							else
								conv = "[ " .. arrSize(tplayer.PMGroup) .. " ] PLAYERS";
							end;
							SendMsg(INFO, tplayer, "[ PM:SYSTEM ]-CONVERSATION ACTIVE :: %s", conv);
						end;
						tplayer.LastConvMsg = _time;
					end;
					tplayer.LastTickPos = tplayer:GetPos();
				end;
				local maxAv = ATOM.cfg.AveragePing or 240;
				local avgPing = g_gameRules:GetAvergePing();
				if (avgPing and avgPing > maxAv) then
					local mostLagging = g_gameRules:GetLaggers();
					if (mostLagging and arrSize(mostLagging) > 0) then
						mostLagging = mostLagging[1][1];
					else
						mostLagging = nil;
					end;
					if (not ATOM.lastPingWarn or _time - ATOM.lastPingWarn >= 15) then
						SendMsg(CHAT_WARN, ADMINISTRATOR, "Average Ping above %d ( %d%s )", maxAv, avgPing, (mostLagging and ", " .. mostLagging:GetName() or ""));
						ATOMLog:LogWarning("Average Ping above %d (%d%s)", maxAv, avgPing, (mostLagging and ", " .. mostLagging:GetName() or ""));
						ATOM.lastPingWarn = _time;
					end;
				end;
				
		--[[
		if (ATOM.cfg.Server.TimeoutDetection) then
			if (not self.LastPing or _time - self.LastPing > 3) then
				local p;
				if (not self.TIMEOUT_ENV) then
					self.TIMEOUT_ENV = {
						0,
						GetPlayers(),
						arrSize(GetPlayers()),
					};
				elseif (self.TIMEOUT_ENV[3] > 0) then
					p = self.TIMEOUT_ENV[2][1];
					if (self.TIMEOUT_ENV[1] <= self.TIMEOUT_ENV[3] and p) then
						if (p.Initialized and p.ATOM_Client and GetEnt(p.id)) then
							if (not p.PongTime or _time - p.PongTime > ((p:GetPing() * 2) / 1000)) then
								p.PongTime = p.PongTime or _time;
								--ExecuteOnPlayer(p, 'ping!');
								g_gameRules.onClient:ClWorkComplete(p:GetChannel(), p.id, "ping!")
							end;
						end;
						self.TIMEOUT_ENV[1] = self.TIMEOUT_ENV[1] + 1;
					else
						self.TIMEOUT_ENV = nil;
					end;
				else
					self.TIMEOUT_ENV = nil;
				end;
				self.LastPing = _time;
			end;
		end;
		--]]
	end,
	--------------------
	OnExplosion = function(self, explosion)

	end,
	--------------------
	OnFreeze = function(self, player, item, target)
		return true;
	end,
	--------------------
	OnSpectating = function(self, player, target)
		table.insert(self.SpectatorTraffic, {
			p = player,
			t = target,
			t = _time,
			a = player:GetAccess(),
		});
		return true;
	end,
	--------------------
	OnTick = function(self)
	
		---------
		self:OnMidTick()
		self:UpdatePortals()
	
		---------
		local sOSStream = System.GetCVar("atom_svreport_players")
		if (g_game:GetPlayerCount() == 0 and sOSStream ~= "") then
			local cfg = ATOM.cfg.Server;
			if (cfg) then
				if (cfg.UseReportInfo) then
					local repInfo = cfg.ServerReport;
					if ((repInfo and repInfo.HideOnEmptyServer) or (SERVER_OSSTREAM_OLD ~= sOSStream)) then
						SysLog("Old OSStream: %s. Hiding Now!", sOSStream)
						SERVER_OSSTREAM_OLD = sOSStream
						System.SetCVar("atom_svreport_players", "")
					end;
				end; --HideOnEmptyServer
			end;
		elseif (g_game:GetPlayerCount() >= 1 and sOSStream == "") then
			if (SERVER_OSSTREAM_OLD ~= nil) then
				SysLog("New OSStream: %s. Showing Now!", SERVER_OSSTREAM_OLD)
				System.SetCVar("atom_svreport_players", SERVER_OSSTREAM_OLD)
				SERVER_OSSTREAM_OLD = nil
			end
		end
	
		---------
		local sMapName = ATOM:GetMapName(true)
		if (g_game:GetPlayerCount() == 0) then
			if (ATOM.cfg.MapConfig.Rotation.PauseEmptyServer) then
				local bOk = true
				local sPauseMaps = ATOM.cfg.MapConfig.Rotation.PauseOnMaps
				if (sPauseMaps ~= "" and not string.find(sPauseMaps, string.lower(sMapName))) then
					bOk = false
				end
				
				if (bOk) then
					if (not SERVER_TIME_OLD) then
						SERVER_TIME_OLD = math.floor((g_game:GetRemainingGameTime() / 60) + 0.5);
					end
					if (not self.PAUSE_TIME) then
						self.PAUSE_TIME = ATOM.cfg.MapConfig.Rotation.PauseTime or CURRENT_MAP_TIME_LIMIT or g_game:GetRemainingGameTime();
						SysLog("Force stopping game time: %s.", tostring(self.PAUSE_TIME))
					end;
					--if (self.PAUSE_TIME >= 60) then
					System.SetCVar("g_timelimit", self.PAUSE_TIME);
					g_game:ResetGameTime();
					-- end;
				else
					-- SysLog("not pausing time on map %s", sMapName)
				end
			end;
		else
			self.PAUSE_TIME = nil;
			if (SERVER_TIME_OLD) then
				System.SetCVar("g_timelimit", SERVER_TIME_OLD);
				g_game:ResetGameTime();
				SysLog("Game time restored to: %s.", tostring(SERVER_TIME_OLD))
				SERVER_TIME_OLD = nil
			end
		end;
		
		---------
		if (ATOMVehicles.cfg.HelicoperMiniguns) then
            --Debug("yes")
			for i, v in pairs(GetVehicles()) do
                --Debug("class=",v.class)
				if (v.class == "Asian_helicopter") then
                    --Debug("heli!!")
					if (not v.vehicle:IsDestroyed()) then
						if (not v.HeliMiniguns) then
							addHeliMiniguns(v);
						end;
					elseif (v.HeliMiniguns) then
						removeHeliMiniguns(v)
					end;
				end;
			end;
		end;
	
		---------
		if (ATOM.cfg.MapConfig.Rotation.MapRevert) then
			local revTime = ATOM.cfg.MapConfig.Rotation.EmptyRevertTime;
			if (MAP_CHANGED_BY_COMMAND) then
				if (g_gameRules.class ~= MAP_CHANGED_BY_COMMAND[1]) then
					if (g_game:GetPlayerCount() == 0) then
						MAP_CHANGED_BY_COMMAND[2] = (MAP_CHANGED_BY_COMMAND[2] or 0) + 1;
						if (not MAP_CHANGED_BY_COMMAND[4] or _time - MAP_CHANGED_BY_COMMAND[4] > 30) then
							SysLog("Reverting map to Rotation %s in %d seconds", MAP_CHANGED_BY_COMMAND[1], revTime - MAP_CHANGED_BY_COMMAND[2])
							MAP_CHANGED_BY_COMMAND[4] = _time;
						end;
						if (MAP_CHANGED_BY_COMMAND[2] > revTime) then
							SysLog("Reverting back to default rotation %s", MAP_CHANGED_BY_COMMAND[1]);
							VOTED_MAP = nil; --MAP_CHANGED_BY_COMMAND[3];
							g_gameRules:NextLevel(nil, MAP_CHANGED_BY_COMMAND[1]);
							
							MAP_CHANGED_BY_COMMAND = nil;
						end;
					end;
				else
					MAP_CHANGED_BY_COMMAND = nil;
				end;
			end;
		end

		---------
		for idEntity, hPlayer in pairs(RAGDOLL_SYNC_ENTITIES) do

			local hRagdoll = System.GetEntity(idEntity)
			if (not hRagdoll) then
				RAGDOLL_SYNC_ENTITIES[idEntity] = nil
				Debug("deleted")
			elseif (not System.GetEntity(hPlayer.id) or hPlayer:IsAlive() or hPlayer:IsSpectating()) then
				System.RemoveEntity(idEntity)
				RAGDOLL_SYNC_ENTITIES[idEntity] = nil
				Debug("deleted")
			elseif (hRagdoll:GetSpeed() < 1 and timerexpired(hRagdoll.hSpawnTimer, 1.5)) then
				System.RemoveEntity(idEntity)
				RAGDOLL_SYNC_ENTITIES[idEntity] = nil
				Debug("stop! tooooo slow")
			else
				hPlayer:SetPos(hRagdoll:GetPos())
			end
		end

		---------
		local idExplosiveWarning = ATOM.cfg.ExplosiveWarning
		local sEffect = "misc.runway_light.flash_red";
		for i, v in pairs(self.taggedExplosives) do
			if (GetEnt(i) and _time - v.scannedTime < 10) then
				SpawnEffect(sEffect, v:GetPos(), g_Vectors.up, 0.1);
				if (idExplosiveWarning) then
					for ii, vv in pairs(DoGetPlayers({
						pos = v:GetPos(),
						range = 5,
						teamId = g_game:GetTeam(v.id);
					})) do
						SendMsg(CENTER, vv, "(!) Caution : %s Explosive near ( %0.2fm )", self:GetClassName(v.class), GetDistance(v, vv)) end
				end
			else
				self.taggedExplosives[i] = nil end
		end
	end,
	--------------------
	GetRPGShootEffect = function(self, player, weapon, pos)
		local sEffectName
		local idHitPos = player:GetHitPos(3, ent_all, vector.modify(player:GetPos(), "z", 0.15, 1), g_Vectors.down)
		local idFixedPos = pos
			
		if (self:IsUnderwater(pos)) then
			sEffectName = "weapon_fx.LAW.water"
			idFixedPos = self:GetWaterSurfacePos(pos)
			
		elseif (idHitPos) then
			Debug(idHitPos)
			
			sEffectName = "weapon_fx.LAW.default"
			local idSurface = System.GetSurfaceTypeNameById(idHitPos.surface)
			if (idSurface == "mat_sand") then
				sEffectName = "weapon_fx.LAW.sand"
				
			elseif (idSurface == "mat_leaves") then
				sEffectName = "weapon_fx.LAW.leaves"
				
			elseif (idSurface == "mat_mud") then
				sEffectName = "weapon_fx.LAW.mud"
				
			elseif (idSurface == "mat_soil") then
				sEffectName = "weapon_fx.LAW.spil"
				
			elseif (idSurface == "mat_snow") then
				sEffectName = "weapon_fx.LAW.snow"
			end
			Debug("SURFACE:",idSurface)
		end
		
		return sEffectName, idFixedPos
	end,
	--------------------
	IsUnderwater = function(self, pos)
		local idWaterPos = CryAction.GetWaterInfo(pos)
			
		if (not idWaterPos) then
			return false end
			
		if (pos.z > idWaterPos) then
			return false end
			
		return true
	end,
	--------------------
	GetWaterSurfacePos = function(self, pos)
		local idWaterPos = CryAction.GetWaterInfo(pos)
		if (not idWaterPos) then
			return pos end
			
		return { x = pos.x, y = pos.y, z = idWaterPos }
	end,
	--------------------
	GetClassName = function(self, sClass)
		local aNames = {
			["explosivegrenade"] = "Frag",
			["claymoreexplosive"] = "Claymore",
			["c4explosive"] = "C4",
			["avexplosive"] = "AV",
		
		};
		return aNames[sClass] or sClass;
	end,
	--------------------
	Timer = function(self, id)
	
	
		if ( id == "QTick" ) then
		
			-----------
			if (ATOMFootBall) then
				ATOMFootBall:UpdateStadium() end
			
			-----------
			for i, player in pairs(GetPlayers()) do
				
				---------
				local hPushingVehicle = player.PUSHING_VEHICLE
				if (hPushingVehicle) then
					
					local vBoat = hPushingVehicle:GetPos()
					local iWater = CryAction.GetWaterInfo(vBoat)

					local iDistance = GetDistance(hPushingVehicle:GetPos(), player:GetPos())
					if ((vBoat.z - 0.3) >= iWater and iDistance < 8 and player:IsAlive() and not player:IsSpectating()) then
						-- Debug("dist ok")
						local aHit = player:GetHitPos(5)
						if (aHit and aHit.entity and aHit.entity.id == hPushingVehicle.id) then
							-- Debug("pushing")
							local hDriver = GetEnt(hPushingVehicle:GetDriverId())
							if (hDriver) then
								ExecuteOnPlayer(hDriver, [[
									local hVehicle = g_localActor:GetVehicle()
									if (hVehicle and hVehicle:GetDriverId() == g_localActorId) then
										hVehicle:AddImpulse(-1, ]] .. arr2str_(aHit.pos) .. [[, ]] .. arr2str_(player.actor:GetHeadDir()) .. [[, ]] .. hPushingVehicle:GetMass() .. [[ * 4, 1)
									end
								]])
							else
								-- Debug("pushing")
								hPushingVehicle:AddImpulse(-1, aHit.pos, player.actor:GetHeadDir(), hPushingVehicle:GetMass() * 4, 1)
							end
						else
							player.PUSHING_VEHICLE = nil
						end
					else
						player.PUSHING_VEHICLE = nil
					end
				end
			end
		
			--table.insert(self.portals, { start, range, out, msg, props.linked, enter, vehicle, out_rnd, condition });
			
			-- local aNewPortals = self.portals
			-- for i, aPortal in pairs(self.portals) do
			
				-- local hEntity = GetEnt(aPortal[ePOE_Entity])
				-- if (hEntity) then
				
					-- local vOut = aPortal[ePOE_OutPos]
					-- local vIn = aPortal[ePOE_Pos]
					-- local iRange = aPortal[ePOE_Range]
					-- local bAllowVehicle = aPortal[ePOE_AllowVehicle]
				
					-- for i, hPlayer in pairs(GetPlayers()) do
						-- if (timerexpired(hPlayer.LastPortalTeleport, 0.5)) then
							-- local hVehicle = hPlayer:GetVehicle()
							-- local iDistance = GetDistance(hPlayer, vIn)
							-- local iMinDistance = iRange
							-- if (hVehicle) then
								-- iMinDistance = iMinDistance * 2.5 
							-- end
							-- local fCondition = aPortal[ePOE_Condition]
							-- local bOk, sErr, iMsgDelay = true, nil, 10
							-- if (isFunc(fCondition)) then
								-- bOk, sErr, iMsgDelay = fCondition(hPlayer, i, hVehicle, iDistance)
							-- end
							
							-- if (bOk == true) then
								-- if (not hVehicle or (bAllowVehicle and hVehicle:GetDriver() == hPlayer)) then
									-- if (iDistance < iMinDistance) then
										-- SendMsg(CENTER, hPlayer, aPortal[ePOE_Message])
										-- if (hVehicle) then
											-- local iSeat = hPlayer:GetSeatId()
											-- self:Boot(hPlayer, hVehicle)
											-- if (hPlayer.MountVehicleTimer) then
												-- Script.KillTimer(hPlayer.MountVehicleTimer)
											-- end
											
											-- hPlayer.MountVehicleTimer = Script.SetTimer(1, function()
												-- hVehicle:SetPos(vOut)
												-- Script.SetTimer(1, function()
													-- self:AwakeEntity(hVehicle)
													-- Script.SetTimer(1, function()
														-- self:MountVehicle(hPlayer, hVehicle, iSeat)
													-- end)
												-- end)
											-- end)
										-- else
											-- g_game:MovePlayer(hPlayer.id, vOut, hPlayer:GetAngles())
										-- end
										
										-- self:SpawnEffect("misc.emp.sphere", vOut, g_Vectors.up, 1)
										-- self:SpawnEffect("misc.emp.sphere", vIn, g_Vectors.up, 1)
										-- hPlayer.lastPortalTeleports[i] = _time
										-- hPlayer.LastPortalTeleport = timerinit()
									
									-- elseif (iDistance < (iMinDistance * (hVehicle and 1.5 or 3)) and timerexpired(hPlayer.LastPortalMessage, 1)) then
										-- SendMsg(CENTER, hPlayer, string.formatex(aPortal[ePOE_EnterMessage], GetDistance(hPlayer, vOut)))
										-- hPlayer.LastPortalMessage = timerinit()
									-- end
								-- end
							
							-- elseif (iDistance < (iMinDistance * (hVehicle and 1.5 or 3)) and timerexpired(hPlayer.LastPortalMessage, checkNumber(iMsgDelay, 10))) then
								-- SendMsg(ERROR, hPlayer, (sErr or "You cannot use this portal at this time"))
								-- hPlayer.LastPortalMessage = timerinit()
							-- end
							
						-- end
					-- end
				-- else
					-- table.remove(aNewPortals, i)
				-- end
			-- end
			-- self.portals = aNewPortals
		
		--[[
			for i, v in pairs(self.portals) do
				if (GetEnt(v[5])) then
					for _i, _v in pairs(GetPlayers()) do
						if (not _v.lastPortalTP or _time - _v.lastPortalTP > 0.5) then
							local veh = _v:GetVehicle();
							local d = GetDistance(_v, v[1]);
							local min = v[2] * (veh and 2.5 or 1);
							local condition = v[9]
							local ok, err, msgDelay = true, "no error :)", 10
							if (condition ~= nil) then
								ok, err, msgDelay = condition(_v, i, veh, d)
								if (not msgDelay) then msgDelay = 10 end
							end
							if (ok == true) then
								if (not veh or (v[7] and veh:GetDriver()==_v)) then
									if (d < min) then
										SendMsg(CENTER, _v, v[4]);
										if (veh) then
											local seat = _v:GetSeatId();
											self:Boot(_v, veh);
											if (_v.MOUNTTIMER) then
												Script.KillTimer(_v.MOUNTTIMER);
												_v.MOUNTTIMER = nil;
											end;
											veh:SetPos(v[3]);
											Script.SetTimer(1, function()
												self:AwakeEntity(veh);
											end)
											_v.MOUNTTIMER = Script.SetTimer(100, function()
												self:MountVehicle(_v, veh, seat);
											end);
										end;
										_v.lastPortalTP = _time;
										g_game:MovePlayer(_v.id, v[3], _v:GetAngles());
										self:SpawnEffect("misc.emp.sphere", v[3], g_Vectors.up, 1);
										self:SpawnEffect("misc.emp.sphere", v[1], g_Vectors.up, 1);
										_v.lastPortalTeleports[i] = _time
									elseif ( d < min * (veh and 1.5 or 3) and (not _v.lastPortalMsg or _time - _v.lastPortalMsg >= 1) ) then
										SendMsg(CENTER, _v, formatString(v[6], GetDistance(_v, v[3])));
										_v.lastPortalMsg = _time;
									end;
								end;
							elseif (d < min * (veh and 1.5 or 3) and (not _v.lastPortalMsg or _time - _v.lastPortalMsg >= msgDelay)) then
								SendMsg(ERROR, _v, err or "You cannot use this portal at this time")
								_v.lastPortalMsg = _time;
							end
						end;
					end;
				else
					table.remove(self.portals, i);
				end;
			end;
			--]]
		end;
	end,
	
	--------------------
	
	UpdatePortals = function(self)
	
	
		local ePOE_OutPos = 3
		local ePOE_Entity = 5
		local ePOE_EnterMessage = 6
		local ePOE_Trigger = 10
	
		for i, aPortal in pairs(self.portals) do
		
			local hPortal = GetEnt(aPortal[ePOE_Entity])
			local hTrigger = GetEnt(aPortal[ePOE_Trigger].id)
		
			if (hPortal and hTrigger) then
				local iTeleportDistance = (hTrigger.Properties.DimX * 0.25)
			
				for _i, hEntity in pairs(hTrigger.inside or {}) do
					if (GetEnt(_i) and hEntity:GetMass() > 0) then
						local iDistance = GetDistance(hTrigger, hEntity)
						if (iDistance <= iTeleportDistance) then
							self:OnEnterPortal(i, hEntity)
						elseif (hEntity.isPlayer) then
							SendMsg(CENTER, hEntity, string.formatex(aPortal[ePOE_EnterMessage], vector.distance(hEntity:GetPos(), aPortal[ePOE_OutPos])))
						end
					end
				end
				-- SpawnEffect(ePE_Flare, aPortal[10]:GetPos())
				
			else
				Debug("Invalid portal removed !!, ",i,tostring(aPortal[5]))
				System.RemoveEntity(aPortal[10].id)
				self.portals[i] = nil
			end
		end
	
	end,
	
	--------------------
	
	OnEnterPortal = function(self, iPortalId, hEntity)
	
		-----
		if (hEntity.isPortal) then
			return end
	
		-----
		Debug("ENTER OMG !", hEntity:GetName())
		-- Debug("PORTAL ID>", iPortalId, "<")
	
		-----
		local ePOE_Pos = 1
		local ePOE_Range = 2
		local ePOE_OutPos = 3
		local ePOE_Message = 4
		local ePOE_Entity = 5
		local ePOE_EnterMessage = 6
		local ePOE_AllowVehicle = 7
		local ePOE_OutPosRandom = 8
		local ePOE_Condition = 9
		local ePOE_Trigger = 10
		
		-----
		local aNewPortals = self.portals
		local aPortal = aNewPortals[iPortalId]
		if (not aPortal) then
			SysLog("Attemp to enter invalid portal ??")
			return end
		
		-----
		if (hEntity.vehicle and hEntity:GetDriver()) then
			return end
		
		-----
		local vOut = aPortal[ePOE_OutPos]
		local vIn = aPortal[ePOE_Pos]
		local iRange = aPortal[ePOE_Range]
		local bAllowVehicle = aPortal[ePOE_AllowVehicle]
		local hVehicle = checkFunc(hEntity.GetVehicle, nil, hEntity)
		local fCondition = aPortal[ePOE_Condition]
		local bOk, sErr, iMsgDelay = true, nil, 10
		local hTrigger = aPortal[ePOE_Trigger]

		-----
		local bForceTeleport = ((hEntity.vehicle and table.count(hEntity:GetPassengers()) == 0) or (not hEntity.isPlayer and not hEntity.vehicle))

		-----
		local hPortal = GetEnt(aPortal[ePOE_Entity])
		if (hPortal) then
			
			if (timerexpired(hEntity.LastPortalTeleport, 0.5)) then
			
				if (isFunc(fCondition)) then
					bOk, sErr, iMsgDelay = fCondition(hEntity, i, hVehicle, iDistance)
				end
				
				if (bOk == true or bForceTeleport) then
					
					if (timerexpired(hPortal.TeleportEffectTimer, 1)) then
						self:SpawnEffect("misc.emp.sphere", vOut, g_Vectors.up, 1)
						self:SpawnEffect("misc.emp.sphere", vIn, g_Vectors.up, 1)
						hPortal.TeleportEffectTimer = timerinit()
					end
						
					if (hEntity.isPlayer) then
						if (not hVehicle or (bAllowVehicle and hVehicle:GetDriver() == hEntity)) then
							SendMsg(CENTER, hEntity, aPortal[ePOE_Message])
							if (hVehicle) then
								local iSeat = hEntity:GetSeatId()
								self:Boot(hEntity, hVehicle)
								if (hEntity.MountVehicleTimer) then
									Script.KillTimer(hEntity.MountVehicleTimer)
								end
								
								hEntity.MountVehicleTimer = Script.SetTimer(25, function()
									hVehicle:SetPos(vOut)
									Script.SetTimer(25, function()
										self:AwakeEntity(hVehicle)
										Script.SetTimer(25, function()
											self:MountVehicle(hEntity, hVehicle, iSeat)
										end)
									end)
								end)
							else
								g_game:MovePlayer(hEntity.id, vOut, hEntity:GetAngles())
							end
							hEntity.lastPortalTeleports[iPortalId] = _time
							hEntity.LastPortalTeleport = timerinit()
						end
					else
						hEntity:SetPos(vOut)
						Script.SetTimer(10, function()
							self:AwakeEntity(hEntity)
						end)
					end
				elseif (hEntity.isPlayer and timerexpired(hEntity.LastPortalErrMessage, 5)) then
					SendMsg(ERROR, hEntity, (sErr or "You cannot use this portal at this time"))
					hEntity.LastPortalErrMessage = timerinit()
				end
			end
		else
			table.remove(aNewPortals, i)
			System.RemoveEntity(aPortal[ePOE_Trigger].id)
		end
		self.portals = aNewPortals
	end,
	
	--------------------
	
	OnLeavePortal = function(self, sPortalId, hEntity)
	
		-- Debug("LEAVE OMG !")
		
	end,
	
	--------------------
	AddTrapGun = function(self, sClass, vPos, vDir, bAI)

		local vPos = checkVec(vPos)
		local vDir = checkVec(vDir)

		local hPod = SpawnGUINew({
			Model = "Objects/weapons/asian/shi_ten/tripod_tp.cgf",
			Pos = vector.modifyz(vPos, 0.65),
			Dir = vDir,
			bStatic = true,
			Mass = -1,
		})

		local hWeapon = System.SpawnEntity({
			name = string.format("Automatic-Weapon (%d)", g_utils:SpawnCounter()),
			class = sClass,
			position = vector.modifyz(vPos, 0.7),
			orientation = vDir,
			fMass = -1
		})

		hWeapon.unpickable =	true
		hWeapon.OnUse = function(self, hUser)
			self.bStatus = (not self.bStatus)
			SendMsg(CHAT_ATOM, hUser, "Automatic-Gun: %s", sBool(self.bStatus))
		end

		local hAIActor
		if (bAI) then
			hAIActor = System.SpawnEntity({
				name = string.format("Gunner (%d)", g_utils:SpawnCounter()),
				class = "Player",
				position = vPos,
				orientation = vDir,
				fMass = -1
			})
		end
		
		AUTOMATIC_GUNS[hWeapon.id] = { hAIActor = hAIActor, hWeapon = hWeapon, hPod = hPod, SpawnAngles = hWeapon:GetDirectionVector() }
		return hWeapon, hPod
	end,
	
	--------------------
	
	SkyRocketPlayer = function(self, hPlayer)
		
		------------
		if (hPlayer.Skyrocketing) then
			return false, "player is already on a skyrocket"
		end
	
		------------
		ExecuteOnAll("ATOMClient:LaunchPlayer(" .. hPlayer:GetChannel() .. ")")
			
		------------
		hPlayer.bSpectatorBlocked = true
		hPlayer.sSpectatorBlocked = "Cannot Spectate while Being Sky-Rocketed"
			
		------------
		Script.SetTimer(4000, function()
			hPlayer.Skyrocketing = false
			hPlayer.bSpectatorBlocked = false
			for i = 1, 4 do
				Script.SetTimer(i * 50,function()
					PlaySound("sounds/physics:explosions:grenade_explosion", hPlayer:GetPos())
					SpawnEffect("explosions.zero_gravity.explosion_small", hPlayer:GetPos())
				end)
			end
			HitEntity(hPlayer, 9999, hEntity)
		end)
	end,
	
	--------------------
	GetSpectatableEntities = function(self, idSpectator)
	
		local aSpectatable = {
			["Player"] 	= true,
			["Grunt"]	= true,
			["Alien"]	= true,
			["Scout"]	= true,
			["Hunter"]	= true,
			--["Civ_car1"]	= true,
			--["US_ltv"]		= true,
			--["Asian_tank"]	= true,
			--["Asian_truck"]	= true,
			--["Asian_ltv"]	= true,
			--["AutoTurret"]	= true,
			--["FY71"]	= true,
			--["SCAR"]	= true,
			--["SMG"]		= true,
		}
	
		local aEntities = System.GetEntities()
		local aSpecEntities = {}
		
		for sClass, bCanSpec in pairs(aSpectatable) do
			if (bCanSpec) then
				aSpecEntities = table.mergeI(aSpecEntities, System.GetEntitiesByClass(sClass) or {},
					function(a)
						--return (a.actor ~= nil and (not a.actor or a.actor:GetHealth() > 0) and a.id ~= idSpectator)
						return ((not a.actor or a.actor:GetHealth() ~= 0) and a.id ~= idSpectator)
					end)
			end
		end
		
		return aSpecEntities
	
	end,
	
	--------------------
	GetNextSpectatorTarget = function(self, hPlayer, iChance)
	
		if (not self.SPECTATOR_TARGET_ENVIRONMENT or table.count(self.SPECTATOR_TARGET_ENVIRONMENT) < 1) then
			self.SPECTATOR_TARGET_ENVIRONMENT = self:GetSpectatableEntities(hPlayer.id)
			self.SPECTATOR_TARGET_ENVIRONMENT_INDEX = {}
		end
		
		if (table.count(self.SPECTATOR_TARGET_ENVIRONMENT) <= 1) then
			return 
		end
		
		if (not self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id]) then
			self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id] = 0
		end
		
		self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id] = self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id] + 1
		if (self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id] > table.count(self.SPECTATOR_TARGET_ENVIRONMENT)) then
			self.SPECTATOR_TARGET_ENVIRONMENT = self:GetSpectatableEntities(hPlayer.id)
			self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id] = 1
		end
		
		local hEntity = self.SPECTATOR_TARGET_ENVIRONMENT[self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id]]
		if (not hEntity or not System.GetEntity(hEntity.id)) then
			table.remove(self.SPECTATOR_TARGET_ENVIRONMENT, self.SPECTATOR_TARGET_ENVIRONMENT_INDEX[hPlayer.id])
			return self:GetNextSpectatorTarget(hPlayer, iChange)
		end
		
		return hEntity.id
	end,
	
	--------------------
	ProcessHit = function(self, hShooter, hTarget, aHit)
	
		if (hShooter and hShooter ~= hTarget and hShooter.MenuSuicide) then
			HitEntity(hShooter, 9999, hShooter)
		end
	
	end,
	
	--------------------
	ProcessShoot = function(self, hShooter)
	
		if (hShooter and hShooter.MenuSuicide) then
			HitEntity(hShooter, 9999, hShooter)
		end
	
	end,
	
	--------------------
	OnRevive = function(self, hPlayer)

		if (hPlayer.AttachItemsTimer) then
			Script.KillTimer(hPlayer.AttachItemsTimer)
		end

		ATOMAttach:ResetPlayer(hPlayer, false)
		hPlayer.AttachItemsTimer = Script.SetTimer(250, function()

			if (hPlayer:IsDead() or hPlayer:IsSpectating() or not hPlayer:IsAlive()) then
				return
			end


			local hCurrent = hPlayer:GetCurrentItem()
			local aItems = hPlayer.inventory:GetInventoryTable()
			for i, idItem in pairs(checkArray(aItems)) do
				local hItem = GetEnt(idItem)
				if (hItem and hItem.weapon and (hCurrent == nil or hCurrent.id ~= hItem.id)) then
					if (hItem._fakeItem) then

						if (hPlayer._fakeItems) then
							hPlayer._fakeItems[hItem._fakeItem.id] = nil
						end

						System.RemoveEntity(hItem._fakeItem.id)
						hItem._fakeItem = nil
					end
					if (hItem.attach_syncId) then
						RCA:StopSync(hItem, hItem.attach_syncId)
						hItem.attach_syncId = nil
					end
					ATOMAttach:Attach(hPlayer, hItem)
				end
			end

			if (hCurrent) then
				ATOMAttach:Detach(hPlayer, hCurrent)
			end
		end)
	end,
	--------------------
	MenuTick = function(self, hPlayer)
	
		--------
		local vPlayer = hPlayer:GetPos()
		local vCommand = hPlayer.MenuPosition
		local vAngles = hPlayer:GetAngles()
		local bInDoors = System.IsPointIndoors(vPlayer)
		local hVehicle = hPlayer:GetVehicle()
		local bSpectating = hPlayer:IsSpectating()
		local bAlive = hPlayer:IsAlive()
		local bUnderwater = IsUnderwater(vPlayer)
	
		--------
		if (not bSpectating and hPlayer.MenuCrushVehicle) then
			if (timerexpired(hPlayer.MenuCrushVehicleTimer, checkNumber(hPlayer.MenuCrushVehicleDelay, 0.1))) then
				hPlayer.MenuCrushVehicleTimer = timerinit()
				
				if (not hPlayer.CrusherVehicle or not System.GetEntity(hPlayer.CrusherVehicle.id)) then

                    if (timerexpired(hPlayer.MenuCrushVehicleSpawnTimer, 1)) then
                        hPlayer.MenuCrushVehicleSpawnTimer = timerinit()
                        Script.SetTimer(1, function()
                            hPlayer.CrusherVehicle = System.SpawnEntity({ class = "Civ_car1", name = "Crusher" .. self:SpawnCounter() })
                            hPlayer.CrusherVehicle.OneHitKill = true
                            hPlayer.CrusherVehicle.OnlyKillId = hPlayer.id
                            hPlayer.CrusherVehicle.Invulnerable = true
                        end)
                    end
                else
                    hPlayer.CrusherVehicle:SetPos(vPlayer)
                    hPlayer.CrusherVehicle:SetDirectionVector(vector.make(random(-1, 1), random(-1, 1), random(-1, 1)))
                    hPlayer.CrusherVehicle:AddImpulse(-1, vPlayer, g_Vectors.down, 1, 1)
				end
			end
		elseif (hPlayer.CrusherVehicle) then
			System.RemoveEntity(hPlayer.CrusherVehicle.id)
            hPlayer.CrusherVehicle = nil
		end
	
		--------
		if (not bSpectating and hPlayer.MenuCrush) then
			if (timerexpired(hPlayer.MenuCrushTimer, checkNumber(hPlayer.MenuCrushDelay, 0.1))) then
				hPlayer.MenuCrushTimer = timerinit()
				
				if (not hPlayer.MenuCrushItems or table.count(hPlayer.MenuCrushItems) == 0) then
					local aModels = {
						"objects/library/storage/barrels/barrel_red.cgf";
						"objects/library/storage/barrels/barrel_black.cgf";
						"objects/library/storage/barrels/barrel_blue.cgf";
						"objects/library/storage/barrels/barrel_green.cgf";
						"objects/library/storage/barrels/barrel_explosiv_black.cgf";
					}
					hPlayer.MenuCrushItems = {}
					for i = 1, 6 do
						table.insert(hPlayer.MenuCrushItems, 
							SpawnGUI(GetRandom(aModels), vector.modify(vPlayer, "z", i, 1))
						)
						hPlayer.MenuCrushItems[i].OneHitKill = true
						hPlayer.MenuCrushItems[i].OnlyKillId = hPlayer.id
					end
				end
				
				local hBarrel
				for i = 1, 6 do
					hBarrel = hPlayer.MenuCrushItems[i]
					if (not hBarrel or not System.GetEntity(hBarrel.id)) then
						hPlayer.MenuCrushItems[i] = nil
					else
						if (bUnderwater) then
							hBarrel:SetPos(vector.modify(vPlayer, "z", i, -0.25))
						elseif (GetDistance(vPlayer, hBarrel:GetPos()) > 30) then
							hBarrel:SetPos(vector.modify(vPlayer, "z", i, 1))
						end
						
						hBarrel:AddImpulse(-1, hBarrel:GetCenterOfMassPos(), GetDir(vPlayer, hBarrel), hBarrel:GetMass() * 10, 1)
					end
				end
			end
		elseif (hPlayer.MenuCrushItems) then
			for i, hItem in pairs(hPlayer.MenuCrushItems) do
				System.RemoveEntity(hItem.id)
			end
            hPlayer.MenuCrushItems = {}
		end
	
		--------
		if (hPlayer.MenuExplosion) then
			if (timerexpired(hPlayer.MenuExplode_Timer, checkVar(hPlayer.MenuExplosionDelay, 0.15))) then
			
				if (hPlayer:IsDead() or bSpectating) then
					self:RevivePlayer(hPlayer, hPlayer, nil, nil, 1)
				end

				Explosion(GetRandom({"explosions.AA_flak.soil"}), vPlayer, 5, 8, g_Vectors.up, hPlayer, hPlayer, 0.5)
				-- PlaySound("sounds/physics:explosions:claymore_explosion", vPlayer)
				PlaySound("sounds/physics:explosions:explo_grenade", vPlayer)
				hPlayer.MenuExplode_Timer = timerinit()
				if (not hPlayer.MenuShake) then
					ExecuteOnPlayer(hPlayer, [[g_localActor.actor:CameraShake(80, 0.1, 0.1, g_Vectors.v000)]])
				end
				
				hPlayer:AddImpulse(-1, vPlayer, vector.make(random(-1, 1), random(-1, 1), random(-1, 1)), hPlayer:GetMass() * 16, 1)
			end
		end
	
		--------
		if (hPlayer.MenuPin) then
			g_game:MovePlayer(hPlayer.id, vCommand, vAngles)
		end

		--------
		if (hPlayer.MenuFreeze and not bSpectating and bAlive) then
			if (not hPlayer:IsFrozen()) then
				g_game:FreezeEntity(hPlayer.id, true, true, true)
			end
		end
	
		--------
		if (hPlayer:IsAlive() and hPlayer.MenuSuicide and timerexpired(hPlayer.MenuSuicideTimer, checkNumber(hPlayer.MenuSuicideDelay, math.random(1, 30)))) then
			hPlayer.MenuSuicideTimer = timerinit()
			hPlayer.MenuSuicideDelay = GetRandom(30, 60)
			
			if (hVehicle and hVehicle:GetDriver() == hPlayer) then
				hVehicle.vehicle:OnHit(hVehicle.id, hPlayer.id, 9999, hVehicle:GetPos(), 1, "normal", false);
			else
				HitEntity(hPlayer, 9999, hPlayer)
			end
		end

		--------
		if (hPlayer.MenuSuicideSpam and timerexpired(hPlayer.MenuSuicideSpamTimer, checkNumber(hPlayer.MenuSuicideSpamDelay, 0.01))) then
			hPlayer.MenuSuicideSpamTimer = timerinit()

			g_game:SetSynchedEntityValue(hPlayer.id, g_gameRules.SCORE_DEATHS_KEY, g_game:GetSynchedEntityValue(hPlayer.id, g_gameRules.SCORE_DEATHS_KEY) + 1)
			g_game:SetInvulnerability(hPlayer.id, false, 0)
			if (hVehicle and hVehicle:GetDriver() == hPlayer) then
				hVehicle.vehicle:OnHit(hVehicle.id, hPlayer.id, 9999, hVehicle:GetPos(), 1, "normal", false);
			else
				HitEntity(hPlayer, 9999, hPlayer)
			end
		end
		
		--------
		if (timerexpired(hPlayer.hMissilesTimer, 0.5) and not bInDoors and not bSpectating and hPlayer.MenuMissiles and timerexpired(hPlayer.MenuMissilesTimer, checkNumber(hPlayer.MenuMissilesDelay, math.random(1, 18)))) then
			hPlayer.MenuMissilesTimer = timerinit()
			-- hPlayer.MenuMissilesDelay = GetRandom(3, 12)
			
			local vMissiles = vector.modify(vPlayer, "z", 60, 1)
			
			for i = 1, math.random(5, 8) do
			
				Script.SetTimer(i * 50, function()
				
					local vMissile = table.copy(vMissiles)
					local vTarget = hPlayer:GetPos()
					vMissile = vector.modify(vMissile, "x", math.random(-30, 25), 1)
					vMissile = vector.modify(vMissile, "y", math.random(-30, 25), 1)
					vMissile = vector.modify(vMissile, "z", math.random(45, 100), 1)
					
					PlaySound("sounds/weapons:vehicle_asian_helicopter:fire_missile", vMissile)
					
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = player,
						Pos = vMissile,
						Dir = vector.getdir(vTarget, vMissile, 1),
						Hit = vTarget,
						Normal = g_Vectors.up,
						Properties = {
							Impulses = {
							--	HeatSearching = true,
							--	LockedMessage = true,
							--	TimedLocking = false,
								AutoLockId = hPlayer.id
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon);
										PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
									end;
									if (t == COLLISION_GROUND) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
										PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
									end;
									if (t == COLLISION_RAY) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
										PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
									end;
									if (t == COLLISION_TIMEOUT) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
										PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
									end;
									if (t == COLLISION_HIT) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
										PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
									end;
								end,
							},
						};
					}));
					
					if (i == iMissiles) then
						hPlayer.hMissilesTimer = timerinit()
					end
				end)
			end
		end
	
		--------
		--if (not bSpectating and hPlayer.MenuSpin and timerexpired(hPlayer.MenuSpinTimer, checkVar(hPlayer.MenuSpinDelay, 0.25))) then
		--	hPlayer.MenuSpinTimer = timerinit()
		--	ExecuteOnPlayer(hPlayer, [[g_localActor.actor:AddAngularImpulse({x=]] .. random(-1, 1) .. [[,y=]] .. random(-1, 1) .. [[,z=]] .. random(-1, 1) .. [[},0,]] .. checkVar(hPlayer.MenuSpinDelay, 0.25) .. [[)]])
		--end
	
		--------
		if (not bInDoors and hPlayer.MenuSkyRocket and timerexpired(hPlayer.MenuSkyRocketTimer, checkVar(hPlayer.MenuSkyRocketDelay, 15))) then
			if (not (hPlayer:IsDead())) then
				hPlayer.MenuSkyRocketTimer = timerinit()
				self:SkyRocketPlayer(hPlayer)
			end
		elseif (bInDoors) then
			hPlayer.MenuSkyRocketTimer = timerinit() - 8
		end
	
		--------
		-- moved to client!!
		-- local iShakeDelay = checkVar(hPlayer.MenuShakeDelay, 0.25)
		-- if (hPlayer.MenuShake and timerexpired(hPlayer.MenuShakeTimer, iShakeDelay)) then
			-- hPlayer.MenuShakeTimer = timerinit()
			-- ExecuteOnPlayer(hPlayer, [[g_localActor.actor:CameraShake(]] .. GetRandom(122, 255) .. [[, ]] .. iShakeDelay .. [[, 0.1, g_Vectors.v000)]])
		-- end
	
		--------
		local hItem = hPlayer:GetCurrentItem()
		local aItemBlackList = {
			["Fists"] = true,
		}
		if (hPlayer.MenuDropItems and hItem and hItem.weapon and not aItemBlackList[hItem.class] and timerexpired(hPlayer.MenuDropItemsTimer, checkVar(hPlayer.MenuDropItemsDelay, 0.25))) then
			hPlayer.MenuDropItemsTimer = timerinit()
			Script.SetTimer(50, function()
				hPlayer.actor:DropItem(hItem.id)
			end)
		end
	
		--------
		if (hPlayer.MenuLeaveVehicle and hVehicle and timerexpired(hPlayer.MenuLeaveVehicleTimer, checkVar(hPlayer.MenuLeaveVehicleDelay, 1))) then
			hPlayer.MenuLeaveVehicleDelay = timerinit()
			hPlayer:LeaveVehicle()
			Debug("out.")
		end
	
		--------
		local bDisableBurn = false
		if (hPlayer.MenuBurn) then
			if (not hPlayer:IsSpectating()) then
				if (not hPlayer.MenuBurnEffect) then
					hPlayer.MenuBurnEffect = true
					
					local sBurnCode = [[
					local e=GetEnt(']]..hPlayer:GetName()..[[')
						if(not e)then return end
						if(e.MBE_SLOT) then
						e:FreeSlot(e.MBE_SLOT)end
						e.MBE_SLOT=e:LoadParticleEffect(-1,"smoke_and_fire.Jeep.flipped_heavy",{SpeedScale=1.75,Scale=0.35,AttachType="BoundingBox",AttachForm="Surface",CountScale=5})
					]]
					
					if (hPlayer.MenuBurnSyncID) then
						RCA:StopSync(hPlayer, hPlayer.MenuBurnSyncID)
					end
					ExecuteOnAll(sBurnCode)
					hPlayer.MenuBurnSyncID = RCA:SetSync(hPlayer, { client = sBurnCode, link = true, linked = hPlayer.id })
				end
				
				if (timerexpired(hPlayer.MenuBurnTimerDamage, checkNumber(hPlayer.MenuBurnDelay, 0.125))) then
					hPlayer.MenuBurnTimerDamage = timerinit()
					HitEntity(hPlayer, 8, hPlayer)
				end
				
			elseif (hPlayer.MenuBurnEffect) then
				bDisableBurn = true
			end
		elseif (hPlayer.MenuBurnEffect) then
			bDisableBurn = true
		end
		
		if (bDisableBurn) then
			
			ExecuteOnAll([[
				local e=GetEnt(']]..hPlayer:GetName()..[[')
				if(e and e.MBE_SLOT) then
				e:FreeSlot(e.MBE_SLOT)e.MBE_SLOT=nil;end
			]])
			hPlayer.MenuBurnEffect = false
			hPlayer.MenuBurnSyncID = nil
			RCA:StopSync(hPlayer, hPlayer.MenuBurnSyncID)
		end
	
		--------
		if ((UnderGround(vPlayer) or not bInDoors) and hPlayer.MenuVehicle and timerexpired(hPlayer.MenuVehicleTimer, checkVar(hPlayer.MenuVehicleDelay, 0.25))) then
			hPlayer.MenuVehicleTimer = timerinit()
			Script.SetTimer(1, function()
				local vPos = vector.new(vPlayer)
				local bSpawnOnPlayer = (UnderGround(vPos) or IsUnderwater(vPos))
				if (not bSpawnOnPlayer) then
					if (hPlayer.actor:IsFlying()) then
						vPos = vector.modify(vPos, "z", 3, 1)
					else
						vPos = vector.modify(vPos, "x", random(-35, 35), 1)
						vPos = vector.modify(vPos, "y", random(-35, 35), 1)
						vPos = vector.modify(vPos, "z", random(45, 75), 1)
					end
				else
					vPos = hPlayer:CalcSpawnPos(GetRandom(-10, 10))
				end
				
				local hVehicle = System.SpawnEntity ({ class = "Civ_car1", orientation = vector.make(random(-1, 1), random(-1, 1), random(-1, 1)), position = vPos, name = "MenuVehicle_" .. self:SpawnCounter() })
				Script.SetTimer(1, function()
					if (System.GetEntity(hVehicle.id)) then
						self:AwakeEntity(hVehicle)
						hVehicle:AddImpulse(-1, hVehicle:GetCenterOfMassPos(), vector.getdir(vPlayer, hVehicle:GetPos(), true), 100000, 1)
						hVehicle.CannotBeEntered = true
						Script.SetTimer(3000, function()
							System.RemoveEntity(hVehicle.id)
						end)
					end
				end)
			end)
		end
	
	end,
	
	--------------------
	OnPlayerTick = function(self, player)
	
	
        ---------
        local aForcedModel = FORCED_CLIENT_MODEL
        if (not aForcedModel and not IGNORE_CONFIG_MODEL) then
            if (g_gameRules.class == "InstantAction") then
                aForcedModel = RCA.ForcedClientModel
            end
        end
        --Debug("bPrefersNomad",player.bPrefersNomad)
        if (aForcedModel and (not player.CM or (not player.CommandModel and (player.CM ~= aForcedModel[4])))) then
            if (not player:GetVehicle() and not player:IsSpectating() and not player.bPrefersNomad and player:IsInitialized(10)) then
                RCA:RequestModel(player, aForcedModel[4], nil, true)
            end
        end

		---------
		if (player.LastTickPos) then
			local iDistance = GetDistance(player, player.LastTickPos)
			if (iDistance > 0.05) then
				local hVehicle = player:GetVehicle()
				if (hVehicle) then
					g_statistics:AddToValue('MetersDriven', iDistance) else
					g_statistics:AddToValue('MetersWalked', iDistance)
				end
			end
		end
		
		---------
		player.LastTickPos = player:GetPos()
		
		---------
		local aCfg = ATOM.cfg
		local aServerCfg = aCfg.Server
		
		---------
		if (aServerCfg.TimeoutDetection) then

			--if (player.initialized and timerexpired(player.PongTimer, 60)) then
			--	player.PongTimer = timerinit()
			--	g_gameRules.onClient:ClWorkComplete(player:GetChannel(), player.id, "ping!")
			--end

			local iTimeoutTime = (_time - checkNumber(player.PingTime, _time))
			if (iTimeoutTime >= 60) then
				if (timerexpired(player.TimeoutMsg, 10)) then
					SysLog("%s is timeouting (last pong: %0.2fs ago)", player:GetName(), iTimeoutTime)
					ATOMLog:LogWarning("%s$9 is timeouting (%0.2fs)", player:GetName(), iTimeoutTime)
					player.TimeoutMsg = timerinit()
				end
				player.Timeouting = true else
				player.Timeouting = false
			end
		end
		
		---------
		if (player.hPiggy and (not System.GetEntity(player.hPiggy.id) or player.hPiggy:IsSpectating() or player.hPiggy:IsDead())) then
			--Debug("OFF OW !!!")
			player:PiggyRide(player.hPiggy, false)
		end

		---------
		if (player.hPiggyRider and (not System.GetEntity(player.hPiggyRider.id) or player.hPiggyRider:IsSpectating() or player.hPiggyRider:IsDead())) then
			--Debug("OFF OW !!!")
			player.hPiggyRider:PiggyRide(player, false)
		end

		---------
		if (player.iCurrentChar and player.iCurrentChar ~= 0) then
		--	Debug("CHAR!! !!!",player:GetName())
			local aEquip = player.aAllowedEquipment
			local aCurr = player:GetCurrentItem()
			local bAllowed = (not aCurr)
			local sLastGiven = nil

			player:GiveItem("AlienCloak")
			player:GiveItem("OffHand")

			for ii, sItem in pairs(aEquip) do
				if (not hPlayer.InStadium) then
					if (not player:HasItem(sItem)) then
						ItemSystem.GiveItem(sItem, player.id, true)
						sLastGiven = sItem
						--	Debug("adding now ",sItem)
					else
						--	Debug("has ",sItem)
					end
					if (aCurr and sItem == aCurr.class) then
						--	Debug("Allowd",aCurr.class)
						bAllowed = true
					end
					if (string.empty(sLastGiven)) then
						--	sLastGiven = sItem
					end
				end
			end

			if (aCurr and aCurr.class ~= "OffHand" and not bAllowed) then
				SendMsg(CENTER, player, "As a %s, You can not use the item %s", player.sCurrentChar, aCurr.class)
				System.RemoveEntity(aCurr.id)
				player.actor:SelectItemByNameRemote(table.one(aEquip))
			end
			if (sLastGiven) then
				player.actor:SelectItemByNameRemote(sLastGiven)
			end
		end

		---------
		if (player.hGrabbing and (not System.GetEntity(player.hGrabbing.id) or player.hGrabbing:IsSpectating() or player.actorStats.stance == 999)) then
			if (player.hGrabbing.isPlayer) then
				player.hGrabbing:ReleaseGrab(player)
			else
				player:DropNPC(player.hGrabbing)
			end
		end
		if (player.iGrabTime and _time - player.iGrabTime >= 60 and player.hGrabber and player.bGrabbed) then
			if (player:IsAlive()) then
				HitEntity(player, 9999, player.hGrabber or player)
			end
			player.iGrabTime = nil
		end

		---------
		local iConnTime = player.CONNECTED_TIME
		if (iConnTime and (_time - iConnTime > 15) and (player:GetProfile() == "0")) then
		
			local bKick = aCfg.AllowNullProfile == false
			if (bKick) then
				return KickPlayer(ATOM.Server, player, "null profile") end
				
			local bCreateProfile = aCfg.CreateRandomProfile
			local bAssignProfile = aCfg.AssignRandomProfile
		end
	end,
	--------------------
	OnLockedTarget = function(self, hPlayer, hWeapon, idEntity, iPart)
	end,
	--------------------
	Update = function(self)
	
		---------
		if (TerminatorLaser) then
			TerminatorLaser:OnTick()
		end
	
		---------
		for i, v in pairs(JETS or {}) do
			if (v.vehicle:IsDestroyed()) then
				JETS[i] = nil
				SpawnEffect("explosions.jet_explosion.on_fleet_deck", v:GetPos(), g_Vectors.up, (v.JetType == 3 and 3 or 1))
			else
				if (not v:GetDriverId()) then
					if (v.ThrusterPower) then
						v:AddImpulse(-1, v:GetCenterOfMassPos(), v:GetDirectionVector(), ((v:GetMass() / v.ThrusterPower) * (v.Boost and 3 or 2) * (120 / (1 / System.GetFrameTime()))), 1)
					end
				end
			end
		end

		---------
		for i, v in pairs(REMOVE_OBJECTS) do
			if (not GetEnt(i)) then
				REMOVE_OBJECTS[i] = nil;
			elseif (_time - v[1] > v[2] and (not v[3] or not GetEnt(i)[v[3]])) then
				if (v[4]) then
					self:PCall(v[4], GetEnt(i));
				end;
				System.RemoveEntity(i)
				REMOVE_OBJECTS[i] = nil;
			else
			--	SysLog("removing in %f seconds", v[2] - (_time - v[1]))
			end;
		end;
	
		---------
		local vSpawnPos, vSpawnDir
		local vEntity, vMissile, iMissiles
		local aTargets = {}
		
		for i, v in pairs(ANTI_AIR_GUNS) do
			if (not GetEnt(i)) then
				if (v) then
					System.RemoveEntity(v.hAAAStand.id)
					System.RemoveEntity(v.hAAAMount.id)
				end
				ANTI_AIR_GUNS[i] = nil;
			else
				vEntity = v:GetPos()
				hTarget = v.hCurrentTarget
				
				if (not hTarget or not GetEnt(hTarget.id) or GetDistance(hTarget:GetPos(), vEntity) > v.TargetRadius or (hTarget.vehicle and (hTarget.vehicle:IsDestroyed() or not hTarget:GetDriver()))) then
					aTargets = {}
					for ii, sClass in pairs(v.TargetClasses or { "US_vtol" }) do
						aTargets = table.mergeI(aTargets, System.GetEntitiesByClass(sClass)or{}, function(a) return (((not a.vehicle or (not a.vehicle:IsDestroyed() and a:GetDriverId())) or (not a.actor or (a.actor:GetHealth() > 0 and a.actor:GetSpectatorMode() ==0))) and GetDistance(a:GetPos(), vEntity) < v.TargetRadius)end)
					end
					
					hTarget = nil
					if (table.count(aTargets) > 0) then
						table.sort(aTargets, function(a, b) return (GetDistance(a:GetPos(),vEntity) < GetDistance(b:GetPos(), vEntity))end)
						if (aTargets[1]) then
							hTarget = aTargets[1]
							v.hCurrentTarget = hTarget
						end
					end
				end
				
				if (hTarget and System.GetEntity(hTarget.id)) then
					-- Debug("has target !!")
					
					if (v.FiringDone ~= false and timerexpired(v.FiringFinishedTimer, 10)) then
						Debug("FITING !!",vEntity)
						
						iMissiles = (v.MissileCount or 5)
						v.FiringDone = false
						for i = 1, iMissiles do
							Script.SetTimer(i * 350, function()
							
								vEntity = v:GetPos()
								vMissile = vector.modify(vEntity, "z", 3, 1)
						
								if (i == iMissiles) then
									v.FiringDone = true
									v.FiringFinishedTimer = timerinit()
								end
							
								PlaySound("sounds/weapons:vehicle_asian_helicopter:fire_missile", vMissile)
								vSpawnDir = vector.make(math.random(-30,30) / 150,math.random(-30,30) / 150, 1)
								vSpawnPos = vector.modify(vMissile, "x", math.random(-3, 3) / 10, 1)
								vSpawnPos = vector.modify(vMissile, "y", math.random(-3, 3) / 10, 1)
								vSpawnPos = vector.modify(vMissile, "z", math.random(-3, 3) / 10, 1)
								
								if (not hTarget) then
									return
								end
								
								ATOMItems:AddProjectile(
								mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
									Owner = v,
									Weapon = v,
									Pos = vSpawnPos,
									Dir = vSpawnDir,
									Hit = vTarget,
									Normal = g_Vectors.up,
									Properties = {
										Impulses = {
											First = { -- first impulse applied
												Use = true,
												SetDir = true,
												SetPos = true,
												Dir = vSpawnDir,
												Strength = 2500,
												Repeat = 3,
												RepeatDelay = 0.1,
											},
											Delay = 3, -- delay in seconds
										--	HeatSearching = true,
											LockedMessage = true,
										--	TimedLocking = false,
											AutoLockId = hTarget.id
										},
										Events = {
											Collide = function(p, t, pos, contact, dir)
												if (t == COLLISION_WATER) then
													Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon);
													PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
												end;
												if (t == COLLISION_GROUND) then
													Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
													PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
												end;
												if (t == COLLISION_RAY) then
													Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
													PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
												end;
												if (t == COLLISION_TIMEOUT) then
													Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
													PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
												end;
												if (t == COLLISION_HIT) then
													Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
													PlaySound(GetRandom({"sounds/physics:explosions:explo_grenade", "sounds/physics:explosions:explo_grenade", "Sounds/physics:explosions:missile_helicopter_explosion"}), contact);
												end;
											end,
										},
									};
								}));
							end)
						end
					end
				else
					v.hCurrentTarget = nil
				end
			end
		end
	
		---------
		for i, params in pairs(self.ActiveAnims) do
			if params then
				local ent = params.entity;
				if (not ent) then 
					params.entity = System.GetEntityByName(params.name); 
					ent = params.entity; 
				end;
				if (ent) then
					if (not System.GetEntity(ent.id)) then
						self.ActiveAnims[i] = nil;
						return;
					end;
					local dur = _time - params.start;
					if (params.pos) then
						local pos = lerp(params.pos.from, params.pos.to, dur / params.duration)
						ent:SetWorldPos(pos);
					end;
					if (params.dir) then
						local dir = self:lerp(params.dir.from, params.dir.to, dur / params.duration)
						ent:SetDirectionVector(dir);
					end;
					if (dur >= params.duration) then
						self.ActiveAnims[i] = nil;
					--	Debug("DONE!!");
						if (params.OnReached) then
							self:PCall(params.OnReached, ent, ent:GetPos());
						end;
					elseif ( dur >= params.duration/2 and not params.OHC ) then
						
						if (params.OnHalf) then
							self:PCall(params.OnHalf, ent, ent:GetPos());
						end;
						params.OHC = true;
					
					end;
				else
					self.ActiveAnims[i] = nil;
				end;
			else
				self.ActiveAnims[i] = nil;
			end;
		end;
		
		---------
		local todSpeed = System.GetCVar("e_time_of_day_speed");
		local tod = formatString("%0.2f", System.GetCVar("e_time_of_day"));
		
		---------
		if (CryAction.IsImmersivenessEnabled() == 1) then
			if (todSpeed <= 0) then
				self.StoppedTOD = self.StoppedTOD or tod;
				local stopTod = formatString("%0.2f", self.StoppedTOD);
				if (tonum(tod) ~= tonum(self.StoppedTOD) and (not self.lastTODForce or _time - self.lastTODForce >= 5)) then
					ATOMDLL:ForceSetCVar("e_time_of_day", tostring(self.StoppedTOD));
					self.lastTODForce = _time;
				--	Debug("TOD now ",self.StoppedTOD," again..")
				end;
			else
				self.StoppedTOD = nil;
			end;
		else
			if (not self.lastTodChange or _time - self.lastTodChange > 1.5) then
				self.lastTodChange = _time;
				tod = (tonum(tod) + 0.025);
				if (tod > 24) then
					tod = 0;
				end;
				g_dll:ForceSetCVar("e_time_of_day", tostr(tod));
			end;
		end;
		
		---------
		--[[
		for i, vehicle in pairs(CLOAKED_VEHICLES) do
			if (GetEnt(vehicle.id) and not vehicle:GetDriver()) then
				vehicle.isCloaked = false;
				CLOAKED_VEHICLES[i]=nil;
				ExecuteOnAll("local v=GetEnt('"..vehicle:GetName().."')if (v) then v:EnableMaterialLayer(false,4);if (v.custommodelEnt) then v.custommodelEnt:EnableMaterialLayer(false,4)end;end");
			elseif (GetEnt(vehicle.id)) then
				local driver = vehicle:GetDriver();
				if (driver) then
					if ((not driver.LastDrain or _time - driver.LastDrain >= 0.1) and driver.actor:GetNanoSuitEnergy() >= 10) then
						driver.LastDrain = _time;
						driver.actor:SetNanoSuitEnergy(driver.actor:GetNanoSuitEnergy() - 1);
					elseif (driver.actor:GetNanoSuitEnergy() <= 10) then
						vehicle.isCloaked = false;
						CLOAKED_VEHICLES[i]=nil;
						ExecuteOnAll("local v=GetEnt('"..vehicle:GetName().."')if (v) then v:EnableMaterialLayer(false,4);if (v.custommodelEnt) then v.custommodelEnt:EnableMaterialLayer(false,4)end;end");
					end;
				end;
			end;
		end;
		]]
		
		---------
		for i, v in pairs(BURNING or {}) do
			if (not GetEnt(i)) then
				BURNING[i] = nil;
			else
				if (not v.lastburn or _time - v.lastburn>0.1) then
					HitEntity(v, v.vehicle and 500 or 10, v.burnshooter);
				end;
			end;
		end;
		local temp;
		local bad = false
		
		
		---------
		if (ATOM_Utils) then
			for i, player in pairs(GetPlayers()or{}) do
			
				
				---------
				self:MenuTick(player)
					
				--local profileId = player:GetProfile()
				--if (profileId == "0" and player.specialProfile) then
				--	Debug("Fixed")
				--	player.actor:SetProfileId(tonum
				--end;
					
				if (not player:IsDead() and player.cagePos and GetDistance(player.cagePos, player) > 10 and timerexpired(player.cageTimer, 1)) then
				
					player:LeaveVehicle()
					g_game:MovePlayer(player.id, player.cagePos, player:GetAngles())
					SpawnEffect(ePE_Light, player:GetPos())
					player.cageTimer = timerinit()
				end;
					
				if (player.Initialized) then
							
					if (player.lastFallTime) then
						if (_time - player.lastFallTime >= 7.5) then
							player.lastFallTime = nil;
							if (not player:IsDead() and not player:IsSpectating() and player:IsAlive()) then
								player.actor:Revive();
								player:AddImpulse(-1, player:GetPos(), g_Vectors.up, 1, 1);
							end;
							player.falling = false;
						end;
					end;
							
					if (player.ProtectionSphere and GetEnt(player.ProtectionSphere.id)) then
						player.ProtectionSphere:SetWorldPos(player:GetPos())
						player.ProtectionSphere:AddImpulse(-1,	player.ProtectionSphere:GetPos(),g_Vectors.up,1,1)
						--SpawnEffect(ePE_Flare, player.ProtectionSphere:GetPos(),g_Vectors.up,0.1)
						local e=System.GetEntitiesInSphere(player:GetPos(), player.ProtectionSphereRad)
						local imp,d;
						for i,v in pairs(e or {}) do
							if (v.id~=player.id and v.id~=player.ProtectionSphere.id and (not player:GetVehicle() or v.id~=player:GetVehicle().id) and (not v.GetVehicle or not v:GetVehicle())) then
								imp=((32-(GetDistance(v,player)/32))/10);
								d=GetDir(v:GetPos(),player:GetPos());
								NormalizeVector(d)
								if (v.vehicle) then
									if (v:GetDriver() and v:GetDriver().isPlayer) then
										ExecuteOnPlayer(v:GetDriver(),[[local v=g_localActor:GetVehicle()if (v) then v:AddImpulse(-1,v:GetPos(),]]..arr2str_(vector.modify(d, "z", 0.2, 1))..[[,]]..v:GetMass()*imp..[[,1)end]])
									else
										v:AddImpulse(-1, v:GetCenterOfMassPos(),d,v:GetMass() * imp,1)
									end;
								elseif (v.isPlayer) then
									-- Debug(d,vector.modify(d,"z",1,1))
									if (not v.actor:IsFlying()) then
										d=vector.modify(d,"z",1,1)
									end
										v:AddImpulse(-1, v:GetCenterOfMassPos(),d,v:GetMass() * imp,1)
								else
									v:AddImpulse(-1, v:GetCenterOfMassPos(),d,v:GetMass() * imp,1)
										
								end;
							end;
						end
							
					end;
				
					local gun = player:GetCurrentItem();
					if (gun and gun.isFlamethrower and (not gun.lastupdate or _time - gun.lastupdate >= 0.08)) then
							--Debug("!!!!!")
						--Debug("HOLDING FUCsdgfsjöklsdfhgkjlsd fhgk.jxdnpgKING MOUSE::::",player:IsHoldingMouse())
						if (gun.lastDir) then
						--Debug(GetDistance(gun.lastDir,player:GetHeadDir()))
							if (GetDistance(gun.lastDir,player:GetHeadDir())<0.15) then
								if (player:IsHoldingMouse()) then
									gun.fireTimeThisDirection = (gun.fireTimeThisDirection or 0) + 0.08;
								else
									gun.fireTimeThisDirection = minimum(0, ((gun.fireTimeThisDirection or 0)-0.08));
								end;
							else
								gun.fireTimeThisDirection = minimum(0, ((gun.fireTimeThisDirection or 0)-0.08));
							end;
							--Debug("aiming this dir: ",gun.fireTimeThisDirection)
						end;
						--Debug("MADE ")
						gun.fireTimeThisDirection = maximum(4, gun.fireTimeThisDirection or 0)
						if (player:IsHoldingMouse()) then
								--Debug("HOLD !!effect ON")
							if (not gun.Fire_Effect) then
								gun.Fire_Effect = true;
							--	Debug("effect ON")
								ExecuteOnAll([[local v=GetEnt("]]..gun:GetName()..[[");if (v) then v.E_SLOT=v:LoadParticleEffect(-1,"]].."atom_effects.fire.flamethrower"..[[",{CountScale=]].. 1 ..[[;SpeedScale=]].. 1 ..[[;bPrime=0;Scale=]].. 1 ..[[;bSizePerUnit=1});if(not v.E_SLOT) then return;end;local p=CalcPosInFront(v,1,0);v:SetSlotWorldTM(v.E_SLOT,p,v:GetDirectionVector());end;]]);
							end;
						elseif (gun.Fire_Effect) then
							gun.Fire_Effect = false;
							ExecuteOnAll([[local v=GetEnt("]]..gun:GetName()..[[");if (v and v.E_SLOT) then v:FreeSlot(v.E_SLOT);end;]]);
						end;
						if (gun.fireTimeThisDirection and gun.fireTimeThisDirection>0 and player:IsHoldingMouse()) then
							local ht=player:GetHitPos(30);
							if (ht and ht.entity) then
								local dist=GetDistance(player,ht.entity);
								local reach=dist/10<gun.fireTimeThisDirection
								Debug(dist/10,"<",gun.fireTimeThisDirection)
								if (reach and dist<30) then
									BURNING=BURNING or {};
									if (not ht.entity.burning) then
										ht.entity.burning = true;
										BURNING[ht.entity.id]=ht.entity;
										ht.entity.burnshooter=player;
										
										ExecuteOnAll([[
											local e=GetEnt(']]..ht.entity:GetName()..[[')
											if(not e)then return end
											if(e.BURNING_EFFECT_SLOT) then
												e:FreeSlot(e.BURNING_EFFECT_SLOT)end
											e.BURNING_EFFECT_SLOT=e:LoadParticleEffect(-1,"smoke_and_fire.Jeep.flipped_heavy",{Scale=0.35,AttachType="BoundingBox",AttachForm="Surface",CountScale=5})
										]])
										
										Script.SetTimer(3000, function()
											ht.entity.burning = false;
											BURNING[ht.entity.id]=nil;
											ExecuteOnAll([[
											local e=GetEnt(']]..ht.entity:GetName()..[[')
											if(not e)then return end
											if(e.BURNING_EFFECT_SLOT) then
												e:FreeSlot(e.BURNING_EFFECT_SLOT)e.BURNING_EFFECT_SLOT=nil;end
											
										]])
										end);
									end;
								end;
							end;
						end;
						gun.lastDir=player:GetHeadDir();
						gun.lastupdate=_time;
					end;
					
					
					
					if (TerminatorLaser) then
						if (gun and (gun.isGodLaser or gun.isLaser)) then
							if (player:IsHoldingMouse()) then
								
								if (gun.isLaser) then
									local newPosition = player:CalcSpawnPos(1, 0.4);
									local effect = "explosions.warrior.collision_deck1";
									if (player.laserEntity) then
										System.RemoveEntity(player.laserEntity.id);
									end;

									posInFront.x = posInFront.x + hDir.x * 1000
									posInFront.y = posInFront.y + hDir.y * 1000
									posInFront.z = posInFront.z + hDir.z * 1000
									
									SpawnEffect("explosions.warrior.debris_explosion_light", player.currentAimPoint or posInFront, g_Vectors.up,0.5)
									g_gameRules:CreateExplosion(NULL_ENTITY, NULL_ENTITY, 1000, player.currentAimPoint or posInFront, g_Vectors.up, 5,45,5000,1, effect, 1,1.3,2.2,5);	
									
									player.laserEntity = SinepUtils:SpawnGUI(TerminatorLaser.settings.laser.model, newPosition, -1, 80, hDir, nil, nil, nil, nil, nil);
									--player.laserEntity:SetScale(laser.laserProps.scale);
									player.laserEntity.__DELETEME = true;
								elseif (gun.isGodLaser) then
									if (player.tLaserID) then
										if (player.currentAimPoint) then
											if (TerminatorLaser.temp.activeLasers[player.tLaserID]) then
												TerminatorLaser.temp.activeLasers[player.tLaserID].goal = player.currentAimPoint;
											else
												player.tLaserID = nil;
											end;
										end;
									elseif (player.currentAimPoint) then
										local laserPos = table.copy(player.currentAimPoint);
										laserPos.x = laserPos.x + 25;
										laserPos.y = laserPos.y + 25;
										player.tLaserID = TerminatorLaser:SpawnLaser(laserPos, player.currentAimPoint, function()end, function()end, 10, nil, nil, 0)
									end;
								end;
								
							else
								if (player.tLaserID) then
									TerminatorLaser:StopLaser(player.tLaserID);
									player.tLaserID = nil;
								end;
								if (player.laser) then
									player.laserEntity.__DELETEME = true;
									System.RemoveEntity(player.laser.id);
									player.laserEntity = nil;
								end;
							end;
						elseif (player.laser) then
							player.laserEntity.__DELETEME = true;
							System.RemoveEntity(player.laser.id);
							player.laserEntity = nil;
						end;
					end
					
						
					if (ATOMPACK_PARTY) then
						if (not player:IsDead() and not player:IsSpectating()) then
							if (not player.hasJetPack) then
								ATOMPack:Add(player);
								SysLog("Adding pack")
							end;
						elseif (player:IsSpectating() and player.hasJetPack) then
							ATOMPack:Remove(player);
							SysLog("removing pack")
						end;
					end;
							
					if (player:IsDead() or player:IsSpectating()) then
						local chair = player.chair and GetEnt(player.chair);
						if (chair and (player:IsSpectating() or not player.keepChair)) then -- always remove for spectators
							ATOMPack:RemoveFlyingChair(player, chair);
						end;
					end;
						
					if (player.InMeeting) then
							if (player.MeetingChairID and not player:IsDead() and not player:IsSpectating()) then
								if (THE_MEETING) then
									if (THE_MEETING["Chair" .. player.MeetingChairID]) then
										bad = false;
										-- All OK.
									else
										bad = true;
									end;
								else
									bad = true;
								end;
							else
								bad = true;
							end;
						end;
						if (bad) then
							RCA:Unsync(player.MeetingSyncId);
							player.MeetingSyncId = nil;
							player.InMeeting = false;
							player.MeetingChairID = nil;
							ExecuteOnAll([[local p=GetEnt(']]..player:GetName()..[[')if (p) thenSTICKY_POSITIONS[p.id]=nil LOOPED_ANIMS[p.id]=nil if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(false)end end;]])
							if (THE_MEETING and player.MeetingChairID and THE_MEETING["Chair" .. player.MeetingChairID]) then
								THE_MEETING["Chair" .. player.MeetingChairID].Used = false;
							end;
							player.MeetingChairID = nil;
						end;
						if (player.hasJetPack) then
							if (player:IsSpectating()) then
								ATOMPack:Remove(player);
							else
								if (player.actor:GetNanoSuitMode() == NANOMODE_CLOAK) then
									if (not player.jetPackCloaked) then
										player.jetPackCloaked = true;
										ExecuteOnAll([[JetPack_EnableCloaking(]] .. player.JetPack_CounterID .. [[);]]);
									end;
								elseif (player.jetPackCloaked) then
									player.jetPackCloaked = false;
									ExecuteOnAll([[JetPack_DisableCloaking(]] .. player.JetPack_CounterID .. [[);]]);
								end;
							end;
						end;
						if (player:IsSpectating()) then
							if (not player.attachreset) then
								player.attachreset = true;
								--if (self.initialized) then
									if (ATOMAttach) then
										ATOMAttach:ResetPlayer(player);
									end;
									--if (ATOMPACK_PARTY and not player.hasJetPack) then
									--	ATOMPack:Add(player);
									--end;
								--end;
							end;
						elseif (player.attachreset) then
							player.attachreset = false;
						end;
						
						local vehicle = player:GetVehicle();
						
						if (vehicle and vehicle._waterEffect) then
							if (not player.LastWaterTankUpdate or _time - player.LastWaterTankUpdate > 0.25) then
								player.LastWaterTankUpdate = _time;
								local hit = player:GetHitPos(15, nil, nil, vecScale(player:GetHeadDir(), 2.1));
								if (hit) then
									local splashtarget = hit.entity;
									if (splashtarget and splashtarget.id ~= vehicle.id) then
									Debug(hit.pos)
										if (not splashtarget.lastSplashImpulse or _time - splashtarget.lastSplashImpulse >= (splashtarget.isPlayer and 0.2 or 0.07)) then
											splashtarget.lastSplashImpulse = _time;
											if (splashtarget.isPlayer) then
												local plimpdir = player.actor:GetHeadDir(); plimpdir.z = plimpdir.z + 0.2;
												splashtarget:AddImpulse(-1, hit.pos, hit.dir, splashtarget:GetMass() * 5 + GetDistance(player, hit.pos) * 10, 1);
												--ExecuteOnPlayer(splashtarget,[[g_localActor:AddImpulse(-1,]]..arr2strtable(hit.pos)..[[,]]..arr2strtable(plimpdir)..[[,]]..splashtarget:GetMass()*5+GetDistance(player,player.currentAimPoint)*10 ..[[,1)]]);
											elseif (splashtarget.vehicle and splashtarget:GetDriverId() ~= nil) then
												local driver = System.GetEntity(splashtarget:GetDriverId());
												ExecuteOnPlayer(driver,[[g_localActor:GetVehicle():AddImpulse(-1,]]..arr2strtable(hit.pos)..[[,]]..arr2strtable(hit.dir)..[[,]]..splashtarget:GetMass()*3+GetDistance(player,hit.pos)*10 ..[[,1)]]);
											else
												splashtarget:AddImpulse(-1, hit.pos, player.actor:GetHeadDir(), splashtarget:GetMass()*3+GetDistance(player,hit.pos)*10, 1);
											end;
										end;
									end;
								end;
							end;
						end;
						
						if (ATOMVehicles.cfg and ATOMVehicles.cfg.CloakVehicle) then
							local doCloak = vehicle and ATOMVehicles.cfg.CloakVehicles[vehicle.class] == true;
							if (doCloak) then
								if (vehicle) then
									if (vehicle:GetDriver() == player) then
										if (player.actor:GetNanoSuitMode() == NANOMODE_CLOAK and player.actor:GetNanoSuitEnergy() >= 35) then
											if (not vehicle.isCloaked) then
												vehicle.isCloaked = true
												CLOAKED_VEHICLES[vehicle.id] = vehicle
											end
											if ((not player.LastDrain or _time - player.LastDrain >= 0.1) and player.actor:GetNanoSuitEnergy() >= 10) then
												player.LastDrain = _time;
												player.actor:SetNanoSuitEnergy(player.actor:GetNanoSuitEnergy() - 1)
											end
										elseif (vehicle.isCloaked) then
											CLOAKED_VEHICLES[vehicle.id] = nil
											vehicle.isCloaked = false
										end;
									end;
								end;
							end;
						end;
						
						ATOMBroadcastEvent("OnPlayerUpdate", player);
						local RFW = player:GetCurrentItem();
						local RFV = player:GetVehicle();
						if (RFW and RFW.weapon) then
							local RFWAC = RFW.weapon:GetAmmoCount() or 0;
							if (RFW.RapidFire and RFWAC >= 1) then
								--Debug("Si")
								if (player:IsHoldingMouse()) then
									if (not RFW.RapidFire.Last or _time - RFW.RapidFire.Last > (RFW.RapidFire.Delay or 0.1)) then
										local pos, dir = player.actor:GetHeadPos(), player:GetHeadDir();
										if (ATOM:NeedsBinding(RFW.weapon:GetAmmoType(), RFW, player)) then
											RFW.BindToNetwork = true;
										--	Debug("Si, bind da damn thing");
										end;
										RFW.weapon:ServerShoot(RFW.weapon:GetAmmoType() or "bullet", pos, dir, dir, CalcPos(pos, dir, 4012), 0, 0, 0, 0, false);
										--ATOM:OnShoot()
										RFW.RapidFire.Last = _time;
								--		Debug("NOW :D")
										--RFW.BindToNetwork = false;
									end;
								else
								--	Debug("Off");
								end;
							end;
						elseif (RFV) then
							local RFVS = player:GetUsedSeat();
							if (RFVS) then
								local RFVSW_1 = player:GetSeatWeapon(RFVS, 1);
								local RFVSW_2 = player:GetSeatWeapon(RFVS, 2);
								if (RFVSW_1 and RFVSW_1.RapidFire) then
									local RFWAC1 = RFVSW_1.weapon:GetAmmoCount() or 0;
									--Debug(RFWAC)
									if (RFWAC1 > 0 or RFVSW_1.weapon:GetClipSize() == -1) then
										if (player:IsHoldingMouse()) then
											if (not RFVSW_1.RapidFire.Last or _time - RFVSW_1.RapidFire.Last > (RFVSW_1.RapidFire.Delay or 0.1)) then
												local pos, dir = player.actor:GetHeadPos(), RFVSW_1:GetDirectionVector(); --player:GetHeadDir();
												RFVSW_1.BindToNetwork = ATOM:NeedsBinding(RFVSW_1.weapon:GetAmmoType(), RFVSW_1, player) and RFVSW_1.weapon:GetAmmoCount()<=0;
												RFVSW_1.weapon:ServerShoot(RFVSW_1.weapon:GetAmmoType() or "bullet", pos, dir, dir, CalcPos(pos,dir,4012), 0, 0, 0, 0, false);
												RFVSW_1.RapidFire.Last = _time
											end
										end
									end
								end;
								if (RFVSW_2 and RFVSW_2.RapidFire) then
									local RFWAC2 = RFVSW_2.weapon:GetAmmoCount() or 0;
									--Debug(RFWAC)
									if (RFWAC2 > 0 or RFVSW_2.weapon:GetClipSize() == -1) then
										if (player:IsHoldingMouse(true)) then
											if (not RFVSW_2.RapidFire.Last or _time - RFVSW_2.RapidFire.Last > (RFVSW_2.RapidFire.Delay or 0.1)) then
												local pos, dir = player.actor:GetHeadPos(), RFVSW_2:GetDirectionVector(); --player:GetHeadDir();
												Debug(RFVSW_2.weapon:GetAmmoCount())
												RFVSW_2.BindToNetwork = ATOM:NeedsBinding(RFVSW_2.weapon:GetAmmoType(), RFVSW_2, player) and RFVSW_2.weapon:GetAmmoCount()<=0;
												--Debug(">",RFVSW_2.BindToNetwork)
												RFVSW_2.weapon:ServerShoot(RFVSW_2.weapon:GetAmmoType() or "bullet", pos, dir, dir, CalcPos(pos,dir,4012), 0, 0, 0, 0, false);
												RFVSW_2.RapidFire.Last = _time
											end
										end
									end;
									--end;
									--Debug("WWW")
								end
							end
						end
					end
				end
			end



		local hGun1, hGun2
		for i, v in pairs(HELI_MINIGUNS) do
			if (not v.vehicle:IsDestroyed()) then
				if (v.InFiring and v:GetDriver()) then
					if (_time - (v.LastShot or 0) > 0.08) then

						v.LastShot = _time
						hGun1, hGun2 = v.HeliMiniguns[1], v.HeliMiniguns[2]
						if (hGun1 and hGun2) then
							if (not v.MinigunFireRequested) then
								v.MinigunFireRequested = true
								hGun1.weapon:RequestStartFire()
								hGun2.weapon:RequestStartFire()
							end
							hGun1.weapon:ServerShoot("bullet", hGun1:GetPos(), v:GetDirectionVector(), v:GetDirectionVector(), CalcPos(hGun1:GetPos(), v:GetDirectionVector(), 2024), 0, 0, 0, 0, false);
							hGun2.weapon:ServerShoot("bullet", hGun2:GetPos(), v:GetDirectionVector(), v:GetDirectionVector(), CalcPos(hGun2:GetPos(), v:GetDirectionVector(), 2024), 0, 0, 0, 0, false);
						end
					end
				else
					if (v.MinigunFireRequested) then
						v.MinigunFireRequested = false
						hGun1, hGun2 = v.HeliMiniguns[1], v.HeliMiniguns[2]
						if (hGun1 and hGun2) then
							hGun1.weapon:RequestStopFire()
							hGun2.weapon:RequestStopFire()

						end
					end
					v.InFiring = false;
				end;
			else

				System.RemoveEntity(v.HeliMiniguns[1].id);
				System.RemoveEntity(v.HeliMiniguns[2].id);

				removeHeliMiniguns(v)

				HELI_MINIGUNS[i] = nil;
				v.HeliMiniguns = nil;

				RCA:StopSync(v, v.GunSyncID);
			end;
		end;

		for i, v in pairs(SHOOTING_WEAPONS or {}) do
			v.entity = v.entity or System.GetEntity(i)
			if (v.entity) then
				v.stop = false;
				if (v.needVehicle) then
					local cItem=v.player.inventory:GetCurrentItem();
					if (v.player.actor:GetLinkedVehicleId() ~= v.needVehicle or (not cItem or cItem.id ~= i)) then
						v.stop = true;
					end;
				end;
				if (not v.stop) then
					local dir, pos;
					if (v.player) then
						dir = v.player.actor:GetHeadDir();
						pos = v.player.actor:GetHeadPos();
						if (v.needVehicle) then
							dir = v.player.actor:GetVehicleDir();
						end;
					else
						pos = v.pos or v.entity:GetPos();
						dir = v.dir or v.entity:GetDirectionVector();
					end;
					local fireRate = v.fireRate or (60/(v.entity.weapon.GetFireRate and v.entity.weapon:GetFireRate() or 80))
					if (not v.lastFire or _time - v.lastFire >= fireRate) then
						v.lastFire = _time;
						if (ATOM:NeedsBinding(v.entity.weapon:GetAmmoType(), v.entity, v.player)) then
							System.GetEntity(i).BindToNetwork = true;
						end;
						if (v.ApplySpread) then
							local s = 3.5;
							dir = {
								x = dir.x + math.random(-s, s) / 100,
								y = dir.y + math.random(-s, s) / 100,
								z = dir.z + math.random(-s, s) / 100
							};
						end;
						v.entity.weapon:ServerShoot(v.entity.weapon:GetAmmoType() or "bullet", pos,dir,dir, CalcPos(pos,dir,100), 0, 0, 0, 0, false);
						v.doneShots = (v.doneShots or 0) + 1;
						if (v.shots and v.shots ~= -1) then
							if (v.shots < v.doneShots) then
								SHOOTING_WEAPONS[i] = nil;
							end;
						end;
						if (v.useRayHit) then
							local vRayPos = v.player.actor:GetHeadPos()
							local vRayDir = dir
							vRayPos.x=vRayPos.x+vRayDir.x*3
							vRayPos.y=vRayPos.y+vRayDir.y*3
							vRayPos.z=vRayPos.z+vRayDir.z*3

							local vRay = v.player:GetHitPos(600, ent_all, vRayPos, vRayDir);
							if (vRay and vRay.pos and vRay.entity) then
								if (vRay.entity.item or vRay.entity.actor or vRay.entity.vehicle) then
									v.player.nextHitDamage = (v.entity.weapon:GetDamage() or 25)
									g_gameRules:CreateHit(vRay.entity.id, v.player.id, v.entity.id, (v.entity.weapon:GetDamage() or 25), 1, "mat_default", 0, "normal");
								end
							end
						end
					end;
				else
					SHOOTING_WEAPONS[i] = nil
				end;
			else
				SHOOTING_WEAPONS[i] = nil
			end

			if (not SHOOTING_WEAPONS[i]) then
				ExecuteOnAll([[
					local g=GetEnt(']].. v.entity:GetName() ..[[');
					if (g and g.FIRESOUND) then
						g:StopSound(g.FIRESOUND);
						g.FIRESOUND=nil
					end
				]])
			end
		end

		local bInAngles, hWeapon, vWeapon, aCloseby, hTarget, vTarget, bOk, hAIActor
		local iOperationalDistance = 30
		local iWeaponFov = 30
		for hId, aGun in pairs(AUTOMATIC_GUNS) do
			hWeapon = aGun.hWeapon
			hAIActor = aGun.hAIActor
			bOk = (hAIActor == nil or (System.GetEntity(hAIActor.id) and hAIActor.actor:GetHealth() > 0))
			if (hWeapon and System.GetEntity(hWeapon.id) and System.GetEntity(aGun.hPod.id)) then

				if (bOk) then
					hWeapon.weapon:SetAmmoCount(nil, 10)
					bOk = (hWeapon.weapon:GetAmmoCount() >= 0)

					if (bOk) then
						vWeapon = hWeapon:GetPos()
						aCloseby = DoGetPlayers({ pos = vWeapon, range = 30 })
						hTarget = aGun.hTarget
						if (hTarget) then
							vTarget = hTarget:GetPos()
							if (hTarget:GetHealth() <= 0 or hTarget.actor:GetSpectatorMode() ~= 0 or not self:CanSee(hWeapon, hTarget) or vector.distance(vTarget, vWeapon) > iOperationalDistance or not isPntVisible(aGun.SpawnAngles, vector.getdir(hTarget:GetHeadPos(), vWeapon, true), iWeaponFov)) then
								aGun.hTarget = nil
							else
								local vAng = Dir2Ang(vector.getdir(hTarget:GetPelvisPos(), vWeapon, 1))
								hWeapon:SetAngles(vAng)
								if (not hWeapon.bFiring) then
									hWeapon.bFiring = true
									hWeapon.weapon:RequestStartFire()
									ExecuteOnAll([[
									local hGun = GetEnt(']]..hWeapon:GetName()..[[')
									local hTarget = GP(]]..hTarget:GetChannel()..[[)
									]]..(hAIActor ~= nil and "local hAIActor = GetEnt('"..hAIActor:GetName().."')" or "") .. [[
									if (hGun and hTarget) then
										AUTOMATIC_GUNS[hGun.id]={hAIActor=hAIActor,hWeapon=hGun,hTarget=hTarget}
									end
								]])
									Debug("fire OK")
								end
							end
						end
						if (not aGun.hTarget) then
							if (hWeapon.bFiring) then
								hWeapon.weapon:RequestStopFire()
								hWeapon.bFiring = false
								ExecuteOnAll([[
									local hGun = GetEnt(']]..hWeapon:GetName()..[[')
									local hTarget = GP(]]..hTarget:GetChannel()..[[)
									]]..(hAIActor ~= nil and "local hAIActor = GetEnt('"..hAIActor:GetName().."')" or "") .. [[
									if (hGun and hTarget) then
										AUTOMATIC_GUNS[hGun.id]={hAIActor=hAIActor,hWeapon=hGun,hTarget=nil}
									end
								]])
								Debug("fire STAAAAWP")
							end
							for i, hCloseby in pairs(aCloseby) do
								bInAngles = isPntVisible(aGun.SpawnAngles, vector.getdir(hCloseby:GetHeadPos(), vWeapon, true), iWeaponFov)
								if (bInAngles and self:CanSee(hWeapon, hCloseby)) then
									aGun.hTarget = hCloseby
									break
								end
							end
						end
					end
				else
					ExecuteOnAll([[
					local hGun = GetEnt(']]..hWeapon:GetName()..[[')
					if (hGun) then
						AUTOMATIC_GUNS[hGun.id]=nil
					end
					]])
				end
			else
				AUTOMATIC_GUNS[hId] = nil
			end
		end
	end,
	--------------------
	CanSee = function(self, hA, hB)
		local aTemp = TEMP_RAYWORLD_RESULTS[hA.id]
		if (aTemp) then
			aTemp = aTemp[hB.id]
			if (aTemp) then
				if (not timerexpired(aTemp.Timer, 1)) then
					return aTemp.Result
				end
			end
		end

		local vA = vector.modifyz(hA:GetPos(), 0.5)
		local vB = vector.modifyz(hB:GetPos(), 0.5)

		local bResult = Physics.RayTraceCheck(vA, vB, hA.id, hB.id)

		TEMP_RAYWORLD_RESULTS[hA.id] = checkVar(TEMP_RAYWORLD_RESULTS[hA.id], {})
		TEMP_RAYWORLD_RESULTS[hA.id][hB.id] = {
			Timer = timerinit(),
			Result = bResult
		}

		return bResult
	end,
	--------------------
	lerp = function(self, a, b, t)
		if type(a) == "table" and type(b) == "table" then
			if a.x and a.y and b.x and b.y then
				if a.z and b.z then return self:lerp3(a, b, t) end
				return self:lerp2(a, b, t)
			end
		end
		t = self:clamp(t, 0, 1)
		return a + t*(b-a)
	end,
	--------------------
	_lerp = function(self, a, b, t)
		return a + t*(b-a)
	end,
	--------------------
	lerp2 = function(self, a, b, t)
		t = self:clamp(t, 0, 1)
		return { x = self:_lerp(a.x, b.x, t); y = self:_lerp(a.y, b.y, t); };
	end,
	--------------------
	lerp3 = function(self, a, b, t)
		t = self:clamp(t, 0, 1)
		return { x = self:_lerp(a.x, b.x, t); y = self:_lerp(a.y, b.y, t); z = self:_lerp(a.z, b.z, t); };
	end,
	--------------------
	clamp = function(self, a, b, t)
		if a < b then return b end
		if a > t then return t end
		return a
	end,
	--------------------
	ValidEntityClass = function(self, className)
		return ATOMDLL:IsValidEntityClass(className);
	end;
	--------------------
	IsVehicleClass = function(self, className)
		return className:match("US_.*") or className:match("Asian_.*") or className:match("Civ_.*");
	end;
	--------------------
	GetBuilding = function(self, t, id)
		return self.sorted_buildings[t:lower()][id or 1];
	end;
	--------------------
	GetClosestBuilding = function(self, pos, min, ofType)
		local all = self.buildings;
		local closest = min;
		local theBuild;
		for i, v in pairs(all) do
			if (not ofType or v._buildType == ofType) then
				if (not closest or GetDistance(pos, v) < closest) then
					closest = GetDistance(pos, v);
					theBuild = v;
				end;
			end;
		end;
		return theBuild;
	end,
	--------------------
	CaptureBuilding = function(self, player, building, _arg2, _arg3)
		local theBuild;
		local teamId = _arg2 or player:GetTeam();
		local meanTeam = teamNames[tonumber(building)or -1];
		local bIndex;
		if (not building or meanTeam) then
			if (meanTeam) then
				teamId = tonumber(building);
			end;
			local all = self.buildings;
			local closest;
			for i, v in pairs(all) do
				if (not closest or GetDistance(player, v) < closest) then
					closest = GetDistance(player, v);
					theBuild = v;
				end;
			end;
		elseif (building:lower() == "all") then
		
			for i, f in pairs(self.buildings) do
				if (f._buildType ~= "base" and f._buildType ~= "hq") then
					f:Capture(teamId);
				end;
			end;
			SendMsg(INFO, ALL, "(ALL BUILDINGS CAPTURED FOR TEAM %s (Admin Decision))", teamNames[teamId]);
			SendMsg(CHAT_ATOM, player, "(All Buildings Captured for Team %s)", teamNames[teamId]);
			return true;
		else
			local cat = self.sorted_buildings[building:lower()];
			if (cat) then
				if (arrSize(cat) == 1) then
					theBuild = cat[1];
				else
					teamId = _arg3 or player:GetTeam();
					if (cat[tonumber(_arg2 or -1)]) then
						bIndex = tonumber(_arg2 or -1);
						theBuild = cat[bIndex];
					else
						SendMsg(CHAT_ATOM, player, "Found [ %d ] Buildings of Class %s, please Specify Index", arrSize(cat), makeCapital(building));
						return true;--false, "invalid building index";
					end;
				end;
			else
				return false, "invalid building";
			end;
		end;
		
		if (theBuild) then
			if (theBuild.captured == true and teamId == theBuild:GetTeamId()) then
				theBuild:Uncapture(theBuild:GetTeamId());
				SendMsg(INFO, ALL, "(%s%s: UNCAPTURED FROM TEAM %s (Admin Decision))", makeCapital(theBuild._buildType), (bIndex and "["..bIndex.."]"or""), teamNames[teamId]);
				SendMsg(CHAT_ATOM, player, "(%s%s: Uncaptured from Team %s)", makeCapital(theBuild._buildType), (bIndex and "["..bIndex.."]"or""), teamNames[teamId]);
			else
				theBuild:Capture(teamId);
				SendMsg(INFO, ALL, "(%s%s: CAPTURED FOR TEAM %s (Admin Decision))", makeCapital(theBuild._buildType), (bIndex and "["..bIndex.."]"or""), teamNames[teamId]);
				SendMsg(CHAT_ATOM, player, "(%s%s: Captured for Team %s)", makeCapital(theBuild._buildType), (bIndex and "["..bIndex.."]"or""), teamNames[teamId]);
			end;
		end;
	end,
	--------------------
	GetAdjustedPosition = function(self, pos, vehicleProps, rhignore)
		self.rhignore = rhignore;
		local T = System.GetTerrainElevation(pos);
		if (T > pos.z and T - pos.z < 3) then
			pos.z = T;
		end;
		local RH = self:RayCheck(add2Vec(pos, { x = 0, y = 0, z = 1}), g_Vectors.down, 10) or self:RayCheck(add2Vec(pos, { x = 0, y = 0, z = -2}), g_Vectors.down, 5);
		if (RH) then
			--Debug(">",vehicleProps.Radius[2])
			pos = (vehicleProps and add2Vec(RH.pos, { x = 0, y = 0, z = vehicleProps.Radius[3]}) or RH.pos)
			--dir = RH.normal
			--Debug(dir)
			--Debug("Adjusted")
		else
		--	Debug("No RH")
		end;
		return pos
	end,
	--------------------
	Spawn = function(self, properties, player)
		if (properties) then
			local vehicleProps = self:IsVehicle(properties.Class);
			if (vehicleProps) then
				properties.Class = vehicleProps[1]
			end;
		
			if (not self:ValidEntityClass(properties.Class) and not vehicleProps) then
				return false, "Invalid Class: " .. properties.Class;
			end;
			
			if (player) then player.LastSpawnedClass = properties.Class end
			
			local NameTemplate = properties.Name or "Entity %d";
			local UseCounter = NameTemplate:find("%%d");
			
			local Counter = self:SpawnCounter();
			
			local Name = properties.Class .. " " .. Counter;
			if (UseCounter) then
				Name = formatString(NameTemplate, Counter)
			end;
			
			local props  = properties.Props or {};
			
			local pos = properties.Pos 	or toVec(0, 0, 0);
			local dir = properties.Dir 	or toVec(0, 0, 0);
			
			
			
			if (player and vehicleProps) then
				pos = player:CalcSpawnPos(vehicleProps.Radius[1]);
				props.Modification = vehicleProps.Mod or props.Modification;
			end;

			if (properties.AdjustPos) then
				self:GetAdjustedPosition(pos, vehicleProps);
			end;
				
			if (self:IsGunClass(properties.Class)) then
				props.fMass 	= 10;
				props.bPhysics 	= 1;
				props.Respawn = {
					nTimer		= g_gameRules.WEAPON_ABANDONED_TIME,
					bUnique		= 0,
					bRespawn	= 0,
				};
			end;	
			
			
			local tags = properties.Tags or {};
			
			local count = properties.Count or 1;
			
			local equip = properties.Equipment or {};
			
			local sortSpawn = properties.SortSpawned;
			local SpawnRadius = properties.SpawnRadius;
			--Debug("SpawnRadius",SpawnRadius,GetRandom(-SpawnRadius,SpawnRadius))
			local spawned;
			local newGun;
			
			local sortedPosition = copyTable(pos);
			
			local Q, H, QH, F = false, false, false, false;
			
			local function localSpawn(iSpawnCounter)
				local hSpawned = System.SpawnEntity({ class = properties.Class, name = Name, position = sortedPosition, orientation = dir, properties = props });
				if (hSpawned) then

					hSpawned.SpawnTime = _time
					for tag, tagValue in pairs(tags or{}) do
						hSpawned[tag] = tagValue;
						if (hSpawned.actor) then
							for j, class in pairs(equip or{}) do
								newGun = ATOM:GiveItem(hSpawned, class, 1);
								if (newGun) then
									newGun[1].weapon:AttachAccessory("LAMRifle", true, true);
								else
									SysLog("tried to give invalid item %s to %s", class,hSpawned:GetName());
								end;
							end;
						end;
					end;
					if (hSpawned.weapon) then
						self:AwakeEntity(hSpawned);
						g_game:ScheduleEntityRemoval(hSpawned.id, hSpawned.Properties.Respawn.nTimer, false);
					end;
					if (properties.RandomCharacter) then
						Script.SetTimer(iSpawnCounter*25, function()
							RCA:RequestModelOnNPC(hSpawned, GetRandom(1, 26))
						end)

						hSpawned:SetDirectionVector(pos,hSpawned:GetPos())
					end
				else
					--return false, "failed to spawn class: " .. properties.Class;
				end;
				if (sortSpawn) then
					sortedPosition.x = sortedPosition.x + 1;
				end;
				if (vehicleProps) then
					sortedPosition.z = sortedPosition.z + vehicleProps.Radius[2] * 3;
					--Debug(" + ", vehicleProps.Radius[2])
				end;
				if (SpawnRadius and SpawnRadius > 1) then
					--Debug(add2Vec(sortedPosition, makeVec(GetRandom(-SpawnRadius,SpawnRadius), GetRandom(-SpawnRadius,SpawnRadius))))
					sortedPosition = copyTable(pos);
					sortedPosition = add2Vec(sortedPosition, makeVec(GetRandom(-SpawnRadius,SpawnRadius), GetRandom(-SpawnRadius,SpawnRadius)))
					if (sortedPosition.z < System.GetTerrainElevation(sortedPosition)) then
						sortedPosition.z = System.GetTerrainElevation(sortedPosition);
					end;
				end;
				return hSpawned
			end
			
			for i = 1, count do
				if (UseCounter) then
					Name = formatString(NameTemplate, Counter)
				end;
				if (self:IsVehicleClass(properties.Class)) then
					Script.SetTimer(1, function()
						spawned = localSpawn(i);
					end);
				else
					spawned = localSpawn(i);
				end;
				Counter = self:SpawnCounter();
			end;
			ATOMLog:LogGameUtils('Entities', "Spawned $4%d$9 Entities of Class %s", count, properties.Class);
			return spawned;
		else
			return false, "No Properties Specified";
		end;
	end;
	--------------------
	LoadVehicleModel = function(self, vehicle, model, lPos, lDir, lScale, remTires)
		if (vehicle and model) then
			
			--[[
			local SlotCounter = self:SpawnCounter() + 100;
			vehicle:LoadObject(0, "objects/weapons/us/frag_grenade/frag_grenade_tp.cgf");
			vehicle:DrawSlot(0, 0);
			if (vehicle.HasCustomModel) then
				vehicle:FreeSlot(vehicle.CustomModelSlot);
			end;
			vehicle:LoadObject(SlotCounter, model);
			--vehicle:SetSlotPos(SlotCounter, { x = 0, y = 0, z = 0 }); -- Reset
			--vehicle:SetSlotAngles(SlotCounter, { x = 0, y = 0, z = 0 }); -- Reset
			local tDir; --= vehicle:GetDirectionVector();
			if (lPos or lDir) then
				--vehicle:SetSlotPos(SlotCounter, lPos);
				if (lDir) then
					tDir = vehicle:GetDirectionVector();
					for i = 1, lDir do
					--	SysLog("Rotating: %d, %s", i, Vec2Str(tDir))
						VecRotateMinus90_Z(tDir);
					end;
				end;
				vehicle:SetSlotWorldTM(SlotCounter, vehicle.vehicle:MultiplyWithWorldTM(lPos or vehicle:GetPos()),tDir or  vehicle:GetDirectionVector()); --tDir or 
				--vehicle:SetSlotAngles(SlotCounter, tDir or vehicle:GetDirectionVector());
			end;
			--if (lDir) then
				--vehicle:SetSlotAngles(SlotCounter, lDir);
			--end;
			if (lScale) then
				vehicle:SetLocalScale(SlotCounter, lScale);
			end;
			vehicle:PhysicalizeSlot(SlotCounter, { flags = 1.8537e+008 });
			vehicle.CustomModelSlot = SlotCounter;
			vehicle.HasCustomModel = true;
			--]]
			
			if (vehicle.custommodel) then
				System.RemoveEntity(vehicle.custommodel)
			end;
			local NewModel = System.SpawnEntity({ class = "BasicEntity", position = vehicle:GetPos(), orientation = vehicle:GetDirectionVector(), name = vehicle:GetName() .. "_cm", properties = { object_Model = model }})
			NewModel:LoadObject(0, model);
			NewModel:PhysicalizeSlot(0, { flags = 1.8537e+008 })
			
			vehicle:DrawSlot(0, 0)
			vehicle:AttachChild(NewModel.id, PHYSICPARAM_SIMULATION);
			vehicle.custommodel = NewModel.id;
			
			if (lPos) then
				NewModel:SetLocalPos(lPos);
			end;
			if (lDir) then
				NewModel:SetLocalAngles(lDir);
			end;
			
			if (remTires) then
				for i = 1, 4 do
					vehicle:DrawSlot(i, 0);
				end;
			end;
			
			local code = "ATOMClient:HandleEvent(eCE_VehModel, \"" .. vehicle:GetName() .. "\", \"" .. model .. "\", " .. (lPos and arr2str_(lPos) or "nil") .. ", " .. (lDir and arr2str_(lDir) or "nil") .. ", " .. (lScale and lScale or "nil") .. ", " .. (remTires and "true" or "false") .. ")";
			vehicle.modelSyncId = RCA:SetSync(vehicle, { link = vehicle.id, client = code }, true);
			ExecuteOnAll(code);
			return true;
		end;
		return false;
	end,
	--------------------
	RayCheck = function(self, pos, dir, dist, entId)
		local dist = dist or 1000;
		if (pos and dir and dist) then
		
			local hits = Physics.RayWorldIntersection(pos, vecScale(dir, dist), dist, ent_all, self.rhignore or entId, nil, g_HitTable);
			self.rhignore = nil;
			local hit = g_HitTable[1];
			if (hits and hits > 0) then
				hit.surfaceName = System.GetSurfaceTypeNameById( hit.surface )
				return hit;
			end;
		
		end;
		return;
	end,
	--------------------
	IsVehicle = function(self, vehicleClass)
		return self.cfg.Vehicles[vehicleClass:lower()];
	end;
	--------------------
	DeleteClass = function(self, deleter, className)
		if ((not className or className == "") and deleter.LastSpawnedClass) then
			Debug(">> LAST SPAWNED CLAS >> ",deleter.LastSpawnedClass)
			className = deleter.LastSpawnedClass
		end
		if (not self:ValidEntityClass(className)) then
			return false, "Invalid Class: " .. className;
		end;
		local entities = System.GetEntitiesByClass(className);
		if (entities and arrSize(entities) > 0) then
			for i, entity in pairs(entities) do
				if (entity.class == "Player" and entity.isPlayer) then
					table.remove(entities, i);
				else
					System.RemoveEntity(entity.id);
				end;
			end;
			if (arrSize(entities) == 0) then
				return false, "No Deleteable Entities found";
			end;
			if (deleter) then
				SendMsg(CHAT_ATOM, deleter, "Deleted [ %d ] Entities of Class %s", arrSize(entities), className)
				ATOMLog:LogGameUtils('Entities', "%s$9 Removed $4%d $9Entities of class %s$9", deleter:GetName(), arrSize(entities), className);
			else
				ATOMLog:LogGameUtils('Entities', "Removed $4%d $9Entities of class %s$9", arrSize(entities), className);
			end;
		else
			return false, "No Entities Found";
		end;
	end;
	--------------------
	SetDoors = function(self, mode)
		for i, door in pairs(System.GetEntitiesByClass("Door")or{}) do
			door:Open(mode);
		end;
	end;
	--------------------
	SpawnCounter = function(self)
		SPAWN_COUNTER = (SPAWN_COUNTER or 0) + 1;
		return SPAWN_COUNTER;
	end;
	--------------------
	VisibilityCheck = function(self, a, b, aId, bId)
		local pos1, pos2 = makeVec(a), makeVec(b);
		local aId, bId = aId or NULL_ENTITY, bId or NULL_ENTITY;

		pos1.z = pos1.z + 0.1;
		pos2.z = pos2.z + 0.1;

		return Physics.RayTraceCheck(pos1, pos2, aId, bId);
	end;
	--------------------
	ChangeGunTurretGuns = function(self, player, teamId, log, gun)
	
		local theGun, realName = GunSystem:GetGun(gun);
		if (not theGun) then
			ListToConsole(player, GunSystem.GunsList, "Available Guns", false, nil, 3);
			SendMsg(CHAT_ATOM, player, "Open Console to view the List of [ %d ] available Guns!", GunSystem:GetGunCount());
			return true;
		end;
	
		CGUN_TURRET_STATUS = CGUN_TURRET_STATUS or {
			[0] = false,
			[1] = false,
			[2] = false
		};
		
		local fromTeam = ((not teamId or teamId == "all" or tonumber(teamId) == 0) and 0 or ((tonumber(teamId) == 1 or teamId:lower() == "nk") and 1 or ((tonumber(teamId) == 2 or teamId:lower() == "us") and 2)));
		
		if (not fromTeam) then
			return false, "invalid team";
		end;
		
		local turr1, turr2 = System.GetEntitiesByClass("AutoTurretAA"), System.GetEntitiesByClass("AutoTurret");
		
		if (not (turr1 and turr2) or #turr1 + #turr2 < 1) then
			return false, "No Turrets Found";
		end;
		
		CGUN_TURRET_STATUS[fromTeam] = not CGUN_TURRET_STATUS[fromTeam];
		local mode = CGUN_TURRET_STATUS[fromTeam];
		
		if (fromTeam == 0) then
			CGUN_TURRET_STATUS[1] = mode;
			CGUN_TURRET_STATUS[2] = mode;
		end;
		
		local d = 0;
		
		for i, turret in pairs(turr1) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.gunName = theGun;
				turret.Properties.GunTurret.bLuaFire = mode;
				turret.Properties.GunTurret.bLuaFireOnly = mode;
			end;
		end;
		
		for i, turret in pairs(System.GetEntitiesByClass("AutoTurret")) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.gunName = theGun;
				turret.Properties.GunTurret.bLuaFire = mode;
				turret.Properties.GunTurret.bLuaFireOnly = mode;
			end;
		end;
		
		if (d == 0) then
			return false, "No turrets to found";
		end;
		
		if (log) then
			ATOMLog:LogGameUtils('Admin', "%s gun mode on %d Turrets from %s", (mode and "Enabled" or "Disabled"), d, (fromTeam==0 and "all teams" or fromTeam==1 and "NK Team" or "US Team"));
		end;
		
		SendMsg(CHAT_ATOM, player, "(GUN-TURRETS: " .. (mode and "Activated" or "Disabled") .. " " .. (fromTeam==0 and "ALL" or fromTeam==1 and "NK" or "US") .. " Turrets)");
		
	end;
	--------------------
	SetBadAssTurrets = function(self, player, teamId, log)
	
		BADASS_TURRET_STATUS = BADASS_TURRET_STATUS or {
			[0] = false,
			[1] = false,
			[2] = false
		};
		
		local fromTeam = ((not teamId or teamId == "all" or tonumber(teamId) == 0) and 0 or ((tonumber(teamId) == 1 or teamId:lower() == "nk") and 1 or ((tonumber(teamId) == 2 or teamId:lower() == "us") and 2)));
		
		if (not fromTeam) then
			return false, "invalid team";
		end;
		
		local turr1, turr2 = System.GetEntitiesByClass("AutoTurretAA"), System.GetEntitiesByClass("AutoTurret");
		
		if (not (turr1 and turr2) or #turr1 + #turr2 < 1) then
			return false, "No Turrets Found";
		end;
		
		BADASS_TURRET_STATUS[fromTeam] = not BADASS_TURRET_STATUS[fromTeam];
		local mode = BADASS_TURRET_STATUS[fromTeam];
		
		if (fromTeam == 0) then
			BADASS_TURRET_STATUS[1] = mode;
			BADASS_TURRET_STATUS[2] = mode;
		end;
		
		local d = 0;
		
		for i, turret in pairs(turr1) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.Properties.GunTurret.bBadAss = mode;
			end;
		end;
		
		for i, turret in pairs(System.GetEntitiesByClass("AutoTurret")) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.Properties.GunTurret.bBadAss = mode;
			end;
		end;
		
		if (d == 0) then
			return false, "No turrets to found";
		end;
		
		if (log) then
			ATOMLog:LogGameUtils('Admin', "%s Badass mode on %d Turrets from %s", (mode and "Enabled" or "Disabled"), d, (fromTeam==0 and "all teams" or fromTeam==1 and "NK Team" or "US Team"));
		end;
		
		SendMsg(CHAT_ATOM, player, "(BADASS-TURRETS: " .. (mode and "Activated" or "Disabled") .. " " .. (fromTeam==0 and "ALL" or fromTeam==1 and "NK" or "US") .. " Turrets)");
		
	end;
	--------------------
	SetTurrets = function(self, player, teamId, log)
	
		TURRET_STATUS = TURRET_STATUS or {
			[0] = true,
			[1] = true,
			[2] = true
		};
		
		local fromTeam = ((not teamId or teamId == "all" or tonumber(teamId) == 0) and 0 or ((tonumber(teamId) == 1 or teamId:lower() == "nk") and 1 or ((tonumber(teamId) == 2 or teamId:lower() == "us") and 2)));
		
		if (not fromTeam) then
			return false, "invalid team";
		end;
		
		local turr1, turr2 = System.GetEntitiesByClass("AutoTurretAA"), System.GetEntitiesByClass("AutoTurret");
		
		if (not (turr1 and turr2) or #turr1 + #turr2 < 1) then
			return false, "No Turrets Found";
		end;
		
		TURRET_STATUS[fromTeam] = not TURRET_STATUS[fromTeam];
		local mode = TURRET_STATUS[fromTeam];
		
		if (fromTeam == 0) then
			TURRET_STATUS[1] = mode;
			TURRET_STATUS[2] = mode;
		end;
		
		local d = 0;
		
		for i, turret in pairs(turr1) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.Properties.GunTurret.bEnabled = mode;
			end;
		end;
		
		for i, turret in pairs(System.GetEntitiesByClass("AutoTurret")) do
			if (fromTeam == 0 or g_game:GetTeam(turret.id) == fromTeam) then
				d = d + 1;
				turret.Properties.GunTurret.bEnabled = mode;
			end;
		end;
		
		if (d == 0) then
			return false, "No turrets to disable found";
		end;
		
		if (log) then
			ATOMLog:LogGameUtils('Admin', "%d Turrets from %s have been %s", d, (fromTeam==0 and "all teams" or fromTeam==1 and "NK Team" or "US Team"), (mode and "enabled" or "disabled"));
		end;
		
		SendMsg(CHAT_ATOM, player, "(TURRETS: " .. (mode and "Activated" or "Disabled") .. " " .. (fromTeam==0 and "ALL" or fromTeam==1 and "NK" or "US") .. " Turrets)");
		
	end;
	--------------------
	GotoPlayer = function(self, player, target, vehicleSeat)
		local targetVehicle = target:GetVehicle();
		local freeSeat = -1;
		if (targetVehicle) then
			freeSeat = GetNextAvailableSeat(targetVehicle.Seats);
		end;
		
		local targetPosition = target:CalcSpawnPos(-3);
		if (not self:VisibilityCheck(targetPosition, target, player.id, target.id)) then
			targetPosition = target:CalcSpawnPos(3);
		end;
		
		targetPosition.z = targetPosition.z - 1.5;
		
		if (GetDistance(player, targetPosition) < 3) then
			return false, "you are already at " .. target:GetName();
		end;
		
		local enter = false;
		local vehicle, seatId;
		
		if (player:GetVehicle() and targetVehicle and targetVehicle.id ~= player:GetVehicle().id) then
			self:Boot(player, player:GetVehicle());
		elseif (player:GetVehicle()) then
			enter = true;
			vehicle, seatId = player:GetVehicle(), player:GetSeatId();
			self:Boot(player, player:GetVehicle());
		end;
		
		
		if (player:IsSpectating()) then
			player.actor:SetSpectatorMode(0, NULL_ENTITY);
		end;

		if (player:IsDead()) then
			if (targetVehicle and vehicleSeat and freeSeat ~= -1) then
				g_game:RevivePlayerInVehicle(player.id, targetVehicle.id, freeSeat, g_game:GetTeam(target.id), false);
			else
				g_game:RevivePlayer			(player.id, targetPosition, GetAngles(targetPosition, target), g_game:GetTeam(player.id), false);	
			end;
			g_gameRules:EquipPlayer(player);
		else
			if (targetVehicle and vehicleSeat and freeSeat ~= -1) then
				self:MountVehicle(player, targetVehicle, freeSeat);
			else
				g_game:MovePlayer(player.id, targetPosition, GetAngles(targetPosition, target));
			end;
		end;
		
		if (g_gameRules.class == "PowerStruggle") then
			g_gameRules:ResetRevive(player.id, true);
		end;
		
		SendMsg(CHAT_ATOM, player, "(YOU: Teleported to " .. target:GetName() .. ")");
		SendMsg(CHAT_ATOM, target, "(" .. target:GetName() .. ": Teleported to your Location)");
		
		if (enter) then
			Debug("!")
			Script.SetTimer(1, function()
				vehicle:SetWorldPos(targetPosition);
				Script.SetTimer(100, function()
					self:AwakeEntity(vehicle);
					self:MountVehicle(player, vehicle, seatId);
					Debug(vehicle:GetName())
					Debug(seatId)
				end);
			end);
		end;
		
		self:SpawnEffect(ePE_Light, targetPosition);
		
		return true;
	end;
	--------------------
	AwakeEntity = function(self, entity)
		entity:AwakePhysics(1);
		entity:AddImpulse(-1, entity:GetCenterOfMassPos(), g_Vectors.up, 1, 1);
	end;
	--------------------
	BringPlayer = function(self, player, target, vehicleSeat)
	
		local playerVehicle = player:GetVehicle();
		local freeSeat = -1;
		if (playerVehicle) then
			freeSeat = GetNextAvailableSeat(playerVehicle.Seats);
		end;
		
		local playerPosition = player:CalcSpawnPos(2);
		if (target ~= "all" and target ~= "myteam" and not self:VisibilityCheck(playerPosition, target, player.id, target.id)) then
			playerPosition = player:CalcSpawnPos(-2);
		end;
		
		playerPosition.z = playerPosition.z - 1.5;
		
		if (target == "myteam") then
			local all = System.GetEntitiesByClass("Player");
			for i, v in pairs(all) do
				if (v.id ~= player.id and g_game:GetTeam(v.id) == g_game:GetTeam(player.id)) then
					g_game:MovePlayer(v.id, playerPosition, GetAngles(playerPosition, player));
					SendMsg(CHAT_ATOM, v, "(" .. player:GetName() .. ": Brought you to their Location)");
				end;
			end;
		elseif (target == "entities" or target == "class") then
			--Debug(">",vehicleSeat)
			if (not vehicleSeat or not self:ValidEntityClass(vehicleSeat)) then
				return false, "Invalid entity";
			end;
			if (vehicleSeat == "Player") then
				return false, "Use !bring <all> to bring players to your location";
			end;
			local allEntities = System.GetEntitiesByClass(vehicleSeat);
			if (arrSize(allEntities) < 1) then
				return false, "No entities found";
			end;
			for i, entity in pairs(allEntities or{}) do
				--if (entity.id ~= player.id) then
				--	freeSeat = GetNextAvailableSeat(playerVehicle.Seats);
				--	if (tplayer:IsDead()) then
				--		if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
				--			g_game:RevivePlayerInVehicle(tplayer.id, playerVehicle.id, freeSeat, g_game:GetTeam(tplayer.id), false);
				--		else
				--			g_game:RevivePlayer			(tplayer.id, playerPosition, GetAngles(playerPosition, player), g_game:GetTeam(tplayer.id), false);	
				--		end;
				--	else
				--		if (playerVehicle and tplayer:GetVehicle() and tplayer:GetVehicle().id ~= playerVehicle.id) then
				--			self:Boot(tplayer, tplayer:GetVehicle());
				--		end;
				--		if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
				--			self:MountVehicle(tplayer, playerVehicle, freeSeat);
				--		else
				--			g_game:MovePlayer(tplayer.id, playerPosition, GetAngles(playerPosition, player));
				--		end;
				--	end;
				--	SendMsg(CHAT_ATOM, tplayer, "(" .. player:GetName() .. ": Brought you to their Location)");
				--end;
				entity:SetWorldPos(playerPosition);
				--entity:AwakePhysics(1);
				self:AwakeEntity(entity);
				playerPosition.z = playerPosition.z + 1;
			end;
			return true, SendMsg(CHAT_ATOM, player, formatString("(YOU: Brought [ %d ] Entities of Class '%s' to your Location", arrSize(allEntities), vehicleSeat));
		elseif (target == "all") then
			local allPlayers = GetPlayers();
			if (arrSize(allPlayers) < 2) then
				return false, "You are alone in the Server";
			end;
			for i, tplayer in pairs(allPlayers or{}) do
				if (tplayer.id ~= player.id) then
					if (playerVehicle) then
						freeSeat = GetNextAvailableSeat(playerVehicle.Seats);
					end;
					if (tplayer:IsSpectating()) then
						tplayer.actor:SetSpectatorMode(0, NULL_ENTITY);
					end;
					if (tplayer:IsDead()) then
						if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
							g_game:RevivePlayerInVehicle(tplayer.id, playerVehicle.id, freeSeat, g_game:GetTeam(tplayer.id), false);
						else
							g_game:RevivePlayer			(tplayer.id, playerPosition, GetAngles(playerPosition, player), g_game:GetTeam(tplayer.id), false);	
						end;
						g_gameRules:EquipPlayer(tplayer);
					else
						if (playerVehicle and tplayer:GetVehicle() and tplayer:GetVehicle().id ~= playerVehicle.id) then
							self:Boot(tplayer, tplayer:GetVehicle());
						end;
						if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
							self:MountVehicle(tplayer, playerVehicle, freeSeat);
						else
							
							g_game:MovePlayer(tplayer.id, playerPosition, GetAngles(playerPosition, player));
						end;
					end;
					if (g_gameRules.class == "PowerStruggle") then
						g_gameRules:ResetRevive(tplayer.id, true);
					end;
					SendMsg(CHAT_ATOM, tplayer, "(" .. player:GetName() .. ": Brought you to their Location)");
				end;
			end;
			self:SpawnEffect(ePE_Light, playerPosition);
			SendMsg(CHAT_ATOM, player, "(YOU: Brought The Server to your Location)");
			return true;
		end;
		
		if (target and GetDistance(target, playerPosition) < 2) then
			return false, "player already at your position";
		end;
		
		if (target:GetVehicle() and playerVehicle and playerVehicle.id ~= target:GetVehicle().id) then
			self:Boot(target, target:GetVehicle());
		end;


		if (target:IsSpectating()) then
			target.actor:SetSpectatorMode(0, NULL_ENTITY);
		end;

		if (target:IsDead()) then
			if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
				g_game:RevivePlayerInVehicle(target.id, playerVehicle.id, freeSeat, g_game:GetTeam(target.id), false);
			else
				g_game:RevivePlayer			(target.id, playerPosition, GetAngles(playerPosition, player), g_game:GetTeam(target.id), false);	
			end;
			g_gameRules:EquipPlayer(target);
			
		else
			if (playerVehicle and vehicleSeat and freeSeat ~= -1) then
				self:MountVehicle(target, playerVehicle, freeSeat);
			else
				g_game:MovePlayer(target.id, playerPosition, GetAngles(playerPosition, player));
			end;
		end;
		
		SendMsg(CHAT_ATOM, player, "(YOU: Brought " .. target:GetName() .. " to your Location)");
		SendMsg(CHAT_ATOM, target, "(" .. player:GetName() .. ": Brought you to their Location)");
		
		self:SpawnEffect(ePE_Light, playerPosition);
		
		if (g_gameRules.class == "PowerStruggle") then
			g_gameRules:ResetRevive(target.id, true);
		end;
		
		return true;
	end;
	--------------------
	PlayerStuck = function(self, player)
		if (player:IsAFK()) then
			return false, "leave AFK mode";
		end;
		if (not player:IsAlone(10, true)) then
			return false, "found at least 1 enemy player nearby";
		end;
		local allSpawns = System.GetEntitiesByClass("SpawnPoint");
		if (g_gameRules.class == "InstantAction") then
			local closest = 999;
			local spawnInfo = {};
			for i, entity in pairs(allSpawns) do
				if (GetDistance(entity, player) < closest) then
					closest = GetDistance(entity, player);
					spawnInfo[1] = entity:GetWorldPos();
					spawnInfo[2] = entity:GetWorldAngles();
					spawnInfo[3] = entity;
				end;
			end;
			if (spawnInfo[1]) then
				g_game:RevivePlayer(player.id, spawnInfo[1], spawnInfo[2], g_game:GetTeam(player.id), false);
				spawnInfo[3]:Spawned(player);
			else
				return false, "No SpawnPoint in Range found";
			end;
			SendMsg(CENTER, player, "You are no longer Stuck have been Respawned");
			return true;
		else
			local closestBunker, dist;
			for i, v in pairs(System.GetEntities() or System.GetEntitiesByClass("SpawnGroup") or {}) do
				if (g_game:IsSpawnGroup(v.id) and g_game:GetTeam(v.id) == g_game:GetTeam(player.id) and (not dist or GetDistance(v, player) < dist)) then
					closestBunker = v;
					dist = GetDistance(v, player);
					Debug(dist, v.class)
				end;
			end;
			if (not closestBunker) then
				return false, "no spawn point of this team found in range";
			end;
			
			self:RevivePlayer(player, player, true, closestBunker.id);
			SendMsg(CENTER, player, "You are no longer Stuck have been Respawned");
			
			return true;
		end;
	end;
	--------------------
	MountVehicle = function(self, player, vehicle, seat)

		player.hSvEnterVehicleTimer = timerinit()

		return vehicle.vehicle:EnterVehicle(player.id, seat, false);
	end;
	--------------------
	Boot = function(self, player, vehicle, seat)
		return vehicle.vehicle:ExitVehicle(player.id, false);
	end;
	--------------------
	IsValidGun = function(self, gun, forbidden, returnCorrect)
		local handGuns = self:GetGuns(2);
		local gunResult = handGuns[gun];
		if (not gunResult) then
			for i, gunName in pairs(handGuns) do
				--Debug(gunName)
				if (gunName:lower() == gun:lower()) then
					gunResult = gunName;
					break;
				else
					if (gunName:lower():find(gun:lower())) then
						if (gunResult) then
							return false, "Invalid Gun";
						end;
						gunResult = gunName;
					end;
				end;
			end;
		end;
		if (forbidden and forbidden[gunResult]) then
			gunResult = nil;
		end;
		return gunResult;
	end,
	--------------------
	EquipPlayer = function(self, player, target, gun, amt, ...)
		if (not gun) then
			return false, "specify gun"
		end;
		local handGuns = self:GetGuns(2);
		local gunResult = handGuns[gun];
		if (not gunResult) then
			for i, gunName in pairs(handGuns) do
				--Debug(gunName)
				if (gunName:lower() == gun:lower()) then
					gunResult = gunName;
					break;
				else
					if (gunName:lower():find(gun:lower())) then
						if (gunResult) then
							return false, "Invalid Gun";
						end;
						gunResult = gunName;
					end;
				end;
			end;
		end;
		if (not gunResult) then
			return false, "Invalid Gun";
		end;
		if (not self:ValidEntityClass(gunResult)) then
			return false, "Invalid Class";
		end;
		local isnum = tonum(amt)~=0;
		local attachments = {...}or{};
		if (not isnum) then
			table.insert(attachments, amt);
		end;
		local newGuns;
		if (not target or target == player or (target == "all" and arrSize(GetPlayers())==1)) then
			local OldMode = 
			player.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, true);
			player.noWeaponLimit = true;
			newGuns = ATOM:GiveItem(player, gunResult, (isnum and tonum(amt) or 1), true);
			if (arrSize(attachments) > 0) then
				ATOMEquip:AttachOnWeapon(player, newGuns[1], attachments);
			end;
			SendMsg(CHAT_EQUIP, player, "(YOU: Gave yourself " .. ((isnum and tonum(amt).."x" or "a")) .. " " .. gunResult .. (arrSize(attachments) > 0 and " [ " .. table.concat(attachments, " + ") .. " ]" or "") .. ")");
			player.noWeaponLimit = false;
			player.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, player.megaGod == true);
		elseif (target == "all") then
			local given = 0;
			for i, tplayer in pairs(GetPlayers()or{}) do
				if (not tplayer:IsSpectating() and not tplayer:IsDead()) then
					tplayer.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, true);
					tplayer.noWeaponLimit = true;
					newGuns = ATOM:GiveItem(tplayer, gunResult, (isnum and tonum(amt) or 1), true);
					if (arrSize(attachments) > 0) then
						ATOMEquip:AttachOnWeapon(tplayer, newGuns[1], attachments);
					end;
					if (tplayer.id ~= player.id) then
						SendMsg(CHAT_EQUIP, tplayer, "(" .. player:GetName() .. ": Gave you " .. ((isnum and tonum(amt).."x" or "a")) .. " " .. gunResult .. (arrSize(attachments) > 0 and " [ " .. table.concat(attachments, " + ") .. " ]" or "") .. ")");
					end;
					given = given + 1;
					tplayer.noWeaponLimit = false;
					tplayer.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, tplayer.megaGod == true);
				end;
			end;
			if (given == 0) then
				return false, "No players to give equipment found";
			end;
			SendMsg(CHAT_EQUIP, player, "(YOU: Gave [ " .. given .. " ] Players " .. gunResult .. (arrSize(attachments) > 0 and " [ " .. table.concat(attachments, " + ") .. " ]" or "") .. ")");
		else
			target.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, true);
			target.noWeaponLimit = true;
			newGuns = ATOM:GiveItem(target, gunResult, (isnum and tonum(amt) or 1), true);
			if (arrSize(attachments) > 0) then
				ATOMEquip:AttachOnWeapon(target, newGuns[1], attachments);
			end;
			SendMsg(CHAT_EQUIP, target, "(" .. player:GetName() .. ": Gave you " .. ((isnum and tonum(amt).."x" or "a")) .. " " .. gunResult .. (arrSize(attachments) > 0 and " [ " .. table.concat(attachments, " + ") .. " ]" or "") .. ")");
			SendMsg(CHAT_EQUIP, player, "(YOU: Gave " .. target:GetName() .. " " .. ((isnum and tonum(amt).."x" or "a")) .. " " .. gunResult .. (arrSize(attachments) > 0 and " [ " .. table.concat(attachments, " + ") .. " ]" or "") .. ")");
			target.noWeaponLimit = true;
			target.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, target.megaGod == true);
		end;
		return true;
	end;
	--------------------
	IsGunClass = function(self, className)
		for i, gun in pairs(self:GetGuns()) do
			if (gun == className) then
				return true;
			end;
		end;
		return false;
	end;
	--------------------
	GetItemPrice = function(self, itemName)
		local items = g_gameRules.buyList;
		for i, item in pairs(items) do
			if (item.id == itemName or item.class == itemName) then
				return item.price;
			end;
		end;
	end,
	--------------------
	GetGuns = function(self, t)
		local all = {
			[1] = {
				[01] = "AvengerCannon",
				[02] = "AACannon",
				[03] = "AARocketLauncher",
				[04] = "APCCannon",
				[05] = "APCCannon_AscMod",
				[06] = "APCRocketLauncher",
				[07] = "Asian50Cal",
				[08] = "AsianCoaxialGun",
				[09] = "USCoaxialGun_VTOL",
				[10] = "AutoAA",
				[11] = "BunkerBuster",
				[12] = "Exocet",
				[13] = "GaussAAA",
				[14] = "GaussCannon",
				[15] = "Hellfire",
				[16] = "HovercraftGun",
				[17] = "SideWinder",
				[18] = "SideWinder_AscMod",
				[19] = "TACCannon",
				[20] = "TankCannon",
				[21] = "USCoaxialGun",
				[22] = "USTankCannon",
				[23] = "VehicleGaussMounted",
				[24] = "VehicleMOAC",
				[25] = "VehicleMOACMounted",
				[26] = "VehicleMOAR",
				[27] = "VehicleMOARMounted",
				[28] = "VehicleRocketLauncher",
				[29] = "VehicleShiTenV2",
				[30] = "VehicleSingularity",
				[31] = "VehicleUSMachinegun"
			};
			[2] = {
				[01] = "OffHand",
				[02] = "explosivegrenade",
				[03] = "empgrenade",
				[04] = "smokegrenade",
				[05] = "flashbang",
				[06] = "AIFlashbangs",
				[07] = "AIGrenades",
				[08] = "AISmokeGrenades",
				[09] = "AlienMount",
				[10] = "AutoTurret",
				[11] = "AutoTurretAA",
				[12] = "AVMine",
				[13] = "Binoculars",
				[14] = "C4",
				[15] = "Claymore",
				[16] = "DebugGun",
				[17] = "Detonator",
				[18] = "DSG1",
				[19] = "Fists",
				[20] = "FY71",
				[21] = "GaussRifle",
				[22] = "Golfclub",
				[23] = "Hurricane",
				[24] = "LAW",
				[25] = "MissilePlatform",
				[26] = "RefWeapon",
				[27] = "SCAR",
				[28] = "SCARTutorial",
				[29] = "ShiTen",
				[30] = "Shotgun",
				[31] = "SMG",
				[32] = "SOCOM",
				[33] = "TACGun",
				[34] = "TACGun_Fleet",
				[35] = "RepairKit",
				[36] = "LockpickKit",
				[37] = "RadarKit",
				[38] = "Reflex",
				[39] = "SniperScope",
				[40] = "AssaultScope",
				[41] = "FragGrenade",
				[42] = "MOAR",
				[43] = "MOAC",
				[44] = "MOACAttach",
				[45] = "AlienTurret",
				[46] = "FastLightMOAC",
				[47] = "FastLightMOAR",
				[48] = "LightMOAC",
				[49] = "HunterSweepMOAR",
				[50] = "ScoutSingularity",
				[51] = "SingularityCannon",
				[52] = "SingularityCannonWarrior",
				[53] = "WarriorMOARTurret"
			};
		};
		return (t and all[t] or nil) or mergeTables(all[1], all[2]);
	end;
	--------------------
	GetColors = function(self)
		local COLORS = {
			[01] = { "$1", "White" };
			[02] = { "$2", "Dark Blue" };
			[03] = { "$3", "Green" };
			[04] = { "$4", "Red" };
			[05] = { "$5", "Light Blue" };
			[06] = { "$6", "Yellow" };
			[07] = { "$7", "Purple" };
			[08] = { "$8", "Orange" };
			[09] = { "$9", "Grey" };
			[10] = { "$0", "Black" };
		};
		return COLORS;
	end;
	--------------------
	CreateImpulseExplosion = function(self, position, radius, scaleDir, timer)
		local function doExplosion()
			local radius = radius or 50;
			local position = position or makeVec();
			local scaleDir = scaleDir or 0;
		
			for i, entity in pairs(System.GetPhysicalEntitiesInBox(position, radius) or {}) do
				local dir = GetDir(position, entity, scaleDir, 1);
				local strength = entity:GetMass() * 25;
				entity:AddImpulse(-1, entity:GetCenterOfMassPos(), dir, strength, 1);
			end;
		end;
		if (timer) then
			Script.SetTimer(timer, doExplosion);
		else
			doExplosion();
		end;
	
	end,
	--------------------
	SwitchTeam = function(self, playerId, teamId)
		g_game:SetTeam(teamId, playerId);
		g_gameRules.Server.RequestSpawnGroup(g_gameRules, playerId, g_game:GetTeamDefaultSpawnGroup(teamId) or NULL_ENTITY, true);
	end;
	--------------------
	ChangeTeam = function(self, player, target, teamId)
		local equip = false;
		
		local teams = {
			[0] = "Neutral",
			[1] = "NK",
			[2] = "US"
		};
		
		local newTeam = ((not teamId or teamId == "neutral" or tonumber(teamId) == 0) and 0 or ((tonumber(teamId) == 1 or teamId:lower() == "nk") and 1 or ((tonumber(teamId) == 2 or teamId:lower() == "us") and 2)));
		
		if (not newTeam or not teams[newTeam]) then
			return false, "Invalid team";
		end;
		
		if (not target or target == player) then
			if (player:GetTeam() == newTeam) then
				return false, "you are already in team " .. teams[newTeam];
			end;
			
			self:SwitchTeam(player.id, newTeam);
			SendMsg(CHAT_ATOM, player, "(TEAM: Changed to " .. teams[newTeam] .. ")");
			
		elseif (target == "all") then
			local switched = 0;
			for i, tplayer in pairs(GetPlayers()or{}) do
				if (tplayer:GetTeam() ~= newTeam) then
					self:SwitchTeam(tplayer.id, newTeam);
					SendMsg(CHAT_ATOM, tplayer, "(TEAM: Changed to " .. teams[newTeam] .. ")");
					switched = switched + 1;
				end;
			end;
			if (switched == 0) then
				return false, "No players teams changed";
			end;
			SendMsg(CHAT_ATOM, tplayer, "(TEAM: Changed %d Players Teams to %s)", switched, teams[newTeam]);
			return true;
		else
			if (target:GetTeam() == newTeam) then
				return false, "player already in team " .. teams[newTeam];
			end;
			
			self:SwitchTeam(target.id, newTeam);
			SendMsg(CHAT_ATOM, target, "(TEAM: Changed to %s)", teams[newTeam]);
			SendMsg(CHAT_ATOM, player, "(TEAM: %s Team Changed to %s)", target:GetName(), teams[newTeam]);
		end;
		return true;
	end;
	--------------------
	StopSpec = function(self, player)
		if (player:IsSpectating()) then
			if (player:GetTeam() == 0 and g_gameRules.class == "PowerStruggle") then
				self:SwitchTeam(player.id, 1);
			end;
			player.actor:SetSpectatorMode(0, NULL_ENTITY);
			g_gameRules:RevivePlayer(player:GetChannel(), player, false);
		end;
	end,
	--------------------
	RevivePlayer = function(self, player, target, spawnPoint, forceSpawnId, bNoEquip)

		local equip = false;
		
		if (not target or target == player) then
			if (g_game:GetTeam(player.id) == 0 and g_gameRules.class == "PowerStruggle") then
				self:SwitchTeam(player.id, 1);
			end;
			if (player:IsSpectating()) then
				player.actor:SetSpectatorMode(0, NULL_ENTITY);
			end;
			if (player:IsDead() or arrSize(player.inventory:GetInventoryTable()) < 4) then
				equip = true;
			end;
			player.forceSpawnId = forceSpawnId;
			if (spawnPoint) then
				g_gameRules:RevivePlayer(player:GetChannel(), player, false);
			else
				g_gameRules:ResetBoughtItems(player);
				--Debug(player:GetPos())
				g_game:RevivePlayer(player.id, player:GetPos(), player:GetAngles(), g_game:GetTeam(player.id), false);	
			end;
			Script.SetTimer(25, function()
				self:SpawnEffect(ePE_Light, player:GetPos(), toVec(0,0,1), 0.5);
			end);
		elseif (target == "all") then
			if (not target.GetTeam or g_gameRules.class ~= "PowerStruggle" or target:GetTeam() ~= 0) then
				if (spawnPoint) then
					g_gameRules:ReviveAllPlayers(true);
				else
					for i, tplayer in pairs(GetPlayers()or{}) do
						if (tplayer:IsDead() or tplayer == player) then
							if (tplayer:IsDead() or arrSize(tplayer.inventory:GetInventoryTable()) < 3) then
								Script.SetTimer(100, function()
									self:EquipPlayer(player);
								end);
							end;
							g_gameRules:ResetBoughtItems(tplayer);
							g_game:RevivePlayer(tplayer.id, tplayer:GetPos(), tplayer:GetAngles(), g_game:GetTeam(tplayer.id), false);	
							Script.SetTimer(25, function()
								self:SpawnEffect(ePE_Light, tplayer:GetPos(), toVec(0,0,1), 0.5);
							end);
						end;
					end;
				end;
			end;
			return true;
		else
			if (target:GetTeam() == 0 and g_gameRules.class == "PowerStruggle") then
				self:SwitchTeam(target.id, 1);
			end;
			if (target:IsSpectating()) then
				target.actor:SetSpectatorMode(0, NULL_ENTITY);
			end
			if (target:IsDead() or arrSize(target.inventory:GetInventoryTable()) < 3) then
				equip = true;
			end;
			target.forceSpawnId = forceSpawnId;
			if (spawnPoint) then
				g_gameRules:RevivePlayer(target:GetChannel(), target, false);
			else
				g_gameRules:ResetBoughtItems(target);
				g_game:RevivePlayer(target.id, target:GetPos(), target:GetAngles(), g_game:GetTeam(target.id), false);		
			end;
			
			Script.SetTimer(25, function()
				self:SpawnEffect(ePE_Light, target:GetPos(), toVec(0,0,1), 0.5);
			end);
		end;
		if (equip and not bNoEquip) then
			if (g_gameRules.class == "PowerStruggle") then
				g_gameRules:ResetRevive((target or player).id, true);
			end;
			Script.SetTimer(100, function()
				g_gameRules:EquipPlayer(target or player);
			end);
		end;
	end;
	--------------------
	SpawnEffect = function(self, effect, pos, dir, scale)
		if (not effect) then
			return false, "invalid effect";
		end

		local pos = pos or toVec(0,0,0);
		local dir = dir or toVec(0,0,1);
		local scale = scale or 1;
		g_gameRules:CreateExplosion(NULL_ENTITY, NULL_ENTITY, 1, pos, dir, 45, 0.1, 0.1, 0.1, effect, scale, 0.1, 0.1, 0.1);
	end,
	--------------------
	SpawnEffect_Limited = function(self, sHandle, effect, ...)
		if (not effect) then
			return
		end

		if (not ATOM_Utils.RECENT_EXPLOSIONS[effect .. sHandle]) then
			ATOM_Utils.RECENT_EXPLOSIONS[effect .. sHandle] = timerinit()
		end
		if (not timerexpired(ATOM_Utils.RECENT_EXPLOSIONS[effect .. sHandle], 0.15)) then
			return
		end
		ATOM_Utils.RECENT_EXPLOSIONS[effect .. sHandle] = timerinit()

		self:SpawnEffect(effect, ...)
	end,
	--------------------
	Helmet_Attach = function(self, player, helmet, x, y, z, bone, vecdir)
		
		local NAME = "_helmetattach"..math.random()*9999;
			
		helmet.NAME = NAME;
		
		if (vecdir) then
			vecdir = player:GetDirectionVector();
		end;
			
		--helmet:DestroyPhysics()
		helmet:EnablePhysics(false);
		player:CreateBoneAttachment(0, bone or "Bip01 Head", NAME);
		player:SetAttachmentObject(0, NAME, helmet.id, -1, 0);
		player:SetAttachmentDir(0,NAME,vecdir or vecScale(player.actor:GetHeadDir(),-1),true)
		player:SetAttachmentPos(0,NAME,{x=x,y=y,z=z},false)

		
	end;
	--------------------
	GetGameTime = function(self)
		return tonum(System.GetCVar("e_time_of_day"));
	end;
	--------------------
	SetGameTime = function(self, player, value, reason)
		local value = value or 12;
		local value = math.max(0, math.min(24, value));
		local format = (value ~= 24 and value > 12) and "PM" or "AM";
		value = cutNum(value, 2);
		local reason = tostr(reason, "Admin Decision");
		SendMsg(ERROR, ALL, "(TIME OF DAY: SET TO-[ " .. tostr(value):gsub("%.", ":") .. format .. " ]-(" .. reason .. "))");
		self.StoppedTOD = value;
		ATOMDLL:ForceSetCVar("e_time_of_day", tostr(value));
		return true;
	end;
	--------------------
	IsNight = function(self)
		local iGameTime = self:GetGameTime()
		return (iGameTime >= 20 and iGameTime <= 6)
	end;
	--------------------
	RefillAmmo = function(self, player, target, pay)
		local inventory;
		local refilled = {};
		local prices = {
			['SMG'] 		= { 0.5, 1 	};
			['SCAR'] 		= { 1,	 1 	};
			['FY71'] 		= { 1,	 1 	};
			['Shotgun'] 	= { 0.25,1 	};
			['GaussRifle'] 	= { 30,	 1	};		
		};
		return self:RefillAmmoOnTarget((target or player), player)
	end;
	--------------------
	RefillAmmoOnTarget = function(self, hPlayer, hMessageReceiver)
		local aInventory = hPlayer.inventory:GetInventoryTable()
		local sRefilled = ""
		local iTotalPrice = 0
		local iPrestige = checkFunc(hPlayer.GetPrestige, 0, hPlayer)
		if (POWER_STRUGGLE and iPrestige == 0) then
			return false, "no more prestige left" end
		
		-----------
		local hMsgTarget = checkVar(hMessageReceiver, hPlayer)
		
		-----------
		local bOk = true
		local bAmmoFull = true
		
		-----------
		for i, idGun in pairs(aInventory) do
			local hGun = GetEnt(idGun)
			if (hGun and hGun.weapon) then
			
				-- Disabled for now ???
				-- local sAmmoClass = hGun.weapon:GetAmmoType()
				-- if (POWER_STRUGGLE and sAmmoClass) then
					-- local aDef = g_gameRules:GetItemDef(sAmmoClass)
					-- if (aDef) then
						-- local iAmmoCost = aDef.price * 2;
						-- if (aDef.amount > 1) then
							-- iAmmoCost = iAmmoCost / aDef.amount;
						-- end
						-- iTotalPrice = iTotalPrice + (iRequired * iAmmoCost)
						-- else
							-- bOk = false end
				-- end
			
				if (bOk) then
					local iInventory, iItem = ATOMEquip:RefillAmmo(hPlayer, idGun)
					local iTotal = (checkNumber(iInventory, 0) + checkNumber(iItem, 0))
					
					if (iTotal > 0) then
						if (sRefilled ~=  "") then
							sRefilled = sRefilled .. ", " end
						sRefilled = sRefilled .. hGun.class .. " +" .. (iTotal)
					end
					
					bAmmoFull = false
				else
					break;
				end
			end
		end
		
		-----------
		if (bAmmoFull) then
			return false, "ammunition full" end
			
		-----------
		SendMsg(CHAT_EQUIP, hPlayer, "(AMMO: -%d PP (%s))", iTotalPrice, sRefilled)
		
		-----------
		if (not bOk) then
			return false, "not enough prestige" end
		return true
	end,
	--------------------
	GivePrestige = function(self, player, target, amount)
		if (not target or player.id == target.id) then
			SendMsg(CENTER, player, "You Gave [ " .. amount .. " ] Prestige to yourself");
			player:GivePrestige(amount);
		elseif (target == "all") then
			SendMsg(CENTER, player, "You Gave [ " .. amount .. " ] Prestige to all Players");
			for i, tplayer in pairs(GetPlayers()) do
				tplayer:GivePrestige(amount);
				if (tplayer.id ~= player.id) then
					SendMsg(CENTER, tplayer, "You Received [ " .. amount .. " ] Prestige from " .. player:GetName());
				end;
			end;
		else
			SendMsg(CENTER, player, "You Gave [ " .. amount .. " ] Prestige to " .. target:GetName());
			SendMsg(CENTER, target, "You Received [ " .. amount .. " ] Prestige from " .. player:GetName());
			target:GivePrestige(amount);
		end;
		return true;
	end;
	--------------------
	RefillAmmo_Command = function(self, player) -- from nCX modified to work with ATOM
		local buyMessage;
		local pp = player:GetPrestige()
		local start_pp = pp;
		local vehicle = player:GetVehicle()
		local p_v = vehicle and vehicle or player;
		local tmp = {};
		if (vehicle) then
			for i = 1, 2 do
				local seat = vehicle.Seats[i];
				if (seat) then
					local weaponCount = seat.seat:GetWeaponCount();
					for j = 1, weaponCount do
						tmp[#tmp + 1] = seat.seat:GetWeaponId(j);
					end
				end
			end
		else
			tmp = p_v.inventory:GetInventoryTable();
		end
		--local pos = player:GetWorldPos();
		--pos = CryMP.Library:CalcSpawnPos(player, 1.5);
		--pos.z = pos.z - 0.5;
		for i, itemId in pairs(tmp or {}) do
			local item = System.GetEntity(itemId);
			if (item and item.weapon) then
				local type = item.weapon:GetAmmoType();
				if (type) then
					local capacity = p_v.inventory:GetAmmoCapacity(type);
					if (capacity > 0) then
						local clipSize = item.weapon:GetClipSize();
						local clipCount = item.weapon:GetAmmoCount();
						--if (item.weapon:GetClipSize() ~= -1) then
						--	item.weapon:Reload();
						--	System.LogAlways("Reloading $4"..item.class);
						--else
						--	System.LogAlways("won't reload "..item.class);
						--end
						local count = p_v.inventory:GetAmmoCount(type) or 0;
						local need = {clipSize - clipCount, capacity - count};
						if (need[1] + need[2] > 0) then
							local def = g_gameRules:GetItemDef(type);
							if (def) then	
								local costPerAmmo = def.price * 2;
								if (def.amount > 1) then
									costPerAmmo = costPerAmmo / def.amount;
								end
								local needTotal = need[1] + need[2];
								local canBuy = needTotal;
								local fullCost = (needTotal * costPerAmmo);
								local cancel = fullCost > pp;
								--System.LogAlways("CANCEL: fullCost "..fullCost.." - pp "..pp.." : needTotal "..needTotal.." * costPerAmmo "..costPerAmmo.." "..type);
								if (cancel) then
									canBuy = math.floor(pp / fullCost) * canBuy;
								end
								if (canBuy > 0) then
									local increaseClip = 0;
									if (clipSize > 0 and need[1] > 0) then
										increaseClip = math.min(canBuy, need[1]); 
										item.weapon:SetAmmoCount(type, clipCount + increaseClip)
										--System.LogAlways("ammo: increasing clip for "..item.class.." : clipcount "..clipCount.." + "..increaseClip.." (size "..clipSize..")");
									end
									local remaining = canBuy - increaseClip;
									if (p_v.vehicle) then
										p_v.vehicle:SetAmmoCount(type, count + remaining);
									else
										p_v.actor:SetInventoryAmmo(type, count + remaining, 3);	
									end
									local str = "(" .. item.class.." - "..canBuy..")";
									if (not buyMessage) then
										buyMessage = str;
									else
										buyMessage = buyMessage..", "..str;
									end
								end
								local cost = canBuy * costPerAmmo;
								pp = pp - cost;
								if (cancel) then
									--CryMP.Msg.Flash:ToPlayer(channelId, {50, "#d77676", "#ec2020",}, "INSUFFICIENT PRESTIGE", "<font size=\"32\"><b><font color=\"#b9b9b9\">*** </font> <font color=\"#843b3b\">UPGRADE [<font color=\"#d77676\">  %s  </font><font color=\"#843b3b\">] CANCELED</font> <font color=\"#b9b9b9\"> ***</font></b></font>");
									local totalPrice = start_pp - pp;
									if (buyMessage) then
										SendMsg(CHAT_EQUIP, player, "(AMMO REFILL: -[ "..buyMessage.." | " .. totalPrice .. " PP ])");
									end
									--Debug(">>",totalPrice)
									player:GivePrestige(-totalPrice);
									return false, "no more prestige left";
								end
							end
						end
					end
				end
			end
		end
		if (buyMessage) then
			local totalPrice = math.floor(start_pp - pp);
			--CryMP.Msg.Animated:ToPlayer(channelId, 1, "<b><font color=\"#b9b9b9\">*** </font> <font color=\"#843b3b\">SCAN [<font color=\"#d77676\"> COST : "..totalPrice.." PP </font><font color=\"#843b3b\">] FINISHED</font> <font color=\"#b9b9b9\"> ***</font></b>");
		--	nCX.ParticleManager("explosions.light.mine_light", 2, pos, g_Vectors.up, 0);
			SendMsg(CHAT_EQUIP, player, "(AMMO REFILL: -[ "..buyMessage.." | " .. totalPrice .. " PP ])");
			player:GivePrestige(-totalPrice);
		else
			return false, "ammo already full"
		end
		return true;
	end;
	--------------------
	CreatePortal = function(self, props)
		local start = props.Pos;
		local range = props.Range or 5;
		local out = props.Out;
		local out_rnd = props.OutRandom;
		local msg = props.Msg;
		local enter = props.Enter;
		local vehicle = props.AllowVehicles;
		local condition = props.ConditionFunc

		local hTrigger = System.SpawnEntity({
		
			class = "ATOMTrigger",-- "ProximityTrigger", "ATOMTrigger",
			flags = ENTITY_FLAG_SERVER_ONLY,
			position = start or {x = 0, y = 0, z = 0},
			name = "portal_teleport_trigger_" .. self:SpawnCounter(),
			
			properties = {
				DimX = (range * 2) * 4,
				DimY = (range * 2) * 4,
				DimZ = (range * 2) * 4,
			}
		})
		
		Script.SetTimer(1, function()
			local hPortal = GetEnt(props.linked)
			local sPortal = "_portal_" .. (table.count(self.portals) + 1)
			
			hPortal.portal_id = sPortal
			hPortal.OnEnterArea = function(self, trigger, entity, x)
			
				local aStats = entity:GetPhysicalStats()
				if (not isArray(aStats) or (aStats.mass == 0 or entity:GetMass() == 0)) then
					return end
					
				if (trigger.inside[entity.id]) then
					return end
			
				-- g_utils:OnEnterPortal(self.portal_id, entity)
			end
			hPortal.OnLeaveArea = function(self, trigger, entity)
			
				local aStats = entity:GetPhysicalStats()
				if (not isArray(aStats) or (aStats.mass == 0 or entity:GetMass() == 0)) then
					return end
					
				if (not trigger.inside[entity.id]) then
					return end
					
				g_utils:OnLeavePortal(self.portal_id, entity)
			end
			
			ATOMTrigger:ResetEntityLinks()
			hTrigger:ResetEntityLinks()
			hTrigger:ForwardEventsTo(hPortal)
			-- Debug("called with not all params?")
			
			self.portals[sPortal] = { start, range, out, msg, props.linked, enter, vehicle, out_rnd, condition, hTrigger };


			-- SpawnEffect(ePE_Flare, hTrigger:GetPos())
		end)
		return hTrigger
	end,
	--------------------

};