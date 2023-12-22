local objects = {
    --[ID] = itemID,
    [955] = 7,
    [956] = 6,
    [2443] = 7,
    [1340] = 1,
    [1341] = 2,
}

local offsets = {
    [955] = {0, -0.75, -0.5},
    [956] = {0, -0.75, -0.5},
    [2443] = {0, -0.75, -0.5},
    [1340] = {1, 0, -1},
    [1341] = {1, -0.5, -1},
}

local costs = {
    --[ItemID] = money
    [1] = 2,
    [7] = 3,
    [2] = 4,
    [6] = 1,
}

local cache = {}
local itemId, itemName, state
local lastCheckTick = -500

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("object")) do
            if objects[v.model] then
                local x, y, z = getElementPosition(v) 
                v.collisions = true
                local rot = v.rotation.z
                local vMatrix = Matrix(x,y,z, 0, 0, rot)
                local pos = vMatrix:transformPosition(unpack(offsets[v.model]))
                local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(v)
                
                local marker = Marker(pos, "cylinder", 0.8, 225, 225, 80, 180);
                attachElements(marker, v, unpack(offsets[v.model]))
                marker.alpha = 0
                marker.dimension = v.dimension ~= -1 and v.dimension or 0
                marker.interior = v.interior
                --localPlayer.position = marker.position
                cache[marker] = v
            end
        end
    end
)

addEventHandler("onClientMarkerHit", root,
    function(thePlayer, matchingDimension)
        if matchingDimension and thePlayer == localPlayer then 
            --outputChatBox(tostring(cache[source]))
            if cache[source] then
                local x,y,z = getElementPosition(source)
                local px,py,pz = getElementPosition(localPlayer)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                if dist <= 2 then
                    local obj = cache[source]
                    local modelID = obj.model
                    itemId = objects[modelID]
                    itemName = getItemName(itemId)
                    cost = costs[itemId]
                    playSound(":cr_skinshop/files/pep.mp3")
                    sourceCol = source
                    addEventHandler("onClientRender", root, drawnEnteringText, true, "low-5")
                    bindKey("E", "down", doingShopping)
                    state = true
                end
            end
        end
    end
)

addEventHandler("onClientMarkerLeave", root,
    function(thePlayer, matchingDimension)
        if matchingDimension and thePlayer == localPlayer then 
            --outputChatBox(tostring(cache[source]))
            if state then
                removeEventHandler("onClientRender", root, drawnEnteringText)
                unbindKey("E", "down", doingShopping)
                state = false
            end
        end
    end
)

local size = 1
white = "#ffffff"
local sx, sy = guiGetScreenSize()
function drawnEnteringText()
    font = exports['cr_fonts']:getFont("Roboto", 11)
    green = exports['cr_core']:getServerColor(nil, true)
    local text = "Egy "..green.."'"..itemName.."'"..white.." vásárlásához használd az "..green.."'E'"..white.." billentyűt! ("..green..""..cost.."$"..white..")"
    local x = dxGetTextWidth(text, 1, font, true) + 10
    dxDrawRectangle(sx/2-x/2, sy - 100 - 20/2, x, 20, tocolor(0,0,0,180))
    dxDrawText(text, sx/2, sy - 100, sx/2, sy - 100, tocolor(255,255,255,255), 1, font, "center", "center", false, false, false, true)
end

function doingShopping()
    local a = 5
    local now = getTickCount()
    if now <= lastCheckTick + a * 1000 then
        return
    end
    lastCheckTick = now
    
    if exports['cr_network']:getNetworkStatus() then return end
    
    if exports['cr_core']:takeMoney(localPlayer, cost, false) then
        giveItem(localPlayer, itemId, 1, 1, 100, 0, 0, 0)
        exports['cr_infobox']:addBox("success", "Sikeresen vásároltál egy "..itemName.."-at/et")
    else
        exports['cr_infobox']:addBox("error", "Nincs elég pénzed")
    end
end