ATOMLevelSystem = {
	cfg = {
	
		StartLevel 		= 0,
		MinimumLevel	= 0,
		MaximumLevel 	= 10000,
		LevelEXP 		= 50,
		
		KillEXP = { -- Multiplier for specific weapons
			GaussRifle 	= 0.1, 
			DSG1		= 1.3,
			C4			= 0.01,
			SOCOM		= 3,
			Claymore	= 0.2,
			AVMine		= 1.5,
			Fists		= 1.5
		};
		
		ChatEXP = { 5, 8 }, -- EXP for chat messages
		GameTimeEXP = { 22, 32 }, -- between 22 and 32 exp every minute
		
		BotEXP = 0.3 -- Multiplier for bot kills 
	};
	----------------
	savedEXP = ATOMLevelSystem ~= nil and ATOMLevelSystem.savedEXP or {};
	----------------
	Init = function(self)
		
		-------
		if (Config and Config.GamePlay.Leveling) then
			self.cfg = mergeTables(self.cfg, Config.GamePlay.Leveling) end
		
		-------
		self:LoadFile()
		
		-------
		shouldGiveEXP = function(self, t)
			return ATOMLevelSystem:ShouldGiveEXP(t) end
	end,

	----------------
	InitPlayer = function(self, hPlayer)

		local aCfg = self.cfg
		hPlayer.levelStats = self:Default()

		----------
		hPlayer.GetEXP = function(self, aTable)
			if (isArray(aTable)) then
				return table.insert(aTable, self.levelStats.EXP)
			end

			return self.levelStats.EXP
		end

		----------
		hPlayer.SetEXP = function(self, iExp)
			self.levelStats.EXP = iExp
			self:RefreshEXP()
		end

		----------
		hPlayer.GiveEXP = function(self, iExp, sMsg, sInfo)
			ATOMLevelSystem:AddEXP(self, iExp, sMsg, sInfo)
		end

		----------
		hPlayer.RemoveEXP = function(self, iExp, sMsg, sInfo)
			ATOMLevelSystem:RemoveEXP(self, iExp, sMsg, sInfo)
		end

		----------
		hPlayer.RefreshLevel = function(self)
		end

		----------
		hPlayer.GetLevel = function(self, aTable)
			if (aTable) then
				return table.insert(aTable, self.levelStats.Level)
			end

			return self.levelStats.Level
		end

		----------
		hPlayer.SetLevel = function(self, iLevel)
			self.levelStats.Level = iLevel
			self:RefreshLevel()
		end

		----------
		hPlayer.AddLevel = function(self, iLevels, sMsg)
			self.levelStats.Level = self.levelStats.Level + iLevels
			if (sMsg) then
				SendMsg(INFO, self, (iLevels > 0 and "+" or "-") .. iLevels .. " LEVELS (" .. sMsg .. ")");
			end
		end

		----------
		hPlayer.RefreshEXP = function(self)
		end

	end,

	----------------
	ShouldGiveEXP = function(self, sType)
		local iAdd = 0
		local iChat = self.cfg.ChatEXP
		local iTime = self.cfg.GameTimeEXP

		if (sType == "Chat" and iChat ~= nil) then
			iAdd = (isArray(iChat) and GetRandom(iChat) or iChat)
		elseif (t=="Time") then
			iAdd = (isArray(iTime) and GetRandom(iTime) or iTime)
		end
		return (iAdd > 0), iAdd
	end,

	----------------
	GiveEXP = function(self, hPlayer, hTarget, iExp)

		if (not hTarget or hTarget == hPlayer) then
			hPlayer:GiveEXP(math.min(25000, iExp), true, "Admin Decision")

		elseif (hTarget == "all") then
			for i, hTargetP in pairs(checkArray(GetPlayers())) do
				hTargetP:GiveEXP(math.min(25000, iExp), true, "Admin Decision")
			end
		else

			hTarget:GiveEXP(math.min(25000, iExp), true, "Admin Decision")
		end
	end,

	----------------
	Default = function(self)
		local cfg = self.cfg
		local t = {
			EXP 		= 0,
			Level 		= cfg.StartLevel or 0,
			NextLevel 	= cfg.LevelEXP,
			Previous	= 0
		};
		t.NextLevel = self:GetNextLevelEXP(t.Level);
		return t;
	end,

	----------------
	OnConnect = function(self, player)

		local sID = player:GetIdentifier()
		if (sID) then
			self.savedEXP[sID] = self.savedEXP[sID] or self:Default()
			player.levelStats = self.savedEXP[sID]
		end
	end,

	----------------
	RefreshEXP = function(self, player)
		--[[local cfg = self.cfg;
		local exp = player:GetEXP();
		local lvl = player:GetLevel();
		local del = 0;
		
		Debug((exp / cfg.LevelEXP) ,'>', lvl)
		
		if (exp / cfg.LevelEXP) > lvl then
			del = del + cfg.LevelEXP;
		
			exp = player:GetEXP();
			lvl = player:GetLevel();
			
		end;
		
		if (del > 0) then
			player:RemoveEXP(cfg.LevelEXP);
			self:OnLevelDown(player);
		end;
		
		self:OnEXPChange();]]
	end;
	----------------
	GetNextLevelEXP = function(self, level)
	--	Debug("NL",self.cfg.LevelEXP * minimum(1, level))
		return self.cfg.LevelEXP * minimum(1, level); --self.cfg.LevelEXP + (level * 2);
	end;
	----------------
	HandleKill = function(self, killHit, headShot)
	
		local killer = killHit.shooter
		local target = killHit.target;
		local weapon = killHit.weapon;
		
		if (killer and killer ~= target and killer.isPlayer) then
			local weaponClass = (weapon and weapon.class or nil);
			local lowerClass = weaponClass and weaponClass:lower() or nil;
			
			if (lowerClass) then
				local newNames = {
					["c4"] = "C4",
					["claymore"] = "Claymore",
					["avmine"] = "AV-Mine",
					["law"] = "RPG",
					["dsg1"] = "Sniper",
					["gaussrifle"] = "Mighty Gauss",
				};
				if (newNames[lowerClass]) then
					weaponClass = newNames[lowerClass];
				end;
			end;
			
			local EXP = self.cfg.KillEXP;
			local Bot = self.cfg.BotEXP or 1;
			
			local exp = math.floor(math.max(0, 15 * (EXP[weaponClass] or 1) * (headShot and 2 or 1) * (not target.isPlayer and Bot or 1))) * (killer.EXPBonus or 1);
			
			killer:GiveEXP(exp, true, weaponClass);
		end;
	end;
	----------------
	ResetLevel = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier) then
			self.savedEXP[identifier] = self:Default();
			player.levelStats = self.savedEXP[identifier];
		end;
		return true;
	end,
	----------------
	GetLevelRank = function(self, player)
		local rank 	= 1;
		local exp	= player:GetEXP();
		for i, v in pairs(self.savedEXP) do
			if (i ~= player:GetIdentifier()) then
				if (v.EXP > exp) then
					rank = rank + 1;
				end;
			end;
		end;
		return rank;
	end;
	----------------
	AddEXP = function(self, player, amount, message, info)
	
		if (amount < 0) then
			return self:RemoveEXP(player, amount * -1, message, info);
		end;
	
		local cfg = self.cfg;
		local leveled = false;
		local before = player:GetLevel()
		
		local addEXP = self:GetNextLevelEXP(player:GetLevel());
		--Debug("Add",addEXP)
		--Debug("Next level",player.levelStats.NextLevel)
		--Debug("exp",player.levelStats.EXP)
		player.levelStats.EXP = round(player.levelStats.EXP + amount);
		
		while (player.levelStats.EXP >= player.levelStats.NextLevel) do --
			addEXP = self:GetNextLevelEXP(player:GetLevel());
			player.levelStats.NextLevel = round(player.levelStats.NextLevel + addEXP);
			player.levelStats.Previous = round(player.levelStats.Previous + addEXP);
			player:AddLevel(1);
			leveled = true;
		--	SysLog("LOOOPING :D")
		--	SysLog("  %d >= %d", player.levelStats.EXP,player.levelStats.NextLevel)
		end;
		
		
		--Debug(player.levelStats.NextLevel/(addEXP-player.levelStats.EXP))
		
		local perc = ((addEXP - (player.levelStats.NextLevel - player.levelStats.EXP))/addEXP) * 100; --cutNum((amount / cfg.LevelEXP) * 100, 2); --(round(((addExp - (plData.nextlevel - plData.exp))/addExp)*100))
		if (perc<0) then
			perc = 0.001;
		end;
		
		
		
		if (leveled) then
			self:OnLevelUp(player, before);
			self:OnEXPChange();
		elseif (message and (not player.lastInfoMsgFrameID or System.GetFrameID() ~= player.lastInfoMsgFrameID )) then

			if (timerexpired(player.EXPMessageTimer, 60)) then
				player.EXPMessageTimer = timerinit()
				SendMsg(INFO, player, "+" .. amount .. " EXP " .. (info and "(" .. info .. ") " or "") .. (perc~=nil and cutNum(perc, 2) .. "% of LEVEL " .. player:GetLevel()+1 or ""));
			end

			player.lastInfoMsgFrameID = System.GetFrameID()
		end;
	--	SysLog("shit ok.")
	end;
	----------------
	RemoveEXP = function(self, player, amount, message, info)

		local cfg = self.cfg;
		
		local addEXP = self:GetNextLevelEXP(player:GetLevel());
		
		player.levelStats.EXP = round(player.levelStats.EXP - amount);
		
		local perc = ((addEXP - (player.levelStats.NextLevel - player.levelStats.EXP))/addEXP) * 100; --cutNum((amount / cfg.LevelEXP) * 100, 2); --(round(((addExp - (plData.nextlevel - plData.exp))/addExp)*100))
		if (perc<0) then
			perc = 0.001;
		end;

		if (message) then
			SendMsg(INFO, player, "-" .. amount .. " EXP " .. (info and "(" .. info .. ") " or "").. (perc~=nil and cutNum(perc, 2) .. "% of LEVEL " .. player:GetLevel()+1 or ""));
		end;
		--[[Debug(player.levelStats.EXP, "<=", player.levelStats.Previous)
		
		while (player.levelStats.EXP > 0 and player.levelStats.EXP <= player.levelStats.Previous and player:GetLevel() > cfg.MinimumLevel and player.levelStats.Previous >= 0) do
		
			
			player.levelStats.Previous 	= player.levelStats.Previous  - cfg.LevelEXP;
			player.levelStats.NextLevel = player.levelStats.NextLevel - cfg.LevelEXP;
			player:AddLevel(-1);
			self:OnLevelDown(player);
			leveled = true;
			
		end;
		
		if (leveled) then--]]
			self:OnEXPChange();
		--[[end;]]--
		
	end;
	----------------
	OnEXPChange = function(self)
		for i, player in pairs(GetPlayers()or{}) do
			local identifier = player:GetIdentifier();
			if (identifier) then
				self.savedEXP[identifier] = player.levelStats;
			end;
		end;
		if (not self.lastSave or _time - self.lastSave >= 0) then
			self.lastSave = _time;
			self:SaveFile();
		end;
	end;
	----------------
	OnLevelUp = function(self, player, oldLevel)
	
		local newLevel 	= player:GetLevel();
		local oldLevel 	= oldLevel or newLevel - 1;
		local newEXP	= player:GetEXP();
		
		--self:SaveFile();
		--player.levelStats.NextLevel = player.levelStats.NextLevel + self.cfg.LevelEXP;
		
		ATOMBroadcastEvent("OnLevelUp", player, newLevel, oldLevel, newEXP);
	
		ATOMLog:LogScoreRestore("Restore", "%s$9 Advanced to Level %s", player:GetName(), newLevel);
		SendMsg( { INFO, BLE_INFO }, player, "%s Advanced to Level %s", player:GetName(), newLevel);
	end;
	----------------
	OnLevelDown = function(self, player)
	
		local newLevel 	= player:GetLevel();
		local oldLevel 	= newLevel + 1;
		local newEXP	= player:GetEXP();
		
		--self:SaveFile();
	--	player.levelStats.NextLevel = player.levelStats.NextLevel - self.cfg.LevelEXP;
		
		ATOMBroadcastEvent("OnLevelDown", player, newLevel, oldLevel, newEXP);
	
		ATOMLog:LogScoreRestore("Restore", "%s$9 Degraded to Level %s", player:GetName(), newLevel);
		SendMsg({INFO,BLE_INFO}, player, "%s Advanced to Level %s", player:GetName(), newLevel);
	
	end;
	----------------
	ConvertTable = function(self)
		local t = {};
		for i, v in pairs(self.savedEXP) do
			if (CanScore(i)) then
				t[arrSize(t)+1] = {
					i,
					v.EXP,
					v.Level,
					v.NextLevel,
					v.Previous
				};
			end;
		end;
		return t;
	end;
	----------------
	OnDisconnect = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier and self.savedEXP[identifier]) then
			self:OnEXPChange();
		end;
	end;
	----------------
	LoadData = function(self, id, exp, level, next, previous)
		self.savedEXP[id] = {
			EXP = exp,
			Level = level,
			NextLevel = next,
			Previous = previous
		};
	end;
	----------------
	SaveFile = function(self)
		SaveFile("ATOMLevels", "Levels.lua", "ATOMLevelSystem:LoadData", self:ConvertTable(self.savedEXP));
	end;
	----------------
	LoadFile = function(self)
		LoadFile("ATOMLevels", "Levels.lua");
	end;
	----------------


};