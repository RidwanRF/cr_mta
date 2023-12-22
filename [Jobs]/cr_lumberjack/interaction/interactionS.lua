local respawnTreeTimers = {};
local treeDataTimers = {};
local treePileDataTimers = {};

addEventHandler("onResourceStart", resourceRoot, function()
	local depositMarker = createMarker(-2014.7565917969, -2397.7563476563, 29.7, "cylinder", 2, 255, 215, 0, 100)
	depositMarker:setData("job >> data", {["woodDeposit"] = true, ["job"] = 2,})
	
	local depositColShape = createColSphere(-2014.7565917969, -2397.7563476563, 29.7, 15)
	depositColShape:setData("job >> data", {["woodDepositCol"] = true, ["job"] = 2,})
end)

addEvent("fallTree", true)
addEventHandler("fallTree", root, function(player, tree)
	Async:foreach(getElementsByType("player"), function(val) 
		local pos = val:getPosition()
		local pos2 = tree:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) <= 15) then
			triggerClientEvent(val, "fallingTreeSound", resourceRoot, pos2.x, pos2.y, pos2.z)
		end
	end)
	treeDataTimers[getElementJobData(tree, "treeID")] = setTimer(function() 
		setElementJobData(tree, "cutBy", false)
	end, 300000, 1)
end)

addEvent("setTreeRespawn", true)
addEventHandler("setTreeRespawn", root, function(player, tree)
	tree:setAlpha(0)
	tree:setCollisionsEnabled(false)
	tree:setRotation(0, 0, 0)
	tree:setData("LumberJack->Fallen", false)
	setElementJobData(tree, "cutBy", false)
    respawnTreeTimers[getElementJobData(tree, "treeID")] = setTimer(function(t) 
		local alpha = t:getAlpha()
		local newAlpha = alpha+63.75
		t:setAlpha(newAlpha)
		if(t:getAlpha() >= 250) then
			t:setAlpha(255)
			t:setCollisionsEnabled(true)
			local pos = t:getPosition()
			t:setPosition(pos.x, pos.y, tonumber(getElementJobData(trees[36], "z")))
			Async:foreach(getElementsByType("object"), function(val)
				if(getElementJobData(val, "treePile")) then
					if(tonumber(getElementJobData(val, "pileTreeID")) == tonumber(getElementJobData(t, "treeID"))) then
						val:destroy()
					end
				end
			end)
		end
	end, 300000, 4, tree)
end)

addEvent("createPile", true)
addEventHandler("createPile", root, function(player, data) 
	local x, y, z, id = unpack(data)
	local pile = createObject(1463, x, y, z, 0, 0, 0)
	pile:setData("job >> data", {["job"] = 2, ["pileTreeID"] = tonumber(id), ["treePile"] = true, ["owner"] = player:getData("acc >> id"), ["leftPiles"] = 3})
	treePileDataTimers[tonumber(id)] = setTimer(function(p) 
		if(isElement(p)) then
			setElementJobData(p, "owner", false) 
		end
	end, 300000, 1, pile)
end)
 
addEventHandler("onElementDataChange", root, function(dataName, oldValue)
    if(dataName == "LumberJack->TreeRotation") then
        local rot = source:getData("LumberJack->TreeRotation")
        local x, y, z = unpack(rot)
        source:setRotation(x, y, z)
    elseif(dataName == "LumberJack->Fallen") then
        local pos = source:getPosition()
        source:setPosition(pos.x, pos.y, pos.z+0.7)
    end
end)

addEvent("pickUpPile", true)
addEventHandler("pickUpPile", root, function(player, pile, left) 
	local pileToHand = exports.cr_objects:createObj(1463, 0, 0, 0)
	pileToHand:setCollisionsEnabled(false)
	pileToHand:setScale(0.35)
	pileToHand:setData("job >> data", {["job"] = 2, ["pileInHand"] = true, ["owner"] = player:getData("acc >> id")})
	
	exports.cr_bone_attach:attachElementToBone(pileToHand, player, 12, 0.25, 0.10, 0, 270, 20, 0)
	
	setElementJobData(player, "pileInHand", pileToHand)
	
	triggerEvent("carry->anim", player, player)
	player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
	
	if(left == 0) then
		pile:destroy()
	end
end)

addEvent("loadPileToVehicle", true)
addEventHandler("loadPileToVehicle", root, function(player, v) 
	local pile = getElementJobData(player, "pileInHand")
	exports.cr_bone_attach:detachElementFromBone(pile)
	local pilesOnVehicle = getElementJobData(v, "piles") or {}
	pile:setCollisionsEnabled(false)
	pile:attach(v, unpack(pilePositions[#pilesOnVehicle+1]))
	table.insert(pilesOnVehicle, pile)
	setElementJobData(v, "piles", pilesOnVehicle)
	setElementJobData(player, "pileInHand", false)
	player:setData("forceAnimation", {"", ""})
	player:outputChat(msgs["info"].."Felpakoltál egy farakást a munkakocsidra. ("..#pilesOnVehicle.."/6)", 255, 255, 255, true)
end)

addEvent("pilePickupFromVehicle", true)
addEventHandler("pilePickupFromVehicle", root, function(player, veh)
	if(isElement(veh)) then
		local piles = getElementJobData(veh, "piles") or {}
		if(isElement(piles[#piles])) then
			setElementJobData(player, "pileInHand", piles[#piles])
			piles[#piles]:detach()
			exports.cr_bone_attach:attachElementToBone(piles[#piles], player, 12, 0.25, 0.10, 0, 270, 20, 0)
			table.remove(piles, #piles)
			setElementJobData(veh, "piles", piles)
			triggerEvent("carry->anim", player, player)
			player:setData("forceAnimation", {"MinerJob->Carry", "MinerJob->Carry"})
			player:outputChat(msgs["info"].."Levettél egy farakást a munkakocsidról. Maradt még: "..#piles.."db a platón.", 255, 255, 255, true)
		end
	end
end)

local spamTimers = {};
addEvent("addPileToGlobal", true)
addEventHandler("addPileToGlobal", root, function(player) 
	-- if not exports['cr_network']:getNetworkStatus() then return end
	if(not isTimer(spamTimers[player:getData("acc > id")])) then
		local pile = getElementJobData(player, "pileInHand")
		if(isElement(pile)) then
			pile:destroy()
			local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 422)
			local HPbonus = 200*((player.health/100)-0.5)
			local HPvehBonus = 200*((veh.health/1000)-0.5)
			HPbonus = HPbonus > 200 and 200 or HPbonus < -50 and -50 or HPbonus
			HPvehBonus = HPvehBonus > 200 and 200 or HPvehBonus < -50 and -50 or HPvehBonus
			local otherPiles = getElementJobData(veh, "piles") or {}
			local depositedPiles = getElementJobData(player, "depositedPiles") or 0
			depositedPiles = depositedPiles+1
			setElementJobData(player, "depositedPiles", depositedPiles)
			player:setData("forceAnimation", {"", ""})
			if(#otherPiles == 0) then
				local salary = math.floor(salaryPerPile*depositedPiles*exports.cr_jobpanel:getPaymentMultiplier()+HPbonus+HPvehBonus)
				local money = player:getData("char >> money")
				player:setData("char >> money", money+salary)
				player:outputChat(msgs["info"].."Elvégezted munkádat. Fizetésed: #008000$"..salary, 255, 255, 255, true)
				if(depositedPiles == 6) then
					local random = math.random(1, 100)
					if(random >= 25 and random <= 75) then
						exports.cr_inventory:giveItem(player, 118, 0, 1, 100, 0, 0)
						triggerClientEvent(player, "showBonusItem", resourceRoot)
					end
				end
				setElementJobData(player, "depositedPiles", 0)
			end
			-- sql
		end
		spamTimers[player:getData("acc > id")] = setTimer(function() end, 5000, 1)
	end
end)