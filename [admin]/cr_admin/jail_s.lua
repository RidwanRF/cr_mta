connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

addEvent("preparePlayerToJail",true)
addEventHandler("preparePlayerToJail",root,
    function (target)
    	if getPedOccupiedVehicle(target) then
            removePedFromVehicle(target)
        end
        detachElements(target)
        setElementPosition(target,2496.049804,-1695.238159,1014.742187)
        setElementInterior(target,3)
        setCameraInterior(target,3)
        setElementDimension(target,getElementData(target,"acc >> id"))
    end
)

addEvent("releasePlayer",true)
addEventHandler("releasePlayer",root,
    function (target)
        setElementPosition(target,1468.4044189453, -1718.8636474609, 14.046875)
        setElementInterior(target,0)
        setCameraInterior(target,0)
        setElementDimension(target,0)
    end
)
    
addEvent("vehCheck",true)
addEventHandler("vehCheck",root,
    function (target)
        target.vehicle = nil
        detachElements(target)
    end
)

addEvent("saveLog",true)
addEventHandler("saveLog",root,
    function (target)
        local acc_id = getElementData(target,"acc >> id")
	    local reason = getElementData(target,"char >> ajail >> reason")
	    local admin = getElementData(target,"char >> ajail >> admin")
	    local time = getElementData(target,"char >> ajail >> time")
	    if acc_id and reason and admin and time then
	        local exec = dbExec(connection, "INSERT INTO `jail_log` SET `account_id` = ?, `reason` = ?, `admin` = ?, `time` = ?", acc_id, reason, admin, time)
	    end
    end
)

addEvent("offJailed",true)
addEventHandler("offJailed",root,
    function (id,p)
        if not tonumber(id) and tostring(id) then
            local playerID, characterData = exports['cr_account']:getPlayerDatasByName(tostring(id))
            if playerID and characterData then
                local ajail = fromJSON(characterData[7][5])
                if ajail and #ajail > 0 then
                    if ajail[1] and type(ajail[1]) == "boolean" then
                        ajail[6] = tostring(id) --tostring(row["charname"])
                        triggerClientEvent(p,"returnOffjailed",p,ajail)
                        --exports['cr_account']:updatePlayerJailDatas(playerID, {})
                        return
                    end
                end

                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "A célpont nincs adminjailben!", p, 255,255,255,true)
                return
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs ilyen játékos!", p, 255,255,255,true)
                return
            end
        end
    end
)

white = "#ffffff"

addEvent("offJail",true)
addEventHandler("offJail",root,
    function (p,id,value,typ)
        --outputChatBox(id)
        if not tonumber(id) and tostring(id) then
            --outputChatBox("asd")
            local value_cache = fromJSON(value)
            local playerName = tostring(id)
            local playerID, characterData = exports['cr_account']:getPlayerDatasByName(tostring(id))
            --outputChatBox(playerID)
            if playerID and characterData then
                local ajail = fromJSON(characterData[7][5])
                --outputChatBox(characterData[7][5])
                --outputChatBox(#ajail)
                if ajail and #ajail > 0 then -- jail
                    --outputChatBox(type(ajail[1]))
                    --outputChatBox(tostring(ajail[1]))
                    if ajail[1] and type(ajail[1]) == "boolean" then
                        --outputChatBox("asd")
                        if typ == "unjail" then -- unjail
                            if tonumber(ajail[6] or 0) <= p:getData("admin >> level") then
                                exports['cr_account']:updatePlayerJailDatas(playerID, value_cache)
                                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                                outputChatBox(syntax .. "Sikeresen kiszedve börtönből!", p, 255,255,255,true)
                                return
                            else
                                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                                outputChatBox(syntax .. "Nincs meg a megfelelő adminszinted ahhoz, hogy ezt a playert kiszed börtönből!", p, 255,255,255,true)
                                return
                            end
                        else -- jail
                            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                            outputChatBox(syntax .. "Már börtönben van!", p, 255,255,255,true)
                            return
                        end
                    else
                        if typ == "unjail" then
                            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                            outputChatBox(syntax .. "Nincs börtönben!", p, 255,255,255,true)
                            return
                        else
                            local tALevel = tonumber(characterData[7][1] or 0)
                            local pALevel = p:getData("admin >> level") 
                            
                            if tALevel >= pALevel then
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                outputChatBox(syntax .. "Magadnál csak kisebb admint jailezhetsz!", p, 255,255,255,true)
                                --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                                return
                            end
                            
                            exports['cr_account']:updatePlayerJailDatas(playerID, value_cache)
                            exports['cr_account']:updatePlayerPositionDatas(playerID, {2496.049804,-1695.238159,1014.742187,(6969+playerID),3, 90})
                            dbExec(connection, "INSERT INTO `jail_log` SET `account_id` = ?, `reason` = ?, `admin` = ?, `time` = ?", playerID, value_cache[2], value_cache[4],value_cache[5])

                            local hasFIX = getElementData(p, "jail >> using") or 0
                            local hasFIX = hasFIX + 1
                            setElementData(p, "jail >> using", hasFIX)
                            local maxHasFix = getMaxJailCount() or 0
                            if hasFIX > maxHasFix then
                                local green = exports['cr_core']:getServerColor("orange", true)
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                --local vehicleName = getVehicleName(target)
                                outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Jail limitet! (Limit: "..green..maxHasFix..white..") (Jailek száma: "..green..hasFIX..white..")", p, 255,255,255,true)
                            end

                            local adminName = value_cache[4]
                            local jatekosName = playerName:gsub("_", " ")
                            local reason = value_cache[2]
                            local jailTime = value_cache[5]
                            triggerEvent("showAdminBox",p, "#ff751a"..adminName.."#ffffff bebörtönözte#ff751a "..jatekosName.."#ffffff játékost [Offline]\n#ff751aIndok:#ffffff "..reason.."\n#ff751aIdő:#ffffff "..jailTime .. " perc", "info", {adminName.." bebörtönözte "..jatekosName .. " játékost [Offline]", "Indok: "..reason, "Idő: "..jailTime.." perc"})
                        end
                    end
                else -- jail
                    
                    if typ ~= "unjail" then
                        local tALevel = tonumber(characterData[7][1] or 0)
                        local pALevel = p:getData("admin >> level") 

                        if tALevel >= pALevel then
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            outputChatBox(syntax .. "Magadnál csak kisebb admint jailezhetsz!", p, 255,255,255,true)
                            --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                            return
                        end

                        exports['cr_account']:updatePlayerJailDatas(playerID, value)
                        exports['cr_account']:updatePlayerPositionDatas(playerID, {2496.049804,-1695.238159,1014.742187,(6969+playerID),3, 90})
                        dbExec(connection, "INSERT INTO `jail_log` SET `account_id` = ?, `reason` = ?, `admin` = ?, `time` = ?", playerID, value_cache[2], value_cache[4],value_cache[5])

                        local hasFIX = getElementData(p, "jail >> using") or 0
                        local hasFIX = hasFIX + 1
                        setElementData(p, "jail >> using", hasFIX)
                        local maxHasFix = getMaxJailCount() or 0
                        if hasFIX > maxHasFix then
                            local green = exports['cr_core']:getServerColor("orange", true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            --local vehicleName = getVehicleName(target)
                            outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Jail limitet! (Limit: "..green..maxHasFix..white..") (Jailek száma: "..green..hasFIX..white..")", p, 255,255,255,true)
                        end

                        local adminName = value_cache[4]
                        local jatekosName = playerName:gsub("_", " ")
                        local reason = value_cache[2]
                        local jailTime = value_cache[5]
                        triggerEvent("showAdminBox",p, "#ff751a"..adminName.."#ffffff bebörtönözte#ff751a "..jatekosName.."#ffffff játékost [Offline]\n#ff751aIndok:#ffffff "..reason.."\n#ff751aIdő:#ffffff "..jailTime .. " perc", "info", {adminName.." bebörtönözte "..jatekosName .. " játékost [Offline]", "Indok: "..reason, "Idő: "..jailTime.." perc"})
                    else
                        local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                        outputChatBox(syntax .. "Nincs börtönben!", p, 255,255,255,true)
                        return
                    end
                    return
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs ilyen játékos!", p, 255,255,255,true)
                return
            end
        end
    end
)