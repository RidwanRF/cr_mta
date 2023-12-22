local parkPositions = {
	{-1982.5137939453, 883.01849365234, 45.203125, 90},
	{-1982.5137939453, 883.01849365234, 45.203125, 90},
	{-1982.5137939453, 883.01849365234, 45.203125, 90},
};

addEvent("startedWastetrans", true)
addEventHandler("startedWastetrans", root, function(player) 
	player:setData("job >> data", {["started"] = true})
	local x, y, z, r = unpack(parkPositions[math.random(1, #parkPositions)])
	local veh = exports.cr_temporaryvehicle:createJobVehicle(player, 422, x, y, z, 0, 0, r, 1, 1, true)
	if(veh) then
		veh:setData("job >> data", {["job"] = 4})
		setElementJobData(player, "jobVehicle", veh)
		triggerClientEvent(root, "ghostMode", player, veh, "on") 
		setTimer(function() 
			triggerClientEvent(root, "ghostMode", player, veh, "off") 
		end, 10000, 1)
	end
end)