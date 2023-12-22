textbars = {}
local state = false
local oText = "***********************************************************************************************************"
local disabledKey = {
    ["capslock"] = true,
    ["lctrl"] = true,
    ["rctrl"] = true,
    ["lalt"] = true,
    ["ralt"] = true,
    ["home"] = true,
    [";"] = true,
    ["'"] = true,
    ["]"] = true,
    ["["] = true,
    ["="] = true,
    ["_"] = true,
    ["á"] = true,
    ["é"] = true,
    ["ű"] = true,
    ["#"] = true,
    ["\ "] = true,
    ["/"] = true,
    --["."] = true,
    [","] = true,
    ['"'] = true,
    ["_"] = true,
    ["-"] = true,
    ["*"] = true,
    ["-"] = true,
    ["+"] = true,
}
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
}
guiState = false
now = 0
tick = 0
 
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

function CreateNewBar(name, details, options, id)
    textbars[name] = {details, options, id}
    now = nil
    guiState = false
    tick = 0
    if name == "Char-Reg.Age" or name == "Char-Reg.Name" or name == "Char-Reg.Weight" or name == "Char-Reg.Height" then
        now = name
        textbars[now][2][2] = ""
        --outputChatBox(k)
        --tick = 250
        setElementData(localPlayer, "inventory.bar-Use", true)
        --guiState = false
        allSelected = false
    end
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function Clear()
    textbars = {}
    now = nil
    guiState = false
    tick = 0
    if now == "Char-Reg.Age" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
        setElementData(localPlayer, "inventory.bar-Use", false)
        guiState = false
        tick = 0
        now = 0
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        setElementData(localPlayer, "inventory.bar-Use", false)
        state = false
    end
end

function UpdatePos(name, details)
    textbars[name][1] = details
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        state = true
    end
end

function GetText(name)
    return textbars[name][2][2]
end

local subTexted = {
    ["CharRegisterHeight"] = " kg",
    ["CharRegisterWeight"] = " cm",
    ["CharRegisterAge"] = " év",
}

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
        
        if secured then
            text = utfSub(oText, 1, #options[2])
        end
        
        if k ~= "Char-Reg.Age" and k ~= "Char-Reg.Name" and k ~= "Char-Reg.Height" and k ~= "Char-Reg.Weight" then
            if now == k then
                tick = tick + 5
                if tick >= 425 then
                    tick = 0
                elseif tick >= 250 then
                    text = text .. "|"
                end 
            end

            if subTexted[k] then
                text = text .. subTexted[k]
            end

            dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY)
        end
    end
end

local allSelected = false

addEventHandler("onClientClick", root,
    function(b, s)
        if s == "down" then
            if now == "Char-Reg.Age" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
                return
            end
            for k,v in pairs(textbars) do
                local x,y,w,h = unpack(v[1])
                if isInSlot(x,y,w,h) then
                    now = k
                    textbars[now][2][2] = ""
                    --outputChatBox(k)
                    tick = 250
                    setElementData(localPlayer, "inventory.bar-Use", true)
                    guiState = true
                    allSelected = false
                    return
                end
            end
            setElementData(localPlayer, "inventory.bar-Use", false)
            guiState = false
            tick = 0
            now = 0
        end
    end
)

local subWord = {
    [";"] = "é",
    ["#"] = "á",
    ["["] = "ő",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
}

--CTRL C + V müködjön!!!

addEventHandler("onClientKey", root,
    function(b, s)
        if guiState and s then
            if b == "tab" then
                local idTable = {}
                --idTable[k] = i
                for k,v in pairs(textbars) do
                    local i = textbars[k][3]
                    idTable[k] = i
                    idTable[i] = k
                end
                local newNum = idTable[now] + 1
                if idTable[newNum] then
                    now = idTable[newNum]
                else    
                    now = idTable[1]
                end
                return
            elseif b == "backspace" then
                playSound("assets/sounds/key.mp3")
                if allSelected then
                    textbars[now][2][2] = ""
                    allSelected = false
                    return
                end
                local options = textbars[now][2]
                local NText = options[2]
                local num = #NText
                local text = NText:sub(1, num - 1)
                tick = 250 -- Release a ticknek.
                textbars[now][2][2] = text
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
            end
            
            local subWorded = false
            
            if changeKey[b] then 
                b = changeKey[b] 
            end
            
            if now == "Char-Reg.Name" then
                local b2 = " " .. b .. " "
                if b == "space" then
                    b = " "
                elseif subWord[b] or b2 == " \ " then
                    exports["ax_infobox"]:addBox("warning", "A nevedben nem szerepelhet ékezet!")
                    return
                elseif tonumber(b) ~= nil then
                    exports["ax_infobox"]:addBox("warning", "A nevedben nem szerepelhet szám!")
                    return
                end
            end
            
            if not disabledKey[b] and #b < 2 or b == " " then
                if now == "Register.Email" then
                    if b == "v" then
                        if getKeyState("lalt") or getKEyState("ralt") then
                            b = "@"
                        end
                    elseif b == "." then
                        b = "."
                    end
                else
                    if b == "." then
                        return
                    end
                end
                if getKeyState("lshift") or getKeyState("rshift") then
                    b = string.upper(b)
                else
                    b = string.lower(b)
                end
                if #textbars[now][2][2] + 1 > textbars[now][2][1] then
                    return
                end
                if textbars[now][2][3] then -- Ha only number
                    if tonumber(b) == nil then -- Ha a stringet átalakítjuk numberré akkor számot kell kapjunk de ha van benne betű akkor nilé alakul.
                        return
                    end
                end
                if allSelected then
                    textbars[now][2][2] = ""
                    allSelected = false
                end
                playSound("assets/sounds/key.mp3")
                textbars[now][2][2] = textbars[now][2][2] .. b
                tick = 250 -- Release a ticknek.
            end
        end
    end
)

function changeChatBoxUsageOnElementDataChange(dName, oValue)
    if dName == "inventory.bar-Use" then
        local value = getElementData(source, dName)
        if value then
            toggleControl("chatbox", false)
        else
            toggleControl("chatbox", true)
        end
    end
end
addEventHandler("onClientElementDataChange", root, changeChatBoxUsageOnElementDataChange)