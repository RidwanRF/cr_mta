local iShowCache = {}

local iShowState = false

function showItem(data)
    local int2 = localPlayer.interior
    local dim2 = localPlayer.dimension
--    outputChatBox(toJSON(item))
    for k,v in pairs(getElementsByType("player")) do
        local int = getElementInterior(v)
        local dim = getElementDimension(v)
        local x1,y1,z1 = getElementPosition(v)
        local name = "nameR"
        --outputChatBox("asd")
        if int == int2 and dim == dim2 then
            local distance = math.floor(getDistanceBetweenPoints3D(localPlayer.position, v.position))
            
            --outputChatBox(distance)
            if distance <= 8 then
                triggerServerEvent("itemShowTrigger", localPlayer, localPlayer, v, data)
            end
        end
    end
end

function itemShowTrigger(sourceElement, v, data)
    --outputChatBox(tostring(isElement(v)))
    --outputChatBox(tostring(sourceElement == localPlayer))
    iShowCache[sourceElement] = {0, data, "fading", getTickCount()}
    
    local count = 0
    for k,v in pairs(iShowCache) do
        count = count + 1
    end
    
    --outputChatBox(count)
    
    if count >= 1 then
        if not iShowState then
            addEventHandler("onClientRender", root, drawnShowItem, true, "low-5")
            iShowState = true
        end
    else
        if iShowState then
            removeEventHandler("onClientRender", root, drawnShowItem)
            iShowState = false
        end
    end
end
addEvent("itemShowTrigger", true)
addEventHandler("itemShowTrigger", root, itemShowTrigger)

animSpeed = 5
showTime = 4000
maxDistance = 18

function drawnShowItem()
    font2 = exports['cr_fonts']:getFont("Rubik-Regular", 13)
    font3 = exports['cr_fonts']:getFont("Rubik-Regular", 10)
    local x, y, z = getCameraMatrix()
    local now = getTickCount()
    for k,v in pairs(iShowCache) do
        local element = k
        local a, data, anim, tick = unpack(v)
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        --outputChatBox("asd")
        
        if isElement(element) then
            if tick + showTime <= now then
                iShowCache[k][3] = "shading"
                anim = "shading"
            end

            if anim == "shading" then
                iShowCache[k][1] = iShowCache[k][1] - animSpeed
                a = a - animSpeed
                if iShowCache[k][1] <= 0 then
                    a = 0
                    iShowCache[k][1] = 0
                    --bubbles[k][9] = "normal"
                    iShowCache[k] = nil
                    --removeText(element, text)
                end
            else
                iShowCache[k][1] = iShowCache[k][1] + animSpeed
                a = a + animSpeed
                if iShowCache[k][1] >= 255 then
                    a = 255
                    iShowCache[k][1] = 255
                end
            end
            if isElementOnScreen(element) then
                if element.alpha == 255 and element.dimension == localPlayer.dimension and element.interior == localPlayer.interior then
                    local x2 = element:getPosition()
                    local dist = getDistanceBetweenPoints3D(x,y,z,x2.x,x2.y,x2.z)
                    if dist < maxDistance then
                        local x2,y2,z2 = getPedBonePosition(element, 4)
                        --outputChatBox(tostring(clear))
                        if x2 and y2 and z2 then
                            
                            local clear = isLineOfSightClear(x,y,z,x2,y2,z2,true,true,false,true,false,false,false)
                            if clear then
                                --outputChatBox(size)
                                z2 = z2 + 0.5
                                local sx, sy = getScreenFromWorldPosition(x2,y2,z2,25,false)
                                if sx and sy then
                                    local size = 1 - (dist / maxDistance)                
                                    --local sy = sy - (((35) * id) * size)
                                    local c = 50 * size
                                    local b = 45 * size
                                    dxDrawRectangle(sx - c/2, sy - c/2, c, c, tocolor(0,0,0,math.min(a, 255*0.75)))
                                    dxDrawImage(sx - b/2, sy - b/2, b, b, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,a))
                                    
                                    --local sx, sy = sx, sy - c/2 - (20*size)
                                    local startX, startY = sx - c/2, sy - c/2
                                    
                                    --local data = 
                                    renderTooltip(startX, startY, data, math.min(a, 255*0.75))
                                    
                                    --[[
                                    local tooltip = true

                                    if tooltip then
                                        local name, weight, description = getItemName(itemid, value, nbt), items[itemid][3], itemDescriptions[itemid]
                                        --Sorozatszám, állapot.
                                        if not gColor then
                                            gColor = getServerColor(nil, true)
                                        end
                                        if not white then
                                            white = "#ffffff"
                                        end
                                        local w, h = drawnSize["left/right"][1], drawnSize["left/right"][2]
                                        local text = "Név: #3dff33"..name..white.."@|@A@C\nSúly: #33beff"..weight.." kg"..white.."\nLeírás: #3dff33"..description..white.."\n"
            
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
                                            text = text .. "Állapot: "..color..status.."%"..white
                                        else
                                            local value = tonumber(value) or 0
                                            text = text .. "Érték: #3dff33"..value..white
                                        end
                                        local length = dxGetTextWidth(text, 1, font3, true)
                                        if length % 2 ~= 0 then
                                            length = length + 1
                                        end
                                        length = (length + 20) * size
                                        --dxDrawImage(startX - length/2 - w, startY - h - 10, w, h, "assets/images/left.png", 0,0,0, tocolor(255,255,255,alpha))
                                        --dxDrawImage(startX + length/2, startY - h - 10, w, h, "assets/images/right.png", 0,0,0, tocolor(255,255,255,alpha))
                                        --dxDrawImage(startX - w/2, startY - 14, w, h, "assets/images/top.png", 0,0,0, tocolor(255,255,255,255))
                                        dxDrawRectangle(startX - (length)/2, startY - (14 * size), length, (72 * size), tocolor(0,0,0,math.min(255 * 0.74, a)))
                                        dxDrawText(text,startX, startY - (14 * size), startX, startY - (14 * size) + (72 * size), tocolor(255,255,255,a), size, font3, "center", "center", false, false, false, true)
                                        tooltip = false
                                    end]]
                                end
                            end
                        end
                    end
                else
                    iShowCache[k] = nil
                end
            end
        else
            iShowCache[k] = nil
        end
    end
end