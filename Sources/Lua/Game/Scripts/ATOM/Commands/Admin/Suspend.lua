--**********************************************************************
--** !suspend
--**********************************************************************

NewCommand({
	Name 	= "suspend",
	Access	= ADMINISTRATOR,
	Description = "Temporarily or permanentely suspends a player from their server accesss",
	Console = true,
	Args = {
		{ "Player", nil, Required = true};
		{ "Time",	nil	};
		{ "Reason", nil	};
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, player, target, time, ...)
		local reason = tableConcat({...}, " ");
		if (emptyString(reason)) then
			reason = "Admin Decision";
		end;
		return self:SuspendPlayer(player, target, time, reason)
	end;
});