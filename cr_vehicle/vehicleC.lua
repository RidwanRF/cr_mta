white = "#ffffff";

local oldx, oldy, oldz = 0, 0, 0;
local oldOdometerFloor = 0;

local windowState = false;
sx, sy = guiGetScreenSize();

local stats = {};

-- addEventHandler("onClientElementDataChange", resourceRoot, function(dName)
    -- if dName == "acc >> id" and getElementData(source, dName) then
		-- outputChatBox("Ha látod ezt szóljál!")
		-- triggerServerEvent("server->loadPlayerVehicles", localPlayer, getElementData(localPlayer, "acc >> id"));
    -- end
-- end)

addEvent("onClientVehicleLoad", true);

addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then
        if getElementData(source, "veh >> id") then
            for i = 2, 5 do
                local state = getElementData(source, "veh >> window"..i.."State");
                setVehicleWindowOpen(source, i, state);
            end

            local value = getElementData(source, "veh >> engine");
            setVehicleEngineState(source, value);
        end
    end
end);

addEventHandler("onClientElementDataChange", localPlayer, function(dName)
    local value = getElementData(source, dName)
    if dName == "inDeath" then
        if value then
            if isElement(beltSound) then
                destroyElement(beltSound);
            end
                
            if windowState then
                removeEventHandler("onClientRender", root, drawnWindowPanel);
                windowState = false;
            end
                
            if doorState then
                removeEventHandler("onClientRender", root, drawnDoorPanel);
                doorState = false;
            end
        end
    end
end);

addEventHandler("onClientElementDataChange", root, function(dName)
    if getElementType(source) == "vehicle" and isElementStreamedIn(source) then
        local value = getElementData(source, dName)
        if dName == "veh >> engineBroken" then
            if value then
                local veh = getPedOccupiedVehicle(localPlayer);
                if veh then
                    if disabledType[getVehicleType(veh)] then return; end
                        
                    if veh == source then
                        exports['cr_infobox']:addBox("error", "A járműved motorja súlyos károkat szenvedett ezért lerobbant!");
                    end
                end
            end
        elseif dName == "veh >> fuel" then
            if value <= 0 then
                local veh = getPedOccupiedVehicle(localPlayer);
                if veh then
                    if veh == source then
                        exports['cr_infobox']:addBox("error", "Kifogyott az üzemanyag a járművedből!");
                            
                        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                            if getElementData(source, "veh >> engine") then
                                setElementData(source, "veh >> engine", false);
                            end
                                
                            if getVehicleEngineState(source) then
                                setVehicleEngineState(source, false);
                            end
                        end
                    end
                end
            end
        elseif dName == "veh >> odometer" then
            if getElementData(source, "veh >> fueltype") ~= getElementData(source, "veh >> oldfueltype") then
                if value >= (getElementData(source, "veh >> mennyitmehetmax") or 0) then
                    local veh = getPedOccupiedVehicle(localPlayer);
                    if veh == source then
                        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                            exports['cr_infobox']:addBox("error", "Rossz üzemanyag lett tankolva a járműbe, ezért a motor tönkrement!");
                                
                            if getElementData(source, "veh >> engine") then
                                setElementData(source, "veh >> engine", false);
                            end
                                
                            if getVehicleEngineState(source) then
                                setVehicleEngineState(source, false);
                            end
                        end
                    end
                end
            end
        elseif dName == "veh >> engine" then
            setVehicleEngineState(source, value);
        elseif utfSub(dName, 1, 13) == "veh >> window" and utfSub(dName, 1, 14) ~= "veh >> windowS" and #dName > 13 then
            local num = tonumber(utfSub(dName, 14, 14));
            if num then
                local window = true;
                setVehicleWindowOpen(source, num, value);
                    
                for i = 2, 5 do
                    local state = getElementData(source, "veh >> window"..i.."State");
                    if state then
                        window = false;
                        break;
                    end
                end
                    
                setElementData(source, "veh >> windowState", window);
            end
        elseif dName == "veh >> fueltype" then
            value = math.random(1,10);
            setElementData(source, "fuel >> mennyitmehetmax", getElementData(source, "veh >> odometer") + value);
        elseif dName == "veh >> locked" then
            local sourceElement = getElementData(source, "veh >> lockSource");
            local veh = source;
            if sourceElement then
                veh = getPedOccupiedVehicle(sourceElement);
            end
                
            if veh and veh == source then
                local veh2 = getPedOccupiedVehicle(localPlayer);
                if veh2 and veh == veh2 then
                    if disabledType[getVehicleType(veh)] then return; end
                        
                    playSound("files/sounds/lockin.mp3");
                end
            else
                if disabledType[getVehicleType(source)] then return; end
                    
                local x,y,z = getElementPosition(source);
                local sound = playSound3D("files/sounds/lock.mp3", x, y, z);
                setSoundMaxDistance(sound, 50);
                setElementDimension(sound, getElementDimension(source));
            end
        end
	elseif(getElementType(source) == "player" and source == localPlayer) then
		if(dName == "acc >> id" and getElementData(source, dName)) then
			triggerServerEvent("server->loadPlayerVehicles", resourceRoot, localPlayer:getData("acc >> id"))
		end
    end
end);

addEventHandler("onClientVehicleStartEnter", root, function(player, seat, door)
    if player == localPlayer then
        if getElementAlpha(source) ~= 255 then
            cancelEvent();
            return;
        end

        setElementData(localPlayer, "char >> belt", false);
            
        if not getElementData(source, "veh >> id") then
            cancelEvent();
            return;
        end

        if getElementData(source, "veh >> id") < 0 then
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") then return; end
                
            if getElementData(source, "veh >> owner") ~= getElementData(localPlayer, "acc >> id") and seat == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                local green = exports['cr_core']:getServerColor("orange", true);
                outputChatBox(syntax .. "Ez nem a te ideiglenes járműved!",255,255,255,true);
                cancelEvent();
                return;
            end
        end

        if getVehicleController(source) and seat == 0 or getVehicleController(source) and door == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error");
            local green = exports['cr_core']:getServerColor("orange", true);
            outputChatBox(syntax .. "Ez nonrp-s kocsi lopás! Használd a "..green.."/kiszed [ID]"..white.." parancsot!",255,255,255,true);
            cancelEvent();
            return;
        end

        if getElementData(source, "veh >> locked") then
            local doorO = getVehicleDoorOpenRatio(source, seat + 2);
            if doorO > 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                outputChatBox(syntax .. "A jármű zárva van!",255,255,255,true);
                cancelEvent();
                return;
            end
        end

        if getVehicleType(source) == "BMX" or getVehicleType(source) == "Bike" or getVehicleType(source) == "Quad" then
            if getElementData(source, "veh >> locked") then
                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                outputChatBox(syntax .. "A jármű zárva van!",255,255,255,true);
                cancelEvent();
                return;
            end
        end
    end
end);

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function()
    local veh = getPedOccupiedVehicle(localPlayer);
    local value = getElementData(veh, "veh >> engine");
    local newOdometer = getElementData(veh, "veh >> odometer") or 0;
        
    setVehicleEngineState(veh, value);
        
    setElementData(localPlayer, "oldVehicle", getElementData(veh, "veh >> id"));
        
    oldx, oldy, oldz = getElementPosition(veh);
    
    oldOdometerFloor = math.floor(newOdometer);
        
    if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
        local breaked = false;
        local occupants = getVehicleOccupants(veh);
            
        for k,v in pairs(occupants) do
            if not getElementData(v, "char >> belt") and getElementData(veh, "veh >> engine") then
                 breaked = true;
            end
        end
            
        if breaked then
            setBeltSound(veh);
        else
            setBeltSound(veh);
        end
    end
    if getPedOccupiedVehicleSeat(localPlayer) == 0 then
        local syntax = exports['cr_core']:getServerSyntax(false, "info");
        outputChatBox(syntax .. "#FFFFFFA jármű beindításához nyomd hosszan a #E34F4F[J] #FFFFFF+ #E34F4F[SPACE] #FFFFFFbillentyűt! ",255,255,255,true);
        outputChatBox(syntax .. "#FFFFFFA biztonsági öv becsatolásához nyomd meg az  #E34F4F[F5] #FFFFFFbillentyűt!",255,255,255,true);
        outputChatBox(syntax .. "#FFFFFFAz ablakokat kezelni az #E34F4F[F1] #FFFFFFés #E34F4F[F2] #ffffffgombokkal tudod!",255,255,255,true);

        if disabledType[getVehicleType(veh)] then
            setElementData(veh, "veh >> engine", false);
            setElementData(veh, "veh >> engine", true);
        end
    end
end);

addEventHandler("onClientPlayerVehicleEnter", root, function()
    if source ~= localPlayer then
        local veh = getPedOccupiedVehicle(source);
        local veh2 = getPedOccupiedVehicle(localPlayer);

        local value = getElementData(veh, "veh >> engine");
        setVehicleEngineState(veh, value);

        if veh2 and veh == veh2 then
            if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck"  then
                local breaked = false;
                local occupants = getVehicleOccupants(veh);

                for k,v in pairs(occupants) do
                    if not getElementData(v, "char >> belt") and getElementData(veh, "veh >> engine") then
                         breaked = true;
                    end
                end

                if breaked and getElementData(veh, "veh >> engine") then
                    setBeltSound(veh);
                else
                    setBeltSound(veh);
                end
            end 
        end
    end
end);

addEventHandler("onClientPlayerVehicleExit", root, function(veh, seat)
    if source ~= localPlayer then
        local value = getElementData(veh, "veh >> engine");
        local veh2 = getPedOccupiedVehicle(localPlayer);
        setVehicleEngineState(veh, value);
        
        if veh2 and veh == veh2 then
            if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck"  then
                local breaked = false;
                local occupants = getVehicleOccupants(veh);
                    
                for k,v in pairs(occupants) do
                    if v ~= source then
                        if not getElementData(v, "char >> belt") then
                            breaked = true;
                        end
                    end
                end
                    
                if breaked then
                    if hasBelt[getElementModel(veh)] then
                        if not isElement(beltSound) then
                            beltSound = playSound("files/sounds/belt.mp3", true);
                        end
                    end
                else
                    if isElement(beltSound) then
                        destroyElement(beltSound);
                    end 
                end
            end
        end
    elseif source == localPlayer then
        if isElement(beltSound) then
            destroyElement(beltSound);
        end
            
        if windowState then
            removeEventHandler("onClientRender", root, drawnWindowPanel);
            windowState = false;
        end
            
        if doorState then
            removeEventHandler("onClientRender", root, drawnDoorPanel);
            doorState = false;
        end
    end
end);

addCommandHandler("thiscar", function(cmd)
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        local id = getElementData(veh, "veh >> id");
        local green = exports['cr_core']:getServerColor("orange", true);
        local syntax = exports['cr_core']:getServerSyntax(false, "success");
        outputChatBox(syntax .. "Jármű ID: "..green..id,255,255,255,true);
    else
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. "Nem tartózkodsz járműben!",255,255,255,true);
    end
end);

addCommandHandler("oldcar", function(cmd)
    local veh = getElementData(localPlayer, "oldVehicle");
    if veh then
        local id = veh;
        local green = exports['cr_core']:getServerColor("orange", true);
        local syntax = exports['cr_core']:getServerSyntax(false, "success");
        outputChatBox(syntax .. "Jármű ID: "..green..id,255,255,255,true);
    else
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. "Mióta felcsatlakoztál a szerverre még nem szálltál járműbe!",255,255,255,true);
    end
end);

function setElementHealthDriving(e, h, l)
    if e == localPlayer then
        setElementHealth(e, h);
        
        if l > 3 then
            triggerEvent("onDamage", localPlayer);
        end
    else
        triggerServerEvent("setElementHealthDriving", localPlayer, e, h, l);
    end
end

addEventHandler("onClientVehicleDamage", root, function(attacker, weapon, loss)
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        if veh == source then
            local seat = getPedOccupiedVehicleSeat(localPlayer);
            if seat == 0 then
                if not attacker and not weapon then
                    local occupants = getVehicleOccupants(veh);
                        
                    for k,v in pairs(occupants) do
                        if not getElementData(v, "char >> belt") then
                            local oldHealth = getElementHealth(v);
                            local newHealth = oldHealth - loss/(math.random(8, 10));
                            setElementHealthDriving(v, newHealth, loss);
                        else
                            local oldHealth = getElementHealth(v);
                            local newHealth = oldHealth - loss/(math.random(10, 12));
                            setElementHealthDriving(v, newHealth, loss);
                        end
                    end
                end
            end
        end
    end

    if getElementData(source, "veh >> engineBroken") then
        if getElementData(source, "veh >> engine") then
            setElementData(source, "veh >> engine", false);
        end
            
        if getVehicleEngineState(source) then
            setVehicleEngineState(source, false);
        end
            
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        cancelEvent();
        return;
    end

    if getElementHealth(source) <= 300 then
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        if not getElementData(source, "veh >> engineBroken") then
            setElementData(source, "veh >> engineBroken", true);
                
            if getElementData(source, "veh >> engine") then
                setElementData(source, "veh >> engine", false);
            end
            if getVehicleEngineState(source) then
                setVehicleEngineState(source, false);
            end
        end
            
        cancelEvent();
        return;
    end
end);

setTimer(function()
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 and not disabledType[getVehicleType(veh)] then
        if getElementHealth(veh) <= 300 then
            setElementHealth(veh, 300);
            cancelEvent();
                
            if not getElementData(veh, "veh >> engineBroken") then
                setElementData(veh, "veh >> engineBroken", true);
                    
                if getElementData(veh, "veh >> engine") then
                    setElementData(veh, "veh >> engine", false);
                end
                    
                if getVehicleEngineState(veh) then
                    setVehicleEngineState(veh, false);
                end
            end
        elseif getElementHealth(veh) > 300 then
            if getVehicleType(veh) ~= "BMX" then
                local lastOilRecoil = getElementData(veh, "veh >> lastOilRecoil");
                local odometer = getElementData(veh, "veh >> odometer");
                if lastOilRecoil + 1000 > odometer then
                    if getElementData(veh, "veh >> engineBroken") then
                        setElementData(veh, "veh >> engineBroken", false);
                    end
                end
            else
                if getElementData(veh, "veh >> engineBroken") then
                    setElementData(veh, "veh >> engineBroken", false);
                end
            end
        end
    end
end, 2000, 0);

setTimer(function()
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        local seat = getPedOccupiedVehicleSeat(localPlayer);
        if getElementHealth(veh) > 300 and seat == 0 and not disabledType[getVehicleType(veh)] then
            if getElementData(veh, "veh >> engine") then
                local newx, newy, newz = getElementPosition(veh);
                local addKM = getDistanceBetweenPoints3D(oldx, oldy, oldz, newx, newy, newz) / 500;
                local oldOdometer = getElementData(veh, "veh >> odometer") or 0;
                oldx, oldy, oldz = newx, newy, newz;
                if addKM * 250 > 1 then
                    setElementData(veh, "veh >> odometer", oldOdometer + addKM);
                    if getVehicleType(veh) ~= "BMX" then
                        local newOdometer = getElementData(veh, "veh >> odometer");
                        if math.floor(newOdometer) > oldOdometerFloor then
                            local oldFuel = getElementData(veh, "veh >> fuel");
                            oldFuel = oldFuel - kmMultipler[getElementModel(veh)];
                                
                            if oldFuel <= 0 then
                                if getElementData(veh, "veh >> engine") then
                                    setElementData(veh, "veh >> engine", false);
                                end
                                if getVehicleEngineState(veh) then
                                    setVehicleEngineState(veh, false);
                                end
                            end
                            setElementData(veh, "veh >> fuel", oldFuel);
                            oldOdometerFloor = math.floor(newOdometer);
                        end
                    end
                    if getVehicleType(veh) ~= "BMX" then
                        local oldOilRecoil = getElementData(veh, "veh >> lastOilRecoil") or 0;
                        if oldOdometer + addKM >= oldOilRecoil + 1000 then
                            if not getElementData(veh, "veh >> engineBroken") then
                                setElementData(veh, "veh >> engineBroken", true);
                            end
                                
                            if getElementData(veh, "veh >> engine") then
                                setElementData(veh, "veh >> engine", false);
                            end
                                
                            exports['cr_infobox']:addBox("error", "Mivel túl rég cseréltél motorolajat, a kocsid lefulladt!");
                                
                            if getVehicleEngineState(veh) then
                                setVehicleEngineState(veh, false);
                            end
                        end
                    end
                end
            end
        end
    end
end, 500, 0);

addEventHandler("onClientResourceStart", resourceRoot, function()
    local texture = dxCreateTexture("files/plate.png", "dxt5");
    local shader = dxCreateShader("files/texture.fx");
    dxSetShaderValue(shader, "gTexture", texture);
    engineApplyShaderToWorldTexture(shader, "plateback3");
    engineApplyShaderToWorldTexture(shader, "plateback2");
    engineApplyShaderToWorldTexture(shader, "plateback1");
end);

local maxDistance = 26;
local font = dxCreateFont("files/fonts/roboto.black.ttf", 18);

function jsonGET(file)
    local fileHandle;
    local jsonDATA = {};
    
    if not fileExists(file) then
        fileHandle = fileCreate(file);
        fileWrite(fileHandle, toJSON({["disabled"] = false}));
        fileClose(fileHandle);
        fileHandle = fileOpen(file);
    else
        fileHandle = fileOpen(file);
    end
    
    if fileHandle then
        local buffer;
        local allBuffer = "";
        
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500);
            allBuffer = allBuffer..buffer;
        end
        
        jsonDATA = fromJSON(allBuffer);
        fileClose(fileHandle);
    end
    
    return jsonDATA;
end

function jsonGETT(file)
    local fileHandle;
    local jsonDATA = {};
    
    if not fileExists(file) then
        fileHandle = fileCreate(file);
        fileWrite(fileHandle, toJSON({["x"] = sx/2, ["y"] = sy/2}));
        fileClose(fileHandle);
        fileHandle = fileOpen(file);
    else
        fileHandle = fileOpen(file);
    end
    
    if fileHandle then
        local buffer;
        local allBuffer = "";
        
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500);
            allBuffer = allBuffer..buffer;
        end
        
        jsonDATA = fromJSON(allBuffer);
        fileClose(fileHandle);
    end
    
    return jsonDATA;
end
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file);
    end
    
    local fileHandle = fileCreate(file);
    fileWrite(fileHandle, toJSON(data));
    fileFlush(fileHandle);
    fileClose(fileHandle);
    
    return true;
end

local value = {};

addEventHandler("onClientResourceStart", resourceRoot, function()
    value = jsonGET("save.json");
        
    if not value["disabled"] then
        addEventHandler("onClientRender", root, renderVehiclePlate, true, "low-5");
    end
end);

addEventHandler("onClientResourceStop", resourceRoot, function()
    jsonSAVE("save.json", value);
end);

function togglePlate()
    value["disabled"] = not value["disabled"];
    if value["disabled"] then
        exports['cr_infobox']:addBox("error", "Sikeresen kikapcsoltad a rendszámok megjelenitését!");
        removeEventHandler("onClientRender", root, renderVehiclePlate);
    else
        exports['cr_infobox']:addBox("success", "Sikeresen bekapcsoltad a rendszámok megjelenitését!");
        addEventHandler("onClientRender", root, renderVehiclePlate, true, "low-5");
    end
end
bindKey("F10", "down", togglePlate);

function dxDrawRectangleBox(left, top, width, height)
    dxDrawRectangle(left, top, width, height, tocolor(0,0,0,160));
    dxDrawRectangle(left-1, top, 1, height, tocolor(0,0,0,220));
    dxDrawRectangle(left+width, top, 1, height, tocolor(0,0,0,220));
    dxDrawRectangle(left, top-1, width, 1, tocolor(0,0,0,220));
    dxDrawRectangle(left, top+height, width, 1, tocolor(0,0,0,220));
end

local renderCache = {}

setTimer(
    function()
        if (value and not value["disabled"]) or true then
            local cameraX, cameraY, cameraZ = getCameraMatrix();
            local dim2, int2 = getElementDimension(localPlayer), getElementInterior(localPlayer);
            renderCache = {}
            for k,element in pairs(getElementsByType("vehicle", root, true)) do
                if isElementStreamedIn(element) and isElementOnScreen(element) then
                    if getPedOccupiedVehicle(localPlayer) ~= element then
                        if not disabledType[getVehicleType(element)] then
                            local dim1 = getElementDimension(element);
                            local int1 = getElementInterior(element);
                            if getElementAlpha(element) == 255 and dim1 == dim2 and int1 == int2 then
                                local worldX, worldY, worldZ = getElementPosition(element);
                                local line = isLineOfSightClear(cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, false, false, true, false, false, false, localPlayer);

                                if line then
                                    local distance = math.sqrt((cameraX - worldX) ^ 2 + (cameraY - worldY) ^ 2 + (cameraZ - worldZ) ^ 2) - 3;
                                    if distance < 0.1 then
                                        distance = 0.1;
                                    end

                                    if getVehiclePlateText(element) and not element:getData("cloned") then
                                        --if distance <= maxDistance then
                                        local size = 1 - (distance / maxDistance);
                                        renderCache[element] = {
                                            ["vehID"] = getElementData(element, "veh >> id"),
                                            ["cloned"] = getElementData(element, "cloned"),
                                            ["distance"] = distance,
                                            ["plateText"] = getVehiclePlateText(element),
                                            ["length"] = dxGetTextWidth(getVehiclePlateText(element), size, font) + 15 * size,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end, 100, 0
)

function renderVehiclePlate()
    if not getElementData(localPlayer, "hudVisible") then return; end
    local cameraX, cameraY, cameraZ = getCameraMatrix();
    
    --local dim2, int2 = getElementDimension(localPlayer), getElementInterior(localPlayer);
    
    --local a = 0
    for element, value in pairs(renderCache) do
        --a = a +1
        local distance = value["distance"]
        if distance <= maxDistance then
            local boneX, boneY, boneZ = getElementPosition(element);
            local size = 1 - (distance / maxDistance);
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + (1.5));

            if screenX and screenY then
                local plateText = value["plateText"]
                local x = value["length"]
                local y = 25 * size;

                dxDrawRectangleBox(screenX - x/2, screenY - y / 2, x, y, tocolor(20,20,20,180));
                dxDrawText(plateText, screenX, screenY, screenX, screenY, tocolor(255,255,255,255), size, font, "center", "center");
            end
        end
    end
    --outputChatBox(a)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setElementData(localPlayer, "char >> belt", false);
end);

function toggleBelt()
    local veh = getPedOccupiedVehicle(localPlayer);
    
    if not veh then return; end

    if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
        if isTimer(spamTimerBelt) then return; end
        
        spamTimerBelt = setTimer(function() end, math.random(500,500), 1);
        
        local belt = getElementData(localPlayer, "char >> belt");
        local newBelt = not belt;
        
        setElementData(localPlayer, "char >> belt", not belt);
        
        if newBelt then
            exports['cr_chat']:createMessage(localPlayer, "becsatolja a biztonsági övét", 1);
            playSound("files/sounds/beltin.mp3");
            
            local breaked = false;
            local occupants = getVehicleOccupants(veh);
            
            for k,v in pairs(occupants) do
                if not getElementData(v, "char >> belt") then
                     breaked = true;
                end
            end
            
            if breaked then
                if hasBelt[getElementModel(veh)] then
                    if not isElement(beltSound) then
                        beltSound = playSound("files/sounds/belt.mp3", true);
                    end
                end
            else
                if isElement(beltSound) then
                    destroyElement(beltSound);
                end 
            end
        else
            exports['cr_chat']:createMessage(localPlayer, "kicsatolja a biztonsági övét", 1);
            playSound("files/sounds/beltout.mp3");
            
            local breaked = true;
            local occupants = getVehicleOccupants(veh);
            
            for k,v in pairs(occupants) do
                if getElementData(veh, "veh >> engine") then
                    if not getElementData(v, "char >> belt") then
                        breaked = true;
                    end
                end
            end
            
            if breaked then
                if hasBelt[getElementModel(veh)] then
                    if not isElement(beltSound) then
                        beltSound = playSound("files/sounds/belt.mp3", true);
                    end
                end
            else
                if isElement(beltSound) then
                    destroyElement(beltSound);
                end 
            end
        end
    end
end
bindKey("F5", "down", toggleBelt);

addEventHandler("onClientElementDataChange", root, function(dName)
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        if getElementType(source) == "player" and dName == "char >> belt" then
            local veh2 = getPedOccupiedVehicle(source);
            if veh == veh2 then
                local breaked = false;
                    
                local occupants = getVehicleOccupants(veh);
                for k,v in pairs(occupants) do
                    if not getElementData(v, "char >> belt") then
                         breaked = true;
                    end
                end
                    
                if breaked then
                    if hasBelt[getElementModel(veh)] then
                        if not isElement(beltSound) and getElementData(veh2, "veh >> engine") then
                            beltSound = playSound("files/sounds/belt.mp3", true);
                        end
                    end
                else
                    if isElement(beltSound) then
                        destroyElement(beltSound);
                    end 
                end
            end
        end
    end
end);

addEventHandler("onClientElementDestroy", root, function()
    if getElementType(source) == "vehicle" then
        local veh = getPedOccupiedVehicle(localPlayer);
        if veh == source then
            if isElement(beltSound) then
                destroyElement(beltSound);
            end
        end
    end
end);

function toggleWindow()
    local veh = getPedOccupiedVehicle(localPlayer);
    
    if veh then
        --if getVehicleType(veh) ~= "Automobile" then return; end
        if isTimer(spamTimerWindow) then return; end
        
        spamTimerWindow = setTimer(function() end, math.random(500,500), 1);
        
        if getElementData(localPlayer, "pulling") then 
            local syntax = exports['cr_core']:getServerSyntax(false, "error");
            outputChatBox(syntax .. "Pullozás közben nem húzhatod fel az ablakot!",255,255,255,true);
            return ;
        end
        
        local num = convert[getPedOccupiedVehicleSeat(localPlayer)];
        local convertSeatIntoName = {
            ["door_lf_dummy"] = true,
            ["door_rf_dummy"] = true,
            ["door_lr_dummy"] = true,
            ["door_rr_dummy"] = true,
        }
        local windowSeatName = convertSeatIntoName[getPedOccupiedVehicleSeat(localPlayer)]
        if windowSeatName and getVehicleComponentVisible(getPedOccupiedVehicle(localPlayer, windowSeatName)) then
            local windowState = getElementData(veh, "veh >> window"..num.."State");
            setElementData(veh, "veh >> window"..num.."State", not windowState);
            local newWindowState = windowState;

            local text = windowNames[num];
            playSound("files/sounds/window.mp3");
            if newWindowState then
                exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
            else
                exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
            end
        end
    end
end
bindKey("F2", "down", toggleWindow);

function toggleLight()
    local veh = getPedOccupiedVehicle(localPlayer)
    
    if disabledType[getVehicleType(veh)] then return; end
    
    if veh then
        if isTimer(spamTimerLight) then return; end
        
        spamTimerLight = setTimer(function() end, math.random(500,500), 1);
        
        if getElementData(veh, "index.left") or getElementData(veh, "index.right") then
            local syntax = exports['cr_core']:getServerSyntax(false, "error");
            outputChatBox(syntax .. "Indexelés közben nem tudod fel/lekapcsolni a fenyszórókat!",255,255,255,true);
            return;
        end
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local oldValue = getElementData(veh, "veh >> light");
            local newValue = not oldValue;
            setElementData(veh, "veh >> light", newValue);
            playSound("files/sounds/light.mp3");
            local vehicleName = getVehicleName(veh);
            if newValue then
                exports['cr_chat']:createMessage(localPlayer, "felkapcsolja egy jármű fényszóróit", 1);
            else
                exports['cr_chat']:createMessage(localPlayer, "lekapcsolja egy jármű fényszóróit", 1);
            end
        end
    end
end
bindKey("L", "down", toggleLight);

function toggleEngine()
    local veh = getPedOccupiedVehicle(localPlayer);
    if not veh then return; end
    if disabledType[getVehicleType(veh)] then return; end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return; end
        
    if getKeyState("J") then
		local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id"));
		if(exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") or veh:getData("veh >> job") and veh:getData("veh >> owner") == localPlayer:getData("acc >> id") or veh:getData("veh >> temporaryVehicle") and veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
			hasKey = true;
		end
		if(hasKey) then
			playSound("files/sounds/engine.mp3");
		end
            
        setTimer(function()
            if getKeyState("J") then
                local veh = getPedOccupiedVehicle(localPlayer);
                if veh then
                    if isTimer(spamTimerEngine) then return; end
                    spamTimerEngine = setTimer(function() end, math.random(500,500), 1);
                            
                    if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                        local oldValue = getElementData(veh, "veh >> engine");
                        local newValue = not oldValue;
                        if newValue then
                            -- if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then
                                -- hasKey = true;
                            -- end
                                    
                            -- if not hasKey then
                                -- if getElementData(veh, "veh >> id") < 0 then
                                    -- if getElementData(veh, "veh >> owner") == getElementData(localPlayer, "acc >> id") then
                                        -- hasKey = true;
                                    -- end
                                -- end
                            -- end
							
							if getElementData(veh, "veh >> engineBroken") then
                                local vehicleName = getVehicleName(veh);
                                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                exports['cr_chat']:createMessage(localPlayer, "beindítani egy "..vehicleName.." motorját", "try2 >> failed");
                                exports['cr_infobox']:addBox("error", "A jármű motorja túlságosan sérült!");
                                    
                                return;
                            elseif getElementData(veh, "veh >> fuel") <= 0 then
                                local vehicleName = getVehicleName(veh);
                                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                exports['cr_chat']:createMessage(localPlayer, "beindítani egy "..vehicleName.." motorját", "try2 >> failed");
                                exports['cr_infobox']:addBox("error", "Kifogyott az üzemenyanyag a járművedből!");
                                    
                                return;
							end
                                    
                            if hasKey then
                                if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleStart") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                                    local vehicleName = getVehicleName(veh);
                                    local syntax = exports['cr_admin']:getAdminSyntax();
                                    local green = exports['cr_core']:getServerColor("orange", true);
                                    local id = getElementData(veh, "veh >> id");
                                    local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                                    local time = getTime() .. " ";
                                    exports['cr_logs']:addLog("Admin", "VehicleStart", time .. aName .. " beindította a(z) "..id.." idjü ("..vehicleName..") motorját!");
                                end
                                        
                                if not (getElementData(veh, "veh >> engineBroken")) and (getElementData(veh, "veh >> fuel")) > 0 then
                                    local vehicleName = getVehicleName(veh);
                                    setElementData(veh, "veh >> engine", newValue);
                                    exports['cr_chat']:createMessage(localPlayer, "beindította egy "..vehicleName.." motorját", 1);
                                        
                                    return;
                                end 
                                        
                            else
								local vehicleName = getVehicleName(veh);
                                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                -- exports['cr_infobox']:addBox("error", "Kifogyott az üzemenyanyag a járművedből!");
								outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
								exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!");
							end
                        end
                    end
                end
            end    
        end, 1050, 1);
    end    
end
bindKey("space", "down", toggleEngine);

function toggleEngineDown()
    local veh = getPedOccupiedVehicle(localPlayer);
    
    if veh then
        if disabledType[getVehicleType(veh)] then return; end

        if isTimer(spamTimerEngine) then return; end
        spamTimerEngine = setTimer(function() end, math.random(500,500), 1);
        
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local oldValue = getElementData(veh, "veh >> engine");
            local newValue = not oldValue;
            
            if not newValue then
                local vehicleName = getVehicleName(veh);  
				exports['cr_chat']:createMessage(localPlayer, "leállította egy "..vehicleName.." motorját", 1);
                setElementData(veh, "veh >> engine", newValue);
                playSound("files/sounds/engineoff.mp3")
            end
        end
    end
end
bindKey("j", "down", toggleEngineDown);
local maxDistanceToOpen = 5;

function getNearbyVehicle(e)
    if e == localPlayer then
        local shortest = {5000, nil};
        local px,py,pz = getElementPosition(localPlayer);
        
        for k,v in pairs(getElementsByType("vehicle", root, true)) do
            local x,y,z = getElementPosition(v);
            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz);
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(v, "veh >> id")) or true;
            
            if not hasKey then
                if getElementData(v, "veh >> id") < 0 then
                    if getElementData(v, "veh >> owner") == getElementData(e, "acc >> id") then
                        hasKey = true;
                    end
                end
            end
            
            if getElementData(v, "veh >> forceToggleDoor") then
                hasKey = false;
            end
            
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then
                hasKey = true;
            end
            
            if dist < shortest[1] and dist < maxDistanceToOpen and hasKey then
                shortest = {dist, v};
            end
        end
        
        if not shortest[2] or shortest[2] and not isElement(shortest[2]) then
            return false;
        else
            return shortest[2];
        end
    end
end

function toggleLock()
    local veh = getPedOccupiedVehicle(localPlayer);
    if isTimer(spamTimerLock) then return; end
    spamTimerLock = setTimer(function() end, math.random(500,500), 1);
	
    local syntax = exports['cr_core']:getServerSyntax(false, "error");
	
    if veh then
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false;
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                hasKey = true
            end
            if getElementData(veh, "veh >> forceToggleDoor") then
                hasKey = false;
            end
            
            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked");
                local newValue = not oldValue;
                setElementData(veh, "veh >> lockSource", localPlayer);
                setElementData(veh, "veh >> locked", newValue);
                local vehicleName = getVehicleName(veh);
                
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1);
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " ";
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1);
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " ";
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                end
			else
				outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!");
            end
        else
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false;
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                hasKey = true
            end
            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked");
                local newValue = not oldValue;
                setElementData(veh, "veh >> lockSource", localPlayer);
                setElementData(veh, "veh >> locked", newValue);
                local vehicleName = getVehicleName(veh);
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1);
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " "
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1);
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " ";
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                end
            else
				outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!");
            end
        end
    else
        veh = getNearbyVehicle(localPlayer);
        
        if veh then
            local hasKey = exports['cr_inventory']:hasItem(localPlayer, keyItem, getElementData(veh, "veh >> id")) or false;
            if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                hasKey = true
            end
            if hasKey then
                local oldValue = getElementData(veh, "veh >> locked");
                local newValue = not oldValue;
                triggerServerEvent("onLock", localPlayer, veh);
                setElementData(veh, "veh >> lockSource", localPlayer);
                setElementData(veh, "veh >> locked", newValue);
                local vehicleName = getVehicleName(veh);
                
                if not newValue then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitotta egy "..vehicleName.." ajtaját", 1);
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " ";
                        
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " kinyitotta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárta egy "..vehicleName.." ajtaját", 1);
                    
                    if exports['cr_permission']:hasPermission(localPlayer, "forceVehicleOpen") and not exports['cr_core']:getPlayerDeveloper(localPlayer) or exports['cr_core']:getPlayerDeveloper(localPlayer) and getElementData(localPlayer, "admin >> duty") then 
                        local syntax = exports['cr_admin']:getAdminSyntax();
                        local green = exports['cr_core']:getServerColor("orange", true);
                        local id = getElementData(veh, "veh >> id");
                        local aName = exports['cr_admin']:getAdminName(localPlayer, true);
                        local time = getTime() .. " ";
                        
                        exports['cr_logs']:addLog("Admin", "VehicleOpen", time .. aName .. " bezárta a(z) "..id.." idjü ("..vehicleName..") jármű ajtaját!");
                    end
                end
            else
				--outputChatBox(syntax.."Nincs kulcsod a járműhöz!", 255, 255, 255, true)
				exports['cr_infobox']:addBox("error", "Nincs kulcsod a járműhöz!");
            end	
        end
    end
end
bindKey("K", "down", toggleLock);

local seatNames = {
    [0] = "door_lf_dummy",
    [1] = "door_rf_dummy",
    [2] = "door_lr_dummy",
    [3] = "door_rr_dummy",
}

function removePedFromVehicleFunc(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. " /"..cmd.." [target]", 255, 255, 255, true);
        
        return;
    end
    
    local target = exports['cr_core']:findPlayer(localPlayer, id);
    
    if target then
        if getElementData(target, "loggedIn") then
            local _target = target
            if target:getData("clone") then
                inspect(target:getData("clone"))
                target = target:getData("clone")
            end
            local veh = getPedOccupiedVehicle(target);
            
            if veh then
                
                local x,y,z = getElementPosition(target);
                local px,py,pz = getElementPosition(localPlayer);
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz);
                local dim1, dim2 = getElementDimension(localPlayer), getElementDimension(target);
                local int1, int2 = getElementInterior(localPlayer), getElementInterior(target);
                
                if dist < 4 and dim1 == dim2 and int1 == int2 then
                    local veh = getPedOccupiedVehicle(target);
                    if veh then
                        if not getElementData(veh, "veh >> locked") then
                            if not getElementData(target, "char >> belt") then
                                if target == localPlayer then
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                    local name = exports['cr_admin']:getAdminName(target);
                                    local green = exports['cr_core']:getServerColor("orange", true);
                                    outputChatBox(syntax .. "Saját magadat nem rángathatod ki!", 255,255,255,true);
                                    
                                    return;
                                end
                                
                                local name = exports['cr_admin']:getAdminName(_target);
                                exports['cr_chat']:createMessage(localPlayer, "kirángott valakit a gépjárműből ((" .. name .. "))", 1);
                                
                                local veh = getPedOccupiedVehicle(target)
                                local comPos = false
                                local seat = nil
                                if veh then
                                    seat = getPedOccupiedVehicleSeat(target)
                                    --triggerServerEvent("kickPlayerFromVeh", localPlayer, localPlayer)
                                    local name = seatNames[seat]
                                    local x,y,z = getVehicleComponentPosition(veh, name, "world")
                                    if x and y and z then
                                        comPos = {x,y,z}
                                    end
                                    
                                    if comPos then
                                        x,y,z = unpack(comPos)
                                    else
                                        if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Bike" then
                                            x,y,z = getElementPosition(veh)
                                            if seat == 0 then
                                                x = x + 0.5
                                                y = y + 0.5
                                            elseif seat == 1 then
                                                x = x - 0.5
                                                y = y - 0.5
                                            end
                                        else
                                            if getElementModel(veh) == 539 or getElementModel(veh) == 457 or getElementModel(veh) == 424 or getElementModel(veh) == 568 then
                                                if seat == 1 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x + 1
                                                    y = y + 1
                                                elseif seat == 0 then
                                                    x,y,z = getElementPosition(veh)
                                                    x = x - 1
                                                    y = y - 1
                                                end
                                            else
                                                x,y,z = getElementPosition(veh)
                                                x = x + 3
                                                y = y + 3
                                            end    
                                        end
                                    end
                                    z = z + 0.1
                                    
                                    comPos = {x,y,z}
                                end
                            
                                triggerServerEvent("kickPlayerFromVeh", localPlayer, target, comPos);
                                
                                return;
                            else
                                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                local name = exports['cr_admin']:getAdminName(target);
                                local green = exports['cr_core']:getServerColor("orange", true);
                                outputChatBox(syntax .. green .. name .. white .. " biztonsági öve be van csatolva!", 255,255,255,true);
                                
                                return;
                            end
                        else
                            local syntax = exports['cr_core']:getServerSyntax(false, "error");
                            outputChatBox(syntax .. "A jármű zárva van!", 255,255,255,true);
                            
                            return;
                        end
                    end
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                local name = exports['cr_admin']:getAdminName(target);
                local green = exports['cr_core']:getServerColor("orange", true);
                outputChatBox(syntax .. green .. name .. white .. " nincs járműben!", 255,255,255,true);
                
                return
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error");
            outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true);
        end
    end
end
addCommandHandler("kiszed", removePedFromVehicleFunc);

function destroyBeltPlayer(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. " /"..cmd.." [target]", 255, 255, 255, true);
        
        return;
    end
    
    local target = exports['cr_core']:findPlayer(localPlayer, id);
    
    if target then
        if getElementData(target, "loggedIn") then
            local _target = target
            if target:getData("clone") then
                target = target:getData("clone")
            end
            
            local veh = getPedOccupiedVehicle(target);
            
            if veh then
                
                local x,y,z = getElementPosition(target);
                local px,py,pz = getElementPosition(localPlayer);
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz);
                local dim1, dim2 = getElementDimension(localPlayer), getElementDimension(target);
                local int1, int2 = getElementInterior(localPlayer), getElementInterior(target);
                
                if dist < 4 and dim1 == dim2 and int1 == int2 then
                    local veh = getPedOccupiedVehicle(target);
                    if veh then
                        if not getElementData(veh, "veh >> locked") then
                            if getElementData(target, "char >> belt") then
                                local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 133)
                                if hasItem then
                                    if target == localPlayer then
                                        local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                        local name = exports['cr_admin']:getAdminName(target);
                                        local green = exports['cr_core']:getServerColor("orange", true);
                                        outputChatBox(syntax .. "Saját magad övét nem vághatod el!", 255,255,255,true);

                                        return;
                                    end

                                    if not target:getData("clone") then
                                        local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                        local name = exports['cr_admin']:getAdminName(target);
                                        local green = exports['cr_core']:getServerColor("orange", true);
                                        outputChatBox(syntax .. "A célpontnak halottnak kell lennie!", 255,255,255,true);

                                        return;
                                    end

                                    local name = exports['cr_admin']:getAdminName(target);
                                    exports['cr_chat']:createMessage(localPlayer, "elvágja valaki övét ((" .. name .. "))", 1);

                                    target:setData("char >> belt", false)
                                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 1)

                                    return;
                                else
                                    local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                    local name = exports['cr_admin']:getAdminName(target);
                                    local green = exports['cr_core']:getServerColor("orange", true);
                                    outputChatBox(syntax .." Nincs nálad övelvágó genyó (átírás kell)!", 255,255,255,true);

                                    return;
                                end
                            else
                                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                                local name = exports['cr_admin']:getAdminName(target);
                                local green = exports['cr_core']:getServerColor("orange", true);
                                outputChatBox(syntax .. green .. name .. white .. " biztonsági öve ki van csatolva!", 255,255,255,true);
                                
                                return;
                            end
                        else
                            local syntax = exports['cr_core']:getServerSyntax(false, "error");
                            outputChatBox(syntax .. "A jármű zárva van!", 255,255,255,true);
                            
                            return;
                        end
                    end
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error");
                local name = exports['cr_admin']:getAdminName(target);
                local green = exports['cr_core']:getServerColor("orange", true);
                outputChatBox(syntax .. green .. name .. white .. " nincs járműben!", 255,255,255,true);
                
                return
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error");
            outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true);
        end
    end
end
addCommandHandler("ovelvag", destroyBeltPlayer);
addCommandHandler("elvag", destroyBeltPlayer);

function toggleWindowPanel()
    local veh = getPedOccupiedVehicle(localPlayer);
    if veh then
        if doorState then return; end
        if getVehicleType(veh) ~= "Automobile" then return; end
        if isTimer(spamTimerWindowPanel) then return; end
        spamTimerWindowPanel = setTimer(function() end, math.random(500,500), 1);
        
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            windowState = not windowState;
            
            if windowState then
                addEventHandler("onClientRender", root, drawnWindowPanel, true, "low-5");
            else
                removeEventHandler("onClientRender", root, drawnWindowPanel);
            end
        end
    end
end
bindKey("F1", "down", toggleWindowPanel);
addCommandHandler("windowpanel", toggleWindowPanel);
addCommandHandler("ablakpanel", toggleWindowPanel);

function toggleDoorPanel()
    local veh = getPedOccupiedVehicle(localPlayer);
    
    if veh then
        if getVehicleType(veh) ~= "Automobile" then return; end
        if windowState then return; end
        if isTimer(spamTimerDoorPanel) then return; end
        spamTimerDoorPanel = setTimer(function() end, math.random(500,500), 1);
        
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            doorState = not doorState;
            
            if doorState then
                addEventHandler("onClientRender", root, drawnDoorPanel, true, "low-5");
            else
                removeEventHandler("onClientRender", root, drawnDoorPanel);
            end
        end
    end
end
addCommandHandler("doorpanel", toggleDoorPanel);
addCommandHandler("cveh", toggleDoorPanel);

function dxDrawRectangleBox2(left, top, width, height, color, color2)
    if not color then
        color = tocolor(0,0,0,160);
    end
    if not color2 then
        color2 = tocolor(0,0,0,220);
    end
    
    dxDrawRectangle(left, top, width, height, color);
    dxDrawRectangle(left-1, top, 1, height, color2);
    dxDrawRectangle(left+width, top, 1, height, tocolor(0,0,0,220));
    dxDrawRectangle(left, top-1, width, 1, tocolor(0,0,0,220));
    dxDrawRectangle(left, top+height, width, 1, tocolor(0,0,0,220));
end

local value2 = {};

addEventHandler("onClientResourceStart", resourceRoot, function()
    value2 = jsonGETT("savePos.json");
end);

addEventHandler("onClientResourceStop", resourceRoot, function()
    jsonSAVE("savePos.json", value2);
end);

local cursorState = isCursorShowing();
local cursorX, cursorY = sx/2, sy/2;
if cursorState then
    local cursorX, cursorY = getCursorPosition();
    cursorX, cursorY = cursorX * sx, cursorY * sy;
end;

addEventHandler("onClientCursorMove", root, function(_, _, x, y)
    cursorX, cursorY = x, y;
    if realMoving and windowState or realMoving and doorState then
        value2["x"] = x - dX;
        value2["y"] = y - dY;
    elseif realMoving and not windowState and not doorState then
        windowState = false;
        doorState = false;
        realMoving = false;
    end
end);

function drawnWindowPanel()
    local veh = getPedOccupiedVehicle(localPlayer);
    if not veh then return; end
    
    if not TwoDoorVehicles[getElementModel(veh)] then
        dxDrawRectangleBox2(value2["x"]-200/2, value2["y"]-200/2, 200, 190);
    else
        dxDrawRectangleBox2(value2["x"]-200/2, value2["y"]-200/2, 200, 80);
    end
    
    dxDrawRectangleBox2(value2["x"]-200/2, value2["y"]-100, 200, 15, tocolor(30,30,30,180));
    
    if not TwoDoorVehicles[getElementModel(veh)] then
        local windowState = getElementData(veh, "veh >> window3State");
        local windowName = windowNames2[3];
        dxDrawText(windowName, value2["x"]+20+70/2, value2["y"]+100/2-20, value2["x"]+20+70/2, value2["y"]+100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center");
        
        if windowState then -- Lehúzva, Felhúzás
            if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then
                dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,180));  -- Bal alsó
                dxDrawText("Lehúzva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            else
                dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,120));  -- Lehúzva
                dxDrawText("Lehúzva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            end
        else -- Felhúzva, lehúzás
            if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then
                dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,180));  -- Bal alsó
                dxDrawText("Felhúzva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            else
                dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,120));  -- Lehúzva
                dxDrawText("Felhúzva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            end
        end
    end
    
    local windowState = getElementData(veh, "veh >> window2State");
    local windowName = windowNames2[2];
    dxDrawText(windowName, value2["x"]+20+70/2, value2["y"]-100/2-20, value2["x"]+20+70/2, value2["y"]-100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center");
    
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,180));  -- Bal alsó
            dxDrawText("Lehúzva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,120));  -- Lehúzva
            dxDrawText("Lehúzva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,180));  -- Bal alsó
            dxDrawText("Felhúzva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,120));  -- Lehúzva
            dxDrawText("Felhúzva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        end
    end
    
    if not TwoDoorVehicles[getElementModel(veh)] then
        local windowState = getElementData(veh, "veh >> window5State");
        local windowName = windowNames2[5];
        dxDrawText(windowName, value2["x"]-90+70/2, value2["y"]+100/2-20, value2["x"]-90+70/2, value2["y"]+100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center");
        
        if windowState then -- Lehúzva, Felhúzás
            if isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then
                dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,180));  -- Bal alsó
                dxDrawText("Lehúzva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            else
                dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,120));  -- Lehúzva
                dxDrawText("Lehúzva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            end
        else -- Felhúzva, lehúzás
            if isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then
                dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,180));  -- Bal alsó
                dxDrawText("Felhúzva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            else
                dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,120));  -- Lehúzva
                dxDrawText("Felhúzva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
            end
        end
    end
    
    local windowState = getElementData(veh, "veh >> window4State");
    local windowName = windowNames2[4];
    dxDrawText(windowName, value2["x"]-90+70/2, value2["y"]-100/2-20, value2["x"]-90+70/2, value2["y"]-100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center");
    
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,180));  -- Bal alsó
            dxDrawText("Lehúzva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,120));  -- Lehúzva
            dxDrawText("Lehúzva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,180));  -- Bal alsó
            dxDrawText("Felhúzva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,120));  -- Lehúzva
            dxDrawText("Felhúzva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
        end
    end
    
    dxDrawText("Ablakok kezelése", value2["x"], value2["y"]-100+15/2, value2["x"], value2["y"]-100+15/2, tocolor(255,255,255,255), 0.6, font, "center", "center");
end

addEventHandler("onClientClick", root, function(b, s)
    if b == "left" and s == "down" then
        if windowState then
            if isTimer(spamTimerClick) then return; end
            spamTimerClick = setTimer(function() end, math.random(850,850), 1);
            local veh = getPedOccupiedVehicle(localPlayer);
            if not veh then return; end
            if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then -- 2
                if not TwoDoorVehicles[getElementModel(veh)] then
                    local num = 3;
                    local windowState = getElementData(veh, "veh >> window"..num.."State");
                    setElementData(veh, "veh >> window"..num.."State", not windowState);
                    local newWindowState = windowState;
                    local text = windowNames[num];

                    if newWindowState then
                        exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
                    else
                        exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
                    end
                end
            elseif isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then -- 3
                local num = 2;
                local windowState = getElementData(veh, "veh >> window"..num.."State");
                setElementData(veh, "veh >> window"..num.."State", not windowState);
                local newWindowState = windowState;
                local text = windowNames[num];
                    
                if newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
                end
            elseif isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then -- 4
                if not TwoDoorVehicles[getElementModel(veh)] then
                    local num = 5;
                    local windowState = getElementData(veh, "veh >> window"..num.."State");
                    setElementData(veh, "veh >> window"..num.."State", not windowState);
                    local newWindowState = windowState;
                    local text = windowNames[num];
                        
                    if newWindowState then
                        exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
                    else
                        exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
                    end
                end
            elseif isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then -- 5
                local num = 4;
                local windowState = getElementData(veh, "veh >> window"..num.."State");
                setElementData(veh, "veh >> window"..num.."State", not windowState);
                local newWindowState = windowState;
                local text = windowNames[num];
                    
                if newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "felhúzza a "..text.." ablakot", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "lehúzza a "..text.." ablakot", 1);
                end
            elseif isInSlot(value2["x"]-200/2, value2["y"]-100, 200, 15) then -- Felső rész
                local cx, cy = exports['cr_core']:getCursorPosition();
                realMoving = true;
                x, y = value2["x"], value2["y"];
                dX, dY = cx - x, cy - y;
            end
        elseif doorState then
            if isTimer(spamTimerClick) then return; end
            spamTimerClick = setTimer(function() end, math.random(800,800), 1);
            local veh = getPedOccupiedVehicle(localPlayer);
            if not veh then return end
            if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then -- 2
                local num = 5;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];
                    
                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a "..text.." ajtót", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.." ajtót", 1);
                end
            elseif isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then -- 3
                local num = 3;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];
                    
                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a "..text.." ajtót", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.." ajtót", 1);
                end
            elseif isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then -- 4
                local num = 4;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];
                    
                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a "..text.." ajtót", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.." ajtót", 1);
                end
            elseif isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then -- 5
                local num = 2;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];

                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a "..text.." ajtót", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.." ajtót", 1);
                end
            elseif isInSlot(value2["x"]-80, value2["y"]-20/2, 70, 20) then
                local num = 0;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];
                    
                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "felnyitja a "..text.."t", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.."t", 1);
                end
            elseif isInSlot(value2["x"]+10, value2["y"]-20/2, 70, 20) then
                local num = 1;
                local windowState = getVehicleDoorOpenRatio(veh, num) == 1;
                triggerServerEvent("changeDoorState", localPlayer, veh, num, windowState);
                local newWindowState = windowState;
                local text = doorNames2[num];
                    
                if not newWindowState then
                    exports['cr_chat']:createMessage(localPlayer, "felnyitja a "..text.."t", 1);
                else
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a "..text.."t", 1);
                end
            elseif isInSlot(value2["x"]-200/2, value2["y"]-100, 200, 15) then -- Felső rész
                local cx, cy = exports['cr_core']:getCursorPosition();
                realMoving = true;
                x, y = value2["x"], value2["y"];
                dX, dY = cx - x, cy - y;
            end
        end
    elseif b == "left" and s == "up" then
        if realMoving then
            realMoving = false;
        end
    end
end);

function drawnDoorPanel()
    dxDrawRectangleBox2(value2["x"]-200/2, value2["y"]-200/2, 200, 200)
    dxDrawRectangleBox2(value2["x"]-200/2, value2["y"]-100, 200, 15, tocolor(30,30,30,180))
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local num = 5
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]+20+70/2, value2["y"]+100/2-20, value2["x"]+20+70/2, value2["y"]+100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]+20+70/2, value2["y"]+100/2, value2["x"]+20+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    local num = 3
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]+20+70/2, value2["y"]-100/2-20, value2["x"]+20+70/2, value2["y"]-100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+20, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]+20+70/2, value2["y"]-100/2, value2["x"]+20+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    local windowState = getElementData(veh, "veh >> window5State")
    local num = 4
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]-90+70/2, value2["y"]+100/2-20, value2["x"]-90+70/2, value2["y"]+100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]+100/2-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]-90+70/2, value2["y"]+100/2, value2["x"]-90+70/2, value2["y"]+100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    local num = 2
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]-90+70/2, value2["y"]-100/2-20, value2["x"]-90+70/2, value2["y"]-100/2-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-90, value2["y"]-100/2-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]-90+70/2, value2["y"]-100/2, value2["x"]-90+70/2, value2["y"]-100/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    local num = 0
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]-80+70/2, value2["y"]-20, value2["x"]-80+70/2, value2["y"]-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]-80, value2["y"]-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-80, value2["y"]-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]-80+70/2, value2["y"], value2["x"]-80+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-80, value2["y"]-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]-80+70/2, value2["y"], value2["x"]-80+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]-80, value2["y"]-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]-80, value2["y"]-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]-80+70/2, value2["y"], value2["x"]-80+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]-80, value2["y"]-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]-80+70/2, value2["y"], value2["x"]-80+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    local num = 1
    local windowState = getVehicleDoorOpenRatio(veh, num) == 1
    local windowName = doorNames[num]
    dxDrawText(windowName, value2["x"]+10+70/2, value2["y"]-20, value2["x"]+10+70/2, value2["y"]-20, tocolor(255,255,255,255), 0.6, font, "center", "center")
    if windowState then -- Lehúzva, Felhúzás
        if isInSlot(value2["x"]+10, value2["y"]-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+10, value2["y"]-20/2, 70, 20, tocolor(87,255,87,180))  -- Bal alsó
            dxDrawText("Kinyitva", value2["x"]+10+70/2, value2["y"], value2["x"]+10+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+10, value2["y"]-20/2, 70, 20, tocolor(87,255,87,120))  -- Lehúzva
            dxDrawText("Kinyitva", value2["x"]+10+70/2, value2["y"], value2["x"]+10+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    else -- Felhúzva, lehúzás
        if isInSlot(value2["x"]+10, value2["y"]-20/2, 70, 20) then
            dxDrawRectangleBox2(value2["x"]+10, value2["y"]-20/2, 70, 20, tocolor(255,87,87,180))  -- Bal alsó
            dxDrawText("Bezárva", value2["x"]+10+70/2, value2["y"], value2["x"]+10+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        else
            dxDrawRectangleBox2(value2["x"]+10, value2["y"]-20/2, 70, 20, tocolor(255,87,87,120))  -- Lehúzva
            dxDrawText("Bezárva", value2["x"]+10+70/2, value2["y"], value2["x"]+10+70/2, value2["y"], tocolor(255,255,255,255), 0.6, font, "center", "center")
        end
    end
    dxDrawText("Ajtók kezelése", value2["x"], value2["y"]-100+15/2, value2["x"], value2["y"]-100+15/2, tocolor(255,255,255,255), 0.6, font, "center", "center")
end

bindKey("accelerate", "down", 
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
        if veh and isElementFrozen(veh) then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Behúzott kézifékel nem tudsz elindulni!", 255,255,255,true)
        end
    end
)

bindKey("brake_reverse", "down", 
    function()
        local veh = getPedOccupiedVehicle(localPlayer)
        if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
        if veh and isElementFrozen(veh) then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Behúzott kézifékel nem tudsz elindulni!", 255,255,255,true)
        end
    end
)

function getPlayerVehicles(e)
    local table = {}
    local num = 0
    for k,v in pairs(getElementsByType("vehicle")) do
        local id = getElementData(v, "veh >> id") or -1
        if id == getElementData(e, "acc >> id") then
            if isElement(v) then
                table[k] = v
            end
            num = num + 1
        end
    end
    return num, table
end

function setBeltSound(veh)
    if veh then
        if getElementData(veh, "veh >> engine") then
            if hasBelt[getElementModel(veh)] then
                 if not isElement(beltSound) then
                    beltSound = playSound("files/sounds/belt.mp3", true)
                 end
            end
        else
           if isElement(beltSound) then
            destroyElement(beltSound)
           end
        end
    end
end

local cursorState = isCursorShowing()
cursorX, cursorY = 0,0
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end














