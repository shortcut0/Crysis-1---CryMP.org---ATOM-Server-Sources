ATOMChat = {
	cfg = {
		ChatEntities = {
			-- chat name   global name  team Id	 log messages to console  access required to see messages
			{ "ATOM",        "ATOM",       0,           true,                       GUEST  };
		};
		
		ConsoleMsgDelay = 1; -- frames
		
		SpamMessages = {
			"Think you're dealing with a cheater? File a Report using !report",
			"Tired of the current map? Use !vote <map> <name> to change it",
			"Dealing with a cheater? report them using !report or vote kick them form the server",
			"Toggle deathkills using !deathkill",
			"Interested in becoming a Staff-Member? You can Apply for Staff using !apply",
			"Stuck in some nasty place? Use !stuck to fix it",
			"Always remember to follow the !rules",
			"Do not use Cheats, Hacks or any other way of gaining unfair advantage over other players!",
			"Annoyed by the Spammy messages? use !chat to disable some Server chat messages",
			"Type !commands in the chat and open your console with [ ~ ] or [ ^ ] to view the list of Commands",
		};
		SpamDelay = 120, -- Minutes
	};
	----------------
	quenedMessages = (ATOMChat~=nil and ATOMChat.quenedMessages or {});
	----------------
	tickCounter    = 0;
	----------------
	chatEntities   = {};
	----------------
	reset = false;
	----------------
	ID = 8; -- because CENTER,CONSOLE,ERROR,INFO,SERVER
	----------------
	Init = function(self)
	
		self:InitGlobals();
		
		self:SpawnChatEntities();
		
		self:InitCases();

		if (not self.cfg.ShowSpectatorChat) then
			System.SetCVar("a_showspectatorchat", "0");
		else
			System.SetCVar("a_showspectatorchat", "1");
		end;
		
		SendMsg = function(...)
			return self:SendMsg(...);
		end;
	end;
	----------------
	InitGlobals = function(self)
	
		CENTER    = 0.1; -- = TextMessageCenter
		CONSOLE   = 1.1; -- = TextMessageConsole
		ERROR     = 2.1; -- = TextMessageError
		INFO      = 3.1; -- = TextMessageInfo      !! don't change these values, they are defined and used in DLL
		SERVER    = 4.1; -- = TextMessageServer
		
		ALL		  = 5.1;
		TEAM	  = 6.1;
		
		MSGGROUP  = 7.1; -- unused
		
		CONSOLE_NOQUENE = 8; -- same as CONSOLE message, but this forcefully inserts a console message with highest priority
		CONSOLE_ATOM	= 8.4; -- same as CONSOLE message
		
		BLE_INFO		= 8.1;
		BLE_CURRENCY	= 8.2;
		BLE_ERROR		= 8.3;

		ChatToAllEx = ChatToAll + 1
		ChatToTeamEx = ChatToAll + 2


		aChatTypes = {
			[ChatToTarget] = "To Target",
			[ChatToAll] = "To All",
			[ChatToAllEx] = "To All (Ex)",
			[ChatToTeam] = "To Team",
			[ChatToTeamEx] = "To Team (Ex)",
		}
	end;
	----------------
	InitCases = function(self)
		CASE_MANY	 = 0;
		CASE_ONE	 = 1;
		CASE_TEAM	 = 2;
		CASE_ALL 	 = 3;
		CASE_ACCESS  = 4;
	end;
	----------------
	SpawnChatEntity = function(self, entityName, consoleLog, globalLog)
		
		local name		  = entityName;
		local class		  = "Reflex";
		local position	  = { x = self.ID, y = self.ID, z = 1000 + self.ID };
		local orientation = { x = 0, y = 0, z = 1 };
		local properties  = {};
		
		local spawnParams = {
			name		  = name,
			class		  = class,
			position	  = position,
			orientation	  = orientation,
		--	properties	  = properties
		};
		local chatEntity  = System.SpawnEntity(spawnParams);

		--Debug("spawned ?",tostring(chatEntity))
		chatEntity.IS_CHAT_ENTITY = true
		return chatEntity;

	end;
	----------------
	GetChatEntity = function(self, t)
		local gV = _G[t:upper()];
		if (gV and (gV==CENTER or gV==ERROR or gV==INFO or gV==SERVER)) then
			return gV;
		end;
		gV = _G["CHAT_"..t:upper()];
		if (gV) then
			return gV;
		end;
		return nil
	end;
	----------------
	SpawnChatEntities = function(self)
		SysLogVerb(2, "ATOMChat::SpawnChatEntities")
		local entity;
		
		Script.SetTimer(300, function()
		for i, entityData in pairs(self.cfg.ChatEntities or{}) do
			
				--Debug("-----------------------------------")
				--Debug("Entity:", entityData[1], entityData[2])
				self.ID = self.ID + 1;
				
				entity = self:GetChatEntityByName(entityData[2]);
				if (entity) then
					entity = nil;
					self:RemoveEntity(entityData[1]);
				--	Debug("FCK OFF ENTITIY :D")
				end;
				--Debug("entity NOW",entity)
				entity = self:SpawnChatEntity(entityData[1]);
				--Debug("entity HTHEN",entity)
				--end;
				--Debug("Entity=",entity)
				
				if (not entity) then
					SysLogVerb(2, "WARNING: GAME FAILED TO SPAWN CHAT ENTITY %s", entityData[2]);
				else
				
					entity.isChatEntity = true;
					
					_G["CHAT_" .. entityData[2]:upper()] = self.ID;
					_G["CHAT_" .. entityData[2]:upper() .. "_ENTITY_ATOM_NOREPLACE" ] = entity;
					
					self.chatEntities[ self.ID ] = entity.id;
					
					local teamId = tonum(entityData[3]);
					
					if ((teamId > 0 and g_gameRules.class == "PowerStruggle")) then
						g_game:SetTeam(teamId, entity.id);
						SysLog("chat entity %s got team %s", entity:GetName(), GetTeamName(teamId))
					end;
					
					if (entityData[4]) then
						entity.logMessages = entityData[4];
						entity.logAccess   = entityData[5] or GetLowestAccess();
					end;
				end;
			--Debug("New entity:", entity:GetName())
		end;
		end);
	end;
	----------------
	RemoveChatEntities = function(self)
		if (Config and Config.Chat and Config.Chat.ChatEntities) then
			self.cfg.ChatEntities = mergeTables(self.cfg.ChatEntities, Config.Chat.ChatEntities);
		end;
		for i, entityData in pairs(self.cfg.ChatEntities or{}) do

			local entity = self:GetChatEntityByName(entityData[1]);
			if (entity) then
				System.RemoveEntity(entity.id);
			end;
		end;
		
		for i, entity in pairs(System.GetEntities()) do
			if (entity.isChatEntity) then
				System.RemoveEntity(entity.id);
			end;
		end;
	end;
	----------------
	OnTick = function(self)
		if (not self.lastSpamMsg or _time - self.lastSpamMsg >= self.cfg.SpamDelay ) then
			self.lastSpamMsg = _time;
			local access = GUEST;
			local loadstr = false;
			local noInfo = false;
			local rules = "*"
			local msg = GetRandom(self.cfg.SpamMessages);
			if (type(msg) == "table") then
				access = msg[2] or msg.Access;
				rules = msg.Rules or "*";
				noInfo = msg.NoInfo;
				loadstr = msg.Load;
				msg = (loadstr and loadstring(msg[1] or msg.Msg)() or msg[1] or msg.Msg);
			end;
			if (g_gameRules.class:match(rules)) then
				local them = GetPlayers();
				for i, v in pairs(them) do
					if (not v.Popups or not v:HasAccess(access)) then
						table.remove(them, i);
					end;
				end;
				if (arrSize(them) > 0) then
					SendMsg(INFO, them, (not noInfo and "[ INFO ] " or "") .. msg);
				end;
			end;
		end;
	end,
	----------------
	ResetEntities = function(self)
		SysLogVerb(2, "ATOMChat::ResetEntities");
		self:SpawnChatEntities()
	end;
	----------------
	RemoveEntity = function(self, entityName)
		local entity = _G[ "CHAT_" .. entityName:upper() .. "_ENTITY_ATOM_NOREPLACE" ];
		if (entity ~= nil) then
			--Debug("Removed entity ", entityName:upper())
			Script.SetTimer(1, function()
				System.RemoveEntity(entity.id);
			end);
		end;
		_G[ "CHAT_" .. entityName:upper() .. "_ENTITY_ATOM_NOREPLACE" ] = nil;
	end;
	----------------
	GetChatEntityByName = function(self, entityName)
		
		--Debug("GetChatEntityByName??")
		local entity = _G[ "CHAT_" .. entityName:upper() .. "_ENTITY_ATOM_NOREPLACE" ];
		if (entity == nil or (entity and not GetEnt(entity.id))) then
			return;
		end;
		
		if (entity:GetName() ~= entityName or (not entity.IS_CHAT_ENTITY)) then
			System.RemoveEntity(entity.id);
		end;
	--	System.LogAlways("ENTITY !!!!!!!!!!!!!!!!")
		--Debug("Found entitiy???")
		return GetEnt(entity.id);
	end;
	----------------
	GetChatEntityByID = function(self, entityId)
		return self.chatEntities[ entityId ];
	end;
	----------------
	SendPM = function(self, player, target, message)
		if (player.id == target.id) then
			return false, "Cannot send PM to yourself";
		elseif (ATOMPunish.ATOMMute:CheckMute(player)) then --IsMuted(player)) then
			return false, "Cannot send PM while muted";
		end;
		self:OnPM(player, target, message);
		self:SendMsg(CHAT_PM, target, "(%s: %s)", player:GetName(), message);
		self:SendMsg(CHAT_PM, player, "Your Message was send to %s", target:GetName());--, message);
		--self:SendMsg(player, target, "(PM: %s)", message); -- removed to prevent "faking" pms
		return true;
	end;
	----------------
	AddToPM = function(self, player, target)
		player.PMGroup = player.PMGroup or {};
		if (player.id == target.id) then
			return false, "Cannot add yourself to your PM Conversation";
		elseif (not player.PMGroup[target.id]) then
			player.PMGroup[target.id] = target:GetName();
			SendMsg(CHAT_PM, player, "(%s: Added to PM Conversation)", target:GetName());
		else
			player.PMGroup[target.id] = nil;
			SendMsg(CHAT_PM, player, "(%s: Removed from PM Conversation)", target:GetName());
		end;
		return true;
	end;
	----------------
	OnPM = function(self, player, target, message)
		SendMsg(CONSOLE, target, "$9=====[ $7PM:SYSTEM$9 ]==============================================================================================");
		SendMsg(CONSOLE, target, "$9[ $1" .. space(28-string.len(player:GetName())) .. player:GetName() .. " $9: $1" .. string.lenprint(message:sub(1, 80), 80) .. " $9]");
		SendMsg(CONSOLE, target, "$9==============================================================================================[ $7PM:SYSTEM$9 ]=====");
	end;
	----------------
	ConvertForFind = function(self, word, ww, bspace)
		local newWord = "";
		if (ww) then
			newWord = "(^? ?)" .. word .. "($? ?)"
		else
			for i = 1, string.len(word) do
				newWord = newWord .. word:sub(i, i) .. (i ~= string.len(word) and "+(.*)" or "");
			end
			Debug("Adv??")
		end;
		return newWord;
	end;
	----------------
	ConvertForFind = function(self, sWord, bWholeWord, bSpace)

		local iWord = string.len(sWord)
		local sNewWord
		if (not bWholeWord) then
			sNewWord = ""
			for i = 1, iWord do
				sNewWord = sNewWord .. string.sub(sWord, i, i) .. (i ~= iWord and "+(.*)" or "")
			end
		else
			sNewWord = "(^? ?)" .. string.gsub(sWord, ".", "%1(%%s*)") .. "($? ?)"
			if (bSpace) then
				sNewWord = "(^? ?)" .. string.gsub(sWord, ".", "%1(%%s*)(%1*)") .. "($? ?)"
			end
		end

		return sNewWord
	end,
	----------------
	OnChatMessage = function(self, t, playerId, senderId, message)
		local player = GetEnt(playerId);
		local target = GetEnt(senderId);

		local cfg = self.cfg;

		if (player.isPlayer) then
			g_statistics:AddToValue("ChatTotal", 1);
		end;

		if (player.isPlayer) then

			local filterChat = self.cfg.ChatFilter;
			local forbidden = self.cfg.ForbiddenWords;
			local replace = self.cfg.ReplaceWords;
			local canSwear = self.cfg.AdminsCanSwear and player:HasAccess(ADMINISTRATOR) or player.ToxicityPass; -- !!FIXME
			local isSwearing = false;
			local swearWord;
			local p1,p2;
			if (filterChat) then
				if (forbidden and not canSwear and not player.messageModified) then
					for word, isforbidden in pairs(forbidden) do
						if (isforbidden) then
							p1, p2= message:lower():find(tostr((self.cfg.AdvancedSearch and self:ConvertForFind(word) or word)):lower());
							if (p1 and p2) then
								isSwearing = true;
								swearWord = word;
								SysLog("%s is swearing! (%s)", player:GetName(), word);
								break;
							end;
						end;
					end;
					if (isSwearing) then
						if (self.cfg.CensorMessage and p1 and p2) then
							local _b, _a = message:sub(0, p1 - 1), message:sub(p2 + 1, 999);
							--Debug(p1, p2, p2-(p1-1))
							local _n = _b .. censor(space(p2-(p1-1))) .. _a
							if (not player.messageCensored) then
								SendMsg(CHAT_ATOM, player, "%s, Watch your Language.", player:GetName());
								SendMsg(CONSOLE_NOQUENE, player, "  $9($1%s: $4Watch your Language.$9)", message:sub(1,10));
								ATOMLog:LogSwearing(maximum(DEVELOPER, minimum(MODERATOR, player:GetAccess()+1)), "%s$9 Is Sewaring ($4%s$9)", player:GetName(), swearWord);
							end;
							player.messageCensored = true;
							g_game:SendChatMessage(t, playerId, senderId, _n);
							return false;
						else
							SendMsg(CHAT_ATOM, player, "%s, Watch your Language.", player:GetName())
							SendMsg(CONSOLE_NOQUENE, player, "  $9($1%s: $4Watch your Language.$9)", message:sub(1,10))
							ATOMLog:LogSwearing(maximum(DEVELOPER, minimum(MODERATOR, player:GetAccess()+1)), "%s$9 Is Sewaring ($4%s$9)", player:GetName(), swearWord)
						end;
						if (g_warnSystem:ShouldWarn("Swearing")) then
							WarnPlayer(ATOM.Server, player, "Swearing");
						end;
						return false;
					end;
				end;

				if (replace and not canSwear) then
					local newMessage = tostr(message);
					local wasReplaced = false;
					for word, replacement in pairs(replace) do
						local rep = replacement;
						if (type(replacement) == "table") then
							rep = copyTable(rep);
							if (rep.AdvancedSearch) then
								rep.AdvancedSearch = nil; -- Ugly workaround lmao
								rep.WholeWord = nil; -- Ugly workaround lmao
								rep = tostr(GetRandom(rep));
								word = self:ConvertForFind(word);
							elseif (rep.WholeWord) then
								rep.AdvancedSearch = nil; -- Ugly workaround lmao
								rep.WholeWord = nil; -- Ugly workaround lmao
								rep = tostr(GetRandom(rep));
								word = self:ConvertForFind(word, 1);
							else
								rep = tostr(GetRandom(rep));
							end;
						else
							rep = tostr(rep)
						end;
						--Debug("R = ",word)
						if (rep and string.len(tostr(rep))>0 and rep~=word) then
							while newMessage:lower():find(tostr(word):lower()) do
								local s, e = newMessage:lower():find(tostr(word):lower());
								if (s and e) then
									--Debug(e-s)
									if (e-s < 25) then
										local before, after = string.sub(newMessage, 1, s - 1), string.sub(newMessage, e + 1, 999);
										--Debug(">", before, "+",after)
										wasReplaced = true;
										--	SysLog("replacing word %s with %s",word, replacement);
										newMessage = before .. rep .. after; --newMessage:gsub("[(a+a+a)]", replacement);
									else
										break;
									end;
								else
									break; -- WTF!?!
								end;
							end;
						end;
					end;
					if (wasReplaced) then
						--SendMsg(CHAT_ATOM, player, "%s, Watch your Language.", player:GetName());
						--SendMsg(player, t==ChatToAll and ALL or t==ChatToTarget and sender or TEAM, newMessage);
						--Debug(message)
						--Debug(newMessage)
						player.messageModified = true;
						g_game:SendChatMessage(t, playerId, senderId, newMessage);
						SysLog("Message from %s was altered ('%s' now '%s')", player:GetName(), message, newMessage);
						ATOMLog:LogSwearing(DEVELOPER, "Message from %s$9 was changed ($4%s$9)", player:GetName(), message);
						return false;
					end;
				end;
			end;
			local spamCfg = cfg.Spam;
			if (spamCfg) then
				--Debug(_time - player.MessageTime,player.SpamCount)
				if (not player.CmdMsg and player.LastMessage and message == player.LastMessage and player.MessageTime and _time - player.MessageTime < spamCfg.SpamTime) then
					player.SpamCount = (player.SpamCount or 0) + 1;
					if (player.SpamCount > spamCfg.Spam) then
						if (not player.MessageMuted or _time - player.MessageMuted > 5) then
							if (not player:HasAccess(MODERATOR) or spamCfg.CheckAdmins ) then
								player.MessageMuted = _time;
								ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, player, spamCfg.MuteDuration, "Chat Spam");
								--	Debug("CHILL TITS :D")
								SendMsg(CHAT_MUTESYS, player, "%s, Chill with the Spam.", player:GetName());
								SendMsg(INFO, ALL, "(%s: User has been Muted for Rule-Breaking Activity(!))", player:GetName());
								if (g_warnSystem:ShouldWarn("ChatSpam")) then
									WarnPlayer(ATOM.Server, player, "Chat Spam");
								end;
							end;
						end;
					end;
				elseif (not player.CmdMsg and player.MessageTime and _time - player.MessageTime < spamCfg.FloodTime) then
					player.MessageCount = (player.MessageCount or 0) + 1;
					--Debug(player.MessageCount)
					if (player.MessageCount > spamCfg.Flood) then
						if (not player.MessageMuted or _time - player.MessageMuted > 5) then
							if (not player:HasAccess(MODERATOR) or spamCfg.CheckAdmins ) then
								player.MessageMuted = _time;
								ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, player, spamCfg.MuteDuration, "Chat Flood");
								SendMsg(CHAT_MUTESYS, player, "%s, Chill with the Spam.", player:GetName());
								SendMsg(INFO, ALL, "(%s: User has been Muted for Rule-Breaking Activity(!))", player:GetName());
								if (g_warnSystem:ShouldWarn("ChatFlood")) then
									WarnPlayer(ATOM.Server, player, "Chat Flood");
								end;
							end;
						end;
					end;
				else
					--	Debug("RESET")
					player.MessageTime 	= _time;
					player.MessageCount = 0;
					player.SpamCount 	= 0;
					player.LastMessage 	= message;
				end;
			end;

			if (not player.CmdMsg and player.isPlayer and player and player.PMGroup and arrSize(player.PMGroup) > 0 and t == ChatToAll) then
				for i, targetName in pairs(player.PMGroup) do
					if (GetEnt(i)) then
						SendMsg(CHAT_PM, GetEnt(i), "Received new PM from [ %s ] - Open Console!", player:GetName());
						self:OnPM(player, GetEnt(i), message);
					else
						SendMsg(INFO, player, "[ PM:SYSTEM ]-[ %s ]-REMOVED FROM CONVERSATION", targetName);
					end;
				end;
				if (arrSize(player.PMGroup) == 1) then
					SendMsg(CHAT_PM, player, "Message send to %s", getFirst(player.PMGroup));
				else
					SendMsg(CHAT_PM, player, "Message send to [ %d ] Players", arrSize(player.PMGroup));
				end;
				--Debug("It's a PM");
				return false;
			end;

			local responses = self.cfg.ChatResponses;
			local responded = {}
			if (responses and t == ChatToAll) then
				local doBreak = false;
				for i, resp in pairs(responses) do
					if (type(resp[1]) == "table") then
						for j, _resp in pairs(resp[1]) do
							--Debug("one of dis?",_resp)
							if (message:lower():find(_resp) and player:HasAccess(resp.Access) and not responded[resp[2]]) then

								-- responded[resp[2]]=true
								Script.SetTimer(1000, function()
									SendMsg(resp.Type or CHAT_ATOM, (resp.All and ALL or player), resp[2]);
								end);
								--Debug("Si")
								doBreak = true; -- only 1 response per message
							end;
							if (doBreak) then break; end;
						end;
					else
						if (message:lower():find(resp[1]) and player:HasAccess(resp.Access) and not responded[resp[2]]) then
							-- responded[resp[2]] = true
							Script.SetTimer(1000, function()
								SendMsg(resp.Type or CHAT_ATOM, (resp.All and ALL or player), resp[2]);
							end);
							doBreak = true; -- only 1 response per message
						end;
					end;
					if (doBreak) then break; end;
				end;

			end;
		end;
		player.messageModified = false;
		player.messageCensored = false;
		return true;
	end;
	--------------
	OnChatMessage = function(self, iType, idPlayer, idSender, sMessage)
		local hPlayer = GetEnt(idPlayer)
		local hTarget = GetEnt(idSender) -- unused

		if (not hPlayer) then
			return
		end

		local sPlayer = hPlayer:GetName()

		local aConfig = self.cfg

		if (hPlayer.isPlayer) then
			g_statistics:AddToValue("ChatTotal", 1)

			local sName = hPlayer:GetName()
			local iAccess = hPlayer:GetAccess()
			local iLogAccess = maximum(DEVELOPER, minimum(MODERATOR, iAccess + 1))

			local aSpamConfig = aConfig.Spam
			local bAdvancedSearch = aConfig.AdvancedSearch
			local bSpacedSearch = aConfig.SpacedSearch
			local bFilterChats = aConfig.ChatFilter
			local aForbiddenWords = aConfig.ForbiddenWords
			local aReplaceWords = aConfig.ReplaceWords
			local aHideTriggers = aConfig.HideMessages
			local bToxPass = ((aConfig.AdminsCanSwear and hPlayer:HasAccess(ADMINISTRATOR)) or hPlayer.ToxicityPass ~= false); -- !!FIXME
			local bIsSwearing = false
			local sLastSwearWord, sNewMessage, sBefore, sAfter, sMiddle

			local x, y

			if (bFilterChats and not hPlayer.CmdMsg) then



				local bWasHidden = hPlayer.bMessageHidden
				hPlayer.bMessageHidden = false

				if (bWasHidden) then
					return true
				end

				local bHideMessage = false
				if (aHideTriggers and not bWasHidden and iType ~= ChatToTarget) then
					for i, aTriggers in pairs(aHideTriggers) do
						bHideMessage = nil
						for ii, sTrigger in pairs(aTriggers) do

							x, y = string.find(string.lower(sMessage), self:ConvertForFind(sTrigger, 1, 1))

							if (bHideMessage == nil) then
								bHideMessage = (x and y) ~= nil
							else
								bHideMessage = bHideMessage and ((x and y) ~= nil)
							end

						end
						if (bHideMessage) then
							break
						end
					end
					if (bHideMessage) then
						hPlayer.bMessageHidden = true

						local iTypeNew = ChatToAllEx
						if (iType == ChatToTeam) then
							iTypeNew = ChatToTeamEx
						end

						g_game:SendChatMessage(iTypeNew, idPlayer, idSender, sMessage)
						ATOMLog:LogSwearing(DEVELOPER, "Message from %s$9 was Hidden ($4%s$9)", sName, sMessage)
						ATOMLog:LogChatMessageToPlayer(iType, hPlayer, sMessage)

						SysLog("Message from %s was Hidden from other players ('%s' to %s)", sName, sMessage, aChatTypes[iType])

						return false
					end
				end

				if (isArray(aForbiddenWords) and not bToxPass and not hPlayer.messageModified) then

					for sWord, bForbidden in pairs(aForbiddenWords) do
						if (bForbidden) then

							x, y = string.find(string.lower(sMessage), string.lower((bAdvancedSearch and self:ConvertForFind(sWord, nil, 1) or (bSpacedSearch and self:ConvertForFind(sWord, 1, 1)) or sWord)))
							--x, y = message:lower():find(tostring((bAdvancedSearch and self:ConvertForFind(word) or word)):lower())
							if (x and y) then
								bIsSwearing = true
								sLastSwearWord = sWord
								SysLog("%s is Swearing! (%s)", hPlayer:GetName(), sWord)
								break
							end
						end
					end

					if (bIsSwearing) then

						if (g_warnSystem:ShouldWarn("Swearing")) then
							WarnPlayer(ATOM.Server, hPlayer, "Swearing")
						end

						if (aConfig.CensorMessage and x and y) then
							sBefore, sAfter, sMiddle  = string.sub(sMessage, 0, x - 1), string.sub(sMessage, y + 1, 999), string.sub(sMessage, x, y)
							sNewMessage = sBefore .. (string.rep("*", (y - (x - 1)))) .. sAfter

							if (bSpacedSearch) then
								sNewMessage = sBefore .. (string.rep("*", string.len(sLastSwearWord))) .. sAfter
							end

							if (not hPlayer.messageCensored) then
								SendMsg(CHAT_ATOM, hPlayer, "%s, Watch your Language.", sName)
								SendMsg(CONSOLE_NOQUENE, hPlayer, "  $9($1%s: $4Watch your Language.$9)", sMessage:sub(1, 10))
								ATOMLog:LogSwearing(iLogAccess, "%s$9 Is Swearing ($4%s$9)", sName, sLastSwearWord)
							end

							hPlayer.messageCensored = true
							g_game:SendChatMessage(iType, idPlayer, idSender, sNewMessage)
							return false
						else
							SendMsg(CHAT_ATOM, hPlayer, "%s, Watch your Language.", sName)
							SendMsg(CONSOLE_NOQUENE, hPlayer, "  $9($1%s: $4Watch your Language.$9)", sMessage:sub(1, 10))
							ATOMLog:LogSwearing(iLogAccess, "%s$9 Is Swearing ($4%s$9)", sName, sLastSwearWord)
						end

						return false
					end
				end

				local bWasModified = hPlayer.bMessageModified
				hPlayer.bMessageModified = false

				if (aReplaceWords and not bToxPass) then

					--Debug("FInd oi",hPlayer.CmdMsg)
					local bWasReplaced = false
					local bSkipReplacement = false
					sNewMessage = tostring(sMessage)

					for _sWord, aReplacement in pairs(aReplaceWords) do
						local sReplacement = table.copy(aReplacement)
						local sWord = _sWord

						bSkipReplacement = false
						if (isArray(sReplacement)) then
							sReplacement = table.copy(sReplacement)

							if (sReplacement.RandomTrigger and math.random(1, 100) < checkNumber(sReplacement.TriggerChance, 50)) then
								bSkipReplacement = true
							end

							sReplacement.RandomTrigger = nil -- Ugly workaround ughh
							sReplacement.TriggerChance = nil -- Ugly workaround ughh

							--Debug(sReplacement)

							local sException = sReplacement.Exception
							if (sException and string.find(string.lower(sNewMessage), string.lower(sException))) then
								SysLog("Message exception '%s' stopped replacement!", sException)
								bSkipReplacement = true
							end

							sReplacement.Exception = nil

							if (sReplacement.SpecialSearch) then

								sReplacement.SpecialSearch = nil -- Ugly workaround ughh
								sReplacement = tostring(GetRandom(sReplacement))
								sWord = self:ConvertForFind(sWord, 1, 1)
							elseif (sReplacement.AdvancedSearch) then

								sReplacement.AdvancedSearch = nil -- Ugly workaround ughh
								sReplacement = tostring(GetRandom(sReplacement))
								sWord = self:ConvertForFind(sWord)
							elseif (sReplacement.WholeWord) then

								sReplacement.WholeWord = nil; -- Ugly workaround ughh
								sReplacement = tostring(GetRandom(sReplacement))
								sWord = self:ConvertForFind(sWord, 1)
							else

								sReplacement = tostring(GetRandom(sReplacement))
							end

						else
							sReplacement = tostring(sReplacement)
						end

						if (not bSkipReplacement and sReplacement and string.len(sReplacement) > 0 and string.lower(sReplacement) ~= string.lower(sWord) and not (string.find(string.lower(sReplacement), string.lower(sWord)))) then

							while (true) do

								x, y = string.find(string.lower(sNewMessage), string.lower(sWord))

								if (x and y) then

									if (y - x >= 25) then
										break
									end

									sBefore, sAfter = string.sub(sNewMessage, 1, x - 1), string.sub(sNewMessage, y + 1, 999)
									bWasReplaced = true
									sNewMessage = sBefore .. sReplacement .. sAfter
								else
									break
								end
							end
						end
					end

					if (bWasReplaced and (sNewMessage ~= sMessage)) then
						hPlayer.messageModified = true
						hPlayer.bMessageModified = true
						g_game:SendChatMessage(iType, idPlayer, idSender, sNewMessage)
						ATOMLog:LogSwearing(DEVELOPER, "Message from %s$9 was changed ($4%s$9)", sName, sMessage)
						SysLog("Message from %s was altered ('%s' now '%s')", sName, sMessage, sNewMessage)
						return false
					end
				end
			end

			if (aSpamConfig and not hPlayer.CmdMsg) then

				if (not hPlayer.CmdMsg and hPlayer.LastMessage and sMessage == hPlayer.LastMessage and hPlayer.MessageTime and (_time - hPlayer.MessageTime < aSpamConfig.SpamTime)) then

					hPlayer.SpamCount = (hPlayer.SpamCount or 0) + 1
					if (hPlayer.SpamCount > checkNumber(aSpamConfig.Spam, 0)) then
						if (not hPlayer.MessageMuted or (_time - hPlayer.MessageMuted > 5)) then
							if (not hPlayer:HasAccess(MODERATOR) or aSpamConfig.CheckAdmins) then

								hPlayer.MessageMuted = _time
								ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, hPlayer, aSpamConfig.MuteDuration, "Chat Spam")
								SendMsg(CHAT_MUTESYS, hPlayer, "%s, Chill with the Spam.", sName)
								SendMsg(INFO, ALL, "(%s: User has been Muted for Rule-Breaking Activity(!))", sName)
								if (g_warnSystem:ShouldWarn("ChatSpam")) then
									WarnPlayer(ATOM.Server, hPlayer, "Chat Spam")
								end
							end
						end
					end
				elseif (not hPlayer.CmdMsg and hPlayer.MessageTime and _time - hPlayer.MessageTime < aSpamConfig.FloodTime) then

					hPlayer.MessageCount = (hPlayer.MessageCount or 0) + 1
					if (hPlayer.MessageCount > aSpamConfig.Flood) then
						if (not hPlayer.MessageMuted or (_time - hPlayer.MessageMuted > 5)) then
							if (not hPlayer:HasAccess(MODERATOR) or aSpamConfig.CheckAdmins) then

								hPlayer.MessageMuted = _time
								ATOMPunish.ATOMMute:MutePlayer(ATOM.Server, hPlayer, aSpamConfig.MuteDuration, "Chat Flood")
								SendMsg(CHAT_MUTESYS, hPlayer, "%s, Chill with the Spam.", sName)
								SendMsg(INFO, ALL, "(%s: User has been Muted for Rule-Breaking Activity(!))", sName)
								if (g_warnSystem:ShouldWarn("ChatFlood")) then
									WarnPlayer(ATOM.Server, hPlayer, "Chat Flood")
								end
							end
						end
					end
				else
					--	Debug("RESET")
					hPlayer.MessageTime 	= _time
					hPlayer.MessageCount	= 0
					hPlayer.SpamCount 		= 0
				end

				hPlayer.LastMessage 	= sMessage
			end

			local iGroupCount = table.count(hPlayer.PMGroup)
			if (not hPlayer.CmdMsg and hPlayer.isPlayer and hPlayer.PMGroup and iGroupCount > 0 and iType == ChatToAll) then

				local hUser, bAnyMessageSent
				for idUser, sUser in pairs(hPlayer.PMGroup) do
					hUser = GetEnt(idUser)
					if (hUser) then
						SendMsg(CHAT_PM, hUser, "(%s: Send you a Private Message, Check Console!)", sName)
						self:OnPM(hPlayer, hUser, sMessage)
						bAnyMessageSent = true
					else
						SendMsg(INFO, player, "(%s: Removed from PM Conversation)", sUser)
					end
				end

				if (bAnyMessageSent) then
					if (iGroupCount == 1) then
						SendMsg(CHAT_PM, hPlayer, string.format("(Message delivered to %s)", getFirst(hPlayer.PMGroup)))
					else
						SendMsg(CHAT_PM, hPlayer, string.format("(Message send to ( %d ) Players)", iGroupCount))
					end
				end

				--Debug("It's a PM")
				return false
			end;

			-- 1 = Trigger, 2 = Response (String or Array or Strings)

			local aResponses = self.cfg.ChatResponses
			if (isArray(aResponses) and iType == ChatToAll and not hPlayer.CmdMsg) then

				local bBreak = false
				local bHasAccess = false

				for i, aResponse in pairs(aResponses) do

					bHasAccess = hPlayer:HasAccess(checkNumber(aResponse.Access, GUEST))
					if (isArray(aResponse[1])) then
						for j, sResponse in pairs(checkArray(aResponse[1], {})) do

							--Debug("one of dis?",sResponse)
							if (string.find(string.lower(sMessage), sResponse) and bHasAccess) then

								Script.SetTimer(1000, function()
									SendMsg(checkNumber(aResponse.Type, CHAT_ATOM), (aResponse.All and ALL or hPlayer), aResponse[2])
								end)
								if (aResponse.BlockMessage) then
									return false -- Hide players message?
								end
								bBreak = true
								break
							end
						end
					else

						if (string.find(string.lower(sMessage), aResponse[1]) and bHasAccess) then

							Script.SetTimer(1000, function()
								SendMsg(checkNumber(aResponse.Type, CHAT_ATOM), (aResponse.All and ALL or hPlayer), aResponse[2])
							end)
							if (aResponse.BlockMessage) then
								return false -- Hide players message?
							end
							bBreak = true
							break
						end
					end

					if (bBreak) then
						break
					end
				end
			end
		end

		hPlayer.messageModified = false
		hPlayer.messageCensored = false

		if (hPlayer.bHideAllMessages and (not hPlayer.bLastMessageHidden) and iType ~= ChatToTarget) then
			hPlayer.bLastMessageHidden = true

			local iTypeNew = ChatToAllEx
			if (iType == ChatToTeam) then
				iTypeNew = ChatToTeamEx
			end

			g_game:SendChatMessage(iTypeNew, idPlayer, idSender, sMessage)
			ATOMLog:LogSwearing(math.min(ADMINISTRATOR, hPlayer:GetAccess()), "Message from %s$9 was Hidden ($4By Command | %s$9)", sPlayer, sMessage)
			ATOMLog:LogChatMessageToPlayer(iType, hPlayer, sMessage)

			SysLog("(Cmd) Message from %s was Hidden from other players ('%s' to %s)", sPlayer, sMessage, aChatTypes[iType])

			return false
		end

		hPlayer.bLastMessageHidden = nil

		return true
	end,
	----------------
	SendMsg = function(self, entityId, receiver, message, ...)
		local receiver = receiver;
		local message = formatString(message, ...);
		if (type(receiver) == "table" and receiver.isServer) then
			SysLog("Command Response " .. message);
			return;
		end;
		
		if (type(receiver) == "table" and receiver[1] and receiver[1].id and receiver[1].GetAccess) then
			if (arrSize(receiver) == arrSize(GetPlayers())) then
		--		Debug("All.")
		--		receiver = ALL;
			end;
		end;
		
		if (type(entityId) == "table") then
			if ( entityId.id ) then
				return self:ProcessMessage(entityId, receiver, message, System.GetEntity(entityId.id));
			else
				for i, v in pairs(entityId) do
					self:SendMsg(v, receiver, message);
				end;
			end;
			return true;
		end;
		
		if (type(receiver) == "string" and _G[receiver]) then
			receiver = _G[receiver];
		end;
		if (type(entityId) == "string" and _G[entityId]) then
			entityId = _G[entityId];
		end;
		
		--Debug("receiver1=",receiver,"entityId-",entityId)
		local entity = self:GetChatEntityByID(entityId);
		self:ProcessMessage(entityId, receiver, message, entity);
		
	end;
	----------------
	SendMsg_NoLog = function(self, entityId, receiver, message, ...)
		
		return self:SendMsg(true, entityId, receiver, message, ...);
		
	end;
	----------------
	ProcessMessage = function(self, entityId, receiver, message, entity)
		if (entityId == BLE_CURRENCY or entityId == BLE_ERROR or entityId == BLE_INFO) then
			self:BattleLogEvent(entityId, receiver, message);
		elseif (entityId == ERROR or entityId == CONSOLE or entityId == CONSOLE_NOQUENE or entityId == CONSOLE_ATOM or entityId == CENTER or entityId == INFO or entityId == SERVER) then
		--	Debug("TextMessage", message, "type", entityId)
			return self:TextMessage(entityId, receiver, message);
		elseif (entity) then
			self:ChatMessage(entity, receiver, message);
		end;
	end;
	----------------
	GetReceiver = function(self, r)
		local n;
		if (type(r) == "string") then
			n = GetPlayer(r);
		else
			n = r;
		end;
		return n;
	end;
	----------------
	TextMessage = function(self, textMessageType, receiver, message)
		if (type(sender) == "userdata") then
			sender = System.GetEntity(sender);
		end;
		local r = self:GetReceiver(receiver);
		local r_type = type(r);
		if (r_type == "number") then
			if (r == ALL) then
				if (textMessageType == CONSOLE_ATOM) then
					ATOMLog:LogATOM(GetPlayers(), message);
				elseif (textMessageType == CONSOLE_NOQUENE) then
					self:AddConsoleMessage({ receiver,  message});
				elseif (textMessageType == CONSOLE) then
					self:QueneConsoleMessage({ receiver,  message});
				else
				--	Debug("ERROR >> ", textMessageType-0.1, ERROR, TextMessageError,message, TextMessageError==textMessageType-0.1)
					return g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToAll);
				end;
			elseif (r == TEAM) then
				local t = {};
				for i, player in pairs(GetPlayers()or{}) do
					if (player:GetTeam() == receiver:GetTeam()) then
						if (textMessageType == CONSOLE or textMessageType == CONSOLE_NOQUENE) then
							table.insert(t, player);
						else
							g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToClient, player.id);
						end;
					end;
				end;
				if (textMessageType == CONSOLE_ATOM) then
					ATOMLog:LogATOM(t, message);
				elseif (textMessageType == CONSOLE_NOQUENE) then
					self:AddConsoleMessage({ t,  message});
				elseif (textMessageType == CONSOLE) then
					self:QueneConsoleMessage({ t,  message});
				end;
				return;
			elseif (IsUserGroup(r)) then
				local t = GetPlayers(r);
				if (textMessageType == CONSOLE_ATOM) then
					ATOMLog:LogATOM(t, message);
				elseif (textMessageType == CONSOLE_NOQUENE) then
					return self:AddConsoleMessage({ t,  message});
				elseif (textMessageType == CONSOLE) then
					return self:QueneConsoleMessage({ t,  message});
				end;
				for i, player in pairs(t or{}) do
					g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToClient, player.id);
				end;
				return;
			end;
		elseif (r_type == "table") then
			if (r.id and r.actor) then
				if (textMessageType == CONSOLE_ATOM) then
					ATOMLog:LogATOM(r, message);
				elseif (textMessageType == CONSOLE_NOQUENE) then
					self:AddConsoleMessage({ r,  message});
				elseif (textMessageType == CONSOLE) then
					self:QueneConsoleMessage({ r,  message });
				else
					g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToClient, r.id);
				end;
			else
				local t = {};
				for i, player in pairs(r) do
					if (textMessageType == CONSOLE_NOQUENE) then
						self:AddConsoleMessage({ t,  player });
					elseif (textMessageType == CONSOLE) then
						table.insert(t, player);
					else
						g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToClient, player.id);
					end;
				end;
				if (textMessageType == CONSOLE_ATOM) then
					ATOMLog:LogATOM(t, message);
				elseif (textMessageType == CONSOLE_NOQUENE) then
					self:AddConsoleMessage({ t,  message});
				elseif (textMessageType == CONSOLE) then
					self:QueneConsoleMessage({ t,  message });
				end;
			end;
			return;
		else
			if (textMessageType == CONSOLE_NOQUENE) then
				return self:AddConsoleMessage({ receiver,  message});
			elseif (textMessageType == CONSOLE) then
				return self:QueneConsoleMessage({ receiver,  message });
			else
				return g_game:SendTextMessage(self:GetTextMessageType(textMessageType), message, TextMessageToClient, receiver.id);
			end;
		end;
	end;
	----------------
	GetTextMessageType = function(self, typeId)
		if (typeId == CENTER) then
			return TextMessageCenter;
		elseif (typeId == CONSOLE) then
			return TextMessageConsole;
		elseif (typeId == ERROR) then
			return TextMessageError;
		elseif (typeId == INFO) then
			return TextMessageInfo;
		elseif (typeId == SERVER) then
			return TextMessageServer;
		end;
	end;
	----------------
	ChatMessage = function(self, sender, receiver, message)
	
		local sender = sender
		if (type(sender) == "userdata") then
			sender = System.GetEntity(sender);
		end;
		
		--if (type(sender) == "table" and sender.isPlayer) then
		--	sender.CmdMsg = true;
		--end;
	
		--Debug("sender",sender)

		local r = self:GetReceiver(receiver);
		local r_type = type(r);
		if (r_type == "number") then
			--SysLog("**************Ok, to Number lol")
			if (r == ALL) then
				return self:SendMessageToAll(sender, message);
			elseif (r == TEAM) then
				for i, player in pairs(GetPlayers()or{}) do
					if (player:GetTeam() == sender:GetTeam()) then
						self:SendMessageToTarget(sender, player, message);
					end;
				end;
				return;
			elseif (IsUserGroup(r)) then
				
			--	SysLog("IS USER GROUP!!!")
				local t = GetPlayers(r);
				if (arrSize(t)>0) then
					if (arrSize(t) == arrSize(GetPlayers())) then
						self:SendMessageToAll(sender, message);
					else
						for i, player in pairs(t or{}) do
					--		SysLog(player:GetName().." ::: IS USER GROUP!!!")
							self:SendMessageToTarget(sender, player, message);
						end;
					end;
				end;
				return;
			end;
		elseif (r_type == "table") then
			--SysLog("**************Ok, to Table")
			if (r.id and r.actor) then
				self:SendMessageToTarget(sender, r, message);
			elseif (arrSize(r) > 0) then
				if (arrSize(r) == arrSize(GetPlayers())) then
					self:SendMessageToAll(sender, message);
				else
					for i, player in pairs(r) do
						self:SendMessageToTarget(sender, player, message);
					end;
				end;
			end;
			return;
		else
			--SysLog("******************Ok, to single")
			return self:SendMessageToTarget(sender, receiver, message);
		end;
	end;
	----------------
	BattleLogEvent = function(self, logType, receiver, message)
		
		local logType = (logType == BLE_CURRENCY and "eBLE_Currency" or logType == BLE_ERROR and "eBLE_Warning" or "eBLE_Information");
		local code = "ATOMClient:HandleEvent(eCE_BattleLog, " .. logType .. ", \"" .. message:gsub("\"","\\\"") .. "\")";
		
		local r = self:GetReceiver(receiver);
		local r_type = type(r);
		if (r_type == "number") then
			if (r == ALL) then
				return ExecuteOnAll(code);
			elseif (r == TEAM) then
				for i, player in pairs(GetPlayers()or{}) do
					if (player:GetTeam() == receiver:GetTeam()) then
						if (player.ATOM_Client) then
							ExecuteOnPlayer(player, code, true);
						else
							RPC:OnPlayer(player, "Execute", { code = "HUD.BattleLogEvent(" .. logType .. ", \"" .. message:gsub("\"","\\\"") .. "\")" })
						end
					end;
				end;
				return;
			elseif (IsUserGroup(r)) then
			--	SysLog("IS USER GROUP!!!")
				local t = GetPlayers(r);
				for i, player in pairs(t or{}) do
			--		SysLog(player:GetName().." ::: IS USER GROUP!!!")
					if (player.ATOM_Client) then
						ExecuteOnPlayer(player, code, true);
					else
						RPC:OnPlayer(player, "Execute", { code = "HUD.BattleLogEvent(" .. logType .. ", \"" .. message:gsub("\"","\\\"") .. "\")" })
					end
				end;
				return;
			end;
		elseif (r_type == "table") then
			if (r.id and r.actor) then
				if (r.ATOM_Client) then
					ExecuteOnPlayer(r, code, true);
				else
				--	Debug("ok now")
					--RPC:OnPlayer(r, "Execute", { code = "System.LogAlways('hi')" })
					RPC:OnPlayer(r, "Execute", { code = "HUD.BattleLogEvent(" .. logType .. ", \"" .. message:gsub("\"","\\\"") .. "\")" })
				end
			else
				for i, player in pairs(r) do
					if (player.ATOM_Client) then
						ExecuteOnPlayer(player, code, true);
					else
						RPC:OnPlayer(player, "Execute", { code = "HUD.BattleLogEvent(" .. logType .. ", \"" .. message:gsub("\"","\\\"") .. "\")" })
					end
				end;
			end;
			return;
		end;
		--Debug("Code: " .. code)
	end;
	----------------
	SendMessageToTarget = function(self, sender, receiver, message)
		--if (sender.isPlayer) then
		----	Debug("!!",sender.CmdMsg)
		--end
		if (g_game and sender and receiver and message) then
			if (sender.isPlayer and not sender.PMMsg) then
				sender.CmdMsg = true;
			--	Debug("True now1")
			else
				sender.PMMsg = false;
			end;
			g_game:SendChatMessage(ChatToTarget, sender.id, receiver.id, message);
		else
			SysLogVerb(2, "missing parameters to SendMessageToTarget (msg=%s, sender=%s, receiver=%s)", tostr(message), tostr(sender), tostr(receiver))
		end;
	end;
	----------------
	SendMessageToAll = function(self, sender, message)
		if (g_game and sender and message) then
			if (sender.isPlayer and not sender.PMMsg) then
				sender.CmdMsg = true;
			--	Debug("True now2")
			else
				sender.PMMsg = false;
			end;
			g_game:SendChatMessage(ChatToAll, sender.id, sender.id, message);
		else
			SysLogVerb(2, "missing parameters to SendMessageToAll (msg=%s, sender=%s, receiver=%s)", tostr(message), tostr(sender), tostr(receiver))
			SysLogVerb(2, "traceback: %s", debug.traceback()or"tb failed")
		end;
	end;
	----------------
	AddConsoleMessage = function(self, q)
		local oldQuene = self.quenedMessages;
		local newQuene = { [1] = q };
		for i, message in pairs(oldQuene) do
			newQuene[ i + 1 ] = message;
		end;
		self.quenedMessages = newQuene;
	end;
	----------------
	QueneConsoleMessage = function(self, q)
		--Debug(tostr(q[1]))
		--Debug("New item in console: ", q[2],"daddy=",(q[1].GetName and q[1]:GetName()))
		table.insert(self.quenedMessages, q);
	end;
	----------------
	UpdateQuene = function(self)
		self.tickCounter = self.tickCounter + 1;
		if (self.cfg.ConsoleMsgDelay == 0) then
			if (arrSize(self.quenedMessages) > 0) then
				if (arrSize(self.quenedMessages) == 1) then -- save memory if single item
					self:UpdateQuened();
				else
					for i = 1, arrSize(self.quenedMessages) do
						self:UpdateQuened(); -- process whole quene
					end;
				end;
			end;
		elseif (self.tickCounter >= self.cfg.ConsoleMsgDelay) then
			self.tickCounter = 0;
			if (arrSize(self.quenedMessages) > 0) then
				self:UpdateQuened();
			end;
		end;
	end;
	----------------
	UpdateQuened = function(self)
		--Debug(#self.quenedMessages)
		local queueItem = self.quenedMessages[ 1 ]; -- {msg, TextMessageToXXXX, target}
		-- in the queue can be 1 target id or table of entities
		if (type(queueItem[ 1 ]) == "table") then
			if (queueItem[ 1 ].id and queueItem[ 1 ].actor) then
				g_game:SendTextMessage(CONSOLE-0.1, queueItem[ 2 ], TextMessageToClient, queueItem[ 1 ].id);
			else
				for i, player in pairs(queueItem[1]) do
					if (isArray(player)) then
						g_game:SendTextMessage(CONSOLE-0.1, queueItem[ 2 ], TextMessageToClient, player.id);
					else
						SysLog("Invalid entry in the message queue (%s: %s)", type(player), tostring(player))
					end
				end;
			end;
		elseif (IsUserGroup(queueItem[ 1 ])) then
			for i, player in pairs(GetPlayers(queueItem[1])) do
				g_game:SendTextMessage(CONSOLE-0.1, queueItem[ 2 ], TextMessageToClient, player.id);
			end;
		else
		--	Debug(type(queueItem[ 1 ]))
		--	g_game:SendTextMessage(CONSOLE, queueItem[ 2 ], TextMessageToClient, queueItem[ 1 ].id);
		end;
		table.remove(self.quenedMessages, 1);
	end;
	----------------
};
ATOMChat:InitGlobals()

SendMsg = function(...)
	return (ATOMChat and ATOMChat:SendMsg(...) or nil);
end;
SendMsg_NoLog = function(...)
	return (ATOMChat and ATOMChat:SendMsg_NoLog(...) or nil);
end;