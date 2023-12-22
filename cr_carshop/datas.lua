screenW, screenH = guiGetScreenSize();
show = false;
CameraMode = false;
buyState = true;
countedModels = {};
components = {};
selectedVehicle = 2;
vehicle = nil;
selectedCarshop = 0;
cameraStatus = 270;
cameraHeight = 1;
selectedColor = 0;
cameraZoom = 0;
tick = getTickCount();
oldR, oldG, oldB = 0, 0, 0;
lastX = 25;
mouse = false;
fonts = {};
isBuyPanel = false;

addEventHandler("onClientClick", getRootElement(), function(button, state, x, y, wx, wy, wz, element)
    if button == "left" and state == "down" then
        if element and getElementType(element) == "ped" and not show then
            if getElementData(element, "ped.type.type") == "carshop" then
                selectedCarshop = getElementData(element, "ped.id") or 1;
                triggerServerEvent("server->getModelCount", localPlayer);
            end
        end
            
        if show then
           if exports.cr_core:isInSlot(25, 25, 420, 32) then
                mouse = true
            end
        end
    elseif button == "left" and state == "up" then
        mouse = false;
    end
end);

addEventHandler("onClientKey", getRootElement(), function(button, state)
    if show then
        if CameraMode and cameraZoom < 0 then
            if state then
                if button == "space" then
                    for i, k in pairs(components) do
                        local cx, cy, cz = getVehicleComponentPosition(vehicle, i, "world");
                        if cx then
                            local ex, ey = getScreenFromWorldPosition(cx, cy, cz);
                            local cameraX, cameraY, cameraZ = getCameraMatrix();
                            local dist = math.sqrt((cameraX - cx) ^ 2 + (cameraY - cy) ^ 2 + (cameraZ - cz) ^ 2);
                            local size = 0.40 + (15 - dist) * 0.02;
                            local width, height = 30, 30
                            local dx, dy = ex - width/2, (ey - 10) - height/2 * size;

                            if isPointerHover(dx, dy, width, height) then
                                --dxDrawImage(dx, dy, width, height, "circle2.png");
                                --outputDebugString(k)
                                --outputDebugString(getVehicleDoorState(vehicle, k[2]))
                                setVehicleDoorOpenRatio(vehicle, k[2], getVehicleDoorOpenRatio(vehicle, k[2]) > 0 and 0 or 1, 500);
                            end
                        end
                    end
                end
            end
        end

        if button == "mouse1" and state then
			if not isBuyPanel and isCursorHover(screenW/2 - (525 + 12.5)/2, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4) then
				isBuyPanel = true;
			end

			if isBuyPanel then
				if isCursorHover(screenW / 2 - 230 + 440 / 3 + 10, screenH / 2 - 5, 440 / 3, 60) then
					if getElementData(localPlayer, "char >> premiumPoints") >= vehicleDatas[vehicle.model][2] then
						triggerServerEvent("carshop->BuyVehicle", localPlayer, localPlayer, {"pp", vehicleDatas[vehicle.model][2]}, vehicle.model, {getVehicleColor(vehicle)});
						closeCarshop();
					else
						exports.cr_infobox:addBox("error", "Nincs elég prémium pontod!");
					end
				end
				
				if(isCursorHover(screenW / 2 - 230, screenH / 2 - 5, 440 / 3, 60)) then
					if getElementData(localPlayer, "char >> money") >= vehicleDatas[vehicle.model][1] then
						if(countedModels[vehicle.model] and countedModels[vehicle.model] <= vehicleDatas[vehicle.model][3] or vehicleDatas[vehicle.model][3] == -1 or not countedModels[vehicle.model]) then
							triggerServerEvent("carshop->BuyVehicle", localPlayer, localPlayer, {"dollar", vehicleDatas[vehicle.model][1]}, vehicle.model, {oldR, oldG, oldB});
							closeCarshop();
						else
							exports.cr_infobox:addBox("info", "Ennek a járműnek a limitje betelt! A megvásárláshoz használd a Prémium Pont fizetési módot.");
						end
					else
						exports.cr_infobox:addBox("error", "Nincs elég pénz nálad!");
					end
				end

				if isCursorHover(screenW / 2 - 230 + 2 * (440 / 3 + 10), screenH / 2 - 5, 440 / 3, 60) then
					isBuyPanel = false;
				end
			end
		end
            
        if button == "backspace" and state then
            closeCarshop();
        elseif button == "q" and state then
            CameraMode = not CameraMode;
        end
    end
end);

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end
		
		if (not bgColor) then
			bgColor = borderColor;
		end
        
    dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
	end
end

function isInSlot(x, y, w, h)
    return exports.cr_core:isInSlot(x, y, w, h);
end
isCursorHover = isInSlot

function closeCarshop()
    if isElement(vehicle) then destroyElement(vehicle); end
    setElementFrozen(localPlayer, false);
    setCameraTarget(localPlayer);
    showCursor(false);
    showChat(true);
    setElementData(localPlayer, "hudVisible", true);
    setElementData(localPlayer, "script >> visible", true);
    setElementData(localPlayer, "inCarshop", false);
    show = false;
    CameraMode = false;
    countedModels = {};
    components = {};
    selectedVehicle = 1;
    selectedCarshop = 0;
    cameraStatus = 270;
    cameraHeight = 1;
    cameraZoom = 0;
    mouse = false;
    vehicle = nil;
    isBuyPanel = false;
end

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function cameraUpdate(stats, weight, zoom)
	local r = getElementRotation(vehicle);
	local rX, rY, rZ = getElementPosition(vehicle);
	local rotation = math.min(stats, stats)+90;
    
	local urX = rX + ((math.cos(math.rad(r+rotation))) * (9 + zoom));
	local urY = rY + ((math.sin(math.rad(r+rotation))) * (9 + zoom));
        
	setCameraMatrix(urX, urY, rZ+weight, rX, rY, rZ);
end

function updateColor(red, green, blue)
    r, g, b = hsv2rgb(red, green or 1, blue or 1);
    
    return r, g, b;
end

function hsv2rgb(h, s, v)
  local r, g, b
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
  local switch = i % 6
  if switch == 0 then
    r = v g = t b = p
  elseif switch == 1 then
    r = q g = v b = p
  elseif switch == 2 then
    r = p g = v b = t
  elseif switch == 3 then
    r = p g = q b = v
  elseif switch == 4 then
    r = t g = p b = v
  elseif switch == 5 then
    r = v g = p b = q
  end
  return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

function rgb2hsv(r, g, b)
  r, g, b = r/255, g/255, b/255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s 
  local v = max
  local d = max - min
  s = max == 0 and 0 or d/max
  if max == min then 
    h = 0
  elseif max == r then 
    h = (g - b) / d + (g < b and 6 or 0)
  elseif max == g then 
    h = (b - r) / d + 2
  elseif max == b then 
    h = (r - g) / d + 4
  end
  h = h/6
  return h, s, v
end

function isPointerHover(startX, startY, sizeX, sizeY)
    local cursorPosition = {x = screenW / 2, y = screenH / 2}

    if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
        return true
    else
        return false
    end
end
