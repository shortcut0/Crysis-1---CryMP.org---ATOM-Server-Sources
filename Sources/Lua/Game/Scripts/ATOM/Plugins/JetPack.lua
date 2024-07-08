ATOMPack = {
	-----------
	Add = function(self, player, unlimited)
	
		if (player:IsSpectating()) then
			return false, "Player is Spectating";
		end;

		if (player.JetPack_CounterID) then
			self:Remove(player);
		end;
		
		player.JetPackPaticles 		= false;
		player.JetPack_CounterID 	= ATOMGameUtils:SpawnCounter();
		player.hasJetPack 			= true
		player.JetPackFuel 			= true;
		player.jetPackCloaked 		= false;
		
		local code = [[JetPack_Attach(GP(]] .. player:GetChannel() .. [[):GetName(),]] .. player.JetPack_CounterID .. [[,]] .. (unlimited and "true" or "false")..[[);]];
		
		if (player.jetPackSyncID) then
			RCA:StopSync(player, player.jetPackSyncID);
		end;
		player.jetPackSyncID = RCA:SetSync(player, { server = [[Debug("ADDED PAC FOR SOME1")]],client = code, link = player.id });
		ExecuteOnAll(code);
	end;
	-----------
	RemoveChairEffects = function(self, player, chair)
		ExecuteOnAll([[
			local c = GetEnt(']] .. chair:GetName() .. [[');
			if (c and c._ES1) then
				c:FreeSlot(c._ES1);
				c:FreeSlot(c._ES2);
				c:FreeSlot(c._ES3);
				c._ES1 = nil;
				c._ES2 = nil;
				c._ES3 = nil;
			end;
		]]);
		if (chair.effectSyncID) then
			Debug("!!!unsync effects");
			RCA:StopSync(chair, chair.effectSyncID);
		end;
		--Debug("REMOVE EFFECTS!!!")
		chair.effectSyncID = nil;
	end;
	-----------
	RemoveFlyingChair = function(self, player, chair)

		local chair = chair or GetEnt(player.chair);
		if (not chair) then
			return false--, Debug("no chair");
		end;

		if (player.sitting) then
		
			player.sitting = false;
			player.chair = nil;
			chair.player = nil;
		
			REMOVE_OBJECTS[chair.id] = { _time, 60 * 3, "player" };
		
			local toLoadString = [[
				local a, b = GetEnt(']]..player:GetName()..[['),GetEnt(']]..chair:GetName()..[[');
				if (a) then
					LOOPED_ANIMS[a.id] = nil
					Script.SetTimer(1, function()
						a:StopAnimation(0,8)
					end);
					a.chairEntity=nil;
					a.flyChairMode=nil;
				end;
				if (b) then
					b:Physicalize(0, PE_RIGID, {mass=100});
					b:AwakePhysics(1);
					FLYING_CHAIRS[b.id] = nil
				end;
			]];
			chair:Physicalize(0, PE_RIGID, {mass=100});
			chair:AwakePhysics(1);
			chair:SetWorldPos(player:GetPos());
			
			self:RemoveChairEffects(player, chair)
			ExecuteOnAll(toLoadString);
			--Debug("CHAIR OFF!!");
		
			if (chair.mainSyncID) then
				--Debug("!!STOP MAIN!!");
				RCA:StopSync(chair, chair.mainSyncID);
				chair.mainSyncID = nil;
			end;
		end;
	end;
	-----------
	AddFlyingChair = function(self, player, chair)
		if (not player:IsSpectating() and not player:IsDead() and not player:IsAFK()) then
			--Debug(player.sitting)
			if (not player.sitting or not GetEnt(player.chair)) then
				player.sitting = true;
				player.chair = chair.id;
				chair.player = player.id;
				
				REMOVE_OBJECTS[chair.id] = nil;
			
				local toLoadString = [[
					local a, b = GetEnt(']]..player:GetName()..[['),GetEnt(']]..chair:GetName()..[[');
					if (not a or not b) then
				
					end;
					b:DestroyPhysics();
					local c="relaxed_sit_nw_01";
					local t=a:GetAnimationLength(0, tostring(c)) or 1.3
					LOOPED_ANIMS[a.id] = {
						Entity 	= a,
						Start	= _time-t,
						Loop 	= -1,
						Timer 	= t,
						Speed 	= 1,
						Anim 	= c
					};
					a.chairEntity=b.id
					FLYING_CHAIRS[b.id] = { playerMinusz = 0.5, player = b, target = a, targetBone = "Bip01 Pelvis" };
					a.hasFlyingChair=0
					b.ATB=true;
					if (a.id==g_localActor.id) then 
						HUD.DisplayBigOverlayFlashMessage("Press [F] to leave the Seat, when in air, hold [F] to start flying", 10, 190, 320, {1,0,0});
					end;
					a.pickable = 0
					a.Properties=a.Properties or{}
					a.Properties.pickable = 0
				]];
				ExecuteOnAll(toLoadString);
				if (chair.mainSyncID) then
					--Debug("unsync main ")
					RCA:StopSync(chair, chair.mainSyncID);
				end;
				chair.mainSyncID = RCA:SetSync(chair, { link = chair, client = toLoadString });
				chair:SetWorldPos(player:GetPos());
			end;
		end;
	end;
	-----------
	AddRocket = function(self, player)
	
		if (player:IsSpectating()) then
			return false, "Player is Spectating";
		end;
		
		if (player.Rocket_CounterID) then
			self:RemoveRocket(player);
		end;

		player.RocketPaticles 		= false;
		player.Rocket_CounterID 	= ATOMGameUtils:SpawnCounter();
		player.hasATOMRocket 		= true
		player.RocketCloaked 		= false;
		
		ExecuteOnAll([[ATOMRocket_Attach(']] .. player:GetName() .. [[',]] .. player.Rocket_CounterID .. [[);]]);
	end;
	-----------
	Cloak = function(self, player)
	
	end;
	-----------
	Uncloak = function(self, player)
	
	end;
	-----------
	Remove = function(self, player)
		if (player.JetPack_CounterID) then
			ExecuteOnAll([[JetPack_Detach(']] .. player:GetName() .. [[', ]] .. player.JetPack_CounterID .. [[);]]);
		end;
		
		if (player.jetPackSyncID) then
			RCA:StopSync(player, player.jetPackSyncID);
		end;
		
		player.JetPack_CounterID = nil;
		player.hasJetPack = false;
	end;
	-----------
	RemoveRocket = function(self, player)
		if (player.Rocket_CounterID) then
			ExecuteOnAll([[ATOMRocket_Detach(']] .. player:GetName() .. [[', ]] .. player.Rocket_CounterID .. [[);]]);
		end;
		player.Rocket_CounterID = nil;
		player.hasATOMRocket = false;
	end;
	-----------
	AddEffects = function(self, player)
		if (player.JetPackFuel) then
			ExecuteOnAll([[JetPack_AddParticles(]] .. player.JetPack_CounterID .. [[);]]);
			ExecuteOnPlayer(player, "JET_PACK_THRUSTERS = true;")--g_localActor:PlaySoundEvent('suit/male/suit_activating_hydrothrusters', g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)");
			ExecuteOnPlayer(player, [[
				local vm = tonumber(System.GetCVar("hud_voicemode"));
				local typ = vm == 1 and "male" or vm == 2 and "female" or "";
				if (typ~="" and timerexpired(g_localActor.lHydro, 5)) then
					g_localActor:PlaySoundEvent("suit/"..typ.."/suit_activating_hydrothrusters",g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
					g_localActor.lHydro = timerinit()
				end
			]])
			player.JetPackPaticles = true;
		else
			SinepUtils:SpawnEffect("explosions.wall_explosion.wall_break",player:GetPos())
		end;
	end;
	-----------
	RemoveEffects = function(self, player)
		ExecuteOnAll([[JetPack_RemoveParticles(]] .. player.JetPack_CounterID .. [[);]]);
		player.JetPackPaticles = false;
		player.JetPackSuperSpeedPaticles = false;
	end;
	-----------
	AddRocketEffects = function(self, player)
		ExecuteOnAll([[ATOMRocket_AddParticles(]] .. player.Rocket_CounterID .. [[);]]);
		ExecuteOnPlayer(player, "ROCKET_THRUSTERS = true;");
		player.RocketPaticles = true;
	end;
	-----------
	RemoveRocketEffects = function(self, player)
		ExecuteOnAll([[ATOMRocket_RemoveParticles(]] .. player.Rocket_CounterID .. [[);]]);
		player.RocketPaticles = false;
	end;
	-----------
	AddSuperEffects = function(self, player)
		ExecuteOnAll([[JetPack_AddSuperSpeedParticles(]] .. player.JetPack_CounterID .. [[);]]);
		player.JetPackSuperSpeedPaticles = true;
	end;

};