ATOMDefense = {
	cfg = {
		CheatOptions = {
			Detect = {
				-- the famous crysis hack
				{ "LongPoke", Options = {
					Detect = true;
					Ban = true; -- ban player
					BanTime = "Infinite"; -- ban time, in minutes
					Kick = false; -- kick player
					Force = false; -- also kick admins
					IgnoreLaggers = false;
				}};
				-- all kinds of lua RMI manipulations
				{ "LuaHax", Options = {
					Detect = true;
					Ban = false; -- ban player
					BanTime = 0; -- ban time 
					Kick = true; -- kick player
					Force = false; -- also kick admins
					IgnoreLaggers = false;
				}};
				-- all kinds of item hacks
				{ "ItemHax", Options = {
					Detect = true;
					Ban = false; -- ban player
					BanTime = 0; -- ban time 
					Kick = true; -- kick player
					Force = false; -- also kick admins
					IgnoreLaggers = false;
				}};
			};
		
		};
		CheaterOptions = {
		
			BanClasses = {
				[MODERATOR] = false;
			};
			--LoosePremium = true; -- cheaters who gained premium rank will be dismissed from premium members and are unable to gain premium by playtime again
		};
	};
	--------------
	Init = function(self)
	
		eCR_FireRate 	= 0
		eCR_NoRecoil	= 1
		eCR_LowRecoil	= 2
		eCR_NoSpread	= 3
		eCR_LowSpread	= 4
		
		SERVER_DEFENSE 	= true
		
	end,
	--------------
	OnReportReceived = function(self, player, case, p1, p2)

		local iTimeThreshold = 1.25
		if (case == eCR_FireRate) then
			if (player.fireTime and _time - player.fireTime < iTimeThreshold) then
				if (p1 < 300) then
					player.iFireRateCheats = (player.iFireRateCheats or 0) + 1
					if (player.iFireRateCheats >= 3) then
						self:OnCheat(player, "FireRate", "Client Fire Rate: " .. p1, false)
					end
				end
			end
		elseif (case == eCR_NoRecoil) then
			if (player.fireTime and _time - player.fireTime < iTimeThreshold) then
				if (p1 < 0.0015) then
					player.iRecoilCheats = (player.iRecoilCheats or 0) + 1
					if (player.iRecoilCheats >= 3) then
						self:OnCheat(player, "No Recoil", "Client Recoil: " .. p1, false)
					end
				end
			end
		elseif (case == eCR_LowRecoil) then
			if (player.fireTime and _time - player.fireTime < iTimeThreshold) then
				if (p1 < 0.003) then
					self:OnCheat(player, "Low Recoil", "Client Recoil: " .. p1, false)
				end
			end
		elseif (case == eCR_NoSpread) then
			if (player.fireTime and _time - player.fireTime < iTimeThreshold) then
				if (p1 < 0.05) then
					player.iNoSpreadCheats = (player.iNoSpreadCheats or 0) + 1
					if (player.iNoSpreadCheats >= 3) then
						self:OnCheat(player, "No Spread", "Client Spread: " .. p1, false)
					end
				end
			end
		elseif (case == eCR_LowSpread) then
			if (player.fireTime and _time - player.fireTime < iTimeThreshold) then
				if (p1 < 0.1) then
					self:OnCheat(player, "Low Spread", "Client Spread: " .. p1, false)
				end
			end
		end
	end;
	--------------
	OnChatMessage = function(self, t, player, target, m)
		if (g_gameRules.class == "InstantAction" and t == ChatToTeam) then
			SysLog("Message was %s", m);
			return false, self:OnCheat(player, "Chat", "Invalid Game Mode", true)
		end
		return true
	end,
	--------------
	CanBan = function(self, playerAccess)
	end,
	--------------
	OnShootSpoof = function(self, hPlayer, hRealEntity)

		if (not timerexpired(hPlayer.hSPTimer, 0.250)) then


			hPlayer.hSPTimer = timerinit()
			hPlayer.iSPCount = (hPlayer.iSPCount or 0) + 1

			if (hPlayer.iSPCount >= 20) then
				self:OnCheat(hPlayer, "Shoot Spoof", "Shoot Spoof: " .. hPlayer.iSPCount, false, false)
				hPlayer.iSPCount = 0
			end

		end

		hPlayer.hSPTimer = timerinit()

	end,
	--------------
	OnCheat = function(self, player, cheat, info, sure, bForcedKick)

		-------------
		if (cheat == "GhostVegetation") then

			if (player:HasAuthorization("BypassBlockedCVars")) then
				ExecuteOnPlayer(player, "IGNORE_BLOCKED_CVARS=1")
				SysLog("Player %s has Ghost Vegetation but has authorization to do so.", player:GetName())
				return
			end

			player.iGhostVegetation = (player.iGhostVegetation or 0) + 1
			SendMsg({ CENTER, ERROR }, player, "The CVar ( r_ATOC ) IS FORBIDDEN ON THIS SERVER (Warning %d \\ 3)", player.iGhostVegetation)
			WarnPlayer(ATOM.Server, player, "Forbidden CVar (r_ATOC)")
			
			if (player.iGhostVegetation >= 3) then
				player.iGhostVegetation = 0
			end
		end

		-------------
		local bSpeedCheat = string.matchex(cheat,
			"Shoot Pos",
			"Teleport",
			"Speed"
		)

		-------------
		if (bSpeedCheat and not timerexpired(player.hSvWallJumpTimer, 7.5)) then
			return
		end

		-------------
		if (((cheat == "Shoot Pos") or (cheat == "Teleport") or (cheat == "Speed")) and ((_time - player.LastSvImpulse < 10) or (_time - (player.iLastSvTeleport or 0) < 10))) then
			return end
	
		-------------
		if (cheat == "Shoot Pos" and (player.CustomModel == true or player.HasSuperSwim or player.RunnerSpeed)) then
			return end
	
		-------------
		if ((cheat == "Teleport" or cheat == "Speed" or cheat == "VehicleTp") and ((player.ExitVehicleTime and (_time - player.ExitVehicleTime < 15) or player.MenuPush or player.HasSuperSwim or player.RunnerSpeed))) then
			return end
	
		-------------
		local bIsLagging = player.actor:IsLagging()
		local aCfg = self.cfg.CheatOptions[cheat]

		-------------
		local iHighestAccess = GetHighestAccess()
		local playerAccess = math.maxex(player:GetAccess() + 1, iHighestAccess)
	
		-------------
		local sCheater = (EntityName(player) or "<Unknown>")
		local sCheat = (cheat or "<Unknown>")
		local sCheatInfo = (info or "<No Further Information>")
		local sCheaterAccess = tostring(player.GetAccessString and player:GetAccessString() or "<Unknown>")
		local sCheaterProfile = tostring(player.GetProfile and player:GetProfile() or "<Unknown>")
		local sCheaterAlias = tostring(player.GetAlias and player:GetAlias() or "<Unknown>")
		local sCheaterCountry = tostring(player.GetCountry and player:GetCountry() or "<Unknown>")
		local sCheaterIP = tostring(player.GetIP and player:GetIP() or "<Unknown>")
		
		local sCheaterWeapon = checkVar(player:GetCurrentItem(), { class = "None" }).class
		local sCheaterVehicle = checkVar(player:GetVehicle(), { class = "None" }).class
		
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "%s: (%s): %s (Sure: %s)", sCheater, sCheat, sCheatInfo, (sure and "Yes" or "No"))
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   ->    Item: %s", sCheaterWeapon)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   -> Vehicle: %s (%s)", (player:GetVehicle() and "Yes" or "No"), sCheaterVehicle)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   -> Lagging: %s", string.bool(bIsLagging, "Yes", "No"))
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   ->  Access: %s", sCheaterAccess)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   -> Profile: %s", sCheaterProfile)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   ->   Alias: %s", sCheaterAlias)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "   -> Country: %s (%s)", sCheaterCountry, sCheaterIP)
		ATOMLog:LogToLogFile(LOG_FILE_DEFENSE, "----------------------")
	
		-------------
		if (SERVER_DEFENSE == false) then
			return false, SysLog("WARNING : ATOM Defense is disabled! (player = %s, Cheat = %s, Info = %s, sure = %s)", tostr(player:GetName()), tostr(cheat), tostr(info), tostr(sure)) end

		-------------
		local KICK = 1
		local BAN = 2
		local PERMABAN = 3
		local MUTE = 4
		local WARN = 5
		local BAN_5_MIN = 6

		local aOkToKick = {
			["Radio"] = KICK,
			["No Spread"] = BAN_5_MIN,
			["No Recoil"] = BAN_5_MIN,
			["Ghost"] = KICK,
			["LongPoke"] = PERMABAN,
		}
		local iOkToKick = (aOkToKick[cheat] or (bForcedKick == true and KICK))
		local bOkToKick = (iOkToKick ~= nil)

		-------------
		if (bIsLagging and aCfg and aCfg.IgnoreLaggers) then
			self:Msg(eCD_LaggerCheat, player:GetName(), cheat, info, playerAccess)
			return false
		end

		-------------
		local iBanTime = 3600
		if (iOkToKick == PERMABAN) then
			iBanTime = "infinite"
		end
		if (aCfg and aCfg.BanTime) then
			iBanTime = aCfg.BanTime
		end

		-------------
		self:Msg(eCD_Cheat, player:GetName(), cheat, info, playerAccess)
		if (bOkToKick) then

			local sDetected = string.format("Detected Cheat: %s", cheat)

			if (iOkToKick == BAN_5_MIN) then
				ATOMPunish.ATOMBan:BanPlayer(ATOM.Server, player, "5min", sDetected)
			elseif (iOkToKick == BAN or iOkToKick == PERMABAN) then
				ATOMPunish.ATOMBan:BanPlayer(ATOM.Server, player, (iBanTime .. "min"), sDetected)
			elseif (iOkToKick == KICK) then
				ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, sDetected)
			elseif (iOkToKick == MUTE) then
				ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, player, 86400, sDetected)
			elseif (iOkToKick == WARN) then
				WarnPlayer(ATOM.Server, player, sDetected)
			end

		end

		--[[
		if (cfg) then
			if (isLagging and cfg.IgnoreLaggers) then-- and not sure) then
				self:Msg(eCD_LaggerCheat, player:GetName(), cheat, info, playerAccess);
				return false;
			end;
			local kick = cfg.Kick
			local ban = cfg.Ban;
			self:Msg(eCD_Cheat, player:GetName(), cheat, info, playerAccess);
			if (ban) then
				local banTime = cfg.BanTime;
				-- ATOMPunish.ATOMBan:BanPlayer(ATOM.Server, player, banTime .. "min", "Detected Cheat: " .. cheat);
			else
				-- ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "Detected Cheat: " .. cheat);
			end;
		else
			if (isLagging) then
				self:Msg(eCD_LaggerCheat, player:GetName(), cheat, info, playerAccess)
				return false
			end

			self:Msg(eCD_Cheat, player:GetName(), cheat, info, playerAccess)
			if (bNoFalsePositive) then
				ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "Detected Cheat: " .. cheat)
			end


			--if (sure and bKickAnyway and not player:HasAccess(MODERATOR)) then
				-- ATOMPunish.ATOMBan:BanPlayer(ATOM.Server, player, '86400', "Detected Cheat: " .. cheat);
			--elseif (bKickAnyway) then
				-- ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "Detected Cheat: " .. cheat);
			--end
		end
		--]]
		
		-------------
		if (player.perfs) then
			player.perfs.flaggedTime = atommath:Get("timestamp")
			player.perfs.flaggedCount = (player.perfs.flaggedCount or 0) + 1
		end

		-------------
		--SysLog("Logged cheat to user access %d (%s)", playerAccess, GetGroupData(playerAccess)[2]);
	end;
	--------------
	Msg = function(self, case, player, p1, p2, p3, p4, p5)
		local cfg = self.cfg;
		if (case == eCD_Cheat) then
			if (timerexpired(self.hCheatChatTimer, 1)) then
				SendMsg(CHAT_DEFENSE, p3, "(" .. player .. ": Detected using " .. p1 .. ", " .. p2 .. ")")
				self.hCheatChatTimer = timerinit()
			end
			ATOMLog:LogCheat(player, p1, p2, p3, false, p3, p3, p3);
		elseif (case == eCD_LaggerCheat) then
			SendMsg(CHAT_DEFENSE, p3, "((LAG)" .. player .. ": Detected using " .. p1 .. ", " .. p2 .. ")");
			ATOMLog:LogCheat(player, p1, p2, p3, true, p3, p3, p3);
		end;
	end;
	--------------
	Utilities = {
		--------------
		Distance = function(self, player, targetPos)
			return getDistance(player, targetPos);
		end;
		--------------
	
	};
	--------------
	HandleExplosive = function(self, player, typeId, explosiveId)
		local explosive = System.GetEntity(explosiveId)
		if (not explosive) then
			return false
		end
		local dist = GetDistance(player:GetPos(), explosive:GetPos())
		if (dist > 30) then
			explosive:SetPos(player:GetPos())
			g_game:ExplodeProjectile(explosiveId, true, false)
			self:OnCheat(player, "Explosive Hax", "Placing %s %0.2fm away", explosive.class, dist, true)
			return false
		elseif (dist > 1) then
			SysLog("%s placed explosive of class %s %0.2fm away from them.", player:GetName(), explosive.class, dist)
		end
	
		return true
	end;
	--------------
	HandleShoot = function(self, hPlayer, hWeapon, vPos, vDir, vHit, vNormal, iDistance, bTerrain)
		hPlayer.fireTime = _time
		
		-- local bWaterOk = true
		-- local iWaterElevation = checkNumber(CryAction.GetWaterInfo(vPos), vPos.z)
		-- local iUnderwaterDistance = (iWaterElevation - vPos.z)
		
		-- if (iUnderwaterDistance >= 3) then
			-- bWaterOk = false end
		
		-- if (bWaterOk) then
			-- hPlayer.iUnderwaterShots = 0
		-- else
			-- hPlayer.iUnderwaterShots = (hPlayer.iUnderwaterShots or 0) + 1;
			-- if (hPlayer.iUnderwaterShots > 10) then
				-- self:OnCheat(hPlayer, "ItemHax", string.format("Firing %0.2fm under water", iUnderwaterDistance), false);
				-- hPlayer.iUnderwaterShots = 0
				-- return false
			-- end
		-- end
		
		return true
	end;
	--------------
	CheckRadio = function(self, hPlayer, iRadio)
	
		---------
		SysLog("[DEFENSE] %s Requested Radio %s", hPlayer:GetName(), tostring(iRadio))
	
		---------
		local sRules = g_gameRules.class
		if (not string.matchex(sRules, "PowerStruggle", "TeamInstantAction")) then
			self:OnCheat(hPlayer, "Radio", "Invalid Game Mode", true)
			return false end
	
		---------
		local iTeam = hPlayer:GetTeam()
		if (iTeam == 0) then
			self:OnCheat(hPlayer, "Radio", "Requested as Neutral", true)
			return false end
			
		---------
		if (iRadio < 0 or iRadio >= 20) then
			self:OnCheat(hPlayer, "Radio", "Requested ID " .. iRadio, true)
			return false end
			
		---------
		return true
	end,
	--------------
	CheckFireMode = function(self, hPlayer, hWeapon, iFireMode)
	
		---------
		SysLog("[DEFENSE] %s (%s) Requested FireMode %s", hPlayer:GetName(), hWeapon.class, tostring(iFireMode))
		
		---------
		if (not isNumber(iFireMode)) then
			return false end
	
		---------
		local iFireModes = hWeapon.weapon:GetFireModeCount()
		SysLog("Max Fire Modes: %d", iFireModes)
		if (iFireMode > iFireModes or (iFireMode < 0)) then
			self:OnCheat(hPlayer, "FireMode", iFireMode .. "\\" .. iFireModes, true)
			return false end
			
		---------
		return true
	end;
	--------------
	OnHit = function(self, hit, vehicle)
		local shooter = hit.shooter;
		return true;
	end;
	--------------
	OnVehicleHit = function(self, hit)
	
		local shooter = hit.shooter;
		local target = hit.target;

		return true;
	end;
	--------------
	CanFreeze = function(self, target, shooter, hWeapon)
		return true;
	end;
	--------------
	CanLockTarget = function(self, hPlayer, hWeapon, targetId, iPart)	
		local hTarget = GetEnt(targetId)
		if (not hTarget) then
			return false end
		
		----------
		local sClass = hWeapon.class
		local bCanLock = (not isNull(table.findex({
			"SideWinder"
		}, sClass)))
		
		----------
		SysLog("%s locking target %s with %s (%0.2fm)", hPlayer:GetName(), hTarget:GetName(), hWeapon.class, GetDistance(hPlayer, hTarget))
		
		----------
		if (bCanLock) then
			return true end
		
		----------
		if (sClass == "LAW") then
			SysLog("Detected LAW-Mod on %s", hPlayer:GetName())
			if (ATOM.cfg.KickLAWMods) then
				KickPlayer(ATOM.Server, hPlayer, "LAW-Mod");
			end
		end
		
		----------
		return false
	end;
	--------------
	HandleZoom = function(self, player, fov)
		local weapon = player.inventory:GetCurrentItem();
		if (not weapon or (weapon.class == "Fists" or weapon.class == "Binoculars" or weapon.class == "LAW")) then
			return true;
		end;
		local limits = {
			["NoZoom"] = {
				0.999,
				1
			},
			["Reflex"] = {
				0.714,
				0.715
			},
			["AssaultScope"] = {
				0.286,
				0.287
			},
			["SniperScope"] = {
				0.100,
				0.250
			}
		};
		local mode;
		for i, v in pairs(limits) do
			if (fov > v[1] and fov < v[2]) then
				mode = i;
			end;
		end;
		local real = "NoZoom";
		if (weapon.weapon:GetAccessory("Reflex")) then
			real = "Reflex";
		elseif (weapon.weapon:GetAccessory("AssaultScope")) then
			real = "AssaultScope";
		elseif (weapon.weapon:GetAccessory("SniperScope")) then
			real = "SniperScope";
		end;
		if (mode == "NoZoom" or (real == "NoZoom" and mode == "Reflex")) then
			return true;
		end;
		if (mode ~= real) then
			player.ZoomHack = (player.ZoomHack or 0) + 1;
			if (player.ZoomHack > 5) then
				return false, self:OnCheat(player, "FOVHack", formatString("%s != %s, %d", tostr(mode), tostr(real), tostr(fov)), false);
			end;
		end;
		if (player.LastZoom) then -- this detects the zoom recoil bug
			local bug = false;
			if (mode == "SniperScope") then
				if (player.actorStats.stance == 0) then
					if (not player.RecoilBug or player.RecoilBug < 3) then
					--	Debug(player.RecoilBug,fov,player.LastFOV)
						if ((player.RecoilBug == 2 and fov > player.LastFOV) or player.RecoilBug ~= 2) then
							bug = true;
						end;
					end;
				elseif (player.actorStats.stance == 2 and player.RecoilBug and player.RecoilBug >= 3) then
					bug = true;
				end;
			end;
			player.RecoilBug = (bug and ((player.RecoilBug or 0) + 1) or 0);
			if (player.RecoilBug == 4) then
				--self:OnCheat(player, "RecoilBug", player.RecoilBug .. " > 4 (SniperScope)", false);
			end;
		end;
		player.LastFOV	= fov;
		player.LastZoom = mode;
		return true;
	end;
	--------------
	CheckItemHit = function(self, item, hit)
	
		local shooter = hit.shooter;
		local target = hit.target;

		return true;
	end;
	--------------
	CheckBuyFlood = function(self, player)
	
		if (player.LastBuyTime and false) then
			local time = _time - player.LastBuyTime;
			if (time < 0.15) then
				player.BuyFlood = (player.BuyFlood or 0) + 1;
				--Debug(player.BuyFlood)
				if (player.BuyFlood >= 10) then
					if (g_warnSystem:ShouldWarn("BuyFlood") and player.BuyFlood <= 10) then
						WarnPlayer(ATOM.Server, player, "BuyFlood");
					end;
					if (player.BuyFlood >= 20) then
						KickPlayer(ATOM.Server, player, "BuyFlood");
						player.BuyFlood = 0;
					end;
				end;
			else
				player.BuyFlood = 0;
			end;
		else
			player.BuyFlood = 0;
		end;
		
		player.LastBuyTime = _time;

		return true;
	end;
	--------------
	OnPlayerTick = function(self, player, ping)
	
		
		--Debug("tick ??",player:GetProfile(),player:GetIP())
		local aBan, iBanID = self:IsBanned(player, player:GetIP(), player:GetHostName(), player:GetProfile(), player:GetIdentifier())
		if (aBan) then
		--	Debug("BANNED ??")
			ATOMDLL:Ban(player:GetChannel(), checkVar(aBan.Admin, string.UNKNOWN) .. ": " .. aBan.Reason)
		end
	
		-- local currentGun = player:GetCurrentItem();
		-- if (player.actorStats.stance == STANCE_SWIM and currentGun and player:IsUnderwater(3) and currentGun.class ~= "Fists" and currentGun.weapon) then
			-- player.underwaterGunTime = (player.underwaterGunTime or 0) + 1;
			-- if (player.underwaterGunTime >= 5) then
				-- self:OnCheat(player, "ItemHax", "Swimming with weapon " .. currentGun.class .. " equipped", false);
				-- player.underwaterGunTime = 0;
			-- end;
		-- else
			-- player.underwaterGunTime = 0;
		-- end
	end;
	--------------
	SpawnGroupOK = function(self, playerId, spawnGroupId)
		local spawnGroupEntity 	= GetEnt(spawnGroupId);
		local playerEntity		= GetEnt(playerId);
		
		if (g_gameRules.class == "InstantAction" or (spawnGroupEntity and playerEntity)) then
		--	Debug("ALL OK!")
		elseif (playerEntity and not spawnGroupEntity) then
		--	Debug("Requested without existing SPAWNGROUP!")
		end;
		
		return true;
	end;
	--------------
	IsPunished = function(self, player)
		return false;
	end;
	--------------
	IsBanned = function(self, player, ip, host, profile, extra)
		return ATOMPunish.ATOMBan:GetBan(ip, host, profile, extra);
	end;	
	--------------
	IsMuted = function(self, player)
		return false;
	end;
	--------------
	CanDrop = function(self, player, item)
		return true;
	end;
	--------------
	OpenDoor = function(self, player, door)
		return GetDistance(player, door) < 5
	end;
	--------------
	CheckGhost = function(self, player)
		local vehicleId = player.actor:GetLinkedVehicleId();
		if (vehicleId) then
			player.GhostHack = (player.GhostHack or 0) + 1;
			if (player.GhostHack > 5) then
				self:OnCheat(player, "Ghost", player.GhostHack .. " > 5", false);
				player.GhostHack = 0;
			end;
			return true;
		end;
		player.GhostHack = 0;
		return false;
	end;
	--------------
	CanUse = function(self, player, item)
		if (self:CheckGhost(player)) then
			return false;
		end;
		local distance = getDistance(player, item, nil, nil, true);
		local max = 10;
		if (player.actor:IsLagging()) then
			max = max * 2;
		end;
		if (distance > max) then
			player.UseHack = (player.UseHack or 0) + 1;
			SysLog("%s tried to use %s (%s) which is %0.2fm (max=%0.2f) away (pos1 = %s, pos2 = %s) (warnings: %d/5)", player:GetName(), item.class, item:GetName(), distance, max, Vec2Str(player:GetPos()), Vec2Str(item:GetPos()), player.UseHack);
			if (player.UseHack > 5) then
				self:OnCheat(player, "Item:Use", distance.." > " .. max, true);
				player.UseHack = 0;
			end;
			return false;
		else
			player.UseHack = 0;
		end;
		return true;
	end;
	--------------
	CanPickup = function(self, player, item)
		if (self:CheckGhost(player)) then
			return false;
		end;
		local distance = getDistance(player, item, nil, nil, true);
		local distanceZ = getDistance(player, item, true, true, false);
		local max = 10;
		local maxZ = 30;
		if (player.actor:IsLagging()) then
			max = max * 2;
			maxZ = maxZ * 2;
		end;
		if (distance > max or distanceZ > maxZ) then
			player.PickupHack = (player.PickupHack or 0) + 1;
			SysLog("%s tried to use %s (%s) which is %0.2fm away (distanceZ=%0.2fm, maxZ=%0.2f) (max=%0.2fm) away (pos1 = %s, pos2 = %s) (warnings: %d/5)", player:GetName(), item.class, item:GetName(), distance, distanceZ, maxZ, max, Vec2Str(player:GetPos()), Vec2Str(item:GetPos()), player.PickupHack);
			if (player.PickupHack > 5) then
				self:OnCheat(player, "Item:Pickup", (distanceZ > maxZ and distanceZ.. "Z > "..maxZ.."Z" or distance.." > " .. max), true);
				player.PickupHack = 0;
			end;
			return false;
		else
			player.PickupHack = 0;
		end;
		return true;
	end;
};