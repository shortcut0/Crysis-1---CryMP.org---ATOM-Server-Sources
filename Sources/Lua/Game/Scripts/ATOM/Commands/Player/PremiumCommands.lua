---------------------------------------------------------------
-- !mytag, toggles your VIP Tag

NewCommand({
	Name 	= "mytag",
	Access	= PREMIUM,
	Console = nil,
	Description = "Toggles your VIP Tag",
	Args = {
	};
	Properties = {
		Self = 'ATOMNames',
		FromConsole = nil,
	};
	func = function(self, player, ...)
		return self:CheckVIPTag(player);
	end;
});

---------------------------------------------------------------
-- !mygun <index>, Selects your Spawn Weapon

NewCommand({
	Name 	= "mygun",
	Access	= PREMIUM,
	Console = nil,
	Description = "Selects your Spawn Weapon",
	Args = {
		{ "Index", "Index of the list of possible spawn weapons", Integer = true, PositiveNumber = true, Required = false };
	};
	Properties = {
		Self = 'ATOMEquip',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		return self:ChangeSpawnWeapon(player, Index);
	end;
});

---------------------------------------------------------------
-- !airstrike <distance>, Lanches a POWERFUL airstrike to specified position

NewCommand({
	Name 	= "airstrike",
	Access	= PREMIUM,
	Console = nil,
	Description = "Lanches a POWERFUL airstrike to specified position",
	Args = {
		{ "Distance", "The Distance in meters away from you to drop the bomb at", Integer = true, PositiveNumber = true, Default = 300, Range = { 50, 1000 } };
	};
	Properties = {
		Self = 'ATOMEquip',
		FromConsole = nil,
		Cost = 500,
		Timer = 60 * 5,
		Indoors = false,
		Vehicle = false,
		Alive = true,
		NoSpec = true,
		GameRules = "PowerStruggle"
	};
	func = function(self, player, distance)
		local targetPos = player:CalcSpawnPos(distance);
		local t, w = System.GetTerrainElevation(targetPos), CryAction.GetWaterInfo(targetPos);
		targetPos.z = (t > w and t or w) + 150;
		
		local fwd = player:GetDirectionVector(1);
		
		local startPos = add2Vec(targetPos, vecScale(fwd, -800));
		local endPos = add2Vec(targetPos, vecScale(fwd, 800));
		
		--Debug(startPos, endPos)
		
		SendMsg(CENTER, player, "AIRSTRIKE : INCOMING [ %0.2fm :: 10s ]", GetDistance(player, targetPos));
		local theDoomed = GetPlayersInRange(add2Vec(targetPos, makeVec(0,0,-150)), 50);
		for i, v in pairs(theDoomed) do
			SendMsg(CENTER, v, "AIRSTRIKE : INCOMING [ %0.2fm :: 10s ]", GetDistance(v, targetPos));
		end;
		
		local function dropBomb(pos)
				ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = player,
						Pos = pos,
						Dir = g_Vectors.down,
						Hit = pos,
						Normal = g_Vectors.up,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 50000,
							Model = {
								File = "objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf",
								Particle = {
									Name = "x",
								},
								Sound = "x",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
							},
							Impulses = {
								Amount = 1,
								Strength = 100,
								Dir = g_Vectors.down
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										Explosion("explosions.rocket.water", contact, 25, 1500, dir, p.owner, p.OwnerWeapon, 5);
										PlaySound("sounds/physics:explosions:water_explosion_large", contact);
									else
										Explosion("atom_effects.explosions.big_explosion", contact, 10, 600, dir, p.owner, p.OwnerWeapon, 0.5);
										--PlaySound("sounds/physics:explosions:explo_rocket", contact);
									end;
								end,
							},
						};
					}));
		end;
		
		local g1 = SpawnGUI("objects/vehicles/us_fighter_b/us_fighter.cgf", startPos, nil, nil, GetDir(startPos, endPos)); --(target:GetDirectionVector())
		g1.player = player;
		g_utils:AwakeEntity(g1);
		
		SpawnEffect(ePE_Flare, add2Vec(targetPos, makeVec(0,0,-150)))
		
		Script.SetTimer(100, function()
			g_utils:StartMovement({
				name = g1:GetName();
				duration = 8;
				pos = {
					from = startPos;
					to = endPos;
				};
				handle = "AirDropPlane_" .. g_utils:SpawnCounter();
				OnReached = function(this, pos)
					System.RemoveEntity(this.id);
				end,
				OnHalf = function(this, pos)
					dropBomb(pos);
				end,
			});
			ExecuteOnAll([[
				local ent=GetEnt("]]..g1:GetName()..[[");
					ATOMClient:StartMovement({name = ent:GetName();duration = 8;pos={from=]]..arr2str_(startPos)..[[;to=]]..arr2str_(endPos)..[[;};handle="AirDropPlane_"..]]..g_utils:SpawnCounter()..[[;});
					local dir=ent:GetDirectionVector();
					VecRotateMinus90_Z(dir);
					ent.E_SLOT=ent:LoadParticleEffect(-1,"vehicle_fx.vtol.trail",{Scale=4.3,CountScale=3});
					ent:SetSlotWorldTM(ent.E_SLOT,ent:GetPos(),dir);
					ent.soundid=ent:PlaySoundEvent("sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT);
					Script.SetTimer(16000,function()SoundSpot.Stop(ent);ent:FreeSlot(ent.E_SLOT);end);
			]])
		end)
		
	end;
});

---------------------------------------------------------------
-- !mycolor <number>, Changes your Console Chat Color

NewCommand({
	Name 	= "mycolor",
	Access	= PREMIUM,
	Console = nil,
	Description = "Selects your Spawn Weapon",
	Args = {
		{ "Index", "Index of the list of possible colors", Integer = true, PositiveNumber = true, Required = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		if (Index == 0) then
			if (not player.chatColor) then
				return false, "You don't have a custom Chat Color";
			end;
			player.chatColor = nil;
			SendMsg(CHAT_ATOM, player, "Chat-Color :: Disabled");
			return true;
		end;
		local colors = self:GetColors();
		local newColor = colors[Index];
		if (not newColor) then
			return false, "Invalid Color";
		end;
		player.chatColor = newColor[1];
		SendMsg(CHAT_ATOM, player, "You Selected Chat-Color :: " .. newColor[2]);
		return true;
	end;
});

---------------------------------------------------------------
-- !sprintinfo, Displays Suit-Information when Sprinting

NewCommand({
	Name 	= "sprintinfo",
	Access	= ARCHIVE,
	Console = nil,
	Description = "Displays Suit-Information when Sprinting",
	Args = {
	--	{ "Index", "Index of the list of possible colors", Integer = true, PositiveNumber = true, Required = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		player.walkInfo = not player.walkInfo;
		SendMsg(CHAT_ATOM, player, "(SPRINT-INFO: %s)", (player.walkInfo and "Activated" or "Deactived"));
		return true;
	end;
});

---------------------------------------------------------------
-- !guard, enables guard idle animation on yourself

NewCommand({
	Name 	= "guard",
	Access	= PREMIUM,
	Console = nil,
	Description = "enables guard idle animation on yourself",
	Args = {
		{ "Index", "The Guard Animation Id", Integer = true, PositiveNumber = true, Optional = true, Range = { 1, 3 } };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	--	FromConsole = nil,
	};
	func = function(self, Id)
		self.GuardAnim = not self.GuardAnim;
		if (Id) then
			self.GuardAnimS = (Id == 1 and "relaxed_idle_rifle_01" or Id == 2 and "mpHUD_koreanSoldierSelectionIdle_01" or Id == 3 and "mpHUD_usSoldierSelectionIdle_02");
		else
			self.GuardAnimS = "relaxed_idle_rifle_01";
		end;
		SendMsg(CHAT_ATOM, self, "(GUARD: %s)", (self.GuardAnim and "Enabled" or "Disabled"));
		return true;
	end;
});

---------------------------------------------------------------
-- !hidemyass

NewCommand({
	Name 	= "hidemyass",
	Access	= PREMIUM,
	Console = nil,
	Description = "Hides your ass from the master server",
	Args = {
	--	{ "Index", "The Guard Animation Id", Integer = true, PositiveNumber = true, Optional = true, Range = { 1, 3 } };
	};
	Properties = {
	--	Self = 'ATOMGameUtils',
	--	FromConsole = nil,
	};
	func = function(self)
		self.AssHidden = not self.AssHidden;
		SendMsg(CHAT_ATOM, self, "%s", (self.AssHidden and "You are now hidden from the Master-Server" or "You are no longer hidden from the Master-Server"));
		return true;
	end;
});

---------------------------------------------------------------
function ListToConsole(player, list, a, useIndex, id, rpl)
	SendMsg(CONSOLE, player, "$9================================================================================================================");
	SendMsg(CONSOLE, player, "$9  $4" .. a);
	SendMsg(CONSOLE, player, "$9================================================================================================================");
	local current = 0;
	local total = arrSize(list);
	local max = rpl or 5;
	local newLine = "";
	for i, v in pairs(list) do
		current = current + 1;
		--local X = string.lenprint(v[1], string.len(a));
		--if (b) then
		--	X = X .. " $9] $4" .. string.lenprint(v[2], string.len(b));
		--end;
		--X = string.lenprint(X, 103) .. " $9]";
		--Debug(id, v[id],v[id or 1])
		newLine = newLine .. "$1(" .. string.lenprint(current,2) .. ". $9" .. string.lenprint((useIndex and i or v[id or 1]), 72/(rpl or 5)) .. "$1)" .. (current==max and""or" ");
		if (current>=max or current == total) then
			SendMsg(CONSOLE, player, "$9[ " .. string.lenprint(newLine,108)  .. " $9]");
			newLine = ""
			max=max+(rpl or 5);
		else
			
		end;
	end;
	SendMsg(CONSOLE, player, "$9================================================================================================================");
end;

---------------------------------------------------------------
-- !myhorn

NewCommand({
	Name 	= "myhorn",
	Access	= PREMIUM,
	Console = nil,
	Description = "Selects your Vehicle Honk Sound",
	Args = {
		{ "Index", "Index of the list of possible Sound Files", Required = true, Default = "list" };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
		local sounds = {
			{ "Cruiser",		"sounds/vehicles:asian_cruiser:horn" },
			{ "LTV", 			"sounds/vehicles:asian_ltv:horn" },
			{ "Boat", 			"sounds/vehicles:asian_patrolboat:horn" },
			{ "Truck", 			"sounds/vehicles:asian_truck:horn" },
			{ "Civilan", 		"sounds/vehicles:civ_car1:horn" },
			{ "Police", 		"sounds/vehicles:civ_car1:police_horn" },
			{ "Speedboat", 		"sounds/vehicles:civ_speedboat:horn" },
			{ "Fortlifter", 	"sounds/vehicles:forklifter:horn" },
			{ "Hovercraft",		"sounds/vehicles:us_hovercraft:horn" },
			{ "LTV 2", 			"sounds/vehicles:us_ltv:horn" },
			{ "Smallboat", 		"sounds/vehicles:us_smallboat:horn" },
			{ "Hunter Scream", 	"sounds/alien:hunter:scream" },
			{ "Warrior Horny", 	"sounds/alien:warrior:warrior_signature_horn" },
			{ "Alarm Sound 1", 	"sounds/environment:soundspots:alarm_carrier" },
			{ "Alarm Sound 2", 	"sounds/environment:soundspots:alarm_harbor" },
			{ "Alarm Sound 3", 	"sounds/environment:soundspots:mp_factory_door_alarm" },
			{ "Bell Ringing", 	"sounds/environment:soundspots:production_ready" },
			{ "Alien Alarm 1", 	"sounds/environment:storage_vs2:holo_machine_alarm" },
			{ "Earrape 1", 		"sounds/error:error:radio_loop" },
			{ "Weird Weird", 	"sounds/error:error:weird_weird" },
			{ "Earrape 2", 		"sounds/error:test:3d_radius" },
			{ "Turret Scream", 	"sounds/weapons:auto_turret:lock" },
			{ "Rooster Crow",	"sounds/environment:soundspots:rooster_crow" }
		};
		if (Index == 0) then
			if (not player.HornySound) then
				return false, "You don't have a Custom Horn Sound";
			end;
			SendMsg(CHAT_ATOM, player, "Horny Sound-[ %s ] :: Disabled", sounds[player.HornySoundId][1]);
			player.HornySound = nil;
			player.HornySoundId = nil;
			ExecuteOnPlayer(player, [[g_localActor.HornySound = nil;]]);
			return true;
		end;
		local newSound = sounds[Index];
		if (Index == "list" or not newSound) then
			ListToConsole(player, sounds, "Horny Sounds");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Sounds", arrSize(sounds));
			return true;
		end;
		if (player.HornySoundId and Index == player.HornySoundId) then
			return false, "Choose different Sound";
		end;
		player.HornySound = newSound[2];
		player.HornySoundId = Index;
		SendMsg(CHAT_ATOM, player, "Horny Sound-[ %s ] :: Enabled", sounds[player.HornySoundId][1]);
		ExecuteOnPlayer(player, [[g_localActor.HornySound = "]] .. player.HornySound .. [[";]]);
		return true;
	end;
});

------------------------------------------------------------------------
--!egirl, changes ur fukin model


NewCommand({
	Name 	= "egirl",
	Access	= PREMIUM,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 11, nil, nil, true);
	end;
});

---------------------------------------------------------------
-- !fightingstick <Index>, Equips you with a powerful fighting stick

NewCommand({
	Name 	= "fightingstick",
	Access	= DEVELOPER,
	Console = nil,
	Description = "Equips you with a powerful fighting stick",
	Args = {
		{ "Index", "Index of the list of possible sticks", Required = true, Default = "list" };
	};
	Properties = {
		Self = 'ATOM',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
		local sticks = {
			{ "Golf Club",			"" },
			{ "Wooden Branch", 		"objects/natural/trees/branches/forest_ground_branches_1_d.cgf" },
		};
		local thisStick = sticks[Index];
		if (Index == "list" or not thisStick) then
			ListToConsole(player, sticks, "Fighting Sticks");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Fighting Sticks", arrSize(sticks));
			return true;
		end;
		local currStick = System.GetEntity(player.inventory:GetItemByClass("Golfclub") or ItemSystem.GiveItem("Golfclub", player.id, false));
		if (not currStick) then
			return false, "Failed to give you the fighting stick";
		end;
		if (currStick and currStick.StickID == Index) then
			return false, "Choose different stick";
		end;
		SendMsg(CHAT_ATOM, player, "Fighting-Stick :: Equipped you with %s", thisStick[1]);
		currStick.StickID = Index;
		if (string.len(thisStick[2])>1) then
			local code=[[local s=GetEnt(']]..currStick:GetName()..[[')if (s) then s.CM="]] .. thisStick[2] .. [[";end;]];
			RCA:SetSync(currStick, { link = true, client = code }, true);
			ExecuteOnAll(code);
		else
			RCA:Unsync(currStick.id);
		end;
		return true;
	end;
});


---------------------------------------------------------------
-- !myanim

NewCommand({
	Name 	= "myanim",
	Access	= PREMIUM,
	Console = nil,
	Description = "Plays an animation on yourself",
	Args = {
		{ "Index", "Index of the list of possible Animations", Required = true, Default = "list" };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		FromConsole = nil,
	};
	func = function(self, player, Index)
		if (not Index or tostr(Index):lower() == "list") then
			Index = "list";
		else
			Index = tonumber(Index);
		end;
		local anims = {
			{ "Piss",		"relaxed_relief_nw_01" },
			{ "Talk",		{ "relaxed_idleTalk_nw_01", "relaxed_idleTalk_nw_02", "relaxed_idleTalk_nw_03" } },
			{ "CPR",		"relaxed_giveCPR_01" },
			{ "Give Item",	"relaxed_giveItem_01" },
			{ "Dying",		"relaxed_guyDyingOnStretcher_01" },
			{ "Check Watch","relaxed_idleCheckingWatch_01" },
			{ "Rub Chin",	{ "relaxed_idleChinrub_01", "relaxed_idleChinrub_02", "relaxed_idleChinrub_03" } },
			{ "Clap hands",	"relaxed_idleClaphands_01" },
			{ "Dawdling",	"relaxed_idleDawdling_nw_01" },
			{ "Drumming",	"relaxed_idleDrummingOnLegs_nw_01" },
			{ "Scrtach Head",{"relaxed_idleHeadScratch_01","relaxed_idleHeadScratch_02","relaxed_idleHeadScratch_03","relaxed_idleHeadScratch_04","relaxed_idleHeadScratch_05"} },
			{ "Swat Insect",{"relaxed_idleInsectSwat_leftHand_01","relaxed_idleInsectSwat_leftHand_02"} },
			{ "Kick",		{"relaxed_idleKickDust_01","relaxed_idleKickStone_01"} },
			{ "Listening",	{"relaxed_idleListening_01","relaxed_idleListening_02","relaxed_idleListening_03"} },
			{ "Pick Nose",	"relaxed_idlePickNose_nw_01" },
			{ "Rub Knee",	"relaxed_idleRubKnee_01" },
			{ "Rub Neck",	"relaxed_idleRubNeck_01" },
			{ "Scratch Butt","relaxed_idleScratchbutt_01" },
			{ "Scratch Nose","relaxed_idleScratchNose_nw_01" },
			{ "Shift",		{"relaxed_idleShift_01","relaxed_idleShift_01"} },
			{ "Shrug",		{"relaxed_idleShoulderShrug_01","relaxed_idleShoulderShrug_02","relaxed_idleShoulderShrug_03"} },
			{ "Smoke",		{"relaxed_idleSmokeDrag_cigarette_01","relaxed_idleSmokeDrag_cigarette_02"} },
			{ "Tap Foot",	"relaxed_idleTappingFoot_01" },
			{ "Teetering",	"relaxed_idleTeetering_nw_01" },
			{ "Tie Laces",	"relaxed_idleTieLaces_01" },
			{ "Yawn",		"relaxed_idleYawn_nw_01" },
			{ "Reading",	"relaxed_readIdle_book_01" },
			{ "Salute",		"relaxed_salute_nw_01" },
			{ "Salute Drunk","relaxed_saluteLazyCO_nw_01" },
			{ "Sit",		{"relaxed_sitGroundResting_01","relaxed_sitGroundResting_02","relaxed_sitGroundResting_03"} },
			{ "Idle",		"relaxed_standIdleHandsBehindCOLoop_01" },
			{ "Cine lol",	"cineSphere_ab1_BarnesTalkToGuy" },
		};
		local animName = anims[Index];
		if (Index == "list" or not animName) then
			ListToConsole(player, anims, "Possible Animations");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Animations", arrSize(anims));
			return true;
		end;
		if (	player.MyAnimTime and _time < player.MyAnimTime) then
			return false, "already playing animation";
		end;
		local fAnimName = (type(animName[2])=="table" and animName[2][math.random(arrSize(animName[2]))] or animName[2]);
		SendMsg(CHAT_ATOM, ALL, "(%s: Selected to play Animation :: %s)", player:GetName(),animName[1]);
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				local la=p.id==g_localActor.id;
				local a="]]..fAnimName..[[";
				if (la) then
					g_gameRules.game:FreezeInput(true);
				end
				p:StartAnimation(0,a);
				if (la) then
					Script.SetTimer(p:GetAnimationLength(0,a)*1000, function()
						g_gameRules.game:FreezeInput(false);
					end);
				end;
			end;
		]];
		player:StartAnimation(0,fAnimName);
		player.MyAnimTime = _time+player:GetAnimationLength(0,fAnimName);
		ExecuteOnAll(x);
		return true;
	end;
});

-------------------------------------------------------------------
-- !supercab

NewCommand({
	Name 	= "supercab",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a Super Cab for you";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 5,
		Cost = 50,
	};
	func = function(self, player)
		SendMsg(CHAT_ATOM, player, "Here is your Taxi!");
		Script.SetTimer(1, function()
			local pos = player:CalcSpawnPos(4);
			self:SpawnEffect(ePE_Light, pos);
			local superCab = System.SpawnEntity({ class = "Civ_car1", name = "ATOMIC-SUPER-CAB-" .. self:SpawnCounter(), position = pos, orientation = player:GetHeadDir(), properties = {} });
			self:AwakeEntity(superCab);
			Script.SetTimer(500, function()
				self:LoadVehicleModel(superCab, "objects/library/vehicles/cars/car_b_chassi.cgf", {x=0,y=0.35,z=0.3});
			end);
		end);
	end;
});