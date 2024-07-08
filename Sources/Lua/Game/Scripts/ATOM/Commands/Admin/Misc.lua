------------------------------------------------------------------------
-- !testeffect

NewCommand({
	Name 	= "testeffect",
	Access	= ADMINISTRATOR,
	Description = "Tests one of the new ATOM-Client Effects",
	Console = true,
	Args = {
		{ "Name", "name of the effect", Required = true},
		{ "Distance", "Distance", Integer = true, PositiveNumber = true, Default = 50 },
		{ "Scale", "Scale", Integer = true, PositiveNumber = true, Default = 1, Range = { 0.1, 25 } },
	--	{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'g_utils',
	};
	func = function(self, player, name, dist)
		SpawnEffect(name, player:CalcSpawnPos(dist, 0), g_Vectors.up, scale);
		Debug("Effect",name,"spawned");
	end;
});


------------------------------------------------------------------------
-- !logsize

NewCommand({
	Name 	= "logsize",
	Access	= ADMINISTRATOR,
	Description = "Shows current size of the Server.log file",
	Console = true,
	Args = {
	--	{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMLog',
	};
	func = function(self, player)
		self:CheckServerLog()
		SendMsg(CHAT_ATOM, player, "Log Size is %0.2fMB (Grew by %0.2fMB in the last Hour)", (self.logSize or 0.00) / ONE_MB, (LOG_GROWTH or 0.00) / ONE_MB);
	end;
});


------------------------------------------------------------------------
-- !clean

NewCommand({
	Name 	= "clean",
	Access	= ADMINISTRATOR,
	Description = "Cleans the server from shit objects",
	Console = true,
	Args = {
	--	{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMLog',
	};
	func = function(self, player)
		local flushed = 0;
		for i, v in pairs(System.GetEntitiesByClass("GUI"))do
			if (not v.chair) then
				System.RemoveEntity(v.id);
				flushed = flushed + 1;
			end;
		end;
		ATOMSetup:OnMapStart(ATOM:GetMapName(true), ATOM:GetMapName());
		SendMsg(CHAT_ATOM, player, "[ %s ] - Trash Objects flushed down the toilet!", flushed);
	end;
});

------------------------------------------------------------------------
-- !setaccess

NewCommand({
	Name 	= "setaccess",
	Access	= ADMINISTRATOR,
	Description = "Changes the Access the player has on the server",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
		{ "Access", "The Access you wish to grant the Player" };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, Target, Access)
		return self:NewUser(player, Target, Access);
	end;
});

------------------------------------------------------------------------
-- !tempaccess

NewCommand({
	Name 	= "tempaccess",
	Access	= ADMINISTRATOR,
	Description = "Temporarily Changes the Access a player has on the server",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, EqualAccess = true, Required = true, Target = true, NotPlayer = true };
		{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true, Range = { GetLowestAccess(), GetHighestAccess() } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, Target, Access)
		return self:TempAccess(player, Target, Access);
	end;
});

------------------------------------------------------------------------
-- !deluser

NewCommand({
	Name 	= "deluser",
	Access	= ADMINISTRATOR,
	Description = "Changes the Access the player has on the server",
	Console = true,
	Args = {
		{ "Player/ID", "The Name/ID of the User you wish to remove", Required = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, ID)
		return self:DelUser(player, ID);
	end;
});
------------------------------------------------------------------------
-- !adduser

NewCommand({
	Name 	= "adduser",
	Access	= ADMINISTRATOR,
	Description = "Manually registers a new user into the system",
	Console = true,
	Args = {
		{ "Name", "The Name of the User you wish to add", Required = true };
		{ "ID", "The ID of the User you wish to add", Required = true };
		{ "Access", "The Access the user will have", Required = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, Name, ID, Access)
		--SysLog("regu %s/%s/%s", Name, ID, Access)
		return self:RegUser(player, Name, ID, Access);
	end;
});

------------------------------------------------------------------------
-- !svcon

NewCommand({
	Name 	= "svcon",
	Access	= ADMINISTRATOR,
	Description = "Sends server console messages to your console",
	Console = true,
	Args = {
		{ "Player", "The Name of the player to toggle Sv Console on", Target = true, EqualAccess = true, Option = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, t)
		(t or player).ServerConsole = not ((t or player).ServerConsole);
		SendMsg(CHAT_ATOM, player, "(SERVER:CONSOLE - %s)", (t or player).ServerConsole and "ENABLED" or "DISABLED");
	end;
});

------------------------------------------------------------------------
-- !regusers

NewCommand({
	Name 	= "regusers",
	Access	= ADMINISTRATOR,
	Description = "Shows all Registered Users",
	Console = true,
	Args = {
	--	{ "Player/ID", "The Name/ID of the User you wish to remove", Required = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player)
		return self:ListUsers(player);
	end;
});

------------------------------------------------------------------------
-- !rcadump

NewCommand({
	Name 	= "rcadump",
	Access	= ADMINISTRATOR,
	Description = "Dumps all code executed on clients",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
	};
	func = function(self, player)
		return self:DumpCode(player)
	end
})

------------------------------------------------------------------------
-- !plugins

NewCommand({
	Name 	= "plugins",
	Access	= ADMINISTRATOR,
	Description = "Shows all loaded plugins and commands",
	Console = true,
	Args = {
	--	{ "Player/ID", "The Name/ID of the User you wish to remove", Required = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player)
		local plugins = self:GetPlugins();
		if (table.count(plugins) < 1) then
			return false, "no plugins found";
		end;
		local total = 0;
		local allTotal = 0;
		table.sort(plugins, function(a,b) return a[3] < b[3]; end);
		SendMsg(CONSOLE, player, "$9========================================================================");
		SendMsg(CONSOLE, player, "$9[ ID   Name                             Loaded     Type       Size     ]");
		SendMsg(CONSOLE, player, "$9========================================================================");
		for i, plugin in pairs(plugins) do
			SendMsg(CONSOLE, player, "$9[ $1%s$9 ] $9%s$9 ] %s$9 ] $1%s$9 ] %s$9 ]",
											string.lenprint(i, 2),
													string.lenprint(plugin[3], 30),
															string.lenprint((plugin[2] and "$3True" or "$4False"), 8),
																	string.lenprint(plugin[1], 8),
																			string.lenprint(toMB(plugin[4]or 0, true, true), 8)
			);
			total = total + (plugin[4] or 0);
		end;
		SendMsg(CONSOLE, player, "$9[                                                             %s ]", string.lenprint(toMB(total, true, true), 8));
		
		allTotal = total;
		total = 0;
		local commands = self:GetCommands();
		--table.sort(commands, function(a,b) return a[6] < b[6]; end);
		if (table.count(commands) > 1) then
			SendMsg(CONSOLE, player, "$9========================================================================");
			for i, command in pairs(commands) do
				SendMsg(CONSOLE, player, "$9[ $1%s$9 ] $9%s$9 ] %s$9 ] $1%s$9 ] %s$9 ]",
												string.lenprint(i, 2),
														string.lenprint("(" .. command[5]:gsub("/","") .. ") " .. command[3], 30),
																string.lenprint((command[2] and "$3True" or "$4False"), 8),
																		string.lenprint(command[1], 8),
																				string.lenprint(toMB(command[4]or 0, true, true), 8)
				);
				total = total + (command[4] or 0);
			end;
			SendMsg(CONSOLE, player, "$9[                                                             %s ]", string.lenprint(toMB(total, true, true), 8));
		end;
		
		allTotal = total;
		total = 0;
		local includes = self:GetIncludes();
		if (table.count(commands) > 1) then
			SendMsg(CONSOLE, player, "$9========================================================================");
			for i, include in pairs(includes) do
				SendMsg(CONSOLE, player, "$9[ $1%s$9 ] $9%s$9 ] %s$9 ] $1%s$9 ] %s$9 ]",
												string.lenprint(i, 2),
														string.lenprint(include[3], 30),
																string.lenprint((include[2] and "$3True" or "$4False"), 8),
																		string.lenprint(include[1], 8),
																				string.lenprint(toMB(include[4]or 0, true, true), 8)
				);
				total = total + (include[4] or 0);
			end;
		end
		SendMsg(CONSOLE, player, "$9========================================================================");
		SendMsg(CONSOLE, player, "$9[                                                             %s ]", string.lenprint(toMB(allTotal+total, true, true), 8));
		SendMsg(CONSOLE, player, "$9========================================================================");
	end;
});
------------------------------------------------------------------------
-- !events

NewCommand({
	Name 	= "events",
	Access	= ADMINISTRATOR,
	Description = "Shows all Registered Events",
	Console = true,
	Args = {
	--	{ "Player/ID", "The Name/ID of the User you wish to remove", Required = true };
	--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMBroadCaster',
	};
	func = function(self, player)
		local events = self:GetRegisteredEvents();
		if (arrSize(events) < 1) then
			return false, "no registered events found";
		end;
		local function localAvg(t)
			local a = 0;
			for i, v in pairs(t) do
				a = a + (v[3] or 0);
			end;
			return a == 0 and 0 or (a / arrSize(t) or 0);
		end;
		local function localCount(t)
			local a = 0;
			for i, v in pairs(t) do
				a = a + (v[4] or 0);
			end;
			return a;
		end;
		local newEvents = {};
		for i, event in pairs(events) do
			table.insert(newEvents, {
				i, 
				arrSize(event),
				localAvg(event),
				localCount(event),
			});
		end;
		SendMsg(CONSOLE, player, "$9======================================================================");
		SendMsg(CONSOLE, player, "$9[ ID   Name                             Events    Avg Time  Errors   ]");
		SendMsg(CONSOLE, player, "$9======================================================================");
		for i, event in pairs(newEvents) do
			SendMsg(CONSOLE, player, "$9[ $1%s$9 ] $1%s$9 ] $%d%s$9 ] $%d%0.4fs$9 ] %s$9 ]",
											string.lenprint(i, 2),
													string.lenprint(event[1], 30),
															(event[2]<2 and 3 or event[2]>5 and 4 or event[2]<=2 and 6 or event[2]<5 and 8 or event[2]>5 and 4 or 5),
															string.lenprint(event[2], 7),
																	(event[3]<0.001 and 3 or event[3]<0.01 and 6 or event[3]<0.08 and 8 or 4),
																	string.lenprint(event[3], 12),
																		string.lenprint(event[4], 8)
			);
		end;
		SendMsg(CONSOLE, player, "$9======================================================================");
	end;
});

------------------------------------------------------------------------
-- ?nocmd

NewCommand({
	Name 	= "nocmd",
	Access	= ADMINISTRATOR,
	Description = "Prevents specified player from using specified or all commands",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to disable commands on", Required = true, Target = true, NotPlayer = true, EqualAccess = true };
		{ "Command", "The Name of the command", Optional = true };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, target, cmdName)
		if (not cmdName) then
			if (not target.NoCommands) then
				target.NoCommands = true;
			else
				target.NoCommands = false;
			end;
			SendMsg(CHAT_ATOM, player, "(%s: %s)", target:GetName(), (target.NoCommands and "Commands blocked" or "Command block disabled"));
			return true;
		else
			local command = self:GetCommand(cmdName);
			if (not command) then
				local status, guessed = self:GetCommandByGuess(cmdName, player:GetAccess());
				if (status == 1 or status == 2) then
					command = self:GetCommand(guessed[1]);
				elseif (status == 3) then
					self:ListMatches(player, guessed, true);
					return false, "invalid command", self:Msg(player, eFR_ManyMatches, cmdName, arrSize(guessed), true);
				end;
			end;
			if (not command) then
				return false, "unknown command";
			end;
			if (not target.NoCommand) then
				target.NoCommand = {};
			end
			if (not target.NoCommand[command[1]]) then
				target.NoCommand[command[1]] = true;
			else
				target.NoCommand[command[1]] = false;
			end;
			SendMsg(CHAT_ATOM, player, "(%s: %s%s)", command[1]:upper(), (target.NoCommand[command[1]] and "Blocked for " or "Unblocked for "), target:GetName());
			return true;
		end;
	end;
});

------------------------------------------------------------------------
-- ?nospec

NewCommand({
	Name 	= "nospec",
	Access	= ADMINISTRATOR,
	Description = "Prevents specified player from spectating",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to disable spectating on", Required = true, Target = true, EqualAccess = true };
		{ "Target", "Prevents player from spectating this player", Optional = true, Target = true, EqualAccess = true };
	};
	Properties = {
	--	Self = 'ATOMCommands',
	};
	func = function(self, player, target)
		if target then
			if (target.id == player.id) then
				return false, "specify different player";
			end;
			player.NoSpecThese = player.NoSpecThese or {};
			if (not player.NoSpecThese[target.id]) then
				player.NoSpecThese[target.id] = true;
				if (player:GetSpectatorTarget() and player:GetSpectatorTarget().id == target.id) then
					g_gameRules.Server.OnChangeSpectatorMode(g_gameRules, player.id, 1, nil);
				end;
			else
				player.NoSpecThese[target.id] = nil;
			end;
			SendMsg(CHAT_ATOM, self, "(NOSPEC: %s %s on %s)", (player.NoSpecThese[target.id] and "Enabled for " or "Disbaled for "), player:GetName(), target:GetName());
			return true;
		else
			if (not player.NoSpec) then
				player.NoSpec = true;
			else
				player.NoSpec = false;
			end;
			if (player:IsSpectating()) then
				g_utils:StopSpec(player);
			end;
			SendMsg(CHAT_ATOM, self, "(NOSPEC: %s%s)", (player.NoSpec and "Enabled for " or "Disbaled for "), player:GetName());
			return true;
		end
	end;
});

------------------------------------------------------------------------
-- ?autorevive

NewCommand({
	Name 	= "autorevive",
	Access	= ADMINISTRATOR,
	Description = "Automatically revives a player as soon as he dies (dev)",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to enable AR on", Required = true, Target = true, EqualAccess = true, AcceptSelf = true, AcceptAll = true };
		{ "AtSpawn", "Will revive player at random spawnpoint instead of death position", Optional = true };
	};
	Properties = {
	--	Self = 'ATOMCommands',
	};
	func = function(player, target, spawn)
		if (target == "all") then
			if (not AutoRevive) then
				AutoRevive = true;
			else
				AutoRevive = false;
			end;
			AutoReviveSpawnPoint = spawn ~= nil;
			SendMsg(CHAT_ATOM, player, "(AUTOREVIVE: %s on %s at %s)", (AutoRevive and "Enabled" or "Disbaled"), "All Players", AutoReviveSpawnPoint and "Spawn Point" or "Death Pos");
			return true;
		else
			if (not target.AutoRevive) then
				target.AutoRevive = true;
			else
				target.AutoRevive = false;
			end;
			target.AutoReviveSpawnPoint = spawn ~= nil;
			SendMsg(CHAT_ATOM, player, "(AUTOREVIVE: %s on %s at %s)", (target.AutoRevive and "Enabled" or "Disbaled"), target:GetName(), target.AutoReviveSpawnPoint and "Spawn Point" or "Death Pos");
			return true;
		end;
	end;
});

------------------------------------------------------------------------
-- ?autorevive

NewCommand({
	Name 	= "autogun",
	Access	= ADMINISTRATOR,
	Description = "Automatically enables specified special gun on revive",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to enable AR on", Required = true, Target = true, EqualAccess = true, AcceptSelf = true, AcceptAll = true };
		{ "Gun", "The name of the gun to enable on revive", Optional = true };
	};
	Properties = {
		Self = 'GunSystem',
	};
	func = function(self, player, target, gunName)
		local theGun = gunName~=nil and self:GetGun(gunName) or false;
		if (theGun ~= false) then
			ListToConsole(player, self.Guns, "Available Guns", true);
			SendMsg(CHAT_ATOM, player, "Open Console to view the List of [ %d ] available Guns!", self:GetGunCount());
			return true;
		end;
		if (target == "all") then
			--Debug("GUN >>",theGun)
			if (theGun) then
			--Debug("GUN !!!!>",theGun)
				AutoGun = theGun;
			else
				AutoGun = nil;
			end;
			SendMsg(CHAT_ATOM, player, "(AUTOGUN: %s%s on %s)", (AutoGun and AutoGun .. " " or ""), (AutoGun and "Enabled" or "Disbaled"), "All Players");
			return true;
		else
			if (theGun) then
				target.AutoGun = theGun;
			else
				target.AutoGun = nil;
			end;
			SendMsg(CHAT_ATOM, player, "(AUTOGUN: %s%s on %s)", (target.AutoGun and target.AutoGun .. " " or ""), (target.AutoGun and "Enabled" or "Disbaled"), target:GetName());
			return true;
		end;
	end;
});