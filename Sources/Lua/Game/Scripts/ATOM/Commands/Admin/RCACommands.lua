--**********************************************************************
--** !install, Starts to Install the ATOM Client on Specified Player
--**********************************************************************

NewCommand({
	Name 	= "install",
	Access	= ADMINISTRATOR,
	Description = "Starts to Install the ATOM Client on Specified Player",
	Console = true,
	Args = {
		{ "Target", "The Player you wish to install the client on", Optional = true, AcceptSelf = true, AcceptAll = true, Target = true };
	};
	Properties = {
		Self = 'RCA',
	};
	func = function(self, player, Target)
		return self:InstallOn(player, Target);
	end;
});

--**********************************************************************
--** !togglerca, Starts to Install the ATOM Client on Specified Player
--**********************************************************************

NewCommand({
	Name 	= "togglerca",
	Access	= ADMINISTRATOR,
	Description = "Toggles RCA Client",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
	};
	func = function(self, player)
		RCA_ENABLED = not RCA_ENABLED
		SendMsg(CHAT_ATOM, player, "RCA Enabled: %s", tostring(RCA_ENABLED))
	end;
});

--**********************************************************************
--** !atompack <Player>, Equips a player with a ATOMPack
--**********************************************************************

NewCommand({
	Name 	= "atompack",
	Access	= MODERATOR,
	Description = "Equips a player with a ATOMPack",
	Console = true,
	Args = {
		{ "Target", "The Player you wish to give the ATOMPack", Optional = true, AcceptSelf = true, AcceptAll = true, Target = true };
	};
	Properties = {
		Self = 'ATOMPack',
	};
	func = function(self, player, Target)
	
		local t = Target or player;
		
		if (t.hasJetPack) then
			self:Remove(t);
			if (samePlayer(player, t)) then
				SendMsg(CHAT_ATOM, player, "(ATOMPACK: Disabled)");
			else
				SendMsg(CHAT_ATOM, t, "(ATOMPACK: Disabled)");
				SendMsg(CHAT_ATOM, player, "(ATOMPACK: Disabled on %s)", t:GetName());
			end;
		else
			self:Add(t);
			if (samePlayer(player, t)) then
				SendMsg(CHAT_ATOM, player, "(ATOMPACK: Enabled)");
			else
				SendMsg(CHAT_ATOM, t, "(ATOMPACK: Enabled)");
				SendMsg(CHAT_ATOM, player, "(ATOMPACK: Enabled on %s)", t:GetName());
			end;
		end;
	end;
});

---------------------------------------------------------------------
-- !flymode <Player>, Toggles flymode on yourself or specified player

NewCommand({
	Name 	= "flymode",
	Access	= CREATOR,
	Description = "Equips a player with a ATOMPack",
	Console = true,
	Args = {
		{ "Target", "The Player you wish to give the ATOMPack", Optional = true, AcceptSelf = true, AcceptAll = true, Target = true, EqualAccess = true, Access = MODERATOR };
	};
	Properties = {
		Self = 'ATOMPack',
	};
	func = function(self, player, Target)
		if (samePlayer(player, Target)) then
			if (player.FlyMode_Enabled) then
				player.FlyMode_Enabled = false;
				ExecuteOnPlayer(player, [[ATOMClient:FlyMode(false);]]);
			else
				player.FlyMode_Enabled = true;
				ExecuteOnPlayer(player, [[ATOMClient:FlyMode(true);]]);
			end;
			SendMsg(CHAT_ATOM, player, "(FLYMODE: %s)", player.FlyMode_Enabled and "ENABLED" or "DISABLED");
		elseif (Target == "all") then
			if (FLY_MODE) then
				FLY_MODE = false;
				ExecuteOnAll([[ATOMClient:FlyMode(false);]]);
			else
				FLY_MODE = true;
				ExecuteOnAll([[ATOMClient:FlyMode(true);]]);
			end;
			SendMsg(CENTER, ALL, "(FLYMODE: %s)", FLY_MODE and "ENABLED" or "DISABLED");
			SendMsg(CHAT_ATOM, player, "(FLYMODE: %s on %s)", FLY_MODE and "ENABLED" or "DISABLED", "All Players");
		else
			if (Target.FlyMode_Enabled) then
				Target.FlyMode_Enabled = false;
				ExecuteOnPlayer(Target, [[ATOMClient:FlyMode(false);]]);
			else
				Target.FlyMode_Enabled = true;
				ExecuteOnPlayer(Target, [[ATOMClient:FlyMode(true);]]);
			end;
			SendMsg(CENTER, Target, "(FLYMODE: %s)", Target.FlyMode_Enabled and "ENABLED" or "DISABLED");
			SendMsg(CHAT_ATOM, player, "(FLYMODE: %s on %s)", Target.FlyMode_Enabled and "ENABLED" or "DISABLED", Target:GetName());
		end;
	end;
});

--**********************************************************************
--** !atompacks, Toggles ATOMPacks for All Players
--**********************************************************************

NewCommand({
	Name 	= "atompacks",
	Access	= MODERATOR,
	Description = "Toggles ATOMPacks for All Players",
	Console = true,
	Args = {
	--	{ "Target", "The Player you wish to give the ATOMPack", Optional = true, AcceptSelf = true, AcceptAll = true, Target = true };
	};
	Properties = {
		Self = 'ATOMPack',
	};
	func = function(self, player, Target)
		ATOMPACK_PARTY = not ATOMPACK_PARTY;
		SendMsg(CHAT_ATOM, player, "(ATOMPACKS: " .. (ATOMPACK_PARTY and "Enabled" or "Disabled") .. ")");
		
		if (ATOMPACK_PARTY) then
			for i, tplayer in pairs(GetPlayers()or{}) do
				self:Add(tplayer);
			end;
		end;
	end;
});

------------------------------------------------------------------------
-- !wattach, Toggles Weapon Attaching on Players backs

NewCommand({
	Name 	= "wattach",
	Access	= MODERATOR,
	Description = "Toggles Weapon Attaching on Players backs",
	Console = true,
	Args = {
	--	{ "Target", "The Player you wish to give the ATOMPack", Optional = true, AcceptSelf = true, AcceptAll = true, Target = true };
	};
	Properties = {
		Self = 'ATOMAttach',
	};
	func = function(self, player, Target)
		ATOM_ATTACH = not ATOM_ATTACH;
		SendMsg(CHAT_ATOM, player, "(ATTACH: " .. (ATOM_ATTACH and "Enabled" or "Disabled") .. ")");
	end;
});