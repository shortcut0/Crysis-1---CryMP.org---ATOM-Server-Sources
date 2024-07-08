---------------------------------------------------------------
-- !rename <newName>, renames a player to specified name

NewCommand({
	Name 	= "rename",
	Access	= MODERATOR,
	Console = false,
	Args = {
		{ "Player", "The new name if the player you wish to rename",Target=true,NotPlayer=true,Required=true };
		{ "Name", "The new name for the player", Concat = true, Required = true, };
	};
	Properties = {
		Self = 'ATOMNames',
		FromConsole = true,
		IgnoreSuspension = true
	};
	func = function(self, player, target, newName)
		return self:RenamePlayer(target, newName, "Admin Decision");
	end;
});

------------------------------------------------------------------------
-- !clones <amount>, spawns a few clones

NewCommand({
	Name 	= "clones",
	Access	= MODERATOR,
	Description = "Spawns a few Clones",
	Console = true,
	Args = {
		{ "Amount", "The Amount of clones to Spawn", 					Integer = true, PositiveNumber = true, Optional = true, Range = { 1, 100 }, Default = 1 };
		{ "Spread", "Spreads the bots in x meter radius", 				Integer = true, PositiveNumber = true, Optional = true, Range = { 1, 100 }, Default = 1 };
		{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Amount, Spread, ...)
		if (tonumber(Amount) and tonumber(Amount) > 25) then
			if (not player:HasAccess(DEVELOPER)) then
				return false, "too many clones"
			end
		end
		
		---------
		if (player.lastClones and (_time - player.lastClones < 5) and not player:HasAccess(DEVELOPER)) then
			return false, "too many clones"
		end
			
		---------
		player.lastClones = _time
			
		---------
		return self:Spawn({ RandomCharacter = false, Pos = player:CalcSpawnPos(3), Class = "Player", SpawnRadius = (Spread or Amount or 1), Tags = { ['isClone'] = true }, Name = "Clone %d", Count = (Amount or 1), Equipment = { ... } });
	end;
});

------------------------------------------------------------------------
-- !sendmsg <type>, <msg>, Sends a Message to all players

NewCommand({
	Name 	= "sendmsg",
	Access	= MODERATOR,
	Description = "Spawns a few Clones",
	Console = true,
	Args = {
		{ "Type", "The Type of the mesage (CENTER, INFO, ERROR, ATOM)", Required = true },
		{ "Message", "The message you wish to send", 				Required = true, Concat = true }
	},
	Properties = {
		Self = 'ATOMChat',
	},
	func = function(self, hPlayer, sEntity, sMessage)
		local hEntity = self:GetChatEntity(sEntity)
		if (hEntity) then
			SendMsg(hEntity, ALL, sMessage)
		else
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Invalid Chat Entity(!))", sEntity)
			SendMsg(CHAT_ATOM, ALL, sMessage)
		end
	end
})

------------------------------------------------------------------------
---- !delc <className>, Removes entities of specified Class
------------------------------------------------------------------------

NewCommand({
	Name 	= "delclass",
	Access	= MODERATOR,
	Description = "Removes All Entities of Specified Class",
	Console = true,
	Args = {
		{ "Class", "The Class of the entities you wish to remove", Required = true, Default = "" };
	--	{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Class, ...)
		return self:DeleteClass(player, Class);
	end;
});

------------------------------------------------------------------------
---- !regai
------------------------------------------------------------------------

NewCommand({
	Name 	= "regai",
	Access	= MODERATOR,
	Description = "Register every actor in AI System",
	Console = true,
	Args = {
	--	{ "Class", "The Class of the entities you wish to remove", Required = true, Default = "Player" };
	--	{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		RequiresCVar = { { "atom_aisystem", "1", "AI System is not enabled" } },
		Self = 'ATOMAI',
	};
	func = function(self, player)
		local all = System.GetEntities();
		local total = 0;
		for i, v in pairs(all) do
			if (v.actor) then
				total = total + 1;
				BasicActor.RegisterAI(v);
			end;
		end;
		SendMsg(CHAT_ATOM, player, "[ %d ] - ENTITIES : REGISTERED", total);
	end;
});

------------------------------------------------------------------------
---- !unregai
------------------------------------------------------------------------

NewCommand({
	Name 	= "unregai",
	Access	= MODERATOR,
	Description = "Unregisters every actor from the AI System",
	Console = true,
	Args = {
	--	{ "Class", "The Class of the entities you wish to remove", Required = true, Default = "Player" };
	--	{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		RequiresCVar = { { "atom_aisystem", "1", "AI System is not enabled" } },
		Self = 'ATOMAI',
	};
	func = function(self, player)
		local all = System.GetEntities();
		local total = 0;
		for i, v in pairs(all) do
			if (v.actor) then
				total = total + 1;
				BasicActor.UnregisterAI(v);
			end;
		end;
		SendMsg(CHAT_ATOM, player, "[ %d ] - ENTITIES : UNREGISTERED", total);
	end;
});

------------------------------------------------------------------------
---- !spawn <className> <amount>, Spawns Entities of specified class
------------------------------------------------------------------------

NewCommand({
	Name 	= "spawn",
	Access	= MODERATOR,
	Description = "Spawns Entities of Specified Class",
	Console = true,
	Args = {
		{ "Class", "The Class of the entities you wish to Spawn", Required = true };
		{ "Amount", "The Amount of entities to Spawn", 			Optional = true, IsInteger = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Class, Amount)
	
		---------
		local iAmount = checkNumber(Amount, 0)
		if (iAmount and iAmount > 25) then
			if (not player:HasAccess(GetHighestAccess())) then
				return false, "too many entities" end 
		elseif (not player:HasAccess(GetHighestAccess()) and iAmount >= 5 and (player.lastEntities and (_time - player.lastEntities < 30))) then
			return false, "too many entities"
		end
		
		---------
		player.lastEntities = _time
			
		---------
		return self:Spawn({ AdjustPos = true, Count = (Amount or 1), Class = Class, Dir = player:GetDirectionVector(), Pos = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}), Tags = { ['CmdSpawned'] = true } }, player);
	end;
});

------------------------------------------------------------------------
---- !spawn <className> <amount>, Spawns Entities of specified class
------------------------------------------------------------------------

NewCommand({
	Name 	= "spawnarchetype",
	Access	= MODERATOR,
	Description = "Spawns Archetype Entities of Specified Class",
	Console = true,
	Args = {
		{ "Name", "The name of the entities you wish to Spawn", Required = true };
		{ "Amount", "The Amount of entities to Spawn", 			Optional = true, IsInteger = true, PositiveNumber = true, Default = 1 };
	};
	Properties = {
		RequiresCVar = { { "atom_aisystem", "1", "AI System is not enabled" } },
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Class, species, bGrenades) -- asian_new.Camper\Elite.Heavy_Rifle_SF
		
		if (not Class) then
			return false, "No Archetype specefied";
		end;
		ATOMDLL:SetMultiplayer(false)
		local s = ATOMDLL:SpawnArchetype(tostring(Class), player:CalcSpawnPos(5), player:GetAngles(), "Entity "..g_utils:SpawnCounter(), "")
		ATOMDLL:SetMultiplayer(true)
		if (not s) then
			return false, "unknown entity";
		end;
		
		local c = s
		c.PropertiesInstance.bAutoDisable = 0
		c.Properties.bSpeciesHostility = 1;
		c.Properties.awarenessOfPlayer = 1;
		c.Properties.bGrenades=1;
		--[[
		c.PropertiesInstance.nVariation = 0

		
		c.Properties.preferredCombatDistance = 20;

		c.Properties.rank = 4;
		c.Properties.special = 0;

		c.Properties.attackrange = 70;
		c.Properties.reaction = 1;	-- time to startr shooting with nominal accuracy
		c.Properties.commrange = 300.0;
		c.Properties.accuracy = 1.0;
		
		c.Properties.distanceToHideFrom = 3;
		
		c.Properties.fdistanceToHideFrom = 3.0;
		
		
		c.Properties.physicMassMult = 1;
		
		c.Properties.ragdollPersistence = 0;
		
		c.Properties.equip_EquipmentPack = "NK_Rifle";
		
		c.Properties.species = SPECIES_COUNTER;
		c.Properties.bSpeciesHostility = 1;
		c.Properties.fGroupHostility = 0;
		
		c.Properties.soclasses_SmartObjectClass = "Actor";
		
		c.Properties.AnimPack = "Basic";
		c.Properties.SoundPack = "Korean03";		
		c.Properties.SoundPackAlternative = "Korean03_eng";
		c.Properties.nVoiceID = 0;
		c.Properties.aicharacter_character = "Sneaker";
		c.Properties.fileModel = "objects/characters/human/asian/nk_soldier/nk_soldier_camp_camper_heavy_01.cdf";
		c.Properties.nModelVariations=7;
		c.Properties.bTrackable=1;
		c.Properties.bSquadMate=0;
		c.Properties.bSquadMateIncendiary=1;
		c.Properties.bGrenades=1;
		c.Properties.IdleSequence = "None";
		c.Properties.bIdleStartOnSpawn = 0;
		
		c.Properties.bCannotSwim = 0;
		c.Properties.bInvulnerable = 0;
		c.Properties.bNanoSuit = 0;

		c.Properties.eiColliderMode = 0; -- zero as default; meaning 'script does not care and does not override graph; etc'.

		c.Properties.awarenessOfPlayer = 1;


			c.Properties.Damage.bNoDeath = 0
			c.Properties.Damage.bNoGrab = 0
			c.Properties.Damage.bLogDamages = 0
			c.Properties.Damage.health = 180
			c.Properties.Damage.FallPercentage = 25
			c.Properties.Damage.FallSleepTime = 1
			
			

			--how visible am I
			c.Properties.Perception.camoScale = 1;
			--movement related parameters
			--VELmultyplier = (velBase + velScale*CurrentVel^2);
			--current priority gets scaled by VELmultyplier
			c.Properties.Perception.velBase = 1;
			c.Properties.Perception.velScale = .03;
			--fov/angle related
			c.Properties.Perception.FOVPrimary = 80;			-- normal fov
			c.Properties.Perception.FOVSecondary = 250;		-- periferial vision fov
			--ranges			
			c.Properties.Perception.sightrange = 70;
			c.Properties.Perception.sightrangeVehicle = -1;	-- how far do i see vehicles
			--how heights of the target affects visibility
			--// compare against viewer height
			-- fNewIncrease *= targetHeight/stanceScale
			c.Properties.Perception.stanceScale = 1.9;
			-- Sensitivity to sound 0=deaf; 1=normal
			c.Properties.Perception.audioScale = 1;
			-- Equivalent to camo scale; used with thermal vision.
			c.Properties.Perception.heatScale = 1;
			-- Flag indicating that the agent has thermal vision.
			c.Properties.Perception.bThermalVision = 0;
			-- The perception reaction speed; default speed = 1. THe higher the value the faster the AI acquires target.
			c.Properties.Perception.reactionSpeed = 1;
			-- controls how often targets can be switched; 
			-- this parameter corresponds to minimum ammount of time the agent will hold aquired target before selectng another one
			-- default = 0 
			c.Properties.Perception.persistence = 0;
			-- controls how long the attention target have had to be invisible to make the player stunts effective again
			c.Properties.Perception.stuntReactionTimeOut = 3.0;
			-- controls how sensitive the agent is to react to collision events (scales the collision event distance).
			c.Properties.Perception.collisionReactionScale = 1.0;	
			-- flag indicating if the agent perception is affected by light conditions.
			c.Properties.Perception.bIsAffectedByLight = 0;	
			-- Value between 0..1 indicating the minimum alarm level.
			c.Properties.Perception.minAlarmLevel = 0;	

	c.gameParams.inertia =0.0

	c.gameParams.inertiaAccel = 0.0
			
	c.gameParams.backwardMultiplier = 0.5--speed is multiplied by this ammount when going backward
--]]

		c.actor:SetParams(c.gameParams)
	
		if (AI_ENABLED) then
			BasicAI.UnregisterAI(s) --:UnregisterAI()
			BasicAI.RegisterAI(s) --c:RegisterAI()
		end;
		--CF_Logger:LogNow(ADMINS, 6, "Spawned Entity-Archetype " .. x .. " with ID " .. tostring(oldId) .. " for player " .. player:GetName());
		SendMsg(CHAT_ATOM, player, "Spawned Archetype-Entity " .. s:GetName())
		if (s.class=="Grunt" and s.currModel:lower()~="objects/characters/human/asian/nk_soldier/nk_soldier_jungle_cover_light_01.cdf") then
			RPC:OnAll("PlayerLoadModel", { model = s.currModel, name = s:GetName() })
			s.myModel = s.currModel
		end;
		if (s.Properties) then
			if (species) then
				s.Properties.species=tonumber(species);
			end;
			if (bGrenades) then
				s.Properties.bGrenades=1;
			end;
		end;
		return true;
	end;
});

------------------------------------------------------------------------
---- !revive <playerName> <deathPos>, revives a player or yourself
------------------------------------------------------------------------

NewCommand({
	Name 	= "revive",
	Access	= MODERATOR,
	Description = "Revives a Player or Yourself",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish to Revive", Required = false, Target = true, AcceptALL = true, AcceptSelf = true };
		{ "DeathPos", "If specified, player will not be revived at their death pos", 			Optional = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, DeathPos)
		return self:RevivePlayer(player, Target, DeathPos);
	end;
});

------------------------------------------------------------------------
---- !tags a player
------------------------------------------------------------------------

NewCommand({
	Name 	= "tag",
	Access	= MODERATOR,
	Description = "Revives a Player or Yourself",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish to Revive", Required = true, Target = true, AcceptALL = true, AcceptSelf = true };
		{ "Tag", "The Tag you wish to add to the player", 			Required = true; };
	};
	Properties = {
		Self = 'ATOMNames',
	};
	func = function(self, hPlayer, hTarget, sTag)

		local sTag = string.format("(%s)", sTag)

		if (hTarget == ALL) then
			for i, hTgt in pairs(GetPlayers()) do
				self:AddNameTag(hTgt, sTag)
			end
		else
			self:AddNameTag(hTarget, sTag)
		end
		return true
	end;
});

------------------------------------------------------------------------
---- !tod <Time> <Reason>, Sets the Time Of Day to specified time
------------------------------------------------------------------------

NewCommand({
	Name 	= "tod",
	Access	= MODERATOR,
	Description = "Sets the Time Of Day to Specified Time",
	Console = true,
	Args = {
		{ "Time", "The Name of the Player you wish to Revive", Integer = true, PositiveNumber = true, Optional = true };
	--	{ "DeathPos", "The Amount of entities to Spawn", 			Optional = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Time, Reason)
		return self:SetGameTime(player, (Time or 10.30), Reason);
	end;
});

------------------------------------------------------------------------
---- !todspeed <speed>
------------------------------------------------------------------------

NewCommand({
	Name 	= "todspeed",
	Access	= MODERATOR,
	Description = "Sets the Time Of Day speed",
	Console = true,
	Args = {
		{ "Speed", "The speed for time of day processing", Integer = true, PositiveNumber = true, Optional = true };
	--	{ "DeathPos", "The Amount of entities to Spawn", 			Optional = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, speed)
		local curr = System.GetCVar("e_time_of_day_speed");
		if (speed) then
			SendMsg(CHAT_ATOM, player, "(TIME OF DAY: Speed set to %0.2f)", speed);
			ATOMDLL:ForceSetCVar("e_time_of_day_speed", tostring(speed))
		else
			SendMsg(CHAT_ATOM, player, "(TIME OF DAY: Speed is %0.2f)", curr);
		end;
		return true;
	end;
});

------------------------------------------------------------------------
---- !goto <Target> <InVehicle>, Teleports you to the specified target-
----							 or in their vehicle
------------------------------------------------------------------------

NewCommand({
	Name 	= "goto",
	Access	= MODERATOR,
	Description = "Teleports you to a players location or vehicle",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish to teleport to", Target = true, Required = true, NotPlayer = true };
		{ "InVehicle", "Teleports you directly into the targets vehicle", 			Optional = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, InVehicle)
		return self:GotoPlayer(player, Target, (InVehicle ~= nil));
	end;
});

------------------------------------------------------------------------
---- !bring <Target> <InVehicle>, Brings a player to your position-
----							 or in their vehicle
------------------------------------------------------------------------

NewCommand({
	Name 	= "bring",
	Access	= MODERATOR,
	Description = "Bring a player to your location or into your Vehicle",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish bring to your Location", Target = true, Required = true, NotPlayer = true, AcceptALL = true, AcceptThis = { ['entities'] = true, ['class'] = true }; };
		{ "InVehicle", "Teleports the target directly into your vehicle", 			Optional = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, InVehicle)
		return self:BringPlayer(player, Target, InVehicle);
	end;
});

------------------------------------------------------------------------
---- !award <Target> <Amount>, Awards specified player prestige
------------------------------------------------------------------------

NewCommand({
	Name 	= "award",
	Access	= MODERATOR,
	Description = "Awards specified player prestige",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish bring to your Location", Target = true, Required = true, NotPlayer = false, AcceptSelf = true, AcceptALL = true };
		{ "Amount", "Teleports the target directly into your vehicle", 			Integer = true, Required = true; };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, Amount)
		return self:GivePrestige(player, Target, Amount);
	end;
});

------------------------------------------------------------------------
---- !equip <Target> <ItemName> <Attachments>, Gives you or specified
----										   Player equipment
------------------------------------------------------------------------

NewCommand({
	Name 	= "equip",
	Access	= MODERATOR,
	Description = "Gives you or specified player equipemt",
	Console = true,
	Args = {
		{ "Target", "The Name of the Player you wish to give equipment", Target = true, Required = true, NotPlayer = false, AcceptALL = true, AcceptSelf = true };
		{ "ItemName", "The Name of the Item you wish to give", 			Required = true  };
		{ "Attachments", "The Names of the accessories to attach on the weapon", 			Optional = true  };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Target, ItemName, ...)
		return self:EquipPlayer(player, Target, ItemName, ...);
	end;
});

