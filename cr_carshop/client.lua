addEventHandler("onClientResourceStart", resourceRoot, function()
    setCameraTarget(localPlayer);
    showCursor(false);
    showChat(true);
    setElementData(localPlayer, "hudVisible", true);
    setElementData(localPlayer, "script >> visible", true);
    setElementData(localPlayer, "inCarshop", false);
    --setElementData(localPlayer, "animate", true);
end);

addEvent("client->getModelCount", true);
addEventHandler("client->getModelCount", getRootElement(), function(data)
    setElementFrozen(localPlayer, true);

    showCursor(false);
    showChat(false);
    setElementData(localPlayer, "hudVisible", false);
    setElementData(localPlayer, "script >> visible", false);
    setElementData(localPlayer, "animate", false);
    setElementData(localPlayer, "inCarshop", true);
    
    countedModels = data;
    show = true;
    addEventHandler("onClientRender", getRootElement(), renderCarshopPanel);
    
    if not vehicle then
        vehicle = createVehicle(shopDatas[selectedCarshop]["Vehicles"][2], unpack(shopDatas[selectedCarshop]["Vehicle_pos"]));
        if vehicle then
            setTimer(setElementFrozen, 1000, 1, vehicle, true);
            setCameraTarget(vehicle);

            cameraUpdate(270, 1, 0);

            setTimer(function()
                selectedColor = math.random(1, 255);
                color = (255-selectedColor)/255;
                local r, g, b = updateColor(color);
                oldR, oldG, oldB = r, g, b;
                setVehicleColor(vehicle, r, g, b);
            end, 50, 1);
        end
    end
end);

local lastInteraction = 0;

function renderCarshopPanel()
    if show then
        
        fonts["Roboto-10"] = exports['cr_fonts']:getFont("Roboto", 10) --dxCreateFont("files/Roboto.ttf", 10);
        fonts["Roboto-11"] = exports['cr_fonts']:getFont("Roboto", 11) --dxCreateFont("files/Roboto.ttf", 11);
        fonts["Roboto-13"] = exports['cr_fonts']:getFont("Roboto", 13) --dxCreateFont("files/Roboto.ttf", 13);
        fonts["Roboto-14"] = exports['cr_fonts']:getFont("Roboto", 14) --dxCreateFont("files/Roboto.ttf", 14);
        
        local multiplier = 3;
        local update = false;
        
        if CameraMode then
            dxDrawImage(screenW/2 - 25, screenH/2 - 25, 50, 50, "files/circle.png");
            
            if cameraZoom < 0 then
                for i, k in pairs(components) do
                    local cx, cy, cz = getVehicleComponentPosition(vehicle, i, "world");
                    if cx then
                        local ex, ey = getScreenFromWorldPosition(cx, cy, cz);
                        local cameraX, cameraY, cameraZ = getCameraMatrix();
                        local dist = math.sqrt((cameraX - cx) ^ 2 + (cameraY - cy) ^ 2 + (cameraZ - cz) ^ 2);
                        local size = 0.40 + (15 - dist) * 0.02;
                        local width, height = 30, 30
                        local dx, dy = ex - 15, (ey - 10) - 15 * size;

                        dxDrawImage(dx, dy, width, height, "files/circle.png");

                        if isPointerHover(dx, dy, width, height) then
                            dxDrawImage(dx, dy, width, height, "files/circle2.png");
                        end
                    end
                end
            end
            
            if getKeyState("lshift") or getKeyState("rshift") then
                multiplier = 5;
            elseif getKeyState("lctrl") or getKeyState("rctrl") then
                multiplier = 0.5;
            end
            
			if getKeyState("d") then
				if cameraStatus < 360 then
					cameraStatus = cameraStatus + 0.5*multiplier;
				else
					cameraStatus = 0;
				end
                
                update = true;
			end
            
			if getKeyState("a") then
				if cameraStatus > 0 then
					cameraStatus = cameraStatus - 0.5*multiplier	;			
				else
					cameraStatus = 360;
				end
                
                update = true;
			end
            
			if getKeyState("w") then
				if cameraHeight < 4 then
					cameraHeight = cameraHeight + 0.01*multiplier;
				else
					cameraHeight = 4;
				end
                
                update = true;
			end
            
			if getKeyState("s") then
				if cameraHeight > 0 then
					cameraHeight = cameraHeight - 0.01*multiplier;
				else
					cameraHeight = 0;
				end
                
                update = true;
			end
            
            if update then
                cameraUpdate(cameraStatus, cameraHeight, cameraZoom);
            end
        else
            local model = shopDatas[selectedCarshop]["Vehicles"][selectedVehicle] or 411;

            if isBuyPanel then
                roundedRectangle(screenW / 2 - 240, screenH / 2 - 70, 480, 140, tocolor(0, 0, 0, 150));

                dxDrawText("Biztos megveszed a " .. exports.cr_vehicle:getVehicleName(model) .. " járművet?", 0, screenH / 2 - 70, screenW, 0, tocolor(255, 255, 255), 1, fonts["Roboto-14"], "center")
            
                dxDrawButton(screenW / 2 - 230, screenH / 2 - 5, 440 / 3, 60, tocolor(255, 153, 51, 180), "Megvétel", "Megvétel\n$" .. vehicleDatas[model][1], fonts["Roboto-10"]);
            
                dxDrawButton(screenW / 2 - 230 + 440 / 3 + 10, screenH / 2 - 5, 440 / 3, 60, tocolor(74, 158, 222, 180), "Megvétel", "Megvétel\n" .. vehicleDatas[model][2] .. " pp", fonts["Roboto-10"]);

                dxDrawButton(screenW / 2 - 230 + 2 * (440 / 3 + 10), screenH / 2 - 5, 440 / 3, 60, tocolor(243, 85, 85, 180), "Mégse", "Mégse", fonts["Roboto-10"]);
            else                
                roundedRectangle(20, 15, 450 - 30 + 12.5, 52, tocolor(0, 0, 0, 150));
                
                --dxDrawText(exports.cr_vehicle:getVehicleName(model), screenW - (450 - 45) - 20, 15, screenW - (450 - 45) - 20 + 450 - 45, 15 + 30, tocolor(255, 255, 255, 255), 1, fonts["Roboto-11"], "center", "center", false, false, false, true)
                
                --dxDrawText("R: "..oldR.." G: "..oldG.." B: "..oldB.." | ("..RGBToHex(oldR, oldG, oldB)..")", 20, 10, 20 + 450 - 30 + 12.5, 10 + 72, tocolor(255, 255, 255), 1, fonts["Roboto-10"], "center", "bottom");
                
                for i=1, 450 - 30 do
                    dxDrawRectangle(25 + i, 25, 1, 32, (i >= 1 and i < 5) and tocolor(0, 0, 0, 255) or ((i > 450 - 35 and i <= 450 - 30) and tocolor(255, 255, 255, 255) or tocolor(updateColor((255-i)/255, 1, 1, 200))));
                end

                if selectedColor ~= 0 then
                    dxDrawImage(lastX + selectedColor - 4.25, 25 - 9, 16, 48, "files/h.png");
                else
                    dxDrawImage(lastX - 4.25, 25 - 9, 16, 48, "files/h.png");
                end
                
                roundedRectangle(screenW/2 - (525 + 12.5)/2, screenH - 125 - 75, 525 + 12.5, 125, tocolor(0, 0, 0, 150));
                roundedRectangle(screenW/2 - (525 + 12.5)/2, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4, (isInSlot(screenW/2 - (525 + 12.5)/2, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4) and tocolor(0, 255, 0, 200) or tocolor(0, 255, 0, 150)));
                roundedRectangle(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - (525 + 12.5)/4.5, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4, (isInSlot(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - (525 + 12.5)/4.5, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4) and tocolor(255, 0, 0, 200) or tocolor(255, 0, 0, 150)));
                
                
                dxDrawText(exports.cr_vehicle:getVehicleName(model), screenW/2 - (525 + 12.5)/2, screenH - 125 - 75 + 135, screenW/2 - (525 + 12.5)/2 + 525 + 12.5, screenH - 125 - 75 + 135 + 125/4, tocolor(255, 255, 255, 255), 1, fonts["Roboto-14"], "center", "center");
                dxDrawText("Vásárlás", screenW/2 - (525 + 12.5)/2, screenH - 125 - 75 + 135, screenW/2 - (525 + 12.5)/2 + (525 + 12.5)/4.5, screenH - 125 - 75 + 135 + 125/4, tocolor(255, 255, 255, 255), 1, fonts["Roboto-13"], "center", "center");
                dxDrawText("Kilépés", screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - (525 + 12.5)/4.5, screenH - 125 - 75 + 135, screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - (525 + 12.5)/4.5 + (525 + 12.5)/4.5, screenH - 125 - 75 + 135 + 125/4, tocolor(255, 255, 255, 255), 1, fonts["Roboto-13"], "center", "center");
                
                dxDrawImage(screenW/2 - (525 + 12.5)/2 - 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1, "files/left.png", 0, 0, 0, (isInSlot(screenW/2 - (525 + 12.5)/2 - 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1) and tocolor(0, 255, 0, 150) or tocolor(255, 255, 255, 255)));
                dxDrawImage(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - 512*0.1 + 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1, "files/right.png", 0, 0, 0, (isInSlot(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - 512*0.1 + 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1) and tocolor(0, 255, 0, 150) or tocolor(255, 255, 255, 255)));
                
                if getKeyState("mouse1") then
                    if isInSlot(screenW/2 - (525 + 12.5)/2 - 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1) then
                        if getTickCount() - lastInteraction > 250 then
                            selectedVehicle = shopDatas[selectedCarshop]["Vehicles"][selectedVehicle - 1] and selectedVehicle - 1 or 1;
                            lastInteraction = getTickCount();
                            updateModel();
                        end
                    elseif isInSlot(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - 512*0.1 + 75, screenH - 125 - 75 + 125/2 - (512*0.1)/2, 512*0.1, 512*0.1) then
                        if getTickCount() - lastInteraction > 250 then
                            selectedVehicle = shopDatas[selectedCarshop]["Vehicles"][selectedVehicle + 1] and selectedVehicle + 1 or 1;
                            lastInteraction = getTickCount();
                            updateModel();
                        end
                    elseif isInSlot(screenW/2 - (525 + 12.5)/2 + 525 + 12.5 - (525 + 12.5)/4.5, screenH - 125 - 75 + 135, (525 + 12.5)/4.5, 125/4) then
                        closeCarshop();
                    end
                end
                
                if getKeyState("arrow_l") then
                    if getTickCount() - lastInteraction > 250 then
                        selectedVehicle = shopDatas[selectedCarshop]["Vehicles"][selectedVehicle - 1] and selectedVehicle - 1 or 1;
                        lastInteraction = getTickCount();
                        updateModel();
                    end
                elseif getKeyState("arrow_r") then
                    if getTickCount() - lastInteraction > 250 then
                        selectedVehicle = shopDatas[selectedCarshop]["Vehicles"][selectedVehicle + 1] and selectedVehicle + 1 or 1;
                        lastInteraction = getTickCount();
                        updateModel();
                    end
                end
            end
        end
    end
end

function updateModel()
    setElementFrozen(vehicle, false);
    setElementModel(vehicle, shopDatas[selectedCarshop]["Vehicles"][selectedVehicle]);
    
    for i, k in pairs(components) do
        local cx, cy, cz = getVehicleComponentPosition(vehicle, i, "world");
        if cx then
            setVehicleDoorOpenRatio(vehicle, k[2], 0, 0);
        end
    end
    
    setTimer(setElementFrozen, 1000, 1, vehicle, true);
end

bindKey("mouse_wheel_up", "down", function()
    if CameraMode then
        if cameraZoom <= (-4 - 0.5) then
            cameraZoom = -4;
        else
            cameraZoom = cameraZoom - 0.5;
        end
            
        if cameraZoom < -4 then
            cameraZoom = -4;
        end
            
        cameraUpdate(cameraStatus, cameraHeight, cameraZoom);
    end
end);

bindKey("mouse_wheel_down", "down", function()
    if CameraMode then
        if cameraZoom <= (0 + 0.5) then
            cameraZoom = cameraZoom + 0.5;
        else
            cameraZoom = 0;
        end
        
        if cameraZoom > 0 then
            cameraZoom = 0;
        end
        
        cameraUpdate(cameraStatus, cameraHeight, cameraZoom);
    end
end);

addEventHandler("onClientCursorMove", getRootElement(), function(_, _, x, y)
    if not show or not mouse then return end
        
    if x > 22.5 and x < 430 + 15 then
        if getKeyState("mouse1") then
            selectedColor = 0;
            color = (255-(x - 22.5))/255;
                
            local r, g, b = updateColor(color);
             
            i = x - 22.5;
            if i >= 0 and i < 5 then
                r, g, b = 0, 0, 0;
            elseif i > 450 - 35 and i <= 430 + 15 then
                r, g, b = 255, 255, 255;        
            end
                
            if oldR ~= r or oldG ~= g or oldB ~= b then
                setVehicleColor(vehicle, r, g, b);
                oldR, oldG, oldB = r, g, b;
                lastX = x;
            end
        end
    end
end)

function dxDrawButton(left, top, width, height, color, title, hovertitle, font)
    roundedRectangle(left, top, width, height, color);

    if isCursorHover(left, top, width, height) then
        dxDrawText(hovertitle, left, top, left + width, top + height, tocolor(0, 0, 0), 1, font, "center", "center");
    else
        dxDrawText(title, left, top, left + width, top + height, tocolor(255, 255, 255), 1, font, "center", "center");
    end
end