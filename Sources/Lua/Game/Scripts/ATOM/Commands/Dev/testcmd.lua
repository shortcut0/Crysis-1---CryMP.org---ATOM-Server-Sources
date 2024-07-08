
RegisterEvent("OnPlayerTick", function(player)

	if (player.builder_enabled) then
		if (player._currObj) then
			System.RemoveEntity(player._currObj.id)
		end;
		
		
		local FIXED_POS = player:CalcSpawnPos(3,-1);
		
		FIXED_POS = makeVec(
			round(FIXED_POS.x),
			round(FIXED_POS.y),
			round(FIXED_POS.z)
		)
		
		player._currObj = SpawnGUINew({
			Model = "Objects/library/architecture/nodule/wood_support_wall.cgf",
			Pos = FIXED_POS or player:CalcPos(3),
			Dir = player:GetDirectionVector(),
			bStatic = true,
			Mass = -1
		})
		local obj = player._currObj 
		
		
		obj:SetWorldPos(FIXED_POS);
		obj:AddImpulse(-1,makeVec(),makeVec(),1,1);
	
	end;
end);



ATOMBoidsOLD = {}
ATOMBoidsOLD.ActiveFlocks = {}
ATOMBoidsOLD.Init = function(self)
	RegisterEvent("OnUpdate", self.Update, "ATOMBoidsOLD")
end
ATOMBoidsOLD.UpdateFlock = function(self, hCreature)

	local hMounted = hCreature:GetMounted()
	if (hMounted) then
		if (hMounted:IsDead() or not System.GetEntity(hMounted.id)) then
			return self:Dismount(hCreature, hMounted)
		end
	end

	local hEntity = hCreature.hEntity
	local vLookAt = hEntity.LAST_LOOK_DIR
	if (not hCreature.IS_FALLING) then
		if (hCreature.WAS_FALLING) then
			--	Msg(0,"landed")
			hEntity.LAST_LOOK_DIR = hEntity:GetAngles()
			hEntity.LAST_LOOK_DIR.x = 0
			hEntity.LAST_LOOK_DIR.y = 0
			vLookAt = hEntity.LAST_LOOK_DIR
		end
		if (vLookAt) then
			--	Msg(0,"dirok")
			hEntity:SetWorldAngles(vLookAt)
		end
	else
		hCreature.MOVE_GOAL = nil
	end

	local aProps = hCreature.Properties
	local vPos = hEntity:GetPos()
	local vGoal = hCreature.MOVE_GOAL
	if (not vGoal) then
		if (not CryAction.IsServer() or not self:Think(hCreature)) then
			return
		else
			vGoal = hCreature.MOVE_GOAL
			if (not vGoal) then
				return
			end
		end
	end

	-----------
	if (not hCreature.MOVEMENT_DISTRIBUTED) then
		return
	end

	-----------
	local iSpeed = (hCreature.MOVE_SPEED or math.frandom(aProps.MoveSpeed[1], aProps.MoveSpeed[2]))
	hCreature.MOVE_SPEED = iSpeed

	-----------
	local vDir = GetDir(vGoal,vPos, 1)
	local vWaterCheck = {
		x = vPos.x + vDir.x * 2,
		y = vPos.y + vDir.y * 2,
		z = vPos.z + vDir.z * 2,
	}
	local iWater = CryAction.GetWaterInfo(vWaterCheck)
	local bInWater = (iWater > (vWaterCheck.z - 0.5))

	if (vGoal and vector.distance(vPos, vGoal) > 1 and not bInWater) then

		if (timerexpired(hCreature.GOAL_REACHED, hCreature.GOAL_REACHED_REST)) then
			hEntity.LAST_LOOK_DIR = Dir2Ang(vDir)
			hCreature.LAST_MOVE_TIMER = timerinit()

			ScaleVectorInPlace(vDir, iSpeed)
			hEntity:SetPhysicParams(PHYSICPARAM_VELOCITY, { v = vDir, w = vDir })
		end
	else
		hCreature.MOVE_GOAL = nil
		hCreature.GOAL_REACHED = timerinit()
		hCreature.GOAL_REACHED_REST = math.random(0, 2.5)
	end

	if (CryAction.IsClient()) then
		return
	end

end

ATOMBoidsOLD.DistributeMovement = function(self, hCreature)

	local hEntity = hCreature.hEntity
	local vGoal = hCreature.MOVE_GOAL

	if (hCreature.DISTRIBUTION_TIMER) then
		Script.KillTimer(hCreature.DISTRIBUTION_TIMER)
	end

	hCreature.DISTRIBUTION_TIMER = Script.SetTimer(100, function()
		hCreature.DISTRIBUTION_TIMER = nil
		hCreature.MOVEMENT_DISTRIBUTED = true
		hCreature.NETSYNC = [[
		local hEnt = GetEnt('{name}')
		Msg(0, "Synced %s", hEnt:GetName())
		]]
		self:SyncData(hCreature)

		Debug("DISTRIBUTE NOW!")
	end)
end

ATOMBoidsOLD.SyncData = function(self, hCreature)

	local hEntity = hCreature.hEntity
	local sData = hCreature.NETSYNC

	local sName = hEntity:GetName()
	local sCode = string.gsuba(sData, {
		{ "{name}", sName }
	})

	if (hEntity.NetSyncID) then
		RCA:StopSync(hEntity, hEntity.NetSyncID)
	end
	hEntity.NetSyncID = RCA:SetSync(hEntity, { client = sCode, link = hEntity.id })
	ExecuteOnAll(sCode)
end

ATOMBoidsOLD.Think = function(self, hCreature)

	hCreature.MOVEMENT_DISTRIBUTED = false

	local hEntity = hCreature.hEntity
	local aProps = hCreature.Properties

	local vPos = hEntity:GetPos()
	local vRHPos = vector.modify(vPos, "z", 0.15)
	local vRHDir = {
		x = math.frandom(-1, 1),
		y = math.frandom(-1, 1),
		z = 0,
	}

	if (aProps.Move3D) then
		vRHDir.z = math.random(-1, 1)
	end

	local iMoveDistance = math.frandom(aProps.StepDistance[1], aProps.StepDistance[2])
	local aRH = RayHit(vRHPos, vRHDir, iMoveDistance, hEntity.id, ent_all - ent_living) or {
	pos = {
		x = vPos.x + vRHDir.x * iMoveDistance,
		y = vPos.y + vRHDir.y * iMoveDistance,
		z = vPos.z + vRHDir.z * iMoveDistance,
	}}

	local iRHWater = CryAction.GetWaterInfo(aRH.pos)
	if (iRHWater < (aRH.pos.z - 0.2)) then
		local aDown = RayHit(vector.modify(aRH.pos, "z", 1), g_Vectors.down, 5, hEntity.id, ent_terrain + ent_static + ent_water)
		if (aDown) then
			local iDownWater = CryAction.GetWaterInfo(vector.modify(aDown.pos, "z", -0.1))
			if (iDownWater < aDown.pos.z) then
				aRH.pos = aDown.pos
			end
		end
	end

	hCreature.MOVE_GOAL = aRH.pos
	self:DistributeMovement(hCreature)

	return true
end
ATOMBoidsOLD.Update = function(self)

	local hEntity
	for i, hCreature in pairs(self.ActiveFlocks) do

		hEntity = hCreature.hEntity
		if (not hEntity or not System.GetEntity(hEntity.id)) then
			self:DisableFlock(hCreature)
		elseif (hCreature.IS_ACTOR) then
			if (hCreature.hEntity:IsDead()) then
				self:DisableFlock(hCreature)
			else
				self:UpdateFlock(hCreature)
			end
		else
			self:UpdateFlock(hCreature)
		end
	end
end

function GetEntityHash(hEntity)
	local sHash = hEntity:GetName()
	for i, aProp in pairs(hEntity["Properties"]or{}) do
		if (not isArray(aProb) and not isFunc(aProp) and not type(aProp) == "userdata") then
			sHash = sHash .. ("[" .. i .. "]" .. "=" .. tostring(aProp))
		end
	end
	hEntity.EntityHash = simplehash.hash(sHash)
	return hEntity.EntityHash
end
function GetEntityByHash(sHash)
	local aEntities = System.GetEntities()
	for i, hEntity in pairs(aEntities) do
		local sEntityHash = GetEntityHash(hEntity)
		if (sEntityHash == sHash) then
			return hEntity
		end
	end
	return
end

NewCommand({
	Name 	= "test",
	Access	= DEVELOPER,
	Console = true,
	Args = {
		--{ "Code", "The lua code you wish to execute", Integer = true, Default = nil };
		--{ "Code", "The lua code you wish to execute", Integer = true, Default = 1 };
	--	{ "Code", "The lua code you wish to execute", Integer = true, Default = 1 };
	};
	Properties = { --█████▒░░░░
		--SendHelp = true;
	
		--RequireVehicle = true;
		Self = 'ATOMExplosives';
	};
	
	func = function(self, player, x,y,z,zz,...)

		if (z) then
			STOP =false
			return
		elseif (y) then
			STOP = true
			return
		end

		local hEntity = System.SpawnEntity({
			class = "BasicEntity",
			name = "Boid_" .. g_utils:SpawnCounter(),
			position = player:CalcSpawnPos(1),
		})
		CryAction.CreateGameObjectForEntity(hEntity.id)
		CryAction.BindGameObjectToNetwork(hEntity.id)
		CryAction.ForceGameObjectUpdate(hEntity.id, true)


		local aProps = {
			Model = "objects/characters/animals/birds/chicken/chicken.chr",
			AnimationSet = {
				Idle = "idle01",
				Walk = "walk_loop",
				Run = "walk_loop",
				Scared = "pickup",
				Fly = "pickup"
			},
			ModelOffSet = {
				z = 0.5,
				x = 0.5,
				y = 0.5
			},
			PlayerOffSet = {
				x = 0,
				y = 0,
				z = 0
			},
			MoveSpeed = { 1, 3 },
			StepDistance = { 5, 8 },
			RestingTime = { 1, 5 },
			RotationLimits = {
				-30,
				60
			},
			SoundEvents = {
				["fall"] = "Sounds/environment:random_oneshots_natural:chicken_throw",
				["idle"] = "Sounds/environment:random_oneshots_natural:chicken_cluck",
				["walk"] = "Sounds/environment:random_oneshots_natural:chicken_run",
				["run"] = "Sounds/environment:random_oneshots_natural:chicken_run",
			}
		}

		if (x == "1") then
			aProps = {

				Model = "objects/characters/animals/Whiteshark/greatwhiteshark.cdf",
				AnimationSet = {
					Idle = "shark_swim_01",
					Walk = "shark_swim_01",
					Run = "shark_swim_01",
					Scared = "shark_swim_bite_01",
					Fly = "shark_swim_01"
				},
				Mass = 100,
				Density = 100,
				ModelOffSet = {
					z = 0.8,
					x = 0.0,
					y = 0.0
				},
				PlayerOffSet = {
					x = 0,
					y = 0,
					z = 0
				},
				MoveSpeed = { 3, 5 },
				StepDistance = { 10, 15 },
				RestingTime = { 1, 3 },
				RotationLimits = {
					-0.3,
					0.85
				},
				Underwater = true,
				Move3D = true,
			}
			Debug("ok")
		end

		ATOMBoids:Create(hEntity, aProps)


		do return end

		local h = System.SpawnEntity({class="BasicEntity",properties={},position =player:GetPos(),name="Mountable_"..g_utils:SpawnCounter()})


		CryAction.CreateGameObjectForEntity(h.id);
		CryAction.BindGameObjectToNetwork(h.id);
		CryAction.ForceGameObjectUpdate(h.id, true);

		h.unpickable=true
		h.OnUse=function(s,user)
			Debug("Okok")

			if (s.hMounted == nil) then
				ExecuteOnAll([[
					ATOMClient.Mountables:Mount(
						ATOMClient.Mountables:GetCreatureA(
							GetEnt(']]..h:GetName()..[[')
						),
						GP(]]..user:GetChannel()..[[)
					)
				]])
				s.hMounted=user
				user.hMount=s
				user.hMountTimer=timerinit()
			elseif (s.hMounted.id == user.id) then
				ExecuteOnAll([[
					ATOMClient.Mountables:Dismount(
						ATOMClient.Mountables:GetCreatureA(
							GetEnt(']]..h:GetName()..[[')
						),
						GP(]]..user:GetChannel()..[[)
					)
				]])
				s.hMounted=nil
				user.hMount=nil
			end
		end

		local vNull = { x = 0, y = 0, z = 0 }
		local fMass = (100)
		local fDensity = (100)

		h.IsMountable = true

		h:Physicalize(0, PE_RIGID, { mass = fMass, density = fDensity })
		h:SetPhysicParams(PHYSICPARAM_SIMULATION, { mass = fMass, density = fDensity })
		h:SetPhysicParams(PHYSICPARAM_VELOCITY, { v = vNull, w = vNull })


		local sparams = [[
		Model = "objects/characters/animals/birds/chicken/chicken.chr",
				AnimationSet = {
					Idle = "idle01",
					Walk = "walk_loop",
					Run = "walk_loop",
					Scared = "pickup",
					Fly = "pickup"
				},
				ModelOffSet = {
					z = 0.5,
					x = 0.5,
					y = 0.5
				},
				PlayerOffSet = {
					x = 0,
					y = 0,
					z = 0
				},
				MoveSpeed = { 1, 3 },
				StepDistance = { 1, 8 },
		]]

		if (x=="1") then
			sparams=[[

				Model = "objects/characters/animals/Whiteshark/greatwhiteshark.cdf",
				AnimationSet = {
					Idle = "shark_swim_01",
					Walk = "shark_swim_01",
					Run = "shark_swim_01",
					Scared = "shark_swim_bite_01",
					Fly = "shark_swim_01"
				},
				Mass = 100,
				Density = 100,
				ModelOffSet = {
					z = 0.8,
					x = 0.0,
					y = 0.0
				},
				PlayerOffSet = {
					x = 0,
					y = 0,
					z = 0
				},
			]]
		end
		if (x=="2") then
			sparams=[[

				Model = "objects/characters/animals/Whiteshark/greatwhiteshark.cdf",
				AnimationSet = {
					Idle = "shark_swim_01",
					Walk = "shark_swim_01",
					Run = "shark_swim_01",
					Scared = "shark_swim_bite_01",
					Fly = "shark_swim_01"
				},
				Mass = 100,
				Density = 100,
				ModelOffSet = {
					z = 0.8,
					x = 0.0,
					y = 0.0
				},
				PlayerOffSet = {
					x = 0,
					y = 0,
					z = 0
				},
			]]
		end

		local s = [[
		local e = GetEnt(']]..h:GetName()..[[')
			ATOMClient.Mountables:Create(e,{
				]]..sparams..[[



			})
for i,v in pairs(e:GetPhysicalStats()) do
Msg(0,i.."="..tostring(v))end


		]]

		Script.SetTimer(1000,function()
		ExecuteOnPlayer(player,s)
		end)
		do return end
		ExecuteOnAll([[

		g_Client:RequestHead(]]..player:GetChannel()..[[,]]..(x or 1)..[[)

		]])


		do return end

		ExecuteOnAll([[

		local headless = "atomobjects/chars/us_nanosuit/nohelmet.cdf"
		g_Client:RequestModel(]]..player:GetChannel()..[[,99,headless,nil,nil,nil,true,false)
		g_Client:RequestHead(]]..(x or 1)..[[)

		]])


		do return end
		do return self:SpawnExplosive(player,x,y) end


		do return end

		local aF=System.GetEntitiesByClass("Civ_car1")
		player.actor:SetSpectatorMode(2, GetRandom(aF).id)
SendMsg(CHAT_ATOM, player, "spactating random vehicle ????")

		do return end
		local aF=System.GetEntitiesByClass("Civ_car1")


		do return end
		ExecuteOnAll([[


		ATOMClient.ClientEvent()














		]])


		do return end

		ExecuteOnAll([[
		Remote.OnUpdate = function()end
		]])
		do return end
		ExecuteOnAll([[
		Remote.OnUpdate = function()

			for i, hPlayer in pairs(System.GetEntitiesByClass("Player")or{}) do

							local hCurrent = hPlayer.inventory:GetCurrentItem()
							if (hCurrent and hCurrent.class == "Fists" ) then

								local iAnimTime = hCurrent:GetAnimationLength(0, ']]..y..[[')
								if (timerexpired(hCurrent.hTimerGrab, ]]..x..[[)) then


									hCurrent:StopAnimation(0,8)
									hCurrent:StopAnimation(0,-1)
									hCurrent:StartAnimation(0, ']]..y..[[')
									hCurrent:SetAnimationTime(0, 0, ]]..z..[[)

									iAnimTime = hCurrent:GetAnimationLength(0, 'on_screen_01')
									hCurrent.hTimerGrab = timerinit() - iAnimTime + 0.1
									Msg(0,"new")

								end
							end


			end

		end
		]])

		do return end

		ExecuteOnAll([[
		STOP_ANIM_OLD = checkVar(STOP_ANIM_OLD, g_localActor.StopAnimation)
		g_localActor.StopAnimation = function(...)
			Msg(0, "from:\n%s",debug.traceback())
			STOP_ANIM_OLD(...)
		end]])




		ExecuteOnAll([[
		STOP_ANIMS_OLD = STOP_ANIMS_OLD or {}

		for i,v in pairs(System.GetEntitiesByClass("Player")) do
			STOP_ANIMS_OLD[v.id] = checkVar(STOP_ANIMS_OLD[v.id], v.StopAnimation)
			v.StopAnimation = function(...)
				Msg(0, "%s:from:\n%s",v:GetName(),debug.traceback())
				STOP_ANIMS_OLD[v.id](...)
			end
		end
		]])


		do return end
		ExecuteOnAll([[



		g_localActor.gameParams.stance[1] =
			{
				stanceId = STANCE_STAND,
				normalSpeed = 1.75,
				maxSpeed = 4.5,
				heightCollider = 1.2,
				heightPivot = 0.0,
				size = {x=0.4,y=0.4,z=0.3},
				viewOffset = {x=0,y=0.15,z=1.625},
				modelOffset = {x=0,y=0,z=1.0},
				name = "combat",
				useCapsule = 1,
			}

		local pparams = {
			modelOffset = { x = 0, y = 0, z = 1 }
		}
		g_localActor.actor:SetParams(pparams)

		]])



		do return end
		ExecuteOnAll([[
		Remote.OnUpdate = function()
		end]])

		do return end

		if (x) then

			if (player.HGRABBED) then
				player.HGRABBED = nil
				RCA:OnDropObject(player,player.hPickedupObject)
				return
			end

			local hHit = player:GetHitPos(2.5)
			if (hHit and hHit.entity) then
				local bPhys = hHit.entity:GetPhysicalStats().mass > 0
				if (bPhys) then
					RCA:OnPickupObject(player,hHit.entity)
					player.HGRABBED = hHit.entity
				end
			end


			return

		end


		ExecuteOnAll([[
		Remote.OnUpdate = function()

			for i, hPlayer in pairs(System.GetEntitiesByClass("Player")or{}) do

				local hGrab = hPlayer.hGrabbedObject
				if (hGrab and System.GetEntity(hGrab.id) and hPlayer.id~=g_localActorId) then

					local bIsLocalActor = hPlayer.id == g_localActorId
					local bFP = g_localActor.actorStats.thirdPerson~=true
					local vPos = hPlayer:GetBonePos("Bip01 L Hand")



					if (bIsLocalActor) then

					if(timerexpired(hPlayer.hTimerPickupStart,1))then
							hPlayer.actor:SelectItemByName("Fists")
							local hCurrent = hPlayer.inventory:GetCurrentItem()
							vPos = nil
							if (hCurrent and hCurrent.class == "Fists" and bFP) then

								local iAnimTime = hCurrent:GetAnimationLength(0, 'grab_onto_01')
								if (timerexpired(hCurrent.hTimerGrab, iAnimTime)) then


									hCurrent.hTimerGrab = timerinit() - iAnimTime+0.03
									hCurrent:StopAnimation(0,8)
									hCurrent:StopAnimation(0,-1)
									hCurrent:StartAnimation(0, 'grab_onto_01')
									hCurrent:SetAnimationTime(0, 0, 1)

								end

								local vHandR = hCurrent:GetBonePos("Hand_R")
								local vHandL = hCurrent:GetBonePos("Hand_L")
								local vDir = System.GetViewCameraDir()

								local vHandBetween = {

									x = vHandL.x + ((vHandR.x - vHandL.x) / 2) - 0 + (vDir.x * 0.25),
									y = vHandL.y + ((vHandR.y - vHandL.y) / 2) - 0 + vDir.y * 0.25,
									z = vHandL.z + ((vHandR.z - vHandL.z) / 2) - 1 + 0,

								}

								vPos = vHandBetween

								vPos = System.GetViewCameraPos()

								local xadd=0
								local yadd=xadd
								if (vDir.z<-0.5)then
									xadd=(-0.5-vDir.z)*0.5
								elseif(vDir.z>0.1)then

									xadd=(vDir.z-0.1)*-0.5
									yadd=xadd*-1.9

									if (vDir.z>0.84)then
										xadd=(-0.556829/150)*100
									end

									xadd=xadd*1.5

								end




								vPos.x = vPos.x + (vDir.x * (0.65+yadd))
								vPos.y = vPos.y + (vDir.y * (0.65+yadd))
								vPos.z = vPos.z - 1.34 - xadd


								Msg(1, "btwn:%f,%f,%s",xadd,yadd,Vec2Str(vDir))
							end
						end

						vPos = vPos or hPlayer:GetBonePos("Bip01 L Hand") or hPlayer:GetPosInFront(0.8)

						hGrab:EnablePhysics(0)
						hGrab:SetPos(vPos)
						hGrab:SetDirectionVector(hPlayer:GetDirectionVector())
					else



						vPos = hPlayer:GetBonePos("Bip01 L Hand")
						vPos.z=hPlayer:GetBonePos("Bip01 Neck").z+0.15

						hGrab:AddImpulse(-1,vPos,g_Vectors.up,1,1)
						hGrab:SetDirectionVector({x=0,y=0,z=0})
						hGrab:SetPos({x=0,y=0,z=0})

						hGrab:SetColliderMode(0)

						hPlayer:SetColliderMode(2)
						hGrab:SetPos(vPos or hPlayer:ToLocal(0, vPos))
						hGrab:SetDirectionVector(hPlayer:GetDirectionVector())
					end

					hPlayer.hGrabbedObjectAttached = hGrab
					if (not hPlayer.bGrabbedObjectAttached) then
						Msg(0, "Ok now on")
						if (bIsLocalActor) then
						else

						end
						hPlayer.bGrabbedObjectAttached = true
					end

					local idOffHand = hPlayer.inventory:GetItemByClass("OffHand")
					if (idOffHand) then
						local hOffHand = System.GetEntity(idOffHand)
						if (hOffHand) then
							hOffHand.item:PlayAction("")
							hOffHand.item:PlayAction("hold_grenade")
						end
					end


				elseif (hPlayer.bGrabbedObjectAttached) then

					Msg(0, "DISABLE")

					if (hPlayer.hGrabbedObjectAttached and System.GetEntity(hPlayer.hGrabbedObjectAttached.id)) then
						hPlayer.hGrabbedObjectAttached:DetachThis()
						hPlayer.hGrabbedObjectAttached:SetColliderMode(0)
						hPlayer.hGrabbedObjectAttached:EnablePhysics(1)
					end

					hPlayer.bGrabbedObjectAttached = nil
					hPlayer.hGrabbedObjectAttached = nil
				else
				end

			end

		end
		]])

do return end


		ExecuteOnAll([[for i, v in pairs(System.GetEntitiesByClass("GUI")or{}) do Msg(0,v:GetName())v:AddImpulse(-1,v:GetPos(),g_Vectors.up,9999,1) end]])
		for i,v in pairs(System.GetEntitiesByClass("GUI") or {}) do
			--	Debug("kk ok LOL")
			v:AddImpulse(-1,v:GetPos(),g_Vectors.up,9999,1)
		end

		do return end

		Debug(tostring(player.id))
		Debug(tonumber((string.gsub(tostring(player.id), "userdata: ", ""))))

		ExecuteOnAll([[

		Msg(0,"id = %s", tostring(g_localActorId))

		Remote.OnUpdate = function()


		end

		]])




		do return end
-- and hFists and hFists.class == "Fists") then
		ExecuteOnAll([[


		Remote.OnUpdate = function()

			local hFists = g_localActor.inventory:GetCurrentItem()
			local hOffHand = g_localActor.inventory:GetItemByClass("OffHand")

			if (hOffHand) then

				hOffHand = System.GetEntity(hOffHand)
				g_localActor.actor:SelectItemByName("OffHand")
				hOffHand.item:Select(true)


				hOffHand:DrawSlot(0,1)
				hOffHand.item:PlayAction('hold_grenade')

				local iAnimTime = hOffHand:GetAnimationLength(0, 'pick_up_item_left_01')
				if (timerexpired(hOffHand.hTimerGrab, iAnimTime)) then


					hOffHand.hTimerGrab = timerinit()
					hOffHand:StopAnimation(0,8)
					hOffHand:StopAnimation(0,-1)
					hOffHand:StartAnimation(0, 'pick_up_item_left_01', 8, 0, 1, true)
					hOffHand:SetAnimationTime(0, 0, ]]..x..[[)
					Msg(0, "Start OKI")

				end
				Msg(1, iAnimTime)
			end
		end


		]])

		do return end
		ExecuteOnAll([[


		Remote.OnUpdate = function()

			for i,hPlayer in pairs(System.GetEntitiesByClass("Player")or{}) do

				local sHash = hPlayer.sGrabbedObjectHash

				if(sHash) then
					local hGrabbed = hPlayer.hGrab or GetEntityByHash(sHash or "")
					if (hGrabbed) then

						hPlayer.hGrab=hGrabbed
						local bIsLocalActor = hPlayer.id == g_localActorId
						local bFP = g_localActor.actorStats.thirdPerson ~= true
						local bIgnore = false

						local vPos = hPlayer:GetBonePos("Bip01 L Hand") or hPlayer:GetPosInFront(1,nil,"Bip01 Pelvis")or nil
						local vVecRot = hPlayer:GetDirectionVector()
						VecRotateMinus90_Z(vVecRot)
						VecRotateMinus90_Z(vVecRot)

						if (not bIsLocalActor) then
							if (not hGrabbed.bIsAttached) then
								hGrabbed.bIsAttached = true


								hGrabbed:PhysicalizeSlot(0, { flags = 1.8537e+008 })
								hPlayer:AttachChild(hGrabbed.id, PHYSICPARAM_SIMULATION)

								hPlayer.idAttachedObject = hGrabbed.id
								hPlayer.AttachedObject = hGrabbed

								Msg(0, "ATTACHED NOW !!!")
							end

							hPlayer:SetColliderMode(2)
							hGrabbed:SetPos(vPos)
							hGrabbed:SetDirectionVector(vVecRot)
						end

						if (timerexpired(DEBUG_TIMER, 1)) then
							DEBUG_TIMER = timerinit()
							Particle.SpawnEffect("explosions.flare.night_time", hGrabbed:GetPos(), g_Vectors.up,0.1)
						end
					elseif (hPlayer.AttachedObject) then
						Msg(0, "Detached")
						hPlayer.hGrab=nil
						hPlayer.AttachedObject:DetachThis()
						hPlayer.AttachedObject.bIsAttached = nil
						hPlayer.AttachedObject = nil
					end
				end
			end
		end

		]])

		do return end



		local sHash = GetEntityHash(player.hPickedupObject)
		ExecuteOnAll([[
		function GetEntityHash(hEntity)
			local sHash = hEntity:GetName()
			for i, aProp in pairs(hEntity["Properties"]or{}) do
				if (not isArray(aProb) and not isFunction(aProp) and not type(aProp) == "userdata") then
					sHash = sHash .. ("[" .. i .. "]" .. "=" .. tostring(aProp))
				end
			end
			hEntity.EntityHash = simplehash.hash(sHash)
			return hEntity.EntityHash
		end
		function GetEntityByHash(sHash)
			local aEntities = System.GetEntities()
			for i, hEntity in pairs(aEntities) do
				local sEntityHash = GetEntityHash(hEntity)
				if (sEntityHash == sHash) then
					return hEntity
				end
			end
			return
		end
		local sHash = "]]..sHash..[["
local hEntity = GetEntityByHash(sHash)
Msg(0, "%s==%s %s", sHash,tostring(hEntity),hEntity:GetName())

		]])

		--ExecuteOnAll("GP("..player:GetChannel()..").hGrabbedObject=GetEntityByHash('"..GetEntityHash(player.hPickedupObject).."')")

	end;
});

-- DIR.z / 57,18897142457728 = ANG.Z

--[[

cfg = {
		System = true,
		Animations = {
			Prone = {
				Use = true,
				{
					--Sniper = { "" },
					Pistol = { "prone_idle_pistol_01", "prone_idle_pistol_02", "prone_idle_pistol_03", "prone_idle_pistol_04" }, -- SOCOM
					Rifle = { "prone_idle_rifle_01", "prone_idle_rifle_02", "prone_idle_rifle_03" }, -- Rifle
					Fist = { "prone_idle_nw_01", "prone_idle_nw_02", "prone_idle_nw_03", "prone_idle_nw_04" } -- Fists
				}, -- = [1]
			},
			Stand = {
				Use = true,
				{
					Minigun = { "combat_idle_mg_01", "combat_idle_mg_02", "combat_idle_mg_03", "combat_idle_mg_04" }, -- Minigun
					Sniper = { "combat_sniperIdle_rifle_01" }, -- Sniper
					Pistol = { "combat_idle_pistol_01", "combat_idle_pistol_02", "combat_idle_pistol_03", "combat_idle_pistol_04" }, -- SOCOM
					Rifle = { "combat_idle_rifle_01", "combat_idle_rifle_02", "combat_idle_rifle_03", "combat_idle_rifle_04" }, -- Rifle
					--Fist = { "" } -- Fists -- Now 'Idle' category
				}, -- = [1]
			},
			Crouch = {
				Use = true,
				{
					Minigun = { "crouch_idle_mg_01", "crouch_idle_mg_02", "crouch_idle_mg_03", "crouch_idle_mg_04" }, -- Minigun
					--Sniper = { "combat_sniperIdle_rifle_01" }, -- Sniper
					Pistol = { "crouch_idle_pistol_01", "crouch_idle_pistol_02", "crouch_idle_pistol_03", "crouch_idleKnee_pistol_01", "crouch_idleKnee_pistol_02", "crouch_idleKnee_pistol_03" }, -- SOCOM
					Rifle = { "crouch_idle_rifle_01", "crouch_idle_rifle_02", "crouch_idle_rifle_03", "crouch_idle_rifle_04", "crouch_idleKnee_rifle_01", "crouch_idleKnee_rifle_02", "crouch_idleKnee_rifle_03", "crouch_idleKnee_rifle_04" }, -- Rifle
					Fist = { "crouch_idle_nw_01", "crouch_idle_nw_02", "crouch_idle_nw_03", "crouch_idle_nw_04", "crouch_idleKnee_nw_02", "crouch_idleKnee_nw_03", "crouch_idleKnee_nw_04" } -- Fists
				}, -- = [1]
			},
			Falling = { -- !!WIP
				Use = true,
				{
					"",
				}, -- = [1]
			},
			Idle = {
				Use = true,
				{
					--Sniper = { "" }, -- Sniper
					--Pistol = { "" }, -- SOCOM
					--Rifle = { "" }, -- Rifle
					--Fist = { "" } -- Fists
					"relaxed_idleCheckingWatch_01",
					"relaxed_idleChinrub_01", "relaxed_idleChinrub_02", "relaxed_idleChinrub_03",
					"relaxed_idleClaphands_01",
					"relaxed_idleDawdling_nw_01",
					"relaxed_idleDrummingOnLegs_nw_01",
					"relaxed_idleHeadScratch_01","relaxed_idleHeadScratch_02","relaxed_idleHeadScratch_03","relaxed_idleHeadScratch_04","relaxed_idleHeadScratch_05",
					"relaxed_idleInsectSwat_leftHand_01","relaxed_idleInsectSwat_leftHand_02",
					"relaxed_idleKickDust_01","relaxed_idleKickStone_01",
					"relaxed_idleListening_01","relaxed_idleListening_02","relaxed_idleListening_03",
					"relaxed_idlePickNose_nw_01",
					"relaxed_idleRubKnee_01", "relaxed_idleRubNeck_01",
					"relaxed_idleScratchbutt_01","relaxed_idleScratchNose_nw_01",
					"relaxed_idleShift_01","relaxed_idleShift_01",
					"relaxed_idleShoulderShrug_01","relaxed_idleShoulderShrug_02","relaxed_idleShoulderShrug_03",
					"relaxed_idleSmokeDrag_cigarette_01","relaxed_idleSmokeDrag_cigarette_02",
					"relaxed_idleTappingFoot_01",
					"relaxed_idleTeetering_nw_01",
					"relaxed_idleTieLaces_01",
					"relaxed_idleYawn_nw_01",
					"relaxed_readIdle_book_01",
					"relaxed_salute_nw_01","relaxed_saluteLazyCO_nw_01",
					"relaxed_standIdleHandsBehindCOLoop_01",
					
					
				}, -- = [1]
			};
		},
	},


RegisterEvent("OnUpdate", function()
	for i, clone in pairs(System.GetEntitiesByClass("Player"))do
		if (clone.freeFall) then
			clone.actor:OpenParachute();
		end;
	end;
end)--]]

xtest = {
	ytest = {
		testTable = {
			object = "testString",
		},
		ztest = function(self)
			Debug("called successfully");
			Debug("test:", self.testTable.object);
		end;
	};
};

--RegisterEvent("OnTick", xtest.ytest.ztest, "xtest.ytest")


function dotest(player,class, timer)
Script.SetTimer(1, function()
	local class = tostring(class or "Grunt")
		local pos = player:CalcSpawnPos(5)
		--BasicAI.Properties.equip_EquipmentPack = "NK_Rifle";
		local Properties=Grunt.Properties;
		Properties.aicharacter_character="Camper"
		local ent = System.SpawnEntity({
			class = "Grunt",
			position = pos,
			name = 'test-spawn',
		--	properties = Properties
		});
		end);
		
		do return end;
		if (class=="Grunt") then
			 Properties = {

			rank = 4,
			special = 0,

			attackrange = 0,
			reaction = 0,	-- time to startr shooting with nominal accuracy
			commrange = 30.0,
			accuracy = 0.0,
			distanceToHideFrom=3,

			smartObject_smartObjectClass="Actor";
			species = 0,
			bSpeciesHostility = 0,
			fGroupHostility = 0,
			equip_EquipmentPack="NK_Sniper_Assault",
			AnimPack = "Basic",
			SoundPack = "Prophet",		
			SoundPackAlternative = "",
			nVoiceID = 0,
			aicharacter_character = "FriendlyNPC",
			fileModel = "objects/characters/human/story/laurence_barnes/laurence_barnes_face.cdf",
			nModelVariations=0,
			bTrackable=1,
			bSquadMate=0,
			bSquadMateIncendiary=0,
			bGrenades=0,
			IdleSequence = "None",
			bIdleStartOnSpawn = 0,
			
			bCannotSwim = 0,
			bInvulnerable = 0,
			bNanoSuit = 0,

			eiColliderMode = 3, -- zero as default, meaning 'script does not care and does not override graph, etc'.

			awarenessOfPlayer =1,

			Perception =
			{
				--how visible am I
				camoScale = 1,
				--movement related parameters
				--VELmultyplier = (velBase + velScale*CurrentVel^2);
				--current priority gets scaled by VELmultyplier
				velBase = 10,
				velScale = 10, --.03,
				--fov/angle related
				FOVPrimary = 0,--80,			-- normal fov
				FOVSecondary = 0,--160,		-- periferial vision fov
				--ranges			
				sightrange = 0,
				sightrangeVehicle = -1,	-- how far do i see vehicles
				--how heights of the target affects visibility
				--// compare against viewer height
				-- fNewIncrease *= targetHeight/stanceScale
				stanceScale = 1.9,
				-- Sensitivity to sound 0=deaf, 1=normal
				audioScale = 1,
				-- Equivalent to camo scale, used with thermal vision.
				heatScale = 1,
				-- Flag indicating that the agent has thermal vision.
				bThermalVision = 0,
				-- The perception reaction speed, default speed = 1. THe higher the value the faster the AI acquires target.
				reactionSpeed = 0,
				-- controls how often targets can be switched, 
				-- this parameter corresponds to minimum ammount of time the agent will hold aquired target before selectng another one
				-- default = 0 
				persistence = 0,
				-- controls how long the attention target have had to be invisible to make the player stunts effective again
				stuntReactionTimeOut = 0.0,
				-- controls how sensitive the agent is to react to collision events (scales the collision event distance).
				collisionReactionScale = 0.0,	
				-- flag indicating if the agent perception is affected by light conditions.
				bIsAffectedByLight = 0,--1,	
				-- Value between 0..1 indicating the minimum alarm level.
				minAlarmLevel = 0,	
			},
			
			AIMovementAbility =
		{
			pathFindPrediction = 0.5,		-- predict the start of the path finding in the future to prevent turning back when tracing the path.
			allowEntityClampingByAnimation = 0,--1,
			usePredictiveFollowing = 1,
			walkSpeed = 63.0, -- set up for humans
			runSpeed = 63.0,
			sprintSpeed = 63.4,
			b3DMove = 0,
			pathLookAhead = 1, 
			pathRadius = 0.4,
			pathSpeedLookAheadPerSpeed = -1.5,
			cornerSlowDown = 0.0,--75,
			maxAccel = 3.0,
			maxDecel = 8.0,
			maneuverSpeed = 1.5,
			velDecay = 0.5,
			minTurnRadius = 0,	-- meters
			maxTurnRadius = 0,--3,	-- meters
			maneuverTrh = 2.0,  -- when cross(dir, desiredDir) > this use manouvering
			resolveStickingInTrace = 1,
			pathRegenIntervalDuringTrace = 4,
			lightAffectsSpeed = 0, --1,

			-- These are actually aiparams (as they may be changed during game and need to get serialized),
			-- but defined here so that designers do not try to change them.
			lookIdleTurnSpeed = 530,
			lookCombatTurnSpeed = 550,
			aimTurnSpeed = -1, --120,
			fireTurnSpeed = -1, --120,
			
			-- Adjust the movement speed based on the angel between body dir and move dir.
			directionalScaleRefSpeedMin = 100, --1.0,
			directionalScaleRefSpeedMax = 999, --8.0,

		  AIMovementSpeeds = 
		  {
				Relaxed =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 1.0, 1.0,1.9 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 1.3, 1.0,1.9 },
					Run =		{ 117.5, 117.3,117.0 },--	{ 4.5, 2.0,7.2 },
				},
				Combat =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.5, 0.6,0.7 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.6, 0.6,0.7 },
					Run =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--	{ 3.0, 2.9,4.3 },
					Sprint =	{ 117.5, 117.3,117.0 },--{ 6.5, 2.3,6.5 },
				},
				Crouch =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.5, 0.6,0.7 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.6, 0.6,0.7 },
					Run =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--	{ 3.0, 2.9,4.3 },
				},
				Stealth =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.5, 0.6,0.7 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.6, 0.6,0.7 },
					Run =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--	{ 3.0, 2.9,4.3 },
				},
				Prone =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.5, 0.6,0.7 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.6, 0.6,0.7 },
					Run =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--	{ 3.0, 2.9,4.3 },
				},
				Swim =
				{
					Slow =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.5, 0.6,0.7 },
					Walk =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--{ 0.6, 0.6,0.7 },
					Run =		{ 117.5, 117.3,117.0 },--{ 7.5, 7.3,7.0 },--	{ 3.0, 2.9,4.3 },
				},
		  },
		}
		};
			Grunt.Properties = Properties;
			Grunt.Properties.AIMovementAbility=Properties.AIMovementAbility
			
			
			Grunt.AIMovementAbility=Properties.AIMovementAbility
			BasicAI.AIMovementAbility=Properties.AIMovementAbility
			Grunt.AIMovementSpeeds=Properties.AIMovementAbility.AIMovementSpeeds
			BasicAI.AIMovementSpeeds=Properties.AIMovementAbility.AIMovementSpeeds
		end;
		
		local ent = System.SpawnEntity({
			class = class,
			position = pos,
			name = 'test-spawn',
			Properties = Properties,
			properties = Properties
		});
		if (not ent) then
			return false, "NO NO NO!!";
		else
			
	
	--g_localActor.actor:SetParams(ent.moveParams);
			ent.AIMovementAbility=Properties.AIMovementAbility
			Debug(formatString("[TESTSPAWN] Spawned entity of class %s, AI = %s, timer = %d", class, tostring(bAI ~= nil), tonumber(timer) or 0));
			System.SetCVar("log_verbosity", "4")
			if (bAI) then
			--	Game.RegisterAI(ent.id,true);
			--	Game.RegisterAI(g_localActor.id);
			--	ent:RegisterAI() 
			--	BasicAI.RegisterAI(ent);
			end;
			ent.Properties.species = 99;
			ent.Properties.equip_EquipmentPack = "NK_Rifle";
			self:Log(0, "Debug: \"" .. ent.Properties.equip_EquipmentPack .. "\"")
			if (timer and tonumber(timer)) then
				Script.SetTimer(tonumber(timer) * 1000, function()
					System.RemoveEntity(ent.id);
				end);
			end;
			
		end;

end