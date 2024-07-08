ATOMBoxingArea = {
	cfg = {
	
	};
	------------
	ArenaPos = ATOMBoxingArea and ATOMBoxingArea.ArenaPos or makeVec(500, 500, 2000),
	ArenaParts = ATOMBoxingArea and ATOMBoxingArea.ArenaParts or {},
	ArenaBoxers = ATOMBoxingArea and ATOMBoxingArea.ArenaBoxers or {},
	ArenaRadius = ATOMBoxingArea and ATOMBoxingArea.ArenaRadius or {},
	ArenaSpawned = ATOMBoxingArea and (ATOMBoxingArea.ArenaSpawned ~= nil and ATOMBoxingArea.ArenaSpawned) or false,
	------------
	PVPPos = ATOMBoxingArea and ATOMBoxingArea.PVPPos or makeVec(500, 600, 2000),
	PVPParts = ATOMBoxingArea and ATOMBoxingArea.PVPParts or {},
	PVPBoxers = ATOMBoxingArea and ATOMBoxingArea.PVPBoxers or {},
	PVPRadius = ATOMBoxingArea and ATOMBoxingArea.PVPRadius or {},
	PVPSpawned = ATOMBoxingArea and (ATOMBoxingArea.PVPSpawned ~= nil and ATOMBoxingArea.PVPSpawned) or false,
	------------
	ArenaPositions = ATOMBoxingArea and ATOMBoxingArea.ArenaPositions or { },
	ArenasParts = ATOMBoxingArea and ATOMBoxingArea.ArenasParts or {},
	ArenaPlayers = ATOMBoxingArea and ATOMBoxingArea.ArenaPlayers or {},
	ArenaRadiuses = ATOMBoxingArea and ATOMBoxingArea.ArenaRadiuses or {},
	ArenasSpawned = ATOMBoxingArea and ATOMBoxingArea.ArenasSpawned or {},
	ArenaSpawns = ATOMBoxingArea and ATOMBoxingArea.ArenaSpawns or {},
	ArenaCount = ATOMBoxingArea and ATOMBoxingArea.ArenaCount or 0,
	ArenaSpawnTimers = ATOMBoxingArea and ATOMBoxingArea.ArenaSpawnTimers or {},
	------------
	-- Init
	Init = function(self)
		
		-- Global representation of this module
		--g_boxing = self;
		
		--RegisterEvent("OnRevive", self.OnRevive, 'ATOMBoxingArea');
		RegisterEvent("OnTick", self.Tick, 'ATOMBoxingArea');
		
	end,
	------------
	-- Reset
	Reset = function(self)
		
		self.ArenaPositions = nil
		self.ArenasParts = nil
		self.ArenaPlayers = nil
		self.ArenaRadiuses = nil
		self.ArenaSpawned = nil
		self.ArenaSpawns = nil
		
	end,
	-----------
	-- Shitdown
	Shutdown = function(self)
		self:Despawn();
	end,
	-----------
	-- Despawn
	Despawn = function(self, t, full)
		if (t == 0) then
			for i, v in pairs(self.ArenaParts or {}) do
				System.RemoveEntity(v.id);
			end;
			
			self.ArenaParts = {};
			self.ArenaSpawned = false;
			--Debug("REMOVED AREA!!!!")
		elseif (t == 1) then
			for i, v in pairs(self.PVPParts or {}) do
				System.RemoveEntity(v.id);
			end;
			
			self.PVPParts = {};
			self.PVPSpawned = false;
			--Debug("REMOVED PVP!!!!")
		end;
	end,
	-----------
	-- SpawnArea
	SpawnArea = function(self, t, full, cmd, pos)
		local pos = pos or makeVec(500, 500, 2000);
		if (t == 1) then
			pos.y = pos.y + 100;
		end;
		
		local data = {
		
			{ makeVec(0, 38, 7), makeVec(0.70710671, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(48, 6, 7), makeVec(-0.70710689, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(0, 54, 7), makeVec(0.70710671, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(0, 22, 7), makeVec(0, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(0, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(16, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(32, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(16, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(32, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(48, 22, 7), makeVec(-0.70710689, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(48, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(48, 38, 7), makeVec(-1, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
			{ makeVec(16.075005, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			{ makeVec(32.450012, 26.475002, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			{ makeVec(16.075005, 26.475006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			{ makeVec(32.450012, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			{ makeVec(-0.299995, 26.47501, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			{ makeVec(-0.299995, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			
			{ makeVec(66.575, 37.900002, 1.9999999985032e-06), makeVec(0, 1, 0), "Objects/library/machines/cranes/container_crane/container_crane.cgf" },
			{ makeVec(23.625, 7.875, 0), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/support_building_fit_concrete_wall.cgf" },
			{ makeVec(22.547081, 10.747971, 0.375), makeVec(0.70710677, 0, 0), "Objects/library/barriers/concrete_wall/door.cgf" },
			{ makeVec(35.724983, 29.125, 2.474998), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf" },
			{ makeVec(41.724976, 29.125008, 2.474998), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_6mb.cgf" },
			{ makeVec(26.72501, 19.749992, 2.475002), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(6.050011, 38.524994, 2.475002), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(26.72501, 38.524994, 2.475002), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(6.075008, 29.124992, 2.475002), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(6.075008, 19.749992, 2.475002), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(41.725014, 38.524994, 2.475002), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(21.075012, 29.124992, 2.475002), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(21.050014, 38.524994, 2.475002), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(21.075012, 19.749996, 2.475002), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(41.725014, 19.749996, 2.475002), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_b.cgf" },
			{ makeVec(35.725006, 29.125, 2.475), makeVec(0, -1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf" },
			{ makeVec(26.725006, 29.125008, 2.475), makeVec(0, 1, 0), "objects/library/architecture/concrete structure/concrete_structure_curb_9mb.cgf" },
			{ makeVec(16.074997, 30.300003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(28.712502, 37.674995, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(12.099991, 18.887501, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(12.099991, 37.662498, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(16.074997, 20.925003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(31.724998, 30.300003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(19.062489, 37.662498, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(19.062489, 18.887501, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(12.099991, 28.262505, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(31.724998, 20.925003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(28.712502, 18.887501, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(16.074997, 39.700005, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(31.724998, 39.712509, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(8.099998, 30.300003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(8.099998, 39.699997, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(8.099998, 20.925003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(35.699997, 37.662498, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(35.699997, 18.887501, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(35.699997, 28.262505, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(8.099987, 28.262512, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(8.099987, 18.88752, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(8.099987, 37.662514, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(39.700005, 20.925003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(39.699989, 18.887512, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(39.699989, 28.26252, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(39.700005, 30.300003, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(39.699989, 37.662514, -0.475), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_gate_4m.cgf" },
			{ makeVec(39.700005, 39.712502, 0.025002000000001), makeVec(-0.70710671, 0, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(29.124992, 28.299995, -0.65), makeVec(-1, 0, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf" },
			{ makeVec(29.124985, 27.974991, -0.65), makeVec(1, 0, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf" },
			{ makeVec(18.649986, 27.974991, -0.65), makeVec(1, 0, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf" },
			{ makeVec(18.649994, 28.299995, -0.65), makeVec(-1, 0, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_end_destroyed_high.cgf" },
			{ makeVec(21.375004, 17.712505, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(21.375004, 27.075001, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(21.375004, 36.537506, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(26.725006, 17.6875, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(26.725006, 27.075001, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(26.725006, 36.5625, 2.699999), makeVec(0, 1, 0), "Objects/library/architecture/village/wall/concrete_wall_simple_4m_destroyed_high.cgf" },
			{ makeVec(26.725002, 38.562492, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(26.725002, 19.687489, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(26.725002, 29.074997, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(21.374996, 38.537491, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(21.374996, 29.074997, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
			{ makeVec(21.374996, 19.712494, 0.075001), makeVec(0, 1, 0), "objects/library/architecture/village/wall/concrete_wall_simple_4m.cgf" },
		
		};
		
		
		if (not full) then
			data = {
				{ makeVec(0, 38, 7), makeVec(0.70710671, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(48, 6, 7), makeVec(-0.70710689, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(0, 54, 7), makeVec(0.70710671, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(0, 22, 7), makeVec(0, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(0, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(16, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(32, 6, 7), makeVec(0, 1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(16, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(32, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(48, 22, 7), makeVec(-0.70710689, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(48, 54, 7), makeVec(0, -1, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(48, 38, 7), makeVec(-1, 0, 0), "Objects/library/barriers/concrete_wall/concrete_wall_16m_b.cgf" },
				{ makeVec(16.075005, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
				{ makeVec(32.450012, 26.475002, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
				{ makeVec(16.075005, 26.475006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
				{ makeVec(32.450012, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
				{ makeVec(-0.299995, 26.47501, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
				{ makeVec(-0.299995, 50.975006, 0.075001), makeVec(0, 1, 0), "Objects/library/architecture/aircraftcarrier/hangar_a_floor3.cgf" },
			};
		end;
		local _returnParts = {};
		for i, v in pairs(data) do
			local part = SpawnGUINew({
				Model = v[3],
				Pos = add2Vec(pos, v[1]);
				Dir = v[2],
				bStatic = 1,
				Mass = -1
			});
			if (not cmd) then
				table.insert((t == 1 and self.PVPParts or self.ArenaParts), part);
			else
				table.insert(_returnParts, part);
			end;
		end;
		if (not cmd) then
			if (t == 0) then
			--	Debug("ARENA!")
				self.ArenaPos = pos;
				self.ArenaSpawned = true;
				self.ArenaRadius = {
					x = { pos.x, pos.x + 47 }, 
					y = { pos.y + 2, pos.y + 50 }, 
					z = { pos.z - 1, pos.z + 60 }
				};
			else
				self.PVPPos = pos;
				self.PVPSpawned = true;
				self.PVPRadius = {
					x = { pos.x, pos.x + 47 }, 
					y = { pos.y + 2, pos.y + 50 }, 
					z = { pos.z - 1, pos.z + 60 }
				};
			end;
		end;
		return _returnParts;
		--Debug("SPAWNED!")
	end,
	
	-----------
	-- GetActiveArenas
	GetActiveArenas = function(self)
	
		local iExisiting = 0
		for i, v in pairs(self.ArenasParts) do
			if (GetEnt(v[1])) then
				iExisiting = iExisiting + 1
			end
		end
	
		return iExisiting
	end,
	
	-----------
	-- ArenaExists
	ArenaExists = function(self, iArena)
	
		if (not isArray(self.ArenasParts)) then
			return false
		end
	
		if (not isArray(self.ArenasParts[iArena])) then
			return false
		end
	
		if (not isArray(self.ArenasParts[iArena][1])) then
			return false
		end

		return System.GetEntity(self.ArenasParts[iArena][1].id) ~= nil
	end,
	
	-----------
	-- GetArenaParts
	GetArenaParts = function(self, iArena)
	
		return (self.ArenasParts[iArena])
	end,
	
	-----------
	-- DeleteArena
	DeleteArena = function(self, iArena)
		local aParts = self:GetArenaParts(iArena)
		for i, v in pairs(checkArray(aParts)) do
			System.RemoveEntity(v.id)
		end

		for i, hPlayer in pairs(GetPlayers() or {}) do
			if (hPlayer.ArenaID and hPlayer.ArenaID == iArena) then
				self:Leave(2, hPlayer, "Arena Deleted")
			end
		end

		self.ArenasParts[iArena] = nil
		self.ArenasSpawned[iArena] = nil
		
	end,

	-----------
	-- EraseArena
	EraseArena = function(self, iArena, hPlayer)

		if (not self:ArenaExists(iArena)) then
			return false, "arena not found"
		end

		self:DeleteArena(iArena)
		SendMsg(CHAT_ARENA, ALL, "Arena ( %d ) Has Been Deleted", iArena)
	end,
	
	-----------
	-- SpawnArena
	SpawnArena = function(self, iArena, hSpawner)
	
		----------------
		local vPos = vector.modify(makeVec(500, 500, 3000), "z", (self:GetActiveArenas() * 25), true)
		local aData = {}
		local aBBox = {
			x = { vPos.x, vPos.x },
			y = { vPos.y, vPos.y },
			z = { vPos.z, vPos.z }
		}
		local aSpawns
		
		----------------
		if (iArena == 1) then
			aData = {
				-- 0.70710671
				{ makeVec(8.5, -9.25, 0), 		makeVec(0, 1.57272, 0), 	"Objects/library/architecture/harbour/warehouse/warehouse_helipad.cgf", 2 },
				{ makeVec(43.40, -9.25, 0), 	makeVec(0, -1.57272, 0),	"Objects/library/architecture/harbour/warehouse/warehouse_helipad.cgf", 2 },
				
				{ makeVec(9.725, -19, 1.375), 	makeVec(0, 0, 0), 			"Objects/library/architecture/concrete structure/terrain_level_ramp_20x.cgf" },
				{ makeVec(43.40, 1, 1.375), 	makeVec(-1, 0, 0), 			"Objects/library/architecture/concrete structure/terrain_level_ramp_20x.cgf" },
				
				{ makeVec(32.0, -9, 2.375), 	makeVec(0, 0, 0), 			"objects/library/architecture/concrete structure/terrain_level_ramp_corner_out.cgf" },
				{ makeVec(26.0, -15, 2.375), 	makeVec(0, -1, 0), 			"objects/library/architecture/concrete structure/terrain_level_ramp_corner_out.cgf" },
				{ makeVec(20.0, -9, 2.375), 	makeVec(-1, 0, 0), 			"objects/library/architecture/concrete structure/terrain_level_ramp_corner_out.cgf" },
				{ makeVec(26.0, -3, 2.375), 	makeVec(0, 1, 0), 			"objects/library/architecture/concrete structure/terrain_level_ramp_corner_out.cgf" },
			}
			
			aBBox = {
				x = { vPos.x - 6, vPos.x - 6 + 63 },
				y = { vPos.y - 25, vPos.y + 6.25 },
				z = { vPos.z + 0, vPos.z + 60 }
			}
			
			aSpawns = {
				{ x = vPos.x - 4, y = vPos.y + 2, z = vPos.z },
				{ x = vPos.x + 54, y = vPos.y + 3, z = vPos.z },
				{ x = vPos.x + 54, y = vPos.y - 22, z = vPos.z },
				{ x = vPos.x + 25, y = vPos.y + 3, z = vPos.z },
				{ x = vPos.x + 25, y = vPos.y - 22, z = vPos.z },
				{ x = vPos.x - 4, y = vPos.y - 23, z = vPos.z }
			}
		end

		----------------
		local aEntities = {}
		
		if (not self:ArenaExists(iArena)) then
			for i, v in pairs(aData) do
			
				local hPart = SpawnGUINew({
					Model = v[3],
					Pos = add2Vec(vPos, v[1]),
					Dir = v[2],
					bStatic = 1,
					Mass = -1
				})
				
				hPart:SetScale(checkNumber(v[4], 1))
				table.insert(aEntities, hPart)
			end
			--Debug("REspawned!")
		else
			--Debug("using OLD!")
			aEntities = self:GetArenaParts(iArena)
		end
		
		----------------
		self.ArenaCount = (self.ArenaCount or 0) + 1
		if (hSpawner) then
			SendMsg(CHAT_ARENA, ALL, "Arena ( %d ) Has Been Spawned! Enter using !arena <%d>", iArena, iArena)
		end
		
		----------------
		self.ArenasParts[iArena] = aEntities
		self.ArenaRadiuses[iArena] = aBBox
		self.ArenaSpawns[iArena] = aSpawns
		self.ArenasSpawned[iArena] = true
		self.ArenaSpawnTimers[iArena] = timerinit()
		
		----------------
		return aEntities
	end,
	-----------
	-- Enter
	SetPlayerSpawn = function(self, hPlayer)
		hPlayer:SetSpawnLocation({
			Pos = nil,
			Ang = nil,
			Priority = 1,
			Condition = function(hPlayer)

				local vPos, vAng
				if (ATOMBoxingArea.ArenaBoxers[hPlayer.id]) then
					Debug("Box")
					vPos, vAng = ATOMBoxingArea:Teleport(0, hPlayer, nil, nil, nil, true)
					SpawnEffect(ePE_Light, vPos, g_Vectors.up)
					hPlayer:ChangeSpawnLocation("ArenaSpawn", { Pos = vPos, Ang = vAng })
					return true
				end
				if (ATOMBoxingArea.PVPBoxers[hPlayer.id]) then
					vPos, vAng = ATOMBoxingArea:Teleport(1, hPlayer, nil, nil, nil, true)
					SpawnEffect(ePE_Light, vPos, g_Vectors.up)
					hPlayer:ChangeSpawnLocation("ArenaSpawn", { Pos = vPos, Ang = vAng })
					return true
				end
				if (ATOMBoxingArea.ArenaPlayers[hPlayer.id]) then
					vPos, vAng = ATOMBoxingArea:Teleport(hPlayer.ArenaID, hPlayer, nil, nil, nil, true)
					SpawnEffect(ePE_Light, vPos, g_Vectors.up)
					hPlayer:ChangeSpawnLocation("ArenaSpawn", { Pos = vPos, Ang = vAng })
					return true
				end

				return false
			end
		}, "ArenaSpawn")
	end,
	-----------
	-- SetInstantRevive
	SetInstantRevive = function(self, hPlayer, bRevive)
		hPlayer:SetInstantRevive(bRevive, "ArenaRevive")
	end,
	-----------
	-- Enter
	Enter = function(self, idArena, player, iArena, isCommand)

		--------
		if (not GetBetaFeatureStatus(FEATURENAME_ARENA)) then
			return false, "feature is disabled"
		end

		--------
		if (player.InStadium) then
			return false, "leave the stadium first"
		end

		--------
		self:SetPlayerSpawn(player)
		self:SetInstantRevive(player, true)

		--------
		self:CheckArea(idArena)
	
		--------
		if (idArena == 0) then
		
			--------
			if (player.InPVPArea) then
				self:Leave(1, player) end
		
			--------
			if (player.InArena) then
				self:Leave(2, player) end
			
			--------
			if (player.InBoxingArea) then
				return self:Leave(0, player) end
			
			--------
			SendMsg(CHAT_BOXING, ALL, "(%s: Entered the Boxing Arena ( #%d ))", player:GetName(), g_statistics:GetValue("BoxPlayers"))
			player.InBoxingArea = true;

			--------
			self:SetPlayerSpawn(player)
			self:DeleteArena(idArena)
			self:SpawnArea(idArena)
			self.ArenaBoxers[player.id] = player
			
		elseif (idArena == 1) then
		
			--------
			if (player.InBoxingArea) then
				self:Leave(0, player) end
		
			--------
			if (player.InArena) then
				self:Leave(2, player) end
				
			--------
			if (player.InPVPArea) then
				return self:Leave(1, player) end
			
			--------
			SendMsg(CHAT_BOXING, ALL, "(%s: Entered the PVP Arena ( #%d ))", player:GetName(), g_statistics:GetValue("PVPPlayers"))
			player.InPVPArea = true
			
			--------
			self:SetPlayerSpawn(player)
			self:DeleteArena(idArena)
			self:SpawnArea(idArena,1)
			self.PVPBoxers[player.id] = player
			
		elseif (idArena == 2) then
		
			--------
			if (player.InBoxingArea) then
				self:Leave(0, player) end
		
			--------
			if (player.InPVPArea) then
				self:Leave(1, player) end
				
			--------
			if (player.InArena) then
				return self:Leave(2, player) end

			--------
			if (isCommand and not self:IsArenaSpawned(iArena)) then
				self:SpawnArena(iArena,player)
				if (not self:IsArenaSpawned(iArena)) then
					return false, "failed to spawn the arena"
				end
			end
			
			--------
			player.InArena = true
			player.ArenaID = 1
			
			--------
			SendMsg(CHAT_BOXING, ALL, "(%s: Entered the Arena #%d ( #%d ))", player:GetName(), iArena, g_statistics:GetValue("ArenaPlayers"))
			
			--------
			self:SetPlayerSpawn(player)
			self.ArenaPlayers[player.id] = player
		end;
		
		--------
		local vPos = player:GetPos()
		local vAng = player:GetAngles()
		
		--------
		player.OldBoxPosition = {
			vPos, vAng
		}
		player.OldPVPPosition = {
			vPos, vAng
		}
		player.OldArenaPosition = {
			vPos, vAng
		}
		
		--------
		self:Teleport(idArena, player, nil, nil, nil, nil, true)
	end,
	-----------
	-- Enter
	Leave = function(self, t, player, r, noTp)


		player:RemoveSpawnLocation("ArenaSpawn")
		self:SetInstantRevive(player, false)

		--------
		if (t == 0) then
		
			--------
			if (not player.InBoxingArea) then
				return end
			
			--------
			SendMsg(CHAT_BOXING, ALL, "(%s: Has Left the Boxing Arena%s)", (player.sLastName or string.UNKNOWN), (r ~= nil and " (" .. r .. ")" or ""))
			
			--------
			if (not noTp) then

				player.InBoxingArea = false
				g_utils:RevivePlayer(player, player, true)
				--[[
				self:Teleport(-1, player, player.OldBoxPosition[1], player.OldBoxPosition[2])
				player.OldBoxPosition = nil
				
				if (player.OldItems) then
					for i, v in pairs(player.OldItems) do
						if (not player.inventory:GetItemByClass(i)) then
							local item = GetEnt(ItemSystem.GiveItem(i, player.id, false))
							ATOMEquip:CheckItem(player, item, nil, true)
							if (v.ammoType) then
								item.weapon:SetAmmoCount(nil, v.AmmoCurr);
								player.actor:SetInventoryAmmo(v.ammoType, v.AmmoTotal)
								player.inventory:SetAmmoCount(v.ammoType, v.AmmoTotal)
							end
						end
					end
				end
				--]]
			end
			
			--------
			self.ArenaBoxers[player.id] = nil
			
		elseif (t == 1) then
		
			--------
			if (not player.InPVPArea) then
				return end
				
			--------
			SendMsg(CHAT_PVP, ALL, "(%s: Has Left the PVP Arena%s)", (player:GetName() or string.UNKNOWN), (r and " (" .. r .. ")" or ""))
			
			--------
			if (not noTp) then
				g_utils:RevivePlayer(player, player, true)
				player.InPVPArea = false
				--self:Teleport(-1, player, player.OldPVPPosition[1], player.OldPVPPosition[2])
				--player.OldPVPPosition = nil
			end
			
			--------
			self.PVPBoxers[player.id] = nil
			
		elseif (t == 2) then
		
			--------
			if (not player.InArena) then
				return end
				
			--------
			SendMsg(CHAT_ARENA, ALL, "(%s: Has Left The Arena #%d%s)", (player:GetName() or string.UNKNOWN), checkNumber(player.ArenaID, -1), (r and " (" .. r .. ")" or ""))
			
			--------
			if (not noTp) then
				g_utils:RevivePlayer(player, player, true)
				player.InArena = false
				player.ArenaID = nil
				--self:Teleport(-1, player, player.OldArenaPosition[1], player.OldArenaPosition[2])
				--player.OldArenaPosition = nil
			end
			
			--------
			self.ArenaPlayers[player.id] = nil
		end
		
		--------
		self:Tick() -- Update arena (in case it wasn't spawned yet!)
	end,
	-----------
	-- Teleport
	Teleport = function(self, idArena, hPlayer, vPos, vAng, bLeft, bNoPort, bNoMsg)
		
		--------
		hPlayer:LeaveVehicle()
		
		--------
		if (bLeft) then
		
			local sMsg = "Stay in the Boxing Area!"
			local iMsg = CHAT_BOXING
			if (idArena == 1) then
				sMsg = "Stay in the PVP Area!" 
				iMsg = CHAT_PVP
			elseif (idArena == 2) then
				sMsg = "Stay in the Arena!"
				iMsg = CHAT_ARENA
			end
			
			SendMsg(iMsg, hPlayer, sMsg)
		end
		
		--------
		if (hPlayer:IsAlive()) then
			g_game:SetInvulnerability(hPlayer.id, true, 1) end
		
		--------
		if (vPos and vAng and self:WithinBounds(idArena, vPos)) then
			SpawnEffect(ePE_Light, hPlayer:GetPos(), g_Vectors.up)
			
			if (not hPlayer:IsSpectating()) then
				g_game:MovePlayer(hPlayer.id, vPos, vAng)
				SpawnEffect(ePE_Light, vPos, g_Vectors.up)
			end
			return
		end
		
		
		--------
		local vPos = (idArena == 0 and self.ArenaPos or self.PVPPos)
		local vSpawn = add2Vec(vPos, makeVec(
			GetRandom(8, 40),
			GetRandom(11, 40),
			1
		))
		
		if (idArena == 2) then
			vPos = self:GetArenaSpawn(hPlayer.ArenaID)
			vSpawn = checkVar(vPos, vSpawn)
		end
		
		--------
		local vPlayerPos = hPlayer:GetPos()
		local vPlayerAng = hPlayer:GetAngles()

		local vAng = vPlayerAng--Dir2Ang(vPlayerPos, vector.getdir({ x = vPos.x + 24, y = vPos.y + 129, z = vPos.z - 10 }))

		--------
		if (not bNoPort) then
			Script.SetTimer(1, function()

				SpawnEffect(ePE_Light, vPlayerPos, g_Vectors.up)

				if (not hPlayer:IsSpectating()) then
					g_game:MovePlayer(hPlayer.id, vSpawn, vPlayerAng)
					SpawnEffect(ePE_Light, vSpawn, g_Vectors.up)
				end
			end)
		end
			
		--------
		if (idArena == 0) then
			hPlayer.OldItems = {};
			--[[
			for i, v in pairs(hPlayer.inventory:GetInventoryTable()) do
				local hWeapon = GetEnt(v)
				if (hWeapon and hWeapon.weapon) then
					hPlayer.OldItems[hWeapon.class] = {
						AmmoCurr = hWeapon.weapon:GetAmmoCount(),
						AmmoTotal = hPlayer.inventory:GetAmmoCount(hWeapon.weapon:GetAmmoType() or ""),
						ammoType = hWeapon.weapon:GetAmmoType(),
					}
				end
			end
			]]
			
			hPlayer.inventory:Destroy()
			Script.SetTimer(1, function()
				ItemSystem.GiveItem("AlienCloak", hPlayer.id, true)
				ItemSystem.GiveItem("OffHand", hPlayer.id, true)
				ItemSystem.GiveItem("Fists", hPlayer.id, true)
				
				hPlayer.actor:SelectItemByNameRemote("Fists")
			end)

			g_statistics:AddToValue("BoxPlayers", 1)
			if (not bNoMsg) then
				SendMsg(CHAT_BOXING, ALL, "(%s: Teleported Inside the Boxing Arena ( #%d ))", hPlayer:GetName(), g_statistics:GetValue("BoxPlayers"))
			end
		elseif (idArena == 1) then
			g_statistics:AddToValue("PVPPlayers", 1)
			if (not bNoMsg) then
				SendMsg(CHAT_BOXING, ALL, "(%s: Teleported Inside the PVP Arena ( #%d ))", hPlayer:GetName(), g_statistics:GetValue("PVPPlayers"))
			end
		elseif (idArena == 2) then
			g_statistics:AddToValue("ArenaPlayers", 1)
			if (not bNoMsg) then
				SendMsg(CHAT_BOXING, ALL, "(%s: Teleported Inside the Arena #%d ( #%d ))", hPlayer:GetName(), hPlayer.ArenaID, g_statistics:GetValue("ArenaPlayers"))
			end
		end


		return vSpawn, vAng
	end,
	-----------
	-- WithinBounds
	
	WithinBounds = function(self, idArena, vPos)
	
		-------
		local aBounds = self.ArenaRadius
		if (idArena == 1) then
			aBounds = self.PVPRadius elseif  (idArena == 1) then
			aBounds = self.ArenaRadiuses[idArena] end
			
		-------
		if (
			aBounds and 
			aBounds.x and 
			aBounds.y and 
			aBounds.z and 
			(
			(vPos.x < aBounds.x[1] or vPos.x > aBounds.x[2]) or 
			(vPos.y < aBounds.y[1] or vPos.y > aBounds.y[2]) or 
			(vPos.z < aBounds.z[1] or vPos.z > aBounds.z[2])
			)
		) then
			return false
		end
	
		-------
		return true
	end,
	
	-----------
	-- OnRevive
	OnRevive = function(self, player)

		if (self.ArenaBoxers[player.id]) then
			self:Teleport(0, player)
		elseif (self.PVPBoxers[player.id]) then
			self:Teleport(1, player)
		elseif (self.ArenaPlayers[player.id]) then
			self:Teleport(2, player)
		end
	end,
	
	-----------
	-- GetArenaSpawn
	GetArenaSpawn = function(self, iArena)
		return GetRandom(checkArray(self.ArenaSpawns[iArena]))
	end,
	
	-----------
	-- IsArenaSpawned
	IsArenaSpawned = function(self, iArena)
		return (self.ArenasSpawned[iArena] == true)
	end,
	
	-----------
	-- Tick
	Tick = function(self)
		self:BoxTick()
		self:PVPTick()
		self:ArenaTick()
	end,
	-----------
	-- BoxTick
	BoxTick = function(self)
	
		local user_pos
		local limits = self.ArenaRadius
		
		for i, v in pairs(self.ArenaBoxers) do
			--g_game:MovePlayer(v.id,self.ArenaPos,v:GetAngles())
			if (not string.empty(v:GetName())) then
				v.sLastName = v:GetName()
			end
			if (GetEnt(i) and g_game:GetPlayerByChannelId(v:GetChannel())) then
				if (v.InBoxingArea) then
					if (v:IsSpectating()) then
						self:Leave(0, v, "User went Spectating");
					elseif (v:IsAlive()) then
						user_pos = v:GetPos()
						--Debug(user_pos.x,limits.x[1],limits.x[2])
						--Debug(user_pos.y,limits.y[1],limits.y[2])
						--Debug(user_pos.t,limits.t[1],limits.z[2])
						if (limits and limits.x and limits.y and limits.z and ((user_pos.x < limits.x[1] or user_pos.x > limits.x[2]) or (user_pos.y < limits.y[1] or user_pos.y > limits.y[2]) or (user_pos.z < limits.z[1] or user_pos.z > limits.z[2]))) then
							--Debug("out");
							self:Teleport(0, v, v.LastInsidePos, v.LastInsideAng, true)
						else
							--Debug("last pos set :D")
							v.LastInsidePos = v:GetPos()
							v.LastInsideAng = v:GetAngles()
						end
					end
				end
			else
				self:Leave(0, v, "User Disconnected", true)	
			end
		end
		
		self:CheckArea(0)
		
	end,
	-----------
	-- BoxTick
	PVPTick = function(self)
		local user_pos;
		local limits = self.PVPRadius;
		for i, v in pairs(self.PVPBoxers) do
			--g_game:MovePlayer(v.id,self.ArenaPos,v:GetAngles())
			if (GetEnt(i) and g_game:GetPlayerByChannelId(v:GetChannel())) then
				if (v.InPVPArea) then
					if (v:IsSpectating()) then
						self:Leave(1, v, "User went Spectating")
					elseif (v:IsAlive()) then
						user_pos = v:GetPos()
						--Debug(user_pos.x,limits.x[1],limits.x[2])
						--Debug(user_pos.y,limits.y[1],limits.y[2])
						--Debug(user_pos.t,limits.t[1],limits.z[2])
						if (limits and limits.x and limits.y and limits.z and ((user_pos.x < limits.x[1] or user_pos.x > limits.x[2]) or (user_pos.y < limits.y[1] or user_pos.y > limits.y[2]) or (user_pos.z < limits.z[1] or user_pos.z > limits.z[2]))) then
							--Debug("out");
							self:Teleport(1, v, v.LastPVPInsidePos, v.LastPVPInsideAng, true)
						else
							--Debug("last pos set :D")
							v.LastPVPInsidePos = v:GetPos()
							v.LastPVPInsideAng = v:GetAngles()
						end;
					end;
				end;
			else
				self:Leave(1, v, "User Disconnected", true)	
			end
		end
		
		self:CheckArea(1)
		
	end,
	
	-----------
	-- ArenaTick
	ArenaTick = function(self)
	
		local aBBoxes = self.ArenaRadius
		local vBBox
		local vPlayer
		
		for idPlayer, hPlayer in pairs(self.ArenaPlayers) do
		
			if (GetEnt(idPlayer) and g_game:GetPlayerByChannelId(hPlayer:GetChannel())) then
				if (hPlayer.InArena) then
					if (hPlayer:IsSpectating()) then
						self:Leave(2, hPlayer, "User went Spectating")
					elseif (hPlayer:IsAlive()) then
						vPlayer = hPlayer:GetPos()
						vBBox = self.ArenaRadiuses[hPlayer.ArenaID]
						-- Debug(vPlayer.x,vBBox.x[1],vBBox.x[2])
						-- Debug(vPlayer.y,vBBox.y[1],vBBox.y[2])
						-- Debug(vPlayer.z,vBBox.z[1],vBBox.z[2])
						
						if (vBBox and vBBox.x and vBBox.y and vBBox.z and ((vPlayer.x < vBBox.x[1] or vPlayer.x > vBBox.x[2]) or (vPlayer.y < vBBox.y[1] or vPlayer.y > vBBox.y[2]) or (vPlayer.z < vBBox.z[1] or vPlayer.z > vBBox.z[2]))) then
							self:Teleport(2, hPlayer, hPlayer.LastArenaInsidePos, hPlayer.LastArenaInsideAng, true)
							-- Debug("BAD!")
						else
							--Debug("last pos set :D")
							hPlayer.LastArenaInsidePos = hPlayer:GetPos()
							hPlayer.LastArenaInsideAng = hPlayer:GetAngles()
						end
					end
				end
			else
				self:Leave(2, hPlayer, "User Disconnected", true)	
			end
		end
		
		self:CheckArea(2)
		
	end,
	-----------
	
	CheckArea = function(self, idArena)
	
		local iActive = 0
		if (idArena == 0) then
			iActive = arrSize(self.ArenaBoxers)
			if (self.ArenaSpawned) then
				if (iActive < 1) then
					self:Despawn(0, false)
				end
			elseif (iActive > 0) then
				--Debug("SPAWN !! :S")
				self:SpawnArea(0, false)
			end

			--Debug("kk",tostring(#self.ArenaParts))
			--for i,v in pairs(self.ArenaParts or {}) do
			--	Debug("kk ok LOL")
			--	v:AddImpulse(-1,v:GetPos(),g_Vectors.up,1,1)
			--end
			
		elseif (idArena == 1) then
		
			iActive = arrSize(self.PVPBoxers)
			if (self.PVPSpawned) then
				if (iActive < 1) then
					self:Despawn(1, true)
				end;
			elseif (iActive > 0) then
				self:SpawnArea(1, true)
			end
--
			--Debug("kk",tostring(#self.PVPParts))
			--for i,v in pairs(self.PVPParts or {}) do
					--Debug("kk ok LOL")

				--SpawnEffect(ePE_Flare,v:GetPos(),g_Vectors.up,0.1)
				--v:SetWorldPos(v:GetPos())
				--g_utils:AwakeEntity(v)
				--v:AddImpulse(-1,v:GetPos(),g_Vectors.up,1,1)
			--end
			
		elseif (idArena == 2) then
		
			local aActive = {}
			for i, v in pairs(self.ArenaPlayers) do
				aActive[v.ArenaID] = (aActive[v.ArenaID] or 0) + 1
			end
			
			for i, v in pairs(self.ArenasSpawned) do
				if (v and ((aActive[i] or 0) >= 1 or not timerexpired(self.ArenaSpawnTimers[i], (60 * 60)))) then
					if (not self:ArenaExists(i)) then
						--Debug("BUILD ARENA NOW!! ENABLED BUT NO EXIST",i)
						self:SpawnArena(i)
					end
				elseif (self:ArenaExists(i)) then
					Debug("REMOVE ARENA! DISABLED BUT STILL EXISTS OR NO PLAYERS!!")
					self:DeleteArena(i)
				end
			end
			-- Debug("checking all arenas?")
		end
	
	end,

};

ATOMBoxingArea:Init()