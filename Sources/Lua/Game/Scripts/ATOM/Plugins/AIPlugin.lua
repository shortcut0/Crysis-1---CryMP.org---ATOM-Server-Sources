ATOMAI = {
	cfg = {
		enabled = AI_ENABLED or System.GetCVar("atom_aisystem") == 1;
	},
	----------
	Init = function(self)
	
		if (System.GetCVar("atom_aisystem") ~= 1) then
			return;
		end;
	
		System.SetCVar("log_verbosity", "4")
		System.SetCVar("log_fileverbosity", "4")
		System.SetCVar("ai_logconsoleverbosity", "4")
	
		local entities = System.GetEntities();
		
		if (self.cfg.enabled) then
			RegisterEvent("OnUpdate", self.Update, 'ATOMAI');
		end
		
		local scripts = {
			{ "BasicActor", "Scripts/Entities/Actor/BasicActor.lua" };
			{ "Player", "Scripts/Entities/Actor/Player.lua" };
			{ "Scout", "Scripts/Entities/AI/Aliens/Scout.lua" };
			{ "Alien", "Scripts/Entities/AI/Aliens/Alien.lua" };
			{ "Hunter", "Scripts/Entities/AI/Aliens/Hunter.lua" };
		};
		
		for i,v in pairs(scripts or {}) do
			if (not _G[v[1]]) then
				Script.ReloadScript(v[2], 1, 1);
			end;
		end;
		
		Grunt.Properties.aicharacter_character = "Camper"
		
		local nullify = {
			"Trooper_Jump",
			"Trooper_DoubleJumpMelee2",
			"Trooper_DoubleJumpMelee",
			"Trooper_JumpFire",
			"Trooper_JumpMelee",
			"Trooper_CheckJumpToFormationPoint"
		};
		
		for i, v in pairs(nullify) do
			_G[v] = function()
				SysLog("Nullified function %s called", v);
				return false;
			end;
		end;
		
		function AI.Animation(id, slot, anim)
			local ai_entity = System.GetEntity(id)
			if (ai_entity and slot and anim) then
				ExecuteOnAll(formatString([[GetEnt('%s'):StartAnimation(%d, %s)]], ai_entity:GetName(), slot, anim));
				SysLog("Got AI Animation (%s) for %s on slot %d", anim or "<null>", ai_entity:GetName(), slot or -1);
			end;
		end;
		
		BasicActor.PSE = function(self, a, b, c, d, e)
			if (self.actor:IsPlayer()) then
				return;
			end;
			local b = b or makeVec();
			local c = c or (self.GetDirectionVector and self:GetDirectionVector(1) or makeVec());
			local d = SOUND_DEFAULT_3D;
			local e = SOUND_SEMANTIC_AI_READABILITY;
			Debug(a)
			ExecuteOnAll([[
				local x=GetEnt(']] .. self:GetName() .. [[')if (x) then x:PlaySoundEvent("]] .. a .. [[",]] .. arr2str_(b) .. [[,]] .. arr2str_(c) .. [[,]] .. d .. [[,]] .. e .. [[);end;
			]]);
			SysLog("BasicActor.PSE(%s, %s, %s, %s, %d, %d)", self:GetName(), a, Vec2Str(b), Vec2Str(c), d, e);
		end;
		
		local replace = {
			{ "PlaySoundEvent", BasicActor.PSE };
		};
		
		for _, _r in pairs(replace) do
			for __, _g in pairs(scripts) do
				if (_G[_g[1]]) then
					_G[_g[1]][_r[1]] = _r[2];
				end;
				
				for ___, _e in pairs(System.GetEntitiesByClass(_g[1])or{}) do
					_e[_r[1]] = _r[2];
				end;
			end;
		end;


		PREDEFINED_EQUIP = {
			["TROOPER"] = 
			{
				"FastLightMOAC",
				--"Freezer"
			},
			["SCOUT"] = 
			{
				"Scout_MOAR",
				"ScoutMOAC"
			},
			["Grunt"] = 
			{
				"FY71",
				"SOCOM"
			},
			
		};
		
		PREDEFINED_EQUIP_PACK = {
			["SCOUT"] = "Alien_Scout"
		}
	
		if (not BasicAI.ai or BasicAI.ai~=1) then BasicAI.ai = 1; end;
	
		if (not Alien.ai) then Alien.ai = 1; end;
		if (not Scout.ai) then Scout.ai = 1; end;
		if (not Player.ai) then Player.ai = 1; end;
		
		if (not Alien.AI) then Alien.AI = {}; end;
		if (not Scout.AI) then Scout.AI = {}; end;
		if (not Player.AI) then Player.AI = {}; end;
		
		-- Fixme : WTF??
		--Hunter.AIType = AIOBJECT_PUPPET;
		
		
		if (not BasicActor.IsSpectating) then
			BasicActor.IsSpectating = function(self)
				return (self.actor:GetSpectatorMode()~=0 and g_game:GetTeam(self.id)==0);
			end;
		end;
		if (not BasicActor.IsAlive) then
			BasicActor.IsAlive = function(self)
				return (self.actor:GetHealth() > 0);
			end;
		end;
		if (not BasicActor.IsDead) then
			BasicActor.IsDead = function(self)
				return (self.actor:GetHealth() <= 0);
			end;
		end;
		
		function BasicAI:RegisterAI()
		
			if (self.actor:IsPlayer()) then
				self:ForcePlayerAI();
				return;
			end;
			
			ATOMAI:Log("AI Enabled on %s", self.class);
			
			ATOMDLL:SetMultiplayer(false);
					
			--if (self ~= g_localActor) then
				if ( self.AIType == nil ) then
					AI.RegisterWithAI(self.id, AIOBJECT_PUPPET, self.Properties or {}, self.PropertiesInstance or {}, self.AIMovementAbility or {},self.melee or {});
				else
					AI.RegisterWithAI(self.id, self.AIType, self.Properties or {}, self.PropertiesInstance or {}, self.AIMovementAbility or {},self.melee or {});
				end
				
				self.hasAI = true;
				
				
				AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
				AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_TARGET,self.forgetTimeTarget);
				AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_SEEK,self.forgetTimeSeek);
				AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_MEMORY,self.forgetTimeMemory);
				
				if (self:IsHidden()) then
					AI.LogEvent(self:GetName()..": The entity is hidden during init -> disable AI.");
					self:TriggerEvent(AIEVENT_DISABLE);
				end
			--end
			BasicAI.OnReset(self);
			
			ATOMDLL:SetMultiplayer(true);
		end

		
		function BasicAI:UnregisterAI()
			if (self.actor:IsPlayer()) then
				self:RemovePlayerAI();
				return;
			end;
			
			ATOMAI:Log("AI Disabled on %s", self.class);
			ATOMDLL:SetMultiplayer(false);
			
			AI.RegisterWithAI(self.id, 0, self.Properties or {}, self.PropertiesInstance or {}, self.AIMovementAbility or {},self.melee or {})
			self.hasAI = false;
			ATOMDLL:SetMultiplayer(true);
			
		end
		
		function BasicAI:ForcePlayerAI()
			ATOMDLL:SetMultiplayer(false);
			AI.RegisterWithAI(self.id, AIOBJECT_PLAYER, self.Properties, self.PropertiesInstance);
			ATOMDLL:SetMultiplayer(true);
			self.hasAI = true;
			
			ATOMAI:Log("AI Enabled on %s", self.class);
		end
		function BasicAI:RemovePlayerAI()
			ATOMDLL:SetMultiplayer(false);
			AI.RegisterWithAI(self.id, 0, self.Properties, self.PropertiesInstance);
			ATOMDLL:SetMultiplayer(true);
			self.hasAI = false;
			
			ATOMAI:Log("AI Disabled on %s", self.class);
		end
		
		function BasicAI.Server:OnInit()
			SysLog("Init AI")
			BasicAI.RegisterAI(self);
			self:OnReset();
		end
		function BasicAI:OnPropertyChange()
			SysLog("RE Init AI")
			BasicAI.RegisterAI(self);
			self:OnReset();
		end
		
		Player.RegisterAI = function(self)
			BasicAI.RegisterAI(self);
		end;
		Player.UnregisterAI = function(self)
			BasicAI.UnregisterAI(self);
		end;
		Player.ForcePlayerAI = function(self)
			BasicAI.ForcePlayerAI(self);
		end;
		Player.RemovePlayerAI = function(self)
			BasicAI.RemovePlayerAI(self);
		end;
		
		for i, v in pairs(System.GetEntities()) do
			if (v.actor) then
				--v.Server.OnInit = BasicAI.Server.OnInit;
				v.OnPropertyChange = BasicAI.OnPropertyChange;
				v.UnregisterAI = BasicAI.UnregisterAI;
				v.RegisterAI = BasicAI.RegisterAI;
				v.ForcePlayerAI = BasicAI.ForcePlayerAI;
				v.RemovePlayerAI = BasicAI.RemovePlayerAI;
			end;
		end;
		
		function FixWeapon(entity, weapon)
			if (weapon) then
				weapon = System.GetEntity(weapon)
				if (weapon and not weapon._attached) then
					local weapon_attach = weapon:GetName() .. g_utils:SpawnCounter();
					weapon._attached = true;
					entity:CreateBoneAttachment(0, "weapon_bone", weapon_attach);
					entity:SetAttachmentObject(0, weapon_attach, weapon.id, -1, 0);
					--entity:SetAttachmentDir(0,weapon_attach,entity.actor:GetHeadDir(),true);
					Script.SetTimer(1000, function()
						if (System.GetEntity(weapon.id)) then
							ExecuteOnAll(formatString([[
								local entity=GetEnt('%s')
								local moac=GetEnt('%s')
								local wp=moac:GetName() .. %d;
								if (entity) then
									entity:CreateBoneAttachment(0, "weapon_bone", wp);
									entity:SetAttachmentObject(0, wp, moac.id, -1, 0);
									entity:SetAttachmentDir(0,wp,entity.actor:GetHeadDir(),true);
								end;
							]], entity:GetName(), weapon:GetName(), g_utils:SpawnCounter()));
							Debug("Fixed ",weapon.class)
						end;
					end);
				end;
			end;
		end;

	end,
	----------
	Update = function(self, entity)
	
		if (System.GetCVar("atom_aisystem") ~= 1) then
			return;
		end;
		
		local GiveItem = ItemSystem.GiveItem;
		local GiveItemPack = ItemSystem.GiveItemPack;
		
		local entities = System.GetEntities();
		
		for i, entity in pairs(entities or{}) do
			if (entity.isPlayer) then
			
				if (entity.actor:GetHealth() > 0) then
					if (not entity.actor:GetAI() or not entity.hasAI) then
						BasicAI.RegisterAI(entity)
					end
				elseif (entity.actor:GetAI() or entity.hasAI) then
					BasicAI.UnregisterAI(entity)
				end
				-- do nothing
			elseif (entity.actor) then
			
				if (entity.actor:GetHealth() > 0) then
					--Debug("alive?")
					if (not entity.actor:GetAI() or not entity.hasAI) then
						BasicAI.RegisterAI(entity)
					end
				
					local update_rate = 1
				
					local inRange = GetPlayersInRange(entity:GetPos(), 100);
				
					entity:AddImpulse(-1, entity:GetCenterOfMassPos(), entity:GetDirectionVector(), 1, 1);
				
					if (inRange and arrSize(inRange) >= 1) then
						--SysLog("Update %s : %s, %s", entity.class, entity:GetName(), Vec2Str(entity:GetPos()))
						if (not entity.direction_update or _time - entity.direction_update>update_rate) then
							local dir-- = entity.actor:GetSyncDir();
							if (not dir or NullVector(dir) or not isVec(dir)) then
								dir = entity.actor:GetHeadDir()
							end
							--DebugTable(entity
							local jammer = AI.GetAttentionTargetEntity( entity.id);
							if (jammer) then
								jammer=jammer:GetPos();
							end;
							
							
							ExecuteOnAll("local x=GetEnt('"..entity:GetName().."')if (x) then x.ldir="..arr2str_(dir)..";end")
							
							entity.direction_update = _time;
						end
					end;
						
					local inventory = entity.inventory;
					local inventory_count = inventory:GetCount();
					local bSuit = entity.Properties.bNanoSuit; 
					bSuit = bSuit and bSuit == 1;
					
					
					if (bSuit and not inventory:GetItemByClass("NanoSuit")) then
						ItemSystem.GiveItem("NanoSuit", entity.id, false)
					end;
					
					local pre_pack = PREDEFINED_EQUIP_PACK[entity.class:upper()];
					local pre_equip = PREDEFINED_EQUIP[entity.class:upper()];
					local item_pack = entity.Properties.equip_EquipmentPack;
					
					if (pre_pack) then
						if (inventory_count < 1 and (not item_pack or item_pack == "")) then
							entity.Properties.equip_EquipmentPack = pre_pack;
						end;
					end;
					
					if (inventory_count < 1 and item_pack and string.len(item_pack) >= 1) then
						GiveItemPack(entity.id, item_pack, false, true);
					end;
					
					inventory_count = inventory:GetCount();
					
					if (inventory_count < 1) then
						if (pre_equip) then
							for _, _i in pairs(pre_equip) do
								ItemSystem.GiveItem(_i, entity.id, false)
							end;
						end;
					end;
					
					inventory_count = inventory:GetCount();
					
					if (entity.class == "Scout") then
						local moar, moac = inventory:GetItemByClass("Scout_MOAR"), inventory:GetItemByClass("ScoutMOAC");
						FixWeapon(entity, moar);
						FixWeapon(entity, moac);
					elseif (entity.class == "Hunter") then
						local sing, hunter_moar, hunter_moar2 = inventory:GetItemByClass("SingularityCannon"), inventory:GetItemByClass("MOAR"), inventory:GetItemByClass("HunterSweepMOAR");
						FixWeapon(entity, sing);
						FixWeapon(entity, hunter_moar);
						FixWeapon(entity, hunter_moar2);
					end;
						
					if (bSuit) then
						local suit = entity.actor:GetNanoSuitMode();
						if (not entity.LastSuitMode or suit ~= entity.LastSuitMode) then
							ExecuteOnAll([[Msg(0, "suitmode");GetEnt(']]..entity:GetName()..[[').actor:SetNanoSuitMode(]] .. suit .. [[)Msg(0, "suitmode ok");]]);
						end;
						entity.LastSuitMode = suit;
					end;
					
				elseif (entity.actor:GetAI()) then-- or entity.hasAI) then
					BasicAI.UnregisterAI(entity)
					entity.hasAI = false;
				end;
			end;
		end;
	end,
	----------
	Log = function(self, msg, ...)
		Debug("logged ???")
		System.LogAlways("<ATOM> : AI : " .. formatString(msg, ...));
	end,
	----------
	RegisterAI = function(self, entity) -- self == entity
		
		Debug("AI REGISTERED!!")
		
		if (entity.isPlayer or (entity.actor:IsPlayer())) then
			return (entity.CoopForceAI and entity:CoopForceAI() or self:RegisterAI_Player(entity));
		end
		
		ATOMDLL:SetMultiplayer(false)
		
		if ( entity.AIType == nil ) then
			AI.RegisterWithAI(entity.id, AIOBJECT_PUPPET, entity.Properties or{}, entity.PropertiesInstance or{}, entity.AIMovementAbility or{},entity.melee or{});
		else
			AI.RegisterWithAI(entity.id, entity.AIType, entity.Properties or{}, entity.PropertiesInstance or{}, entity.AIMovementAbility or{},entity.melee or{});
		end
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
		AI.ChangeParameter(entity.id,AIPARAM_FORGETTIME_TARGET,entity.forgetTimeTarget);
		AI.ChangeParameter(entity.id,AIPARAM_FORGETTIME_SEEK,entity.forgetTimeSeek);
		AI.ChangeParameter(entity.id,AIPARAM_FORGETTIME_MEMORY,entity.forgetTimeMemory);
	
		-- If the entity is hidden during 
		if (entity:IsHidden()) then
			AI.LogEvent(entity:GetName()..": The entity is hidden during init -> disable AI.");
			entity:TriggerEvent(AIEVENT_DISABLE);
		end;
		self:Log("Enabled on actor %s", entity.class)
		
		ATOMDLL:SetMultiplayer(true)
	end,
	----------
	UnregisterAI = function(self, entity)
		Debug("AI UNREGISTERED!!")
		self:Log("Disabled on actor %s", entity.class)
		
		ATOMDLL:SetMultiplayer(false)
		AI.RegisterWithAI(entity.id, 0, entity.Properties or{}, entity.PropertiesInstance or{}, entity.AIMovementAbility or{},entity.melee or{});
		ATOMDLL:SetMultiplayer(true)
	end,
	----------
	RegisterAI_Player = function(self, entity)
		ATOMDLL:SetMultiplayer(false)
		AI.RegisterWithAI(entity.id, AIOBJECT_PLAYER, entity.Properties or{}, entity.PropertiesInstance or{});
		ATOMDLL:SetMultiplayer(true)
		self:Log("Enabled on player %s", entity.class)
	end,
	----------
};
ATOMAI:Init();







function SpawnBot(player,tm)
	local randomNames = {
		"x",
		"z"
	};
	
	local rndSpawnPointLocation = {}
	local allll = System.GetEntitiesByClass("SpawnPoint") 
	rndSpawnPointLocation = player:CalcSpawnPos(5)--allll[math.random(#allll)]:GetPos();

SPECIES_COUNTER=(SPECIES_COUNTER or 3) +1

	
	BasicActor.Properties.equip_EquipmentPack = "NK_Rifle";
		
	local c = System.SpawnEntity({class="Player",position=rndSpawnPointLocation,name=GetRandom(randomNames)});--System.GetEntity(ATOMDLL:SpawnArchetype("Asian_new.Flanker\\Camp.Heavy_Rifle", rndSpawnPointLocation, {x=0,y=0,z=0},GetRandom(randomNames)..GetRandom(999999), "")) --System.SpawnEntity({class="Player", position = rndSpawnPointLocation, name=CF_NameHandler:GenerateName(),orientation=SinepUtils.MathUtils:NullVector(), Properties={species=SPECIES_COUNTER},properties={species=SPECIES_COUNTER}})
	c.bot=1
	
c.Properties.species = 3
	
	c.noRegister = 1
	
	BasicActor.Properties.equip_EquipmentPack = "";
		
	c.ai = 1;
	
	c.primaryWeapon = "FY71"
	c.secondaryWeapon = "SOCOM"
		
	c.Behaviour = {
	}
	
	c.onAnimationStart = {}
	c.onAnimationEnd = {}
	c.onAnimationKey = {}
	
	c.SuitMode ={
		SUIT_OFF=0,
		SUIT_ARMOR=1,		
		SUIT_CLOAK=2,
		SUIT_POWER=3,
		SUIT_SPEED=4,				
	}
	
	c.supressed=0
	c.supressedTrh=8
		
		
		c.PropertiesInstance.soclasses_SmartObjectClass = "Actor"
		c.PropertiesInstance.groupid = 173
		c.PropertiesInstance.aibehavior_behaviour = "Job_StandIdle"
		c.PropertiesInstance.bAutoDisable = 0
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


	c.actor:SetParams(c.gameParams)
	
	-- the AI movement ability 
	c.AIMovementAbility ={
		pathFindPrediction = 0.5,		-- predict the start of the path finding in the future to prevent turning back when tracing the path.
		allowEntityClampingByAnimation = 1,
		usePredictiveFollowing = 1,
		walkSpeed = 2.0, -- set up for humans
		runSpeed = 4.0,
		sprintSpeed = 6.4,
		b3DMove = 0,
		pathLookAhead = 1, 
		pathRadius = 0.4,
		pathSpeedLookAheadPerSpeed = -1.5,
		cornerSlowDown = 0.75,
		maxAccel = 3.0,
		maxDecel = 8.0,
		maneuverSpeed = 1.5,
		velDecay = 0.5,
		minTurnRadius = 0,	-- meters
		maxTurnRadius = 3,	-- meters
		maneuverTrh = 2.0,  -- when cross(dir, desiredDir) > this use manouvering
		resolveStickingInTrace = 1,
		pathRegenIntervalDuringTrace = 4,
		lightAffectsSpeed = 1,

		-- These are actually aiparams (as they may be changed during game and need to get serialized),
		-- but defined here so that designers do not try to change them.
		lookIdleTurnSpeed = 30,
		lookCombatTurnSpeed = 50,
		aimTurnSpeed = -1, --120,
		fireTurnSpeed = -1, --120,
		
		-- Adjust the movement speed based on the angel between body dir and move dir.
		directionalScaleRefSpeedMin = 1.0,
		directionalScaleRefSpeedMax = 8.0,
};
	  c.AIMovementAbility.AIMovementSpeeds =  {
			Relaxed =
			{
				Slow =		{ 1.0, 1.0,1.9 },
				Walk =		{ 1.3, 1.0,1.9 },
				Run =			{ 4.5, 2.0,7.2 },
			},
			Combat =
			{
				Slow =		{ 0.8, 0.8,1.3 },
				Walk =		{ 1.3, 0.8,1.3 },
				Run =			{ 4.5, 2.3,6.0 },
				Sprint =	{ 6.5, 2.3,6.5 },
			},
			Crouch =
			{
				Slow =		{ 0.5, 0.3,1.3 },
				Walk =		{ 0.9, 0.3,1.3 },
				Run =			{ 3.5, 2.7,5.5 },
			},
			Stealth =
			{
				Slow =		{ 0.8, 0.7,1.0 },
				Walk =		{ 0.9, 0.7,1.0 },
				Run =			{ 3.5, 2.7,5.5 },
			},
			Prone =
			{
				Slow =		{ 0.4, 0.4,0.5 },
				Walk =		{ 0.5, 0.4,0.5 },
				Run =			{ 0.5, 0.4,0.5 },
			},
			Swim =
			{
				Slow =		{ 0.5, 0.6,0.7 },
				Walk =		{ 0.6, 0.6,0.7 },
				Run =			{ 3.0, 2.9,4.3 },
			},
		};
	
	
	c.AI_changeCoverLastTime = 0;
	c.AI_changeCoverInterval = 7;
	
	
	c.AIFireProperties = c.AIFireProperties or{
	};
	c.AI =c.AI or {};
	
	-- now fast I forget the target (S-O-M speed)
	c.forgetTimeTarget = 16.0;
	c.forgetTimeSeek = 20.0;
	c.forgetTimeMemory = 20.0;
	
	c.Properties.preferredCombatDistance = 20;
	

	--melee stuff
	c.melee = c.melee or {}
	c.melee.damageRadius = 1.1							-- size of the damage box.

	for i,v in pairs(Grunt)do
		if (type(v) == "function") then
			if (not c[i]) then
				c[i] = Grunt[i];
			end;
		end;
	end;
	
	for i,v in pairs(BasicAI)do
		if (type(v) == "function") then
			if (not c[i]) then
				c[i] = BasicAI[i];
			end;
		end;
	end;
	
	for i,v in pairs(BasicAITable)do
		if (not c[i]) then
			c[i] = BasicAITable[i];
		end;
	end;
	
	for i,v in pairs(BasicAIEvent)do
		if (type(v) == "function") then
			if (not c[i]) then
				c[i] = BasicAIEvent[i];
			end;
		end;
	end;
	c.bot=1
	c.explosion_death_impulse =
	{ -- explosion impulse
		headshot =
		{
			{
				direction = {x=0,y=0,z=-1},
				strength = 1.2,
				partId = -1,
			},			
			{
				use_direction = true,
				direction = {x=1,y=1,z=1},
				use_strength = true,
				partId = -1,
				strength = 1.2,
			},						
			{
				use_direction = true,
				direction = {x=1,y=1,z=1},
				strength = 1.2,
				partId = 31,
			},
		},
		chestshot =
		{
			{
				direction = {x=0,y=0,z=1},
				use_strength = true,
				partId = -1,
				strength = 1.2,
			},
			{
				use_direction = true,
				direction = {x=1,y=1,z=1},
				use_strength = true,
				partId = -1,
				strength = 1.2,
			},
			{
				use_direction = true,
				direction = {x=1,y=1,z=1},
				use_strength = true,
				partId = 23,
				strength = 1.2,
			},
			{
				use_direction = true,
				direction = {x=1,y=1,z=1},
				use_strength = true,
				partId = 6,
				strength = 1.2,
			},
			{
				use_direction = true,
				direction = {x=-1,y=-1,z=-1},
				use_strength = true,
				partId = 62,
				strength = 0.3,
			},
			{
				use_direction = true,
				direction = {x=-1,y=-1,z=-1},
				use_strength = true,
				partId = 38,
				strength = 0.3,
			},
		},
		rotate = 0.3,
	};
	c.death_impulses =
	{
		{ -- Light Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 50,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 50,
					partId = 31,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 25,
					partId = 2,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 25,
					partId = 3,
				},							
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 50,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					strength = 5,
				},
			},
			rotate = 0,
		},
		{ -- Shotgun Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=-1},
					strength = 500,
					partId = -1,
				},			
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					partId = -1,
					strength = 2,
				},						
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 150,
					partId = 31,
				},
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 600,
					use_strength = true,
					partId = -1,
					strength = 10,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					partId = -1,
					strength = 4,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					partId = 23,
					strength = 2,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					partId = 6,
					strength = 2,
				},
				{
					use_direction = true,
					direction = {x=-1,y=-1,z=-1},
					use_strength = true,
					partId = 62,
					strength = 0.3,
				},
				{
					use_direction = true,
					direction = {x=-1,y=-1,z=-1},
					use_strength = true,
					partId = 38,
					strength = 0.3,
				},
			},
			rotate = 0.3,
		},
		{ -- Assault Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 40,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 75,
					partId = 31,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 2,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 3,
				},					
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 30,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					strength = 5,
				},
			},
			rotate = 1,
		},
		{ -- Sniper Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 40,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 100,
					partId = 31,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 2,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 3,
				},								
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 40,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					strength = 2,
				},
			},
			rotate = 1,
		},
		{ -- Hurricane Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 40,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 100,
					partId = 31,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 2,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 3,
				},								
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 100,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					strength = 4,
				},
			},
			rotate = 1,
		},
		{ -- Gauss Bullet
			headshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 150,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					strength = 200,
					partId = 31,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 2,
				},
				{
					direction = {x=0,y=1,z=0},
					strength = 50,
					partId = 3,
				},				
			},
			chestshot =
			{
				{
					direction = {x=0,y=0,z=1},
					strength = 150,
					partId = -1,
				},
				{
					use_direction = true,
					direction = {x=1,y=1,z=1},
					use_strength = true,
					strength = 4.0,
				},
			},
			rotate = 0,
		},
	};
	
	
		
	ItemSystem.GiveItemPack(c.id, c.Properties.equip_EquipmentPack, false, true)
	--RefillAmmo(c)
	
	--for i=0,300 do
	AI.EnableWeaponAccessory(c.id, 1, true);

	--end;
	c.noRegister = 0
	BasicAI.UnregisterAI(c) --:UnregisterAI()
	BasicAI.RegisterAI(c) --c:RegisterAI()
	--]]
		RPC:OnAll("BattleLogEvent", {type = "eBLE_Information", message = "@mp_BLPlayerConnected", pA = c:GetName()})
	
	return c
	
	--RPC:OnAll("EntityLoadMode", { model = "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf", name = c:GetName() })
end;