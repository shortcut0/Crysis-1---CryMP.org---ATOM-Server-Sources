---------------------------------------------------------------
-- !assist, toggles aim assistance

NewCommand({
	Name 	= "assist",
	Access	= PREMIUM,
	Console = nil,
	Description = "Toggles Aim Assistenace IF U REQUIRE IT (!)",
	Args = {
	};
	Properties = {
		Self = 'ATOMNames',
		FromConsole = nil,
	};
	func = function(self, hPlayer)
	
		if (hPlayer.aimAssistance) then
			self:CheckAssistTag(hPlayer, false)
			hPlayer.aimAssistance = false
		else
		
			---------
			local iKills = g_gameRules:GetPlayerScore(hPlayer.id)
			if (iKills == 0) then
				iKills = 1 end
			
			---------
			local iDeaths = g_gameRules:GetPlayerDeaths(hPlayer.id)
			if (iDeaths == 0) then
				iDeaths = 1 end
			
			---------
			local iRatio = (iKills / iDeaths)
			if (iKills > 15 and iRatio >= 1.5) then
				return false, "you do not need aim assistance" end
		
			---------
			self:CheckAssistTag(hPlayer, true)
			hPlayer.aimAssistance = true
		end
		
		local sMode = string.bool(hPlayer.aimAssistance, "Enabled", "Disabled")
		SendMsg(INFO, ALL, "(%s: %s AIM ASSISTANCE (!))", string.upper(hPlayer:GetName()), string.upper(sMode))
		ATOMLog:LogGameUtils("", "$9%s$4 %s Aim Assistance", hPlayer:GetName(), sMode)
		ExecuteOnPlayer(hPlayer, [[AIM_ASSIST_ENABLED = ]] .. string.bool(hPlayer.aimAssistance))
	end
	
});

---------------------------------------------------------------
-- !maplist, SHows map list??

NewCommand({
	Name 	= "maplist",
	Access	= GUEST,
	Console = nil,
	Description = "Toggles Aim Assistenace IF U REQUIRE IT (!)",
	Args = {
		{ "Filter", "Only list maps of desired Game Rules", Optional = true }
	};
	Properties = {
		Self = 'g_utils',
		FromConsole = nil,
	};
	func = function(self, hPlayer, sFilter)
	
		return self:ListMaps(hPlayer, sFilter)
	end
	
});

---------------------------------------------------------------
-- !hitsounds, toggles new hit sounds

NewCommand({
	Name 	= "hitsounds",
	Access	= GUEST,
	Console = false,
	Args = {
	--	{ "Name", "The new name you wish to be renamed to" };
	};
	Properties = {
		Self = 'RCA',
		RequireRCA = true,
	};
	func = function(self, player)
		if (player.HitSounds) then
			player.HitSounds = false;
			ExecuteOnPlayer(player, [[CUSTOM_HIT_SOUNDS = false;]]);
		else
			player.HitSounds = true;
			ExecuteOnPlayer(player, [[CUSTOM_HIT_SOUNDS = true;]]);
		end;
		SendMsg(CHAT_ATOM, player, "(HITSOUNDS: %s)", player.HitSounds and "Enabled" or "Disabled");
		return true;
	end;
});

---------------------------------------------------------------
-- !jailtime, shows your jail time

NewCommand({
	Name 	= "jailtime",
	Access	= GUEST,
	Console = false,
	Description = "shows your remaining jail time",
	Args = {
	--	{ "Name", "The new name you wish to be renamed to" };
	};
	Properties = {
		Self = 'ATOMJail',
		RequireRCA = true,
	};
	func = function(self, player)
		return self:GetRemainingJailTime(player);
	end
});

---------------------------------------------------------------
-- !visitjail, Visits the jail to watch the prisoners

NewCommand({
	Name 	= "visitjail",
	Access	= GUEST,
	Console = false,
	Description = "Visits the jail to watch the prisoners",
	Args = {
	--	{ "Name", "The new name you wish to be renamed to" };
	};
	Properties = {
		Self = 'ATOMJail',
		RequireRCA = true,
	};
	func = function(self, player)
		return self:VisitJail(player);
	end
});

---------------------------------------------------------------
-- !feedprisoner, Visits the jail to watch the prisoners

NewCommand({
	Name 	= "feedprisoner",
	Access	= GUEST,
	Console = false,
	Description = "Visits the jail to watch the prisoners",
	Args = {
		{ "Target", "The Name of the Target you wish to feed", Target = true, NotSelf = true, Required = true };
	};
	Properties = {
		Self = 'ATOMJail',
		RequireRCA = true,
	};
	func = function(self, player, target)
		return self:FeedPrisoner(player, target);
	end
});


------------------------------------------------------------------------
-- !clone, spawns a clone for you

NewCommand({
	Name 	= "clone",
	Access	= MODERATOR,
	Description = "Spawns a clone for you",
	Console = true,
	Args = {
	--	{ "Amount", "The Amount of clones to Spawn", 					Integer = true, PositiveNumber = true, Optional = true };
	--	{ "Spread", "Spreads the bots in x meter radius", 				Integer = true, PositiveNumber = true, Optional = true };
	--	{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		Alive = true,
		NoSpec = true,
		Timer = 3 * 60,
		Cost = 100,
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Amount, Spread, ...)
		local idClone = self:Spawn({ Pos = player:CalcSpawnPos(3), Class = "Player", SpawnRadius = 1, Tags = { ['isClone'] = true }, Name = "Clone %d", Count = 1, Equipment = { "SCAR", "FY71" } });
		if (idClone) then
			Script.SetTimer(1000, function()
				ExecuteOnAll([[
				local anim="combat_guard_rifle_01"
				local entity=GetEnt(']] .. idClone:GetName() .. [[')
				if (entity) then
					entity:StartAnimation(0,anim,8,0,1,1,1);
					entity:ForceCharacterUpdate(0, true);
					LOOPED_ANIMS[entity.id] = {
						Entity 	= entity,
						Loop 	= -1,
						Timer 	= entity:GetAnimationLength(0, anim),
						Speed 	= 1,
						Anim 	= anim,
						NoSpec	= true,
						Alive	= true
					};
				end
				]])
			end)
		end
		return true
	end;
});

--combat_guard_rifle_01
------------------------------------------------------------------------
-- !grunt, spawns a grunt for you

NewCommand({
	Name 	= "grunt",
	Access	= MODERATOR,
	Description = "Spawns a grunt for you",
	Console = true,
	Args = {
	--	{ "Amount", "The Amount of clones to Spawn", 					Integer = true, PositiveNumber = true, Optional = true };
	--	{ "Spread", "Spreads the bots in x meter radius", 				Integer = true, PositiveNumber = true, Optional = true };
	--	{ "Weapons", "The Weapon Classes the clones will be carrying", 	Optional = true };
	};
	Properties = {
		Alive = true,
		NoSpec = true,
		Timer = 3 * 60,
		Cost = 100,
		Self = 'ATOMGameUtils',
	};
	func = function(self, player, Amount, Spread, ...)
		local idGrunt = self:Spawn({ Pos = player:CalcSpawnPos(3), Class = "Grunt", SpawnRadius = 1, Tags = { ['isClone'] = true }, Name = "Clone %d", Count = 1, Equipment = { "SCAR", "FY71" } });
		if (idGrunt) then
			Script.SetTimer(1000, function()
				ExecuteOnAll([[
				local anim="combat_guard_rifle_01"
				local entity=GetEnt(']] .. idGrunt:GetName() .. [[')
				if (entity) then
					entity:StartAnimation(0,anim,8,0,1,1,1);
					entity:ForceCharacterUpdate(0, true);
					LOOPED_ANIMS[entity.id] = {
						Entity 	= entity,
						Loop 	= -1,
						Timer 	= entity:GetAnimationLength(0, anim),
						Speed 	= 1,
						Anim 	= anim,
						NoSpec	= true,
						Alive	= true
					};
				end
				]])
			end)
			Script.SetTimer(60 * 1000, function() if (System.GetEntity(idGrunt.id)) then System.RemoveEntity(idGrunt.id) end; end)
		end
		return true
	end;
});

---------------------------------------------------------------
-- !name <newName>, renames a player to specified name

NewCommand({
	Name 	= "name",
	Access	= GUEST,
	Console = false,
	Args = {
		{ "Name", "The new name you wish to be renamed to" };
	};
	Properties = {
		Self = 'ATOMNames',
		FromConsole = false,
	};
	func = function(self, player, ...)
		return self:RenamePlayer(player, tableConcat({...}), "User Decision");
	end;
});


---------------------------------------------------------------
-- !luaerr <error>, lua error

NewCommand({
	Name 	= "luaerr",
	Access	= GUEST,
	Console = false,
	Args = {
		{ "Error", "The new name you wish to be renamed to", Concat = true };
	};
	Properties = {
		--Self = 'ATOMNames',
		--FromConsole = false,
		Hidden = true,
	};
	func = function(self, err)
		SendMsg(CHAT_CLIENT, ADMINISTRATOR, "(%s: CLE - %s)", self:GetName(), err)
		RCA:OnClientError(self, err)
	end;
});



---------------------------------------------------------------
-- !clearsky, Kills specified target if on VTOL

NewCommand({
	Name 	= "clearsky",
	Access	= GUEST,
	Console = false,
	Description = "Kills specified target if on VTOL",
	Args = {
		{ "Target", "The target you wish to terminate", Target = true, NotPlayer = true, Required = true };
	};
	Properties = {
		Self = 'g_gameRules',
		FromConsole = false,
		Timer = 60 * 5,
		Indoors = false,
		Alive = true,
		NoSpec = true,
	};
	func = function(self, player, target)
		local cost = 1000;
		local pp = player:GetPrestige();
		
		local bPS = (g_gameRules.class == "PowerStruggle")
		if (target:GetTeam() == player:GetTeam() and not bPS) then
			return false, "target is in your team dumdum";
		end
		
		local vehicle = target:GetVehicle();
		if (not vehicle or vehicle.class ~= "US_vtol") then
			return false, "target is not on a VTOL";
		end
		
		if (cost > pp and not bPS) then
			return false, "insufficient prestige (costs 1000)";
		end;
		
		if (not bPS) then
			player:PayPrestige(cost) end
		
		SendMsg(CHAT_ATOM, player, "%s - Missiles launched!", target:GetName());
		SendMsg(ERROR, target, "WARNING : HOMING COMETS LOCKED ON TO YOU");
		
		for i = 1, 3 do
			Script.SetTimer(i * 400, function()
				ATOMItems:AddProjectile(
					mergeTables_(DEFAULT_PROJECTILE_PROPERTIES, {
						Owner = player,
						Weapon = player:GetCurrentItem(),
						Pos = player:CalcSpawnPos(3),
						Dir = add2Vec(g_Vectors.up, makeVec(GetRandom(-0.05, 0.05),GetRandom(-0.05, 0.05),1)),
						Hit = hit,
						Normal = g_Vectors.up,
						Properties = {
							FilterProjectileCollisions = true, 
							LifeTime = 30000,
							Model = {
								File = "Objects/natural/rocks/cliff_rocks/cliff_rock_a_small.cgf",
								Particle = {
									Name = "explosions.jet_explosion.burning",
									Scale = 0.3,
									Loop = true,
									Timer = 8
								},
								Sound = "Sounds/vehicles:trackview_vehicles:jet_constant_run_01_mp_with_fade",
								NoServer = true, -- Will not load model on server (projectiles wont collide with each other)
								Mass = 1,
							},
							Impulses = {
								First = { -- first impulse applied
									Use = true,
									Dir = add2Vec(g_Vectors.up, makeVec(GetRandom(-5, 5)/50,GetRandom(-5, 5)/50,1)), --g_Vectors.up,
									Strength = 10000,
								},
								LockedTarget = target:GetVehicle().id,
								AutoAim = false,
								Amount = -1,
								Strength = 4,
								Delay = 2,
							},
							Events = {
								Collide = function(p, t, pos, contact, dir)
									if (t == COLLISION_WATER) then
										for i,v in ipairs({
										{"explosions.warrior.water_wake_sphere",  0.10 },
										{"explosions.mine.seamine",               5 },
										{"explosions.Grenade_SCAR.water",         5 },
										{"explosions.jet_water_impact.hit",       3}
										}) do
											SpawnEffect(v[1], contact, dir, v[2]);
										end;
										Explosion("explosions.rocket.water", contact, 10, 500, dir, p.owner, p.OwnerWeapon, 2);
										PlaySound("sounds/physics:explosions:sphere_cafe_explo_3", contact);
									else
										Explosion(GetRandom({"explosions.jet_explosion.on_fleet_deck", "explosions.mine_explosion.hunter_reveal", "explosions.mine_explosion.door_explosion", "explosions.harbor_airstirke.airstrike_large", "explosions.harbor_airstirke.airstrike_medium" }), contact, 10, 10000, dir, p.owner, p.OwnerWeapon, 1.3);
										PlaySound(GetRandom({"Sounds/physics:explosions:sphere_cafe_explo_1", "Sounds/physics:explosions:sphere_cafe_explo_2", "Sounds/physics:explosions:sphere_cafe_explo_3"}), contact);
									end;
								end,
							},
						};
					})
				);
			end);
		end;
		
	end;
});

---------------------------------------------------------------
-- !protection, portects nearest bunker with an auto turret for 30s

NewCommand({
	Name 	= "protection",
	Access	= GUEST,
	Console = false,
	Description = "portects nearest bunker with an auto turret for 30s",
	Args = {
	--	{ "Name", "portects nearest bunker with an auto turret for 30s" };
	};
	Properties = {
		Self = 'g_gameRules',
		FromConsole = false,
		Cost = 500,
		Timer = 15 * 60,
		NoSpec = true,
	};
	func = function(self, player, ...)
		if (g_game:GetTeam(player.id) == 0) then
			return false, "not as neutral player";
		end;
		local bunker = g_utils:GetClosestBuilding(player:GetPos(), 30, "bunker");
		if (not bunker) then
			return false, "no bunker in range found";
		elseif (g_game:GetTeam(bunker.id) ~= g_game:GetTeam(player.id)) then
			return false, "this is not your bunker";
		end;
		if (bunker.HasProtection) then
			return false, "this bunker already has protection";
		end;
		g_gameRules:ProtectBunker(player, bunker, 1, 1);
		SendMsg(CHAT_ATOM, ALL, "%s : Enabled Protection on the Closest Bunker!", player:GetName());
		return true;
	end;
});

---------------------------------------------------------------
-- !sync, dummy command

NewCommand({
	Name 	= "sync",
	Access	= GUEST,
	Console = true,
	Args = {
		{ "token1", "No idea what this requires" };
		{ "token2", "Same here" };
	};
	Properties = {
		Hidden = true;
		NoChatLog = true;
	};
	func = function(player, ...)
		return true;
	end;
});

---------------------------------------------------------------
-- !validate, dummy command

local function VerifyToken(id, token, privkey)
	local tok, t = string.match(token, "([a-f0-9A-F]+)_(.-)")
	if (not tok) then
		return false;
	end;
	if tok:len()<40 then 
		return false; 
	end
	local vlen = tok:len() - 40
	local hsh = tok:sub(0, vlen)
	local org = id..":"..t..":"..privkey
	local sign=sha1(org)
	local part=sign:sub(0,vlen)
	return (part==hsh)
end;
local ATOMValidateKey = "2822652332fe13405ac31f082d94e";

NewCommand({
	Name 	= "validate",
	Access	= GUEST,
	Console = true,
	Args = {
		{ "profile" };
		{ "id" };
		{ "token" };
	};
	Properties = {
		Hidden = true;
		NoChatLog = true;
	};
	func = function(player, id, token)
		if (not id or not token) then
			return ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "(1) Invalid Validate");
		end;
		if (not player.Info.Profile or player.Info.Profile == 0) then
			--local tok, t = string.match(token, "([a-f0-9A-F]+)_(.-)");
			--Debug(token)
			--Debug(tok)
			--Debug(t)
			--if (not tok or not t) then
			--	return ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "(2) Invalid Validate");
			--end;
			if token:len()<40 then
				return ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "(3) Invalid Validate");
			end

			if (not tonumber(id)) then
				return ATOMPunish.ATOMPunish:KickPlayer(ATOM.Server, player, "(4) Invalid Validate")
			end

			player.Info.Profile = tonumber(id)
		end
	end
})

------------------------------------------------------------------------
---- !commands <access>, lists all commands to the players console
----    		Optional, lists commands only from this group
------------------------------------------------------------------------

NewCommand({
	Name 	= "commands",
	Access	= GUEST,
	Console = true,
	Args = {
		{ "Access",	"List Commands only from this Group" };
	};
	Properties = {
		Self = 'ATOMCommands',
	};
	func = function(self, player, i)
		return self:ListCommands(player, tonumber(i) or tonumber(_G[tostring(i):upper()] or 0));
	end;
});

------------------------------------------------------------------------
---- !flare, Signalizes your Position
------------------------------------------------------------------------

NewCommand({
	Name 	= "flare",
	Access	= GUEST,
	Console = true,
	Description = "Signalizes your Position";
	Args = {
	--	{ "Access",	"List Commands only from this Group" };
	};
	Properties = {
		Indoors = false;
		Self = 'ATOMGameUtils',
		Timer = 10,
		Cost = 10,
	};
	func = function(self, player, i)
		if (i and tonumber(i) and player:HasAccess(SUPERADMIN)) then
			for i = 1, math.min(100, math.max(1, tonumber(i))) do
				Script.SetTimer(i - 25, function()
					self:SpawnEffect((self:IsNight() and ePE_FlareNight or ePE_Flare), player:GetPos(), toVec(math.random(-10, 10) / 10, math.random(-10, 10) / 10, 1));
				end);
			end;
		else
			self:SpawnEffect((self:IsNight() and ePE_FlareNight or ePE_Flare), player:GetPos());
		end;
		return true;
	end;
});

------------------------------------------------------------------------
---- !megafirework
------------------------------------------------------------------------

NewCommand({
	Name 	= "megafirework",
	Access	= GUEST,
	Console = true,
	Description = "Signalizes your Position";
	Args = {
		{ "Count",	"The amount of flares", Number = true, Integer = true, Optional = true }
	};
	Properties = {
		Indoors = false,
		Self = 'ATOMGameUtils',
		Timer = 60 * 5,
		Cost = 250,
	};
	func = function(self, hPlayer, iCount)

		local sEffect = "ATOM_Effects.very_important.mega_firework_flare"

		if (isNumber(iCount) and hPlayer:HasAccess(SUPERADMIN)) then
			for i = 1, math.min(100, math.max(1, iCount)) do
				Script.SetTimer(i - 25, function()
					self:SpawnEffect(sEffect, hPlayer:GetPos())
				end)
			end
		else
			self:SpawnEffect(sEffect, hPlayer:GetPos())
		end

		SendMsg(CHAT_ATOM, ALL, "(%s: Has Released a Mega Firework)", hPlayer:GetName())
		return true
	end
});

------------------------------------------------------------------------
---- !flare, Signalizes your Position
------------------------------------------------------------------------

NewCommand({
	Name 	= "firework",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a Firework";
	Args = {
		{ "Count",	"The amount of flares", Number = true, Integer = true, Optional = true }
	};
	Properties = {
		Indoors = false;
		Self = 'ATOMGameUtils',
		Timer = 60,
		Cost = 10,
	};
	func = function(self, hPlayer, iCount)

		local sEffect = "ATOM_Effects.Very_Important.firework_q_8s"

		if (isNumber(iCount) and hPlayer:HasAccess(SUPERADMIN)) then
			for i = 1, math.min(250, math.max(1, iCount)) do
				Script.SetTimer(i - 25, function()
					self:SpawnEffect(sEffect, hPlayer:GetPos())
				end)
			end
		else
			self:SpawnEffect(sEffect, hPlayer:GetPos())
		end

		SendMsg(CHAT_ATOM, ALL, "(%s: Released some Fireworks!)", hPlayer:GetName())

		return true
	end;
});

------------------------------------------------------------------------
---- !jump, Jump 50m in the Air
------------------------------------------------------------------------

NewCommand({
	Name 	= "jump",
	Access	= GUEST,
	Console = true,
	Description = "Jump 150m in the Air";
	Args = {
	--	{ "Access",	"List Commands only from this Group" };
	};
	Properties = {
		Indoors = false,
		Ground = true,
		Timer = 2.5 * 60,
		Self = 'ATOMGameUtils',
		Cost = 50,
		OnlyAlive = true,
		NoVehicle = true
	};
	func = function(self, player, i)
		local pos = player:GetPos();
		self:SpawnEffect(ePE_AlienBeam, pos);
		self:SpawnEffect(ePE_Light, pos);
		self:SpawnEffect(ePE_Light, add2Vec(pos, {x=0,y=0,z=150}));
		g_game:MovePlayer(player.id, add2Vec(pos, {x=0,y=0,z=150}), player:GetAngles());
		--SendMsg(CHAT_ATOM, ALL, "%s: Jumped Skyhigh", player:GetName());
		return true;
	end;
});

------------------------------------------------------------------------
---- !stuck, Respawns you at the Nearest SpawnPoint
------------------------------------------------------------------------

NewCommand({
	Name 	= "stuck",
	Access	= GUEST,
	Console = true,
	Description = "Respawns you at the Nearest SpawnPoint";
	Args = {
	--	{ "Access",	"List Commands only from this Group" };
	};
	Properties = {
		Ground = true,
		Timer = 60 - 5,
		Self = 'ATOMGameUtils',
		--Cost = 10,
	};
	func = function(self, player, i)
		return self:PlayerStuck(player);
	end;
});

------------------------------------------------------------------------
---- !info, Shows the Server-Information
------------------------------------------------------------------------

NewCommand({
	Name 	= "info",
	Access	= GUEST,
	Console = true,
	Description = "Shows the Server-Information";
	Args = {
	--	{ "Access",	"List Commands only from this Group" };
	};
	Properties = {
		Self = 'ATOM',
		Timer = 1,
	};
	func = function(self, player)
		return self:SendInfoMessages(player);
	end;
});

------------------------------------------------------------------------
---- !ammo, Refills your ammunition
------------------------------------------------------------------------

NewCommand({
	Name 	= "ammo",
	Access	= GUEST,
	Description = "Refills your ammunition",
	Console = true,
	Args = {
	--	{ "Target", "The Player to refill ammunition on", Target = true, Optional = true };
	};
	Properties = {
		GameRules = "PowerStruggle",
		Self = 'ATOMGameUtils',
		Timer = 60 - 10,
	};
	func = function(self, player, Target)
		return self:RefillAmmo_Command(player);
	end;
});

------------------------------------------------------------------------
---- !mylevel, Shows your Level Information
------------------------------------------------------------------------

NewCommand({
	Name 	= "mylevel",
	Access	= GUEST,
	Console = true,
	Description = "Shows your Level Information";
	Args = {
		{ "Player",	"Display Level Information from this Player", Target = true, AcceptSelf = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMLevelSystem',
	--	Timer = 1,
	};
	func = function(self, player, target)
		local addEXP = self:GetNextLevelEXP(player:GetLevel());
		local perc = ((addEXP - (player.levelStats.NextLevel - player.levelStats.EXP))/addEXP) * 100; --cutNum((amount / cfg.LevelEXP) * 100, 2); --(round(((addExp - (plData.nextlevel - plData.exp))/addExp)*100))
		if (perc<0) then
			perc = 0.001;
		end;
		if (samePlayer(player, target)) then
			SendMsg(CHAT_ATOM, player, "Your Level..: %d (#%d)", 	player:GetLevel(), self:GetLevelRank(player));
			SendMsg(CHAT_ATOM, player, "Your EXP....: %d", 			player:GetEXP());
			SendMsg(CHAT_ATOM, player, "Next Level..: %d, (%0.2f%%)", 	player.levelStats.NextLevel, perc); --cutNum(((self:GetNextLevelEXP(player:GetLevel()) - (player.levelStats.NextLevel - player.levelStats.EXP))/self:GetNextLevelEXP(player:GetLevel())) - 100, 2));
		else
		
		end;
	end;
});

------------------------------------------------------------------------
---- !bank, Deposit, withdraw or see your Bank Status
------------------------------------------------------------------------

NewCommand({
	Name 	= "bank",
	Access	= GUEST,
	Console = true,
	Description = "Deposit, withdraw or see your Bank Status";
	Args = {
		{ "Option",	"Option for you action", Required = true, AcceptThis = {
			['export'] = true,
			['import'] = true,
			['status'] = true
		}, Default = "status"};
		{ "Amount", "The amount of Prestige to Deposit/Withdraw", Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMBank',
		GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, status, amount)
		if (status == 'export') then
			return player:WithdrawPrestige(amount);
		elseif (status == 'import') then
			return player:DepositPrestige(amount);
		else
			local bank = player:GetBank();
			SendMsg(CHAT_BANK, player, "Welcome, %s, to your Bank Account", player:GetName());
			SendMsg(CHAT_BANK, player, "Bank Prestige : %d (%d%%, #%d)", bank.Prestige, (bank.Prestige/bank.MaxPrestige) - 100, self:GetBankRank(player));
			SendMsg(CHAT_BANK, player, "Maximum Prestige : %d", bank.MaxPrestige);
			SendMsg(CHAT_BANK, player, "Daily Bonus : %d", self:GetDailyBonus(bank.Prestige));
			return true;
		end;
	end;
});

------------------------------------------------------------------------
---- !airport, Teleport to the Airport if possible
------------------------------------------------------------------------

NewCommand({
	Name 	= "airport",
	Access	= GUEST,
	Console = true,
	Description = "Teleport to the Airport if possible";
	Args = {
	};
	Properties = {
		Self = 'ATOMAircrafts',
		Timer = 30,
		NotInFight = true,
		Alive = true,
		NoSpec = true,
		Vehicle = false,
		Cost = 250,
	--	Timer = 1,
	};
	func = function(self, player)
		self:TeleportPlayer(player, "Airport");
	end;
});

------------------------------------------------------------------------
---- !buyjet, Buys a Jet of specified Type
------------------------------------------------------------------------

NewCommand({
	Name 	= "buyjet",
	Access	= GUEST,
	Console = true,
	Description = "Buys a Jet of specified Type";
	Args = {
		{ "Type", "The type of the aircraft", Required = true, Default = "list" },
	};
	Properties = {
		Self = 'ATOMAircrafts',
		NotInFight = true,
		Alive = true,
		NoSpec = true,
		Vehicle = false,
	--	Timer = 1,
	};
	func = function(self, player, Index)
	
		if (not self:IsAtAirport(player)) then
			return false, "only near the airport (use !airport)"
		end
	
		local models = {
			{ "US Figter", 		2, nil,	1000 	},
			{ "US Cargoplane", 	3, nil,	1000 	},
			{ "Asian Fighter", 	2, 1, 	600		},
			{ "Aircraft", 		1, nil, 300		},
		};
		
		local newModel = models[tonum(Index)];
		if (Index == "list" or not newModel) then
			ListToConsole(player, models, "Aircraft Types");
			SendMsg(CHAT_ATOM, player, "Open Console to View the List of [ %d ] Possible Types", arrSize(models));
			return true;
		end;
		
		if (g_gameRules.class == "PowerStruggle") then
			local price = newModel[4];
			local pp = player:GetPrestige();
			if (price > pp) then
				return false, "insufficient prestige";
			end;
			player:PayPrestige(price);
		end
		self:SpawnAircraft(player, newModel[2], newModel[3]);
	end;
});

------------------------------------------------------------------------
---- !markercolor,

NewCommand({
	Name 	= "markercolor",
	Access	= GUEST,
	Console = true,
	Description = "Changes the color of your hit marker";
	Args = {
		{ "Index", "Index of the list of possible colors", Integer = true, Required = false, Default = "list" },
	};
	Properties = {
	--	Timer = 1,
	};
	func = function(hPlayer, iIndex)

		local aColors = {
			{ "$0Black$9", 		"$0" },
			{ "$1White$9", 		"$1" },
			{ "$2Dark Blue$9", 	"$2" },
			{ "$3Green$9", 		"$3" },
			{ "$4White$9", 		"$4" },
			{ "$5Light Blue$9", "$5" },
			{ "$6<Unknown>$9", 	"$6" },
			{ "$7Purple$9", 	"$7" },
			{ "$8Orange$9", 	"$8" },
			{ "$9Grey$9", 		"$9" },
		}
		local sColor = aColors[iIndex]
		Debug(type(iIndex))
		if (iIndex == "list" or not sColor) then
			ListToConsole(hPlayer, aColors, "Marker Colors");
			SendMsg(CHAT_ATOM, hPlayer, "Open Console to View the List of [ %d ] Possible Colors", table.count(aColors));
			return true
		end

		ExecuteOnPlayer(hPlayer, string.format("HIT_MARKER_COLOR = \"%s\"", sColor[2]))
		SendMsg(CHAT_ATOM, hPlayer, "(MarkerColor: %s)", string.gsub(sColor[1], "%$%d", ""))
	end
});


-------------------------------------------------------------------
-- !myconfig

NewCommand({
	Name 	= "myconfig",
	Access	= GUEST,
	Console = true,
	Description = "Shows your weapon configurations";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Class", "Displays only the Configuration of this Weapon", Optional = true };
	};
	Properties = {
		Self = 'ATOMEquip',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Class)
		local myconfig = self:HasEquipment(player)
		if (not myconfig) then
			return false, "No configuration found"
		end;
		
		
		local attaches={}
		for i, v in pairs(myconfig) do
			--local attaches = "
			attaches[i]="<" .. table.concat(v, "> <") .. ">";
		end;
		local longestName = longest(myconfig, 0);
		local longestAttach = longest(attaches, -1);
		
		local attaches;
		
		if (not Class or not myconfig[Class]) then
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestAttach+6));
			SendMsg(CONSOLE, player, " $9      Name " .. string.rep(" ",longestName-2) .. " Attachments");
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestAttach+6));
			local counted = 0;
			for i, v in pairs(myconfig) do
				counted = counted + 1;
				attaches = arrSize(v)>0 and "$1<$9" .. table.concat(v, "$1> <$9") .. "$1>" or "$9No Attachments";
				SendMsg(CONSOLE, player, " $9[$1"..counted..repStr(3,counted).."$9] $4" .. tostring(i):upper()..repStr(longestName+1,tostring(i)).." $9] $4"..attaches..repStr(longestAttach,attaches).." $9]")
			end;
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestAttach+6));
			SendMsg(CHAT, player, "Open console to view the Cached data");
		else
			attaches = arrSize(myconfig[Class])>0 and "<" .. table.concat(myconfig[Class], ">, <") .. ">" or "No Attachments";
			SendMsg(CHAT_EQUIP, player, "(" .. Class:upper() .. ": " .. attaches .. ")");
		end;
		return true;
	end;
});


-------------------------------------------------------------------
-- !myrank

NewCommand({
	Name 	= "myrank",
	Access	= GUEST,
	Console = true,
	Description = "Shows your Rank on this Server";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Type", "The Rank Type to display", Optional = true, AcceptThis = { 
			['exp'] = true,
			['score'] = true,
			['death'] = true,
			['kills'] = true
		}};
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Type)
		
		local id = player:GetIdentifier();
		
		local score = self:GetData(id);
		
		if (not Type or Type == "score") then
			SendMsg(CHAT_ATOM, player, "Your Score: %d, (#%d)", self:GetScore(id), self:GetPlayerRank(player, eST_Score));
			SendMsg(CHAT_ATOM, player, "Your Kills: %d", (score.kills or 0));
			SendMsg(CHAT_ATOM, player, "Your Deaths: %d", (score.deaths or 0));
		elseif (Type == "exp") then
			SendMsg(CHAT_ATOM, player, "Your EXP: %d, (#%d)", player:GetEXP(), self:GetPlayerRank(player, eST_EXP));
		elseif (Type == "death") then
			SendMsg(CHAT_ATOM, player, "Your Deaths: %d, (#%d)", (score.deaths or 0), self:GetPlayerRank(player, eST_Deaths));
		elseif (Type == "kills") then
			SendMsg(CHAT_ATOM, player, "Your Kills: %d, (#%d)", (score.kills or 0), self:GetPlayerRank(player, eST_Kills));
		end;
		
		return true;
	end;
});


-------------------------------------------------------------------
-- !mytime

NewCommand({
	Name 	= "mytime",
	Access	= GUEST,
	Console = true,
	Description = "Shows your game and playtime on this Server";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "The Rank Type to display", Optional = true, AcceptThis = { 
	--		['exp'] = true,
	--		['score'] = true,
	--		['death'] = true,
	--		['kills'] = true
	--	}};
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Type)
		
		local id = player:GetIdentifier();
		local score = self:GetData(id);
		
		local playTime = player:GetPlayTime();
		local playTimeRank = 1;
		for i, other in pairs(GetPlayers()or{}) do
			if (other.id ~= player.id) then
				if (other:GetPlayTime() > playTime) then
					playTimeRank = playTimeRank + 1;
				end;
			end;
		end;
		
		local premiumStatus = "*UNLOCKED*";
		local premiumTime	= self.cfg.Goals.HoursUntilPremium - 60 - 60;
		
		if (not player:HasAccess(PREMIUM) and score.GameTime < premiumTime) then
			premiumStatus = "Remaining: " .. calcTime(premiumTime - score.GameTime, true, unpack(GetTime_SMH)) .. ", (" .. cutNum((score.GameTime / premiumTime)-100, 2) .. "%)";
		end;
		
		SendMsg(CHAT_ATOM, player, "Your Play Time: %s, (#%d)", calcTime(score.GameTime, true, unpack(GetTime_SMH)), self:GetPlayerRank(player, eST_GameTime));
		SendMsg(CHAT_ATOM, player, "Your Game Time: %s, (#%d)", calcTime(playTime, true, unpack(GetTime_SMH)), playTimeRank);
		SendMsg(CHAT_ATOM, player, "Premium Status: %s", premiumStatus);

		return true;
	end;
});

-------------------------------------------------------------------
-- !mykills

NewCommand({
	Name 	= "mykills",
	Access	= GUEST,
	Console = true,
	Description = "Shows kill count of each weapon you used";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Class", "Displays only the Kill Count of this Weapon", Optional = true };
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Class)
		local mydata = self:GetData(player:GetIdentifier());
		if (not mydata) then
			return false, "No scores associated to your account found"
		end;
		if (not mydata.classKills) then
			return false, "No Kills found"
		end;

		local new = {};
		
		for i, v in pairs(mydata.classKills) do
		--	Debug(v,mydata.kills)
			new[#new+1] = { i, v, "(D4" .. cutNum((v / mydata.kills) * 100) .. "%$9)"}; --cutNum((v/mydata.kills)-100, 2)
		end;
		
		local mykills = new;
		table.sort(mykills,function(a,b) return a[2]>b[2]end);
		
		local longestName = setmin(longest(mykills, 1), 6);
		local longestPerc = setmin(longest(mykills, 3), 0) - 2;
		
		--Debug(">...",longestPerc.." >> " ..longest(mykills, 0))
		if (not Class or not mykills[Class]) then
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestPerc+12));
			SendMsg(CONSOLE, player, " $9      Weapon " .. string.rep(" ",longestName-4) .. " Kills   %");
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestPerc+12));
			local counted = 0;
			for i, v in pairs(mykills) do
				SendMsg(CONSOLE, player, " $9[$1"..i..repStr(3,i).."$9] $4" .. tostring(v[1]):upper() .. repStr(longestName+1,tostring(v[1])).." $9] $4"..v[2]..repStr(5,v[2]).." $9] " .. v[3]:gsub("D4","$4") .. repStr(longestPerc,v[3]) .. " ]")
			end;
			SendMsg(CONSOLE, player, " $9======"..string.rep("=",longestName+longestPerc+12));
			SendMsg(CHAT, player, "Open console to view the Cached data");
		else
			local kills = mykills[Class];
			SendMsg(CHAT_EQUIP, player, "(" .. Class:upper() .. ": " .. kills .. " Kills)");
		end;
		return true;
	end;
});


-------------------------------------------------------------------
-- !nextmap

NewCommand({
	Name 	= "nextmap",
	Access	= GUEST,
	Console = true,
	Description = "Shows the next map";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Class", "Displays only the Kill Count of this Weapon", Optional = true };
	};
	Properties = {
		Self = 'g_gameRules',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player)
		SendMsg(CHAT_ATOM, player, "Next Map : %s", self:NextLevel(true):sub(16));
		return true;
	end;
});

-------------------------------------------------------------------
-- !top10

NewCommand({
	Name 	= "top10",
	Access	= GUEST,
	Console = true,
	Description = "Shows the Top 10 players of this Server";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Type", "Sort Top Players by selected type", Optional = true, AcceptThis = { 
			['exp'] = true,
			['lvl'] = true,
		}};
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, sMode)
		local allScores = self.permaScore;
		local theScores = {};
		for i, v in pairs(allScores) do
			theScores[arrSize(theScores)+1] = {
				i,
				v
			};
		end;
		table.sort(theScores,function(a,b)

			if (sMode == "exp") then
				a[2].score = nil or (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].EXP 	or 0)
				b[2].score = nil or (ATOMLevelSystem.savedEXP[b[1]] and ATOMLevelSystem.savedEXP[b[1]].EXP 	or 0)
				return a[2].score>b[2].score;
			end

			if (sMode == "lvl") then
				a[2].score = (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].Level  or 0)
				b[2].score = (ATOMLevelSystem.savedEXP[b[1]] and ATOMLevelSystem.savedEXP[b[1]].Level  or 0)
				return a[2].score>b[2].score;
			end

			a[2].score = a[2].score or (a[2].kills or 0) + 1 / ((a[2].deaths or 0) + 2);
			b[2].score = b[2].score or (b[2].kills or 0) + 1 / ((b[2].deaths or 0) + 2);
			if (a[2].score == b[2].score) then
				local X, Y = (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].EXP or 0), (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].EXP or 0);
				return X>Y;
			end;
			return a[2].score>b[2].score;
		end);
		
		
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9       NAME                  KILLS   DEATH    HS    FIST   LEVEL     EXP     FRAG  STREAK VISIT    PLAY:TIME ");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		
		local data, playTimeSeconds, playTime, kills, deaths, heads, frags, box, exp, level, name, visits, rankInfo;
		
		local id = player:GetIdentifier();
		local thisIsPlayer = false;
		for i, v in ipairs(theScores) do
			
			data = v[2];
			playTimeSeconds = (data.GameTime or 0);
			playTime = calcTime(playTimeSeconds, true, unpack(GetTime_SMH)):gsub(":", "$9:$4");
			
			kills 	= (data.kills  or 0);
			deaths 	= (data.deaths or 0);
			heads 	= (data.heads  or 0);
			frags 	= (data.classKills and data.classKills['Frag'] 	or 0);
			box		= (data.classKills and data.classKills['Fists'] or 0);
			
			exp 	= (ATOMLevelSystem.savedEXP[v[1]] and ATOMLevelSystem.savedEXP[v[1]].EXP 	or 0);
			if (exp > 1000000) then
				exp = formatString("%0.2fmil", exp / 1000000);
			elseif (exp > 1000) then
				exp = formatString("%0.2fk", exp / 1000);
			end;
			--if (exp > 10000000) then
				--exp = "9999999+";
			--end;
			level 	= (ATOMLevelSystem.savedEXP[v[1]] and ATOMLevelSystem.savedEXP[v[1]].Level  or 0);
			streak 	= (data.killStreak or 0);
			
			name	= (data.name or "<Unknown>");
			
			visits 	= (data.Visits or 0);
			
			thisIsPlayer = v[1] == id;
			
			if (i < 11 or v[1] == id) then 
				if ( i >= 10 and thisIsPlayer ) then
					SendMsg(CONSOLE, player, "$9================================================================================================================");
				end;
				rankInfo = "[ $1#" .. string.lenprint(i, 3) .. " $5" .. string.lenprint(name:sub(1, 19), 19);
				if (v[1] == id) then
					rankInfo = "[ $1#" .. string.lenprint(i, 3) .. " $3YOUR : RANK" .. repStr(6, i) .. " ->";
				end;
				
				SendMsg(CONSOLE, player, "$9" .. rankInfo .. " $9| $4" .. kills .. repStr(5, kills) .. " $9| $4" .. repStr(5, deaths) .. deaths .. " $9| $4" .. repStr(4, heads) .. heads .. " $9| $6" .. repStr(5, box) .. box .. " $9| $6" .. repStr(4, level) .. level .. " $9| $7" .. repStr(8, exp) .. exp .. " $9| $4" .. repStr(3, frags) .. frags .. " $9| $4" .. repStr(4, streak) .. streak .. " $9| $4" .. repStr(3, visits) .. visits .. " $9| $4" .. repStr(13, playTime) .. playTime .. " $9]");
			end;
			
			--[[
			currRank = currRank + 1;
			totExp = Sinep.LevelingSystem.stored[tostring(v.ident)] and Sinep.LevelingSystem.stored[tostring(v.ident)].exp or 0;
			totLevel = Sinep.LevelingSystem.stored[tostring(v.ident)] and Sinep.LevelingSystem.stored[tostring(v.ident)].level or 0;
			if (currRank<10) then currRankText=""..currRank.."  " elseif (currRank<100) then currRankText=""..currRank.." " else currRankText = currRank end
			currRankText=""..currRankText
			if (foundYou and currRank~=1) then
				--SendMsg(CONSOLE, player, "$9"..repStrByStr("=",113))
			end
			if (foundYou) then

				if (currRank>1) then

				SendMsg(CONSOLE, player,"$9"..repStrByStr("=",108)) end;
			end
			SendMsg(CONSOLE, player, "$9[ $5" .. (not foundYou and v.name or "$3YOUR : RANK") .. repStr(19, (not foundYou and v.name or "$3YOUR : RANK")) .. " $9-> #$3"..currRankText..repStr(3,currRankText).." $9| $5"..v.totalKills..repStr(5,v.totalKills).." $9| $5"..v.totalDeaths..repStr(5,v.totalDeaths).." $9| $4"..v.totalHeadShots..repStr(4,v.totalHeadShots).." $9| $4"..v.totalFragKills..repStr(4,v.totalFragKills).." $9| $4"..v.totalBoxKills..repStr(3,v.totalBoxKills).." $9| $4"..v.totalBoxDeaths..repStr(5,v.totalBoxDeaths).." $9| $7"..totExp..repStr(8,totExp).." $9| $8"..totLevel..repStr(5,totLevel).." $9| $5" .. totpt .. repStr(10,totpt) .." $9] ")
			if (foundYou) then

				if (currRank~=10) then

				SendMsg(CONSOLE, player, "$9"..repStrByStr("=",108)) 
				end;
			end
			
			if (currRank>=10) then
				if (not foundYoufoundYou) then
					for a,bb in ipairs(theScores) do
						cr1=cr1+1;
						if (cr1<100) then cr2=""..cr1.." " end if (cr1<10) then cr2=""..cr1.."  " end
						cr2=""..cr2
						--Debug(tostring(a) .. " == " .. player:GetSinProfile())
						if (tostring(bb.ident)==player:GetSinProfile()) then
							totExp = Sinep.LevelingSystem.stored[tostring(a)] and Sinep.LevelingSystem.stored[tostring(a)].exp or 0;
							totLevel = Sinep.LevelingSystem.stored[tostring(a)] and Sinep.LevelingSystem.stored[tostring(a)].level or 0;
			totpt=Sinep.PlayTimeSystem.temp[bb.ident].playTime or 0;
			
			a,b,c,d,e,f,g = InMinutes((tonumber(totpt or 0) or 0),false,true,false);
			totpt = "$5"..d.."d$9:$5"..c.."h$9:$5"..b.."m$9";
							SendMsg(CONSOLE, player, "$9"..repStrByStr("=",108))
							
							SendMsg(CONSOLE, player, "$9[ $5" .. "$3YOUR : RANK" .. repStr(19, "$3YOUR : RANK") .. " $9-> #$3"..cr2..repStr(3,cr2).." $9| $5"..bb.totalKills..repStr(5,bb.totalKills).." $9| $5"..bb.totalDeaths..repStr(5,bb.totalDeaths).." $9| $4"..bb.totalHeadShots..repStr(4,bb.totalHeadShots).." $9| $4"..bb.totalFragKills..repStr(4,bb.totalFragKills).." $9| $4"..bb.totalBoxKills..repStr(3,bb.totalBoxKills).." $9| $4"..bb.totalBoxDeaths..repStr(5,bb.totalBoxDeaths).." $9| $7"..totExp..repStr(8,totExp).." $9| $8"..totLevel..repStr(5,totLevel).." $9| $5" .. totpt .. repStr(10,totpt) .." $9] ")
			
							--SendMsg(CONSOLE, player, "$9[ $5" .. b.name .. repStr(20, b.name) .. " $9| $7"..cr2..repStr(5,cr2).." $9| $5"..b.totalKills..repStr(6,b.totalKills).." $9| $5"..b.totalDeaths..repStr(7,b.totalDeaths).." $9| $4"..b.totalHeadShots..repStr(5,b.totalHeadShots).." $9| $4"..b.totalFragKills..repStr(5,b.totalFragKills).." $9| $4"..b.totalBoxKills..repStr(4,b.totalBoxKills).." $9| $4"..b.totalBoxDeaths..repStr(10,b.totalBoxDeaths).." $9| $7"..totExp..repStr(8,totExp).." $9| $8"..totLevel..repStr(8,totLevel).." $9] ")
							break;
						end
					end
				end
				break;
			end;
			foundYou=false--]]
		end;
		SendMsg(CONSOLE, player, "$9================================================================================================================");
	end;
});

-------------------------------------------------------------------
-- !myprofile

NewCommand({
	Name 	= "myprofile",
	Access	= GUEST,
	Console = true,
	Description = "Shows your Current profile Information";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Target", "The name of the target", Optional = true, Target = true, EqualAccess = true, Access = MODERATOR };
	};
	Properties = {
	--	Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(player, target)
		local who = target or player;
		
		SendMsg(CHAT_ATOM, player, "%s Profile: %s", (who.id~=player.id and "Their" or "My"), tostr(who:GetProfile()));
		Script.SetTimer(10, function()
			SendMsg(CHAT_ATOM, player, "%s Rank: %s",(who.id~=player.id and "Their" or "My"),  tostr(who:GetAccessString()));
		end);
		Script.SetTimer(20, function()
			SendMsg(CHAT_ATOM, player, "%s IP: %s", (who.id~=player.id and "Their" or "My"), tostr(who:GetIP()));
		end);
		Script.SetTimer(30, function()
			SendMsg(CHAT_ATOM, player, "%s Country: %s", (who.id~=player.id and "Their" or "My"), tostr(who:GetCountry()));
		end);
	end;
});


-------------------------------------------------------------------
-- !myinfo

NewCommand({
	Name 	= "myinfo",
	Access	= GUEST,
	Console = true,
	Description = "Shows your account information";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "The Rank Type to display", Optional = true, AcceptThis = { 
	--		['exp'] = true,
	--		['score'] = true,
	--		['death'] = true,
	--		['kills'] = true
	--	}};
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Type)
		
		local id = player:GetIdentifier();
		local score = self:GetData(id);
		
		local playTime 		= player:GetPlayTime();
		local playTimeRank 	= 1;
		for i, other in pairs(GetPlayers()or{}) do
			if (other.id ~= player.id) then
				if (other:GetPlayTime() > playTime) then
					playTimeRank = playTimeRank + 1;
				end;
			end;
		end;
		playTime		= calcTime(playTime, true, unpack(GetTime_SMH));
		playTimeRank 	= "#" .. playTimeRank .. " / " .. arrSize(GetPlayers()or{});
		
		local premiumStatus = "--- UNLOCKED ---";
		local premiumPerc	= "100.00";
		local premiumTime	= self.cfg.Goals.HoursUntilPremium - 60 - 60;
		
		local gameTime 		= calcTime(score.GameTime, true, unpack(GetTime_SMH));
		local gameTimeRank 	= self:GetPlayerRank(player, eST_GameTime);
		gameTime			= gameTime .. " $9($7#" .. gameTimeRank .. "/" .. arrSize(self.permaScore) .. "$9)"
		gameTimeRank		= "#" .. gameTimeRank .. " / " .. arrSize(self.permaScore);
		
		if (not player:HasAccess(PREMIUM) and (score.GameTime or 0) < premiumTime) then
			premiumStatus 	= calcTime(premiumTime - score.GameTime, true, unpack(GetTime_SMH));
			premiumPerc		= cutNum((score.GameTime / premiumTime) - 100, 2);
			premiumStatus	= premiumStatus .. " $9($4" .. premiumPerc .. "%$9)";
		end;
		
		local kills 	= (score.kills or 0);
		local killsRank = "#" .. self:GetPlayerRank(player, eST_Score) .. " / " .. arrSize(self.permaScore)
		local deaths 	= (score.deaths or 0);
		deaths			= deaths .. " $9($4" .. cutNum((deaths/kills)-100, 2) .. "%$9)"
		local tscore 	= (score.score or 0);
		
		
		local levelRank 	= ATOMLevelSystem:GetLevelRank(player);
		local level 		= player:GetLevel() .. " $9($7#" .. levelRank .. "$9)";
		local exp 			= player:GetEXP();
		local nextLevel 	= player.levelStats.NextLevel;
		local nextLevelPerc	= cutNum(((ATOMLevelSystem:GetNextLevelEXP(player:GetLevel()) - (player.levelStats.NextLevel - player.levelStats.EXP))/ATOMLevelSystem:GetNextLevelEXP(player:GetLevel())) - 100, 2);
		local nextLevelEXP	= ATOMLevelSystem:GetNextLevelEXP(player:GetLevel()) .. " $9($4" .. nextLevelPerc .. "%$9)";
		
		local bank 				= player:GetBank();
		local bankPrestige 		= bank.Prestige .. "PP";
		local bankPrestigePerc	= cutNum((bank.Prestige/bank.MaxPrestige) - 100, 2);
		local bankPrestigeRank	= "#" .. ATOMBank:GetBankRank(player) .. " / " .. arrSize(ATOMBank.savedBank);
		local bankMaxPrestige 	= bank.MaxPrestige .. " $9($4" .. bankPrestigePerc .. "%$9)";
		local bankBonus		 	= ATOMBank:GetDailyBonus(bank.Prestige);
		
		local IP		 = player:GetIP();
		local profile	 = player:GetProfile();
		local host		 = player:GetHostName();
		local country	 = player:GetCountry();
		
		local access	 = player:GetGroupData();
		local color		 = access[4]
		access			 = color .. access[2];
		
		local playerName = player:GetName():sub(1, 45);
		
		local wallJump 	 = (score.BestWJ or 0) .. "m";
		
		
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[             IP $9| $1" .. string.lenprint(IP, 25) 				.. " $9]          Profile $9| $4" .. string.lenprint(profile, 45) 		.. "$9]");
		SendMsg(CONSOLE, player, "$9[        Country $9| $5" .. string.lenprint(country, 25) 			.. " $9]             Host $9| $1" .. string.lenprint(host, 45) 			.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[         Access $9| " .. string.lenprint(access, 25) 				.. " $9]             Name $9| $5" .. string.lenprint(playerName, 45) 		.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[          Score $9| $4" .. string.lenprint(tscore, 25) 			.. " $9]             Rank $9| $7" .. string.lenprint(killsRank, 45) 		.. "$9]");
		SendMsg(CONSOLE, player, "$9[          Kills $9| $4" .. string.lenprint(kills, 25) 				.. " $9]           Deaths $9| $4" .. string.lenprint(deaths, 45) 			.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[      Play Time $9| $4" .. string.lenprint(gameTime, 25) 			.. " $9]          Premium $9| $4" .. string.lenprint(premiumStatus, 45)	.. "$9]");
		SendMsg(CONSOLE, player, "$9[     Match Time $9| $5" .. string.lenprint(playTime, 25) 			.. " $9]             Rank $9| $7" .. string.lenprint(playTimeRank, 45)	.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[          Level $9| $4" .. string.lenprint(level, 25) 				.. " $9]              EXP $9| $7" .. string.lenprint(exp, 45)				.. "$9]");
		SendMsg(CONSOLE, player, "$9[     Next Level $9| $4" .. string.lenprint(nextLevel, 25) 			.. " $9]              EXP $9| $7" .. string.lenprint(nextLevelEXP, 45)	.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[           Bank $9| $4" .. string.lenprint(bankPrestige, 25)		.. " $9]          Maximum $9| $6" .. string.lenprint(bankMaxPrestige, 45)	.. "$9]");
		SendMsg(CONSOLE, player, "$9[      Rich-Rank $9| $7" .. string.lenprint(bankPrestigeRank, 25)	.. " $9]      Daily Bonus $9| $6" .. string.lenprint(bankBonus, 45)		.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");
		SendMsg(CONSOLE, player, "$9[  Best WallJump $9| $4" .. string.lenprint(wallJump, 25) 			.. " $9]                  $9  $6" .. string.lenprint("", 45)		.. "$9]");
		SendMsg(CONSOLE, player, "$9================================================================================================================");

		return true;
	end;
});

-------------------------------------------------------------------
-- !toadmins

NewCommand({
	Name 	= "toadmins",
	Access	= GUEST,
	Console = true,
	Description = "Sends a Message to all Administrators in the Server";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Message", "The Message you wish to send to admins", Concat = true, Required = true, Length = { 5, 1000 } };
	};
	Properties = {
	--	Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(player, message)
		if (player:HasAccess(ADMINISTRATOR) and not player:HasAccess(DEVELOPER)) then
			return false, "Cannot be used as staff member";
		end;
		local admins = GetPlayers(ADMINISTRATOR)
		if (not admins or arrSize(admins) < 1) then
			return false, "no Staff members online";
		elseif (arrSize(admins) == 1 and admins[1].id == player.id) then
			return false, "you are the only staff member online";
		end;
		SendMsg(CHAT_ADMIN, player, "(YOU: %s)", message);
		SendMsg(CHAT_ADMIN, RemovePlayer(admins, player.id), "(%s: %s)", player:GetName(), message);
		return true;
	end;
});

-------------------------------------------------------------------
-- !pm

NewCommand({
	Name 	= "pm",
	Access	= GUEST,
	Console = true,
	Description = "Sends a PM to a player or starts a new PM Conversation";
	Args = {
		{ "Player",	"The Name of the player to send a PM to", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Message", "The message you wish to send", Concat = true, Optional = true, Length = { 1, 1000 } };
	};
	Properties = {
		Self = 'ATOMChat',
		NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, target, message)
		if (not message) then
			return self:AddToPM(player, target);
		else
			return self:SendPM(player, target, message);
		end;
		return true;
	end;
});

-------------------------------------------------------------------
-- !transfer

NewCommand({
	Name 	= "transfer",
	Access	= GUEST,
	Console = true,
	Description = "Transfers prestige points to a player";
	Args = {
		{ "Player",	"The Name of the player you wish to transfer prestige to", NotPlayer = true, Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Prestige", "The amount of prestige points to transfer", Integer = true, PositiveNumber = true, Required = true, Length = { 1, 1000000 } };
	};
	Properties = {
		Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, target, prestige)
		local curr = player:GetPrestige();
		if (curr == 0) then
			return false, "you have no prestige left";
		end;
		if (prestige > curr) then
			prestige = curr;
		end;
		player:PayPrestige(prestige);
		target:GivePrestige(prestige);
		SendMsg(CENTER, player, "You Transferred [ %d ] Prestige to %s", prestige, target:GetName());
		SendMsg(CENTER, target, "You Received [ %d ] Prestige from %s", prestige, player:GetName());
		return true;
	end;
});

-------------------------------------------------------------------
-- !report

NewCommand({
	Name 	= "report",
	Access	= GUEST,
	Console = true,
	Description = "Reports a player to the Modertors";
	Args = {
		{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, target, reason)
		return self:Report(player, target, reason);
	end;
});

-------------------------------------------------------------------
-- !apply

NewCommand({
	Name 	= "apply",
	Access	= GUEST,
	Console = true,
	Description = "Creates a Staff Application";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Reason", "Your Reason why you wish to become a Staff Member", Concat = true, Required = true, Length = { 3, 36 } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
		Level = 20,
	};
	func = function(self, player, reason)
		return self:ApplyForStaff(player, reason);
	end;
});

-------------------------------------------------------------------
-- !soundbug

NewCommand({
	Name 	= "soundbug",
	Access	= GUEST,
	Console = true,
	Description = "Debugs your Sound";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 30,
	};
	func = function(self, player, target)
		ExecuteOnPlayer(player, [[local x=System.ExecuteCommand;x("s_soundenable 0")x("s_soundenable 1");]]);
		SendMsg(CHAT_ATOM, player, "(SOUND: Debugged)");
		return true;
	end;
});


-------------------------------------------------------------------
-- !hitinfo

NewCommand({
	Name 	= "hitinfo",
	Access	= GUEST,
	Console = true,
	Description = "Shows hit info";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
	--	Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self)
		self.HitInfo = not self.HitInfo;
		SendMsg(CHAT_ATOM, self, "(HITINFO: %s)", (self.HitInfo and "Enabled" or "Disabled"));
		return true;
	end;
});



-------------------------------------------------------------------
-- !kills

NewCommand({
	Name 	= "kills",
	Access	= GUEST,
	Console = true,
	Description = "Shows kills in console";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
	--	Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self)
		self.KillLogs = not self.KillLogs;
		SendMsg(CHAT_ATOM, self, "(KILLS: %s)", (self.KillLogs and "Enabled" or "Disabled"));
		return true;
	end;
});


-------------------------------------------------------------------
-- !deathkills

NewCommand({
	Name 	= "deathkills",
	Access	= GUEST,
	Console = true,
	Description = "Toggle death kills";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
	--	Self = 'ATOMReports',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self)
		self.DeathKills = not self.DeathKills;
		self.actor:ToggleDeathKills(self.DeathKills);
		SendMsg(CHAT_ATOM, self, "(DEATHKILLS: %s)", (self.DeathKills and "Enabled" or "Disabled"));
		return true;
	end;
});



-------------------------------------------------------------------
-- !lock

NewCommand({
	Name 	= "lock",
	Access	= GUEST,
	Console = true,
	Description = "Locks your current or last entered vehicle";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMVehicles',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self, player)
		return self:LockVehicle(player);
	end;
});

-------------------------------------------------------------------
-- !afk

NewCommand({
	Name 	= "afk",
	Access	= GUEST,
	Console = true,
	Description = "Enters AFK mode";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Reason", "What are u doin lol", Concat = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMAFK',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self, player, r)
		return self:ToggleAFK(player, r);
	end;
});

-------------------------------------------------------------------
-- !afk

NewCommand({
	Name 	= "sleep",
	Access	= GUEST,
	Console = true,
	Description = "Enters AFK mode";
	Args = {
	--	{ "Player",	"The Name of the player you wish to report", Required = true, Target = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Reason", "What are u doin lol", Concat = true, Optional = true };
	};
	Properties = {
		Self = 'ATOMAFK',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self, player, r)
		return self:ToggleAFK(player, r, true);
	end;
});

-------------------------------------------------------------------
-- !lock

NewCommand({
	Name 	= "unlock",
	Access	= GUEST,
	Console = true,
	Description = "Unlocks your current or last entered vehicle";
	Args = {
		{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMVehicles',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 1,
	};
	func = function(self, player, target)
		return self:UnlockVehicle(player, target);
	end;
});

-------------------------------------------------------------------
-- !taxi

NewCommand({
	Name 	= "taxi",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a Taxi for you";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 10,
		Cost = 50,
	};
	func = function(self, player)
		SendMsg(CHAT_ATOM, player, "Here is your Taxi!");
		return self:Spawn({ AdjustPos = true, Count = (Amount or 1), Name = "ATOMIC-Super-Cab-%d", Class = "Civ_car1", Dir = player:GetDirectionVector(), Pos = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}), Tags = { ['CmdSpawned'] = true } }, player);
	end;
});

-------------------------------------------------------------------
-- !taxi

NewCommand({
	Name 	= "audi",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a audi for you";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 10,
		Cost = 50,
	};
	func = function(self, player)
		SendMsg(CHAT_ATOM, player, "Here is your AUDI R8!");
		-- local v = self:Spawn({ AdjustPos = true, Count = (Amount or 1), Name = "ATOMIC-Super-Cab-%d", Class = "Civ_car1", Dir = player:GetDirectionVector(), Pos = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}), Tags = { ['CmdSpawned'] = true } }, player);
		Script.SetTimer(1, function()
			local v = System.SpawnEntity({ name = string.format("ATOMIC-Super-Cab-%d",math.random(1,99999)), class = "Civ_car1", orientation = player:GetDirectionVector(), position = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) });
			self:LoadVehicleModel(v, "objects/library/vehicles/cars/car_b_chassi.cgf", { x = 0, y = 0.350, z = 0.30 }, makeVec(0,0,0),			false,		 nil);
		end)
	end;
});

-------------------------------------------------------------------
-- !taxi

NewCommand({
	Name 	= "tesla",
	Access	= GUEST,
	Console = true,
	Description = "Spawns a audi for you";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Reason", "The Reason for the Report", Concat = true, Required = true, Length = { 1, 36 } };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 10,
		Cost = 50,
	};
	func = function(self, player)
		SendMsg(CHAT_ATOM, player, "Here is your TESLA!");
		-- local v = self:Spawn({ AdjustPos = true, Count = (Amount or 1), Name = "ATOMIC-Super-Cab-%d", Class = "Civ_car1", Dir = player:GetDirectionVector(), Pos = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}), Tags = { ['CmdSpawned'] = true } }, player);
		-- self:LoadVehicleModel(v, "objects/library/vehicles/cars/car_a.cgf", 									{ x = 0, y = 0.350, z = 0.50 }, makeVec(0,0,0),			false,		 nil);
		Script.SetTimer(1, function()
			local v = System.SpawnEntity({ name = string.format("ATOMIC-Super-Cab-%d",math.random(1,99999)), class = "Civ_car1", orientation = player:GetDirectionVector(), position = add2Vec((player:CalcSpawnPos(4)), { x = 0, y = 0, z = -1}) });
			self:LoadVehicleModel(v, "objects/library/vehicles/cars/car_a.cgf", 									{ x = 0, y = 0.350, z = 0.50 }, makeVec(0,0,0),			false,		 nil);
		end)
	end;
});


-------------------------------------------------------------------
-- !login

NewCommand({
	Name 	= "login",
	Access	= GUEST,
	Console = true,
	Description = "Logs in to a registered user account";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Account", "The Name of the Account", Required = true };
		{ "Password", "The password of the Account", Concat = true, Required = true };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 30,
	--	Cost = 50,
	};
	func = function(self, player, account, password)
		return self:Login(player, account, password);
	end;
});


-------------------------------------------------------------------
-- !setpw

NewCommand({
	Name 	= "setpw",
	Access	= GUEST,
	Console = true,
	Description = "Changes the password of your account";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
		{ "Password", "The new password", Concat = true, Required = true, Length = { 1, 26 } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 30,
	--	Cost = 50,
	};
	func = function(self, player, password)
		return self:ChangePassword(player, password);
	end;
});


-------------------------------------------------------------------
-- !setname

NewCommand({
	Name 	= "setname",
	Access	= GUEST,
	Console = true,
	Description = "Changes the name of your account";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
		{ "Name", "The new Name", Concat = false, Required = true, Length = { 1, 26 } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 30,
	--	Cost = 50,
	};
	func = function(self, player, name)
		return self:ChangeUsername(player, name);
	end;
});

-------------------------------------------------------------------
-- !mypw

NewCommand({
	Name 	= "mypw",
	Access	= GUEST,
	Console = true,
	Description = "Shows the password of your Account";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Password", "The new password", Concat = true, Required = true, Length = { 1, 26 } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 30,
	--	Cost = 50,
	};
	func = function(self, player)
		return self:GetPassword(player);
	end;
});

-------------------------------------------------------------------
-- !chat

NewCommand({
	Name 	= "chat",
	Access	= GUEST,
	Console = true,
	Description = "Toggles Server Chat Messages (Killing, Walljumping, ect)";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Password", "The new password", Concat = true, Required = true, Length = { 1, 26 } };
	};
	Properties = {
	--	Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
	--	Timer = 30,
	--	Cost = 50,
	};
	func = function(self)
		if (not self.bKillMessages) then
			self.bKillMessages = true
		else
			self.bKillMessages = false
		end
		SendMsg(CHAT_ATOM, self, "(POPUPS: %s)", (self.bKillMessages and "Enabled" or "Disabled"))
	end;
});

-------------------------------------------------------------------
-- !reset

NewCommand({
	Name 	= "reset",
	Access	= GUEST,
	Console = true,
	Description = "Resets your Score and Rank";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Password", "The new password", Concat = true, Required = true, Length = { 1, 26 } };
	};
	Properties = {
		Self = 'ATOM_Usergroups',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 300,
	--	Cost = 50,
	};
	func = function(self, player)
		local playerID = player.id;
		g_game:SetSynchedEntityValue(playerID, g_gameRules.SCORE_KILLS_KEY, 0);
		g_game:SetSynchedEntityValue(playerID, g_gameRules.SCORE_DEATHS_KEY, 0);
		g_game:SetSynchedEntityValue(playerID, g_gameRules.SCORE_HEADSHOTS_KEY, 0);
		if (g_gameRules.class == "PowerStruggle") then
			g_gameRules:SetPlayerPP(playerID, 100);
			g_gameRules:SetPlayerCP(playerID, 0);
			g_gameRules:SetPlayerRank(playerID, 1);
		end;
		ATOMStats.PersistantScore:Reset(player)

		SendMsg(CHAT_ATOM, player, "Your score and rank was Reset!");
	end;
});


-------------------------------------------------------------------
-- !resetlevel

NewCommand({
	Name 	= "resetlevel",
	Access	= GUEST,
	Console = true,
	Description = "Resets your level to 0";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Password", "The new password", Concat = true, Required = true, Length = { 1, 26 } };
	};
	Properties = {
		Self = 'ATOMLevelSystem',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle'
		Timer = 300,
	--	Cost = 50,
	};
	func = function(self, player, target)
		if (not player.doResetLevel) then
			player.doResetLevel = true;
			return false, "are you sure? use this command again to reset your level.";
		end;
		player.doResetLevel = false;
		self:ResetLevel(player, target);
		SendMsg(CHAT_ATOM, player, "Your Level was Reset");
		return true;
	end;
});

-------------------------------------------------------------------
-- !airdrop

NewCommand({
	Name 	= "airdrop",
	Access	= GUEST,
	Console = true,
	Description = "Requests an Airdrop to deliver you Weapons";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
		{ "Items", "The name of the items you wish to order", Required = true };
	};
	Properties = {
		Self = 'ATOMAirDrop',
	--	NoChatLog = true
	--	NoLog = true,
		GameRules = 'PowerStruggle',
		IgnoreUsers = SUPERADMIN,
		Timer = 150,
	--	Cost = 50,
	};
	func = function(self, player, ...)
		local items = { ... };
		local fixedItems = {}
		for i, item in pairs(items) do
			local sFixed = g_utils:IsValidGun(item, self.cfg.ForbiddenItems)
			if (sFixed) then
				table.insert(fixedItems, sFixed);
			else
				SendMsg(CHAT_ATOM, player, "(AIRDROP: %s - Invalid Item Removed)", item);
			end;
		end;
		if (arrSize(fixedItems) == 0) then
			return false, "no valid items to order found";
		end;
		local totalPrice = 0;
		local totalPP = player:GetPrestige();
		if (totalPP == 0) then
			return false, "insufficient prestige";
		end;
		for i, item in pairs(fixedItems) do
			totalPrice = totalPrice + (g_utils:GetItemPrice(item) or 0)
			if (totalPrice > totalPP) then
				table.remove(fixedItems, i);
				SendMsg(CHAT_ATOM, player, "(AIRDROP: %s - Removed (Insufficient Prestige))", item);
			else
			end;
		end;
		if (arrSize(fixedItems) == 0) then
			return false, "not enough prestige";
		end;
		SendMsg(CHAT_ATOM, player, "(AIRDROP: %s - Will be ordered (Total Cost: %d))", table.concat(fixedItems, ", "), totalPrice);
		player:PayPrestige(totalPrice);
		self:Spawn(player, player, 1200, fixedItems)
	end;
});

-------------------------------------------------------------------
-- !boxing

NewCommand({
	Name 	= "boxing",
	Access	= GUEST,
	Console = true,
	Description = "Enter the boxing arena";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Items", "The name of the items you wish to order", Required = true };
	};
	Properties = {
		Self = 'ATOMBoxingArea',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
		NoSpec = true,
		Alive = true,
	};
	func = function(self, player)
		return self:Enter(0, player);
	end;
});

-------------------------------------------------------------------
-- !pvp

NewCommand({
	Name 	= "pvp",
	Access	= GUEST,
	Console = true,
	Description = "Enter the pvp arena";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Items", "The name of the items you wish to order", Required = true };
	};
	Properties = {
		Self = 'ATOMBoxingArea',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
		NoSpec = true,
		Alive = true,
	};
	func = function(self, player)
		return self:Enter(1, player);
	end;
});

-------------------------------------------------------------------
-- !arena

NewCommand({
	Name 	= "arena",
	Access	= GUEST,
	Console = true,
	Description = "Enters specified arena";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Account", "The Name of the Account", Required = true };
	--	{ "Items", "The name of the items you wish to order", Required = true };
		{ "Arena", "The id of the arena you wish to enter", Required = true, Integer = true, PositiveNumber = true };
	};
	Properties = {
		Self = 'ATOMBoxingArea',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
		NoSpec = true,
		Alive = true,
	};
	func = function(self, player, iArena)
		return self:Enter(2, player, iArena, true)
	end;
});

-------------------------------------------------------------------
-- !vote

NewCommand({
	Name 	= "vote",
	Access	= GUEST,
	Console = true,
	Description = "Start a new voting";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
		{ "Type", "The Type of the vote you wish to start", Required = true };
		{ "Arguments", "The required arguments for the specified vote", Optional = true };
	};
	Properties = {
		Self = 'ATOMVote',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
	--	NoSpec = true,
	--	Alive = true,
	};
	func = function(self, player, topic, ...)
		return self:StartVote(player, topic, ...);
	end;
});

-------------------------------------------------------------------
-- !yes

NewCommand({
	Name 	= "yes",
	Access	= GUEST,
	Console = true,
	Description = "Vote for YES in the current voting";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "The Type of the vote you wish to start", Required = true };
	--	{ "Arguments", "The required arguments for the specified vote", Optional = true };
	};
	Properties = {
		Self = 'ATOMVote',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
	--	NoSpec = true,
	--	Alive = true,
	};
	func = function(self, player)
		return self:SubmitVote(player, true);
	end;
});

-------------------------------------------------------------------
-- !no

NewCommand({
	Name 	= "no",
	Access	= GUEST,
	Console = true,
	Description = "Vote for NO in the current voting";
	Args = {
	--	{ "Player",	"Unlock vehicles for this specific player", Optional = true, Target = true, NotPlayer = true, AccepALL = true }, --AcceptThis }, --= {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "The Type of the vote you wish to start", Required = true };
	--	{ "Arguments", "The required arguments for the specified vote", Optional = true };
	};
	Properties = {
		Self = 'ATOMVote',
	--	NoChatLog = true
	--	NoLog = true,
	--	GameRules = 'PowerStruggle',
	--	IgnoreUsers = SUPERADMIN,
	--	Timer = 150,
	--	Cost = 50,
	--	NoSpec = true,
	--	Alive = true,
	};
	func = function(self, player)
		return self:SubmitVote(player, false);
	end;
});


-------------------------------------------------------------------
-- !proto

NewCommand({
	Name 	= "proto",
	Access	= GUEST,
	Console = true,
	Description = "Spawn a portal to teleport to the Prototype factory";
	Args = {

	};
	Properties = {
		Self = 'ATOMAirDrop',
	--	NoChatLog = true
	--	NoLog = true,
		Ground = true,
		Indoors = false,
		GameRules = 'PowerStruggle',
		IgnoreUsers = DEVELOPER,
		Timer = 300,
		OnlyAlive = true,
		NoSpec = false
	--	Cost = 50,
	};
	func = function(self, player)
		
		if (not self) then
		---	return false, "plugin not loaded"
		end
		
		local spawnPos = add2Vec(fixPos(player:CalcSpawnPos(5, 2)), makeVec(0,0,-1));
		if (not player:CanSee(spawnPos)) then
			return false, "terrain/objects ahead";
		end;
		local spawnDir = player:GetDirectionVector();
		
		local protoPos = g_utils:GetBuilding("proto");
		if (not protoPos) then
			return false, "no proto found";
		end;
		
		if (GetDistance(spawnPos, protoPos) < 50) then
			return false, "you are already at the prototype factory";
		end;
		
		Debug(spawnDir)
		Debug(spawnPos)
		
		local portal_main = SpawnGUINew({ Model = "Objects/library/alien/props/gravity_stream_rings/gravity_stream_ring_main.cgf", bStatic = true, Mass = -1, Pos = spawnPos, Dir = spawnDir });
		local portal_support = SpawnGUINew({ Model = "Objects/library/alien/props/gravity_stream_rings/gravity_stream_ring_support.cgf", bStatic = true, Mass = -1, Pos = spawnPos, Dir = spawnDir });
		local portal_forcefield = SpawnGUINew({ Model = "Objects/library/alien/props/forcefield/forcefield_small.cgf", bStatic = true, Mass = -1, Pos = spawnPos, Dir = spawnDir });
		
		portal_main:SetScale(0.5);
		portal_support:SetScale(0.5);
		portal_forcefield:SetScale(0.37 * 0.5);
		
		
		portal_main.isPortal = true
		portal_support.isPortal = true
		portal_forcefield.isPortal = true
			
		
		player.PortalTimer = Script.SetTimer(60000, function()
			Countdown(player, 10, 1, function(p, s, d)
				if (d) then
					System.RemoveEntity(portal_main.id);
					System.RemoveEntity(portal_support.id);
					System.RemoveEntity(portal_forcefield.id);
					SendMsg(CENTER, p, "Your portal was removed");
				elseif (s < 10) then
					SendMsg(CENTER, p, "Your portal will be removed in [ %d ] Seconds!", s);
				end;
			end);
		end);
		
		SendMsg(CHAT_ATOM, ALL, "%s: Opened a portal to the prototype factory", player:GetName());
		
		g_utils:CreatePortal({
			Pos = spawnPos,
			Range = 2.5,
			Out = add2Vec(protoPos, makeVec(0,0,100)),
			Msg = "You were teleported to the Prototype Factory",
			Enter = "Portal to the Prototype Factory [ %0.2fm ]",
			linked = portal_main.id,
			AllowVehicles = true
		});
	end;
});
