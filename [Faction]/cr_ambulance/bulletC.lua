local data
local element
local gData
local selected
local anim

function syncBullet(attacker, weapon, bodypart)
    if attacker and isElement(attacker) and attacker.type == "player" and tonumber(weapon) then
        if getPedTotalAmmo(attacker) > 1 then
            local t = attacker:getData("weaponDatas") or {0,0,0}
            if t and t[2] and t[11] then
                local id = t[2]
                local weaponID = utf8.sub(md5(id), 1, 12)
                local bulletsInBody = localPlayer:getData("bulletsInBody") or {}
                local bulletID 
                if t[11] and t[11][2] and t[11][2][2] then
                    bulletID = t[11][2][2] -- YEa bitch
                else
                    bulletID = "Ismeretlen"
                end

                table.insert(bulletsInBody, 1, {bodypart, weapon, weaponID, bulletID})
                localPlayer:setData("bulletsInBody", bulletsInBody)
            end
        end
    end
end
addEventHandler("onClientPlayerDamage", localPlayer, syncBullet)

function resetBullets()
    --localPlayer:setData("bulletsInBody", {})
end
addEventHandler("onClientPlayerSpawn", localPlayer, resetBullets)

local e = localPlayer:getData("parent") or localPlayer:getData("clone") or e
if isElement(e) then
    local p = e:getData("syncedBulletsBy")
    e:setData("syncedBulletsBy", nil)
    if isElement(p) then
        p:setData("syncedBulletsBy", nil)
    end
end

function getBullets(e)
    if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
        --outputChatBox("asd")
        if not localPlayer:getData("syncedBulletsBy") then
            --outputChatBox("asd2")
            if not e:getData("syncedBulletsBy") then
                local parent = e:getData("parent") or e:getData("clone") or e
                local data = e:getData("bulletsInBody")
                --outputChatBox(#data)
                if data and #data >= 1 then
                    --outputChatBox("asd3")
                    exports['cr_chat']:createMessage(localPlayer, "átvizsgálja egy hulla testét ("..exports['cr_admin']:getAdminName(parent)..")", 1)
                    gData = data
                    element = e
                    e:setData("syncedBulletsBy", localPlayer)
                    localPlayer:setData("syncedBulletsBy", e)
                    bindKey("backspace", "down", closeBulletsPanel)
                    selected = nil
                    anim = false
                    if not isRenderBullets then
                        addEventHandler("onClientRender", root, drawnBulletsPanel, true, "low-5")
                        isRenderBullets = true
                    end
                end
            else
                exports['cr_infobox']:addBox("error", "Valaki már vizsgálja a hulla testét!")
            end
        end
    end
end

function closeBulletsPanel()
    localPlayer:setData("syncedBulletsBy", nil)
    if isElement(element) then
        element:setData("syncedBulletsBy", nil)
    end
    unbindKey("backspace", "down", closeBulletsPanel)
    if isRenderBullets then
        removeEventHandler("onClientRender", root, drawnBulletsPanel)
        isRenderBullets = nil
    end
end

addEventHandler("onClientElementDataChange", root, 
    function(dName)
        if dName == "syncedBulletsBy" then
            local value = localPlayer:getData("syncedBulletsBy")
            if value == source then
                local value2 = source:getData("syncedBulletsBy")
                if localPlayer ~= value2 then
                    --exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    localPlayer:setData("syncedBulletsBy", nil)
                    closeBulletsPanel()
                    --source:setData("syncedBulletsBy", nil)
                end
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        if source:getData("syncedBulletsBy") then -- Akit gyógyítanak
            if localPlayer:getData("syncedBulletsBy") then
                local value = source:getData("syncedBulletsBy")
                local value2 = localPlayer:getData("syncedBulletsBy")
                if value == localPlayer and source == value2 then
                    --exports['cr_minigame']:stopMinigame(localPlayer, 2, true)
                    localPlayer:setData("isRespawningE", nil)
                    source:setData("isRespawningE", nil)
                    closeBulletsPanel()
                end
            end
        end
    end
)

local hunName = {
    [3] = "törzsben",
    [4] = "seggben",
    [5] = "bal kézben",
    [6] = "jobb kézben",
    [7] = "bal lábban",
    [8] = "jobb lábban",
    [9] = "fejben",
}

function getBullet(k)
    --local bulletsInBody = gData
    selected = nil
    anim = false
    local weaponID = gData[k][3]
    local bulletID = gData[k][4]
    exports['cr_inventory']:giveItem(localPlayer, 131, {weaponID, bulletID})
    table.remove(gData, k)
    element:setData("bulletsInBody", gData)
    exports['cr_chat']:createMessage(localPlayer, "kioperál egy használt lőszert "..exports['cr_admin']:getAdminName(localPlayer).." testéből", 1)
    --Giveitem
    closeBulletsPanel()
end

local sx, sy = guiGetScreenSize()
function drawnBulletsPanel()
    if not isElement(element) or getDistanceBetweenPoints3D(element.position, localPlayer.position) >= 3 then
        --outputChatBox("asd")
        closeBulletsPanel()
        return
    end
    local font = exports['cr_fonts']:getFont("Roboto", 11)
    local fontHeight = dxGetFontHeight(1, font)
    local y = 30 + ((fontHeight + 5) * #gData)
    local a,b,c,d = 300, 280, dxGetTextWidth("Kivétel", 1, font) + 10, fontHeight + 4
    dxDrawRectangle(sx/2 - a/2, sy/2 - y/2, a, y, tocolor(0,0,0,120))
    dxDrawLine(sx/2 - b/2, sy/2 - y/2 + 15, sx/2 + b/2, sy/2 - y/2 + 15)
    dxDrawText("Golyók kioperálása", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    --dxDrawText("Testrész", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    --dxDrawText("Testrész", sx/2, sy/2 - y/2, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    --dxDrawText("Interakció", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    selected = nil
    
    local startY = sy/2 - y/2 + 30
    for k = 1, #gData do
        local v = gData[k]
        local bodypart, weapon, weaponID, bulletID = v[1], v[2], v[3], v[4]
        --local c = dxGetTextWidth("Golyó a "..hunName[bodypart], 1, font)
        if exports['cr_core']:isInSlot(sx/2 + b/2 - c, startY - d/2, c, d) then
            dxDrawText("Golyó a "..hunName[bodypart], sx/2 - b/2, startY, sx/2 + b/2, startY, tocolor(255,255,255,255), 1, font, "left", "center")
            dxDrawRectangle(sx/2 + b/2 - c, startY - d/2, c, d, tocolor(0,0,0,100))
            dxDrawText("Kivétel", sx/2 + b/2 - c, startY - d/2, sx/2 + b/2 - c + c, startY - d/2 + d, tocolor(255,255,255,255), 1, font, "center", "center")
            selected = k
            
            if anim then
                local now = getTickCount()
                local elapsedTime = now - startTime
                local duration = endTime - startTime
                local progress = elapsedTime / duration

                local a = interpolateBetween ( 
                    0, 0, 0,
                    c, 0, 0,
                    progress, "Linear"
                )

                if a >= c then
                    getBullet(k)
                    --closeBulletsPanel()
                    return
                end
                
                dxDrawRectangle(sx/2 + b/2 - c, startY - d/2, a, d, tocolor(87,255,87,100))
            end
        else
            dxDrawText("Golyó a "..hunName[bodypart], sx/2 - b/2, startY, sx/2 + b/2, startY, tocolor(255,255,255,180), 1, font, "left", "center")
            dxDrawRectangle(sx/2 + b/2 - c, startY - d/2, c, d, tocolor(0,0,0,100))
            dxDrawText("Kivétel", sx/2 + b/2 - c, startY - d/2, sx/2 + b/2 - c + c, startY - d/2 + d, tocolor(255,255,255,180), 1, font, "center", "center")
        end
        startY = startY + fontHeight + 5
    end
    --dxDrawText("Golyók kioperálása", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    --dxDrawText("Golyók kioperálása", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
    --dxDrawText("Golyók kioperálása", sx/2, sy/2 - y/2 + 15, sx/2, sy/2 - y/2, tocolor(255,255,255,255), 1, font, "center", "center")
end

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" then
            if selected then
                local v = gData[selected]
                local bodypart, weapon, weaponID, bulletID = v[1], v[2], v[3], v[4]
                
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