ATOMMisc = {
	Init = function(self)

		for i, v in pairs(self) do
			if (type(v) == "table") then
				if (v.Init) then
					v:Init()
				end
			end
		end

	end;
	-----------------
	OnHit = function(self, ...)
		for i, v in pairs(self) do
			if (type(v) == "table") then
				if (v.OnHit) then
					v:OnHit(...)
				end
			end
		end
	end;
	-----------------
	OnTick = function(self, ...)
		for i, v in pairs(self) do
			if (type(v) == "table") then
				if (v.OnTick) then
					v:OnTick(...)
				end
			end
		end
	end;
	-----------------
	ScriptedExplosives = {
		cfg = {
			enabled = true;
		};
		-----------------
		Init = function(self)
		--	AddHook("OnItemHit", self.OnHit, self);
		--	AddHook("OnHalfSecTick", self.OnTick, self);
		end;
		-----------------
		OnHit = function(self, ...)
			self.BombRack:OnHit(...);
			self.GasStation:OnHit(...);
		end;
		-----------------
		OnTick = function(self, ...)
			self.BombRack:OnTick(...);
		end;
		-----------------
		BombRack = {
			cfg = {
				enabled = true;
			};
			-----------------
			racks = (ATOMisc~=nil and ATOMisc.ScriptedExplosives~=nil and ATOMisc.ScriptedExplosives.BombRack~=nil) and ATOMisc.ScriptedExplosives.BombRack.racks or {};
			-----------------
			SpawnRack = function(self, player, amount)
				local x1, y1 = 0, 0;
				local x2, y2 = 0, 0
				local times = makeEvent(round(newmath:SetMaxMin(amount, 30, 1))/2);
				
				local spawnPosO = player:CalcSpawnPos(player, 3, 0);
				
				local hd = player.actor:GetHeadDir()

				local spawnPos, groundPos;

				local xtimes = times
				local ytimes = times

				local cname = "Rack:"..arrSize(self.racks)+1

				self.racks[cname] = {bombs={}}

				for i = 1, xtimes do
					--if (hd.x>0) then
					--	x2 = x2 + 2;
					--else
					--	x2 = x2 - 2;
					--end;
					
					x2.x = x2.x + hd.x * 2;
					
					y2 = y1;
					for j = 1, ytimes do
						--if (hd.x>0) then
						--	y2 = y2 + 2;
						--else
						--	y2 = y2 - 2;
						--end;
						x2.y = x2.y + hd.y * 2;
						spawnPos = { x = spawnPosO.x + x2, y =  spawnPosO.y + y2, z = spawnPosO.z };
						groundPos = System.GetTerrainElevation(spawnPos)
						
						--	Debug("BOT FICKxed >> " .. spawnPos.z)
						if (groundPos - spawnPos.z >0.1 and groundPos-spawnPos<3) then
							spawnPos.z = groundPos+2.5;
						elseif (groundPos - spawnPos.z <-0.1 and groundPos-spawnPos.z>-3) then
							spawnPos.z = groundPos+2.5;
						--	Debug("FICKxed >> " .. spawnPos.z)
						end;
						local bombe = SinepUtils:SpawnGUI("Objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf", spawnPos, 1000);
						bombe.isBomb = true;
						table.insert(self.racks[cname].bombs, bombe);
						bombe.hookedHit = function(self, hit)
							ATOMMisc.ScriptedExplosives.BombRack:OnItemHit(hit, self);
						end;
					end;
				end;
			end;
			-----------------
			OnHit = function(self, item, hit)
				if (not item.FLY and item.isBomb) then
					item.FLY = true;
								
					--:LoadParticleEffect(-1,"misc.sparks.damaged_scout",{bActive=1,bPrime=1,Scale=1,SpeedScale=1,CountScale=1,bCountPerUnit=0,AttachType="Render",AttachForm="Surface",PulsePeriod=0})
					local code = [[
						local bombe = GetEnt(']]..item:GetName()..[[');
						local p=bombe:GetPos()
						bombe.effectSlot = bombe:LoadParticleEffect(-1, "explosions.jet_explosion.burning",{Scale=0.2,CountScale=3}); 
						bombe:SetSlotWorldTM(bombe.effectSlot, {x=p.x,y=p.y,z=p.z-2.3},g_Vectors.down)
					]]
					ExecuteOnAll(code);
					RCA:SetSync(item, { link = true, client = code})		
					item.wasHit = _time;
				end;
			end;
			-----------------
			OnTick = function(self)
				for i, rack in pairs(self.racks) do
					if (rack.bombs) then
						for j, bombe in pairs(rack.bombs) do
							if ( System.GetEntity(bombe.id)) then
								if (bombe.wasHit) then
									if (_time - bombe.wasHit >= 3.5) then
										
										local bombePos = bombe:GetPos();
										System.RemoveEntity(bombe.id);
										g_gameRules:CreateExplosion(bombe.id, bombe.id, 1000, bombePos, g_Vectors.up, 20, 45, 20, 20, "explosions.C4_explosion.ship_door", 1, 1, 1, 1);
												
									
									elseif (_time - bombe.wasHit >= 1) then
										--if (not bomb.flying) then
											--Script.SetTimer(1000, function()
												local dir = bombe:GetDirectionVector();
															
												local imp = 15000;
												if (dir.z>0.4 or dir.z<0.4) then
												imp = imp * 5;
												end;
															
												local x = dir.x
												dir.x = dir.z
												dir.z = x
																
												bombe:AddImpulse(-1, bombe:GetCenterOfMassPos(), dir, imp, 1);
												
											--end);
										--end;
									end;
								end;
							else
								table.remove(self.racks[i].bombs, j);
							end;
						end;
					else
						self.racks[i] = nil;
					end;
				end;
			end;
			-----------------
			KillBomb = function(self, bomb)
				self.racks[bomb.id] = nil;
				g_gameRules:CreateExplosion(bomb.id, bomb.id, 1000, bomb:GetPos(), g_Vectors.up, 20, 45, 20, 20, "explosions.CIV_explosion.a", 1, 1, 1, 1);
			end;
			-----------------
			HitBomb = function(self, item)
				if (not self.racks[item.id].hit) then
					self.racks[item.id].hit = true;
					self.racks[item.id].hitTime = _time + math.random(-3,3);
					
					local dir = GetDir(item:GetPos(), item.helper:GetPos())
							dir=vecScale(dir,-1)
					
							
					item:AddImpulse(-1, item:GetCenterOfMassPos(), dir, 1, 1);
					--SinepUtils:SpawnEffect("explosions.flare.night_time", item:GetPos(), 0.1, dir)
					
					local code=[[
						local bombe = GetEnt(']]..item:GetName()..[[');
						local p=bombe:GetPos()
						bombe.effectSlot = bombe:LoadParticleEffect(-1, "explosions.jet_explosion.burning",{Scale=0.2,CountScale=3}); 
						System.LogAlways("Slot: " .. tostring(bombe.effectSlot))
						bombe:SetSlotWorldTM(bombe.effectSlot, {x=p.x,y=p.y,z=p.z},g_Vectors.down)
					]];
					ExecuteOnAll(code);
					RCA:SetSync(item, { link = true, client = code})	
				end;
			end;			
		};
		-----------------
		GasStation = {
			cfg = {
				enabled = true;
			};
			-----------------
			stations = (ATOMMisc~=nil and ATOMMisc.ScriptedExplosives~=nil and ATOMMisc.ScriptedExplosives.GasStation~=nil) and ATOMMisc.ScriptedExplosives.GasStation.stations or {};
			-----------------
			SpawnStation = function(self, player)
				local pos = (player.x and copyTable(player) or GetGroundPos(player:CalcSpawnPos(player, 20, 0)));
				
				local pos1, pos2, pos3, pos4 = add2vec(copyTable(pos), { x = 7.1104, y = -12.2198, z = 0.267 }), add2vec(copyTable(pos), { x = 10, y = -12.2198, z = 0.267 }), add2vec(copyTable(pos), { x = 11.605, y = -12.2198, z = 0.267 }), add2vec(copyTable(pos), { x = 14.7998, y = -12.2198, z = 0.267 });
				
				
				--SinepUtils:SpawnGUI(modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect)
				local GS_Main  = SpawnGUI("objects/library/architecture/village/gasstation_new.cgf", pos, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true, 500, nil, true);
				
				local GS_Pump1 = SpawnGUI("objects/library/props/gasstation/pumping_station.cgf",    pos1, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true, 500, nil, false);
				local GS_Pump2 = SpawnGUI("objects/library/props/gasstation/pumping_station.cgf",    pos2, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true, 500, nil, false);
				local GS_Pump3 = SpawnGUI("objects/library/props/gasstation/pumping_station.cgf",    pos3, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true, 500, nil, false);
				local GS_Pump4 = SpawnGUI("objects/library/props/gasstation/pumping_station.cgf",    pos4, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true, 500, nil, false);
				
				self.stations["Station:"..arrSize(self.stations)] = {
					GS_Main = GS_Main;
					positions = {
						[1] = pos,
						[2] = pos1,
						[3] = pos2,
						[4] = pos3,
						[5] = pos4
					};
					pumps = {
						[1] = GS_Pump1,
						[2] = GS_Pump2,
						[3] = GS_Pump3,
						[4] = GS_Pump4
					};
					spawnPos = pos;
				};
			end;
			-----------------
			InitHooks = function(self)
			--	AddHook("OnItemHit", self.OnHit, self);
			end;
			-----------------
			OnHit = function(self, item, hit)
				--Debug(item.pump)
				--if (item:GetName()) then
				--Debug(item:GetName())
					local station = self:IsPump(item);
					
					if (station) then
						self:OnPumpHit(station, item, hit);
					end;
				--end;
				if (item.hookedHit) then
					pcall(item.hookedHit, item, hit);
				end;
			end;
			-----------------
			OnPumpHit = function(self, station, pump, hit)
				pump.hp = (pump.hp or 50) - hit.damage;
				if (pump.hp < 0 and pump.id ~= station.GS_Main.id) then
					self:KillPump(station, pump);
				end;
			end;
			-----------------
			KillPump = function(self, station, pump)
				if (not pump.died) then
					self:PumpExplosion(station, pump);
				end;
				pump.died = true;
			end;
			-----------------
			PumpExplosion = function(self, station, pump)
				g_gameRules:CreateExplosion(pump.id, pump.id, 1000, pump:GetPos(), g_Vectors.up, 20, 45, 20, 20, "explosions.small_fuel_tank.tank", 1, 1, 1, 1);
				Script.SetTimer(100, function()
					self:ProcessExplosion(station, pump);
				end);
			end;
			-----------------
			ProcessExplosion = function(self, station, pump)
				Script.SetTimer(3000, function()
					g_gameRules:CreateExplosion(pump.id, pump.id, 1000, pump:GetPos(), g_Vectors.up, 20, 45, 20, 20, "explosions.CIV_explosion.a", 1, 1, 1, 1);
					local pos = pump:GetPos();
					if (not station.ultraExplosionTriggered) then
						--Script.SetTimer(4500, function()
						--	Debug("Very final")
						--	g_gameRules:CreateExplosion(station.GS_Main.id, station.GS_Main.id, 1000, pos, g_Vectors.up, 20, 45, 20, 20, "explosions.C4_explosion.ship_door", 8, 1, 1, 1);
						--end);
					end;
					station.ultraExplosionTriggered = true;
					Script.SetTimer(10, function()
						System.RemoveEntity(pump.id);
					end);
					if (not station.mainExplosionTriggered) then
					
						--self:KillPump(station, station.pumps[2]);
						
						Script.SetTimer(100, function()
							self:KillPump(station, station.pumps[2]);
						end);
						Script.SetTimer(150, function()
							self:KillPump(station, station.pumps[3]);
						end);
						Script.SetTimer(200, function()
							self:KillPump(station, station.pumps[4]); 
							self:MainExplosion(station);
						end);
						
					end;
					station.mainExplosionTriggered=true
				end);
			end;
			-----------------
			SpawnBrokenObjects = function(self, station)
				System.RemoveEntity(station.GS_Main.id);
				local pos = station.spawnPos;
				local GS_DES1  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_04.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES2  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_08.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES3  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed.cgf",          pos, -1, 1, { x = 0, y = 0.5, z = 0 }, true, true);
				local GS_DES4  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_05.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES5  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_01.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES6  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_02.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES7  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_06.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES8  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_03.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES9  = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_10.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES10 = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_09.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
				local GS_DES11 = SpawnGUI("objects/library/architecture/village/gasstation_new_destroyed_piece_07.cgf", pos, 100, 1, { x = 0, y = 0.5, z = 0 });
			end;
			-----------------
			MainExplosion = function(self, station)
			
				local GS_Main = station.GS_Main;
				local positions = station.positions
				
				local pos, pos1, pos2, pos3, pos4 = positions[1], positions[2], positions[3], positions[4], positions[5];
			
			
				ExecuteOnAll([[
					GetEnt(']]..GS_Main:GetName()..[['):PlaySoundEvent("sounds/physics:explosions:huge_explosion",g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT)
				]])
				
				self:SpawnBrokenObjects(station);
				
				local e={
					"explosions.carrier_island.explosion",
					"explosions.carrier_island.bigflames",
					"explosions.carrier_island.singleflame",
					"explosions.carrier_island.animated_explosion"
				};
				g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos1,g_Vectors.up,20,45,20,20,e[math.random(#e)],2, 1, 1, 1);
				g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos2,g_Vectors.up,20,45,20,20,e[math.random(#e)],2, 1, 1, 1);
				g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos3,g_Vectors.up,20,45,20,20,e[math.random(#e)],2, 1, 1, 1);
				g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos4,g_Vectors.up,20,45,20,20,e[math.random(#e)],2, 1, 1, 1);

				Script.SetTimer(500, function()
					g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos2,g_Vectors.up,20,45,20,20,"explosions.harbor_airstirke.airstrike_medium",1, 21, 21, 21);
					for i, pos in ipairs(station.positions) do
						Script.SetTimer( i * 50, function()
							g_gameRules:CreateExplosion(GS_Main.id, GS_Main.id, 1000, pos, g_Vectors.up, 20, 45, 20, 20, "explosions.CIV_explosion.a", 2, 21, 21, 21);
						end);
					end;
				end);
				Script.SetTimer(800, function()
					g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos2,g_Vectors.up,20,45,20,20,"explosions.harbor_airstirke.plane_crash",2, 15, 15, 15);
					ExecuteOnAll([[
					GetEnt(']]..GS_Main:GetName()..[['):PlaySoundEvent("sounds/physics:explosions:harbor_airstrike_explosion_2",g_Vectors.v000,g_Vectors.v010,SOUND_EVENT,SOUND_SEMANTIC_SOUNDSPOT)
					]])
					Script.SetTimer(100, function()
						g_gameRules:CreateExplosion(GS_Main.id,GS_Main.id,1000,pos2,g_Vectors.up,20,45,20,20,"explosions.mine_explosion.alien_ship_open",2.5, 21, 21, 21);
					end);
				end);
			end;
			-----------------
			IsPump = function(self, item)
			--Debug(item)
			--			SinepUtils:SpawnEffect(EFFECT_FLARE,item:GetPos())
				for i, station in pairs(self.stations or{}) do
					--Debug("pupms: "..tostring(station.pumps))
					for j, pump in pairs(station.pumps or{}) do
					--	Debug(pump.id==item.id)
						
						--SinepUtils:SpawnEffect(EFFECT_FLARE,pump:GetPos())
						if (pump.id == item.id) then
							return station;
						end;
					end;
				end;
			end;
			-----------------
			
			-----------------
			
			-----------------
		};
	};
};
ATOMMisc:Init();