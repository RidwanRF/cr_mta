local bankNPCS = {};
local doors = {};
local drillMarkers = {};
local drills = {};
local ropeMarkers = {};
local ropeResetTimers = {};
local alarmResetTimer = nil;

addEventHandler("onResourceStart", resourceRoot, function() 
	local x, y, z = unpack(bankCenter)
	local center = createColSphere(x, y, z, bankRadius)
	center:setData("bank >> radius", true)
	center:setData("bank >> underRobbing", false)
	center:setData("bank >> alarm", false)
	
	x, y, z = unpack(startPoint)
	local start = createColSphere(x, y, z, startRadius)
	start:setData("bank >> robStart", true)
	
	x, y, z = unpack(startNPCPoint)
	local r = startNPCPoint[4] or 0
	local npc = createPed(startNPCSkin, x, y, z, r)
	npc:setData("bank >> startNPC", true)
	npc:setData("ped.name", "Stephen")
	npc:setData("ped.type", "Banki alkalmazott")
	npc:setData("char >> noDamage", true)
	bankNPCS["startNPC"] = npc
	
	for i, v in pairs(doorPositions) do
		local x, y, z, rx, ry, rz = unpack(v)
		doors[i] = createObject(doorID, x, y, z, rx, ry, rz)
		doors[i]:setData("bank >> door", true)
		doors[i]:setData("bank >> doorRot", rz)
	end
	
	for i, v in pairs(stealthStartMarkers) do
		local x, y, z = unpack(v)
		local m = createMarker(x, y, z, "cylinder", 0.8, 0, 0, 0, 0)
		ropeMarkers[i] = m
		m:setData("bank >> stealthStart", true)
		m:setData("bank >> stealthStartID", i)
		m:setData("bank >> occupiedRope", false)
		
		x, y, z = unpack(stealthRopePositions[i]["inside"])
		m = createMarker(x, y, z, "cylinder", 0.8, 0, 0, 0, 0)
		m:setData("bank >> escapeMarker", true)
		m:setData("bank >> escapeID", i)
	end
	
	for i, v in pairs(drillPoints) do
		local x, y, z, s, rz = unpack(v)
		drillMarkers[i] = createMarker(x, y, z, "cylinder", s, 0, 0, 0, 0)
		drillMarkers[i]:setData("bank >> drillPoint", i)
		drillMarkers[i]:setData("bank >> drillZ", rz)
	end
	
	x, y, z = unpack(securityPoint)
	local securityRoom = createMarker(x, y, z, "cylinder", 2, 0, 0, 0, 0)
	securityRoom:setData("bank >> securityRoom", true)
end)

function sendMessageToMultiple(tbl, msg)
	for i, v in pairs(tbl) do
		v:outputChat(msg, 255, 255, 255, true)
	end
end

addEvent("NPCOpenDoor", true)
addEventHandler("NPCOpenDoor", resourceRoot, function(n)
	local player = client
	triggerClientEvent(root, "NPCRunToOpenDoor", resourceRoot, bankNPCS["startNPC"])
	for index, value in pairs(guardPositions) do
		if(not bankNPCS["guards"]) then
			bankNPCS["guards"] = {}
		end
		local n, x, y, z, r, s, w, a, ar = unpack(value)
		bankNPCS["guards"][index] = {createPed(s, x, y, z, r), w}
		bankNPCS["guards"][index][1]:setData("bank >> guardID", index)
		bankNPCS["guards"][index][1]:setData("bank >> guardNPC", true)
		bankNPCS["guards"][index][1]:setData("bank >> guardShootingTo", false)
		bankNPCS["guards"][index][1]:setArmor(ar)
		bankNPCS["guards"][index][1]:giveWeapon(w, a, true)
		bankNPCS["guards"][index][1]:setData("ped.name", n)
		bankNPCS["guards"][index][1]:setData("ped.type", "Biztonsági őr")
	end
	sendMessageToMultiple(n, player:getData("char >> name").." ordítja: "..startConversation[1])
	setTimer(function(nb) 
		sendMessageToMultiple(nb, "Banki alkalmazott mondja: "..startConversation[2])
		setTimer(function(n) 
			sendMessageToMultiple(n, player:getData("char >> name").." mondja: "..startConversation[3])
			setTimer(function(nb) 
				sendMessageToMultiple(nb, "Banki alkalmazott mondja: "..startConversation[4])
			end, 3000, 1, n)
		end, 3000, 1, nb)
	end, 3000, 1, n)
end)

addEvent("syncNPC", true)
addEventHandler("syncNPC", resourceRoot, function(npc, pos)
	local player = client
	npc:setPosition(pos.x, pos.y, pos.z)
end)

addEvent("openStartDoors", true)
addEventHandler("openStartDoors", resourceRoot, function() 
	-- outputDebugString(doorPositions[4]["open"][2])
	triggerClientEvent(root, "toggleDoors", resourceRoot, {{doors[1], doorPositions[1]["open"][1], doorPositions[1]["open"][2]}, {doors[2], doorPositions[2]["open"][1], doorPositions[2]["open"][2]}, {doors[3], doorPositions[3]["open"][1], doorPositions[3]["open"][2]}, {doors[4], doorPositions[4]["open"][1], doorPositions[4]["open"][2]}})
end)

addEvent("setNPCSafeAnim", true)
addEventHandler("setNPCSafeAnim", resourceRoot, function() 
	local player = client
	setPedAnimation(bankNPCS["startNPC"], "ped", "handsup", 9000, false, false, false, true)
end)

addEventHandler("onElementDataChange", resourceRoot, function(dName, oValue)
	if(source and source:getData("bank >> door") and not oValue == false or not oValue == nil) then
		if(dName == "bank >> doorRot") then
			source:setRotation(0, 0, source:getData(dName))
		end
	elseif(source and dName == "bank >> alarm") then
		if(source:getData(dName)) then
			local bank = source
			alarmResetTimer = setTimer(function(b) 
				b:setData("bank >> alarm", false)
			end, 3600*2*1000, 1, bank)
		end
	end
end)

addEvent("createDrill", true)
addEventHandler("createDrill", resourceRoot, function(index) 
	local player = client
	index = tonumber(index) 
	if(not drills[index]) then
		for i, v in pairs(drillMarkers) do
			if(i == index) then
				local pos = v:getPosition()
				x2, y2, z2 = getPositionFront({pos.x, pos.y, pos.z+1}, {0, 0, drillMarkers[index]:getData("bank >> drillZ")}, 1.25)
				player:outputChat("Fúró létrehozva!")
				drills[index] = createObject(drillerID, x2, y2, z2, 0, 0, drillMarkers[index]:getData("bank >> drillZ"))
				triggerClientEvent(root, "startDrillerSound", resourceRoot, x2, y2, z2)
				drills[index]["timer"] = setTimer(function(i) 
					drills[i]:destroy()
					drills[i] = nil
					triggerClientEvent(root, "toggleDoors", resourceRoot, {{doors[drillPoints[i]["doors"][1]], doorPositions[drillPoints[i]["doors"][1]]["open"][1], doorPositions[drillPoints[i]["doors"][1]]["open"][2]}, {doors[drillPoints[i]["doors"][2]], doorPositions[drillPoints[i]["doors"][2]]["open"][1], doorPositions[drillPoints[i]["doors"][2]]["open"][2]}})
					triggerClientEvent(root, "stopDrillerSound", resourceRoot)
				end, 10000, 1, index)
				break
			end
		end
	else
		player:outputChat("Itt már van egy aktív fúró!")
	end
end)

addEvent("getGuardNPCS", true)
addEventHandler("getGuardNPCS", resourceRoot, function()
	local player = client
	triggerClientEvent(player, "receiveGuardNPCS", resourceRoot, bankNPCS["guards"])
end)

addEvent("setupGuardShottingToPlayer", true)
addEventHandler("setupGuardShottingToPlayer", resourceRoot, function(id)
	local player = client
	-- player:outputChat("2 oké")
	local guard = bankNPCS["guards"][id][1]
	if(not guard:getData("bank >> guardShootingTo")) then
		triggerClientEvent(root, "guardStartShootingToPlayer", resourceRoot, guard, player)
		guard:setData("bank >> guardShootingTo", player:getData("acc >> id"))
	end
end)

addEvent("headShotPed", true)
addEventHandler("headShotPed", resourceRoot, function(ped) 
	local player = client
	ped:setHealth(0)
	setPedHeadless(ped, true)
	killPed(ped, player)
end)

addEvent("removePedArmor", true)
addEventHandler("removePedArmor", resourceRoot, function(ped)
	local player = client
	ped:setArmor(0)
end)

addEvent("showRopeToEveryoneS", true)
addEventHandler("showRopeToEveryoneS", resourceRoot, function(id) 
	local player = client
	triggerClientEvent(root, "showRopeToEveryone", resourceRoot, id)
end)

addEvent("startedStealthRobbing", true)
addEventHandler("startedStealthRobbing", resourceRoot, function(markerID) 
	-- ropeResetTimers[markerID] = setTimer(function(id) 
		-- ropeMarkers[id]:setData("bank >> occupiedRope", false)
	-- end, 60000, 1, markerID)
end)

addEvent("addRopeAnimToPlayer", true)
addEventHandler("addRopeAnimToPlayer", resourceRoot, function() 
	local player = client
	player:setAnimation("ped", "abseil", -1, false, false, false)
	setTimer(function() 
		player:setAnimation(nil, nil)
	end, 5000, 1)
end)

addEvent("dodgeWindow", true)
addEventHandler("dodgeWindow", resourceRoot, function() 
	local player = client
	player:setAnimation("ped", "climb_jump_b", -1, false, false, false)
	setTimer(function() 
		player:setAnimation(nil, nil)
	end, 2000, 1)
end)

addEvent("spawnStealthGuards", true)
addEventHandler("spawnStealthGuards", resourceRoot, function() 
	for index, value in pairs(stealthGuardPositions) do
		if(not bankNPCS["guards"]) then
			bankNPCS["guards"] = {}
		end
		local n, x, y, z, r, s, w, a, ar = unpack(value)
		bankNPCS["guards"][index] = {createPed(s, x, y, z, r), w}
		bankNPCS["guards"][index][1]:setData("bank >> guardID", index)
		bankNPCS["guards"][index][1]:setData("bank >> guardNPC", true)
		bankNPCS["guards"][index][1]:setData("bank >> guardShootingTo", false)
		bankNPCS["guards"][index][1]:setArmor(ar)
		bankNPCS["guards"][index][1]:giveWeapon(w, a, true)
		bankNPCS["guards"][index][1]:setData("ped.name", n)
		bankNPCS["guards"][index][1]:setData("ped.type", "Biztonsági őr")
	end
end)