ATOMSetup = {
	-- config
	cfg = {};
	-------------
	-- map setup loaded entities
	loaded = ATOMSetup~=nil and ATOMSetup.loaded or {};
	-------------
	-- script files
	files = ATOMSetup~=nil and ATOMSetup.files or {};
	globalFile = "",
	-------------
	AddMapSetupScript = function(self, fileName, filePath)
		Script.UnloadScript(filePath);
		Script.ReloadScript(filePath)
	end;
	-------------
	AddSetup = function(self, map, f)
		if (map == "Global") then
			self.globalFile = f
			return
		end
		self.files[map:lower()] = f;
	end;
	-------------
	OnMapStart = function(self, mapName, mapPath)

		local fGlobal = self.globalFile
		if (fGlobal) then
			local bOk, sError = pcall(fGlobal)
			if (not bOk or sError) then
				ATOMLog:LogError("Failed to load Global Map Setup file (%s)", tostring(sError))
			else
				ATOMLog:Log("Global Map Setup file loaded")
			end
		end

		local scriptPath = self.files[mapPath:lower()] or self.files[mapName:lower()]; --mapPath:lower()]; --mapName:lower()];
		if (scriptPath) then
			--scriptPath = scriptPath:gsub("Game/","");
			if (self.loaded[mapPath]) then
			--	Script.UnloadScript(scriptPath);
				self:CleanUp();
			end;
			local success, error = pcall(scriptPath);--Script.LoadScript(scriptPath);
			if (success) then
				self.loaded[mapPath] = true;
				ATOMLog:Log("Loaded Map Setup Script for map %s", makeCapital(mapName));
			else
				ATOMLog:LogError("Failed to load MapSetup Script for Map %s, %s", makeCapital(mapName), tostr(error));
			end;
		else
			SysLog("No map setup found " .. mapName .. ", " .. mapPath)
		end;
	end;
	-------------
	CleanUp = function(self)
		local iCleaned = 0
		for i, entity in pairs(System.GetEntities()or{}) do
			if (entity.SETUP_SPAWNED or entity:GetName():find("^%[MAPSETUP%]")) then
				for ii, v in pairs(entity.DELETION_LINKS or {}) do
					System.RemoveEntity(v)
					iCleaned = iCleaned + 1
				end
				System.RemoveEntity(entity.id)
				iCleaned = iCleaned + 1
			end
		end
		SysLog("Deleted ( %d ) Old Map-Setup Entities", iCleaned)
	end;
	-------------
	MarkAsMapSetup = function(...)
		local entities = { ... };
		for i, v in pairs(entities) do
			v.SETUP_SPAWNED = true;
		end;
	end;
	-------------
	LoadSetup = function(self, f)
		local success, error = pcall(f);
		if (not success) then
			ATOMLog:LogError("Failed to load MapSetup: %s", error);
		end;
	end;
	-------------
	Spawn = function(properties)
		local props = {
			class 		= properties.class or properties.Class,
			name 		= properties.name or properties.Name,
			position 	= properties.pos or properties.position,
			orientation = properties.orientation or Dir2Ang(properties.dir),
			properties 	= properties.properties or {}
		};
		local isVehicle = g_utils:IsVehicleClass(props.class);
		if (props.properties.bAdjustToTerrain) then
			props.position.z = GetGroundPos(props.position);
		end;
		if (isVehicle) then
			Script.SetTimer(1, function()
				props.name = "[MAPSETUP]" .. props.name;
				local new = System.SpawnEntity(props);
				new.SETUP_SPAWNED = not properties.nosetup;
				if (properties.network) then
					CryAction.CreateGameObjectForEntity(new.id);
					CryAction.BindGameObjectToNetwork(new.id);
					CryAction.ForceGameObjectUpdate(new.id, true);
				end;
				if (properties.SpawnFunc) then
					new[properties.SpawnFunc]();
				end;
				if (properties.scale) then
					new:SetScale(properties.scale);
				end;
				if (properties.angles) then
					new:SetAngles(properties.angles);
				end;
				ATOMGameUtils:AwakeEntity(new);
				return new;
			end);
		else
			local new = System.SpawnEntity(props);
			new.SETUP_SPAWNED = not properties.nosetup;
			if (properties.network) then
				CryAction.CreateGameObjectForEntity(new.id);
				CryAction.BindGameObjectToNetwork(new.id);
				CryAction.ForceGameObjectUpdate(new.id, true);
			end;
			if (properties.SpawnFunc) then
				pcall(_G[props.class][properties.SpawnFunc], new);
			end;
			if (properties.scale) then
				new:SetScale(properties.scale);
			end;
			if (properties.angles) then
				new:SetAngles(properties.angles);
			end;
			return new;
		end;
	end;
	-------------
};

AddEntity = ATOMSetup.Spawn;
MarkAsMapSetup = ATOMSetup.MarkAsMapSetup;