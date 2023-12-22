addEventHandler("onClientResourceStart", resourceRoot, function() 
	if(localPlayer:getData("char >> job") == 3) then
		initializeJobStarter()
		restoreJobStatus()
	end
end)

addEventHandler("onClientElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
	if(source == localPlayer) then
		if(dataName == "char >> job") then
			if(oldValue == 3 and newValue ~= 3) then
				if(isElement(startMarker)) then
					startMarker:destroy()
				end
				destroyJobMarkers()
				setTimer(function()
					triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 578)
					destroyElementJobData(localPlayer)
				end, 250, 1)
				exports.cr_radar:destroyStayBlip("Roncs szállító telephely")
				exports.cr_radar:destroyStayBlip("Roncsfeldolgozó")
				exports.cr_radar:destroyStayBlip("Roncstelep")
			elseif(newValue == 3) then
				initializeJobStarter()
				restoreJobStatus()
			end
		end
	end
end)

function restoreJobStatus()
	if(getElementJobData(localPlayer, "started")) then
		for i, v in pairs(getElementsByType("vehicle")) do
			if(v:getData("veh >> job") == 3 and v:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
				local blip = createBlip(-1858.8732910156, -1650.6628417969, 26.690162658691)
				exports.cr_radar:createStayBlip("Roncsfeldolgozó", blip, 1, "kek", 15, 15, 255, 255, 255, false)
				
				blip = createBlip(1295.0541992188, 166.92585754395, 20.4609375)
				exports.cr_radar:createStayBlip("Roncstelep", blip, 1, "zold", 15, 15, 255, 255, 255, false)
			
				if(not getElementJobData(v, "wreckage")) then
					initializeLoadMarkers()
				else
					initializePutdownPlace()
				end
				
				local m = createMarker(-1855.9727783203, -1627.8669433594, 20.75, "cylinder", 2, 0, 0, 150, 100)
				m:setData("job >> data", {["job"] = 3, ["starter"] = localPlayer:getData("acc >> id"), ["forkliftStarter"] = true})
				
				m = createMarker(1295.6427001953, 171.86511230469, 19.4609375, "checkpoint", 1, 0, 150, 0, 150)
				m:setData("job >> data", {["job"] = 3, ["starter"] = localPlayer:getData("acc >> id"), ["putdownMarker"] = true})
				break
			end
		end
	end
end

panelKeys = {
	["start"] = false,
	["stop"] = false,
	["request"] = false,
	["despawnRequest"] = false,
}

keyDatas = {
	["start"] = {
		["start"] = 0,
		["stop"] = 0,
	},
	["stop"] = {
		["start"] = 0,
		["stop"] = 0,
	},
	["request"] = {
		["start"] = 0,
		["stop"] = 0,
	},
	["despawnRequest"] = {
		["start"] = 0,
		["stop"] = 0,
	}
}

local posX, posY

checkboxes = {
	["tutorial"] = false,
};

function cbClick(b, s) 
	if(b == "left" and s == "down") then
		if(isCursorHover(posX+50, posY+55, 25, 25)) then
			checkboxes["tutorial"] = not checkboxes["tutorial"]
		end
	end
end

function renderPanels()
    local font = exports['cr_fonts']:getFont("Roboto", 10)
    local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
    local font3 = exports['cr_fonts']:getFont("Roboto", 10)
    local x, y, w, h = sx/2-200, sy/2-250, 400, 500
    local alpha = 175
	if(panelData["start"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["start"]["startTime"]
		local duration = panelData["start"]["endTime"] - panelData["start"]["startTime"]
		local progress = elapsedTime / duration
		local stx, sty = sx/2-200, -500
		local ex, ey = x, y
		posX, posY = interpolateBetween(stx, sty, 0, ex, ey, 0, progress, "OutBack")
		if(panelData["start"]["hide"]) then
			stx, sty = x, y
			ex, ey = sx/2-200, -500
			posX, posY = interpolateBetween(stx, sty, 0, stx, ey, 0, progress, "OutBack")
		end
		dxDrawRectangle(posX, posY, w, h, tocolor(0, 0, 0, alpha))
		dxDrawRectangle(posX, posY, w, 35, tocolor(0, 0, 0, alpha))
		dxDrawText("Roncs szállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
		dxDrawRectangle(posX+25, posY+40, w-50, h-100, tocolor(0, 0, 0, alpha))
		
		dxDrawRectangle(posX+50, posY+55, 25, 25, tocolor(50, 50, 50, 175))
		dxDrawText("Leírások (Tutorial)", posX+80, posY+60, 0, 0, checkboxes["tutorial"] and tocolor(255, 153, 51, 255) or tocolor(255, 255, 255, 255), 1, font2, nil, nil, false, false, true, true)
		if(checkboxes["tutorial"]) then
			dxDrawRectangle(posX+55, posY+60, 15, 15, tocolor(255, 153, 51, 175))
		end
		
		dxDrawText("Lorem ipsum dolor sit amet, consectetur adipisicing elit.", posX+30, posY+95, posX+350, posY+200, tocolor(255, 255, 255, 255), 1, font, nil, nil, true, true, true, true)
		dxDrawImage(posX+150, posY+h-175, 100, 100, "images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		
		dxDrawRectangle(posX+24, posY+h-46, w-49, 22, tocolor(0, 0, 0, alpha))
        if(panelKeys["start"]) then
			now = getTickCount()
			elapsedTime = now - keyDatas["start"]["start"]
			duration = keyDatas["start"]["stop"] - keyDatas["start"]["start"]
			progress = elapsedTime / duration
			
			local width = interpolateBetween(0, 0, 0, w-50, 0, 0, progress, "Linear")
            dxDrawRectangle(posX+25, posY+h-45, width, 20, tocolor(0, 150, 0, alpha))
			dxDrawText("Indítás...", posX+24, posY+h-46, posX+351, posY+h-24, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		else
			dxDrawText("Az indításhoz tartsd lenyomva a 'E' gombot!", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	elseif(panelData["stop"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["start"]["startTime"]
		local duration = panelData["start"]["endTime"] - panelData["start"]["startTime"]
		local progress = elapsedTime / duration
		local stx, sty = sx/2-200, -500
		local ex, ey = x, y
		local posX, posY = interpolateBetween(stx, sty, 0, ex, ey, 0, progress, "OutBack")
		if(panelData["stop"]["hide"]) then
			stx, sty = x, y
			ex, ey = sx/2-200, -500
			posX, posY = interpolateBetween(stx, sty, 0, stx, ey, 0, progress, "OutBack")
		end
		dxDrawRectangle(posX, posY, w, h, tocolor(0, 0, 0, alpha))
		dxDrawRectangle(posX, posY, w, 35, tocolor(0, 0, 0, alpha))
		dxDrawText("Roncs szállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
		dxDrawRectangle(posX+25, posY+40, w-50, h-100, tocolor(0, 0, 0, alpha))
		dxDrawText("Lorem ipsum dolor sit amet, consectetur adipisicing elit.", posX+30, posY+45, posX+350, posY+200, tocolor(255, 255, 255, 255), 1, font, nil, nil, true, true, true, true)
		dxDrawImage(posX+150, posY+h-175, 100, 100, "images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		
		dxDrawRectangle(posX+24, posY+h-46, w-49, 22, tocolor(0, 0, 0, alpha))
        if(panelKeys["stop"]) then
			now = getTickCount()
			elapsedTime = now - keyDatas["stop"]["start"]
			duration = keyDatas["stop"]["stop"] - keyDatas["stop"]["start"]
			progress = elapsedTime / duration
			
			local width = interpolateBetween(0, 0, 0, w-50, 0, 0, progress, "Linear")
            dxDrawRectangle(posX+25, posY+h-45, width, 20, tocolor(150, 0, 0, alpha))
			dxDrawText("Leállítás...", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		else
			dxDrawText("A leállításhoz tartsd lenyomva a 'E' gombot!", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	elseif(panelData["forklift"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["forklift"]["startTime"]
		local duration = panelData["forklift"]["endTime"] - panelData["forklift"]["startTime"]
		local progress = elapsedTime / duration
		local stx, sty = sx/2-200, -500
		local ex, ey = x, y
		local posX, posY = interpolateBetween(stx, sty, 0, ex, ey, 0, progress, "OutBack")
		if(panelData["forklift"]["hide"]) then
			stx, sty = x, y
			ex, ey = sx/2-200, -500
			posX, posY = interpolateBetween(stx, sty, 0, stx, ey, 0, progress, "OutBack")
		end
		dxDrawRectangle(posX, posY, w, h, tocolor(0, 0, 0, alpha))
		dxDrawRectangle(posX, posY, w, 35, tocolor(0, 0, 0, alpha))
		dxDrawText("Roncs szállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
		dxDrawRectangle(posX+25, posY+40, w-50, h-100, tocolor(0, 0, 0, alpha))
		dxDrawText("Lorem ipsum dolor sit amet, consectetur adipisicing elit.", posX+30, posY+45, posX+350, posY+200, tocolor(255, 255, 255, 255), 1, font, nil, nil, true, true, true, true)
		dxDrawImage(posX+150, posY+h-175, 100, 100, "images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		
		dxDrawRectangle(posX+24, posY+h-46, w-49, 22, tocolor(0, 0, 0, alpha))
        if(panelKeys["request"]) then
			now = getTickCount()
			elapsedTime = now - keyDatas["request"]["start"]
			duration = keyDatas["request"]["stop"] - keyDatas["request"]["start"]
			progress = elapsedTime / duration
			
			local width = interpolateBetween(0, 0, 0, w-50, 0, 0, progress, "Linear")
            dxDrawRectangle(posX+25, posY+h-45, width, 20, tocolor(0, 150, 0, alpha))
			dxDrawText("Lekérés...", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		else
			dxDrawText("Targonca igényléshez tartsd lenyomva a 'E' gombot!", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	elseif(panelData["forkliftDespawn"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["forkliftDespawn"]["startTime"]
		local duration = panelData["forkliftDespawn"]["endTime"] - panelData["forkliftDespawn"]["startTime"]
		local progress = elapsedTime / duration
		local stx, sty = sx/2-200, -500
		local ex, ey = x, y
		local posX, posY = interpolateBetween(stx, sty, 0, ex, ey, 0, progress, "OutBack")
		if(panelData["forkliftDespawn"]["hide"]) then
			stx, sty = x, y
			ex, ey = sx/2-200, -500
			posX, posY = interpolateBetween(stx, sty, 0, stx, ey, 0, progress, "OutBack")
		end
		dxDrawRectangle(posX, posY, w, h, tocolor(0, 0, 0, alpha))
		dxDrawRectangle(posX, posY, w, 35, tocolor(0, 0, 0, alpha))
		dxDrawText("Roncs szállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
		dxDrawRectangle(posX+25, posY+40, w-50, h-100, tocolor(0, 0, 0, alpha))
		dxDrawText("Lorem ipsum dolor sit amet, consectetur adipisicing elit.", posX+30, posY+45, posX+350, posY+200, tocolor(255, 255, 255, 255), 1, font, nil, nil, true, true, true, true)
		dxDrawImage(posX+150, posY+h-175, 100, 100, "images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		
		dxDrawRectangle(posX+24, posY+h-46, w-49, 22, tocolor(0, 0, 0, alpha))
        if(panelKeys["despawnRequest"]) then
			now = getTickCount()
			elapsedTime = now - keyDatas["despawnRequest"]["start"]
			duration = keyDatas["despawnRequest"]["stop"] - keyDatas["despawnRequest"]["start"]
			progress = elapsedTime / duration
			
			local width = interpolateBetween(0, 0, 0, w-50, 0, 0, progress, "Linear")
            dxDrawRectangle(posX+25, posY+h-45, width, 20, tocolor(150, 0, 0, alpha))
			dxDrawText("Leadás...", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		else
			dxDrawText("Targonca leadásához tartsd lenyomva a 'E' gombot!", posX+25, posY+h-46, posX+25+w-50, posY+h-25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	end
end

waitData = {
	["start"] = 0,
	["end"] = 0,
	["pos"] = false,
}
waitTimer = nil

function renderWait()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
    local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
    local font3 = exports['cr_fonts']:getFont("Roboto", 10)
	local x, y, w, h = sx/2-150, sy/2-400, 300, 20
	local now = getTickCount()
	local elapsedTime = now - waitData["start"]
	local duration = waitData["end"] - waitData["start"]
	local progress = elapsedTime / duration
	local width = interpolateBetween(0, 0, 0, w, 0, 0, progress, "Linear")
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 175))
	dxDrawRectangle(x, y+1, width, h-2, tocolor(150, 0, 0, 175))
	dxDrawText("Ne mozogj!", x, y, x+w, y+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	
	local veh = localPlayer:getOccupiedVehicle()
	if(isElement(veh)) then
		if(veh:getModel() == 530) then
			if(not isElement(getElementJobData(veh, "vas"))) then
				local x, y, z = veh:getComponentPosition("misc_a", "world")
				if(waitData["pos"]) then
					local x2, y2, z2 = unpack(waitData["pos"])
					if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 1) then
						killTimer(waitTimer)
						removeEventHandler("onClientRender", root, renderWait)
						waitData["pos"] = false
						setUpCheckTimer()
					end
				end
			else
				local x, y, z = veh:getComponentPosition("misc_a", "world")
				if(waitData["pos"]) then
					local x2, y2, z2 = unpack(waitData["pos"])
					if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 3) then
						killTimer(waitTimer)
						removeEventHandler("onClientRender", root, renderWait)
						waitData["pos"] = false
						setUpCheckTrailer()
					end
				end
			end
		end
	end
end


addEventHandler("onClientMarkerHit", root, function(element, md)
	if(element == localPlayer and md) then
		if(getElementJobData(source, "job") == 3) then
			if(getElementJobData(source, "start")) then
				if(not getElementJobData(localPlayer, "started")) then
					if(not isPedInVehicle(localPlayer)) then
						showPanel(1, true)
						addEventHandler("onClientKey", root, startPanelKeyHandler)
						addEventHandler("onClientClick", root, cbClick)
					end
				else
					showPanel(2, true)
					addEventHandler("onClientKey", root, stopPanelKeyHandler)
				end
				addEventHandler("onClientRender", root, renderPanels)
			elseif(getElementJobData(source, "pickUp")) then
				local veh = localPlayer:getOccupiedVehicle()
				local boxes = getElementJobData(veh, "wreckageBoxes") or {}
				if(#boxes == 0) then
					local rot = veh:getRotation()
					if(rot.z <= 200 and rot.z >= 160) then
						
						waitData["start"] = getTickCount()
						waitData["end"] = getTickCount()+2000
						addEventHandler("onClientRender", root, renderWait)
						waitTimer = setTimer(function(s) 
							toggleControl("enter_exit", false)
							toggleControl("accelerate", false)
							toggleControl("brake_reverse", false)
							outputChatBox(msgs["info"].."A felpakolás megkezdődött várd meg míg a daru felpakolja a roncsot a munkajárművedre!", 255, 255, 255, true)
							local veh = localPlayer:getOccupiedVehicle()
							local rot = veh:getRotation()
							if(rot.z <= 200 and rot.z >= 160) then
								if(getElementJobData(s, "pickUp") == 1) then
									addCarToDFT()
								else
									addCarToDFT2()
								end
								toggleAllControls(false, false, false)
								veh:setFrozen(true)
								
								for index, value in pairs(getElementsByType("marker")) do
									if(getElementJobData(value, "pickUp")) then
										value:destroy()
									end
								end	
								removeEventHandler("onClientRender", root, renderWait)
							else
								outputChatBox(msgs["error"].."A daruhoz képest párhuzamosan állj bele a markerbe!", 255, 255, 255, true)
							end
						end, 2000, 1, source)
					else
						outputChatBox(msgs["error"].."A daruhoz képest párhuzamosan állj bele a markerbe!", 255, 255, 255, true)
					end
				end
			elseif(getElementJobData(source, "putDown")) then
				waitData["start"] = getTickCount()
				waitData["end"] = getTickCount()+2000
				addEventHandler("onClientRender", root, renderWait)
				waitTimer = setTimer(function(s) 
					toggleControl("enter_exit", false)
					toggleControl("accelerate", false)
					toggleControl("brake_reverse", false)
					outputChatBox(msgs["info"].."A lepakolás megkezdődött várd meg míg a daru leemeli a roncsot a munkajárművedről!", 255, 255, 255, true)
					local veh = localPlayer:getOccupiedVehicle()
					for index, value in pairs(getElementsByType("marker")) do
						if(getElementJobData(value, "putDown")) then
							value:destroy()
						end
					end	
					toggleAllControls(false, false, false)
					veh:setFrozen(true)
					removeCarToDFT()
					removeEventHandler("onClientRender", root, renderWait)
				end, 2000, 1)
			elseif(getElementJobData(source, "forkliftStarter")) then
				if(not isPedInVehicle(localPlayer) or isPedInVehicle(localPlayer) and localPlayer:getOccupiedVehicle():getModel() == 530) then
					if(getElementJobData(localPlayer, "started")) then
						for i, v in pairs(getElementsByType("vehicle")) do
							if(v:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
								if(v:getData("veh >> job") and v:getModel() == 530) then
									addEventHandler("onClientRender", root, renderPanels)
									addEventHandler("onClientKey", root, forkliftDespawnPanelKeyHandler)
									showPanel(4, true)
									return
								end
							end
						end
						addEventHandler("onClientRender", root, renderPanels)
						addEventHandler("onClientKey", root, forkliftPanelKeyHandler)
						showPanel(3, true)
					end
				end
			elseif(getElementJobData(source, "putdownMarker")) then
				local veh = localPlayer:getOccupiedVehicle() 
				local boxes = getElementJobData(veh, "wreckageBoxes") or {}
				if(#boxes > 0) then
					waitData["start"] = getTickCount()
					waitData["end"] = getTickCount()+2000
					addEventHandler("onClientRender", root, renderWait)
					waitTimer = setTimer(function(s) 
						local veh = localPlayer:getOccupiedVehicle()
						toggleAllControls(false, false, false)
						toggleControl("enter_exit", false)
						toggleControl("accelerate", false)
						toggleControl("brake_reverse", false)
						veh:setFrozen(true)
						startPutDown()
						removeEventHandler("onClientRender", root, renderWait)
					end, 2000, 1)
				end
			end
		end
	end
end)

addEventHandler("onClientMarkerLeave", root, function(element, md)
	if(element == localPlayer and md) then
		if(getElementJobData(source, "job") == 3) then
			if(getElementJobData(source, "start")) then
				if(not getElementJobData(localPlayer, "started")) then
					showPanel(1, false)
					removeEventHandler("onClientKey", root, startPanelKeyHandler)
					removeEventHandler("onClientClick", root, cbClick)
					panelKeys["start"] = false
					keyDatas["start"]["start"] = 0
					keyDatas["start"]["stop"] = 0
					if(isTimer(timerHandler)) then
						killTimer(timerHandler)
					end
				else
					showPanel(2, false)
					removeEventHandler("onClientKey", root, stopPanelKeyHandler)
					panelKeys["stop"] = false
					keyDatas["stop"]["start"] = 0
					keyDatas["stop"]["stop"] = 0
					if(isTimer(timerHandler)) then
						killTimer(timerHandler)
					end
				end
				setTimer(function() 
					removeEventHandler("onClientRender", root, renderPanels)
				end, 500, 1)
			elseif(getElementJobData(source, "pickUp")) then
				if(isTimer(waitTimer)) then
					killTimer(waitTimer)
				end
				removeEventHandler("onClientRender", root, renderWait)
			elseif(getElementJobData(source, "putDown")) then
				if(isTimer(waitTimer)) then
					killTimer(waitTimer)
				end
				removeEventHandler("onClientRender", root, renderWait)
			elseif(getElementJobData(source, "forkliftStarter")) then
				if(getElementJobData(localPlayer, "started")) then
					for i, v in pairs(getElementsByType("vehicle")) do
						if(v:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
							if(v:getData("veh >> job") and v:getModel() == 530) then
								showPanel(4, false)
								removeEventHandler("onClientKey", root, forkliftDespawnPanelKeyHandler)
								panelKeys["despawnRequest"] = false
								keyDatas["despawnRequest"]["start"] = 0
								keyDatas["despawnRequest"]["stop"] = 0
								setTimer(function() 
									removeEventHandler("onClientRender", root, renderPanels)
								end, 500, 1)
								return
							end
						end
					end
					showPanel(3, false)
					removeEventHandler("onClientKey", root, forkliftPanelKeyHandler)
					panelKeys["request"] = false
					keyDatas["request"]["start"] = 0
					keyDatas["request"]["stop"] = 0
					setTimer(function() 
						removeEventHandler("onClientRender", root, renderPanels)
					end, 500, 1)
				end
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
			elseif(getElementJobData(source, "putdownMarker")) then
				if(isTimer(waitTimer)) then
					killTimer(waitTimer)
				end
				removeEventHandler("onClientRender", root, renderWait)
			end
		end
	end
end)

function initializeLoadMarkers()
	local pickups = {
		{2788.6672363281, -2431.3232421875, 13.13526725769},
		{2789.9035644531, -2486.6979980469, 13.647694587708},
	}
	for i, v in pairs(pickups) do
		local x, y, z = unpack(v)
		local m = createMarker(x, y, z, "checkpoint", 1, 150, 0, 0)
		m:setData("job >> data", {["job"] = 3, ["pickUp"] = i, ["starter"] = localPlayer:getData("acc >> id")})
	end
end

addEvent("deletedJobVehicle", true)
addEventHandler("deletedJobVehicle", getRootElement(), function(data)
	if(isElement(data["wreckage"])) then
		triggerServerEvent("destroyWreckage", localPlayer, localPlayer, data["wreckage"])
	end
	if(isElement(data["vas"])) then
		triggerServerEvent("deletedForklift", localPlayer, localPlayer, data)
	end
	if(data["jobVehicle"]) then
		destroyJobMarkers()
	end
	if(data["wreckageBoxes"]) then
		triggerServerEvent("deleteWreckageBoxes", localPlayer, localPlayer, data)
	end
	
	triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 530)
end)