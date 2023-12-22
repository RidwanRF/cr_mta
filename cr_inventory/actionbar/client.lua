local lastItem = 0

gNum = 255

addCommandHandler("togactionbar", function() if gNum == 0 then gNum = 255 elseif gNum == 255 then gNum = 0 end end)

isInUse = {}

function getNode(Name, column)
    --outputChatBox(Name)
    local enabled, x,y,w,h,sizable,turnable, sizeDetails, t, columns = getDetails(Name)
    --outputChatBox(x)
    if enabled then
        if column == "x" then
            return tonumber(x)
        elseif column == "y" then
            return tonumber(y)
        elseif column == "w" or column == "width" then
            return tonumber(w)
        elseif column == "h" or column == "height" then
            return tonumber(h)
        elseif column == "type" then
            return tonumber(t)
        elseif column == "columns" then
            return tonumber(columns)
        end
    end
    return 0;
end

function DxDrawActionbar()
    --outputChatBox("asd")
    local alpha = gNum
    
    font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    font3 = exports['cr_fonts']:getFont("Rubik-Regular", 10)
    font4 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    
    local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
    local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
    
    ax = ax + 3
    acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
    
    if acType == 1 then
        local w, h = (36 * columns + columns * 1) + 1, 40
        dxDrawRectangle(ax, ay, w, h, tocolor(0,0,0,math.min(255*0.75, alpha)))
        
        local _w = w
        
        local startX = ax + 1
        local startY = ay + 2
        
        checkTableArray(1, accID, 10)
        if not cache[1] then
            return
        else
            if not cache[1][accID] then
                return
            else
                if not cache[1][accID][10] then
                    return
                end
            end
        end
        local data = cache[1][accID][10]
        
        if isCursorShowing() and interfaceDrawn then
            --dxDrawRectangle(ax, ay, 20, 20)
            local aw = aw
            dxDrawRectangle(ax + aw, ay, 20, 20, tocolor(0,0,0,math.min(180, alpha)))
            if isInSlot(ax + aw, ay, 20, 20) then
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(255,255,255,alpha), 1, font, "center", "center")
            else
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(255,255,255,alpha), 1, font4, "center", "center")
            end
            
            dxDrawRectangle(ax + aw, ay + 20, 20, 20, tocolor(0,0,0,math.min(180, alpha)))
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(255,255,255,alpha), 1, font, "center", "center")
            else
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(255,255,255,alpha), 1, font4, "center", "center")
            end
        end
        --cache[1][accID][10] = {}
        --cache[1][accID][10][1] = {1, 1}
        local tooltip = false
        for i = 1, columns do
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            
            if isInSlot(startX, startY, w, h) or getKeyState(i) and not isConsoleActive() and not guiState then
                dxDrawRectangle(startX, startY, w, h, tocolor(255, 153, 51, math.min(255 * 0.8, alpha)))
                if not getKeyState(i) then
                    isIn = true
                    _lastItem = lastItem
                    lastItem = i
                end
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(52, 52, 52,math.min(63.75, alpha)))
            end

            if data then
                local data = data[i]
                if data then
                    local _invType = invType
                    local invType, pairSlot = unpack(data)
                    local data = cache[1][accID][invType][pairSlot]
                    if moveState then
                        if pairSlot == moveSlot and invType == _invType then
                            data = moveDetails
                        end
                    end
                    
                    local isActive = false
                    if activeSlot[invType .. "-" .. pairSlot] then
                        --if invElement == localPlayer and invType == 1 then
                        isActive = true
                        --end
                    end
                    
                    if data then
                        
                        if isActive and not isIn then
                            dxDrawRectangle(startX, startY, w, h, tocolor(85, 255, 51, math.min(255 * 0.8, alpha)))
                        end
                        
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if isIn then
                            tooltip = i
                            tooltipD = data
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

                        if count >= 2 then
                            dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                        end
                    end
                end
            end

            if tooltip then
                local data = tooltipD
                renderTooltip(startX, startY, data, alpha)
                tooltip = false
            end
            
            startX = startX + w + 1
        end
        
        --local w, h = drawnSize["left/right"][1], drawnSize["left/right"][2]
        dxDrawImage(ax + _w, ay - h + 20, 14, 80, "assets/actionbar/right.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawImage(ax - 14, ay - h + 20, 14, 80, "assets/actionbar/left.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif acType == 2 then
        
        local ax = ax - 2
        local w, h = 40, (36 * columns + columns * 1)+ 1
        dxDrawRectangle(ax, ay, w, h, tocolor(0,0,0,math.min(255*0.74, alpha)))
        
        if isCursorShowing() and interfaceDrawn then
            --dxDrawRectangle(ax, ay, 20, 20)
            local aw = aw
            dxDrawRectangle(ax + aw, ay, 20, 20, tocolor(0,0,0,math.min(180, alpha)))
            if isInSlot(ax + aw, ay, 20, 20) then
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(255,255,255,alpha), 1, font, "center", "center")
            else
                dxDrawText("+",ax + aw, ay, ax + aw + 20, ay + 20, tocolor(255,255,255,alpha), 1, font4, "center", "center")
            end
            
            dxDrawRectangle(ax + aw, ay + 20, 20, 20, tocolor(0,0,0,math.min(180, alpha)))
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(255,255,255,alpha), 1, font, "center", "center")
            else
                dxDrawText("-",ax + aw, ay + 20, ax + aw + 20, ay + 40, tocolor(255,255,255,alpha), 1, font4, "center", "center")
            end
        end
        
        local _h = h
        
        local startX = ax + 2
        local startY = ay + 1
        
        checkTableArray(1, accID, 10)
        if not cache[1] then
            return
        else
            if not cache[1][accID] then
                return
            else
                if not cache[1][accID][10] then
                    return
                end
            end
        end
        local data = cache[1][accID][10]
        local tooltip = false
        for i = 1, columns do
            local w,h = drawnSize["bg_cube"][1], drawnSize["bg_cube"][2]
            local isIn = false
            
            if isInSlot(startX, startY, w, h) or getKeyState(i) and not isConsoleActive() and not guiState then
                dxDrawRectangle(startX, startY, w, h, tocolor(255, 153, 51, math.min(255 * 0.8, alpha)))
                if not getKeyState(i) then
                    isIn = true
                    _lastItem = lastItem
                    lastItem = i
                end
            else
                dxDrawRectangle(startX, startY, w, h, tocolor(52, 52, 52,math.min(63.75, alpha)))
            end

            if data then
                local data = data[i]
                if data then
                    local _invType = invType
                    local invType, pairSlot = unpack(data)
                    local data = cache[1][accID][invType][pairSlot]
                    if moveState then
                        if pairSlot == moveSlot and invType == _invType then
                            data = moveDetails
                        end
                    end
                    
                    local isActive = false
                    if activeSlot[invType .. "-" .. pairSlot] then
                        --if invElement == localPlayer and invType == 1 then
                        isActive = true
                        --end
                    end
                    
                    if data then
                        
                        if isActive and not isIn then
                            dxDrawRectangle(startX, startY, w, h, tocolor(85, 255, 51, math.min(255 * 0.8, alpha)))
                        end
                        
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        if isIn then
                            tooltip = i
                            tooltipD = data
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
                        if cuffed or jailed or inventoryForceDisabled then
                            dxDrawImage(startX + b, startY + b, w, h, "assets/images/delete.png", 0,0,0, tocolor(255,255,255,alpha))
                        end

                        if count >= 2 then
                            dxDrawText(count,startX + b, startY + b, startX + b + w, startY + b + h, tocolor(255,255,255,alpha), 1, font2, "right", "bottom")
                        end
                    end
                end
            end

            if tooltip then
                local data = tooltipD
                renderTooltip(startX, startY, data, alpha)
                tooltip = false
            end
            
            startY = startY + h + 1
        end
        
        dxDrawImage(ax - 5, ay - 50/2 - 1, 50, 50, "assets/actionbar/top.png", 0,0,0, tocolor(255,255,255,alpha))
        dxDrawImage(ax - 5, ay + _h - 50/2 + 1, 50, 50, "assets/actionbar/bottom.png", 0,0,0, tocolor(255,255,255,alpha))
    end
end

addEventHandler("onClientResourceStart",resourceRoot,
    function()     
        --local res = getThisResource()
        if getElementData(localPlayer, "loggedIn") and getElementData(localPlayer, "hudVisible") and getElementData(localPlayer, "Actionbar.enabled") and getElementData(root, "loaded") then
            addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
        end	
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "loggedIn" then
            local value = getElementData(source, dName)
            if value then
                --local res = getThisResource()
                if getElementData(source, "hudVisible") and source:getData("Actionbar.enabled") and getElementData(root, "loaded") then
                    addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                end
            else
                removeEventHandler("onClientRender",root,DxDrawActionbar)
            end
        elseif dName == "hudVisible" then
            local value = getElementData(source, dName)
            if value then
                --local res = getThisResource()
                if getElementData(source, "loggedIn") and source:getData("Actionbar.enabled") and getElementData(root, "loaded") then
                    addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                end
            else
                removeEventHandler("onClientRender",root,DxDrawActionbar)
            end    
        elseif dName == "player.Actionbar-visible" then
            local value = getElementData(source, dName)
            if value then
                --local res = getThisResource()
                if getElementData(source, "loggedIn") and source:getData("Actionbar.enabled") and getElementData(root, "loaded") then
                    addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                end
            else
                removeEventHandler("onClientRender",root,DxDrawActionbar)
            end
        elseif dName == "Actionbar.enabled" then
            local value = getElementData(source, dName)
            if value then
                --local res = getThisResource()
                if getElementData(source, "loggedIn") and getElementData(source, "hudVisible") and getElementData(root, "loaded") then
                    addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                end
            else
                removeEventHandler("onClientRender",root,DxDrawActionbar)
            end    
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "loaded" then
            local value = getElementData(root, "loaded")
            if value then
                if getElementData(localPlayer, "hudVisible") and localPlayer:getData("Actionbar.enabled") and localPlayer:getData("loggedIn") then
                    addEventHandler("onClientRender",root,DxDrawActionbar, true, "low-5")
                end
            end
        end
    end
)


bindKey("mouse3", "down",
    function()
        local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
        local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
        ax = ax + 3
        local acType, columns = getNode("Actionbar", "type"), getNode("Actionbar", "columns")
    
        local w, h = (36 * columns + columns * 1)+ 1, 40
        if isInSlot(ax, ay, aw, ah) then
            local a = 1
            if acType == 1 then
                a = 2
            end
            
            local w,h = (36 * columns + columns * 1)+ 1, 40
            
            if a == 2 then
                h = w
                w = 40
            end
            
            exports['cr_interface']:setNode("Actionbar", "type", a)
            exports['cr_interface']:setNode("Actionbar", "width", w)
            exports['cr_interface']:setNode("Actionbar", "height", h)
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" and isCursorShowing() and interfaceDrawn then
            local ax, ay = getNode("Actionbar", "x"), getNode("Actionbar", "y")
            local aw, ah = getNode("Actionbar", "width"), getNode("Actionbar", "height")
            if isInSlot(ax + aw, ay, 20, 20) then
                local oldColumns = getNode("Actionbar", "columns")
                if oldColumns + 1 <= 9 then
                    exports['cr_interface']:setNode("Actionbar", "columns", oldColumns + 1)
                    
                    local acType = getNode("Actionbar", "type")
                    if acType == 1 then
                        local w, h = (36 * (oldColumns + 1) + (oldColumns + 1) * 1)+ 10, 40
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    else
                        local w, h = 40, (36 * (oldColumns + 1) + (oldColumns + 1) * 1)+ 10
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    end
                end
            end
            
            if isInSlot(ax + aw, ay + 20, 20, 20) then
                local oldColumns = getNode("Actionbar", "columns")
                if oldColumns - 1 >= 1 then
                    exports['cr_interface']:setNode("Actionbar", "columns", oldColumns - 1)
                    
                    local acType = getNode("Actionbar", "type")
                    if acType == 1 then
                        local w, h = (36 * (oldColumns - 1) + (oldColumns - 1) * 1)+ 10, 40
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    else
                        local w, h = 40, (36 * (oldColumns - 1) + (oldColumns - 1) * 1)+ 10
                        exports['cr_interface']:setNode("Actionbar", "width", w)
                        exports['cr_interface']:setNode("Actionbar", "height", h)
                    end
                end
            end
        end
    end
)

for i = 1, 9 do
    bindKey(i, "down",
        function(i)
            if not localPlayer:getData("hudVisible") or localPlayer:getData("keysDenied") then
                return
            end
            i = tonumber(i)
            
            local columns = getNode("Actionbar", "columns")
            
            if i <= columns then
                --outputChatBox(i)
                if localPlayer:getData("loggedIn") and not guiState then
                    --outputChatBox("asdd")
                    local data = cache[1][accID][10]
                    if data then
                        --outputChatBox("asdDDD")
                        local data = data[i]
                        if data then
                            --outputChatBox("asdDD")
                            local _invType = invType
                            local invType, pairSlot = unpack(data)
                            --outputChatBox(invType)
                            --outputChatBox(invType)
                            --outputChatBox(pairSlot)
                            local data = cache[1][accID][invType][pairSlot]
                            if moveState then
                                if pairSlot == moveSlot and invType == _invType then
                                    data = moveDetails
                                end
                            end
                            if data then
                                --outputChatBox("asd")
                                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                                --outputChatBox("UseItem: "..itemid)
                                useItem(pairSlot, id, itemid, value, count, status, dutyitem, premium, nbt)
                                playSound("assets/sounds/key.mp3")
                            end
                        end
                    end
                end
            end
        end, i
    )
end