------------------------------------------------------------
-- !fps <Timer>, Shows your Average FPS and Spec in Chat
------------------------------------------------------------

NewCommand({
	Name 	= "fps",
	Access	= GUEST,
	Description = "Shows your Average FPS and Spec in Chat",
	Console = true,
	Args = {
		{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 30,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local timer;
		if (Timer) then
			timer = math.min(Timer, 60);
		end;
		SendMsg(CHAT_ATOM, player, "Gathering FPS, Please wait" .. (timer and " :: " .. timer .. "s Average" or ""));
		ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_ReportFPS, " .. (timer and timer .. ", " or "") .. "nil)");
		return true;
	end;
});

------------------------------------------------------------
-- !usemountable
------------------------------------------------------------

NewCommand({
	Name 	= "usemountable",
	Access	= GUEST,
	Description = "",
	Console = true,
	Args = {
	},
	Properties = {
		Hidden = true,
	},
	func = function(hUser, sEntity)
		local hEntity = GetEntity(sEntity)
		Debug(sEntity)
		if (hEntity) then
			hEntity:OnUse(hUser)
		end
	end
})

------------------------------------------------------------
-- !fps <Timer>, Shows your Average FPS and Spec in Chat
------------------------------------------------------------

NewCommand({
	Name 	= "bmplace",
	Access	= GUEST,
	Description = "no description",
	Console = true,
	Args = {
		{ "a", "x", Integer = true },
		{ "b", "x", Integer = true },
		{ "c", "x", Integer = true },
		{ "d", "x", Integer = true },
		{ "e", "x", Integer = true },
		{ "f", "x", Integer = true },
		{ "g", "x", Concat = true },
	},
	Properties = {
		Hidden = true,
		Self = 'RCA',
		Timer = 30,
		RequireRCA = true
	},
	func = function(self, player, pX, pY, pZ, dX, dY, dZ, sModel)

		local vPos = vector.make(pX, pY, pZ)
		local vDir = vector.make(dX, dY, dZ)

		Debug("sPos",vPos)
		Debug("sDir",vDir)

		local CATEGORY_PROPS = 1
		local CATEGORY_BUILDINGS = 2
		local CATEGORY_PREFABS = 3

		local aList = {
			[CATEGORY_PROPS] = {
				Name = "Props",
				Models = {
					{ Name = "Small Box", File = "Objects/library/storage/civil/civil_box_a_mp.cgf" },
					{ Name = "Large Box", File = "Objects/library/storage/civil/civil_box_b_mp.cgf" },
					{ Name = "Red Barrel", File = "objects/library/storage/barrels/barrel_red.cgf" },
				}
			},
			[CATEGORY_BUILDINGS] = {
				Name = "Buildings",
				Models = {
					{ Name = "Air Control Tower", 		File = "objects/library/architecture/airfield/air_control_tower/air_control_tower_mp.cgf";  },
					{ Name = "Control Tower", 			File = "objects/library/architecture/airfield/air_control_tower/control_tower_b.cgf" },
					{ Name = "Air Control Tower 2", 	File = "objects/library/architecture/airfield/air_control_tower/air_control_tower_mockup.cgf"; },
					{ Name = "Air Control Tower 3", 	File = "objects/library/architecture/airfield/air_control_tower_b/air_control_tower_b.cgf" },
					{ Name = "Motel", 	File = "objects/library/architecture/hillside_cafe/sleep_house_5_rooms.cgf" },
					{ Name = "Village House 1", 	File = "objects/library/architecture/village/village_house1.cgf" },
					{ Name = "Village House 2", 	File = "objects/library/architecture/village/village_house2.cgf" },
					{ Name = "Village House 3", 	File = "objects/library/architecture/village/village_house3.cgf" },
					{ Name = "Village House 4", 	File = "objects/library/architecture/village/village_house4.cgf" },
					{ Name = "Village House 5", 	File = "objects/library/architecture/village/village_house5.cgf" },
					{ Name = "Village House 6", 	File = "objects/library/architecture/village/village_house6.cgf" },
					{ Name = "Village House 7", 	File = "objects/library/architecture/village/village_house7.cgf" },
					{ Name = "Village House 8", 	File = "objects/library/architecture/village/village_house8.cgf" },
					{ Name = "Village House 9", 	File = "objects/library/architecture/village/village_house9.cgf" },
				}
			},
			[CATEGORY_PREFABS] = {
				Name = "Prefabs",
				Models = {
					{ Name = "Prefab: Cafe", 	Files = {
						"objects/library/architecture/hillside_cafe/cafe_house.cgf",
						"objects/library/architecture/hillside_cafe/terrace.cgf",
						"objects/library/architecture/hillside_cafe/glass_01.cgf",
						"objects/library/architecture/hillside_cafe/glass_02.cgf",
						"objects/library/architecture/hillside_cafe/glass_03.cgf",
						"objects/library/architecture/hillside_cafe/glass_04.cgf",
						"objects/library/architecture/hillside_cafe/glass_05.cgf",
						"objects/library/architecture/hillside_cafe/glass_06.cgf",
						"objects/library/architecture/hillside_cafe/glass_07.cgf",
						"objects/library/architecture/hillside_cafe/glass_08.cgf",
						"objects/library/architecture/hillside_cafe/glass_09.cgf",
						"objects/library/architecture/hillside_cafe/glass_10.cgf",
						"objects/library/architecture/hillside_cafe/glass_11.cgf",
						"objects/library/architecture/hillside_cafe/glass_12.cgf",
						"objects/library/architecture/hillside_cafe/glass_13.cgf",
						"objects/library/architecture/hillside_cafe/glass_14.cgf",
						"objects/library/architecture/hillside_cafe/glass_15.cgf",
					}},
					{ Name = "Prefab: Warehouse", 	Files = {
						"objects/library/architecture/harbour/warehouse/warehouse.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_2.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_base_rampa.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_decal.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_glass_big.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_in.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_kitchen.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_kitchen_wall.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_metal_shelter_cable.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_metal_shelter.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_room_01.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_room_02.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_room_03.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_room_04_01.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_room_5.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_signs.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_stairs.cgf",
						"objects/library/architecture/harbour/warehouse/warehouse_stairs_02.cgf",
					}},
					{ Name = "Prefab: Workshop", 	Files = {
						"objects/library/architecture/harbour/workshop/workshop.cgf",
						"objects/library/architecture/harbour/workshop/workshop_2.cgf",
						"objects/library/architecture/harbour/workshop/workshop_2_detail_breakable.cgf",
						"objects/library/architecture/harbour/workshop/workshop_decal_door.cgf",
						"objects/library/architecture/harbour/workshop/workshop_glass.cgf",
						"objects/library/architecture/harbour/workshop/workshop_in.cgf",
						"objects/library/architecture/harbour/workshop/workshop_in_crane.cgf",
					}},
					{ Name = "Prefab: Closed Terminal", 	Files = {
						"objects/library/architecture/airfield/terminal_building_b/exterior.cgf",
						"objects/library/architecture/airfield/terminal_building_b/interior.cgf",
						"objects/library/architecture/airfield/terminal_building_b/roof.cgf",
						"objects/library/architecture/airfield/terminal_building_b/walls_first_floor.cgf",
						"objects/library/architecture/airfield/terminal_building_b/walls_ground_floor.cgf",
					}},
					{ Name = "Prefab: Terminal", 	Files = {
						"objects/library/architecture/airfield/terminal/ext_departure_canopy.cgf",
						"objects/library/architecture/airfield/terminal/ext_entrance_roof.cgf",
						"objects/library/architecture/airfield/terminal/ext_entrance_supports.cgf",
						"objects/library/architecture/airfield/terminal/ext_floor.cgf",
						"objects/library/architecture/airfield/terminal/ext_mainwall.cgf",
						"objects/library/architecture/airfield/terminal/ext_pillars1.cgf",
						"objects/library/architecture/airfield/terminal/ext_pillars2.cgf",
						"objects/library/architecture/airfield/terminal/ext_pillars3.cgf",
						"objects/library/architecture/airfield/terminal/ext_pillars4.cgf",
						"objects/library/architecture/airfield/terminal/ext_roof.cgf",
						"objects/library/architecture/airfield/terminal/ext_simplepillars.cgf",
						"objects/library/architecture/airfield/terminal/ext_stairs_departure.cgf",
						"objects/library/architecture/airfield/terminal/ext_topwindowframe.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway1.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway1_pillars.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway1_railing.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway2.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway2_pillars.cgf",
						"objects/library/architecture/airfield/terminal/ext_walkway2_railing.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_cafe.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_departure.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_depstairs.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_entrance.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_helpdesk.cgf",
						"objects/library/architecture/airfield/terminal/ext_windowframes_walkway2.cgf",
						"objects/library/architecture/airfield/terminal/int_2ndfloor.cgf",
						"objects/library/architecture/airfield/terminal/int_2ndfloor_corner1.cgf",
						"objects/library/architecture/airfield/terminal/int_2ndfloor_corner2.cgf",
						"objects/library/architecture/airfield/terminal/int_2ndfloor_railing.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe01.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe02.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe03.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe04.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe05.cgf",
						"objects/library/architecture/airfield/terminal/int_doorframe06.cgf",
						"objects/library/architecture/airfield/terminal/int_entrance_roof.cgf",
						--"objects/library/architecture/airfield/terminal/int_floor.cgf",
						"objects/library/architecture/airfield/terminal/int_floor1.cgf",
						"objects/library/architecture/airfield/terminal/int_floor2.cgf",
						"objects/library/architecture/airfield/terminal/int_floor3.cgf",
						"objects/library/architecture/airfield/terminal/int_floor4.cgf",
						"objects/library/architecture/airfield/terminal/int_floor5.cgf",
						"objects/library/architecture/airfield/terminal/int_floor6.cgf",
						"objects/library/architecture/airfield/terminal/int_floor7.cgf",
						"objects/library/architecture/airfield/terminal/int_floor8.cgf",
						"objects/library/architecture/airfield/terminal/int_floor9.cgf",
						"objects/library/architecture/airfield/terminal/int_floor10.cgf",
						"objects/library/architecture/airfield/terminal/int_floor11.cgf",
						"objects/library/architecture/airfield/terminal/int_floor12.cgf",
						"objects/library/architecture/airfield/terminal/int_floor13.cgf",
						"objects/library/architecture/airfield/terminal/int_floor14.cgf",
						"objects/library/architecture/airfield/terminal/int_floor15.cgf",
						"objects/library/architecture/airfield/terminal/int_floor16.cgf",
						"objects/library/architecture/airfield/terminal/int_floor17.cgf",
						"objects/library/architecture/airfield/terminal/int_floor18.cgf",
						"objects/library/architecture/airfield/terminal/int_floor19.cgf",
						"objects/library/architecture/airfield/terminal/int_floor20.cgf",
						"objects/library/architecture/airfield/terminal/int_floor21.cgf",
						"objects/library/architecture/airfield/terminal/int_floor22.cgf",
						"objects/library/architecture/airfield/terminal/int_floor23.cgf",
						"objects/library/architecture/airfield/terminal/int_floor24.cgf",
						"objects/library/architecture/airfield/terminal/int_floor25.cgf",
						"objects/library/architecture/airfield/terminal/int_floor26.cgf",
						"objects/library/architecture/airfield/terminal/int_floor27.cgf",
						"objects/library/architecture/airfield/terminal/int_floor28.cgf",
						"objects/library/architecture/airfield/terminal/int_floor29.cgf",
						"objects/library/architecture/airfield/terminal/int_floor30.cgf",
						"objects/library/architecture/airfield/terminal/int_floor31.cgf",
						"objects/library/architecture/airfield/terminal/int_floor32.cgf",
						"objects/library/architecture/airfield/terminal/int_floor33.cgf",
						"objects/library/architecture/airfield/terminal/int_floor34.cgf",
						"objects/library/architecture/airfield/terminal/int_floor35.cgf",
						"objects/library/architecture/airfield/terminal/int_floor36.cgf",
						"objects/library/architecture/airfield/terminal/int_floor37.cgf",
						"objects/library/architecture/airfield/terminal/int_floor38.cgf",
						"objects/library/architecture/airfield/terminal/int_floor39.cgf",
						"objects/library/architecture/airfield/terminal/int_floor40.cgf",
						"objects/library/architecture/airfield/terminal/int_floor41.cgf",
						"objects/library/architecture/airfield/terminal/int_floor42.cgf",
						"objects/library/architecture/airfield/terminal/int_floor43.cgf",
						"objects/library/architecture/airfield/terminal/int_floor44.cgf",
						"objects/library/architecture/airfield/terminal/int_floor45.cgf",
						"objects/library/architecture/airfield/terminal/int_floor46.cgf",
						"objects/library/architecture/airfield/terminal/int_floor47.cgf",
						"objects/library/architecture/airfield/terminal/int_gardenframe.cgf",
						"objects/library/architecture/airfield/terminal/int_giftshop_shelf1.cgf",
						"objects/library/architecture/airfield/terminal/int_giftshop_shelf2.cgf",
						"objects/library/architecture/airfield/terminal/int_giftshop_shelf3.cgf",
						"objects/library/architecture/airfield/terminal/int_giftshop_shelf4.cgf",
						"objects/library/architecture/airfield/terminal/int_luggagerack.cgf",
						"objects/library/architecture/airfield/terminal/int_mainwall.cgf",
						"objects/library/architecture/airfield/terminal/int_pillars1.cgf",
						"objects/library/architecture/airfield/terminal/int_pillars4.cgf",
						"objects/library/architecture/airfield/terminal/int_roof.cgf",
						"objects/library/architecture/airfield/terminal/int_shop1_shelf1.cgf",
						"objects/library/architecture/airfield/terminal/int_shop1_shelf2.cgf",
						"objects/library/architecture/airfield/terminal/int_shop1_shelf3.cgf",
						"objects/library/architecture/airfield/terminal/int_shop2_freezer.cgf",
						"objects/library/architecture/airfield/terminal/int_shop2_shelf1.cgf",
						"objects/library/architecture/airfield/terminal/int_shop2_shelf2.cgf",
						"objects/library/architecture/airfield/terminal/int_shop2_shelf3.cgf",
						"objects/library/architecture/airfield/terminal/int_sign_toilets.cgf",
						"objects/library/architecture/airfield/terminal/int_simplepillars.cgf",
						"objects/library/architecture/airfield/terminal/int_stairs.cgf",
						--"objects/library/architecture/airfield/terminal/int_stairs_railing.cgf",
						"objects/library/architecture/airfield/terminal/int_supports1.cgf",
						"objects/library/architecture/airfield/terminal/int_toiletmen_stalls.cgf",
						"objects/library/architecture/airfield/terminal/int_toiletwomen_stalls.cgf",
						"objects/library/architecture/airfield/terminal/int_walls1.cgf",
						"objects/library/architecture/airfield/terminal/int_walls2.cgf",
						"objects/library/architecture/airfield/terminal/int_walls3.cgf",
						"objects/library/architecture/airfield/terminal/int_walls4.cgf",
						"objects/library/architecture/airfield/terminal/int_walls5.cgf",
						"objects/library/architecture/airfield/terminal/int_walls6.cgf",
						"objects/library/architecture/airfield/terminal/int_walls7.cgf",
						"objects/library/architecture/airfield/terminal/int_windowframes_cafe.cgf",
						"objects/library/architecture/airfield/terminal/int_windowframes_depstairs.cgf",
						"objects/library/architecture/airfield/terminal/int_windowframes_entrance.cgf",
						"objects/library/architecture/airfield/terminal/int_windowframes_helpdesk.cgf",
						"objects/library/architecture/airfield/terminal/int_windowframes_walkway2.cgf",
					}
					} },{
					{ Name = "Prefab: Control Room", 	Files = {
						"objects/library/architecture/airfield/powerbuilding/powerbuilding.cgf",
						"objects/library/architecture/airfield/powerbuilding/powerbuilding_interior.cgf",
					} },
					{ Name = "Prefab: Control Center", 	Files = {
						"objects/library/architecture/harbour/control_center/harbor_control_center.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_arch.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_arch01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_arch02.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_big_room.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_big_room_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_big_room_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_decals.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_drawing.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_frame01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_frame02.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_frame03.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_fun.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_garret.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_garret_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_garret_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_a.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_b.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_c.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_d.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_glass_roof_long_e.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall01_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall01_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall02.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall02_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_hall_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_interior.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_interior_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_interior_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_kitchen01_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room01_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room01_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room02.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room02_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_room02_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_seats.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_stairs.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_storage01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet01_detail_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet02_detail_lamp.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet03.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet03_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet04.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet04_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet05.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet05_detail.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet06.cgf",
						"objects/library/architecture/harbour/control_center/harbor_control_center_toilet06_detail.cgf",
					} },
				}
			}
		}

		local iPrefab, iCategory = string.match(sModel, "^PREFAB:(%d+),(%d+)$")
		if (iCategory and iPrefab) then
			iPrefab = tonumber(iPrefab)
			iCategory = tonumber(iCategory)
			local aCategory = aList[iCategory]
			if (not aCategory) then
				return
			end
			if (not aCategory.Models) then
				return
			end
			local aModels = aCategory.Models[iPrefab]
			if (not aModels) then
				return
			end
			local aFiles = aModels.Files
			if (not aFiles) then
				return
			end

			for i, sFile in pairs(aFiles) do
				local hPrefab = SpawnGUINew({
					Model = (sFile or "Objects/library/storage/civil/civil_box_b_mp.cgf"),
					Pos = vPos,
					vDir = vDir,
					Mass = -1,
					Static = 1,
					Dir = vDir
				})
				hPrefab:SetDirectionVector(vDir)
				hPrefab:SetPos(vPos)
			end

			return
		end

		local hObj = SpawnGUINew({
			Model = (sModel or "Objects/library/storage/civil/civil_box_b_mp.cgf"),
			Pos = vPos,
			vDir = vDir,
			Mass = -1,
			Static = 1,
			Dir = vDir
		})
		hObj:SetDirectionVector(vDir)
		hObj:SetPos(vPos)

	end
})

------------------------------------------------------------
-- !lowspec, Enables super low graphic settings on your Client
------------------------------------------------------------

NewCommand({
	Name 	= "lowspec",
	Access	= GUEST,
	Description = "Enables super low graphic settings on your Client",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 30,
		RequireRCA = true
	};
	func = function(self, player, Timer)
	
		player.LOW_SPEC = not player.LOW_SPEC;
		SendMsg(CHAT_ATOM, player, "(LOWSPEC: " .. (player.LOW_SPEC and "Activated" or "Disabled") .. ")");
		
		ExecuteOnPlayer(player, "ATOMClient:HandleEvent(eCE_ToggleLowSpec, " .. tostring(player.LOW_SPEC) .. ");");
		
		return true;
	end;
});

------------------------------------------------------------
-- !reconnect <Timer>, Reconnects you to the Server
------------------------------------------------------------

NewCommand({
	Name 	= "reconnect",
	Access	= GUEST,
	Description = "Reconnects you to the Server",
	Console = true,
	Args = {
		{ "Timer", "The delay until you wish to be reconnected", Optional = true, Integer = true, PositiveNumber = true, Range = { 1, 60 } };
	};
	Properties = {
		Self = 'RCA',
		Timer = 30,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local timer;
		if (Timer) then
			timer = math.min(Timer, 60);
		else
			timer = 0;
		end;
		if (not player.RLG_Timer) then
			player.Reconnecting = true;
			player.RLG_Timer = timer;
			Script.SetTimer(timer * 1000, function()
				if (player and System.GetEntity(player.id)) then
					ExecuteOnPlayer(player, [[
						Script.SetTimer(100, function()
							System.ExecuteCommand('connect');
						end);
					]]);
				end;
			end);
		else
			return false, "Reconnting already initialized, " .. player.RLG_Timer .. "s";
		end;
		return true;
	end;
});



------------------------------------------------------------------------
--!dts, Reports data to Server


NewCommand({
	Name 	= "dts",
	Access	= GUEST,
	Description = "Reports data to Server",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 0,
		RequireRCA = true,
		Hidden = true,
		NoChatLog = true,
	};
	func = function(self, player, A, B, C)
		if (A and B and C) then
			self:OnModifiedData(player, A, B, C);
		end;
		return;
	end;
});

------------------------------------------------------------------------
--!ncr, Reports data to Server


NewCommand({
	Name 	= "ncr",
	Access	= GUEST,
	Description = "Reports data to Server",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 0,
		RequireRCA = true,
		Hidden = true,
		NoChatLog = true,
	};
	func = function(self, player, A, B, C)
		if (A and B and C) then
			self:OnWeaponData(player, A, B, C);
		end;
		return;
	end;
});

------------------------------------------------------------------------
--!flip, Flips a flipped vehicle 


NewCommand({
	Name 	= "flip",
	Access	= GUEST,
	Description = "Flips your vehicle if flipped",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 0,
		RequireRCA = true,
		Hidden = false,
		OnlyAsDriver = true,
		RequireVehicle = true,
	};
	func = function(self, player, vehicle)
		if (not vehicle.vehicle:IsFlipped()) then
			return false, "Vehicle is not flipped";
		end;
		ExecuteOnPlayer(player, [[local v=GetEnt(']]..vehicle:GetName()..[[');if (v) then v:AddImpulse(-1, v.vehicle:MultiplyWithWorldTM(v:GetVehicleHelperPos("Engine")) or v:GetCenterOfMassPos(), g_Vectors.up, v:GetMass()*10, 1);end;]]);
		return;
	end;
});

------------------------------------------------------------
-- !smoke


NewCommand({
	Name 	= "smoke",
	Access	= GUEST,
	Description = "Take a smoke",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 30,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				if (p.id==g_localActor.id) then
					g_gameRules.game:FreezeInput(true);
				end
				p:StartAnimation(0,"relaxed_idleSmokeLight_lighter_01");
				Script.SetTimer(11667, function()
					p:StartAnimation(0,"relaxed_idleSmokeDrag_cigarette_0]] .. math.random(1,2) .. [[");
					Script.SetTimer(10000, function()
						if (p.id==g_localActor.id) then
							g_gameRules.game:FreezeInput(false);
						end;
					end);
				end);
			end;
		]];
		SendMsg(CHAT_ATOM, ALL, "%s Is having a Smoke", player:GetName());
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !scratch


NewCommand({
	Name 	= "scratch",
	Access	= GUEST,
	Description = "Scratch your Butt",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 15,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				p:StartAnimation(0,"relaxed_idleScratchbutt_01");
			end;
		]];
		SendMsg(CHAT_ATOM, GetPlayersInRange(player:GetPos(), 30), "%s Is scratching their Gluteus Maximus", player:GetName());
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !piss


NewCommand({
	Name 	= "piss",
	Access	= GUEST,
	Description = "Reliefs you from heavy duty",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 15,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				p:StartAnimation(0,"relaxed_relief_nw_01");
			end;
		]];
		SendMsg(CHAT_ATOM, ALL, "%s Is taking a Piss", player:GetName());
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !wave


NewCommand({
	Name 	= "wave",
	Access	= GUEST,
	Description = "Wave",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				p:StartAnimation(0,"]] .. GetRandom({ "stealth_signalFollowUB_pistol_01", "stealth_signalFollowUB_rifle_01", "combat_callReinforcements_nw_01", "combat_callReinforcements_nw_02" }) .. [[");
			end;
		]];
		SendMsg(CHAT_ATOM, player, "You're Waving");
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !wave

--[[
NewCommand({
	Name 	= "come",
	Access	= GUEST,
	Description = "Singnalize players to come to you",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = xx
			local p=GetEnt('xx..player:GetName()..xx');
			if (p) then
				p:StartAnimation(0,"xx .. GetRandom({  }) .. xx");
			end;
		xx;
		--SendMsg(CHAT_ATOM, player:GetTeam(), "%s : Needs Help", player:GetName());
		ExecuteOnAll(x);
		return true;
	end;
});
--]]

------------------------------------------------------------
-- !yoga


NewCommand({
	Name 	= "yoga",
	Access	= GUEST,
	Description = "Do some yoga",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 15,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local yogaPoses = {
			"usCarrier_flightCDuckSignal_nw_01",
			"usCarrier_flightCDuck_nw_01",
			"usCarrier_flightSignal_nw_01",
			"usCarrier_flightSignal_nw_02",
			"usCarrier_flightSignal_nw_03",
			"usCarrier_flightSignal_nw_04",
			"usCarrier_flightSignal_nw_05",
			"usCarrier_flightSignal_nw_06",
			"usCarrier_flightSignal_nw_07",
			"usCarrier_flightSignal_nw_10",
			"usCarrier_flightSignal_nw_12",
			"usCarrier_flightSignal_nw_13",
			"usCarrier_flightSignal_nw_14",
			"usCarrier_brownCableRepair_bigWrench_01"
		};
		
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				FI(p,1);
				local a="]]..GetRandom(yogaPoses)..[[";
				p:StopAnimation(0,-1)
				p:StartAnimation(0,a);
				local time=p:GetAnimationLength(0,a);
				Script.SetTimer(time*1000, function()
					FI(p);
				end);
			end;
		]];
		
		player.yoagTime = _time;
		
		SendMsg(CHAT_ATOM, ALL, "%s Is Doing some serious Yoga!", player:GetName());
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !science


NewCommand({
	Name 	= "science",
	Access	= GUEST,
	Description = "Do some serious science",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 15,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		if (not player.DoingScience) then
			local yogaPoses = {
				"usCarrier_flightCDuckSignal_nw_01",
				"usCarrier_flightCDuck_nw_01",
				"usCarrier_flightSignal_nw_01",
				"usCarrier_flightSignal_nw_02",
				"usCarrier_flightSignal_nw_03",
				"usCarrier_flightSignal_nw_04",
				"usCarrier_flightSignal_nw_05",
				"usCarrier_flightSignal_nw_06",
				"usCarrier_flightSignal_nw_07",
				"usCarrier_flightSignal_nw_10",
				"usCarrier_flightSignal_nw_12",
				"usCarrier_flightSignal_nw_13",
				"usCarrier_flightSignal_nw_14",
				"usCarrier_brownCableRepair_bigWrench_01"
			};
			
			local p, d = player:CalcSpawnPos(0);
			local pos = g_utils:GetAdjustedPosition(p, nil, player.id)
			
			local x = [[
				local s={
					"relaxed_researchIdleBreak_microscope_01","relaxed_researchIdleBreak_microscope_02","relaxed_researchIdleBreak_microscope_03","relaxed_researchIdleBreak_bio_01","relaxed_researchIdleBreak_bio_02","relaxed_researchIdleBreak_bio_03","relaxed_researchIdle_microscope_01","relaxed_researchIdle_bio_01"
				};
				local p=GetEnt(']]..player:GetName()..[[');
				if (p) then
					FI(p,1);
					STICKY_POSITIONS[p.id] = { ]] .. arr2str_(player:GetPos()) .. [[, 0, 0, 1 };
					LOOPED_ANIMS[p.id]={Start = _time,Entity = p,Loop = -1,Timer= 0,Speed = 1,Anim = s};
				end;
			]];
			
			local pos_table = add2Vec(pos, makeVec(-0.6396,0.94,0))
			local pos_shit1 = add2Vec(pos, makeVec(-1.2617,1.1066,0.8748))
			local pos_shit2 = add2Vec(pos, makeVec(-0.639,0.8475,0.8748))
			local pos_shit3 = add2Vec(pos, makeVec(-0.019,0.6755,1.12))
			
			local dir = player:GetDirectionVector();
			
			local dir_shit1 = add2Vec(makeVec(), makeVec(0.391, -0.921, 0.000));
			local dir_shit2 = add2Vec(makeVec(), makeVec(1, -0.017, 0.000));
			local dir_shit3 = add2Vec(makeVec(), makeVec(-1, -0.017, 0.000));
			
			player.ScienceShit = {
				SpawnGUINew({Model="objects/library/architecture/aircraftcarrier/props/furniture/tables/navtable_200x125y.cgf", Pos=pos_table, Mass=-1, Dir=player:GetDirectionVector()}),
				SpawnGUINew({Model="Objects/library/props/scientific/oscilloscope.cgf", Pos=pos_shit1, Mass=-1, Dir=dir_shit1}),
				SpawnGUINew({Model="Objects/library/props/scientific/microscope_large.cgf", Pos=pos_shit2, Mass=-1, Dir=dir_shit2}),
				SpawnGUINew({Model="objects/library/props/scientific/microscope.cgf", Pos=pos_shit3, Mass=-1, Dir=dir_shit3}),
				
			};
			
			if (player.ScienceSyncID) then
				RCA:StopSync(player, player.ScienceSyncID);
			end;
			player.ScienceSyncID = RCA:SetSync(player, {client=x,link=true});
			
			player.DoingScience = true;
			player.StopIdleAnim = true;
		
			SendMsg(CHAT_ATOM, ALL, "%s Is Doing some Science!", player:GetName());
			ExecuteOnAll(x);
		else
			SendMsg(CHAT_ATOM, ALL, "%s Stopped their Science course", player:GetName());
			ExecuteOnAll([[
				local p=GP(]]..player:GetChannel()..[[);
				STICKY_POSITIONS[p.id] = nil;
				LOOPED_ANIMS[p.id]=nil;
				FI(p)
			]]);
			player.StopIdleAnim = false;
			player.DoingScience = false;
			RCA:StopSync(player, player.ScienceSyncID);
			player.ScienceSyncID = nil;
			if (player.ScienceShit) then
				for i, v in pairs(player.ScienceShit) do
					System.RemoveEntity(v.id);
				end;
				player.ScienceShit = nil;
			end;
		end;
		return true;
	end;
});

------------------------------------------------------------
-- !piss


NewCommand({
	Name 	= "nice",
	Access	= GUEST,
	Description = "Nice one",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'RCA',
		Timer = 15,
		RequireRCA = true
	};
	func = function(self, player, Timer)
		local x = [[
			local p=GetEnt(']]..player:GetName()..[[');
			if (p) then
				if (p.id==g_localActor.id) then
					g_gameRules.game:FreezeInput(true);
				end
				p:StartAnimation(0,"usCarrier_flightSignal_nw_06");
				Script.SetTimer(5866.67, function()
					if (p.id==g_localActor.id) then
						g_gameRules.game:FreezeInput(false);
					end;
				end);
			end;
		]];
		SendMsg(CENTER, player, "!! NICE !!");
		ExecuteOnAll(x);
		return true;
	end;
});

------------------------------------------------------------
-- !gore


NewCommand({
	Name 	= "gore",
	Access	= GUEST,
	Description = "Enables more ... gore ...",
	Console = true,
	Args = {
	--	{ "Timer", "The Maximum time to Calculate the FPS", Optional = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
	};
	func = function(self)
		local x = [[
			if (ATOMCLIENT_GORE ~= true) then
				ATOMCLIENT_GORE = true
			else
				ATOMCLIENT_GORE = false
			end
		]]
		ExecuteOnPlayer(self, x)

		if (not self.ATOMCLIENT_GORE) then
			self.ATOMCLIENT_GORE = true
		else
			self.ATOMCLIENT_GORE = false
		end

		SendMsg(CHAT_ATOM, self, "(More Blood: %s)", string.bool(self.ATOMCLIENT_GORE, 2))
		return true
	end;
});



------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "nomad",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)

		if (player.bPrefersNomad ~= true) then
			player.bPrefersNomad = true
		else
			player.bPrefersNomad = false end

		SendMsg(CHAT_ATOM, player, "(Nomad: Character %s)", string.bool(player.bPrefersNomad, BTOSTRING_TOGGLED))
		return self:RequestModel(player, 0, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "human",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		if (hPlayer.iCurrentHead) then
			return self:RequestHead(hPlayer, 0, nil, nil, true)
		end
		return self:RequestCharacter(hPlayer, 0, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "chicken",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 4, nil, nil, true)
	end;
});


------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "frog",
	Access	= PREMIUM,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 9, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "turtle",
	Access	= PREMIUM,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 5, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "crab",
	Access	= PREMIUM,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 6, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "trooper",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 1, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!nomad


NewCommand({
	Name 	= "shark",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, hPlayer)
		return self:RequestCharacter(hPlayer, 3, nil, nil, true)
	end;
});


------------------------------------------------------------------------
--!kyong, changes ur fukin model


NewCommand({
	Name 	= "kyong",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 1, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!korean, changes ur fukin model


NewCommand({
	Name 	= "korean",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 2, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!aztec, changes ur fukin model


NewCommand({
	Name 	= "aztec",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 3, nil, nil, true)
	end;
});

------------------------------------------------------------------------
--!jester, changes ur fukin model


NewCommand({
	Name 	= "jester",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 4, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!sykes, changes ur fukin model


NewCommand({
	Name 	= "sykes",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 5, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!prophet, changes ur fukin model


NewCommand({
	Name 	= "prophet",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 6, nil, nil, true);
	end;
});

------------------------------------------------------------------------
--!psycho, changes ur fukin model


NewCommand({
	Name 	= "psycho",
	Access	= GUEST,
	Description = "Changes your appearance",
	Console = true,
	Args = {
	};
	Properties = {
		Self = 'RCA',
		Timer = 10,
		RequireRCA = true,
	};
	func = function(self, player)
		return self:RequestModel(player, 7, nil, nil, true);
	end;
});
