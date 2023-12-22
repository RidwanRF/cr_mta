local sounds = {}
soundActive = false

function startLoginSound()
    sounds["element"] = playSound("files/login-sound.mp3", true)
    a = setTimer(
        function()
            setSoundVolume(sounds["element"], saveJSON["soundVolume"])
        end, 1000, 1
    )
    soundActive = true
    addEventHandler("onClientRender", root, drawnSoundMultipler, true, "low-5")
end

function stopLoginSound()
    if isTimer(a) then
        killTimer(a)
    end
    if isElement(sounds["element"]) then
        destroyElement(sounds["element"])
        sounds["element"] = nil
    end
    soundActive = false
    removeEventHandler("onClientRender", root, drawnSoundMultipler)
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 180)
		end
		if (not bgColor) then
			bgColor = borderColor
		end
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
        
        --Sarkokba pötty:
        dxDrawRectangle(x + 0.5, y + 0.5, 1, 2, borderColor, postGUI); -- bal felső
        dxDrawRectangle(x + 0.5, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
        dxDrawRectangle(x + w - 0.5, y + 0.5, 1, 2, borderColor, postGUI); -- bal felső
        dxDrawRectangle(x + w - 0.5, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
	end
end


function drawnSoundMultipler()    
    if page ~= "Unknown" then
        roundedRectangle(sx/2 - 330/2, sy - 70, 330, 50, tocolor(217, 124, 14, math.min(220, alpha or 255)), tocolor(217, 124, 14, math.min(220, alpha or 255)))
        dxDrawImage(sx/2 - 360/2, sy - 75, 360, 55, f .. "sound-wallpaper.png", 0,0,0, tocolor(255,255,255, alpha or 255))
        local pos = sx/2 - 113 + ((113 + 111) * saveJSON["soundVolume"])
        dxDrawLine(sx/2 - 113 - 1, sy - 44, pos - 1, sy - 44, tocolor(156, 156, 156, math.min(220, alpha or 255)), 3)
        --dxDrawRectangle(sx/2 - 113, sy - 48, 113 + 111, 8)
        dxDrawImage(pos - 32/2, sy - 44 - 32/2, 32, 32, f .. "sound-pointer.png", 0,0,0, tocolor(156, 156, 156, alpha or 255))
        dxDrawText(math.floor(saveJSON["soundVolume"] * 100) .. "%", sx/2 + (330/2 - 25), sy - 67, sx/2 + (330/2 - 25), sy - 70 + 50, tocolor(255,255,255,alpha or 255), 1, fonts["default-regular"], "center", "center")
    end
end

function sounds.onClick(b, s)
--    outputChatBox(page)
    if page == "Login" or page == "Register" or page == "RPTest" then
        if b == "left" and s == "down" then
            if isInSlot(sx/2 - 113, sy - 48, 113 + 111, 8) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                playSound("files/bubble.mp3")
                local cx, cy = exports['cr_core']:getCursorPosition()
                local soundVolume = (cx - (sx/2 - 113)) / (113 + 111)
                saveJSON["soundVolume"] = soundVolume
                setSoundVolume(sounds["element"], soundVolume)
                soundClick = true
                
                lastClickTick = getTickCount()
            end
        elseif b == "left" and s == "up" then
            if soundClick then
                soundClick = false
            end
        end
    end
end
addEventHandler("onClientClick", root, sounds.onClick)

local minX = sx/2 - 113 + (113 + 111)
local maxX = sx/2 - 113

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        if soundClick then
            if x >= maxX and x <= minX then
                local soundVolume = (x - (sx/2 - 113)) / (113 + 111)
                saveJSON["soundVolume"] = soundVolume
                setSoundVolume(sounds["element"], soundVolume)
            end
        end
    end
)