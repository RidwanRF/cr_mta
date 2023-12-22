fileDelete("client.lua")

local nodes = {}
local nodesT = {}

function getDetails(name)
    if nodes[name] then
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    else
        nodes[name] = {exports['cr_interface']:getDetails(name)}
        if not (nodesT[name]) then
            nodesT[name] = setTimer(
                function()
                    if nodes[name] ~= {exports['cr_interface']:getDetails(name)} then
                        nodes[name] = {exports['cr_interface']:getDetails(name)}
                    end
                end, 50, 0
            )
            --nodesT[name] = true
        end
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    end
    
    return exports['cr_interface']:getDetails(name)
end

--
function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end
--

local multipler = 0.15

local sx, sy = guiGetScreenSize()
local fontState = false

local cache = {}
local options = {}
local convert = {
    ["Say"] = "IC Chat: ",
    ["b"] = "OOC Chat: ",
    ["Rádió"] = "Rádió: ",
}

local editVals = {}
local restoreBtn, closeBtn, fontBtn = nil, nil, nil

fonts = {
    --["fontName"] = {src, defSize, defSize(protected)}
    ["Roboto"] = {":cr_fonts/files/Roboto.ttf", 10, 10},
    ["Rubik-Bold"] = {"fonts/Rubik-Bold.ttf", 10, 10},
    ["Rubik-Regular"] = {"fonts/Rubik-Regular.ttf", 10, 10},
    ["Gotham Light"] = {"fonts/gotham_light.ttf", 10, 10},
    ["OpenSans"] = {"fonts/OpenSans-Bold.ttf", 10, 10},
    ["PT_Sans"] = {"fonts/PT_Sans-Narrow-Web-Bold.ttf", 10, 10},
    ["Slabo27px"] = {"fonts/Slabo27px-Regular.ttf", 10, 10},
    ["Ubuntu"] = {"fonts/Ubuntu-Medium.ttf", 10, 10},
    ["SourceSansPro"] = {"fonts/SourceSansPro-Bold.ttf", 10, 10},
    ["Helvetica Neue"] = {"fonts/HelveticaNeue.ttf", 10, 10},
}
local fontsG = {}
--[[
for k,v in pairs(fonts) do
    fontsG[k] = dxCreateFont(v[1], v[2])
end]]

local defFont = "Roboto"
local defFontSize = 10

local function recreateFontsG()
    --fontsG = {}
    --for k,v in pairs(fonts) do
        --if k == options.font then
    local k = options["font"]
    local v = options["fontsize"]
    local b = options["bold"]
    --outputDebugString(k)
    --outputDebugString(v)
    --outputDebugString(b)
    if not fontsG[k..v..b] then
        fontsG[k..v..b] = dxCreateFont(fonts[k][1], v, options.bold == 0)
    end
end

--local font = dxCreateFont(":cr_gameplay/files/roboto.ttf", 10)

--pcall(loadstring(exports.cr_dx:getExports()));

--
local opState = false
local colors, optionsTable = {}, {}
local fontClick = false

local function refreshOptions()
    options.bold = 1
    options.font = defFont
    options.fontsize = defFontSize
    fonts[options.font][2] = options.fontsize
    recreateFontsG()
    recalculateIC()
    options.fadeout = 0
    options.fadeoutMultipler = 0.15
    multipler = options.fadeoutMultipler
    options.background = {0,0,0,0} -- r,g,b,a
    options.cacheRemain = 10
end

local function loadPlayerOptions()
    local data = exports.cr_json:jsonGET("icsettings");
    
    --outputConsole(data.font)
    if not data.bold then
        data.bold = 1
    end
    
    if not data.font or not fonts[data.font] then
        data.font = defFont
    end
    
    if not data.fontsize then
        data.fontsize = fonts[defFont][2] or 10
    end
    --fonts[data.font][2] = data.fontsize
    
    if not data.fadeout then
        data.fadeout = 0
    end
    
    if not data.fadeoutMultipler then
        data.fadeoutMultipler = 0.15
    end
    multipler = data.fadeoutMultipler
    
    if not data.background then
        data.background = {0,0,0,0} -- r,g,b,a
    end
    
    if not data.cacheRemain then
        data.cacheRemain = 10
    end
    
    options = data
    
    recreateFontsG()
    
    colors = {"#ffa726", "#cddc39", "#8bc34a", "#4caf50"};

    optionsTable = {
        {
            name = "Betűtípus méret:",
            value = "fontsize",
            vmin = 0,
            vmax = 7,
            vstart = 6,
            whole = false,
            tooltip = function(val, old)
                val = math.floor(val)
                --old = math.floor(old)
                ----outputChatBox(old)
                --val = math.floor(val) + 5
                --old = math.floor(old or 0) - 5
                if old ~= val then
                    options.fontsize = val
                    fonts[options.font][2] = val
                    recreateFontsG()
                    recalculateIC()
                end
                return val;
            end,
            color = function(val)
                return colors[4];
            end
        },
        {
            name = "Félkövér:",
            value = "bold",
            vmin = 0,
            vmax = 1,
            vstart = 0,
            whole = true,
            tooltip = function(val, old)
                if old ~= val then
                    options.bold = val
                    recreateFontsG()
                    recalculateIC()
                end
                return val == 1 and "Nem" or "Igen";
            end,
            color = function(val)
                return val == 1 and colors[1] or colors[4];
            end
        },
        {
            name = "Elhalványulás:",
            value = "fadeout",
            vmin = 0,
            vmax = 1,
            vstart = 0,
            whole = true,
            tooltip = function(val, old)
                if old ~= val then
                    options.fadeout = val
                end
                return val == 1 and "Nem" or "Igen";
            end,
            color = function(val)
                return val == 1 and colors[1] or colors[4];
            end
        },
        {
            name = "Elhalványulás szorzó:",
            value = "fadeoutMultipler",
            vmin = 0.05,
            vmax = 2,
            vstart = 0.15,
            whole = false,
            tooltip = function(val, old)
                if old ~= val then
                    options.fadeoutMultipler = val
                    multipler = options.fadeoutMultipler
                end
                return val;
            end,
            color = function(val)
                return colors[4];
            end
        },
        {
            name = "Háttér áttetszőség:",
            value = {"background", 4},
            vmin = 0,
            vmax = 255,
            vstart = 0,
            whole = false,
            tooltip = function(val, old)
                local val = math.floor(val)
                if old ~= val then
                    options.background[4] = val
                end
                return val
            end,
            color = function(val)
                if val <= 255 * 0.25 then
                    return colors[1];
                elseif val <= 255 * 0.5 then
                    return colors[2];
                elseif val <= 255 * 0.75 then
                    return colors[3];
                else
                    return colors[4];
                end
            end
        },
        {
            name = "Háttér (r):",
            value = {"background", 1},
            vmin = 0,
            vmax = 255,
            vstart = 0,
            whole = false,
            tooltip = function(val, old)
                local val = math.floor(val)
                if old ~= val then
                    options.background[1] = val
                end
                return val
            end,
            color = function(val)
                if val <= 255 * 0.25 then
                    return colors[1];
                elseif val <= 255 * 0.5 then
                    return colors[2];
                elseif val <= 255 * 0.75 then
                    return colors[3];
                else
                    return colors[4];
                end
            end
        },
        {
            name = "Háttér (g):",
            value = {"background", 2},
            vmin = 0,
            vmax = 255,
            vstart = 0,
            whole = false,
            tooltip = function(val, old)
                local val = math.floor(val)
                if old ~= val then
                    options.background[2] = val
                end
                return val
            end,
            color = function(val)
                if val <= 255 * 0.25 then
                    return colors[1];
                elseif val <= 255 * 0.5 then
                    return colors[2];
                elseif val <= 255 * 0.75 then
                    return colors[3];
                else
                    return colors[4];
                end
            end
        },
        {
            name = "Háttér (b):",
            value = {"background", 3},
            vmin = 0,
            vmax = 255,
            vstart = 0,
            whole = false,
            tooltip = function(val, old)
                local val = math.floor(val)
                if old ~= val then
                    options.background[3] = val
                end
                return val
            end,
            color = function(val)
                if val <= 255 * 0.25 then
                    return colors[1];
                elseif val <= 255 * 0.5 then
                    return colors[2];
                elseif val <= 255 * 0.75 then
                    return colors[3];
                else
                    return colors[4];
                end
            end
        },
        {
            name = "Megtartott sorok:",
            value = "cacheRemain",
            vmin = 10,
            vmax = 100,
            vstart = 0,
            whole = false,
            tooltip = function(val, old)
                local val = math.floor(val)
                if old ~= val then
                    options.cacheRemain = val
                end
                return val .. " sor megtartása a maximum sorok megtelése után."
            end,
            color = function(val)
                if val <= 50 * 0.25 then
                    return colors[1];
                elseif val <= 50 * 0.5 then
                    return colors[2];
                elseif val <= 50 * 0.75 then
                    return colors[3];
                else
                    return colors[4];
                end
            end
        },
    }
end
--addEventHandler("onClientResourceStart", resourceRoot, loadPlayerOptions)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if opState then
                if closeBtn then
                    showOptionsIC()
                    closeBtn = nil
                elseif restoreBtn then
                    refreshOptions()
                    restoreBtn = nil
                elseif fontBtn then
                    showOptionsIC()
                    showFontsIC()
                    fontBtn = nil
                end
            elseif fontState then
                if closeBtn then
                    showFontsIC()
                    closeBtn = nil
                elseif restoreBtn then
                    --refreshOptions()
                    options.font = defFont
                    options.fontsize = defFontSize
                    fonts[options.font][2] = options.fontsize
                    recreateFontsG()
                    recalculateIC()
                    restoreBtn = nil
                elseif fontClick then
                    ----outputChatBox(fontClick)
                    options.font = fontClick
                    fonts[options.font][2] = options.fontsize
                    recreateFontsG()
                    recalculateIC()
                end
            end
        end
    end
)

local function savePlayerOptions()
    exports.cr_json:jsonSAVE("icsettings", options);
end 
addEventHandler("onClientResourceStop", resourceRoot, savePlayerOptions)

local function drawnOptions()
end

function showOptionsIC()
    fontState = true
    showFontsIC()
    opState = not opState
    
    if opState then
        addEventHandler("onClientRender", root, drawnOptions, true, "low-5")
    else
        removeEventHandler("onClientRender", root, drawnOptions)
    end
end

local fontsDrawn = {}
local fontsCount = 0
local function recreateFontsWithDefSize()
    fontsDrawn = {}
    fontsCount = 0
    for k,v in pairs(fonts) do
        fontsDrawn[k] = dxCreateFont(v[1], v[3] or v[2])
        fontsCount = fontsCount + 1
    end
end

local function drawnFonts()
    local sWidth = 400;
    local sHeight = 60 + (fontsCount * 40);
    local sLeft = sx / 2 - sWidth / 2;
    local sTop = sy / 2 - sHeight / 2;
    
    --exports.cr_blur:createBlur(sLeft + 2, sTop + 2, sWidth - 4, sHeight - 4);
    dxDrawRectangle(sLeft, sTop, sWidth, sHeight, tocolor(0, 0, 0, 50));
    dxDrawRectangle(sLeft + 2, sTop + 2, sWidth - 4, sHeight - 4, tocolor(0, 0, 0, 140));
    
    dxDrawText("Betűtípusok", sLeft, sTop + 10, sLeft + sWidth, 0, tocolor(255, 255, 255, 200), 1, getFont("Rubik", 10), "center", "top");
    dxDrawRectangle(sLeft + 2 + 10, sTop + 40, sWidth - 4 - 20, 2, tocolor(60, 60, 60, 50));
    _, closeBtn = dxDrawButton(getIcon("fa-times"), sLeft + sWidth - 30, sTop + 10, 20, 20, "#f44336", "#ffffff", getFont("fontawesome", 8));
    _, restoreBtn = dxDrawButton(getIcon("fa-refresh"), sLeft + sWidth - 55, sTop + 10, 20, 20, "#2196f3", "#ffffff", getFont("fontawesome", 8));
    if restoreBtn then
        tooltip("Alapértelmezett");
    end
    local eTop = sTop + 60;
    local eLeft = sLeft + 2 + 10;
    
    fontClick = nil
    local hover = nil
    for k,v in pairs(fontsDrawn) do
        _, hover = dxDrawButton(k, eLeft, eTop, sWidth - 20 - 4, 20, "#2196f3", "#ffffff", getFont("Rubik", 8));
        
        if hover then
            fontClick = k
        end
        eTop = eTop + 40
    end
end

function showFontsIC()
    ----outputChatBox("asd")
    fontState = not fontState
    
    if fontState then
        recreateFontsWithDefSize()
        addEventHandler("onClientRender", root, drawnFonts, true, "low-5")
    else
        removeEventHandler("onClientRender", root, drawnFonts)
    end
end
--

--Global function for showChat()
_showChat = showChat
function showChat(a)
    if not customChatEnabled then
        if state then
            removeEventHandler("onClientRender", root, drawnChat)
            state = false
        end
        return _showChat(a)
    else
        _showChat(false)
        if a then
            if not state then
                addEventHandler("onClientRender", root, drawnChat, true, "low-5")
                state = true
            end
        else
            if state then
                removeEventHandler("onClientRender", root, drawnChat)
                state = false
            end
        end
        return true
    end
end

_isChatVisible = isChatVisible
function isChatVisible()
    ----outputChatBox("Custom Chat Enabled: "..tostring(customChatEnabled))
    if not customChatEnabled then
        return _isChatVisible(a)
    else
        return state
    end
end
--
--import("*"):from("ax_core")

local function initWidgets()
    --chat = exports.cr_widget:addWidget("chat", 20, 16, 500, 290, "IC Chat", false, false, true, {500 * 0.5, 290 * 0.5 - 10, 500 * 1.5, 290 * 1.5});
    
    startCustomChat()
end

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_interface" then
            setTimer(initWidgets, 1000, 1)
        elseif startedRes == getThisResource() then
            if(getResourceState(getResourceFromName("cr_interface"))=="running")then
                setTimer(initWidgets, 1000, 1)
            end
        end
    end
)

function getLines()
    local a = getChatboxLayout()["chat_lines"]
    if customChatEnabled then
        a = options["lines"]
    end
    return a
end

function recalculateIC()
    --fontsG[options["font"] .. options["fontsize"] .. options["bold"]] = --exports['ax_core']:getFont("Roboto", 10)
    --outputConsole(options["font"] or " NIl")
    ----outputChatBox("asd")
    ----outputChatBox(options["font"] .. options["fontsize"] .. options["bold"])
    local font = fontsG[options["font"] .. options["fontsize"] .. options["bold"]]
    options["font-height"] = dxGetFontHeight(1, font)
    --options["font-oneX"] = 7
    options["lines"] = math.floor(height / options["font-height"] )
    --options["xWhenBreak"] = math.floor(width / options["font-oneX"])
    --startY = startY + ((options["lines"]) * options["font-height"])
    minLines = 1
    maxLines = options["lines"]
    
    if #cache >= options["lines"] + options.cacheRemain then
        table.remove(cache, options["lines"] + options.cacheRemain)
    end

    if #cache > 0 then
        for k,v in pairs(cache) do 
            local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)

            local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
            text = string.gsub(text, "\n", "")
            local length = dxGetTextWidth(text, 1, font, true)
            
            local textSub = {}
            local a = 0
            local breaks = 0
            --outputConsole("ORIGTEXT: "..text)
            --outputConsole("LENGTH: "..length)
            --outputConsole("WIDTH: "..width)
            if length >= width then
                local i = 1
                local i2 = 1
                local start = 1
                local remainText = ""
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                    --outputConsole("NOWLENGTH: "..length)
                    if length >= width then
                        breaks = breaks + 1
                        local startpos, endpos = utf8.find(text, "#", i - 7)
                        if startpos and startpos <= i - 1 then
                            i = startpos + 7
                        end
                        if utfSub(text, i - 1, i - 1) == "#" then
                            table.insert(textSub, utfSub(text, i2, i - 2) .. "\n")
                            --table.insert(textSub, utfSub(text, i - 1, #text))
                            i2 = i - 1
                            remainText = utfSub(text, i2, #text)
                            
                            text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                        else
                            table.insert(textSub, utfSub(text, i2, i - 1) .. "\n")
                             --table.insert(textSub, utfSub(text, i, #text))
                            i2 = i
                            remainText = utfSub(text, i2, #text)
                            
                            text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                        end
                        start = i
                        --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                        --outputConsole("START: "..i)
                    elseif i + 1 >= #text then
                        table.insert(textSub, remainText)
                        break
                    end
                    i = i + 1
                end
                --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))

                --text = addCharToString(text, breakT, "\n", breaks)
            end
            
            text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
            cache[k][1] = text
            cache[k][3] = breaks + 1
            cache[k][4] = text2
            cache[k][7] = textSub
        end
        
        ----outputChatBox(tostring(typing))
        if typing then
            local text = name .. options["sayingText"]
            local a = 0
            local breaks = 0
            local length = dxGetTextWidth(text, 1, font, true)
            --outputConsole("ORIGTEXT: "..text)
            --outputConsole("LENGTH: "..length)
            --outputConsole("WIDTH: "..width)
            if length > width then
                local i = 1
                local start = 1
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, font, true)
                    --outputConsole("NOWLENGTH: "..length)
                    if length >= width then
                        breaks = breaks + 1
                        local startpos, endpos = utf8.find(text, "#", i - 7)
                        if startpos and startpos <= i - 1 then
                            i = startpos + 7
                        end
                        if utfSub(text, i - 1, i - 1) == "#" then
                            text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                        else
                            text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                        end
                        start = i
                        --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                        --outputConsole("START: "..i)
                    elseif i + 1 >= #text then
                        break
                    end
                    i = i + 1
                end
                --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))

                --text = addCharToString(text, breakT, "\n", breaks)
                --text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
            end
            options["renderText"] = string.gsub(text, name, "")
        end
    end
end

function startCustomChat()
    loadPlayerOptions()
    --initWidgets()
    --showChat(true)
    --startX, startY = exports['ax_interface']:getNode("Chat", "x"), exports['ax_interface']:getNode("Chat", "y")
    --width, height = exports['ax_interface']:getNode("Chat", "width"), exports['ax_interface']:getNode("Chat", "height")
    _, startX, startY, width, height = exports['cr_interface']:getDetails("chat") --exports['cr_widget']:getPosition(chat)
    isEnabledICChat = localPlayer:getData("chat.enabled")
    --if not isEnabledICChat then return end
    --fontsG[options["font"] .. options["fontsize"] .. options["bold"]] = font --exports['ax_core']:getFont("Roboto", 10)
    ----outputChatBox(options["font"] .. options["fontsize"] .. options["bold"])
    ----outputChatBox(options["font"] .. options["fontsize"] .. options["bold"])
    local font = fontsG[options["font"] .. options["fontsize"] .. options["bold"]]
    --outputConsole(options["font"] or " NIl")
    options["font-height"] = dxGetFontHeight(1, font)
    --options["font-oneX"] = 7
    customChatEnabled = false
    if isEnabledICChat then
        customChatEnabled = true
        owidth, oheight = width, height
        --options["xWhenBreak"] = math.floor(width / options["font-oneX"])
        options["lines"] = math.floor(height / options["font-height"] )
        startY = startY + ((options["lines"]) * options["font-height"])
        minLines = 1
        maxLines = options["lines"]
        --addMessageToCache("Teszt üzenet", 255,0,0)
        ----outputChatBox("ONEX:" .. options["font-oneX"])
        ----outputChatBox("HEIGHT:" .. options["font-height"])
        ----outputChatBox("LINES:" .. options["lines"])
        ----outputChatBox("BREAK:" .. options["xWhenBreak"])
        ----outputChatBox("StartY:" .. startY)
        --bindKey("pgup", "down", keyInteracts, "pgup", true)
        --bindKey("pgup", "up", keyInteracts, "pgup", false)
        --bindKey("pgdn", "down", keyInteracts, "pgdn", true)
        --bindKey("pgdn", "up", keyInteracts, "pgdn", false)
        ----outputChatBox(toJSON(cache))
        showChat(true)
    end
    bindKey("t", "down", startTyping, "Say")
    bindKey("b", "down", startTyping, "b")
    bindKey("y", "down", startTyping, "Rádió")
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "chat.enabled" then
            ----outputChatBox("asd")
            startCustomChat()
        end
    end
)

function upMove()
    if state then
        if maxLines + 1 <= #cache then
            maxLines = maxLines + 1 
            minLines = minLines + 1
        end
    end
end

function downMove()
    if state then
        if minLines - 1 >= 1 then
            maxLines = maxLines - 1 
            minLines = minLines - 1
        end
    end
end

function startTyping(B, B, a)
    --if not exports.cr_core:isHudVisible() then return end
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    --outputDebugString(tostring(customChatEnabled))
    --outputDebugString(tostring(state))
    --outputDebugString(tostring(typing))
    if state and customChatEnabled then
        if not typing then
            --if getElementData(localPlayer, "player.bar-Use") then return end
            --if getElementData(localPlayer, "score.bar-Use") then return end
            --if not getElementData(localPlayer, "player.loggedIn") then return end
            if a ~= "b" then
                for i, v in pairs(cache) do
                    local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                    cache[i][5] = getTickCount()
                    cache[i][6] = 255
                end
            else
                refreshOOC()
            end
            gui = GuiEdit(-1, -1, 1, 1, "", true)
            --guiEditSetCaretIndex(gui, 1)
            --guiSetProperty(gui, "AlwaysOnTop", "True")
            setTimer(guiBringToFront, 50, 1, gui)
            _oldCState = false -- isCursorShowing()
            showCursor(true)
            addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
            addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
            localPlayer:setData("player.write", true)
            localPlayer:setData("write", true)
            typing = true
            guiSetInputMode("no_binds")
            local newValue = typing
            if newValue then
                ----outputChatBox(a)
                options["textType"] = a
                name = convert[options["textType"]]
                options["sayingText"] = ""
                options["renderText"] = ""
                --toggleAllControls(false)
                bindKey("enter", "down", interactText)
            end
        end
    end
end

function onGuiBlur()
    guiBringToFront(gui)
end

function onGuiChange()
    options["sayingText"] = guiGetText(gui)
    local text = name .. options["sayingText"]
    local a = 0
    local breaks = 0
    local length = dxGetTextWidth(text, 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
    --outputConsole("ORIGTEXT: "..text)
    --outputConsole("LENGTH: "..length)
    --outputConsole("WIDTH: "..width)
    if length > width then
        local i = 1
        local start = 1
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
            --outputConsole("NOWLENGTH: "..length)
            if length >= width then
                breaks = breaks + 1
                local startpos, endpos = utf8.find(text, "#", i - 7)
                if startpos and startpos <= i - 1 then
                    i = startpos + 7
                end
                if utfSub(text, i - 1, i - 1) == "#" then
                    text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                else
                    text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                end
                start = i
                --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                --outputConsole("START: "..i)
            elseif i + 1 >= #text then
                break
            end
            i = i + 1
        end
        --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))

        --text = addCharToString(text, breakT, "\n", breaks)
        --text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    options["renderText"] = string.gsub(text, name, "")
end

function stopTyping()
    if typing then
        ----outputChatBox("asd")
        setTimer(function() typing = false end, 150, 1)
        --toggleAllControls(true)
        unbindKey("enter", "down", interactText)
        showCursor(_oldCState)
        guiSetInputMode("allow_binds")
        localPlayer:setData("player.write", false)
        localPlayer:setData("write", false)
        if isElement(gui) then
            destroyElement(gui)
        end

        if isTimer(backspaceTimer) then
            killTimer(backspaceTimer)
        end

        if isTimer(backspaceRepeatTimer) then
            killTimer(backspaceRepeatTimer)
        end

        if isTimer(buttonTimer) then
            killTimer(buttonTimer)
        end

        if isTimer(buttonTimerRepeatTimer) then
            killTimer(buttonTimerRepeatTimer)
        end
    end
end

addEventHandler("onClientKey", root, 
    function(button,press) 
        if button == "escape" and press then
            return stopTyping()
        end
    end
)

function interactText()
    local t = options["sayingText"]
    
    if #t == 0 then
        stopTyping()
    else
        local st = utfSub(t, 1, 1)
        if st == "/" then
            if #t > 1 then
                stopTyping()
                --string.byte(' ')
                local stW = utfSub(t, 2, #t)
                local cmd = gettok(t, 1, string.byte(' '))
                cmd = cmd:gsub("/", "")
                
                local match = searchSpace(t)
                local args = matchConvertToString(t, match)
                --Nagy valószínűséggel command
                
                if not executeCommandHandler(cmd, args) then
                    triggerServerEvent("executeCommand", localPlayer, cmd, args)
                end
                stopTyping()
                return
            else
                stopTyping()
                ----outputChatBox("Hibás command.")
                return
            end
        end
        
        if st and st ~= " " then
            if options["textType"] == "b" then
                executeCommandHandler("b", t)
            else
                executeCommandHandler(options["textType"], t)
            end
        end
        
        stopTyping()
        --triggerServerEvent("ca", localPlayer, t, 0)
    end
end

local disabledKey = {
    ["capslock"] = true,
    ["lctrl"] = true,
    ["rctrl"] = true,
    ["lalt"] = true,
    ["ralt"] = true,
    ["home"] = true,
}

for i = 1, 9 do
    disabledKey["F"..i] = true
end

local changeKey = {
    ["num_0"] = "0",
    ["num_1"] = "1",
    ["num_2"] = "2",
    ["num_3"] = "3",
    ["num_4"] = "4",
    ["num_5"] = "5",
    ["num_6"] = "6",
    ["num_7"] = "7",
    ["num_8"] = "8",
    ["num_9"] = "9",
    ["num_div"] = "/",
    ["space"] = " ",
    ["num_mul"] = "*",
    ["num_add"] = "+",
    ["num_sub"] = "-",
    ["num_dec"] = "."
}

local subWord = {
    [";"] = "é",
    ["#"] = "á",
    ["["] = "ő",
    ["'"] = "ö",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
    ["\\"] = "ű",
}

local upperKey = {
    ["é"] = "É",
    ["á"] = "Á",
    ["ő"] = "Ő",
    ["ö"] = "Ö",
    ["ú"] = "Ú",
    ["ó"] = "Ó",
    ["ü"] = "Ü",
    ["ű"] = "Ű",
    ["í"] = "Í"
}

local subWordBack = {}

for k,v in pairs(subWord) do
    subWordBack[v] = true
end

for k,v in pairs(upperKey) do
    subWordBack[v] = true
end

local maxChar = 100

function backspace()
    if #options["sayingText"] > 0 then
        --playSound(":ax_account/files/key.mp3")
        if allSelected then
            options["sayingText"] = ""
            allSelected = false
            return
        end
        local NText = options["sayingText"]
        local num = #NText
        local last = NText:sub(num - 1, num)
        local text = ""
        if subWordBack[last] then
            text = NText:sub(1, num - 2)
        else
            text = NText:sub(1, num - 1)
        end
        
        options["sayingText"] = text
        local text = name .. text
        local a = 0
        local breaks = 0
        local length = dxGetTextWidth(text, 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
        --outputConsole("ORIGTEXT: "..text)
        --outputConsole("LENGTH: "..length)
        --outputConsole("WIDTH: "..width)
        if length > width then
            local i = 1
            local start = 1
            while true do
                local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
                --outputConsole("NOWLENGTH: "..length)
                if length >= width then
                    breaks = breaks + 1
                    local startpos, endpos = utf8.find(text, "#", i - 7)
                    if startpos and startpos <= i - 1 then
                        i = startpos + 7
                    end
                    if utfSub(text, i - 1, i - 1) == "#" then
                        text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                    else
                        text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                    end
                    start = i
                    --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                    --outputConsole("START: "..i)
                elseif i + 1 >= #text then
                    break
                end
                i = i + 1
            end
            --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))

            --text = addCharToString(text, breakT, "\n", breaks)
            --text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
        end
        text = string.gsub(text, name, "")
        options["renderText"] = text
    end
end

function interactButton(b)
    
    if b == "enter" or b == "num_enter" then
        return interactText()
    end
    
    ----outputChatBox(b)
    if b == "pgup" then
        return upMove()
    end
    
    if b == "pgdn" then
        return downMove()
    end
    
    return
    --[[
    local subWorded = false
       
    if subWord[b] then 
        b = subWord[b] 
    end
    
    if changeKey[b] then 
        b = changeKey[b] 
    end

    if not disabledKey[b] and #b < 3 or b == " " then
        
        if b == "." then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = ":"
            end
        end
        
        if b == "," then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "?"
            end
        end
        
        if b == "8" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "("
            end
        end
        
        if b == "j" then
            if getKeyState("lalt") or getKeyState("ralt") then
                b = "í"
            end
        end
        
        if b == "1" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "'"
            end
        end
        
        if b == "3" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "+"
            end
        end
        
        if b == "2" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = '"'
            end
        end
        
        if b == "4" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "!"
            end
        end
        
        if b == "5" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "%"
            end
        end
        
        if b == "6" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "/"
            end
        end
        
        if b == "7" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "="
            end
        end
        
        if b == "9" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = ")"
            end
        end
        
        if string.lower(b) == "f" then
            if getKeyState("lalt") or getKeyState("ralt") then
                b = "["
            end
        end
        
        if string.lower(b) == "," then
            if getKeyState("lalt") or getKeyState("ralt") then
                b = ";"
            end
        end
        
        if string.lower(b) == "g" then
            if getKeyState("lalt") or getKeyState("ralt") then
                b = "]"
            end
        end
        
        if string.lower(b) == "i" then
            if getKeyState("lalt") or getKeyState("ralt") then
                b = "Í"
            end
        end
        
        if getKeyState("lshift") or getKeyState("rshift") then
            if upperKey[b] then
                b = upperKey[b]
            end
            b = string.upper(b)
        else
            b = string.lower(b)
        end
        
        if #options["sayingText"] + 1 > maxChar then
            return
        end

        if allSelected then
            textbars[now][2][2] = ""
            allSelected = false
        end

        --playSound(":ax_account/files/key.mp3")
        options["sayingText"] = options["sayingText"] .. b
        local text = name .. options["sayingText"]
        local a = 0
        local breaks = 0
        local length = dxGetTextWidth(text, 1, fontsG[options["font"], true)
        --outputConsole("ORIGTEXT: "..text)
        --outputConsole("LENGTH: "..length)
        --outputConsole("WIDTH: "..width)
        if length > width then
            local i = 1
            local start = 1
            while true do
                local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"], true)
                --outputConsole("NOWLENGTH: "..length)
                if length >= width then
                    breaks = breaks + 1
                    if utfSub(text, i - 1, i - 1) == "#" then
                        text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                    else
                        text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                    end
                    start = i
                    --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                    --outputConsole("START: "..i)
                elseif i + 1 >= #text then
                    break
                end
                i = i + 1
            end
            --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))

            --text = addCharToString(text, breakT, "\n", breaks)
            --text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
        end
        options["renderText"] = string.gsub(text, name, "")
    end
    ]]
end

function keyInteracts(b, s)
    if not s then
        if b == "backspace" then
            if isTimer(backspaceRepeatTimer) then
                killTimer(backspaceRepeatTimer)
            end
        elseif b == _b then
            if isTimer(buttonTimer) then
                killTimer(buttonTimer)
            end
            
            if isTimer(buttonTimerRepeatTimer) then
                killTimer(buttonTimerRepeatTimer)
            end
        end
    end
    if s and typing or s and b == "pgup" or s and b == "pgdn" then
        ----outputChatBox(b)
        if b == "backspace" then
            backspace()
            if isTimer(backspaceTimer) then
                killTimer(backspaceTimer)
            end

            if isTimer(backspaceRepeatTimer) then
                killTimer(backspaceRepeatTimer)
            end
            
            --[[
            backspaceTimer = setTimer(
                function()
                    if getKeyState("backspace") then
                        backspace()
                        backspaceRepeatTimer = setTimer(
                            function()
                                if getKeyState("backspace") then
                                    backspace()
                                end
                            end, 50, 0
                        )
                    end
                end, 600, 1
            )
            ]]
            return
        elseif b == "home" then
            if getKeyState("lshift") or getKeyState("rshift") then
                allSelected = true
                return
            end
        elseif b == "lshift" or b == "rshift" then
            if getKeyState("home") then
                allSelected = true
                return
            end
        elseif b == "-" then
            if getKeyState("lshift") or getKeyState("rshift") then
                b = "_"
            end
        end

        if isTimer(buttonTimer) then
            killTimer(buttonTimer)
        end

        if isTimer(buttonTimerRepeatTimer) then
            killTimer(buttonTimerRepeatTimer)
        end

        ----outputChatBox("A" .. b)
        _b = b
        if b == "enter" or b == "num_enter" or b == "pgup" or b == "pgdn" then
            interactButton(b)
            if b == "pgup" or b == "pgdn" then
                buttonTimer = setTimer(
                    function()
                        if getKeyState(_b) then
                            interactButton(_b)
                            buttonTimerRepeatTimer = setTimer(
                                function()
                                    if getKeyState(_b) then
                                        interactButton(_b)
                                    end
                                end, 50, 0
                            )
                        end
                    end, 500, 1
                )
            end
        else
            cancelEvent()
        end
    end
end
addEventHandler("onClientKey", root, keyInteracts)

function addMessageToCache(text, r,g,b)
    
    if not customChatEnabled then return end
    if not text or #text <= 0 then return end
    
    if #cache >= options["lines"] + options.cacheRemain then
        table.remove(cache, options["lines"] + options.cacheRemain)
    end
    
    
    if isTimer(mTimer) then killTimer(mTimer) end
    if maxLines > options["lines"] then
        mTimer = setTimer(
            function()
                downMove()
                if minLines == 1 then
                    killTimer(mTimer)
                end
            end, 50, 0
        )
    end
    
    local length = dxGetTextWidth(text, 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
    
    local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    text = string.gsub(text, "\n", "")
    
    local a = 0
    local breaks = 0
    --outputConsole("ORIGTEXT: "..text)
    --outputConsole("LENGTH: "..length)
    --outputConsole("WIDTH: "..width)
    local textSub = {}
    if length > width then
        local i = 1
        local start = 1
        local i2 = 1
        local remainText = ""
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
            --outputConsole("NOWLENGTH: "..length)
            if length >= width then
                breaks = breaks + 1
                local startpos, endpos = utf8.find(text, "#", i - 7)
                if startpos and startpos <= i - 1 then
                    i = startpos + 7
                end
                if utfSub(text, i - 1, i - 1) == "#" then
                    table.insert(textSub, utfSub(text, i2, i - 2) .. "\n")
                    --table.insert(textSub, utfSub(text, i - 1, #text))
                    i2 = i - 1
                    remainText = utfSub(text, i2, #text)
                    text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                else
                    table.insert(textSub, utfSub(text, i2, i - 1) .. "\n")
                     --table.insert(textSub, utfSub(text, i, #text))
                    i2 = i
                    remainText = utfSub(text, i2, #text)
                    text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                end
                start = i
                --outputConsole("SUBTEXT:" .. string.gsub(text, "\n", "PU"))
                --outputConsole("START: "..i)
            elseif i + 1 >= #text then
                table.insert(textSub, remainText)
                break
            end
            i = i + 1
        end
        --outputConsole("FINALTEXT:" .. string.gsub(text, "\n", "PU"))
        
        --text = addCharToString(text, breakT, "\n", breaks)
        text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    
    --text = addCharToString(text, a, "\n", breaks)
    --text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    local t = {text, {r,g,b}, breaks + 1, text2, getTickCount(), 255, textSub}
    table.insert(cache, 1, t)
    
    --[[
    outputConsole(#cache)
    outputConsole(maxLines)
    if #cache >= maxLines then
        minLines = maxLines - (options["lines"]) + 1
        maxLines = #cache
    end
    
    if #cache <= 0 then
        if state then
            removeEventHandler("onClientRender", root, drawnChat)
            state = false
        end
    else
        if not state then
            addEventHandler("onClientRender", root, drawnChat, true, "low-5")
            state = true
        end
    end
    ]]
end
addEventHandler("onClientChatMessage", root, addMessageToCache)

local between = 40

function drawnChat()
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    isChatEnabled, startX, startY, width, height = exports['cr_interface']:getDetails("chat")
    __startY = startY
    local _startY = startY
    if not isChatEnabled then
        customChatEnabled = false
        if not isChatEnabled then
            if not bb then
                bb = true
                _showChat(true)
            end
        end
        return
    else
        bb = false
        --showChat(false)
        customChatEnabled = true
        _showChat(false)
    end    
    if owidth ~= width or oheight ~= height then
        --outputChatBox("asd")
        recalculateIC()
    end
    
    owidth, oheight = width, height
    
    local lines = 0
    for k,v in pairs(cache) do
        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
        lines = lines + line
    end
    if not lines or not options["lines"] then
        return
    end
    startY = startY + ((math.min(lines, options["lines"])) * options["font-height"]) --((options["lines"]) * options["font-height"])
    
    --dxDrawRectangle(startX, startY, width, options["font-height"], tocolor(255,0,0,180))
    local r,g,b,a = unpack(options["background"])
    dxDrawRectangle(startX, _startY, width, height, tocolor(r,g,b,a))
    
    local _maxLines, maxLines = options["lines"], maxLines
    local startY = startY - options["font-height"] 
    local _startY, startY = startY, startY
    if #cache >= 1 then
        --outputConsole(options.fadeout)
        if options.fadeout == 0 then
            local now = getTickCount() 
            --outputConsole(now)
            for i, v in pairs(cache) do
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                --outputConsole(oTick .. " > "..between)
                if oTick + (between * 1000) < now then
                    --outputConsole(multipler .. "CC")
                    cache[i][6] = alpha - multipler
                    --alpha = alpha - multipler
                    --outputConsole(cache[i][6])
                    if cache[i][6] <= -60 then
                        table.remove(cache, i)
                    end
                end
            end
        end
        
        --outputConsole("minLines: "..minLines)
        --outputConsole("maxLines: "..maxLines)
        for i = minLines, math.min(maxLines, #cache) do 
            if cache[i] then
                local v = cache[i]
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                local _CA = false
                if i >= minLines and i <= maxLines then

                    if line > 1 and i < minLines + 1 then
                        startY = startY - (options["font-height"] * (line - 1))
                    end
                    
                    ----outputChatBox(i + (line - 1).. ">" .. line - 1 .. ">"..maxLines)
                    if line - 1 > 0 then
                        if i + (line - 1) > maxLines then
                            local terrain = {}
                            local _i = i
                            --dxDrawRectangle(0, startY, 200, 2)
                            ----outputChatBox(startY)
                            ----outputChatBox(__startY)
                            local tY = math.floor(math.floor(__startY - startY) / options["font-height"])
                            for i = 1, tY do 
                                --local i = i - _i
                                ----outputChatBox("Ezt a sort: "..i.." törölni kell!")
                                --line = line - 2
                                --__startY = __startY - (options["font-height"] * (1))
                                terrain[i] = true
                            end
                            
                            --dxDrawRectangle(0, __startY, 200, 5)
                            
                            local newText = ""
                            ----outputChatBox(toJSON(textSub))
                            for BB = 1, #textSub do --for k,v in pairs(textSub) do
                                local v = textSub[BB]
                                local v = v:gsub("\n", "")
                                ----outputChatBox(BB..">"..v)
                                if not terrain[BB] then
                                    newText = newText .. "#ffffff" .. v .. "\n"
                                end
                            end
                            ----outputChatBox(newText)
                            
                            _CA = true
                            text = newText
                            textWithNoColor = string.gsub(newText, "#%x%x%x%x%x%x", "")
                        end
                    end

                    alpha = math.max(alpha, 0)

                    local r,g,b = unpack(color)
                    --[[local line = 1
                    if i % 2 == 0 then
                        dxDrawRectangle(startX, startY, width, options["font-height"] * line, tocolor(0,0,0,220))
                    else
                        dxDrawRectangle(startX, startY, width, options["font-height"] * line, tocolor(0,0,0,180))
                    end
                    ----outputChatBox(v[1])
                    ]]
                    if _CA then
                        local startY = __startY
                        if alpha >= 1 then
                            dxDrawText(textWithNoColor, startX+1, startY+1, startX + width+1, startY+1, tocolor(0,0,0,alpha), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, true)
                            dxDrawText(text, startX, startY, startX + width, startY, tocolor(r,g,b,alpha), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, true)
                        end
                    else
                        if alpha >= 1 then
                            dxDrawText(textWithNoColor, startX+1, startY+1, startX + width+1, startY + (options["font-height"] * line)+1, tocolor(0,0,0,alpha), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, true)
                            dxDrawText(text, startX, startY, startX + width, startY + (options["font-height"] * line), tocolor(r,g,b,alpha), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, true)
                        end
                    end
                    --outputConsole("LINES: "..line)
                    --outputConsole("startY1: "..startY)
                    --outputConsole("startY2: "..startY)

                    if cache[i + 1] then
                        local v = cache[i + 1]
                        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                        --outputConsole((math.max(line, 2) - 1))
                        local b = math.max(line, 2)
                        if line >= 2 then
                            startY = startY - (options["font-height"] * (b))
                        else
                            startY = startY - (options["font-height"] * (b - 1))
                        end
                    end
                    
                    if line > 1 then
                        maxLines = maxLines - (line - 1)
                        --outputConsole("MAXLINeS: "..maxLines)
                    end
                end
            end
        end
    end
    
    local startY = _startY + (1 * options["font-height"])
    if typing then
        dxDrawText(name .. options["renderText"], startX+1, startY+1, startX + width+1, startY + (options["font-height"])+1, tocolor(0,0,0,255), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, false)
        dxDrawText(name .. options["renderText"], startX, startY, startX + width, startY + (options["font-height"]), tocolor(255,255,255,255), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], "left", "top", false, false, false, false)
    end
end

function clearChat(cmd)
    cache = {}
    --outputChatBox(exports['cr_core']:getServerSyntax() .. "IC Chat sikeresen kiürítve!", 0,255,0,true)
end
addCommandHandler("clearCHAT", clearChat)
addCommandHandler("ClearChat", clearChat)
addCommandHandler("Clearchat", clearChat)
addCommandHandler("clearchat", clearChat)

--
function searchSpace(a)
    local match = {}
    local d = 0
    local s = 0
   
    while true do
        local b, c = utf8.find(a, "%s", s)
        if b then
            s = b + 1
            d = d + 1
            match[d] = b
        else
            break
        end
    end
   
    return match
end
 
function matchConvertToString(text, matchTable)
    local args = ""
    local d = 0
    for i = 1, #matchTable do
        local v = matchTable[i] + 1
        ----outputChatBox("START: ".. v)
        if matchTable[i+1] then
            local v2 = matchTable[i+1] - 1
            ----outputChatBox("END: ".. v2)
            local e = utfSub(text, v, v2)
            if #e > 0 then
                ----outputChatBox("TEXT: ".. e)
                d = d + 1
                if tonumber(e) ~= nil then
                    e = tonumber(e)
                end
                args = args .. e .. " "
            end
        else
            d = d + 1
            ----outputChatBox("END: ".. #text)
            local e = utfSub(text, v, #text)
            if #e > 0 then
                ----outputChatBox("TEXT: ".. e)
                if tonumber(e) ~= nil then
                    e = tonumber(e)
                end
                args = args .. e .. " "
            end
        end
    end
   
    return args
    --Használatkor: executeCommandHandler("asd", source, unpack(table))
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        cache = exports.cr_json:jsonGET("iccache")
        cache = {}
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        exports.cr_json:jsonSAVE("iccache", cache)
    end
)