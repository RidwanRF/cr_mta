local sx, sy = guiGetScreenSize()
local w, h, w2 = 310, 10, 310
local x, y = sx / 2 - w / 2, sy - h - 90
local waterState = false
local oxigen = getPedOxygenLevel(localPlayer)

function getDetails(component)
    return exports['cr_interface']:getDetails(component)
end

function dxCreateBorder(x,y,w,h, color)
    return exports['cr_core']:linedRectangle(x,y,w,h, tocolor(0,0,0,0), tocolor(0,0,0,200), 1.7)
end

function drawnIcon(x, y, icon)
    dxDrawImage(x - 30/2, y - 30/2, 30, 30, "files/"..icon..".png")
end

function drawnEvent()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,x,y,w,h,sizable,turnable = getDetails("oxygen")
    drawnIcon(x - 18, y + h/2, "water")
    dxDrawRectangle(x, y, w, h, tocolor(0,0,0,180))
    local oxigen = math.min(1000, getPedOxygenLevel(localPlayer))
    local w2 = w
    local w = w * (oxigen / 1000)
    dxDrawRectangle(x,y, w2,h, tocolor(90,90,90,180))
    dxCreateBorder(x, y, w2, h, tocolor(0,0,0,255))
    dxDrawRectangle(x, y, w, h, tocolor(0, 102, 255,180))
end

setTimer(
    function()
        if isElementInWater(localPlayer) then
            if not waterState then
                waterState = true
                addEventHandler("onClientRender", root, drawnEvent, true, "low-5")
            end
        else
            if waterState then
                waterState = false
                removeEventHandler("onClientRender", root, drawnEvent)
            end
        end
    end, 500, 0
)