ATOMAFK = {
	cfg = {
		UseAFKBed = false,
	},
	---------------
	Init = function(self)
		RegisterEvent("OnTick", self.OnTick, 'ATOMAFK')
	--	RegisterEvent("OnClientInstalled", self.OnClientInstalled, self)
	end,
	---------------
	OnTick = function(self)

		for i, hPlayer in pairs(GetPlayers()) do
			if (hPlayer.AFK) then
				hPlayer:LeaveVehicle()
				if (hPlayer.AFK.Bed) then
					if (GetDistance(hPlayer, hPlayer.AFK.AFKPos) > 0.1) then
						g_game:MovePlayer(hPlayer.id, hPlayer.AFK.AFKPos, hPlayer.AFK.AFKAng);
					end
				elseif (GetDistance(hPlayer, hPlayer.AFK.AFKPos) > 1) then
					g_game:MovePlayer(hPlayer.id, hPlayer.AFK.AFKPos, hPlayer.AFK.AFKAng);
					SendMsg(CENTER, hPlayer, "STAY IN UR AFK %s !!", (hPlayer.AFK.AFKBed and "BED" or "CAGE"))
					g_utils:SpawnEffect(ePE_Light, hPlayer:GetPos())
				end
			end
		end
		
	end,
	---------------
	OnClientInstalled = function(self, player)
		for i, AFK in pairs(GetPlayers()) do
			if (AFK.AFK) then
				if (AFK.AFK.AFKBed) then
					SysLog("Syncing AFK Bed")
					Script.SetTimer(100, function()
						ExecuteOnAll(formatString(AFK.AFK.AFKCode, AFK:GetName(), AFK.AFK.AFKBed:GetName()));
					end)
				end
			end
		end
	end,
	---------------
	ToggleAFK = function(self, player, whyLol, forceBed)
	
		if (not player.AFK) then
			return self:EnterAFK(player, whyLol, forceBed)
		end
		
		return self:LeaveAFK(player, player.AFK)
	
		-- local s, e;
		-- if (not player.AFK) then
			-- s, e = self:EnterAFK(player, whyLol, forceBed);
		-- else
			-- s, e = self:LeaveAFK(player, player.AFK);
		-- end;
		-- return s, e;
	end,
	---------------
	LeaveAFK = function(self, player, afk)
		if (afk.AFKBed) then
			Script.SetTimer(100, function()
				ExecuteOnAll([[
					local p = GetEnt(']] .. player:GetName() .. [[')
					if (p and p.actor) then
						p:StopAnimation(0,-1)
						Script.SetTimer(1, function()
						p:StartAnimation(0,"relaxed_sleepingWithHatOnFaceEnd_hat_01")
						end)
						Script.SetTimer(4500, function()
							p:StopAnimation(0,-1)
							STICKY_POSITIONS[p.id] = nil;
							FI(p)
						end);
					end;
				]])
			end);
			local pillowId = afk.AFKBed.Pillow and afk.AFKBed.Pillow.id;
			local bedId = afk.AFKBed.id;
			Script.SetTimer(6000, function()
				if (pillowId) then
					System.RemoveEntity(pillowId);
				end;
				System.RemoveEntity(bedId);
				player.AFKFinished = true;
			end);
		else
			local cage_parts = afk.AFKCage;
			for i, v in pairs(cage_parts) do
				System.RemoveEntity(v.id);
			end;
			player.AFKFinished = true;
			g_game:MovePlayer(player.id, add2Vec(player.AFK.AFKPos, { x = 0, y = 0, z = -1000 }), player:GetAngles());
			g_utils:SpawnEffect(ePE_Light, player:GetPos())
		end;
		player.AFK = nil;
		
		self:SetAFKTag(player, false);
		self:AnnounceAFK(player, false, nil);
		
		if (not player.godMode) then
			player.invulnerable = false;
		--	g_game:SetInvulnerability(player.id, true, 1);
		end;
	end,
	---------------
	EnterAFK = function(self, player, whyLol, forceBed)
		if (player.actor:IsFlying()) then
			return false, "you must be standing on the ground";
		end;
		if (player:GetVehicle()) then
			return false, "leave your vehicle";
		end;
		if (player:IsSpectating()) then
			return false, "not while spectating";
		end;
		if (player:IsUnderwater()) then
			return false, "not underwater";
		end;
		if (player:IsIndoors()) then
			return false, "not indoors";
		end;
		if (player.AFKFinished == false) then
			return false, "slow down";
		end;
		
		player:LeaveVehicle();
		
		local pos = player:CalcSpawnPos(1); --GetPos();
		local ang = player:GetAngles();
		local sleepAnims = {
			"",
		};
		local ray = RayHit(add2Vec(pos, makeVec(0, 0, 1)), g_Vectors.down, 5);
		--local pos_ray;
		if (ray) then
			pos = ray.pos;
			--Debug("Fixed position using ray hits");
		end;
		
		if (player.ATOM_Client and (forceBed or self.cfg.UseAFKBed)) then
		--	Debug("B afk");
			pos.z = pos.z + 1
			local code = [[
				local p = GetEnt('%s')
				local b = GetEnt('%s');
				if (p and b and p.actor) then
					STICKY_POSITIONS[p.id] = { ]] .. arr2str_(pos) .. [[, -2, -1.4 };
					LOOPED_ANIMS[p.id]={Start = _time,Entity = p,Loop = -1,Timer= 0,Speed = 1,Anim = {"relaxed_idleSleep_nw_01","cineMine_ab5_barnesdying_03400_02","relaxed_guyDyingOnStretcher_01","relaxed_sleepingWithHatOnFaceLoop_hat_01"},NoSpec= true,Alive=true,NoWater=true };
					FI(p,1)
				end;
			]];
			pos.z = pos.z - 1
			player.AFK = {
				AFKPos		= pos,
				AFKAng		= ang,
				AFKBed	 	= self:SpawnAFKBed(pos);
				AFKCode		= code;
			};
			Script.SetTimer(1000, function()
				ExecuteOnAll(formatString(code, player:GetName(), player.AFK.AFKBed:GetName()));
			end);
		else
		--	Debug("N afk");
			pos.z = pos.z + 1000;
			player.AFK = {
				AFKPos		= makeVec(pos.x + 0.5, pos.y, pos.z),
				AFKAng		= ang,
				AFKCage 	= self:SpawnAFKCage(pos);
			};
			g_utils:SpawnEffect(ePE_Light, pos)
		end;
		player.invulnerable = true;
		g_game:SetInvulnerability(player.id, true, 1);
		self:SetAFKTag(player, true); -- must be done before client code
		self:AnnounceAFK(player, true, whyLol);
		player.AFKFinished = false;
		return true;
	end,
	---------------
	SetAFKTag = function(self, hPlayer, bEnable)
	
		ATOMNames:AddNameTag(hPlayer, "(AFK) ", bEnable)
		--[[
		local tag = self.cfg.AFKTag or "[AFK]";
		local name = player:GetName();
		--Debug("AFK Name then:"..name)
		local has_tag = ATOMNames:HasTag(name, tag);
		if (enable) then
			if (not has_tag) then
				name = ATOMNames:AddTag(name, tag);
			end;
		elseif (has_tag) then
			name = ATOMNames:RemoveTag(name, tag);
		end;
		--Debug("AFK Name now:"..name)
		g_game:RenamePlayer(player.id, name);
		--]]
	end,
	---------------
	AnnounceAFK = function(self, player, enable, whyLol)
		if (enable) then
			SendMsg(CHAT_AFK, ALL, "%s: Is %s: %s", player:GetName(), (player.AFK.AFKBed and "Taking a nap" or "AFK"), (whyLol or "AFK"));
			ATOMLog:LogGameUtils("", "%s$9 is %s", player:GetName(), player.AFK.AFKBed and "Taking a nap" or ("AFK" .. ": " .. (whyLol or "AFK")));
		else
			SendMsg(CHAT_AFK, ALL, "%s: Is Back in Game", player:GetName());
			ATOMLog:LogGameUtils("", "%s$9 Is Back In Game", player:GetName());
		end;
	end,
	---------------
	SpawnAFKBed = function(self, pos)
		local hBed = SpawnGUI("Objects/library/furniture/beds/bed_wooden.cgf", pos, -1, nil, {x=0,y=0,z=0}, true, 1, 100);
		hBed.Pillow = SpawnGUI("Objects/library/furniture/beds/pillow.cgf", add2Vec(pos,{x=-1,y=0,z=0.7}), -1, nil, {x=0,y=0,z=0}, true, 1, 100)
		
		return hBed
	end,
	---------------
	SpawnAFKCage = function(self, pos)
		local cage_parts = {};
		
		pos.y = pos.y + 3
		cage_parts.part1 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=0,y=0,z=0}, true, 1, 100);
		
		pos.y = pos.y - 6
		cage_parts.part2 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=0,y=0,z=0}, true, 1, 100);
		
		pos.x = pos.x + 3
		pos.y = pos.y + 3
		cage_parts.part3 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=0,y=1,z=0}, true, 1, 100);
		
		pos.x = pos.x - 6
		cage_parts.part4 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=0,y=1,z=0}, true, 1, 100);
		
		pos.x = pos.x - 0.2
		pos.z = pos.z + 3.45
		cage_parts.part5 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=tonumber(x),y=tonumber(y),z=tonumber(z)}, true, 1, 100);
		cage_parts.part5:SetAngles({ x = 0, y = 1.572, z = 0});
		
		pos.x = pos.x + 2.8;
		cage_parts.part6 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=tonumber(x),y=tonumber(y),z=tonumber(z)}, true, 1, 100);
		cage_parts.part6:SetAngles({ x = 0, y = 1.572, z = 0});
		
		pos.z = pos.z - 3.45
		cage_parts.part7 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=tonumber(x),y=tonumber(y),z=tonumber(z)}, true, 1, 100);
		cage_parts.part7:SetAngles({ x = 0, y = 1.572, z = 0});
		
		pos.x = pos.x - 2.8
		cage_parts.part8 = SpawnGUI("Objects/library/barriers/concrete_wall/gate_6m.cgf", pos, -1, nil, {x=tonumber(x),y=tonumber(y),z=tonumber(z)}, true, 1, 100);
		cage_parts.part8:SetAngles({ x = 0, y = 1.572, z = 0});
		
		return cage_parts;
	end,
	---------------
	---------------
	



};

ATOMAFK:Init()