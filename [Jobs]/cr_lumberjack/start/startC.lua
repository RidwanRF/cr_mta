addEventHandler("onClientResourceStart", resourceRoot, function() 
	if(localPlayer:getData("char >> job") == 2) then
		initializeJobStarter()
		restoreJobStatus()
	end
end)

addEventHandler("onClientElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
	if(source == localPlayer) then
		if(dataName == "char >> job") then
			if(oldValue == 2 and newValue ~= 2) then
				destroyElementJobData(localPlayer)
				for i, v in pairs(getElementsByType("marker"), resourceRoot) do
					if(getElementJobData(v, "job") == 2) then
						if(getElementJobData(v, "start")) then
							v:destroy()
						end
					end
				end
				exports.cr_radar:destroyStayBlip("Fa leadó telep")
				exports.cr_radar:destroyStayBlip("Fatelep")
			elseif(newValue == 2) then
				initializeJobStarter()
				restoreJobStatus()
			end
		end
	end
end)

function restoreJobStatus()
	if(localPlayer:getData("char >> job") == 2) then
		local blip = createBlip(-2010.587890625, -2402.61328125, 31.492992401123)
		exports.cr_radar:createStayBlip("Fa leadó telep", blip, 1, "zold", 15, 15, 255, 255, 255, false)
	end
end

function initializeJobStarter()
	startMarker = createMarker(1089.5825195313, -306.79516601563, 72.9921875, "cylinder", 1.2, 255, 165, 0, 0)
	startMarker:setData("job >> data", {["job"] = 2, ["start"] = true, ["account"] = localPlayer:getData("acc >> id")})
	local blip = createBlip(1090.3823242188, -316.11206054688, 73.9921875)
	exports.cr_radar:createStayBlip("Fatelep", blip, 1, "sarga", 15, 15, 255, 255, 255, false)
end

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
		dxDrawText("Favágó", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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
		dxDrawText("Favágó", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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

addEventHandler("onClientMarkerHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 2) then
			if(not getElementJobData(localPlayer, "started")) then
				if(not isPedInVehicle(localPlayer)) then
					if(getElementJobData(source, "job") == 2) then
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
				if(getElementJobData(source, "job") == 2) then
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
		if(localPlayer:getData("char >> job") == 2) then
			if(not getElementJobData(localPlayer, "started")) then
				if(getElementJobData(source, "job") == 2) then
					if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
						if(getElementJobData(source, "start")) then
                            if(isTimer(removeTimer)) then
                                killTimer(removeTimer)     
                            end
                            removeTimer = setTimer(function()
                                removeEventHandler("onClientRender", root, renderPanels)
                            end, 500, 1)
							showPanel(1, false)
							removeEventHandler("onClientKey", root, startPanelKeyHandler)
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
				if(getElementJobData(source, "job") == 2) then
					if(getElementJobData(source, "account") == localPlayer:getData("acc >> id")) then
				        if(isTimer(removeTimer)) then
                            killTimer(removeTimer)     
                        end
                        removeTimer = setTimer(function()
                            removeEventHandler("onClientRender", root, renderPanels)
                        end, 500, 1)
						showPanel(2, false)
						removeEventHandler("onClientKey", root, stopPanelKeyHandler)
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

addEvent("deletedJobVehicle", true)
addEventHandler("deletedJobVehicle", getRootElement(), function(data) 
	local piles = data["piles"] or {}
	if(#piles > 0) then
		triggerServerEvent("destroyObjects", localPlayer, localPlayer, piles)
	end
end)


-- addEventHandler("onClientClick", root, function(button, state)
    -- if(panelData["start"]["show"]) then
        -- if(button == "left" and state == "down") then
            -- if(hoverData["startButton"]) then
                -- showPanel(1, false)
                -- if(isTimer(removeTimer)) then
                    -- killTimer(removeTimer)     
                -- end
                -- removeTimer = setTimer(function()
                    -- removeEventHandler("onClientRender", root, renderPanels)
                    -- hoverData["startButton"] = false
                -- end, 500, 1)
                -- triggerServerEvent("startLumberjack", resourceRoot)
            -- end
        -- end
    -- elseif(panelData["stop"]["show"]) then
        -- if(button == "left" and state == "down") then
           -- if(hoverData["stopButton"]) then
                -- destroyElementJobData(localPlayer)
                -- triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
                -- showPanel(2, false)
                -- if(isTimer(removeTimer)) then
                    -- killTimer(removeTimer)     
                -- end
                -- removeTimer = setTimer(function()
                    -- removeEventHandler("onClientRender", root, renderPanels)
                    -- hoverData["stopButton"] = false
                -- end, 500, 1)
                -- outputChatBox(msgs["info"].." Befejezted a munkádat.", 255, 255, 255, true)
            -- end
        -- end
    -- end
-- end)