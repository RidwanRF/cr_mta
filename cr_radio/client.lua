local state = false
local sx, sy = guiGetScreenSize()
local x,y = 508, 138 + 256 / 3
local nowChannel = 1
local sound = nil

local cursorState = isCursorShowing()
local cursorX, cursorY = sx/2, sy/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
end

local r,g,b = exports['cr_core']:getServerColor('red', false)
local gr,gg,gb = exports['cr_core']:getServerColor('green', false)
local or1, og, ob = exports['cr_core']:getServerColor(nil, false)

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            r,g,b = exports['cr_core']:getServerColor('red', false)
            gr,gg,gb = exports['cr_core']:getServerColor('green', false)
            or1, og, ob = exports['cr_core']:getServerColor(nil, false)
        end
    end
)

local value = {}

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON({["disabled"] = false}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end

local pos = {}

function jsonGETT(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local x, y = sx/2, sy/2
        fileWrite(fileHandle, toJSON({["x"] = x, ["y"] = y}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end

addCommandHandler("resetradio", 
    function()
        pos["x"] = sx/2
        pos["y"] = sy/2
    end
)

function toggleRadioEqualizer()
    value["disabled"] = not value["disabled"]
    if not value["disabled"] then
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen bekapcsoltad a rádió equalizerét!", 255,255,255,true)
    else
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen kikapcsoltad a rádió equalizerét!", 255,255,255,true)
    end
end
addCommandHandler("toggleradioequalizer", toggleRadioEqualizer)
addCommandHandler("togradioequalizer", toggleRadioEqualizer)
addCommandHandler("toggleradioe", toggleRadioEqualizer)
addCommandHandler("togradioe", toggleRadioEqualizer)
addCommandHandler("togre", toggleRadioEqualizer)
 
function jsonSAVET(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        value = jsonGET("@value.json")
        pos = jsonGETT("@position.json")
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVET("@position.json", pos)
        jsonSAVET("@value.json", value)
    end
)

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON({}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end


function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function linedRectangle(x,y,w,h, color, color2, size)
    if not size then
        size = 1
    end
    exports['cr_core']:linedRectangle(x,y,w,h, color, color2, size)
end

function dxDrawnBorder(x, y, w, h, color2, color1)
    exports['cr_core']:roundedRectangle(x,y,w,h,color1,color2)
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

local channels = {
    --{"Név", "url"},
    {"ClassFM", "http://icast.connectmedia.hu/t4790/B-UA-2992377297-1503989326-7596/live.mp3"},
    {"Music FM", "http://stream.musicfm.hu:8000/musicfm.mp3"},
    {"Rádió 88", "http://www.radio88.hu/stream/radio88.pls"},
    {"Retro Rádió", "http://www.retrofm.hu/listen.pls"},
    {"Rádió M", "http://fmradiom.hu/radiom.m3u"},
    {"Magyar Mulatós", "http://stream.mercyradio.eu/mulatos.mp3"},
    {"Turbó Mulatós", "http://stream.mercyradio.eu/roma.mp3"},
    {"Rádió 1", "http://213.181.210.106:80/high.mp3"},
    {"Sláger FM", "http://92.61.114.159:7812/slagerfm256.mp3"},
    {"Klub rádió", "http://stream.klubradio.hu:8080/bpstream"},
    {"Dance FM", "http://173.192.207.51:8062/listen.pls"},
    {"KroneHit", "http://relay.181.fm:8068"},
    {"Underground FM", "http://broadcast.infomaniak.net/generationfm-underground-high.mp3.m3u"},
    {"Old School", "http://relay.181.fm:8068"},
    {"Radio HiT", "http://asculta.radiohitfm.ro:8340/listen.pls"},
    {"Jamaica Radio", "http://209.126.108.37:8575/listen.pls"},
    {"Hard Techno", "http://tunein.t4e.dj/hard/dsl/mp3"},
    {"ReggaeWorld", "http://67.212.189.122:8042/listen.pls"},
    {"ReggaeCast", "http://64.202.98.32:808/listen.pls"},
    {"Hip Hop", "http://sverigesradio.se/topsy/direkt/2576-hi-aac.pls"},
    {"Uzic - Techo/Minimal", "http://stream.uzic.ch:9010/listen.pls"},
    {"idobi Howl", "http://69.46.88.26:80/listen.pls"},
    {"HOT 108 Jamz", "http://108.61.30.179:4010/listen.pls"},
    {"Russian Radio", "http://www.listenlive.eu/ru_rus.m3u"},
	{"Part FM", "http://87.229.53.9:9000/;stream.mp3"},
	{"Balaton Radio", "http://wssgd.gdsinfo.com:8200/listen.pls"},
	{"Sunshine FM", "http://195.56.193.129:8100/listen.pls"},
	{"Friss FM", "http://178.63.40.81:10050/;?type=http&nocache=23"},
	{"Radio Gold", "http://goldmusic.hu/lst/listen.m3u"},
	{"90's dance", "http://listen.181fm.com/181-90sdance_128k.mp3"},
	{"Mix Radio", "http://mixradio.hu/listen.m3u"},
	{"Awesome 80's", "http://www.181.fm/winamp.pls?station=181-awesome80s&file=181-awesome80s.pls"},
	{"Star 90's", "http://www.181.fm/winamp.pls?station=181-star90s&file=181-star90s.pls"},
	{"PopTron", "http://somafm.com/wma128/poptron.asx"},
	{"UK top 40", "http://www.181.fm/winamp.pls?station=181-uktop40&file=181-uktop40.pls"},
	{"The Mix", "http://www.181.fm/winamp.pls?station=181-themix&file=181-themix.pls"},
	{"The Vibe of Vegas", "http://www.181.fm/winamp.pls?station=181-vibe&file=181-vibe.pls"},
	{"Hip Hop Request", "http://149.56.175.167:5461/listen.pls"},
	{"BlackBeats FM", "http://blackbeats.fm/listen.m3u"},
	{"Classic RAP Radio", "http://listen.radionomy.com/classic-rap.m3u"},
	{"Old School Hip Hop", "http://www.181.fm/winamp.pls?station=181-oldschool&file=181-oldschool.pls"},
	{"DISCO HIT Radio", "http://discoshit.hu/ds-radio.m3u"},
	{"Ibiza Global Radio", "http://ibizaglobalradio.streaming-pro.com:8024/listen.pls"},
	{"Minimal Mix Radio", "http://5.39.71.159:8750/listen.pls"},
	{"Bassjunkees", "http://space.ducks.invasion.started.at.bassjunkees.com:8442/listen.pls"},
	{"Techno Radio", "http://149.56.157.81:5100/listen.pls"},
	{"KISS country", "http://192.99.62.212:9770/stream"},
	{"Magyar Disco Radio", "http://stream.mercyradio.eu/disco.mp3"},
	{"Magyar RAP Radio", "http://stream.mercyradio.eu/rap.mp3"},
	{"Magyar 90-es Evek zenei", "http://stream.mercyradio.eu/90.mp3"},
	{"fnoobtechno", "http://play.fnoobtechno.com:2199/tunein/fnoobtechno320.pls"},
}

function getChannels()
    return channels
end

local sounds = {}

local sourceVeh = getPedOccupiedVehicle(localPlayer)

function stopMusic(veh)
    if sounds[veh] then
        destroyElement(sounds[veh])
        sounds[veh] = nil
    end
    
    if sourceVeh == veh then
        if isElement(sound) then
            destroyElement(sound) 
            sound = nil
        end
    end
end

function startMusic(veh)
    stopMusic(veh)
    if sourceVeh == veh then
        if isElement(veh) and getElementType(veh) == "vehicle" then
            local soundVolume = getElementData(sourceVeh, "radio.volume") or 100
            nowChannel = getElementData(veh, "radio.channel") or 1
            --outputChatBox(nowChannel)
            --outputChatBox(nowChannel)
            local musicURL = channels[nowChannel][2]
            sound = playSound(musicURL)
            local details = getSoundMetaTags(sound)
            musicName = details["title"]
            if not musicName then
                musicName = details["stream_title"]
                if not musicName then
                    musicName = "Ismeretlen zene cím"
                end
            end  
            --outputChatBox(musicName)
            setSoundVolume(sound, soundVolume / 100)
        end
    else
        if isElement(veh) and getElementType(veh) == "vehicle" then
            nowChannel = getElementData(veh, "radio.channel") or 1
            --outputChatBox(nowChannel)
            --outputChatBox(nowChannel)
            local musicURL = channels[nowChannel][2]
            local x,y,z = getElementPosition(veh)
            sounds[veh] = playSound3D(musicURL, x,y,z)
            attachElements(sounds[veh], veh)
            local soundVolume = getElementData(veh, "radio.volume") or 100
            setSoundMaxDistance(sounds[veh], 40 * (soundVolume / 100))
            setSoundVolume(sounds[veh], soundVolume / 100)
        end
    end
end
addEvent("backStart",true)
addEventHandler("backStart",root,startMusic)

if sourceVeh then
    if getElementData(sourceVeh, "radio.state") then
        startMusic(sourceVeh)
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setElementData(localPlayer, "radio.volume", 100)
        for k,v in pairs(getElementsByType("vehicle", root, true)) do
            if getElementData(v, "radio.state") then
                if not getElementData(v, "veh >> windowState") then
                    startMusic(v)
                end
            end
        end
    end
)

local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_fonts" then
	        font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
        end
	end
)

addEventHandler("onClientCursorMove", root, 
    function(_, _, cx, cy)
        cursorX, cursorY = cx, cy
        if realMoving and state then
            pos["x"] = cx - dX
            pos["y"] = cy - dY
            return
        end
        
        if soundMoving then
            local x = x
            if getElementData(sourceVeh, "radio.state") then
                local channelName = channels[nowChannel][1]
                local musicName = channelName .. " >> " .. musicName
                local musicNameWidth = dxGetTextWidth(musicName, 1, font)
                if musicNameWidth > x * 0.95 then
                    x = musicNameWidth + 60
                end
            end
            local nx = x * 0.95
            local ny = 15
            local maxX = pos["x"]-nx/2
            local minX = pos["x"]+nx/2
            if cx >= maxX and cx <= minX then
                local num = math.round((cx - maxX) / nx * 100, 1)
                setElementData(sourceVeh, "radio.volume", math.round(num, 0))
                --outputChatBox(num)
            end
        end
    end
)

local animX = 0
local animState = false
local animDes = ">>"
local ax, ay = pos["x"], 0
local nowAnimX = 0
local alpha = 0

function createLogoAnim()
    --[[
    animX = 210
    animState = true
    animDes = ">>"
    addEventHandler("onClientRender", root, drawnAnim, true, "low")
    ax, ay = pos["x"], 0
    aw, ah = 210, 188
    nowAnimX = 0
    startTime = getTickCount()
	endTime = startTime + 2000
    alpha = 255
    tickCount = 0
    ]]
end

function drawnAnim()
    local ax, ay = pos["x"], pos["y"]- y/2 - 110
    if animDes == ">>" then
        local now = getTickCount()
	    local elapsedTime = now - startTime
	    local duration = endTime - startTime
	    local progress = elapsedTime / duration

	    local x, y, z = interpolateBetween ( 
		    ax - (188/2)/2, 0, 0,
		    ax - (188/2)/2 - 210/2, 0, 0, 
		    progress, "OutBounce")
    
        if progress >= 1 then
            alpha = alpha + 1
            if alpha >= 255 then
                tickCount = tickCount + 1
                if tickCount > 8 then
                    alpha = 255
                    animDes = "<<"
                    tickCount = 0
                    startTime = getTickCount()
	                endTime = startTime + 2000
                else
                    alpha = 0
                end
            end
            dxDrawImage(x, ay + 10, 188/2, 188/2, "files/logo.png", 0,0,0,tocolor(255,255,255,alpha))
            dxDrawImage(x + (155)/2, ay - 45, 210, 188, "files/staymta.png", 0,0,0,tocolor(255,255,255,alpha))
        else
            dxDrawImage(x, ay + 10, 188/2, 188/2, "files/logo.png")
        end
    elseif animDes == "<<" then
        local now = getTickCount()
	    local elapsedTime = now - startTime
	    local duration = endTime - startTime
	    local progress = elapsedTime / duration

	    local x, y, z = interpolateBetween ( 
		    ax - (188/2)/2 - 210/2, 0, 0,
		    ax - (188/2)/2, 0, 0, 
		    progress, "OutBounce")
    
        dxDrawImage(x, ay + 10, 188/2, 188/2, "files/logo.png")
        
        if progress >= 1 then
            tickCount = tickCount + 0.5
            if tickCount >= 255 then
                animState = false
                removeEventHandler("onClientRender", root, drawnAnim)
                createLogoAnim()
            end
        end
    end
end

function stopLogoAnim()
    --removeEventHandler("onClientRender", root, drawnAnim)
    --animState = false
end

function interactRadio()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" or getVehicleType(veh)  == "Bike" then
            if state == nil then state = false end
            state = not state
            if state then
                nowChannel = getElementData(veh, "radio.channel") or 1
                sourceVeh = veh
                addEventHandler("onClientRender", root, drawnRadio, true, "low-5")
                createLogoAnim()
            else
                removeEventHandler("onClientRender", root, drawnRadio)
                stopLogoAnim()
            end
        end
    end
end
bindKey("R", "down", interactRadio)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if state then
                local x = x
                if getElementData(sourceVeh, "radio.state") then
                    local channelName = channels[nowChannel][1]
                    local musicName = channelName .. " >> " .. musicName
                    local musicNameWidth = dxGetTextWidth(musicName, 1, font)
                    if musicNameWidth > x * 0.95 then
                        x = musicNameWidth + 60
                    end
                    if getPedOccupiedVehicleSeat(localPlayer) > 1 then
                        local y = y * 0.65
                        if isInSlot(pos["x"]-x/2, pos["y"]-y/2, x, 20) then -- Felső rész
                            local cx, cy = exports['cr_core']:getCursorPosition()
                            realMoving = true
                            local x, y = pos["x"], pos["y"]
                            dX, dY = cx - x, cy - y
                        end
                    else
                        if isInSlot(pos["x"]-x/2, pos["y"]-y/2, x, 20) then -- Felső rész
                            local cx, cy = exports['cr_core']:getCursorPosition()
                            realMoving = true
                            local x, y = pos["x"], pos["y"]
                            dX, dY = cx - x, cy - y
                        end
                    end
                else
                    if getPedOccupiedVehicleSeat(localPlayer) > 1 then
                        local y = y * 0.2
                        if isInSlot(pos["x"]-x/2, pos["y"]-y/2, x, 20) then -- Felső rész
                            local cx, cy = exports['cr_core']:getCursorPosition()
                            realMoving = true
                            local x, y = pos["x"], pos["y"]
                            dX, dY = cx - x, cy - y
                        end
                    else
                        local y = y * 0.5
                        if isInSlot(pos["x"]-x/2, pos["y"]-y/2, x, 20) then -- Felső rész
                            local cx, cy = exports['cr_core']:getCursorPosition()
                            realMoving = true
                            local x, y = pos["x"], pos["y"]
                            dX, dY = cx - x, cy - y
                        end
                    end
                end
                local nx = x * 0.95
                local ny = 15
                local x2, y3 = 240/2, 100/2
                if getPedOccupiedVehicleSeat(localPlayer) > 1 or getVehicleType(sourceVeh) == "Bike" and getPedOccupiedVehicleSeat(localPlayer) == 1 then return end
                local y = y
                if not getElementData(sourceVeh, "radio.state") then
                    y = y * 0.5
                end
                if isInSlot(pos["x"]-x2/2, pos["y"]+y/2 - (5 + y3), 40, 42) then -- Back
                    if isTimer(spamTimer) then return end
                    spamTimer = setTimer(function() end, 500, 1)
                    if not getElementData(sourceVeh, "radio.state") then return end
                    nowChannel = getElementData(sourceVeh, "radio.channel") or 1
                    if nowChannel - 1 >= 1 then
                        nowChannel = nowChannel - 1
                        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                            if getVehicleType(sourceVeh) ~= "BMX" and getVehicleType(sourceVeh) ~= "Bike" and getVehicleType(sourceVeh) ~= "Quad" then
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                            end
                        end
                        setElementData(sourceVeh, "radio.channel", nowChannel)
                        playSound("files/gomb.mp3")
                    end
                elseif isInSlot(pos["x"]-x2/2+42, pos["y"]+y/2 - (5 + y3), 38, 42) then -- Play / Stop
                    if isTimer(spamTimer) then return end
                    spamTimer = setTimer(function() end, 500, 1)
                    local oldState = getElementData(sourceVeh, "radio.state")
                    setElementData(sourceVeh, "radio.state", not oldState)
                    local newState = not oldState
                    if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                        if getVehicleType(sourceVeh) ~= "BMX" and getVehicleType(sourceVeh) ~= "Bike" and getVehicleType(sourceVeh) ~= "Quad" then
                            setElementData(localPlayer, "animation", {"", ""})
                            setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                        end
                    end
                    if newState then
                        exports['cr_chat']:createMessage(localPlayer, "bekapcsolja egy jármű rádióját", 1)
                    else
                        exports['cr_chat']:createMessage(localPlayer, "kikapcsolja egy jármű rádióját", 1)
                    end
                    playSound("files/gomb.mp3")
                elseif isInSlot(pos["x"]-x2/2+82, pos["y"]+y/2 - (5 + y3), 40, 42) then -- Next
                    if isTimer(spamTimer) then return end
                    spamTimer = setTimer(function() end, 500, 1)
                    if not getElementData(sourceVeh, "radio.state") then return end
                    nowChannel = getElementData(sourceVeh, "radio.channel") or 1
                    if nowChannel + 1 <= #channels then
                        nowChannel = nowChannel + 1
                        if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                            if getVehicleType(sourceVeh) ~= "BMX" and getVehicleType(sourceVeh) ~= "Bike" and getVehicleType(sourceVeh) ~= "Quad" then
                                setElementData(localPlayer, "animation", {"", ""})
                                setElementData(localPlayer, "animation", {"PED", "Car_tune_radio"})
                            end
                        end
                        setElementData(sourceVeh, "radio.channel", nowChannel)
                        playSound("files/gomb.mp3")
                    end
                elseif isInSlot(pos["x"]-nx/2, pos["y"]+y/2 - (10 + 50 + ny), nx, ny) then
                    if isTimer(spamTimer2) then return end
                    spamTimer2 = setTimer(function() end, 350, 1)
                    if not getElementData(sourceVeh, "radio.state") then return end
                    soundMoving = true
                    local cx, cy = cursorX, cursorY
                    local x = x
                    if getElementData(sourceVeh, "radio.state") then
                        local channelName = channels[nowChannel][1]
                        local musicName = channelName .. " >> " .. musicName
                        local musicNameWidth = dxGetTextWidth(musicName, 1, font)
                        if musicNameWidth > x * 0.95 then
                            x = musicNameWidth + 60
                        end
                    end
                    local nx = x * 0.95
                    local ny = 15
                    local maxX = pos["x"]-nx/2
                    local minX = pos["x"]+nx/2
                    if cx >= maxX and cx <= minX then
                        local num = math.round((cx - maxX) / nx * 100, 1)
                        setElementData(sourceVeh, "radio.volume", math.round(num, 0))
                        --outputChatBox(num)
                    end
                end
            end
        elseif b == "left" and s == "up" then
            if realMoving then
                realMoving = false
            end
            if soundMoving then
                soundMoving = false
            end
        end
    end
)

setTimer(
    function()
        if isElement(sound) then
            local details = getSoundMetaTags(sound)
            musicName = details["title"]
            if not musicName then
                musicName = details["stream_title"]
                if not musicName then
                    musicName = "Ismeretlen zene cím"
                end
            end    
        end
    end, 1000, 0
)

function drawnRadio()
    if not getPedOccupiedVehicle(localPlayer) then return end
    if getElementData(sourceVeh, "radio.state") then
        if not isElement(sound) then
            startMusic(sourceVeh)
            return
        end
        local x = x
        local channelName = channels[nowChannel][1]
        local musicName = channelName .. " >> " .. musicName
        local musicNameWidth = dxGetTextWidth(musicName, 1, font)
        if musicNameWidth > x * 0.95 then
            x = musicNameWidth + 60
        end
        if getPedOccupiedVehicleSeat(localPlayer) > 1 or getVehicleType(sourceVeh) == "Bike" and getPedOccupiedVehicleSeat(localPlayer) == 1 then
            local y = y * 0.65
            dxDrawnBorder(pos["x"]-x/2, pos["y"]-y/2, x, y, tocolor(0,0,0,150), tocolor(0,0,0,255))
            local x2, y2 = x * 0.95, 25
            linedRectangle(pos["x"]-x2/2, pos["y"]-y/2 + 10, x2, y2, tocolor(20,20,20,120), tocolor(0,0,0,180))
            linedRectangle(pos["x"]-(x2 - 50)/2, pos["y"]-y/2 + y2 + 20, x2 - 50, 256/3, tocolor(20,20,20,120), tocolor(0,0,0,180))
            if not value["disabled"] then
                local bt = getSoundFFTData(sound,2048,(x2 - 100) + 1)
                local startX = pos["x"] - (x2 - 100)/2
                if bt then
                    for i=1,(x2 - 100) do
                        bt[i] = math.sqrt(bt[i])* (256/2.8) --scale it (sqrt to make low values more visible)
                        dxDrawRectangle(startX + 1, pos["y"]-y/2 + y2 + 20 + 256/3, 1, -bt[i])
                        startX = startX + 1
                    end
                end
            end
            local xStart, xEnd = pos["x"]
            local yStart = pos["y"]-y/2 + 10
            local yEnd = pos["y"]-y/2 + 10 + y2
            dxDrawText(musicName, xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "center", "center")
        else
            dxDrawnBorder(pos["x"]-x/2, pos["y"]-y/2, x, y, tocolor(0,0,0,150), tocolor(0,0,0,255))
            local x2, y2 = x * 0.95, 25
            linedRectangle(pos["x"]-x2/2, pos["y"]-y/2 + 10, x2, y2, tocolor(20,20,20,120), tocolor(0,0,0,180))
            linedRectangle(pos["x"]-(x2 - 50)/2, pos["y"]-y/2 + y2 + 20, x2 - 50, 256/3, tocolor(20,20,20,120), tocolor(0,0,0,180))
            if not value["disabled"] then
                local bt = getSoundFFTData(sound,2048,x2 - 100 + 1)
                local startX = pos["x"] - (x2 - 100)/2
                if bt then
                    for i=1,x2 - 100 do
                        bt[i] = math.sqrt(bt[i])* (256/2.8) --scale it (sqrt to make low values more visible)
                        dxDrawRectangle(startX + 1, pos["y"]-y/2 + y2 + 20 + 256/3, 1, -bt[i])
                        startX = startX + 1
                    end
                end
            end
            local xStart, xEnd = pos["x"]
            local xStart, xEnd = pos["x"]
            local yStart = pos["y"]-y/2 + 10
            local yEnd = pos["y"]-y/2 + 10 + y2
            dxDrawText(musicName, xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "center", "center")

            local nx = x * 0.95
            local ny = 15
            local soundVolume = getElementData(sourceVeh, "radio.volume") or 100
            local realX = nx * (soundVolume / 100)
            linedRectangle(pos["x"]-nx/2, pos["y"]+y/2 - (10 + 50 + ny), nx, ny, tocolor(90,90,90,180), tocolor(0,0,0,255))
            local color
            if realX <= nx * 0.2 then
                color = tocolor(r,g,b,180)
            elseif realX > nx * 0.2 and realX < nx * 0.8 then
                color = tocolor(or1,og,ob,180)
            elseif realX >= nx * 0.8 then
                color = tocolor(gr,gg,gb,180)
            end
            dxDrawRectangle(pos["x"]-nx/2, pos["y"]+y/2 - (10 + 50 + ny), realX, ny, color)

            --[[
            local sizeX = 330
            local sizeY = 15
            local x = pos["x"]-x/2+305-sizeX/2
            local y = pos["y"]-y/2+17
            linedRectangle(x, y, sizeX, sizeY, tocolor(20,20,20,120), tocolor(0,0,0,180)) -- 20 > 32 Y
            ]]
            local x2, y3 = 240/2, 100/2
            dxDrawImage(pos["x"]-x2/2, pos["y"]+y/2 - (5 + y3), x2, y3, "files/icons2.png")

            local nowChannel = nowChannel

            if nowChannel - 1 > 0 then
                local xStart, yStart = pos["x"]-x2/2 - 20, pos["y"]+y/2 - (5 + y3)
                local xEnd, yEnd = pos["x"]-x2/2 - 20, pos["y"]+y/2 - (5 + y3) + y3
                dxDrawText(channels[nowChannel - 1][1], xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "right", "center")
            end

            if nowChannel + 1 <= #channels then
                local xStart, yStart = pos["x"]+x2/2 + 20, pos["y"]+y/2 - (5 + y3)
                local xEnd, yEnd = pos["x"]+x2/2 + 20, pos["y"]+y/2 - (5 + y3) + y3
                dxDrawText(channels[nowChannel + 1][1], xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "left", "center")
            end
            --[[
            dxDrawRectangle(pos["x"]-x2/2, pos["y"]+y/2 - (5 + y3), 40, 42) -- Back
            dxDrawRectangle(pos["x"]-x2/2+42, pos["y"]+y/2 - (5 + y3), 38, 42) -- Play
            dxDrawRectangle(pos["x"]-x2/2+82, pos["y"]+y/2 - (5 + y3), 40, 42) -- Next
            ]]
        end
    else
        if getPedOccupiedVehicleSeat(localPlayer) > 1 or getVehicleType(sourceVeh) == "Bike" and getPedOccupiedVehicleSeat(localPlayer) == 1 then
            local y = y * 0.2
            dxDrawnBorder(pos["x"]-x/2, pos["y"]-y/2, x, y, tocolor(0,0,0,150), tocolor(0,0,0,255))
            local x2, y2 = x * 0.95, 25
            linedRectangle(pos["x"]-x2/2, pos["y"]-y/2 + 10, x2, y2, tocolor(20,20,20,120), tocolor(0,0,0,180))
            local xStart, xEnd = pos["x"]
            local yStart = pos["y"]-y/2 + 10
            local yEnd = pos["y"]-y/2 + 10 + y2
            dxDrawText("Kikapcsolva", xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "center", "center")
            --linedRectangle(x, y, sizeX, sizeY, tocolor(90,90,90,180), tocolor(0,0,0,180)) -- 20 > 32 Y
            --local x2, y3 = 240/2, 100/2
            --dxDrawImage(pos["x"]-x2/2, pos["y"]+y/2 - (5 + y3), x2, y3, "files/icons.png")
        else
            local y = y * 0.5
            dxDrawnBorder(pos["x"]-x/2, pos["y"]-y/2, x, y, tocolor(0,0,0,150), tocolor(0,0,0,255))
            local x2, y2 = x * 0.95, 25
            linedRectangle(pos["x"]-x2/2, pos["y"]-y/2 + 10, x2, y2, tocolor(20,20,20,120), tocolor(0,0,0,180))
            local xStart, xEnd = pos["x"]
            local yStart = pos["y"]-y/2 + 10
            local yEnd = pos["y"]-y/2 + 10 + y2
            dxDrawText("Kikapcsolva", xStart, yStart, xEnd, yEnd, tocolor(255,255,255,255), 1, font, "center", "center")
            --linedRectangle(x, y, sizeX, sizeY, tocolor(90,90,90,180), tocolor(0,0,0,180)) -- 20 > 32 Y
            local x2, y3 = 240/2, 100/2
            dxDrawImage(pos["x"]-x2/2, pos["y"]+y/2 - (5 + y3), x2, y3, "files/icons.png")
        end
    end
end

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName)
        local value = getElementData(source, dName)
        if dName == "inDeath" then
            if value then
                if state then
                    removeEventHandler("onClientRender", root, drawnRadio)
                    state = false
                    stopLogoAnim()
                end
                stopMusic(sourceVeh)
            end
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh == source then
                if state then
                    removeEventHandler("onClientRender", root, drawnRadio)
                    state = false
                    stopLogoAnim()
                end
            end
            stopMusic(source)
        end
    end
)

addEventHandler("onClientPlayerVehicleExit", root,
    function(veh, seat)
        if source == localPlayer then
            if state then
                removeEventHandler("onClientRender", root, drawnRadio)
                state = false
                stopLogoAnim()
            end
            stopMusic(veh)
            sourceVeh = nil
            for k,v in pairs(getElementsByType("vehicle", root, true)) do
                if getElementData(v, "radio.state") then
                    if not getElementData(v, "veh >> windowState") then
                        startMusic(v)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientPlayerVehicleEnter", root,
    function(veh, seat)
        if source == localPlayer then
            if getElementData(veh, "radio.state") then
                nowChannel = getElementData(veh, "radio.channel") or 1
                --outputChatBox(nowChannel)
                sourceVeh = veh
                stopMusic(veh)
                startMusic(veh)
            end
            if getElementData(veh,"veh >> windowState") then
                for k,v in pairs(sounds) do
                    stopMusic(k)
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if not veh then
                if not getElementData(source, "veh >> windowState") then
                    if getElementData(source, "radio.state") then
                        startMusic(source)
                    end
                end
            elseif veh and not getElementData(veh, "veh >> windowState") then
                if not getElementData(source, "veh >> windowState") then
                    if getElementData(source, "radio.state") then
                        startMusic(source)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if getElementType(source) == "vehicle" then
            if sounds[source] then
                stopMusic(source)
            end
        end
    end
)

addEventHandler("onClientElementDataChange", root, 
    function(dName)
        if getElementType(source) ~= "vehicle" then return end
        local veh = getPedOccupiedVehicle(localPlayer)
        if dName == "radio.volume" then
            if veh == source then
                if not isElement(sound) then return end
                local soundVolume = getElementData(source, "radio.volume") or 100
                setSoundVolume(sound, soundVolume / 100)
            elseif sounds[source] then
                if not isElement(sounds[source]) then return end
                local soundVolume = getElementData(source, "radio.volume") or 100
                setSoundMaxDistance(sounds[source], 40 * (soundVolume / 100))
                setSoundVolume(sounds[source], soundVolume / 100)
            end
        end
        if veh and veh == source then
            local value = getElementData(source, dName)
            if dName == "radio.state" then
                stopMusic(source)
                if value then
                    startMusic(source)
                end
            elseif dName == "radio.channel" then
                stopMusic(source)
                if value then
                    startMusic(source)
                end
            elseif dName == "veh >> windowState" then
                if value then
                    for k,v in pairs(sounds) do
                        stopMusic(k)
                    end
                else
                    for k,v in pairs(getElementsByType("vehicle", root, true)) do
                        if getElementData(v, "radio.state") then
                            if not getElementData(v, "veh >> windowState") then
                                startMusic(v)
                            end
                        end
                    end
                end
            end
        elseif veh and veh ~= source then -- Ha másik kocsiban ül és levan húzva az ablakja és a másiknak is levan húzva az ablakja akkor hallhatja a zenét
            if isElementStreamedIn(source) then
                if not getElementData(source, "veh >> windowState") and not getElementData(veh, "veh >> windowState") then
                    if getElementData(source, "radio.state") then
                        local value = getElementData(source, dName)
                        if dName == "radio.state" then
                            stopMusic(source)
                            if value then
                                startMusic(source)
                            end
                        elseif dName == "radio.channel" then
                            stopMusic(source)
                            if value then
                                startMusic(source)
                            end
                        elseif dName == "veh >> windowState" then
                            if value then
                                stopMusic(source)
                            else
                                startMusic(source)
                            end
                        end
                    elseif not getElementData(source, "radio.state") then
                        stopMusic(source)
                    end
                elseif getElementData(source, "veh >> windowState") then
                    stopMusic(source)
                end
            end
        else -- Gyalogos , ha levan húzva a kocsiban az ablak akkor hallhatja a zenét
            if isElementStreamedIn(source) then
                if not getElementData(source, "veh >> windowState") then
                    if getElementData(source, "radio.state") then
                        local value = getElementData(source, dName)
                        if dName == "radio.state" then
                            stopMusic(source)
                            if value then
                                startMusic(source)
                            end
                        elseif dName == "radio.channel" then
                            stopMusic(source)
                            if value then
                                startMusic(source)
                            end
                        elseif dName == "veh >> windowState" then
                            if value then
                                stopMusic(source)
                            else
                                startMusic(source)
                            end
                        end
                    elseif not getElementData(source, "radio.state") then
                        stopMusic(source)
                    end
                elseif getElementData(source, "veh >> windowState") then
                    stopMusic(source)
                end
            end
        end
    end
)