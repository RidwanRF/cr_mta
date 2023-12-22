addEvent("idCard->Request", true);
addEventHandler("idCard->Request", root, function(player)
	if client and client == player then
		local time = getRealTime();

		local start = 1900 + time.year .. ". " .. ("%02d"):format(time.month + 1) .. ". " .. ("%02d"):format(time.monthday) .. ".";
		local expired = nil;

		if time.month + 5 > 12 then
			expired = 1900 + time.year + 1 .. ". " .. ("%02d"):format(time.month + 5 - 12) .. ". " .. ("%02d"):format(time.monthday) .. ".";
		else
			expired = 1900 + time.year .. ". " .. ("%02d"):format(time.month + 5) .. ". " .. ("%02d"):format(time.monthday) .. ".";
		end

		local table = {
			name = getElementData(player, "char >> name"):gsub("_", " "),
			id = getElementData(player, "acc >> id"),
			skin = player.model,
			start = start,
			expired = expired,
		};

		exports.cr_inventory:giveItem(player, 78, table);
	end
end);