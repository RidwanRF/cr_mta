function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

function dxDrawRoundedRectangle2(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y - radius, radius, ry + radius * 2, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        --dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        --dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

function dxDrawRoundedRectangle3(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        --dxDrawRectangle(x - radius, y, radius, ry, color)
        --dxDrawRectangle(x + rx, y - radius, radius, ry + radius * 2, color)
        dxDrawRectangle(x - radius, y - radius, radius, ry + radius * 2, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        --dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        --dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end

local colors = {
    ["error"] = {"#ff3333", {255,51,51}},
    ["warning"] = {"#ff6333", {255,99,51}},
    ["info"] = {"#3398ff", {51,152,255}},
}

local cache = {}

function addBox(msg, type)
    if colors[type] then
        local length = #cache
        if length + 1 > 4 then
            table.remove(cache, 1)
        end
        
        playSound("files/beep.mp3")
        
        local line = 0
        local latest = 0
        
        while true do
            local a, b = utf8.find(msg, "\n", latest)
            if a and b then
                latest = b + 1
                line = line + 1
            else
                break
            end
        end
        
        table.insert(cache, 
            {
                ["msg"] = msg, 
                ["length"] = dxGetTextWidth(msg .. "a",1,exports['cr_fonts']:getFont("Rubik-Regular", 11),true) + 10, 
                ["now"] = getTickCount(), 
                ["end"] = getTickCount() + 1000, 
                ["state"] = "y", 
                ["type"] = type, 
                ["lines"] = line,
                ["tick"] = 0,
            }
        )
        --outputConsole("["..type.."] "..string.gsub(msg, "#%x%x%x%x%x%x", ""))
        
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
addEvent("showAdminBox", true)
addEventHandler("showAdminBox", root, addBox)

local fonts = {}
local sx, sy = guiGetScreenSize()

function drawnBoxes()
    --fonts["default-regular"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    fonts["default-regular-small"] = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    --fonts["default-bold"] = exports['cr_fonts']:getFont("Rubik-Black", 12)

    _sx, _sy = sx, sy
    local enabled, sx, nowY, w,h,sizable,turnable, sizeDetails, t, columns = exports['cr_interface']:getDetails("kick/ban")
    _nowY = nowY
    sx = sx + 24
    for k,v in pairs(cache) do
        local msg = v["msg"]
        local length = v["length"]
        local startTime = v["now"]
        local endTime = v["end"]
        local state = v["state"]
        local type = v["type"]
        local tick = v["tick"]
        local line = v["lines"]
        local boxSize = (dxGetFontHeight(1,fonts["default-regular-small"]) * line) + 15
        --outputChatBox(line)
        
        local r,g,b = unpack(colors[type][2])
        
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

                dxDrawRoundedRectangle(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
                --dxDrawImage(sx + boxSize/2 - 13, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
                --dxDrawImage(sx - boxSize/2 - 18, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
                --dxDrawText(icon, sx, y + boxSize/2, sx, y + 5boxSize/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
                --local
                local x, y, w, h = sx - 34/2 + 10/2, y + boxSize/2 - 24/2, 24, 24 
                dxDrawImage(x, y, w, h, "icons/"..type..".png")
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

            dxDrawRoundedRectangle2(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
            dxDrawRoundedRectangle3(sx + 34/2, y, x, boxSize, tocolor(0,0,0,180), 50 * 0.2)
            --dxDrawImage(sx + x/2 + boxSize/2 - 13.5, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
            --dxDrawImage(sx - boxSize/2 - x/2 - 18.5, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
            --dxDrawText(icon, sx - boxSize/2 - x/2, y + 30/2, sx - boxSize/2 - x/2 + boxSize, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            --local x, y, w, h = sx - boxSize/2 + 10/2, y + boxSize/2 - 24/2, 24, 24 
            dxDrawImage(sx - 34/2 + 10/2, y + boxSize/2 - 24/2, 24, 24, "icons/"..type..".png")
            
            if progress >= 6 then
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 2000
                cache[k]["state"] = "x - end"
            elseif progress >= 1 then
                dxDrawText(msg, sx + 34/2, y, sx + 34/2 + x, y + boxSize, tocolor(255,255,255,220), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
            end
        elseif state == "x - end" then
            local now = getTickCount()
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration
            
            --if progress < 1 then
            local y = nowY + 2
            local x = math.floor(interpolateBetween(length, 0, 0, 0, 0, 0, progress, "InBounce"))

            dxDrawRoundedRectangle3(sx + 34/2, y, x, boxSize, tocolor(0,0,0,180), 50 * 0.2)
            --dxDrawImage(sx + x/2 + boxSize/2 - 13.5, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
            --dxDrawImage(sx - boxSize/2 - x/2 - 18.5, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
            --dxDrawText(icon, sx - boxSize/2 - x/2, y + 30/2, sx - boxSize/2 - x/2 + boxSize, y + 30/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
            --local x, y, w, h = sx - boxSize/2 + 10/2, y + boxSize/2 - 24/2, 24, 24 
            
            if progress >= 1.4 then
                dxDrawRoundedRectangle(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
                cache[k]["now"] = getTickCount()
                cache[k]["end"] = getTickCount() + 1000
                cache[k]["state"] = "y - end"
            elseif progress >= 0.9 then
                dxDrawRoundedRectangle(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
            else
                dxDrawRoundedRectangle2(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
            end
            
            dxDrawImage(sx - 34/2 + 10/2, y + boxSize/2 - 24/2, 24, 24, "icons/"..type..".png")
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

                dxDrawRoundedRectangle(sx - 34/2, y, 34, boxSize, tocolor(r,g,b,180), 50 * 0.2)
                --dxDrawImage(sx + boxSize/2 - 13, y - 1, 32, 32, "files/right.png", 0,0,0, tocolor(r,g,b,180))
                --dxDrawImage(sx - boxSize/2 - 18, y - 1, 32, 32, "files/left.png", 0,0,0, tocolor(r,g,b,180))
                --dxDrawText(icon, sx, y + boxSize/2, sx, y + 5boxSize/2, tocolor(255,255,255,220), 1, fonts["awesomeFont"], "center", "center")
                --local
                local x, y, w, h = sx - 34/2 + 10/2, y + boxSize/2 - 24/2, 24, 24 
                dxDrawImage(x, y, w, h, "icons/"..type..".png")
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
        nowY = nowY + 5 + boxSize
    end
end