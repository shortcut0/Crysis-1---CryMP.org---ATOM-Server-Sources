---------------------------------------------------------------
-- restart, Restarts the Current Game
---------------------------------------------------------------

NewCommand({
	Name 	= "restart",
	Access	= ADMINISTRATOR,
	Description = "Restarts the Current Game",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player)
		return true, System.ExecuteCommand("sv_Restart");
	end;
});



---------------------------------------------------------------
-- endgame, ends the current game and forces scoreboard
---------------------------------------------------------------

NewCommand({
	Name 	= "endgame",
	Access	= ADMINISTRATOR,
	Description = "Ends the Current Game",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player)
		return self:EndGame()
	end;
});

---------------------------------------------------------------
-- nextlevel, ends the current game and switches to next level in rotation
---------------------------------------------------------------

NewCommand({
	Name 	= "nextlevel",
	Access	= ADMINISTRATOR,
	Description = "Ends the Current Game and switches to Next Level in Rotation",
	Console = true,
	Args = {
		{ "Timer", "The amount of Seconds before Map Change", Integer = true, PositiveNumber = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Timer)
		return self:NextLevel(Timer);
	end;
});

---------------------------------------------------------------
-- map <mapname>, Changes map to specified one
---------------------------------------------------------------

NewCommand({
	Name 	= "map",
	Access	= ADMINISTRATOR,
	Description = "Changes map to specified one",
	Console = true,
	Args = {
		{ "MapName", "The new map you wish to start", Required = true };
		{ "Timer", "The amount of Seconds before Map Change", Integer = true, PositiveNumber = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, MapName, Timer)
		return self:ChangeMap(MapName, Timer);
	end;
});

---------------------------------------------------------------
-- mapsetup, Reloads the mapsetup for the current map
---------------------------------------------------------------

NewCommand({
	Name 	= "mapsetup",
	Access	= SUPERADMIN,
	Description = "Reloads the mapsetup for the current map",
	Console = true,
	Args = {
	--	{ "MapName", "The new map you wish to start", Required = true };
	--	{ "Timer", "The amount of Seconds before Map Change", Integer = true, PositiveNumber = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMSetup',
	};
	func = function(self, player)--, MapName, Timer)
		return ATOMSetup:OnMapStart(ATOM:GetMapName(true), ATOM:GetMapName());
	end;
});

---------------------------------------------------------------
-- god <Target>, Toggles GodMode for you or specified Player
---------------------------------------------------------------

NewCommand({
	Name 	= "god",
	Access	= ADMINISTRATOR,
	Description = "Toggles God-Mode for you or specified Player",
	Console = true,
	Args = {
		{ "Target", "The Player to toggle God-Mode on", Target = true, Optional = true, AcceptSelf = true };
		{ "MegaGod", "Enabled Mega God Mode", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, MegaGod)
		local mega = MegaGod ~= nil and "MEGA" or "";
		if (not Target or Target == player) then
			player:ToggleGodMode(MegaGod ~= nil);
			SendMsg(CENTER, player, "(" .. mega .. "GODMODE : " .. (player:IsInGodMode() and "ENABLED" or "DISABLED") .. ")");		
		else
			Target:ToggleGodMode();
			SendMsg(CENTER, Target, "(" .. mega .. "GODMODE : " .. (Target:IsInGodMode() and "ENABLED" or "DISABLED") .. ")");
			SendMsg(CHAT_ATOM, player, "(" .. Target:GetName() .. ": God Mode " .. (Target:IsInGodMode() and "ENABLED" or "DISABLED") .. ")");
		end;
		return true;
	end;
});


---------------------------------------------------------------
-- getammo <Target>, Refills your or targets ammunition
---------------------------------------------------------------

NewCommand({
	Name 	= "getammo",
	Access	= ADMINISTRATOR,
	Description = "Refills your or Targets Ammunition",
	Console = true,
	Args = {
		{ "Target", "The Player to refill ammunition on", Target = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target)
		return self:RefillAmmo(player, Target, false);
	end;
});


---------------------------------------------------------------
-- set <CVar> <Value>, Forcefully changes the value of a Console Variable
---------------------------------------------------------------

NewCommand({
	Name 	= "set",
	Access	= ADMINISTRATOR,
	Description = "Forcefully changes the value of a Console Variable",
	Console = true,
	Args = {
		{ "CVar", "The Name of the Console Variable", Required = true };
		{ "Value", "The Value you wish to set the CVar to, if not specified will show current value of <$3CVar$1>", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		NoChatLog = true
	};
	func = function(self, player, CVar, Value)
		ORIG_CVARS = ORIG_CVARS or {};
		if (type(ORIG_CVARS) ~= "table") then
			ORIG_CVARS = {};
		end;
		if (CVar:lower() == "reset") then
			if (not Value or Value:lower() == "all") then
				if (not ORIG_CVARS or arrSize(ORIG_CVARS) < 1) then
					LAST_CVAR_CONFIG = nil;
					return false, "No CVars to Reset found";
				end;
				for cvar, value in pairs(ORIG_CVARS) do
					ATOMLog:LogGameUtils('Admin', "CVar %s restored to %s ($4%s$9)", cvar, value, tostr(System.GetCVar(cvar)));
					ATOMDLL:ForceSetCVar(cvar, value);
				end;
				SendMsg(CHAT_ATOM, player:GetAccess(), "(CVAR: Restored %d CVars to Original Value)", arrSize(ORIG_CVARS));
				ORIG_CVARS = {};
				LAST_CVAR_CONFIG = nil;
				return true;
			else
				local value = ORIG_CVARS[Value:lower()];
				if (not value) then
					return false, "CVar already default";
				end;
				ATOMLog:LogGameUtils('Admin', "CVar %s restored to %s ($4%s$9)", Value, value, tostr(System.GetCVar(Value)));
				ATOMDLL:ForceSetCVar(Value, value);
				SendMsg(CHAT_ATOM, player:GetAccess(), "(" .. Value:upper() .. ": Restored to: " .. value .. ")");
				ORIG_CVARS[Value:lower()] = nil;
				return true;
			end;
		end;
		local currValue = System.GetCVar(CVar);
		if (not currValue) then
			return false, "Invalid CVar";
		end;
		if (currValue and not Value) then
			SendMsg(CHAT_ATOM, player, "(" .. CVar:upper() .. ": Current Value is: " .. currValue .. ")");
			return true;
		end;
		if (currValue == Value) then
			SendMsg(CHAT_ATOM, player, "(" .. CVar:upper() .. ": Current Value already is: " .. currValue .. ")");
			return true;
		end;
		ORIG_CVARS = ORIG_CVARS or {};
		
		if (type(ORIG_CVARS) ~= "table") then
			ORIG_CVARS = {};
		end;
		ORIG_CVARS[CVar:lower()] = ORIG_CVARS[CVar:lower()] or tostr(currValue);
		ATOMDLL:ForceSetCVar(CVar, Value);
		SendMsg(CHAT_ATOM, player:GetAccess(), "(" .. CVar:upper() .. ": Value Set to: " .. Value .. ")");
		ATOMLog:LogGameUtils('Admin', "CVar %s set to %s ($4%s$9)", CVar, Value, ORIG_CVARS[CVar:lower()]);
		return true;
	end;
});


------------------------------------------------------------------------------------------------------
--  !spawnweap <weapon> <attachments>

NewCommand({
	Name 	= "spawnweap",
	Access	= ADMINISTRATOR,
	Description = "sets a weapon to spawn with",
	Console = true,
	Args = {
		{ "Weapon", "The Weapon to spawn with", Required = true };
		{ "Attachments", "The attachments for the spawn weapon", Optional = true };
	};
	Properties = {
		Self = 'ATOMEquip',
	--	NoChatLog = true
	};
	func = function(self, player, weapon, ...)

		if (weapon and weapon:lower()=="reset") then
			self.cfg.SpawnEquipment = {
				["InstantAction"] = copyTable(self.defaultEquipment["InstantAction"]),
				["PowerStruggle"] = copyTable(self.defaultEquipment["PowerStruggle"])
			};
			return true, SendMsg(CHAT_ATOM, player, "(SpawnWeapon: Reset to default Value)");
		end;

		local spawnWeap, err = (weapon:lower() == "fists" and "Fists") or (weapon:lower() == "random" and "Random"), nil;
		if (not spawnWeap) then
			spawnWeap, err = g_utils:IsValidGun(weapon);
			if (not spawnWeap) then
				return false, err;
			end;
		end;
		local attachment;
		local attachments = {};
		for i, att in ipairs({...}) do
			attachment = g_utils:IsValidAttachment(att:lower());
			if (attachment) then
				table.insert(attachments, attachment);
			end;
		end;

		local spawnEquip = self.cfg.SpawnEquipment[g_gameRules.class];
		local spawnItem = { spawnWeap, attachments };

		
		spawnEquip[GUEST] = {};
		spawnEquip[PREMIUM] = {};
		
		spawnEquip[GUEST][1] = spawnItem;
		spawnEquip[PREMIUM][1] = spawnItem;

		--SendMsg(EventMsgType, ALL, "Spawn weapon has been changed to "..weapon);
		SendMsg(CHAT_ATOM, ALL, "(SpawnWeapon: CHANGED TO-[ %s ]-BY :: %s)", spawnItem[1]:upper(), player:GetName());
		return true;

	end
});

---------------------------------------------------------------
-- exec <string>, Executes a string in the Server Console
---------------------------------------------------------------

NewCommand({
	Name 	= "exec",
	Access	= ADMINISTRATOR,
	Description = "Executes a string in the Server Console",
	Console = true,
	Args = {
		{ "String", "The String to Execute", Required = true };
	--	{ "Value", "The Value you wish to set the CVar to, if not specified will show current value of <$3CVar$1>", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		NoChatLog = true
	};
	func = function(self, player, ...)
		local code = table.concat({...}, " ");
		local forbidden = {
			"system.quit";
			"kick (.*)";
			"ban (.*)";
			"dumpcommandsvars";
		};
		if (not player:HasAccess(DEVELOPER)) then
			for i, no in pairs(forbidden) do
				if (code:lower():find(no)) then
					return false, "insufficient access"
				end;
			end;
		end;
		System.ExecuteCommand(code);
		SendMsg(CHAT_ATOM, player, "(CONSOLE: Executed String \"%s\")", code);
		return true;
	end;
});


---------------------------------------------------------------
-- tpf <Distance>, Teleports you X Meter forward
---------------------------------------------------------------

NewCommand({
	Name 	= "tpf",
	Access	= ADMINISTRATOR,
	Description = "Teleports you Specified Meters forward",
	Console = true,
	Args = {
		{ "Distance", "The Distance you wish to be teleported forward", PositiveNumber = true, Integer = true, Optional = true };
		{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Distance, FollowTerrain)
		return self:Teleport(player, Distance, (FollowTerrain ~= nil));
	end;
});

---------------------------------------------------------------
-- tp <X>, <Y>, <Z>, Teleports your to specified position
---------------------------------------------------------------

NewCommand({
	Name 	= "tp",
	Access	= ADMINISTRATOR,
	Description = "Teleports your to specified position",
	Console = true,
	Args = {
		{ "X", "The X position on the map", Integer = true, Required = true };
		{ "Y", "The Y position on the map", Integer = true, Optional = true };
		{ "Z", "The Z position on the map", Integer = true, Optional = true };
		{ "FollowTerrain", "Adjust specified position to terrain height", Optional = true };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, x, y, z, terrain)
		local pos = player:GetPos();
		local position = makeVec(x, (y or pos.y), (z or pos.z));
		if (terrain ~= nil) then
			position.z = GetGroundPos(position);
		end;
		
		if (GetDistance(position, player) < 0.1) then
			return false, "You are already at this position";
		end;
		
		SendMsg(CHAT_ATOM, player, "Teleported to position %s", position.x .. ", " .. position.y .. ", " .. position.z);
		
		g_game:MovePlayer(player.id, position, player:GetAngles());
		self:SpawnEffect(ePE_Light, position);
		return true;
	end;
});


---------------------------------------------------------------
-- up <Distance>, Teleports you X Meter upwards
---------------------------------------------------------------

NewCommand({
	Name 	= "up",
	Access	= MODERATOR,
	Description = "Teleports you Specified Meters upwards",
	Console = true,
	Args = {
		{ "Distance", "The Distance you wish to be teleported forward", PositiveNumber = false, Integer = true, Optional = true, Length = { -999999, 999999 } };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Distance)--, FollowTerrain)
		return self:Teleport_Up(player, Distance);--, (FollowTerrain ~= nil));
	end;
});


---------------------------------------------------------------
-- deathpos, toggles reviving players at their death position
---------------------------------------------------------------

NewCommand({
	Name 	= "deathpos",
	Access	= MODERATOR,
	Description = "Toggles reviving players at their death position",
	Console = true,
	Args = {
	--	{ "Distance", "The Distance you wish to be teleported forward", PositiveNumber = false, Integer = true, Optional = true };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, Distance)--, FollowTerrain)
		self.cfg.RespawnPlayerAtPos = not self.cfg.RespawnPlayerAtPos;
		SendMsg(CHAT_ATOM, player:GetAccess(), "(DEATHPOS: " .. (self.cfg.RespawnPlayerAtPos and "Enabled" or "Disabled") .. ")");
		return true;
	end;
});


---------------------------------------------------------------
-- setping <Target> <Ping>, Changes the Ping of specified or all Players
---------------------------------------------------------------

NewCommand({
	Name 	= "setping",
	Access	= ADMINISTRATOR,
	Description = "Changes the Ping of specified or all Players",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player to change the Ping", Target = true, AcceptALL = true, AcceptSelf = true, Required = true };
		{ "Ping", "The Fake ping to assign to the target player", Integer = true, Optional = true };
	};
	Properties = {
		Self = 'g_gameRules'
	};
	func = function(self, player, Target, Ping)--, FollowTerrain)
		local FakePing = Ping or 0;
		if (not Target or Target == player) then
			if (FakePing == 0) then
				player.Fake_Ping = nil;
				SendMsg(CHAT_ATOM, player, "(YOU: Removed Your FakePing)");
			else
				player.Fake_Ping = FakePing;
				SendMsg(CHAT_ATOM, player, "(YOU: Set your FakePing to %d)", FakePing);
			end;
		elseif (Target == "all") then
			if (FakePing == 0) then
				self.Fake_Ping = nil;
				SendMsg(CHAT_ATOM, player, "(YOU: Removed all players FakePings)");
				for i, tplayer in pairs(GetPlayers()or{}) do
					tplayer.Fake_Ping = nil;
				end;
			else
				self.Fake_Ping = FakePing;
				SendMsg(CHAT_ATOM, player, "(YOU: Set all players FakePings to %d)", FakePing);
				for i, tplayer in pairs(GetPlayers()or{}) do
					tplayer.Fake_Ping = nil;
				end;
			end;
		else
			if (FakePing == 0) then
				Target.Fake_Ping = nil;
				SendMsg(CHAT_ATOM, player, "(YOU: Removed %s FakePing)", Target:GetName());
				--SendMsg(CHAT_ATOM, player, "(%s: Removed your FakePing)", player:GetName());
			else
				Target.Fake_Ping = FakePing;
				SendMsg(CHAT_ATOM, player, "(YOU: Set %s FakePing to %d)", Target:GetName(), FakePing);
				--SendMsg(CHAT_ATOM, player, "(%s: Set your FakePing to %d)", player:GetName(), FakePing);
			end;
		end;
		return true;
	end;
});


---------------------------------------------------------------
-- turrets, Enables or Disables all Turrets
---------------------------------------------------------------

NewCommand({
	Name 	= "turrets",
	Access	= MODERATOR,
	Description = "Enables or Disables all Turrets",
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
		return self:SetTurrets(player, teamId, true);
	end;
});


---------------------------------------------------------------
-- nokill, toggles no killing mode on the server
---------------------------------------------------------------

NewCommand({
	Name 	= "nokill",
	Access	= ADMINISTRATOR,
	Description = "toggles no killing mode on the server",
	Console = true,
	Args = {
		{ "Target", "Toggle no kill only on this player", Optional = true, Target = true };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, target)--, Distance)--, FollowTerrain)
		if (target) then
			target.NoKill = not target.NoKill;
			if (target.id == player.id) then
				SendMsg(CHAT_ATOM, player, "(%s: No Kill Mode %s on yourself)", "YOU", (target.NoKill and "Enabled" or "Disabled"));
			else
				SendMsg(CHAT_ATOM, player, "(%s: No Kill Mode %s)", target:GetName(), (target.NoKill and "Enabled" or "Disabled"));
				SendMsg(CENTER, target, "(No Kill Mode :: %s)", (target.NoKill and "Enabled" or "Disabled"));
			end;
		else
			self.cfg.DamageConfig.NoKillMode = not ATOM.cfg.DamageConfig.NoKillMode;
			SendMsg(CHAT_ATOM, player, "No Kill Mode :: %s", (ATOM.cfg.DamageConfig.NoKillMode and "Enabled" or "Disabled"));
		end;
		return true;
	end;
});


---------------------------------------------------------------
-- addexp <target>, Gives EXP Points to specified Player
---------------------------------------------------------------

NewCommand({
	Name 	= "addexp",
	Access	= MODERATOR,
	Description = "Gives EXP Points to specified Player",
	Console = true,
	Args = {
		{ "Target", "The Player you wish to give EXP to", Required = true, Target = true, AcceptSelf = true, AcceptALL = true };
		{ "Amount", "Will adjust position to terrain height", Required = true, Integer = true };
	};
	Properties = {
		Self = 'ATOMLevelSystem',
	};
	func = function(self, player, Target, Amount)--, FollowTerrain)
		self:GiveEXP(player, Target, Amount);
	end;
});



----------------------------------------------------------------------
-- !timelimit

NewCommand({
	Name 	= "timelimit",
	Access	= MODERATOR,
	Description = "Changes the remaining time limit",
	Console = true,
	Args = {
		{ "Limit", "Sets the remaining round time limit, use <[+/-]number> to add or remove remaining time", Required = true };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Limit)--, FollowTerrain)
		return self:SetTimeLimit(player, Limit);--, (FollowTerrain ~= nil));
	end;
});



---------------------------------------------------------------
-- cvarconfig 
---------------------------------------------------------------

NewCommand({
	Name 	= "gfx",
	Access	= ADMINISTRATOR,
	Description = "Enables specified CVar-Configuration",
	Console = true,
	Args = {
		{ "Index", "The index of the Configuration List [0/6]", Required = true, Integer = true, PositiveNumber = true };
	--	{ "Value", "The Value you wish to set the CVar to, if not specified will show current value of <$3CVar$1>", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		NoChatLog = true,
		Help = true
	};
	func = function(self, player, Index)
		local list = {
			[0] = {};
			[1] = {
				'Minimal Performance',
				{
					e_sun = 0,
					r_postprocesseffects = 0
				}
			};
			[2] = {
				'Small Performance',
				{
					e_flocks  = 0,
					e_sun = 0,
					r_postprocesseffects = 0,
					e_fog = 0
				}
			};
			[3] = {
				'Performance',
				{
					e_flocks  = 0,
					e_sun = 0,
					r_postprocesseffects = 0,
					e_fog = 0,
					e_sky_box = 0,
					r_Rain = 0
				}
			};
			[4] = {
				'Moderate Performance',
				{
					e_flocks  = 0,
					e_sun = 0,
					r_postprocesseffects = 0,
					e_fog = 0,
					e_sky_box = 0,
					e_water_volumes = 0,
					e_water_ocean = 0,
					r_Rain = 0
				}
			};
			[5] = {
				'Ultra Performance',
				{
					e_flocks  = 0,
					e_sun = 0,
					r_postprocesseffects = 0,
					e_fog = 0,
					e_sky_box = 0,
					e_water_volumes = 0,
					e_water_ocean = 0,
					r_texskyquality = 0,
					e_vegetation = 0,
					e_voxel = 0,
					r_Rain = 0
				}
			};
			[6] = {
				'Maximum Performance',
				{
					e_flocks  = 0,
					e_sun = 0,
					r_postprocesseffects = 0,
					e_fog = 0,
					e_sky_box = 0,
					e_water_volumes = 0,
					e_water_ocean = 0,
					r_texskyquality = 0,
					e_vegetation = 0,
					e_voxel = 0,
					e_terrain = 0,
					r_Rain = 0
				}
			};
		};
		ORIG_CVARS = ORIG_CVARS or {};
		if (Index == 0) then
			if (not LAST_CVAR_CONFIG) then
				return false, "No Config to disable";
			end;
			cvars = list[LAST_CVAR_CONFIG];
			for cvar, value in pairs(cvars[2]) do
			--	ORIG_CVARS[cvar:lower()] = ORIG_CVARS[cvar:lower()] or System.GetCVar(cvar);
				if (ORIG_CVARS[cvar:lower()]) then
					ATOMDLL:ForceSetCVar(cvar, tostr(ORIG_CVARS[cvar:lower()]));
				end;
			end;
			LAST_CVAR_CONFIG = nil
			ATOMLog:LogGameUtils('Admin', "CVar Config %s Unloaded ($4%s CVars Restored$9)", cvars[1], arrSize(cvars[2]));
			return true;
		elseif (not list[Index]) then
			return false, "Invalid Config Index";
		else
			if (LAST_CVAR_CONFIG) then
				if (LAST_CVAR_CONFIG == Index) then
					return false, "Configuration already loaded"
				end;
				cvars = list[LAST_CVAR_CONFIG];
				for cvar, value in pairs(cvars[2]) do
					if (ORIG_CVARS[cvar:lower()]) then
					--	ORIG_CVARS[cvar:lower()] = nil;
						ATOMDLL:ForceSetCVar(cvar, tostr(ORIG_CVARS[cvar:lower()]));
					end;
				end;
				ATOMLog:LogGameUtils('Admin', "CVar Config %s Unloaded ($4%s CVars Restored$9)", cvars[1], arrSize(cvars[2]));
			end;
			LAST_CVAR_CONFIG = Index;
			cvars = list[LAST_CVAR_CONFIG];
			for cvar, value in pairs(cvars[2]) do
				ORIG_CVARS[cvar:lower()] = ORIG_CVARS[cvar:lower()] or tostr(System.GetCVar(cvar));
				ATOMDLL:ForceSetCVar(cvar, tostr(value));
			end;
			ATOMLog:LogGameUtils('Admin', "CVar Config %s was Loaded ($4%s CVars Changed$9)", cvars[1], arrSize(cvars[2]));
			return true;
		end;
		--ORIG_CVARS[CVar:lower()] = ORIG_CVARS[CVar:lower()] or tostr(currValue);
	end;
});


local function localLookUp(self, player, target)
	local aGroupData 	= target:GetGroupData()
	local sColor 		= aGroupData[4]
	local sAccess 		= string.format("%s%s", sColor, aGroupData[2])
	local sIP 			= checkVar(target:GetIP(), 		string.UNKNOWN)
	local sProfile 		= checkVar(target:GetProfile(), string.UNKNOWN)
	local iChannel 		= checkVar(target:GetChannel(), string.UNKNOWN)
	local sPort 		= checkVar(target:GetPort(), 	string.UNKNOWN)
	local sHost 		= checkVar(target:GetHostName(),string.UNKNOWN)
	local sCountry 		= checkVar(target:GetCountry(), string.UNKNOWN)
	local sAccount 		= checkVar(target.accountname, 	string.UNKNOWN)
	
	------------------
	local sName = target:GetName()
	
	------------------
	local sTimeStamp 	= atommath:Get("timestamp")
	local sLastSeen 	= string.UNKNOWN
	local iLastSeen 	= checkFunc(target.GetLastSeen, -1, target)
	if (string.empty(sLastSeen)) then
		sLastSeen = -1 
		else
			iLastSeen = tonumber(iLastSeen) end
	
	------------------
	local sTimeDiffer 	= math_sub(sTimeStamp, iLastSeen)
	local iTimeDiffer 	= tonumber(sTimeDiffer)
	
	------------------
	if (iLastSeen == -1) then
		sLastSeen = "Never"
		
	elseif ((iTimeDiffer < ONE_DAY)) then
		sLastSeen = "Today"
		
	elseif ((iTimeDiffer < (ONE_DAY * 2))) then
		sLastSeen = "Yesterday"
		
	elseif ((iTimeDiffer < (ONE_DAY * 4))) then
		sLastSeen = "A few Days ago"
		
	elseif ((iTimeDiffer < (ONE_DAY * 7))) then
		sLastSeen = "A Week ago"
		
	else
	
		sLastSeen = string.format("%d Days ago", math.round(tonumber(math_div(iTimeDiffer, ONE_DAY))))
	end;
	
	------------------
	local id = target:GetIdentifier()
	local score = self:GetData(id)
	
	------------------
	if (not score) then
		score = {} end
	
	------------------
	local iPlayTime 	 = checkNum(target:GetPlayTime(), 0)
	local iPlayTimeRank  = 1
	
	------------------
	for i, hOther in pairs(GetPlayers()) do
		if (hOther.id ~= target.id) then
			if (checkNum(hOther:GetPlayTime(), 0) > iPlayTime) then
				iPlayTimeRank = (iPlayTimeRank + 1)
			end
		end
	end
	
	------------------
	local sPlayTime		= SimpleCalcTime(iPlayTime)
	local sPlayTimeRank	= string.format("#%d / %d", iPlayTimeRank, table.count(GetPlayers()))
	
	------------------
	local sVIPStatus	= "<Unlocked>";
	local iPermiumTime	= self.cfg.Goals.HoursUntilPremium * 60 * 60;
	
	------------------
	local sLongestTime		= SimpleCalcTime(score.LongTime or 0)
	
	------------------
	local iGameTimeRank 	= self:GetPlayerRank(target, eST_GameTime)
	local sGameTimeRank		= string.format("#%d / %d", iGameTimeRank, arrSize(self.permaScore))
	local sGameTime 		= string.format("%s $9($7#%d/%d$9)", SimpleCalcTime(score.GameTime), iGameTimeRank, arrSize(self.permaScore))
	
	------------------
	if (not target:HasAccess(PREMIUM) and score.GameTime < iPermiumTime) then
		sVIPStatus		= string.format("%s $9($4%0.2f%%$9)", SimpleCalcTime(iPermiumTime - score.GameTime), ((score.GameTime / iPermiumTime) * 100))
	end;
	
	------------------
	local iLevelRank 	= checkNum(ATOMLevelSystem:GetLevelRank(player), 0)
	local sLevel 		= string.format("%d $9($7#%d$9)", checkNum(target:GetLevel(), 0), iLevelRank)
	local iEXP 			= (target:GetEXP())
	
	------------------
	local aLuaClient = checkVar(target.LuaClient, { "$1", "Unknown" })
	local sLuaClient = (aLuaClient[1] .. aLuaClient[2])

	------------------
	local sAlias = checkVar(target:GetAlias(), string.UNKNOWN)
	
	------------------
	local iSpace = 84
	
	------------------
	SendMsg(CONSOLE, player, " ")
	SendMsg(CONSOLE, player, "$9===== [ $5LOOKUP$9 ] ===============================================================================================")
	SendMsg(CONSOLE, player, "$9[                  Name : $5" .. string.rspace(sName,		 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[                 Alias : $5" .. string.rspace(sAlias,		 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[                Access : $5" .. string.rspace(sAccess,		 iSpace, string.COLOR_CODE) 	.. " $9]")
	SendMsg(CONSOLE, player, "$9[               Channel : $5" .. string.rspace(iChannel,	 iSpace, string.COLOR_CODE) 	.. " $9]")
	SendMsg(CONSOLE, player, "$9[                    IP : $5" .. string.rspace(sIP,			 iSpace, string.COLOR_CODE) 	.. " $9]")
	SendMsg(CONSOLE, player, "$9[                    ID : $5" .. string.rspace(sProfile,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[                Domain : $5" .. string.rspace(sHost,		 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[    Multiplayer Client : $5" .. string.rspace(sLuaClient,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[          Account Name : $5" .. string.rspace(sAccount,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[               Country : $5" .. string.rspace(sCountry,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[             Last Seen : $5" .. string.rspace(sLastSeen,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[             Game Time : $5" .. string.rspace(sGameTime,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[               Premium : $5" .. string.rspace(sVIPStatus,	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[             Play Time : $5" .. string.rspace(sPlayTime, 	 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[          Longest Time : $5" .. string.rspace(sLongestTime, iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[                 Level : $5" .. string.rspace(sLevel,		 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9[                   Exp : $5" .. string.rspace(iEXP,		 iSpace, string.COLOR_CODE)		.. " $9]")
	SendMsg(CONSOLE, player, "$9================================================================================================ [ $5LOOKUP$9 ] ====")
end;

---------------------------------------------------------------
-- !toxpass 

NewCommand({
	Name 	= "toxpass",
	Access	= MODERATOR,
	Description = "Give or take the toxicity pass from a player",
	Console = true,
	Args = {
		{ "Target", "The target player", Required = true, Target = true, AcceptSelf = true, AcceptALL = false };
	};
	Properties = {
		Self = 'g_playerperfs',
	};
	func = function(self, hPlayer, hTarget)--, Amount)--, FollowTerrain)
	
		if (not hTarget) then
			return false, "invalid player" end
	
		if (hTarget.ToxicityPass ~= true) then
			hTarget.ToxicityPass = true
			else
				hTarget.ToxicityPass = false end
		
		---------
		SendMsg(CHAT_ATOM, hPlayer, "(ToxicityPass: %s On %s)", string.bool(hTarget.ToxicityPass, BTOSTRING_TOGGLED), hTarget:GetName())
		
		---------
		--self:SetValue(hTarget, "ToxicityPass", hTarget.ToxicityPass)
		return true
	end;
});

---------------------------------------------------------------
-- !alias 

NewCommand({
	Name 	= "alias",
	Access	= MODERATOR,
	Description = "Shows the alias of specified player",
	Console = true,
	Args = {
		{ "Target", "The target player", Required = true, Target = true, AcceptSelf = true, AcceptALL = false };
	};
	Properties = {
	};
	func = function(hPlayer, hTarget)--, Amount)--, FollowTerrain)
	
		if (not hTarget) then
			return false, "invalid player" end
	
		---------
		SendMsg(hTarget, hPlayer, "(Alias: %s)", checkFunc(hTarget.GetAlias, string.UNKNOWN, hTarget))
		
		---------
		return true
	end
});

---------------------------------------------------------------
-- !alias

NewCommand({
	Name 	= "setalias",
	Access	= MODERATOR,
	Description = "Changes the alias of a player",
	Console = true,
	Args = {
		{ "Target", "The target player", Required = true, Target = true, AcceptSelf = true, AcceptALL = false };
		{ "Alias", "The new alias", Required = true, Concat = true };
	};
	Properties = {
	};
	func = function(hPlayer, hTarget, sAlias)

		if (not hTarget) then
			return false, "invalid player" end

		---------
		local bOk, sErr = hTarget:SetAlias(sAlias, "Admin Decision", hPlayer)
		if (not bOk) then
			return false, sErr
		end

		SendMsg(hTarget, hPlayer, "(Alias: Changed to %s)", checkFunc(hTarget.GetAlias, string.UNKNOWN, hTarget))

		---------
		return true
	end
});

---------------------------------------------------------------
-- !alias

NewCommand({
	Name 	= "aliaslist",
	Access	= MODERATOR,
	Description = "Changes the alias of a player",
	Console = true,
	Args = {
		{ "Filter", "Search Filter", Optional = true, Concat = true };
	};
	Properties = {
		Self = "ATOMAlias"
	};
	func = function(self, hPlayer, sFilter)
		return self:ListAliases(hPlayer, sFilter)
	end
});

---------------------------------------------------------------
-- lookup <target>, Sends info about selected player to your Console
---------------------------------------------------------------

NewCommand({
	Name 	= "lookup",
	Access	= MODERATOR,
	Description = "Sends info about selected player to your Console",
	Console = true,
	Args = {
		{ "Target", "The target player", Required = true, Target = true, AcceptSelf = true, AcceptALL = false };
	--	{ "Amount", "Will adjust position to terrain height", Required = true, Integer = true };
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	};
	func = function(self, player, Target)--, Amount)--, FollowTerrain)
		return true, localLookUp(self, player, Target);
	end;
});


---------------------------------------------------------------
-- players <Index>, Lists information of all Online Players to your Console
---------------------------------------------------------------

NewCommand({
	Name 	= "players",
	Access	= MODERATOR,
	Description = "Lists information of all Online Players to your Console",
	Console = true,
	Args = {
		{ "Index", "Index of the Player List", Optional = true, Integer = true, PositiveNumber = true };
	--	{ "Amount", "Will adjust position to terrain height", Required = true, Integer = true };
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	};
	func = function(self, player, iIndex)
		local aGroupData, sColor, sAccess, sIP, sProfile, iChannel, sPort, sHost, sCountry, sAccount, sTeam
		local aPlayers = GetPlayers()
		
		local aTeams = {
			[0] = "$9SPEC",
			[1] = "$7NK",
			[2] = "$5US"
		};
		
		local hIndex = (iIndex and aPlayers[iIndex])
		if (not hIndex) then

			SendMsg(CONSOLE, player, "$9================================================================================================================");
			SendMsg(CONSOLE, player, "$9 #     Slot  Name                  Team  Access       ID        CC IP               Port    Host    ");
			SendMsg(CONSOLE, player, "$9================================================================================================================");
			
			local iCounter = 0
			local sCounter = "0"
		
			for i, hTarget in ipairs(aPlayers) do
				iCounter = iCounter + 1
				
				sTeam = aTeams[hTarget:GetTeam()]
				if (g_gameRules.class == "InstantAction") then
					if (hTarget:IsSpectating()) then
						sTeam = "$9SPEC" else
							sTeam = "$5INGM" end
				end
				
				aGroupData 	= hTarget:GetGroupData()
				sColor 		= aGroupData[4]
				sAccess 	= string.format("%s%s", sColor, aGroupData[2])
				sIP 		= checkVar(hTarget:GetIP(), 		string.UNKNOWN)
				sProfile 	= checkVar(hTarget:GetProfile(), 	string.UNKNOWN)
				iChannel 	= checkVar(hTarget:GetChannel(),	string.UNKNOWN)
				sPort 		= checkVar(hTarget:GetPort(), 		string.UNKNOWN)
				sHost 		= checkVar(hTarget:GetHostName(),	string.UNKNOWN)
				sCountry 	= checkVar(hTarget:GetCountryCode(),string.UNKNOWN)
				sAccount 	= checkVar(hTarget.accountname,		string.UNKNOWN)
				sName 		= string.sub(hTarget:GetName(), 0, 21)
				
				SendMsg(CONSOLE, player, string.format("$9[$1%s$9] ($1%s$9) $1%s $9%s $9(%s $9: $4%s$9) <$8%s$9>$8%s $9($4%s $9: $1%s$9)]",
					string.rspace(iCounter, 3),
					string.rspace(iChannel, 4),
					string.rspace(sName, 21),
					string.rspace(sTeam, 4, string.COLOR_CODE),
					string.rspace(sAccess, 12),
					string.rspace(sProfile, 7),
					string.rspace(sCountry, 2),
					string.rspace(sIP, 15),
					string.rspace(sPort, 5),
					string.rspace(sHost, 18)
					
				))
				-- SendMsg(CONSOLE, player, "$9[$1" .. string.rspace(sCounter, 4) .. "$9] ($1".. tplayer:GetChannel() .. repStr(4, tplayer:GetChannel()) .. "$9) $5" .. tplayer:GetName():sub(0,21) .. repStr(21, tplayer:GetName():sub(0,21)) .. " $9" .. sTeam .. " $9(" .. Color .. Access .. repStr(11, Access) .. " $9: $4" .. Profile .. repStr(7, Profile) .. "$9) $8" .. IP .. repStr(15, IP) .. " $9($4" .. Port .. repStr(5, Port) .. " $9: $9" .. Host .. repStr(20, Host) .. "$9)]")
			end;
			SendMsg(CONSOLE, player, "$9================================================================================================================");
		else
			localLookUp(self, player, hIndex)
		end
	end
});

----------------------------------------------------------------------
-- !fpscap

NewCommand({
	Name 	= "fpscap",
	Access	= ADMINISTRATOR,
	Description = "Sets an FPS Cap",
	Console = true,
	Args = {
		{ "Limit", "Sets the Maximum Allowed FPS", Required = false, Optional = true, Integer = true, Range = { 0, 1000 } };
	--	{ "FollowTerrain", "Will adjust position to terrain height", Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Limit)--, FollowTerrain)
		local function toFps(num)
			return (1/num)*-1;
		end;
		local c = System.GetCVar("fixed_time_step");
		if (not Limit or not tonumber(Limit)) then
			SendMsg(CHAT_ATOM, player, "(FPSCAP: Current CAP %d FPS)", (c == 0 and 0 or toFps(c)));
			return true;
		elseif (Limit == 0) then
			if (c == 0) then
				return false, "FPS Cap Already disabled";
			end;
			SendMsg(CHAT_ATOM, player, "(FPSCAP: FPS Cap Disabled)");
			ATOMDLL:ForceSetCVar("fixed_time_step", "0");
			return true;
		end;
		ORIG_CVARS = ORIG_CVARS or {};
		ORIG_CVARS["fixed_time_step"] = ORIG_CVARS["fixed_time_step"] or c;
		ATOMDLL:ForceSetCVar("fixed_time_step", tostr(toFps(Limit)));
		SendMsg(CHAT_ATOM, player, "(FPSCAP: FPS CAP set to %d)", Limit);
	end;
});