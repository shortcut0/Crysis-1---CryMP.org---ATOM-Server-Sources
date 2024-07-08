	---------------------------------------------------------
	-- CLIENT UNDER CONSTRUCTION.
	-- THIEVES OUT. 
	-- ASK FOR MY PERMISSION BEFORE USING MY WORK.
	--
	-- COPYRIGHT (D) R 2006-2008
	--
	---------------------------------------------------------

	-- IDEAS
	--  + OVERWRITE ACTION ANIMATIONS 

	-- TODO
	--  + OH MA GAWD PLS REMOVE ALL SEMICOLONS !!!!


	--=========================================================
	-- Hallo
	--=========================================================
	
	-- is dis da first time we install the client?
	FIRST_INSTALL = (ATOMClient == nil)
	
	local p_data;
	if (ATOMClient) then
		p_data = ATOMClient.Patcher._patched;
	end;
	ATOMClient = {
		version = "3.1",
		LogVerbosity = 0,
	};
	
	ATOMClient._GLOBALS = {};
	ATOMClient._DEBUG	= true;

	--=========================================================
	-- Some Globals
	--=========================================================
	
	-- are the PS buy lists patched
	BUYLISTS_PATCHED	= false;
	
	-- is the mod disabled
	CLIENT_DISABLED 	= false;
	
	-- is the pak loaded
	CLIENT_MOD_ENABLED = false;
	
	-- IS THIS POWER STRUGGLE ??
	POWER_STRUGGLE = g_gameRules and g_gameRules.class == "PowerStruggle";
	
	--=========================================================
	-- START UP
	--=========================================================
	
	-- Clean up any mess
	if (CryMP) then -- Yes
		CryMP:RestoreOriginalFunctions();
		CryMP:OnDisconnect();
	end;

	--=========================================================
	-- Functions
	--=========================================================
	
		ATOMClient.Init = function(self)
		
			---------------------------------------------------------
			-- Init Libraries (STOLEN FROM BOT)
			self:InitLibraries()
		
			---------------------------------------------------------
			-- Vaporize leftovers
			self:Vaporize({ 
				"nCX", "CryMP", "CL_VERSION", "FRESH_INSTALL"
			});
		
			---------------------------------------------------------
			-- Add new functions
			self:RegisterFunctions();
			
			---------------------------------------------------------
			-- Check if PAK is loaded
			self:CheckPAK();
			
			---------------------------------------------------------
			-- EToServer Cases
			eTS_Spectator, eTS_Chat, eTS_ChatLua, eTS_Report 
			= 1, 2, 3, 4;
			
			---------------------------------------------------------
			-- Very Special Meeting commands
			eCE_JoinMeeting
			= 50
			
			---------------------------------------------------------
			-- EClientEvent Cases
			eCE_ClientInstalled, eCE_LoadCode,  eCE_ReportFPS, eCE_LoadEffect,
			eCE_UnloadEffect,    eCE_Sound,     eCE_Anim,      eCE_SetCapacity,
			eCE_ToggleLowSpec,   eCE_BattleLog, eCE_SetForced, eCE_AddForced
			= 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12;
			
			
			eCE_SetSuperSpeed, eCE_EnableSuperSpeed, eCE_SetWJMult,
			eCE_IdleAnim,      eCE_VehModel,         eCE_ATOMTaunt
			= 13, 14, 15, 16, 17, 18;
			
			---------------------------------------------------------
			-- EClientResponse Cases
			eCR_JetpackOn, eCR_JetpackOff,
			eCR_RocketON,  eCR_RocketOFF
			= 12, 13, 17, 18;
			
			---------------------------------------------------------
			-- EClientResponse Cases determining what client we're on
			eCR_ClientSFWCL, eCR_ClientCryMP, eCR_ClientUnknown 
			= 100, 101, 102;
			
			---------------------------------------------------------
			-- Mouse commands
			eCR_MouseP,  eCR_MouseR, -- pr
			eCR_MeleeP,  eCR_MeleeR, -- pr
			eCR_MousePL, eCR_MouseRL -- plrl
			= 30, 31, 32, 33, 34, 35;
			
			---------------------------------------------------------
			-- Vehicle commands
			eCR_HornyON,  	eCR_HornyOFF,
			eCR_VBoostON, 	eCR_VBoostOFF,
			eCR_VForwardOn, eCR_VForwardOff,
			eCR_VBrakeON,	eCR_VBrakeOFF
			= 40, 41, 42, 43, 44, 45, 46, 47;
			
			---------------------------------------------------------
			-- Object commands
			eCR_UseObject1		= 70; -- Airdrop
			eCR_Interactive		= 71; -- Order Drink
			eCR_ChairOFF		= 72;
			eCR_ChairON			= 73;
			eCR_UseObject0		= 74; -- just 'use' key
			eCR_DropSpecial		= 76; -- drop special crap
			
			---------------------------------------------------------
			-- Ping Pong commands
			eCR_Pong			= 110;
			
			-- IDs in range from 120 to 131 are used by bound keys
			
			---------------------------------------------------------
			-- EAntiCheat Cases
			eAC_NoRecoil, eAC_Gravity, eAC_Flags,
			eAC_Mass,     eAC_Speed,   eAC_Teleport,
			eAC_Door
			= 20, 21, 22, 23, 24, 25, 26;
			
			---------------------------------------------------------
			-- Global Variables and tables
			
			self._GLOBALS = {
				-- keep these globals on re-install
				restore = 
				{
					-- items             hagdoll sync          sounds            discord nitro 
					"ATTACHED_ITEMS",   "RAGDOLL_BALLS",    "LOOPED_SOUNDS",     "NITRO_VEHICLES",
					-- anims               sticky positions       obj anims           guns
					"LOOPED_ANIMS",     "STICKY_POSITIONS", "ACTIVE_ANIMATIONS", "GUNS_WITH_MODELS",
					-- cracks               chairs               OST              jets
					"EXPLOSION_CRACKS", "FLYING_CHAIRS",    "ATOM_2D_TEXTS",     "JETS",
					-- digga!!           fire trucks         fire tires
					"GRABBED_DIGGAS",   "WATER_TANKS",      "FIRE_TIRES",
					-- remote           -- forced actions
					"Remote",           --"FORCED_ACTIONS"
				},
				-- reset these globals on re-install
				reset =
				{
					-- cvars
					{ "FORCED_CVARS",     {} },
					{ "ATTACHED_HELMET", nil },
					{ "FLYMODE_STATE",   nil },
					{ "HIT_MARKERS",      {} },
				},
				-- special values for these globals
				value = 
				{
					-- Forced Actions, leave empty for DEFAULT 
					{ "FORCED_ACTIONS", {
						["Hurricane"] = "mine",
						["LAW"]       = "pistol", -- Lol..
						["Golfclub"]  = "mg", -- Lol..
					},                               true },
					-- Vehicle Boost
					{ "VEHICLE_BOOST_UP_AMOUNT",        2 },
					{ "VEHICLE_BOOST_FORWARD_AMOUNT", 4.5 },
					{ "VEHICLE_BOOST_TIME", 		    5 },
					{ "VEHICLE_WEAPON_SYSTEM",       true },
					{ "VEHICLE_MODEL_SLOT_COUNTER",   150 },
					-- entity properties synch
					{ "CAP_ENVIRONMENT_STEPS",          1 },
					-- fly mode
					{ "FLYMODE_UPDATE_RATE",         .015 },
					-- masks
					{ "MASK_CLOAK",               2, true },
					-- moreHUD
					{ "MOREHUD_SCAN_DIST",        5, true },
					{ "MOREHUD_SHOW_ALL",     false, true },
					-- FPS LIMIT
					{ "THE_FPS_LIMIT",            0, true },
					{ "CLIENT_FPS_LIMIT",        30, true },
					-- search LASERS, NOT lights.
					{ "SEARCHLASER_SCALE",       15, true },
					-- hp bars
					{ "USE_FLOATING_HP_BAR",  false, true },
					{ "HEALTHBAR_SIZE",          75, true },
					-- no dts (just for chris)
					{ "ATOM_NO_DTS",              0, true },
					-- hit sounds
					{ "CUSTOM_HIT_SOUNDS",    false, true },
					-- rank models
					{ "USE_RANK_MODELS",      false, true },
					-- dummies
					{ "null_function",function()end, true },
					-- dummies
					{ "FEMALE_NANOSUIT_PATH", "objects/characters/human/story/helena_rosenthal/helena_rosenthal.cdf" },
					
				}
			};
			
			---------------------------------------------------------
			-- keep these
			for i, g in pairs(self._GLOBALS.restore) do
				_G[g] = _G[g] or {};
			end;
			-- reset those
			for i, g in pairs(self._GLOBALS.reset) do
				_G[g[1]] = _G[g[1]] or (g[2] or nil);
			end;
			-- change these
			for i, g in pairs(self._GLOBALS.value) do
				_G[g[1]] = (g[3] and g[2] or (_G[g[1]] or g[2]));
			end;
			
			-- Collapse this for your own viewing experience
			RANK_MODELS = {
				[1] = { -- PVT
					[1] = { 
					{ 
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_01.cdf", 
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_03.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_04.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_05.cdf"
					}, arms, frozen, fp3p },
					[2] = { { 
						"objects/characters/human/us/marine/marine_afroamerican_01.cdf",
						"objects/characters/human/us/marine/marine_afroamerican_02.cdf",
						"objects/characters/human/us/marine/marine_afroamerican_03.cdf",
						"objects/characters/human/us/marine/marine_afroamerican_04.cdf",
						"objects/characters/human/us/marine/marine_afroamerican_05.cdf",
					}, arms, frozen, fp3p },
				};
				[2] = { -- CPL
					[1] = {
					{
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_03.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_04.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_05.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_06.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_07.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_flanker_light_08.cdf",
						
					}, nil, nil, nil },
					[2] = { { 
						"objects/characters/human/us/marine/marine_16.cdf",
						"objects/characters/human/us/marine/marine_19.cdf",
						"objects/characters/human/us/marine/marine_23.cdf",
						"objects/characters/human/us/marine/marine_24.cdf",
					}, arms, frozen, fp3p },
				};
				[3] = { -- SGT
					[1] = {
					{
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_03.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_04.cdf",
						
					}, nil, nil, nil },
					[2] = { { 
						"objects/characters/human/us/marine/marine_caucasian_01.cdf",
						"objects/characters/human/us/marine/marine_caucasian_02.cdf",
						"objects/characters/human/us/marine/marine_caucasian_03.cdf",
						"objects/characters/human/us/marine/marine_12.cdf",
						"objects/characters/human/us/marine/marine_11.cdf",
						"objects/characters/human/us/marine/marine_10.cdf",
					}, arms, frozen, fp3p },
				};
				[4] = { -- LT
					[1] = {
					{
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_03.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_04.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_05.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_06.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_light_gren_07.cdf",
					}, nil, nil, nil },
					[2] = { { 
						"objects/characters/human/us/marine/marine_caucasian_01.cdf",
						"objects/characters/human/us/marine/marine_caucasian_02.cdf",
						"objects/characters/human/us/marine/marine_caucasian_03.cdf",
						"objects/characters/human/us/marine/marine_12.cdf",
						"objects/characters/human/us/marine/marine_11.cdf",
						"objects/characters/human/us/marine/marine_10.cdf",
					}, arms, frozen, fp3p },
				
				};
				[5] = { -- CPT
					[1] = {
					{
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_heavy_gren_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_heavy_gren_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_heavy_gren_03.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_heavy_gren_04.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_flanker_heavy_gren_05.cdf",
					}, nil, nil, nil },
					[2] = { { 
						"objects/characters/human/us/marine/marine_01_helmet_goggles_off.cdf",
						"objects/characters/human/us/marine/marine_02_helmet_goggles_off.cdf",
						"objects/characters/human/us/marine/marine_03_helmet_goggles_off.cdf",
						"objects/characters/human/us/marine/marine_04_helmet_goggles_off.cdf",
						"objects/characters/human/us/marine/marine_05_helmet_goggles_off.cdf",
						"objects/characters/human/us/marine/marine_06_helmet_goggles_off.cdf",
					}, arms, frozen, fp3p },
				};
				[6] = { -- MAJ
					[1] = {
					{
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_heavy_leader_shotgun_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_heavy_leader_shotgun_02.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_heavy_leader_01.cdf",
						"objects/characters/human/asian/nk_soldier/nk_soldier_elite_heavy_leader_02.cdf",
					}, nil, nil, nil },
					[2] = { { 
						"objects/characters/human/us/marine/marine_01_helmet_goggles_on.cdf",
						"objects/characters/human/us/marine/marine_02_helmet_goggles_on.cdf",
						"objects/characters/human/us/marine/marine_03_helmet_goggles_on.cdf",
						"objects/characters/human/us/marine/marine_04_helmet_goggles_on.cdf",
						"objects/characters/human/us/marine/marine_05_helmet_goggles_on.cdf",
						"objects/characters/human/us/marine/marine_06_helmet_goggles_on.cdf",
					}, arms, frozen, fp3p },
				};
				[7] = { -- COL -- COL + = nanosuit, so leave empty for default model ;)
					[1] = {
					{
						"objects/characters/human/asian/officer/officer.chr"
					}, nil, nil, nil},
					[2] = {
					{
						"objects/characters/human/us/officer/officer_01.cdf",
						"objects/characters/human/us/officer/officer_02.cdf",
						"objects/characters/human/us/officer/officer_03.cdf",
						"objects/characters/human/us/officer/officer_04.cdf",
						"objects/characters/human/us/officer/officer_caucasian_01.cdf",
						"objects/characters/human/us/officer/officer_caucasian_02.cdf",
						"objects/characters/human/us/officer/officer_caucasian_03.cdf",
						"objects/characters/human/us/officer/officer_caucasian_04.cdf",
					}, nil, nil, nil},
				};
				--[8] = { -- GEN
				--};
			};
			
			---------------------------------------------------------
			-- Add Console Variables
			self:AddCommands();
			
			---------------------------------------------------------
			-- Hook Globals
			self:HookGlobals();
		
			---------------------------------------------------------
			-- hook the game rule functions for ATOM
			self:HookGameRules();
		
			---------------------------------------------------------
			-- hook entity scrips
			self:HookEntities();
			
			---------------------------------------------------------
			-- fixes some script bugs
			--self:FixBugs();
			
			---------------------------------------------------------
			-- create key bindings
			self:CreateBindings();
			
			---------------------------------------------------------
			-- check cvars
			self:CheckCVars();
			
			---------------------------------------------------------
			-- patch entities using new patcher
			self:PatchEntities();
			
			---------------------------------------------------------
			-- Patch BuyLists
			if (POWER_STRUGGLE) then
				Script.SetTimer(2000, function() -- Client sometimes installs before g_gameRules.factories exists??
					self:PatchBuyLists();
				end);
			end;
			
			---------------------------------------------------------
			-- inform server that we finished initialiazing the Client
			self:HandleEvent(eCE_ClientInstalled);
			
			---------------------------------------------------------
			-- Init LASERS
			self.AASearchLasers:Init();
			
			---------------------------------------------------------
			-- init patched entities
			self.Patcher:Init();
			
			
			-- Rank models for PS games
			-- 1 = NK, 2 = US
			-- First entry in table is for rankID, second is for teamID
			-- First table in team table (can be table or string) is client mode, 2nd is arms, 3rd is frozen and 4th idk wtf it is
			
			FIRST_INSTALL = false
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Shutdown = function(self, cause, desc)
			
			---------------------------------------------------------
			-- Information
			Msg(0, "Shutting Client down, %s (%s)", tostring(cause), tostring(desc));
			
			---------------------------------------------------------
			-- Restore all functions and objects to default value
			pcall(self.Patcher.Shutdown, self.Patcher, cause, desc);
		
			---------------------------------------------------------
			-- Remove EToServer Cases
			eTS_Spectator, eTS_Chat, eTS_ChatLua, eTS_Report 
			= nil;
			
			---------------------------------------------------------
			-- Remove EClientEvent Cases
			eCE_ClientInstalled, eCE_LoadCode,  eCE_ReportFPS, eCE_LoadEffect,
			eCE_UnloadEffect,    eCE_Sound,     eCE_Anim,      eCE_SetCapacity,
			eCE_ToggleLowSpec,   eCE_BattleLog, eCE_SetForced, eCE_AddForced
			= nil;
			
			
			eCE_SetSuperSpeed, eCE_EnableSuperSpeed, eCE_SetWJMult,
			eCE_IdleAnim,      eCE_VehModel,         eCE_ATOMTaunt
			= nil;
			
			---------------------------------------------------------
			-- Remove EClientResponse Cases
			eCR_JetpackOn, eCR_JetpackOff,
			eCR_RocketON,  eCR_RocketOFF
			= nil;
			
			---------------------------------------------------------
			-- Remove EClientResponse Cases determining what client we're on
			eCR_ClientSFWCL, eCR_ClientCryMP, eCR_ClientUnknown 
			= nil;
			
			---------------------------------------------------------
			-- Remove Mouse commands
			eCR_MouseP,  eCR_MouseR, -- pr
			eCR_MeleeP,  eCR_MeleeR, -- pr
			eCR_MousePL, eCR_MouseRL -- plrl
			= nil;
			
			---------------------------------------------------------
			-- Remove Vehicle commands
			eCR_HornyON,  	eCR_HornyOFF,
			eCR_VBoostON, 	eCR_VBoostOFF,
			eCR_VForwardOn, eCR_VForwardOff,
			eCR_VBrakeON,	eCR_VBrakeOFF
			= nil;
			
			---------------------------------------------------------
			-- Remove Object commands
			eCR_UseObject1		= 70; -- Airdrop
			eCR_Interactive		= 71; -- Order Drink
			eCR_ChairOFF		= 72;
			eCR_ChairON			= 73;
			eCR_UseObject0		= 74; -- just 'use' key
			eCR_DropSpecial		= 76; -- drop special crap
			
			---------------------------------------------------------
			-- Remove Remove Ping Pong commands
			eCR_Pong			= nil;
			
			---------------------------------------------------------
			-- Remove Remove EAntiCheat Cases
			eAC_NoRecoil, eAC_Gravity, eAC_Flags,
			eAC_Mass,     eAC_Speed,   eAC_Teleport,
			eAC_Door
			= nil;
			
			---------------------------------------------------------
			-- Remove Globals
			for a, b, c in table.zip(self._GLOBALS.restore, self._GLOBALS.reset, self._GLOBALS.value) do
				if (a) then _G[a] = nil; end;
				if (b) then _G[b] = nil; end;
				if (c) then _G[c] = nil; end;
			end;
			
			---------------------------------------------------------
			-- Remove Globals
			calcDist, average, g_game, GetEnt, round, totable, copyTable, isVec
			= nil;
			
			---------------------------------------------------------
			-- Remove Globals
			CamGirlPos, CamGirlDir
			= nil;
			
			---------------------------------------------------------
			-- Replace Globals
			Msg 		= null_function;
			
			---------------------------------------------------------
			-- Mark client as disabled
			CLIENT_DISABLED    = true;
			CLIENT_MOD_ENABLED = false;
			
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckPAK = function(self)
		
			-- This file sets CLIENT_MOD_ENABLED to true on Init
			Script.ReloadScript("ATOM/ATOMMain.lua");
			
			CLIENT_MOD_ENABLED = CLIENT_MOD_ENABLED or ATOM_Client ~= nil
			
			-- Message
			Msg(0, "PAK Loaded: %s", (CLIENT_MOD_ENABLED and "YES" or "NO"));
			
			if (CLIENT_MOD_ENABLED) then
				HUD.DrawStatusText( "ATOM MOD Loaded!" )
				if (g_localActor.actor:GetSpectatorMode() ~= 0 and FIRST_INSTALL) then
					System.ExecuteCommand( "i_reload" )
				end
			end
			
			Msg(0, "CLIENT_MOD_ENABLED = %s", tostring(CLIENT_MOD_ENABLED))
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.PatchEntities = function(self)
		
			---------------------------------------------------------
			-- Vehicle Base
			
			
			self.Patcher:Add("VehicleBase", function(self)
				Msg(0, "VehicleBase.OnPropertyChangeExtra was called.")
				if (self.OnPropertyChangeExtra) then		
					self:OnPropertyChangeExtra();
				end;
				--Msg(0, "test called");
				Msg(0, "CRYMP_CLIENT = %s, self.class = %s, CLIENT_MOD_ENABLED = %s", tostring(CRYMP_CLIENT), tostring(self.class), tostring(CLIENT_MOD_ENABLED))
				if (CRYMP_CLIENT and self.class == "Civ_car1" and CLIENT_MOD_ENABLED) then
					Msg(0, "using new modwel ???!??!");
					-- until ALL CLIENTS use CryMP client
					ChangeVehicleModel(self, "Objects/Vehicles/Niva2329/Niva2329.cga", {x=0,y=0.5,z=0}, {x=0,y=0,z=0}, 1, false)
					
				end;
			end, "OnPropertyChange", nil, true, "vehicle");
			
			-------------------------
			
			--[[
			self.Patcher:Add("VehicleBase", function(self, hit)
				Msg(0, "vehicle hit!")
				if (self.vehicle:IsDestroyed()) then
					if (CRYMP_CLIENT and self.class == "Civ_car1") then
						--Msg(0, "using new modwel ???!??!");
						-- until ALL CLIENTS use CryMP client
						--ChangeVehicleModel(self, "Objects/Vehicles/Niva2329/Niva2329_damaged.cga", {x=0,y=0.5,z=0}, {x=0,y=0,z=0}, 1, false)
						Msg(0, "vehicle ded")
					end;
				end;
			end, "OnHit", "Client", "vehicle");
			--]]
			
			---------------------------------------------------------
			-- Game Rules
			
			self.Patcher:Add("g_gameRules", function(self, vehicle, seat, passengerId)
				if (CLIENT_DISABLED) then
					assert(false,"still calling ATOM functions");
				end;
				
				ATOMClient:OnEnterVehicleSeat(vehicle, seat, passengerId)
			end, "OnEnterVehicleSeat");
			---------------------------------------------------------
			self.Patcher:Add("g_gameRules", function(self, vehicle, seat, passengerId)
				if (CLIENT_DISABLED) then
					assert(false, "still calling ATOM functions");
				end;
				
				ATOMClient:OnLeaveVehicleSeat(vehicle, seat, passengerId, exiting)
			end, "OnLeaveVehicleSeat");
			---------------------------------------------------------
			self.Patcher:Add("g_gameRules", function(self, playerId, pos, rot, teamId)
				if (CLIENT_DISABLED) then
					assert(false,"still calling ATOM functions");
				end;
				
				ATOMClient:OnRevive(playerId, pos, rot, teamId);
			end, "OnReviveInVehicle", "Client");
			---------------------------------------------------------
			self.Patcher:Add("g_gameRules", function(self, playerId, pos, rot, teamId)
				if (CLIENT_DISABLED) then
					assert(false,"still calling ATOM functions");
				end;
				
				ATOMClient:OnRevive(playerId, pos, rot, teamId);
			end, "OnRevive", "Client");
			
			---------------------------------------------------------
			-- Local Actor
			
			self.Patcher:Add("g_localActor", function(self, x)
				return CryAction.GetWaterInfo(self:GetPos()) > self:GetPos().z;
			end, "Underwater");
			
			self.Patcher:Add("g_localActor", function(self, action, activation, value)
			
				if (g_gameRules and g_gameRules.Client.OnActorAction) then 
					if (not g_gameRules.Client.OnActorAction(g_gameRules, self, action, activation, value)) then
						return;
					end;
				end;
				
				if (action == "use" or action == "xi_use") then
					self:UseEntity(self.OnUseEntityId, self.OnUseSlot, activation == "press");
				end;
				
				if (CLIENT_DISABLED) then
					assert(false, "still calling ATOM functions!");
				end;
				
				ATOMClient:OnAction(action, activation, value);
			end, "OnAction");
			
			self.Patcher:Add("g_localActor", function(self, frameTime) -- findme: update
			
				local stats = self.actorStats;		
				if (self.actor:GetSpectatorMode() ~= 0) then
					self:DrawSlot(0, 0);
				else
					local hide = (stats.firstPersonBody or 0) > 0;
					if (stats.thirdPerson or stats.isOnLadder) then
						hide = false;
					end
					local customModel = ((self.CM and self.CM > 0) or self.thisModel) and hide;
					self:DrawSlot(0, (customModel and 0 or 1))
					self:HideAllAttachments(0, hide, false)
					
				end

				if (not CLIENT_DISABLED) then
					ATOMClient:OnUpdate(System.GetFrameTime());
				else
					assert(false, "still calling ATOM functions!!");
				end;
			end, "UpdateDraw");
			
			self.Patcher:Add("g_localActor", function(self, tSeat)
				local V = self:GetVehicle();
				if (V) then
					local seat = (tSeat or self:GetUsedSeat());
					local wc = seat.seat:GetWeaponCount();
					return wc;
				end;
				return;
			end, "GetSeatWeaponCount");
			
			self.Patcher:Add("g_localActor", function(self)
				local vehicleId = self.actor:GetLinkedVehicleId();
				if (vehicleId) then
					return System.GetEntity(vehicleId);
				end;
				return;
			end, "GetVehicle");
			
			self.Patcher:Add("g_localActor", function(self)
				local V = self:GetVehicle();
				if (V) then
					local S;
					for i, v in pairs(V.Seats) do
						if (v:GetPassengerId() == self.id) then
							return v;
						end;
					end;
				end;
				return nil;
			end, "GetUsedSeat");
			
			---------------------------------------------------------
			-- Basic Actor
			
			self.Patcher:Add("BasicActor", function(self)
			
				if (not POWER_STRUGGLE) then
					return 0
				end
			
				local alive = self.actor:GetHealth() > 0
				if (alive) then
					return "Talk"
				end
				return "Loot"
				
			end, "GetUsableMessage");
			
			-------------------------
			
			self.Patcher:Add("BasicActor", function(self, user)
				if (not POWER_STRUGGLE) then
					return 0
				end
				local alive = self.actor:GetHealth() > 0
				if (alive) then
					self.Looted = nil
					return (g_gameRules.game:GetTeam(self.id) == g_gameRules.game:GetTeam(user.id) and 1 or 0)
				end
				
				local prestige = g_gameRules:GetPlayerPP(self.id)
				local loot = math.floor((prestige * 0.1) + 0.5)
				
				if (self.Looted) then --and loot > 25) then
					return 0
				end
				return 1
			end, "IsUsable");
			
			-------------------------
			
			self.Patcher:Add("BasicActor", function(self)
				
				local alive = self.actor:GetHealth() > 0
				if (not alive) then
					self.Looted = true
				end
				ATOMClient:ToServer(eTS_Report, "TALKTO", self.actor:GetChannel());
			end, "OnUsed");
			
			-------------------------
			
			self.Patcher:Add("BasicActor", null_function, "ApplyDeathImpulse");
			self.Patcher:Add("BasicActor", null_function, "DoPainSounds");
			
			-------------------------
			
			-- FIXME: Reenable!!
			--[[
			self.Patcher:Add("BasicActor", function(self, isClient)

				self:KillTimer(UNRAGDOLL_TIMER);
				
				local custom = ((not self.CM or self.CM == 0) and self.thisModel);
				local PropInstance = self.PropertiesInstance;
				local model = custom or self.Properties.fileModel;
				Msg(1, "original model=%s",self.Properties.fileModel);
				Msg(1, "new model=%s",model);
				
				-- take care of fp3p
				if (self.Properties.clientFileModel and isClient and not custom) then
					model =  self.Properties.clientFileModel;
					Msg(1, "client model=%s",model);
				end
				
				local nModelVariations = self.Properties.nModelVariations;
				if (nModelVariations and nModelVariations > 0 and PropInstance and PropInstance.nVariation) then
				  local nModelIndex = PropInstance.nVariation;
				  if (nModelIndex < 1) then
					nModelIndex = 1;
				  end
				  if (nModelIndex > nModelVariations) then
					nModelIndex = nModelVariations;
				  end
					local sVariation = string.format('%.2d',nModelIndex);
					model = string.gsub(model, "_%d%d", "_"..sVariation);
					--System.Log( "ActorModel = "..model );
				end
				
				if (self.currModel ~= model) then
					self.currModel = model;	

					self:LoadCharacter(0, model);

					--set all animation events
					self:InitAnimationEvents();

					--set IK limbs
					--!TODO: add new ik limbs 
					self:InitIKLimbs();
					
					self:ForceCharacterUpdate(0, false); -- whots dis
					if (self.Properties.objFrozenModel and self.Properties.objFrozenModel~="") then
						self:LoadObject(1, self.Properties.objFrozenModel);
						self:DrawSlot(1, 0);
					end
					
					self:CreateBoneAttachment(0, "weapon_bone", "right_item_attachment");	
					self:CreateBoneAttachment(0, "alt_weapon_bone01", "left_item_attachment");
				
					--laser bone (need it for updating character correctly when out of camera view)
					self:CreateBoneAttachment(0, "weapon_bone", "laser_attachment");	
					
					if (self.CreateAttachments) then
						self:CreateAttachments();
					end
				end	

				if (self.currItemModel ~= self.Properties.fpItemHandsModel) then	
					self:LoadCharacter(3, self.Properties.fpItemHandsModel);
					self:DrawSlot(3, 0);
					self:LoadCharacter(4, self.Properties.fpItemHandsModel); -- second instance for dual wielding
					self:DrawSlot(4, 0);
					
					self.currItemModel = self.Properties.fpItemHandsModel;
				end	
			end, "SetActorModel");
			--]]
			
			---------------------------------------------------------
			-- Player
			
			self.Patcher:Add("Player", function(self, hit)
				local blood = tonumber(System.GetCVar("g_blood"));
				if (blood == 0) then
					return;
				end
				self:DestroyAttachment(0, "wound");
				self:CreateBoneAttachment(0, "Bip01", "wound");
				
				local effect = self.bloodFlowEffect;
				local pos = hit.pos
				local level, normal, flow = CryAction.GetWaterInfo(pos);
				if (level and level >= pos.z) then
					effect = self.bloodFlowEffectWater;
				end
				
				self:SetAttachmentEffect(0, "wound", effect, pos, hit.dir, 1, 0);
			end, "Bleed");
			
			---------------------------------------------------------
			-- Player
			
			self.Patcher:Add("Player", function(self, hit)
				local blood = tonumber(System.GetCVar("g_blood"));
				if (blood == 0) then
					return;
				end
				
				local hp = self.actor:GetHealth()
				if (hp >= 1) then
					if (self.BLOODPOOL_TIMER) then Script.KillTimer(self.BLOODPOOL_TIMER) end
					return
				end

				-- if we are still moving, let's not do a bloodpool, yet
				self:GetVelocity(g_Vectors.temp_v1);
				
				if (LengthSqVector(g_Vectors.temp_v1) > 0.2) then
					if (self.BLOODPOOL_TIMER) then Script.KillTimer(self.BLOODPOOL_TIMER) end
					self.BLOODPOOL_TIMER = Script.SetTimerForFunction(300, "Player.BloodPool", self, hit)
					return
				end
				
				local dist = 1;
				local pos = self:GetBonePos("Bip01 Pelvis", g_Vectors.temp_v1);	
				if (pos == nil) then
					Log("Bip01 Pelvis not found in model " .. self.currModel);
					return
				end
				pos.z = pos.z + 1;
				
				local dir = vecScale(g_Vectors.down, 2.5)
				local hits = Physics.RayWorldIntersection(pos, dir, 2.5, ent_terrain + ent_static, self.id, nil, g_HitTable);
				
				local splat = g_HitTable[1];
				if (hits > 0 and splat) then
				
					local n = table.getn(self.bloodSplatGround)
					local i = math.random(1, n);
					local s = 0.8 * splat.dist --calcDist(pos, splat.pos)
					Msg(0, "ok for pool")
					Particle.CreateMatDecal(splat.pos, splat.normal, s, 300, self.bloodSplatGround[i], math.random() * 360, vecNormalize(dir), splat.entity and splat.entity.id, splat.renderNode, 6, true);
				end
			end, "BloodPool");
			
			---------------------------------------------------------
			-- Player
			
			self.Patcher:Add("Player", function(self, hit)
				local blood = tonumber(System.GetCVar("g_blood"));
				if (blood == 0) then
					return;
				end
				
				if (hit.material) then
					local dist = 2.5;
					local dir = vecScale(hit.dir, dist);
					local hits = Physics.RayWorldIntersection(hit.pos, dir, 1, ent_all, hit.targetId, nil, g_HitTable);
					
					local splat = g_HitTable[1];
					if (hits > 0 and splat and ((splat.dist or 0) > 0.25)) then
						local n = table.getn(self.bloodSplatWall);
						local i = math.random(1, n);
						local s = 0.25 + (splat.dist / dist) * 0.35;
						
						Particle.CreateMatDecal(splat.pos, splat.normal, s, 300, self.bloodSplatWall[i], math.random()*360, vecNormalize(hit.dir), splat.entity and splat.entity.id, splat.renderNode);
					end
				end
			end, "BloodSplat");
			
			---------------------------------------------------------
			-- Player
			
			self.Patcher:Add("Player", function(self, model, arms, frozen, fp3p)
				if (model) then
					if (fp3p) then
						self.Properties.clientFileModel = fp3p;
					end
					self.Properties.fileModel = model;

					if (arms) then
						self.Properties.fpItemHandsModel = arms;
					end
					if (frozen) then
						self.Properties.objFrozenModel = frozen;
					end
				end
			end, "SetModel");
			
			-------------------------
			
			self.Patcher:Add("Player", function(self)
				self.GetUsableMessage = BasicActor.GetUsableMessage;
				self.IsUsable = BasicActor.IsUsable;
				self.OnUsed = BasicActor.OnUsed;
			end, "ChangeUse", nil, true);
			
			
			-------------------------
			
			
			-- BUG: THIS IS CONNECTED TO CRASH BUG !!!
			self.Patcher:Add("Player", function(self, hit)
				ATOMClient:OnHit(self, hit);
			end, "OnHit", "Client");
			
			
			-------------------------
			
			self.Patcher:Add("Player", null_function, "ApplyDeathImpulse");
			self.Patcher:Add("Player", null_function, "DoPainSounds");
			
			--self.Patcher:Add("Player", Player.ChangeUse, "ChangeUse", nil, true);
			--self.Patcher:Add("Player", Player.SetModel, "SetModel");
			
			self.Patcher:Add("Player", BasicActor.SetActorModel, "SetActorModel");
			
			---------------------------------------------------------
			-- Game Rules
			
			---------------------------------------------------------
			-- Game Rules
			
			---------------------------------------------------------
			-- Game Rules
		
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AASearchLasers = {
			cfg = {
				rules = "PowerStruggle",
				enabled = true,
			},
			---------------------------------------------------------
			-- Constructor
			Init = function(self)
			
				self.RESET = true;
				if (self.cfg.enabled and g_gameRules.class == self.cfg.rules) then
					self:EnableAASearchLaser("AutoTurret",   true);
					self:EnableAASearchLaser("AutoTurretAA", true);
				end;
				
			end,
			---------------------------------------------------------
			-- Enabler
			EnableAASearchLaser = function(self, class, enable)
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					self:SpawnSearchLaser(v, enable);
				end
			end,
			---------------------------------------------------------
			-- PreUpdater
			PreUpdateAASearchLaser = function(self, class)
				if (not self.cfg.enabled or g_gameRules.class ~= self.cfg.rules) then
					return;
				end;
				
				self:PostUpdateAASearchLaser("AutoTurret");
				self:PostUpdateAASearchLaser("AutoTurretAA");
			end,
			---------------------------------------------------------
			-- PostUpdater
			PostUpdateAASearchLaser = function(self, class)
				-- update
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					if (v.item:IsDestroyed()) then
						if (v.SearchLaser and not v.HadSearchLaser) then
							self:SpawnSearchLaser(v, false); -- remove from destroyed turrets!
							v.HadSearchLaser = true;
						end;
					else
						if (v.HadSearchLaser) then
							self:SpawnSearchLaser(v, true); -- add (!!!)LASER(!!!) back if it already had one!!
							v.HadSearchLaser = false;
						end;
						if (v.SearchLaser) then
							if (v.SearchLaser:GetScale() ~= SEARCHLASER_SCALE) then
								v.SearchLaser:SetScale(SEARCHLASER_SCALE); -- real time updating scale! how cool is that!
							end;
							v.SearchLaser:SetAngles(v:GetSlotAngles(1)); -- slot angles 1 = gun turret direction
						end;
					end;
				end
			end,
			---------------------------------------------------------
			-- Spawner
			SpawnSearchLaser = function(self, entity, enable)	
				if (enable) then
					self:LoadAALaser(entity);
				else
					self:UnloadLaser(entity, entity.SearchLaser);
				end
			end,
			---------------------------------------------------------
			-- Unloader
			UnloadLaser = function(self, entity, laser)
				if (laser) then
					--Msg(0, "del %s", laser:GetName())
					System.RemoveEntity(laser.id);
					entity.SearchLaser = nil;
				end;
			end,
			---------------------------------------------------------
			-- Loader
			LoadAALaser = function(self, entity)
				
				-- no double spawning (!)LASERS(!)
				if (entity.SearchLaser and System.GetEntity(entity.SearchLaser.id)) then
					if (self.RESET) then
						System.RemoveEntity(entity.SearchLaser.id);
					else
						return;
					end;
				end;
				
				-- note: this spawns a (!)LASER(!)
				local laser = System.SpawnEntity({
					class = "BasicEntity", -- maybe not the best entity for this?
					name = entity:GetName() .. "_searchlaser", -- prolly not unique, but who cares
					scale = 2,
					properties = {
						object_Model = "objects/effects/beam_laser_02.cgf", -- better than the other one
					},
					fMass = -1, -- no mass
				});
				laser:SetScale(SEARCHLASER_SCALE); -- scale (!)LASER(!) before attaching!
				
				entity.SearchLaser = laser;
				entity:AttachChild(laser.id, 8);
				
				laser:SetLocalPos({ x = 0, y = 0, z = 1.8 }); -- set (!)LASER(!) position after attaching!
			end
		};
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Patcher = {
			---------------------------------------------------------
			-- Scripts 
			_scripts = {
				['AdvancedDoor'] = "Scripts/Entities/Doors/AdvancedDoor.lua",
				['AIAlertness'] = "Scripts/Entities/AI/AIAlertness.lua",
				['AIAnchor'] = "Scripts/Entities/AI/AIAnchor.lua",
				['AICheckInBox'] = "Scripts/Entities/Triggers/AICheckInBox.lua",
				['AIReinforcementSpot'] = "Scripts/Entities/AI/AIReinforcementSpot.lua",
				['AISpawner'] = "Scripts/Entities/AI/AISpawner.lua",
				['AlienEnergyPoint'] = "Scripts/Entities/Multiplayer/AlienEnergyPoint.lua",
				['AlienPlayer'] = "Scripts/Entities/Actor/AlienPlayer.lua",
				['Player'] = "Scripts/Entities/Actor/Player.lua",
				['BasicActor'] = "Scripts/Entities/Actor/BasicActor.lua",
				['AmbientVolume'] = "Scripts/Entities/Sound/AmbientVolume.lua",
				['AnimDoor'] = "Scripts/Entities/Doors/AnimDoor.lua",
				['AnimObject'] = "Scripts/Entities/Physics/AnimObject.lua",
				['AreaBezierVolume'] = "Scripts/Entities/Physics/AreaBezierVolume.lua",
				['AreaTrigger'] = "Scripts/Entities/Triggers/AreaTrigger.lua",
				['BasicEntity'] = "Scripts/Entities/Physics/BasicEntity.lua",
				['Birds'] = "Scripts/Entities/Boids/Birds.lua",
				['Boid'] = "Scripts/Entities/Boids/Boid.lua",
				['BreakableObject'] = "Scripts/Entities/Physics/BreakableObject.lua",
				['Bugs'] = "Scripts/Entities/Boids/Bugs.lua",
				['BuyZone'] = "Scripts/Entities/Multiplayer/BuyZone.lua",
				['CameraShake'] = "Scripts/Entities/Others/CameraShake.lua",
				['CameraSource'] = "Scripts/Entities/Others/CameraSource.lua",
				['CameraTarget'] = "Scripts/Entities/Others/CameraTarget.lua",
				['CharacterAttachHelper'] = "Scripts/Entities/Others/CharacterAttachHelper.lua",
				['Chickens'] = "Scripts/Entities/Boids/Chickens.lua",
				['CinematicTrigger'] = "Scripts/Entities/Triggers/CinematicTrigger.lua",
				['CloneFactory'] = "Scripts/Entities/Others/CloneFactory.lua",
				['Cloth'] = "Scripts/Entities/Physics/Cloth.lua",
				['Cloud'] = "Scripts/Entities/Render/Cloud.lua",
				['Comment'] = "Scripts/Entities/Others/Comment.lua",
				['Constraint'] = "Scripts/Entities/Physics/Constraint.lua",
				['Crabs'] = "Scripts/Entities/Boids/Crabs.lua",
				['DeadBody'] = "Scripts/Entities/Physics/DeadBody.lua",
				['DecalPlacer'] = "Scripts/Entities/Others/DecalPlacer.lua",
				['DelayTrigger'] = "Scripts/Entities/Triggers/DelayTrigger.lua",
				['DestroyableObject'] = "Scripts/Entities/Physics/DestroyableObject.lua",
				['Dialog'] = "Scripts/Entities/Sound/Dialog.lua",
				['Door'] = "Scripts/Entities/Doors/Door.lua",
				['Elevator'] = "Scripts/Entities/Elevators/Elevator.lua",
				['ElevatorSwitch'] = "Scripts/Entities/Elevators/ElevatorSwitch.lua",
				['Explosion'] = "Scripts/Entities/Physics/Explosion.lua",
				['ExplosiveObject'] = "Scripts/Entities/Physics/ExplosiveObject.lua",
				['Factory'] = "Scripts/Entities/Multiplayer/Factory.lua",
				['Fan'] = "Scripts/Entities/Others/Fan.lua",
				['Fish'] = "Scripts/Entities/Boids/Fish.lua",
				['Flag'] = "Scripts/Entities/Multiplayer/Flag.lua",
				['Flash'] = "Scripts/Entities/Render/Flash.lua",
				['Fog'] = "Scripts/Entities/Render/Fog.lua",
				['FogVolume'] = "Scripts/Entities/Render/FogVolume.lua",
				['ForbiddenArea'] = "Scripts/Entities/Multiplayer/ForbiddenArea.lua",
				['Frogs'] = "Scripts/Entities/Boids/Frogs.lua",
				['GravityBox'] = "Scripts/Entities/Physics/GravityBox.lua",
				['GravitySphere'] = "Scripts/Entities/Physics/GravitySphere.lua",
				['GravityStream'] = "Scripts/Entities/Physics/GravityStream.lua",
				['GravityStreamCap'] = "Scripts/Entities/Physics/GravityStreamCap.lua",
				['GravityValve'] = "Scripts/Entities/Physics/GravityValve.lua",
				['GUI'] = "Scripts/Entities/Others/GUI.lua",
				['Hazard'] = "Scripts/Entities/Others/Hazard.lua",
				['HQ'] = "Scripts/Entities/Multiplayer/HQ.lua",
				['IndirectLight'] = "Scripts/Entities/Lights/IndirectLight.lua",
				['InteractiveEntity'] = "Scripts/Entities/Others/InteractiveEntity.lua",
				['Ladder'] = "Scripts/Entities/Ladders/Ladder.lua",
				['Light'] = "Scripts/Entities/Lights/Light.lua",
				['Lightning'] = "Scripts/Entities/Render/Lightning.lua",
				['Mine'] = "Scripts/Entities/Others/Mine.lua",
				['MissionHint'] = "Scripts/Entities/Sound/MissionHint.lua",
				['MissionObjective'] = "Scripts/Entities/Others/MissionObjective.lua",
				['MultipleTrigger'] = "Scripts/Entities/Triggers/MultipleTrigger.lua",
				['MusicEndTheme'] = "Scripts/Entities/Sound/MusicEndTheme.lua",
				['MusicLogicTrigger'] = "Scripts/Entities/Sound/MusicLogicTrigger.lua",
				['MusicMoodSelector'] = "Scripts/Entities/Sound/MusicMoodSelector.lua",
				['MusicPlayPattern'] = "Scripts/Entities/Sound/MusicPlayPattern.lua",
				['MusicStinger'] = "Scripts/Entities/Sound/MusicStinger.lua",
				['MusicThemeSelector'] = "Scripts/Entities/Sound/MusicThemeSelector.lua",
				['Objective'] = "Scripts/Entities/Multiplayer/Objective.lua",
				['ParticleEffect'] = "Scripts/Entities/Particle/ParticleEffect.lua",
				['Perimeter'] = "Scripts/Entities/Multiplayer/Perimeter.lua",
				['PlayerModelChanger'] = "Scripts/Entities/Others/PlayerModelChanger.lua",
				['Plover'] = "Scripts/Entities/Boids/Plover.lua",
				['PrecacheCamera'] = "Scripts/Entities/Others/PrecacheCamera.lua",
				['PressurizedObject'] = "Scripts/Entities/Physics/PressurizedObject.lua",
				['ProximityTrigger'] = "Scripts/Entities/Triggers/ProximityTrigger.lua",
				['RaisingWater'] = "Scripts/Entities/Others/RaisingWater.lua",
				['RandomSoundVolume'] = "Scripts/Entities/Sound/RandomSoundVolume.lua",
				['ReverbVolume'] = "Scripts/Entities/Sound/ReverbVolume.lua",
				['RigidBody'] = "Scripts/Entities/Others/RigidBody.lua",
				['RigidBodyEx'] = "Scripts/Entities/Physics/RigidBodyEx.lua",
				['Rope'] = "Scripts/Entities/Physics/Rope.lua",
				['ShootingTarget'] = "Scripts/Entities/Others/ShootingTarget.lua",
				['SimpleIndirectLight'] = "Scripts/Entities/Lights/SimpleIndirectLight.lua",
				['SimpleLight'] = "Scripts/Entities/Lights/SimpleLight.lua",
				['SmartObject'] = "Scripts/Entities/AI/SmartObject.lua",
				['SmartObjectCondition'] = "Scripts/Entities/AI/SmartObjectCondition.lua",
				['SoundEventSpot'] = "Scripts/Entities/Sound/SoundEventSpot.lua",
				['SoundMoodVolume'] = "Scripts/Entities/Sound/SoundMoodVolume.lua",
				['SoundSpot'] = "Scripts/Entities/Sound/SoundSpot.lua",
				['SoundSupressor'] = "Scripts/Entities/Others/SoundSupressor.lua",
				['SpawnAlien'] = "Scripts/Entities/AISpawners/SpawnAlien.lua",
				['SpawnCivilian'] = "Scripts/Entities/AISpawners/SpawnCivilian.lua",
				['SpawnCoordinator'] = "Scripts/Entities/AISpawners/SpawnCoordinator.lua",
				['SpawnGroup'] = "Scripts/Entities/Multiplayer/SpawnGroup.lua",
				['SpawnGrunt'] = "Scripts/Entities/AISpawners/SpawnGrunt.lua",
				['SpawnHunter'] = "Scripts/Entities/AISpawners/SpawnHunter.lua",
				['SpawnObserver'] = "Scripts/Entities/AISpawners/SpawnObserver.lua",
				['SpawnPoint'] = "Scripts/Entities/Others/SpawnPoint.lua",
				['SpawnScout'] = "Scripts/Entities/AISpawners/SpawnScout.lua",
				['SpawnTrooper'] = "Scripts/Entities/AISpawners/SpawnTrooper.lua",
				['SpectatorPoint'] = "Scripts/Entities/Multiplayer/SpectatorPoint.lua",
				['Switch'] = "Scripts/Entities/Others/Switch.lua",
				['TagPoint'] = "Scripts/Entities/AI/TagPoint.lua",
				['TeamRandomSoundVolume'] = "Scripts/Entities/Multiplayer/TeamRandomSoundVolume.lua",
				['TeamSoundSpot'] = "Scripts/Entities/Multiplayer/TeamSoundSpot.lua",
				['Turtles'] = "Scripts/Entities/Boids/Turtles.lua",
				['ViewDist'] = "Scripts/Entities/Render/ViewDist.lua",
				['VolumeObject'] = "Scripts/Entities/Render/VolumeObject.lua",
				['Warrior'] = "Scripts/Entities/AI/Aliens/Warrior.lua",
				['WaterKillEvent'] = "Scripts/Entities/Others/WaterKillEvent.lua",
				['Wind'] = "Scripts/Entities/Others/Wind.lua",
				['WindArea'] = "Scripts/Entities/Physics/WindArea.lua",
				['VehicleBase'] = "Scripts/Entities/Vehicles/VehicleBase.lua",
				['g_localActor'] = "lol",
				['g_gameRules'] = "lol",
				['VehicleBase'] = "lol",
				['AutoTurret'] = "lol",
				['AutoTurretAA'] = "lol"
			},
			---------------------------------------------------------
			-- CFG
			toHook = {},
			toRep = {},
			_patched = p_data or {},
			---------------------------------------------------------
			-- Check Entity
			CheckEntity = function(self, entity)
				local script = self:GetScript(entity);
				if (not script) then
					return false;
				end;
				if (not _G[entity] or type(_G[entity]) ~= "table") then
				--	ATOM:DebugFacTeams("BEFORE ::: reloaded"..script)
					Msg(1, "reloading entity script %s", entity);
					Script.ReloadScript(script);
				--	ATOM:DebugFacTeams("AFTER ::: reloaded"..script)
				end;
				if (not _G[entity]) then
					System.LogAlways(string.format("[ScriptBackup] Failed to load script for entity %s (= %s)", entity, script));
					return false;
				end;
				Msg(1, "loaded script for entity %s", entity);
				return true;
			end,
			---------------------------------------------------------
			-- Get Script
			GetScript = function(self, x)
				return self._scripts[x];
			end,
			---------------------------------------------------------
			-- Add
			Add = function(self, e, f, p, m, n, onlyGlobal, entName)
				--Msg(0, "added for %s", e)
				self.toHook[ #(self.toHook) + 1 ] = { e, f, p, m, n, onlyGlobal, entName };
			end,
			---------------------------------------------------------
			-- Add
			AddNew = function(self, props)
				--Msg(0, "added for %s", e)
				self.toHook[ #(self.toHook) + 1 ] = { 
					props.entity, 
					props.func, 
					props.funcName, 
					props.funcTabel, 
					props.funcCall, 
					props.onlyGlobal,
					props.entityRealName
				};
			end,
			---------------------------------------------------------
			-- Add
			Replace = function(self, a, b)
				--Msg(0, "added for %s", e)
				self.toRep[ #(self.toRep) + 1 ] = { a, b };
			end,
			---------------------------------------------------------
			-- FappAdd
			FAdd = function(self, e, f, p, m, n, onlyGlobal)
				--Msg(0, "added for %s", e)
				local func = {
					e, f, p, m, n, onlyGlobal
				};
				local ent 	= func[1];
				local f		= func[2];
				local t		= func[3];
				local p		= func[4];
				local doCall = func[5];
				local onlyGlobal = func[6];
				local entName = func[7]
					
				local ok = true;
					
				local is_object = not (type(f) == "function");
				--Msg(0, "%s IS_OBJECT = %s (ITS = %s)", ent, (is_object and "YES" or "NO :(("), type(f))
				if (not self:CheckEntity(ent)) then
					Msg(0, "Attempt to patch function of unexistant entity %s", ent);
					ok = false;
				end;

				if (type(_G[ent]) ~= "table") then
					Msg(0, "Attempt to patch a non entity %s (%s)", ent, type(_G[ent]));
					ok = false;
				end;
					
				if (ok) then
					
					self:DoHook(ent, f, t, p, doCall, onlyGlobal, is_object, ok, entName);
				end;
				--self.toHook[ #(self.toHook) + 1 ] = { e, f, p, m, n, onlyGlobal };
			end,
			---------------------------------------------------------
			-- Log
			LogAlways = function(msg)
				if (System.GetCVar("log_verbosity") >= 2) then
					System.LogAlways(msg);
				end;
			end,
			---------------------------------------------------------
			-- Destructor
			Shutdown = function(self)
				local _f, _o = 0, 0;
				for ent, patched in pairs(self._patched) do
					local s = self:GetScript(i);
					for obj, val in pairs(patched) do
						--Msg(0, "%s IS_OBJECT = %s", ent, tostring(val.IS_OBJECT ))
						--Msg(0, "")
						--Msg(0, "%s", tostring(patched.IS_OBJECT))
						if (type(val[1]) == "function" or val.IS_OBJECT) then
							if (val.IS_OBJECT) then
								_o = _o + 1;
							else
								_f = _f + 1;
							end;
							self.LogAlways(string.format("[ScriptBackup] %s _G[%s][%s] was restored (= %s)", (val.IS_OBJECT and "Object" or "Function"), ent, val[2], tostring(val[1])));
							_G[ent][val[2]] = val[1];
						else
							for _obj, _val in pairs(val) do
								if (val.IS_OBJECT) then
									_o = _o + 1;
								else
									_f = _f + 1;
								end;
								self.LogAlways(string.format("[ScriptBackup] %s _G[%s][%s][%s] was restored (= %s)", (_val.IS_OBJECT and "Object" or "Function"), ent, obj, _val[2], tostring(_val[1])));
								_G[ent][obj][_val[2]] = _val[1];
							end;
						end;
					end;
					
					if (s) then
						-- Reload script to restore default stuff??
						Script.UnloadScript(s);
						Script.ReloadScript(s);
					end;
					
				end;
				
				System.LogAlways(string.format("[ScriptBackup] Restored %d functions and %d objects to their default value", _f, _o));
				
				self._patched = {};
				self.toHook = {};
			end,
			---------------------------------------------------------
			-- Test function
			Test = function(self)
				 -- dont call during GP (!!!)
				self._patched = {}
				self.toHook = {}
				self:Add(
					"BasicEntity", 
					function(self, playerId, class, props)
						self.bRigidBodyActive = 1;
						self:SetFromProperties();
						Msg(0, "!! IT WORKED !!");
					end, 
					"OnSpawn"
				)
				self:Add(
					"BasicEntity", 
					function(self, playerId, class, props)
						self.bRigidBodyActive = 1;
						self:SetFromProperties();
						Msg(0, "!! IT WORKED !!");
					end, 
					"OnSpawn", 
					"TestTable"
				)
				self:Init();
			end,
			---------------------------------------------------------
			-- Hook a function or object
			DoHook = function(self, ent, f, t, p, doCall, onlyGlobal, is_object, ok, entName)
				--Msg(0, tostring(f))
				Msg(0, "entName = %s", entName or "LOL, EMPTY!!")
				local classEnts = System.GetEntitiesByClass(ent) or {};
				if (entName and (not classEnts or #classEnts < 1)) then
					for i, v in pairs(System.GetEntities()) do
						if (v[entName] ~= nil) then
							classEnts[#classEnts+1] = v
							Msg(0, "added " .. v:GetName())
						end
					end
				end

				if (t) then
					self._patched[ent] = self._patched[ent] or {};
							
					if (p) then
						_G[ent][p] = _G[ent][p] or {};
						self._patched[ent][p] = self._patched[ent][p] or {};
								
						if (_G[ent][p][t]) then
							if (not self._patched[ent][p][t]) then
								self._patched[ent][p][t] = { _G[ent][p][t], t };
								self._patched[ent][p][t].IS_OBJECT = is_object;
								self.LogAlways(string.format("[ScriptBackup] Copy of %s_G[%s][%s][%s] was saved (= %s)", (is_object and"OBJECT "or""),ent, p, t, tostring(_G[ent][p][t])));
								--Msg(0, tostring(is_object))
							else
								self.LogAlways(string.format("[ScriptBackup] Copy of _G[%s][%s][%s] was already saved (= %s)", ent, p, t, tostring(self._patched[ent][p][t][1])));
							end;
						else
							self.LogAlways(string.format("[ScriptBackup] No backup for _G[%s][%s][%s] was made", ent, p, t));
								
						end;
						_F = f;
						_G[ent][p][t] = f;
						loadstring(ent .. [[.]] .. p .. [[.]] .. t .. [[=_F]])();
						for iv, vv in pairs(classEnts or {}) do
							if (not onlyGlobal) then
								vv[p][t] = f;
							end;
							if (doCall and type(f) == "function") then
								--self.Log(string.format("[FileBackup] Calling function %s:%s(%s) on %s", p, t, vv:GetName(), vv.class));
								f(vv);
							--	vv:OnPropertyChange();
							end;
						end;
					else
						if (_G[ent][t]) then
							if (not self._patched[ent][t]) then
								self.LogAlways(string.format("[ScriptBackup] Copy %sof _G[%s][%s] was saved (= %s)", (is_object and"OBJECT "or""),ent, t, tostring(_G[ent][t])));
								self._patched[ent][t] = { _G[ent][t], t  };
								self._patched[ent][t].IS_OBJECT = is_object;
								--Msg(0, tostring(is_object))
							else
								self.LogAlways(string.format("[ScriptBackup] Copy of _G[%s][%s] was already saved (= %s)", ent, t, tostring(self._patched[ent][t][1])));
							end;
						else
							self.LogAlways(string.format("[ScriptBackup] No backup for _G[%s][%s] was made", ent, t));
						end;
						_G[ent][t] = f;
						for iv, vv in pairs(classEnts or {}) do
							if (not onlyGlobal) then
								vv[t] = f;
							end;
							if (doCall) then
								--self.Log(string.format("[FileBackup] Calling function %s.%s(%s)", vv.class, t, vv:GetName()));
								f(vv);
							end;
						end;
					end;
				end;
			end,
			---------------------------------------------------------
			-- Constructor
			Init = function(self)
				--Msg(0, "Patcher init")
				-- save old functionality of the hookers
				for i, func in pairs(self.toHook) do
				--Msg(0, "hook >" .. tostring(i) .. " -> " .. tostring(func[1]))
				
					local ent 	= func[1];
					local f		= func[2];
					local t		= func[3];
					local p		= func[4];
					local doCall = func[5];
					local onlyGlobal = func[6];
					local entName = func[7];
					
					local ok = true;
					
					local is_object = not (type(f) == "function");
					--Msg(0, "%s IS_OBJECT = %s (ITS = %s)", ent, (is_object and "YES" or "NO :(("), type(f))
					if (not self:CheckEntity(ent)) then
						Msg(0, "Attempt to patch function of unexistant entity %s", ent);
						ok = false;
					end;

					if (type(_G[ent]) ~= "table") then
						Msg(0, "Attempt to patch a non entity %s (%s)", ent, type(_G[ent]));
						ok = false;
					end;
					
					if (ok) then
					
						self:DoHook(ent, f, t, p, doCall, onlyGlobal, is_object, ok, entName);
					--else
					--	if (p) then
					--		_G[ent][p] = f;
					--		for iv, vv in pairs(classEnts or {}) do
					--			vv[p] = f;
					--		end;
					--	else
					--		_G[ent] = f;
					--	end;
					end;
					
				end;
				
				for i, addr in pairs(self.toRep) do
					loadstring(addr[1] .. " = " .. addr[2])();
				end;
				
				Msg(1, "Hooked " .. #(self.toHook) .. " Entity Script-functions");
			end,
		};
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckCVars = function(self)
			local cvars = {
				--sys_physics_cpu = 1,
				e_particles_quality = 4,
				r_UseSoftParticles = 1,
				e_water_ocean_soft_particles = 1,
				e_particles_object_collisions = 1,	
				e_particles_max_emitter_draw_screen = 500000,
				r_glow = 1,		
				--e_particles_thread = 1
			};
			local set = System.SetCVar;
			
			for var, val in pairs(cvars) do
				set(var, tostring(val));
			end;
			
			Msg(1, "%d cvars changed.", #cvars);
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Vaporize = function(self, dataTable)
			-- some test to see if it actually vaporized the crap
			local crapBefore = collectgarbage("count");
			-- define by system log verbosity if we should log the Vaporization process
			local logVaporization = System.GetCVar("log_verbosity") >= 3;
			-- show that we started Vaporization
			if (logVaporization) then
				System.LogAlways(string.format("[Vaporization] Started with %0.5f-K-bytes...", crapBefore));
			end;
			-- delete that pack
			for i, v in pairs(dataTable) do
				if (logVaporization) then
					System.LogAlways(string.format("[Vaporization] Successfully destroyed %s!", (tostring(v) or "Fack")));
				end;
				-- remove global instance
				if (_G[v]) then
					_G[v] = nil;
				end;
				-- remove the item 
				if (type(v) ~= "string") then
					v = nil;
				elseif (string.len(tostring(v)) >= 1) then
					-- remove the item 
					loadstring(tostring(v) .. [[ = nil]])();
				end;
				-- remove the instance from the dataTable
				dataTable[i] = nil;
			end;
			-- Delete the table too, in case item is not string but the data itself
			dataTable = nil;
			-- force garbage collection to ensure everything is really gone forever
			collectgarbage("collect");
			-- some test to see if it actually vaporized the crap
			local crapAfter = collectgarbage("count");
			-- subtract the crap
			local crapRemoved = crapBefore - crapAfter;
			-- print the result
			if (logVaporization) then
				System.LogAlways(string.format("[Vaporization] %0.5f-K-bytes of crap was removed - that is %0.4f-Mega-bytes or %f-bytes", crapRemoved, crapRemoved / 1024, crapRemoved * 1024));
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CreateBindings = function()
			-- "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9",
			-- z and u for Chats
			-- "z", "u", "f1","f2","f3","f4","f5","f6","f7","f8","f9",
			--,"np_1","np_2","np_3","np_4","np_5","np_6","np_7","np_8","np_9","np_0",
			local keys = {"f3","w","a","s","d","shift","escape","space","enter"};
			System.ClearKeyState(); -- dOeS tHiS eVeN wOrK ?
			
			function OnKeyPressed(key)
				if (key == "space") then
					key=" ";
				end;
				Msg(1, "Key pressed: %s", key)
				ATOMClient:HandleKey(g_localActor, key);
			end;
			
			-- Possible nCX patch since both clients use different commands for bound keys.
			nCX = {
				OnInput = function(self, key)	
					Msg(1, "nCX patch was a fucking success!");
					OnKeyPressed(key);
				end,
				-- ... :(
				RequestNitro = function()
					Msg(1, "nCX patch was a fucking success!!");
					OnKeyPressed("f3");
				end,
			};
			
			local CKB = CPPAPI and CPPAPI.CreateKeyBind;
			
			local log = System.GetCVar("log_verbosity");
			local crymp = CKB or System.GetCVar("mp_walljump") ~= nil;
			if (crymp and not CKB) then
				System.SetCVar("log_verbosity", "-1"); -- No logging at all
			end;
			
			for i, v in pairs(keys) do
				--uncomment
				System.AddCCommand("cl_input", "OnKeyPressed(\%1)", "obsolete");--\%1
				
				-- Possible nCX patch since both clients use different commands for bound keys.
				System.AddCCommand("ncx_press", "OnKeyPressed(\%1)", "obsolete");--\%1
				if (CKB) then
					CKB(v, "cl_input " .. v);
				else
					System.ExecuteCommand("bind " .. v .. " cl_input " .. v); -- ??? 
				end;
			end;
			
			
			System.SetCVar("log_verbosity", tostring(log));
			
			Msg(1, "Key bindings created for %d keys!", #keys)
		end;
		
		
		---------------------------------------------------------
		-- VEHICLE
		---------------------------------------------------------
		
		
		ATOMClient.OnLeaveVehicleSeat = function(self, vehicle, seat, idPassenger, exiting)
			local hPassenger = System.GetEntity(idPassenger);
			if (not hPassenger) then
				return end
			
			-----------
			if (exiting) then
				hPassenger.ICMId = nil
				hPassenger.ICML = nil
			end
			
			-----------
			Msg(1, "id=%s,driver=%s,jet=%s,thruster=%s,power=%f/0", tostring(idPassenger == g_localActorId), tostring(seat.seat:IsDriver()), tostring(vehicle.IsJet), tostring(vehicle.ThrusterON), (vehicle.ThrusterPowerVisual or 0))
			if (idPassenger == g_localActorId and seat.seat:IsDriver() and vehicle.IsJet and vehicle.ThrusterON and (vehicle.ThrusterPower or 0)>0) then
				self:ToServer(eTS_Report, "MJS", vehicle.ThrusterPower) end
			
			-----------
			if (idPassenger == g_localActorId) then
				self.EXIT_VEHICLE_TIME = timerinit() end
		end;
		
		ATOMClient.OnEnterVehicleSeat = function(self, vehicle, seat, passengerId)
			--Msg(0, "worked")
			local passenger = System.GetEntity(passengerId);
			if (not passenger) then
				return;
			end
			if (not passenger.vehicleId) then
			end
			passenger.LAST_SEATID = seat.seatId;
			
				
			local player = System.GetEntity(passengerId);
			--Msg(0, "call ok (v=%s,id=%s,id2=%s)",tostring(vehicle),tostring(seatId),tostring(passengerId))
			if (seat.seat:IsDriver()) then
				--Msg(0, "seat ID ok")
				if (player and player.id == g_localActorId) then
					--Msg(0, "passenger ID ok")
					local supported = {
						["Civ_car1"] = true,
						["US_ltv"] = true,
						["Asian_ltv"] = true, -- does this even exist? or am I lost ?
					};
					if (vehicle.IsJet == true) then
						--Msg(0, "jet ok")
						if (vehicle.JetType == 2) then
							--Msg(0, "jet type ok")
							HUD.DisplayBigOverlayFlashMessage("Press [F3] To Start Bomb Drop!", 10, 130, 360, { 221/255, 107/255, 23/255 });
						end;
					else
						if (supported[vehicle.class]) then
							HUD.DisplayBigOverlayFlashMessage("Press [F3] To Enable Fire Tires!", 10, 130, 360, { 221/255, 107/255, 23/255 });
						end;
					end;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnRevive = function(self, playerId, pos, rot, teamId)
			
			local teamId = teamId;
			local player = System.GetEntity(playerId);
			
			
			
			if (player and teamId and teamId ~= 0) then
				local thisModel;
				local rank = g_gameRules.game:GetSynchedEntityValue(player.id, g_gameRules.RANK_KEY) or 1;
				local c = false;
				--Msg(0, "test==22")
				
				if (USE_RANK_MODELS and RANK_MODELS[rank] and RANK_MODELS[rank][teamId]) then
					--Msg(0, "Using rank models!");
					
					if (rank == player.lastRank and player.lastModel and teamId == player.lastTeam) then
						--Msg(0, "Found old model, NOT using new one for MAXIMUM IMMERSION !! :D");
						thisModel = player.lastModel;
					else--if () then
						thisModel = RANK_MODELS[rank][teamId][1];
						thisModel = type(thisModel)=="table" and thisModel[math.random(#thisModel)] or thisModel;
					end;
						Msg(1, "slected model=%s", thisModel)
					c = true;
					player.lastModel = thisModel;
					player.lastRank = rank;
					player.lastTeam = teamId;
					player.thisModel = thisModel;
					return;
				else
					player.thisModel = nil;
				end
				
				local teamName = g_gameRules.game:GetTeamName(teamId);
				local models = g_gameRules.teamModel[teamName];
				if (models and table.getn(models) > 0) then
					local model = models[1];
					
					player:SetModel(model[1], model[2], model[3],model[4]);
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.InitLibraries = function(self)
		
			------------
			LibLog = function(sMsg, ...)
				System.LogAlways(string.format("[ATOMLibraries]: %s", string.format(sMsg, ...)))
			end
		
			------------
			self:InitLuaUtils()
			self:InitTimer()
		end
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.InitLuaUtils = function(self)
			loadstring([[
			--=====================================================
			-- CopyRight (c) R 2022-2203
			--
			-- Random (sometimes) useful utils for lua
			--
			--=====================================================

			-------------------
			luautils = {
				version = "1.0",
				author = "shortcut0",
				description = "all kinds of utiliy functions that might come in handy"
			}

			---------------------------
			-- luautils.isFunction

			luautils.isFunction = function(hParam)
				return type(hParam) == "function"
			end

			---------------------------
			-- luautils.isString

			luautils.isString = function(hParam)
				return type(hParam) == "string"
			end

			---------------------------
			-- luautils.isNumber

			luautils.isNumber = function(hParam)
				return type(hParam) == "number"
			end

			---------------------------
			-- luautils.isBoolean

			luautils.isBoolean = function(hParam)
				return type(hParam) == "bool"
			end

			---------------------------
			-- luautils.isArray

			luautils.isArray = function(hParam)
				return type(hParam) == "table"
			end

			---------------------------
			-- luautils.isNull

			luautils.isNull = function(hParam)
				return type(hParam) == "nil"
			end

			---------------------------
			-- luautils.isDead

			luautils.isDead = function(hParam)
				return (isNumber(hParam) and hParam == 0xDEAD)
			end

			---------------------------
			-- luautils.isEntityId

			luautils.isEntityId = function(hParam)
				return type(hParam) == "userdata"
			end

			---------------------------
			-- luautils.fileexists

			luautils.fileexists = function(sPath)
				-------------
				local hFile = io.open(sPath, "r")
				if (not hFile) then
					return false end
				
				-------------
				hFile:close()
				
				-------------
				return true
			end

			---------------------------
			-- luautils.fileexists

			luautils.random = function(min, max, floor)
				-------------
				if (isArray(min)) then
					if (max and isFunction(max) and table.count(min) > 1) then
						for i, hVal in pairs(table.shuffle(min)) do
							if (max(hVal) == true) then
								return hVal
							end
						end
					else
						return min[math.random((max or table.count(min)))] end
				end
				
				-------------
				local iRandom
				if (max) then
					iRandom = math.random(min, max)
				else
					iRandom = math.random(0, min)
				end
				
				-------------
				if (floor) then
					iRandom = math.floor(iRandom)
				end
				
				-------------
				return iRandom
			end

			---------------------------
			-- luautils.checkNumber

			luautils.checkNumber = function(iNumber, iDefault)

				-------------
				if (not isNumber(iNumber)) then
					return iDefault end
				-------------
				return iNumber
			end

			---------------------------
			-- luautils.compNumber

			luautils.compNumber = function(iNumber, iGtr)

				-------------
				if (not isNumber(iNumber)) then
					return false end

				-------------
				if (not isNumber(iGtr)) then
					return false end
					
				-------------
				return (iNumber >= iGtr)
			end

			---------------------------
			-- luautils.checkVar

			luautils.checkVar = function(sVar, hDefault)

				-------------
				if (isNull(sVar)) then
					return hDefault end
					
				-------------
				return sVar
			end

			-------------------
			getrandom = luautils.random
			isNull = luautils.isNull
			isDead = luautils.isDead
			isArray = luautils.isArray
			isBoolean = luautils.isBoolean
			isBool = luautils.isBoolean
			isString = luautils.isString
			isNumber = luautils.isNumber
			isFunction = luautils.isFunction
			isEntityId = luautils.isEntityId
			fileexists = luautils.fileexists
			checkNumber = luautils.checkNumber
			checkVar = luautils.checkVar
			compNumber = luautils.compNumber

			-------------------
			LibLog("Lua Utils Library loaded")
		
			-------------------
			return luautils
			]])()
		end
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		ATOMClient.InitTimer = function(self)
			loadstring([[
			--=====================================================
			-- CopyRight (c) R 2022-2203
			--
			-- Random (sometimes) useful timer utils for lua
			--
			--=====================================================

			-------------------
			timer = {
				version = "1.0",
				author = "shortcut0",
				description = "all kinds of timer utility functions that might come in handy"
			}

			---------------------------
			-- luautils.init

			timer.init = function()
				return (os.clock())
			end

			---------------------------
			-- luautils.destroy

			timer.destroy = function(hTimer)
				hTimer = nil
				return nil
			end

			---------------------------
			-- timer.diff

			timer.diff = function(hTimer)
				return (os.clock() - hTimer)
			end

			---------------------------
			-- timer.check

			timer.expired = function(hTimer, iTime)
				if (not isNumber(hTimer)) then
					return true end
					
				if (not isNumber(iTime)) then
					return true end
				
				return (timer.diff(hTimer) >= iTime)
			end

			---------------------------
			-- timer.sleep

			timer.sleep = function(iMs)

				-----------
				if (not isNumber(iMs)) then
					return end

				-----------
				local iMs = (iMs / 1000)

				-----------
				local hSleepStart = timer.init()
				repeat
					-- sleep well <3
				until (timer.expired(hSleepStart, iMs))
			end

			---------------------------
			-- timer.sleep_call

			timer.sleep_call = function(iMs, fCall, ...)

				-----------
				if (not fCall) then
					return timer.sleep(iMs) end

				-----------
				if (not isNumber(iMs)) then
					return end

				-----------
				local iMs = (iMs / 1000)
				
				-----------
				local hSleepStart = timer.init()
				repeat
					-- sleep well <3
				until ((iMs ~= -1 and (timer.expired(hSleepStart, iMs))) or (fCall(...) == true))
			end


			-------------------
			timerdestroy = timer.destroy
			timerinit = timer.init
			timerdiff = timer.diff
			timerexpired = timer.expired
			sleep = timer.sleep
			sleepCall = timer.sleep_call

			-------------------
			LibLog("Timer Utils Library loaded")

			-------------------
			return timer
			]])()
		end
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.RegisterFunctions = function(self)
			-------------------------------
			-- Simple byte suffix function
			
			ByteSuffix = function(iBytes, iNullCount, bNoSuffix)

				local aSuffixes = { "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "HB", "BB" }
				local iIndex = 1
				while (iBytes > 1023 and iIndex <= 11) 
				do
					iBytes = iBytes / 1024
					iIndex = iIndex + 1
				end
				
				if (not iNullCount) then
					if (iIndex == 1) then iNullCount = 0 else
						iNullCount = 2
					end
				end
				
				local sBytes = string.format(string.format("%%0.%df%%s", iNullCount), iBytes, ((not bNoSuffix) and (" " .. aSuffixes[iIndex]) or ""))
				return sBytes
			end;
		
			-------------------------------
			-- Parallel table iterating
			table.zip_max = function(arrays)
				local m, _m = 0, 0;
				for i, v in pairs(arrays) do
					for _i, _v in pairs(v) do
						m = m + 1;
					end;
					if (m > _m) then
						_m = m;
					end;
					m = 0;
				end;
				return _m;
			end;
			
			-------------------------------
			table.zip_allnull = function(arr, index)
				local allNull = true;
				for i, v in pairs(arr) do
					allNull = allNull and v[index] == nil;
				end;
				return allNull
			end
			
			-------------------------------
			table.zip_sort = function(arrs)
				local new_arrays = {};
				while #arrs >= 1 do
					local m, _m = 0, table.zip_max(arrs);
					local tmax;
					for i, v in pairs(arrs) do
						for _i, _v in pairs(v) do
							m = m + 1;
						end;
						if (m >= _m) then
							table.insert(new_arrays, v);
							table.remove(arrs, i);
							_m = m;
						elseif (i == #arrs) then
							table.insert(new_arrays, v);
							table.remove(arrs, i);
						end;
						m = 0;
					end;
				end;
				return new_arrays
			end
			
			-------------------------------
			table.zip = function(...)
				local arrays, ans = table.zip_sort({...}), {}
				local index = 0;
				return function()
					index = index + 1
					for i,t in ipairs(arrays) do
						if (type(t) == 'function') then
							ans[i] = t();
						else
							ans[i] = t[index];
						end;
					end;
					if (table.zip_allnull(arrays, index)) then 
						return;
					end;
					return table.unpack(ans);
				end;
			end;
			
			-------------------------------
			math.smax = function(a, b)
				if (a > b) then
					return b;
				end
				return a;
			end
			
			-------------------------------
			function getLoadingBar(__cur, __max, c)
				local __max = __max or 100;
				local __mul = __max / 100;
				local __cur = math.floor(__cur * __mul);
				local __rem = __max - __cur;
				local __F 	= math.smax(math.floor(__cur), __max);
				local __R 	= math.floor(__rem);
				return c .. string.rep("|", __F) .. "$1" .. string.rep("|", __R);
			end;
			
			-------------------------------
			-- Msg(verb, message, format)
			Msg = function(v, msg, ...)
				if (v <= self.LogVerbosity) then
					local message = msg;
					if (...) then
						message = string.format(msg, ...);
					end;
					System.LogAlways("$9[$4ATOM$9] " .. tostring(message));
				end;
			end;
			
			-------------------------------
			getOwner = function(item)
				if (CRYMP_CLIENT) then
					-- fixed in new client
					return item.weapon:GetShooter();
				end;
				--this is BAD
				local all = System.GetEntitiesByClass("Player");
				for _, v in pairs(all) do
					if (v.actor:IsPlayer()) then
						for __, _v in pairs(v.inventory:GetInventoryTable() or {}) do
							if (_v == item.id) then
								return true;
							end;
						end;
					end;
				end;
				return false;
			end;
			
			-------------------------------
			HE = function(...)
				return self:HandleEvent(...);
			end;
			
			-------------------------------
			GP = function(channelId)
				if (type(channelId) == "number") then
					return g_gameRules.game:GetPlayerByChannelId(channelId);
				else
					return System.GetEntityByName(channelId);
				end;
			end;
			
			-------------------------------
			FI = function(p,f,t)
				if (p.id==g_localActorId) then
					if (f) then
						g_gameRules.game:FreezeInput(true);
					else
						g_gameRules.game:FreezeInput(false);
					end;
					if (t) then
						if (p.FI_TIMER) then
							Script.KillTimer(p.FI_TIMER);
							p.FI_TIMER = nil;
						end;
						p.FI_TIMER = Script.SetTimer(t*1000, function()
							g_gameRules.game:FreezeInput(false);
						end);
					end;
				end;
			end;
			
			-------------------------------
			totable = function(t)
				if (not t or type(t) ~= "table") then
					return {};
				end;
				return t;
			end;
			
			-------------------------------
			copyTable = function(x)
				local copied = {};
				for key, value in pairs(totable(x)) do
					copied[key] = value;
				end;
				return copied;
			end;
			
			-------------------------------
			isVec = function(vector)
				return (type(vector) == 'table' and vector.x and tonumber(vector.x) and vector.y and tonumber(vector.y) and vector.z and tonumber(vector.z) and #vector == 3);
			end;
			
			-------------------------------
			GetDir = function(a, b, n)
				local c = { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z };
				if (n) then
					NormalizeVector(c)
				end;
				return c;
			end;
			
			-------------------------------
			table.copy = function(orig)
				local copied = {};
				for key, value in pairs(orig) do
					copied[key] = value;
				end;
				return copied;
			end;
			
			-------------------------------
			add2Vec = function(a, b)
				return { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z };
			end;
			
			-------------------------------
			CalcPosInFront = function(entity, distance, height)
				local pos = table.copy(entity:GetPos()); --("Bip01 head"));
				local dir = table.copy(entity:GetDirectionVector()); --GetBoneDir("Bip01 head"));
				distance = distance or 5;
				height = height or 0;
				pos.z = pos.z + height;
				ScaleVectorInPlace(dir, distance);
				FastSumVectors(pos, pos, dir);
				dir = entity:GetDirectionVector(1);
				return pos, dir;
			end;
			
			-------------------------------
			calcDist = function(a, b, noX, noY, noZ)
				local p1, p2 = a, b;
				
				if (p1 and p2) then
					local xD, yD, zD = p1.x - p2.x, p1.y - p2.y, p1.z - p2.z;
					local distance = math.sqrt((not noX and xD*xD or 0) + (not noY and yD*yD or 0) + (not noZ and zD*zD or 0));
					return distance;
				end;
				System.LogAlways("> " .. (debug.traceback()or"<tbf>"));
				return "fuk";
			end;
			
			-------------------------------
			average = function(t)
				local a = 0;
				local b = 0;
				for i, v in pairs(t) do
					a = a + v;
					b = b + 1;
				end;
				return (a / b);
			end;
			
			-------------------------------
			round = function(n)
				return (n > 0 and math.floor(n + 0.5) or math.ceil(n - 0.5));
			end;
			
			-------------------------------
			GetEnt = function(name)
				return type(name) == "userdata" and System.GetEntity(name) or System.GetEntityByName(name);
			end;
			
			-------------------------------
			g_game = g_gameRules.game;
			
			-------------------------------
			distanceVectors = function(a, b)
				local X, Y, Z = (a.x - b.x), (a.y - b.y), (a.z - b.z);
				return math.sqrt(X*X + Y*Y + Z*Z);
			end;
			
			-------------------------------
			Helmet_Attach = function(channel, helmetName, x, y, z, bone, vecdir, scale)
				
				local player = GP(channel);
				if (not player) then
					return
				end;
				local helmet = GetEnt(helmetName);
				local NAME = "_helmetattach"..math.random()*9999;
				
				helmet.NAME = NAME;
			
				local tdir;
			
				if (vecdir) then
				--	Msg(0,"TDIR!!")
					tdir = player:GetDirectionVector();
					if (scale) then
						tdir = vecScale(tdir, -1);
					end;
				end;
				--	Msg(0,bone or "Bip01 Head")
				
				--helmet:DestroyPhysics()
				helmet:EnablePhysics(false);
				player:CreateBoneAttachment(0, bone or "Bip01 Head", NAME);
				player:SetAttachmentObject(0, NAME, helmet.id, -1, 0);
				player:SetAttachmentDir(0,NAME,tdir or vecScale(player.actor:GetHeadDir(),-1),true)
				player:SetAttachmentPos(0,NAME,{x=x,y=y,z=z},false)
				
				if (player.id == g_localActorId) then
					ATTACHED_HELMET = helmet;
				end;
			end;
			
			-------------------------------
			function ATOMRocket_AddParticles(rocketCounter)
				local r = _G["atomrockets_" .. rocketCounter]; --System.GetEntityByName(rocketName);
				if (r) then
					local effectsTable = {
						[1] = "misc.signal_flare.on_ground_green",
						[2] = "misc.signal_flare.on_ground",
						[3] = "misc.signal_flare.on_ground_purple"
					};
					local entity = r.EffectEntity;
					if (entity.__EFFECT1) then
						entity:FreeSlot(entity.__EFFECT1);
					end;
					if (entity.__EFFECT2) then
						entity:FreeSlot(entity.__EFFECT2);
					end;
					entity.__EFFECT1 = entity:LoadParticleEffect(-1, effectsTable[math.random(#effectsTable)],{});
					entity.__EFFECT2 = entity:LoadParticleEffect(-1, "smoke_and_fire.pipe_steam_a.steam",     {});
					Msg(0, "Effects added. %s",tostring(entity.__EFFECT1));
				end;
			end;
			
			-------------------------------
			function ATOMRocket_RemoveParticles(counter)
				local r = _G['atomrockets_'..counter];
				if (r) then
					
					local entity = r.EffectEntity;
					if (entity.__EFFECT1) then
						entity:FreeSlot(entity.__EFFECT1);
					end;
					if (entity.__EFFECT2) then
						entity:FreeSlot(entity.__EFFECT2);
					end;
					Msg(0, "Effects removed.");
				end;
			end;
			
			-------------------------------
			function ATOMRocket_Attach(playerName, rocketCounter)
			
				local player = GetEnt(playerName);
				
				if (_G["atomrockets_" .. rocketCounter]) then
					Msg(0, "WARNING!!!!!!!!!!!!!! ROCKET ALREADY EXISTS!!!!!!!!!!!!!!!!!!!");
				end;
				local dp = player:GetPos();
				
				_G["atomrockets_" .. rocketCounter] = {};
				_G["atomrockets_" .. rocketCounter].main = System.SpawnEntity({class="OffHand",position={x=dp.x,y=dp.y,z=dp.z},orientation=g_Vectors.down,name="ar.e_e"..rocketCounter}); 
				_G["atomrockets_" .. rocketCounter].mainrocket = System.SpawnEntity({ViewDistRatio=200, class = "CustomAmmoPickup",position={x=dp.x,y=dp.y,z=dp.z},orientation={ x=0,y=0,z=0},name="atomrocket_main_r_"..rocketCounter,properties={objModel="Objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf",bPhysics=0}})			
				_G["atomrockets_" .. rocketCounter].mainrocket:SetScale(0.5)
				_G["atomrockets_" .. rocketCounter].EffectEntity = System.SpawnEntity({class="OffHand",position={x=dp.x0,y=dp.y,z=dp.z-1.57765},orientation=g_Vectors.down,name="ar.e_e_r"..rocketCounter})

				if (player and player.id == g_localActorId) then
					HAS_ROCKET 			= true;
				end;
				
				for i,v in pairs(_G['atomrockets_'..rocketCounter]) do
					if tostring(i)~="main" then
						_G['atomrockets_'..rocketCounter].main:AttachChild(v.id,1);
				--		Msg(0,"attaching!!")
					end;
				end;
				--Msg(0, "OK LOL")
				player:CreateBoneAttachment(0, "weaponPos_rifle01","_ATOMRocketAttachPositionLOL");
				player:SetAttachmentObject(0, "_ATOMRocketAttachPositionLOL", _G['atomrockets_'..rocketCounter].main.id, -1, 0);
				_G["atomrockets_" .. rocketCounter].mainrocket:SetScale(0.5)
			end;
			
			-------------------------------
			function ATOMRocket_Detach(playerName, counter)
				local rocket = _G['atomrockets_' .. counter];
				if (rocket) then
					local player = GetEnt(playerName);
					if (player and player.id == g_localActorId) then
					
						HAS_ROCKET 			= false;
						
					end;
					
					System.RemoveEntity(rocket.main.id);
					System.RemoveEntity(rocket.EffectEntity.id);
					
					_G['atomrockets_' .. counter] = nil;
				end;
			end;
			
			-------------------------------
			function JetPack_AddParticles(counter)
				if (_G['_currjp_'.. counter]) then
					local names={
						[1]=_G['_currjp_'..counter].t_l_pp1:GetName();
						[2]=_G['_currjp_'..counter].t_r_pp1:GetName();
					};
					local effectsTable = {
						[1] = "misc.signal_flare.on_ground_green",
						[2] = "misc.signal_flare.on_ground",
						[3] = "misc.signal_flare.on_ground_purple"
					};
					local entity;
					for i,v in ipairs(names) do
						entity = System.GetEntityByName(v);
						if (entity) then
							if (entity.__EFFECT1) then
								entity:FreeSlot(entity.__EFFECT1);
							end;
							if (entity.__EFFECT2) then
								entity:FreeSlot(entity.__EFFECT2);
							end;
							entity.__EFFECT1 = entity:LoadParticleEffect(-1, effectsTable[math.random(#effectsTable)],{});
							entity.__EFFECT2 = entity:LoadParticleEffect(-1, "smoke_and_fire.pipe_steam_a.steam",     {});
						end;
					end;
				end;
			end;
			
			-------------------------------
			function JetPack_AddSuperSpeedParticles(counter)
				if (_G['_currjp_'..counter]) then
					local entity = System.GetEntityByName(_G['_currjp_'..counter].t_l_pp1:GetName());
					if (entity) then
						entity.__EFFECT3 = entity:LoadParticleEffect(-1, "smoke_and_fire.Vehicle_fires.burning_jet", {Scale = 0.1, CountScale = 5});
					end;
				end;
			end;
			
			-------------------------------
			function JetPack_RemoveParticles(counter)
				if (_G['_currjp_'..counter]) then
					local names={
						[1]=_G['_currjp_'..counter].t_l_pp1:GetName();
						[2]=_G['_currjp_'..counter].t_r_pp1:GetName();
					};
					local entity;
					for i,v in ipairs(names) do
						entity = System.GetEntityByName(v);
						if (entity) then
							if (entity.__EFFECT1) then
								entity:FreeSlot(entity.__EFFECT1);
								entity.__EFFECT1 = nil;
							end;
							if (entity.__EFFECT2) then
								entity:FreeSlot(entity.__EFFECT2);
								entity.__EFFECT2 = nil;
							end;
							if (entity.__EFFECT3) then
								entity:FreeSlot(entity.__EFFECT3);
								entity.__EFFECT3 = nil;
							end;
						end;
					end;
				end;
			end;
			
			-------------------------------
			function JetPack_Detach(playerName, counter)
				local jetPack = _G['_currjp_' .. counter];
				if (jetPack) then
					local player = GetEnt(playerName);
					if (player) then
						
						player.__jetpackID = nil
					end;
					if (player and player.id == g_localActorId) then
					
						HAS_JET_PACK 			= false;
						g_localActor.flyMode 	= OLD_FLYMODE;
						JETPACK_FUEL 			= nil;
						JETPACK_FUEL_REPORTED 	= false;
						JETPACK_OFF 			= nil;
						JETPACK_EFFECT 			= false;
						JETPACK_ANTENNA_HIDDEN 	= false
						
					end;
					for i, v in pairs(jetPack) do
						System.RemoveEntity(v.id);
					end;
					_G['_currjp_' .. counter] = nil;
				end;
			end;
			
			-------------------------------
			function JetPack_Attach(playerName, counter, unlimited)
				local player = GetEnt(playerName);
				
				if (player.__jetpackID) then
					JetPack_Detach(playerName, player.__jetpackID);
				end;
				player.__jetpackID = counter;
				
				dp1 	= player:GetPos()
				dp1.z 	= dp1.z + 0.5;
					
				dp 		= player:GetPos();
				dp.x 	= dp.x + 0.1;
				dp.z 	= dp.z + 0.2;
					
				_G['_currjp_'..counter] = {}
				_G['_currjp_'..counter].main=System.SpawnEntity({class="CustomAmmoPickup",position=dp1,orientation={ x=0.5,y=0,z=-1},name="JetPackTest_mainPart_"..counter})

				_G['_currjp_'..counter].backHolder=System.SpawnEntity({ViewDistRatio=200, class = "CustomAmmoPickup",position={x=dp.x,y=dp.y,z=dp.z+0.01},orientation={ x=0,y=1,z=0},name="JetPackTest_backHolder_"..counter,properties={objModel="objects/library/installations/electric/electrical_cabinets/electrical_cabinet1.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
					
				_G['_currjp_'..counter].backHolder:SetScale(0.2)
					
				_G['_currjp_'..counter].l_t=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.15,y=dp.y,z=dp.z} ,orientation={ x=0,y=0,z=-1},name="jp.l_t_"..counter,properties={objModel="objects/library/props/gasstation/funnel.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].r_t=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z} ,orientation={ x=0,y=0,z=-1},name="jp.r_t_"..counter,properties={objModel="objects/library/props/gasstation/funnel.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
					
				_G['_currjp_'..counter].l_t_u=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.15,y=dp.y,z=dp.z} ,orientation={ x=1,y=0,z=0},name="jp.l_t_u_"..counter,properties={objModel="objects/library/props/gasstation/can_a.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].r_t_u=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z} ,orientation={ x=1,y=0,z=0},name="jp.r_t_u_"..counter,properties={objModel="objects/library/props/gasstation/can_a.cgf",bPhysics=1,Physics={bPhysicalize=1}}})

				_G['_currjp_'..counter].l_t_u:SetScale(3)
				_G['_currjp_'..counter].r_t_u:SetScale(3)

				_G['_currjp_'..counter].l_t_u_r=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.15,y=dp.y,z=dp.z-0.03} ,orientation={ x=1,y=0,z=0},name="jp.l_t_u_r_"..counter,properties={objModel="objects/library/props/gasstation/tire_rim.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].r_t_u_r=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z-0.03} ,orientation={ x=1,y=0,z=0},name="jp.r_t_u_r_"..counter,properties={objModel="objects/library/props/gasstation/tire_rim.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
					
				_G['_currjp_'..counter].l_t_u_r:SetScale(0.25)
				_G['_currjp_'..counter].r_t_u_r:SetScale(0.25)
					
				_G['_currjp_'..counter].t_t1=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.15,y=dp.y,z=dp.z+0.1} ,orientation={ x=0,y=0,z=0},name="jp.t_t1_"..counter,properties={objModel="objects/library/props/household/windchimes/windchime1/tube06.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].t_t2=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z+0.1} ,orientation={ x=0,y=0,z=0},name="jp.t_t2_"..counter,properties={objModel="objects/library/props/household/windchimes/windchime1/tube06.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
					
				_G['_currjp_'..counter].t_t3=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.15,y=dp.y,z=dp.z} ,orientation={ x=0,y=1,z=1},name="jp.t_t3_"..counter,properties={objModel="objects/library/props/household/windchimes/windchime1/tube06.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].t_t4=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z} ,orientation={ x=0,y=1,z=1},name="jp.t_t4_"..counter,properties={objModel="objects/library/props/household/windchimes/windchime1/tube06.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
					
				_G['_currjp_'..counter].t_t5=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x,y=dp.y,z=dp.z+0.2} ,orientation={ x=0.001,y=0,z=1},name="jp.t_t5_"..counter,properties={objModel="objects/library/props/building material/wodden_support_beam_plank_2_b.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].t_t6=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x,y=dp.y,z=dp.z+0.1} ,orientation={ x=0.001,y=0,z=1},name="jp.t_t6_"..counter,properties={objModel="objects/library/props/building material/wodden_support_beam_plank_2_b.cgf",bPhysics=1,Physics={bPhysicalize=1}}})

				_G['_currjp_'..counter].t_t5:SetScale(0.2)
				_G['_currjp_'..counter].t_t6:SetScale(0.2)
					
				_G['_currjp_'..counter].pp1=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x-0.075,y=dp.y,z=dp.z} ,orientation={ x=0,y=0,z=0},name="jp.pp1_"..counter,properties={objModel="objects/library/installations/electric/power_pole/power_pole_wood_700_b.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].pp1:SetScale(0.3)
				
				_G['_currjp_'..counter].pp2=System.SpawnEntity({class="CustomAmmoPickup",position={x=dp.x+0.15,y=dp.y,z=dp.z} ,orientation={ x=0,y=0,z=0},name="jp.pp2_"..counter,properties={objModel="objects/library/props/flags/northkorean_flagpole_b.cgf",bPhysics=1,Physics={bPhysicalize=1}}})
				_G['_currjp_'..counter].pp2:SetScale(0.1)
				
				_G['_currjp_'..counter].t_l_pp1=System.SpawnEntity({class="OffHand",position={x=dp.x-0.15,y=dp.y,z=dp.z-0.2},orientation=g_Vectors.down,name="jp.t_l_pp1_"..counter})
				_G['_currjp_'..counter].t_r_pp1=System.SpawnEntity({class="OffHand",position={x=dp.x+0.15,y=dp.y,z=dp.z-0.2},orientation=g_Vectors.down,name="jp.t_r_pp1_"..counter})
					
				for i, v in pairs(_G['_currjp_'..counter]) do
					if tostring(i)~="main" then
						--EntityCommon.PhysicalizeRigid( v, -1, {Mass=100,mass=100,fMass=100}, 1 );
						v:EnablePhysics(false)
						v:DestroyPhysics()
						_G['_currjp_'..counter].main:AttachChild(v.id,-1);
					end;
				end;

				if (player and player.id == g_localActorId) then
					JET_PACK_UNLIMITED		= unlimited and true or false;
					HAS_JET_PACK 			= true;
					OLD_FLYMODE				= g_localActor.flyMode;
					JETPACK_ANTENNA_HIDDEN	= false
					g_localActor.flyMode 	= 0;
					g_localActor.jetPackID	= counter;
				end;
				player:CreateBoneAttachment(0, "weaponPos_rifle01","_JetPackAttachPosition");
				player:SetAttachmentObject(0, "_JetPackAttachPosition", _G['_currjp_' .. counter].main.id, -1, 0);
			end;
			
			-------------------------------
			function JetPack_EnableCloaking(c)
				if (_G['_currjp_'..c]) then
					for i, v in pairs(_G['_currjp_'..c]) do
						if (CPPAPI and CPPAPI.ApplyMaskOne) then
							CPPAPI.ApplyMaskOne(v.id, MASK_CLOAK, 1);
						else
							v:EnableMaterialLayer(true, NANOMODE_CLOAK);
						end;
					end;
				end;
			end;
			
			-------------------------------
			function JetPack_DisableCloaking(c)
				if (_G['_currjp_'..c]) then
					for i, v in pairs(_G['_currjp_'..c]) do
						if (CPPAPI and CPPAPI.ApplyMaskOne) then
							CPPAPI.ApplyMaskOne(v.id, MASK_CLOAK, 0);
						else
							v:EnableMaterialLayer(false, NANOMODE_CLOAK);
						end;
					end;
				end;
			end;
			
			-------------------------------
			function _WeaponAttach(weaponName, playerName, boneName01, boneName02, bonePos01, bonePos02, onBack)
				if (CRYMP_CLIENT) then
					-- Not on CryMP client :)
					return;
				end;
				local w, p = GetEnt(weaponName), GetEnt(playerName);
				if (w and p) then
					--w.Properties.bPickable=0;
					p:CreateBoneAttachment(0, bonePos01, boneName01);
					p:CreateBoneAttachment(0, bonePos02, boneName02);
					--w.GetUsableMessage = function()
					--	return "";
					--end; 
					w:DestroyPhysics();
					
					w.IsUsable = function()
						return false;
					end;
					
					if (onBack == 1) then
						p:SetAttachmentObject(0, boneName02, w.id, -1, 0);
					else
						p:SetAttachmentObject(0, boneName01, w.id, -1, 0);
					end;
					w:AwakePhysics(0);
					
					if (p.id == g_localActorId) then
					--	ATTACHED_ITEMS[w.id] = true;
					end;
					
					ATTACHED_ITEMS[w.id] = p.id;
					
					Msg(3, "Attaching on %s back, %s, %s, %d", playerName, boneName01, boneName02, onBack)
				end;
			end;
			
			-------------------------------
			function ChangeVehicleModel(vehicle, model, localPos, localDir, localScale, hideTires)
				if (vehicle and model) then
					
					--[[
					VEHICLE_MODEL_SLOT_COUNTER = VEHICLE_MODEL_SLOT_COUNTER + 1;
					vehicle:LoadObject(0, "objects/weapons/us/frag_grenade/frag_grenade_tp.cgf");
					vehicle:DrawSlot(0, 0);
					if (vehicle.HasCustomModel) then
						vehicle:FreeSlot(vehicle.CustomModelSlot);
					end;
					
					vehicle:LoadObject(VEHICLE_MODEL_SLOT_COUNTER, model);
					--vehicle:SetSlotPos(VEHICLE_MODEL_SLOT_COUNTER, { x = 0, y = 0, z = 0 }); -- Reset
					--vehicle:SetSlotAngles(VEHICLE_MODEL_SLOT_COUNTER, { x = 0, y = 0, z = 0 }); -- Reset
					
					if (localPos or localDir) then
						--vehicle:SetSlotPos(SlotCounter, lPos);
						local tDir = vehicle:GetDirectionVector();
						Msg(3, "localDir=%s",tostring(localDir))
						if (localDir and tonumber(localDir)) then
							for i = 1, tonumber(localDir) do
								Msg(3, "Rotating: %d, %s", i, Vec2Str(tDir))
								VecRotateMinus90_Z(tDir);
							end;
						end;
						vehicle:SetSlotWorldTM(VEHICLE_MODEL_SLOT_COUNTER, vehicle.vehicle:MultiplyWithWorldTM(localPos or vehicle:GetPos()), tDir); --(localDir or vehicle:GetDirectionVector()));
						Msg(3, "Pos=%s", Vec2Str(localPos or g_Vectors.down))
						Msg(3, "Dir=%s", Vec2Str(tDir or g_Vectors.down))
					end;
				
					--if (localPos) then
					--	vehicle:SetSlotPos(VEHICLE_MODEL_SLOT_COUNTER, localPos);
					--	Msg(3, "Pos=%s", Vec2Str(localPos))
					--end;
					--if (localDir) then
					--	vehicle:SetSlotAngles(VEHICLE_MODEL_SLOT_COUNTER, localDir);
					--	Msg(3, "Dir=%s", Vec2Str(localDir))
					--end;
					if (localScale) then
						vehicle:SetLocalScale(VEHICLE_MODEL_SLOT_COUNTER, localScale);
					end;
					vehicle:PhysicalizeSlot(VEHICLE_MODEL_SLOT_COUNTER, { flags = 1.8537e+008 });
					vehicle:GetPhysicalStats()
					vehicle.CustomModelSlot = VEHICLE_MODEL_SLOT_COUNTER;
					--]]
					
					if (vehicle.custommodel) then
						System.RemoveEntity(vehicle.custommodel)
					end;
					local NewModel = System.SpawnEntity({ class = "BasicEntity", position = vehicle:GetPos(), orientation = vehicle:GetDirectionVector(), name = vehicle:GetName() .. "_cm", properties = { object_Model = model }})
					NewModel:LoadObject(0, model);
					-- special flags for correct collision.
					NewModel:PhysicalizeSlot(0, { flags = 1.8537e+008 })
					
					vehicle:DrawSlot(0, 0)
					vehicle:AttachChild(NewModel.id, PHYSICPARAM_SIMULATION);
					vehicle.custommodel = NewModel.id;
					vehicle.custommodelEnt = NewModel;
					
					if (localPos) then
						NewModel:SetLocalPos(localPos);
						Msg(3, "Pos=%s", Vec2Str(localPos))
					end;
					if (localDir) then
						NewModel:SetLocalAngles(localDir);
						Msg(3, "Dir=%s", Vec2Str(localDir))
					end;
					
					if (remTires) then
						for i = 1, 4 do
							vehicle:DrawSlot(i, 0);
						end;
					end;
					
					Msg(3, "Loaded model on vehicle: p=%s, a=%s, s=%s, ht=%s, m=%s", tostring(localPos), tostring(localDir), tostring(localScale), tostring(hideTires), tostring(model));
					
					vehicle.HasCustomModel = true;
				end;
			end;
			
			-------------------------------
			CamGirlPos = function()
				return System.GetViewCameraPos();
			end;
			
			-------------------------------
			CamGirlDir = function()
				return System.GetViewCameraDir();
			end;
			
			-------------------------------
			doSay = function(...)
				local msg = table.concat({...}, " ");
				if (g_localActor) then
					if (msg and string.len(msg) > 0) then
						g_gameRules.game:SendChatMessage(ChatToTarget, g_localActorId, g_localActorId, tostring(msg));
					else
						System.Log("$4Error: message not specified");
					end;
				else
					System.LogAlways("$4Error: local actor not found");
				end;
			end;
			
			-------------------------------
			doSayToAll = function(...)
				local msg = table.concat({...}, " ");
				if (g_localActor) then
					if (msg and string.len(msg) > 0) then
						g_gameRules.game:SendChatMessage(ChatToAll, g_localActorId, g_localActorId, tostring(msg));
					else
						System.Log("$4Error: message not specified");
					end;
				else
					System.LogAlways("$4Error: local actor not found");
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.FlyMode = function(self, enable)
			
			FLYMODE_ENABLED = enable;
			
			if (enable) then
				if (CRYMP_CLIENT) then
					CPPAPI.FSetCVar("mp_flymode", "2");
				else
					FLYMODE_STATE = 0;
				end;
				HUD.DisplayBigOverlayFlashMessage("FlyMode Enabled | Hit [W], [A], [S], [D] Key Once to Start/Stop Moving.", 10, 230, 360, { 221/255, 107/255, 23/255 });
			else
				if (CRYMP_CLIENT) then
					CPPAPI.FSetCVar("mp_flymode", "0");
				else
					FLYMODE_STATE = nil;
					FLYMODE_STATE_NULL_POS = nil; -- reset null position
				end;
				HUD.DisplayBigOverlayFlashMessage("FlyMode Disabled", 10, 160, 360, { 221/255, 107/255, 23/255 });
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HandleKey = function(self, user, keyName)
			if (CHAT_OPEN) then
				if (keyName == "escape") then
					CHAT_OPEN = false;
				end;
			end;
			
			local _send = {
				["escape"] = 122,
				["enter"] = 123,
				["f3"] = 124,
			};
			
			local keyID = _send[keyName];
			if (keyID) then
				self:ToServer(eTS_Spectator, keyID);
			end;
			
			if (keyName == "escape" or keyName == "enter") then
				CHAT_OPEN = false;
			end;
				
			if (keyName == "f3" and FLYMODE_ENABLED) then
				if (FLYMODE_STATE) then
					FLYMODE_STATE = nil;
					FLYMODE_STATE_NULL_POS = nil;
				else
					FLYMODE_STATE = 0;
				end;
				Msg(2, "Flymode state is now %s (FLYMODE_ENABLED=%s)",tostring(FLYMODE_STATE),tostring(FLYMODE_ENABLED));
			end;
				
			if (FLYMODE_STATE ~= nil and not CHAT_OPEN) then
				if (keyName=="w") then
					FLYMODE_STATE = FLYMODE_STATE == 1 and 0 or 1;
				elseif (keyName=="a") then
					FLYMODE_STATE = FLYMODE_STATE == 2 and 0 or 2;
				elseif (keyName=="s") then
					FLYMODE_STATE = FLYMODE_STATE == 3 and 0 or 3;
				elseif (keyName=="d") then
					FLYMODE_STATE = FLYMODE_STATE == 4 and 0 or 4;
				elseif (keyName=="shift") then
					FLYMODE_STATE_SHIFT = not FLYMODE_STATE_SHIFT;
				end;
			end;
			
			Msg(1, "Chat Open: %s", tostring(CHAT_OPEN))
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnAction = function(self, action, activation, value)
		
			local w = g_localActor.inventory:GetCurrentItem();
			local v = g_localActor.actor:GetLinkedVehicleId();
			if (v) then
				v = System.GetEntity(v);
			end;
			
			local wCount = g_localActor:GetSeatWeaponCount();
			
			if (action == "zoom") then
				self:ToServer(eTS_Spectator, (activation == "press" and eCR_MousePL or eCR_MouseRL));
			--	Msg(0,tostring(activation == "press" and eCR_MousePL or eCR_MouseRL))
			end;
			
			local drop = {
				["ShiTen"] = true,
			--	["Claymore"] = true,
			};
			
			if (action == "drop" and w and drop[w.class] and activation == "press") then
				self:ToServer(eTS_Spectator, eCR_DropSpecial);
			-----------------------------------------------------
			elseif (action == "v_horn") then
				self:ToServer(eTS_Spectator, activation == "press" and eCR_HornyON or eCR_HornyOFF);
				Msg(1, "HORNY ID = " .. (activation == "press" and eCR_HornyON or eCR_HornyOFF))
				if (g_localActor.HornySound) then
					if (v) then
						if (activation == "press" and not v.HornySound) then
							v.HornySound = v:PlaySoundEvent(g_localActor.HornySound, g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
						elseif (activation ~= "press" and v.HornySound) then
							v:StopSound(v.HornySound);
							v.HornySound = nil;
						end;
					end;
				end;
			-----------------------------------------------------
			elseif (action == "v_boost") then
				self:ToServer(eTS_Spectator, activation == "press" and eCR_VBoostON or eCR_VBoostOFF);
				if (v and v:GetDriverId() == g_localActorId) then
					if (activation == "press") then
						v.Boost = true;
						v.Boosting = true;
						v.BoostTime = _time;
						if (v.LaunchedNitros) then
						--	Msg(0, "Rockets found, Starting Boost!!")
							if (not v.BoostEffects) then
								local dir = v:GetDirectionVector();
								local pos;
								for i, nitro in ipairs(v.LaunchedNitros) do
									if (nitro.NitroSlot) then
										nitro:FreeSlot(nitro.NitroSlot);
										nitro.NitroSlot = nil;
									end;
									nitro.NitroSlot = nitro:LoadParticleEffect(-1, "misc.signal_flare.on_ground", { Scale = 5 });
									pos = nitro:GetPos();
									pos.x = pos.x - dir.x * 2.5;
									pos.y = pos.y - dir.y * 2.5;
									pos.z = pos.z - dir.z * 2.5 - 0.3;
									nitro:SetSlotWorldTM(nitro.NitroSlot, pos, vecScale(dir, -1));
								end;
								v.BoostEffects = true;
							end;
							NITRO_VEHICLES[v.id] = true;
						end;
					else
						v.Boosting = false;
						v.Boost = false;
						if (v.LaunchedNitros) then
						--	Msg(0, "Rockets found, Stopping Boost!!")
							--if (v.BoostEffects) then
								for i, nitro in ipairs(v.LaunchedNitros) do
									if (nitro.NitroSlot) then
										nitro:FreeSlot(nitro.NitroSlot);
									end;
									nitro.NitroSlot = nil;
								end;
								v.BoostEffects = false;
							--end;
						end;
						NITRO_VEHICLES[v.id] = false;
					end;
				end;
			-----------------------------------------------------
			elseif (action == "v_brake" or (v and action == "skip_cutscene")) then
				if (v and v:GetDriverId() == g_localActorId) then
					if (activation == "press") then
						v.Boost = false; -- disable boosting when braking.
						v.Braking = true;
						v.Boosting = false; -- disable super boosing when braking.
						v.BrakingTime = _time;
					--	Msg(0, "Vehicle brake enabled, Stopping Boost!!")
					--	v.ThrusterON = true;
					else
						v.Braking = false;
					--	v.ThrusterON = false;
					end;
					--v.JetEngineStatus = not v.JetEngineStatus;
					if (activation == "press" and action == "skip_cutscene") then
						self:ToServer(eTS_Spectator, eCR_VBrakeON); --activation == "press" and eCR_VBrakeON or eCR_VBrakeOFF); -- not needed ATM.
					end;
				end;
			-----------------------------------------------------
			elseif (action == "v_moveforward") then
				--self:ToServer(eTS_Spectator, activation == "press" and eCR_PressMV or eCR_ReleaseMV); -- not needed ATM.
				if (v and v:GetDriverId() == g_localActorId) then
					if (activation == "press") then
						v.MovingForward = true;
					--	Msg(0, "Vehicle brake enabled, Stopping Boost!!")
					else
						v.MovingForward = false;
					end;
					v.MovingForward_H = activation == "press";
					self:ToServer(eTS_Spectator, activation == "press" and eCR_VForwardOn or eCR_VForwardOff);
				end;
			-----------------------------------------------------
			elseif (action == "v_moveback" or action == "v_movebackwards") then
				--self:ToServer(eTS_Spectator, activation == "press" and eCR_PressMV or eCR_ReleaseMV); -- not needed ATM.
				if (v and v:GetDriverId() == g_localActorId) then
					if (activation == "press") then
						v.MovingBackwards = true;
					--	Msg(0, "Vehicle brake enabled, Stopping Boost!!")
					else
						v.MovingBackwards = false;
					end;
					v.MovingBackwards_H = activation == "press";
					--self:ToServer(eTS_Spectator, activation == "press" and eCR_VForwardOn or eCR_VForwardOff); -- not yet
				end;
			-----------------------------------------------------
			elseif (action == "use") then
				if (HAS_JET_PACK) then
					self:ToServer(eTS_Spectator, activation == "press" and eCR_JetpackOn or eCR_JetpackOff);
					self._JetpackThrottle = 0;
					if (activation == "press") then
					--	JET_PACK_THRUSTERS = true;
					else
						JETPACK_SUPERSPEED = false;
						JET_PACK_THRUSTERS = false;
					end;
				end;
				if (HAS_ROCKET) then
					self:ToServer(eTS_Spectator, activation == "press" and eCR_RocketON or eCR_RocketOFF);
					self._RocketThrottle = 0;
					if (activation == "press") then
					--	JET_PACK_THRUSTERS = true;
					else
						--JETPACK_SUPERSPEED = false;
						ROCKET_THRUSTERS = false;
					end;
				end;
				
				if (false and not v and activation == "release") then
					local rayHit = self:RayCheck(g_localActor:GetPos(), g_Vectors.down, 1);
					if (rayHit and rayHit.entity) then
						if (rayHit.entity.JetType) then
							if (g_localActor.planeAttachID) then
								Msg(1, "detaching from plane");
								g_localActor:DetachThis();
								g_localActor.planeAttachID = nil;
								self:ToServer(eTS_Spectator, eCR_Detach);
							else
								Msg(1, "attaching to plane. dont use 3rd person while u r attached.");
								g_localActor.planeAttachID = rayHit.entity.id;
								rayHit.entity:AttachChild(g_localActor.id, 1);
								self:ToServer(eTS_Spectator, eCR_Attach);
							end;
						end;
					end;
				end;
				
				if (activation == "press") then
					ATOMClient:ToServer(eTS_Spectator, eCR_UseObject0); -- report only once
				end;
				
				if (g_localActor.hasFlyingChair and g_localActor.chairEntity and System.GetEntity(g_localActor.chairEntity)) then
					if (activation == "press") then
						--Msg(0, "CHAIR ON!!");
						g_localActor.hasFlyingChair = 1;
						self:ToServer(eTS_Spectator, eCR_ChairON);
					else
						--Msg(0, "CHAIR OFF!!");
						g_localActor.hasFlyingChair = 0;
						self:ToServer(eTS_Spectator, eCR_ChairOFF);
					end;
				end;
			-----------------------------------------------------
			elseif (action == "next_spectator_target" and v) then
				if (VEHICLE_WEAPON_SYSTEM == true and wCount < 1) then
					local WeapEnv = g_localActor.inventory:GetInventoryTable();
					g_localActor.LastSelected = g_localActor.LastSelected or {};
					local selectThis;
					local ignore = {
						["Binoculars"] = true;
						["Fists"] = true;
						["OffHand"] = true;
						["RadarKit"] = true; -- was bugged (players count SPAM scan and make insane amount of creds)
					};
					local only;
					if (v:GetDriverId() == g_localActorId) then
						--only = {
						--	["SOCOM"] = true
						--};
						--Msg(0, "Actor is driver, setting weapon to SOCOM");
					else
						--[[for i, seat in ipairs(v.Seats) do
							if (seat:GetPassengerId() == g_localActorId) then
								if (seat:GetWeaponCount() > 0) then
									Msg(0, "Seat has weapons, skipping selection");
								--	only = {};
								elseif (seat.id > 1) then
									Msg(0, "Seat has NO weapons, setting S list");
									only = {
										["FY71"] = true,
										["SCAR"] = true,
										["SMG" ] = true,
										["DSG1"] = true,
										["LAW" ] = true
									};
								end;
							end;
						end;]] -- disabled for now.
					end;
					for i, v in pairs(WeapEnv or {}) do
						local w = System.GetEntity(v);
						if (not only or only[w.class]) then
							if (w and w.weapon and not g_localActor.LastSelected[w.id] and not ignore[w.class]) then
								selectThis = w;
								break;
							end;
						end;
					end;
					if (not selectThis) then
						g_localActor.LastSelected = {};
					else
						g_localActor.LastSelected[selectThis.id] = true;
						g_localActor.actor:SelectItemByName(selectThis.class);
					end;
				end;
			-----------------------------------------------------
			elseif (action == "nextitem") then --action == "small" or action == "medium") then
				local all = g_localActor.inventory:GetInventoryTable();
				local total = -2;
				for i, v in pairs(all or{}) do
					local w = System.GetEntity(v);
					if (w and w.weapon) then
						total = total + 1;
					end;
				end;
				g_localActor.invenv = (g_localActor.invenv or 0) + 1;
				--Msg(0, "%d/%d",g_localActor.invenv,total)
				if (g_localActor.invenv >= total) then
					g_localActor.invenv = nil;
					--Msg(0, "SHITEN!");
					local shiTen = g_localActor.inventory:GetItemByClass("ShiTen");
					if (shiTen) then

						ShiTen.Properties.bSelectable = 1
						ShiTen.Properties.bPickable = 1
						ShiTen.Properties.bSelectable = 1
						ShiTen.Properties.bDroppable = 1
						ShiTen.Properties.bGiveable = 1
						ShiTen.Properties.bRaisable = 1
						ShiTen.Properties.bMounted = 0
						ShiTen.Properties.bMountable = 1
					
						shiTen = System.GetEntity(shiTen);
						shiTen.Properties.bSelectable = 1
						shiTen.Properties.bPickable = 1
						shiTen.Properties.bSelectable = 1
						shiTen.Properties.bDroppable = 1
						shiTen.Properties.bGiveable = 1
						shiTen.Properties.bRaisable = 1
						shiTen.Properties.bMounted = 0
						shiTen.Properties.bMountable = 1
						g_localActor.actor:SelectItemByName("ShiTen");
						--Msg(0, "SHITEN SELECTED!!");
					end;
				end;
				--[[
				if (not v or (v and wCount < 1)) then
					local items;
					-- need g_localActor.inventory:GetItemsByType :(
					if (action == "small") then
						items = g_localActor.inventory:GetItemsByType("small");
					else
						local selectShiten = false;
						items = g_localActor.inventory:GetItemsByType("medium");
						Msg(0, "items:%d",#items);
						g_localActor.mediumItemEnv = g_localActor.mediumItemEnv or 0;
						if (g_localActor.mediumItemEnv>=#items) then
							selectShiten = true;
							g_localActor.mediumItemEnv = nil;
						else
							g_localActor.mediumItemEnv = g_localActor.mediumItemEnv+1;
						end;
						Msg("Shiten: %d/%d",g_localActor.mediumItemEnv,#items);
						if (selectShiten) then
							local shiTen = g_localActor.inventory:GetItemByClass("ShiTen");
							if (shiTen) then
								g_localActor.actor:SelectItemByName("ShiTen");
								Msg(0, "SHITEN SELECTED!!");
							end;
						end;
					end;
				end;--]]
			-----------------------------------------------------
			elseif (action == "binoculars" and v) then
				if (VEHICLE_WEAPON_SYSTEM == true and wCount < 1) then
					local Binocs = g_localActor.inventory:GetItemByClass("Binoculars");
					if (Binocs) then
						Binocs = System.GetEntity(Binocs);
						if (not Binocs.Selected or g_localActor.inventory:GetCurrentItem().id ~= Binocs.id) then
							g_localActor.actor:SelectItemByName(Binocs.class);
							Binocs.Selected = true;
						else
							g_localActor.actor:HolsterItem(true);
							g_localActor.actor:SelectItemByName("Fists");
							Binocs.Selected = false;
						end;
					end;
				end;
			-----------------------------------------------------
			elseif (action == "attack1") then
				self:ToServer(eTS_Spectator, (activation == "press" and eCR_MouseP or eCR_MouseR));
				if (v and w) then
				--	self.ReportHD = activation == "press";
				end;
			-----------------------------------------------------
			elseif (action == "special") then
				self:ToServer(eTS_Spectator, (activation == "press" and eCR_MeleeP or eCR_MeleeR));
			end;
			
			
			if (Remote.OnAction) then -- remote added function
				Remote:OnAction(action, activation, value);
			end;
			
			
			if (w and w.class == "Fists") then
				self:CheckWallJump(action, activation, value);
			end;
			
			if (action == "hud_openchat" or action == "hud_openteamchat") then
				self:ToServer(eTS_Spectator, action == "hud_openchat" and 120 or 121);
				CHAT_OPEN = true;
			end;
			
			g_localActor.LastAction = action;
			
			Msg(5, "OnAction(%s, %s, %d)", action, activation, value);
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CanSeePoint = function(self, point, id)
			if (not System.IsPointVisible(point)) then
				return false;
			end;
		
			-- add timer to prevent crashes on weak ahh computers
			self.LAST_RAY_CHECKS = self.LAST_RAY_CHECKS or {};
			if (self.LAST_RAY_CHECKS[id] and _time - self.LAST_RAY_CHECKS[id][2] < 1) then
				return self.LAST_RAY_CHECKS[id][1];
			end;
		
			self.LAST_RAY_CHECKS[id] = { Physics.RayTraceCheck(CamGirlPos(), point, g_localActor.id, id or NULL_ENTITY), _time };
			return self.LAST_RAY_CHECKS[id][1];
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckWallJump = function(self, a, b, c, w)
			if (g_localActor:IsDead() or g_localActor.actor:GetSpectatorMode() ~= 0) then-- or not g_localActor.WallJumpMult) then
				g_localActor.WallJumpSteps = 0;
				return;
			end;
			-- FIXME: Not angles
			local anglesZ = System.GetViewCameraDir().z;
			if (anglesZ > 0 and anglesZ < 0.5) then
				return;
			end;
			
			local Object = self:RayCheck(System.GetViewCameraPos(), System.GetViewCameraDir(), 1);
			if (not Object) then
				return;
			end;
			
			local WallJumping = false;
			if (a == "cycle_spectator_mode") then
			
				WallJumping = true;
				g_localActor.WallJumpStart = _time;
			elseif (g_localActor.LastAction and g_localActor.LastAction == "cycle_spectator_mode" and a == "jump" and _time - g_localActor.WallJumpStart <= 3) then
			
				WallJumping = true;
			elseif (g_localActor.WallJumpSteps and g_localActor.WallJumpSteps >= 2 and (a == "zoom" or a == "zoom_out") and _time - g_localActor.WallJumpStart <= 5) then
			
				WallJumping = true;
			end;
			if (WallJumping) then
			
				g_localActor.WallJumpSteps = (g_localActor.WallJumpSteps or 0) + 1;
				Msg(1, "JUMPING!!, STEPS %d", g_localActor.WallJumpSteps)
				if (g_localActor.WallJumpSteps >= 5) then
				
					if (g_localActor.WallJumpMult) then
						g_localActor:AddImpulse(-1, g_localActor:GetCenterOfMassPos(), vecScale(System.GetViewCameraDir(), -1), g_localActor.WallJumpSteps * (g_localActor.WallJumpMult * 10), 1); 
					end;
					WALL_JUMPING = WALL_JUMPING or { Jumping = true, StartZ = g_localActor:GetPos().z, Highest = -1, StartTime = _time };
					
					if (not WALL_JUMPING.Jumping) then
						WALL_JUMPING.Jumping = true;
						WALL_JUMPING.Highest = -1;
						WALL_JUMPING.BestTime = -1;
						WALL_JUMPING.StartZ = g_localActor:GetPos().z;
						WALL_JUMPING.StartTime = _time;
					end;
				end;
			else
				g_localActor.WallJumpSteps = 0;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.RayCheck = function(self, pos, dir, distance)
			local hits = Physics.RayWorldIntersection(pos, vecScale(dir, distance), distance, ent_all-ent_terrain, g_localActor.id, nil, g_HitTable);
			local hit = g_HitTable[1];
			if (hits > 0 and hit) then
				local surface = System.GetSurfaceTypeNameById(hit.surface);
				hit.surfaceName = surface
				return hit;
			end
			return nil;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HandleEvent = function(self, eventCase, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22)
			-- MESSY
			-- MESSY
			-- NMESSY
			if (CLIENT_DISABLED) then -- the client is disabled
				return false;
			end;
			
			--Msg(6, "HandleEvent(%s, %s, %s)", eventCase, eventCase, eventCase);
			
			local entity, temp;
			
			if (eventCase == eCE_ClientInstalled) then
				self:ToServer(eTS_Spectator, 4);
				if (System.GetCVar("cl_crymp")) then
					self:ToServer(eTS_Spectator, eCR_ClientCryMP);
				elseif (CPPAPI) then
					self:ToServer(eTS_Spectator, eCR_ClientSFWCL);
				else
					self:ToServer(eTS_Spectator, eCR_ClientUnknown);
				end;
				
			elseif (eventCase == eCE_LoadCode) then
			--	Msg(0, "CODE [4] \"%s\", %d", p1:sub(1, 4), string.len(p1:sub(1, 4)));
				if (p1:sub(1, 3) == "EX:" or p1:sub(1, 4) == "EX:" or p1:sub(1, 4) == "EX: ") then
					p1 = p1:sub(4);
				end;
				local success, error = pcall(loadstring, p1);
				if (not success) then
					Msg(0, "[1] Error loading code, %s, (%s)", error, p1);
					self:ToServer(eTS_ChatLua, "!luaerr" .. error);
					--self:ToServer(eTS_Spectator, 5); -- error
				end;
				success, error = pcall(error);
				if (not success) then
					Msg(0, "[2] Error loading code, %s, (%s)", error, p1);
					self:ToServer(eTS_ChatLua, "!luaerr" .. error);
					--self:ToServer(eTS_Spectator, 5); -- error
				end;
				
			elseif (eventCase == eCE_ReportFPS) then
				local avgSpec = average({
					System.GetCVar("sys_spec_GameEffects"), 
					System.GetCVar("sys_spec_MotionBlur"), 
					System.GetCVar("sys_spec_ObjectDetail"), 
					System.GetCVar("sys_spec_Particles"), 
					System.GetCVar("sys_spec_Physics"), 
					System.GetCVar("sys_spec_PostProcessing"), 
					System.GetCVar("sys_spec_Quality"), 
					System.GetCVar("sys_spec_Shading"), 
					System.GetCVar("sys_spec_Shadows"), 
					System.GetCVar("sys_spec_Sound"),
					System.GetCVar("sys_spec_Texture"), 
					System.GetCVar("sys_spec_VolumetricEffects"), 
					System.GetCVar("sys_spec_Water")
				});
				local fps = {
					screen 	= (System.GetCVar("r_width") .. "x" .. System.GetCVar("r_height")),
					spec	= round(avgSpec),
					start	= System.GetFrameID(),
					endFps	= 0,
					diffFps	= 0,
					average	= 0,
					dx10	= false
				}; 
				
				-- sryke
				if (CPPAPI and CPPAPI.GetRenderType) then	
					local tbl = {
						[0] = "Undefined",
						[1] = "Null",
						[2] = "DX9",
						[3] = "DX10",
						[4] = "BigBox360",
						[5] = "PS3",
					}
					fps.dx10=tbl[CPPAPI.GetRenderType()] or "DX25";
				end
				
				Script.SetTimer(1000 * (tonumber(p1) or 3), function() 
					fps.endFps	= System.GetFrameID(); 
					fps.diffFps	= fps.endFps - fps.start; 
					fps.average	= fps.diffFps / (tonumber(p1) or 3); 
					fps.dx10	= CryAction.IsImmersivenessEnabled()==1 and "DX10" or "DX9"; 
					local specNames = {
						[1] = "Very Low";
						[2] = "Low";
						[3] = "Medium";
						[4] = "Very High";
					};
					local spec = specNames[fps.spec] or "Medium";
					if (System.GetCVar("r_texResolution") >= 3) then -- Special case for FPS lovers
						spec = "Next Gen Graphics";
					end;
					if (p2 == nil) then
						--g_gameRules.game:SendChatMessage(2,g_localActorId,g_localActorId, "My FPS are "..fps.average.." | Driver "..(not fps.dx10 and "DX9" or "DX10").." | Display "..fps.screen.." | Spec " ..spec);
						self:ToServer(eTS_Chat, "My Average FPS Are " .. fps.average .. " | Driver " .. fps.dx10 .. " | Display " .. fps.screen .. " | Spec " .. spec);
					else
						self:ToServer(eTS_Report, "FPS", round(fps.average), fps.dx10, fps.spec, fps.screen);
						--g_localActor:Report(5, round(fps.average), fps.dx10, fps.spec, fps.screen);	
					end;
				end);
			elseif (eventCase == eCE_LoadEffect) then
				entity = GetEnt(p1);
				if (entity) then
					if (p10) then
						self:HandleEvent(eCE_UnloadEffect, entity.id);
					end;
					temp = {				
						bActive			= 1,
						bPrime			= 1,
						Scale			= tonumber(p3 or 1),			-- Scale entire effect size.
						SpeedScale		= tonumber(p4 or 0),			-- Scale particle emission speed
						CountScale		= tonumber(p5 or 0),			-- Scale particle counts.
						bCountPerUnit	= tonumber(p6 or 0),			-- Multiply count by attachment extent
						AttachType		= tostring(p7 or "Render"),		-- BoundingBox, Physics, Render
						AttachForm		= tostring(p8 or "Surface"),	-- Vertices, Edges, Surface, Volume - cool stuff :D
						PulsePeriod		= tonumber(p9 or 0),			-- Restart continually at this period.
					};
					entity.loadedParticles = (entity.loadedParticles or 30) + 1;
					entity['effect_' .. entity.loadedParticles] = entity:LoadParticleEffect(-1, p2, temp);
					Msg(1, "EFFECT SLOT = %s", tostring(entity['effect_' .. entity.loadedParticles]));
				else
					Msg(0, "Invalid Entity to event eCE_LoadEffect, %s", tostring(p1));
				end;
			elseif (eventCase == eCE_UnloadEffect) then
				entity = GetEnt(p1);
				if (entity) then
					for i = 1, (entity.loadedParticles or 0) do
						temp = 'effect_' .. entity.loadedParticles
						if (entity[temp]) then
							Msg(0, "Cleared Slot %s (%s)", tostring(temp), tostring(entity[temp]));
							entity:FreeSlot(entity[temp]);
						end;
					end;
					entity.loadedParticles = nil;
				else
					Msg(0, "Invalid Entity to event eCE_UnloadEffect, %s", tostring(p1));
				end;
			elseif (eventCase == eCE_Sound) then
				entity = ((type(p1)=="table" and p1.id) and p1 or GetEnt(p1));
				if (entity) then
					entity.soundId = entity:PlaySoundEvent(p2, g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
				else
					Msg(0, "Invalid Entity to event eCE_Sound, %s", tostring(p1));
				end;
			elseif (eventCase == eCE_Anim) then
				entity = GetEnt(p1);
				if (entity) then
					if (not p3) then
						entity:StartAnimation(0, tostring(p2)); 
					else
						local animTime = tonumber(p2) or 1;
						entity:StartAnimation(0, tostring(p2), 8, 0, 1, --[[LOOP ->]]1--[[<- LOOP]], 1);
						entity:ForceCharacterUpdate(0, true);
						LOOPED_ANIMS[entity.id] = {
							Entity 	= entity,
							Loop 	= p3 or -1,
							Timer 	= entity:GetAnimationLength(0, tostring(p2)),
							Speed 	= p4 or 1,
							Anim 	= p2,
							NoSpec	= true,
							Alive	= true
						};
						Script.SetTimer(animTime * 1000, function()
							LOOPED_ANIMS[entity.id] = nil;
							entity:StopAnimation(0, 8);	
						end);
					end;
				else
					Msg(0, "Invalid Entity to event eCE_Anim, %s", tostring(p1));
				end;
			
			elseif (eventCase == eCE_SetCapacity) then
				g_localActor.newAmmoCapacity =
				{
					bullet				= tonumber(p1) 	or 35*4,
					fybullet			= tonumber(p2) 	or 35*4,
					lightbullet			= tonumber(p3) 	or 25*8,
					smgbullet			= tonumber(p4) 	or 40*8,
					explosivegrenade	= tonumber(p5) 	or 3,
					flashbang			= tonumber(p6) 	or 3,
					smokegrenade		= tonumber(p7) 	or 3,
					empgrenade			= tonumber(p8) 	or 3,
					scargrenade			= tonumber(p9) 	or 10,
					rocket				= tonumber(p10) or 5,
					sniperbullet		= tonumber(p11) or 10*4,
					tacbullet			= tonumber(p12) or 5*4,
					tagbullet			= tonumber(p13) or 10,
					gaussbullet			= tonumber(p14) or 5*4,
					hurricanebullet		= tonumber(p15) or 500*2,
					incendiarybullet	= tonumber(p16) or 30*4,
					shotgunshell		= tonumber(p17) or 8*8,
					avexplosive			= tonumber(p18) or 6,
					c4explosive			= tonumber(p19) or 6,
					claymoreexplosive	= tonumber(p20) or 6,
					rubberbullet		= tonumber(p21) or 30*4,
					tacgunprojectile	= tonumber(p22) or 4
				};
			
				if (g_localActor.inventory and g_localActor.newAmmoCapacity) then
					for ammo, capacity in pairs(g_localActor.newAmmoCapacity) do
						Msg(8, "[AMMO CAPACITY] %s = %s", tostring(ammo),tostring(capacity))
						g_localActor.inventory:SetAmmoCapacity(ammo, capacity);
					end;
				end;
			elseif (eventCase == eCE_ToggleLowSpec) then
				if (p1 == true) then
				
					Msg(1, "Low spec enabled");
					
					--OLD_SPEC = OLD_SPEC or System.GetCVar("sys_spec_full");
					--System.SetCVar("sys_spec_full", "1");
					System.SetCVar("r_texResolution", "4");
					System.SetCVar("r_texBumpResolution", "4");
				else
				
					Msg(1, "Low spec disabled");
				
					--System.SetCVar("sys_spec_full", tostring(OLD_SPEC));
					System.SetCVar("r_texResolution", "0");
					System.SetCVar("r_texBumpResolution", "0");
					
					OLD_SPEC = nil;
				end;
			elseif (eventCase == eCE_BattleLog) then
				if (not p1 or not tonumber(p1)) then
					return Msg(0, "Invalid type to Event eCE_BattleLog");
				end;
				HUD.BattleLogEvent(p1, p2);
			elseif (eventCase == eCE_ATOMPack) then
			
			elseif (eventCase == eCE_SetForced) then
				if (not p1 or #p1 < 1) then
					return Msg(0, "No or Empty table to Event eCE_SetForced");
				end;
				Msg(3, "Adding %d Cvars to forced cvars list", #p1);
				FORCED_CVARS = {};
				for i, cvar in pairs(p1) do
					if (cvar[1]) then
						FORCED_CVARS[cvar[1]] = cvar[2];
					else
						Msg(0, "Nil CVar to eCE_SetForced (%s)", tostring(cvar));
					end;
				end;
			elseif (eventCase == eCE_AddForced) then
				if (not p1) then
					return Msg(0, "No Cvar to Event eCE_SetForced");
				end;
				if (not p2) then
					return Msg(0, "No Value to Event eCE_SetForced");
				end;
				Msg(3, "Added %s (%s) to forced cvars list", p1,p2);
				FORCED_CVARS[p1] = p2;
			elseif (eventCase == eCE_SetSuperSpeed) then
				if (not p1) then
					return Msg(0, "No Speed to Event eCE_SetSuperSpeed");
				end;
				if (p1 == -1) then
					g_localActor.actor:Revive();
					g_localActor.SuperSpeed = nil;
					Msg(3, "Super Speed disabled");
					return;
				end;
				g_localActor.SuperSpeed = p1;
				Msg(3, "Super Speed set to x%d", p1);
				self:HandleEvent(eCE_EnableSuperSpeed, g_localActor.SuperSpeed);
			elseif (eventCase == eCE_SetSuperJump) then
				
			elseif (eventCase == eCE_EnableSuperSpeed) then
				temp = p1 or g_localActor.SuperSpeed;
				temp = {
					standSpeed = 60.0,--meters/s
					speedInertia = 100.0,--the more, the faster the speed change: 1 is very slow, 10 is very fast already 
					rollAmmount = 60.0,
					
					sprintMultiplier = temp,--speed is multiplied by this ammount when alien is sprinting
					sprintDuration = 10.5,--how long the sprint is
					
					rotSpeed_min = 10.9 * 7.0,--1.0,--rotation speed at min speed
					rotSpeed_max = 10.6 * 7.0,--rotation speed at max speed
					
					speed_min = 10.0,--used by the above parameters
					
					forceView = 11.0,--multiply how much the view is taking into account when moving
					
					--graphics related
					modelOffset = { x = 0, y = 0, z = 0 }
				};
				g_localActor.actor:SetParams(temp);
				Msg(3, "Super Speed enabled, x%d", p1);
			elseif (eventCase == eCE_SetWJMult) then
				if (p1 == -1) then
					g_localActor.WallJumpMult = nil;
					return Msg(3, "WallJump Multiplier Disabled");
				end;
				g_localActor.WallJumpMult = p1;
				Msg(3, "WallJump Multiplier Set to %d", p1);
			elseif (eventCase == eCE_IdleAnim) then -- Spcial event for ATOM-AnimationHandler.lua
				if (not p1) then
					return Msg(0, "No entity specified to eCE_IdleAnim");
				end;
				entity = GetEnt(p1);
				if (not entity) then
					return Msg(0, "Entity specified to eCE_IdleAnim was not found");
				end;
				if (not p2) then
					return Msg(0, "No animation specified to eCE_IdleAnim");
				end;
				if (p3~=nil) then
					LOOPED_ANIMS[entity.id] = {
						Start 	= _time,
						Entity 	= entity,
						Loop 	= -1,
						Timer 	= entity:GetAnimationLength(0, tostring(p2)),
						Speed 	= 1,
						Anim 	= tostring(p2),
						NoSpec	= true,
						Alive	= true,
						NoWater	= true
					};
				elseif (LOOPED_ANIMS[entity.id]) then
					LOOPED_ANIMS[entity.id] = nil;
					Msg(0, "Unregistered anim event for %s", p1);
				end;
				entity:StopAnimation(0, -1);
				entity:StartAnimation(0, tostring(p2));
				--entity:ForceCharacterUpdate(0, true);
				Msg(3, "Started animation %s on %s (loop: %s)", p2, p1, tostring(p3 ~= nil));
			elseif (eventCase == eCE_VehModel) then
				if (not p1) then
					return Msg(0, "No vehicle specified to eCE_VehModel");
				end;
				entity = GetEnt(p1);
				if (not entity) then
					return Msg(0, "vehicle specified to eCE_VehModel was not found");
				end;
				if (not p2) then
					return Msg(0, "No model specified to eCE_VehModel");
				end;
				ChangeVehicleModel(entity, p2, p3, p4, p5, p6, p7);
			elseif (eventCase == eCE_ATOMTaunt) then
				if (not p1) then
					return Msg(0, "No entity specified to eCE_ATOMTaunt");
				end;
				entity = GetEnt(p1);
				if (not entity) then
					return Msg(0, "entity specified to eCE_ATOMTaunt was not found");
				end;
				if (not p2) then
					return Msg(0, "No sound specified to eCE_ATOMTaunt");
				end;
				entity:PlaySoundEvent(p2, g_Vectors.v000, g_Vectors.v010, bor(bor(SOUND_EVENT, SOUND_VOICE),SOUND_DEFAULT_3D),SOUND_SEMANTIC_PLAYER_FOLEY);
				--self:HandleEvent(eCE_Sound, entity, p2);
				Msg(2, "Playing Taunt %s on %s", p2,entity:GetName());
			else
				Msg(0, "Invalid Type to HandleEvent, %s", tostring(eventCase));
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HookGlobals = function(self)
			if (ShiTen) then
				ShiTen.Properties.bSelectable = 1
				ShiTen.Properties.bPickable = 1
				ShiTen.Properties.bSelectable = 1
				ShiTen.Properties.bDroppable = 1
				ShiTen.Properties.bGiveable = 1
				ShiTen.Properties.bRaisable = 1
				ShiTen.Properties.bMounted = 0
				ShiTen.Properties.bMountable = 1
				--ShiTen.CM
			end;
			
			CRYMP_CLIENT = (CPPAPI and CPPAPI.CreateKeyBind) or System.GetCVar("mp_crymp");
			if (CRYMP_CLIENT) then
				-- maybe causes gay kick bug??? it does. skata scheisse alter | ok gefixt brudda
				CPPAPI.FSetCVar("mp_pickupobjects", "1");
				CPPAPI.FSetCVar("mp_pickuvehicles", "1");
				CPPAPI.FSetCVar("mp_walljump", 		"1");
				CPPAPI.FSetCVar("mp_circlejump", 	"1"); -- too lazy to add to server
				-- NO !!
				--CPPAPI.FSetCVar("mp_crymp", "1");
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HookGameRules = function(self)
			--local game = g_gameRules;
			
			---------------------
			-- OnKill
			---------------------
			
			-- ====================================================================================
			-- MAYBE ALL OF THE SHIT BELOW CAUSES THE CRASH BUG ???
			-- ====================================================================================
		
			-- doesnt work all the time, needs C++ func CGameRules::InitScriptTables() to be called
			--[[
			self.Patcher:Add("g_gameRules", function(self, p, s, w, dmg, m, t)
			
				local mn = self.game:GetHitMaterialName(m) or "";
				local tp = self.game:GetHitType(h) or "";			
					
				local hs = string.find(mn, "head");
				local melee = string.find(tp, "melee");
				local pp = p and System.GetEntity(p);

				if (p == g_localActorId) then
					local x = hs and 2 or melee and 3 or 5;
					HUD.ShowDeathFX((hs and 3 or melee and 2 or 1));
					--g_gameRules.FadeScreen(g_gameRules); -- UNDO: maybe causes crash bug ???
				end
				
				if (ATOMClient and ATOMClient.OnKill and pp) then
					ATOMClient:OnKill(pp, s, w, melee, hs, tp);
				end;
			end, "OnKill", "Client");
			
			---------------------
			-- FadeScreen
			---------------------
			
			self.Patcher:Add("g_gameRules", function(self)
				self.Client.OnPlayerKilled(self, g_localActor);
			end, "FadeScreen");
			
			---------------------
			-- ClientViewShake
			---------------------
			
			self.Patcher:Add("g_gameRules", function(self)
				-- Vallah weg damiiiiiiiiiiiiiiit
			end, "ClientViewShake");
			--]]
			---------------------
			-- SetupPlayer
			---------------------
			
			self.Patcher:Add("g_gameRules", function(self, player)

				player.ammoCapacity = player.newAmmoCapacity or {
					bullet				= 30*4,
					fybullet			= 30*4,
					lightbullet			= 20*8,
					smgbullet			= 20*8,
					explosivegrenade	= 3,
					flashbang			= 2,
					smokegrenade		= 1,
					empgrenade			= 1,
					scargrenade			= 10,
					rocket				= 3,
					sniperbullet		= 10*4,
					tacbullet			= 5*4,
					tagbullet			= 10,
					gaussbullet			= 5*4,
					hurricanebullet		= 500*2,
					incendiarybullet	= 30*4,
					shotgunshell		= 8*8,
					avexplosive			= 2,
					c4explosive			= 2,
					claymoreexplosive	= 2,
					rubberbullet		= 30*4,
					tacgunprojectile	= 2
				};

				if (player.inventory and player.ammoCapacity) then
					for ammo,capacity in pairs(player.ammoCapacity) do
						player.inventory:SetAmmoCapacity(ammo, capacity);
					end;
				end;

			end, "SetupPlayer");
			---------------------
			-- OnDisconnect
			---------------------
			self.Patcher:Add("g_gameRules", function(self, cause, desc) -- doesnt get called anymore for whatever unknown reason
				System.LogAlways("$4Disconnecting");
				if (ATOMClient and CLIENT_DISABLED == false) then
					ATOMClient:Shutdown(cause, desc);
				end;
			end, "OnDisconnect", "Client");
			
			-- Fucking game states
			self.Patcher:Replace("g_gameRules.Client.InGame.OnDisconnect", "g_gameRules.Client.OnDisconnect;Msg(0,\"replaced\")");
			self.Patcher:Replace("g_gameRules.Client.PreGame.OnDisconnect", "g_gameRules.Client.OnDisconnect;Msg(0,\"replaced\")");
			self.Patcher:Replace("g_gameRules.Client.PostGame.OnDisconnect", "g_gameRules.Client.OnDisconnect;Msg(0,\"replaced\")");
			
			---------------------
			-- CanWork
			---------------------
			self.Patcher:Add("g_gameRules", function()
				-- free workspace for everybody
				return true;
			end, "CanWork");
			---------------------
			-- OnHit
			---------------------
			self.Patcher:Add("g_gameRules", function(self, hit)
				if ((not hit.target) or (not self.game:IsFrozen(hit.target.id))) then
					local target = hit.target;
					if (target and (not hit.backface) and target.Client and target.Client.OnHit) then
						target.Client.OnHit(target, hit);
					end;
				end	;
				Msg(6, "function g_gameRules.Client.OnHit(self, hit)")
			end, "OnHit", "Client");
			
		end;
		---------------------
		-- AddCommands
		---------------------
		ATOMClient.AddCommands = function(self)
			local commands = {
				{
					"logVerbosity",
					"ATOMClient:SetLogVerbosity(%1)",
					"Sets the ATOMClient Logging Verbosity.\nDefault is " .. self.LogVerbosity
				},
				{
					"toggleclient",
					"CLIENT_DISABLED = not CLIENT_DISABLED; Msg(0,'STATUS: %s',tostring(CLIENT_DISABLED))",
					"toggles the client state !!!"
				},
				{
					"test",
					"loadstring(%%)()",
					"Run sum tests"
				},
				{
					"state",
					"System.LogAlways((CLIENT_DISABLED==true and\"DISABLED\"or\"ENABLED\"))",
					"show the client state"
				},
				{
					"displayInfo",
					"ATOMClient:CVarCallback(\"a_displayInfo\", \"NEW_DISPLAY_INFO\", (%% or nil), true, false, false)",
					"Display additional information on screen.\n[1] = On, [0] = Off."
				},
				{
					"debug_wallJump",
					"ATOMClient:CVarCallback(\"a_debug_wallJump\", \"DEBUG_WALL_JUMP\", %%, false, true, false)",
					"Displays walljump information on screen for debugging purposes.\n[1] = On, [0] = Off."
				},
				{
					"debug_fp_spec",
					"ATOMClient:CVarCallback(\"a_debug_fp_spec\", \"DEBUG_FIRST_PERSON_SPEC\", %%, false, true, false)",
					"Displays first person spectator information on screen for debugging purposes.\n[1] = On, [0] = Off."
				},
				{
					"vehicle_boost_up",
					"ATOMClient:CVarCallback(\"a_vehicle_boost_up\", \"VEHICLE_BOOST_UP_AMOUNT\", %%, true, false, false)",
					"Sets the Vehicle Boost UP Impulse Amount.\nImpulse applied to hood or engine position of Vehicle."
				},
				{
					"vehicle_boost_forward",
					"ATOMClient:CVarCallback(\"a_vehicle_boost_forward\", \"VEHICLE_BOOST_FORWARD_AMOUNT\", %%, true, false, false)",
					"Sets the Vehicle Boost FORWARD Impulse Amount.\nImpulse applied to center of mass position of Vehicle."
				},
				{
					"vehicle_boost_time",
					"ATOMClient:CVarCallback(\"a_vehicle_boost_time\", \"VEHICLE_BOOST_TIME\", %%, true, false, false)",
					"Sets the Vehicle Boost Time in Seconds.\nDefault Value is 10.\nNote: Greater value also means faster speed."
				},
				{
					"vehicle_weapon_system",
					"ATOMClient:CVarCallback(\"a_vehicle_weapon_system\", \"VEHICLE_WEAPON_SYSTEM\", %%, false, true, false)",
					"Enables or disables the ability to equip items while in vehicle\n0 = Off,\n1 = On"
				},
				{
					"no_dts",
					"ATOMClient:CVarCallback(\"a_no_dts\", \"ATOM_NO_DTS\", %%, false, true, false)",
					"Empty\n0 = Off,\n1 = On"
				},
				{
					"cap_env_steps",
					"ATOMClient:CVarCallback(\"a_cap_env_steps\", \"CAP_ENVIRONMENT_STEPS\", %%, true, false, false)",
					"The amount of cap entity environment updates done each frame\nHigher numbers might cause lags."
				},
				{
					"flymode_update_rate",
					"ATOMClient:CVarCallback(\"flymode_update_rate\", \"FLYMODE_UPDATE_RATE\", %%, true, false, false)",
					"The time between each flymode position update."
				},
				{
					"moreHUD_dist",
					"ATOMClient:CVarCallback(\"moreHUD_dist\", \"MOREHUD_SCAN_DIST\", %%, true, false, false)",
					"The distance for moreHUD to operate."
				},
				{
					"moreHUD_showall",
					"ATOMClient:CVarCallback(\"moreHUD_showall\", \"MOREHUD_SHOW_ALL\", %%, false, true, false)",
					"The distance for moreHUD to operate."
				},
				{
					"use_slowmo_kills",
					"ATOMClient:CVarCallback(\"use_slowmo_kills\", \"USE_SLOWMO_KILLS\", %%, false, true, false)",
					"Toggle slowmotion kills"
				},
				{
					"fps_limit",
					"ATOMClient:CVarCallback(\"a_fps_limit\", \"CLIENT_FPS_LIMIT\", (%% or nil), true, false, false)",
					"maximum updates per second for ATOM Cleint"
				},
				{
					"searchLASER_scale",
					"ATOMClient:CVarCallback(\"a_searchLASER_scale\", \"SEARCHLASER_SCALE\", (%% or nil), true, false, false)",
					"scale for the search (!)LASERS(!)"
				},
				{
					"use_floating_healthbars",
					"ATOMClient:CVarCallback(\"use_floating_healthbars\", \"USE_FLOATING_HP_BAR\", (%% or nil), false, true, false)",
					"size of them floating health bars"
				},
				{
					"floating_healthbar_size",
					"ATOMClient:CVarCallback(\"floating_healthbar_size\", \"HEALTHBAR_SIZE\", (%% or nil), true, false, false)",
					"size of them floating health bars"
				},
				--{
				--	"doors_instant_react",
				--	"ATOMClient:CVarCallback(\"a_doors_instant_react\", \"DOORS_LOCAL_USE\", %%, true, false, false)",
				--	"Enables or disables doors opening on client for instant reactions.\n[1] = On, [0] = Off."
				--},
			};
			
			local addCom = System.AddCCommand;
			
			for i, command in pairs(commands) do
				addCom("a_" .. command[1], command[2], command[3]);
			end;
			
			addCom("fps_limit", [[ATOMClient:CVarCallback("fps_limit", "THE_FPS_LIMIT", (%% or nil), true, false, false);]], "Sets limit for your FPS\n<=0 disables the fps limit");
			
			addCom("say", [[
				doSay(%%);
			]], "send a chat message to yourself"); 
			
			addCom("saytoall", [[
				doSayToAll(%%);
			]], "Send a Chat message to all players $4(!)");
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AddHitMarker = function(self, hier, entfernung)
			--Msg(0, "%f",entfernung)
			if (entfernung < 80) then
				if (#HIT_MARKERS >= 5) then
					-- remove last maybe ?
				end
				
				-- markers stay for 1s
				local hitMarkerTime = 1
				
				HIT_MARKERS[ #HIT_MARKERS+1 ] = { dort = hier, zeit = _time, lebensdauer = hitMarkerTime, expire = _time + hitMarkerTime }
			end
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateHitMarkers = function(self)
			if (#HIT_MARKERS >= 1) then
				local g_localActorPos = g_localActor:GetPos()
				for i = 1, #HIT_MARKERS do
					--Msg(0, "id = %d", i)
					local marker = HIT_MARKERS[i]
					local r = false
					if (marker and _time < marker.expire) then
						local entfernung = calcDist(marker.dort, g_localActorPos)
						if (entfernung <= 80) then
							-- alpha = ((x - y) / z) * -1
							local alpha = ((marker.expire - _time) / marker.lebensdauer) * 1
							--Msg(0, (entfernung / 100) * 0.5)
							if (alpha > 0) then
								-- (entfernung / 100) * 10
								System.DrawLabel( marker.dort, 1.5, "$4(X)", 1, 0, 0, alpha ); -- only one label can be drawn at a time :c
							end
							
						else
							r = true
						end
					else -- ?
						table.remove(HIT_MARKERS, i)
						--HIT_MARKERS[i] = nil
						break
					end
					
					if (r) then
						--HIT_MARKERS[i] = nil
						table.remove(HIT_MARKERS, i)
					end
				end
			end
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnHit = function(self, player, hit)	
		
			if (not hit.shooter or not hit.target) then
				return
			end
		
			local ht = hit.type
			
			if (ht == "lockpick" or ht == "repair") then
				return
			end
		
			local idShooterIsLA = hit.shooterId == g_localActorId
			local idTargetIsLA  = hit.targetId  == g_localActorId
			local idSelfHit		= idShooterIsLA and idTargetIsLA
			
			local idIsBullet = string.find(tostring(ht), "bullet")
			local idIsMelee = ht == "melee"
			local idExplosion = hit.explosion
			local idHeadshot = g_gameRules:IsHeadShot(hit)
			local idWeaponClass = hit.weapon and hit.weapon.class
			
			if (idShooterIsLA and not idSelfHit and idIsBullet) then
				
				local s = "sounds/physics:bullet_impact:mat_armor"
				if (idHeadshot) then
					s = "sounds/physics:bullet_impact:helmet_feedback"
				end
				g_localActor:PlaySoundEvent(s, g_Vectors.v000, g_Vectors.v010, SOUND_2D, SOUND_SEMANTIC_PLAYER_FOLEY);
				
				if (not idTargetIsLA and not idIsMelee) then
					self:AddHitMarker(hit.pos, calcDist(g_localActor:GetPos(), hit.pos))
				end
			end
			
			if (idIsBullet) then
				
				-- MAYBE BLOOD POOL CAUSES CRASH ?? TOO MANY RAY CHECKS ETC ??????????? IM CONFUSED
				-- EDIT: IT DOES-,, GAWD DAMN
				-- No more blood pools i guess ;-;
				--if (player.BPT) then
				--	Script.KillTimer(player.BPT)
				--end
				--player.BPT = Script.SetTimer(300, function() player:BloodPool() end)
				
				
				player:BloodSplat(hit)
				player:Bleed(hit)
				
				local d = hit.dir; 
				d.x = d.x * -1.0;
				d.y = d.y * -1.0;
				d.z = d.z * -1.0;
				if (idHeadshot) then
					local blood_scale = 0.75
					if (idWeaponClass == "DSG1" or idWeaponClass == "GaussRifle") then
						blood_scale = idWeaponClass == "DSG1" and 2 or 3
					end
					Particle.SpawnEffect("bullet.hit_flesh.c", hit.pos, d, blood_scale);
				else
					Particle.SpawnEffect("bullet.hit_flesh.armor", hit.pos, d, 0.5);
				end
			end
			
			if (idIsMelee) then

			else
			
			end
			--[[
			local shooter = hit.shooter;
			local target = hit.target;
			
			player.HitTime = _time;
			player.MusicInfo = player.MusicInfo or {}
			
			local armor = player.actor:GetArmor();
			local hs = g_gameRules:IsHeadShot(hit);
			
			player.MusicInfo.headshot = hs;
			player:LastHitInfo(player.lastHit, hit);
			
			if (ht:find("bullet")) then
				if (not player:IsBleeding()) then
					player:SetTimer(BLEED_TIMER, 0);
				end
				if (hit.damage > 10) then
					if (shooter and shooter.id == g_localActorId) then
						local s = (armor or 100) > 10 and "armor" or "flesh";
						player:PlaySoundEvent((hs and"sounds/physics:bullet_impact:headshot_feedback_fp"or CUSTOM_HIT_SOUNDS and"sounds/physics:bullet_impact:helmet_feedback"or"sounds/physics:bullet_impact:mat_" .. s .. "_fp"), g_Vectors.v000, g_Vectors.v010, SOUND_2D, SOUND_SEMANTIC_PLAYER_FOLEY);
					end	
					--if (armor > 10) then
						local d = hit.dir; 
						d.x = d.x * -1.0;
						d.y = d.y * -1.0;
						d.z = d.z * -1.0;
						Particle.SpawnEffect("bullet.hit_flesh.armor", hit.pos, d, 0.5);
					--end
				end
				player:WallBloodSplat(hit);
				if (self.UseHitSounds) then
					self:HitSounds(player, hit);
				end
			end
			local shakeAmount = tonumber(System.GetCVar("cl_hitShake"));
			local cSD = 0.35;
			local cSF = 0.15;
			if (ht == "melee") then
				player.lastMelee = 1;
				player.lastMeleeImpulse = hit.damage * 2;
				shakeAmount = 33;
				cSF = 0.2;
			else
				player.lastMelee = nil;
			end
			if (player.actor:GetHealth() and player.actor:GetHealth() <= 0) then
				return;
			end
			if (target and target.id == g_localActorId) then
				player.actor:CameraShake(shakeAmount, cSD, cSF, g_Vectors.v000);
				player.viewBlur = 0.5;
				player.viewBlurAmt = tonumber(System.GetCVar("cl_hitBlur"));
				--Msg(0, "HIT SHAKE!!!");
			elseif (target and target.id ~= g_localActorId and (hit.target.actor:GetHealth()-hit.damage<=0 or hit.target:IsDead())) then
				--Msg(0, "pc=%d",g_gameRules.game:GetPlayerCount(true))
				if (#System.GetEntitiesByClass("Player") == 2 and CRYMP_CLIENT) then
					if (not SLOWMO_TIMER) then
						--CPPAPI.FSetCVar("time_scale", "0.4");
						--SLOWMO_TIMER = _time;
					end;
				end;
			end;
			--]]
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		--[[
		ATOMClient.OnKill = function(self, player, shooter, weapon, melee, hs, lel, lulz)
			Msg(0, "KILL :D")
			if (player and shooter and weapon) then
				if (player.id ~= shooter.id and (weapon.class == "GaussRifle" or weapon.class == "DSG1") and hs) then
					player:AddImpulse(-1, player.actor:GetHeadPos(), shooter:GetDirectionVector(), 10000, 1);
				end;
			end;
		end;
		--]]
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnSpawn = function(self, spawn, entity)
			if (entity.id == g_localActorId) then
				if (g_localActor.SuperSpeed) then
					self:HandleEvent(eCE_EnableSuperSpeed, g_localActor.SuperSpeed);
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HookEntities = function(self)
			------------------------------------------------------------
			if (not Lightning) then
				Script.ReloadScript("Scripts/Entities/Render/Lightning.lua");
			end
			self.Patcher:Add("Lightning", function(self)
				self.bStriking = 0;
				self.light_fade = 0;
				self.light_intensity = 0;
				self.vStrikeOffset = {x=0,y=0,z=0};
				self.vSkyHighlightPos = {x=0,y=0,z=0};

				self:CheckName();

				--self:NetPresent(0);
				self.bActive = self.Properties.bActive;
				self:ScheduleNextStrike();
				
				--Msg(0, "INIT!");
			end, "OnInit");
			------------------------------------------------------------
			self.Patcher:Add("Lightning", function(self)
				local name = self:GetName();
				Msg(1, "Lightning: %s!!", name);
				
				local intensity, radius, effect, effectScale, effectScaleVariation, _highAtten, _highColor, _highMult, _highVertical, sound, delay, delayVar, dur, tunderDelay, tunderVar, fuck = 
				name:match(
					"(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)"
				);
				
				local props = self.Properties;
				local props_timing = self.Properties.Timing;
				local props_effect = self.Properties.Effects;
				
				-- Effects
				
				if (intensity and tonumber(intensity)) then
					props_effect.LightIntensity = tonumber(intensity);
				end;
				if (radius and tonumber(radius)) then
					props_effect.LightRadius = tonumber(radius);
				end;
				if (effect and #effect>=3) then
					props_effect.ParticleEffect = effect;
					Msg(0, "EFFECT:%s",effect)
				end;
				if (effectScale and tonumber(effectScale)) then
					props_effect.ParticleScale = tonumber(effectScale);
				end;
				if (effectScaleVariation and tonumber(effectScaleVariation)) then
					props_effect.ParticleScaleVariation = tonumber(effectScaleVariation);
				end;
				if (effectScaleVariation and tonumber(effectScaleVariation)) then
					props_effect.ParticleScaleVariation = tonumber(effectScaleVariation);
				end;
				
				-- Color
				
				if (_highAtten and tonumber(_highAtten)) then
					props_effect.SkyHighlightAtten = tonumber(_highAtten);
				end;
				if (_highMult and tonumber(_highMult)) then
					props_effect.SkyHighlightMultiplier = tonumber(_highMult);
				end;
				if (_highVertical and tonumber(_highVertical)) then
					props_effect.SkyHighlightVerticalOffset = tonumber(_highVertical);
				end;
				if (_highColor and _highColor:match("(.*)_(.*)_(.*)")) then
					local c_x, c_y, c_z = _highColor:match("(.*)_(.*)_(.*)");
					props_effect.color_SkyHighlightColor = {
						x = tonumber(c_x) or 1,
						y = tonumber(c_y) or 1,
						z = tonumber(c_z) or 1,
					};
				end;
				
				-- Sound
					Msg(0, "sound:%s",sound)
				
				if (sound and #sound>3) then
					props_effect.sound_Sound = sound;
				end;
		
				-- Timing
		
				if (delay and tonumber(delay)) then
					props_timing.fDelay = tonumber(delay);
				end;
				if (delayVar and tonumber(delayVar)) then
					props_timing.fDelayVariation = tonumber(delayVar);
				end;
				if (dur and tonumber(dur)) then
					props_timing.fLightningDuration = tonumber(dur);
				end;
				if (tunderDelay and tonumber(tunderDelay)) then
					props_timing.fThunderDelay = tonumber(tunderDelay);
				end;
				if (tunderVar and tonumber(tunderVar)) then
					props_timing.fThunderDelayVariation = tonumber(tunderVar);
				end;
				
				self.Properties.Effects = props_effect;
				self.Properties.Timing  = props_timing;
				
				Msg(1, "LIGHTNING SYNCHED!");
			
			end, "CheckName");
			------------------------------------------------------------
			if (not InteractiveEntity) then
				Script.ReloadScript("Scripts/Entities/Others/InteractiveEntity.lua");
			end
			self.Patcher:Add("InteractiveEntity", {
				fUseDelay = 0,
				fCoolDownTime = 1,
				bEffectOnUse = 1,
				bSoundOnUse = 1,
				bSpawnOnUse = 1,
				bChangeMatOnUse = 1,
			}, "OnUse", "Properties", nil, true);
			------------------
			self.Patcher:Add("InteractiveEntity", 0, "bTwoState", "Properties", nil, true);
			------------------
			InteractiveEntity.Properties.SpawnEntity.iSpawnLimit = 100; -- :D
			------------------
			self.Patcher:Add("InteractiveEntity", function(self, user, idx)
				local UseProps=self.Properties.OnUse;
				if (self.bCoolDown==0) then
					if (self.iDelayTimer== -1) then
						if (UseProps.fUseDelay>0) then
							self.iDelayTimer=Script.SetTimerForFunction(UseProps.fUseDelay*1000,"InteractiveEntity.Use",self);
						else
							self:Use(user, 1);
							ATOMClient:ToServer(eTS_Spectator, eCR_Interactive);
						end;
					end;
				end;	
			end, "OnUsed");	
			------------------
			self.Patcher:Add("InteractiveEntity", function(self, user)
				if (self:GetState()~="Destroyed") then
					return 1;
				else
					return 0;
				end
			end, "IsUsable");
			------------------
			self.Patcher:Add("InteractiveEntity", function(self, idx)
				return "Order Drink"
			end, "GetUsableMessage");
			------------------------------------------------------------
			-- SpawnPoint
			------------------------------------------------------------
			self.Patcher:Add("SpawnPoint", function(self, entity)
				ATOMBroadcastEvent(self, "Spawn");
				if (ATOMClient and ATOMClient.OnSpawn) then
					ATOMClient:OnSpawn(self, entity);
				end;
			end, "Spawned");
			------------------------------------------------------------
			-- CustomAmmoPickupLarge
			------------------------------------------------------------
			CustomAmmoPickupLarge.SyncNameParams = function(self)
				local name = self:GetName();
				if (not name) then
					return;
				end;
				local model, sound, soundVol, effect, scale, trash = name:match("(.*)|(.*)+(.*)|(.*)|(.*)|(.*)");
				if (model and string.len(model) > 3) then
					self:LoadObject(0, model);
					self:DrawSlot(0, 1);
				end;
				if (sound and string.len(sound) > 3) then
					self.soundId = self:PlaySoundEvent(sound, g_Vectors.v000, g_Vectors.v010, SOUND_2D, SOUND_SEMANTIC_PLAYER_FOLEY); --, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
					if (soundVol and tonumber(soundVol)) then
						Sound.SetSoundVolume(self.soundId, tonumber(soundVol));
					end;
				end;
				if (effect and string.len(effect) > 3) then
					Msg(5, "Scale = %d", tonumber(scale))
					local ename, pulse = effect:match("(.*)+(.*)");
					if (pulse) then
						Msg(5, "Pulse period found in Particle name, OK lol");
						self.effectId = self:LoadParticleEffect(-1, ename, { PulsePeriod = tonumber(pulse), Scale = tonumber(scale or 1)});
					else
						self.effectId = self:LoadParticleEffect(-1, effect, { Scale = tonumber(scale or 1)});
					end;
					--self:SetSlotWorldTM(self.effectId, self:GetPos(), vecScale(self:GetDirectionVector(), -1));
				end;
				Msg(5, "Synched Name params, %s, %s, %s", tostring(model), tostring(sound), tostring(effect));
			end
			--**********************************************************
			-- AnimDoor
			--**********************************************************
			self:CheckEntity("AnimDoor", "Scripts/Entities/Doors/AnimDoor.lua");
			------------------
			self.Patcher:Add("AnimDoor", {
				snd_Open 	= "sounds/environment:storage_vs2:door_trooper_open", 
				snd_Close 	= "sounds/environment:storage_vs2:door_trooper_close"
			}, "Sounds", "Properties", nil, true);
			------------------
			self.Patcher:Add("AnimDoor", 1, "bActivatePortal", "Properties", nil, true);
			------------------
			self.Patcher:Add("AnimDoor", { 
				anim_Open 	= "passage_door_open",
				anim_Close 	= "passage_door_closed"
			}, "Animation", "Properties", nil, true);
			------------------
			self.Patcher:Add("AnimDoor", function(self)
			
				local name = self:GetName();
				local object, anim1, anim2, s1, s2, trash = name:match("(.*)|(.*)%+(.*)|(.*)%+(.*)|(.*)");
				if (object) then
					self.Properties.object_Model = object;
				end;
				
				if (anim1 and string.len(anim1) > 3) then
					AnimDoor.Properties.Animation.anim_Open = anim1;
				end;
				
				if (anim2 and string.len(anim2) > 3) then
					AnimDoor.Properties.Animation.anim_Close = anim2;
				end;
				
				if (s1 and string.len(s1) > 3) then
					AnimDoor.Properties.Sounds.snd_Open = s1;
				end;
				
				if (s2 and string.len(s2) > 3) then
					AnimDoor.Properties.Sounds.snd_Close = s2;
				end;
				
				Msg(5, "Anim door got: %s, %s, %s, %s, (%s)", tostring(object), tostring(anim1), tostring(anim2), tostring(s1), tostring(s2), tostring(trash));
			
				if (self.portal) then
					System.ActivatePortal(self:GetWorldPos(), 0, self.id);
				end

				self.bLocked 		= false;
				self.portal 		= self.Properties.bActivatePortal ~= 0;
				self.bUseSameAnim 	= self.Properties.Animation.anim_Close == "";

				local model 		= self.Properties.object_Model;
				
				if (model ~= "") then
					self:LoadObject(0,model);
				end

				self.bNoAnims = self.Properties.Animation.anim_Open == "" and self.Properties.Animation.anim_Close == "";
				
				self:PhysicalizeThis();
				self:DoStopSound();
				
				-- state setting, closed
				self.nDirection = -1;
				self.curAnim 	= "";
				
				if (AI) then
					AI.SetSmartObjectState( self.id, "Closed" );
				end
				if (self.Properties.bLocked ~= 0) then
					self:Lock();
				end
			end, "Reset", nil, true);
			------------------
			self.Patcher:Add("AnimDoor", function(self, doAction)
				if (doAction == nil) then
					if (ATOMClient ~= nil) then
						ATOMClient:ToServer(eTS_Spectator, 10);
					end;
				else
					self:DoPlayAnimation(1,nil,true);
				end;
			end, "Event_Open");
			------------------
			self.Patcher:Add("AnimDoor", function(self, doAction)
				if (doAction == nil) then
					if (ATOMClient ~= nil) then
						ATOMClient:ToServer(eTS_Spectator, 11);
					end;
				else
					self:DoPlayAnimation(-1,nil,true);
				end;
			end, "Event_Close");
			------------------
			-- Door
			------------------
			self:CheckEntity("Door", "Scripts/Entities/Doors/Door.lua");
			------------------
			self.Patcher:Add("Door", {
			
				soclasses_SmartObjectClass 	= "Door",
				fileModel 					= "Objects/library/barriers/concrete_wall/door.cgf",
				
				Sounds = {
					soundSoundOnMove		= "sounds/environment:doors:door_metal_sheet_open",
					soundSoundOnStop		= "sounds/environment:doors:door_metal_sheet_close",
					soundSoundOnStopClosed 	= "",
					fVolume 				= 200,
					fRange 					= 50
				},		
				Rotation = {
					fSpeed 					= 200.0,
					fAcceleration 			= 500.0,
					fStopTime 				= 0.125,
					fRange 					= 90,
					sAxis 					= "z",
					bRelativeToUser 		= 0, -- Always open to the same Side, prevents bugs
					sFrontAxis				= "y"
				},
				Slide = {
					fSpeed	 				= 2.0,
					fAcceleration 			= 3.0,
					fStopTime				= 0.5,
					fRange	 				= 0,
					sAxis		 			= "x"
				},
				fUseDistance 	= 10,
				bLocked 		= 0,
				bSquashPlayers 	= 1,
				bActivatePortal = 0
				
			}, "Properties", nil, nil, true);
			------------------
			-- OnUsed
			------------------
			self.Patcher:Add("Door", function(self, user)	
				--local distance = calcDist(self, user);
				--if (distance > 10) then
				--	return false;
				--	Msg(0, "distance to Door.OnUsed() (10<%f)", distance);
				--end;
				if (not user or user.id ~= g_localActor.id) then -- Possible manipulation
					if (ATOMClient) then
						ATOMClient:ToServer(eTS_Spectator, eAC_Door);
					end;
					Msg(0, "Not local actor to Door.OnUsed() (%s)", tostring(user));
				--	return false;
				end;
				--if (DOORS_LOCAL_USE and DOORS_LOCAL_USE == 1 and not CLIENT_DISABLED) then
				--	self:Open(self.action~=DOOR_OPEN);
				--end;
				Msg(1, "requested to open door with user %s", user:GetName());
				self.server:SvRequestOpen(user.id, self.action ~= DOOR_OPEN);
			end, "OnUsed");
			------------------
			self.Patcher:Add("Door", false, "isreset");
			------------------
			self.Patcher:Add("Door", function(self)
				--Msg(0, "HELLO, DO PHYSICALIZE!!")
				self:OnReset();
				
				if (self.currModel ~= self.Properties.fileModel) then
					CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", false);
					
					local model = self.Properties.fileModel;
					self:LoadObject	(0, model);
					self:Physicalize(0, PE_RIGID, self.PhysParams);
					
					CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", true);			
				end;

				if (tonumber(self.Properties.bSquashPlayers)==0) then
					self:SetPhysicParams(PHYSICPARAM_FLAGS, {flags_mask=pef_cannot_squash_players, flags=pef_cannot_squash_players});
				end;
				
				self.currModel = self.Properties.fileModel;
			end, "DoPhysicalize");
			------------------
			self.Patcher:Add("Door", function(self, x, y)
				--Msg(0, "self=%s, x=%s, y=%s", tostring(self), tostring(x), tostring(y))
				local fileModel, toUser, S1, S2, S3, Rotate, Speed, Slide, trash = self:GetName():match("(.*)|(.*)|(.*)%+(.*)%+(.*)|(.*)%+(.*)%+(.*)|(.*)");
				
				if (fileModel) then
					self.Properties.fileModel = fileModel;
				end;
				
				if (toUser) then
					self.Properties.Rotation.bRelativeToUser = toUser;
				end;

				if (S1 and string.len(S1) > 3) then
					self.Properties.Sounds.soundSoundOnMove 		= S1;
				end;
				if (S2 and string.len(S2) > 3) then
					self.Properties.Sounds.soundSoundOnStop 		= S2;
				end;
				if (S3 and string.len(S3) > 3) then
					self.Properties.Sounds.soundSoundOnStopClosed 	= S3;
				end;
					
				if (Rotate) then
					self.Properties.Rotation.fRange 	= tonumber(Rotate);
				end;
					
				if (Slide) then
					Msg(5, "Door slide: %s", tostring(Slide))
					local slideRange, slideAxis = Slide:match("(.*)_(.*)");
					
					Msg(5, "Door slide RANGE, AXIS: %s, %s", tostring(slideRange), tostring(slideAxis))
					if (slideRange) then
						self.Properties.Slide.fRange	= tonumber(slideRange);
					end;
					if (slideAxis) then
						self.Properties.Slide.sAxis 	= slideAxis;
					end;
				end;
					
				if (Speed) then
					self.Properties.Rotation.fSpeed 	= tonumber(Speed);
				end;
				
				Msg(5, "Door Params: %s, %s, %s, %s, %s, %s", tostring(S1), tostring(S2), tostring(S3), tostring(Rotate), tostring(Speed), tostring(Slide))
				
				self:Reset();
			end, "OnReset", nil, true);
			------------------
			self.Patcher:Add("Door", function(self, user)
				return (self.action == 1 and "Close" or "Knock"); --(self.action == 1 and "mach ZU vallah" or "mach AUF vallah");
			end, "GetUsableMessage");
			------------------
			--**********************************************************
			-- GUI
			--**********************************************************
			self:CheckEntity("GUI", "Scripts/Entities/Others/GUI.lua");
			---------------------------
			GUI.Properties.objModel 				= "objects/library/storage/barrels/rusty_metal_barrel_a.cgf";
			GUI.Properties.bRigidBody				= 1;
			GUI.Properties.bResting 				= 0;
			GUI.Properties.bUsable					= nil;
			GUI.Properties.bPhysicalized			= 1;
			GUI.Properties.fMass					= 35;
			GUI.Properties.GUIMaterial				= "material_girl";
			GUI.Properties.GUIUsageDistance			= 1.5;
			GUI.Properties.GUIUsageTolerance		= 0.75;
			GUI.Properties.GUIWidth					= 512;
			GUI.Properties.GUIHeight				= 512;
			GUI.Properties.GUIDefaultScreen			= "egirls";
			GUI.Properties.GUIMouseCursor			= "egirl";
			GUI.Properties.GUIPreUpdate				= 1;
			GUI.Properties.GUIMouseCursorSize		= 18;
			GUI.Properties.GUIHasFocus				= 0;
			GUI.Properties.color_GUIBackgroundColor	= { 0, 0, 0 };
			GUI.Properties.fileGUIScript			= "egirl()";
			GUI.Properties.bStatic					= 0;
			GUI.Properties.fViewDist				= 50; -- GUI default (i think)
			GUI.Properties.fMass					= 50; -- GUI default (i think)
			GUI.Properties.fDistance				= 300; -- GUI default (i think)
			GUI.Properties.sParticleEffect			= "egirls.egirls.egirl";
			---------------------------
			--		OnSpawn
			---------------------------
			self.Patcher:Add("GUI", function(self) 
				self:OnReset()
				Msg(5, "GUI:OnSpawn()")
			end, "OnSpawn", nil);
			---------------------------
			--		OnSpawn
			---------------------------
			self.Patcher:Add("GUI", function(self, user) 
				if (not user or not user.actor or not user.actor:IsPlayer()) then
					return false;
				end;
				Msg(5, "GUI:CanUse()")
				return calcDist(self:GetPos(), user:GetPos()) < 5;
			end, "CanUse");
			---------------------------
			--		OnReset
			---------------------------
			self.Patcher:Add("GUI", function(self) -- In case of thievery, please note that server will require the same scripts for proper physics synch.
				
				--Msg(0, "test called!")
				
				if (ATTACHED_ITEMS[self.id]) then
					return; --self:DestroyPhysics();
				end;
				
				Msg(5, "GUI:OnReset()");
				
				self.Properties.bUsable = nil;
				
				self:SetUpdatePolicy(ENTITY_UPDATE_VISIBLE);
				
				
				local modelName, bStatic, fMass, fDistance, particleEffect, garbage = self:GetName():match("(.*)|(.*)+(.*)+(.*)|(.*)|(.*)");
				
				local t = (modelName and modelName:sub(-4) or "");
				if (modelName and (t == ".cga" or t == ".cgf" or t == ".chr" or t == ".cdf")) then 
					self.Properties.objModel = modelName;
					Msg(5, "Got model, %s", self.Properties.objModel);
				end 
				if (fMass) then
					self.Properties.fMass = tonumber(fMass);
				end;
				if (bStatic) then
					self.Properties.bStatic = tonumber(bStatic);
				end;
				if (fDistance) then
					self.Properties.fDistance = tonumber(fDistance);
				end;
				if (particleEffect and string.len(particleEffect) > 3) then
					self.Properties.sParticleEffect = tostring(sParticleEffect);
				end;
				
				Msg(5, "GUI: Name Params: %s, %s, %s, %s, %s (%s)", tostring(modelName), tostring(bStatic), tostring(fMass), tostring(fDistance), tostring(particleEffect), tostring(garbage));
				
				local model = self.Properties.objModel;
				self:LoadObject(0, model);
				self:DrawSlot(0, 1);
				if (tonumber(self.Properties.bPhysicalized) ~= 0) then
					local physParam = {
						mass = self.Properties.fMass;
					};
					self:Physicalize(0, (self.Properties.bStatic == 1 and PE_STATIC or PE_RIGID), physParam);
					if (tonumber(self.Properties.bResting) ~= 0) then
						self:AwakePhysics(0);
					else
						self:AwakePhysics(1);
					end;
				end;
				
				local effect = self.Properties.sParticleEffect;
				if (effect and string.len(effect) >= 6) then -- >=6 in case of a.a.a
					if (ATOMClient ~= nil) then
						Script.SetTimer(1, function()
							ATOMClient:HandleEvent(eCE_LoadEffect, self.id, effect);
						end);
					end;
				end;
				
				local dist = self.Properties.fDistance;
				if (dist and self.SetViewDistRatio) then
					self:SetViewDistRatio(dist);
				end;
				
				MakePickable(self)

			end, "OnReset", nil, true);
			-------------------------
			self.Patcher:Add("GUI", function(self, user)	  
				return self.Properties.bUsable == 1;
			end, "IsUsable");
			-------------------------
			for i, v in pairs({
				"OnDestroy",
				"SetUI",
				"CreateUI",
				"DestroyUI",
				"RenderUI",
				"DefaultScreen",
				"OnStartUsing",
				"OnStopUsing",
			}) do
				self.Patcher:Add("GUI", null_function, v);
			end;
			MakePickable(GUI)
			--------------------------------------------------
			-- Elevator
			--------------------------------------------------
			self:CheckEntity("Elevator", "Scripts/Entities/Elevators/Elevator.lua");
			self:CheckEntity("ElevatorSwitch", "Scripts/Entities/Elevators/ElevatorSwitch.lua");
			-------------------------
			Elevator.DoPhysicalize = function(self)
				Elevator.SetPropertiesFromName(self);
				if (self.currModel ~= self.Properties.objModel) then
					CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", false); -- <-- what is this
					self:LoadObject( 0,self.Properties.objModel );
					self:Physicalize(0,PE_RIGID,{mass=0});
					CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", true);-- <-- what is this
				end
				self.currModel = self.Properties.objModel;
			end
			--name = "Objects/natural/plants/big_leave_plant/big_leave_plant_med_a.cgf|1+2+2.25+0|1+z+1+0.75|sounds/environment:soundspots:elevator_fleet_run+sounds/environment:soundspots:elevator_fleet_start+sounds/environment:soundspots:elevator_fleet_stop|" .. g_utils:SpawnCounter(),
			-------------------------
			Elevator.SetPropertiesFromName = function(self)
				local name = self:GetName();
				local obj, dest, floorCunt, floorHeight, floorInit, accel, axis, speed, stopTime, sndMove, sndStart, sndStop, trash = name:match(
					"(.*)|(.*)+(.*)+(.*)+(.*)|(.*)+(.*)+(.*)+(.*)|(.*)+(.*)+(.*)|(.*)"
				);
				-- model
				if (obj) then
					self.Properties.objModel = obj;
				end;
				-- moving
				if (dest and tonumber(dest)) then
					self.Properties.nDestinationFloor = tonumber(dest);
				end;
				if (floorCunt and tonumber(floorCunt)) then
					self.Properties.nFloorCount = tonumber(floorCunt);
				end;
				if (floorHeight and tonumber(floorHeight)) then
					self.Properties.fFloorHeight = tonumber(floorHeight);
				end;
				if (floorInit and tonumber(floorInit)) then
					self.Properties.nInitialFloor = tonumber(floorInit);
				end;
				-- slide
				if (accel and tonumber(accel)) then
					self.Properties.Slide.fAcceleration = tonumber(accel);
				end;
				if (axis and (axis=="x" or axis=="z" or axis=="y")) then
					self.Properties.Slide.sAxis = axis;
				end;
				if (speed and tonumber(speed)) then
					self.Properties.Slide.fSpeed = tonumber(speed);
				end;
				if (stopTime and tonumber(stopTime)) then
					self.Properties.Slide.fStopTime = tonumber(stopTime);
				end;
				-- sounds
				if (sndMove and string.len(sndMove) > 3) then
					self.Properties.Sounds.soundSoundOnMove = sndMove;
				end;
				if (sndStart and string.len(sndStart) > 3) then
					self.Properties.Sounds.soundSoundOnStart = sndStart;
				end;
				if (sndStop and string.len(sndStop) > 3) then
					self.Properties.Sounds.soundSoundOnStop = sndStop;
				end;
				Msg(1, "Elevator was reset!");
			end
			-------------------------
			for i,v in ipairs(System.GetEntitiesByClass("Elevator")or{})do
				v.SetPropertiesFromName = Elevator.SetPropertiesFromName;
				v.DoPhysicalize 		= Elevator.DoPhysicalize;
				-- THIS IS NOT SAFE!!!!!
				if (string.len(v:GetName()) > 30) then
					-- safe to assume custom elevators have awfully long names
					v:Reset();
				end;
			end;
			-- connect switches using entity:CreateLink('up' or 'down') and
			-- then entity:SetLinkTarget(kek.id, 'up' or 'down')
			-- must be up/down.
			-------------------------
			ElevatorSwitch.DoPhysicalize = function(self)
				ElevatorSwitch.SetPropertiesFromName(self);
				if (self.currModel ~= self.Properties.objModel) then
					self:LoadObject( 0,self.Properties.objModel );
					self:Physicalize(0,PE_RIGID, {mass=0});
				end
				
				self.currModel = self.Properties.objModel;
			end
			--name = "Objects/natural/plants/big_leave_plant/big_leave_plant_med_a.cgf|1+2+2.25+0|1+z+1+0.75|sounds/environment:soundspots:elevator_fleet_run+sounds/environment:soundspots:elevator_fleet_start+sounds/environment:soundspots:elevator_fleet_stop|" .. g_utils:SpawnCounter(),
			--name = "objects/library/architecture/aircraftcarrier/props/consoles/elevator_console.cgf|0+1|Close Bunker|Sounds/environment:soundspots:elevator_hangar_button|" .. g_utils:SpawnCounter(),
			-------------------------
			ElevatorSwitch.SetPropertiesFromName = function(self)
				local name = self:GetName();
				local obj, delay, floor, useMsg, sndUse, trash = name:match(
					"(.*)|(.*)+(.*)|(.*)|(.*)|(.*)"
				);
				-- model
				if (obj) then
					self.Properties.objModel = obj;
				end;
				-- moving
				if (delay and tonumber(delay)) then
					self.Properties.fDelay = tonumber(delay);
				end;
				if (floor and tonumber(floor)) then
					self.Properties.nFloor = tonumber(floor);
				end;
				-- use
				if (useMsg) then
					self.Properties.szUseMessage = useMsg;
				end;
				-- sound
				if (sndUse) then
					self.Properties.Sounds.soundSoundOnPress = sndUse;
				end;
				
				Msg(1, "ElevatorSwitch was reset!");
			end
			-------------------------
			for i,v in ipairs(System.GetEntitiesByClass("ElevatorSwitch")or{})do
				v.SetPropertiesFromName = ElevatorSwitch.SetPropertiesFromName;
				v.DoPhysicalize 		= ElevatorSwitch.DoPhysicalize;
				-- THIS IS NOT SAFE!!!!!
				if (string.len(v:GetName()) > 30) then
					-- safe to assume custom elevators have awfully long names
					v:Reset();
				end;
			end;
			--------------------------------------------------
			-- BasicEntity
			--------------------------------------------------
			self:CheckEntity("BasicEntity", "Scripts/Entities/Physics/BasicEntity.lua");
			-------------------------
			BasicEntity.Properties = {
				soclasses_SmartObjectClass 	= "",
				bAutoGenAIHidePts 			= 0,
				
				object_Model 				= "Objects/box.cgf",
				object_ModelFrozen 			= "",
				
				sParticleEffect				= "",
				fDistance					= 300,
				bStatic						= 0,
				
				Physics = {
					bPhysicalize 		= 1, -- True if object should be physicalized at all.
					bRigidBody 			= 1, -- True if rigid body, False if static.
					bPushableByPlayers 	= 1,
				
					Density = -1,
					Mass 	= -1,
				},
				
				bFreezable 	= 1,
				bCanShatter = 1
			};
			-------------------------
			BasicEntity.OnSpawn = function(self)
				self.bRigidBodyActive = 1;
				self:SetFromProperties();	
			end;
			-------------------------
			BasicEntity.SetPropertiesFromName = function(self)
			
				if (CLIENT_DISABLED) then
					return;
				end;
				
				Msg(5, "BasicEntity:SetPropertiesFromName()");

				local modelName, bHasPhys, fMass, fDistance, particleEffect, garbage = self:GetName():match("(.*)|(.*)+(.*)+(.*)|(.*)|(.*)");
				
				local t = (modelName and modelName:sub(-4) or "");
				if (modelName and (t == ".cga" or t == ".cgf" or t == ".chr" or t == ".cdf")) then 
					self.Properties.object_Model = modelName;
					Msg(5, "Got model, %s", self.Properties.object_Model);
				end 
				if (fMass) then
					self.Properties.Physics.fMass = tonumber(fMass);
				end;
				if (bHasPhys) then
					-- doesnt worik in dx9 :c
					Msg(3, "PHYSICS: %d", tonumber(bHasPhys)or-1);
					self.Properties.Physics.bRigidBody = tonumber(bHasPhys);
					self.Properties.Physics.bPhysicalize = tonumber(bHasPhys);
					self.Properties.Physics.bPushableByPlayers = tonumber(bHasPhys);
				end;
				if (fDistance) then
					self.Properties.fDistance = tonumber(fDistance);
				end;
				if (particleEffect and string.len(particleEffect) > 3) then
					self.Properties.sParticleEffect = tostring(sParticleEffect);
				end;
				
				Msg(5, "BasicEntity: Name Params: %s, %s, %s, %s, %s (%s)", tostring("seeabove"), tostring(bHasPhys), tostring(fMass), tostring(fDistance), tostring(particleEffect), tostring(garbage));
				
				local effect = self.Properties.sParticleEffect;
				if (effect and string.len(effect) >= 6) then -- >=6 in case of a.a.a
					if (ATOMClient ~= nil) then
						Script.SetTimer(1, function()
							ATOMClient:HandleEvent(eCE_LoadEffect, self.id, effect);
						end);
					end;
				end;
				
				local dist = self.Properties.fDistance;
				if (dist and self.SetViewDistRatio) then
					self:SetViewDistRatio(dist);
				end;
			end;
			-------------------------
			BasicEntity.SetFromProperties = function(self)
				BasicEntity.SetPropertiesFromName(self);
				
				local Properties = self.Properties;

				if (Properties.object_Model == "") then
					return;
				end
				
				self.freezable = tonumber(Properties.bFreezable)~=0;
				
				self:LoadObject(0, Properties.object_Model);
				
				if (Properties.object_ModelFrozen ~= "") then
					self.frozenModelSlot = self:LoadObject(-1, Properties.object_ModelFrozen);
					self:DrawSlot(self.frozenModelSlot, 0);
				else
				self.frozenModelSlot = nil;
			  end
				
				if (Properties.Physics.bPhysicalize == 1) then
					self:PhysicalizeThis();
				end

				-- Mark AI hideable flag.
				if (Properties.bAutoGenAIHidePts == 1) then
					self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 0); -- set
				else
					self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 2); -- remove
				end
			end;
			-------------------------
			for i,v in ipairs(System.GetEntitiesByClass("BasicEntity")or{})do
				v.SetPropertiesFromName = BasicEntity.SetPropertiesFromName;
				v.SetFromProperties 	= BasicEntity.SetFromProperties;
				v:SetFromProperties();
			end;
			--------------------------------------------------
			-- AutoTurret
			--------------------------------------------------
			
			self.Patcher:Add("AutoTurret", 5112,  "species",  "Properties");
			self.Patcher:Add("AutoTurret", "tan", "teamName", "Properties");
			self.Patcher:Add("AutoTurret", "objects/weapons/multiplayer/air_unit_radar.cgf",     "objModel",     "Properties");
			self.Patcher:Add("AutoTurret", "objects/weapons/multiplayer/ground_unit_gun.cgf",    "objBarrel",    "Properties");
			self.Patcher:Add("AutoTurret", "objects/weapons/multiplayer/ground_unit_mount.cgf",  "objBase",      "Properties");
			self.Patcher:Add("AutoTurret", "objects/weapons/multiplayer/air_unit_destroyed.cgf", "objDestroyed", "Properties");
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckEntity = function(self, globalName, scriptPath)
			if (not _G[string.lower(tostring(globalName))]) then
				Script.ReloadScript(scriptPath);
			end;
			return true;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.ToServer = function(self, t, p1, p2, p3, p4, p5, p6, p7, p8, ...)
			if (not g_gameRules) then
				return;
			end;
			if (t == eTS_Spectator) then
				return g_gameRules.server:RequestSpectatorTarget(g_localActorId, p1);
			elseif (t == eTS_Chat) then
				return g_game:SendChatMessage(ChatToAll, g_localActorId, g_localActorId, tostring(p1));
			elseif (t == eTS_ChatLua) then
				return g_game:SendChatMessage(ChatToAll, g_localActorId, g_localActorId, "!luaerr [ LUA ] -> " .. tostring(p1));
			--	return System.LogAlways('LUA ERROR: ' .. tostring(p1));
			elseif (t == eTS_Report) then
				local allParams = {
					p1, p2, p3, p4, p5, p6, p7, p8, ...
				};
				local report = "++";
				for i, param in pairs(allParams) do
					report = report .. (i~= 1 and "|" or "") .. param;
				end;
				--Msg(0, "Report: %s", report)
				--return (g_gameRules.class == "InstantAction" and g_game:RenamePlayer(g_localActorId, report) or g_gameRules.server:SvBuyAmmo(g_localActorId, report));
				if (g_gameRules.class == "InstantAction") then
					g_game:RenamePlayer(g_localActorId, report) -- ONLY SUPPORTS STRING UP TO 16 CHARACTERS OR SOME BULLSHIT BRUH (That sucks.)
				else
					g_gameRules.server:SvBuyAmmo(g_localActorId, report)
				end;
				return;
			else
				Msg(0, "Invalid Type to ToServer, %s", tostring(t));
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Add2DText = function(self, p)
			local _id = "2dtext_" .. #ATOM_2D_TEXTS;
			-- ?????? SERVER/CIENT STILL SOMEHOW MANAGES TO BUG THIS
			if (p.bind) then
				for i, v in pairs(ATOM_2D_TEXTS) do
					if (v.Bind and v.Bind == p.bind) then
						Msg(1, "removing old text...");
						table.remove(ATOM_2D_TEXTS, i);
					end;
				end;
			end;
			table.insert(ATOM_2D_TEXTS, {
				ID		= _id,
				Time 	= p.time or -1,
				Color 	= p.color or { 0, 0, 0 },
				Bind 	= p.bind or nil,
				Bind_P	= p.bind_bone or nil,
				Message = p.message or { msg = "empty" },
			});
			return _id;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Remove2DText = function(self, id)
			for i, v in pairs(ATOM_2D_TEXTS) do
				if (v.ID == id) then
					-- table.remove :s, add new tableRemove here (once added)
					table.remove(ATOM_2D_TEXTS, i);
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateFlyingChairs = function(self, frameTime)
			for i, chair in pairs(FLYING_CHAIRS or {}) do
				if (chair.player and chair.target) then
					local bonePos = chair.target:GetBonePos(chair.targetBone);
					--Msg(1, "bonePos=%s",tostring(bonePos))
					if (not bonePos) then
						FLYING_CHAIRS[i] = nil;
						break;
					end;
					if (chair.playerMinusz) then 
						bonePos.z = bonePos.z - chair.playerMinusz; 
					end;
					chair.player:SetWorldPos(bonePos);
					chair.player:SetDirectionVector(chair.target:GetDirectionVector());
				else
					FLYING_CHAIRS[i] = nil;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateFloatingHPBars = function(self, frameTime)
			if (not USE_FLOATING_HP_BAR) then
				return;
			end;
			
			for i, v in pairs(System.GetEntitiesByClass("Player")) do
			
				if ((v.id ~= g_localActorId or v.actorStats.thirdPerson) and _time - ((v.HitTime or 0)) <= 10) then
					
					local hp = v.actor:GetHealth(), v.actor:GetArmor()
					local en = v.actor:GetNanoSuitEnergy()
					
					local hpos = v:GetBonePos("Bip01 head");
					
					hpos.z = hpos.z + 0.8
					
					local dist = calcDist(hpos, System.GetViewCameraPos());
					
					if (dist < 50) then
						if (ATOMClient:CanSeePoint(hpos, v.id)) then
							System.DrawLabel( hpos, math.MAX(3/dist,0.5)*1.3, (hp>0 and"$1["..getLoadingBar(hp,math.MAX(HEALTHBAR_SIZE,1000),"$4").."$1] "or"").."$1["..getLoadingBar(en/2,math.MAX(HEALTHBAR_SIZE,1000),"$5").."$1]", 1,0,0, (50-dist)/50 );
						end;
					end;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateStickyPositions = function(self, frameTime)
			local entity, ang, _pos;
			for i, v in pairs(STICKY_POSITIONS) do
				entity = System.GetEntity(i);
				if (entity) then
					if (not entity.actor or (not entity:IsDead() and entity.actor:GetSpectatorMode()==0)) then
						_pos = v[1];
						if (type(v[1]) == "userdata" and System.GetEntity(v[1])) then
							_pos = System.GetEntity(v[1]):GetPos();
						end;
						entity:SetWorldPos(_pos);
						ang = entity:GetAngles();
						if (not v[4]) then
							if (ang.z<v[2]) then
								entity:SetAngles({
									x = ang.x,
									y = ang.y,
									z = v[2]
								});
							elseif (ang.z>v[3]) then
								entity:SetAngles({
									x = ang.x,
									y = ang.y,
									z = v[3]
								});
							end;
						end;
					else
						STICKY_POSITIONS[i] = nil;
					end;
				else
					STICKY_POSITIONS[i] = nil;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnUpdate = function(self, frameTime)
		
			if ((CLIENT_DISABLED) or (not g_localActor)) then
				return true;
			end;
			
			-- Simple LUA FPS limiter :)
			local fps_limit = THE_FPS_LIMIT;
			if (fps_limit and fps_limit >= 1) then
				local c = os.clock();
				while (LAST_FRAME and (1 / (c - LAST_FRAME) > fps_limit)) do
					c = os.clock();
					-- wait around on this current frame ...
				end;
				LAST_FRAME = c;
			end;
			
			
			-- needs to be called on frame
			if (self.MOREHUD_MSG) then
				System.DrawLabel(add2Vec(CamGirlPos(), vecScale(CamGirlDir(), 3)), 1.3, self.MOREHUD_MSG, 1, 1, 1, 1);
			end;
			
			-- also needs to be called on frame
			if (Remote.OnUpdate) then -- remote added function
				Remote:OnUpdate();
			end;
			
			-----------------------------------------
			-- AND THESE NEED TO BE CALLED ON FRAME TOO1!1!!
			self:UpdateATOMPack(frameTime);
			self:UpdateFlyingChair(frameTime);
			self:Update2DText(frameTime);
			self:UpdateFlyingChairs(frameTime);
			self:UpdateStickyPositions();
			self:UpdateFloatingHPBars();
			self:UpdateHitMarkers();
			-----------------------------------------
			
			local FPS_LIMIT = 1 / CLIENT_FPS_LIMIT; -- 30 fps. like on console.
			local FPS_TIME = _time;
			if (ON_STOLEN_FPS_LIMITER and (FPS_TIME - ON_STOLEN_FPS_LIMITER) < FPS_LIMIT) then
				return;
			end;
			ON_STOLEN_FPS_LIMITER = FPS_TIME;
			
			
			local w = g_localActor.inventory:GetCurrentItem();
			local v = g_localActor.actor:GetLinkedVehicleId();
			if (v) then
				v = System.GetEntity(v);
			end;
			
			if (ALLOW_EXPERIMENTAL ~= false) then -- Fixes SafeWriting-Client Client-Developer Mode breaking this Client.
				ALLOW_EXPERIMENTAL = false;
			end;
			
			
			-------------------
			-- AntiCheat Stuff
			self:CheckWeapon(frameTime);
			self:CheckMovement(frameTime);
			
			-------------------
			-- Other stuff
			self.AASearchLasers:PreUpdateAASearchLaser();
			self:UpdateRealism(frameTime);
			self:UpdateRocketPack(frameTime);
			self:UpdateFPSpec(frameTime);
			self:UpdateAnims(frameTime);
			self:UpdateJets(v,frameTime);
			
			for i, v in pairs(WATER_TANKS or {}) do
				local _v = System.GetEntity(i)
				if (_v and _v:GetDriverId()) then

					local a = System.GetEntity(v:GetDriverId())
					local wp = a.actor:GetHeadPos();
					local d = a.actor:GetHeadDir();
					wp.x = wp.x + d.x * 5.8;
					wp.y = wp.y + d.y * 5.8;
					wp.z  =wp.z + d.z * 5.8;
					_v:SetSlotWorldTM(_v._WS, wp, d);
				else
					if (_v) then
						_v:FreeSlot(_v._WS);
						_v._WS = nil;
					end;
					WATER_TANKS[i] = nil;
				end;
			end;
			
			local stats = g_localActor.actorStats;
			
			if (NEW_DISPLAY_INFO == 1) then
				FPS_INFO = FPS_INFO or { 0, 99999, 0, {}, nil };
				local fps = 1 / System.GetFrameTime();
				if (fps > FPS_INFO[3]) then
					FPS_INFO[3] = fps;
				elseif (fps < FPS_INFO[2]) then
					FPS_INFO[2] = fps
				end;
				FPS_INFO[1] = fps;
				table.insert(FPS_INFO[4], fps); 
				if (#FPS_INFO[4]>100) then
					table.remove(FPS_INFO[4], 1);
				end;
				--if (not FPS_INFO[5] or _time - FPS_INFO[5] >= 1) then
					CryAction.Persistant2DText([[Crysis 1.6156 | ]] .. (System.GetCVar("cl_crymp")and"CryMP"or CPPAPI and "SFWCL"or"Unknown") .. [[, ATOMClient ]] .. self.version .. [[ \nFPS: ]] .. FPS_INFO[1].. [[ (min:]]..FPS_INFO[2]..[[, max:]] ..FPS_INFO[3]..[[, avg:]] ..average(FPS_INFO[4])..[[]], 2, { 1, 1, 1 }, "TextHandle", System.GetFrameTime());
					FPS_INFO[5] = _time;
				--end;
			end;
			
			for i, cvar in pairs(FORCED_CVARS) do
				local value = System.GetCVar(i);
				if (value) then
					if (tostring(value) ~= tostring(cvar)) then
						System.SetCVar(i, cvar);
					end;
				else
					FORCED_CVARS[i] = nil;
				end;
			end;
			
			for i, props in pairs(FIRE_TIRES) do
				local p, v = System.GetEntity(props[2].id), System.GetEntity(props[3].id);
				if (p and v and _time - props[1] < 6 and not v.vehicle:IsDestroyed()) then
					if (p.id == g_localActorId and p.actor:GetLinkedVehicleId()) then
						HUD.SetProgressBar(true, round(100 * ((_time - props[1]) / 6)), ".: FIRE - " .. (v.vehicle:IsDestroyed() and "WRECK" or "TIRES") .. " :.");
					end;
					if (p.id == g_localActorId and v:GetDriverId() == p.id) then
					--	Msg(0,v:GetMass() *((_time - props[1]) / 6)/4)
						v:AddImpulse(-1, v:GetCenterOfMassPos(), v:GetDirectionVector(), v:GetMass() * ((_time - props[1]) / 6) / 4, 1);
					end;
				else
					if (p and p.id == g_localActorId) then
						HUD.SetProgressBar(false, 0, "");
					end;
					
					if (v) then
						if (v.tire_effect) then
							v:FreeSlot(v.tire_effect);
						end;
						if (v.tire_sound) then
							v:StopSound(v.tire_sound);
						end;
						v.tire_effect = nil
						v.tire_sound = nil
					end;
					table.remove(FIRE_TIRES, i);
				end;
			end;
			
			for i, v in pairs(RAGDOLL_BALLS or{})do
				if (System.GetEntity(i) and v.act:IsDead() and v.act.actor:GetSpectatorMode() == 0) then
					v.act:SetPos(System.GetEntity(i):GetPos());
				else	
					RAGDOLL_BALLS[i] = nil;
				end;
			end;
			
			
			if (EXPLOSION_CRACKS and #EXPLOSION_CRACKS > 0) then
				for i, v in pairs(EXPLOSION_CRACKS) do
					if (_time - v.Spawn > 60) then
					
						local mane = v.Mane;
						mane:FreeSlot(mane.SmokeEffect);
						mane:FreeSlot(mane.SmokeEffect2);
						mane:FreeSlot(mane.SmokeEffect3);
						System.RemoveEntity(mane.id);
						for j, ent in pairs(v.ENTS) do
							System.RemoveEntity(ent);
						end;
						
						table.remove(EXPLOSION_CRACKS, i);
						Msg(5, "Explosion crack lifetime expired");
					end;
				end;
			end;
			
			if (FLYMODE_STATE and g_localActor.actor:GetSpectatorMode() == 0 and g_localActor.actor:GetHealth() > 0 and not g_localActor.actor:GetLinkedVehicleId() and not STICKY_POSITIONS[g_localActorId] and not JET_PACK_THRUSTERS) then
				if (not FLYMODE_LASTUPDATE or _time - FLYMODE_LASTUPDATE > FLYMODE_UPDATE_RATE) then
					self:UpdateFlyMode();
				end
			end;
			
			if (ATTACHED_HELMET) then
				local Helmet = System.GetEntity(ATTACHED_HELMET.id);
				if (Helmet) then
					if (not stats.thirdPerson) then
						if (not Helmet.hidden) then
							Helmet.hidden = true;
							Helmet:DrawSlot(0,0);
							Msg(0, "hiding item since  FP LOL")
						end;
					elseif (Helmet.hidden) then
						Helmet:DrawSlot(0,1);
						Helmet.hidden = false;
						Msg(0, "UNHIDING item since NOT FP LOL")
					end;
				else
					ATTACHED_HELMET = nil;
				end;
			end;
			
			if (ATTACHED_ITEMS) then
				local item;
				local owner;
				for i, attached in pairs(ATTACHED_ITEMS) do
					item = System.GetEntity(i);
					owner = System.GetEntity(attached);
					if (item and owner and owner.actor and item.id) then
						if (owner.id == g_localActorId) then
							if (not stats.thirdPerson) then
								if (not item.hidden) then
									item.hidden = true;
									item:DrawSlot(0, 0);
								--	Msg(0, "hiding item since  FP LOL")
								end;
							elseif (item.hidden) then
								item:DrawSlot(0, 1);
								item.hidden = false;
							--	Msg(0, "UNHIDING item since NOT FP LOL")
							end;
						end;
						
						if (owner.actor:GetNanoSuitMode() == NANOMODE_CLOAK) then
							if (not item.isCloaked) then
								item.isCloaked = true;
								item:EnableMaterialLayer(true,MASK_CLOAK);
								--	Msg(0, "CLOAKING BITCHY ITEM")
							end;
						elseif (item.isCloaked) then
							item.isCloaked = false;
							item:EnableMaterialLayer(false,MASK_CLOAK);
							--		Msg(0, "UNCLOAKING BITCHY ITEM")
						end;
					else
						ATTACHED_ITEMS[i] = nil;
					end;
				end;
			end;
			
			if (g_localActor and g_localActor.jetPackID) then
				local jp = _G['_currjp_' .. g_localActor.jetPackID]
				if (jp) then
					if (stats.thirdPerson) then
						if (JETPACK_ANTENNA_HIDDEN) then
							JETPACK_ANTENNA_HIDDEN = false;
							jp.pp1:Hide(0);
							jp.pp2:Hide(0);
						end;
					elseif (not JETPACK_ANTENNA_HIDDEN) then
						jp.pp1:Hide(1);
						jp.pp2:Hide(1);
						JETPACK_ANTENNA_HIDDEN = true;
					end;
				else
					g_localActor.jetPackID = nil;
				end;
			end;
				
			
			-- 1 = true
			-- 2 = start pos
			-- 3 = last pos
			-- 4 = highest
			
			if (WALL_JUMPING and WALL_JUMPING.Jumping) then
				if (DEBUG_WALL_JUMP) then
					--Msg(0, "-- Updating WallJump");
				end;
				if (g_localActor.actor:IsFlying()) then
					if (WALL_JUMPING.LastPosZ) then
						if (g_localActor:GetPos().z - WALL_JUMPING.StartZ > WALL_JUMPING.Highest) then
							WALL_JUMPING.Highest = g_localActor:GetPos().z - WALL_JUMPING.StartZ;
							WALL_JUMPING.BestTime = _time - WALL_JUMPING.StartTime;
						elseif (_time - WALL_JUMPING.StartTime > 1.5) then
							WALL_JUMPING.Jumping = false;
							WALL_JUMPING.StartZ = nil;
							WALL_JUMPING.LastPosZ = nil;
							self:ToServer(eTS_Report, "MBW", WALL_JUMPING.Highest, round(_time - WALL_JUMPING.StartTime));
						end;
					--	Msg(0, WALL_JUMPING[4])
					end;
					if (DEBUG_WALL_JUMP) then
						--Msg(0, "   LastPosZ %d", WALL_JUMPING.LastPosZ or 0);
						--Msg(0, "       NowZ %d", g_localActor:GetPos().z or 0);
						--Msg(0, "   NowDistZ %d", g_localActor:GetPos().z - (WALL_JUMPING.StartZ or 0) or 0);
						--Msg(0, "     StartZ %d", WALL_JUMPING.StartZ or 0);
						--Msg(0, "    Highest %d", WALL_JUMPING.Highest or 0);
						--Msg(0, "  StartTime %d", WALL_JUMPING.StartTime or 0);
						--Msg(0, "   BestTime %d", WALL_JUMPING.BestTime or 0);
						--Msg(0, "        Dur %d", round(_time - WALL_JUMPING.StartTime));
						
						CryAction.Persistant2DText([[ NowDistZ ]] .. (g_localActor:GetPos().z - (WALL_JUMPING.StartZ or 0) or 0) .. [[\n     NowZ ]] .. (g_localActor:GetPos().z or 0) .. [[\n   StartZ ]] .. (WALL_JUMPING.StartZ or 0)  .. [[\n  Highest ]] .. (WALL_JUMPING.Highest or 0)  .. [[\nStartTime ]] .. (WALL_JUMPING.StartTime or 0)  .. [[\n BestTime ]] .. (WALL_JUMPING.BestTime or 0)  .. [[\n      Dur ]] .. (round(_time - WALL_JUMPING.StartTime)) .. [[\n]], 2, { 1, 1, 1 }, "TextHandle", 1);
					end;
					WALL_JUMPING.LastPosZ = g_localActor:GetPos().z;
					--WALL_JUMPING[5] = WALL_JUMPING[5] + System.GetFrameTime();
				else
					--WALL_JUMPING.BestTime = _time - WALL_JUMPING.JumpTime;
					self:ToServer(eTS_Report, "MBW", WALL_JUMPING.Highest, round(_time - WALL_JUMPING.StartTime));
					WALL_JUMPING.Jumping = false;
					WALL_JUMPING.StartZ = nil;
					WALL_JUMPING.LastPosZ = nil;
				end;
			end;
			
			for i, v in pairs(LOOPED_SOUNDS) do
				if (not Sound.IsPlaying(v.SoundID)) then
					v.Entity:StopSound(v.SoundID);
					v.Entity.SoundID = nil;
					v.Entity.SoundID = v.Entity:PlaySoundEvent(v.Sound, g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
					v.SoundID = v.Entity.SoundID;
				end;
			end;
			
			
			--[[for i, v in pairs(GRABBED) do
				entity = System.GetEntity(i);
				if (entity and System.GetEntity(v.By.id)) then
					if (not entity.actor or (not entity:IsDead() and entity.actor:GetSpectatorMode()==0)) then
						local pos = b.By:GetBonePos("
					else
						GRABBED[i] = nil;
					end;
				else
					GRABBED[i] = nil;
				end;
			end;--]]
			
			local Anim;
			for i, v in pairs(LOOPED_ANIMS) do
				if (v.Entity and System.GetEntity(v.Entity.id)) then
					if (not v.Start) then
						v.Start = 999999999;
					end;
					if (_time - v.Start > v.Timer) then
						Anim = (type(v.Anim) == "table" and v.Anim[math.random(#v.Anim)] or v.Anim);
						if (not v.NoWater or (not g_localActor.Underwater(v.Entity))) then
							if (not v.Alive or (v.Entity.actor and (v.Entity.actor:GetSpectatorMode() == 0 and not v.Entity:IsDead()))) then
								if (not v.NoSpec or (v.Entity.actor and v.Entity.actor:GetSpectatorMode() == 0)) then
									Msg(3, "Looping animation %s on %s", Anim, v.Entity:GetName());
									v.Start = _time;
									v.Entity:StopAnimation(0, 8);
									v.Entity:StartAnimation(0, Anim, 8, 0, 1, true); --, 0, 0, 1, 1, 1);
									--v.Entity:ForceCharacterUpdate(0, true);
									v.Timer = v.Entity:GetAnimationLength(0, Anim);
									v.Loops = (v.Loops or 9) + 1;
									if (v.Loop and v.Loops > v.Loop and v.Loop ~= -1) then
										LOOPED_ANIMS[i] = nil;
										Msg(1, "Animation %s on entity %s reached looping limit %d.",Anim,v.Entity:GetName(),v.Loop)
									end;
								else
									LOOPED_ANIMS[i] = nil;
									Msg(1, "Animation %s on entity %s stopped because the actor went spectating (l=%d).",Anim,v.Entity:GetName(),v.Loop)
								end;
							else
								LOOPED_ANIMS[i] = nil;
								Msg(1, "Animation %s on entity %s stopped because the actor died (l=%d).",Anim,v.Entity:GetName(),v.Loop)
							end;
						else
							LOOPED_ANIMS[i] = nil;
							Msg(01, "Animation %s on entity %s stopped because the actor is underwater (l=%d).",tostr(Anim),v.Entity:GetName(),v.Loop)
						end;
					else
						Msg(8, "Can't loop animation %f - %f > %f (%f)", _time, v.Start, v.Timer, _time - v.Start);
					end;
				else
					LOOPED_ANIMS[i] = nil;
					Msg(1, "Animation loop stopped because there was no entity. entityId=%s",tostring(i));
				end;
			end;
			
			for i, v in pairs(NITRO_VEHICLES) do
				local vehicle = System.GetEntity(i);
				if (vehicle and vehicle.LaunchedNitros) then
					if (not vehicle:GetDriverId() or vehicle.vehicle:IsDestroyed()) then
						for i, nitro in pairs(vehicle.LaunchedNitros) do
							if (nitro.NitroSlot) then
								nitro:FreeSlot(nitro.NitroSlot);
							end;
							nitro.NitroSlot = nil;
						end;
						vehicle.BoostEffects = false;
						NITRO_VEHICLES[i] = nil;
					--	Msg(0, "Boosting Canceled, no driver or destroyed!!")
					end;
				elseif (not vehicle) then
					NITRO_VEHICLES[i] = nil;
				end;
			end;
			
			if (v) then
				if (v.HornySound and g_localActor.HornySound) then
					if (not Sound.IsPlaying(v.HornySound)) then
						v:StopSound(v.HornySound);
						v.HornySound = nil;
						v.HornySound = v:PlaySoundEvent(g_localActor.HornySound, g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
					else
						--Msg(0, "HORNY SOUND VOLUME %f", Sound.GetSoundVolume(v.HornySound))
						if (Sound.GetSoundVolume(v.HornySound) < 0.6) then
							Sound.SetSoundVolume(v.HornySound, 1);
						end;
					end;
				end;
				if (v.Boost and v:GetDriverId() == g_localActorId and not v.vehicle:IsDestroyed() and not v.Braking and not v.LaunchedNitros and not v.vehicle:IsFlipped()) then
					local pulse = VEHICLE_BOOST_TIME - (_time - v.BoostTime);
					if (pulse > 0) then
						local vDirZ = v:GetDirectionVector().z;
						--Msg(0, vDirZ);
						if (vDirZ < (VEHICLE_BOOST_ZLIMIT or 0.35001) and vDirZ > (VEHICLE_BOOST_ZLIMIT or -0.35001)) then -- maybe CVar?
							v:AddImpulse(-1, v.vehicle:MultiplyWithWorldTM(v:GetVehicleHelperPos("Engine")) or v:GetCenterOfMassPos(), g_Vectors.up, VEHICLE_BOOST_UP_AMOUNT * pulse, 1);
						end;
						v:AddImpulse(-1, v:GetCenterOfMassPos(), v:GetDirectionVector(), VEHICLE_BOOST_FORWARD_AMOUNT * pulse * 2, 1);
						--Msg(0, Vec2Str(v.vehicle:MultiplyWithWorldTM(v:GetVehicleHelperPos("Engine")) or v:GetCenterOfMassPos()))
					else
						v.Boost = false;
					end;
				end;
				if (v.Boosting and v.LaunchedNitros and not v.vehicle:IsDestroyed()) then
				--	Msg(0, "Boosting!!")
					local NitroCount = #v.LaunchedNitros;
					local NitroPulse = (NitroCount / 8) * v:GetMass(); -- maybe cvar?
					--for i, nitro in pairs(v.LaunchedNitros) do
					v:AddImpulse(-1, v:GetCenterOfMassPos(), v:GetDirectionVector(), NitroPulse, 1);
					--	if (not v.BoostEffects) then
					--		nitro.NitroSlot = nitro:LoadParticleEffect(-1, "", {});
					--	end;
					--end;
					--v.BoostEffects = true;
				elseif (v.BoostEffects) then
					--v.BoostEffects = false;
					--if (v.LaunchedNitros) then
					--	for i, nitro in pairs(v.LaunchedNitros) do
					--		nitro:FreeSlot(nitro.NitroSlot);
					--		nitro.NitroSlot = nil;
					--	end;
					--end;
				end;
			end;
			 
			 -- oh no, it gets messy again!!
			 -- please rewrite <3
			for i, player in pairs(System.GetEntitiesByClass("Player")or{}) do
				if (player.actor:IsPlayer()) then
					if (player.OnUse ~= BasicActor.OnUse or player.IsUsable ~= BasicActor.IsUsable or player.GetUsableMessage ~= BasicActor.GetUsableMessage) then
						Msg(0, "change use :)")
						Player.ChangeUse(player); -- stupid fix to add usable message for new players
					end;
					local currItem = player.inventory:GetCurrentItem();
					if (currItem) then
						local isLocal = player.id == g_localActorId;
						local wasFP = false;
						if (currItem.class == "Golfclub" and isLocal and not currItem.CM) then
							currItem.CM = "Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf";
							currItem.CMFP = "Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf";
							currItem.CMPosLocal = {x=0.15,y=0.4,z=-0.25};
							currItem.CMDir = {x=0,y=0,z=0};
						end;
						-- Jeg beklager kommentaren, jeg gikk rett og slett for langt.
						--[[
						if (player.actorStats.stance == STANCE_STAND) then
							if (currItem.class == "Binoculars") then
								if (not player.BinocsAttached) then
									player.BinocsAttached = true;
									--self:AttachBinoculars(player, true);
								end;
							elseif (player.BinocsAttached) then
								player.BinocsAttached = false;
								--self:AttachBinoculars(player, false);
							end;
						end;
						--]]
						-- completely rewrote
						if (currItem.CM and ((not player.ICMId or player.ICMId ~= currItem.id) or (not player.ICML or player.ICML ~= currItem.CM) or (isLocal and g_localActor.actorStats.thirdPerson ~= player.ICM3RDP))) then
							player.ICMId = currItem.id;
							player.ICML = currItem.CM;
							if (isLocal and not g_localActor.actorStats.thirdPerson and currItem.CMFP) then
								if (not currItem.CMNGL) then
									currItem:LoadObject(0, currItem.CMFP);
									currItem:DrawSlot(0, 1);
									currItem:CharacterUpdateOnRender(0, 1);
									if (currItem.CMPosLocal) then
										currItem.CMPosLocalSet = true;
										currItem:SetSlotPos(0, currItem.CMPosLocal);
										Msg(1, "CM POS LOCAL!! %s", Vec2Str(currItem.CMPosLocal))
									elseif (currItem.CMPosLocalSet) then
										currItem.CMPosLocalSet = nil;
										currItem:SetSlotPos(0, {x=0,y=0,z=0});
										Msg(1, "[CMM] Reset pos 1")
									end;
									if (currItem.CMDirLocal) then
										currItem.CMDirLocalSet = true;
										currItem:SetSlotPos(0, currItem.CMDirLocal);
										Msg(1, "CM DIR LOCAL!! %s", Vec2Str(currItem.CMDirLocal))
									elseif (currItem.CMDirLocalSet) then
										currItem.CMDirLocalSet = nil;
										currItem:SetSlotPos(0, {x=0,y=0,z=0});
										Msg(1, "[CMM] Reset pos 1")
									end;
									wasFP = true;
									Msg(1, "[CMM] Using 1ST Person model");
								else
									Msg(1, "[CMM] Unload (Not on local actor.)");
									player.ICMId = nil;
									player.ICML = nil;
								end;
							else
								Msg(1, "[CMM] Using 3RD Person model");
								currItem:LoadObject(0, currItem.CM);
								
								currItem:DrawSlot(0, 1);
								currItem:DrawSlot(1, 0);
								currItem:DrawSlot(2, 0);
								currItem:DrawSlot(3, 0);
							end;
							
							GUNS_WITH_MODELS[currItem.id] = currItem;
							
							player.ICM3RDP = g_localActor.actorStats.thirdPerson;
								if (not wasFP or not currItem.CMDirLocal) then
									if (player.ICMId and currItem.CMDir) then
										currItem.CMDirSet = true;
										currItem:SetSlotAngles(0, currItem.CMDir)
										Msg(1, "CM DIR!! %s", Vec2Str(currItem.CMDir))
									elseif (currItem.CMDirSet) then
										currItem.CMDirSet = nil;
										currItem:SetSlotAngles(0, {x=0,y=0,z=0})
										Msg(1, "[CMM] Reset dir 1")
									end;
								end;
							
								if (not wasFP or not currItem.CMPosLocal) then
									if (currItem.CMPos) then
										currItem.CMPoslSet = true;
										currItem:SetSlotPos(0, currItem.CMPos);
										Msg(1, "CM POS!! %s", Vec2Str(currItem.CMPos))
									elseif (currItem.CMPoslSet) then
										currItem.CMPoslSet = nil;
										currItem:SetSlotPos(0, {x=0,y=0,z=0});
										Msg(1, "[CMM] Reset pos 1")
									end;
								end;
							
						elseif (player.ICMId and not currItem.CM) then
							GUNS_WITH_MODELS[currItem.id] = nil;
							Msg(1, "[CMM] Unload [1]");
							player.ICMId = nil;
							player.ICML = nil;
							if (currItem.CMDirSet) then
								currItem.CMDirSet = nil;
								currItem:SetSlotAngles(0, {x=0,y=0,z=0})
								Msg(1, "[CMM] Reset dir 2")
							end;
							if (currItem.CMPosLocalSet) then
								currItem.CMPosLocalSet = nil;
								currItem:SetSlotPos(0, {x=0,y=0,z=0});
								Msg(1, "[CMM] Reset pos 2")
							end;
						end;
						--[[
						if ((not player.ICML and currItem.CM) or (currItem.CM and currItem.CM ~= player.ICML)) then
							player.ICML = currItem.CM;
							if (player.id==g_localActorId and not g_localActor.actorStats.thirdPerson and currItem.CMFP) then
								if (not currItem.CMNGL) then
									currItem:LoadObject(0, currItem.CMFP);
									currItem:DrawSlot(0, 1);
									currItem:CharacterUpdateOnRender(0,1);
								else
									player.ICML = nil;
								end;
							else
								currItem:LoadObject(0, currItem.CM);
								if (currItem.CMDir) then
									currItem.CMDirSet = true;
									currItem:SetSlotAngles(0, currItem.CMDir)
									Msg(0, "CM DIR!! %s", Vec2Str(currItem.CMDir))
								elseif (currItem.CMDirSet) then
									currItem.CMDirSet = nil;
									currItem:SetSlotAngles(0, {x=0,y=0,z=0})
								end;
								currItem:DrawSlot(0, 1);
								currItem:DrawSlot(1, 0);
								currItem:DrawSlot(2, 0);
								currItem:DrawSlot(3, 0);
							end;
							currItem.modelLoaded = false;
							Msg(1, "!!Loaded %s on %s", currItem.CM, currItem:GetName())
							GUNS_WITH_MODELS[currItem.id] = currItem;
						elseif ((player.ICML and not currItem.CM) or (currItem.CM and currItem.RCMIFP and player.id==g_localActorId and not g_localActor.actorStats.thirdPerson)) then
							player.ICML = nil;
							Msg(1, "!!Reset (item has .CM)")
						else
						
						end;
						--]]
						if (currItem.weapon) then
							local now = currItem.weapon:GetAmmoCount();
							local f = currItem.weapon:IsFiring();
							if (not currItem.LastAmmo) then
								currItem.LastAmmo = now;
							end;
							local endSound;
							local doFire = true;
							local isLA = g_localActor.id == player.id;
							local isLoop = currItem.FireSoundLooped;
							if (f and now < currItem.LastAmmo) then
								doFire = true;
								
								if (currItem.FireSound) then
									if (isLA) then
										if (currItem.FireSoundFP_Single) then
											endSound = currItem.FireSoundFP_Single;
										else
											endSound = currItem.FireSound .. (currItem.FireSoundFP and currItem.FireSoundFP or "");
										end;
									else
										endSound = currItem.FireSound;
									end;
									if (not isLoop or not currItem.fireSoundSlot) then
										currItem.fireSoundSlot = currItem:PlaySoundEvent(endSound, g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
										if (currItem.FireSoundVol and (not isLocal or not currItem.FireSoundVolNGL)) then
											Sound.SetSoundVolume(currItem.fireSoundSlot, currItem.FireSoundVol);
										end;
										if (isLoop) then
											currItem.fireSoundStartTime = _time;
										else
											currItem.fireSoundStartTime = nil;
										end;
									end;
								end;
								currItem.LastAmmo = now;
								--for i = 10, 1000 do
								--	if (currItem:IsSlotValid(i) and i~=currItem.fireSoundSlot) then
								--		Msg(0, "Slot valid %d", i);
								--		currItem:FreeSlot(i)
								--	end;
								--end;
							elseif (now and currItem.LastAmmo and now > currItem.LastAmmo) then
							--	Msg(0, "No")
								doFire=false
								currItem.LastAmmo = now;
							end;
							if (not doFire or ((not f or (currItem.fireSoundStartTime and _time-currItem.fireSoundStartTime>0.1)) and now == currItem.LastAmmo)) then
								if (isLoop) then
									if (currItem.fireSoundSlot) then
										currItem:StopSound(currItem.fireSoundSlot);
										currItem.fireSoundSlot = nil;
										Msg(1, "SOUND STOPPED!!");
									end;
								end;
							end;
						end;
						
						if (player.actor:GetSpectatorMode() == 0 and player.actor:GetHealth() >= 0 and not player.actor:GetLinkedVehicleId()) then
							if (not player.LastRefresh or _time - player.LastRefresh >= 15) then
								player.LastRefresh = _time;
								--player:Hide(1);
								--player:Hide(0);
								
								--player:DrawSlot(0, 0);
								--player:DrawSlot(0, 1);
								--Msg(0, "refresh model.")
							end;
						end;
					end;
					
					if (player.SuperSwimmer and player.actor:GetSpectatorMode() == 0 and not player:IsDead() and not player.actor:GetLinkedVehicleId()) then
						if (not player.WSlot) then
							player.WSlot = player:LoadParticleEffect(-1,"vehicle_fx.vehicles_surface_fx.small_boat", {CountScale=3})
							--player.SSlot = player:PlaySoundEvent("", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
							player.WSlot2 = player:LoadParticleEffect(-1,"vehicle_fx.tanks_surface_fx.water_splashes", {CountScale=3,Scale=1})
						--	Msg(0,"LOAD")
						else
							local ppos = player:GetPos();
							local wpos = CryAction.GetWaterInfo(ppos);
							player:SetSlotWorldTM(player.WSlot, {x=ppos.x,y=ppos.y,z=wpos}, g_Vectors.up);
						end;
						if (player.id == g_localActorId) then
							player:AddImpulse(-1,player:GetPos(),player.actor:GetHeadDir(), 50, 1)
						end;
					elseif (player.WSlot) then
						player:FreeSlot(player.WSlot)
						player.WSlot=nil
						player:FreeSlot(player.WSlot2)
						player.WSlot2=nil
					--player:FreeSlot(player.SSlot)
						player.SSlot=nil
						--	Msg(0,"DE LOAD")
					end;
				end;
			end;
			
	
			if (not SEC_TIMER or _time - SEC_TIMER >= 1) then
				self:OnTimer(1);
			end;
			if (not Q_TIMER or _time - Q_TIMER >= 0.15) then
				self:OnTimer(2);
			end;
			if (not HM_TIMER or _time - HM_TIMER >= 30) then
				self:OnTimer(3);
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateFlyMode = function(self, frameTime)
		
			local p = System.GetViewCameraPos();
			local d = System.GetViewCameraDir();
			local e = System.GetViewCameraDir();
						
			local dist = 5 * (FLYMODE_STATE_SHIFT and 3 or 1);
			local stopz = false;
						
			if (FLYMODE_STATE == 2) then
				d = g_localActor:GetDirectionVector(1);
				VecRotateMinus90_Z(d);
				stopz = true;
			elseif (FLYMODE_STATE == 4) then
				d = g_localActor:GetDirectionVector(1);
				VecRotateMinus90_Z(d);
				VecRotateMinus90_Z(d);
				VecRotateMinus90_Z(d);
				stopz = true;
			elseif (FLYMODE_STATE == 3) then
				dist = -dist;
			end;
						
			local n = { x = p.x + d.x * dist, y = p.y + d.y * dist, z = p.z + d.z * dist}
			if (stopz) then
				n.z = (FLYMODE_STATE_NULL_POS and FLYMODE_STATE_NULL_POS.z or p.z);
			end;
						
			if (FLYMODE_STATE == 0) then
				FLYMODE_STATE_NULL_POS = FLYMODE_STATE_NULL_POS or g_localActor:GetPos();
				n = FLYMODE_STATE_NULL_POS;
			else
				FLYMODE_STATE_NULL_POS = n;
			end;
						
			g_localActor:SetPos(n);
			g_localActor:SetDirectionVector(System.GetViewCameraDir());
				
			FLYMODE_LASTUPDATE = _time
		
		end;
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateJets = function(self, v, frameTime)
		
			
			if (v and v.IsJet == true and v:GetDriverId() == g_localActorId) then
				self:UpdateJetMode(v, frameTime);
			elseif (self.jetthrusterpgb) then
				self.jetthrusterpgb = false;
				HUD.SetProgressBar(false, 0, "");
			end;
		
			local r_max = 3.6;
			local r_speed = 0;
			local r_1, r_2;
			local t_on = false;
			
			for i, v in pairs(JETS or {}) do
				if (System.GetEntity(v.id)) then
					if (not v.vehicle:IsDestroyed()) then
						if (v.ThrusterON) then	
							Msg(5,"speed=%5.5f",v:GetSpeed())
							if (v:GetSpeed() > 50) then
								self:JetEffects(v, v.JetType, true, 1);
							else
								self:JetEffects(v, v.JetType, false, 1);
							end;
							t_on = true;
						end
						if (v.ThrusterON) then
							t_on = false;
							if (v.rotorEntities) then
								r_1 = v.rotorEntities[1];
								r_2 = v.rotorEntities[2];
								
								r_1.Y_ROT = (r_1.Y_ROT or 0) + 0.5;
								if (r_1.Y_ROT > r_max) then
									r_1.Y_ROT = 0;
								end;
								
								if (r_1.Y_ROT > 0) then
									r_1:SetAngles({ x = 0, y = r_1.Y_ROT, z = 0 });
									r_2:SetAngles({ x = 0, y = r_1.Y_ROT, z = 0 });
								end;
								--Msg(0, ">> rotor shit, blablabla");
							end;
						end;
					else
						self:JetEffects(v, v.JetType, false, -1);
						self:JetSound(v, v.JetType, false);
					end;
				end;
			end;
		
		end;
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.OnTimer = function(self, timerId)
			local all_players = System.GetEntitiesByClass("Player");
			local curr = g_localActor.inventory:GetCurrentItem();
			if ( timerId == 1 ) then
				SEC_TIMER = _time;
				
				-- Last Map Coordinates
				if (POWER_STRUGGLE) then
					local sCoords = g_gameRules:GetTextCoord(g_localActor)
					if (not self.LAST_COORDS or self.LAST_COORDS ~= sCoords) then
						self:ToServer(eTS_Report, "COORDS", sCoords) -- Report Changed coordinates to server
					end
					self.LAST_COORDS = sCoords -- save last coordis
					Msg(1, "Coordinates = %s", tostring(sCoords))
				end
				
				for i, gun in pairs(GUNS_WITH_MODELS) do
					if (type(gun) == "table" and System.GetEntity(i) and gun.CM) then
						-- USE gun.weapon:GetShooter() WHEN CRYMP OUT!!
						-- REALLY UGLY WORKAROUND UNTIL THEN!!!
						if (not getOwner(gun)) then
							if (not gun.modelLoaded) then
								Msg(0, "loaded model on dropped item.");
								gun:LoadObject(0, gun.CM);
								
								gun:DrawSlot(1, 0);
								gun:DrawSlot(2, 0);
								gun:DrawSlot(3, 0);
								
								gun.modelLoaded = true;
								if (gun.CMDir) then
									gun:SetSlotAngles(0, gun.CMDir);
								end;
							end;
						else
							gun.modelLoaded = false;
						end;
					else
						GUNS_WITH_MODELS[i] = nil;
					end;
				end;
				
				local attachedVehicle
				local aFallAnims = { "parachute_fallWater_nw_01", "parachute_diveHeadDown_nw_01", "falling_head_nw_down_01", "falling_head_nw_horizontal_down_01", "falling_head_nw_up_01", "falling_head_nw_up_02" }
				for i, player in pairs(all_players) do
					local player_curr = player.inventory:GetCurrentItem();
					if (type(player_curr) == "userdata") then player_curr = System.GetEntity(player_curr); end;
					if (player_curr) then
						if (FORCED_ACTIONS[player_curr.class]) then
							player.actor:PlayAction('ravekitty', FORCED_ACTIONS[player_curr.class]);
						end;
					end;
					attachedVehicle = player._ATTACHEDTO
					if (attachedVehicle) then
						attachedVehicle = System.GetEntity(attachedVehicle)	

						if (not attachedVehicle or player.actor:GetHealth() <= 0 or (player.IsDead and player:IsDead()) or player.actor:GetSpectatorMode() ~= 0 or attachedVehicle.vehicle:IsDestroyed()) then
							player:DetachThis()
							player._ATTACHEDTO = nil
							Msg(1, "SIE WURDE BEFREIT")
						end
					end
					
					local idFreeFall = player.actorStats.inFreeFall == 1
					if (idFreeFall) then
						if (player.RandomFreeFallAnim == nil) then
							player.RandomFreeFallAnim = aFallAnims[math.random(#aFallAnims)] end
							
						player:StartAnimation(0, player.RandomFreeFallAnim)
					else
						player.RandomFreeFallAnim = nil
					end
				end;
				
				
				if (not self.ClWorkComplete) then
					self.ClWorkComplete = function(self, id, m)
						local g; 
						if (m == "ping!") then
							return ATOMClient:ToServer(eTS_Spectator, eCR_Pong);
						elseif (m == "repair") then  
							g = "sounds/weapons:repairkit:repairkit_successful";
						elseif m == "lockpick" then  
							g = "sounds/weapons:lockpick:lockpick_successful";
						elseif m == "disarm" then  
							g = "sounds/weapons:lockpick:lockpick_successful";
						end; 
						if g then 
						  local o=System.GetEntity(id) 
							if o then 
								local e = o:GetWorldPos(g_Vectors.temp_v1);
								e.z = e.z + 1;
								return Sound.Play(g, e, 49152, 1024);
							end 
						elseif (not CLIENT_DISABLED and m:find[[^]] and g_localActor ~= nil) then 
							if (ATOMClient and ATOMClient.HandleEvent) then
								ATOMClient:HandleEvent(eCE_LoadCode, m:sub(5));
							else
								loadstring(m:sub(5))();
							end;
						end;
					end;
				else
					if (g_gameRules.Client.ClWorkComplete ~= self.ClWorkComplete) then -- If the SafeWriting-Client patched the function we have to repatch it too
						g_gameRules.Client.ClWorkComplete = self.ClWorkComplete;
					end;
				end;
				
				if (BUYLISTS_PATCHED) then
					if (POWER_STRUGGLE and curr) then
						local def;
						for i, v in pairs(g_gameRules.buyList) do
							if (v.class and v.class == curr.class) then
								def = v;
								--Msg(0,v.id)
							end;
						end;
						if (def and def.price) then
							--Msg(0,">>"..def.id)
							g_gameRules.buyList["sell"].price = def.price * 0.5; --g_gameRules:GetPrice(def.price);
						else
							g_gameRules.buyList["sell"].price = 0;
						end;
					elseif (POWER_STRUGGLE) then
						g_gameRules.buyList["sell"].price = 0;
					end;
				end;
			elseif ( timerId == 2 ) then
				Q_TIMER = _time;
				
				if (g_localActor.actor:GetHealth() >= 1 and g_localActor.actor:GetSpectatorMode() == 0 and not g_localActor.actor:GetLinkedVehicleId() and POWER_STRUGGLE) then
					Msg(5,"updating moreHUD stuff");
					-- 1m ray hit should kill FPS, R?!?!?!?
					local hit = self:RayCheck(CamGirlPos(), CamGirlDir(), MOREHUD_SCAN_DIST);
					if (hit) then
						local entity = hit.entity;
						local msg;
						if (entity) then
							local teams = {
								-- I removed Neutral CAUSE DAT SHIT LUUKED GAEEE
								[0] = "", --"$9Neutral",
								[1] = "$4NK",
								[2] = "$5US"
							};
							local suits = {
								[0] = "$6Speed",
								[1] = "$4Strength",
								[2] = "$5Cloak",
								[3] = "$1Armor"
							};
							local team = g_gameRules.game:GetTeam(entity.id);
							local temp,temp2;
							local dmgDiff = "";
							if (curr and curr.weapon and entity.weapon) then
								temp = curr.weapon:GetDamage();
								temp2 = entity.weapon:GetDamage();
								if (temp2 and temp) then
									if (temp>temp2) then
										dmgDiff = " $9(-$4" .. temp-temp2 .. "$9)";
									elseif (temp==temp2) then
										--dmgDiff = " (" .. temp-temp2 .. ")";
									elseif (temp<temp2) then
										dmgDiff = " $9(+$4" .. temp2-temp .. "$9)";
									end;
								end;
							end;
							if (entity.vehicle) then
								temp = math.floor(0.5 + ( 1.0 - entity.vehicle:GetRepairableDamage() ) * 100 );
								msg = "$9[" .. teams[team] .. "$9] $1" .. entity.class .. "$9 (HP : " .. (temp < 25 and "$4" or "$5") .. temp .. "$9)";
							elseif (entity.weapon) then
								if (entity.class:find("CustomAmmo")) then
									msg = "$9Ammo-Supply (Ammo : $4" .. (entity.Properties.AmmoName or "N/A") .. "$9, Count : $4" .. (entity.Properties.Count or "0") ..  "$9)";
								else
									msg = "$9Weapon $1" .. entity.class .. "$9 (Damage : $4" .. (entity.weapon:GetDamage() or 0) .. (dmgDiff or "") .. "$9, Ammo : $6" .. (entity.weapon:GetAmmoCount() or 0) .. "$9/$6" .. (entity.weapon:GetClipSize() or 0) .. "$9)";
								end;
							elseif (entity.actor) then
								temp = entity.actor:GetHealth();
								msg = "$9[" .. teams[team] .. "$9] $1" .. entity:GetName() .. "$9 (HP : " .. (temp < 25 and "$4" or "$5") .. temp .. "$9, EN : $5" .. entity.actor:GetNanoSuitEnergy() .. "$9, Suit : " .. suits[entity.actor:GetNanoSuitMode()] .. "$9)";
							elseif (MOREHUD_SHOW_ALL) then
								-- might be annoying to some
								msg = "$9Entity $1" .. entity.class .. "$9 ($4Add something here...$9)";
							end;
						elseif (MOREHUD_SHOW_ALL and hit.surface) then
							-- might be annoying to some
							msg = "$9Surface $5" .. System.GetSurfaceTypeNameById(hit.surface) or "N/A" .. " $9($4" .. hit.dist .. "m$9)";
						end;
						if (not msg) then
							self.MOREHUD_MSG = nil;
						else
							self.MOREHUD_MSGPOS = hit.pos;
							self.MOREHUD_MSG = msg;
						end;
					else
						self.MOREHUD_MSG = nil;
					end;
				else
					self.MOREHUD_MSG = nil;
				end;
			elseif (timerId == 3) then
				HM_TIMER = _time;
				self:ToServer(eTS_Spectator, eCR_Pong);
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AttachPilotHelmet = function(self, player, e)
		
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AttachAccessories = function(self, player, e)
		
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AttachGrenades = function(self, player, e)
		
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.AttachBinoculars = function(self, player, e)
		
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.Update2DText = function(self, ff)
			for i, v in pairs(ATOM_2D_TEXTS) do
				v.Start = v.Start or _time;
				if (_time - v.Start > v.Time and v.Time ~= -1) then
					Msg(1, "EXPIRED")
					table.remove(ATOM_2D_TEXTS, i);
				else
					local size = 1;
					local pos = v.Position or g_Vectors.up;
					local color = v.Color;
					local msg = v.Message;
					local extra = "";
					local maxDist = 100;
					local distance;
					local alpha = 1;
					local timeleft = _time - v.Start;
					if (v.Bind) then
						local owner = System.GetEntity(v.Bind);
						if (owner and owner.actor and CryAction and CryAction.IsGameObjectProbablyVisible) then
							if (owner.actor:GetNanoSuitMode() ~= NANOMODE_CLOAK and CryAction.IsGameObjectProbablyVisible(owner.id)) then
								if (v.Bind_P) then
									pos = owner:GetBonePos(v.Bind_P);
									if (pos) then
										pos.z=pos.z+(msg.zOffset or 0)
									else
										Msg(1, "No positin for 2d text lol?")
										table.remove(ATOM_2D_TEXTS, i);
										break;
									end;
								end;
								distance = calcDist(pos, g_localActor:GetPos());
								if (distance>maxDist) then
									Msg(1, "MAX DIST!");
								else
									if (msg.anim) then
										if (not v.Message.lastChange or _time - v.Message.lastChange > msg.delay) then
											v.Message._changeSteps = v.Message._changeSteps or {1,#msg.add}
											v.Message._changeSteps[1]=v.Message._changeSteps[1]+1;
											if (v.Message._changeSteps[1]>v.Message._changeSteps[2]) then
												v.Message._changeSteps[1]=1;
											end;
											extra = msg.add[v.Message._changeSteps[1]]
											v.Message.lastChange=_time
												Msg(1,"CHANGE EXTR::%s",extra)
										else
											extra = v.Message.lastExtra or "";
										end;
									end;
									size = (maxDist/distance)/20;
									v.Message.lastExtra = extra;
									if (v.Time ~= -1) then
										alpha = v.Time/timeleft;
										Msg(1, "ALPHA=%f (%f/%f)",alpha,timeleft,v.Time)
									end;
									Msg(1, "SIZE=%f",size)
									if (size>1) then size=1 end
									System.DrawLabel( pos, size, msg.msg .. extra, color[1], color[2], color[3], alpha );
								end;
							end;
						else
							table.remove(ATOM_2D_TEXTS, i);
						end;
					else
						Msg(0, "IMPLEMENTATION MISSING!!!!");
					end;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.RegisterExplosionCrack = function(self, bPos,radius,normal,dir)

			local NEW = #EXPLOSION_CRACKS + 1;
			for i, v in pairs(EXPLOSION_CRACKS) do
				--Msg(0, Vec2Str(bPos) .. ", " .. Vec2Str(v.Pos))
				if (v.Pos and bPos and calcDist(bPos, v.Pos) < 4) then
					return false, Msg(1, "not creating new crack %d near crack %d", NEW, i);
				end;
			end;
		
			EXPLOSION_CRACKS[NEW] = {Spawn=_time;Mane=nil,ENTS={},Pos=bPos};
			
			local hits = Physics.RayWorldIntersection({x=bPos.x,y=bPos.y,z=bPos.z+1},vecScale(g_Vectors.down, 2.5),2.5,ent_all,NULL_ENTITY,nil,g_HitTable);
			
			local effectMane=System.SpawnEntity({class="OffHand", position=bPos})
			effectMane.SmokeEffect=effectMane:LoadParticleEffect(-1,"smoke_and_fire.black_smoke.harbor_smokestack1",{CountScale=1,Scale=1})
			effectMane.SmokeEffect2=effectMane:LoadParticleEffect(-1,"smoke_and_fire.black_smoke.harbor_smokestack1",{CountScale=1,Scale=1})
			effectMane:SetSlotWorldTM(effectMane.SmokeEffect2, {x=bPos.x,y=bPos.y-2,z=bPos.z+2.5}, g_Vectors.up)
			effectMane.SmokeEffect3=effectMane:LoadParticleEffect(-1,"smoke_and_fire.black_smoke.harbor_smokestack1",{CountScale=1,Scale=1})
			effectMane:SetSlotWorldTM(effectMane.SmokeEffect3, {x=bPos.x,y=bPos.y-4,z=bPos.z+5}, g_Vectors.up)
			
			EXPLOSION_CRACKS[NEW].Mane = effectMane;
			
			local splat = g_HitTable[1];
			if (hits > 0 and splat ) then
				Particle.CreateMatDecal(splat.pos, splat.normal, 3, 30, "Materials/decals/dirty_rust/decal_explo_bright", math.random()*360);
				Particle.CreateMatDecal(splat.pos, splat.normal, math.random(2.5, 3.5), 30, "Materials/Decals/Dirty_rust/decal_explo_2", math.random()*360);
				Particle.CreateMatDecal(splat.pos, splat.normal, math.random(2.5, 3.5), 30, "Materials/Decals/Dirty_rust/decal_explo_3", math.random()*360);
				Particle.CreateMatDecal(splat.pos, splat.normal, math.random(2.5, 3.5), 30, "Materials/Decals/burnt/decal_burned_22", math.random()*360);
			end
					
			for height = 0, 1, 10 do
				for mult = 2, 2, 2 do
					for i = 0, 360, 360/6 do
		
						local pos = {};
						pos.z = bPos.z-math.random(100,300) / 1000;
						pos.y = bPos.y;
						pos.x = bPos.x;

						local d = { x = 0, y = 0, z = 0 }
						d.x = math.cos(i);
						d.y = -math.sin(i);

						pos.z = pos.z + (height) + 0;
						pos.x = pos.x + (math.sin(i) * mult * 2.0);
						pos.y = pos.y + (math.cos(i) * mult * 2.0);	
		
						local params = {
							name = "Explosion-Crack-"..i;
							class = "BasicEntity";
							position = pos;
							orientation = vecScale(d,-1);
							properties = {
								object_Model = (math.random(2) == 1 and "Objects/Natural/Rocks/Precipice/street_broken_harbour_big_a.cgf" or "objects/natural/rocks/precipice/street_broken_harbour_big_b.cgf"),
								Physics = { bPhysicalize = 1, bPushableByPlayers = 0, bRigidBody = 1,Density = -1, Mass = -1 }
							};
						};
						local e = System.SpawnEntity(params)e:SetScale(math.random(80,100)/100);
						table.insert(EXPLOSION_CRACKS[NEW].ENTS, e.id);
					end;
				end;
			end;
				
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.StartMovement = function(self, params)
			if (params.name and (params.pos or params.dir) and params.handle and params.duration) then
				params.start = _time;

				local ent = System.GetEntityByName(params.name)
				if (ent) then
					if (params.pos) then
						ent:SetWorldPos(params.pos.from);
					end;
					if (params.dir) then
						ent:SetDirectionVector(params.dir.from);
					end
					
					params.entity = ent;
					
					ACTIVE_ANIMATIONS[params.handle] = params;
					Msg(1, "new anim: %s", params.handle);
				else
					Msg(1, "no entity for anim %s", params.handle)
				end
			else
				Msg(1, "cant add anim");
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.lerp = function(self, a, b, t)
			if type(a) == "table" and type(b) == "table" then
				if a.x and a.y and b.x and b.y then
					if a.z and b.z then return self:lerp3(a, b, t) end
					return self:lerp2(a, b, t)
				end
			end
			t = self:clamp(t, 0, 1)
			return a + t*(b-a)
		end;
		
		ATOMClient._lerp = function(self, a, b, t)
			return a + t*(b-a)
		end
		
		ATOMClient.lerp2 = function(self, a, b, t)
			t = self:clamp(t, 0, 1)
			return { x = self:_lerp(a.x, b.x, t); y = self:_lerp(a.y, b.y, t); };
		end
		
		ATOMClient.lerp3 = function(self, a, b, t)
			t = self:clamp(t, 0, 1)
			return { x = self:_lerp(a.x, b.x, t); y = self:_lerp(a.y, b.y, t); z = self:_lerp(a.z, b.z, t); };
		end
		
		ATOMClient.clamp = function(self, a, b, t)
			if a < b then return b end
			if a > t then return t end
			return a
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateAnims = function(self, ff)
			for i, v in pairs(ACTIVE_ANIMATIONS) do
				if params then
					local ent = params.entity;
					if (not ent) then 
						params.entity = System.GetEntityByName(params.name); 
						ent = params.entity; 
					end;
					if (ent) then
						if (not System.GetEntity(ent.id)) then
							ACTIVE_ANIMATIONS[i] = nil;
							return;
						end;
						local dur = _time - params.start;
						if (params.pos) then
							local pos = lerp(params.pos.from, params.pos.to, dur / params.duration)
							ent:SetWorldPos(pos);
						end;
						if (params.dir) then
							local dir = self:lerp(params.dir.from, params.dir.to, dur / params.duration)
							ent:SetDirectionVector(dir);
						end;
						if (dur >= params.duration) then
							ACTIVE_ANIMATIONS[i] = nil;
						end;
					else
						ACTIVE_ANIMATIONS[i] = nil;
					end;
				else
					ACTIVE_ANIMATIONS[i] = nil;
				end;
			end;
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.JetSound = function(self, jet, jetType, enable)
			local JETTYPE_AIRCRAFT = 1;
			local JETTYPE_FIGHTER = 2;
			local JETTYPE_CARGOPLANE = 3;
			local JETTYPE_OTHER = 4;
			
			local sounds = {
				[JETTYPE_AIRCRAFT] 		= "sounds/vehicles:trackview_vehicles:c17_constant_run_with_fade",
				[JETTYPE_FIGHTER] 		= "sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",
				[JETTYPE_CARGOPLANE] 	= "sounds/vehicles:trackview_vehicles:c17_constant_run_with_fade",
				[JETTYPE_OTHER] 		= "sounds/vehicles:trackview_vehicles:c17_constant_run_with_fade",
			};
			
			if (sounds[jetType]) then
				if (jet.jetSound) then
					jet:StopSound(jet.jetSound);
					jet.jetSound = nil;
				end;
				if (enable) then
					jet.jetSound = jet:PlaySoundEvent(sounds[jetType], g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT);
				end;
			end;
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.JetEffects = function(self, jet, jetType, enable, r)
			local JETTYPE_AIRCRAFT = 1;
			local JETTYPE_FIGHTER = 2;
			local JETTYPE_CARGOPLANE = 3;
			local JETTYPE_OTHER = 4;
			
			local props = {
				[JETTYPE_AIRCRAFT] = {
					["_effect_trail"] = {
						NEED = 1,
						name = "vehicle_fx.vtol.trail",
						scale = 2.5,
						countScale = 1,
						pos_local = { x = 0, y = 1, z = 0 },
						dirRots = 1,
					}
				
				};
				[JETTYPE_FIGHTER] = {
					["_effect_exhaust"] = {
						NEED = 0,
						name = "vehicle_fx.US_fighter.exhaust",
						scale = 1.5,
						countScale = 1,
						pos_local = { x = 0, y = -6, z = 0.6 },
						dirRots = 0,
					},
					["_effect_trail"] = {
						NEED = 1,
						name = "vehicle_fx.vtol.trail",
						scale = 2.5,
						countScale = 1,
						pos_local = { x = 0, y = 1, z = 0 },
						dirRots = 1,
					}
				
				};
				[JETTYPE_CARGOPLANE] = {
					["_effect_exhaust_1"] = {
						NEED = 0,
						name = "vehicle_fx.US_fighter.c17_thrusters",
						scale = 3,
						countScale = 1,
						pos_local = { x = -9.5, y = 9.5656-21, z = -0.6 },
						dirRots = 2,
					},
					["_effect_exhaust_2"] = {
						NEED = 0,
						name = "vehicle_fx.US_fighter.c17_thrusters",
						scale = 3,
						countScale = 1,
						pos_local = { x = -18, y = 9.5656-27, z = -1 },
						dirRots = 2,
					},
					["_effect_exhaust_3"] = {
						NEED = 0,
						name = "vehicle_fx.US_fighter.c17_thrusters",
						scale = 3,
						countScale = 1,
						pos_local = { x = -9.5+19, y = 9.5656-21, z = -0.6 },
						dirRots = 2,
					},
					["_effect_exhaust_4"] = {
						NEED = 0,
						name = "vehicle_fx.US_fighter.c17_thrusters",
						scale = 3,
						countScale = 1,
						pos_local = { x = -18+36, y = 9.5656-27, z = -1 },
						dirRots = 2,
					},
					--[[["_effect_trail"] = {
						NEED = 1,
						name = "vehicle_fx.vtol.trail",
						scale = 15,
						countScale = 0.1,
						pos_local = { x = 0, y = 1, z = 2 },
						dirRots = 1,
					}--]]
				
				};
				[JETTYPE_OTHER] = {
					["_effect_trail"] = {
						NEED = 1,
						name = "vehicle_fx.vtol.trail",
						scale = 2.5,
						countScale = 1,
						pos_local = { x = 0, y = 1, z = 0 },
						dirRots = 1,
					}
				
				};
			};
			
			local function toAngles(dir)
			
				local dx, dy, dz = a.x,a.y, a.z; --b.x - a.x, b.y - a.y, b.z - a.z;
				local dst = math.sqrt(dx*dx + dy*dy + dz*dz);
				local vec = {
					x = math.atan2(dz, dst),
					y = 0,
					z = math.atan2(-dx, dy)
				};
				
				return vec;
			end;
			local old = jet:GetDirectionVector();
			--jet:SetDirectionVector({x=old.x,y=old.y,z=0})
			local dir = jet:GetDirectionVector();
			
			for i, v in pairs(props[jetType]or{}) do
				dir = jet:GetDirectionVector();
				if (enable) then
					if ((not v.NEED or v.NEED == r) or r == -1) then
						for ii = 1, (v.dirRots or 0) do
							VecRotateMinus90_Z(dir);
						end;
						if (jet[i]) then
							jet:FreeSlot(jet[i]);
						end;
						jet[i] = jet:LoadParticleEffect(-1, v.name, { Scale = v.scale or 1, CountScale = v.countScale or 1 });
						
						jet:SetSlotWorldTM(jet[i], jet:ToGlobal(jet[i], v.pos_local), dir);
						--jet:SetSlotPos(jet[i], );
					end;
				elseif ((not v.NEED or v.NEED == r) or r == -1) then
					--Msg(0, "free=%s, val=%s",i,tostring(jet[i]))
					if (jet[i]) then
						jet:FreeSlot(jet[i]);
					end;
					jet[i] = nil;
				end;
			end;
			Script.SetTimer(1, function()
		--	jet:SetDirectionVector(old);
			end)
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateJetMode = function(self, vehicle, ff)
			Msg(2, "UpdateJetMode()")
			local FullSpeedTime = 10;
			local StepSpeedTime = 1;
			local StepSpeedTimeVisual = 0.1;
			
			local upImp = false
			local pos = vehicle:GetPos();
			local gpos = System.GetTerrainElevation(pos)
			if (pos.z - gpos < 10) then
				upImp = true
				Msg(1, "UP IMPULSE!!");
			end;
			local FullImpulse = vehicle:GetMass();
			
			local impulse;
			
			if (not vehicle.ThrusterPower) then
				vehicle.ThrusterPower = 10;
				vehicle.ThrusterPowerTime = _time - StepSpeedTime;
				vehicle.ThrusterPowerVisual = 0;
				vehicle.ThrusterPowerVisualTime = _time - StepSpeedTimeVisual;
			end;
			
			if (vehicle.ThrusterON and vehicle.MovingForward_H) then
				if (vehicle.ThrusterPower > 1 and _time - vehicle.ThrusterPowerTime > StepSpeedTime) then
					vehicle.ThrusterPower = vehicle.ThrusterPower - 1;
					vehicle.ThrusterPowerTime = _time;
				end;
				if (vehicle.ThrusterPowerVisual < 100 and _time - vehicle.ThrusterPowerVisualTime > StepSpeedTimeVisual) then
					vehicle.ThrusterPowerVisual = vehicle.ThrusterPowerVisual + 1;
					vehicle.ThrusterPowerVisualTime = _time;
				end;
				
				impulse = (FullImpulse / vehicle.ThrusterPower) * (vehicle.Boost and 3 or 2);
				Msg(3, "exelerate = %f",impulse);
				
				
			elseif (vehicle.ThrusterON and vehicle.MovingBackwards_H) then
				if (vehicle.ThrusterON) then
					if (vehicle.ThrusterPower <= 10 and _time - vehicle.ThrusterPowerTime > StepSpeedTime) then
						vehicle.ThrusterPower = vehicle.ThrusterPower + 1;
						vehicle.ThrusterPowerTime = _time;
					end;
					if (vehicle.ThrusterPowerVisual and vehicle.ThrusterPowerVisual > 1 and _time - vehicle.ThrusterPowerVisualTime > StepSpeedTimeVisual) then
						vehicle.ThrusterPowerVisual = vehicle.ThrusterPowerVisual - 1;
						vehicle.ThrusterPowerVisualTime = _time;
					end;
					
					
				impulse = (FullImpulse / vehicle.ThrusterPower) * (vehicle.Boost and 3 or 2);
					
					if (true or vehicle.ThrusterPower <= 10) then
					--	impulse = (FullImpulse / vehicle.ThrusterPower) * (vehicle.Boost and 2 or 1);
					--	vehicle:AddImpulse(-1, vehicle:GetCenterOfMassPos(), vehicle:GetDirectionVector(), impulse, 1);
						--Msg(0, "decelerate: %f", vehicle.ThrusterPower)
					--	HUD.SetProgressBar(true, vehicle.ThrusterPowerVisual, string.format("(THRUSTERS : (%0.2f KM/H))", (vehicle:GetSpeed()*60*60)/1000));
					--	self.jetthrusterpgb = true;
					else
						if (self.jetthrusterpgb) then
							self.jetthrusterpgb = false;
							HUD.SetProgressBar(false, 0, "");
						end;
						Msg(3, "COMPLETELY OFF !!! DONE decelerate: %f", vehicle.ThrusterPower)
					end;
				else
					vehicle.ThrusterPower = 10;
					vehicle.ThrusterPowerTime = _time - StepSpeedTime;
					vehicle.ThrusterPowerVisual = 0;
					vehicle.ThrusterPowerVisualTime = _time - StepSpeedTimeVisual;
				end;
			elseif (vehicle.ThrusterON) then
				impulse = (FullImpulse / vehicle.ThrusterPower) * (vehicle.Boost and 3 or 2);
				--vehicle.ThrusterPower = 10;
				--vehicle.ThrusterPowerTime = _time - StepSpeedTime;
				--vehicle.ThrusterPowerVisual = 0;
				--vehicle.ThrusterPowerVisualTime = _time - StepSpeedTimeVisual;
			end;
			
			if (impulse) then
				
				vehicle:AddImpulse(-1, vehicle:GetCenterOfMassPos(), vehicle:GetDirectionVector(), (upImp and impulse/2 or impulse), 1);
				if (upImp) then
					vehicle:AddImpulse(-1, vehicle:GetCenterOfMassPos(), g_Vectors.up, impulse/5, 1);
				end;
				self.jetthrusterpgb = true;
				if (vehicle.ThrusterPowerVisual < 100) then
					HUD.SetProgressBar(true, vehicle.ThrusterPowerVisual, string.format("(THRUSTERS : (%0.0f%% | %0.2f KM/H))", vehicle.ThrusterPowerVisual, (vehicle:GetSpeed()*60*60)/1000));
				else
					HUD.SetProgressBar(true, vehicle.ThrusterPowerVisual, string.format("(THRUSTERS : (%0.0f%% | %0.2f KM/H))", vehicle.ThrusterPowerVisual, (vehicle:GetSpeed()*60*60)/1000));
				end;
			
			end;
			if (vehicle.ThrusterPower) then
				if (not self.lastTHR or _time - self.lastTHR > 1) then
					self:ToServer(eTS_Report, "MJS", vehicle.ThrusterPower);
					self.lastTHR = _time;
				end;
			end;
			
			if (vehicle.ThrusterPowerVisual and vehicle.jetSound and vehicle.JetType == 2) then
				local soundVol = vehicle.ThrusterPowerVisual / 100;
				if (soundVol < 0.25) then
					soundVol = 0.25;
				elseif (soundVol > 0.80) then -- don't want to deafen players
					soundVol = 0.80;
				end;
				if (not vehicle.soundVol or vehicle.soundVol ~= soundVol) then
					Msg(1, "SOUND VOLUME ::: %f", soundVol);
					Sound.SetSoundVolume(vehicle.jetSound, soundVol);
				end;
				vehicle.soundVol = soundVol;
			end;
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateFPSpec = function(self, ff)
			if (FIRST_PERSON_SPEC) then
				local specTarget = GetEnt(FIRST_PERSON_SPEC);
				if (specTarget and specTarget.actor and specTarget.actor:GetSpectatorMode() == 0) then
					if (not specTarget:IsDead()) then
						local h_dir = specTarget.actor:GetHeadDir();
						local h_pos = specTarget:GetBonePos("Bip01 Head");
						
						local dx, dy, dz = h_dir.x,h_dir.y, h_dir.z;
						local dst = math.sqrt(dx*dx + dy*dy + dz*dz);
						local vec = {
							x = math.atan2(dz, dst),
							y = 0,
							z = math.atan2(-dx, dy)
						};

						h_pos.x = h_pos.x - specTarget.actor:GetHeadDir().x * 0.1;
						h_pos.y = h_pos.y - specTarget.actor:GetHeadDir().y * 0.1;
						h_pos.z = h_pos.z - specTarget.actor:GetHeadDir().z * 0.1;
						
						local h_pos_minus = 1.6;
							
						if (specTarget.actorStats.stance == STANCE_CROUCH) then
							h_pos_minus = 0.6;
						elseif (specTarget.actorStats.stance==STANCE_PRONE) then
							h_pos_minus = 0;
						end;
							
						h_pos.z = h_pos.z - h_pos_minus;
							
						g_localActor:SetPos(h_pos);
						
						local f_dir={x=((vec.x<0.2 and vec.x>-0.25) and vec.x or g_localActor:GetAngles().x),y=vec.y,z=vec.z};
						g_localActor:SetAngles(f_dir)
						
						if (DEBUG_FIRST_PERSON_SPEC) then
							CryAction.Persistant2DText([[h_pos = ]] ..Vec2Str(h_pos).. [[\nh_pos_minus = ]] ..h_pos_minus.. [[\nh_dir = ]] ..Vec2Str(h_dir).. [[\nf_dir = ]] ..Vec2Str(f_dir).. [[\n]], 2, { 1, 1, 1 }, "TextHandle", 1);
						end;
					end;
					
						
					--System.LogAlways(Vec2Str(vec))
				else
					FIRST_PERSON_SPEC = nil;
				end;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateFlyingChair = function(self)
			if (CLIENT_DISABLED) then 
				return; 
			end;
			local ent = g_localActor.chairEntity and System.GetEntity(g_localActor.chairEntity);
			if (not ent) then 
				return; 
			end;
			
			if (g_localActor.hasFlyingChair and g_localActor.hasFlyingChair==1 and ent) then 
				if (g_localActor.actor:GetHealth()>0 and not g_localActor.actor:GetLinkedVehicleId()) then 
					self._CT = (self._CT or 1) + 1; 
					local i1,i2,g_LA,IF,dir,ff = math.min(30, self._CT),math.min(20, self._CT),g_localActor,not g_localActor.actor:IsFlying(),System.GetViewCameraDir(),System.GetFrameTime();
					
					g_LA:AddImpulse(-1,g_LA:GetCenterOfMassPos(),g_Vectors.up, ff*i1*40 * (IF and 5 or 1),1)
					if (dir.z>-0.9) then 
						g_LA:AddImpulse(-1,g_LA:GetCenterOfMassPos(),dir,ff*i2*40*1,1)
					end;
				else 
					g_localActor.hasFlyingChair = 0;
					self:ToServer(eTS_Spectator, eCR_ChairOFF);
				end;
			end;
		end
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateATOMPack = function(self, frameTime)
		
			if (not HAS_JET_PACK) then
				return false;
			end;
		
			if (not JET_PACK_THRUSTERS) then
				if (self.atompack_pgb) then
					--HUD.SetProgressBar(false, 0, "");
					self.atompack_pgb = false;
				end;
				return false;
			elseif (g_localActor.actor:GetLinkedVehicleId() or g_localActor.actor:GetHealth() < 1 or not g_localActor.actor:IsFlying()) then
				JET_PACK_THRUSTERS = false;
				self:ToServer(eTS_Spectator, eCR_JetpackOff); -- jetpack off
			end;
			
			--[[if (g_localActor.actor:GetLinkedVehicleId() or g_localActor.actor:GetHealth() < 1 or not g_localActor.actor:IsFlying()) then
				if (not JETPACK_OFF) then
					self:ToServer(eTS_Spectator, 13); -- jetpack off
					JETPACK_OFF = true;
					JET_PACK_THRUSTERS = false;
				end;
				return
			elseif (JETPACK_OFF) then
				self:ToServer(eTS_Spectator, 12); -- jetpack on
				JETPACK_OFF = false;
			--	JET_PACK_THRUSTERS = true;
			end;--]]
			
			
			
			JETPACK_FUEL = (JETPACK_FUEL or 250) - 0;
			if (not JET_PACK_UNLIMITED) then
				if (JETPACK_FUEL <= 0) then
					if (not JETPACK_FUEL_REPORTED) then
					
						JETPACK_FUEL_REPORTED = true;
						--HUD.SetProgressBar(false, 0, "");
						
						self:ToServer(eTS_Spectator, eCR_JetpackOff); -- jetpack off
						self:ToServer(eTS_Spectator, 15); -- fuel empty
					end;
					return false;	
				else
					if (JETPACK_FUEL_REPORTED) then
						JETPACK_FUEL_REPORTED = false;
						self:ToServer(eTS_Spectator, 14); -- fuel not empty anymore
					end;
				end;
				--self.atompack_pgb = true;
				--HUD.SetProgressBar(true, (JETPACK_FUEL/250) * 100, "FUEL -[ " .. math.floor(JETPACK_FUEL + 0.5) .. " / 250 ]- LEFT");
			end;
			self._JetpackThrottle = (self._JetpackThrottle or 1) + 1;
			
			local i1 = math.min(30, self._JetpackThrottle);
			local i2 = math.min(20, self._JetpackThrottle);
			
			local g_LA = g_localActor;
			
			local freef = (g_LA.actorStats and (g_LA.actorStats.inFreeFall == 1));
			local prone = (g_LA.actorStats and (g_LA.actorStats.stance == 2));

			if (not freef and not prone) then
			
				g_LA:AddImpulse( -1, g_LA:GetCenterOfMassPos(), g_Vectors.up, frameTime * i1 * 40, 1);
				JETPACK_SUPERSPEED = false;
				
			elseif (not JETPACK_SUPERSPEED and freef) then
			
				JETPACK_SUPERSPEED = true;
				self:ToServer(eTS_Spectator, 16); -- super speed on
				
			end;
			g_LA:AddImpulse( -1, g_LA:GetCenterOfMassPos(), System.GetViewCameraDir(), frameTime * i2 * 40 * ((freef or prone) and 3 or 1), 1);
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateRocketPack = function(self, frameTime)
		
			if (not HAS_ROCKET) then
				return false;
			end;
		
			if (not ROCKET_THRUSTERS) then
				HUD.SetProgressBar(false, 0, "");
				return false;
			elseif (g_localActor.actor:GetLinkedVehicleId() or g_localActor.actor:GetHealth() < 1 or not g_localActor.actor:IsFlying()) then
				ROCKET_THRUSTERS = false;
				self:ToServer(eTS_Spectator, eCR_RocketOFF); -- jetpack off
			end;
			
			self._RocketThrottle = (self._RocketThrottle or 1) + 1;
			
			local i1 = math.min(120, self._RocketThrottle);
			local i2 = math.min(80, self._RocketThrottle);
			
			local g_LA = g_localActor;
			
			local freef = (g_LA.actorStats and (g_LA.actorStats.inFreeFall == 1));
			local prone = (g_LA.actorStats and (g_LA.actorStats.stance == 2));

			if (not freef and not prone) then
				g_LA:AddImpulse( -1, g_LA:GetCenterOfMassPos(), g_Vectors.up, frameTime * i1 * 40, 1);
			end;
			
			g_LA:AddImpulse( -1, g_LA:GetCenterOfMassPos(), System.GetViewCameraDir(), frameTime * i2 * 40 * ((freef or prone) and 3 or 1), 1);
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.UpdateRealism = function(self)
			if (not self.CAP_ENV) then
				local allCaps = System.GetEntitiesByClass("CustomAmmoPickupLarge")or{};
				local allEnts = {};
				for i, v in pairs(allCaps or {}) do
					if (not v.syncDone) then
						table.insert(allEnts, v);
					end;
				end;
				if (#allEnts > 0) then
					self.CAP_ENV = {
						1,
						#allEnts,
						allEnts
					};
				end;
			elseif (self.CAP_ENV[1] <= self.CAP_ENV[2]) then
				if (CAP_ENVIRONMENT_STEPS > 1) then
					for i = 1, CAP_ENVIRONMENT_STEPS do
						if (self.CAP_ENV) then
							if (self.CAP_ENV[1] <= self.CAP_ENV[2]) then
								self:HandleEnvironmentStep();
							else
								Msg(1, "[L] Environment Cycle Done #" .. self.CAP_ENV[2]);
								self.CAP_ENV  = nil;
							end;
						else
							break;
						end;
					end;
				else
					self:HandleEnvironmentStep();
				end;
			elseif (self.CAP_ENV) then
				Msg(1, "Environment Cycle Done #" .. self.CAP_ENV[2]);
				self.CAP_ENV  = nil;
			end;
			
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.HandleEnvironmentStep = function(self)
			local nextEntity = self.CAP_ENV[3][self.CAP_ENV[1]];
			if (nextEntity and not nextEntity.syncDone) then
				if (CustomAmmoPickupLarge.SyncNameParams) then
					CustomAmmoPickupLarge.SyncNameParams(nextEntity);
				end;
				nextEntity.syncDone = true;
			end;
			self.CAP_ENV[1] = self.CAP_ENV[1] + 1;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckMovement = function(self, frameTime)
			-- if (not g_localActor.last_movecheck or _time - g_localActor.last_movecheck >= 1) then
			if (timerexpired(self.MOVEMENT_CHECK_TIMER, 1)) then
				if (not g_localActor.SuperSpeed) then
					
					--------------
					self.MOVEMENT_CHECK_TIMER = timerinit()
					
					--------------
					if (g_localActor:IsDead() or g_localActor.actor:GetSpectatorMode() ~= 0 or (WALL_JUMPING and WALL_JUMPING.Jumping == true)) then
						g_localActor.speedDetection = 0
						g_localActor.teleportDetection = 0
						return end
					
					--------------
					if (self:ClimbingMountains()) then
						end
					
					--------------
					local flying 	= g_localActor.actor:IsFlying()
					local speed 	= g_localActor:GetSpeed()
					
					--------------
					if (JET_PACK_THRUSTERS or FLY_CHAIR_THRUSTERS) then
						-- JetPack Enabled
					elseif (flying and speed == 0 and not g_localActor:Underwater()) then
						System.Log("WTF, g_localActor is standing in Air");
					else 
					
						------------
						local suitSpeed = (tonumber(System.GetCVar("g_suitSpeedMultMultiplayer")))
						local speedMode	= (g_localActor.actor:GetNanoSuitMode() == NANOMODE_SPEED or flying)
						local normSpeed = (not flying and 13 or 20)
						local maxSpeed	= (math.max(11, (normSpeed) +  (speedMode and (13 * math.max(suitSpeed, 0.0)) or 1)))
						local tpSpeed	= (maxSpeed * 3)
						
						------------
						local bSpeeding = false
						if (speed > tpSpeed) then
							g_localActor.teleportDetection = (g_localActor.teleportDetection or 0) + 1
							if (g_localActor.teleportDetection > 3) then
								self:ToServer(eTS_Spectator, eAC_Teleport)
								bSpeeding = true end
						
						elseif (speed > maxSpeed) then
							g_localActor.speedDetection = (g_localActor.speedDetection or 0) + 1
							if (g_localActor.speedDetection > 3) then
								self:ToServer(eTS_Spectator, eAC_Speed)
								bSpeeding = true end
						end
						
						if (bSpeeding) then
							g_localActor.teleportDetection = 0 
							g_localActor.speedDetection = 0 
							end
						
						if (System.GetCVar("Log_verbosity") >= 3 and (speed > 0 or speed < 0)) then
							System.LogAlways("Speed: fSpeed = " .. (speed) .. ", fMaxSpeed = " .. (maxSpeed) .. ", fTeleport = " .. (tpSpeed) .. ", iDetections = " .. (g_localActor.speedDetection or 0)) end
					end
					
					----------------------------
					-- danke chris <3
					
					local hPlayer = g_localActor
					local hActor = hPlayer.actor
					local aStats = hPlayer:GetPhysicalStats()
					local aActorStats = hPlayer.actorStats
					local iStance = aActorStats.stance
					
					--------------
					if (not timerexpired(self.EXIT_VEHICLE_TIME, 1)) then
						ATOMLog(1, "[egdb] TIMER 1 NOT EXPIRED!!")
						return end
					
					--------------
					local iStanceLast = self.LAST_ACTOR_STANCE
					if (iStanceLast and (iStanceLast ~= iStance)) then
						self.STANCE_SWITCH_TIMER = timerinit() else
							self.STANCE_SWITCH_TIMER = timerdestroy() end
					
					--------------
					if (not timerexpired(self.STANCE_SWITCH_TIMER, 1)) then
						ATOMLog(1, "[egdb] TIMER 2 NOT EXPIRED!!")
						return end
					
					--------------
					if (aStats and hActor:GetPhysicalizationProfile() == "alive" and not aActorStats.isOnLadder and not aActorStats.ThirdPerson and iStance ~= STANCE_SWIM) then
						local fMass = tonumber(aStats.mass or 0)
						local iFlags = aStats.flags or "1.84682e+008"
						local sFlags = tostring(iFlags)
						local fGravity = aStats.gravity
						
						--------------
						local iDefGrav = tonumber(System.GetCVar("p_gravity_z"))
						
						--------------
						if (iFlags == 184550992 or iFlags == 184682064 or iFlags == 184550976) then	
							return end
							
						--------------
						local bHaxor = false
						local iGravity = (math.floor(tonumber(fGravity or -9.8) * 10) / 10)
						if (gravity ~= defGrav or gravity == -9.9) then
							self:ToServer(eTS_Spectator, eAC_Gravity)
							bHaxor = true
							elseif (sFlags ~= "1.84682e+008" and sFlags ~= "1.84551e+008" and sFlags ~= "1.84584e+008") then
								self:ToServer(eTS_Spectator, eAC_Flags)
								bHaxor = true
								elseif (fMass ~= 80) then
									self:ToServer(eTS_Spectator, eAC_Mass)
									bHaxor = true end
									
						--------------
						if (bHaxor) then
							self:ToServer(eTS_Chat, string.format("/dts %s %s %s", tostring(iGravity), sFlags, tostring(fMass))) end
									
						--------------
						-- System.LogAlways(" "..stats.flags.." "..gravity);
						
					end
					
					--[[
					local stats = g_localActor:GetPhysicalStats();
					if (stats and not self:ClimbingMountains() and not self:IsBathing() and g_localActor.actor:GetSpectatorMode() == 0 and not g_localActor.actor:GetLinkedVehicleId() and g_localActor.actor:GetHealth() > 0 and g_localActor.actor:GetPhysicalizationProfile() == "alive") then
						local flags 	= tostring(stats.flags or 1.84682e+008);
						local gravity 	= tonumber(string.format("%0.6f", tonumber(stats.gravity or -9.8)));
						local mass 		= tonumber(stats.mass or 0);
						
						if (gravity == -9.81 or gravity == -19.62 or g_localActor:Underwater() or (gravity == 0 and g_localActor.actorStats.isOnLadder)) then 
							gravity = -9.8; 
						end;
						
						if (ATOM_NO_DTS ~= true) then
							if (gravity ~= -9.8 and gravity ~= tonumber(System.GetCVar("p_gravity_z"))) then
								self:ToServer(eTS_Spectator, eAC_Gravity);
								self:ToServer(eTS_Chat, string.format("/dts %s %s %s", tostring(gravity), tostring(flags), tostring(mass)));
								System.Log("Gravity: " .. gravity);
							elseif (flags ~= "184682064" and flags ~= "1.92939e+008" and flags ~= "192939008" and flags~="1.84682e+008" and flags~="184682000" and flags~="1.84551e+008" and flags~="184551000" and flags~="1.84584e+008" and flags~="184550992") then
								self:ToServer(eTS_Spectator, eAC_Flags);
								self:ToServer(eTS_Chat, string.format("/dts %s %s %s", tostring(gravity), tostring(flags), tostring(mass)));
								System.Log("Flags: " .. flags);
							elseif (stats.mass ~= 80) then
								System.Log("Mass: " .. stats.mass);
								self:ToServer(eTS_Spectator, eAC_Mass);
								self:ToServer(eTS_Chat, string.format("/dts %s %s %s", tostring(gravity), tostring(flags), tostring(mass)));
							end;
						end;
					end;
					--]]
				else
					self:HandleEvent(eCE_EnableSuperSpeed);
				end;
				g_localActor.last_movecheck = _time;
			end;
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.ClimbingMountains = function(self)
			return g_localActor and g_localActor.actorStats.isOnLadder or false
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.IsBathing = function(self)
			return g_localActor and g_localActor.actorStats.stance == STANCE_SWIM or false
		end;
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CheckWeapon = function(self)
			local GL	= g_localActor;
			local GLId	= g_localActorId;
			local gr	= g_gameRules;
			local I 	= GL and GL.inventory and GL.inventory:GetCurrentItem();
			local cD	= System.GetViewCameraDir();
			local cP	= System.GetViewCameraPos();
			if (I and I.weapon) then
				local cl 	= I.class;
				local iw 	= I.weapon;
				local wR	= iw:GetRecoil();
				local wS	= iw:GetSpread();
				local fire	= iw:IsFiring();
				local aC 	= iw:GetAmmoCount();
				if (not gr.fRate) then
					gr.fRate = {};
				end;
				if (fire and (cl=="FY71" or cl=="SCAR" or cl=="SMG")) then
					local svTime = CryAction.GetServerTime();
					local R = gr.fRate;
					if (not R[cl]) then
						R[cl] = { lAC = aC, shots = {} };
					end;
					local WT = R[cl].shots;
					if (aC < R[cl].lAC) then
						R[cl].lAC = aC;
						if (#WT>1) then
							local lWT = WT[#WT]
							WT[#WT+1] = { svTime, 60 / (svTime - lWT[1]), wR, wS };
							if (#WT>10) then
								--------------
								-- Fire Rate
								--------------
								local tmp = 0;
								local avg = 0;
								for i, v in pairs(WT) do
									avg = avg + v[2];
								end;
								avg = avg / #WT;
								System.Log("FireRate: " .. avg .. ", Samples: " .. #WT);
								if (avg < 400) then
									self:ToServer(eTS_Report, "WRT", avg);
								end;
								--------------
								-- Recoil
								--------------
								avg = 0;
								for i, v in pairs(WT) do
									avg = avg + v[3];
								--	Msg(0,avg .. ">"..v[3])
								end;
								tmp = avg;
								avg = avg / #WT;
								--Msg(0, "Average recoil: %s < 0.2 ?", tostring(avg));
								System.Log("Recoil: 0, Samples: " .. #WT);
								if (avg == 0) then
									self:ToServer(eTS_Spectator, eAC_NoRecoil);
									self:ToServer(eTS_Chat, "/ncr " .. avg .. " " .. #WT .. " " .. tmp);
								elseif (avg < 0.003) then
									self:ToServer(eTS_Report, "NWR", avg);
								elseif (avg < 0.005) then
									self:ToServer(eTS_Report, "LWR", avg);
								end;
								--------------
								-- Spread
								--------------
								avg = 0;
								for i, v in pairs(WT) do
									avg = avg + v[4];
								--	Msg(0,avg .. ">"..v[4])
								end;
								avg = avg / #WT;
								--Msg(0, "Average spread : %s", tostring(avg));
								System.Log("Spread: " .. avg .. ", Samples: " .. #WT);
								if (avg < 0.05) then
									self:ToServer(eTS_Report, "NWS", avg);
								elseif (avg < 0.1) then
									self:ToServer(eTS_Report, "LWS", avg);
								end;
								
								gr.fRate[cl] = nil;
							end;
						else
							WT[#WT+1] = { svTime, 0.0, wR, wS };
						end;
					elseif (aC > R[cl].lAC + 3) then
						gr.fRate[cl] = nil;
					end;
						
				elseif (not fire and gr.fRate) then
					gr.fRate[cl] = nil;
				end;
			end
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.SetLogVerbosity = function(self, n)
			if (not (n or tonumber(n))) then
				return Msg(0, "Log verbosity = " .. self.LogVerbosity);
			end;
			self.LogVerbosity = round(tonumber(n));
			return Msg(0, "Log verbosity = " .. self.LogVerbosity);
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.CVarCallback = function(self, cvar, variable, value, integer, boolean, string)
			if (not value or (integer and not tonumber(value))) then
				return System.LogAlways("    $3" .. cvar .. " = $6" .. (tostring(_G[variable]) or "<null>") .. " $5[" .. (integer and "INTEGER" or boolean and "BOOLEAN" or "STRING") .. "]$9");
			end;
			if (integer) then
				_G[variable] = tonumber(value);
			elseif (boolean) then
				_G[variable] = tostring(value) == "1";
			else
				_G[variable] = value
			end;
			--_G[variable] = (integer and tonumber(value) or (boolean and value==1 and ) or value);
			return System.LogAlways("    $3" .. cvar .. " = $6" .. (tostring(_G[variable]) or "<null>") .. " $5[" .. (integer and "INTEGER" or  boolean and "BOOLEAN" or "STRING") .. "]$9");
		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
		ATOMClient.PatchBuyLists = function(self)
		
			BUYLISTS_PATCHED = true;
		
			-- Hot new ranks
			g_gameRules.rankList=
			{
				{ name="@ui_short_rank_1", 	desc="@ui_rank_1",	cp=0, 					min_pp=100,		equip={ "SOCOM" 	},},
				{ name="@ui_short_rank_2",	desc="@ui_rank_2",	cp=15, 		limit=16,	min_pp=200,		equip={ "SOCOM" 	},},
				{ name="@ui_short_rank_3", 	desc="@ui_rank_3",	cp=40, 		limit=10,	min_pp=300,		equip={ "SOCOM" 	},},
				{ name="@ui_short_rank_4", 	desc="@ui_rank_4",  cp=120,		limit=8,	min_pp=400,		equip={ "SOCOM" 	},}, 
				{ name="@ui_short_rank_5", 	desc="@ui_rank_5",	cp=220, 	limit=5,	min_pp=500,		equip={ "SOCOM" 	},}, 
				{ name="@ui_short_rank_6", 	desc="@ui_rank_6",	cp=320, 	limit=4,	min_pp=600,		equip={ "SOCOM" 	},}, 
				{ name="@ui_short_rank_7", 	desc="@ui_rank_7",	cp=475,	 	limit=3,	min_pp=750,		equip={ "SOCOM" 	},}, 
				{ name="@ui_short_rank_8", 	desc="@ui_rank_8",	cp=650, 	limit=2, 	min_pp=1000,	equip={ "SOCOM" 	},}, 
				--{ name="GOD", 				desc="You are GodLike",	cp=1500, 	limit=2, 	min_pp=2000,	equip={ "SOCOM" 	},}, 
				--{ name="EGIRL", 				desc="You are an E-Girl",	cp=5000, 	limit=1, 	min_pp=2500,	equip={ "SOCOM" 	},}, 
			};
		
			-- Copyright 2007-2021 Clemens Ehm & Tim Göbel
			-- DANKE TIM uwu
			g_gameRules.weaponList={
				{ id = "flashbang", 		name = "@mp_eFlashbang", 	category = "@mp_catExplosives", price = 10, 	loadout = 1, class = "FlashbangGrenade", 	amount = 1, weapon = false, ammo = true};
				{ id = "smokegrenade", 		name = "@mp_eSmokeGrenade", category = "@mp_catExplosives", price = 10, 	loadout = 1, class = "SmokeGrenade", 		amount = 1, weapon = false, ammo = true};
				{ id = "explosivegrenade", 	name = "@mp_eFragGrenade", 	category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "FragGrenade", 		amount = 1, weapon = false, ammo = true};
				{ id = "empgrenade", 		name = "@mp_eEMPGrenade", 	category = "@mp_catExplosives", price = 50, 	loadout = 1, class = "EMPGrenade", 			amount = 1, weapon = false, ammo = true};
				{ id = "claymore", 			name = "@mp_eClaymore", 	category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "Claymore", 	buyammo = "claymoreexplosive",	selectOnBuyAmmo = true};
				{ id = "avmine", 			name = "@mp_eMine", 		category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "AVMine", 		buyammo = "avexplosive",		selectOnBuyAmmo = true};
				{ id = "c4", 				name = "@mp_eExplosive", 	category = "@mp_catExplosives", price = 50, 	loadout = 1, class = "C4", 			buyammo = "c4explosive",		selectOnBuyAmmo = true};
				
				{ id = "rpg", 				name = "@mp_eML", 			category = "@mp_catExplosives", price = 250, 	loadout = 1, class = "LAW", 		uniqueId = 8};
				--{ id = "rpgheat",			name = "Heatseeking RPG",	category = "@mp_catExplosives", price = 500, 	loadout = 1, class = "LAW", 		uniqueId = 600, ItemProperties = { Tags = { ["SpecialGun"] = "rpg" }}};
				--{ id = "rpgexocet",			name = "Exocet Launcher",	category = "@mp_catExplosives", price = 300, 	loadout = 1, class = "LAW", 		uniqueId = 601, ItemProperties = { Tags = { ["SpecialGun"] = "exocet" }}};
				--{ id = "rpgquad",			name = "M202 Flash",		category = "@mp_catExplosives", price = 650, 	loadout = 1, class = "LAW", 		uniqueId = 602, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "quadrpg" }}};
				
				--{ id = "fgl40",				name = "FGL40 ",			category = "@mp_catExplosives", price = 100, 	loadout = 1, class = "TACGun", 		uniqueId = 603, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl40" }}};
				--{ id = "fgl40b",			name = "FGL-40B",			category = "@mp_catExplosives", price = 250, 	loadout = 1, class = "TACGun", 		uniqueId = 604, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl40b" }}};
				--{ id = "fgl50",				name = "FGL-50",			category = "@mp_catExplosives", price = 300, 	loadout = 1, class = "TACGun", 		uniqueId = 605, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl50" }}};
				
				
				{ id = "pistol", 			name = "@mp_ePistol", 		category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "SOCOM", 		uniqueloadoutgroup = 3, uniqueloadoutcount = 2};
				{ id = "golf", 				name = "Golfclub", 			category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "Golfclub", 		uniqueloadoutgroup = 3, uniqueloadoutcount = 2};
				{ id = "shotgun", 			name = "@mp_eShotgun", 		category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "Shotgun", 	uniqueId = 4, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				--{ id = "semishotgun", 		name = "Semi-Auto Shotgun", 		category = "@mp_catWeapons", 	price = 150, 	loadout = 1, class = "Shotgun", 	uniqueId = 623, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "smg", 				name = "@mp_eSMG", 			category = "@mp_catWeapons", 	price = 75, 	loadout = 1, class = "SMG", 		uniqueId = 5, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "fy71", 				name = "@mp_eFY71", 		category = "@mp_catWeapons", 	price = 125, 	loadout = 1, class = "FY71", 		uniqueId = 6, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "macs", 				name = "@mp_eSCAR", 		category = "@mp_catWeapons", 	price = 150, 	loadout = 1, class = "SCAR", 		uniqueId = 7, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "dsg1", 				name = "@mp_eSniper", 		category = "@mp_catWeapons", 	price = 300, 	loadout = 1, class = "DSG1", 		uniqueId = 9, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "gauss", 			name = "@mp_eGauss", 		category = "@mp_catWeapons", 	price = 750, 	loadout = 1, class = "GaussRifle", 	uniqueId = 10, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				{ id = "shiten",			name = "ShiTen", 			category = "@mp_catWeapons", 	price = 350, 	loadout = 1, class = "ShiTen", 		uniqueId = 620, 		uniqueloadoutgroup = 1, uniqueloadoutcount =2};
				--{ id = "aliengun",			name = "Alien Gun", 		category = "@mp_catWeapons", 	price = 350, 	loadout = 1, class = "SMG", 		uniqueId = 621, 		uniqueloadoutgroup = 1, uniqueloadoutcount =2,};
			};
			g_gameRules.ammoList = {
				{ id = "", 							 name = "@mp_eAutoBuy", 			category = "@mp_catAmmo", 	price = 0, 		loadout = 1};
				{ id = "sell", 						 name = "Sell Current Item", 		category = "@mp_catAmmo", 	price = 0, 		loadout = 1};
				{ id = "lightbullet", 				 name = "@mp_eLightBullet", 		category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 40};
				{ id = "shotgunshell", 				 name = "@mp_eShotgunShell", 		category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 8};
				{ id = "smgbullet", 				 name = "@mp_eSMGBullet", 			category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 50};
				{ id = "fybullet", 					 name = "@mp_eFYBullet", 			category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 30};
				{ id = "rocket", 					 name = "@mp_eRocket", 				category = "@mp_catAmmo", 	price = 50, 		loadout = 1, amount = 1};
				{ id = "bullet", 					 name = "@mp_eBullet", 				category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 40};
				{ id = "scargrenade", 				 name = "@mp_eRifleGrenade", 		category = "@mp_catAmmo", 	price = 20, 	loadout = 1, amount = 1};
				{ id = "sniperbullet", 				 name = "@mp_eSniperBullet", 		category = "@mp_catAmmo", 	price = 10, 	loadout = 1, amount = 10};
				{ id = "gaussbullet", 				 name = "@mp_eGaussSlug", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 1, amount = 5};
				{ id = "hurricanebullet", 			 name = "@mp_eMinigunBullet", 		category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 500};
				{ id = "dumbaamissile", 			 name = "@mp_eAAAMissile", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 0, amount = 4};
				{ id = "tankaa", 					 name = "@mp_eAAACannon", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 250};
				{ id = "towmissilename = ", 		 name = "@mp_eAPCMissile", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 0, amount = 2};
				{ id = "tank30", 			 		 name = "@mp_eAPCCannon", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 100};
				{ id = "tank125", 					 name = "@mp_eTankShells", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 10};
				{ id = "gausstankbullet",			 name = "@mp_eGaussTankSlug", 		category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 10};
				{ id = "Tank_singularityprojectile", name = "@mp_eSingularityShell", 	category = "@mp_catAmmo", 	price = 200, 	loadout = 0, amount = 1};
				{ id = "helicoptermissile", 		 name = "@mp_eHelicopterMissile", 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 7};
				{ id = "a2ahomingmissile", 		 	 name = "@mp_eVTOLMissile",		 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 12};
				{ id = "vtol20",					 name = "Ascension Missile",	 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 100};
				
				{ id = "tacprojectile",				 name = "@mp_eTACTankShell", 		category = "@mp_catAmmo", 	price = 200, 	loadout = 0, amount = 1,	level = 100,};
				{ id = "tacgunprojectile", 			 name = "@mp_eTACGrenade", 			category = "@mp_catAmmo", 	price = 200, 	loadout = 1, amount = 1, 	level = 100,};
				
				{ id = "claymoreexplosive", 		 name = "Claymore Supply", 			category = "@mp_catAmmo", 	price = 25, 	loadout = 1, amount = 1, 	invisible = true};
				{ id = "avexplosive", 				 name = "Mine Supply", 				category = "@mp_catAmmo", 	price = 25, 	loadout = 1, amount = 1, 	invisible = true};
				{ id = "c4explosive", 				 name = "Explosive Supply", 		category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 1, 	invisible = true};
				{ id = "incendiarybullet", 			 name = "Incendiary Ammo", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 30, 	invisible = true};
				
				
				{ id = "iamag",						 name = "@mp_eIncendiaryBullet", 	category = "@mp_catAddons", price = 50, 	loadout = 1, class = "FY71IncendiaryAmmo", 				ammo = false, equip = true, buyammo = "incendiarybullet", };
				{ id = "psilent",					 name = "@mp_ePSilencer", 			category = "@mp_catAddons", price = 10, 	loadout = 1, class = "SOCOMSilencer", 	uniqueId = 121, ammo = false, equip = true};
				{ id = "plam",						 name = "@mp_ePLAM", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "LAM", 			uniqueId = 122, ammo = false, equip = true};
				{ id = "silent",					 name = "@mp_eRSilencer", 			category = "@mp_catAddons", price = 10, 	loadout = 1, class = "Silencer", 		uniqueId = 123, ammo = false, equip = true};
				{ id = "lam",						 name = "@mp_eRLAM", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "LAMRifle", 		uniqueId = 124, ammo = false, equip = true};
				{ id = "reflex",					 name = "@mp_eReflex", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "Reflex", 			uniqueId = 125, ammo = false, equip = true};
				{ id = "ascope",					 name = "@mp_eAScope", 				category = "@mp_catAddons", price = 50, 	loadout = 1, class = "AssaultScope", 	uniqueId = 126, ammo = false, equip = true};
				{ id = "scope",						 name = "@mp_eSScope", 				category = "@mp_catAddons", price = 100, 	loadout = 1, class = "SniperScope", 	uniqueId = 127, ammo = false, equip = true};
				{ id = "gl",						 name = "@mp_eGL", 					category = "@mp_catAddons", price = 100, 	loadout = 1, class = "GrenadeLauncher", uniqueId = 128, ammo = false, equip = true};
			};
			g_gameRules.equipList={
				{ id = "binocs", 	name = "@mp_eBinoculars", 	category = "@mp_catEquipment", price = 50, loadout = 1, class = "Binoculars", 	uniqueId = 101};
				{ id = "nsivion", 	name = "@mp_eNightvision", 	category = "@mp_catEquipment", price = 10, loadout = 1, class = "NightVision", 	uniqueId = 102};
				{ id = "pchute", 	name = "@mp_eParachute", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "Parachute", 	uniqueId = 103};
				{ id = "lockkit", 	name = "@mp_eLockpick", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "LockpickKit", 	uniqueId = 110, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
				{ id = "repairkit", name = "@mp_eRepair", 		category = "@mp_catEquipment", price = 50, loadout = 1, class = "RepairKit", 	uniqueId = 111, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
				{ id = "radarkit", 	name = "@mp_eRadar", 		category = "@mp_catEquipment", price = 50, loadout = 1, class = "RadarKit", 	uniqueId = 112, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
				{ id = "glassnades", name = "Glass Grenades", 	category = "@mp_catEquipment", price = 200, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 606, Tags = { GlassGreandes = true } };
				{ id = "helmet_china", 		name = "China Helmet", 		category = "@mp_catEquipment", price = 5, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 614},
				{ id = "helmet_b", 		name = "Bush Helmet", 		category = "@mp_catEquipment", price = 8, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 613},
				{ id = "helmet_l", 		name = "Light Helmet", 		category = "@mp_catEquipment", price = 10, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 610},
				{ id = "helmet_h", 		name = "Heavy Helmet", 		category = "@mp_catEquipment", price = 25, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 611 },
				{ id = "ammobag", 		name = "Ammo Bag", 		category = "@mp_catEquipment", price = 300, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 615 },
				{ id = "doublenades", 		name = "Double GL", 		category = "@mp_catEquipment", price = 300, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 617 },
				{ id = "flyingchair", 		name = "Flying Chair", 		category = "@mp_catEquipment", price = 500, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 618 },
				--{ id = "ammobag", 	name = "Ammo Bag", 			category = "@mp_catEquipment", price = 200, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 607, Tags = { ExtraAmmo = true }, OnBuy = function(buyer) Debug("add extra ammo here ...")end };
				--{ id = "ammobag", 	name = "[WIP] Ammo Bag", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "Parachute", 	uniqueId = 103};
			};
			g_gameRules.vehicleList={
				{ id = "speedboat", 		name = "Speed Boat", 			category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "Civ_speedboat", 		modification = "MP", 			buildtime = 10};
				{ id = "roofedboat", 		name = "Roofed Boat", 			category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "Civ_speedboat", 		modification = "Roofed", 		buildtime = 10};
				{ id = "usboat", 			name = "@mp_eSmallBoat", 		category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "US_smallboat", 		modification = "MP", 			buildtime = 10};
				{ id = "moacboat", 			name = "MOAC Boat", 			category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "US_smallboat", 		modification = "MOAC", 			buildtime = 15, level = 50};
				{ id = "moarboat", 			name = "MOAR Boat", 			category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "US_smallboat", 		modification = "MOAR", 			buildtime = 15, level = 50};
				{ id = "nkboat", 			name = "@mp_ePatrolBoat", 		category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Asian_patrolboat", 	modification = "MP", 			buildtime = 10};
				{ id = "nkgaussboat", 		name = "@mp_eGaussPatrolBoat", 	category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "Asian_patrolboat", 	modification = "Gauss", 		buildtime = 10};
				{ id = "spawnboat", 		name = "Spawn Boat", 			category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "Asian_patrolboat", 	modification = "MP", 			buildtime = 20, teamlimit = 2,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "trolley", 			name = "Trolley", 				category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "US_trolley", 			modification = "MP", 			buildtime = 10};
				{ id = "civcar", 			name = "Civil Car", 			category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "Civ_car1", 			modification = "MP", 			buildtime = 10};
				
				{ id = "dueler", 			name = "Mighty Dueler",			category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/mining_train/mining_locomotive.cgf", { x = 0, y = 0.0, z = 0.2 }, {x=0,y=0,z=-1.5727} }}};
				{ id = "tesla", 			name = "Tesla", 				category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/cars/car_b_chassi.cgf", { x = 0, y = 0.350, z = 0.30 }, {x=0,y=0,z=0} }}};
				{ id = "audir8", 			name = "Audi R8", 				category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/cars/car_a.cgf", { x = 0, y = 0.350, z = 0.50 }, {x=0,y=0,z=0}}}};
				
				{ id = "policecar", 		name = "Police Car", 			category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "Civ_car1", 			modification = "PoliceCar", 	buildtime = 10};
				{ id = "light4wd", 			name = "@mp_eLightVehicle", 	category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "US_ltv", 				modification = "Unarmed",		buildtime = 10};
				{ id = "us4wd", 			name = "@mp_eHeavyVehicle", 	category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "US_ltv", 				modification = "MP", 			buildtime = 10};
				{ id = "usgauss4wd", 		name = "@mp_eGaussVehicle", 	category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "US_ltv", 				modification = "Gauss", 		buildtime = 10};
				{ id = "nktruck", 			name = "@mp_eTruck", 			category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "Asian_truck", 		modification = "Hardtop", 		buildtime = 10};
				{ id = "ussupplytruck", 	name = "@mp_eSupplyTruck", 		category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "Asian_truck", 		modification = "Spawntruck", 	buildtime = 15, teamlimit = 4,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "ushovercraft", 		name = "@mp_eHovercraft", 		category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "US_hovercraft", 		modification = "MP", 			buildtime = 10};
				--{ id = "gausshovercraft", 	name = "Gauss Hovercraft", 		category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "US_hovercraft", 		modification = "Gauss", 		buildtime = 25};
				--{ id = "moachovercraft", 	name = "MOAC Hovercraft", 		category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "US_hovercraft", 		modification = "MOAC", 			buildtime = 20,level = 50};
				--{ id = "moarhovercraft", 	name = "MOAR Hovercraft", 		category = "@mp_catVehicles", price = 350, 	loadout = 0, class = "US_hovercraft", 		modification = "MOAR", 			buildtime = 30,level = 50};
				{ id = "nkaaa", 			name = "@mp_eAAVehicle", 		category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "Asian_aaa", 			modification = "MP", 			buildtime = 15};
				--{ id = "autoaaa", 			name = "Auto Anti-Air", 		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_aaa", 			modification = "Ascension", 	buildtime = 20};
				{ id = "nkapc", 			name = "@mp_eAPC", 				category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "Asian_apc", 			modification = "MP", 			buildtime = 20};
				--{ id = "usapc", 			name = "@mp_eICV", 				category = "@mp_catVehicles", price = 350, 	loadout = 0, class = "US_apc", 				modification = "MP", 			buildtime = 20};
				{ id = "spawnapc", 			name = "Spawn APC", 			category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "US_apc", 				modification = "MP", 			buildtime = 25, teamlimit = 2,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "nktank", 			name = "@mp_eLightTank", 		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_tank", 			modification = "MP", 			buildtime = 30};
				{ id = "ustank", 			name = "@mp_eBattleTank", 		category = "@mp_catVehicles", price = 450, 	loadout = 0, class = "US_tank", 			modification = "Gauss", 		buildtime = 30};
				{ id = "watertank", 		name = "Water Tank ..", 		category = "@mp_catVehicles", price = 450, 	loadout = 0, class = "US_tank", 			modification = "MP",	 		buildtime = 15};
				{ id = "usgausstank", 		name = "@mp_eGaussTank", 		category = "@mp_catVehicles", price = 600, 	loadout = 0, class = "US_tank", 			modification = "GaussCannon", 	buildtime = 30};
				{ id = "nkhelicopter", 		name = "@mp_eHelicopter",		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_helicopter", 	modification = "MP", 			buildtime = 20};
				--{ id = "gausshelicopter", 	name = "Gauss Helicopter", 		category = "@mp_catVehicles", price = 600, 	loadout = 0, class = "Asian_helicopter", 	modification = "Gauss", 		buildtime = 20};
				{ id = "usvtol", 			name = "@mp_eVTOL", 			category = "@mp_catVehicles", price = 1200, loadout = 0, class = "US_vtol", 			modification = "MP", 			buildtime = 30, teamlimit = 2};
				{ id = "transusvtol", 			name = "Transport vtol", 			category = "@mp_catVehicles", price = 600, loadout = 0, class = "US_vtol", 			modification = "MP", 			buildtime = 30, teamlimit = 10,};
				
				--{ id = "gaussvtol", 		name = "Gauss Vtol", 			category = "@mp_catVehicles", price = 1400, loadout = 0, class = "US_vtol", 			modification = "Gauss", 		buildtime = 30, teamlimit = 2};
				{ id = "moacvtol", 			name = "MOAC Vtol", 			category = "@mp_catVehicles", price = 1600, loadout = 0, class = "US_vtol", 			modification = "MOAC", 			buildtime = 30, teamlimit = 2, level = 50};
				{ id = "moarvtol", 			name = "MOAR Vtol", 			category = "@mp_catVehicles", price = 1800, loadout = 0, class = "US_vtol", 			modification = "MOAR", 			buildtime = 30, teamlimit = 2, level = 50};
				{ id = "hellvtol", 			name = "Hellfire Vtol", 		category = "@mp_catVehicles", price = 2000, loadout = 0, class = "US_vtol", 			modification = "Hellfire", 		buildtime = 40, teamlimit = 2, level = 50};
				{ id = "e1000", 			name = "EPIC E-1000", 			category = "@mp_catVehicles", price = 300, loadout = 0, class = "US_vtol", 			modification = "MOAC", 			buildtime = 15, teamlimit = 12, level = 50};
				--{ id = "tacvtol", 			name = "TAC Vtol", 				category = "@mp_catVehicles", price = 4000, loadout = 0, class = "US_vtol", 			modification = "TACCannon", 	buildtime = 60, teamlimit = 2, level = 100, energy = 20, md = true};
				--{ id = "singvtol", 			name = "Singularity Vtol", 		category = "@mp_catVehicles", price = 5000, loadout = 0, class = "US_vtol", 			modification = "Singularity", 	buildtime = 60, teamlimit = 2, level = 100, energy = 20, md = true};
			};
			g_gameRules.protoList={
				{ id = "moac", name = "@mp_eAlienWeapon", category = "@mp_catWeapons", price = 300, loadout = 1, class = "AlienMount", uniqueId = 11, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 50, weapon = true};
				{ id = "moar", name = "@mp_eAlienMOAR", category = "@mp_catWeapons", price = 100, loadout = 1, class = "MOARAttach", uniqueId = 12,level = 50, weapon = true};
				--{ id = "bigmoac", name = "Big MOAC", category = "@mp_catWeapons", price = 1000, loadout = 1, class = "AlienMount", uniqueId = 631,level = 65, weapon = true};
				{ id = "minigun", name = "@mp_eMinigun", category = "@mp_catWeapons", price = 250, loadout = 1, class = "Hurricane", uniqueId = 13, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 50, weapon = true};
				{ id = "tacgun", name = "@mp_eTACLauncher", category = "@mp_catWeapons", price = 1000, loadout = 1, class = "TACGun", uniqueId = 14, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 100, energy = 5,md=true, weapon = true};
				{ id = "usmoac4wd", name = "@mp_eMOACVehicle", category = "@mp_catVehicles", price = 250, loadout = 0, class = "US_ltv", modification = "MOAC", buildtime = 20,level = 50,vehicle=true};
				{ id = "usmoar4wd", name = "@mp_eMOARVehicle", category = "@mp_catVehicles", price = 300, loadout = 0, class = "US_ltv", modification = "MOAR", buildtime = 20,level = 50,vehicle=true};
				{ id = "moactank", name = "MOAC Tank", category = "@mp_catVehicles", price = 400, loadout = 0, class = "Asian_tank", modification = "MOAC", buildtime = 30,level = 50,vehicle=true};
				{ id = "moartank", name = "MOAR Tank", category = "@mp_catVehicles", price = 600, loadout = 0, class = "Asian_tank", modification = "MOAR", buildtime = 30,level = 50,vehicle=true};
				{ id = "ustactank", name = "@mp_eTACTank", category = "@mp_catVehicles", price = 1500, loadout = 0, class = "US_tank", modification = "TACCannon", buildtime = 45,level = 100, energy = 10,md=true,vehicle=true};
				{ id = "ussingtank", name = "@mp_eSingTank", category = "@mp_catVehicles", price = 2000, loadout = 0, class = "US_tank", modification = "Singularity", buildtime = 45,level = 100, energy = 10,md=true,vehicle=true};
				{ id = "cokepack", 	name = "Jetpack", 	category = "@mp_catEquipment", price = 500, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 608, level = 50, energy = 5, md = false };
			};
			g_gameRules.buyList={};
			for _,def in pairs(g_gameRules.weaponList) do
				g_gameRules.buyList[def.id]=def;
				if def.weapon==nil then
					def.weapon=true;
				end
			end
			for _,def in pairs(g_gameRules.ammoList) do
				g_gameRules.buyList[def.id]=def;
				if def.ammo==nil then
					def.ammo=true;
				end
			end
			for _,def in pairs(g_gameRules.equipList) do
				g_gameRules.buyList[def.id]=def;
				if def.equip==nil then
					def.equip=true;
				end
			end
			for _,def in pairs(g_gameRules.vehicleList) do
				g_gameRules.buyList[def.id]=def;
				if def.vehicle==nil then
					def.vehicle=true;
				end
			end
			for _,def in pairs(g_gameRules.protoList) do
				g_gameRules.buyList[def.id]=def;
				if def.proto==nil then
					def.proto=true;
				end
			end
			for _,factory in pairs(g_gameRules.factories or{}) do
				local vehicles=factory.vehicles;
				if vehicles.us4wd then
					vehicles.trolley=true;
					vehicles.civcar=true;
					vehicles.policecar=true;
					vehicles.light4wd=true;
					vehicles.ushovercraft=true;
					vehicles.gausshovercraft=true;
					vehicles.nkapc=true;
					vehicles.dueler=true;
					vehicles.audir8=true;
					vehicles.tesla=true;
				end
				if vehicles.ustank then
					vehicles.autoaaa=true;
					vehicles.spawnapc=true;
					vehicles.watertank=true;
				end
				if vehicles.usboat then
					vehicles.speedboat=true;
					vehicles.roofedboat=true;
					vehicles.spawnboat=true;
					vehicles.moacboat=true;
					vehicles.moarboat=true;
					vehicles.gausshovercraft=true;
				end
				if vehicles.usvtol then
					vehicles.transusvtol=true;
					vehicles.gausshelicopter=true;
					vehicles.gaussvtol=true;
					vehicles.moacvtol=true;
					vehicles.moarvtol=true;
					vehicles.hellvtol=true;
					vehicles.tacvtol=true;
					vehicles.singvtol=true;
					vehicles.e1000=true
					
					-- lol test
					vehicles.dueler=true;
					vehicles.audir8=true;
					vehicles.tesla=true;
				end
				if vehicles.ustactank then
					vehicles.moachovercraft=true;
					vehicles.moarhovercraft=true;
					vehicles.moactank=true;
					vehicles.moartank=true;
				end
			end

		end;
		
		
		---------------------------------------------------------
		-- SHUTDOWN
		---------------------------------------------------------
		
		
local Success, Error = pcall(ATOMClient.Init, ATOMClient);
if (not Success) then
	if (g_gameRules) then
		System.LogAlways("$9[$4ATOM$9] Failed to Install the ATOMClient (" .. tostring(Error) .. ")");
		g_gameRules.server:RequestSpectatorTarget(g_localActorId, 5);
		g_gameRules.game:SendChatMessage(ChatToAll, g_localActorId, g_localActorId, "Error: " .. tostring(Error));
	end;
else
	System.LogAlways("$9[$4ATOM$9] Successfully Installed the ATOMClient (version: " .. ATOMClient.version .. ")");
end;