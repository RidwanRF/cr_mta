widgets = {mySavedConfig = {}, disabledWidgets = {}}
local sX, sY = guiGetScreenSize()
local editorState = false
local moveingWidget = false
local currentlyMoveing = false
local currentlyResizeing = false
local resizeingWidget = -1
local offsetX = 0
local offsetY = 0
local oState, oState2
local fileName = "widgets.json"
-- local hoveredActionButton = ""

addCommandHandler("resethud", 
    function()
        cfg = {}
        widget = {}
        local tables = {}
        for k,v in pairs(defPositions) do
            --if v["showing"] then
                tables[k] = v
            --end
        end
        local a = toJSON(tables)
        --outputChatBox(a)
        cfg = fromJSON(a)
        
        local tables = {}
        for k,v in pairs(defPositions) do
            if not v["showing"] then
                table.insert(tables, {k, v["name"]})
            end
        end
        local a = toJSON(tables)
        --outputChatBox(a)
        widget = fromJSON(a)
    end
)

function widgets.draw()
    font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    
	--dxDrawRectangle(0, 0, sX, sY, tocolor(0, 0, 0, 50))
	
    if selected and moveingWidget then
        dxDrawImage(sx/2 - 70, 20, 60, 60, "images/bin.png", 0, 0, animation1FOV, tocolor(255,51,51, 255)) 
        dxDrawImage(sx/2 + 10, 20, 60, 60, "images/reset.png", 0, 0, animation2FOV, tocolor(51,152,255, 180))
    end
    
	for name, v in pairs(cfg) do
        local _name = name
		if widgets.convertToBool(v["showing"]) and not v["invisible"] then
            if selected ~= name then
                local name = v["name"]
                dxDrawRectangle(v["x"], v["y"], v["width"], v["height"], tocolor(0, 0, 0, 255 * 0.2), true)
                dxDrawText(name, v["x"], v["y"], v["width"] + v["x"], v["height"] + v["y"], tocolor(255,255,255, 255 * 0.2), 1, font, "center", "center", false, false, true, true)
            else
                local name = v["name"]
                dxDrawRectangle(v["x"], v["y"], v["width"], v["height"], tocolor(0, 0, 0, 255 * 0.75), true)
                dxDrawText(name, v["x"], v["y"], v["width"] + v["x"], v["height"] + v["y"], tocolor(255,255,255, 255 * 0.75), 1, font, "center", "center", false, false, true, true)
            end
			--dxDrawRectangle(v["x"], v["y"], v["width"], 30, tocolor(0, 0, 0, 255 * 0.5), true)
            local a = 5
            --[[if v["turnable"] then
                if widgets.isInBox(v["x"] + a, v["y"] + 6, 16, 16) then
                    dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/bin.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
                else
                    dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/bin.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
                end
                if widgets.isInBox(v["x"] + a + 20, v["y"] + 6, 16, 16) then
                    dxDrawImage(v["x"] + a + 20, v["y"] + 6, 16, 16, "images/reset.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
                else
                    dxDrawImage(v["x"] + a + 20, v["y"] + 6, 16, 16, "images/reset.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
                end]]
                
            --[[
            if _name == "oocchat" or _name == "chat" then
                --outputChatBox("asd")
                if widgets.isInBox(v["x"] + a, v["y"] + 6, 16, 16) then
                    --dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/settings.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
                else
                    --dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/settings.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
                end
            end  ]]
            --[[
            else
                if widgets.isInBox(v["x"] + a, v["y"] + 6, 16, 16) then
                    dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/reset.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
                else
                    dxDrawImage(v["x"] + a, v["y"] + 6, 16, 16, "images/reset.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
                end
            end]]
                
            
			if v["sizeable"] then
                if widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16) then
                    dxDrawImage(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, "images/resize.png", 0, 0, 0, tocolor(255, 255, 255, 220), 
                    true)
                else
				    dxDrawImage(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, "images/resize.png", 0, 0, 0, tocolor(255, 255, 255, 180), 
                    true)
                end
			end
		end
	end
	
	-- Disabled Widgets
	if #widget > 0 then
        --if isInSlot(250 - 8, 20 + 10, 16, 16) then
        dxDrawRectangle(20, 20, 250, 35, tocolor(0, 0, 0, 255 * 0.75), true)
        local fullY = 35
        if widgetsEnabled then
            if anim then
                fullY = animY
            else
                fullY = 35 + (#widget * 33) + 10
            end
        end
        dxDrawRectangle(20, 20, 250, fullY, tocolor(0, 0, 0, 255 * 0.5), true)
        dxDrawText("Widgetek", 20, 20, 250 + 20, 55, white, 1, font, "center", "center", false, false, true, true)
        if widgets.isInBox(250 - 8, 20 + 10, 16, 16) then
            dxDrawImage(250 - 8, 20 + 10, 16, 16, "images/add.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
        else
            dxDrawImage(250 - 8, 20 + 10, 16, 16, "images/add.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
        end

        if widgetsEnabled and not anim then
            local startY = (2) * 32.5
            for k, v in pairs(widget) do
                dxDrawRectangle(25, startY, 240, 30, tocolor(0, 0, 0, 255 * 0.75), true)
                if widgets.isInBox(250 - 8, startY + 30/2 - 16/2, 16, 16) then
                    dxDrawImage(250 - 8, startY + 30/2 - 16/2, 16, 16, "images/add.png", 0, 0, 0, tocolor(255, 255, 255, 220), true)
                else
                    dxDrawImage(250 - 8, startY + 30/2 - 16/2, 16, 16, "images/add.png", 0, 0, 0, tocolor(255, 255, 255, 180), true)
                end
                dxDrawText(v[2], 30, startY, 250, startY + 30, white, 1, font, "center", "center", false, false, true, true)
                startY = startY + 33
            end
        end
        --end
	end
end
--addEventHandler("onClientRender", root, widgets.draw, true, "low-5")

addEventHandler("onClientCursorMove", root,
    function()
        if moveingWidget then
            if isCursorShowing() then
                local cX, cY = getCursorPosition()
                cX, cY = cX * sX, cY * sY
                cfg[currentlyMoveing]["x"] = cX + offsetX
                cfg[currentlyMoveing]["y"] = cY + offsetY
            end
        end

        if currentlyResizeing then
            if isCursorShowing() then
                local cX, cY = getCursorPosition()
                cX, cY = cX * sX, cY * sY
                cfg[resizeingWidget]["width"] = cX - cfg[resizeingWidget]["x"]
                cfg[resizeingWidget]["height"] = cY - cfg[resizeingWidget]["y"]
                if (cfg[resizeingWidget]["width"] <= defPositions[resizeingWidget]["minWidth"]) then
                    cfg[resizeingWidget]["width"] = defPositions[resizeingWidget]["minWidth"]
                elseif (cfg[resizeingWidget]["width"] >= defPositions[resizeingWidget]["maxWidth"]) then
                    cfg[resizeingWidget]["width"] = defPositions[resizeingWidget]["maxWidth"]
                end
                
                if (cfg[resizeingWidget]["height"] <= defPositions[resizeingWidget]["minHeight"]) then
                    cfg[resizeingWidget]["height"] = defPositions[resizeingWidget]["minHeight"]
                elseif (cfg[resizeingWidget]["height"] >= defPositions[resizeingWidget]["maxHeight"]) then
                    cfg[resizeingWidget]["height"] = defPositions[resizeingWidget]["maxHeight"]    
                end
            end
        end
    end
)

function widgets.click(button, state, absX, absY)
    if button == "left" and state == "down" and editorState then
        if widgets.isInBox(250 - 8, 20 + 10, 16, 16) then
            widgetsEnabled = not widgetsEnabled
            selected = nil
            if widgetsEnabled then
                anim = true
                widgets.animate(35, 35 + (#widget * 33) + 10, 4, 120, function(v) 
                    animY = v
                    if animY >= 35 + (#widget * 33) + 10 then
                        anim = false
                    end
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)
            else
                anim = true
                widgets.animate(animY, 35, 4, 120, function(v) 
                    animY = v
                    if animY <= 35 then
                        anim = false
                    end
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)
            end
            return
        end
            
        if widgetsEnabled then
            local startY = (2) * 32.5
            for k, v in ipairs(widget) do
                --local k = v
                if widgets.isInBox(250 - 8, startY + 30/2 - 16/2, 16, 16, absX, absY) then
                    --outputChatBox("interface."..v.."-visible")
                    localPlayer:setData(v[1]..".enabled", true)
                    --cfg[v]["x"] = defPositions[v]["x"]
                    --cfg[v]["y"] = defPositions[v]["y"]
                    local val = toJSON(defPositions[v[1]])
                    cfg[v[1]] = fromJSON(val)
                    cfg[v[1]]["showing"] = true
                    table.remove(widget, k)
                    return
                end				
                startY = startY + 33
            end
        end
	end
    
    if button == "left" and state == "down" and not editorState then
        local shortest = 9999
        selected = nil
		for k, v in pairs(cfg) do
            if widgets.convertToBool(v["showing"]) then
                local ns = v["height"] + v["width"]

                -- Resize/Move
                if v["invisible"] then
                    if not widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) then
                        if widgets.isInBox(cfg[k]["x"], cfg[k]["y"], cfg[k]["width"], cfg[k]["height"], absX, absY) then
                            if ns < shortest then
                                shortest = ns
                                currentlyMoveing = k
                                moveingWidget = true
                                selected = k
                                offsetX = cfg[k]["x"] - absX
                                offsetY = cfg[k]["y"] - absY
                            end
                        end
                    end
                end
            end
        end
	elseif button == "left" and state == "down" and editorState then
        
        local shortest = 9999
        selected = nil
		for k, v in pairs(cfg) do
            if widgets.convertToBool(v["showing"]) and not v["invisible"] then
                local ns = v["height"] + v["width"]
                if cfg[k]["turnable"] then

                    -- Remove/Reset
                    --[[
                    if widgets.isInBox(v["x"] + 5, v["y"] + 6, 16, 16, absX, absY) then -- Remove
                        cfg[k]["showing"] = false
                        --outputChatBox("interface."..k.."-visible")
                        localPlayer:setData(k..".enabled", false)
                        table.insert(widget, k)
                        return
                    end]]
                    
                    if k == "oocchat" or k == "chat" then
                        if widgets.isInBox(v["x"] + 5, v["y"] + 6, 16, 16) then
                            if k == "oocchat" then
                                --exports['cr_custom-chat']:showOptionsOOC()
                            elseif k == "chat" then
                                --exports['cr_custom-chat']:showOptionsIC()
                            end
                        end
                    end  

                    --[[
                    if widgets.isInBox(v["x"] + 25, v["y"] + 6, 16, 16, absX, absY) then -- Reset


                        widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                            cfg[k]["x"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                            cfg[k]["y"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        widgets.animate(cfg[k]["width"], defPositions[k]["width"], 4, 120, function(v) 
                            cfg[k]["width"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        widgets.animate(cfg[k]["height"], defPositions[k]["height"], 4, 120, function(v) 
                            cfg[k]["height"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        cfg[k]["type"] = defPositions[k]["type"]
                        cfg[k]["columns"] = defPositions[k]["columns"]

                        --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        --outputChatBox(defPositions[k]["type"])
                        --cfg[k]["x"] = defPositions[k]["x"]
                        -- cfg[k]["y"] = defPositions[k]["y"]
                        return
                    end]]
                else
                    --[[
                    if widgets.isInBox(v["x"] + 5, v["y"] + 6, 16, 16, absX, absY) then -- Reset

                        widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                            cfg[k]["x"]  = v
                        end, false)

                        widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                            cfg[k]["y"]  = v
                        end, false)

                        widgets.animate(cfg[k]["width"], defPositions[k]["width"], 4, 120, function(v) 
                            cfg[k]["width"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        widgets.animate(cfg[k]["height"], defPositions[k]["height"], 4, 120, function(v) 
                            cfg[k]["height"]  = v
                            --cfg[k] = fromJSON(toJSON(defPositions[k]))
                        end, false)

                        cfg[k]["type"] = defPositions[k]["type"]
                        cfg[k]["columns"] = defPositions[k]["columns"]
                        -- cfg[k]["x"] = defPositions[k]["x"]
                        -- cfg[k]["y"] = defPositions[k]["y"]
                        return
                    end]]
                end

                -- Resize/Move
                if not widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) then
                    if widgets.isInBox(cfg[k]["x"], cfg[k]["y"], cfg[k]["width"], cfg[k]["height"], absX, absY) then
                        if ns < shortest then
                            shortest = ns
                            currentlyMoveing = k
                            moveingWidget = true
                            selected = k
                            offsetX = cfg[k]["x"] - absX
                            offsetY = cfg[k]["y"] - absY
                        end
                    end
                end

                if widgets.isInBox(v["x"] + v["width"] - 16, v["y"] + v["height"] - 16, 16, 16, absX, absY) and not moveingWidget then
                    if (defPositions[k]["sizeable"]) then
                        currentlyResizeing = true
                        resizeingWidget = k
                        selected = k
                        --outputChatBox("resize")
                        break
                    end
                end
            end
		end
	elseif button == "left" and state == "up" then        
		if moveingWidget then
            local k = selected
            if widgets.isInBox(sx/2 - 70, 20, 60, 60) then
                if cfg[k]["turnable"] then
                    cfg[k]["showing"] = false
                    --outputChatBox("interface."..k.."-visible")
                    localPlayer:setData(k..".enabled", false)
                    table.insert(widget, {k, cfg[k]["name"]})
                    return
                end
            elseif widgets.isInBox(sx/2 + 10, 20, 60, 60) then
                widgets.animate(cfg[k]["x"], defPositions[k]["x"], 4, 120, function(v) 
                    cfg[k]["x"]  = v
                end, false)

                widgets.animate(cfg[k]["y"], defPositions[k]["y"], 4, 120, function(v) 
                    cfg[k]["y"]  = v
                end, false)

                widgets.animate(cfg[k]["width"], defPositions[k]["width"], 4, 120, function(v) 
                    cfg[k]["width"]  = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)

                widgets.animate(cfg[k]["height"], defPositions[k]["height"], 4, 120, function(v) 
                    cfg[k]["height"]  = v
                    --cfg[k] = fromJSON(toJSON(defPositions[k]))
                end, false)

                cfg[k]["type"] = defPositions[k]["type"]
                cfg[k]["columns"] = defPositions[k]["columns"]
                -- cfg[k]["x"] = defPositions[k]["x"]
                -- cfg[k]["y"] = defPositions[k]["y"]
            end
			moveingWidget = false
			currentlyMoveing = false
		end
		if currentlyResizeing then
			currentlyResizeing = false
			resizeingWidget = -1
		end
	end
end
addEventHandler("onClientClick", root, widgets.click)

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local table = {}
        for k,v in pairs(defPositions) do
            --if v["showing"] then
                table[k] = v
            --end
        end
        fileWrite(fileHandle, toJSON(table))
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

function jsonGET2(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        local tables = {}
        for k,v in pairs(defPositions) do
            if not v["showing"] then
                table.insert(tables, k)
            end
        end
        fileWrite(fileHandle, toJSON(tables))
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

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        cfg = jsonGET("save/@cfg.json")
        
        for k,v in pairs(cfg) do 
            local visible = v["showing"]
            localPlayer:setData(k..".enabled", visible)
        end
        
        widget = jsonGET2("save/@widget.json")
        
        if type(widget) ~= "table" then
            widget = {}
        end
        --outputChatBox(toJSON(widget))
    end
)
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVE("save/@cfg.json", cfg)
        --outputChatBox(toJSON(widget))
        jsonSAVE("save/@widget.json", widget)
    end
)

function widgets.convertToBool(string)
	if tostring(string) == "true" then
		return true
	else
		return false
	end
end

function widgets.isInBox(dX, dY, dSZ, dM, eX, eY)
    local eX, eY = exports['cr_core']:getCursorPosition()
    if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
        return true
    else
        return false
    end
end

function getNode(id, node)
	if cfg[id] and cfg[id][node] then
		return cfg[id][node]
	end
end

--[[
function setNode(id, node, value)
	if cfg[id] and cfg[id][node] then
		cfg[id][node] = value
	end
end]]

function getDetails(id)
    if cfg[id] then
        --local x,y,w,h,sizable,turnable, sizeDetails, t, columns = unpack(positions[id]);
        local a = cfg[id]["showing"]
        
        local x = cfg[id]["x"]
        local y = cfg[id]["y"]
        local w = cfg[id]["width"]
        local h = cfg[id]["height"]
        local t = cfg[id]["type"]
        local columns = cfg[id]["columns"]
        
        return a,x,y,w,h,nil,nil,nil, t, columns;
    end
end

local convert = {
    ["x"] = 1,
    ["y"] = 2,
    ["w"] = 3,
    ["h"] = 4,
    ["width"] = 3,
    ["height"] = 4,
    ["sizable"] = 5,
    ["turnable"] = 6,
    ["sizeDetails"] = 7,
    ["type"] = 8,
    ["t"] = 8,
    ["columns"] = 9,
};

function setNode(id, node, value)
    --outputChatBox(id)
    --outputChatBox(node)
    if cfg[id] and cfg[id][node] then
        --local convertedName = tonumber(convert[dName])
        if cfg[id] then
            cfg[id][node] = value;
            return true;
        end
    end
end

function widgets.toggle()
    if not getElementData(localPlayer, "loggedIn") then return end
    if not editorState and isCursorShowing() then
        if getElementData(localPlayer, "keysDenied") then return end
        editorState = true
        addEventHandler("onClientRender", root, widgets.draw, true, "low-5")
        --showCursor(true)
        widgetsEnabled = false
        createShader()
        oState = getElementData(localPlayer, "keysDenied")
        oState2 = exports['cr_custom-chat']:isChatVisible()
        showCursor(true)
        selected = nil
        currentlyMoveing = false
        moveingWidget = false
        setElementData(localPlayer, "keysDenied", true)
        setElementData(localPlayer, "interface.drawn", true)
        setElementData(localPlayer, "script >> drawn", true)
        soundElement = playSound("sounds/loop.mp3", true)
        --showChat(false)
        currentlyResizeing = false
        animation2FOV = 0
        animation1FOV = 0
        --localPlayer:setData("hudVisible", )
        exports['cr_custom-chat']:showChat(false)
        --widgets.checkJSON()
    elseif editorState and isCursorShowing() then
        editorState = false
        showCursor(not isCursorShowing())
        createShader()
        if isElement(soundElement) then destroyElement(soundElement) end
        removeEventHandler("onClientRender", root, widgets.draw)
        --showCursor(false)
        setElementData(localPlayer, "keysDenied", oState)
        --showChat(oState2)
        setElementData(localPlayer, "interface.drawn", false)
        setElementData(localPlayer, "script >> drawn", false)
        exports['cr_custom-chat']:showChat(oState2)
        selected = nil
        currentlyMoveing = false
        moveingWidget = false
        currentlyResizeing = false
        --widgets.save()
    end
end
bindKey("lctrl", "down", widgets.toggle)
bindKey("lctrl", "up", widgets.toggle)

-- Animate
local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function widgets.animate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end, true, "low-5")

--Shader
local screenWidth, screenHeight = guiGetScreenSize()
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
local showHud = "false"
local flickerStrength = 10
local blurStrength = 0.001 
local noiseStrength = 0.001
local sstate = false

function createShader()
    if sstate then
        if oldFilmShader then
			destroyElement(oldFilmShader)
			--destroyElement(myScreenSource)
			oldFilmShader = nil
			removeEventHandler("onClientPreRender", root, updateShader)
            sstate = false
		end
    else
        --myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
        oldFilmShader, oldFilmTec = dxCreateShader("shaders/old_film.fx")
        addEventHandler("onClientPreRender", root, updateShader, false, "low-1")
        sstate = true
    end
end


function updateShader()
    upDateScreenSource()

    if (oldFilmShader) then
        local flickering = math.random(100 - flickerStrength, 100)/100
        dxSetShaderValue(oldFilmShader, "ScreenSource", myScreenSource);
        dxSetShaderValue(oldFilmShader, "Flickering", flickering);
        dxSetShaderValue(oldFilmShader, "Blurring", blurStrength);
        dxSetShaderValue(oldFilmShader, "Noise", noiseStrength);
        dxDrawImage(0, 0, screenWidth, screenHeight, oldFilmShader)
    end
end
--addEventHandler("onClientPreRender", root, updateShader)


function upDateScreenSource()
    dxUpdateScreenSource(myScreenSource)
end

_dxDrawRectangle = dxDrawRectangle
function dxDrawRectangle(x, y, w, h, bgColor, postGUI)
	if (x and y and w and h) then
        
		local borderColor = bgColor
        
		_dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		_dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		_dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		_dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		_dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
        
        --Sarkokba pötty:
        --dxDrawRectangle(x + 0.5, y + 0.5, 1, 2, borderColor, postGUI); -- bal felső
        --dxDrawRectangle(x + 0.5, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
        --dxDrawRectangle(x + w - 2, y + 0.5, 1, 2, tocolor(0,0,0,255), postGUI); -- bal felső
        --dxDrawRectangle(x + w - 2, y + h - 1.5, 1, 2, borderColor, postGUI); -- bal alsó
	end
end