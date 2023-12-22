local cache = {
    --[replaceID (A modelID amire rakja a dolgot)] = {name (Ami van a files/xy.txd, files/xy.dff), turnable (kikapcsolhatóe true, false), hasCol (Van e Col hozzá)},
    [578] = {"dft30", true, false},
	[542] = {"clover", true, false},
	[479] = {"regina", true, false},
	[467] = {"oceanic", true, false}, --csere
	[426] = {"premier", true, false},
	[605] = {"picador1", true, false},
	[439] = {"stallion", true, false},
	[405] = {"sentinel", true, false},
	[551] = {"sentinel1", true, false},
	[429] = {"banshee", true, false},
	[480] = {"banshee1", true, false},
	[580] = {"stafford", true, false},
	[600] = {"picador", true, false},
	[436] = {"stallion1", true, false},
	[400] = {"landstal", true, false},
	[415] = {"cheetah", true, false},
	[494] = {"hotring", true, false},
	[492] = {"greenwood", true, false},
	[470] = {"patriot", true, false},
	[506] = {"supergt", true, false},--ujak
	[602] = {"alpha", true, false},
	[541] = {"bullet", true, false},
	[585] = {"emperor", true, false},
	[413] = {"pony", true, false},
	[482] = {"burrito", true, false},
	[543] = {"sadler", true, false},
	[451] = {"turismo", true, false},
	[477] = {"zr350", true, false},
	[604] = {"dgleen", true, false},
	[598] = {"copcarvg", true, false},
	[599] = {"copcarru", true, false},
	[596] = {"copcarla", true, false},
	[597] = {"copcarsf", true, false},
	[491] = {"virgo", true, false},
	[409] = {"stretch", true, false},
	[438] = {"cabbie", true, false},
	[411] = {"infernus", true, false},
	[516] = {"nebula", true, false},
	[503] = {"hotring3", true, false},
	[525] = {"towtruck", true, false},
    [581] = {"581", true, false},
    [462] = {"462", true, false},
    [521] = {"521", true, false},
    [463] = {"463", true, false},
    [522] = {"522", true, false},
    [461] = {"461", true, false},
    [468] = {"468", true, false},
    [586] = {"586", true, false},	
    [3895] = {"3895", false, true},
    [3898] = {"3898", false, true},
    [3892] = {"r", false, true},
    [3893] = {"l", false, true},
    [3891] = {"r2", false, true},
    [339] = {"katana", false, false},
    [355] = {"ak47", false, false},
    [349] = {"chromegun", false, false},
    [346] = {"colt45", false, false},
    [357] = {"cuntgun", false, false},
    [348] = {"desert_eagle", false, false},
    [335] = {"knifecur", false, false},
    [356] = {"m4", false, false},
    [352] = {"micro_uzi", false, false},
    [353] = {"mp5lng", false, false},
    [334] = {"nitestick", false, false},
    [350] = {"sawnoff", false, false},
    [351] = {"shotgspa", false, false},
    [347] = {"silenced", false, false},
    [358] = {"sniper", false, false},
    [372] = {"tec9", false, false},
    [322] = {"csakany", false, false},
	[323] = {"balta", false, false},
	[17426] = {"desert_eagle2", false, false},
	[10012] = {"taser", false, false},
	[11625] = {"agy", false, true},
}

local sx, sy = guiGetScreenSize()

local turnabled = {}

local originalMaxLines = sy / 50
local maxLines = originalMaxLines
local minLines = 1

local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)

addEventHandler("onClientResourceStart", root,
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

addCommandHandler("resetmodpanel", 
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

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        pos = jsonGETT("@position.json")
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVET("@position.json", pos)
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
    tickCount = 0]]
end

function drawnAnim()
    local num = num
    if num > originalMaxLines then
        num = originalMaxLines
    end
    local ax, ay = pos["x"], pos["y"] - ((num*40)/2) - 130
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
    --[[
    removeEventHandler("onClientRender", root, drawnAnim)
    animState = false]]
end

local maxStartPerTime = 4
local percentTime = 250

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        turnabled = jsonGET("@save.json")
        local alreadyStarted = {}
        local allStart = 0
        local now = getTickCount()
        startTimer = setTimer(
            function()
                local started = 0
                for k,v in pairs(cache) do
                    if not turnabled[k] and not alreadyStarted[k] then
                        local name, turnable, hasCol = unpack(v)
                        if hasCol then
                            local col = engineLoadCOL("files/"..name..".col")
                            engineReplaceCOL(col, k)
                        end
                        local txd = engineLoadTXD("files/"..name..".txd")
                        engineImportTXD(txd, k)
                        local dff = engineLoadDFF("files/"..name..".dff")
                        engineReplaceModel(dff, k)
                        alreadyStarted[k] = true
                        started = started + 1
                        allStart = allStart + 1
                    end
                    
                    if started >= maxStartPerTime then
                        return
                    end
                end
                
                if started < maxStartPerTime then
                    local newNow = getTickCount()
                    local seconds = (newNow - now) / 1000
                    outputDebugString("Loading succesfully finished, #"..allStart.." modells loaded in #"..seconds.." seconds!", 0, 20, 87, 255)
                    setElementData(localPlayer, "modsLoaded", true)
                    killTimer(startTimer)
                end
            end, percentTime, 0
        )
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVE("@save.json", turnabled)
    end
)

bindKey("F1", "down",
    function()
        if not getElementData(localPlayer, "loggedIn") then return end
        if not getPedOccupiedVehicle(localPlayer) then
            state = not state
            if state then
                num = 0
                for k,v in pairs(cache) do
                    local name, turnable, hasCol = unpack(v)
                    if turnable then
                        num = num + 1
                    end
                end
                maxLines = originalMaxLines
                minLines = 1
                addEventHandler("onClientRender", root, drawnTurnablePanel, true, "low-5")
                createLogoAnim()
            else
                removeEventHandler("onClientRender", root, drawnTurnablePanel)
                stopLogoAnim()
            end
        end
    end
)

local cursorState = isCursorShowing()
local cursorX, cursorY = pos["x"], pos["y"]
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
        if realMoving and state then
            pos["x"] = x - dX
            pos["y"] = y - dY
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

function linedRectangle(x,y,w,h, color, color2)
    return dxDrawRectangle2(x,y,w,h, color, color2) --exports['cr_core']:linedRectangle(x,y,w,h, color, color2, 2)
end

function drawnTurnablePanel()
    local num = num
    if num > originalMaxLines then
        num = originalMaxLines
    end
    linedRectangle(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+20, tocolor(0,0,0,140), tocolor(0,0,0,200))
    --dxDrawText("A görgő használatával tudsz görgetni!", pos["x"], pos["y"] - ((num*40)/2) - 5, pos["x"], pos["y"] - ((num*40)/2) - 5, tocolor(255,255,255,255), 1, font, "center", "center")
    local startY = ((num*40)/2)
    local newK = 1
    hovered = false
    for k,v in pairs(cache) do
        local name, turnable, hasCol = unpack(v)
        if turnable then
            if newK >= minLines and newK <= maxLines then
                local vehicleName = exports['cr_vehicle']:getVehicleName(k)
                vehicleName = (vehicleName .. " ("..getVehicleNameFromModel(k).."," .. k .. ")")
                linedRectangle(pos["x"] - 500/2, pos["y"] - startY + 10, 500, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
                dxDrawText(vehicleName, pos["x"] - 480/2, pos["y"] - startY + 10, pos["x"] - 480/2, pos["y"] - startY + 10 + 20, tocolor(255,255,255,255), 1, font, "left", "center")
                dxDrawRectangle(pos["x"] + 480/2 - 180, pos["y"] - startY + 10, 180, 20, tocolor(0,0,0,100))
                if turnabled[k] then
                    if isInSlot(pos["x"] + 480/2 - 180, pos["y"] - startY + 10, 180, 20) then
                        dxDrawText("Kikapcsolva", pos["x"] + 480/2 - 180, pos["y"] - startY + 12.5, pos["x"] + 480/2, pos["y"] - startY + 10 + 20, tocolor(255,87,87,255), 1, font, "center", "center")
                        hovered = k
                    else
                        dxDrawText("Kikapcsolva", pos["x"] + 480/2 - 180, pos["y"] - startY + 12.5, pos["x"] + 480/2, pos["y"] - startY + 10 + 20, tocolor(255,87,87,180), 1, font, "center", "center")
                    end
                else
                    if isInSlot(pos["x"] + 480/2 - 180, pos["y"] - startY + 10, 180, 20) then
                        dxDrawText("Bekapcsolva", pos["x"] + 480/2 - 180/2, pos["y"] - startY + 12.5, pos["x"] + 480/2 - 180/2, pos["y"] - startY + 10 + 20, tocolor(87,255,87,255), 1, font, "center", "center")
                        hovered = k
                    else
                        dxDrawText("Bekapcsolva", pos["x"] + 480/2 - 180/2, pos["y"] - startY + 12.5, pos["x"] + 480/2 - 180/2, pos["y"] - startY + 10 + 20, tocolor(87,255,87,180), 1, font, "center", "center")
                    end
                end
                startY = startY - 40
            end
            newK = newK + 1
        end
    end
    
    linedRectangle(pos["x"] - 180/2, pos["y"] - startY + 30, 180, 20, tocolor(0,0,0,120), tocolor(0,0,0,220))
    if turnabled["all"] then
        if isInSlot(pos["x"] - 180/2, pos["y"] - startY + 30, 180, 20) then
            dxDrawText("Összes bekapcsolása", pos["x"], pos["y"] - startY + 30, pos["x"], pos["y"] - startY + 30 + 20, tocolor(87,255,87,255), 1, font, "center", "center")
            hovered = "all"
        else
            dxDrawText("Összes bekapcsolása", pos["x"], pos["y"] - startY + 30, pos["x"], pos["y"] - startY + 30 + 20, tocolor(87,255,87,180), 1, font, "center", "center")
        end
    else
        if isInSlot(pos["x"] - 180/2, pos["y"] - startY + 30, 180, 20) then
            dxDrawText("Összes kikapcsolása", pos["x"], pos["y"] - startY + 30, pos["x"], pos["y"] - startY + 30 + 20, tocolor(255,87,87,255), 1, font, "center", "center")
            hovered = "all"
        else
            dxDrawText("Összes kikapcsolása", pos["x"], pos["y"] - startY + 30, pos["x"], pos["y"] - startY + 30 + 20, tocolor(255,87,87,180), 1, font, "center", "center")
        end
	end
end    

bindKey("mouse_wheel_down", "down", 
    function()
        if state then
            if isInSlot(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+30) then
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
            if isInSlot(pos["x"] - 500/2, pos["y"] - ((num*40)/2) - 30/2, 500, (num*40)+30) then
                if minLines - 1 > 0 then
                    minLines = minLines - 1
                    maxLines = maxLines - 1
                end
            end
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if state then
            if b == "left" and s == "down" then
                if hovered then
                    local k = hovered
                    local v = cache[hovered]
                    if v then
                        local name, turnable, hasCol = unpack(v)
                        if turnable then
                            if turnabled[k] then
                                local name, turnable, hasCol = unpack(cache[k])
                                if hasCol then
                                    local col = engineLoadCOL("files/"..name..".col")
                                    engineReplaceCOL(col, k)
                                end
                                local txd = engineLoadTXD("files/"..name..".txd")
                                engineImportTXD(txd, k)
                                local dff = engineLoadDFF("files/"..name..".dff")
                                engineReplaceModel(dff, k)
                                turnabled[k] = false
                                return
                            else
                                local name, turnable, hasCol = unpack(cache[k])
                                if hasCol then
                                    engineRestoreCOL(k)
                                end
                                engineRestoreModel(k)
                                turnabled[k] = true
                                return
                            end
                        end
                    end
                end
                    
                if hovered and hovered == "all" then
                    if turnabled["all"] then
                        turnabled["all"] = false
                        for k,v in pairs(cache) do
                            local name, turnable, hasCol = unpack(v)
                            if hasCol then
                                local col = engineLoadCOL("files/"..name..".col")
                                engineReplaceCOL(col, k)
                            end
                            local txd = engineLoadTXD("files/"..name..".txd")
                            engineImportTXD(txd, k)
                            local dff = engineLoadDFF("files/"..name..".dff")
                            engineReplaceModel(dff, k)
                            turnabled[k] = false
                        end
                    else
                        for k,v in pairs(cache) do
                            local name, turnable, hasCol = unpack(v)
                            if hasCol then
                                engineRestoreCOL(k)
                            end
                            engineRestoreModel(k)
                            turnabled[k] = true
                        end
                        turnabled["all"] = true
                    end
                end
            end
        end
    end
)

setTimer(
    function()
        if getPedOccupiedVehicle(localPlayer) then
            if state then
                removeEventHandler("onClientRender", root, drawnTurnablePanel)
                state = false
                --stopLogoAnim()
            end
        end
    end, 1000, 0
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" and state then
            local num = num
            if num > originalMaxLines then
                num = originalMaxLines
            end
            if isInSlot(pos["x"]-500/2, pos["y"] - ((num*40)/2) - 30/2, 500, 20) then -- Felső rész
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

_dxDrawRectangle = dxDrawRectangle;
dxDrawRectangle = function(left, top, width, height, color, postgui)
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

dxDrawRectangle2 = function(left, top, width, height, color, color2)
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