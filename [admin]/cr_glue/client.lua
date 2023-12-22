local enabledVehs = {
    --[id] = true
    ["472"] = true, 
    ["473"] = true, 
    ["493"] = true, 
    ["595"] = true, 
    ["484"] = true, 
    ["430"] = true, 
    ["453"] = true, 
    ["452"] = true, 
    ["446"] = true, 
    ["454"] = true, 
    ["422"] = true, 
    ["478"] = true,
}
lastOpenTick = -5000
enabled = false
glue = localPlayer:getData("glue>state")
if not glue then
    gElement = getPlayerContactElement(localPlayer)
    if localPlayer.vehicle then
        gElement = nil
    end
    
    if isElement(gElement) then
        if getElementType(gElement) == "vehicle" then
            if enabledVehs[gElement.model] then
                enabled = true
            end
        end
    end
else
    gElement = localPlayer:getData("glue>e")
    --outputChatBox(tostring(gElement))
    if isElement(gElement) then
        enabled = true
    end
end
isRender = false

setTimer(
    function()
        if not glue then
            gElement = getPlayerContactElement(localPlayer)
            if localPlayer.vehicle then
                gElement = nil
            end
            enabled = false
            if isElement(gElement) then
                if getElementType(gElement) == "vehicle" then
                    if enabledVehs[tostring(gElement.model)] then
                        --outputChatBox(gElement.model)
                        enabled = true
                    end
                end
            end
        else
            enabled = true
        end
        
        --enabled = true
        
        if enabled then
            if not isRender then
                addEventHandler("onClientRender", root, drawnText, true, "low-5")
                isRender = true
            end
        else
            if isRender then
                removeEventHandler("onClientRender", root, drawnText)
                isRender = false
            end
        end
    end, 50, 0
)

local sx, sy = guiGetScreenSize()

function drawnText()
    font = exports['cr_fonts']:getFont("Roboto", 11)
    colorCode = exports['cr_core']:getServerColor(nil, true)
    
    local text = ""
    if not glue then
        text = "A járműhöz tapadáshoz használd a(z) '"..colorCode.."X#ffffff' billentyűt!"
    else
        text = "A járműhöz tapadás abbahagyásához használd a(z) '"..colorCode.."X#ffffff' billentyűt!"
    end
    local width = dxGetTextWidth(text, 1, font, true) + 20
    local height = dxGetFontHeight(1, font) + 10
    
    dxDrawRectangle(sx/2 - width/2, 50 - height/2, width, height, tocolor(0,0,0,180))
    dxDrawText(text, sx/2, 50, sx/2, 50, tocolor(255,255,255,255),1, font, "center", "center", false, false, false, true)
end

if enabled then
    if not isRender then
        addEventHandler("onClientRender", root, drawnText, true, "low-5")
        isRender = true
    end
else
    if isRender then
        removeEventHandler("onClientRender", root, drawnText)
        isRender = false
    end
end

function deatach()
    glue = false
    localPlayer:setData("glue>state", glue)
    localPlayer:setData("glue>e", nil)
    triggerServerEvent("glue>vehicle>deattach",localPlayer)
end

function attach()
    local px, py, pz = getElementPosition(localPlayer)
    local vx, vy, vz = getElementPosition(gElement)
    local sx = px - vx
    local sy = py - vy
    local sz = pz - vz

    local rotpX = 0
    local rotpY = 0
    local a,b,rotpZ = getElementRotation(localPlayer)     

    local rotvX,rotvY,rotvZ = getElementRotation(gElement)

    local t = math.rad(rotvX)
    local p = math.rad(rotvY)
    local f = math.rad(rotvZ)

    local ct = math.cos(t)
    local st = math.sin(t)
    local cp = math.cos(p)
    local sp = math.sin(p)
    local cf = math.cos(f)
    local sf = math.sin(f)

    local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
    local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
    local y = st*sz - sf*ct*sx + cf*ct*sy

    local rotX = rotpX - rotvX
    local rotY = rotpY - rotvY
    local rotZ = rotpZ - rotvZ

    glue = true
    localPlayer:setData("glue>state", glue)
    localPlayer:setData("glue>e", gElement)

    triggerServerEvent("glue>vehicle>attach",localPlayer,gElement,x, y, z, rotX, rotY, rotZ)
end

bindKey("x", "down",
    function()
        if isRender then
            if glue then -- Attach
                local now = getTickCount()
                local a = 1
                if now <= lastOpenTick + a * 1000 then
                    return
                end
                deatach()
                
                lastOpenTick = getTickCount()
            else -- Dettach
                local now = getTickCount()
                local a = 1
                if now <= lastOpenTick + a * 1000 then
                    return
                end
                
                attach()
                
                lastOpenTick = getTickCount()
            end
        end
    end
)

addEventHandler("onClientElementDestroy",root,
	function()
		if gElement == source then
			deatach()
		end
	end
)

addEventHandler("onClientElementDataChange",root,
	function(dName)
		if getElementType(source) == "vehicle" and dName == "veh >> loaded" then
			if gElement == source then
				local bool = getElementData(source,dName)
				if not bool then
					deatach()
				end
			end
		end
	end
)