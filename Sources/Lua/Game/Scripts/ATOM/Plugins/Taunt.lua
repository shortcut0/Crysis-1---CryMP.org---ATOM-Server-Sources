
-- Model ID Ids (for easier editing LOL)
MODELID_NANOSUIT_NK		= -1;
MODELID_KOREAN_KYONG	= 1;
MODELID_KOREAN_SOLDIER 	= 2;
MODELID_AI_AZTEC	 	= 3; -- Doesn't have private sound folder, L
MODELID_AI_JESTER	 	= 4;
MODELID_AI_SYKES	 	= 5;
MODELID_AI_PROPHET	 	= 6;
MODELID_AI_PSYCHO	 	= 7;
MODELID_AI_KEEGAN	 	= 10;
MODELID_AI_BRADLEY	 	= 13;
MODELID_AI_EGIRL	 	= 2000;


ATOMTaunt = {
	cfg = {
		System = false;
		Sounds = {
			ThrowFrag = {
				SoundName = "grenade_",
				SoundRange = { "00", "01", "02", "03", "04" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundName = "grenade_", FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { SoundName = "grenade_", FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { SoundName = "grenade_", FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { SoundName = "grenade_", SoundRange = { "00", "01", "03", "04" }, FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { SoundName = "grenade_", FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { SoundName = "grenade_", SoundRange = { "00", "01", "02", "03", "04" }, FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { SoundName = "incominggrenade_", SoundRange = { "00", "01", "02", "03", "04", "05" }, FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { SoundName = "grenade_", FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { SoundName = "grenade_", FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { SoundName = "incominggrenade_", FolderName = "ai_korean_soldier", 	FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0001", "_pu0002", "_pu0003" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			IncomingFrag = {
				SoundName = "incominggrenade_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = nil, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			ReloadingWeapon = {
				SoundName = "reloading_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundName = "contactreply_", SoundRange = { "02", "04", "05" }, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_marine", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_marine", 	FolderRange = { "_3" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			TargetKilled = {
				SoundName = "targetdown_",
				SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10" , "11" , "12" , "13" , "14" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"}, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { SoundName = "targetdownreply_", FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { SoundName = "targetdownreply_", FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { SoundName = "targetdownreply_", FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"}, FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			AllTargetsKilled = {
				SoundName = "alldead_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundName = "contactgroup_", SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08","09"}, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { SoundName = "combatgroup_", SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08","09"}, FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { SoundName = "combatgroup_", SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"}, FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012", "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			TargetKilled_Reply = {
				SoundName = "targetdownreply_",
				SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10" , "11" , "12" , "13" , "14" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"},SoundName="targetdown_",FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"},FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { SoundRange = {"00", "01", "02", "03", "04", "05", "06", "07", "08"}, FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			Death = {
				SoundName = "death_",
				SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			AllyDied = {
				SoundName = "aidowngroup_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_marine", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_marine", 	FolderRange = { "_3" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			Melee = {
				SoundName = "meleedeath_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" }, SoundName = "death_", FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" }, SoundName = "death_", FolderName = "ai_prophet", 	FolderRange = { "_3" } },
					[MODELID_AI_PSYCHO] 		= { SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" }, SoundName = "death_", FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			FriendlyFire = {
				SoundName = "friendlyfire_",
				SoundRange = { "00", "01", "02", "03", "04", "05" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundName = "bulletrain_", FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { SoundName = "bulletrain_", FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_major_bradley", 	FolderRange = { "" } },
					[MODELID_NANOSUIT_NK] 		= { SoundName = "alertthreatreply_", FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			Falling = {
				SoundName = "fallingdeath_",
				SoundRange = { "00", "01", "02", "03", "04" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_marine", 	FolderRange = { "_3" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = { "_pu0009", "_pu00010","_pu00011","_pu00012" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};

			-----------
			UsingMG = {
				SoundName = "mountedweapon_",
				SoundRange = { "00", "01", "02", "03" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" },SoundName = "contactgroup_", FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { SoundName = "callinghelp_", FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { SoundName = "contactsoloclose_", FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};

			-----------
			C4Explosive = {
				SoundName = "explosionimminent_",
				SoundRange = { "00", "01", "02", "03" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = nil, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1_suit", "_02_suit", "_3_suit" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
			-----------
			BulletRain = {
				SoundName = "bulletrain_",
				SoundRange = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09" },
				FolderName = "ai_marine",
				FolderRange = { "", "_1", "_2", "_3" },
				ModelSpecific = {
					[MODELID_KOREAN_KYONG] 		= { SoundRange = nil, FolderName = "ai_kyong", 			FolderRange = { "" } },
					[MODELID_KOREAN_SOLDIER] 	= { FolderName = "ai_korean_soldier", 	FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_AZTEC] 			= { FolderName = "ai_marine", 			FolderRange = { "_2" } },
					[MODELID_AI_JESTER] 		= { FolderName = "ai_jester", 			FolderRange = { "" } },
					[MODELID_AI_SYKES] 			= { FolderName = "ai_marine", 			FolderRange = { "_1" } },
					[MODELID_AI_PROPHET] 		= { FolderName = "ai_prophet", 	FolderRange = { "" } },
					[MODELID_AI_PSYCHO] 		= { FolderName = "ai_psycho", 	FolderRange = { "" } },
					[MODELID_AI_KEEGAN] 		= { FolderName = "ai_marine", 	FolderRange = { "" } },
					[MODELID_AI_BRADLEY] 		= { FolderName = "ai_marine", 	FolderRange = { "_2" } },
					[MODELID_NANOSUIT_NK] 		= { FolderName = "ai_korean_soldier", FolderRange = { "_1", "_2", "_3" } },
					[MODELID_AI_EGIRL] 			= { SoundName = "helena_mine_ab4", SoundRange = {"_pu0009", "_pu00010","_pu00011","_pu00012",  "_pu0004" }, FolderName = "mine", 	FolderRange = { "" } },
				}
			};
		};
	};
	DebugMode = true,
	trackedNades = {},
	-------------------
	--     Init
	-------------------
	Init = function(self)
	
		-- Debug
		if (isNull(TAUNT_SYSTEM)) then
			TAUNT_SYSTEM = true end
		
		-- Assign Config
		self.cfg = mergeTables(self.cfg, ATOM.cfg.Immersion.Taunt)
		
		-- Init Cases
		eAT_EventGrenade 		= 00; -- Throw Frag
		eAT_EventReload 		= 01; -- Reloading Weapon
		eAT_EventFrag	 		= 02; -- Incoming Frag
		eAT_EventKilled	 		= 03; -- Player Killed an enemy
		eAT_EventAllyDied		= 04; -- Player Ally Died
		eAT_EventAllDead		= 05; -- All nearby enemies killed
		eAT_EventFlashbang		= 06; -- Player got flashbanged
		eAT_EventBulletRain		= 07; -- Player is in bulletrain
		eAT_EventRushIn			= 08; -- Player is rushing to enemies (HOW U GONNA DO THIS????)
		eAT_EventFalling		= 09; -- Player is falling down
		eAT_EventAllyFire		= 10; -- Player is getting shot at by an ally
		eAT_EventMG				= 11; -- Player is using MG
		eAT_EventBattle			= 12; -- Player screaming at enemy during combat
		eAT_EventDied			= 13; -- Player died (lol, noob)
		eAT_EventKilledReply	= 14; -- Player replies to someone who killed an enemy
		eAT_EventC4				= 15; -- Player placed a C4
		eAT_MeleeHit			= 16; -- Player placed a C4
		
		self:InitHooks();
	end,
	-------------------
	--   InitHooks
	-------------------
	InitHooks = function(self)
		RegisterEvent("OnShoot", self.OnShoot, 'ATOMTaunt');
		RegisterEvent("OnTick", self.CheckNades, 'ATOMTaunt');
		RegisterEvent("CanUseItem", self.OnUseItem, 'ATOMTaunt');
		--RegisterEvent("OnKill", self.OnKill, self);
	end,
	-------------------
	-- OnProjectileExplosion
	-------------------
	OnProjectileExplosion = function(self, weaponClass, projectileId)
		if (self.trackedNades[projectileId]) then
			self.trackedNades[projectileId] = nil;
		end;
	end,
	-------------------
	--    OnUseItem
	-------------------
	OnUseItem = function(self, player, item)
		if (item.item:IsMounted() and not player.UsingItem) then
			self:OnEvent(eAT_EventMG, player);
		end;
		if (player.UsingItem) then
			player.UsingItem = false;
		else
			player.UsingItem = true;
		end;
		--Debug(player.UsingItem)
	end,
	-------------------
	--   CheckNades
	-------------------
	CheckNades = function(self)
	
		if (not TAUNT_SYSTEM) then
			return end

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end


		--Debug("OK")
		if (arrSize(self.trackedNades) > 0) then
			--Debug("Si SI")
			for nadeId, nadeInfo in pairs(self.trackedNades) do
				Debug(nadeId)
				local nadePos = g_dll:GetProjectilePosition(nadeId);
				--Debug(_time - nadeInfo.SpawnTime)
				if (nadePos) then
					if (_time - nadeInfo.SpawnTime > 0.8) then
					--Debug("Si")
						local inRange = GetPlayersInRange(nadePos, 8);
						if (arrSize(inRange) > 0) then
							Debug("In range",GetRandom(inRange):GetName())
							self:OnEvent((nadeInfo.C4 and eAT_EventC4 or eAT_EventFrag), GetRandom(inRange));
							self.trackedNades[nadeId] = nil;
						end;
					end;
				else
					--Debug("No")
					self.trackedNades[nadeId] = nil;
				end;
			end;
		end;
		for i, player in pairs(GetPlayers()) do
			if (player.actor:IsFlying() and player:GetPos().z > CryAction.GetWaterInfo(player:GetPos()) and not player:IsDead() and not player:IsSpectating()) then
				player.FallTime = (player.FallTime or 0) + 1;
			else
				player.FallTime = 0;
			end;
			if (player.FallTime > 6 and not player.JetPackPaticles and not player.chair) then
				self:OnEvent(eAT_EventFalling, player);
				--SysLog("Falling time %f", player.FallTime*1.0)
			end;
		end;
		--Debug("Complete")
	end,
	-------------------
	--   OnShoot
	-------------------
	OnShoot = function(self, shooter, weapon, pos, dir, hit, hitNormal, distance, bTerrain, ammoClass, ammoId)

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end

		if (shooter.isPlayer and not shooter:IsAFK()) then
			local grenade = ammoClass == "explosivegrenade" or ammoClass == "scargrenade";
			if (grenade and isEntityId(ammoId)) then
				self.trackedNades[ammoId] = { SpawnTime = _time, team = g_game:GetTeam(shooter.id) };
				if (shooter.isPlayer) then
					self:OnEvent(eAT_EventGrenade, shooter, pos);
				end;
			elseif (shooter.LastShot and GetDistance(shooter:GetPos(), hit) > 10) then
				if (_time - shooter.LastShot < 0.2) then
					shooter.BulletRain = (shooter.BulletRain or 0) + 1;
				else
					shooter.BulletRain = 0;
				end;
				if (shooter.BulletRain > 3) then
					--local inRange = GetPlayersInRange(hit, 3, shooter.id, (shooter:GetTeam()==2 and 1 or 2), true);
					local inRange = DoGetPlayers({ OnlyAlive = true, pos = hit, range = 7.5, teamId = (shooter:GetTeam() == 2 and 1 or 2), sameTeam = true})
					if (table.count(inRange) > 0) then
						self:OnEvent(eAT_EventBulletRain, GetRandom(inRange))
					end
					--Debug(#inRange)
				end
			end
		end
	end,
	-------------------
	-- OnExplosivePlaced
	-------------------
	OnExplosivePlaced = function(self, player, C4)
		self:OnEvent(eAT_EventC4, player);
		self.trackedNades[C4.id] = { SpawnTime = _time - 1, C4 = true };
	end,
	-------------------
	--   OnKilled
	-------------------
	OnKilled = function(self, shooter, target)

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end

		if (not TAUNT_SYSTEM) then
			return end
	
		if (shooter.isPlayer and not shooter:IsAFK()) then
			if (shooter.isPlayer and not sameTeam(shooter.id, target.id)) then
				
				--local near = arrSize(GetPlayersInRange(target:GetPos(), 50, target.id, g_game:GetTeam(target.id), true));
				--Debug(near)

				local aNearbyEnemies = DoGetPlayers({ AllActors = true, except = shooter.id, teamId = g_game:GetTeam(shooter.id), sameTeam = false, pos = target:GetPos(), range = 40, OnlyAlive = true})
				local aNearbyAllies = DoGetPlayers({ except = shooter.id, teamId = g_game:GetTeam(shooter.id), sameTeam = true, pos = shooter:GetPos(), range = 35, OnlyAlive = true})
				local iHostile = table.count(aNearbyEnemies)
				local iAllies = table.count(aNearbyAllies)

			--	Debug("iHostile",iHostile)
			--	Debug("iAllies",iAllies)

				if (shooter ~= target) then
					if (iHostile > 0) then
						self:OnEvent(eAT_EventKilled, shooter)
					else
						self:OnEvent(eAT_EventAllDead, shooter)
					end
				end
				--local inRange = GetPlayersInRange(shooter:GetPos(), 35, shooter.id, g_game:GetTeam(shooter.id), true);
				if (iAllies > 0) then
					Script.SetTimer(800, function()
						self:OnEvent(eAT_EventKilledReply, GetRandom(aNearbyAllies));
					end);
				end;
			end;
		end;
		if (target.isPlayer) then
			self:OnEvent(eAT_EventDied, target);
			local allyInRange = GetPlayersInRange(target:GetPos(), 20, target.id, g_game:GetTeam(target.id), true);
			if (arrSize(allyInRange) > 0) then
				self:OnEvent(eAT_EventAllyDied, GetRandom(allyInRange));
			end;
		end;
	end,
	-------------------
	--   OnHit
	-------------------
	OnHit = function(self, hShooter, target, weapon)

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end

		if (not TAUNT_SYSTEM) then
			return end
	
		if (hShooter and hShooter.IsAFK and not hShooter:IsAFK() and target and hShooter.isPlayer and target.isPlayer) then
			if (sameTeam(hShooter.id, target.id) and hShooter.id ~= target.id) then
				self:OnEvent(eAT_EventAllyFire, target)
			elseif (not sameTeam(hShooter.id, target.id) and weapon and weapon.class == "Fists") then
				self:OnEvent(eAT_MeleeHit, target)
			end
		end
	end,
	-------------------
	--   OnEvent
	-------------------
	OnEvent = function(self, event, sender, p2, p3)

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end

		if (not sender.isPlayer or sender:IsSpectating()) then
			return;
		end;
		if (sender:IsSpectating() or sender:IsAFK()) then
			return;
		end;
		local bForce = false
		local soundInfo;
		local doPlay = self.DebugMode or not self:Alone(sender, 40);
		if (event == eAT_EventGrenade) then
		--	Debug(sender:GetName(),"throw nade");
			if (doPlay) then
				soundInfo = self.cfg.Sounds.ThrowFrag;
			end;
		elseif (event == eAT_EventReload) then
		--	Debug(sender:GetName(),"reloading gun")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.ReloadingWeapon;
			end;
		elseif (event == eAT_EventFrag) then
		--	Debug(sender:GetName(),"Frag incoming")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.IncomingFrag;
				--Debug("Incoming!")
			end;
		elseif (event == eAT_EventKilled) then
			--Debug(sender:GetName(),"enemy killed")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.TargetKilled;
			end;
		elseif (event == eAT_EventAllDead) then
		--	Debug(sender:GetName(),"all enemies killed")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.AllTargetsKilled;
			end;
		elseif (event == eAT_EventKilledReply) then
		--	Debug(sender:GetName(),"reply to enemy killed")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.TargetKilled_Reply;
			end;
		elseif (event == eAT_EventDied) then
			--Debug(sender:GetName(),"death")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.Death;
				bForce = true
			end;
		elseif (event == eAT_EventAllyDied) then
		--	Debug(sender:GetName(),"ally died")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.AllyDied;
			end;
		elseif (event == eAT_EventAllyFire) then
			--Debug(sender:GetName()," friendly fire")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.FriendlyFire;
			end;
		elseif (event == eAT_EventFalling) then
		--	Debug(sender:GetName(),"falling")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.Falling;
			end;
		elseif (event == eAT_EventMG) then
		--	Debug(sender:GetName(),"using MG")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.UsingMG;
			end;
		elseif (event == eAT_EventC4) then
		--	Debug(sender:GetName(),"using MG")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.C4Explosive;
			end;
		elseif (event == eAT_EventBulletRain) then
			--Debug(sender:GetName(),"bullet rain")
			if (doPlay) then
				soundInfo = self.cfg.Sounds.BulletRain;
			end;
		end;
		
		if (soundInfo) then
			self:PlayTauntSound(sender, soundInfo, bForce);
		else
			Debug("NO INFO FOR EVENT ",event,"!!!!!!")
		end;
	end,
	-------------------
	--    Alone
	-------------------
	Alone = function(self, player, range)
		return arrSize(GetPlayersInRange(player:GetPos(), (range or 30), player.id)) == 0;
	end,
	-------------------
	-- GetRandom
	-------------------
	GetRandom = function(self, strId, t)
		self.LastAssignedIds = self.LastAssignedIds or {};
		local last = self.LastAssignedIds;
		local R;
		if (not last or not last[strId]) then
			--Debug(t)
			R = GetRandom(t);
			self.LastAssignedIds[strId] = { [R] = true };
			return R;
		end;
		if (arrSize(last[strId]) == arrSize(t)) then -- all slots already used, SHIT :D
			return GetRandom(t);
		end;
		for i, v in pairs(t) do
			if (not self.LastAssignedIds[strId][v]) then
				self.LastAssignedIds[strId][v] = true;
		--		Debug("Choosed random",v)
				return v;
			end;
		end;
		return GetRandom(t);
	end,
	-------------------

	GetRandom = function(self, hSender, iModel, sType, aSounds)

		if (not self.PlayedSounds) then
			self.PlayedSounds = {}
		end

		if (not self.PlayedSounds[hSender.id]) then
			self.PlayedSounds[hSender.id] = {}
		end

		if (not self.PlayedSounds[hSender.id][iModel]) then
			self.PlayedSounds[hSender.id][iModel] = {}
		end

		if (not self.PlayedSounds[hSender.id][iModel][sType]) then
			self.PlayedSounds[hSender.id][iModel][sType] = {}
		end

		local sRandom
		local iSounds = table.count(aSounds)
		if (iSounds == 1) then
			return GetRandom(aSounds)
		end

		local aPlayed = self.PlayedSounds[hSender.id][iModel][sType]
		if (table.count(aPlayed) == table.count(aSounds)) then
			sRandom = GetRandom(aSounds)
			self.PlayedSounds[hSender.id][iModel][sType] = { [sRandom] = true }
			return sRandom
		end

		for i = 1, iSounds do
			sRandom = GetRandom(aSounds)
			if (not aPlayed[sRandom]) then
				break
			end
		end

		self.PlayedSounds[hSender.id][iModel][sType][sRandom] = true
		return sRandom
	end,

	-------------------
	-- PlayTauntSound
	-------------------
	PlayTauntSound = function(self, hSender, aInfo, bForce)

		if (not GetBetaFeatureStatus("taunt")) then
			return
		end

		if (not self.cfg.System and not TAUNT_SYSTEM) then
			return
		end

		local sSoundName = aInfo.SoundName
		local aSoundRange = aInfo.SoundRange

		local sFolderName = aInfo.FolderName
		local aFolderRange = aInfo.FolderRange

		local iCustom = (hSender.iForcedTauntID or (hSender.CM and hSender.CM > 0 and hSender.CM) or hSender.TCM)
		if (not iCustom and g_gameRules.class == "PowerStruggle" and hSender:GetTeam() == 1) then
			iCustom = MODELID_NANOSUIT_NK
		end

		local sFinalSound, sFinalFolder

		local aCustoms = aInfo.ModelSpecific
		local aCustom
		if (aCustoms and iCustom and iCustom ~= 0) then
			aCustom = aCustoms[iCustom]
		end

		local aForced = hSender.aForcedTaunts
		if (aForced) then

			sSoundName = checkVar(aForced.SoundName, sSoundName)
			aSoundRange = checkVar(aForced.SoundRange, aSoundRange)

			sFolderName = checkVar(aForced.FolderName, sFolderName)
			aFolderRange = checkVar(aForced.FolderRange, sFolderRange)

			sFinalSound = sSoundName .. (self:GetRandom(hSender, iCustom, sSoundName, checkArray(aSoundRange, {""})))

		elseif (aCustom) then

			sSoundName = checkVar(aCustom.SoundName, sSoundName)
			aSoundRange = checkVar(aCustom.SoundRange, aSoundRange)

			sFolderName = checkVar(aCustom.FolderName, sFolderName)
			aFolderRange = checkVar(aCustom.FolderRange, sFolderRange)

			sFinalSound = sSoundName .. (self:GetRandom(hSender, iCustom, sSoundName, checkArray(aSoundRange, {""})))

			if (iCustom ~= hSender.iLastCustom) then
				hSender.sTauntVoiceFolderCM = {}
			end
			hSender.iLastCustom = iCustom

			if (not hSender.sTauntVoiceFolderCM) then
				hSender.sTauntVoiceFolderCM = {}
			end
			if (not hSender.sTauntVoiceFolderNameCM) then
				hSender.sTauntVoiceFolderNameCM = {}
			end

			if (hSender.sTauntVoiceFolderCM[iCustom]) then
				sFinalFolder = hSender.sTauntVoiceFolderCM[iCustom]
				if (hSender.sTauntVoiceFolderNameCM[iCustom] ~= sFolderName) then
					sFinalFolder = nil
				end
			end

			if (string.empty(sFinalFolder)) then
				sFinalFolder = sFolderName  .. (GetRandom(checkArray(aFolderRange, {""})))
				hSender.sTauntVoiceFolderCM[iCustom] = sFinalFolder
				hSender.sTauntVoiceFolderNameCM[iCustom] = sFolderName
			end
		else

			if (not sSoundName or not sFolderName) then
				return SysLog("No Sound Name or Folder")
			end

			sFinalSound = sSoundName .. (self:GetRandom(hSender, 999, sSoundName, checkArray(aSoundRange, {""})))
			if (hSender.sTauntVoiceFolder) then
				sFinalFolder = hSender.sTauntVoiceFolder
			else
				sFinalFolder = sFolderName  .. (GetRandom(checkArray(aFolderRange, {""})))
				hSender.sTauntVoiceFolder = sFinalFolder
			end
		end

		local sClientSound = sFinalFolder .. "/" .. sFinalSound

		if (timerexpired(hSender.hTimerLastTaunt, (bForce and 1 or 6)) and not hSender:IsSpectating() and (not hSender:IsDead() or bForce)) then
			--SysLog("Playing Taunt Sound %s on %s", sClientSound, hSender:GetName())
			ExecuteOnAll("HE(eCE_ATOMTaunt,\"" .. hSender:GetName() .. "\", \"" .. sClientSound .. "\");")
			hSender.hTimerLastTaunt = timerinit()
		end
	end,
};

ATOMTaunt:Init();