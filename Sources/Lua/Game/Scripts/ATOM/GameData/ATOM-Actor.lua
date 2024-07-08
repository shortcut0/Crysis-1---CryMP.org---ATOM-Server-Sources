if (not BasicActor) then
	Script.ReloadScript("Scripts/Entities/Actors/BasicActor.lua")
end



local function isSpectating(self)
	return self.actor:GetSpectatorMode() ~= 0;
end

local function isDead(self)
	return checkNumber(self.actor:GetHealth(),0) <= 0;
end

local function isAlive(self)
	return not (self:IsDead() and self:IsSpectating());
end

local function getAccess(self)
	return 0;
end

local function getChannel(self)
	return 0;
end

local function null(self)
	return 0;
end

if (BasicActor) then
	BasicActor.IsSpectating = isSpectating;
	BasicActor.IsDead = isDead;
	BasicActor.IsAlive = isAlive;
	BasicActor.GetAccess = getAccess;
	BasicActor.GetChannel = getChannel;
	--SysLog("Basic Actor Patched")
end

function ATOMActor_Init()

	local ents = System.GetEntities();
	if (ents) then
		for i, ent in pairs(ents) do
			if (ent and ent.Server and (type(ent.Server)=="table") and ent.actor) then
				--set metatable
				local metatb = getmetatable(ent);
				if (metatb and metatb.OnSpawn) then
					metatb.IsSpectating = isSpectating;
					metatb.IsDead = isDead;
					metatb.IsAlive = isAlive;
					metatb.GetAccess = getAccess;
					metatb.GetChannel = getChannel;
				--	System.LogAlways("$6MetaItemTB OnHit Hooked");
				end
				--set playertables
				if (not ent.IsSpectating) then
					ent.IsSpectating = isSpectating;
				end
				if (not ent.IsDead) then
					ent.IsDead = isDead;
				end
				if (not ent.IsAlive) then
					ent.IsAlive = isAlive;
				end
				if (not ent.GetAccess) then
					ent.GetAccess = getAccess;
				end
				if (not ent.GetChannel) then
					ent.GetChannel = getChannel;
				end
				ent.DoPainSounds = null;
			end
		end
	end

end