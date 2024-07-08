----------------------------------------------------------------------------------
-- !theride

NewCommand({
	Name 	= "theride",
	Access	= CREATOR,
	Description = "Spawns ThE rIdE",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
	
	
		local function MakeTheRide(hVeh)
		
			hVeh.IsARide = true
			local sCode = [[
		
			System.LogAlways("Called OK")
			
			local v=GetEnt(']]..hVeh:GetName()..[[')
			if(not v)then return end
			System.LogAlways("Vehicle OK")
			
			v:DrawSlot(0,0)
			local vp,va=v:GetPos(),v:GetDirectionVector()
			
			DEPENDENT_OBJECTS[v.id]=DEPENDENT_OBJECTS[v.id]or{}
			for i,vv in pairs(__THERIDE__ENTITIES__) do
				local new=System.SpawnEntity({class="CustomAmmoPickup",position=vp,orientation=va,name="v_part_",properties={objModel=vv[1],bPhysics=0}})			
				v:AttachChild(new.id,0)
				new:SetScale(vv[4])
				new:SetLocalPos(vv[2])
				new:SetLocalAngles(vv[3])
				table.insert(DEPENDENT_OBJECTS[v.id], new.id)
			end
			
			]]
			
			
			Script.SetTimer(100, function()
			ExecuteOnAll(sCode)
			hVeh.syncId = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			-- hVeh.syncId1 = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			end)
		end
	
	
		local hVehicle = hPlayer:GetVehicle()
		if (hVehicle and hVehicle.class ~= "Civ_car1") then
			return false, "this vehicle cannot become the ride"
		elseif (not hVehicle) then
			Script.SetTimer(100, function()
				hVehicle = System.SpawnEntity({ name = string.format("taxi%d",g_utils:SpawnCounter()), class = "Civ_car1", orientation = hPlayer:GetDirectionVector(), position = add2Vec((hPlayer:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) })
				Script.SetTimer(1500, function()
					MakeTheRide(hVehicle)
				end)
			end)
			SendMsg(CHAT_ATOM, hPlayer, "Here is your Ride")
			return true
		end
		
		if (hVehicle.IsARide) then
			return false, "this vehicle is already a RiDe"
		end
		
		MakeTheRide(hVehicle)
		SendMsg(CHAT_ATOM, hPlayer, "Your vehicle has become a real ride")
	end
})

----------------------------------------------------------------------------------
-- !theride

NewCommand({
	Name 	= "thesetup",
	Access	= CREATOR,
	Description = "Spawns ThE SeTuP",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
	
	
		local function MakeTheRide(hVeh)
		
			hVeh.IsARide = true
			local sCode = [[
		
			System.LogAlways("Called OK")
			
			local v=GetEnt(']]..hVeh:GetName()..[[')
			if(not v)then return end
			
			v:DrawSlot(0,0)
			v:DrawSlot(2,0)
			v:DrawSlot(4,0)
			local vp,va=v:GetPos(),v:GetDirectionVector()
			
			DEPENDENT_OBJECTS[v.id]=DEPENDENT_OBJECTS[v.id]or{}
			for i,vv in pairs(__THESETUP__ENTITIES__) do
				local new=System.SpawnEntity({class="CustomAmmoPickup",position=vp,orientation=va,name="v_part_",properties={objModel=vv[1],bPhysics=0}})			
				v:AttachChild(new.id,0)
				new:SetScale(vv[4])
				new:SetLocalPos(vv[2])
				new:SetLocalAngles(vv[3])
				table.insert(DEPENDENT_OBJECTS[v.id], new.id)
				
				if(vv[5]) then
					if (type(vv[5])=="table") then
						for ii,p in pairs(vv[5]) do
							new:LoadParticleEffect(-1,p,{CountScale=5,SpeedScale=0.35,PulsePeriod=0.1,Scale=1})
						end
					else
						new:LoadParticleEffect(-1,vv[5],{CountScale=5,SpeedScale=0.35,PulsePeriod=0.1,Scale=1})
					end
				end
				if(vv[6]) then
					new.SoundID_Exhaust = new:PlaySoundEvent(vv[6], g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)
					Sound.SetSoundVolume(new.SoundID_Exhaust, 3)
				end
			end
			
			]]
			
			
			Script.SetTimer(100, function()
			ExecuteOnAll(sCode)
			hVeh.syncId = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			-- hVeh.syncId1 = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			end)
		end
	
	
		local hVehicle = hPlayer:GetVehicle()
		if (hVehicle and hVehicle.class ~= "Civ_car1") then
			return false, "this vehicle cannot become the setup"
		elseif (not hVehicle) then
			Script.SetTimer(100, function()
				hVehicle = System.SpawnEntity({ name = string.format("taxi%d",g_utils:SpawnCounter()), class = "Civ_car1", orientation = hPlayer:GetDirectionVector(), position = add2Vec((hPlayer:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) })
				Script.SetTimer(1500, function()
					MakeTheRide(hVehicle)
				end)
			end)
			SendMsg(CHAT_ATOM, hPlayer, "Here is your Setup")
			return true
		end
		
		if (hVehicle.IsARide) then
			return false, "this vehicle is already a Setup"
		end
		
		MakeTheRide(hVehicle)
		SendMsg(CHAT_ATOM, hPlayer, "Your vehicle has become a real Setup")
	end
})

----------------------------------------------------------------------------------
-- !transportvtol

NewCommand({
	Name 	= "transportvtol",
	Access	= CREATOR,
	Description = "Spawns a transport vtol",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer)

		local aModel = { "objects/vehicles/us_vtol_transport/us_vtol_transport.cga", { x = 0, y = 0.0000, z = -4.10 }, makeVec(0,0,0), false, nil }

		local hVehicle = hPlayer:GetVehicle()
		if (hVehicle and hVehicle.class ~= "US_vtol") then
			return false, "this vehicle cannot become a transport vtol"
		elseif (not hVehicle) then
			Script.SetTimer(100, function()
				hVehicle = System.SpawnEntity({ name = string.format("TransportVTOL_%d",g_utils:SpawnCounter()), class = "US_vtol", orientation = hPlayer:GetDirectionVector(), position = add2Vec((hPlayer:CalcSpawnPos(12, 3)), { x = 0, y = 0, z = -1}) })
				Script.SetTimer(1500, function()
					g_utils:LoadVehicleModel(hVehicle, aModel[1], aModel[2], aModel[3])
				end)
			
				hVehicle.IsTrans = true
				hVehicle.TransRange = 10
				hVehicle.TransCargo = nil
			end)
			
			SendMsg(CHAT_ATOM, hPlayer, "Here is your Transport VTOL")
			return true
		end
		
		if (hVehicle.IsTrans) then
			return false, "this vtol is already a transport vtol"
		end
		
		hVehicle.IsTrans = true
		hVehicle.TransRange = 10
		hVehicle.TransCargo = nil
		
		g_utils:LoadVehicleModel(hVehicle, aModel[1], aModel[2], aModel[3])
		
		SendMsg(CHAT_ATOM, hPlayer, "Your vehicle has become a transport vtol")
	end
})

----------------------------------------------------------------------------------
-- !grab

NewCommand({
	Name 	= "grab",
	Access	= CREATOR,
	Description = "Spawns a transport vtol",
	Console = true,
	Args = {
		{ "Player", "The Name of the target player", SameAccess = true, Target = true, Required = true, NotPlayer = true }
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer, hTarget)

		local hGrabber = hTarget.hGrabber
		if (hGrabber) then

			if (hGrabber.id == hPlayer.id) then
				return false, "you are already grabbing " .. hTarget:GetName()
			end

			SendMsg(CHAT_ATOM, hPlayer, "(%s: Grabbed from %s)", hTarget:GetName(), hGrabber:GetName())
			SendMsg(CHAT_ATOM, hGrabber, "(%s: Stole %s from your Grab)", hPlayer:GetName(), hTarget:GetName())
			hGrabber:GrabPlayer(hTarget, nil, (hGrabber.actor:GetNanoSuitMode() == NANOMODE_STRENGTH and 2125 or 650))
			hPlayer:GrabPlayer(hTarget, nil, nil)
			return true
		end

		hPlayer:GrabPlayer(hTarget, nil, nil)
		SendMsg(CHAT_ATOM, hPlayer, "(%s: Grabbed)", hTarget:GetName())
		SendMsg(CHAT_ATOM, hTarget, "(%s: Grabbed You)", hPlayer:GetName())
	end
})

----------------------------------------------------------------------------------
-- !piggyback

NewCommand({
	Name 	= "piggyback",
	Access	= CREATOR,
	Description = "Spawns a transport vtol",
	Console = true,
	Args = {
		{ "Player", "The Name of the target player", Target = true, Required = true, NotPlayer = true }
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer, hTarget)

		if (hPlayer.bPiggyRiding) then
			hPlayer:PiggyRide(hTarget, false)
		else
			hPlayer:PiggyRide(hTarget, true)
		end

	end
})

----------------------------------------------------------------------------------
-- !piggynpc

NewCommand({
	Name 	= "piggynpc",
	Access	= CREATOR,
	Description = "Spawns an NPC and makes it piggyback ride you",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer, sSpawnNew)

		local bSpawnNew = (sSpawnNew ~= nil)
		Debug(bSpawnNew)
		Debug(table.count(hPlayer.aPiggyNPCs))
		if (not bSpawnNew and table.count(hPlayer.aPiggyNPCs) > 0) then
			SendMsg(CHAT_ATOM, hPlayer, "(Piggyback: NPCs Removed)")
			for i, hEnt in pairs(hPlayer.aPiggyNPCs) do
				System.RemoveEntity(hEnt.id)
			end
			hPlayer.aPiggyNPCs = {}
			return true
		end

		local hCarrier = (hPlayer.hLastPiggyNPC or hPlayer)
		local hNPC = hPlayer:Clone(true)
		hPlayer.hLastPiggyNPC = hNPC

		hNPC:PiggyRide(hCarrier, true)
		SendMsg(CHAT_ATOM, hPlayer, "(Piggyback: NPC Spawned!)")
		table.insert(hPlayer.aPiggyNPCs, hNPC)
		Debug(hNPC:GetName())

		return true
	end
})

----------------------------------------------------------------------------------
-- !motorcycle

NewCommand({
	Name 	= "motorcycle",
	Access	= CREATOR,
	Description = "Spawns ThE rIdE",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
	
	
		local function MakeTheRide(hVeh)
		
			hVeh.IsARide = true
			local sCode = [[
		
			System.LogAlways("Called OK")
			
			local v=GetEnt(']]..hVeh:GetName()..[[')
			if(not v)then return end
			
			v:DrawSlot(0,0)
			v:DrawSlot(3,0)
			v:DrawSlot(4,0)
			
			local vp,va=v:GetPos(),v:GetDirectionVector()
			
			DEPENDENT_OBJECTS[v.id]=DEPENDENT_OBJECTS[v.id]or{}
			for i,vv in pairs(__THEBIKE__ENTITIES__) do
				local new=System.SpawnEntity({class="CustomAmmoPickup",position=vp,orientation=va,name="v_part_",properties={objModel=vv[1],bPhysics=0}})			
				v:AttachChild(new.id,0)
				new:SetScale(vv[4])
				new:SetLocalPos(vv[2])
				new:SetLocalAngles(vv[3])
				table.insert(DEPENDENT_OBJECTS[v.id], new.id)
			end
			
			]]
			
			
			Script.SetTimer(100, function()
			ExecuteOnAll(sCode)
			hVeh.syncId = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			-- hVeh.syncId1 = RCA:SetSync(hVeh, { link = hVeh.id, client = sCode }, true);
			end)
		end
	
	
		local hVehicle = hPlayer:GetVehicle()
		if (hVehicle and hVehicle.class ~= "Civ_car1") then
			return false, "this vehicle cannot become a motorcycle"
		elseif (not hVehicle) then
			Script.SetTimer(100, function()
				hVehicle = System.SpawnEntity({ name = string.format("taxi%d",g_utils:SpawnCounter()), class = "Civ_car1", orientation = hPlayer:GetDirectionVector(), position = add2Vec((hPlayer:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) })
				Script.SetTimer(1500, function()
					MakeTheRide(hVehicle)
				end)
			end)
			SendMsg(CHAT_ATOM, hPlayer, "Here is your motorcycle")
			return true
		end
		
		if (hVehicle.IsARide) then
			return false, "this vehicle is already a motorcycle"
		end
		
		MakeTheRide(hVehicle)
		SendMsg(CHAT_ATOM, hPlayer, "Your vehicle has become a real motorcycle")
	end
})


----------------------------------------------------------------------------------
-- !forcemodel

NewCommand({
	Name 	= "forcemodel",
	Access	= CREATOR,
	Description = "Forces all players to use a specific player model",
	Console = true,
	Args = {
        { "iModel", "The ID of the model to force on players", Optional = true, Default = "list" },
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer, iModel)
		return self:ToggleForceModel(hPlayer, iModel)
	end
});

----------------------------------------------------------------------------------
-- !fmodel

NewCommand({
	Name 	= "fmodel",
	Access	= CREATOR,
	Description = "Toggles the Config Forced Model",
	Console = true,
	Args = {
        { "iModel", "The ID of the model to force on players", Optional = true, Default = "list" },
	},
	Properties = {
		Self = 'RCA',
	},
	func = function(self, hPlayer, iModel)
		if (not IGNORE_CONFIG_MODEL) then
            IGNORE_CONFIG_MODEL = true
        else
            IGNORE_CONFIG_MODEL = false
        end

        SendMsg(CHAT_ATOM, hPlayer, "(ForcedModel: %s Configuration Preset)", string.bool((not IGNORE_CONFIG_MODEL), "Enabled", "Disabled"))
	end
});


----------------------------------------------------------------------------------
-- !stadium

NewCommand({
	Name 	= "stadium",
	Access	= CREATOR,
	Description = "Spawns the Stadium",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
		return self:SpawnStadium(hPlayer)
	end
});

----------------------------------------------------------------------------------
-- !stadiumr

NewCommand({
	Name 	= "stadiumr",
	Access	= CREATOR,
	Description = "Removes the Stadium",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
		return self:RemoveStadium(hPlayer)
	end
});

----------------------------------------------------------------------------------
-- !stadiumdebug

NewCommand({
	Name 	= "stadiumdb",
	Access	= CREATOR,
	Description = "Debugs the Stadium",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
		return self:ResetBalls()
	end
});

----------------------------------------------------------------------------------
-- !joinstadium

NewCommand({
	Name 	= "joinstadium",
	Access	= GUEST,
	Description = "Joins the Stadium",
	Console = true,
	Args = {
		{ "Team", "Team", Optional = true }
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer, sTeam)
		return self:EnterStadium(hPlayer, sTeam)
	end
});

----------------------------------------------------------------------------------
-- !stadiumparty

NewCommand({
	Name 	= "stadiumparty",
	Access	= ADMINISTRATOR,
	Description = "Forces everybody into the stadium!",
	Console = true,
	Args = {
		{ "Team", "Team", Optional = true }
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
		return self:ForceEnterStadium()
	end
});

----------------------------------------------------------------------------------
-- !leavestadium

NewCommand({
	Name 	= "leavestadium",
	Access	= GUEST,
	Description = "Leaves the Stadium",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'ATOMFootBall',
	},
	func = function(self, hPlayer)
		return self:LeaveStadium(hPlayer)
	end
});

----------------------------------------------------------------------------------
-- !runner, Enables Super Speed Mode on Yourself or Specified Player

NewCommand({
	Name 	= "runner",
	Access	= CREATOR,
	Description = "Enables Super Speed Mode on Yourself",
	Console = true,
	Args = {
		{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, Speed)
		if (not Speed and player.RunnerSpeed) then
			player.RunnerSpeed = nil;
			SendMsg(CHAT_ATOM, player, "(SUPER-SPEED: Disabled)");
			ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetSuperSpeed, -1);"); -- -1 means disable
			
			return true;
		end;
		player.RunnerSpeed = (Speed or 25);
		SendMsg(CHAT_ATOM, player, "(SUPER-SPEED: Activated, x%d)", player.RunnerSpeed);
		ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetSuperSpeed, " .. tostring(player.RunnerSpeed) .. ");");
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !jumper, Enables Super jumper Mode on Yourself or Specified Player
--[[
NewCommand({
	Name 	= "jumper",
	Access	= CREATOR,
	Description = "Enables Super jumper Mode on Yourself",
	Console = true,
	Args = {
		{ "Height", "The Jump Height Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, height)
		if (not height and player.JumperHeight) then
			player.JumperHeight = nil;
			SendMsg(CHAT_ATOM, player, "(SUPER-JUMP: Disabled)");
			ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetSuperJump, -1);"); -- -1 means disable
			
			return true;
		end;
		player.JumperHeight = (height or 25);
		SendMsg(CHAT_ATOM, player, "(SUPER-JUMP: Activated, x%d)", player.JumperHeight);
		ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetSuperJump, " .. tostring(player.JumperHeight) .. ");");
		return true;
	end;
});
--]]
----------------------------------------------------------------------------------
-- !sb, Spawns some barrels

NewCommand({
	Name 	= "sb",
	Access	= CREATOR,
	Description = "Spawns some barrels",
	Console = true,
	Args = {
		{ "Amount", "The amount of barrels to spawn", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 10000 }, Default = 5 },
		{ "Sort", "Sorts barrels to prevent massive lag", Optional = true },
	},
	Properties = {
		Self = 'g_utils',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, amount, sortPos)
		if (not player:HasAccess(SUPERADMIN)) then
			amount = maximum(15, amount);
		end;
		local pos = player:CalcSpawnPos(5);
		local models = {
			"objects/library/storage/barrels/barrel_red.cgf";
			"objects/library/storage/barrels/barrel_black.cgf";
			"objects/library/storage/barrels/barrel_blue.cgf";
			"objects/library/storage/barrels/barrel_green.cgf";
			"objects/library/storage/barrels/barrel_explosiv_black.cgf";
		}
		local zs = 100;
		local ns = 10;
		local xs = 10;
		local pos_old = copyTable(pos);
		for i = 1, amount do
			Script.SetTimer(i, function()
				if (sortPos ~= nil) then
					if (i >= zs) then
						zs = zs + 100;
						pos.z = pos.z + 1.2;
						pos.x = pos_old.x;
						pos.y = pos_old.y;
					end;
					if (i >= ns) then
						ns = ns + 10;
						pos.x = pos.x + 0.8;
						pos.y = pos_old.y;
					--	Debug("Reset Y, add to X")
					--	g_utils:SpawnEffect(ePE_Flare, pos, g_Vectors.up, 0.1)
					else
						pos.y = pos.y + 0.8;
						if (i >= xs) then
						--	xs = xs + 10;
						--	pos.x = pos_old.x;
						end;
					end;
				end;
				SpawnGUI(GetRandom(models), pos);
			end);
		end;
		SendMsg(CHAT_ATOM, player, "Spawned [ %d ] Barrels", amount);
	end;
});
----------------------------------------------------------------------------------
-- !spawnturret, Spawns a Turret for u

NewCommand({
	Name 	= "spawnturret",
	Access	= CREATOR,
	Description = "Spawns a turret for u",
	Console = true,
	Args = {
		--{ "Amount", "The amount of barrels to spawn", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 10000 }, Default = 5 },
		{ "Minigun", "Enables minigun on the turret", Optional = true },
		{ "Rockets", "Enables Rockets on the turret", Optional = true },
	},
	Properties = {
		Self = 'g_utils',
	--	Timer = 30,
		RequireRCA = false
	},
	func = function(self, player, noMG, noRockets)
	
		local pos = player:CalcSpawnPos(3, -1)
	
		local Turret = _G["AutoTurret"];
		Turret.Properties.teamName = g_gameRules.class == "PowerStruggle" and (g_game:GetTeam(player.id) == 2 and "black" or "tan") or "egirls";
		--Turret.Properties.species = player:GetChannel();
		--player.species = player:GetChannel(); -- RIP AI!!
		Turret.Properties.objModel = "objects/weapons/multiplayer/air_unit_radar.cgf";
		Turret.Properties.objBarrel = "objects/weapons/multiplayer/ground_unit_gun.cgf";
		Turret.Properties.objBase = "objects/weapons/multiplayer/ground_unit_mount.cgf";
		Turret.Properties.objDestroyed = "objects/weapons/multiplayer/air_unit_destroyed.cgf";
		Turret.Properties.GunTurret.bEnabled = 1
		Turret.Properties.GunTurret.TurnSpeed = 3
		Turret.Properties.GunTurret.bVehiclesOnly = 0
		Turret.Properties.GunTurret.bNoPlayers = 0
		Turret.Properties.GunTurret.MGRange = not noMG and 1 or 80;
		Turret.Properties.GunTurret.RocketRange = not noRockets and 1 or 60;
		
		local turrturr = System.SpawnEntity({ class = "AutoTurret", position = pos, name = "RAPE-MACHINE-" .. self:SpawnCounter() })
		
			
		CryAction.CreateGameObjectForEntity(turrturr.id);
		CryAction.BindGameObjectToNetwork(turrturr.id);
		
		if (g_gameRules.class == "PowerStruggle") then
			g_game:SetTeam(player:GetTeam(), turrturr.id);
		end;
	end;
});
----------------------------------------------------------------------------------
-- !delturrets, Spawns a Turret for u

NewCommand({
	Name 	= "delturrets",
	Access	= CREATOR,
	Description = "removes all player spawned turrets",
	Console = true,
	Args = {
		--{ "Amount", "The amount of barrels to spawn", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 10000 }, Default = 5 },
		--{ "Minigun", "Enables minigun on the turret", Optional = true },
		--{ "Rockets", "Enables Rockets on the turret", Optional = true },
	},
	Properties = {
		Self = 'g_utils',
	--	Timer = 30,
		RequireRCA = false
	},
	func = function(self, player, hasMG, hasRockets)
	
		local t = 0;
		for i, v in pairs(System.GetEntitiesByClass("AutoTurret")or {}) do
			if (v.ISTURRTURR) then
				t = t + 1;
				System.RemoveEntity(v.id);
			end;
		end;
		
		player.TURRTURR = nil;
		player.turretsShootMe = nil;
		player.CanTarget = nil;
		
		if (t > 0) then
			SendMsg(CHAT_ATOM, player, "[ %d ] Turrrets removed", t);
		end;
		return t > 0, "no turrets found"
		
	end;
});

----------------------------------------------------------------------------------
-- !addarena, Spawns a new arena

NewCommand({
	Name 	= "addarena",
	Access	= CREATOR,
	Description = "Spawns a new arena",
	Console = true,
	Args = {
		{ "Arena", "The ID of the arena you wish to spawn", Required = true, Integer = true, PositiveNumber = true, Default = 1 },
	--	{ "Sort", "Sorts barrels to prevent massive lag", Optional = true },
	},
	Properties = {
		Self = 'ATOMBoxingArea',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, iArena)

		return (self:SpawnArena(iArena, player))
	end;
});

----------------------------------------------------------------------------------
-- !delarena, Spawns a new arena

NewCommand({
	Name 	= "delarena",
	Access	= CREATOR,
	Description = "Spawns a new arena",
	Console = true,
	Args = {
		{ "Arena", "The ID of the arena you wish to spawn", Required = true, Integer = true, PositiveNumber = true, Default = 1 },
	--	{ "Sort", "Sorts barrels to prevent massive lag", Optional = true },
	},
	Properties = {
		Self = 'ATOMBoxingArea',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, iArena)

		return (self:EraseArena(iArena, player))
	end;
});

----------------------------------------------------------------------------------
-- !sh, Spawns some houses

NewCommand({
	Name 	= "sv",
	Access	= CREATOR,
	Description = "Spawns some houses",
	Console = true,
	Args = {
		{ "Index", "The index of the list of houses", Optional = true, Integer = true, PositiveNumber = true, Default = 1 },
	--	{ "Sort", "Sorts barrels to prevent massive lag", Optional = true },
	},
	Properties = {
		Self = 'g_utils',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, index)
		local models = {
			[1] = {
				"objects/library/architecture/airfield/terminal_building_b/exterior.cgf";
				"objects/library/architecture/airfield/terminal_building_b/interior.cgf";
				"objects/library/architecture/airfield/terminal_building_b/roof.cgf";
				"objects/library/architecture/airfield/terminal_building_b/walls_first_floor.cgf";
				"objects/library/architecture/airfield/terminal_building_b/walls_ground_floor.cgf";
			},
			[2] = {
				"objects/library/architecture/airfield/terminal/ext_departure_canopy.cgf";
				"objects/library/architecture/airfield/terminal/ext_entrance_roof.cgf";
				"objects/library/architecture/airfield/terminal/ext_entrance_supports.cgf";
				"objects/library/architecture/airfield/terminal/ext_floor.cgf";
				"objects/library/architecture/airfield/terminal/ext_mainwall.cgf";
				"objects/library/architecture/airfield/terminal/ext_pillars1.cgf";
				"objects/library/architecture/airfield/terminal/ext_pillars2.cgf";
				"objects/library/architecture/airfield/terminal/ext_pillars3.cgf";
				"objects/library/architecture/airfield/terminal/ext_pillars4.cgf";
				"objects/library/architecture/airfield/terminal/ext_roof.cgf";
				"objects/library/architecture/airfield/terminal/ext_simplepillars.cgf";
				"objects/library/architecture/airfield/terminal/ext_stairs_departure.cgf";
				"objects/library/architecture/airfield/terminal/ext_topwindowframe.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway1.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway1_pillars.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway1_railing.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway2.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway2_pillars.cgf";
				"objects/library/architecture/airfield/terminal/ext_walkway2_railing.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_cafe.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_departure.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_depstairs.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_entrance.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_helpdesk.cgf";
				"objects/library/architecture/airfield/terminal/ext_windowframes_walkway2.cgf";
				"objects/library/architecture/airfield/terminal/int_2ndfloor.cgf";
				"objects/library/architecture/airfield/terminal/int_2ndfloor_corner1.cgf";
				"objects/library/architecture/airfield/terminal/int_2ndfloor_corner2.cgf";
				"objects/library/architecture/airfield/terminal/int_2ndfloor_railing.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe01.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe02.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe03.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe04.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe05.cgf";
				"objects/library/architecture/airfield/terminal/int_doorframe06.cgf";
				"objects/library/architecture/airfield/terminal/int_entrance_roof.cgf";
				--"objects/library/architecture/airfield/terminal/int_floor.cgf";
				"objects/library/architecture/airfield/terminal/int_floor1.cgf";
				"objects/library/architecture/airfield/terminal/int_floor2.cgf";
				"objects/library/architecture/airfield/terminal/int_floor3.cgf";
				"objects/library/architecture/airfield/terminal/int_floor4.cgf";
				"objects/library/architecture/airfield/terminal/int_floor5.cgf";
				"objects/library/architecture/airfield/terminal/int_floor6.cgf";
				"objects/library/architecture/airfield/terminal/int_floor7.cgf";
				"objects/library/architecture/airfield/terminal/int_floor8.cgf";
				"objects/library/architecture/airfield/terminal/int_floor9.cgf";
				"objects/library/architecture/airfield/terminal/int_floor10.cgf";
				"objects/library/architecture/airfield/terminal/int_floor11.cgf";
				"objects/library/architecture/airfield/terminal/int_floor12.cgf";
				"objects/library/architecture/airfield/terminal/int_floor13.cgf";
				"objects/library/architecture/airfield/terminal/int_floor14.cgf";
				"objects/library/architecture/airfield/terminal/int_floor15.cgf";
				"objects/library/architecture/airfield/terminal/int_floor16.cgf";
				"objects/library/architecture/airfield/terminal/int_floor17.cgf";
				"objects/library/architecture/airfield/terminal/int_floor18.cgf";
				"objects/library/architecture/airfield/terminal/int_floor19.cgf";
				"objects/library/architecture/airfield/terminal/int_floor20.cgf";
				"objects/library/architecture/airfield/terminal/int_floor21.cgf";
				"objects/library/architecture/airfield/terminal/int_floor22.cgf";
				"objects/library/architecture/airfield/terminal/int_floor23.cgf";
				"objects/library/architecture/airfield/terminal/int_floor24.cgf";
				"objects/library/architecture/airfield/terminal/int_floor25.cgf";
				"objects/library/architecture/airfield/terminal/int_floor26.cgf";
				"objects/library/architecture/airfield/terminal/int_floor27.cgf";
				"objects/library/architecture/airfield/terminal/int_floor28.cgf";
				"objects/library/architecture/airfield/terminal/int_floor29.cgf";
				"objects/library/architecture/airfield/terminal/int_floor30.cgf";
				"objects/library/architecture/airfield/terminal/int_floor31.cgf";
				"objects/library/architecture/airfield/terminal/int_floor32.cgf";
				"objects/library/architecture/airfield/terminal/int_floor33.cgf";
				"objects/library/architecture/airfield/terminal/int_floor34.cgf";
				"objects/library/architecture/airfield/terminal/int_floor35.cgf";
				"objects/library/architecture/airfield/terminal/int_floor36.cgf";
				"objects/library/architecture/airfield/terminal/int_floor37.cgf";
				"objects/library/architecture/airfield/terminal/int_floor38.cgf";
				"objects/library/architecture/airfield/terminal/int_floor39.cgf";
				"objects/library/architecture/airfield/terminal/int_floor40.cgf";
				"objects/library/architecture/airfield/terminal/int_floor41.cgf";
				"objects/library/architecture/airfield/terminal/int_floor42.cgf";
				"objects/library/architecture/airfield/terminal/int_floor43.cgf";
				"objects/library/architecture/airfield/terminal/int_floor44.cgf";
				"objects/library/architecture/airfield/terminal/int_floor45.cgf";
				"objects/library/architecture/airfield/terminal/int_floor46.cgf";
				"objects/library/architecture/airfield/terminal/int_floor47.cgf";
				"objects/library/architecture/airfield/terminal/int_gardenframe.cgf";
				"objects/library/architecture/airfield/terminal/int_giftshop_shelf1.cgf";
				"objects/library/architecture/airfield/terminal/int_giftshop_shelf2.cgf";
				"objects/library/architecture/airfield/terminal/int_giftshop_shelf3.cgf";
				"objects/library/architecture/airfield/terminal/int_giftshop_shelf4.cgf";
				"objects/library/architecture/airfield/terminal/int_luggagerack.cgf";
				"objects/library/architecture/airfield/terminal/int_mainwall.cgf";
				"objects/library/architecture/airfield/terminal/int_pillars1.cgf";
				"objects/library/architecture/airfield/terminal/int_pillars4.cgf";
				"objects/library/architecture/airfield/terminal/int_roof.cgf";
				"objects/library/architecture/airfield/terminal/int_shop1_shelf1.cgf";
				"objects/library/architecture/airfield/terminal/int_shop1_shelf2.cgf";
				"objects/library/architecture/airfield/terminal/int_shop1_shelf3.cgf";
				"objects/library/architecture/airfield/terminal/int_shop2_freezer.cgf";
				"objects/library/architecture/airfield/terminal/int_shop2_shelf1.cgf";
				"objects/library/architecture/airfield/terminal/int_shop2_shelf2.cgf";
				"objects/library/architecture/airfield/terminal/int_shop2_shelf3.cgf";
				"objects/library/architecture/airfield/terminal/int_sign_toilets.cgf";
				"objects/library/architecture/airfield/terminal/int_simplepillars.cgf";
				"objects/library/architecture/airfield/terminal/int_stairs.cgf";
				--"objects/library/architecture/airfield/terminal/int_stairs_railing.cgf";
				"objects/library/architecture/airfield/terminal/int_supports1.cgf";
				"objects/library/architecture/airfield/terminal/int_toiletmen_stalls.cgf";
				"objects/library/architecture/airfield/terminal/int_toiletwomen_stalls.cgf";
				"objects/library/architecture/airfield/terminal/int_walls1.cgf";
				"objects/library/architecture/airfield/terminal/int_walls2.cgf";
				"objects/library/architecture/airfield/terminal/int_walls3.cgf";
				"objects/library/architecture/airfield/terminal/int_walls4.cgf";
				"objects/library/architecture/airfield/terminal/int_walls5.cgf";
				"objects/library/architecture/airfield/terminal/int_walls6.cgf";
				"objects/library/architecture/airfield/terminal/int_walls7.cgf";
				"objects/library/architecture/airfield/terminal/int_windowframes_cafe.cgf";
				"objects/library/architecture/airfield/terminal/int_windowframes_depstairs.cgf";
				"objects/library/architecture/airfield/terminal/int_windowframes_entrance.cgf";
				"objects/library/architecture/airfield/terminal/int_windowframes_helpdesk.cgf";
				"objects/library/architecture/airfield/terminal/int_windowframes_walkway2.cgf";
			},
			[3] = {
				"objects/library/architecture/airfield/powerbuilding/powerbuilding.cgf";
				"objects/library/architecture/airfield/powerbuilding/powerbuilding_interior.cgf";
			},
			[4] = {
				"objects/library/architecture/airfield/air_control_tower/air_control_tower_mp.cgf";
			},
			[5] = {
				"objects/library/architecture/airfield/air_control_tower/control_tower_b.cgf";
			},
			[6] = {
				"objects/library/architecture/airfield/air_control_tower/air_control_tower_mockup.cgf";
			},
			[7] = {
				"objects/library/architecture/airfield/air_control_tower_b/air_control_tower_b.cgf";
			},
			[8] = {
				"objects/library/architecture/harbour/control_center/harbor_control_center.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_arch.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_arch01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_arch02.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_big_room.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_big_room_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_big_room_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_decals.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_drawing.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_frame01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_frame02.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_frame03.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_fun.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_garret.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_garret_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_garret_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_a.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_b.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_c.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_d.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_e.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall01_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall01_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall02.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall02_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_hall_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_interior.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_interior_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_interior_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room01_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room01_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room02.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room02_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_room02_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_seats.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_stairs.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_storage01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01_detail_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02_detail_lamp.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet03.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet03_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet04.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet04_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet05.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet05_detail.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet06.cgf";
				"objects/library/architecture/harbour/control_center/harbor_control_center_toilet06_detail.cgf";
			},
			[9] = {
				"objects/library/architecture/harbour/workshop/workshop.cgf";
				"objects/library/architecture/harbour/workshop/workshop_2.cgf";
				"objects/library/architecture/harbour/workshop/workshop_2_detail_breakable.cgf";
				"objects/library/architecture/harbour/workshop/workshop_decal_door.cgf";
				"objects/library/architecture/harbour/workshop/workshop_glass.cgf";
				"objects/library/architecture/harbour/workshop/workshop_in.cgf";
				"objects/library/architecture/harbour/workshop/workshop_in_crane.cgf";
			},
			[10] = {
				"objects/library/architecture/harbour/warehouse/warehouse.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_2.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_base_rampa.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_decal.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_glass_big.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_in.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_kitchen.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_kitchen_wall.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_metal_shelter_cable.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_metal_shelter.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_room_01.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_room_02.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_room_03.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_room_04_01.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_room_5.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_signs.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_stairs.cgf";
				"objects/library/architecture/harbour/warehouse/warehouse_stairs_02.cgf";
			},
			[11] = {
				"objects/library/architecture/hillside_cafe/sleep_house_5_rooms.cgf";
			},
			[12] = {
				"objects/library/architecture/hillside_cafe/cafe_house.cgf",
				"objects/library/architecture/hillside_cafe/terrace.cgf",
				"objects/library/architecture/hillside_cafe/glass_01.cgf",
				"objects/library/architecture/hillside_cafe/glass_02.cgf",
				"objects/library/architecture/hillside_cafe/glass_03.cgf",
				"objects/library/architecture/hillside_cafe/glass_04.cgf",
				"objects/library/architecture/hillside_cafe/glass_05.cgf",
				"objects/library/architecture/hillside_cafe/glass_06.cgf",
				"objects/library/architecture/hillside_cafe/glass_07.cgf",
				"objects/library/architecture/hillside_cafe/glass_08.cgf",
				"objects/library/architecture/hillside_cafe/glass_09.cgf",
				"objects/library/architecture/hillside_cafe/glass_10.cgf",
				"objects/library/architecture/hillside_cafe/glass_11.cgf",
				"objects/library/architecture/hillside_cafe/glass_12.cgf",
				"objects/library/architecture/hillside_cafe/glass_13.cgf",
				"objects/library/architecture/hillside_cafe/glass_14.cgf",
				"objects/library/architecture/hillside_cafe/glass_15.cgf",
			},
			[13] = {
				"objects/library/architecture/village/village_house1.cgf";
			},
			[14] = {
				"objects/library/architecture/village/village_house2.cgf";
			},
			[15] = {
				"objects/library/architecture/village/village_house3.cgf";
			},
			[16] = {
				"objects/library/architecture/village/village_house4.cgf";
			},
			[17] = {
				"objects/library/architecture/village/village_house5.cgf";
			},
			[18] = {
				"objects/library/architecture/village/village_house6.cgf";
			},
			[19] = {
				"objects/library/architecture/village/village_house7.cgf";
			},
			[20] = {
				"objects/library/architecture/village/village_house8.cgf";
			},
			[21] = {
				"objects/library/architecture/village/village_house9.cgf";
			},
		}
		if (not models[index]) then
			return false, "invalid id";
		end;
		local model = models[index];
		local pos = player:CalcSpawnPos(30);
		for i, obj in ipairs(model) do
			SpawnGUI(obj, pos, -1, nil, nil, nil, 1)
		end;
		SendMsg(32, player, "HouseID - [ "..index.." ] - SPAWNED")
	end;
});

----------------------------------------------------------------------------------
-- !st, Spawns some trash

NewCommand({
	Name 	= "st",
	Access	= CREATOR,
	Description = "Spawns some barrels",
	Console = true,
	Args = {
		{ "Amount", "The amount of barrels to spawn", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 10000 }, Default = 5 },
		{ "Sort", "Sorts barrels to prevent massive lag", Optional = true },
	},
	Properties = {
		Self = 'g_utils',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, amount, sortPos)
		if (not player:HasAccess(SUPERADMIN)) then
			amount = maximum(15, amount);
		end;
		local pos = player:CalcSpawnPos(5);
		local models = {
			"objects/library/storage/barrels/barrel_red.cgf";
			"objects/library/storage/barrels/barrel_black.cgf";
			"objects/library/storage/barrels/barrel_blue.cgf";
			"objects/library/storage/barrels/barrel_green.cgf";
			"objects/library/storage/barrels/barrel_explosiv_black.cgf";
			"Objects/Library/storage/trashcontainers/trashbag.cgf";
			"objects/library/storage/trashcontainers/trashcon_med_a.cgf";
			"Objects/Library/storage/trashcontainers/trashcon_orange_a.cgf";
			"Objects/Library/storage/trashcontainers/trashcon_orange_b.cgf";
			"Objects/Library/storage/trashcontainers/trashcon_orange_c.cgf";
			"Objects/Library/Props/trashbins/trash_container_small.cgf";
			"Objects/Library/Props/trashbins/trash_wooden_a.cgf";
			"Objects/Library/Props/trashbins/trash_wooden_b.cgf";
			"Objects/Library/Props/trashbins/trash_wooden_c.cgf";
			"Objects/Library/Props/trashbins/trash_wooden_d.cgf";
			"objects/library/props/trashbins/trashbin.cgf";
			"objects/library/props/trashbins/trash_container_big.cgf";
			"Objects/Library/Props/misc/trashbin_small/trashbin_small.cgf";
			"Objects/Library/Props/misc/trashbin_small/trashbin_small_base.cgf";
			"Objects/Library/Props/bananafarm_tank/bananafarm_tank.cgf";
			"objects/library/props/building material/steel_beam_pack.cgf";
			"objects/library/props/building material/reinforced_pipe_servicehatch_grate.cgf";
			"objects/library/props/building material/tube_stack.cgf";
			"objects/library/props/building material/steel_support_beam_vertical.cgf";
			"objects/library/props/building material/steel_support_beam_vertical_a.cgf";
			"objects/library/props/building material/steel_support_beam_vertical_b.cgf";
			"objects/library/props/building material/steel_support_beam_vertical_c.cgf";
			"objects/library/props/building material/wooden_shelves.cgf";
			"objects/library/props/building material/wooden_stack.cgf";
			"objects/library/props/building material/wooden_support_beam_b_closed.cgf";
			"objects/library/props/electronic_devices/coffeemaker/coffeemaker.cgf";
			"objects/library/props/electronic_devices/computer_racks/flightcase_small_computer.cgf";
			"objects/library/props/electronic_devices/computer_racks/flightcase_small_closed.cgf";
			"objects/library/props/electronic_devices/computer_racks/flightcase_small_open.cgf";
			"objects/library/props/electronic_devices/computer_racks/server/server_03.cgf";
			"objects/library/props/electronic_devices/misc/asian_artifact_scanner/asian_artifact_scanner_bottom.cgf";
			"objects/library/props/electronic_devices/screens/television_old.cgf";
			"objects/library/props/fish/fish2_double.cgf";
			"objects/library/props/fishing_nets/cage_a.cgf";
			"objects/library/props/flowers/flowerpot_harbour_a.cgf";
			"objects/library/props/flowers/flowerpot_harbour_l_a_pink.cgf";
			"objects/library/props/flowers/flowerpot_harbour_s_a_white.cgf";
			"objects/library/props/kable_drum_wooden/kable_drum_wooden_b.cgf";
			"objects/library/props/misc/cooker/cooker.cgf";
			"objects/library/props/misc/pushcart/pushcart.cgf";
			"objects/library/props/misc/shopping_cart/shopping_cart.cgf";
			"objects/library/props/misc/washing_machine/washing_machine.cgf";
			"objects/library/props/oiltanks/oiltank2_destroyed.cgf";
			"objects/library/props/school/table_a.cgf";
			"objects/library/props/school/table_b.cgf";
			"objects/library/props/school/table_c.cgf";
			"objects/library/props/stacks/harbor_stack_small.cgf";
			"objects/library/props/stonelantern/stonelantern.cgf";
			"objects/library/props/watermine/watermine.cgf";
			"objects/library/storage/palettes/palettes_pack_small.cgf";
			"objects/library/storage/palettes/palettes_pack_big.cgf";
			"objects/library/storage/palettes/palettes_pack_big_mp.cgf";
			"objects/library/storage/palettes/palettes_pack_med.cgf";
		}
		local zs = 100;
		local ns = 10;
		local xs = 10;
		local pos_old = copyTable(pos);
		for i = 1, amount do
			Script.SetTimer(i, function()
				if (sortPos ~= nil) then
					if (i >= zs) then
						zs = zs + 100;
						pos.z = pos.z + 1.2;
						pos.x = pos_old.x;
						pos.y = pos_old.y;
					end;
					if (i >= ns) then
						ns = ns + 10;
						pos.x = pos.x + 0.8;
						pos.y = pos_old.y;
					--	Debug("Reset Y, add to X")
					--	g_utils:SpawnEffect(ePE_Flare, pos, g_Vectors.up, 0.1)
					else
						pos.y = pos.y + 0.8;
						if (i >= xs) then
						--	xs = xs + 10;
						--	pos.x = pos_old.x;
						end;
					end;
				end;
				SpawnGUI(GetRandom(models), pos);
			end);
		end;
		SendMsg(CHAT_ATOM, player, "Spawned [ %d ] Trash", amount);
	end;
});


----------------------------------------------------------------------------------
-- !impkills, Enables Impulse kills on Yourself or Specified Player

NewCommand({
	Name 	= "impkills",
	Access	= CREATOR,
	Description = "Enables Impulse kills on Yourself or Specified Player",
	Console = true,
	Args = {
	--	{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player)
		if (not player.ImpulseKills) then
			player.ImpulseKills = true;
		else
			player.ImpulseKills = false;
		end;
		SendMsg(CHAT_ATOM, player, "(IMPULSE-KILLS: %s)", player.ImpulseKills and "Enabled" or "Disabled");
	--	ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetSuperSpeed, " .. tostring(player.RunnerSpeed) .. ");");
		return true;
	end;
});


----------------------------------------------------------------------------------
-- !swimmer, Enables Super Swimmer Mode on Yourself or Specified Player

NewCommand({
	Name 	= "swimmer",
	Access	= CREATOR,
	Description = "Enables Super Swimmer Mode on Yourself",
	Console = true,
	Args = {
	--	{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, Speed)
		if (not Speed and player.RunnerSpeed) then
			SendMsg(CHAT_ATOM, player, "(SUPER-SWIMMER: Disabled)")
			player.RunnerSpeed = nil
			player.HasSuperSwim = false
			return true
		end

		SendMsg(CHAT_ATOM, player, "(SUPER-SWIMMER: Activated)")
		player.RunnerSpeed = (Speed or 25)
		player.HasSuperSwim = true
		return true
	end;
});


------------------------------------------------------------------------
--!modelid, changes ur fukin model


NewCommand({
	Name 	= "modelid",
	Access	= CREATOR,
	Description = "Changes your appearance",
	Console = true,
	Args = {
		{ "Index", "Index of the list of available models", Required = true },
	},
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	},
	func = function(self, player, x)
		return self:RequestModel(player, tonumber(x) or "list", nil, nil, true);
	end;
});


----------------------------------------------------------------------------------
-- !lockdown, Locks down all vehicles and Doors in the Map

NewCommand({
	Name 	= "lockdown",
	Access	= CREATOR,
	Description = "Locks down all vehicles and Doors in the Map",
	Console = true,
	Args = {
	--	{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'ATOMGameUtils',
		--Timer = 30,
		RequireRCA = false
	},
	func = function(self, player, Speed)
		self.LOCK_DOWN = not self.LOCK_DOWN;
		SendMsg(CHAT_ATOM, player, "(LOCKDOWN: %s)", (self.LOCK_DOWN and "ENABLED" or "DISABLED"));
		self:SetDoors(self.LOCK_DOWN);
	end;
});


----------------------------------------------------------------------------------
-- !tauntsystem, Toggles taunt system

NewCommand({
	Name 	= "tauntsystem",
	Access	= CREATOR,
	Description = "Locks down all vehicles and Doors in the Map",
	Console = true,
	Args = {
	--	{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'ATOMTaunt',
		--Timer = 30,
		RequireRCA = false
	},
	func = function(self, player, Speed)
		if (not self) then
			return false, "plugin not loaded";
		end;
		TAUNT_SYSTEM = not TAUNT_SYSTEM;
		SendMsg(CHAT_ATOM, player, "(TAUNTSYSTEM: %s)", (TAUNT_SYSTEM and "ENABLED" or "DISABLED"));
	end;
});

----------------------------------------------------------------------------------
-- !animhandler, Disables or enables the new idle animation handler

NewCommand({
	Name 	= "animhandler",
	Access	= CREATOR,
	Description = "Disables or enables the new idle animation handler",
	Console = true,
	Args = {
	--	{ "Speed", "The Speed Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 250 } },
	},
	Properties = {
		Self = 'ATOMGameUtils',
		--Timer = 30,
		RequireRCA = false
	},
	func = function(self, player, Speed)
		ANIM_HANDLER = not ANIM_HANDLER;
		SendMsg(CHAT_ATOM, player, "(ANIMS: %s)", (ANIM_HANDLER and "ENABLED" or "DISABLED"));
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !walljumper, Enables Super WallJump Mode on Yourself or Specified Player

NewCommand({
	Name 	= "walljumper",
	Access	= CREATOR,
	Description = "Enables Super WallJump Mode on Yourself or Specified Player",
	Console = true,
	Args = {
		{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, Multiplier)
		if (not Multiplier and player.WallJumpMultiplier) then
			player.WallJumpMultiplier = nil;
			SendMsg(CHAT_ATOM, player, "(WALLJUMP: Disabled)");
			ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetWJMult, -1);"); -- -1 means disable
			
			return true;
		end;
		player.WallJumpMultiplier = (Multiplier or 5);
		SendMsg(CHAT_ATOM, player, "(WALLJUMP: Activated, x%d)", player.WallJumpMultiplier);
		ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_SetWJMult, " .. tostring(player.WallJumpMultiplier) .. ");");
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !superman, Enables superman mode on yourself

NewCommand({
	Name 	= "superman",
	Access	= CREATOR,
	Description = "Enables superman mode on yourself",
	Console = true,
	Args = {
		--{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player)
		if (not player.Superman) then
			player.Superman = true;
		else
			player.Superman = false;
		end;
		SendMsg(CHAT_ATOM, player, "(SUPERMAN: %s)", player.Superman and "ENABLED" or "DISABLED");
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !superboxer, Enables super boxer mode on yourself

NewCommand({
	Name 	= "superboxer",
	Access	= CREATOR,
	Description = "Enables super boxer mode on yourself",
	Console = true,
	Args = {
		{ "Multiplier", "The kb Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 500 }, Default = 5 },
	},
	Properties = {
		Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player, scale)
		if (not player.SuperBoxer) then
			player.SuperBoxer = true;
		else
			player.SuperBoxer = false;
		end;
		
		player.SuperBoxerStrength = scale * 80;
		
		SendMsg(CHAT_ATOM, player, "(SUPERBOXER: %s, x%d)", player.SuperBoxer and "ENABLED" or "DISABLED", scale);
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !nitro, Enables Super Nitro Boosters on your Vehicle

NewCommand({
	Name 	= "nitro",
	Access	= CREATOR,
	Description = "Enables Super WallJump Mode on Yourself or Specified Player",
	Console = true,
	Args = {
		{ "Amount", "The Number of Nitro Rockets to Equip your vehicle with", Optional = true, Integer = true, PositiveNumber = true, Range = { 0, 36 } },
	},
	Properties = {
		Self = 'RCA',
		Timer = 5,
		RequireRCA = true,
		RequireVehicle = true
	},
	func = function(self, player, Vehicle, Amount)
		local Amount = Amount or 2;
		if (Amount == 0) then
			SendMsg(CHAT_ATOM, player, "(NITRO: Disabled)");
			ExecuteOnAll([[
				local v=GetEnt(']]..Vehicle:GetName()..[[');
				if (v) then
					for i, nitro in pairs(v.LaunchedNitros) do
						if (nitro.NitroSlot) then
							nitro:FreeSlot(nitro.NitroSlot);
						end;
						System.RemoveEntity(nitro.id);
					end;
					v.LaunchedNitros = nil;
				end;
			]])
			self:Unsync(Vehicle.id);
			Vehicle.Nitro = false;
			return true;
		end;
		
		if (Vehicle.Nitro) then
			ExecuteOnAll([[
				local v=GetEnt(']]..Vehicle:GetName()..[[');
				if (v) then
					for i, nitro in pairs(v.LaunchedNitros) do
						if (nitro.NitroSlot) then
							nitro:FreeSlot(nitro.NitroSlot);
						end;
						System.RemoveEntity(nitro.id);
					end;
					v.LaunchedNitros = nil;
				end;
			]])
			self:Unsync(Vehicle.id);
			Vehicle.Nitro = false;
		end;
		
		local limit = 4;
		if (player:HasAccess(SUPERADMIN)) then
			limit = 36;
		elseif (player:HasAccess(SUPERADMIN)) then
			limit = 12;
		end;
		
		local xd = 1.4;
		local yd = 1;
		local zs = 0.2;
		if (Vehicle.class:find("tank") or Vehicle.class:find("apc") or Vehicle.class:find("Asian_aaa")) then
			xd =2.2
			yd =-0.5;
			zs = 0.2;
		elseif (Vehicle.class:find("vtol")) then
			zs = -2;
			yd =-1.5;
			xd = 1.8
		end;
		local code = [[
			local v=GetEnt(']]..Vehicle:GetName()..[[');
			if (v) then
				v.LaunchedNitros = {}
				local perside = ]] .. math.min(limit, math.max(Amount, 1)) .. [[
				local z = ]]..zs..[[;
				for j = 1, 2 do
					z = ]]..zs..[[;
					for i = 1, perside do
						z = z + 0.5;
						table.insert(v.LaunchedNitros, System.SpawnEntity({position={x=0,y=0,z=0},class="CustomAmmoPickup",name=v:GetName().."_rocket_" ..(j==1 and "R" or "L") .. "_"..i,properties={objModel="objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf",bPhysics=1}}));
						v:AttachChild(v.LaunchedNitros[#v.LaunchedNitros].id, 1);
						v.LaunchedNitros[#v.LaunchedNitros]:SetLocalPos(j==1 and {x=]]..xd..[[,y=]]..yd..[[,z=z} or {x=-]]..xd..[[,y=]]..yd..[[,z=z});
						v.LaunchedNitros[#v.LaunchedNitros]:SetLocalAngles({x=-1.572,y=0,z=0});
					end;
				end;
				v.NitroMode = true;
				System.LogAlways("RCOKETS  ON!")
			end;
		]];
		self:SetSync(Vehicle, { link = true, client = code }, true);
		ExecuteOnAll(code);
		Vehicle.Nitro = true;
		SendMsg(CHAT_ATOM, player, "(NITRO: Mounted x%d Nitro Tanks)", Amount);
		return true;
	end;
});



-------------------------------------------------------------------
-- !firetruck

NewCommand({
	Name 	= "firetruck",
	Access	= CREATOR,
	Console = true,
	Description = "Spawns a fire truck for you";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}},
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } },
	},
	Properties = {
		Self = 'ATOMGameUtils',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 5,
		Cost = 50,
	},
	func = function(self, player, x)
		SendMsg(CHAT_ATOM, player, "Here is your Fire Truck!");
		Script.SetTimer(1, function()
			local pos = player:CalcSpawnPos(8);
			self:SpawnEffect(ePE_Light, pos);
			local superCab = System.SpawnEntity({ class = "US_tank", name = "ATOMIC-SUPER-FIRETRUCK-" .. self:SpawnCounter(), position = pos, orientation = player:GetHeadDir(), properties = {} });
			self:AwakeEntity(superCab);
			superCab.waterID = x and 2 or 1;
			superCab.WaterTank = 1;
			superCab.NoBuyAmmo = 1;
			
		end);
	end;
});

----------------------------------------------------------------------------------
-- !megac4, Enables Mega C4 Mode on Yourself or Specified Player

NewCommand({
	Name 	= "megac4",
	Access	= CREATOR,
	Description = "Enables Mega C4 Mode on Yourself",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self)
		self.MegaC4 = not self.MegaC4;
		SendMsg(CHAT_ATOM, self, "(MEGAC4: %s)", (self.MegaC4 and "Activated" or "Deactived"));
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !vending, Spawns a vending machine in fron of you

NewCommand({
	Name 	= "vending",
	Access	= CREATOR,
	Description = "Spawns a vending machine in fron of you",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 30,
	--	RequireRCA = true
	},
	func = function(player)
		--local vending = System.SpawnEntity({ class = "InteractiveEntity", name = "VendingMachine_" .. g_utils:SpawnCounter(), position = self:CalcSpawnPos(3), orientation = self:GetDirectionVector() });
		local vending = g_utils:Spawn({ AdjustPos = true, Dir = player:GetDirectionVector(), Pos = player:CalcSpawnPos(3), Class = "InteractiveEntity", SpawnRadius = 1, Name = "Vending_MAchine_" .. g_utils:SpawnCounter(), Count = 1 });
		--Debug(vending:GetName())
		CryAction.CreateGameObjectForEntity(vending.id);
		CryAction.BindGameObjectToNetwork(vending.id);
		CryAction.ForceGameObjectUpdate(vending.id, true);
		
		SendMsg(CHAT_ATOM, player, "Here is your Vending Machine!");
	end;
});


----------------------------------------------------------------------------------
-- !hologram, Spawns a loyal horse for you

NewCommand({
	Name 	= "hologram",
	Access	= DEVELOPER,
	Description = "Spawns a loyal horse for you",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 30,
		Hidden = true,
		Disabled = true
	--	RequireRCA = true
	},
	func = function(player)
		--local vending = System.SpawnEntity({ class = "InteractiveEntity", name = "VendingMachine_" .. g_utils:SpawnCounter(), position = self:CalcSpawnPos(3), orientation = self:GetDirectionVector() });
		Script.SetTimer(100, function()
			local vending = SpawnBSE({
				Model = "objects/library/alien/generic_elements/hologram_machine/hologram_machine_default.cga",
				Dir = g_Vectors.down,
				Pos = player:CalcSpawnPos(2),
				Mass = 1000,
				bHasPhys = 1,
			}); --g_utils:Spawn({ AdjustPos = true, Dir = player:GetDirectionVector(), Pos = player:CalcSpawnPos(3), Class = "InteractiveEntity", SpawnRadius = 1, Name = "Vending_MAchine_" .. g_utils:SpawnCounter(), Count = 1 });
			vending.OnUsed = function(self, user)
				if (self.Open) then
					ExecuteOnAll([[GetEnt(']] .. self:GetName() .. [['):StartAnimation(0, "machine_default_03");]]);
				else
					ExecuteOnAll([[GetEnt(']] .. self:GetName() .. [['):StartAnimation(0, "machine_default_01");]]);
				end;
				self.Open = not self.Open;
				self:StartAnimation(0, self.Open and "machine_default_01" or "machine_default_03"); -- reversed
				self:AddImpulse(0, makeVec(), makeVec(), 1, 1);
			end;
			vending.MarkedForUse = true;
			local code = [[
				local h = GetEnt(']] .. vending:GetName() .. [[');
				h.IsUsable = function()return 1 end;
			]];
			Script.SetTimer(1000, function()
				ExecuteOnAll(code);
				RCA:SetSync(vending, {link=vending,client=code});
			end)
		end)
		--Debug(vending:GetName())
		--CryAction.CreateGameObjectForEntity(vending.id);
		----CryAction.BindGameObjectToNetwork(vending.id);
		--CryAction.ForceGameObjectUpdate(vending.id, true);
		
		SendMsg(CHAT_ATOM, player, "Here is your Loyal Dog.. or something");
	end;
});

----------------------------------------------------------------------------------
-- !aaa, Spawns an anti air thingy

NewCommand({
	Name 	= "aaa",
	Access	= CREATOR,
	Description = "Spawns an anti air thingy",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 15,
	--	RequireRCA = true
	},
	func = function(hPlayer)
		
		local vSpawnPos = hPlayer:CalcSpawnPos(3, -1.1)
		local hAAAStand = SpawnGUINew({Model="objects/weapons/multiplayer/ground_unit_stand.cgf", Pos=vSpawnPos,Mass=-1,bStatic=true,NoPhys=false});
		local hAAAMount = SpawnGUINew({Model="objects/weapons/multiplayer/ground_unit_mount.cgf", Pos=vector.modify(vSpawnPos, "z", 6.5, 1),Mass=-1,bStatic=true,NoPhys=false});
		local hAAA = SpawnGUINew({Model="objects/weapons/multiplayer/ground_unit_radar.cgf", Pos=vector.modify(vSpawnPos, "z", 8, 1),Mass=-1,bStatic=true,NoPhys=false});
		
		hAAA.hAAAStand = hAAAStand
		hAAA.hAAAMount = hAAAMount
		
		hAAA.TargetRadius = 250
		hAAA.TargetClasses = {
			"US_vtol",
			-- "Player"
		}
		
		ANTI_AIR_GUNS[hAAA.id] = hAAA
		SendMsg(CHAT_ATOM, hPlayer, "Here is your AAA")
	end
});

----------------------------------------------------------------------------------
-- !sphere, Spawns a protective sphere for you

NewCommand({
	Name 	= "sphere",
	Access	= CREATOR,
	Description = "Spawns a protective sphere for you",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 5,
	--	RequireRCA = true
	},
	func = function(player)
		if (not player.ProtectionSphere) then
			SendMsg(CHAT_ATOM, player, "There is your Sphere");
			local sphere = SpawnGUINew({Model="Objects/library/alien/ship_exterior/sphere_around_ship/zero_g_sphere.cgf", Pos=player:GetPos(),Mass=1,bStatic=false,NoPhys=false});
			sphere:SetScale(0.02)
		--player:AttachChild(sphere.id,2);
			Script.SetTimer(1000, function()
				player.ProtectionSphere = sphere
				player.ProtectionSphereRad = 32;
				local code=[[local s,_p=GetEnt("]]..sphere:GetName()..[["),GP(]]..player:GetChannel()..[[);if(not (s or _p))then return end;s:SetMaterial("objects/library/alien/ship_exterior/sphere_around_ship/zerogspherescene2")STICKY_POSITIONS[s.id]={_p.id,nil,nil,true}]];
				sphere.syncId = RCA:SetSync(player, {client=code,link=true})
				ExecuteOnAll(code)
			end);
		else
			SendMsg(CHAT_ATOM, player, "Your Sphere was removed");
			RCA:StopSync(player.ProtectionSphere, player.ProtectionSphere.syncId);
			System.RemoveEntity(player.ProtectionSphere.id)
			player.ProtectionSphere = nil;
		end;
	end;
});

----------------------------------------------------------------------------------
-- !minisphere, Spawns a protective sphere for you

NewCommand({
	Name 	= "minisphere",
	Access	= CREATOR,
	Description = "Spawns a protective sphere for you",
	Console = true,
	Args = {
	--	{ "Multiplier", "The Jump Multiplier", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 1500 } },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 5,
	--	RequireRCA = true
	},
	func = function(player)
		if (not player.ProtectionSphere) then
			SendMsg(CHAT_ATOM, player, "There is your Sphere");
			local sphere = SpawnGUINew({Model="Objects/library/alien/ship_exterior/sphere_around_ship/zero_g_sphere.cgf", Pos=player:GetPos(),Mass=1,bStatic=false,NoPhys=false});
			sphere:SetScale(0.005)
		--player:AttachChild(sphere.id,2);
			Script.SetTimer(1000, function()
				player.ProtectionSphere = sphere
				player.ProtectionSphereRad = 8;
				Debug(sphere:GetName())
				local code=[[Msg(0,'>>]]..sphere:GetName()..[[')local s,_p=GetEnt(']]..sphere:GetName()..[['),GP(]]..player:GetChannel()..[[);if(not (s or _p))then return end;s:SetMaterial("objects/library/alien/ship_exterior/sphere_around_ship/zerogspherescene2")STICKY_POSITIONS[s.id]={_p.id,nil,nil,true}]];
				player.hSphereSyncID = RCA:SetSync(player, {client=code,link=true,links={sphere.id,player.id}})
				ExecuteOnAll(code)
			end);
		else
			SendMsg(CHAT_ATOM, player, "Your Sphere was removed")
			
			RCA:StopSync(player, player.hSphereSyncID)
			player.hSphereSyncID = nil
			
			System.RemoveEntity(player.ProtectionSphere.id)
			player.ProtectionSphere = nil
		end;
	end;
});

----------------------------------------------------------------------------------
-- !vspam, Spawms civ cars 

NewCommand({
	Name 	= "vspam",
	Access	= CREATOR,
	Description = "Spawms civ cars ",
	Console = true,
	Args = {
		{ "Amount", "Number of cars", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 10 }, Default = 3 },
	},
	Properties = {
	--	Self = 'RCA',
		--Timer = 5,
	--	RequireRCA = true
	},
	func = function(player, amt)
		for i = 1, amt do
			Script.SetTimer(i*100, function()
				local v=System.SpawnEntity({class="Civ_car1",position = player:CalcSpawnPos(3, 1),name="CRASHCAR_"..g_utils:SpawnCounter()});
				v:AddImpulse(-1, v:GetPos(), player:GetHeadDir(), 100000, 1);
			end);
		end;
	end;
});

----------------------------------------------------------------------------------
-- !chair, Spawns a flying chair in front of you

NewCommand({
	Name 	= "chair",
	Access	= CREATOR,
	Description = "Spawns a flying chair in front of you",
	Console = true,
	Args = {
		{ "Model", "The ID of the Model for your Chair", Optional = true, Integer = true },
	},
	Properties = {
	--	Self = 'RCA',
		Timer = 30,
	--	RequireRCA = true
	},
	func = function(player, modelid)
		local models = {
			[0] = "",
			[1] = "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/console_chair.cgf",
			[2] = "Objects/library/furniture/chairs/cafe_chair_frozen.cgf",
			[3] = "objects/library/furniture/chairs/bank_wooden_01.cgf",
			[4] = "objects/library/furniture/chairs/chair_wooden_01.cgf",
			[5] = "objects/library/furniture/chairs/office_chair.cgf",
			[6] = "objects/library/furniture/chairs/hillside_cafe_chair_bar.cgf",
			[7] = "objects/library/furniture/chairs/hillside_cafe_couch.cgf",
			[8] = "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/captains_chair.cgf",
			[9] = "objects/library/architecture/aircraftcarrier/props/furniture/chairs/captains_loungechair.cgf",
			[10] = "objects/library/architecture/aircraftcarrier/props/furniture/chairs/console_chair_bag.cgf",
			[11] = "Objects/library/installations/sanitary/toilet.cgf",
			[12] = "objects/library/installations/sanitary/france_toilet.cgf"
		
		}
		local model = (not modelid or not tonumber(modelid) or not models[tonumber(modelid)]) and models[1] or models[tonumber(modelid)];
		if (model == "") then
			model = models[math.random(10)];
		end;
		--Debug(fixPos(player:CalcSpawnPos(3)))
		local seat = SpawnGUI(model, fixPos(player:CalcSpawnPos(2, -1)));
		seat.chair = true;
		
		seat:Physicalize(0, PE_RIGID, {mass=100});
		seat:AwakePhysics(1);
		
		--g_gameRules.Server:RequestSpectatorTarget(player.id, eCR_ChairON);

		Script.SetTimer(500, function()
			local code = [[ATOMClient:ClientEvent(1, ']] .. seat:GetName() .. [[')]]
			seat.syncId1 = RCA:SetSync(seat, {linked=seat.id,client=code})
			ExecuteOnAll(code)
			SendMsg(CHAT_ATOM, player, "Here is your Chair!")
			REMOVE_OBJECTS[seat.id] = { _time, 60 * 3, "player" }
		end)
		player.keepChair = true
	end
})


----------------------------------------------------------------------------------
-- !dsg1, Spawns the DSG1 Aim Map

NewCommand({
	Name 	= "dsg1",
	Access	= CREATOR,
	Description = "Spawns the DSG1 Aim Map",
	Console = true,
	Args = {
	--	{ "Model", "The ID of the Model for your Chair", Optional = true, Integer = true },
	},
	Properties = {
		Self = 'ATOMBoxingArea',
		Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player, nodel)
		if (_DSG_1_AIMMAPS and not nodel) then
			for i, v in pairs(_DSG_1_AIMMAPS) do
				for _i, _v in pairs(v) do
					System.RemoveEntity(_v.id);
				end;
			end;
			_DSG_1_AIMMAPS = {},
			SendMsg(CHAT_ATOM, player, "Old map Removed");
		end;
		_DSG_1_AIMMAPS = _DSG_1_AIMMAPS or {}
		_DSG_1_AIMMAPS[#_DSG_1_AIMMAPS+1] = self:SpawnArea(nil, true, true, player:GetPos());
		SendMsg(CHAT_ATOM, player, "Here is your DSG1-Aim Map");
	end;
});


----------------------------------------------------------------------------------
-- !trapgun, Spawns a trap gun

NewCommand({
	Name 	= "trapgun",
	Access	= CREATOR,
	Description = "Spawns a trap gun",
	Console = true,
	Args = {
		{ "Index", "Index of the list of possible trap guns", Optional = true, Default = "list" },
	},
	Properties = {
		Self = 'g_utils',
		Timer = 1,
	--	RequireRCA = true
	},
	func = function(self, hPlayer, hIndex)

		local aGuns = {
			['M4A1'] 			= "Objects/weapons/us/m4a1/m4a1_tp.cgf",
			['FY71'] 			= "Objects/weapons/asian/fy71/fy71_tp.cgf",
			['Shotgun'] 		= "Objects/weapons/us/shotgun/shotgun_tp.cgf",
			['TacGun'] 			= "objects/weapons/us/tac_gun/tac_gun_tp.cgf",
			['Hurricane'] 		= "Objects/weapons/us/hurricane/hurricane_tp.cgf",
			['SCAR'] 			= "objects/weapons/us/scar/scar_l-c_tp.cgf",
			['SMG'] 			= "objects/weapons/us/smg/smg_tp.cgf",
			['AlienMount'] 		= "objects/weapons/us/alien_weapon_mount/alien_weapon_mount_tp.cgf",
			['SOCOM']			= "objects/weapons/us/socom/socom_tp.cgf",
			['LAW'] 			= "objects/weapons/us/law/law_tp.cgf",
			['GaussRifle'] 		= "objects/weapons/us/gauss/gauss_tp.cgf",
			['DSG1'] 			= "objects/weapons/us/sniper_dsg1/sniper_dsg1_tp.cgf",
		}

		local hIndex = checkVar(hIndex, "list")
		local aGun = aGuns[hIndex];
		Debug(hIndex)

		if (not aGun) then
			if (hIndex == "0" or hIndex == "del") then
				local aPlayerGuns = hPlayer.aTrapGuns
				local iPlayerGuns = table.count(aPlayerGuns)
				if (iPlayerGuns <= 0) then
					return false, "You don't have any Trap Guns"
				end

				for hId, hGun in pairs(aPlayerGuns) do
					System.RemoveEntity(hGun.hWeapon.id)
					System.RemoveEntity(hGun.hPod.id)
				end

				SendMsg(CHAT_ATOM, hPlayer, "[ %d ] - Trap guns removed", iPlayerGuns)
				hPlayer.aTrapGuns = {}

			else
				ListToConsole(hPlayer, aGuns, "Options", true)
			end
			return true
		end
		
		local hNewGun, hPod = self:AddTrapGun(hIndex, hPlayer:GetPos(), hPlayer:GetDirectionVector())

		hPlayer.aTrapGuns = (hPlayer.aTrapGuns or {})
		hPlayer.aTrapGuns[hNewGun.id] = {
			hWeapon = hNewGun,
			hPod = hPod
		},
	
		SendMsg(CHAT_ATOM, player, "(%s: Spawned)", hIndex)
	end
})

----------------------------------------------------------------------------------
-- !trapgun, Spawns a trap gun

NewCommand({
	Name 	= "aigunner",
	Access	= CREATOR,
	Description = "Spawns a trap gun",
	Console = true,
	Args = {
		{ "Index", "Index of the list of possible trap guns", Optional = true, Default = "list" },
	},
	Properties = {
		Self = 'g_utils',
		Timer = 1,
	--	RequireRCA = true
	},
	func = function(self, hPlayer, hIndex)

		local aGuns = {
			['M4A1'] 			= "Objects/weapons/us/m4a1/m4a1_tp.cgf",
			['FY71'] 			= "Objects/weapons/asian/fy71/fy71_tp.cgf",
			['Shotgun'] 		= "Objects/weapons/us/shotgun/shotgun_tp.cgf",
			['TacGun'] 			= "objects/weapons/us/tac_gun/tac_gun_tp.cgf",
			['Hurricane'] 		= "Objects/weapons/us/hurricane/hurricane_tp.cgf",
			['SCAR'] 			= "objects/weapons/us/scar/scar_l-c_tp.cgf",
			['SMG'] 			= "objects/weapons/us/smg/smg_tp.cgf",
			['AlienMount'] 		= "objects/weapons/us/alien_weapon_mount/alien_weapon_mount_tp.cgf",
			['SOCOM']			= "objects/weapons/us/socom/socom_tp.cgf",
			['LAW'] 			= "objects/weapons/us/law/law_tp.cgf",
			['GaussRifle'] 		= "objects/weapons/us/gauss/gauss_tp.cgf",
			['DSG1'] 			= "objects/weapons/us/sniper_dsg1/sniper_dsg1_tp.cgf",
		}

		local hIndex = checkVar(hIndex, "list")
		local aGun = aGuns[hIndex];

		if (not aGun) then

			if (hIndex == "0" or hIndex == "del") then

				local aPlayerGuns = hPlayer.aAITrapGuns
				local iPlayerGuns = table.count(aPlayerGuns)
				if (iPlayerGuns <= 0) then
					return false, "You don't have any Trap Guns"
				end

				for hId, hGun in pairs(aPlayerGuns) do
					System.RemoveEntity(hGun.hWeapon.id)
					System.RemoveEntity(hGun.hPod.id)
				end

				SendMsg(CHAT_ATOM, hPlayer, "[ %d ] - Trap guns removed", iPlayerGuns)
				hPlayer.aAITrapGuns = {}
			else
				ListToConsole(hPlayer, aGuns, "Options", true)
			end
			return true
		end

		local hNewGun, hPod = self:AddTrapGun(hIndex, hPlayer:GetPos(), hPlayer:GetDirectionVector(), 1)

		hPlayer.aAITrapGuns = (hPlayer.aAITrapGuns or {})
		hPlayer.aAITrapGuns[hNewGun.id] = {
			hWeapon = hNewGun,
			hPod = hPod
		},

		SendMsg(CHAT_ATOM, player, "(%s: Spawned)", hIndex)
	end
})

----------------------------------------------------------------------------------
-- !meeting, Starts a new meeting or join current one

NewCommand({
	Name 	= "meeting",
	Access	= GUEST,
	Description = "Starts a new meeting or join current one",
	Console = true,
	Args = {
		{ "Option", "Option for the Meeting", Required = false },
	},
	Properties = {
	--	Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
		Escape = true,
	},
	func = function(self, option)
		local creator = self:HasAccess(CREATOR);
		if (not option and self.InMeeting) then option = self.MeetingChairID end
		if (not option or option == "new") then
			if (THE_MEETING) then
				--if (not creator) then
				--	return false, "choose a valid seat";
				--end;
				return false, "choose a valid seat";
			else
				if (not creator) then
					return false, "there is no meeting active right now"
				end;
				THE_MEETING = {
					Table1 = { Used = false, Entity = nil, },
					Table2 = { Used = false, Entity = nil, },
					Table3 = { Used = false, Entity = nil, },
					Table4 = { Used = false, Entity = nil, },
					Table5 = { Used = false, Entity = nil, },
					Table6 = { Used = false, Entity = nil, },
					
					Chair1 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3, 	Chair = true, ChairId = 1 },
					Chair2 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3, 	Chair = true, ChairId = 2 },
					Chair3 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3, 	Chair = true, ChairId = 3 },
					Chair4 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6, 	Chair = true, ChairId = 4 },
					Chair5 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6, 	Chair = true, ChairId = 5 },
					Chair6 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6, 	Chair = true, ChairId = 6 },
					Chair7 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -1.0, DirLimitR = 1.0, 	Chair = true, ChairId = 7 },
					Chair8 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -99, DirLimitR = 99, 		Chair = true, ChairId = 8 },
					
					RandomFood = { -- Randomly placed objects across the tables
					},
				}
				local StartPos = self:CalcSpawnPos(3);
				local x, y = 0, 0;
				local p;
				local strCL = [[
				local p=function(c)
					c.GetUsableMessage=function()return"Sit"end;
					c.IsUsable=function(self)return 1 end;
					c.OnUsed=function(self,u)ATOMClient:ToServer(eTS_Spectator,eCE_JoinMeeting or 50)end;
				end;
				]]
				for i = 1, 6 do
					if (i == 4) then
						y = 0;
						x = (CryAction.IsImmersivenessEnabled() and 1 or 1.15);
					elseif (i>1) then
						y = y + (CryAction.IsImmersivenessEnabled() and 2 or 2.3);
					end;
					p = add2Vec(StartPos, { x = x, y = y, z = 0 }); p.z = GetGroundPos(p);
					
					THE_MEETING["Table"..i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "objects/library/furniture/tables/table_asian.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						makeVec(0,0,0),
						nil,
						1,
						250,
						nil,
						nil,
						nil
					);
				end;
				x, y = 0, 0;
				local d, p;
				
				for i = 1, 6 do
					if (i < 4) then
						x = -1.0
						if (i > 1) then
							y = y + (CryAction.IsImmersivenessEnabled() and 2 or 2.3);
						end;
						d = makeVec(0,0,0);
					else
						x = 2.0;
						if (i == 4) then
							y=0;
						else
							y = y + (CryAction.IsImmersivenessEnabled() and 2 or 2.3);
						end;
						d = makeVec(0,0,-1.57272);
					end;
					p = add2Vec(StartPos, { x = x, y = y, z = 0 }); p.z = GetGroundPos(p)
					THE_MEETING["Chair"..i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/mess_chair.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						d,
						nil,
						1,
						250,
						nil,
						nil,
						nil
					);
					THE_MEETING["Chair".. i].Entity.isMeetingChair = true
					THE_MEETING["Chair".. i].BindPos = add2Vec(p,makeVec(0,0,0))--0.5)
					strCL = strCL .. "p(GetEnt('"..THE_MEETING["Chair"..i].Entity:GetName().."'))"
					--ExecuteOnAll([[
					--	
					--]]);
				end;
				Script.SetTimer(1000, function()
					ExecuteOnAll(strCL)
				end)
				x, y = 0, 0;
				p, d = nil, nil;
				for i = 1, 2 do
					if (i == 1) then
						x = 0.5
						y = -1.5
						d = makeVec(0,0,0)
					else
						x = 0.5
						y = 5.6
						d = makeVec(0,-1,0)
					end;
					p = add2Vec(StartPos, { x = x, y = y, z = 0 }); p.z = GetGroundPos(p)
					THE_MEETING["Chair" .. 6 + i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/mess_chair.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						nil,
						nil,
						1,
						250,
						nil,
						nil,
						d
					);
					THE_MEETING["Chair" .. 6 + i].BindPos = add2Vec(p,makeVec(0,0,0));
				end;
				x, y = 0.5, 0;
				p, d = nil, nil;
				local rX, rY = 0, 0;
				local rP = makeVec(0,0,0);
				local food = {
					"objects/library/props/household/cans/beverage_can_a.cgf",
					"objects/library/props/household/cans/beverage_can_b.cgf",
					"objects/library/props/household/cans/beverage_can_c.cgf",
					"objects/library/props/household/kitchen/basin_small.cgf",
					"objects/library/props/household/kitchen/basin_small.cgf",
					"objects/natural/fruits_vegetables/potato_breakable.cgf",
					"objects/natural/fruits_vegetables/apple_breakable.cgf",
					"objects/natural/fruits_vegetables/honeymelon_breakable.cgf",
					"objects/natural/fruits_vegetables/orange_breakable.cgf",
					"objects/natural/fruits_vegetables/pineapple_breakable.cgf",
					"objects/natural/fruits_vegetables/potato_breakable.cgf",
					"objects/natural/fruits_vegetables/apple_breakable.cgf",
					"objects/natural/fruits_vegetables/honeymelon_breakable.cgf",
					"objects/natural/fruits_vegetables/orange_breakable.cgf",
					"objects/natural/fruits_vegetables/pineapple_breakable.cgf",
					"objects/natural/fruits_vegetables/potato_breakable.cgf",
					"objects/natural/fruits_vegetables/apple_breakable.cgf",
					"objects/natural/fruits_vegetables/honeymelon_breakable.cgf",
					"objects/natural/fruits_vegetables/orange_breakable.cgf",
					"objects/natural/fruits_vegetables/pineapple_breakable.cgf",
				}
				local foodEnv={0,food,arrSize(food)}
				
				--for ii = 0, 0 do
				--	for iii = 0, 0 do
				--		p = add2Vec(StartPos, { x = x + math.random(-10,10)/15, y = y + math.random(-10,10)/15, z = -1.4 });
				--		foodEnv[1]=foodEnv[1]+1
				--		if (foodEnv[1]>foodEnv[3]) then
				--			foodEnv[1]=1
				--		end;
				--		table.insert(THE_MEETING["RandomFood"], SpawnGUI(
				--			food[foodEnv[1]],
				--			p,
				--			5,
				--			1,
				--			nil,
				--			false,
				--			false,
				--			250,
				--			nil,
				--			nil,
				--			d
				--		));
				--	end;
				--	y = y + 2
				--end;
			end;
			SendMsg(CHAT_ATOM, ALL, "A New Meeting has started, to join type !meeting");
		elseif (option:lower() == "del" and creator) then
			if (not THE_MEETING) then
				return false, "there is no active meeting";
			end;
			for i, entity in pairs(THE_MEETING) do
				if (entity.Used and entity.User and System.GetEntity(entity.User)) then
					if (not entity.Bot) then
						ExecuteOnAll([[local p=GetEnt(']]..self:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]=nil LOOPED_ANIMS[p.id]=nil if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(false)end end;]]);
						RCA:Unsync(self.id, self.MeetingSyncId);
						entity.User = nil;
						entity.Used = false;
						self.InMeeting = false;
						self.MeetingChairID = nil;
						g_game:MovePlayer(self.id, self.OldPos, self.OldAng);
						g_utils:SpawnEffect(ePE_Light, self.OldPos, self.OldAng);
					else
						System.RemoveEntity(entity.User);
					end;
				end;
				if (entity.Entity) then
					System.RemoveEntity(entity.Entity.id);
				end;
			end;
			for i, entity in pairs(THE_MEETING.RandomFood or {}) do
				System.RemoveEntity(entity.id);
			end;
			SendMsg(CHAT_ATOM, ALL, "The meeting has ended");
			THE_MEETING = nil;
		elseif (option:lower() == "addbot" and creator) then
			if (not THE_MEETING) then
				return false, "there is no active meeting";
			end;
			local thisSeat;
			for i = 1, 8 do 
				if (not THE_MEETING["Chair"..i].Used or (not GetEnt(THE_MEETING["Chair"..i].User))) then
					thisSeat = i;
					break;
				end;
			end;
			if (thisSeat) then
				local seat = THE_MEETING["Chair"..thisSeat];
				local addBot = System.SpawnEntity({class="Player",position=seat.BindPos,name=ATOMNames:GetName("Nomad", 1000 + HIGHEST_SLOT + arrSize(System.GetEntitiesByClass("Player")))});
				seat.Used = true;
				seat.Bot = addBot.id;
				seat.User = addBot.id;
				local code = [[local p=GetEnt(']]..addBot:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]={]]..arr2str_(seat.BindPos)..[[,]]..seat.DirLimitL..[[,]]..seat.DirLimitR..[[,]]..tostr(seat.SpecialCalc)..[[}LOOPED_ANIMS[p.id]={Start 	= _time,Entity 	= p,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= {"relaxed_drinkLoop_01","relaxed_eatSolidLoop_01","relaxed_eatSolidLoop_02","relaxed_eatSolidLoop_03","relaxed_eatSolidLoop_04","relaxed_eatSolidLoop_05","relaxed_eatSoupLoop_01","relaxed_sit_nw_01","relaxed_sitIdleBreak_nw_01","relaxed_sitTableIdle_01"},NoSpec	= true,Alive	= true,NoWater	= true },if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(true)end;end]]
				ExecuteOnAll(code)
				addBot.MeetingSyncId = RCA:SetSync(addBot,{link=true,client=code});
				SendMsg(CHAT_ATOM, self, "(BOT: has been added to the meesting)");
			else
				return false, "no free seat found";
			end;
		else
			if (self.AFK) then
				return false, "not while AFK";
			end;
			local seatId = tonumber(option);
			if (not seatId) then
				return false, "specify valid seatId (number from 1-8)";
			end;
			local seat = THE_MEETING["Chair" .. seatId];
			if (not seat) then
				return false, "specify valid seatId (number from 1-8)";
			end;
			if (seat.Used and System.GetEntity(seat.User)) then
				if (seat.User and seat.User == self.id) then
					ExecuteOnAll([[local p=GetEnt(']]..self:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]=nil LOOPED_ANIMS[p.id]=nil if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(false)end end;p:StopAnimation(0,-1)]]);
					RCA:Unsync(self.id, self.MeetingSyncId);
					seat.User = nil;
					seat.Used = false;
					self.InMeeting = false;
					self.MeetingChairID = nil;
					g_game:MovePlayer(self.id, self.OldPos, self.OldAng);
					g_utils:SpawnEffect(ePE_Light, self.OldPos, self.OldAng);
					SendMsg(CHAT_ATOM, ALL, "(%s: Left the Meeting)", self:GetName());
					return true;
				end;
				return false, "this seat is already in use";
			else
				seat.User = self.id;
				seat.Used = true;
				self.MeetingChairID = option;
				self.InMeeting = true;
				local code = [[local p=GetEnt(']]..self:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]={]]..arr2str_(seat.BindPos)..[[,]]..seat.DirLimitL..[[,]]..seat.DirLimitR..[[,]]..tostr(seat.SpecialCalc)..[[}LOOPED_ANIMS[p.id]={Start 	= _time,Entity 	= p,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= {"relaxed_drinkLoop_01","relaxed_eatSolidLoop_01","relaxed_eatSolidLoop_02","relaxed_eatSolidLoop_03","relaxed_eatSolidLoop_04","relaxed_eatSolidLoop_05","relaxed_eatSoupLoop_01","relaxed_sit_nw_01","relaxed_sitIdleBreak_nw_01","relaxed_sitTableIdle_01"},NoSpec	= true,Alive	= true,NoWater	= true },if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(true)end;end]]
				ExecuteOnAll(code)
				self.MeetingSyncId = RCA:SetSync(self,{link=true,client=code});
				SendMsg(CHAT_ATOM, ALL, "(%s: Has joined the meeting (!meeting))", self:GetName());
				self.OldPos = self:GetPos();
				self.OldAng = self:GetAngles();
			end;
		end;
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !tankwar

NewCommand({
	Name 	= "tankwar",
	Access	= CREATOR,
	Console = true,
	Args = {
		{ "Amount", "The amount of tanks to spawn", Integer = true, Default = 5, Optional = true, PositiveNumber = true, Range = { 2, 50 } },
		{ "Radius", "The Spawn Radius for the tanks", Integer = true, Default = 50, Optional = true, PositiveNumber = true, Range = { 20, 2000 } },
	--	{ "Code", "The lua code you wish to execute", Integer = true, Default = 1 },
	},
	Properties = { --█████▒░░░░
		--SendHelp = true;
		--RequireVehicle = true;
		RequiresCVar = { { "atom_aisystem", "1", "AI System is not enabled" } },
		Self = 'ATOM';
	},
	
	func = function(self, player, Amount, Radius)
		
		ATOMDLL:SetMultiplayer(false);
		
		local species = g_utils:SpawnCounter();
		local species_add = false;
		local pos_old = player:GetPos();
		local pos_rnd = pos_old;
		local half = Amount / 2;
		
		local x, y;
		
		local function prep(entity, t_species)
			entity.PropertiesInstance.bAutoDisable = 0;
			entity.Properties.bSpeciesHostility = 1;
			entity.Properties.awarenessOfPlayer = 1;
			entity.Properties.species = t_species;
			entity.Properties.bGrenades = 1;
		end;
		
		local tank;
		local driver, gunner;
		
		for i = 1, Amount do
		
			Script.SetTimer(i * 1, function()
			
				x = GetRandom(-Radius, Radius);
				y = GetRandom(-Radius, Radius);
					
				if (i >= half) then
				--	x = GetRandom(-Radius, -10);
				--	y = GetRandom(-Radius, -10);
					
					if (not species_add) then
						species_add = true;
						species = g_utils:SpawnCounter();
					end;
				else
				--	x = GetRandom(10, minimum(10, Radius));
				--	y = GetRandom(10, minimum(10, Radius));
				end;
				
				pos_rnd = add2Vec(pos_old, { x = x, y = y, z = 0 });
				
				driver = ATOMDLL:SpawnArchetype("asian_new.Special\\Driver.NK_Driver_tank", pos_old, player:GetHeadDir(), "Grunt " .. g_utils:SpawnCounter(), "")
				gunner = ATOMDLL:SpawnArchetype("asian_new.Special\\Driver.NK_Driver_tank", pos_old, player:GetHeadDir(), "Grunt " .. g_utils:SpawnCounter(), "")
				
				prep(driver, species);
				prep(gunner, species);
			
				tank = math.random(1, 4) == 3 and System.SpawnEntity({ class = "Asian_helicopter", position = add2Vec(pos_rnd, makeVec(0, 0, 150)), orientation = (i>=half and player:GetHeadDir() or vecScale(player:GetHeadDir(), -1)) }) or System.SpawnEntity({ class = (i>=half and "Asian" or "US") .. "_tank", position = pos_rnd, orientation = (i>=half and player:GetHeadDir() or vecScale(player:GetHeadDir(), -1)) })
				tank.Properties.species = species;
				
				if (tank.class == "Asian_helicopter") then
					tank.Properties.aicharacter_character = "HeliAggressive";
				end;
				
				tank:ForceCoopAI();
				
				tank.vehicle:EnterVehicle(driver.id, 1, false);
				tank.vehicle:EnterVehicle(gunner.id, 2, false);
			end);
		
		end;
	
		SendMsg(CHAT_ATOM, player, "TANKS - [ %d ] - IN RADIUS OF - [ %dm ] - SPAWNED", Amount, Radius);
	
		--Script.SetTimer(Amount + 1, function()
			ATOMDLL:SetMultiplayer(true);
		--end);
	end;
});
		

----------------------------------------------------------------------------------
-- !icerocks

NewCommand({
	Name 	= "icerocks",
	Access	= CREATOR,
	Description = "Spawn sum ice rocks above someone",
	Console = true,
	Args = {
	--	{ "Gun", "The Name of the gun you wish to enable", Required = true, Default = "list" },
		{ "Target", "The Name of the player to enable the gun on", Optional = true, AcceptSelf = true, Target = true, EqualAccess = false },
		{ "Amount", "Amount of rocks", Optional = true, Default = 5, Integer = true, PositiveNumber = true },
	},
	Properties = {
	--	Self = 'GunSystem',
		Timer = 3,
	--	RequireRCA = true
	},
	func = function(player, target, y)
	
		local count = minimum(1, maximum(50, y));
		local pos = target:GetPos()
		pos.z = pos.z + 100
		SendMsg(CHAT_ATOM, player, "Ice Rocks detected above %s", target:GetName());
		if (player~=target) then
			SendMsg(CHAT_ATOM, target, "Ice Rocks detected above you");
		end;
		for i = 1, count do
			Script.SetTimer( i * 500, function()
				SpawnEffect("Alien_environment.Ice.falling_rock", pos, g_Vectors.down, 1);
				--g_gameRules:CreateExplosion(player.id,player.id,0,pos,g_Vectors.down,1,45,1,1,"misc.falling_debris.mine_large_earthquake",1, 1, 1, 1);
			end)
		end
		return true
	end;
});

----------------------------------------------------------------------------------
-- !rocks

NewCommand({
	Name 	= "rocks",
	Access	= CREATOR,
	Description = "Spawn sum rocks above someone",
	Console = true,
	Args = {
	--	{ "Gun", "The Name of the gun you wish to enable", Required = true, Default = "list" },
		{ "Target", "The Name of the player to enable the gun on", Optional = true, AcceptSelf = true, Target = true, EqualAccess = false },
		{ "Amount", "Amount of rocks", Optional = true, Default = 5, Integer = true, PositiveNumber = true },
	},
	Properties = {
	--	Self = 'GunSystem',
		Timer = 3,
	--	RequireRCA = true
	},
	func = function(player, target, y)
	
		local count = minimum(1, maximum(50, y));
		local pos = target:GetPos()
		pos.z = pos.z + 100
		SendMsg(CHAT_ATOM, player, "Rocks detected above %s", target:GetName());
		if (player~=target) then
			SendMsg(CHAT_ATOM, target, "Rocks detected above you");
		end;
		for i = 1, count do
			Script.SetTimer( i * 500, function()
				SpawnEffect("misc.falling_debris.mine_large_earthquake", pos, g_Vectors.down, 1);
				--g_gameRules:CreateExplosion(player.id,player.id,0,pos,g_Vectors.down,1,45,1,1,"misc.falling_debris.mine_large_earthquake",1, 1, 1, 1);
			end)
		end
		return true
	end;
});


----------------------------------------------------------------------------------
-- !flamethrower

NewCommand({
	Name 	= "flamethrower",
	Access	= CREATOR,
	Description = "Makes your current weapon a flamethrower",
	Console = true,
	Args = {
	--	{ "Gun", "The Name of the gun you wish to enable", Required = true, Default = "list" },
	--	{ "Target", "The Name of the player to enable the gun on", Optional = true, AcceptSelf = true, Target = true, EqualAccess = false },
	--	{ "Amount", "Amount of rocks", Optional = true, Default = 5, Integer = true, PositiveNumber = true },
	},
	Properties = {
	--	Self = 'GunSystem',
	--	Timer = 3,
	--	RequireRCA = true
	},
	func = function(player)
	
		local item = player:GetCurrentItem();
		if (not item or not item.weapon) then
			return false, "invalid item";
		end;
		
		item.isFlamethrower = not item.isFlamethrower;
		if (item.weapon) then
			item.weapon:DisableShooting(item.isFlamethrower)
		end
		SendMsg(CHAT_ATOM, player, "FLAMETHROWER :: %s", (item.isFlamethrower and "ENABLED" or "DISABLED"));
	end;
});


---------------------------------------------------------------
-- !skyrocket, Skyrockets a player

NewCommand({
	Name 	= "skyrocket",
	Access	= CREATOR,
	Console = nil,
	Description = "Special Admin Menu",
	Args = {
		{ "Player", "The name of the player", OnlyAlive = true, Target = true, AcceptSelf = true, Required = false, EqualAccess = false, AcceptAll = true },
	},
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	},
	func = function(self, hPlayer, hTarget)
		
		local function fSkyRocket(hEntity)
			g_utils:SkyRocketPlayer(hEntity)
		end
		
		local hTarget = hTarget or hPlayer
		if (hTarget == "all") then
			if (table.count(GetPlayers()) == 1) then
				hTarget = hPlayer
			else
				local iCount = 0
				for i, hPl in pairs(GetPlayers()) do
					if (hPl:IsAlive() and hPl.ATOM_Client) then
						iCount = iCount + 1
						if (hPl.id ~= hPlayer.id) then
							fSkyRocket(hPl)
							SendMsg(CHAT_ATOM, hPl, "You have been Sky-Rocketed")
							
						end
					end
				end
				if (iCount == 0) then
					return false, "noone to skyrocket found"
				end
				SendMsg(CHAT_ATOM, hPlayer, "You Sky-Rocketed ( %d ) Players", iCount)
				return true
			end
		end
		
		if (not hTarget.ATOM_Client) then
			return false, "player requires ATOM Client"
		end
		
		if (not hTarget:IsAlive()) then
			return false, "player must be alive"
		end
				
		fSkyRocket(hTarget)
		SendMsg(CHAT_ATOM, hTarget, "You are being Sky-Rocketed!")
		if (hTarget ~= hPlayer) then
			SendMsg(CHAT_ATOM, hPlayer, "%s Is Being Sky-Rocketed!", hTarget:GetName())
		end
		
	end;
});



------------------------------------------------------------------------
-- !spawnjet


NewCommand({
	Name 	= "spawnjet",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a jet";
	Args = {
		{ "Type", "The type of the aircraft", Required = true, Default = "list" },
	},
	Properties = {
		Self = 'ATOMAircrafts',
		NotInFight = true,
		Alive = true,
		NoSpec = true,
		Vehicle = false,
		--	Timer = 1,
	},
	func = function(self, player, Index)

		local models = {
			{ "US Figter", 		2, nil,	1000 	},
			{ "US Cargoplane", 	3, nil,	1000 	},
			{ "Asian Fighter", 	2, 1, 	600		},
			{ "Aircraft", 		1, nil, 300		},
		}

		local newModel = models[tonum(Index)]
		if (Index == "list" or not newModel) then
			ListToConsole(player, models, "Aircraft Types")
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Types", arrSize(models))
			return true
		end

		self:SpawnAircraft(player, newModel[2], newModel[3])
	end;
});


------------------------------------------------------------------------
--!alien, changes ur fukin model


NewCommand({
	Name 	= "alien",
	Access	= CREATOR,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	},
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
		OnlyAlive = true,
		Dead = false,
		NoSpec = true,
		NoVehicle = true
	},
	func = function(self, player)
		return self:RequestCharacter(player, 1, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!playas, changes ur fukin model


NewCommand({
	Name 	= "playas",
	Access	= CREATOR,
	Description = "Changes your character",
	Console = true,
	Args = {
		{ "Character", "The Index of the list of possible characters", Number = true, PositiveNumber = true }
	},
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
		OnlyAlive = true,
		Dead = false,
		NoSpec = true,
		NoVehicle = true
	},
	func = function(self, hPlayer, iChar)
		return self:RequestCharacter(hPlayer, iChar, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!playas, changes ur fukin HEAAAAD

NewCommand({
	Name 	= "sethead",
	Access	= CREATOR,
	Description = "Changes your characters head",
	Console = true,
	Args = {
		{ "Head", "The Index of the list of possible heads", Number = true, PositiveNumber = true }
	},
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
		OnlyAlive = true,
		Dead = false,
		NoSpec = true,
		NoVehicle = true
	},
	func = function(self, hPlayer, iChar)
		return self:RequestHead(hPlayer, iChar, nil, nil, true)
	end;
});


----------------------------------------------------------------------------------
-- !guns

NewCommand({
	Name 	= "guns",
	Access	= CREATOR,
	Description = "Enables Crazy Gun mode on yourself or specified Player",
	Console = true,
	Args = {
		{ "Gun", "The Name of the gun you wish to enable", Required = true, Default = "list" },
		{ "Target", "The Name of the player to enable the gun on", Optional = true, AcceptSelf = true, Target = true, EqualAccess = true },
	},
	Properties = {
		Self = 'GunSystem',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player, gun, target)
		local theGun, realName = self:GetGun(gun);
		if (not theGun) then
			ListToConsole(player, self.GunsList, "Available Guns", false, nil, 3);
			SendMsg(CHAT_ATOM, player, "Open Console to view the List of [ %d ] available Guns!", self:GetGunCount());
			return true;
		end;
		local vehicle, item;
		if (not target or target == player) then
			vehicle, item = player:GetVehicle(), player:GetCurrentItem();
			if (not vehicle) then
				if (not item) then
					return false, "no item found";
				end;
				if (item.SpecialGun and item.SpecialGun == theGun) then
					SendMsg(CHAT_ATOM, player, "(CRAZY-GUN: Disabled - [ %s ])", realName); --item.SpecialGun);
					item.SpecialGun = nil;
					item.weapon:AutoRemoveProjectiles(false);
					if (item.class == "LAW") then
						item.weapon:DisableAutoDropping(false);
					end;
					return true;
				end;
				if (item.class == "LAW") then
					item.weapon:DisableAutoDropping(true);
				end;
				item.SpecialGun = theGun;
				SendMsg(CHAT_ATOM, player, "(CRAZY-GUN: Enabled - [ %s ])", realName); --item.SpecialGun);
				item.weapon:AutoRemoveProjectiles(true);
			else
				if (vehicle.SpecialGun and vehicle.SpecialGun == theGun) then
					SendMsg(CHAT_ATOM, player, "(CRAZY-GUN: Disabled - [ %s ] - ON:VEHICLE)", realName); --vehicle.SpecialGun);
					vehicle.SpecialGun = nil;
					return true;
				end;
				vehicle.SpecialGun = theGun;
				SendMsg(CHAT_ATOM, player, "(CRAZY-GUN: Enabled - [ %s ] - ON:VEHICLE)", realName); --vehicle.SpecialGun);
			end;
		else
		
		end;
		return true;
	end;
});


----------------------------------------------------------------------------------
-- !gmodel

NewCommand({
	Name 	= "gunmodel",
	Access	= CREATOR,
	Description = "Changes the model of your currently equipped weapon",
	Console = true,
	Args = {
		{ "Index", "The index of the list of models", Optional = true },
	},
	Properties = {
		Self = 'ATOM',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player, Index)
	
		local gun = player:GetCurrentItem();
		if (not gun) then
			return false, "no weapon found";
		elseif (gun.item:IsMounted() or gun.class == "Fists" or gun.class == "Binoculars" or gun.class == "Detonator" or not gun.weapon) then
			return false, "invalid weapon";
		end;
	
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
			
		local models = {
			{ "Mighty Gauss",	"objects/weapons/us/gauss/gauss_fp.chr",			"objects/weapons/us/gauss/gauss_tp.cgf",				"sounds/weapons:gaussrifle:fire", 		"_fp", false },
			{ "FY71",			"objects/weapons/asian/fy71/fy_71_fp.chr", 			"Objects/weapons/asian/fy71/fy71_tp.cgf",				"sounds/weapons:fy71:fire_3rd_loop", 	"sounds/weapons:fy71:fire_fp_loop", true, true },
			{ "Shotgun",		"Objects/weapons/us/shotgun/shotgun_fp.chr",		"Objects/weapons/us/shotgun/shotgun_tp.cgf",			"sounds/weapons:shotgun:fire",			"_fp" },
			{ "TACGun",			"objects/weapons/us/tac_gun/tac_gun_fp.chr",		"objects/weapons/us/tac_gun/tac_gun_tp.cgf",			"sounds/weapons:tac_gun:fire",			"_fp" },
		--	{ "Hurricane",		"Objects/weapons/us/hurricane/hurricane_fp.chr",	"Objects/weapons/us/hurricane/hurricane_tp.cgf" },
			{ "SCAR",			"objects/weapons/us/scar/scar_l-c_fp.chr",			"objects/weapons/us/scar/scar_l-c_tp.cgf",				"sounds/weapons:scar:fire_3rd_loop", 	"sounds/weapons:scar:fire_fp_loop", true, true },
			{ "SMG",			"objects/weapons/us/smg/smg_fp.chr",				"objects/weapons/us/smg/smg_tp.cgf", 					"sounds/weapons:smg:fire_3rd_single",	nil },
		--	{ "RPG",			"objects/weapons/us/law/law_fp.chr",				"objects/weapons/us/law/law_tp.cgf" },
			{ "Pistol",			"objects/weapons/us/socom/socom_right_fp.chr",		"objects/weapons/us/socom/socom_tp.cgf",				"sounds/weapons:socom:fire",			"_fp" },
			{ "Sniper",			"objects/weapons/us/sniper_dsg1/sniper_dsg1_fp.chr","objects/weapons/us/sniper_dsg1/sniper_dsg1_tp.cgf", 	"sounds/weapons:sniperrifle:fire",		"_fp" },
			
			{ "Golf Club",		"Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf",	"Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf" },
			{ "Ice machine",	"objects/weapons/us/alien_weapon_mount/alien_weapon_mount_fp.chr",		"objects/weapons/us/alien_weapon_mount/alien_weapon_mount_tp.cgf" },
		}
		
		if (Index == 0) then
			if (not gun.modelSyncId) then
				return false, "This Gun does not have custom Model";
			end;
			SendMsg(CHAT_ATOM, player, "Gun Model-[ %s ] :: Disabled", models[gun.ModelId][1]);
			RCA:StopSync(gun, gun.modelSyncId);
			gun.modelSyncId = nil;
			gun.ModelId = nil;
			ExecuteOnAll([[local g=GetEnt(']]..gun:GetName()..[[')if (g) then g.CM=nil;end]]);
			--ExecuteOnPlayer(player, [[local v=g_localActor:GetVehicle()if (v) then System.RemoveEntity(v.custommodel.id)v:DrawSlot(0,1)end;]]); -- ??? ON ALL ???

			return true;
		end;
		local newModel = models[Index];
		if (Index == "list" or not newModel) then
			ListToConsole(player, models, "Gun Models");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Models", arrSize(models));
			return true;
		end;
		if (gun.ModelId and Index == gun.ModelId) then
			return false, "Choose different model";
		end;
		gun.ModelId = Index;
		SendMsg(CHAT_ATOM, player, "Gun Model-[ %s ] :: Enabled", models[gun.ModelId][1]);
		local code = [[
			local g=GetEnt(']]..gun:GetName()..[[')
			if (g) then 
				g.CMDir = nil;
				g.FireSoundFP=nil;
				g.FireSoundFP_Single=nil;
				g.FireSound=nil;
				g.FireSoundLooped=nil;
				g.CM="]]..newModel[3]..[["
				g.CMFP="]]..newModel[2]..[[";
				]] ..
				(newModel[4] and [[g.FireSound="]]..newModel[4]..[["]] or "") ..
				(newModel[5] and [[g.FireSoundFP="]]..newModel[5]..[["]] or "") ..
				(newModel[6] and [[g.FireSoundFP_Single="]]..newModel[5]..[["]] or "") ..
				(newModel[7] and [[g.FireSoundLooped=true]] or "") 
				.. [[
			end
		]];
		
	
		
		if (gun.modelSyncId) then
		
		end;
		gun.modelSyncId = RCA:SetSync(gun,{client=code,link=true},1);
		ExecuteOnAll(code);
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !gsound

NewCommand({
	Name 	= "gunsound",
	Access	= CREATOR,
	Description = "Changes the fire sound of your currently equipped weapon",
	Console = true,
	Args = {
		{ "Index", "The index of the list of models", Optional = true },
	},
	Properties = {
		Self = 'ATOM',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, player, Index)
	
		local gun = player:GetCurrentItem();
		if (not gun) then
			return false, "no weapon found";
		elseif (gun.class == "Fists" or gun.class == "Binoculars" or gun.class == "Detonator") then
			return false, "invalid weapon";
		end;
	
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
			
		local sounds = {
			{ "Thunder",		"Sounds/environment:fleet_v2:distant_thunder", 		"", false, false },
			
			{ "Mighty Gauss",	"sounds/weapons:gaussrifle:fire", 		"_fp", false, false },
			
			{ "FY71 Single",	"sounds/weapons:fy71:fire_3rd_single", 	nil, false, false },
			{ "FY71 Rapid",		"sounds/weapons:fy71:fire_3rd_loop", 	"sounds/weapons:fy71:fire_fp_loop", true, true },
			{ "SCAR Single",	"sounds/weapons:scar:fire_3rd_single", 	"sounds/weapons:scar:fire_fp_single", true, false },
			{ "SCAR Rapid",		"sounds/weapons:scar:fire_3rd_loop", 	"sounds/weapons:scar:fire_fp_loop", true, true },
			{ "SMG Single",		"sounds/weapons:smg:fire_3rd_single", 	"sounds/weapons:smg:fire_fp_single", true, false },
			{ "SMG Rapid",		"sounds/weapons:smg:fire_3rd_loop", 	"sounds/weapons:smg:fire_fp_loop", true, true },
			
			{ "Shotgun",		"sounds/weapons:shotgun:fire",			"_fp", false, false },
			{ "TACGun",			"sounds/weapons:tac_gun:fire",			"_fp", false, false },
			
			{ "Pistol",			"sounds/weapons:socom:fire",			"_fp", false, false },
			{ "Sniper",			"sounds/weapons:sniperrifle:fire",		"_fp", false, false },
			
			{ "MG Single",		"sounds/weapons:heavymachinegun:fire_3rd_single",		"sounds/weapons:heavymachinegun:fire_fp_single", true, false },
			{ "MG Rapid",		"sounds/weapons:heavymachinegun:fire_3rd_loop",			"sounds/weapons:heavymachinegun:fire_fp_loop", true, true },
			
			{ "RPG",			"sounds/weapons:law:fire",				"_fp", false, false },
			{ "MOAC",			"sounds/weapons:moac_large:fire",		"_fp", false, false },
			{ "MOAC Smoll",		"sounds/weapons:moac_small:fire",		"",    false, false },
			{ "MOAC Mighty",	"sounds/weapons:moac_warrior:fire",		"",    false, false },
			
			{ "MOAR",			"sounds/weapons:moar_large:fire",		"_fp", false, false },
			{ "MOAR Smoll",		"sounds/weapons:moar_small:fire",		"",    false, false },
			{ "MOAR Mighty",	"sounds/weapons:moar_warrior:fire",		"",    false, false },
			
			{ "Sing Cannon",	"sounds/weapons:singularity_cannon:sing_cannon_fire",	"_fp",    false, false },
			
			{ "ShitEn Single",	"sounds/weapons:shiten:fire_3rd_single",	"sounds/weapons:shiten:fire_fp_single", true, false },
			{ "ShitEn Rapid",	"sounds/weapons:shiten:fire_3rd_loop",		"sounds/weapons:shiten:fire_fp_loop", true, true },
			
			{ "AAA Single",		"sounds/weapons:vehicle_asian_aaa:fire_3rd_single",		"sounds/weapons:vehicle_asian_aaa:fire_fp_single", true, false },
			{ "AAA Rapid",		"sounds/weapons:vehicle_asian_aaa:fire_3rd_loop",		"sounds/weapons:vehicle_asian_aaa:fire_fp_loop", true, true },

			{ "Heli Single",	"sounds/weapons:vehicle_asian_helicopter:fire",			"_fp", false, false },
			{ "Heli Rocket",	"sounds/weapons:vehicle_asian_helicopter:fire_missile",	"_fp", false, false },

			{ "Tank Round",		"sounds/weapons:vehicle_asian_tank:fire",			"_fp", false, false },
			{ "Tank Gauss",		"sounds/weapons:vehicle_asian_tank:fire_gauss",	"_fp", false, false },
			
			{ "ABC",			"sounds/weapons:vehicle_us_apc:fire",			"_fp", false, false },
			
			{ "US Tank",		"sounds/weapons:vehicle_us_tank:fire",			"_fp", false, false },
			
			{ "VTOL Rocket",	"sounds/weapons:vehicle_us_vtol:fire_missile",			"_fp", false, false },
			
		}
		
		if (Index == 0) then
			if (not gun.gSoundSyncId) then
				return false, "This Gun does not have custom Sound";
			end;
			SendMsg(CHAT_ATOM, player, "Gun Sound-[ %s ] :: Disabled", sounds[gun.GSoundID][1]);
			RCA:StopSync(gun, gun.gSoundSyncId);
			gun.gSoundSyncId = nil;
			gun.GSoundID = nil;
			ExecuteOnAll([[local g=GetEnt(']]..gun:GetName()..[[')if (g) then g.FireSoundFP=nil;g.FireSoundFP_Single=nil;g.FireSound=nil;g.FireSoundLooped=nil;end]]);
			--ExecuteOnPlayer(player, [[local v=g_localActor:GetVehicle()if (v) then System.RemoveEntity(v.custommodel.id)v:DrawSlot(0,1)end;]]); -- ??? ON ALL ???

			return true;
		end;
		local newSound = sounds[Index];
		if (Index == "list" or not newSound) then
			ListToConsole(player, sounds, "Gun Sounds");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Models", arrSize(sounds));
			return true;
		end;
		if (gun.GSoundID and Index == gun.GSoundID) then
			return false, "Choose different Sound";
		end;
		gun.GSoundID = Index;
		SendMsg(CHAT_ATOM, player, "Gun Sound-[ %s ] :: Enabled", sounds[gun.GSoundID][1]);
		local code = [[
			local g=GetEnt(']]..gun:GetName()..[[')
			if (g) then 
				g.FireSoundVol=nil;
				g.FireSoundFP=nil;
				g.FireSoundFP_Single=nil;
				g.FireSound=nil;
				g.FireSoundLooped=nil;
				]] ..
				(newSound[2] and [[g.FireSound="]]..newSound[2]..[["]] or "") ..
				(newSound[3] and [[g.FireSoundFP="]]..newSound[3]..[["]] or "") ..
				(newSound[4] and [[g.FireSoundFP_Single="]]..newSound[3]..[["]] or "") ..
				(newSound[5] and [[g.FireSoundLooped=true]] or "") 
				.. [[
			end
		]];
		if (gun.gSoundSyncId) then
		
		end;
		gun.gSoundSyncId = RCA:SetSync(gun,{client=code,link=true},1);
		ExecuteOnAll(code);
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !rapidfire, Enables Rapid Fire Mode on Yourself or Specified Player

NewCommand({
	Name 	= "rapidfire",
	Access	= CREATOR,
	Description = "Enables Mega C4 Mode on Yourself",
	Console = true,
	Args = {
		{ "Target", "The name of the Target to enable RapidFire on", Optional = true, IsTarget = true, AccepSelf = true, EqualAccess = true },
	},
	Properties = {
	--	Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, target)
		local W;
		local VW;
		local enabledOn;
		if (not target or target.id == self.id) then
			W = self:GetCurrentItem();
			if (not W) then
				W = self:GetSeatWeapon(nil, -1);
				if (not W) then
					return false, "no weapon equipped";
				else
					enabledOn = "";
					local M = W[1].RapidFire;
					for i, w in pairs(W) do
						if (M) then
							w.RapidFire = nil;
						else
							w.RapidFire = {
								Delay = 0.05,
							}
						end;
						w.weapon:DisableAntiCheat(w.RapidFire == nil);
						enabledOn = enabledOn .. w.class .. (i ~= arrSize(W) and " + " or "")
					end;
					W.RapidFire = M == nil;
				end;
			else
				enabledOn = W.class;
				if (W.RapidFire) then
					W.RapidFire = nil;
				else
					W.RapidFire = {
						Delay = 0.05,
					}
				end;
				W.weapon:DisableAntiCheat(W.RapidFire == nil);
			end;
			SendMsg(CHAT_ATOM, self, "(RAPID-FIRE: %s ON %s)", (W.RapidFire and "Activated" or "Deactived"), enabledOn);
		else
			W = target:GetCurrentItem();
			if (not W) then
				W = target:GetSeatWeapon(nil, -1);
				if (not W) then
					return false, "no weapon equipped";
				else
					enabledOn = "";
					local M = W[1].RapidFire;
					for i, w in pairs(W) do
						if (M) then
							w.RapidFire = nil;
						else
							w.RapidFire = {
								Delay = 0.05,
							}
						end;
						w.weapon:DisableAntiCheat(w.RapidFire == nil);
						enabledOn = enabledOn .. w.class .. (i ~= arrSize(W) and " + " or "")
					end;
					W.RapidFire = M == nil;
				end;
			else
				enabledOn = W.class;
				if (W.RapidFire) then
					W.RapidFire = nil;
				else
					W.RapidFire = {
						Delay = 0.05,
					}
				end;
				W.weapon:DisableAntiCheat(W.RapidFire == nil);
			end;
			SendMsg(CHAT_ATOM, self, "(RAPID-FIRE: %s ON WEAPON %s for %s)", (W.RapidFire and "Activated" or "Deactived"), enabledOn, target:GetName());
			SendMsg(CHAT_ATOM, target, "(RAPID-FIRE: %s ON %s)", (W.RapidFire and "Activated" or "Deactived"), enabledOn);
			W.weapon:DisableAntiCheat(W.RapidFire == nil);
		end;
		return true;
	end;
});

----------------------------------------------------------------------------------
-- !shotgun, Enables Rapid Fire Mode on Yourself or Specified Player

NewCommand({
	Name 	= "shotgun",
	Access	= CREATOR,
	Description = "Enables Shotgun firemode on Yourself",
	Console = true,
	Args = {
		{ "Target", "The name of the Target to enable Shutgun on", Optional = true, IsTarget = true, AccepSelf = true, EqualAccess = true },
	},
	Properties = {
	--	Self = 'RCA',
	--	Timer = 30,
	--	RequireRCA = true
	},
	func = function(self, target)
		local W;
		local VW;
		if (not target or target.id == self.id) then
			W = self:GetCurrentItem();
			if (not W) then
				W = self:GetSeatWeapon(nil, -1);
				if (not W) then
					return false, "no weapon equipped";
				else
					enabledOn = "(";
					local M = W[1].ShotgunFire;
					for i, w in pairs(W) do
						if (M) then
							w.ShotgunFire = nil;
						else
							w.ShotgunFire = {
								Pellets = 6,
							}
						end;
						w.weapon:DisableAntiCheat(w.ShotgunFire == nil);
						enabledOn = enabledOn .. w.class .. (i ~= arrSize(W) and "+ " or ")")
					end;
					W.ShotgunFire = M == nil;
				end;
			else
				enabledOn = W.class;
				if (W.ShotgunFire) then
					W.ShotgunFire = nil;
				else
					W.ShotgunFire = {
						Delay = 0.05,
					}
				end;
				W.weapon:DisableAntiCheat(W.ShotgunFire == nil);
			end;
			SendMsg(CHAT_ATOM, self, "(SHOTGUN: %s ON %s)", (W.ShotgunFire and "Activated" or "Deactived"), enabledOn);
			--W.weapon:DisableAntiCheat(self.ShotgunFire == nil);
		else
			W = self:GetCurrentItem();
			if (not W) then
				W = self:GetSeatWeapon(nil, -1);
				if (not W) then
					return false, "no weapon equipped";
				else
					enabledOn = "(";
					local M = W[1].ShotgunFire;
					for i, w in pairs(W) do
						if (M) then
							w.ShotgunFire = nil;
						else
							w.ShotgunFire = {
								Pellets = 6,
							}
						end;
						w.weapon:DisableAntiCheat(w.ShotgunFire == nil);
						enabledOn = enabledOn .. w.class .. (i ~= arrSize(W) and "+ " or ")")
					end;
					W.ShotgunFire = M == nil;
				end;
			else
				enabledOn = W.class;
				if (W.ShotgunFire) then
					W.ShotgunFire = nil;
				else
					W.ShotgunFire = {
						Delay = 0.05,
					}
				end;
				W.weapon:DisableAntiCheat(W.ShotgunFire == nil);
			end;
			SendMsg(CHAT_ATOM, self, "(SHOTGUN: %s ON WEAPON %s for %s)", (W.ShotgunFire and "Activated" or "Deactived"), enabledOn, target:GetName());
			SendMsg(CHAT_ATOM, target, "(SHOTGUN: %s ON %s)", (W.ShotgunFire and "Activated" or "Deactived"), enabledOn);
			--W.weapon:DisableAntiCheat(W.ShotgunFire == nil);
		end;
		return true;
	end;
});

-------------------------------------------------------------------
-- !vehicleid

NewCommand({
	Name 	= "vehicleid",
	Access	= CREATOR,
	Console = nil,
	Description = "Changes the model of your vehicle",
	Args = {
		{ "Index", "Index of the list of possible Model Files", Required = true },
	},
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
		RequireVehicle = true,
	},
	func = function(self, player, vehicle, Index)
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
			
		local models = {							-- model																position			  dir   			  rem tires 	 Available On
			{ "Tesla",				{ "objects/library/vehicles/cars/car_b_chassi.cgf", 							{ x = 0, y = 0.350, z = 0.30 }, makeVec(0,0,0),			false,		 nil }},
			{ "Audi R8",			{ "objects/library/vehicles/cars/car_a.cgf", 									{ x = 0, y = 0.350, z = 0.50 }, makeVec(0,0,0),			false,		  }},
			{ "Düler",				{ "objects/library/vehicles/mining_train/mining_locomotive.cgf",				{ x = 0, y = 0.0, z = 0.2 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Ferrari",			{ "objects/library/vehicles/ship/roofed_rowing_boat/ship.cgf",				{ x = 0, y = 0.8, z = -0.1 }, makeVec(0,0,0),			false,		  }},
			{ "Disel Train",		{ "objects/library/vehicles/diesel_train_engine/diesel_train_engine.cgf",		{ x = 0, y = 0.350, z = 0.10 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Aircraft",			{ "Objects/library/vehicles/aircraft/aircraft.cgf", 							{ x = 0, y = -0.00, z = -0.00 }, makeVec(0,0,0),			false, 		  }},
			{ "NK Fighter",			{ "objects/vehicles/asian_fighter/asian_fighter.cgf",							{ x = 0, y = -1, z = 1 }, makeVec(0,0,0),			false, 		  }},
			{ "US Fighter",			{ "objects/vehicles/us_fighter_b/us_fighter.cga",								{ x = 0, y = -1, z = -1.4 }, makeVec(0,0,3.14),			false, 		  }},
			{ "Cargo Plane",		{ "objects/vehicles/us_cargoplane/us_cargoplane_open.cgf", 						{ x = 0, y = -21.0, z = -5.8 }, makeVec(0,0,-1.5727), 	false,		  }},
			{ "Transport Plane",	{ "objects/library/vehicles/asian_transport_plane/asian_transport_plane.cgf",	{ x = 0, y = -10.40, z = -2.0 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "AWACS",				{ "objects/library/vehicles/north_korean_awacs/nk_awacs.cgf",					{ x = 0, y = 00000, z = 5 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Transport VTOL",		{ "objects/vehicles/us_vtol_transport/us_vtol_transport.cga",					{ x = 0, y = 0.0000, z = -4.10 }, makeVec(0,0,0),			false,		 nil }},
			
			
			{ "Excavator",			{ "objects/library/vehicles/excavator/excavator.cgf",							{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Forklift",			{ "objects/library/vehicles/forklift/forklift.cgf",								{ x = 0, y = 1.2, z = 0.0 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Mine Truck",			{ "objects/library/vehicles/mine_truck/mine_truck.cgf",							{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Crane",				{ "objects/library/vehicles/mobile_crane/mobile_crane.cga",						{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Wagon",				{ "objects/library/vehicles/rail_trailer/trans_wagon_4_wheel.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Cart",				{ "objects/library/vehicles/baggage_truck/baggage_cart.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Shopping Cart",		{ "objects/library/props/misc/shopping_cart/shopping_cart.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "AAA",				{ "Objects/Vehicles/asian_aaa/asian_aaa.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "APC",				{ "objects/vehicles/asian_apc/asian_apc.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,-1.574),			false,		  }},
			{ "Heli",				{ "objects/vehicles/asian_helicopter/asian_helicopter.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Tank",				{ "objects/vehicles/asian_tank/asian_tank.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Headless Tank ",		{ "objects/vehicles/asian_tank/frozen_asian_tank_chassis.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Tank Turret ",		{ "objects/vehicles/asian_tank/frozen_asian_tank_turret.cgf",		{ x = 0, y = 1.0, z = 0.2 }, makeVec(0,0,-1.5727),			false,		  }},
			{ "Truck",				{ "objects/vehicles/asian_truck_b/asian_truck_b.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Car",				{ "objects/vehicles/civ_car1/civ_car.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "LTV",				{ "objects/vehicles/ltv/asian_ltv.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Dauntless",				{ "objects/vehicles/dauntless/dauntless.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Kuanti",				{ "objects/vehicles/kuanti/kuanti.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Speedboat",				{ "objects/vehicles/speedboat/speedboat.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Destroyer",				{ "objects/vehicles/us_destroyer/us_destroyer_mp.cga",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Hovercraft",				{ "objects/vehicles/us_hovercraft_b/us_hovercraft_b.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Scientist Ship",				{ "objects/library/vehicles/ship/cargo_ship/cargo_ship.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Cargo Ship",				{ "objects/library/vehicles/diesel_train_engine/diesel_train_engine.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Skyforge ",				{ "objects/library/vehicles/ship/valley_forge_placeholder/valley_forge.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Navy Ship ",				{ "objects/library/vehicles/ship/us_navy_ship_placeholder/us_navy_ship.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Tanker ",				{ "objects/library/vehicles/tanker_truck/tanker_truck_trailer.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Shark ",				{ "objects/characters/animals/whiteshark/greatwhiteshark.chr",		{ x = 0, y = 0.0, z = 0.8 }, makeVec(0,0,3.1),			false,		  }},
			{ "Palm ",				{ "Objects/natural/trees/palm_tree/palm_tree_large_b.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
			{ "Rock ",				{ "objects/natural/rocks/suitjump_rocks/cliff_rock_cover_a.cgf",		{ x = 0, y = 0.0, z = 0.0 }, makeVec(0,0,0),			false,		  }},
		}
		
		
		if (Index == 0) then
			if (not vehicle.modelSyncId) then
				return false, "Vehicle does not have custom Model";
			end;
			SendMsg(CHAT_ATOM, player, "Vehicle Model-[ %s ] :: Disabled", models[vehicle.ModelId][1]);
			RCA:StopSync(vehicle, vehicle.modelSyncId);
			vehicle.modelSyncId = nil;
			vehicle.ModelId = nil;
			ExecuteOnPlayer(player, [[local v=g_localActor:GetVehicle()if (v) then v:FreeSlot(111)]]); -- ??? ON ALL ???
			return true;
		end;
		local newModel = models[Index];
		if (Index == "list" or not newModel) then
			ListToConsole(player, models, "Vehicle Models");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Models", arrSize(models));
			return true;
		end;
		if (vehicle.ModelId and Index == vehicle.ModelId) then
			return false, "Choose different model";
		end;
		vehicle.ModelId = Index;
		SendMsg(CHAT_ATOM, player, "Vehicle Model-[ %s ] :: Enabled", models[vehicle.ModelId][1]);
		self:LoadVehicleModel(vehicle, newModel[2][1], newModel[2][2], newModel[2][3], newModel[2][4], newModel[2][5]);
		
		local code=[[
			local vehicle=GetEnt(']]..vehicle:GetName()..[[')
			if (vehicle) then
				if (vehicle.custommodel) then
					System.RemoveEntity(vehicle.custommodel)
				end;
				local model = System.SpawnEntity({class="BasicEntity",position=vehicle:GetPos(), orientation=vehicle:GetDirectionVector(),name=vehicle:GetName().."_cm",properties={object_Model="]]..newModel[2][1]..[["}})
				model:LoadObject(0, "]]..newModel[2][1]..[[");
				model:PhysicalizeSlot(0,{ flags = 1.8537e+008 })
				vehicle:DrawSlot(0,0)
				vehicle:AttachChild(model.id,PHYSICPARAM_SIMULATION);
				vehicle.custommodel=model.id
				model:SetLocalPos(]]..arr2str_(newModel[2][2])..[[)
				model:SetLocalAngles(]]..arr2str_(newModel[2][3])..[[)
				
				
			end;
		
		]]
		
		--[[
		
		model:PhysicalizeSlot(0,{})
				vehicle:AttachChild(model.id,PHYSICPARAM_SIMULATION);
				model:SetLocalPos({x=0,y=0,z=0})
				model:SetLocalAngles({x=0,y=0,z=0})
				
				]]
		--ExecuteOnAll(code)
		--loadstring(code)()
		--return true;
	end;
});

-------------------------------------------------------------------
-- !tireid

NewCommand({
	Name 	= "tireid",
	Access	= CREATOR,
	Console = nil,
	Description = "Changes the model of your vehicles tires",
	Args = {
		{ "Index", "Index of the list of possible Model Files", Required = true, Default = "list" },
	},
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
		RequireVehicle = true,
	},
	func = function(self, player, vehicle, Index)

		local models = {
			{ "Melon", "Objects/library/props/food/melon/melon.cgf", 2.5 },
			{ "Fish", "objects/library/props/fish/fish2_double.cgf", 2.5 },
			{ "Flowerpot", "objects/library/props/flowers/flowerpot_harbour_a.cgf", 2.5 },
			{ "EGirl", "objects/characters/human/story/helena_rosenthal/helena_rosenthal.cdf", 2.5 },
			{ "Tire", "Objects/library/props/gasstation/truck_tire.cgf", 2.5 },
		}
		
		
		local newModel = models[tonum(Index)];
		if (Index == "list" or not newModel) then
			ListToConsole(player, models, "Vehicle Models");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Models", arrSize(models));
			return true;
		end;
		
		
		local supported = {
			["Civ_car1"] = 1,
			["US_ltv"] = 1,
			["Asian_ltv"] = 1
		}
		if (not supported[vehicle.class]) then
			return false, "unsupported vehicle";
		end;
		
		
		if (vehicle.TireModelID and Index == vehicle.TireModelID) then
			return false, "Choose different model";
		end;
		vehicle.ModelId = Index;
		SendMsg(CHAT_ATOM, player, "Vehicle Model-[ %s ] :: Enabled", newModel[1]);
		
		if (vehicle.tireSyncID) then
			RCA:StopSync(vehicle, vehicle.tireSyncID);
		end;
		
		local code=formatString([[
			local vehicle=GetEnt(']]..vehicle:GetName()..[[')
			if (vehicle) then
				for i = 1, 4 do
					vehicle:FreeSlot(i);
					vehicle:LoadObject(i, "%s")
					vehicle:SetSlotScale(i,%f);
				end;
			end;
		]], newModel[2], newModel[3] or 1.0);
		ExecuteOnAll(code);
		vehicle.tireSyncID = RCA:SetSync(vehicle, {link=vehicle.id,client=code});
		
	end;
});

-------------------------------------------------------------------
-- !cage

NewCommand({
	Name 	= "cage",
	Access	= CREATOR,
	Console = nil,
	Description = "Cage someone",
	Args = {
		{ "Player", "The name of the player you wish to cage", Required = true, Target = true, EqualAccess = false },
	},
	Properties = {
		Self = 'ATOMAFK',
		--FromConsole = nil,
		--RequireVehicle = true,
	},
	func = function(self, player, target)

		if (target.cageParts) then
			for i, v in pairs(target.cageParts) do
				System.RemoveEntity(v.id);
			end;
			SendMsg(CHAT_ATOM, player, "%s has been uncaged", target:GetName());
			target.cageParts = nil;
			target.cagePos = nil;
			return true;
		end;
		
		target.cageParts = self:SpawnAFKCage(target:GetPos());
		target.cagePos = target:GetPos();
		SendMsg(CHAT_ATOM, player, "%s has been Caged HARD", target:GetName());
		
	end;
});

-------------------------------------------------------------------
-- !circlejump

NewCommand({
	Name 	= "circlejump",
	Access	= CREATOR,
	Description = "Toggles Circlejumping",
	Console = true,
	Args = {
	},
	Properties = {
		--Self = 'ATOMAFK',
		--FromConsole = nil,
		--RequireVehicle = true,
	},
	func = function(player, target)

		----------
		local iCVar = System.GetCVar("mp_circlejump")
		if (not iCVar) then
			return false, "CVar not found" end
			
		----------
		SaveCVar("mp_circlejump", iCVar)
			
		----------
		local bEnabled = (iCVar >= 1)
		if (bEnabled) then
			System.SetCVar("mp_circlejump", "0") 
			else
				System.SetCVar("mp_circlejump", "1") end
				
		----------
		ATOMLog:LogGameUtils("", "Circlejumping has been %s", string.bool((not bEnabled), "Enabled", "Disabled"))
		
	end;
});

-------------------------------------------------------------------
-- !walljump

NewCommand({
	Name 	= "walljump",
	Access	= CREATOR,
	Description = "Changes the walljumping multiplier",
	Console = true,
	Args = {
		{ "Multiplier", "The walljump multiplier", IsInteger = true, PositiveNumber = true, Optional = true, Range = { 0, 999 } }
	},
	Properties = {
		--Self = 'ATOMAFK',
		--FromConsole = nil,
		--RequireVehicle = true,
	},
	func = function(player, fMultiplier)

		----------
		local iCVar = System.GetCVar("mp_walljump")
		if (not iCVar) then
			return false, "CVar not found" end
			
		----------
		SaveCVar("mp_walljump", iCVar)
			
		----------
		if (isNull(fMultiplier)) then
			local bEnabled = (iCVar > 0)
			if (bEnabled) then
				System.SetCVar("mp_walljump", "0") 
				else
					System.SetCVar("mp_walljump", "1") end
			
			ATOMLog:LogGameUtils("", "Walljumping has been %s", string.bool((not bEnabled), "Enabled", "Disabled"))
		else
			System.SetCVar("mp_walljump", fMultiplier)
			ATOMLog:LogGameUtils("", "Walljump Multiplier has been set to %0.2f", fMultiplier)
		end
		
		----------
		
	end;
});

-------------------------------------------------------------------
-- !pickup

NewCommand({
	Name 	= "pickup",
	Access	= CREATOR,
	Description = "Toggles the ability to pickup objects",
	Console = true,
	Args = {
	},
	Properties = {
		--Self = 'ATOMAFK',
		--FromConsole = nil,
		--RequireVehicle = true,
	},
	func = function(player, target)

		----------
		local iCVar = System.GetCVar("mp_pickupobjects")
		if (not iCVar) then
			return false, "CVar not found" end
			
		----------
		SaveCVar("mp_pickupobjects", iCVar)
			
		----------
		local bEnabled = (iCVar >= 1)
		if (bEnabled) then
			System.SetCVar("mp_pickupobjects", "0") 
			else
				System.SetCVar("mp_pickupobjects", "1") end
				
		----------
		ATOMLog:LogGameUtils("", "Object-Pickup has been %s", string.bool((not bEnabled), "Enabled", "Disabled"))
		
	end;
});
