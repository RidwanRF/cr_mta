addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if dName == "hifi >> movedBy" then
            local val = source:getData(dName)
            if val then
                if oValue then
                    if val ~= oValue then
                        if localPlayer == val then
                            --source:setData("hifi >> movedBy", oValue)
                            exports['cr_elementeditor']:resetEditorElementChanges(true)
                        end
                    end
                end
            end
        end
    end
)

addEvent("onSaveHifiPositionEditor",true)
addEventHandler("onSaveHifiPositionEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
--        triggerServerEvent("onHifiSetPosition",element,element, x, y, z, rx, ry, rz)
        --outputChatBox("awsd")
        --tputChatBox(exports['cr_core']:getServerSyntax("Hifi", "success") .. "sikeresen megváltoztattad egy hifi pozicióját!")
        triggerServerEvent("updateHifiPosition", localPlayer, element, x,y,z)
        triggerServerEvent("updateHifiRotation", localPlayer, element, {rx,ry,rz})
        triggerServerEvent("hifiChangeState", localPlayer, element, 255)
        element:setData("hifi >> movedBy", nil)
        --is_lines_rendered = true
    end
)

local nearest = nil
local cache = {}
local soundCache = {}

function getNearest()
    nearest = nil
    local dist = 9999
    for v, k in pairs(cache) do
        if v.model == 2102 then
            if getDistanceBetweenPoints3D(localPlayer.position, v.position) <= 16 then
                if getDistanceBetweenPoints3D(localPlayer.position, v.position) <= dist then
                    nearest = v
                    dist = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                end
            end
        end
    end
    
    if isElement(nearest) then
        local pos = nearest.matrix
        local lines = 
        {
            {nil,nil},
            {pos:transformPosition(0.3,0,0.3),pos:transformPosition(0.3,0,0.5)},
            {pos:transformPosition(0.2,0,0.3),pos:transformPosition(0.2,0,0.5)},
            {pos:transformPosition(0.1,0,0.3),pos:transformPosition(0.1,0,0.5)},
            {pos:transformPosition(0,0,0.3),pos:transformPosition(0,0,0.5)},
            {pos:transformPosition(-0.1,0,0.3),pos:transformPosition(-0.1,0,0.5)},
            {pos:transformPosition(-0.2,0,0.3),pos:transformPosition(-0.2,0,0.5)},
            {pos:transformPosition(-0.3,0,0.3),pos:transformPosition(-0.3,0,0.5)},
        } 
        local h_pos = pos:transformPosition(0,0,0.5)
         --setElementPosition( hifi_sync[element][2],getElementPosition(element))
        values = {nearest,soundCache[nearest],lines,h_pos}
        
        if not renderState then
            renderState = true
            addEventHandler("onClientRender", root, drawnLines, true, "low-5")
        end
    else
        if renderState then
            renderState = false
            removeEventHandler("onClientRender", root, drawnLines)
        end
    end
end
setTimer(getNearest, 200, 0)

function startSync(e)
    stopSync(e)
    
    --outputChatBox("asd")
    
    cache[e] = e:getData("hifi >> channel") or 1
    local channels = exports['cr_radio']:getChannels()
    local url = channels[e:getData("hifi >> channel") or 1][2]
    --outputChatBox(url)
    local sound = playSound3D(url, e.position)
    --setSoundMaxDistance(sound, 16)
    
    soundCache[e] = sound
end

function stopSync(e)
    if isElement(soundCache[e]) then
        destroyElement(soundCache[e])
    end
    soundCache[e] = nil
    cache[e] = nil
end

function onStart()
    for k,v in pairs(getElementsByType("object", _, true)) do
        if v.model == 2102 then
            --outputChatBox("asd")
            if v:getData("hifi >> state") then
                startSync(v)
            end
        end
    end
    
    local enabled = exports['cr_json']:jsonGET("@radio_settings.json", true)
    is_lined_enabled = enabled[1]
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
    exports['cr_json']:jsonSAVE("@radio_settings.json", {is_lined_enabled}, true)
    --is_lined_enabled = not enabled[1]
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source:getData("hifi >> state") then
            startSync(source)
        end
    end
)

addEventHandler("onClientElementStreamOut", root,
    function()
        if source:getData("hifi >> state") then
            stopSync(source)
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if isElementStreamedIn(source) then
            if dName == "hifi >> state" then
                local val = source:getData(dName)
                if val then
                    startSync(source)
                else
                    stopSync(source)
                end
            elseif dName == "hifi >> channel" then
                startSync(source)
            end
        end
    end
)

function drawnLines()
    if not is_lined_enabled then
        local sound_data = false
        --local values = sound_data
        if  not isSoundPaused (values[2]) then sound_data = getSoundFFTData(values[2],4096,12) end
        if sound_data  then
            if isElementOnScreen(values[1]) then
                for i = 1,11 do				
                    sound_data[i] = sound_data[i]*5
                    if sound_data[i] > 1 then sound_data[i] = 1
                    elseif sound_data[i] < 0.1 then sound_data[i] = 0.1 end
                     --sound_data[i] = --math.round(sound_data[i],10,"floor") 				 
                end	
                
                for i = 2,8 do
                    dxDrawLine3D(values[3][i][1]:getX(),values[3][i][1]:getY(),values[3][i][1]:getZ(),values[3][i][2]:getX(),values[3][i][2]:getY(),values[3][i][2]:getZ()+(values[3][i][2]:getZ()-values[3][i][1]:getZ())*sound_data[12-i]*1.5,tocolor(249,154,51,150),3)
                end
            end
        end
    end
end



addCommandHandler("toghifilines",function()
	is_lined_enabled = not is_lined_enabled
end)

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

