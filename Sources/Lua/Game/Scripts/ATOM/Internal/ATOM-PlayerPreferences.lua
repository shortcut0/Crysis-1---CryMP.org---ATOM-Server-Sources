ATOMPlayerPerfs = {
	cfg = {},
	-------------
	default = {
		
		-- Player tags (VIP Tag, Chat Popups, Kill Messages, etc)
		tags = {},
		
		-- Saved positions (!save, !load)
		positions = {},

		-- Granted authorizations
		aGrantedAuths = {},
		
		-- Last Used Name
		name = "",
		
		-- Last position before player disconnected
		position = makeVec(0, 0, 0),
		
		-- some misc
		SpendMoney = 0,
		
	},
	-------------
	perfs = {},
	-------------
	Init = function(self)
		
		-- Global representation of this plugin
		g_playerperfs = self;
		
		-- load existing file
		self:LoadFile();
		
		-- Register events
		RegisterEvent("OnPlayerInit", self.InitPlayer, 'ATOMPlayerPerfs');
		RegisterEvent("OnSeqTimer", self.SaveFile, 'ATOMPlayerPerfs');
		RegisterEvent("OnDisconnect", self.OnDisconnect, 'ATOMPlayerPerfs');
		
	end,
	-------------
	OnDisconnect = function(self, player)
		self:SetValue(player, "position", player:GetPos());
		self:SaveFile();
	end,
	-------------
	InitPlayer = function(self, player)
		--Debug("INIT!!")
		--Debug(self.perfs[player:GetIdentifier()] )
		player.perfs = self.perfs[player:GetIdentifier()] or copyTable(self.default)
		for i, v in pairs(self.default) do
			if (player.perfs[i] == nil) then
				player.perfs[i] = v
			end
		end

		for i, tag in pairs(player.perfs.tags) do
			if (tag ~= nil) then
				player[i] = tag;
			end
		--	Debug("tag ",i,"restored:",tag)
		end;

		player.aGrantedAuths = player.perfs.aGrantedAuths
		player.positions = player.perfs.positions
		if (player.iGender == nil) then
			player:SetGender(GENDER_MALE)
		end
	end,
	-------------
	SetValue = function(self, player, key, value)
		if (not player.perfs) then
			SysLog("NO PERFS FOR PLAYER YET !! (key=%s, value=%s)", key, tostring(value));
			return;
		end;
		player.perfs[key] = value;
	end,
	-------------
	GetValue = function(self, player, key)
		return player.perfs[key];
	end,
	-----------------------
	Load = function(self, id, t)
		--Debug(id)
	--	Debug(t)
		--SysLogVerb(3, "[g_playerperfs] load %s = %s", tostring(id), tostring(t))
		self.perfs[id] = t;
		--self.perfs=id
	end,
	-----------------------
	Load_Old = function(self, t)
		--Debug(id)
		--Debug(t)
		--SysLog("[g_playerperfs] load %s = %s", tostring(id), tostring(t))
		self.perfs = t;
		--self.perfs=id
	end,
	-----------------------
	LoadFile = function(self)
		LoadFile("PlayerPreferences", "Preferences.lua");
	end,
	-----------------------
	SaveFile = function(self)
		local n = {};
		for i, v in pairs(GetPlayers()) do
			if (v.perfs) then

				v.perfs.aGrantedAuths = v.aGrantedAuths
				v.perfs.tags["Popups"] = v.Popups;
				v.perfs.tags["bKillMessages"] = v.bKillMessages;
				v.perfs.tags["DeathKills"] = v.DeathKills;
				v.perfs.tags["ToxicityPass"] = v.ToxicityPass;
				v.perfs.tags["bPrefersNomad"] = v.bPrefersNomad;
				v.perfs.tags["iGender"] = v.iGender;
				v.perfs.tags["sGender"] = v.sGender;
				--v.perfs.tags["flaggedTime"] = v.flaggedTime;
				--v.perfs.tags["flaggedCount"] = v.flaggedCount;
				self.perfs[v:GetIdentifier()] = v.perfs;
				--Debug("PERF SAVED")
				for _i, _v in pairs(self.default.tags) do
					if (v[_i]) then
						self.perfs[v:GetIdentifier()].tags[_i] = v[_i];
					end;
				end;
			end;
		end;
		for i, v in pairs(self.perfs) do
			--SysLogVerb(0, "[g_playerperfs] save %s = %s", tostring(i), tostring(v))
			n[arrSize(n)+1] = { i, v };
		end;
		SaveFileArr("PlayerPreferences", "Preferences.lua", "g_playerperfs:Load", n );
	end,
	-------------
};

ATOMPlayerPerfs:Init();