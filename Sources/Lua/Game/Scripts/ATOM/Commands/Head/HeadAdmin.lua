-------------------------------------------
-- !authtest

NewCommand({
	Name 	= "authtest",
	Access	= HEADADMIN,
	Description = "tests the new authorization system",
	Console = true,
	Args = {
	};
	Properties = {
		RequiredAuth = "TestAuth1234",
	};
	func = function(hPlayer)
		SendMsg(CHAT_ATOM, hPlayer, "(Auth: Ok)")
	end;
});

-------------------------------------------
-- !authlist

NewCommand({
	Name 	= "authlist",
	Access	= HEADADMIN,
	Description = "tests the new authorization system",
	Console = true,
	Args = {
		{ "Player", nil, Required = true, EqualAccess = true, Target = true, AcceptSelf = true };
	};
	Properties = {
		RequiredAuth = "ViewAuthList",
	};
	func = function(hPlayer, hTarget)

		SendMsg(CHAT_ATOM, hPlayer, "(%s: Open Console to view the Granted Authorizations)", hTarget:GetName())
		ListToConsole(hPlayer, hTarget.aGrantedAuths, "Granted Authorizations", true)

	end
});

-------------------------------------------
-- !setauth

NewCommand({
	Name 	= "setauth",
	Access	= HEADADMIN,
	Description = "changes a specifiy authoriration for a player",
	Console = true,
	Args = {
		{ "Player", nil, Required = true, EqualAccess = true, Target = true, AcceptSelf = true },
		{ "Auth", "The Name of the Authorization", Required = true },
		{ "Mode", "Status of the Authorization", Required = true }
	};
	Properties = {
		SkipAuth = DEVELOPER,
		RequiredAuth = "AuthModify",
	};
	func = function(hPlayer, hTarget, sAuth, sMode)


		local bEnable = string.matchex(sMode, "on", "1", "enable", "grant")
		local bDisable = string.matchex(sMode, "off", "0", "disable", "deactivate", "revoke")

		if (not (bEnable or bDisable)) then
			SendMsg(CHAT_ATOM, hPlayer, "(Possible Modes: <On/1/Enable>, <Off/0/Disable>)")
			return true
		end

		local sTarget = hTarget:GetName()
		local sAuthName = hTarget:GetAuthName(sAuth)

		local aGrant = { sAuth }
		local bAll = (sAuth == "all")
		local bTrusted = (sAuth == "trusted")

		if (bAll) then
			aGrant = hTarget:GetAuthList()
		end
		if (bTrusted) then
			aGrant = hTarget:GetAuthList(AUTHLIST_TRUSTED)
		end
		if (bEnable) then
			if (not (bAll or bTrusted) and hTarget:HasAuthorization(sAuth)) then
				return false, "player already has authorization " .. sAuthName
			end

			for i, sGrant in pairs(aGrant) do

				sAuthName = hTarget:GetAuthName(sGrant)
				if (not hTarget:HasAuthorization(sGrant)) then
					ATOMLog:LogUser(HEADADMIN, "%s$9 Was $3Granted Authorization $9($4%s$9)", sTarget, sAuthName)
					SendMsg(CHAT_ATOM, hPlayer, "(%s: Granted Authorization (%s))", sTarget, sAuthName)
					SendMsg({ CENTER, INFO }, hTarget, "(You Were Granted Authorization (%s))", sAuthName)
					hTarget:SetAuthorization(sGrant, true)
				end
			end
		else
			if (not (bAll or bTrusted) and not hTarget:HasAuthorization(sAuth)) then
				return false, "player does not have authorization " .. sAuthName
			end

			for i, sGrant in pairs(aGrant) do

				sAuthName = hTarget:GetAuthName(sGrant)

				if (hTarget:HasAuthorization(sGrant)) then
					ATOMLog:LogUser(HEADADMIN, "%s$9 Was $4Revoked Authorization $9($4%s$9)", sTarget, sAuthName)
					SendMsg(CHAT_ATOM, hPlayer, "(%s: Revoked Authorization (%s))", sTarget, sAuthName)
					SendMsg({ CENTER, INFO }, hTarget, "(Revoked Authorization (%s))", sAuthName)
					hTarget:SetAuthorization(sGrant, false)
				end
			end
		end

		return true
	end
});



---------------------------------------------------------------
-- !betafeatures, Toggles server beta features

NewCommand({
	Name 	= "betafeature",
	Access	= HEADADMIN,
	Console = true,
	Description = "Toggles server beta features",
	Args = {
		{ "Feature", "The name of the feature to toggle", Optional = true },
		{ "Mode", "The Status of the feature", Optional = true, Default = "" }
	},
	Properties = {
		Self = 'g_features',
	},
	func = function(self, hPlayer, sFeature, sMode)

		if (not sFeature or not GetBetaFeature(sFeature)) then
			--ListToConsole(hPlayer, self:GetFeatures(), "Server-Features", false, 1)
			local aFeatures = self:GetFeatures()
			if (table.count(aFeatures) == 0) then
				return false, "no features found"
			end

			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================");
			SendMsg(CONSOLE, hPlayer, "$9  $4Server-Features")
			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================");
			local iCurrent = 0
			local iTotal = table.count(aFeatures)
			local iMax = 5
			local sNewLine = ""

			for i, v in pairs(aFeatures) do
				iCurrent = iCurrent + 1

				sNewLine = "$1(" .. string.rspace(iCurrent, 2) .. ". $9" .. (v[eID_FeatureStatus] and "" or "$4") .. string.rspace(v[eID_FeatureName], 15) .. " $9(" .. string.rspace(v[eID_FeatureNameFriendly], 71) .. " | " .. (v[eID_FeatureStatus] and "$3" or "$4").. string.lspace(string.bool(v[eID_FeatureStatus], BTOSTRING_ACTIVATED), 11) .. "$9)"
				SendMsg(CONSOLE, hPlayer, "$9[ " .. string.rspace(sNewLine, 108)  .. " $9]")
				if (iCurrent == iTotal) then
					--sNewLine = "$1(" .. string.rspace(iCurrent + 1, 2) .. ". $9" .. string.rspace("!feature", 15) .. " (" .. string.rspace("On/1/Enable | Off/0/Disable", 71) .. " | " .. string.lspace("-", 11) .. ")"
					sNewLine = "$1Usage: !betafeature <name> (<1/on> or <0/off>)"
					SendMsg(CONSOLE, hPlayer, "$9[ " .. string.rspace(sNewLine, 110)  .. " $9]")
				end
			end
			SendMsg(CONSOLE, hPlayer, "$9================================================================================================================")

			SendMsg(CHAT_ATOM, hPlayer, "Open Console to view the list of available features")
			return true
		end

		local bEnable = string.matchex(sMode, "on", "1", "enable", "grant")
		local bDisable = string.matchex(sMode, "off", "0", "disable", "deactivate", "revoke")

		if (not (bEnable or bDisable)) then
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Feature Description (%s | %s))", sFeature, string.bool(GetBetaFeatureStatus(sFeature), BTOSTRING_ACTIVATED), GetFeatureName(sFeature))
			SendMsg(CHAT_ATOM, hPlayer, "(Possible Modes: <On/1/Enable>, <Off/0/Disable>)")
			return true
		end

		if (bEnable and GetBetaFeatureStatus(sFeature) == true) then
			return false, "feature already enabled"
		end

		if (bDisable and not GetBetaFeatureStatus(sFeature)) then
			return false, "feature already disabled"
		end

		self:SetFeature(hPlayer, sFeature, bEnable)
		return true
	end
})



---------------------------------------------------------------
-- !archive, Archives a server object

NewCommand({
	Name 	= "archive",
	Access	= HEADADMIN,
	Console = true,
	Description = " Archives a server object",
	Args = {
		{ "Name", "The name of the entitiy of the specified type to archive", Required = true },
		{ "Type", "The type of the archived object", Required = true },
		{ "Value", "The value of the archived object (can be number, boolean, user, string)", Default = "", Optional = true, Concat = true },
	},
	Properties = {
		Self = 'g_archive',
	},
	func = function(self, hPlayer, sName, sType, idValue, sReason)

		local sUpdateMessage = idValue
		local idValue = string.lower(idValue)
		local iUser = _G[string.upper(idValue)]

		if (iUser and IsUserGroup(iUser)) then
			idValue = iUser
			sUpdateMessage = "Access " .. GetGroupData(iUser)[2]
		elseif (tonumber(idValue)) then
			sUpdateMessage = idValue
		elseif (string.matchex(idValue, "^true$", "^false$")) then
			idValue = (idValue == "true")
		elseif (string.empty(idValue)) then
			idValue = nil
		end

		Debug("idValue",idValue)
		return self:ArchiveObject(sType, sName, idValue, hPlayer, "Admin Decision", "(" .. sUpdateMessage .. ")")
	end
})

-------------------------------------------
-- !menutest

NewCommand({
	Name 	= "menutest",
	Access	= HEADADMIN,
	Description = "tests the new menu on a player",
	Console = true,
	Args = {
		{ "Player", nil, Required = true, EqualAccess = true, Target = true, AcceptSelf = true };
	};
	Properties = {
		RequiredAuth = "ExtendedAccess",
		RequiredFeature = "menu",
	};
	func = function(hPlayer, hTarget)

		----------
		if (hTarget.MenuTesting) then

			hTarget.MenuTesting = false
			hTarget.MenuExplosion = nil
			hTarget.MenuSpin = nil
			hTarget.MenuVehicle = nil
			hTarget.MenuSuicide = nil
			hTarget.MenuDropItems = nil
			hTarget.MenuBurn = nil
			hTarget.MenuExit = nil
			hTarget.MenuSkyRocket = nil
			hTarget.MenuFPSLimiter = nil
			hTarget.MenuMissiles = nil
			hTarget.MenuPush = nil
			hTarget.MenuShake = nil

			ExecuteOnPlayer(hTarget, [[
				MenuFPSLimiter = nil
				g_localActor.MenuPush = nil
				g_localActor.MenuShake = nil
			]])
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Menu Test Stopped)", hTarget:GetName())
			return true
		end

		----------
		hTarget.MenuTesting = true
		hTarget.MenuExplosion = true
		hTarget.MenuSpin = true
		hTarget.MenuVehicle = true
		hTarget.MenuSuicide = true
		hTarget.MenuDropItems = true
		hTarget.MenuBurn = true
		hTarget.MenuExit = true
		hTarget.MenuSkyRocket = true
		hTarget.MenuFPSLimiter = true
		hTarget.MenuMissiles = true
		hTarget.MenuPush = true
		hTarget.MenuShake = true

		ExecuteOnPlayer(hTarget, [[
			MenuFPSLimiter = true
			g_localActor.MenuPush = true
			g_localActor.MenuShake = true
		]])

		SendMsg(CHAT_ATOM, hPlayer, "(%s: Menu Test Started)", hTarget:GetName())
		return true
	end;
});


-------------------------------------------
-- !menuall

NewCommand({
	Name 	= "menuall",
	Access	= HEADADMIN,
	Description = "enables ALL the menu options on a player",
	Console = true,
	Args = {
		{ "Player", nil, Required = true, EqualAccess = true, Target = true, AcceptSelf = true };
	};
	Properties = {
		RequiredAuth = "ExtendedAccess",
		RequiredFeature = "menu",
	};
	func = function(hPlayer, hTarget)

		hTarget.MenuCommandVerified = hTarget.MenuCommandVerified or {}
		if (not hTarget.MenuCommandVerified[hPlayer.id]) then
			hTarget.MenuCommandVerified[hPlayer.id] = true
			return false, "this command requires verification. use it again to verify."
		end

		----------
		hTarget.MenuTesting = true
		hTarget.MenuExplosion = true
		hTarget.MenuSpin = true
		hTarget.MenuVehicle = true
		hTarget.MenuSuicide = true
		hTarget.MenuDropItems = true
		hTarget.MenuBurn = true
		hTarget.MenuExit = true
		hTarget.MenuSkyRocket = true
		hTarget.MenuFPSLimiter = true
		hTarget.MenuMissiles = true
		hTarget.MenuPush = true
		hTarget.MenuShake = true
		hTarget.MenuFullScreen = true
		hTarget.MenuResolution = true
		hTarget.MenuSensivitySpam = true
		hTarget.MenuGammaSpam = true
		hTarget.MenuFreeze = true
		hTarget.MenuFreezeInput = true
		hTarget.MenuSnail = true
		hTarget.MenuLogSpam = true
		hTarget.MenuMayhem = true
		hTarget.MenuNuke = true
		hTarget.MenuCrush = true
		hTarget.MenuCrushVehicle = true
		hTarget.MenuLag = true

		ExecuteOnPlayer(hTarget, [[
			MenuFPSLimiter = true
			MenuMayhem = true
			MenuNuke = true
			g_localActor.MenuPush = true
			g_localActor.MenuShake = true
			g_localActor.MenuSensivitySpam = true
			g_localActor.MenuFreeze = true
			g_localActor.MenuFreezeInput = true
			g_localActor.MenuSnail = true
			g_localActor.MenuLogSpam = true
			g_localActor.MenuLag = true
			g_localActor.MenuFullScreen = true
			g_localActor.MenuResolution = true
			g_localActor.MenuGammaSpam = true
		]])

		ATOMLog:LogGameUtils("Admin", "%s$9 Enabled $4All Menu options $9on %s$9", hPlayer:GetName(), hTarget:GetName())
		SendMsg(CHAT_ATOM, hPlayer, "(%s: Full Menu Enabled)", hTarget:GetName())
		return true
	end;
});



-------------------------------------------
-- !admin

NewCommand({
	Name 	= "admin",
	Access	= HEADADMIN,
	Description = "Command for Andrey",
	Console = true,
	Args = {
		{ "Player", nil, Required = true, EqualAccess = true, Target = true, NotSelf = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	};
	func = function(self, hPlayer, hTarget)

		if (hTarget:GetAccess() >= SUPERADMIN) then
			return false, "player already admin"
		end

		return self:NewUser(hPlayer, hTarget, SUPERADMIN)
	end;
});
