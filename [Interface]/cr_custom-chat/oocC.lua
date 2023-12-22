fileDelete("oocC.lua")

--local font = dxCreateFont(":cr_gameplay/files/roboto.ttf", 10)

local cache = {}
local options = {}

local minLines, maxLines = 0,0

local startX, startY = 0,0
local _startX, _startY, __startY = 0,0,0
local width, height = 0,0
local owidth,oheight = 0,0

local state = false
--local enabled,x,y,w,h,sizable,turnable = getDetails("ooc")
local x,y = 20, 500
local maxLength = 10

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
    ["r"] = "Rádió: ",
}

local editVals = {}
local restoreBtn, closeBtn, fontBtn = nil, nil, nil

local fonts = fonts
local fontsG = {}
--[[
for k,v in pairs(fonts) do
    fontsG[k] = dxCreateFont(v[1], v[2])
end]]

local function recreateFontsG()
    --fontsG = {}
    --for k,v in pairs(fonts) do
        --if k == options.font then
    local k = options["font"]
    local v = options["fontsize"]
    local b = options["bold"]
    if not fontsG[k..v..b] then
        fontsG[k..v..b] = dxCreateFont(fonts[k][1], v, options.bold == 0)
    end
end

local defFont = "Roboto"
local defFontSize = 10

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
    recalculateOOC()
    options.fadeout = 0
    options.fadeoutMultipler = 0.15
    multipler = options.fadeoutMultipler
    options.background = {0,0,0,0} -- r,g,b,a
    options.cacheRemain = 10
end

local function loadPlayerOptions()
    local data = exports.cr_json:jsonGET("OOCsettings");
    
    if not data.bold then
        data.bold = 1
    end
    
    --outputConsole(data.font)
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
                    recalculateOOC()
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
                    recalculateOOC()
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
                    showOptionsOOC()
                    closeBtn = nil
                elseif restoreBtn then
                    refreshOptions()
                    restoreBtn = nil
                elseif fontBtn then
                    showOptionsOOC()
                    showFontsOOC()
                    fontBtn = nil
                end
            elseif fontState then
                if closeBtn then
                    showFontsOOC()
                    closeBtn = nil
                elseif restoreBtn then
                    --refreshOptions()
                    options.font = defFont
                    options.fontsize = defFontSize
                    fonts[options.font][2] = options.fontsize
                    recreateFontsG()
                    recalculateOOC()
                    restoreBtn = nil
                elseif fontClick then
                    ----outputChatBox(fontClick)
                    options.font = fontClick
                    fonts[options.font][2] = options.fontsize
                    recreateFontsG()
                    recalculateOOC()
                end
            end
        end
    end
)

local function savePlayerOptions()
    exports.cr_json:jsonSAVE("OOCsettings", options);
end 
addEventHandler("onClientResourceStop", resourceRoot, savePlayerOptions)

local function drawnOptions()
end

function showOptionsOOC()
    fontState = true
    showFontsOOC()
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
    for k,v in pairs(fontsDrawn) do
        _, hover = dxDrawButton(k, eLeft, eTop, sWidth - 20 - 4, 20, "#2196f3", "#ffffff", getFont("Rubik", 8));
        
        if hover then
            fontClick = k
        end
        eTop = eTop + 40
    end
end

function showFontsOOC()
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


local function initWidgets()
    --oocchat = exports.cr_widget:addWidget("oocchat", 20, 330, 500, 140, "OOC Chat", false, false, true, {350, 100, 500 * 1.5, 150 * 2});
    
    startOOC()
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

function recalculateOOC()
    --options["font-height"] = dxGetFontHeight(1, options["font"])
    --options["font-oneX"] = 7
    local font = fontsG[options["font"] .. options["fontsize"] .. options["bold"]]
    options["font-height"] = dxGetFontHeight(1, font)
    --options["font-oneX"] = 7
    options["lines"] = math.floor(height / options["font-height"])
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
            local length = dxGetTextWidth(text, 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)

            local a = 0
            local breaks = 0
            --outputConsole("ORIGTEXT: "..text)
            --outputConsole("LENGTH: "..length)
            --outputConsole("WIDTH: "..width)
            local textSub = {}
            local inserted = {}
            if length >= width then
                local i = 1
                local i2 = 1
                local start = 1
                local remainText = ""
                while true do
                    local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
                    --outputConsole("NOWLENGTH: "..length)
                    if length >= width then
                        breaks = breaks + 1
                        if utfSub(text, i - 1, i - 1) == "#" then                            
                            table.insert(textSub, utfSub(text, i2, i - 2) .. "\n")
                            --table.insert(textSub, utfSub(text, i - 1, #text))
                            i2 = i - 1
                            remainText = utfSub(text, i2, #text)
                            
                            --textSub[breaks] = utfSub(text, 1, i - 2) .. "\n"
                            --textSub[breaks + 1] = utfSub(text, i - 1, #text)
                            text = utfSub(text, 1, i - 2) .. "\n" .. utfSub(text, i - 1, #text)
                        else
                            table.insert(textSub, utfSub(text, i2, i - 1) .. "\n")
                             --table.insert(textSub, utfSub(text, i, #text))
                            i2 = i
                            remainText = utfSub(text, i2, #text)
                            
                            --textSub[breaks] = utfSub(text, 1, i - 1) .. "\n"
                            --textSub[breaks + 1] = utfSub(text, i, #text)
                            text = utfSub(text, 1, i - 1) .. "\n" .. utfSub(text, i, #text)
                        end
                        ----outputChatBox(toJSON(textSub))
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
    end
end

function refreshOOC()
    for i, v in pairs(cache) do
        local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
        cache[i][5] = getTickCount()
        cache[i][6] = 255
    end
end

function startOOC()
    --showChat(false
    _, startX, startY, width, height = exports['cr_interface']:getDetails("oocchat") --exports['cr_widget']:getPosition(oocchat)
    isEnabledOOCChat = localPlayer:getData("oocchat.enabled")
    loadPlayerOptions()
    local font = fontsG[options["font"] .. options["fontsize"] .. options["bold"]]
    options["font-height"] = dxGetFontHeight(1, font)
    if isEnabledOOCChat then
        
        addEventHandler("onClientRender", root, drawnOOC, true, "low-5")
        
        ----outputChatBox(width)
        owidth, oheight = width, height
        --customChatEnabled = true
        --options["font"] = font
        options["font-height"] = dxGetFontHeight(1, font)
        --options["font-oneX"] = 7
        options["lines"] = math.floor(height / options["font-height"])
        ----outputChatBox(options["lines"])
        --options["xWhenBreak"] = math.floor(width / options["font-oneX"])
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
        --showChat(getElementData(localPlayer, "player.hud-visible"))
    else
        removeEventHandler("onClientRender", root, drawnOOC)
    end
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "oocchat.enabled" then
            startOOC()
        end
    end
)

function clearOOC(cmd)
    --outputChatBox(exports['cr_core']:getServerSyntax() .. "OOC Chat sikeresen kiürítve!", 0,255,0,true)
    cache = {}
end
addCommandHandler("clearOOC", clearOOC)
addCommandHandler("ClearOOC", clearOOC)
addCommandHandler("Clearooc", clearOOC)
addCommandHandler("clearooc", clearOOC)

function insertOOC(text, color)
    if not color then
        color = {255,255,255}
    end
    local r,g,b = unpack(color)
    
    if #cache >= options["lines"] + options.cacheRemain then
        table.remove(cache, options["lines"] + options.cacheRemain)
    end
    
    --[[
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
    --]]
    
    local length = dxGetTextWidth(text, 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
    
    local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    text = string.gsub(text, "\n", "")
    
    local a = 0
    local breaks = 0
    --outputConsole("ORIGTEXT: "..text)
    --outputConsole("LENGTH: "..length)
    --outputConsole("WIDTH: "..width)
    local textSub = {}
    local inserted = {}
    if length > width then
        local i = 1
        local i2 = 1
        local start = 1
        local remainText = ""
        while true do
            local length = dxGetTextWidth(utfSub(text, start, i), 1, fontsG[options["font"] .. options["fontsize"] .. options["bold"]], true)
            --outputConsole("NOWLENGTH: "..length)
            if length >= width then
                breaks = breaks + 1
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
--addEventHandler("onClientChatMessage", root, addMessageToCache)

local between = 60
--local multipler = 0.15

function drawnOOC()
    if not localPlayer:getData("hudVisible") then return end
    if not localPlayer:getData("loggedIn") then return end
    --startX, startY = exports['ax_interface']:getNode("OOC Chat", "x"), exports['ax_interface']:getNode("OOC Chat", "y")
    isOOCEnabled, startX, startY, width, height = exports['cr_interface']:getDetails("oocchat") --exports['cr_widget']:getPosition(oocchat)
    if not isOOCEnabled then return end
    __startY = startY
    startY = startY - 20
    --startY = startY - (options["font-height"]) 
    _startY = startY
    if owidth ~= width or oheight ~= height then
        recalculateOOC()
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
    --width, height = exports['ax_interface']:getNode("OOC Chat", "width"), exports['ax_interface']:getNode("OOC Chat", "height")
    
    --dxDrawRectangle(startX, startY, width, options["font-height"], tocolor(255,0,0,180))
    local r,g,b,a = unpack(options["background"])
    dxDrawRectangle(startX, _startY, width, height, tocolor(r,g,b,a))
    --dxDrawRectangle(startX, startY, width, -height, tocolor(r,g,b,100))
    
    --dxDrawText("OOC Chat (törléshez /clearooc)", startX+1, _startY + 5+1, startX+1, _startY + 5+1, tocolor(0,0,0,255), 1, "default-bold", "left", "center")
    --dxDrawText("OOC Chat (törléshez /clearooc)", startX, _startY + 5, startX, _startY + 5, tocolor(255,255,255,255), 1, "default-bold", "left", "center")
    
    local _maxLines, maxLines = options["lines"], maxLines
    --local startY = startY + 15
    local _startY, startY = startY, startY
    if #cache >= 1 then
        local now = getTickCount() 
        if options.fadeout == 0 then
            for i, v in pairs(cache) do
                local text, color, line, textWithNoColor, oTick, alpha, textSub = unpack(v)
                if oTick + (between * 1000) < now then
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
                                    newText = newText .. v .. "\n"
                                end
                            end
                            ----outputChatBox(newText)
                            
                            _CA = true
                            text = newText
                            textWithNoColor = string.gsub(text, "#%x%x%x%x%x%x", "")
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
                        if alpha >= 1 then
                            local startY = __startY
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
end

function getHourAndMinute()
	local realtime = getRealTime()
	hours = realtime.hour
	minute = realtime.minute
	if hours < 10 then
		hours = "0"..hours
	end
	if minute < 10 then
		minute = "0"..minute
	end
	return hours..":"..minute
end

function onOOCMessageSend(message, typ, p)
    if not p then
        p = localPlayer
    end
    if not typ then
        typ = 0
    end
	local text = "["..getHourAndMinute().."] "..message
	if getElementData(p, "admin >> duty") or tostring(typ) == "gb" then
		adminduty = 1
	else
		adminduty = 0
	end
	insertOOC(text, adminduty == 1 and {255, 0, 0})
	outputConsole("[OOC]"..text)
end
addEvent("onOOCMessageSend", true)
addEventHandler("onOOCMessageSend", root, onOOCMessageSend)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        cache = exports.cr_json:jsonGET("ooccache")
        cache = {}
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        exports.cr_json:jsonSAVE("ooccache", cache)
    end
)