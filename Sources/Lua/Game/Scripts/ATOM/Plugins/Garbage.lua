GarbageCollector = {
	cfg = {
	};
	toDeleteFlags = {
		ENTITY_FLAG_CLIENT_ONLY;
	};
	-----------------
	InitHooks = function(self)
		RegisterEvent("OnMapRestart", self.CheckForGarbage, 'GarbageCollector');
	end;
	-----------------
	CheckForGarbage = function(self)
		--System.LogAlways("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TRRASH")
		local trashCounter = 0;
		for i, entity in ipairs(System.GetEntities()or{}) do
			for j, flag in pairs(self.toDeleteFlags or {ENTITY_FLAG_CLIENT_ONLY}) do
				if (entity:HasFlags(flag)) then
					System.RemoveEntity(entity.id);
					trashCounter = trashCounter + 1;
				end;
			end;
		end;
		SysLog("Found %d trash entities", trashCounter)
	end;
};

GarbageCollector:InitHooks();