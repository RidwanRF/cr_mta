addEventHandler("onClientResourceStart", root, function() 
	if(localPlayer:getData("char >> job") == 1) then
		initializeJobStarter()
		restoreJobStatus()
	end
end)

-- local hoverData = {
    -- ["startButton"] = false,
    -- ["retireButton"] = false,
    -- ["stopButton"] = false,
    -- ["chButton"] = false,
-- }

panelKeys = {
	["start"] = false,
	["stop"] = false,
}

keyDatas = {
	["start"] = {
		["start"] = 0,
		["stop"] = 0,
	},
	["stop"] = {
		["start"] = 0,
		["stop"] = 0,
	}
}

checkboxes = {
	["tutorial"] = false,
};

local posX, posY
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
		dxDrawText("Bányász", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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
			dxDrawText("Az indításhoz tartsd lenyomva a 'E' gombot!", posX+24, posY+h-46, posX+351, posY+h-24, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	elseif(panelData["stop"]["show"]) then
		local now = getTickCount()
		local elapsedTime = now - panelData["stop"]["startTime"]
		local duration = panelData["stop"]["endTime"] - panelData["stop"]["startTime"]
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
		dxDrawText("Bányász", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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
			dxDrawText("Leállítás...", posX+24, posY+h-46, posX+351, posY+h-24, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		else
			dxDrawText("A leállításhoz tartsd lenyomva a 'E' gombot!", posX+24, posY+h-46, posX+351, posY+h-24, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        end
	end
end

function cbClick(b, s) 
	if(b == "left" and s == "down") then
		if(isCursorHover(posX+50, posY+55, 25, 25)) then
			checkboxes["tutorial"] = not checkboxes["tutorial"]
		end
	end
end

addEventHandler("onClientElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
	if(source == localPlayer) then
		if(dataName == "char >> job") then
			if(oldValue == 1 and newValue ~= 1) then
				deleteJobMarkers()
				triggerServerEvent("destroyVehicleRocks", localPlayer, localPlayer)
				setTimer(function()
					triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
					destroyElementJobData(localPlayer)
				end, 250, 1)
				for i, v in pairs(getElementsByType("marker"), resourceRoot) do
					if(getElementJobData(v, "job") == 1) then
						if(getElementJobData(v, "start")) then
							v:destroy()
						end
					end
				end
				exports.cr_radar:destroyStayBlip("Bánya")
				exports.cr_radar:destroyStayBlip("Kő feldolgozó")
				exports.cr_radar:destroyStayBlip("Zsák leadó")
			elseif(newValue == 1) then
				initializeJobStarter()
				for i, v in pairs(getElementsByType("object"), resourceRoot) do
					if(getElementJobData(v, "rockObjective")) then
						rockDisplay[getElementJobData(v, "rockID")] = {v, getElementJobData(v, "rockType")}     
					end
				end
				updateDistance()
			end
		end
	end
end)

addEvent("restoreJobStatus", true)
addEventHandler("restoreJobStatus", getRootElement(), function() 
	restoreJobStatus()
end)

function restoreJobStatus()
	if(getElementJobData(localPlayer, "started")) then
		for i, v in pairs(getElementsByType("vehicle")) do
			if(v:getData("veh >> job") == 1 and v:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
				-- local ch = createMarker(-2205.2429199219, -1134.6264648438, 18.5, "cylinder", 1, 0, 100, 0, 100)
				-- ch:setData("job >> data", {["job"] = 1, ["starter"] = localPlayer:getData("acc >> id"), ["changingRoom"] = true,})
				local blip = createBlip(336.34429931641, -65.439849853516, 1.5544219017029)
				exports.cr_radar:createStayBlip("Kő feldolgozó", blip, 1, "kek", 15, 15, 255, 255, 255, false)
				
				blip = createBlip(-1745.3931884766, -110.01053619385, 3.5546875)
				exports.cr_radar:createStayBlip("Zsák leadó", blip, 1, "zold", 15, 15, 255, 255, 255, false)
				for i, v in pairs(putdowns) do
					local x, y, z = unpack(v)
					local putdownMarker = createMarker(x, y, z-1, "cylinder", 0.7, 100, 100, 0, 100)
					putdownMarker:setData("job >> data", {["job"] = 1, ["putdownMarker"] = true, ["starter"] = localPlayer:getData("acc >> id"),})
				end
				triggerServerEvent("destroyRockInHand", localPlayer, localPlayer)
				triggerServerEvent("destroyBagInHand", localPlayer, localPlayer)
				local bags = getElementJobData(localPlayer, "refinedRockData") or {}
				for i, v in pairs(bags) do
					createBagObject(v["containingRockType"], v["status"], false, v["slot"])
				end
				if(getElementJobData(localPlayer, "tutorial")) then
					tutorialState = tonumber(getElementJobData(localPlayer, "tutorialState"))
					exports.cr_tutorial:showPanel(tutorialTitle, tutorialTexts[tutorialState])
				end
				break
			end
		end
	end
end

function initializeJobStarter()
	startMarker = createMarker(-2242.6137695313, -1159.3851318359, 18, "cylinder", 1.2, 255, 165, 0, 0)
	startMarker:setData("job >> data", {["job"] = 1, ["start"] = true, ["account"] = localPlayer:getData("acc >> id")})
	local blip = createBlip(-2221.7194824219, -1128.6009521484, 19.227294921875)
	exports.cr_radar:createStayBlip("Bánya", blip, 1, "sarga", 15, 15, 255, 255, 255, false)
end

addEventHandler("onClientMarkerHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 1) then
			if(not getElementJobData(localPlayer, "started")) then
				if(not isPedInVehicle(localPlayer)) then
					if(getElementJobData(source, "job") == 1) then
						if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
							if(getElementJobData(source, "start")) then
								addEventHandler("onClientRender", root, renderPanels)
								showPanel(1, true)
								addEventHandler("onClientKey", root, startPanelKeyHandler)
								addEventHandler("onClientClick", root, cbClick)
							end
						end
					end
				end
			else
				if(getElementJobData(source, "job") == 1) then
					if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
						addEventHandler("onClientRender", root, renderPanels)
						showPanel(2, true)
						addEventHandler("onClientKey", root, stopPanelKeyHandler)
					end
				end
			end
		end
	end
end)

local removeTimer = false
addEventHandler("onClientMarkerLeave", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 1) then
			if(not getElementJobData(localPlayer, "started")) then
				if(getElementJobData(source, "job") == 1) then
					if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
						if(getElementJobData(source, "start")) then
                            if(isTimer(removeTimer)) then
                                killTimer(removeTimer)     
                            end
							removeEventHandler("onClientKey", root, startPanelKeyHandler)
                            removeTimer = setTimer(function()
                                removeEventHandler("onClientRender", root, renderPanels)
                                hoverData["startButton"] = false
                            end, 500, 1)
							showPanel(1, false)
							removeEventHandler("onClientClick", root, cbClick)
							keyDatas["start"]["start"] = 0
							keyDatas["start"]["stop"] = 0
							panelKeys["start"] = false
							if(isTimer(timerHandler)) then
								killTimer(timerHandler)
							end
						end
					end
				end
			else
				if(getElementJobData(source, "job") == 1) then
					if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
				        if(isTimer(removeTimer)) then
                            killTimer(removeTimer)     
                        end
						removeEventHandler("onClientKey", root, stopPanelKeyHandler)
                        removeTimer = setTimer(function()
                            removeEventHandler("onClientRender", root, renderPanels)
                            hoverData["stopButton"] = false
                        end, 500, 1)
						showPanel(2, false)
						-- showCursor(false)
						keyDatas["stop"]["start"] = 0
						keyDatas["stop"]["stop"] = 0
						panelKeys["stop"] = false
						if(isTimer(timerHandler)) then
							killTimer(timerHandler)
						end
					end
				end
			end
		end
	end
end)

-- local cooldown = nil
-- addEventHandler("onClientClick", root, function(button, state) 
	-- if(not isTimer(cooldown)) then
		-- if(panelData["start"]["show"] and not panelData["start"]["hide"]) then
			-- if(button == "left" and state == "down") then
				-- if(hoverData["startButton"]) then
					-- triggerServerEvent("startedMiner", root)
					-- local ch = createMarker(-2205.2429199219, -1134.6264648438, 18.5, "cylinder", 1, 0, 100, 0, 100)
					-- ch:setData("job >> data", {["job"] = 1, ["starter"] = localPlayer:getData("acc >> id"), ["changingRoom"] = true,})
					
					-- for i, v in pairs(putdowns) do
						-- local x, y, z = unpack(v)
						-- local putdownMarker = createMarker(x, y, z-1, "cylinder", 0.7, 100, 100, 0, 100)
						-- putdownMarker:setData("job >> data", {["job"] = 1, ["putdownMarker"] = true, ["starter"] = localPlayer:getData("acc >> id"),})
					-- end
					
					-- showPanel(1, false)
					-- for i, v in pairs(getElementsByType("object")) do
						-- if(getElementJobData(v, "rockObjective")) then
							-- rockDisplay[getElementJobData(v, "rockID")] = {v, getElementJobData(v, "rockType")}     
						-- end
					-- end
					-- updateDistance()
					-- cooldown = setTimer(function() end, 1000, 1)
                -- end
			-- end
		-- elseif(panelData["stop"]["show"] and not panelData["stop"]["hide"]) then
			-- if(button == "left" and state == "down") then
				-- if(hoverData["stopButton"]) then
					-- triggerServerEvent("destroyVehicleRocks", root)
					-- setTimer(function()
						-- triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
						-- destroyElementJobData(localPlayer)
					-- end, 250, 1)
					-- destroyBagsInGround()
					-- deleteJobMarkers()
					-- showPanel(2, false)
					-- outputChatBox(msgs["info"].." Befejezted a munkádat.", 255, 255, 255, true)
					-- cooldown = setTimer(function() end, 1000, 1)
				-- end
			-- end
		-- elseif(panelData["changingRoom"]["show"] and not panelData["changingRoom"]["hide"]) then
			-- if(button == "left" and state == "down") then
				-- if(hoverData["chButton"]) then
					-- exports['cr_chat']:createMessage(localPlayer, "elővesz egy szaros undorító munkaruhát amit teleizzadtak, majd felhúzza magára", 1)
					-- outputChatBox(msgs["info"].." Sikeresen átöltöztél.", 255, 255, 255, true)
					-- showPanel(3, false)
					-- TODO: Attach helmet to player and also add a jacket. ELEMENT DATA IS!!!!!
					-- cooldown = setTimer(function() end, 1000, 1)
				-- end
			-- end
		-- end
	-- end
-- end)
