-------------------------------------------------------------------
-- !localstats

NewCommand({
	Name 	= "localstats",
	Access	= MODERATOR,
	Console = true,
	Description = "Shows the local stats of online players";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "Sort Top Players by selected type", Optional = true, AcceptThis = { 
	--		['exp'] = true
	--	}};
	};
	Properties = {
		Self = 'ATOMStats.PermaScore',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Class)
		local allScores = self.permaScore;--[[{};
		for i, v in pairs(GetPlayers()or{}) do
			if (self.permaScore[v:GetIdentifier()]) then
				allScores[v:GetIdentifier()] = self.permaScore[v:GetIdentifier()];
			end;
		end;--]]
		local theScores = {};
		for i, v in pairs(allScores) do
			theScores[arrSize(theScores)+1] = {
				i,
				v
			};
		end;
		table.sort(theScores,function(a,b)
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
		
		local function online(id)
			for i, v in pairs(GetPlayers()or{}) do
				if (v:GetIdentifier() == id) then
					return true;
				end;
			end;
			return false;
		end;
		
		for i, v in ipairs(theScores) do
			if (online(v[1])) then
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
					exp = "999999+";
				end;
				level 	= (ATOMLevelSystem.savedEXP[v[1]] and ATOMLevelSystem.savedEXP[v[1]].Level  or 0);
				streak 	= (data.killStreak or 0);
				
				name	= (data.name or "<Unknown>");
				
				visits 	= (data.Visits or 0);
				
				if (i < 10 or v[1] == id) then 
					if ( i >= 10 ) then
						SendMsg(CONSOLE, player, "$9================================================================================================================");
					end;
					rankInfo = "[ $1#" .. string.lenprint(i, 3) .. " $5" .. string.lenprint(name:sub(1, 19), 19);
					if (v[1] == id) then
						rankInfo = "[ $1#" .. string.lenprint(i, 3) .. " $3YOUR : RANK" .. repStr(6, i) .. " ->";
					end;
					
					SendMsg(CONSOLE, player, "$9" .. rankInfo .. " $9| $4" .. kills .. repStr(5, kills) .. " $9| $4" .. repStr(5, deaths) .. deaths .. " $9| $4" .. repStr(4, heads) .. heads .. " $9| $6" .. repStr(5, box) .. box .. " $9| $6" .. repStr(4, level) .. level .. " $9| $7" .. repStr(7, exp) .. exp .. " $9| $4" .. repStr(4, frags) .. frags .. " $9| $4" .. repStr(4, streak) .. streak .. " $9| $4" .. repStr(3, visits) .. visits .. " $9| $4" .. repStr(13, playTime) .. playTime .. " $9]");
				end;
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
-- !team

NewCommand({
	Name 	= "team",
	Access	= MODERATOR,
	Console = true,
	Description = "Changes the team of a player or yourself";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "Sort Top Players by selected type", Optional = true, AcceptThis = { 
	--		['exp'] = true
	--	}};
		{ "Target", "The Name of the player", Target = true, Required = false, AcceptAll = true, AcceptSelf = true };
		{ "Team", "The Name of the Team", Required = true, AcceptThis = {
			[0] = true,
			[1] = true,
			[2] = true,
			["us"] = true,
			["nk"] = true,
			["neutral"] = true
		}};
	};
	Properties = {
		Self = 'ATOMGameUtils',
		GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, Target, Team)
		return self:ChangeTeam(player, Target, Team);
	end
});




-------------------------------------------------------------------
-- !resetnextmap

NewCommand({
	Name 	= "resetnextmap",
	Access	= MODERATOR,
	Console = true,
	Description = "Resets the next map";
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
		if (not VOTED_MAP) then
			return false, "no next map selected yet";
		end;
		local last = VOTED_MAP;
		VOTED_MAP = nil;
		SendMsg(CHAT_ATOM, player, "Next Map Reset : %s (Previous %s)", self:NextLevel(true):sub(16), last:sub(16));
		return true;
	end;
});

-------------------------------------------------------------------
-- !capture

NewCommand({
	Name 	= "capture",
	Access	= MODERATOR,
	Console = true,
	Description = "Capture nearest or specified PS building";
	Args = {
	--	{ "Option",	"Option for you action", Required = true, AcceptThis = {
	--		['export'] = true,
	--		['import'] = true,
	--		['status'] = true
	--	}};
	--	{ "Type", "Sort Top Players by selected type", Optional = true, AcceptThis = { 
	--		['exp'] = true
	--	}};
		{ "Building", "The Name of the Building", Optional = true };
		{ "Team", "The team Id", Optional = true, Integer = true, Range = { 0, 2 }, AcceptThis = nil };
	};
	Properties = {
		Self = 'ATOMGameUtils',
		GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, ...)
		return self:CaptureBuilding(player, ...);
	end
});

-------------------------------------------------------------------
-- !behind

NewCommand({
	Name 	= "behind",
	Access	= MODERATOR,
	Console = true,
	Description = "Teleports yourself behind specified player";
	Args = {
		{ "Target", "The Name of the player", Target = true, Required = true, AcceptAll = false, AcceptSelf = false, TargetAlive = true };
	};
	Properties = {
		Self = 'ATOMGameUtils',
	--	GameRules = 'PowerStruggle'
	--	Timer = 1,
	};
	func = function(self, player, target)
		if (not target.Initialized) then
			return false, "target is not initialized";
		end;
		local behind = target:CalcSpawnPos(-4, -2);
		g_game:MovePlayer(player.id, behind, GetAngles(behind, target));
		SendMsg(CHAT_ATOM, player, "(YOU: Teleported behind %s)", target:GetName());
		return true;
	end
});