-------------------------------------------
-- !autowarn

NewCommand({
	Name 	= "autowarn",
	Access	= MODERATOR,
	Description = "Adds a warning for specified ID",
	Console = true,
	Args = {
		{ "Player", nil, Required = true };
		{ "Reason", nil, Optional = true, Concat = true, Length = { "5", "25" }};
	};
	Properties = {
		Self = 'ATOMPunish.AutoWarns',
	};
	func = function(self, hPlayer, idTarget, sReason)
		
		----------
		local hTarget = GetPlayer(idTarget) or GetPlayerByProfileID(idTarget)
		if (hTarget) then
			return false, "use !warn for online players"
		else
			hTarget = idTarget
			local iTargetAccess = ATOM_Usergroups:GetAccessByID(hTarget)
			if (iTargetAccess and iTargetAccess >= hPlayer:GetAccess()) then
				return false, "Insufficient Access" end 
		end
	
		----------
		return self:Warn(hPlayer, hTarget, sReason)
	end;
});
