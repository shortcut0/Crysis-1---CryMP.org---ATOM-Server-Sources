ATOMSetup:AddSetup('multiplayer/ps/mesa', function()
	-- Proto door 1
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/vehicle_factory/vehicle_factory_door_c.cgf|0|sounds/environment:doors:door_metal_sheet_open+sounds/environment:doors:door_metal_sheet_close+n|90+200+0x|x1",
		position = {
			x = 2110.26,
			y = 1990.8,
			z = 49.2715
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 90,
			z = 90
		}),
		scale = 0.9078
	}).AutoClose = { timer = 30 };
	-- Proto door 2
	--[[
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/prototype_factory/entrance_door_a.cgf|0|sounds/environment:doors:metal_glass_door_open+sounds/environment:doors:metal_glass_door_close+n|90+200+0x|x1",
		position = {
			x = 2098.036,
			y = 1997.258,
			z = 49.201
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = 0
		}),
		scale = 1
	});
	-----------------------------------
	-- Proto door 3
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/prototype_factory/entrance_door_b.cgf|0|sounds/environment:doors:metal_glass_door_open+sounds/environment:doors:metal_glass_door_close+n|-90+200+0x|x1",
		position = {
			x = 2098.028,
			y = 1994.842,
			z = 49.201
		},
		SpawnFunc = "OnReset",
		orientation = makeVec(
			1,
			0,
			0
		) or Dir2Ang({
			x = 0,
			y = 90,
			z = 90
		}),
		scale = 1
	});
	--]]
	--[[
	-- Proto door 4
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/prototype_factory/entrance_door_b.cgf|0|sounds/environment:doors:metal_glass_door_open+sounds/environment:doors:metal_glass_door_close+n|-90+200+0x|x3",
		position = {
			x = 2104.105,
			y = 1995.337,
			z = 49.201
		},
		SpawnFunc = "OnReset",
		orientation = makeVec(
			0,
			-1,
			0
		),
		scale = 1
	});
	-----------------------------------
	-- Proto door 5
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/prototype_factory/entrance_door_a.cgf|0|sounds/environment:doors:metal_glass_door_open+sounds/environment:doors:metal_glass_door_close+n|-90+200+0x|x5",
		position = {
			x = 2106.54,
			y = 1995.337,
			z = 49.201
		},
		SpawnFunc = "OnReset",
		orientation = makeVec(
			0,
			-1,
			0
		),
		scale = 1
	});--]]
	-----------------------------------
	-- Proto door 6
	AddEntity({
		class = "Door",
		network = true,
		name = "objects/library/architecture/multiplayer/vehicle_factory/vehicle_factory_door_b.cgf|0|sounds/environment:doors:metal_glass_door_open+sounds/environment:doors:metal_glass_door_close+n|-90+200+0x|x5",
		position = {
			x = 2109.734,
			y = 2011.848,
			z = 49.2113
		},
		SpawnFunc = "OnReset",
		orientation = makeVec(
			0,
			0,
			0
		),
		scale = 0.9114
	}).AutoClose = { timer = 30 };
	
	function multV(mult, vec)
		return { x = mult*vec.x, y = mult*vec.y, z = mult*vec.z };
	end;

	function reverseV(vec)
		return { x = -vec.x, y = -vec.y, z = -vec.z };
	end;

	function turnLeftV(vec)
		return { x = -vec.y, y = vec.x, z = vec.z };
	end;

	function turnRightV(vec)
		return { x = vec.y, y = -vec.x, z = vec.z };
	end;
	
	local function spawnDoors(bunker, base_pos , rot)
	
		-- the model
		local _model = "Objects/library/barriers/concrete_wall/gate_6m.cgf";
		-- the material
		local _material = "objects/library/architecture/aircraftcarrier/handrails/catwalk_handrails_whitemetal";
	
		-- directions
		local bdir 	= rot;
		local fwd   = turnLeftV(bdir);
		local left  = reverseV(bdir);
		local right = bdir;
		
		--[[
		-- The Switches
		local switch = AddEntity({
			class = "ElevatorSwitch",
			network = false,
			name = "objects/library/architecture/aircraftcarrier/props/consoles/elevator_console.cgf|0+1|Close Bunker|Sounds/environment:soundspots:elevator_hangar_button|" .. g_utils:SpawnCounter(),
			position = bunker:ToGlobal( -1, makeVec(1.2842, -1.4211, -1.6391) ),
			orientation = reverseV(fwd),
			scale = 1,
		});

		local switch2 = AddEntity({
			class = "ElevatorSwitch",
			network = false,
			name = "objects/library/architecture/aircraftcarrier/props/consoles/elevator_console.cgf|0+0|Close Bunker|Sounds/environment:soundspots:elevator_hangar_button|" .. g_utils:SpawnCounter(),
			position = bunker:ToGlobal( -1, makeVec(1.2842,  1.4211, -1.6391) ),
			orientation = reverseV(fwd),
			scale = 1,
		});
		
		switch._bunker = bunker;
		switch2._bunker = bunker;
		
		local door1 = AddEntity({
			class = "Door",
			network = true,
			name = "objects/library/architecture/aircraftcarrier/doors/doorbig2b.cgf|0|sounds/environment:doors:naval_factory_door_open+sounds/environment:doors:naval_factory_door_close+n|90+200+0x|x5",
			position = bunker:ToGlobal(-1, makeVec(2.3425, 4.497, -1.061)),
			SpawnFunc = "OnReset",
			orientation = reverseV(right),
			scale = 1.06
		});
		--SpawnEffect(ePE_Flare,bunker:ToGlobal(-1, makeVec(4.0425, 4.497, -1.061)))
		local door2 = AddEntity({
			class = "Door",
			network = true,
			name = "objects/library/architecture/aircraftcarrier/doors/doorbig2.cgf|0|sounds/environment:doors:naval_factory_door_open+sounds/environment:doors:naval_factory_door_close+n|-90+200+0x|x6",
			position = bunker:ToGlobal(-1, makeVec(2.3479, -4.3745, -1.061)),
			SpawnFunc = "OnReset",
			orientation = right,
			scale = 1.06
		});
		
		bunker.BunkerDoors = {
			door1, door2
		};
		
		door1.AutoClose = { timer = 15 };
		door2.AutoClose = { timer = 15 };
		
		bunker.SealBunker = function(self, user)
			local d1, d2 = bunker.BunkerDoors[1], bunker.BunkerDoors[2];
			
			if (not self.Sealed) then
				
				self.Sealed = true;
				
				d1.Server.SvRequestOpen(d1, (user or ATOM.Server).id, false, true);
				d2.Server.SvRequestOpen(d2, (user or ATOM.Server).id, false, true);
				
				d1.Locked = "This Door is Locked";
				d2.Locked = "This Door is Locked";
				
			else
			
				self.Sealed = false;
				
				--d1.Server.SvRequestOpen(d1, (user or ATOM.Server).id, not d1.lastMode, true);
				--d2.Server.SvRequestOpen(d2, (user or ATOM.Server).id, not d1.lastMode, true);
				
				--d1.Server.SvRequestOpen(d1, (user or ATOM.Server).id, nil, true);
				--d2.Server.SvRequestOpen(d2, (user or ATOM.Server).id, nil, true);
				
				d1.Locked = nil;
				d2.Locked = nil;
			end;
			
			if (user) then
				SendMsg(CHAT_ATOM, user, "BUNKER DOORS : %s", self.Sealed and "LOCKED" or "UNLOCKED");
			end;
		end;
		--]]
		
		-- directions
		local directions = {
			fwd, -- bunker direction
			rot, -- bunker direction
			fwd, -- bunker direction
		};
		-- local positions
		local positions = {
			makeVec( -1.1492, -4.2734, -1.8255 ), -- wall 1 pt 1
			makeVec( -4.2681,   0.113, -1.8255 ), -- wall 1 pt 2
			makeVec( -1.1492,  4.3940, -1.8255 ), -- wall 2 pt 1
		};
		
		local all = {};
		for i = 1, 3 do
			all[#all + 1] = SpawnGUINew({
				Model = _model,
				Pos = bunker:ToGlobal(-1, positions[i]);
				Dir = directions[i],
				bStatic = 1,
				Mass = 0,
			});
		end;
		MarkAsMapSetup(unpack(all));
		
		do return end;
		Script.SetTimer(1000, function()
			if (GetEnt(switch.id)) then
				local code = [[
					local s = GetEnt(']]  .. switch:GetName()   .. [[');
					local s2 = GetEnt(']] .. switch2:GetName()  .. [[');
					if (s) then
						s.Used = function(self,user)
							if (CryAction.IsServer()) then
								self._bunker:SealBunker(user or GetPlayersInRange(self:GetPos(),5)[1]);
							else
								ATOMClient:ToServer(eTS_Spectator,75);
							end;
						end;
					end;
					if (s2) then
						s2.Used = function(self,user)
							if (CryAction.IsServer()) then
								self._bunker:SealBunker(user or GetPlayersInRange(self:GetPos(),5)[1]);
							else
								ATOMClient:ToServer(eTS_Spectator,75);
							end;
						end;
					end;
				]];
				RCA:SetSync(switch, { client = code, linked = switch.id, links = all });
				ExecuteOnAll(code);
				loadstring(code)();
			
			end;
		end);
		
		
	end;
	local bunkers = g_utils.sorted_buildings.bunker;
	for i, v in pairs(bunkers) do
		spawnDoors(v, v:GetPos(), v:GetDirectionVector(1))
		--Objects/library/barriers/fence/concrete/concrete_wall_200_200_a.cgf
		--objects/library/architecture/aircraftcarrier/handrails/catwalk_handrails_whitemetal
	end;
	
	local function condi(player, portalId)
	
		if (not player.actor) then
			return
		end
	
		local proto = g_utils:GetBuilding("Proto")
		if (proto) then
			if (g_game:GetTeam(proto.id) == g_game:GetTeam(player.id)) then
				return false, "You cannot Teleport to the Prototype Factory while your team owns it"
			elseif (g_game:GetTeam(proto.id) == TEAM_NEUTRAL) then
				return false, "You cannot Teleport to the Prototype Factory while no team owns it"
			end
		end
		local last = player.lastPortalTeleports[portalId]
		local delay = 180
		if (last and _time - last < delay) then
			return false, "Please wait " .. calcTime(math.floor(delay - (_time - last)), true, unpack(GetTime_SM)) .. " before using this Portal again", 3
		end
		return true
	end

	MarkAsMapSetup(addPortal(makeVec(1557.020, 1771.892, 81.663), makeVec(-0.732, -0.681, 0.000), nil, "the Prototype Factory", "the Prototype Factory", condi))
	MarkAsMapSetup(addPortal(makeVec(2564.605, 2471.429, 60.559), makeVec(-0.030, -1.000, 0.000), nil, "the Prototype Factory", "the Prototype Factory", condi))

end);







	