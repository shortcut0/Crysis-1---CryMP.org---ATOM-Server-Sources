ATOMEquip = {
	cfg = {
	
		UseSpawnEquipment = true;
		
		RefillAmmo = true;
		
		UseCustomSpawnWeapon = true;
		
		SpawnEquipment = {
			InstantAction = {
				[GUEST	] = {
					{ "FY71", { "LAMRifle", "Silencer" }};
				};
				[PREMIUM] = {
					{ "FY71", { "LAMRifle", "Silencer" }};
					{ "SCAR", { "LAMRifle", "Silencer", "AssaultScope" }};
				};
				AdditionalEquip = {
					'Binoculars'
				};
				MustHave = {
					"LAMRifle", 
					"Silencer"
				};
			};
			PowerStruggle = {
				[GUEST	] = {
					{ "FY71", { "LAMRifle", "Silencer" }};
				};
				[PREMIUM] = {
					{ "FY71", { "LAMRifle", "Silencer" }};
					{ "SCAR", { "LAMRifle", "Silencer", "AssaultScope" }};
				};
				AdditionalEquip = {
					'Binoculars'
				};
				MustHave = {
					"LAMRifle", 
					"Silencer"
				};
			};
		};
	
		SaveEquipment = true; -- save equipment in external file
		SaveEquipmentMessage = {
			Delay	= 120,
			Message = "You Equipment has been Saved";
		};
	};
	-------------
	savedEquipment = ATOMEquip~=nil and ATOMEquip.savedEquipment or {};
	savedSpawnWeapons = ATOMEquip~=nil and ATOMEquip.savedSpawnWeapons or {};
	-------------
	Init = function(self)
		self.savedEquipment = {};
		self:LoadFile();
		self.defaultEquipment = self.cfg.SpawnEquipment;
	end;
	-------------
	InitPlayer = function(self, player)
		player.GetEquipment = function(self)
			return ATOMEquip:GetEquipment(self);
		end;
		player.GetSpawnWeapon = function(self)
			return ATOMEquip:GetSpawnWeapon(self);
		end;
	end;
	-------------
	ItemSelected = function(self, player, item)
		if (item.class == "RepairKit" and g_gameRules.class == "PowerStruggle") then
			if (not player.LastDefMsg or _time - player.LastDefMsg > 60) then
				local brokenTurret = false;
				local damagedHQ = false;
				local t;
				for i, v in pairs(g_gameRules.turrets) do
					t = GetEnt(v);
					if (t) then
						if (t.item:IsDestroyed() and g_game:GetTeam(t.id) == g_game:GetTeam(player.id) and GetDistance(t,player) < 60) then
							brokenTurret = true;
						end;
					end;
				end;
				for i, v in pairs(g_gameRules.hqs) do
					t = GetEnt(v);
					if (t) then
						if (t:GetHealth() < t.Properties.nHitPoints and g_game:GetTeam(t.id) == g_game:GetTeam(player.id) and GetDistance(t,player) < 250) then
							damagedHQ = true;
						end;
					end;
				end;
				
				SendMsg(CHAT_EQUIP, player, (damagedHQ and "Repair your HQ using your Repair Kit!" or brokenTurret and "Revive Destroyed Turrets using your Repair Kit" or "Use your Defibrillator on dead teammates to Revive them!"));
				player.LastDefMsg = _time;
			end;
		end;
	end,
	-------------
	ChangeSpawnWeapon = function(self, player, Index)
		if (not Index) then
			if (not self.savedSpawnWeapons[player:GetIdentifier()]) then
				return false, "You don't have a custom Gun"
			end;
			return true, SendMsg(CHAT_EQUIP, player, "(SpawnWeapon: Current Custom Gun %s)", self.savedSpawnWeapons[player:GetIdentifier()]:upper());
		end;
		
		local Index = tonum(Index);
		local identifier = player:GetIdentifier();
		
		if (Index == 0) then
			if (not self.savedSpawnWeapons[player:GetIdentifier()]) then
				return false, "You don't have a custom Gun"
			end;
			self.savedSpawnWeapons[player:GetIdentifier()] = nil;
			return true, self:SaveFile2(), SendMsg(CHAT_EQUIP, player, "(SpawnWeapon: Custom gun Disabled)");
		end;
		
		local equip = {
			[1] = "SMG";
			[2] = "FY71";
			[3] = "SCAR";
		};
		if (player:HasAccess(SUPERADMINISTRATOR)) then
			equip = {
				[1] = "SMG";
				[2] = "FY71";
				[3] = "SCAR";
				[4] = "TACGun";
				[5] = "Hurricane";
				[6] = "Shotgun";
				[7] = "GaussRifle";
			}
		end;
		
		local possibilities = "";
		for i = 1,arrSize(equip) do
			local v = equip[i];
			possibilities = possibilities .. (i>1 and " " or "") .. "[ " .. i .. " ] :: [ " .. v .. " ]" .. (i~=arrSize(equip) and " |" or ""); 
			--[ 1 ] for :: [ SMG ] | [ 2 ] for :: [ FY71 ] | [ 3 ] for :: [ SCAR ]
		end;
		
		if (not Index or Index > arrSize(equip)) then
			return true, SendMsg(CHAT_EQUIP, player, "(SpawnWeapon: Select " .. possibilities .. ")");
		end;
		SendMsg(CHAT_EQUIP, player, "(SpawnWeapon: Selected Item [ " .. equip[Index] .. " ])");
		self.savedSpawnWeapons[identifier] = equip[Index];
		self:SaveFile2();
	end;
	-------------
	HasSpawnWeapon = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier) then
			return self:GetSpawnWeapon(player);
		end;
	end;
	-------------
	GetSpawnWeapon = function(self, player)
	--	Debug(self.savedSpawnWeapons[player:GetIdentifier()])
		return self.savedSpawnWeapons[player:GetIdentifier()];
	end;
	-------------
	OnSpawn = function(self, player)
	
		--`do return end
		
		if (not self.cfg.UseSpawnEquipment or not self.cfg.SpawnEquipment) then
			return false;
		end;
		
		local playerAccess = player:GetAccess();
		local last = -999;
		local equip = {};
		local spawnEquip = {};
		if (g_gameRules.class == "PowerStruggle") then
			spawnEquip = self.cfg.SpawnEquipment['PowerStruggle'];
		else
			spawnEquip = self.cfg.SpawnEquipment['InstantAction'];
		end;
		
		for i, equipment in pairs(spawnEquip) do
			if (IsUserGroup(i) and player:HasAccess(i) and last < i) then
				last = i;
				equip = equipment;
			end;
		end;
		
		if (self.cfg.UseCustomSpawnWeapon) then
			if (self:HasSpawnWeapon(player)) then
				equip = { { [1] = self:GetSpawnWeapon(player), [2] = { "LAMRifle", "Silencer" } } };
			end;
		end;
		
		if (arrSize(equip) < 1) then
			return false;
		end;
		
		if (spawnEquip['AdditionalEquip']) then
			for j, item in pairs(spawnEquip['AdditionalEquip']) do
				ItemSystem.GiveItem(item, player.id, true);
			end;
		end;
		if (spawnEquip['MustHave']) then
			for j, item in pairs(spawnEquip['MustHave']) do
				if (not player.inventory:GetItemByClass(item)) then
					ItemSystem.GiveItem(item, player.id, true);
				end;
			end;
		end;
		
		player.customEquipmentLoaded = false;
		
		local idIsPS = g_gameRules.class == "PowerStruggle"
		for i, equipData in pairs(equip) do
			if (IsUserGroup(i)) then
				local gunID = ItemSystem.GiveItem((equipData[1] == "Random" and self:GetRandomItem() or equipData[1]), player.id, true);
				local gun = GetEnt(gunID);
				if (gun) then
					local accessories = self:GetAccessoriesForGun(player, gun.class) or equipData[2];
					if (accessories and arrSize(accessories) > 0) then
					--                     (player, weapon, attachments, pickup, needsInInventory, noGive)
						for _i, v in pairs(equipData[2]) do
							ItemSystem.GiveItem(v, player.id, false)
						end
						self:AttachOnWeapon(player, gun, accessories, false, idIsPS, idIsPS);
						if (self.cfg.RefillAmmo) then
							self:RefillAmmo(player, newItem);
						end;
					end;
					local ag = AutoGun or player.AutoGun;
					if (ag) then
						gun.SpecialGun = ag;
					end;
				end;
			end;
		end;
		
		--if (player.customEquipmentLoaded) then
		--	if (not player.lastEquipMsg) then
		--	end;
		--end;
		
		return true;
	end;
	-------------
 -- CheckItem           (      player, p1,  nil,    true,   true);
	CheckItem = function(self, player, gun, noauto, pickup, needsInInventory)
		local accessories = self:GetAccessoriesForGun(player, gun.class);
		--Debug(gun.class,accessories)
		if (accessories and arrSize(accessories) > 0) then
			--Debug(":)")
			self:AttachOnWeapon(player, gun, accessories, pickup, needsInInventory);
			--if (self.cfg.RefillAmmo) then
			--	self:RefillAmmo(player, newItem);
			--end;
		end;
		if (not noauto) then
			local ag = AutoGun or player.AutoGun;
			if (ag) then
				gun.SpecialGun = ag;
			end;
		end;
	end,
	-------------
	GetRandomItem = function(self)
		local Random = {
			"FY71",
			"Claymore",
			"ShiTen",
			"FastLightMOAR",
			"FastLightMOAC",
			"ScoutSingularity",
			"MOAR",
			"MOAC",
			"AlienMount",
			"EMPGrenade",
			"SmokeGrenade",
			"RepairKit",
			"RadarKit",
			"LAW",
			"SMG",
			"SCAR",
			"Shotgun",
			"Hurricane",
			"SOCOM",
			"DSG1",
			"GaussRifle",
			"C4",
			"FragGrenade"
		};
		return GetRandom(Random);
	end,
	-------------
	RefillAmmo = function(self, player, weaponId)
		local weapon = weaponId and System.GetEntity(weaponId) or player.inventory:GetCurrentItem();
		if (weapon and weapon.weapon) then
			local ammoType = weapon.weapon:GetAmmoType();
			if (ammoType) then
				local ammoCapacity = player.inventory:GetAmmoCapacity(ammoType);
				if (ammoCapacity) then
					
					local refilled 		= ammoCapacity - player.inventory:GetAmmoCount(ammoType);
					local gunRefilled 	= weapon.weapon:GetClipSize()+1 - weapon.weapon:GetAmmoCount();
					
					weapon.weapon:SetAmmoCount(nil, weapon.weapon:GetClipSize()+1);
					player.actor:SetInventoryAmmo(ammoType, ammoCapacity);
					player.inventory:SetAmmoCount(ammoType, ammoCapacity);
					
					return refilled, gunRefilled;
				end;
			end;
		end;
	end;
	-------------
	AttachOnWeapon = function(self, player, weapon, attachments, pickup, needsInInventory, noGive)
		weapon.changed = false;
		local attachID;
		for i, attachClass in ipairs(attachments) do
			if (not noGive and not needsInInventory) then
				--Debug("ITEM WAS GIVEN TO THE PLAYER !!!")
				attachID = ItemSystem.GiveItem(attachClass, player.id, false);
			end;
			if (not attachID) then
			--	return false, "failed to give "..attachClass.." to "..player:GetName();
			end;
			if (pickup) then
			--	Debug("PUI")
			--	Debug()
				--Debug("?",attachClass)
				--Debug("needs in inv: ",needsInInventory)
				--Debug("has in inv:", player.inventory:GetItemByClass(attachClass))
				--Debug("class:", attachClass)
				if (not weapon.weapon:GetAccessory(attachClass) and (not needsInInventory or player.inventory:GetItemByClass(attachClass))) then
					--Debug("!!",attachClass)
					weapon.weapon:SwitchAccessory_Server(attachClass)
					weapon.changed = true;
				end;
			else	
					--Debug("needsInInventory",needsInInventory,"player.inventory:GetItemByClass(",attachClass,")",player.inventory:GetItemByClass(attachClass))
				if (weapon.weapon:SupportsAccessory(attachClass) and (not needsInInventory or player.inventory:GetItemByClass(attachClass))) then
					weapon.weapon:AttachAccessory(attachClass, true, true);
					weapon.changed = true;
				end;
			end;
		end;
		return true;

	end;
	-------------
	IsAccessoryAttached = function(self, weapon, a)
		for i, b in pairs(self:GetEntitiesFromTable(weapon, weapon.weapon:GetAttachedAccessories()or{})or{}) do
			--Debug(b,'=',a)
			if (b == a) then
				return true;
			end;
		end;
		return false;
	end;
	-------------
	GetAccessoriesForGun = function(self, player, class)
		if (self.cfg.SaveEquipment) then
			local identifier = player:GetIdentifier();
			local data = self.savedEquipment[identifier];
			if (data and identifier) then
			--	Debug("Class",class)
			--	Debug("data",data);
			--	Debug("Dataclass",data[class])
				player.customEquipmentLoaded = true;
				return data[class];
			end;
		end;
		return;
	end;
	-------------
	CheckSavedEquipment = function(self, player)
		if (self.cfg.SaveEquipment) then
			if (self:HasEquipment(player)) then
			--	Debug("Wow, has")
				self:GiveEquipment(player);
				return true;
			end;
		end;
		--Debug("Wow, NO ")
		return false;
	end;
	-------------
	GiveEquipment = function(self, player)
		local equip = self:GetEquipment(player);
		local guns 	= player.inventory:GetInventoryTable();
		for i, gunID in pairs(guns or{}) do
			local gun = GetEnt(gunID);
			if (gun and gun.weapon) then
			--	Debug(gun.class)
				if (equip[gun.class]) then
			--		Debug("RESTORE!!!", equip[gun.class])
					self:AttachToWeapon(player, gun, equip[gun.class]);
				end;
			end;
		end;
	end;
	-------------
	HasEquipment = function(self, player)
		local identifier = player:GetIdentifier();
		if (identifier) then
			return self:GetEquipment(player);
		end;
	end;
	-------------
	GetEquipment = function(self, player)
	--	Debug(self.savedEquipment[player:GetIdentifier()])
		return self.savedEquipment[player:GetIdentifier()];
	end;
	-------------
	OnLeaveModify = function(self, player, weapon)
		if (player and not player:DefaultEquipment() and self.cfg.SaveEquipment) then
			local savedAny = false;
			for i, gunId in pairs(player.inventory:GetInventoryTable()or{}) do
				local gun = GetEnt(gunId);
				if (gun.weapon) then
					if (gun.accessoriesChanged ~= false) then
						local attached = self:GetEntitiesFromTable(gun, gun.weapon:GetAttachedAccessories());
						self:SaveAccessories(player, gun.class, attached);
						savedAny = true;
					end;
					gun.accessoriesChanged = false;
				end;
			end;
			local msg = self.cfg.SaveEquipmentMessage;
			if (not msg) then
				msg = {
					Delay = 120;
					Message = "You Equipment has been Saved";
				};
			end;
			if (savedAny and player.Popups) then
				if (not player.lastEquipMsg or _time - player.lastEquipMsg >= msg.Delay) then
					SendMsg(CHAT_EQUIP, player, msg.Message);
					player.lastEquipMsg = _time;
				end;
			end;
		--	self:SaveFile();
		end;
	end;
	-------------
	OnAttachAccessory = function(self, player, weapon, accessory)
	--	Debug("Changed")
		if (weapon.AllowAttach) then
			if (not weapon.AllowAttach[accessory]) then
				--Debug("blocked attaching ",accessory)
				return false;
			end;
		end;
		
		local forb = self.cfg.ForbiddenAttachments;
		if (forb and forb[accessory]) then
			return false, SendMsg(ERROR, player, "( %s ) ATTACHMENT FORBIDDEN", accessory);
		end;
		
		weapon.accessoriesChanged = true;
		return true;
	end;
	-------------
	GetEntitiesFromTable = function(self, w, t)
		local n = {};
		for i, v in pairs(t) do
		--	n [arrSize(n)+1] = GetEnt(v).class;
			if (w.weapon:GetAccessory(System.GetEntity(v).class)) then
				table.insert(n, System.GetEntity(v).class);
			end;
		end;
		return n;
	end;
	-------------
	SaveAccessories = function(self, player, weaponClass, accessories)
		if (self.cfg.SaveEquipment) then
			local identifier = player:GetIdentifier();
			if (identifier) then
				self:SetAccessories(identifier, weaponClass, accessories);
		
			end;
		end;
	end;
	-------------
	ConvertTable = function(self, t)
		local n = {};
		--[[for i, v in pairs(t) do
			for j, k in pairs(v) do
				Debug(i,j,k)
				if (arrSize(k)>0) then
					n [arrSize(n)+1] = {
						i,
						j,
						unpack(v)
					};
				end;
			end;
		end;--]]
		local gunName;
		for i, id in pairs(t) do
			--Debug(i)
			for j, d in pairs(id) do
				n[arrSize(n)+1] = {
					i,
					j,
					unpack(d),
				};
			end;
			
		end;
		return n;
	end;
	-------------
	SetAccessories = function(self, identifier, weapon, accessories)
		self.savedEquipment[identifier] = self.savedEquipment[identifier] or {};
		self.savedEquipment[identifier][weapon] = {};
		for i, v in pairs(accessories or{}) do
			table.insert(self.savedEquipment[identifier][weapon], (type(v)=="table" and v.class or v));
		end;
	end;
	-------------
	LoadFile = function(self, t)
	--	Debug("Lodding?")
		LoadFile("ATOMEquip1", "Equipment.lua");
		LoadFile("ATOMEquip2", "VIPSpawnWeapons.lua");
	end;
	----------
	LoadEquipment = function(self, identifier, weaponName, ...)
		--Debug("INIT INIT INIT ???",identifier,weaponName,...)
		if (identifier and weaponName) then
		--	Debug("Loaded:",identifier,weaponName,unpack({...}))
			self:SetAccessories(identifier, weaponName, { ... });
		end;
	end;
	----------
	LoadSpawnWeapon = function(self, identifier, weaponName, ...)
	--	Debug("INIT INIT INIT ???",identifier,weaponName,...)
	--	if (identifier and weaponName) then
	--		Debug("Loaded:",identifier,weaponName,unpack({...}))
	--		self.savedSpawnWeapons[identifier] = weaponName;
	--	end;
	end;
	------------
	SaveFile = function(self, t)
		SaveFile("ATOMEquip1", "Equipment.lua", "ATOMEquip:LoadEquipment", self:ConvertTable(self.savedEquipment));
	end;
	------------
	SaveFile2 = function(self, t)
	--	SaveFile("ATOMEquip2", "VIPSpawnWeapons.lua", "ATOMEquip:LoadSpawnWeapon", self.savedSpawnWeapons);
		SaveFile_Arr("ATOMEquip2", "VIPSpawnWeapons.lua", "ATOMEquip.savedSpawnWeapons", self.savedSpawnWeapons);
	end;
	
};