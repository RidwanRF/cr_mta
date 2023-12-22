local state = false

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName)
        local value = getElementData(source, dName)
        if dName == "inDeath" then
            if value then
                if state then
                    setElementData(localPlayer, "keysDenied", false)
                    removeEventHandler("onClientRender", root, drawnHandbrake)
                    setCursorAlpha(255)
                    showCursor(false)
                    state = false
                end
            end
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh == source then
                if state then
                    removeEventHandler("onClientRender", root, drawnHandbrake)
                    setElementData(localPlayer, "keysDenied", false)
                    setCursorAlpha(255)
                    showCursor(false)
                    state = false
                end
            end
        end
    end
)

function toggleHandBrake()
    --if isTimer(spamTimer) then return end
    --spamTimer = setTimer(function() end, 500, 1)
    if isChatBoxInputActive() then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getVehicleType(veh) == "BMX" then return end
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            local speed = getElementSpeed(veh)
            if not state and speed < 2 then
                sourceVeh = veh
                local enabled,x,y,w,h,sizable,turnable = exports['cr_interface']:getDetails("handbrake")
                setCursorPosition(x + w/2, y + h/2)
                setCursorAlpha(0)
                addEventHandler("onClientRender", root, drawnHandbrake, true, "low-5")
                setElementData(localPlayer, "keysDenied", true)
                showCursor(true)
                state = true
            end
        end
    end
end

function toggleHandBrake2()
    --if isTimer(spamTimer) then return end
    --spamTimer = setTimer(function() end, 500, 1)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
            if state then
                removeEventHandler("onClientRender", root, drawnHandbrake)
                setElementData(localPlayer, "keysDenied", false)
                setCursorAlpha(255)
                showCursor(false)
                state = false
            end
        end
    end
end

addEventHandler("onClientPlayerVehicleExit", root,
    function(veh, seat)
        if source == localPlayer then
            if state then
                removeEventHandler("onClientRender", root, drawnHandbrake)
                setElementData(localPlayer, "keysDenied", false)
                setCursorAlpha(255)
                showCursor(false)
                state = false
            end
        end
    end
)

bindKey("lalt", "down", toggleHandBrake)
bindKey("lalt", "up", toggleHandBrake2)

function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 100
        else
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 1.8 * 100
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

local sx, sy = guiGetScreenSize()
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

function drawnHandbrake()
    local enabled,x,y,w,h,sizable,turnable = exports['cr_interface']:getDetails("handbrake")
    local w, h = 64, 256
    dxDrawImage(x,y,w,h,"files/handBrakeBG.png", 0,0,0, tocolor(255,255,255,255))
    local cx, cy = cursorX, cursorY 
    --setCursorPosition(x, cy)
    if cy < y + 30 then
        cy = y + 30
    elseif cy > y + h - 6 then
        cy = y + h - 6
    end
    dxDrawImage(x, cy - 16/2, 64, 16, "files/handBrakePointer.png", 0,0,0, tocolor(255,255,255,255))
    if cy <= y + 40 then
        if getElementData(sourceVeh, "veh >> handbrake") then
            setElementData(sourceVeh, "veh >> handbrake", false)
            playSound("files/handbrakeoff.wav")
        end
    elseif cy >= y + h - 30 then
        if not getElementData(sourceVeh, "veh >> handbrake") then
            setElementData(sourceVeh, "veh >> handbrake", true)
            playSound("files/handbrake.wav")
        end
    end
end