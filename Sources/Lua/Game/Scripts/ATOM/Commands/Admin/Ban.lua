--**********************************************************************
--** !ban <player>, <duration>, <reason>, bans a player from the server 
--			the name of the target
--					the duration
--                               the reason of the action
--**********************************************************************

NewCommand({
	Name 	= "ban",
	Access	= ADMINISTRATOR,
	Description = "Temporarily or permanently bans a player from the server",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = true, Required = true };
		{ "Time",	nil	};
		{ "Reason", nil	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMBan',
		IgnoreSuspension = true
	};
	func = function(self, player, target, time, ...)
		local reason = tableConcat({...}, " ");
		if (emptyString(reason)) then
			reason = "Admin Decision";
		end;
		return self:BanPlayer(player, target, time, reason)
	end;
});

--**********************************************************************
--** !unban <name>, <reason>, removes a ban from the ban system
--**    	 name of the target
--**				optional, unban reason 
--**********************************************************************

NewCommand({
	Name 	= "unban",
	Access	= ADMINISTRATOR,
	Description = "Removes a ban from the System",
	Console = true,
	Args = {
		{ "BanName",	nil, Required = true };
		{ "Reason",		nil	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMBan',
		IgnoreSuspension = true
	};
	func = function(self, player, banName, ...)
		local reason = tableConcat({...}, " ");
		if (emptyString(reason)) then
			reason = "Admin Decision";
		end;
		return self:UnbanPlayer(banName, reason)
	end;
});


--**********************************************************************
--** !bans <index>, <option>, lists the bans to players console
--**    	index of the ban list
--**				option
--**********************************************************************

NewCommand({
	Name 	= "bans",
	Access	= ADMINISTRATOR,
	Description = "Lists the bans to your console",
	Console = true,
	Args = {
		{ "Index",	"The Index of the Ban List" };
		{ "Option",	"Option"	};
	};
	Properties = {
		Self = 'ATOMPunish.ATOMBan',
		IgnoreSuspension = true
	};
	func = function(self, player, i, o)
		return self:ListBans(player, i, o);
	end;
});
