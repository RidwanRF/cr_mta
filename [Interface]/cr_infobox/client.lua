local mcrBoxes = 4
local cache = {}
local sx, sy = guiGetScreenSize()
local renderState = false
local types = {}
local fonts = {}

function onResourceStart()
    local res = Resource.getFromName("cr_core") 
    if res and res.state == "running" then
        engine = exports['cr_core']
        types = {
            --[type] = {"awesomeIcon", r,g,b}
            ["warning"] = {"", {engine:getServerColor('lightyellow', false)}},
            ["error"] = {"", {engine:getServerColor('red', false)}},
            ["info"] = {"", {engine:getServerColor('blue', false)}},
            ["success"] = {"", {engine:getServerColor('green', false)}},
            ["aduty"] = {engine:getIcon("fa-users"), {255, 200, 0}},
            ["kick"] = {engine:getIcon("fa-eye-slash"), {124, 197, 118}},
            ["ban"] = {engine:getIcon("fa-ban"), {114, 20, 20}},
        }
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)

local fontsize = 1

function onCoreStart(startedRes)    
    if getResourceName(startedRes) == "cr_core" then
        engine = exports['cr_core']
        types = {
            --[type] = {"awesomeIcon", r,g,b}
            ["warning"] = {"", {engine:getServerColor('lightyellow', false)}},
            ["error"] = {"", {engine:getServerColor('red', false)}},
            ["info"] = {"", {engine:getServerColor('blue', false)}},
            ["success"] = {"", {engine:getServerColor('green', false)}},
            ["aduty"] = {engine:getIcon("fa-users"), {255, 200, 0}},
            ["kick"] = {engine:getIcon("fa-eye-slash"), {124, 197, 118}},
            ["ban"] = {engine:getIcon("fa-ban"), {114, 20, 20}},
        }
    end
end
addEventHandler("onClientResourceStart", root, onCoreStart)
--Fentről lejön, szétnyílik. 5mpig nyitva van, ezután összecsukódik, lemegy a képernyő aljára

function addBox(type, msg)
    fonts["default-regular"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    fonts["default-regular-small"] = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    fonts["default-bold"] = exports['cr_fonts']:getFont("Rubik-Black", 12)
    fonts["awesomeFont"] = exports['cr_fonts']:getFont("AwesomeFont", 13)
    fonts["awesomeFont2"] = exports['cr_fonts']:getFont("AwesomeFont", 14)
    fonts["awesomeFont3"] = exports['cr_fonts']:getFont("AwesomeFont", 11)
    if types[type] then
        local length = #cache
        if length + 1 > mcrBoxes then
            table.remove(cache, 1)
        end
        
        local checkMSG = msg
        --[[
        if #checkMSG % 2 ~= 0 then
            checkMSG = "a" .. checkMSG
        end
        ]]
        local textLength = dxGetTextWidth(checkMSG, fontsize, fonts["default-regular-small"], true) + 10
        if textLength % 2 == 0 then
            textLength = textLength + 1
        end
        playSound("files/beep.mp3")
        table.insert(cache, 
            {
                ["msg"] = msg, 
                ["length"] = textLength, 
                ["now"] = getTickCount(), 
                ["end"] = getTickCount() + 1000, 
                ["state"] = "y", 
                ["type"] = type, 
                ["tick"] = 0,
            }
        )
        outputConsole("["..type.."] "..string.gsub(msg, "#%x%x%x%x%x%x", ""))
        
        --outputChatBox(#cache)
        if #cache >= 1 then
            --outputChatBox(tostring(state))
            if not renderState then
                --outputChatBox("Hozzáadva")
                renderState = true
                addEventHandler("onClientRender", root, drawnBoxes, true, "low-5")
            end
        end
    end
end

addEvent("addBox", true)
addEventHandler("addBox", root, addBox)
    
local between = 32
    
function drawnBoxes()
    fonts["default-regular"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    fonts["default-regular-small"] = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    fonts["default-bold"] = exports['cr_fonts']:getFont("Rubik-Black", 12)
    fonts["awesomeFont"] = exports['cr_fonts']:getFont("AwesomeFont", 13)
    fonts["awesomeFont2"] = exports['cr_fonts']:getFont("AwesomeFont", 14)
    fonts["awesomeFont3"] = exports['cr_fonts']:getFont("AwesomeFont", 11)
    _sx, _sy = sx, sy
    local enabled, sx, nowY, w,h,sizable,turnable, sizeDetails, t, columns = exports['cr_interface']:getDetails("infobox")
    _nowY = nowY
    sx = sx + w/2
    for k,v in pairs(cache) do
        local msg = v["msg"]
        local length = v["length"]
        local startTime = v["now"]
        local endTime = v["end"]
        local state = v["state"]
        local type = v["type"]
        local tick = v["tick"]
        local boxSize = 25 
        
        local r,g,b = unpack(types[type][2])
        local icon = types[type][1]
        
        if state == "y" then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            if progress < 1 then
                local y
                if _nowY >= _sy / 2 then
                    y = math.floor(interpolateBetween(sy + 400, 0, 0, nowY + 2, 0, 0, progress, "OutBack"))
                else
                    y = math.floor(interpolateBetween(-400, 0, 0, nowY + 2, 0, 0, progress, "OutBack"))
                end

                dxDrawRectangle(sx - boxSize/2, y, boxSize, 30, tocolor(r,g,b,180))
                dxDrawImage(sx + boxSize/2 - 13, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
                dxDrawImage(sx - boxSize/2 - 18, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
                dxDrawText(icon, sx, y + 30/2, sx, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            else 
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 1000
                cache[k]["state"] = "x"
            end
        elseif state == "x" then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            --if progress < 1 then
            local y = nowY + 2
            local x = math.floor(interpolateBetween(0, 0, 0, length, 0, 0, progress, "InBounce"))

            dxDrawRectangle(sx - boxSize/2 - x/2, y, boxSize, 30, tocolor(r,g,b,180))
            dxDrawRectangle(sx - x/2 + boxSize/2, y, x, 30, tocolor(r,g,b,180))
            dxDrawImage(sx + x/2 + boxSize/2 - 13.5, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
            dxDrawImage(sx - boxSize/2 - x/2 - 18.5, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
            dxDrawText(icon, sx - boxSize/2 - x/2, y + 30/2, sx - boxSize/2 - x/2 + boxSize, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            
            if progress >= 6 then
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 2000
                cache[k]["state"] = "x - end"
            elseif progress >= 1 then
                dxDrawText(msg, sx - x/2 + boxSize/2, y, sx - x/2 + boxSize/2 + x, y + 30, tocolor(255,255,255,220), 1, fonts["default-regular-small"], "center", "center")
            end
        elseif state == "x - end" then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            --if progress < 1 then
            local y = nowY + 2
            local x = math.floor(interpolateBetween(length, 0, 0, 0, 0, 0, progress, "InBounce"))

            dxDrawRectangle(sx - boxSize/2 - x/2, y, boxSize, 30, tocolor(r,g,b,180))
            dxDrawRectangle(sx - x/2 + boxSize/2, y, x, 30, tocolor(r,g,b,180))
            dxDrawImage(sx + x/2 + boxSize/2 - 13, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
            dxDrawImage(sx - boxSize/2 - x/2 - 18, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
            dxDrawText(icon, sx - boxSize/2 - x/2, y + 30/2, sx - boxSize/2 - x/2 + boxSize, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            
            if progress >= 1 then
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 5000
                cache[k]["state"] = "y - end"
            end
        elseif state == "y - end" then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            --outputChatBox(progress)
            
            if progress < 1 then
                local y
                if _nowY >= _sy / 2 then
                    y = math.floor(interpolateBetween(nowY + 2, 0, 0, sy + 400, 0, 0, progress, "OutBack"))
                else
                    y = math.floor(interpolateBetween(nowY + 2, 0, 0, -400, 0, 0, progress, "OutBack"))
                end
                
                --outputChatBox("Y" .. y)

                dxDrawRectangle(sx - boxSize/2, y, boxSize, 30, tocolor(r,g,b,180))
                dxDrawImage(sx + boxSize/2 - 13, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
                dxDrawImage(sx - boxSize/2 - 18, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
                dxDrawText(icon, sx, y + 30/2, sx, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            else 
                table.remove(cache, k)
                if #cache <= 0 then
                    --outputChatBox(tostring(renderState))
                    if renderState then
                        --outputChatBox("Render off")
                        renderState = false
                        removeEventHandler("onClientRender", root, drawnBoxes)
                    end
                end
            end
        end
        nowY = nowY + between
    end
end