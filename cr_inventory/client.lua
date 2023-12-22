_addCommandHandler = addCommandHandler
--import("*"):from("cr_core")

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            --import("*"):from("cr_core")
		elseif getResourceName(startedRes) == "cr_inventory" then
			localPlayer:setData("enabledInventory", true)
        end
	end
)

function unpack(table)
    --outputChatBox("asd")
    return table[1], table[2], table[3], table[4], table[5], table[6], table[7], table[8], table[9], table[10], table[11], table[12], table[13], table[14], table[15], table[16], table[17], table[18], table[19], table[20], table[21], table[22], table[23], table[24], table[25], table[26], table[27], table[28], table[29], table[30], table[31], table[32], table[33], table[34], table[35], table[36], table[37], table[38], table[39], table[40], table[41], table[42], table[43], table[44], table[45], table[46], table[47], table[48], table[49], table[50], table[51], table[52], table[53], table[54], table[55], table[56], table[57], table[58], table[59], table[60], table[61], table[62], table[63], table[64], table[65], table[66], table[67], table[68], table[69], table[70], table[71], table[72], table[73], table[74], table[75], table[76], table[77], table[78], table[79], table[80], table[81], table[82], table[83], table[84], table[85], table[86], table[87], table[88], table[89], table[90], table[91], table[92], table[93], table[94], table[95], table[96], table[97], table[98], table[99], table[100]
end

local lastItem = 0

--HASITEMNÉL MAJD ARRA FIGYELJ ODA, HOGY HA A SLOT MOVESLOT (AKÁR SZERÓOLDALON) IS AKKOR NÉZZE TOVÁBB vagy ne az a lényeg erre figyelj oda.

--ACTIONBARRA VALÓ ÁTRAKÁSNÁL ARRA FIGYELJ ODA, HOGY AZ INVELEMENT == LOCALPLAYER!!!!!!!!!

invElement = localPlayer

local disableThisInt = {
    ["count"] = true,
}

firstLoad = false

addEvent("returnValue", true)
addEventHandler("returnValue", root,
    function(sourceElement, rtype, args)
        if source and source == localPlayer then
            if sourceElement and sourceElement == localPlayer then
                if rtype == "items" then
                    local neededElement = args[1]
                    
                    if not invElement then
                        invElement = neededElement
                    end
                    
                    local eType = getEType(neededElement)
                    --outputChatBox("ETYPE:" .. eType)
                    local eId = getEID(neededElement)
                    --outputChatBox("EID:" .. eId)
                    local items = args[2]
                    checkTableArray(eType, eId)
                    
                    cache[eType][eId] = items
                    --[[
                    for i = 1, 4 do
                        checkTableArray(eType, eId, i)
                    end]]
                    
                    if isTimer(clickTimer) then killTimer(clickTimer) end
                    
                    if not disableThisInt[args[3]] then
                        if invType then
                            fullWeight = getWeight(invElement, invType)
                        end
                        
                        if state then
                            if moveState then
                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                moveDetails = nil
                            end
                        end
                    end
                    
                    --outputChatBox("YEE")
                    if not firstLoad then
                        --outputChatBox("firstLoad:"..tostring(firstLoad))
                        attachWeapons()
                        firstLoad = true
                    end
                    
                    --outputDebugString(eType.." - "..eId.." got trigger ["..rtype.."], Returnvalue: "..toJSON(args[2]).. " [Client]", 0, 200, 100, 85)
                end
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if localPlayer:getData("loggedIn") then
            --local res = getThisResource()
            if getElementData(root, "loaded") then
                --outputChatBox("Betöltés .. 1")
                triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                if isTimer(stateTimer) then killTimer(stateTimer) end
                stateTimer = setTimer(
                    function()
                        local playerItems = getItems(localPlayer, 1)
                        local playerItems2 = getItems(localPlayer, 2)
                        local isBankTicket = false
                        local ticketCost = 0
                        
                        --outputChatBox("asd12")
                        for slot, data in pairs(playerItems2) do
                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                            --outputChatBox(itemid)
                            if itemid == 128 then
                                --outputChatBox(tostring(tonumber(value["timestamp"]) < getRealTime()["timestamp"]))
                                if(tonumber(value["timestamp"]) < getRealTime()["timestamp"]) then
                                    --outputChatBox("asd2")
                                    --local value = 
                                    cache[1][accID][2][slot] = nil
                                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 2)
                                    triggerServerEvent("payTicketBank", localPlayer, localPlayer, value, slot)
--                                    triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, value["cost"] * 2, "removeMoneyFromBank2")
                                    ticketCost = ticketCost + (value["cost"] * 2)
                                    isBankTicket = true
                                end
                            end 
                        end
                        
                        for slot, data in pairs(playerItems) do
                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)                            
                            if items[itemid][7] and not items[itemid][6] then
                                if status - 1 >= 0 then
                                    status = status - 1
                                    cache[1][accID][1][slot][5] = status
                                    triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, status)
                                end
                            end
                        end
                        
                        if isBankTicket then
                            exports['cr_infobox']:addBox("warning", "Mivel nem fizetted be időben a csekkeidet ezért azoknak 200%-a lett levonva a bankszámládról! ("..ticketCost..")")
                            triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, ticketCost, "removeMoneyFromBank2")
                        end
                    end, 10 * 60 * 1000, 0
                )
            end
        end
    end
)

cuffed = localPlayer:getData("char >> cuffed")
tazed = localPlayer:getData("char >> tazed")
jailed = localPlayer:getData("char >> ajail")
inventoryForceDisabled = localPlayer:getData("inv >> forceDisabled")

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "usingRadio.frekv" then
            if localPlayer:getData("usingRadio") then
                local slot = tonumber(localPlayer:getData("usingRadio.slot"))
                local value = tonumber(localPlayer:getData("usingRadio.frekv"))
                
                updateItemDetails(localPlayer, slot, 1, {"value", value})
                cache[1][accID][1][slot][3] = value
            end
        elseif dName == "loggedIn" then
            local value = source:getData(dName)
            if value then
                --local res = getThisResource()
                if getElementData(root, "loaded") then
                    --outputChatBox("Betöltés .. 2")
                    triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                    if isTimer(stateTimer) then killTimer(stateTimer) end
                    stateTimer = setTimer(
                        function()
                            local playerItems = getItems(localPlayer, 1)
                            local playerItems2 = getItems(localPlayer, 2)
                            local isBankTicket = false

                            --outputChatBox("asd12")
                            for slot, data in pairs(playerItems2) do
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                --outputChatBox(itemid)
                                if itemid == 128 then
                                    --outputChatBox(tostring(tonumber(value["timestamp"]) < getRealTime()["timestamp"]))
                                    if(tonumber(value["timestamp"]) < getRealTime()["timestamp"]) then
                                        --outputChatBox("asd2")
                                        --local value = 
                                        cache[1][accID][2][slot] = nil
                                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 2)
                                        triggerServerEvent("payTicketBank", localPlayer, localPlayer, value, slot)
                                        triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, value["cost"] * 2, "removeMoneyFromBank")
                                        isBankTicket = true
                                    end
                                end 
                            end

                            for slot, data in pairs(playerItems) do
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)                            
                                if items[itemid][7] and not items[itemid][6] then
                                    if status - 1 >= 0 then
                                        status = status - 1
                                        cache[1][accID][1][slot][5] = status
                                        triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, status)
                                    end
                                end
                            end

                            if isBankTicket then
                                exports['cr_infobox']:addBox("warning", "Mivel nem fizetted be időben a csekkeidet ezért azoknak 200%-a lett levonva a bankszámládról!")
                            end
                        end, 10 * 60 * 1000, 0
                    )
                end
            end
        elseif dName == "char >> cuffed" then
            local value = source:getData(dName)
            cuffed = value
            if value then
                hideWeapon()
            end
        elseif dName == "char >> tazed" then
            local value = source:getData(dName)
            tazed = value
            if value then
                hideWeapon()
            end
        elseif dName == "char >> ajail" then
            local value = source:getData(dName)
            jailed = value 
            if value then
                hideWeapon()
            end
        elseif dName == "inv >> forceDisabled" then
            local value = source:getData(dName)
            inventoryForceDisabled = value
            if value then
                --outputChatBox("asd")
                hideWeapon()
            end
        elseif dName == "char >> death" then
            local value = source:getData(dName)
            charDeath = value
        elseif dName == "inDeath" then
            local value = source:getData(dName)
            inDeath = value
        elseif dName == "acc >> id" then
            local value = source:getData(dName)
            accID = value
        elseif dName == "interface.drawn" then
            local value = source:getData(dName)
            interfaceDrawn = value
        end
    end
)

charDeath = localPlayer:getData("char >> death")
inDeath = localPlayer:getData("inDeath")
accID = localPlayer:getData("acc >> id")
interfaceDrawn = localPlayer:getData("interface.drawn")

setTimer(
    function()
        if invElement then
            if invElement.type == "vehicle" then
                local val = invElement:getData("inventory.open")
                if not val then
                    invElement:setData("inventory.open", localPlayer)
                end                
            elseif invElement.type == "object" then
                local val = invElement:getData("inventory.open2")
                if not val then
                    invElement:setData("inventory.open2", localPlayer)
                end                
            end
        end
    end, 50, 0
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "inventory.open2" then
            if source == invElement then
                --[[
                local value = source:getData(dName)
                if value then
                    if value ~= localPlayer then -- EZ MÜKÖDÖTT
                        closeInventory()
                    end
                end]]
                local value = source:getData(dName)
                if value then
                    if oValue then
                        if val ~= oValue then
                            if localPlayer == val then
                                closeInventory()
                            end
                        end
                    end
                end
            end
        elseif dName == "inventory.open" then
            if source == invElement then
                local value = source:getData(dName)
                if value then
                    if oValue then
                        if val ~= oValue then
                            if localPlayer == val then
                                closeInventory()
                            end
                        end
                    end
                end
            end
            --[[
            if source.type == "object" then
                local value = source:getData(dName)
                if value then
                    --outputChatBox("1829re Change")
                    setElementModel(source, 1829)
                    --source.model = 1829
                else
                    --outputChatBox("1829re Vissza")
                    setElementModel(source, 2332)
                    --source.model = 2332
                end
            end]]
        elseif dName == "loaded" then
            local value = getElementData(root, "loaded")
            if value then
                if localPlayer:getData("loggedIn") then
                    --outputChatBox("Betöltés .. 3")
                    triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                    if isTimer(stateTimer) then killTimer(stateTimer) end
                    stateTimer = setTimer(
                        function()
                            local playerItems = getItems(localPlayer, 1)
                                
                            for slot, data in pairs(playerItems) do
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                                if items[itemid][7] and not items[itemid][6] then
                                    if status - 1 >= 0 then
                                        status = status - 1
                                        cache[1][accID][1][slot][5] = status
                                        triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, status)
                                    end
                                end
                            end
                        end, 5 * 60 * 1000, 0
                    )
                end
            end
        end
    end
)

lastOpenTick = 0
lastClickTick = 0

bindKey("I", "down", 
    function()
        --local res = getThisResource()
        if not getElementData(root, "loaded") then return end
        if getElementData(localPlayer, "score >> bar") then return end
        if exports['cr_network']:getNetworkStatus() then return end
        
        if localPlayer:getData("loggedIn") then
            --outputChatBox("oppen")
            state = not state
            if state then
                --[[
                local now = getTickCount()
                local a = 2
                if now <= lastOpenTick + a * 1000 then
                    local syntax = getServerSyntax("Inventory", "warning")
                    outputChatBox(syntax .. "Az inventory-t csak "..a.." másodpercenként nyithatod meg!", 255,255,255,true)
                    state = false
                    return
                end
                ]]
                lastOpenTick = getTickCount()
                
                openInventory(localPlayer)
            else
                lastOpenTick = getTickCount()
                closeInventory(localPlayer)
            end
        end
    end
)

function showInventory(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "showinventory") then
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
            return 
        end

        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if target then
            state = true
            openInventory(target, true)
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Nincs ilyen játékos",255,255,255,true)
        end
    end
end
_addCommandHandler("showinv", showInventory)
_addCommandHandler("showInv", showInventory)
_addCommandHandler("showinventory", showInventory)
_addCommandHandler("showInventory", showInventory)

invType = 1

function openInventory(e, spec, def)
    if def then
        state = true
    end
    if charDeath or inDeath then return end
    
    if exports['cr_network']:getNetworkStatus() then return end
	
	if not localPlayer:getData("enabledInventory") then return end
	if localPlayer:getData("keysDenied") then return end
	
    if invElement and invElement.type == "vehicle" then
        if invType == specTypes["vehicle.in"] then
            setElementData(invElement, "inventory.open2", false)
            --exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű kesztyűtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
        else
            --exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
            setElementData(invElement, "inventory.open", false)
        end
    elseif invElement and invElement.type == "object" then
        --exports['cr_chat']:createMessage(localPlayer, "bezárja egy közelében lévő széf ajtaját", 1)
        setElementData(invElement, "inventory.open", false)
    end
    
    invElement = e
    elementID = getEID(e)
    elementType = getEType(e)
    
    alpha = 0
    multipler = 20
    lastItem = 0
    
    if specTypes[e.type] then
        invType = specTypes[e.type]
    else
        if invType >= 5 then
            invType = 1
        end
    end
    
    checkTableArray(elementID, elementType, invType)
    if moveState then
        cache[elementType][elementID][invType][moveSlot] = moveDetails
    end
    
    moveState = false
    moveInteractDisabled = spec
    moveDetails = nil
    
    start = true
    
    x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    addEventHandler("onClientRender", root, drawnInventory, true, "low-5")
    CreateNewBar("stack", {x + 4, y + 2, 60, 18}, {4, "", true, tocolor(255,255,255,255), font4, 1, "center", "center"}, 1)
    --triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
    
    if e ~= localPlayer then
        triggerServerEvent("needValue", localPlayer, localPlayer, "items", e)
    end
    
    fullWeight = getWeight(invElement, invType)
end

function closeInventory(e)
    --removeEventHandler("onClientRender", root, drawnInventory)
    start = false
    --triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
    --triggerServerEvent("needValue", localPlayer, localPlayer, "items", e)
end

cminLines, cmaxLines = 1, 6
gdata = {}

function drawnInventory()
    if charDeath or inDeath then 
        --outputChatBox("death")
        if moveState then
            moveState = false
            playSound("assets/sounds/move.mp3")
            if stacking then
                --local data = cache[elementType][elementID][invType][moveSlot]
                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                stacking = false
            end
            cache[elementType][elementID][invType][moveSlot] = moveDetails
            moveDetails = nil
        end
        start = false
    end
    
    if exports['cr_network']:getNetworkStatus() then 
        --outputChatBox("network")
        if moveState then
            moveState = false
            playSound("assets/sounds/move.mp3")
            if stacking then
                --local data = cache[elementType][elementID][invType][moveSlot]
                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                stacking = false
            end
            cache[elementType][elementID][invType][moveSlot] = moveDetails
            moveDetails = nil
        end
        start = false
    end
    
    if invElement.type ~= "player" then
        --outputChatBox("invElement")
        if getDistanceBetweenPoints3D(invElement.position, localPlayer.position) > (invElement.type == "vehicle" and 5 or 3) then
            if moveState then
                moveState = false
                playSound("assets/sounds/move.mp3")
                if stacking then
                    --local data = cache[elementType][elementID][invType][moveSlot]
                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                    stacking = false
                end
                cache[elementType][elementID][invType][moveSlot] = moveDetails
                moveDetails = nil
            end
            start = false
        end
        
        if invElement.type == "vehicle" then
            if not invElement:getData("veh >> boot") and invType == specTypes["vehicle"] then
                if moveState then
                    moveState = false
                    playSound("assets/sounds/move.mp3")
                    if stacking then
                        --local data = cache[elementType][elementID][invType][moveSlot]
                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                        stacking = false
                    end
                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                    moveDetails = nil
                end
                start = false
            end
        end
    end
    
    if moveState and not isCursorShowing() then
        --outputChatBox("IsCursorShowing()")
        moveState = false
        playSound("assets/sounds/move.mp3")
        if stacking then
            --local data = cache[elementType][elementID][invType][moveSlot]
            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
            stacking = false
        end
        cache[elementType][elementID][invType][moveSlot] = moveDetails
        moveDetails = nil
    end
    
    if start then
        if alpha + multipler <= 255 then
            alpha = alpha + multipler
        elseif alpha > 255 then
            alpha = 255
        end
    else
        if alpha - multipler >= 0 then
            alpha = alpha - multipler
        elseif alpha <= 0 then
            alpha = 0
            if invElement.type == "vehicle" then
                if invType == specTypes["vehicle.in"] then
                    setElementData(invElement, "inventory.open2", false)
                    exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű kesztyűtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                else
                    --exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                    setElementData(invElement, "inventory.open", false)
                end
            elseif invElement.type == "object" then
                exports['cr_chat']:createMessage(localPlayer, "bezárja egy közelében lévő széf ajtaját", 1)
                setElementData(invElement, "inventory.open", false)
            end
            stacking = false
            invElement = localPlayer
            removeEventHandler("onClientRender", root, drawnInventory)
            Clear()
            state = false
            return
        end
    end
    
    
    font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    font3 = exports['cr_fonts']:getFont("Rubik-Regular", 10)
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    
    x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
    UpdatePos("stack", {x + 4, y + 2, 60, 18})
    local _x, _y = x, y
    x = x - 110
    y = y - 174
    
    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
    local cx, cy = x, y
    
    local line = 1
    local column = 1
    local startX = _x + (6)
    local _startX = startX
    local startY = _y + (28)
    
    local data = cache[elementType][elementID][invType]
    
    if not data then
        checkTableArray(elementType, elementID, invType)
    end
    
    dxDrawImage(cx, cy, w, h, textures["bg"], 0,0,0, tocolor(255,255,255,alpha))
    
    --local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
    if invType == specTypes["vehicle"] then
        dxDrawImage(cx, cy, w, h, textures["vehicons"], 0,0,0, tocolor(255,255,255,alpha))
    elseif invType == specTypes["vehicle.in"] then
        dxDrawImage(cx, cy, w, h, textures["vehicons"], 0,0,0, tocolor(255,255,255,alpha))
    elseif invType == specTypes["object"] then
        dxDrawImage(cx, cy, w, h, textures["safeicons"], 0,0,0, tocolor(255,255,255,alpha))
    else
        dxDrawImage(cx, cy, w, h, textures["icons"], 0,0,0, tocolor(255,255,255,alpha))
    end
    
    if invType ~= 4 then
        local maxWeight = typeDetails[invType][2]
        local multipler = math.min(fullWeight / maxWeight, 1)
        local w = (490 - 110) * multipler
        w = 110 + w
        if multipler >= 1 then
            w = w + (600 - w)
        end

        --dxDrawRectangle(_x + 4, _y + 2, 65, 18)

        --CreateNewBar("stack", {_x + 4, _y + 2, 65, 18}, {15, "", false, tocolor(255,255,255,255), font, 1, "center", "center"}, 1)

        local h = drawnSize["weight"][2]
        dxDrawImageSection(cx, cy, w, h, 0, 0, w, h, textures["weight"], 0,0,0, tocolor(255,255,255,alpha))

        local w, h = realSize["bg"][1], realSize["bg"][2]
        local x, y = _x + w/2, _y + h - 23
        dxDrawText(math.floor(multipler * 100) .. "%", x, y, x, y + 22.5, tocolor(255,255,255,math.min(255 * 0.76, alpha)), 1, font, "center", "center")
    end    
    
    if invType == 4 then
        
        if isCrafting then
            local now = getTickCount()
            local elapsedTime = now - startTick
            local duration = endTick - startTick
            local multipler = elapsedTime / duration
            local w = (490 - 110) * multipler
            w = 110 + w
            if multipler >= 1 then
                w = w + (600 - w)
            end

            --dxDrawRectangle(_x + 4, _y + 2, 65, 18)

            --CreateNewBar("stack", {_x + 4, _y + 2, 65, 18}, {15, "", false, tocolor(255,255,255,255), font, 1, "center", "center"}, 1)

            local h = drawnSize["weight"][2]
            dxDrawImageSection(cx, cy, w, h, 0, 0, w, h, textures["weight"], 0,0,0, tocolor(255,255,255,alpha))

            local w, h = realSize["bg"][1], realSize["bg"][2]
            local x, y = _x + w/2, _y + h - 23
            dxDrawText(math.floor(multipler * 100) .. "%", x, y, x, y + 22.5, tocolor(0,0,0,math.min(255 * 0.76, alpha)), 1, font, "center", "center")
        end    
        
        --CraftPositions:
        positions = {
            {_x + 7, _y + 52, 168, 20},
            {_x + 7, _y + 52 + 22, 168, 20},
            {_x + 7, _y + 52 + 22*2, 168, 20},
            {_x + 7, _y + 52 + 22*3 + 2, 168, 20},
            {_x + 7, _y + 52 + 22*4 + 4, 168, 20},
            {_x + 7, _y + 52 + 22*5 + 4, 168, 20},
        }
        --outputChatBox("asd")
        local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
        dxDrawImage(cx, cy, w, h, textures["craftBG"], 0,0,0, tocolor(255,255,255,alpha))
        --dxDrawRectangle(_x + 7 + 168/2 - 60/2 - 5, _y + 52 + 22*5 + 4 + 29, 60, 20)
        
        cActive = nil
        if isInSlot(unpack(positions[1])) or cSelected == 1 then
            dxDrawImage(cx, cy, w, h, "assets/craft/1-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 1
        elseif isInSlot(unpack(positions[2])) or cSelected == 2 then
            dxDrawImage(cx, cy, w, h, "assets/craft/2-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 2
        elseif isInSlot(unpack(positions[3])) or cSelected == 3 then
            dxDrawImage(cx, cy, w, h, "assets/craft/3-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 3
        elseif isInSlot(unpack(positions[4])) or cSelected == 4 then
            dxDrawImage(cx, cy, w, h, "assets/craft/4-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 4
        elseif isInSlot(unpack(positions[5])) or cSelected == 5 then
            dxDrawImage(cx, cy, w, h, "assets/craft/5-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 5
        elseif isInSlot(unpack(positions[6])) or cSelected == 6 then
            dxDrawImage(cx, cy, w, h, "assets/craft/6-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 6
        else
            dxDrawImage(cx, cy, w, h, "assets/craft/all_deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        end
        
        if isInSlot(_x + 7 + 168/2 - 60/2 - 5, _y + 52 + 22*5 + 4 + 29, 60, 20) then
            dxDrawImage(cx, cy, w, h, "assets/craft/button-active.png", 0,0,0, tocolor(255,255,255,alpha))
            cActive = 7 -- 7 / Button
        else
            dxDrawImage(cx, cy, w, h, "assets/craft/button-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
        end
        
        local index, num = 1, 1
        --gdata = {}
        
        --outputChatBox(cminLines .. "a")
        --outputChatBox(cmaxLines .. "b")
        for k, v in pairs(craftG) do
            local ctype, listed, citems = unpack(v)
            
            if listed then
                if index >= cminLines and index <= cmaxLines then
                    local x, y, w, h = unpack(positions[num])
                    w = w + x
                    h = h + y
                    if isInSlot(x, y, w - x, h - y) then
                        dxDrawText(ctype..":", x, y, w, h, tocolor(0,0,0,alpha), 1, font4, "center", "center")
                    else
                        dxDrawText(ctype..":", x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                    end
                    num = num + 1
                end

                for k2,v2 in pairs(citems) do
                    local itemdata, crafttime, cdata, needed = unpack(v2)
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                    index = index + 1
                    if index >= cminLines and index <= cmaxLines then
                        --outputChatBox(num)
                        local x, y, w, h = unpack(positions[num])
                        local _w = w
                        w = w + x
                        h = h + y

                        if isInSlot(x, y, w - x, h - y) then
                            --outputChatBox(text)
                            renderTooltip(x + _w/2 - 19, y, cdata, alpha, true)
                            
                            dxDrawText(getItemName(itemid), x, y, w, h, tocolor(0,0,0,alpha), 1, font3, "center", "center")
                        else
                            dxDrawText(getItemName(itemid), x, y, w, h, tocolor(255,255,255,alpha), 1, font3, "center", "center")
                        end

                        num = num + 1
                    end    
                end
            else
                if index >= cminLines and index <= cmaxLines then
                    local x, y, w, h = unpack(positions[num])
                    w = w + x
                    h = h + y
                    if isInSlot(x, y, w - x, h - y) then
                        dxDrawText(ctype, x, y, w, h, tocolor(0,0,0,alpha), 1, font4, "center", "center")
                    else
                        dxDrawText(ctype, x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                    end
                    num = num + 1
                end
            end
            index = index + 1
        end
            
        local startX, startY = _x + 7 + 168 + 10, _y + 28
        local _startX = startX
        local tooltip = false
        local column, line = 1, 1
        local breakColumn = 5
        for i = 1, 5*5 do
            local isIn = false
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            if isInSlot(startX, startY, w, h) then
                dxDrawRectangle(startX, startY, w, h, tocolor(255, 153, 51, math.min(255 * 0.8, alpha)))
                isIn = true
                _lastItem = lastItem
                lastItem = i
            elseif gdata[i] and hasData[i] then
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 255, 51, math.min(63.75, alpha)))
            elseif gdata[i] and not hasData[i] then
                dxDrawRectangle(startX, startY, w, h, tocolor(255, 51, 51, math.min(63.75, alpha)))
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(52, 52, 52,math.min(63.75, alpha)))
            end

            if gdata then
                local data = gdata[i]
                if data then
                    local id = 5000
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)

                    if isIn then
                        tooltip = i

                        if _lastItem ~= i and not interfaceDrawn then
                            playSound("assets/sounds/hover.mp3")
                            lastItem = i
                        end
                    end
                    local _w = w
                    local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]
                    local b = 1

                    if dutyitem == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(255, 51, 51, math.min(63.75, alpha)))
                    end

                    if premium == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(51, 255, 51, math.min(63.75, alpha)))
                    end

                    dxDrawImage(startX + b, startY + b, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,alpha))

                    local count = count or 1
                    if count >= 2 then
                        dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                    end
                end
            end

            if tooltip then
                local data = gdata[tooltip]
                renderTooltip(startX, startY, data, alpha)
                tooltip = false
            end

            startX = startX + drawnSize["bg_cube"][1] + between
            column = column + 1
            if column > breakColumn then
                startY = startY + drawnSize["bg_cube"][2] + between
                startX = _startX
                column = 1
                line = line + 1
            end
        end
    else
        local tooltip = false
        for i = 1, maxLines * maxColumn do    
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            local isActive = false
            if activeSlot[invType .. "-" .. i] then
                if invElement == localPlayer then
                    isActive = true
                end
            end

            if isInSlot(startX, startY, w, h) then
                dxDrawRectangle(startX, startY, w, h, tocolor(255, 153, 51, math.min(255 * 0.8, alpha)))
                isIn = true
                _lastItem = lastItem
                lastItem = i
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(52, 52, 52,math.min(63.75, alpha)))
            end

            if isActive and not isIn then
                dxDrawRectangle(startX, startY, w, h, tocolor(85, 255, 51, math.min(255 * 0.8, alpha)))
            end

            if data then
                local data = data[i]
                if data then
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    if not items[itemid] or not items[itemid][1] then
                        cache[elementType][elementID][invType][i] = nil
                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, invType)
                    end

                    if isIn then
                        tooltip = i

                        if _lastItem ~= i and not interfaceDrawn then
                            playSound("assets/sounds/hover.mp3")
                            lastItem = i
                        end
                    end
                    local _w = w
                    local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]
                    local b = 1

                    if dutyitem == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(255, 51, 51, math.min(63.75, alpha)))
                    end

                    if premium == 1 and not isIn and not isActive then
                        dxDrawRectangle(startX, startY, _w, _w, tocolor(51, 255, 51, math.min(63.75, alpha)))
                    end

                    dxDrawImage(startX + b, startY + b, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,alpha))
                    if cuffed or jailed or inventoryForceDisabled or tazed then
                        dxDrawImage(startX + b, startY + b, w, h, "assets/images/delete.png", 0,0,0, tocolor(255,255,255,alpha))
                    end

                    local count = count or 1
                    if count >= 2 then
                        dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                    end
                end
            end

            if tooltip then
                local data = data[tooltip]
                if data then
                    renderTooltip(startX, startY, data, alpha)
                    tooltip = false
                end
            end

            startX = startX + drawnSize["bg_cube"][1] + between
            column = column + 1
            if column > breakColumn then
                startY = startY + drawnSize["bg_cube"][2] + between
                startX = _startX
                column = 1
                line = line + 1
            end
        end
    end
    
    if moveState then
        if invElement == localPlayer then
            local w, h = getNode("Inventory", "width"), getNode("Inventory", "height")
            if isInSlot(_x + w/2 - 100/2, _y - 120, 100, 100) then
                dxDrawImage(_x + w/2 - 100/2, _y - 120, 100, 100, "assets/images/eye.png", 0,0,0, tocolor(255,240,240,alpha))
            else
                dxDrawImage(_x + w/2 - 100/2, _y - 120, 100, 100, "assets/images/eye.png", 0,0,0, tocolor(255,255,255,math.min(200,alpha)))
            end
        end
        --dxDrawText(x, y, )
        
        local cx, cy = getCursorPosition()
        local x, y = cx - ax, cy - ay
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
        local w, h = drawnSize["bg_cube_img"][1], drawnSize["bg_cube_img"][2]
        dxDrawImage(x, y, w, h, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,alpha))
        
        dxDrawText(count,x, x, x + w, y + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
    end
    --dxDrawRectangle(_x + w/2 - 200/2, _y + h - 23, 200, 20)
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if state then
            if invElement.type == "vehicle" then
                if invType == specTypes["vehicle.in"] then
                    setElementData(invElement, "inventory.open2", false)
                else
                    setElementData(invElement, "inventory.open", false) 
                end
            elseif invElement.type == "object" then
                setElementData(invElement, "inventory.open", false)
            end
        end
    end
)

isEnabledTypeForOpen = {
    ["Automobile"] = true,
    ["Plane"] = true,
    ["Helicopter"] = true,
    ["Boat"] = true,
    --["Bike"] = true, // ?!
}

isEnabledTypeForOpen2 = {
    ["Automobile"] = true,
    ["Plane"] = true,
    ["Helicopter"] = true,
    ["Boat"] = true,
    --["Bike"] = true, // ?!
}

addEventHandler("onClientClick", root,
    function(b, s, abX, abY, wx, wy, wz, worldE)
        if charDeath or inDeath then 
            if moveState then
                moveState = false
                playSound("assets/sounds/move.mp3")
                if stacking then
                    --local data = cache[elementType][elementID][invType][moveSlot]
                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                    stacking = false
                end
                cache[elementType][elementID][invType][moveSlot] = moveDetails
                moveDetails = nil
            end
            return 
        end
        
        if exports['cr_network']:getNetworkStatus() then 
            if moveState then
                moveState = false
                playSound("assets/sounds/move.mp3")
                if stacking then
                    --local data = cache[elementType][elementID][invType][moveSlot]
                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                    stacking = false
                end
                cache[elementType][elementID][invType][moveSlot] = moveDetails
                moveDetails = nil
            end
            return
        end
        
        if b == "right" and s == "down" then
            
            --if not state then
            if invElement == localPlayer then
                local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")

                if localPlayer:getData("Actionbar.enabled") and isInSlot(ax, ay, aw, ah) then
                    acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                    --outputChatBox(acType)
                    if acType == 1 then
                        local startX = ax + 1
                        local startY = ay + 2

                        checkTableArray(1, accID, 10)
                        local data = cache[1][accID][10]
                        --cache[1][accID][10] = {}
                        --cache[1][accID][10][1] = {1, 1}
                        ----outputChatBox("")
                        local tooltip = false
                        for i = 1, columns do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            local isIn = false
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local _invType = invType
                                        local invType, pairSlot, id = unpack(data)
                                        local data = cache[1][accID][invType][pairSlot]
                                        if moveState then
                                            if pairSlot == moveSlot and invType == _invType then
                                                data = moveDetails
                                            end
                                        end
                                        if data then
                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, 10)
                                            cache[1][accID][10][i] = nil
                                            playSound("assets/sounds/move.mp3")
                                            return
                                        end
                                    end
                                end
                            end

                            startX = startX + w + 1
                        end
                    elseif acType == 2 then
                        local ax = ax - 2

                        local startX = ax + 2
                        local startY = ay + 1

                        local data = cache[1][accID][10]
                        local tooltip = false
                        for i = 1, columns do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            local isIn = false
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local _invType = invType
                                        local invType, pairSlot, id = unpack(data)
                                        local data = cache[1][accID][invType][pairSlot]
                                        if moveState then
                                            if pairSlot == moveSlot and invType == _invType then
                                                data = moveDetails
                                            end
                                        end
                                        if data then
                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i, 10)
                                            cache[1][accID][10][i] = nil
                                            playSound("assets/sounds/move.mp3")
                                            return
                                        end
                                    end
                                end
                            end

                            startY = startY + h + 1
                        end
                    end
                end
            end
            
            if state then
                if invType == specTypes["vehicle.in"] then
                    local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                    local _x, _y = x, y
                    x = x - 110
                    y = y - 174

                    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                    local cx, cy = x, y

                    local line = 1
                    local column = 1
                    local startX = _x + (6)
                    local _startX = startX
                    local startY = _y + (28)

                    local data = cache[elementType][elementID][invType]

                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                ----outputChatBox("asd")
                                if data then
                                    local data = data[i]
                                    if data then
                                        local slot = i
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                
                                        if dutyitem == 1 then
                                            local syntax = getServerSyntax("Inventory", "error")
                                            outputChatBox(syntax .. "Ez a tárgy nem átadható (Dutyitem)!", 255,255,255,true)
                                            
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end
                                        
                                        local canMove = items[itemid][8]
                                        if not canMove then
                                            local syntax = getServerSyntax("Inventory", "error")
                                            outputChatBox(syntax .. "Ez a tárgy nem átadható!", 255,255,255,true)
                                            
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end

                                        --outputChatBox(invType)
                                        local a2 = items[itemid][2]
                                        local itemName = getItemName(itemid, value, nbt)
                                        
                                        --outputChatBox("Itemátadás magadnak de csomiból.")
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end
                                        
                                        exports['cr_chat']:createMessage(localPlayer, "kivesz egy tárgyat a jármű kesztyűtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                                        
                                        
                                        triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, localPlayer, invType, a2, data, slot)
                                        --useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt)
                                        
                                        cache[elementType][elementID][invType][moveSlot] = nil
                                        moveDetails = nil
                                        
                                        fullWeight = getWeight(invElement, invType)
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                elseif invElement == localPlayer then
                    local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                    local _x, _y = x, y
                    x = x - 110
                    y = y - 174

                    local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                    local cx, cy = x, y

                    local line = 1
                    local column = 1
                    local startX = _x + (6)
                    local _startX = startX
                    local startY = _y + (28)

                    local data = cache[elementType][elementID][invType]
                    
                    --local data2 = cache[1][elementID][invType]
                    
                    local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                    local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
                        
                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                ----outputChatBox("asd")
                                if data then
                                    local data = data[i]
                                    if data then
                                        local slot = i
                                        
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --outputChatBox("UseItem: "..itemid)
                                        useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt)
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                end
            end
        end
        
        if state then
            if b == "middle" and s == "down" and invType == 4 then
                local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                local _x, _y = x, y
                x = x - 110
                y = y - 174

                local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                local cx, cy = x, y

                local line = 1
                local column = 1
                local index = 0
                local startX = _x + (6)
                local _startX = startX
                local startY = _y + (28)
                
                if invElement == localPlayer and invType == 4 then
                    local num = 0
                    for k, v in pairs(craftG) do
                        local ctype, listed, citems = unpack(v)

                        if listed then
                            if index >= cminLines and index <= cmaxLines then
                                --local x, y, w, h = unpack(positions[num])
                                --w = w + x
                                --h = h + y
                                --dxDrawText(ctype..":", x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                                num = num + 1
                                --[[
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        hasData = {}
                                        ginfo = nil
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end]]
                            end

                            --[[
                            for k2,v2 in pairs(citems) do
                                local itemdata, crafttime, cdata, needed = unpack(v2)
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                                index = index + 1
                                if index >= cminLines and index <= cmaxLines then
                                    --outputChatBox(num)
                                    --local x, y, w, h = unpack(positions[num])
                                    --w = w + x
                                    --h = h + y

                                    --dxDrawText(getItemName(itemid), x, y, w, h, tocolor(255,255,255,alpha), 1, font3, "center", "center")

                                    num = num + 1
                                    if cActive == num then
                                        
                                        local faction, location, blueprint, hammer = unpack(cdata)
                                        
                                        local syntax = exports['cr_core']:getServerSyntax("Craft", "success")
                                        outputChatBox(syntax .. getItemName(itemid) .. " információi:",255,255,255,true)
                                        local color = "#ffffff"--exports['cr_core']:getServerColor(nil, true)
                                        outputChatBox(color.."Frakció: "..(faction and "#00ff00Szükséges" or "#ff0000Nem szükséges"),255,255,255,true)
                                        outputChatBox(color.."Pozició: "..(location and "#00ff00Szükséges" or "#ff0000Nem szükséges"),255,255,255,true)
                                        outputChatBox(color.."Megfelelő tudás (Blueprint): "..(blueprint and "#00ff00Szükséges" or "#ff0000Nem szükséges"),255,255,255,true)
                                        outputChatBox(color.."Kalapács: "..(hammer and "#00ff00Szükséges" or "#ff0000Nem szükséges"),255,255,255,true)
                                        
                                        --cSelected = cActive
                                    end
                                end    
                            end]]
                        else
                            if index >= cminLines and index <= cmaxLines then
                                --local x, y, w, h = unpack(positions[num])
                                --w = w + x
                                --h = h + y
                                --dxDrawText(ctype, x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                                num = num + 1
                                --[[
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        ginfo = nil
                                        hasData = {}
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end]]
                            end
                        end
                        index = index + 1
                    end
                end
            elseif b == "left" and s == "down" then
                local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                local _x, _y = x, y
                x = x - 110
                y = y - 174

                local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                local cx, cy = x, y

                local line = 1
                local column = 1
                local startX = _x + (6)
                local _startX = startX
                local startY = _y + (28)
                
                if invElement == localPlayer and invType == 4 then
                    local index, num = 1, 1
                    --gdata = {}
                    
                    if cActive == 7 then
                        if gdata and ginfo then
                            local now = getTickCount()
                            local a = 5
                            if now <= lastClickTick + a * 1000 then
                                local syntax = getServerSyntax("Inventory", "warning")
                                outputChatBox(syntax .. "Csak "..a.." másodpercenként craftolhatsz!", 255,255,255,true)
                                return
                            end
                            
                            lastClickTick = getTickCount()
                            local breaked = false
                            for k,v in pairs(gdata) do
                                if not hasData[k] then
                                    breaked = true
                                end
                            end
                            
                            if not breaked then
                                local itemdata, crafttime, cdata, needed = unpack(ginfo)
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                                local faction, location, blueprint, hammer = unpack(cdata)
                                
                                if faction and type(faction) == "table" then
                                    if faction[tonumber(localPlayer:getData("char->faction") or 0)] then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő szervezetben kell légy!", 255,255,255,true)
                                        return
                                    end
                                end
                                
                                if location and type(location) == "table" then
                                    local shortest = 0
                                    for k,v in pairs(location) do
                                        local dist = getDistanceBetweenPoints3D(localPlayer.position, unpack(v))
                                        if dist <= shortest then
                                            shortest = dist
                                        end
                                    end
                                    
                                    if shortest >= 5 then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő helyen kell légy!", 255,255,255,true)
                                        return
                                    end
                                end
                                
                                if blueprint and type(blueprint) == "table" then
                                    local blueprints = localPlayer:getData("blueprints") or {}
                                    local has = true
                                    for k,v in pairs(blueprint) do
                                        if not blueprints[k] then
                                            has = false
                                            break
                                        end
                                    end
                                    
                                    if not has then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ahhoz, hogy ezt a tárgyat elkészíthesd a megfelelő tudást el kell sajátítanod (Blueprint)!", 255,255,255,true)
                                        return
                                    end
                                end
                                
                                if hammer then
                                    local isIsHand = localPlayer:getData("isHammerInHand")
                                    
                                    if not isHand then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ahhoz, hogy ezt a tárgyat elkészíthesd egy kalapácsnak a kezedben kell lennie!", 255,255,255,true)
                                        return
                                    end
                                end
                                
                                if cuffed or jailed or inventoryForceDisabled or tazed then
                                    return
                                end
                                
                                local eType = getEType(localPlayer)
                                local eId = getEID(localPlayer)
                                for k,v in pairs(gdata) do
                                    local iType = items[v[2]][2]
                                    local boolean, slot, data = unpack(hasData[k])
                                    if boolean then
                                        checkTableArray(eType, eId, iType)
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])
                                        if count - v[3] <= 0 then
                                            cache[eType][eId][iType][slot] = nil
                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, iType)
                                        else
                                            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, iType, count - v[3])
                                        end
                                    end
                                end
                                
                                isCrafting = true
                                startTick = getTickCount()
                                local b = crafttime * 1000
                                endTick = startTick + b
                                local syntax = getServerSyntax("Inventory", "warning")
                                outputChatBox(syntax .. "A tárgy készítése elkezdődött. ("..getItemName(itemid)..")", 255,255,255,true)
                                localPlayer:setData("forceAnimation", {"bd_fire", "wash_up"})
                                exports['cr_chat']:createMessage(localPlayer, "elkezdett elkészíteni egy tárgyat ("..getItemName(itemid)..")", 1)
                                craftSound = playSound("assets/sounds/craftSound.mp3", true)
                                
                                setTimer(
                                    function()
                                        isCrafting = false
                                        startTick = nil
                                        endTick = nil
                                        if isElement(craftSound) then destroyElement(craftSound) end
                                        craftSound = nil
                                        local syntax = getServerSyntax("Inventory", "success")
                                        outputChatBox(syntax .. "Sikeresen készítettél egy "..getItemName(itemid).."-at/et", 255,255,255,true)
                                        giveItem(localPlayer, itemid, value, count, status, dutyitem, premium, nbt)
                                        showItem({-5000, itemid, value, count, status, dutyitem, premium, nbt})

                                        exports['cr_chat']:createMessage(localPlayer, "elkészített egy tárgyat ("..getItemName(itemid)..")", "do")
                                        localPlayer:setData("forceAnimation", {"", ""})
                                    end, b, 1
                                )
                            else
                                local syntax = getServerSyntax("Inventory", "error")
                                outputChatBox(syntax .. "Ahhoz, hogy ezt a tárgyat elkészíthesd az összes szükséges tárgynak nálad kell legyen!", 255,255,255,true)
                                return
                            end
                        end
                    end
                    
                    local num = 0
                    for k, v in pairs(craftG) do
                        local ctype, listed, citems = unpack(v)

                        if listed then
                            if index >= cminLines and index <= cmaxLines then
                                --local x, y, w, h = unpack(positions[num])
                                --w = w + x
                                --h = h + y
                                --dxDrawText(ctype..":", x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                                num = num + 1
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        hasData = {}
                                        ginfo = nil
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end
                            end

                            for k2,v2 in pairs(citems) do
                                local itemdata, crafttime, cdata, needed = unpack(v2)
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                                index = index + 1
                                if index >= cminLines and index <= cmaxLines then
                                    --outputChatBox(num)
                                    --local x, y, w, h = unpack(positions[num])
                                    --w = w + x
                                    --h = h + y

                                    --dxDrawText(getItemName(itemid), x, y, w, h, tocolor(255,255,255,alpha), 1, font3, "center", "center")

                                    num = num + 1
                                    if cActive == num then
                                        gdata = needed
                                        ginfo = v2
                                        hasData = {}
                                        for k,v in pairs(gdata) do
                                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                                            if hasItem(localPlayer, itemid, value) then
                                                hasData[k] = {hasItem(localPlayer, itemid, value)}
                                            end
                                        end

                                        updateTimer = setTimer(
                                            function()
                                                hasData = {}
                                                for k,v in pairs(gdata) do
                                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                                                    if hasItem(localPlayer, itemid, value) then
                                                        hasData[k] = {hasItem(localPlayer, itemid, value)}
                                                    end
                                                end
                                            end, 1000, 0
                                        )
                                        gdatak = k
                                        --cSelected = cActive
                                    end
                                end    
                            end
                        else
                            if index >= cminLines and index <= cmaxLines then
                                --local x, y, w, h = unpack(positions[num])
                                --w = w + x
                                --h = h + y
                                --dxDrawText(ctype, x, y, w, h, tocolor(255,255,255,alpha), 1, font4, "center", "center")
                                num = num + 1
                                if cActive == num then
                                    v[2] = not v[2]
                                    craftG[k] = v
                                    if gdatak == k then
                                        gdata = {}
                                        ginfo = nil
                                        hasData = {}
                                        if isTimer(updateTimer) then killTimer(updateTimer) end
                                    end
                                end
                            end
                        end
                        index = index + 1
                    end
                end

                if not localPlayer:getData("enabledInventory") then return end
                if localPlayer:getData("keysDenied") then return end
                -- checkTableArray(elementType, elementId, invType) -- emiatt nem ment...
                
                if not cache[elementType] or not cache[elementType][elementID] or not cache[elementType][elementID][invType] then return end
                
                local data = cache[elementType][elementID][invType]
                
                if invElement.type == "player" then
                    for k,v in pairs(iconPositions) do
                        local ax, ay = unpack(v)
                        local w, h = 20,20
                        if isInSlot(_x + ax - w/2, _y + ay - h/2, w, h) then
                            if k ~= 4 then
                                if invType ~= k then
                                    playSound("assets/sounds/bincoselect.mp3")
                                end
                                invType = k
                                gdata = {}
                                ginfo = nil
                                hasData = {}
                                if isTimer(updateTimer) then killTimer(updateTimer) end
                                fullWeight = getWeight(invElement, invType)
                            else
                                if invElement == localPlayer then
                                    if invType ~= k then
                                        playSound("assets/sounds/bincoselect.mp3")
                                    end
                                    gdata = {}
                                    ginfo = nil
                                    hasData = {}
                                    if isTimer(updateTimer) then killTimer(updateTimer) end
                                    invType = k
                                end
                            end
                            --triggerServerEvent("needValue", localPlayer, localPlayer, "items", localPlayer)
                            --triggerServerEvent("needValue", localPlayer, localPlayer, "items", invElement)
                            return
                        end
                    end
                end
                
                if not moveState and not moveInteractDisabled then
                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local num = tonumber(textbars["stack"][2][2])
                                        if num then
                                            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[elementType][elementID][invType][i])
                                            local isStackable = items[itemid][4]
                                            if isStackable then
                                                if num <= count - 1 then
                                                    local isActive = false
                                                    if activeSlot[invType .. "-" .. i] then
                                                        if invElement == localPlayer then
                                                            isActive = true
                                                        end
                                                    end
                                                    if isActive then
                                                        moveState = false
                                                        --playSound("assets/sounds/move.mp3")
                                                        moveDetails = nil
                                                        return
                                                    end
                                                    
                                                    if cuffed or jailed or inventoryForceDisabled or tazed then
                                                        return
                                                    end
                                                    
                                                    local cx, cy = getCursorPosition()
                                                    ax = cx - startX
                                                    ay = cy - startY
                                                    local newCount = count - num
                                                    moveState = true
                                                    playSound("assets/sounds/select.mp3")
                                                    moveSlot = i
                                                    stacking = true
                                                    moveDetails = {id, itemid, value, num, status, dutyitem, premium, nbt, i, count}
                                                    cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                    --triggerServerEvent("countUpdate", localPlayer, localPlayer, i, invType, newCount)
                                                    --fullWeight = getWeight(invElement, invType)
                                                else
                                                    local syntax = getServerSyntax("Inventory", "error")
                                                    outputChatBox(syntax .. "Ennyit nem választhatsz szét!", 255,255,255,true)
                                                end
                                            else
                                                local syntax = getServerSyntax("Inventory", "error")
                                                outputChatBox(syntax .. "Ez az item nem szétszedhető!", 255,255,255,true)
                                            end
                                        else
                                            if activeSlot[invType .. "-" .. i] then
                                                if invElement == localPlayer then
                                                    return
                                                end
                                            end
                                            
                                            if cuffed or jailed or inventoryForceDisabled or tazed then
                                                return
                                            end
                                            
                                            local i = i
                                            local cx, cy = getCursorPosition()
                                            ax = cx - startX
                                            ay = cy - startY
                                            clickTimer = setTimer(
                                                function()
                                                    if getKeyState("mouse1") then
                                                        moveState = true
                                                        playSound("assets/sounds/select.mp3")
                                                        moveSlot = i
                                                        moveDetails = cache[elementType][elementID][invType][i]
                                                        moveDetails[9] = i
                                                        moveDetails[10] = moveDetails[4]
                                                        cache[elementType][elementID][invType][i] = nil
                                                        --stacking = false
                                                    end
                                                end, 400, 1
                                            )
                                        end
                                        return
                                    end
                                end
                            end

                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                    end
                end
            elseif b == "left" and s == "up" then
                if isTimer(clickTimer) then
                    killTimer(clickTimer)
                end
                
                local x, y = getNode("Inventory", "x"), getNode("Inventory", "y")
                local _x, _y = x, y
                x = x - 110
                y = y - 174

                local w, h = drawnSize["bg"][1], drawnSize["bg"][2]
                local cx, cy = x, y

                local line = 1
                local column = 1
                local startX = _x + (6)
                local _startX = startX
                local startY = _y + (28)
                
                local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
                local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
                
                local w, h = getNode("Inventory", "width"), getNode("Inventory", "height")

                if not cache[elementType] or not cache[elementType][elementID] or not cache[elementType][elementID][invType] then return end
                local data = cache[elementType][elementID][invType]
                if moveState then
                    if isInSlot(_x, _y, realSize["bg"][1], realSize["bg"][2]) then
                        for i = 1, maxLines * maxColumn do
                            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                            if isInSlot(startX, startY, w, h) then
                                if data then
                                    local data = data[i]
                                    if data then
                                        local isActive = false
                                        if activeSlot[invType .. "-" .. i] then
                                            if invElement == localPlayer then
                                                isActive = true
                                            end
                                        end

                                        if isActive then
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end
                                        --Stack / maxStack check
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        
                                        if itemid == itemid2 then
                                            local canStack = items[itemid][4]
                                            local maxStack = items[itemid][5]
                                            
                                            local between = math.abs(status - status2)
                                            if between > 2 then
                                                --[[moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil--]]
                                                canStack = false
                                            end

                                            if dutyitem == 1 or dutyitem2 == 1 then
                                                if dutyitem ~= dutyitem2 then
                                                    --[[moveState = false
                                                    playSound("assets/sounds/move.mp3")
                                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                    moveDetails = nil--]]
                                                    canStack = false
                                                end
                                            end

                                            if premium == 1 or premium2 == 1 then
                                                if premium ~= premium2 then
                                                    --[[moveState = false
                                                    playSound("assets/sounds/move.mp3")
                                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                    moveDetails = nil--]]
                                                    canStack = false
                                                end
                                            end

                                            if value ~= value2 then
                                                --[[moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil--]]
                                                canStack = false
                                            end

                                            if nbt ~= nbt2 then
                                                --[[moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil--]]
                                                canStack = false
                                            end

                                            --outputChatBox("asd")
                                            if canStack then
                                                --outputChatBox("asd2")
                                                if count + count2 <= maxStack then
                                                    --outputChatBox("asd3")
                                                    if i ~= moveSlot then
                                                        
                                                        if stacking then
                                                            --stack

                                                            --outputChatBox("asd5")
                                                            local newCount = count + count2
                                                            cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}

                                                            --trigger > countUpdate + itemRemoveFromSlot
                                                            
                                                            local count3 = moveDetails[10]
                                                            
                                                            --outputChatBox(i..">"..newCount)
                                                            --outputChatBox(moveSlot..">"..count3 - count2)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, i, invType, newCount, true)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, moveSlot, invType, count3 - count2)

                                                            moveState = false
                                                            stacking = false
                                                            moveDetails = nil
                                                        else
                                                            local newCount = count + count2
                                                            cache[elementType][elementID][invType][i] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                            cache[elementType][elementID][invType][moveSlot] = nil
                                                            triggerServerEvent("removeItemFromSlot", localPlayer, invElement, moveSlot, invType, true)
                                                            triggerServerEvent("countUpdate", localPlayer, invElement, i, invType, newCount)
                                                            
                                                            moveState = false
                                                            stacking = false
                                                            moveDetails = nil
                                                        end
                                                        
                                                        return
                                                        --fullWeight = getWeight(invElement, invType)
                                                    end
                                                    --[[
                                                    if i ~= moveSlot then
                                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[elementType][elementID][invType][moveSlot])
                                                        local newCount = count
                                                        if newCount > 0 then
                                                            cache[elementType][elementID][invType][moveSlot] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                            triggerServerEvent("countUpdate", localPlayer, localPlayer, moveSlot, invType, newCount)
                                                        else
                                                            outputChatBox("asd")
                                                            cache[elementType][elementID][invType][moveSlot] = nil
                                                            triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                                        end
                                                    end
                                                    ]]
                                                end
                                                
                                                --outputChatBox("asd4")
                                                moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                --outputChatBox(tostring(count))
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil
                                                return
                                            else
                                                --outputChatBox("asd2")
                                                moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                if stacking then
                                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                    stacking = false
                                                end
                                                local oSlotData2 = cache[elementType][elementID][invType][i]
                                                cache[elementType][elementID][invType][i] = moveDetails
                                                cache[elementType][elementID][invType][moveSlot] = oSlotData2
                                                --fullWeight = getWeight(invElement, invType)
                                                local oSlotData = moveDetails
                                                moveDetails = nil

                                                if i ~= moveSlot then
                                                    local data = cache[1][accID][10]
                                                    for i2 = 1, 9 do
                                                        if data then
                                                            local data = data[i2]
                                                            if data then
                                                                local _invType = invType
                                                                local invType, pairSlot, id = unpack(data)
                                                                local data = cache[1][accID][invType][pairSlot]
                                                                --outputChatBox("MoveSlot: "..moveSlot.."-"..pairSlot.." (PairSlot)")
                                                                --outputChatBox("invType: "..invType.."-".._invType.." (_invType)")
                                                                if pairSlot == moveSlot and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, i, id}
                                                                    --outputChatBox("1 trigger")
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                                end
                                                            end
                                                        end
                                                    end
                                                    
                                                    local data = cache[1][accID][10]
                                                    for i2 = 1, 9 do
                                                        if data then
                                                            local data = data[i2]
                                                            if data then
                                                                local _invType = invType
                                                                local invType, pairSlot, id = unpack(data)
                                                                local data = cache[1][accID][invType][pairSlot]
                                                                outputChatBox("MoveSlot: "..i.."-"..pairSlot.." (PairSlot)")
                                                                outputChatBox("MoveSlot: "..moveSlot.."-"..pairSlot.." (PairSlot)")
                                                                outputChatBox("invType: "..invType.."-".._invType.." (_invType)")
                                                                if pairSlot == moveSlot and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, moveSlot, id}
                                                                    --outputChatBox("1 trigger")
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, moveSlot, id})
                                                                elseif pairSlot == i and invType == _invType then
                                                                    cache[1][accID][10][i2] = {invType, i, id}
                                                                    --outputChatBox("asd"..moveSlot)
                                                                    triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                                end
                                                            end
                                                        end
                                                    end
                                                    --TriggerSlotUpdate
                                                    triggerServerEvent("changeSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData, oSlotData2)
                                                end
                                                return
                                            end
                                        else
                                            --outputChatBox("asd2")
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            local oSlotData2 = cache[elementType][elementID][invType][i]
                                            cache[elementType][elementID][invType][i] = moveDetails
                                            cache[elementType][elementID][invType][moveSlot] = oSlotData2
                                            --fullWeight = getWeight(invElement, invType)
                                            local oSlotData = moveDetails
                                            moveDetails = nil

                                            if i ~= moveSlot then
                                                local data = cache[1][accID][10]
                                                for i2 = 1, 9 do
                                                    if data then
                                                        local data = data[i2]
                                                        if data then
                                                            local _invType = invType
                                                            local invType, pairSlot, id = unpack(data)
                                                            local data = cache[1][accID][invType][pairSlot]
                                                            --outputChatBox("MoveSlot: "..i.."-"..pairSlot.." (PairSlot)")
                                                            --outputChatBox("MoveSlot: "..moveSlot.."-"..pairSlot.." (PairSlot)")
                                                            --outputChatBox("invType: "..invType.."-".._invType.." (_invType)")
                                                            if pairSlot == moveSlot and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, i, id}
                                                                --outputChatBox("1 trigger")
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                            elseif pairSlot == i and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, moveSlot, id}
                                                                --outputChatBox("2")
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, moveSlot, id})
                                                            end
                                                        end
                                                    end
                                                end
                                                --TriggerSlotUpdate
                                                triggerServerEvent("changeSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData, oSlotData2)
                                            end
                                            return
                                        end
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        
                                        return
                                    else
                                        --newSlot
                                        
                                        if stacking then
                                            if i ~= moveSlot then
                                                --outputChatBox("asd")
                                                triggerServerEvent("addItemToSlot", localPlayer, invElement, i, invType, moveDetails, true)
                                                local newCount = moveDetails[10] - moveDetails[4]
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, newCount, status, dutyitem, premium, nbt}
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                triggerServerEvent("countUpdate", localPlayer, invElement, moveSlot, invType, newCount)
                                            end
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            end
                                            cache[elementType][elementID][invType][i] = moveDetails
                                            moveDetails = nil
                                            stacking = false
                                            textbars["stack"][2][2] = ""
                                            --fullWeight = getWeight(invElement, invType)
                                        else
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][i] = moveDetails
                                            --fullWeight = getWeight(invElement, invType)
                                            local oSlotData = moveDetails
                                            moveDetails = nil
                                            
                                            if i ~= moveSlot then
                                                local data = cache[1][accID][10]
                                                for i2 = 1, 9 do
                                                    if data then
                                                        local data = data[i2]
                                                        if data then
                                                            local _invType = invType
                                                            local invType, pairSlot, id = unpack(data)
                                                            local data = cache[1][accID][invType][pairSlot]
                                                            --outputChatBox("MoveSlot: "..moveSlot.."-"..pairSlot.." (PairSlot)")
                                                            --outputChatBox("invType: "..invType.."-".._invType.." (_invType)")
                                                            if pairSlot == moveSlot and invType == _invType then
                                                                cache[1][accID][10][i2] = {invType, i, id}
                                                                --outputChatBox("1 trigger")
                                                                triggerServerEvent("ac.valueUpdate", localPlayer, localPlayer, i2, 10, {invType, i, id})
                                                            end
                                                        end
                                                    end
                                                end
                                                --TriggerSlotUpdate
                                                triggerServerEvent("updateSlot", localPlayer, invElement, moveSlot, i, invType, oSlotData)
                                            end
                                        end
                                        return
                                    end
                                end
                            end
                        
                            startX = startX + drawnSize["bg_cube"][1] + between
                            column = column + 1
                            if column > breakColumn then
                                startY = startY + drawnSize["bg_cube"][2] + between
                                startX = _startX
                                column = 1
                                line = line + 1
                            end
                        end
                        
                    --outputChatBox(tostring(localPlayer:getData("Actionbar.enabled")))
                    elseif state and isInSlot(_x + w/2 - 100/2, _y - 120, 100, 100) then
                        
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                        
                        moveState = false
                        playSound("assets/sounds/move.mp3")
                        if stacking then
                            --local data = cache[elementType][elementID][invType][moveSlot]
                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                            stacking = false
                        end
                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                        --outputChatBox("Tárgy felmutatás: "..itemid..", "..count)
                        
                        local itemName = getItemName(itemid, value, nbt)
                        
                        showItem(moveDetails)
                        moveDetails = nil
                                        
                        exports['cr_chat']:createMessage(localPlayer, "felmutat egy tárgyat ("..itemName..")", 1)
                    elseif localPlayer:getData("Actionbar.enabled") and isInSlot(ax, ay, aw, ah) and invElement == localPlayer then
                        acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
                        --outputChatBox(acType)
                        if acType == 1 then
                            local startX = ax + 1
                            local startY = ay + 2
                            
                            checkTableArray(1, accID, 10)
                            local data = cache[1][accID][10]
                            --cache[1][accID][10] = {}
                            --cache[1][accID][10][1] = {1, 1}
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                if stacking then
                                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                    stacking = false
                                                end
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil
                                                return
                                            end
                                        end
                                    end

                                    ----outputChatBox("HEEH")
                                    triggerServerEvent("addItemToSlot", localPlayer, localPlayer, i, 10, {invType, moveSlot, -1})

                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    
                                    checkTableArray(1, accID, 10)
                                    cache[1][accID][10][i] = {invType, moveSlot}
                                    return
                                end

                                startX = startX + w + 1
                            end

                            moveState = false
                            playSound("assets/sounds/move.mp3")
                            if stacking then
                                --local data = cache[elementType][elementID][invType][moveSlot]
                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                stacking = false
                            end
                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                            moveDetails = nil
                            
                            return
                        elseif acType == 2 then
                            local ax = ax - 2

                            local startX = ax + 2
                            local startY = ay + 1

                            local data = cache[1][accID][10]
                            local tooltip = false
                            for i = 1, columns do
                                local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
                                local isIn = false
                                if isInSlot(startX, startY, w, h) then
                                    if data then
                                        local data = data[i]
                                        if data then
                                            local _invType = invType
                                            local invType, pairSlot, id = unpack(data)
                                            local data = cache[1][accID][invType][pairSlot]
                                            if moveState then
                                                if pairSlot == moveSlot and invType == _invType then
                                                    data = moveDetails
                                                end
                                            end
                                            if data then
                                                moveState = false
                                                playSound("assets/sounds/move.mp3")
                                                if stacking then
                                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                    stacking = false
                                                end
                                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                                moveDetails = nil
                                                return
                                            end
                                        end
                                    end

                                    ----outputChatBox("HEEH")
                                    triggerServerEvent("addItemToSlot", localPlayer, localPlayer, i, 10, {invType, moveSlot, -1})

                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    
                                    checkTableArray(1, accID, 10)
                                    cache[1][accID][10][i] = {invType, moveSlot}
                                    return
                                end

                                startY = startY + h + 1
                            end

                            moveState = false
                            playSound("assets/sounds/move.mp3")
                            if stacking then
                                --local data = cache[elementType][elementID][invType][moveSlot]
                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                stacking = false
                            end
                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                            moveDetails = nil
                            return
                        end

                        moveState = false
                        playSound("assets/sounds/move.mp3")
                        if stacking then
                            --local data = cache[elementType][elementID][invType][moveSlot]
                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                            stacking = false
                        end
                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                        moveDetails = nil
                    else   
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                        
                        if not worldInteract[itemid] then
                            --outputChatBox(tostring(worldE))
                            --outputChatBox(tostring(worldE.type))
                            if worldE and worldE.type == "player" then
                                if worldE ~= localPlayer and invElement == localPlayer then
                                    --outputChatBox("Itemátadás másik playernek")

                                    local canMove = items[itemid][8]
                                    if not canMove then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem átadható!", 255,255,255,true)
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                
                                    if dutyitem == 1 then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem átadható (Dutyitem)!", 255,255,255,true)
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local veh = getPedOccupiedVehicle(localPlayer)
                                    if veh then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Kocsiban ülve nem tudod átadni a tágyat!", 255,255,255,true)
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                    if dist > (worldE.type == "vehicle" and 5 or 3) then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "A célpont túl messze van", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    --cache[elementType][elementID][invType][moveSlot] = moveDetails		   
                                    
                                    local itemName = getItemName(itemid, value, nbt)
                                    exports['cr_chat']:createMessage(localPlayer, "átad egy tárgyat egy közelében lévő embernek ("..itemName..")", 1)
                                    --outputChatBox(invType)
                                    
                                    local a2 = items[itemid][2]
                                    triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot)
                                    
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    cache[elementType][elementID][invType][moveSlot] = nil
                                    moveDetails = nil
                                    
                                    fullWeight = getWeight(invElement, invType)
                                    
                                    return
                                elseif worldE == localPlayer and invElement ~= localPlayer then
                                    if invType == specTypes["vehicle"] then
                                        --outputChatBox("Itemátadás magadnak de csomiból.")

                                        local canMove = items[itemid][8]
                                        if not canMove then
                                            local syntax = getServerSyntax("Inventory", "error")
                                            outputChatBox(syntax .. "Ez a tárgy nem átadható!", 255,255,255,true)
                                            
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return      
                                        end
                                        
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                
                                        if dutyitem == 1 then
                                            local syntax = getServerSyntax("Inventory", "error")
                                            outputChatBox(syntax .. "Ez a tárgy nem átadható (Dutyitem)!", 255,255,255,true)
                                            
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end

                                        local veh = getPedOccupiedVehicle(localPlayer)
                                        if veh then
                                            local syntax = getServerSyntax("Inventory", "error")
                                            outputChatBox(syntax .. "Kocsiban ülve nem tudod átadni a tágyat!", 255,255,255,true)
                                            
                                            moveState = false
                                            playSound("assets/sounds/move.mp3")
                                            if stacking then
                                                --local data = cache[elementType][elementID][invType][moveSlot]
                                                --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                                --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                                moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                                stacking = false
                                            end
                                            cache[elementType][elementID][invType][moveSlot] = moveDetails
                                            moveDetails = nil
                                            return
                                        end

                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        --cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        
                                        --[[
                                        local data = cache[1][accID][10]
                                        for i2 = 1, 9 do
                                            if data then
                                                local data = data[i2]
                                                if data then
                                                    local invType, pairSlot, id = unpack(data)
                                                    local data = cache[1][accID][invType][pairSlot]
                                                    if pairSlot == moveSlot then
                                                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, i2, 10)
                                                        cache[1][accID][10][i2] = nil
                                                    end
                                                end
                                            end
                                        end
                                        ]]

                                        --outputChatBox(invType)
                                        local a2 = items[itemid][2]
                                        local itemName = getItemName(itemid, value, nbt)
                                        
                                        exports['cr_chat']:createMessage(localPlayer, "kivesz egy tárgyat a jármű csomagtartójából ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(invElement)..")", 1)
                                        triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot)
                                        
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        cache[elementType][elementID][invType][moveSlot] = nil
                                        moveDetails = nil
                                        
                                        fullWeight = getWeight(invElement, invType)
                                        return
                                    end
                                end
                                
                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                if stacking then
                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                    stacking = false
                                end
                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                
                                return
                            elseif worldE and worldE.type == "vehicle" then
                                if invElement ~= localPlayer then
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    moveDetails = nil
                                    return
                                end
                                
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                
                                if dutyitem == 1 then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Ez a tárgy nem átadható (Dutyitem)!", 255,255,255,true)
                                    
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local canMove = items[itemid][8]
                                if not canMove then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Ez a tárgy nem átadható!", 255,255,255,true)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local veh = getPedOccupiedVehicle(localPlayer)
                                if veh and veh ~= worldE then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Nem tudsz átnyúlni az egyik kocsiból a másikba, hogy berakd oda a cuccod.", 255,255,255,true)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local seat = getPedOccupiedVehicleSeat(localPlayer)
                                if veh and seat >= 2 then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "A kesztyűtartóba csak a vezető és anyósülésen lévő játékos tud tárgyat berakni.", 255,255,255,true)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                if dist > (worldE.type == "vehicle" and 5 or 3) then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "A célpont túl messze van", 255,255,255,true)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local eId = getEID(worldE)
                                --outputChatBox(itemid)
                                if not veh then
                                    if not worldE:getData("veh >> boot") then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "A célpont zárva van!", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                end
                                --outputChatBox(tostring(hasItem))
                                
                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                if stacking then
                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local a2 = specTypes["vehicle"]
                                local text = "csomagtartójába"
                                
                                if veh then
                                    a2 = specTypes["vehicle.in"]
                                    text = "kesztyűtartójába"
                                end
                                
                                if isKey(itemid) then
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Kulcsok nem helyezhetőek csomagtartóba.", 255,255,255,true)
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end
                                
                                local itemName = getItemName(itemid, value, nbt)
                                exports['cr_chat']:createMessage(localPlayer, "berak egy tárgyat a jármű "..text.." ("..itemName..") ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                                
                                triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot)
                                
                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                cache[elementType][elementID][invType][moveSlot] = nil
                                moveDetails = nil
                                fullWeight = getWeight(invElement, invType)
                                
                                return
                            elseif worldE and worldE.type == "object" then    
                                --"outputChatBox("asd")
                                if worldE.model == 1359 then -- kuka
                                    if invElement ~= localPlayer then
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

 
                                    if dutyitem == 1 then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem kidobható (Dutyitem)!", 255,255,255,true)

                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
									
                                    local canMove = items[itemid][8]
                                    if not canMove then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem kidobható!", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local veh = getPedOccupiedVehicle(localPlayer)
                                    if veh then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Nem tudsz átnyúlni a kocsiból, hogy kidobd a cuccod.", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                    if dist > (worldE.type == "vehicle" and 5 or 3) then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "A célpont túl messze van", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    cache[elementType][elementID][invType][moveSlot] = nil

                                    exports['cr_chat']:createMessage(localPlayer, "kidob egy tárgyat a közelében lévő kukába ("..getItemName(itemid, value, nbt)..")", 1)

                                    triggerServerEvent("deleteItem", localPlayer, localPlayer, moveSlot, itemid)
                                    moveDetails = nil
                                    return
                                elseif worldE:getData("safe.id") then -- széf
                                    if invElement ~= localPlayer then
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)

                                    if dutyitem == 1 then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem átadható (Dutyitem)!", 255,255,255,true)

                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local canMove = items[itemid][8]
                                    if not canMove then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem átadható!", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local veh = getPedOccupiedVehicle(localPlayer)
                                    if veh and veh ~= worldE then
                                        --local syntax = getServerSyntax("Inventory", "error")
                                        --outputChatBox(syntax .. "Nem tudsz átnyúlni az egyik kocsiból a másikba, hogy berakd oda a cuccod.", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local dist = getDistanceBetweenPoints3D(localPlayer.position, worldE.position)
                                    if dist > (worldE.type == "vehicle" and 5 or 3) then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "A célpont túl messze van", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    --cache[elementType][elementID][invType][moveSlot] = moveDetails

                                    local a2 = specTypes["object"]
                                    local text = "széfbe"

                                    if veh then
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    local eId = getEID(worldE)
                                    local _itemid = convertKey("safe")
                                    --outputChatBox(itemid)
                                    local hasKey = hasItem(localPlayer, _itemid, eId)

                                    if not hasKey then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "A célponthoz nincs kulcsod!", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
                                    if isKey(itemid) then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Kulcsok nem helyezhetőek széfbe.", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        if stacking then
                                            --local data = cache[elementType][elementID][invType][moveSlot]
                                            --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                            --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                            local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                            moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                            stacking = false
                                        end
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end

                                    local itemName = getItemName(itemid, value, nbt)
                                    exports['cr_chat']:createMessage(localPlayer, "berak egy tárgyat egy "..text.." ("..itemName..")", 1)

                                    triggerServerEvent("transportItem", localPlayer, localPlayer, invElement, worldE, invType, a2, moveDetails, moveSlot)
                                    
                                    cache[elementType][elementID][invType][moveSlot] = nil
                                    fullWeight = getWeight(invElement, invType)
                                elseif worldE and worldE.model == 2942 then
                                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                    
                                    if itemid == 97 then -- bankkártya then
                                        --outputChatBox("MEGÖLLEk")
                                        --exports['cr']
                                        exports['cr_bank']:openATM(moveDetails, worldE)
                                    end
                                
                                    moveState = false
                                    playSound("assets/sounds/move.mp3")
                                    if stacking then
                                        --local data = cache[elementType][elementID][invType][moveSlot]
                                        --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                        --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                        local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                        moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                        stacking = false
                                    end
                                    cache[elementType][elementID][invType][moveSlot] = moveDetails
                                    moveDetails = nil
                                    return
                                end

                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                if stacking then
                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                    stacking = false
                                end
                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                moveDetails = nil
								
							elseif(worldE and worldE.type == "ped") then
								local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                local invType = items[itemid][2]
                                local eType = getEType(localPlayer)
                                local eId = getEID(localPlayer)
								local doRemoveItem = false
								if(worldE:getData("faction >> depositNPC")) then
                                    local canMove = items[itemid][8]
                                    if not canMove then
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ez a tárgy nem helyezhető be frakcióba!", 255,255,255,true)
                                        moveState = false
                                        playSound("assets/sounds/move.mp3")
                                        cache[elementType][elementID][invType][moveSlot] = moveDetails
                                        moveDetails = nil
                                        return
                                    end
                                    
									local factions = exports.cr_faction:getPlayerFactions(localPlayer)
									local found = false
									for i, v in pairs(factions) do
										if(tonumber(v["id"]) == tonumber(worldE:getData("faction >> depositFaction"))) then
											local pos, ppos = worldE:getPosition(), localPlayer:getPosition()
											if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 3) then
												found = true
												local syntax = getServerSyntax("Faction", "error")
												outputChatBox(syntax..exports.cr_inventory:getItemName(itemid).." hozzáadva a #"..exports.cr_faction:getFactionName(localPlayer, v["id"]).." frakcióhoz!", 255, 255, 255, true)
												triggerServerEvent("depositItemToFaction", localPlayer, localPlayer, v["id"], itemid, value, count, status)
												doRemoveItem = true
											end
											break
										end
									end
									if(not found) then
										local syntax = getServerSyntax("Faction", "error")
										outputChatBox(syntax.."Nem vagy tagja az adott frakciónak.", 255, 255, 255, true)
									end
								elseif(worldE:getData("shop >> npc")) then
									if(itemid == 97) then
										outputChatBox("bankkártyás fizetés")
									end
                                elseif worldE:getData("faction >> ticketNPC") then
                                    local pos, ppos = worldE:getPosition(), localPlayer:getPosition()
                                    if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 3) then
                                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(moveDetails)
                                        --local remove = false
                                        local invType = items[itemid][2]
                                        local eType = getEType(localPlayer)
                                        local eId = getEID(localPlayer)
                                        --outputChatBox(itemid)
                                        if itemid == 128 then -- bankkártya then
                                            local cost = value["cost"]
                                            if(tonumber(value["timestamp"]) < getRealTime()["timestamp"]) then
                                                cost = cost * 2
                                            end
                                            if exports['cr_core']:takeMoney(localPlayer, cost) then
                                                --outputChatBox("MEGÖLLEk")
                                                --exports['cr']
                                                --exports['cr_bank']:openATM(moveDetails, worldE)
                                                --local value = 
                                                --cache[1][accID][2][moveSlot] = nil
                                                --remove = true
                                                --triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 2)
                                                doRemoveItem = true
                                                triggerServerEvent("payTicket", localPlayer, localPlayer, value, slot)
                                            else
                                                exports['cr_infobox']:addBox("error", "Nincs elég pénzed a csekk kifizetésre!")
                                            end
                                        end
                                    end
								end
								
								moveState = false
								playSound("assets/sounds/move.mp3")
								if stacking then
									--local data = cache[elementType][elementID][invType][moveSlot]
									--local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
									--local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
									local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
									moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
									stacking = false
								end
								if(not doRemoveItem) then
									cache[eType][eId][invType][moveSlot] = moveDetails
								else
									triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                    local eType = getEType(localPlayer)
                                    local eId = getEID(localPlayer)
                                    cache[eType][eId][invType][moveSlot] = nil
								end
								moveDetails = nil
								return
                            else
                                local disableChatInteract = nil
                                local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                local pos = Vector3(wx, wy, wz)
                                if itemid == 22 then
                                    if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
                                        local invType = items[itemid][2]
                                        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                        local eType = getEType(localPlayer)
                                        local eId = getEID(localPlayer)
                                        cache[eType][eId][invType][moveSlot] = nil
                                        moveDetails = nil
                                        moveState = nil
                                        stacking = nil
                                        exports['cr_chat']:createMessage(localPlayer, "lehelyez a földre egy hifit", 1)
                                        --local element = createObject(2102,wx,wy,wz,0,0,0)
                                        triggerServerEvent("createHifi", localPlayer, localPlayer, wx,wy,wz)
                                        return
                                    else
                                        disableChatInteract = {"box", {"error", "Túl messzire szeretnéd lehelyezni a hifit!"}}
                                    end
                                elseif itemid == 72 then
                                    if localPlayer.dimension ~= 0 and localPlayer.interior ~= 0 then
                                        local datas = localPlayer:getData("interior->Datas") or {
                                                    ["interior"] = 0,
                                                    ["dimension"] = 0,
                                                    ["owner"] = -1,
                                                }
                                        if datas["interior"] == localPlayer.interior and datas["dimension"] == localPlayer.dimension and datas["owner"] == localPlayer:getData("acc >> id") then
                                            if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
                                                local objectsInDim = 0
                                                for k,v in pairs(getElementsByType("object")) do
                                                    if v.dimension == localPlayer.dimension and v.interior == localPlayer.interior and v.model == 2332 then
                                                        objectsInDim = objectsInDim + 1
                                                    end
                                                end
                                                local max = 1
                                                if objectsInDim + 1 <= max then
                                                    setTimer(triggerServerEvent, 200, 1, "createSafe", localPlayer, localPlayer, nil, true, {pos.x, pos.y, pos.z + 0.5})
                                                    local invType = items[itemid][2]
                                                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, moveSlot, invType)
                                                    local eType = getEType(localPlayer)
                                                    local eId = getEID(localPlayer)
                                                    cache[eType][eId][invType][moveSlot] = nil
                                                    return
                                                else
                                                    disableChatInteract = {"box", {"error", "Ez a széf nem helyezhető le hisz már elérted a limitet ("..max..")!"}}
                                                end
                                            else
                                                disableChatInteract = {"box", {"error", "Túl messzire szeretnéd lehelyezni a széfet!"}}
                                            end
                                        else
                                            --exports['cr_infobox']:addBox("error", "Csak saját interiorban helyezhető le széf")
                                            disableChatInteract = {"box", {"error", "Csak saját interiorban helyezhető le széf"}}
                                        end
                                    else
                                        disableChatInteract = {"box", {"error", "Csak interiorban helyezhető le széf"}}
                                    end
                                end
                                
                                if disableChatInteract then
                                    if type(disableChatInteract) == "table" then
                                        if disableChatInteract[1] == "chat" then
                                            outputChatBox(disableChatInteract, 255,255,255,true)
                                        elseif disableChatInteract[1] == "box" then
                                            exports['cr_infobox']:addBox(disableChatInteract[2][1], disableChatInteract[2][2])
                                        end
                                    end
                                else
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Ezzel a tárggyal nem végezhető ilyen interakció. (Kidobás / Lehelyezés)", 255,255,255,true)
                                end
                                moveState = false
                                playSound("assets/sounds/move.mp3")
                                if stacking then
                                    --local data = cache[elementType][elementID][invType][moveSlot]
                                    --local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                    --local id2, itemid2, value2, count2, status2, dutyitem2, premium2, nbt2 = unpack(moveDetails)
                                    local id, itemid, value, num, status, dutyitem, premium, nbt, i, count = unpack(moveDetails)
                                    moveDetails = {id, itemid, value, count, status, dutyitem, premium, nbt}
                                    stacking = false
                                end
                                cache[elementType][elementID][invType][moveSlot] = moveDetails
                                moveDetails = nil
                                return
                            end
                        end
                        --worldDrop / worldObjInteract
                    end
                end
            end
        end
        
        if b == "right" and s == "down" then
            if worldE and worldE.type == "object" and worldE.model == 2332 then -- Széf
                --[[
                local veh = getPedOccupiedVehicle(localPlayer)
                --outputChatBox("asd")
                if not veh then
                    if getDistanceBetweenPoints3D(worldE.position, localPlayer.position) > 3 then
                        moveState = false
                        playSound("assets/sounds/move.mp3")
                        --cache[elementType][elementID][invType][moveSlot] = moveDetails
                        moveDetails = nil
                        return
                    end
                    
                    if not getElementData(worldE, "inventory.open") then
                        local eId = getEID(worldE)
                        local itemid = convertKey("safe")
                        local hasKey = hasItem(localPlayer, itemid, eId)
                        if hasKey then
                            setElementData(worldE, "inventory.open", localPlayer)
                            exports['cr_chat']:createMessage(localPlayer, "kinyitja egy közelében lévő széf ajtaját", 1)
                            state = true
                            openInventory(worldE)
                            invType = specTypes["object"]
                            return
                        else
                            local syntax = getServerSyntax("Inventory", "error")
                            outputChatBox(syntax .. "Ezt az inventory-t nem tudod megnyitni mert vagy nincs hozzá kulcsod vagy pedig zárva van!", 255,255,255,true)
                            return
                        end
                    else
                        local syntax = getServerSyntax("Inventory", "error")
                        outputChatBox(syntax .. "Ez az inventory jelenleg használatban van!", 255,255,255,true)
                        return
                    end
                end]]
            elseif worldE and worldE.type == "vehicle" then
                local veh = getPedOccupiedVehicle(localPlayer)
                --outputChatBox("asd")
                if not veh then
                    --[[
                    if getDistanceBetweenPoints3D(worldE.position, localPlayer.position) > 3 then
                        moveState = false
                        playSound("assets/sounds/move.mp3")
                        --cache[elementType][elementID][invType][moveSlot] = moveDetails
                        moveDetails = nil
                        return
                    end
                    
                    if isEnabledTypeForOpen[getVehicleType(worldE)] then
                        if not getElementData(worldE, "inventory.open") then
                            local eId = getEID(worldE)
                            local itemid = convertKey("vehicle")
                            if worldE:getData("veh >> boot") then
								if getElementData(worldE, "drone >> isDrone") or getElementData(worldE, "veh >> temporaryVehicle") or getElementData(worldE, "veh >> job") then return end
                                setElementData(worldE, "inventory.open", localPlayer)
                                exports['cr_chat']:createMessage(localPlayer, "belenézz a jármű csomagtartójába ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                                state = true
                                openInventory(worldE)
                                invType = specTypes["vehicle"]
                                return
                            else
                                local syntax = getServerSyntax("Inventory", "error")
                                outputChatBox(syntax .. "Ezt az inventory-t nem tudod megnyitni mert zárva van a csomagtartója!", 255,255,255,true)
                                return
                            end
                        else
                            local syntax = getServerSyntax("Inventory", "error")
                            outputChatBox(syntax .. "Ez az inventory jelenleg használatban van!", 255,255,255,true)
                            return
                        end
                    else
                        local syntax = getServerSyntax("Inventory", "error")
                        outputChatBox(syntax .. "Ennél a fajta járműnél nem lehetséges a csomagtartó megnyitása.", 255,255,255,true)
                        return
                    end]]
                else
                    if localPlayer:getData("keysDenied") then return end
                    if worldE == veh then
                        local seat = getPedOccupiedVehicleSeat(localPlayer)
                        if seat <= 1 then
                            if isEnabledTypeForOpen2[getVehicleType(veh)] then
                                --Belső kisebb invet nyissa meg.
                                if not getElementData(worldE, "inventory.open2") then
                                    local eId = getEID(worldE)
                                    --local itemid = convertKey("vehicle")
                                    --outputChatBox(itemid)
                                    --local hasKey = hasItem(localPlayer, itemid, eId)
                                    --outputChatBox(tostring(hasItem))
                                    --if hasKey then
									if getElementData(worldE, "drone >> isDrone") or getElementData(worldE, "veh >> temporaryVehicle") or getElementData(worldE, "veh >> job") then return end
                                    setElementData(worldE, "inventory.open2", localPlayer)
                                    exports['cr_chat']:createMessage(localPlayer, "kinyitja a jármű kesztyűtartóját ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                                    state = true
                                    openInventory(worldE)
                                    invType = specTypes["vehicle.in"]
                                    return
                                    --[[else
                                        local syntax = getServerSyntax("Inventory", "error")
                                        outputChatBox(syntax .. "Ezt az inventory-t nem tudod megnyitni mert nincs hozzá kulcsod!", 255,255,255,true)
                                        return
                                    end]]
                                else
                                    local syntax = getServerSyntax("Inventory", "error")
                                    outputChatBox(syntax .. "Ez az inventory jelenleg használatban van!", 255,255,255,true)
                                    return
                                end
                            else
                                local syntax = getServerSyntax("Inventory", "error")
                                outputChatBox(syntax .. "Ennél a fajta járműnél nem lehetséges a kesztyűtartója megnyitása.", 255,255,255,true)
                                return
                            end
                        else
                            local syntax = getServerSyntax("Inventory", "error")
                            outputChatBox(syntax .. "Csak a vezető és anyósülésen ülő játékos nyithatja meg a kesztyűtartót!", 255,255,255,true)
                            return
                        end
                    else
                        local syntax = getServerSyntax("Inventory", "error")
                        outputChatBox(syntax .. "Mivel nem vagy varázsló ezért nem tudsz átnyúlni a kocsidból egy másik kocsi csomagtartójába... !", 255,255,255,true)
                        return
                    end
                end
            end
        end
    end
)

function upMove()
    if not positions then return end
    local isIn = false
    for i = 1,6 do
        local x,y,w,h = unpack(positions[i])
        h = h + 10
        if isInSlot(x,y,w,h) then
            isIn = true
        end
    end
    
    if isIn then
        if cminLines - 1 >= 1 then
            cminLines = cminLines - 1
            cmaxLines = cmaxLines - 1
        end
    end
end

function downMove()
    if not positions then return end
    local isIn = false
    for i = 1, 6 do
        local x,y,w,h = unpack(positions[i])
        h = h + 10
        if isInSlot(x,y,w,h) then
            isIn = true
        end
    end
    
    local index, num = 1, 0
    
    for k, v in pairs(craftG) do
        local ctype, listed, citems = unpack(v)

        if listed then
            if index >= cminLines and index <= cmaxLines then
                num = num + 1
            end

            for k2,v2 in pairs(citems) do
                local itemdata, crafttime, cdata, needed = unpack(v2)
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemdata)
                index = index + 1
                if index >= cminLines and index <= cmaxLines then
                    num = num + 1
                end    
            end
        else
            if index >= cminLines and index <= cmaxLines then
                num = num + 1
            end
        end
        index = index + 1
    end
    
    if isIn then
        if cmaxLines + 1 < index then
            cminLines = cminLines + 1
            cmaxLines = cmaxLines + 1
        end
    end
end

bindKey("mouse_wheel_up", "down", upMove)
bindKey("mouse_wheel_down", "down", downMove)

function giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
    triggerServerEvent("giveItem", sourceElement, sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
end
addEvent("giveItem", true)
addEventHandler("giveItem", root, giveItem)

function deleteItem(sourceElement, slot, itemid)
    triggerServerEvent("deleteItem", sourceElement, sourceElement, slot, itemid)
end
addEvent("deleteItem", true)
addEventHandler("deleteItem", root, deleteItem)

function updateItemDetails(sourceElement, slot, iType, details)
    triggerServerEvent("updateItemDetails", sourceElement, sourceElement, slot, iType, details)
end
addEvent("updateItemDetails", true)
addEventHandler("updateItemDetails", root, updateItemDetails)

function getItems(element, invType)
    local eType = getEType(element)
    local eId = getEID(element)
    checkTableArray(eType, eId, invType)

    return cache[eType][eId][invType]
end

function hasItem(element, itemID, itemValue)
    if not element or type(element) == "number" then 
        element = localPlayer 
    end
    
    if itemValue then
        for i = 1, 3 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if itemid == itemID and value == itemValue then
                    return true, slot, data
                end
            end
        end
        
        return false
    else
        for i = 1, 3 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if itemid == itemID then
                    return true, slot, data
                end
            end
        end
        
        return false
    end
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

local maxDist = 150

_addCommandHandler("nearbytrash", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbytrash") then
            local syntax = getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő kukák: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("trash.id")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..white..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)

_addCommandHandler("nearbysafe", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbysafe") then
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő széfek: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("safe.id")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..white..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)

function formatTimeStamp(t)
    local time = getRealTime(t)
    local year = time.year
    local month = time.month+1
    local day = time.monthday
    local hours = time.hour
    local minutes = time.minute
    local seconds = time.second
    if(month < 10) then
        month = "0"..month
    end
    if(day < 10) then
        day = "0"..day
    end
    if (hours < 10) then
        hours = "0"..hours
    end
    if (minutes < 10) then
        minutes = "0"..minutes
    end
    if (seconds < 10) then
        seconds = "0"..seconds
    end
    return 1900+year .. "." ..  month .. "." .. day .." - " .. hours .. ":" .. minutes
end

local textHeights = {}

local interiorNames = {}

function getInteriorName(id)
    local id = id
    for k,v in pairs(getElementsByType("marker")) do
        if v:getData("interior >> id") and v:getData("interior >> id") == id then
            --outputChatBox("asd")
            interiorNames[id] = v:getData("interior >> name")
            
            addEventHandler("onClientElementDataChange", v, 
                function(dName)
                    if dName == "interior >> name" then
                        local id = source:getData("interior >> id")
                        interiorNames[id] = v:getData("interior >> name")
                    end
                end
            )
            
            break
        end
    end
end

function renderTooltip(startX, startY, data, alpha, specText)
    if interfaceDrawn then return end
    --Sorozatszám, állapot.
    --outputChatBox("asd")
    --outputChatBox(specText)
    if not gColor then
        gColor = getServerColor(nil, true)
    end
    if not white then
        white = "#ffffff"
    end
    local w, h = drawnSize["left/right"][1], drawnSize["left/right"][2]
    if not count then count = 1 end
    if not value then value = 1 end
    --[[
    --Hely: Szükség, Recept: Szükséges, Tárgy: Szükséges, Szervezet: Szükséges
        "Hely:" .. #33FF33Szükséges\n
    ]]
    local id, itemid, value, count, status, dutyitem, premium, nbt, name, weight, description, text
    
    if specText then
        if type(data) == "table" then
            local faction, location, blueprint, hammer = unpack(data)
            text = "#ffffffHely: " .. (location and "#33FF33Szükséges" or "#FF3333Nem szükséges") .. "\n#ffffffSzervezet: " .. (faction and "#33FF33Szükséges" or "#FF3333Nem szükséges") .. "\n#ffffffRecept: " .. (blueprint and "#33FF33Szükséges" or "#FF3333Nem szükséges") .. "\n#ffffffKalapács: " .. (hammer and "#33FF33Szükséges" or "#FF3333Nem szükséges")
        else
            text = specText
        end
    else
        id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        name, weight, description = getItemName(itemid, value, nbt), items[itemid][3], itemDescriptions[itemid]
        local weightText = "\nSúly: #33beff"..weight * count.." kg"..white
        if not disabledWeight[itemid] then
            text = "Név: #3dff33"..name..white.."@|@A@C"..weightText --Leírás: #3dff33"..description..white.."\n"
        else
            text = "Név: #3dff33"..name..white.."@|@A@C"..white --Leírás: #3dff33"..description..white.."\n"
        end

        if isWeapon(itemid) and items[itemid][10] > 1 then -- isWeapon
            text = string.gsub(text, "@A", " (" .. gColor.."#"..gColor..utf8.sub(md5(id), 1, 12)..white..")")
        else
            text = string.gsub(text, "@A", "")
        end

        if dutyitem == 1 then
            text = string.gsub(text, "@|", " #ff3333[DutyItem]" .. white)
        else
            text = string.gsub(text, "@|", "")
        end

        if premium == 1 then
            text = string.gsub(text, "@C", " #ff3333[Premium]" .. white)
        else
            text = string.gsub(text, "@C", "")
        end

        if itemid == 16 and tonumber(nbt) and tonumber(nbt) > 1 then
            local vehName = exports['cr_vehicle']:getVehicleName(nbt) 
            text = text .. " #ff3333["..vehName.."]" .. white .. weightText
        end
        
        if itemid == 17 or itemid == 18 then
            if not interiorNames[value] then
                interiorNames[value] = ""
                getInteriorName(value)
            end
            local vehName = interiorNames[value]
            text = text .. " #ff3333["..vehName.."]" .. white .. weightText
        end

        if items[itemid][7] then -- isStatus
            local color = {} 
            if status <= 25 then
                color = {253, 0, 0}
            elseif status <= 50 then
                color = {253, 105, 0}
            elseif status <= 75 then
                color = {253, 168, 0} 
            elseif status <= 100 then 
                color = {106, 253, 0}
            end   
            color = RGBToHex(unpack(color))
            text = text .. "\nÁllapot: "..color..status.."%"..white
        else
            if itemid == 16 or itemid == 17 or itemid == 18 or itemid == 29 then
                text = text .. "\nAzonosító: #3dff33"..value..white
            elseif itemid == 97 then
                text = text .. "\nKártyaszám: #3dff33"..value..white
            elseif itemid == 78 then
                --iprint(value)
                text = text .. "\nAzonosító: #3dff33"..(value.id)..white .. "\nNév: #3dff33"..(value.name)..white
            elseif itemid == 132 then
                local bulletName
                if type(value[2]) == "number" then
                    bulletName = getItemName(value[2], 1, 0)
                else
                    bulletName = value[2]
                end
                text = text .. "\nFegyver azonosító: #3dff33"..value[1]..white.."\nLőszer típus: #3dff33"..bulletName..white
            elseif itemid == 128 then
                local cost = value["cost"]
                --outputChatBox(value["timestamp"])
                --outputChatBox("A"..getRealTime()["timestamp"])
                if(tonumber(value["timestamp"]) < getRealTime()["timestamp"]) then
                    cost = cost * 2
                    --outputChatBox("asd")
                end
                text = text .. "\nIndok: #3dff33"..value["title"]..white.."\nBírság: #3dff33"..cost..white.."$\nLejárat: #3dff33"..formatTimeStamp(value["timestamp"])
            elseif itemid == 19 then
                text = text .. "\nFrekvencia: #3dff33"..value..white
            else
                --text = text .. "Érték: #3dff33"..value..white
            end
        end
    end
    
    if not textHeights[text] then
        local count = 0
        local last = 0
        while true do
            local startpos, endpos = utf8.find(text,'\n',last,true)
            if startpos and endpos then
                count = count + 1
                last = endpos + 1
            else
                break
            end
        end
        
        textHeights[text] = count
    end
    local h = (textHeights[text] * dxGetFontHeight(1, font3))
    local length = dxGetTextWidth(text, 1, font3, true) + 10
    if length % 2 ~= 0 then
        length = length + 1
    end   
    dxDrawImage(startX + drawnSize["bg_cube"][1]/2 - w/2, startY - 14, w, drawnSize["left/right"][2], "assets/images/top.png", 0,0,0, tocolor(255,255,255,alpha))
    dxDrawRoundedRectangleTooltip(startX + drawnSize["bg_cube"][1]/2 - length/2, startY - h - 14, length, h, tocolor(0,0,0,math.min(255 * 0.72, alpha)), 10)
    
    --[[if startX + drawnSize["bg_cube"][1]/2 - length/2 <= 0 then
        startX = length/2
    end
    
    if startX + drawnSize["bg_cube"][1]/2 + length/2 >= screenSize[1] then
        startX = screenSize[1] - length/2
    end--]]
    --dxDrawImage(startX + drawnSize["bg_cube"][1]/2 - length/2 - w, startY - h - 10, w, h, "assets/images/left.png", 0,0,0, tocolor(255,255,255,alpha))
    --dxDrawImage(startX + drawnSize["bg_cube"][1]/2 + length/2, startY - h - 10, w, h, "assets/images/right.png", 0,0,0, tocolor(255,255,255,alpha))
    --dxDrawRectangle(startX + drawnSize["bg_cube"][1]/2 - length/2, startY - h - 6, length, 72, tocolor(0,0,0,math.min(255 * 0.72, alpha)))
    dxDrawText(text,startX + drawnSize["bg_cube"][1]/2, startY - h - 14, startX + drawnSize["bg_cube"][1]/2, startY - h - 14 + h, tocolor(255,255,255,alpha), 1, font3, "center", "center", false, false, false, true)
end

function dxDrawRoundedRectangleTooltip(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

function openBoot(worldE)
    if localPlayer:getData("keysDenied") then return end
    
    --[[
    if getDistanceBetweenPoints3D(worldE.position, localPlayer.position) > 3 then
        moveState = false
        playSound("assets/sounds/move.mp3")
        --cache[elementType][elementID][invType][moveSlot] = moveDetails
        moveDetails = nil
        return
    end]]

    if isEnabledTypeForOpen[getVehicleType(worldE)] then
        if not getElementData(worldE, "inventory.open") then
            local eId = getEID(worldE)
            local itemid = convertKey("vehicle")
            if worldE:getData("veh >> boot") then
                if getElementData(worldE, "drone >> isDrone") or getElementData(worldE, "veh >> temporaryVehicle") or getElementData(worldE, "veh >> job") then return end
                setElementData(worldE, "inventory.open", localPlayer)
                exports['cr_chat']:createMessage(localPlayer, "belenézz a jármű csomagtartójába ("..exports['cr_vehicle']:getVehicleName(worldE)..")", 1)
                state = true
                openInventory(worldE)
                invType = specTypes["vehicle"]
                return
            else
                local syntax = getServerSyntax("Inventory", "error")
                outputChatBox(syntax .. "Ezt az inventory-t nem tudod megnyitni mert zárva van a csomagtartója!", 255,255,255,true)
                return
            end
        else
            local syntax = getServerSyntax("Inventory", "error")
            outputChatBox(syntax .. "Ez az inventory jelenleg használatban van!", 255,255,255,true)
            return
        end
    else
        local syntax = getServerSyntax("Inventory", "error")
        outputChatBox(syntax .. "Ennél a fajta járműnél nem lehetséges a csomagtartó megnyitása.", 255,255,255,true)
        return
    end
end

function openSafe(worldE)
    if localPlayer:getData("keysDenied") then return end
    
    local veh = getPedOccupiedVehicle(localPlayer)
    --outputChatBox("asd")
    if not veh then
        if getDistanceBetweenPoints3D(worldE.position, localPlayer.position) > 3 then
            --moveState = false
            --playSound("assets/sounds/move.mp3")
            --cache[elementType][elementID][invType][moveSlot] = moveDetails
            --moveDetails = nil
            return
        end

        if not getElementData(worldE, "inventory.open") then
            local eId = getEID(worldE)
            local itemid = convertKey("safe")
            local hasKey = hasItem(localPlayer, itemid, eId)
            if hasKey then
                setElementData(worldE, "inventory.open", localPlayer)
                exports['cr_chat']:createMessage(localPlayer, "kinyitja egy közelében lévő széf ajtaját", 1)
                state = true
                openInventory(worldE)
                invType = specTypes["object"]
                return
            else
                local syntax = getServerSyntax("Inventory", "error")
                outputChatBox(syntax .. "Ezt az inventory-t nem tudod megnyitni mert vagy nincs hozzá kulcsod vagy pedig zárva van!", 255,255,255,true)
                return
            end
        else
            local syntax = getServerSyntax("Inventory", "error")
            outputChatBox(syntax .. "Ez az inventory jelenleg használatban van!", 255,255,255,true)
            return
        end
    end
end

function destroySafe(worldE)
    local eId = getEID(worldE)
    local itemid = convertKey("safe")
    local hasKey, slot, data = hasItem(localPlayer, itemid, eId)
    if hasKey then
        worldE:setData("inventory.open", nil)
        
        local invType = items[itemid][2]
        triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
        local eType = getEType(localPlayer)
        local eId = getEID(localPlayer)
        cache[eType][eId][invType][slot] = nil
        
        giveItem(localPlayer, 72, 1)
        
        triggerServerEvent("deleteSafe", localPlayer, localPlayer, nil, worldE:getData("safe.id"), true)
    else
        local syntax = getServerSyntax("Inventory", "error")
        outputChatBox(syntax .. "Ez a széf nem felvehető hisz nincs hozzá kulcsod!", 255,255,255,true)
        return
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "safe >> movedBy" then
            local val = source:getData(dName)
            if val then
                if oValue then
                    if val ~= oValue then
                        if localPlayer == val then
                            --source:setData("hifi >> movedBy", oValue)
                            exports['cr_elementeditor']:resetEditorElementChanges(true)
                        end
                    end
                end
            end
        end
    end
)

addEvent("onSaveSafePositionEditor",true)
addEventHandler("onSaveSafePositionEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
--        triggerServerEvent("onHifiSetPosition",element,element, x, y, z, rx, ry, rz)
        --outputChatBox("awsd")
        --tputChatBox(exports['cr_core']:getServerSyntax("Hifi", "success") .. "sikeresen megváltoztattad egy hifi pozicióját!")
        triggerServerEvent("updateSafePosition", localPlayer, element, {x,y,z,rx,ry,rz})
        --triggerServerEvent("updateHifiRotation", localPlayer, element, {rx,ry,rz})
        triggerServerEvent("safeChangeState", localPlayer, element, 255)
        element:setData("safe >> movedBy", nil)
        --is_lines_rendered = true
    end
)