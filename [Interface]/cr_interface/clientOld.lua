local sx, sy = guiGetScreenSize()
local fontsize = 1
if getResourceState(getResourceFromName("cr_core")) == "running" then
    font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
    font2 = exports['cr_fonts']:getFont("Yantramanav-Regular", 14)
    font3 = exports['cr_fonts']:getFont("Yantramanav-Black", 15)
    r,g,b = exports['cr_core']:getServerColor(nil, false)
    r2,g2,b2 = exports['cr_core']:getServerColor('red', false)
    gr,gg,gb = exports['cr_core']:getServerColor('green', false)
    yr,yg,yb = exports['cr_core']:getServerColor('yellow', false)
    sizeX = exports['cr_core']:getIcon("fa-arrows-h")
    sizeY = exports['cr_core']:getIcon("fa-arrows-v")
end
if getResourceState(getResourceFromName("cr_fonts")) == "running" then 
    awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 11)
    awesomeFontM = exports['cr_fonts']:getFont("AwesomeFont", 9)
end
local moving = {}
local mySavedConfig = {}
addEventHandler("onClientResourceStart", root,
    function(startedRes)
    	local startedResName = getResourceName(startedRes)
        if startedResName == "cr_core" then
            r,g,b = exports['cr_core']:getServerColor(nil, false)
            gr,gg,gb = exports['cr_core']:getServerColor('green', false)
            r2,g2,b2 = exports['cr_core']:getServerColor('red', false)
            yr,yg,yb = exports['cr_core']:getServerColor('yellow', false)
            sizeX = exports['cr_core']:getIcon("fa-arrows-h")
            sizeY = exports['cr_core']:getIcon("fa-arrows-v")
       	elseif startedResName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
			font2 = exports['cr_fonts']:getFont("Yantramanav-Regular", 14)
			font3 = exports['cr_fonts']:getFont("Yantramanav-Black", 15)
			awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 11)
			awesomeFontM = exports['cr_fonts']:getFont("AwesomeFont", 9)
        end
    end
)

function getNode(id, node)
    if mySavedConfig[id] and mySavedConfig[id][node] then
        return mySavedConfig[id][node]
    end
end

local defPositions = {
    --["componentname"] = {x,y,w,h, {canSizableX, canSizableY}, canTurnable, {{minX, maxX}, {minY, maxY}}}
    
    --["hudbars"] = {sx - 260, 0, 260, 105, {true, false}, false, {{70, 300}, {0, 0}}, "HUD"},
    
    ["hp"] = {sx - 320, 0, 90, 90, {false, false}, true, {{0, 0}, {0, 0}}, "Élet"},
    ["armor"] = {sx - 320 + 60, 40, 90, 90, {false, false}, true, {{0, 0}, {0, 0}}, "Páncél"},
    ["hunger"] = {sx - 320 + 120, 0, 90, 90, {false, false}, true, {{0, 0}, {0, 0}}, "Éhség"},
    ["thirsty"] = {sx - 320 + 180, 40, 90, 90, {false, false}, true, {{0, 0}, {0, 0}}, "Szomjúság"},
    ["stamina"] = {sx - 320 + 240, 0, 90, 90, {false, false}, true, {{0, 0}, {0, 0}}, "Stamina"},
    ["hudmoney"] = {sx - 255, 120, 200, 25, {false, false}, false, {{0, 0}, {0, 0}}, "Pénz"},
    ["radar"] = {20, sy - 265, 350, 225, {true, true}, true, {{100, 600}, {100, 600}}, "Kis Térkép"},
    ["infobox"] = {sx/2 - 395/2, 10, 420, 35, {false, false}, false, {{50, 600}, {10, 20}}, "Infobox"},
    ["kick/ban"] = {20, sy - 305 - (47*2), 340, 47*3, {false, false}, false, {{50, 600}, {10, 20}}, "Kick/Ban Infobox"},
    ["oxygen"] = {sx/2 - 310/2, sy - 10 - 90, 310, 10, {true, false}, false, {{50, 600}, {10, 20}}, "Oxigén"},
    ["bone"] = {sx - 150, 140, 18, 46, {false, false}, true, {{50, 600}, {10, 20}}, "Csontozat"},
    ["ooc"] = {20, sy/2 - (15*5)/2, 310, 15*5, {false, true}, true, {{50, 600}, {15*2, 15*20}}, "OOC Chat"},
    ["speedo"] = {sx - 20 - 275, sy - 20 - 275, 275, 275, {false, false}, true, {{0,0}, {0,0}}, "Sebességmérő"},
    ["vehname"] = {sx - 20 - 300, sy - 20 - 280 - 30, 300, 20, {false, false}, true, {{0,0}, {0,0}}, "Jármű Név"},
    ["handbrake"] = {sx - 20 - 64, sy/2 - 256/2, 64, 256, {false, false}, false, {{0,0}, {0,0}}, "Jármű Kézifék"},
    ["km counter"] = {sx - 20 - 220, sy - 20 - 280 - 30-55, 150, 50, {false, true}, false, {{0,0}, {0,0}}, "Jármű Kilóméter Számláló"},
    ["speedo_icon"] = {sx - 20 - 250, sy - 20 - 275+160, 145, 90, {false, true}, false, {{0,0}, {0,0}}, "Sebességmérő Ikon"},
    ["Inventory"] = {sx - 382 - 20, sy/2 - 256/2, 382, 256, {false, false}, false, {{0, 0}, {0, 0}}, "Leltár"},
    ["Actionbar"] = {sx/2 - (230/2), sy - 50, (36 * 6 + 5 * 1) + 10, 40, {false, false}, false, {{0, 0}, {0, 0}}, 1, 6, "Actionbar"},
    ["weapon"] = {sx - (256/1.2 + 20), 310, 256/1.2, 50, {false, false}, false, {{50,600}, {10,20}}, "Fegyver"},
    ["shopitems"] = {sx / 2, sy / 2, 80, 70, {false, false}, true, {{0, 0}, {0, 0}}, "Bolt Item"},
    ["groupinfo"] = {sx * 0.25, 25, 250, 250, {false, false}, true, {{0, 0}, {0, 0}}, "Csapat információk"},
}

local defWidgets = {
    --["componentname"] = {x,y,w,h, {canSizableX, canSizableY}, canTurnable}
    ["ping"] = {sx - 200, 150, 70, 20, {false, false}, true, {{50, 600}, {10, 20}}, "Ping"},
    ["fps"] = {sx - 95, 150, 75, 20, {false, false}, true, {{50, 600}, {10, 20}}, "FPS"},
    ["name"] = {sx - 300, 170, 280, 30, {false, false}, true, {{50, 600}, {10, 20}}, "Karakternév"},
    ["time"] = {sx - 200, 210, 70, 20, {false, false}, true, {{50, 600}, {10, 20}}, "Idő"},
    ["datum"] = {sx - 120, 210, 100, 20, {false, false}, true, {{50, 600}, {10, 20}}, "Dátum"},
    ["premiumPoints"] = {sx - 200, 230, 180, 20, {false, false}, true, {{50, 600}, {10, 20}}, "Prémium Pont"},
    ["videocard"] = {sx - 310, 250, 300, 100, {false, false}, true, {{50, 600}, {10, 20}}, "Videókártya"},
    ["packetloss"] = {sx - 200, 280, 180, 20, {false, false}, true, {{50, 600}, {10, 20}}, "Packet Loss"},
}

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON({["Position"] = defPositions, ["Widget"] = defWidgets}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

local positions = {};
local widgets = {};
addEventHandler("onClientResourceStart", resourceRoot, function()
    local table = jsonGET("save.json")
    positions = table["Position"]

    for k,v in pairs(positions) do
        setElementData(localPlayer, k .. ".enabled", true)
    end

    widgets = table["Widget"];

    for k,v in pairs(widgets) do
        setElementData(localPlayer, k .. ".enabled", false)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if getElementData(localPlayer, "loggedIn") then
        jsonSAVE("save.json", {["Position"] = positions, ["Widget"] = widgets})
    end
end);

local showHud = "false";
local flickerStrength = 10;
local blurStrength = 0.001;
local noiseStrength = 0.001;
local sstate = false;

function upDateScreenSource()
    dxUpdateScreenSource(myScreenSource);
end

local disabledVeh = {
    [509] = true,
    [481] = true,
    [510] = true,
};

bindKey("lctrl", "down", function()
    if getElementData(localPlayer, "loggedIn") and not getElementData(localPlayer, "keysDenied") then
        local veh = getPedOccupiedVehicle(localPlayer)

        if veh and disabledVeh[getElementModel(veh)] then
            return;
        end

        if not isCursorShowing() then return end

        state = true;
        setElementData(localPlayer, "script >> visible", false);
        setElementData(localPlayer, "interface.drawn", state);
        addEventHandler("onClientRender", root, drawnComponents, false, "low-1");
        showCursor(true);
        oldBone = getElementData(localPlayer, "char >> bone");
        setElementData(localPlayer, "keysDenied", true);
        toggleAllControls(false);
        alpha = 180;
        showChat(false);
    end
end);

bindKey("lctrl", "up", function()
    if getElementData(localPlayer, "loggedIn") and state then
        local veh = getPedOccupiedVehicle(localPlayer);
            
        if veh and disabledVeh[getElementModel(veh)] then
            return;
        end
            
        if moving["state"] then
            if moving["type"] == "moving" then
                realMoving = false;
                moving["state"] = false;
                moving["type"] = nil;
                moving["component"] = nil;
                moving["componentDetails"] = nil;
            elseif moving["type"] == "deleteFrom >> Y" then
                moving["state"] = false;
                moving["type"] = nil;
                moving["component"] = nil;
                moving["componentDetails"] = nil;
            elseif moving["type"] == "deleteFrom >> X" then    
                moving["state"] = false;
                moving["type"] = nil;
                moving["component"] = nil;
                moving["componentDetails"] = nil;
            elseif moving["type"] == "deleteFrom >> XY" then    
                moving["state"] = false;
                moving["type"] = nil;
                moving["component"] = nil;
                moving["componentDetails"] = nil;        
            end
        end
            
        state = false;
        setElementData(localPlayer, "interface.drawn", state);
        setElementData(localPlayer, "script >> visible", true);
        removeEventHandler("onClientRender", root, drawnComponents);
        showCursor(false);
        setCursorAlpha(255);
        toggleAllControls(true);
        setElementData(localPlayer, "char >> bone", oldBone);
        setElementData(localPlayer, "keysDenied", false);
        showChat(true);
    end
end);

local downIcon = ""
local upIcon = ""
local resetIcon = ""
local errorIcon = ""

function drawnComponents()
    exports.cr_renderblur:createBlur(0, 0, sx, sy, 100);
    shadowedText("HUD Szerkesztés", 0,0, sx, sy, tocolor(r,g,b,255), fontsize, font3, "center", "center");
    dxDrawText("HUD Szerkesztés", 0,0, sx, sy, tocolor(r,g,b,255), fontsize, font3, "center", "center");
    
    if widgetState then
        local nowY = 0;
        for k,v in pairs(widgets) do
            if k == "Actionbar" then
                k = v[10] or k
            else
                k = v[8] or k
            end
            if isInSlot(0,nowY, 200, 20) then
                dxDrawRectangle(0, nowY, 200, 20, tocolor(r,g,b,180));
                dxDrawText(k, 0,nowY, 200, nowY + 20, tocolor(0,0,0,255), fontsize, awesomeFontM, "center", "center");
            else
                dxDrawRectangle(0, nowY, 200, 20, tocolor(r,g,b,180));
                dxDrawText(k, 0,nowY, 200, nowY + 20, tocolor(255,255,255,255), fontsize, awesomeFontM, "center", "center");
            end
            
            nowY = nowY + 21;
        end
        
        if isInSlot(0, nowY, 200, 20) then
            dxDrawRectangle(0, nowY, 200, 20, tocolor(r,g,b,180));
            dxDrawText(upIcon, 0, nowY, 200, nowY + 20, tocolor(0,0,0,255), fontsize, awesomeFontM, "center", "center");
        else
            dxDrawRectangle(0, nowY, 200, 20, tocolor(r,g,b,180))
            dxDrawText(upIcon, 0, nowY, 200, nowY + 20, tocolor(255,255,255,255), fontsize, awesomeFontM, "center", "center");
        end
    else
        if isInSlot(0,0, 200, 20) then
            dxDrawRectangle(0, 0, 200, 20, tocolor(r,g,b,180));
            dxDrawText(downIcon, 0,0, 200, 20, tocolor(0,0,0,255), fontsize, awesomeFontM, "center", "center");
        else
            dxDrawRectangle(0, 0, 200, 20, tocolor(r,g,b,180))
            dxDrawText(downIcon, 0,0, 200, 20, tocolor(255,255,255,255), fontsize, awesomeFontM, "center", "center");
        end
    end
    
    local alphaAssigned = false
    for k,v in pairs(positions) do
        local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(v);
        
        if realMoving and moving["component"] == k or k == "ooc" then
            dxDrawnBorder(x,y,w,h, tocolor(r,g,b,150), tocolor(0,0,0,220));
        end
        if k == "Actionbar" then
            k = v[10] or k
        else
            k = v[8] or k
        end
        if isInSlot(x,y,w,h) then
            dxDrawText(k, x, y, x + w, y + h, tocolor(0,0,0,255), fontsize, font, "center", "center");
        else
            dxDrawText(k, x, y, x + w, y + h, tocolor(255,255,255,255), fontsize, font, "center", "center");
        end
        
        if isInSlot(x - 14/2, y - 14/2, 14, 14) then
            dxDrawText(resetIcon, x, y, x, y, tocolor(yr,yg,yb,255), fontsize, awesomeFontM, "center", "center");
        else 
            dxDrawText(resetIcon, x, y, x, y, tocolor(yr,yg,yb,100), fontsize, awesomeFontM, "center", "center");
        end
        
        if turnable then
            if isInSlot(x + w - 10/2, y - 10/2, 10, 10) then
                dxDrawText(errorIcon, x + w, y, x + w, y, tocolor(r2,g2,b2,255), fontsize, awesomeFontM, "center", "center");
            else 
                dxDrawText(errorIcon, x + w, y, x + w , y, tocolor(r2,g2,b2,100), fontsize, awesomeFontM, "center", "center");
            end
        end
        
        local sizableX, sizableY = unpack(sizable)
        if sizableX then
            if isInSlot(x + w - 2, y - 2, 4, h + 4) then
                local cx, cy = exports['cr_core']:getCursorPosition();
                shadowedText(sizeX, cx, cy, cx, cy, tocolor(255,255,255,255), fontsize, awesomeFont, "center", "center");
                dxDrawText(sizeX, cx, cy, cx, cy, tocolor(255,255,255,255), fontsize, awesomeFont, "center", "center");
                setCursorAlpha(0);
                alphaAssigned = true;
            else
                if not alphaAssigned then
                    setCursorAlpha(255);
                end
            end
        end
        
        if sizableY then
            if isInSlot(x - 2, y + h - 2, w + 4, 4) then
                local cx, cy = exports['cr_core']:getCursorPosition();
                shadowedText(sizeY, cx, cy, cx, cy, tocolor(255,255,255,255), fontsize, awesomeFont, "center", "center");
                dxDrawText(sizeY, cx, cy, cx, cy, tocolor(255,255,255,255), fontsize, awesomeFont, "center", "center");
                setCursorAlpha(0);
                alphaAssigned = true;
            else
                if not alphaAssigned then
                    setCursorAlpha(255);
                end
            end
        end
    end
end

addEventHandler("onClientClick", root, function(button, s)
    if button == "left" and s == "down" then
        if state then
            if widgetState then
                local nowY = 0;
                    
                for k,v in pairs(widgets) do
                    if isInSlot(0,nowY, 200, 20) then
                        positions[k] = widgets[k];
                        widgets[k] = nil;
                        setElementData(localPlayer, k..".enabled", true);
                        local enabled = false;
                        for k,v in pairs(widgets) do enabled = true break end
                            
                        if not enabled then
                            widgetState = false;
                        end
                        return;
                    end       
                        
                    nowY = nowY + 21;
                end

                if isInSlot(0, nowY, 200, 20) then
                    widgetState = false;
                end
            else
                if isInSlot(0,0, 200, 20) then
                    local enabled = false;
                    for k,v in pairs(widgets) do enabled = true break end
                        
                    if enabled then
                        widgetState = true;
                    end
                end
            end

            local shortestW, shortestH = 10000, 10000;
            for k,v in pairs(positions) do
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(v);
                local sizableX, sizableY = unpack(sizable);

                if isInSlot(x - 14/2, y - 14/2, 14, 14) then
                    if isTimer(resetTimer) then return end
                    resetTimer = setTimer(function() end, math.random(500,1000), 1);
                        
                    if defPositions[k] then
                        local v = defPositions[k];
                        positions[k] = {};
                        positions[k] = v;
                    elseif defWidgets[k] then
                        local v = defWidgets[k];
                        positions[k] = {};
                        positions[k] = v;
                    end
                    return;
                end

                if turnable then
                    if isInSlot(x + w - 10/2, y - 10/2, 10, 10) then
                        widgets[k] = positions[k];
                        positions[k] = nil;
                        setCursorAlpha(255);
                        setElementData(localPlayer, k..".enabled", false);
                        return
                    end
                end
                    
                if sizableX and sizableY then
                    if isInSlot(x - 2, y + h - 2, w + 4, 4) and isInSlot(x - 2, y + h - 2, w + 4, 4) then
                        moving["state"] = true;
                        moving["type"] = "deleteFrom >> XY";
                        moving["component"] = k;
                        moving["componentDetails"] = v;
                        return
                    end    
                end
                    
                if sizableX then
                    if isInSlot(x + w - 2, y - 2, 4, h + 4) then
                        moving["state"] = true;
                        moving["type"] = "deleteFrom >> X";
                        moving["component"] = k;
                        moving["componentDetails"] = v;
                        return
                    end
                end

                if sizableY then
                    if isInSlot(x - 2, y + h - 2, w + 4, 4) then
                        moving["state"] = true;
                        moving["type"] = "deleteFrom >> Y";
                        moving["component"] = k;
                        moving["componentDetails"] = v;
                        return
                    end
                end

                if isInSlot(x, y, w, h) then
                    local num1 = shortestW + shortestH;
                    local num2 = w + h;
                        
                    if num2 < num1 then
                        local cx, cy = exports['cr_core']:getCursorPosition();
                        realMoving = true;
                        moving["state"] = true;
                        moving["type"] = "moving";
                        moving["component"] = k;
                        moving["componentDetails"] = v;
                        dX, dY = cx - x, cy - y;
                        shortestW = w;
                        shortestH = h;
                    end
                end
            end

            inScreenSize = true;
            iX, iY = exports['cr_core']:getCursorPosition();
        end
    elseif button == "left" and s == "up" then
        if state then
            if moving["state"] then
                if moving["type"] == "moving" then
                    realMoving = false;
                    moving["state"] = false;
                    moving["type"] = nil;
                    moving["component"] = nil;
                    moving["componentDetails"] = nil;
                elseif moving["type"] == "deleteFrom >> Y" then
                    moving["state"] = false;
                    moving["type"] = nil;
                    moving["component"] = nil;
                    moving["componentDetails"] = nil;
                elseif moving["type"] == "deleteFrom >> X" then    
                    moving["state"] = false;
                    moving["type"] = nil;
                    moving["component"] = nil;
                    moving["componentDetails"] = nil;
                elseif moving["type"] == "deleteFrom >> XY" then    
                    moving["state"] = false;
                    moving["type"] = nil;
                    moving["component"] = nil;
                    moving["componentDetails"] = nil;        
                end
            elseif inScreenSize then
                inScreenSize = false;
            end
        end
    end
end);

addEventHandler("onClientCursorMove", root, function(_,_,cx,cy)
    if state then
        if moving["state"] then
            if moving["type"] == "deleteFrom >> Y" then
                local componentName = moving["component"]
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(positions[componentName]);
                local minX, maxX = unpack(movingDetails[1]);
                local minY, maxY = unpack(movingDetails[2]);
                local realMinX, realMaxX = x + minX, x + maxX;
                local realMinY, realMaxY = y + minY, y + maxY;
                local nowY = cy - y;
                    
                if cy >= realMinY and cy <= realMaxY then
                    positions[componentName] = {x, y, w, nowY, sizable, turnable, movingDetails, t, columns};
                end
            elseif moving["type"] == "deleteFrom >> X" then
                local componentName = moving["component"];
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(positions[componentName]);
                local minX, maxX = unpack(movingDetails[1]);
                local minY, maxY = unpack(movingDetails[2]);
                local realMinX, realMaxX = x + minX, x + maxX;
                local realMinY, realMaxY = y + minY, y + maxY;
                local cx, cy = exports['cr_core']:getCursorPosition();
                local nowX = cx - x;
                    
                if cx >= realMinX and cx <= realMaxX then
                    positions[componentName] = {x, y, nowX, h, sizable, turnable, movingDetails, t, columns};
                end
            elseif moving["type"] == "deleteFrom >> XY" then
                local componentName = moving["component"];
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(positions[componentName]);
                local minX, maxX = unpack(movingDetails[1]);
                local minY, maxY = unpack(movingDetails[2]);
                local realMinX, realMaxX = x + minX, x + maxX;
                local realMinY, realMaxY = y + minY, y + maxY;
                local cx, cy = exports['cr_core']:getCursorPosition();
                local nowX = cx - x;
                    
                if cx >= realMinX and cx <= realMaxX then
                    positions[componentName] = {x, y, nowX, h, sizable, turnable, movingDetails, t, columns};
                end 
                    
                local componentName = moving["component"]
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(positions[componentName]);
                local minX, maxX = unpack(movingDetails[1]);
                local minY, maxY = unpack(movingDetails[2]);
                local realMinX, realMaxX = x + minX, x + maxX;
                local realMinY, realMaxY = y + minY, y + maxY;
                local nowY = cy - y;
                    
                if cy >= realMinY and cy <= realMaxY then
                    positions[componentName] = {x, y, w, nowY, sizable, turnable, movingDetails, t, columns};
                end    
            elseif moving["type"] == "moving" then
                local componentName = moving["component"];
                local x,y,w,h,sizable,turnable, movingDetails, t, columns = unpack(positions[componentName]);
                positions[componentName] = {cx - dX, cy - dY, w, h, sizable, turnable, movingDetails, t, columns};
            end
        end
    end
end);

function resetHUD()
    if isTimer(resetTimer) then return end
    resetTimer = setTimer(function() end, math.random(500,1000), 1);
    positions = {};
    widgets = {};
    for k,v in pairs(defPositions) do
        positions[k] = v;
        setElementData(localPlayer, k .. ".enabled", true);
    end
    
    for k,v in pairs(defWidgets) do
        widgets[k] = v;
        setElementData(localPlayer, k .. ".enabled", false);
    end
end
addCommandHandler("resethud", resetHUD)

function getDetails(component)
    if positions[component] then
        local x,y,w,h,sizable,turnable, sizeDetails, t, columns = unpack(positions[component]);
        return "true",x,y,w,h,sizable,turnable, sizeDetails, t, columns;
    elseif widgets[component] then
        local x,y,w,h,sizable,turnable, sizeDetails, t, columns = unpack(widgets[component]);
        return "false",x,y,w,h,sizable,turnable, sizeDetails, t, columns;
    end
end

local convert = {
    ["x"] = 1,
    ["y"] = 2,
    ["w"] = 3,
    ["h"] = 4,
    ["width"] = 3,
    ["height"] = 4,
    ["sizable"] = 5,
    ["turnable"] = 6,
    ["sizeDetails"] = 7,
    ["type"] = 8,
    ["t"] = 8,
    ["columns"] = 9,
};

function setNode(component, dName, value)
    local convertedName = tonumber(convert[dName])
    if positions[component] then
        positions[component][convertedName] = value;
        return true;
    elseif widgets[component] then
        widgets[component][convertedName] = value;
        return true;
    end
end

local screenSize = {guiGetScreenSize()};
local cursorState = isCursorShowing();
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2;
if cursorState then
    local cursorX, cursorY = getCursorPosition();
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2];
end

addEventHandler("onClientCursorMove", root, function(_, _, x, y)
    cursorX, cursorY = x, y;
end);

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true;
    else
        return false;
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true;
        else
            return false;
        end
    end 
end

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
end

function linedRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180);
    end
    if not color2 then
        color2 = color;
    end
    if not size then
        size = 3;
    end
    
    dxDrawRectangle(x, y, w, h, color);
    dxDrawRectangle(x - size, y - size, w + (size * 2), size, color2);
    dxDrawRectangle(x - size, y + h, w + (size * 2), size, color2);
    dxDrawRectangle(x - size, y, size, h, color2);
    dxDrawRectangle(x + w, y, size, h, color2);
end

function dxDrawnBorder(x, y, w, h, bgColor, borderColor, postGUI)
    if (x and y and w and h) then
        if (not borderColor) then
            borderColor = tocolor(0, 0, 0, 180);
        end
        if (not bgColor) then
            bgColor = borderColor;
        end
        
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
        dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
        dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
        dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
        dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
        
        dxDrawRectangle(x + 0.5, y + 0.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + 0.5, y + h - 1.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + w - 0.5, y + 0.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + w - 0.5, y + h - 1.5, 1, 2, borderColor, postGUI);
    end
end