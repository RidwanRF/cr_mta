local rockRespawnTimers = {};

addEventHandler("onResourceStart", resourceRoot, function() 
	Async:setPriority("high")
	Async:setDebug(true) 
end)

addEvent("updateLeftRocks", true)
addEventHandler("updateLeftRocks", root, function(player, rock)
	local leftRock = rock:getData("job >> leftRock")
	rock:setData("job >> leftRock", leftRock-1)
	player:outputChat(msgs["success"].."Kiütöttél egy követ. Most pakold fel a munkajárműved platójára!", 255, 255, 255, true)
	-- toggleControl(player, "fire", false)
	triggerEvent("carry->anim", player, player)
	player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
	local rockToHand = exports.cr_objects:createObj(1305, 0, 0, 0, 0, 0, 0)
	rockToHand:setData("job >> data", {["job"] = 1, ["attachRock"] = true, ["type"] = getElementJobData(rock, "rockType"), ["account"] = player:getData("acc >> id"),})
	rockToHand:setScale(0.2)
	setElementJobData(player, "rockInHand", rockToHand)
	exports.cr_bone_attach:attachElementToBone(rockToHand, player, 12, 0.25, 0.25, 0, 0, 0, 0)
	
	-- takeAllWeapons(player)
	
	if(leftRock-1 == 0) then
		rock:setAlpha(0)
		rock:setCollisionsEnabled(false)
		rockRespawnTimers[getElementJobData(rock, "rockID")] = setTimer(function(r) 
			r:setAlpha(255)
			r:setCollisionsEnabled(true)
			r:setData("job >> leftRock", math.random(2, 10))
		end, rockRespawnTimes[getElementJobData(rock, "rockType")]*1000, 1, rock)
	end
end)

addEvent("addRockToVehicle", true)
addEventHandler("addRockToVehicle", root, function(player, veh)
	local vehrocks = getElementJobData(veh, "rocks")
    --outputChatBox("Create2")
	if(#vehrocks < 6) then
		player:setData("forceAnimation", {"", ""})
        --outputChatBox("Create1")
        local sprintState = isControlEnabled(player, "sprint")
        local jumpState = isControlEnabled(player, "jump")
        toggleControl(player, "sprint", sprintState)
        toggleControl(player, "jump", jumpState)
		local e = getElementJobData(player, "rockInHand")
		local dt = e:getData("job >> data")
		exports.cr_bone_attach:detachElementFromBone(e)
		e:destroy()
		removeElementJobData(player, "rockInHand")
		
		--outputChatBox("Create3")
		local e = exports.cr_objects:createObj(1305, 0, 0, 0, 0, 0, 0)
		
		e.scale = 0.2
		e.alpha = 255
		--setElementJobData(player, "rockInHand", e) 
		---outputChatBox(inspect(veh))
		--outputChatBox(inspect(stonePositionsOnVehicle[#vehrocks]))
		table.insert(vehrocks, e)
		e:setData("job >> data", dt)
		e:attach(veh, unpack(stonePositionsOnVehicle[#vehrocks]))
		e:setCollisionsEnabled(false)
		setElementJobData(veh, "rocks", vehrocks)
		--getElementJobData(player, "rockInHand"):setCollisionsEnabled(false)
		--setElementJobData(player, "rockInHand", false)
		player:outputChat(msgs["info"].." Felpakoltál egy követ. ("..#vehrocks.."/6)", 255, 255, 255, true)
		if(#vehrocks == 6) then
			if(veh:getData("veh >> owner") == player:getData("acc >> id")) then
				player:outputChat(msgs["info"].."A járműved teljesen meg lett rakodva. (6/6)", 255, 255, 255, true)
			else
				local p = exports.cr_core:findPlayer(veh:getData("veh >> owner"))
				if(p) then
					p:outputChat(msgs["info"].."A járműved teljesen meg lett rakodva. (6/6)", 255, 255, 255, true)
				end
			end
		end
	else
		player:outputChat(msgs["error"].."Ez a jármű tele van! Nem tudsz több követ felpakolni. Használd a /eldob kő parancsot vagy add oda egy másik játékosnak.", 255, 255, 255, true)
	end
end)