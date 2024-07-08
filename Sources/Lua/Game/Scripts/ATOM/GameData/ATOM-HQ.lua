ATOMHQ = {
	cfg = {
		-- If true, will enable new HQ settings
		CustomHQSettings = true,
		
		-- How many TAC Hits it requires to destroy a HQ
		TacHits = 5,
		
		-- If true, HQs will be undestroyable
		HQUndestroyable = true,
		
		-- If >0, HQ cann#t be destroyed before this amount of time
		AttackDelay = 30 * 60, -- 30 Minutes
		
		-- If true, will send info message if HQ was hit
		InfoMessage = true,
		
		-- Reward for hitting HQs
		RewardOnHit = {
			PP = 500,
			CP = 100,
		},
		
	},
	---------------------
	Init = function(self)
		local ents = System.GetEntitiesByClass("HQ");
		if (ents) then
			for i, ent in pairs(ents) do
				if (ent and ent.Server and (type(ent.Server)=="table")) then
					--set metatable
					local metatb = getmetatable(ent);
					if (metatb and metatb.Server and (type(metatb.Server)=="table") and metatb.Server.OnHit) then
						metatb.Server.OnHit = self.OnHQHit;
						--System.LogAlways("$6MetaHQTB OnHit Hooked");
					end
					--set playertables
					if (ent.Server.OnHit) then
						ent.Server.OnHit = self.OnHQHit;
						--System.LogAlways("$6HQTB OnHit Hooked");
					end
					ent.RemainingHits = ent.RemainingHits or 0;
				end
			end
		end;
	end;
	---------------------
	GetStatus = function(self, team)
		local NK_HQS, US_HQS = {}, {};
		for i, v in pairs(System.GetEntitiesByClass("HQ")or{}) do
			if (g_game:GetTeam(v.id) == 2) then
				table.insert(US_HQS, v);
			else
				table.insert(NK_HQS, v);
			end;
		end;
		local HQ_NK = NK_HQS[1];
		local HQ_US = US_HQS[1];
		
		return "(HQ-STATUS: NK - " .. HQ_NK.RemainingHits .. " | US - " .. HQ_US.RemainingHits .. ")"
	end,
	---------------------
	OnHit = function(self, hit, hq)
		local shooter = hit.shooter;
		if (self.cfg.CustomHQSettings) then
			local teamId = g_gameRules.game:GetTeam(hit.shooterId) or nil;
			if (teamId and (teamId==0 or teamId~=hq:GetTeamId()) and hit.explosion and hit.type and hit.type=="tac") then --if tac hit

				local team = (hq:GetTeamId() == 2) and "US" or "NK";
				if (self.cfg.HQUndestroyable and not shooter.megaGod) then
					SendMsg(ERROR, ALL, "** HQs NOT DESTROYABLE **");
					SendMsg(_G["CHAT_TEAM"..team:upper()], shooter, "(HQ: Not Destroyable in this Session)");
					hit.damage = 0;
					return;
				end
				if (not shooter.megaGod and self.cfg.AttackDelay > 0 and MapStartTime + self.cfg.AttackDelay > _time) then
					local rem = calcTime((MapStartTime + self.cfg.AttackDelay) - _time, true, unpack(GetTime_SM));
					SendMsg(ERROR, ALL, "** HQ CURRENTLY UNDESTROYABLE **");
					--Debug(_G["CHAT_TEAM"..team:upper()])
					SendMsg(_G["CHAT_TEAM"..team:upper()], shooter, "(HQ: Destroyable in %s)", rem);
					hit.damage = 0;
					return;
				end

				hit.damage = math.ceil(hq.Properties.nHitPoints / self.cfg.TacHits);
				local newhealth = (hq:GetHealth() - hit.damage);
				local neededhits = (newhealth / hit.damage);
				local shooterName = hit.shooter:GetName() or "N/A";
				local reward = self.cfg.RewardOnHit;
				local pp = 500;
				local cp = 100;
				
				HQ.RemainingHits = neededhits;
				
				if (reward) then
					pp = self.cfg.RewardOnHit[1] or self.cfg.RewardOnHit.PP or 0;
					cp = self.cfg.RewardOnHit[2] or self.cfg.RewardOnHit.CP or 0;
					if ((pp > 0 or cp > 0)) then
						shooter:GivePrestige(pp);
						shooter:GiveCP(cp);
						--g_gameRules.game:SendTextMessage(TextMessageInfo, "***Special-Award for Base Attack  +["..pp.."]PP  +["..cp.."]CP***", TextMessageToClient,hit.shooter.id);
					end
					pp = (pp or 0) * (shooter:HasAccess(PREMIUM) and 2 or 1);
					cp = (cp or 0) * (shooter:HasAccess(PREMIUM) and 2 or 1);
				end
				
				local sTeamPlayers = GetPlayersByTeam(g_game:GetTeam(hit.shooter.id), true);
				local oTeamPlayers = GetPlayersByTeam(g_game:GetTeam(hit.shooter.id), false);

				if (self.cfg.InfoMessage) then
					if (neededhits > 0) then
						
						SendMsg(ERROR, sTeamPlayers, "** ENEMY HQ HIT BY :: %s %s**", shooterName, (reward and "- GOT " .. pp .. " PRESTIGE "or""));
						SendMsg(ERROR, oTeamPlayers, "** OUR HQ WAS HIT BY :: %s - [ %d ] - HITS REMAINING **", shooterName, neededhits);
						
						SendMsg(BLE_INFO,  sTeamPlayers, "%s: Hit the Enemy HQ - %d Hits Remaining", shooterName, neededhits); 
						SendMsg(BLE_ERROR, oTeamPlayers, "%s: Hit our HQ - %d Hits Remaining", shooterName, neededhits); 
						
						SendMsg(team == "US" and CHAT_TEAMNK or CHAT_TEAMUS, sTeamPlayers, "%s: Hit the Enemy HQ - %d Hits Remaining %s", shooterName, neededhits, (reward and "(GOT " .. pp .. " PRESTIGE)"or"")); 
						SendMsg(team == "US" and CHAT_TEAMUS or CHAT_TEAMNK, oTeamPlayers, "%s: Hit our HQ - %d Hits Remaining", shooterName, neededhits); 
						
						ATOMLog:LogHQHit(sTeamPlayers, "%s$9 Hit the Enemy HQ %s($4%d Hits Remaining$9)", shooterName, (reward and "and got $4" .. pp .. "$9 PRESTIGE "or""), neededhits);
						ATOMLog:LogHQHit(oTeamPlayers, "%s$9 Hit our HQ ($4%d Hits Remaining$9)", shooterName, neededhits);
						
					elseif (neededhits <= 0 and newhealth <=0) then
					
						SendMsg(ERROR, sTeamPlayers, "** ENEMY HQ HAS BEEN DESTROYED BY :: %s **", shooterName);
						SendMsg(ERROR, oTeamPlayers, "** OUR HQ WAS DESTROYED BY :: %s **", shooterName); 
						
						SendMsg(team == "US" and CHAT_TEAMNK or CHAT_TEAMUS, sTeamPlayers, "%s: Destroyed the Enemy HQ", shooterName); 
						SendMsg(team == "US" and CHAT_TEAMUS or CHAT_TEAMNK, oTeamPlayers, "%s: Destroyed our HQ", shooterName); 
						
						ATOMLog:LogHQHit(sTeamPlayers, "%s$9 Destroyed the Enemy HQ", shooterName);
						ATOMLog:LogHQHit(oTeamPlayers, "%s$9 Destroyed our HQ", shooterName);
					end
				end
			end
		end

		ATOMBroadcastEvent("OnHQHit", hit, HQ);
	end,
	---------------------
	OnHQHit = function(self, hit) -- note: 'self' is not ATOMHQ but the HQ itself
		--Debug("HAQ HIT")
		if (self.destroyed) then
			return
		end

		if (not hit.shooter) then
			return
		end
		
		SysLog("HQ[%s] Was hit by [%s] (damage = %f, weapon = %s)", self:GetName(), hit.shooter:GetName(), hit.damage or 0.0, (hit.weapon and hit.weapon.class or "No WEAPON"));

		-- !hook
		ATOMHQ.OnHit(ATOMHQ, hit, self);

		local destroyed = false;
		-- check if destroyed, decrease health if needed
		local teamId = g_gameRules.game:GetTeam(hit.shooterId);
		if (teamId == 0 or teamId ~= self:GetTeamId()) then
			if (hit.explosion and hit.type=="tac") then
				self:SetHealth(self:GetHealth()-hit.damage);
				if (self:GetHealth()<=0) then
					destroyed=true;
				end

				if (hit.damage>0 and hit.type ~= "repair") then
					if (g_gameRules.Server.OnHQHit) then
						g_gameRules.Server.OnHQHit(g_gameRules, self, hit);
					end
				end
			end
		end

		if (destroyed) then
		
			self.HQDestroyed = true;
		
			if (not self.isClient) then
				self:Destroy();
			end

			self.allClients:ClDestroy();

			if (g_gameRules and g_gameRules.OnHQDestroyed) then
				g_gameRules:OnHQDestroyed(self, hit.shooterId, teamId);
			end
			
			SpawnEffect("atom_effects.explosions.nuke", self:GetPos(), g_Vectors.up, 0.3);
		end

		return destroyed;
	end,
};