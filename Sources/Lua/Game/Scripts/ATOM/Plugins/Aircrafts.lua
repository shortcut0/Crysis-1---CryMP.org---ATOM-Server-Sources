ATOMAircrafts = {
	cfg = {
		Positions = {
			["Airport"] = {
				["multiplayer/ps/mesa"] = makeVec(1913, 178, 378),
			};
		};
	},
	--------------------
	Init = function(self)
		
	end,
	--------------------
	CheckAircraft = function(self, aircraft)
		
	end,
	--------------------
	IsAtAirport = function(self, player)
	
		local pos = self.cfg.Positions["Airport"];
		if (not pos) then
			return false--, "invalid position";
		end;
		pos = pos[g_dll:GetMapName():lower()];
		if (not pos) then
			return false--, "unsupported map";
		end;
		
		return GetDistance(player:GetPos(), pos) < 250
		
	end,
	--------------------
	TeleportPlayer = function(self, player, where)
		local pos = self.cfg.Positions[where];
		if (not pos) then
			return false, "invalid position";
		end;
		pos = pos[g_dll:GetMapName():lower()];
		if (not pos) then
			return false, "unsupported map";
		end;
		g_utils:SpawnEffect(ePE_AlienBeam, player:GetPos());
		Script.SetTimer(1000, function()
			g_game:MovePlayer(player.id, pos, player:GetAngles());
			g_utils:SpawnEffect(ePE_Light, pos);
			SendMsg(CHAT_ATOM, ALL, "(%s: Teleported to the Airfield (!airport))", player:GetName());
			SendMsg(CHAT_ATOM, player, "Use !buyjet <Index> To Buy a New Aircraft!", player:GetName());
		end);
	end,
	--------------------
	SpawnAircraft = function(self, player, airType, special)
		Script.SetTimer(1, function()
			local vtol = System.SpawnEntity({ class = "US_vtol", name = "US_vtol_" .. g_utils:SpawnCounter(), position = fixPos(player:CalcSpawnPos(15)), orientation = player:GetDirectionVector(), properties = {} });
			if (vtol) then
				Script.SetTimer(500, function()
					RCA:MakeJet(vtol, airType, special);
				end);
			end;
		end);
		SendMsg(CHAT_ATOM, player, "Here is your Aircraft");
	end,
	--------------------
};

ATOMAircrafts:Init();