local carPositions = {
	{2797.3500976563, -2392.0263671875, 14.631328582764, 90},
	{2797.7919921875, -2399.9431152344, 14.631220817566, 90},
	{2797.7475585938, -2406.4650878906, 14.631232261658, 90},
	{2798.4611816406, -2413.91796875, 14.631057739258, 90},
	{2798.9411621094, -2421.3076171875, 14.630940437317, 90},

};

addEvent("startedCartrans", true)
addEventHandler("startedCartrans", root, function(player)
	player:setData("job >> data", {["started"] = true})
	local x, y, z, r = unpack(carPositions[math.random(1, #carPositions)])
	local veh = exports.cr_temporaryvehicle:createJobVehicle(player, 578, x, y, z, 0, 0, r, 255, 255, true)
	if(veh) then
		veh:setData("job >> data", {["job"] = 3, ["wreckage"] = false, ["wreckageBoxes"] = {}, ["jobVehicle"] = true})
		setElementJobData(player, "jobVehicle", veh)
		triggerClientEvent(root, "ghostMode", player, veh, "on") 
		setTimer(function() 
			triggerClientEvent(root, "ghostMode", player, veh, "off") 
		end, 10000, 1)
	end
	player:outputChat(msgs["info"].."Elkezdtél dolgozni.", 255, 255, 255, true)
	player:outputChat(msgs["info"].."Feladat: állj a tetszőleges daru mellé párhuzamosan a markerbe, majd várd meg míg a daru felpakolja a roncsot! #FF0000(Piros marker)", 255, 255, 255, true)
	player:outputChat(msgs["info"].."Felpakolás után pedig szállítsd el a roncsot a Roncs feldolgozóhoz! #0000FF(Kék blip)", 255, 255, 255, true)
	
end) 