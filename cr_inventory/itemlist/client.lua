_dxDrawRectangle = dxDrawRectangle;
local dxDrawRectangle = function(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
end

local dxDrawRectangle2 = function(left, top, width, height, color, color2)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
    
    _dxDrawRectangle(left - 2, top, 2, height, color2, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color2, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color2, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color2, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color2, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color2, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color2, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color2, postgui)
end

dxDrawRectangle3 = function(left, top, width, height, color, color2)
	if not postgui then
		postgui = false;
	end

	left, top = left, top;
	width, height = width, height;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left + 1, top, width - 1, height, color, postgui);
    
    _dxDrawRectangle(left - 2, top, 2, height, color2, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color2, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color2, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color2, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color2, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color2, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color2, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color2, postgui)
end

local sx, sy = guiGetScreenSize()
local state, animState = false, false

local originalMaxLines = sy / 45
local maxLines = originalMaxLines
local minLines = 1
local num = 0

local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)

_addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_fonts" then
	        font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
        end
	end
)

local pos = {}

function jsonGETT(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local num = originalMaxLines
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

_addCommandHandler("resetitemlistpanel", 
    function()
        pos["x"] = sx/2
        pos["y"] = sy/2
    end
)
 
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

_addEventHandler("onClientResourceStart", resourceRoot,
    function()
        pos = jsonGETT("@position.json")
    end
)

_addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVET("@position.json", pos)
    end
)
 
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

_addCommandHandler("itemlist",
    function()
        if not exports['cr_permission']:hasPermission(localPlayer, "itemlist") then return end
        state = not state
        if state then
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "success")
            outputChatBox(syntax .. "Itemlista előhozva!", 255,255,255,true)
            num = #items
            --[[
            for k,v in pairs(items) do
                num = num + 1
            end]]
            --maxLines = originalMaxLines
            --minLines = 1
            _addEventHandler("onClientRender", root, drawnTurnablePanel, true, "low-5")
            --createLogoAnim()
        else
            local syntax = exports['cr_core']:getServerSyntax("Inventory", "error")
            outputChatBox(syntax .. "Itemlista eltüntetve!", 255,255,255,true)
            removeEventHandler("onClientRender", root, drawnTurnablePanel)
            --stopLogoAnim()
        end
    end
)

local cursorState = isCursorShowing()
local cursorX, cursorY = 0,0 --pos["x"], pos["y"]
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
end

_addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
        if realMoving and state then
            pos["x"] = x - dX
            pos["y"] = y - dY
        end
    end
)

function inBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function inSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if inBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

local function linedRectangle(x,y,w,h, color, color2)
    return dxDrawRectangle2(x,y,w,h, color, color2) --exports['cr_core']:linedRectangle(x,y,w,h, color, color2, 2)
end

function drawnTurnablePanel()
    local num = num
    if num > originalMaxLines then
        num = originalMaxLines
    end
    linedRectangle(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+30, tocolor(0,0,0,140), tocolor(0,0,0,200))
    --dxDrawText("A görgő használatával tudsz görgetni!", pos["x"], pos["y"] - ((num*40)/2) - 5, pos["x"], pos["y"] - ((num*40)/2) - 5, tocolor(255,255,255,255), 1, font, "center", "center")
    local startY = ((num*40)/2)
    local newK = 1
    hovered = nil
    for i = minLines, maxLines do
        local v = items[i]
        local name, weight = v[1], v[3]
        if not name then
            name = "Ismeretlen"
        end
        
        if not weight then
            weight = 0
        end
        --if newK >= minLines and newK <= maxLines then
        linedRectangle(pos["x"] - 500/2, pos["y"] - startY + 10, 500, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
        if isInSlot(pos["x"] - 500/2, pos["y"] - startY + 10, 500, 20) then
            local x, y = pos["x"] - 480/2, pos["y"] - startY + 10
            local x2, y2 = x + 480, y + 20
            dxDrawText(i, x, y, x2, y2, tocolor(255,255,255,255), 1, font, "left", "center")
            dxDrawText(name, x, y, x2, y2, tocolor(255,255,255,255), 1, font, "center", "center")
            dxDrawText(weight .. " kg", x, y, x2, y2, tocolor(255,255,255,255), 1, font, "right", "center")
            hovered = i
        else
            local x, y = pos["x"] - 480/2, pos["y"] - startY + 10
            local x2, y2 = x + 480, y + 20
            dxDrawText(i, x, y, x2, y2, tocolor(255,255,255,180), 1, font, "left", "center")
            dxDrawText(name, x, y, x2, y2, tocolor(255,255,255,180), 1, font, "center", "center")
            dxDrawText(weight .. " kg", x, y, x2, y2, tocolor(255,255,255,180), 1, font, "right", "center")
        end
        --dxDrawRectangle(pos["x"] + 480/2 - 180, pos["y"] - startY + 10, 180, 20, tocolor(0,0,0,100))
        startY = startY - 40
        --end
        newK = newK + 1
    end
end    

bindKey("mouse_wheel_down", "down", 
    function()
        if state then
            if inSlot(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+30) then
                if maxLines + 1 <= num then
                    minLines = minLines + 1
                    maxLines = maxLines + 1
                end
            end
        end
    end
)

bindKey("mouse_wheel_up", "down", 
    function()
        if state then
            if inSlot(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+30) then
                if minLines - 1 > 0 then
                    minLines = minLines - 1
                    maxLines = maxLines - 1
                end
            end
        end
    end
)

_addEventHandler("onClientClick", root,
    function(b, s)
        if b == "middle" and s == "down" and state then
            if hovered and tonumber(hovered) then
                if exports['cr_permission']:hasPermission(localPlayer, "giveitem") then
                    giveItem(localPlayer, tonumber(hovered))
                    exports['cr_infobox']:addBox("success", "Sikeres addolás!")
                else
                    exports['cr_infobox']:addBox("error", "Neked nincs jogod az item addoláshoz!")
                end
            end
        elseif b == "left" and s == "down" and state then
            
            local num = num
            if num > originalMaxLines then
                num = originalMaxLines
            end
            if inSlot(pos["x"]-500/2, pos["y"] - ((num*40)/2) - 30/2, 500, 20) then -- Felső rész
                local cx, cy = exports['cr_core']:getCursorPosition()
                realMoving = true
                local x, y = pos["x"], pos["y"]
                dX, dY = cx - x, cy - y
            end
        elseif b == "left" and s == "up" and state then
            if realMoving then
                realMoving = false
            end
        end
    end
)