ATOMBoids = {
    cfg = {},
    ---------------------------------------------------------
    -- Data
    IS_CLIENT = CryAction.IsClient(),
    IS_SERVER = CryAction.IsServer(),
    ACTIVE_CREATURES = {},
    ACTOR_CLASSES = {
        ["Player"] = true,
    },
    ---------------------------------------------------------
    -- Constructor
    Init = function(self)
        g_ATOMBoids = self
        if (self.IS_SERVER) then
            RegisterEvent("OnUpdate", self.Update, "ATOMBoids")
        end
    end,
    ---------------------------------------------------------
    -- Constructor
    Create = function(self, hEntity, aParams)
        local aCreature = {}

        aCreature.hEntity = hEntity

        aCreature.IS_ACTOR = (hEntity.actor ~= nil and (self.ACTOR_CLASSES[hEntity.class]))
        aCreature.IS_SOLO = true
        aCreature.MOUNTED_ENTITY = nil
        aCreature.LAST_MOVE_TIMER = nil
        aCreature.CURRENT_ANIMATION = nil
        aCreature.ANIMATION_TIMER = nil
        aCreature.ANIMATION_TIME = nil
        aCreature.SoundTimers = {}

        aCreature.Properties = table.deepMerge(aParams, {
            Model = "objects/characters/animals/birds/chicken/chicken.chr",
            AnimationSet = {
                Idle = "idle01",
                Walk = "walk_loop",
                Run = "walk_loop",
                Scared = "pickup"
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
            RestingTime = { 3, 8 },
            ModelScale = 1,
            RotationLimits = { -999, 999 },
            SoundEvents = {},
        })

        if (self.IS_CLIENT) then
            hEntity.Properties.bPickable = nil
            hEntity.GetUsableDistance = function() return 1  end
            hEntity.IsUsable = function() return 1  end
            hEntity.GetUsableMessage = function(self)
                local sMsg = "Mount"
                local hUser = aCreature:GetMounted()
                if (hUser and hUser.id == g_localActorId) then
                    sMsg = "Dismount"
                end
                return sMsg
            end
            hEntity.OnUsed = function(self, hUser)
                Msg(0,"%s",self:GetName())
                ATOMClient:ToServer(eTS_Chat, "!usemountable " .. self:GetName())
            end
        else
            hEntity.OnUse = function(self, hUser)

                local sCode
                if (self.hMounted == nil) then
                    sCode = [[g_ATOMBoids:Mount(ATOMClient.Mountables:GetCreatureA(GetEnt(']]..h:GetName()..[[')),GP(]]..user:GetChannel()..[[))]]
                    ExecuteOnAll(sCode)
                    self.NetSyncMount = RCA:SetSync(self, { client = sCode, link = self.id })
                    self.hMounted = hUser
                    hUser.hMount = self
                    hUser.hMountTimer = timerinit()

                elseif (self.hMounted.id == hUser.id) then
                    sCode = [[g_ATOMBoids:Dismount(ATOMClient.Mountables:GetCreatureA(GetEnt(']]..h:GetName()..[[')),GP(]]..user:GetChannel()..[[))]]
                    ExecuteOnAll(sCode)
                    RCA:StopSync(self, self.NetSyncMount)
                    self.NetSyncMount = nil
                    self.hMounted = nil
                    hUser.hMount = nil
                end
            end
            self:CreateOnClient(aCreature)
        end

        aCreature.UpdateSolo = self.UpdateCreature_Solo
        aCreature.UpdateMount = self.UpdateCreature_Mounted
        aCreature.UpdateAnimations = self.UpdateCreature_Animations
        aCreature.IsSolo = function(self)
            return self.IS_SOLO
        end
        aCreature.GetMounted = function(self)
            return self.MOUNTED_ENTITY
        end
        aCreature.IsMountedMoving = function(self)
            local hMount = self:GetMounted()
            if (not hMount) then
                return false
            end
            return (hMount:GetSpeed() >= 1)
        end

        self:Physicalize(hEntity, aCreature.Properties, aCreature)
        if (aCreature.IS_ACTOR and self.IS_CLIENT) then
            g_Client.AnimationHandler:RegisterAnimations(hEntity)
        end

        --table.insert(self.ACTIVE_CREATURES, aCreature)
        self.ACTIVE_CREATURES[hEntity.id] = aCreature
    end,
    ---------------------------------------------------------
    -- CreateOnClient
    CreateOnClient = function(self, aCreature)

        if (self.IS_CLIENT) then
            return
        end

        local hEntity = aCreature.hEntity
        local sName = hEntity:GetName()

        local sCode = string.format([[
            local hEnt = GetEnt('%s')
            if (hEnt) then
                g_ATOMBoids:Create(hEnt, %s)
            end
        ]], sName, table.tostring(aCreature.Properties, "", ""))
        ExecuteOnAll(sCode)

        aCreature.NetSyncID = RCA:SetSync(hEntity, { client = sCode, link = hEntity.id })
    end,
    ---------------------------------------------------------
    -- Physicalize
    Physicalize = function(self, hCreature, aProps, aCreature)

        local sModel = aProps.Model
        if (string.sub(sModel, -4) == ".chr") then
            hCreature:LoadCharacter(0, sModel)
        else
            hCreature:LoadObject(0, sModel)
        end

        local vNull = { x = 0, y = 0, z = 0 }
        local fMass = (aProps.Mass or 100)
        local fDensity = (aProps.Density or 100)

        aCreature.Physicalize = function()
            hCreature:Physicalize(0, PE_RIGID, { mass = fMass, density = fDensity })
            hCreature:SetPhysicParams(PHYSICPARAM_SIMULATION, { mass = fMass, density = fDensity })
            hCreature:SetPhysicParams(PHYSICPARAM_VELOCITY, { v = vNull, w = vNull })
            if (aCreature.Properties.Underwater) then
                hCreature:SetPhysicParams(PHYSICPARAM_BUOYANCY, {
                    water_density = 10,
                    water_damping = 10,
                    water_resistance = 10,
                })
            end
        end
        aCreature.DestroyPhysics = function()
            hCreature:DestroyPhysics()
        end

        hCreature:SetScale(aProps.ModelScale)

        aCreature.Physicalize()
        hCreature.LAST_LOOK_DIR = { x = 0, y = 0, z = 0 }
    end,
    ---------------------------------------------------------
    -- GetCreatureA
    GetCreatureA = function(self, hEntity)

        for i, aCreature in pairs(self.ACTIVE_CREATURES) do
            if (aCreature.hEntity.id == hEntity.id) then
                return aCreature
            end
        end
    end,
    ---------------------------------------------------------
    -- Dismount
    Dismount = function(self, hCreature, hUser)

        local hEntity = hCreature.hEntity
        local bNewMethod = false

        hCreature.IS_SOLO = true
        if (hUser) then

            if (self.IS_CLIENT) then
                LOOPED_ANIMS[hUser.id] = nil
                hUser:StopAnimation(0, 8)
            end

            -- New Method
            if (bNewMethod and hUser.id ~= g_localActorId) then
                hUser:DetachThis()
            else
                hCreature.Physicalize()
            end
        end

        hCreature.MOUNTED_ENTITY = nil
        --hCreature.Physicalize()

    end,
    ---------------------------------------------------------
    -- Mount
    Mount = function(self, hCreature, hUser)

        hCreature.IS_SOLO = false
        hCreature.MOUNTED_ENTITY = hUser

        --if (hUser.id == g_localActorId) then
        --	hCreature.DestroyPhysics()
        --end

        -- New Method
        local hEntity = hCreature.hEntity
        local aProps = hCreature.Properties
        local bNewMethod = false

        if (bNewMethod and hUser.id ~= g_localActorId) then
            hEntity:AttachChild(hUser.id, PHYSICPARAM_SIMULATION)

            local aOffSet = aProps.PlayerOffSet
            if (aOffSet) then
                hUser:SetLocalPos(aOffSet)
            end
        else
            hCreature.DestroyPhysics()
        end

        if (self.IS_CLIENT) then
            self:InitAnims(hUser)
        end
    end,
    ---------------------------------------------------------
    -- Destructor
    CalculateAnimationSpeedFromVelocity = function(self, iVelocity, iMultiplier, iMinSpeed, iMaxSpeed)

        local iMaxSpeed = checkNumber(iMaxSpeed, 4)
        local iMinSpeed = checkNumber(iMinSpeed, 0.75)

        local iSpeed = (iMaxSpeed * (iVelocity / 12))
        if (iSpeed > iMaxSpeed) then
            iSpeed = iMaxSpeed
        elseif (iSpeed < iMinSpeed) then
            iSpeed = iMinSpeed
        end

        return iSpeed * checkNumber(iMultiplier, 1)
    end,
    ---------------------------------------------------------
    -- Update
    Think = function(self, hCreature)

        if (not self.IS_SERVER) then
            return
        end

        if (not timerexpired(hCreature.GOAL_REACHED, hCreature.GOAL_REACHED_REST)) then
            return
        end

        hCreature.MOVEMENT_DISTRIBUTED = false

        local hEntity = hCreature.hEntity
        local aProps = hCreature.Properties

        local vPos = hEntity:GetPos()
        local vRHPos = vector.modify(vPos, "z", 0.15, 1)
        local vRHDir = {
            x = math.frandom(-1, 1),
            y = math.frandom(-1, 1),
            z = 0,
        }

        if (aProps.Move3D) then
            vRHDir.z = math.random(-1, 1)
        end


        local iMoveDistance = math.frandom(aProps.StepDistance[1], aProps.StepDistance[2])
        if (iMoveDistance < 1) then
            iMoveDistance = 1
        end
       -- SysLog("check crah")
        local aRH = RayHit(vRHPos, vRHDir, iMoveDistance, hEntity.id, ent_all) or {
            pos = {
                x = vPos.x + vRHDir.x * iMoveDistance,
                y = vPos.y + vRHDir.y * iMoveDistance,
                z = vPos.z + vRHDir.z * iMoveDistance,
            }
        }
       -- SysLog("check crah ok")

        --g_utils:SpawnEffect(ePE_Flare, aRH.pos, g_Vectors.up, 0.1)
        --do return end
        aRH.pos.x = aRH.pos.x - vRHDir.x * 1
        aRH.pos.y = aRH.pos.y - vRHDir.y * 1
        aRH.pos.z = aRH.pos.z - vRHDir.z * 1

        local bFish = aProps.Underwater

        local iRHWater = CryAction.GetWaterInfo(aRH.pos)
        if (not bFish) then
            if (iRHWater < (aRH.pos.z - 0.2)) then
                --SysLog("check crah2")
                local aDown = RayHit(vector.modify(aRH.pos, "z", 1, 1), g_Vectors.down, 5, hEntity.id, ent_terrain + ent_static)
                --SysLog("check crah2 ok")
                if (aDown) then
                    local iDownWater = CryAction.GetWaterInfo(vector.modify(aDown.pos, "z", -0.1, 1))
                    if (iDownWater < aDown.pos.z) then
                        aRH.pos = aDown.pos
                    end
                end
            else
                return
            end
        else
            if (iRHWater < aRH.pos.z) then
                aRH.pos.z = iRHWater - math.frandom(1, 2)
            end
        end


        local iSpeed = (hCreature.MOVE_SPEED or math.frandom(aProps.MoveSpeed[1], aProps.MoveSpeed[2]))
        hCreature.MOVE_SPEED = iSpeed
        hCreature.GOAL_REACHED_REST = math.frandom(aProps.RestingTime[1], aProps.RestingTime[2])
        hCreature.MOVE_GOAL = aRH.pos
        self:DistributeMovement(hCreature)

        return true
    end,
    ---------------------------------------------------------
    -- Update
    SyncData = function(self, hCreature)

        if (not self.IS_SERVER) then
            return
        end

        local hEntity = hCreature.hEntity
        local sData = hCreature.NETSYNC

        if (hEntity.NetSyncID) then
            RCA:StopSync(hEntity, hEntity.NetSyncID)
        end
        hEntity.NetSyncID = RCA:SetSync(hEntity, { client = sData, link = hEntity.id })
        ExecuteOnAll(sData)
    end,
    ---------------------------------------------------------
    -- Update
    DistributeMovement = function(self, hCreature, vPos, iTimer)

        if (not self.IS_SERVER) then
            return
        end

        local hEntity = hCreature.hEntity
        local aProps = hCreature.Properties
        local sName = hEntity:GetName()
        local vGoal = (vPos or hCreature.MOVE_GOAL)

        if (hCreature.DISTRIBUTION_TIMER) then
            Script.KillTimer(hCreature.DISTRIBUTION_TIMER)
        end

        local iRestingTime = (hCreature.GOAL_REACHED_REST or math.frandom(aProps.RestingTime[1], aProps.RestingTime[2]))
        local iMoveSpeed = (hCreature.MOVE_SPEED or math.frandom(aProps.MoveSpeed[1], aProps.MoveSpeed[2]))

        hCreature.DISTRIBUTION_TIMER = Script.SetTimer(checkNumber(iTimer, 100), function()
            hCreature.DISTRIBUTION_TIMER = nil
            hCreature.MOVEMENT_DISTRIBUTED = true
            hCreature.NETSYNC = string.format([[
            local hEnt = GetEnt('%s')
            if (hEnt) then
                g_ATOMBoids:UpdateData(hEnt.id, "MOVE_GOAL", %s)
                g_ATOMBoids:UpdateData(hEnt.id, "GOAL_REACHED_REST", %f)
                g_ATOMBoids:UpdateData(hEnt.id, "MOVE_SPEED", %f)
            end
            ]], sName, table.tostring(vGoal, "", ""), iRestingTime, iMoveSpeed)
            self:SyncData(hCreature)

           -- g_utils:SpawnEffect(ePE_Flare, vGoal, g_Vectors.up, 0.1)
           -- g_utils:SpawnEffect(ePE_Flare, hEntity:GetPos(), g_Vectors.up, 0.1)
            --Debug("DISTRIBUTE NOW!")
        end)
    end,
    ---------------------------------------------------------
    -- UpdateData
    UpdateData = function(self, hID, sIndex, hData)

        local aCreature = self.ACTIVE_CREATURES[hID]
        if (not aCreature) then
            return
        end

        aCreature[sIndex] = hData
    end,
    ---------------------------------------------------------
    -- DeleteBoid
    DeleteBoid = function(self, hID)
        self.ACTIVE_CREATURES[hID] = nil
    end,
    ---------------------------------------------------------
    -- Update
    Update = function(self)

        local aCreatures = self.ACTIVE_CREATURES
        local hEntity
        for i, hCreature in pairs(aCreatures) do

            hEntity = hCreature.hEntity
            if (not System.GetEntity(hEntity.id)) then
                self:DeleteBoid(i)
            elseif (hCreature.IS_ACTOR and hEntity.actor:GetHealth() <= 0) then
                self:DeleteBoid(i)
            else
                --if (self.IS_CLIENT) then
                hCreature:UpdateAnimations()
               -- end

                if (hCreature:IsSolo()) then
                    hCreature:UpdateSolo()
                else
                    hCreature:UpdateMount()
                end
            end
        end

    end,
    ---------------------------------------------------------
    -- Update Solo (must be done on server)
    UpdateCreature_Solo = function(hCreature)

        -----------
        local hMounted = hCreature:GetMounted()
        if (hMounted) then
            if (hMounted:IsDead() or not System.GetEntity(hMounted.id)) then
                return self:Dismount(hCreature, hMounted)
            end
        end

        -----------
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
            hCreature.GOAL_REACHED = timerinit()
            --SysLog("bad")
        end

        -----------
        local aProps = hCreature.Properties
        local vPos = hEntity:GetPos()
        local vGoal = hCreature.MOVE_GOAL
        if (not vGoal) then
            if (not g_ATOMBoids.IS_SERVER or not g_ATOMBoids:Think(hCreature)) then
                return
            else
                vGoal = hCreature.MOVE_GOAL
                if (not vGoal) then
                    return
                end
            end
        end

        -----------
        if (g_ATOMBoids.IS_SERVER and not hCreature.MOVEMENT_DISTRIBUTED) then
            return
        end

        -----------
        local iSpeed = hCreature.MOVE_SPEED

        -----------
        local vDir = GetDir(vGoal, vPos, 1)
        local vDirA = hEntity:GetDirectionVector()
        local vWaterCheck = {
            x = vPos.x + vDirA.x * 2,
            y = vPos.y + vDirA.y * 2,
            z = vPos.z + vDirA.z * 2,
        }
        local iWater = CryAction.GetWaterInfo(vWaterCheck)
        local bInWater = (iWater > (vWaterCheck.z - 0.15))
        if (g_ATOMBoids.IS_CLIENT or aProps.Underwater) then
            bInWater = false -- Only on server
        end
       -- SysLog("%f>%f",iWater,vWaterCheck.z-0.15)

        -----------
        local iGoalDist = 1.0
        if (aProps.Underwater) then
            iGoalDist = 2
        end
        --SysLog(tostring(vGoal).." and " .. vector.distance(vPos, vGoal) ..">1.25 and "..tostring(not bInWater))
        if (vGoal and vector.distance(vPos, vGoal) > iGoalDist and not bInWater) then

            hEntity.LAST_LOOK_DIR = Dir2Ang(vDir)
            local aLimits = aProps.RotationLimits
            if (hEntity.LAST_LOOK_DIR.x < aLimits[1]) then
                hEntity.LAST_LOOK_DIR.x = aLimits[1]
            end
            if (hEntity.LAST_LOOK_DIR.x > aLimits[2]) then
                hEntity.LAST_LOOK_DIR.x = aLimits[2]
            end

            hCreature.LAST_MOVE_TIMER = timerinit()

            ScaleVectorInPlace(vDir, iSpeed)
            hEntity:SetPhysicParams(PHYSICPARAM_VELOCITY, { v = vDir, w = vDir })
            --System.LogAlways(string.format("move to %f",vector.distance(vPos, vGoal)))
        else
            if (bInWater) then
             --   Debug("IN WATER !!!")
            end
            --g_ATOMBoids:DistributeMovement(hCreature, vPos, 0)
            hCreature.MOVE_GOAL = nil
            hCreature.GOAL_REACHED = timerinit()
          --  SysLog("WAIT START !")
        end

        if (CryAction.IsClient()) then
            return
        end

    end,
    ---------------------------------------------------------
    -- Update mounted
    UpdateCreature_Mounted = function(hCreature)

        local aProps = hCreature.Properties

        local hEntity = hCreature.hEntity
        local hMounted = hCreature:GetMounted()

        if (not hMounted) then
            return
        end

        local vDir = hMounted:GetBoneDir("Bip01 Pelvis")
        local vAng = Dir2Ang(vDir)
        vAng.x = 0

        local vPos = hMounted:GetBonePos("Bip01 Pelvis")

        vPos.x = vPos.x + vDir.x * (aProps.ModelOffSet.x)
        vPos.y = vPos.y + vDir.y * (aProps.ModelOffSet.y)
        vPos.z = vPos.z - (aProps.ModelOffSet.z)

        hEntity:SetWorldPos(vPos)
        hEntity:SetAngles(vAng)
        --hEntity:SetDirectionVector(hMounted:GetDirectionVector(1))

        if (g_ATOMBoids.IS_CLIENT) then
            if (not LOOPED_ANIMS[hMounted.id] or LOOPED_ANIMS[hMounted.id].ID ~= "mounted") then
                g_ATOMBoids:InitAnims(hMounted)
            end
        end
    end,
    ---------------------------------------------------------
    -- InitAnims
    InitAnims = function(self, hMounted)
        LOOPED_ANIMS[hMounted.id] = {
            KeepAnimation = 1,
            ForcedTimer = 0.05,
            Timer 	= 0.01,
            Start 	= -999,
            Entity 	= hMounted,
            Loop 	= -1,
            Timer 	= 0,
            Speed 	= 1,
            Anim 	= "relaxed_sit_nw_01",
            NoSpec	= true,
            Alive	= true,
            NoWater	= true,
            ID		= "mounted"
        }
    end,
    ---------------------------------------------------------
    -- Update Animations
    UpdateCreature_Animations = function(hCreature)

        local aProps = hCreature.Properties
        local aAnims = aProps.AnimationSet

        local hMounted = hCreature:GetMounted()
        local hEntity = hCreature.hEntity
        if (hEntity.class == "Player") then
            return -- Code below obsolete for player entities. those are managed by the AnimationHandler
        end

        local iSpeed = hEntity:GetSpeed()
        if (hMounted) then
            iSpeed = hMounted:GetSpeed()
        end

        local bIdle = (iSpeed <= 0.5)
        local bRunning = (iSpeed >= 8.5)
        local bFalling = false

        local bMountedMoving = (hCreature:IsMountedMoving())
        local bFreefall = (bFalling or (not bIdle and timerexpired(hCreature.LAST_MOVE_TIMER, 0.1) and not bMountedMoving))

        local bEnterFreeFall = (bFreefall and not hCreature.IS_FALLING)
        hCreature.WAS_FALLING = (not bFreefall and hCreature.IS_FALLING)
        hCreature.IS_FALLING = bFreefall

        local sAnim
        local iAnimTime = nil
        local iAnimStart = nil
        local iAnimSpeed = 1

        if (not bFreefall) then
            hCreature.FREEFALL_START = nil
        end

        local bServer = g_ATOMBoids.IS_SERVER
        if (bFreefall) then
            --Msg(0,"entity freefalling !")
            sAnim = aAnims.Fly
            iAnimSpeed = 2
            iAnimTime = 0.4

            if (bEnterFreeFall) then
                hCreature.FREEFALL_START = timerinit()
            end

            if (bServer) then
                g_ATOMBoids:SoundEvent(hCreature, "fall")
            end
        elseif (bIdle) then
            --Msg(0, "entity idle !")
            sAnim = aAnims.Idle
            if (bServer) then
                g_ATOMBoids:SoundEvent(hCreature, "idle")
            end
        elseif (bRunning) then
            --Msg(0, "entity running !")
            sAnim = aAnims.Run
            iAnimSpeed = g_ATOMBoids:CalculateAnimationSpeedFromVelocity(iSpeed, nil, 1, 2)
            if (bServer) then
                g_ATOMBoids:SoundEvent(hCreature, "run")
            end
        else
            --Msg(0, "entity walking !")
            sAnim = aAnims.Walk
            iAnimSpeed = g_ATOMBoids:CalculateAnimationSpeedFromVelocity(iSpeed, nil, 1, 5)
            if (bServer) then
                g_ATOMBoids:SoundEvent(hCreature, "walk")
            end
            --Msg(0,iAnimSpeed..","..iSpeed)
        end

        if (sAnim) then
            if (sAnim ~= hCreature.CURRENT_ANIMATION or (iAnimStart ~= hCreature.ANIMATION_START) or (iAnimSpeed ~= hCreature.ANIMATION_SPEED) or (timerexpired(hCreature.ANIMATION_TIMER, hCreature.ANIMATION_TIME))) then

                if (g_ATOMBoids.IS_CLIENT) then
                    hEntity:StopAnimation(0, 8)
                    if (iAnimTime) then
                        hEntity:StopAnimation(0, -1)
                    end
                    hEntity:StartAnimation(0, sAnim, 8, 0, iAnimSpeed, true)
                    if (iAnimStart) then
                        hEntity:SetAnimationTime(0, 8, iAnimStart)
                    end

                    hCreature.CURRENT_ANIMATION = sAnim
                    hCreature.ANIMATION_TIMER = timerinit()
                    hCreature.ANIMATION_TIME = ((iAnimTime or hEntity:GetAnimationLength(0, sAnim)) / iAnimSpeed)
                    hCreature.ANIMATION_SPEED = iAnimSpeed
                    hCreature.ANIMATION_START = iAnimStart
                end
            end
        elseif (bFreefall and hCreature.CURRENT_ANIMATION) then

            hEntity:StopAnimation(0, -1)
            hCreature.CURRENT_ANIMATION = nil
        end
    end,
    ---------------------------------------------------------
    -- SoundEvent
    SoundEvent = function(self, hCreature, sEvent)

        local hEntity = hCreature.hEntity
        local aSounds = hCreature.Properties.SoundEvents[sEvent]
        if (not aSounds) then
            return
        end

        if (not hCreature.SoundTimers[sEvent]) then
            hCreature.SoundTimers[sEvent] = {}
        end
        if (not timerexpired(hCreature.SoundTimers[sEvent][1], hCreature.SoundTimers[sEvent][2])) then
            return
        end

        local sSound = (isArray(aSounds) and GetRandom(aSounds) or aSounds)

        hCreature.SoundTimers[sEvent][1] = timerinit()
        hCreature.SoundTimers[sEvent][2] = math.frandom(6, 12)
        ExecuteOnAll([[
        local hEnt = GetEnt(']].. hEntity:GetName() ..[[')
        if (hEnt) then
            if (hEnt.SoundSlot) then
                hEnt:StopSound(hEnt.SoundSlot)
            end
            hEnt.SoundSlot = hEnt:PlaySoundEvent(']].. sSound ..[[', g_Vectors.v000, g_Vectors.v010, SOUND_EVENT, SOUND_SEMANTIC_SOUNDSPOT)
        end
        ]])

    end,
    ---------------------------------------------------------
    -- Destructor
    Shutdown = function(self)
    end,
}

ATOMBoids:Init()