
ATOMAttach = {
	cfg = {
		Attachable = {
			['M4A1'] 			= true;
			['SMG'] 			= true;
			['SCAR'] 			= true;
			['TACGun'] 			= true;
			['FY71'] 			= true;
			['GaussRifle'] 		= true;
			['Hurricane'] 		= true;
			['TACGun_Fleet'] 	= true;
			['SCAR_Tutorial'] 	= true;
			['DSG1'] 			= true;
			['Golfclub'] 		= false; -- caused bugs
			['Shotgun'] 		= true;
			['AlienMount'] 		= true;
		};
	};
	---------------
	Init = function(self)
		_WeaponAttach = function()end;
		ATOM_ATTACH = true;
		RegisterEvent("OnItemChanged", ATOMAttach.OnChanged, 'ATOMAttach');
	end,
	---------------
	ResetPlayer = function(self, player, died)
		if (not player) then
			return;
		end;
		for i, fakeItem in pairs(player._fakeItems or {}) do
			if (died) then
				local this = GetEnt(fakeItem.parent);
				if (this) then
					local handPos = player:GetBonePos("Bip01 R hand");
					local dropped = System.SpawnEntity({class=this.class,position=handPos,orientation=g_Vectors.down,name=this:GetName().."_dropped",properties={InitialSetup = GetAttachments(this,true),fMass=10,bPhysics=1}});
					ATOMGameUtils:AwakeEntity(dropped);
					g_game:ScheduleEntityRemoval(dropped.id, 15, false);
					for j, v in pairs(GetAttachments(this)or{})do
						dropped.weapon:AttachAccessory(GetEnt(v).class, true, true);
					end;
				end;
			end;
			System.RemoveEntity(fakeItem.me);
		end;
		player._fakeItems = {};
	end;
	---------------
	Detach = function(self, player, item, bForce)

		if (not GetBetaFeatureStatus("attach")) then
			return
		end
		if (ATOM_ATTACH) then
			if (item.class ~= "Fists" and item._fakeItem ~= nil) then
				
				if (item._dontAttach or (not bForce and not InInventory(player, item.id))) then
					item._dontAttach = false;
					return;
				end;
					
				local cancel = false;
					
				local rifles = self.cfg.Attachable;
					
				player.onBack_Rifle_Used = player.onBack_Rifle_Used or {};
				player.onBack_LAW_Used = player.onBack_LAW_Used or {};
				player.onBack_SOCOM_Used = player.onBack_SOCOM_Used or {};
					
				--Debug(rifles[item.class])
					
				if (rifles[item.class]) then
					--player.onBack_Rifle = (player.onBack_Rifle or 1) - 1;
					--if (player.onBack_Rifle<=0) then player.onBack_Rifle=1; end;
					--player.onBack_Rifle_Used[player.onBack_Rifle] = false;
					--player.onBack_Rifle = math.min(2, math.max(0, player.onBack_Rifle));
				elseif (item.class == "LAW") then
					--player.onBack_LAW = (player.onBack_LAW or 1) - 1;
					--if (player.onBack_LAW<=0) then player.onBack_LAW=1; end;
					--player.onBack_LAW_Used[player.onBack_LAW] = false;
					--player.onBack_LAW = math.min(2, math.max(0, player.onBack_LAW));
				elseif (item.class == "SOCOM") then
					--player.onBack_SOCOM = (player.onBack_SOCOM or 1) - 1;
					--if (player.onBack_SOCOM<=0) then player.onBack_SOCOM=1; end;
					--player.onBack_SOCOM_Used[player.onBack_SOCOM] = false;
					--player.onBack_SOCOM = math.min(2, math.max(0, player.onBack_SOCOM));
				elseif (item.class == "RepairKit") then
				
				else
					cancel = true;
				end;
				
				if (cancel) then return; end;
				
				item.attached = false;
				player._fakeItems = player._fakeItems or {};
				player._fakeItems[item._fakeItem.id] = nil;
				System.RemoveEntity(item._fakeItem.id);
				item._fakeItem = nil;
				
				if (item.attach_syncId) then
					--Debug("SYNC:: REMOVED");
					RCA:StopSync(item, item.attach_syncId);
					item.attach_syncId = nil;
				end;
				
				--Debug("Detached: " .. item:GetName().. ", " ..player.onBack_Rifle );
			end;
		end;
	end;
	---------------
	Attach = function(self, player, item)

		if (not GetBetaFeatureStatus("attach")) then
			return
		end

		if (ATOM_ATTACH) then

			for i, v in pairs(checkArray(player._fakeItems)) do
				if (not player.inventory:GetItemByClass(v.forClass)) then
				--	Debug("invalid item detedted aaaAAAAAAAAAAAHHHHH!!")
					if (System.GetEntity(v.parent)) then
					--	Debug("del 1 DETACH !")
						self:Detach(player,System.GetEntity(v.parent), 1)
					elseif (v.me) then
						System.RemoveEntity(v.me)
					end
				end
			end

			if (item.class ~= "Fists" and item._fakeItem == nil) then
					
				if (item._dontAttach or not InInventory(player, item.id)) then
					item._dontAttach = false
					return
				end
				--Debug("Okay")
				
				local boneName01, boneName02, bonePos01, bonePos02 = "", "", "", ""
				
				local onBack = 0
				
				local toAttach = self.cfg.Attachable
					
				local cancel = false
				local socom = false
					
				local current = 1
				local rifles = self.cfg.Attachable
					
				if (rifles[item.class]) then
					boneName01, boneName02, bonePos01, bonePos02 = "_rap0", "_rap1", "weaponPos_rifle01", "weaponPos_rifle02"
				elseif (item.class == "LAW") then
					boneName01, boneName02, bonePos01, bonePos02 = "_lap0", "_lap1", "weaponPos_hurricane", "weaponPos_hurricane"
					current = 2
				elseif (item.class == "SOCOM") then
					boneName01, boneName02, bonePos01, bonePos02 = "_sap0", "_sap1", "weaponPos_pistol_L_leg", "weaponPos_pistol_R_leg"
					current = 3
				--	socom = true;
				elseif (item.class == "RepairKit") then
					boneName01, boneName02, bonePos01, bonePos02 = "_kap0", "_kap1", "weaponPos_pistol_R_leg", "weaponPos_pistol_L_leg"
					current = 4
				else
					cancel = true
				end
				
				if (cancel) then
				--	Debug("Bad",item.class)
					return
				end
			--	Debug("Okay2")
				
				if (onBack>2) then
					onBack = 2
				end

				if (onBack == player.onBack__) then
					onBack = (player.onBack__ == 1 and 2 or 1)
				end
				
				--Debug("OB: " .. onBack .. " boneName01 = " .. boneName01 .. " boneName02 = " .. boneName02)
				
				item.attached = true;
				--(modelName, position, fMass, scale, dir, noPhys, bStatic, viewDistance, particleEffect)
				item._fakeItem = SpawnGUI(self:GetModelByClass(item.class), g_Vectors.up, 0, 1, g_Vectors.up, true); --System.SpawnEntity({name = item:GetName() .. game:SpawnCounter(), class = item.class, Properties = item.Properties})
				
				item._fakeItem.unpickable = true;
				
				player._fakeItems = player._fakeItems or {};
				player._fakeItems[item._fakeItem.id] = {
					parent = item.id;
					me = item._fakeItem.id;
					forClass = item.class,
				};
				
				player.gunSlots = player.gunSlots or {};
				player.gunSlots[current] = player.gunSlots[current] or {};
				
				if (player.gunSlots[current][1] and System.GetEntity(player.gunSlots[current][1])) then
					onBack = 2;
					player.gunSlots[current][2] = item._fakeItem.id;
				else
					onBack = 1;
					player.gunSlots[current][1] = item._fakeItem.id;
				end;
				if (player.codeTimer) then
					Script.KillTimer(player.codeTimer)
				end

				--Debug("ll good")
				player.codeTimer = Script.SetTimer(125, function()
					if (item._fakeItem and System.GetEntity(item._fakeItem.id)) then
						local toLoadString = [[_WeaponAttach(']]..item._fakeItem:GetName()..[[',']]..player:GetName()..[[',']]..boneName01..[[',']]..boneName02..[[',']]..bonePos01..[[',']]..bonePos02..[[',]]..onBack..[[);]];
						ExecuteOnAll(toLoadString, true);
						if (item.attach_syncId) then
							--Debug("SYNC:: REMOVED");
							RCA:StopSync(item, item.attach_syncId);
							item.attach_syncId = nil;
						end;
						--Debug("SYNC:: ADDED");
						item.attach_syncId = RCA:SetSync(item, { link = true, client = toLoadString}, true);
						
						if (socom) then
							if (onBack>=2) then
								onBack=1
							end
						end
						
						player.onBack__ = onBack;
						loadstring(toLoadString)()
						--Debug("Loaded")
					end;
				end);
			end;
		end;
	end;
	---------------
	GetModelByClass = function(self, class)
		local models = {
			['m4a1'] 			= "Objects/weapons/us/m4a1/m4a1_tp.cgf";
			['fy71'] 			= "Objects/weapons/asian/fy71/fy71_tp.cgf";
			['shotgun'] 		= "Objects/weapons/us/shotgun/shotgun_tp.cgf";
			['tacgun'] 			= "objects/weapons/us/tac_gun/tac_gun_tp.cgf";
			['hurricane'] 		= "Objects/weapons/us/hurricane/hurricane_tp.cgf";
			['scar'] 			= "objects/weapons/us/scar/scar_l-c_tp.cgf";
			['smg'] 			= "objects/weapons/us/smg/smg_tp.cgf";
			['golf'] 			= "Objects/library/architecture/aircraftcarrier/props/misc/golfclub.cgf";
			['alienmount'] 		= "objects/weapons/us/alien_weapon_mount/alien_weapon_mount_tp.cgf";
			['socom']			= "objects/weapons/us/socom/socom_tp.cgf";
			['law'] 			= "objects/weapons/us/law/law_tp.cgf";
			['gaussrifle'] 		= "objects/weapons/us/gauss/gauss_tp.cgf";
			['dsg1'] 			= "objects/weapons/us/sniper_dsg1/sniper_dsg1_tp.cgf";
			['tacgun_fleet'] 	= "objects/weapons/us/tac_gun/tac_gun_tp.cgf";
			['scar_tutorial'] 	= "objects/weapons/us/scar/scar_l-c_tp.cgf";
			['repairkit'] 		= "Objects/weapons/equipment/repair_kit/repair_kit_tp.cgf";
		};
		return models[class:lower()];
	end;
	---------------
	OnChanged = function(self, player, newItem, oldItem)
		if (ATOM_ATTACH) then
			if (newItem) then
				self:Detach(player, newItem)
			end;
			if (oldItem) then
				self:Attach(player, oldItem)
			end;
		end;
	end;
};

ATOMAttach:Init();