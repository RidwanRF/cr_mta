textbars = {}
local guiState = false
local now = 0
local tick = 0
local state = false
searchCache = {}
 
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

function CreateNewBar(name, details, options, id)
    searchCache = {}
    local x,y,w,h = unpack(details)
    --local gui = GuiEdit(x, y, w, h, "", false)
    --gui:setData("name", name)
    --guiSetAlpha(gui, 0)
    --guiSetVisible(gui, false)
    --guiSetInputMode("no_binds_when_editing")
    --setTimer(guiBringToFront, 50, 1, gui)
    --addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
    --addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
    textbars[name] = {details, options, id}
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function onGuiBlur()
    guiBringToFront(source)
end

function onGuiChange()
    local name = getElementData(source, "name") or ""
    textbars[name][2][2] = guiGetText(source)
    playSound(":ax_account/files/key.mp3")
    searchCache = {}
    local text = string.lower(textbars[name][2][2])
    if tonumber(text) then
        local player = exports['cr_core']:findPlayer(localPlayer, tostring(text))
        local v = cacheGetDetails(player)
        table.insert(searchCache, v)
    end
    for k,v in pairs(cache) do
        local text2 = v["name"]
        local e = v["element"]
        if text == string.lower(utfSub(text2, 1, #text)) then
            if e == localPlayer then
                table.insert(searchCache, 1, v)
            else
                table.insert(searchCache, v)
            end
        end
    end
    if maxLines > #searchCache then
        minLines = 1
        maxLines = (screen.y - 150 - (sizes["top"].y + sizes["bottom"].y)) / 35
    end
end

function Clear()
    toggleControl("chatbox", true)
    setElementData(localPlayer, "score >> bar", false)
    oldCState = nil
    
    for k,v in pairs(textbars) do
        if isElement(v[4]) then
            destroyElement(v[4])
        end
        textbars[k] = nil
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        state = false
        guiState = false
        tick = 0
        now = 0
    end
end

function UpdatePos(name, details)
    textbars[name][1] = details
    --local x,y,w,h = unpack(details)
    --guiSetPosition(textbars[name][4], x, y, false)
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function GetText(name)
    return textbars[name][2][2]
end

function DrawnBars()
    for k,v in pairs(textbars) do
        local details = v[1]
        local x,y,w,h = unpack(details)
        local w,h = x + w, y + h
        local options = v[2]
        local text = options[2]
        local color = options[4]
        local font = options[5]
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        --local rot1,rot2,rot3 = unpack(options[10])
        
        --[[
        tick = tick + 5
        if tick >= 425 then
            tick = 0
        elseif tick >= 250 then
            text = text .. "|"
        end 
        ]]
        
        --outputChatBox(text)
        dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY)
    end
end

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if state then
                for k,v in pairs(textbars) do
                    local details = v[1]
                    local x,y,w,h = unpack(details)
                    if isInSlot(x,y,w,h) then
                        if not isElement(v[4]) then
                            local gui = GuiEdit(-1, -1, 1, 1, "", true)
                            gui:setData("name", k)
                            --guiSetAlpha(gui, 0)
                            --guiSetVisible(gui, false)
                            --guiSetInputMode("no_binds_when_editing")
                            oldCState = isControlEnabled("chatbox")
                            toggleControl("chatbox", false)
                            setElementData(localPlayer, "score >> bar", true)
                            setTimer(guiBringToFront, 50, 1, gui)
                            addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                            addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                            textbars[k][4] = gui
                        else
                            guiBringToFront(v[4])
                        end
                        return
                    end
                end
                
                for k,v in pairs(textbars) do
                    if isElement(v[4]) then
                        destroyElement(v[4])
                    end
                    textbars[k][4] = nil
                end
                toggleControl("chatbox", true)
                setElementData(localPlayer, "score >> bar", false)
            end
        end
    end
)