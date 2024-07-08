ATOM_Client = {
	cfg = {},
	-----------
	-- Init
	Init = function(self)

		-- Logging
		self:Log(0, "Initializing PAK Client ...")
		
		-- Tell ATOMClient the atom client pak was loaded
		CLIENT_MOD_ENABLED = true

		-- Register New Models
		self:AddNewModels()
		
		-- Add New Custom Gun Sounds
		self:AddWeaponSounds()

		-- Logging
		self:Log(0, "PAK Client Initialized")
		
	end,
	-----------
	-- Shutdown
	Shutdown = function(self)
		
		CLIENT_MOD_ENABLED = false
	
	end,
	-----------
	-- AddWeaponSounds
	AddWeaponSounds = function(self)
		
		CUSTOM_WEAPON_SOUNDS = {
			["SOCOM"] = { vol = 0.75, tp = "sounds/weapons/Beretta92FS:fire_tp:fire_tp", fp = "sounds/weapons/Beretta92FS:fire:fire", Silencer = { tp = "sounds/weapons:socom:fire_silenced", fp = "sounds/weapons/Beretta92FS:fire_silenced:fire_silenced" } },
		}
		
		self:Log(0, "Registered %d New Weapon Sounds", table.count(CUSTOM_WEAPON_SOUNDS))
	
	end,
	-----------
	-- AddNewModels
	AddNewModels = function(self)

		FEMALE_NANOSUIT_PATH = "objects/characters/woman/nanosuit_female/nanosuit_female.cdf"

	end,
	-----------
	-- Log
	Log = function(self, iVerbosity, sMsg, ...)
		
		local sMsg = tostring(sMsg)
		if (...) then
			sMsg = string.format(sMsg, ...)
		end

		if (iVerbosity > ATOMClient.LogVerbosity) then
			return
		end

		System.LogAlways("$9[$7ATOM$9] " .. tostring(sMsg))
	
	end,
};

ATOM_Client:Init();