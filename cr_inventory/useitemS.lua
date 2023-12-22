local objs = {}

addEvent("giveWeaponH", true)
addEventHandler("giveWeaponH", root,
    function(sourceElement, weaponID, ammo, itemid, value, tex)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                --setWeaponProperty(weaponID, "poor", "maximum_clip_ammo", 100)
                --setWeaponProperty(weaponID, "std", "maximum_clip_ammo", 100)
                --setWeaponProperty(weaponID, "pro", "maximum_clip_ammo", 100)
                local _weaponID = weaponID
                if weaponID == -1 then weaponID = 24 end
                giveWeapon(sourceElement, weaponID, 99999, true)
                local weaponID = _weaponID
                
                --outputChatBox(tonumber(itemid or -1))
                local obj
                if tonumber(itemid or -1) == 51 then
                    obj = Object(17426, sourceElement.position)
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.03,-0.03,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
                elseif tonumber(itemid or -1) == 127 then
                    obj = Object(10012, sourceElement.position)
                    sourceElement:setData("taser>obj", obj)
                    exports['cr_bone_attach']:attachElementToBone(obj,sourceElement,12,0,0.03,-0.03,0,-90,0)
                    --run exports.cr_bone_attach:attachElementToBone(taser,source,12,0,0.03,-0.03,0,-90,0)
                    objs[sourceElement] = obj
                end
                
                if isElement(obj) then
                    triggerClientEvent(sourceElement, "pj>apply", sourceElement, weaponID, ammo, itemid, value, tex, obj)
                end
            end
        end
    end
)

addEvent("takeAllWeapons", true)
addEventHandler("takeAllWeapons", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                takeAllWeapons(sourceElement)
                
                if objs[sourceElement] then
                    local obj = objs[sourceElement]
                    if isElement(obj) then
                        sourceElement:setData("taser>obj", nil)
                        exports['cr_bone_attach']:detachElementFromBone(obj)
                        destroyElement(obj)
                        objs[sourceElement] = nil
                        collectgarbage("collect")
                    end
                end
            end
        end
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        local sourceElement = source
        if objs[sourceElement] then
            local obj = objs[sourceElement]
            if isElement(obj) then
                sourceElement:setData("taser>obj", nil)
                exports['cr_bone_attach']:detachElementFromBone(obj)
                destroyElement(obj)
                objs[sourceElement] = nil
                collectgarbage("collect")
            end
        end
    end
)

addEvent("setWeaponAmmo", true)
addEventHandler("setWeaponAmmo", root,
    function(sourceElement, weaponID, ammo)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                setWeaponAmmo(sourceElement, weaponID, 99999)
            end
        end
    end
)

addEvent("weaponAnim", true)
addEventHandler("weaponAnim", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                setPedAnimation(sourceElement, "COLT45", "sawnoff_reload", 500, false, false, false, false)
            end
        end
    end
)

addEvent("anim", true)
addEventHandler("anim", root,
    function(sourceElement, details)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                setPedAnimation(sourceElement, unpack(details))
            end
        end
    end
)

local timers = {}

addEvent("reloadAnim", true)
addEventHandler("reloadAnim", root,
    function(sourceElement)
        if client and client.type == "player" then
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                if isTimer(timers[sourceElement]) then
                    killTimer(timers[sourceElement])
                end
                setPedAnimation(sourceElement, "BUDDY", "buddy_reload", 1000, false, true, true)
                timers[sourceElement] = setTimer(
                    function(client)
                        setPedAnimation(sourceElement, "FOOD", "EAT_Vomit_SP", 1, false)
                    end, 
                800, 1, sourceElement)
            end
        end
    end
)

addEventHandler("onResourceStart", resourceRoot,
    function()
        takeAllWeapons(root)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        takeAllWeapons(root)
    end
)

local foodE = {}

function getFoodE(e)
    if not foodE[e] then
        local obj = createObject(e:getData("isUsingFood.foodType") == "food" and 2703 or 2647, 0,0,0)
    
        foodE[e] = obj

        return obj
    else
        return foodE[e]
    end
end

function destroyFoodE(e)
    if not e then
        e = source -- Fix: OnPlayerQuit event
    end
    if foodE[e] then
        exports['cr_bone_attach']:detachElementFromBone(getFoodE(source))
        destroyElement(foodE[e])
        foodE[e] = nil
        return true
    end
end

addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "isUsingFood" then
            local value = source:getData(dName)
            if value then
                if source:getData("isUsingFood.foodType") == "food" then
                    exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 12, -0.07, 0.02, 0.085, 0,0,0)
                else
                    exports['cr_bone_attach']:attachElementToBone(getFoodE(source), source, 11, 0.07, 0, 0.085, 90, 45, 0)
                end
            else
                destroyFoodE(source)
            end
        end
    end
)

addEventHandler("onPlayerQuit", root, destroyFoodE)
addEventHandler("onResourceStop", root, 
    function()
        for k,v in pairs(foodE) do
            destroyFoodE(k)
        end
    end
)