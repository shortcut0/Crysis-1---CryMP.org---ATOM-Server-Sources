--**********************************************************************
--** !silence <player>, Completely silences a player
--			the name of the target
--**********************************************************************

NewCommand({
	Name 	= "silence",
	Access	= SUPERADMIN,
	Description = "Completely silences a player",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = true, Required = true };
	};
	Properties = {
		Self = 'ATOMPunish.ATOMMute',
	};
	func = function(self, player, target, time, ...)
		if (not self:IsMuted(target)) then
			return false, "Target is not muted"
		end
		target.MegaMute = not target.MegaMute
		SendMsg(CHAT_MUTESYS, player, "(MegaMute: %s on %s)", (target.MegaMute and "Enabled" or "Disabled"), target:GetName())
		if (target.MegaMute) then
			SendMsg(CHAT_MUTESYS, target, "You have been Silenced and Admins will no longer see your blocked Messages")
		end
		return true
	end;
});

-----------------------------------------------------------------
-- Test Command

NewCommand({
	Name 	= "quietmode",
	Access	= SUPERADMIN,
	Description = "Hides messages from a specific player, but makes it look for them, as if they were still delivered to others",
	Console = true,
	Args = {
		{ "Player", nil, Target = true, NotPlayer = false, Required = true, EqualAccess = true };
	};
	Properties = {
	};
	func = function(self, hTarget)

		local sTarget = hTarget:GetName()
		hTarget.bHideAllMessages = (not hTarget.bHideAllMessages)
		if (hTarget.bHideAllMessages) then
			SendMsg(CHAT_ATOM, self, "(%s: Put into Quiet Mode)", sTarget)
			ATOMLog:LogMute("%s$9 Was put into Quiet Mode", sTarget)
		else
			SendMsg(CHAT_ATOM, self, "(%s: Quiet Mode disabled)", sTarget)
			ATOMLog:LogMute("Quiet Mode disabled for %s$9", sTarget)
		end

		return true
	end;
});


--**********************************************************************
--** !deny <slot>, Denies an active connection from joining this server
--**********************************************************************

NewCommand({
	Name 	= "deny",
	Access	= SUPERADMIN,
	Description = "Stops an active connection from joining this server",
	Console = true,
	Args = {
		{ "Slot", "The ID of the Connection", Integer = true, PositiveNumber = true };
		{ "Reason", "The reason for the denial", Optional = true, Concat = true, Default = "Admin Decision" };
	};
	Properties = {
		Self = 'ATOM',
	};
	func = function(self, player, channelId, sReason)
		local aActive = self.activeConnections
		if (not aActive or arrSize(aActive) == 0) then
			return false, "No active connections found" end
		
		----------
		local channelId = tonumber(channelId)
		local sReason = (sReason or "Connection Denied")
		
		----------
		if (aActive[channelId] ~= nil) then
			SendMsg(CHAT_ATOM, player, "(%s: Denied connection on slot %d)", self.activeConnections[channelId][2], channelId)
			ATOMLog:LogBan("Denied new connection on Slot %d $9($4%s$9)", channelId, sReason)
			ATOMDLL:Kick(channelId, sReason)
			self.activeConnections[channelId] = nil
		else
			return false, "invalid connection"
		end
		
		----------
		return true
	end;
});

--**********************************************************************
--** !loadban <name>, <ip>, <host>, <profile>, Manually adds a ban to the ban list
--**********************************************************************

NewCommand({
	Name 	= "loadban",
	Access	= SUPERADMIN,
	Description = " Manually adds a ban to the ban list",
	Console = true,
	Args = {
		{ "Name", "The Name of the Ban", Required = true };
		{ "Time", "The Duration of the Ban", Required = true };
		{ "Profile", "The Profile ID of the target", Required = true };
		{ "IP", "The IP Address of the target", Optional = true };
		{ "Host", "The Host Name of the target", Optional = true };
		{ "Extra", "The Extra identifier of the target", Optional = true };
	};
	Properties = {
		Self = 'ATOMPunish.ATOMBan',
	};
	func = function(self, player, name, time, profile, ip, host, extra)
		local time = time:lower() ~= "infinite" and ATOMPunish:ParseTime(time or self.cfg.DefaultBanTime, true) or "Infinite";
		--Debug("self.cfg.MaxBanTime",self.cfg.MaxBanTime)
		if (time ~= "Infinite" and tonumber(math_div(time, 86400)) > self.cfg.MaxBanTime) then
			time = tostr(self.cfg.MaxBanTime);
		end;
		if (self:WriteBan(name, ip, host, profile, extra, time, "Banned", "N/A", player:GetName())) then
			return true, self:Msg(eBM_Added, name, calcTime(time, true, unpack(GetTime_SMHD)), "Admin Decision");
		else
			return false, "player already banned";
		end;
	end;
});