local bones = {
    --["BoneName"] = {boneID (A ped bone idje amihez jön a szöveg), az elementdatában elfoglalt sorrend idje (Ha külön elementdata akkor elementdatanév)}
    ["Bal kéz"] = {34, 2},
    ["Jobb kéz"] = {24, 3},
    ["Bal láb"] = {43, 4},
    ["Jobb láb"] = {53, 5},
}
local element
local brokenParts = {}

function syncPlayerBrokenParts(e)
    
    --if exports['cr_inventory']:hasItem(localPlayer, 130) -- // Megvizsgáló
    
    if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then

        local nearObject
        for k,v in pairs(getElementsByType("object")) do
            if getDistanceBetweenPoints3D(v.position, e.position) <= 5 then
                if v.model == 3383 then
                    nearObject = true
                    break
                end    
            end
        end

        --outputChatBox(tostring(nearObject))

        local hasItem, slot, data = exports['cr_inventory']:hasItem(localPlayer, 130)
        --outputChatBox(tostring(hasItem))
        if nearObject or hasItem then
            --Object közelében vagy item van neki. Ha elkezdi megjavítani 1 testrészét akkor instant desync és újra kell syncelnie.

            --Ha 1 distancen kívülre kerül ne drawnoljon, desyncelje
            --outputChatBox("asd")
            for k,v in pairs(brokenParts) do
                return
            end

            element = e
            brokenParts = {}
            local bone = e:getData("char >> bone") or {true, true, true, true, true}
            local valid = false
            for i = 1, 5 do
                if not bone[i] then
                    valid = true
                    break
                end
            end
            anim = false
            selected = nil
            --outputChatBox(tostring(valid))
            if valid then
                brokenParts.bone = bone
                brokenParts.e = e
                for k,v in pairs(bones) do
                    local boneId, sortID = v[1], v[2]
                    --outputChatBox(sortID)
                    if not bone[sortID] then
                        --outputChatBox(sortID..">true")
                        brokenParts[k] = true
                    end
                end    

                exports['cr_chat']:createMessage(localPlayer, "átvizsgálja "..exports['cr_admin']:getAdminName(e).." testrészeit", 1)

                if not renderingBrokenParts then
                    addEventHandler("onClientRender", root, renderBrokenParts, true, "low-5")
                    renderingBrokenParts = true
                end
            end
        end
    end
end

function desyncBrokenParts()
    brokenParts = {}
    removeEventHandler("onClientRender", root, renderBrokenParts, true, "low-5")
    renderingBrokenParts = nil
end
addCommandHandler("syncme", function() syncPlayerBrokenParts(localPlayer) end)

function fixBrokenPart(k)
    local v = bones[k]
    local boneID, dataID = v[1], v[2]
    
    local bone = element:getData("char >> bone") or {true, true, true, true, true}
    bone[dataID] = true
    element:setData("char >> bone", bone)
    
    exports['cr_chat']:createMessage(localPlayer, "meggyógyítja "..exports['cr_admin']:getAdminName(element).." "..string.lower(k).."-ét(át)", 1)
end

function renderBrokenParts()
    if getDistanceBetweenPoints3D(localPlayer.position, element.position) >= 5 then
        desyncBrokenParts()
        return
    end
    font = exports['cr_fonts']:getFont("Roboto", 11)
    selected = nil
    for k,v in pairs(brokenParts) do
        local v = bones[k]
        if v then
            local boneID, dataID = v[1], v[2]

            local name = k
            local boneX, boneY, boneZ = getPedBonePosition(element, boneID)
            local sx, sy = getScreenFromWorldPosition(boneX, boneY, boneZ)
            local text = name

            if sx and sy then
                local width = dxGetTextWidth(text, 1, font, true) + 20
                local height = dxGetFontHeight(1, font) + 10
                dxDrawRectangle(sx - width/2, sy - height/2, width, height, tocolor(0,0,0,180))
                if isInSlot(sx - width/2, sy - height/2, width, height) then
                    dxDrawText(text, sx - width/2, sy - height/2, sx + width/2, sy + height/2, tocolor(255,255,255,255),1, font, "center", "center", 
                    false, false, false, true)
                    selected = k
                    
                    if anim then
                        local now = getTickCount()
                        local elapsedTime = now - startTime
                        local duration = endTime - startTime
                        local progress = elapsedTime / duration
                        
                        local a = interpolateBetween ( 
                            0, 0, 0,
                            width, 0, 0,
                            progress, "Linear"
                        )
                        
                        if a >= width then
                            desyncBrokenParts()
                            fixBrokenPart(k)
                            return
                        end
                        
                        dxDrawRectangle(sx - width/2, sy - height/2, a, height, tocolor(87,255,87,180))
                    end
                else
                    dxDrawText(text, sx - width/2, sy - height/2, sx + width/2, sy + height/2, tocolor(255,255,255,180),1, font, "center", "center", 
                    false, false, false, true)
                end
            end
        end
    end
end

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" then
            if selected then
                local v = bones[selected]
                local boneID, dataID = v[1], v[2]
                
                startTime = getTickCount()
                endTime = startTime + 1000
                if s == "down" then
                    anim = true
                else
                    anim = false
                end
            end
        end
    end
)

localPlayer:setData("isRespawning", true)

function doRespawn(e)
    if not e.headless then
        local has, slot, data = exports['cr_inventory']:hasItem(localPlayer, 73) 
        if has then -- eü doboz
            if not e:getData("isRespawning") or e:getData("isRespawning") and not e:getData("isRespawningE") and exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                e:setData("isRespawning", true)
                e:setData("isRespawningE", localPlayer)
                localPlayer:setData("isRespawningE", e)
                exports['cr_chat']:createMessage(localPlayer, "elkezd újraéleszteni egy embert ("..exports['cr_admin']:getAdminName(e:getData("parent"))..")", 1)
                setPedDucked(localPlayer, true)
                local type = 1 -- Player, EÜ Doboz
                if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                    exports['cr_minigame']:createMinigame(localPlayer, 2, "death > respawn", {max=60, needed=20, speed=800, speedMultipler=4})
                else
                    exports['cr_minigame']:createMinigame(localPlayer, 2, "death > respawn", {max=60, needed=50, speed=800, speedMultipler=4})
                end
                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 1)
            else
                exports['cr_infobox']:addBox("error", "Már valaki elkezdte a felélesztést!")
            end
        else
            exports['cr_infobox']:addBox("error", "Nincs nálad elsősegély doboz!")
        end
    else
        exports['cr_infobox']:addBox("error", "Rajta már nem segíthetsz!")
    end
end

addEventHandler("onClientElementDataChange", root, 
    function(dName)
        if dName == "isRespawningE" then
            if localPlayer:getData("isRespawningE") then
                local value = localPlayer:getData("isRespawningE")
                if value == source then
                    local value2 = source:getData("isRespawningE")
                    if localPlayer ~= value2 then
                        exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                        localPlayer:setData("isRespawningE", nil)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        if source:getData("isRespawning") and source:getData("isRespawningE") then -- Akit gyógyítanak
            if localPlayer:getData("isRespawningE") then
                local value = source:getData("isRespawningE")
                local value2 = localPlayer:getData("isRespawningE")
                if value == localPlayer and source == value2 then
                    exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    localPlayer:setData("isRespawningE", nil)
                end
            end
        elseif source:getData("isRespawningE") and not source:getData("parent") and not source:getData("clone") then -- Aki gyógyít
            if localPlayer:getData("isRespawning") and localPlayer:getData("isRespawningE") then
                local value = source:getData("isRespawningE")
                local value2 = localPlayer:getData("isRespawningE")
                if value == localPlayer and source == value2 then
                    --exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    --localPlayer:setData("isRespawning", nil)
                    localPlayer:setData("isRespawningE", nil)--nem mert ezzel fognak szórakozni, hogy ők kilépnek és újra :D
                end
            end
        end
    end
)

addEvent("SuccessMinigame", true)
addEventHandler("SuccessMinigame", localPlayer,
    function()
        local e = localPlayer:getData("isRespawningE") 
        --outputChatBox("asd")
        if e then
            localPlayer:setData("isRespawningE", nil)
            exports['cr_chat']:createMessage(localPlayer, "újraélesztett egy embert ("..exports['cr_admin']:getAdminName(e:getData("parent"))..")", 1)
            local clone = getElementData(e, "clone") or e
            local x,y,z = getElementPosition(clone)
            clone:setData("isRespawningE", nil)
            clone:setData("isRespawning", nil)
            triggerServerEvent("goToMedical", localPlayer, e:getData("parent"), 2000, x,y,z)
        end
    end
)

addEvent("FailedMinigame", true)
addEventHandler("FailedMinigame", localPlayer,
    function()
        local e = localPlayer:getData("isRespawningE") 
        --outputChatBox("asd2")
        if e then
            localPlayer:setData("isRespawningE", nil)
            exports['cr_chat']:createMessage(localPlayer, "elrontotta egy ember újraélesztését ("..exports['cr_admin']:getAdminName(e:getData("parent"))..")", 1)
            local clone = getElementData(e, "clone") or e
            local x,y,z = getElementPosition(clone)
            clone:setData("isRespawningE", nil)
            --clone:setData("isRespawning", nil)
            --triggerServerEvent("goToMedical", localPlayer, e, 2000, x,y,z)
        end
    end
)