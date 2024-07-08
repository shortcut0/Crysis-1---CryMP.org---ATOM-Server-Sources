ATOMStatistics = {
	cfg = {},
	-----------------------
	stats_default = {
		Maximum = 0, -- Maximum amount of online players recorded
		
		TimeTotal = 0, -- total time players spend in this server
		TimeAverage = 0, -- average time players spend in this server
		Times = { -- collected play times for average calculation (UNUSED)
		},
	
		KillsTotal = 0, -- total kills done in this server 
		DeathsTotal = 0, -- total deaths in this server

		BoxPlayers = 0,
		PVPPlayers = 0,
		ArenaPlayers = 0,

		ChatTotal = 0, -- total chat messages send in this server
		CommandsTotal = 0, -- total commands used in this server
		PlayerTotal = 0, -- total connections
		ConnTotal = 0, -- total connections
		Channels = 0, -- total channels

		MetersWalked = 0, -- total meters players walked in this server
		MetersDriven = 0, -- total meters players drove in vehicles in this server
		DamageDealt = 0,
		MetersFlighted = 0, -- total meters players flighted in vehicles
		BulletsFired = 0, -- total bullets fired
		HitsLanded = 0, -- total hits
		
		Runtime = 0, -- total run time of this server
		RuntimeAverage = 0, -- total run time of this server
		Runtimes = { -- collected runtimes for average calculation
		},
	},
	stats = {},
	stats_limits = {},
	-----------------------
	Init = function(self)
	
		-- reset statistics
		self.stats = self.stats_default;
	
		-- global representation of the player statistics system
		g_statistics = self;
		
		-- load the stored data
		self:LoadFile();
		
		-- register events
		RegisterEvent("OnTick", self.OnTick, 'ATOMStatistics');
		
		-- finish up
		STATISTICS_CURRENT_VALUE = STATISTICS_CURRENT_VALUE or arrSize(self:GetValue("Runtimes")) + 1;

		-- set limits for some data entries
		self:SetKeyLimit("DamageDealt", 	MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("BulletsFired", 	MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("HitsLanded", 		MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("MetersFlighted", 	MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("MetersWalked", 	MAXIMUM_NUMBER_INTEGER)

		self:SetKeyLimit("MetersWalked", 	MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("MetersDriven", 	MAXIMUM_NUMBER_INTEGER)
		self:SetKeyLimit("MetersFlighted", 	MAXIMUM_NUMBER_INTEGER)

	end,
	-----------------------
	Load = function(self, t)
		--Debug(t)
		self.stats = t;
	end,
	-----------------------
	CheckKey = function(self, key)
		if (self.stats_default[key] and not self.stats[key]) then
			self.stats[key] = self.stats_default[key];
			SysLog("fixed missing key %s", key);
		end
	end,
	-----------------------
	GetValue = function(self, key, index)
		self:CheckKey(key)
		return (index and (self.stats[key][index]or 0) or self.stats[key])
	end,
	-----------------------
	GetValueLimit = function(self, key, index)
		self:CheckKey(key)

		if (not self.stats_limits) then
			return
		elseif (index) then
			return checkArray(self.stats_limits[key], {})[index]
		end

		return self.stats_limits[key]
	end,
	-----------------------
	SetValue = function(self, key, value, index)
		--Debug(value)

		local iLimit = self:GetValueLimit(key, index)
		if (self:ValidKey(key)) then -- only insert valid keys
			if (self:ValidValue(key, value, index)) then
				if (index) then
					self.stats[key][index] = value
				else
					self.stats[key] = value
				end

				if (isNumber(value) and isNumber(iLimit)) then
					if (value > iLimit) then
						if (index) then
							self.stats[key][index] = iLimit
						else
							self.stats[key] = iLimit
						end
						--SysLog("Limit %d for key %s reached", iLimit, key)
					end
				end
			else
				ATOMLog:LogError("[STATS][1] Key values do not match (%s, should be %s, not %s)", key, self.wrongkey, type(value))
			end
		else
			ATOMLog:LogError("[STATS][1] Attempt to set value of invalid key %s (%s)", tostr(key), tostr(value))
		end
	end,
	-----------------------
	SetKeyLimit = function(self, sKey, iLimit, iIndex)

		if (self:ValidKey(sKey)) then -- only insert valid keys
			if (self:ValidValue(sKey, iLimit, iIndex)) then
				if (iIndex) then
					self.stats_limits[sKey][iIndex] = iLimit
				else
					self.stats_limits[sKey] = iLimit
				end
			else
				ATOMLog:LogError("[STATS][1] Key values do not match (%s, should be %s, not %s)", sKey, self.wrongkey, type(iValue))
			end
		else
			ATOMLog:LogError("[STATS][1] Attempt to set limit of an invalid key %s (%s)", tostr(sKey), tostr(iValue))
		end
	end,
	-----------------------
	AddToValue = function(self, key, value, index)
		local current = self:GetValue(key)
		if (current) then
			--Debug(key)
			self:SetValue(key, (index and (current[index]or 0) or current) + value, index)
		else
			SysLog("Attempt to modify invalid value of ATOMStatistics (%s)", tostring(key))
		end;
	end,
	-----------------------
	ResetValue = function(self, key)
		self.stats[key] = self.stats_default[key];
	end,
	-----------------------
	ValidKey = function(self, key)
		return key and self.stats_default[key];
	end,
	-----------------------
	ValidValue = function(self, key, value, index)
		
		local key_type = type(value);
		local real_type = type(self.stats_default[key]);
		if (index) then
			real_type = type(self.stats_default[key][index] or 0);
		end;

		self.wrongkey = nil;
		
		if (key_type ~= real_type) then
			self.wrongkey = real_type;
			return false;
		end;
		
		return true;
	end,
	-----------------------
	OnTick = function(self)
	
		-- local hTimerStart = timerinit()
	
		-------
		self:AddToValue("Runtime", 1)
		self:AddToValue("Runtimes", 1, STATISTICS_CURRENT_VALUE)
		
		-------
		for i = 1, arrSize(self:GetValue("Runtimes")) do
			if (not self.stats["Times"][i]) then
				self.stats["Times"][i] = 0
			end
		end
		
		-------
		self:AddToValue("TimeTotal", arrSize(GetPlayers()))
		self:AddToValue("Times", arrSize(GetPlayers()), STATISTICS_CURRENT_VALUE)
		
		-------
		if (arrSize(self:GetValue("Runtimes")) > 25) then
			table.remove(self.stats["Runtimes"], 1)
			STATISTICS_CURRENT_VALUE = STATISTICS_CURRENT_VALUE - 1 -- table changed, roll back to previous number
		end
		
		-------
		self:SetValue("RuntimeAverage", average(self:GetValue("Runtimes")))
		self:SetValue("TimeAverage", average(self:GetValue("Times")))
		
		--Debug("TimeAverage", self:GetValue("TimeAverage"), "This", self:GetValue("Times", STATISTICS_CURRENT_VALUE))
		
		-------
		if (arrSize(GetPlayers()) > self:GetValue("Maximum")) then
			self:SetValue("Maximum", arrSize(GetPlayers()))
		end
		
		-------
		if (not self.LastSave or _time - self.LastSave > (arrSize(GetPlayers()) == 0 and 60 or 60*10)) then
			self.LastSave = _time
			self:SaveFile()
		end
		
		-------
		-- SysLog("Tick took %fs", timerdiff(hTimerStart))
		--Debug("runtime:", self:GetValue("Runtime"))
		--Debug("runtimeavg",self:GetValue("Runtimes", STATISTICS_CURRENT_VALUE))
	end,
	-----------------------
	LoadFile = function(self)
		LoadFile("PlayerStatistics", "Statistics.lua");
	end,
	-----------------------
	SaveFile = function(self)
		SaveFileArr("PlayerStatistics", "Statistics.lua", "g_statistics:Load", { { self.stats } } );
	end,

};

ATOMStatistics:Init();