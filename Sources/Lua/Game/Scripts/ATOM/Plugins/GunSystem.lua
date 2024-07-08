GunSystem = {
	cfg = {
		RequiredEvents = {
			{ "OnHit", 			"OnHit" },
			{ "OnVehicleHit", 	"OnHit" },
			{ "OnItemHit", 		"OnHit" },
			
			{ "OnShoot", 		"OnShoot" },
			{ "OnMelee", 		"OnMelee" }
		}
	},
	-----------------------
	Guns = {},
	GunsList = {},
	-----------------------
	-- OnInit
	-----------------------
	OnInit = function(self)
		self:AddGuns();
		for i, event in pairs(self.cfg.RequiredEvents) do
			RegisterEvent(event[1], self[event[2]], 'GunSystem');
		end;
		
		DEFAULT_PROJECTILE_PROPERTIES = {
			Owner = nil,
			Weapon = nil,
			Pos = nil,
			Dir = nil,
			Hit = nil,
			Normal = nil,
			Properties = {
				UnderwaterMissile = false, -- If true, projectile wont collide on water
				Collision = {
					Water = 0.3,
					Ground = 0.3,
				},
				LifeTime = 25000, -- Lifetime in milliseconds
				Model = {
					File = "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf",
					Dir = nil,
					Particle = {
						Scale = 1,
						Name = "smoke_and_fire.weapon_stinger.FFAR",
						Loop = false, -- use pulse period on effect
						Timer = 0, -- Effect pulse period
					},
					Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
					Mass = 10,
				},
				Impulses = {
					HeatSearching = false, -- If true, projectile will lock on entities
					AutoAim = false, -- Projectile flys wherever player is currently aiming
					First = { -- first impulse applied
						Use = false,
						Dir = dir,
						SetDir = false, -- force this direction
						Strength = 1000,
					},
					Delay = 0, -- delay in seconds
					Amount = -1, -- amount of impulses
					Timer = 0, -- timer between each impulse
					Strength = 100, -- strength of the impulses applied
					LockedTarget = nil,
					GotoAimDir = false, -- if true, projectile will travel to current aim point
				},
				Events = {
					Spawn = function(p)
					end,
					Collide = function(p, t, pos, contact, dir)
						if (t == COLLISION_WATER) then
							Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon);
							PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
						end;
						if (t == COLLISION_GROUND) then
							Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
							PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", contact);
						end;
						if (t == COLLISION_RAY) then
							Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
							PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", contact);
						end;
						if (t == COLLISION_TIMEOUT) then
							Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
							PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", contact);
						end;
						if (t == COLLISION_HIT) then
							Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon);
							PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", contact);
						end;
					end,
				},
			},
		}
	end,
	-----------------------
	-- OnShutdown
	-----------------------
	OnShutdown = function(self)
	
	end,
	-----------------------
	-- AddGuns
	-----------------------
	AddGuns = function(self)
		self:AddWeapon(
			"teleport", 
			"Teleport Gun",
			"Teleports wherever you shoot",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					SendMsg(CENTER, player, "(TELEPORTED :: %sm)", cutNum(GetDistance(player:GetPos(), hit), 2));
					g_game:MovePlayer(player.id, hit, Dir2Ang(dir));
					g_utils:SpawnEffect(ePE_Light, hit, hitNormal);
				end
			}
		);
		self:AddWeapon(
			"onehit", 
			"OnHit Gun",
			"Kills everything with one hit",
			{ 
				OnHit = function(weapon, hit)
					hit.KillHit = true;
					hit.damage = 999999;
				end 
			}
		);
		self:AddWeapon(
			"hellfire", 
			"HellFire Missile",
			"shoots a deadly helicopter projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
					
					}));
				end 
			}
		);
		self:AddWeapon(
			"exocet", 
			"Exocet Missile",
			"shoots a deadly exocet missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						
						Properties = {
							Impulses = {
							--	HeatSearching = true,
							--	LockedMessage = true,
							--	TimedLocking = false,
								AutoAim = true
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 6, 160, dir, p.owner, p.OwnerWeapon);
										PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
									else
										Explosion("explosions.rocket_terrain.exocet", contact, 6, 160, dir, p.owner, p.OwnerWeapon, 1.4);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil,
			}
		);
		self:AddWeapon(
			"missileplatform", 
			"Platform Missile",
			"shoots a deadly missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									else
										Explosion("explosions.rocket_terrain.explosion", contact, 15, 500, dir, p.owner, p.OwnerWeapon);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"sidewinder", 
			"Sidewinder Missile",
			"shoots a deadly missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2)
										PlaySound("sounds/physics:explosions:water_explosion_large", contact)
									else
										Explosion(GetRandom({"explosions.rocket.concrete", "explosions.rocket.generic"}), contact, 15, 500, dir, p.owner, p.OwnerWeapon)
										PlaySound("sounds/physics:explosions:missile_vtol_explosion", contact)
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"singularity", 
			"Singularity Projectile",
			"shoots a deadly Singularity Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Model = {
								Particle = {
									Name = "alien_weapons.singularity.Hunter_Singularity_Projectile",
									Timer = 1,

								},
								Sound = "Sounds/weapons:singularity_cannon:sing_cannon_flying_loop",
							},
							Impulses = {
								Strength = 50
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
									--	Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										SpawnEffect("explosions.rocket.water", contact, dir);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									end;
										Explosion("Alien_Weapons.singularity.Scout_Singularity_Impact", contact, 15, 500, dir, p.owner, p.OwnerWeapon);
									--end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"hsingularity", 
			"HeavySingularity Projectile",
			"shoots a deadly Singularity Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Model = {
								Particle = {
									Name = "alien_weapons.singularity.Hunter_Singularity_Projectile",
									Timer = 1,

								},
								Sound = "Sounds/weapons:singularity_cannon:sing_cannon_flying_loop",
							},
							Impulses = {
								Strength = 50
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
									--	Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										SpawnEffect("explosions.rocket.water", contact, dir);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									end;
										Explosion("Alien_Weapons.singularity.Tank_Singularity_Impact", contact, 30, 500, dir, p.owner, p.OwnerWeapon, 0.4);
									--end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"megasingularity", 
			"MegaSingularity Projectile",
			"shoots a deadly Singularity Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Model = {
								Particle = {
									Name = "alien_weapons.singularity.Hunter_Singularity_Projectile",
									Timer = 1,

								},
								Sound = "Sounds/weapons:singularity_cannon:sing_cannon_flying_loop",
							},
							Impulses = {
								Strength = 50,
								AutoAim = true
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
									--	Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										SpawnEffect("explosions.rocket.water", contact, dir);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									end;
										Explosion("Alien_Weapons.singularity.Tank_Singularity_Impact", contact, 50, 500, dir, p.owner, p.OwnerWeapon, 0.8);
									--end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"rpg", 
			"RPG Missile",
			"shoots a deadly bazooka missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Impulses = {
								HeatSearching = true,
								LockedMessage = true,
								TimedLocking = true,
								AutoAim = true
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 5, 60, dir, p.owner, p.OwnerWeapon);
										PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
									else
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 150, dir, p.owner, p.OwnerWeapon, 0.6);
										PlaySound("sounds/physics:explosions:law_explosion", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"apc", 
			"APC Round",
			"shoots a deadly bazooka missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Impulses = {
								Strength = 2000,
							},
							Model = {
								Particle = {
									Name = "smoke_and_fire.Tank_round.apc30",
									Scale = 5
								},
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 3, 60, dir, p.owner, p.OwnerWeapon, 0.54);
										PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
									else
										Explosion("explosions.tank30.default", contact, 3, 50, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound("sounds/physics:explosions:large_explosion", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"tank", 
			"Tank Round",
			"shoots a deadly bazooka missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Impulses = {
								Strength = 2000,
							},
							Model = {
								Particle = {
									Name = "smoke_and_fire.Tank_round.Trail",
									Scale = 0.5
								},
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 5, 300, dir, p.owner, p.OwnerWeapon, 3);
										PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
									else
										Explosion("explosions.rocket.metal", contact, 5, 300, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound("sounds/physics:explosions:cannon_explosion_big", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"warzone", 
			"Warzone Missile",
			"shoots a deadly bazooka missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Events = {
								Collide = function(p, t, pos, contact, dir)
									local aEffects = {
										"explosions.grenade_air.explosion",
										"explosions.tank_explosion.chinese_tank",
										"explosions.grenade_air.explosion",
										"explosions.CIV_explosion.a",
										"explosions.train_destroy.small",
									}
									local vPos = vector.copy(contact)
									for i = 1, 30 do
										Script.SetTimer(i * 100, function()
											vPos.x = contact.x + GetRandom(-40, 40)
											vPos.y = contact.y + GetRandom(-40, 40)
											vPos.z = GetGroundPos(vPos)
											
											Explosion(GetRandom(aEffects), vPos, 10, 150, dir, p.owner, p.OwnerWeapon)
										end)
									end
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"8brpg", 
			"8B Rpg",
			"shoots 8 deadly bazooka missiles",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 1, 8 do
						Script.SetTimer(15, function()
							ATOMItems:AddProjectile(
							mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
								Owner = player,
								Weapon = weapon,
								Pos = add2Vec(pos, { x = math.random(-10,10) / 100, y = math.random(-10,10) / 100, z = math.random(-10,10) / 100}),
								Dir = add2Vec(dir, { x = math.random(-10,10) / 100, y = math.random(-10,10) / 100, z = math.random(-10,10) / 100}),
								Hit = hit,
								Normal = hitNormal,
								Properties = {
									FPCTime = 0.5,
									Impulses = {
										AutoAim = false
									},
									Events = {
										Collide = function(p, t, pos, contact, dir)
											if (t == COLLISION_WATER) then
												Explosion("explosions.rocket.water", contact, 5, 60, dir, p.owner, p.OwnerWeapon);
												PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
											else
												Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 150, dir, p.owner, p.OwnerWeapon);
												PlaySound("sounds/physics:explosions:law_explosion", contact);
											end;
										end,
									},
								};
							}));
						end);
					end;
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"quadrpg", 
			"Quad Launcher",
			"shoots 4 deadly bazooka missiles",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 1, 4 do
						Script.SetTimer(15, function()
							ATOMItems:AddProjectile(
							mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
								Owner = player,
								Weapon = weapon,
								Pos = add2Vec(pos, { x = math.random(-10,10) / 100, y = math.random(-10,10) / 100, z = math.random(0,10) / 100}),
								Dir = add2Vec(dir, { x = math.random(-10,10) / 100, y = math.random(-10,10) / 100, z = math.random(0,10) / 100}),
								Hit = hit,
								Normal = hitNormal,
								Properties = {
									FPCTime = 0.5,
									Impulses = {
										AutoAim = false
									},
									Events = {
										Collide = function(p, t, pos, contact, dir)
											if (t == COLLISION_WATER) then
												Explosion("explosions.rocket.water", contact, 5, 60, dir, p.owner, p.OwnerWeapon);
												PlaySound("sounds/physics:explosions:water_explosion_medium", contact);
											else
												Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 5, 150, dir, p.owner, p.OwnerWeapon, 0.7);
												PlaySound("sounds/physics:explosions:law_explosion", contact);
											end;
										end,
									},
								};
							}));
						end);
					end;
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"cluster", 
			"Cluster Gun ?",
			"shoots a deadly wtf round",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						--Weapon = weapon,
						Pos = pos,
						Dir = add2Vec(dir, toVec(0,0,0.1)),
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisionsTime = 0.3,
							Impulses = {
								Amount = 1,
								Strength = 500,
							},
							Model = {
								Particle = {
									Name = "muzzleflash.LAM.grenade_white",
									Scale = 4,
									Loop = true,
									Timer = 1
								},
								Sound = "x",
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 0.7);
										PlaySound("sounds/physics:explosions:water_explosion_small", contact);
									else
										Explosion("explosions.Grenade_SCAR.backup", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 1.75);
										PlaySound("sounds/physics:explosions:grenade_launcher_explosion", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"fgl40", 
			"FGL40 Launcher",
			"shoots a deadly FGL40 round",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						--Weapon = weapon,
						Pos = pos,
						Dir = add2Vec(dir, toVec(0,0,0.1)),
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisionsTime = 0.3,
							Impulses = {
								Amount = 1,
								Strength = 200,
							},
							Model = {
								Particle = {
									Name = "muzzleflash.LAM.grenade_white",
									Scale = 4,
									Loop = true,
									Timer = 1
								},
								Sound = "x",
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 0.7);
										PlaySound("sounds/physics:explosions:water_explosion_small", contact);
									else
										Explosion("explosions.mine.frog_mine", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 1);
										PlaySound("sounds/physics:explosions:grenade_explosion", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"fgl40b", 
			"FGL40-B Launcher",
			"shoots a deadly FGL40-B round",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						--Weapon = weapon,
						Pos = pos,
						Dir = add2Vec(dir, toVec(0,0,0.05)),
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisionsTime = 0.3,
							Impulses = {
								Amount = 1,
								Strength = 600,
							},
							Model = {
								Particle = {
									Name = "muzzleflash.LAM.grenade_white",
									Scale = 4,
									Loop = true,
									Timer = 1
								},
								Sound = "x",
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 0.7);
										PlaySound("sounds/physics:explosions:water_explosion_small", contact);
									else
										Explosion("explosions.mine.frog_mine", contact, 6, 100, dir, p.owner, p.OwnerWeapon, 1);
										PlaySound("sounds/physics:explosions:grenade_explosion", contact);
									end;
								end,
							},
						};
					}));
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"fgl50", 
			"FGL50 Launcher",
			"shoots 4 deadly FGL40 rounds",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 1, 3 do
						Script.SetTimer(100, function()
							local d; --add2Vec(add2Vec(dir, toVec(0,0,0.01)), toVec(math.random(-3,3)/100, math.random(-3,3)/100, 0));
							local p
							if (i==1) then
								d=add2Vec(dir,makeVec(math.random(-3,3)/100,0,0))
								p=add2Vec(pos, d);
							elseif (i==2) then
								d=dir;--add2Vec(dir,makeVec(dir.x,0,0))
								p=pos;
							else
								d=add2Vec(dir,makeVec(0,math.random(-3,3)/100,0))
								p=add2Vec(pos, d);
							end;
							--local p = add2Vec(pos, makeVec(0,i*0.1,i*0.01)); --add2Vec(pos, d);-- { x = math.random(-10,10) / 40, y = math.random(-10,10) / 40, z = math.random(-10,10) / 40});
							ATOMItems:AddProjectile(
							mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
								Owner = player,
								--Weapon = weapon,
								Pos = p,
								Dir = d,
								Hit = hit,
								Normal = hitNormal,
								Properties = {
									FilterProjectileCollisionsTime = 0.3,
									Impulses = {
										Amount = 1,
										Strength = 200,
									},
									Model = {
										Particle = {
											Name = "muzzleflash.LAM.grenade_white",
											Scale = 4,
											Loop = true,
											Timer = 1
										},
										Sound = "x",
										File = nil,
										NoServer = true;
									},
									Events = {
										Collide = function(p, t, pos, contact, dir)
											if (t == COLLISION_WATER) then
												Explosion("explosions.rocket.water", contact, 3, 100, dir, p.owner, p.OwnerWeapon, 0.7);
												PlaySound("sounds/physics:explosions:water_explosion_small", contact);
											else
												Explosion("explosions.mine.frog_mine", contact, 3, 100, dir, p.owner, p.OwnerWeapon, 1);
												PlaySound("sounds/physics:explosions:grenade_explosion", contact);
											end;
										end,
									},
								};
							}));
						end);
					end;
				end 
			},
			{
				NoMelee = nil
			}
		);
		self:AddWeapon(
			"loochadorRocket", 
			"Loochador Missile",
			"shoots a deadly loochador missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							Impulses = {
								First = {
									Use = true,
									Dir = toVec(dir.x, dir.y, 0.7),
									Strength = 300,
								},
								Delay = 0.6,
								HeatSearching = true,
								AutoAim = false,
								GotoAimDir = true,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									else
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound("sounds/physics:explosions:explo_rocket", contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"jetbomb", 
			"Jet Bomb",
			"shoots a deadly jet missile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 20000,
							Model = {
								File = "objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf",
								Particle = {
									Name = "x",
								},
								Sound = "x",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
							},
							Impulses = {
								Amount = 1,
								Strength = 350,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									else
										Explosion(GetRandom({"explosions.C4_explosion.ship_door", "explosions.C4_explosion.ship_door"}), contact, 10, 500, dir, p.owner, p.OwnerWeapon, 0.7);
										PlaySound("sounds/physics:explosions:explo_rocket", contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"tacgun", 
			"TACGun",
			"shoots a deadly Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = nil, --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "smoke_and_fire.Tank_round.tac",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 50,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.TAC.small_new", "explosions.TAC.rifle_close", "explosions.TAC.rifle_far"}), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"dueltacgun", 
			"DualTACGun",
			"shoots, bear with me, TWO deadly Projectiles",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 0, 1 do
					Script.SetTimer(i * 500, function()
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = nil, --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "smoke_and_fire.Tank_round.tac",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 50,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.TAC.small_new", "explosions.TAC.rifle_close", "explosions.TAC.rifle_far"}), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
					end)
					end
				end 
			}
		);
		self:AddWeapon(
			"minitacgun", 
			"MiniTACGun",
			"shoots a Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = nil, --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "smoke_and_fire.Tank_round.tac",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 50,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.1 },
										{"explosions.mine.seamine",               0.5 },
										{"explosions.Grenade_SCAR.water",         0.5 },
										{"explosions.jet_water_impact.hit",       0.3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 3, 500, dir, p.owner, p.OwnerWeapon, 0.25);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.TAC.small_new", "explosions.TAC.rifle_close", "explosions.TAC.rifle_far"}), contact, 3, 10000, dir, p.owner, p.OwnerWeapon, 0.15);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"tactankgun", 
			"Tank TACGun",
			"shoots a deadly TAC Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = nil, --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "smoke_and_fire.Tank_round.tac",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								First = { -- first impulse applied
									Use = true,
									Dir = dir,
									Strength = 99999,
								},
								Delay = 0.5,
								Amount = 50,
								Strength = 99999,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.TAC.Small_new"}), contact, 25, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"mortar", 
			"MORTAR",
			"shoots a deadly mortar Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = nil, --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "smoke_and_fire.Tank_round.tac",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 50,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									local projPos = pos;projPos.z=projPos.z+25
									local effects = {
										"explosions.barrel.explode",
										"explosions.zero_gravity.explosion_small",
										"explosions.mine.huge_harbor_mortars",
										"explosions.mine.harbor_mortars_cine",
										"explosions.rocket.cliff",
										"explosions.rocket_terrain.exocet",
										"explosions.C4_explosion.ship_door",
										"explosions.Grenade_terrain.explosion",
										"explosions.zero_gravity.explosion_small",
										"explosions.zero_gravity.explosion_big",
									};
									for i=1, 30 do
										Script.SetTimer(i*100, function()
											local _dummy = SpawnCAP("Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf", projPos);
											_dummy:AddImpulse(-1, _dummy:GetCenterOfMassPos(), makeVec(math.random(-1.0,0.3), math.random(-1.0,0.3), math.random(-1.0,0.0)), 1500, 1);
											Script.SetTimer(2.5*1000, function()
												g_gameRules:CreateExplosion(p.owner.id,p.owner.id,300,_dummy:GetPos(),{x=0,y=0,z=1},10,0,1500,1,GetRandom(effects),1, 5, 15, 15);
												--PlaySound("sounds/physics:explosions:grenade_explosion", _dummy:GetPos());
												Script.SetTimer(2500, function()
													System.RemoveEntity(_dummy.id);
												end);
											end)
										end);
									end;
									return true;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"rpgcomet", 
			"Bazooka Comet",
			"shoots a deadly Asteroid",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "explosions.jet_explosion.burning",
									Scale = 0.3,
									Loop = true,
									Timer = 8
								},
								Sound = "Sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								
								AutoAim = true,
								Amount = -1,
								Strength = 500,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.jet_explosion.on_fleet_deck", "explosions.mine_explosion.hunter_reveal", "explosions.mine_explosion.door_explosion", "explosions.harbor_airstirke.airstrike_large", "explosions.harbor_airstirke.airstrike_medium" }), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"megacomet", 
			"Mega Comet",
			"shoots a deadly Asteroid",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "explosions.jet_explosion.burning",
									Scale = 0.3,
									Loop = true,
									Timer = 8
								},
								Sound = "Sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Timer = 1,
								Amount = -1,
								Strength = 1000,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.jet_explosion.on_fleet_deck", "explosions.mine_explosion.hunter_reveal", "explosions.mine_explosion.door_explosion", "explosions.harbor_airstirke.airstrike_large", "explosions.harbor_airstirke.airstrike_medium" }), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"grenade", 
			"Frag Grenade",
			"shoots a deadly frag grenade",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							NoCollision = true,
							FilterProjectileCollisions = true, 
							LifeTime = 3000,
							Model = {
								File = nil,
								Particle = {
									Name = "muzzleflash.LAM.grenade_white",
								},
								Sound = "x",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
							},
							Impulses = {
								Amount = 1,
								Strength = 70,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_TIMEOUT) then
										if (pos.z < CryAction.GetWaterInfo(pos)) then
											Explosion(GetRandom({"explosions.Grenade_SCAR.water"}), toVec(pos.x, pos.y, CryAction.GetWaterInfo(pos)), 8, 25, dir, p.owner, p.OwnerWeapon, 1);
											PlaySound("sounds/physics:explosions:water_explosion_small", contact);
										else
											Explosion(GetRandom({"explosions.Grenade_SCAR.concrete"}), contact, 8, 25, dir, p.owner, p.OwnerWeapon, 1);
											PlaySound("sounds/physics:explosions:grenade_explosion", contact);
										end;
									end;
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"glassgrenade", 
			"Glass Grenade",
			"shoots a deadly glass frag grenade",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							NoCollision = false,
							FilterProjectileCollisions = true, 
							LifeTime = 3000,
							Model = {
								File = nil,
								Particle = {
									Name = "muzzleflash.LAM.grenade_white",
								},
								Sound = "x",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
							},
							Impulses = {
								Amount = 1,
								Strength = 70,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									--if (t == COLLISION_TIMEOUT) then
										if (t == COLLISION_WATER) then
											Explosion(GetRandom({"explosions.Grenade_SCAR.water"}), toVec(pos.x, pos.y, CryAction.GetWaterInfo(pos)), 8, 25, dir, p.owner, p.OwnerWeapon, 1);
											PlaySound("sounds/physics:explosions:water_explosion_small", contact);
										else
											Explosion(GetRandom({"explosions.Grenade_SCAR.concrete"}), contact, 8, 25, dir, p.owner, p.OwnerWeapon, 1);
											PlaySound("sounds/physics:explosions:grenade_explosion", contact);
										end;
									--end;
								end,
							},
						};
					}));
				end 
			}
		);
		
		self:AddWeapon(
			"mine", 
			"SeaMine",
			"shoots a deadly sea mine",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "objects/library/props/watermine/watermine.cgf", --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 50,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
											{"explosions.warrior.water_wake_sphere",  0.10 },
											{"explosions.mine.seamine",               1.0 },
											{"explosions.Grenade_SCAR.water",         1.0 },
											{"explosions.jet_water_impact.hit",       1.00 }
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
									else
										Explosion(GetRandom({"explosions.jet_explosion.on_fleet_deck";"explosions.mine_explosion.hunter_reveal";"explosions.mine_explosion.door_explosion";"explosions.harbor_airstirke.airstrike_large"; "explosions.harbor_airstirke.airstrike_medium"}), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
									PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1","Sounds/physics:explosions:sphere_cafe_explo_2","Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
								end,
							},
						};
					}));
				end 
			}
		);
		
		self:AddWeapon(
			"megamine", 
			"Mega SeaMine",
			"shoots a deadly sea mine",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "objects/library/props/watermine/watermine.cgf", --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "",
									--Scale = 0.3,
									--Loop = true,
									--Timer = 8
								},
								Sound = "",
								NoServer = false, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = -1,
								Strength = 50,
								AutoAim = true,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
											{"explosions.warrior.water_wake_sphere",  0.10 },
											{"explosions.mine.seamine",               1.0 },
											{"explosions.Grenade_SCAR.water",         1.0 },
											{"explosions.jet_water_impact.hit",       1.00 }
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
									else
										Explosion(GetRandom({"explosions.jet_explosion.on_fleet_deck";"explosions.mine_explosion.hunter_reveal";"explosions.mine_explosion.door_explosion";"explosions.harbor_airstirke.airstrike_large"; "explosions.harbor_airstirke.airstrike_medium"}), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										--PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
									PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1","Sounds/physics:explosions:sphere_cafe_explo_2","Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
								end,
							},
						};
					}));
				end 
			}
		);
		
		self:AddWeapon(
			"chick", 
			"Chick",
			"shoots a deadly mortar Projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "objects/characters/animals/birds/chicken/chicken.cdf", --"Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "bullet.hit_feathers.a",
									Scale = 0.1,
									Loop = true,
									Timer = 0.1
								},
								--Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								Amount = 1,
								Strength = 15,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									Explosion(GetRandom({"bullet.hit_feathers.a"}), contact, 8, 25, dir, p.owner, p.OwnerWeapon, 5);
									PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1"; "Sounds/physics:explosions:sphere_cafe_explo_2"; "Sounds/physics:explosions:sphere_cafe_explo_3"}), pos);
								end,
							},
						};
					}));
				end 
			}
		);
		self:AddWeapon(
			"alienexplo", 
			"Alien Explosion",
			"shoots a deadly glass frag grenade",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({"alien_special.Trooper.death_explosion"}), hit, 1, 1, dir, player, weapon, 0.4);
				end 
			}
		);
		self:AddWeapon(
			"explosion", 
			"Explosion",
			"shoots a deadly glass frag grenade",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({
						"explosions.Grenade_SCAR.backup",
						"explosions.Grenade_SCAR.backup",
						"explosions.Grenade_SCAR.cliff", 
						"explosions.Grenade_SCAR.concrete", 
						"explosions.Grenade_SCAR.explosion",
						"explosions.Grenade_SCAR.soil"
					}), hit, 3, 100, dir, player, weapon, 1)
					PlaySound("sounds/physics:explosions:grenade_launcher_explosion", hit)
				end 
			}
		);
		self:AddWeapon(
			"light", 
			"Light Explosion",
			"shoots a deadly glass frag grenade",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({
						"explosions.light.portable_light"
					}), hit, 3, 100, dir, player, weapon, 1)
					-- PlaySound("sounds/physics:explosions:grenade_launcher_explosion", hit)
				end 
			}
		);
		self:AddWeapon(
			".50", 
			".50 Caliber",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					SpawnEffect("bullet.hit_rock.b_dusty", hit, hitNormal, 0.8);
					PlaySound("sounds/physics:bullet_impact:mat_concrete_50cal", hit);
				end 
			}
		);
		self:AddWeapon(
			"supermortar", 
			"Super MORTAR",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({"explosions.mine.harbor_mortar_start"}), hit, 8, 25, hitNormal, player, weapon, 1);
					PlaySound("sounds/physics:explosions:claymore_explosion", hit);
				end 
			}
		);
		self:AddWeapon(
			"megamortar", 
			"Mega MORTAR",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({"explosions.mine.harbor_mortar_start"}), hit, 15, 1000, hitNormal, player, weapon, 5);
					PlaySound("sounds/physics:explosions:claymore_explosion", hit);
				end 
			}
		);
		self:AddWeapon(
			"melonapo", 
			"Melon Apo",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					if (not weapon.busyTime or _time - weapon.busyTime >= 1) then
						weapon.busyTime = _time;
						local pos = hit;
						local rad = 7;
						pos.z = pos.z + 15;
						for tc = 1, 25 do
							Script.SetTimer(tc*80, function()
								local delMe = SpawnGUILimit("Objects/Library/Props/food/melon/melon.cgf", { x = pos.x + math.random(-rad,rad), y = pos.y + math.random(-rad,rad), z = pos.z }, 25, math.random(50,300)/100, nil, nil, nil, 200);
								delMe:AwakePhysics(1);
								delMe:SetScale(math.random(1,5));
								delMe.oneHitKill = true;
								delMe.owner = shooter;
								Script.SetTimer(5000, function()
									System.RemoveEntity(delMe.id);
								end)
							end);
						end;
					end;
				end 
			}
		);
		self:AddWeapon(
			"ballapo", 
			"Ball Apo",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					if (not weapon.busyTime or _time - weapon.busyTime >= 1) then
						weapon.busyTime = _time;
						local pos = hit;
						local rad = 7;
						pos.z = pos.z + 15;
						for tc = 1, 25 do
							Script.SetTimer(tc*80, function()
								local delMe = SpawnGUILimit("objects/library/architecture/aircraftcarrier/props/misc/golfball.cgf", { x = pos.x + math.random(-rad,rad), y = pos.y + math.random(-rad,rad), z = pos.z }, 25, math.random(50,300)/100, nil, nil, nil, 200);
								delMe:AwakePhysics(1);
								delMe:SetScale(math.random(12,35));
								delMe.oneHitKill = true;
								delMe.owner = shooter;
								Script.SetTimer(5000, function()
									System.RemoveEntity(delMe.id);
								end)
							end);
						end;
					end;
				end 
			}
		);
		self:AddWeapon(
			"flare", 
			"Flare",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					SpawnEffect(ePE_Flare, pos, dir)
				end 
			}
		);
		self:AddWeapon(
			"melon", 
			"Melon",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local delMe = SpawnGUILimit("Objects/Library/Props/food/melon/melon.cgf", add2Vec(pos, vecScale(dir, 3)), 25, math.random(50,300)/100, nil, nil, nil, 200);
					delMe:AwakePhysics(1);
					delMe:AddImpulse(-1, delMe:GetPos(), dir, 5000, 1)
					delMe.oneHitKill = true;
					delMe.owner = shooter;
					Script.SetTimer(6000, function()
						System.RemoveEntity(delMe.id);
					end)
				end 
			}
		);
		self:AddWeapon(
			"banana", 
			"Banana",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local delMe = SpawnGUILimit("objects/natural/bananas/banana.cgf", add2Vec(pos, vecScale(dir, 3)), 25, math.random(50,300)/100, nil, nil, nil, 200);
					delMe:AwakePhysics(1);
					delMe:AddImpulse(-1, delMe:GetPos(), dir, 100, 1)
					delMe.oneHitKill = true;
					delMe.owner = shooter;
					Script.SetTimer(25000, function()
						System.RemoveEntity(delMe.id);
					end)
				end 
			}
		);
		self:AddWeapon(
			"trash", 
			"Trash Gun",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local delMe = SpawnGUILimit(GetRandom({
						"objects/library/props/food/melon/melon.cgf";
						"objects/library/props/trashbins/trashbin.cgf";
						"objects/library/props/school/table_b.cgf";
						"objects/library/props/misc/cooker/cooker.cgf";
						"objects/library/props/flowers/flowerpot_harbour_a.cgf";
						"objects/library/props/flowers/flowerpot_harbour_l_a_pink.cgf";
						"objects/library/props/flowers/flowerpot_harbour_s_a_white.cgf";
						"objects/library/props/kable_drum_wooden/kable_drum_wooden_b.cgf";
						"objects/library/props/electronic_devices/computer_racks/flightcase_small_open.cgf";
						"objects/library/storage/palettes/palettes_pack_big_mp.cgf";
						"objects/library/props/building material/wooden_shelves.cgf";
						"Objects/Library/storage/trashcontainers/trashbag.cgf";
						"objects/library/props/building material/steel_beam_pack.cgf";
					}), add2Vec(pos, vecScale(dir, 3)), 25, math.random(50,300)/100, nil, nil, nil, 200);
					delMe:AwakePhysics(1);
					delMe:AddImpulse(-1, delMe:GetPos(), dir, 5000, 1)
					delMe.oneHitKill = true;
					delMe.owner = shooter;
					Script.SetTimer(6000, function()
						System.RemoveEntity(delMe.id);
					end)
				end 
			}
		);
		self:AddWeapon(
			"weapon", 
			"Equipment Gun",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local aRandom = GetRandom({
						[1] = { "SMG", "smgbullet" },
						[2] = { "SCAR", "bullet" },
						[3] = { "FY71", "fybullet" },
						[4] = { "GaussRifle", "gaussbullet" },
						[5] = { "LAW", "rocket" },
						[6] = { "C4", "c4explosive" },
						[7] = { "DSG1", "sniperbullet" },
						[8] = { "RadarKit", "nil" },
						[9] = { "LockpickKit", "nil" },
						[10] = { "RepairKit", "nil" },
						[11] = { "SOCOM", "nil" },
						[12] = { "Claymore", "nil" },
						[13] = { "AVMine", "nil" },
						[14] = { "GrenadeLauncher", "nil" },
						[15] = { "LAMRifle", "nil" },
						[16] = { "Silencer", "nil" },
						[17] = { "LAMRifleFlashLight", "nil" },
						[18] = { "LAM", "nil" },
						[19] = { "LAMFlashLight", "nil" },
					})
					
					local hItem = System.SpawnEntity({ class = aRandom[1], position = add2Vec(pos, vecScale(dir, 3)), name = aRandom[1] .. g_utils:SpawnCounter(), fMass = 100, properties = { count =  100, AmmoName = "smgbullet",  bPhysics = 1, objModel = "Objects/weapons/us/smg/smg_tp.cgf" }})
					hItem:AddImpulse(-1, hItem:GetCenterOfMassPos(), dir, 5000, 1)
					g_gameRules.game:ScheduleEntityRemoval(hItem.id, 10, false)
					return true
				end 
			}
		);
		self:AddWeapon(
			"vehicle", 
			"Vehicle Gun",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					if (timerexpired(weapon.LastCarSpawn, 1)) then
					
						local aRandom = GetRandom({
							[1] = { "Civ_car1", 35000 },
							[2] = { "US_tank",500000 },
							[3] = { "US_vtol", 500000 },
							[4] = { "Asian_tank", 500000 },
							[5] = { "Asian_truck", 60000 },
							[7] = { "US_ltv", 30000 },
							[8] = { "Asian_apc", 500000 },
							[9] = { "US_apc", 500000 },
						})
						Script.SetTimer(1,function()
							local hVehicle = System.SpawnEntity({ name = "Random-Vehicle-%d", class = aRandom[1], orientation = dir, position = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) })
							hVehicle:AddImpulse(-1, hVehicle:GetCenterOfMassPos(), dir, aRandom[2], 1)
						end)
						
						weapon.LastCarSpawn = timerinit()
					end
				end 
			}
		);
		self:AddWeapon(
			"fly", 
			"Jetpack Gun",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					player:AddImpulse(-1, player:GetPos(), vecScale(dir, -1), 2000, 1)
				end 
			}
		);
		self:AddWeapon(
			"lightning", 
			"Lightning",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local p2 = hit; --collInf.pos;
					p2.z = p2.z + 26;

					local r = math.random;
					
					for i=1, 2 do
						Script.SetTimer(i*400, function()
							local rpos = {x=p2.x+r(-5,5),y=p2.y+r(-5,5),z=p2.z};
							g_gameRules:CreateExplosion(player.id,weapon.id,0,rpos,g_Vectors.down,1,45,0,1,"Alien_Environment.Fleet.thundervolt",1, 1, 1, 1);
							rpos.z = rpos.z - 24;
							g_gameRules:CreateExplosion(player.id,weapon.id,0,rpos,g_Vectors.down,1,45,3500,1,"Alien_Environment.Fleet.thundervolt_hit",r(0.8,1.5), 1, 1, 1);
						end);
					end;
					
					for i=1, 25 do
						Script.SetTimer(i*200, function()
							local rpos = {x=p2.x+r(-5,5),y=p2.y+r(-5,5),z=p2.z-24};
							g_gameRules:CreateExplosion(player.id,weapon.id,100,rpos,g_Vectors.down,6,45,5000,1,"",r(0.8,1.5), 1, 1, 1);
						end);
					end;
					
					local s = System.SpawnEntity({class="OffHand", position = p2, name = "thunderSound_"..g_utils:SpawnCounter()});
					
					ExecuteOnAll([[for i=0,15 do Script.SetTimer(i*math.random(150,280),function()HE(eCE_Sound,"]]..s:GetName()..[[","Sounds/physics:explosions:explo_rocket")end)end;for i=1,25 do Script.SetTimer(i*200,function()HE(eCE_Sound,"]]..s:GetName()..[[","Sounds/environment:fleet_v2:distant_thunder");end);end;]])
				
					Script.SetTimer(25*200 + 3000, function()
						System.RemoveEntity(s.id);
					end)
				end 
			}
		);
		self:AddWeapon(
			"ball", 
			"Ball",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local delMe = SpawnGUILimit("objects/library/architecture/aircraftcarrier/props/misc/golfball.cgf", add2Vec(pos, vecScale(dir, 3)), 25, math.random(50,300)/100, nil, nil, nil, 200);
					delMe:AwakePhysics(1);
					delMe:SetScale(GetRandom(12,26))
					delMe:AddImpulse(-1, delMe:GetPos(), dir, 5000, 1)
					delMe.oneHitKill = true;
					delMe.owner = shooter;
					Script.SetTimer(6000, function()
						System.RemoveEntity(delMe.id);
					end)
				end 
			}
		);
		self:AddWeapon(
			"gardener", 
			"Gardener",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					local models = {
						"Objects/natural/trees/banana_tree/bananatree_big_a.cgf",
						"Objects/natural/trees/banana_tree/bananatree_big_b.cgf",
						"objects/natural/trees/banana_tree/bananatree_med_a.cgf",
						"objects/natural/trees/banana_tree/bananatree_med_b.cgf",
						"objects/natural/trees/banana_tree/bananatree_old_a.cgf",
						"objects/natural/trees/banana_tree/bananatree_old_b.cgf",
						"objects/natural/trees/banana_tree/bananatree_small_a.cgf",
						"objects/natural/trees/banana_tree/bananatree_small_b.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_a.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_b.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_c.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_d.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_e.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_f.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_g.cgf",
						"objects/natural/trees/palm_tree/palm_tree_large_h.cgf",
						"objects/natural/trees/river_tree/river_tree_a.cgf",
						"objects/natural/trees/river_tree/river_tree_b.cgf",
						"objects/natural/trees/river_tree/river_tree_c.cgf",
						"objects/natural/trees/twisted_tree/twisted_tree_a.cgf",
						"objects/natural/trees/twisted_tree/twisted_tree_b.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_a.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_b.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_c.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_d.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_e.cgf",
						"objects/natural/trees/jungle_tree_thin/jungle_tree_thin_f.cgf",
						"objects/natural/trees/jungle_tree_large/jungle_tree_large_big_bright_green.cgf",
						"objects/natural/trees/jungle_tree_large/jungle_tree_large_med_noleaves_b.cgf",
						"objects/natural/trees/jungle_tree_large/jungletree_saw.cgf",
						"objects/natural/trees/jungle_tree_large/jungle_tree_large_big_grey_green_360_deg.cgf",
						"objects/natural/trees/jungle_tree_large/jungle_tree_large_med_bright_green.cgf",
						"objects/natural/trees/jungle_tree_large/jungle_tree_large_big_yellow.cgf",
					}
					
					local melon = SpawnGUILimit(models[math.random(#models)], hit, -1, math.random(30,300)/100, hitNormal, nil, nil, 1000);
					--melon:SetDirectionVector(player:GetDirectionVector())
					melon.owner = player;
					Script.SetTimer(6000, function()
						System.RemoveEntity(melon.id)
					end);
				end 
			}
		);
		self:AddWeapon(
			"flak", 
			"Flak",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					Explosion(GetRandom({"explosions.AA_flak.soil"}), hit, 8, 25, hitNormal, player, weapon, 1);
					PlaySound("sounds/physics:explosions:claymore_explosion", hit);
				end 
			}
		);
		self:AddWeapon(
			"selfdestruction", 
			"Self Destruction",
			"does something",
			{ 
				OnHit = function(self, hit)
					local target, shooter = hit.target, hit.shooter;
					if (target and shooter and target.id ~= shooter.id) then
						if (target.selfDestructing) then
							return;
						else
							target.selfDestructing = true;
							ExecuteOnAll([[ATOMClient:HandleEvent(eCE_Sound,']]..target:GetName()..[[','sounds/interface:multiplayer_interface:mp_vehicle_alarm');]]);
							Script.SetTimer(5000, function()
								g_gameRules:CreateExplosion(shooter.id,shooter.id,1500,target:GetPos(),g_Vectors.up,5,45,1500,1,"explosions.small_fuel_tank.gas",3, 1, 1, 1);
								target.selfDestructing = false;
							end);
						end;
					end;
				end;
			}
		);
		self:AddWeapon(
			"disolve", 
			"Disolve",
			"does something",
			{ 
				OnHit = function(self, hit)
					local target, shooter = hit.target, hit.shooter;
					if (target and shooter and target.id ~= shooter.id) then
						if (not target.disolving) then
							target.disolving = true
							hit.damage = 0;
							ExecuteOnAll([[ATOMClient:HandleEvent(eCE_LoadEffect, ']]..target:GetName()..[[','misc.electric_man.disolve',1,1,1,5);]])
							Script.SetTimer(6000, function()
								target.disolving = false
								HitEntity(target, 9999, shooter)
							end)
						end
					end;
				end;
			}
		);
		self:AddWeapon(
			"impulse", 
			"Impulse",
			"does something",
			{
				OnItemHit = function(self, hit, hItem)
					hItem:AddImpulse(-1, hit.pos, hit.dir, hItem:GetMass() * 25, 1)
				end,
				OnHit = function(self, hit)
					local target = hit.target
					local player = hit.shooter
					
					if (target and player and target.id ~= player.id) then
						target:AddImpulse(-1, hit.pos, hit.dir, target:GetMass() * 25, 1)
					end
				end 
			}
		);
		self:AddWeapon(
			"magnet", 
			"Magnet",
			"does something",
			{ 
				OnHit = function(self, hit)
					local target = hit.target;
					local player = hit.shooter;
					
					if (target and player and target.id ~= player.id) then
						target:AddImpulse(-1, hit.pos, vecScale(hit.dir,-1), target:GetMass() * 25, 1);
					end;
				end 
			}
		);
		self:AddWeapon(
			"impbomb", 
			"Impulse Bomb",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 1, 5 do
						Script.SetTimer(i * 1000, function()
							if (i == 5) then
								g_utils:SpawnEffect("alien_special.scout.ScoutExplosion", hit, g_Vectors.up, 1);
								g_utils:CreateImpulseExplosion(hit, 50, -1, 3700);
							else
								g_utils:SpawnEffect(ePE_Flare, hit, g_Vectors.up, 1);
							end;
						end);
					end;
				end
			}
		);
		self:AddWeapon(
			"magbomb", 
			"Magnet Bomb",
			"does something",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					for i = 1, 5 do
						Script.SetTimer(i * 1000, function()
							if (i == 5) then
								g_utils:SpawnEffect("alien_special.scout.ScoutExplosion", hit, g_Vectors.up, 1);
								g_utils:CreateImpulseExplosion(hit, 50, 1, 3700);
							else
								g_utils:SpawnEffect(ePE_Flare, hit, g_Vectors.up, 1);
							end;
						end);
					end;
				end
			}
		);
	end,
	-----------------------
	-- AddWeapon
	-----------------------
	AddWeapon = function(self, name, normalName, desc, funcs, props)
		if (self:GetItem(name)) then
			return false, ATOMLog:LogError("Attempt to add duplicated gun to AddWeapon(\"%s\")", name);
		end;
		self.Guns[name] = 
		{
		
			OnShoot		= (funcs and funcs.OnShoot 		or nil),
			OnHit		= (funcs and funcs.OnHit 		or nil),
			OnEnabled	= (funcs and funcs.OnEnabled 	or nil),
			OnDisabled	= (funcs and funcs.OnDisabled 	or nil),
			
			Desc		= desc or "No Description",
			
			Props		= props or {},
		};
		--table.insert(self.GunsList, normalName);
		table.insert(self.GunsList, { normalName,  name });
	end,
	-----------------------
	-- GetItem
	-----------------------
	GetItem = function(self, name)
		return self.Guns[name];
	end,
	-----------------------
	-- OnHit
	-----------------------
	OnHit = function(self, hit)
		if (hit) then
			local weapon = hit.weapon;
			if (weapon) then
			--	weapon.SpecialGun = "onehit"
				if (weapon and weapon.SpecialGun and self:GetItem(weapon.SpecialGun)) then
					self:ProcessHit(weapon, self:GetItem(weapon.SpecialGun), hit);
				end
			end
		end
	end,
	-----------------------
	-- ProcessHit
	-----------------------
	ProcessHit = function(self, weapon, funcs, hit)
		if (funcs.OnHit) then
			local s, e = pcall(funcs.OnHit, weapon, hit);
			if (not s and e) then
				ATOMLog:LogError("OnHit for %s Failed ($4%s$9)", weapon.SpecialGun, tostr(e))
			end
		end
	end,
	-----------------------
	-- Onshoot
	-----------------------
	OnShoot = function(self, shooter, weapon, ...)
		if (shooter and weapon) then
		--	weapon.SpecialGun = "onehit"
			local vehicle = shooter.GetVehicle and shooter:GetVehicle();
			if (weapon and weapon.SpecialGun and self:GetItem(weapon.SpecialGun)) then
				self:ProcessShot(weapon, self:GetItem(weapon.SpecialGun), shooter, ...);
			elseif (vehicle and vehicle.SpecialGun and self:GetItem(vehicle.SpecialGun)) then
				self:ProcessShot(weapon, self:GetItem(vehicle.SpecialGun), shooter, ...);
			end;
		end;
	end,
	-----------------------
	-- ProcessShot
	-----------------------
	ProcessShot = function(self, weapon, funcs, shooter, ...)
		if (funcs.OnShoot) then
			local s, e = pcall(funcs.OnShoot, shooter, weapon, ...);
			if (not s and e) then
				ATOMLog:LogError("OnShoot for %s Failed ($4%s$9)", weapon.SpecialGun, tostr(e))
			end;
		end;
	end,
	-----------------------
	-- OnMelee
	-----------------------
	OnMelee = function(self, player, pos, dir, isWeapon, seq)
		local weapon = player:GetCurrentItem();
		if (player and weapon) then
			local hitPos = player:GetHitPos(1024) or { pos = player:GetPosInFront(1024) };
			local vehicle = player.GetVehicle and player:GetVehicle();
			local gunInfo = self:GetItem(weapon.SpecialGun);
			--Debug("ok",gunInfo)
			if (gunInfo and not gunInfo.Props.NoMelee) then
				if (weapon and weapon.SpecialGun and gunInfo) then
					self:ProcessShot(weapon, gunInfo, player, pos, dir, hitPos.pos, g_Vectors.up, GetDistance(hitPos.pos, pos), false);
				elseif (vehicle and vehicle.SpecialGun and self:GetItem(vehicle.SpecialGun)) then
					self:ProcessShot(weapon, gunInfo, player, pos, dir, hitPos.pos, g_Vectors.up, GetDistance(hitPos.pos, pos), false);
				end;
			end;
		end;
	end,
	-----------------------
	-- GetGun
	-----------------------
	GetGun = function(self, name)
		local res = {};
		name = name:gsub("_", " ");
		for i, v in pairs(self.GunsList) do
			if (v[1]:lower() == name:lower()) then
				return v[2], v[1];
			elseif (v[1]:lower():find(name:lower())) then
			--	Debug("Found",v[2],"+",v[1])
				table.insert(res, { v[2], v[1] });
			end;
			--Debug(v[1],v[2])
		end;
		if (arrSize(res) == 1) then
			return res[1][1], res[1][2];
		end;
		return;
		--return (arrSize(res) == 1 and () or nil);
	end,
	-----------------------
	-- GetGunCount
	-----------------------
	GetGunCount = function(self)
		return arrSize(self.Guns);
	end,

};

GunSystem:OnInit();


--[[

self:AddWeapon(
			"hellfire", 
			"HellFire Gun",
			"shoots a deadly helicopter projectile",
			{ 
				OnShoot = function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain)
					ATOMItems:AddProjectile({
						Owner = player,
						Weapon = weapon,
						Pos = pos,
						Dir = dir,
						Hit = hit,
						Normal = hitNormal,
						Properties = {
							UnderwaterMissile = false, -- If true, projectile wont collide on water
							Collision = {
								Water = 0.3,
								Ground = 0.3,
							},
							LifeTime = 30000, -- Lifetime in milliseconds
							Model = {
								File = "Objects/weapons/us/frag_grenade/frag_grenade_tp.cgf",
								Dir = nil,
								Particle = {
									Scale = 1,
									Name = "smoke_and_fire.weapon_stinger.FFAR",
									Loop = false, -- use pulse period on effect
									Timer = 0, -- Effect pulse period
								},
								Sound = "sounds/physics:bullet_whiz:missile_whiz_loop",
								Mass = 10,
							},
							Impulses = {
								AutoAim = true, -- Projectile flys wherever player is currently aiming
								First = { -- first impulse applied
									Use = false,
									Dir = dir,
									Strength = 1000,
								},
								Delay = 0, -- delay in seconds
								Amount = -1, -- amount of impulses
								Timer = 0, -- timer between each impulse
								Strength = 100, -- strength of the impulses applied
								LockedTarget = nil,
							},
							Events = {
								Spawn = function(p)
								
								end,
								Collide = function(p, t, pos)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", pos, 10, 500);
										PlaySound("sounds/physics:explosions:water_explosion_medium", pos);
									end;
									if (t == COLLISION_GROUND) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), pos, 10, 500);
										PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", pos);
									end;
									if (t == COLLISION_RAY) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), pos, 10, 500);
										PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", pos);
									end;
									if (t == COLLISION_TIMEOUT) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), pos, 10, 500);
										PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", pos);
									end;
									if (t == COLLISION_HIT) then
										Explosion(GetRandom({"explosions.rocket.generic", "explosions.rocket.concrete"}), pos, 10, 500);
										PlaySound("Sounds/physics:explosions:missile_helicopter_explosion", pos);
									end;
								end,
							},
						},
					});
				end 
			}
		);
		
		--]]