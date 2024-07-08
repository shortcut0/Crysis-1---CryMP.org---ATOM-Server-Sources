------------------
VTOLMegaMod = {
	Config = {
		VTOLPriceMultiplier = 10, -- 1200*10=12000 oof
		VTOLExplodeChance = 33,
		ProjectileBackfireChance = 3,
		DeathCountCooldown = 10,
		AllowedItems = { -- items the player is allowed to buy during the cooldown (see PowerStruggle.buyList)
			["pistol"] = 1
		},
	}
}

------------------

VTOLMegaMod.Init = function (self)

	VMM_EVENT_KILL, VMM_EVENT_BUYITEM, VMM_EVENT_BUYVEHICLE = 
	0, 1, 2
	
	VMM_EVENT_CANBUYITEM, VMM_EVENT_CANBUYVEHICLE = 
	3, 4

	---------------------------------------
	-- On Connect
	RegisterEvent ("OnPlayerInit", function(player) -- See g_gameRules.SetupPlayer for hooking!!
		return self.InitPlayer(self, player)
	end)
	---------------------------------------
	-- On Kill
	RegisterEvent ("OnKill", function(hit) -- See g_gameRules.OnPlayerKilled for hooking!!
		return self.OnEvent (self, VMM_EVENT_KILL, hit.target, hit)
	end)
	---------------------------------------
	-- On Item Bought
	RegisterEvent ("OnItemBought", function(player, item, itemClass) -- See g_gameRules.BuyItem for hooking!!
		return self.OnEvent (self, VMM_EVENT_BUYITEM, player, item, itemClass)
	end)
	---------------------------------------
	-- Can Buy Item
	RegisterEvent ("CanBuyItem", function(player, itemClass) -- See g_gameRules.BuyItem for hooking!!
		return self.OnEvent (self, VMM_EVENT_CANBUYITEM, player, itemClass)
	end)
	---------------------------------------
	-- On Vehicle Bought
	RegisterEvent ("OnVehicleBought", function(player, vehicle, vehicleClass) -- See Factory.BuildVehicle for hooking!!
		return self.OnEvent (self, VMM_EVENT_BUYVEHICLE, player, vehicle, vehicleClass)
	end)
	---------------------------------------
	-- Can Buy Vehicle
	RegisterEvent ("CanBuyVehicle", function(player, vehicleClass) -- See g_gameRules.BuyVehicle for hooking!!
		Debug("can buy vehicle : ",vehicleClass)
		return self.OnEvent (self, VMM_EVENT_CANBUYVEHICLE, player, vehicleClass)
	end)
	---------------------------------------
	-- On Shoot
	RegisterEvent ("OnShoot", function(player, weapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId) -- Requires C++ "CWeapon::OnShoot()" lua callback!!
		return self.OnEvent (self, VMM_EVENT_ONSHOOT, player, player:GetVehicle(), weapon, ammoId) -- ammoId to remove projectile (not needed)
	end)
	
	---------------------------------------
	
	if (g_gameRules.class == "PowerStruggle") then
		g_gameRules.buyList["usvtol"].price = g_gameRules.buyList["usvtol"].price * self.cfg.VTOLPriceMultiplier -- price multiplier
	end

end
------------------

VTOLMegaMod.InitPlayer = function (self, player)

	player.VMM = {
		DeathCount = 0
	}

end

------------------

VTOLMegaMod.OnEvent = function (self, eventId, player, p1, p2, p3)

	local cfg = self.Config
	local bOnCooldown = player.VMM.DeathCount < cfg.DeathCountCooldown
	local nullVec = { x = 0, y = 0, z = 0 }

	if (eventId == VMM_EVENT_KILL) then
		if (player.id ~= p1.shooterId) then -- block suicide deaths
			player.VMM.DeathCount = player.VMM.DeathCount + 1 -- if >= 10 then cooldown ended
		end
	elseif (eventId == VMM_EVENT_BUYVEHICLE) then
		if (p2 == "US_vtol") then
			player.VMM.DeathCount = 0 -- reset cooldown
			if (math.random(1, 100) <= cfg.VTOLExplodeChance) then -- 33.3333% chance to explode
				p1.vehicle:Destroy()
				SendMsg ({ ERROR }, player, "Unfortunately your VTOL exploded") -- some message
			end
		end
	elseif (eventId == VMM_EVENT_CANBUYVEHICLE) then
		if (p1 == "usvtol") then
			if (bOnCooldown) then
				SendMsg({ ERROR }, player, "BECAUSE YOU BOUGHT A VTOL, YOU MUST DIE " .. (10 - player.VMM.DeathCount) .. " MORE TIMES BEFORE YOU CAN BUY THE VTOL AGAIN") -- some message
				--return false 
			end
		end
	elseif (eventId == VMM_EVENT_BUYITEM) then -- player bought an item
		-- something ?
	elseif (eventId == VMM_EVENT_CANBUYITEM) then
		if (bOnCooldown and not cfg.AllowedItems[p1]) then -- allow only PISTOL to be bought during cooldown
			SendMsg({ ERROR }, player, "BECAUSE YOU BOUGHT A VTOL, YOU MUST DIE " .. (10 - player.VMM.DeathCount) .. " MORE TIMES BEFORE YOU CAN BUY THIS ITEM AGAIN")
			return false
		end
	elseif (eventId == VMM_EVENT_ONSHOOT) then
		if (p1 and p1.class == "US_vtol") then -- shooting from vehicle
			if (math.random(1, 100) <= cfg.ProjectileBackfireChance) then -- 3% change to backfire (increase to increase chance)
				local iDamage = p2 and p2.weapon:GetDamage() or 1000
				g_gameRules:CreateHit(p1.id, NULL_ENTITY, NULL_ENTITY, iDamage, 1, 'mat_default', -1, "normal", p1:GetPos(), g_Vectors.up, g_Vectors.up)
				SendMsg ({ ERROR }, player, "YOUR PROJECTILE BACKFIRED")
				if (p3) then System.RemoveEntity(p3) end
			end
		end
	end

end

------------------

VTOLMegaMod:Init()