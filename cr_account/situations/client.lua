local eCache = {
    ["vehicle"] = {},
    ["ped"] = {},
}

local timers = {}

function changeCameraPos(id, oid2, id2, time)
    local x0, y0, z0, x1, y1, z1 = unpack(cameraPos[id][oid2])
    --outputChatBox(x0 .. " " .. y0 .. " " .. z0)
    local x2, y2, z2, x3, y3, z3 = unpack(cameraPos[id][id2])
    --outputChatBox(x2 .. " " .. y2 .. " " .. z2)
    --outputChatBox(time)
    smoothMoveCamera(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, time)
    setTimer(
        function()
            setCameraMatrix(x2, y2, z2, x3, y3, z3)
        end, time, 1
    )
end

function createSituation(id, refresh, id2)
	farclip = getFarClipDistance( )
	setFarClipDistance(125)
    local id = id or 1
    local id2 = id2 or 1
    setCameraMatrix(unpack(cameraPos[id][id2]))
    setTimer(
        function()
            if id == 1 then
                for k,v in pairs(vehicles[id]) do
                    local x,y,z,rot = unpack(v)
                    local model, pedModel = valiableVehicles[math.random(1,#valiableVehicles)], valiableSkins[math.random(1,#valiableSkins)]
                    local veh = createVehicle(model, x,y,z)
                    local ped = createPed(pedModel, 0,0,0)
                    setElementFrozen(ped, true)
                    warpPedIntoVehicle(ped, veh)
                    setElementRotation(veh, 0, 0, rot)
                    setElementDimension(veh, getElementDimension(localPlayer))
                    setElementDimension(ped, getElementDimension(localPlayer))
                    eCache["vehicle"][veh] = true
                    eCache["vehicle"][ped] = true
                    setTimer(setPedControlState, 300, 1, ped, "accelerate", true)
                end

                timers["refilTimer"] = setTimer(
                    function()
                        for k,v in pairs(eCache["vehicle"]) do
                            if isElement(k) then
                                destroyElement(k)
                            end
                            eCache["vehicle"][k] = nil
                        end

                        for k,v in pairs(vehicles[id]) do
                            local x,y,z,rot = unpack(v)
                            local model, pedModel = valiableVehicles[math.random(1,#valiableVehicles)], valiableSkins[math.random(1,#valiableSkins)]
                            local veh = createVehicle(model, x,y,z)
                            local ped = createPed(pedModel, 0,0,0)
                            setElementFrozen(ped, true)
                            warpPedIntoVehicle(ped, veh)
                            setElementRotation(veh, 0, 0, rot)
                            setElementDimension(veh, getElementDimension(localPlayer))
                            setElementDimension(ped, getElementDimension(localPlayer))
                            eCache["vehicle"][veh] = true
                            eCache["vehicle"][ped] = true
                            setTimer(setPedControlState, 300, 1, ped, "accelerate", true)
                        end
                    end, 10000, 0
                )

                for k,v in pairs(peds[id]) do
                    local x,y,z,rot,walk,animDetails = unpack(v)
                    local pedModel = valiableSkins[math.random(1,#valiableSkins)]
                    local ped = createPed(pedModel, x,y,z)
                    setElementDimension(ped, getElementDimension(localPlayer))
                    setElementRotation(ped, 0, 0, rot)
                    if not walk then
                        setElementFrozen(ped, true)
                        setPedAnimation(ped, unpack(animDetails))
                    else
                        setTimer(setPedControlState, 300, 1, ped, "forwards", true)
                        setTimer(setPedControlState, 300, 1, ped, "walk", true)
                    end
                    eCache["ped"][ped] = true
                end

                timers["refilTimer2"] = setTimer(
                    function()
                        for k,v in pairs(eCache["ped"]) do
                            if getPedControlState(k, "forwards") then
                                destroyElement(k)
                                eCache["ped"][k] = nil
                            end
                        end

                        for k,v in pairs(peds[id]) do
                            local x,y,z,rot,walk,animDetails = unpack(v)
                            local pedModel = valiableSkins[math.random(1,#valiableSkins)]
                            if walk then
                                local ped = createPed(pedModel, x,y,z)
                                setElementDimension(ped, getElementDimension(localPlayer))
                                setElementRotation(ped, 0, 0, rot)
                                setTimer(setPedControlState, 300, 1, ped, "forwards", true)
                                setTimer(setPedControlState, 300, 1, ped, "walk", true)
                                eCache["ped"][ped] = true
                            end
                        end
                    end, 30000, 0
                )
            end
        end, 500, 1
    )
end

function stopSituations()
    if isTimer(timers["refilTimer"]) then
        killTimer(timers["refilTimer"])
    end
    if isTimer(timers["refilTimer2"]) then
        killTimer(timers["refilTimer2"])
    end
    for k,v in pairs(eCache) do
        for k2, v2 in pairs(eCache[k]) do
            if isElement(k2) then
                k2:destroy()
                eCache[k][k2] = nil
            end
        end
    end
end

--
local sm = {}
sm.moov = 0
sm.object1, sm.object2 = nil, nil

local function camRender()
	local x1, y1, z1 = getElementPosition(sm.object1)
	local x2, y2, z2 = getElementPosition(sm.object2)
	setCameraMatrix(x1, y1, z1, x2, y2, z2)
end

local function removeCamHandler()
	if (sm.moov == 1) then
		sm.moov = 0
		removeEventHandler("onClientPreRender", root, camRender)
	end
end

function stopSmoothMoveCamera()
	if (sm.moov == 1) then
		if (isTimer(sm.timer1)) then killTimer(sm.timer1) end
		if (isTimer(sm.timer2)) then killTimer(sm.timer2) end
		if (isTimer(sm.timer3)) then killTimer(sm.timer3) end
		if (isElement(sm.object1)) then destroyElement(sm.object1) end
		if (isElement(sm.object2)) then destroyElement(sm.object2) end
		removeCamHandler()
		sm.moov = 0
	end
end

function smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, time, easing)
	if (sm.moov == 1) then return false end
	sm.object1 = createObject(1337, x1, y1, z1)
	sm.object2 = createObject(1337, x1t, y1t, z1t)
	setElementAlpha(sm.object1, 0)
	setElementAlpha(sm.object2, 0)
    setElementCollisionsEnabled(sm.object1, false)
    setElementCollisionsEnabled(sm.object2, false)
	setObjectScale(sm.object1, 0.01)
	setObjectScale(sm.object2, 0.01)
	moveObject(sm.object1, time, x2, y2, z2, 0, 0, 0, (easing and easing or "InOutQuad"))
	moveObject(sm.object2, time, x2t, y2t, z2t, 0, 0, 0, (easing and easing or "InOutQuad"))
	
	addEventHandler("onClientPreRender", root, camRender, true, "low")
	sm.moov = 1
	sm.timer1 = setTimer(removeCamHandler, time, 1)
	sm.timer2 = setTimer(destroyElement, time, 1, sm.object1)
	sm.timer3 = setTimer(destroyElement, time, 1, sm.object2)
	
	return true
end