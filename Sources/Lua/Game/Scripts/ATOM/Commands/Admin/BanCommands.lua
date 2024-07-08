---------------------------------------
-- !bancom

NewCommand({
	Name 	= "bancom",
	Access	= ADMINISTRATOR,
	Description = "Bans a user from using a specified command",
	Console = true,
	Args = {
		{ "idPlayer", "The name or ID of the target", Required = true };
		{ "sCommand", "The name of the command", Required = true };
		{ "sReason", "The reason for your action", Concat = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, hPlayer, idTarget, sCommand, sReason)
	
		----------
		local iAccess = hPlayer:GetAccess()
	
		----------
		local aCommand = self:GetCommand(sCommand);
		if (not aCommand) then
			local iStatus, aGuessed = self:GetCommandByGuess(sCommand, hPlayer:GetAccess());
			if (iStatus == 1 or iStatus == 2) then
				aCommand = self:GetCommand(aGuessed[1])
				
			elseif (iStatus == 3) then
				self:ListMatches(hPlayer, aGuessed, true)
				return false, "invalid command", self:Msg(hPlayer, eFR_ManyMatches, sCommand, table.count(aGuessed), true)
			end
		end
		
		----------
		if (not aCommand) then
			return false, "unknown command" end
		
		----------
		local hTarget = GetPlayer(idTarget)
		if (hTarget) then
			if (hTarget:GetAccess() >= hPlayer:GetAccess() and not hPlayer:IsOwner()) then
				return false, "Insufficient Access" end
		else
			hTarget = idTarget
			local iTargetAccess = ATOM_Usergroups:GetAccessByID(hTarget)
			if (iTargetAccess and iTargetAccess >= hPlayer:GetAccess() and not hPlayer:IsOwner()) then
				return false, "Insufficient Access" end 
		end
				
		----------
		return self:BanCommand(hPlayer, string.lower(aCommand[1]), hTarget, sReason)
	end;
});

---------------------------------------
-- !combans

NewCommand({
	Name 	= "combans",
	Access	= ADMINISTRATOR,
	Description = "Lists all Command bans to your console",
	Console = true,
	Args = {
		{ "iIndex", "The index of the ban list", Optional = true, Integer = true, PositiveNumber = true };
		{ "idPlayer", "The name or ID of the target", Optional = true };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, hPlayer, iIndex, idTarget)
		return self:ListBans(hPlayer, iIndex, idTarget) end
});

---------------------------------------
-- !unbancom

NewCommand({
	Name 	= "unbancom",
	Access	= ADMINISTRATOR,
	Description = "Removes a command ban",
	Console = true,
	Args = {
		{ "idPlayer", "The name or ID of the target", Required = true };
		{ "sCommand", "The name of the command", Required = true };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, hPlayer, idTarget, sCommand)
	
		----------
		local iAccess = hPlayer:GetAccess()
	
		----------
		local aCommand = self:GetCommand(sCommand);
		if (not aCommand) then
			local iStatus, aGuessed = self:GetCommandByGuess(sCommand, hPlayer:GetAccess());
			if (iStatus == 1 or iStatus == 2) then
				aCommand = self:GetCommand(aGuessed[1])
				
			elseif (iStatus == 3) then
				self:ListMatches(hPlayer, aGuessed, true)
				return false, "invalid command", self:Msg(hPlayer, eFR_ManyMatches, sCommand, table.count(aGuessed), true)
			end
		end
		
		----------
		if (not aCommand) then
			return false, "unknown command" end
		
		----------
		local hTarget = GetPlayer(idTarget)
		if (hTarget) then
			if (hTarget:GetAccess() >= hPlayer:GetAccess()) then
				return false, "Insufficient Access" end
		else
			hTarget = idTarget
			local iTargetAccess = ATOM_Usergroups:GetAccessByID(hTarget)
			if (iTargetAccess and iTargetAccess >= hPlayer:GetAccess()) then
				return false, "Insufficient Access" end 
		end
				
		----------
		return self:UnbanCommand(hPlayer, string.lower(aCommand[1]), hTarget)
	end;
});
