local noob = {
	["FragGrenade"] = true,
	["GaussRifle"] = true,
	["C4"] = true

};
ATOMSetup:AddSetup('multiplayer/ia/poolday_v2', function()
	for i, entity in pairs(System.GetEntities()) do
		if (noob[entity.class]) then
			System.RemoveEntity(entity.id);
		end;
	end;
end);