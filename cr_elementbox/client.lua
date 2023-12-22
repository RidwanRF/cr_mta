import("*"):from("cr_core")

local white = "#ffffff"

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            import("*"):from("cr_core")
        end
    end
)

function getFont(a, b)
    return exports['cr_fonts']:getFont(a, b)
end

local size = Vector2(200, 165)
local size2 = Vector2(size.x - 20, 25)
lastClickTick = getTickCount()
local saveJSON = {}

local gButtons = {
    --["type"] = {}
    ["player"] = {
        --{"Név" ({Név ha true, Név ha false, EData}), funcOnPress, checkFunc},
        
        {"Bemutatkozás", {255,153,51,255/100*75},
            function()
                local debutTable = localPlayer:getData("debuts") or {}
                local id2 = tostring(getElementData(e, "acc >> id") or 0)
                debutTable[tonumber(id2)] = true
                local green = exports['cr_core']:getServerColor(nil, true)
                local aName = exports['cr_admin']:getAdminName(e, false)
                local syntax = getServerSyntax("Friend", "success")
                outputChatBox(syntax .. "Bemutatkoztál "..green..aName..white.." -nak/nek", 255,255,255,true)
                triggerServerEvent("nametag->goToServer", localPlayer, e, id, localPlayer)
                localPlayer:setData("debuts", debutTable)
            end,
            function()
                local id = tostring(getElementData(localPlayer, "acc >> id") or 0)
                local id2 = tostring(getElementData(e, "acc >> id") or 0)
                local debutTable = localPlayer:getData("debuts") or {}
                if not debutTable[tonumber(id2)] then
                    return true
                
                else
                    return false
                end
            end,
        },
        {"Megmotozás", {255,153,51,255/100*75},
            function()
                
                local name2 = e:getData("char >> name")
                exports['cr_chat']:createMessage(localPlayer, "megmotozott egy közelében lévő embert ("..name2:gsub("_", " ")..")", 1)
                exports['cr_inventory']:openInventory(e, true, true)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                local anim1, anim2 = getPedAnimation(e)
                if anim1 == "ped" and anim2 == "FLOOR_hit" or anim1 == "ped" and anim2 == "FLOOR_hit_f" or anim1 == "ped" and anim2 == "handsup" then
                    return true
                else
                    return false
                end
            end,
        },
        {{"Bilincs levétele", "Megbilincselés", "char >> cuffed"}, {255,153,51,255/100*75},
            function()
                return
            end,
            function()
                return true
            end,
        },
        {"Megkötözés", {255,153,51,255/100*75},
            function()
                return
            end,
            function()
                return true
            end,
        },
        {{"Szemkötő levétele", "Szemkötő felrakása", "char >> blinded"}, {255,153,51,255/100*75},
            function()
                return
            end,
            function()
                return true
            end,
        },
        {{"Levétel a hordágyról", "Hordágyra helyezés", "char >> inAmbulanceBed"}, {255,153,51,255/100*75},
            function()
                exports['cr_ambulance']:doAmbulanceBedPlacePlayer(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                return true
            end,
        },
        {"Átvizsgálás", {255,153,51,255/100*75},
            function()
                exports['cr_ambulance']:syncPlayerBrokenParts(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                return true
            end,
        },
    },
    ["vehicle"] = {
        {{"Csomagtartó bezárása", "Csomagtartó kinyitása", "veh >> boot"}, {255,153,51,255/100*75},
            function()
                --outputChatBox(e:getData("veh >> id"))
                if exports['cr_inventory']:hasItem(localPlayer, 16, e:getData("veh >> id")) then
                    --outputChatBox(tostring(e:getData("veh >> boot")))
                    if not e:getData("veh >> boot") then
                        exports['cr_chat']:createMessage(localPlayer, "kinyitja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(e)..")", 1)
                    else
                        exports['cr_chat']:createMessage(localPlayer, "bezárja a jármű csomagtartóját ("..exports['cr_vehicle']:getVehicleName(e)..")", 1)
                    end
                    e:setData("veh >> boot", not e:getData("veh >> boot"))
                    
                    if not e:getData("veh >> boot") then
                        e:setData("inventory.open", nil)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "Nincs kulcsod a járműhöz!", 255,255,255,true)
                end
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end

                if enabled then
                    return true
                else
                    return false
                end
            end,
        },
        {"Csomagtartó", {255,153,51,255/100*75},
            function()
                exports['cr_inventory']:openBoot(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end

                if enabled then
                    return true
                else
                    return false
                end
            end,
        },
        {{"Hordágy kivétele", "Hordágy berakása", "veh >> ambulanceBed"}, {255,153,51,255/100*75},
            function()
                --exports['cr_inventory']:openBoot(e)
                exports['cr_ambulance']:interactAmbulanceBed(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                if e.model == 416 then
                    local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                    local enabled = false
                    if x and y and z then
                        local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                        if dist <= 1.5 then
                            enabled = true
                        end
                    end
            
                    if enabled then
                        if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end,
        },
        {"Információk", {255,153,51,255/100*75},
            function()
                outputChatBox("Hamarosan...")
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                if getDistanceBetweenPoints3D(e.position, localPlayer.position) <= 4 then
                    return true
                else
                    return false
                end
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                local x, y, z = getVehicleComponentPosition(e, "boot_dummy", "world")
                local enabled = false
                if x and y and z then
                    local dist = getDistanceBetweenPoints3D(localPlayer.position, x,y,z)
                    if dist <= 1.5 then
                        enabled = true
                    end
                end
            
                if getDistanceBetweenPoints3D(e.position, localPlayer.position) <= 4 or enabled then
                    return true
                else
                    state = false
                    e = nil
                    m:destroy()
                    removeEventHandler("onClientRender", root, drawnPanel)
                    return false
                end
            end,
        },
    },
    ["ped"] = {
        {"Átkutatás", {255,153,51,255/100*75},
            function()
                exports['cr_ambulance']:getBullets(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
            end,
            function()
                if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Megmotozás", {255,153,51,255/100*75},
            function()
                local e = e:getData("parent")
                local name2 = e:getData("char >> name")
                exports['cr_chat']:createMessage(localPlayer, "megmotozott egy közelében lévő embert ("..name2:gsub("_", " ")..")", 1)
                exports['cr_inventory']:openInventory(e, true, true)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)

                return
            end,
            function()
                local anim1, anim2 = getPedAnimation(e)
                if anim1 == "ped" and anim2 == "FLOOR_hit" or anim1 == "ped" and anim2 == "FLOOR_hit_f" or anim1 == "ped" and anim2 == "handsup" or anim1 == "ped" and anim2 == "KO_shot_front" then
                    return true
                else
                    return false
                end
            end,
        },
        {"Felélesztés", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felélesztés cucc")
                exports['cr_ambulance']:doRespawn(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                return true
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                return true
            end,
        },
    },
    ["object"] = {
        {"chanelName", {255,153,51,0},
            function()
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        local channel = exports['cr_radio']:getChannels()
                        chanelName = channel[e:getData("hifi >> channel") or 1][1]
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        
        {{"Kikapcsolás", "Bekapcsolás", "hifi >> state"}, {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                e:setData("hifi >> state", not e:getData("hifi >> state"))
                local channel = exports['cr_radio']:getChannels()
                if not e:getData("hifi >> channel") or not channel[e:getData("hifi >> channel")] then
                    e:setData("hifi >> channel", 1)
                end
                
                --[[
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    return true
                else
                    return false
                end
            end,
        },
        
        {"Következő állomás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                local num = e:getData("hifi >> channel") or 1
                local num = num + 1
                local channel = exports['cr_radio']:getChannels()
                if not channel[num] then
                    num = 1
                end
                e:setData("hifi >> channel", num)
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --[[
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        
        {"Előző állomás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                local num = e:getData("hifi >> channel") or 1
                local num = num - 1
                local channel = exports['cr_radio']:getChannels()
                if num <= 0 then
                    num = #channel
                end
                e:setData("hifi >> channel", num)
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --[[
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                ]]
                
                return
            end,
            function()
                if e.model == 2102 then
                    --return true
                    if e:getData("hifi >> state") then
                        if not e:getData("hifi >> movedBy") then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end,
        },
        
        {"Mozgatás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                if not e:getData("hifi >> movedBy") then
                    exports["cr_elementeditor"]:toggleEditor(e, "onSaveHifiPositionEditor", "onSaveHifiDeleteEditor")
                    exports['cr_chat']:createMessage(localPlayer, "elkezd mozgatni egy hifit", 1)
                    e:setData("hifi >> movedBy", localPlayer)
                    triggerServerEvent("hifiChangeState", localPlayer, e, 180)
                    state = false
                    e = nil
                    m:destroy()
                    removeEventHandler("onClientRender", root, drawnPanel)
                end
                
                return
            end,
            function()
                if e.model == 2102 then
                    if not e:getData("hifi >> state") then
                        if not e:getData("hifi >> movedBy") then
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },
        
        {"Felvétel", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                exports['cr_chat']:createMessage(localPlayer, "felvesz egy hifit", 1)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                if e.model == 2102 then
                    if not e:getData("hifi >> state") then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },
        
        {"Hordágy felvétele", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                exports['cr_ambulance']:interactAmbulanceBed2(e)
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                if e.model == 11625 then
                    --return true
                    if exports['cr_faction']:isPlayerInFaction(localPlayer, 2) then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        {"Ember lesegítése", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                local p = e:getData("isPlayerInBed")
                exports['cr_ambulance']:doAmbulanceBedPlacePlayer(p)
                
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                if e.model == 11625 then
                    if e:getData("isPlayerInBed") then
                        return true
                    else
                        return false
                    end
                end
            end,
        },
        {"Megnyitás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                
                exports['cr_inventory']:openSafe(e)
                
--                exports["cr_elementeditor"]:toggleEditor(e, "onSaveHifiPositionEditor", "onSaveHifiDeleteEditor")
                
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Felvétel", {255,153,51,255/100*75},
            function()
                --outputChatBox("Majd ide a felvétel cucc")
                
                if exports['cr_inventory']:hasItem(localPlayer, 29, tonumber(e:getData("safe.id"))) then
                    exports['cr_inventory']:destroySafe(e)
                else
                    exports['cr_infobox']:addBox("error", "Ehhez a széfhez nincs kulcsod")
                end
                
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                
                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    return true
                else
                    return false
                end
            end,
        },
        {"Mozgatás", {255,153,51,255/100*75},
            function()
                --outputChatBox("Következő állomás")
                --e:setData("hifi >> state", not e:getData("hifi >> state"))
                
                --triggerServerEvent("destroyHifi", localPlayer, localPlayer, e)
                if not e:getData("safe >> movedBy") then
                    if exports['cr_inventory']:hasItem(localPlayer, 29, tonumber(e:getData("safe.id"))) then
                        exports["cr_elementeditor"]:toggleEditor(e, "onSaveSafePositionEditor", "onSaveSafeDeleteEditor")
                        exports['cr_chat']:createMessage(localPlayer, "elkezd mozgatni egy széfet", 1)
                        e:setData("safe >> movedBy", localPlayer)
                        triggerServerEvent("safeChangeState", localPlayer, e, 180)
                        state = false
                        e = nil
                        m:destroy()
                        removeEventHandler("onClientRender", root, drawnPanel)
                    else
                        exports['cr_infobox']:addBox("error", "Ehhez a széfhez nincs kulcsod")
                    end
                end
                
                return
            end,
            function()
                if e.model == 2332 and tonumber(e:getData("safe.id")) then
                    if not e:getData("safe >> movedBy") then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end,
        },
        {"Bezárás", {255,153,51,255/100*75},
            function()
                state = false
                e = nil
                m:destroy()
                removeEventHandler("onClientRender", root, drawnPanel)
                return
            end,
            function()
                return true
            end,
        },
    },
}

local maxDist = {
    ["player"] = 2,
    ["vehicle"] = 8,
    ["ped"] = 2,
    ["object"] = 2,
    ["vehicle416"] = 5,
}

addEventHandler("onClientClick", root,
    function(b, s, _,_,_,_,_, worldElement)
        if localPlayer.vehicle then return end
        if not state and worldElement and gButtons[worldElement.type] and worldElement ~= localPlayer and b == "right" and s == "down" then
            if worldElement.type == "ped" and not worldElement:getData("parent") then return end
            --if worldElement.type == "object" and not worldElement:getData("placed") and not worldElement:getData("safe.id") then return end
            if worldElement.type == "object" and not worldElement:getData("placed") and not worldElement:getData("safe.id") and not worldElement:getData("hifi >> creator") then return end
            if localPlayer:getData("keysDenied") then return end
            local pos = localPlayer:getPosition()
            local pos2 = worldElement:getPosition()
            local dist = getDistanceBetweenPoints3D(pos, pos2)
            --outputChatBox(dist)
            --outputChatBox(tostring(maxDist[worldElement.type .. "" .. worldElement.model] and dist <= maxDist[worldElement.type .. "" .. worldElement.model]))
            if maxDist[worldElement.type .. "" .. worldElement.model] and dist <= maxDist[worldElement.type .. "" .. worldElement.model] or dist <= maxDist[worldElement.type] then
                --outputChatBox("asd")
                font = getFont("Rubik-Regular", 10)
                m = Marker(0,0,0, "arrow", 0.4, 87, 200, 255)
                e = worldElement
                m:attach(e, 0, -0.08, 1.8)
                state = true
                pos2.z = pos2.z + 0.5
                multipler = 5
                multipler2 = 3.5
                alpha = 0
                alpha2 = 0
                x, y = getScreenFromWorldPosition(pos2)
                addEventHandler("onClientRender", root, drawnPanel, true, "low-5")
            end
        elseif state and b == "left" and s == "down" then
            if lastClickTick + 600 > getTickCount() then
                return
            end
            lastClickTick = getTickCount()
            
            local pos2 = e:getPosition()
            local x, y = getScreenFromWorldPosition(pos2) 
            if x and y then
                local y = y - 30

                y = y + 10
                for k, v in pairs(gButtons[e.type]) do
                    local name = v[1]
                    --[[
                    if type(name) == "table" then
                        local name1, name2, eData = unpack(name)
                        local value = e and isElement(e) and e:getData(eData)
                        if tonumber(value) then
                            if value == 1 then value = true else value = false end
                        end
                        
                        if value then
                            name = name1
                        else
                            name = name2
                        end
                    end]]
                    local r,g,b,a = unpack(v[2])
                    local func = v[3]
                    local func2 = v[4]
                    if func2() then
                        if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                            if exports['cr_network']:getNetworkStatus() then 
                                e = nil
                                m:destroy()
                                state = false
                                removeEventHandler("onClientRender", root, drawnPanel)
                                return
                            end
                            return func()
                        end

                        y = y + size2.y + 5
                    end
                end
            end
        end
    end
)

function drawnPanel()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    local pos = localPlayer:getPosition()
    local pos2 = e:getPosition()
    local dist = getDistanceBetweenPoints3D(pos, pos2)
    --outputChatBox(tostring(maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type .. "" .. e.model] ))
    if not e or not isElement(e) or maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type .. "" .. e.model] or not maxDist[e.type .. "" .. e.model] and dist > maxDist[e.type] then
        e = nil
        m:destroy()
        state = false
        removeEventHandler("onClientRender", root, drawnPanel)
        return
    end
    local x, y = getScreenFromWorldPosition(pos2) 
    if x and y then
        local y = y - 30
        local num = 0
        for k,v in pairs(gButtons[e.type]) do 
            if v[4]() then
                num = num + 1 
            end
        end
        size.y = num * (size2.y + 5) + 15
		dxDrawRoundedRectangle(x - size.x/2, y, size.x, size.y, tocolor(0,0,0,math.min(alpha, 255/100*75)))
        y = y + 10
        
        for k, v in pairs(gButtons[e.type]) do
            local name = v[1]
            local left = false
            if name == "chanelName" then 
                name = chanelName 
                left = true
            end
            if type(name) == "table" then
                local name1, name2, eData = unpack(name)
                if not isElement(e) then return end
                local value = e:getData(eData)
                if tonumber(value) then
                    if value == 1 then value = true else value = false end
                end

                if value then
                    name = name1
                else
                    name = name2
                end
            end
            local r,g,b,a = unpack(v[2])
            local func = v[3]
            local func2 = v[4]
            if func2() then
                if not left then
                    if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                        if alpha2 + multipler2 <= 255 then
                            alpha2 = alpha2 + multipler2
                        elseif alpha >= 255 then
                            alpha2 = 255
                        end
                        dxDrawRoundedRectangle(x - size2.x/2, y, size2.x, size2.y, tocolor(r,g,b,math.min(alpha2, a)))
                    else
                        dxDrawRoundedRectangle(x - size2.x/2, y, size2.x, size2.y, tocolor(52,52,52,math.min(alpha, 255/100*50)))
                    end
                end
                
                dxDrawText(name, x - size2.x/2, y, x - size2.x/2 + size2.x, y + size2.y, tocolor(255,255,255,alpha), 1, font, left and "left" or "center", "center")

                y = y + size2.y + 5
            end
        end
    end
end

addEventHandler("onClientCursorMove", root,
    function()
        if state then
            local pos2 = e:getPosition()
            local x, y = getScreenFromWorldPosition(pos2) 
            if x and y then
                local y = y - 30

                y = y + 10
                local breaked = false
                
                for k, v in pairs(gButtons[e.type]) do
                    local name = v[1]
                    if type(name) == "table" then
                        local name1, name2, eData = unpack(name)
                        if not isElement(e) then return end
                        local value = e:getData(eData)
                        if tonumber(value) then
                            if value == 1 then value = true else value = false end
                        end

                        if value then
                            name = name1
                        else
                            name = name2
                        end
                    end
                    local r,g,b,a = unpack(v[2])
                    local func = v[3]
                    local func2 = v[4]
                    --outputChatBox(k)
                    if func2() then
                        --outputChatBox(k .. "a")
                        --dxDrawRectangle(x - size2.x/2, y, size2.x, size2.y)
                        if isInSlot(x - size2.x/2, y, size2.x, size2.y) then
                            breaked = true
                            break
                        end
                        
                        y = y + size2.y + 5
                    end
                end
                
                if not breaked then
                    alpha2 = 0
                end
            end
        end
    end
)

addEvent("nametag->goToClient", true)
addEventHandler("nametag->goToClient", root, 
    function(id, e2)
        local friendTable = localPlayer:getData("friends") or {}
        if not friendTable[tonumber(id)] then
            friendTable[tonumber(id)] = true
            local syntax = getServerSyntax("Friend", "success")
            local aName = exports['cr_admin']:getAdminName(e2, false)
            local id = getElementData(localPlayer, "acc >> id")
            local green = exports['cr_core']:getServerColor(nil, true)
            outputChatBox(syntax .. "Bemutatkozott neked "..green..aName..white.."!", 255,255,255,true)
            localPlayer:setData("friends", friendTable)
        end
    end
)

function isKnow(who, id)
    local friendTable = who:getData("friends") or {}
    if friendTable[tonumber(id)] then
        return true
    else
        return false
    end
end

function dxDrawRoundedRectangle(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	dxDrawRectangle(left + width, top, 2, height, color, postgui);
	dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	dxDrawRectangle(left, top + height, width, 2, color, postgui);

	dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	dxDrawRectangle(left, top, width, height, color, postgui);
end