ATOMAirDrop = {
	cfg = {
		PriceModifier = 1.5,
		ForbiddenItems = {
			["TACGun"] = true, ["TACGun_Fleet"] = true,["AlienMount"] = true, ["MOAR"] = true, ["MOAC"] = true, ["AlienAttach"] = true, ["RefWeapon"] = true, ["MOACAttach"] = true, ["MOARAttach"] = true, ["Fists"] = true, ["DebugGun"] = true, ["Detonator"] = true, ["OffHand"] = true, ["Hurricane"] = true
		},
		RandomAirDrops = true,
		MinimumPlayers = 3, -- Minimum players required for random airdrops
		AllowedGameRules = {
			["PowerStruggle"] = true;
		},
	},
	------------------
	--    Init
	------------------
	Init = function(self)
	--	Debug("Init")
		if (self:SystemUsable()) then
			RegisterEvent("OnSeqTimer", self.SpawnRandom, 'ATOMAirDrop');
		end;
	end,
	------------------
	--    SystemUsable
	------------------
	SystemUsable = function(self)
		return (self.cfg.AllowedGameRules == ALL or self.cfg.AllowedGameRules[g_gameRules.class] == true);
	end,
	------------------
	--    SpawnRandom
	------------------
	SpawnRandom = function(self)
		
	
		local min = self.cfg.MinimumPlayers;
		
		if (g_game:GetPlayerCount() < min or not self:SystemUsable()) then
			return;
		end;
		
		
		if (not timerexpired(self.LAST_SPAWN_TIMER, 60 * 8)) then
			return
		end
		self.LAST_SPAWN_TIMER = timerinit()
		
		local pos = add2Vec(g_utils:GetBuilding("proto"):GetPos(), makeVec(0,0,150));-- or makeVec(2019, 2233, 135);
		local rnd1 = add2Vec(pos, makeVec(math.random(-1000, -500), math.random(-1000, -500), 0));
		local rnd2 = add2Vec(pos, makeVec(math.random(500,  1000), math.random(500,  1000), 0));
		--local air = System.SpawnEntity({ class = "Player", position = rnd });
		self:Spawn(air, air, 1200, self:GetRandom(), rnd1, rnd2);
		--System.RemoveEntity(air.id);
	end,
	------------------
	--    GetRandom
	------------------
	GetRandom = function(self)
		local a, b, c = GetRandom({"FY71", "SCAR", "GaussRifle", "SMG", "LAW"}), GetRandom({"FY71", "SCAR", "GaussRifle", "SMG", "LAW"}), GetRandom({"FY71", "SCAR", "GaussRifle", "SMG", "LAW"});
		local d, e, f = GetRandom(2), GetRandom(2), GetRandom(2);
		
		return { [a] = d, [b] = e, [c] = f };
	end,
	------------------
	--    Spawn
	------------------
	Spawn = function(self, player, target, distance, loot, rnd1, rnd2)
		if (not self:SystemUsable()) then
			return false, "invalid game mode";
		end;
		
		self:SpawnJet(player, target, distance, loot, rnd1, rnd2);
		-- add plane that drops container with equipment and vehicles ...
	end,
	------------------
	--    SpawnJet
	------------------
	SpawnJet = function(self, shooter, target, distance, Loot, p1, p2)
		local distance = distance or 3000;
		local p1 = p1 or target:CalcSpawnPos(-distance, 0);
		local p2 = p2 or target:CalcSpawnPos( distance, 0);
		
		p1.z = System.GetTerrainElevation(target and target:GetPos() or p1)+150;
		p2.z = p1.z;
		
		local g1 = SpawnGUI("objects/vehicles/us_fighter_b/us_fighter.cgf", p1, nil, nil, GetDir(p1, p2)); --(target:GetDirectionVector())
		g1.player = shooter;
		g_utils:AwakeEntity(g1)
		Script.SetTimer(1000, function()
			g_utils:StartMovement({
				name = g1:GetName();
				duration = 20;
				pos = {
					from = p1;
					to = p2;
				};
				handle = "AirDropPlane_" .. g_utils:SpawnCounter();
				OnReached = function(this, pos)
					System.RemoveEntity(this.id);
				end,
				OnHalf = function(this, pos)
					ATOMAirDrop:OnReached(this, this.player, this:GetWorldPos(), Loot);
					if (this.container) then
						if (not this.container.player) then
							SendMsg(CHAT_ATOM, ALL, "(AIRDROP: An AirDrop has Arrived!)");
						end;
					end;
				end,
			});
			ExecuteOnAll([[
				local ent=GetEnt("]]..g1:GetName()..[[");
				if (not ent) then return end
					ATOMClient:StartMovement({name = ent:GetName();duration = 5;pos={from=]]..arr2str_(p1)..[[;to=]]..arr2str_(p2)..[[;};handle="AirDropPlane_"..]]..g_utils:SpawnCounter()..[[;});
					local dir=ent:GetDirectionVector();
					VecRotateMinus90_Z(dir);
					ent.E_SLOT=ent:LoadParticleEffect(-1,"vehicle_fx.vtol.trail",{Scale=4.3,CountScale=3});
					ent:SetSlotWorldTM(ent.E_SLOT,ent:GetPos(),dir);
					ent.soundid=ent:PlaySoundEvent("sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT);
					Script.SetTimer(16000,function()SoundSpot.Stop(ent);ent:FreeSlot(ent.E_SLOT);end);
			]])
		end)
		return g1;
	end;
	------------------
	--    GetGround
	------------------
	GetGround = function(self, pos)
		local G, W = System.GetTerrainElevation(pos), CryAction.GetWaterInfo(pos);
		if (G > W) then
			return toVec(pos.x, pos.y, G);
		else
			return toVec(pos.x, pos.y, W);
		end;
	end,
	------------------
	--    OnReached
	------------------
	OnReached = function(self, drop, player, pos, Loot)
		local container = ATOMItems:AddProjectile(
		mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
			Owner = player,
			--Weapon = weapon,
			Pos = pos,
			Dir = player and player:GetDirectionVector() or drop:GetDirectionVector(),
			--Hit = hit,
			Normal = hitNormal,
			Properties = {
				NoRemoval = true,
				Impulses = {
				--	Amount = -1,
				--	Strength = 3111,
				},
				LifeTime = 100000,
				Model = {
					Particle = {
						Name = "x",
					},
					File = "Objects/library/storage/civil/civil_box_b_mp.cgf", --"Objects/library/storage/crates/container/container_green_open.cgf",
					Sound = "x",
					Mass = 15000,
				},
				Events = {
					Collide = function(p, t, pos, contact, dir)
						ATOMAirDrop:OnCollided(p, t==COLLISION_WATER, contact, dir);
					end,
					OnSpawn = function(p)
						drop.container = p;
						p.IsAirDrop = true;
						p.player = p.owner;
						p.Loot = Loot;
					end,
				},
			};
		}));
		--Debug(container:GetName())
		Script.SetTimer(400, function()
			local code = [[
				local e = GetEnt(']]..container:GetName()..[[')
				if (not e) then return end
				e.Para = e:LoadCharacter(100, "objects/vehicles/parachute/parachute_wind.chr");
				e.Properties.bUsable = 0;
				function e:IsUsable()
					return 1;
				end
				function e:GetUsableMessage()
					return "Press [ F ] to open the Container";
				end
				function e:OnUsed(user, idx)
					ATOMClient:ToServer(eTS_Spectator, eCR_UseObject1);
				end
				e:SetViewDistRatio(1000)
			]]
			ExecuteOnAll(code);
			if (container.syncID) then
				RCA:StopSync(container, container.syncID);
			end;
			container.syncID = RCA:SetSync(container, { client = code, link = container.id });
		end);
	end,
	------------------
	--    OnCollided
	------------------
	OnCollided = function(self, container, onWater, pos)
	
		Script.SetTimer(60000, function()
			System.RemoveEntity(container.id);
		end)
	
		local sCode = [[
			local e = GetEnt(']]..container:GetName()..[[')
			e:FreeSlot(100);
		]]
		ExecuteOnAll(sCode);
		if (container.syncIDDeletePara) then
			RCA:StopSync(container, container.syncIDDeletePara);
		end;
		container.syncIDDeletePara = RCA:SetSync(container, { client = sCode, link = container.id });
		
		
		g_utils:SpawnEffect(ePE_Flare, pos);
		if (container.player) then
			SendMsg(CHAT_ATOM, container.player, "(AIRDROP: Your Airdrop has Arrived, Press F to open it!)");
		else
			if (arrSize(GetPlayersInRange(pos, 50)) < 1) then
				--Debug("Can smoke signal")
				local signal_smoke = System.SpawnEntity({ class = "OffHand", position = pos, name = "Singal_Effect_" .. g_utils:SpawnCounter(), orientation = g_Vectors.up });
				Script.SetTimer(300, function()
					ExecuteOnAll(formatString([[
						local s_f=GetEnt("%s")
						if (s_f) then
							s_f.SIGNAL=s_f:LoadParticleEffect(-1, "explosions.Smoke_grenade.AI_signal", {PulsePeriod = 3, SpeedScale=2,CountScale=2,Scale=2});
							Script.SetTimer(18000, function()
								s_f:FreeSlot(s_f.SIGNAL);
							end);
						end
					]], signal_smoke:GetName()));
				end);
				Script.SetTimer(20000, function()
					System.RemoveEntity(signal_smoke.id);
				end);
			end;
			SendMsg(CHAT_ATOM, ALL, "(AIRDROP: The AirDrop has REACHED the Ground!!)");
			for i = 1, 2 do
				Script.SetTimer(1000, function()
					g_utils:SpawnEffect(ePE_FlareNight, pos);
				end);
			end;
		end;
	end,
	------------------
	--    OnUsed
	------------------
	OnUsed = function(self, player, container)
		local pos = container:GetPos();
		local loot = container.Loot;
		g_utils:SpawnEffect("explosions.house_destroy.small", add2Vec(pos, makeVec(0,0,0.5)));
		g_utils:SpawnEffect(ePE_Light, add2Vec(pos, makeVec(0,0,0.5)));
		System.RemoveEntity(container.id);
		local X;
		for i, v in pairs(loot) do
			if (type(v) == "number") then
				for ii = 1, v do
					X = System.SpawnEntity({ class = i, orientation = makeVec(0,0,0), position = add2Vec(pos, makeVec(math.random(-5,5)/10,math.random(-5,5)/10,math.random(-5,5)/40)), name = i .. ii .. "_gun", properties = { fMass = 1, bPhysics = 1 } })
					g_utils:AwakeEntity(X)
				end;
			else
				X = System.SpawnEntity({ class = v, orientation = makeVec(0,0,0), position = add2Vec(pos, makeVec(math.random(-5,5)/10,math.random(-5,5)/10,math.random(-5,5)/40)), name = v .. "_gun", properties = { fMass = 1, bPhysics = 1 } })
				g_utils:AwakeEntity(X)
			end;
		end;
	end,

};

ATOMAirDrop:Init();