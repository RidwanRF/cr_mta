local positions = {
    --{Vector(x,y,z),Vector(dim,int)},
    {Vector3(1923.9403076172, -1800.5081787109, 13), Vector3(0,0)},
}

local elementCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(positions) do
            local pos, pos2 = unpack(v)
            local mark = Marker(pos, "checkpoint", 2, 255, 0, 0)
            mark.interior = pos2.y
            mark.dimension = pos2.x
            elementCache[mark] = true
        end
    end
)

addEventHandler("onClientMarkerHit", resourceRoot,
    function(hitPlayer, matchingDimension)
        if elementCache[source] then
            if hitPlayer == localPlayer and matchingDimension and doingState then
                if gVeh and isElement(gVeh) and gVeh:getData(doingState.."->parent") and isElement(gVeh:getData(doingState.."->parent")) then
                    if doingState then
                        local element = gVeh:getData(doingState.."->parent")
                        local k = doingState
                        --local k = gVeh:getData("hide")
                        if k then
                            gVeh:setData(k.."->hide", 1)
                            triggerServerEvent("destroyClonedVehicle", localPlayer, localPlayer, gVeh, k)
                            onControls()
                            setElementData(localPlayer, "forceAnimation", {"", ""})
                            triggerServerEvent("removeAnimation", localPlayer, localPlayer)
                            doingState = nil
                            gVeh:setData(k.."->doing", false)
                            gVeh:setData(k.."->parent", nil)
                            gVeh = nil
                            
                            local syntax = exports['cr_core']:getServerSyntax("Mechanic", "success")
                            outputChatBox(syntax .. "Sikeresen töröltél 1 komponenst!",255,255,255,true)
                        end
                    end
                end
            end
        end
    end
)