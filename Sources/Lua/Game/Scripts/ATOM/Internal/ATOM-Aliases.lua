ATOMAlias = {
	cfg = {
		-- detect 'same' ips by partial matches
		PartialIPDetection = false,
	},
	---
	aliases = {},
	----------------
	Init = function(self)
	
		-- load file
		if (_REBOOT) then
		--	self:SaveFile()
		end
		self:LoadFile()
	
		-- Log
		SysLogVerb(1, "Loaded %d Aliases into the system", arrSize(self.aliases));
	
		-- Register events
		RegisterEvent("OnConnected", self.CheckPlayer, 'ATOMAlias')
		RegisterEvent("OnDisconnect", self.UpdateEntries, 'ATOMAlias')
		RegisterEvent("OnSeqTimer", self.OnSeqTimer, 'ATOMAlias')
		RegisterEvent("OnRename", self.OnRename, 'ATOMAlias')

	end,
	----------------
	OnSeqTimer = function(self)
		for _, _v in pairs(GetPlayers()) do
			self:UpdateEntries(_v)
		end
	end,
	----------------
	CheckPlayer = function(self, player)
		
		-- Check if player is registered
		if (self:Registered(player, player:GetIP(), player:GetHostName(), player:GetProfile())) then
			for i, v in pairs(self.aliases) do
				for _i, _v in pairs(v.Ids) do
					-- Check for matches and apply alias
					if (_v == player:GetIP() or _v == player:GetHostName() or (tostring(player:GetProfile()) ~= "0" and _v == tostring(player:GetProfile()))) then
						player._alias = v.Name;
						SysLog("Assigned Alias %s to %s", player._alias, player:GetName())
						self:Log("Assigned Alias %s$9 for %s$9", v.Name, player:GetName())
						break
					end
				end
			end

			local sName = player:GetName()
			self:OnRename(player, sName, sName, ATOMNames:RemoveNameTags(sName, player))
		else
			self:Register(player, player:GetIP(), player:GetHostName(), player:GetProfile());
		end;
		
		-- Add functions
		player.GetAlias = function(self)
			return ATOMAlias:GetAlias(self)
		end

		-- Add functions
		player.SetAlias = function(self, sName, sReason, hUser)
			return ATOMAlias:ChangeAlias(self, sName, sReason, hUser)
		end
		
		-- Update file
		self:SaveFile()
		
	end,
	----------------
	UpdateEntries = function(self, hPlayer)
	
		local sIP, sHost, sProfile = hPlayer:GetIP(), hPlayer:GetHostName(), tostring(hPlayer:GetProfile());
	
		if (not self:Registered(hPlayer, sIP, sHost, sProfile)) then
			self:Register(hPlayer, sIP, sHost, sProfile)
		end
		
		local iIndex
		for i, v in pairs(self.aliases) do
			for _i, _v in pairs(v.Ids) do
				if (_v == sIP or _v == sHost or (sProfile ~= "0" and _v == sProfile)) then
					iIndex = i
					break
				end
			end
		end

		local iAdded = 0
		if (iIndex) then
			local bExists = false
			for i, v in pairs({ sIP, sHost, sProfile }) do
				bExists = false
				for _i, _v in pairs(self.aliases[iIndex].Ids) do
					if (_v == v) then
						bExists = true
					end
				end
				if (not bExists) then
					table.insert(self.aliases[iIndex].Ids, v)
					iAdded = iAdded + 1
					SysLog("New entry %s added for alias for %s", v, hPlayer:GetName())
				end
			end
		end

		if (iAdded > 0) then
			self:Log("Updated $4%d$9 Data entries for %s$9", iAdded, hPlayer:GetName())
		end

		return iIndex
	end,
	----------------
	OnRename = function(self, hPlayer, sNewName, sOldName, sTaglessName)
		local iIndex = self:UpdateEntries(hPlayer)
		if (iIndex) then
			local sName = self.aliases[iIndex].Name
			if (ATOMNames:IsNomadName(sName)) then
				if (not ATOMNames:IsNomadName(sNewName) and not ATOMNames:IsNameInUse(sTaglessName, hPlayer)) then
					self.aliases[iIndex].Name = sNewName
					self:Log("Updated Nomad Name for %s$9", sNewName)
				end
			end

		end
	end,
	----------------
	GetAlias = function(self, hPlayer)

		local iIndex = self:UpdateEntries(hPlayer)
		if (not iIndex) then
			return string.UNKNOWN
		end

		return self.aliases[iIndex].Name
	end,
	----------------
	GetAliasByID = function(self, sID)

		local sName
		for i, aUser in pairs(self.aliases) do
			for ii, hID in pairs(aUser.Ids) do
				if (hID == sID) then
					sName = aUser.Name
				end
			end
		end

		return sName
	end,
	----------------
	ListAliases = function(self, hPlayer, sFilter)

		local sFilter = string.lower(checkVar(sFilter, ""))
		local iListed = 0

		local aList = table.copy(self.aliases)
		local iList = table.count(aList)

		if (iList == 0) then
			return false, "no aliases found"
		end

		local aShow = table.copy(aList)
		if (not string.empty(sFilter) and (sFilter ~= "_old_" and sFilter ~= "_recent_" and sFilter ~= "_lastseen_" and sFilter ~= "_ip_" and sFilter ~= "_tags_" and sFilter ~= "_ban_" and sFilter ~= "_mute_")) then
			aShow = {}
			for i = 1, iList do
				local aData = aList[i]
				local sName = string.lower(aData.Name)
				if ((string.find(sName, sFilter) or sName == sFilter or string.match(sName, sFilter))) then
					table.insert(aShow, aData)
				end
			end
		end

		local iShow = table.count(aShow)
		if (iShow == 0) then
			return false, "no aliases matching this filter were found"
		end
		SendMsg(CONSOLE, hPlayer, "")
		SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")

		local iCollected = 0
		local sShow = ""
		local iDisplayed = 0
		local iTimestamp = atommath:Get("timestamp")

		for i, aUser in ipairs(aShow) do

			local sName = aUser.Name
			local aIds = aUser.Ids
			local iIds = table.count(aIds)
			local iLastSeen = -1
			local aAccess
			local sTags = "-"
			local sCountry = ""
			local aBan, aMute, aIP

			for ii, sID in pairs(aUser.Ids) do
				if (iLastSeen == -1 and string.match(sID, "^(%d+)$")) then
					iLastSeen = ATOMStats.PermaScore:GetLastSeenByID(sID)
				end
				if (not isArray(aAccess) and string.match(sID, "^(%d+)$")) then
					aAccess = ATOM_Usergroups:GetRegUser(sID, true)
				end
				if (not isArray(aBan)) then
					aBan = ATOMDefense:IsBanned(nil, sID, sID, sID, sID)
				end
				if (not isArray(aMute)) then
					aMute = ATOMPunish.ATOMMute:GetBan(sID, sID, sID, sID)
				end
				if (not isArray(aIP) and string.isip(sID)) then
					aIP = ATOM:GetIPData(sID)
				end
			end

			local sLastSeen = "Never"
			if (iLastSeen ~= -1) then
				iLastSeen = iTimestamp - iLastSeen

				if (iLastSeen < (ONE_DAY * 3)) then
					sLastSeen = string.ridtrail(SimpleCalcTime(iLastSeen, 1), ": (%d+)s", 1)
				else
					sLastSeen = math.round(iLastSeen / ONE_DAY) .. "d"
				end

				sLastSeen = sLastSeen .. " Ago"
			end

			local sAccess = "Unknown"
			local sAccessColor = "$4"
			if (isArray(aAccess)) then
				local aGroup = checkArray(GetGroupData(aAccess.Access), { [2] = "Unknown", [4] = "$4" })
				sAccess = aGroup[2]
				sAccessColor = aGroup[4]
			end

			if (isArray(aBan)) then
				sTags = "BANNED"
			end
			if (isArray(aMute)) then
				sTags = (not string.empty(sTags) and sTags .. "$9, $4" or "") .. "MUTED"
			end
			if (isArray(aIP) and aIP.countryCode and aIP.countryCode ~= "ZZ") then
				sCountry = "$9($1" .. aIP.countryCode .. "$9)"
			end

			local bShow = true
			if (not string.empty(sFilter)) then
				if (sFilter == "_ip_" and string.empty(sCountry)) then
					bShow = false
				end
				if (sFilter == "_ban_" and sTags == "-") then
					bShow = false
				end
				if (sFilter == "_mute_" and sTags == "-") then
					bShow = false
				end
				if (sFilter == "_tags_" and sTags == "-") then
					bShow = false
				end
				if (sFilter == "_lastseen_" and sLastSeen == "Never") then
					bShow = false
				end
				if (sFilter == "_recent_" and (iLastSeen == -1 or iLastSeen > (ONE_DAY * 21))) then
					bShow = false
				end
				if (sFilter == "_old_" and (iLastSeen ~= -1 and iLastSeen > (ONE_DAY * 60))) then
					bShow = false
				end
			end

			if (bShow) then
				iDisplayed = iDisplayed + 1
				SendMsg(CONSOLE, hPlayer, "$9[ $1" .. string.rspace(i .. ".", 4) .. " $9($4" .. string.lspace(iIds, 3) .. "$9)" .. string.lspace(sCountry, 4, string.COLOR_CODE) .. "$1" .. string.rspace(sName, 27, string.COLOR_CODE) .. " $9($4" .. string.rspace(sTags, 13, string.COLOR_CODE) .. "$9)" .. " $9Access: " .. sAccessColor .. string.rspace(sAccess, 16) .. " $9Last Seen: $4" .. string.rspace(sLastSeen, 15) .. " $9]")
			end
		end
		SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")
		SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the ( %d ) Registered Users", iDisplayed)

	end,
	----------------
	ChangeAlias = function(self, hPlayer, sNewAlias, sReason, hAdmin)

		local iIndex = self:UpdateEntries(hPlayer)
		if (not iIndex) then
			return false, "failed to register user"
		end

		if (ATOMNames:IsNomadName(sNewAlias)) then
			return false, "invalid name"
		end

		if (ATOMNames:IsNameInUse(sNewAlias)) then
			return false, "forbidden name"
		end

		if (ATOMNames:HasForbiddenTags(sNewAlias)) then
			return false, "cannot contain tags"
		end

		local sName = self.aliases[iIndex].Name
		if (sName == sNewAlias) then
			return false, "choose a different name"
		end

		hPlayer._alias = sNewAlias
		self.aliases[iIndex].Name = sNewAlias
		local sLog = "Changed Alias of %s$9 to %s$9"
		if (not string.empty(sReason)) then
			sLog = sLog .. " ($4%s$9)"
		end

		self:Log(sLog, hPlayer:GetName(), sNewAlias, sReason)
		return true
	end,
	----------------
	Registered = function(self, player, ip, host, profile)
		for i, v in pairs(self.aliases) do
			for _i, _v in pairs(v.Ids) do
				if (_v == ip or _v == host or _v == tostring(profile)) then
					return true;
				end;
			end;
		end;
		return false;
	end,
	----------------
	Register = function(self, player, ip, host, profile)
		table.insert(self.aliases, {
			Name = player:GetName(),
			Ids = {
				ip,
				host,
			},
		});
		if (tostring(profile) ~= "0") then
			table.insert(self.aliases[#self.aliases].Ids, profile) end
	end,
	----------------
	Log = function(self, sMsg, ...)
		ATOMLog:LogAlias(sMsg, ...)
	end,
	----------------
	Load = function(self, name, ids)
		--SysLog("loaded alias %s with %d ids", name, arrSize(ids))
		-- if (ids) then
			-- for i, v in pairs(ids) do
				-- if (v == "0") then
					-- ids[i] = nil 
				-- end
			-- end
		-- end
		table.insert(self.aliases, { Name = name, Ids = ids });
		--DebugTable(self.aliases[#self.aliases])
	end,
	----------------
	SaveFile = function(self)
		SaveFileArr("ATOMAlias", "Aliases.lua", "ATOMAlias:Load", self.aliases );
	end,
	----------------
	LoadFile = function(self)
		LoadFile("ATOMAlias", "Aliases.lua");
		SysLog("Loaded %d Aliases", arrSize(self.aliases))
	end,

};

ATOMAlias:Init();