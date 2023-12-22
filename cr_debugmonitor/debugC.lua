local screenW, screenH = guiGetScreenSize()

local chatData = getChatboxLayout()
local lines = chatData["chat_lines"]
local debugLines = {}

local debugTypes = {"#cc0000[ERROR]: ", "#cccc00[WARNING]: ", "#00cc00[INFO]: "}
debugTypes[0] = "#7cc576[CUSTOM]: "

addCommandHandler("cleardebugs", function()
    debugLines = {}
end)

local positions = {0, screenH - 80}

addCommandHandler("debugmode", function()
    if getElementData(localPlayer, "admin >> level") >= 8 then
    	debugShow = not debugShow

    	if debugShow then
    		outputChatBox("Debug mode bekapcsolva", 0, 255, 0)
    	else
    		outputChatBox("Debug mode kikapcsolva", 255, 0, 0)
    	end
    end
end)

addEvent("debug->ClearChat", true)
addEventHandler("debug->ClearChat", root, function()
	debugLines = {}
end)

addEvent("debug->Add", true)
addEventHandler("debug->Add", root, function(message, level, file, line)
	addDebugMessage(message, level, file, line)
end)

addEventHandler("onClientDebugMessage", root, function(message, level, file, line)
    addDebugMessage(message, level, file, line)
end)

function addDebugMessage(message, level, file, line)
    local file = file or ""
    local line = line or 1
    local level = level or 1
    local message = message or ""
    
    local result = 0
    
    for index, value in pairs(debugLines) do
        if value.text == debugTypes[level] .. file .. ":" .. line .. ": #ffffff" .. message then
            result = index
        end
    end

    if type(result) == "number" and result > 0 and getTickCount() - debugLines[result].time < 60000 then
        debugLines[result].amount = debugLines[result].amount + 1
        debugLines[result].time = getTickCount()
    else
        local msg = debugTypes[level] .. file .. ":" .. line .. ": #ffffff" .. message
        table.insert(debugLines, {text = msg, amount = 1, time = getTickCount()})
    end
        
    if #debugLines > lines then
        table.remove(debugLines, 1)
    end 
end

local font = dxCreateFont("Roboto.ttf", 10)

local y = positions[2]

addEventHandler("onClientRender", root, function()
    if debugShow then
        for index = 1, lines do
            local value = debugLines[index]
            if value then
                local text = value.text or ""
                local level = value.level or 1
                local amount = value.amount or 1
                
                if amount > 1 then
                	dxDrawText("["..amount.."x]" .. text:gsub("#%x%x%x%x%x%x", ""), 1, y + 1, screenW + 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText("["..amount.."x]" .. text:gsub("#%x%x%x%x%x%x", ""), 1, y - 1, screenW - 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText("["..amount.."x]" .. text:gsub("#%x%x%x%x%x%x", ""), -1, y + 1, screenW + 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText("["..amount.."x]" .. text:gsub("#%x%x%x%x%x%x", ""), -1, y - 1, screenW - 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                   
                    dxDrawText("#7cc576["..amount.."x]" .. text, 0, y, screenW, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                else
                	dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), 1, y + 1, screenW + 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), 1, y - 1, screenW - 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), -1, y + 1, screenW + 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                	dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), -1, y - 1, screenW - 1, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)

                    dxDrawText(text, 0, y, screenW, 0, tocolor(0, 0, 0), 1, font, "center", "top", false, false, false, true)
                end

                y = y - 15
            end
        end

        y = positions[2]
    end
end)