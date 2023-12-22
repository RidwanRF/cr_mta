local rods = {};
local floats = {};

addEvent("fishing->CreateRod", true);
addEventHandler("fishing->CreateRod", root, function(player)
	if client and player == client then
		if not rods[player] then
			rods[player] = Object(338, 0, 0, 0);
			rods[player].scale = 1.4;
			exports.cr_bone_attach:attachElementToBone(rods[player], player, 12, 0.15, 0, 0.07, 0, 260, 0);

			setElementData(player, "char->Fishing", true);
		else
			rods[player]:destroy();
			rods[player] = nil;

			if floats[player] then
				floats[player]:destroy();
				floats[player] = nil;

				triggerClientEvent(root, "fishing->Sync", root, floats, rods);
			end

			setElementData(player, "char->Fishing", false);
		end
	end
end);

addEvent("fishing->CreateFloat", true);
addEventHandler("fishing->CreateFloat", root, function(player, x, y)
	if client and player == client then
		if not floats[player] then
			floats[player] = Object(1974, x, y, 0);

			floats[player].scale = 2;
			setElementCollisionsEnabled(floats[player], false);

			triggerClientEvent(root, "fishing->Sync", root, floats, rods);
		else
			floats[player]:destroy();
			floats[player] = nil;

			triggerClientEvent(root, "fishing->Sync", root, floats, rods);
		end
	end
end);

addEventHandler("onPlayerQuit", root, function()
	if rods[source] then
		rods[source]:destroy();
		rods[source] = nil;
	end

	if floats[source] then
		floats[sorce]:destroy();
		floats[sorce] = nil;

		triggerClientEvent(root, "fishing->Sync", root, floats, rods);
	end
end);

addEvent("fishing->AnimPlayer", true);
addEventHandler("fishing->AnimPlayer", root, function(player, block, name)
	if client and client == player then
		if not block and not name then
			setPedAnimation(player);
		else
			setPedAnimation(player, block, name, -1, true, true, true);
		end
	end
end);