local lamps = {};

addEvent("lamp->ChangeState", true);
addEventHandler("lamp->ChangeState", root, function(player, array)
	if client and client == player then
		if isElement(lamps[player.vehicle]) then
			detachElements(lamps[player.vehicle], player.vehicle);
			destroyElement(lamps[player.vehicle]);

			setElementData(player.vehicle, "lamps->State", false);
			exports.cr_chat:createMessage(player, "levesz egy taxi lámpát a kocsiról", 1);
		else
			lamps[player.vehicle] = Object(16307, player.vehicle.position);
			attachElements(lamps[player.vehicle], player.vehicle, array[1], array[2], array[3], array[4], array[5], array[6]);

			setElementData(player.vehicle, "lamps->State", true);
			exports.cr_chat:createMessage(player, "felrak egy taxi lámpát a kocsira", 1);
		end
	end
end);

addEventHandler("onElementDestroy", root, function()
	if lamps[source] then
		destroyElement(lamps[source]);
	end
end);