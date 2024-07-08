ATOMVehicles = {
	cfg = {
		TurretsTargetEmptyVehicle = true; -- if true, turrets will also shoot emtpy enemy vehicles - no mercy. (Will not overrite when reloading)
		NewBoost = true;
		CloakVehicle = true, -- if true, cloaks vehicles when driver activates cloak mode
		CloakVehicles = { -- Vehicle classes that can be cloaked
			["Civ_car1"] 			= true, -- Civ Car
			["Civ_speedboat"] 		= true,	-- Speed boat
			["US_ltv"] 				= true,	-- LTV
			["Asian_ltv"] 			= true,	-- LTV
			["Asian_truck"] 		= true,	-- Truck
			["Asian_aaa"] 			= false, -- AAA
			["Asian_apc"] 			= false, -- APC
			["Asian_helicopter"] 	= false, -- Helicopter
			["Asian_patrolboat"] 	= false, -- Patrol Boat
			["Asian_tank"] 			= false, -- Tank
			["US_apc"] 				= false, -- APC
			["US_hovercraft"] 		= false, -- Hovercraft
			["US_smallboat"] 		= false, -- Smallboat
			["US_tank"] 			= false, -- Tank
			["US_transportVTOL"] 	= false, -- Transport VTOL
			["US_trolley"] 			= false, -- Trolley
			["US_vtol"] 			= false  -- VTOL
		},
		HitImpulseMultiplier = 1; -- the multiplierf for the hit impulse (this*vehicleMass)
	},
	-------------
	Init = function(self)
		if (VehicleBase) then
		
			function VehicleBase:SpawnVehicleBase()
			
				if (self.OnPreSpawn) then
					self:OnPreSpawn();
				end
				
				if (_G[self.class.."Properties"]) then
					mergef(self, _G[self.class.."Properties"], 1);  
				end
			  
				if (self.OnPreInit) then
					self:OnPreInit();
				end  

				self:InitVehicleBase();
						
				self.ProcessMovement = nil;
				
				if (not EmptyString(self.Properties.FrozenModel)) then
				  self.frozenModelSlot = self:LoadObject(-1, self.Properties.FrozenModel);
				  self:DrawSlot(self.frozenModelSlot, 0);
				end
					
				if (self.OnPostSpawn) then
					self:OnPostSpawn();
				end
				
				local aiSpeed = self.Properties.aiSpeedMult;
				local AIProps = self.AIMovementAbility;
				if (AIProps and aiSpeed and aiSpeed ~= 1.0) then	  
					if (AIProps.walkSpeed) then AIProps.walkSpeed = AIProps.walkSpeed * aiSpeed; end;
					if (AIProps.runSpeed) then AIProps.runSpeed = AIProps.runSpeed * aiSpeed; end;
					if (AIProps.sprintSpeed) then AIProps.sprintSpeed = AIProps.sprintSpeed * aiSpeed; end;
					if (AIProps.maneuverSpeed) then AIProps.maneuverSpeed = AIProps.maneuverSpeed * aiSpeed; end;
				end

				if (self.InitAI) then
					self:InitAI();
				end
				self:InitSeats();
				self:OnReset();
				
				self.Server.OnHit = ATOMVehicles.OnHit;
			end
		
			VehicleBase.GetDriver = function(self)
				local driverId = self:GetDriverId();
				return (driverId and System.GetEntity(driverId) or nil);
			end;
		
			VehicleBase.GetPassengers = function(self)
				local aPassengers = {}
				for i, aSeat in pairs(self.Seats) do
					if (aSeat:GetPassengerId()) then
						table.insert(aPassengers, aSeat:GetPassengerId())
					end
				end
				return aPassengers
			end
			
			--VehicleBase.OnHit = self.OnHit;
			VehicleBase.Server.OnHit = VehicleBase.OnHit;
			
			VehicleBase.turretsShootMe = self.cfg.TurretsTargetEmptyVehicle; --true;
			
			--------------------------------------------------------------------------
			VehicleBase.ForceCoopAI = function(self)
			--	Debug("VEHICLE REG AI UWU");
				ATOMDLL:SetMultiplayer(false)
				AI.RegisterWithAI(self.id, self.AIType or 0, self.Properties or {}, self.PropertiesInstance or {}, self.AIMovementAbility or {});
				ATOMDLL:SetMultiplayer(true)
			end;
			
			VehicleBase.CanTarget = function(gameRules, vehicle, turret)
				--Debug(turret:GetName())
				local alive = not vehicle.vehicle:IsDestroyed();
				local Id1, Id2 = vehicle, turret;
				if (type(vehicle) == "number") then
					Id1 = System.GetEntity(vehicle).id;
				elseif (type(vehicle) == "table") then
					Id1 = vehicle.id;
				end;
				if (type(turret) == "number") then
					Id2 = System.GetEntity(turret).id;
				elseif (type(turret) == "table") then
					Id2 = turret.id;
				end;
				--SysLog("%s, %s", tostr(Id1), tostr(Id2))
				return alive and g_game:GetTeam(Id1) ~= g_game:GetTeam(Id2) and g_game:GetTeam(Id1) ~= 0;
			end;
			local entities = System.GetEntities();
			if (entities) then
				for i, ent in ipairs(entities) do
					if (ent.Server and (type(ent.Server)=="table") and ent.vehicle) then
						local metatbl = getmetatable(ent.Server);
						if ((type(metatbl)=="table")) then
							metatbl.OnHit = self.OnHit;
						end;
						ent.Server.OnHit = self.OnHit;
						ent.GetDriver = VehicleBase.GetDriver;
						ent.CanTarget = VehicleBase.CanTarget;
						ent.ForceCoopAI = VehicleBase.ForceCoopAI;
						if (ent.turretsShootMe == nil) then
							ent.turretsShootMe = VehicleBase.turretsShootMe; --ent.CanTarget or 
						end
					end
				end
			end
		end
		
		--------
		if (self.cfg.NewBoost) then
			ATOMDLL:ForceSetCVar("v_newBoost", "1") end
		
		--------
		if (self.cfg.Enable360Camera) then
			ATOMDLL:ForceSetCVar("v_debugView", "1") end
		
	end,
	-------------
	OnHit = function(self, hit) -- self == vehicle here
		-- Debug("vehicle got hit duh")
		
		local currCargo = self.TransCargo and GetEnt(self.TransCargo);
		local p = self:GetPos();
		if (currCargo and not self.vehicle:IsDestroyed()) then
			currCargo:SetWorldPos(makeVec(p.x, p.y, p.z - 7));
			--self.TransCargo = nil;
			--if (self.TransCargoSyncID) then
			--	self:Unsync(self, self.TransCargoSyncID);
			--	self.TransCargoSyncID = nil;
			--end;
		else
			if (currCargo) then
				self.TransCargo = nil;
				if (self.TransCargoSyncID) then
					RCA:Unsync(self, self.TransCargoSyncID);
					self.TransCargoSyncID = nil;
				end;
				--Debug("remove this bitch")
			end;
		end;
		
		local start = os.clock();
		local shooter = hit.shooter;
		local driver = self:GetDriver();
		
		local weapon = hit.weapon;

		local explosion = hit.explosion or false;
		local targetId = (explosion and hit.impact) and hit.impact_targetId or hit.targetId;
		local hitType = (explosion and hit.type == "") and "explosion" or hit.type;
		local direction = hit.dir;

		if (hit.type ~= "fire") then
			if (self.class ~= "US_vtol" and self.class ~= "Asian_helicopter") then
				g_gameRules.game:SendHitIndicator(hit.shooterId, hit.explosion or false);
			end
		end

		if (hit.type == "collision") then
			direction.x = -direction.x;
			direction.y = -direction.y;
			direction.z = -direction.z;
		end;
		
		if (shooter and shooter.isPlayer and shooter.actor:GetNanoSuitMode() == NANOMODE_STRENGTH and weapon and weapon.class == "Fists") then
			local impulse = self:GetMass();
			if (ATOMVehicles.cfg.HitImpulseMultiplier) then
				impulse = impulse * ATOMVehicles.cfg.HitImpulseMultiplier;
			end;
			if (driver and impulse > 100) then
				if (RCA) then
					--Debug(arr2str_(direction))
					--Debug(driver:GetName())
					ExecuteOnPlayer(driver, [[local vId=g_localActor.actor:GetLinkedVehicleId();if (vId) then local v=System.GetEntity(vId)if (v) then v:AddImpulse(-1,v:GetCenterOfMassPos(),]]..arr2str_(direction)..[[, ]]..impulse..[[,1)end;end;]]);
				end;
			else
				self:AddImpulse(-1, hit.pos, hit.dir, impulse, 1);
			end;
		end;
		
		
		if (not ATOMDefense:OnVehicleHit(hit, self)) then
			-- Debug("defense said NO.")
			return false;
		elseif (ATOMBroadcastEvent("OnVehicleHit", hit, self) == false) then
			-- Debug("events said NO.")
			return false;
		end;
		
		local cfg = ATOM.cfg.DamageConfig;
		if (cfg and weapon) then
			local vehicleCfg = cfg.VehicleHits;
			if (vehicleCfg) then
				--Debug("Yes!!")
				local damageCfg = vehicleCfg.DamageMultipliers;
				if (damageCfg) then
					for i, dmgConfig in pairs(damageCfg) do
						local v_ok = true;
						local w_ok = true;
						if (dmgConfig[3]) then
							if (type(dmgConfig[3]) == "table") then
								for _i, class in pairs(dmgConfig[3]) do
									if (self.class == class) then
										-- SysLog("its the vehicle (%s==%s)",self.class,class)
										v_ok = true;
										break;
									else
										v_ok = false;
									end;
								end;
							else
								v_ok = self.class == dmgConfig[3];
							end;
						end;
						
						if (dmgConfig[2]) then
							if (type(dmgConfig[2]) == "table") then
								for _i, class in pairs(dmgConfig[2]) do
									if (weapon.class == class) then
										-- SysLog("its the weapon (%s==%s)",weapon.class,class)
										w_ok = true;
										break;
									else
										w_ok = false;
									end;
								end;
							else
								w_ok = weapon.class == dmgConfig[2];
							end;
						end;
						
						if (w_ok and v_ok) then
							hit.damage = hit.damage * dmgConfig[1];
						end;
						--SysLog("ok to multiply: %s %f",tostring(w_ok and v_ok),dmgConfig[1])
					end;
					--Debug("Yes!")
					--[[
					for i, damageMult in pairs(damageCfg) do
							Debug("??>",i,weapon.class)
						if (i == weapon.class) then
						--local damageMult = damageCfg[weapon.class];
						--if (damageMult) then
							Debug("Yes>",weapon.class)
							if (type(damageMult) == "table") then
								local ok = false;
								for i, v in pairs(damageMult[2]) do
									if (self.class == v) then
										ok = true;
										break;
									end;
								end;
								if (ok) then
									--Debug("yes, ok, lol, mult = ",damageMult[1]);
									hit.damage = hit.damage * damageMult[1];
								end;
							else
								--Debug("no, ok, lol, mult = ",damageMult);
								hit.damage = hit.damage * damageMult;
							end;
						--end;
						end;
					end;
					--]]
				end;
			end;
		end;
		
		--if (weapon and weapon.class == "GaussRifle" and self.class == "US_vtol") then
			--Debug(hit.damage)
			--hit.damage = hit.damage * 20;
			--Debug(hit.damage)
		--end;
		
		-- prevents infinite chain explosions from respawning vehicles damaging each other
		if (not self.wasUsed and (hit.explosion or hitType == "fire") and weapon and weapon.vehicle and weapon ~= vehicle) then
			hit.damage = 0;
		end;
		
		local passengerGod = false;
		for i, seat in pairs(self.Seats) do
			if (seat:GetPassengerId()) then
				local passenger = GetEnt(seat:GetPassengerId());
				if (passenger and passenger.InGodMode and passenger:InGodMode()) then
					passengerGod = true;
				end;
			end;
		end;
		
		if (shooter and shooter.isPlayer) then
			if ((shooter.megaGod or shooter.Superman) and weapon and weapon.class == "Fists") then
				if (driver) then
					if (RCA) then
						ExecuteOnPlayer(driver, [[local vId=g_localActor.actor:GetLinkedVehicleId();if (vId) then local v=System.GetEntity(vId)if (v) then v:AddImpulse(-1,v:GetCenterOfMassPos(),]]..arr2str_(direction)..[[, 10000000,1)end;end;]]);
					end;
				else
				--	Debug("Fly WTF")
					self:AddImpulse(-1, hit.pos, direction, 1000000, 1);
				end;
			end;
		end;
		
		if (passengerGod or (driver and driver.InGodMode and driver:InGodMode())) then
			hit.damage = 0;
			-- Debug("GOD said NO.")
			return false;
		end;

        if (self.Invulnerable) then
            hit.damage = 0
			return false;
          --  Debug("vehicle GOD!")
        end

		self.vehicle:OnHit(targetId, hit.shooterId, hit.damage, hit.pos, hit.radius, hitType, explosion);
		-- Debug("hit oki! ",hit.damage)

		-- added 3 signals 20/12/05 tetsuji

		if (AI_ENABLED and AI and hit.type ~= "collision") then
			if (hit.shooter) then
				g_SignalData.id = hit.shooterId;
			else
				g_SignalData.id = NULL_ENTITY;
			end
			g_SignalData.fValue = hit.damage;
			if (hit.shooter and self.Properties.species ~= hit.shooter.Properties.species) then
			  CopyVector(g_SignalData.point, hit.shooter:GetWorldPos());
				AI.Signal(SIGNALFILTER_SENDER,0,"OnEnemyDamage",self.id,g_SignalData);
			elseif (self.Behaviour and self.Behaviour.OnFriendlyDamage ~= nil) then
				AI.Signal(SIGNALFILTER_SENDER,0,"OnFriendlyDamage",self.id,g_SignalData);
			else
				AI.Signal(SIGNALFILTER_SENDER,0,"OnDamage",self.id,g_SignalData);
			end
		end;
		
		if (hit.KillHit) then
			hit.damage = 999999;
			return true;
		end;

		return self.vehicle:IsDestroyed();
	end,
	-------------
	OnOwnerFirstEnter = function(self, player, vehicle)
		vehicle.ownerID = player.id;
		if (player.lastVehicleID) then
			local lastVehicle = System.GetEntity(player.lastVehicleID);
			if (lastVehicle and not g_gameRules.game:IsSpawnGroup(player.lastVehicleID)) then
				lastVehicle.ownerID = nil;
			end;
		end;
		player.lastVehicleID = vehicle.id;
		--Debug("OWNER FIRST ENTER!!")
	end,
	-------------
	CanEnterVehicle = function(self, player, vehicle)
		local distance = GetDistance(player, vehicle);
		if (distance > 15) then
			return false;
		end;
		
		if (self:IsLocked(vehicle, player)) then
			return false, SendMsg(ERROR, player, "THIS VEHICLE IS LOCKED")
		end;
		
		if (LOCKDOWN and not player.meagGod) then
			return false, SendMsg(ERROR, player, "LOCKDOWN IS ENABLED")
		end;
		
		return ATOMBroadcastEvent("CanEnterVehicle", player, vehicle);
	end,
	-------------
	IsLocked = function(self, vehicle, player)
		if (vehicle.lockedBy) then
			local owner = System.GetEntity(vehicle.lockedBy);
			vehicle.unlockedPlayers = vehicle.unlockedPlayers or {};
			if (owner and owner ~= player and owner:GetTeam() == player:GetTeam() and not vehicle.unlockedPlayers[player.id]) then
			--	SendMessage(ERROR, player, "Vehicle is locked by "..owner:GetName());
				return true;
			end;
		end;
		return false;
		--return vehicle.lockedBy and GetEnt(vehicle.lockedBy) and vehicle.lockedBy ~= player.id;
	end,
	-------------
	OnSeatChange = function(self, player, vehicle, seat)

		vehicle.wasUsed = true;

		local distance = GetDistance(player, vehicle);
		if (distance > 15) then
			return false;
		end;
		
		local playerID = player.id;
		local ownerID = vehicle.ownerID or vehicle.vehicle:GetOwnerId();
		local lockedID = vehicle.lockedBy;
		
		if (seat.seat:IsDriver() and ((ownerID and ownerID~=ALL and ownerID~=playerID and (g_game:GetTeam(ownerID)==g_game:GetTeam(playerID) or (ownerID==vehicle.id))) or (lockedID and lockedID~=playerID))) then
			SendMsg(ERROR, player, "Cannot switch to driver (it is not your vehicle)");
			return false;
		end;
		return ATOMBroadcastEvent("OnSeatChange", player, vehicle, seat);
	end,
	-------------
	OnLeaveVehicle = function(self, player, vehicle, seat)
		player.ExitVehicleTime = _time;
		player.ExitVehicleId = vehicle.id;

		return ATOMBroadcastEvent("CanLeaveVehicle", player, vehicle, seat);
	end,
	-------------
	GetPlayerVehicle = function(self, player)
	end,
	-------------
	LockVehicle = function(self, player)
		local vehicle = player:GetVehicle();
		if (not vehicle) then
			vehicle = player.ExitVehicleId and GetEnt(player.ExitVehicleId);
			if (not vehicle or GetDistance(vehicle, player) > 200) then
				return false, "no vehicle in radius of 200m was found";
			end;
		end;
		
		if (vehicle.lockedBy) then
			if (GetEnt(vehicle.lockedBy) and vehicle.lockedBy ~= player.id) then
				return false, "vehicle already locked by someone else";
			end;
			vehicle.unlockedPlayers = {};
			vehicle.isLocked = false;
			vehicle.lockedBy = nil;
			player.lockedVehicleId = nil;
			SendMsg(CHAT_VEHICLE, player, "UNLOCKED");
		else
			if (player.lockedVehicleId) then
				local lockedVehicle = GetEnt(player.lockedVehicleId);
				if (lockedVehicle) then
					lockedVehicle.isLocked = false;
					lockedVehicle.lockedBy = nil;
				end;
			end;
			
			vehicle.isLocked = true;
			vehicle.lockedBy = player.id;
			player.lockedVehicleId = vehicle.id;
			SendMsg(CHAT_VEHICLE, player, "LOCKED");
		end;
		
		return true;
	end,
	-------------
	UnlockVehicle = function(self, player, target)
		local vehicle = player:GetVehicle();
		if (not vehicle) then
			vehicle = player.ExitVehicleId and GetEnt(player.ExitVehicleId);
			if (not vehicle or GetDistance(vehicle, player) > 200) then
				return false, "no vehicle in radius was found";
			else
			--	remote = true;
			end;
		end;
		
		if (vehicle.lockedBy) then
			if (GetEnt(vehicle.lockedBy) and vehicle.lockedBy ~= player.id) then
				return false, "vehicle locked by someone else";
			end;
			vehicle.unlockedPlayers = {};
			vehicle.isLocked = false;
			vehicle.lockedBy = nil;
			player.lockedVehicleId = nil;
			SendMsg(CHAT_VEHICLE, player, "UNLOCKED");
		else
			return false, "vehicle is not locked";
		end;
		
		return true;
	end,
};

ATOMVehicles:Init();