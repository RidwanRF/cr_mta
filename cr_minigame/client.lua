addEvent("[Minigame - StartMinigame]", true)
addEvent("[Minigame - EndMinigame]", true)

local minigame2Cache = {}
local minigame3Cache = {}
local sx, sy = guiGetScreenSize()

function createMinigame(e, id, detailName, extra)
    if e == localPlayer then
        startMinigame(id, detailName, extra)
        triggerEvent("[Minigame - StartMinigame]", e, e, id, detailName, extra)
        outputDebugString("[Minigame] Started, ID:"..id, 0, 87,255,255)
    end
end

function startMinigame(id, detailName, extra)
    if id == 1 then -- Újraélesztési cucckombó
        local max = 15
        local needed = max/2
        local multipler = 6
        if extra then
            max = extra["max"]
            needed = extra["needed"]
            multipler = extra["multipler"]
        end
        nowMinigame = detailName
        local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
        outputChatBox(syntax .. "A minigame megkezdődött! Interakciójához használd a Bal Alt -ot (lalt)!", 255,255,255,true)
        resetMinigame(id, max, needed, multipler)
        setElementData(localPlayer, "inMinigame", true)
        addEventHandler("onClientRender", root, drawnMinigame1, true, "low-5")
        bindKey("lalt", "down", doMinigame1)
    elseif id == 2 then
        local max = 15
        local needed = max/2
        local speed = 800
        local speedMulti = 4
        if extra then
            max = extra["max"]
            needed = extra["needed"]
            speed = extra["speed"]
            speedMulti = extra["speedMultipler"]
        end
        nowMinigame = detailName
        last = 1
        speedMultipler = speedMulti
        local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
        outputChatBox(syntax .. "A minigame megkezdődött! Ha az ikon elérte rendes helyét akkor használd a megfelelő nyilat !", 255,255,255,true)
        
        --outputChatBox(max)
        
        toggleAllControls(false)
        resetMinigame(id, max, needed)
        setElementData(localPlayer, "inMinigame", true)
        addAnimation()
        minigame2Timer = setTimer(
            function()
                addAnimation()
            end, speed, max
        )
        addEventHandler("onClientRender", root, drawnMinigame2, true, "low-5")
        addEventHandler("onClientKey", root, doMinigame2)
    elseif id == 3 then
        local max = 30
        local needed = max/2
        local speed = 500
        local speedMulti = 6
        if extra then
            max = extra["max"]
            needed = extra["needed"]
            speed = extra["speed"]
            speedMulti = extra["speedMultipler"]
        end
        nowMinigame = detailName
        speedMultipler = speedMulti
        local syntax = exports['cr_core']:getServerSyntax("Minigame", "warning")
        outputChatBox(syntax .. "A minigame megkezdődött! Ha a betű elérte a kört akkor használd a Bal Alt -ot (lalt)!", 255,255,255,true)
        resetMinigame(id, max, needed)
        setElementData(localPlayer, "inMinigame", true)
        addAnimation2()
        minigame3Timer = setTimer(
            function()
                addAnimation2()
            end, speed, max
        )
        addEventHandler("onClientRender", root, drawnMinigame3, true, "low-5")
        bindKey("lalt", "down", doMinigame3)    
    end
end

function doMinigame1()
    if animY > 100 and animY < 200 then
        success = success + 1
        max = max - 1
        if max <= 0 then
            stopMinigame(1)
            return
        elseif success >= needed then
            stopMinigame(1)
            return
        end
    else
        failed = failed + 1
        max = max - 1
        if max <= 0 then
            stopMinigame(1)
            return
        end
    end
    animY = 0
end

local isAllowed = {
    ["arrow_l"] = true,
    ["arrow_r"] = true,
    ["arrow_u"] = true,
    ["arrow_d"] = true,
}
function doMinigame2(bt2, press)
    if isAllowed[bt2] and press then
        for k = 1, #minigame2Cache do --k,v in ipairs(minigame2Cache) do
            local v = minigame2Cache[k]
            local data, y, isFailed, try = unpack(v) 
            local type, rot, x, bt = unpack(data)
            --dxDrawRectangle(sx/2 + x, y, 50, 10) -- Teteje

            --dxDrawRectangle(sx/2 + x, y + 50, 50, 10) -- Teteje
            if y + 50 >= sy - 150 then
                if y - 10 <= sy - 100 then
                    --outputChatBox(bt2)
                    if bt2 == bt then
                        if isFailed and not try then
                            if not minigame2Cache[k][4] then
                                minigame2Cache[k][3] = false
                                minigame2Cache[k][4] = true
                                last = k + 1
                                return
                            end
                        end
                    else
                        if not minigame2Cache[k][4] then
                            minigame2Cache[k][3] = true
                            minigame2Cache[k][4] = true
                            last = k + 1
                            return
                        end
                    end
                else
                    if not minigame2Cache[k][4] then
                        minigame2Cache[k][3] = true
                        minigame2Cache[k][4] = true
                        last = k + 1
                        return
                    end
                end
            --[[
            else
                if not minigame2Cache[k][4] then
                    minigame2Cache[k][3] = true
                    minigame2Cache[k][4] = true
                    last = k + 1
                    return
                end]]    
            end
        end
    end
end

function doMinigame3()
    for k,v in pairs(minigame3Cache) do
        local string, x, isFailed, try = unpack(v) 
        if x > sx/2 - 60/2 then
            if x < sx + 60/2 then
                if isFailed and not try then
                    minigame3Cache[k][3] = false
                    minigame3Cache[k][4] = true
                end
            else
                minigame3Cache[k][3] = true
                minigame3Cache[k][4] = true
            end
            return
        end
    end
end

function stopMinigame(id, ignoreTrigger)
    if id == 1 then
        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)
        triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        unbindKey("lalt", "down", doMinigame1)
        removeEventHandler("onClientRender", root, drawnMinigame1)
    elseif id == 2 then
        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)
        triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        toggleAllControls(true)
        if success >= needed then
            --outputChatBox(nowMinigame)
            if string.lower(nowMinigame) == string.lower("death > respawn") then
                --outputChatBox("TRIGGER>TRUE")
                triggerEvent("SuccessMinigame", localPlayer, localPlayer)
            end
        else
            --outputChatBox(nowMinigame)
            if string.lower(nowMinigame) == string.lower("death > respawn") then
                --outputChatBox("TRIGGER>FALSE")
                triggerEvent("FailedMinigame", localPlayer, localPlayer)
            end
        end
        local oldBones = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true}
        setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
        setElementData(localPlayer, "char >> bone", oldBones)
        removeEventHandler("onClientKey", root, doMinigame2)
        removeEventHandler("onClientRender", root, drawnMinigame2)
    elseif id == 3 then
        outputDebugString("[Minigame] Stopped, ID:"..minigame..", Success:"..success..", Failed:"..failed..", Needed:"..needed, 0, 87,255,255)
        triggerEvent("[Minigame - StopMinigame]", localPlayer, localPlayer, {minigame, nowMinigame, success, failed, needed})
        unbindKey("lalt", "down", doMinigame3)
        removeEventHandler("onClientRender", root, drawnMinigame3)    
    end
end

function resetMinigame(id, i, i2, i3)
    if id == 1 then
        minigame = id
        success = 0
        failed = 0
        max = i
        needed = i2
        multipler = i3
        animY = 0
        animState = "+"
    elseif id == 2 then
        minigame = id
        success = 0
        failed = 0
        max = i
        last = 1
        needed = i2
        minigame2Cache = {}
        if isTimer(minigame2Timer) then
            killTimer(minigame2Timer)
        end
    elseif id == 3 then
        minigame = id
        success = 0
        failed = 0
        max = i
        needed = i2
        minigame3Cache = {}
        if isTimer(minigame3Timer) then
            killTimer(minigame3Timer)
        end
    end
    return true
end

function linedRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180)
    end
    if not color2 then
        color2 = color
    end
    if not size then
        size = 1.7
    end
	dxDrawRectangle(x, y, w, h, color) -- Háttér
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color2) -- felső
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color2) -- alsó
	dxDrawRectangle(x - size, y, size, h, color2) -- bal
	dxDrawRectangle(x + w, y, size, h, color2) -- jobb
end

function getColor(animY) 
    local color = {255,87,87}
    if animY > 100 and animY < 200 then
        color = {87,255,87}
    end
    return unpack(color)
end

function drawnMinigame1()
    if animState == "+" then
        animY = animY + multipler
        if animY >= 300 then
            animY = 300
            animState = "-"
        end
    elseif animState == "-" then
        animY = animY - multipler
        if animY <= 0 then
            animY = 0
            animState = "+"
        end
    end
    local r,g,b = getColor(animY)
    linedRectangle(sx - 90, sy/2-300/2, 30, 300, tocolor(70,70,70,180), tocolor(0,0,0,180), 1.7)
    linedRectangle(sx - 90, sy/2+300/2, 30, -animY, tocolor(r,g,b,180), tocolor(0,0,0,0), 1.7)
end

function getTypeDatas(type)
    local rot = 0
    local x = -240
    local bt = ""
    if type == 1 then
        rot = 0
        x = -240
        bt = "arrow_d"
    elseif type == 2 then
        rot = 90
        x = -120
        bt = "arrow_l"
    elseif type == 3 then
        rot = 180
        x = 20
        bt = "arrow_u"
    elseif type == 4 then
        rot = 270
        x = 160
        bt = "arrow_r"
    end
    return {type, rot, x, bt}
end

function addAnimation()
    local type = math.random(1,4)
    local tablee = {getTypeDatas(type), 0, true, false} -- type, y
    --outputChatBox(type)
    table.insert(minigame2Cache, 1, tablee)
end

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- numbers/lowercase chars/uppercase chars

function generateString(len)
    if tonumber(len) then
        math.randomseed(getTickCount())
        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.upper(string.char(math.random(charlist[1], charlist[2])))
        end
        if tonumber(str) ~= nil then
            return generateString(len)
        end
        return str
    end
    return false
end

function addAnimation2()
    local string = generateString(1)
    local tablee = {string, 0, true, false} -- y, x
    table.insert(minigame3Cache, 1, tablee)
end

function drawnMinigame2()
    
    --dxDrawRectangle(sx/2 - 200, sy - 150, 400, math.abs((sy - 50) - (sy - 150)))
            
    --dxDrawRectangle(sx/2 + x, y, 50, 10) -- Teteje

    --dxDrawRectangle(sx/2 + x, y + 50, 50, 10) -- Teteje
    
    --dxDrawRectangle(50, y + 100, 10, 10)
    --dxDrawRectangle(sy - 150, 10, 10)
    --dxDrawRectangle(sy - 50, 10, 10)
    --dxDrawRectangle(y <= sy - 50 then
            
            
    dxDrawRectangle(sx/2 - 250, sy - 150 - 10, (sx/2+160)-(sx/2 - 240)+70, 70, tocolor(0,0,0,180))
    dxDrawImage(sx/2 - 240, sy - 150, 50, 50, "files/2/arrow.png", 0, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 - 120, sy - 150, 50, 50, "files/2/arrow.png", 90, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 + 20, sy - 150, 50, 50, "files/2/arrow.png", 180, 0, 0, tocolor(255,255,255,255))
    dxDrawImage(sx/2 + 160, sy - 150, 50, 50, "files/2/arrow.png", 270, 0, 0, tocolor(255,255,255,255))
    
    --dxDrawRectangle(sx/2 + 160, sy - 150, 50, 10, tocolor(255, 0, 0, 255)) -- Teteje
    --dxDrawRectangle(sx/2 + 160, sy - 100, 50, 10, tocolor(255, 0, 255, 255)) -- Alja
    for k,v in pairs(minigame2Cache) do
        local data, y, isFailed, try = unpack(v) 
        y = y + speedMultipler
        minigame2Cache[k][2] = y
        local type, rot, x, bt = unpack(data)
        
        --dxDrawRectangle(sx/2 + x, y, 50, 10) -- Teteje

        --dxDrawRectangle(sx/2 + x, y + 50, 50, 10) -- Teteje
        
        --dxDrawRectangle(sx/2 + x, y + 50, 50, 10, tocolor(0,255,0, 255)) -- Alja
        --dxDrawRectangle(sx/2 + x, y - 10, 50, 10, tocolor(0,0,255, 255)) -- Teteje
        local r,g,b = 255,255,255
        if not isFailed and try then
            r,g,b = 87, 255, 87
        end
        if y >= sy then
            table.remove(minigame2Cache, k)
            --last = k
            if isFailed then
                failed = failed + 1
            else
                success = success + 1
            end
        end
        --outputChatBox(k .. ":"..tostring(isFailed).."-"..tostring(try))
        if isFailed and try then
            r,g,b = 255,87,87
        end
        dxDrawImage(sx/2 + x, y, 50, 50, "files/2/arrow.png", rot, 0, 0, tocolor(r,g,b,255))
    end
    --outputChatBox(#minigame2Cache)
    if #minigame2Cache <= 0 then
        stopMinigame(2)
    end
end

function drawnMinigame3()
    dxDrawImage(sx/2 - 50/2, sy - 150, 50, 50, "files/3/belsokor.png", 0, 0, 0, tocolor(180,180,180,255))
    dxDrawImage(sx/2 - 50/2, sy - 150, 50, 50, "files/3/kulsokor.png", 0, 0, 0, tocolor(180,180,180,255))
    for k,v in pairs(minigame3Cache) do
        local string, x, isFailed, try = unpack(v) 
        x = x + speedMultipler
        minigame3Cache[k][2] = x
        local r,g,b = 255,255,255
        if not isFailed then
            r,g,b = 87, 255, 87
        end
        if x >= sx then
            table.remove(minigame3Cache, k)
            if isFailed then
                failed = failed + 1
            else
                success = success + 1
            end
        elseif x > sx/2 + (120/2) then
            if isFailed then
                r,g,b = 255,87,87
            end
        end
        dxDrawText(string, x, sy - (150) + 50/2, x, sy - (150) + 50/2, tocolor(r,g,b,255), 1, "default-bold", "center", "center")
    end
    --outputChatBox(#minigame2Cache)
    if #minigame3Cache <= 0 then
        stopMinigame(3)
    end
end