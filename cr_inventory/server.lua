connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

spam = {}

spamTimers = {}

white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

function loadItems()
    setElementData(root, "loaded", false)
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local eType = tonumber(row["elementtype"])
                        local eId = tonumber(row["elementid"])
                        local iType = tonumber(row["itemtype"])
                        local itemid = tonumber(row["itemid"])    
                        local slot = tonumber(row["slot"])    
                        local value = tostring(row["value"])
                        local status = tonumber(row["status"])
                        local count = tonumber(row["count"])  
                        if not count then
                            count = 1
                        end
                        local dutyitem = tonumber(row["dutyitem"])    
                        local premium = tonumber(row["premium"])
                        local nbt = tostring(row["nbt"])
                        
                        --//Fejleszd majd tovább, premiummal és nbtvel -- Jó
                        
                        checkTableArray(eType, eId, iType, slot)
                        
                        if iType == 10 then
                            local table = fromJSON(value)
                            table[3] = id
                            cache[eType][eId][iType][slot] = table
                        else
                            if tonumber(value) then
                                value = tonumber(value)
                            elseif fromJSON(value) then
                                value = fromJSON(value)
                            end
                            
                            if tonumber(nbt) then
                                nbt = tonumber(nbt)
                            elseif fromJSON(nbt) then
                                nbt = fromJSON(nbt)    
                            end
                            cache[eType][eId][iType][slot] = {id, itemid, value, count, status, dutyitem, premium, nbt}
                        end
                        --outputDebugString("Loading item #"..id, 0, 255, 50, 255)
                    end,
                    -- callback
                    function()
                        setElementData(root, "loaded", true)
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." items in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `items`")
    
    giveCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local details = tostring(row["data"])
                        local ownerid = tonumber(row["ownerid"])
                        local iType = tonumber(row["iType"])
                        --IDEEE
                        
                        local details = fromJSON(details)
                        local tble = {}
                        for k,v in pairs(details) do
                            if tonumber(k) then
                                --details[k] = nil
                                tble[tonumber(k)] = v
                            else
                                tble[k] = v
                            end
                        end
                        
                        tble["id"] = id
                        
                        if not giveCache[ownerid] then
                            giveCache[ownerid] = {}
                        end
                        
                        if not giveCache[ownerid][iType] then
                            giveCache[ownerid][iType] = {}
                        end
                        
                        table.insert(giveCache[ownerid][iType], tble)
                        --outputDebugString("Loading item #"..id, 0, 255, 50, 255)
                    end,
                    -- callback
                    function()
                        setElementData(root, "loaded", true)
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." giveCache items in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `items_givecache`")
    
    trashCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local pos = fromJSON(tostring(row["pos"]))
                        
                        local x,y,z,rot,int,dim = unpack(pos)
                        local obj = createObject(1359, x,y,z)
                        obj.rotation.z = 0
                        obj.interior = int
                        --obj.dimension = dim
                        obj:setData("trash.id", id)
                        trashCache[id] = obj
                    end,
                    -- callback
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." trash in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `trash`")
    
    safeCache = {}
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            local tick = getTickCount()
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local pos = fromJSON(tostring(row["pos"]))
                        
                        local x,y,z,rot,int,dim = unpack(pos)
                        local obj = createObject(2332, x,y,z)
                        obj:setData("safe.id", id)
                        setElementRotation(obj, 0,0,rot)
                        obj.interior = int
                        obj.dimension = dim
                        safeCache[id] = obj
                    end,
                    -- callback
                    function()
                        collectgarbage("collect")
                        outputDebugString("Loaded "..query_lines.." safe in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
                    end
                )
            end    
        end, 
    connection, "SELECT * FROM `safe`")
end
addEventHandler("onResourceStart", resourceRoot, loadItems)

function createTrash(sourceElement, cmd)
    if exports['cr_permission']:hasPermission(sourceElement, "addtrash") then
        local x,y,z = getElementPosition(sourceElement)
        z = z - 0.35
        local rot = 0--getElementRotation(sourceElement)
        --sourceElement.position.z = z + 1
        local dim = sourceElement.dimension
        local int = sourceElement.interior
        local t = toJSON({x,y,z,rot,int,dim})
        
        sourceElement.position = Vector3(x,y,z+1)
        
        dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local pos = fromJSON(tostring(row["pos"]))

                            local x,y,z,rot,int,dim = unpack(pos)
                            local obj = createObject(1359, x,y,z)
                            --obj.rotation = rot
                            obj.interior = int
                            obj.dimension = dim
                            obj:setData("trash.id", id)
                            trashCache[id] = obj
                            
                            local green = exports['cr_core']:getServerColor("orange", true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "success")
                            outputChatBox(syntax .. "Sikeresen létrehoztál egy kukát (#"..green..id..white..")", sourceElement, 255,255,255,true)
                            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                            local syntax = exports['cr_admin']:getAdminSyntax()
                            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." létrehozott egy kukát (#"..green..id..white..")", 8)
                            
                            exports['cr_logs']:addLog(sourceElement, "Inventory", "addtrash", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " létrehozott egy kukát (#"..id..")")
                            --dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `trash` WHERE `pos`=?", t)
        
    end
end
addCommandHandler("addtrash", createTrash)

function deleteTrash(sourceElement, cmd, id)
    if exports['cr_permission']:hasPermission(sourceElement, "deltrash") then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if trashCache[id] then
            local obj = trashCache[id]
            local x,y,z = getElementPosition(obj)
            local rot = 0--obj.rotation.z
            local dim = obj.dimension
            local int = obj.interior
            local t = toJSON({x,y,z,rot,int,dim})
            --outputChatBox(t)
            dbExec(connection, "DELETE FROM `trash` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            trashCache[id] = nil
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen töröltél egy kukát (#"..green..id..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy kukát (#"..green..id..white..")", 8)
            
            exports['cr_logs']:addLog(sourceElement, "Inventory", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy kukát (#"..id..")")
            --dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)
        end
    end
end
addCommandHandler("deltrash", deleteTrash)

function createSafe(sourceElement, cmd, ignorePerm, xyz)
    if exports['cr_permission']:hasPermission(sourceElement, "addsafe") or ignorePerm then
        local x,y,z = unpack(xyz) --getElementPosition(sourceElement)
        z = z - 0.35
        local rot = sourceElement.rotation.z
        --sourceElement.position.z = z + 1
        local dim = sourceElement.dimension
        local int = sourceElement.interior
        --out
        if xyz then
            x,y,z = unpack(xyz)
        end
        local t = toJSON({x,y,z,rot,int,dim})
        --safeCache
        --iprint(t)
        
        --sourceElement.position = Vector3(x,y,z+1)
        
        dbExec(connection, "INSERT INTO `safe` SET `pos`=?", t)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local pos = fromJSON(tostring(row["pos"]))

                            local x,y,z,rot,int,dim = unpack(pos)
                            local obj = createObject(2332, x,y,z)
                            obj:setData("safe.id", id)
                            setElementRotation(obj, 0,0,rot)
                            obj.interior = int
                            obj.dimension = dim
                            safeCache[id] = obj
                            
                            if not ignorePerm then
                                local green = exports['cr_core']:getServerColor("orange", true)
                                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                                outputChatBox(syntax .. "Sikeresen létrehoztál egy széfet (#"..green..id..white..")", sourceElement, 255,255,255,true)
                                local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                                local syntax = exports['cr_admin']:getAdminSyntax()
                                exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." létrehozott egy széfet (#"..green..id..white..")", 8)
                            end

                            exports['cr_logs']:addLog(sourceElement, "Inventory", "addsafe", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " létrehozott egy széfet (#"..id..")")
                            --dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)
                            giveItem(sourceElement, convertKey("safe"), id, 1, 100, 0, 0, 0, true)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `safe` WHERE `pos`=?", t)
        
    end
end
--addCommandHandler("addsafe", createSafe)

addEvent("createSafe", true)
addEventHandler("createSafe", root,
    function(sourceElement, cmd, ignorePerm, pos)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                createSafe(sourceElement, cmd, ignorePerm, pos)
            end
        end
    end
)

function updateSafePosition(e, pos)
    if isElement(e) and tonumber(e:getData("safe.id")) then
        local x,y,z,_,_,rz = unpack(pos)
        e.position = Vector3(x,y,z)
        e.rotation = Vector3(0,0,rz)
        local t = toJSON({x,y,z,rz,e.interior,e.dimension})
        --safeCache
        --iprint(t)
        
        --sourceElement.position = Vector3(x,y,z+1)
        
        --dbExec(connection, "INSERT INTO `safe` SET `pos`=?", t)
        dbExec(connection, "UPDATE `safe` SET `pos`=? WHERE `id`=?", t, tonumber(e:getData("safe.id")))
    end
end
addEvent("updateSafePosition", true)
addEventHandler("updateSafePosition", root, updateSafePosition)

addEventHandler("onElementDataChange", resourceRoot,
    function(dName, oValue)
        if dName == "safe >> movedBy" then
            local val = source:getData(dName)
            --outputChatBox("asd")
            if val then
                source.alpha = 155
                source.collisions = false
            else
                source.alpha = 255
                source.collisions = true
            end
        end
    end
)

function safeChangeState(element, alpha)
    if isElement(e) and cache[e] then
        e.alpha = alpha
        if alpha == 255 then
            e.collisions = true
        elseif alpha == 180 then
            e.collisions = false
        end
    end
end
addEvent("safeChangeState", true)
addEventHandler("safeChangeState", root, safeChangeState)

function deleteSafe(sourceElement, cmd, id, ignorePerm)
    --outputChatBox(inspect(ignorePerm))
    if exports['cr_permission']:hasPermission(sourceElement, "delsafe") or ignorePerm then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if safeCache[id] then
            local obj = safeCache[id]
            local x,y,z = getElementPosition(obj)
            local rot = obj.rotation.z
            local dim = obj.dimension
            local int = obj.interior
            local t = toJSON({x,y,z,rot,int,dim})
            --outputChatBox(t)
            dbExec(connection, "DELETE FROM `safe` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            safeCache[id] = nil
            if not ignorePerm then
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                outputChatBox(syntax .. "Sikeresen töröltél egy széfet (#"..green..id..white..")", sourceElement, 255,255,255,true)
                local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                local syntax = exports['cr_admin']:getAdminSyntax()
                exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy széfet (#"..green..id..white..")", 8)
            end
            exports['cr_logs']:addLog(sourceElement, "Inventory", "delsafe", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy széfet (#"..id..")")
            --dbExec(connection, "INSERT INTO `s` SET `pos`=?", t)
        end
    end
end
addCommandHandler("delsafe", deleteSafe)

addEvent("deleteSafe", true)
addEventHandler("deleteSafe", root,
    function(sourceElement, cmd, id, ignorePerm)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                deleteSafe(sourceElement, cmd, id, ignorePerm)
            end
        end
    end
)

function needValue(sourceElement, rtype, neededElement, spec)
    if rtype == "items" then
        local args = {}
        local eType = getEType(neededElement)
        local eId = getEID(neededElement)
        if cache[eType] then
            if cache[eType][eId] then
                args = cache[eType][eId]
            end
        end

        --checkTableArray(eType, eId)

        args = args
        if sourceElement.type ~= "player" then
            local invE = sourceElement:getData("inventory.open")
            if invE and isElement(invE) and invE.type == "player" then
                sourceElement = invE
                triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
            end
            
            local invE = sourceElement:getData("inventory.open2")
            if invE and isElement(invE) and invE.type == "player" then
                sourceElement = invE
                triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
            end
        else
            triggerClientEvent(sourceElement, "returnValue", sourceElement, sourceElement, "items", {neededElement, args, spec})
        end
        --outputDebugString(eType.." - "..eId.." do trigger ["..rtype.."], Returnvalue: "..toJSON(args) .. " [Server]", 0, 200, 100, 85)
    end
end

addEvent("needValue", true)
addEventHandler("needValue", root,
    function(sourceElement, rtype, neededElement)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client and neededElement then
                needValue(sourceElement, rtype, neededElement)
            end
        end
    end
)

spamTimers["changeSlot"] = {}

function changeSlot(sourceElement, oldSlot, newSlot, iType, oData, oData2)
    --[[
    local lastClickTick = spamTimers["updateSlot"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["updateSlot"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    --outputChatBox(eType)
    --outputChatBox(eId)
    --outputChatBox(iType)
    --outputChatBox(oldSlot)
    --outputChatBox(newSlot)
    
    --oData[9] = nil
    --oData[10] = nil
    
    --outputChatBox(inspect(cache[eType][eId][iType][oldSlot]))
    --outputChatBox(inspect(oData))
    --outputChatBox(tostring(cache[eType][eId][iType][oldSlot] == oData))
    if cache[eType][eId][iType][oldSlot] and type(cache[eType][eId][iType][oldSlot][1]) == "number" and cache[eType][eId][iType][oldSlot][1] == oData[1] and cache[eType][eId][iType][newSlot] and type(cache[eType][eId][iType][newSlot][1]) == "number" and cache[eType][eId][iType][newSlot][1] == oData2[1] then
        checkTableArray(eType, eId, iType)
        checkTableArray(eType, eId, iType, newSlot)
        checkTableArray(eType, eId, iType, oldSlot)
        
        local oData = cache[eType][eId][iType][oldSlot]
        local oData2 = cache[eType][eId][iType][newSlot]
        cache[eType][eId][iType][newSlot] = oData
        cache[eType][eId][iType][oldSlot] = oData2
        
        if sourceElement:getData("usingRadio") then
            if tonumber(sourceElement:getData("usingRadio.slot") or 0) == oldSlot then
                sourceElement:setData("usingRadio.slot", newSlot)
            end
        end
        
        --[[
        if iType == 10 then
            local value = toJSON(cache[eType][eId][iType][newSlot])
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=? AND `elementtype`=? AND `elementid`=? AND `value`=? AND `slot`=?", newSlot, iType, eType, eId, value, oldSlot)
        else]]
        
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(oData)
        dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)
        
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(oData2)
        dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", oldSlot, id)
        --[[
        if sourceElement.type == "player" then
            local toName = exports['cr_admin']:getAdminName(sourceElement)
            exports['cr_logs']:addLog("Inventory", "updateSlot.player", exports['cr_core']:getTime() .. " " .. "Item slot módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][newSlot]).." (Slot: "..newSlot..") (Régi slot: "..oldSlot..")")
        else
            local toName = sourceElement.type.. "("..getEID(sourceElement)..")"
            exports['cr_logs']:addLog("Inventory", "updateSlot.element", exports['cr_core']:getTime() .. " " .. "Item slot módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][newSlot]).." (Slot: "..newSlot..") (Régi slot: "..oldSlot..")")
        end
        --end]]
    end
    
    needValue(sourceElement, "items", sourceElement)
end

addEvent("changeSlot", true)
addEventHandler("changeSlot", root,
    function(sourceElement, oldSlot, newSlot, iType, oData, oData2)
        --if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                changeSlot(sourceElement, oldSlot, newSlot, iType, oData, oData2)
            --end
        --end
    end
)

spamTimers["updateSlot"] = {}

function updateSlot(sourceElement, oldSlot, newSlot, iType, oData)
    --[[
    local lastClickTick = spamTimers["updateSlot"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["updateSlot"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    --outputChatBox(eType)
    --outputChatBox(eId)
    --outputChatBox(iType)
    --outputChatBox(oldSlot)
    --outputChatBox(newSlot)
    
    --oData[9] = nil
    --oData[10] = nil
    
    --outputChatBox(inspect(cache[eType][eId][iType][oldSlot]))
    --outputChatBox(inspect(oData))
    --outputChatBox(tostring(cache[eType][eId][iType][oldSlot] == oData))
    if cache[eType][eId][iType][oldSlot] and type(cache[eType][eId][iType][oldSlot][1]) == "number" and cache[eType][eId][iType][oldSlot][1] == oData[1] and not cache[eType][eId][iType][newSlot] then
        checkTableArray(eType, eId, iType)
        checkTableArray(eType, eId, iType, newSlot)
        checkTableArray(eType, eId, iType, oldSlot)
        
        cache[eType][eId][iType][newSlot] = cache[eType][eId][iType][oldSlot]
        cache[eType][eId][iType][oldSlot] = nil
        
        if sourceElement:getData("usingRadio") then
            if tonumber(sourceElement:getData("usingRadio.slot") or 0) == oldSlot then
                sourceElement:setData("usingRadio.slot", newSlot)
            end
        end
        
        --[[
        if iType == 10 then
            local value = toJSON(cache[eType][eId][iType][newSlot])
            dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=? AND `elementtype`=? AND `elementid`=? AND `value`=? AND `slot`=?", newSlot, iType, eType, eId, value, oldSlot)
        else]]
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][newSlot])
        dbExec(connection, "UPDATE `items` SET `slot`=? WHERE `id`=?", newSlot, id)
        --[[
        if sourceElement.type == "player" then
            local toName = exports['cr_admin']:getAdminName(sourceElement)
            exports['cr_logs']:addLog("Inventory", "updateSlot.player", exports['cr_core']:getTime() .. " " .. "Item slot módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][newSlot]).." (Slot: "..newSlot..") (Régi slot: "..oldSlot..")")
        else
            local toName = sourceElement.type.. "("..getEID(sourceElement)..")"
            exports['cr_logs']:addLog("Inventory", "updateSlot.element", exports['cr_core']:getTime() .. " " .. "Item slot módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][newSlot]).." (Slot: "..newSlot..") (Régi slot: "..oldSlot..")")
        end
        --end]]
    end
    
    needValue(sourceElement, "items", sourceElement)
end

addEvent("updateSlot", true)
addEventHandler("updateSlot", root,
    function(sourceElement, oldSlot, newSlot, iType, oData)
        --if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                updateSlot(sourceElement, oldSlot, newSlot, iType, oData)
            --end
        --end
    end
)

spamTimers["countUpdate"] = {}

function countUpdate(sourceElement, slot, iType, newCount, ignoreTrigger)
    --[[
    local lastClickTick = spamTimers["countUpdate"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["countUpdate"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])
    
    if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
        
        checkTableArray(eType, eId, iType, slot)
        
        local oldCount = cache[eType][eId][iType][slot][4]
        cache[eType][eId][iType][slot] = {id, itemid, value, newCount, status, dutyitem, premium, nbt}

        dbExec(connection, "UPDATE `items` SET `count`=? WHERE `id`=?", newCount, id)
        
        --[[
        if sourceElement.type == "player" then
            local toName = exports['cr_admin']:getAdminName(sourceElement)
            exports['cr_logs']:addLog("Inventory", "countUpdate.player", exports['cr_core']:getTime() .. " " .. "Item darabszám módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..") (Régi darabszám: "..oldCount..")")
        else
            local toName = sourceElement.type.. "("..getEID(sourceElement)..")"
            exports['cr_logs']:addLog("Inventory", "countUpdate.element", exports['cr_core']:getTime() .. " " .. "Item darabszám módosítás: "..toName.."nak: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..") (Régi darabszám: "..oldCount..")")
        end]]
    end
    
    if not ignoreTrigger then
        needValue(sourceElement, "items", sourceElement, "count")
    end
end

addEvent("countUpdate", true)
addEventHandler("countUpdate", root,
    function(sourceElement, slot, iType, newCount, ignoreTrigger)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                countUpdate(sourceElement, slot, iType, newCount, ignoreTrigger)
            --end
        end
    end
)

spamTimers["acValueUpdate"] = {}

function acValueUpdate(sourceElement, slot, iType, newValue)
    --[[
    local lastClickTick = spamTimers["acValueUpdate"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["acValueUpdate"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    checkTableArray(eType, eId, iType, slot)

    local oldValue = cache[eType][eId][iType][slot]
    local id = oldValue[3]
    newValue[3] = oldValue[3]
    cache[eType][eId][iType][slot] = newValue

    dbExec(connection, "UPDATE `items` SET `value`=? WHERE `id`=?", toJSON(newValue), id)
end

addEvent("ac.valueUpdate", true)
addEventHandler("ac.valueUpdate", root,
    function(sourceElement, slot, iType, newValue)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                acValueUpdate(sourceElement, slot, iType, newValue)
            end
        end
    end
)

spamTimers["removeItemFromSlot"] = {}

function removeItemFromSlot(sourceElement, slot, iType, ignoreTrigger)
    --[[
    local lastClickTick = spamTimers["removeItemFromSlot"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["removeItemFromSlot"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    --outputChatBox("ITYPE:" .. iType)
    --outputChatBox("ETYPE:" .. eType)
    --outputChatBox("EID:" .. eType)
    
    checkTableArray(eType, eId, iType)
    
    if iType == 10 then
        local value = cache[eType][eId][iType][slot]
        local id = value[3]
        cache[eType][eId][iType][slot] = nil

        --outputChatBox("value:" .. value)
        --outputChatBox("SLOT:" .. slot)

        dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
    else
        if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(cache[eType][eId][iType][slot])

            --outputChatBox("ITEMID:" .. itemid)
            --outputChatBox("SLOT:" .. slot)
            
            if sourceElement.type == "player" then
                if itemid == 19 then
                    if sourceElement:getData("usingRadio") then
                        if tonumber(sourceElement:getData("usingRadio.slot") or 0) == slot then
                            sourceElement:setData("usingRadio", false)
                        end
                    end
                end
                
                if isWeapon(itemid) then
                    triggerClientEvent(sourceElement, "deAttachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, true))
                end
            end
            
            --[[
            if sourceElement.type == "player" then
                local toName = exports['cr_admin']:getAdminName(sourceElement)
                exports['cr_logs']:addLog("Inventory", "removeItemFromSlot.player", exports['cr_core']:getTime() .. " " .. "Item törlés (slotról): "..toName.."nak: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..")")
            else
                local toName = sourceElement.type.. "("..getEID(sourceElement)..")"
                exports['cr_logs']:addLog("Inventory", "removeItemFromSlot.element", exports['cr_core']:getTime() .. " " .. "Item törlés (slotról): "..toName.."nak: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..")")
            end]]
            
            for i = 1, 10 do
                if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                    local invType, slot2, id = unpack(cache[eType][eId][10][i])

                    if invType == iType then
                        if slot == slot2 then
                            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                            cache[eType][eId][10][i] = nil
                        end
                    end
                end
            end
            
            cache[eType][eId][iType][slot] = nil
            
            if checkItemsInGiveCache(sourceElement, iType) then
                setTimer(giveOneItemFromGiveCache, 1000, 1, sourceElement, iType)
            end

            dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
        end
    end
    
    if not ignoreTrigger then
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("removeItemFromSlot", true)
addEventHandler("removeItemFromSlot", root,
    function(sourceElement, slot, iType, ignoreTrigger)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                removeItemFromSlot(sourceElement, slot, iType, ignoreTrigger)
            --end
        end
    end
)

spamTimers["addItemToSlot"] = {}

function addItemToSlot(sourceElement, slot, iType, details, ignoreTrigger)
    --[[
    local lastClickTick = spamTimers["addItemToSlot"][sourceElement] or 0
    if lastClickTick + 100 > getTickCount() then
        return
    end
    
    spamTimers["addItemToSlot"][sourceElement] = getTickCount()
    ]]
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)

    checkTableArray(eType, eId, iType, slot)
    
    --outputChatBox("ITYPE: "..iType)
    cache[eType][eId][iType][slot] = details
    
    if iType ~= 10 then
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(details)

        --outputChatBox("ITYPE:" .. iType)
        --outputChatBox("ETYPE:" .. eType)
        --outputChatBox("EID:" .. eType)
        --outputChatBox("ITEMID:" .. itemid)
        --[[outputChatBox("SLOT:" .. slot)
        
        
        if sourceElement.type == "player" then
            local toName = exports['cr_admin']:getAdminName(sourceElement)
            exports['cr_logs']:addLog("Inventory", "addItemToSlot.player", exports['cr_core']:getTime() .. " " .. "Item adás (slotra): "..toName.."nak: "..toJSON(details).." (Slot: "..slot..")")
            if isWeapon(itemid) then
                triggerClientEvent(sourceElement, "attachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, true), value)
            end
        else
            local toName = sourceElement.type.. "("..getEID(sourceElement)..")"
            exports['cr_logs']:addLog("Inventory", "addItemToSlot.element", exports['cr_core']:getTime() .. " " .. "Item adás (slotra): "..toName.."nak: "..toJSON(details).." (Slot: "..slot..")")
        end]]

        dbExec(connection, "INSERT INTO `items` SET `status`=?, `dutyitem`=?, `count`=?,`value`=?,`itemid`=?,`premium`=?,`nbt`=?,`itemtype`=?,`elementtype`=?,`elementid`=?,`slot`=?", status, dutyitem, count, value, itemid, premium, nbt, iType, eType, eId, slot)
        
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            cache[eType][eId][iType][slot][1] = id
                            
                            --[[outputChatBox(tostring(oldID))
                            if oldID then
                                local _id = id
                                local id = tonumber(oldID)
                                cache[eType][eId][iType][slot][1] = id

                                dbExec(connection, "UPDATE `items` SET `id`=? WHERE `id`=?", id, _id)
                            end]]
                            needValue(sourceElement, "items", sourceElement)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `items` WHERE `elementtype`=? AND `elementid`=? AND `itemtype`=? AND `slot`=?", eType, eId, iType, slot)
    else
        local value = toJSON(details)
        --outputChatBox("VALUE: ".. value)
        dbExec(connection, "INSERT INTO `items` SET `value`=?,`itemtype`=?,`elementtype`=?,`elementid`=?,`slot`=?", value, iType, eType, eId, slot)
        
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            cache[eType][eId][iType][slot][3] = id
                            
                            --outputChatBox(tostring(oldID))
                            if oldID then
                                local _id = id
                                local id = tonumber(oldID)
                                cache[eType][eId][iType][slot][3] = id

                                dbExec(connection, "UPDATE `items` SET `id`=? WHERE `id`=?", id, _id)
                            end
                            needValue(sourceElement, "items", sourceElement)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `items` WHERE `value`=? AND `itemtype`=? AND `elementtype`=? AND `elementid`=? AND `slot`=?", value, iType, eType, eId, slot)
    end
    
    if not ignoreTrigger then
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("addItemToSlot", true)
addEventHandler("addItemToSlot", root,
    function(sourceElement, slot, iType, details, ignoreTrigger)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                addItemToSlot(sourceElement, slot, iType, details, ignoreTrigger)
            --end
        end
    end
)

local execTable = {}

function updateStatus(sourceElement, slot, newStatus, invType)   
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    local iType = invType or 1

    checkTableArray(eType, eId, iType, slot)
    if cache[eType][eId][iType][slot] and type(cache[eType][eId][iType][slot][1]) == "number" then
        cache[eType][eId][iType][slot][5] = newStatus

        local dbid = cache[eType][eId][iType][slot][1]
        table.insert(execTable, {"UPDATE `items` SET `status`=? WHERE `id`=?", {newStatus, dbid}})
        
        -- Lehet ezzel a fossal lesz probléma szóval teszteljétek majd
    else
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("updateStatus", true)
addEventHandler("updateStatus", root,
    function(sourceElement, slot, newStatus, invType)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                updateStatus(sourceElement, slot, newStatus, invType)
            --end
        end
    end
)

function doExec()
    local count = #execTable
    local tick = getTickCount()
    for k,v in pairs(execTable) do
        local text, variables = unpack(v)
        dbExec(connection, text, unpack(variables))
        table.remove(execTable, k)
    end
    collectgarbage("collect")
    outputDebugString("Finished #"..count.." dbExec in "..(getTickCount()-tick).." ms!", 0, 255, 50, 255)
end
setTimer(doExec, 10 * 60 * 1000, 0)
addEventHandler("onResourceStop", resourceRoot, doExec)

spamTimers["transportItem"] = {}

addEvent("transportItem", true)
addEventHandler("transportItem", root,
    function(sourceElement, from, to, fromiType, toiType, itemDetails, oldSlot)
        --[[
        local lastClickTick = spamTimers["transportItem"][sourceElement] or 0
        if lastClickTick + 100 > getTickCount() then
            return
        end

        spamTimers["transportItem"][sourceElement] = getTickCount()
        ]]
        
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(itemDetails)
        
        local eType = getEType(from)
        local eId = getEID(from)
        checkTableArray(eType, eId, fromiType)
        if cache[eType][eId][fromiType][oldSlot] and cache[eType][eId][fromiType][oldSlot][1] == id then
            --local iType = items[itemid][2]

            --outputChatBox("toiType: "..toiType)
            --outputChatBox("fromiType: "..fromiType)
            --outputChatBox("itemDetails: "..toJSON(itemDetails))
            --outputChatBox("oldSlot: "..oldSlot)
            --outputChatBox("itemid: "..itemid)
            
            local nowWeight = getWeight(to, toiType)
            local addWeight = items[itemid][3] * count 
            local maxWeight = typeDetails[toiType][2]

            if nowWeight + addWeight > maxWeight then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
                outputChatBox(syntax .. "Nem tudod átadni ezt a tárgyat mert nincs elég hely a célpontnál", from, 255,255,255,true)
                needValue(sourceElement, "items", from)
                return
            end

            local freeSlot = getFreeSlot(to, toiType)

            if not freeSlot then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
                outputChatBox(syntax .. "Nem tudod átadni ezt a tárgyat mert nincs elég hely (üres slot) a célpontnál", from, 255,255,255,true)
                needValue(sourceElement, "items", from)
                return
--                addItemToGiveCache(sourceElement, {to, freeSlot, toiType, itemDetails, itemDetails[1]}, "addItemToSlot")
            end
            
            if from.type == "player" then
                if isWeapon(itemid) then
                    triggerClientEvent(from, "deAttachWeapon", from, from, convertIdToWeapon(itemid, true))
                end
            end
            
            if to.type == "player" then
                if isWeapon(itemid) then
                    triggerClientEvent(to, "attachWeapon", to, to, convertIdToWeapon(itemid, true), value)
                end
            end

            if from.type == "player" then
                local data = cache[1][from:getData("acc >> id")][10]
                --outputDebugString(toJSON(data))
                for i2 = 1, 9 do
                    --outputDebugString("I2"..i2)
                    if data then
                        --outputDebugString("Data:"..toJSON(data))
                        local data = data[i2]
                        if data then
                            --outputDebugString("Data2:"..toJSON(data))
                            local invType, pairSlot = unpack(data)
                            local data = cache[1][from:getData("acc >> id")][invType][pairSlot]
                            if pairSlot == oldSlot then
                                removeItemFromSlot(sourceElement, i2, 10, true)
                                cache[1][from:getData("acc >> id")][10][i2] = nil
                            end
                        end
                    end
                end
            end

            --removeItemFromSlot(from, oldSlot, fromiType)
            --addItemToSlot(to, freeSlot, toiType, itemDetails)
            
            local eType = getEType(from)
            local eId = getEID(from)

            --outputChatBox("ITYPE:" .. iType)
            --outputChatBox("ETYPE:" .. eType)
            --outputChatBox("EID:" .. eType)

            checkTableArray(eType, eId, fromiType)
            if cache[eType][eId][fromiType][oldSlot] and type(cache[eType][eId][fromiType][oldSlot][1]) == "number" then
                for i = 1, 10 do
                    if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                        local invType, slot2, id = unpack(cache[eType][eId][10][i])

                        if invType == fromiType then
                            if oldSlot == slot2 then
                                dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                                cache[eType][eId][10][i] = nil
                            end
                        end
                    end
                end

                cache[eType][eId][fromiType][oldSlot] = nil

                if checkItemsInGiveCache(from, fromiType) then
                    setTimer(giveOneItemFromGiveCache, 1000, 1, from, fromiType)
                end
                
                local eType = getEType(to)
                local eId = getEID(to)
                local iType = toiType
                local slot = freeSlot

                checkTableArray(eType, eId, iType, slot)

                --outputChatBox("ITYPE: "..iType)
                cache[eType][eId][iType][slot] = itemDetails
                local id = itemDetails[1]
                dbExec(connection, "UPDATE `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `slot`=? WHERE `id`=?", eType, eId, iType, slot, id)
            end

            setPedAnimation(from,"DEALER","DEALER_DEAL",3000,false,false,false,false)
            setPedAnimation(to,"DEALER","DEALER_DEAL",3000,false,false,false,false)
        end
        
        if to.type == "player" and from.type == "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.player-to-player", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        elseif to.type == "player" and from.type ~= "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.model-to-player", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        elseif from.type == "player" and to.type ~= "player" then
            local eId = getEID(from)
            local eId2 = getEID(to)
            exports['cr_logs']:addLog(from, "Inventory", "transportitem.player-to-object", "Item átadás: "..eId.."tól "..eId2.."hez: "..toJSON(itemDetails))
        end
        
        needValue(from, "items", to)
        needValue(from, "items", from)
        
        needValue(to, "items", to)
        needValue(to, "items", from)
        
        --[[
        needValue(sourceElement, "items", to)
        needValue(sourceElement, "items", from)
        
        if to.type == "player" then
            needValue(to, "items", from)
            needValue(to, "items", to)
        else
            local invE = to:getData("inventory.open")
            if invE and isElement(invE) and invE.type == "player" then
                needValue(invE, "items", from)
                needValue(invE, "items", to)
            end
            
            local invE = to:getData("inventory.open2")
            if invE and isElement(invE) and invE.type == "player" then
                needValue(invE, "items", from)
                needValue(invE, "items", to)
            end
        end]]
    end
)

addEventHandler("onElementDataChange", root,
    function(dName, oValue)
        if dName == "veh >> boot" then
            if source.type == "vehicle" then
                local value = source:getData(dName)
                if value then
                    source:setDoorOpenRatio(1, 1, 450)
                else
                    source:setDoorOpenRatio(1, 0, 450)
                end
            end
        elseif dName == "inventory.open" then
            if source.type == "object" then
                local value = source:getData(dName)
                if value then
                    --outputChatBox("1829re Change")
                    --setElementModel(source, 1829)
                    --source.model = 1829
                else
                    --outputChatBox("1829re Vissza")
                    --setElementModel(source, 2332)
                    --source.model = 2332
                end
            end
        end
    end
)

function addItemToGiveCache(sourceElement, details, type)
    local _sourceElement = sourceElement
    local sourceElement = sourceElement:getData("acc >> id")
    if not sourceElement then return end
    if not giveCache[sourceElement] then
        giveCache[sourceElement] = {}
    end
    
    local iType
    if type == "giveItem" then
        iType = items[details[1]][2]
    end
    
    if not giveCache[sourceElement][iType] then
        giveCache[sourceElement][iType] = {}
    end
    --table.insert(giveCache[sourceElement][iType], tble)
    
    local tble = details
    tble["type"] = type
    
    --{itemid, value, count, status, dutyitem, premium, nbt}, "giveItem"
    
    local time = getRealTime()["timestamp"]
    local jsontble = toJSON(tble)
    dbExec(connection, "INSERT INTO `items_givecache` SET `ownerid`=?, `data`=?, `iType`=?, `time`=?", sourceElement, jsontble, iType, (time))
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        tble["id"] = id
                        table.insert(giveCache[sourceElement][iType], tble)
                        
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Mivel nincs elég slot az inventorydban ezért várólistára került a neked adni kivánt tárgy!")
                        exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[sourceElement][iType].." tárgy van várólistán")
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `items_givecache` WHERE `ownerid`=? AND `data`=? AND `iType`=? AND `time`=?", sourceElement, jsontble, iType, (time))
end

function checkItemsInGiveCache(sourceElement, iType)
    local _sourceElement = sourceElement
    local sourceElement = sourceElement:getData("acc >> id")
    if not sourceElement then return end
    if giveCache[sourceElement] and giveCache[sourceElement][iType] and #giveCache[sourceElement][iType] >= 1 then
        return true
    else
        return false
    end
end

function giveOneItemFromGiveCache(sourceElement, iType)
    if checkItemsInGiveCache(sourceElement, iType) then
        local _sourceElement = sourceElement
        local sourceElement = sourceElement:getData("acc >> id")
        --if not sourceElement then return end    
        local details = giveCache[sourceElement][iType][1]
        local typ = details["type"]
        local id = details["id"]
        details["type"] = nil
        details["id"] = nil
        --outputChatBox(sourceElement)
        --outputChatBox(typ)
        --outputChatBox(inspect(_sourceElement))
        --outputChatBox(inspect(details))
        if typ == "giveItem" then
            local freeSlot = getFreeSlot(_sourceElement, iType)
            if freeSlot then
                dbExec(connection, "DELETE FROM `items_givecache` WHERE `id`=?", id)
                table.remove(giveCache[sourceElement][iType], 1)
                giveItem(_sourceElement, unpack(details))
                exports['cr_infobox']:addBox(_sourceElement, "info", "Mivel felszabadult egy slot az inventorydban ezért sikerült odaadni a várólistán lévő tárgyat!")
                exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[sourceElement][iType].." tárgy van várólistán")
                return true
            end
        elseif typ == "addItemToSlot" then
            local freeSlot = getFreeSlot(_sourceElement, iType)
            if freeSlot then
                table.remove(giveCache[sourceElement][iType], 1)
                addItemToSlot(unpack(details))
                exports['cr_infobox']:addBox(_sourceElement, "info", "Mivel felszabadult egy slot az inventorydban ezért sikerült odaadni a várólistán lévő tárgyat!")
                exports['cr_infobox']:addBox(_sourceElement, "warning", "Jelenleg a(z) "..typeDetails[iType][1].." típusnál "..#giveCache[sourceElement][iType].." tárgy van várólistán")
                return true
            end
        end
    end
    
    return false
end

spamTimers["giveItem"] = {}

function giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
    --[[local lastClickTick = spamTimers["giveItem"][sourceElement] or 0
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    spamTimers["giveItem"][sourceElement] = getTickCount()
    --]]
    
    --iprint(value)
    if not tonumber(itemid) then itemid = 1 end
    if not value then value = 1 end
    if not tonumber(count) then count = 1 end
    if not tonumber(status) then status = 100 end
    if not tonumber(dutyitem) then dutyitem = 0 end
    if not tonumber(premium) then premium = 0 end
    if not nbt then nbt = 0 end
    
    itemid = tonumber(itemid)
    if tonumber(value) then 
        value = tonumber(value) 
    end
    count = tonumber(count)
    status = tonumber(status)
    dutyitem = tonumber(dutyitem)
    premium = tonumber(premium)
    if tonumber(nbt) then 
        nbt = tonumber(nbt) 
    end
    
    --outputChatBox(itemid)
    --iprint({itemid, value, count, status, dutyitem, premium, nbt, update})
    
    local iType = items[itemid][2]
    local nowWeight = getWeight(sourceElement, iType)
    local addWeight = items[itemid][3] * count 
    local maxWeight = typeDetails[iType][2]
    
    if nowWeight + addWeight > maxWeight then
        local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        outputChatBox(syntax .. "Nem tudod átadni ezt a tárgyat mert nincs elég hely a célpontnál", sourceElement, 255,255,255,true)
        return
    end
    
    local freeSlot = getFreeSlot(sourceElement, iType)
        
    if not freeSlot then
        --local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        --outputChatBox(syntax .. "Nem tudod átadni ezt a tárgyat mert nincs elég hely (üres slot) a célpontnál", sourceElement, 255,255,255,true)
        
        addItemToGiveCache(sourceElement, {itemid, value, count, status, dutyitem, premium, nbt}, "giveItem")
        return
    end
    
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    checkTableArray(eType, eId, iType, slot)
    cache[eType][eId][iType][freeSlot] = {-1, itemid, value, count, status, dutyitem, premium, nbt}
    
    --outputChatBox(premium)
    if tonumber(value) then
        value = tonumber(value)
    elseif toJSON(value) then
        value = toJSON(value)
    end
    
    if tonumber(nbt) then
        nbt = tonumber(nbt)
    elseif toJSON(nbt) then
        nbt = toJSON(nbt)
    end
    
    --outputChatBox("A"..tostring(value))
    --outputChatBox("A"..tostring(nbt))
    dbExec(connection, "INSERT INTO `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `itemid`=?, `slot`=?, `value`=?, `count`=?, `status`=?, `dutyitem`=?, `premium`=?, `nbt`=?", eType, eId, iType, itemid, freeSlot, value, count, status, dutyitem, premium, nbt)
    
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local eType = tonumber(row["elementtype"])
                        local eId = tonumber(row["elementid"])
                        local iType = tonumber(row["itemtype"])
                        local itemid = tonumber(row["itemid"])    
                        local slot = tonumber(row["slot"])    
                        local value = tostring(row["value"])
                        local status = tonumber(row["status"])
                        local count = tonumber(row["count"])    
                        local dutyitem = tonumber(row["dutyitem"])
                        local premium = tonumber(row["premium"])
                        local nbt = tostring(row["nbt"])
                        
                        checkTableArray(eType, eId, iType, slot)
                        
                        if iType == 10 then
                            cache[eType][eId][iType][slot] = fromJSON(value)
                        else
                            if tonumber(value) then
                                value = tonumber(value)
                            elseif fromJSON(value) then
                                value = fromJSON(value)
                            end
                            
                            if tonumber(nbt) then
                                nbt = tonumber(nbt)
                            elseif fromJSON(nbt) then
                                nbt = fromJSON(nbt)    
                            end
                            
                            --outputChatBox(tostring(value))
                            --outputChatBox(tostring(nbt))
                            cache[eType][eId][iType][slot] = {id, itemid, value, count, status, dutyitem, premium, nbt}
                            exports['cr_logs']:addLog(sourceElement, "Inventory", "giveitem", "Item adás: "..toJSON(cache[eType][eId][iType][slot]).." (Slot: "..slot..")")
                            
                            if sourceElement.type == "player" then
                                if isWeapon(itemid) then
                                    triggerClientEvent(sourceElement, "attachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, true), value)
                                end
                            end
                        end
                        
                        needValue(sourceElement, "items", sourceElement)
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `items` WHERE `elementtype`=? AND `elementid`=? AND `itemtype`=? AND `slot`=?", eType, eId, iType, freeSlot)
end

function giveItemCMD(sourceElement, cmd, who, itemid, value, count, status, dutyitem, premium, nbt)
    if exports['cr_permission']:hasPermission(sourceElement, "giveitem") then
        if not itemid or not who then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/giveitem [who] [itemid] [érték] [darab] [státusz] [dutyitem (1 = Igen, 0 = Nem)] [premium (1 = Igen, 0 = Nem)] [nbt]", sourceElement, 255,255,255,true)
            return
        end
        
        local who = exports['cr_core']:findPlayer(sourceElement, who)
        
        if who then
            itemid = tonumber(itemid)
            local id = getElementData(who, "char >> name"):gsub("_", " ")
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen adtál "..green..id..white.."nak/nek egy tárgyat! ("..green..getItemName(itemid, value, nbt)..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." adott "..green..id..white.."nak/nek egy tárgyat! ("..green..getItemName(itemid, value, nbt)..white..")", 3)
            
            exports['cr_logs']:addLog(sourceElement, "Inventory", "giveitemCMD", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " adott "..(tonumber(getElementData(who, "acc >> id")) or inspect(who)).."nak/nek egy tárgyat! ("..getItemName(itemid, value, nbt)..")")
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local text = syntax .. green .. aName .. white .. " adott neked egy tárgyat ("..green..getItemName(itemid, value, nbt)..white..")"
            outputChatBox(text, who, 255,255,255,true)
            giveItem(who, itemid, value, count, status, dutyitem, premium, nbt, true)
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "Hibás Név/ID!", sourceElement, 255,255,255,true)
        end
    end
end
addCommandHandler("giveitem", giveItemCMD)

addEvent("giveItem", true)
addEventHandler("giveItem", root,
    function(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                giveItem(sourceElement, itemid, value, count, status, dutyitem, true)
            --end
        end
    end
)

function getItems(element, invType)
    local eType = getEType(element)
    local eId = getEID(element)
    checkTableArray(eType, eId, invType)

    return cache[eType][eId][invType]
end

function hasItem(element, itemID, itemValue)
    if itemValue then
        for i = 1, 3 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if itemid == itemID and value == itemValue then
                    return true, slot, data
                end
            end
        end
        
        return false
    else
        for i = 1, 3 do
            local items = getItems(element, i)
            for slot, data in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                if itemid == itemID then
                    return true, slot, data
                end
            end
        end
        
        return false
    end
end

--[[

addCommandHandler("giveItm100", 
    function()
        --local count = 0
        for i = 1, 200000 do
            dbExec(connection, "INSERT INTO `items` SET `elementtype`=?, `elementid`=?, `itemtype`=?, `slot`=?, `value`=?, `count`=?, `status`=?, `dutyitem`=?", math.random(1,3), math.random(1,10000000), math.random(1,3), math.random(1,100), 1, 1, 100, 0)
            --count = count + 1
            --outputDebugString("Kész"..count)
        end
        --outputDebugString("Kész FULLRA: "..count)
    end
)

--]]

spamTimers["deleteItem"] = {}

function deleteItem(sourceElement, slot, itemid)
    --[[local lastClickTick = spamTimers["deleteItem"][sourceElement] or 0
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    spamTimers["deleteItem"][sourceElement] = getTickCount()
    --]]
    
    local iType = items[itemid][2]
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    --outputChatBox(eType)
    --outputChatBox(eId)
    --outputChatBox(iType)
    --outputChatBox(slot)
    
    --checkTableArray(eType, eId, iType, slot)
    --checkTableArray(eType, eId, 10)
    
    local data = cache[eType][eId][iType][slot]
    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
    cache[eType][eId][iType][slot] = nil
    
    if checkItemsInGiveCache(sourceElement, iType) then
        setTimer(giveOneItemFromGiveCache, 1000, 1, sourceElement, iType)
    end
    
    dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
    exports['cr_logs']:addLog(sourceElement, "Inventory", "deleteitem", "Item törlés: "..toJSON(data).." (Slot: "..slot..")")
    
    if sourceElement.type == "player" then
        --ActionbarCheck
        
        for i = 1, 10 do
            if cache[eType][eId][10] and cache[eType][eId][10][i] then 
                local invType, slot2, id = unpack(cache[eType][eId][10][i])

                if invType == iType then
                    if slot == slot2 then
                        dbExec(connection, "DELETE FROM `items` WHERE `id`=?", id)
                        cache[eType][eId][10][i] = nil
                    end
                end
            end
        end
        
        if isWeapon(itemid) then
            triggerClientEvent(sourceElement, "deAttachWeapon", sourceElement, sourceElement, convertIdToWeapon(itemid, true))
        end
        
        needValue(sourceElement, "items", sourceElement)
    end
end

addEvent("deleteItem", true)
addEventHandler("deleteItem", root,
    function(sourceElement, slot, itemid)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                deleteItem(sourceElement, slot, itemid)
            --end
        end
    end
)

local compileDetails = {
    ["id"] = {"id", 1},
    ["itemid"] = {"itemid", 2},
    ["value"] = {"value", 3},
    ["count"] = {"count", 4},
    ["status"] = {"status", 5},
    ["dutyitem"] = {"dutyitem", 6},
    ["premium"] = {"premium", 7},
    ["nbt"] = {"nbt", 8},
}

function updateItemDetails(sourceElement, slot, iType, details)
    local eType = getEType(sourceElement)
    local eId = getEID(sourceElement)
    
    --outputChatBox(eType)
    --outputChatBox(eId)
    --outputChatBox(iType)
    --outputChatBox(slot)
    
    --checkTableArray(eType, eId, iType, slot)
    --checkTableArray(eType, eId, 10)
    
    local name, number = unpack(compileDetails[details[1]])
    local newValue = details[2]
    local data = cache[eType][eId][iType][slot]
    
    if data then
        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
        cache[eType][eId][iType][slot][number] = newValue
        if number == 3 or number == 8 then
            if tonumber(newValue) then
                newValue = tonumber(newValue)
            elseif toJSON(newValue) then
                newValue = toJSON(newValue)
            end
        end
        table.insert(execTable, {"UPDATE `items` SET `"..name.."`=? WHERE `id`=?", {newValue, id}})
    end
end

addEvent("updateItemDetails", true)
addEventHandler("updateItemDetails", root,
    function(sourceElement, slot, iType, details)
        if client and client.type == "player" then
            --if sourceElement and sourceElement.type == "player" and sourceElement == client then
                updateItemDetails(sourceElement, slot, iType, details)
            --end
        end
    end
)