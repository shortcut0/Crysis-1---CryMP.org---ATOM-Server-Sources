ATOMPlayerUtils = {

	InitServer = function(self, entity)
		entity.GetIdentifier = function(self)
			return "-1";
		end;
		entity.IsSuspended = function(self)
			return false
		end;
	end,

	InitPlayer = function(player, channelId, bIsBot)

		player.bKillMessages = false
		player.Popups = false
		player.bIsMoving = false
		player.iMovingSpeed = 0
		player.iTimeLastMoved = 0
		player.LastSvImpulse = 0

		player.lastPortalTeleports = {}
		player.aGrantedAuths = {}
		player.aPiggyNPCs = {}

		player.CurrentMapCoords = "A0"

		player.LastHitTime = 0
		player.LastInteractiveActivity = _time - 999;

		player.Popups = true
		player.LastDeathTime = 0
		player.RageQuitImpossible = false;
		player.DeathKills = true

		player.actorStats.UseDefaultEquipment	 = false
		player.actorStats.testingMode			 = false
		player.actorStats.VIPTag				 = false

		player.aInstantReviveTriggers		 = checkArray(player.aInstantReviveTriggers, {});
		player.aSpawnLocations				 = checkArray(player.aSpawnLocations, {});

		player.bInit = true

		if (bIsBot) then
			if (player.ATOM_BOT_INITIALIZED) then
				return
			end

			player.ATOM_BOT_INITIALIZED = true
			player.isPlayer = false
			player.isBot = true

			player.GetChannel = function() return 0 end
		end

		GENDER_MALE = 0
		GENDER_FEMALE = 1
		GENDER_UNKNOWN = 2

		GENDER_NAMES = {
			[0] = "Male",
			[1] = "Female",
			[2] = "Other",
		}

		AUTHLIST_TRUSTED = 0
		AUTHLIST_ALL = 1

		local sAuth_List = "ViewAuthList"
		local sAuth_Modify = "AuthModify"
		local sAuth_Access = "ExtendedAccess"

		AUTHORIZATION_NAMES = {
			[sAuth_List] = "View Auth List",
			[sAuth_Modify] = "Auth Modify",
			[sAuth_Access] = "Extended Mod. Access",
		}

		AUTHORIZATION_LIST = {
			sAuth_List,
			sAuth_Modify,
			sAuth_Access
		}

		AUTHORIZATION_LIST_TRUSTED = {
			sAuth_List,
			sAuth_Modify,
			sAuth_Access
		}

		player.GetCurrentItemClass = function(self)
			local hItem = self:GetCurrentItem()
			return (hItem and hItem.class or nil)
		end

		player.Clone = function(self, bClean)

			local sName = string.format("Clone %d", g_utils:SpawnCounter())
			local sEquip = self:GetCurrentItemClass()
			local vPos = self:CalcPos(2.5)
			local vAng = self:GetAngles()

			if (not bClean) then
				sName = (self:GetName() .. sName)
				sEquip = nil
			end

			local hClone = System.SpawnEntity({
				class = "Player",
				position = vPos,
				orientation = vAng,
				name = sName
			})

			if (not hClone) then
				return
			end

			ATOMPlayerUtils.InitPlayer(hClone, 0, true)
			if (sEquip) then
				ItemSystem.GiveItem(sEquip, hClone.id, true)
				hClone.actor:SelectItemByName(sEquip)
			end

			return hClone
		end

		player.HasStance = function(self, iStance)
			local iCurrStance = self.actorStats.stance
			return (iCurrStance == iStance)
		end

		player.GetStance = function(self, iStance)
			local iCurrStance = self.actorStats.stance
			if (iStance) then
				return (iCurrStance == iStance)
			end
			return (iCurrStance)
		end

		player.GetAuthName = function(self, sAuthMode)
			if (not sAuthMode) then
				return "Unknown"
			end
			return checkVar(AUTHORIZATION_NAMES[sAuthMode], sAuthMode)
		end

		player.GetAuthList = function(self, iAuthList)

			local aList = table.copy(AUTHORIZATION_LIST)

			if (iAuthList) then
				if (iAuthList == AUTHLIST_TRUSTED) then
					aList = table.copy(AUTHORIZATION_LIST_TRUSTED)
				elseif (iAuthList == AUTHLIST_ALL) then

				else
					aList = {}
				end

			end
			return aList
		end

		player.HasAuthorization = function(self, sAuthMode)
			if (not sAuthMode) then
				return false
			end
			return self.aGrantedAuths[sAuthMode] == true
		end

		player.SetAuthorization = function(self, sAuthMode, bEnable)
			if (not sAuthMode) then
				return false
			end

			if (bEnable ~= true) then
				self.aGrantedAuths[sAuthMode] = nil
			else
				self.aGrantedAuths[sAuthMode] = true
			end
		end

		player.GetGender = function(self, iGender)
			if (iGender) then
				return self.iGender == iGender
			end
			return self.iGender
		end
		player.SetGender = function(self, iGender)
			if (not iGender) then
				return
			end

			if (not (GENDER_NAMES[iGender])) then
				return
			end

			self.sGender = GENDER_NAMES[iGender]
			self.iGender = iGender
		end

		player.DeleteInstantRevive = function(self, sID)

			local bRevive = self.aInstantReviveTriggers[sID]
			if (not bRevive) then
				return
			end

			self.bRevive[sID] = nil
		end

		player.SetInstantRevive = function(self, bSet, sID)


			local sID = checkVar(sID, "Default_Instant_Revive")
			self.aInstantReviveTriggers[sID] = bSet
			if (bSet == false or bSet == 0) then
				self:DeleteInstantRevive(sID)
			end

			return sID
		end

		player.CanInstantRevive = function(self)

			for i, bRevive in pairs(self.aInstantReviveTriggers) do
				if (bRevive == true or bRevive == 1) then
					return true
				end
			end

			return false
		end

		player.RemoveSpawnLocation = function(self, sID)

			local aLocation = self.aSpawnLocations[sID]
			if (not aLocation) then
				return
			end

			self.aSpawnLocations[sID] = nil
		end

		player.SetSpawnLocation = function(self, aProps, sID)

			local sID = checkVar(sID, "SpawnLoc_" .. table.count(self.aSpawnLocations))
			self.aSpawnLocations[sID] = {
				Pos = aProps.Pos,
				Ang = aProps.Ang,
				Offset = aProps.Offset,
				Condition = aProps.Condition,
				Priority = checkNumber(aProps.Priority, 0),
			}

			return sID
		end

		player.ChangeSpawnLocation = function(self, sID, aProps)

			local aLocation = self.aSpawnLocations[sID]
			if (not aLocation) then
				return
			end

			self.aSpawnLocations[sID] = table.merge(self.aSpawnLocations[sID], aProps, true)
		end

		player.GetSpawnLocation = function(self)

			local vPos, vAng, iOffset
			local iHighestScore = -999
			for i, aLocation in pairs(self.aSpawnLocations) do
				if ((not aLocation.Condition or (aLocation.Condition(self)) == true) and checkNumber(aLocation.Priority, 0) > iHighestScore) then

					vPos, vAng, iOffset =
					self.aSpawnLocations[i].Pos,
					self.aSpawnLocations[i].Ang or self.aSpawnLocations[i].Dir,
					self.aSpawnLocations[i].iOffset or 0.1

					iHighestScore = checkNumber(self.aSpawnLocations[i].Priority, 0)

				end
			end

			return vPos, vAng, iOffset

		end

		player.DoPainSounds = function(self, bDead)
		end

		player.ToggleVIPTag = function(self, mode)
			self.actorStats.VIPTag = mode;
			return self.actorStats.VIPTag;
		end;

		player.DefaultEquipment = function(self)
			return self.actorStats.UseDefaultEquipment;
		end;

		player.HasItem = function(self, sClass)
			return self.inventory:GetItemByClass(sClass);
		end;

		player.GiveItem = function(self, sClass, bSelect)
			if (not g_dll:IsValidEntityClass(sClass)) then
				return
			end

			if (self:HasItem(sClass)) then
				return
			end

			ItemSystem.GiveItem(sClass, self.id, true)
			if (bSelect) then
				self.actor:SelectItemByName(sClass)
				self.actor:SelectItemByNameRemote(sClass)
			end
		end;

		player.IsTesting = function(self)
			return self.actorStats.testingMode;
		end;

		player.SetTestingMode = function(self, mode)
			self.actorStats.testingMode = mode;
			return self.actorStats.testingMode;
		end;

		if (not player.Old_AddImpulse) then
			player.Old_AddImpulse = player.AddImpulse;
		end;

		player.AddImpulse = function(self, slot, pos, dir, strength, scale, ...)
			if (self.LastClientImpulse and _time - self.LastClientImpulse < 0.08) then
				return;
			end;
			if (strength < 80) then
				return end
			self.LastClientImpulse = _time;
			ExecuteOnPlayer(self, formatString([[
				g_localActor:AddImpulse(%d, %s, %s, %0.3f, %0.3f);
			]], slot, arr2str_(pos), arr2str_(dir), strength, scale));
			self.LastSvImpulse = _time

			return self:Old_AddImpulse(slot, pos, dir, strength, scale, ...);
		end;

		player.AddImpulse_All = function(self, slot, pos, dir, strength, scale, ...)
			if (self.LastClientImpulse and _time - self.LastClientImpulse < 0.1) then
				return;
			end;
			self.LastClientImpulse = _time;
			ExecuteOnAll(formatString([[
				local n=%d;
				local p=GP(n);
				if (p) then
				p:AddImpulse(%d, %s, %s, %0.3f, %f);
				end;
			]], self.actor:GetChannel(), slot, arr2str_(pos), arr2str_(dir), strength, scale));
			return self:Old_AddImpulse(slot, pos, dir, strength, scale, ...);
		end;

		player.AddServerImpulse = function(self, slot, pos, dir, strength, scale, ...)
			return self:Old_AddImpulse(slot, pos, dir, strength, scale, ...);
		end;

		player.GetHealth = function(self)
			return self.actor:GetHealth() or 0
		end;

		player.IsAlive = function(self)
			return self.actor:GetHealth() > 0 and self.actor:GetSpectatorMode() == 0;
		end;

		player.IsFrozen = function(self)
			return (self.actorStats.isFrozen == true)
		end;

		player.PiggyRide = function(self, hTarget, bMount)
			if (not hTarget or hTarget.id == self.id) then
				return
			end

			if (bMount and (hTarget:IsDead() or hTarget:IsSpectating() or self:IsDead() or self:IsSpectating())) then
				return
			end

			if (self.hPiggy and self.hPiggy.id ~= hTarget.id) then
				Debug("already one")
				self:PiggyRide(self.hPiggy, false)
				return
			end

			if (self.hPiggy and self.hPiggy.id == hTarget.id and bMount) then
				Debug("cant mount twice")
				return
			end

			local iChannelRider = self:GetChannel()
			local iChannelPig = hTarget:GetChannel()

			local sGetEntRider = string.format("GP(%d)", iChannelRider)
			if (iChannelRider == 0) then
				sGetEntRider = string.format("GetEnt('%s')", checkString(self:GetName(), "null_name"))
			end

			local sGetEntPig = string.format("GP(%d)", iChannelPig)
			if (iChannelPig == 0) then
				sGetEntPig = string.format("GetEnt('%s')", checkString(hTarget:GetName(), "null_name"))
			end

			if (not bMount) then

				Debug("dismount ",hTarget:GetName())
				ExecuteOnAll([[
				local hPig, hRider = ]] .. sGetEntPig .. [[, ]] .. sGetEntRider .. [[
				if (hPig) then
					PIGGY_RIDERS[hPig.id] = nil
				end

				if (hRider) then
					hRider:DetachThis()
					LOOPED_ANIMS[hRider.id] = nil
					hRider:SetColliderMode(0)
					hRider:StopAnimation(0, 8)
				end
				]])
				if (self.iPiggybackSync) then
					RCA:StopSync(self, self.iPiggybackSync)
				end

				hTarget.hPiggyRider = nil
				self.hPiggy = nil
				self.bPiggyRiding = false
				self.iPiggybackSync = nil
			else
				hTarget.hPiggyRider = self
				self.bPiggyRiding = true
				self.hPiggy = hTarget
				self.iPiggyChannel = hTarget:GetChannel()


				local sCode = [[
				local hPig, hRider = ]] .. sGetEntPig .. [[, ]] .. sGetEntRider .. [[
				if (not hPig or not hRider) then
					return
				end

				PIGGY_RIDERS[hPig.id] = {
					Rider = hRider
				}

				if (hRider.id ~= g_localActorId) then
					hPig:AttachChild(hRider.id, 1)
				end
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
				]]
				ExecuteOnAll(sCode)
				if (self.iPiggybackSync) then
					RCA:StopSync(self, self.iPiggybackSync)
				end
				self.iPiggybackSync = RCA:SetSync(self, { links = { self.id, hTarget.id }, client = sCode})
			end
		end;

		player.ReleaseGrab = function(self, hGrabber, iReleaseImpulse)
			if (hGrabber and hGrabber.id == self.id) then
				return
			end

			if (not self.bGrabbed) then
				return
			end

			self.bGrabbed = false
			self.hGrabber = nil
			self.iGrabTime = nil

			if (hGrabber) then
				hGrabber.hGrabbing = nil
				if (hGrabber.hGrabSyncID) then
					RCA:StopSync(hGrabber, hGrabber.hGrabSyncID)
					hGrabber.hGrabSyncID = nil
				end
			end

			ExecuteOnAll("ATOMClient.GrabHandler:Drop(GP(" .. self:GetChannel() .. "), GP(" .. (hGrabber and hGrabber:GetChannel() or "") .. "))")
			if (iReleaseImpulse) then
				Script.SetTimer(100, function()
					local vDir = vector.scale(self.actor:GetHeadDir(), -1)
					if (hGrabber) then
						vDir = hGrabber.actor:GetHeadDir()
					end
					self:AddImpulse(-1, self:GetCenterOfMassPos(), vDir, iReleaseImpulse, 1)
				end)
			end
		end

		player.DropNPC = function(self, hNPC, iReleaseImpulse)
			if (hNPC and hNPC.id == self.id) then
				return
			end

			if (not hNPC.bGrabbed) then
				return
			end

			if (hNPC.isPlayer) then
				return
			end

			hNPC.bGrabbed = false
			hNPC.hGrabber = nil

			self.hGrabbing = nil
			self.iGrabTime = nil

			if (self.hGrabSyncID) then
				RCA:StopSync(self, self.hGrabSyncID)
				self.hGrabSyncID = nil
			end

			ExecuteOnAll("ATOMClient.GrabHandler:Drop(GP(" .. "\"" .. hNPC:GetName() .. "\"" .. "), GP(" .. (self:GetChannel()) .. "))")


			Script.SetTimer(75, function()
				hNPC:SetWorldPos(self:CalcPos(2.5))
			end)

			if (iReleaseImpulse) then
				Script.SetTimer(125, function()
					local vDir = self.actor:GetHeadDir()
					hNPC:AddImpulse_All(-1, hNPC:GetCenterOfMassPos(), vDir, iReleaseImpulse, 1)
				end)
			end
		end

		player.GrabPlayer = function(self, hTarget, bGrab, iReleaseImpulse)
			if (not hTarget or hTarget.id == self.id) then
				return
			end

			if (hTarget.actor:GetHealth() <= 0 or hTarget:IsSpectating()) then
				return
			end

			if (self.actor:GetHealth() <= 0 or self:IsSpectating()) then
				return
			end

			if (hTarget:GetSpeed() > 2.5 and not hTarget.bGrabbed) then
				return SendMsg(ERROR, self, "You can only Grab a player when they are stationary")
			end

			hTarget.iGrabTime = _time

			local iChannel = hTarget:GetChannel()
			if (iChannel == 0) then
				iChannel = "\"" .. hTarget:GetName() .. "\""
			end
			local sCode = "ATOMClient.GrabHandler:Grab(GP(" .. self:GetChannel() .. "), GP(" .. iChannel .. "))"
			local bGrab = bGrab
			if (bGrab == nil and not self.hGrabbing) then
				bGrab = true
			end

			if (hTarget.bGrabbed) then
				if (not bGrab and hTarget.hGrabber == self) then

					if (hTarget.isBot) then
						self:DropNPC(hTarget, iReleaseImpulse)
						Debug("NPc off")
					else

						if (self.hGrabSyncID) then
							RCA:StopSync(self, self.hGrabSyncID)
							self.hGrabSyncID = nil
						end

						local vDeathPos = hTarget.hGrabber:GetPos()

						hTarget.iGrabTime = nil
						hTarget.bGrabbed = nil
						hTarget.hGrabber = nil
						self.hGrabbing = nil
						ExecuteOnAll("ATOMClient.GrabHandler:Drop(GP(" .. hTarget:GetChannel() .. "), GP(" .. self:GetChannel() .. "))")
						--Debug("IMPUUUUUUUUULSE",iReleaseImpulse)
						if (iReleaseImpulse) then
							Script.SetTimer(100, function()
								hTarget:SetPos(vDeathPos)
								g_game:MovePlayer(hTarget.id, vDeathPos, hTarget:GetAngles())
								ExecuteOnAll([[local x=GP(]]..hTarget:GetChannel()..[[)if(x) then x:SetPos(]]..vector.tostring(vDeathPos)..[[)end]])
								hTarget:AddImpulse(-1, hTarget:GetCenterOfMassPos(), self.actor:GetHeadDir(), iReleaseImpulse, 1)
								--if (hTarget:IsAlive() and not hTarget:IsSpectating()) then

								--	hTarget.lastFallTime = _time
								--	hTarget.falling = true
								--end
								--Debug("IMPUUUUUUUUULSE")
							end)
						end
					end
					return
				end
				return
			elseif (not bGrab) then
				return
			end

			if (hTarget.bPiggyRiding and hTarget.hPiggy.id == self.id) then
				--Debug("cant grab our rider!!")
				return
			end

			if (hTarget.bPiggyRiding) then
				--Debug("cant grab piggy riders!!")
				return
			end

			if (self.bPiggyRiding) then
				--Debug("Cant pick upwhile PIGGY RIDING!!")
				return
			end


			--Debug("piggy name",self.hPiggy:GetName(),"target name",hTarget:GetName())
			--do return end

			hTarget.bGrabbed = true
			hTarget.hGrabber = self
			self.hGrabbing = hTarget
			if (self.hGrabSyncID) then
				RCA:StopSync(self, self.hGrabSyncID)
			end
			self.hGrabSyncID = RCA:SetSync(self, { client = sCode, links = { self.id, hTarget.id }})
			ExecuteOnAll(sCode)
		end;

		player.CanSee = function(self, what)
			local t = type(what);
			local p;
			if (t == "table" ) then
				if (what.GetPos) then
					p = what:GetPos();
				else
					p = makeVec(what.x, what.y, what.z);
				end;
			elseif ( t == "userdata" ) then
				p = (GetEnt(what) and GetEnt(what:GetPos()) or g_dll:GetProjectilePosition(what));
			end;

			if (p) then
				--Debug("pos.")
				--Debug(Physics.RayTraceCheck(player:GetHeadPos(), p, player.id, player.id))
				return Physics.RayTraceCheck(player:GetHeadPos(), p, player.id, player.id);
			end;
		end;

		player.GetPrestige = function(self)
			return ATOMPlayerUtils:GetPlayerPP(self);
		end;

		player.SetPrestige = function(self, amount)
			return ATOMPlayerUtils:SetPlayerPP(self, amount);
		end;

		player.SetRank = function(self, rank)
			return ATOMPlayerUtils:SetRank(self, minimum(1, maximum(10, rank)));
		end;

		player.PayPrestige = function(self, amount)
			return ATOMPlayerUtils:PayPrestige(self, amount);
		end;

		player.GivePrestige = function(self, amount)
			return ATOMPlayerUtils:GivePP(self, amount);
		end;

		player.GiveCP = function(self, amount)
			return ATOMPlayerUtils:GiveCP(self, amount);
		end;

		player.GetAveragePing = function(self)
			return self.actorStats.averagePing;
		end;

		player.CalcSpawnPos = function(self, distance, height)
			return CalcSpawnPos(self, distance, height);
		end;

		player.CalcPos = function(self, distance, height)
			return CalcPos(self:GetHeadPos(), self:GetHeadDir(), distance, height);
		end;

		player.GetPosInFront = function(self, distance, height)
			return CalcPos(self:GetPos(), self.actor:GetHeadDir(), distance, height)
		end

		player.IsIndoors = function(self, p)
			return System.IsPointIndoors(p or self:GetPos())
		end

		player.IsInitialized = function(self, p)
			return (self._initialized and (_time - self._initialized >= (p or -999)))
		end

		player.SetPreference = function(self, sKey, sValue)
			return (ATOMPlayerPerfs:SetValue(self, sKey, sValue))
		end

		player.IsHoldingMouse = function(self, L)
			if (L) then
				--	Debug("L",self.LMouseHeld)
				return self.LMouseHeld == true
			else
				return self.MouseHeld == true
			end
		end

		player.GetUsedSeat = function(self)
			local V = self:GetVehicle()
			if (V) then
				local S
				for i, v in pairs(V.Seats) do
					if (v:GetPassengerId() == self.id) then
						return v
					end
				end
			end
			return nil
		end

		player.GetSeatWeapon = function(self, tSeat, id)
			local V = self:GetVehicle()
			local F = {}
			if (V or tSeat) then
				local seat = (tSeat or self:GetUsedSeat())
				local wc = seat.seat:GetWeaponCount()
				for j = 1, wc do
					local weaponid = seat.seat:GetWeaponId(j)
					if (weaponid) then
						table.insert(F, GetEnt(weaponid))
					end
				end
			end
			return ((id and id == -1) and F or F[(id or 1)])
		end

		player.GetVehicleWeapon = function(self, weaponId)
			local V = self:GetVehicle()
			if (V) then
				local A = self:GetSeatWeapon(nil, -1)
				if (A) then
					for i, v in pairs(A) do
						if (v.id == weaponId) then
							return v
						end
					end
				end
			end
			return
		end

		player.GetVehicle = function(self)
			local vehicleId = self.actor:GetLinkedVehicleId()
			if (vehicleId) then
				return GetEnt(vehicleId)
			end
			return
		end

		player.LeaveVehicle = function(self, vehicle)
			local vehicle = vehicle or self:GetVehicle();
			if (vehicle) then
				return vehicle.vehicle:ExitVehicle(self.id, false)
			end
			return
		end

		player.GetSeatId = function(self)
			local vehicleId = self.actor:GetLinkedVehicleId();
			if (vehicleId) then
				local vehicle = GetEnt(vehicleId);
				for i, seat in pairs(vehicle.Seats) do
					if (seat:GetPassengerId() == self.id) then
						return i
					end
				end
			end
			return
		end;

		player.IsAlone = function(self, range, mustBeAlive)
			return IsPlayerAlone(self, range or 25, mustBeAlive or true)
		end

		player.GetLean = function(self)
			return self.actor.IsLeaning and self.actor:IsLeaning() or 0;
		end

		LEAN_RIGHT = 1
		LEAN_NONE = 0
		LEAN_LEFT = -1

		player.IsLeaning = function(self, eLeanMode)
			local leanMode = self:GetLean()
			if (eLeanMode) then
				return leanMode == eLeanMode
			end
			return leanMode == LEAN_NONE
		end

		player.GetSuitMode = function(self, tmode)
			local mode = self.actor:GetNanoSuitMode();
			if (tmode) then
				return mode == tmode
			end
			return mode
		end

		player.GetSuitEnergy = function(self, tenergy)
			local energy = self.actor:GetNanoSuitEnergy();
			if (tenergy) then
				return energy>tenergy;
			end;
			return energy;
		end;


		player.GetCP = function(self)
			local CP = g_game:GetSynchedEntityValue(player.id, g_gameRules.CP_AMOUNT_KEY) or 0;
			return CP;
		end;

		player.GetRank = function(self)
			local rank = g_game:GetSynchedEntityValue(player.id, g_gameRules.RANK_KEY) or 1;
			return rank;
		end;

		player.IsAFK = function(self)
			return self.AFK ~= nil;
		end;

		player.ShowMessage = function(self, t)
			local fId = System.GetFrameID();
			self.messageFrameIDs = self.messageFrameIDs or {};
			if (not self.messageFrameIDs[t]) then
				self.messageFrameIDs[t] = fId;
				return true;
			end;
			if (self.messageFrameIDs[t] == fId) then
				Debug("HIDE",t)
				self.messageFrameIDs[t] = fId;
				return false;
			end;
			self.messageFrameIDs[t] = fId;
			Debug("show",t)
			return true;
		end;

		player.IsSpectating = function(self)
			return self.actor:GetSpectatorMode() ~= 0;
		end;

		player.GetSpectatorTarget = function(self)
			local id = self.actor:GetSpectatorTarget();
			return id and System.GetEntity(id) or nil;
		end;

		player.ToggleGodMode = function(self, megaGod)
			ATOMPlayerUtils:ToggleGODMode(self, megaGod);
		end;

		player.IsInGodMode = function(self)
			return self.godMode == true;
		end;

		player.InGodMode = function(self)
			return self:IsInGodMode();
		end;

		player.IsUnderwater = function(self, d)
			return ATOMDLL.IsUnderwater and ATOMDLL:IsUnderwater(self:GetPos()) or false;--ATOMPlayerUtils:IsPositionUnderwater(self:GetPos(), d);
		end;

		player.GetCurrentItem = function(self)
			return self.inventory:GetCurrentItem();
		end;

		player.GetTeam = function(self)
			return g_game:GetTeam(self.id);
		end;

		player.GetPing = function(self)
			local ping = math.floor((g_game:GetPing(self:GetChannel()) or 0) * 1000 + 0.5);
			return ping or 0;
		end;

		player.CurrentItemChanged = function(self, ...)
			return ATOMPlayerUtils:OnItemChanged(self, ...);
		end;

		player.GetHitPos = function(self, ...)
			return ATOMPlayerUtils:GetHitPos(self, ...);
		end;

		player.GetHeadDir = function(self)
			if (not self:GetVehicle()) then
				return self.actor:GetHeadDir();
			end;
			return self.actor:GetVehicleDir();
		end;

		player.GetHeadPos = function(self)
			return self.actor:GetHeadPos();
		end;

		player.GetPelvisPos = function(self)
			return (self:GetBonePos("Bip01 Pelvis"))
		end

		player.CanSeePosition = function(self, pos)
			return (isPntVisible(self:GetHeadDir(), GetDir(pos, self.actor:GetHeadPos(), 1, true)));
		end;

		player.HitEntity = function(self, entity, damage, pos, dir)
			--.ServerHit(targetId, shooterId, weaponId, dmg, radius, material\Id, partId, typeId, [pos], [dir], [normal])
			g_gameRules:CreateHit(entity.id, self.id, (--[[self.inventory:GetCurrentItem()]]nil or self).id, damage, 1, 'mat_default', -1, "normal", (pos or entity:GetPos()), (dir or  g_Vectors.v000), g_Vectors.up)
		end;

		player.GetSuitName = function(self)
			local names = {
				[NANOMODE_DEFENSE]	= "Defense",
				[NANOMODE_SPEED]	= "Speed",
				[NANOMODE_STRENGTH]	= "Strength",
				[NANOMODE_CLOAK]	= "Cloak",
			};
			return names[self.actor:GetNanoSuitMode()];
		end;
		--player.GetEXP = function(self)
		--	return self.stats.EXPTotal;
		--end;

	end;
	------------------
	OnItemChanged = function(self, player, newItemId, lastItemId)
		
		local item = System.GetEntity(newItemId);
		ATOMBroadcastEvent("OnItemChanged", player, item, GetEnt(lastItemId));
		if (item) then
			ATOMEquip:ItemSelected(player, item);
		end;
		
		if (item and AI_ENABLED) then
			local weapon = item.weapon;
			
			local entityAccessoryTable = SafeTableGet(self.AI, "WeaponAccessoryTable");
			if (weapon and entityAccessoryTable) then 
			
				if (weapon:GetAccessory("Silencer") or item.class == "Fists") then
					entityAccessoryTable["Silencer"] = 1;
					self.AI.Silencer = true;
				else
					entityAccessoryTable["Silencer"] = 0;
					self.AI.Silencer = false;
				end;
				
				if (weapon:GetAccessory("SCARIncendiaryAmmo")) then
					entityAccessoryTable["SCARIncendiaryAmmo"] = 2;
					entityAccessoryTable["SCARNormalAmmo"] = 0;
				elseif (weapon:GetAccessory("SCARNormalAmmo")) then
					entityAccessoryTable["SCARIncendiaryAmmo"] = 0;
					entityAccessoryTable["SCARNormalAmmo"] = 2;
				end;
				self:SetTimer(SWITCH_WEAPON_TIMER,2000);
			end;
		end;
	end;
	------------------
	GetHitPos = function(self, player, distance, types, pos, dir)
		local distance = distance or 4086;
		local entities = types or ent_all;
		local dir = dir or player:GetHeadDir();
		local hits = Physics.RayWorldIntersection((pos or player.actor:GetHeadPos()), vecScale(dir, distance), distance, entities, player:GetVehicle() and player:GetVehicle().id or player.id, nil, g_HitTable);
		local hit = g_HitTable[1];
		if (hits and hits > 0) then
			hit.surfaceName = System.GetSurfaceTypeNameById( hit.surface )
			return hit;
		end;
		return;
	end;
	------------------
	IsPositionUnderwater = function(self, pos, dist)
		local water = CryAction.GetWaterInfo(pos);
		local d = water-pos.z;
		return (d>(dist or 0)), d;
	end;
	------------------
	OnPlayerTick = function(self, player)
		if (player:InGodMode()) then
			player.actor:SetNanoSuitEnergy(200);
			player.actor:SetHealth(100);
			g_game:SetInvulnerability(player.id, true, 1);
		end;
		ATOMNames:OnDisconnect(player);
	end;
	------------------
	ToggleGODMode = function(self, player, megaGod)
		if (not player.godMode) then
			if (player:IsDead()) then
				g_game:RevivePlayer(player.id, player:GetPos(), player:GetAngles(), g_game:GetTeam(player.id), true)
				g_utils:RevivePlayer(player, player, false)
			end;
			player.godMode = true;
			player.megaGod = megaGod;
			player.invulnerable = true;
			player.actor:SetNanoSuitEnergy(200);
			player.actor:SetHealth(100);
			g_game:SetInvulnerability(player.id, true, 1);
			g_gameRules.game:ForbiddenAreaWarning(false, 0, player.id);
			player.actor:ToggleMode(ACTORMODE_GOD, true);
			if (megaGod) then
				player.actor:ToggleMode(ACTORMODE_MEGAGOD, true);
				player.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, true);
				player.actor:ToggleMode(ACTORMODE_UNLIMITEDENERGY, true);
				player.actor:ToggleMode(ACTORMODE_UNLIMITEDAMMO, true);
				
			end;
		else
			player.actor:ToggleMode(ACTORMODE_GOD, false);
			player.actor:ToggleMode(ACTORMODE_MEGAGOD, false);
			player.actor:ToggleMode(ACTORMODE_NOWEAPONLIMIT, false);
			player.actor:ToggleMode(ACTORMODE_UNLIMITEDENERGY, false);
			player.actor:ToggleMode(ACTORMODE_UNLIMITEDAMMO, false);
			player.megaGod = false;
			player.godMode = false;
			player.invulnerable = false;
		end;
		
		ATOM:ChangeCapacity(player)
	end;
	------------------
	PayPrestige = function(self, player, value)
		--Debug(value,">",player:GetPrestige(),">",player:GetPrestige() - value)
		if (value) then
			g_gameRules:SetPlayerPP(player.id, math.max(0, player:GetPrestige() - value));
		end;
	end;
	------------------
	SetPlayerPP = function(self, player, value)
		g_gameRules:SetPlayerPP(player.id, math.min(MAXIMUM_NUMBER_DISPLAY, value));
	end;
	------------------
	SetRank = function(self, player, value)
		g_gameRules:SetPlayerRank(player.id, value);
	end;
	------------------
	GivePP = function(self, player, value)
		if (player:GetPrestige() + value >= MAXIMUM_NUMBER_DISPLAY) then
			value = MAXIMUM_NUMBER_DISPLAY - player:GetPrestige();
		end;
		g_gameRules:AwardPPCount(player.id, value, nil, true);
	end;
	------------------
	GiveCP = function(self, player, value)
		g_gameRules:AwardCPCount(player.id, value);
	end;
	------------------
	GetPlayerPP = function(self, player)
		local pp = 0;
		if (g_gameRules.class == "PowerStruggle") then
			pp = g_gameRules:GetPlayerPP(player.id);
		end;
		return pp;
	end;
	------------------
	Init = function(self)
	
		ACTORMODE_GOD 				= 0;
		ACTORMODE_MEGAGOD 			= 1;
		ACTORMODE_NOWEAPONLIMIT 	= 2;
		ACTORMODE_UNLIMITEDENERGY 	= 3;
		ACTORMODE_UNLIMITEDAMMO		= 4;
		
		if (g_localActor) then
		--	self.InitPlayer(g_localActor);
		end
	end,
};

ATOMPlayerUtils:Init()
