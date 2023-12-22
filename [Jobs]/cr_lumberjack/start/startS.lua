local carPositions = {
	{1105.5125732422, -294.96627807617, 73.985054016113, 180},
	{1110.1916503906, -295.24975585938, 73.9921875, 180},
	{1117.3626708984, -306.23336791992, 73.9921875, 0},
	{1112.3884277344, -305.99154663086, 73.9921875, 0},
	{1107.0441894531, -322.78482055664, 73.9921875, 0},
	{1106.9635009766, -314.94802856445, 73.9921875, 0},
	{1098.4272460938, -306.24154663086, 73.9921875, 90},
	{1083.7691650391, -300.35195922852, 73.9921875, 90},
	{1088.4093017578, -311.53787231445, 73.9921875, 90},
	{1088.2900390625, -316.71258544922, 73.9921875, 90},
	{1088.55859375, -321.99591064453, 73.9921875, 90},
	{1089.2143554688, -328.25088500977, 73.9921875, 90},
	{1077.8094482422, -327.84564208984, 73.9921875, 90},
	{1062.8739013672, -298.26538085938, 73.985054016113, 180},
	{1071.9724121094, -297.71157836914, 73.985054016113, 180},
	{1079.0521240234, -296.44409179688, 73.9921875, 180},
	{1083.5155029297, -296.56521606445, 73.9921875, 180},
	{1071.9307861328, -307.55712890625, 73.9921875, 180},
	{1066.6098632813, -307.52844238281, 73.9921875, 180},
	{1061.1262207031, -307.37130737305, 73.9921875, 180},
	{1062.5262451172, -316.86965942383, 73.9921875, 180},
	{1068.6959228516, -316.76800537109, 73.9921875, 180},
	{1073.3193359375, -316.37197875977, 73.9921875, 180},
	
};

addEvent("startLumberjack", true)
addEventHandler("startLumberjack", root, function(player)
	local x, y, z, r = unpack(carPositions[math.random(1, #carPositions)])
    local veh = exports.cr_temporaryvehicle:createJobVehicle(player, 422, x, y, z, 0, 0, r, 1, 1, true)
	if(veh) then
		veh:setData("job >> data", {["piles"] = {}, ["job"] = 2,})
		setElementJobData(player, "jobVehicle", veh)
		triggerClientEvent(root, "ghostMode", player, veh, "on") 
		setTimer(function() 
			triggerClientEvent(root, "ghostMode", player, veh, "off") 
		end, 10000, 1)
	end
    player:setData("job >> data", {["started"] = true, ["trunkInHand"] = false,})
    player:outputChat(msgs["info"].." Elkezdtél dolgozni.", 255, 255, 255, true)
end) 

addEvent("destroyObjects", true)
addEventHandler("destroyObjects", root, function(player, objects)
	if(objects) then
		if(player:getData("char >> job") == 2) then
			for i, v in pairs(objects) do
				v:destroy()
			end
		end
	end
end)