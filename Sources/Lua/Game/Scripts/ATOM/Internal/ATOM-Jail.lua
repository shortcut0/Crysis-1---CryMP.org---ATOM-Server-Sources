ATOMJail = {
		temp = ATOMJail ~= nil and ATOMJail.temp or { jailed = {}; }; --(SinepGPUtils~=nil and SinepGPUtils.Jail~=nil) and SinepGPUtils.Jail.temp or {jailed={}}; -- we must not loose previous jailed players!!
		jail = ATOMJail ~= nil and ATOMJail.jail or { parts = {}; visitPoints = {}; }; --(SinepGPUtils~=nil and SinepGPUtils.Jail~=nil) and SinepGPUtils.Jail.jail or {parts={};visitPoints={};}; -- we must not loose previous created jail!!
		perma = ATOMJail ~= nil and ATOMJail.perma or { jailed = {}; }; --(SinepGPUtils~=nil and SinepGPUtils.Jail~=nil) and SinepGPUtils.Jail.perma or { jailed = {}; };
		cfg = {
			PermaJail = true; -- if true, even reconnecting wont unjail. :P
		};
		-----------------
		Init = function(self)
		
			-- Load file
			self:LoadFile();
		
			-- Register events
			RegisterEvent("OnTick", self.OnTick, 'ATOMJail');
		end;
		-----------------
		CheckHit = function(self, hit)
		
			if (not self.cfg.enabled) then 
				return end
			
			if (self:IsJailed(hit.shooterId)) then
				SendMsg(CENTER, shooter, "PRISONERS CANNOT DAMAGE OTHER PLAYERS")
				hit.damage = 0
				hit.blocked = true
			end
		end;
		-----------------
		CheckKill = function(self, hit)
			
		end;
		-----------------
		CheckJailed = function(self, player)
			local id = player:GetIdentifier();
			if (id) then
				if (self.perma.jailed[id]) then
					if (not self:IsJailed(player)) then
						player.remainingJailTime = self.perma.jailed[id].t;
						self:JailPlayer(player, self.perma.jailed[id].t, self.perma.jailed[id].r);
					end;
				end;
			end;
		end;
		-----------------
		JailExists = function(self)
			
			---------
			self.jail = checkArray(self.jail, { parts = {}, visitPoints = {} })
			self.temp = checkArray(self.temp, { jailed = {} })
			
			---------
			local bJailOk = (table.count(self.jail.parts) > 0) and (GetEnt(self.jail.parts[1]).id)
			if (bJailOk) then
				return true
			end
			
			---------
			return false
		end,
		-----------------
		CheckJail = function(self, bRebuild, bJail)
			
			---------
			self.jail = checkArray(self.jail, { parts = {}, visitPoints = {} })
			self.temp = checkArray(self.temp, { jailed = {} })
		
			---------
			local iJailed = table.count(self.temp.jailed)
			local iVisitors = table.count(DoGetPlayers({ pos = vector.make(1000, 1000, 1000), range = 30 }))
			if (iVisitors == 0 and not timerexpired(self.LastVisitJailTimer, 60)) then
				iVisitors = 1 end
			
			---------
			if (not bJail and iJailed <= 0 and iVisitors <= 0) then
				self:RemoveJail(true)
				return false end
			
			---------
			local bJailOk = self:JailExists()
			--Debug("JailOK: ",bJailOk)
			if (not bJailOk) then
				if (bRebuild) then
				self:CreateJail(true) end
				return true
			end
		end;
		-----------------
		CreateJail = function(self, force)
		
			if (g_game:GetPlayerCount() < 1) then
				return self:RemoveJail() end
		
			self.jail.parts = self.jail.parts or {};
			if (#self.jail.parts<1 or force) then
				self:RemoveJail();
				local jailParts = {
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=0.000,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=3.125,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250+3.125+3.125,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375+3.125+3.125,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250+3.125+3.125+3.125+3.125,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375+3.125+3.125+3.125+3.125,y=0.000,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=0.000,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=3.125,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250+3.125+3.125,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375+3.125+3.125,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=6.250+3.125+3.125+3.125+3.125,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/architecture/mobile_camp_structures/us_armory/us_armory.cgf", {x=9.375+3.125+3.125+3.125+3.125,y=-14.00,z=0.000}, {x=0,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=0,y=-14.00,z=0.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=8,y=-14.00,z=0.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=16,y=-14.00,z=0.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=24,y=-14.00,z=0.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=0,y=-14.00,z=3.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=8,y=-14.00,z=3.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=16,y=-14.00,z=3.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_edge_8m.cgf",  {x=24,y=-14.00,z=3.000}, {x=1.574,y=0,z=1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=1.4,y=-3.750,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=7.6,y=-3.750,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=1.4,y=-14.00+3.75,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=7.6,y=-14.00+3.75,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=8+6,y=-14.00+3.75,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=8.2+6+6,y=-14.00+3.75,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=8+6,y=-3.750,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "Objects/library/barriers/concrete_wall/gate_6m.cgf",                          {x=8.2+6+6,y=-3.750,z=0.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_c.cgf",        {x=-1.7,y=0,z=5.000}, {x=0,y=0,z=-1.574}, 1};
					{"GUI", "objects/library/architecture/concrete structure/concrete_block_c.cgf",        {x=27.6,y=0,z=5.000}, {x=0,y=0,z=-1.574}, 1};
				};
				local p1 = { x= 1000, y = 1000, z = 1000 };
				local p2 = { x= 1000, y = 1000, z = 1000 };
				for i, part in ipairs(jailParts)do
					p1 = copyTable(p2);
					p1.x = p1.x + part[3].x;
					p1.y = p1.y + part[3].y;
					p1.z = p1.z + part[3].z;
					if (part[1] == "GUI") then
						table.insert(self.jail.parts, SpawnGUI(part[2], p1, -1, part[6], {x=0,y=0,z=0}, true, 1, 100));
					else
						table.insert(self.jail.parts, System.SpawnEntity({class=part[1], name = part[2], position = p1, orientation = {x=0,y=0,z=0}}));
					end;
					self.jail.parts[#self.jail.parts]:SetAngles(part[4]);
					self.jail.parts[#self.jail.parts]:SetFlags(2, 0);
				end;
				p1 = copyTable(p2);
				self.jail.visitPoints = {
					[1] = {{ x = p1.x + 20, y = p1.y - 7, z = p1.z + 1 }, { x = 0, y = 0, z = 1.57764}};
					[2] = {{ x = p1.x + 00, y = p1.y - 7, z = p1.z + 1 }, { x = 0, y = 0, z = -1.57764}};
				};
				self.jail.cells = {
					{used = false, id = 1, area = { x = { 1002, 999}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x - 0, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 2, area = { x = { 1002+3, 999+3}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 3, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 3, area = { x = { 1002+6, 999+6}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 6, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 4, area = { x = { 1002+9, 999+9}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 9, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 5, area = { x = { 1002+12, 999+12}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 12, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 6, area = { x = { 1002+15, 999+15}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 15, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 7, area = { x = { 1002+18, 999+18}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 18, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					{used = false, id = 8, area = { x = { 1002+21, 999+21}, y = { 1001, 996}, z = { 1001, 999}}, spawn = { x = p1.x + 21, y = p1.x - 0, z = p1.z + 1}, angles = { x = 0, y = 0, z = 1.574*2}};
					------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					{used = false, id = 9, area = { x = { 1002, 999}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x - 0, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 10, area = { x = { 1002+3, 999+3}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 3, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 11, area = { x = { 1002+6, 999+6}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 6, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 12, area = { x = { 1002+9, 999+9}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 9, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 13, area = { x = { 1002+12, 999+12}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 12, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 14, area = { x = { 1002+15, 999+15}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 15, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 15, area = { x = { 1002+18, 999+18}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 18, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
					{used = false, id = 16, area = { x = { 1002+21, 999+21}, y = { 989, 984}, z = { 1001, 999}}, spawn = { x = p1.x + 21, y = p1.x - 12, z = p1.z + 1}, angles = { x = 0, y = 0, z = 0}};
				};
			else
				if (force) then
					self:RemoveJail()
					self:CreateJail()
				end
			end
		end;
		-----------------
		RemoveJail = function(self)
			if (self.jail.parts) then
				for i, obj in ipairs(self.jail.parts) do
					System.RemoveEntity(obj.id);
				end;
				self.jail.parts = {};
			end;
		end;
		-----------------
		JailPlayer = function(self, player, time, reason)
			self:CheckJail(true, true);
			local time = tonumber(time);
			if (time and tostring(time)~="-1" and time<60) then 
				time = 60;
			end;
			if (not time) then time=-1 end;
			
			local jailTime;
			
			if (time and tostring(time) ~= "-1") then
				jailTime = calcTime(time, true, unpack(GetTime_SMH));
			end;
			
			if (not self:IsJailed(player.id)) then
				local cell = self:GetFreeCell();
				if (cell) then
					SendMsg(CHAT_ATOM, player, "You have been Jailed for " .. (reason or "BAD BEHAVIOR") .. "%s", ((time and tostring(time)~="-1") and " For " .. jailTime or "!") );
					for i, pl in ipairs(g_gameRules.game:GetPlayers()or{})do
						if (not self:IsJailed(pl.id)) then
							SendMsg(CHAT_ATOM, pl, player:GetName() .. " has been jailed for %s", (reason or "Bad Behavior"));
						end;
					end;
					return self:Jail(player, cell, self.cfg.PermaJail, time, reason);
				else
					return false, "no more free cells";
				end;
			else
				return false, "player already jailed";
			end;
			return true;
		end;
		-----------------
		UnJailPlayer = function(self, player)
			self:CheckJail(true);
			if (self:IsJailed(player.id)) then
				SendMsg(CHAT_ATOM, player, "Your Jailtime is serverd, you are free to go");
				return self:UnJail(player, player.jailId);
			else
				return false, "player not jailed";
			end;
			return false, "error";
		end;
		-----------------
		IsJailed = function(self, id)
			return self.temp.jailed[id] ~= nil;
		end;
		-----------------
		VisitJail = function(self, player)
		
			local iTimer = (self:JailExists() and 1000 or 0)
		
			if (not self:IsJailed(player.id)) then
				if (player.jailVisitPos) then
					self:UnVisitJail(player);
				else
					
					self.LastVisitJailTimer = timerinit()
					self:CheckJail(true)
						
					local point = self.jail.visitPoints[math.random(#self.jail.visitPoints)];
					if (point and point[1] and point[2]) then
						player.jailVisitPos = {
							ang = player:GetAngles();
							pos = player:GetPos();
						};
						
						Script.SetTimer(iTimer, function()
							player.lastSvTeleport = _time;
							g_gameRules.game:MovePlayer(player.id, point[1], point[2]);
							SendMsg(CHAT_ATOM, player, "You teleported to the Jail");
							self:InformPrisoners(player:GetName() .. " came for a visit!");
							SendMsg(INFO, ALL, player:GetName() .. " went to visit the jail, use !visitjail")
						end)
						return true;
					end;
					return false, "failed to visit the jail"
				end;
			else
				return false, "you cannot visit the jail";
			end;
		end;
		-----------------
		IsVisitingJail = function(self, player)
			return player.jailVisitPos~=nil;
		end;
		-----------------
		FeedPrisoner = function(self, feeder, player)
			if (not self.cfg.enabled) then return false, "Jail System is disabled"; end;
			if (self:IsJailed(feeder.id)) then
				return false, "you cannot feed other prisoners";
			end;
			if (not self:IsVisitingJail(feeder)) then
				return false, "you must be in the Jail to feed a prisonder, use !visitjail";
			end;
			if (self:IsJailed(player.id)) then
				if (player.jailId) then
					local cell = self:GetCellById(player.jailId);
					if (cell) then
						if (GetDistance(cell.spawn, feeder:GetPos()) > 5) then
							return false, "you are too far away to feed the prisoner";
						end;
						if (g_gameRules.class == "PowerStruggle") then
							local canPay, missing = SinepUtils:PayPrestige(feeder, 25);
							if (not canPay) then
								return false, "you need " .. missing .. " more pp to feed the prisoner";
							end;
						end;
						local foodClass;
						local futter = {
							{ "Banana", "objects/natural/bananas/banana_bundle1.cgf" };
							{ "Cabbage", "objects/natural/fruits_vegetables/cabbage_breakable.cgf" };
							{ "Melon", "Objects/Library/Props/food/melon/melon.cgf" };
							{ "Honey Melon", "objects/natural/fruits_vegetables/honeymelon_breakable.cgf" };
							{ "Apple", "Objects/natural/fruits_vegetables/apple_breakable.cgf" };
							{ "Pineapple", "objects/natural/fruits_vegetables/pineapple_breakable.cgf" };
							{ "Potato", "objects/natural/fruits_vegetables/potato_breakable.cgf" };
							{ "Orange", "objects/natural/fruits_vegetables/orange_breakable.cgf" };
						};
						local choosenFood = futter[math.random(#futter)];
						foodClass = choosenFood[1];
						local theFood = SpawnGUI(choosenFood[2], cell.spawn);
						theFood:AddImpulse(-1, theFood:GetCenterOfMassPos(), GetNVec(GetDir(theFood:GetPos(), player:GetPos())), 30, 1);
						Script.SetTimer(10000, function()
							System.RemoveEntity(theFood.id);
						end);
						for i, tgt in ipairs(g_gameRules.game:GetPlayers()or{})do
							if (tgt == feeder) then
								SendMsg(CHAT_ATOM, feeder, "You fed the prisoner a " .. foodClass);
							elseif (tgt == player) then
								SendMsg(CHAT_ATOM, player, feeder:GetName() .. " fed you a " .. foodClass);
							elseif (not self:IsJailed(tgt.id)) then
								SendMsg(INFO, tgt, player:GetName() .. " fed a prisoner a " .. foodClass .. ", use !feedprisoner");
							end;
						end;
						return true;
					end;
				end
				return false, "failed to feed the prisoner"
			else
				return false, "this player isn't jailed";
			end;
		end;
		-----------------
		UnVisitJail = function(self, player)
			if (not self:IsJailed(player.id)) then
				local oldAng, oldPos = player.jailVisitPos.ang, player.jailVisitPos.pos;
				player.lastSvTeleport = _time;
				g_gameRules.game:MovePlayer(player.id, oldPos, oldAng);
				SendMsg(CHAT_ATOM, player, "You left the Jail");
				self:InformPrisoners(player:GetName() .. " left the jail!");
				player.jailVisitPos = nil
				return false, "failed to leave the jail"
			else
				return false, "you cannot leave the jail";
			end;
		end;
		-----------------
		UnJail = function(self, player, cellId, disconnected)
			local cell = self:GetCellById(cellId);
			if (cell) then
				if (not disconnected) then
					local oldAng, oldPos = player.jailOldPos.ang, player.jailOldPos.pos;
					player.jailId = nil;
					player.jailOldPos = nil;
					self.temp.jailed[player.id] = nil;
					player.lastSvTeleport = _time;
					g_gameRules.game:MovePlayer(player.id, oldPos, oldAng);
					player.remainingJailTime = nil;
					if (player.inventoryKilled) then
						player.inventoryKilled = false;
						ATOMEquip:OnSpawn(player);
						ItemSystem.GiveItem("AlienCloak", player.id, false);
						ItemSystem.GiveItem("OffHand", player.id, false);
						ItemSystem.GiveItem("Fists", player.id, false);
					end;
					player.escapeCounter = 0;
					local id = player:GetIdentifier();
					if (id and string.len(id)>0) then
						if (self.perma.jailed[id]) then
							self.perma.jailed[id] = nil;
							self:SaveFile();
						end;
					end;
				end;
				self:SetCell(cell.id, false);
				return true;
			end;
		end;
		-----------------
		Jail = function(self, player, cellId, permaJail, time, reason)
			player.jailId = cellId;
			local cell = self:GetCellById(cellId);
			if (cell) then
				self:SetCell(cell.id, true);
				player.jailOldPos = {
					ang = player:GetAngles();
					pos = player:GetPos();
				};
				player.jailVisitPos = nil
				self.temp.jailed[player.id] = player;
				player.lastSvTeleport = _time;
				g_gameRules.game:MovePlayer(player.id, cell.spawn, cell.angles);
				player.inventory:Destroy();
				player.inventoryKilled = true;
				player.remainingJailTime = (time and tonumber(time) or -1);
				if (permaJail) then
					local id = player:GetIdentifier();
					if (id and string.len(id)>0 and id ~= "0") then
						if (not self.perma.jailed[id]) then
							self.perma.jailed[id] = {r=reason,t=player.remainingJailTime};
						end;
					end;
				end;
				self:SaveFile();
				return true;
			end;
		end;
	-----------------
	GetRemainingJailTime = function(self, player)
		if (not self:IsJailed(player.id)) then
			return false, "you are not jailed";
		end;
		if (player.remainingJailTime and tostring(player.remainingJailTime) ~= "-1") then
			SendMsg(CHAT_ATOM, player, "You will be released in %s", calcTime(player.remainingJailTime, true, unpack(GetTime_SMH)));
		else
			SendMsg(CHAT_ATOM, player, "You are Perma-Jailed and have to wait for Admins to unjail you!");
		end;
		return true;
	end;
	-----------------
	OnTick = function(self)
		--Debug("Fack")
		for i, player in pairs(GetPlayers()or{}) do
			self:CheckJailed(player);
			if (self:IsJailed(player.id)) then
				if (player.remainingJailTime and player.remainingJailTime ~= -1) then
					player.remainingJailTime = player.remainingJailTime -1;
					if (player.remainingJailTime <= 0) then
						self:UnJailPlayer(player, "Timeout");
					else
						local id = player:GetIdentifier();
						if (id) then
							if (self.perma.jailed[id]) then
								self.perma.jailed[id].t = player.remainingJailTime;
							end;
						end;
					end;
				end;
			end;
		end;
		self:CheckJail(true)
		self:CheckPrisoners();
	end;
	-----------------
	CheckPrisoners = function(self)
		local temp = { 
			skipPunish = false;
			revived = false
		};
		for i, player in pairs(self.temp.jailed or{})do
			if (System.GetEntity(player.id)) then
				if (player:IsDead() or player:IsSpectating()) then
					if (not player.beingPunished) then
						g_utils:RevivePlayer(player, player);
						temp.revived = true;
						self:MoveIntoCell(player);
					end;
					temp.skipPunish=true;
				end;
				if (player.actor:GetLinkedVehicleId()) then
					local vehicle = System.GetEntity(player.actor:GetLinkedVehicleId());
					if (vehicle) then
						vehicle.vehicle:ExitVehicle(player.id, true);
					end;
				end;
				if (player.inventory:GetCount() > 0) then
					player.inventory:Destroy();
				end;
				if (player:IsAlive() and not player:IsSpectating()) then
					player.actor:SetHealth(2);
					player.actor:SetNanoSuitEnergy(2);
					player.actor:SetNanoSuitMode(1);
				end;
				if (not player.jailId) then
					local cellId = self:GetFreeCell();
					if (cellId) then
						self:Jail(player, cellId);
					end;
				else
					local cell = self:GetCellById(player.jailId);
					if (cell) then
						local playerPos = player:GetPos();
						local x, y, z = round(playerPos.x), round(playerPos.y), round(playerPos.z);
						--Debug("if (("..x.." > "..cell.area.x[1].." or "..x.." < "..cell.area.x[2]..") or ("..y.." > "..cell.area.y[1].." or "..y.." < "..cell.area.y[2]..") or ("..z.." > "..cell.area.z[1].." or "..z.." < "..cell.area.z[2]..")) then")
						if ((x > cell.area.x[1] or x < cell.area.x[2]) or (y > cell.area.y[1] or y < cell.area.y[2]) or (z > cell.area.z[1] or z < cell.area.z[2])) then
							player.lastSvTeleport = _time;
							g_gameRules.game:MovePlayer(player.id, cell.spawn, cell.angles);
							SpawnEffect(ePE_Light, cell.spawn, g_Vectors.up, 1);
							local msg = "YOU CANNOT ESCAPE THE JAIL!!";
							local messages = {
								[5] = "STOP TRYING TO ESCAPE OR IT WILL END BADLY!!";
								[6] = "!!STOP TRYING TO ESCAPE OR IT WILL END BADLY!!";
								[7] = "!!!STOP TRYING TO ESCAPE OR IT WILL END BADLY!!!";
								[8] = "!!LAST WARNING: STOP TRYING TO ESCAPE OR IT WILL END BADLY!!";
								[10] = "NOW YOU WILL BE PUNISHED";
								[11] = "ESCAPING WILL NOT BE TOLERATED!! AND YOU WILL BE PUNISHED";
							};
							if (player.escapeCounter and messages[player.escapeCounter]) then
								msg = messages[player.escapeCounter];
							end;
							if (player.escapeCounter and player.escapeCounter > 11) then
								msg = messages[11];
							end;
							SendMsg(ERROR, player, msg);
							if (not temp.skipPunish and not player.beingPunished) then
								player.escapeCounter = (player.escapeCounter or 0) + 1;
								if (player.escapeCounter > 10) then
									self:PunishEscaper(player, player.escapeCounter);
								end;
							end;
						end;
					end;
				end;
			else
				self:UnJail(player, player.jailId, true);
			end;
		end;
		if (arrSize(self.temp.jailed)==0) then
			for i, cell in ipairs(self.jail.cells or{})do
				self:SetCell(cell.id, false);
			end;
		end;
	end;
	-----------------
	SetCell = function(self, id, mode)
		for i, cell in ipairs(self.jail.cells or{})do
			if (cell.id == id) then
				cell.used = mode;
			end;
		end;
	end;
	-----------------
	GetFreeCell = function(self)
		for i, cell in ipairs(self.jail.cells or{})do
			if (not cell.used) then
				return cell.id;
			end;
		end;
	end;
	-----------------
	InformPrisoners = function(self, msg)
		for i, player in pairs(self.temp.jailed) do
			SendMsg(39, player, msg);
		end;
	end;
	-----------------
	GetCellById = function(self, id)
		for i, cell in ipairs(self.jail.cells)do
			if (cell.id == id) then
				return cell;
			end;
		end;
		return;
	end;
	-----------------
	BlockAction = function(self, player)
		if (self:IsJailed(player.id)) then
			return false;
		end;
		return true;
	end;
	-----------------
	MoveIntoCell = function(self, player, silent)
		if (player.jailId) then
			local cell = self:GetCellById(player.jailId);
			if (cell) then
				player.lastSvTeleport = _time;
				g_gameRules.game:MovePlayer(player.id, cell.spawn, cell.angles);
				--SendMsg(39, player, "YOU CANNOT ESCAPE THE JAIL!!"); -- handled by CheckPrisoners()
			end;
		end;
	end;
	-----------------
	PunishEscaper = function(self, player, frequency)
		if (not self.cfg.enabled) then return false, "Jail System is disabled"; end;
		if (not player.beingPunished) then
			local pos = player:GetPos();
			player.beingPunished = true
			for i=1, frequency do
				Script.SetTimer(i*(i==1 and 0 or 50), function()
					SendMsg(CENTER, player, "BOOM :: DIED ["..i.."]-TIMES ::")
					g_gameRules:KillPlayer(player, true);
					if (i == frequency) then
						for j=1, frequency/5 do
							Script.SetTimer(j*(j==1 and 0 or 100), function()
								pos = player:GetPos();
								g_gameRules:CreateExplosion(NULL_ENTITY,NULL_ENTITY,100,{x=pos.x+math.random(-1,1),y=pos.y+math.random(-1,1),z=pos.z+math.random(-1,1)},g_Vectors.up,1,5,1000,1,"explosions.mine.claymore",1, 3, 5, 5);
								if (j==frequency) then
									Script.SetTimer(100, function()
										player.beingPunished = false;
									end);
								end;
							end);
						end;
					end;
				end);
			end;
		end;
	end;
	-----------------
	ResetAll = function(self)
		self.perma = { jailed = {} };
		self.temp = { jailed = {} };
	end,
	-----------------
	Load = function(self, t)
		self.perma = t;
	end,
	-----------------
	SaveFile = function(self)
		Debug(self.perma)
		SaveFileArr("ATOMJail", "Jail.lua", "ATOMJail:Load", {{ self.perma }} );
	end;
	-----------------
	LoadFile = function(self)
		LoadFile("ATOMJail", "Jail.lua");
	end;
	-----------------
};

ATOMJail:Init();