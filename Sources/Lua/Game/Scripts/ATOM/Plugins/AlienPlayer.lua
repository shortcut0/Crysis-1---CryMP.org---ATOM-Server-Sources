Script.ReloadScript("scripts/entities/actor/basicalien.lua");


AlienPlayer = 
{
	type = "Alien",
		
	Properties = 
	{
		health = 255,
	
		-- AI-related properties
		--groupid = 0,
		--species = 0,
		--commrange = 40; -- Luciano - added to use SIGNALFILTER_GROUPONLY
		-- AI-related properties over
		
		--fileModel = "Objects/characters/alien/methagen/Methagen.cdf",
		
		----
		soclasses_SmartObjectClass = "Player",
		groupid = 0,
		species = 0,
		commrange = 40; -- Luciano - added to use SIGNALFILTER_GROUPONLY
		-- AI-related properties over

		voiceType = "player",
		aicharacter_character = "Player",

		Perception =
		{
			--how visible am I
			camoScale = 1,
			--movement related parameters
			velBase = 1,
			velScale = .03,
			--ranges			
			sightrange = 50,
		}	,
		--
		fileModel = "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf",
		clientFileModel = "objects/characters/human/us/nanosuit/nanosuit_us_fp3p.cdf",
		--fileModel = "objects/characters/human/asian/nanosuit/nanosuit_asian_fp3p.cdf",
		fpItemHandsModel = "objects/weapons/arms_global/arms_nanosuit_us.chr",	
		--fpItemHandsModel = "objects/weapons/arms_global/arms_nanosuit_asian.chr",	
		objFrozenModel= "objects/characters/human/asian/nk_soldier/nk_soldier_frozen_scatter.cgf",
		
	},
	
	PropertiesInstance = {
		aibehavior_behaviour = "PlayerIdle",
	},
	
	ammoCapacity =
	{
		bullet=40*7,
		fybullet=30*10,
		lightbullet=20*10,
		smgbullet=50*7,
		explosivegrenade=10,
		flashbang=10,
		smokegrenade=10,
		empgrenade=10,
		scargrenade=10,
		rocket=3,
		sniperbullet=10*3,
		tacbullet=4*5,
		tagbullet=10,
		gaussbullet=4*5,
		hurricanebullet=500,
		incendiarybullet=30*10,
		shotgunshell=8*5,
		avexplosive=3,
		c4explosive=4,
		claymoreexplosive=3,
		rubberbullet=30*20,
		tacgunprojectile=5,
	},
	
	gameParams =
	{
		stance =
		{
			{
				stanceId = STANCE_STAND,
				normalSpeed = 1.75,
				maxSpeed = 4.5,
				heightCollider = 1.2,
				heightPivot = 0.0,
				size = {x=0.4,y=0.4,z=0.3},
				viewOffset = {x=0,y=0.15,z=1.625},
				modelOffset = {x=0,y=0,z=0.0},
				name = "combat",
				useCapsule = 1,
			},
			-- -2 is a magic number that gets ignored by CActor::SetupStance
			{
				stanceId = -2,
			},
			--
			{
				stanceId = STANCE_CROUCH,
				normalSpeed = 1.0,
				maxSpeed = 1.5,
				heightCollider = 0.9,
				heightPivot = 0,
				size = {x=0.4,y=0.4,z=0.1},
				viewOffset = {x=0,y=0.1,z=1.0},
				modelOffset = {x=0,y=0,z=0},
				name = "crouch",
				useCapsule = 1,
			},
			--
			{
				stanceId = STANCE_PRONE,
				normalSpeed = 0.375,
				maxSpeed = 0.75,
				heightCollider = 0.4,
				heightPivot = 0,
				size = {x=0.35,y=0.35,z=0.001},
				viewOffset = {x=0,y=0.0,z=0.5},
				modelOffset = {x=0,y=0,z=0},
				weaponOffset = {x=0.0,y=0.0,z=0.0},
				name = "prone",
				useCapsule = 1,
			},
			--
			{
				stanceId = STANCE_SWIM,
				normalSpeed = 1.0,
				maxSpeed = 2.5,
				heightCollider = 1.0,
				heightPivot = 0,
				size = {x=0.4,y=0.4,z=0.35},
				viewOffset = {x=0,y=0.1,z=1.5},
				modelOffset = {x=0,y=0,z=0.0},
				weaponOffset = {x=0.3,y=0.0,z=0},
				name = "swim",
				useCapsule = 1,
			},
			--
			{
				stanceId = STANCE_ZEROG,
				normalSpeed = 1.75,
				maxSpeed = 3.5,
				heightCollider = 0.0,
				heightPivot = 0,
				size = {x=0.6,y=0.6,z=0.001},
				viewOffset = {x=0,y=0.0,z=0.35},
				modelOffset = {x=0,y=0,z=0.0},
				weaponOffset = {x=0.3,y=0.0,z=0},
				name = "zerog",
				useCapsule = 1,
			},
			-- -2 is a magic number that gets ignored by CActor::SetupStance
			{
				stanceId = -2,
			},
		},
		
		nanoSuitActive = 1,
--		thrusterAISoundRadius = 38,
		
	},
			
	modelSetup =
	{
		deadAttachments = {"head","helmet"},
	},
	
	physicsParams =
	{
		flags = 0,
		mass = 200,
		stiffness_scale = 73,
		--k_air_control = 0.9, --not used atm
			
		Living = 
		{
			gravity = 15,--REMINDER: if there is a ZeroG sphere in the map, gravity is set to 9.81.
						 --It will be fixed, but for now just do all the tweaks without any zeroG sphere in the map.
			mass = 200,
			--inertia = 5.5, --not used atm
			air_resistance = 0.0, --used in zeroG
		},
	},
	
	moveParams =
	{
		standSpeed = 7.0,--meters/s
		speedInertia = 9.0,--the more, the faster the speed change: 1 is very slow, 10 is very fast already 
		rollAmmount = 3.0,
		
		sprintMultiplier = 1.5,--speed is multiplied by this ammount when alien is sprinting
		sprintDuration = 0.5,--how long the sprint is
		
		rotSpeed_min = 0.9 * 7.0,--1.0,--rotation speed at min speed
		rotSpeed_max = 0.6 * 7.0,--rotation speed at max speed
		
		speed_min = 0.0,--used by the above parameters
		
		forceView = 1.0,--multiply how much the view is taking into account when moving
		
		--graphics related
		modelOffset = {x=0,y=0,z=0},
	},
	
	--melee stuff
	melee_animations =
	{
		{
			"melee_03",
			"melee_04",
			1,
		},
	},
		
	Server = {},
	Client = {},
	
	squadFollowMode = 0,

	squadTarget = {x=0,y=0,z=0},
	SignalData = {},

	AI = {},
	OnUseEntityId = NULL_ENTITY,
	OnUseSlot = 0,
	grabParams =
	{
		collisionFlags = 0, --geom_colltype_player,		
						
		holdPos = {x=0.0,y=0.4,z=1.25}, -- position where grab is holded
						
		grabDelay = 0,--if IK is used, its the time delay where the limb tries to reach the object.
		followSpeed = 5.5,
		
		limbs = 
		{
			"rightArm",
			"leftArm",
			--"fpRightArm",
			--"fpLeftArm",
		},
		
		useIKRotation = 0,
	},
	
--	Bip01 R Clavicle
--	Bip01 R UpperArm
--	Bip01 R Forearm
--	Bip01 R Hand

	IKLimbs = 
	{
		{0,"rightArm","Bip01 R UpperArm","Bip01 R Forearm","Bip01 R Hand", IKLIMB_RIGHTHAND},
		{0,"leftArm","Bip01 L UpperArm","Bip01 L Forearm","Bip01 L Hand", IKLIMB_LEFTHAND},
				
		--{2,"fpRightArm","rootR","forearm_R","hand_R"},
		--{2,"fpLeftArm","rootL","forearm_L","hand_L"},
		
		--{2,"fpRightArm","rootR","","hand_R"},
		--{2,"fpLeftArm","rootL","","hand_L"},
	},
		
	bloodFlowEffectWater = "misc.blood_fx.water",
	bloodFlowEffect = "misc.blood_fx.ground",
	bloodSplatWall={	
		"Materials/decals/blood_splat1",
		"Materials/decals/blood_splat2",
		"Materials/decals/blood_splat5",
		"Materials/decals/blood_splat7",
		"Materials/decals/blood_splat11",
	},
	bloodSplatGround={	
		"materials/decals/blood_pool",
	},
	bloodSplatGroundDir = {x=0, y=0, z=-1},

	waterStats =
	{
		lastSplash = 0,
	},
	
	actorStats =
	{
		
	},lastHit =
	{
		dir = {x=0,y=0,z=0},
		pos = {x=0,y=0,z=0},
		velocity = {x=0,y=0,z=0},
		partId = -1,
		damage = 0,
		bulletType = -1,
	},
	
	tempSetStats =
	{
	},
}


Net.Expose {
	Class = AlienPlayer,
	ClientMethods = {
		PhysicalizeActor = {RELIABLE_ORDERED, PRE_ATTACH},
	},
	ServerMethods = {
	},
	ServerProperties = {
	}
}

function AlienPlayer.Server:OnInit()
	--self:OnInit();
	self:PhysicalizeActor();
end

function AlienPlayer.Server:OnInitClient( channelId )
	self.actorStats={}
	self.onClient:PhysicalizeActor( channelId )
end

function AlienPlayer:PhysicalizeActor()
	BasicAlien.PhysicalizeActor(self);
end



function AlienPlayer.Client:PhysicalizeActor()
	self:PhysicalizeActor()
end
function AlienPlayer:PhysicalizeActor()

end;

function AlienPlayer.Client:OnInit()
	self:OnInit();
end


function AlienPlayer.Client:OnUpdate( deltaTime )
end

function AlienPlayer.Server:OnUpdate( deltaTime )
	BasicAlien.Server.OnUpdate(self,deltaTime);
	--BasicActor.Server.OnUpdate(self,frameTime);
		
	--FIXME:temporary
	if (self.stopEPATime and self.stopEPATime < 0) then
		self.actor:SetParams({followCharacterHead = 0,});
		self.actor:SetMovementTarget(g_Vectors.v000,g_Vectors.v000,g_Vectors.v000,1);
		self.stopEPATime = nil;
		self.hostageID = nil;
		
		self:HolsterItem(false);
						
	elseif (self.stopEPATime) then
		self.stopEPATime = self.stopEPATime - frameTime;
	end
end

function AlienPlayer:OnInit()
	self.actor:SetMaxHealth( self.Properties.health )
	self.actor:SetHealth( self.Properties.health )
	
--	AI.RegisterWithAI(self.id, AIOBJECT_PUPPET, self.Properties, self.PropertiesInstance);
--	self:SetAIName("Alien");
	
	self:OnReset();
end


function AlienPlayer:OnReset()
	System.Log(" --->> AlienPlayer:OnReset  -------->>> ");
	BasicAlien.Reset(self);
end

function AlienPlayer:OnAction(action)
	if (action == "attack1") then
		self:MeleeAttack();
	end
end

function AlienPlayer.Client:OnShutDown()
end

function AlienPlayer:OnContact( Entity )
end

function AlienPlayer:OnEvent( EventId, Params )
end

function AlienPlayer:OnSave( props )
end

function AlienPlayer:OnLoad( props )
end 

function AlienPlayer.Server:OnTimer()
end

-- return true when the player died
function AlienPlayer:OnHit(hit)
	
	return false;
end

ATOMPatcher:CheckEntity("Player")

for i, v in pairs(Player) do
	if not AlienPlayer[i] then
		AlienPlayer[i] = Player[i]
	end;
end;

--function AlienPlayer:Physicalize()
--
--	self:Physicalize(0, PE_LIVING, self.physicsParams);	
--	self.actor:SetParams(self.moveParams);
--end
