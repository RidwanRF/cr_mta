local spamTimer
local oldMessage = "StayMTA"
local maxLength = 120
local bubbleTimer = nil

local emojis = {
    ["%:%)"] = {"mosolyog.", false},
    ["%:%("] = {"szomorú.", false},
    ["%:d"] = {"nevet.", {"rapping", "laugh_01"}},
    ["xd"] = {"szakad a röhögéstől.", {"rapping", "laugh_01"}},
    ["%;%)"] = {"kacsint.", false},
    ["%:o"] = {"meglepődik.", false},
    ["o%_o"] = {"meglepődik.", false},
    ["o%-o"] = {"meglepődik.", false},
    ["0%-0"] = {"meglepődik.", false},
    ["0%_0"] = {"meglepődik.", false},
    ["%;%("] = {"sírva fakad", {"GRAVEYARD", "mrnF_loop"}},
    ["%:%'%("] = {"sírva fakad", {"GRAVEYARD", "mrnF_loop"}},
}

function createMessage(element, message, mtype)
    if element == localPlayer then
        onClientMessage(localPlayer, message, mtype)
    end
end
addEvent("createMessage", true)
addEventHandler("createMessage", root, createMessage)

function removeHex(text, digits)
    assert(type(text) == "string", "Bad argument 1 @ removeHex [String expected, got " .. tostring(text) .. "]")
    assert(digits == nil or (type(digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got " .. tostring(digits) .. "]")
    return string.gsub(text, "#" .. (digits and string.rep("%x", digits) or "%x+"), "")
end

function onClientMessage(element, message, mtype)
    if not getElementData(element, "loggedIn") then return end
    if element ~= localPlayer then return end
    if isTimer(spamTimer) then return end
    message = removeHex(message, 6)
    --[[
    if oldMessage == message then 
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax .. "Ne ismételd önmagadat! (Ne írd 2x ugyan azt a szöveget egymás után)", 255,255,255,true)
        return
    end
    ]]
    if getElementData(localPlayer, "char->afk") then
        setElementData(localPlayer, "char->afk", false)
    end
    
    if getElementData(localPlayer, "char >> tazed") then
        return
    end
    oldMessage = message
    if mtype ~= "ooc" then
        if isPedDead(localPlayer) then return end
        if getElementHealth(localPlayer) <= 1 then return end
        setElementData(localPlayer, "bubbleOn", true)
        if isTimer(bubbleTimer) then killTimer(bubbleTimer) end
        bubbleTimer = setTimer(
            function()
                setElementData(localPlayer, "bubbleOn", false)
            end, 8.5 * 1000, 1
        )
    end
    if mtype == 0 then
        local veh = getPedOccupiedVehicle(localPlayer)
        local isWindowableVeh = false
        if veh then
            isWindowableVeh = exports['cr_vehicle']:isWindowableVeh(getElementModel(veh)) or true
        end
        --outputChatBox("isWindowableVeh: " .. tostring(isWindowableVeh))
        --outputChatBox("VEH: " .. tostring(isElement(veh)))
        if veh and isWindowableVeh then
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            local name = exports['cr_admin']:getAdminName(element)
            if not getElementData(veh, "veh >> windowState") then
                outputChatBox(name.." mondja: "..message, 255,255,255)
            else
                outputChatBox(name.." mondja (járműben): "..message, 255,255,255)
            end
            
            spamTimer = setTimer(function() end, 300, 1)

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))

                    local veh2 = getPedOccupiedVehicle(v)
                    --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                    if veh2 and veh == veh2 then
                        local r,g,b = 255,255,255
                        if not getElementData(veh, "veh >> windowState") then
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                        else    
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (járműben): "..message, r,g,b)
                        end    
                    elseif distance <= 8 and not getElementData(veh, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                    end
                end
            end
        else
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            local name = exports['cr_admin']:getAdminName(element)

            if not getElementData(localPlayer, "admin >> duty") then
                outputChatBox(name.." mondja: "..message, 255,255,255)
            else
                local color = exports['cr_core']:getServerColor(nil, true)
                outputChatBox(color.."[ADMIN] "..name..": "..message, 255,255,255, true)
            end

            spamTimer = setTimer(function() end, 300, 1)

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    --local x1, y1, z1 = getElementPosition(v)
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                    local veh2 = getPedOccupiedVehicle(v)
                    --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                    local nowVeh = veh
                    if not nowVeh then
                        nowVeh = veh2
                    end
                    if distance <= 8 and not veh2 or distance <= 8 and veh2 and not getElementData(nowVeh, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        elseif distance <= 4 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 6 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 8 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        if not getElementData(localPlayer, "admin >> duty") then
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                        else
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "[ADMIN] "..name..": "..message, 255, 153, 51)
                        end
                    elseif veh2 and distance <= 4 and getElementData(veh2, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        if distance <= 2 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 4 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        
                        if not getElementData(localPlayer, "admin >> duty") then
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                        else
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "[ADMIN] "..name..": "..message, 255, 153, 51)
                        end
                    end
                end
            end
        end
    elseif mtype == 1 then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /me [Cselekvés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" ***"..name.." "..message, 194, 162, 218)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 194, 162, 218
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " ***"..name.." "..message, r,g,b)
                end
            end
        end
    elseif mtype == "do" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /do [Történés]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        message = message:gsub("^%l", string.upper)
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" * "..message.." (("..name.."))", 255, 51, 102)
        
        --outputChatBox("ASd")
        --addBubble(localPlayer, " * "..message.." (("..name.."))", 255, 51, 102)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 255, 51, 102
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " * "..message.." (("..name.."))", r,g,b)
                end
            end
        end    
    elseif mtype == "ame" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /ame [Karaktered vizuális leírása]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end

        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" >> "..name.." "..message, 183, 146, 211)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 183, 146, 211
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " >> "..name.." "..message, r,g,b)
                end
            end
        end
    elseif mtype == "shout" then
        local veh = getPedOccupiedVehicle(localPlayer)
        local isWindowableVeh = false
        if veh then
            isWindowableVeh = exports['cr_vehicle']:isWindowableVeh(getElementModel(veh)) or true
        end
        if veh and isWindowableVeh then
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. " /s [Szöveg]", 255,255,255,true)
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            local name = exports['cr_admin']:getAdminName(element)
            if not getElementData(veh, "veh >> windowState") then
                outputChatBox(name.." ordítja: "..message, 255,255,255)
            else
                outputChatBox(name.." ordítja (járműben): "..message, 255,255,255)
            end
            
            spamTimer = setTimer(function() end, 300, 1)

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    --local x1, y1, z1 = getElementPosition(v)
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                    local veh2 = getPedOccupiedVehicle(v)
                    if veh2 and veh == veh2 then
                        local r,g,b = 255,255,255
                        if not getElementData(veh, "veh >> windowState") then
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b)
                        else
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja (járműben): "..message, r,g,b)
                        end
                    elseif distance <= 18 and not getElementData(veh, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 4 then
                            r,g,b = 255,255,255
                        elseif distance <= 8 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 12 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 16 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b)
                    elseif distance <= 4 and getElementData(veh, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 166, 166, 166
                        elseif distance <= 4 then
                            r,g,b = 115, 115, 115
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja (járműben): "..message, r,g,b)
                    end
                end
            end
        else
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. " /s [Szöveg]", 255,255,255,true)
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            setElementData(localPlayer, "animation", {"ON_LOOKERS","shout_01"})
            
            local name = exports['cr_admin']:getAdminName(element)
            outputChatBox(name.." ordítja: "..message, 255,255,255)
            
            spamTimer = setTimer(function() end, 300, 1)

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    --local x1, y1, z1 = getElementPosition(v)
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                    local veh2 = getPedOccupiedVehicle(v)
                    if distance <= 18 and not veh2 or distance <= 18 and veh2 and not getElementData(veh2, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        if distance <= 4 then
                            r,g,b = 255,255,255
                        elseif distance <= 8 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 12 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 16 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b)
                    elseif veh2 and distance <= 6 and getElementData(veh2, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        if distance <= 2 then
                            r,g,b = 191, 191, 191 --75% white
                        elseif distance <= 4 then
                            r,g,b = 166, 166, 166 --65% white
                        elseif distance <= 6 then
                            r, g, b = 115, 115, 115 --45% white
                        else
                            r, g, b = 95, 95, 95 --?% white
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." ordítja: "..message, r,g,b)
                    end
                end
            end
        end
    elseif mtype == "c" then
        local veh = getPedOccupiedVehicle(localPlayer)
        local isWindowableVeh = false
        if veh then
            isWindowableVeh = exports['cr_vehicle']:isWindowableVeh(getElementModel(veh))
        end
        if veh and isWindowableVeh then
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. " /c [Szöveg]", 255,255,255,true)
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            local name = exports['cr_admin']:getAdminName(element)
            if not getElementData(veh, "veh >> windowState") then
                outputChatBox(name.." suttogja: "..message, 255,255,255)
            else
                outputChatBox(name.." suttogja (járműben): "..message, 255,255,255)
            end
            
            playSound("files/ws.wav")
            
            spamTimer = setTimer(function() end, 300, 1)

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    --local x1, y1, z1 = getElementPosition(v)
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                    local veh2 = getPedOccupiedVehicle(v)
                    if veh2 and veh == veh2 then
                        local r,g,b = 255,255,255
                        if not getElementData(veh, "veh >> windowState") then
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja (járműben): "..message, r,g,b, true)
                        else
                            triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja (járműben): "..message, r,g,b, true)
                        end
                    elseif distance <= 2 and not getElementData(veh, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        --outputChatBox(distance)
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja: "..message, r,g,b, true)
                    end
                end
            end
        else
            --local message
            if string.len(message) > 1 then
                message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
            elseif string.len(message) < 1 or string.len(message) == 0 then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. " /c [Szöveg]", 255,255,255,true)
                return
            elseif string.sub(message, 1, 1) == " " then
                return    
            elseif string.len(message) > maxLength then
                return
            else
                message = string.upper(string.sub(message, 1, 1))
            end
            
            for k,v in pairs(emojis) do
                if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                    setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                    if emojis[k][2] then
                        if not getPedOccupiedVehicle(localPlayer) then 
                            setElementData(localPlayer, "animation", emojis[k][2]); 
                         end
                    end
                    --outputChatBox(message)
                    --outputChatBox(k)
                    local mes = string.gsub(string.lower(message), k, "") 
                    local mes2 = string.gsub(mes, " ", "")
                    if #mes2 <= 0 then
                        return
                    else
                        message = mes
                    end
                end
            end
            
            local name = exports['cr_admin']:getAdminName(element)
            outputChatBox(name.." suttogja: "..message, 255,255,255)
            
            spamTimer = setTimer(function() end, 300, 1)
            
            playSound("files/ws.wav")

            local x,y,z = getElementPosition(localPlayer)
            local int2 = getElementInterior(localPlayer)
            local dim2 = getElementDimension(localPlayer)
            if getElementData(localPlayer, "player >> recon") then
                local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
                x,y,z = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            for k,v in pairs(getElementsByType("player")) do
                local int = getElementInterior(v)
                local dim = getElementDimension(v)
                local x1,y1,z1 = getElementPosition(v)
                if getElementData(v, "player >> recon") then
                    local target = getElementData(v, "player >> recon >> target") or v
                    x1,y1,z1 = getElementPosition(target)
                    int, dim = getElementInterior(target), getElementDimension(target)
                end
                if v ~= localPlayer and int == int2 and dim == dim2 then
                    --local x1, y1, z1 = getElementPosition(v)
                    local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                    local veh2 = getPedOccupiedVehicle(v)
                    if distance <= 2 and not veh2 or distance <= 2 and veh2 and not getElementData(veh2, "veh >> windowState") then
                        local r,g,b = 255,255,255
                        if distance <= 2 then
                            r,g,b = 255,255,255
                        end
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." suttogja: "..message, r,g,b, true)
                    end
                end
            end
        end
    elseif mtype == "try2 >> success" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /megpróbálja [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" ***"..name.." megpróbálja "..message.." és sikerül neki!", 71, 209, 71)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 71, 209, 71
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " ***"..name.." megpróbálja "..message.." és sikerül neki!", r,g,b)
                end
            end
        end
    elseif mtype == "try2 >> failed" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /megpróbálja [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" ***"..name.." megpróbálja "..message.." de sajnos nem sikerült neki!", 255, 51, 51)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 255, 51, 51
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " ***"..name.." megpróbálja "..message.." de sajnos nem sikerült neki!", r,g,b)
                end
            end
        end    
    elseif mtype == "try >> success" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /megpróbál [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" ***"..name.." megpróbál "..message.." és sikerül neki!", 71, 209, 71)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 71, 209, 71
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " ***"..name.." megpróbál "..message.." és sikerül neki!", r,g,b)
                end
            end
        end
    elseif mtype == "try >> failed" then
        --local message
        if string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /megpróbál [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.sub(message, 1, 1)
        end
        
        for k,v in pairs(emojis) do
            if string.upper(message):find(string.upper(string.gsub(string.lower(k), string.lower("%%"), "") ), 1, true) then
                setTimer(onClientMessage, 400, 1, localPlayer, emojis[k][1], 1)
                if emojis[k][2] then
                    if not getPedOccupiedVehicle(localPlayer) then 
                        setElementData(localPlayer, "animation", emojis[k][2]); 
                     end
                end
                --outputChatBox(message)
                --outputChatBox(k)
                local mes = string.gsub(string.lower(message), k, "") 
                local mes2 = string.gsub(mes, " ", "")
                if #mes2 <= 0 then
                    return
                else
                    message = mes
                end
            end
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        outputChatBox(" ***"..name.." megpróbál "..message.." de sajnos nem sikerült neki!", 255, 51, 51)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 255, 51, 51
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, " ***"..name.." megpróbál "..message.." de sajnos nem sikerült neki!", r,g,b)
                end
            end
        end
    elseif mtype == "ooc" then
        --local message
        
        --[[
        KELL MÉG BELE AZ ADMINDUTYS CUCC
        ]]
        
        if string.len(message) > maxLength then
            return
        elseif string.len(message) > 1 then
            message = string.sub(message, 1, 1) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " /b [Szöveg]", 255,255,255,true)
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        else
            message = string.sub(message, 1, 1)
        end
        
        local name = exports['cr_admin']:getAdminName(element)
        local time = getRealTime()
        local time1 = time.hour
        if time1 < 10 then
            time1 = "0" .. tostring(time1)
        end
        local time2 = time.minute
        if time2 < 10 then
            time2 = "0" .. tostring(time2)
        end
        local time3 = time.second
        if time3 < 10 then
            time3 = "0" .. tostring(time3)
        end
        --local time = time1..":"..time2..":"..time3
        local time = ""
        insertOOC("(( "..name..": "..message.." ))", 0, localPlayer)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(localPlayer)
        local int2 = getElementInterior(localPlayer)
        local dim2 = getElementDimension(localPlayer)
        if getElementData(localPlayer, "player >> recon") then
            local target = getElementData(localPlayer, "player >> recon >> target") or localPlayer
            x,y,z = getElementPosition(target)
            int, dim = getElementInterior(target), getElementDimension(target)
        end
        for k,v in pairs(getElementsByType("player")) do
            local int = getElementInterior(v)
            local dim = getElementDimension(v)
            local x1,y1,z1 = getElementPosition(v)
            if getElementData(v, "player >> recon") then
                local target = getElementData(v, "player >> recon >> target") or v
                x1,y1,z1 = getElementPosition(target)
                int, dim = getElementInterior(target), getElementDimension(target)
            end
            if v ~= localPlayer and int == int2 and dim == dim2 then
                --local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                if distance <= 8 then
                    local r,g,b = 255, 255, 255
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, "(( "..name..": "..message.." ))", r,g,b, false, true)
                end
            end
        end
    end
end
addEvent("onClientMessage", true)
addEventHandler("onClientMessage", root, onClientMessage)

function rePresentSay(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, 0)
end
addCommandHandler("Say", rePresentSay)
addCommandHandler("SAY", rePresentSay)
addCommandHandler("saY", rePresentSay)
addCommandHandler("sAY", rePresentSay)
addCommandHandler("sAy", rePresentSay)

function rePresentMe(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, 1)
end
addCommandHandler("Me", rePresentMe)
addCommandHandler("me", rePresentMe)
addCommandHandler("ME", rePresentMe)
addCommandHandler("mE", rePresentMe)

function rePresentDo(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "do")
end
addCommandHandler("Do", rePresentDo)
addCommandHandler("do", rePresentDo)
addCommandHandler("DO", rePresentDo)
addCommandHandler("dO", rePresentDo)

function rePresentAme(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "ame")
end
addCommandHandler("AME", rePresentAme)
addCommandHandler("aMe", rePresentAme)
addCommandHandler("Ame", rePresentAme)
addCommandHandler("aME", rePresentAme)
addCommandHandler("AMe", rePresentAme)
addCommandHandler("ame", rePresentAme)

function rePresentShout(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "shout")
end
addCommandHandler("s", rePresentShout)
addCommandHandler("S", rePresentShout)
addCommandHandler("Shout", rePresentShout)
addCommandHandler("shout", rePresentShout)

function rePresentC(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "c")
end
addCommandHandler("c", rePresentC)
addCommandHandler("C", rePresentC)

function rePresentTry(cmd, ...)
    local text = table.concat({...}, " ")
    local rand = math.random(1,2) 
    if rand == 1 then
        onClientMessage(localPlayer, text, "try >> success")
    else
        onClientMessage(localPlayer, text, "try >> failed")
    end
end
addCommandHandler("try", rePresentTry)
addCommandHandler("Try", rePresentTry)
addCommandHandler("megprobal", rePresentTry)
addCommandHandler("Megprobal", rePresentTry)
addCommandHandler("Megpróbál", rePresentTry)
addCommandHandler("megpróbál", rePresentTry)

function rePresentTry2(cmd, ...)
    local text = table.concat({...}, " ")
    local rand = math.random(1,2) 
    if rand == 1 then
        onClientMessage(localPlayer, text, "try2 >> success")
    else
        onClientMessage(localPlayer, text, "try2 >> failed")
    end
end
addCommandHandler("try2", rePresentTry2)
addCommandHandler("Try2", rePresentTry2)
addCommandHandler("megprobalja", rePresentTry2)
addCommandHandler("Megprobalja", rePresentTry2)
addCommandHandler("Megpróbálja", rePresentTry2)
addCommandHandler("megpróbálja", rePresentTry2)

addEvent("chat -- receive", true)
addEventHandler("chat -- receive", root,
    function(e, message, r,g,b, whisper, ooc)
        if e == localPlayer then    
            if ooc then
                --outputChatBox(message, r,g,b)
                insertOOC(message, 0, e)
            else
                outputChatBox(message, r,g,b)
            end

            if whisper then
                playSound("files/ws.wav")
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        --outputChatBox("asd")
        --unbindKey("b", "down", "chatbox", "OOC")
        --bindKey("t", "down", "chatbox", "IC")
        bindKey("b", "down", "chatbox", "OOC")
        bindKey("y", "down", "chatbox", "Rádió")
        --unbindKey("y", "down", "chatbox", "Rádió")
    end
)

function useOOC(cmd, ...)
    local text = table.concat({...}, " ")
    onClientMessage(localPlayer, text, "ooc")
end
addCommandHandler("b", useOOC)
addCommandHandler("B", useOOC)
addCommandHandler("OOC", useOOC)
addCommandHandler("ooc", useOOC)
addCommandHandler("Ooc", useOOC)
addCommandHandler("OoC", useOOC)

function insertOOC(message, typ, p)
    triggerEvent("onOOCMessageSend", localPlayer, message, typ, p)
end

--[[
function getDetails(component, notRender)
    if notRender then
        if getResourceState(getResourceFromName("cr_fonts")) ~= "running" then return end
    end
    return exports['cr_interface']:getDetails(component)
end

local OOCCache = {}
local state = false
local enabled,x,y,w,h,sizable,turnable = getDetails("ooc", true)
local maxLength = 15 * 2
if tostring(enabled) == "true" then
    maxLength = math.floor(h / 15)
end

setTimer(
    function()
    	if not getElementData(localPlayer, "loggedIn") then return end

        local enabled,x,y,w,h,sizable,turnable = getDetails("ooc")
        if tostring(enabled) == "nil" or tostring(enabled) == "false" then return end
        if math.floor(h / 15) ~= maxLength and math.floor(h / 15) < maxLength then
            maxLength = math.floor(h / 15)
            while #OOCCache > maxLength do
                table.remove(OOCCache, 1)
            end
        else
            maxLength = math.floor(h / 15)
        end
    end, 100, 0
)

function insertOOC(text)
    --outputChatBox(text)
    table.insert(OOCCache, #OOCCache + 1, text)
    if #OOCCache > maxLength then
        table.remove(OOCCache, 1)
    end
    outputConsole("[OOC] " .. text)
end

function drawnOOC()
    if not getElementData(localPlayer, "hudVisible") then return end
    if not getElementData(localPlayer, "loggedIn") then return end
    --OOC
    local enabled,x,y,w,h,sizable,turnable = getDetails("ooc")
    if not enabled then return end
    dxDrawText("OOC Chat (törléshez /clearooc)", x+1, y - 10+1, x+1, y - 15+1, tocolor(0,0,0,255), 1, "default-bold", "left", "center")
    dxDrawText("OOC Chat (törléshez /clearooc)", x, y - 10, x, y - 15, tocolor(255,255,255,255), 1, "default-bold", "left", "center")
    local ay = 15
    for k,v in pairs(OOCCache) do
        dxDrawText(v, x+1, y + ay - 20+1, x+1, y + ay+1, tocolor(0,0,0,255), 1, "default-bold", "left", "center")
        dxDrawText(v, x, y + ay - 20, x, y + ay, tocolor(255,255,255,255), 1, "default-bold", "left", "center")
        ay = ay + 15
    end
end
addEventHandler("onClientRender", root, drawnOOC, true, "low-5")

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "ooc.enabled" then
            local value = getElementData(source, dName)
            if value then
            	removeEventHandler("onClientRender", root, drawnOOC)
                addEventHandler("onClientRender", root, drawnOOC, true, "low-5")
            else
                removeEventHandler("onClientRender", root, drawnOOC)
            end
        end
    end
)

function clearOOC(cmd)
    local syntax = exports['cr_core']:getServerSyntax(false, "success")
    outputChatBox(syntax.."OOC Chat sikeresen kiürítve!", 255,255,255,true)
    OOCCache = {}
end
addCommandHandler("clearOOC", clearOOC)
addCommandHandler("ClearOOC", clearOOC)
addCommandHandler("Clearooc", clearOOC)
addCommandHandler("clearooc", clearOOC)

function clearChat(cmd)
    local chatData = getChatboxLayout()
    local lines = chatData["chat_lines"]
    for i = 0, lines do
        outputChatBox(" ")
    end
    local syntax = exports['cr_core']:getServerSyntax(false, "success")
    outputChatBox(syntax.."Chat sikeresen kiürítve!", 255,255,255,true)
end
addCommandHandler("clearChat", clearChat)
addCommandHandler("ClearChat", clearChat)
addCommandHandler("Clearchat", clearChat)
addCommandHandler("clearchat", clearChat)
--]]