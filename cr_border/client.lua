--Képernyő
local x,y = guiGetScreenSize()
local sx,sy = x/2, y/2
local pos = {
	["x"] = sx,
	["y"] = sy
}
local pose = {
	["x"] = sx,
	["y"] = sy
}
local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
local orange = exports['cr_core']:getServerColor("orange", true)
local green = exports['cr_core']:getServerColor("green", true)
local red = exports['cr_core']:getServerColor("red", true)

addEventHandler("onClientResourceStart", root,
    function(startedRes)
    	local startedResName = getResourceName(startedRes)
        if startedResName == "cr_core" then
            orange = exports['cr_core']:getServerColor("orange", true)
            green = exports['cr_core']:getServerColor("green", true)
            red = exports['cr_core']:getServerColor("red", true)
       	elseif startedResName == "cr_fonts" then
       		font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
        end
	end
)

--Panelok
local panel_state = {
	["fizet"] = false,
	["kezel"] = false
}

--Változók
local sounds = 1
local choose = false
local key
local realMoving = false

--Tömbök
local cols = {
    --{group,x,y,z,w,d,h,rot}
    {1,31.00263, -1540.60095,4.3,7,8,4},
    {2,60.30491, -1529.83484,4.1,7,8,4},
    {3,-9.61811, -1370.02075, 9.8,6,6,4},
    {4,-23.40753, -1338.54517, 9.9,6,6,4},
    {5,-75.97370,-896.90093,15,6,5.3,4},
    {6,-90.05153,-912.54999,16.7,6,5.3,4},
    {7,-962.82599, -326.32520, 35.19247,6,6,4},
    {8,-972.50708, -339.72641, 35.28793,5.5,6,4}
}

--Üres tömbök
local placed_collisions = {}

--Forciklusok
for k,v in pairs(cols) do
    placed_collisions[v[1]] = createColCuboid(v[2],v[3],v[4],v[5],v[6],v[7])
end

--mozgatás mentése
function savePos()
	local x,y = pos["x"],pos["y"]
	local ex,ey = pose["x"],pose["y"]
	saveXML("x",x)
	saveXML("y",y)
	saveXML("ex",ex)
	saveXML("ey",ey)
end

--Hang funkciók
function saveXML(parameter, value)
	local xmlFileName = "settings.xml"
	local xmlFile = xmlLoadFile ( xmlFileName )
	if not (xmlFile) then
		xmlFile = xmlCreateFile( xmlFileName, "sound" )
	end
	
	local xmlNode = xmlFindChild (xmlFile, parameter, 0)
	if not (xmlNode) then
		xmlNode = xmlCreateChild(xmlFile, parameter)
	end
	xmlNodeSetValue (xmlNode,value)
	xmlSaveFile(xmlFile)
	xmlUnloadFile(xmlFile)
end 

function toggleSounds()
    if sounds == 0 then
        sounds = 1
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen kikapcsoltad a határhangot!", 255,255,255,true)
    else
        sounds = 0
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax.. "Sikeresen bekapcsoltad a határhangot!", 255,255,255,true)
    end
    saveXML("sound",sounds)
end
addCommandHandler("togbordersound",toggleSounds)
addCommandHandler("toghatarhang",toggleSounds)
addCommandHandler("toghatarsound",toggleSounds)
addCommandHandler("togborderhang",toggleSounds)

function loadSettings()
    local xmlfile = xmlLoadFile("settings.xml")
	if xmlfile then
		local as = xmlFindChild(xmlfile, "sound", 0)
		local ax = xmlFindChild(xmlfile, "x", 0)
		local ay = xmlFindChild(xmlfile, "y", 0)
		local fax = xmlFindChild(xmlfile, "ex", 0)
		local fay = xmlFindChild(xmlfile, "ey", 0)
		
		if as then
			local s = xmlNodeGetValue(as)
			if s then
				sounds = s
				pos["x"] = x
				pos["y"] = y
				pose["x"] = ex
				pose["y"] = ey
			end
		end
		if ax and ay then
			local x = xmlNodeGetValue(ax)
			local y = xmlNodeGetValue(ay)
			if x and y then
				pos["x"] = x
				pos["y"] = y
			end
		end
		if fax and fay then
			local ex = xmlNodeGetValue(fax)
			local ey = xmlNodeGetValue(fay)
			if x and y then
				pose["x"] = ex
				pose["y"] = ey
			end
		end
	end
end
loadSettings()

addEvent("playSound",true)
addEventHandler("playSound",root,
	function (element)
	    if tonumber(sounds) == 0 then return end
	    local x,y,z = getElementPosition(element)
	    sound = playSound3D("sound.mp3",x,y,z,false)
	    setSoundMaxDistance(sound, 40)
	end
)

hatar_manual = {}

local white = "#ffffff"
--Renderek
function panelRender()
    --dxDrawRectangle(pos["x"] - 240/2,pos["y"] - 60/2 ,240,25,tocolor(0,0,0,120))

    --drawBorder(pos["x"] - 240/2,pos["y"] - 60/2 ,240,25,tocolor(20,20,20,250))
    
    --[[
        font = exports['cr_core']:getFont("Yantramanav-Regular", 12)
        orange = exports['cr_core']:getServerColor("orange", true)
        green = exports['cr_core']:getServerColor("green", true)
        red = exports['cr_core']:getServerColor("red", true)
    ]]
    if not orange then
        orange = exports['cr_core']:getServerColor("orange", true)
    end
    if not green then
        green = exports['cr_core']:getServerColor("green", true)
    end
    if not red then
        red = exports['cr_core']:getServerColor("red", true)
    end
    
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    local w,h = 300, 200
    local sx, sy = pos["x"], pos["y"]
    local x,y = sx - w/2, sy - h/2
--    dxDrawRectangle(pos["x"] - 300/2, pos["y"] - 200/2, 300, 90, tocolor(0,0,0,150))
    local color = exports['cr_core']:getServerColor(nil, true)

    local w2, h2 = 280, 40
    selected = nil
    
    if not hatar_manual[key] then
        dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
        dxDrawText("A határon való átkeléshez \n"..color..tonumber(25)..white.."$-t kell fizess!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
        if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
            selected = 1
            dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
            dxDrawText("Befizetés", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
        else
            dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
            dxDrawText("Befizetés", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
        end

        if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
            selected = 2
            dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
            dxDrawText("Bezárás", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
        else
            dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
            dxDrawText("Bezárás", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
        end
    else
        local w,h = 300, 90
        local x,y = sx - w/2, sy - h/2
        dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
        dxDrawText("A határ jelenleg zárva van!", x, y, x + w, y + h, tocolor(255,51,51,255), 1, font, "center", "center", _, _, _, true)
    end
    
    --[[
    dxDrawText("A határátépés díja: "..orange.."25 #ffffff$",pos["x"],pos["y"]-60/2 + 25/2,pos["x"],pos["y"]-60/2 + 25/2,tocolor(255,255,255,255),1,font,"center","center",false,false,false,true)
    if not hatar_manual[key] or hatar_manual[key] == nil then
	    dxDrawRectangle(pos["x"] - 250/2 + 5,pos["y"] + 5,115,25,tocolor(0,0,0,120))
	    dxDrawRectangle(pos["x"] + 5,pos["y"] + 5,115,25,tocolor(0,0,0,120))

	    drawBorder(pos["x"] - 250/2 + 5,pos["y"] + 5,115,25,tocolor(20,20,20,250))
	    drawBorder(pos["x"] + 5,pos["y"] + 5,115,25,tocolor(20,20,20,250))

	    dxDrawText(green.."Elfogad",pos["x"] - 250/2 + 5 + 115/2,pos["y"] + 5 + 25/2,pos["x"] - 250/2 + 5 + 115/2,pos["y"] + 5 + 25/2,isMouseInPosition(pos["x"] - 250/2 + 5,pos["y"] + 5,115,25) and tocolor(0, 153, 51,255) or tocolor(0, 153, 51,200),1,font,"center","center",false,false,false,true)
	    dxDrawText(red.."Mégse",pos["x"] + 5 + 115/2,pos["y"] + 5 + 25/2,pos["x"] + 5 + 115/2,pos["y"] + 5 + 25/2,isMouseInPosition(pos["x"] + 5,pos["y"] + 5,115,25) and tocolor(204, 51, 51,255) or tocolor(204, 51, 51,200),1,font,"center","center",false,false,false,true)
	else
		dxDrawRectangle(pos["x"] - 250/2 + 5,pos["y"] + 5,240,25,tocolor(0,0,0,120))

	    drawBorder(pos["x"] - 250/2 + 5,pos["y"] + 5,240,25,tocolor(20,20,20,250))

	    dxDrawText(red.."A határ jelenleg zárva van",pos["x"] - 250/2 + 5 + 240/2,pos["y"] + 5 + 25/2,pos["x"] - 250/2 + 5 + 240/2,pos["y"] + 5 + 25/2,isMouseInPosition(pos["x"] - 250/2 + 5,pos["y"] + 5,115,25) and tocolor(0, 153, 51,255) or tocolor(0, 153, 51,200),1,font,"center","center",false,false,false,true)  
	end]]
end

function manualRender()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    local w,h = 300, 200
    local sx, sy = pose["x"], pose["y"]
    local x,y = sx - w/2, sy - h/2
    local color = exports['cr_core']:getServerColor(nil, true)

    local w2, h2 = 280, 40
    selected = nil
    
    dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
    dxDrawText("Határkezelés", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
    if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
        selected = 1
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText("Nyit", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
        dxDrawText("Nyit", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end

    if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
        selected = 2
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
        dxDrawText("Zár", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
        dxDrawText("Zár", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
end

function drawBorder(x,y,w,h,c)
	dxDrawRectangle(x - 2,y - 2,w + 4,2,c)
	dxDrawRectangle(x - 2,y + h,w + 4,2,c)
	dxDrawRectangle(x - 2,y,2,h,c)
	dxDrawRectangle(x + w,y,2,h,c)
end

--Egyéb funkciók
addEvent("sendManuals",true)
addEventHandler("sendManuals",root,
	function (table)
		hatar_manual = table
	end
)

function resetPanel()
	pos["x"],pos["y"] = x/2,y/2
	savePos()
end
addCommandHandler("resetborderpanel",resetPanel)

function money(player)
	exports['cr_core']:takeMoney(player, 25,false)
end
addEvent("money",true)
addEventHandler("money",root,money)

addEvent("writeInChat",true)
addEventHandler("writeInChat",root,
	function (type,text,sectype)
		if type == "me" then
			exports['cr_chat']:createMessage(localPlayer, text, 1)
		elseif type == "outputChatBox" then
			local syntax = exports['cr_core']:getServerSyntax(false,sectype)
            outputChatBox(syntax..text, 255,255,255,true)
        elseif type == "faction" then
            if exports['cr_faction']:isPlayerInFaction(localPlayer, 1) then
                for k,v in pairs(text) do
                    outputChatBox(v, 255,255,255,true)
                end
            end    
		end
	end
)

function closePay()
	removeEventHandler("onClientRender",root,panelRender)
    panel_state["fizet"] = false
end

function hatar(back,lo)
    --outputChatBox(key)
    --if key and cols[key] and cols[key][1] then
       -- outputChatBox(cols[key][1])
        if exports['cr_faction']:isPlayerInFaction(localPlayer, 1) then
            if back == 1 then
                if lo == false then
                    removeEventHandler("onClientRender",root,manualRender)
                    panel_state["kezel"] = false
                    return
                end
                panel_state["kezel"] = not panel_state["kezel"]
                if panel_state["kezel"] then
                    addEventHandler("onClientRender",root,manualRender)
                elseif not panel_state["kezel"] then
                    removeEventHandler("onClientRender",root,manualRender)
                end
            else
                triggerServerEvent("checkManualEnable",localPlayer,key)
            end
        end
    --end
end
addEvent("toggleHatar",true)
addEventHandler("toggleHatar",root,hatar)

function selecting()
    --outputChatBox(key)
    if key and cols[key] and cols[key][1] then
        --outputChatBox(cols[key][1])
        if exports['cr_faction']:isPlayerInFaction(localPlayer, 1) then
            choose = not choose
            if choose then
                local syntax = exports['cr_core']:getServerSyntax(false,"warning")
                outputChatBox(syntax.."Határválasztás bekapcsolva! Kattints egy határcölöpre!", 255,255,255,true)
            else
                local syntax = exports['cr_core']:getServerSyntax(false,"warning")
                outputChatBox(syntax.."Határválasztás bekapcsolva! Kattints egy határcölöpre!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setborderstate",selecting)
addCommandHandler("sethatarmanual",selecting)
addCommandHandler("setbordermanual",selecting)
addCommandHandler("toghatarmanual",selecting)
addCommandHandler("togbordermanual",selecting)

function onClick(mouse,press,ax,ay,wx,wy,wz,element)
	if mouse == "left" and press == "down" then
		if panel_state["fizet"] then
			if selected == 1 then
				if exports['cr_core']:hasMoney(localPlayer, 25, false)then
	            	triggerServerEvent("moveSync",localPlayer,key,true,true)
	            	closePay()
	            else
	            	local syntax = exports['cr_core']:getServerSyntax(false,"error")
            		--outputChatBox(syntax.."Nincs elég pénzed ahhoz, hogy átlépj a határon!", 255,255,255,true)
                    exports['cr_infobox']:addBox("error", "Nincs elég pénzed ahhoz, hogy átlépj a határon!")
	            	closePay()
	            end
	        elseif selected == 2 then
	            closePay()
	        end
            selected = nil
		elseif panel_state["kezel"] then
			if selected == 1 then
            	triggerServerEvent("moveSync",localPlayer,key,true,false)
	        elseif selected == 2 then
	            triggerServerEvent("moveSync",localPlayer,key,false,false,localPlayer)
	        end
            selected = nil
	    elseif choose then
            --factioncheck
            --if key and cols[key] and cols[key][1] then
            if exports['cr_faction']:isPlayerInFaction(localPlayer, 1) then
                if isElement(element) then
                    triggerServerEvent("toggleManual",localPlayer,element)
                    choose = false
                end
            end
            --end
		end
	end
end
addEventHandler("onClientClick",root,onClick)

addEventHandler("onClientVehicleExit",root,
	function (player,dim)
		if localPlayer == player and panel_state["fizet"] then
			closePay()
		end
	end
)

addEventHandler("onClientKey",root,
	function(bill,press)
		if bill == "enter" and panel_state["fizet"] and not isChatBoxInputActive() then
			cancelEvent()
			if exports['cr_core']:hasMoney(localPlayer, 25, false)then
	            triggerServerEvent("moveSync",localPlayer,key,true,true)
	            closePay()
	        else
	            --local syntax = exports['cr_core']:getServerSyntax(false,"error")
            	--outputChatBox(syntax.."Nincs elég pénzed ahhoz, hogy átlépj a határon!", 255,255,255,true)
                exports['cr_infobox']:addBox("error", "Nincs elég pénzed ahhoz, hogy átlépj a határon!")
	            closePay()
	        end
		elseif bill == "backspace" and panel_state["fizet"] and not isChatBoxInputActive() then
			closePay()
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setTimer(
            function()
                for k,v in pairs(getElementsByType("object")) do
                    if v.model == 1214 then
                        setObjectBreakable(v, false)
                    end
                end
            end, 1000, 1
        )
    end
)

--Colshape funckiók
function onClientColShapeHit( theElement, matchingDimension )
    --outputChatBox("asd")
    if (theElement == localPlayer) and matchingDimension and source then
        --outputChatBox("asd2")
        for k,v in pairs(placed_collisions) do
            --outputChatBox("asd3")
            if source == v and getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer)==0 and not panel_state["fizet"] then
                --outputChatBox("asd4")
                key = k
                --outputChatBox(key)
                panel_state["fizet"] = true
                addEventHandler("onClientRender",root,panelRender)
                triggerServerEvent("refreshManual",localPlayer)
                break
            elseif source == v and not getPedOccupiedVehicle(localPlayer) then
                --outputChatBox("asd5")
                key = k
                --outputChatBox(key)
                addCommandHandler("hatarkezel",hatar)
                addCommandHandler("borderstate",hatar)
                triggerServerEvent("refreshManual",localPlayer)
                break
            end
        end
    end
end
addEventHandler("onClientColShapeHit", root, onClientColShapeHit)

function leave( theElement, matchingDimension )
    if theElement == localPlayer and panel_state["fizet"] then
        removeEventHandler("onClientRender",root,panelRender)
        panel_state["fizet"] = false
    elseif theElement == localPlayer and panel_state["kezel"] then
        removeEventHandler("onClientRender",root,manualRender)
    	panel_state["kezel"] = false
    end
    removeCommandHandler("hatarkezel",hatar)
    removeCommandHandler("borderstate",hatar)
end
addEventHandler("onClientColShapeLeave", root, leave)

--Kiegészítő funkciók
       
local screenSize = {guiGetScreenSize()}
local cursorState = isCursorShowing()
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2]
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
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

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
        if realMoving and panel_state["fizet"] then
            pos["x"] = x - dX
            pos["y"] = y - dY
        end
        if realMoving and panel_state["kezel"] then
        	pose["x"] = x - dX
            pose["y"] = y - dY
        end
    end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" and panel_state["fizet"] then
            if isInSlot(pos["x"] - 300/2, pos["y"] - 200/2, 300, 90) then -- Felső rész
                local cx, cy = exports['cr_core']:getCursorPosition()
                realMoving = true
                local x, y = pos["x"], pos["y"]
                dX, dY = cx - x, cy - y
            end
        elseif b == "left" and s == "up" and panel_state["fizet"] then
            if realMoving then
                realMoving = false
                savePos()
            end
        end
        if b == "left" and s == "down" and panel_state["kezel"] then
        	if isInSlot(pose["x"] - 300/2, pose["y"] - 200/2, 300, 90) then -- Felső rész
                local cx, cy = exports['cr_core']:getCursorPosition()
                realMoving = true
                local x, y = pose["x"], pose["y"]
                dX, dY = cx - x, cy - y
            end
        elseif b == "left" and s == "up" and panel_state["kezel"] then
        	if realMoving then
                realMoving = false
                savePos()
            end
        end
    end
)