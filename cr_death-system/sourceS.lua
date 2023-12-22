local damage = {
    [4] = 100,
    [8] = 100,
    [22] = 15,
    [23] = 15,
    [24] = 25,
    [25] = 40,
    [26] = 40,
    [27] = 50,
    [28] = 15,
    [32] = 15,
    [29] = 20,
    [30] = 35,
    [31] = 35,
    [33] = 60,
    [34] = 80, 
}

function playerDamage(attacker, weapon, bodypart, loss)
	if bodypart == 9 and getPedArmor(source) == 0 then
	    killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif weapon == 8 then
        killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif bodypart == 9 then
        local armor = getPedArmor(source)
        armor = armor - damage[weapon]
        if armor <= 0 then
            armor = 0
        end
        setPedArmor(source, armor)
	end
end
addEventHandler("onPlayerDamage", root, playerDamage)

addEvent("collisions", true)
addEventHandler("collisions", root,
    function(e, s)
        if e and isElement(e) then
            if not s then
                e.alpha = 180
            else
                e.alpha = 255
            end
            --setElementCollisionsEnabled(e, s)
        end
    end
)

local clones = {}

function clonePlayer(e, rot, veh, seat, state)
    outputChatBox(state)
    if not clones[e] then
        if state == 1 then
            --setElementAlpha(e, 0)
            local skinid = getElementModel(e)
            local x,y,z = getElementPosition(e)
            local name = exports['cr_admin']:getAdminName(e) or getElementData(e, "char >> name") or getPlayerName(e)
            local type = getElementData(e, "char >> id") or -1
            z = z + 0.2
            local ped = createPed(skinid, x,y,z, rot)
            if isElement(veh) then
                warpPedIntoVehicle(ped, veh, seat)
            end
            --setElementData(ped, "ped.id", "Death-System")
            --setElementData(ped, "ped.name", name)
            --setElementData(ped, "ped.type", type)
            setElementData(ped, "parent", e)
            local deathReason = getElementData(e, "deathReason")
            local deathReasonAdmin = getElementData(e, "deathReason >> admin")
            local belt = getElementData(e, "char >> belt")
            local bulletsInBody = getElementData(e, "bulletsInBody") or {}
            setElementData(ped, "deathReason", deathReason)
            setElementData(ped, "deathReason >> admin", deathReasonAdmin)
            setElementData(ped, "bulletsInBody", bulletsInBody)
            setElementData(ped, "char >> belt", belt)
            --setElementFrozen(ped, true)
            local headless = getElementData(e, "char >> headless")
            setPedHeadless(ped, headless)
            --setElementFrozen(ped, true)
            --[[
            local ped = ped
            setTimer(
                function()
                    setElementFrozen(ped, false)
                end, 10000, 1
            )
            ]]
            --ped.alpha = 0
            setElementData(e, "char >> headless", false)
            --setElementCollisionsEnabled(e, false)
            local dimension = e.dimension -- getElementData(e, "oldDimension")
            setElementDimension(ped, dimension)
            local interior = getElementDimension(e)
            setElementInterior(ped, interior)
            setElementData(e, "clone", ped)
            --setPedAnimation(ped, "ped", "floor_hit_f", 0, false, false, false, true, 0)--,false,false,fals
            setTimer(function()
                if isElement(veh) then
                    local a = math.random(1,2)
                    if a == 1 then
                        exports['cr_animation']:applyAnimation(ped, "ped", "car_dead_lhs", -1, false, true, false)
                        --setElementData(ped, "forceAnimation", {"ped", "car_dead_lhs", -1, false, true, false})
                    else
                        exports['cr_animation']:applyAnimation(ped, "ped", "car_dead_rhs", -1, false, true, false)
                    end
                elseif isElementInWater(e) then
                    --setTimer(setPedAnimation, 100, 4, ped, "ped", "Drown", -1, false, true, false)
                    exports['cr_animation']:applyAnimation(ped, "ped", "drown", -1, false, true, false)
                else
                    --setTimer(setPedAnimation, 100, 4, ped, "ped", "FLOOR_hit_f", -1, false, true, false)
                    exports['cr_animation']:applyAnimation(ped, "ped", "floor_hit_f", -1, false, true, false)
                end
            end, 200, 1)
            --[[
            local a, a, rot = getElementRotation(e)
            setElementRotation(ped, 0,0,rot)
            ]]
            setElementData(ped, "rot", rot)
            clones[e] = ped
            e.alpha = 0
            --setElementCollisionsEnabled(e, false)
        end
        --setElementData(e, "inDeath", false)
        --spawnPlayer(e, 0,0,0, rot, skinid)
        --setElementData(e, "oldPos", {x,y,z})
        setElementData(e, "inDeath", true)
        setElementData(e, "inDeathVeh", veh)
    end
end
addEvent("clonePlayer", true)
addEventHandler("clonePlayer", root, clonePlayer)

function destroyClone(e)
    if clones[e] then
        destroyElement(clones[e])
        clones[e] = nil
        setElementData(e, "clone", nil)
    end
end

function readyToMoveInNewWorld(e)
    local e = e
    local skinid = getElementModel(e)
    local x,y,z = getElementPosition(e)
    local interior = getElementInterior(e)
    --setElementAlpha(e, 255)
    setElementData(e, "char >> death", true)
    setElementData(e, "inDeath", true)
    spawnPlayer(e, x-1,y-1,math.floor(z + 1), 0, skinid)
    setElementAlpha(e, 100)
    setElementDimension(e, getElementData(e, "acc >> id"))
    setElementInterior(e, interior)
    setElementFrozen(e, true)
    setTimer(
        function()
            if isElement(e) then
                setElementCollisionsEnabled(e, true)
                setElementFrozen(e, false)
            end
        end, 7000, 1
    )
end
addEvent("readyToMoveInNewWorld", true)
addEventHandler("readyToMoveInNewWorld", root, readyToMoveInNewWorld)

function goToMedical(e, time, x,y,z)
    local clone = e:getData("clone") or e
    local dim, int = clone.dimension, clone.interior
    if not x or not y or not z then
        x,y,z = 1188.48608, -1323.86096, 14.5668
        dim, int = 0, 0
    end
    triggerClientEvent(e, "Clear -> DeathEffect", e, e)
    triggerClientEvent(e, "stopTazedEffect", e, e)
    local skinid = getElementModel(e)
    setElementData(e, "char >> death", false)
    setElementData(e, "bulletsInBody", {})
    setElementData(e, "inDeath", false)
    if isPedDead(e) then
        spawnPlayer(e, x,y,z)
    end
    local skin = getElementData(e, "char >> skin")
    setElementModel(e, skin)
    setElementData(e, "char >> belt", false)
    --setElementData(e, "")
    destroyClone(e)
    setElementPosition(e, x, y, z+0.5)
    setElementRotation(e, 0, 0, 265)
    triggerClientEvent(e, "spawn - event", e, e, time)
    setElementHealth(e, 100)
    setElementDimension(e, dim)
    setElementInterior(e, int)
    setElementAlpha(e, 255)
    setElementFrozen(e, false)
end
addEvent("goToMedical", true)
addEventHandler("goToMedical", root, goToMedical)

addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "dimension" then
            local value = getElementData(source, dName)
            setElementDimension(source, value)
        elseif dName == "deathReason >> admin" and getElementType(source) == "player" then
            local clone = clones[source]
            if clone then
                local deathReason = getElementData(source, "deathReason")
                local deathReasonA = getElementData(source, dName)
                setElementData(clone, "deathReason", deathReason)
                setElementData(clone, "deathReason >> admin", deathReasonA)
            end
        end
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        if getElementData(source, "char >> death") or getElementData(source, "inDeath") then
            destroyClone(source)
        end
    end
)