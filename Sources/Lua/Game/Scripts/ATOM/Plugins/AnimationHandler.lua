ATOMAnimations = { -- Please don't steal this nCX, please ask before copying this idea :)
	cfg = {
		System = true,
		GameRules = {
			["PowerStruggle"] = true,
			["InstantAction"] = false,
		},
		IfPlayersNear = false, -- Only play animations if other players are near
		Animations = {
			KickDeadBody = {
				Use = true,
				{
					Rifle = { "combat_deadBodyKick_rifle_01", "combat_deadBodyKick_rifle_02", "combat_deadBodyKick_rifle_03" },
				},
			},
			Prone = {
				Use = true,
				{
					--Sniper = { "" },
					Pistol = { "prone_idle_pistol_01", "prone_idle_pistol_02", "prone_idle_pistol_03", "prone_idle_pistol_04" }, -- SOCOM
					Rifle = { "prone_idle_rifle_01", "prone_idle_rifle_02", "prone_idle_rifle_03" }, -- Rifle
					Fist = { "prone_idle_nw_01", "prone_idle_nw_02", "prone_idle_nw_03", "prone_idle_nw_04" } -- Fists
				}, -- = [1]
			},
			Stand = {
				Use = true,
				{
					Minigun = { "combat_idle_mg_01", "combat_idle_mg_02", "combat_idle_mg_03", "combat_idle_mg_04" }, -- Minigun
					Sniper = { "combat_sniperIdle_rifle_01", "combat_guard_rifle_01" }, -- Sniper
					Pistol = { "combat_idle_pistol_01", "combat_idle_pistol_02", "combat_idle_pistol_03", "combat_idle_pistol_04" }, -- SOCOM
					Rifle = { "combat_idle_rifle_01", "combat_idle_rifle_02", "combat_idle_rifle_03", "combat_idle_rifle_04", "combat_guard_rifle_01" }, -- Rifle
					Rocket = { "combat_idleAimBlockPoses_rocket_01" },
					
					Leaning = {
						Fist = {
							Left = { "combat_peekIdle_nw_left_01" },
							Right = { "combat_peekIdle_nw_right_01" },
						};
						Rifle = {
							Left = { "combat_peekIdle_rifle_left_01" },
							Right = { "combat_peekIdle_rifle_right_01" },
						};
						Pistol = {
							Left = { "combat_peekIdle_pistol_left_01" },
							Right = { "combat_peekIdle_pistol_right_01" },
						};
						
					};
					--Fist = { "" } -- Fists -- Now 'Idle' category
				}, -- = [1]
			},
			Crouch = {
				Use = true,
				{
				
					Cloaked = { 
						Minigun = { "stealth_idle_mg_01", "stealth_idle_mg_02", "stealth_idle_mg_03", "stealth_idle_mg_04" },
						Fist = { "stealth_idle_nw_01", "stealth_idle_nw_02", "stealth_idle_nw_03", "stealth_idle_nw_04" },
						Pistol = { "stealth_idle_pistol_01", "stealth_idle_pistol_02", "stealth_idle_pistol_03", "stealth_idle_pistol_04" },
						Rifle = { "stealth_idle_rifle_01", "stealth_idle_rifle_02", "stealth_idle_rifle_03", "stealth_idle_rifle_04" },
					},
					Minigun = { "stealth_idle_mg_01", "stealth_idle_mg_02", "stealth_idle_mg_03", "stealth_idle_mg_04", --[[!!!!]] "crouch_idle_mg_01", "crouch_idle_mg_02", "crouch_idle_mg_03", "crouch_idle_mg_04" }, -- Minigun
					--Sniper = { "combat_sniperIdle_rifle_01" }, -- Sniper
					Pistol = { "stealth_idle_pistol_01", "stealth_idle_pistol_02", "stealth_idle_pistol_03", "stealth_idle_pistol_04", --[[!!!!]] "crouch_idle_pistol_01", "crouch_idle_pistol_02", "crouch_idle_pistol_03", "crouch_idleKnee_pistol_01", "crouch_idleKnee_pistol_02", "crouch_idleKnee_pistol_03" }, -- SOCOM
					Rifle = { "stealth_idle_rifle_01", "stealth_idle_rifle_02", "stealth_idle_rifle_03", "stealth_idle_rifle_04", --[[!!!!]]"crouch_listening_rifle_01", "crouch_talk_rifle_01", "crouch_idle_rifle_01", "crouch_idle_rifle_02", "crouch_idle_rifle_03", "crouch_idle_rifle_04", "crouch_idleKnee_rifle_01", "crouch_idleKnee_rifle_02", "crouch_idleKnee_rifle_03", "crouch_idleKnee_rifle_04" }, -- Rifle
					Fist = { "stealth_idle_nw_01", "stealth_idle_nw_02", "stealth_idle_nw_03", "stealth_idle_nw_04", --[[!!!!]] "crouch_idle_nw_01", "crouch_idle_nw_02", "crouch_idle_nw_03", "crouch_idle_nw_04", "crouch_idleKnee_nw_02", "crouch_idleKnee_nw_03", "crouch_idleKnee_nw_04" } ,-- Fists
					
					Leaning = {
						Fist = {
							Left = { "crouch_peekIdle_nw_left_01" },
							Right = { "crouch_peekIdle_nw_right_01" },
						};
						Rifle = {
							Left = { "crouch_peekIdle_rifle_left_01" },
							Right = { "crouch_peekIdle_rifle_right_01" },
						};
						Pistol = {
							Left = { "crouch_peekIdle_pistol_left_01" },
							Right = { "crouch_peekIdle_pistol_right_01" },
						};
						
					};
				}, -- = [1]
			},
			Air = { -- !!WIP
				Use = true,
				{
					Fly = { "" },
					Fall = { 
						Ground = { "parachute_diveHeadUp_nw_01" }, -- over ground
						Water = { "parachute_fallWater_nw_01" }, -- over water
					},
					FreeFall = {
						Close = { "parachute_signalBackOff_nw_01" }, -- if close to ground
						Far = { 
							Ground = { "parachute_diveHeadUp_nw_01" }, -- over ground
							Water = { "parachute_fallWater_nw_01" }, -- over water
						}, -- if far away from ground
					},
					Parachute = { "" },
				}, -- = [1]
			},
			Stagger = { -- !!WIP
				Use = true,
				{
					Stand = {
						Fist = { "combat_fearFront_nw_01", "combat_fearFront_nw_02" }, 
						Rifle = { "combat_fearFront_rifle_01", "combat_fearFront_rifle_02", "combat_flinch_rifle_01" }, 
						Pistol = { "combat_fearFront_pistol_01", "combat_fearFront_pistol_02" }, 
					},
					Crouch = {
						Cloaked = { 
							Rifle = { "stealth_flinch_rifle_01" },
						},
						--Fist = { "combat_fearFront_nw_01", "combat_fearFront_nw_02" }, 
						Rifle = { "stealth_flinch_rifle_01", "crouch_flinch_rifle_01", "crouch_flinch_rifle_02", "combat_flinch_rifle_01" }, 
						--Pistol = { "combat_fearFront_pistol_01", "combat_fearFront_pistol_02" }, 
					},
					--Prone = {
					--	Fist = { "combat_fearFront_nw_01", "combat_fearFront_nw_02" }, 
					--	Rifle = { "combat_fearFront_rifle_01", "combat_fearFront_rifle_02", "combat_flinch_rifle_01" }, 
					--	Pistol = { "combat_fearFront_pistol_01", "combat_fearFront_pistol_02" }, 
					--},
				}, -- = [1]
			},
			Vehicle = {
				Use = true,
				{
					Repair = { -- if player is facing a damaged vehicle
						Stand = { "relaxed_cleaningBoatArgument_01", "relaxed_cleaningBoatLoop_01", "relaxed_repairGeneric_hammer_01", "relaxed_repairGeneric_hammer_02", "relaxed_repairGeneric_screwdriver_01", },
						Crouch = { "relaxed_repairGenericCrouch_hammer_01", "relaxed_repairGenericCrouch_screwdriver_01", "relaxed_repairGenericCrouch_screwdriver_02", "relaxed_repairGenericCrouch_screwdriver_03", },
					},
					Inside = {
					
					},
				},
			},
			Idle = {
				Use = true,
				{
					--Sniper = { "" }, -- Sniper
					--Pistol = { "" }, -- SOCOM
					--Rifle = { "" }, -- Rifle
					--Fist = { "" } -- Fists
					Leaning = {
						"relaxed_idleFootOnWallLoop_nw_01",
					--	"relaxed_idleFootOnWallLoop_nw_02" -- too short
					},
					Standing = {
						"relaxed_idleCheckingWatch_01",
						"relaxed_idleChinrub_01", "relaxed_idleChinrub_02", "relaxed_idleChinrub_03",
						"relaxed_idleClaphands_01",
						"relaxed_idleDawdling_nw_01",
						"relaxed_idleDrummingOnLegs_nw_01",
						"relaxed_idleHeadScratch_01","relaxed_idleHeadScratch_02","relaxed_idleHeadScratch_03","relaxed_idleHeadScratch_04","relaxed_idleHeadScratch_05",
						"relaxed_idleInsectSwat_leftHand_01","relaxed_idleInsectSwat_leftHand_02",
						"relaxed_idleKickDust_01","relaxed_idleKickStone_01",
						"relaxed_idleListening_01","relaxed_idleListening_02","relaxed_idleListening_03",
						"relaxed_idlePickNose_nw_01",
						"relaxed_idleRubKnee_01", "relaxed_idleRubNeck_01",
						"relaxed_idleScratchbutt_01","relaxed_idleScratchNose_nw_01",
						"relaxed_idleShift_01","relaxed_idleShift_01",
						"relaxed_idleShoulderShrug_01","relaxed_idleShoulderShrug_02","relaxed_idleShoulderShrug_03",
						"relaxed_idleSmokeDrag_cigarette_01","relaxed_idleSmokeDrag_cigarette_02",
						"relaxed_idleTappingFoot_01",
						"relaxed_idleTeetering_nw_01",
						"relaxed_idleTieLaces_01",
						"relaxed_idleYawn_nw_01",
						"relaxed_readIdle_book_01",
						--"relaxed_salute_nw_01","relaxed_saluteLazyCO_nw_01",
						"relaxed_standIdleHandsBehindCOLoop_01",
						"relaxed_standIdleHandsBehindCOLoop_01", "relaxed_standIdleHandsBehindCOLoop_02",
						--
						"usCarrier_lsoWatchingPlanes_nw_01",
						"usCarrier_flightSignal_nw_13",
					},
				}, -- = [1]
			},
			HelloAdmin = { -- Used when a player with higher access approches a player with lesser access
				Use = true,
				Anims = {
					"relaxed_salute_nw_01", "relaxed_saluteLazyCO_nw_01", 
				},
			},
			Radio = {
				Use = true,
				{
					Help = { "combat_callReinforcements_nw_01", "combat_callReinforcements_nw_02" },
					Other = { "combat_idleFranticRadio_rifle_01", "combat_idleFranticRadio_rifle_02", "cineFleet_manTalkingOnCBFranticLoop_radioHandset_01"},
					Follow = {
						Rifle = { "stealth_signalFollowUB_rifle_01", "cineSphere_ab3_MarineWavesIntoVTOLLoop_01", },
						Pistol = { "stealth_signalFollowUB_pistol_01", "cineSphere_ab3_MarineWavesIntoVTOLLoop_01" },
					};
				},
			},
			Weapons = {
				Use = true,
				{
					DSG1 = { "combat_sniperFire_rifle_01" },
				},
			},
		},
	},
	----------------
	-- Init
	----------------
	Init = function(self)
		--Debug("1")
		if (Config and Config.ATOM and Config.ATOM.Immersion) then
			self.cfg = mergeTables(self.cfg, Config.ATOM.Immersion.Animations);
		end;
		
		if (not self.cfg.System or not self.cfg.GameRules[g_gameRules.class]) then
			return false;
		end;

		--Debug("2")
	
		RegisterEvent("QTick", self.UpdateAll, 'ATOMAnimations');
		RegisterEvent("OnExplosion", self.OnExplosion, 'ATOMAnimations');
		RegisterEvent("CanSendRadio", self.OnRadio, 'ATOMAnimations');
		-- RegisterEvent("OnShoot", self.OnShoot, 'ATOMAnimations'); -- Dropped
	end,
	----------------
	-- UpdateAll
	----------------
	UpdateAll = function(self)

		if (not GetBetaFeatureStatus("idleanim")) then
			return
		end

		if (ANIM_HANDLER == false or self.cfg.System ~= true) then
			return end
			
		for i, player in pairs(GetPlayers()or{}) do
			if (not (player:IsDead() and player:IsSpectating())) then
				self:UpdatePlayer(player);
			end;
		end;
	end,
	----------------
	-- UpdatePlayer
	----------------
	UpdatePlayer = function(self, player)

		if (not GetBetaFeatureStatus("idleanim")) then
			return
		end


		if (not player.ATOM_Client or player.InMeeting or not player.isPlayer or not player.Initialized or player.sitting or player:IsAFK()) then
			return false;
		end;
		
		--Debug("Ok0")
		local playerPos = player:GetPos();
		local plNear = GetPlayersInRange(playerPos, 100, player.id);
		local cfg = self.cfg;
		if (cfg.System == false) then
			return true;
		else
			if (cfg.IfPlayersNear) then
				if (arrSize(plNear) == 0 and not player:HasAccess(DEVELOPER)) then
					return true; -- Safe performance
				end;
			end;
			if (player:IsUnderwater(1)) then
				return true;
			end;
		end;
		
		if (player.hGrabbing or player.bGrabbed) then
			return
		end

		if (player.yoagTime and _time - player.yoagTime < 10) then
			return;
		end;
		
		--Debug("Ok1")
	
		player.LastActivity = player.LastActivity or _time - 999;
		local speed = player.LastTickPos and GetDistance(player, player.LastTickPos)or 1;--player:GetSpeed();
		local vehicle = player:GetVehicle();
		local alive = not (player:IsDead() and player:IsSpectating());
		local stance = player.actorStats.stance;
		local freeFall = player.actorStats.inFreeFall == 1;
		local flying = player.actor:IsFlying();
		local item = player:GetCurrentItem();
		if (item and item.class == "Binoculars") then
			return;
		end;
		local fists = not item or (item.class == "Fists" or item.class == "Binoculars");
		local pistol = not fists and item.class == "SOCOM";
		local rocket = not fists and item.class == "LAW";
		local kit = not fists and (item.class == "RadarKit" or item.class == "RepairKit" or item.class == "LockpickKit");
		local rifle = not fists and not rocket and not pistol;
		local mini = rifle and (item.class == "Hurricane" or item.class == "AlienMount" or item.class == "ShiTen");
		local sniper = rifle and (item.class == "DSG1" or item.class == "GaussRifle");
		local isIdleAnim = stance == STANCE_STAND and fists;
		local NoExtraTime = false;
		local IsLoop = false;
		local onGround = not flying
		local isIdle = (_time - player.iTimeLastMoved > 3) and (onGround and speed == 0) and (_time - player.LastActivity) > (onGround and 8 or -1);
		local isFlying = player.LastTickPos and GetDistance(player, player.LastTickPos, false, false, true) > 1.4;
		local groundDistance = playerPos.z - System.GetTerrainElevation(playerPos);
		local waterPos = CryAction.GetWaterInfo(playerPos);
		local waterDistance = playerPos.z - waterPos
		local willHitWater = waterDistance > groundDistance;
		local hitgroundTime = groundDistance/speed
		local atWall = false;
		local atVehicle = false;
		local vehicleEnt;
		local frozen = g_game:IsFrozen(player.id);
		local lean_r = player:IsLeaning(LEAN_RIGHT);
		local lean_l = player:IsLeaning(LEAN_LEFT);
		local bDeadBody = false
		local vDeadBody = player:CalcSpawnPos(1, -1.6)
		if (table.count(DoGetPlayers({ AllActors = true, except = player.id, pos = vDeadBody, range = 1.8, OnlyDead = true })) > 0) then
			bDeadBody = true
		end
		
		local sWeaponClass = (item and item.class or nil)
		if (sWeaponClass and not player.sLastWeaponClass) then
			player.sLastWeaponClass = sWeaponClass
		end
		
		
		--Debug(player:GetLean())
		
		local stop = false;
		
		if (frozen) then
			stop = true;
		end;
		
		if (vehicle) then
			stop = true;
		end;
		
		if (not alive) then
			stop = true;
		end;
		
		if (stop) then
			return self:StopAll(player)
		end;
		
		if (fists and speed == 0 and player.IdleTime and player.IdleTime > 3) then
			atWall = player:GetHitPos(1, ent_static, player:GetBonePos("Bip01 Pelvis"), vecScale(player:GetBoneDir("Bip01 Pelvis"), -1));
			atWall = atWall and atWall.dist < 0.8;
			if (not atWall) then
				atVehicle = player:GetHitPos(1, ent_rigid+ent_living, nil,nil);
				vehicleEnt = atVehicle and atVehicle.entity;
				atVehicle = atVehicle and atVehicle.entity and atVehicle.entity.vehicle and atVehicle.entity.vehicle:GetRepairableDamage()<100 and atVehicle.dist < 1;
			end;
		end;
		local anims = cfg.Animations;
		local instant=false
		local reset_loop=false
		
		if (isIdle ) then
			local animPack;
			
			player.IdleTime = (player.IdleTime or 0) + 1;
			player.inlean = false;
			if ((not player.LastRadioAnim or _time>player.LastRadioAnim) and (not player.StaggerAnimtime or _time>player.StaggerAnimtime) and (not player.LastFireAnim or _time>player.LastFireAnim)) then
			
				if (onGround) then
					if (fists or kit) then
						if ((lean_r or lean_l) and (stance == STANCE_STAND or stance==STANCE_CROUCH)) then
							animPack = stance == STANCE_STAND and  anims.Stand[1].Leaning.Fist[(lean_r and "Right" or "Left")] or anims.Crouch[1].Leaning.Fist[(lean_r and "Right" or "Left")];
							NoExtraTime = true;
							IsLoop=true
							isIdleAnim = false;
							reset_loop = stance~=player.lastPeekStance or lean_r~=player.LastRightLean
							--Debug(reset_loop)
							--Loop = true;
							player.lastPeekStance=stance;
							player.LastRightLean=lean_r;
							player.inlean = true;
						--	Debug("leaning " .. (lean_r and "R" or "L"))
						elseif (atVehicle and (stance == STANCE_STAND or stance == STANCE_CROUCH)) then
							animPack = stance == STANCE_STAND and anims.Vehicle[1].Repair.Stand or anims.Vehicle[1].Repair.Crouch;
							NoExtraTime = true;
							isIdleAnim = false;
							if (vehicleEnt) then
							--	Debug("Repair ...")
									local hit = {
									shooter = player;
									shooterId = player.id;
									target = vehicleEnt;
									targetId = vehicleEnt.id;
									type = "repair";
									typeId = g_gameRules.game:GetHitTypeId("repair");
									weapon = nil;
									damage = 1;
									radius = 0;
									materialId = 0;
									partId = -1;
									pos = vehicleEnt:GetWorldPos();
									dir = { x=0.0, y=0.0, z=1.0 };
								};
								vehicleEnt.Server.OnHit(vehicleEnt, hit);
							end;
						--	Debug("Repair Vehicle OK")
						elseif (atWall and stance == STANCE_STAND) then
							animPack = anims.Idle[1].Leaning;
							NoExtraTime = true;
						else
							animPack = (stance == STANCE_PRONE and anims.Prone[1].Fist or stance == STANCE_STAND and anims.Idle[1].Standing or stance == STANCE_CROUCH and anims.Crouch[1].Fist);
						end;
						if (player.GuardAnim and stance == STANCE_STAND) then
							animPack = {
								"relaxed_officerHandsBehindListening_01", --player.GuardAnimS or "relaxed_idle_rifle_01", --
							};
							reset_loop = player.sLastWeaponClass ~= sWeaponClass
							IsLoop = true;
						end;
						if (stance == STANCE_STAND) then
							local sayHello = false;
							for i, v in pairs(GetPlayersInRange(playerPos, 7, player.id)or{}) do
								if (v:HasAccess(ADMINISTRATOR)) then
									sayHello = true;
									break;
								end;
							end;
							if (sayHello and player.IdleTime>2) then
								if (not player.SaidHello) then
									player.SaidHello = true;
									isIdleAnim = false;
									player.AnimationTime = nil;
									animPack = anims.HelloAdmin.Anims;
									--Debug("PACK",animPack,"!",anims.HelloAdmin.Anims)
									--Debug(player:GetName()," says Salute!!!!");
								end;
							elseif (not sayHello and player.SaidHello) then
							--	Debug(player:GetName()," says bye fucker")
								player.SaidHello = false;
							end;
						end;
					elseif (rifle and (lean_r or lean_l) and (stance == STANCE_STAND or stance==STANCE_CROUCH)) then
							animPack = stance == STANCE_STAND and  anims.Stand[1].Leaning.Rifle[(lean_r and "Right" or "Left")] or anims.Crouch[1].Leaning.Rifle[(lean_r and "Right" or "Left")];
							NoExtraTime = true;
							IsLoop=true
							isIdleAnim = false;
							reset_loop = stance~=player.lastPeekStance or lean_r~=player.LastRightLean
							--Debug(reset_loop)
							--Loop = true;
							player.lastPeekStance=stance;
							player.LastRightLean=lean_r;
							--Debug("RIFLE !!! leaning " .. (lean_r and "R" or "L"))
					elseif (bDeadBody and anims.KickDeadBody.Use and (rifle or sniper) and stance == STANCE_STAND) then
					
						animPack = anims.KickDeadBody[1].Rifle
					elseif (sniper) then
						--Debug("S")
						animPack = (stance == STANCE_PRONE and anims.Prone[1].Rifle or stance == STANCE_STAND and anims.Stand[1].Sniper or stance == STANCE_CROUCH and anims.Crouch[1].Rifle);
						if (player.GuardAnim and stance == STANCE_STAND) then
							animPack = {
								player.GuardAnimS or "relaxed_idle_rifle_01", --relaxed_officerHandsBehindListening_01
							};
							reset_loop = player.sLastWeaponClass ~= sWeaponClass
							IsLoop = true;
						end;
					elseif (mini) then
						--Debug("M")
						animPack = (stance == STANCE_STAND and anims.Stand[1].Minigun or stance == STANCE_CROUCH and anims.Crouch[1].Minigun);
						
					elseif (rifle) then
						-- Debug("R1")
						animPack = (stance == STANCE_PRONE and anims.Prone[1].Rifle or stance == STANCE_STAND and anims.Stand[1].Rifle or stance == STANCE_CROUCH and anims.Crouch[1].Rifle);
						if (player.GuardAnim and stance == STANCE_STAND) then
							animPack = {
								player.GuardAnimS or "relaxed_idle_rifle_01", --relaxed_officerHandsBehindListening_01
							};
							reset_loop = player.sLastWeaponClass ~= sWeaponClass
							IsLoop = true;
						end;
					elseif (pistol) then
						--Debug("P")
						if ((lean_r or lean_l) and (stance == STANCE_STAND or stance==STANCE_CROUCH)) then
							animPack = stance == STANCE_STAND and  anims.Stand[1].Leaning.Pistol[(lean_r and "Right" or "Left")] or anims.Crouch[1].Leaning.Pistol[(lean_r and "Right" or "Left")];
							NoExtraTime = true;
							IsLoop=true
							isIdleAnim = false;
							reset_loop = stance~=player.lastPeekStance or lean_r~=player.LastRightLean
						--	Debug(reset_loop)
							--Loop = true;
							player.lastPeekStance=stance;
							player.LastRightLean=lean_r;
							--Debug("PISTOL!!!! !!! leaning " .. (lean_r and "R" or "L"))
						else
							animPack = (stance == STANCE_PRONE and anims.Prone[1].Pistol or stance == STANCE_STAND and anims.Stand[1].Pistol or stance == STANCE_CROUCH and anims.Crouch[1].Pistol);
						end;
					elseif (rocket) then
						-- Debug("R2")
						animPack = (stance == STANCE_PRONE and anims.Prone[1].Rifle or stance == STANCE_STAND and anims.Stand[1].Rifle or stance == STANCE_CROUCH and anims.Crouch[1].Rifle);
						-- if (stance == STANCE_STAND) then
							-- IsLoop = true
							-- IsIdleAnim = false
						-- end
						
					end;
					
					player.sLastWeaponClass = sWeaponClass
					if ((not isIdleAnim and player.IdleTime > 2 or instant) or (player.IdleTime > 15)) then
					--	Debug("Is Idle!",player:GetName())
						if (animPack) then
							local animation = self:GetRandomAnim(animPack, player.LastAnimation);
							local animationLength = self:GetAnimLength(animation);
							local ExtraCode;
							-- Debug(animPack,animation)
							if (IsLoop) then
							--	Debug("Is LOOP!!!!",player:GetName())
								if (reset_loop) then
									player.LoopAnim=false;
									Debug("loop reset! :D")
								end;
								if (player.LoopAnim) then
									Debug("Already looping.");
									return true;
								else
									local code = [[
										ATOMClient:HandleEvent(eCE_IdleAnim, "]] .. player:GetName() .. [[", "]] .. animation .. [[", true);
									]];
									ExecuteOnAll(code);
									if (player.GuardSyncId) then
										RCA:StopSync(player.id, player.GuardSyncId)
									end;
									player.GuardSyncId = RCA:SetSync(player, { linked = player.id, client = code });
									player.LoopAnim = true;
									return true;
								end;
							elseif (player.LoopAnim or player.GuardSyncId) then
								Debug("unregiserting looped anim..",player:GetName())
								RCA:Unsync(player.id, player.GuardSyncId);
								player.GuardSyncId = nil;
								ExtraCode = "LOOPED_ANIMS[p.id]=nil";
								player.LoopAnim = false;
								player.AnimationTime = nil;
							end;
							
							if (not player.AnimationTime) then
							--	Debug("PLAY NEW ANIMATIN::",player:GetName(),animationLength* (NoExtraTime and 1 or (isIdleAnim and 4 or 3)))
								player.LastAnimation = animation;
								player.AnimationTime = _time + animationLength * (NoExtraTime and 1 or (isIdleAnim and 4 or 3));
								self:StartAnim(player, animation, ExtraCode);
							elseif (_time > player.AnimationTime) then
							--	Debug("ANBIMATION DONHEE::",player:GetName())
								player.AnimationTime = nil;
								self:UpdatePlayer(player); -- !!Check this
							elseif (_time - player.AnimationTime < -100 ) then
								ATOMLog:LogError("Animation (%s) created infinite delay %s (%s)", (player.LastAnimation or "<error>"), cutNum(player.AnimationTime-_time,2),(self:GetAnimLength((player.LastAnimation or "<error>")) or "<error>"));
								player.AnimationTime = nil;
							end;
							
						else
							-- do something ..
						end;
					end;
				else
					player.AirTime = (player.AirTime or 0) + 1;
					
					if (player.AirTime > 6) then
						if (isFlying) then
							animPack = anims.Air[1].Fly;
							--Debug("Fly")
						else
							if (freeFall) then
								if (hitgroundTime < 2) then
								--	Debug("Free fall CLOSE");
									animPack = anims.Air[1].FreeFall.Close;
								else
								--	Debug("Free fall FAR",willHitWater);
									animPack = anims.Air[1].FreeFall.Far[((willHitWater and waterDistance < 30) and "Water" or "Ground")];
								end;
							else
								if (willHitWater and waterDistance < 30) then
									animPack = anims.Air[1].Fall.Water;
								else
									animPack = anims.Air[1].Fall.Ground;
								end;
								--Debug("Fall")
							end;
						end;
						
						
						
						if (animPack) then
							local animation = self:GetRandomAnim(animPack, player.LastAnimation);
							local animationLength = self:GetAnimLength(animation);
							local ExtraCode;
							if (IsLoop) then
								if (player.LastLoopAnim and animation ~= player.LastLoopAnim) then
									player.LoopAnim = nil;
								end;
								if (player.LoopAnim) then
								--	Debug("Already looping.");
									return true;
								else
									local code = [[
										ATOMClient:HandleEvent(eCE_IdleAnim, "]] .. player:GetName() .. [[", "]] .. animation .. [[", true);
									]];
									ExecuteOnAll(code);
									if (player.GuardSyncId) then
										RCA:StopSync(player, player.GuardSyncId);
									end;
									player.GuardSyncId = RCA:SetSync(player, { linked = player, client = code });
									player.LoopAnim = true;
									player.LastLoopAnim = animation;
									return true;
								end;
							elseif (player.LoopAnim) then
								ExtraCode = "LOOPED_ANIMS[p.id]=nil";
								player.LoopAnim = false;
								player.AnimationTime = nil;
							end;
							
							if (not player.AnimationTime) then
								player.LastAnimation = animation;
								player.AnimationTime = _time + animationLength * (NoExtraTime and 1 or (isIdleAnim and 4 or 3));
								self:StartAnim(player, animation, ExtraCode);
							elseif (_time > player.AnimationTime) then
								player.AnimationTime = nil;
								self:UpdatePlayer(player); -- !!Check this
							--	Debug("uwu")
							end;
							
						else
							-- do something ..
						end;
					end;
				end;
			else
				--Debug("No")
			end;
		else
			self:StopAll(player)
		end;
		
	end,
	----------------
	-- StopAll
	----------------
	
	StopAll = function(self, hPlayer)

		---------
		if (not self.cfg.System) then
			return
		end

		---------
		if (hPlayer.AnimationTime) then
			ExecuteOnAll("local p=GP(" .. hPlayer:GetChannel() .. ")if(p)then p:StopAnimation(0,8)g_Client:ResetClient(p);end")
		end
		
		---------
		if (hPlayer.LoopAnim) then
			if (hPlayer.GuardSyncId) then
				RCA:StopSync(hPlayer, hPlayer.GuardSyncId)
				hPlayer.GuardSyncId = nil
			end;
			ExecuteOnAll([[
			local p = GP(]]..hPlayer:GetChannel()..[[)or GetEnt(']] .. hPlayer:GetName() .. [[');
			if (p) then
				LOOPED_ANIMS[p.id]=nil
				p:StopAnimation(0,8)
			end
			]])
			Debug("Stop ANIM !!!")
			hPlayer.LoopAnim = false
		end
		
		---------
		hPlayer.AnimationTime = nil
		hPlayer.IdleTime = 0
		hPlayer.AirTime = 0
	end,
	
	----------------
	-- OnShoot
	----------------
	OnShoot = function(self, player, weapon)

		---------
		if (not self.cfg.System) then
			return
		end

		---------
		local weaponClass = weapon.class;
		if (player.IdleTime and player.IdleTime > 2) then
			if (not player.LastFireAnim or _time > player.LastFireAnim) then
				local cfg = self.cfg;
				if (not cfg.System or player.InMeeting or ANIM_HANDLER==false) then
					return;
				end;
				Debug("ok oNE")
				local anims = cfg.Animations.Weapons;
				if (anims and anims.Use) then
					local stance = player.actorStats.stance;
					if (stance == STANCE_STAND) then
						local animPack;
						if (weaponClass == "DSG1") then
							animPack = anims[1].DSG1;
						end;
						if (animPack) then
							player.LastActivity = _time - 999;
							local animation = self:GetRandomAnim(animPack, player.LastAnimation);
							if (animation) then
								player.LastAnimation = animation;
								player.LastFireAnim = _time + self:GetAnimLength(animation);
								self:StartAnim(player, animation);
								Debug("ok?")
							end;
						end;
					end;
				end;
			end;
		end;
		
	end,
	----------------
	-- OnRadio
	----------------
	OnRadio = function(self, player, radioId)

		---------
		if (not self.cfg.System) then
			return
		end

		---------
		if (player.IdleTime and player.IdleTime > 2) then
			Debug(radioId)
			if (not player.LastRadioAnim or _time > player.LastRadioAnim) then
				local cfg = self.cfg;
				if (not cfg.System or player.InMeeting or ANIM_HANDLER==false) then
					return;
				end;
				local anims = cfg.Animations.Radio;
				local item = player:GetCurrentItem();
				local pistol = item and item.class == "SOCOM";
				local rifle = item and not pistol;
				
				if (anims and anims.Use) then
					local stance = player.actorStats.stance;
					if (stance == STANCE_STAND or stance == STANCE_CROUCH) then
						local animPack;
						if (radioId == 15) then
							animPack = anims[1].Help;
						elseif (radioId == 3) then
							--if (stance == STANCE_CROUCH) then
								if (pistol) then
									animPack = anims[1].Follow.Pistol
								elseif (rifle) then
									animPack = anims[1].Follow.Rifle
								else
									animPack = anims[1].Other;
								end;
								Debug(animPack)
							--end;
						else
							animPack = anims[1].Other;
						end;
						if (animPack) then
							local animation = self:GetRandomAnim(animPack, player.LastAnimation);
							if (animation) then
								player.LastAnimation = animation;
								player.LastRadioAnim = _time + self:GetAnimLength(animation);
								self:StartAnim(player, animation);
							else
								Debug("no anim from pack?")
							end;
						end;
					end;
				end;
			end;
		end;
	end,
	----------------
	-- OnExplosion
	----------------
	OnExplosion = function(self, explosion)

		---------
		if (not self.cfg.System) then
			return
		end

		---------
		if (ANIM_HANDLER and ANIM_HANDLER == false) then
			return;
		end;
		if (not self.cfg.System) then
			return false;
		end;
		local entities = explosion.AffectedEntities;
		local animpack;
		local stance;
		local item;--  = player:GetCurrentItem();
		local fists;-- = not item or (item.class == "Fists" or item.class == "Binoculars");
		local pistol;--  = not fists and item.class == "SOCOM";
		local rocket;--  = not fists and item.class == "LAW";
		local rifle;--  = not fists and not rocket and not pistol;
		local mini;--  = rifle and (item.class == "Hurricane" or item.class == "AlienMount");
		local sniper;-- 
		local anims = self.cfg.Animations.Stagger[1]
		if (arrSize(entities)>0) then
			for i, entity in pairs(entities) do
				if (not g_game:IsFrozen(entity.id) and entity.ATOM_Client and not entity.InMeeting and entity.isPlayer and entity:CanSeePosition(explosion.pos) and explosion.radius >3) then
					if (not entity:IsDead() and not entity:IsSpectating() and not entity:GetVehicle() and not entity:IsUnderwater()) then
						if (not entity.StaggerAnimtime or _time > entity.StaggerAnimtime) then
							stance = entity.actorStats.stance;
							item = entity:GetCurrentItem();
							fists = not item or (item.class == "Fists" or item.class == "Binoculars");
							pistol = not fists and item.class == "SOCOM";
							rocket = not fists and item.class == "LAW";
							rifle = not fists and not rocket and not pistol;
							mini = rifle and (item.class == "Hurricane" or item.class == "AlienMount");
							sniper = sniper and (item.class == "DSG1" or item.class == "GaussRifle");
							animpack = nil;
							--Debug(entity:CanSeePosition(explosion.pos));
							if (fists) then
							--	Debug("FIST OWO ->",stance == STANCE_CROUCH)
								animpack = stance == STANCE_STAND and anims.Stand.Fist
							elseif (pistol) then
							--	Debug("PISTOL ->",stance == STANCE_CROUCH)
								animpack = stance == STANCE_STAND and anims.Stand.Pistol
							elseif (rifle) then
							--	Debug("Rifle ->",stance == STANCE_CROUCH)
								animpack = stance == STANCE_STAND and anims.Stand.Rifle or stance == STANCE_CROUCH and anims.Crouch.Rifle
							end;
							if (animpack) then
								local animation = self:GetRandomAnim(animpack, entity.LastAnimation);
								local animationLength = self:GetAnimLength(animation);
							--	Debug(animationLength)
							--	Debug("PLAY STAGGER::",entity:GetName(),animationLength* 2)
								entity.LastAnimation = animation;
								entity.StaggerAnimtime = _time + animationLength*2;
								self:StartAnim(entity, animation);
							else
								-- do something ..
							end;
						end;
					end;
				end;
			end;
		end;
	end,
	----------------
	-- StartAnim
	----------------
	StartAnim = function(self, player, animationName, extraCode)

		---------
		if (not self.cfg.System) then
			return
		end

		---------
		if (not GetBetaFeatureStatus("idleanim")) then
			return
		end

		---------
		if (player.AFK) then
			return;
		end;

		if (player.hGrabbing or player.bGrabbed or player.bPiggyRiding) then
			return
		end

		local item = player:GetCurrentItem()
		if (item and item.class == "Binoculars") then
			return;
		end;
		
		if (player.StopIdleAnim) then
			return;
		end;
		--if (player.GuardSyncId) then
		--	RCA:StopSync(player, player.GuardSyncId);
		--	player.GuardSyncId = nil;
		--end;
		--Debug(">>",player:GetName(),animationName)
		ExecuteOnAll([[
			local p=GP(]]..player:GetChannel()..[[)
			ATOMClient:HandleEvent(eCE_IdleAnim, p:GetName(), "]] .. animationName .. [[");
		]]..(extraCode or ""));
		--ExecuteOnAll([[
		--	local p = GetEnt(']] .. player:GetName() .. [[');
		--	if (p) then
		--		]]..(extraCode or "")..[[
		--		p:StartAnimation(0, "]] .. animationName .. [[");
		--	end;
		--]]);
	end,
	----------------
	-- GetRandomAnim
	----------------
	GetRandomAnim = function(self, packs, lastAnim)
		local packTotal = arrSize(packs);
		if (packTotal < 2) then
			--Debug("one, ",packs[1])
			return packs[1];
		end;
		local randomAnim = packs[math.random(packTotal)];
		if (lastAnim) then
			while randomAnim == lastAnim do
				randomAnim = packs[math.random(packTotal)];
			end;
		end;
		return randomAnim;
	end,
	----------------
	-- GetAnimLength
	----------------
	GetAnimLength = function(self, name)
		local AnimationTimes = { -- Auto-Generated
			["prone_idle_pistol_01"] = 1.93333,
			["prone_idle_pistol_02"] = 3.66667,
			["prone_idle_pistol_03"] = 4.96667,
			["prone_idle_pistol_04"] = 4.23333,
			["prone_idle_rifle_01"] = 2.06667,
			["prone_idle_rifle_02"] = 11.1,
			["prone_idle_rifle_03"] = 8.96667,
			["prone_idle_nw_01"] = 2,
			["prone_idle_nw_02"] = 3.66667,
			["prone_idle_nw_03"] = 2,
			["prone_idle_nw_04"] = 4.53333,
			["combat_idle_mg_01"] = 2.23333,
			["combat_idle_mg_02"] = 4.33333,
			["combat_idle_mg_03"] = 3.76667,
			["combat_idle_mg_04"] = 4.9,
			["combat_sniperIdle_rifle_01"] = 10.4333,
			["combat_idle_pistol_01"] = 2.1,
			["combat_idle_pistol_02"] = 3.6,
			["combat_idle_pistol_03"] = 3.6,
			["combat_idle_pistol_04"] = 4.1,
			["combat_idle_rifle_01"] = 1.4,
			["combat_idle_rifle_02"] = 7.7,
			["combat_idle_rifle_03"] = 8.36667,
			["combat_idle_rifle_04"] = 3.66667,
			["combat_guard_rifle_01"] = 0.33333,
			["crouch_idle_mg_01"] = 3.06667,
			["crouch_idle_mg_02"] = 4.93333,
			["crouch_idle_mg_03"] = 3.63333,
			["crouch_idle_mg_04"] = 4,
			["crouch_idle_pistol_01"] = 1.96667,
			["crouch_idle_pistol_02"] = 3,
			["crouch_idle_pistol_03"] = 1.66667,
			["crouch_idleKnee_pistol_01"] = 1.96667,
			["crouch_idleKnee_pistol_02"] = 3,
			["crouch_idleKnee_pistol_03"] = 1.66667,
			["crouch_idle_rifle_01"] = 1.46667,
			["crouch_idle_rifle_02"] = 8.33333,
			["crouch_idle_rifle_03"] = 9.33333,
			["crouch_idle_rifle_04"] = 2.93333,
			["crouch_idleKnee_rifle_01"] = 1.46667,
			["crouch_idleKnee_rifle_02"] = 8.33333,
			["crouch_idleKnee_rifle_03"] = 9.33333,
			["crouch_idleKnee_rifle_04"] = 2.93333,
			["crouch_idle_nw_01"] = 1.46667,
			["crouch_idle_nw_02"] = 12.2667,
			["crouch_idle_nw_03"] = 5.83333,
			["crouch_idle_nw_04"] = 5,
			["crouch_idleKnee_nw_02"] = 12.2667,
			["crouch_idleKnee_nw_03"] = 5.83333,
			["crouch_idleKnee_nw_04"] = 5,
			["relaxed_idleCheckingWatch_01"] = 6,
			["relaxed_idleChinrub_01"] = 4.33333,
			["relaxed_idleChinrub_02"] = 6.33333,
			["relaxed_idleChinrub_03"] = 7,
			["relaxed_idleClaphands_01"] = 9.66667,
			["relaxed_idleDawdling_nw_01"] = 7,
			["relaxed_idleDrummingOnLegs_nw_01"] = 7,
			["relaxed_idleHeadScratch_01"] = 6.33333,
			["relaxed_idleHeadScratch_02"] = 4.16667,
			["relaxed_idleHeadScratch_03"] = 4.9,
			["relaxed_idleHeadScratch_04"] = 6.7,
			["relaxed_idleHeadScratch_05"] = 4.9,
			["relaxed_idleInsectSwat_leftHand_01"] = 4.16667,
			["relaxed_idleInsectSwat_leftHand_02"] = 7.16667,
			["relaxed_idleKickDust_01"] = 5.33333,
			["relaxed_idleKickStone_01"] = 6.33333,
			["relaxed_idleListening_01"] = 4.46667,
			["relaxed_idleListening_02"] = 4.53333,
			["relaxed_idleListening_03"] = 10.6667,
			["relaxed_idlePickNose_nw_01"] = 6.66667,
			["relaxed_idleRubKnee_01"] = 4.9,
			["relaxed_idleRubNeck_01"] = 4.33333,
			["relaxed_idle_rifle_01"] = 2.25,
			["relaxed_idleScratchbutt_01"] = 4,
			["relaxed_idleScratchNose_nw_01"] = 5.86667,
			["relaxed_idleShift_01"] = 7.33333,
			["relaxed_idleShift_01"] = 7.33333,
			["relaxed_idleShoulderShrug_01"] = 5.33333,
			["relaxed_idleShoulderShrug_02"] = 5.76667,
			["relaxed_idleShoulderShrug_03"] = 7.5,
			["relaxed_idleSmokeDrag_cigarette_01"] = 10,
			["relaxed_idleSmokeDrag_cigarette_02"] = 8.33333,
			["relaxed_idleTappingFoot_01"] = 6.5,
			["relaxed_idleTeetering_nw_01"] = 6.36667,
			["relaxed_idleTieLaces_01"] = 10,
			["relaxed_idleYawn_nw_01"] = 5.66667,
			["relaxed_readIdle_book_01"] = 4.43333,
			["relaxed_salute_nw_01"] = 3,
			["relaxed_saluteLazyCO_nw_01"] = 3.6,
			["relaxed_standIdleHandsBehindCOLoop_01"] = 5.33333,
			["relaxed_idleFootOnWallLoop_nw_01"] = 15.3333, 
			["relaxed_idleFootOnWallLoop_nw_02"] = 2.23333,
			["relaxed_standIdleHandsBehindCOLoop_01"] = 5.33333,
			["relaxed_standIdleHandsBehindCOLoop_01"] = 5.33333,
			["relaxed_standIdleHandsBehindCOLoop_02"] = 10,
			["relaxed_repairGeneric_hammer_01"] = 5.2,
			["relaxed_repairGeneric_hammer_02"] = 5.2,
			["relaxed_repairGeneric_screwdriver_01"] = 1.8,
			["relaxed_repairGenericCrouch_hammer_01"] = 1.26667,
			["relaxed_repairGenericCrouch_screwdriver_01"] = 9.26667,
			["relaxed_repairGenericCrouch_screwdriver_02"] = 9.26667,
			["relaxed_repairGenericCrouch_screwdriver_03"] = 17.2,
			["relaxed_salute_nw_01"] = 3,
			["relaxed_saluteLazyCO_nw_01"] = 3.6,
			["stealth_idle_mg_01"] = 2.2, 
			["stealth_idle_mg_02"] = 3.8, 
			["stealth_idle_mg_03"] = 4.3, 
			["stealth_idle_mg_04"] = 3.66667, 
			["stealth_idle_mg_01"] = 2.2, 
			["stealth_idle_nw_01"] = 1.66667, 
			["stealth_idle_mg_02"] = 3.8, 
			["stealth_idle_nw_02"] = 3.66667, 
			["stealth_idle_mg_03"] = 4.3, 
			["stealth_idle_nw_03"] = 4.93333, 
			["stealth_idle_mg_04"] = 3.66667, 
			["stealth_idle_nw_04"] = 2.93333, 
			["stealth_idle_nw_01"] = 1.66667, 
			["stealth_idle_pistol_01"] = 1.3, 
			["stealth_idle_nw_02"] = 3.66667, 
			["stealth_idle_pistol_02"] = 2.8, 
			["stealth_idle_nw_03"] = 4.93333, 
			["stealth_idle_pistol_03"] = 3.5, 
			["stealth_idle_nw_04"] = 2.93333, 
			["stealth_idle_pistol_04"] = 3.53333, 
			["stealth_idle_pistol_01"] = 1.3, 
			["stealth_idle_rifle_01"] = 1.86667, 
			["stealth_idle_pistol_02"] = 2.8, 
			["stealth_idle_rifle_02"] = 3.76667, 
			["stealth_idle_pistol_03"] = 3.5, 
			["stealth_idle_rifle_03"] = 2.9, 
			["stealth_idle_pistol_04"] = 3.53333, 
			["stealth_idle_rifle_04"] = 3.66667, 
			["stealth_idle_rifle_01"] = 1.86667, 
			["stealth_flinch_rifle_01"] = 1.63333, 
			["stealth_idle_rifle_02"] = 3.76667, 
			["stealth_idle_rifle_03"] = 2.9, 
			["stealth_idle_rifle_04"] = 3.66667, 
			["stealth_flinch_rifle_01"] = 1.63333, 
			["combat_callReinforcements_nw_01"] = 2.6, 
			["combat_callReinforcements_nw_02"] = 3.56667,
			["combat_fearFront_nw_01"] = 1.5,
			["combat_fearFront_nw_02"] = 1.76667,
			["combat_fearFront_rifle_01"] = 1.5,
			["combat_fearFront_rifle_02"] = 1.76667,
			["combat_flinch_rifle_01"] = 1.63333,
			["combat_fearFront_pistol_01"] = 1.5,
			["combat_fearFront_pistol_02"] = 1.76667,
			["stealth_flinch_rifle_01"] = 1.63333,
			["stealth_flinch_rifle_01"] = 1.63333,
			["crouch_flinch_rifle_01"] = 1.26667,
			["crouch_flinch_rifle_02"] = 1.43333,
			["combat_flinch_rifle_01"] = 1.63333,
		};
		return AnimationTimes[name] or 3;
	end,
};

ATOMAnimations:Init();