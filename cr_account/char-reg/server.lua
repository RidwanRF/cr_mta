local startMoney = {3000, 500}

function nationalityNumToString(e)
    e = tonumber(e)
    if e == 1 then
        return "európai"
    elseif e == 2 then
        return "amerikai"
    elseif e == 3 then
        return "ázsiai"
    else
        return "afrikai"
    end
end

addEvent("character.Register", true)
addEventHandler("character.Register", root, 
    function(sourceElement, details, t)
        local lastClickTick = spam[sourceElement] or 0
        if lastClickTick + 1500 > getTickCount() then
            return
        end
        spam[sourceElement] = getTickCount()
        
        local oName = t[1]
        local oId = t[2]
        local skin = details["skin"]
        local name = details["name"]
        details["skin"] = nil
        details["name"] = nil
        details["walkStyle"] = 121
        details["fightStyle"] = 5
        local a = "Ő egy XX cm magas, XY kg súlyú, XZ éves, XO nemzetiségű ember!"
        a = a:gsub("XX", details["height"])
        a = a:gsub("XY", details["weight"])
        a = a:gsub("XZ", details["age"])
        a = a:gsub("XO", nationalityNumToString(details["nationality"]))
        details["description"] = a
        details = toJSON(details)
        local position = toJSON({1584.9250488281, -2311.2719726563, 13.546875, 0,0, 70})
        local details2 = toJSON(
            {100, 0, skin, startMoney[1], 0,1,0, 0, 100,100, 5, 5, 1, toJSON({{[-1000] = true}, {[-1000] = true}}), toJSON({true, true, true, true, true}), toJSON({[5000] = false}), startMoney[2]}
        )
        
        local usedNames = toJSON({[name] = true})
        
        dbExec(connection, "INSERT INTO `characters` SET `id`=?, `ownerAccountName`=?, `charName`=?, `position`=?, `details`=?, `charDetails`=?, `usedNames`=?", oId, oName, name, position, details2, details, usedNames)
        
        loadCharacterSQL(oId)
    end
)

function loadCharacterSQL(id)
    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local id = tonumber(row["id"])
                        local ownerAccountName = tostring(row["ownerAccountName"])
                        local charname = tostring(row["charname"])
                        local position = tostring(row["position"])
                        local details = tostring(row["details"])    
                        local charDetails = tostring(row["charDetails"])
                        local deathDetails = tostring(row["deathDetails"])
                        local adminDetails = tostring(row["adminDetails"])
                        local usedNames = tostring(row["usedNames"])
                        local groupID = tonumber(row["charGroup"] or 0)
                        
                        position = fromJSON(position)
                        details = fromJSON(details)
                        charDetails = fromJSON(charDetails)
                        deathDetails = fromJSON(deathDetails)
                        adminDetails = fromJSON(adminDetails)
                        usedNames = fromJSON(usedNames)
                        
                        isAccountHaveCharacter[ownerAccountName] = id
                        isNameRegistered[string.lower(charname)] = id
                        characters[id] = {ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails, usedNames, groupID}
                        outputDebugString("Character #"..id.." - loaded!", 0, 255, 50, 255)
                    end
                )
            end
        end, 
    connection, "SELECT * FROM `characters` WHERE `id`=?", id)
end

function loadCharacter(sourceElement, id, username, a)
    --isLogged[username] = true

    --local lastlogin = accounts[username][6]
    --local regdatum = accounts[username][5]
    dbExec(connection, "UPDATE `accounts` SET `online`=? WHERE `id`=?", 1, id)
    
    local data = characters[id]
    local usedNames = characters[id][8]
    local value = characters[id][2]
    if not usedNames[value] then
        --usedNames[value] = true
        characters[id][8][value] = true
        local usedNames = toJSON(characters[id][8])
        dbExec(connection, "UPDATE `characters` SET `usedNames`=? WHERE `id`=?", usedNames, id)
    end
    triggerClientEvent(sourceElement, "loadCharacter", sourceElement, data)
end
addEvent("loadCharacter", true)
addEventHandler("loadCharacter", root, loadCharacter)

addEvent("checkNameRegistered", true)
addEventHandler("checkNameRegistered", root,
    function(e, b)
        local lastClickTick = spam[e] or 0
        if lastClickTick + 1500 > getTickCount() then
            return
        end
        spam[e] = getTickCount()
        
        local a = true
        if isNameRegistered[string.lower(b)] then
            a = false
        end
        triggerClientEvent(e, "receiveNameRegisterable", e, a, b)
    end
)

function setname_sc(element,cmd, target,...)
    if exports['cr_permission']:hasPermission(element, "setname") then
        if not (target) or not(...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos ID/Név] [Name]",element,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(element, target)
            if target then
                local aName = exports['cr_admin']:getAdminName(target, false) --getElementData(target,"char >> name"):gsub("_"," ")
                if target:getData("loggedIn") then
                    local color = exports['cr_core']:getServerColor(nil, true)
                    local newName = table.concat({...}, " ")
                    local newName = newName:gsub(" ","_")
                    if #newName <= 8 and #newName >= 30 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A karakternév minimum 8, maximum 30 karakter lehet!",element,255,255,255,true)
                        return
                    end
                    
                    local name = newName:gsub("_", " ")
                    local count = 1
                    local fullName = ""
                    while true do
                        local a = gettok(name, count, string.byte(' '))
                        if a then
                            count = count + 1
                            if gettok(name, count, string.byte(' ')) then
                                a = a .. "_"
                            end
                            a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
                            fullName = fullName .. a
                        else
                            break
                        end
                    end
                    newName = fullName
                    
                    if not isNameRegistered[string.lower(newName)] then
                        local syntax = exports['cr_core']:getServerSyntax(false, "success")
                        outputChatBox(syntax.."Sikeresen megváltoztattad "..color..aName.."#ffffff nevét! ("..color..newName:gsub("_", " ").."#ffffff)",element,255,255,255,true)
                        exports['cr_core']:sendMessageToAdmin(target,exports['cr_admin']:getAdminSyntax()..color..exports['cr_admin']:getAdminName(element,true).."#ffffff megváltoztatta "..color..aName.."#ffffff nevét! ("..color..newName:gsub("_", " ").."#ffffff)",1)
                        
                        exports['cr_infobox']:addBox(target, "success", "Új nevet kaptál! ("..newName:gsub("_", " ")..")")
                        
                        local text = tonumber(element:getData("acc >> id") or 0).." megváltoztatta" .. tonumber(target:getData("acc >> id") or 0).." nevét! ("..newName..")"
                        exports['cr_logs']:addLog(thePlayer, "Admin", "ban", string.gsub(text, "#%x%x%x%x%x%x", ""))

                        target:setData("char >> name", newName)
                    else
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A karakter név már foglalt!",element,255,255,255,true)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax..aName.." nincs bejelentkezve!",element,255,255,255,true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."Nincs találat "..target.."-ra(re)!",element,255,255,255,true)
            end
        end
    end
end
addCommandHandler("setname", setname_sc)
addCommandHandler("changename", setname_sc)