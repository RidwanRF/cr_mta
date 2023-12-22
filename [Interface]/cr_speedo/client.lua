local sx, sy = guiGetScreenSize();
local browser = createBrowser(301, 240, true, true);
local browserUpdate;
local index_l, index_r = 0, 0
local font2 = dxCreateFont("files/font2.ttf", 20)

function getVehicleSpeed()
	local vehicle = getPedOccupiedVehicle(localPlayer)
    if isPedInVehicle(localPlayer) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 180		
	end
    return 0
end

function getSpeedColor(s)
    local color = "#ffffff"
    if s <= 75 then -- zöld
        color = "#7cc576"
    elseif s <= 120 then -- sárga
        color = "#d09924"
    elseif s > 12 then -- piros
        color = "#d02424"
    end
    return color
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+2,w,h+2,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Fent
    dxDrawText(text,x,y-2,w,h-2,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Lent
    dxDrawText(text,x-2,y,w-2,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Bal
    dxDrawText(text,x+2,y,w+2,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Jobb
end

function renderSpeedo()
	if(browser and isPedInVehicle(localPlayer)) then
		local enabled, x2, y2 = exports['cr_interface']:getDetails("speedo")
		if(enabled) then
			if not getElementData(localPlayer, "hudVisible") then return end
			if not getElementData(localPlayer, "vehname.enabled") then return end
			local veh = localPlayer:getOccupiedVehicle()
			local enabled, x, y, w, h, sizable, turnable = exports['cr_interface']:getDetails("vehname")
			local text = exports['cr_vehicle']:getVehicleName(veh) .. " "
			if veh:getData("tempomat") then
				local tempomatSpeed = veh:getData("tempomat.speed")
				local speedColor = getSpeedColor(tempomatSpeed)
				text = text .. speedColor .."(" ..math.floor(tempomatSpeed).." km/h)"
			end
			local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
			shadowedText(text2, x, y, x + w, y + h, tocolor(255,255,255,255), 1, font2, "center", "center", false, false, false, true)
			dxDrawText(text, x, y, x + w, y + h, tocolor(255,255,255,255), 1, font2, "center", "center", false, false, false, true)
			dxDrawImageSection(x2-30, y2+15, 301, 231, 0, 0, 301, 231, browser);
			-- executeBrowserJavascript(browser, "updatePosition('"..x.."', '"..y.."')")
			if(browserUpdate <= getTickCount()) then
				local gear = getVehicleCurrentGear(veh)
				browserUpdate = getTickCount()+12
				local speed = getVehicleSpeed()
				executeBrowserJavascript(browser, "updateSpeed('"..math.floor(speed).."')")
				executeBrowserJavascript(browser, "updateGear('"..gear.."')")
			end
		end
	end
end

addEventHandler("onClientElementDataChange", root, function(dName, oValue) 
	if(isPedInVehicle(localPlayer)) then
		if(tostring(getElementType(source)) == "vehicle") then
			if(source == localPlayer:getOccupiedVehicle()) then
				if(dName == "veh:IndicatorState") then
					local data = source:getData("veh:IndicatorState") or {left = false, right = false};
					index_l, index_r = data.left and 1 or 0, data.right and 1 or 0
					executeBrowserJavascript(browser, "updateIndexes('"..index_l.."', '"..index_r.."')")
				elseif(dName == "veh >> engine") then
					executeBrowserJavascript(browser, "toggleEngine('".. (source:getData("veh >> engine") and 1 or 0) .."')")
				elseif(dName == "veh >> handbrake") then
					executeBrowserJavascript(browser, "updateHandbrake('".. (source:getData("veh >> handbrake") and 1 or 0) .."')")
				elseif(dName == "veh >> light") then
					executeBrowserJavascript(browser, "updateLight('".. (source:getData("veh >> light") and 1 or 0) .."')")
				end
			end
		end
	end
end)

addEventHandler("onClientBrowserCreated", browser, function()
	loadBrowserURL(browser, "http://mta/local/html/speedo.html")
end)

local checkTimer = nil;
addEventHandler("onClientVehicleEnter", root, function(p, s) 
	if(p == localPlayer) then
		if(s < 2) then
			local data = source:getData("veh:IndicatorState") or {left = false, right = false};
			index_l, index_r = data.left and 1 or 0, data.right and 1 or 0
			browserUpdate = getTickCount()+12
			addEventHandler("onClientRender", root, renderSpeedo)
			executeBrowserJavascript(browser, "updateIndexes('"..index_l.."', '"..index_r.."')")
			executeBrowserJavascript(browser, "updateEngine('".. (source:getData("veh >> engine") and 1 or 0) .."')")
			executeBrowserJavascript(browser, "updateHandbrake('".. (source:getData("veh >> handbrake") and 1 or 0) .."')")
			executeBrowserJavascript(browser, "updateCheckEngine('".. (source:getHealth() <= 600 and 1 or 0) .."')")
			executeBrowserJavascript(browser, "updateLight('".. (source:getData("veh >> light") and 1 or 0) .."')")
			if(isTimer(checkTimer)) then
				killTimer(checkTimer)
			end
			local fuel = localPlayer:getOccupiedVehicle():getData("veh >> fuel")
			local maxFuel = exports["cr_vehicle"]:getVehicleMaxFuel(getElementModel(source))
            if not maxFuel then maxFuel = 100 end
			executeBrowserJavascript(browser, "updateVehicleFuel('".. fuel .."', '".. maxFuel .."')")
			executeBrowserJavascript(browser, "toggleVehicle('1')")
			executeBrowserJavascript(browser, "toggleOilCheck('".. (((localPlayer:getOccupiedVehicle():getData("veh >> odometer") - localPlayer:getOccupiedVehicle():getData("veh >> lastOilRecoil")) >= 988) and 1 or 0) .."')")
			checkTimer = setTimer(function() 
				if(isPedInVehicle(localPlayer) and isElement(localPlayer:getOccupiedVehicle())) then
					executeBrowserJavascript(browser, "updateCheckEngine('".. (localPlayer:getOccupiedVehicle():getHealth() <= 600 and 1 or 0) .."')")
					executeBrowserJavascript(browser, "updateVehicleHealth('".. localPlayer:getOccupiedVehicle():getHealth() .."')")
					local fuel = localPlayer:getOccupiedVehicle():getData("veh >> fuel")
					local maxFuel = exports["cr_vehicle"]:getVehicleMaxFuel(getElementModel(localPlayer:getOccupiedVehicle()))
                    if not maxFuel then maxFuel = 100 end
					executeBrowserJavascript(browser, "updateVehicleFuel('".. fuel .."', '".. maxFuel .."')")
					executeBrowserJavascript(browser, "toggleOilCheck('".. (((localPlayer:getOccupiedVehicle():getData("veh >> odometer") - localPlayer:getOccupiedVehicle():getData("veh >> lastOilRecoil")) >= 988) and 1 or 0) .."')")
					executeBrowserJavascript(browser, "updateOdometer('".. math.floor(tonumber(localPlayer:getOccupiedVehicle():getData("veh >> odometer"))) .."')")
				end
			end, 250, 0)
		end
	end					
end)

addEventHandler("onClientVehicleExit", root, function(p, s) 
	if(p == localPlayer) then
		if(s < 2) then
			if(isTimer(checkTimer)) then
				killTimer(checkTimer)
			end
			removeEventHandler("onClientRender", root, renderSpeedo)
			executeBrowserJavascript(browser, "toggleVehicle('0')")
		end
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	setTimer(function()
		if(isPedInVehicle(localPlayer)) then
			if(localPlayer:getOccupiedVehicleSeat() < 2) then
				local veh = localPlayer:getOccupiedVehicle()
				local data = veh:getData("veh:IndicatorState") or {left = false, right = false};
				index_l, index_r = data.left and 1 or 0, data.right and 1 or 0
				browserUpdate = getTickCount()+125;
				addEventHandler("onClientRender", root, renderSpeedo)
				executeBrowserJavascript(browser, "updateIndexes('"..index_l.."', '"..index_r.."')")
				executeBrowserJavascript(browser, "updateEngine('".. (veh:getData("veh >> engine") and 1 or 0) .."')")
				executeBrowserJavascript(browser, "updateHandbrake('".. (veh:getData("veh >> handbrake") and 1 or 0) .."')")
				executeBrowserJavascript(browser, "updateCheckEngine('".. (veh:getHealth() <= 600 and 1 or 0) .."')")
				executeBrowserJavascript(browser, "updateLight('".. (veh:getData("veh >> light") and 1 or 0) .."')")
				if(isTimer(checkTimer)) then
					killTimer(checkTimer)
				end
				local fuel = localPlayer:getOccupiedVehicle():getData("veh >> fuel")
				local maxFuel = exports["cr_vehicle"]:getVehicleMaxFuel(localPlayer:getOccupiedVehicle():getModel())
                if not maxFuel then maxFuel = 100 end
				executeBrowserJavascript(browser, "updateVehicleFuel('".. fuel .."', '".. maxFuel .."')")
				executeBrowserJavascript(browser, "updateOdometer('".. math.floor(tonumber(localPlayer:getOccupiedVehicle():getData("veh >> odometer"))) .."')")
				executeBrowserJavascript(browser, "toggleOilCheck('".. (((localPlayer:getOccupiedVehicle():getData("veh >> odometer") - localPlayer:getOccupiedVehicle():getData("veh >> lastOilRecoil")) >= 988) and 1 or 0) .."')")
				checkTimer = setTimer(function() 
					executeBrowserJavascript(browser, "updateCheckEngine('".. (localPlayer:getOccupiedVehicle():getHealth() <= 600 and 1 or 0) .."')")
					executeBrowserJavascript(browser, "updateVehicleHealth('".. localPlayer:getOccupiedVehicle():getHealth() .."')")
					local fuel = localPlayer:getOccupiedVehicle():getData("veh >> fuel")
					local maxFuel = exports["cr_vehicle"]:getVehicleMaxFuel(getElementModel(localPlayer:getOccupiedVehicle()))
                    if not maxFuel then maxFuel = 100 end
					executeBrowserJavascript(browser, "updateVehicleFuel('".. fuel .."', '".. maxFuel .."')")
					executeBrowserJavascript(browser, "toggleOilCheck('".. (((localPlayer:getOccupiedVehicle():getData("veh >> odometer") - localPlayer:getOccupiedVehicle():getData("veh >> lastOilRecoil")) >= 988) and 1 or 0) .."')")
					executeBrowserJavascript(browser, "updateOdometer('".. math.floor(tonumber(localPlayer:getOccupiedVehicle():getData("veh >> odometer"))) .."')")
				end, 250, 0)
				executeBrowserJavascript(browser, "toggleVehicle('1')")
				-- toggleBrowserDevTools(browser, true)
			end
		end
	end, 500, 1)
end)