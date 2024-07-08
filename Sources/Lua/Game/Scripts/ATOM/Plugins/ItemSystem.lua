ATOMItems = {
	cfg = {
		UpdateRate = 0.01,
	},
	active = {},
	--------------
	Init = function(self)
	
		COLLISION_WATER 	= 1;
		COLLISION_GROUND 	= 2;
		COLLISION_RAY 		= 3;
		COLLISION_TIMEOUT 	= 4;
		COLLISION_HIT 		= 5;
	
		RegisterEvent("OnUpdate", self.Update, 'ATOMItems');
		RegisterEvent("OnItemHit", self.OnHit, 'ATOMItems');
		RegisterEvent("OnCollision", self.OnCollision, 'ATOMItems');
	end,
	--------------
	AddProjectile = function(self, properties)
			
		local pos = properties.Pos;
		local dir = properties.Dir;
		
		local owner = properties.Owner;
		
		local props = properties.Properties;
		if (not props) then
			return false;
		end;
		
		local impulseProps = props.Impulses;
		impulseProps = impulseProps or {
			Amount = -1,
			Strength = 100
		};
		
		props.Model = props.Model or { File = "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf", };
		props.Model.Particle = props.Model.Particle or {};
		
		local model 	= props.Model.File or "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf";
		local sound 	= props.Model.Sound or "x";
		local mass 		= props.Model.Mass or 10;
		local effect 	= props.Model.Particle.Name or "x";
		local scale 	= props.Model.Particle.Scale or "x";
		local pulse		= props.Model.Particle.Loop;
		local pulseTime	= props.Model.Particle.Timer or 0;
		--Debug(mass)
		--Debug(scale, pulse, pulseTime)
		local entityName = model .. "|" .. sound .. "+1|" .. effect .. (pulseTime and "+"..pulseTime or "") .. "|" .. scale .. "|" .. ATOMGameUtils:SpawnCounter();
		local spawned = AddEntity({ network = false, class = "CustomAmmoPickupLarge", position = pos, dir = dir, mass = mass or 10, Mass = mass or 10, fMass = mass or 10, name = entityName, properties = { objModel = props.Model.NoServer and "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf" or model, bPhysics = 1 } });
	
		if (mass) then
			SetPhysParams(spawned, { Mass = mass });
		end;
	
		if (not spawned) then
			SysLogVerb(1,"Fatal: Failed to add projectile");
			return false;
		end;
	
		spawned.NoRemoval = props.NoRemoval;
	
		g_utils:AwakeEntity(spawned);
		spawned.ReportOnCollision = true;
		
		--if (pulse and pulseTime and pulseTime > 0.1) then
		--	Script.SetTimer(pulseTime, function()
		--		if (System.GetEntity(spawned.id) and not spawned.isCollided) then
		--			--RPC:Call("Execute", {code=[[System.GetEntityByName("]]..proj:GetName()..[["):LoadParticleEffect(-1, "]]..effect..[[",{Scale=]]..scale..[[;PulsePeriod=]]..mParams.loop.delay..[[});]]});
		--			ExecuteOnAll("local x=GetEnt('"..spawned:GetName().."')if (x) then x:FreeSlot(x.effectId);x.effectId=x:LoadParticleEffect(-1,'"..effect.."',{Scale="..scale.."})end;");
		--		end;
		--	end);
		--end;
	
		
		self.active[spawned.id] = { spawnTime = _time; spawned = spawned;};
		spawned.Props = props;

		spawned.ImpulseProps = impulseProps;

		spawned.spawnTime = _time;
		spawned.FireInfo = {
			dir = dir;
			pos = pos;
		};
		
		spawned.NoCollision = props.NoCollision;
		
		spawned.FilterProjectileCollisions = props.FilterProjectileCollisions or props.FPC;
		spawned.FilterProjectileCollisionsTime = props.FilterProjectileCollisionsTime or props.FPCTime;
		
		spawned.FireHitPos = properties.Hit
		
		local OnCollision = props.Events.OnCollision or props.Events.Collide;
		local OnSpawn = props.Events.OnSpawn or props.Events.Spawn;
		local OnHit = props.Events.OnHit or props.Events.Hit;

		spawned.OnCollisionFunc = OnCollision or function()Debug("NULL")end;
		spawned.OnHitFunc = OnHit or function()SysLog("NULL")end;

		if (owner) then
			owner.activeProjectiles = owner.activeProjectiles or {};
			owner.activeProjectiles[spawned.id] = spawned;
		
			spawned.owner = owner;
			spawned.OwnerWeapon = properties.Weapon;
		end;

		spawned.isCollided = false;

		--Debug("LULZ")
	
		if (OnSpawn) then
			g_utils:PCall(OnSpawn, spawned);
		end;
		return spawned;
	end,
	--------------
	Update = function(self)
		if (not self.lastUpdate or _time - self.lastUpdate > self.cfg.UpdateRate) then
			for i, proj in pairs(self.active) do
				if (GetEnt(i) and not proj.isCollided) then
					self:UpdateProjectile(proj.spawned);
				else
					self.active[i] = nil
				end
			end
			self.lastUpdate = _time
		end
	end,
	--------------
	UpdateProjectile = function(self, ent)
		if (ent and ent.spawnTime > 0 and not ent.isCollided) then
			
			local props = ent.Props;
			local pos = ent:GetPos();
			--local ground = System.GetTerrainElevation(pos);
			local water = CryAction.GetWaterInfo(pos);
			
			local func = ent.OnCollisionFunc;
			local coll = -1;
			
			local GroundTreshold = 1; --0.3;
			local WaterTreshold  = 1; --0.3;
			
			local collPos;
			--Debug(pos.z-ground,"<",GroundTreshold)
			--[[if ((ground > pos.z and ground - pos.z < 3) or (pos.z - ground < GroundTreshold)) then
				coll = COLLISION_GROUND;
				collPos = toVec(pos.x, pos.y, ground);
			elseif ((water > pos.z or pos.z - water < WaterTreshold) and not props.UnderwaterMissile) then
				coll = COLLISION_WATER;
				collPos = toVec(pos.x, pos.y, water);
			elseif (self:RayCheck(ent)) then
				coll = COLLISION_RAY;
				collPos = pos;
			else]]if (props.LifeTime and _time - ent.spawnTime > (props.LifeTime / 1000)) then
				coll = COLLISION_TIMEOUT;
				collPos = pos;
			elseif (not ent.NoCollision and ((water > pos.z or pos.z - water < WaterTreshold) and not props.UnderwaterMissile)) then
				coll = COLLISION_WATER;
				collPos = toVec(pos.x, pos.y, water);
			
			end;
			
			if (coll > -1) then
				ent.isCollided = true;
				local s, e = pcall(func, ent, coll, pos, collPos, g_Vectors.up);
				if (not ent.NoRemoval) then
					System.RemoveEntity(ent.id);
				end;
				if (not s) then
					ATOMLog:LogError(e);
				end;
			--	Debug("This ones done for :)")
			else
				if (not ent.impulsesDone) then
					local impulseProps = ent.ImpulseProps;
					local first = impulseProps.First;
					--[[
					local gotoAimDir = impulseProps.GotoAimDir;
					if (gotoAimDir and ent.owner and ent.owner.actor) then
						if (not ent.GoingToAimDir) then
							local apDir = self:GetHitPos(ent.owner);
							if (apDir) then
								apDir = GetDir(apDir.pos, pos);
								--Debug(Vec2Str(apDir))
								--Debug("OK, POINT SET!!")
							else
								apDir = ent.owner:GetHeadDir();
							end;
							ent.AimPointDir = apDir;
							ent.GoingToAimDir = true;
						end;
					end;
					--]]
					if (impulseProps and impulseProps.Delay and _time - ent.spawnTime < impulseProps.Delay) then
						
						ent.FirstImpulses = ent.FirstImpulses or 0
						if (first and first.Use) then
							if (ent.firstImpulseDone) then
								if (first.Repeat and (first.Repeat > 0 or first.Repeat == -1)) then
									if (timerexpired(ent.FirstImpulseTimer, (first.RepeatDelay or 0.5))) then
										ent.FirstImpulseTimer = timerinit()
										ent:AddImpulse(-1, ent:GetCenterOfMassPos(), (first.Dir or g_Vectors.down), first.Strength or 100, 1);
										ent.FirstImpulses = ent.FirstImpulses + 1
									end
								end
							end
						end
						if (first and first.Use and not ent.firstImpulseDone) then
							ent.firstImpulseDone = true;
							ent:AddImpulse(-1, ent:GetCenterOfMassPos(), (first.Dir or g_Vectors.down), first.Strength or 100, 1);
						end;
						
						if (first.Use and first.SetDir) then
							ent:SetDirectionVector(first.Dir)
						end
						return;
					end;
					local timer = impulseProps.Timer or 0;
					
					if (timer and ent.LastImpulse and _time - timer < impulseProps.Timer) then
						return;
					end;
				
					ent.LastImpulse = _time;
				
					local lockStatus;
				
					local impulses = impulseProps.Amount;
					local strength = impulseProps.Strength;
					--Debug("??? : " .. strength)
					local lockedOn = impulseProps.LockedTarget;
						
					ent.completedImpulses = ent.completedImpulses or 0;
						
					local dir = ent.lastDir or ent.FireInfo.dir or g_Vectors.down;
					
					if (impulseProps.FixedDir) then
						dir = impulseProps.FixedDir;
					end;
					
					local idLockOn = impulseProps.AutoLockId
					local hLockOn
					if (idLockOn) then
						if (type(idLockOn) == "userdata") then
							hLockOn = System.GetEntity(idLockOn)
						else
							hLockOn = idLockOn
						end
						
						if (hLockOn and hLockOn.GetPos) then
							dir = GetDir(hLockOn:GetPos(), pos);
							NormalizeVector(dir);
						end
					end
						
					if (lockedOn and ((type(lockedOn) == "userdata" and System.GetEntity(lockedOn)) or lockedOn.id)) then
						dir = GetDir((type(lockedOn) == "userdata" and System.GetEntity(lockedOn):GetPos() or lockedOn:GetPos()), pos);
						NormalizeVector(dir);
					end;
						
					local autoAim = impulseProps.AutoAim;
					local heatSearching = impulseProps.HeatSearching;
					local TimedLocking = impulseProps.TimedLocking;
					local resetLock = true
					local firstLock = false
					local locking = false
					local locked = false
					if (autoAim and ent.owner and ent.owner.actor) then
						local curr = (ent.owner.inventory and ent.owner.inventory:GetCurrentItem());
						--if (curr and curr.autoAim and ent.parentWeapon and ent.parentWeapon.id == curr.id) then
						--	local fpos = System.GetCollideData(ent.shooter,ent.shooter.actor:GetHeadDir()); --ent.shooter and ent.shooter.currentAimPoint or 
						--	dir = (fpos and GetDir(fpos.pos, p) or ent.shooter.actor:GetHeadDir());
						--end;
						if (curr and ent.OwnerWeapon and ent.OwnerWeapon.id == curr.id) then
							dir = self:GetHitPos(ent.owner);
							local aimingOnProjectile = dir and dir.entity and self.active[dir.entity.id];
							if (dir and not aimingOnProjectile) then
								--DebugTable(dir)
								if (heatSearching and dir.entity and not self.active[dir.entity.id]) then
									if (not ent.owner or ent.owner.id ~= dir.entity.id) then
										if (not ent.OwnerWeapon or ent.OwnerWeapon.id ~= dir.entity.id) then
											if (TimedLocking) then
												resetLock = false;
												ent.LockingTime = ent.LockingTime or 0;
												ent.LockingTime = ent.LockingTime + System.GetFrameTime() * 1;
											end;
											--Debug(TimedLocking)
											if (not ent.owner.AutoaimStarted) then
												firstLock = true
											end
											
											ent.owner.AutoaimStarted = true
											
											lockStatus = ((ent.LockingTime or 0) / 10) * 1000;
											if (TimedLocking and lockStatus < 100) then
												if (not ent.owner.LastLockMsg or _time - ent.owner.LastLockMsg > 0.1) then
													SendMsg(CENTER, ent.owner, "[ LOCKING - [ %s%% ] - FINISHED ]", cutNum((lockStatus/100)*100,2));
													ent.owner.LastLockMsg = _time;
													locking = true
												end;
												if (ent.owner.IS_LOCKING) then
												--	g_gameRules.onClient:ClStepWorking(g_gameRules.game:GetChannelId(ent.owner.id), math.floor(tonumber(cutNum((lockStatus/100)*100,2))  + 0.5));
												end
											else
												ent.HeatTarget = dir.entity;
												local tgtIsPlayer = ent.HeatTarget.isPlayer or (ent.HeatTarget.vehicle and ent.HeatTarget:GetDriver() and ent.HeatTarget:GetDriver().isPlayer);
												local playerTarget = ent.HeatTarget.isPlayer and ent.HeatTarget or ((ent.HeatTarget.vehicle and ent.HeatTarget:GetDriver() and ent.HeatTarget:GetDriver().isPlayer) and ent.HeatTarget:GetDriver())
												if (tgtIsPlayer and impulseProps.LockedMessage) then
													if (not ent.LockedMessage) then
														ent.LockedMessage = true;
														--Debug(ent.HeatTarget:GetName())
														SendMsg(ERROR, playerTarget, "!! WARNING : MISSLES LOCKED ON TO YOU !!");
														ExecuteOnPlayer(playerTarget, "ATOMClient:HandleEvent(eCE_Sound, g_localActor:GetName(), \"sounds/interface:multiplayer_interface:mp_tac_alarm_suit\");")
														
													end;
												end;
												if (ent.owner and ent.owner.isPlayer) then
													SendMsg(CENTER, ent.owner, "!! MISSILES LOCKED ON TARGET !!");
													locked = true
												end;
											end;
										--	Debug("LOCKING ON!",dir.entity:GetName())
										end;
									end;
								end;
								--Debug(tostr(dir.Entity))
								dir = GetDir(dir.pos, pos);
							else
								dir = ent.owner:GetHeadDir();
							end;
						end;
					elseif (gotoAimDir and ent.owner and ent.owner.actor) then
						dir = GetDir(ent.FireHitPos, pos);
					end;
					
					--[[
					local idLockPercentage = cutNum(((((ent.LockingTime or 0) / 10) * 1000) /100) * 100, 2)
					
					if (locked) then
						Debug("LOCKED !")
					elseif (firstLock and not resetLock) then
						Debug("FIRST LOCK !!",idLockPercentage)
					elseif (locking) then
						Debug("LOCKING !!!",idLockPercentage)
					elseif (resetLock and tonumber(idLockPercentage) > 0) then
						Debug("UNLOCK !",idLockPercentage)
					end--]]
					
					if (firstLock) then
					--	Debug("Start working !!")
					--	g_gameRules.onClient:ClStartWorking(g_gameRules.game:GetChannelId(ent.owner.id), ent.owner.id, "autolock");
					--	ExecuteOnPlayer(ent.owner, "g_gameRules.work_name=\"Locking on Target ...\"HUD.SetProgressBar(true, 0, g_gameRules.work_name);Msg(0,'OK')")
					--	ent.owner.IS_LOCKING = true
					end
					
					if (resetLock) then
						ent.LockingTime = minimum(0, (ent.LockingTime or 0) - System.GetFrameTime() / 5);
						lockStatus = ((ent.LockingTime or 0) / 10) * 1000;
						if (ent.LockingTime > 0) then
						
							if (ent.owner.IS_LOCKING) then
							--	ent.owner.IS_LOCKING = false
							--	ExecuteOnPlayer(ent.owner, "g_gameRules.work_name=\"Unlockin ...\"HUD.SetProgressBar(true, 0, g_gameRules.work_name);Msg(0,'OK')")
							end
						
							if (not ent.owner.LastLockMsg or _time - ent.owner.LastLockMsg > 0.1) then
								SendMsg(CENTER, ent.owner, "[ UNLOCKING - [ %s%% ] ]", cutNum((lockStatus/100)*100,2));
								ent.owner.LastLockMsg = _time;
							end;
							
						--	g_gameRules.onClient:ClStepWorking(g_gameRules.game:GetChannelId(ent.owner.id), math.floor(tonumber(cutNum((lockStatus/100)*100,2))  + 0.5));
						else
						--	g_gameRules.onClient:ClStopWorking(g_gameRules.game:GetChannelId(ent.owner.id), ent.id, true);
						end;
					end;
					
					if (ent.HeatTarget) then
						if (GetEnt(ent.HeatTarget.id)) then
							dir = GetDir(ent.HeatTarget:GetCenterOfMassPos(), ent);
							NormalizeVector(dir)
							--Debug(Vec2Str(dir))
						else
							ent.HeatTarget = nil;
						end;
					end;
					--Debug(dir)
					--dir=g_Vectors.up
					if (impulses == -1 or ent.completedImpulses < impulses) then
						--if ((not timer or timer <= 0) or (not ent.lastImp or _time - ent.lastImp > timer)) then
						--	ent.lastImp = _time;
						ent:AddImpulse(-1, ent:GetCenterOfMassPos(), dir or g_Vectors.down, strength, 1);
						--end;
						if (not impulseProps.NoSetDir) then
							ent:SetDirectionVector(dir)
						end;
						if (impulses ~= -1) then
							ent.completedImpulses = ent.completedImpulses + 1;
						end;
					else
						ent.impulsesDone = true;
					end;
						
					ent.lastDir = dir;
				end;
			end;
		end;
	end,
	--------------
	GetHitPos = function(self, owner)
		if (not owner.LastHitPos or _time - owner.LastHitPosTime > 0.1) then
			owner.LastHitPosTime = _time;
			owner.LastHitPos = owner:GetHitPos(1024);
			--Debug("NEW DIR")
		end;
		return owner.LastHitPos;
	end,
	--------------
	CollidedWithProjectile = function(self, sample)
		for i, entity in ipairs(sample or{}) do
			if (entity and type(entity) == "table" and entity.id and self.active[entity.id]) then
				--Debug(entity:GetName() .. " -> self.active")
				return true;
			end;
		end;
		for i, v in pairs(self.active) do
			if (_time - v.spawned.spawnTime < 1) then
				local owner = v.spawned.owner;
				if (owner) then
					if (owner.GetVehicle) then
						local vId = owner:GetVehicle();
						if (vId) then
							for j, entity in ipairs(sample or{}) do
								if (entity and type(entity) == "table" and entity.id and vId.id == entity.id) then
									--Debug(entity:GetName() .. " -> this.owner.vehicle")
									return true;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end,
	--------------
	RayCheck = function(self, entity)
		do return false end
		local FUCK = entity:CheckCollisions(0,0)
		--Debug(#FUCK.contacts)
		if (_time - entity.spawnTime > 0.1) then
			local sample = Physics.SamplePhysEnvironment(entity:GetPos(), 0.3)
			if (arrSize(sample) > 0) then
				return not self:CollidedWithProjectile(sample);
			end;
		end;
		return false;
	end,
	--------------
	OnCollision = function(self, ent, tgt, impulse, contact, normal, radius)
		--Debug("impulse", impulse)
		--Debug("contact", contact)
		--Debug("normal", normal)
		--Debug("radius", radius)
		--Debug((tgt and tgt:GetName() or "prop"))
		if (not ent.isCollided and self.active[ent.id] and _time - ent.spawnTime > 0.1 and not ent.NoCollision) then
			if (tgt and (ent.FilterProjectileCollisions or (ent.OwnerWeapon and ent.OwnerWeapon.RapidFire)) and self.active[tgt.id]) then
				return;
			end;
			if (tgt and (ent.FilterProjectileCollisionsTime and _time - ent.spawnTime < ent.FilterProjectileCollisionsTime) and self.active[tgt.id]) then
				return;
			end;
			local props = ent.Props;
			local pos = ent:GetPos();
			local ground = System.GetTerrainElevation(pos);
			local water = CryAction.GetWaterInfo(pos);
			
			local func = ent.OnCollisionFunc;
			local coll = -1;
			
			local GroundTreshold = 1; --0.3;
			local WaterTreshold  = 1; --0.3;
			
			local collPos;
			--Debug(pos.z-ground,"<",GroundTreshold)
			if ((ground > pos.z and ground - pos.z < 3) or (pos.z - ground < GroundTreshold)) then
				coll = COLLISION_GROUND;
				collPos = toVec(pos.x, pos.y, ground);
			elseif ((water > pos.z or pos.z - water < WaterTreshold) and not props.UnderwaterMissile) then
				coll = COLLISION_WATER;
				collPos = toVec(pos.x, pos.y, water);
			else
				coll = COLLISION_RAY;
				collPos = contact; --pos;
			end;
			--Debug("!!",COLLISION_RAY,_time - ent.spawnTime)
			if (coll > -1) then
				ent.isCollided = true;
				local s, e = pcall(func, ent, coll, pos, collPos, normal);
				if (not ent.NoRemoval) then
					System.RemoveEntity(ent.id);
				end;
				if (not s) then
					ATOMLog:LogError(e);
				end;
			--	Debug("This ones done for :)")
			end;
			
			ent.ReportOnCollision = false; -- report only once
		end;
	end,
	--------------
	OnHit = function(self, entity, hit)
		if (self.active[entity.id] and not entity.isCollided) then
			entity.isCollided = true;
			local func = entity.OnHitFunc
			local s, e = pcall(func, entity, COLLISION_HIT, entity:GetPos(), hit.pos. hit.dir);
			if (not ent.NoRemoval) then
				System.RemoveEntity(ent.id);
			end;
			if (not s) then
				ATOMLog:LogError(e);
			end;
		end;
	end,
	--------------
};

ATOMItems:Init();
