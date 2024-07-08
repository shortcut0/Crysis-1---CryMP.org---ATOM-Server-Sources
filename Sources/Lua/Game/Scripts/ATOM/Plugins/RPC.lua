RPC = {
	ctr = 0;
	----------
	cb_storage = {};
	----------
	spawnCounter = 0;
	----------
	spawnedEntities = {};
	----------
	Await = function(self, id, cb, timeo)
		timeo = timeo or 5
		local players = { }
		if id[3] then
			local pl = g_gameRules.game:GetPlayers() or {};
			for i, v in pairs(pl) do
				if v.id ~= (id[2] or {}).id then
					players[#players + 1] = v
					if not v.rpcFinished then
						v.rpcFinished = {}
					end
					v.rpcFinished[id[1]] = false
				end
			end
		else
			players = { id[2] }
			if not id[2].rpcFinished then
				id[2].rpcFinished = {}
			end
			id[2].rpcFinished[id[1]] = false
		end
		self.cb_storage[id[1]] = {
			players = players,
			t = _time,
			expire = _time + timeo,
			fn = cb
		}
	end;
	----------
	OnAll = function(self, a, b, c)


		local noClientPlayers = {};
		for i, player in pairs(GetPlayers()) do
			if (not player.ATOM_Client and _time - player.installStart > 30) then
				table.insert(noClientPlayers, player);
			end;
		end;
		
		if (arrSize(noClientPlayers) == 1) then
			SysLog("Found 1 player without client, RPC on others")
			return self:OnOthers(noClientPlayers[1], a, b, c);
		elseif (arrSize(noClientPlayers) > 1) then
			SysLog("Found more than 1 player without client, RPC on players")
			for i, player in pairs(noClientPlayers) do
				self:OnPlayer(player, a, b, c);
			end;
			return;
		end;

		local payload = {}
		payload.id = self.ctr
		self.ctr = self.ctr + 1
		if type(b) == "string" then
			payload.class = a
			payload.method = b
			payload.params = c or {}
		else
			payload.method = a
			payload.params = b or {}
		end
		
		self:CheckCode(payload);
		SysLog("OnAll > %s", json.encode(payload))
		
		g_gameRules.allClients:ClStartWorking(ATOM.Server.id, "@" .. json.encode(payload));
		
		return { payload.id, nil, true }
	end;
	----------
	OnPlayer = function(self, player, a, b, c)
		
		if (type(player) == "table" and not player.actor:IsPlayer()) then
			return
		end
		
		if (player.installStart and _time - player.installStart > 30 and not player.ATOM_Client) then -- Player not using Supportive client for this
			SysLog("Dropping RPC on player %s (client timeout)", player:GetName())
			return
		end

		local payload = {}
		
		local channelId = (type(player) == "table" and player.actor:GetChannel() or player);
		
		payload.id = self.ctr;
		self.ctr = self.ctr + 1
		
		if type(b) == "string" then
			payload.class = a
			payload.method = b
			payload.params = c or {}
		else
			payload.method = a
			payload.params = b or {}
		end
		
		self:CheckCode(payload);
		SysLog("OnPlayer(%d) > %s", channelId, json.encode(payload))
		
		g_gameRules.onClient:ClStartWorking(channelId, ATOM.Server.id, "@" .. json.encode(payload));
		
		return { payload.id, player, false }
	end;
	----------
	StreamEntitiesForPlayer = function(self, player)
		--[[self.spawnCounter = self.spawnCounter or 0
		player.rpcSpawnCounter = player.rpcSpawnCounter or 0
		--printf("Player: %d, Server: %d", player.rpcSpawnCounter, self.spawnCounter)
		if player.rpcSpawnCounter < self.spawnCounter then
			local mn = math.min(player.rpcSpawnCounter + 16, self.spawnCounter)
			for i=player.rpcSpawnCounter, mn - 0 do
				local j = i + 1
				if self.spawnedEntities[i] then
					local ent = self.spawnedEntities[i][2]
					local par = self.spawnedEntities[i][1]
					if ent then
						if not (ent.vehicle or ent.weapon or ent.class == "Player") then
							self:CallOne(player, "SpawnEntity", par)
						end
					end
				end
				player.rpcSpawnCounter = i
				--Debug("I: "..i.." Player: "..player.rpcSpawnCounter.." Server: "..self.spawnCounter)
			end
		end--]]
	end;
	----------
	CheckCode = function(self, params)
		if (params and params.code) then
			if (params.code:match("^EX: (.*)")) then
				params.code = params.code:sub(5);
			end;
		end;
	end;
	----------
	OnOthers = function(self, player, a, b, c)
		if (g_gameRules.game:GetPlayerCount(true)<1) then return; end;

		local payload = {}
		if (not player.actor) then return end;
		
		local channelId=player.actor:GetChannel();
		
		payload.id = self.ctr
		self.ctr = self.ctr + 1
		
		if type(b) == "string" then
			payload.class = a
			payload.method = b
			payload.params = c or {}
		else
			payload.method = a
			payload.params = b or {}
		end
		
		self:CheckCode(payload);
		SysLog("OnOthers > %s", json.encode(payload))
		g_gameRules.otherClients:ClStartWorking(channelId, ATOM.Server.id, "@" .. json.encode(payload))
		
		return { payload.id, player, true }
	end;
	----------
	OnMapStart = function(self)
	--	CryFire.allEntsTable = nil
		self.spawnedEntities = {};
		self.spawnCounter = 0;
	end;
	----------
}