ATOMGameRules = {
	cfg = {};
	------------
	f = {};
	------------
	Server = {};
	------------
	Client = {};
	------------
	toHook = {};
	------------
	Add = function(self, ...)
		self.toHook[ arrSize(self.toHook) + 1 ] = {...};
	end;
	------------
	Init = function(self)
		
		ATOMLog:Log("Hooked " .. arrSize(self.toHook) .. " Game Rule functions");
		
		for i, f in pairs(self.toHook) do
			local name = f[1];
			local func = f[2];
			local part = f[3];
			local type = f[4];
			
			if (part) then
				if (type) then
					--Debug("g_gameRules." .. type .. "." .. part .. "." .. name .. "=",func)
					self.f[part] = self.f[part] or {};
					self.f[part][type] = self.f[part][type] or {};
					self.f[part][type][name] = func;
					
					loadstring([[
						function g_gameRules.]]..part..[[.]]..type..[[:]] .. name .. [[(...)
							return ATOMGameRules.f.]]..part..[[.]]..type..[[.]] .. name .. [[(self,...);
						end;
						--Debug("g_gameRules.]]..part..[[.]]..type..[[:]]..name..[[(...)");
					]])();
				else
					self.f[part] = self.f[part] or {};
					self.f[part][name] = func;
					
					loadstring([[
						function g_gameRules.]]..part..[[:]] .. name .. [[(...)
							return ATOMGameRules.f.]]..part..[[.]] .. name .. [[(self,...);
						end;
						g_gameRules.]]..part..[[.InGame.]] .. name .. [[ = g_gameRules.]]..part..[[.]] .. name .. [[;
						g_gameRules.]]..part..[[.PreGame.]] .. name .. [[ = g_gameRules.]]..part..[[.]] .. name .. [[;
						g_gameRules.]]..part..[[.PostGame.]] .. name .. [[ = g_gameRules.]]..part..[[.]] .. name .. [[;
						g_gameRules.]]..part..[[.Reset.]] .. name .. [[ = g_gameRules.]]..part..[[.]] .. name .. [[;
						
						--Debug(">>g_gameRules.]]..part..[[:]]..name..[[(...)");
					]])();
				end;
			elseif (type) then
				self.f[type] = self.f[type] or {};
				self.f[type][name] = func;
				
				loadstring([[
					function g_gameRules.]]..type..[[:]] .. name .. [[(...)
						return ATOMGameRules.f.]]..type..[[.]] .. name .. [[(self,...);
					end;
					--Debug("g_gameRules.]]..type..[[:]]..name..[[(...)");
				]])();
				--Debug("g_gameRules." .. type .. "." .. name .. "=",func)
			else
				self.f[name] = func;
				
				loadstring([[
					function g_gameRules:]] .. name .. [[(...)
						return ATOMGameRules.f.]] .. name .. [[(self,...);
					end;
					--Debug("g_gameRules:]]..name..[[(...)");
				]])();
			end;
		
		end;
		--[[
		Script.SetTimer(1, function()
			if (g_gameRules.old_factory_teams) then
				for i, v in pairs(g_gameRules.old_factory_teams) do
				--	SysLog("RESTORING team of factory %s (%d)", v[1]:GetName(),v[2]);
					--v[1]:Capture(v[2]);
					v[1]:SetTeamId(v[2]);
					v[1].captured=true;
					v[1].capturing=false;
					v[1].capturingTeamId=nil;
					v[1].capturingTimer=nil;
					v[1].lastCapturingTimer=nil;
					g_game:SetTeam(v[2], v[1].id);
					
					
				end;
			end;
		end);--]]
		ATOMDLL:InitGRScripts(); -- Updates c++ scrip tables
		
		do return end
		for i, f in pairs(self.toHook) do
			local name = f[1];
			local func = f[2];
			local part = f[3];
			local type = f[4];
			
			if (part) then
				if (type) then
				--	Debug("g_gameRules." .. type .. "." .. part .. "." .. name .. "=",func)
					g_gameRules[part][type][name] = func;
				else
					for ii,vv in pairs(g_gameRules[part]) do
						if (ii==name) then
							--Debug("Patched >>>>" .. name)
							g_gameRules[part][ii] = nil;--func;
							g_gameRules[part][ii] = func;--func;
						end;
					end;
					g_gameRules[part][name] = func;
					
					g_gameRules[part].InGame  [name]	= g_gameRules[part][name];
					g_gameRules[part].PreGame [name]	= g_gameRules[part][name];
					g_gameRules[part].Reset   [name]	= g_gameRules[part][name];
					g_gameRules[part].PostGame[name] 	= g_gameRules[part][name];
				--	Debug("g_gameRules." .. part .. ".InGame."..name .. "=",func)
				--	Debug("g_gameRules." .. part .. "." .. name .. "=",func)
				end;
			elseif (type) then
				g_gameRules[type][name] = func;
				--Debug("g_gameRules." .. type .. "." .. name .. "=",func)
			else
				for ii,vv in pairs(g_gameRules) do
					if (ii==name) then
						g_gameRules[ii] = func;
					end;
				end;
				
				--if (not g_gameRules[name]) then
					g_gameRules[name] = func;
				--end;
				
				g_gameRules["Server"].InGame  [name]	= g_gameRules[name];
				g_gameRules["Server"].PreGame [name]	= g_gameRules[name];
				g_gameRules["Server"].Reset   [name]	= g_gameRules[name];
				g_gameRules["Server"].PostGame[name] 	= g_gameRules[name];
			end;
		
		end;
		
		do return end
		-- this was before I noticed you need to re-register script tables in C++ to update changes made to certain functions.
		
		for i, func in pairs(self.toHook) do
			
			if (func[3]) then
				if (func[4]) then
					Debug("g_gameRules["..func[3].."]["..func[4].."]["..func[1].."] =",func[2])
					g_gameRules[func[3]][func[4]][func[1]]	= func[2];
				else
					Debug("g_gameRules["..func[3].."]["..func[1].."] =",func[2])
					g_gameRules[func[3]][func[1]]			= func[2];
				end;
			else
				if (func[4]) then
					g_gameRules[func[4]][func[1]]	= func[2];
				else
					g_gameRules[func[1]]			= func[2];
				end;
			end;
			
			if (func[3]) then
				if (func[4]) then
				--	Debug("ONLY >> " .. func[4])
					g_gameRules[func[3]][func[4]]	[func[1]] 	= g_gameRules[func[3]][func[4]][func[1]];
				--	g_gameRules[func[3]].PreGame	[func[1]] 	= g_gameRules[func[3]][func[1]];
				--	g_gameRules[func[3]].PostGame	[func[1]] 	= g_gameRules[func[3]][func[1]];
				--	g_gameRules[func[3]].Reset		[func[1]] 	= g_gameRules[func[3]][func[1]];
				else
				--	Debug("ALL ONLY >> " .. func[1])
					g_gameRules[func[3]].InGame		[func[1]] 	= g_gameRules[func[3]][func[1]];
					g_gameRules[func[3]].PreGame	[func[1]] 	= func[2]; --g_gameRules[func[3]][func[1]];
					g_gameRules[func[3]].PostGame	[func[1]] 	= func[2]; --g_gameRules[func[3]][func[1]];
					g_gameRules[func[3]].Reset		[func[1]] 	= func[2]; --g_gameRules[func[3]][func[1]];
			
					--Debug(func[2])
					--Debug(g_gameRules[func[3]].InGame		["RequestSpectatorTarget"])
				end;
			elseif (func[4]) then
			--	g_gameRules[func[3]][func[4]	[func[1]] 	= g_gameRules[func[3]][func[1]];
			else
			--	g_gameRules.InGame				[func[1]] 	= g_gameRules[func[1]];
			--	g_gameRules.PreGame				[func[1]] 	= g_gameRules[func[1]];
			--	g_gameRules.PostGame			[func[1]] 	= g_gameRules[func[1]];
			--	g_gameRules.Reset				[func[1]] 	= g_gameRules[func[1]];
			end;
		end;

	end;
};
--[[
ATOMGameRules:Add('', function(self)
	local curr = nCX.GetCurrentLevel():sub(16, -1):lower();
	local command = "sv_restart";
	--if (nCX.LevelRotation and (nCX.Count(nCX.LevelRotation) > 1 or not nCX.LevelRotation[curr])) then
	--	command = "g_nextlevel";
	--end
	if (nCX.NextMap) then
		local gr = nCX.MapList[nCX.NextMap];
		if (gr) then
			gr = gr == "TeamInstantAction" and "InstantAction" or gr;
			System.ExecuteCommand("sv_gamerules "..gr);
			command = "map "..nCX.NextMap;
			nCX.EndGame();
		end
	end
	CryMP:HandleEvent("OnGameEnd", {0, type, winningPlayerId});
	CryMP:SetTimer(10, function()
		System.ExecuteCommand(command);
		nCX.NextMap = nil;
	end);		
	nCX.GameEnd = true;
end);--]]




ATOMGameRules:Add('OnChangeTeam', function(self, playerId, teamId)

	local state = self:GetState();
	local oldTeamId = self.game:GetTeam(playerId);
	
	if (teamId ~= oldTeamId) then
		local player=System.GetEntity(playerId);
		if (player) then
			if (player.last_team_change and teamId ~= 0) then
				if (state == "InGame") then
					if (_time - player.last_team_change < self.TEAM_CHANGE_MIN_TIME) then
						if ((not player.last_team_change_warning) or (_time - player.last_team_change_warning >= 4)) then
							player.last_team_change_warning = _time;
							self.game:SendTextMessage(TextMessageError, "@mp_TeamChangeLimit", TextMessageToClient, playerId, self.TEAM_CHANGE_MIN_TIME - math.floor(_time - player.last_team_change+0.5));
						end
						return;
					end
				end
			end
			
			if (self.IsTeamLocked and self:IsTeamLocked(teamId, playerId)) then
				if ((not player.last_team_locked_warning) or (_time-player.last_team_locked_warning >= 4)) then
					player.last_team_locked_warning = _time;
					SysLog("team change request by %s denied: team %d has too many players", EntityName(playerId), teamId);
					self.game:SendTextMessage(TextMessageError, "@mp_TeamLockedTooMany", TextMessageToClient, playerId);
				end
				return;
			end
			
			if (player.actor:GetHealth()>0 and player.actor:GetSpectatorMode()==0) then
				self:KillPlayer(player);
			end
		
			if (teamId ~= 0) then	
				if (self.QueueRevive) then
					self:QueueRevive(playerId); end
				self.game:SetTeam(teamId, playerId);
				self.Server.RequestSpawnGroup(self, player.id, self.game:GetTeamDefaultSpawnGroup(teamId) or NULL_ENTITY, true);
				
				player.last_team_change=_time;
			end;
		end;

		for i,factory in pairs(self.factories) do
			factory:CancelJobForPlayer(playerId);
		end;
	else
		SendMsg(ERROR, GetEnt(playerId), "Already in team %s", GetTeamName(teamId))
	end;
end, "Server");


ATOMGameRules:Add('ProcessActorDamage', function(self, hit)

	---------
	if (not ATOM:ProcessHit(hit)) then
		return false end
	
	---------
	self:OnHit(hit, dead)

	---------
	local hTarget = hit.target
	local iHealth = hTarget.actor:GetHealth()
	
	---------
	iHealth = math.floor(iHealth - hit.damage * (1 - self:GetDamageAbsorption(hTarget, hit)))
	hTarget.actor:SetHealth(iHealth)

	---------
	local bDead = (iHealth <= 0)
	return bDead
end);

--https://youtu.be/EnyiGmM5M7Y

ATOMGameRules:Add("AwardKillCP", function(self, hit)
	local cp = self:CalcKillCP(hit);
	self:AwardCPCount(hit.shooter.id, cp);
end);

ATOMGameRules:Add("OnPerimeterBreached", function(self, base, entity)
	self.LastPerimeterAlert = self.LastPerimeterAlert or {};
	if (entity) then
		--Debug("base team:",g_game:GetTeam(base.id),"intruderteam:",g_game:GetTeam(entity.id))
		if (not sameTeam(base.id, entity.id)) then
			if (_time - (self.LastPerimeterAlert[entity.id] or 0) >= 60) then
				self.LastPerimeterAlert[entity.id] = _time;
				local players = DoGetPlayers({sameTeam = true, teamId = g_game:GetTeam(base.id)});
				if (players) then
				--	Debug("BREACHED UWUW");
					for i, p in pairs(players) do
						local channelId = p:GetChannel();
						self.onClient:ClPerimeterBreached(channelId, base.id);
					end
				end
			end
		end
	end
	--[[
	if (entity) then
		if (entering and areaId ~= -1 and not sameTeam(base.id, entity.id)) then
			if (_time - (self.LastAlert.Perimeter[areaId] or 0) >= 5) then
				self.LastAlert.Perimeter[areaId] = _time;
				local players = DoGetPlayers({teamId = g_game:GetTeam(entity.id)});
					if (players) then
					Debug("BREACHED UWUW");
					for i, p in pairs(players) do
						local channelId = p:GetChannel();
						self.onClient:ClPerimeterBreached(channelId, base.id);
					end
				end
			end
		end
	end
	ATOMBroadcastEvent("OnPerimeterBreached", base, entity);
	--]]
end);

ATOMGameRules:Add("CheckPerimeter", function(self)
	if (self.class ~= "PowerStruggle") then
		return;
	end;
	local outside = {};
	for index, hqId in pairs(self.hqs) do
		local hq = GetEnt(hqId);
		--Debug(hq)
		if (hq) then
			local breached, rest = DoGetPlayers({others = true, range = 150, pos = hq:GetPos(), teamId = g_game:GetTeam(hqId), sameTeam = false });
			if (#breached > 0) then
				for i, player in pairs(breached) do
					if (not player:IsSpectating() and player:GetTeam() ~= g_game:GetTeam(hqId)) then
						self:OnPerimeterBreached(hq, player);
						outside[player.id] = nil;
						--Debug("enter")
					end
				end;
			end;
		end;
	end;
end);


ATOMGameRules:Add("AwardPPCount", function(self, playerId, c, why, NO_BLE)
	if (c>0) then
		local g_pp_scale_income = System.GetCVar("g_pp_scale_income");
		if (g_pp_scale_income) then
			c = math.floor(c * math.max(0, g_pp_scale_income));
		end
	end

	local total = self:GetPlayerPP(playerId)+c;
	self:SetPlayerPP(playerId, math.max(0, total));

	local player=System.GetEntity(playerId);
	if (player and not NO_BLE) then
		self.onClient:ClPP(player.actor:GetChannel(), c);
	end

	CryAction.SendGameplayEvent(playerId, eGE_Currency, nil, total);
	CryAction.SendGameplayEvent(playerId, eGE_Currency, why, c);
end);


ATOMGameRules:Add("AwardAssistPPAndCP", function(self, hit)

	--Debug("AWARD IT !!")
	if (self.class ~= "PowerStruggle") then return end
	
	if (not ATOM.cfg.GamePlayConfig.KillAssistReward or not hit.shooter) then
		return;
	end;
	
	local method = ATOM.cfg.GamePlayConfig.KillAssistMethod;
	
	local pp = self:CalcKillPP(hit);
	local cp = self:CalcKillCP(hit);
	local target = hit.target;
	local shooter = hit.shooter;
	
	if (target and shooter and target.id ~= shooter.id) then
		local all = target.allHits;
		if (not all) then
			return;
		end;
		local tHits = 0;
		local tDmg = 0;
		for _, __ in pairs(all or {}) do
			if (_ ~= target.id and GetEnt(_) ~= nil) then
				-- only add hits from players who actually assisted in the kill
				if (_time - __[1] < 10) then
					tHits = tHits + __[2];
					tDmg = tDmg + __[3];
					--Debug("tHits",tHits)
				end;
			end;
		end;
		local hitPerc = 0;
		for _, __ in pairs(all or {}) do
			if (_time - __[1] < 10 and GetEnt(_) and _ ~= shooter.id) then
				hitPerc = (__[2] / tHits)
				if (method == 2) then
					hitPerc = (__[3] / tDmg);
				end;
				
				SendMsg(BLE_CURRENCY, GetEnt(_), "KILL : ASSIST ( %d PP + %d CP )", pp * hitPerc, cp * hitPerc);
				self:AwardPPCount(_, round(min(0, pp * hitPerc)), nil, true);
				self:AwardCPCount(_, round(min(0, cp * hitPerc)));
				--SendMsg(CHAT_ATOM, ALL,"KILL : ASSIST ( %dPP + %dCP )", pp * hitPerc, 0);
				--Debug("hit percent for kill: " .. hitPerc*100,__[2],"/",tHits,	"toal pp",pp,"assist amount",pp*hitPerc)
			end;
		end;
	end;

end);

ATOMGameRules:Add("OnCapture", function(self, spawnGroup, teamId)
	--SysLog("---------------------------------------------------------%s", debug.traceback())
	--Debug("check captureedby")
	--Debug("spawn group",spawnGroup:GetName())
	spawnGroup.capturedBy = {};
	local players = spawnGroup.inside;
	if (players) then
		
		for i,playerId in ipairs(players) do
			if (g_gameRules.game:GetTeam(playerId)==teamId) then
				local player=System.GetEntity(playerId);
				if (player and player.actor and (not player:IsDead()) and (player.actor:GetSpectatorMode() == 0)) then
					spawnGroup.capturedBy[player.actor:GetChannel()] = player;
					if (not player.CaptureShareFeatureMessage or _time - player.CaptureShareFeatureMessage > 600) then
						-- SendMsg(CENTER, player, "You Captured a Building! Whenever a Player spawns here or buys an item, you will get a small Share of their invest!")
						player.CaptureShareFeatureMessage = _time
					end
					Debug("added captureedby ",player:GetName())
				end
			end
		end
	end
	
	local aBuyOptions = checkArray(spawnGroup.Properties or {}).buyOptions
	if (aBuyOptions) then
		if (aBuyOptions.bPrototypes) then
			Debug("proto swap team ??")
		end
	end

end, "Server");

ATOMGameRules:Add("OnUncapture", function(self, spawnGroup, teamId)
	spawnGroup.capturedBy = {};
	Debug("reset captureedby")
end, "Server");

ATOMGameRules:Add("CheckSpawnPP", function(self, player, isVehicle, spawn)

	--Debug("AWARD IT !!")
	
	if (not ATOM.cfg.GamePlayConfig.AwardSpawnPP) then
		return;
	end;
	
	local val = (isVehicle and ATOM.cfg.GamePlayConfig.VehicleSpawnAward or ATOM.cfg.GamePlayConfig.BunkerSpawnAward);
	if (not isVehicle) then
		Debug("bunga")
		Debug(spawn:GetName())
		local p;
		for chan, pl in pairs(spawn.capturedBy or {}) do
			p = self.game:GetPlayerByChannelId(chan);
			Debug("chan",chan)
			if (p and p.id ~= player.id) then
				Debug("Spawned in bunker reward");
				SendMsg(BLE_CURRENCY, p, "Ally Bunker Spawn ( +%d PP )", val);
				self:AwardPPCount(p.id, round(min(0, val)), nil, true);
				SysLog("awarding %d pp to %s for %s spawning in their captured bunker", val, p:GetName(), player:GetName());
			end;
		end;
	else
		Debug("Carra")
		local owner = GetEnt(spawn.vehicle:GetOwnerId()) or (spawn.ownerID and GetEnt(spawn.ownerID));
		if (owner and owner.isPlayer) then
			Debug("Spawned in bunker reward");
			SendMsg(BLE_CURRENCY, owner, "Ally Vehicle Spawn ( +%d PP )", val);
			self:AwardPPCount(owner.id, round(min(0, val)), nil, true);
			SysLog("awarding %d pp to %s for %s spawning in their spawn truck", val, owner:GetName(), player:GetName());
		end;
	end;


end);

ATOMGameRules:Add("AwardKillPP", function(self, hit)
	--Debug("AWARD IT !!")
	local pp = self:CalcKillPP(hit);
	--local tgt = hit.target;
	--local sht = hit.shooter;
	--[[
	if (tgt and tgt.id ~= sht.id) then
		local all = tgt.allHits;
		local tHits = 0;
		for _, __ in pairs(all) do
			Debug(_~=tgt.id and GetEnt(_)~=nil)
			if (_ ~= tgt.id and GetEnt(_) ~= nil) then
				-- only add hits from players who actually assisted in the kill
				if (_time - __[1] < 10) then
					tHits = tHits + __[2];
					--Debug("tHits",tHits)
				end;
			end;
		end;
		local hitPerc = 0;
		for _, __ in pairs(all) do
			if (_time - __[1] < 10 and GetEnt(_) and _ ~= sht.id) then
				hitPerc = (__[2] / tHits)
				SendMsg(BLE_CURRENCY, GetEnt(_), "KILL : ASSIST ( %dPP + %dCP )", pp * hitPerc, cp * hitPerc);
				self:AwardPPCount(_, round(min(0, pp * hitPerc)), nil, true);
				--SendMsg(CHAT_ATOM, ALL,"KILL : ASSIST ( %dPP + %dCP )", pp * hitPerc, 0);
				--Debug("hit percent for kill: " .. hitPerc*100,__[2],"/",tHits,	"toal pp",pp,"assist amount",pp*hitPerc)
			end;
		end;
	end;
	--tgt.allHits = {};
	--always award killer full PP, but "helpers" only a part
	--]]
	local playerId = hit.shooter.id;
	self:AwardPPCount(playerId, pp);
end);

ATOMGameRules:Add("CalcKillPP", function(self, hit)
	if (self.class ~= "PowerStruggle") then
		return
	end;
		local target=hit.target;
		local shooter=hit.shooter;
		local headshot=self:IsHeadShot(hit);
		local melee=hit.type=="melee";

		if (shooter and target ~= shooter) then
			local team1=self.game:GetTeam(shooter.id);
			local team2=self.game:GetTeam(target.id);
			if (team1 ~= team2) then
				local ownRank = self:GetPlayerRank(shooter.id);
				local enemyRank = self:GetPlayerRank(target.id);
				local bonus=0;
				
				if (headshot) then
					bonus=bonus+self.ppList.HEADSHOT;
				end
				
				if (melee) then
					bonus=bonus+self.ppList.MELEE;
				end
				
				local rankDiff=enemyRank-ownRank;
				if (rankDiff~=0) then
					bonus=bonus+rankDiff*self.ppList.KILL_RANKDIFF_MULT;
				end
				
				-- check if inside a factory
				for i,factory in pairs(self.factories) do
					local factoryTeamId=self.game:GetTeam(factory.id);
					if (factory:IsPlayerInside(hit.targetId) and (factoryTeamId~=team2) and (factoryTeamId==team1)) then
						bonus=bonus+self.defenseValue[factory:GetCaptureIndex() or 0] or 0;
					end
				end

				return math.max(0, (self.ppList.KILL+bonus) * ATOM.cfg.GamePlayConfig.PremiumKillPP);
			else
				return self.ppList.TEAMKILL;
			end
		else
			return self.ppList.SUICIDE;
		end
end);

ATOMGameRules:Add("OnHit", function(self, hit, deadHit)
	-- Debug("CLIENT hit",hit.damage)
	local shooter 	= hit.shooter;
	local target 	= hit.target
	local weapon 	= hit.weapon;
	
	if (shooter and target) then
		if (shooter.actor and target.actor and not shooter.actor:IsPlayer() and not target.actor:IsPlayer()) then
			self.OnHit(self, hit, deadHit)
		end
	end

	
end, "Client");

ATOMGameRules:Add("OnHit", function(self, hit, deadHit)
	-- Debug("Dibag hit",hit.damage)
	local shooter 	= hit.shooter;
	local target 	= hit.target
	local weapon 	= hit.weapon;

	if (self.class == "PowerStruggle") then
		if (shooter and target and shooter ~= target and shooter.isPlayer and target.class == "Player" and g_game:GetTeam(shooter.id) ~= g_game:GetTeam(target.id)) then
			if (not target.allHits) then
				target.allHits = {};
			end;
			target.allHits[shooter.id] = target.allHits[shooter.id] or {
				_time,
				0,
				0
			};
			target.allHits[shooter.id][2] = target.allHits[shooter.id][2] + 1;
			target.allHits[shooter.id][3] = target.allHits[shooter.id][3] + hit.damage;
		end;
	end;

	if (shooter) then
		if (target) then
			if (shooter ~= target) then

				if (target.isPlayer) then
					if (shooter ~= target and not hit.explosion) then
						targetPos = target:GetPos();
						hitPos = {
							x = targetPos.x - tonumber(hit.pos.x);
							y = targetPos.y - tonumber(hit.pos.y);
							z = targetPos.z - tonumber(hit.pos.z);
						};
						if (not shooter.HitAccuracy or (shooter.HitAccuracy and shooter.HitAccuracy.targetId ~= target.id)) then
							shooter.HitAccuracy = {
								firstHit = true;
								pos = hitPos or {
									x = targetPos.x - tonumber(hit.pos.x);
									y = targetPos.y - tonumber(hit.pos.y);
									z = targetPos.z - tonumber(hit.pos.z);
								};
								targetId = target.id;
								shots = {};
							};
						end;
						--Debug("Distance SHOOTER + TARGET = " .. GetDistance(shooter,target))
						--Debug(GetDistance(shooter.HitAccuracy.pos,hitPos))
						
						local bdist = GetDistance(hit.pos,hit.target:GetBonePos("Bip01 Head"));
						if (bdist > GetDistance(hit.pos,hit.target:GetBonePos("Bip01 Pelvis"))) then
							bdist = GetDistance(hit.pos,hit.target:GetBonePos("Bip01 Pelvis"))
						end;
						table.insert(shooter.HitAccuracy.shots, {["c"]=bdist;["a"]=(shooter.HitAccuracy.firstHit==true and 0 or GetDistance(shooter.HitAccuracy.pos,hitPos));["b"]=GetDistance(shooter,target)});
						shooter.HitAccuracy = {
							firstHit = false;
							pos = hitPos;
							targetId = target.id;
							shots = (((shooter.HitAccuracy.targetId and shooter.HitAccuracy.targetId == target.id) and shooter.HitAccuracy.shots) and (shooter.HitAccuracy.shots or {}) or {});
						};
						while #shooter.HitAccuracy.shots > 5 do
							table.remove(shooter.HitAccuracy.shots, 1);
						end;
		--				CalculatePrecision(shooter, true)
					end;
				end;
			end;
		end;
	end;
end);

ATOMGameRules:Add('OnBeginState', function(self)
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameEnd, "", 1);--server
	
	self:StartTicking();
	self:SetTimer(self.NEXTLEVEL_TIMERID, self.NEXTLEVEL_TIME);
	
end, "Server", "PostGame");





ATOMGameRules:Add('ProtectBunker', function(self, player, bunker, hasMG, hasRockets)
	local pos = bunker:GetPos();
	pos.z = pos.z + 2.0;
	
	if (bunker.HasProtection) then
		System.RemoveEntity(bunker.ProtectionTurret.id);
		bunker.HasProtection = false;
		bunker.ProtectionTurret = nil;
	end;
	
	bunker.HasProtection = true;
	
	local Turret = _G["AutoTurret"];
	Turret.Properties.teamName = (g_game:GetTeam(player.id) == 2 and "black" or "tan");
	Turret.Properties.objModel = "objects/weapons/multiplayer/air_unit_radar.cgf";
	Turret.Properties.objBarrel = "objects/weapons/multiplayer/ground_unit_gun.cgf";
	Turret.Properties.objBase = "objects/weapons/multiplayer/ground_unit_mount.cgf";
	Turret.Properties.objDestroyed = "objects/weapons/multiplayer/air_unit_destroyed.cgf";
	Turret.Properties.GunTurret.bEnabled = 1
	Turret.Properties.GunTurret.TurnSpeed = 3
	Turret.Properties.GunTurret.bVehiclesOnly = 1
	Turret.Properties.GunTurret.bNoPlayers = 1
	Turret.Properties.GunTurret.MGRange = hasMG and 80 or 1;
	Turret.Properties.GunTurret.RocketRange = hasRockets and 60 or 1;
	
	local protection = System.SpawnEntity({ class = "AutoTurret", position = pos, name = "BunkerProtection_" .. g_utils:SpawnCounter() })
		
	CryAction.CreateGameObjectForEntity(protection.id);
	CryAction.BindGameObjectToNetwork(protection.id);
		
	self.game:SetTeam(player:GetTeam(), protection.id);
	
	bunker.ProtectionTurret = protection;
	
	self.spawned_turrets = self.spawned_turrets or {};
	self.spawned_turrets[protection.id] = {
		user = player.id,
		time = _time,
		lifetime = 60,
		bunker = bunker.id;
	};
	
end);

ATOMGameRules:Add('Tick', function(self)
	
	local function repairTurret(turret, damage)
		local hit = {
			typeId	=self.game:GetHitTypeId("repair"),
			type	="repair",
			material=0,
			materialId=0,
			dir		=g_Vectors.up,
			radius	=0,
			partId	=-1,
		};
	
		hit.shooter=turret;
		hit.shooterId=turret.id;
		hit.target=turret;
		hit.targetId=turret.id;
		hit.pos=turret:GetWorldPos(hit.pos);
		hit.damage=damage;
		turret.Server.OnHit(turret, hit);
	end;
	
	local tCfg = ATOM.cfg.DamageConfig.Turrets;
	
	local autoRepair 			= tCfg.AutoRepair;
	local autoRepairReviveTimer = tCfg.ReviveTimer or 60*60*25;
	local autoRepairRevive 		= tCfg.ReviveHealth or 100;
	local autoRepairTick 		= tCfg.RepairHealth or 10;
	local autoRepairTimer 		= tCfg.RepairTimer or 60;
	local autoRepairMax 		= tCfg.RepairMaxHP or 1000;
	
	--SysLog("[AutoRepair] : %s - revive=%f, hp=%f, repair=%f, hp=%f", tostr(autoRepair), autoRepairReviveTimer, autoRepairRevive, autoRepairTimer, autoRepairTick)
	
	if (self.class == "PowerStruggle") then
		local turrets = self.turrets;
		if (autoRepair) then
			for i, v in pairs(turrets or {}) do
				local t = GetEnt(v);
				if (t) then
					if (t.item:IsDestroyed()) then
						t.destroyed_timer = t.destroyed_timer or _time;
						if (t.destroyed_timer and _time - t.destroyed_timer >= autoRepairReviveTimer) then --(60*60*20)
							SysLog("Reparing turret after %s minutes of death time!", round(autoRepairReviveTimer/60));
							--Debug("broken turret uwu");
							repairTurret(t, 100);
						else
						--	Debug("revive in ",_time - t.destroyed_timer)
						end;
					elseif (t:GetHealth() < autoRepairMax and t:GetHealth() < t.item:GetMaxHealth() and _time - (t.LAST_HIT or 999) >= (60 * 5)) then
						if (not t.LastRepairHit or _time - t.LastRepairHit >= autoRepairTimer) then
							--Debug("Repair hti!");
							--Debug(t:GetHealth(),t.item:GetMaxHealth())
							SysLog("Automatic repair hit on %s (hp: %0.2f/%0.2f)", t:GetName(), t:GetHealth(), t.item:GetMaxHealth());
							repairTurret(t, 10);
							t.LastRepairHit = _time;
						end;
					end;
					
					if (t.WAS_HACKED) then
						if (_time - t.HACK_TIMER >= (60 * 5)) then
							g_game:SetTeam(t.OLD_TEAM, t.id)
							t.WAS_HACKED = false
							Debug("RESTORE TEAM !!")
						end
					end
				end;
			end;
		end;
	end;
	
	for i, v in pairs(self.spawned_turrets or {}) do
		if (_time - v.time > v.lifetime) then
			System.RemoveEntity(i);
			self.spawned_turrets[i] = nil;
			if (GetEnt(v.user)) then
				SendMsg(CHAT_ATOM, GetEnt(v.user), "Your Bunker Protection is gone");
			end;
			GetEnt(v.bunker).HasProtection = false;
		end;
	end;
	
end);



ATOMGameRules:Add('OnTurretHit', function(self, turret, hit)
	if (turret and self:GetState()=="InGame") then
		local teamId=self.game:GetTeam(turret.id) or 0;

		turret.LAST_HIT = _time
		if (teamId~=0) then
			if (_time-self.lastTurretHit[teamId]>=5) then
				self.lastTurretHit[teamId]=_time;
				local players=self.game:GetTeamPlayers(teamId, true);
				if (players) then
					for i,p in pairs(players) do
						local channel=p.actor:GetChannel();
						if (channel>0) then
							self.onClient:ClTurretHit(channel, turret.id);
							if (turret.item:IsDestroyed()) then
								self.onClient:ClTurretDestroyed(channel, turret.id);
							end
						end
					end
				end
			end			
				
			if ((teamId==0 or (teamId~=self.game:GetTeam(hit.shooterId))) and turret.item:IsDestroyed()) then
				self:AwardPPCount(hit.shooterId, self.ppList.TURRETKILL);
				self:AwardCPCount(hit.shooterId, self.cpList.TURRETKILL);
				turret.destroyed_timer = _time;
				
			end			
		end
	end
end, "Server");



ATOMGameRules:Add('OnTimer', function(self, timerId, msec)

	if (self.class == "PowerStruggle") then
		if (timerId == self.NUKE_SPECTATE_TIMERID) then
			local players=self.game:GetPlayers();
			local targetplayer = System.GetEntity(self.nukePlayer or NULL_ENTITY);
			if (players) then
				for i,player in pairs(players) do	
					if (targetplayer and player.id ~= self.nukePlayer) then
						player.inventory:Destroy();	
						self.game:ChangeSpectatorMode(player.id, 3, targetplayer.id);
						--player.actor:SetSpectatorMode(3, targetplayer.id);
					else
						-- oops. Spectate the HQ directly?
					end
				end
			end
			if (targetplayer and targetplayer.isPlayer) then
				ExecuteOnAll([[
					local p=GP(]] .. targetplayer:GetChannel() .. [[)p:StartAnimation(0,"cineIsland_ab6_HawkerEnd_01",1);
					for i=1,3 do
					Script.SetTimer(i*3200,function()
						p:StopAnimation(0,-1);
						p:StartAnimation(0,"cineIsland_ab6_HawkerEnd_01",1);
					end);
					end;
				]]);
			end;
		end

		--TeamInstantAction.Server.OnTimer(self, timerId, msec);
	end;
	
	if (timerId==self.TICK_TIMERID) then
		if (self.OnTick) then
			--pcall(self.OnTick, self);
			self:OnTick();
			self:SetTimer(self.TICK_TIMERID, self.TICK_TIME);
			
		end
	elseif (timerId==self.NEXTLEVEL_TIMERID) then
		--Debug("next level xD");
		self:GotoState("Reset");
		self.game:NextLevel();
		--self:NextLevel();
	end
	
end, "Server");

ATOMGameRules:Add('GetNextMap', function(self, maps, randomize, total, rules)

	local theMap, time, _tMap;
	
	if (ATOM.cfg.MapConfig.Rotation.LoopMap) then
		theMap = g_dll:GetMapName()
		time = System.GetCVar('g_timeLimit')
		SysLog("Looping map %s with time %d. Rotation.LoopMap == true", theMap, time)
		return theMap, time 
	end

	local selected = LAST_MAP;
		if (randomize) then
			if (arrSize(maps) > 1) then
				
				if ((not MAP_ENV) or (arrSize(MAP_ENV) >= arrSize(maps)) or (rules ~= LAST_RULES)) then
					MAP_ENV = selected and {
						["m" .. selected] = true;
					} or {};
					SysLog("Map Environment was reset, marking last map .Maps[%d] as already used", LAST_MAP or -1);
				end;
				
				while MAP_ENV["m" .. selected] do
					SysLog(".Maps[%d] already used, choosing next map", selected);
					selected = math.random(1, arrSize(maps));
					--SysLog("New index is %d .. ", selected);
				end;
				
				SysLog(".Maps[%d] was selected", selected);
				LAST_MAP = selected;
				MAP_ENV["m" .. selected] = true;
				
				_tMap = maps[LAST_MAP];
				if (type(_tMap) == "table") then
					
					SysLog(".Maps[%d] contains custom time limit", LAST_MAP);
					theMap = _tMap[1];
					time = _tMap[2];
					
					SysLog(".Maps[%d] Map = %s, Time = %d", LAST_MAP, theMap, time);
				else
					theMap = _tMap;
					
				end;
				
				theMap = formatString("%s/%s/%s", "Multiplayer", rules, theMap);
				
				SysLog("Map %s (with time %d) was randomly selected as the next Map!", theMap, (time or -1))
				--[[
				if ((not MAP_ENV) or (arrSize(MAP_ENV) == total) or (rules ~= LAST_RULES)) then
					MAP_ENV = {  };
					SysLog("Resetting map environment (%s, %s, %s)", tostring(not MAP_ENV), tostring(arrSize(MAP_ENV) == total), tostring(rules ~= LAST_RULES));
				end;
				while MAP_ENV[selected] do	
					SysLog("choosing next map ... %d was already taken...", selected);
					selected = GetRandom(1, total);
					SysLog("selected now = %d", selected);
				end;
				LAST_MAP = selected;
				MAP_ENV[LAST_MAP] = true;
				SysLog("LAST_MAP = %d", LAST_MAP);
				if (type(maps[LAST_MAP]) == "table") then
					SysLog("its table:")
					Debug(maps[LAST_MAP])
					theMap = maps[LAST_MAP][1];
					time = maps[LAST_MAP][2]
				else
					SysLog("not table: %s", tostring(maps[LAST_MAP]))
					SysLog("total %d (%d)", total, arrSize(maps))
					SysLog("this %d", LAST_MAP)
					Debug(maps)
					theMap=maps[LAST_MAP]
				end;
				Debug("themap", theMap)
				Debug("theMapTS", tostring(theMap))
				Debug("rules", rules)
				theMap = "multiplayer/" .. rules .. "/" .. theMap;
				SysLog("Randomly selected map %s out of %d", theMap, total);
				--]]
				
			else
			
				_tMap = maps[1];
				if (type(_tMap) == "table") then
					
					SysLog(".Maps[1] contains custom time limit");
					theMap = _tMap[1];
					time = _tMap[2];
					
					SysLog(".Maps[1] Map = %s, Time = %d", theMap, time);
				else
					theMap = _tMap;
					
				end;
				
				theMap = formatString("%s/%s/%s", "Multiplayer", rules, theMap);
				
				SysLog("Found only one map in .Maps, %s (with time %d) was selected as the next Map!", theMap, (time or -1))
			end;
		else
			LAST_MAP = (LAST_MAP or 0) + 1;
			if (g_dll:GetMapName():lower():sub(16) == maps[LAST_MAP]) then
				SysLog("Preventing repeating map");
				LAST_MAP = LAST_MAP + 1;
			end;
			if (LAST_MAP > total) then
				SysLog("Looping map rotation now");
				LAST_MAP = 1;
			end;
			
			_tMap = maps[LAST_MAP];
			if (type(_tMap) == "table") then
					
				SysLog(".Maps[1] contains custom time limit");
				theMap = _tMap[1];
				time = _tMap[2];
					
				SysLog(".Maps[1] Map = %s, Time = %d", theMap, time);
			else
				theMap = _tMap;

			end;
			
			theMap = formatString("%s/%s/%s", "Multiplayer", rules, theMap);
			SysLog("Selected next %s map %s from rotation", self.class, theMap);
		end;
	return theMap, time;
end);

ATOMGameRules:Add('NextLevel', function(self, nochange, forceRules)
	SysLog("ATOMGameRules:NextLeveL");
	
	if (not nochange) then
		self:GotoState("Reset");
	end;
	
	local cfg = ATOM.cfg.MapConfig;
	if (not cfg) then
		SysLog("Fatal: Using Default map change system");
		return false;--g_game:NextLevel();
	end;
	
	local rotation = cfg.Rotation[forceRules or self.class];
	if (not rotation) then
		SysLog("Fatal: No Rotation found for rules %s, using default map change system", self.class);
		return false;--g_game:NextLevel();
	end;
	
	local timelimit = rotation.DefaultTimeLimit or 15;
	local nTime;
	--SysLog("Timelimit for next map: %d", timelimit);
	
	local maps = rotation.Maps;
	if (not maps or arrSize(maps) == 0) then
		SysLog("Fatal: Rotation for rules %s is empty, using default map change system", self.class);
		return false;--g_game:NextLevel();
	end;
	
	LAST_MAP = (LAST_MAP or 1);
	
	SysLog("Choosing next map for Game Rules %s (last map index: %d)", forceRules or self.class, LAST_MAP);
	
	local total = arrSize(maps);
	local rules = (forceRules or self.class) == "PowerStruggle" and "PS" or "IA";
	local randomize = rotation.Randomize;
	local theMap = VOTED_MAP;
	if (theMap) then
		
	end;
	
	if (not theMap) then
		theMap, nTime = self:GetNextMap(maps, randomize, total, rules);
		VOTED_MAP = theMap;
		if (nTime) then
			SysLog("Found predefined map time %d",nTime);
			VOTED_MAP_TIME = nTime;
			timelimit = nTime;
		else
			VOTED_MAP_TIME = nil;
		end;
	else
		SysLog("selected voted map %s", theMap);
	end;
	rules = g_utils:ParseRules(theMap);
	
	LAST_RULES = (rules == "PowerStruggle" and "PS" or "IA");
	LAST_MAP_NAME = theMap;
	
	CURRENT_MAP_TIME_LIMIT = timelimit;
	
	--SysLog("!!!!!!!!!!!! LAST_RULES = %s", LAST_RULES);
	local oldTimelimit = System.GetCVar("g_timelimit");
	if (not nochange) then
		System.SetCVar("g_timelimit", timelimit);
		SysLog("g_timelimit = %s", tostring(System.GetCVar("g_timelimit")));
		System.ExecuteCommand("sv_gamerules " .. rules);--self.class);
		System.ExecuteCommand("map " .. theMap);
		--g_game:ResetGameTime()
		--System.SetCVar("g_timelimit", oldTimelimit);
	else
		--VOTED_MAP = nil
		return theMap, timelimit;
	end;
	VOTED_MAP = nil;
	VOTED_MAP_TIME = nil;
	--System.ExecuteCommand("g_nextlevel " .. (CryAction.IsImmersivenessEnabled() == 1 and "x" or "")); -- dx10
	
	
	return true;
end);

ATOMGameRules:Add('CheckTimeLimit', function(self)
	--if (not ATOM.GameEnd) then
		if (self.class == "PowerStruggle") then
			self:CheckTimeLimit_PS();
		else
			self:CheckTimeLimit_IA();
		end;
	--end;
end);

ATOMGameRules:Add('CheckTimeLimit_PS', function(self)
	local timeLeft = self.game:GetRemainingGameTime();
	if (self.game:IsTimeLimited() and timeLeft <= 0) then
		--Debug("should end now: " ..timeLeft)
		local stat e= self:GetState();
		if (state and state~="InGame") then
			return;
		end
		self:EndGameWithWinner_PS()
	elseif (self.game:IsTimeLimited()) then
		--Debug(self.game:GetRemainingGameTime())
		if (timeLeft <= 60 * 15) then
			if (not self.AddTimeHit) then
				SendMsg(CHAT_VOTE, ALL, "Map ends in 15 Minutes, vote to add more time using !vote <time>");
				self.AddTimeHit = true;
			end;
		elseif (timeLeft <= 60 * 10) then
			if (not self.MapVote) then
				--Debug("map voting now")
				if (ATOMVoting) then
				--	SendMsg(CHAT_ATOM, ALL, "Map Voting Started, Use !vote <map> to cast your vote");
				end;
				self.MapVote = true;
			end;
		else
			self.AddTimeHit = false;
			self.MapVote = false;
		end;
	end
end);

ATOMGameRules:Add('EndGameWithWinner_PS', function(self)
	local draw=true;
		
	local maxHP;
	local maxTeamId;
		
	for i,teamId in pairs(self.teamId) do
		local hp=0;
		for k,hqId in pairs(self.hqs) do
			if (self.game:GetTeam(hqId)==teamId) then
				local hq=System.GetEntity(hqId);
				if (hq) then
					hp=hp+math.max(0, hq:GetHealth());
				end
			end
		end

		if (not maxHP) then
			maxHP=hp;
			maxTeamId=teamId;
		else
			if (hp>maxHP or hp<maxHP) then
				if (hp>maxHP) then
					maxHP=hp;
					maxTeamId=teamId;
				end
				draw=false;
			end
		end
	end				
		
	if (not draw) then
		self:OnGameEnd(maxTeamId, 2);
	else
		self:OnGameEnd(nil, 2);
	end
end);


ATOMGameRules:Add('CheckTimeLimit_IA', function(self)
	if (self.game:IsTimeLimited() and (self:GetState()=="InGame")) then
		local time = self.game:GetRemainingGameTime();
		--Debug(ATOM.cfg.MapConfig.IAEndGameRadio)
		if (time <= 0) then
			self:EndGameWithWinner_IA();
		elseif (ATOM.cfg.MapConfig.IAEndGameRadio) then
	
			time = tonumber(formatString("%0.0f", time));
			
			--Debug(time,_time - (self.RadioTime or 0))
			
			local radio = {
				[120] = "mp_american/us_commander_2_minute_warming_01",
				[60 ] = "mp_american/us_commander_1_minute_warming_01",
				[30 ] = "mp_american/us_commander_30_second_warming_01",
				[5  ] = "mp_american/us_commander_final_countdown_01",
			};
			
			if ((not self.RadioTimer or _time - self.RadioTimer >= 1)) then
				if (radio[time]) then
					SendMsg(INFO, ALL, "(GAME OVER IN : %d - SECONDS (!))", time);
					self.RadioTimer = _time;
					ExecuteOnAll([[local soundId=g_localActor:PlaySoundEvent("]] .. radio[time] .. [[", g_Vectors.v000, g_Vectors.v010, bor(SOUND_LOAD_SYNCHRONOUSLY, SOUND_VOICE), SOUND_SEMANTIC_MP_CHAT);]]);
				elseif (time < 30) then
					self.RadioTimer = _time;
					SendMsg(CENTER, ALL, "Game Over in - [ %d ] - Seconds!", time);
				end;
			end;
		end;
	end
end);

ATOMGameRules:Add('EndGameWithWinner_IA', function(self)

	local maxScore = nil
	local maxId = nil
	local draw = false
	
	local players = self.game:GetPlayers(true)

	if (players) then
		for i,player in pairs(players) do
			local score=self:GetPlayerScore(player.id);
			if (not maxScore) then
				maxScore=score;
			end
			if (score>=maxScore) then
				if ((maxId~=nil) and (maxScore==score)) then
					draw=true;
				else
					draw=false;
					maxId=player.id;
					maxScore=score;
				end
			end
		end
				
				-- if there's a draw, check for lowest number of deaths
		if (draw) then
			local minId=nil;
			local minDeaths=nil;
					
			for i,player in pairs(players) do
				local score=self:GetPlayerScore(player.id);
				if (score==maxScore) then
					local deaths=self:GetPlayerDeaths(player.id);
					if (not minDeaths) then
						minDeaths=deaths;
					end
							
					if (deaths<=minDeaths) then
						if ((minId~=nil) and (minDeaths==deaths)) then
							draw=true;
						else
							draw=false;
							minId=player.id;
							minDeaths=deaths;
						end
					end
				end
			end
					
			if (not draw) then
				maxId=minId;
			end
		end
	end
	
	if (not draw) then
		self:OnGameEnd(maxId, 2);
	else
		self:OnGameEnd(nil, 2);
	end
end);


ATOMGameRules:Add('OnGameEnd', function(self, a, type, shooterId)
	local nextMap = self:NextLevel(true);
	if (self.class == "InstantAction") then
		if (a) then
			local playerName=EntityName(a);
			self.game:SendTextMessage(TextMessageCenter, "@mp_GameOverWinner", TextMessageToAll, nil, playerName);
			self.allClients:ClVictory(a);
		else
			self.game:SendTextMessage(TextMessageCenter, "@mp_GameOverNoWinner", TextMessageToAll);
			self.allClients:ClNoWinner();
		end
	else
		if (a and a~=0) then
			local teamName=self.game:GetTeamName(a);
			self.game:SendTextMessage(TextMessageCenter, "@mp_GameOverWinner", TextMessageToAll, nil, "@mp_team_"..teamName);
		else
			self.game:SendTextMessage(TextMessageCenter, "@mp_GameOverNoWinner", TextMessageToAll);
		end
		self.allClients:ClVictory(a or 0, type, shooterId or NULL_ENTITY);
		self.nukePlayer = shooterId or NULL_ENTITY;
	end;
	
	SendMsg(CHAT_ATOM, ALL, "Next Map : %s (%s)", nextMap:sub(16):upper(), g_utils:ParseRules(nextMap));
	
	ATOMBroadcastEvent("OnGameEnd", winningPlayerId, type or 0);
	
	self.game:EndGame();
	self:GotoState("PostGame");		

end);

ATOMGameRules:Add("SetupPlayer", function(self, player)
	ATOM:ChangeCapacity(player);
end);

ATOMGameRules:Add('OnClientConnect', function(self, channelId, reset, name)
	local player = self:SpawnPlayer(channelId, name)
	if (not player) then
		return false, SysLog("WARNING! Failed to Spawn Player %s on channel %d", checkVar(name, string.UNKNOWN), channelId) end
	
	if (not reset) then
		player.wasInSpecMode = true; -- !!hook  to prevent logging this obvious initial spectator mode change
		self.game:ChangeSpectatorMode(player.id, 2, NULL_ENTITY);
		-- ADD BleSend
	else
		if (not CryAction.IsChannelOnHold(channelId)) then
			self:ResetScore(player.id);
		end;

		local specMode=self.channelSpectatorMode[channelId] or 0;
		local teamId=self.game:GetChannelTeam(channelId) or 0;
		
		local doRevive = true;
		if (not player.GetChannel) then
			doRevive = false;
		end;

		if (specMode==0 or teamId~=0) then
			player.wasInSpecMode = false; -- !!hook  to prevent logging this obvious initial spectator mode change
			
			self.game:SetTeam(teamId, player.id); -- make sure he's got a team before reviving

			self.Server.RequestSpawnGroup(self, player.id, self.game:GetTeamDefaultSpawnGroup(teamId) or NULL_ENTITY, true);
			if (doRevive) then
				self:RevivePlayer(player.actor:GetChannel(), player);
			else
				self.Server.OnChangeSpectatorMode(self, player.id, 1, nil, true);
			end;
		else
			player.wasInSpecMode = true; -- !!hook  to prevent logging this obvious initial spectator mode change
			self.Server.OnChangeSpectatorMode(self, player.id, specMode, nil, true);
		end;
	end;

	if (g_gameRules.class == "PowerStruggle") then
		if (not CryAction.IsChannelOnHold(channelId)) then
			self:ResetScore(player.id);
			self:ResetPP(player.id);
			self:ResetCP(player.id);
		end
		self:ResetRevive(player.id);
	end;
	
	local some_factory;
	for i, v in pairs(System.GetEntities()) do
		if (v.SynchedBuyZone) then
			--Debug("SYNCH!!")
			some_factory = GetEnt(v.SynchedBuyZone[1]);
			if (some_factory) then
				some_factory.allClients:ClSetBuyFlags(v.id, v.SynchedBuyZone[2]);
			--	Debug("SYNCHEFD")
			end;
		end;
	end;
	
end, 'Server');

ATOMGameRules:Add('OnAddTaggedEntity', function(self, shooterId, targetId)
	Debug("TAGGED")
	local shooterTeam = self.game:GetTeam(shooterId);
	local targetTeam = self.game:GetTeam(targetId);
	
	local target = System.GetEntity(targetId);
	local player = System.GetEntity(shooterId);
	
	local total_pp = player.scan_pp or 0;
	local total_cp = player.scan_cp or 0;
	local hostiles = 0
	
	player.scan_num = (player.scan_num or 0) + 1;
	
	if ( (shooterTeam ~= targetTeam)) then --(targetTeam~=0) and
		if (target) then
			local mult = player.GetAccess and (player:GetAccess() >= PREMIUM and 2) or 1;
			if ((not target.last_scanned) or (_time-target.last_scanned > 5)) then
			
				total_pp = total_pp + self.ppList.TAG_ENEMY * mult;
				total_cp = total_cp + self.cpList.TAG_ENEMY * mult;
				target.last_scanned = _time;
				
			end
			if (targetTeam ~= 0 and target.actor and target.actor:IsPlayer()) then
				Debug("hostile scanned!")
				hostiles = hostiles + 1
			end
		end
	end
	
	player.scan_pp = total_pp;
	player.scan_cp = scan_cp;
	player.scan_hostiles = hostiles
	
	SysLog("[PowerStruggle.lua] Entity %s was tagged by %s", target:GetName(), player:GetName());
end, "Server");

ATOMGameRules:Add('AwardScanPP', function(self, player)

	local total_pp = player.scan_pp or 0;
	local total_cp = player.scan_cp or 0;
	local total_num = player.scan_num;
	local scan_hostiles = player.scan_hostiles;
	
	
	if (total_pp > 0) then
		self:AwardPPCount(player.id, total_pp, nil, true);
	end;
	if (total_cp > 0) then
		self:AwardCPCount(player.id, total_cp, nil, true);
	end;
	
	if (total_num > 0) then
		SendMsg({BLE_CURRENCY}, player, "Scanned %d Entities ( +%d PP, +%d CP )", total_num, total_pp, total_cp);
		if (scan_hostiles > 0 and ATOM.cfg.Immersion.AlertHostileScan) then
		
			local aInRangePlayers = DoGetPlayers({ teamId = g_game:GetTeam(player.id), sameTeam = true, pos = player:GetPos(), range = 50 })
			SendMsg(BLE_ERROR, aInRangePlayers, "Alert: " .. scan_hostiles .. " Hostiles detected on Radar!")
			for i, v in pairs(aInRangePlayers) do
				PlPlaySound(v, "sounds/interface:multiplayer_interface:mp_tac_alarm_suit") end
		end
	else
		SendMsg({BLE_CURRENCY}, player, "Scan Complete: No entities found");
	end
	player.scan_pp = 0;
	player.scan_cp = 0;
	player.scan_num = 0;
	player.scan_hostiles = 0;
end);

ATOMGameRules:Add('OnClientDisconnect', function(self, channelId, r)
	local player=self.game:GetPlayerByChannelId(channelId);
	
	if (not player) then
		return
	end;
	
	self.channelSpectatorMode[player.actor:GetChannel()]=nil;
	self.works[player.id]=nil;
	
	--Debug("rmi disconnect 1")
	for i, p in pairs(GetPlayers()) do
		if (p.ATOM_CLIENT) then
			ExecuteOnPlayer(p, [[HUD.BattleLogEvent("(]] .. r .. [[) ]] .. player:GetName() .. [[ Disconnecting ..")]]);
		else
			self.onClient:ClClientDisconnect(channelId, player:GetName());
		end;
	end;

	if (g_gameRules.class == "PowerStruggle") then
		if (not CryAction.IsChannelOnHold(channelId)) then
			self:ResetScore(player.id);
			self:ResetPP(player.id);
			self:ResetCP(player.id);
		end
		self:ResetRevive(player.id);
		
		if (player) then
			self:ResetRevive(player.id, true);
				
			self:VehicleOwnerDeath(player);
			self:ResetUnclaimedVehicle(player.id, true);
				
			self.inBuyZone[player.id]=nil;
			self.inServiceZone[player.id]=nil;
		end
	end;
end, 'Server');


ATOMGameRules:Add("OnFreeze", function(self, targetId, shooterId, weaponId, value)


	local target=System.GetEntity(targetId);
	local shooter=System.GetEntity(shooterId);
	local weapon=System.GetEntity(weaponId);
	
	if (not (weapon and target and shooter)) then
		return false;
	end;
	
	if (not ATOMDefense:CanFreeze(target, shooter, weapon)) then
		return false;
	end;
	
	if (g_utils:OnFreeze(shooter, weapon, target) == false) then
		return false;
	end;

	if (target.OnFreeze and not target:OnFreeze(shooterId, weaponId, value)) then
		return false;
	end

	if (target.actor or target.vehicle) then
		target.frostShooterId=shooterId;
	end
	return true;

end, "Server");

ATOMGameRules:Add("OnExplosion", function(self, explosion)
	--SysLog("************************************E22xplosion. OK")
	local entities = explosion.AffectedEntities;
	local entitiesObstruction = explosion.AffectedEntitiesObstruction;

	if (entities) then
		-- calculate damage for each entity
		for i,entity in ipairs(entities) do

			local incone=true;
			if (explosion.angle>0 and explosion.angle<2*math.pi) then				
				self.explosion_entity_pos = entity:GetWorldPos(self.explosion_entity_pos);
				local entitypos = self.explosion_entity_pos;
				local ha = explosion.angle*0.5;
				local edir = vecNormalize(vecSub(entitypos, explosion.pos));
				local dot = 1;

				if (edir) then
					dot = vecDot(edir, explosion.dir);
				end
				
				local angle = math.abs(math.acos(dot));
				if (angle>ha) then
					incone=false;
				end
			end

			local frozen = self.game:IsFrozen(entity.id);
			if (incone and (frozen or (entity.Server and entity.Server.OnHit))) then
				local obstruction=entitiesObstruction[i];
				local damage=explosion.damage;
				
				damage = math.floor(0.5+self:CalcExplosionDamage(entity, explosion, obstruction));		

				local dead = (entity.IsDead and entity:IsDead());
					
				local explHit=self.explosionHit;
				explHit.pos = explosion.pos;
				explHit.dir = vecNormalize(vecSub(entity:GetWorldPos(), explosion.pos));
				explHit.radius = explosion.radius;
				explHit.partId = -1;
				explHit.target = entity;
				explHit.targetId = entity.id;
				explHit.weapon = explosion.weapon;
				explHit.weaponId = explosion.weaponId;
				explHit.shooter = explosion.shooter;
				explHit.shooterId = explosion.shooterId;
				explHit.materialId = 0;
				explHit.damage = damage;
				explHit.typeId = explosion.typeId or 0;
				explHit.type = explosion.type or "";
				explHit.explosion = true;
				explHit.impact = explosion.impact;
				explHit.impact_targetId = explosion.impact_targetId;
			
				if (entity and entity.InGodMode and entity:InGodMode()) then
					explHit.damage = 0;
				end;
				local deadly=false;
				local canShatter = ((not entity.CanShatter) or (tonumber(entity:CanShatter())~=0));

				if (self.game:IsFrozen(entity.id) and canShatter) then
					if (damage>15) then				
					  local hitpos = entity:GetWorldPos();
				    local hitdir = vecNormalize(vecSub(hitpos, explosion.pos));
				    
						self:ShatterEntity(entity.id, explHit);
					end
				else				
					if (entity.actor and entity.actor:IsPlayer()) then
						if (self.game:IsInvulnerable(entity.id)) then
							explHit.damage=0;
						end
						---System.LogAlways("============================");
						--for s, v in pairs(explHit) do
						--	System.LogAlways(tostring(s).." - "..tostring(v));
						--end
		
					end

					if ((not dead) and entity.Server and entity.Server.OnHit and entity.Server.OnHit(entity, explHit)) then
						-- special case for actors
						-- if more special cases come up, lets move this into the entity
						if (entity.actor and self.ProcessDeath) then
							self:ProcessDeath(explHit);
						elseif (entity.vehicle and self.ProcessVehicleDeath) then
							self:ProcessVehicleDeath(explHit);
						end
						
						deadly=true;
					end
				end
				
				local debugHits = self.game:DebugHits();
				
				if (debugHits>0) then
					self:LogHit(explHit, debugHits>1, deadly);
				end
			end
		end
	end
	g_utils:OnExplosion(explosion)
	ATOMBroadcastEvent("OnExplosion", explosion, entities, entitiesObstruction);
end, "Server");

ATOMGameRules:Add('RequestSpawnGroup', function(self, playerId, groupId, force)
	local player = System.GetEntity(playerId);
	
	if (ATOMDefense) then
		if (not ATOMDefense:SpawnGroupOK(playerId, groupId, force)) then
			return;
		end;
	end;

	if (player) then
		local teamId=self.game:GetTeam(playerId);

		if ((not force) and (teamId ~= self.game:GetTeam(groupId))) then
			return;
		end;
		
		if (groupId==player.spawnGroupId) then
			return;
		end;
		
		local group=System.GetEntity(groupId);
		if (group and group.vehicle and (group.vehicle:IsDestroyed() or group.vehicle:IsSubmerged())) then
			return;
		end;
		
		if (group and group.vehicle) then
			local vehicle=group.vehicle;
			local seats=group.Seats;
			local seatCount = 0;
			
			for i,v in pairs(seats) do
				if ((not v.seat:IsGunner()) and (not v.seat:IsDriver()) and (not v.seat:IsLocked())) then
					seatCount=seatCount+1;
				end;
			end;
			
			local occupied=0;
			local players=self.game:GetPlayers(true);
			local mateGroupId;
			
			if (players) then
				for i,player in pairs(players) do
					if (teamId==self.game:GetTeam(player.id)) then
						mateGroupId=self:GetPlayerSpawnGroup(System.GetEntity(player.id)) or NULL_ENTITY;
						if (mateGroupId==groupId) then
							occupied=occupied+1;
						end;
					end;
				end;
			end;

			if (occupied>=seatCount) then
				return;
			end;
		end;

		self:SetPlayerSpawnGroup(playerId, groupId);
	
		if (player.actor) then
			if ((not g_localActorId) or (g_localActorId~=playerId)) then
				local channelId=player.actor:GetChannel();
			
				if (channelId and channelId>0) then
					self.onClient:ClSetSpawnGroup(channelId, groupId);
				end;
			end;
		end
		
		self:UpdateSpawnGroupSelection(player.id);
	end;
end, 'Server');

ATOMGameRules:Add('RevivePlayer', function(self, channelId, player)

	if (g_gameRules.class == "PowerStruggle") then
		if (player.actor:GetSpectatorMode() ~= 0) then
			self.game:ChangeSpectatorMode(player.id, 0, NULL_ENTITY)
		end
	end


	local keepEquip = false;
	local result 	= false;
	local groupId 	= player.forceSpawnId or player.spawnGroupId;
	local teamId 	= self.game:GetTeam(player.id);
	if ((player.IsDead and player:IsDead()) or player.actor:GetHealth() <= 0) then
		keepEquip 	= false;
	end
	--Debug("FORCE:",player.forceSpawnId)
	player.forceSpawnId = nil;

	if (self.USE_SPAWN_GROUPS and groupId and groupId~=NULL_ENTITY) then
		local spawnGroup = System.GetEntity(groupId);
		if (spawnGroup and spawnGroup.vehicle) then -- spawn group is a vehicle, and the vehicle has some free seats then
			result = false;
			for i, seat in pairs(spawnGroup.Seats) do
				if ((not seat.seat:IsDriver()) and (not seat.seat:IsGunner()) and (not seat.seat:IsLocked()) and (seat.seat:IsFree()))  then
					self.game:RevivePlayerInVehicle(player.id, spawnGroup.id, i, teamId, not keepEquip);

					-- !!hook
					--if (CF_VehicleHandler.cfg.AwardSpawnVehicleOwner and spawnGroup.ownerID) then
					--	self:AwardPPCount(spawnGroup.ownerID, CF_VehicleHandler.cfg.AwardPP);
					--end

					result = true;
					break;
				end
			end

			-- if we didn't find a valid seat, rather than failing pass an invalid seat id. RevivePlayerInVehicle will try and
			--	find a respawn point at one of the seat exits etc.
			if (not result) then
				self.game:RevivePlayerInVehicle(player.id, spawnGroup.id, -1, teamId, not keepEquip);
				result = true;
			end
		end
	elseif (self.USE_SPAWN_GROUPS) then
		Log("Failed to spawn %s! teamId: %d  groupId: %s  groupTeamId: %d", player:GetName(), self.game:GetTeam(player.id), tostring(groupId), self.game:GetTeam(groupId or NULL_ENTITY));

		return false;
	end
	local spawn;
	local spawnId, zoffset;
	local group
	
	if (not result) then
		local ignoreTeam = (groupId~=nil) or (not self.TEAM_SPAWN_LOCATIONS);

		local includeNeutral = true;
		if (self.TEAM_SPAWN_LOCATIONS) then
			includeNeutral = self.NEUTRAL_SPAWN_LOCATIONS or false;
		end

		if (self.USE_SPAWN_GROUPS or (not player.death_time) or (not player.death_pos)) then
			spawnId, zoffset = self.game:GetSpawnLocation(player.id, ignoreTeam, includeNeutral, groupId or NULL_ENTITY);
			
		else
			spawnId, zoffset = self.game:GetSpawnLocation(player.id, ignoreTeam, includeNeutral, groupId or NULL_ENTITY, 50, player.death_pos);
		end

		if (ATOMSpawns and ATOMSpawns:CustomSpawnsEnabled() and g_gameRules.class == "InstantAction") then
			local nspawnId, nzoffset = ATOMSpawns:GetSpawnLocation(player.id);
			if (nspawnId) then
				spawnId = nspawnId;
			end;
			if (nzoffset) then
				zoffset = nzoffset;
			end;
		end;

		local vNewSpawn, vNewAngles, iNewOffset
		if (player.bInit) then
			vNewSpawn, vNewAngles, iNewOffset = player:GetSpawnLocation()--ATOMBroadcastEventAny("GetSpawnLocation", player)
		end


		local pos, angles;

		--Debug("vNewSpawn",vNewSpawn)
		if (vNewSpawn) then

			local vSpawnPos = vNewSpawn
			local vSpawnAng = vNewAngles or player:GetAngles()
			local iSpawnOff = checkNumber(iNewOffset, 0.1)
			Debug("Custom spawn POINT!!!")


			if (ATOM.cfg.RespawnPlayerAtPos) then
				vSpawnPos, vSpawnAng = (player.death_pos or player:GetPos()), player:GetAngles();
			end

			self.game:RevivePlayer(player.id, vSpawnPos, vSpawnAng, teamId, not keepEquip)
			result 	= true


		elseif (spawnId) then
			spawn	= System.GetEntity(spawnId)
			if (spawn) then
			
				spawn:Spawned(player);
			
				pos		= spawn:GetWorldPos(g_Vectors.temp_v1);
				angles	= spawn:GetWorldAngles(g_Vectors.temp_v2);
				pos.z	= pos.z + zoffset;


				if (ATOM.cfg.RespawnPlayerAtPos) then
					pos, angles = (player.death_pos or player:GetPos()), player:GetAngles();
				end;
				
				
				if (zoffset>0) then
					Log("Spawning player '%s' with ZOffset: %g!", player:GetName(), zoffset);
				end;
				
				self.game:RevivePlayer(player.id, pos, angles, teamId, not keepEquip);
				Debug("Spawned ok")

				result 	= true;
			end
		end
	end

	-- make the game realise the areas we're in right now...
	-- otherwise we'd have to wait for an entity system update, next frame
	player:UpdateAreas();

	if (result) then
		if (player.actor:GetSpectatorMode() ~= 0) then
			player.actor:SetSpectatorMode(0, NULL_ENTITY);
		end

		if (not keepEquip) then
			local additionalEquip;
			if (groupId) then
				group=System.GetEntity(groupId);
				if (group and group.GetAdditionalEquipmentPack) then
					additionalEquip = group:GetAdditionalEquipmentPack();
				end;
			end;
			self:EquipPlayer(player, additionalEquip);
		end
		player.death_time		= nil;
		player.frostShooterId	= nil;

		if (self.INVULNERABILITY_TIME and self.INVULNERABILITY_TIME>0) then
			self.game:SetInvulnerability(player.id, true, self.INVULNERABILITY_TIME);
		end
	end

	if (not result) then
		Log("Failed to spawn %s! teamId: %d  groupId: %s  groupTeamId: %d", player:GetName(), self.game:GetTeam(player.id), tostring(groupId), self.game:GetTeam(groupId or NULL_ENTITY));
	end
 -- IA part end

	if (g_gameRules.class == "PowerStruggle") then
		self:ResetUnclaimedVehicle(player.id, false);
		player.lastVehicleId=nil;
		self:ResetBoughtItems(player);
	end;

	-- !!hook
	--CF_PlayerActionHandler:OnRevive(player);
	ATOMStats.PermaScore:OnRevive(player);
	ATOMBroadcastEvent("OnRevive", player, spawnId, spawn);

	if (group) then
		self:CheckSpawnPP(player, group.vehicle ~=nil, group);
	end;


	return result;

end);

ATOMGameRules:Add('EquipPlayer', function(self, player, additionalEquip)
	if (self.game:IsDemoMode() ~= 0) then -- don't equip actors in demo playback mode, only use existing items
		Log("Don't Equip : DemoMode");
		return;
	end;

	player.inventory:Destroy();

	-- !!hook
	if (player.IsPunished and player:IsPunished()) then
		return;
	end;

	ItemSystem.GiveItem("AlienCloak", 	player.id, true);
	ItemSystem.GiveItem("OffHand",		player.id, true);
	ItemSystem.GiveItem("Fists", 		player.id, true);

	

	-- !!hook
	if (not ATOMEquip:OnSpawn(player)) then
		if (additionalEquip and additionalEquip ~= "") then
			ItemSystem.GiveItemPack(player.id, additionalEquip, true);
		end;
		ItemSystem.GiveItem("SOCOM", player.id, true);
	end;
	
	if (player.customEquipmentnr) then
		if (not player.equipmentLoadedMessage) then
			SendMsg(CHAT_EQUIP, player, "(Custom Equipment: Loaded)");
		end;
		player.equipmentLoadedMessage = true;
	end;
	--ATOMEquip:CheckSavedEquipment(player);
end);

ATOMGameRules:Add('OnPlayerKilled', function(self, hit, doKill)
	
	
	--self.lastKillFrame = self.lastKillFrame or {};
	
	--if (not doKill) then
	--	self.lastKillFrame[#self.lastKillFrame+1] = hit;
	--	return;
	--end;
	
	--self.kill_quene = self.kill_quene or {};
	--if (self.lastKillFrame and _time == self.lastKillFrame) then
	--	Debug("blocked!")
	--	self.lastKillFrame[#self.lastKillFrame+1] = hit;
	--	return;
	--end;
	--self.lastKillFrame = _time;
	
	local tk=false;
	local target=hit.target;
	local shooter=hit.shooter;
	target.death_time=_time;
	target.death_pos=target:GetWorldPos(target.death_pos);
	
	if (g_gameRules.class == "InstantAction") then
		self.game:KillPlayer(hit.targetId, true, true, hit.shooterId, hit.weaponId, hit.damage, hit.materialId, hit.typeId, hit.dir or vector.make(0,0,1));
	else
		if (shooter and shooter.actor and shooter.actor:IsPlayer()) then
			if (target ~= shooter) then
				local team1=self.game:GetTeam(shooter.id);
				local team2=self.game:GetTeam(target.id);

				if ((team1~=0) and (team1==team2)) then
					tk=true;
					if (self.OnTeamKill) then
						self:OnTeamKill(target.id, shooter.id);
					end
				end
			end
		end
		self.game:KillPlayer(hit.targetId, not tk, true, hit.shooterId, hit.weaponId, hit.damage or 0, hit.materialId or "mat_default", hit.typeId or -1, hit.dir or vector.make(0,0,0));
	end;
	
	self:ProcessScores(hit, tk);
	self:AwardAssistPPAndCP(hit);
	target.allHits = {};
	
	self:OnKilled(hit);
end, "Server");

ATOMGameRules:Add("UpdateReviveQueue", function(self)
	local reviveTimer=self.game:GetRemainingReviveCycleTime();
	local stop = false;
	if (reviveTimer>0) then
		for playerId,revive in pairs(self.reviveQueue) do
			if (revive.active) then
				--Debug(playerId)
				stop=false; -- reset stop
				local player=System.GetEntity(playerId);
				if (player) then
					--Debug("player OK")
					--Debug(player.rebooter)
					if (player.rebooter) then
						--Debug("player rebooter OK")
						local reb = GetEnt(player.rebooter);
						if (reb and reb.rebooting and reb.rebooting == playerId) then
							--Debug("stop!")
							stop=true;
							if (revive.announced) then
								self.onClient:ClReviveCycle(player.actor:GetChannel(), false);
								revive.announced=nil;
								--Debug("no cycle!")
							end;
						end;
					end;
				
				end;
				if (not stop) then
					if (player and player.spawnGroupId and player.spawnGroupId~=NULL_ENTITY) then
						if (not revive.announced) then
							self.onClient:ClReviveCycle(player.actor:GetChannel(), true);
							revive.announced=true;
							--Debug("yes cycle")
						end
					elseif (revive.announced) then -- spawngroup got invalidated while spawn cycle was up,
																					-- so need to make sure it gets sent again after the situation is cleared
						revive.announced=nil;
					end
				else
					--Debug("stop, probably being rebooted.");
				end;
			else
				--Debug("no active for",EntityName(playerId))
			end
		end
		
		-- if player has been dead more than 5s and isn't spectating, auto-switch to spectator mode 3
		local players=self.game:GetPlayers();
		if (players) then
			for i,player in pairs(players) do
				if (player and player:IsDead() and player.death_time and _time-player.death_time>25 and player.actor:GetSpectatorMode() == 0) then
					self.Server.RequestSpectatorTarget(self, player.id, 1);
				end
			end
		end
	end

	if (reviveTimer<=0) then
		self.game:ResetReviveCycleTime();
		
		for i,teamId in ipairs(self.teamId) do
			self:UpdateTeamRanks(teamId);
		end
		
		for playerId,revive in pairs(self.reviveQueue) do
			if (revive.active and self:CanRevive(playerId)) then
				revive.active=false;

				local player=System.GetEntity(playerId);
				--Debug("ok",player:IsDead())
				if (player and player:IsDead()) then
					self:RevivePlayer(player.actor:GetChannel(), player);
					if (not revive.tk) then
						local rank=self.rankList[self:GetPlayerRank(player.id)];
						if (rank and rank.min_pp and rank.min_pp>0) then
							local currentpp=self:GetPlayerPP(player.id);
							local premium=player:HasAccess(PREMIUM)
							local min=rank.min_pp;
							--Debug(premium)
							if (premium) then
								local cfg = ATOM.cfg.GamePlayConfig;
								Debug(cfg.PremiumBonusPP)
							--	Debug("BONUS1",min)
								min=min*(cfg and cfg.PremiumBonusPP or 1);
							--	Debug("BONUS2",min)
							end;
							--Debug(currentpp,min)
							if (currentpp<min) then
								self:AwardPPCount(player.id, min-currentpp);
							end
						end
					end

					self:CommitRevivePurchases(playerId);

					revive.tk=nil;
					revive.announced=nil;
				end
			end
		end
	end
end);

ATOMGameRules:Add('OnKilled', function(self, hit)

	local weapon = hit.weapon;
	local target = hit.target;
	local shooter = hit.shooter;
	local cfg = self.cfg; -- too many of them here

	local killType = "unknown";
	local headshot = false;
	local bHeadshot = false

	local suicide = not shooter or shooter == target;

	if (GetBetaFeatureStatus("ragdollsync")) then
		if (target and target.isPlayer) then

			local aSpawnParams = {}
			aSpawnParams.class = "CustomAmmoPickupLarge"
			aSpawnParams.name = string.format("@{Ragdoll-Sync-Entity-For-Channel-[%d]}", target.actor:GetChannel())
			aSpawnParams.position = hit.pos
			if (hit.targetId == hit.shooterId) then
				aSpawnParams.position = hit.shooter:GetPos()
			end
			aSpawnParams.orientation = g_Vectors.up
			aSpawnParams.properties = {}
			aSpawnParams.properties.AmmoName = ""
			aSpawnParams.properties.bUsable = 0
			aSpawnParams.properties.bPickable = 0
			aSpawnParams.properties.bPhysics = 1
			aSpawnParams.properties.objModel = "objects/library/architecture/aircraftcarrier/props/misc/golfball.cgf"

			local hRagdollSync = System.SpawnEntity(aSpawnParams)
			if (not hRagdollSync) then
				return
			end

			hRagdollSync.hSpawnTimer = timerinit()

			Debug("hRagdollSync",hRagdollSync:GetName())

			SetPhysParams(hRagdollSync, { Mass = target:GetMass() })
			hRagdollSync:SetColliderMode(1)
			g_utils:AwakeEntity(hRagdollSync)

			Script.SetTimer(1, function()
				hRagdollSync:AddImpulse(1, hit.pos, hit.dir, 2500, 1)
			end)

			RAGDOLL_SYNC_ENTITIES[hRagdollSync.id] = target
		end
	end

	target.BuyCooldown = {}; -- reset on death

	if (target.isPlayer) then
		-- detect suicide
		if (suicide) then
			killType = "suicide";
			-- player who accidentally kills himself doesn't deserve -1 to kills, 1 death is enough
			local kills = g_game:GetSynchedEntityValue(target.id, g_gameRules.SCORE_KILLS_KEY) or 0;
			g_game:SetSynchedEntityValue(target.id, g_gameRules.SCORE_KILLS_KEY, kills + 1);
		elseif (shooter.isPlayer) then
			-- detect teamkill
			if (g_gameRules.class ~= "InstantAction" and g_game:GetTeam(shooter.id) == g_game:GetTeam(target.id)) then
				killType = "team_kill";
				local teamKillReward = ATOMStats.cfg.TeamKillReward;
				if (teamKillReward) then
					local kills = g_game:GetSynchedEntityValue(shooter.id, g_gameRules.SCORE_KILLS_KEY) or 0;
					g_game:SetSynchedEntityValue(shooter.id, g_gameRules.SCORE_KILLS_KEY, kills + (teamKillReward or -2));
					--self:OnTeamKill(shooter.id, target);
				end;
			else
				killType = "enemy_kill";
				-- detect headshot
				if (hit.material_type and hit.material_type:find("head", nil, true)) then
					headshot = true;
					bHeadshot = true
				end;
				--[[if (cfg.ShowRemainingHealth) then
					self:ShowRemaining(hit);
				end;--]]
			end;
			--[[if (cfg.ShowKillDeathRatio) then
				self:ShowKDR(shooter);
			end;--]]
		else
			killType = "bot_kill";
		end;
		--[[if (cfg.ShowKillDeathRatio and not target.MKinprogress) then
			self:ShowKDR(target);
		end;--]]
	elseif (shooter) then
		if (shooter.isPlayer) then
			-- target is not player -> remove points
			killType = "bot_kill";
			if (not ATOMStats.cfg.AwardScoreForBotKill) then
				local shooterID = shooter.id;
				local kills = g_game:GetSynchedEntityValue(shooterID, g_gameRules.SCORE_KILLS_KEY) or 0;
				g_game:SetSynchedEntityValue(shooterID, g_gameRules.SCORE_KILLS_KEY, kills - 1);
				g_gameRules:AwardPPCount(shooterID, -PowerStruggle.ppList.KILL);
				g_gameRules:AwardCPCount(shooterID, -PowerStruggle.cpList.KILL);
			end;
		else
			killType = "bot_kill";
		end;
	else
		killType = "bot_death";
	end;

	g_statistics:AddToValue("DeathsTotal", 1);
	if (target and shooter and target ~= shooter) then
		g_statistics:AddToValue("KillsTotal", 1);
	end;

	-- remove corpses of dead AI
	if (target and not target.isPlayer and (string.matchex(target.class, "Grunt", "Player") or target.actor) and System.GetCVar("a_unlimitedRagdolls") ~= 1) then
		Script.SetTimer(System.GetCVar("g_ragdollmintime") * 1000, function()
			local iHP = target.actor:GetHealth()
			if (iHP and iHP <= 0) then
				System.RemoveEntity(target.id)
			end
		end)
	else
		target.ragDollTime = _time
	end

	ATOMBroadcastEvent("OnKill", hit, killType, headshot);
	if (shooter) then
		ATOMLog:LogKill(target, shooter, killType, headshot, (hit.weapon and hit.weapon.class), g_game:GetSynchedEntityValue(shooter.id, g_gameRules.SCORE_KILLS_KEY) or 0, g_game:GetSynchedEntityValue(target.id, g_gameRules.SCORE_KILLS_KEY) or 0);
		if (shooter and target and shooter.id ~= target and shooter.isPlayer) then
			if (ATOMTaunt) then
				ATOMTaunt:OnKilled(shooter, target, hit); --OnEvent(eAT_EventKilled, shooter, target);
			end;
		end;
	end;
	
	local targetPos = target:GetPos();
	local hitPos = { x = hit.pos.x - targetPos.x, y = hit.pos.y - targetPos.y, z = hit.pos.z - targetPos.z };
	local targetStanceId = (target and target.actorStats.stance or 3);
	local debug_system = true;
	if (shooter) then
		if (shooter.isPlayer) then
			if (target) then
				if (debug_system or target.isPlayer) then
					
				end;
			end;
		end;
	end;
	
	local messages = {
		[03] = "%s IS on a KILLING SPREE : %d kills";
		[05] = "%s IS on a RAMPAGE : %d kills";
		[08] = "%s IS DOMINATING : %d kills";
		[12] = "%s IS just UNSTOPPABLE : %d kills";
		[15] = "%s IS AMAZING : %d kills";
		[19] = "%s IS INSANE : %d kills";
		[23] = "%s IS OVERPOWERED : %d kills";
		[28] = "%s IS GODLIKE : %d kills";
		[35] = "%s IS MORE THAN GODLIKE : %d kills";
		[40] = "%s IS UNDEFEATABLE : %d kills";
		[50] = "%s IS PUSSYLICKER : %d kills";
		[60] = "%s IS CHICKENLIKE : %d kills";
		[80] = "%s IS TYSON CHICKEN : %d kills";
	};
	
	local expBooster = {
		[03] = 1.1;
		[04] = 1.2;
		[05] = 1.3;
		[07] = 1.35;
		[09] = 1.4;
		[10] = 1.5;
		[12] = 1.6;
		[14] = 1.7;
		[16] = 1.8;
		[18] = 2.1;
		[25] = 3.0;
		[50] = 4.0;
		[100] = 5.0;
		[200] = 10.0;
		[10000] = 1000;
	};
		
	local rapeMessages = {
		[04] = "%s is SLAYING %s ::: %d kills";
		[06] = "%s is ANTI %s ::: %d kills";
		[07] = "%s is RAPING %s ::: %d kills";
		[11] = "%s is DESTROYING %s ::: %d kills";
		[13] = "%s is REKTING %s ::: %d kills";
		[15] = "%s DESTROYED %s ::: %d kills";
	};
	local acc, prec;
	if (shooter and target) then
		if (shooter.isPlayer) then
			if (shooter.id ~= target.id) then
				
				if (target.isPlayer) then
				
					-- if (shooter.aimAssistance) then
						-- SendMsg(CENTER, target, "(%s: Killed you with Aim Assistance)", target:GetName()) end
				
					shooter.DeathStreak = 0;
					shooter.KillStreaks = (shooter.KillStreaks or 0) + 1;
					
				
					if (expBooster[shooter.KillStreaks]) then
						shooter.EXPBonus = expBooster[shooter.KillStreaks];
						SendMsg(CENTER, shooter, "(EXP BOOSTER :: x" .. shooter.EXPBonus .. ")");
					end;
					
					shooter.rapeStreaks = shooter.rapeStreaks or {};
					shooter.rapeStreaks[target.id] = (shooter.rapeStreaks[target.id] or 0) + 1;
					
					--if (rapeMessages[shooter.rapeStreaks[target.id]]) then
					--	SendMsg(BLE_CURRENCY, ALL, string.format(rapeMessages[shooter.rapeStreaks[target.id]], shooter:GetName(), target:GetName(), shooter.KillStreaks));
					--else
						if (messages[shooter.KillStreaks]) then
						SendMsg(BLE_CURRENCY, ALL, string.format(messages[shooter.KillStreaks],shooter:GetName(), shooter.KillStreaks));
					end;
					acc, prec = self:CalculateAccuracy(shooter, false, true);
				end;

				if (not BETA_FEATURES) then
					if (weapon and (((weapon.class == "GaussRifle" or weapon.class == "DSG1") and headshot)  or shooter.ImpulseKills)) then
						ExecuteOnAll("GetEnt('" .. target:GetName() .. "'):AddImpulse(-1," .. arr2str_(hit.pos) .. ", " .. arr2str_(hit.dir) .. ", 2500, 1)");
						target:AddImpulse(-1, hit.pos, hit.dir, 2500, 1);
					end
				end
				
			end;
			
		end;
		target.EXPBonus 	= 1.0;
		target.KillStreaks 	= 0;
		target.rapeStreaks 	= {};
		target.DeathStreak	= (target.DeathStreak or 0) + 1;
	end;
	--Debug(hit.type)
	ATOMLevelSystem:HandleKill(hit, headshot);
	ATOMStats.PermaScore:OnKill(shooter, target, (weapon and weapon.class or nil), GetDistance((target or shooter), shooter), headshot, acc, prec, hit.type);
	
	if (ATOMAttach and target.isPlayer) then 
		ATOMAttach:ResetPlayer(target, true);
	end;
	
	--if (target and target ~= shooter and target.class == "Player") then
	--	Script.SetTimer(1, function()
	--		self:SynchDeathPos(shooter, target, hit);
	--	end);
	--end;
	
	if (target.isPlayer) then
		if (target.AutoRevive or AutoRevive) then
			Script.SetTimer(500, function()
				if (target:IsDead()) then
					g_utils:RevivePlayer(target, nil, target.AutoReviveSpawnPoint or AutoReviveSpawnPoint);
				end;
			end);
		end;
	end;
	
	local weaponClass = hit.weapon and hit.weapon.class or ""
	
	if (target and shooter) then
		local wasFisted 	= weaponClass == "Fists"
		local wasFragged 	= hit.type == "frag"
		local suicide 		= killType == "suicide"
		local fallDeath 	= (shooter and shooter==target and hit.damage<=1000 and shooter.isPlayer and not hit.material_type and not hit.weapon and hit.type=="") 
		local blewUp 		= hit.explosion == true
		local pistoled 		= weaponClass == "SOCOM"
		local dsg1d 		= weaponClass == "DSG1"
		local gaussed 		= weaponClass == "GaussRifle"
		local minigunned 	= weaponClass == "Hurricane"
		local shutgunned 	= weaponClass == "Shotgun"
		local weaponIsVehicle = hit.weapon and hit.weapon.vehicle
		local killSelfCommand = suicide and hit.damage == 8190
		
		--Debug(hit.damage)
		local msgs = {
			"%s Killed %s",
		}
		if (fallDeath) then
			msgs = { "%s Fell to Death", "%s Slipped Off a Cliff", "%s Took the Jump" }
		elseif (killSelfCommand) then
			msgs = { "%s Took the Easy way Out" }
		elseif (suicide) then
			if (blewUp) then
				msgs = { "%s Blew Themselves Up", "%s Took the Bomb", "%s Ate a Frag" }
			elseif (weaponIsVehicle) then
				msgs = { "%s Drove Over Themselves", "%s rammed themself" }
			else
				msgs = { "%s Commited Suicide" }
			end
		elseif (weaponIsVehicle) then
			msgs = { "%s Drove Over %s", "%s Flattened %s", "%s Ran Over %s", "%s Ran %s Down" }
		elseif (wasFisted) then
			msgs = { "%s Fisted %s", "%s Kocked %s Out", "%s Kocked %s tf out", "%s Slapped %s" }
		elseif (pistoled) then
			msgs = { "%s Pistoled %s" }
		elseif (dsg1d) then
			msgs = { "%s Sniped %s", "%s Picked Off %s", "%s Scoped %s" }
		elseif (gaussed) then
			msgs = { "%s GAUSSED %s", "{p1} GAUSSED {p2}", "%s NOOB GUNNED %s", "%s Killed %s WITH A GAUSS" }
		elseif (wasFragged) then
			msgs = { "%s Fragged %s", "%s Fed %s the Frag", "%s Gave %s the Frag" }
		elseif (blewUp) then
			msgs = { "%s Blew Up %s", "%s Bombed %s", "%s Detonated %s", "%s Erased %s", "%s Destroyed %s", "%s Obliterated %s", "%s Nuked %s" }
		elseif (minigunned) then
			msgs = { "%s Ripped %s Apart", "%s Torn %s Apart", "%s Wiped %s Out" }
		elseif (shutgunned) then
			msgs = { "%s Pulverised %s", "%s Shotgunned %s" }
		else 
			msgs = { "%s Eliminated %s" }
		end
		
		local msg = GetRandom(msgs)
		msg = string.format(msg, shooter:GetName(), target:GetName()):gsub("{p1}", shooter:GetName()):gsub("{p2}", target:GetName());
		--SendMsg({ BLE_INFO, BLE_INFO, BLE_INFO, BLE_INFO }, GetPlayers(), " ")
		
		if (ATOM.cfg.Immersion.UseNewKillMessages) then
			--SendMsg({ BLE_INFO }, GetPlayers(), "																								")
			--SendMsg({ BLE_INFO }, GetPlayers(), "																								")
			--SendMsg({ BLE_INFO }, GetPlayers(), "																								")
			--SendMsg({ BLE_INFO }, GetPlayers(), msg)

			ExecuteOnAll("ATOMClient:ClientEvent(0, nil, \"" .. msg .. "\")")

			--ExecuteOnAll([[
			--if (not KILL_MESSAGES or System.GetCVar("mp_killmessages")~=0) then return Msg(1,"no kill messages...") end
			--local sMsg=']]..msg..[['
			--HUD.BattleLogEvent(eBLE_Information, sMsg)
			--]])
			--Debug(msg)
		else
			-- Debug("kill msgs off!")
		end
		
		if (dsg1d and g_gameRules.class == "PowerStruggle") then
			local iDist = GetDistance(target, shooter)
			if (iDist > 100) then
				local iReward = math.floor((iDist / 100) + 0.5) * 100 * (bHeadshot and 2.5 or 1)
				self:AwardPPCount(shooter.id, iReward, nil, true)
				SendMsg(BLE_CURRENCY, shooter, "SNIPER KILL : %0.2fm ( +%d PP )", iDist, iReward)
			end
		
		end
		
	end

	local iImpulse = 0
	if (shooter and target and target.hGrabber and shooter.id == target.hGrabber.id) then
		iImpulse = 3000
	end

	if (target and target.bGrabbed) then
		if (target.isPlayer) then
			target:ReleaseGrab(target.hGrabber, iImpulse)
		elseif (target.hGrabber) then
			Debug("NPC ok")
			target.hGrabber:DropNPC(target, iImpulse)
		end
		Debug("release GRAB NOW")
	end

	if (target and target.hGrabbing) then
		target.hGrabbing:ReleaseGrab(target, iImpulse)
		Debug("release GRAB NOW!!!")
	end

	if (target.hPiggy) then
		target:PiggyRide(target.hPiggy, false)
		Debug("PIGGY OFF NOW!")
	end

	--if (shooter and shooter.hGrabbing) then
	--	shooter.hGrabbed:ReleaseGrab(shooter, iImpulse)
	--	Debug("release GRABBED NOW, WE DIED")
	--end

	
	target.LastDeathTime = _time; -- for rage quit detection
	self:ResetBoughtItems(target);
	-- SysLog("all shit ok.")
	
end);

ATOMGameRules:Add('SynchDeathPos', function(self, shooter, target, hit)

	local RAGDOLL = SpawnCAP('Objects/library/architecture/aircraftcarrier/props/misc/golfball.cgf', hit.pos, target:GetMass()); --SpawnGUI('Objects/library/architecture/aircraftcarrier/props/misc/golfball.cgf', hit.pos, target:GetMass())
	RAGDOLL:AddImpulse(-1, hit.pos, hit.dir, target:GetMass() * 10);
	
	RAGDOLL_BALLS = RAGDOLL_BALLS or {}
	RAGDOLL_BALLS[RAGDOLL.id] = { s = _time, act = target };

	Script.SetTimer(10, function()
		ExecuteOnAll([[
			local a, b = GetEnt(']] .. target:GetName() .. [['), GetEnt(']] .. RAGDOLL:GetName() .. [[');
			RAGDOLL_BALLS[b.id] = { act = a };
		]]);
	end);
end);

ATOMGameRules:Add("CalculateAccuracy", function(self, player, noreset, battleLog)

	if (not player.HitAccuracy) then
		return;
	end;

	local accuracy  = 0;
	local precise   = 0;
	local distance  = 0;
	
	local shotCount = #player.HitAccuracy.shots;

	for i, shot in pairs(player.HitAccuracy.shots) do

		accuracy = accuracy + shot["c"];
		precise  = precise  + shot["a"];
		distance = distance + shot["b"];
			
	end;

	accuracy  	= (1 - (accuracy / shotCount)) * 100;
	precise   	= (1 - (precise  / shotCount)) * 100;
	distance  	= distance / shotCount;
	
	accuracy 	= cutNum(accuracy, 2) .. "%";
	precise  	= cutNum(precise,  2) .. "%";
	distance 	= cutNum(distance, 2) .. "m";
	
	local msg = "(PRECISION : " .. precise .. " ACCURACY : " .. accuracy .. " | " .. distance .. ")";
	
	SysLog("Precision: " .. precise .. "% distance: " .. distance);
	
	--SendMsg((battleLog and BLE_CURRENCY or CENTER), player, msg);
	
	--BigMsg(player, msg, 2, 2, rbg2Str(rbg2552rbg1(0, 0, 255)));
	--SendMsg(B_PP, msg)
	
	player.CurrentAccuracy = accuracy;
	
	if (not noreset) then
		player.HitAccuracy = nil;
	--	Debug("Reset")
	end;
	
end);
--[[
function  g_gameRules.Server:RequestRevive(playerId)
	local player = System.GetEntity(playerId);

	if (player and player.actor) then
		-- allow respawn if spectating player and on a team
		
		if (((player.actor:GetSpectatorMode() == 3 and self.game:GetTeam(playerId)~=0) or (player:IsDead() and player.death_time and _time-player.death_time>2.5)) and (not self:IsInReviveQueue(playerId))) then
			self:QueueRevive(playerId);
		--	Debug("REQUESTEd lol")
		end
	end
end--]]


ATOMGameRules:Add('RequestRevive', function(self, playerId)

			Debug("REVIIII!",playerId,"x")

	local hPlayer = System.GetEntity(playerId);
	if (hPlayer and hPlayer.actor) then


		--if (hPlayer.InBoxingArea or hPlayer.InArena or hPlayer.InPVPArena) then
		--	return self:RevivePlayer(hPlayer.actor:GetChannel(), hPlayer)
		--end

		if (hPlayer:CanInstantRevive()) then
			return self:RevivePlayer(hPlayer.actor:GetChannel(), hPlayer)
		else
		end

		if (g_gameRules.class == "PowerStruggle") then
			if (((hPlayer.actor:GetSpectatorMode() == 3 and self.game:GetTeam(playerId) ~= 0) or (hPlayer:IsDead() and hPlayer.death_time and _time - hPlayer.death_time > 2.5)) and (not self:IsInReviveQueue(playerId))) then
				self:QueueRevive(playerId)
			end
		else	
			if (hPlayer.death_time and _time - hPlayer.death_time > 2.5 and hPlayer:IsDead()) then
				self:RevivePlayer(hPlayer.actor:GetChannel(), hPlayer);
			end
		end
	end
end, "Server")

ATOMGameRules:Add('RequestSpectatorTarget', function(self, playerId, change)

	local player = System.GetEntity(playerId);
	--local mode = player.actor:GetSpectatorMode();
	
	if (not player or not change) then
		return false;
	end;
 
	if (change == 111) then
		ATOM:OnBotConnection(player);
		return;
	end;
	
	if (CLIENT_MOD and RCA) then
		if (RCA:OnResponse(player, change)) then
			return false;
		end;
	end;
	
	--[[local canSpectate = ATOMBroadcastEvent('RequestSpectatorTarget', player, mode)
	if (canSpectate == false) then
		return false;
	end;--]]
	
	if (g_gameRules.class == "PowerStruggle") then
		local team = self.game:GetTeam(playerId);
		if (player.IsDead and not player:IsDead() and team ~= 0 and mode ~= 3) then
			return false;
		end
	end;
	if (player.FIRST_PERSON_SPEC) then
		ExecuteOnPlayer(player,[[FIRST_PERSON_SPEC=nil]]);
		player.FIRST_PERSON_SPEC=false;
	end;
	local targetId = self.game:GetNextSpectatorTarget(playerId, change);
	if (not targetId or targetId==0) then
		targetId = g_utils:GetNextSpectatorTarget(player, change)
		local hEntity = GetEnt(targetId)
		if (hEntity and hEntity.actor and hEntity.actor:GetHealth() <= 0) then
			targetId = nil 
		end
		-- if (targetId and GetEnt(targetId) and GetEnt(targetId).actor:GetHealth
	end
	if (targetId) then
		if (targetId ~= 0 and not player.FIRST_PERSON_SPEC) then
			if (FP_SPEC and GetEnt(targetId).actor and targetId ~= player.id) then
				ExecuteOnPlayer(player,[[FIRST_PERSON_SPEC=GetEnt("]]..GetEnt(targetId):GetName()..[[").id]]);
				player.FIRST_PERSON_SPEC = true;
			else
				self.game:ChangeSpectatorMode(playerId, 3, targetId);
			end;
		elseif (self.game:GetTeam(playerId) == 0) then
			self.game:ChangeSpectatorMode(playerId, 1, NULL_ENTITY);	-- noone to spectate, so revert to free look mode
			ExecuteOnPlayer(player,[[FIRST_PERSON_SPEC=nil]]);
			player.FIRST_PERSON_SPEC = false
		end;
	end;
	
	
	
end, "Server");

ATOMGameRules:Add('OnChangeSpectatorMode', function(self, playerId, mode, targetId, resetAll, norevive)

---	Debug("Ok yyy!!!!")
	local player = System.GetEntity(playerId);
	if (not player) then
		return;
	end
	local target = targetId and System.GetEntity(targetId);
	if (not target) then
	--	return;
	end
	
	--Debug("Ok 1")
	--[[if (CLIENT_MOD and RCA) then
		if (RCA:OnResponse(player, mode)) then
			return false;
		end;
	end;--]]


	local canSpectate = ATOMBroadcastEvent('RequestSpectatorTarget', player, mode, target)
	if (canSpectate == false) then
		return false end
	
	local specCfg = ATOM.cfg.Spectator;
	if (specCfg) then
		if (specCfg.NoSpec and not player:HasAccess(MODERATOR)) then
			return false, SendMsg(ERROR, player, "Spectator Mode is currently Disabled")
		end
	end
	
	if (player.NoSpec) then
		return false, SendMsg(ERROR, player, "Your Spectator mode has been Blocked");
	elseif (player.NoSpecThese) then
		local NoSpec = target and target.id and player.NoSpecThese[target.id];
		if (NoSpec) then
			--return false, SendMsg(ERROR, player, "You cannot spectate this player");
			mode = player.LastMode == 1 and 2 or 1; -- Just change mode ;)
			player.LastMode = mode;
		end;
	end;
	
	if (player.bSpectatorBlocked == true) then
		return false, SendMsg(ERROR, player, (player.sSpectatorBlocked or "Spectator Mode Temporarily Blocked"))
	end
	
	

 -- IA part start

	-- !!hook
	--local canChange = ATOMBroadcastEvent("CanChangeSpectatorMode", player, mode, resetAll, norevive);
	--if (canChange == false) then
	--	return;
	--end;
	
	if (player.InMeeting) then
		SendMsg(ERROR, player, "Cannot spectate while in Meeting!");
		return;
	end;
	
	if (player.SpectatorTimeout and player.SpectatorTimeoutDur and _time - player.SpectatorTimeout < player.SpectatorTimeoutDur) then
		return false, SendMsg(ERROR, player, "Spectator Mode blocked for %0.2fs (%s)", player.SpectatorTimeoutDur - (_time - player.SpectatorTimeout), player.SpectatorTimeoutReason);
	end;
	

	if (g_gameRules.class == "PowerStruggle") then
		if (resetAll and ATOMStats.cfg.ResetScoreOnSpectatorMode) then -- disabled, nobody likes to lose points after spectator mode
			self:ResetPP(playerId);
			self:ResetCP(playerId);
		end;
		norevive = true; -- this must be here, because PowerStruggle calls InstantAction with norevive=true
	end;
	local canSpec, msg;
	if (mode>0) then

		if (resetAll) then
			player.death_time=nil;
			player.inventory:Destroy();
			if (mode==1 or mode==2) then
				self.game:SetTeam(0, playerId);
			end;
		end;

		if (mode == 1 or mode == 2) then
			local pos=g_Vectors.temp_v1;
			local angles=g_Vectors.temp_v2;

			player.actor:SetSpectatorMode(mode, NULL_ENTITY);
			player.LastSpecTarget = nil;
			local locationId=self.game:GetInterestingSpectatorLocation();
			--Debug("locId = %s", tostr(locationId))
			if (locationId) then
				local location=System.GetEntity(locationId);
				if (location) then
					pos=location:GetWorldPos(pos);
					angles=location:GetWorldAngles(angles);

					self.game:MovePlayer(playerId, pos, angles);
				end;
			end;
		elseif (mode == 3) then
			if (targetId and targetId~=0) then
				--local player = System.GetEntity(playerId);
				canSpec, msg = self:OnSpectating(player, GetEnt(targetId));
				if ( canSpec) then
					player.actor:SetSpectatorMode(3, targetId);
				elseif (msg) then
					SendMsg(ERROR, player, msg);
				end;
			else
				local newTargetId = self.game:GetNextSpectatorTarget(playerId, 1);
				if (newTargetId and newTargetId~=0) then
					--local player = System.GetEntity(playerId);
					canSpec, msg = self:OnSpectating(player, GetEnt(newTargetId));
					if ( canSpec) then
						player.actor:SetSpectatorMode(3, newTargetId);
					elseif (msg) then
						SendMsg(ERROR, player, msg);
					end;
				end;
			end;
		end;
	elseif (not norevive) then
		if (self:CanRevive(playerId)) then
			player.actor:SetSpectatorMode(0, NULL_ENTITY);
			self:RevivePlayer(player.actor:GetChannel(), player);
			player.LastSpecTarget = nil;
		end;
	end;

	if (resetAll and ATOMStats.cfg.ResetScoreOnSpectatorMode) then -- disabled, nobody likes to lose score after spectator mode
		self:ResetScore(playerId);
	end

	self.channelSpectatorMode[player.actor:GetChannel()] = mode;

	if (g_gameRules.class == "PowerStruggle") then
		if (resetAll and mode>0) then
			self:ResetRevive(playerId);
		end;
	end;
	ATOMBroadcastEvent("OnChangeSpectatorMode", player, mode, resetAll, norevive);
end, "Server");


ATOMGameRules:Add('OnSpectating', function(self, player, target)
	local blocked, msg;-- = ATOM:OnSpectating(player, target);
	if (not blocked) then
		if (not player.LastSpecTarget or target.id ~= player.LastSpecTarget) then
			SysLog("%s started spectating %s", player:GetName(), target:GetName());
			if (target.isPlayer and target:HasAccess(player:GetAccess())) then
				SendMsg(BLE_CURRENCY, target, "%s: Started Spectating You ...", player:GetName());
				if (ATOM.cfg.Spectator.ChatMessage and target:HasAccess(ATOM.cfg.Spectator.ChatAccess)) then
					SendMsg(CHAT_ATOM, target, "(%s: Started Spectating You)", player:GetName());
				end;
			end;
			blocked, msg = ATOM:OnSpectating(player, target);
			if (blocked) then
				if (g_warnSystem:ShouldWarn("Spectator")) then
					WarnPlayer(ATOM.Server, player, "Spectator Spam");
				end;
			end;
		end;
	end;
	player.LastSpecTarget = target.id;
	player.LastSpecTime = _time;
	return blocked, msg;
end);


ATOMGameRules:Add('SetPlayerScore', function(self, playerId, score)
	self.game:SetSynchedEntityValue((type(playerId)=="table" and playerId.id or playerId), self.SCORE_KILLS_KEY, score);
end);

ATOMGameRules:Add('SetPlayerDeaths', function(self, playerId, deaths)
	self.game:SetSynchedEntityValue((type(playerId)=="table" and playerId.id or playerId), self.SCORE_DEATHS_KEY, deaths);
end);

g_gameRules.SpawnPlayer = function(self, channelId, name)
	self.dudeCount = self.dudeCount or 0;
		
	local pos = g_Vectors.temp_v1;
	local angles = g_Vectors.temp_v2;
	ZeroVector(pos);
	ZeroVector(angles);
		
	local locationId = self.game:GetInterestingSpectatorLocation();
	if (locationId) then
		local location = System.GetEntity(locationId);
		if (location) then
			pos = location:GetWorldPos(pos);
			angles = location:GetWorldAngles(angles);
		end
	end
	local class = "Player";
	if (ATOM and ATOM.cfg.PlayerClass) then
		class = ATOM.cfg.PlayerClass;
	end;
	local name = tostring(name);
	if (ATOMNames ~= nil) then
		name = ATOMNames:GetName(name, channelId, ATOM.channelCCs[channelId]) or name;
	end;
	name = name or "Nomad";
	
	name = name:gsub("%%", "_");
	name = name:gsub("@",  "_");
	
	--Debug("name",name)
	SysLog("New player with name %s has been spawned", name)
	
	local player = self.game:SpawnPlayer(channelId, name or "Nomad", class, pos, angles);	
	
	return player;
end;

ATOMGameRules:Add('OnClientEnteredGame', function(self, channelId, player, reset) -- self == g_gameRules

	local onHold = CryAction.IsChannelOnHold(channelId);
	if ((not onHold) and (not reset)) then
		self.game:ChangeSpectatorMode(player.id, 2, NULL_ENTITY);
	elseif (not reset) then
		if (player.actor:GetHealth()>0) then
			player.actor:SetPhysicalizationProfile("alive");
		else
			player.actor:SetPhysicalizationProfile("ragdoll");
		end
	end

	if (not reset) then
	--	self.otherClients:ClClientEnteredGame(channelId, player:GetName());
	end

	self:SetupPlayer(player);

	if ((not g_localActorId) or (player.id~=g_localActorId)) then
		self.onClient:ClSetupPlayer(player.actor:GetChannel(), player.id);
	end

	--ATOM:ChangeCapacity(player);
	
	if (g_gameRules.class == "PowerStruggle") then
		if (player) then
			if (reset) then
				self:SetPlayerPP(player.id, self.ppList.START);
			end
			self.inBuyZone = self.inBuyZone or {};
			if (self.inBuyZone[player.id]) then
				for zoneId, yes in pairs(self.inBuyZone[player.id]) do
					if (yes) then
						self.onClient:ClEnterBuyZone(player.actor:GetChannel(), zoneId, true);
					end;
				end;
			end;
		end;
	end;

	-- !!hook
	if (ATOM.initialized) then
		ATOMBroadcastEvent("OnEnterGame", player, channelId);
	end;
end, "Server");

ATOMGameRules:Add('OnShoot', function(self) -- self == g_gameRules
end);

ATOMGameRules:Add('UpdatePings', function(self, frameTime)
--	Debug("W")
end);

ATOMGameRules:Add('GetAvergePing', function(self)
	return self.AveragePing;
end);

ATOMGameRules:Add("GetLaggers", function(self)
	local laggers = {};
	for i, player in pairs(GetPlayers()or{}) do
		if (player.actor:IsLagging() or player:GetPing() >= (ATOM.cfg.AveragePing or 240)) then
			table.insert(laggers, { player, player:GetPing() });
		end;
	end;
	table.sort(laggers, function(a,b)
		return a[2]>b[2]
	end);
	
	return laggers;
end);

ATOMGameRules:Add('HandlePings', function(self)
	self.AveragePing = 0
	local players = g_game:GetPlayers();
	if (players) then
		local totalPing = 0;
		for i, player in ipairs(players) do
			local channelId = player.actor:GetChannel()
			if (player and channelId) then
				
				ATOMDefense:OnPlayerTick(player, ping);
				ATOMPlayerUtils:OnPlayerTick(player);
				g_utils:OnPlayerTick(player);
				
				local ping = math.floor((g_game:GetPing(channelId) or 0) * 1000 + 0.5);

				if (self.Fake_Ping) then
					ping = self.Fake_Ping;
				elseif (player.Fake_Ping) then
					ping = player.Fake_Ping;
				end;				

				if (ATOMBroadCaster ~= nil) then
					local newPing = ATOMBroadcastEvent("OnPlayerTick", player, ping);
					if (newPing and type(newPing) == "number" ) then
						ping = newPing;
					end;
				end;
					
				--ping = ping;
				if (ATOM.cfg.HidePings) then
					ping = 0;
				elseif (ATOM.cfg.PingMultiplier) then
					ping = (ATOM.cfg.AllowNegativePing and ping * ATOM.cfg.PingMultiplier or math.max(1, ping * ATOM.cfg.PingMultiplier));
				end;
				
				ATOM:OnTimer(4, player, ping);
				
				totalPing = totalPing + ping;
				
				if (not player.LastPing or round(ping or 0)~=player.LastPing) then
					g_game:SetSynchedEntityValue(player.id, self.SCORE_PING_KEY, round(ping or 0));
					player.LastPing = round(ping or 0);
				end;
				player.allPings = player.allPings or {};
				table.insert(player.allPings,  ping);
				
				if (arrSize(player.allPings) > 10) then
					table.remove(player.allPings, 1);
				end;
				if (arrSize(player.allPings) > 100) then
					table.remove(player.allPings, 1);
				end;
				player.actorStats.averagePing = getAverage(player.allPings);
			end;
		end;
		self.AveragePing = totalPing / arrSize(GetPlayers());
	end;
end);



ATOMGameRules:Add('StartWork', function(self, entityId, playerId, work_type)
	local work=self.works[playerId];
	if (not work) then
		work={};
		self.works[playerId]=work;
	end
	
	work.active=true;
	work.entityId=entityId;
	work.playerId=playerId;
	work.type=work_type;
	work.amount=0;
	work.complete=nil;
	
	--Log("%s starting '%s' work on %s...", EntityName(playerId), work_type, EntityName(entityId));
	
	-- HAX
	local entity = System.GetEntity(entityId);
	if (entity) then
		if (entity.CanDisarm and entity:CanDisarm(playerId)) then
			work_type = "disarm";
			work.type = work_type;
		end
	end
	local player = System.GetEntity(playerId);
	if (entity.actor) then
		self:OnSuitReboot(player, entity);
		if (self.class == "PowerStruggle" and self:IsInReviveQueue(entity.id)) then
			self:ResetRevive(entity.id);
			Debug("start reboot, STOP revive")
		end;
	else
		self.onClient:ClStartWorking(self.game:GetChannelId(playerId), entityId, work_type);
		if (self:IsTurret(entity) and work_type == "lockpick") then
			ExecuteOnPlayer(GetEnt(playerId), "g_gameRules.work_name=\"Hacking Turret ...\"HUD.SetProgressBar(true, 0, g_gameRules.work_name);Msg(0,'OK')")
		end
	end;
end);


ATOMGameRules:Add('CanRepairVehicle', function(self, entity,entityId,playerId)
	local dmgratio=entity.vehicle:GetRepairableDamage();
	if (self.game:IsSameTeam(entityId, playerId) or self.game:IsNeutral(entityId)) then
		if ((dmgratio>0) and (not entity.vehicle:IsSubmerged())) then
			return true;
		end
	end
end);


ATOMGameRules:Add('CanRepairHQ', function(self, entity, playerId)
	local repairableHP = entity.Properties.nHitPoints - entity:GetHealth();
	if (self.game:IsSameTeam(entity.id, playerId)) then
		if ((repairableHP>0) and (not entity.HQDestroyed)) then
			return true;
		end
	end
end);

ATOMGameRules:Add('CanRepairTurret', function(self, entity,playerId)
	if (((entity.class == "AutoTurret") or (entity.class == "AutoTurretAA"))) then
	local health=entity.item:GetHealth();
		local maxhealth=entity.item:GetMaxHealth();
		if ((health < maxhealth)) then
			return true;
		end
	end
end);

ATOMGameRules:Add('CanHackTurret', function(self, entity,playerId)
	if (((entity.class == "AutoTurret") or (entity.class == "AutoTurretAA"))) then
		local turretTeam = g_game:GetTeam(entity.id)
		local playerTeam = g_game:GetTeam(playerId)
		return turretTeam ~= 0 and turretTeam ~= playerTeam;
	end
end);
ATOMGameRules:Add('CanLockpickVehicle', function(self, entity,playerId)
	if ((not self.game:IsSameTeam(entityId, playerId)) and (not self.game:IsNeutral(entityId))) then
		local v=entity.vehicle;
		if (v:IsEmpty() and (not v:IsDestroyed())) then
			return true;
		end;
	end;
end);

ATOMGameRules:Add('CanWorkOnPlayer', function(self, playerId)
--	Debug("WorkOnPlayer")
	local player = System.GetEntity(playerId);
	if (not player.rebooting) then
		local c={nil,1000}
		for i, tgt in pairs(g_gameRules.game:GetPlayers()or{})do
		--	Debug(GetDistance(player,tgt))
			if (tgt:IsDead() and GetDistance(player,tgt)<c[2] and tgt.id ~= player.id and (g_gameRules.class == "InstantAction" or g_game:GetTeam(playerId) == g_game:GetTeam(tgt.id))) then
				if (c[1]) then
					c[1] = nil;
					break;
				end;	
				--Debug("So close, USING :D" .. tgt:GetName())
				c[1] = tgt.id
				c[2] = GetDistance(player,tgt)
			end;
		end;
		if (c[1]) then
		--	Debug("So close, USING :D")
			player.rebootingFoundDistance = minimum(5, c[2])
			player.rebooting = c[1]
		end;
	end;
	if (player and player.rebootingFoundDistance and player.rebooting and System.GetEntity(player.rebooting) and GetDistance(player, System.GetEntity(player.rebooting)) < player.rebootingFoundDistance) then
	--	Debug("!!!")
	--	Debug("Yes, can work ON PLAYER... ",player.rebooting,System.GetEntity(player.rebooting):GetName())
		return player.rebooting;
	elseif (player and not player.rebootingFoundDistance) then
		player.rebootingFoundDistance = nil;
		player.rebooting = nil;
	end;
	return;
end);

ATOMGameRules:Add('CanWork', function(self, entityId, playerId, work_type)
	if (self.isServer) then
		local work=self.works[playerId];
		if (work) then
			if (work.active and (work.entityId~=entityId)) then -- disarming explosives will change work.type, but the weapon will keep reporting a different work_type
	--			Debug("Twerk :S")
				return false;
			end
		end
	end
	local entity = System.GetEntity(entityId);
	if (work_type=="repair") then
		if (entity.actor) then
			return self:CanRebootNanosuit(playerId, entityId);
		elseif (entity.vehicle) then
			--Debug("work on ve")
			return self:CanRepairVehicle(entity,entityId,playerId);
		elseif (entity.item) then
			return self:CanRepairTurret(entity,playerId);
		elseif (entity.CanDisarm and entity:CanDisarm(playerId)) then
			return true;
		elseif (entity.class == "HQ") then
			--Debug("work on hq")
			return self:CanRepairHQ(entity, playerId);
		end;
	elseif (work_type=="lockpick") then
		if (entity.vehicle) then
			return self:CanLockpickVehicle(entity,playerId);
		elseif (entity.item) then
			return self:CanHackTurret(entity,playerId)
		end;
	end;
end);

ATOMGameRules:Add('CanRebootNanosuit', function(self, playerId, entityId)
	local player = GetEnt(playerId);
	local target = GetEnt(entityId);
	
	if (player and target) then
		if (not target.isPlayer) then
			return false;
		end;
		if (g_gameRules.class == "PowerStruggle" and g_game:GetTeam(playerId) ~= g_game:GetTeam(entityId)) then
			return false;
		end;
		--not target:IsDead()) or 
		--Debug(target.actor:GetHealth())
		Debug(target.actor:GetNanoSuitEnergy())
		if (target.actor:GetNanoSuitEnergy() >= 200 or target:IsSpectating()) then
			return false;
		end;
		--Debug("Ok")
		if (GetDistance(player, target) > 4) then
			return false;
		end;
		if (player.rebooting) then
			if (player.rebooting ~= entityId) then
				return false;
			end;
			return true;
		end;
		if (target.rebooter) then
			if (target.rebooter ~= playerId) then
				return false;
			end;
			return true;
		end;
		--Debug("Si :D")
		target.rebooter = playerId;
		player.rebooting = entityId;
		return true;
	end;
	return false;
end);

----------------------------------------------------------------------------------------------------
ATOMGameRules:Add('OnSuitRebooted', function(self, player, entity, complete)
	
	if (complete) then
		if (self:IsInReviveQueue(entity.id)) then
			self:ResetRevive(entity.id);
			--Debug("reset revive: Onsuitrebooted COMPLETE!!!!!!!!!!!")
		end;
		local pp = 150; -- cfg entry ...
		SendMsg({CENTER,BLE_CURRENCY}, player, "SUIT : REBOOTED ( +%d PP )", pp);
		self:AwardPPCount(player.id, pp, nil, true);
		SendMsg(CENTER, entity, "%s : REBOOTED YOUR NANOSUIT", player:GetName());
	elseif (self.class == "PowerStruggle") then
		if (not self:IsInReviveQueue(entity.id)) then
			self.Server.RequestRevive(self, entity.id);
			--Debug("reset revive: Onsuitrebooted NOT COMPLETE!!!!!!!!!!!")
		end;
	end;
	local torchName = '';
	local currItem = player.inventory:GetCurrentItem();
	if (currItem) then
		if (currItem.class == "RepairKit" or currItem.class == "LockpickKit") then
			torchName = currItem:GetName();
		end;
	end;
	local code = [[
		local a, b, c = GetEnt(']] .. player:GetName() .. [['), GetEnt(']] .. entity:GetName() .. [['), GetEnt(']] .. torchName .. [[');
		if (b and b.REBOOT_SLOT) then
			b:FreeSlot(b.REBOOT_SLOT);
			b.REBOOT_SLOT = nil;
		end;
		if (c and c.SPARK_SLOT) then
			c:FreeSlot(c.SPARK_SLOT);
			c.SPARK_SLOT = nil;
		end;
	]];
	ExecuteOnAll(code);
end);
----------------------------------------------------------------------------------------------------
ATOMGameRules:Add('OnSuitReboot', function(self, player, entity)
	local torchName = '';
	local currItem = player.inventory:GetCurrentItem();
	if (currItem) then
		if (currItem.class == "RepairKit" or currItem.class == "LockpickKit") then
			torchName = currItem:GetName();
		end;
	end;
	local code = [[
		g_gameRules.work_type = "lockpick";
		local a, b, c = GetEnt(']] .. player:GetName() .. [['), GetEnt(']] .. entity:GetName() .. [['), GetEnt(']] .. torchName .. [[');
		if (b) then
			if (b.id == g_localActorId) then
				g_gameRules.work_name = "Nanosuit is ]] .. (entity:IsDead() and "Rebooting" or "being Recharged") .. [[ ..";
				HUD.SetProgressBar(true, 0, g_gameRules.work_name);
			end;
			if (b.REBOOT_SLOT) then
				b:FreeSlot(b.REBOOT_SLOT);
			end;
			b.REBOOT_SLOT = b:LoadParticleEffect(-1,'misc.electric_man.electricity',{bActive=1,bPrime=1,Scale=1,SpeedScale=1,CountScale=1,bCountPerUnit=1,AttachType='Render',AttachForm='Surface',PulsePeriod=0});
		end;
		if (c) then
			if (c.SPARK_SLOT) then
				c:FreeSlot(c.SPARK_SLOT);
			end;
			c.SPARK_SLOT = c:LoadParticleEffect(-1, "misc.sparks.directional", {});
		end;
		if (a and a.id == g_localActorId) then
			g_gameRules.work_name = "]] .. (entity:IsDead() and "Reviving" or "Recharging") .. [[ :: " .. b:GetName();
			HUD.SetProgressBar(true, 0, g_gameRules.work_name);
		end;
	]];
	ExecuteOnAll(code);
end);
----------------------------------------------------------------------------------------------------
ATOMGameRules:Add('RebootSuit', function(self, player, entity, work, workamount)
	work.amount = work.amount + workamount * (entity:IsDead() and 0.25 or 0.1);
	if (not entity:IsDead()) then
		work.amount = minimum(1, (entity.actor:GetNanoSuitEnergy()) + 2);
		if (_time - entity.LastHitTime < 8) then
			work.complete = true;
			self.onClient:ClStopWorking(self.game:GetChannelId(player.id), entity.id, false);
			self.onClient:ClStopWorking(self.game:GetChannelId(entity.id), entity.id, false);
			return true;
		end;
	end;
	
	if (not player.RepairStartAmount) then
		player.RepairStartAmount = work.amount;
	end;
	
	local _div = entity:IsDead() and 1 or 2;
	
	if (entity.isPlayer) then
		self.onClient:ClStepWorking(self.game:GetChannelId(entity.id), math.floor((work.amount/_div)  + 0.5));
	end;
	local max = entity:IsDead() and 100 or 200;-- or 200;
	self.onClient:ClStepWorking(self.game:GetChannelId(player.id), math.floor((work.amount/_div) + 0.5));
	if (work.amount >= max) then
		--Debug("finished")
		if (entity.isPlayer) then
			if (entity:IsDead()) then
				self.game:RevivePlayer(entity.id, entity:GetPos(), entity:GetAngles(), g_game:GetTeam(entity.id), false);
				self:EquipPlayer(entity);
				self.Utils:SpawnEffect(ePE_Light, entity:GetPos())
				self:ResetRevive(entity.id);
			else
				--Debug("reward for repairing ",200-player.RepairStartAmount,"energy:",(200-player.RepairStartAmount)*10)
				self:AwardPPCount(player.id, 200 - player.RepairStartAmount);
				player.RepairStartAmount = nil;
			end;
		end;
		work.complete = true;
	elseif (not entity:IsDead()) then
		--Debug(work.amount)
		--Debug(work.amount/2)
		entity.actor:SetNanoSuitEnergy(work.amount);
	end;
	return (work.complete ~= true);
end);
----------------------------------------------------------------------------------------------------
ATOMGameRules:Add('StopWork', function(self, playerId)
	local work=self.works[playerId];
	if (work and work.active) then
		if (work.complete) then
			--Log("%s completed '%s' work on %s...", EntityName(playerId), work.type, EntityName(work.entityId));
		else
			--Log("%s stopping '%s' work on %s...", EntityName(playerId), work.type, EntityName(work.entityId));
		end
		work.active=false;

		self.onClient:ClStopWorking(self.game:GetChannelId(playerId), work.entityId, work.complete or false);
		local entity = System.GetEntity(work.entityId)
		local player = System.GetEntity(playerId);
		
		local hqreward = 0;
		if (entity and entity.class == "HQ") then
			--Debug("HQ repair stop")
			if (player.HQRepairHPTotal) then
				local repairedHP = player.HQRepairHPTotal;
				if (repairedHP and repairedHP > 0) then
				--	Debug(repairedHP)
				--	Debug("pp", repairedHP);
					hqreward = repairedHP * 2;
				end;
				player.HQRepairHPTotal = nil;
			end;
		end;
		
		if (work.complete) then
		
			if (hqreward > 0) then
				local teamID = g_game:GetTeam(player.id);
				local sTeamPlayers = GetPlayersByTeam(teamID, true);
				local oTeamPlayers = GetPlayersByTeam(teamID, false);
				
				SendMsg(teamID == 2 and CHAT_TEAMUS or CHAT_TEAMNK, oTeamPlayers, "%s: Repaired the enemy HQ and got %d Prestige", player:GetName(), hqreward);
				SendMsg(teamID == 2 and CHAT_TEAMUS or CHAT_TEAMNK, sTeamPlayers, "%s: Repaired our HQ and got %d Prestige", player:GetName(), hqreward);
			end;
		
			self.allClients:ClWorkComplete(work.entityId, work.type);
			if (entity and entity.actor) then
				self.onClient:ClStopWorking(self.game:GetChannelId(work.entityId), work.entityId, true);
			--	self.allClients:ClWorkComplete(work.entityId, work.type);
				self:OnSuitRebooted(player, entity, true);
			elseif (entity and self:IsTurret(entity)) then
				if (work.type == "repair") then
					Debug("turret REPAIRED !")
					self:OnTurretRepaired(player, entity)
				else
					Debug("turret HACKED ")
					self:OnTurretHacked(player, entity)
				end
			end;
		elseif (entity and entity.actor) then
			self.onClient:ClStopWorking(self.game:GetChannelId(work.entityId), work.entityId, false);
		--	self.allClients:ClWorkComplete(work.entityId, work.type);
			self:OnSuitRebooted(player, entity, false);
		end
		
		if (player) then
			player.rebooting = nil;
		end;
		if (entity and self.class == "PowerStruggle") then
			--Debug("rebooter stop")
			entity.rebooter = nil;
			if (not self:IsInReviveQueue(entity.id)) then
				--Debug("enable revive again")
				self.Server.RequestRevive(self, entity.id)
			end;
		end;
	end
end);
--
ATOMGameRules:Add('OnTurretRepaired', function(self, player, turret)

	local tCfg = ATOM.cfg.DamageConfig.Turrets
	local iReward = tCfg.RepairReward
	
	Debug("iReward",iReward)

	self:AwardPPCount(player.id, iReward, nil, true);
	
	if (iReward > 0) then
		SendMsg({BLE_CURRENCY,CENTER}, player, "Turret Repaired ( +%d PP )", iReward) end
		
	Debug("award money etc ???")
end)


ATOMGameRules:Add('OnTurretHacked', function(self, player, turret)

	local tCfg = ATOM.cfg.DamageConfig.Turrets
	local iReward = tCfg.HackReward or 300
	
	Debug("iReward",iReward)

	self:AwardPPCount(player.id, iReward, nil, true);
	
	if (iReward > 0) then
		SendMsg({BLE_CURRENCY,CENTER}, player, "Turret Hacked ( +%d PP )", iReward)
		SendMsg({BLE_ERROR}, DoGetPlayers({ teamId = turret.OLD_TEAM or g_game:GetTeam(turret.id), sameTeam = true }), "The Enemy hacked one of our Turrets!") end
		
	Debug("award money etc ???")
end)

--
ATOMGameRules:Add('Work', function(self, playerId, amount, frameTime)
	--Debug("WORK!")
	local work=self.works[playerId];
	if (work and work.active) then
		--Log("%s doing '%s' work on %s for %.3fs...", EntityName(playerId), work.type, EntityName(work.entityId), frameTime);
		
		local entity=System.GetEntity(work.entityId);
		local player=System.GetEntity(playerId);
		if (entity) then
			local workamount = amount * frameTime;
			if (player and player.megaGod) then
				workamount=workamount*100
			end;
			if (work.type == "repair") then
				if (entity.actor) then
					return self:RebootSuit(GetEnt(playerId), entity, work, workamount);
				end;
				if (not self.repairHit) then
					self.repairHit={
						typeId	=self.game:GetHitTypeId("repair"),
						type		="repair",
						material=0,
						materialId=0,
						dir			=g_Vectors.up,
						radius	=0,
						partId	=-1,
					};
				end
				
				local hit=self.repairHit;
				hit.shooter=System.GetEntity(playerId);
				hit.shooterId=playerId;
				hit.target=entity;
				hit.targetId=work.entityId;
				hit.pos=entity:GetWorldPos(hit.pos);
				hit.damage=workamount;
				work.amount=work.amount+workamount;

				if (entity.vehicle) then
					entity.Server.OnHit(entity, hit);
					work.complete=entity.vehicle:GetRepairableDamage()<=0; -- keep working?
					
					local progress=math.floor(0.5+(1.0-entity.vehicle:GetRepairableDamage())*100)
					self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress);
					
					return (not work.complete);
				elseif (entity.item and (entity.class=="AutoTurret" or entity.class=="AutoTurretAA") ) then
					entity.Server.OnHit(entity, hit);
					work.complete=entity.item:GetHealth()>=entity.item:GetMaxHealth();

					local progress=math.floor(0.5+(100*entity.item:GetHealth()/entity.item:GetMaxHealth()));
					self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress);
					
					return (not work.complete);
				elseif ( entity.class == "HQ" ) then
				
				
					workamount = 0.1;
					if (player and player.megaGod) then
						workamount=workamount*100
					end;
					hit.damage = workamount;
					work.amount = work.amount+workamount;
					
					player.HQRepairHPTotal = (player.HQRepairHPTotal or 0) + hit.damage;
					--Debug(hit.damage)
					--entity.Server.OnHit(entity, hit);
					
					
					
					entity:SetHealth(entity:GetHealth() + hit.damage)
					work.complete=entity:GetHealth()>=entity.Properties.nHitPoints;

					--Debug(work.complete,entity.Properties.nHitPoints,"/",entity:GetHealth())
					local progress=math.floor(0.5+(100*entity:GetHealth()/entity.Properties.nHitPoints));
					self.onClient:ClStepWorking(self.game:GetChannelId(playerId), progress);
					
					return (not work.complete)
				end
			elseif (work.type=="lockpick") then
				if (entity.actor) then
					return self:RebootSuit(GetEnt(playerId), entity, work, workamount);
				end;
				
				if (entity.item and self:IsTurret(entity)) then
					return self:HackTurret(GetEnt(playerId), entity, work, workamount)
				end
				
				if (true) then
					work.amount=work.amount+workamount;
					if (work.amount>100) then
						self.game:SetTeam(self.game:GetTeam(playerId), entity.id);
						entity.vehicle:SetOwnerId(NULL_ENTITY);
						work.complete=true;
					end	
				end;
				
					self.onClient:ClStepWorking(self.game:GetChannelId(playerId), math.floor(work.amount+0.5));
				return (not work.complete);
			elseif (work.type=="disarm") then
				if ((entity.CanDisarm and entity:CanDisarm(playerId)) or (entity.class == "Claymore" or entity.class == "AVMine" or entity.class == "c4explosive")) then
					work.amount=work.amount+(100/4)*frameTime;
					
					if (work.amount>100) then
						work.complete=true;
						--Debug("disarmed!")
						if (self.OnDisarmed) then
							Debug("exi")
							self:OnDisarmed(work.entityId, playerId);
						else
							--System.RemoveEntity(work.entityId);
						end
					end

					self.onClient:ClStepWorking(self.game:GetChannelId(playerId), math.floor(work.amount+0.5));
					
					return (not work.complete);
				end
			end
		end
	end

	return false;
end);




ATOMGameRules:Add('IsTurret', function(self, id)
	
	local sClass = id
	if (type(id) == "table") then
		sClass = id.class
	end
	
	return (sClass == "AutoTurret" or sClass == "AutoTurretAA")
end)


ATOMGameRules:Add('HackTurret', function(self, player, turret, work, workamount)
	work.amount = work.amount + (workamount * 0.4);
	Debug("OK -> ",work.amount)
	if (work.amount > 100) then
		turret.OLD_TEAM = g_game:GetTeam(turret.id)
		turret.WAS_HACKED = true
		turret.HACK_TIMER = _time
		self.game:SetTeam (g_game:GetTeam(player.id), turret.id)
		work.complete = true
		SendMsg((turret.OLD_TEAM == TEAM_NK and CHAT_TEAMNK or CHAT_TEAMUS), DoGetPlayers({ team = turret.OLD_TEAM }), "The Enemy has Hacked one of our Auto Turrets!")
	end	
	self.onClient:ClStepWorking(self.game:GetChannelId(player.id), math.floor(work.amount+0.5));
	
	return (work.complete ~= true);
end)


ATOMGameRules:Add('OnDisarmed', function(self, entityId, disarmerId)

	local entity = System.GetEntity(entityId);
	local player = System.GetEntity(disarmerId);
	
	local class = entity and entity.class;
	Debug("class",class)
	class = 
	class == "claymoreexplosive" and "Claymore" or 
	class == "c4explosive"       and "C4" or 
	class == "avexplosive"       and "AVMine"
	
	if (entity and player and class) then
		Script.SetTimer(1, function()
			ATOM:GiveItem(player, class, 1, true);
		end);
	end;
	
	entity.DISARMED = true;
	entity.WAS_DISARMED = true;
	
	local pp = 0;
	
	if (self.game:GetTeam(entityId)~=self.game:GetTeam(disarmerId) or ATOM.cfg.GamePlayConfig.AlwaysAwardDisarmPP) then
		-- give the player some PP
		pp = self.ppList.DISARM
		
		self:AwardPPCount(disarmerId, pp, nil, true);
	end
	
	SendMsg({BLE_CURRENCY,CENTER}, player, "%s : DISARMED ( +%d PP )", class:upper(), pp);
	
	Script.SetTimer(1, function()
		System.RemoveEntity(entityId);
	end);
end);		


ATOMGameRules:Add('DoBuyAmmo', function(self, playerId, name)
--Log("PowerStruggle.Server:SvBuyAmmo(%s, %s)", EntityName(playerId), tostring(name));
	
	local player=System.GetEntity(playerId);
	if (not player) then
		return false;
	end
	
	local def=self:GetItemDef(name);
	if (not def and name ~= "sell") then
		ATOMBuying:InvalidItem(player, "Ammo", tostring(name));
		return false;
	end
	
	local revive;
	local alive=true;
	if (player.actor:GetHealth()<=0) then
		revive=self.reviveQueue[playerId];
		alive=false;
		
		
	end
	if (name == "sell") then
		local tdef;
		local curr = player:GetCurrentItem();
		if (self:IsInBuyZone(playerId)) then
			if (curr) then
				for i, v in pairs(g_gameRules.buyList) do
					if (v.class and v.class == curr.class) then
						tdef = v;
						--Msg(0,v.id)
					end;
				end;
				if (tdef and tdef.price) then
					local sellPrice = math.floor(math.max(0, tdef.price*0.75)+0.5);
					ATOMBuying:Message(player, "Item '$7%s$9' Sold for $4%d$9 PP", curr.class, sellPrice);
					Debug("item sold for ", sellPrice)
					self:AwardPPCount(player.id, sellPrice, nil, true);
					ExecuteOnPlayer(player, "HUD.BattleLogEvent(eBLE_Currency, \"Item " .. tdef.name .. " Sold ( +" .. sellPrice .. " PP )\");");
					player.actor:SelectItemByNameRemote("Fists")
					System.RemoveEntity(curr.id);
				else
					SendMsg(ERROR, player, "Cannot Sell Item %s", curr.class);
					ATOMBuying:Message(player, "Item '$7%s$9' Cannot be sold", curr.class);
				end;
			else
				ATOMBuying:Message(player, (curr and "This item cannot be sold" or "No sellable item equipped"));
			end;
		end;
		return true;
	end;
	

	local result=false;
	
	local flags=0;
	local level=0;
	local zones=self.inBuyZone[playerId];
	local teamId=self.game:GetTeam(playerId);

	local vehicleId = player and player.actor:GetLinkedVehicleId();
	if (vehicleId) then
		-- don't do this for spawn trucks, just use the buyzone
		local vehicle=System.GetEntity(vehicleId);
		if (not vehicle.buyFlags or vehicle.buyFlags == 0) then
			zones=self.inServiceZone[playerId];
		end
	end

	for zoneId,b in pairs(zones or {}) do
		if (teamId == self.game:GetTeam(zoneId)) then
			local zone=System.GetEntity(zoneId);
			if (zone and zone.GetPowerLevel) then
				local zonelevel=zone:GetPowerLevel();
				if (zonelevel>level) then
					level=zonelevel;
				end
			end
		end
	end

	local tg = player.inventory:GetItemByClass("TACGun");
	local FGL40Case = def.id == "tacgunprojectile" and tg and (GetEnt(tg).SpecialGun == "fgl40" or GetEnt(tg).SpecialGun == "fgl50" or GetEnt(tg).SpecialGun == "fgl40b");
	--Debug("FGL40Case",FGL40Case)
	if (def.level and def.level>0 and def.level>level and not FGL40Case) then
		self.game:SendTextMessage(TextMessageError, "@mp_AlienEnergyRequired", TextMessageToClient, playerId, def.name);
		return false;
	end
	---------------------------------------
	
	local ammo=self.buyList[name];
	if (ammo and ammo.ammo) then
		local price=self:GetPrice(name);

		local vehicle = vehicleId and System.GetEntity(vehicleId);
		-- ignore vehicles with buyzones here (we want to buy ammo for the player not the vehicle in this case)
		if (vehicleId and vehicle and not vehicle.buyFlags and not vehicle.NoBuyAmmo) then
			if (alive) then
				 --is in vehiclebuyzone 
				if (self:IsInServiceZone(playerId) and (price==0 or self:EnoughPP(playerId, nil, price)) and self:VehicleCanUseAmmo(vehicle, name)) then
					local c=vehicle.inventory:GetAmmoCount(name) or 0;
					local m=vehicle.inventory:GetAmmoCapacity(name) or 0;
	
					if (c<m or m==0) then
						local need=ammo.amount;
						if (m>0) then
							need=math.min(m-c, ammo.amount);
						end
	
						-- this function takes care of synchronizing it to clients
						vehicle.vehicle:SetAmmoCount(name, c+need);
					
						if (price>0) then
							if (need<ammo.amount) then
								price=math.ceil((need*price)/ammo.amount);
							end
							if (FGL40Case) then price=100 end
							self:AwardPPCount(playerId, -price);
						end

						return true;
					end
				end
			end
		elseif ((self:IsInBuyZone(playerId) or (not alive)) and (price==0 or self:EnoughPP(playerId, nil, price))) then
			local c=player.inventory:GetAmmoCount(name) or 0;
			local m=player.inventory:GetAmmoCapacity(name) or 0;

			if (not alive) then
				c=revive.ammo[name] or 0;
			end

			if (c<m or m==0) then
				local need=ammo.amount;
				if (m>0) then
					need=math.min(m-c, ammo.amount);
				end

				if (alive) then
					-- this function takes care of synchronizing it to clients
					player.actor:SetInventoryAmmo(name, c+need);
				else
					revive.ammo[name]=c+need;
				end

				if (price>0) then
					if (need<ammo.amount) then
						price=math.ceil((need*price)/ammo.amount);
					end

					if (alive) then
						if (FGL40Case) then price=100 end
						--self:AwardPPCount(playerId, -price);
						self:AwardPPCount(playerId, -price, nil, true);
						ExecuteOnPlayer(player, "HUD.BattleLogEvent(eBLE_Currency, \"" .. ammo.name .. " Bought ( -" .. price .. " PP )\");");
					else
						revive.ammo_price=revive.ammo_price+price;
					end
				end
			
				return true;
			end
		end
	end
	
	return false;
end);

ATOMGameRules:Add("OnPlayReadabilitySound", function(entity, sound)
	
	Debug(sound)
	
	ExecuteOnAll([[ATOMClient:HandleEvent(eCE_ATOMTaunt, "]] .. entity:GetName() .. [[", "]] .. sound .. [[");]])
end);

ATOMGameRules:Add("ResetBoughtItems", function(self, player)

	player.GlassGrenades = false
	player.__BOUGHT = {}
	
	if (player.ATOMPackBought and not ATOMPACK_PARTY and player.hasJetPack) then
		Script.SetTimer(1, function()
			ATOMPack:Remove(player)
		end)
	end
	
	if (player.AmmoBag) then
		System.RemoveEntity(player.AmmoBag)
		player.AmmoBag = nil
		player.aCustomCapacity = nil
		ATOM:ChangeCapacity(player)
	end
	
	if (player.helmetID) then
		System.RemoveEntity(player.helmetID)
		player.helmetID = nil
	end
	
	player.HasDoubleGrenadeAttachment = false
	player.HelmetShots = 0
	player.LastLoot = {}
end);

ATOMGameRules:Add('EnoughPP', function(self, playerId, itemName, price)
	if (itemName and not price) then
		price = self:GetPrice(itemName);
	end
	
	if (not price) then
		price = 0;
	end
	
	local missing = 0;
	local cpp = self:GetPlayerPP(playerId);
	
	local player=System.GetEntity(playerId);
	if (player) then
		local alive = player.actor:GetHealth()>0;
		if (alive) then
			if (price and (price>cpp)) then
				return false, (price or 0) - cpp;
			end
			return true;
		else
			local revive=self.reviveQueue[playerId];
			local total=price;
			if (revive) then
				total=total+(revive.items_price or 0)+(revive.ammo_price or 0);
			end
			if (total>cpp) then
				return false, total - cpp;
			end
			return true;
		end
	end
	return false, 0;
end);


ATOMGameRules:Add("DoBuyAmmo_X", function(self, playerId, name)
--Log("PowerStruggle.Server:SvBuyAmmo(%s, %s)", EntityName(playerId), tostring(name));
	
	local player=System.GetEntity(playerId);
	if (not player) then
		return false;
	end
	
	local def=self:GetItemDef(name);

	if (not def) then
		ATOMBuying:InvalidItem(player, "Ammo", tostring(name));
		return false;
	end
	
	local revive;
	local alive=true;
	if (player.actor:GetHealth()<=0) then
		revive=self.reviveQueue[playerId];
		alive=false;
	end

	local result=false;
	
	local flags=0;
	local level=0;
	local zones=self.inBuyZone[playerId];
	local teamId=self.game:GetTeam(playerId);

	if (player.actor:GetLinkedVehicleId()) then
		zones=self.inServiceZone[playerId];
	end

	for zoneId,b in pairs(zones) do
		if (teamId == self.game:GetTeam(zoneId)) then
			local zone=System.GetEntity(zoneId);
			if (zone and zone.GetPowerLevel) then
				local zonelevel=zone:GetPowerLevel();
				if (zonelevel>level) then
					level=zonelevel;
				end
			end
		end
	end

	if (def.level and def.level>0 and def.level>level) then
		self.game:SendTextMessage(TextMessageError, "@mp_AlienEnergyRequired", TextMessageToClient, playerId, def.name);
		return false;
	end
	
	local ammo=self.buyList[name];
	if (ammo and ammo.ammo) then
		--player:SetPrestige(1)
		local price=self:GetPrice(name);
		
		local buyOk, missing = self:EnoughPP(playerId, nil, price);
		if (not buyOk) then
		--	local w=player:GetCurrentItem();
		--	Debug("MONI MONI :D")
		--	ATOMBuying:OnNotEnoughPP(player, nil, price, missing, w.class);
		end;
		local vehicleId = player and player.actor:GetLinkedVehicleId();
		if (vehicleId) then
			if (alive) then
				local vehicle=System.GetEntity(vehicleId);
				 --is in vehiclebuyzone 
				if (self:IsInServiceZone(playerId) and (price==0 or buyOk) and self:VehicleCanUseAmmo(vehicle, name)) then
					local c=vehicle.inventory:GetAmmoCount(name) or 0;
					local m=vehicle.inventory:GetAmmoCapacity(name) or 0;
	
					if (c<m or m==0) then
						local need=ammo.amount;
						if (m>0) then
							need=math.min(m-c, ammo.amount);
						end
	
						-- this function takes care of synchronizing it to clients
						vehicle.vehicle:SetAmmoCount(name, c+need);
					
						if (price>0) then
							if (need<ammo.amount) then
								price=math.ceil((need*price)/ammo.amount);
							end
							self:AwardPPCount(playerId, -price);
						end

						return true;
					end
				end
			end
		elseif ((self:IsInBuyZone(playerId) or (not alive)) and (price==0 or buyOk)) then
			local c=player.inventory:GetAmmoCount(name) or 0;
			local m=player.inventory:GetAmmoCapacity(name) or 0;

			if (not alive) then
				c=revive.ammo[name] or 0;
			end

			if (c<m or m==0) then
				local need=ammo.amount;
				if (m>0) then
					need=math.min(m-c, ammo.amount);
				end

				if (alive) then
					-- this function takes care of synchronizing it to clients
					player.actor:SetInventoryAmmo(name, c+need);
				else
					revive.ammo[name]=c+need;
				end

				if (price>0) then
					if (need<ammo.amount) then
						price=math.ceil((need*price)/ammo.amount);
					end

					if (alive) then
						self:AwardPPCount(playerId, -price);
					else
						revive.ammo_price=revive.ammo_price+price;
					end
				end
			
				return true;
			end
		end
	end
	
	return false;
end)

ATOMGameRules:Add('SvBuyAmmo', function(self, playerId, name)
	--Log("PowerStruggle.Server:SvBuyAmmo(%s, %s)", EntityName(playerId), tostring(name));
	
	local player=System.GetEntity(playerId);
	if (not player) then
		return;
	end
	
	if (RCA and RCA:CheckRequest(player, name) == true) then
	--	Debug("R3 :D")
		return;
	end;
	
	if (ATOMDefense:CheckBuyFlood(player) == false) then
	--	Debug("R2 :D")
		return;
	end;
	--	Debug("R1 :D")
	
	local frozen = self.game:IsFrozen(playerId);
	local channelId = player.actor:GetChannel();		
	local ok = false;
	
	if (not frozen) then
		ok = self:DoBuyAmmo(playerId, name);
	end

	if (ok) then
		self.onClient:ClBuyOk(channelId, name);
	else
		self.onClient:ClBuyError(channelId, name);
	end
end, "Server");


ATOMGameRules:Add('SvBuy', function(self, playerId, itemName)
	local player=System.GetEntity(playerId);
	if (not player) then
		return;
	end

	local ok=false;
	local channelId=player.actor:GetChannel();
	if (self.game:GetTeam(playerId)~=0) then
		local frozen=self.game:IsFrozen(playerId);
		local alive=player.actor:GetHealth()>0;
		
		if (not frozen and alive) then
			if (self:ItemExists(playerId, itemName)) then
				local item = self.buyList[itemName];
				local buyOk, missing = self:EnoughPP(playerId, itemName);
				--Debug("more:",missing)
				if (self:IsVehicle(itemName)) then
					if (buyOk) then
						ok=self:BuyVehicle(playerId, itemName);
					else -- !!hook
						ATOMBuying:OnNotEnoughPP(player, itemName, item.price, missing);
					end
				elseif (self:IsInBuyZone(playerId)) then
					if (buyOk) then
						ok=self:BuyItem(playerId, itemName);
					else -- !!hook
						ATOMBuying:OnNotEnoughPP(player, itemName, item.price, missing);
					end
				end
			else
				SysLog("%s tired to buy unknonw item %s", player:GetName(),tostring(itemName));
				ATOMBuying:InvalidItem(player, "Item", tostring(itemName));
				-- !!hook - help message for added custom items buyable in console
				--SendMsg(CONSOLE, player, "$8such item doesn't exist");
			end
		end

	end

	if (ok) then
		self.onClient:ClBuyOk(channelId, itemName);
	else
		self.onClient:ClBuyError(channelId, itemName);
	end
end, "Server"); 


ATOMGameRules:Add('OnPurchaseCancelled', function(self, playerId, teamId, itemName)

	local price, energy = self:GetPrice(itemName);
	if (price > 0) then
			
		self:AwardPPCount(playerId, price, nil, true);
		ExecuteOnPlayer(GetEnt(playerId), "HUD.BattleLogEvent(eBLE_Currency, \"Vehicle Refund ( +" .. price .. " PP )\");");
		--self:AwardPPCount(playerId, price);
	end
		
	if (energy and energy > 0) then
		self:SetTeamPower(teamId, self:GetTeamPower(teamId) + energy);
	end

end);
ATOMGameRules:Add('BuyItem', function(self, playerId, itemName)
	
	local price=self:GetPrice(itemName);
	local def=self:GetItemDef(itemName);

	if (not def) then
		return false;
	end

	-- !!hook
	local player = System.GetEntity(playerId);
	if (player) then
		if (ATOMBuying:CanBuyItem(player, itemName) == false) then
			return false;
		end;
	end;

	if (def.buy) then
		local buydef=self:GetItemDef(def.buy);
		if (buydef and (not self:HasItem(playerId, buydef.class))) then
			local result=self:BuyItem(playerId, buydef.id);
			if (not result) then
				return false;
			end
		end
		
	end

	if (def.buyammo and self:HasItem(playerId, def.class)) then
		local ret = self:DoBuyAmmo(playerId, def.buyammo);
		if (def.selectOnBuyAmmo and ret and player) then
			player.actor:SelectItemByNameRemote(def.class);
		end
		return ret;
	end

	if (not player) then
		return false;
	end

	local revive;
	local alive=true;
	if (player.actor:GetHealth()<=0) then
		revive=self.reviveQueue[playerId];
		alive=false;
	end
	
	local itemProps = self.buyList[itemName].ItemProperties;
	local playerProps = self.buyList[itemName].PlayerProperties;

	local uniqueOld=nil;
	if (def.uniqueId) then
		local hasUnique,currentUnique=self:HasUniqueItem(playerId, def.uniqueId);
		if (hasUnique) then
			if (alive and not player.megaGod and (not itemProps or itemProps.Unlimited~=true)) then
				if (def.category == "@mp_catEquipment") then
					local kitCount = (player:HasItem("RadarKit")and 1 or 0) + (player:HasItem("RepairKit")and 1 or 0) + (player:HasItem("LockpickKit")and 1 or 0);
					local kitLimit = ATOMBuying.cfg.Buying.KitLimit or 1;
					if (not kitLimit or kitCount >= kitLimit) then
						ATOMBuying:Message(player, "Cannot carry more Kits");
						self.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMoreKit", TextMessageToClient, playerId);
					end;
				else
					if (def.class) then
						player.actor:SelectItemByNameRemote(def.class);
						ATOMBuying:Message(player, "You already bought $7%s", def.class);
					end;
					self.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMore", TextMessageToClient, playerId);
				end
				return false;
			end
			uniqueOld=currentUnique;
		end
	end

	--				Debug("NO :D")
	local flags=0;
	local level=0;
	local zones=self.inBuyZone[playerId];
	local teamId=self.game:GetTeam(playerId);
	local factory

	for zoneId,b in pairs(zones) do
		if (teamId == self.game:GetTeam(zoneId)) then
			local zone=System.GetEntity(zoneId);
			if (zone and zone.GetPowerLevel) then
				local zonelevel=zone:GetPowerLevel();
				if (zonelevel>level) then
					level=zonelevel;
				end
			end
			if (zone and zone.GetBuyFlags) then
				flags=bor(flags, zone:GetBuyFlags());
			end
			factory = zone
		end
	end

	-- dead players can't buy anything else
	if (not alive) then
		flags=bor(bor(self.BUY_WEAPON, self.BUY_AMMO), self.BUY_EQUIPMENT);
	end

	if (def.level and def.level>0 and def.level>level and not player.megaGod) then
	--	Debug("EN")
		self.game:SendTextMessage(TextMessageError, "@mp_AlienEnergyRequired", TextMessageToClient, playerId, def.name);
		ATOMBuying:Need_Energy(player, def.class, def.level);
		return false;
	end

	local itemflags=self:GetItemFlag(itemName);
	if (band(itemflags, flags)==0) then
		return false;
	end

	local limitOk,teamCheck=self:CheckBuyLimit(itemName, self.game:GetTeam(playerId));
	if (not limitOk and not player.megaGod) then
		if (teamCheck) then
			ATOMBuying:Item_Limit(player, def.class, "Team");	
			self.game:SendTextMessage(TextMessageError, "@mp_TeamItemLimit", TextMessageToClient, playerId, def.name);
		else
			ATOMBuying:Item_Limit(player, def.class, "Global");
			self.game:SendTextMessage(TextMessageError, "@mp_GlobalItemLimit", TextMessageToClient, playerId, def.name);
		end

		return false;
	end

	-- check inventory
	local itemId;
	local ok;

	if (alive) then
		if (not itemProps or itemProps.Unlimited~=true) then
			ok=player.actor:CheckInventoryRestrictions(def.class);
		else
			ok=true
		end;
	else
		if (revive.items and table.getn(revive.items)>0) then
			local inventory={};
			for i,v in ipairs(revive.items) do
				local item=self:GetItemDef(v);
				if (item) then
					table.insert(inventory, item.class);
				end
			end
			ok=player.actor:CheckVirtualInventoryRestrictions(inventory, def.class);
		else
			ok=true;
		end
	end

	if (ok or player.megaGod) then
		if ((not alive) and (uniqueOld)) then
			for i,old in pairs(revive.items) do
				if (old == uniqueOld) then
					revive.items_price=revive.items_price-self:GetPrice(old);
					table.remove(revive.items, i);
					break;
				end
			end
		end

		local price,energy=self:GetPrice(def.id);
		if (alive) then
		
			player.BuyCooldown = player.BuyCooldown or {};
			if (itemProps and itemProps.BuyCooldown) then
				if (player.BuyCooldown[def.id] and _time - player.BuyCooldown[def.id] < itemProps.BuyCooldown) then
					SendMsg(ERROR, player, "Please wait %s before buying that item again", calcTime(itemProps.BuyCooldown - (_time - player.BuyCooldown[def.id]), true, 1, 1));
					ATOMBuying:Message(player, "Please wait $4%s$9 Before Buying This Item Again", calcTime(itemProps.BuyCooldown - (_time - player.BuyCooldown[def.id]), true, 1, 1));
					return 
				end;
			end;
			player.BuyCooldown[def.id] = _time;
			if (itemProps and itemProps.CallBefore) then
				local ax,bx=pcall(itemProps.CallBefore, player);
				if (not ax) then
					ATOMLog:LogError(bx);
				end;
			end;
			
			local item
			if (not itemProps or not itemProps.DontGive) then
				itemId = ItemSystem.GiveItem(def.class, playerId);
				item=System.GetEntity(itemId);
			else
			--	Debug("PROPS SAY NO GIVE!!");
			end;
			
			if self.buyList[itemName] then
				if self.buyList[itemName].tag then
					item[self.buyList[itemName].tag] = true
					item.tagBought = true
				end
			end

			-- !!hook ATOMBuying.lua
			ATOMBuying:OnItemBought(player, item, self.buyList[itemName]);
			if (item and not item.weapon) then
				local idCurrent = player:GetCurrentItem()
				if (idCurrent and idCurrent.weapon) then
					ATOMEquip:CheckItem(player, idCurrent, nil, true, true);
				end
			end
			if (itemProps) then
				if (itemProps.Tags) then
					if (item) then
						for tag, val in pairs(itemProps.Tags) do
							item[tag] = val;
							--SysLog("copy key %s = %s", tag,val)
						end;
					end;
				end;
				if (itemProps.Unique) then
					player.__BOUGHT = player.__BOUGHT or {};
					local uname=itemProps.UniqueMsg;
					if (player.__BOUGHT[itemProps.Unique]) then
						return false, ATOMBuying:OwnsItem(player, "You already Bought $7" ..( uname or "the $7" .. self.buyList[itemName].name)), SendMsg(ERROR, player, "You already Bought %s", uname or "the " .. self.buyList[itemName].name);
					end;
					player.__BOUGHT[itemProps.Unique] = true;
				end;
				Debug("props found")
				if (itemProps.Call) then
					Debug("call found")
					local a,b=pcall(itemProps.Call, item, player);
					if (not a) then
						ATOMLog:LogError(b);
					else
						Debug("call OK")
					end;
				end;
			end;
			if (playerProps) then
				if (playerProps.Tags) then
					for tag, val in pairs(playerProps.Tags) do
						player[tag] = val;
						--SysLog("copy key %s = %s", tag,val)
					end;
				end;
				if (playerProps.Call) then
					local a,b=pcall(playerProps.Call, player, item);
					if (not a) then
						ATOMLog:LogError(b);
					end;
				end;
			end;
			if (not player.megaGod) then
				self:AwardPPCount(playerId, -price, nil, true);
				--Debug(def.name)
				ExecuteOnPlayer(player, "HUD.BattleLogEvent(eBLE_Currency, \"Item " .. def.name .. " Bought ( -" .. price .. " PP )\");");
				local award = math.floor(price/10)
				if (award >= 1) then
					for i, v in pairs(factory.capturedBy or{}) do
						if (GetEnt(v.id) and GetEnt(v.id).isPlayer and v.id ~= player.id) then--) then-- 
							ExecuteOnPlayer(v, "HUD.BattleLogEvent(eBLE_Currency, \"" .. GetBuildingName(factory) .. " Sales Share ( +" .. award .. " PP )\");");
						end
					end
				end
			end;
			if (energy and energy>0) then
				local teamId=self.game:GetTeam(playerId);
				self:SetTeamPower(teamId, self:GetTeamPower(teamId)-energy);
			end
			
			if (item) then
				item.builtas=def.id;
			end
		elseif ((not energy) or (energy==0)) then
			table.insert(revive.items, def.id);
			revive.items_price=revive.items_price+price;
		else
			return false;
		end
	else
		if (self.buyList[itemName].class) then
			ATOMBuying:Message(player, "Cannot carry more Weapons of Type $7%s$9", makeCapital(g_dll:GetItemCategory(self.buyList[itemName].class)));
		else
			ATOMBuying:Message(player, "Cannot carry more Items", g_dll:GetItemCategory(self.buyList[itemName].class));
		end;
		self.game:SendTextMessage(TextMessageError, "@mp_CannotCarryMore", TextMessageToClient, playerId);
		return false;
	end

	if (itemId) then
		self.Server.OnItemBought(self, itemId, itemName, playerId);
	end

	return true;
	
end);

ATOMGameRules:Add("GetProductionFactory", function(self, playerId, itemName, insideOnly)
	
	local player = System.GetEntity(playerId);
	
	if (not self.factories) then
		return;
	end
		
	local def=self:GetItemDef(itemName);
	if ((not def) or (not def.vehicle)) then
		SendMsg(CONSOLE_ATOM, player, "Vehicle '$4%s$9' does not exist", itemName);
	--	SendMsg(CHAT_ATOM, player, "$8such vehicle doesn't exist");
		return;
	end
	
	if (def.special) then
		if (not CryAction.IsChannelSpecial(playerId)) then
			return;
		end
	end
	
	local insideFactory = nil;
	
	for i,factory in pairs(self.factories) do
		if (not insideOnly or self:IsInBuyZone(playerId, factory.id)) then
			if (not insideFactory) then
				insideFactory = factory;
			else
				ATOMLog:LogError("WTF, player "..player:GetName().." is inside more factories at the same time");
			end;
			break;
		end;
	end
			
	if (insideFactory) then
		local playerTId = self.game:GetTeam(playerId);
		local factoryTId = self.game:GetTeam(insideFactory.id);
		if (factoryTId == playerTId) then
			if (insideFactory:CanBuild(itemName)) then
				if ((not def.level or def.level <= insideFactory:GetPowerLevel())) then
					return insideFactory;
				elseif (def.level) then
					SendMsg(CHAT_ATOM, player, "$8not enough alien energy (requires " .. def.level .. ")");
				end;
			else
				SendMsg(CHAT_ATOM, player, "$8this vehicle cannot be bought in this factory");
			end;
		else
			SendMsg(CHAT_ATOM, player, "$8this is not your factory");
		end;
	else
		SendMsg(CHAT_ATOM, player, "$8you are not inside any factory");
	end;
	
end)


ATOMGameRules:Add("BuyVehicle", function(self, playerId, itemName)
	local factory=self:GetProductionFactory(playerId, itemName, true);
	if (factory) then
	--Debug("Buying?")

		-- !!hook
		local player = System.GetEntity(playerId);
		if (player) then
			if (ATOMBuying:CanBuyVehicle(player, itemName) == false) then
				return false;
			end;
		else
			return;
		end;

		local limitOk, teamCheck=self:CheckBuyLimit(itemName, self.game:GetTeam(playerId));
		if (not limitOk and not player.megaGod) then
			if (teamCheck) then
				self.game:SendTextMessage(TextMessageError, "@mp_TeamItemLimit", TextMessageToClient, playerId, self:GetItemName(itemName));
			else
				self.game:SendTextMessage(TextMessageError, "@mp_GlobalItemLimit", TextMessageToClient, playerId, self:GetItemName(itemName));
			end

			return false;
		end

		--if (player.VehicleJobs >= 2) then
			for i,factory in pairs(self.factories) do
				factory:CancelJobForPlayer(playerId);
			end
		--end;
		
		local theitem = self.buyList[itemName];
		local props = theitem.VehicleProperties;

		local price,energy=self:GetPrice(itemName);
		if (factory:Buy(playerId, itemName, props)) then
			--findmelol
			
			self:AwardPPCount(playerId, -price, nil, true);
			ExecuteOnPlayer(player, "HUD.BattleLogEvent(eBLE_Currency, \"Vehicle " .. theitem.name .. " Bought ( -" .. price .. " PP )\");");
			--self:AwardPPCount(playerId, -price);
			self:AwardCPCount(playerId, self.cpList.BUYVEHICLE);

			if (energy and energy>0) then
				local teamId=self.game:GetTeam(playerId);
				if (teamId and teamId~=0) then
					self:SetTeamPower(teamId, self:GetTeamPower(teamId)-energy);
				end
			end

			self:AbandonPlayerVehicle(playerId);

			return true;
		end
	end

	-- !!hook!!
	--SendMessage(CONSOLE, System.GetEntity(playerId), "$8"..tostring(itemName).." cannot be bought in this factory");
	return false;
end);


ATOMGameRules:Add("OnEnterBuyZone", function(self, zone, player)
	--Debug("enter")
	if (zone.vehicle and (zone.vehicle:IsDestroyed() or zone.vehicle:IsSubmerged())) then
		return;
	end
	--Debug("enter ok")

	if (not self.inBuyZone[player.id]) then
		self.inBuyZone[player.id]={};
	end

	local was=self.inBuyZone[player.id][zone.id];
	if (not was) then
		Debug("zone=",zone.id)
		self.inBuyZone[player.id][zone.id]=true;
		if (self.game:IsPlayerInGame(player.id)) then
			self.onClient:ClEnterBuyZone(player.actor:GetChannel(), zone.id, true);
			-- !!hook
			ATOMBuying:OnEnterBuyZone(player, zone);
			--Debug("RMI !!")
		end
		--Debug("zone.Properties.szName",zone.Properties.szName)
		--Debug("zone.Properties.bCapturable",zone.Properties.bCapturable)
		if (zone.Properties.szName == "air" and zone.Properties.bCapturable ~= 1) then
		--	Debug("AIR FAC===")
		end
	end

	self.buyList[van][jeep]=true; -- ;<
end);


------------------------------------------------------------------------------------------------------

ATOMGameRules:Add("OnLeaveBuyZone", function(self, zone, player)
	if (self.inBuyZone[player.id] and self.inBuyZone[player.id][zone.id]) then
		self.inBuyZone[player.id][zone.id]=nil;
		if (self.game:IsPlayerInGame(player.id)) then
			self.onClient:ClEnterBuyZone(player.actor:GetChannel(), zone.id, false);
			-- !!hook
			ATOMBuying:OnLeaveBuyZone(player, zone);
		end
	end
end);



------------------------------------------------------------------------------------------------------


function g_gameRules:CanEnterVehicle(vehicle, userId)

	if (vehicle.CannotBeEntered) then
		return false
	end

	local player = System.GetEntity(userId);
	if (not player or GetDistance(player, vehicle) > 25) then
		return false;
	end;

	-- !!hook
	local canEnter = ATOMVehicles:CanEnterVehicle(player, vehicle);
	if (canEnter == false) then
	--	Debug("LOL!")
		return canEnter;
	else
		local cfg = ATOM.cfg.GamePlayConfig;
		if (cfg and cfg.PilotHelmets) then
			--Debug("Helmet");
			if (not player.helmetID and not player.__BOUGHT["HELMET"]) then
				--Debug("Change Fligt helmet uwu")
			end;
		end;
		--Debug("LOL")
	end;

	--if (g_gameRules.class == "InstantAction") then
	--	return true;
	--end;

	if (false ) then--not player.enterAnim) then
		if (not player.ENTERING) then
			ExecuteOnAll([[local p=GP(]]..player:GetChannel()..[[)p:StartAnimation(0,"usLTV_passenger01Enter_01");]])
			Script.SetTimer(3000,function()
				vehicle.vehicle:EnterVehicle(player.id, 1,false)
				player.ENTERING=false
			end);
		end;
		player.ENTERING=true
		Debug("no.")
		return false;
	end;
	--player.enterAnim=false

	if (vehicle.vehicle:GetOwnerId()==userId) then
		return true;
	end

	local vteamId=self.game:GetTeam(vehicle.id);
	local pteamId=self.game:GetTeam(userId);

	local ok;

	if (pteamId==vteamId or vteamId==0 or player.megaGod) then
		ok = true; --vehicle.vehicle:GetOwnerId()==nil;   -- allows everyone to enter, but OnEnterSeat allows only owner to drive
	else
		ok = false;
	end
	if (ok) then
		player.LastInteractiveActivity = _time;
		vehicle.ReportOnCollision = true;
		vehicle.DriverEnterTime = _time;
		self.CollisionVehicles[vehicle.id] = player.id;
	end;
	return ok;
end


------------------------------------------------------------------------------------------------------

function g_gameRules:OnEnterVehicleSeat(vehicle, seat, entityId)
	if (self.isServer) then
		local player=System.GetEntity(entityId);

		
		self.game:SetTeam(self.game:GetTeam(entityId), vehicle.id);

		if (player) then
			self:AbandonPlayerVehicle(player.id, vehicle.id);
		end

		if (entityId==vehicle.vehicle:GetOwnerId()) then
			vehicle.vehicle:SetOwnerId(NULL_ENTITY);

			-- !!hook
			ATOMVehicles:OnOwnerFirstEnter(vehicle, player);

			-- this is the owner entering the vehicle
			if (vehicle.vehicle:GetMovementType()=="air") then
				local player=System.GetEntity(entityId);
				if (player) then
					if (player.inventory:GetCountOfClass("Parachute")==0) then
						ItemSystem.GiveItem("Parachute", entityId, false);
					end
				end
			end
		end

		vehicle.vehicle:KillAbandonTimer();

		if (self.unclaimedVehicle[vehicle.id]) then
			self.unclaimedVehicle[vehicle.id] = nil;
		end
	end
end


----------------------------------------------------------------------------------------------------

function g_gameRules:OnLeaveVehicleSeat(vehicle, seat, entityId, exiting)
	local player=System.GetEntity(entityId);
	if (self.isServer) then
		if (exiting) then
			
			if (not player) then
				return;
			end;
			SysLog("entityId %s exiting vehicle %s", tostr(player:GetName()), vehicle:GetName());
		--	Debug("leave, not change.")
			-- !!hook
		
			local empty=true;
			for i,seat in pairs(vehicle.Seats) do
				local passengerId = seat:GetPassengerId();
				if (passengerId and passengerId~=NULL_ENTITY and passengerId~=entityId) then
					empty=false;
					break;
				end
			end

			if (empty) then
				--self.game:SetTeam(0, vehicle.id);
				vehicle.lastOwnerId=entityId;
				local player=System.GetEntity(entityId);
				if (player) then
					player.lastVehicleId=vehicle.id;
				end
				--vehicle.ReportOnCollision = false;
			end
			if (player and empty) then
				player.lastSeatId = seat.seatId;
				if (ATOMVehicles:OnLeaveVehicle(player, vehicle, seat) == false) then
				--	Debug(seat.seatId)
					Script.SetTimer(0, function()
						vehicle.vehicle:EnterVehicle(player.id, seat.seatId, false);
					end)
					SysLog("%s can't leave vehicle %s", GetEnt(entityId):GetName(), vehicle:GetName());
					return;
				end;
			end;

			if (entityId==vehicle.vehicle:GetOwnerId()) then
				vehicle.vehicle:SetOwnerId(NULL_ENTITY);
			end
			
		else
			SysLog("entityId %s leaving vehicle seat %d of %s", tostr(player:GetName()), seat.seatId, vehicle:GetName());
		--	Debug("change, not leave.")
		-- !!hook    let mod decide if this seat change is ok
			if (ATOMVehicles:OnSeatChange(GetEnt(entityId), vehicle, seat) == false) then
			--	Debug("fuk no u, u can' not leave seat ",seat.seatId)
				Script.SetTimer(0, function()
					vehicle.vehicle:OnUsed(entityId, 1100+seat.seatId);-- + );
				end);
				SysLog("%s can't leave seat %d of vehicle %s", GetEnt(entityId):GetName(), seat.seatId, vehicle:GetName());
				return;
			end;
		end;
	end
end

g_gameRules.AutodestructingVehicles = g_gameRules.AutodestructingVehicles or {};
g_gameRules.CollisionVehicles = g_gameRules.CollisionVehicles or {};
g_gameRules.placed_avmines = g_gameRules.placed_avmines or {};

----------------------------------------------------------------------------------------------------
function g_gameRules:PostUpdate(frameTime)
	
	--------
	self:UpdateUnclaimedVehicles(frameTime)
	self:UpdateAbandoningVehicles(frameTime)
	self:UpdateCollisionVehicles(frameTime)
	
	--------
	if (_time - (self.last_avmine_tick or 0) > 0.25) then
		self.last_avmine_tick = _time;
		for i, v in pairs(self.placed_avmines) do
			local aClose = GetPlayers()
			local bClose = false
			for ii, vv in pairs(aClose or {}) do
				if (g_game:GetTeam(vv.id) ~= g_game:GetTeam(v.id)) then
					if (GetDistance(v:GetPos(), vv:GetPos()) < 0.2) then
						bClose = true
					end
				end
			end
			if (bClose) then
				g_game:ExplodeProjectile(v.id, true, false)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------

function g_gameRules:UpdateCollisionVehicles(frameTime)
	for id, v in pairs(self.CollisionVehicles or{}) do
		local vehicle = GetEnt(id);
		if (not vehicle or not vehicle.vehicle or vehicle.vehicle:IsDestroyed() or (_time - vehicle.DriverEnterTime >= 10)) then
			self.CollisionVehicles[id] = nil;
			if (vehicle) then
				--Debug("unregistered vehicle!");
				vehicle.ReportOnCollision = false;
			end;
		end;
	end
end

------------------------------------------------------------------------------------------------------

function g_gameRules:UpdateAbandoningVehicles(frameTime)
	for id, v in pairs(self.AutodestructingVehicles or{}) do
		if (not GetEnt(id) or v.vehicle:IsDestroyed()) then
			self.AutodestructingVehicles[id] = nil;
		elseif (not v.abandonStopped and _time - v.abandonTimer >= 10) then
			self.AutodestructingVehicles[id] = nil;
			--Debug("removed")
		elseif (#DoGetPlayers({range = 5, pos = v:GetPos()})>0) then
			if (not v.abandonStopped) then
			--	Debug("STOPPED DESTRUCTION!!");
				v.vehicle:KillAbandonTimer();
				v.abandonStopped = true;
			end;
		elseif (v.abandonStopped) then
			--Debug("restore abandoning!");
			v.abandonStopped = false;
			if (not v.lastOwnerId) then
				v.vehicle:StartAbandonTimer(true, 6);
				v.abandonTimer = _time-6;
			else
				v.abandonTimer = _time - 10.1;
			end;
		end;
	end
end

------------------------------------------------------------------------------------------------------

function g_gameRules:UpdateUnclaimedVehicles(frameTime)

	local idOwner
	for id,v in pairs(self.unclaimedVehicle or{}) do
		v.time = v.time - frameTime;
		
		idOwner = v.ownerId and GetEnt(v.ownerId) or nil
		if (v.time <= 0) then
			if (g_gameRules.class == "PowerStruggle" and GetEnt(v.ownerId) and GetEnt(v.ownerId).actor) then --PS
				-- inform the player
				self.game:SendTextMessage(TextMessageInfo, "@mp_UnclaimedVehicle", TextMessageToClient, v.ownerId, g_gameRules:GetItemName(v.name));
				-- refund
				--Debug("refund :D")
				--Debug(GetEnt(v.ownerId):GetName())
				local price=self:GetPrice(v.name);
				if (price and price>0) then
					local amt = math.floor(self.ppList.VEHICLE_REFUND_MULT*price+0.5);
					g_gameRules:AwardPPCount(idOwner, amt, nil, true);
					SendMsg(BLE_CURRENCY, idOwner, "Unclaimed Vehicle Refund ( +%d PP )", amt);
				end
			else --IA
				-- inform the player
				self.game:SendTextMessage(TextMessageInfo, "@mp_UnclaimedVehicle", TextMessageToClient, v.ownerId, v.name);
			end
			System.RemoveEntity(id);

			self.unclaimedVehicle[id]=nil;
		elseif (g_gameRules.class == "PowerStruggle" and idOwner and v.time <= 10) then
			if (not idOwner.lastVehicleTimoutMsg or _time - idOwner.lastVehicleTimoutMsg >= 1) then
				idOwner.lastVehicleTimoutMsg = _time
				SendMsg(CENTER, idOwner, "Your unclaimed vehicle will be removed in %ds", v.time)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------

function g_gameRules:AbandonPlayerVehicle(playerId, currentVehicleId, destroy)
	local player=System.GetEntity(playerId);
	if (not player or player.megaGod) then
		return;
	end

	if (player.lastVehicleId and ((not currentVehicleId) or player.lastVehicleId~=currentVehicleId)) then
		local lastVehicle=System.GetEntity(player.lastVehicleId);
		if (lastVehicle) then
			if (lastVehicle.lastOwnerId and lastVehicle.lastOwnerId==playerId and lastVehicle.vehicle:IsEmpty() and (not self.game:IsSpawnGroup(player.lastVehicleId))) then
				if (destroy) then
					lastVehicle.vehicle:Destroy();
				else
					lastVehicle.abandonTimer = _time;
					self.AutodestructingVehicles[lastVehicle.id] = lastVehicle;
					lastVehicle.vehicle:StartAbandonTimer(true, 10);
					Debug("START TIMER!")
				end
			end
			lastVehicle.lastOwnerId = nil;
		end
		player.lastVehicleId = nil;
	end
end

----------------------------------------------------------------------------------------------------
--  this function is never called for some reason
function g_gameRules:ClaimedVehicle(vehicleId, playerId)
	local vehicle=self.unclaimedVehicle[vehicleId];

	if (vehicle and vehicle.ownerId == playerId) then
		self.unclaimedVehicle[vehicleId]=nil;
	end
end


----------------------------------------------------------------------------------------------------

function g_gameRules:ResetUnclaimedVehicle(playerId, unlock)
	for i,v in pairs(self.unclaimedVehicle) do
		if (v.ownerId==playedId) then
			if (unlock) then
				vehicle.vehicle:SetOwnerId(NULL_ENTITY);
				self.game:SetTeam(v.teamId, v.id);
			end

			self.unclaimedVehicle[i]=nil;
			return;
		end
	end
end

if (g_gameRules.class == "PowerStruggle") then
	g_gameRules.rankList =
	{
		{ name="@ui_short_rank_1", 	desc="@ui_rank_1",	cp=0, 					min_pp=100,		equip={ "SOCOM" 	},},
		{ name="@ui_short_rank_2",	desc="@ui_rank_2",	cp=15, 		limit=99,	min_pp=200,		equip={ "SOCOM" 	},},
		{ name="@ui_short_rank_3", 	desc="@ui_rank_3",	cp=40, 		limit=99,	min_pp=300,		equip={ "SOCOM" 	},},
		{ name="@ui_short_rank_4", 	desc="@ui_rank_4",  cp=120,		limit=99,	min_pp=400,		equip={ "SOCOM" 	},}, 
		{ name="@ui_short_rank_5", 	desc="@ui_rank_5",	cp=220, 	limit=99,	min_pp=500,		equip={ "SOCOM" 	},}, 
		{ name="@ui_short_rank_6", 	desc="@ui_rank_6",	cp=320, 	limit=99,	min_pp=600,		equip={ "SOCOM" 	},}, 
		{ name="@ui_short_rank_7", 	desc="@ui_rank_7",	cp=475,	 	limit=99,	min_pp=750,		equip={ "SOCOM" 	},}, 
		{ name="@ui_short_rank_8", 	desc="@ui_rank_8",	cp=650, 	limit=99, 	min_pp=1000,	equip={ "SOCOM" 	},}, 
		--{ name="GOD", 				desc="You are GodLike",	cp=1500, 	limit=1, 	min_pp=2000,	equip={ "SOCOM" 	},}, 
		--{ name="EGIRL", 				desc="You are an E-Girl",	cp=5000, 	limit=1, 	min_pp=2500,	equip={ "SOCOM" 	},}, 
	};
end;


------------------------------------------------------------------------------------------------------

g_gameRules.unclaimedVehicle = g_gameRules.unclaimedVehicle or {};

------------------------------------------------------------------------------------------------------

function MakeBuyZone(entity, defaultBuyFlags)
	local hasFlag=function(option, flag)
		if (band(option, flag)~=0) then
			return 1;
		else
			return 0;
		end
	end

	if (entity.class) then -- has this entity spawned already?
		local buyFlags=0;
		local options=entity.Properties.buyOptions;
		if (tonumber(options.bVehicles)~=0) then	 	buyFlags=bor(buyFlags, PowerStruggle.BUY_VEHICLE); end;
		if (tonumber(options.bWeapons)~=0) then 		buyFlags=bor(buyFlags, PowerStruggle.BUY_WEAPON); end;
		if (tonumber(options.bEquipment)~=0) then		buyFlags=bor(buyFlags, PowerStruggle.BUY_EQUIPMENT); end;
		if (tonumber(options.bPrototypes)~=0) then 	buyFlags=bor(buyFlags, PowerStruggle.BUY_PROTOTYPE); end;
		if (tonumber(options.bAmmo)~=0) then		 		buyFlags=bor(buyFlags, PowerStruggle.BUY_AMMO); end;
		entity.buyFlags=buyFlags;
	else
		entity.Properties.buyAreaId	= 0;
		entity.Properties.buyOptions={
			bVehicles 	= hasFlag(defaultBuyFlags, PowerStruggle.BUY_VEHICLE),
			bWeapons 		= hasFlag(defaultBuyFlags, PowerStruggle.BUY_WEAPON),
			bEquipment	= hasFlag(defaultBuyFlags, PowerStruggle.BUY_EQUIPMENT),
			bPrototypes	= hasFlag(defaultBuyFlags, PowerStruggle.BUY_PROTOTYPE),
			bAmmo				= hasFlag(defaultBuyFlags, PowerStruggle.BUY_AMMO),
		};
	
		-- OnSpawn
		entity.OnSpawn=replace_post(entity.OnSpawn, function(self)
			SysLog("spawned new buyzone.")
			local buyFlags=0;
			local options=self.Properties.buyOptions;
			if (tonumber(options.bVehicles)~=0) then	 	buyFlags=bor(buyFlags, PowerStruggle.BUY_VEHICLE); end;
			if (tonumber(options.bWeapons)~=0) then 		buyFlags=bor(buyFlags, PowerStruggle.BUY_WEAPON); end;
			if (tonumber(options.bEquipment)~=0) then		buyFlags=bor(buyFlags, PowerStruggle.BUY_EQUIPMENT); end;
			if (tonumber(options.bPrototypes)~=0) then 	buyFlags=bor(buyFlags, PowerStruggle.BUY_PROTOTYPE); end;
			if (tonumber(options.bAmmo)~=0) then		 		buyFlags=bor(buyFlags, PowerStruggle.BUY_AMMO); end;
			self.buyFlags=buyFlags;
		end);
	end
	
	-- GetBuyFlags
	entity.GetBuyFlags=replace_post(entity.GetBuyFlags, function(self)
		return self.buyFlags;
	end);

	if (entity.class) then
		-- OnEnterArea
		entity.OnEnterArea=replace_post(entity.OnEnterArea, function(self, entity, areaId)
			--SysLog("entity.OnEnterArea")
			if (areaId == self.Properties.buyAreaId) then
			--	SysLog("areaId == self.Properties.buyAreaId")
				if (g_gameRules.OnEnterBuyZone) then
			--		SysLog("g_gameRules.OnEnterBuyZone")
					g_gameRules.OnEnterBuyZone(g_gameRules, self, entity);
				end
			end		
		end);
	
		-- OnLeaveArea
		entity.OnLeaveArea=replace_post(entity.OnLeaveArea, function(self, entity, areaId)
			--SysLog("entity.OnLeaveArea")
			if (areaId == self.Properties.buyAreaId) then
			--	SysLog("areaId == self.Properties.buyAreaId")
				if (g_gameRules.OnLeaveBuyZone) then
			--		SysLog("g_gameRules.OnLeaveBuyZone")
					g_gameRules.OnLeaveBuyZone(g_gameRules, self, entity);
				end		
			end
		end);	
	else
		-- OnEnterArea
		entity.Server.OnEnterArea=replace_post(entity.Server.OnEnterArea, function(self, entity, areaId)
			--SysLog("entity.OnEnterArea")
			if (areaId == self.Properties.buyAreaId) then
				if (g_gameRules.OnEnterBuyZone) then
					g_gameRules.OnEnterBuyZone(g_gameRules, self, entity);
				end
			end
		end);
	
		-- OnLeaveArea
		entity.Server.OnLeaveArea=replace_post(entity.Server.OnLeaveArea, function(self, entity, areaId)
			--SysLog("entity.OnLeaveArea")
			if (areaId == self.Properties.buyAreaId) then
				if (g_gameRules.OnLeaveBuyZone) then
					g_gameRules.OnLeaveBuyZone(g_gameRules, self, entity);
				end		
			end
		end);	
	end
end