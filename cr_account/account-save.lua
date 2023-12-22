function savePlayer(e)
    -- outputChatBox(tostring(getElementData(e, "player.loggedIn")))
    if getElementData(e, "loggedIn") then
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        --local position = data[3]
        local id = tonumber(getElementData(e, "acc >> id"))
        -- outputChatBox(id)
        local name = tostring(getElementData(e, "acc >> username"))

        local clone = getElementData(e, "clone") or e
        if not isElement(clone) then clone = e end
        local x,y,z = getElementPosition(clone)
        local dim, int = getElementDimension(clone), getElementInterior(clone)
        local a,a,rot = getElementRotation(clone)
        --local x,y,z, dim,int,rot = unpack(position)

        local Health = tonumber(getElementHealth(e))
        local Armor = tonumber(getPedArmor(e))
        local SkinID = tonumber(getElementModel(e))
        local Money = tonumber(getElementData(e, "char >> money")) or 0
        local BankMoney = tonumber(getElementData(e, "char >> bank_money")) or 0
        local PlayedTime = tonumber(getElementData(e, "char >> playedtime")) or 0
        local Level = tonumber(getElementData(e, "char >> level")) or 1
        local premiumPoints = tonumber(getElementData(e, "char >> premiumPoints")) or 0
        local job = tonumber(getElementData(e, "char >> job")) or 1
        local food = tonumber(getElementData(e, "char >> food")) or 100
        local drink = tonumber(getElementData(e, "char >> drink")) or 100
        --local details = {Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink}
        --local Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink = unpack(details)

        local charname = tostring(getElementData(e, "char >> name")) or "Ismeretlen"

        local dead = tostring(getElementData(e, "char >> death")) or "false"
        local reason = tostring(getElementData(e, "deathReason")) or ""
        local aReason = tostring(getElementData(e, "deathReason >> admin")) or ""
        local reason = {reason, aReason}
        local headless = tostring(getElementData(e, "char >> headless")) or "false"

        local alevel = tonumber(getElementData(e, "admin >> level")) or 0
        local nick = tostring(getElementData(e, "admin >> name")) or "Ismeretlen"
        local adutyTime = tonumber(getElementData(e, "admin >> time")) or 0
        
        local vehicleLimit = tonumber(getElementData(e, "char >> vehicleLimit")) or 3
        local interiorLimit = tonumber(getElementData(e, "char >> interiorLimit")) or 3
        local avatar = tonumber(getElementData(e, "char >> avatar")) or 1
        local c1 = getElementData(e, "friends", friend) or {}
        local c2 = getElementData(e, "debuts", debut) or {}
        local isKnow = {c2, c1}
        local isHidden = getElementData(e, "weapons >> hidden") or {}
        
        local Bones = getElementData(e, "char >> bone", bone) or {true, true, true, true, true}
        
        local usedCmds = {}
        local rtc = getElementData(e, "rtc >> using", rtc)
        local fix = getElementData(e, "fix >> using", fix)
        local fuel = getElementData(e, "fuel >> using", fuel)
        local ban = getElementData(e, "ban >> using", ban)
        local kick = getElementData(e, "kick >> using", kick)
        local jail = getElementData(e, "jail >> using", jail)
        usedCmds = {rtc, fix, fuel, jail, ban, kick}
        
        local position = {x,y,z, dim,int,rot}
        local charDetails = getElementData(e, "char >> details")
        charDetails["description"] = getElementData(e, "char >> description")
        local details = {Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink, vehicleLimit, interiorLimit, avatar, isKnow, Bones, isHidden, BankMoney}
        local bulletsInBody = getElementData(e, "bulletsInBody") or {}
        local deathDetails = {dead, reason, headless, bulletsInBody}
        
        local abool = getElementData(e,"char >> ajail") or false
        local areason = getElementData(e,"char >> ajail >> reason") or ""
        local atype = getElementData(e,"char >> ajail >> type") or 0
        local aadmin = getElementData(e,"char >> ajail >> admin") or ""
        local adminlevel = getElementData(e,"char >> ajail >> aLevel") or 0
        local atime = getElementData(e,"char >> ajail >> time") or 0
        local ajail = toJSON({abool,areason,atype,aadmin,atime,adminlevel})
        
        local adminDetails = {alevel, nick, adutyTime, usedCmds, ajail}
        local groupID = tonumber(getElementData(e, "char >> groupId") or 0)
        
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        characters[id][2] = charname
        characters[id][3] = position
        characters[id][4] = details
        characters[id][5] = charDetails
        characters[id][6] = deathDetails
        characters[id][7] = adminDetails
        characters[id][9] = groupID
        
        -- outputChatBox("Position:" .. toJSON(position))
        -- outputChatBox("Details:" .. toJSON(details))
        -- outputChatBox("CharDetails:" .. toJSON(charDetails))
        -- outputChatBox("DeathDetails:" .. toJSON(deathDetails))
        -- outputChatBox("AdminDetails:" .. toJSON(adminDetails))
        -- outputChatBox("ID:" .. id)

        --outputDebugString("Account #"..id.." - saved", 0, 200, 200, 200)
        
        dbExec(connection, "UPDATE `characters` SET `charname`=?, `position`=?, `details`=?, `charDetails`=?, `deathDetails`=?, `adminDetails`=?, `charGroup`=? WHERE `id`=?", charname, toJSON(position), toJSON(details), toJSON(charDetails), toJSON(deathDetails), toJSON(adminDetails), groupID, id)
    end
end

addEventHandler("onPlayerQuit", root,
    function()
        savePlayer(source)
        local id = getElementData(source, "acc >> id")
        if id then
            outputDebugString("Account #"..id.." - saved", 0, 200, 200, 200)
        end
    end
)

function saveAllPlayers()
    local count = 0
    outputDebugString("Started saving accounts...", 0, 200, 200, 200)
    for k,v in pairs(getElementsByType("player")) do
        local co = coroutine.create(savePlayer)
        coroutine.resume(co, v)
        count = count + 1
    end
    outputDebugString("Saved #"..count.." accounts!", 0, 200, 200, 200)
end
addEventHandler("onResourceStop", resourceRoot, saveAllPlayers)
setTimer(saveAllPlayers, 15 * 60 * 1000, 0)