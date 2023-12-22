localPlayer:setData("usingRadio", false)
weaponInHand = false
weaponInHandID = 0
localPlayer:setData("weaponInHand", weaponInHand)
isUsingFood = false
localPlayer:setData("isUsingFood", isUsingFood)
weaponDatas = {}
activeSlot = {}--{0, 0}
lastTick = -500
wMultipler = 1
recailing = false

toggleControl("next_weapon", false)
toggleControl("previous_weapon", false)
--toggleControl("fire", false)
canShot = false
toggleControl("action", false) 

local alpha = 0

function checkBone(dName)
    if source == localPlayer and dName == "char >> bone" then
        local value = source:getData(dName) or {true, true, true, true, true}
        if not value[2] and not value[3] then
            exports['cr_infobox']:addBox("error", "Mivel eltört mindkét kezed a fegyvert tovább nem használhatod!")
            hideWeapon()
        end
        
        if not canShot then
            toggleControl("next_weapon", false)
            toggleControl("previous_weapon", false)
            toggleControl("fire", false)
            toggleControl("vehicle_fire", false)
            toggleControl("action", false) 
        end
    elseif source == localPlayer and dName == "inHorse" then
        local value = source:getData(dName)
        if value then
            hideWeapon()
        end
    end
end

function putdownWeapon()
    hideWeapon()
end

localPlayer:setData("laserState", nil)

function convertFoodType(text)
    return text == "food" and "kaját" or "italt"
end

function useItem(slot, id, itemid, value, count, status, dutyitem, premium, nbt)
    
    if exports['cr_network']:getNetworkStatus() then return end
    if getElementData(localPlayer, "char >> death") or getElementData(localPlayer, "inDeath") then return end
    if getElementData(localPlayer, "inHorse") or getElementData(localPlayer, "inHorseE") then return end
    
    if cuffed or jailed or inventoryForceDisabled or tazed then
        return
    end
    
    if lastTick + 1000 > getTickCount() then
        exports['cr_infobox']:addBox("error", "Csak 1 másodpercenként végezhető item interakció!")
        return
    end
    lastTick = getTickCount()
    
    if moveState and moveSlot and tonumber(moveSlot) and tonumber(moveSlot) >= 1 then return end
    
    if itemid == 16 then
        exports['cr_vehicle']:triggerVehicleLock(value)
    elseif itemid == 19 then
        if localPlayer:getData("usingRadio") then
            if tonumber(localPlayer:getData("usingRadio.slot") or 0) == slot then
                localPlayer:setData("usingRadio", false)
                activeSlot[items[itemid][2] .. "-" .. slot] = nil
                exports['cr_chat']:createMessage(localPlayer, "abbahagyja egy rádió hallgatását", 1) -- / ?! majd megváltoztatjátok
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Egy másik rádióra rávagy hangolódva!",255,255,255,true)
            end
        else
            localPlayer:setData("usingRadio", true)
            localPlayer:setData("usingRadio.slot", tonumber(slot))
            localPlayer:setData("usingRadio.frekv", tonumber(value))
            activeSlot[items[itemid][2] .. "-" .. slot] = true
            
            exports['cr_chat']:createMessage(localPlayer, "elkezdi egy rádió hallgatását", 1) -- / ?! majd megváltoztatjátok
        end
    elseif itemid == 21 then
        exports['cr_chat']:createMessage(localPlayer, " gurított egyet a kockával ami " .. math.random( 1, 6 ) .."-ot mutat.", "do")
	--elseif itemid == 26 then
		--if (isPedDead(source)) then
			--skin = getElementModel(source)
			--x, y, z = getElementPosition(source)
			--spawnPlayer(source,x,y,z,0,skin,0,0)
			--jatekosItemEltavolitas(source, itemIndex)
		--else
			--exports['cr_infobox']:addBox("error", "Nem vagy halott!") 	
		--end	
	elseif itemid == 37 then
        exports.cr_sirens:createSiren()
    elseif itemid == 75 then
        exports.cr_taxi:createLamp()
    elseif itemid == 78 then
        isIdentityCardShowing = exports.cr_idcard:changeCardState(value, id)
        if isIdentityCardShowing then
            activeSlot[items[itemid][2] .. "-" .. slot] = true
        else
            activeSlot[items[itemid][2] .. "-" .. slot] = nil
        end
    elseif itemid == 84 then
        exports['cr_vehicle']:triggerVehicleLock(value, true)
    elseif itemid == 85 then
        if not localPlayer.vehicle then
            if weaponInHand and getPedWeapon(localPlayer) > 0 then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                outputChatBox(syntax .. "Mielőtt elővennéd a horgászbotot, rakd el a a fegyvert",255,255,255,true)
                return    
            end
            
            if isUsingFood then
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                outputChatBox(syntax .. "Mielőtt elővennéd a horgászbotot, rakd el a kaját",255,255,255,true)
                return
            end

            weaponInHand = exports.cr_fishing:createFishingRod();
            --outputChatBox(tostring(weaponInHand))
            if weaponInHand then
                oldState = false
                weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt, 0, {0,0}}
                --activeSlot = {slot, 0, items[itemid][2]}
                activeSlot[items[itemid][2] .. "-" .. slot] = true
                disabled = true
            else
                weaponDatas = {}
                activeSlot[items[itemid][2] .. "-" .. slot] = nil --{0,0}
            end
        end
	elseif(itemid == 126) then
		-- triggerServerEvent("createDrone", root, localPlayer)
		exports.cr_bank_script:createDrone() 
		if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            checkTableArray(eType, eId, 1)
            cache[eType][eId][1][slot][4] = count - 1
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif itemid == 129 then
        --if weaponInHand then
        -- Lézer
        laserState = not laserState
        localPlayer:setData("laserState", laserState)
        if laserState then
            exports['cr_chat']:createMessage(localPlayer, "elkezdi használni a célzólézert", 1) -- // ?!
            activeSlot[items[itemid][2] .. "-" .. slot] = true
        else
            exports['cr_chat']:createMessage(localPlayer, "abbahagyja a célzólézer használatát", 1) -- // ?!
            activeSlot[items[itemid][2] .. "-" .. slot] = nil
        end
    elseif itemid == 131 then
        if exports['cr_faction']:isPlayerInFaction(localPlayer, 1) then
            if localPlayer.dimension == 0 and localPlayer.interior == 0 then
                local pos = Vector3(1472.8494873047, -1721.6120605469, 13.546875)
                if getDistanceBetweenPoints3D(pos, localPlayer.position) <= 5 then
                    local invType = items[itemid][2]
                    triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
                    local eType = getEType(localPlayer)
                    local eId = getEID(localPlayer)
                    cache[eType][eId][invType][slot] = nil
                    giveItem(localPlayer, 132, value)
                else
                    exports['cr_infobox']:addBox("error", "Itt nem lehetséges az itemhasználata!")
                end
            else
                exports['cr_infobox']:addBox("error", "Itt nem lehetséges az itemhasználata!")
            end
        else
            exports['cr_infobox']:addBox("error", "Nem vagy a Rendőr frakció tagja!")
        end
    elseif not isWeapon(itemid) and items[itemid][7] and foodDetails[itemid] then
        if weaponInHand then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            outputChatBox(syntax .. "Mielőtt elővennéd a kaját, rakd el a kezedben lévő eszközt (fegyver, horgászbot, etc...)",255,255,255,true)
            return
        end
        
        local itemName = getItemName(itemid, value, nbt)
        if not isUsingFood then
            weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt}
            exports['cr_chat']:createMessage(localPlayer, "elővesz egy "..convertFoodType(foodTypes[itemid]).." ("..itemName..")", 1)
            
            addEventHandler("onClientRender", root, drawnFoodBar, true, "low-5")
            addEventHandler("onClientClick", root, interactFoodBar)
            dropNum = foodDetails[itemid][2] --math.random(2, 5)
            _dropNum = dropNum
            isEaten = false
            
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            local green = exports['cr_core']:getServerColor(nil, true)
            outputChatBox(syntax .. "Az eldobáshoz használd az egér "..green.."'Bal'#ffffff klikkjét, az evéshez pedig a "..green.."'Jobb' #ffffffklikket.",255,255,255,true)

            --activeSlot = {slot, slot2, items[itemid][2]}
            activeSlot[items[itemid][2] .. "-" .. slot] = true
            activePage = 1
            alpha = 0
            if not multipler then multipler = 10 end

            isUsingFood = true
            localPlayer:setData("isUsingFood.foodType", foodTypes[itemid])
            localPlayer:setData("isUsingFood", isUsingFood)
        else
            if weaponDatas[1] == slot and activeSlot[items[itemid][2] .. "-" .. slot] then
                if not isEaten then
                    if _dropNum == dropNum then
                        exports['cr_chat']:createMessage(localPlayer, "elrak egy "..convertFoodType(foodTypes[itemid]).." ("..itemName..")", 1)
                        isUsingFood = false
                        localPlayer:setData("isUsingFood", isUsingFood)
                        activeSlot[items[itemid][2] .. "-" .. slot] = nil

                        removeEventHandler("onClientRender", root, drawnFoodBar)
                        removeEventHandler("onClientClick", root, interactFoodBar)
                    else
                        local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                        outputChatBox(syntax .. "Mivel már ettél/itál ebből a kajából/italból ezért már csak eldobni tudod!",255,255,255,true)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                    outputChatBox(syntax .. "Mivel már ettél/itál ebből a kajából/italból ezért már csak eldobni tudod!",255,255,255,true)
                end
            end
        end
    elseif isWeapon(itemid) and moveSlot ~= itemid then
        if isTimer(clickTimer) then killTimer(clickTimer) end
        if isUsingFood then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            outputChatBox(syntax .. "Mielőtt elővennéd a fegyvert, rakd el a kaját",255,255,255,true)
            return
        end
        
        if weaponInHand and getPedWeapon(localPlayer) <= 0 then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
            outputChatBox(syntax .. "Mielőtt elővennéd a fegyvert, rakd el a a kezedben lévő eszközt (csákány, horgászbot, etc...)",255,255,255,true)
            return
        end
        
        local weaponID = convertIdToWeapon(itemid)
        if weaponID then
            --local weaponInHand = localPlayer:getData("isWeaponInHand")
            if not weaponInHand then
                if status <= 0 then
                    exports['cr_infobox']:addBox("error", "Ez a fegyver nem használható, hisz törött!")
                    return
                end
                
                if localPlayer.vehicle then
                    if localPlayer.vehicle.controller == localPlayer then
                        exports['cr_infobox']:addBox("error", "Fegyvert nem vehetsz elő vezetői ülésben!")
                        return
                    end
                end
                
                local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
                if not bone[2] and not bone[3] then
                    exports['cr_infobox']:addBox("error", "Ez a fegyver nem használható, hisz mindkét kezed!")
                    return
                end
                
                --[[
                if not bone[3] then
                    exports['cr_infobox']:addBox("error", "Ez a fegyver nem használható, hisz törött a jobbkezed!")
                    return
                end]]
                
                local ammo = 0
                local ammoItemID = items[itemid][10]
                
                disabled = false
                --outputChatBox(ammoItemID)
                if ammoItemID <= 0 then -- // Gránátok
                    ammo = 1000
                    disabled = true
                end
                
                local has, slot2, data = hasItem(localPlayer, ammoItemID)
                
                if disabled then
                    has = true
                end
                
                if ammoItemID == -2 then
                    if value <= 0 then
                        has = false
                    end
                end
                
                if ammoItemID == -4 then
                    has = true
                end
                
                local hasData = {slot2, data}
                
                oldState = isControlEnabled("fire")
                oldState2 = false --isControlEnabled("vehicle_fire")
                
                if has then
                    toggleControl("fire", true)
                    toggleControl("vehicle_fire", true)
                    canShot = true
                    toggleControl("action", false) 
                    if not disabled then
                        ammo = data[4]
                    end
                else
                    toggleControl("fire", false)
                    toggleControl("vehicle_fire", true)
                    canShot = false
                    toggleControl("action", false) 
                    if not disabled then
                        if not binded then
                            bindKey("r", "down", reloadWeapon)
                            binded = true
                        end
                    end
                    --toggleControl("aim_weapon", false)
                end
                
                --outputChatBox("asd")
                toggleControl("next_weapon", false)
                toggleControl("previous_weapon", false)
                
                weaponDatas = {slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData}
                
                local tex = convertWeaponToTexture(weaponInHandID)
                triggerServerEvent("giveWeaponH", localPlayer, localPlayer, weaponID, ammo, itemid, value, tex)
                
                setPlayerHudComponentVisible("crosshair", false)
                
                if isTimer(shotTimer) then killTimer(shotTimer) end
                local weaponName = getItemName(itemid, value, nbt)
                exports['cr_chat']:createMessage(localPlayer, "elővesz egy fegyvert ("..weaponName..")", 1)
                
                --activeSlot = {slot, slot2, items[itemid][2]}
                activeSlot[items[itemid][2] .. "-" .. slot] = true
                if tonumber(slot2) and tonumber(slot2) >= 1 and tonumber(ammoItemID) and tonumber(ammoItemID) >= 1 then
                    activeSlot[items[ammoItemID][2] .. "-" .. slot2] = true
                end
                activePage = 1
                
                if isWeapon(itemid) then
                    triggerEvent("deAttachWeapon", localPlayer, localPlayer, convertIdToWeapon(itemid, true))
                end
                
                weaponInHand = true
                weaponInHandID = convertIdToWeapon(itemid)
                localPlayer:setData("weaponInHand", weaponInHand)
                localPlayer:setData("weaponDatas", weaponDatas)
                
                local hasPJ = tonumber(value or 0) > 1
                local pjSrc
                --outputChatBox(tostring(hasPJ))
                if hasPJ then
                    pjSrc = ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
                    local tex = convertWeaponToTexture(weaponInHandID)
                    --outputChatBox(tex)
                    exports['cr_texturechanger']:replace(localPlayer, tex, pjSrc, true)
                end
                
                local crouch = false;
                if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
                    crouch = true;
                end
                if not crouch then
                    triggerServerEvent("weaponAnim", localPlayer, localPlayer)
                end
                addEventHandler("onClientElementDataChange", localPlayer, checkBone)
                wMultipler = 1
                recailing = false
            else
                if weaponDatas[1] == slot and activeSlot[items[weaponDatas[3]][2] .. "-" .. weaponDatas[1]] then
                    hideWeapon()
                end
            end
        end
    else
        local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        outputChatBox(syntax .. "Ehhez a tárgyhoz nem kapcsolódik funkció.",255,255,255,true)
    end
end

function checkHandWeapon()
    if weaponInHand then
        local id = weaponInHandID or 0
        if weaponInHandID == -1 then -- Sokkoló
            id = 24
        end
        local wep = getPedWeapon(localPlayer)
        if tonumber(id) ~= tonumber(wep) then
            triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)
            
            local tex = convertWeaponToTexture(weaponInHandID)
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            triggerServerEvent("giveWeaponH", localPlayer, localPlayer, weaponInHandID, 99000, itemid, value, tex)
            
            local hasPJ = tonumber(value or 0) > 1
            local pjSrc
            --outputChatBox(tostring(hasPJ))
            if hasPJ then
                pjSrc = ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
                local tex = convertWeaponToTexture(weaponInHandID)
                --outputChatBox(tex)
                exports['cr_texturechanger']:replace(localPlayer, tex, pjSrc, true)
            end
        end
    end
end
setTimer(checkHandWeapon, 200, 0)

addEventHandler("onClientPlayerWeaponFire", localPlayer,
    function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
        --outputChatBox(weapon)
        if weaponInHand then
            local itemid = weaponDatas[3]
            local ammoItemID = items[itemid][10]
            --outputChatBox(ammoItemID)
            if ammoItemID == -3 then -- grenade
                local invType = items[itemid][2]
                --outputChatBox(invType)
                local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
                --outputChatBox(slot)
                --setTimer(hideWeapon, 200, 1)
                
                -->>
                hideWeapon()
                -->>
                
                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, invType)
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                
                cache[eType][eId][invType][slot] = nil
                cancelEvent()
                return
            elseif ammoItemID == -2 then
                local invType = items[itemid][2] --activeSlot[3]
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
                value = value - 1
                
                updateItemDetails(localPlayer, slot, invType, {"value", value})
                cache[eType][eId][invType][slot][3] = value
                
                if value <= 0 then
                    hideWeapon()
                end
                
                cancelEvent()    
                return
            end
            
            if disabled then return end
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
            local slot2, data = unpack(hasData)
            
            if not slot2 or slot2 <= 0 then
                toggleControl("fire", false)
                toggleControl("vehicle_fire", false)
                canShot = false
                toggleControl("action", false) 
                cancelEvent()
                return
            end
            
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            checkTableArray(eType, eId, 1)
            
            ammo = ammo - 1
            weaponDatas[10] = ammo
            localPlayer:setData("weaponDatas", weaponDatas)
            
            recailing = false
            started = false
            destroyAnimation(1)
            local weapDmg = weapDmgs[weapon] * (math.random(5, 12) / 10)
            wMultipler = math.max(0, wMultipler - weapDmg)
            
            if wMultipler <= 0.15 then
                local chance = 1
                if chance == 1 then
                    local _oldState = oldState
                    local oldState = weaponDatas[6]
                    local damage = math.random(5,20)
                    weaponDatas[6] = math.max(0, oldState - damage)
                    cache[eType][eId][1][slot][6] = weaponDatas[6]
                    --triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 1)
                    
                    if weaponDatas[6] <= 0 then
                        hideWeapon()
                    end
                end
            elseif wMultipler <= 0.25 then
                local chance = 1
                if chance == 1 then
                    local _oldState = oldState
                    local oldState = weaponDatas[6]
                    local damage = math.random(5,15)
                    weaponDatas[6] = math.max(0, oldState - damage)
                    cache[eType][eId][1][slot][6] = weaponDatas[6]
                    --triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 1)
                        
                    if weaponDatas[6] <= 0 then
                        hideWeapon()
                    end    
                end
            elseif wMultipler <= 0.5 then
                local chance = math.random(1,10)
                if chance == 1 then
                    local _oldState = oldState
                    local oldState = weaponDatas[6]
                    local damage = math.random(5,20)
                    weaponDatas[6] = math.max(0, oldState - damage)
                    cache[eType][eId][1][slot][6] = weaponDatas[6]
                    --triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 1)    
                        
                    if weaponDatas[6] <= 0 then
                        hideWeapon()
                    end
                end
            elseif wMultipler <= 0.75 then
                local chance = math.random(1,20)
                if chance == 1 then
                    local _oldState = oldState
                    local oldState = weaponDatas[6]
                    local damage = math.random(5,10)
                    weaponDatas[6] = math.max(0, oldState - damage)
                    cache[eType][eId][1][slot][6] = weaponDatas[6]
                    triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 1)    
                        
                    if weaponDatas[6] <= 0 then
                        hideWeapon()
                    end
                end    
            end
            
            if isTimer(recailTimer) then killTimer(recailTimer) end
            recailTimer = setTimer(
                function()
                    recailing = true    
                end, 350, 1 
            )    
            
            --outputChatBox(ammo)
            
            local weaponID = convertIdToWeapon(itemid)
            --outputChatBox(itemid)
            if ammo == 1 or ammo == 0 or ammo == 2 then
                triggerServerEvent("setWeaponAmmo", localPlayer, localPlayer, weaponID, 30)
            end
            
            localPlayer:setData("weaponDatas", weaponDatas)
            
            if ammo <= 0 then
                local weaponName = getItemName(itemid, value, nbt)
                local syntax = exports['cr_core']:getServerSyntax("Inventory", "warning")
                exports['cr_chat']:createMessage(localPlayer, "kifogyott a lőszer ("..weaponName..")", "do")
                
                setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
                setElementData(localPlayer, "pulling", false)   
                
                outputChatBox(syntax .. "A fegyver újratöltéséhez használd az #00ff00'R'#ffffff bilentyűt!", 255,255,255,true)
                toggleControl("vehicle_fire", false)
                toggleControl("fire", false)
                canShot = false
                toggleControl("action", false) 
                if not binded then
                    bindKey("r", "down", reloadWeapon)
                    binded = true
                end
                cache[eType][eId][1][slot2] = nil
                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot2, 1)
                --activeSlot[2] = 0
                --activeSlot[items[itemid][2] .. "-" .. slot] = nil
                local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
                if hasData then
                    local slot2, data = unpack(hasData)
                    if tonumber(slot2) and tonumber(slot2) >= 1 then
                        activeSlot[items[data[2]][2] .. "-" .. slot2] = nil
                    end
                end
                local itemID = weaponDatas[3]
                return
            elseif ammo > 0 then
                cache[eType][eId][1][slot2][4] = ammo
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot2, 1, ammo)
            end
        else
            triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)
            cancelEvent()
        end
    end
)

function reloadWeapon()
    local itemid = weaponDatas[3]
    local ammoItemID = items[itemid][10]
                
    local has, slot2, data = hasItem(localPlayer, ammoItemID)
    
    if has then
        local hasData = {slot2, data}
        ammo = data[4]
        weaponDatas[10] = ammo
        weaponDatas[11] = hasData
        --activeSlot[2] = slot2
        activeSlot[items[data[2]][2] .. "-" .. slot2] = true
        local weaponName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "újratölt egy fegyvert ("..weaponName..")", 1)
        toggleControl("fire", true)
        toggleControl("vehicle_fire", true)
        canShot = true
        toggleControl("action", false) 
        if binded then
            unbindKey("r", "down", reloadWeapon)
            binded = false
        end
        localPlayer:setData("weaponDatas", weaponDatas)
        
        local weaponID = convertIdToWeapon(itemid)
        triggerServerEvent("setWeaponAmmo", localPlayer, localPlayer, weaponID, ammo)
        
        local crouch = false;
        if getPedTask(localPlayer, "secondary", 1) == "TASK_SIMPLE_DUCK" then
            crouch = true;
        end
        if not crouch then
            triggerServerEvent("reloadAnim", localPlayer, localPlayer)
        end
    else
        local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
        outputChatBox(syntax .. "Nincs nálad a fegyverhez való lőszer ("..items[ammoItemID][1]..")", 255,255,255,true)
    end
end

local sx, sy = guiGetScreenSize()

function drawnFoodBar()
    local tooltip = false
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
    
    local sx, sy = getNode("Actionbar", "x") + (getNode("Actionbar", "w")/2), getNode("Actionbar", "y") - 50 - 20
    
    local c = 50
    local b = 45
    
    local startX, startY = sx, sy - c/2
    dxDrawRectangle(sx - c/2, sy - c/2, c - 1, c - 1, tocolor(0,0,0,math.min(alpha, 255*0.75)))
    dxDrawImage(sx - b/2 - 1, sy - b/2, b, b, getItemPNG(itemid, value, nbt, status), 0,0,0, tocolor(255,255,255,alpha))
    
    if isInSlot(sx - c/2, sy - c/2, c, c) then
        tooltip = true
    end
    
    if tooltip then
        renderTooltip(startX - b/2 + 1, startY, {id, itemid, value, count, status, dutyitem, premium, nbt}, alpha)
        tooltip = false
    end
    
    local startY = startY + c + 10
    
    dxDrawRectangle(sx - c/2, startY, c, 10, tocolor(90,90,90,120))
    local wMultipler = 1 - (math.abs(dropNum - _dropNum) / _dropNum)
    local color = {} 
    if wMultipler <= 0.25 then
        color = {253, 0, 0}
    elseif wMultipler <= 0.5 then
        color = {253, 105, 0}
    elseif wMultipler <= 0.75 then
        color = {253, 168, 0} 
    elseif wMultipler <= 1 then 
        color = {106, 253, 0}
    end  
    dxDrawRectangle(sx - c/2, startY, c * wMultipler, 10, tocolor(color[1],color[2],color[3],120))
    dxDrawRectangle3(sx - c/2,startY,c, 10, tocolor(90,90,90,0), tocolor(0,0,0,180), 2)
end

function giveHunger(give)
	if give then
		if getElementData(localPlayer, "char >> food") + give <= 100 then
			setElementData(localPlayer, "char >> food", getElementData(localPlayer, "char >> food") + give)
            isEaten = true
			return true
		elseif getElementData(localPlayer, "char >> food") == 100 then 
			exports['cr_infobox']:addBox("warning", "Nem vagy éhes")
            isEaten = true
			return false
		elseif getElementData(localPlayer, "char >> food") + give > 100 then
			setElementData(localPlayer, "char >> food", 100)
            isEaten = true
			return true
		end 
	end 
end

function giveWater(give)
	if give then
		if getElementData(localPlayer, "char >> drink") + give <= 100 then
			setElementData(localPlayer, "char >> drink", getElementData(localPlayer, "char >> drink") + give)
            isEaten = true
			return true
		elseif getElementData(localPlayer, "char >> drink") == 100 then 
			exports['cr_infobox']:addBox("warning", "Nem vagy szomjas")
            isEaten = true
			return false
		elseif getElementData(localPlayer, "char >> drink") + give > 100 then
			setElementData(localPlayer, "char >> drink", 100)
            isEaten = true
			return true
		end 
	end 
end

lastFoodTick = -1000

function interactFoodBar(b,s)
    local sx, sy = getNode("Actionbar", "x") + (getNode("Actionbar", "w")/2), getNode("Actionbar", "y") - 50 - 20
    
    local c = 50
    local _b = b
    local b = 45
    
    --dxDrawRectangle(sx - c/2, sy - c/2, c, c)
    if not isInSlot(sx - c/2, sy - c/2, c, c) then
        return
    end
    
    local b = _b
    
    if b == "left" and s == "down" then
        if lastFoodTick + 1000 > getTickCount() then
            exports['cr_infobox']:addBox("error", "Csak 1 másodpercenként végezhető interakció!")
            return
        end
        lastFoodTick = getTickCount()
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        local itemName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "eldob egy "..convertFoodType(foodTypes[itemid]).." ("..itemName..")", 1)
        isUsingFood = false
        localPlayer:setData("isUsingFood", isUsingFood)
        --activeSlot = {0, 0}
        activeSlot[items[itemid][2] .. "-" .. slot] = nil

        removeEventHandler("onClientRender", root, drawnFoodBar)
        removeEventHandler("onClientClick", root, interactFoodBar)
        
        if count - 1 <= 0 then
            deleteItem(localPlayer, slot, itemid)
        else
            local eType = getEType(localPlayer)
            local eId = getEID(localPlayer)
            checkTableArray(eType, eId, 1)
            cache[eType][eId][1][slot][4] = count - 1
            triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
        end
    elseif b == "right" and s == "down" then
        if lastFoodTick + 1000 > getTickCount() then
            exports['cr_infobox']:addBox("error", "Csak 1 másodpercenként végezhető interakció!")
            return
        end
        lastFoodTick = getTickCount()
        --Ide majd kaja. Kattingatásos szar mint mindenhol, minnél romlotabb annál nagyobb esélye van, hogy hpt vegyen le és annál több hpt. 
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        local itemName = getItemName(itemid, value, nbt)
        local chance = 100 - status
        local rand = math.random(1, 100)
        local hpRemove = math.random(15, 50) * (chance / 100)
        
        local foodType = foodTypes[itemid] == "food" and "kajától" or "italtól"
        
        local text = "a "..foodType
        
        dropNum = dropNum - 1
        
        if rand <= chance then
            exports['cr_chat']:createMessage(localPlayer, "rosszul lett "..text.." ("..itemName..")", "do")
            setElementHealth(localPlayer, math.max(0, getElementHealth(localPlayer) - hpRemove))
        else
            if foodType == "kajától" then
                local give = foodDetails[itemid][1] * (status / 100)

                if giveHunger(give) then
                    exports['cr_chat']:createMessage(localPlayer, "eszik egy harapást a "..foodType:gsub("tól", "ból").." ("..itemName..")", "do")
                    triggerServerEvent("anim", localPlayer, localPlayer, {"food", "eat_burger", 4000, false, true, true})
                    playSound("assets/sounds/eat.mp3")
                    isEaten = true
                end
            else
                local give = foodDetails[itemid][1] * (status / 100)

                if giveWater(give) then
                    exports['cr_chat']:createMessage(localPlayer, "iszik egy kortyot a "..foodType:gsub("tól", "ból").." ("..itemName..")", "do")
                    triggerServerEvent("anim", localPlayer, localPlayer, {"VENDING", "VEND_Drink_P", 4000, false, true, true})
                    playSound("assets/sounds/drink.mp3")
                    isEaten = true
                end
            end
        end
        
        if dropNum <= 0 then
            local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
            local itemName = getItemName(itemid, value, nbt)
            exports['cr_chat']:createMessage(localPlayer, "megevett egy "..foodType:gsub("ól", "").." ("..itemName..")", "do")
            isUsingFood = false
            localPlayer:setData("isUsingFood", isUsingFood)
            --activeSlot = {0, 0}
            activeSlot[items[itemid][2] .. "-" .. slot] = nil

            removeEventHandler("onClientRender", root, drawnFoodBar)
            removeEventHandler("onClientClick", root, interactFoodBar)
            
            if count - 1 <= 0 then
                deleteItem(localPlayer, slot, itemid)
            else
                local eType = getEType(localPlayer)
                local eId = getEID(localPlayer)
                checkTableArray(eType, eId, 1)
                cache[eType][eId][1][slot][4] = count - 1
                triggerServerEvent("countUpdate", localPlayer, localPlayer, slot, 1, count - 1)
            end
            return
        end
    end
end

function hideWeapon()
    --outputChatBox(tostring(weaponInHand))
    if weaponInHand then
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt = unpack(weaponDatas)
        --activeSlot = {0, 0}
        toggleControl("fire", oldState)
        toggleControl("vehicle_fire", oldState2)
        canShot = false
        toggleControl("action", oldState) 
        local weaponName = getItemName(itemid, value, nbt)
        exports['cr_chat']:createMessage(localPlayer, "elrak egy fegyvert ("..weaponName..")", 1)
        if isTimer(shotTimer) then killTimer(shotTimer) end
        triggerServerEvent("updateStatus", localPlayer, localPlayer, slot, weaponDatas[6], 1)    
        
        if binded then
            unbindKey("r", "down", reloadWeapon)
            binded = false
        end
        
        setTimer(setPedDoingGangDriveby, 400, 1, localPlayer, false )
        setElementData(localPlayer, "pulling", false)

        local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
        activeSlot[items[itemid][2] .. "-" .. slot] = nil
        if hasData then
            local slot2, data = unpack(hasData)
            if tonumber(slot2) and tonumber(slot2) >= 1 then
                activeSlot[items[data[2]][2] .. "-" .. slot2] = nil
            end
        end
        if isWeapon(itemid) and convertIdToWeapon(itemid) then
            triggerEvent("attachWeapon", localPlayer, localPlayer, convertIdToWeapon(itemid, true), value)
        end
        
        local hasPJ = tonumber(value or 0) > 1
        local pjSrc
        --outputChatBox(tostring(hasPJ))
        if hasPJ then
            pjSrc = ":cr_inventory/assets/weaponstickers/"..weaponInHandID.."-"..value..".png"
            local tex = convertWeaponToTexture(weaponInHandID)
            --outputChatBox(tex)
            exports['cr_texturechanger']:destroy(localPlayer, tex, pjSrc, true)
        end

        triggerServerEvent("takeAllWeapons", localPlayer, localPlayer)
        weaponInHand = false
        weaponInHandID = 0
        localPlayer:setData("weaponInHand", weaponInHand)
        removeEventHandler("onClientElementDataChange", localPlayer, checkBone)

        local oldState = localPlayer:getData("char >> bone")
        localPlayer:setData("char >> bone", {true, true, true, true, true})
        localPlayer:setData("char >> bone", oldState)
    end
end
addEventHandler("onClientPlayerSpawn", localPlayer, hideWeapon)
addEventHandler("onClientPlayerWasted", localPlayer, hideWeapon)
addEventHandler("onClientResourceStart", resourceRoot, hideWeapon)

addEvent("pj>apply", true)
addEventHandler("pj>apply", localPlayer,
    function(weaponID, ammo, itemid, value, tex, obj)
        local hasPJ = tonumber(value or 0) > 1
        local pjSrc
        --outputChatBox(tostring(hasPJ))
        if hasPJ then
            pjSrc = ":cr_inventory/assets/weaponstickers/"..weaponID.."-"..value..".png"
            local tex = convertWeaponToTexture(weaponID)
            --outputChatBox(tex)
            setTimer(
                function()
                    exports['cr_texturechanger']:replace(obj, tex, pjSrc, true)
                end, 500, 1
            )
        end
    end
)

addEventHandler("onClientVehicleStartEnter", root, 
    function(player,seat,door)
        if (player == localPlayer and seat == 0)then
            if weaponInHand then
                exports['cr_infobox']:addBox("error", "Vezetői ülésbe nem szállhatsz be fegyverrel!")
                cancelEvent()
                return
            end
            
            local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
            if not bone[2] and not bone[3] then
                exports['cr_infobox']:addBox("error", "Vezetői ülésbe nem szállhatsz be hisz törött mindkét kezed!")
                cancelEvent()
                return
            end
--[[
            if not bone[3] then
                exports['cr_infobox']:addBox("error", "Vezetői ülésbe nem szállhatsz be hisz törött a jobbkezed!")
                cancelEvent()
                return
            end]]
        end
    end
)