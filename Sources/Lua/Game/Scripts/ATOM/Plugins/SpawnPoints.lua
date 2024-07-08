ATOMSpawns = {
	cfg = {
		UseClosestSpawn = false, -- Spawn Players at closest spawn point
		UseGroupSpawn = false, -- Spawns players at spawn closest to other players
		ReduceSpawns = true, -- Reduce available spawn points
		BlacklistedMaps = {
			["aimmapv2"] = true,
			["poolday_v2"] = true,
			["dsg_1_aim"] = true
		}
	},
	AvailableSpawns = {},
	-------------------
	--      Init
	-------------------
	Init = function(self) -- Call when player connects
	
		if (Config) then
			self.cfg = mergeTables(self.cfg, Config.ATOM.SpawnPoints);
		end;
		
		--SysLog("SpawnPoints Plugin - Map: %s (System Active: %s)", ATOM:GetMapName(true):lower(), tostring(self.cfg.BlacklistedMaps[ATOM:GetMapName(true):lower()]~=true and "Yes" or "No"))
		if (g_gameRules.class ~= "InstantAction" or self.cfg.BlacklistedMaps[ATOM:GetMapName(true):lower()]) then
			return false;
		end;
		local allSpawns = System.GetEntitiesByClass("SpawnPoint");
		self.AvailableSpawns = allSpawns;
		if (arrSize(allSpawns) == 1) then
			return false;
		end;
		
		for i, spawn in pairs(allSpawns) do
			self:Enable(spawn, false); -- First disable all
		end;
		local playerCount = arrSize(GetPlayers()) * 2;
		if (playerCount == 0) then
			playerCount = 1;
		end;
		local enabled = 0;
		if (playerCount < arrSize(allSpawns)) then
			local randomSpawn;
			local antiHang = 0;
			while enabled < playerCount do
				randomSpawn = allSpawns[math.random(arrSize(allSpawns))];
				if (not randomSpawn.isEnabled) then
					enabled = enabled + 1;
					self:Enable(randomSpawn, true);
				end;
				antiHang = antiHang + 1;
				if (antiHang > 100) then
					SysLog("Anti Hang prevented hang in ATOMSpawns.Init.while");
					break;
				end;
			end;
			SysLog("Enabled %d spawns", enabled)
		else -- enable all
			for i, spawn in pairs(allSpawns) do
				self:Enable(spawn, true); -- First disable all
			end;
			--SysLog("Too many players, enabling all spawns")
		end;
	end,
	-------------------
	--    Enable
	-------------------
	Enable = function(self, spawn, enable)
		spawn.isEnabled = enable;
		spawn:Enable(enable);
	end,
	-------------------
	--    CustomSpawnsEnabled
	-------------------
	CustomSpawnsEnabled = function(self)
		return (self.cfg.UseClosestSpawn or self.cfg.UseGroupSpawn) and arrSize(GetPlayers()) > 1;
	end,
	-------------------
	--  GetSpawnLocation
	-------------------
	GetSpawnLocation = function(self, playerId)
		local player = GetEnt(playerId);
		local playerPos = player:GetPos();
		local closest = 1000;
		local spawnId;
		if (self.cfg.UseClosestSpawn) then
			for i, v in pairs(self.AvailableSpawns) do
				if (GetDistance(player, v) < closest) then
					spawnId = v.id
					closest = GetDistance(player, v);
				--	SysLog("Closest spawn: %f", closest)
				end;
			end;
			return spawnId, 0;
		end;
		if (self.cfg.UseGroupSpawn) then
			local spawnsWithEnemies = {};
			local enemies = {};
			local temp;
			for i, v in pairs(self.AvailableSpawns) do
				enemies = System.GetEntitiesInSphereByClass(v:GetPos(), 30, "Player");
				if (arrSize(enemies) > 1) then
					temp = System.GetNearestEntityByClass(v:GetPos(), 30, "Player");
					table.insert(spawnsWithEnemies, { v.id, arrSize(enemies), temp });
				--	SysLog("There are %d enemies close to %s spawn %f", arrSize(enemies), v:GetName(), GetDistance(temp,v));
				end;
			end;
			if (arrSize(spawnsWithEnemies) > 0) then
				table.sort(spawnsWithEnemies, function(a,b) return a[2]>b[2] end);
				local most = spawnsWithEnemies[1][2];
				for i, v in pairs(spawnsWithEnemies) do
					if (v[2] < most) then
						table.remove(spawnsWithEnemies, i);
					end;
				end;
				local ne;
				for i, v in pairs(spawnsWithEnemies) do
					if (GetDistance(v[3], GetEnt(v[1])) < closest) then
						closest=GetDistance(v[3], GetEnt(v[1]))
						spawnId=v[1]
						ne=v[3]
					end;
				end;
				--SysLog("Selected: %s, %f", GetEnt(spawnId):GetName(), GetDistance(ne,GetEnt(spawnId)))
			end;
			return spawnId, nil;
		end;
	end,
	

};

ATOMSpawns:Init();