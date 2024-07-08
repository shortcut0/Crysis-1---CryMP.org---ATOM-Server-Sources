ATOMBuying = {
	cfg = {
		Buying = {
			-- The maximum amount of kits the player can buy
			KitLimit = 3,
			
			-- List of items the player cannot buy
			ForbiddenItems = {
				["GaussRifle"] = false,
				["Frag"] = false,
			},
		};
	},
	-----------------------
	Init = function(self)
		if (g_gameRules.class == "PowerStruggle") then
			self:PatchBuyList();
		end;
	end,
	-----------------------
	PatchBuyList = function(self)
		g_gameRules.weaponList = {
			{ id = "flashbang", 		name = "@mp_eFlashbang", 	category = "@mp_catExplosives", price = 10, 	loadout = 1, class = "FlashbangGrenade", 	amount = 1, weapon = false, ammo = true};
			{ id = "smokegrenade", 		name = "@mp_eSmokeGrenade", category = "@mp_catExplosives", price = 10, 	loadout = 1, class = "SmokeGrenade", 		amount = 1, weapon = false, ammo = true};
			{ id = "explosivegrenade", 	name = "@mp_eFragGrenade", 	category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "FragGrenade", 		amount = 1, weapon = false, ammo = true};
			{ id = "empgrenade", 		name = "@mp_eEMPGrenade", 	category = "@mp_catExplosives", price = 50, 	loadout = 1, class = "EMPGrenade", 			amount = 1, weapon = false, ammo = true};
			{ id = "claymore", 			name = "@mp_eClaymore", 	category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "Claymore", 	buyammo = "claymoreexplosive",	selectOnBuyAmmo = true};
			{ id = "avmine", 			name = "@mp_eMine", 		category = "@mp_catExplosives", price = 25, 	loadout = 1, class = "AVMine", 		buyammo = "avexplosive",		selectOnBuyAmmo = true};
			{ id = "c4", 				name = "@mp_eExplosive", 	category = "@mp_catExplosives", price = 50, 	loadout = 1, class = "C4", 			buyammo = "c4explosive",		selectOnBuyAmmo = true};
			
			{ id = "rpg", 				name = "@mp_eML", 			category = "@mp_catExplosives", price = 250, 	loadout = 1, class = "LAW", 		uniqueId = 8};
			{ id = "rpgheat",			name = "H1 RPG",			category = "@mp_catExplosives", price = 500, 	loadout = 1, class = "LAW", 		uniqueId = 600, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "rpg" }}};
			{ id = "rpgexocet",			name = "Exocet Launcher",	category = "@mp_catExplosives", price = 400, 	loadout = 1, class = "LAW", 		uniqueId = 601, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "exocet" }}};
			{ id = "rpgquad",			name = "M202 Flash",		category = "@mp_catExplosives", price = 800, 	loadout = 1, class = "LAW", 		uniqueId = 602, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "quadrpg" }}};
			
			{ id = "fgl40",				name = "FGL-40",			category = "@mp_catExplosives", price = 100, 	loadout = 1, class = "TACGun", 		uniqueId = 603, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl40" }}};
			{ id = "fgl40b",			name = "FGL-40B",			category = "@mp_catExplosives", price = 250, 	loadout = 1, class = "TACGun", 		uniqueId = 604, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl40b" }}};
			{ id = "fgl50",				name = "FGL-50",			category = "@mp_catExplosives", price = 300, 	loadout = 1, class = "TACGun", 		uniqueId = 605, ItemProperties = { Call = function(item)item.weapon:AutoRemoveProjectiles(true)end, Tags = { ["SpecialGun"] = "fgl50" }}};
			
			
			{ id = "pistol", 			name = "@mp_ePistol", 		category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "SOCOM", 		uniqueloadoutgroup = 3, uniqueloadoutcount = 2};
			{ id = "golf", 				name = "Golfclub", 			category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "Golfclub", 		uniqueloadoutgroup = 3, uniqueloadoutcount = 2,
			ItemProperties = {
				Call = function(item, player)
					Script.SetTimer(1000, function()
						if (not item or not GetEnt(item.id)) then 
							return; 
						end;
						local code = [[
						local shit=GetEnt("]]..item:GetName()..[[")
						if (shit) then
							shit.CM="Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf";
							shit.CMNGL=true;
							shit.RCMIFP=true;
						end;
						]];
						--ExecuteOnAll(code);
						--item.syncID = RCA:SetSync(item, {client=code,link=item.id});
					end);
				end,
			}
			
			};
			{ id = "shotgun", 			name = "@mp_eShotgun", 		category = "@mp_catWeapons", 	price = 50, 	loadout = 1, class = "Shotgun", 	uniqueId = 4, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			{ id = "semishotgun", 		name = "Semi-Auto Shotgun", 		category = "@mp_catWeapons", 	price = 150, 	loadout = 1, class = "Shotgun", 	uniqueId = 623, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2,
				ItemProperties = {
					Call = function(item, player)
						item.RapidFire = {
							Last = _time;
							Delay = 0.3
						};
						--Debug("raff raff")
					end
				};
			};
			{ id = "smg", 				name = "@mp_eSMG", 			category = "@mp_catWeapons", 	price = 75, 	loadout = 1, class = "SMG", 		uniqueId = 5, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			{ id = "fy71", 				name = "@mp_eFY71", 		category = "@mp_catWeapons", 	price = 125, 	loadout = 1, class = "FY71", 		uniqueId = 6, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			{ id = "macs", 				name = "@mp_eSCAR", 		category = "@mp_catWeapons", 	price = 150, 	loadout = 1, class = "SCAR", 		uniqueId = 7, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			{ id = "dsg1", 				name = "@mp_eSniper", 		category = "@mp_catWeapons", 	price = 300, 	loadout = 1, class = "DSG1", 		uniqueId = 9, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			{ id = "gauss", 			name = "@mp_eGauss", 		category = "@mp_catWeapons", 	price = 750, 	loadout = 1, class = "GaussRifle", 	uniqueId = 10, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2};
			--{ id = "flamethrower",		name = "Flamethrower", 		category = "@mp_catWeapons", 	price = 500, 	loadout = 1, class = "AlienMount", 	uniqueId = 619, 			uniqueloadoutgroup = 1, uniqueloadoutcount =2, ItemProperties={
			--Tags = { ["isFlamethrower"] = true }, Call = function(item, player) item.weapon:DisableShooting(true)end,
			--
			--}};
			
			{ id = "shiten",			name = "ShiTen", 			category = "@mp_catWeapons", 	price = 350, 	loadout = 1, class = "ShiTen", 		uniqueId = 620, 		uniqueloadoutgroup = 1, uniqueloadoutcount =2,
			ItemProperties = { CallBefore = function()
				_G["ShiTen"].Properties.bSelectable = 1
				_G["ShiTen"].Properties.bPickable = 1
				_G["ShiTen"].Properties.bMounted = 0
				_G["ShiTen"].Properties.bMountable = 1
				_G["ShiTen"].Properties.bSelectable = 1
				_G["ShiTen"].Properties.bDroppable = 1
				_G["ShiTen"].Properties.bGiveable = 1
				_G["ShiTen"].Properties.bRaisable = 1
			end,
			Call = function(shit, player)
				shit.Properties.bSelectable = 1
				shit.Properties.bPickable = 1
				shit.Properties.bGiveable = 1
				shit.Properties.bRaisable = 1
				shit.Properties.bSelectable = 1
				shit.Properties.bDroppable = 1
				shit.Properties.bMounted = 0
				shit.Properties.bMountable = 1
				Script.SetTimer(1000, function()
					if (not shit or not GetEnt(shit.id)) then 
						return; 
					end;
					local code = [[
					local shit=GetEnt("]]..shit:GetName()..[[")
					if (shit) then
						shit.CM="Objects/weapons/asian/shi_ten/shi_ten_mounted_fp.chr";
						shit.CMNGL=true;
						shit.RCMIFP=true;
					end;
					]];
					ExecuteOnAll(code);
					shit.syncID = RCA:SetSync(shit, {client=code,link=shit.id});
				end);
			end,
			}};
			{ id = "aliengun",			name = "Alien Gun", 			category = "@mp_catWeapons", 	price = 350, 	loadout = 1, class = "SMG", 		uniqueId = 621, 		uniqueloadoutgroup = 1, uniqueloadoutcount =2,
			ItemProperties = {
			Call = function(shit, player)
				shit.AlienGun = true;
				Script.SetTimer(1000, function()
					local code = [[
						local g=GetEnt("]]..shit:GetName()..[[")
						g.CM="Objects/weapons/alien/alien_weapon/alien_weapon.cgf"
						g.CMFP="Objects/weapons/alien/alien_weapon/alien_weapon.cgf"
						g.CMDir={x=-1.15,y=-0.1,z=1.56}
						g.CMPosLocal={x=0.15,y=0.4,z=-0.25}
						g_localActor.ICML=nil
						g.FireSound="sounds/weapons:moar_warrior:fire"
						g.FireSoundVol=2;
						g.FireSoundVolNGL=1;
					]]
					ExecuteOnAll(code);
					shit.syncID = RCA:SetSync(shit, {client=code,link=shit.id});
				end);
				shit.weapon:AttachAccessory("Silencer",true,true);
				--shit.weapon:DisableAccessoryAttaching(true);
			end,
			}};
		};
		g_gameRules.ammoList={
			{ id = "", 							 name = "@mp_eAutoBuy", 			category = "@mp_catAmmo", 	price = 0, 		loadout = 1};
			{ id = "lightbullet", 				 name = "@mp_eLightBullet", 		category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 40};
			{ id = "shotgunshell", 				 name = "@mp_eShotgunShell", 		category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 8};
			{ id = "smgbullet", 				 name = "@mp_eSMGBullet", 			category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 50};
			{ id = "fybullet", 					 name = "@mp_eFYBullet", 			category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 30};
			{ id = "bullet", 					 name = "@mp_eBullet", 				category = "@mp_catAmmo", 	price = 5, 		loadout = 1, amount = 40};
			{ id = "rocket", 					 name = "@mp_eRocket", 				category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 1};
			{ id = "scargrenade", 				 name = "@mp_eRifleGrenade", 		category = "@mp_catAmmo", 	price = 20, 	loadout = 1, amount = 1};
			{ id = "sniperbullet", 				 name = "@mp_eSniperBullet", 		category = "@mp_catAmmo", 	price = 10, 	loadout = 1, amount = 10};
			{ id = "gaussbullet", 				 name = "@mp_eGaussSlug", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 1, amount = 5};
			{ id = "hurricanebullet", 			 name = "@mp_eMinigunBullet", 		category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 500};
			{ id = "dumbaamissile", 			 name = "@mp_eAAAMissile", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 0, amount = 4};
			{ id = "tankaa", 					 name = "@mp_eAAACannon", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 250};
			{ id = "towmissilename = ", 		 name = "@mp_eAPCMissile", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 0, amount = 2};
			{ id = "tank30", 			 		 name = "@mp_eAPCCannon", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 100};
			{ id = "tank125", 					 name = "@mp_eTankShells", 			category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 10};
			{ id = "gausstankbullet",			 name = "@mp_eGaussTankSlug", 		category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 10};
			{ id = "Tank_singularityprojectile", name = "@mp_eSingularityShell", 	category = "@mp_catAmmo", 	price = 200, 	loadout = 0, amount = 1};
			{ id = "helicoptermissile", 		 name = "@mp_eHelicopterMissile", 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 7};
			{ id = "a2ahomingmissile", 		 	 name = "@mp_eVTOLMissile",		 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 12};
			{ id = "vtol20",					 name = "Ascension Missile",	 	category = "@mp_catAmmo", 	price = 100, 	loadout = 0, amount = 100};
			
			{ id = "tacprojectile",				 name = "@mp_eTACTankShell", 		category = "@mp_catAmmo", 	price = 200, 	loadout = 0, amount = 1,	level = 100,};
			{ id = "tacgunprojectile", 			 name = "@mp_eTACGrenade", 			category = "@mp_catAmmo", 	price = 200, 	loadout = 1, amount = 1, 	level = 100,};
			
			{ id = "claymoreexplosive", 		 name = "Claymore Supply", 			category = "@mp_catAmmo", 	price = 25, 	loadout = 1, amount = 1, 	invisible = true};
			{ id = "avexplosive", 				 name = "Mine Supply", 				category = "@mp_catAmmo", 	price = 25, 	loadout = 1, amount = 1, 	invisible = true};
			{ id = "c4explosive", 				 name = "Explosive Supply", 		category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 1, 	invisible = true};
			{ id = "incendiarybullet", 			 name = "Incendiary Ammo", 			category = "@mp_catAmmo", 	price = 50, 	loadout = 1, amount = 30, 	invisible = true};
			
			
			{ id = "iamag",						 name = "@mp_eIncendiaryBullet", 	category = "@mp_catAddons", price = 50, 	loadout = 1, class = "FY71IncendiaryAmmo", 				ammo = false, equip = true, buyammo = "incendiarybullet", };
			{ id = "psilent",					 name = "@mp_ePSilencer", 			category = "@mp_catAddons", price = 10, 	loadout = 1, class = "SOCOMSilencer", 	uniqueId = 121, ammo = false, equip = true};
			{ id = "plam",						 name = "@mp_ePLAM", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "LAM", 			uniqueId = 122, ammo = false, equip = true};
			{ id = "silent",					 name = "@mp_eRSilencer", 			category = "@mp_catAddons", price = 10, 	loadout = 1, class = "Silencer", 		uniqueId = 123, ammo = false, equip = true};
			{ id = "lam",						 name = "@mp_eRLAM", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "LAMRifle", 		uniqueId = 124, ammo = false, equip = true};
			{ id = "reflex",					 name = "@mp_eReflex", 				category = "@mp_catAddons", price = 25, 	loadout = 1, class = "Reflex", 			uniqueId = 125, ammo = false, equip = true};
			{ id = "ascope",					 name = "@mp_eAScope", 				category = "@mp_catAddons", price = 50, 	loadout = 1, class = "AssaultScope", 	uniqueId = 126, ammo = false, equip = true};
			{ id = "scope",						 name = "@mp_eSScope", 				category = "@mp_catAddons", price = 100, 	loadout = 1, class = "SniperScope", 	uniqueId = 127, ammo = false, equip = true};
			{ id = "gl",						 name = "@mp_eGL", 					category = "@mp_catAddons", price = 100, 	loadout = 1, class = "GrenadeLauncher", uniqueId = 128, ammo = false, equip = true};
		};
		g_gameRules.equipList={
			{ id = "binocs", 		name = "@mp_eBinoculars", 	category = "@mp_catEquipment", price = 50, loadout = 1, class = "Binoculars", 	uniqueId = 101};
			{ id = "nsivion", 		name = "@mp_eNightvision", 	category = "@mp_catEquipment", price = 10, loadout = 1, class = "NightVision", 	uniqueId = 102};
			{ id = "pchute", 		name = "@mp_eParachute", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "Parachute", 	uniqueId = 103};
			{ id = "lockkit", 		name = "@mp_eLockpick", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "LockpickKit", 	uniqueId = 110, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
			{ id = "repairkit", 	name = "@mp_eRepair", 		category = "@mp_catEquipment", price = 50, loadout = 1, class = "RepairKit", 	uniqueId = 111, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
			{ id = "radarkit", 		name = "@mp_eRadar", 		category = "@mp_catEquipment", price = 50, loadout = 1, class = "RadarKit", 	uniqueId = 112, uniqueloadoutgroup = 2, uniqueloadoutcount = 2};
			{ id = "glassnades", 	name = "Glass Grenades", 	category = "@mp_catEquipment", price = 200, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 606, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "GLASS GRENADES :: ENABLED")
					SendMsg(CHAT_BUYING, player, "(Glass-Grenades Purchased: Your Grenades will now instantly explode on-impact)")
				end;
			Unique = "GLASSNADE", Unlimited = true, DontGive = true }, PlayerProperties = { Call = nil, Tags = { ["GlassGrenades"] = true }} };
			
			{ id = "helmet_china", 	name = "China Helmet", 		category = "@mp_catEquipment", price = 5, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 613, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "HELMET :: EQUIPPED")
					SendMsg(CHAT_BUYING, player, "(Helmet Purchased: You will now be immune to a Limited number of Headshots)")
					player.HelmetShots = 5;
					local h = SpawnGUI("Objects/characters/attachment/asian/helmets/china_helmet.cgf", player:GetPos());
					player.helmetID = h.id;
					
					Helmet_Attach(player, h, 0.2, 0, 0);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", 0.23, -0.03, 0);
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id });
					end);
				end;
				Unique = "HELMET", 
				UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "helmet_b", 		name = "Bush Helmet", 		category = "@mp_catEquipment", price = 8, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 614, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "HELMET :: EQUIPPED")
					SendMsg(CHAT_BUYING, player, "(Helmet Purchased: You will now be immune to a Limited number of Headshots)")
					player.HelmetShots = 5
					local h = SpawnGUI("objects/characters/attachment/asian/helmets/asian_helmet_veg_0" .. GetRandom(3) .. ".cgf", player:GetPos());
					player.helmetID = h.id;
					
					Helmet_Attach(player, h, 0.2, 0, 0);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", 0.2, -0.03, 0);
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id });
					end);
				end;
				Unique = "HELMET", 
				UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "helmet_l", 		name = "Light Helmet", 		category = "@mp_catEquipment", price = 10, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 610, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "HELMET :: EQUIPPED")
					SendMsg(CHAT_BUYING, player, "(Helmet Purchased: You will now be immune to a Limited number of Headshots)")
					player.HelmetShots = 10;
					local h = SpawnGUI("objects/characters/attachment/asian/helmets/asian_helmet_0" .. GetRandom(4) .. ".cgf", player:GetPos());
					player.helmetID = h.id;
					
					Helmet_Attach(player, h, 0.2, 0, 0);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", 0.2, 0, 0);
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id });
					end);
				end;
				Unique = "HELMET", 
				UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "helmet_m", 		name = "Medium Helmet", 		category = "@mp_catEquipment", price = 25, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 612, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "HELMET :: EQUIPPED")
					SendMsg(CHAT_BUYING, player, "(Helmet Purchased: You will now be immune to a Limited number of Headshots)")
					player.HelmetShots = 15;
					local h = SpawnGUI("objects/characters/attachment/squad/base_helmets/squad_helmet_engineer.cgf", player:GetPos());
					player.helmetID = h.id;
					
					Helmet_Attach(player, h, 0.1, 0, 0);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", 0.1, 0, 0);
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id });
					end);
				end;
				Unique = "HELMET", 
				UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "helmet_h", 		name = "Heavy Helmet", 		category = "@mp_catEquipment", price = 25, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 611, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "HELMET :: EQUIPPED");
					player.HelmetShots = 20;
					local h = SpawnGUI("objects/characters/attachment/squad/base_helmets/squad_helmet_engineer.cgf", player:GetPos());
					player.helmetID = h.id;
					
					Helmet_Attach(player, h, 0.1, 0, 0);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", 0.1, 0, 0);
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id });
					end);
					
					SendMsg(CHAT_BUYING, player, "(Helmet Purchased: You will now be immune to a Limited number of Headshots)")
				end;
				Unique = "HELMET", 
				UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "ammobag", 		name = "Ammo Bag", 		category = "@mp_catEquipment", price = 300, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 616, ItemProperties = { 
				Call = function(item, player)
					SendMsg(CENTER, player, "AMMOBAG :: EQUIPPED");
					player.HelmetShots = 8;
					local h = SpawnGUI("objects/characters/attachment/asian/backpack_standard.cgf", player:GetPos());
					player.AmmoBag = h.id;
					
					Helmet_Attach(player, h, -0.02, 0.05, 0.1, "weaponPos_rifle01", true);
					
					Script.SetTimer(10, function()
						local c = [[
							Helmet_Attach(]] .. player:GetChannel() .. [[, "]] .. h:GetName() .. [[", -0.02, 0.05, 0.1, "weaponPos_rifle01", true);
						
						]];
						ExecuteOnAll(c);
						h.helmetSyncID = RCA:SetSync(h, { client = c, link = h.id })
						
						player.aCustomCapacity = {
							{ "bullet",				400,  1 },
							{ "fybullet",			400,  2 },
							{ "lightbullet",		400,  3 },
							{ "smgbullet",			400,  4 }
						}
						ATOM:ChangeCapacity(player, player.aCustomCapacity)
					end)
					
					SendMsg(CHAT_BUYING, player, "(Ammo-Bag Purchased: you can now Carry more Rifle Ammunition)")
					
				end;
				Unique = "AMMOBAG", 
				--UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Call = function(player)end, Tags = { }} };
			{ id = "doublenades", 		name = "Double GL", 		category = "@mp_catEquipment", price = 300, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 617, ItemProperties = { 
				
				Call = function(item, player)
					SendMsg(CENTER, player, "DOUBLE GL :: EQUIPPED")
					SendMsg(CHAT_BUYING, player, "(Double GrenadeLauncher Purchased: your GL will now load two Rounds)")
				end,
				
				Unique = "DOUBLENADES", 
				--UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Tags = { ["HasDoubleGrenadeAttachment"] = true }} };
			{ id = "flyingchair", 		name = "Flying Chair", 		category = "@mp_catEquipment", price = 500, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 618, ItemProperties = { 
				BuyCooldown = 60,
				Call = function(item, player)
					SendMsg(CENTER, player, "FLYING CHAIR : SPAWNED");
					local seat = SpawnGUI("Objects/library/architecture/aircraftcarrier/props/furniture/chairs/console_chair.cgf", fixPos(player:CalcSpawnPos(1, -1)));
					seat.chair = true;
					player.keepChair = false;
					seat:Physicalize(0, PE_RIGID, {mass=100});
					seat:AwakePhysics(1);
					
					SendMsg(CHAT_BUYING, player, "(Flying-Char Purchased: When standing still, Press ( F ) to Mount/Dismount the Chair)")
					--g_gameRules.Server:RequestSpectatorTarget(player.id, eCR_ChairON);
					Script.SetTimer(500, function()
						local code = [[ATOMClient:ClientEvent(1, ']] .. seat:GetName() .. [[')]];
						seat.syncId1 = RCA:SetSync(seat, {linked=seat.id,client=code})
						ExecuteOnAll(code);
					end);
					REMOVE_OBJECTS[seat.id] = { _time, 60, "player", function() if (GetEnt(player.id)) then SendMsg(CENTER, player, "Flying Chair removed due to inactivity")g_gameRules:AwardPPCount(player.id,300)end end };
				end,
				
				--Unique = "DOUBLENADES", 
				--UniqueMsg = "a Helmet",
				Unlimited = true, 
				DontGive = true 
			}, PlayerProperties = { Tags = { ["keepChair"] = false }} };
			--{ id = "ammobag", 	name = "[WIP] Ammo Bag", 	category = "@mp_catEquipment", price = 25, loadout = 1, class = "Parachute", 	uniqueId = 103};
		};
		g_gameRules.vehicleList = {
				{ id = "speedboat", 		name = "Speed Boat", 			category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "Civ_speedboat", 		modification = "MP", 			buildtime = 10};
				{ id = "roofedboat", 		name = "Roofed Boat", 			category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "Civ_speedboat", 		modification = "Roofed", 		buildtime = 10};
				{ id = "usboat", 			name = "@mp_eSmallBoat", 		category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "US_smallboat", 		modification = "MP", 			buildtime = 10};
				{ id = "moacboat", 			name = "MOAC Boat", 			category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "US_smallboat", 		modification = "MOAC", 			buildtime = 15, level = 50};
				{ id = "moarboat", 			name = "MOAR Boat", 			category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "US_smallboat", 		modification = "MOAR", 			buildtime = 15, level = 50};
				{ id = "nkboat", 			name = "@mp_ePatrolBoat", 		category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Asian_patrolboat", 	modification = "MP", 			buildtime = 10};
				{ id = "nkgaussboat", 		name = "@mp_eGaussPatrolBoat", 	category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "Asian_patrolboat", 	modification = "Gauss", 		buildtime = 10};
				{ id = "spawnboat", 		name = "Spawn Boat", 			category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "Asian_patrolboat", 	modification = "MP", 			buildtime = 20, teamlimit = 2,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "trolley", 			name = "Trolley", 				category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "US_trolley", 			modification = "MP", 			buildtime = 10};
				{ id = "civcar", 			name = "Civil Car", 			category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "Civ_car1", 			modification = "MP", 			buildtime = 10};
				
				{ id = "dueler", 			name = "Mighty Dueler",			category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/mining_train/mining_locomotive.cgf", { x = 0, y = 0.0, z = 0.2 }, {x=0,y=0,z=-1.5727} }}};
				{ id = "tesla", 			name = "Tesla", 				category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/cars/car_b_chassi.cgf", { x = 0, y = 0.350, z = 0.30 }, {x=0,y=0,z=0} }}};
				{ id = "audir8", 			name = "Audi R8", 				category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "Civ_car1", 			modification = "", 				buildtime = 10, VehicleProperties = { ModelProperties = { "objects/library/vehicles/cars/car_a.cgf", { x = 0, y = 0.350, z = 0.50 }, {x=0,y=0,z=0}}}};
				
				{ id = "policecar", 		name = "Police Car", 			category = "@mp_catVehicles", price = 25, 	loadout = 0, class = "Civ_car1", 			modification = "PoliceCar", 	buildtime = 10};
				{ id = "light4wd", 			name = "@mp_eLightVehicle", 	category = "@mp_catVehicles", price = 0, 	loadout = 0, class = "US_ltv", 				modification = "Unarmed",		buildtime = 10};
				{ id = "us4wd", 			name = "@mp_eHeavyVehicle", 	category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "US_ltv", 				modification = "MP", 			buildtime = 10};
				{ id = "usgauss4wd", 		name = "@mp_eGaussVehicle", 	category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "US_ltv", 				modification = "Gauss", 		buildtime = 10};
				{ id = "nktruck", 			name = "@mp_eTruck", 			category = "@mp_catVehicles", price = 50, 	loadout = 0, class = "Asian_truck", 		modification = "Hardtop", 		buildtime = 10};
				{ id = "ussupplytruck", 	name = "@mp_eSupplyTruck", 		category = "@mp_catVehicles", price = 200, 	loadout = 0, class = "Asian_truck", 		modification = "Spawntruck", 	buildtime = 15, teamlimit = 4,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "ushovercraft", 		name = "@mp_eHovercraft", 		category = "@mp_catVehicles", price = 100, 	loadout = 0, class = "US_hovercraft", 		modification = "MP", 			buildtime = 10};
				{ id = "gausshovercraft", 	name = "Gauss Hovercraft", 		category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "US_hovercraft", 		modification = "Gauss", 		buildtime = 25};
				--{ id = "moachovercraft", 	name = "MOAC Hovercraft", 		category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "US_hovercraft", 		modification = "MOAC", 			buildtime = 20,level = 50};
				--{ id = "moarhovercraft", 	name = "MOAR Hovercraft", 		category = "@mp_catVehicles", price = 350, 	loadout = 0, class = "US_hovercraft", 		modification = "MOAR", 			buildtime = 30,level = 50};
				{ id = "nkaaa", 			name = "@mp_eAAVehicle", 		category = "@mp_catVehicles", price = 250, 	loadout = 0, class = "Asian_aaa", 			modification = "MP", 			buildtime = 15};
				--{ id = "autoaaa", 			name = "Auto Anti-Air", 		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_aaa", 			modification = "Ascension", 	buildtime = 20};
				{ id = "nkapc", 			name = "@mp_eAPC", 				category = "@mp_catVehicles", price = 300, 	loadout = 0, class = "Asian_apc", 			modification = "MP", 			buildtime = 20};
				{ id = "usapc", 			name = "@mp_eICV", 				category = "@mp_catVehicles", price = 350, 	loadout = 0, class = "US_apc", 				modification = "MP", 			buildtime = 20};
				{ id = "spawnapc", 			name = "Spawn APC", 			category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "US_apc", 				modification = "MP", 			buildtime = 25, teamlimit = 2,spawngroup=true,abandon=0,buyzoneradius=6,servicezoneradius=16,buyzoneflags=bor(bor(PowerStruggle.BUY_AMMO,PowerStruggle.BUY_WEAPON),PowerStruggle.BUY_EQUIPMENT)};
				{ id = "nktank", 			name = "@mp_eLightTank", 		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_tank", 			modification = "MP", 			buildtime = 30};
				{ id = "ustank", 			name = "@mp_eBattleTank", 		category = "@mp_catVehicles", price = 450, 	loadout = 0, class = "US_tank", 			modification = "Gauss", 		buildtime = 30};
				{ id = "watertank", 		name = "@mp_eBattleTank", 		category = "@mp_catVehicles", price = 450, 	loadout = 0, class = "US_tank", 			modification = "MP",	 		buildtime = 15, VehicleProperties = {
					Call = function(vehicle, player)
						vehicle.WaterTank = true;
						vehicle.NoBuyAmmo = true;
						vehicle.waterID = 1;
						for i, v in pairs(player:GetSeatWeapon(vehicle.Seats[1]))do
							--Debug(v)
							--Debug(v)
							--Debug(GetEnt(GetEnt(v).__this))
							if (GetEnt(v)) then
								if (GetEnt(GetEnt(v).__this)) then
									vehicle.vehicle:SetAmmoCount(GetEnt(GetEnt(v).__this).weapon:GetAmmoType(), 0)
								end
							end
						end
						--Debug("Called uwu")
					end;
				}};
				{ id = "usgausstank", 		name = "@mp_eGaussTank", 		category = "@mp_catVehicles", price = 600, 	loadout = 0, class = "US_tank", 			modification = "GaussCannon", 	buildtime = 30};
				{ id = "nkhelicopter", 		name = "@mp_eHelicopter",		category = "@mp_catVehicles", price = 400, 	loadout = 0, class = "Asian_helicopter", 	modification = "MP", 			buildtime = 20};
				--{ id = "gausshelicopter", 	name = "Gauss Helicopter", 		category = "@mp_catVehicles", price = 600, 	loadout = 0, class = "Asian_helicopter", 	modification = "Gauss", 		buildtime = 20};
				{ id = "usvtol", 			name = "@mp_eVTOL", 			category = "@mp_catVehicles", price = 1200, loadout = 0, class = "US_vtol", 			modification = "MP", 			buildtime = 30, teamlimit = 2};
				{ id = "transusvtol", 			name = "Transport vtol", 			category = "@mp_catVehicles", price = 600, loadout = 0, class = "US_vtol", 			modification = "MP", 			buildtime = 30, teamlimit = 10, 
				VehicleProperties = {
					Call = function(transVtol, player)
						transVtol.IsTrans = true
						transVtol.TransRange = 10
						transVtol.TransCargo = nil
					end,
					ModelProperties = { "objects/vehicles/us_vtol_transport/us_vtol_transport.cga",					{ x = 0, y = 0.0000, z = -4.10 }, makeVec(0,0,0),			false,		 nil }
				}
				
				};
				--{ id = "gaussvtol", 		name = "Gauss Vtol", 			category = "@mp_catVehicles", price = 1400, loadout = 0, class = "US_vtol", 			modification = "Gauss", 		buildtime = 30, teamlimit = 2};
				{ id = "moacvtol", 			name = "MOAC Vtol", 			category = "@mp_catVehicles", price = 1600, loadout = 0, class = "US_vtol", 			modification = "MOAC", 			buildtime = 30, teamlimit = 2, level = 15};
				{ id = "moarvtol", 			name = "MOAR Vtol", 			category = "@mp_catVehicles", price = 1800, loadout = 0, class = "US_vtol", 			modification = "MOAR", 			buildtime = 30, teamlimit = 2, level = 15};
				{ id = "hellvtol", 			name = "Hellfire Vtol", 		category = "@mp_catVehicles", price = 2000, loadout = 0, class = "US_vtol", 			modification = "Hellfire", 		buildtime = 40, teamlimit = 2, level = 15};
				{ id = "e1000", 			name = "EPIC E-1000", 			category = "@mp_catVehicles", price = 300, loadout = 0, class = "US_vtol", 			modification = "MOAC", 			buildtime = 15, teamlimit = 12, level = 0, VehicleProperties = {
					Call = function(e1k, p)
						Script.SetTimer(1000, function()
							RCA:MakeJet(e1k, 1);
						end);
					end,
				}};
				--{ id = "tacvtol", 			name = "TAC Vtol", 				category = "@mp_catVehicles", price = 4000, loadout = 0, class = "US_vtol", 			modification = "TACCannon", 	buildtime = 60, teamlimit = 2, level = 100, energy = 20, md = true};
				--{ id = "singvtol", 			name = "Singularity Vtol", 		category = "@mp_catVehicles", price = 5000, loadout = 0, class = "US_vtol", 			modification = "Singularity", 	buildtime = 60, teamlimit = 2, level = 100, energy = 20, md = true};
		};
		g_gameRules.protoList={
			{ id = "moac", 		name = "@mp_eAlienWeapon", category = "@mp_catWeapons", price = 300, loadout = 1, class = "AlienMount", uniqueId = 11, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 50, weapon = true};
			{ id = "bigmoac", 	name = "Big MOAC", category = "@mp_catWeapons", price = 1000, loadout = 1, class = "AlienMount", uniqueId = 631, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 65, weapon = true,
			ItemProperties = {
			Call = function(shit, player)
				shit.MegaAlienGun = true;
				shit.AllowAttach = {
					-- Only allow LAM to be attached
					["LAMRifle"] = true,
				};
				Script.SetTimer(1000, function()
					local code = [[
						local g=GetEnt("]]..shit:GetName()..[[")
						g.CM = "objects/weapons/alien/moac/moac.cgf"
						g.CMFP = "objects/weapons/alien/moac/moac.cgf"
						g.CMPos={x=-0.2,y=0.4,z=0}
						g.CMPosLocal={x=0.25,y=0.7,z=-0.5}
						g.CMDir={x=0.24,y=0,z=1.6}
						g_localActor.ICML=nil
						g_localActor.ICMId=nil
						g.FireSound="sounds/weapons:moac_warrior:fire"
						g.FireSoundVol=2;
						g.FireSoundVolNGL=1;
					]]
					ExecuteOnAll(code);
					shit.syncID = RCA:SetSync(shit, {client=code,link=shit.id});
				end);
				shit.weapon:AttachAccessory("Silencer",true,true);
				--shit.weapon:DisableAccessoryAttaching(true);
			end,
			}};
			
			{ id = "moar", name = "@mp_eAlienMOAR", category = "@mp_catWeapons", price = 100, loadout = 1, class = "MOARAttach", uniqueId = 12,level = 50, weapon = true};
			{ id = "minigun", name = "@mp_eMinigun", category = "@mp_catWeapons", price = 250, loadout = 1, class = "Hurricane", uniqueId = 13, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 50, weapon = true};
			{ id = "tacgun", name = "@mp_eTACLauncher", category = "@mp_catWeapons", price = 1000, loadout = 1, class = "TACGun", uniqueId = 14, uniqueloadoutgroup = 1, uniqueloadoutcount =2,level = 100, energy = 5,md=true, weapon = true};
			{ id = "usmoac4wd", name = "@mp_eMOACVehicle", category = "@mp_catVehicles", price = 250, loadout = 0, class = "US_ltv", modification = "MOAC", buildtime = 20,level = 50,vehicle=true};
			{ id = "usmoar4wd", name = "@mp_eMOARVehicle", category = "@mp_catVehicles", price = 300, loadout = 0, class = "US_ltv", modification = "MOAR", buildtime = 20,level = 50,vehicle=true};
			{ id = "moactank", name = "MOAC Tank", category = "@mp_catVehicles", price = 400, loadout = 0, class = "Asian_tank", modification = "MOAC", buildtime = 30,level = 50,vehicle=true};
			{ id = "moartank", name = "MOAR Tank", category = "@mp_catVehicles", price = 600, loadout = 0, class = "Asian_tank", modification = "MOAR", buildtime = 30,level = 50,vehicle=true};
			{ id = "ustactank", name = "@mp_eTACTank", category = "@mp_catVehicles", price = 1500, loadout = 0, class = "US_tank", modification = "TACCannon", buildtime = 45,level = 100, energy = 10,md=true,vehicle=true};
			{ id = "ussingtank", name = "@mp_eSingTank", category = "@mp_catVehicles", price = 2000, loadout = 0, class = "US_tank", modification = "Singularity", buildtime = 45,level = 100, energy = 10,md=true,vehicle=true};
			{ id = "cokepack", 	name = "Jetpack", 	category = "@mp_catEquipment", price = 500, loadout = 1, class = "SCAR_Tutorial", 	uniqueId = 608, level = 50, energy = 5, md = false, ItemProperties = { Call = function(item, player)SendMsg(CENTER, player, "JETPACK :: EQUIPPED")end;Unique = "ATOMCOKEPACK", Unlimited = true, DontGive = true }, PlayerProperties = { 
				Call = function(player) 
					if (true or not player.hasJetPack) then 
						ATOMPack:Add(player, 1)
						SendMsg(CHAT_BUYING, player, "(JetPack Purchased: Jump and holf ( F ) to Start Flying)")
					end
				end }};
		};
		--[[local veh_categs = {};
		for i,v in pairs(g_gameRules.vehicleList) do
				
				if v.factories then
					for j, w in pairs(v.factories) do
						if not veh_categs[j] then
							veh_categs[j] = {}
						end
						veh_categs[j][v.id] = w
					end
				end
			end
		for i, f in pairs(g_gameRules.factories or {}) do
			local tpe = f.Properties.szName
			if f.vehicles and f.vehicles.us4wd then tpe = "small" end
			if f.vehicles and f.vehicles.nktank then tpe = "war" end
			if veh_categs[tpe] then
				for j, v in pairs(veh_categs[tpe]) do
					SysLog(f:GetName().. " " .. j)
					f.vehicles[j] = v
				end
			end
		end--]]
		
		g_gameRules.buyList={};
		for _,def in pairs(g_gameRules.weaponList) do
			g_gameRules.buyList[def.id]=def;
			if def.weapon==nil then
				def.weapon=true;
			end
		end
		for _,def in pairs(g_gameRules.ammoList) do
			g_gameRules.buyList[def.id]=def;
			if def.ammo==nil then
				def.ammo=true;
			end
		end
		for _,def in pairs(g_gameRules.equipList) do
			g_gameRules.buyList[def.id]=def;
			if def.equip==nil then
				def.equip=true;
			end
		end
		for _,def in pairs(g_gameRules.vehicleList) do
			g_gameRules.buyList[def.id]=def;
			if def.vehicle==nil then
				def.vehicle=true;
			end
		end
		for _,def in pairs(g_gameRules.protoList) do
			g_gameRules.buyList[def.id]=def;
			if def.proto==nil then
				def.proto=true;
			end
		end

		VEHICLE_BUY_LISTS = {};
		
		for _,factory in pairs(g_gameRules.factories or System.GetEntitiesByClass("Factory") or {}) do
			local vehicles=factory.vehicles;
			if vehicles.us4wd then
				vehicles.trolley=true;
				vehicles.civcar=true;
				vehicles.policecar=true;
				vehicles.light4wd=true;
				vehicles.ushovercraft=true;
				vehicles.gausshovercraft=true;
				vehicles.nkapc=true;
				vehicles.audir8=true;
				vehicles.dueler=true;
				vehicles.tesla=true;
				_lol=factory.id
			end
			if vehicles.ustank then
				vehicles.watertank=true;
				vehicles.autoaaa=true;
				vehicles.spawnapc=true;
			end
			if vehicles.usboat then
				vehicles.speedboat=true;
				vehicles.roofedboat=true;
				vehicles.spawnboat=true;
				vehicles.moacboat=true;
				vehicles.moarboat=true;
				vehicles.gausshovercraft=true;
			end
			if vehicles.usvtol then
				vehicles.transusvtol=true;
				vehicles.gausshelicopter=true;
				vehicles.gaussvtol=true;
				vehicles.moacvtol=true;
				vehicles.moarvtol=true;
				vehicles.hellvtol=true;
				vehicles.tacvtol=true;
				vehicles.singvtol=true;
				vehicles.e1000=true;
				
					vehicles.dueler=true;
					vehicles.audir8=true;
					vehicles.tesla=true;
			end
			if vehicles.ustactank then
				vehicles.moachovercraft=true;
				vehicles.moarhovercraft=true;
				vehicles.moactank=true;
				vehicles.moartank=true;
			end
			VEHICLE_BUY_LISTS[factory.id] = vehicles;
		end
	end,
	-----------------------
	CanBuyItem = function(self, player, itemName)
		if (ATOMBroadcastEvent("CanBuyItem", player, itemName) == false) then return false end
		return true;
	end,
	-----------------------
	OwnsItem = function(self, player, t)
		SendMsg(CONSOLE_ATOM, player, "%s", t);
	end,
	-----------------------
	InvalidItem = function(self, player, t, name)
		SendMsg(CONSOLE_ATOM, player, "%s '$4%s$9' does not exist", t, tostring(name));
	end,
	-----------------------
	Need_Energy = function(self, player, item, level)
		SendMsg(CONSOLE_ATOM, player, "'$4%s$9' requires $4%d$9 Alien-Energy", item, level);
	end,
	-----------------------
	Item_Limit = function(self, player, item, t)
		SendMsg(CONSOLE_ATOM, player, "%s Limit for Item '$4%s$9' reached", t, item);
	end,
	-----------------------
	Message = function(self, player, t, ...)
		SendMsg(CONSOLE_ATOM, player, t, ...);
	end,
	-----------------------
	OnNotEnoughPP = function(self, player, itemName, price, missing)
		local item = g_gameRules.buyList[itemName];
		local price = price or item.price;
		SendMsg(CONSOLE_ATOM, player, "$7%s$9 Costs $4%d$9 Prestige (You need $7%d$9 more)", (item.ammo or item.class), price, missing or 0);
		return true;
	end,
	-----------------------
	OnItemBought = function(self, player, item, itemProperties)
	--	Debug(item.id)
		if (item and item.id) then
			if (not itemProperties.DontGive) then
				--ATOMEquip:CheckItem(player, item)
				Script.SetTimer(1, function()
					ATOMEquip:CheckItem(player, item, nil, true, true);
					if (item.changed) then
						SendMsg(CHAT_EQUIP, player, "(Custom Equipment: Loaded for %s)", item.class);
					end;
				end);
			end;
			if (item.class == "LAW") then
				item.weapon:DisableAutoDropping(true);
			end;
			ATOMBroadcastEvent("OnItemBought", player, item, item.class)
		end;
	--	Debug("itemProperties",itemProperties)
		return true;
	end,
	-----------------------
	CanBuyVehicle = function(self, player, itemName)
		if (ATOMBroadcastEvent("CanBuyVehicle", player, itemName) == false) then return false end
		return true;
	end,
	-----------------------
	OnVehicleBought = function(self, player, vehicle)
		ATOMBroadcastEvent("OnVehicleBought", player, vehicle, vehicle.class)
		return true;
	end,
	-----------------------
	OnEnterBuyZone = function(self, player, itemName)
		return true;
	end,
	-----------------------
	OnLeaveBuyZone = function(self, player, itemName)
		return true;
	end,
	-----------------------
};

ATOMBuying:Init();