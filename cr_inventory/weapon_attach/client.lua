fileDelete("async/global.lua")
fileDelete("triggerHack.lua")
fileDelete("importer/importer.lua")
fileDelete("bar/client.lua")
fileDelete("global.lua")
fileDelete("client.lua")
fileDelete("useItemC.lua")
fileDelete("actionbar/client.lua")
fileDelete("itemlist/client.lua")
fileDelete("weapon/client.lua")
fileDelete("itemshow/itemshowC.lua")
fileDelete("weapon_attach/client.lua")
fileDelete("checkpoints/client.lua")
fileDelete("vending_machines/client.lua")

local modells = {
	[28] = 352, --
    [29] = 353,
	[32] = 372, --
	[22] = 346, --
	[23] = 347, --
	[24] = 17426, 
	[-1] = 10012, 
	[5] = 336,
	[8] = 339,
	[33] = 357,
	[34] = 358,
    [4] = 335, --
	[25] = 349,
	[26] = 350,
	[27] = 351,
	[30] = 355,
	[31] = 356,
}

local weaponPositions = {
    [28] = {14, 0.1, 0.05, 0, 0, -90, 90},
    [32] = {14, 0.12, 0.05, 0, 0, -90, 90},
    [22] = {13, -0.05, 0.05, 0, 0, -90, 90},
    [23] = {13, -0.05, 0.05, 0, 0, -90, 90},
    [4] = {13, -0.035, -0.1, 0.3, 0, 0, 90},
    [30] = {6, -0.08, -0.1, 0.2, 10, 155, 95},
    [31] = {5, 0.10, -0.1, 0.2, -10, 155, 90},
    [29] = {13, -0.07, 0.04, 0.06, 0, -90, 95},
    [8] = {6, -0.15, 0, -0.02, -10, -105, 90},
    [24] = {14, 0.10, 0, 0, 0, 264, 90},
    [-1] = {14, 0.10, 0, 0, 0, 264, 90},
    [5] = {6, -0.09, -0.1, 0.1, 10, 260, 95},
    [3] = {13, -0.05, -0.15, 0.1, 0, 10, 90},
    [25] = {5, 0.10, -0.1, 0.2, 0, 155, 90},
    [26] = {5, 0.10, 0.06, 0.2, 0, 172, 90},
    [33] = {6, -0.09, -0.1, 0.2, 10, 155, 95},
    [34] = {5, 0.10, -0.1, 0.2, -10, 155, 90},
    [27] = {6, -0.09, 0.02, 0.2, 10, 155, 95},
}

local modelCache = {}
local objCache = {}

function checkModelCacheArray(e)
    if not modelCache[e] then
        modelCache[e] = {}
    end
    
    if not objCache[e] then
        objCache[e] = {}
    end
end

function convertWeaponToTexture(a)
    --outputChatBox(a)
    if a == 4 then
        return "powerframe"
    elseif a == 8 then
        return "1"
    elseif a == 22 then
        return "glock17_body"
    elseif a == 23 then
        return "usp_texture_0"
    elseif a == 24 then
        return "deserte"
    elseif a == 25 then
        return "rec_rec"
    elseif a == 26 then
        return "map"
    elseif a == 27 then
        return "sp12"
    elseif a == 28 then
        return "9MM_C"
    elseif a == 29 then
        return "gun_mp5_LONG2"
    elseif a == 30 then
        return "ak"
    elseif a == 31 then
        return "1stpersonassualtcarbine" --"bm_m4a1"
    elseif a == 32 then
        return "gun"
    elseif a == 33 then
        return "wood" -- // csere
    elseif a == 34 then
        return "Main_Body"
    elseif a == -1 then
        return "taser"
    end
end

localPlayer:setData("weapon_attach.table", {})

function attachWeaponToBone(sourceElement, weapon, pj)
    if not isElement(sourceElement) then return end
    if not weapon then return end
    
    local isHidden = getElementData(sourceElement, "weapons >> hidden") or {}
    if not isHidden[weapon] then
        if modells[weapon] and weaponPositions[weapon] then
            checkModelCacheArray(sourceElement)
            if not modelCache[sourceElement][weapon] then
                local bone, ox, oy, oz, orx, ory, orz = unpack(weaponPositions[weapon])
                local obj = createObject(modells[weapon], 0,0,0)
                obj.dimension = sourceElement.dimension
                obj.interior = sourceElement.interior
                obj:setCollisionsEnabled(false)
                modelCache[sourceElement][weapon] = tonumber(pj or 0)
                objCache[sourceElement][weapon] = obj
                local ws = sourceElement.walkingStyle
                local hasPJ = tonumber(pj or 0) > 1
                local pjSrc
                --outputChatBox(tostring(hasPJ))
                if hasPJ then
                    pjSrc = ":cr_inventory/assets/weaponstickers/"..weapon.."-"..pj..".png"
                    local tex = convertWeaponToTexture(weapon)
                    --outputChatBox(tex)
                    setTimer(
                        function()
                            exports['cr_texturechanger']:replace(obj, tex, pjSrc, true)
                        end, 500, 1
                    )
                end

                if sourceElement == localPlayer then
                    localPlayer:setData("weapon_attach.table", modelCache[sourceElement])
                end
                
                exports['cr_bone_attach']:attachElementToBone(obj, sourceElement, bone, ox, oy, oz, orx, ory, orz)
            end
        end
    end
end

function attachWeapons()
    local items = getItems(localPlayer, 1)
    ------outputChatBox"as")
    for k,v in pairs(items) do
        if not activeSlot[1 .. "-" .. k] then
            ------outputChatBox"asd")
            local id, itemid, value, count, status, dutyitem = unpack(v)

            if isWeapon(itemid) then
                local weaponID = convertIdToWeapon(itemid, true)
                attachWeaponToBone(localPlayer, weaponID, value)
            end
        end
    end
end

function attachWeapon(e, weaponID, pj) 
    if not isElement(e) then return end
    
    local isHidden = getElementData(e, "weapons >> hidden") or {}
    if not isHidden[weaponID] then
        attachWeaponToBone(e, weaponID, pj)
    end
end
addEvent("attachWeapon", true)
addEventHandler("attachWeapon", root, attachWeapon)

function hideWeaponC(e, weaponID, state)
    if not isElement(e) then return end
    --outputChatBox(tostring(state))
    if state then -- True = Elrejt, False = Megjelenít
        local isHidden = getElementData(e, "weapons >> hidden") or {}
        isHidden[weaponID] = true
        setElementData(e, "weapons >> hidden", isHidden)
        deAttachWeapon(e, weaponID)
    else
        local isHidden = getElementData(e, "weapons >> hidden") or {}
        isHidden[weaponID] = false
        setElementData(e, "weapons >> hidden", isHidden)
        attachWeapons()
    end
end

local enabledToHide = {
    [22] = true, -- Glock
    [23] = true, -- Silenced
    [24] = true, -- Dezi
}

function hideWeapCMD(cmd)
    local w = getPedWeapon(localPlayer)
    if w and enabledToHide[w] then
        local isHidden = getElementData(localPlayer, "weapons >> hidden") or {}
        if isHidden[w] then
            hideWeaponC(localPlayer, w, false)
            local syntax = getServerSyntax("Inventory", "success")
            outputChatBox(syntax .. "Sikeresen megjelenítetted a kezedben lévő fegyvert!", 255,255,255,true)
        else
            hideWeaponC(localPlayer, w, true)
            local syntax = getServerSyntax("Inventory", "success")
            outputChatBox(syntax .. "Sikeresen eltüntetted a kezedben lévő fegyvert!", 255,255,255,true)
        end
    end
end
_addCommandHandler("elrejt", hideWeapCMD)
_addCommandHandler("Elrejt", hideWeapCMD)
_addCommandHandler("elrejtem", hideWeapCMD)
_addCommandHandler("Elrejtem", hideWeapCMD)
_addCommandHandler("hide", hideWeapCMD)
_addCommandHandler("Hide", hideWeapCMD)

function deAttachWeapon(e, weaponID) 
    exports['cr_bone_attach']:detachElementFromBone(objCache[e][weaponID])
    destroyElement(objCache[e][weaponID])
    modelCache[e][weaponID] = nil
    objCache[e][weaponID] = nil
    collectgarbage("collect")
    setTimer(
        function()
            attachWeapons()
        end, 1000, 1
    )
    if e == localPlayer then
        e:setData("weapon_attach.table", modelCache[e])
    end
end
addEvent("deAttachWeapon", true)
addEventHandler("deAttachWeapon", root, deAttachWeapon)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setTimer(
            function()
                for k,v in pairs(getElementsByType("player", _, true)) do
                    if isElementStreamedIn(v) then
                        checkModelCacheArray(v)

                        local value = v:getData("weapon_attach.table") or {}
                        local have = {}
                        local _v = v
                        for k,v in pairs(value) do -- modellCache[sourceElement] >> k = weapon
                            ----outputChatBox"Elviekben nincs "..k)
                            if not modelCache[_v][k] then
                                ----outputChatBox"Kajakra nincs "..k)
                                local pj = v
                                attachWeaponToBone(_v, k, pj)
                            end

                            have[k] = true
                        end

                        if modelCache and modelCache[source] then
                            for k,v in pairs(modelCache[source]) do
                                ----outputChatBox"Elviekben van / nincs "..k)
                                --for k2, v2 in pairs(modelCache[source][k]) do
                                if not have[k] then
                                    ----outputChatBox"Mivel nincs törlés "..k)
                                    exports['cr_bone_attach']:detachElementFromBone(objCache[_v][k])
                                    destroyElement(objCache[_v][k])
                                    modelCache[_v][k] = nil
                                    objCache[_v][k] = nil
                                    collectgarbage("collect")
                                end
                                --end1
                            end
                        end
                    end
                end
            end, 1000, 1
        )
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "weapon_attach.table" then
            if isElementStreamedIn(source) and source ~= localPlayer then 
                checkModelCacheArray(source)
                
                local value = source:getData(dName)
                local have = {}
                for k,v in pairs(value) do -- modellCache[sourceElement] >> k = weapon
                    ----outputChatBox"Elviekben nincs "..k)
                    if not modelCache[source][k] then
                        ----outputChatBox"Kajakra nincs "..k)
                        --local pj = modelCache[source][k]
                        local pj = v
                        attachWeaponToBone(source, k, pj)
                    end
                    
                    have[k] = true
                end
                
                if modelCache and modelCache[source] then
                    for k,v in pairs(modelCache[source]) do
                        ----outputChatBox"Elviekben van / nincs "..k)
                        --for k2, v2 in pairs(modelCache[source][k]) do
                        if not have[k] then
                            ----outputChatBox"Mivel nincs törlés "..k)
                            exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                            destroyElement(objCache[source][k])
                            modelCache[source][k] = nil
                            objCache[source][k] = nil
                            collectgarbage("collect")
                        end
                        --end1
                    end
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source.type == "player" then
            checkModelCacheArray(source)
            
            local value = source:getData("weapon_attach.table") or {}
            for k,v in pairs(value) do -- modellCache[sourceElement]
                
                --outputChatBox("Elviekben nincs nála "..k)
                --for k2, v2 in pairs(value[k]) do -- modellCache[sourceElement][Weapon]
                if not modelCache[source][k] then
                    --outputChatBox("Kajakra nincs adjunk neki "..k)
                    local pj = v
                    attachWeaponToBone(source, k, pj)
                end
                --end
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        checkModelCacheArray(source)
        if source.type == "player" then
            if modelCache and modelCache[source] then
                --outputChatBox("Töröljük mert már nem látjuk a buzit")
                for k,v in pairs(modelCache[source]) do
                    --outputChatBox("Ezt töröljük:" ..k)
                    --for k2, v2 in pairs(modelCache[source][k]) do
                    exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                    destroyElement(objCache[source][k])
                    modelCache[source][k] = nil
                    objCache[source][k] = nil
                    collectgarbage("collect")
                    --end
                end
            end
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        if modelCache and modelCache[source] then
            for k,v in pairs(modelCache[source]) do
                --for k2, v2 in pairs(modelCache[source][k]) do
                exports['cr_bone_attach']:detachElementFromBone(objCache[source][k])
                destroyElement(objCache[source][k])
                modelCache[source][k] = nil
                objCache[source][k] = nil
                collectgarbage("collect")
                --end
            end
        end
    end
)


--[[
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for k,v in pairs(modelCache) do
            for k2,v2 in pairs(modelCache[k]) do
                ---for k3, v3 in pairs(modelCache[k][k2]) do
                exports['cr_bone_attach']:detachElementFromBone(objCache[k3])
                destroyElement(objCache[k2])
                modelCache[source][k2] = nil
                objCache[k2] = nil
                --end
            end
        end
    end
)]]