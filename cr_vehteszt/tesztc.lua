if fileExists("tesztc.lua") then
	fileDelete("tesztc.lua")
end

local componentTable ={
    [415] = true,
    [506] = true,
	[502] = true,
	[466] = true,
	[445] = true,
	[439] = true,
	[451] = true,
	[480] = true,
	[580] = true,
	[585] = true,
	[458] = true,
    [402] = true,
    [602] = true,
    [405] = true,
    [416] = true,
	[516] = true,
}

local defpos = 0

function kmhForgas()
    local theVeh = getPedOccupiedVehicle(localPlayer)
    if theVeh then
        if componentTable[getElementModel(theVeh)] then
            local theVeh = getPedOccupiedVehicle(localPlayer)
            local rx, ry, rz = getVehicleComponentRotation(theVeh, "wheel_lf_dummy")
			setVehicleComponentRotation(theVeh, "steering_dummy", 0, -rz+180.00001525879, 0)			
			setVehicleComponentRotation(theVeh, "movsteer_0.5", 0, -rz+180.00001525879, 0)
            setVehicleComponentRotation(theVeh, "movsteer_1.0", 0, -rz+180.00001525879, 0)
            setVehicleComponentRotation(theVeh, "movsteer_2.0", 0, -rz+180.00001525879, 0)
			setVehicleComponentRotation(theVeh, "steering_ok", 0, -rz+180.00001525879, 0)
			setVehicleComponentRotation(theVeh, "steering", 0, -rz+180.00001525879, 0)			
            local rpm = getVehicleRPM(theVeh)
            setVehicleComponentRotation(theVeh, "tahook", 0, rpm/35, 0)
            local spd = getElementSpeed(theVeh, "kmh")
            setVehicleComponentRotation(theVeh, "speedook", 0, spd, 0)
            setVehicleComponentRotation(theVeh, "dvorright", 0, -defpos, 0)
            setVehicleComponentRotation(theVeh, "dvorleft", 0, -defpos, 0)
            if getElementModel(theVeh) == 415 then
                local sX, sY, sZ = getVehicleComponentPosition(theVeh, "movspoiler_16.0_2000")
                if spd >= 120 then
                    if sZ < 1.2 then
                        setVehicleComponentPosition(theVeh, "movspoiler_16.0_2000", sX, sY, sZ+0.005)
                    end
                elseif spd < 120 then
                    if sZ > 0.87 then
                        setVehicleComponentPosition(theVeh, "movspoiler_16.0_2000", sX, sY, sZ-0.01)
                    end
                end
            elseif getElementModel(theVeh) == 506 then
                local sX, sY, sZ = getVehicleComponentPosition(theVeh, "movspoiler")
                if spd >= 120 then
                    if sZ < 1.2 then
                        setVehicleComponentPosition(theVeh, "movspoiler", sX, sY, sZ+0.005)
                    end
                elseif spd < 120 then
                    if sZ > 1 then
                        setVehicleComponentPosition(theVeh, "movspoiler", sX, sY, sZ-0.01)
                    end
                end
            elseif getElementModel(theVeh) == 502 then
                local sX, sY, sZ = getVehicleComponentPosition(theVeh, "movspoiler_25_1300")
                if spd >= 120 then
                    if sZ < 0.6 then
                        setVehicleComponentPosition(theVeh, "movspoiler_25_1300", sX, sY, sZ+0.005)
                    end
                elseif spd < 120 then
                    if sZ > 0.456 then
                        setVehicleComponentPosition(theVeh, "movspoiler_25_1300", sX, sY, sZ-0.01)
                    end
                end            
			end
        end
    end
end
addEventHandler("onClientRender", root, kmhForgas)

function getElementSpeed(element, unit)
    if (unit == nil) then
        unit = 0
    end
    if (isElement(element)) then
        local x, y, z = getElementVelocity(element)

        if (unit == "mph" or unit == 1 or unit == '1') then
            return math.floor((x^2 + y^2 + z^2) ^ 0.5 * 100)
        else
            return math.floor((x^2 + y^2 + z^2) ^ 0.5 * 100 * 1.609344)
        end
    else
        return false
    end
end

function getVehicleRPM(vehicle)
local vehicleRPM = 0
    if (vehicle) then
        if (getVehicleEngineState(vehicle) == true) then
            if getVehicleCurrentGear(vehicle) > 0 then
                vehicleRPM = math.floor(((getElementSpeed(vehicle, "kmh") / getVehicleCurrentGear(vehicle)) * 180) + 0.5)
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            else
                vehicleRPM = math.floor((getElementSpeed(vehicle, "kmh") * 180) + 0.5)
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            end
        else
            vehicleRPM = 0
        end
        return tonumber(vehicleRPM)
    else
        return 0
    end
end