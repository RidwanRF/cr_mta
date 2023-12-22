local mx, my, mz = -2102.50244, 208.49536, 34
local rx, ry, rz = -2160, 208.49536, 34
local cx, cy, cz = -2102, 208.47462, 122
local dX, dY, dZ = -2054, 208.47462, 119.2

veh = nil

function loadScript()
    makeMarker()
    craneObj = createObject(1381, cx, cy, cz)
    crObj = createObject(1384, dX, dY, dZ, 0, 0, 90)
    removeWorldModel(3872, 200, -2086.93042, 203.92935, 35.09310)
end
addEventHandler("onResourceStart", resourceRoot, loadScript)

function playerAcceptOffer(thePlayer)
    local pveh = getPedOccupiedVehicle(thePlayer)
    veh = pveh
    setElementPosition(pveh, -2102.50244, 208.49536, 34.9)
    setElementFrozen(pveh, true)
    removePedFromVehicle(thePlayer)
    --setElementPosition(thePlayer, rx, ry, rz)
    --destroyElement(cp)
    local newPosition = cp.position
    newPosition.z = newPosition.z - 50
    cp.position = newPosition
    stepOne()
end
addEvent("acceptOffer", true)
addEventHandler("acceptOffer", root, playerAcceptOffer)

function makeMarker()
    cp = createMarker(mx, my, mz, "cylinder", 2)
    cp.alpha = 0
    setElementData(cp, "junkyard", true)
end

function resetMarker()
    local newPosition = cp.position
    newPosition.z = newPosition.z + 50
    cp.position = newPosition
end

mpS = math.random(2, 8) / 10
function changeMultipler(first)
    mpS = math.random(2, 8) / 10
    outputChatBox(exports['cr_core']:getServerSyntax("Zúzda", "info") .. "Az árak megváltoztak!", root, 255, 255, 255, true)
    if not first then
        triggerClientEvent(root, "changeMultipler", root, mpS)
    end
end
changeMultipler(true)
setTimer(changeMultipler, 60 * 60 * 1000, 0)

function requestMultipler(e)
    triggerClientEvent(e, "changeMultipler", e, mpS)
    triggerClientEvent(e, "getData", e, {cp, craneObj, crObj})
end
addEvent("requestMultipler", true)
addEventHandler("requestMultipler", root, requestMultipler)
--setTimer(changeMultipler, 10000, 0)

function stepOne()
    local x, y, z = getElementPosition(craneObj)
    setElementData(craneObj, "startPos", {x, y, z})
    moveObject(craneObj, 15000, -2102, 208.47462, 36.65)
    craneObj.collisions = false
    --craneObj:setData("doing", true)
    veh.collisions = false
    setTimer(function()
        attachElements(veh, craneObj, 0, 0, -2)
        stepTwo()
    end, 17000, 1)
end

function stepTwo()
    moveObject(craneObj, 15000, -2102, 208.47462, 122)
    setTimer(
        function()
            craneObj:setData("startPos", nil)
            attachElements(craneObj, crObj, 0, 48, 4)
            attachElements(veh, crObj, 0, 48, 1)
            moveObject(crObj, 10000, dX, dY, dZ, 0, 0, -50)
            stepThree()
        end, 17000, 1
    )
    --[[
    setTimer(function()
        local x,y,z = getElementPosition(veh)
        outputChatBox(x .. "|" .. y .. "|" .. z)
    end, 20000, 1)]]
end

function stepThree() -- 1973.1378173828|-2635.9921875|78
    setTimer(function()
        veh.collisions = true
        detachElements(veh, crObj)
        detachElements(veh, craneObj)
        setElementFrozen(veh, false)
        stepFour()
    end, 12000, 1)
end

function stepFour()
    setTimer(function()
        --destroyElement(veh)
        --destroyVehicle(veh)
        exports['cr_vehicle']:deleteVehicle(veh:getData("veh >> id"), veh.model)
        stepFive()
    end, 5000, 1)
end

function stepFive()
    attachElements(craneObj, crObj, 0, 48, 4)
    moveObject(crObj, 12000, dX, dY, dZ, 0, 0, 50)
    stepSix()
end

function stepSix()
    setTimer(function()
        detachElements(craneObj, crObj)
        setElementPosition(craneObj, -2102, 208.47462, 122)
        resetMarker()
        veh = nil
    end, 12000, 1)
end

function destroyVehicle(veh)
    destroyElement(veh)
    --Trigger
end

addEventHandler("onResourceStop", resourceRoot,
    function()
        if isElement(veh) then destroyVehicle(veh) end
    end
)
