local objects = {
    --[ID] = true,
    [2412] = 2,
    [1892] = 1.5,
}

local isDeletableItem = {
    --[itemID] = true
    [12] = true,
    [13] = true,
    [14] = true,
    [31] = true,
    [32] = true,
    [41] = true,
    [44] = true,
    [48] = true,
    [49] = true,
    [50] = true,
    [51] = true,
    [52] = true,
    [53] = true,
    [54] = true,
    [55] = true,
    [56] = true,
    [57] = true,
    [58] = true,
    [59] = true,
    [60] = true,
    [61] = true,
    [66] = true,
    [67] = true,
    [68] = true,
    [69] = true,
    [70] = true,
    [71] = true,
}

local cache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("object")) do
            if objects[v.model] then
                local x, y, z = getElementPosition(v) 
                local rot = math.floor(v.rotation.z)
                local vMatrix = Matrix(x,y,z, rot)
                local pos = vMatrix:transformPosition(0, 0, 0)
                
                local obj = createColSphere(pos.x, pos.y, pos.z, tonumber(objects[v.model]) or 0)
                
                cache[obj] = v
            end
        end
    end
)

local lastCheckTick = -500

addEventHandler("onClientColShapeHit", root,
    function(thePlayer, matchingDimension)
        if matchingDimension and thePlayer == localPlayer then 
            --outputChatBox(tostring(cache[source]))
            if cache[source] then
                --outputChatBox("asd")
                local a = 5 * 60
                local now = getTickCount()
                if now <= lastCheckTick + a * 1000 then
                    return
                end
                lastCheckTick = now
                
                local items = getItems(localPlayer, 1)
            
                --outputChatBox(toJSON(items))
                for slot, details in pairs(items) do
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(details)
                    --outputChatBox(itemid)
                    if isDeletableItem[tonumber(itemid)] then
                        --outputChatBox(tonumber(itemid))
                        interactPD()
                        return
                    end
                end
            end
        end
    end
)

local ignores = {
    [1] = true,
    [6] = true,
}

function interactPD()
    --outputChatBox("asd")
    for k,v in pairs(ignores) do
        if exports['cr_faction']:isPlayerInFaction(localPlayer, k) then
            return
        end
    end
        
    for k,v in pairs(getElementsByType("player")) do
        if v.dimension == 0 and v.interior == 0 then
            if v:getData("loggedIn") then
                if exports['cr_faction']:isPlayerInFaction(v, 1) or exports['cr_faction']:isPlayerInFaction(v, 6) then
                    triggerServerEvent("createBlip", localPlayer, localPlayer, v)
                end
            end
        end
    end
end