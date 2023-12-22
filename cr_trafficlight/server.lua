local lightCache = {}

function trafficlight_sendTicket(element)
    local rand = math.random(1,2)
    if rand == 1 then
	   exports['cr_faction_scripts']:createTicket(element, "Tilos jelzésen való áthaladás", 35, getRealTime()["timestamp"] + (7 * 24 * 60 * 60))
    end
end

function tralightCheck(playerElement, vehicleElement, objRot1)
--    outputChatBox("ESD1")
	if playerElement and getElementType(playerElement) == "player" then
        local vehicleType = getVehicleType(vehicleElement)
--        outputChatBox("ESD2")
        if vehicleType == "Automobile" or vehicleType == "Bike" or vehicleType == "Monster Truck" or vehicleType == "Quad" then
            --local objectElement = lightCache[colElement]
            local _, _, vehRot = getElementRotation(vehicleElement)
--            local _, _, objRot = getElementRotation(objectElement)
            local vehRot1 = getRoundedRotation(vehRot)
--            local objRot1 = getRoundedRotation(objRot)
            --outputChatBox("ESD3: "..vehRot1..", "..objRot1)
            if objRot1 == vehRot1 or not objRot1 or not vehRot1 then
                local lightState = getTrafficLightState()
                if objRot1 == 90 or objRot1 == 270 then
                    if lightState == 0 or lightState == 1 or lightState == 2 then
                        trafficlight_sendTicket(playerElement)
                    end
                elseif objRot1 == 0 or objRot1 == 180 then
                    if lightState == 4 or lightState == 3 or lightState == 2 then
                        trafficlight_sendTicket(playerElement)
                    end
                end
            end
        end
	end
end
addEvent("tralightCheck", true)
addEventHandler("tralightCheck", root, tralightCheck)