ATOMBroadCaster = {
	cfg = {
		AllowCustomEvents	 = false,
		DisableEventOnError  = false
	},
	
	----------------
	Events = {
		
		--"OnGameInit",	-- Called when the game initializes
		"OnMapStart",	-- Called when a new map started
		"OnMapRestart",	-- Called when the current game was restarted
		"OnGameEnd",	-- Called whne the game ends
	
		-- timers
		"OnUpdate",		-- Called every frame
		"OnTick",		-- Called every second
		"OnMidTick",	-- Called every 2 seconds
		"QTick",		-- Called every 250 ms
		"OnMinTimer",	-- Called every minute
		"OnSeqTimer",	-- Called every 10 mins
		
		-- player specific
		"OnVehicleBought",			-- Called when player bought an vehicle
		"CanBuyVehicle",			-- Called when player requests to buy a vehicle
		"OnItemBought",				-- Called when player bought an item
		"CanBuyItem",				-- Called when player requests to buy an item
		"InitPlayer", 				-- Called when player entity was spawned
		"OnPlayerInit", 			-- Called when player was initialized
		"CanChangeSpectatorMode",	-- Called when player requests to change spectator mode
		"OnChangeSpectatorMode",	-- Called when player requests to enter spectator mode
		"RequestSpectatorTarget",	-- Called when player requests a new spectator target
		"OnConsoleName",			-- Called when player renamed via "name" console command
		"OnConnection",				-- Called when the server received a new connection
		"OnConnected",				-- Called when the player entered the server
		"OnEnterGame",				-- Called when the player entered the game
		"OnDisconnect",				-- Called when the player disconnected from the server
		"OnShoot",					-- Called when the player shoots a weapon
		"OnLevelUp",				-- Called when the player levels up
		"OnItemChanged",			-- Called when the player switches current equipped item
		"OnChatMessage",			-- Called before a chat message gets send
		"OnPlayerTick",				-- Called every second
		"OnPlayerUpdate",			-- Called every frame
		"CanJump",					-- Called when player requests to jump
		"CanPickupItem",			-- Called when player requests to pick up an item
		"CanDropItem",				-- Called when player requests to drop an item
		"CanUseItem",				-- Called when player requested to use an item (shiten etc)
		"OnRevive",					-- Called when the player gets revived
		"CanSendRadio",				-- Called when player requests to send a radio message
		"OnExplosivePlaced",		-- Called when player placed an explosive
		"OnExplosiveRemoved",		-- Called when a player's explosive got detonated
		"CanUnfreeze",				-- Called when player requestes to unfreeze
		"CanUseHitAssistance",		-- Called when player requests hit assistance
		"CanLockTarget",			-- Called when player requests to lock a target
		"OnSeatChange",				-- Called when player switches current vehicle seat
		"CanEnterVehicle",			-- Called when player requests to enter a vehicle
		"CanOpenDoor",				-- Called when player requests to open a door
		"OnPlayerFroze",			-- Called when the player was frozen
		"OnMelee",					-- Called when the player performs a melee attack
		"OnClientInstalled",		-- Called when the player installed the ATOM client
		"CanLeaveVehicle",
		"GetSpawnLocation",
		"OnRename",

		
		"OnHit",		-- Called when an actor entity was hit
		"OnVehicleHit",	-- Called when a vehicle was hit
		"OnItemHit",	-- Called when a item was hit
		"OnKill",		-- Called when an actor entity was killed
		"OnExplosion",	-- Called when an explosion spawns
		"OnCollision",	-- Called when at entity collides somewhere (only if entity.ReportOnCollision == true)
		"OnHQHit",		-- Called when a HQ was hit
		
		
		-- misc
		"testEvent",	-- Called when broadcasted (lol)
	},
	
	----------------
	RegisteredEvents = {},
	collectedErrors  = {},
	speedTestSamples = {},
	
	----------------
	ATOMBroadcastEventAny = function(self, sEvent, ...)

		self.aReturned = {}
		self.ATOMBroadcastEvent(self, sEvent, ...)

		return unpack(self.aReturned)
	end,

	----------------
	ATOMBroadcastEvent = function(self, sEvent, ...)
		
		------------
		if (not self:IsValidEvent(sEvent) and not self.cfg.AllowCustomEvents) then
			return false, ATOMLog:LogError("Attempt to broadcast invalid event '%s' (names are case sensitive)", tostr(sEvent))
		end
	
		------------
		if (not self.collectedErrors[sEvent]) then
			self.collectedErrors[sEvent] = {} end
			
		------------
		local bOk, sErr
		local aListeners = self.RegisteredEvents[sEvent]
		
		local bIsOk = true
		local bDisable = self.cfg.DisableEventOnError
		
		local hATOMLog = ATOMLog
		local hGetObj = getObject
		local hTs = tostring

		local aErrors = self.collectedErrors
		
		local hTimerStart = timerinit()
		local iExecTime = 0
		
		local eObj_Func = 1
		local eObj_Object = 2
		local eObj_ExecTime = 3
		
		local aObject
		
		------------
		local hTimerAll = timerinit()

		------------
		local aReturned = {}
		if (aListeners and table.count(aListeners) > 0) then
			for i, aEvent in pairs(aListeners) do
				hTimerStart = timerinit()
				aObject = aEvent[eObj_Object]
				
				local fFunc = aEvent[eObj_Func]
				if (aObject) then
					if (isString(aObject)) then
						aObject = hGetObj(aObject)
					end
					bOk, sErr, aReturned[2], aReturned[3], aReturned[4], aReturned[5], aReturned[6], aReturned[7] =
					pcall(fFunc, aObject, ...)
				else
					bOk, sErr, aReturned[2], aReturned[3], aReturned[4], aReturned[5], aReturned[6], aReturned[7] =
					pcall(fFunc, ...)
				end
				
				iExecTime = timerdiff(hTimerStart)
				if (not aEvent[eObj_ExecTime] or iExecTime > aEvent[eObj_ExecTime]) then
					aEvent[eObj_ExecTime] = iExecTime
					SysLogVerb(2, "event broadcast of %s (%d) took %fs", sEvent, i, iExecTime)
				end
				
				if (not bOk) then
				
					local sFunc = tostring(fFunc)
				
					aEvent[4] = (aEvent[4] or 0) + 1;
					hATOMLog:LogError("Error in '%s' %s", sEvent, hTs(sErr))
					SysLog("%s", (debug.traceback() or string.TBFAILED))
					
					if (bDisable) then
					
						local iErrors = aErrors[sEvent][sFunc]
					
						if (not iErrors) then
							aErrors[sEvent][sFunc] = { 0, _time }
							
						elseif ((_time - aErrors[sEvent][sFunc][2]) < 0.1) then
							aErrors[sEvent][sFunc][1] = (aErrors[sEvent][sFunc][1] + 1)
							
							if (aErrors[sEvent][sFunc][1] > 10) then
								hATOMLog:LogError("Unregistered event '%s' from class '%s' (error overflow)", i, sEvent)
								table.remove(aListeners, i)
							end
						else
							aErrors[sEvent][sFunc][1] = 0
						end
						aErrors[sEvent][sFunc][2] = _time
					end
					
				else
					aReturned[1] = sErr
					if (bIsOk ~= false and sErr ~= nil) then
						bIsOk = sErr
					end
				end
			end
		end
		
		------------
		--[[
		local aEventTimers = self.speedTestSamples[sEvent]
		if (table.count(aEventTimers) >= 60) then
		
			local iTimeAvg = 0
			local sLast10 = ""
			for i, iTime in pairs(aEventTimers) do
			
				iTimeAvg = iTimeAvg + iTime
				
				if (i <= 10) then
					sLast10 = sLast10 .. iTime .. ","
				end
			end
			
			self.speedTestSamples[sEvent] = {}
			
			SysLog("$1Speedtest Result: Event: %s, $4%d Samples$1, Time Avg: $4%f$1, Last 10: $8%s$1", sEvent, table.count(self.aEventTimers), iTimeAvg, string.ridtrail(sLast10, ","))
		end
		
		table.insert(aEventTimers, timerdiff(hTimerAll))
		--]]

		------------
		self.aReturned = aReturned
		return bIsOk
	end,
	
	----------------
	GetRegisteredEvents = function(self)
		return self.RegisteredEvents
	end,
	
	----------------
	AddEventListener = function(self, eventName, f, o)
	
		local eventName = tostr(eventName);
		if (self:IsValidEvent(eventName) or self.cfg.AllowCustomEvents) then
			if (not f) then
				return false, ATOMLog:LogError("Attempt to add event '" .. eventName .. "' without function");
			end;
			local c = arrSize(self.RegisteredEvents[eventName]);
			if (o ~=nil and type(o) ~= "string") then
				ATOMLog:LogWarning("Non-string object added to event '%s', this is a performance issue", eventName);
				SysLog("%s", debug.traceback() or TRACEBACK_FAILED);
			end;
			self.RegisteredEvents[ eventName ][ c + 1 ] = { f, o };
		else
			return false, ATOMLog:LogError("Attempt to add invalid event '" .. eventName .. "' (names are case sensitive)");
		end
		
	end,
	
	----------------
	Init = function(self)
	
		------------
		for i, sEvent in pairs(self.Events) do
			self.RegisteredEvents[sEvent] = {}
			self.collectedErrors [sEvent] = {}
			self.speedTestSamples[sEvent] = {}
		end
		
		------------
		ATOMBroadcastEvent = function(...)
			return self:ATOMBroadcastEvent(...) end

		------------
		ATOMBroadcastEventAny = function(...)
			return self:ATOMBroadcastEventAny(...) end
		
		------------
		RegisterEvent = function(...)
			return self:AddEventListener(...) end
		
	end,
	
	----------------
	IsValidEvent = function(self, sEvent)
	
		------------
		for i, sRegEvent in pairs(self.Events) do
			if (sRegEvent == sEvent) then
				return true
			end
		end
		
		------------
		return false
	end
};

ATOMBroadCaster:Init()

