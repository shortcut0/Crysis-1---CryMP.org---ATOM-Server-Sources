ATOMBank = {
	cfg = {
		MaxPrestige 	= 100000;
		StoragePerLevel = 1000;
		StartLevel 		= 1;
		DailyPay 		= 25; -- in percent
	};
	----------------
	savedBank = ATOMBank ~= nil and ATOMBank.savedBank or {};
	----------------
	Init = function(self)
		self:LoadFile();
		
		RegisterEvent("OnLevelUp", self.OnLevelUp, 'ATOMBank');
		RegisterEvent("OnTick", self.OnTick, 'ATOMBank');
	end;
	----------------
	InitPlayer = function(self, player)
	
		player.GetBank = function(self)
			return ATOMBank:GetAccount(self);
		end;
		-----------
		player.GetBankPrestige = function(self)
			return self.BankData.Prestige;
		end;
		-----------
		player.DepositPrestige = function(self, amount)
			return ATOMBank:Deposit(self, amount);
		end;
		-----------
		player.WithdrawPrestige = function(self, amount)
			return ATOMBank:Withdraw(self, amount);
		end;
		-----------
		player.AddPrestigeToBank = function(self, amount)
			return ATOMBank:AddToAccount(self, amount);
		end;
	end;
	----------------
	OnLevelUp = function(self, player, new, old)
		local levels = new - old;
		local identifier = player:GetIdentifier();
		if (not CanScore(identifier)) then
			return;
		end;
		self.savedBank[identifier].MaxPrestige = math.min(self.cfg.MaxPrestige, self.savedBank[identifier].MaxPrestige + (levels * self.cfg.StoragePerLevel));
	end;
	----------------
	Default = function(self, access)
		local d = {
			Prestige 	= 0,
			MaxPrestige	= self.cfg.StoragePerLevel;
		};
		return d;
	end;
	----------------
	GetDailyBonus = function(self, amount)
		return amount * (self.cfg.DailyPay / 100)
	end;
	----------------
	OnConnect = function(self, player)
		local identifier = player:GetIdentifier();
		if (not CanScore(identifier)) then
			player.BankData = self:Default();
			return;
		end;
		if (identifier) then
			self.savedBank[identifier] = self.savedBank[identifier] or self:Default();
			player.BankData = self.savedBank[identifier];
		end;
	end;
	----------------
	GetAccount = function(self, player)
		local identifier = player:GetIdentifier();
		if (not CanScore(identifier)) then
			return self:Default();
		end;
		self.savedBank[identifier] = self.savedBank[identifier] or self:Default();
		return self.savedBank[identifier];
	end;
	----------------
	Deposit = function(self, player, amount)
	
		if (not amount) then
			return false, "Specify amount";
		end;
		amount = math.floor(amount + 0.5);
	
		local everything = false;
		
		if (amount > player:GetPrestige()) then
			everything = true;
			amount = player:GetPrestige();
		end;
	
		local bank = self:GetAccount(player);
		local limit = bank.MaxPrestige;
		local curr	 = bank.Prestige;
		local deposit = curr + amount;
		local space = limit - curr;
		
		if (space <= 0) then
			return false, "Your Bank is Full";
		end;
		
		local full = false;
		
		if (amount > space) then
			amount = space;
			full = true;
		end;
		
		 if (amount < player:GetPrestige()) then
			everything = false;
		end;
		
		local bank = self:GetAccount(player);
		bank.Prestige = bank.Prestige + amount;
		
		SendMsg(CHAT_BANK, player, "You have deposited " .. (everything and "all your" or " [ " .. amount .. " ]") .. " Prestige to your Bank Account " .. (full and "(Bank Now Full)" or ""));
		player:PayPrestige(amount);
		
		return true, self:OnBankChange();
	end;
	----------------
	Withdraw = function(self, player, amount)
	
		if (not amount) then
			return false, "Specify amount";
		end;
	
		amount = math.floor(amount + 0.5);
	
		local everything = false;
		
	
		local bank = self:GetAccount(player);
		local curr	 = bank.Prestige;
		if (curr < 1) then
			return false, "Your Bank is empty";
		end;
		
		local full = false;
		
		if (amount > curr) then
			amount = curr;
			everything = true;
		end;
		
		
		local bank = self:GetAccount(player);
		bank.Prestige = bank.Prestige - amount;
		
		SendMsg(CHAT_BANK, player, "You have withdrawn " .. (everything and "all your" or " [ " .. amount .. " ]") .. " Prestige from your Bank Account " .. (everything and "(Bank Now Empty)" or ""));
		player:GivePrestige(amount);
		
		return true, self:OnBankChange();
	end;
	----------------
	GetBankRank = function(self, player)
		local bank = player:GetBank();
		local bankScore = bank.Prestige + (bank.MaxPrestige / 3);
		local rank = 1;
		for i, v in pairs(self.savedBank) do
			if (i ~= player:GetIdentifier()) then
				local score = v.Prestige + (v.MaxPrestige / 2);
				if (score > bankScore) then
					rank = rank + 1;
				end;
			end;
		end;
		return rank;
	end;
	----------------
	ConvertTable = function(self)
		local t = {};
		for i, v in pairs(self.savedBank) do
			if (CanScore(i)) then
				t[arrSize(t)+1] = {
					i,
					v.Prestige,
					v.MaxPrestige
				};
			end;
		end;
		return t;
	end;
	----------------
	OnBankChange = function(self, nosave)
		for i, player in pairs(GetPlayers()or{}) do
			local identifier = player:GetIdentifier();
			if (identifier) then
				self.savedBank[identifier] = player.BankData;
			end;
		end;
		if (not nosave) then
			if (not self.lastSave or _time - self.lastSave >= 60) then
				self.lastSave = _time;
				self:SaveFile();
			end;
		end;
	end;
	----------------
	IsPayDay = function(self)
		local time = System.GetCVar("e_time_of_day");
		if (time >= 12 and time <= 13) then
			if (not self.AccountsPayed) then
				self.AccountsPayed = true;
				return true;
			end;
		else
			self.AccountsPayed = false;
		end;
		return false;
	end,
	----------------
	OnTick = function(self)
		if (g_gameRules.class ~= "PowerStruggle") then
			return
		end
		
		local full = false;
		local bonus = 0;
		local added = 0;
		local free = 0;
		local player;
		if (self:IsPayDay()) then
			self:OnBankChange(true);
			for i, account in pairs(self.savedBank) do
				full = false;
				extraMsg = "";
				bonus = 0;
				added = 0;
				player = GetPlayerByProfileID(i)
				free = account.MaxPrestige - account.Prestige;
				if (free > 0) then
					if (account.Prestige > 100) then
						bonus = round(maximum(account.MaxPrestige, self:GetDailyBonus(account.Prestige)));
						if (bonus > 0) then
							account.Prestige = round(account.Prestige + bonus);
							if (account.MaxPrestige <= account.Prestige) then
								extraMsg = "(Bank is now full)";
							end;
							added = bonus;
						else
							extraMsg = "(Report this to admins ASAP!)"
						end;
					else
						extraMsg = "(You're too broke)";
					end
				else
					extraMsg = "(Bank is full)";
				end;
				if (player) then
					SendMsg(CHAT_BANK, player, "PayDay : Your Bank Account Got ( +%d PP ) Bonus! %s", added, extraMsg);
				end;
			end;
		end;
	end,
	----------------
	OnDisconnect = function(self, player)
		local identifier = player:GetIdentifier();
		if (not CanScore(identifier)) then
			return;
		end;
		if (identifier and self.savedEXP[identifier]) then
			self:OnBankChange();
		end;
	end;
	----------------
	LoadAccount = function(self, id, prestige, max)
		self.savedBank[id] = {
			Prestige = prestige;
			MaxPrestige = (max or self.cfg.StoragePerLevel)
		};
	end;
	----------------
	SaveFile = function(self)
		SaveFile("ATOMBank", "Bank.lua", "ATOMBank:LoadAccount", self:ConvertTable(self.savedEXP));
	end;
	----------------
	LoadFile = function(self)
		LoadFile("ATOMBank", "Bank.lua");
	end;
	-----
	
};