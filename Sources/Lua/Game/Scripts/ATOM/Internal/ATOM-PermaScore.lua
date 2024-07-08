ATOMStats = {
	cfg = {
		
		ScoreRestore = true;
		PermaScore	 = true;
		ResetScoreOnSpectatorMode = false;
		AwardScoreForBotKill	  = true;
		TeamKillReward			  = 0;
		AllowNullProfile 		  = ATOM.cfg.AllowNullProfile;
	};
	------------
	PermaScore = {
		cfg = {
			Goals = {
				HoursUntilPremium = 20;
			};
		};
		------------
		nilData = {
			GameTime	= 0,
			Visits		= 0,
		
		};
		------------
		permaScore = {};
		------------
		Init = function(self)

			eSG_PlayTime 		= 0;
			eSG_UnlockedPremium = 1;
			eSG_Visits			= 2;
			
			eST_Deaths 			= 0;
			eST_EXP				= 1;
			eST_Kills			= 2;
			eST_Score			= 3;
			eST_Visits			= 4;
			eST_GameTime		= 5;
			
			RegisterEvent("CanSendRadio", self.OnRadio, 'ATOMStats');
			
			self:LoadFile();
		end;
		------------
		OnConnect = function(self, player)
			
			player.GetPlayTime = function(self)
				return self.Info.PlayTime;
			end;
			
			player.GetGameTime = function(self)
				return ATOMStats.PermaScore:GetGameTime(self);
			end;
			
			player.GetLastSeen = function(self)
				return ATOMStats.PermaScore:GetLastSeen(self);
			end;
		
			self:CheckPlayer(player, true);
			
		end;
		------------
		GetLastSeen = function(self, player)
			local aData = self:GetData(player:GetIdentifier())
			if (not aData) then
				return
			end
			return aData.LastSeen
		end;
		------------
		GetLastSeenByID = function(self, sID)
			local aData = self:GetDataByID(sID)
			if (not aData) then
				return -1
			end

			return aData.LastVisit
		end;
		------------
		OnDisconnect = function(self, player)

			local identifier = player:GetIdentifier();
			if (identifier and CanScore(identifier)) then
				if (not self:IsRegistered(identifier)) then
					self:Register(identifier);
				end;
				
				local data = self:IsRegistered(identifier, true);
				data.LastPos = not player:IsSpectating() and {
					player:GetPos(),
					player:GetAngles()
				} or nil;
				data.LastVisit = atommath:Get("timestamp"); --os.date();
				data.LastPosMapName = ATOM:GetMapName();
			--	Debug("!!!",data.LastVisit)
				
			--	self:CheckGoal(player, identifier, eSG_PlayTime, self:IsRegistered(identifier, true).GameTime);
			end;
			
		end;
		------------
		OnKill = function(self, player, target, weaponClass, distance, headshot, accuracy, precision, hitType)
			--Debug(weaponClass)
			if (player and player.isPlayer and target ~= player and CanScore(player:GetIdentifier())) then
				local data_1 = self:IsRegistered(player:GetIdentifier());
				
			
				data_1.kills = (data_1.kills or 0) + 1;
				
				data_1.name = player:GetName():sub(1, 19);
				
				data_1.score = (data_1.kills or 0) - ((data_1.deaths or 2) / 2) + (data_1.heads or 0);-- - (data_1.deaths or 0);
				
				newRank = self:GetPlayerRank(player, eST_Score);
				if (player.LAST_RANK and newRank > player.LAST_RANK) then
					SendMsg(INFO, ALL, "[ HIGH : SCORES ] >> " .. player:GetName() .. " :: NOW RANK #" .. newRank);
				end;
				player.LAST_RANK = newRank;
				
				
				if (headshot) then
					data_1.heads = (data_1.heads or 0) + 1;
				end;
				
				if (not weaponClass and hitType == "frag") then
					weaponClass = "Frag";
				end;
				
				if (weaponClass) then
				
					--Debug("kill class :: ",weaponClass)
					data_1.classKills = data_1.classKills or {};
					data_1.classKills[weaponClass] = (data_1.classKills[weaponClass] or 0) + 1;
					
					if (weaponClass == "DSG1") then
						if (not data_1.bestDSG or type(data_1.bestDSG)~="number" or distance > data_1.bestDSG) then
							data_1.bestDSG = distance;
						end;
					end
				end;
				
				if (player.KillStreaks) then
					if (not data_1.killStreak or player.KillStreaks > data_1.killStreak) then
						data_1.killStreak = player.KillStreaks;
					end;
				end;
			end;
			
			if (target and target.isPlayer and CanScore(target:GetIdentifier())) then

				local data_2 = self:IsRegistered(target:GetIdentifier());
				if (not data_2) then
					return
				end

				data_2.deaths = (data_2.deaths or 0) + 1
				data_2.name = target:GetName():sub(1, 19)
				data_2.score = (data_2.kills or 0) - ((data_2.deaths or 2) / 2) + (data_2.heads or 0)
				
				if (target.DeathStreak) then
					if (not data_2.deathStreak or target.DeathStreak > data_2.deathStreak) then
						data_2.deathStreak = target.DeathStreak
					end
				end
			end
		end;
		------------
		OnWallJump = function(self, player, meters)
			if (CanScore(player:GetIdentifier())) then
				local data = self:IsRegistered(player:GetIdentifier());
				if (data and (not data.BestWJ or tonumber(meters) > tonumber(data.BestWJ))) then
					data.BestWJ = meters;
				end;
			end;
		end;
		------------
		GetScore = function(self, id)
			return self.permaScore[id].score or 0;
		end;
		------------
		GetData = function(self, id)
			self.permaScore[id] = self.permaScore[id] or {}
			return self.permaScore[id]
		end;
		------------
		GetDataByID = function(self, sID)
			local aData = self.permaScore[sID]
			if (not aData) then
				return
			end
			return aData
		end;
		------------
		GetTop = function(self, topPlayers)
			local top = {};
			local allScores = self.permaScore;
			local theScores = {};
			for i, v in pairs(allScores) do
				theScores[arrSize(theScores)+1] = {
					i,
					v
				};
			end;
			table.sort(theScores,function(a,b)
				a[2].score = (a[2].kills or 0) - ((a[2].deaths or 2) / 2) + (a[2].heads or 0);
				b[2].score = (b[2].kills or 0) - ((b[2].deaths or 2) / 2) + (b[2].heads or 0);
				
				if (a[2].score == b[2].score) then
					local X, Y = (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].EXP or 0), (ATOMLevelSystem.savedEXP[a[1]] and ATOMLevelSystem.savedEXP[a[1]].EXP or 0);
					return X > Y;
				end;
				
				return a[2].score > b[2].score;
			end);
			
			for i = 1, topPlayers or 10 do
				if (not theScores[i]) then
					break;
				end
				top[i] = theScores[i][2];
			end;
			
			return top;
		end,
		------------
		GetPlayerRank = function(self, player, t)
			local rank = 1;
			local playerScore = self:GetScore(player:GetIdentifier());
			local playerExp = player:GetEXP();
			local playerKills, playerDeaths, playerVisits, playerGameTime = (self:GetData(player:GetIdentifier()).kills or 0), (self:GetData(player:GetIdentifier()).deaths or 0), (self:GetData(player:GetIdentifier()).Visits or 0), (self:GetData(player:GetIdentifier()).GameTime or 0);
			for i, reg in pairs(self.permaScore) do
				reg.score = (reg.kills or 0) - ((reg.deaths or 2) / 2) + (reg.heads or 0);
				if (i ~= player:GetIdentifier()) then
					if (t == eST_Score) then
						if ((reg.score or 0) > playerScore) then
							rank = rank + 1;
						end;
					elseif (t == eST_EXP) then
						if ((ATOMLevelSystem.savedEXP[i] and ATOMLevelSystem.savedEXP[i].EXP or 0) > playerExp) then
							rank = rank + 1;
						end;
					elseif (t == eST_Kills) then
						if ((reg.kills or 0) > playerKills) then
							rank = rank + 1;
						end;
					elseif (t == eST_Deaths) then
						if ((reg.deaths or 0) > playerDeaths) then
							rank = rank + 1;
						end;
					elseif (t == eST_Visits) then
						if ((reg.Visits or 0) > playerVisits) then
							rank = rank + 1;
						end;
					elseif (t == eST_GameTime) then
						if ((reg.GameTime or 0) > playerGameTime) then
							rank = rank + 1;
						end;
					end;
				end;
			end;
			return rank;
		end;
		------------
		LoadFile = function(self, t)
		--	SysLog("LOAD!!")
			LoadFile("ATOMStats_PermaScore", "PermaScore.lua");
			--LoadFile("ATOMStats_PermaScore_", ".PermaScore.lua");
		end;
		----------
		LoadPermaScore = function(self, identifier, GameTime, Vists)
		--	self.permaScore[identifier] = {
		--		GameTime = GameTime,
		--		Visits	 = Visits,
		--	};
		end;
		------------
		SaveFile = function(self, t)
			
			if (not CanScore("0")) then
				self.permaScore["0"] = nil;
			end;
		--	Debug("SAVE!!")
		--	SaveFile("ATOMStats_PermaScore", "PermaScore.lua", "ATOMStats.PermaScore:LoadPermaScore", ATOMStats:ConvertTable(self.permaScore, false));
		--	SaveFile_Arr("ATOMStats_PermaScore", "PermaScore.lua", "ATOMStats.PermaScore.permaScore", self.permaScore);
			SaveFileArr ("ATOMStats_PermaScore", "PermaScore.lua", "ATOMStats.PermaScore:LoadScore", ATOMStats:ConvertTable(self.permaScore, 1));
		
		end;
		------------
		ConvertTable = function(self, t)
		end;
		------------
		LoadScore = function(self, id, deaths, kills, score, LastVisit, NextGoal, LastPos, classKills, bestDSG, name, BestWJ, LongTime, heads, GameTime, Visits, KStreak, DStreak)
			--if (id=="2000001") then
			--	SysLog("Loading %s=%d",id,Visits)
			--end
			self.permaScore[id] = 
			{
				deaths 		= deaths,
				kills 		= kills,
				score 		= score,
				LastVisit 	= LastVisit,
				NextGoal 	= NextGoal, 
				LastPos 	= LastPos,
				classKills 	= classKills,
				bestDSG 	= bestDSG,
				name 		= name,
				BestWJ 		= BestWJ,
				LongTime 	= LongTime,
				heads 		= heads,
				GameTime 	= GameTime,
				Visits 		= Visits,
				killStreak	= KStreak,
				deathStreak	= DStreak
			}
			--Debug("Game Time",GameTime)
			--Debug("LongTime Time",LongTime)
		end,
		------------
		CheckPlayer = function(self, player, isConnect)
			local isConnect = true;
			
			if (ATOMStats.cfg.PermaScore) then
			
				local identifier = player.GetIdentifier and player:GetIdentifier();
				if (identifier and CanScore(identifier)) then
					if (not self:IsRegistered(identifier)) then
					--Debug("Not reg LOL")
						self:Register(identifier);
					end;
					local data = self:IsRegistered(identifier);
					if (data and not player.VisitSaved) then
						player.VisitSaved = true;
						--Debug("VISTS = ",data.Visits, "ID=",identifier)
						data.Visits = (data.Visits or 0) + 1;
						self:CheckGoal(player, identifier, eSG_Visits, data.Visits);
						self:SaveFile(true);
					end;
					if (data.LastPos and data.LastPos~= 0 and not player._PositionRestoreed and ATOM:GetMapName() == data.LastPosMapName) then
						--Debug(data.LastPos)
						self:RestorePosition(player);
						player.RestoringPos = data.LastPos;
						data.LastPos = nil;
						player._PositionRestoreed = true;
					else
						data.LastPos = nil;
						player._PositionRestoreed = true;
					end;
				end;
			end;
		end;
		------------
		RestorePosition = function(self, player)
			if (not player.Restoring and g_gameRules.class == "PowerStruggle") then
				player.Restoring = true;
			end;
		end;
		------------
		IsRegistered = function(self, identifier)
			return self.permaScore[identifier];
		end;
		------------
		Register = function(self, identifier)
			self.permaScore[identifier] = {};
		end;
		------------
		OnTick = function(self, player)
			player.Info.PlayTime = (player.Info.PlayTime or 0) + 1; --1;
			player.Info.PlayTimeMinutes = player.Info.PlayTimeMinutes or 60;
			if (player.Info.PlayTime > player.Info.PlayTimeMinutes) then
				player.Info.PlayTimeMinutes = player.Info.PlayTimeMinutes + 60;
				local give, exp = shouldGiveEXP("Time");
				if (give) then
					s:GiveEXP(exp, true, "PlayTIME LOLOLOL");
				end;
			end;
			--Debug(player.Info.PlayTime)
			local identifier = player:GetIdentifier();
			if (identifier and CanScore(identifier)) then
				self:CheckPlayer(player);
				local data = self:IsRegistered(identifier, true);
				data.GameTime = (data.GameTime or 0) + 1; --1;
				if (not data.LongTime or player.Info.PlayTime > data.LongTime) then
					data.LongTime = player.Info.PlayTime;
				end;
				self:CheckGoal(player, identifier, eSG_PlayTime, self:IsRegistered(identifier, true).GameTime);
					
			end;
			
			if (player.Restoring and player.EnteredGame) then
				if (not player.RPosTimer or player.RPosTimer < 30) then
					player.RPosTimer = (player.RPosTimer or 0) + 1;
					SendMsg(CENTER, player, "RESTORE LAST POSITION [ %0.2fm ] :: [ F5 + F1 ] for YES [ F5 + F2 ] for NO :: [ %ds ]", GetDistance(player:GetPos(), player.RestoringPos[1]), 30-player.RPosTimer);
				else
					player.Restoring = false;
				end;
			elseif (not player:IsSpectating()) then
				player.EnteredGame = true;
			end;
		end;
		------------
		OnRadio = function(self, player, Id)
			if (player.Restoring) then
				if (Id == 0) then
					local dist = GetDistance(player:GetPos(), player.RestoringPos[1]);
					--SendMsg(CENTER, player, "POSITION :: RESTORED (%0.2fm)" , dist);
					ATOMLog:LogGameUtils("", "%s$9 Restored their Position ( $4%0.2fm$9 )", player:GetName(), dist);
					SendMsg(CHAT_ATOM, GetPlayers(nil, player.id, true), "%s: Restored their Position ( %0.2fm )", player:GetName(), dist);
					g_game:MovePlayer(player.id, player.RestoringPos[1], player.RestoringPos[2]);
					g_utils:SpawnEffect(ePE_Light, player.RestoringPos[1]);
				elseif (Id == 1) then
					SendMsg(CENTER, player, "Last Position Removed");
				end;
				player.Restoring = false;
				return false;
			end;
			return true;
		end;
		------------
		CheckGoal = function(self, player, identifier, goalId, value)
			local plData = self:IsRegistered(identifier);
			--Debug("nest goal",plData.NextGoal)
			plData.NextGoal = plData.NextGoal or {};
			local goals = self.cfg.Goals;
			if (goals and CanScore(identifier)) then
				if (goalId == eSG_PlayTime) then
					local hours = value / 3600;
					--Debug(value/((plData.NextGoal[1] or 1)*60*60))
					if (hours >= (plData.NextGoal[1] or 1)) then
						local psmsg;
						plData.NextGoal[1] = (plData.NextGoal[1] or 0) + 1;
						if (g_gameRules.class == "PowerStruggle") then
							player:GivePrestige((plData.NextGoal[1]-1) * 10);
							SendMsg(CENTER, player, "For playing total - [ %d ] - Hours, you have been awarded - [ %d ] - Prestige!", plData.NextGoal[1]-1, (plData.NextGoal[1]-1)*10);
							psmsg = "and won " .. (plData.NextGoal[1]-1)*10 .. " Prestige"
						end;
						self:Msg(player, eSG_PlayTime, plData.NextGoal[1]-1, psmsg);
						self:SaveFile(true);
					end;
					if (hours >= goals.HoursUntilPremium) then
						if (not player:HasAccess(PREMIUM)) then
							self:Msg(player, eSG_UnlockedPremium, hours);
							AddUser(player, PREMIUM);
							self:SaveFile(true);
						end;
					end;
				elseif (goalId == eSG_Visits) then
					--SysLog("EVENT ESG_VISIST!!!");
					--Debug(value,plData.NextGoal[2])
					if (value >= (plData.NextGoal[2] or 25)) then
						plData.NextGoal[2] = (plData.NextGoal[2] or 0) + 25;
						self:Msg(player, eSG_Visits, value);
						self:SaveFile(true);
					end;
				end;
			end;
		end;
		------------
		Msg = function(self, player, case, p1, p2, p3)
			local name = player:GetName();
			if (case == eSG_PlayTime) then
				ATOMLog:LogAchievement(player, "%s$9 Has played total %d Hours%s", name, p1, p3 or "");
			elseif (case == eSG_UnlockedPremium) then
				ATOMLog:LogAchievement(player, "%s$9 Has Played total %d Hours and unlocked PREMIUM Access", name, p1);
			elseif (case == eSG_Visits) then
				ATOMLog:LogAchievement(player, "%s$9 Visited this server total %d Times", name, p1);
			end;
		end;
		------------
		GetGameTime = function(self, player)
			local identifier = player:GetIdentifier();
			local data 		 = self:IsRegistered(identifier);
			if (identifier and data) then
				return data.GameTime;
			end;
			return 0;
		end;
		------------
		OnRevive = function(self, player)
			local ID = player:GetIdentifier();
			if (not CanScore(ID) and (not player.RevivedTimes or player.RevivedTimes > 5)) then
				SendMsg(CHAT_ATOM, player, "Your Profile is Invalid, your Scores and progress will not be Saved.");
				player.RevivedTimes = 0;
			end;
			player.RevivedTimes = (player.RevivedTimes or 0) + 1;
		end;
		
	};
	------------
	PersistantScore = {
		------------
		saved = ATOMStats~=nil and ATOMStats.PersistantScore.saved or {
			["instantaction"]     = {};
			["powerstruggle"]     = {};
			["teamaction"]        = {};
			["teaminstantaction"] = {};
		};
		savedInMaps = ATOMStats~=nil and ATOMStats.PersistantScore.savedInMaps or {
			["instantaction"]     = {};
			["powerstruggle"]     = {};
			["teamaction"]        = {};
			["teaminstantaction"] = {};
		};
		------------
		Init = function(self)
			RegisterEvent("OnSeqTimer", self.SaveScores, 'ATOMStats.PersistantScore');
			self:LoadFiles();
		end;
		------------
		OnConnect = function(self, player)
			--Debug("Checking")
			self:CheckPlayer(player, true);
		end;
		------------
		SaveScores = function(self)
			--SysLog("all ok bruddah")
			if (g_game:GetPlayerCount() > 0) then
				for i, player in pairs(GetPlayers()) do
					self:Save(player, true);
				end;
				self:SaveFile();
				SysLog("Saving scores");
			end;
			--SysLog("%s", tostring(self))
		end;
		------------
		SynchRest = function(self, player)
			if (player.restorePEEPEE) then
				local pp, cp, rank = player.restorePEEPEE[1], player.restorePEEPEE[2], player.restorePEEPEE[3];
				if (pp and pp > player:GetPrestige()) then
					SysLog("Restoring PP")
					g_game:SetSynchedEntityValue(player.id, g_gameRules.PP_AMOUNT_KEY, pp or 0);
					SysLog("Restoring PP Ok")
				end;
				if (cp and cp > player:GetCP()) then
					SysLog("Restoring CP")
					g_game:SetSynchedEntityValue(player.id, g_gameRules.CP_AMOUNT_KEY, cp or 0);
					SysLog("Restoring CP Ok")
				end;
				if (rank and rank > player:GetRank()) then
					SysLog("Restoring Rank")
					g_game:SetSynchedEntityValue(player.id, g_gameRules.RANK_KEY, rank or 1);
					SysLog("Restoring Rank ok")
				end;
				player.restorePEEPEE = nil;
			end;
		end,
		------------
		LoadFiles = function(self, t)
			LoadFile("ATOMStats_PersistantScore", "PersistantScore.lua");
		end;
		----------
		LoadScore = function(self, gameRules, identifier, kills, deaths, name, iden, pp, rank, cp)
			self.saved[gameRules][identifier] = {
				kills	 = kills;
				deaths	 = deaths;
				name	 = name;
				iden	 = iden;
				pp		 = pp;
				rank	 = rank;
				cp		 = cp;
			};
		end;
		------------
		SaveFile = function(self)
			--local old_ps = self.saved["powerstruggle"];
			--self.saved["powerstruggle"] = nil;
			--SysLog("Not saving PS scores into file...");
			SaveFile("ATOMStats_PersistantScore", "PersistantScore.lua", "ATOMStats.PersistantScore:LoadScore", ATOMStats:ConvertTable(self.saved, 2) );
			--self.saved["powerstruggle"] = old_ps;
		end;
		------------
		IsRegistered = function(self, player, playerProfile, rules)
			local playerProfile = playerProfile or player:GetIdentifier(); --(player.GetSinProfile and player:GetSinProfile() or "nil:nil:nil");
			return (playerProfile and player and self.saved[(rules or "instantaction")][playerProfile] ~= nil);
		end;
		------------
		Register = function(self, identifier)
			self.saved[identifier] = {};
		end;
		------------
		Save = function(self, player, noSave)
		
			local playerProfile = player:GetIdentifier();
			
			if (not CanScore(playerProfile)) then
				return;
			end;
			
			if (playerProfile) then
				local kills = g_gameRules.game:GetSynchedEntityValue(player.id, g_gameRules.SCORE_KILLS_KEY) or 0;
				local deaths = g_gameRules.game:GetSynchedEntityValue(player.id, g_gameRules.SCORE_DEATHS_KEY) or 0;
				local pp   = 0;
				local cp   = 0;
				local rank = 1;
				if (not self:IsIA()) then
					pp 		= g_game:GetSynchedEntityValue(player.id, g_gameRules.PP_AMOUNT_KEY) or 0;
					cp 		= g_game:GetSynchedEntityValue(player.id, g_gameRules.CP_AMOUNT_KEY) or 0;
					rank 	= g_game:GetSynchedEntityValue(player.id, g_gameRules.RANK_KEY) or 1;
				end;
				--Debug("pp",pp, g_game:GetSynchedEntityValue(player.id, g_gameRules.PP_AMOUNT_KEY))
				
				if (noSave ~= true and not player.wasKicked) then
					self:LogSaved(player);
				end;
				--Debug("deaths == ", deaths)
				self:SetScore(player, playerProfile, kills, deaths, pp, cp, rank, noSave);
			end;
		end;
		------------
		Restore = function(self, player)
		
			if (not ATOMStats.cfg.ScoreRestore) then
				return false;
			end;
			if (player.restored) then
				return false;
			end;
		
			local playerProfile = player:GetIdentifier();
		
			if (not CanScore(playerProfile)) then
				return;
			end;
			
			
			if (not self:IsRegistered(player, playerProfile, self:GetRules(true))) then
				self:Setup(player, playerProfile, self:GetRules(true));
			else
				player.restored = true;
				self:LogRestored(player);
			end;
			
			local kills, deaths, pp, cp, rank = self:GetScore(player, playerProfile, self:GetRules(true));
			SysLog("restoring score and waiting for crash: %d, %d, %d, %d, %d", kills, deaths, pp, cp, rank);
			g_gameRules:SetPlayerScore(player.id, kills);
			g_gameRules:SetPlayerDeaths(player.id, deaths);
			
			if (not self:IsIA()) then
				--Debug("PP",pp)
				player.restorePEEPEE = {
					pp or 1,
					cp or 1,
					rank or 1
				};
				Script.SetTimer(1500, function()
					self:SynchRest(player);
				end);
			end;
		end;
		------------
		GetScore = function(self, player, playerProfile, rules)
			local playerProfile = playerProfile or player:GetIdentifier(); --(player.GetSinProfile and player:GetSinProfile() or "nil:nil:nil");
			if (not self:IsRegistered(player, playerProfile, rules)) then
				self:Setup(player, playerProfile, rules);
			end;
			local data = self.saved[rules][playerProfile];
			local kills, deaths, pp, cp, rank = data.kills or 0, data.deaths or 0, data.pp or 0, data.cp or 0, data.rank or 0;
			return kills, deaths, pp, cp, rank;
		end;
		------------
		LogRestored = function(self, player)
			local name = (not player.id and tostring(player) or player:GetName());
			if (name) then
				Script.SetTimer(250, function()
					ATOMLog:LogScoreRestore('Restore', "Restored score from %s", name);
				end);
			end;
		end;
		------------
		LogSaved = function(self, player)
			local name = (not player.id and tostring(player) or player:GetName());
			if (name) then
				ATOMLog:LogScoreRestore('Save', "Saved score from %s", name);
			end;
		end;
		------------
		GetRules = function(self, lower)
			return ((lower and g_gameRules.class:lower() or g_gameRules.class) or "nil")
		end;
		------------
		SetScore = function(self, player, playerProfile, kills, deaths, pp, cp, rank, noSave)
			local playerProfile = playerProfile or player:GetIdentifier(); --(player.GetSinProfile and player:GetSinProfile() or "nil:nil:nil");
			if (playerProfile) then
				self.saved[self:GetRules(true)][playerProfile] = {
					kills  = (kills or 0);
					deaths = (deaths or 0);
					name   = (player.accname and player.accname or player:GetName());
					iden   = playerProfile;
					pp     = (pp or 0);
					rank   = (rank or 0);
					cp     = (cp or 0);
				};
				if (noSave ~= true) then
					self:SaveFile();
				end;
			end;
			return true;
		end;
		------------
		Setup = function(self, player, playerProfile, rules)
			local playerProfile = playerProfile or player:GetIdentifier(); --(player.GetSinProfile and player:GetSinProfile() or "nil:nil:nil");
			if (not self:IsRegistered(player, playerProfile, rules)) then
				self.saved[rules][playerProfile] = {
					kills  = 0;
					deaths = 0;
					name   = (player.accname and player.accname or player:GetName());
					iden   = playerProfile;
					pp     = 0;
					rank   = 0;
					cp     = 0;
				};
				self.savedInMaps = self.saved;
			end;
			return true;
		end;
		------------
		Reset = function(self, player, playerProfile)
			local playerProfile = playerProfile or player:GetIdentifier(); --(player.GetSinProfile and player:GetSinProfile() or "nil:nil:nil");
			if (playerProfile) then
				if (self:IsRegistered(player, playerProfile, self:GetRules(true))) then
					self.saved[self:GetRules(true)][playerProfile] = nil;
					self:SaveFile();
					return true;
				end;
			end;
			return false, "no scores found";
		end;
		------------
		ResetAll = function(self)
			if ((#self.saved["instantaction"] > 0) or (#self.saved["powerstruggle"] > 0) or (#self.saved["teamaction"] > 0) or (#self.saved["teaminstantaction"] > 0)) then
				self.saved = {
					["instantaction"]     = {};
					["powerstruggle"]     = {};
					["teamaction"]        = {};
					["teaminstantaction"] = {};
				};
				self:SaveFile();
				return true;
			else
				return false, "no scores found";
			end;
		end;
		------------
		IsIA = function(self)
			return g_gameRules.class ~= "PowerStruggle";
		end;
		------------
		CheckPlayer = function(self, player)
			--Debug "WTF"
			local identifier = player:GetIdentifier();
			if (identifier) then
				self:Restore(player);
			else
				--Debug("!")
			end;
		end;
		
	};
	------------
	Init = function(self)
		self.PermaScore:Init();
		self.PersistantScore:Init();
		
		g_permaScore = self.PermaScore;
		g_persistantScore = self.PersistantScore;
	end;
	----------
	ConvertTable = function(self, t, id)
		local function prep(x)
			local r={};
			for i,v in pairs(x) do
				r[i]=v
			end;
			return r;
		end;
		local n = {};
		for i, v in pairs(t) do
			if (id == 1) then
				--Debug("ja")
				n[arrSize(n)+1] = {
					i,
					v.deaths or 0,
					v.kills or 0,
					v.score or 0,
					v.LastVisit or 0,
					(v.NextGoal or {}),
					v.LastPos or 0,
					(v.classKills or {}),
					v.bestDSG or 0,
					v.name or "<Unknown>",
					v.BestWJ or 0,
					v.LongTime or 0,
					v.heads or 0,
					v.GameTime or 0,
					v.Visits or 0,
					v.killStreak or 0,
					v.deathStreak or 0,
					v.LastPosMapName or 0
				};
				--Debug("GT",v.GameTime)
			elseif (id == 2 or id == 3) then
				for j, m in pairs(v) do
					m.cp = tonumber(m.cp) or 0;
					m.rank = tonumber(m.rank) or 0;
					m.pp = tonumber(m.pp) or 0;
					n[arrSize(n)+1] = {
						i, 
						j,
						m.kills,
						m.deaths,
						m.name,
						m.iden,
						m.pp,
						m.rank,
						m.cp
					};
				end;
			end;
		end;
		--Debug(n[1])
		return n;
	end;
	------------
	OnTick = function(self, player)
		self.PermaScore:OnTick(player);
	end;
	------------
	OnDisconnect = function(self, player)
		self.PermaScore:OnDisconnect(player);
		self.PersistantScore:Save(player);
	end;
	------------
	InitPlayer = function(self, player)
		ATOMStats.PermaScore:OnConnect(player);
		ATOMStats.PersistantScore:OnConnect(player);	
	end;
	------------
};

function CanScore(id)

	if (not GetBetaFeatureStatus(FEATURENAME_PERMASCORE)) then
		return false
	end

	if (id == "0") then
		return ATOMStats.cfg.AllowNullProfile == false
	end;
	return not (ATOMStats.cfg.ScoreBans[id] == true)
end;

ATOMStats:Init();