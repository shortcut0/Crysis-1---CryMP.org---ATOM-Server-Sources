TerminatorLaser = {
		cfg = {
			
		};
		settings = {
			laser = {
				model = "objects/effects/beam_laser_02.cgf";
				scale = 500;
				height = 700;
			};
			effects = {
				ground = "explosions.warrior.collision_deck1";
				water = "explosions.warrior.collision_deck1";
				ray = "explosions.warrior.collision_deck1";
			};
		};
		temp = {
			activeLasers = {};
		};
		-----------------
		Init = function(self)
			AddHook("OnQTick", self.OnTick, self);
		end;
		-----------------
		SpawnLaser = function(self, pos, goal, onReached, onTimeout, speed, groundH, laserS, goalR)
			pos.z = pos.z + self.settings.laser.height;
			local laserId = "LASER_" .. game:SpawnCounter();
			self.temp.activeLasers[laserId] = {
				laserActive = true;
				id = laserId;
				laserSpeed = speed or 3;
				laserDeathRadius = 5;
				currentPos = pos;
				goal = goal; -- can be entity or position
				goalRadius = goalR or 5; -- if closer than this to goal[pos/entity] it succeeds
				onReached = onReached or function()end;
				onTimeout = onTimeout or function()end;
				lifeTime = 100; -- in seconds
				laserProps = {
					scale = laserS or self.settings.laser.scale;
					height = groundH or self.settings.laser.height;
				};
			};
			return laserId;
		end;
		-----------------
		StopLaser = function(self, laserId)
			if (self.temp.activeLasers[laserId]) then
				self.temp.activeLasers[laserId].laserActive = false;
			end;
		end;
		-----------------
		OnTick = function(self)
			local temp, goal = self.temp, nil;
			if (arrSize(temp.activeLasers) > 0) then
				for i, laser in pairs(temp.activeLasers or{}) do
					laser.activeTime = (laser.activeTime or 0) + 0.1;
					if (laser.goal and laser.currentPos) then
						if (laser.laserActive) then
							if (laser.activeTime >= laser.lifeTime and laser.lifeTime ~= -1) then
								laser.onTimeout(laser.goal);
								self:RemoveEntities(laser);
								self.temp.activeLasers[i] = nil;
							else
								goal = (laser.goal.id and laser.goal:GetPos() or laser.goal);
								if (GetDistance(goal, laser.currentPos) and GetDistance(goal, laser.currentPos) < laser.goalRadius) then
									laser.onReached(laser.goal);
									if (laser.goal.id) then HitEntity(laser.goal, 9999); end;
									--g_gameRules:CreateExplosion(NULL_ENTITY, NULL_ENTITY, 10000, goal, g_Vectors.up, 15,45,5000,1, "", 1,1.3,2.2,5);
									self:RemoveEntities(laser);
									self.temp.activeLasers[i] = nil;
								else
									local newPosition = CF_GameUtils:GetPosInFrontOfDir(laser.currentPos, GetNVec(GetDir(laser.currentPos, goal, true)), laser.laserSpeed);
									local effect = "";
									if (newPosition.z < CryAction.GetWaterInfo(newPosition)) then
										effect = self.settings.effects.ground;
										newPosition.z = CryAction.GetWaterInfo(newPosition);
									else
										effect = self.settings.effects.water;
										newPosition.z = System.GetTerrainElevation(newPosition);
									end;
									if (laser.laserEntity) then
										System.RemoveEntity(laser.laserEntity.id);
									end;
									SpawnEffect("explosions.warrior.debris_explosion_light", newPosition, g_Vectors.up, 0.5)
								--	SinepUtils:SpawnEffect("explosions.warrior.collision_deck2", newPosition)
									g_gameRules:CreateExplosion(NULL_ENTITY, NULL_ENTITY, 1000, newPosition, g_Vectors.up, 5,45,5000,1, effect, 1,1.3,2.2,5);
									
									newPosition.z = newPosition.z + laser.laserProps.height;
									laser.currentPos = newPosition;
									laser.laserEntity = SinepUtils:SpawnGUI(self.settings.laser.model, newPosition, -1, nil, nil, nil, nil, nil, nil);
									if (not laser.cloud) then
										--local model, sound, soundVol, effect, scale, trash = name:match("(.*)|(.*)+(.*)|(.*)|(.*)|(.*)");
										local name = "x|x+x|Alien_Environment.Mine.mountain_cloud|2|"..game:SpawnCounter()
										laser.cloud = System.SpawnEntity({class = "CustomAmmoPickupLarge", name = name, orientation=dir, position = newPosition, properties = { bPhysics=1, objModel = "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf"}});
										laser.cloud.__DELETEME = true;
									end;
									laser.cloud:SetWorldPos(newPosition);
									laser.laserEntity:SetScale(laser.laserProps.scale);
									laser.laserEntity.__DELETEME = true;
									laser.laserEntity:SetAngles({x=-1.572,y=0,z=0});
									newPosition.z = newPosition.z - laser.laserProps.height;
								end;
							end;
						else
							self:RemoveEntities(laser);
						end;
					else
						self.temp.activeLasers[i] = nil;
					end;
				end;
			elseif (false) then
				local guis = System.GetEntitiesByClass("GUI");
				local caps = System.GetEntitiesByClass("CustomAmmoPickup");
				for i, ent in ipairs(guis or{}) do
					if (ent.__DELETEME) then
						System.RemoveEntity(ent.id);
					end;
				end;
				for i, ent in ipairs(caps or{}) do
					if (ent.__DELETEME) then
						System.RemoveEntity(ent.id);
					end;
				end;
			end;
		end;
		-----------------
		RemoveEntities = function(self, laser)
			if (laser.cloud) then
				System.RemoveEntity(laser.cloud.id);
			end;
			if (laser.laserEntity) then
				System.RemoveEntity(laser.laserEntity.id);
			end;
			laser.laserActive = false;
			self:StopLaser(laser.id);
		end;
		-----------------
		
		-----------------
		
		-----------------
		
		-----------------
		
		-----------------
	}; -- SinepGPUtils.WeaponForce.toReplace
TerminatorLaser:Init();