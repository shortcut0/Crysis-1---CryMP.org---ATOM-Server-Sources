-------------------------------------------------------------------
-- !reports

NewCommand({
	Name 	= "reports",
	Access	= MODERATOR,
	Console = true,
	Description = "Sends the list of reported players to your console";
	Args = {
		{ "Index",	"The Index of the Ban List" };
		{ "Option",	"Option"	};
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
		IgnoreSuspension = true
	};
	func = function(self, player, i, o)
		return self:ListReports(player, i, o);
	end;
});




--**********************************************************************
--** !mute <player>, <duration>, <reason>, mutes a player
--			the name of the target
--					the duration
--                               the reason of the action
--**********************************************************************

NewCommand({
	Name 	= "mute",
	Access	= MODERATOR,
	Description = "Temporarily Mutes a Player",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = true, Required = true };
		{ "Time",	nil	};
		{ "Reason", nil	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMMute',
		IgnoreSuspension = true
	};
	func = function(self, player, target, time, ...)
		local reason = tableConcat({...}, " ");
		if (emptyString(reason)) then
			reason = "Admin Decision";
		end;
		return self:MutePlayer(player, target, time, reason)
	end;
});

--**********************************************************************
--** !unmute <name>, <reason>, removes a mute from the system
--**    	 name of the target
--**				optional, unmute reason 
--**********************************************************************

NewCommand({
	Name 	= "unmute",
	Access	= MODERATOR,
	Description = "Removes a mute from the System",
	Console = true,
	Args = {
		{ "MuteName",	nil, Required = true };
		{ "Reason",		nil	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMMute',
		IgnoreSuspension = true
	};
	func = function(self, player, banName, ...)
		local reason = tableConcat({...}, " ");
		if (emptyString(reason)) then
			reason = "Admin Decision";
		end;
		return self:UnmutePlayer(player, banName, reason)
	end;
});


--**********************************************************************
--** !mutes <index>, <option>, lists the mutes to players console
--**    	index of the mute list
--**				option
--**********************************************************************

NewCommand({
	Name 	= "mutes",
	Access	= MODERATOR,
	Description = "Lists all Mutes to your console",
	Console = true,
	Args = {
		{ "Index",	"The Index of the Mute List" };
		{ "Option",	"Option"	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMMute',
		IgnoreSuspension = true
	};
	func = function(self, player, i, o)
		return self:ListMutes(player, i, o);
	end;
});


--**********************************************************************
--** !kick <player>, <reason>, lists the mutes to players console
--**    	name of the target 
--**				  reason for the action
--**********************************************************************

NewCommand({
	Name 	= "kick",
	Access	= MODERATOR,
	Description = "Kicks a player from the server",
	Console = true,
	Args = {
		{ "Player",	"The name of the player you wish to have removed from the server", Target = true, NotPlayer = true, MaxAccess = ADMINISTRATOR, EqualAccess = true, Required = true };
		{ "Reason",	"The Reason for your Action", Concat = true	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMPunish',
		Hidden = false;
		IgnoreSuspension = true
	};
	func = function(self, player, Target, Reason)
		return self:KickPlayer(player, Target, Reason);
	end;
});


-----------------------------------------
--  !jailplayer <player>, <reason>

NewCommand({
	Name 	= "jailplayer",
	Access	= MODERATOR,
	Description = "Jails a player hard",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = false, Required = true };
		{ "Time", nil, Integer = true, Default = 180, PositiveNumber = true };
		{ "Reason", nil, Optional = true, Concat = true, Default = "Admin Decision" };
	};
	Properties = {
		Self = 'ATOMJail',
	};
	func = function(self, player, target, time, reason)
		local status, message = self:JailPlayer(target, time, checkString(reason, "Admin Decision"));
		if (not status) then
			return false, message;
		end;
		if (player ~= target) then 
			SendMsg(CHAT_ATOM, player, "(%s: Has been Jailed hard)", target:GetName()); 
		end;
	end;
});

-----------------------------------------
--  !unjailplayer <player>

NewCommand({
	Name 	= "unjailplayer",
	Access	= MODERATOR,
	Description = "Unjails a player",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = false, Required = true };
		{ "Reason", nil, Required = false, Concat = true };
	};
	Properties = {
		Self = 'ATOMJail',
	};
	func = function(self, player, target, reason)
		if (emptyString(reason)) then
			return false, "specify valid reason"
		end;
		local status, message = self:UnJailPlayer(target, reason);
		if (not status) then
			return false, message;
		end;
		if (player ~= target) then 
			SendMsg(CHAT_ATOM, player, "(%s: Has been Unjailed)", target:GetName()); 
		end;
	end;
});



--**********************************************************************
--** !warn <player>, <reason>, warns a player
--			the name of the target
--                    the reason of the action
--**********************************************************************

NewCommand({
	Name 	= "warn",
	Access	= MODERATOR,
	Description = "Warns a Player",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = fa, Required = true };
		{ "Reason", nil, Required = true, Concat = true, Length = { "5", "25" }};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMWarn',
		IgnoreSuspension = true
	};
	func = function(self, player, target, reason)
		if (emptyString(reason)) then
			return false, "specify valid reason"
		end;
		return self:WarnPlayer(player, target, reason)
	end;
});


--**********************************************************************
--** !warns <index>, <index>, <option>, lists the warns to players console
--**********************************************************************

NewCommand({
	Name 	= "warns",
	Access	= MODERATOR,
	Description = "Lists all Warns to your Console",
	Console = true,
	Args = {
		{ "Index",	"The Index of the Warn List" };
		{ "Index",	"The Index of the Index of the List" };
		{ "Option",	"Option"	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMWarn',
		IgnoreSuspension = true
	};
	func = function(self, player, i, y, o)
		return self:ListWarns(player, i, y, o);
	end
});