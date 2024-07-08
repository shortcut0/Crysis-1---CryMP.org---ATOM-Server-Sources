ATOMCasino = {
	cfg = {
		GameConfig = {
		
		},
	},
	Games = {
		{
			"bet",
			"bet prestige with a 40% chance to win twice as much as you bet",
			function(player, amount)
				local pp = player:GetPrestige();
				if (pp == 0) then
					return false, "insufficient prestige";
				end;
				if (amount > pp) then
					amount = pp;
				end;
				player.perfs.SpendMoney = (player.perfs.SpendMoney or 0) + amount;
				player:PayPrestige(amount);
				local rnd = math.random(100);
				local win = rnd >= 55;
				if (win) then
					SendMsg(CHAT_CASINO, player, "(BET: Congratulations, you've just won %d Prestige!)", amount * 2);
					SendMsg(CHAT_CASINO, GetPlayers(nil, nil, player.id), "(BET: %s just won %d Prestige in !bet)", player:GetName(), amount * 2);
					player:GivePrestige(amount * 2);
				else
					SendMsg(CHAT_CASINO, player, "(BET: Sorry, you've just lost %d Prestige!)", amount);
				end;
				return true;
			end,
			{ { "Amount", "The Amount of prestige to bet", Integer = true, Range = { 50, 5000 }, Required = true }, { GameRules = "PowerStruggle", Timer = 60 } },
		},
		{
			"blackjack",
			"Play a round of blackjack to win twice as much as you bet",
			function(player, amount)
				if (not player.BlackJacking) then
					local pp = player:GetPrestige();
					if (pp == 0) then
						return false, "insufficient prestige";
					end;
					amount = tonumber(amount);
					if (not amount) then
						return false, "specify valid amount";
					end;
					if (amount > pp) then
						amount = pp;
					end;
					player.perfs.SpendMoney = player.perfs.SpendMoney + amount;
					player:PayPrestige(amount);
					SendMsg(CHAT_CASINO, player, "(BLACKJACK: Game Started, use !blackjack to try to win %d Prestige!)", amount * 2);
					player.BlackJacking = {
						PC = { math.random(1, 12) },
						DC = { math.random(1, 12) },
						Win = amount * 2
					};
				else
					amount = amount:lower();
					local dCA, pCA = 0, 0;
					for i, v in pairs(player.BlackJacking.PC) do
						pCA = pCA + v;
					end;
					for i, v in pairs(player.BlackJacking.DC) do
						dCA = dCA + v;
					end;
					if (amount == "stand") then
						if (pCA > dCA) then
							SendMsg(CHAT_CASINO, player, "(BLACKJACK: You beat the Dealer and Won %d Prestige!)", player.BlackJacking.Win);
							player:GivePrestige(player.BlackJacking.Win);
						else
							SendMsg(CHAT_CASINO, player, "(BLACKJACK: Sorry, but the Dealer had better cards, better luck next Time!)", player.BlackJacking.Win);
						end;
						player.BlackJacking = nil;
						return true;
					elseif (amount == "hit") then
						local nPC, nDC = math.random(1, 12), math.random(1, 12);
						SendMsg(CHAT_CASINO, player, "(BLACKJACK: You Drew a %d (Total: %d)", nPC, pCA + nPC);
						--SendMsg(CHAT_CASINO, player, "(BLACKJACK: The Dealer Drew a %d (Total: %d)", nDC, dCA + nDC); 
						if (pCA + nPC > 21) then
							SendMsg(CHAT_CASINO, player, "(BLACKJACK: Sorry, but your Cards value is above 21, better luck next Time!)");
							player.BlackJacking = nil;
							return true
						elseif (dCA + nDC > 21) then
							SendMsg(CHAT_CASINO, player, "(BLACKJACK: The Dealers Cards value is above 21, You won %d Prestige!)", player.BlackJacking.Win);
							player:GivePrestige(player.BlackJacking.Win);
							player.BlackJacking = nil;
							return true
						end;
						table.insert(player.BlackJacking.PC, nPC);
						table.insert(player.BlackJacking.DC, nDC);
					elseif (amount == "cards") then
						local pC = table.concat(player.BlackJacking.PC, ", ") or "No Cards Drawn yet";
						SendMsg(CHAT_CASINO, player, "(BLACKJACK: Your Cards: %s (Total: %d))", pC, pCA);
					else
						return false, "choose valid option (hit/stand/cards)";
					end;
				end;
				return true;
			end,
			{ { "Option", "Your action", Required = true } },
		},
		{
			"guess",
			"try to guess a random number between 1 and 120 and win twice as much as you bet (winning with 1st try triples the reward)",
			function(player, amount)
				if (not player.GuessingGame) then
					local pp = player:GetPrestige();
					if (pp == 0) then
						return false, "insufficient prestige";
					end;
					if (amount > pp) then
						amount = pp;
					end;
					if (amount < 50) then
						return false, "you need to bet at least 50 Prestige";
					end;
					player:PayPrestige(amount);
					SendMsg(CHAT_CASINO, player, "(GUESS: Game started, use !guess to guess the number and win %d Prestige!)", amount * 2);
					--player:Pay(amount * 2);
					player.GuessingGame = {
						Bet = amount,
						Win = amount * 2,
						Try = 0,
						Num = math.random(1, 120)
					};
				else
					if (amount > 120 or amount < 0) then
						return false, "out of range";
					end;
					player.GuessingGame.Try = player.GuessingGame.Try + 1;
					if (amount == player.GuessingGame.Num) then
						local FirstTry = player.GuessingGame.Try == 1;
						if (FirstTry) then
							player.GuessingGame.Win = player.GuessingGame.Win + player.GuessingGame.Bet;
						end;
						SendMsg(CHAT_CASINO, player, "(GUESS: Congratulations, you've guessed the right number %sand won %d Prestige!)", FirstTry and "with 1 try " or "", player.GuessingGame.Win);
						SendMsg(CHAT_CASINO, GetPlayers(nil, player.id), "(GUESS: %s just won %d Prestige in !guess)", player:GetName(), player.GuessingGame.Win);
						player:GivePrestige(player.GuessingGame.Win);
						player.GuessingGame = nil;
						return true;
					elseif (player.GuessingGame.Try < 8) then
						SendMsg(CHAT_CASINO, player, "(GUESS: Sorry, but the real number is %s than %d (%d Tries left)", (amount > player.GuessingGame.Num and "lesser" or "greater"), amount, 8 - player.GuessingGame.Try);
					end;
					if (player.GuessingGame.Try == 8) then
						SendMsg(CHAT_CASINO, player, "(GUESS: Sorry, but the real number was %d, I get to keep your Prestige!)", player.GuessingGame.Num);
						player.GuessingGame = nil;
						return true;
					end;
				end;
				return true;
			end,
			{ { "Amount", "Number", Integer = true, Range = { 1, 50000 }, Required = true }, { GameRules = "PowerStruggle", Timer = 0 } },
		},
	
	},
	---------------------
	--      Init
	---------------------
	Init = function(self)
		self:AddCommands();
	end,
	---------------------
	--    AddCommands
	---------------------
	AddCommands = function(self)
		for i, game in pairs(self.Games) do
			NewCommand({
				Name 	= game[1],
				Access	= GUEST,
				Description = game[2],
				Console = true,
				Args = game[4] or {
				};
				Properties = game[5] or {
					GameRules = "PowerStruggle",
				};
				func = game[3]or function(self)
					return true;
				end;
			});
		end;
	end,
	---------------------
	--      Init
	---------------------
	Init1 = function(self)
	
	end,
	---------------------
	--      Init
	---------------------
	Init1 = function(self)
	
	end,
	---------------------
	--      Init
	---------------------
	Init1 = function(self)
	
	end,
	---------------------
	--      Init
	---------------------
};

ATOMCasino:Init()