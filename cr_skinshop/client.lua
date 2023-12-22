local cache = {}
local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 16)
local font2 = exports['cr_fonts']:getFont("Roboto", 12)
local font3 = exports['cr_fonts']:getFont("Roboto", 11)
local green = exports['cr_core']:getServerColor("orange", true)
local red = "#ff3333"
local r,g,b = exports['cr_core']:getServerColor("orange", false)
local awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 13)
local awesomeFont2 = exports['cr_fonts']:getFont("AwesomeFont", 14)
local awesomeFont3 = exports['cr_fonts']:getFont("AwesomeFont", 11)
local awesomeFont4 = exports['cr_fonts']:getFont("AwesomeFont", 12)
addEventHandler("onClientResourceStart", root,
    function(startedRes)
    	local startedResName = getResourceName(startedRes)
        if startedResName == "cr_core" then
            green = exports['cr_core']:getServerColor("orange", true)
            r,g,b = exports['cr_core']:getServerColor("orange", false)
        elseif startedResName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Yantramanav-Regular", 16)
			font2 = exports['cr_fonts']:getFont("Roboto", 12)
			font3 = exports['cr_fonts']:getFont("Roboto", 11)
			awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 13)
			awesomeFont2 = exports['cr_fonts']:getFont("AwesomeFont", 14)
			awesomeFont3 = exports['cr_fonts']:getFont("AwesomeFont", 11)
			awesomeFont4 = exports['cr_fonts']:getFont("AwesomeFont", 12)
        end
	end
)
local arrowLeft = ""
local arrowRight = ""
local sx, sy = guiGetScreenSize()
local white = "#ffffff"
local walking = false
local walkingStyles = {
    133, 126
}

local nowWalkingStyle = 1

local cursorState = isCursorShowing()
local cursorX, cursorY = sx/2, sy/2
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

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Fent
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Lent
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Bal
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Jobb
    --dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
end

local markers = {
    --[[
    {x,y,z,dim,int,{r,g,b},name, {pedX, pedY, pedZ, pedRot}, {cameraX, cameraY, cameraZ}, 
        ["skins"] = {
            --{SkinID, Ár}
        }
    }
    ]]
    --{1268.2322998047, -1420.4986572266, 14, 0,0, {255, 87, 87}, "Női kinézetek", {1260.9200439453, -1421.2680664063, 14.987089157104, 270}, {1265.0589599609, -1421.4360351563, 16.753128051758},
	{1101.1934814453, -1585.4656982422, 12.61651802063, 0,0, {255, 87, 87}, "Női kinézetek", {1103.4033203125, -1585.3065185547, 13.61651802063, 178}, {1103.1358642578, -1587.3562011719, 15},
        ["skins"] = {
            --{SkinID, Ár}
            {107, 25000}, 
            {109, 15000},
        }
    },
    {1105.3395996094, -1585.3669433594, 12.61651802063, 0,0, {51, 133, 255}, "Férfi kinézetek", {1103.4033203125, -1585.3065185547, 13.61651802063, 185}, {1103.4, -1587.2, 15},
        ["skins"] = {
            --{SkinID, Ár}
            {117, 25000}, 
            {121, 15000},
            {113, 125},
        }
    },
}

local markerSize = 1.2

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(markers) do
            local x,y,z,dim,int,colors,name, pedPos, cameraPos = unpack(v)
            local r,g,b = unpack(colors)
            local pedX, pedY, pedZ = unpack(pedPos)
            local cameraX, cameraY, cameraZ = unpack(cameraPos)
            local marker = createMarker(x,y,z, "cylinder", markerSize, r,g,b)
            setElementDimension(marker, dim)
            setElementInterior(marker, int)
            setElementData(marker, "skinshop >> id", k)
            setElementData(marker, "skinshop >> name", name)
            setElementData(marker, "skinshop >> cameraPos", cameraPos)
            setElementData(marker, "skinshop >> pedPos", pedPos)
            cache[k] = marker
        end
    end
)

function dxDrawRectangleBox(left, top, width, height)
    dxDrawRectangle(left, top, width, height, tocolor(0,0,0,160))
    dxDrawRectangle(left-1, top, 1, height, tocolor(0,0,0,220))
    dxDrawRectangle(left+width, top, 1, height, tocolor(0,0,0,220))
    dxDrawRectangle(left, top-1, width, 1, tocolor(0,0,0,220))
    dxDrawRectangle(left, top+height, width, 1, tocolor(0,0,0,220))
end

local maxDistance = 32

function drawnSkinshopNames()
    if not getElementData(localPlayer, "hudVisible") then return end
    local cameraX, cameraY, cameraZ = getCameraMatrix()
    local dim2, int2 = getElementDimension(localPlayer), getElementInterior(localPlayer)
    for id,element in pairs(cache) do
        --if isElement(element) then
            --if getElementData(element, "skinshop >> id") then
                local dim1 = getElementDimension(element)
                local int1 = getElementInterior(element)
                if getElementAlpha(element) == 255 and dim1 == dim2 and int1 == int2 then
                    local worldX, worldY, worldZ = getElementPosition(element)
                    local line = isLineOfSightClear(cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, false, false, true, false, false, false, localPlayer)
                    if line then
                        local distance = math.sqrt((cameraX - worldX) ^ 2 + (cameraY - worldY) ^ 2 + (cameraZ - worldZ) ^ 2) - 4
                        if distance < 0.1 then
                            distance = 0.1
                        end
                        if distance <= maxDistance then
                            local boneX, boneY, boneZ = getElementPosition(element)
                            local size = 1 - (distance / maxDistance)
                            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + (1.5 * size))
                            if screenX and screenY then
                                local text = getElementData(element, "skinshop >> name")
                                local x = dxGetTextWidth(text, size, font) + 20 * size
                                local y = 30 * size
                                dxDrawRectangleBox(screenX - x/2, screenY - y / 2, x, y, tocolor(20,20,20,180))
                                dxDrawText(text, screenX, screenY, screenX, screenY, tocolor(255,255,255,255), size, font, "center", "center")
                            end
                        end
                    end
                end
            --end
        --end
    end
end
addEventHandler("onClientRender", root, drawnSkinshopNames, true, "low-5")

function onMarkerHit(hitPlayer, matchingDimension)
	if hitPlayer == localPlayer then
        if getPedOccupiedVehicle(localPlayer) then return end
        if matchingDimension then
            if getElementData(source, "skinshop >> id") then
                local x,y,z = getElementPosition(source)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                if dist < 2 then
                    playSound("files/pep.mp3")
                    sourceMarker = source
                    addEventHandler("onClientRender", root, drawnEnteringText, true, "low-5")
                    bindKey("E", "down", doingShopping)
                    state = true
                    nowWalkingStyle = 1
                end
            end
        end
    end
end
addEventHandler("onClientMarkerHit", root, onMarkerHit)

function onMarkerLeave(hitPlayer, matchingDimension)
	if hitPlayer == localPlayer then
        if getPedOccupiedVehicle(localPlayer) then return end
        if matchingDimension then
            if getElementData(source, "skinshop >> id") then
                if state then
                    exitShopping()
                    sourceMarker = nil
                    removeEventHandler("onClientRender", root, drawnEnteringText)
                    unbindKey("E", "down", doingShopping)
                    state = false
                end
            end
        end
    end
end
addEventHandler("onClientMarkerLeave", root, onMarkerLeave)

setTimer(
    function()
        if state then
            if getPedOccupiedVehicle(localPlayer) then
                exitShopping()
                sourceMarker = nil
                removeEventHandler("onClientRender", root, drawnEnteringText)
                unbindKey("E", "down", doingShopping)
                state = false
            end
        end
    end, 1000, 0
)

addEventHandler("onClientClick", root,
    function(b, s)
        if isElement(ped) then
            if b == "left" and s == "down" then
                if isInSlot(sx/2 - 125/2, sy - 180, 125, 20) then
                    walking = not walking
                    if walking then
                        setPedControlState(ped, "forwards", true)
                    else
                        setPedControlState(ped, "forwards", false)
                    end
                elseif isInSlot(sx/2 - 200/2 - 20, sy - 180, 20, 20) then -- bal
                    if nowWalkingStyle - 1 >= 1 then
                        nowWalkingStyle = nowWalkingStyle - 1
                        local walkingStyle = walkingStyles[nowWalkingStyle]
                        setPedWalkingStyle(ped, walkingStyle)
                    elseif nowWalkingStyle -1 < 1 then
                        nowWalkingStyle = #walkingStyles
                        local walkingStyle = walkingStyles[nowWalkingStyle]
                        setPedWalkingStyle(ped, walkingStyle)
                    end
                elseif isInSlot(sx/2 + 200/2, sy - 180, 20, 20) then -- jobb
                    if nowWalkingStyle + 1 <= #walkingStyles then
                        nowWalkingStyle = nowWalkingStyle + 1
                        local walkingStyle = walkingStyles[nowWalkingStyle]
                        setPedWalkingStyle(ped, walkingStyle)
                    elseif nowWalkingStyle + 1 > #walkingStyles then
                        nowWalkingStyle = 1
                        local walkingStyle = walkingStyles[nowWalkingStyle]
                        setPedWalkingStyle(ped, walkingStyle)
                    end
                end
            end
        end
    end
)

function drawnEnteringText()
    if isElement(ped) then
        local id = getElementData(sourceMarker, "skinshop >> id")
        local skinCost = markers[id]["skins"][nowSkinID][2]
        local skinID = markers[id]["skins"][nowSkinID][1]
        local text = "Ár: "..green..skinCost..white.."$\nA megvételhez használd az "..green.."'Enter'"..white.." billentyűt!\nA kilépéshez használd a "..red.."'Backspace'"..white.." billentyűt!\nA váltáshoz használd a "..green.."'Balra' "..white.."és "..green.."'Jobbra'"..white.." nyílat!"
        local x = dxGetTextWidth(text, size, font, true) + 10
        dxDrawRectangle(sx/2-x/2, sy - 100 - 100/2, x, 100, tocolor(0,0,0,180))
        dxDrawText(text, sx/2, sy - 100, sx/2, sy - 100, tocolor(255,255,255,255), 1, font2, "center", "center", false, false, false, true)
        --dxDrawRectangle(sx/2 - 200 - 20/2, sy/2 - 20/2, 20, 20, tocolor(255,255,255,255))
        --dxDrawRectangle(sx/2 + 220 - 20/2, sy/2 - 20/2, 20, 20, tocolor(255,255,255,255))
        if isInSlot(sx/2 - 200 - 20/2, sy/2 - 20/2, 20, 20) then
            if getKeyState("mouse1") then
                local a,a,newRot = getElementRotation(ped)
                local newRot = newRot - 1
                if newRot < 0 then
                    newRot = 359
                end
                setElementRotation(ped, 0, 0, newRot, "default", true)
            end
            shadowedText(arrowLeft, sx/2 - 200, sy/2, sx/2 - 200, sy/2, tocolor(255,255,255,255), 1, awesomeFont2, "center", "center")
            dxDrawText(arrowLeft, sx/2 - 200, sy/2, sx/2 - 200, sy/2, tocolor(255,255,255,255), 1, awesomeFont2, "center", "center")
        else
            shadowedText(arrowLeft, sx/2 - 200, sy/2, sx/2 - 200, sy/2, tocolor(255,255,255,255), 1, awesomeFont, "center", "center")
            dxDrawText(arrowLeft, sx/2 - 200, sy/2, sx/2 - 200, sy/2, tocolor(255,255,255,255), 1, awesomeFont, "center", "center")
        end
        
        if isInSlot(sx/2 + 220 - 20/2, sy/2 - 20/2, 20, 20) then
            if getKeyState("mouse1") then
                local a1,a2,newRot = getElementRotation(ped)
                local newRot = newRot + 1
                if newRot > 360 then
                    newRot = 0
                end
                setElementRotation(ped, 0, 0, newRot, "default", true)
            end
            shadowedText(arrowRight, sx/2 + 220, sy/2, sx/2 + 220, sy/2, tocolor(255,255,255,255), 1, awesomeFont2, "center", "center")
            dxDrawText(arrowRight, sx/2 + 220, sy/2, sx/2 + 220, sy/2, tocolor(255,255,255,255), 1, awesomeFont2, "center", "center")
        else    
            shadowedText(arrowRight, sx/2 + 220, sy/2, sx/2 + 220, sy/2, tocolor(255,255,255,255), 1, awesomeFont, "center", "center")
            dxDrawText(arrowRight, sx/2 + 220, sy/2, sx/2 + 220, sy/2, tocolor(255,255,255,255), 1, awesomeFont, "center", "center")
        end    
        
        dxDrawRectangle(sx/2 - 200/2, sy - 180, 200, 20, tocolor(0,0,0,180))
        dxDrawRectangle(sx/2 - 200/2 - 20, sy - 180, 20, 20, tocolor(0,0,0,220))
        if isInSlot(sx/2 - 200/2 - 20, sy - 180, 20, 20) then
            dxDrawText(arrowLeft, sx/2 - 200/2 - 20, sy - 170, sx/2 - 200/2, sy - 170, tocolor(255,255,255,255), 1, awesomeFont4, "center", "center")
        else
            dxDrawText(arrowLeft, sx/2 - 200/2 - 20, sy - 170, sx/2 - 200/2, sy - 170, tocolor(255,255,255,255), 1, awesomeFont3, "center", "center")
        end
        dxDrawRectangle(sx/2 + 200/2, sy - 180, 20, 20, tocolor(0,0,0,220))
        if isInSlot(sx/2 + 200/2, sy - 180, 20, 20) then
            dxDrawText(arrowRight, sx/2 + 200/2, sy - 170, sx/2 + 200/2 + 20, sy - 170, tocolor(255,255,255,255), 1, awesomeFont4, "center", "center")
        else
            dxDrawText(arrowRight, sx/2 + 200/2, sy - 170, sx/2 + 200/2 + 20, sy - 170, tocolor(255,255,255,255), 1, awesomeFont3, "center", "center")
        end
        if walking then
            setPedControlState(ped, "walk", true)
            dxDrawText("Sétálás kikapcsolása", sx/2, sy - 180, sx/2, sy - 180 + 20, tocolor(255,87,87,255), 1, font2, "center", "center", false, false, false, true)
        else
            dxDrawText("Sétálás bekapcsolása", sx/2, sy - 180, sx/2, sy - 180 + 20, tocolor(87,255,87,255), 1, font2, "center", "center", false, false, false, true)
        end
    else
        local text = "Az interakcióhoz használd az "..green.."'E'"..white.." billentyűt!"
        local x = dxGetTextWidth(text, size, font, true) + 10
        dxDrawRectangle(sx/2-x/2, sy - 100 - 20/2, x, 20, tocolor(0,0,0,180))
        dxDrawText(text, sx/2, sy - 100, sx/2, sy - 100, tocolor(255,255,255,255), 1, font3, "center", "center", false, false, false, true)
    end
end

function doingShopping()
    if isTimer(spamTimer) then return end
    spamTimer = setTimer(function() end, 500, 1)
    if isElement(ped) then return end
    unbindKey("E", "down", doingShopping)
    setElementFrozen(localPlayer, true) 
    local cx, cy, cz = unpack(getElementData(sourceMarker, "skinshop >> cameraPos"))
    local x,y,z,rot  = unpack(getElementData(sourceMarker, "skinshop >> pedPos"))
    setCameraMatrix(cx, cy, cz, x,y,z)
    walking = false
    nowSkinID = 1
    local id = getElementData(sourceMarker, "skinshop >> id")
    local skinID = markers[id]["skins"][nowSkinID][1]
    ped = createPed(skinID, x,y,z)
    local walkingStyle = walkingStyles[nowWalkingStyle]
    setPedWalkingStyle(ped, walkingStyle)
    setElementRotation(ped, 0,0,rot, "default", true)
    setElementFrozen(ped, true)
    showChat(false)
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    bindKey("arrow_r", "down", nextSkin)
    bindKey("arrow_l", "down", oldSkin)
    bindKey("enter", "down", buySkin)
    bindKey("backspace", "down", exitShopping)
    shopState = true
end

function nextSkin()
    local id = getElementData(sourceMarker, "skinshop >> id")
    if nowSkinID + 1 <= #markers[id]["skins"] then
        nowSkinID = nowSkinID + 1
        local skinID = markers[id]["skins"][nowSkinID][1]
        setElementModel(ped, skinID)
    elseif nowSkinID + 1 > #markers[id]["skins"] then
        nowSkinID = 1
        local skinID = markers[id]["skins"][nowSkinID][1]
        setElementModel(ped, skinID)
    end
end

function oldSkin()
    local id = getElementData(sourceMarker, "skinshop >> id")
    if nowSkinID - 1 >= 1 then
        nowSkinID = nowSkinID - 1
        local skinID = markers[id]["skins"][nowSkinID][1]
        setElementModel(ped, skinID)
    elseif nowSkinID -1 < 1 then
        nowSkinID = #markers[id]["skins"]
        local skinID = markers[id]["skins"][nowSkinID][1]
        setElementModel(ped, skinID)
    end
end

function buySkin()
    local id = getElementData(sourceMarker, "skinshop >> id")
    local skinCost = markers[id]["skins"][nowSkinID][2]
    local skinID = markers[id]["skins"][nowSkinID][1]
    if skinID == getElementData(localPlayer, "char >> skin") then
        exports['cr_infobox']:addBox("error", "Te már ezt a kinézetet viseled!")
        return
    end
    if exports['cr_core']:takeMoney(localPlayer, skinCost, false) then
        exports['cr_infobox']:addBox("success", "Sikeresen megvásároltad a kiválasztott kinézetet")
        exitShopping()
        setElementData(localPlayer, "char >> skin", skinID)
    else
        exports['cr_infobox']:addBox("error", "Nincs elég pénzed")
    end
end

function exitShopping()
    if shopState then
        setCameraTarget(localPlayer, localPlayer)
        setElementFrozen(localPlayer, false)
        if isElement(ped) then
            destroyElement(ped)
        end
        showChat(true)
        setElementData(localPlayer, "keysDenied", false)
        setElementData(localPlayer, "hudVisible", true)
        unbindKey("arrow_r", "down", nextSkin)
        unbindKey("arrow_l", "down", oldSkin)
        unbindKey("enter", "down", buySkin)
        unbindKey("backspace", "down", exitShopping)
        shopState = false
    end
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if state then
            exitShopping()
        end
    end
)