-- Server implementation for client ranked models to play proper taunting sounds
IRankedModels = {
	OnRevive = function(self, player)
		local rank = g_gameRules.game:GetSynchedEntityValue(player.id, g_gameRules.RANK_KEY) or 1;
		local team = g_game:GetTeam(player.id);
		player.TCM = nil;
		if(rank <= 7 and team == 1)then
			player.TCM = MODELID_KOREAN_SOLDIER;
		end;
		Debug("TCM",player.TCM)
	end,
};

--RegisterEvent("OnRevive", IRankedModels.OnRevive, IRankedModels);