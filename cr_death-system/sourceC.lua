function setElementData(element, dataName, value)
    exports['cr_core']:setElementData(element, dataName, value)
end

function removeElementData(element, dataName)
    exports['cr_core']:removeElementData(element, dataName)
end

setElementData(localPlayer, "respawn", false)
local minutes = 15
local seconds = 0
local fontsize = 1
local movingTimer, clockTimer
local state = false

local speedOnDeath = 0.5
local time = 35000

local font = exports['cr_fonts']:getFont("Roboto", 20)
addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Roboto", 20)
		end
	end
)

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName)
        if not getElementData(localPlayer, "inDeath") then return end
        if dName == "hudVisible" then
            setElementData(localPlayer, dName, false)
            showChat(false)
        elseif dName == "keysDenied" then
            setElementData(localPlayer, dName, true)
        end
    end
)

local seatNames = {
    [0] = "door_lf_dummy",
    [1] = "door_rf_dummy",
    [2] = "door_lr_dummy",
    [3] = "door_rr_dummy",
}

function startDeath()
    if isTimer(respawnTimer) then
        destroyElement(respawnTimer)
    end
    triggerEvent("stopTazedEffect", localPlayer, localPlayer)
    setElementData(localPlayer, "respawn", false)
    --setElementData(localPlayer, "respawn", )
    _weather = getWeather()
    _time = {getTime()}
    local veh = getPedOccupiedVehicle(localPlayer)
    local comPos = false
    local seat = nil
    if veh then
        seat = getPedOccupiedVehicleSeat(localPlayer)
        --[[
        triggerServerEvent("kickPlayerFromVeh", localPlayer, localPlayer)
        local name = seatNames[seat]
        local x,y,z = getVehicleComponentPosition(veh, name, "world")
        if x and y and z then
            comPos = {x,y,z}
        end]]
    end
    setElementData(localPlayer, "char >> death", true)
    --if not localPlayer:getData("death >> ")
    --setElementData(localPlayer, "death >> location", comPos)
    setElementData(localPlayer, "inDeath", true)
    if getElementData(localPlayer, "inDeathVeh") then
        veh = getElementData(localPlayer, "inDeathVeh")
    end
    minutes = 15
    seconds = 0
    local interior = getElementInterior(localPlayer)
    toggleAllControls(false)
    setCameraInterior(interior)
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    setElementCollisionsEnabled(localPlayer, false)
    
    --
    local veh = getPedOccupiedVehicle(localPlayer)
    local comPos = false
    local seat = nil
    if veh then
        seat = getPedOccupiedVehicleSeat(localPlayer)
        --[[
        triggerServerEvent("kickPlayerFromVeh", localPlayer, localPlayer)
        local name = seatNames[seat]
        local x,y,z = getVehicleComponentPosition(veh, name, "world")
        if x and y and z then
            comPos = {x,y,z}
        end]]
    end
    --setElementData(localPlayer, "char >> death", true)
    --if not localPlayer:getData("death >> ")
    --setElementData(localPlayer, "death >> location", comPos)
    --setElementData(localPlayer, "inDeath", true)
    if getElementData(localPlayer, "inDeathVeh") then
        veh = getElementData(localPlayer, "inDeathVeh")
    end
    --minutes = 15
    --seconds = 0
    local interior = getElementInterior(localPlayer)
    --toggleAllControls(false)
    --setCameraInterior(interior)
    --setElementData(localPlayer, "hudVisible", false)
    --setElementData(localPlayer, "keysDenied", true)
    --setElementCollisionsEnabled(localPlayer, false)
    --local oldDimension = getElementDimension(localPlayer)
    --setElementData(localPlayer, "oldDimension", oldDimension)
    local x,y,z = getElementPosition(localPlayer)
    --
    outputChatBox("clone")
    triggerServerEvent("clonePlayer", localPlayer, localPlayer, rot, veh, seat, 1)
    --local oldDimension = getElementDimension(localPlayer)
    --setElementData(localPlayer, "oldDimension", oldDimension)
    local x,y,z = getElementPosition(localPlayer)
    state = true
    setCameraMatrix(x,y,z,x,y,z)
    exports['cr_core']:stopSmoothMoveCamera()
    exports['cr_core']:smoothMoveCamera(x,y,z+1,x,y,z+1,x,y,z+250,x,y,z,time)
    local a,a,rot = getElementRotation(localPlayer)
    --local headless = getElementRotation(localPlayer)
    triggerServerEvent("clonePlayer", localPlayer, localPlayer, rot, veh, seat, 1)
    movingTimer = setTimer(
        function()
            if not state then return end
            fadeCamera(false, 5, 0,0,0)
            movingTimer = setTimer(
                function()
                    if not state then return end
                    fadeCamera(true, 5)
                    movingTimer = setTimer(
                        function()
                            if not state then return end
                            setElementCollisionsEnabled(localPlayer, true)
                            triggerServerEvent("clonePlayer", localPlayer, localPlayer, _, _, _, 2)
                            triggerServerEvent("readyToMoveInNewWorld", localPlayer, localPlayer)
                            toggleAllControls(true)
                            setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
                            toggleControl("enter_exit", false)
                            startShader()
                            setGameSpeed(speedOnDeath)
                            startClockTimer()
                            --[[
                            movingTimer = setTimer(
                                function()
                                    triggerServerEvent("readyToMoveInNewWorld", localPlayer, localPlayer)
                                    setCameraTarget(localPlayer, localPlayer) --setElementData(localPlayer, "char >> death", 0)
                                end, 10000, 1
                            )
                            ]]
                        end, 5000, 1
                    )
                end, 7500, 1
            )
        end, time, 1
    )
end

function onTryEnter()
	if getElementData(localPlayer,"char >> death") then
		cancelEvent()
	end
end
addEventHandler("onClientVehicleEnter",root,onTryEnter)

local isDeletableItem = {
    --[itemID] = true
    [12] = true,
    [13] = true,
    [14] = true,
    [31] = true,
    [32] = true,
    [41] = true,
    [44] = true,
    [48] = true,
    [49] = true,
    [50] = true,
    [51] = true,
    [52] = true,
    [53] = true,
    [54] = true,
    [55] = true,
    [56] = true,
    [57] = true,
    [58] = true,
    [59] = true,
    [66] = true,
    [67] = true,
    [68] = true,
    [69] = true,
    [70] = true,
    [71] = true,
}

function startClockTimer()
    gVehTable = {}
    for k,v in pairs(getElementsByType("vehicle", _, true)) do
        setElementAlpha(v, 0)
        setElementCollidableWith(v, localPlayer, false)
        gVehTable[v] = true
    end
    toggleControl("enter_exit", false)
    stopClockTimer()
    addEventHandler("onClientRender", root, drawnClock, true, "low-5")
    state = true
    heartSound = playSound("sounds/heart.mp3", true)
    setSoundVolume(heartSound, 0.5)
    backgroundSound = playSound("sounds/backgroundSound.mp3", true)
    setSoundVolume(backgroundSound, 0.65)
    effectTimer = setTimer(
        function()
            createEffect()
        end, 1 * 60 * 1000, 0
    )
    clockTimer = setTimer(
        function()
            seconds = seconds - 1
            if seconds <= 0 then
                seconds = 59
                minutes = minutes - 1
                if minutes < 0 then
                    minutes = 0
                    --setGameSpeed(1)
                    --stopClockTimer()
                    --stopShader()
                    setElementData(localPlayer, "respawn", true)
                    setElementData(localPlayer, "respawn.min", 0)
                    for k,v in pairs(getElementsByType("player")) do 
                        setElementCollidableWith(localPlayer, v, false)
                    end
                    local a = 0
                    triggerServerEvent("collisions", localPlayer, localPlayer, false)
                    respawnTimer = setTimer(
                        function()
                            a = a + 1
                            setElementData(localPlayer, "respawn.min", a)
                            if a == 1 then
                                triggerServerEvent("collisions", localPlayer, localPlayer, true)
                                for k,v in pairs(getElementsByType("player")) do 
                                    setElementCollidableWith(localPlayer, v, true)
                                end
                            elseif a >= 10 then
                                setElementData(localPlayer, "respawn", false)
                            end
                        end, 60 * 1000, 10
                    )
                    triggerServerEvent("goToMedical", localPlayer, localPlayer, time)
                    local playerItems = exports['cr_inventory']:getItems(localPlayer, 1)
                        
                        
                    for slot, data in pairs(playerItems) do
                        local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                        --outputChatBox(itemid .. "IsWeapon:"..tostring(exports['cr_inventory']:isWeapon(itemid))..", AmmoID:"..tostring(tonumber(exports['cr_inventory']:getWeaponAmmoItemID(itemid))))
                        --if exports['cr_inventory']:isWeapon(itemid) and tonumber(exports['cr_inventory']:getWeaponAmmoItemID(itemid)) and tonumber(exports['cr_inventory']:getWeaponAmmoItemID(itemid)) >= 1 then
                        if isDeletableItem[tonumber(itemid)] then
                            if premium == 0 then
                                triggerServerEvent("removeItemFromSlot", localPlayer, localPlayer, slot, 1)
                            end
                        end
                    end
                    
                    exporst['cr_money']:takeMoney(localPlayer, math.max(tonumber(localPlayer:getData("char >> money") or 0), 0) * 0.25)
                    exports['cr_infobox']:addBox("warning", "A készpénzed 25%-a levonásra került, és az összes illegális dolgodat elkobozták!")
                    setWeather(_weather) --exports['cr_weather']:resetWeather()
                    setTime(unpack(_time)) --exports['cr_time']:resetTime()
                    --setElementData(localPlayer, "keysDenied", false)
                    --setElementData(localPlayer, "hudVisible", true)
                end
            end
        end, 1000, 0
    )
end

local effect = 0
function clearDeathEffects(e)
    if e == localPlayer then
        if gVehTable then
            for v,k in pairs(gVehTable) do
                if isElement(v) then
                    setElementAlpha(v, 255)
                    setElementCollidableWith(v, localPlayer, true)
                end
            end
        end
        setGameSpeed(1)
        stopClockTimer()
        stopShader()
        fadeCamera(true)
        setWeather(_weather) --exports['cr_weather']:resetWeather()
        setTime(unpack(_time)) --exports['cr_time']:resetTime()
        state = false
    end
end
addEvent("Clear -> DeathEffect", true)
addEventHandler("Clear -> DeathEffect", root, clearDeathEffects)
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if localPlayer:getData("inDeath") then
            clearDeathEffects(localPlayer)
        end
    end
)

function createEffect()
    effect = effect + 1
    if effect > 4 then
        effect = 1
    end
    
    if effect == 4 then -- Víz felemelkedik 10 Másodpercig
        exploisonTimer = setTimer(
            function()
                local x,y,z = getElementPosition(localPlayer)
                local replace = {
                    [1] = 1,
                    [2] = -1,
                }
                createExplosion(x - (math.random(10,20) * replace[math.random(1,2)]), y - (math.random(10,20) * replace[math.random(1,2)]), z, 12)
            end, 2.5 * 1000, 0
        )
        setTimer(
            function()
                killTimer(exploisonTimer)
            end, 30 * 1000, 1
        )
    elseif effect == 2 then -- Fehér villanás 10 Másodpercig, kiesel a világból
        startWhiteShader()
        toggleAllControls(false)
        setSoundVolume(heartSound, 1)
        setSoundVolume(backgroundSound, 0.1)
        local x,y,z = getElementPosition(localPlayer)
        setElementPosition(localPlayer, x,y,z + 10)
        setElementFrozen(localPlayer, true)
        setTimer(
            function()
                setElementFrozen(localPlayer, false)
                stopWhiteShader()
                toggleAllControls(true)
                toggleControl("enter_exit", false)
                setSoundVolume(heartSound, 0.5)
                setSoundVolume(backgroundSound, 0.7)
            end, 10 * 1000, 1
        )
    end
end

function stopClockTimer()
    if state then
        removeEventHandler("onClientRender", root, drawnClock)
        state = false
    end
    if isTimer(movingTimer) then
        killTimer(movingTimer)
    end
    if isTimer(effectTimer) then
        killTimer(effectTimer)
    end
    if isTimer(clockTimer) then
        killTimer(clockTimer)
    end
    if isElement(heartSound) then
        destroyElement(heartSound)
    end
    if isElement(backgroundSound) then
        destroyElement(backgroundSound)
    end
end

function formatString(n)
    if n < 10 then
        n = "0" .. n
    end
    return n
end

local sx, sy = guiGetScreenSize()

function drawnClock()
    local minutesS = formatString(minutes)
    local secondsS = formatString(seconds)
    local x, y = sx - 70, sy - 50
    dxDrawText(minutesS .. ":" .. secondsS,x,y+1,x,y+1,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS .. ":" .. secondsS,x,y-1,x,y-1,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS .. ":" .. secondsS,x-1,y,x-1,y,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS .. ":" .. secondsS,x+1,y,x+1,y,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Jobb
    local r,g,b = 255,255,255
    if minutes <= 3 then
        r,g,b = 255,87,87
    end
    dxDrawText(minutesS .. ":" .. secondsS, x, y, x, y, tocolor(r,g,b,255), fontsize, font, "center", "top")
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "char >> death") then
            --outputChatBox("asd")
            --[[
            if getElementData(localPlayer, "oldDimension") ~= getElementDimension(localPlayer) then
                setElementData(localPlayer, "dimension", getElementData(localPlayer, "oldDimension"))
            end]]
            startDeath()
        end   
    end
)

local hunText = {
    ["Fist"] = "Halált okozó testi sértés",
    ["Brassknuckle"] = "Boxer",
    ["Golfclub"] = "Golfütő",
    ["Nightstick"] = "Gumibot",
    ["Knife"] = "Kés",
    ["Bat"] = "Baseball ütő",
    ["Shovel"] = "Ásó",
    ["Poolstick"] = "Dákó",
    ["Chainsaw"] = "Láncfűrész",
    ["Cane"] = "Járóbot",
    ["Flower"] = "Csokor virág",
    ["Fire Extinguisher"] = "Tűzoltó készülék",
    ["Spraycan"] = "Spray kanna",
    ["Molotov"] = "Molotov gránát",
    ["Teargas"] = "Könnygáz",
    ["Grenade"] = "Gránát",
    ["Flamethrower"] = "Elégett",
    ["Rocket Launcher"] = "Rakétavető",
    ["Rocket Launcher HS"] = "Rakétavető HK",
    ["Sniper"] = "Mesterlövész puska",
    ["Rifle"] = "Vadászpuska",
    ["Combat Shotgun"] = "SPAZ-12 taktikai sörétes puska",
    ["Sawed-off"] = "Rövid csövű sörétes puska",
    ["Shotgun"] = "Sörétes puska",
    ["Colt 45"] = "Glock 18",
    ["Silenced"] = "Hangtompítós Colt-45",
    ["Satchel"] = "Tapadó bomba",
    ["Explosion"] = "Felrobbant",
}
function getWeaponNameTranslated(name)
    return hunText[name]
end

function player_Wasted(attacker, weapon, bodypart)
    local hexColor = "#ff3333"
    local tempString = "#ffffffHalál oka: "
    local tempString2 = "#ffffffHalál oka: "
    if attacker then
        if getElementType(attacker) == "player" then
            local weaponName = getWeaponNameFromID(weapon)
            if hunText[weaponName] then
                weaponName = hunText[weaponName]
            end
            tempString = tempString .. hexColor .. weaponName..""
            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
            tempString2 = tempString2 .. hexColor .. weaponName.." #ffffff(" .. hexColor .. killerName .. "#ffffff)"
        elseif getElementType(attacker) == "vehicle" then
            tempString = tempString .. hexColor .. "Elütötték#ffffff!"
            local killerName = "Ismeretlen, Kocsi id: " .. tonumber(getElementData(attacker, "veh >> id") or "Ismeretlen")
            local killer = getVehicleController(attacker)
            if killer then
                killerName = getElementData(killer, "char >> name"):gsub("_", " ") or getPlayerName(killer):gsub("_", " ")
            end
            tempString2 = tempString2 .. hexColor .. "Elütötték#ffffff! (" .. hexColor .. killerName .. "#ffffff)"
        end
        if ( bodypart == 9 ) then
            if not getElementData(localPlayer, "char >> headless") then
                setElementData(localPlayer, "char >> headless", true)
            end
            tempString = tempString.." #ffffff(" .. hexColor .. "FEJLÖVÉS!#ffffff)"
            tempString2 = tempString2.." #ffffff(" .. hexColor .. "FEJLÖVÉS!#ffffff)"
        end
    else
        tempString = tempString .. hexColor .. "Ismeretlen!"
        tempString2 = tempString2 .. hexColor .. "Ismeretlen! (Ismeretlen elkövető...)"
    end
    --[[if localPlayer:getData("specialReason") then
        local value = localPlayer:getData("specialReason")
        if type(value) == "table" then
            tempString = value[1]
            tempString2 = value[2]
        else
            tempString = value
            tempString2 = value
        end
    end--]]
    --if not localPlayer:getData("deathReason") then
    setElementData(localPlayer, "deathReason", tempString)
    --end
    --if not localPlayer:getData("deathReason >> admin") then
    setElementData(localPlayer, "deathReason >> admin", tempString2)
    --end
end
addEventHandler("onClientPlayerWasted", localPlayer, player_Wasted)

addEventHandler("onClientPlayerWasted", localPlayer,
    function(killer,weapon,bodypart)
        if not state then
            startDeath()
        end
        --setElementData(localPlayer, "char >> death", {killer,weapon,bodypart})
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "char >> death" then
            local value = getElementData(source, dName)
            if value then
                if not state then
                    startDeath()
                end
            end
        end
    end
)


addEventHandler("onClientPlayerSpawn", localPlayer,
    function()
        if getElementData(localPlayer, "inDeath") then
            toggleAllControls(false)
            showChat(false)
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "char >> headless", false)
            --setElementData(localPlayer, "deathReason", nil)
            --setElementData(localPlayer, "deathReason >> admin", nil)
            --setElementData(localPlayer, "loggedIn", false)
            setGameSpeed(speedOnDeath)
            --setElementFrozen(localPlayer, true)
            local x,y,z = getElementPosition(localPlayer)
            --setElementPosition(localPlayer, x, y, z)
            exports['cr_core']:stopSmoothMoveCamera()
            exports['cr_core']:smoothMoveCamera(x, y, z + 250, x, y, z, x, y, z + 4, x, y, z + 3, time)
            setTimer(
                function()
                    setCameraTarget(localPlayer, localPlayer)
                    toggleAllControls(true)
                    toggleControl("enter_exit", false)
                    --setElementData(localPlayer, "loggedIn", true)
                    --setElementFrozen(localPlayer, false)
                end, time, 1
            )
        end
    end
)

addEvent("spawn - event", true)
addEventHandler("spawn - event", root,
    function(e)
        if e ~= localPlayer then return end
        stopClockTimer()
        --local time = 7000
        exports['cr_core']:stopSmoothMoveCamera()
        setElementData(localPlayer, "char >> death", false)
        toggleAllControls(true)
        setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
        setElementData(localPlayer, "inDeath", false)
        --toggleAllControls(false)
        showChat(false)
        setGameSpeed(1)
        setElementData(localPlayer, "char >> food", 100)
        setElementData(localPlayer, "char >> drink", 100)
        setElementData(localPlayer, "hudVisible", false)
        setElementData(localPlayer, "keysDenied", true)
        setElementData(localPlayer, "char >> headless", false)
        --triggerServerEvent("setElementModelSpecial",localPlayer, localPlayer, getElementData(localPlayer, "char >> skin"))
        --setElementData(localPlayer, "loggedIn", false)
        local x,y,z = getElementPosition(localPlayer)
        setElementPosition(localPlayer, x, y, z)
        setCameraTarget(localPlayer, localPlayer)
        --toggleAllControls(true)
        showChat(true)
        setElementData(localPlayer, "hudVisible", true)
        setElementData(localPlayer, "keysDenied", false)
        setElementFrozen(localPlayer, false)
        toggleControl("enter_exit", true)
    end
)

setTimer(
    function()
        if state then
            setTime(0,0)
            setWeather(19)
        end
    end, 1000, 0
)

addEventHandler("onClientPedDamage",getRootElement(),
	function(att,weapon,part,loss)
        local id = getElementData(source, "ped.id") or "Invalid-4"
		if id == "Death-System" then
            cancelEvent()
        end
	end
)

local white = "#ffffff"

addCommandHandler("asegit", 
    function(cmd, target)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            if not target then
                local syntax = exports['cr_core']:getServerSyntax(false, "warning")
                outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
                return
            else
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    if not getElementData(target, "char >> death") then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax.."A játékos nem halott!", 255,255,255,true)
                        return
                    end
                    local clone = getElementData(target, "clone") or target
                    local x,y,z = getElementPosition(clone)
                    triggerServerEvent("goToMedical", localPlayer, target, 2000, x,y,z)
                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    local syntax2 = exports['cr_admin']:getAdminSyntax()
                    local name = exports['cr_admin']:getAdminName(target)
                    local aName = exports['cr_admin']:getAdminName(localPlayer, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    outputChatBox(syntax .. "Sikeresen újraélesztetted "..hexColor..name..white.." játékost!", 255,255,255,true)
                    local text = syntax2 .. ""..hexColor..aName..white.." újraélesztette "..hexColor..name..white.." játékost!"
                    exports['cr_core']:sendMessageToAdmin(localPlayer, text, 3)
                    local text = syntax .. "Újraélesztett "..hexColor..aName..white.."!"
                    triggerServerEvent("outputChatBox", localPlayer, target, text)
                end
            end
        end
    end
)

--[[addEventHandler("onClientElementStreamIn", root,
    function()
        if getElementType(source) == "ped" then
            if getElementData(source, "deathReason") then
                if isElementInWater(source) then
                    setTimer(setPedAnimation, 50, 2, source, "ped", "Drown", -1, false, true, false)
                else
                    setTimer(setPedAnimation, 50, 2, source, "ped", "FLOOR_hit_f", -1, false, true, false)
                end
                
                local a,a2 = nil
                local rot = getElementData(source, "rot")
                if not rot then
                    a, a2, rot = getElementRotation(source)
                end
                setElementRotation(source, 0,0,rot)
                
            end
        
        elseif getElementType(source) == "player" then
            if getElementData(source, "inDeath") then
                local clone = getElementData(source, "clone")
                if isElementInWater(source) then
                    setTimer(setPedAnimation, 50, 2, source, "ped", "Drown", -1, false, true, false)
                else
                    setTimer(setPedAnimation, 50, 2, source, "ped", "FLOOR_hit_f", -1, false, true, false)
                end
                setElementCollisionsEnabled(source, false)
            end
        end
    end
)]]--

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        local e = localPlayer:getData("clone") or localPlayer:getData("parent")
        if e and isElement(e) then
            localPlayer.position = e.position
            localPlayer.rotation = e.rotation
            localPlayer.dimension = e.dimension
            localPlayer.interior = e.interior
        end
    end
)