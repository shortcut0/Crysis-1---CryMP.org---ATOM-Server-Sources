ATOMSquad = {

	------------------------------
	--          Config
	------------------------------

	TeamLeaders = {
		[1] = nil, -- US
		[2] = nil, -- NK
	},

	Last_Effect = 0,
	
	MinTeamPlayers = 4,
	
	------------------------------
	--          Init
	------------------------------
	
	Init = function(self)
		RegisterEvent("OnChangeSpectatorMode", 	self.Server.OnChangeSpectatorMode, 	"ATOMSquad.Server");
		RegisterEvent("OnRevive", 				self.Server.OnRevive,				"ATOMSquad.Server");
	end,
	
	------------------------------
	--          Server
	------------------------------

	Server = {
		
		OnRevive = function(self, player, groupId, group)
			Debug("[squad] ", player:GetName(), "revied on", group.class);
			
			if (group and group.actor and player.id ~= group.actor.id) then
				g_gameRules:AwardPPCount(player.id, 10);	
				if (not self.Last_Effect or _time - self.Last_Effect > 5) then
					local pos = group:GetPos();
					if (g_gameRules.inCaptureZone and g_gameRules.inCaptureZone[group.id]) then
						--pos.z = pos.z + 100;
						Debug("[squad] spawn in buy zone !!");
					end						
					SpawnEffect("alien_special.Hunter.Pre_Self_Destruct_body", pos, g_Vectors.up, 1); 
					self.Last_Effect = _time;							
				end
			end
		end,
		
		OnChangeSpectatorMode = function(self, player)
			Debug("[squad] ", player:GetName(), "went spectating");
			self:Disable(player, "went spectating");
		end,
	
	},
	
	OnTick = function(self)
		local teamLeaders = self.TeamLeaders;
		if (teamLeaders) then
			local leader, players;
			for teamId, playerId in pairs(teamLeaders) do
				leader = GetEnt(playerId);
				if (leader) then
					players = GetPlayersByTeam(teamId);
					if (players) then
						for i, player in pairs(players) do
							if (player.id == playerId) then	
								local vehicle = player:GetVehicle();
								if (vehicle) then
									SendMsg(INFO, player, "TEAM:LEADER - Players might spawn in your %s", vehicle.class);
								else
									SendMsg(INFO, player, "TEAM:LEADER - Players might spawn near you");
								end
							else
								SendMsg(INFO, player, "TEAM:LEADER - Our Team Leader -[ " .. leader:GetName() .. " ]");
							end
						end
					end
				else
					self:Disable(false, "disconnected", teamId);
				end;
			end;
		end;
		
	end,
	
	Disable = function(self, player, why, teamId)
	
		local teamId = teamId or player:GetTeam();
		if (teamId > 0 and self.TeamLeaders[teamId] and (not player or player.id == self.TeamLeaders[teamId])) then
			g_gameRules.game:RemoveSpawnGroup(self.TeamLeaders[teamId]);
			self.TeamLeaders[teamId] = nil;
			if (player) then
				SendMsg(INFO, GetPlayersByTeam(teamId), "TEAM:LEADER - %s in no longer the Team Leader ( %s )", player:GetName(), why);
			else
				SendMsg(INFO, GetPlayersByTeam(teamId), "TEAM:LEADER - we lost our Team Leader ( %s )", why);
			end;
		end;
		
	end,
	
	Enable = function(self, player)
	
		local teamId = player:GetTeam();
		if (teamId > 0) then
			g_gameRules.game:AddSpawnGroup(player.id);
			self.TeamLeaders[teamId] = player.id;
			SendMsg(INFO, GetPlayersByTeam(teamId), "TEAM:LEADER - %s in the new Team Leader", player:GetName());
		end;
		
	end,
	

};