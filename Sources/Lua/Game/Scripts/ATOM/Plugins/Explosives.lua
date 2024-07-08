-----------------
ATOMExplosives = {
	cfg = {
		bEnabled = true,
		iUpdateRate = 0.05
	},

	aExplosives = {},
	aHelperEntities = {},
}

-----------------
eID_ExplosiveRocket = 1

-----------------
-- Init
ATOMExplosives.Init = function(self)

	-------
	RegisterEvent("OnUpdate", self.OnUpdate, "ATOMExplosives")

end

-----------------
-- Init
ATOMExplosives.Shutdown = function(self)

end

-----------------
-- Init
ATOMExplosives.OnUpdate = function(self)

	if (not self.cfg.bEnabled) then
		return
	end

	for i, hExplosive in pairs(self.aExplosives) do
		if (not System.GetEntity(i)) then
			self.aExplosives[i] = nil
			for ii, hHelper in pairs(hExplosive.aHelperEntities) do
				System.RemoveEntity(hHelper)
			end
		elseif (timerexpired(hExplosive.hUpdateTimer, self.cfg.iUpdateRate)) then
			hExplosive.hUpdateTimer = timerinit()
			self:UpdateExplosive(hExplosive)
		end
	end

end

-----------------
-- Init
ATOMExplosives.Explode = function(self, hEntity)
	if (hEntity.bExploded) then
		return
	end
	Explosion("ATOM_Effects.Explosions.C4_Explosion", hEntity:GetPos(), 15, 2000, g_Vectors.up, hEntity, hEntity, 1)
	hEntity.bExploded = true
	System.RemoveEntity(hEntity.id)
end

-----------------
-- Init
ATOMExplosives.UpdateExplosive = function(self, hEntity)

	if (hEntity.iExplosiveType == eID_ExplosiveRocket) then

		if (not hEntity.bExploded) then

			local aLastHits = checkArray(hEntity.aLastHits)
			for i, aHit in pairs(aLastHits) do
				if (not timerexpired(aHit.hHitTimer, 7)) then
					local hHelper = aHit.hHitHelper
					if (hHelper) then
						local iImpulse = hEntity:GetMass() * (2 * math.maxex((timerdiff(aHit.hHitTimer)), 3))
						hEntity.vUpDir = hEntity.vUpDir or vector.make((math.random(-10, 10) / 20), (math.random(-10, 10) / 20), 1)
						hEntity:AddImpulse(-1, (hHelper:GetPos() or hEntity:GetPos()), (hHelper:GetDirectionVector() or hEntity.vUpDir), iImpulse, 1)
						hEntity:AddImpulse(-1, hHelper:GetWorldPos(), hEntity.vUpDir, (hEntity:GetMass() * 2), 1)
					end
				elseif (timerexpired(aHit.hHitTimer, aHit.iExplodeDelay)) then
					self:Explode(hEntity)

				end
			end
		end

	end

end

-----------------
-- Init
ATOMExplosives.PatchEntity = function(self, hEntity)

	hEntity.aHelperEntities = checkArray(hEntity.aHelperEntities, {})
	hEntity.Server = checkArray(hEntity.Server, {})
	hEntity.Server.OnHit = function(self, aHit)

		local iDamage = aHit.damage
		if (aHit.explosion) then
			iDamage = iDamage * 0.75
		end
		self.iHP = (self.iHP or 100) - iDamage
		Debug(self.iHP)
		if (self.iHP <= 0) then
			ATOMExplosives:Explode(self)
		end

		local hHelper = System.SpawnEntity({ name = "Reflex_" .. g_utils:SpawnCounter(), class = "Reflex", position = aHit.pos })
		hHelper:SetPos(aHit.pos)
		hHelper:SetDirectionVector(aHit.dir or g_Vectors.down)

		self:AttachChild(hHelper.id, 1)

		local aNewHit = aHit
		aNewHit.hHitTimer = timerinit()
		aNewHit.hHitHelper = hHelper
		aNewHit.iExplodeDelay = math.random(7, 11)

		table.insert(self.aHelperEntities, hHelper.id)

		self.aLastHits = checkArray(self.aLastHits)
		if (table.count(self.aLastHits) >= 10) then
			System.RemoveEntity(self.aLastHits[1].hHitHelper.id)
			table.remove(self.aLastHits, 1)
		end

		if (self.iExplosiveType == eID_ExplosiveRocket) then
			--SysLog(aHit.type)
			if (aHit.explosion or  aHit.type == "collision" or aHit.type == "bullet") then
				table.insert(self.aLastHits, aNewHit)
				if (aHit.type ~= "bullet" and not self.bNonBulletEffect) then
					self.bNonBulletEffect = true
					local sCode = [[g_Client.ExplosiveEffect("%s")]]
					ExecuteOnAll(string.format(sCode, self:GetName()))
				end
			end
		else
			table.insert(self.aLastHits, aNewHit)
		end
	end

end

-----------------
-- Init
ATOMExplosives.DoSpawn = function(self, vPos, iType)
	local hEntity

	if (iType == eID_ExplosiveRocket) then

		hEntity = SpawnGUINew({
			Pos = vPos,
			Mass = 100,
			Model = GetRandom({
				"Objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf"
			})
		})
		self:PatchEntity(hEntity)
	end

	hEntity.iExplosiveType = iType

	Script.SetTimer(100, function()
		ExecuteOnAll(string.format([[
		local x,y=GetEnt("%s")
		if (not x)then return end
		x.iExplosiveType=%d
		]], hEntity:GetName(), hEntity.iExplosiveType))
	end)
	self.aExplosives[hEntity.id] = hEntity
end

-----------------
-- Init
ATOMExplosives.SpawnExplosive = function(self, hPlayer, iType, iCount)

	local iType = tonumber(iType)
	local vPos = hPlayer:CalcSpawnPos(2.5, 0)

	local iCount = math.limit(checkNumber(tonumber(iCount), 1), 1, 20)
	if (iCount == 1) then
		return self:DoSpawn(vPos, iType)
	end

	local vSpawn = vector.new(vPos)
	for x = 1, iCount do
		vSpawn.y = vPos.y
		vSpawn.x = vSpawn.x + (x * 0.5)
		for y = 1, iCount do
			vSpawn.y = vSpawn.y + (y * 0.3)
			self:DoSpawn(vSpawn, iType)
		end
	end
end

ATOMExplosives:Init()