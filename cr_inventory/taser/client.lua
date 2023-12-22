function syncTaserShot(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    --outputChatBox(weapon)
    --outputChatBox(tostring(isElement(source:getData("taser>obj"))))
    if weapon == 24 and isElement(source:getData("taser>obj")) then
        playSoundFrontEnd(38)
        --outputChatBox("asd")
        --setAmbientSoundEnabled ("gunfire", false)
        setWorldSoundEnabled ( 5, false)
        local muzzleX, muzzleY, muzzleZ = getPedWeaponMuzzlePosition(source)
        local sound = playSound3D("assets/sounds/shock.mp3", muzzleX, muzzleY, muzzleZ)
        attachElements(sound, source)
        local dim = source.dimension
        local int = source.interior
        setSoundMaxDistance(sound, 90)
		setElementDimension(sound, dim)
		setElementInterior(sound, int)
		setSoundVolume(sound, 0.6)
        setWorldSoundEnabled ( 5, true)
        
        if hitElement and isElement(hitElement) and hitElement.type == "player" then
            local effect = createEffect("prt_spark_2", hitX, hitY, hitZ)
            setTimer(
                function()
                    destroyElement(effect)
                    effect = nil
                    collectgarbage("collect")
                end, 400, 1
            )
        end
        
        if source == localPlayer then
            toggleControl("fire", false)
            shotTimer = setTimer(
                function()
                    if isElement(sound) then destroyElement(sound) end
                    --
                    toggleControl("fire", true)
                end, 5000, 1
            )
        end
    end
end
addEventHandler("onClientPlayerWeaponFire", root, syncTaserShot)

addEvent("startTazedEffect", true)
addEventHandler("startTazedEffect", localPlayer,
    function()
        local tazerSavedValues = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), localPlayer:getData("char >> bone"), isChatVisible()}
        showChat(false)
        localPlayer:setData("tazerSavedValues", tazerSavedValues)
        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
        localPlayer:setData("char >> bone", {false, false, false, false, false})
        --if getPedWeapon(localPlayer) > 0 then hideWeapon() end
        toggleAllControls(false)
        fadeCamera(false, 5, 255,255,255)
        noiseSound = playSound("assets/sounds/noise.mp3", true)
        localPlayer:setData("char >> tazed", false)
        exports['cr_chat']:createMessage(localPlayer, "összeesett a sokkolás következtében", "do")
        localPlayer:setData("char >> tazed", true)
        tazedEffectTimer = setTimer(stopTazedEffect, 1 * 60 * 1000, 1) -- 1 perc
    end
)

addEvent("startTazedEffectAttacker", true)
addEventHandler("startTazedEffectAttacker", localPlayer,
    function(a)
        exports['cr_chat']:createMessage(localPlayer, "lesokkolt valakit ("..exports['cr_admin']:getAdminName(a, false)..")", "do")
    end
)

function stopTazedEffect()
    --outputChatBox("asd")
    if localPlayer:getData("char >> tazed") then
        --outputChatBox("asd2")
        if isElement(noiseSound) then destroyElement(noiseSound) end
        fadeCamera(true, 5, 255,255,255)
        localPlayer:setData("char >> tazed", false)
        local tazerSavedValues = localPlayer:getData("tazerSavedValues") or {true, false, {true, true, true, true, true}, true}
        showChat(tazerSavedValues[4])
        localPlayer:setData("tazerSavedValues", nil)
        localPlayer:setData("char >> tazedBy", nil)
        localPlayer:setData("hudVisible", tazerSavedValues[1])
        localPlayer:setData("keysDenied", tazerSavedValues[2])
        --if getPedWeapon(localPlayer) > 0 then hideWeapon() end
        toggleAllControls(true)
        localPlayer:setData("char >> bone", {true, true, true, true, true})
        localPlayer:setData("char >> bone", tazerSavedValues[3])

        localPlayer:setData("forceAnimation", {"", ""})
        
        if isTimer(tazedEffectTimer) then
            killTimer(tazedEffectTimer)
        end
    end
end    
if localPlayer:getData("char >> tazed") then
    tazedEffectTimer = setTimer(stopTazedEffect, 1 * 60 * 1000, 1)
    noiseSound = playSound("assets/sounds/noise.mp3", true)
end
addEvent("stopTazedEffect", true)
addEventHandler("stopTazedEffect", root, stopTazedEffect)

-- Vonal stream

local sync = {}
local laserSync = {}
local isDrawn = false
local isDrawnLaser = false

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "char >> tazedBy" then
            if isElementStreamedIn(source) then
                --if source ~= localPlayer then
                    local value = source:getData(dName)
                    if value and isElement(value[1]) then
                        createLine(source, value)
                    end
                --end
            end
        elseif dName == "laserState" then
            if isElementStreamedIn(source) then
                --if source ~= localPlayer then
                    local value = source:getData(dName)
                    if value then
                        createLaserLine(source)
                    else
                        destroyLaserLine(source)
                    end
                --end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source and isElement(source) and source:getData("laserState") then
            createLaserLine(source)
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source and isElement(source) and source:getData("laserState") then
            destroyLaserLine(source)
        end
    end
)

function createLine(source1, source2)
    table.insert(sync, {source1, source2, getTickCount()})
    
    if #sync >= 1 then
        if not isDrawn then
            addEventHandler("onClientRender", root, drawn3DLinesTazer, true, "low-5")
            isDrawn = true
        end
    elseif #sync <= 0 then
        if isDrawn then
            removeEventHandler("onClientRender", root, drawn3DLinesTazer)
            isDrawn = false
        end
    end
end

function drawn3DLinesTazer()
    for k,v in pairs(sync) do
        local source1, source2, tick = unpack(v) -- kit, kitől, mikor
        local source2, bodypart = unpack(source2)
        local sx,sy,sz = getPedBonePosition(source2, 26)--getPedWeaponMuzzlePosition(source2)
        --outputChatBox(sx)
        if not isElement(source1) or not isElement(source2) then
            table.remove(sync, k)
            return
        end
        if source1:getData("clone") then
            source1 = source1:getData("clone")
        end
        local x,y,z = getPedBonePosition(source1, bodypart) --getElementPosition(source1)
        dxDrawLine3D(sx,sy,sz,x,y,z,tocolor(255, 255, 255, 255), 1)
        
        if getTickCount() >= tick + 15000 then -- 15 másodpercig látható
            table.remove(sync, k)
            return
        end
    end
end

function createLaserLine(source)
    --table.insert(sync, {source1, source2, getTickCount()})
    laserSync[source] = true
    
    local num = 0
    for k,v in pairs(laserSync) do
        num = num + 1
        break
    end
    
    if num >= 1 then
        if not isDrawnLaser then
            addEventHandler("onClientRender", root, drawn3DLinesLaser, true, "low-5")
            isDrawnLaser = true
        end
    elseif num <= 0 then
        if isDrawnLaser then
            removeEventHandler("onClientRender", root, drawn3DLinesLaser)
            isDrawnLaser = false
        end
    end
end

function destroyLaserLine(source) 
    if laserSync[source] then
        laserSync[source] = nil
        
        local num = 0
        for k,v in pairs(laserSync) do
            num = num + 1
            break
        end

        if num >= 1 then
            if not isDrawnLaser then
                addEventHandler("onClientRender", root, drawn3DLinesLaser, true, "low-5")
                isDrawnLaser = true
            end
        elseif num <= 0 then
            if isDrawnLaser then
                removeEventHandler("onClientRender", root, drawn3DLinesLaser)
                isDrawnLaser = false
            end
        end
    end
end

function drawn3DLinesLaser()
    for k,v in pairs(laserSync) do
        if not isElement(k) then
            laserSync[k] = nil
            return
        end
        if getPedWeapon(k) > 0 then
            local a,b,c,d = getPedTask(k, "secondary", 0)
            if a == "TASK_SIMPLE_USE_GUN" then
                --local source1, source2, tick = unpack(v) -- kit, kitől, mikor
                --local source2, bodypart = unpack(source2)
                local sx,sy,sz = getPedWeaponMuzzlePosition(k)
                local x,y,z = getPedTargetEnd(k) --getElementPosition(source1)
                local hit, hitX, hitY, hitZ, elementHit = processLineOfSight(sx,sy,sz,x,y,z)
                if hit then
                    x,y,z = hitX, hitY, hitZ
                end
                --outputChatBox(sx)
                if not isElement(k) then
                    destroyLaserLine(k)
                    return
                end
                dxDrawLine3D(sx,sy,sz,x,y,z,tocolor(255, 0, 0, 255), 1)
            end
        end
    end
end