slotPositions = {
	[1] = {
		["start"] = {310.45816040039, -13.438849449158, 2},
		["stop"] = {310.71627807617, -36.235980987549, 5.35},
		["end"] = {310.84439086914, -36.838027954102, 0.8},
	},
	[2] = {
		["start"] = {321.35589599609, -13.499017715454, 2},
		["stop"] = {321.80883789063, -36.223327636719, 5.35},
		["end"] = {321.67456054688, -36.77526473999, 0.8},
	},
	[3] = {
		["start"] = {331.80230712891, -13.602686882019, 2},
		["stop"] = {332.3069152832, -36.45365524292, 5.35},
		["end"] = {332.41842651367, -37.057209014893, 0.8},
	},
	[4] = {
		["start"] = {343.21603393555, -62.471321105957, 2},
		["stop"] = {343.52713012695, -85.876007080078, 5.35},
		["end"] = {343.76800537109, -85.872802734375, 0.8},
	},
	[5] = {
		["start"] = {352.95706176758, -61.446281433105, 2},
		["stop"] = {353.37066650391, -86.103088378906, 5.35},
		["end"] = {353.50790405273, -86.106216430664, 0.8},
	},
	[6] = {
		["start"] = {362.61172485352, -61.999683380127, 2},
		["stop"] = {363.09036254883, -86.009826660156, 5.35},
		["end"] = {362.96234130859, -86.111846923828, 0.8},
	},
	[7] = {
		["start"] = {372.22598266602, -61.228157043457, 2},
		["stop"] = {372.62268066406, -85.653686523438, 5.35},
		["end"] = {372.7887878418, -86.434173583984, 0.8},
	},
	[8] = {
		["start"] = {361.15341186523, -125.8870010376, 2},
		["stop"] = {361.13403320313, -102.19948577881, 4.75},
		["end"] = {360.95315551758, -101.55810546875, 0.8},
	},
	[9] = {
		["start"] = {348.76071166992, -126.14884185791, 2},
		["stop"] = {348.70025634766, -101.79853057861, 4.75},
		["end"] = {348.4563293457, -101.22331237793, 0.8},
	},
};

actionTimer = nil
pickupTimer = nil
putOnTimer = nil
vcX, vcY, vcZ = false, false, false
function renderAction()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	local x,y,w,h = sx/2-600/2, sy - 80 - 30, 600, 30
	if(isTimer(actionTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) > 1) then
			killTimer(actionTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("miner >> felvetel")
		end
	end
	if(isTimer(pickupTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) > 1) then
			killTimer(pickupTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("miner >> felvetel2")
		end
	end
	if(isTimer(putOnTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) > 1) then
			killTimer(putOnTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("miner >> felpakolas")
		end
	end
	if(isTimer(putDownTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) > 1) then
			killTimer(putDownTimer)
			removeEventHandler("onClientRender", root, renderAction)
			exports.cr_progressbar:deleteProgressbar("miner >> lerakas")
		end
	end
end

mData = {}
mHover = {
	["okButton"] = false,
	["cancelButton"] = false,
}

function onMoveCursor(_, _, x, y)
	mData["moved"] = true
end

function renderRefineryMinigame()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
    local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
    local font3 = exports['cr_fonts']:getFont("Roboto", 10)
	local x, y, w, h = sx/2, sy/2, 100, 100
	
	dxDrawImage(x-((w/2)/2), y-((h/2)/2), w/2, h/2, "images/"..mData["type"]..".png", 0, 0, 0, tocolor(255, 255, 255, 255))
	dxDrawImage(x-(w/2), y-(h/2), w, h, "images/ore.png", 0, 0, 0, tocolor(255, 255, 255, 255-(255/100)*mData["health"]))
	dxDrawRectangle(x-150, y-200, 300, 20, tocolor(0, 0, 0, 150))
	dxDrawRectangle(x-150, y-200, (300/100)*math.floor(mData["health"]), 20, tocolor(150, 0, 0, 150))
	dxDrawText("Feldolgozva: "..math.floor(mData["health"]).."%", x-150, y-200, x+150, y-180, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)

	if(isCursorHover(x-(w/2)-100, y-(h/2)-100, w+200, h+200)) then
		local cx, cy = getCursorPosition()
		cx, cy = cx*sx, cy*sy
		if(not mData["done"]) then
			dxDrawImage(cx-17.5, cy-17.5, 35, 35, "images/wheel.png", mData["spin"], 0, 0, tocolor(255, 255, 255, 255), true)
		end
		if(mData["spinning"]) then
			if(mData["spin"] < 360) then 
				mData["spin"] = mData["spin"]+20
			else
				mData["spin"] = 0
			end
			if(isCursorHover(x-(w/2), y-(h/2), w, h)) then
				if(mData["moved"]) then
					mData["health"] = mData["health"]+0.0625
					mData["moved"] = false
				end
				if(mData["health"] >= 100) then
					mData["spinning"] = false
					mData["done"] = true
				end
			end
		end
	end
	
	dxDrawRectangle(x-175, y+200, 350, 30, tocolor(0, 0, 0, 100))
	-- Ok
	dxDrawText("Kész", x-175, y+200, x-75, y+230, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	if(isCursorHover(x-175, y+200, 100, 30)) then
		dxDrawRectangle(x-175, y+200, 100, 30, tocolor(255, 215, 0, 150))
		mHover["okButton"] = true
	else
		dxDrawRectangle(x-175, y+200, 100, 30, tocolor(0, 0, 0, 150))
		mHover["okButton"] = false
	end
	
	-- Cancel
	dxDrawText("Mégse", x-175+350-100, y+200, x-175+350, y+230, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	if(isCursorHover(x-175+350-100, y+200, 100, 30)) then
		dxDrawRectangle(x-175+350-100, y+200, 100, 30, tocolor(255, 215, 0, 150))
		mHover["cancelButton"] = true
	else
		dxDrawRectangle(x-175+350-100, y+200, 100, 30, tocolor(0, 0, 0, 150))
		mHover["cancelButton"] = false
	end
end

function doRefineryMinigame(button, state)
	if(button == "left") then
		if(state == "down") then
			if(not mData["done"]) then
				mData["spinning"] = true
			end
			if(mHover["okButton"]) then
				triggerServerEvent("onRefineryMinigameEnd", localPlayer, localPlayer, mData["type"], math.floor(mData["health"]), mData["slot"])
				removeEventHandler("onClientRender", root, renderRefineryMinigame)
				removeEventHandler("onClientClick", root, doRefineryMinigame)
				removeEventHandler("onClientCursorMove", root, onMoveCursor)
				mData["spinning"] = false
				mData["done"] = true
				showCursor(false)
			elseif(mHover["cancelButton"]) then
				removeEventHandler("onClientRender", root, renderRefineryMinigame)
				removeEventHandler("onClientClick", root, doRefineryMinigame)
				removeEventHandler("onClientCursorMove", root, onMoveCursor)
				mData["spinning"] = false
				mData["done"] = true
				showCursor(false)
			end
		elseif(state == "up") then
			if(not mData["done"]) then
				mData["spinning"] = false
			end
		end
	end 
end

addEventHandler("onClientColShapeHit", root, function(e, md)
	if(e == localPlayer and md) then
		if(getElementJobData(source, "job") == 1 and localPlayer:getData("char >> job") == 1) then
			if(tutorialState == 3) then
				nextTutorial()
			end
			if(getElementJobData(source, "refinery")) then
				setElementJobData(localPlayer, "enablePickup", true)
				addEventHandler("onClientKey", root, pickupRockFromVehicleHandler)
				if(getElementJobData(localPlayer, "started")) then
					exports['cr_infobox']:addBox("info", "Követ levenni a kocsi hátuljánál az 'E' gombbal tudsz.", 255, 255, 255, true)
				end
			elseif(getElementJobData(source, "deposit")) then
				setElementJobData(localPlayer, "enablePickupBag", true)
				addEventHandler("onClientKey", root, pickupBagFromVehicleKeyHandler)
				addEventHandler("onClientKey", root, putdownBagKeyHandler)
			end
		end
	end
end)

addEventHandler("onClientColShapeLeave", root, function(e, md)
	if(e == localPlayer and md) then
		if(getElementJobData(source, "job") == 1) then
			if(getElementJobData(source, "refinery")) then
				setElementJobData(localPlayer, "enablePickup", false)
				removeEventHandler("onClientKey", root, pickupRockFromVehicleHandler)
			elseif(getElementJobData(source, "deposit")) then
				setElementJobData(localPlayer, "enablePickupBag", false)
				removeEventHandler("onClientKey", root, pickupBagFromVehicleKeyHandler)
				removeEventHandler("onClientKey", root, putdownBagKeyHandler)
			end
		end
	end
end)

itemTable = {
	[1] = {31, 66, "Kő", 110},
	[2] = {67, 100, "Alumínium", 111},
	[3] = {2, 2, "Homokkő", 112},
	[4] = {6, 10, "Szén", 113},
	[5] = {16, 30, "Vas", 114},
	[6] = {1, 1, "Titán", 115},
	[7] = {11, 15, "Ólom", 116},
	[8] = {3, 5, "Vörösréz", 117},
}

function randomItem(bags)
	local kezdo = 1
	for i, v in pairs(bags) do
		local type = tonumber(v["containingRockType"])
		if(type == 1) then
			kezdo = kezdo + 5
		elseif(type == 2) then
			kezdo = kezdo + 3
		elseif(type == 3) then
			kezdo = kezdo + 2
		end
	end
	local random = math.random(kezdo, 100)
	for index, value in pairs(itemTable) do
		if(value[1] <= random and value[2] >= random) then
			return index
		end
	end
end

vehicleBags = {}
hoverData = {
	["yesButton"] = false,
	["cancelButton"] = false,
	["noButton"] = false,
}

function renderDepositPanel()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
    local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
    local font3 = exports['cr_fonts']:getFont("Roboto", 10)
    local x, y, w, h = sx/2-250, sy/2-200, 500, 400
	local alpha = 175
	if(panelData["depositPanel"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["depositPanel"]["startTime"]
		local duration = panelData["depositPanel"]["endTime"] - panelData["depositPanel"]["startTime"]
		local progress = elapsedTime / duration
		local stx, sty = sx/2-250, -400
		local ex, ey = x, y
		local posX, posY = interpolateBetween(stx, sty, 0, ex, ey, 0, progress, "OutBack")
		if(panelData["depositPanel"]["hide"]) then
			stx, sty = x, y
			ex, ey = sx/2-250, -400
			posX, posY = interpolateBetween(stx, sty, 0, stx, ey, 0, progress, "OutBack")
		end
		dxDrawRectangle(posX, posY, w, h, tocolor(0, 0, 0, alpha))
		dxDrawRectangle(posX, posY, w, 35, tocolor(0, 0, 0, alpha))
		dxDrawText("Bányász", posX+30, posY, posX+60, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
		dxDrawText("Valóban le szeretnéd pakolni a zsákokat?\nZsákok:", posX+10, posY+40, w, h, tocolor(255, 255, 255, 255), 1, font3, nil, nil, false, false, true, true)
		
		for i, v in pairs(vehicleBags) do
			dxDrawRectangle(posX+30, posY+50+(i*45), 40, 40, tocolor(0, 0, 0, 150))
			dxDrawImage(posX+35, posY+55+(i*45), 30, 30, "images/"..v["containingRockType"]..".png", 0, 0, 0, tocolor(255, 255, 255, 255))
			dxDrawText(rockTypeText[v["containingRockType"]].." - Feldolgozottság: #007a78"..v["status"].."%", posX+75, posY+62+(i*45), sx, sy, tocolor(255, 255, 255, 255), 1, font, nil, nil, false, false, true, true)
		end
		
		
        if(isCursorHover(posX, posY+h-35, 100, 35)) then
            hoverData["yesButton"] = true
            dxDrawRectangle(posX, posY+h-35, 100, 35, tocolor(255, 165, 0, alpha))
        else
            hoverData["yesButton"] = false
            dxDrawRectangle(posX, posY+h-35, 100, 35, tocolor(0, 0, 0, alpha))
        end
        dxDrawText("Igen", posX, posY+h-35, posX+100, posY+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		
		if(isCursorHover(posX+w-100, posY+h-35, 100, 35)) then
            hoverData["cancelButton"] = true
            dxDrawRectangle(posX+w-100, posY+h-35, 100, 35, tocolor(255, 165, 0, alpha))
        else
            hoverData["cancelButton"] = false
            dxDrawRectangle(posX+w-100, posY+h-35, 100, 35, tocolor(0, 0, 0, alpha))
        end
        dxDrawText("Mégse", posX+w-100, posY+h-35, posX+w, posY+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	end
end 

addEventHandler("onClientClick", root, function(button, state)
	if(panelData["depositPanel"]["show"] and not panelData["depositPanel"]["hide"]) then
		if(button == "left" and state == "down") then
			if(hoverData["yesButton"]) then
				setElementJobData(localPlayer, "deposited", true)
				local veh = getPlayerJobVehicle()
				setElementJobData(veh, "deposited", true)
				outputChatBox(msgs["info"].." Most lepakolhatod a járművedet!", 255, 255, 255, true)
				local bags = getElementJobData(veh, "refinedRocks") or {}
				setElementJobData(localPlayer, "bagNumber", #bags)
				showPanel(4, false)
				exports['cr_infobox']:addBox("info", "Zsákot levenni a kocsi hátuljánál az 'E' gombbal tudsz.", 255, 255, 255, true)
				if(tutorialState == 7) then
					nextTutorial()
				end
				setTimer(function() 
					removeEventHandler("onClientRender", root, renderDepositPanel)
				end, 500, 1)
			elseif(hoverData["cancelButton"]) then
				showPanel(4, false)
				setTimer(function() 
					removeEventHandler("onClientRender", root, renderDepositPanel)
				end, 500, 1)
			end
		end
	end
end)

addEventHandler("onClientMarkerHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 1) then
			if(getElementJobData(localPlayer, "started")) then
				if(getElementJobData(source, "refineryMarker")) then
					localPlayer:setData("job >> refineryMarker", true)
					localPlayer:setData("job >> refineryMarkerSlot", getElementJobData(source, "slot"))
					addEventHandler("onClientKey", root, minigameKeyHandler)
					if(getElementJobData(localPlayer, "started") and getElementJobData(localPlayer, "rockInHand")) then
						exports['cr_infobox']:addBox("info", "A kő feldolgozásához használd az 'E' gombot!", 255, 255, 255, true)
					end
				elseif(getElementJobData(source, "depositMarker")) then
					if(isPedInVehicle(localPlayer)) then
						local veh = localPlayer:getOccupiedVehicle()
						if(veh) then
							if(veh:getController() == localPlayer) then
								if(veh:getData("veh >> job") == 1) then
									if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
										local bags = getElementJobData(veh, "refinedRocks")
										if(#bags > 0) then
											if(not getElementJobData(localPlayer, "deposited")) then
												vehicleBags = {}
												for i, v in pairs(bags) do
													table.insert(vehicleBags, v:getData("job >> data"))
													vehicleBags[#vehicleBags]["object"] = v 
												end
												showPanel(4, true)
												addEventHandler("onClientRender", root, renderDepositPanel)
											end
										end
									end
								end
							end
						end
					end
				elseif(getElementJobData(source, "putdownMarker")) then
					setElementJobData(localPlayer, "putdown", true)
					addEventHandler("onClientKey", root, putdownBagKeyHandler)
				end
			end
		end
	end
end)

addEventHandler("onClientMarkerLeave", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 1) then
			if(getElementJobData(localPlayer, "started")) then
				if(getElementJobData(source, "refineryMarker")) then
					localPlayer:setData("job >> refineryMarker", false)
					removeEventHandler("onClientKey", root, minigameKeyHandler)
				elseif(getElementJobData(source, "depositMarker")) then
					showPanel(4, false)
					setTimer(function() 
						removeEventHandler("onClientRender", root, renderDepositPanel)
					end, 500, 1)
				elseif(getElementJobData(source, "putdownMarker")) then
					setElementJobData(localPlayer, "putdown", false)
					removeEventHandler("onClientKey", root, putdownBagKeyHandler)
				end
			end
		end
	end
end)

function getNearestBag(player, distance)
	local tempTable = {}
	local lastMinDis = distance-0.0001
	local nearestVeh = false
	local px, py, pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)
	for _,v in pairs(getElementsByType("object")) do
		if(getElementJobData(v, "bagObject")) then
			local vint,vdim = getElementInterior(v), getElementDimension(v)
			if(vint == pint and vdim == pdim) then
				local vx, vy, vz = getElementPosition(v)
				local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
				if(dis < distance)then
					if(dis < lastMinDis) then 
						lastMinDis = dis
						nearestVeh = v
					end
				end
			end
		end
	end
	return nearestVeh
end

addEventHandler("onClientKey", root, function(key, pressed)
	if(getElementJobData(localPlayer, "started")) then
		if(not getElementJobData(localPlayer, "rockInHand")) then
			if(not getElementJobData(localPlayer, "bagInHand")) then
				if(getElementJobData(localPlayer, "enablePickup")) then
					if(key == "e") then
						if(pressed) then
							local bag = getNearestBag(localPlayer, 1)
							if(isElement(bag)) then
								if(not getElementJobData(bag, "onVehicleBack")) then
									local jobveh = getPlayerJobVehicle()
									if(jobveh) then
										local rocks = getElementJobData(jobveh, "rocks") or {}
										if(#rocks == 0) then
											vcX, vcY, vcZ = getElementPosition(bag)
											addEventHandler("onClientRender", root, renderAction, true, "low-5")
											exports.cr_progressbar:createProgressbar("miner >> felvetel2", tocolor(0, 0, 150, 255), "Felvétel...", 2000)
											pickupTimer = setTimer(function()
												if(tutorialState == 6) then
													nextTutorial()
												end
												triggerServerEvent("pickUpBag", localPlayer, localPlayer, bag:getData("job >> data"))
												toggleControl("sprint", false)
												toggleControl("jump", false)
												removeEventHandler("onClientRender", root, renderAction)
												bag:destroy()
												addEventHandler("onClientKey", root, loadBagKeyHandler)
											end, 2000, 1)
										end
									end
								end
							end
						else
							if(isTimer(pickupTimer)) then
								killTimer(pickupTimer)
								removeEventHandler("onClientRender", root, renderAction)
								exports.cr_progressbar:deleteProgressbar("miner >> felvetel2")
							end
						end
					end
				end
			end
		end	
	end
end)

addEvent("createBagObject", true)
addEventHandler("createBagObject", root, function(rockType, rockStatus, slot) 
	createBagObject(rockType, rockStatus, true, slot)
end)

local bagData = {};
function moveBag()
	local now = getTickCount()
	local elapsedTime = now - bagData["start"]
	local duration = bagData["stop"] - bagData["start"]
	local progress = elapsedTime / duration
	local startx, starty, startz = unpack(slotPositions[tonumber(bagData["slot"])]["start"])
	local stopx, stopy, stopz = unpack(slotPositions[tonumber(bagData["slot"])]["stop"])
	local x, y, z = interpolateBetween(startx, starty, startz, stopx, stopy, stopz, progress, "Linear")
	bagData["bag"]:setPosition(x, y, z)
end

function createBagObject(rockType, rockStatus, updateData, slot)
	local x, y, z = unpack(slotPositions[tonumber(slot)]["start"])
	local bag = createObject(2060, x, y, z)
	
	bagData["bag"] = bag
	bagData["start"] = getTickCount()
	bagData["stop"] = getTickCount()+10000
	bagData["slot"] = slot
	setTimer(function() 
		removeEventHandler("onClientRender", root, moveBag)
		x, y, z = unpack(slotPositions[tonumber(slot)]["end"])
		bag:setPosition(x, y, z)
	end, 10000, 1)
	addEventHandler("onClientRender", root, moveBag, true, "low-5")
	bag:setData("job >> data", {["job"] = 1, ["bagObject"] = true, ["containingRockType"] = rockType, ["status"] = rockStatus, ["account"] = localPlayer:getData("acc >> id")})
	if(updateData) then
		local refinedRocks = getElementJobData(localPlayer, "refinedRocks") or {}
		local refinedRockData = getElementJobData(localPlayer, "refinedRockData") or {}
		table.insert(refinedRocks, bag)
		table.insert(refinedRockData, {["job"] = 1, ["bagObject"] = true, ["containingRockType"] = rockType, ["status"] = rockStatus, ["account"] = localPlayer:getData("acc >> id"), ["slot"] = slot,})
		setElementJobData(localPlayer, "refinedRocks", refinedRocks)
		setElementJobData(localPlayer, "refinedRockData", refinedRockData)
	end
end

function destroyBagsInGround()
	for i, v in pairs(getElementsByType("object")) do
		if(getElementJobData(v, "account") == localPlayer:getData("acc >> id")) then
			if(getElementJobData(v, "bagObject")) then
				v:destroy()
			end
		end
	end
end

addEvent("deletedJobVehicle", true)
addEventHandler("deletedJobVehicle", getRootElement(), function(data) 
	local rocks = data["rocks"] or {}
	local bags = data["refinedRocks"] or {}
	if(#rocks > 0) then
		triggerServerEvent("destroyObjects", localPlayer, rocks)
	end
	if(#bags > 0) then
		triggerServerEvent("destroyObjects", localPlayer, bags)
	end
end)

local renderItem = false
function renderSalaryInfo()
	if(renderItem) then
		local font = exports['cr_fonts']:getFont("Roboto", 10)
		local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
		local font3 = exports['cr_fonts']:getFont("Roboto", 10)
		local x, y, w, h = sx/2-25, sy/2-150, 35, 35
		dxDrawImage(x, y, w, h, "images/"..renderItem[4]..".png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
		dxDrawText("Kaptál egy bónusz tárgyat: #007a78"..renderItem[3], x, y, x+w, y+50+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	end
end

addEvent("giveClientSalary", true)
addEventHandler("giveClientSalary", root, function(item)
	exports.cr_tutorial:hidePanel()
	tutorialState = 0
	setElementJobData(localPlayer, "tutorial", false)
	setElementJobData(localPlayer, "tutorialState", 0)
	local veh = getPlayerJobVehicle()
	local salary = 0
	local HPbonus = 200*((localPlayer.health/100)-0.5)
	local HPvehBonus = 200*((veh.health/1000)-0.50)
	HPbonus = HPbonus > 200 and 200 or HPbonus < -50 and -50 or HPbonus
	HPvehBonus = HPvehBonus > 200 and 200 or HPvehBonus < -50 and -50 or HPvehBonus
	for i, v in pairs(vehicleBags) do
		salary = salary+value[v["containingRockType"]]+((value[v["containingRockType"]]/100)*v["status"])
	end
	salary = salary+HPbonus+HPvehBonus
	-- if not exports["cr_network"]:getNetworkStatus() then return end
	triggerServerEvent("giveSalary", localPlayer, localPlayer, salary)
	if(item) then
		local index = randomItem(vehicleBags)
		triggerServerEvent("giveMinerItem", localPlayer, localPlayer, itemTable[index][4])
		renderItem = itemTable[index]
		outputChatBox(msgs["info"].."Kaptál egy bónusz tárgyat: #007a78"..itemTable[index][3], 255, 255, 255, true)
		addEventHandler("onClientRender", root, renderSalaryInfo)
		setTimer(function()
			removeEventHandler("onClientRender", root, renderSalaryInfo)
			renderItem = false
		end, 5000, 1)
	end
end)