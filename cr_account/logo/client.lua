local details = {}
local animRender = false
local r, g, b = 255, 153, 51
local showtime = 10000
local dr, dg, db = 0, 0, 0

function createLogoAnimation(type, pos)
    if type == 1 then
        details = {}
        details["x"] = pos[1]
        details["y"] = pos[2]
        details["type"] = type
        details["tick"] = 0
        details["state"] = 1
        details["index"] = 0
        details["r"] = 0
        details["g"] = 0
        details["b"] = 0
        if isTimer(timer) then
            killTimer(timer)
        end
        timer = setTimer(changeDetailsTimer, showtime, 1)
        startTime = getTickCount()
        endTime = startTime + 2000
        if not animRender then
            animRender = true
            addEventHandler("onClientRender", root, drawnAnim, true, "low-5")
        end
    end
end

function updateLogoPos(a)
    details["x"] = a[1]
    details["y"] = a[2]
end

local change = {
    [1] = 2,
    [2] = 1,
}

function changeDetailsTimer()
    local oldState = details["state"]
    details["state"] = change[oldState]
    
    if change[oldState] == 2 then
        startTime = getTickCount()
        endTime = startTime + 2000
    end
    
    timer = setTimer(changeDetailsTimer, showtime, 1)
end

function stopLogoAnimation()
    if animRender then
        animRender = false
        removeEventHandler("onClientRender", root, drawnAnim)
        if isTimer(timer) then
            killTimer(timer)
        end
    end
end

local multipler = 1

function drawnAnim()
    --outputChatBox("ASD2")
    if details["type"] == 1 then
        --outputChatBox("ASD")
        local now = getTickCount()
        local elapsedTime = now - startTime
        local duration = endTime - startTime
        local progress = elapsedTime / duration
        --local red, green, blue 
        
        if details["state"] == 1 then
            if details["tick"] + multipler <= 255 then
                details["tick"] = details["tick"] + multipler
                --outputChatBox(details["tick"])
                if details["tick"] >= 254 then
                    --outputChatBox("ASDD")
                    startTime = now
                    endTime = startTime + 2000
                end
            else
                if details["tick"] ~= 255 then
                    details["tick"] = 255
                end
            end
        elseif details["state"] == 2 then
            --outputChatBox("Try")
            if red == dr and green == dg and blue == db then
                --outputChatBox("TryS")
                if details["tick"] - multipler >= 0 then
                    details["tick"] = details["tick"] - multipler
                else
                    if details["tick"] ~= 0 then
                        details["tick"] = 0
                    end
                end
            end
        end
        
        if details["tick"] >= 255 then
            --local red, green, blue
            if details["state"] == 1 then
                red, green, blue = interpolateBetween( 
                    dr, dg, db,
                    r, g, b, 
                progress, "OutBounce")
            elseif details["state"] == 2 then
                red, green, blue = interpolateBetween( 
                    r, g, b,
                    dr, dg, db, 
                progress, "OutBounce")
            end
        end
        
        if not red then red = dr end
        if not green then green = dg end
        if not blue then blue = db end
        
        dxDrawImage(details["x"] - size["logo-image-X"]/2, details["y"] - size["logo-image-Y"]/2, size["logo-image-X"], size["logo-image-Y"], "files/logo.png", 0,0,0, tocolor(red,green,blue, details["tick"]))
        dxDrawImage(details["x"] - size["logo-image-X"]/2, details["y"] - size["logo-image-Y"]/2, size["logo-image-X"], size["logo-image-Y"], "files/logo-text.png", 0,0,0, tocolor(255,255,255, details["tick"]))
    end
end