local carPositions = {
	{-2201.8220214844, -1146.3973388672, 19.353067398071, 190},
	{-2205.7553710938, -1148.9044189453, 19.197158813477, 190},
	{-2210.7629394531, -1150.5433349609, 19.238773345947, 190},
	{-2217.6958007813, -1152.3602294922, 19.095628738403, 190},
	{-2223.7507324219, -1154.3714599609, 19.024053573608, 190},
	{-2230.072265625, -1156.9866943359, 19.064571380615, 190},
};

addEvent("startedMiner", true)
addEventHandler("startedMiner", root, function(player)
	player:setData("job >> data", {["started"] = true, ["rockInHand"] = false,})
	local x, y, z, r = unpack(carPositions[math.random(1, #carPositions)])
	local veh = exports.cr_temporaryvehicle:createJobVehicle(player, 422, x, y, z, 0, 0, r, 1, 1, true)
	if(veh) then
		veh:setData("job >> data", {["job"] = 1, ["rocks"] = {}, ["refinedRocks"] = {}})
		setElementJobData(player, "jobVehicle", veh)
		triggerClientEvent(root, "ghostMode", player, veh, "on") 
		setTimer(function() 
			triggerClientEvent(root, "ghostMode", player, veh, "off") 
		end, 10000, 1)
	end
	player:outputChat(msgs["info"].."Elkezdtél dolgozni. Feladat: menj be a bányába és pakold meg a járművedet kövekkel, majd szállítsd le a feldolgozóba.", 255, 255, 255, true)
end)