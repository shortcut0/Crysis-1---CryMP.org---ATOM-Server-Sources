do return end

ExecuteOnAll([[



		Remote.OnUpdate = function()

			for i,hPlayer in pairs(System.GetEntitiesByClass("Player")or{}) do

				local hGrabbed = hPlayer.hGrabbedObject
				if (hGrabbed) then

					Msg(0, "kk")
					local bIsLocalActor = hPlayer.id == g_localActorId
					local bFP = g_localActor.actorStats.thirdPerson ~= true
					local bIgnore = false

					local vPos = hPlayer:GetPosInFront(1,nil,"Bip01 Pelvis")or hPlayer:GetBonePos("Bip01 R Hand")
					if (bIsLocalActor) then

						if (bFP) then
							bIgnore = true
						end
						hGrabbed:SetColliderMode(2)
					else
						hPlayer:SetColliderMode(2)
					end

					if (not bIgnore) then
						if (not hGrabbed.bIsAttached) then
							hGrabbed.bIsAttached = true

							if (not bIsLocalActor) then
								hGrabbed:PhysicalizeSlot(0, { flags = 1.8537e+008 })
								hPlayer:AttachChild(hGrabbed.id, PHYSICPARAM_SIMULATION)
								hGrabbed:EnablePhysics(true)
							else
								hGrabbed:PhysicalizeSlot(0, { flags = 1.8537e+008 })
								hPlayer:AttachChild(hGrabbed.id, PHYSICPARAM_SIMULATION)
							end
							hPlayer.idAttachedObject = hGrabbed.id
							hPlayer.AttachedObject = hGrabbed
						end
						vPos.z = vPos.z - 0.5
						hGrabbed:SetPos(vPos)
					end


				elseif (hPlayer.AttachedObject) then
					if (System.GetEntity(hPlayer.idAttachedObject)) then
						hPlayer.AttachedObject:DetachThis()
					end
					hPlayer.AttachedObject:SetColliderMode(0)
					if (hPlayer.id == g_localActorId) then
						g_localActor:SetColliderMode(0)
					end
				end
			end
		end

		]])




		do return end
		ExecuteOnAll([[Remote.FORCED_CLIENT_ANIMATION=nil
		]])
		ExecuteOnAll([[Remote.FORCED_CLIENT_ANIMATION="]]..x..[["]])

		do return end
		ExecuteOnAll([[g_localActor:MultiplyWithSlotTM(0,{x=]]..x..[[,y=]]..y..[[,z=]]..z..[[})]])



		do return end
		ExecuteOnAll([[
		ATOMClient.AnimationHandler:StartAnimation(g_localActor, {

			AnimName = "usCarrier_watchTowerLookOut_binoculars_01",
			Stance = STANCE_STAND,
			CharacterOffset = nil,
			MaxSpeed = 0,
			MinSpeed = -1,
			InAir = 0,
			OnGround = 1,
			InWater = 0,
			bNoSwimming = 1,
			Condition = function(hPlayer)
				local hItem = hPlayer.inventory:GetCurrentItem()
				if (hItem and hItem.class == "Binoculars") then
					return true
				end
				return false
			end,
		})

		]])





		do return end

		ExecuteOnAll([[
		Remote.OnUpdate = function()
		end]])

		do return end

		ExecuteOnAll([[
		Remote.OnUpdate = function()
			for i, hPlayer in pairs(System.GetEntitiesByClass("Player") or {}) do

				if (not hPlayer.id == g_localActorId or g_localActor.actorStats.thirdPerson == true) then
					local vHead = hPlayer:GetBonePos("Bip01 Head")
					vHead.z = vHead.z + 0.15
					System.DrawLabel( vHead, 1, "(HEAD)", 1, 1, 1, 1 )
					vHead.z = vHead.z + 0.15
					System.DrawLabel( vHead, 1, string.format("%s (%0.2fm)", hPlayer:GetName(), vector.distance(System.GetViewCameraPos(), vHead)), 1, 1, 1, 1 )
					System.DrawLabel( hPlayer:GetBonePos("Bip01 Pelvis"), 1, "(Pelvis)", 1, 1, 1, 1 )
					System.DrawLabel( hPlayer:GetBonePos("Bip01 L Hand"), 1, "(Left Hand)", 1, 1, 1, 1 )
					System.DrawLabel( hPlayer:GetBonePos("Bip01 R Hand"), 1, "(Right Hand)", 1, 1, 1, 1 )
					System.DrawLabel( hPlayer:GetBonePos("Bip01 L Foot"), 1, "(Left Food)", 1, 1, 1, 1 )
					System.DrawLabel( hPlayer:GetBonePos("Bip01 R Foot"), 1, "(Right Food)", 1, 1, 1, 1 )
				end
			end
		end
		]])


		do return end


		ExecuteOnAll("lalallala.hGrabAttachEntity:SetLocalPos({ x = "..y..", y="..z..", z="..zz.." })")

		do return end

		local t = GetPlayer(x)
		ExecuteOnAll("GP("..t:GetChannel()..").hGrabAttachEntity:SetLocalPos({ x = "..y..", y="..z..", z="..zz.." })")


		do return end
		ExecuteOnAll([[

		Remote.OnUpdate = function()
			for idPig, aData in pairs(PIGGY_RIDERS) do
				local bRemove = true
				local hPig = System.GetEntity(idPig)
				local hRider = aData.Rider

				if (hPig and hRider and System.GetEntity(hRider.id)) then

					local vPigHead = hPig:GetBonePos("Bip01 Head")
					local vPigHeadDir = hPig.actor:GetHeadDir()

					vPigHead.z = vPigHead.z - 0.2
					vPigHead.x = vPigHead.x - (vPigHeadDir.x * 0.3)
					vPigHead.y = vPigHead.y - (vPigHeadDir.y * 0.3)
					local vRider = hRider:GetPos()

					hRider:SetPos(vPigHead)

					local vPigAngles = hPig:GetAngles()
					local vRiderAngles = hRider:GetAngles()

					if (hRider.id == g_localActorId) then
						if (vRiderAngles.z < (vPigAngles.z - 0.5)) then
							hRider:SetAngles({
								x = vRiderAngles.x,
								y = vRiderAngles.y,
								z = vRiderAngles.z + 0.01
							})
						elseif (vRiderAngles.z > (vPigAngles.z + 0.5)) then
							hRider:SetAngles({
								x = vRiderAngles.x,
								y = vRiderAngles.y,
								z = vRiderAngles.z - 0.01
							})
						end
					else
						hRider:SetDirectionVector(vPigHeadDir)
					end

					bRemove = false
				end

				if (bRemove) then
					Msg(0, "deleted")
					PIGGY_RIDERS[idPig] = nil
				end
			end
		end

		]])

		local t = GetPlayer(x)

		if (player.bPiggyRiding) then

			player.bPiggyRiding = false
			player.hPiggy = nil
			ExecuteOnAll([[
				local hPig, hRider = GP(]] .. t:GetChannel() .. [[), GP(]] .. player:GetChannel() .. [[)
				if (hPig) then
					PIGGY_RIDERS[hPig.id] = nil
				end

				if (hRider) then
					LOOPED_ANIMS[hRider.id] = nil
					hRider:SetColliderMode(0)
				end
			]])
		else

			player.bPiggyRiding = true
			player.hPiggy = t
			ExecuteOnAll([[
				local hPig, hRider = GP(]] .. t:GetChannel() .. [[), GP(]] .. player:GetChannel() .. [[)
				if (not hPig or not hRider) then
					return
				end

				PIGGY_RIDERS[hPig.id] = {
					Rider = hRider
				}

				hRider:SetColliderMode(2)
				LOOPED_ANIMS[hRider.id] =
				{
					KeepAnimation = 1,
					Start 	= _time - 99,
					Entity 	= hRider,
					Loop 	= -1,
					Timer 	= 0,
					Speed 	= 1,
					Anim 	= "relaxed_sit_nw_01",
					NoSpec	= true,
					Alive	= true,
					NoWater	= true
				}
			]])
		end


		do return end

		ExecuteOnAll([[
		ATOMClient.GrabHandler.Update = function(self)

				if (not self.cfg.bStatus == true) then
					return
				end

				local bLocalPos = false
				local bIsLocal = false
				local bGrabberLocal = false

				local bSelectFists = false
				local hCurrentItem = nil

				local hGrabber

				local aPlayers = System.GetEntitiesByClass("Player") or {}
				for i, hPlayer in pairs(aPlayers) do
					if (hPlayer.bGrabbed and hPlayer.hGrabber) then

						bLocalPos = false
						hGrabber = hPlayer.hGrabber
						bSelectFists = false
						bIsLocal = (hPlayer.id == g_localActorId)
						bGrabberLocal = (hGrabber.id == g_localActorId)

						if (not self:CheckAnimations(hPlayer, hGrabber)) then
							self:StartAnimations(hGrabber, hPlayer)
						end

						if (timerexpired(hPlayer.hTimerColliderMode, 1) and bGrabberLocal) then
							hPlayer.hTimerColliderMode = true
							hPlayer:SetColliderMode(2)
						end

						if (bIsLocal) then
							if (hPlayer.iGrabTime) then
								HUD.SetProgressBar(true, (100 - ((_time - hPlayer.iGrabTime) / 0.6)), "Suffocating")
								if (_time - hPlayer.iGrabTime >= 60) then
									HUD.SetProgressBar(false, 0, "")
									hPlayer.iGrabTime = nil
								end
							end
							self:CheckItem(hPlayer)
						elseif (bGrabberLocal) then
							self:CheckItem(g_localActor)
						end

						local vGrabberHand = hGrabber:GetBonePos("Bip01 L Hand")
						local vGrabAttach = vGrabberHand
						vGrabAttach.z = vGrabAttach.z - 0.5

						local vGrabberHeadDir = hGrabber.actor:GetHeadDir()
						local vGrabberHead = hGrabber.actor:GetHeadPos()
						local hPlayerHeadDir = hPlayer.actor:GetHeadDir()
						local hPlayerHead = hPlayer.actor:GetHeadPos()

						local vHeadDir = {
							x = (hPlayerHead.x - vGrabberHead.x) * -1,
							y = (hPlayerHead.y - vGrabberHead.y) * -1,
							z = (hPlayerHead.z - vGrabberHead.z) * -1,
						}
						local vLookDirection = self:GetAnglesFromDir(vHeadDir)

						if (bIsLocal or bGrabberLocal) then

							if (bIsLocal) then
								vGrabAttach.z = vGrabAttach.z - 1
								if (g_localActor.actorStats.thirdPerson == true) then
									vGrabAttach = vGrabberHand
									vGrabAttach.x = vGrabAttach.x + (vGrabberHeadDir.x * -2)
									vGrabAttach.y = vGrabAttach.y + (vGrabberHeadDir.y * -2)
									vGrabAttach.z = vGrabAttach.z + (vGrabberHeadDir.z * -2)
									g_localActor.bGrabHiddn = true
									g_localActor:DrawSlot(0, 0)
								else
									if (g_localActor.bGrabHiddn) then
										g_localActor.bGrabHiddn = false
										g_localActor:DrawSlot(0, 1)
									end
								end
							elseif (bGrabberLocal) then
								if (g_localActor.actorStats.thirdPerson ~= true) then
									vGrabAttach.x = vGrabAttach.x - (vGrabberHeadDir.x * 0.1)
									vGrabAttach.y = vGrabAttach.y - (vGrabberHeadDir.y * 0.1)
								else
									vGrabAttach.x = vGrabAttach.x + (vGrabberHeadDir.x * 0.25)
									vGrabAttach.y = vGrabAttach.y + (vGrabberHeadDir.y * 0.25)
								end

								vLookDirection = {
									x = (hPlayerHead.x - vGrabberHead.x) * -1,
									y = (hPlayerHead.y - vGrabberHead.y) * -1,
									z = 0,
								}
							end

							hPlayer:SetPos(vGrabAttach)
							if (bIsLocal) then
								hPlayer:SetAngles(vLookDirection)
							else
								hPlayer:SetDirectionVector(vLookDirection)
							end
						else
							vGrabAttach.x = vGrabAttach.x + (vGrabberHeadDir.x * 0.25)
							vGrabAttach.y = vGrabAttach.y + (vGrabberHeadDir.y * 0.25)
							hPlayer:SetPos(vGrabAttach)

							hPlayerHead = hPlayer:GetPos()
							vGrabberHead = hGrabber:GetPos()
							vGrabberHead.z = vGrabberHead.z + 0.5

							vLookDirection = {
								x = (hPlayerHead.x - vGrabberHead.x) * -1,
								y = (hPlayerHead.y - vGrabberHead.y) * -1,
								z = (hPlayerHead.z - vGrabberHead.z) * -1 + 0.3,
							}

							hPlayer:SetAngles(self:GetAnglesFromDir(vLookDirection))
							hPlayer:SetDirectionVector(vLookDirection)
						end
					elseif (self:IsGrabbed(hPlayer)) then
						self:Drop(hPlayer, hPlayer.hGrabber)
					end
				end

			end
		]])


		do return end

		local t=GetPlayer(x)

		player:GrabPlayer(t, nil, 133)


		do return end
		if (t.grabbed) then
			player.grabbing=false
			t.grabbed=false;
			Debug("drop")
			ExecuteOnAll([[

				local a=GP(]]..player:GetChannel()..[[)
				local b=GP(]]..t:GetChannel()..[[);
				local xxx="fff"
				b:DetachThis()
				b.grabbed=false
				g_gameRules.game:FreezeInput(false)
				a:DestroyAttachment(0, xxx)
			LOOPED_ANIMS[b.id]=nil
			LOOPED_ANIMS[a.id]=nil

			b:StopAnimations(0)
			a:StopAnimations(0)
			]]);
		else
			player.grabbing=true
			t.grabbed=true
			Debug("grab")
			ExecuteOnAll([[

			GetAnglesFromDir = function(vDir1)

				local a = vDir1

				local dx, dy, dz = a.x,a.y, a.z;
				local dst = math.sqrt(dx*dx + dy*dy + dz*dz);
				local vec = {
					x = math.atan2(dz, dst),
					y = 0,
					z = math.atan2(-dx, dy)
				};

				return vec;
			end;

				local a=GP(]]..player:GetChannel()..[[)
				local b=GP(]]..t:GetChannel()..[[);
				local xxx="fff"

				a:AttachChild(b.id,1)
				b:SetColliderMode(2)
				if (b.id==g_localActorId) then
					g_gameRules.game:FreezeInput(true)
				end

				b.grabbed=true
				b.grabbedBy=a
				LOOPED_ANIMS[b.id]={KeepAnimation=1,ForcedTimer = 0.05, Timer=0.01,Start 	= _time-999,Entity 	= b,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= "grabbed_struggle_nw_01",NoSpec	= true,Alive	= true,NoWater	= true }
				LOOPED_ANIMS[a.id]={KeepAnimation=1,ForcedTimer = 0.05, Timer=0.01,Start 	= _time-999,Entity 	= a,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= "grabbed_struggleAttacker_nw_01",NoSpec	= true,Alive	= true,NoWater	= true }



			Remote.OnUpdate=function(self)
				for i,v in pairs(System.GetEntitiesByClass("Player"))do
					if (v.grabbed) then

						local bSelFists = false
						if (v.id==g_localActorId) then

							local hFIsts = v.inventory:GetItemByClass("Fists")
							local hCUrr=v.inventory:GetCurrentItem()

							if (hFIsts) then
								if (not hCUrr or hCUrr.class~="Fists") then
									v.actor:SelectItemByName("Fists")
								end
							end

						elseif (v.grabbedBy.id==g_localActorId) then

							local hFIsts = g_localActor.inventory:GetItemByClass("Fists")
							local hCUrr=g_localActor.inventory:GetCurrentItem()

							if (hFIsts) then
								if (not hCUrr or hCUrr.class~="Fists") then
									g_localActor.actor:SelectItemByName("Fists")
								end
							end

						end

						if (bSelFists) then

						end

							local vHand = v.grabbedBy:GetBonePos("Bip01 L Hand")
							local vNeck = v:GetBonePos("Bip01 Neck")
							local vHead = v:GetPos() or v:GetBonePos("Bip01 Head")
							local vFace = v.grabbedBy:GetBonePos("Bip01 Pelvis")

							local vMoveTo = vHand
							vMoveTo.z = vMoveTo.z - 0.5






						local vGrabber = v.grabbedBy.actor:GetHeadPos()
							local vGrabbed = v.actor:GetHeadPos()
							local vLookAt = {
								x = (vGrabbed.x - vGrabber.x) * -1,
								y = (vGrabbed.y - vGrabber.y) * -1,
								z = (vGrabbed.z - vGrabber.z) * -1,
							}
							vLookAt = GetAnglesFromDir(vLookAt)


						Msg(0,"FACE:: x=%f,y=%f,z=%f",vGrabbed.x,vGrabbed.y,vGrabbed.z)
						Msg(0,"HAND:: x=%f,y=%f,z=%f",vGrabber.x,vGrabber.y,vGrabber.z)

						if (v.id==g_localActorId or v.grabbedBy.id==g_localActorId) then
							Msg(0,"LOOK:: x=%f,y=%f,z=%f",vLookAt.x,vLookAt.y,vLookAt.z)

							if (v.id==g_localActorId) then
								vMoveTo.z=vMoveTo.z-1
							end
							v:SetPos(vMoveTo)

							if (v.id ~= g_localActorId) then
								v:SetAngles(vLookAt)
							else

							v:SetAngles(vLookAt)
							end
						else

							local vGrabberLookDir = v.grabbedBy.actor:GetHeadDir()
							vMoveTo.x = vMoveTo.x + vGrabberLookDir.x*0.25
							vMoveTo.y = vMoveTo.y + vGrabberLookDir.y*0.25
							v:SetPos(vMoveTo)

						vGrabbed=v:GetPos()
						vGrabber=v.grabbedBy:GetPos()
						vGrabber.z=vGrabber.z+0.5

							vLookAt = {
								x = (vGrabbed.x - vGrabber.x) * -1,
								y = (vGrabbed.y - vGrabber.y) * -1,
								z = (vGrabbed.z - vGrabber.z) * -1 + 0.3,
							}
							Msg(0,"LOOK:: x=%f,y=%f,z=%f",vLookAt.x,vLookAt.y,vLookAt.z)
							v:SetAngles(GetAnglesFromDir(vLookAt))
							v:SetDirectionVector((vLookAt))
						end

						if (timerexpired(XXXTIMER, 1)) then


							Particle.SpawnEffect("explosions.flare.night_time", vHand, vLookAt, 0.1)
							XXXTIMER=timerinit()
						end

					end;
				end;
			end;
			]]);
		end;

		do return end
		--[[
		Remote.OnUpdate=function(self)
				for i,v in pairs(System.GetEntitiesByClass("Player"))do
					if (v.grabbed) then
						local head=v.actor:GetHeadPos();
						local head2=v.grabbedBy.actor:GetHeadPos()
						local dir={
							x=head.x-head2.x,
							y=head.y-head2.y,
							z=head.z-head2.z,

						}
						v:SetDirectionVector(vecScale(dir,-1))
						v:SetPos(v.grabbedBy:GetBonePos("Bip01 L Hand"))

					end;
				end;
			end;
		]]

		do return end
		ExecuteOnAll("ATOMClient:LaunchPlayer("..player:GetChannel()..")")


		do return end


		ExecuteOnAll([[
			local p=GP(]]..player:GetChannel()..[[)
			if (not p) then return end
			
			ATOMClient:HandleEvent(eCE_Anim, p:GetName(), 
			local hRocket = System.SpawnEntity({ class = "BasicEntity", name = "BoomBoomRocket_" .. p:GetName(), position = p:GetPos(), orientation = { x = 0, y = 0, z = 0 }, properties = { object_Model = "Objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf" }, fMass = -1 })
			hRocket:SetScale(0.5)
			hRocket:DestroyPhysics()
			hRocket.TEffect=hRocket:LoadParticleEffect(-1,"smoke_and_fire.Vehicle_fires.burning_jet",{Scale=0.1,CountScale=5})
			hRocket.SEffect=hRocket:PlaySoundEvent("Sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)
			Sound.SetSoundVolume(hRocket.SEffect,0.5)
			local vpos=hRocket:GetPos()
			vpos.x=vpos.x+0
			vpos.y=vpos.y+0
			vpos.z=vpos.z-1
			local vdir=g_Vectors.up
			hRocket:SetSlotWorldTM(hRocket.TEffect, vpos, vecScale(vdir, -1))
			
			p:AttachChild(hRocket.id, 0)
			hRocket:SetLocalPos({x=-0.25,y=0.25,z=-1.0})
			
			Script.SetTimer(4000,function()
				hRocket:FreeSlot(hRocket.TEffect)
				System.RemoveEntity(hRocket.id)
			end)
			
			local vidir={x=0,y=0,z=1}
			if(p.id==g_localActorId)then
				p:AddImpulse(-1,p:GetCenterOfMassPos(),vidir, 3000, 1)
				Script.SetTimer(1000,function()
					p:AddImpulse(-1,p:GetCenterOfMassPos(),vidir, 3300, 1)
				end)
				FI(p,1,4)
			end
		]])

		Script.SetTimer(4000, function()
			for i = 1, 4 do
				Script.SetTimer(i*50,function()
					PlaySound("sounds/physics:explosions:grenade_explosion", player:GetPos())
					SpawnEffect("explosions.zero_gravity.explosion_small", player:GetPos())
				end)
			end
			HitEntity(player, 9999, player)
		end)



		do return end
		ExecuteOnPlayer(player,[[
		
		
		
		
		
		
		
		
		
		
		
														
														               
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												
																												]])


		do return end
		ATOM:ChangeCapacity(player,{
			[1] = { "bullet",				tonumber(x),  1 },
			[5] = { "explosivegrenade",	tonumber(x), 	  5 },
		})

		-- pole: objects/library/architecture/mine/scaffolding/scaffolding_pole_5m.cgf
		-- 0.75
		-- rotor: Objects/library/vehicles/asian_transport_helicopter/main_rotor.cgf
		-- 0.2


		do return end
		ExecuteOnAll([[
		
			Msg(0, tostring(g_localActor:GetBonePos("Bip01 Spine")))
		
			local sRotor = "Objects/library/vehicles/asian_transport_helicopter/main_rotor.cgf"
			local sPole = "objects/library/architecture/mine/scaffolding/scaffolding_pole_5m.cgf"
		
			local hPlayer = GP(]] .. player:GetChannel() .. [[)
			if (not hPlayer) then
				return false
			end
			
			local vPos = hPlayer:GetPos()
			
			local hPole = System.SpawnEntity({ class = "BasicEntity", name = "BasicEntity_HeliPole_" .. hPlayer:GetName(), position = vPos, orientation = { x = 0, y = 0, z = 0 }, properties = { object_Model = sPole, fMass = -1 }, fMass = -1 })
			local hRotor = System.SpawnEntity({ class = "BasicEntity", name = "BasicEntity_HeliPole_" .. hPlayer:GetName(), position = vPos, orientation = { x = 0, y = 0, z = 0 }, properties = { object_Model = sRotor, fMass = -1 }, fMass = -1 })
		
			hPole:SetScale(0.3)
			hRotor:SetScale(0.1)
			
			if (hPlayer.ATTACHED_ROTOR) then
				System.RemoveEntity(hPlayer.ATTACHED_ROTOR[1].id)
				System.RemoveEntity(hPlayer.ATTACHED_ROTOR[2].id)
			end
			
			hPole:DestroyPhysics()
			
			hPlayer:CreateBoneAttachment(0, "weapon_bone", "ROTOR_ATTACH_POINT")
			hPlayer:CreateBoneAttachment(0, "weapon_bone", "POLE_ATTACH_POINT")
			
			hPlayer:SetAttachmentObject(0, "ROTOR_ATTACH_POINT", hRotor.id, -1, 0)
			hPlayer:SetAttachmentObject(0, "POLE_ATTACH_POINT", hPole.id, -1, 0)
			
			
			hPlayer:SetAttachmentDir(0, "ROTOR_ATTACH_POINT", { x = 0, y = 0, z = 0 }, true)
			hPlayer:SetAttachmentPos(0, "ROTOR_ATTACH_POINT", { x = 0, y = -3, z = 0 }, false)
			
			hPlayer:SetAttachmentDir(0, "POLE_ATTACH_POINT", { x = 0, y = 0, z = 0 }, true)
			hPlayer:SetAttachmentPos(0, "POLE_ATTACH_POINT", { x = 0, y = 0, z = 0 }, false)
			
				
			hPlayer.ATTACHED_ROTOR = {
				hPole,
				hRotor
			}

			Msg(0,"yes")
		]])

		--[[
		
		helmet:EnablePhysics(false)
				player:CreateBoneAttachment(0, bone or "Bip01 Head", NAME)
				player:SetAttachmentObject(0, NAME, helmet.id, -1, 0)
				player:SetAttachmentDir(0,NAME,tdir or vecScale(player.actor:GetHeadDir(),-1),true)
				player:SetAttachmentPos(0,NAME,{x=x,y=y,z=z},false)
		
		]]

		do return end

		ExecuteOnPlayer(player,[[
		g_localActor.actor:CameraShake(80, 0.1, 0.1, g_Vectors.v000)
	]])


		do return end
		local hVehicle = player:GetVehicle()
		if not hVehicle then
			return false ,"enter vehicle "
		end


		-- x={x=0,y=0,z=0}
		ExecuteOnAll([[
		
		local v=GetEnt(']]..hVehicle:GetName()..[[')
		v:DrawSlot(0,0)
		
		local x={x=0,y=0,z=0}
		local aEnts={
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=-0.5,y=0.375,z=0.625},x,1},
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=0.5,y=0.30,z=0.625},x,1},
			{"Objects/library/props/electronic_devices/consoles/keyboard.cgf", {x=-0.3782,y=0.9353,z=1.2089},{x=0,y=0,z=-1.57},1},
			{"Objects/library/props/electronic_devices/consoles/keyboard.cgf", {x=0.4,y=0.9353,z=1.2089},{x=0,y=0,z=-1.57},1},
			{"Objects/library/architecture/aircraftcarrier/props/furniture/tables/mess_table.cgf", {x=-0.0032,y=1.4353,z=0.4589},x,1},
			{"Objects/library/props/electronic_devices/consoles/monitor_lcd.cgf", {x=-0.3782,y=1.3103,z=1.2089},{x=0,y=0,z=-1.57},1},
			{"Objects/library/props/electronic_devices/consoles/monitor_lcd.cgf", {x=0.4968,y=1.3103,z=1.2089},{x=0,y=0,z=-1.57},1},
			{"objects/library/architecture/village/floor/floor_concrete_400_400.cgf", {x=-0.7241,y=0.9353,z=0.4589},x,0.35},
			{"objects/library/architecture/village/floor/floor_concrete_400_400.cgf", {x=-1.0032,y=-1.0647,z=0.4589},x,0.5},
			{"Objects/library/props/gasstation/tire_rim.cgf", {x=-1.2025,y=-0.6001,z=0.3237},{x=0,y=1.575,z=-0},1.2},
			{"Objects/library/props/gasstation/tire_rim.cgf", {x=0.9988,y=-0.6001,z=0.3237},{x=0,y=1.575,z=-0},1.2},
			{"Objects/library/machines/elevators/mine elevator/elevator_generator.cgf", {x=-0.2532,y=2.5603,z=0.4589},{x=0,y=0,z=1.575},0.25},
			{"objects/weapons/us/frag_grenade/frag_grenade_tp.cgf", {x=-1.0032,y=2.5603,z=1.8339},{x=1.575,y=0,z=0},1,{"vehicle_fx.vehicle_exhaust.boost","vehicle_fx.vehicle_exhaust.tank_exhaust"},"sounds/vehicles:us_apc:run"},
			
			
		
		}
		
		v:DrawSlot(2,0)
		v:DrawSlot(4,0)
		local vpos=v:GetPos()
		local vang=v:GetDirectionVector()
		Msg(0,"ok")
		for i,vv in pairs(aEnts) do
			
			local aNew=System.SpawnEntity({ class = "CustomAmmoPickup",position={x=vpos.x,y=vpos.y,z=vpos.z},orientation=vang,name="v_part_"..tostring(i)..tostring(v),properties={objModel=vv[1],bPhysics=0}})			
		
			v:AttachChild(aNew.id,0)
			aNew:SetScale(vv[4])
			aNew:SetLocalPos(vv[2])
			aNew:SetLocalAngles(vv[3])
			
			if(vv[5]) then
				if (type(vv[5])=="table") then
					for ii,p in pairs(vv[5]) do
						aNew:LoadParticleEffect(-1,p,{CountScale=5,SpeedScale=0.35,PulsePeriod=0.1,Scale=1})
					end
				else
					aNew:LoadParticleEffect(-1,vv[5],{CountScale=5,SpeedScale=0.35,PulsePeriod=0.1,Scale=1})
				end
			end
			if(vv[6]) then
				aNew.SoundID_Exhaust = aNew:PlaySoundEvent(vv[6], g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)
				Sound.SetSoundVolume(aNew.SoundID_Exhaust, 3)
			end
			
		end
		
		
		]])



		do return end

		local hPet = System.SpawnEntity({ class = "Player", name = "Pet " .. g_utils:SpawnCounter(), position = player:CalcSpawnPos(-3), orientation = player:GetAngles() })
		local idGun = ItemSystem.GiveItem(GetRandom({"SCAR","FY71","SMG"}), hPet.id, true)
		local hGun = GetEnt(idGun)

		Script.SetTimer(1000, function()
			hGun.weapon:RequestStartFire()
			for i = 1, hGun.weapon:GetClipSize() do
				Script.SetTimer(i * (hGun.weapon:GetFireRate() / 100), function()

					local vPlayer = player:GetBonePos("Bip01 Pelvis")
					-- vPlayer.z = vPlayer.z + 1
					local vPos = hPet:GetPos()--hGun.weapon:GetFiringPos(vPlayer)
					-- local vPos = hPet:GetBonePos("Bip01 R Hand")
					local vDir = vector.getdir(vPlayer, vPos, 1)


					-- SpawnEffect(ePE_Flare, vPos, g_Vectors.up, 0.1)

					hGun.weapon:ServerShoot(hGun.weapon:GetAmmoType(), vPos, vDir, vDir, CalcPos(vPos, vDir, 1024), 0, 0, 0, 0, false)
					-- hPet.nextHitDamage = 25
					-- g_gameRules:CreateHit(player.id, hPet.id, hGun.id, (hGun.weapon:GetDamage() or 25), 1, "mat_default", 0, "normal");
					if (i==hGun.weapon:GetClipSize()) then
						hGun.weapon:RequestStopFire()
					end
				end)
			end

		end)


		do return end



		local hVehicle = player:GetVehicle()
		if not hVehicle then
			return false ,"enter vehicle "
		end


		ExecuteOnAll([[
		
		local v=GetEnt(']]..hVehicle:GetName()..[[')
		v:DrawSlot(0,0)
		
		x={x=0,y=0,z=0}
		local aEnts={
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=-0.5,y=0.375,z=0.625},x,1},
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=0.5,y=0.30,z=0.625},x,1},
			{"Objects/library/architecture/aircraftcarrier/props/consoles/console_bridge_steer.cgf", {x=-0.875,y=1.875,z=0.625},x,0.78},
			{"objects/library/architecture/aircraftcarrier/props/consoles/console_bridge_5.cgf", {x=-0.125,y=1.875,z=0.625},x,0.78},
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=-0.5,y=-0.125,z=0.625},{x=0,y=0,z=3.2},1},
			{"Objects/library/furniture/chairs/office_chair.cgf", {x=0.5,y=-0.125,z=0.625},{x=0,y=0,z=3.2},1},
			{"Objects/library/architecture/aircraftcarrier/props/furniture/tables/mess_table.cgf", {x=-0.125,y=-1.12,z=0.625},x,1},
			
			{"Objects/library/architecture/hillside_cafe/metal_roof_01.cgf", {x=-0.625,y=0.875,z=2.875},x,1},
			{"Objects/library/architecture/hillside_cafe/metal_roof_01.cgf", {x=-0.625,y=-0.675,z=2.875},x,1},
			{"Objects/library/architecture/hillside_cafe/metal_roof_01.cgf", {x=0.625,y=0.875,z=2.875},{x=0,y=0,z=3.2},1},
			{"Objects/library/architecture/hillside_cafe/metal_roof_01.cgf", {x=0.625,y=-0.625,z=2.875},{x=0,y=0,z=3.2},1},
			
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=-0.875,y=1.625,z=1.75},{x=0,y=0,z=2},1.1725},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=-0.875,y=-1.25,z=1.75},{x=0,y=0,z=-2},1.1725},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=0.875,y=1.625,z=1.75},{x=0,y=0,z=2},1.1725},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=0.875,y=-1.25,z=1.75},{x=0,y=0,z=-2},1.1725},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=0,y=0.25,z=1.85},{x=0,y=0,z=-2},1.1825},
			
			
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=-0.5,y=0.375,z=0.5},{x=1.47,y=0,z=0},2.15},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=0,y=0.375,z=0.5},{x=1.47,y=0,z=0},2.15},
			{"Objects/library/props/building material/wodden_support_beam_plank_2_c.cgf", {x=0.5,y=0.375,z=0.5},{x=1.47,y=0,z=0},2.15},
			
			
		
		}
		
		
		local vpos=v:GetPos()
		local vang=v:GetDirectionVector()
		Msg(0,"ok")
		for i,vv in pairs(aEnts) do
			
			local aNew=System.SpawnEntity({ class = "CustomAmmoPickup",position={x=vpos.x,y=vpos.y,z=vpos.z},orientation=vang,name="v_part_"..tostring(i)..tostring(v),properties={objModel=vv[1],bPhysics=0}})			
		
			v:AttachChild(aNew.id,0)
			aNew:SetScale(vv[4])
			aNew:SetLocalPos(vv[2])
			aNew:SetLocalAngles(vv[3])
			
		end
		
		
		]])





		do return end
		ATOMDefense:OnCheat(player, "test", "test", false)
		player.perfs.flaggedCount = 123
		player.perfs.flaggedTime = 311
		do return end

		if x and y then
			return self:EnterStadium(player) elseif (x) then
			return self:RemoveStadium(player) else
			return self:SpawnStadium(player) end



		do return end
		local vTest = player:GetVehicle() or SpawnGUINew({ Model = "Objects/library/props/scientific/oscilloscope.cgf", Pos = player:GetPos() })
		local radius = 5
		local dim=2*radius;

		local trigger=System.SpawnEntity{
			class="ATOMTrigger",
			flags=ENTITY_FLAG_SERVER_ONLY,
			position=player:GetPos() or {x=0, y=0, z=0},
			name=vTest:GetName().."_service_zone_trigger",


			properties={
				DimX=dim,
				DimY=dim,
				DimZ=dim,
				bOnlyPlayer=1,
			},
		};

		vTest.OnEnterArea = function()
			Debug("enter !!")
		end

		vTest.OnLeaveArea = function()
			Debug("leave !!")
		end


		trigger:ForwardEventsTo(vTest, true)
		-- vTest:AttachChild(trigger.id, 0);
		-- trigger:ForwardTriggerEventsTo(vTest.id);

		SpawnEffect(ePE_Flare, trigger:GetPos())

		do return end
		local vTest = SpawnGUINew({ Pos = player:GetPos() })
		MakeBuyZone(vTest)

		vTest.Server.OnEnterArea = function()
			Debug("enter !")
		end

		vTest.Server.OnLeaveArea = function()
			Debug("leave !")
		end


		do return end

		local v = player:GetVehicle();
		if (v.HeliMiniguns) then
			System.RemoveEntity(v.HeliMiniguns[1].id);
			System.RemoveEntity(v.HeliMiniguns[2].id);
			v.HeliMiniguns = nil;

			RCA:StopSync(v, v.GunSyncID);
			HELI_MINIGUNS[v.id] = nil;
		else
			local Minigun1 = System.SpawnEntity({ class = "Hurricane", position = v:GetPos(), name = v:GetName() .. "_minigun_" .. g_utils:SpawnCounter() });
			local Minigun2 = System.SpawnEntity({ class = "Hurricane", position = v:GetPos(), name = v:GetName() .. "_minigun_" .. g_utils:SpawnCounter() });

			Minigun1.unpickable = true;
			Minigun2.unpickable = true;

			v.HeliMiniguns = {
				Minigun1,
				Minigun2
			};

			v:AttachChild(Minigun1.id, 1);
			v:AttachChild(Minigun2.id, 1);

			local vdir = v:GetDirectionVector();

			Minigun1:SetDirectionVector(vdir);
			Minigun2:SetDirectionVector(vdir);

			Minigun1:SetLocalPos({x=3.05,y=-0.65,z=0.25})
			Minigun2:SetLocalPos({x=-3.05,y=-0.65,z=0.25})

			local code = [[
				local v=GetEnt(']] .. v:GetName() .. [[');
				local g1, g2 = GetEnt(']] .. Minigun1:GetName() .. [['), GetEnt(']] .. Minigun2:GetName() .. [[');
				if (v and not v.vehicle:IsDestroyed() and g1 and g2) then
					v:AttachChild(g1.id, 1);
					v:AttachChild(g2.id, 1);
					
					local vdir = v:GetDirectionVector();
					
					g1:SetDirectionVector(vdir);
					g2:SetDirectionVector(vdir);
					
					g1:SetLocalPos({x=3.05,y=-0.65,z=0.25})
					g2:SetLocalPos({x=-3.05,y=-0.65,z=0.25})
				end;
			]];

			ExecuteOnAll(code);

			v.GunSyncID = RCA:SetSync(v, { client = code, link = true });
			v.OnMousePress = function(self, driver, release)
				Debug("PRESSED!")
				if (not self.vehicle:IsDestroyed()) then
					if (driver or release) then
						if (driver and not release) then
							self.InFiring = true;
						elseif (self.InFiring) then
							self.InFiring = false;
						end;
					end;
				end;
			end;

			HELI_MINIGUNS[v.id] = v;
		end;


		do return end

		player.AimDebug = not player.AimDebug


		do return end
		if (player.placedExplosives and arrSize(player.placedExplosives) > 0) then
			if (g_game:GetPlayerCount() >= 2) then
				if (g_gameRules.class == "PowerStruggle") then
					local others = DoGetPlayers({sameTeam = true, teamId = g_game:GetTeam(player.id), except = player.id});
					if (others[1]) then
						SendMsg(CENTER, others[1], "You gained ownership of %s explosives", player:GetName());
						for i, explosives in pairs(player.placedExplosives) do
							for ii, explosiveId in pairs(explosives) do
								local explosive = GetEnt(explosiveId);
								if (explosive) then
									if (g_game.SetProjectileOwner) then
										g_game:SetProjectileOwner(explosiveId, others[1].id);
									else
										explosive.new_ownerId = others[1].id;
									end;
								end;
							end;
						end;
						player.placedExplosives = nil;
					end;
				end;
			end;
		end;

		do return end

		for i, entityid in pairs(g_gameRules.hqs) do
			local entity=GetEnt(entityid)
			entity.Server.OnEnterArea=function(self, entity, areaId)
				g_gameRules:OnPerimeterBreached()
			end;

			-- OnLeaveArea
			entity.Server.OnLeaveArea=function(self, entity, areaId)
				g_gameRules:OnPerimeterBreached()
			end;

		end
		do return end

		ExecuteOnAll([[
	
	
	
		
			ATOMClient.AASearchLasers.EnableAASearchLight = function(self, class, enable)
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					self:SpawnSearchLight(v, enable);
				end
			end
		
			
			ATOMClient.AASearchLasers.PostUpdateAASearchLaser = function(self, class)
				
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					if (v.item:IsDestroyed()) then
						if (v.SearchLaser and not v.HadSearchLaser) then
							self:SpawnSearchLaser(v, false);
							v.HadSearchLaser = true;
						end;
						if (v.SearchLight and not v.HadSearchLight) then
							self:SpawnSearchLight(v, false);
							v.HadSearchLight = true;
							v.SearchLight = false;
						end;
					else
						if (v.HadSearchLight) then
							self:SpawnSearchLight(v, true);
							v.SearchLight = true;
						end;
						if (v.HadSearchLaser) then
							self:SpawnSearchLaser(v, true);
							v.HadSearchLaser = false;
						end;
						if (v.SearchLaser) then
							if (v.SearchLaser:GetScale() ~= SEARCHLASER_SCALE) then
								v.SearchLaser:SetScale(SEARCHLASER_SCALE); 
							end;
							v.SearchLaser:SetAngles(v:GetSlotAngles(1));
						end;
						if (v.SearchLight) then
							v.SearchLight:SetAngles(v:GetSlotAngles(1));
							
						end;
					end;
				end
			end
			
			ATOMClient.AASearchLasers.SpawnSearchLight = function(self, entity, enable)	
				if (enable) then
					self:LoadAALight(entity);
				else
					self:UnloadLight(entity);
				end
			end
			ATOMClient.AASearchLasers.UnloadLaser = function(self, entity, laser)
				System.RemoveEntity(entity.SearchLight);
				entity.SearchLight = nil;
			end
			ATOMClient.AASearchLasers.LoadAALight = function(self, entity)
				
				if (entity.SearchLight) then
					System.RemoveEntity(entity.SearchLight.id);
				end;
				
				if (not Light) then
					Script.ReloadScript("Scripts/Entities/Lights/Light.lua");
				end
				local props = Light.Properties;
				local Style = props.Style;
				local Projector = props.Projector;
				local Color = props.Color;
				local Options = props.Options;

				local diffuse_mul = Color.fDiffuseMultiplier;
				local specular_mul = Color.fSpecularMultiplier;
				
				local lt = Light._LightTable;
				lt.style = Style.nLightStyle;
				lt.corona_scale = Style.fCoronaScale;
				lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
				lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
				lt.radius = props.Radius;
				lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
				if (diffuse_mul ~= 0) then
					lt.specular_multiplier = specular_mul / diffuse_mul;
				else
					lt.specular_multiplier = 1;
				end
				
				lt.hdrdyn = Color.fHDRDynamic;
				lt.projector_texture = Projector.texture_Texture;
				lt.proj_fov = Projector.fProjectorFov;
				lt.proj_nearplane = Projector.fProjectorNearPlane;
				lt.cubemap = Projector.bProjectInAllDirs;
				lt.this_area_only = Options.bAffectsThisAreaOnly;
				lt.realtime = Options.bUsedInRealTime;
				lt.heatsource = 0;
				lt.fake = Options.bFakeLight;
				lt.fill_light = props.Test.bFillLight;
				lt.negative_light = props.Test.bNegativeLight;
				lt.indoor_only = 0;
				lt.has_cbuffer = 0;
				lt.cast_shadow = Options.bCastShadow;

				lt.lightmap_linear_attenuation = 1;
				lt.is_rectangle_light = 0;
				lt.is_sphere_light = 0;
				lt.area_sample_number = 1;
				
				lt.RAE_AmbientColor = { x = 0, y = 0, z = 0 };
				lt.RAE_MaxShadow = 1;
				lt.RAE_DistMul = 1;
				lt.RAE_DivShadow = 1;
				lt.RAE_ShadowHeight = 1;
				lt.RAE_FallOff = 2;
				lt.RAE_VisareaNumber = 0;
				
				entity.SearchLight = System.SpawnEntity({class="Light",})
				entity.SearchLight.bActive=0
				entity.SearchLight:OnPropertyChange()
				entity:AttachChild(entity.SearchLight.id, 8);
				entity.SearchLight:SetLocalPos({ x = 0, y = 0, z = 1.65 })
				Msg(0, "loaded")
			end
			
			
		ATOMClient.AASearchLasers:EnableAASearchLight("AutoTurret",   true);
		ATOMClient.AASearchLasers:EnableAASearchLight("AutoTurretAA", true);
		
		
	
	]])

		do return end

		ExecuteOnAll([[
	
		Remote.OnUpdate=nil
	]])


		do return end

		ExecuteOnAll([[
	
	local max = function(a,b)
		if (a>b) then
			return b
		end
		return a
	end
	
	local function getLoadingBar(__cur, __max, c)
	local __max = __max or 100;
	local __mul = __max / 100;
	local __cur = math.floor(__cur * __mul);
	local __rem = __max - __cur;
	local __F = max(math.floor(__cur), __max);
	local __R = math.floor(__rem);
	return c..string.rep("|", __F) .. "$1" ..string.rep("|", __R);
	end;
	
	ATOMClient.Patcher:FAdd("Player", function(self, hit)
		Msg(0, "Hit!")
		ATOMClient:OnHit(self, hit);
		
	end, "OnHit", "Client");
	
		Remote.OnUpdate = function()
		
			for i, v in pairs(System.GetEntitiesByClass("Player")) do
			
				if ((v.id ~= g_localActorId or v.actorStats.thirdPerson) and _time - ((v.HitTime or 0)) <= 10) then
					
					local hp = v.actor:GetHealth(), v.actor:GetArmor()
					local en = v.actor:GetNanoSuitEnergy()
					
					local hpos = v:GetBonePos("Bip01 head");
					
					hpos.z = hpos.z + 0.8
					
					local dist = calcDist(hpos, System.GetViewCameraPos());
					
					if (dist < 50) then
						if (ATOMClient:CanSeePoint(hpos, v.id)) then
							System.DrawLabel( hpos, max(3/dist,0.5)*1.3, (hp>0 and"$1["..getLoadingBar(hp,HEALTHBAR_SIZE,"$4").."$1] "or"").."$1["..getLoadingBar(en/2,HEALTHBAR_SIZE,"$5").."$1]", 1,0,0, (50-dist)/50 );
						end;
					end;
				end;
			end;
		
		end
	
	]])

		do return end


		ExecuteOnAll([[
	
		AASearchLasers = {
			-------------------
			EnableAASearchLaser = function(self, class, enable)
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					self:SpawnSearchLaser(v, enable);
				end
			end,
			-------------------
			UpdateAASearchLaser = function(self, class)
				for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
					if (v.SearchLaser) then
						if (v.SearchLaser:GetScale() ~= SEARCHLASER_SCALE) then
							v.SearchLaser:SetScale(SEARCHLASER_SCALE);
						end;
						v.SearchLaser:SetAngles(v:GetSlotAngles(1));
					end;
				end
			end,
			-------------------
			SpawnSearchLaser = function(self, entity, enable)	
				if (enable) then
					self:LoadAALaser(entity);
				else
					self:UnloadLaser(entity, entity.SearchLaser);
				end
			end,
			-------------------
			UnloadLaser = function(self, entity, laser)
				if (laser) then
					Msg(0, "del %s", laser:GetName())
					System.RemoveEntity(laser.id);
					entity.SearchLaser = nil;
				end;
			end,
			-------------------
			LoadAALaser = function(self, entity)
				local laser = System.SpawnEntity({
					class = "BasicEntity",
					name = entity:GetName() .. "_searchlaser",
					scale = 2,
					properties = {
						object_Model = "objects/effects/beam_laser_02.cgf",
					},
					fMass = -1,
				});
				laser:SetScale(SEARCHLASER_SCALE)
				entity.SearchLaser = laser;
				entity:AttachChild(laser.id, 8);
				laser:SetLocalPos({ x = 0, y = 0, z = 1.65 })
				Msg(0, "%s", laser:GetName())
			end
			-------------------
		},
	
		ATOMClient.AASearchLasers:EnableAASearchLaser("AutoTurret", false)
		ATOMClient.AASearchLasers:EnableAASearchLaser("AutoTurretAA", false)
		
		ATOMClient.AASearchLasers:EnableAASearchLaser("AutoTurret", true)
		ATOMClient.AASearchLasers:EnableAASearchLaser("AutoTurretAA", true)
	
	]])

		do return end
		ExecuteOnAll([[
		
			Remote.OnUpdate = function()
				
			end
		
		]])

		do return end
		os.execute("chcp 65001")
		print("[31mtest1")
		System.LogAlways("[31mtest2")
		os.execute("echo [31mtest3");

		do return end
		player.builder_enabled=not player.builder_enabled

		do return end

		-- LOL
		ExecuteOnAll([[
		
		nCX={}
			function nCX:EnableAASearchLights(class, enable)
		for i, v in pairs(System.GetEntitiesByClass(class) or {}) do
			self:AttachSearchLight(v, enable);
		end
	end

	function nCX:UpdateAASearchLights()
		for i, v in pairs(System.GetEntitiesByClass("AutoTurretAA") or {}) do
			v:SetSlotAngles(7, v:GetSlotAngles(1));
		end
		for i, v in pairs(System.GetEntitiesByClass("AutoTurret") or {}) do
			v:SetSlotAngles(7, v:GetSlotAngles(1));
		end
	end
	
	function nCX:AttachSearchLight(entity, enable)	
		if (enable) then
			self:LoadLight(entity, 7, enable);
		else
		
		end
	end
	
	function nCX:LoadLight(entity, nSlot, enable)
		if (not enable) then
			
		end
		if (not Light) then
			Script.ReloadScript("Scripts/Entities/Lights/Light.lua");
		end
		local props = Light.Properties;
		local Style = props.Style;
		local Projector = props.Projector;
		local Color = props.Color;
		local Options = props.Options;

		local diffuse_mul = Color.fDiffuseMultiplier;
		local specular_mul = Color.fSpecularMultiplier;
		
		local lt = Light._LightTable;
		lt.style = Style.nLightStyle;
		lt.corona_scale = Style.fCoronaScale;
		lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
		lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
		lt.radius = props.Radius;
		lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
		if (diffuse_mul ~= 0) then
			lt.specular_multiplier = specular_mul / diffuse_mul;
		else
			lt.specular_multiplier = 1;
		end
		
		lt.hdrdyn = Color.fHDRDynamic;
		lt.projector_texture = Projector.texture_Texture;
		lt.proj_fov = Projector.fProjectorFov;
		lt.proj_nearplane = Projector.fProjectorNearPlane;
		lt.cubemap = Projector.bProjectInAllDirs;
		lt.this_area_only = Options.bAffectsThisAreaOnly;
		lt.realtime = Options.bUsedInRealTime;
		lt.heatsource = 0;
		lt.fake = Options.bFakeLight;
		lt.fill_light = props.Test.bFillLight;
		lt.negative_light = props.Test.bNegativeLight;
		lt.indoor_only = 0;
		lt.has_cbuffer = 0;
		lt.cast_shadow = Options.bCastShadow;

		lt.lightmap_linear_attenuation = 1;
		lt.is_rectangle_light = 0;
		lt.is_sphere_light = 0;
		lt.area_sample_number = 1;
		
		lt.RAE_AmbientColor = { x = 0, y = 0, z = 0 };
		lt.RAE_MaxShadow = 1;
		lt.RAE_DistMul = 1;
		lt.RAE_DivShadow = 1;
		lt.RAE_ShadowHeight = 1;
		lt.RAE_FallOff = 2;
		lt.RAE_VisareaNumber = 0;

		entity:LoadLight( nSlot,lt );

	end	
	
	nCX:EnableAASearchLights("AutoTurret", true)
	nCX:EnableAASearchLights("AutoTurretAA", true)
		Remote.OnUpdate = nCX.UpdateAASearchLights
		
		]])


		do return end

		player:GetCurrentItem().isGodLaser = true

		do return end
		do return self:StartVote(player,x,y,z,...); end

		do return end
		ATOMNames:OnConnect(player)

		do return end
		self:Enter(player);

		do return end

		local function convertDir(d)
			return {x = 90/d.x,y = 90/d.y,z = 90/d.z}
		end;

		local data_f = {

		}
		local data = {


			-- !! ALL WORKIN !!!
			{ makeVec(36,74,25), makeVec(0.70710671,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(84,42,25), makeVec(-0.70710689,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(36,90,25), makeVec(0.70710671,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(36,58,25), makeVec(0,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(36,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(52,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
			{ makeVec(68,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK

			{ makeVec(52,90,25), makeVec(0,-1,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(68,90,25), makeVec(0,-1,0,1), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(84,58,25), makeVec(-0.70710689,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(84,90,25), makeVec(0,-1,0,1), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(84,74,25), makeVec(-1,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},


			{ makeVec(52.075005,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(68.450012,62.475002,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(52.075005,62.475006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(68.450012,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(35.700005,62.47501,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(35.700005,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},

			{ makeVec(102.575,73.900002,18.000002), makeVec(0,1,0,0), "Objects/library/machines/cranes/container_crane/container_crane.cgf"},
			{ makeVec(59.625,43.875,18), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/support_building_fit_concrete_wall.cgf"},
			{ makeVec(58.547081,46.747971,18.375), makeVec(0.70710677,0,0,-0.70710677), "Objects/library/barriers/concrete_wall/door.cgf"},

			{ makeVec(71.724983,65.125,20.474998), makeVec(0,1,0,1.1126266e-007), "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf"},
			{ makeVec(77.724976,65.125008,20.474998), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf"},


			{ makeVec(62.72501,55.749992,20.475002), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(42.050011,74.524994,20.475002), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(62.72501,74.524994,20.475002), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(42.075008,65.124992,20.475002), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(42.075008,55.749992,20.475002), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(77.725014,74.524994,20.475002), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(57.075012,65.124992,20.475002), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(57.050014,74.524994,20.475002), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(57.075012,55.749996,20.475002), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(77.725014,55.749996,20.475002), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},

			{ makeVec(71.725006,65.125,20.475), makeVec(0,-1,0,1), "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf"},
			{ makeVec(62.725006,65.125008,20.475), makeVec(0,1,0,0), "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf"},

			{ makeVec(52.074997,66.300003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(64.712502,73.674995,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(48.099991,54.887501,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(48.099991,73.662498,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(52.074997,56.925003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(67.724998,66.300003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(55.062489,73.662498,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},

			{ makeVec(55.062489,54.887501,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(48.099991,64.262505,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(67.724998,56.925003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(64.712502,54.887501,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(52.074997,75.700005,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(67.724998,75.712509,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},


			{ makeVec(44.099998,66.300003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(44.099998,75.699997,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(44.099998,56.925003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},


			{ makeVec(71.699997,73.662498,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(71.699997,54.887501,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(71.699997,64.262505,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},

			{ makeVec(44.099987,64.262512,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(44.099987,54.88752,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(44.099987,73.662514,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},

			{ makeVec(75.700005,56.925003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(75.699989,54.887512,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(75.699989,64.26252,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(75.700005,66.300003,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(75.699989,73.662514,17.525), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(75.700005,75.712502,18.025002), makeVec(-0.70710671,0,0,0.70710683), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},

			{ makeVec(65.124992,64.299995,17.35), makeVec(-1,0,0,0.70710683), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(65.124985,63.974991,17.35), makeVec(1,0,0,-0.70710671), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(54.649986,63.974991,17.35), makeVec(1,0,0,-0.70710671), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(54.649994,64.299995,17.35), makeVec(-1,0,0,0.70710683), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},


			{ makeVec(57.375004,53.712505,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(57.375004,63.075001,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(57.375004,72.537506,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},

			{ makeVec(62.725006,53.6875,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(62.725006,63.075001,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(62.725006,72.5625,20.699999), makeVec(0,1,0,0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},


			{ makeVec(62.725002,74.562492,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(62.725002,55.687489,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(62.725002,65.074997,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},

			{ makeVec(57.374996,74.537491,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(57.374996,65.074997,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(57.374996,55.712494,18.075001), makeVec(0,1,0,0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},

			-- !! ALL WORKIN !!!




			--[[






            --]]
		};


		for i, v in pairs(data) do
			local pos = v[1];
			local dir = v[2];
			System.LogAlways(
					"{ makeVec(" .. pos.x - 36 .. ", " .. pos.y - 36 .. ", " .. pos.z - 18 .. "), makeVec(" .. dir.x .. ", " .. dir.y .. ", " .. dir.z .. "), \"" .. v[3] .. "\" },"
			)

		end;

		do return end

		local p=player:GetPos() or makeVec() or _TESTPOS or player:GetPos()
		_TESTPOS=p
		for i, v in pairs(data) do

			if (x) then
				_TESTINDEX=x=="x" and 0 or  tonum(x)
			end
			_TESTINDEX=(_TESTINDEX or 0)+1

			--local v = data[_TESTINDEX]

			local x=SpawnGUINew({
				Model = v[3],
				Pos = add2Vec(p, v[1]),
				Dir = (v[2]),
				bStatic = 1,
				Mass = -1,
			})

			SpawnEffect(ePE_Flare,add2Vec(p, v[1]))
			--Debug(x:GetDirectionVector(), "|",v[2])
			--x:SetAngles(Dir2Ang(v[2]))
			--x:SetDirectionVector(v[2])
			Debug("INDEX :: ".._TESTINDEX)

		end;

		for i, v in pairs(data_f) do

			local x=SpawnGUINew({
				Model = v[3],
				Pos = add2Vec(p, v[1]),
				Dir = (v[2]),
				bStatic = 1,
				Mass = -1,
			})
			--Debug(x:GetDirectionVector(), "|",v[2])
			--x:SetAngles(Dir2Ang(v[2]))
			--x:SetDirectionVector(v[2])

		end;

		do return end



		local data = {
			{ makeVec(-30.980396270752, -89.90001180768, 120.3597869873), makeVec(0, 0,3.141592502594),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-21.527477264404, -46.647982388735, 126.9847869873), makeVec(0, 0,-1.570796251297),"Objects/library/barriers/concrete_wall/door.cgf"},
			{ makeVec(-46.980396270752, -57.90001180768, 120.3597869873), makeVec(0, 0,1.5707961320877),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-25.705402374268, -53.58751180768, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-20.355392456055, -55.612505704165, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-38.680400848389, -66.200014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-7.0803833007812, -64.162524014711, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-28.105381011963, -63.875002652407, 128.00978660583), makeVec(0, 0,-1.5707961320877),"Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(9.3446025848389, -63.575011044741, 127.3597869873), makeVec(0, 0,0),"Objects/library/machines/cranes/towercrane/towercranea.cgf"},
			{ makeVec(-40.705410003662, -55.650007992983, 124.88478469849), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-34.680393218994, -64.162516385317, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-20.355392456055, -64.975008755922, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-25.705406188965, -55.650004178286, 124.88478469849), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-38.680400848389, -56.825014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-65.555393218994, -73.800013333559, 127.35978507996), makeVec(0, 0,0),"Objects/library/machines/cranes/container_crane/container_crane.cgf"},
			{ makeVec(1.3195991516113, -62.375021725893, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(-20.030410766602, -74.425005704165, 124.88478469849), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-11.080387115479, -54.78751257062, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-5.0304069519043, -74.425005704165, 124.88478469849), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(1.3195991516113, -86.875017911196, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(-30.980396270752, -41.90001180768, 120.3597869873), makeVec(0, 0,0),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-20.355400085449, -53.612517148256, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-28.105388641357, -64.200007230043, 128.00978660583), makeVec(0, 0,1.5707964897156),"Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(-20.355400085449, -72.437517911196, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-11.080387115479, -73.562510281801, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-27.692897796631, -54.78751257062, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-30.705394744873, -56.825014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-20.055408477783, -55.650007992983, 124.88478469849), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-38.680400848389, -75.612513333559, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-20.355392456055, -74.437502652407, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-38.6803855896, -73.56252554059, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-25.705402374268, -65.025019437075, 124.88478660583), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf"},
			{ makeVec(-7.0803833007812, -64.162524014711, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-15.055400848389, -62.375017911196, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(-14.980396270752, -41.90001180768, 120.3597869873), makeVec(0, 0,0),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(1.019603729248, -41.90001180768, 120.3597869873), makeVec(0, 0,0),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-15.055400848389, -86.875017911196, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(-25.70539855957, -74.462504178286, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-15.055393218994, -66.200014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-7.080394744873, -56.825014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-18.04288482666, -73.562510281801, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-27.692897796631, -73.575007230043, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-46.980396270752, -89.90001180768, 120.3597869873), makeVec(0, 0,3.141592502594),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-38.6803855896, -54.787524014711, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-5.0554046630859, -55.650004178286, 124.88478469849), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-7.080394744873, -75.600008755922, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-14.980396270752, -89.90001180768, 120.3597869873), makeVec(0, 0,3.141592502594),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-5.0554046630859, -65.025004178286, 124.88478469849), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-7.0803833007812, -73.56252554059, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-34.705379486084, -65.02501180768, 124.88478851318), makeVec(0, 0,2.2252531550748e-07),"objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf"},
			{ makeVec(-38.6803855896, -64.162531644106, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-25.705406188965, -74.425005704165, 124.88478469849), makeVec(0, 0,0),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-30.705394744873, -66.200014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(1.019603729248, -57.90001180768, 120.3597869873), makeVec(0, 0,-1.5707964897156),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-17.630390167236, -64.200007230043, 128.00978660583), makeVec(0, 0,1.5707964897156),"Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(-31.430408477783, -62.375014096498, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(-15.055393218994, -56.825014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-46.980396270752, -41.90001180768, 120.3597869873), makeVec(0, 0,1.5707961320877),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(1.019603729248, -89.90001180768, 120.3597869873), makeVec(0, 0,-1.5707964897156),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-22.605396270752, -43.77501180768, 127.3597869873), makeVec(0, 0,0),"Objects/library/barriers/concrete_wall/support_building_fit_concrete_wall.cgf"},
			{ makeVec(-31.430408477783, -86.875017911196, 127.28478622437), makeVec(0, 0,0),"Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
			{ makeVec(1.019603729248, -73.90001180768, 120.3597869873), makeVec(0, 0,-1.5707964897156),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-25.705402374268, -72.46251180768, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-20.355400085449, -62.97501257062, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-30.705394744873, -75.612520962954, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-25.705402374268, -62.97501257062, 124.65978813171), makeVec(0, 0,0),"Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf"},
			{ makeVec(-17.630382537842, -63.875002652407, 128.00978660583), makeVec(0, 0,-1.5707961320877),"Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf"},
			{ makeVec(-34.680393218994, -73.562510281801, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-7.0803833007812, -54.787531644106, 127.83478736877), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf"},
			{ makeVec(-34.680393218994, -54.78751257062, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-15.055393218994, -75.600016385317, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-20.055408477783, -65.025004178286, 124.88478469849), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-46.980396270752, -73.90001180768, 120.3597869873), makeVec(0, 0,1.5707961320877),"Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
			{ makeVec(-40.705410003662, -74.425005704165, 124.88478469849), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf"},
			{ makeVec(-40.705371856689, -65.025019437075, 124.88478851318), makeVec(0, 0,-3.1415922641754),"objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf"},
			{ makeVec(-11.080387115479, -64.162516385317, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-34.705402374268, -65.02501180768, 124.88478660583), makeVec(0, 0,-3.141592502594),"objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf"},
			{ makeVec(-25.70539855957, -64.975008755922, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-18.04288482666, -54.78751257062, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-7.080394744873, -66.200014859438, 127.33478546143), makeVec(0, 0,1.5707964897156),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
			{ makeVec(-25.70539855957, -55.587500363588, 127.28478622437), makeVec(0, 0,0),"objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf"},
		};


		local p=player:GetPos()
		for i, v in pairs(data) do

			local x=SpawnGUINew({
				Model = v[3],
				Pos = add2Vec(p, v[1]),
				Ang = v[2],
				bStatic = 1,
				Mass = -1,
			})
			--Debug(x:GetDirectionVector(), "|",v[2])
			--x:SetAngles(Dir2Ang(v[2]))
			x:SetAngles(v[2])

		end;

		do return end;



		local _MAINPOS = player:GetPos(); --makeVec(59, 64, 19)

		local models={

			["GeomEntity75"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity74"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity95"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity30"] = "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf",
			["GeomEntity66"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity101"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity28"] = "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf",
			["GeomEntity9"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity12"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity18"] = "Objects/library/machines/cranes/towercrane/towercranea.cgf",
			["GeomEntity19"] = "Objects/library/machines/cranes/container_crane/container_crane.cgf",
			["GeomEntity7"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity35"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity88"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity64"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity78"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity49"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity23"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity53"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity90"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity98"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity100"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity39"] = "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf",
			["GeomEntity34"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity85"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity5"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity67"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity27"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity56"] = "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf",
			["GeomEntity47"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity48"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity8"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity62"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity73"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity10"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity102"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity65"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity91"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity4"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity3"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity26"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity72"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity82"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity32"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity33"] = "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf",
			["GeomEntity52"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity40"] = "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf",
			["GeomEntity84"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity11"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity50"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity97"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity57"] = "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf",
			["GeomEntity89"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity55"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity103"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity6"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity22"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity16"] = "Objects/library/barriers/concrete_wall/support_building_fit_concrete_wall.cgf",
			["GeomEntity13"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity54"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity99"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity42"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity51"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity87"] = "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf",
			["GeomEntity94"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity86"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity79"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity83"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity96"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity25"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity2"] = "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf",
			["GeomEntity105"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity45"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity24"] = "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf",
			["GeomEntity104"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity63"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
			["GeomEntity17"] = "Objects/library/barriers/concrete_wall/door.cgf",
			["GeomEntity106"] = "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf",
			["GeomEntity68"] = "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf",
			["GeomEntity43"] = "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf",
			["GeomEntity71"] = "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf",
		}

		local geom = System.GetEntitiesByClass("GeomEntity")
		for i, g in pairs(geom) do
			--Debug("P",g.Properties)
			--Debug("E",g)
			System.LogAlways("{ makeVec(" .. _MAINPOS.x - g:GetPos().x .. ", " .. _MAINPOS.y - g:GetPos().y .. ", " .. _MAINPOS.z - g:GetPos().z .. "), makeVec(" .. g:GetAngles().x .. ", " ..g:GetAngles().y..","..g:GetAngles().z..")," .. "\"" ..models[g:GetName()] .. "\"},")

		end;

		do return end




		local v = player:GetVehicle()
		ExecuteOnAll([[
			local v=GetEnt(']]..v:GetName()..[[')
			v:DrawSlot(3,0)
			v:DrawSlot(4,0)
			v:SetSlotPos(1,{x=1,y=-1,z=-0.3})
			v:SetSlotPos(2,{x=1,y=1,z=-0.3})
		]])


		do return end

		-- !! DSG FLOOR WITHOUT BUILDINGS !! DONT FKC UP 
		--[[
				local data_f = {
{ makeVec(36,74,25), makeVec(0.70710671,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(84,42,25), makeVec(-0.70710689,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(36,90,25), makeVec(0.70710671,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(36,58,25), makeVec(0,0,0,-0.70710683), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(36,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(52,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK
{ makeVec(68,42,25), makeVec(0,1,0,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"}, -- OK

{ makeVec(52,90,25), makeVec(0,-1,0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
{ makeVec(68,90,25), makeVec(0,-1,0,1), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
{ makeVec(84,58,25), makeVec(-0.70710689,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
{ makeVec(84,90,25), makeVec(0,-1,0,1), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},
{ makeVec(84,74,25), makeVec(-1,0,0,0.70710671), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf"},


{ makeVec(52.075005,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
{ makeVec(68.450012,62.475002,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
{ makeVec(52.075005,62.475006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
{ makeVec(68.450012,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
{ makeVec(35.700005,62.47501,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
{ makeVec(35.700005,86.975006,18.075001), makeVec(0,1,0,0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf"},
}
--]]

		do return end
		local some_factory;
		for i, v in pairs(System.GetEntities()) do
			if (v.SynchedBuyZone) then
				--Debug("SYNCH!!")
				some_factory = GetEnt(v.SynchedBuyZone[1]);
				if (some_factory) then
					Debug(some_factory.class)
					some_factory.allClients:ClSetBuyFlags(v.id, v.SynchedBuyZone[2]);
					--Debug("SYNCHEFD")
				end;
			end;
		end;

		do return end
		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");
		ExecuteOnAll([[
			local g = GetEnt("]]..AlienThing:GetName()..[[")
			g.CM =   "objects/weapons/us/Beretta92FS/Beretta92FS_tp.cgf"
			g.CMFP = "objects/weapons/us/Beretta92FS/Beretta92FS_right_fp.chr"
			
		]])


		do return end

		do return end

		local transVtol = player:GetVehicle();
		transVtol.IsTrans = true;
		transVtol.TransRange = 10;
		transVtol.TransCargo = nil;


		do return end
		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");

		AlienThing.MegaAlienGun=true
		ExecuteOnAll([[
			local g = GetEnt("]]..AlienThing:GetName()..[[")
			g.CM = "objects/weapons/alien/moac/moac.cgf"
			g.CMFP = "objects/weapons/alien/moac/moac.cgf"
			g.CMPos={x=-0.2,y=0.4,z=0}
			g.CMPosLocal={x=0.25,y=0.7,z=-0.5}
			g.CMDir={x=0.24,y=0,z=1.6}
			g_localActor.ICML=nil
			g_localActor.ICMId=nil
		]])


		do return end

		ExecuteOnAll([[
			local g = GetEnt("]]..AlienThing:GetName()..[[")
			g.CM = "objects/weapons/alien/moac/moac.cgf"
			g.CMFP = "objects/weapons/alien/moac/moac.cgf"
			g.CMPos={x=-0.2,y=0.4,z=0}
			g.CMPosLocal={x=0,y=0.5,z=-0.3}
			g.CMDirLocal={x=]]..x..[[,y=]]..y..[[,z=]]..z..[[}
			g.CMDir={x=0.24,y=0,z=1.6}
			g_localActor.ICML=nil
			g_localActor.ICMId=nil
		]])


		do return end
		player:GetVehicle().ReportOnCollision=1

		do return end
		local all = player:GetCurrentItem()
		all.item:SetParams(1,true)

		do return end

		local all = player:GetCurrentItem()
		all.item:Reset()
		ExecuteOnAll([[
					GetEnt("]]..all:GetName()..[[").item:Reset()
				]])


		do return end

		local all = System.GetEntitiesByClass("GUI");
		for i, v in pairs(all) do
			if (v.Init_Pos) then
				SpawnEffect(ePE_Light,v:GetPos())
				ExecuteOnAll([[
					GetEnt("]]..v:GetName()..[["):SetPos(]]..arr2str_(v:GetPos())..[[)
				]])
			end;
		end;

		do return end
		ExecuteOnAll([[
		
			function ElevatorSwitch:Used()
		Msg(0, "TEST NOW!!!")
	local i=0;
	local link=self:GetLinkTarget("up", i);
	while (link) do
		Msg(0, "UP!!!")
		link:Up(self.Properties.nFloor);
		i=i+1;
		link=self:GetLinkTarget("up", i);
	end
	
	i=0;
	link=self:GetLinkTarget("down", i);
	while (link) do
		Msg(0, "DOWWWWWWWWWWWN!!!")
		link:Down(self.Properties.nFloor);
		i=i+1;
		link=self:GetLinkTarget("down", i);
	end
	
	
	self.allClients:ClUsed();
end

for i,v in pairs(System.GetEntitiesByClass("ElevatorSwitch")) do
	v.Used=ElevatorSwitch.Used
	Msg(0,"PATCHED %s",v:GetName())
end;
		]])
		do return end
		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");
		ExecuteOnAll([[
			local g=GetEnt("]]..AlienThing:GetName()..[[")
			g.CM="Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf"
			g.CMFP="Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf"
		
			g.CMPosLocal={x=0.15,y=0.4,z=-0.25}
			g_localActor.ICML=nil
		]])


		do return end

		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");
		ExecuteOnAll([[
			g_localActor:SetSlotPos(3, {x=0.15,y=0.4,z=-0.25})
		]])


		do return end

		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");
		ExecuteOnAll([[
			local g=GetEnt("]]..AlienThing:GetName()..[[")
			g_localActor.actor:PlayAction("melee_upper_cut_right","Action");
		]])


		do return end

		local AlienThing = player:GetCurrentItem();--SpawnGUI("Objects/weapons/alien/alien_weapon/alien_weapon.cgf");
		ExecuteOnAll([[
			local g=GetEnt("]]..AlienThing:GetName()..[[")
			g_localActor.actor:SimulateOnAction("]]..x..[[",1,1.0);
		]])


		do return end
		SpawnGUI("objects/library/alien/generic_elements/hologram_machine/hologram_machine_default.cga",player:CalcPos(3))

		do return end
		if (not player.ProtectionSphere) then
			Debug("there, ")
			local sphere = SpawnGUINew({Model="Objects/library/alien/ship_exterior/sphere_around_ship/zero_g_sphere.cgf", Pos=player:GetPos(),Mass=1,bStatic=false,NoPhys=false});
			sphere:SetScale(0.02)
			--player:AttachChild(sphere.id,2);
			player.ProtectionSphere = sphere
			player.ProtectionSphereRad = 30;
			local code=[[local s,_p=GetEnt("]]..sphere:GetName()..[["),GP(]]..player:GetChannel()..[[);s:SetMaterial("objects/library/alien/ship_exterior/sphere_around_ship/zerogspherescene2")STICKY_POSITIONS[s.id]={_p.id,nil,nil,true}]];
			sphere.syncId = RCA:SetSync(sphere, {client=code,link=true})
			ExecuteOnAll(code)
		else
			Debug("gone, ")
			RCA:StopSync(player.ProtectionSphere, player.ProtectionSphere.syncId);
			System.RemoveEntity(player.ProtectionSphere.id)
			player.ProtectionSphere = nil;
		end;

		do return end
		ExecuteOnPlayer(player, [[USE_RANK_MODELS=true]])

		do return end
		player:SetRank(tonumber(x))

		do return end
		self:GetTextCoord(player)

		do return end
		local Turret = _G["AutoTurret"];
		Turret.Properties.species = player.Properties.species--game:SpawnCounter();	
		Turret.Properties.teamName = "tan";
		Turret.Properties.objModel="objects/weapons/multiplayer/air_unit_radar.cgf";
		Turret.Properties.objBarrel="objects/weapons/multiplayer/ground_unit_gun.cgf";
		Turret.Properties.objBase="objects/weapons/multiplayer/ground_unit_mount.cgf";
		Turret.Properties.objDestroyed="objects/weapons/multiplayer/air_unit_destroyed.cgf";
		Turret.Properties.GunTurret.bEnabled=1
		Turret.Properties.GunTurret.TurnSpeed=3
		Turret.Properties.GunTurret.MGRange=250
		Turret.Properties.GunTurret.RocketRange=250
		player.Properties.species=0
		local T = System.SpawnEntity({class="AutoTurret",position=player:CalcSpawnPos(10,1),name="TURTUR_"..g_gameRules.Utils:SpawnCounter()})

		CryAction.CreateGameObjectForEntity(T.id);
		CryAction.BindGameObjectToNetwork(T.id);

		g_game:SetTeam(T.id, player:GetTeam())

		local vehicle=player:GetVehicle()
		Script.SetTimer(1, function()
			--local civ=System.GetEntity(player.actor:GetLinkedVehicleId())--System.SpawnEntity({class="Civ_car1",position=CF_GameUtils:CalcSpawnPos(player,3,0),name="CIVVI_"..game:SpawnCounter()})
			Script.SetTimer(100, function()
				local CODE=[[
					local c=GetEnt("]]..vehicle:GetName()..[[");
					if (c) then
						local a=GetEnt("]]..T:GetName()..[[")
						c:AttachChild(a.id,1);
						a:SetLocalPos({x=0,y=-0.2,z=2})
						a:SetScale(0.5)
					end;
				]]
				ExecuteOnAll(CODE)
				vehicle.syncId=self:SetSync(vehicle.id, {link = true, client = CODE});
				T:SetScale(1)
				vehicle:AttachChild(T.id, 1);
				T:SetLocalPos({ x = 0, y = -0.2, z = 2 });
			end);
		end);


		do return end
		ATOMJail.perma={
			jailed={["1234"]=883812}
		}
		ATOMJail:SaveFile()
		ATOMJail:LoadFile()

		--ATOMJail:JailPlayer(player,x,y,z)

		do return end
		--



		--intensity, radius, effect, effectScale, effectScaleVariation, _highAtten, _highColor, _highMult, _highVertical, sound, delay, delayVar, dur, tunderDelay, tunderVar
		local T=System.SpawnEntity({class="Lightning",position=player:CalcSpawnPos(100),name=

		"1|800|Weather.Lightning.LightningBolt1|0.05|0.5|10|77_121_223|32|8|Sounds/environment:random_oneshots_natural:distant_thunder|5|0.5|0.2|1|0.5|"..g_utils:SpawnCounter()

		})

		CryAction.CreateGameObjectForEntity(T.id);
		CryAction.BindGameObjectToNetwork(T.id);

		do return end

		ExecuteOnAll([[
			
		
		]])


		do return end

		ExecuteOnAll([[
			
			GP(]]..player:GetChannel()..[[):StartAnimation(0,"crouch_plantUB_c4_01")
		
		]])



		do return end

		local t=GetPlayer(x)

		if (t.grabbed) then
			t.grabbed=false;
			Debug("drop")
			ExecuteOnAll([[
				
				local a=GP(]]..player:GetChannel()..[[)
				local b=GP(]]..t:GetChannel()..[[);
				local xxx="fff"
				b.grabbed=false
				a:DestroyAttachment(0, xxx)
			LOOPED_ANIMS[b.id]=nil
			LOOPED_ANIMS[a.id]=nil
			]]);
		else
			t.grabbed=true
			Debug("grab")
			ExecuteOnAll([[
				local a=GP(]]..player:GetChannel()..[[)
				local b=GP(]]..t:GetChannel()..[[);
				local xxx="fff"
				
				b.grabbed=true
				b.grabbedBy=a
				LOOPED_ANIMS[b.id]={Start 	= _time,Entity 	= b,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= "grabbed_struggle_nw_01",NoSpec	= true,Alive	= true,NoWater	= true }
				LOOPED_ANIMS[a.id]={Start 	= _time,Entity 	= a,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= "grabbed_struggleAttacker_nw_01",NoSpec	= true,Alive	= true,NoWater	= true }
			Remote.OnUpdate=function(self)
				for i,v in pairs(System.GetEntitiesByClass("Player"))do
					if (v.grabbed) then
						local head=v.actor:GetHeadPos();
						local head2=v.grabbedBy.actor:GetHeadPos()
						local dir={
							x=head.x-head2.x,
							y=head.y-head2.y,
							z=head.z-head2.z,
						
						}
						v:SetDirectionVector(vecScale(dir,-1))
						v:SetPos(v.grabbedBy:GetBonePos("Bip01 L Hand"))
						
					end;
				end;
			end;
			]]);
		end;
		--[[
					a:CreateBoneAttachment(0, "Bip01 L Hand", fff);
					a:SetAttachmentPos(0, fff, {x=-0,y=-0.3,z=1}, false);
					a:SetAttachmentObject(0, fff, b.id, -1, 0);
		GRABBED[b.id]={
					By=a,
					Bone="Bip01 R hand"
				}
				--]]

		do return end
		ExecuteOnAll([[
			
			GP(]]..player:GetChannel()..[[):StartAnimation(0,"stealth_idleAimPoses_mg_01")
		
		]])

		do return end
		--	local pos = {0.12,0.18,0,};
		--	player:SetAttachmentPos(0, beanie, pos, false);
		ExecuteOnAll([[
			ATOMClient.AttachBinoculars=function(self,player,enable)
					local beanie = "_beanie";
				if (enable) then
				
				local cgfPath = "Objects/Library/Equipment/binoculars/binoculars.cgf";
			
					player:DestroyAttachment(0, beanie);
					player:CreateBoneAttachment(0, "Bip01 R Eye", beanie);
					player:SetAttachmentCGF(0, beanie, cgfPath);
					
					local dir =player.actor:GetHeadDir();
					player:SetAttachmentDir(0, beanie, dir, true);
				
				
					player:StartAnimation(0, "usCarrier_watchTowerLookOut_binoculars_01", 10, 0, 1, true);
				else
					player:StopAnimation(0,10)
					player:DestroyAttachment(0, beanie);
				end;
			end;
		
		]])

		do return end
		ATOMAlias:CheckPlayer(player)

		do return end
		g_gameRules.nukePlayer=player.id;
		g_gameRules:SetTimer(g_gameRules.NUKE_SPECTATE_TIMERID, 1000)

		do return end
		ExecuteOnAll([[
		HUD.DisplayBigOverlayFlashMessage("Press [F3] To Start Bomb Drop!", 10, ]]..x..[[, ]]..y..[[, { 255/255, 255/255, 255/255 });
		]])

		do return end
		player.actor:DropItem(player:GetCurrentItem().id)

		do return end
		local RAY=player:GetHitPos(1, ent_all, player:GetPos(), g_Vectors.down);
		if (RAY and RAY.entity and RAY.entity.JetType) then
			Debug("JET, TOGGLE LINK");
			if (player.linkedToJet) then
				player:DetachThis();
				player.linkedToJet=false
				ExecuteOnAll(formatString([[
					local p,v=GP(%d),GetEnt("%s");
					p:DetachThis()
				
				]],player:GetChannel(),RAY.entity:GetName()))
			else
				player.actor:LinkToEntity(RAY.entity.id);
				ExecuteOnAll(formatString([[
					local p,v=GP(%d),GetEnt("%s");
					v:AttachChild(p.id,]]..x..[[);
				
				]],player:GetChannel(),RAY.entity:GetName()))
				player.linkedToJet=true
			end;
			Debug("NOW LINKED: ",player.linkedToJet)
		elseif (player.linkedToJet) then
			player:DetachThis();
			Debug("NO JET, DELINK")
			player.linkedToJet=false
			ExecuteOnAll(formatString([[
					local p=GP(%d);
					p:DetachThis()
				
				]],player:GetChannel()))
		end;
		Debug("Standing On Aircraft:",(RAY and RAY.entity) and RAY.entity:GetName() or false)


		do return end



		player.actor:SetMovementTarget(player:GetPos(), add2Vec(player:GetPos(),makeVec(10,10,0)), makeVec(), 15)

		do return end

		_G[x].Properties.bMounted = 0
		_G[x].Properties.bMountable = 1

		_G[x].Properties.bSelectable = 1
		_G[x].Properties.bPickable = 1
		_G[x].Properties.bGiveable = 1
		_G[x].Properties.bRaisable = 1
		_G[x].Properties.bSelectable = 1
		_G[x].Properties.bDroppable = 1

		ExecuteOnAll([[
			local x="]]..x..[["
			
		_G[x].Properties.bSelectable = 1
		_G[x].Properties.bPickable = 1
		_G[x].Properties.bSelectable = 1
		_G[x].Properties.bDroppable = 1
		_G[x].Properties.bGiveable = 1
		_G[x].Properties.bRaisable = 1
		_G[x].Properties.bMounted = 0
		_G[x].Properties.bMountable = 1
		
		
		]])

		Script.SetTimer(111, function()
			local shit = System.GetEntity(ItemSystem.GiveItem(x, player.id, true));


			if (shit) then
				shit.Properties.bSelectable = 1
				shit.Properties.bPickable = 1
				shit.Properties.bGiveable = 1
				shit.Properties.bRaisable = 1
				shit.Properties.bSelectable = 1
				shit.Properties.bDroppable = 1
				shit.Properties.bMounted = 0
				shit.Properties.bMountable = 1
				Script.SetTimer(1, function()
					ExecuteOnAll([[
			local x=GetEnt("]]..shit:GetName()..[[")
			
		x.Properties.bSelectable = 1
		x.Properties.bPickable = 1
		x.Properties.bSelectable = 1
		x.Properties.bDroppable = 1
		x.Properties.bGiveable = 1
		x.Properties.bRaisable = 1
		x.Properties.bMounted = 0
		x.Properties.bMountable = 1
		
		
		]])
					player.actor:SelectItemByNameRemote(x);

				end)
				player.inventory:SetAmmoCount(shit.weapon:GetAmmoType(), 999)
			else
				return false, "shit";
			end;

		end)
		do return end

		self:SetTimer(self.NEXTLEVEL_TIMERID, 1)

		do return end

		local enabled = RCA:MakeJet(player:GetVehicle(), x or 2);
		Debug(enabled);

		do return end
		ExecuteOnAll([[
	
			ATOMClient:JetEffects(GetEnt("]]..player:GetVehicle():GetName()..[["), 3, true, 0)
		]])


		do return end

		ExecuteOnAll([[
	
			g_localActor:GetVehicle().IsJet = 1
			g_localActor:GetVehicle().IsJet = true
			g_localActor:GetVehicle().isJet = 1
		]])
		player:GetVehicle().IsJet=true

		do return end
		g_gameRules.onClient:ClStartWorking(player, ATOM.Server.id, "@" .. json.encode(payload));

		do return end
		g_game:SetSynchedEntityValue(player.id, PowerStruggle.PP_AMOUNT_KEY, pp or 0);
		SysLog("1")
		g_game:SetSynchedEntityValue(player.id, PowerStruggle.PP_AMOUNT_KEY, cp or 0);
		SysLog("2")
		g_game:SetSynchedEntityValue(NULL_ENTITY, PowerStruggle.PP_AMOUNT_KEY, pp or 0);
		SysLog("3")
		g_game:SetSynchedEntityValue(NULL_ENTITY, PowerStruggle.PP_AMOUNT_KEY, cp or 0);
		SysLog("4")
		for i=1, 199 do
			g_game:SetSynchedEntityValue(NULL_ENTITY, i or PowerStruggle.PP_AMOUNT_KEY, i or 0);
			SysLog("%d",i+4)
		end
		do return end

		player:GetCurrentItem().isFlamethrower=not player:GetCurrentItem().isFlamethrower

		do return end
		SendMsg(CENTER, player, "For playing total - [ %d ] - Hours, you have been awarded - [ %d ] - Prestige!", 555, (555-1)*10);

		do return end

		ExecuteOnAll([[
			local keys = {
				"w","a","s","d","leftshift"
			};
			System.ClearKeyState();
			
			function OnKeyPressed(key)
				if (FLYMODE_STATE ~= nil) then
					if (key=="w") then
						FLYMODE_STATE = FLYMODE_STATE == 1 and 0 or 1;
					elseif (key=="a") then
						FLYMODE_STATE = FLYMODE_STATE == 2 and 0 or 2;
					elseif (key=="s") then
						FLYMODE_STATE = FLYMODE_STATE == 3 and 0 or 3;
					elseif (key=="d") then
						FLYMODE_STATE = FLYMODE_STATE == 4 and 0 or 4;
					elseif (key=="shift") then
						FLYMODE_STATE_SHIFT = not FLYMODE_STATE_SHIFT;
					end;
				end;
			end;
			for i, v in pairs(keys) do
				System.AddCCommand("cl_input", "OnKeyPressed(\%1)", "obsolete")
				System.ExecuteCommand("bind " .. v .. " cl_input "..v)
			end;
			
			Remote.OnUpdate=function()
				if (FLYMODE_STATE) then
					if (not FLYMODE_LASTUPDATE or _time - FLYMODE_LASTUPDATE > 0.03) then
					
						local p = System.GetViewCameraPos()
						local d = System.GetViewCameraDir()
						local e = System.GetViewCameraDir()
						
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
					end
				end;
			end;
		]]);



		do return end

		ExecuteOnAll([[ATOM_2D_TEXTS={}]])

		do return end

		ExecuteOnAll([[
			local keys = {
				"a",
				"b",
				"c",
				"d",
				"e",
				"f",
				"g",
				"h",
				"i",
				"j",
				"k",
				"l",
				"m",
				"n",
				"o",
				"p",
				"q",
				"r",
				"s",
				"t",
				"u",
				"v",
				"w",
				"x",
				"y",
				"z",
				"0",
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
				"7",
				"8",
				"9",
				"f1",
				"f2",
				"f3",
				"f4",
				"f5",
				"f6",
				"f7",
				"f8",
				"f9",
				"space",
				"enter",
				"np_1",
			};
			System.ClearKeyState();
			
			function OnKeyPressed(key)
				if (key=="space") then
					key=" ";
				end;
				Msg(0, "Key pressed: %s", key)
			end;
			System.SetCVar("log_verbosity","-1")
			for i, v in pairs(keys) do
				System.AddCCommand("cl_input", "OnKeyPressed(\%1)", "obsolete")
				System.ExecuteCommand("bind " .. v .. " bind_key_"..v,true,true)
			end;
			--System.ClearConsole();
			
		]]);



		do return end
		ATOMNames:OnConnect(player)


		do return end

		local x=SpawnBot(player,x)

		Script.SetTimer(1099, function()
			x.actor:RequestMovement()
		end)

		do return end
		Script.SetTimer(1, function()
			System.SpawnEntity({class = "Player", position = player:CalcSpawnPos(10) })
		end)


		do return end

		local alientest = System.SpawnEntity({class="Grunt",position=player:CalcSpawnPos(5),properties={species=player.Properties.species,bSpeciesHostility=0},name="grunt_"..g_utils:SpawnCounter()})
		local proto = g_utils:GetBuilding("Proto");
		alientest.Properties.species=player.Properties.species

		Script.SetTimer(1,function()
			ATOMDLL:SetClient(false)
			local AI_VEHICLE = System.SpawnEntity({class="US_tank",name="Heli "..g_utils:SpawnCounter(),position=player:CalcSpawnPos(15)})

			ATOMDLL:SetClient(true)

			AI_VEHICLE.Properties.accuracy = 1;
			AI_VEHICLE.Properties.followDistance = 1000;
			AI_VEHICLE.Properties.commrange = 1000;
			AI_VEHICLE.Properties.attackrange = 3000;
			AI_VEHICLE.Properties.aicharacter_character = "HeliAggressive";
			AI_VEHICLE.Properties.species = CCC;
			AI_VEHICLE.Properties.bSpeciesHostility = 1
			AI_VEHICLE.Properties.bAutoDisable = 0

			--AI.RegisterWithAI(AI_VEHICLE.id, AIOBJECT_VEHICLE, AI_VEHICLE.Properties or {});


			AI_VEHICLE.vehicle:EnterVehicle(alientest.id, 1, false)
		end);



		Script.SetTimer(1000, function()
			ATOMDLL:SetMultiplayer(false)
			alientest.actor:ExecuteAction("run_combat", proto.id)
			ATOMDLL:SetMultiplayer(true)
		end)


		do return end

		ExecuteOnAll([[
		
			Remote.OnUpdate=function()
				for i,e in pairs(System.GetEntitiesByClass("Scout")or{})do
					if ( e.actor:GetHealth()>0) then
						if (e.ldir ) then
						
							e:SetDirectionVector(e.ldir)
						end;
					end
				end;
			end
		]])

		do return end

		ATOMDLL:SetClient(true)
		--ATOMDLL:SetServer(false)
		ATOMDLL:SetMultiplayer(false)
		local alientest = System.GetEntity(ATOMDLL:SpawnArchetype("aliens.Hunters.Hunter", player:CalcSpawnPos(40), {x=0,y=0,z=0},"Entity "..g_utils:SpawnCounter(), ""))

		ATOMDLL:SetMultiplayer(true)
		--ATOMDLL:SetServer(true)
		ATOMDLL:SetClient(false)
		do return end
		--ATOMDLL:SetClient(true)
		local counter=g_utils:SpawnCounter()
		local alientest = System.SpawnEntity({PropertiesInstance={bAutoDisable=0},properties={},class="Scout", position=player:CalcSpawnPos(15), name="Scout_" .. counter})

		alientest.PropertiesInstance.bAutoDisable=0

		Debug("AITYPE",alientest.AIType)
		Debug(">",alientest.Properties.aicharacter_character)

		Script.SetTimer(5000, function()

			alientest:TriggerEvent(AIEVENT_ENABLE);

		end)

		--ATOMDLL:SetClient(false)


		do return end

		ATOMDLL:SetClient(true)
		local alientest = System.GetEntity(ATOMDLL:SpawnArchetype("aliens.NakedAliens.Alien_Range_Weapon", player:CalcSpawnPos(15), {x=0,y=0,z=0},"Entity "..g_utils:SpawnCounter(), ""))

		alientest.Properties.aicharacter_character="GuardNeue"

		alientest.PropertiesInstance.bAutoDisable=0
		alientest.PropertiesInstance.groupid=711
		alientest.PropertiesInstance.smartObject_smartObjectClass="Alien";
		alientest.PropertiesInstance.Variation=0

		alientest.Properties.aicharacter_character="GuardNeue"
		alientest.Properties.commrange=70
		alientest.Properties.fGroupHostility=0
		alientest.Properties.groupid=711
		alientest.Properties.rank=4
		alientest.Properties.special=0
		alientest.Properties.smartObject_smartObjectClass="Alien"




		alientest.Properties.bSpeciesHostility = 1;
		alientest.Properties.awarenessOfPlayer = 1;
		alientest.Properties.species=g_utils:SpawnCounter()
		alientest.Properties.bGrenades=1;

		Debug("AITYPE",alientest.AIType)
		Debug(">",alientest.Properties.aicharacter_character)

		ATOMAI:RegisterAI(alientest)


		ATOMDLL:SetClient(false)


		do return end

		ATOMDLL:SetMultiplayer(false)
		ATOMDLL:SetClient(true)

		local CCC=g_utils:SpawnCounter()

		local AI_PILOT = System.GetEntity(ATOMDLL:SpawnArchetype("Asian_new.Special\\Driver.NK_Driver_Heli", player:GetPos(), {x=0,y=0,z=0},"Entity "..g_utils:SpawnCounter(), ""))
		local AI_GUNNER = System.GetEntity(ATOMDLL:SpawnArchetype("Asian_new.Flanker\\Elite.Light_SMG_SF", player:GetPos(), {x=0,y=0,z=0},"Entity "..g_utils:SpawnCounter(), ""))

		AI_PILOT.Properties.species = CCC;
		AI_GUNNER.Properties.species = CCC;

		Script.SetTimer(1,function()
			ATOMDLL:SetClient(false)
			local AI_VEHICLE = System.SpawnEntity({properties={accuracy=1;followDistance=15;commrange=1000;attackrange=3000;aicharacter_character="HeliAggressive",species=10;bSpeciesHostility=1};class="Asian_helicopter",name="Heli "..g_utils:SpawnCounter(),position=player:CalcSpawnPos(15)})

			ATOMDLL:SetClient(true)

			AI_VEHICLE.Properties.accuracy = 1;
			AI_VEHICLE.Properties.followDistance = 1000;
			AI_VEHICLE.Properties.commrange = 1000;
			AI_VEHICLE.Properties.attackrange = 3000;
			AI_VEHICLE.Properties.aicharacter_character = "HeliAggressive";
			AI_VEHICLE.Properties.species = CCC;
			AI_VEHICLE.Properties.bSpeciesHostility = 1
			AI_VEHICLE.Properties.bAutoDisable = 0

			--AI.RegisterWithAI(AI_VEHICLE.id, AIOBJECT_VEHICLE, AI_VEHICLE.Properties or {});


			AI_VEHICLE.vehicle:EnterVehicle(AI_PILOT.id, 1, false)
			AI_VEHICLE.vehicle:EnterVehicle(AI_GUNNER.id, 2, false)
		end);

		ATOMDLL:SetClient(false)
		ATOMDLL:SetMultiplayer(true)


		do return false end
		ATOMDLL:SetMultiplayer(false)
		ATOMDLL:SetClient(true)
		local PILOTLOL = System.GetEntity(ATOMDLL:SpawnArchetype(tostring(x or "asian_new.Special\\Driver.NK_Driver_tank"), player:CalcSpawnPos(5), player:GetAngles(), "Entity "..g_utils:SpawnCounter(), ""))
		local GUNNERLOL = System.GetEntity(ATOMDLL:SpawnArchetype("Asian_new.Flanker\\Elite.Light_SMG_SF", player:CalcSpawnPos(3), player:GetAngles(), "Entity "..g_utils:SpawnCounter(), ""))


		local CCC=g_utils:SpawnCounter()

		local c=PILOTLOL
		c.PropertiesInstance.bAutoDisable = 0
		c.Properties.bSpeciesHostility = 1;
		c.Properties.awarenessOfPlayer = 1;
		c.Properties.species=CCCC
		c.Properties.bGrenades=1;
		c=GUNNERLOL
		c.PropertiesInstance.bAutoDisable = 0
		c.Properties.bSpeciesHostility = 1;
		c.Properties.awarenessOfPlayer = 1;
		c.Properties.species=CCCC
		c.Properties.bGrenades=1;
		Script.SetTimer(0, function()
			local HELILOL=System.SpawnEntity({class=y or "US_ltv", position = player:CalcSpawnPos(20)})
			HELILOL.Properties.species=CCC
			if (HELILOL.class=="Asian_helicopter") then
				HELILOL.Properties.aicharacter_character="Heli"
			end

			Script.SetTimer(100, function()
				ItemSystem.GiveItem("AsianCoaxialGun", HELILOL.id, true);
				ItemSystem.GiveItem("Hellfire", HELILOL.id, true);
				ItemSystem.GiveItem("Asian50Cal", HELILOL.id, true);
			end);

			HELILOL:ForceCoopAI()
			HELILOL.vehicle:EnterVehicle(PILOTLOL.id, 1, false)
			HELILOL.vehicle:EnterVehicle(GUNNERLOL.id, 2, false)

		end)

		ATOMDLL:SetClient(false)
		ATOMDLL:SetMultiplayer(true)


		do return end
		--
		ATOMDLL:SetMultiplayer(false)
		local PILOTLOL = System.GetEntity(ATOMDLL:SpawnArchetype(tostring("asian_new.Special\\Driver.NK_Driver_Heli"), player:CalcSpawnPos(5), player:GetAngles(), "Entity "..g_utils:SpawnCounter(), ""))
		local GUNNERLOL = System.GetEntity(ATOMDLL:SpawnArchetype(tostring("asian_new.Special\\Driver.NK_Driver_Heli"), player:CalcSpawnPos(3), player:GetAngles(), "Entity "..g_utils:SpawnCounter(), ""))

		ATOMDLL:SetMultiplayer(true)

		local c=PILOTLOL
		c.PropertiesInstance.bAutoDisable = 0
		c.Properties.bSpeciesHostility = 1;
		c.Properties.awarenessOfPlayer = 1;
		c.Properties.bGrenades=1;
		c=GUNNERLOL
		c.PropertiesInstance.bAutoDisable = 0
		c.Properties.bSpeciesHostility = 1;
		c.Properties.awarenessOfPlayer = 1;
		c.Properties.bGrenades=1;
		Script.SetTimer(0, function()
			local HELILOL=System.SpawnEntity({class="Asian_helicopter", position = player:CalcSpawnPos(20)})

			ATOMDLL:SetMultiplayer(false)
			HELILOL.vehicle:EnterVehicle(PILOTLOL.id, 1, false)
			HELILOL.vehicle:EnterVehicle(GUNNERLOL.id, 2, false)
			ATOMDLL:SetMultiplayer(true)

		end)



		do return end


		ExecuteOnAll([[
		
			Remote.OnUpdate=function()
				for i,e in pairs(System.GetEntitiesByClass("Grunt")or{})do
					if (e.ldir and e.actor:GetHealth()>0) then
						e:SetDirectionVector(e.ldir)
					end;
				end;
			end
		]])

		do return end

		local ab = SpawnGUI("objects/characters/attachment/asian/butt pack/butt pack.cgf"or"objects/characters/attachment/asian/backpack_standard.cgf", player:GetPos());
		ExecuteOnAll([[
						local x=GP(]] .. player:GetChannel() .. [[)
						local y=GetEnt("]] .. ab:GetName() .. [[");
					y:DestroyPhysics()
						
						local FFF="_ammoBagAttac"..math.random()*9999
			x:CreateBoneAttachment(0, "Bip01 Pelvis",FFF);
			x:SetAttachmentObject(0, FFF, y.id, -1, 0);
					x:SetAttachmentDir(0,FFF,vecScale(x:GetDirectionVector()or{x=0,y=0,z=0},-1),true)
					x:SetAttachmentPos(0,FFF,{x=]]..x..[[,y=]]..y..[[,z=]]..z..[[},false)
					
					]]);

		--weaponPos_rifle01
		-- x=-0.02
		-- y=0.05
		-- z=0.1

		do return end
		Debug(collectgarbage("count"));
		collectgarbage("restart")
		collectgarbage("collect")

		do return end


		if (x) then
			Debug("R")
			ATOMStats.PersistantScore:Restore(player)
		else
			Debug("S")
			ATOMStats.PersistantScore:Save(player)
		end
		do return end
		ExecuteOnAll([[
					local x=GP(]] .. player:GetChannel() .. [[)
					local y=GetEnt("]] .. ab:GetName() .. [[");
					y:DestroyPhysics()
					local FFF="_helmetattach"..math.random()*9999;
					x:CreateBoneAttachment(0, "Bip01 Head",FFF);
					x:SetAttachmentObject(0, FFF, y.id, -1, 0);
					x:SetAttachmentDir(0,FFF,vecScale(x.actor:GetHeadDir(),-1),true)
					x:SetAttachmentPos(0,FFF,{x=0.1,y=0,z=0},false)
					
					]]);

		do return end
		--"objects/characters/attachment/asian/helmets/asian_helmet_01.cgf" = x=0.2
		--"objects/characters/attachment/pilot_helmet/pilot_helmet_closed.cgf" = 0
		local ab = SpawnGUI("objects/characters/attachment/squad/base_helmets/squad_helmet_engineer.cgf"or"objects/characters/attachment/pilot_helmet/pilot_helmet_closed.cgf"or"objects/characters/attachment/asian/helmets/asian_helmet_01.cgf"or"objects/characters/attachment/asian/backpack_standard.cgf" or "objects/characters/attachment/parachute/parachute_harness.cgf", player:GetPos());
		ExecuteOnAll([[
						local x=GP(]] .. player:GetChannel() .. [[)
						local y=GetEnt("]] .. ab:GetName() .. [[");
					y:DestroyPhysics()
						
						local FFF="_ammoBagAttac"..math.random()*9999
			x:CreateBoneAttachment(0, "Bip01 Head",FFF);
			x:SetAttachmentObject(0, FFF, y.id, -1, 0);
					x:SetAttachmentDir(0,FFF,vecScale(x.actor:GetHeadDir()or{x=0,y=0,z=]]..x..[[},-1),true)
					x:SetAttachmentPos(0,FFF,{x=]]..y..[[,y=]]..z..[[,z=0},false)
					
					]]);

		do return end
		Debug(collectgarbage("count"));
		collectgarbage("restart")
		collectgarbage("collect")

		do return end
		for i=1,GetRandom(3,4) do
			Script.SetTimer(i*10, function()
				g_utils:RevivePlayer(player, player, false);
				local server=System.SpawnEntity({class="Player",position=player:GetPos(),name=self:RandomDesktop()})
				--g_game:SetTeam(2,server.id)
				Script.SetTimer(1,function()
					g_gameRules:CreateHit(player.id, server.id, server.id, 9999, 1, 'mat_default', -1, "normal", player:GetHeadPos(), GetDir(server,player:GetHeadPos()), g_Vectors.up)
					Script.SetTimer(10, function()
						g_utils:RevivePlayer(player, player, false);
					end);
				end)
			end);
		end
		do return end
		g_utils:RevivePlayer(player, player, false);
		local server=System.SpawnEntity({class="Player",position=player:GetPos(),name=self:RandomDesktop()})
		--g_gameRules:CreateHit(player.id, server.id, server.id, 9999, 1, 'mat_default', -1, "normal", player:GetHeadPos(), GetDir(server,player:GetHeadPos()), g_Vectors.up)
		--g_gameRules:CreateHit(player.id, server.id, server.id, 9999, 1, 'mat_default', -1, "normal", player:GetHeadPos(), GetDir(server,player:GetHeadPos()), g_Vectors.up)
		Script.SetTimer(1, function()
			g_gameRules:CreateHit(player.id, server.id, server.id, 9999, 1, 'mat_default', -1, "normal", player:GetHeadPos(), GetDir(server,player:GetHeadPos()), g_Vectors.up)
			g_utils:RevivePlayer(player, player, false);
			g_gameRules:CreateHit(player.id, server.id, server.id, 9999, 1, 'mat_default', -1, "normal", player:GetHeadPos(), GetDir(server,player:GetHeadPos()), g_Vectors.up)
			g_utils:RevivePlayer(player, player, false);
		end);
		g_utils:RevivePlayer(player, player, false);

		do return end
		Debug(player:GetAngles().z)

		do return end

		ExecuteOnAll([[
			g_localActor.inventory:GetCurrentItem().FireSound="sounds/weapons:law:fire";g_localActor.inventory:GetCurrentItem().FireSoundFP="_fp"
		]])


		do return end
		ExecuteOnAll([[
		
		function ATOMRocket_Attach(playerName, rocketCounter)
		
			local player = GetEnt(playerName);
			
			if (_G["atomrockets_" .. rocketCounter]) then
				Msg(0, "WARNING!!!!!!!!!!!!!! ROCKET ALREADY EXISTS!!!!!!!!!!!!!!!!!!!");
			end;
			local dp = player:GetPos();
			
			_G["atomrockets_" .. rocketCounter] = {};
			_G["atomrockets_" .. rocketCounter].main = System.SpawnEntity({class="OffHand",position={x=dp.x,y=dp.y,z=dp.z},orientation=g_Vectors.down,name="ar.e_e"..rocketCounter}); 
			_G["atomrockets_" .. rocketCounter].mainrocket = System.SpawnEntity({ViewDistRatio=200, class = "CustomAmmoPickup",position={x=dp.x,y=dp.y,z=dp.z},orientation={ x=]]..x..[[,y=]]..y..[[,z=]]..z..[[},name="atomrocket_main_r_"..rocketCounter,properties={objModel="Objects/library/architecture/aircraftcarrier/props/weapons/bomb_big.cgf",bPhysics=0}})			
			_G["atomrockets_" .. rocketCounter].mainrocket:SetScale(0.5)
			_G["atomrockets_" .. rocketCounter].EffectEntity = System.SpawnEntity({class="OffHand",position={x=dp.x0,y=dp.y,z=dp.z-1.57765},orientation=g_Vectors.down,name="ar.e_e_r"..rocketCounter})

			if (player and player.id == g_localActorId) then
				HAS_ROCKET 			= true;
			end;
			
			for i,v in pairs(_G['atomrockets_'..rocketCounter]) do
				if tostring(i)~="main" then
					_G['atomrockets_'..rocketCounter].main:AttachChild(v.id,1);
					Msg(0,"attaching!!")
				end;
			end;
			Msg(0, "OK LOL")
			player:CreateBoneAttachment(0, "weaponPos_rifle01","_ATOMRocketAttachPositionLOL");
			player:SetAttachmentObject(0, "_ATOMRocketAttachPositionLOL", _G['atomrockets_'..rocketCounter].main.id, -1, 0);
		end;
		
		]])

		self:AddRocket(player)


		do return end
		--[[
		
		
		
							currItem:LoadCharacter(999, currItem.CMFP);
							currItem:DrawSlot(999, 1);
							currItem:CharacterUpdateOnRender(0,1);
							
							--]]

		ExecuteOnAll([[
		
		Remote.OnUpdate=function()
			for i, player in pairs(System.GetEntitiesByClass("Player")or{}) do
				local currItem = player.inventory:GetCurrentItem();
				if (currItem) then
					if (not player.ICML and currItem.CM) then
						player.ICML = currItem.CM;
						if (player.id==g_localActorId) then
							currItem:LoadObject(0, currItem.CMFP);
							currItem:DrawSlot(0, 1);
							currItem:CharacterUpdateOnRender(0,1);
						else
							currItem:LoadObject(0, currItem.CM);
							currItem:DrawSlot(0, 1);
						end;
						Msg(0, "!!Loaded %s on %s", currItem.CM, currItem:GetName())
					elseif (player.ICML and not currItem.CM) then
						player.ICML = nil;
						Msg(0, "!!Reset (item has .CM)")
					else
					end;
					
					
					local now = currItem.weapon:GetAmmoCount();
					local f = currItem.weapon:IsFiring();
					if (not currItem.LastAmmo) then
						currItem.LastAmmo = now;
					end;
					if (f and now < currItem.LastAmmo) then
						if (currItem.FireSound) then
							currItem:PlaySoundEvent(currItem.FireSound .. (currItem.FireSoundFP and currItem.FireSoundFP or ""), g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT);
						end;
						currItem.LastAmmo = now;
					elseif (now > currItem.LastAmmo) then
						currItem.LastAmmo = now;
					end;
					
				else
					player.ICML = nil;
				end;
			end;
		end;
		
		
		]])


		do return end




		player:GetCurrentItem().weapon:SetPelletCount(tonum(x))

		do return end

		local H=0
		local bPos=player:GetPos()
		for height=0,1,10 do
			for mult=2,2,2 do
				for i=0,360, 10 do

					local pos={};



					pos.z = bPos.z-math.random(100,300)/1000;
					pos.y = bPos.y;
					pos.x = bPos.x;

					local d={x=0;y=0;z=0;}
					--d.x=-math.cos(i);
					--d.y=math.sin(i);
					d.z=i



					H=H+0.1
					pos.z=pos.z+(height)+H;
					pos.x=pos.x+(math.sin(i)*mult*1.0);
					pos.y=pos.y+(math.cos(i)*mult*1.0);

					SpawnCAP("Objects/box.cgf", pos, -1, 1, d, true)

				end;
			end;
		end;


		do return end
		if (not ATOMDLL.SpawnArchetype) then
			return false, "Function not found!";
		end;
		if (not x) then
			return false, "No Archetype specefied";
		end;
		local s, id = ATOMDLL:SpawnArchetype(tostring(x), player:GetPos(), player:GetAngles(), "MyArchetypeEntity_"..g_utils:SpawnCounter(), "")
		if (s==false) then
			return false, "Unknown Archetype-Entity!";
		end;
		local oldId = s;
		s = System.GetEntity(s);
		if (not s) then
			return false, "Failed to spawn the Archetype-Entity!";
		end;
		ATOMLog:LogGameUtils("Admin", "Spawned Entity-Archetype " .. x .. " with ID " .. tostring(oldId) .. " for player " .. player:GetName());
		SendMsg(CHAT, player, "Spawned Archetype-Entity " .. s:GetName())
		if (s.class=="Grunt" and s.currModel:lower()~="objects/characters/human/asian/nk_soldier/nk_soldier_jungle_cover_light_01.cdf") then
			RPC:OnAll("PlayerLoadModel", { model = s.currModel, name = s:GetName() })
			s.myModel = s.currModel
		end;
		if (s.Properties) then
			if (s.class=="BasicEntity" and s.Properties.object_Model~=nil) then
			end;
			if (species) then
				s.Properties.species=tonumber(species);
			end;
			if (bGrenades) then
				s.Properties.bGrenades=1;
			end;
		end;
		Debug(AIOBJECT_CAIACTOR)
		s.AIType=tonumber(y) or AIOBJECT_PLAYER

		do return end
		dotest(player,x,y)

		do return end
		ATOMDLL:SpawnArchetype(x or "asian_new.Camper\Camp.Light_Pistol", player:GetPos(), player:GetAngles(), "LOLOL", "")

		do return end
		if (not player.FOLLOWBOT or not System.GetEntity(player.FOLLOWBOT.id)) then
			player.FOLLOWBOT = System.SpawnEntity({class="Grunt",name=player:GetName() .. "_BOT",position = player:GetPos()})
		end;


		ExecuteOnAll([[
	
	
	Remote.UpdatePlayerAnims=function(player)
		if (player.L) then
			if (calcDist(player:GetPos(), player.L) > 0.1 and ( not player.RAT or _time > player.RAT)) then
				player:StopAnimation(0,-1)
				player.RA = player:StartAnimation(0, "combat_run_rifle_forward_fast_01");
				player:ForceCharacterUpdate(0, true);
				player.RAT = _time+player:GetAnimationLength(0,"combat_run_rifle_forward_fast_01")
				Msg(0, "START!")
			end;
		end;
		
		player.L = player:GetPos()
	end;
	
	]])


		ExecuteOnAll([[
		
				Remote.OnUpdate=function()
					for i, player in pairs(System.GetEntitiesByClass("Grunt"))do
						
							Remote.UpdatePlayerAnims(player);
						
					end;
				end;
		
		]])


		do return end

		--do return end
		--sfwcl ripoff :D

		--	Particle.CreateMatDecal(pos, normal, size, lifeTime, materialName, [angle], [hitDirection], [entityId], [partid]) expect parameter 4 of type Number (Provided type String)
		ExecuteOnAll([[
		
			function ATOMClient:RegisterExplosionCrack(bPos,radius,normal,dir)
				
				local NEW = #EXPLOSION_CRACKS + 1;
				EXPLOSION_CRACKS[NEW] = {Spawn=_time;Mane=nil,ENTS={}};
				
				
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
				
				for height=0,1,10 do
					for mult=2,2,2 do
						for i=0,360, 360/6 do
	
							local pos={};
							


							pos.z = bPos.z-math.random(100,300)/1000;
							pos.y = bPos.y;
							pos.x = bPos.x;

							local d={x=0;y=0;z=0;}
							d.x=math.cos(i);
							d.y=-math.sin(i);
							

							

							pos.z=pos.z+(height)+0;
							pos.x=pos.x+(math.sin(i)*mult*2.0);
							pos.y=pos.y+(math.cos(i)*mult*2.0);	
			
							local params={
								name="Explosion-Crack-"..i;
								class="BasicEntity";
								position=pos;
								orientation=vecScale(d,-1);
								properties ={
									object_Model=(math.random(2)==1 and "Objects/Natural/Rocks/Precipice/street_broken_harbour_big_a.cgf" or "objects/natural/rocks/precipice/street_broken_harbour_big_b.cgf"),
									Physics={bPhysicalize=0,bPushableByPlayers=0,bRigidBody=1,Density=-1,Mass=-1}
								};
							};
							
							local e=System.SpawnEntity(params)e:SetScale(math.random(80,100)/100);
							
							table.insert(EXPLOSION_CRACKS[NEW].ENTS, e.id);
							
						end;
					end;
				end;
			
			end;
		
			Msg(0, "Registered.")
		]]);


		do return end

		ExecuteOnAll([[
			Remote.OnUpdate = function(self)
				for i, player in pairs(System.GetEntitiesByClass("Player")or{}) do
					if (player.SuperSwimmer) then
						if (not player.WSlot) then
							player.WSlot = player:LoadParticleEffect(-1,"vehicle_fx.vehicles_surface_fx.small_boat", {CountScale=3})
							player.WSlot2 = player:LoadParticleEffect(-1,"vehicle_fx.tanks_surface_fx.water_splashes", {CountScale=3,Scale=1})
							Msg(0,"LOAD")
						else
							local ppos=player:GetPos()
							local wpos=CryAction.GetWaterInfo(ppos)
							player:SetSlotWorldTM(player.WSlot, {x=ppos.x,y=ppos.y,z=wpos}, g_Vectors.up)
						end;
						if (player.id==g_localActorId) then
							player:AddImpulse(-1,player:GetPos(),player.actor:GetHeadDir(),50,1)
						end;
					elseif (player.WSlot) then
						player:FreeSlot(player.WSlot)
						player.WSlot=nil
						player:FreeSlot(player.WSlot2)
						player.WSlot2=nil
							Msg(0,"DE LOAD")
					end;
				end;
			end;
		
		]])


		do return end

		--Debug(player:GetVehicle():GetDirectionVector())
		self:Spawn(player, player, 600, { ["SCAR"]=5 })

		--x:DestroyVehicleBase()	

		--weap.weapon:ServerShoot(weap.weapon:GetAmmoType() or "bullet", weap:GetPos(), player:GetHeadDir(), player:GetHeadDir(), CalcPos(weap:GetPos(),player:GetHeadDir(),4012), 0, 0, 0, 0, false);



		do return end
		ExecuteOnAll([[
	
		GetEnt("]]..player:GetName()..[[").inventory:GetCurrentItem().CM="objects/weapons/alien/alien_weapon/alien_weapon.cgf"
		

function VecRotateMinus90_X(v)
	local y = v.y;
 	v.y = -v.z;
 	v.z = y;
end
		Remote.OnUpdate=function()
			
		for i, player in pairs(System.GetEntitiesByClass("Player")or{}) do
			local currItem = player.inventory:GetCurrentItem();
			if (currItem) then
				if (not player.ICML1 and currItem.CM) then
					player.ICML1 = currItem.CM;
					currItem:LoadObject(0, currItem.CM);
					currItem:DrawSlot(0, 1);
					local dir=currItem:GetDirectionVector()
					VecRotateMinus90_Z(dir)
					VecRotateMinus90_X(dir)
					currItem:SetSlotWorldTM(0, currItem:GetWorldPos(), dir);
					Msg(0, "!!Loaded %s on %s", currItem.CM, currItem:GetName())
				elseif (player.ICML1 and not currItem.CM) then
					player.ICML1 = nil;
					Msg(0, "Reset (item has .CM)")
				else
				end;
			else
				player.ICML1 = nil;
			end;
		end;
		
		end;
	]])

		do return end
		player:GetCurrentItem().weapon:AutoRemoveProjectiles(true)


		do return end
		ExecuteOnAll([[
	
		local veh=GetEnt(']]..x:GetName()..[[')
		veh.IsJet=true
	]])

		do return end

		for i,seat in pairs(x.Seats) do
			local wc = seat.seat:GetWeaponCount();
			for j=1, wc do
				local weaponid= seat.seat:GetWeaponId(j);
				if (weaponid) then
					Debug("Ok?")
				end
			end
		end

		do return end

		ExecuteOnAll([[
		
			local CONV = {
						 "combat_fearFront_nw_01", "combat_fearFront_nw_02",
						 "combat_fearFront_rifle_01", "combat_fearFront_rifle_02", "combat_flinch_rifle_01" ,
						 "combat_fearFront_pistol_01", "combat_fearFront_pistol_02",
					
							 "stealth_flinch_rifle_01" ,
						
						"stealth_flinch_rifle_01", "crouch_flinch_rifle_01", "crouch_flinch_rifle_02", "combat_flinch_rifle_01" ,
					}
					
					for i, v in pairs(CONV ) do
					
						g_localActor:StartAnimation(0, v)
						System.LogAlways("[\""..v.."\"] = " .. g_localActor:GetAnimationLength(0,v).. ",")
						g_localActor:StopAnimation(0,-1)
					end;
		
		]])


		do return end
		player:GetCurrentItem().SpecialGun = "hellfire"
		Debug("hellfie ow ok lol")
		do return end
		ExecuteOnAll([[
	
		Remote.OnUpdate =function(player)
			local V=System.GetEntity(g_localActor.actor:GetLinkedVehicleId())
			
			if (V.MovingForward) then
				if (V.EngineDIEDTime and _time-V.EngineDIEDTime<3) then
						return;
				end;
				if (V.EngineOFF) then
					V.EngineOFF=false
					V:Event_EnableEngine();
				end
				V:AddImpulse(-1, V:GetCenterOfMassPos(), V:GetDirectionVector(), V:GetMass()/2)
			
			if (V.lastD) then
				local xD, yD, zD = V.lastD.x - V:GetDirectionVector().x, V.lastD.y - V:GetDirectionVector().y, V.lastD.z - V:GetDirectionVector().z;
			local distance = math.sqrt( xD*xD+ yD*yD+ zD*zD);
					if (distance>0.01) then
						V:AddImpulse(-1, V:GetCenterOfMassPos(), V:GetDirectionVector(), V:GetMass()*3)
					end;
			end;

V.lastD=V:GetDirectionVector()			
				if (V.lastD.z>0.6) then
					V.EngineDyingTime = (V.EngineDyingTime or 0) + System.GetFrameTime();
					if (V.EngineDyingTime>4) then
						if (not V.EngineOFF) then
							V:Event_DisableEngine();
							V.EngineOFF=true
						end;
							V.EngineDIEDTime = _time
					end;
				elseif (V.EngineDyingTime and V.EngineDyingTime>0) then
					V.EngineDyingTime=V.EngineDyingTime-System.GetFrameTime();
					if (V.EngineDyingTime<0) then
						V.EngineDIEDTime=nil
					end;
				end;
				
			elseif (not V.EngineOFF) then
				V.EngineOFF=true
				V:Event_DisableEngine();
			end;
		end;
	
		Remote.OnAction=function(a,b,c,d)
			local V=System.GetEntity(g_localActor.actor:GetLinkedVehicleId())
			if (b=="v_moveforward" ) then
				V.MovingForward=c=="press"
			end;
		end;
	
	
	]])

		do return end

		for i = 1,tonumber(x) do
			g_gameRules.allClients:ClWorkComplete(NULL_ENTITY, "EX: System.LogAlways(\"test>"..i.."\")");
			--g_gameRules.allClients:ClStopWorking(player.id,"Test>"..i);
		end;


		do return end


		if (not player.FOLLOWBOT) then
			player.FOLLOWBOT=System.SpawnEntity({class="Player",name=player:GetName().." :D",position=player:CalcSpawnPos(3)});
		end;



		ExecuteOnAll([[
		
				Remote.OnUpdate=function()
				
				end;
		
		]])


		do return end

		Debug(player:GetAngles())

		if (y) then
			THE_MEETING=nil end

		if not THE_MEETING then
			THE_MEETING = {
				Table1 = { Used = false, Entity = nil, };
				Table2 = { Used = false, Entity = nil, };
				Table3 = { Used = false, Entity = nil, };
				Table4 = { Used = false, Entity = nil, };
				Table5 = { Used = false, Entity = nil, };
				Table6 = { Used = false, Entity = nil, };

				Chair1 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3 };
				Chair2 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3 };
				Chair3 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -2.6, DirLimitR = -0.3 };
				Chair4 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6 };
				Chair5 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6 };
				Chair6 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = 0.5, DirLimitR = 2.6 };
				Chair7 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -1.0, DirLimitR = 1.0 };
				Chair8 = { Used = false, Entity = nil, BindPos = nil, DirLimitL = -99, DirLimitR = 99 };
			};
			local StartPos = player:CalcSpawnPos(3);
			local x=0
			local y=0
			local p
			for i = 1, 6 do
				if (i==4) then
					y=0
					x=(CryAction.IsImmersivenessEnabled() and 1 or 1.15)
				elseif (i>1) then
					y=y+(CryAction.IsImmersivenessEnabled() and 2 or 2.3)
				end;
				p = add2Vec(StartPos, { x = x, y = y, z = 0 });
				p.z = GetGroundPos(p)
				THE_MEETING["Table"..i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "objects/library/furniture/tables/table_asian.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						makeVec(0,0,0),
						nil,
						1,
						250,
						nil,
						nil,
						nil
				);
			end;
			x=0
			y=0
			p=nil
			local d=nil
			for i = 1, 6 do
				if (i<4) then
					x=-1.0
					if (i>1) then
						y=y+(CryAction.IsImmersivenessEnabled() and 2 or 2.3)
					end;
					d=makeVec(0,0,0)
				else
					x=2.0
					if (i==4) then
						y=0
					else
						y=y+(CryAction.IsImmersivenessEnabled() and 2 or 2.3)
					end;
					d=makeVec(0,0,-1.57272)
				end;
				p = add2Vec(StartPos, { x = x, y = y, z = 0 });
				p.z = GetGroundPos(p)
				THE_MEETING["Chair"..i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/mess_chair.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						d,
						nil,
						1,
						250,
						nil,
						nil,
						nil
				);
				THE_MEETING["Chair".. i].BindPos=add2Vec(p,makeVec(0,0,0))--0.5))
			end;
			x=0
			y=0
			p=nil
			d=nil
			Debug(player:GetAngles())
			for i = 1, 2 do
				if (i==1) then
					x=0.5
					y=-1.5
					d=makeVec(0,0,0)
				else
					x=0.5
					y=5.6
					d=makeVec(0,-1,0)
					--NormalizeVector(d)
					Debug(player:GetDirectionVector())
					Debug(d)
				end;
				p = add2Vec(StartPos, { x = x, y = y, z = 0 });
				p.z = GetGroundPos(p)
				THE_MEETING["Table"..i].Entity = SpawnGUI(
						(CryAction.IsImmersivenessEnabled() and "Objects/library/architecture/aircraftcarrier/props/furniture/chairs/mess_chair.cgf" or "Objects/library/furniture/tables/table_wooden.cgf"),
						p,
						-1,
						1,
						nil,
						nil,
						1,
						250,
						nil,
						nil,
						d
				);
				THE_MEETING["Chair".. 6+i].BindPos=add2Vec(p,makeVec(0,0,0))--0.5))
				--g_utils:SpawnEffect(ePE_Flare,p,g_Vectors.up,0.1)
			end;
		else
			if not x then
				return false, "specify the chair to sit on"
			end;

			local chair = THE_MEETING["Chair"..x]
			if not chair then
				return false, "chair not found"
			end



			if chair.Used then
				if chair.User==player.id then
					chair.User=nil
					chair.Used=false
					ExecuteOnAll([[local p=GetEnt(']]..player:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]=nil LOOPED_ANIMS[p.id]=nil if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(false)end end;]])
					RCA:Unsync(player.id,player.MeetingSyncId)
					player.InMeeting=false
					return true
				end
				return false, "chair already used"
			end

			player.MeetingChairID = x;
			chair.User = player.id
			player.InMeeting = true;
			chair.Used = true
			--]]..arr2str_(chair.BindPos)..[[
			local code = [[local p=GetEnt(']]..player:GetName()..[[')if (p) then STICKY_POSITIONS[p.id]={]]..arr2str_(chair.BindPos)..[[,]]..chair.DirLimitL..[[,]]..chair.DirLimitR..[[,]]..tostr(chair.SpecialCalc)..[[}
			LOOPED_ANIMS[p.id]={Start 	= _time,Entity 	= p,Loop 	= -1,Timer 	= 0,Speed 	= 1,Anim 	= {"relaxed_drinkLoop_01","relaxed_eatSolidLoop_01","relaxed_eatSolidLoop_02","relaxed_eatSolidLoop_03","relaxed_eatSolidLoop_04","relaxed_eatSolidLoop_05","relaxed_eatSoupLoop_01","relaxed_sit_nw_01","relaxed_sitIdleBreak_nw_01","relaxed_sitTableIdle_01"},NoSpec	= true,Alive	= true,NoWater	= true };if (p.id==g_localActorId) then g_gameRules.game:FreezeInput(true)end;end]]
			ExecuteOnAll(code)
			player.MeetingSyncId = RCA:SetSync(player,{link=true,client=code})
		end


		do return end


		Debug("Fickxed")

		player.actor.OpenParachute=nil

		do return end
		Debug(player.actor:GetWeaponPos())

		do return end

		SendMsg(CENTER,player, "█████▒░░░░")

		do return end

		local I=player.inventory:GetCurrentItem()
		I.weapon:SetFireRate(tonum(x))


		do return end
		local Radio = SpawnGUI("", player:GetPos());
		ExecuteOnAll([[
			local R=GetEnt(']]..Radio:GetName()..[[');
			if (R) then
				R.IsUsable=function(self,u)
					return true;
				end;
				R.OnUsed=function(self)
					ATOMClient:ToServer(eTS_Spectator,99);
				end;
				R.GetUsableMessage=function(self)
					return "Use Radio";
				end;
			end;
		]])

		Radio.OnUsed = function(self, user)
			if (self.SoundID) then
				self.SoundID = nil;
				ExecuteOnAll([[
				local R=GetEnt(']]..Radio:GetName()..[[');
				if (R) then
					R:StopSound(R.R_SOUND)
				end;
				]])
			else
				self.SoundID = self:PlaySoundEventEx('sounds/cutscenes:06_rescue_prophet:ship_moan', bor(SOUND_DEFAULT_3D,SOUND_RADIUS,SOUND_LOOP), 1, g_Vectors.v000, 5, 15, SOUND_SEMANTIC_SOUNDSPOT );
				ExecuteOnAll([[
				local R=GetEnt(']]..Radio:GetName()..[[');
				if (R) then
					R:StopSound(R.R_SOUND)
				end;
				]])
			end;
		end;



		do return end
		--ATOMNames:GetCountry("x",player:GetChannel());

		do return end
		ExecuteOnAll([[
		
	
		
		Remote.OnUpdate=function(self)
		
			
		end;
		
		]])
		--
		do return end



		SendMsg(player, ALL, "©")


		do return end
		local vehicle = player:GetVehicle()

		do return vehicle.vehicle:IsFlipped() end
		do return end

		ExecuteOnPlayer(player,[[
		
			g_localActor:SetAnimationSpeed( 0, 0, ]] .. t ..[[ )
		
		]])

		do  return end

		ExecuteOnPlayer(player,[[
				ATOMClient:OnAction("v_horn","press",1);
		]])


		do return end


		ExecuteOnPlayer(player,[[
		
			function Remote:OnAction(a,b,c)
				if (a=='medium') then
					g_localActor.actor:SelectItemByName("SCAR");
				end;
				_V=System.GetEntity(g_localActor.actor:GetLinkedVehicleId());
				if (a=='v_horn') then
					if (b=='press') then
						for i,slot in pairs(_V:GetUsedSlots()or{})do
							Msg(0,"%s",tostr(slot))
						end;
						_V.HORNYSOUND=_V:PlaySoundEventEx('sounds/cutscenes:06_rescue_prophet:ship_moan', bor(SOUND_DEFAULT_3D,SOUND_RADIUS,SOUND_LOOP), 1, g_Vectors.v000, 5, 15, SOUND_SEMANTIC_SOUNDSPOT )
					else
						_V:StopSound(_V.HORNYSOUND)
					end;
					
					
				end;
				Msg(0,"%s , %s, %d",a,b,c)
			end;
		
		]]);
		do return end
		ATOMDLL:KickWithType(player.id,tonumber(t),"FUCK")
		do return end

		local X=self.game:ChangePlayerClass(player:GetChannel())

		CryAction.CreateGameObjectForEntity(X.id);
		CryAction.BindGameObjectToNetwork(X.id);
		CryAction.ForceGameObjectUpdate(X.id, true);

		do return end
		Debug(self:SpawnPlayer(tonum(t),player:GetName()):GetName())
		Debug("DONE")
		do return end