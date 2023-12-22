function spawnPl(sourceElement, SkinID, x,y,z, rot, dim,int, Health, Armor, fightStyle, walkStyle)
    local pos = Vector3(x,y,z+1)
    sourceElement:spawn(pos, rot, SkinID)
    sourceElement:setData("char >> skin", SkinID)
    
    sourceElement:setDimension(dim)
    sourceElement:setInterior(int)
    sourceElement:setHealth(Health)
    sourceElement:setArmor(Armor)
    setPedFightingStyle(sourceElement, fightStyle)
    setPedWalkingStyle(sourceElement, walkStyle)
    sourceElement:setAlpha(150)
    sourceElement:setFrozen(true)
    setElementData(sourceElement, "hudVisible", false)
    setElementData(sourceElement, "keysDenied", true)
    sourceElement:setCollisionsEnabled(false)
    
    triggerClientEvent(sourceElement, "cameraSpawn", sourceElement)
end
addEvent("spawnPl", true)
addEventHandler("spawnPl", root, spawnPl)

function unFreeze(sourceElement)
    sourceElement:setAlpha(255)
    sourceElement:setFrozen(false)
    sourceElement:setCollisionsEnabled(true)
    local name = getElementData(sourceElement, "acc >> username")
    local id = getElementData(sourceElement, "acc >> id")
    isLogged[name] = true
    outputDebugString("Account: #"..id..", #"..name.." state - online")
    setElementData(sourceElement, "loggedIn", true)
    if not sourceElement:getData("char >> death") then
        exports["cr_infobox"]:addBox(sourceElement, "success", "Sikeres bejelentkezés. Jó játékot!")
        setElementData(sourceElement, "hudVisible", true)
        setElementData(sourceElement, "keysDenied", false)
    end
end
addEvent("unFreeze", true)
addEventHandler("unFreeze", root, unFreeze)

function interactLogin(sourceElement, username, password)   
    if not isValidAccount[username] then
        exports["cr_infobox"]:addBox(sourceElement, "error", "Ez a felhasználónév ("..username..") nincs regisztrálva!")
        return
    end

    if isLogged[username] then
        exports["cr_infobox"]:addBox(sourceElement, "error", "Ez a felhasználó ("..username..") már használatban van!")
        return
    end
    
    local lastClickTick = spam[sourceElement] or 0
    if lastClickTick + 1500 > getTickCount() then
        return
    end
    spam[sourceElement] = getTickCount()

    local data = accounts[username]
    --accounts[name] = {id, password, serial, email, regdate, lastlogin, ip, usedSerials, usedIps, banned}
    local id = data[1]
    local realPassword = data[2]
    local serial = data[3]
    local email = data[4]
    local registerdatum = data[5]
    local lastlogin = data[6]
    local ip = data[7]
    local usedSerials = data[8]
    local usedIps = data[9]
    local banned = data[10]
    local usedEmails = data[11]

    local mtaserial = getElementData(sourceElement, "mtaserial")
    local nowIP = getPlayerIP(sourceElement)
    
    --outputChatBox(string.lower(realPassword))
    --outputChatBox(string.lower(password))
    if string.lower(password) ~= string.lower(realPassword) then
        local hashedPassword = hash("sha512", username .. password .. username)
        local hashedPassword2 = hash("md5", salt .. hashedPassword .. salt)

        if string.lower(realPassword) ~= string.lower(hashedPassword2) then
            exports["cr_infobox"]:addBox(sourceElement, "error", "Hibás jelszó!")
            return
        end
    end
    
    if banned then
        local banID = isIdentityHaveBan[username]
        banIdentity = bans[banID][2]
        banIdentity[mtaserial] = true
        banIdentity[nowIP] = true
        isIdentityHaveBan[mtaserial] = banID
        isIdentityHaveBan[nowIP] = banID
        bans[banID][2] = banIdentity
        kickPlayer(sourceElement, "Rendszer", "Ki lettél tiltva a szerverről!")
        dbExec(connection, "UPDATE `bans` SET `banIdentity`=? WHERE `id`=?", toJSON(banIdentity), banID)
        return
    end

    if string.lower(serial) ~= string.lower(mtaserial) then
        if tostring(serial) == "0" or tonumber(serial) == 0 then -- Serial váltás
            if not isSerialAttachedToAccount[mtaserial] then
                dbExec(connection, "UPDATE `accounts` SET `serial`=? WHERE `id`=?", mtaserial, id)
                accounts[username][3] = mtaserial
                isSerialAttachedToAccount[mtaserial] = username
            else
                exports["cr_infobox"]:addBox(sourceElement, "error", "A te serialod másik felhasználóhoz van csatolva! ("..tostring(isSerialAttachedToAccount[mtaserial])..")!")
                return
            end
        else
            exports["cr_infobox"]:addBox(sourceElement, "error", "A te serialod ("..mtaserial..") nem ehhez a felhasználóhoz van társítva!")
            return
        end
    end
    
    if not usedSerials[mtaserial] then
        accounts[username][8][mtaserial] = true
        local usedSerials = toJSON(accounts[username][8])
        dbExec(connection, "UPDATE `accounts` SET `usedSerials`=? WHERE `id`=?", usedSerials, id)
    end
    
    if not usedIps[nowIP] then
        accounts[username][9][nowIP] = true
        local usedIps = toJSON(accounts[username][9])
        dbExec(connection, "UPDATE `accounts` SET `usedIps`=? WHERE `id`=?", usedIps, id)
    end
    
    if not usedEmails[email] then
        accounts[username][11][email] = true
        local usedEmails = toJSON(accounts[username][11])
        dbExec(connection, "UPDATE `accounts` SET `usedEmails`=? WHERE `id`=?", usedEmails, id)
    end

    --isLogged[username] = true

    --local lastlogin = accounts[username][6]
    --local regdatum = accounts[username][5]

    dbExec(connection, "UPDATE `accounts` SET `lastlogin`=NOW() WHERE `id`=?", id)
    --[[
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            --for i, row in pairs(query) do
            Async:foreach(query, function(row)
                local lastlogin = tostring(row["lastlogin"])
                accounts[username][6] = lastlogin   
            end)
        end
    end, connection, "SELECT `lastlogin` FROM `accounts` WHERE `id` = ?", id)
    ]]

    --setElementData(sourceElement, "acc >> loggedIn", true)
    setElementData(sourceElement, "acc >> id", id)
    setElementData(sourceElement, "acc >> username", username)

    if isAccountHaveCharacter[username] then
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local details = tostring(row["details"])
                            details = fromJSON(details)
                            characters[id][4][7] = details[7]
                            triggerClientEvent(sourceElement, "loadScreen", sourceElement)
                        end
                    )
                end
            end,
        connection, "SELECT `details` FROM `characters` WHERE `id` = ?", id)
    else
        triggerClientEvent(sourceElement, "Start.Char-Register", sourceElement)
    end
    
    --triggerClientEvent(sourceElement, "idgLoading", sourceElement)
end
addEvent("login.goLogin", true)
addEventHandler("login.goLogin", root, interactLogin)

local isValid = {
    ["char >> skin"] = true,
    ["char >> fightStyle"] = true,
    ["char >> walkStyle"] = true,
    ["char >> headless"] = true,
    ["char >> name"] = true,
    ["char >> armor"] = true,
}

addEventHandler("onElementDataChange", root,
    function(dName, oValue)
        if getElementType(source) == "player" and isValid[dName] then
            if dName == "char >> skin" then
                local value = getElementData(source, dName)
                setElementModel(source, value)
            elseif dName == "char >> fightStyle" then
                local value = getElementData(source, dName)
                setPedFightingStyle(source, value)
                
                if getElementData(source, "char >> details") then
                    local v = getElementData(source, "char >> details")
                    v[7] = value
                    setElementData(source, "char >> details", v)
                end
            elseif dName == "char >> walkStyle" then
                local value = getElementData(source, dName)
                setPedWalkingStyle(source, value)
                
                if getElementData(source, "char >> details") then
                    local v = getElementData(source, "char >> details")
                    v[8] = value
                    setElementData(source, "char >> details", v)
                end
            elseif dName == "char >> name" then
                local id = getElementData(source, "acc >> id")
                if oValue then
                    isNameRegistered[string.lower(oValue)] = nil
                end
                local value = getElementData(source, dName)
                setPlayerName(source, value)
                characters[id][2] = value
                isNameRegistered[string.lower(value)] = id

                local usedNames = characters[id][8]

                if not usedNames[value] then
                    --usedNames[value] = true
                    characters[id][8][value] = true
                    local usedNames = toJSON(characters[id][8])
                    dbExec(connection, "UPDATE `characters` SET `usedNames`=? WHERE `id`=?", usedNames, id)
                end
            elseif dName == "char >> armor" then
                local value = getElementData(source, dName)
                setPedArmor(source, value)    
            elseif dName == "char >> headless" then
                local value = getElementData(source, dName)
                setPedHeadless(source, value)
            end
        end
    end
)

addEvent("change.premiumPoints", true)
addEventHandler("change.premiumPoints", root,
    function(oldName, newValue, set)
        local acc = accounts[oldName]
        local id = acc[1]
        local oldValue = characters[id][4][7]
        local value = oldValue
        if set then
            value = newValue
        else
            value = oldValue + newValue
        end
        characters[id][4][7] = value
        dbExec(connection, "UPDATE `characters` SET `details`=? WHERE `id`=?", toJSON(chracters[id][4]), id)
        
        if isLogged[oldName] then
            local p = getRandomPlayer()
            if p and isElement(p) then
                triggerClientEvent(p, "searchPlayer.addPP", p, id, value)
            end
        end
    end
)