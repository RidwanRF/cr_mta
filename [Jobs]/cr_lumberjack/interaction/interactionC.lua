local treeData = false;

function renderTreeAction()
	if(treeData) then
		local pos = localPlayer:getPosition()
		local opos = treeData[1]:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, opos.x, opos.y, opos.z) >= 6) then
			if(isTimer(activityTimer)) then
				killTimer(activityTimer)
			end
			treeData = false
			removeEventHandler("onClientRender", root, renderTreeAction)
			exports.cr_progressbar:deleteBar("lumberjack >> treeHP")
		end
	end
end

local startTime = 0
local endTime = 0
local fallenTree = false
local activityTimer = nil
local cooldown = nil
addEventHandler("onClientObjectDamage", root, function(loss, attacker)
	if(attacker == localPlayer) then
		if(not source:getData("LumberJack->Fallen")) then
			if(localPlayer:getData("char >> job") == 2) then
				if(getElementJobData(localPlayer, "started")) then
					if(not getElementJobData(localPlayer, "treeInHand")) then
						if(getElementJobData(source, "treeObjective") and not isTimer(cooldown)) then
							local weapon = localPlayer:getWeapon()
							if(weapon == 12) then
								cooldown = setTimer(function() end, 500, 1)
								local state
								if(not treeData) then
									state = 0
									addEventHandler("onClientRender", root, renderTreeAction, true, "low-5")
									exports.cr_progressbar:createBar("lumberjack >> treeHP", tocolor(150, 0, 0, 255), 5, 100)
								else
									if(getElementJobData(treeData[1], "treeID") == getElementJobData(source, "treeID")) then
										state = treeData[2]
									else
										treeData = false
										state = 0 
										exports.cr_progressbar:deleteBar("lumberjack >> treeHP")
										exports.cr_progressbar:createBar("lumberjack >> treeHP", tocolor(150, 0, 0, 255), 5, 100)
									end
								end
								if(isTimer(activityTimer)) then
									killTimer(activityTimer)
								end
								if(tutorialState == 1) then
									nextTutorial()
								end
								state = state+treeStateValue[getElementJobData(source, "treeType")]
								exports.cr_progressbar:updateBar("lumberjack >> treeHP", state)
								if(state >= 100) then
									state = 100
									exports.cr_progressbar:updateBar("lumberjack >> treeHP", state)
								end
								treeData = {source, state}
								if(state >= 100) then
									local ch = playSound("endChopping.mp3")
									setSoundVolume(ch, 0.8)
									startTime = getTickCount()
									endTime = startTime + 2500
									addEventHandler("onClientRender", root, fallTree, true, "low-5")
									setElementJobData(source, "cutBy", localPlayer:getData("acc >> id"))
									triggerServerEvent("fallTree", localPlayer, localPlayer, source)
									fallenTree = source
									treeData = false
									if(tutorialState == 2) then
										nextTutorial()
									end
								else
									local ch = playSound("chopping.mp3")
									setSoundVolume(ch, 0.8)
								end
								activityTimer = setTimer(function() 
									treeData = false
									removeEventHandler("onClientRender", root, renderTreeAction)
									exports.cr_progressbar:deleteBar("lumberjack >> treeHP")
								end, 15000, 1)
								
								localPlayer:setFrozen(true)
								setTimer(function() 
									localPlayer:setFrozen(false)
								end, 1000, 1)
							end
						end
					end
				end
			end
		end
	end
end)

function fallTree()
    if(isElement(fallenTree)) then
        local now = getTickCount() 
        local elapsedTime = now - startTime
        local duration = endTime - startTime
        local progress = elapsedTime / duration
        fallenTree:setData("LumberJack->Fallen", true)
        if(progress > 1.1) then
            removeEventHandler("onClientRender", root, fallTree)
            fallenTree = false
			exports.cr_infobox:addBox("info", "Kivágtál egy fát, a felaprításhoz kattints a fára!")
            return
        end
        local rot = interpolateBetween(0, 0, 0, 90, 0, 0, progress, "Linear") 
        local rotation = {0, rot, 0}
        fallenTree:setData("LumberJack->TreeRotation", rotation)
    end
end

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element) 
	if(button == "left" and state == "down") then
		if(isElement(element) and getElementJobData(element, "treeObjective") and element:getData("LumberJack->Fallen")) then
			if(getElementJobData(element, "cutBy") == localPlayer:getData("acc >> id") or getElementJobData(element, "cutBy") == false) then
				startCuttingMinigame(element)
				setElementJobData(element, "cutBy", localPlayer:getData("acc >> id"))
			else
				outputChatBox(msgs["error"].." Ez a fa nem hozzád tartozik.", 255, 255, 255, true)
			end
		end
	end
end)

local minigameTree = false
local mData = {};
local sawPositions = {};
function startCuttingMinigame(t)
	minigameTree = t
	mData["x"] = sx/2
	mData["y"] = sy-400
	sawPositions = {
		["arrow_r"] = {
			["start"] = mData["x"]-150,
			["end"] = mData["x"]-50,
		},
		["arrow_l"] = {
			["start"] = mData["x"]-50,
			["end"] = mData["x"]-150,
		}
	}
	mData["sawX"] = mData["x"]-150
	mData["sawY"] = mData["y"]-135
	mData["counter"] = 0
	mData["key"] = "arrow_r"
	mData["move"] = false
	addEventHandler("onClientKey", root, cuttingMinigameKeyHandler)
	addEventHandler("onClientRender", root, renderCuttingMinigame, true, "low-5")
	toggleAllControls(false)
	_triggerServerEvent("applyAnimation", getRootElement(), localPlayer, "bomber", "bom_plant_crouch_in", -1, true, false, false, false, 250)
end

function stopCuttingMinigame()
	mData = {}
	removeEventHandler("onClientKey", root, cuttingMinigameKeyHandler)
	removeEventHandler("onClientRender", root, renderCuttingMinigame)
	toggleAllControls(true)
	_triggerServerEvent("removeAnimation", getRootElement(), localPlayer)
end

function renderCuttingMinigame()
	local x, y = mData["x"], mData["y"]
	dxDrawImage(x-50, y, 100, 100, "images/wood.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	if(mData["key"] == "arrow_l") then
		dxDrawImage(x-250, y+12.5, 75, 75, "images/arrow.png", 90, 0, 0, tocolor(255, 255, 255, 255), true)
	else
		dxDrawImage(x-225, y+25, 50, 50, "images/arrow.png", 90, 0, 0, tocolor(255, 255, 255, 255), true)
	end
	
	if(mData["key"] == "arrow_r") then
		dxDrawImage(x+175, y+12.5, 75, 75, "images/arrow.png", 270, 0, 0, tocolor(255, 255, 255, 255), true)
	else
		dxDrawImage(x+175, y+25, 50, 50, "images/arrow.png", 270, 0, 0, tocolor(255, 255, 255, 255), true)
	end
	
	if(mData["move"]) then
		local now = getTickCount()
        local elapsedTime = now - mData["startTime"]
        local duration = mData["endTime"] - mData["startTime"]
        local progress = elapsedTime / duration
		mData["sawX"] = interpolateBetween(sawPositions[mData["move"]]["start"], 0, 0, sawPositions[mData["move"]]["end"], 0, 0, progress, "Linear")
		if(now == endTime) then
			mData["move"] = false
		end
	end
	
	dxDrawImage(mData["sawX"], mData["sawY"], 200, 200, "images/saw.png", 0, 0, 0, tocolor(255, 255, 255, 255))
end

local counterTable = {
	[5] = true,
	[10] = true,
	[15] = true,
	[20] = true,
	[25] = true,
	[30] = true,
	[35] = true,
	[40] = true,
	[45] = true,
	[50] = true,
	[55] = true,
	[60] = true,
	[65] = true,
	[70] = true,
	[75] = true,
	[80] = true,
	[85] = true,
}

function cuttingMinigameKeyHandler(key, pressed)
	if(not isTimer(mData["cooldown"])) then
		if(key == "arrow_r" and pressed) then
			if(mData["key"] == "arrow_r") then
				mData["cooldown"] = setTimer(function() end, 500, 1)
				local sound = playSound("woodSawing.mp3")
				setSoundVolume(sound, 0.8)
				mData["move"] = mData["key"]
				mData["key"] = "arrow_l"
				mData["startTime"] = getTickCount()
				mData["endTime"] = getTickCount()+500
				mData["counter"] = mData["counter"]+1
				if(counterTable[mData["counter"]]) then
					mData["sawY"] = mData["sawY"]+5
				elseif(mData["counter"] == 90) then
					stopCuttingMinigame()
					outputChatBox(msgs["success"].."Sikeres minigame!", 255, 255, 255, true)
					exports.cr_infobox:addBox("info", "Elvégezted a minigamet a farakás felvételéhez használd az 'E' gombot a rakás mellett!")
					triggerServerEvent("setTreeRespawn", localPlayer, localPlayer, minigameTree)
					local pos = minigameTree:getPosition()
					local id = getElementJobData(minigameTree, "treeID")
					triggerServerEvent("createPile", localPlayer, localPlayer, {pos.x, pos.y, pos.z, id})
					minigameTree = false
					local sound2 = playSound("minigameFinish.mp3")
					setSoundVolume(sound2, 0.8)
					
					-- addEventHandler("onClientKey", root, pilePickupKeyHandler)
				end
			else
				stopCuttingMinigame()
				outputChatBox(msgs["error"].."Sikertelen minigame.", 255, 255, 255, true)
			end
		elseif(key == "arrow_l" and pressed) then
			if(mData["key"] == "arrow_l") then
				mData["cooldown"] = setTimer(function() end, 500, 1)
				local sound = playSound("woodSawing.mp3")
				setSoundVolume(sound, 0.8)
				mData["move"] = mData["key"]
				mData["key"] = "arrow_r"
				mData["startTime"] = getTickCount()
				mData["endTime"] = getTickCount()+500
				mData["counter"] = mData["counter"]+1
				if(counterTable[mData["counter"]]) then
					mData["sawY"] = mData["sawY"]+5
				elseif(mData["counter"] == 90) then
					stopCuttingMinigame()
					outputChatBox(msgs["success"].."Sikeres minigame!", 255, 255, 255, true)
					triggerServerEvent("setTreeRespawn", localPlayer, localPlayer, minigameTree)
					local pos = minigameTree:getPosition()
					local id = getElementJobData(minigameTree, "treeID")
					triggerServerEvent("createPile", localPlayer, localPlayer, {pos.x, pos.y, pos.z, id})
					minigameTree = false
					local sound2 = playSound("minigameFinish.mp3")
					setSoundVolume(sound2, 0.8)
					
					-- addEventHandler("onClientKey", root, pilePickupKeyHandler)
				end
			else
				stopCuttingMinigame()
				outputChatBox(msgs["error"].."Sikertelen minigame.", 255, 255, 255, true)
				if(math.random(0, 6) > 3) then
					localPlayer:setHealth(localPlayer:getHealth()-5)
				end
			end
		end
	end
	if(key == "backspace" and pressed) then
		stopCuttingMinigame()
	end
end

addCommandHandler("cheatmg", function(cmd)
	mData["counter"] = 89
end)

addEvent("fallingTreeSound", true)
addEventHandler("fallingTreeSound", resourceRoot, function(x, y, z)
	playSound3D("fallingTree.mp3", x, y, z)
end)

pickUpTimer = nil
loadTimer = nil
warningTimer = nil
pickUpFromVehicleTimer = nil
putDownTimer = nil
putDownArea = false
vcX, vcY, vcZ = false, false, false
function renderAction()
	if(isTimer(pickUpTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) >= 2) then
			killTimer(pickUpTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("lumberjack >> pilePickup")
			vcX, vcY, vcZ = false, false, false
		end
	elseif(isTimer(loadTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) >= 2) then
			killTimer(loadTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("lumberjack >> pileLoad")
			vcX, vcY, vcZ = false, false, false
		end
	elseif(isTimer(pickUpFromVehicleTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) >= 2) then
			killTimer(pickUpFromVehicleTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("lumberjack >> pilePickupFromVehicle")
			vcX, vcY, vcZ = false, false, false
		end
	elseif(isTimer(putDownTimer)) then
		if(not putDownArea) then
			killTimer(putDownTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("lumberjack >> putDownPile")
		end
	end
end

function renderWarning()
	local x, y, w, h = sx/2-800/2, sy - 100 - 30, 800, 30
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	dxDrawText("Figyelem! Ez a jármű nem a te munkakocsid! Kérlek erősítsd meg, a felpakolást, azzal, hogy újra lenyomva tartod az 'E' gombot!", x, y, x+w, y+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 100))
end

addEventHandler("onClientMarkerHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(getElementJobData(source, "woodDeposit")) then
			if(getElementJobData(localPlayer, "started")) then
				setElementJobData(localPlayer, "deposit", true)
				putDownArea = true
				addEventHandler("onClientKey", root, pilePutDownKeyHandler)
				if(getElementJobData(localPlayer, "pileInHand")) then
					exports.cr_infobox:addBox("info", "A farakás leadásához használd 'E' gombot!")
				end
			end
		end
	end
end)


addEventHandler("onClientMarkerLeave", root, function(p, md)
	if(p == localPlayer and md) then
		if(getElementJobData(source, "woodDeposit")) then
			if(getElementJobData(localPlayer, "started")) then
				setElementJobData(localPlayer, "deposit", false)
				putDownArea = false
				removeEventHandler("onClientKey", root, pilePutDownKeyHandler)
			end
		end
	end
end)

addEventHandler("onClientColShapeHit", root, function(element, md)
	if(md) then
		if(element == localPlayer) then
			if(getElementJobData(source, "woodDepositCol")) then
				if(getElementJobData(localPlayer, "started")) then
					setElementJobData(localPlayer, "enablePickUp", true)
					if(tutorialState == 4) then
						nextTutorial()
					end
					addEventHandler("onClientKey", root, pickupFromVehicleKeyHandler)
					exports.cr_infobox:addBox("info", "A farakás levételéhez használd 'E' gombot a kocsi hátuljánál!")
				end
			end
		end
	end
end)

addEventHandler("onClientColShapeLeave", root, function(element, md) 
	if(md) then
		if(element == localPlayer) then
			if(getElementJobData(source, "woodDepositCol")) then
				if(getElementJobData(localPlayer, "started")) then
					setElementJobData(localPlayer, "enablePickUp", false)
					removeEventHandler("onClientKey", root, pickupFromVehicleKeyHandler)
				end
			end
		end
	end
end)

function renderBonusItem()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
	local font3 = exports['cr_fonts']:getFont("Roboto", 10)
	local x, y, w, h = sx/2-25, sy/2-150, 35, 35
	dxDrawImage(x, y, w, h, "images/fa.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("Kaptál egy bónusz tárgyat: #007a78Fa", x, y, x+w, y+50+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
end

addEvent("showBonusItem", true)
addEventHandler("showBonusItem", resourceRoot, function() 
	addEventHandler("onClientRender", root, renderBonusItem)
	setTimer(function() 
		removeEventHandler("onClientRender", root, renderBonusItem)
	end, 5000, 1)
end)

addEventHandler("onClientVehicleEnter", root, function(p) 
	if(p == localPlayer) then
		if(p:getData("char >> job") == 2) then
			if(getTickCount()-startTime > 60000) then
				if(source:getData("veh >> job") and source:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
					local piles = getElementJobData(source, "piles") or {}
					if(#piles > 0) then
						exports.cr_radar:setGPSDestination(-2010.587890625, -2402.61328125)
					end
					if(#piles == 0) then
						exports.cr_radar:setGPSDestination(1090.3823242188, -316.11206054688)
					end
				end
			end
		end
	end
end)