RCA = {
	cfg = {
		MaximumCode = 850;
		KillLimit = 3850;
	};
	-----------
	Client_URL_AI = "http://nomad.nullptr.one/~finch/ATOMClient_AI.lua",
	Client_URL = "http://nomad.nullptr.one/~finch/ATOMClient.lua", --https://github.com/williambrowningg/ATOM-Client/raw/main/ATOM-Client.lua", --"http://nomad.nullptr.one/~finch/ATOMClient.lua",
	Client_Version = "0.0a",
	Client_Mod = true,
	----------
	callsThisFrame = 0,
	iFrameCalls = 0,
	iTotalCalls = 0,
	----------
	storedCode = RCA ~= nil and RCA.storedCode or { [NULL_ENTITY] = {} },
	----------
	EXECUTED_CODE = checkGlobal("RCA.EXECUTED_CODE", {}),
	EXECUTED_CODE_MAP = checkGlobal("RCA.EXECUTED_CODE_MAP", {}),
	EXECUTED_CODE_COUNT = checkGlobal("RCA.EXECUTED_CODE_COUNT", 0),
	----------
	thisFrame = System.GetFrameTime(),
	iCurrentFrame = System.GetFrameTime(),
	----------
	quenedCalls = {},
    ForcedClientModel = nil,
	----------
	Init = function(self)

        local iForcedModel = Config.ATOM.Immersion.ForcedClientModelID
        if (iForcedModel and iForcedModel ~= -1) then
            self:SetForcedModel(iForcedModel)
        end
         

		RCA_ENABLED = true
	
		CLIENT_MOD = self.Client_Mod;
		CLIENT_URL = self.Client_URL;
		CLIENT_URL_AI = self.Client_URL_AI;
		CLIENT_VER = self.Client_Version;
		
		ExecuteOnPlayer = self.ExecuteOnPlayer;
		ExecuteOnOthers = self.ExecuteOnOthers;
		ExecuteOnAll	= self.ExecuteOnAll;
		
		-- Player
		eCR_Bot			= 111;
		
		-- Client
		eCR_Installed 	= 4;
		eCR_InstallFail	= 5;
		
		-- Anim Door
		eCR_OpenAnimDoor	= 10;
		eCR_CloseAnimDoor	= 11;
		
		-- ATOM Pack
		eCR_JetPack_ON		= 12;
		eCR_JetPack_OFF		= 13;
		eCR_JetPack_EMPTY	= 14;
		eCR_JetPack_FULL	= 15;
		eCR_JetPack_SUPER	= 16;
		
		eCR_RocketON		= 17;
		eCR_RocketOFF		= 18;
		
		-- AntiCheat
		eCR_CheatNoRecoil	= 20;
		eCR_Gravity			= 21;
		eCR_Flags			= 22;
		eCR_Mass			= 23;
		eCR_Speed			= 24;
		eCR_Teleport		= 25;
		eCR_Door			= 26;
		eCR_Vegetation		= 140;
		eCR_VehicleTp		= 141;
		
		-- Client Version
		eCR_ClientSFWCL		= 100;
		eCR_ClientCryMP		= 101;
		eCR_ClientUnknown	= 102;
		
		-- Other
		eCR_MousePress		= 30;
		eCR_MouseRelease	= 31;
		eCR_MeleePress		= 32;
		eCR_MeleeRelease	= 33;
		eCR_MousePressL		= 34;
		eCR_MouseReleaseL	= 35;
		
		-- Vehicle
		eCR_HornyON			= 40;
		eCR_HornyOFF		= 41;
		eCR_VBoostON		= 42;
		eCR_VBoostOFF		= 43;
		eCR_VForwardOn		= 44;
		eCR_VForwardOff		= 45;
		eCR_VBrakeON		= 46;
		eCR_VBrakeOFF		= 47;
		
		eCR_UseObject1		= 70; -- Airdrop
		eCR_Interactive		= 71; -- Airdrop
		
		eCR_ChairOFF		= 72; -- Airdrop
		eCR_ChairON			= 73; -- Airdrop
		eCR_UseObject2		= 74;
		eCR_UseObject3		= 75; -- Elevators
		eCR_DropSpecial		= 76; -- drop special dong
		
		eCR_Pong			= 110;
		
		eCR_F3				= 124;
		eCR_JoinMeeting		= 50;
		
		--eCR
		
		-- register gloabls
		
		JETS = JETS or {};
		
		-- hook entities
		self:HookEntities();
	end;
	----------
	HookEntities = function(self)
		
		--**********************************************************
		-- AnimDoor
		--**********************************************************
		self:CheckEntity("AnimDoor", "Scripts/Entities/Doors/AnimDoor.lua");
		------------------
		AnimDoor.Properties.Sounds = {
			snd_Open 	= "sounds/environment:storage_vs2:door_trooper_open", 
			snd_Close 	= "sounds/environment:storage_vs2:door_trooper_close"
		};
		------------------
		AnimDoor.Properties.bActivatePortal = 1;
		------------------
		AnimDoor.Properties.Animation 		= { 
			anim_Open 	= "passage_door_open",
			anim_Close 	= "passage_door_closed"
		};
		------------------
		AnimDoor.Reset = function(self)
		
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
			
			--Msg(0, "Anim door got: %s, %s, %s, %s, (%s)", tostring(object), tostring(anim1), tostring(anim2), tostring(s1), tostring(s2), tostring(trash));
		
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
		end
		------------------
		AnimDoor.Event_Open = function(self)--, doAction)
			--if (doAction == nil) then
			--	if (ATOMClient ~= nil) then
			--		ATOMClient:ToServer(eTS_Spectator, 10);
			--	end;
			--else
				self:DoPlayAnimation(1,nil,true);
			--end;
		end;
		------------------
		AnimDoor.Event_Close = function(self)--, doAction)
			--if (doAction == nil) then
			--	if (ATOMClient ~= nil) then
			--		ATOMClient:ToServer(eTS_Spectator, 11);
			--	end;
			--else
				self:DoPlayAnimation(-1,nil,true);
			--end;
		end;
		------------------
		for i, animDoor in ipairs(System.GetEntitiesByClass("AnimDoor")or{})do
			AnimDoor.Reset(animDoor);
			animDoor.Event_Open = AnimDoor.Event_Open;
			animDoor.Event_Close = AnimDoor.Event_Close;
		end;
		------------------

		
	end;
	----------
	CheckEntity = function(self, globalName, scriptPath)
		if (not _G[string.lower(tostring(globalName))]) then
			Script.ReloadScript(scriptPath);
		end;
		return true;
	end;
	----------
	OnReport = function(self, player, report)


		SysLog("report=%s",report)
		local rest, temp, temp2;
		local yes = false;
		if (report:sub(1, 2) == "++") then
			rest = report:sub(3);
			if (rest:sub(1, 3) == "WRT") then
				temp = rest:sub(5);
				if (tonumber(temp)) then
					ATOMDefense:OnReportReceived(player, eCR_FireRate, tonumber(temp));
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "NWR") then
				temp = rest:sub(5);
				if (tonumber(temp)) then
					ATOMDefense:OnReportReceived(player, eCR_NoRecoil, tonumber(temp));
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "LWR") then
				temp = rest:sub(5);
				if (tonumber(temp)) then
					ATOMDefense:OnReportReceived(player, eCR_LowRecoil, tonumber(temp));
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "NWS") then
				temp = rest:sub(5);
				if (tonumber(temp)) then
					ATOMDefense:OnReportReceived(player, eCR_NoSpread, tonumber(temp));
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "LWS") then
				temp = rest:sub(5);
				if (tonumber(temp)) then
					ATOMDefense:OnReportReceived(player, eCR_LowSpread, tonumber(temp));
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "MJS") then
				--Debug("!!")
				temp = rest:sub(5);
				if (tonumber(temp)) then
					temp2 = player:GetVehicle() or GetEnt(player.ExitVehicleId)
					if (temp2) then
						temp2.ThrusterPower = minimum(1, round(tonumber(temp)))
					--	Debug("CLIENT POWER :: ",temp2.ThrusterPower)
					end
					yes = true
				end;
			elseif (rest:sub(1, 6) == "TALKTO") then
				--Debug("!!",rest:sub(8))
				temp = rest:sub(8);
				if (tonumber(temp)) then
					temp2 = g_game:GetPlayerByChannelId(tonumber(temp));
					if (temp2) then
						self:PlayerTalk(player, temp2);
					end;
					yes = true;
				end;
			elseif (rest:sub(1, 4) == "GRAB") then
				--Debug("!!",rest:sub(8))

				if (GetBetaFeatureStatus("grab")) then
					temp = rest:sub(6);
					if (temp) then
						yes = true

						if (tonumber(temp)) then
							temp2 = g_game:GetPlayerByChannelId(tonumber(temp));
							if (temp2) then
								player:GrabPlayer(temp2,nil,(player.actor:GetNanoSuitMode()==NANOMODE_STRENGTH and 2125 or 650));
							end
						else
							temp2 = System.GetEntityByName(temp)
							if (temp2 and temp2.actor and not temp2.actor:IsPlayer()) then
								player:GrabPlayer(temp2,nil,(player.actor:GetNanoSuitMode()==NANOMODE_STRENGTH and 2125 or 650));
							else
								yes = false
							end
						end
					end
				else
					SendMsg(ERROR, player, "Grabbing Feature is Disabled")
				end
			elseif (rest:sub(1, 6) == "COORDS") then
				temp = rest:sub(8);
				--Debug("!!",rest:sub(8))
				--Debug("coords = ",temp)
				if (temp:match("^[ABCDEFG][0-9]$")) then
					if (not player:IsSpectating() and (player.CurrentMapCoords ~= temp:upper()) and timerexpired(player.hTimerSectorChanged, 10)) then
						player.hTimerSectorChanged = timerinit()
						SendMsg(BLE_INFO, player, "You Entered Sector %s", temp)
					end
					player.CurrentMapCoords = temp:upper()
					yes = true
				else
					Debug("Invalid coords??")
				end
				--if (tonumber(temp)) then
				--	temp2 = g_game:GetPlayerByChannelId(tonumber(temp));
				--	if (temp2) then
				--		self:PlayerTalk(player, temp2);
				--	end;
				--	yes = true;
				--end;
			elseif (rest:sub(1, 3) == "MBW") then
				rest = rest:sub(5);
				temp = {};
				temp[1], temp[2] = rest:match("(.*)|(.*)");
				if (temp[1] and temp[2] and tonumber(temp[1]) and tonumber(temp[2])) then
					ATOMStats.PermaScore:OnWallJump(player, temp[1], temp[2]);
					if (not player.BestWallJump) then
						SendMsg(CENTER, ALL, "(%s: FIRST WALLJUMP: %dm, DURATION: %ds)", player:GetName(), temp[1], temp[2]);
						player.BestWallJump = {
							Height = temp[1];
							Duration = temp[2];
						};
					else
					--	Debug(temp[2])
					--	Debug(temp[1])
					--	Debug(player.BestWallJump.Height)
						if (tonum(temp[1]) > tonum(player.BestWallJump.Height)) then
							SendMsg(CENTER, ALL, "(%s: NEW BEST WALLJUMP: %dm, DURATION: %ds)", player:GetName(), temp[1], temp[2]);
							player.BestWallJump = {
								Height = temp[1];
								Duration = temp[2];
							};
						else
							SendMsg(CENTER, player, "([ WALLJUMP ]-[ %dm ] :: [ DURATION ]-[ %ds ])", temp[1], temp[2]);
						end;
					end;
					player.LastWallJump = _time;
					yes = true;
				end;
			elseif (rest:sub(1, 3) == "MHD") then
				rest = rest:sub(5);
				temp = {x = 0, y = 0, y = 0};
				temp.x, temp.y, temp.y = rest:match("(.*)|(.*)|(.*)");
				player.ViewCameraDir = temp;
				yes = true;

			elseif (rest:sub(1, 3) == "CLV") then
				rest = rest:sub(5)
				player.sClientVersion = rest
				ATOMLog:LogRCA("Player %s is using CryMP-Client (v%s)", player:GetName(), player.sClientVersion)
				yes = true;

			end;
		end;
		--Debug("Request!")
		return yes;
	end;
	----------
	CheckRequest = function(self, player, req)
	--	Debug("Ok")
		return self:OnReport(player, req);
	end,
	----------
	OnResponse = function(self, player, id)

		local id = tonumber(id)
		if (id < 0) then
			id = id + (128 * 2)
		end
	
		if (not player.actor) then
			return end

		if (id == 142 or id == 143) then
			self:LogPakStatus(player,id == 142)
			return true
		end

		local hWeapon = player:GetCurrentItem()
		local entity;
		local temp, temp2;
		local vehicleId = player.actor:GetLinkedVehicleId();
		local vehicle, v;
		if (vehicleId) then
			vehicle = System.GetEntity(vehicleId);
			v = vehicle;
		end;
		--Debug("???",id)
		--------------------------------------
		-- Other stuff
		--Debug(id)
		-- Debug("id",id)
		if (id == eCR_MousePress) then
		
			
		
			if (v and v.OnMousePress and v:GetDriver() == player) then
				v.OnMousePress(v, v:GetDriver(), false);
			end;
		
			temp = player.inventory:GetCurrentItem();
			if (temp and vehicle and ATOMVehicles.cfg.AllowShooting) then
				if (ATOMVehicles.cfg.WeaponClasses == ALL or ATOMVehicles.cfg.WeaponClasses[temp.class]) then
					if (temp and temp.class ~= "Fists") then
						SHOOTING_WEAPONS = SHOOTING_WEAPONS or {};
						if (not SHOOTING_WEAPONS[temp.id]) then
							ExecuteOnAll([[
								local g=GetEnt(']]..temp:GetName()..[[');
								if (g and not g.FIRESOUND) then
									g.FIRESOUND=g:PlaySoundEvent("sounds/weapons:"..g.class:lower()..":fire_3rd_loop", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
								end;
							]]);
						end;
						SHOOTING_WEAPONS[temp.id] = {
							needVehicle = vehicle.id;
							player = player;
							shots = (player:InGodMode() and -1 or temp.weapon:GetClipSize());
							lastFireTime = _time - (60/(temp.weapon.GetFireRate and temp.weapon:GetFireRate() or 80));
							useRayHit = true,
						};
						
						--temp.weapon:ServerShoot(temp.weapon:GetAmmoType() or "bullet", player.actor:GetHeadPos(), player:GetBoneDir("Bip01 Head"), player:GetBoneDir("Bip01 Head"), player:GetPosInFront(3), 0, 0, 0, 0, false);
					end;
				end;
			elseif (temp and temp.class ~= "Fists") then
				if (temp.class == "Claymore" and ATOM.cfg.Immersion.AllowPlaceClaymoreEverywhere) then
					--Debug("ok ?")
					if (player.actorStats.stance ~= STANCE_CROUCH) then
						local wall = player:GetHitPos(5);
						--Debug(wall)
						if (wall) then
							Script.SetTimer(1, function()
								local clay = System.SpawnEntity({ class = "claymoreexplosive", position = wall.pos, orientation = g_Vectors.down })
								local dir = GetDir(wall.pos, player:GetHeadPos(), 1);
								
								clay:SetDirectionVector(dir);
								--temp.weapon:ServerShoot(temp.weapon:GetAmmoType() or "claymoreexplosive", wall.pos, wall.normal, wall.normal, CalcPos(wall.pos, wall.normal, 2024), 0, 0, 0, 0, false);
								temp.weapon:Plant(wall.pos, wall.normal, makeVec(), 0, true);
								CryAction.CreateGameObjectForEntity(clay.id);
								CryAction.BindGameObjectToNetwork(clay.id);
								CryAction.ForceGameObjectUpdate(clay.id, true);
								g_game:SetTeam(player:GetTeam(), clay.id);
								--Debug("id",id)
							end);
							--Debug("wall, place the fucker NOW!");
						end;
					end;
				else
					if (temp.class == "Golfclub" and player:HasStance(STANCE_STAND, STANCE_CROUCH)) then
						-- x:StartAnimation(0,"combat_weaponPunchUB_pistol_01")
						ExecuteOnAll([[
							local x=GP(]]..player:GetChannel()..[[);
							x.actor:PlayAction("]]..(temp.class=="GolfClub" and "melee_upper_cut_right" or "melee")..[[","Action")
							
						]]); --HE(eCE_ATOMTaunt, x:GetName(), "ai_marine]] ..GetRandom({"","_1","_2"}) ..[[/fallingdeath_]] ..GetRandom({"00","01","02","03"}) ..[[")--.;]]);
						local HitData = player:GetHitPos(2);
						local finalDamage = 50 * (player:GetSuitMode(NANOMODE_STRENGTH) and (2*(player:GetSuitEnergy(40) and 1.5 or 1)) or 1);
						--Debug(finalDamage)
						if (HitData and HitData.entity) then
							player:HitEntity(HitData.entity, finalDamage);
							HitData.entity:AddImpulse(-1, HitData.pos, player:GetHeadDir(), 300, 1);
						end;
					end;
				end;
			end;
			--Debug(temp.class)
			player.MouseHeld = true;
			
			if (v and v.WaterTank and v:GetDriverId() == player.id and not v._waterEffect) then
				v._waterEffect = true;
				local code = [[
					local v=GetEnt(']]..vehicle:GetName()..[[');
					if (v) then
						v._WS = v:LoadParticleEffect(-1,"]]..(vehicle.waterID == 1 and 'water.water_tank.leaking' or 'water.oil_tank.oil') ..[[",{SpeedScale=3,PulsePeriod=2.5,Scale=8,CountScale=5});
						WATER_TANKS[v.id] = v;
					end;
				]];
				
				ExecuteOnAll(code);
				vehicle.waterSyncID = self:SetSync(vehicle, { linked = vehicle.id, client = code });
			end;
			return true;
		end;
			
		if (id == eCR_MouseRelease) then
		
			if (v and v.OnMousePress and v:GetDriver() == player) then
				v.OnMousePress(v, v:GetDriver(), true);
			end;
			if (vehicle) then
				temp = player.inventory:GetCurrentItem();
				if (temp) then
					SHOOTING_WEAPONS = SHOOTING_WEAPONS or {};
					if (SHOOTING_WEAPONS[temp.id]) then
						ExecuteOnAll([[
							local g=GetEnt(']]..temp:GetName()..[[');
							if (g and g.FIRESOUND) then
								g:StopSound(g.FIRESOUND);
								g.FIRESOUND=nil;
							end;
						]]);
					end;
					SHOOTING_WEAPONS[temp.id] = nil;
				end;
			end;
			player.MouseHeld = false;
			
			if (v and v.WaterTank and v._waterEffect and player.id == v:GetDriverId()) then
				if (v.waterSyncID) then
					self:StopSync(v, v.waterSyncID);
					v.waterSyncID = nil;
				end;
				if (v._waterEffect) then
					v._waterEffect = nil;
					local code = [[
						local v=GetEnt(']]..v:GetName()..[[');
						if (v) then
							if (v._WS) then
								v:FreeSlot(v._WS);
							end;
							WATER_TANKS[v.id] = nil
						end;
					]];
					ExecuteOnAll(code);
				end;
			end;
			
			return true;
		end;
		
		if (id == eCR_MousePressL) then
		
			-- Debug("press??")
			local aBoats = {
				["US_smallboat"] = true,
				["Asian_patrolboat"] = true,
				["Asian_patrolboat"] = true,
			}
		
			if (v == nil and hWeapon and hWeapon.class == "Fists") then
				temp = player:GetHitPos(4)
				-- Debug("v nil ok lol pressed")
				if (temp and temp.entity) then
					-- Debug("entity found")
					temp2 = temp.entity
					if (aBoats[temp2.class]) then
						-- Debug("BOAT")
						if (player.PUSHING_VEHICLE ~= nil) then
							--Debug("OFF!")
							player.PUSHING_VEHICLE = nil 
						else
							player.PUSHING_VEHICLE = temp2
						end
						-- if (temp2:GetDriver()) then
						
						-- else
							-- temp2:AddImpulse(-1, temp.pos, temp.dir, temp2:GetMass(), 
						-- end
					end
				end
			end
		
		
		--	Debug("ON")
			player.LMouseHeld = true;
			return true;
		end;
		
		if (id == eCR_MouseReleaseL) then
		
			--Debug("RELESE NOW !!")
			player.PUSHING_VEHICLE = nil
		
		--	Debug("OFF")
			player.LMouseHeld = false;
			return true;
		end;
		
		if (id == eCR_MeleePress) then
			temp = player.inventory:GetCurrentItem();
			if (temp) then
				if (temp.class == "RadarKit" or temp.class == "LockpickKit" or temp.class == "RepairKit" or temp.class == "ShiTen") then
					--GetEnt(']]..player:GetName()..[['):StartAnimation(0,"combat_weaponPunchUB_pistol_01")
					ExecuteOnAll([[
					
						local x=GP(]]..player:GetChannel()..[[);
						x:StartAnimation(0,"combat_weaponPunchUB_pistol_01")
					
					
					]]);--.actor:PlayAction("]]..(temp.class=="GolfClub" and "melee_upper_cut_right" or "melee")..[[","Action");]]);
					local HitData = player:GetHitPos(2);
					local finalDamage = 50 * (player:GetSuitMode(NANOMODE_STRENGTH) and (2*(player:GetSuitEnergy(40) and 1.5 or 1)) or 1);
					--Debug(finalDamage)
					if (HitData and HitData.entity) then
						player:HitEntity(HitData.entity, finalDamage);
						HitData.entity:AddImpulse(-1, HitData.pos, player:GetHeadDir(), 300, 1);
					end;
				end;
			end;
			player.Melee = true;
			return true;
		end;
		
		if (id == eCR_MeleeRelease) then
			temp = player.inventory:GetCurrentItem();
			if (temp) then
				if (temp.class == "RadarKit" or temp.class == "LockpickKit" or temp.class == "RepairKit") then
					if (not temp.LastMelee or _time - temp.LastMelee > 1) then
						--Debug("melee with kit");
					end;
				end;
			end;
			player.MeleeHold = false;
			return true;
		end;
		
		
		local theSound = vehicle and ATOMVehicles.cfg.VehicleHorns[vehicle.class] or nil;
		--Debug("honk sound :: ",theSound)
		if (id == eCR_HornyON) then
	--	Debug("ON called???")
			if (player.HornySound) then
				if (vehicle and not vehicle.HornySound) then
					ExecuteOnOthers(player, [[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and not v.HornySound) then
							v.HornySound = true;
							v.SoundID=v:PlaySoundEvent("]]..player.HornySound..[[", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
							LOOPED_SOUNDS[v.id]={
								Entity = v,
								Sound = "]]..player.HornySound..[[",
								SoundID = v.SoundID;
							};
						end;
					]]);
					vehicle.HornySound = true;
				end;
			elseif (vehicle and theSound and vehicle:GetDriverId() == player.id) then
				if (not vehicle.TheHornySound) then
					ExecuteOnAll([[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and not v.TheHornySound) then
							v.TheHornySound = true;
							v.SoundID=v:PlaySoundEvent("]]..theSound..[[", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
							LOOPED_SOUNDS[v.id]={
								Entity = v,
								Sound = "]]..theSound..[[",
								SoundID = v.SoundID;
							};
						end;
					]]);
					vehicle.TheHornySound = true;
					--Debug("Sound ON !!")
				end;
			end;
			return true;
		end;
		
		if (id == eCR_HornyOFF) then
		--Debug("off called???")
			if (player.HornySound) then
				if (vehicle and vehicle.HornySound) then
					ExecuteOnOthers(player, [[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and v.SoundID) then
							v.HornySound = false;
							v:StopSound(v.SoundID);
							v.SoundID=nil;
						end;
						LOOPED_SOUNDS[v.id]=nil;
					]]);
					vehicle.HornySound = false;
				end;
			elseif (vehicle and theSound and vehicle:GetDriverId() == player.id) then
				if (vehicle.TheHornySound) then
					ExecuteOnAll([[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and v.SoundID) then
							v.TheHornySound = false;
							v:StopSound(v.SoundID);
							v.SoundID=nil;
						end;
						LOOPED_SOUNDS[v.id]=nil;
					]]);
				end;
				vehicle.TheHornySound = nil;
				--	Debug("Sound OFF !!")
			end;
			--Debug("OK",Vehicle and theSound)
			return true;
		end;
		
		if (id == eCR_VBoostON) then
			if (v) then
				v.Boost = true;
				if (v.Nitro and not v.NitroEffect) then
					ExecuteOnOthers(player, [[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and v.LaunchedNitros) then
							local pos,dir;
							dir = v:GetDirectionVector()
							NITRO_VEHICLES[v.id] = true;
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
						end;
					]]);
					v.NitroEffect = true;
				end;
			end;
			return true;
		end;
		
		if (id == eCR_VBoostOFF) then
			if (v) then
				v.Boost = false;
				if (v.Nitro and v.NitroEffect) then
					ExecuteOnOthers(player, [[
						local v=GetEnt(']]..vehicle:GetName()..[[');
						if (v and v.LaunchedNitros) then
							NITRO_VEHICLES[v.id] = nil;
							for i, nitro in pairs(v.LaunchedNitros) do
								if (nitro.NitroSlot) then
									nitro:FreeSlot(nitro.NitroSlot);
									nitro.NitroSlot = nil;
								end;
							end;
						end;
					]]);
					v.NitroEffect = false;
				end;
			end;
			return true;
		end;
		
		if (id == eCR_VForwardOn) then
			if (v) then
				v.MovingForward = true;
				if (v.IsJet) then
					if (v.EngineON) then
						--Debug("Jet FORWARDING NOW!!");
					else
						--Debug("Jet FORWARDING BUT ENGINE OFF!!");
					end;
				end;
			end;
			return true;
		end;
		
		if (id == eCR_VForwardOff) then
			if (v) then
				v.MovingForward = false;
				if (v.IsJet) then
					if (v.EngineON) then
						--Debug("Jet FORWARDING OFF!!");
					end;
				end;
			end;
			return true;
		end;
		
		if (id == eCR_VBrakeON) then
			if (v) then
				v.Braking = true;
				v.EngineON = not v.EngineON;
				if (v.IsJet) then
					--Debug("Jet ENGINE !!",v.EngineON);
					if (v.EngineON) then
						temp = formatString([[
							local v=GetEnt("%s");
							local p=GP(%d);
							if (v and p) then
								if (p.id==g_localActorId) then
									HUD.DisplayBigOverlayFlashMessage("Jet Engine ENABLED | Hold/Release [ W ] To Accelerate/Decelerate!", 10, 230, 360, { 0/255, 0/255, 255/255 });
								end;
								v.ThrusterON = true;
								v:Event_EnableMovement();
								if (v.JetType) then
									ATOMClient:JetEffects(v, v.JetType, true, 0);
									ATOMClient:JetSound(v, v.JetType, true);
								end;
								v._clThrusterSpeed=]]..(v.ThrusterPower or 0) ..[[
							end;
						]], v:GetName(), player:GetChannel());
						ExecuteOnAll(temp);
						JETS[v.id] = v;
						if (v.rotorEntities) then
							--Debug("has rotor lol")
							local code = [[
								local v,a,b = GetEnt("]]..v:GetName()..[["), GetEnt("]]..v.rotorEntities[1]:GetName()..[["), GetEnt("]]..v.rotorEntities[2]:GetName()..[[");
								if (v and a and b) then
									v.rotorEntities={
										a,
										b
									};
									a.ss=a:PlaySoundEvent('sounds/vehicles:trackview_vehicles:heli_constant_run_with_fade',g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT)
									b.ss=b:PlaySoundEvent('sounds/vehicles:trackview_vehicles:heli_constant_run_with_fade',g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT)
								end;
							]];
							ExecuteOnAll(code);
						end;
					else
						temp = formatString([[
							local v=GetEnt("%s");
							local p=GP(%d);
							if (v and p) then
								if (p.id==g_localActorId) then
									HUD.DisplayBigOverlayFlashMessage("Jet Engine DISABLED", 10, 100, 360, { 0/255, 0/255, 255/255 });
								end;
								v.ThrusterON = false;
								v:Event_DisableMovement();
								if (v.JetType) then
									ATOMClient:JetEffects(v, v.JetType, false, 0);
								end;
								if (v.jetSound) then
									v:StopSound(v.jetSound)v.jetSound=nil;
								end;
								local v_re=v.rotorEntities;
								if (v_re and v_re[1].ss) then
									v_re[1]:StopSound(v_re[1].ss)
									v_re[2]:StopSound(v_re[2].ss)
									v_re[1].ss=nil;
									v_re[2].ss=nil;
								end;
							end;
						]], v:GetName(), player:GetChannel());
						ExecuteOnAll(temp);
						JETS[v.id] = nil;
					end;
				end;
			end;
			return true;
		end;
		
		if (id == eCR_VBrakeOFF) then
			Debug("off")
			if (v) then
				v.Braking = false;
				--v.EngineON = false;
				--if (v.IsJet) then
				--	Debug("Jet ENGINE OFF!!");
				--end;
			end;
			return true;
		end;
		
		-----------------------
		-- Client
		
		if (id == eCR_Installed) then
			self:OnInstalled(player);
			return true;
		end;
		
		if (id == eCR_InstallFail) then
			self:OnError(player);
			return true;
		end;

		-----------------------
		-- Hooked Entities
		
		if (id == eCR_OpenAnimDoor) then
			entity = GetClosestEntity("AnimDoor", player:GetPos(), 3);
			if (entity) then
				ExecuteOnAll([[GetEnt(']] .. entity:GetName() .. [['):Event_Open(1);]]);
			end;
			return true;
		end;
		
		if (id == eCR_CloseAnimDoor) then
			entity = GetClosestEntity("AnimDoor", player:GetPos(), 3);
			if (entity) then
				ExecuteOnAll([[GetEnt(']] .. entity:GetName() .. [['):Event_Close(1);]]);
			end;
			return true;
		end;
		
		-----------------------
		-- AntiCheat
		
		if (id == eCR_CheatNoRecoil) then
			ATOMDefense:OnCheat(player, "No Recoil", "Client Recoil is 0", false);
			return true;
		end;
		
		if (id == eCR_Mass) then
			ATOMDefense:OnCheat(player, "Mass", "Modified Mass on Client", false);
			return true;
		end;
		
		if (id == eCR_Gravity) then
			ATOMDefense:OnCheat(player, "Gravity", "Modified Gravity on Client", false);
			return true;
		end;
		
		if (id == eCR_Flags) then
			ATOMDefense:OnCheat(player, "Flags", "Modified Flags on Client", false);
			return true;
		end;
		
		if (id == eCR_Speed) then
			ATOMDefense:OnCheat(player, "Speed", "Modified Speed on Client", false);
			return true;
		end;
		
		if (id == eCR_Teleport) then
			if (_time - (player.iLastSvTeleport or 0) > 10) then
				ATOMDefense:OnCheat(player, "Teleport", "Teleporting on Client", false)
			end
			return true;
		end;
		
		if (id == eCR_Door) then
			ATOMDefense:OnCheat(player, "Door", "Manipulating Doors", false)
			return true;
		end;
		
		if (id == eCR_Vegetation) then
			ATOMDefense:OnCheat(player, "GhostVegetation", "Seeing through Vegetation", true, true)
			return true;
		end;
		
		if (id == eCR_VehicleTp) then
			if (_time - (player.iLastSvTeleport or 0) > 10 and timerexpired(player.hSvEnterVehicleTimer, 10)) then
				ATOMDefense:OnCheat(player, "VehicleTeleport", "Teleporting with Vehicle", true, false)
			end
			return true;
		end;
		
		
		-----------------------
		-- ATOM Rockets
		
		if (id == eCR_RocketON) then
			if (player.hasATOMRocket and not player.RocketPaticles) then
				if (not player.actor:GetLinkedVehicleId() and player.actor:GetHealth() >= 1 and player.actor:IsFlying()) then
					ATOMPack:AddRocketEffects(player);
				end;
			end;
			return true;
		end;
		
		if (id == eCR_RocketOFF) then
			if (player.hasATOMRocket and player.RocketPaticles) then
				ATOMPack:RemoveRocketEffects(player);
			end;
			return true;
		end;
		
		-----------------------
		-- ATOM Pack
		
		if (id == eCR_JetPack_ON) then
			if (player.hasJetPack and not player.JetPackPaticles) then
				if (not player.actor:GetLinkedVehicleId() and player.actor:GetHealth() >= 1 and player.actor:IsFlying()) then
					ATOMPack:AddEffects(player);
				end;
			end;
			return true;
		end;
		
		if (id == eCR_JetPack_OFF) then
			if (player.hasJetPack and player.JetPackPaticles) then
				ATOMPack:RemoveEffects(player);
			end;
			return true;
		end;
		
		if (id == eCR_JetPack_SUPER) then
			if (player.hasJetPack) then
				if (not player.actor:GetLinkedVehicleId() and player.actor:GetHealth() >= 1 and player.actor:IsFlying()) then
					if (not player.JetPackSuperSpeedPaticles) then
						ATOMPack:AddSuperEffects(player);
					end;
					ATOMGameUtils:SpawnEffect("explosions.wall_explosion.wall_break", player:GetPos(), vecScale(player.actor:GetHeadDir(), -1));
				end;
			end;
			return true;
		end;
		
		if (id == eCR_JetPack_FULL) then
			player.JetPackFuel = true;
			return true;
		end;
		
		if (id == eCR_JetPack_EMPTY) then
			player.JetPackFuel = false;
			return true;
		end;
		
		--------------------------------------
		
		if (id == eCR_ClientCryMP) then
			player.LuaClient = {
				"$4",
				"CryMP"	
			}
			self:OnInstalled(player)
			return true
		end;
		if (id == eCR_ClientSFWCL) then
			player.LuaClient = {
				"$5",
				"SFWCL"	
			}
			self:OnInstalled(player)
			return true
		end;
		if (id == eCR_ClientUnknown) then
			player.LuaClient = {
				"$1",
				"Unknown"	
			}
			self:OnInstalled(player)
			return true
		end;
		
		--------------------------------------
		
		if (id == eCR_Bot) then
			ATOM:OnBotConnection(player);
			return true;
		end;
		
		--------------------------------------
		
		if (id == eCR_UseObject1) then
			temp = System.GetNearestEntityByClass(player:GetPos(), 5, "CustomAmmoPickupLarge");
			--Debug(temp:GetName())
			if (temp and temp.IsAirDrop and ATOMAirDrop ~= nil) then
				ATOMAirDrop:OnUsed(player, temp);
			end
			return true;
		end;
		
		--------------------------------------
		
		if (id == eCR_Interactive) then
			temp = System.GetNearestEntityByClass(player:GetPos(), 5, "InteractiveEntity");
            if (temp) then
                Debug(temp:GetName())
                temp:Use(player);
                ExecuteOnAll(formatString("local IE=GetEnt(\"%s\")if IE then IE:Use(GP(%d))IE:DoSpawn()end", temp:GetName(), player:GetChannel()));
            end
            --SpawnEffect(ePE_Light, temp:GetPos(), g_Vectors.up, 0.4);
			return true;
		end;
		
		--------------------------------------
		
		if (id == eCR_ChairON) then
			if (player.chair and System.GetEntity(player.chair) and player.actor:IsFlying() and not player:IsSpectating() and not player:IsDead()) then
				local chair = System.GetEntity(player.chair);
				if (not chair.effect) then
					--Debug("EFFECT ON OWOW")
					local code = [[
						local c = GetEnt(']] .. chair:GetName() .. [[');
						if (c) then
							if (c._ES1) then
								c:FreeSlot(c._ES1);
								c:FreeSlot(c._ES2);
								c:FreeSlot(c._ES3);
							end;
							c._ES1 = c:LoadParticleEffect(-1, "misc.signal_flare.on_ground_purple", {});
							c._ES2 = c:LoadParticleEffect(-1, "misc.signal_flare.on_ground_green", {Scale = 2});
							c._ES3 = c:LoadParticleEffect(-1, "misc.signal_flare.on_ground", {Scale = 2});
							local d = g_Vectors.down;
							local p = c:GetPos();
							c:SetSlotWorldTM(c._ES3, p, d)
							c:SetSlotWorldTM(c._ES1, p, d)
							c:SetSlotWorldTM(c._ES2, p, d)
						end;
					]]
					if (chair.effectSyncID) then
						--Debug("Old effects sync oFF!")
						RCA:StopSync(chair, chair.effectSyncID);
					end;
					chair.effectSyncID = RCA:SetSync(chair, {linked=chair.id,client=code})
					ExecuteOnAll(code);
					ExecuteOnPlayer(player,[[g_localActor.hasFlyingChair =1;]])
					--Debug("CHAIR EFFECT ON!");
				end;
				chair.effect = true;
			end;
			
			return true;
		end;
		
		
		if (id == eCR_ChairOFF) then
			
			if (player.chair and System.GetEntity(player.chair)) then
				local chair = System.GetEntity(player.chair);
				if (chair.effect) then
					--Debug("EFFECT OFF OWOW")
					ATOMPack:RemoveChairEffects(player, chair)
					ExecuteOnPlayer(player,[[
						g_localActor.hasFlyingChair =0;
						g_localActor:StopAnimation(0,-1)]]);
				--	Debug("CHAIR EFFECT OFF!");
					
				end;
				chair.effect = false;
			end;
			return true;
		end;
		
		
		if (id == eCR_UseObject2) then
			--if (player.InMeeting) then
			--	SendMsg(player, player, "!meeting " .. player.MeetingChairID)
			--	return true
			--end

			local hMount = player.hMount
			if (hMount and timerexpired(player.hMountTimer, 2.5)) then
				hMount:OnUse(player)
			end

			if (player.chair and GetEnt(player.chair)) then
				temp = GetEnt(player.chair);
				if (not player.actor:IsFlying()) then
					if (player.sitting) then
						--Debug("Get the Fuck off the fucking chair");
						if (temp.ExitTimer) then
							Script.KillTimer(temp.ExitTimer);
						end;
						temp.ExitTimer = Script.SetTimer(300, function()
							if (player.chair and GetEnt(player.chair) and player.sitting) then
								if (_time - player.LastInteractiveActivity > 2) then
									ATOMPack:RemoveFlyingChair(player, GetEnt(player.chair));
								end;
							end;
						end);
					end;
				end;
				return true;
			end;
			
			if (player.ChairEnterTimer) then
				Script.KillTimer(player.ChairEnterTimer);
			end;
			player.ChairEnterTimer = Script.SetTimer(300, function()
				if (_time - player.LastInteractiveActivity > 1) then
					local closest = 3;
					for i, gui in pairs(System.GetEntitiesByClass("GUI")or{}) do
						if (gui.chair and (not gui.player or not GetEnt(gui.player))) then
							if (GetDistance(player, gui) < closest) then
								closest = GetDistance(player, gui);
								temp = gui;
							end;
						end;
					end;
					if (temp) then
						--Debug("found new chair uwu");
						if (not player.actor:IsFlying()) then
							--Debug("hop on!");
							ATOMPack:AddFlyingChair(player, temp);
							return true;
						end;
					end;
				end;
			end);
			--Debug("use")
			Script.SetTimer(300, function()
				if (not player:GetVehicle()) then
					--Debug("No v")
					temp = player:GetHitPos(2, ent_all, player:GetPos(), g_Vectors.down);
					if (temp) then
						--Debug("ray")
						temp = temp.entity;
						if (temp and temp.JetType) then
							--Debug("jet uwu")
							if (player.attached) then
								player.attached = false;
								self:StopSync(player, player.attachedSyncID);
								player.attachedSyncID = nil;
								ExecuteOnAll(formatString([[
									GP(%d):DetachThis();
									GP(%d)._ATTACHEDTO=nil
								]], player:GetChannel()));
								--Debug("detached")
								player:DetachThis();
							else
								player.attached = true;
								local code = formatString([[
									local v=GetEnt("%s");
									if (v) then
										v:AttachChild(GP(%d).id,1);
										GP(%d)._ATTACHEDTO=v.id
									end;
								]], temp:GetName(),player:GetChannel());
								player.attachedSyncID = self:SetSync(temp, {client=code,link=temp.id});
								ExecuteOnAll(code);
								--Debug("attached")
								temp:AttachChild(player.id,1);
							end;
							
						end;
					end;
				end;
			end);
			
			closest = 3;
			for i, v in pairs(System.GetEntities()) do
				if (v.MarkedForUse) then
					if (GetDistance(player, v) < closest) then
						closest = GetDistance(player, v);
						temp = v;
					end;
				end;
			end;
			if (temp and temp.OnUsed) then
				temp.OnUsed(temp, player);
				return true;
			end;
			
			return true;
		end;
		
		if ( id == eCR_UseObject3 ) then
		
			--Debug("SEAL")
			temp = g_utils:GetClosestBuilding(player:GetPos(), 10, "bunker");
			if (temp and temp.BunkerDoors) then
				temp.SealBunkers(temp, player);
				return true;
			end;
			
			return true;
		end;
		
		--------------------------------------
		
		if ( id == eCR_DropSpecial ) then
		
			--Debug("SEAL")
			temp = player.inventory:GetItemByClass("ShiTen");
			temp = temp and GetEnt(temp);
			if (temp and not temp.item:IsMounted()) then
				System.RemoveEntity(temp.id);
				player.actor:SelectItemByNameRemote("Fists");
				local fakeShiten = System.SpawnEntity({
					class = "CustomAmmoPickup",
					ammoClass = "ShiTen",
					name = temp:GetName() .. "_fake",
					position = player:CalcPos(1, 1),
					orientation = player:GetDirectionVector(),
					properties = {
						AmmoName = "tagbullet",
						AmmoCount = 0,
						count = 0,
						bPhysics = 1,
						objModel = "Objects/weapons/asian/shi_ten/shi_ten_vehicle.chr",
						fMass = 10,
					}
				});
				g_utils:AwakeEntity(fakeShiten);
				fakeShiten:AddImpulse(-1, fakeShiten:GetCenterOfMassPos(), player:GetHeadDir(), fakeShiten:GetMass() * 2, 1);
				fakeShiten.OnPrePickup = function(self, user)
					System.RemoveEntity(self.id);
					local shiten = GetEnt(ItemSystem.GiveItem("ShiTen", user.id, false));
					user.actor:SelectItemByNameRemote("ShiTen");
					if (g_gameRules.class == "PowerStruggle") then
						g_gameRules.buyList["shiten"].ItemProperties.Call(shiten, player);
					end;
					return false;
				end;
				g_game:ScheduleEntityRemoval(fakeShiten.id, 30, false);
			end;
			
			return true;
		end;
		
		--------------------------------------
		
		--Debug("!!! >>>",eCR_Pong, id)
		if (id == eCR_Pong) then
			--Debug("Pong!",_time-player.PongTime);
			player.PongTime = nil;
			player.PingTime = _time;
			return true;
		end;
		
		--------------------------------------
		
		if (id >= 120 and id <= 123) then
			if (id == 120 or id == 121) then
				player.chat_open = true;
				self:HandleChat(player, 1);
				--Debug("Open");
			else--if (player.chat_open) then
				--Debug("Close");
				player.chat_open = false;
				self:HandleChat(player, 0);
			end;
			return true;
		end;
		
		--------------------------------------
		
		if (id == eCR_JoinMeeting) then
			temp = System.GetNearestEntityByClass(player:GetPos(), 5, "GUI");
			--Debug(temp:GetName())
			if (temp and temp.isMeetingChair) then
				if (temp.user) then
					SendMsg(ERROR, player, "This Chair is already in use")
				else
					local freeSeat
					for i, v in pairs(THE_MEETING) do
						if (v.Chair and not v.Entity.user) then
							freeSeat = v.ChairId
						end
					end
					if (freeSeat) then
						SendMsg(player, player, "!meeting " .. freeSeat)
					else
					SendMsg(ERROR, player, "All Seats are in use")
					end
				end
			end;
			return true;
		end
		--Debug("NOT JOIN ???",id)
		
		--------------------------------------
		
		if (id == eCR_F3) then
			--Debug("F3")
			temp = player:GetVehicle();
			if (temp and temp:GetDriverId() == player.id) then
				if (temp.BombOK) then
					--Debug("ok")
					if (temp.JetType == 2) then
						--Debug("o2k")
						self:HandleJetBombs(player, temp);
					end;
				elseif (temp.IsTrans) then
					self:HandleTransVtol(player, temp);
				else
					self:HandleFireTires(player, temp);
				end;
			elseif (player.sitting and player.chair and GetEnt(player.chair) and player.keepChair) then
				temp = GetEnt(player.chair);
				temp:SetWorldPos(player:GetPos());
				ATOMItems:AddProjectile(
				mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
					Owner = player,
					Weapon = player,
					Pos = add2Vec(temp:GetPos(), makeVec(0,0,-1)),
					Dir = player:GetHeadDir(),--g_Vectors.down,
					Hit = add2Vec(temp:GetPos(), makeVec(0,0,-10)),
					Normal = g_Vectors.up,
					
				}));
			end;
			return true;
		end;
		
		--------------------------------------
		
		if (id > 4) then
			return true, ATOMLog:LogRCA("Invalid Client Response %d from %s$9", id, player:GetName());
		end;
		
		return false;
	end;
	----------
	PlayerLoot = function(self, player, target)
		if (g_gameRules.class ~= "PowerStruggle") then
			return
		end
		
		target.LastLoot = target.LastLoot or {}
		if (target.LastLoot[player.Info.Channel]) then
			return
		end
		target.LastLoot[player.Info.Channel] = true
		
		local prestige = target:GetPrestige()
		local steal = round(prestige * 0.1)
		if (steal >= 25) then
			g_gameRules:AwardPPCount(player.id, steal, nil, true);
			ExecuteOnPlayer(player, "HUD.BattleLogEvent(eBLE_Currency, \"Target Looted ( +" .. steal .. " PP )\");");
		else
			SendMsg(ERROR, player, "Nothing worth looting ..")
		end
		
		SendMsg(CENTER, target, player:GetName() .. " Looted you ...")
		
	end,
	----------
	PlayerTalk = function(self, player, target)
		if (target.actor:GetHealth() <= 0) then
			return self:PlayerLoot(player, target)
		end;
		if (not player.Talking) then
			player.Talking = true;
			SendMsg(CENTER, target, "%s Is Talking to You", player:GetName());
			local sounds = {
			
			};
			player.greeted = player.greeted or {};
			if (not player.greeted[target.id] or _time - player.greeted[target.id]>120) then
				player.greeted[target.id] = _time;
				sounds = {
					"languages/dialog/ai_jester/greets_00.mp2",
					"languages/dialog/ai_jester/greets_01.mp2",
					"languages/dialog/ai_jester/greets_02.mp2",
					"languages/dialog/ai_jester/greets_03.mp2",
					"languages/dialog/ai_jester/greets_04.mp2",
					"languages/dialog/ai_jester/greets_05.mp2"
				};
			elseif (_time - player.greeted[target.id] < 10) then
				sounds = {
					"languages/dialog/ai_jester/staring_00.mp2",
					"languages/dialog/ai_jester/staring_01.mp2",
					"languages/dialog/ai_jester/staring_02.mp2",
					"languages/dialog/ai_jester/staring_03.mp2",
					"languages/dialog/ai_jester/staring_04.mp2",
					"languages/dialog/ai_jester/staring_05.mp2",
					"languages/dialog/ai_jester/staring_06.mp2",
					"languages/dialog/ai_jester/staring_07.mp2",
					"languages/dialog/ai_jester/staring_08.mp2",
					"languages/dialog/ai_jester/staring_09.mp2",
					"languages/dialog/ai_jester/staring_10.mp2",
					"languages/dialog/ai_jester/staring_11.mp2",
				};
			else
				sounds = {
					"languages/dialog/island/jester_island_ab3_00077.mp2",
					"languages/dialog/island/jester_island_ab3_00078.mp2",
					"languages/dialog/island/jester_island_ab3_00082.mp2",
					"languages/dialog/island/jester_island_ab3_00084.mp2",
					"languages/dialog/island/jester_island_ab3_00080.mp2",
					"languages/dialog/island/jester_island_ab2_findaztec1.mp2",
					"languages/dialog/island/jester_island_ab2_findaztec2.mp2",
					"languages/dialog/island/jester_island_ab2_findaztec3.mp2",
					"languages/dialog/island/jester_island_ab3_stillhere.mp2",
					"languages/dialog/island/jester_island_ab2_ar0001.mp2",
					"languages/dialog/island/jester_island_ab9_41d8eba1.mp2",
					"languages/dialog/island/jester_island_ab9_5000804b.mp2",
				
				};
			end;
			
			local anims = {
				Listen = {
					"relaxed_idleListening_01",
					"relaxed_idleListening_02",
					"relaxed_idleListening_03"
				};
				Talk = {
					"relaxed_idleTalk_nw_01",
					"relaxed_idleTalk_nw_02",
					"relaxed_idleTalk_nw_03"
				};
			};
			
			local sound = GetRandom(sounds);
			ExecuteOnAll([[
				local p=GP(]] .. player:GetChannel() .. [[)p:PlaySoundEvent("]]..sound..[[", g_Vectors.v000, g_Vectors.v010, bor(bor(SOUND_EVENT, SOUND_VOICE),SOUND_DEFAULT_3D),SOUND_SEMANTIC_PLAYER_FOLEY);
				GP(]]..target:GetChannel()..[[):StartAnimation(0,"]]..GetRandom(anims.Listen)..[[",9);
				p:StartAnimation(0,"]]..GetRandom(anims.Talk)..[[",9);
			]]);
			Script.SetTimer(5000, function()
				player.Talking = false;
			end);
		end;
	end,
	----------
	HandleJetBombs = function(self, player, vehicle)
		--Debug("HandleJetBombs")
		
		if (not vehicle.BombDrop) then
			vehicle.BombDrop = true;
			for i = 1, 4 do
				Script.SetTimer((i>1 and i or 0) * 300, function()
					if (i == 4) then
						Script.SetTimer(3000, function()
							vehicle.BombDrop = false;
						end);
					end;
					if (not vehicle.vehicle:IsDestroyed()) then
						--Debug("Dropping jet poop");
						-- I really don't like copy/pasting these huge tables all over our lua files, but what can I do..
						ATOMItems:AddProjectile(
						mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
							Owner = player,
							Weapon = vehicle,
							Pos = add2Vec(vehicle:GetPos(), makeVec(0,0,-5)),
							Dir = g_Vectors.down,
							Hit = add2Vec(vehicle:GetPos(), makeVec(0,0,-15)),
							Normal = g_Vectors.up,
							Properties = {
								FilterProjectileCollisions = true, 
								LifeTime = 20000,
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
									Strength = 50,
								},
								Events = {
									Collide = function(p, t, pos, contact, dir)
										if (t == COLLISION_WATER) then
											Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
											PlaySound("sounds/physics:explosions:water_explosion_large", contact);
										else
											Explosion(GetRandom({"explosions.C4_explosion.ship_door", "explosions.C4_explosion.ship_door"}), contact, 5, 500, dir, player, player, 0.5);
											PlaySound("sounds/physics:explosions:explo_rocket", contact);
										end;
									end,
								},
							};
						}));
					end;
				end);
			end;
		else
			SendMsg(CENTER, player, "Please wait until current bombs dropped");
			--Debug("CHILL YOUR FUKING TITS ", player:GetName());
		end;
	end,
	----------
	MakeJet = function(self, vehicle, t, specialModel)
		local code = [[local v=GetEnt("]]..vehicle:GetName()..[[");if(not v) then return end;]]
		if (vehicle.IsJet) then
			code = code .. [[JETS[v.id]=nil;v:Event_EnableMovement()v.IsJet=nil;]];
			ExecuteOnAll(code);
			self:StopSync(vehicle, vehicle.jetSynch);
			if (vehicle.rotorSynch) then
				self:StopSync(vehicle, vehicle.rotorSynch);
				System.RemoveEntity(vehicle.rotorEntities[1].id);
				System.RemoveEntity(vehicle.rotorEntities[2].id);
				vehicle.rotorEntities = nil;
			end;
			vehicle.jetSynch = nil;
			vehicle.JetType = nil;
			vehicle.BombOK = false;
		else
			local respectiveModelProps = {
				[1] = { 6, "Objects/library/vehicles/aircraft/aircraft.cgf", 							{ x = 0, y = -0.00, z = -0.00 }, makeVec(0,0,0),			false, },
				[2] = { 8, "objects/vehicles/us_fighter_b/us_fighter.cga",								{ x = 0, y = -1, z = -1.4 }, makeVec(0,0,3.14),			false, },
				[3] = { 9, "objects/vehicles/us_cargoplane/us_cargoplane_open.cgf", 						{ x = 0, y = -21.0, z = -5.8 }, makeVec(0,0,-1.5727), 	false, },
			};
			
			local otherModels = {
				[1] = { 7, "objects/vehicles/asian_fighter/asian_fighter.cgf",							{ x = 0, y = -1, z = 1 }, makeVec(0,0,0),			false},
			};
			
			vehicle.JetType = tonum(t or 2);
			local newModel = (specialModel and otherModels[specialModel] or respectiveModelProps[vehicle.JetType]);
			if (newModel and not vehicle.ModelId) then
				vehicle.ModelId = newModel[1];
				g_utils:LoadVehicleModel(vehicle, newModel[2], newModel[3], newModel[4], newModel[5], newModel[6]);
			end;
			if (vehicle.jetSynch) then
				self:StopSync(vehicle, vehicle.jetSynch);
			end;
			if (vehicle.rotorSynch) then
				self:StopSync(vehicle, vehicle.rotorSynch);
			end;
			code = code .. [[v:SetViewDistRatio(10000);v.IsJet=true;JETS[v.id]=v;v.JetType=]]..(t or 2)..[[;v:Event_DisableMovement();v.ThrusterON=false;v.MovingForward_H=false;v.MovingBackwards_H=false]];
			if (vehicle.JetType == 1) then
				--Debug("spawn rotor too ")
				vehicle.rotorEntities = {
					SpawnGUI("objects/weapons/attachments/scope_assault/scope_assault_fp_low.cgf", g_Vectors.up),
					SpawnGUI("objects/weapons/attachments/scope_assault/scope_assault_fp_low.cgf", g_Vectors.up)
				};
				local rotor_code = [[
					local v=GetEnt("]]..vehicle:GetName()..[[");
					local a,b,c,m,ml=GetEnt("]]..vehicle.rotorEntities[2]:GetName()..[["),GetEnt("]]..vehicle.rotorEntities[1]:GetName()..[["),GetEnt("]]..vehicle:GetName()..[["),"Objects/library/architecture/harbour/pipes/pipe_6m.cgf",'Objects/library/vehicles/carrier_support_truck/carrier_support_truck';
					if (v and JETS[v.id]) then
						a:LoadObject(0, m);
						b:LoadObject(0, m);
						a:SetScale(0.6)
						b:SetScale(0.6)
						a:DestroyPhysics()
						b:DestroyPhysics()
						c:AttachChild(a.id,0);
						c:AttachChild(b.id,0);
						a:EnablePhysics(false)
						b:EnablePhysics(false)
						a:SetMaterial(ml)
						b:SetMaterial(ml)
						a.cdir = -3.1;
						b.cdir = -3.1;
						a:SetLocalPos({x=-3.95, y=5.6,z=-0.4})
						a:SetLocalAngles({x=0,y=0,z=0})
						b:SetLocalPos({x=3.95,y=5.6,z=-0.4})
						b:SetLocalAngles({x=0,y=0,z=0})
						a.rotorParent=c.id;
						b.rotorParent=c.id;
						JETS[v.id].rotors = {};
					end;
				]];
				Script.SetTimer(500, function()
					ExecuteOnAll(rotor_code);
				end);
				vehicle.rotorSynch = self:SetSync(vehicle, {linked=vehicle.id,client=code});
			end;
			ExecuteOnAll(code);
			vehicle.jetSynch = self:SetSync(vehicle, {client=code,linked=vehicle.id});
			vehicle.BombOK = true;
		end;
		vehicle.IsJet = not vehicle.IsJet;
		return vehicle.IsJet;
	end,
	----------
	HandleTransVtol = function(self, player, vehicle)
		if (vehicle:GetDriverId() == player.id) then
			local currCargo = vehicle.TransCargo and GetEnt(vehicle.TransCargo);
			if (currCargo) then
				vehicle.TransCargo = nil;
				if (vehicle.TransCargoSyncID) then
					self:Unsync(vehicle, vehicle.TransCargoSyncID);
					vehicle.TransCargoSyncID = nil;
				end;
				local code = [[
					local t, c = GetEnt(']] .. vehicle:GetName() .. [['), GetEnt(']] .. currCargo:GetName() .. [[');
					if (c) then
						local p = t:GetPos();
						c:DetachThis();
						c:SetWorldPos({ x = p.x, y = p.y, z = p.z - 7 });
						c:SetDirectionVector(t:GetDirectionVector());
						c:AwakePhysics(1);
					end;
				]];
				local mass, speed = vehicle:GetMass(), vehicle:GetSpeed();
				Script.SetTimer(300, function()
					local dir = vehicle:GetDirectionVector()
					if (currCargo:GetDriver()) then
						ExecuteOnAll([[
							local v=GetEnt(']]..currCargo:GetName()..[[')
							if(not v or not v.GetDriver)then return end
							local d=v:GetDriverId()
							if(d==g_localActorId)then
								v:AddImpulse(-1,v:GetPos(),]]..arr2str_(dir) .. [[,]]..mass*speed..[[,1)
							end
						]]);
					else
						currCargo:AddImpulse(-1, currCargo:GetCenterOfMassPos(), dir, mass * speed, 1);
					end;
				end);	
				SendMsg(CENTER, player, "The Cargo was detached!");
				ExecuteOnAll(code);
				loadstring(code)();
			elseif (vehicle.PossibleTransCargo) then
				if (vehicle:GetSpeed() > 3) then
					return SendMsg(ERROR, player, "You must be standing still to attach cargo!");
				end;
				vehicle.TransCargo = nil;
				if (vehicle.TransCargoSyncID) then
					self:Unsync(vehicle, vehicle.TransCargoSyncID);
					vehicle.TransCargoSyncID = nil;
				end;
				local cargo = GetEnt(vehicle.PossibleTransCargo);
				if (cargo) then
					if (cargo:GetSpeed() > 3) then
						return SendMsg(ERROR, player, "The Cargo must be standing still in order to attach!");
					end;
					vehicle.TransCargo = cargo.id;
					local code = [[
						local t, c = GetEnt(']] .. vehicle:GetName() .. [['), GetEnt(']] .. cargo:GetName() .. [[');
						if (t and c) then
							local p = t:GetPos();
							t:AttachChild(c.id, 1);
							c:SetDirectionVector(t:GetDirectionVector());
							c:SetWorldPos({ x = p.x, y = p.y, z = p.z - 7 });
						end;
					]];
					ExecuteOnAll(code);
					vehicle.TransCargoSyncID = self:SetSync(vehicle, { client = code, links = { cargo.id, vehicle.id }, link = true});
					loadstring(code)();
				else
					vehicle.PossibleTransCargo = nil;
				end;
			end;
		end;
	end,
	----------
	HandleFireTires = function(self, player, vehicle)
		local supported = {
			["Civ_car1"] = true,
			["US_ltv"] = true,
			["Asian_ltv"] = true, -- does this even exist? or am I lost ?
			["Asian_truck"] = true,
		};
		local vehicle = vehicle or player:GetVehicle();
		if (not vehicle or not supported[vehicle.class]) then
			return false, SendMsg(BLE_ERROR, player, "FireTires : %s", (vehicle and "Unsupported Vehicle" or "Only In Vehicle"));
		end;
		--Debug("good")
		if (not vehicle.FireTires) then
			--Debug("good :D")
			vehicle.FireTires = true; --true;
			Script.SetTimer(7000, function()
				vehicle.FireTires = false;
			end);
			ExecuteOnAll(formatString([[
				local v = GetEnt("%s");
				local p = GP(%d);
				if (v and p and v:GetDriverId() and v:GetDriverId() == p.id) then
					FIRE_TIRES[#FIRE_TIRES + 1] = { _time, p, v, 0 };
					if (v.tire_sound) then
						v:FreeSlot(v.tire_sound);
						v:FreeSlot(v.tire_effect);
					end;
					v.tire_effect = v:LoadParticleEffect(-1, "misc.electric_man.fire_man", { Scale = 1, CountScale = 59, CountPerUnit = 50, AttachType = "Render", AttachForm = "Surface" });
					v.tire_sound = v:PlaySoundEvent("Sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade", g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
					Sound.SetSoundVolume(v.tire_sound, 0.2)
				end;
			]], vehicle:GetName(), player:GetChannel()));
			--for i = 1, 4 do
			--			if (v.tire_effect[i]) then
			--				v:FreeSlot(v.tire_effect[i]);
			--			end;
			--			v.tire_effect[i] = v:LoadParticleEffect(i, "misc.electric_man.fire", {});
			--		end;
			--Debug("perfect :D")
		end;
	end,
	----------
	HandleChat = function(self, hPlayer, iActive)

		if (iActive == 1) then
			local sCode = string.format("g_Client:AddChatEffect(%d)", hPlayer:GetChannel())

			if (not hPlayer.bHasChatEffect) then
				ExecuteOnAll(sCode)
			end
			if (hPlayer.hChatSymSync) then
				self:StopSync(hPlayer, hPlayer.hChatSymSync)
			end
			hPlayer.hChatSymSync = self:SetSync(hPlayer, { link = hPlayer.id, client = sCode })

		elseif (hPlayer.hChatSymSync) then

			ExecuteOnAll(string.format([[g_Client:DeleteChatEffect(%d)]], hPlayer:GetChannel()))
			self:StopSync(hPlayer, hPlayer.hChatSymSync)
			hPlayer.hChatSymSync = nil
		end

		hPlayer.bHasChatEffect = (iActive == 1)
	end,
    ----------
    SetForcedModel = function(self, iModel)
		local aModels = self:GetModels()
		if (not aModels[iModel]) then
			return SysLog("Attempt to set Forced Model to invalid model '%s'", tostring(iModel))
		end

		local aModel = aModels[iModel]
		self.ForcedClientModel = aModel
		self.ForcedClientModel[4] = iModel

		SysLog("Setting forced Client Model to %s (%d)", aModel[1], iModel)
	end,
    ----------
    GetModels = function()

            local aModels = {
    			[0] = { "Nomad", "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf" , true},
				[1] = {"General Kyong", "objects/characters/human/story/Kyong/Kyong.cdf", true},
				[2] = {"Korean AI", {
    			
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_04.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_05.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_07.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_heavy_09.cdf",
    			
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_01.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_cover_light_02.cdf",
    			
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_04.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_02.cdf",
    			"objects/characters/human/asian/nk_soldier/nk_soldier_camp_light_leader_03.cdf",
    			
    			}, nil },
				[3] = {"Aztec", "objects/characters/human/story/Harry_Cortez/harry_cortez_chute.cdf", 1},
				[4] = {"Jester", "objects/characters/human/story/Martin_Hawker/Martin_Hawker.cdf", 1},
				[5] = {"Sykes", "objects/characters/human/story/Michael_Sykes/Michael_Sykes.cdf", 1},
				[6] = {"Prophet", "objects/characters/human/story/Laurence_Barnes/Laurence_Barnes.cdf", 1},
				[7] = {"Psycho", "objects/characters/human/story/Laurence_Barnes/Laurence_Barnes.cdf", 1},
				[8] = {"Badowsky", "objects/characters/human/story/badowsky/Badowsky.cdf"},
				[9] = {"Scientist", "objects/characters/human/story/female_scientist/female_scientist.cdf"},
				[10] = {"Keegan", "Objects/characters/human/story/keegan/keegan.cdf"},
				[11] = {"Journalist", "objects/characters/human/story/Journalist/journalist.cdf"},
				[12] = {"Dr Rosenthal", "objects/characters/human/story/Dr_Rosenthal/Dr_Rosenthal.cdf"},
				[13] = {"Lt Bradley", "objects/characters/human/story/Lt_Bradley/Lt_Bradley_radio.cdf"},
				[14] = {"Richard M", "objects/characters/human/story/Richard_Morrison/morrison_with_hat.cdf"},
				[15] = {"NK Pilot", "objects/characters/human/asian/pilot/koreanpilot.cdf"},
				[16] = {"Gong Pitter", "objects/characters/human/us/fire_fighter/green_cleaner.cdf"},
				[17] = {"Shemad", "objects/characters/human/story/helena_rosenthal/helena_rosenthal.cdf"},
				[18] = {"Jump Sailor", "objects/characters/human/us/jumpsuitsailor/jumpsuitsailor.cdf"},
				[19] = {"Navy Pilot", "objects/characters/human/us/navypilot/navypilot.cdf"},
				[20] = {"Marine", {
    			
    			"objects/characters/human/us/marine/marine_01.cdf",
    			"objects/characters/human/us/marine/marine_02.cdf",
    			"objects/characters/human/us/marine/marine_03.cdf",
    			"objects/characters/human/us/marine/marine_04.cdf",
    			"objects/characters/human/us/marine/marine_05.cdf",
    			"objects/characters/human/us/marine/marine_06.cdf",
    			"objects/characters/human/us/marine/marine_07.cdf",
    			"objects/characters/human/us/marine/marine_08.cdf",
    			"objects/characters/human/us/marine/marine_09.cdf",
    			
    			"objects/characters/human/us/marine/marine_01_helmet_goggles_off.cdf",
    			"objects/characters/human/us/marine/marine_02_helmet_goggles_off.cdf",
    			"objects/characters/human/us/marine/marine_03_helmet_goggles_off.cdf",
    			"objects/characters/human/us/marine/marine_04_helmet_goggles_off.cdf",
    			"objects/characters/human/us/marine/marine_05_helmet_goggles_off.cdf",
    			
    			"objects/characters/human/us/marine/marine_01_helmet_goggles_on.cdf",
    			"objects/characters/human/us/marine/marine_02_helmet_goggles_on.cdf",
    			"objects/characters/human/us/marine/marine_03_helmet_goggles_on.cdf",
    			"objects/characters/human/us/marine/marine_04_helmet_goggles_on.cdf",
    			"objects/characters/human/us/marine/marine_05_helmet_goggles_on.cdf",
    			
    			
    			}, nil },
				[21] = {"Corona Guy", {
    			
    			"objects/characters/human/asian/scientist/chinese_scientist_01.cdf",
    			"objects/characters/human/asian/scientist/chinese_scientist_02.cdf",
    			"objects/characters/human/asian/scientist/chinese_scientist_03.cdf",
    			"objects/characters/human/asian/scientist/chinese_scientist_01_hazardmask.cdf",
    			"objects/characters/human/asian/scientist/chinese_scientist_02_hazardmask.cdf",
    			"objects/characters/human/asian/scientist/chinese_scientist_03_hazardmask.cdf",
    			
    			
    			}, nil },
				[22] = {"Officer", {
    			
    			"objects/characters/human/us/officer/officer_01.cdf",
    			"objects/characters/human/us/officer/officer_02.cdf",
    			"objects/characters/human/us/officer/officer_03.cdf",
    			"objects/characters/human/us/officer/officer_04.cdf",
    			"objects/characters/human/us/officer/officer_05.cdf",
    			
    			"objects/characters/human/us/officer/officer_afroamerican_01.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_02.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_03.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_04.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_05.cdf",
    			
    			"objects/characters/human/us/officer/officer_afroamerican_01.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_02.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_03.cdf",
    			"objects/characters/human/us/officer/officer_afroamerican_04.cdf",
    			
    			}, nil },
				[23] = {"Technican", {
    			
    			"objects/characters/human/asian/technician/technician_01.cdf",
    			"objects/characters/human/asian/technician/technician_02.cdf"
    			
    			}, nil },

				[24] = {"Archaeologist", {
    			
    			"objects/characters/human/us/archaeologist/archaeologist_female_01.cdf",
    			"objects/characters/human/us/archaeologist/archaeologist_female_02.cdf",
    			
    			}, nil },

				[25] = {"Archaeologist", {
    			
    			"objects/characters/human/us/archaeologist/archaeologist_male_01.cdf",
    			"objects/characters/human/us/archaeologist/archaeologist_male_02.cdf",
    			
    			}, nil },

				[26] = {"Firefighter", {
    			
    			"objects/characters/human/us/fire_fighter/firefighter.cdf",
    			"objects/characters/human/us/fire_fighter/firefighter_helmet.cdf",
    			"objects/characters/human/us/fire_fighter/firefighter_silver.cdf",
    			"objects/characters/human/us/fire_fighter/firefighter_silver_mask.cdf",
    			"objects/characters/human/us/fire_fighter/firefighter_silver_maskvs2.cdf",
    			
    			}, nil },

				[27] = {"Deckhander", {
    			
    			"objects/characters/human/us/deck_handler/deck_handler_grape_helmet.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_blue.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_brown.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_grape.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_green.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_red.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_white.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_blue2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_yellow.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_brown2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_grape2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_green2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_red2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_white2.cdf",
    			"objects/characters/human/us/deck_handler/deckhand_yellow2.cdf",
    			
    			}, nil },

				[28] = {"Alien", "objects/characters/alien/alienbase/alienbase.cdf" },
				[29] = {"Hunter", "objects/characters/alien/hunter/hunter.cdf" },
				[30] = {"Scout", "objects/characters/alien/scout/scout_leader.cdf" },
    			--{"Trooper", "objects/characters/alien/scout/scout_base.cdf" },
				[31] = {"Shark", "objects/characters/animals/Whiteshark/greatwhiteshark.cdf"},
				[32] = {"Dog or sum", "Objects/characters/alien/trooper/trooper_base.chr" },
    			[33] = {"Alien Trooper", "objects/characters/alien/trooper/trooper_leader.chr" },
    			[34] = {"Chicken", "objects/characters/animals/birds/chicken/chicken.chr" },
    			[35] = {"Alien", "objects/characters/alien/alienbase/alienbase.cdf" },
				[36] = {"Turtle", "objects/characters/animals/turtle/turtle.cdf" },
				[37] = {"Crab", "objects/characters/animals/crab/crab.cdf" },
				[38] = {"Finch", "objects/characters/animals/birds/plover/plover.cdf" },
				[39] = {"Tern", "Objects/characters/animals/birds/tern/tern.chr" },
				[40] = {"Frog", "objects/characters/animals/frog/frog.chr" },
				[999] = { "Nomad", "ATOMObjects/Chars/US_NanoSuit/NoHelmet.cdf" }
    		}

            return aModels

        end,
	----------
	GetCharacters = function(self)

		local aCharacters = {
			{ "Alien Trooper", 	 33, { "Fists", "FastLightMOAC" } },
			{ "Alien Worker", 	 35, { "Fists", "FastLightMOAC" } },
			--{ "Scout", 30, { "Fists", "FastLightMOAC" } },
			{ "Shark", 	 31, { "Fists" } },
			{ "Chicken", 34, { "Fists" } },
			{ "Turtle",	 36, { "Fists" } },
			{ "Crab", 	 37, { "Fists" } },
			{ "Finch", 	 38, { "Fists" } },
			{ "Tern", 	 39, { "Fists" } },
			{ "Frog", 	 40, { "Fists" } },
		}

		return aCharacters

	end,
	----------
	GetHeads = function(self)

		local aHeads = {
			{ "Helena", 999 },
			{ "Chicken", 999 },
		}

		return aHeads

	end,
	----------
    ToggleForceModel = function(self, hPlayer, iModel)


            local aModels = self:GetModels()
            local iModel = iModel
            if (iModel) then
                iModel = tonumber(iModel)
            end

            if ((FORCED_CLIENT_MODEL and FORCED_CLIENT_MODEL == iModel) or iModel == 0 or (FORCED_CLIENT_MODEL and not iModel)) then
                SendMsg(CHAT_ATOM, hPlayer, "(ForcedModel: Disabled)")
                FORCED_CLIENT_MODEL = nil
                return true
            end

            -- Debug("iModel", iModel)

            if (not iModel or not aModels[iModel]) then
                ListToConsole(hPlayer, aModels, "Available Models")
                SendMsg(CHAT_ATOM, hPlayer, "Open your Console to view the ( %d ) Available Models", table.count(aModels))
                return true
            end

            FORCED_CLIENT_MODEL = aModels[iModel]
            FORCED_CLIENT_MODEL[4] = iModel

            SendMsg(CHAT_ATOM, hPlayer, "(ForcedModel: Set to %s)", FORCED_CLIENT_MODEL[1])

            return true
        end,
	----------
	OnPickupObject = function(self, hPlayer, hObject)

		do return end

		if (not GetBetaFeatureStatus("objectgrab")) then
			return
		end

		if (not hPlayer or not hObject) then
			return
		end

		if (hPlayer.iPickedObjectSyncId) then
			self:StopSync(hPlayer, hPlayer.iPickedObjectSyncId)
		end

		local sCode = [[
			local x=GP(]]..hPlayer:GetChannel()..[[)
			local y=GetEntityByHash(']]..GetEntityHash(hObject)..[[')
			if(y)then
				Msg(0, "found %s", y:GetName())
				x.hGrabbedObject_H=y
				x.sGrabbedObjectHash_H="]]..GetEntityHash(hObject)..[["
				if(x and x.id ~=g_localActorId)then
					x:AttachChild(y.id,1)
				elseif (false) then
					local z=x.inventory:GetItemByClass("Fists")
					x.hTimerPickupStart=timerinit()
					if(z)then
						Msg(0,"ok")
						x.actor:SelectItemByName("Fists")
						z=System.GetEntity(z)
						z.item:Select(true)
						z.hTimerPickupStart = timerinit()
						z:StopAnimation(0,-1)
						z:StartAnimation(0,"grab_onto_01")
					end
				end
			end
		]]

		sCode = string.format("g_Client.GrabHandler:PickupObject(%d, '%s')", hPlayer:GetChannel(), GetEntityHash(hObject))

		hObject:SetPhysicParams(PHYSICPARAM_FLAGS, {flags_mask = pef_cannot_squash_players, flags = pef_cannot_squash_players})
		hPlayer:AttachChild(hObject.id, 1)
		hObject:SetPos(hPlayer:GetBonePos("Bip01 R Hand"))

		hPlayer.hPickedupObject = hObject
		hPlayer.iPickedObjectSyncId = self:SetSync(hPlayer, { client = sCode, links = { hObject.id, hPlayer.id }, link = true })
		ExecuteOnAll(sCode)

		Debug("Pick up ", hObject:GetName())
	end,
	----------
	OnDropObject = function(self, hPlayer, hObject)
		if (not hPlayer or not hObject) then
			return
		end

		if (not GetBetaFeatureStatus("objectgrab")) then
			return
		end

		if (hPlayer.iPickedObjectSyncId) then
			self:StopSync(hPlayer, hPlayer.iPickedObjectSyncId)
		end

		hObject:DetachThis()
		--g_utils:AwakeEntity(hObject)
		--local vPos = hPlayer:GetPosInFront(1)
		--vPos.z = vPos.z + 1.5
		--hObject:SetPos(vPos)

		hPlayer.hPickedupObject = nil
		hPlayer.iPickedObjectSyncId = nil

		--ExecuteOnAll("local x=GP("..hPlayer:GetChannel()..")if(x)then x.hGrab=nil if(x.hGrabbedObject_H) then x.hGrabbedObject_H:DetachThis()Msg(0,'off')end x.sGrabbedObjectHash_H=nil x.hGrabbedObject_H=nil end")
		ExecuteOnAll(string.format("g_Client.GrabHandler:ReleaseObject(%d)", hPlayer:GetChannel()))
		Script.SetTimer(100, function()

			if (hObject) then
				--g_utils:AwakeEntity(hObject)
				--hObject:AddImpulse(-1, hObject:GetPos(), hPlayer:GetHeadDir(), hObject:GetMass() * (hPlayer.actor:GetNanoSuitMode() == NANOMODE_STRENGTH and 40 or 25), 1)
			end
		end)

		Debug("Drop ", hObject:GetName())
	end,
	----------
	SyncCharacter = function(self, hPlayer, hTarget)

		local iChar = hPlayer.iCurrentChar

		local aChars = self:GetCharacters()
		local aChar = aChars[iChar]

		self:RequestModel(hPlayer, aChar[2], hTarget, true, true)
		hPlayer.iCurrentChar = iChar
		hPlayer.sCurrentChar = aChar[1]
		hPlayer.aAllowedEquipment = aChar[3]
		return
	end,
	----------
	SyncHead = function(self, hPlayer, hTarget)

		local iHead = hPlayer.iCurrentHead

		local aHeads = self:GetCharacters()
		local aHead = aHeads[iHead]

		self:RequestHead(hPlayer, iHead, hTarget, true, true)
		return
	end,
	----------
	RequestCharacter = function(self, hPlayer, iChar, hOnThis, bQuiet, bCommand)

		--do return false, "sorry, this command is temporarily out of function " end

		local aChars = self:GetCharacters()
		local iChar = tonumber(iChar) or nil
		if (iChar == 0) then
			if (not hPlayer.iCurrentChar) then
				return false, "you are not playing as any special character"
			end

			hPlayer.iCurrentChar = nil
			hPlayer.aAllowedEquipment = nil
			self:RequestModel(hPlayer, 0, nil, true, false)
			SendMsg(CHAT_ATOM, ALL, "(%s: Is Playing as Human again)", hPlayer:GetName())

			Script.SetTimer(1, function()
				g_gameRules:EquipPlayer(hPlayer)
			end)
			return true
		end

		--local aChars = self:GetCharacters()
		if (not aChars[iChar]) then

			ListToConsole(hPlayer, aChars, "Available Characters")
			SendMsg(CHAT_ATOM, hPlayer, "Open Console to View the List of ( %d ) Possible Characters", table.count(nameaCharss))
			return true
		end

		local aChar = aChars[iChar]
		if (hPlayer.iCurrentChar == iChar and not hOnThis) then
			return false, "you are already playing as a " .. aChar[1]
		end

		if (not hOnThis) then
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Use !Human to Play as a Human again)", aChar[1])
			SendMsg(CHAT_ATOM, ALL, "(%s: Selected to Play as a %s)", hPlayer:GetName(), aChar[1])
		end
		self:RequestModel(hPlayer, aChar[2], hOnThis, true, true)

		hPlayer.iCurrentChar = iChar
		hPlayer.sCurrentChar = aChar[1]
		hPlayer.aAllowedEquipment = aChar[3]

	end,
	----------
	RequestHead = function(self, hPlayer, iHead, hOnThis, bQuiet, bCommand)

		--do return false, "sorry, this command is temporarily out of function " end

		local aHeads = self:GetHeads()
		local iHead = (tonumber(iHead) or nil)
		if (iHead == 0) then
			if (not hPlayer.iCurrentHead) then
				return false, "you are not playing with any special head"
			end

			if (hPlayer.hHeadSync) then
				self:StopSync(hPlayer, hPlayer.hHeadSync)
			end

			hPlayer.iCurrentHead = nil
			self:RequestModel(hPlayer, 0, nil, true, false)
			SendMsg(CHAT_ATOM, ALL, "(%s: Is Playing as Human again)", hPlayer:GetName())

			Script.SetTimer(1, function()
				g_gameRules:EquipPlayer(hPlayer)
			end)
			return true
		end

		--local aHeads = self:GetHeads()
		if (not aHeads[iHead]) then

			ListToConsole(hPlayer, aHeads, "Available Heads")
			SendMsg(CHAT_ATOM, hPlayer, "Open Console to View the List of ( %d ) Possible Heads", table.count(aHeads))
			return true
		end

		local aHead = aHeads[iHead]
		if (hPlayer.iCurrentHead == iHead and not hOnThis) then
			return false, "you are already playing with " .. aHead[1] .. "s Head"
		end

		if (not hOnThis) then
			SendMsg(CHAT_ATOM, hPlayer, "(%s: Use !Nomad to Play as a Human again)", aHead[1])
			SendMsg(CHAT_ATOM, ALL, "(%s: Selected to Play with %s's Head)", hPlayer:GetName(), aHead[1])
		end
		self:RequestModel(hPlayer, aHead[2], hOnThis, true, true)

		local sCode = string.format([[g_Client:RequestHead(%d, %d)]], hPlayer:GetChannel(), iHead)
		--if (hPlayer.hHeadSync) then
		--	self:StopSync(hPlayer, hPlayer.hHeadSync)
		--end
		--hPlayer.hHeadSync = self:SetSync(hPlayer, { client = sCode, link = true })
		ExecuteOnAll(sCode)

		hPlayer.iCurrentHead = iHead
		hPlayer.sCurrentHead = aHead[1]

	end,
	----------
	RequestModelOnNPC = function(self, hNPC, iModelId)

		if (hNPC:IsOnVehicle()) then
			return
		end

		if (hNPC.CM == iModelId) then
			return
		end

		local defaultfileModel = "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf"
		local defaultClientFileModel = "objects/characters/human/us/nanosuit/nanosuit_us_fp3p.cdf"
		if (g_gameRules.game:GetTeam(hNPC.id) == 1) then
			defaultfileModel = "objects/characters/human/asian/nanosuit/nanosuit_asian_multiplayer.cdf"
			defaultClientFileModel = "objects/characters/human/asian/nanosuit/nanosuit_asian_fp3p.cdf"
		end

		local aModels = self:GetModels()
		aModels[0][2] = defaultfileModel

		if (not aModels[iModelId]) then
			return
		end

		local sModelName = aModels[iModelId][2]
		if (isArray(sModelName)) then
			sModelName = GetRandom(sModelName)
		end

		local sModelPath = "\"" .. sModelName .. "\""
		if (iModelId == 17) then
			sModelPath = "FEMALE_NANOSUIT_PATH"
		end

		local sCode = [[

			local p = GP(']] .. hNPC:GetName() .. [[');
			if (not p) then return end
			Msg(0,p:GetName())
            p:ResetMaterial(0)
			local loc = p.id == g_localActorId;
			local spth=]] .. sModelPath .. [[
			local mId=]] .. iModelId .. [[
			p.CMPath=spth
			p.CM=mId
			p:SetModel(p.CMPath)
			p.actor:Revive()
			p:Physicalize(0, 4, p.physicsParams)
			p.currModel=']]..defaultfileModel..[['
            p:SetMaterial(GetObjectMaterial(spth))
		]]

		local hOnThis
		if (hOnThis) then
			ExecuteOnPlayer(hOnThis, sCode)
		else
			ExecuteOnAll(sCode)
		end

		hNPC.CustomModel = true
		hNPC.CM = iModelId
		hNPC.modelID = sModelPath
	end,
	----------
	RequestModel = function(self, player, modelId, onthis, bQuiet, bCommand)
		if (player:IsOnVehicle()) then
			return false, "Leave your vehicle!", true;
		end
		local defaultfileModel = "objects/characters/human/us/nanosuit/nanosuit_us_multiplayer.cdf";
		local defaultClientFileModel = "objects/characters/human/us/nanosuit/nanosuit_us_fp3p.cdf";
		if (g_gameRules.game:GetTeam(player.id) == 1) then
			defaultfileModel = "objects/characters/human/asian/nanosuit/nanosuit_asian_multiplayer.cdf";
			defaultClientFileModel = "objects/characters/human/asian/nanosuit/nanosuit_asian_fp3p.cdf";
		end
		--Debug(modelId)
		local names = self:GetModels()
        names[0][2] = defaultfileModel
		if (not names[modelId]) then

			local aList = table.copy(names)
			aList[0] = nil
			ListToConsole(player, aList, "Available Models");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Models", arrSize(names));
			return false, "invalid id"
		end
		
		local modelName = names[modelId][1];
		local modelPath = names[modelId][2];
		local randomModel = false;
		if (type(modelPath) == "table") then
			randomModel = true;
			modelPath = GetRandom(modelPath);
		end;
		
		if ((not randomModel and modelId == player.CM) and not onthis) then
			return false, "You're already playing as "..names[modelId][1];
		end
		
		local n = {"03"};
		local so = "greets_";
		local c=modelId;
		local sf = "";
		if (c==1) then -- or c == 2
			sf="ai_kyong/"; so = "aidowngroup_"; n = {"04", "05",};
		elseif (c==2) then
			--languages/dialog/ai_korean_soldier_3/contactsoloclose_00.mp2
			sf="ai_korean_soldier_3/"; so = "contactsoloclose_"; n = {"01", "02", "03", "04", "05",};
		elseif (c==3) then
			sf="ai_jester/"; n = {"02", "04", "05",};
		elseif (c==4) then
			sf="ai_marine_3/"; n = {"05"};
		elseif (c==5) then
			sf="ai_psycho/"; n = {"01"};
		elseif (c==6) then
			sf="ai_prophet/"; n = {"00", "05"};
		elseif (c==20) then
			--languages/dialog/ai_marine_1/greets_00.mp2
			sf="ai_marine_1/";n = {"01", "02", "03", "04", "05",};
		--elseif (c==11 or c==17) then
			--languages/dialog/village/female_scientist_village_ab2_17596ef3.mp2
		--	sf="village/"; so="female_scientist_village_ab2_"; n={"ab2_17596ef3","ab2_17596ef3"};
		else
		--languages/dialog/ambience/pa_system_ab1_0026.mp2
			--sf = "ambience/"; so = "pa_system_ab1_"; n = { "0026" };
		end
		local path = sf..so..n[math.random(#n)];		
		local fPath = "\"" .. modelPath .. "\"";
		local bPatchMaterial = true

		if (names[modelId][3]) then
			bPatchMaterial = false
		end

		if (modelId == 17) then
			fPath = "FEMALE_NANOSUIT_PATH"
		end

		if (modelId == 17 or modelId == 11) then
			if (player:GetGender(GENDER_MALE)) then
				return false, "reserved model"
			end
		end
		
		local bGod = player:InGodMode()
		local bMegaGod = player.megaGod
		
		if (bGod) then
			player:ToggleGodMode()
			player.actor:SetNanoSuitMode(0)
			Script.SetTimer(250, function()
				if (bGod ~= player:InGodMode()) then
					player:ToggleGodMode(bMegaGod)
				end
			end)
		end
		
		local channel = player:GetChannel()

		local f = [[
			ATOMClient:RequestModel(]] .. channel .. [[, ]] .. modelId .. [[, ]] .. fPath .. [[, "]] .. path .. [[", "]] .. defaultfileModel .. [[", "]] .. defaultClientFileModel .. [[", ]] .. tostring(bQuiet) .. [[, ]] .. tostring(modelId ~= 0) .. [[)
		]]

		if (modelId == 999 and player.iCurrentHead) then
			f = f .. [[g_Client:RequestHead(]] .. channel .. [[, ]] .. player.iCurrentHead .. [[)]]
		end


		local xf = [[

			local p = GP(]]..channel..[[);
			if (not p) then return end
            p:ResetMaterial(0)
			local loc = p.id == g_localActorId;
			local spth=]]..fPath..[[
			local mId=]]..modelId..[[
			p.CMPath=spth
			p.CM=mId
			p:SetModel(p.CMPath)
			if (p.actor:GetHealth()>0)then
				p.actor:Revive()
			end
			if (not loc) then
				p:Physicalize(0, 4, p.physicsParams)
				p.currModel=']]..defaultfileModel..[['
			else
				p:SetActorModel()
				p.currModel=']]..defaultClientFileModel..[['
				
			end
			]] .. ((not bQuiet and modelId>0) and [[ATOMClient:HandleEvent(eCE_Sound, p:GetName(),']]..path..[[');]] or "") .. [[
			local v = p.inventory:GetCurrentItem()
			if (v) then v.item:Select(true)end
			p.CMResetMat=loc or ]]..(modelId==0 and "false"or"true")..[[
			p.CMMaterial=nil
            p:ResetMaterial(0)
            p.CMMaterial=GetObjectMaterial(spth)
            p:SetMaterial(p.CMMaterial)
            p:ReattachItems()
            p:UpdateAttachedItems()
		]];

		--[[
		p:SetMaterial(p.CMMaterial)
			Msg(0,"MATERIAL = %s", p.CMMaterial)

			local t=
			Msg(0,"T  MATERIAL = %s", t:GetMaterial(0))
			System.RemoveEntity(t.id)
			--]]
			--p.CMSuitMode=p.actor:GetNanoSuitMode()
		--g_localActor.actor:ActivateNanoSuit((1 < 7 and 1 or 0));
		--	p.CMRestMat=]]..tostring(bPatchMaterial)..[[
		local name = player:GetName();
		
		if (onthis) then --Prophet
		--	Debug("Ok")
			ExecuteOnPlayer(onthis, f);
		else
			g_utils:OnRevive(player)
            if (not bQuiet) then
                SendMsg(CHAT_ATOM, ALL, "(%s: Selected to play as :: %s)", name, modelName);
                ATOMLog:LogRCA("Player "..name.."$9 selected to play as "..modelName);
            end
            ExecuteOnAll(f);
		end
		
        if (bCommand) then
            player.CommandModel = true
		elseif (bCommand == false) then
			player.CommandModel = nil
        end
		player.CustomModel = true
		player.CM = modelId;
		player.modelID = modelPath;
		player.iCurrentChar = nil
		player.sCurrentChar = nil
		player.aAllowedEquipment = nil
		player.iCurrentHead = nil
		player.sCurrentHead = nil

		player.iForcedTauntID = nil
		if (modelId == 11 or modelId == 17) then
			player.iForcedTauntID = 2000
		end
		
		
		do return end
		
		if (modelId == 0) then
			--Debug("Fuk")
			player.modelID = nil;
			player.CM = 0;
			local f = [[
				local p = g_game:GetPlayerByChannelId(]]..channel..[[);
				if (not p) then return end
				local mId=]]..modelId..[[;
				p:SetModel(']]..defaultfileModel..[[', false, ']]..defaultClientFileModel..[[');
				p.currModel="";
				if (p:IsAlive()) then
					p.actor:Revive();
				end
				if (p.id ~= g_localActorId) then
					p:Physicalize(0, 4, p.physicsParams);
				else
					p:SetActorModel(true);
				end
				local v = p.inventory:GetCurrentItem();
				if (v) then v.item:Select(true);end
				p.CM=0;
				p.CMPath=nil;
			]];
			local modelName = "Nomad";
			g_gameRules.allClients:ClWorkComplete(player.id, "EX:"..RSE:Optimize(f));
			Message.Chat:ToAll("PLAYER "..name.." has selected to play as :: "..modelName);
			self:Log("Player "..name.." has selected to play as "..modelName);
			return true;
		end
		if (g_gameRules.class == "PowerStruggle" and not player:HasAccess(SUPERADMIN)) then
			local teamId = g_gameRules.game:GetTeam(player.id);
			if (modelId < 3 and teamId == 2) then
				return false, "This model is available for NK players only"--, true;
			elseif (modelId > 2 and teamId == 1) then
				return false, "This model is available for US players only"--, true;
			end
		elseif (g_gameRules.class ~= "PowerStruggle") then
			if (modelId == 2) then
				return false, "only in PowerStruggle"
			end
		end
		local n = {"03"};
		local so = "greets_";
		local c=modelId;
		local sf = "";
		if (c==1 or c== 2 or c > 6) then
			sf="ai_kyong/"; so = "aidowngroup_"; n = {"04", "05",};
		elseif (c==3) then
			sf="ai_jester/"; n = {"02", "04", "05",};
		elseif (c==4) then
			sf="ai_marine_3/"; n = {"05"};
		elseif (c==5) then
			sf="ai_psycho/"; n = {"01"};
		elseif (c==6) then
			sf="ai_prophet/"; n = {"00", "05"};
		end
		local path = sf..so..n[math.random(#n)];		
		local fPath = "human/story/"..modelPath;
		if (names[modelId][3]) then
			fPath = names[modelId][3]..modelPath;
		end
		local channel = player:GetChannel()
		local f = [[
			Msg(0, "CALLED")
			local p = g_game:GetPlayerByChannelId(]]..channel..[[);
			if (not p) then return end
			local loc = p.id == g_localActorId;
			local mId=]]..modelId..[[;
			p.CMPath="objects/characters/]]..fPath..[[";
			p:SetModel(p.CMPath);
			p.actor:Revive();
			if (not loc) then
				p:Physicalize(0, 4, p.physicsParams);
				p.currModel=']]..defaultfileModel..[[';
			else
				p:SetActorModel();
				p.currModel=']]..defaultClientFileModel..[[';
				g_localActor.actor:ActivateNanoSuit((mId < 7 and 1 or 0));
			end
			ATOMClient:HandleEvent(eCE_Sound, p:GetName(),']]..path..[[');
			local v = p.inventory:GetCurrentItem();
			if (v) then v.item:Select(true);end
			p.CM=mId;
		]];
		

		--local channel = iTEC5:GetChannel(player);	
		if (onthis) then --Prophet
		--	Debug("Ok")
			ExecuteOnPlayer(onthis, f);
		else
			SendMsg(CHAT_ATOM, ALL, "(%s: Selected to play as :: %s)", name, modelName);
			ATOMLog:LogRCA("Player "..name.."$9 selected to play as "..modelName);
			ExecuteOnAll(f);
		end
		player.CM = modelId;
		player.modelID = modelPath;
		
		return true;
	end,
	----------
	OnError = function(self, player)
		ATOMLog:LogRCA("%s$9 Failed to Install Client", player:GetName());
	end;
	----------
	ExecuteOnPlayer = function(player, code, doQuene)

		----------
		if (not player) then
			return end

		----------
		if (not isArray(player)) then
			return ATOMLog:LogRCA("$4Error: Attempt to Execute Code on Non-Actor Parameter (%s)", type(player)) end

		----------
		if (not player.actor) then
			return ATOMLog:LogRCA("$4Error: Attempt to Execute Code on Non-Actor (%s)", checkVar(player:GetName(), "<N/A>")) end

		----------
		local bQueue = true

		----------
		if (not g_game:GetPlayerByChannelId(player.actor:GetChannel())) then
			return
		end

		----------
		if (player.installStart and _time - player.installStart > 30 and not player.ATOM_Client) then
			return
		end

		----------
		local sCode = (code:sub(1, 4) ~= "EX: " and "EX: " or "") .. RCA:CleanCode(code)

		----------
		if (string.len(sCode) > RCA.cfg.MaximumCode) then
			ATOMLog:LogRCA("$4Warning: $9Code Length above maximum length ($4%d$9)", string.len(sCode));
		end

		----------
		local iChannel = player.actor:GetChannel()
		if (not iChannel or not isNumber(iChannel) or iChannel <= 0 or not g_game:GetPlayerByChannelId(iChannel)) then
			return SysLog("Invalid Channel to ExecuteOnPlayer (%s)", tostring(iChannel))
		end

		----------
		if (RCA:CanCall()) then
			if (player.ATOM_Client) then
				--SysLogVerb(1, "Execute OP %s", sCode)

				RCA.iTotalCalls = RCA.iTotalCalls + 1
				g_gameRules.onClient:ClWorkComplete(iChannel, player.id, sCode)
				RCA:OnExecute({ player }, sCode)
			elseif (bQueue) then
				SysLog("Added code to queue")
				RCA:AddToQuene(1, { player = player, atom = true, code = sCode })
			else
				RPC:OnPlayer(player, "Execute", { code = code })
			end
		else
			RCA:AddToQuene(1, { player = player, atom = bQueue, code = code })
		end
	end;
	----------
	ExecuteOnOthers = function(player, code)
	
		if (not player.actor) then
			return end
			
		if (not g_game:GetPlayerByChannelId(player.actor:GetChannel())) then
			return ExecuteOnAll(code);
		end;
		local clientCode = "EX: " .. RCA:CleanCode(code)

		if (string.len(clientCode) > RCA.cfg.MaximumCode) then
			ATOMLog:LogRCA("$4Warning: $9Code Length above maximum length ($4%d$9)", string.len(clientCode));
		end;
		
		if (true or RCA:CanCall()) then
			--SysLog("Executd OO %s",clientCode)
			RCA:OnExecute(DoGetPlayers({ except = player.id }), clientCode)
			g_gameRules.otherClients:ClWorkComplete(player.actor:GetChannel(), player.id, clientCode)
		--	SysLog("Executed!!")
		else
		--	RCA:AddToQuene(2, { player, clientCode });
		end
	end;
	----------
	ExecuteOnAll = function(code, doQuene)
	
		local clientCode = "EX: " .. RCA:CleanCode(code);
		
		if (string.len(clientCode) > RCA.cfg.MaximumCode) then
			ATOMLog:LogRCA("$4Warning: $9Code Length above maximum length ($4%d$9)", string.len(clientCode))
		end;
		if (string.len(clientCode) > RCA.cfg.KillLimit) then
			ATOMLog:LogRCA("$4Fatal: $9Code Length above kill length ($4%d$9)", string.len(clientCode))
			return
		end
		
		local noClientPlayers = {};
		for i, player in pairs(GetPlayers()) do
			if (not player.ATOM_Client and _time - (player.installStart or 0) > 30) then
				table.insert(noClientPlayers, player);
			end;
		end;
		
		if (arrSize(noClientPlayers) == 1) then
			--SysLog("Found 1 player without client, executiong on others")
			return ExecuteOnOthers(noClientPlayers[1], code, doQuene);
		elseif (arrSize(noClientPlayers) > 1) then
			--SysLog("Found more than 1 player without client, executiong on players")
			for i, player in pairs(GetPlayers()) do
				ExecuteOnPlayer(player, code, doQuene);
			end;
			return;
		end;
		
		if (RCA:CanCall()) then
			if (RCA:AllClientsPatched()) then
				--SysLog("Executd OA >> %s",clientCode)
				RCA:OnExecute(GetPlayers(), clientCode)
				g_gameRules.allClients:ClWorkComplete(NULL_ENTITY, clientCode);
			else
				for i, client in pairs(GetPlayers()or{}) do
					ExecuteOnPlayer(client, clientCode, doQuene);
				end;
			end;
			--SysLog("Executed!!")
		else
			RCA:AddToQuene(3, { player = nil, code = code, atom = doQuene });
		end;
	end;
	----------
	DumpCode = function(self, hPlayer)

		local aCode = RCA.EXECUTED_CODE
		local aMap = RCA.EXECUTED_CODE_MAP
		if (not aCode) then
			return false, "no code executed yet"
		end

		local iCode = table.count(aCode)
		if (iCode == 0) then
			return false, "no code executed yet"
		end

		SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")

		local iCount = 0
		local iTotalLen = 0
		local iExecutedTotal = 0
		for idPlayer, aPlayer in pairs(aCode) do
			local aPlayerMap = aMap[idPlayer]
			iCount = iCount + 1
			local iCodeLen = string.len(table.getall(aPlayer, "sFullCode"))
			local iExecuted = table.count(aPlayerMap)
			iTotalLen = iTotalLen + iCodeLen
			iExecutedTotal = iExecutedTotal + iExecuted
			local sName = checkArray(System.GetEntity(idPlayer), { GetName = function() return string.UNKNOWN end}):GetName()
			local iLast = checkArray(aPlayer[aPlayerMap[table.count(aPlayerMap)]], { iExecutionTime = _time }).iExecutionTime
			SendMsg(CONSOLE, hPlayer, "$9[ $1%s$9 ($1%s$9 | $4%s$9) %s | $3%s$9 ]", string.rspace(iCount .. ".", 4), string.rspace(sName, 25), string.lspace(iExecuted, 6), string.rspace(SimpleCalcTime(_time - iLast, 1) .. " Ago", 25), string.lspace(string.bytesuffix(iCodeLen), 39))
		end
		SendMsg(CONSOLE,     hPlayer, "$9[ $1%s$9 ($1%s$9 | $4%s$9) %s | $3%s$9 ]", string.rspace(iCount + 1 .. ".", 4), string.rspace("Total", 25), string.lspace(iExecutedTotal, 6), string.rspace("-", 25), string.lspace(string.bytesuffix(iTotalLen), 39))
		SendMsg(CONSOLE, hPlayer, "$9==================================================================================================================")

	end,
	----------
	OnExecute = function(self, aPlayers, sCode)

		if (not RCA.EXECUTED_CODE) then
			RCA.EXECUTED_CODE = {}
		end
		if (not RCA.EXECUTED_CODE_MAP) then
			RCA.EXECUTED_CODE_MAP = {}
		end
		if (not RCA.EXECUTED_CODE_COUNT) then
			RCA.EXECUTED_CODE_COUNT = 0
		end

		for i, hPlayer in pairs(aPlayers) do

			if (not RCA.EXECUTED_CODE[hPlayer.id]) then
				RCA.EXECUTED_CODE[hPlayer.id] = {}
			end
			if (not RCA.EXECUTED_CODE_MAP[hPlayer.id]) then
				RCA.EXECUTED_CODE_MAP[hPlayer.id] = {}
			end

			local sCodeShort = string.sub(string.sub(sCode, 5), 1, 43)
			local sHash = simplehash.hash(sCodeShort)

			table.insert(RCA.EXECUTED_CODE_MAP[hPlayer.id], sHash)
			RCA.EXECUTED_CODE_COUNT = (RCA.EXECUTED_CODE_COUNT + 1)
			RCA.EXECUTED_CODE[hPlayer.id][sHash] = {
				iExecutionTime = _time,
				sTraceback = (debug.traceback() or "<failed>"),
				sFullCode = sCode
			}
		end

		if (RCA_LOG == true) then
			local iPlayers = table.count(aPlayers)
			local sPlayers = string.format("%d Players", iPlayers)
			if (iPlayers == 1) then
				sPlayers = string.format("On %s$9", checkFunc(aPlayers[1].GetName, string.ERROR, aPlayers[1]))
			elseif (iPlayers == table.count(GetPlayers())) then
				sPlayers = "On Everyone"
			end

			ATOMLog:LogRCA("($4%s$9) Executed code (%s) %s", string.lspace(RCA.EXECUTED_CODE_COUNT, 5), string.limit(sCode, 43), sPlayers)
		end

	end,
	----------
	OnClientError = function(self, hPlayer, sError)

		local x, iLine, sErrorShort = string.match(sError, '%[ LUA %] %-> !luaerr%[string "(.*)"%]:(.*): (.*)')
		ATOMLog:LogErrorNoDebug("Lua Error on %s$9 (%s)", hPlayer:GetName(), (sErrorShort or "<null>"))
		SysLog("Client LUA Error (%s)", sError)

		local sCode = string.match(sError, '%[string "(.*)"%]')
		if (not sCode) then

			SysLog("Failed to retrieve code from client error message '%s'", sError)
			return
		end

		ATOMLog:LogErrorNoDebug("%s (Line: %s)", sCode, tostring(iLine))
		sCode = string.ridtrail(sCode, "...")

		if (not RCA.EXECUTED_CODE) then
			RCA.EXECUTED_CODE = {}
		end
		if (not RCA.EXECUTED_CODE_MAP) then
			RCA.EXECUTED_CODE_MAP = {}
		end

		local aRecentCodes = RCA.EXECUTED_CODE[hPlayer.id]
		local aRecentCodesMap = checkArray(RCA.EXECUTED_CODE_MAP[hPlayer.id], {})
		if (not aRecentCodes) then

			ATOMLog:LogErrorNoDebug("No traceback was found (%s)", sHash)
			SysLog("Failed to traceback error for Code '%s'", sCode)
			return
		end

		local iLastCodes = table.count(aRecentCodesMap)

		if (iLastCodes >= 1) then
			SysLog("-------------------------------------------------------")
			SysLog("Dumping last 10 calls from %s (Total: %d)", hPlayer:GetName(), iLastCodes)
			for i = 0, 9 do
				local iIndex = (iLastCodes - i)
				local sHashIndex = aRecentCodesMap[iIndex]
				if (iIndex <= 0) then
					break
				end
				if (sHashIndex) then
					local sLastCode = checkArray(aRecentCodes[sHashIndex],{ sFullCode = "<Null>" }).sFullCode
					SysLog("[%02d (%s)] %s", (i + 1), string.lspace(iIndex, 3), (sLastCode or "<Null>"))
				end
			end
		end

		local sHash = simplehash.hash(string.sub(sCode, 1, 43))
		local aRecentCode = aRecentCodes[sHash]
		if (not aRecentCode) then

			ATOMLog:LogErrorNoDebug("No traceback was found (%s)", sHash)
			SysLog("Failed to traceback error for Code '%s'", sCode)
			SysLog("Hash = %s", sHash)
			return
		end

		SysLog("------------------- Traceback found -------------------")
		SysLog("Executed: %s ago", SimpleCalcTime(_time - aRecentCode.iExecutionTime))
		SysLog("Traceback: ")
		for i, sLine in pairs(string.split(aRecentCode.sTraceback, "\n")) do
			SysLog("\t%s", string.gsub(sLine, "^(%s+)", ""))
		end
		SysLog("-------------------------------------------------------")

		ATOMLog:LogErrorNoDebug("Executed %s Ago", SimpleCalcTime(_time - aRecentCode.iExecutionTime))
		for i, sLine in pairs(string.split(aRecentCode.sTraceback, "\n")) do
			ATOMLog:LogErrorNoDebug(string.lspace(i, 2) .. ": " .. (string.gsubex(sLine, { "^(%s+)", "^%.%.%.OM/Game/Scripts/ATOM/", "^Mods/ATOM/Game/Scripts/ATOM/" }, "")))
		end

		return
	end,
	----------
	CleanCode = function(self, sCode)
	
		-----------
		local iOld = string.len(sCode)
		local sNew = string.gsubex(sCode, { "	", "(\t+)", "(\n+)", "\n", "\t" }, " ")
		sNew = string.gsub(sNew, ";(%s+)", ";")
		sNew = string.gsub(sNew, "%)(%s+)then", ")then")
		sNew = string.gsub(sNew, "if(%s+)%(", "if(")
		sNew = string.gsubex(sNew, { "^(%s+)", "^(\t+)", "^(\n+)" }, "")
		sNew = string.gsubex(sNew, { "(%s+)$", "(\t+)$", "(\n+)$" }, "")
		local iNew = string.len(sNew)
		local iDecrease = (((iOld - iNew) / iOld) * 100)
		
		-----------
		-- log 25% decreases!
		if (iDecrease > 25) then
			SysLog("Reduced size of Client Code from %d to %d (%d%% Decrease)", iOld, iNew, iDecrease)
		end
		
		-----------
		return sNew
		
		--[[
		local sub = {
			["(%s+)"] = " ",
			["(\t+)"] = " ",
			["\t"] = " ",
			["\n"] = " "
		};
		for i, gsub in pairs(sub) do
			code = string.gsub(tostring(code), i, gsub);
		end;
		return code;
		--]]
	end;
	----------
	AllClientsPatched = function(self)
		local AP = true;
		for i, player in pairs(GetPlayers()or{}) do
			AP = AP and player.ATOM_Client == true;
		end;
		return AP;
	end;
	----------
	CanCall = function(self)

		if (System.GetFrameID() > self.iCurrentFrame) then
			self.iCurrentFrame = System.GetFrameID()
			self.iTotalCalls = 0
			return true
		end

		local iThreshold = min((g_game:GetPlayerCount() * 20), 30)
		if (self.iTotalCalls > iThreshold) then
			if (timerexpired(self.hTimerLog, 0.1)) then
				self.hTimerLog = timerinit()
				ATOMLog:LogRCA("Too many client calls this frame ( %d (%d))", self.iTotalCalls, self.iCurrentFrame)
			end
			return false
		end

		self.iCurrentFrame = System.GetFrameID()
		return true

		--[[
		self.iFrameCalls = (self.iFrameCalls or 0) + 1
		local iThreshold = min((g_game:GetPlayerCount() * 10), 1)

		SysLog("%d >= %d", self.iFrameCalls, iThreshold)

		if (System.GetFrameID() == self.iCurrentFrame) then
			if (self.iFrameCalls > iThreshold) then
				if (timerexpired(self.hTimerCalls, 1)) then
					self.hTimerCalls = timerinit()
					ATOMLog:LogRCA("Too many client calls on frame ( %d (%f))", self.iFrameCalls, self.iCurrentFrame)
				end
				return false
			else
				self.iFrameCalls = self.iFrameCalls + 1
				return true
			end
		end

		SysLog("Reset to ONE. %d, %d", (System.GetFrameID()), self.iCurrentFrame)
		self.iFrameCalls = 1
		return true
--]]
		--[[
		do return end
		self.callsThisFrame = (self.callsThisFrame or 0)
		if (System.GetFrameTime() == self.thisFrame) then
			if (self.callsThisFrame > (g_game:GetPlayerCount() == 0 and 1 or g_game:GetPlayerCount()) * 10) then
				ATOMLog:LogError("Too many Client Calls on this frame, %d (%f)", self.callsThisFrame, self.thisFrame)
			--	Debug("TOO MANY CALLS ON CURRENT FRAME!!");
				return true;
			else
				self.callsThisFrame = self.callsThisFrame + 1;
				return true;
			end;
		else
			self.callsThisFrame = 1;
			return true;
		end;
		--]]
	end;
	----------
	AddToQuene = function(self, Id, params)
		table.insert(self.quenedCalls, { Id = Id, params = params });
	end;
	----------
	OnWeaponData = function(self, player, a, b, c)
		if (a and b and c) then
			local avg, samples, tempAvg = tonumber(a), tonumber(b), tonumber(c);
			if (avg and samples and tempAvg) then
				ATOMLog:LogRCA("Modified W-Data on Client %s$9 (A:%d, S:%d, T:%d)", player:GetName(), avg, samples, tempAvg);
			end;
		end;
	end;
	----------
	OnModifiedData = function(self, player, a, b, c)
		if (a and b and c) then
			local gravity, flags, mass = tonumber(a), tonumber(b), tonumber(c);
			if (gravity and flags and mass) then
				ATOMLog:LogRCA("Modified Physics on Client %s$9 (G:%d, F:%d, M:%d)", player:GetName(), gravity, flags, mass);
			end
		end
	end;
	----------
	InstallOn = function(self, player, target)
		
		if (not target or target.id == player.id) then
			self:Install(player);
			SendMsg(CHAT_ATOM, player, "(RCA: Installing Client on yourself)");
		elseif (target == "all") then
			for i, client in pairs(GetPlayers()) do
				self:Install(client);
			end;
			SendMsg(CHAT_ATOM, player, "(RCA: Installing Client on all Players)");
		else
			self:Install(target);
			SendMsg(CHAT_ATOM, player, "(RCA: Installing Client on %s)", target:GetName());
		end;
		
		return true;
	end;
	----------
	Install = function(self, player)
		SysLog("RCA:Install(%s)", player:GetName())
		player.installStart = _time;
		player.ATOM_Client = false;
		RPC:OnPlayer(player, "Execute", { url = CLIENT_URL });
		if (AI_ENABLED) then
			RPC:OnPlayer(player, "Execute", { url = CLIENT_URL_AI });
		end;
		SysLog("RCA:Install(%s) Ok", player:GetName())
	end;
	----------
	LogPakStatus = function(self, hPlayer, bInstalled)

		hPlayer.bClientPak = bInstalled
		if (bInstalled) then
			ATOMLog:LogRCA("%s$9 Successfully Installed Client Pak", hPlayer:GetName())
		else
			ATOMLog:LogRCA("%s$9 Did not Install the Client Pak", hPlayer:GetName())
		end
	end;
	----------
	OnInstalled = function(self, player)
		local iTime = (_time - (player.installStart or _time));
		player.ATOM_Client = true;
		ATOMLog:LogRCA("%s$9 Successfully Installed Client (%ss)", player:GetName(), cutNum(iTime, 2));
		SendMsg(player, GetPlayers(MODERATOR, nil, player.id), "(CLIENT: Successfully Installed (%ss))", cutNum(iTime, 2));
		if (ATOMAFK) then
			ATOMAFK:OnClientInstalled(player);
		end;
		ATOMBroadcastEvent("OnClientInstalled", player);
		Script.SetTimer(1000, function()
			self:StartSynch(player);
		end)
	end;
	----------
	SetSync = function(self, object, codeParams, overwrite)
		if (not (codeParams.client or codeParams.server)) then
			return false, ATOMLog:LogError("Attempt to add sync for \"%s\" without code", (object and object:GetName() or "NULL"));
		end;
		self.storedCode = self.storedCode or { [NULL_ENTITY] = {} };
		if (object) then
			self.storedCode[object.id] = (not overwrite and (self.storedCode[object.id] or {}) or {});
			--[[
			table.insert(self.storedCode[object.id], {
				linked = codeParams.link or codeParams.linked;
				client = codeParams.client;
				server = codeParams.server;
			});
			--]]
			self.storedCode[object.id]["sync_" .. arrSize(self.storedCode[object.id]) + 1] = {
				linked = codeParams.link or codeParams.linked;
				links  = codeParams.links;
				client = codeParams.client;
				server = codeParams.server;
			};
			return "sync_" .. arrSize(self.storedCode[object.id]);
		else
			self.storedCode[NULL_ENTITY]["sync_" .. arrSize(self.storedCode[NULL_ENTITY]) + 1] = {
				linked = nil;
				links  = codeParams.links;
				client = codeParams.client;
				server = codeParams.server;
			};
			--[[
			table.insert(self.storedCode[NULL_ENTITY], {
				linked = false;
				client = codeParams.client;
				server = codeParams.server;
			});
			--]]
			return "sync_" .. arrSize(self.storedCode[NULL_ENTITY]);
		end;
	end;
	----------
	StopSync = function(self, ...)
		return self:Unsync(...);
	end;
	----------
	Unsync = function(self, objectId, Index)
		local object_id = type(objectId) == "userdata" and objectId or objectId.id;
		self.storedCode = self.storedCode or {};
		if (Index) then
			self.storedCode[object_id] = self.storedCode[object_id] or {};
			--Debug("INDEX!!",Index)
			--Debug("CURRENT",self.storedCode[object_id][Index])
			self.storedCode[object_id][Index] = nil;
		elseif (self.storedCode[object_id]) then
			self.storedCode[object_id] = nil;
		end;
	end;
	----------
	StartSynch = function(self, hPlayer)

		-------
		local sRemoved = ""
		local sSynced = ""

		local aCfg = self.cfg

		-------
		if (not System.GetEntity(hPlayer.id)) then
			return SysLog("Player left during RCA Synchronisation")
		end

		-------
		SendMsg(CENTER, hPlayer, "Starting Client Data Sync, Please wait ...")

		-------
		local sCode = "";
		for i, hEntity in pairs(System.GetEntities() or {}) do

			-------
			if (hEntity.iCurrentHead) then

				self:SyncHead(hEntity, hPlayer)
			elseif (hEntity.iCurrentChar) then

				self:SyncCharacter(hEntity, hPlayer)
			elseif (hEntity.modelID and hEntity.CM > 0) then

				self:RequestModel(hEntity, hEntity.CM, hPlayer)
			end

			-------
			if (hEntity.hasJetPack) then
				sCode = sCode .. [[JetPack_Attach(']] .. hEntity:GetName() .. [[',]] .. hEntity.JetPack_CounterID .. [[);]]
				if (hEntity.jetPackCloaked) then
					sCode = sCode .. [[JetPack_EnableCloaking(]] .. hEntity.JetPack_CounterID .. [[);]]
				end
			end

			-------
			if (string.len(sCode) > aCfg.MaximumCode) then
				ExecuteOnPlayer(player, sCode);
				sCode = ""
			end

		end

		-------
		sCode = ""

		-------
		local function fGetEntities(aEntities)
			local bOk = true
			for i, hId in pairs(aEntities) do
				bOk = (bOk and (type(hId) == "table" and GetEnt(hId.id) or GetEnt(hId)) ~= nil)
			end
			return bOk
		end

		-------
		local iSynced = 0
		local iDeleted = 0
		local iLimit = 100
		local bAllOk = true

		-------
		for i, v in pairs(self.storedCode) do

			for iv, vv in pairs(v) do

				bAllOk = (vv.links==nil or fGetEntities(vv.links))
				if (bAllOk) then
					bAllOk = (vv.linked == nil or System.GetEntity(i) ~= nil)
				end

				if (bAllOk) then
					if (vv.client) then
						iSynced = iSynced + 1
						sCode = sCode .. " " .. vv.client
						sSynced = sSynced .. string.limit(vv.client, iLimit) .. "\n\t"
						if (string.len(sCode) > aCfg.MaximumCode or string.find(sCode, "return")) then
							ExecuteOnPlayer(hPlayer, sCode)
							sCode = ""
						end
					end

					if (vv.server) then
						local bSuccess, sError = (isString(vv.server) and pcall(pcall(loadstring, vv.server)) or pcall(vv.server, hPlayer))
						if (not bSuccess) then
							ATOMLog:LogError("ServerCode: %s", checkString(sError, "<N/A>"))
						end
					end
				else
					if (vv.client) then
						sRemoved = sRemoved .. string.limit(vv.client, iLimit) .. "\n\t"
					end
					iDeleted = iDeleted + 1
					self.storedCode[i][iv] = nil
				end
			end
		end

		-------
		if (sCode ~= "") then
			ExecuteOnPlayer(hPlayer, sCode)
			sSynced = sSynced .. string.limit(sCode, iLimit) .. "\n\t"
			sCode = ""
		end

		-------
		if (not hPlayer:IsDead() and not hPlayer:IsSpectating() and ATOMPACK_PARTY and not hPlayer.hasJetPack) then
			ATOMPack:Add(hPlayer)
		end

		-------
		self.aForcedCLVars = {
		}

		if (self.aForcedCLVars and not table.empty(self.aForcedCLVars)) then
			local sForced = "{"
			local iForced = 0
			for sName, sValue in pairs(self.forcedClientVars) do
				iForced = iForced + 1
				sForced = sForced .. "{\"" .. sName .."\"," .. sValue .. "}" .. (iForced < table.count(self.aForcedCLVars) and "," or "")
			end

			sForced = sForced .. "}"
			ExecuteOnPlayer(hPlayer, "ATOMClient:HandleEvent(eCE_SetForced," .. sForced .. ");");
		end

		g_gameRules:SetupPlayer(hPlayer)
		ExecuteOnPlayer(hPlayer, "ATOMClient:HandleEvent(8, " .. hPlayer.allCap .. ");")


		-------
		if (NO_CLIP_MODE ~= nil) then
			sCode = sCode .. "NO_CLIP_MODE=" .. NO_CLIP_MODE .. ";"
		end

		if (FLY_MODE) then
			sCode = sCode .. [[ATOMClient:FlyMode(true);]]
		end

		if (ESP_ENABLED) then
			sCode = sCode .. [[ESP_ENABLED=true;]]
		end

		if (sCode ~= "") then
			ExecuteOnPlayer(player, sCode)
			sSynced = sSynced .. string.limit(sCode, iLimit) .. "\n\t"
		end

		-------
		if (string.empty(sRemoved)) then
			sRemoved = "N/A"
		end
		if (string.empty(sSynced)) then
			sSynced = "N/A"
		end
		ATOMLog:LogRCA("%d RCA Synchronization(s) finished on %s (Removed: %d)", iSynced, checkString(hPlayer:GetName() or "<Unknown>"), iDeleted)
		SysLog("------------------------\nSynched: \n\t%s\nRemoved: \n\t%s", sSynced, sRemoved)

		-------
		Script.SetTimer(1000, function()
			SendMsg(CENTER, hPlayer, "Data Synchronized!")
		end)
	end;
	----------
	UpdateQuene = function(self)
		local player, code, need
		for i, quene in pairs(self.quenedCalls or{}) do
			if (quene.Id == 1) then -- On Player
				player = GetEnt(quene.params.player.id)
				if (player) then
					if (player.ATOM_Client) then
						if (self:CanCall()) then
							self.ExecuteOnPlayer(quene.params.player, quene.params.code, false)
							table.remove(self.quenedCalls, i)
						end
					end
				else
					table.remove(self.quenedCalls, i)
				end
			elseif (quene.Id == 2) then -- On Others
			
			elseif (quene.Id == 3) then -- On All
				if (self:CanCall()) then
					self.ExecuteOnAll(quene.params.code)
					table.remove(self.quenedCalls, i)
				end
			end
		end

		self.iCurrentFrame = System.GetFrameID()
	end;
	----------
	InitPlayer = function(self, player)
		if (RCA_ENABLED) then
			self:Install(player);
		else
			ATOMLog:LogRCA("Not installing on %s", player:GetName())
		end
	end;
};
RCA:Init();
--RegisterEvent("InitPlayer", RCA.InitPlayer, RCA);

CLIENT_MOD_RAW = [[

]];