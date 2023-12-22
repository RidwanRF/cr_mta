-- local dutys = {
    -- [1] = {1570.6579589844, -1628.3862304688, 13.3828125, 0, 0, 2, "Rendőrség - Szolgálat", 1},
-- };

local element = nil;

local screenW, screenH = guiGetScreenSize();
fonts = {};
fonts["Awesome-20"] = dxCreateFont("files/FontAwesome.ttf", 20);
fonts["Roboto-Bold-11"] = dxCreateFont("files/Roboto-Bold.ttf", 11);
fonts["Roboto-10"] = dxCreateFont("files/Roboto.ttf", 10);
fonts["Roboto-12"] = dxCreateFont("files/Roboto.ttf", 12);

elements = {};
duty = {};
faction = 0;
local selectedElement = 1;
local lineDutys = 1;

addEventHandler("onClientResourceStart", resourceRoot, function()
	setTimer(triggerServerEvent, 100, 1, "getDutyPoints", resourceRoot)
end)

addEventHandler("onClientPickupHit", getRootElement(), function(player, dim)
    if player == localPlayer then
        if dim then
            faction = tonumber(getElementData(source, "faction")) or 0;
            if faction > 0 then
                if exports.cr_faction:isPlayerInFaction(localPlayer, faction) then
                    addEventHandler("onClientRender", getRootElement(), renderDuty);
                    pickupHit = true;
                    element = source;
                    duty = {};
                    local temp = exports.cr_faction:getFactionDutys(localPlayer, faction);
                    local rank = exports.cr_faction:getPlayerFactionRank(localPlayer, faction);
                    if temp then
                        for i=1, #temp do
                            if temp[i]["rank"] <= rank then
                                table.insert(duty, temp[i]);
                            end
                        end
                    end
                        
                    addEventHandler("onClientKey", getRootElement(), onKey);
                    addEventHandler("onClientClick", getRootElement(), onClick);
                end
            end
        end
    end
end);

addEventHandler("onClientPickupLeave", getRootElement(), function(player, dim)
    if player == localPlayer then
        closeDuty();
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

function renderDuty()
    if pickupHit then
        roundedRectangle(screenW/2 - 450/2, screenH - 100, 450, 55, tocolor(0, 0, 0, 150));
        roundedRectangle(screenW/2 - 450/2, screenH - 100, 50, 55, tocolor(0, 0, 0, 150));
        dxDrawText("", screenW/2 - 450/2, screenH - 100, screenW/2 - 450/2 + 50, screenH - 100 + 55, tocolor(255, 255, 255, 255), 1, fonts["Awesome-20"], "center", "center");
        
        dxDrawText(getElementData(element, "name"), screenW/2 - 450/2 + 50, screenH - 112.5, screenW/2 - 450/2 + 50 + 400, screenH - 112.5 + 55, tocolor(255, 153, 51, 255), 1, fonts["Roboto-Bold-11"], "center", "center");
        
        dxDrawText((getElementData(localPlayer, "player >> duty >> state") or false) and "Szolgálat leadásához nyomd meg az 'E' betűt!" or "Szolgálati panel megnyitásához nyomd meg az 'E' betűt!", screenW/2 - 450/2 + 50, screenH - 95, screenW/2 - 450/2 + 50 + 400, screenH - 95 + 55, tocolor(255, 255, 255, 255), 1, fonts["Roboto-10"], "center", "center");
        return;
    end
    
    if element then
        roundedRectangle(screenW/2 - 400/2, screenH/2 - 350/2, 400, 350, tocolor(0, 0, 0, 200));
        dxDrawText(exports.cr_faction:getFactionName(localPlayer, faction), screenW/2 - 400/2, screenH/2 - 350/2, screenW/2 - 400/2 + 400, screenH/2 - 350/2 + 350, tocolor(255, 255, 255, 255), 1, fonts["Roboto-12"], "center", "top");
        
        roundedRectangle(screenW/2 - 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30, (isCursorHover(screenW/2 - 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30) and tocolor(32, 188, 34, 200) or tocolor(32, 188, 34, 150)));
        roundedRectangle(screenW/2 - 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30, (isCursorHover(screenW/2 - 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30) and tocolor(232, 71, 71, 200) or tocolor(232, 71, 71, 150)));
        dxDrawText("Szolgálatba lépés", screenW/2 - 400/2, screenH/2 - 350/2 + 350 - 30, screenW/2 - 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30 + 30, tocolor(255, 255, 255, 255), 1, fonts["Roboto-10"], "center", "center");
        dxDrawText("Bezárás", screenW/2 - 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30, screenW/2 - 400/2 + 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30 + 30, tocolor(255, 255, 255, 255), 1, fonts["Roboto-10"], "center", "center");
        
        roundedRectangle(screenW/2 - 400/2 + 400/2 - 225/2, screenH/2 - 350/2 + 50, 225, 10*23.4, tocolor(0, 0, 0, 150));
        
        local maxLine = 10;
        local y = screenH/2 - 350/2 + 50;
        local latestLine = lineDutys + maxLine - 1;

        for i=1, #duty do
            if i >= lineDutys then 
                if i <= latestLine then
                    roundedRectangle(screenW/2 - 400/2 + 400/2 - 225/2 + 3, y + 3, 225 - 6, 20, ((selectedElement == i or isCursorHover(screenW/2 - 400/2 + 400/2 - 225/2, y + 3, 225 - 6, 20)) and tocolor(255, 153, 51, 150) or tocolor(40, 40, 40, 200)));
                    dxDrawText(duty[i]["name"], screenW/2 - 400/2 + 400/2 - 225/2 + 3, y + 3, screenW/2 - 400/2 + 400/2 - 225/2 + 3 + 225 - 6, y + 3 + 20, tocolor(255, 255, 255, 255), 1, fonts["Roboto-10"], "center", "center");
                    
                    y = y + 23
                end
            end
        end
    end
end

function onKey(button, state)
    if pickupHit and element then
        if button == "e" and state then
            if getElementData(localPlayer, "player >> duty >> state") or false then
                setElementData(localPlayer, "player >> duty >> state", false);
                setElementData(localPlayer, "player >> duty >> name", "");
                setElementData(localPlayer, "player >> duty >> skin", 0);
                
                setElementData(localPlayer, "char >> skin", getElementData(localPlayer, "oldskin") or 0);
        
                -- for i=1, 3 do
                    -- local items = exports.cr_inventory:getItems(localPlayer, i);
                    -- for slot, data in pairs(items) do
                        -- local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data);
                        -- if dutyitem == 1 then
                            -- exports.cr_inventory:deleteItem(localPlayer, slot, itemid);
							-- triggerServerEvent("depositItemToFaction", getRootElement(), localPlayer, faction, itemid, value, count)
                        -- end
                    -- end
                -- end
				triggerServerEvent("removeDutyItems", root, localPlayer, faction)
                
                exports.cr_infobox:addBox("info", "Kiléptél szolgálatból!");
                return;
            end
            if #duty > 0 then
                pickupHit = false;
                setElementData(localPlayer, "script >> visible", false);
                setElementData(localPlayer, "hudVisible", false);
                showCursor(true);
                showChat(false);
            else
                exports.cr_infobox:addBox("error", "Nincs még duty létrehozva!");
            end
        end
    end
    
    if element and not pickupHit then
        if button == "mouse_wheel_up" and state then
            if lineDutys - 1 > 0 then
                lineDutys = lineDutys - 1;
            end
        elseif button == "mouse_wheel_down" and state then
            if lineDutys + 1 < #duty then
                if lineDutys + 10 > #duty then
                    return;
                end
                lineDutys = lineDutys + 1;
            end
        end
    end
end

function onClick(button, state)
    if button == "left" and state == "down" then
        if not pickupHit and element then
            if isCursorHover(screenW/2 - 400/2 + 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30) then
                closeDuty();
                return;
            elseif isCursorHover(screenW/2 - 400/2 + 400/2 - 225/2, screenH/2 - 350/2 + 50, 225, 10*23.4) then
                local maxLine = 10;
                local y = screenH/2 - 350/2 + 50;
                local latestLine = lineDutys + maxLine - 1;

                for i=1, #duty do
                    if i >= lineDutys then 
                        if i <= latestLine then
                            if isCursorHover(screenW/2 - 400/2 + 400/2 - 225/2 + 3, y + 3, 225 - 6, 20) then
                                selectedElement = i;
                                return;
                            end
                            y = y + 23;
                        end
                    end
                end
                return;
            elseif isCursorHover(screenW/2 - 400/2, screenH/2 - 350/2 + 350 - 30, 400/2, 30) then
                local datas = duty[selectedElement];
				if(datas["rank"] <= exports.cr_faction:getPlayerFactionRank(localPlayer, faction)) then
					if datas then
						setElementData(localPlayer, "player >> duty >> faction", faction);
						setElementData(localPlayer, "player >> duty >> state", true);
						setElementData(localPlayer, "player >> duty >> name", datas["name"]);
						setElementData(localPlayer, "player >> duty >> skin", tonumber(datas["skin"]));
						setElementData(localPlayer, "oldskin", getElementModel(localPlayer));
						setElementData(localPlayer, "char >> skin", tonumber(datas["skin"]));
						-- for i, k in pairs(datas["items"]) do
							-- exports.cr_inventory:giveItem(localPlayer, localPlayer, k[1], k[2], k[4], 1, 1, false, false, true)
							-- triggerServerEvent("removeStorageItem", getRootElement(), localPlayer, faction, i)
						-- end
						triggerServerEvent("giveDutyItems", root, localPlayer, faction, datas["name"])
						
						exports.cr_infobox:addBox("info", "Szolgálatba léptél!");
						closeDuty();
					end
				else
					exports.cr_infobox:addBox("error", "Nem vagy jogosult ennek a dutynak a használatára!");
				end
                return;
            end
            return;
        end
    end
end

function closeDuty()
    removeEventHandler("onClientRender", getRootElement(), renderDuty);
    pickupHit = false;
    element = nil;
    faction = 0;
    duty = {};
    removeEventHandler("onClientKey", getRootElement(), onKey);
    removeEventHandler("onClientClick", getRootElement(), onClick);
    setElementData(localPlayer, "script >> visible", true);
    setElementData(localPlayer, "hudVisible", true);
    showCursor(false);
    showChat(true);
    selectedElement = 1;
    lineDutys = 1;
end

function isCursorHover(startX, startY, sizeX, sizeY)
    if isCursorShowing() then
        local cursorPosition = {getCursorPosition()};
        cursorPosition.x, cursorPosition.y = cursorPosition[1] * screenW, cursorPosition[2] * screenH;

        if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
            return true;
        else
            return false;
        end
    else
        return false;
    end
end

local dutyPoints = {};
local dutyPickups = {};

addEvent("receiveDutyPoints", true)
addEventHandler("receiveDutyPoints", resourceRoot, function(points)
	dutyPoints = points
	for i, v in pairs(dutyPoints) do
		if(exports.cr_faction:isPlayerInFaction(localPlayer, v["faction"])) then
			local x, y, z = unpack(v["pos"])
			local int, dim = unpack(v["world"])
			if(not dutyPickups[i]) then
				dutyPickups[i] = createPickup(x, y, z, 3, 1275)
				elements[dutyPickups[i]] = true;
				dutyPickups[i]:setData("name", v["name"])
				dutyPickups[i]:setData("id", i)
				dutyPickups[i]:setData("faction", v["faction"])
				dutyPickups[i]:setInterior(int)
				dutyPickups[i]:setDimension(dim)
			else
                if dutyPickups[i] and isElement(dutyPickups[i]) then
    				dutyPickups[i]:setPosition(x, y, z)
    				dutyPickups[i]:setInterior(int)
    				dutyPickups[i]:setDimension(dim)
                end
			end
		else
			if(dutyPickups[i]) then
				elements[dutyPickups[i]] = false;
				dutyPickups[i]:destroy()
			end
		end
	end
end)

setTimer(function() 
	for i, v in pairs(dutyPoints) do
		if(exports.cr_faction:isPlayerInFaction(localPlayer, v["faction"])) then
			local x, y, z = unpack(v["pos"])
			local int, dim = unpack(v["world"])
			if(not dutyPickups[i]) then
				dutyPickups[i] = createPickup(x, y, z, 3, 1275);
				dutyPickups[i]:setInterior(int)
				dutyPickups[i]:setDimension(dim)
			else
                if dutyPickups[i] and isElement(dutyPickups[i]) then
    				dutyPickups[i]:setPosition(x, y, z)
    				dutyPickups[i]:setInterior(int)
    				dutyPickups[i]:setDimension(dim)
                end
			end
		else
			if(dutyPickups[i]) then
				dutyPickups[i]:destroy()
				dutyPickups[i] = nil
			end
		end
	end
	setTimer(triggerServerEvent, 100, 1, "getDutyPoints", resourceRoot)
end, 5000, 0)

addEvent("deleteDutyPoint", true)
addEventHandler("deleteDutyPoint", resourceRoot, function(id) 
	dutyPickups[id]:destroy()
	dutyPickups[id] = nil
end)

