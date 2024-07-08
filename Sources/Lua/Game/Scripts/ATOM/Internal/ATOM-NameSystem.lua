ATOMNames = {
	cfg = {
		NameTemplate = "[ATOM.%s] :: [#%s]";
		MinLength = 1;
		MaxLength = {
		
			[GUEST]	 		= 18;
			[PREMIUM]	 	= 22;
			[DEVELOPER] 	= 100;
		
		};
		RenameNomads = true;
		RememberNames = { -- set to 'true' to save names from all players
			[PREMIUM]	 = true;
		};
		AllowCrypticNames = false;
		MaxCryptPercent = 10; -- if new name is more than 20% cryptic, return error
		PermiumMaxDollar = 3;
		ConsoleRenaming = false;
		ForbiddenNames = {};
		VIPTag = "(VIP) ";
		ForbiddenTags = {
			"(AFK) ",
			"(GOD) ",
			"(VIP) ",
			"(ASSIST) ",
			"(ADMIN) ",
			"(MODERATOR) ",
			"(MOD) ",
			"(OWNER) ",
			"(PREMIUM) ",
		};
	};
	---------
	savedNames = ATOMNames~= nil and ATOMNames.savedNames or {};
	---------
	nameQuene = {};
	---------
	IsNomad = function(self, playerName, notempl)
		--Debug("isnomad",playerName)
		--Debug(playerName:match("^Nomad:(%w+)$"))

		local sPlayerName = string.lower(playerName)
		if (string.match(sPlayerName, "^nomad$")) then
			return true
		end

		local sTemplate = self.cfg.NameTemplate
		if (not string.empty(sTemplate) and (string.match(sPlayerName, "^" .. string.lower(sTemplate) .. "$") or string.lower(sTemplate) == sPlayerName)) then
			return true
		end


		return playerName:match("^Nomad:(%w+)$") or playerName:lower() == "nomad" or playerName:lower():match("nomad%((%d+)%)") or (not notempl and playerName:lower():match("%[atom%.(.*)%] :: %[#(%d+)%]"));-- or playerName:lower():match("%[atom.%s+%] :: %[#(%d+)%]");
	end;
	---------
	IsNomadName = function(self, sName)

		local sPlayerName = string.lower(sName)
		if (string.match(sPlayerName, "^nomad$")) then
			return true
		end

		local sTemplate = self.cfg.NameTemplate
		if (not string.empty(sTemplate) and (string.match(sPlayerName, "^" .. string.lower(sTemplate) .. "$") or string.lower(sTemplate) == sPlayerName)) then
			return true
		end

		local sTemplate = self.cfg.NameTemplate
		if (not sTemplate or string.empty(sTemplate)) then
			return false
		end

		local sMatch = self:FormatTemplateEx(sTemplate)
		return ((string.match(sName, sMatch)) ~= nil)
	end;
	---------
	IsNameInUse = function(self, sName, hExcept)

		local idExcept = checkArray(hExcept,{ id = -1 }).id
		local hEntity = GetEnt(sName)
		if (hEntity and hEntity.id ~= idExcept) then
			if (hEntity.isPlayer or hEntity.isServer or hEntity.isChatEntity) then
				return true
			end
		end

		return false
	end,
	---------
	ForbiddenTags = {};
	---------
	IsForbiddenName = function(self, playerName)
		if (self.cfg.ForbiddenNames and type(self.cfg.ForbiddenNames) == "table") then
			for i, name in pairs(self.cfg.ForbiddenNames or{}) do
				if (name:lower() == playerName:lower()) then
					return true;
				end;
			end;
		end;
		return false;
	end;
	---------
	CleanName = function(self, playerName, player)
		local newName = tostr(playerName);
		if (self.cfg.ReplaceNames and type(self.cfg.ReplaceNames) == "table") then
			local wasReplaced = false;
			for word, replacement in pairs(self.cfg.ReplaceNames) do
				--Debug("R = ",word)
				if (replacement and string.len(tostr(replacement))>0 and replacement~=word) then
					while newName:lower():find(tostr(word):lower()) do
						local s, e = newName:lower():find(tostr(word):lower());
						if (s and e) then
							local before, after = string.sub(newName, 1, s - 1), string.sub(newName, e + 1, 999);
							--Debug(">", before, "+",after)
							wasReplaced = true;
							--	SysLog("replacing word %s with %s",word, replacement);
							newName = before .. replacement .. after; --newMessage:gsub("[(a+a+a)]", replacement);
						else
							break; -- WTF!?!
						end;
					end;
				end;
			end;
			if (wasReplaced) then
				--SendMsg(CHAT_ATOM, player, "%s, Watch your Language.", player:GetName());
				--SendMsg(player, t==ChatToAll and ALL or t==ChatToTarget and sender or TEAM, newMessage);
				--Debug(message)
				--Debug(newMessage)
				--g_game:SendChatMessage(t, playerId, senderId, newName);
				SysLog("Name from %s was altered ('%s' now '%s')", player:GetName(), playerName, newName);
				--return false;
			end;
		end;
		return newName;
	end;
	---------
	HasName = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier) then
			for i, v in pairs(self.savedNames) do
		--		Debug(tostr(i) ,'==', tostr(identifier))
				if (tostr(i) == tostr(identifier)) then
					return self:RemoveTags(v);
				end;
			end;
		end;
	end;
	---------
	OnConnect = function(self, player)
		
		if (player.accountName and player.accountName:lower() ~= "nomad") then
			Debug("found accnamre",player.accountName)
			return player.accountName;
		end;
		
		if (self.cfg.RememberNames) then
			local remember = self.cfg.RememberNames;
			local restore = false;
			if (type(remember) == "table") then
				local last = -999;
				for i, doRestore in pairs(remember) do
					if (player:HasAccess(i) and last < i) then
						last = i;
						restore = doRestore;
					end;
				end;
			elseif (IsUserGroup(remember)) then
				restore = player:HasAccess(remember);
			else
				restore = remember;
			end;
			--Debug("Restoring name ");
			--Debug(restore,self:HasName(player))
			--Debug("Nomad",self:IsNomad(player:GetName()))
			if (restore and self:HasName(player) and self:IsNomad(player:GetName())) then
				return self:RenamePlayer(player, self:HasName(player), "Last Used Name");
			end;
		end;
		
		local template = self.cfg.NameTemplate;
		local custom = self.cfg.UseCustomNames;
		local customNames = self.cfg.CustomNames;
		local sName;
		
		if (false and custom and customNames) then
			sName = GetRandom(customNames)
		elseif (template) then
			sName = self:GetNomadName(player)
		end
		
		if (sName) then
			if ((self.cfg.RenameNomads and (self:IsNomad(player:GetName(), true)) or self:IsForbiddenName(player:GetName()))) then
				self:RenamePlayer(player, sName, "Forbidden Name")
			end
		end
	end;

	---------
	GetName = function(self, sPlayerName, iChannel, aData)
		local sNewName
		local sTemplate = self.cfg.NameTemplate
		if (sTemplate) then

			local aData = checkArray(aData, {
				IP = nil,
				Country = nil,
				CountryCode = nil
			})
			local aNewData = {
				ChannelId	 = iChannel,
				ProfileId	 = 0,
				HostName	 = (aData.IP or "N/A"),
				Country		 = (aData.Country or "N/A"),
				CountryCode	 = (aData.CountryCode or "N/A"),
			}

			sNewName = self:GetNomadName(nil, aNewData)

		end

		if (sNewName) then
			if ((self.cfg.RenameNomads and self:IsNomad(sPlayerName) or self:IsForbiddenName(sPlayerName))) then
				return sNewName
			end
		end
		return
	end;
	----------
	GetNomadName = function(self, hPlayer, aData)
		local sTemplate = self:FormatTemplate(string.new(self.cfg.NameTemplate), hPlayer, aData)
		return sTemplate
	end;
	----------
	FormatTemplateEx = function(self, sTemplate)

		local sFormatted = string.escape(string.new(sTemplate))
		for sFind, sRep in pairs({
			["{slot}"] 			= "(%%d+)",
			["{profile}"] 		= "(%%d+)",
			["{host}"] 			= "(%%w+)",
			["{country}"] 		= "(%%w+)",
			["{countryCode}"] 	= "(%%w%%w)",
			["{channel}"]	 	= "(%%d%%d%%d%%d)",
			["{totalchannel}"] 	= "(%%d%%d%%d%%d)",
		}) do
			sFormatted = string.gsub(sFormatted, sFind, sRep)
		end

		return sFormatted
	end;
	----------
	FormatTemplate = function(self, sName, hPlayer, aData)

		local aFormat = { TotalChannel = g_statistics:GetValue("ConnTotal") }
		if (aData and not hPlayer) then
			aFormat.Channel		 = aData.ChannelId
			aFormat.Profile		 = aData.ProfileId
			aFormat.HostName	 = aData.HostName
			aFormat.Country		 = aData.Country
			aFormat.CountryCode	 = aData.CountryCode
		elseif (hPlayer) then
			aFormat.Channel		 = hPlayer:GetChannel()
			aFormat.Profile		 = hPlayer:GetProfile()
			aFormat.HostName	 = hPlayer:GetHostName()
			aFormat.Country		 = hPlayer:GetCountry()
			aFormat.CountryCode	 = hPlayer:GetCountryCode()
			aFormat.TotalChannel = (hPlayer.TotalChannelID or aFormat.TotalChannel)
		end

		for sFind, sRep in pairs({
			["{slot}"] 			= aFormat.Channel,
			["{profile}"] 		= aFormat.Profile,
			["{host}"] 			= aFormat.HostName,
			["{country}"] 		= aFormat.Country,
			["{countryCode}"] 	= aFormat.CountryCode,
			["{channel}"]	 	= string.lspace(aFormat.Channel, 4, nil, "0"),
			["{totalchannel}"] 	= string.lspace(aFormat.TotalChannel, 4, nil, "0"),
		}) do
			sName = string.gsub(sName, sFind, sRep)
		end

		return sName
	end;
	----------
	RemoveTag = function(self, name, tag)
		local saneTag = tag:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
		local fixedName = name:gsub(saneTag, "");
		return fixedName;
	end;
	----------
	AddTag = function(self, name, tag)
		return tag .. name;
	end;
	----------
	RemoveTags = function(self, name)
		--Debug("Name before:", name);
		local newName = name;
		for i, v in pairs(self.cfg.ForbiddenTags) do
		--	Debug(sub,v)
			newName = self:RemoveTag(newName, v);
		end;
		--Debug("Name after:", newName);
		return newName;
	end;
	----------
	HasTag = function(self, name, tag)
		if (name:find(tag, nil, true)) then
			return true;
		else
			return false;
		end;
	end;
	----------
	HasTags = function(self, name, tag)
		for i, v in pairs(self.cfg.ForbiddenTags) do
			if (self:HasTag(name, v)) then
				return true, v;
			end;
		end;
	end;
	----------
	CanUseName = function(self, name)
	--	Debug("TRUE",not self:IsForbiddenName(name) and not self:IsNomad(name) and string.len(name))
		return not self:IsForbiddenName(name) and not self:IsNomad(name) and string.len(name) >= string.len(self:RemoveTags(name));
	end;
	----------
	OnDisconnect = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier) then
			if (self:CanUseName(player:GetName())) then
				if (self.savedNames[identifier] == player:GetName()) then
					return;
				end;
				self.savedNames[identifier] = self:RemoveTags(player:GetName());
			else
				self.savedNames[identifier] = nil;
			end;
			self:SaveFile();
		end;
	end;
	----------
	Init = function(self)
		self.ForbiddenTags = self.cfg.ForbiddenTags or {};
		self.ForbiddenTags[arrSize(self.ForbiddenTags)+1] = self.cfg.VIPTag;
		self.savedNames = {}
		self:LoadFile();
	end;
	----------
	LoadFile = function(self)
		LoadFile("ATOMNames", "Names.lua");
	end;
	----------
	LoadSavedName = function(self, identifier, name)
		self.savedNames[identifier] = name;
	end;
	----------
	ConvertTable = function(self, t)
		local n = {};
		for i, v in pairs(t) do
			n[arrSize(n)+1] = {
				i,
				v
			};
		end;
		return n
	end;
	----------
	SaveFile = function(self)
		SaveFile("ATOMNames", "Names.lua", "ATOMNames:LoadSavedName", self:ConvertTable(self.savedNames));
	end;
	---------
	
	EscapeCharacters = function(self, sString)
		local aEscapes = {
			"(", ")",
			"[", "]",
			"+", "-", "*", 
			"?", "%", "$", "^"
		}
		
		local sEscaped = string.new(sString)
		for i, sChar in pairs(aEscapes) do
			--Debug("rep ",sChar,"->%",sChar)
			sEscaped = string.gsub(sEscaped, ("%" .. sChar), ("%%%" .. sChar))
		end
		
		return string.gsub(sEscaped, "(%%+)", "%%")
	end,
	
	---------
	
	AddNameTag = function(self, hPlayer, sTag, bForce)
		-- local sTagMatch = ("^" .. self:EscapeCharacters(sTag))
		
		-- local sName = string.gsub(hPlayer:GetName(), sTagMatch, "")
		-- local sNewName = (sTag .. sName)
		
		hPlayer.aTags = checkVar(hPlayer.aTags, {})
		hPlayer.aTags[sTag] = (not hPlayer.aTags[sTag])
		
		if (not isNull(bForce)) then
			hPlayer.aTags[sTag] = bForce end
		
		hPlayer.WasTagRemovalRename = true
		hPlayer.bIsTagRemoval = true
		return self:RenamePlayer(hPlayer, hPlayer:GetName())
		
		-- local bHasTag = (hPlayer.aTags[sTag] == true)
		-- local bSuccess
		-- if (sName ~= sNewName) then
			-- if (bHasTag) then
				-- bSuccess = self:RenamePlayer(hPlayer, sName) 
			-- else
				-- bSuccess = self:RenamePlayer(hPlayer, sNewName) 
			-- end
		-- end
		
		-- if (true or bSuccess) then
			 -- end
			
		-- return bSuccess, "Failed to add tag"
	end,
	
	---------
	
	AddNameTags = function(self, sName, hPlayer)
		
		-- Debug("Add Tags: " , sName)
		hPlayer.aTags = checkVar(hPlayer.aTags, {})
		for sTag, bAdd in pairs(hPlayer.aTags) do
			if (bAdd) then
				sName = sTag .. sName end
		end
		-- Debug("Added Tags: " , sName)
		
		return sName
	end,
	
	---------
	
	RemoveNameTags = function(self, sName, hPlayer, sThis)
		
		-- Debug("Remove Tags: " , sName)
		hPlayer.aTags = checkVar(hPlayer.aTags, {})
		for sTag in pairs(hPlayer.aTags) do
			if (not sThis or (string.lower(sTag) == string.lower(sThis))) then
				sName = string.gsub(sName, self:EscapeCharacters(sTag), "")
			end
		end
		
		-- Debug("Removed Tags: " , sName)
		return sName
	end,
	
	---------
	
	CheckVIPTag = function(self, hPlayer)
		return self:AddNameTag(hPlayer, self.cfg.VIPTag)
	end,
	
	---------
	
	CheckAssistTag = function(self, hPlayer, bForce)
		return self:AddNameTag(hPlayer, self.cfg.AimAssistTag, bForce)
	end,

	---------

	HasForbiddenTags = function(self, sName)

		local aForbidden = self.cfg.ForbiddenTags
		for i, sTag in pairs(aForbidden) do
			if (string.find(sName, sTag, nil, true)) then
				return true
			end
		end

		return false
	end,
	
	---------
	RenamePlayer = function(self, hPlayer, sName, sReason, bForce)
	

		local aCfg = self.cfg
		if (sName) then
			sName = string.gsubex(sName, { "\"", "%%", "%[", "%]" }, "")
		end

		if (string.empty(sName)) then
			return false, "invalid name"
		end

		local bIsPremium = hPlayer:HasAccess(PREMIUM)
		local bIsSuper = hPlayer:HasAccess(SUPERADMIN)

		local x, iDollars
		local sTaglessName

		if (not bIsPremium) then
			if (not aCfg.AllowColoredNames) then
				sName = string.gsub(sName, "%$", "_")
			else
				x, iDollars = string.gsub(sName, "%$", "x")
				if (true or not bIsSuper) then
					if (checkNumber(iDollars, 0) > aCfg.GuestMaxDollar) then
						return false, "Name too Colorful"
					end
				end
			end;
		elseif (true or not bIsSuper) then

			x, iDollars = string.gsub(sName, "%$", "x")
			if (true or not bIsSuper) then
				if (checkNumber(iDollars, 0) > aCfg.PremiumMaxDollar) then
					return false, "Name too Colorful"
				end
			end
			
			local bHasForbidden = self:HasForbiddenTags(sName)
			if (bHasForbidden and not hPlayer.WasTagRemovalRename) then
				return false, "name cannot include tags"
			end

			sTaglessName = self:RemoveNameTags(sName, hPlayer)
			sName = self:AddNameTags(sTaglessName, hPlayer)

			Debug("Fixed: ", sName)
		else
			sName = self:RemoveNameTags(sName, hPlayer)
			sName = self:AddNameTags(sName, hPlayer)
			
			if (hPlayer.WasTagRemovalRename) then
				if (string.empty(sName)) then
					sName = "empty"
				end
			end
		end

		hPlayer.WasTagRemovalRename = false
		if (not bIsSuper) then
			sName = string.gsub(sName, "@", "_")
		end

		local iLen = string.len(sName)

		local aMinLength = aCfg.MinLength
		local iLastAccess = -1
		if (aMinLength) then

			local iMinLength = checkNumber(aMinLength, 1)
			if (isArray(aMinLength)) then
				for iAccess, iLimit in pairs(aMinLength) do
					if (hPlayer:HasAccess(iAccess) and iAccess > iLastAccess) then
						iLastAccess = iAccess
						iMinLength = checkNumber(iLimit, 1)
					end
				end
			end

			if (iMinLength and string.len(iLen) < iMinLength) then
				return false, "name too short"
			end
		end


		local aMaxLength = aCfg.MaxLength
		iLastAccess = -1
		if (aMaxLength) then

			local iMaxLength = checkNumber(aMaxLength, 24)
			if (isArray(aMaxLength)) then
				for iAccess, iLimit in pairs(aMaxLength) do
					if (hPlayer:HasAccess(iAccess) and iAccess > iLastAccess) then
						iLastAccess = iAccess
						iMaxLength = checkNumber(iLimit, 24)
					end
				end
			end

			if (iMaxLength and string.len(iLen) > iMaxLength) then
				return false, "name too long"
			end
		end

		local sOldName = hPlayer:GetName()
		local sTagLess = self:RemoveNameTags(sName, hPlayer)

		iLen = string.len(sTagLess)
		if (not aCfg.AllowCrypticNames) then
			sName = UTF8Clean(sName)
		end
		local iLenNew = string.len(self:RemoveNameTags(sName, hPlayer))
		local iCrypt = (100 - (100 / (iLen / iLenNew)))

		local hUsedBy

		if (not bForce) then
			local iCryptMax = checkNumber(self.cfg.MaxCryptPercent, 25)
			if (iCryptMax and self.cfg.AllowCrypticNames) then
				if (iCrypt > iCryptMax) then
					return false, "name too cryptic"
				end
			elseif (iCrypt > 0) then
				return false, "cryptic names not allowed"
			end
			
		
			local bReserved, sReserved = ATOM_Usergroups:IsProtectedName(hPlayer, sTagLess)
			if (bReserved) then
				return false, "reserved name (" .. sReserved .. ")"
			end

			local bMuted, muteInfo = ATOMDefense:IsMuted(hPlayer)
			if (bMuted) then
				return false, "cannot rename while muted"
			end

			hUsedBy = GetEnt(sName)
			if (hUsedBy and not hPlayer.bIsTagRemoval) then
				if (hUsedBy.isChatEntity) then
					return false, "forbidden name"
				elseif (hUsedBy.isPlayer) then
					return false, "name already used ".. (hUsedBy.id == hPlayer.id and "by you"or"")
				end
			end
		end

		if (hPlayer.bIsTagRemoval) then
			hUsedBy = GetEnt(sName)
			if (hUsedBy) then
				if (hUsedBy.isChatEntity or hUsedBy.isServer) then
					sName = self:GetNomadName(hPlayer)
				elseif (hUsedBy.isPlayer) then
					sName = self:GetNomadName(hPlayer)
				end
			end
		end
		hPlayer.bIsTagRemoval = false
		
		if (sOldName == sName) then
			return false, "choose different name"
		end
		
		if (self:IsForbiddenName(sName)) then
			return false, "forbidden name"
		end

		sName = self:CleanName(sName, hPlayer)
		if (sReason) then
			self:QueneRename(hPlayer, sName);
			ATOMLog:LogRename(hPlayer, sOldName, sName, sReason)
		else
			g_game:RenamePlayer(hPlayer.id, sName)
		end

		ATOMBroadcastEvent("OnRename", hPlayer, sName, sOldName, self:RemoveNameTags(sName, hPlayer))
		
		return true
	end;
	---------
	---------
	OnConsoleRename = function(self, player, name)
		if (not RCA or not RCA:OnReport(player, name)) then
			local canRename = ATOMBroadcastEvent("OnConsoleName", player, name);
			if (canRename and self.cfg.ConsoleRenaming) then
				local renamed, error = self:RenamePlayer(player, name, 'User Decision');
				if (renamed) then
					SendMsg(CONSOLE_NOQUENE, player, "$1name: $3Success");
				else
					SendMsg(CONSOLE_NOQUENE, player, "$1name: $4failed: " .. error);
					SendMsg(CHAT_ATOM, player, "(NAME: Failed: " .. error .. ")");
				end;
			end;
		end;
	end;
	---------
	QueneRename = function(self, player, name)
		Script.SetTimer(1, function()
			g_game:RenamePlayer(player.id, name);
		end);
	end;

};