ATOMVote = {
	cfg = {
		Voting = {
		
			-- Can only vote every 60s
			Delay = 60,
			
			-- Time in seconds a vote lasts
			Time = 30,
			
			-- time between each message
			MessageTime = 10,
			
			-- Minimum percent of positive votes for a vote to succeed
			PercentVoted = 51,
			
			-- Minimum percent of all players who need to participate in a vote in order for the vote to succeed
			PercentAll = 20,
			
			-- time in seconds a question lasts
			QuestionTime = 30,
			
		},
		-- Manage votes config
		Manage = {
			-- These users can disable/stop votes
			Access = MODERATOR,
			
			-- Kickable players
			Kickable = {
				[GUEST] = true,
				[PREMIUM] = false,
			};
			
		},
		-- Allowed vote types
		AllowedVoteTypes = {
			kick 	= true, -- Kick vote
			map 	= true, -- Map vote
			lock 	= true, -- Lock items/vehicles vote
			shop 	= true, -- Shop vote
		},
		-- default vote types
		Types = {
			{
				Name = "map",
				Desc = "Start a vote to change the current map",
				VoteSucceed = function(self, voter, args)
					--SendMsg(CHAT_VOTE, ALL, "Map will be changed to %s", self.mapee);
					local r, name, x = g_utils:GetCorrectMapName(self.mapee);
					--Debug(">>>>>>>>>>>>",r, name, x)
					VOTED_MAP = name;
					g_utils:EndGame();
				end,
				OnTick = function(self, voter)
					return true
				end,
				Condition = function(self, voter, mapName)
					if (not mapName) then
						return false, "specify valid map"
					end
					local valid = g_utils:IsValidMap(mapName)
					if (not valid) then
						return false, "invalid map"
					end
					if (ATOM:GetMapName(true):lower() == mapName:lower()) then
						return false, "current map already is " .. makeCapital(mapName)
					end
					
					self.mapee = mapName:lower()
					
					return true
				end,
				GetMessage = function(self, voter)
					return "vote to change map to " .. self.mapee:upper();
				end,
				VoteFailed = function(self, voter, ...)
					SendMsg(CHAT_VOTE, ALL, "Map will NOT be changed to %s", makeCapital(self.mapee));
				end,
				MinPerc = 51,
				AllPerc = 51,
			},
			{
				Name = "kick",
				Desc = "Start a vote to kick specified player from the server",
				VoteSucceed = function(self, voter, args)
					g_punishSystem:KickPlayer(ATOM.Server, self.kickee, "Vote Kick");
				end,
				OnTick = function(self, voter)
					if (not GetEnt(self.kickee.id)) then
						return false, "player left";
					end;
					return true;
				end,
				Condition = function(self, voter, targetName, ...)
					if (not targetName) then
						return false, "specify player";
					end;
					local target = GetPlayer(targetName);
					if (not target) then
						return false, "player not found";
					end;
					if (target.id == voter.id) then
						return false, "cannot vote kick yourself";
					end;
					local kickable = self.cfg.Manage.Kickable;
					if (not voter:HasAccess(DEVELOPER) and (not kickable[target:GetAccess()] or voter:GetAccess() < target:GetAccess())) then
						return false, "cannot act against protected users";
					end;
					
					local reason = table.concat({ ... }, " ");
					if (not reason or string.len(reason) < 5) then
						return false, "specify valid reason";
					end;
					
					self.kickee = target;
					
					return true;
				end,
				GetMessage = function(self, voter)
					return formatString("vote to KICK %s", self.kickee:GetName());
				end,
				VoteFailed = function(self, voter, ...)
					if (self.kickee) then
						SendMsg(CHAT_VOTE, ALL, "%s will not be kicked from the Server", self.kickee:GetName());
					end;
					self.kickee = nil;
				end,
				MinPerc = 75,
				AllPerc = 75,
			},
			{
				Name = "time",
				Desc = "Start a vote to add more time to the current match",
				VoteSucceed = function(self, voter, args)
					--g_punishSystem:KickPlayer(ATOM.Server, self.kickee, "Vote Kick");
					g_utils:SetTimeLimit(ATOM.Server, "+30");
					SendMsg(CHAT_VOTE, ALL, "30 Minutes were added to map time");
				end,
				OnTick = function(self, voter)
					local limit = System.GetCVar("g_timelimit");
					if (limit == 0) then
						return false, "time unlimited";
					end;
					local time = g_game:GetRemainingGameTime() / 60;
					if (time > 120) then
						return false, "already enough time";
					end;
					return true;
				end,
				Condition = function(self, voter)
				
					local limit = System.GetCVar("g_timelimit");
					local time = g_game:GetRemainingGameTime() / 60;
					if (limit == 0) then
						return false, "time limit is turned off";
					end;
					Debug(time)
					if (time > 120) then
						return false, "time limit is already high enough";
					end;
					
					return true;
				end,
				GetMessage = function(self, voter)
					return formatString("vote to ADD 30 Minutes to map time");
				end,
				VoteFailed = function(self, voter, ...)
					SendMsg(CHAT_VOTE, ALL, "Game time will not be changed");
				end,
				MinPerc = 51,
				AllPerc = 10,
			},
			{
				Name = "test",
				Desc = "test voting system and get admin",
				VoteSucceed = function(self, voter, args)
					SendMsg(CHAT_VOTE, ALL, "voting succeeded");
				end,
				OnTick = function(self, voter)
					return true;
				end,
				Condition = function(self, voter)
					return true;
				end,
				GetMessage = function(self, voter)
					return formatString("vote to test voting system");
				end,
				VoteFailed = function(self, voter, ...)
					SendMsg(CHAT_VOTE, ALL, "voting failed");
				end,
				MinPerc = 51,
				AllPerc = 10,
			},
		
		},
	},
	-------------
	inProgress = false,
	stopped = false,
	startTime = nil,
	receivedVotes = {},
	-------------
	voteTypes = {},
	-------------
	-- Init
	Init = function(self)
	
		-- Load predefined vote types
		self:LoadVoteTypes();
		
		-- function to easily add new vote types
		AddVoteType = function(...)
			return self:RegisterVote(...);
		end;
		
		-- global instance of this plugin
		-- g_voting = self;
		
		-- Register events
		RegisterEvent("OnTick", self.Tick, 'ATOMVote');
	end,
	-------------
	-- Shutdown
	Shutdown = function(self)
	
		g_voting = nil;
	end,
	-------------
	-- LoadVoteTypes
	LoadVoteTypes = function(self)
	
		-- Register voting types
		for i, t in pairs(self.cfg.Types) do
			self:AddVoteType(t);
		end;
	end,
	-------------
	-- AddVoteType
	AddVoteType = function(self, props)
	
		if (not self.voteTypes[props.Name:lower()]) then
			self.voteTypes[props.Name:lower()] = {
				name = props.Name;
				desc = props.Desc or "No Description";
				canVote 		= props.Condition,
				onVotingSuccess = props.VoteSucceed,
				onVotingFail 	= props.VoteFailed,
				getVoteTitle 	= props.GetMessage,
				onTick			= props.OnTick or function() return true; end,
				MinPerc			= props.MinPerc,
				AllPerc			= props.AllPerc
			};
			--SysLog("[debug] added new vote type %s", props.Name);
		else
			return false, ATOMLog:LogError("Attept to add vote type %s twice", props.Name);
		end;
		
	end,
	-------------
	-- IsManager
	IsManager = function(self, player)
		return player:GetAccess(self.cfg.Manage.Access);
	end,
	-------------
	--GetVoteTypes
	GetVoteTypes = function(self)
		local all = "";
		for i, v in pairs(self.voteTypes) do
			all = all .. i .. ", ";
		end;
		return all:gsub(", $", "");
	end,
	-------------
	-- StartVote
	StartVote = function(self, player, voteType, argument1, argument2, ...)
		
		local cfg = self.cfg.Voting;
		local isManager = self:IsManager(player);
		
		local voteType = string.lower(tostr(voteType));
				
		if (self.inProgress) then
			if (isManager and voteType:lower() == "stop") then
				return true, self:StopVote("Admin Decision", true);
			end;
			return false, "voting already in progress";
		end;
		local voteParams = self.voteTypes[voteType];
		if (not voteParams) then
			return false, " invalid vote (possible votes: " .. self:GetVoteTypes() .. ")";
		end;	
		if (not self.cfg.AllowedVoteTypes[voteType] and not isManager) then
			return false, makeCapital(voteType) .. " is disabled";
		end;
		local remaining = math.ceil(self.cfg.Voting.Delay - _time + (voteParams.lastVote or 0));
		if (remaining > 0 and not isManager) then
			return false, "vote available in " .. calcTime(remaining, 1, 1, 1, 1);
		end;

		local canVote, error = voteParams.canVote(self, player, argument1, argument2, ...);
		if (not canVote) then
			return false, error;
		end;

		self.voteName = makeCapital(voteType);
		self.voteTitle = voteParams.getVoteTitle(self, player, argument1, argument2, ...);
		self.inProgress = true;
		self.stopped = false;
		self.startTime = _time;
		self.messageTime = nil; --_time - cfg.MessageTime - 15;
		self.receivedVotes = {};
		self.votedYes = 0;
		self.votedNo  = 0;
		self.votingPlayer = player;
		
		self.reqPerc = voteParams.MinPerc or cfg.PercentVoted;
		self.allPerc = voteParams.AllPerc or cfg.PercentAll;

		self:Tick()

		return true;
		
	end,
	-------------
	-- Tick
	Tick = function(self)
		local cfg = self.cfg.Voting;
		if (self.inProgress) then
			if (_time - self.startTime >= cfg.Time) then
				--Debug("vote time bad")
				self:StopVote()
			elseif (not self.messageTime or _time - self.messageTime >= cfg.MessageTime) then
				self:VoteMessage()
				self.messageTime = _time
			end
		end
	end,
	-------------
	-- VoteMessage
	VoteMessage = function(self)
		local cfg = self.cfg.Voting;
		if (self.inProgress) then
			local Yes, No = self.votedYes, self.votedNo;
			local YesPercent = (Yes / (Yes + No)) * 100;
			if (tostr(YesPercent) == "-nan(ind)") then
				YesPercent = 0;
			end;
			--Debug(Yes, No, (Yes + No), (Yes / (Yes + No)))
			local NeedPercent = (YesPercent / self.reqPerc) * 100;
			--Debug(YesPercent ,"/",cfg.PercentVoted,"=",NeedPercent)
			--Debug(cfg.PercentVoted, YesPercent, NeedPercent)
			local timeLeft = cfg.Time - (_time - self.startTime);
			
			local voteName = self.voteName;
			local voteTitle = self.voteTitle;
			local voteParams = self.voteTypes[voteName:lower()];
			
			local ok, error = voteParams.onTick(self, self.votingPlayer);
			--Debug(">>>",ok)
			if (ok) then
				SendMsg(CHAT_VOTE, ALL, "(%s : %s | YES : %d, NO : %d ( %d%%, %ds left ))", voteName, voteTitle, Yes, No, max(100, NeedPercent), timeLeft);
				ATOMLog:LogGameUtils(GUEST, "$3%s$9 Vote: %s (No: $4%d$9, Yes: $3%d$9)", voteName, voteTitle, No, Yes, max(100, NeedPercent), timeLeft);
			else
				self:StopVote(error or "Vote Failed");
			end;
		end;
	end,
	-------------
	-- StopVote
	StopVote = function(self, reason, forceFail)
		
		local cfg = self.cfg.Voting;
		local playerCount  = g_gameRules.game:GetPlayerCount(true);
		
		local voteParams = self.voteTypes[self.voteName:lower()];
		
		local Yes, No = self.votedYes, self.votedNo;
		local YesPercent = (Yes / (Yes + No)) * 100;
		if (tostr(YesPercent) == "-nan(ind)") then
			YesPercent = 0;
		end;
		local NeedPercent = (YesPercent / self.reqPerc) * 100;
			
		local percentAll   = (Yes / playerCount) * 100;
		local status = false;
		local voteReq = "% Positive Votes";
		--Debug(percentAll,"|",cfg.PercentAll)
		--Debug(NeedPercent,"|",cfg.PercentVoted)

		if (YesPercent > self.reqPerc and percentAll > self.allPerc and not forceFail) then
			status = true;
		elseif ( percentAll < self.allPerc ) then
			voteReq = "Players voted";
			-- !!HAX
			YesPercent = Yes; --percentAll;
			--Debug(percentAll,"<",self.allPerc)
			self.reqPerc = playerCount * (self.allPerc/100)  --Yes / playerCount; --self.allPerc;
			--reason = reason or "Not enough votes";
		end;
		
		ATOMLog:LogGameUtils(GUEST, "$3%s$9 Vote: %s$9 ( Yes: $3%d$9, No: $4%d$9 )", self.voteName, (status and "$3SUCCEED" or "$4FAILED"), Yes, No, YesPercent, self.reqPerc, voteReq);
		SendMsg(CHAT_VOTE, ALL, "(%s : %s%s | YES : %d, NO : %d ( %d/%d %s ))", self.voteName, (status and "SUCCEED" or "FAILED"), (reason and " (" .. reason .. ")" or ""), Yes, No, YesPercent, self.reqPerc, voteReq);
		
		Script.SetTimer(1000, function()
			if (status) then
				voteParams.onVotingSuccess(self, self.votingPlayer);
			else
				voteParams.onVotingFail(self, self.votingPlayer);
			end;
			
			voteParams.lastVote = _time;
		end);
		
		self.inProgress = false;
		self.receivedVotes = {};
	end,
	-------------
	-- SubmitVote
	SubmitVote = function(self, player, yes)
		if (not self.inProgress) then
			return false, "there is no voting in progress";
		end;
		
		local submittedVotes = self.receivedVotes;
		local submittedVote = submittedVotes[player:GetChannel()];
		local changed = false;
		if ( submittedVote == yes ) then
			return false, "you already voted with " .. (yes and "Yes" or "No");
		elseif ( submittedVote ~= nil ) then
			if (submittedVote == false) then
				self.votedNo = self.votedNo - 1;
				--Debug("removed no vote")
			else
				self.votedYes = self.votedYes - 1;
				--Debug("removed yes vote")
			end;
			changed = true;
		end;
		
		if (yes) then
			self.votedYes = self.votedYes + 1;
		else
			self.votedNo = self.votedNo + 1;
		end;
		
		submittedVotes[player:GetChannel()] = yes;
		
		ATOMLog:LogGameUtils(min(MODERATOR, player:GetAccess()), "%s$9 %s %s$9 in %s-Vote", player:GetName(), (changed and "Changed vote to" or "voted for"), yes and "$3YES" or "$4NO", makeCapital(self.voteName))
		SendMsg(CHAT_VOTE, player, (changed and "You changed your vote to" or "You Voted for") .. " %s", yes and "YES" or "NO");
	end,
};

ATOMVote:Init();