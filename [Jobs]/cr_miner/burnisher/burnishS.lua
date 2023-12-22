addEvent("pickUpBagFromVehicle", true)
addEventHandler("pickUpBagFromVehicle", root, function(player, veh) 
	local bags = getElementJobData(veh, "refinedRocks") or {}
	if(#bags > 0) then
		triggerEvent("carry->anim", player, player)
		player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
		if(isElement(bags[#bags])) then
			setElementJobData(player, "bagInHand", bags[#bags])
			bags[#bags]:detach()
			exports.cr_bone_attach:attachElementToBone(bags[#bags], player, 12, 0.25, 0.0625, 0, 90, -20, 0)
			table.remove(bags, #bags)
			setElementJobData(veh, "refinedRocks", bags)
		else
			local index = #bags - 1
			if(isElement(bags[index])) then
				setElementJobData(player, "bagInHand", bags[index])
				bags[index]:detach()
				exports.cr_bone_attach:attachElementToBone(bags[#bags], player, 12, 0.25, 0.0625, 0, 90, -20, 0)
				table.remove(bags, #bags)
				table.remove(bags, index)
				setElementJobData(veh, "refinedRocks", bags)
			end
		end
	end
end)

addEvent("pickUpBag", true)
addEventHandler("pickUpBag", getRootElement(), function(player, bagData) 
	local bag = exports.cr_objects:createObj(2060, 0, 0, 0, 0, 0, 0)
	bag:setData("job >> data", bagData)
	exports.cr_bone_attach:attachElementToBone(bag, player, 12, 0.25, 0.0625, 0, 90, -20, 0)
	triggerEvent("carry->anim", player, player)
	player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
	setElementJobData(player, "bagInHand", bag)
end)

addEvent("addBagToVehicle", true)
addEventHandler("addBagToVehicle", root, function(player, veh)
	local bags = getElementJobData(player, "refinedRocks") or {}
	local bagDatas = getElementJobData(player, "refinedRockData") or {}
	local bag = getElementJobData(player, "bagInHand")
	setElementJobData(bag, "onVehicleBack", true)
	if(#bags < 6) then
		local vehBags = getElementJobData(veh, "refinedRocks") or {}
		table.insert(vehBags, getElementJobData(player, "bagInHand"))
		exports.cr_bone_attach:detachElementFromBone(bag)
		bag:attach(veh, unpack(bagPositionsOnVehicle[#vehBags]))
		setElementJobData(veh, "refinedRocks", vehBags)
		bag:setCollisionsEnabled(false)
		local sprint, jump = isControlEnabled(player, "sprint"), isControlEnabled(player, "jump")
		toggleControl(player, "sprint", sprint)
		toggleControl(player, "jump", jump)
		if(#bagDatas > 0) then
			table.remove(bags, #bags)
			table.remove(bagDatas, #bagDatas)
			setElementJobData(player, "refinedRocks", bags)
			setElementJobData(player, "refinedRockData", bagDatas)
		end
		setElementJobData(player, "bagInHand", false)
	end
end)

addEvent("destroyObjects", true)
function destroyObjects(table)
	Async:foreach(table, function(val) 
		val:destroy()
	end)
end
addEventHandler("destroyObjects", root, destroyObjects)

addEvent("destroyVehicleRocks", true)
addEventHandler("destroyVehicleRocks", getRootElement(), function(player)
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player)
	if(veh) then
		if(getElementJobData(veh, "rocks")) then
			destroyObjects(getElementJobData(veh, "rocks"))
		end
		if(getElementJobData(veh, "refinedRocks")) then
			destroyObjects(getElementJobData(veh, "refinedRocks"))
		end
	end
end)

addEvent("removeBagFromVehicle", true)
addEventHandler("removeBagFromVehicle", root, function(player, index)
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 422)
	if(veh) then
		local vehbags = getElementJobData(veh, "refinedRocks")
		local bag = vehbags[index]
		table.remove(vehbags, index)
		bag:destroy()
		player:outputChat(tostring(vehbags))
		setElementJobData(veh, "refinedRocks", vehbags)
	end
end)

addEvent("addBagToGlobal", true)
addEventHandler("addBagToGlobal", root, function(player) 
	-- dbExec...
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 422)
	if(veh) then
		local bags = getElementJobData(veh, "refinedRocks") or {}
		if(#bags == 0) then
			setElementJobData(player, "deposited", false)
			setElementJobData(veh, "deposited", false)
			if(getElementJobData(player, "bagNumber") == 6 and veh:getHealth() >= 850) then
				triggerClientEvent(player, "giveClientSalary", player, true)
			else
				triggerClientEvent(player, "giveClientSalary", player, false)
			end
			setElementJobData(player, "bagNumber", false)
		else
			player:outputChat(msgs["info"].."Leadtál egy zsákot. Maradt még "..#bags.."db a munkakocsin.", 255, 255, 255, true)
		end
	end
	local sprintState = isControlEnabled(player, "sprint")
    local jumpState = isControlEnabled(player, "jump")
    toggleControl(player, "sprint", sprintState)
    toggleControl(player, "jump", jumpState)
	destroyBagInHand(player)
end)

addEvent("pickUpRock", true)
addEventHandler("pickUpRock", root, function(player, veh)
	local rocks = getElementJobData(veh, "rocks")
	setElementJobData(player, "rockInHand", rocks[#rocks])
	exports.cr_bone_attach:attachElementToBone(rocks[#rocks], player, 12, 0.25, 0.25, 0, 0, 0, 0)
	table.remove(rocks, #rocks)
	setElementJobData(veh, "rocks", rocks)
	triggerEvent("carry->anim", player, player)
	player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
	player:outputChat(msgs["info"].." Levettél egy követ a platóról. Maradt még: "..#rocks.."db a platón.", 255, 255, 255, true)	
	if(#rocks == 0) then
		exports['cr_infobox']:addBox(player, "info", "A zsák felvételéhez használd az 'E' gombot a zsák előtt!", 255, 255, 255, true)
	end
end)

addEvent("showRefineryMinigame", true)
addEventHandler("showRefineryMinigame", root, function(player) 
	-- local rockType = getElementJobData(getElementJobData(player, "rockInHand"), "type")
	player:setData("forceAnimation", {"", ""})
	local sprintState = isControlEnabled(player, "sprint")
    local jumpState = isControlEnabled(player, "jump")
    toggleControl(player, "sprint", sprintState)
    toggleControl(player, "jump", jumpState)
	-- getElementJobData(player, "rockInHand"):destroy()
	-- setElementJobData(player, "rockInHand", false)
	-- onRefineryMinigameEnd(player, rockType, 0)
end)

-- function onRefineryMinigameEnd(player, rockType, rockStatus)
	-- player:outputChat(msgs["success"].." Sikeresen elvégezted a minigamet.", 255, 255, 255, true)
	-- player:triggerEvent("createBagObject", root, rockType, rockStatus)
-- end

addEvent("onRefineryMinigameEnd", true)
addEventHandler("onRefineryMinigameEnd", getRootElement(), function(player, rockType, rockStatus, slot)
	player:outputChat(msgs["success"].." Sikeresen elvégezted a minigamet.", 255, 255, 255, true)
	triggerClientEvent(player, "createBagObject", player, rockType, rockStatus, slot)
	getElementJobData(player, "rockInHand"):destroy()
	setElementJobData(player, "rockInHand", false)
end)

local spamTimers = {}
addEvent("giveSalary", true)
addEventHandler("giveSalary", root, function(player, salary) 
	if(not isTimer(spamTimers[player:getData("acc >> id")])) then
		local money = player:getData("char >> money")
		player:setData("char >> money", money+(math.floor(salary*exports.cr_jobpanel:getPaymentMultiplier())))
		player:outputChat(msgs["info"].."Végeztél munkáddal. Fizetésed: #008000$"..math.floor(salary)*exports.cr_jobpanel:getPaymentMultiplier(), 255, 255, 255, true)
		spamTimers[player:getData("acc >> id")] = setTimer(function() end, 15000, 1)
	end
end)

addEvent("giveMinerItem", true)
addEventHandler("giveMinerItem", root, function(player, item)
	exports.cr_inventory:giveItem(player, tonumber(item), 0, 1, 100, 0, 0)
end)