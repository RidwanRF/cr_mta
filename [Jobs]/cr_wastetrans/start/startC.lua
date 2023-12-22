addEventHandler("onClientResourceStart", resourceRoot, function() 
	if(localPlayer:getData("char >> job") == 4) then
		initializeJobStarter()
		if(getElementJobData(localPlayer, "started")) then
			restoreJobData()
		end
	end
end)

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
		dxDrawText("Törmelékszállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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
		dxDrawText("Törmelékszállító", posX, posY, posX+w, posY+35, tocolor(255, 255, 255, 255), 1, font2, "center", "center", false, false, true, true)
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

addEventHandler("onClientMarkerHit", root, function(p, md)
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 4) then
			if(getElementJobData(source, "start") and not getElementJobData(localPlayer, "started")) then
				showPanel(1, true)
				addEventHandler("onClientKey", root, startPanelKeyHandler)
				addEventHandler("onClientClick", root, cbClick)
			elseif(getElementJobData(source, "start") and getElementJobData(localPlayer, "started")) then
				showPanel(2, true)
				addEventHandler("onClientKey", root, stopPanelKeyHandler)
			end
		end
	end
end)

addEventHandler("onClientMarkerLeave", root, function(p, md) 
	if(p == localPlayer and md) then
		if(localPlayer:getData("char >> job") == 4) then
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
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
			if(getElementJobData(source, "start") and not getElementJobData(localPlayer, "started")) then
				showPanel(1, false)
				removeEventHandler("onClientKey", root, startPanelKeyHandler)
				removeEventHandler("onClientClick", root, cbClick)
			end
			if(getElementJobData(localPlayer, "started")) then
				if(getElementJobData(source, "start")) then
					showPanel(2, false)
					removeEventHandler("onClientKey", root, stopPanelKeyHandler)
				end
			end
		end
	end
end)

addEventHandler("onClientElementDataChange", root, function(dName, oValue, newValue)
	if(dName == "char >> job") then
		if(source == localPlayer) then
			if(oValue == 4 and newValue ~= 4) then
				destroyJobMarkers()
			elseif(newValue == 4) then
				initializeJobStarter()
			end
		end
	end
end)