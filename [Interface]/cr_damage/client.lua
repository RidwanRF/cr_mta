local damageActive = false
local pictureData = {
    [1] = {460, 300},
    [2] = {1400, 616},
    [3] = {742, 643},
    [4] = {894, 894},
    [5] = {688, 554},
    [6] = {600, 400},
    [7] = {1024, 515},
    [8] = {300, 300},
    [9] = {759, 500},
}
local picture = math.random(1,#pictureData)
local posX, posY = 0
local alpha = 255
local sx, sy = guiGetScreenSize()

function drawnFunction()
    dxDrawImage(posX, posY, pictureData[picture][1], pictureData[picture][2], "files/"..picture..".png", 0,0,0, tocolor(255,255,255,alpha))
    if not state then
        dxDrawRectangle(0, 0, sx, sy, tocolor(255,0,0,30))
    end
    alpha = alpha - 4
    if alpha <= 0 then
        removeEventHandler("onClientRender", root, drawnFunction)
        damageActive = false
    end
end

function onDamage(attacker, weapon, bodypart, loss)
    if not damageActive then
        damageActive = true
        addEventHandler("onClientRender", root, drawnFunction, true, "low-5")
        picture = math.random(1, #pictureData)
        alpha = 255
        posX = sx / math.random(2,3) - pictureData[picture][1] / math.random(2,3)
        posY = sy / math.random(2,3) - pictureData[picture][2] / math.random(2,3)
    else
        alpha = 255
        --posX = sx / math.random(2,3) - pictureData[picture][1] / math.random(2,3)
        --posY = sy / math.random(2,3) - pictureData[picture][2] / math.random(2,3)
    end
end
addEvent("onDamage", true)
addEventHandler("onDamage", root, onDamage)
addEventHandler("onClientPlayerDamage", localPlayer, onDamage)

local health = getElementHealth(localPlayer)
local state = false
local minHP = 40

setTimer(
    function()
        health = getElementHealth(localPlayer)
        if health <= minHP then
            if not state then
                state = true
                addEventHandler("onClientRender", root, drawnLowHP, true, "low-5")
            end
        else
            if state then
                state = false
                removeEventHandler("onClientRender", root, drawnLowHP)
            end
        end
    end, 400, 0
)

function drawnLowHP()
    if not getElementData(localPlayer, "inDeath") then
        local alpha = 255 * (1 - (health / minHP))
        dxDrawImage(0,0,sx,sy,"files/damage.png", 0,0,0, tocolor(255,255,255,alpha))
        if health < 20 then
            local alpha = 255 * (1 - (health / 20))
            dxDrawRectangle(0,0,sx,sy,tocolor(255,20,20,alpha))
        end
    end
end