function ATOMItem_OnHit(self, hit)

  local explosionOnly=tonumber(self.Properties.bExplosionOnly or 0)~=0;
  local hitpoints = self.Properties.HitPoints;

	local shooterId = hit.shooterId;
	if (shooterId and shooterId ~= self.id) then
		if (hit.shooter and hit.shooter.isPlayer) then
			--Debug("last shooter: ",hit.shooter:GetName(),">>",self.class)
			self.LastShooter = hit.shooter.id;
			self.LastShooterEnt = hit.shooter;
			self.LastHitPos = hit.pos
			
			--Debug("hit.type",hit.type)
			if (hit.type ~= "collision") then
				self.LastShooterName = hit.shooter:GetName();
				self.LastShooterTeam = g_game:GetTeam(hit.shooter.id)
				self.LastShooterId = hit.shooter.id
			end
		end;
	else
	--	self.LastShooter = nil;
	end;

	-- !hook
	if (ATOM:CheckItemHit(self, hit) and ATOMDefense:CheckItemHit(self, hit)) then
		ATOMBroadcastEvent("OnItemHit", hit, self);
	else
		return false;
	end;

	if (hitpoints and (hitpoints > 0)) then
		local destroyed=self.item:IsDestroyed()
		if (hit.type=="repair") then
			self.item:OnHit(hit);
		elseif ((not explosionOnly) or (hit.explosion)) then
			if ((not g_gameRules:IsMultiplayer()) or g_gameRules.game:GetTeam(hit.shooterId)~=g_gameRules.game:GetTeam(self.id)) then
				--patch1 hack: to compensate for decreased law damage
				--should have some kind of multiplier table per damage type
				--this will suffice for the time being
				if (hit.type=="law_rocket") then
					hit.damage=hit.damage*2.0;
				end

				self.item:OnHit(hit);
				if (not destroyed) then
					if (hit.damage>0) then
						if (g_gameRules.Server.OnTurretHit) then
							g_gameRules.Server.OnTurretHit(g_gameRules, self, hit);
						end
					end

					if (self.item:IsDestroyed()) then
						if (self.FlowEvents and self.FlowEvents.Outputs.Destroyed) then
							self:ActivateOutput("Destroyed",1);
						end
					end
				end
			end
		end
	end

end


function ATOMItem_Init()

	local ents = System.GetEntities();
	if (ents) then
		for i, ent in pairs(ents) do
			if (ent and ent.Server and (type(ent.Server)=="table") and ent.item) then
				--set metatable
				local metatb = getmetatable(ent);
				if (metatb and metatb.Server and (type(metatb.Server)=="table") and metatb.Server.OnHit) then
					metatb.Server.OnHit = ATOMItem_OnHit;
					--System.LogAlways("$6MetaItemTB OnHit Hooked");
				end
				--set playertables
				if (ent.Server.OnHit) then
					ent.Server.OnHit = ATOMItem_OnHit;
					--System.LogAlways("$6ItemTB OnHit Hooked");
				end
			end
		end
	end

end