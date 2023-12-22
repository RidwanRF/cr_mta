local cache = {}
local pos = {}
local fontsize = 1
local font = exports['cr_fonts']:getFont("Roboto", 10)
addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Roboto", 10)
		end
	end
)

local screenSize = {guiGetScreenSize()}
local screenX, screenY = guiGetScreenSize()
local sx, sy = guiGetScreenSize()
local minLines = 0

local dist = 15
local chatData = getChatboxLayout()
local lines = chatData["chat_lines"]
local minLines, maxLines = 1, lines
--local pos["x"], pos["y"] = pos["x"]/2, pos["y"] - (lines * dist) --pos["y"] - (maxLines * dist)
local debugState = false

local cursorState = isCursorShowing()
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2]
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, cx, cy)
        cursorX, cursorY = cx, cy
        if realMoving and debugState then
            pos["x"] = cx - dX
            pos["y"] = cy - dY
            return
        end
    end
)

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

addEventHandler("onClientDebugMessage", root, 
    function(message, level, file, line, r, g, b)
        addDebugText(message, level, file, line, "client", r, g, b)
    end
)

function jsonGETT(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local x, y = sx/2, sy
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
        pos = jsonGETT("@positions.json")
        x,y2 = pos["x"], lines * dist
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVET("@positions.json", pos)
    end
)

function addDebugText(message, level, file, line, eT, r, g, b)
    local breakelve = false
    for k,v in pairs(cache) do
	    if v.message == message and v.level == level and v.file == file and v.line == line and v.eT == eT then
		    local lastTick = ( v.tick / 1000 ) / 60 -- Percé alakítom
			local nowTick = ( getTickCount() / 1000 ) / 60 -- Mostani időt is :S
			if lastTick + 5 > nowTick then
			    breakelve = true
				v.value = v.value + 1
			end
		end
	end
	
	if not breakelve then
	    table.insert(cache, {message = message or "", level = level or "", file = file or "", line = line or "", eT = eT, time = getRealTime(), value = 1, tick = getTickCount(), r = r or 255, g = g or 255, b = b or 255})
        
        if #cache <= 2 or not debugState then return end
        if maxLines + 1 <= #cache then
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
	end
end
addEvent("addDebugText", true)
addEventHandler("addDebugText", root, addDebugText)

addCommandHandler("cleardebugs", 
    function() 
	    if #cache > 0 then
            cache = {} 
		end
    end
)

addCommandHandler("resetdebug", 
    function() 
	    pos["x"], pos["y"] = sx/2, sy
    end
)


addCommandHandler("debug", 
    function() 
        if exports['cr_permission']:hasPermission(localPlayer, "debug") then
            debugState = not debugState
            if debugState then 
                local syntax = exports['cr_core']:getServerSyntax(false, "success")
                addEventHandler("onClientRender", root, renderDebug, true, "low-5")
                outputChatBox(syntax .. "Debugscript aktiválva!", 255, 255, 255, true)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                removeEventHandler("onClientRender", root, renderDebug)
                outputChatBox(syntax .. "Debugscript deaktiválva!", 255, 255, 255, true)
            end
        end
	end
)

function renderDebug()
    if #cache > 0 then
	    local forY = 0
		--dxDrawRectangle(pos["x"] - x/2, pos["y"] -((forY + dist) * #cache + 20), x, ((forY + dist) * #cache + 20), tocolor(0,0,0,80))
		--if isInSlot(pos["x"] - x/2, pos["y"] -((forY + dist) * #cache + 20), x, ((forY + dist) * #cache + 20)) then outputChatBox("asd") end
		
	    for i = minLines, maxLines do
		    local v = cache[i]
		    if v then
			    local time = v.time
				local hour = time.hour
				local hourSting = hour
				if hour < 10 then
				    hourSting = "0" .. hourSting
				end
                local minute = time.minute
				local minuteString = minute
				if minute < 10 then
				    minuteString = "0" .. minuteString
				end
                local seconds = time.second
				local secondsString = seconds
				if seconds < 10 then
				    secondsString = "0" .. secondsString
				end
		        local text = "[" .. hourSting .. ":" ..minuteString.. ":" .. secondsString.. "] " .. v.message .. " (" .. v.file .. " - " .. v.line .. " [" .. v.value .. "x] (".. v.eT .. ") )" 
			    local dType = v.level
                local r,g,b = v.r, v.g, v.b
		        forY = forY + dist
				--dxDrawText(text, pos["x"] - 1, pos["y"] - forY, pos["x"] - 1, pos["y"] - forY, tocolor(0,0,0,255), fontsize, font, "center", "center")
				--dxDrawText(text, pos["x"] + 1, pos["y"] - forY, pos["x"] + 1, pos["y"] - forY, tocolor(0,0,0,255), fontsize, font, "center", "center")
				dxDrawText(text, pos["x"], pos["y"] - forY + 1, pos["x"], pos["y"] - forY + 1, tocolor(0,0,0,255), fontsize, font, "center", "center")
				--dxDrawText(text, pos["x"], pos["y"] - forY - 1, pos["x"], pos["y"] - forY - 1, tocolor(0,0,0,255), fontsize, font, "center", "center")
			    dxDrawText(text, pos["x"], pos["y"] - forY, pos["x"], pos["y"] - forY, tocolor(r,g,b,255), fontsize, font, "center", "center")
			end
		end
    end 
end

addEventHandler("onClientClick", root,
    function(e, d)
	    if e == "left" and d == "down" and debugState then
            local forY = 0
            if isInSlot(pos["x"] - x/2, pos["y"] -((forY + dist) * #cache + 20), x, ((forY + dist) * #cache + 20)) then
                local cx, cy = exports['cr_core']:getCursorPosition()
                realMoving = true
                local x, y = pos["x"], pos["y"]
                dX, dY = cx - x, cy - y
            end
		elseif e == "left" and d == "up" then
		    if realMoving then
			    realMoving = false
			end
		end
	end
)

bindKey("pgdn", "down",
    function()
        
        if #cache <= 2 or not debugState then return end
        
        if minLines - 1 ~= 0 then
            minLines = minLines - 1
            maxLines = maxLines - 1
        end
        
        
    end
)

bindKey("pgup", "down",
    function()
        
        if #cache <= 2 or not debugState then return end
        
        if maxLines + 1 <= #cache then
            minLines = minLines + 1
            maxLines = maxLines + 1
        end
    end
)