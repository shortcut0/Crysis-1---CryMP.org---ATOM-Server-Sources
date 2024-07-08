ATOMSetup:AddSetup('multiplayer/ia/outpost', function()

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/barriers/concrete_wall/door.cgf|0|sounds/environment:doors:door_metal_sheet_open+sounds/environment:doors:door_metal_sheet_close+n|90+200+0x|x1",
		position = {
			x = 1114.333,
			y = 972.5009,
			z = 162.996
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 0.87
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/barriers/concrete_wall/door.cgf|0|sounds/environment:doors:door_metal_sheet_open+sounds/environment:doors:door_metal_sheet_close+n|90+200+0x|x2",
		position = {
			x = 1114.333,
			y = 972.5009,
			z = 160.0826
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 0.87
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/barriers/concrete_wall/door.cgf|0|sounds/environment:doors:door_metal_sheet_open+sounds/environment:doors:door_metal_sheet_close+n|90+200+0x|x3",
		position = {
			x = 1110.955,
			y = 961.0115,
			z = 160.126
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 0.8004
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/barriers/concrete_wall/door.cgf|0|sounds/environment:doors:door_metal_sheet_open+sounds/environment:doors:door_metal_sheet_close+n|90+200+0x|x4",
		position = {
			x = 1131.069,
			y = 959.1457,
			z = 163.6272
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -180
		}),
		scale = 0.8004
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/architecture/aircraftcarrier/doors/doorbig.cgf|0|sounds/environment:doors:naval_factory_door_open+sounds/environment:doors:naval_factory_door_close+n|-90+70+0x|x1",
		position = {
			x = 1091.726,
			y = 1010.769,
			z = 160.5939
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 1
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/architecture/aircraftcarrier/doors/doorbig.cgf|0|sounds/environment:doors:naval_factory_door_open+sounds/environment:doors:naval_factory_door_close+n|-90+70+0x|x2",
		position = {
			x = 1091.476,
			y = 953.019,
			z = 160.3439
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 1
	});

	local AnimDoor1 = AddEntity({
		class = "AnimDoor",
		network = true,
		name = "Objects/library/alien/props/hangar_tunel/hatch_passage_door.cga|n+n|sounds/environment:storage_vs2:door_trooper_open+sounds/environment:storage_vs2:door_trooper_close|x1",
		position = {
			x = 1048,
			y = 946.125,
			z = 165
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = 0
		}),
		angles = DirZ2Ang({
			x = 0,
			y = 0,
			z = -90 --1.57373 + 1.57373 ---90/57.18897142457728
		}),
		scale = 1
	});

	AddEntity({
		class = "US_ltv",
		network = true,
		name = "LTV-ParkingLot-1",
		position = {
			x = 1123.115,
			y = 952.3261,
			z = 159.9084
		},
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		properties = {
			Modification = "MP",
			Paint = "us",
			Respawn = {
				bAbandon = 1,
				bRespawn = 1,
				bUnique = 1,
				nAbandonTimer = 20,
				nTimer = 25
			}
		}
	});

	AddEntity({
		class = "GUI",
		network = true,
		name = "objects/library/architecture/nodule/buildings/mine_entrance/gate_nodoor.cgf|1+-1+1000|n|x1",
		position = {
			x = 1114.606,
			y = 935.159,
			z = 163.3799
		},
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 1
	});

	AddEntity({
		class = "GUI",
		network = true,
		name = "objects/library/architecture/nodule/buildings/mine_entrance/mine_entrance_exterior.cgf|1+-1+1000|n|x1",
		position = {
			x = 1115.732,
			y = 932.581,
			z = 163.7465
		},
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 0.51
	});

	AddEntity({
		class = "Door",
		network = true,
		name = "Objects/library/architecture/multiplayer/roundtunnel/roundtunnel_gate.cgf|0|n+sounds/environment:doors:metal_gate_stop+n|0+70+8_y|x1",
		position = {
			x = 1116.148,
			y = 933.0117,
			z = 163.9394
		},
		SpawnFunc = "OnReset",
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = -90
		}),
		scale = 0.5118
	});

	AddEntity({
		class = "GUI",
		network = true,
		name = "objects/natural/rocks/cliff_rocks/cliff_rock_mine_exit_a.cgf|1+-1+1000|n|x1",
		position = {
			x = 1118.148,
			y = 932.2617,
			z = 172.8144
		},
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = 0
		}),
		angles = DirZ2Ang({
			x = 0,
			y = 0,
			z = 90 --1.57373 + 1.57373 ---90/57.18897142457728
		}),
		scale = 0.354
	});

	AddEntity({
		class = "GUI",
		network = true,
		name = "Objects/Library/Storage/military/transport_case.cgf|1+-1+1000|n|x1",
		position = {
			x = 1118.586,
			y = 935.0386,
			z = 163.7291
		},
		orientation = Dir2Ang({
			x = 0,
			y = 0,
			z = 30
		}),
		--[[angles = DirZ2Ang({
			x = 0,
			y = 0,
			z = 90 --1.57373 + 1.57373 ---90/57.18897142457728
		}),--]]
		scale = 1
	});

	AddEntity({
		class = "FY71",
		network = true,
		name = "Objects/Library/Storage/military/transport_case.cgf|1+-1+1000|n|x1",
		position = {
			x = 1118.586,
			y = 935.0386,
			z = 164.3
		},
		properties = {
			Respawn = {
				bUnique = 0,
				bRespawn = 1,
				nTimer = 1
			};
			InitialSetup = "LAMRifle,Silencer,Reflex"
		};
		orientation = {
			x = 1.57373,
			y = 0,
			z = 0
		},
		--[[angles = DirZ2Ang({
			x = 0,
			y = 0,
			z = 90 --1.57373 + 1.57373 ---90/57.18897142457728
		}),--]]
		scale = 1
	});
end);






































