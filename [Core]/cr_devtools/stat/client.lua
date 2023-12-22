local sx,sy = guiGetScreenSize()
local resStat = false
local clientRows = {}, {}
local serverRows = {}, {}

local avgC, avgCM, avgS, avgSM = 0,0, 0,0

local MED_CLIENT_CPU = 5 -- 5%
local MAX_CLIENT_CPU = 10 -- 10%

local MED_SERVER_CPU = 1 -- 1%
local MAX_SERVER_CPU = 2 -- 3%

function dxDrawRectangle(x,y,w,h,color2, color)
    return exports['cr_core']:roundedRectangle(x,y,w,h,color, color2)
end

addCommandHandler("stat", 
    function()
        if exports['cr_core']:getPlayerDeveloper(localPlayer) then
            resStat = not resStat
            if resStat then
                local syntax = exports['cr_core']:getServerSyntax(false, "success")    
                _, clientRows = getPerformanceStats("Lua timing")
                outputChatBox(syntax .. "Szerver terhelési nézet bekapcsolva!", 0, 255, 0, true)
                addEventHandler("onClientRender", root, resStatRender, true, "low")
                triggerServerEvent("getServerStat", localPlayer)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")    
                outputChatBox(syntax .. "Szerver terhelési nézet kikapcsolva!", 255, 0, 0, true)
                removeEventHandler("onClientRender", root, resStatRender)
                serverRows = {}, {}
                clientRows = {}, {}
                triggerServerEvent("destroyServerStat", localPlayer)
            end
        end
    end
)

function toFloor(num)
	return tonumber(string.sub(tostring(num), 0, -2)) or 0
end

addEvent("receiveServerStat", true)
addEventHandler("receiveServerStat", root, 
    function(stat1,stat2)
        _, clientRows = getPerformanceStats("Lua timing")
        _, serverRows = stat1,stat2

        table.sort(clientRows, function(a, b)
            return toFloor(a[2]) > toFloor(b[2])
        end)

        table.sort(serverRows, function(a, b)
            return toFloor(a[2]) > toFloor(b[2])
        end)
        
        avgC = 0
        for k,v in pairs(clientRows) do
            avgC = avgC + toFloor(v[2])
        end
        avgCM = math.floor(avgC)
        avgC = math.floor(avgC / #clientRows)
        
        avgS = 0
        for k,v in pairs(serverRows) do
            avgS = avgS + toFloor(v[2])
        end
        avgSM = math.floor(avgS)
        avgS = math.floor(avgS / #serverRows)
    end
)

local disabledResources = {}
function resStatRender()
    font = exports['cr_fonts']:getFont("Roboto", 10)
    
	local x = sx-300
	if #serverRows == 0 then
		x = sx-140
	end
	if #clientRows ~= 0 then
        local count = 0
        for i, row in ipairs(clientRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
                if usedCPU > 0.1 then
                    count = count + 1
                end
            end
        end
        
		local height = (15*count)+15
		local y = sy/2-height/2
		if #serverRows == 0 then
			dxDrawText("Client: "..avgC.."%, "..avgCM.."%",sx-74,y-19,sx-74,y-19,tocolor(0,0,0,255),1, font,"center")
			dxDrawText("Client: "..avgC.."%, "..avgCM.."%",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1, font,"center")
		else
			dxDrawText("Client: "..avgC.."%, "..avgCM.."%",sx-234,y-19,sx-234,y-19,tocolor(0,0,0,255),1, font,"center")
			dxDrawText("Client: "..avgC.."%, "..avgCM.."%",sx-235,y-20,sx-235,y-20,tocolor(255,255,255,255),1, font,"center")
		end
        local r,g,b,a = 255,255,255,255
        if avgC > MAX_CLIENT_CPU then
            r,g,b,a = 255,0,0,255
        elseif avgC > MED_CLIENT_CPU then
            r,g,b,a = 255,255,0,255
        end
		dxDrawRectangle(x-10,y,150,height,tocolor(r,g,b,150), tocolor(0,0,0,150))
		y = y + 5
		for i, row in ipairs(clientRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
                if usedCPU > 0.1 then
                    local r,g,b,a = 255,255,255,255
                    if usedCPU > MAX_CLIENT_CPU then
                        r,g,b,a = 255,0,0,255
                    elseif usedCPU > MED_CLIENT_CPU then
                        r,g,b,a = 255,255,0,255
                    end
                    local text = row[1]:sub(0,15)..": "..usedCPU.."%"
                    dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,font)
                    dxDrawText(text,x,y,150,15,tocolor(r,g,b,a),1,font)
                    y = y + 15
                end
			end
		end
	end
	
	if #serverRows ~= 0 then
        local count = 0
        for i, row in ipairs(serverRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
                if usedCPU > 0.01 then
                    count = count + 1
                end
            end
        end
        
		local x = sx-140
		local height = (15*count)
		local y = sy/2-height/2
		dxDrawText("Server: "..avgS.."%, "..avgSM.."%",sx-74,y-19,sx-74,y-19,tocolor(0,0,0,255),1, font,"center")
		dxDrawText("Server: "..avgS.."%, "..avgSM.."%",sx-75,y-20,sx-75,y-20,tocolor(255,255,255,255),1, font,"center")
        local r,g,b,a = 255,255,255,255
        if avgS > MAX_CLIENT_CPU then
            r,g,b,a = 255,0,0,255
        elseif avgS > MED_CLIENT_CPU then
            r,g,b,a = 255,255,0,255
        end
		dxDrawRectangle(x-10,y,150,height+15,tocolor(r,g,b,150),tocolor(0,0,0,150))
		y = y + 5
		for i, row in ipairs(serverRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
                if usedCPU > 0.01 then
                    local r,g,b,a = 255,255,255,255
                    if usedCPU > MAX_SERVER_CPU then
                        r,g,b,a = 255,0,0,255
                    elseif usedCPU > MED_SERVER_CPU then
                        r,g,b,a = 255,255,0,255
                    end
                    local text = row[1]:sub(0,15)..": "..usedCPU.."%"
                    dxDrawText(text,x+1,y+1,150,15,tocolor(0,0,0,255),1,font)
                    dxDrawText(text,x,y,150,15,tocolor(r,g,b,a),1,font)
                    y = y + 15
                end
			end
		end
	end
end