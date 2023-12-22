local red = exports['cr_core']:getServerColor("red", true)
function shadowedText(text,x,y,w,h,color,fontsize,font)
    exports['cr_core']:shadowedText(text,x,y,w,h,color,fontsize,font,"center","center")
end
function dxDrawnBorder(x, y, w, h, color2, color1)
    exports['cr_core']:roundedRectangle(x,y,w,h,color1,color2)
end
function linedRectangle(x,y,w,h, color, color2)
    return exports['cr_core']:linedRectangle(x,y,w,h, color, color2, 2)
end
local selected, gSelected = 0,0
local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
local font1 = exports['cr_fonts']:getFont("Roboto", 18)
local font2 = exports['cr_fonts']:getFont("Roboto", 15)
local font3 = exports['cr_fonts']:getFont("Roboto", 17)
local r,g,b = exports['cr_core']:getServerColor('red', false)
local syntaxSuccess = exports['cr_core']:getServerSyntax(false, "success")
local syntaxError = exports['cr_core']:getServerSyntax(false, "error")
addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
			font1 = exports['cr_fonts']:getFont("Roboto", 18)
			font2 = exports['cr_fonts']:getFont("Roboto", 15)
			font3 = exports['cr_fonts']:getFont("Roboto", 17)
		elseif sResourceName == "cr_core" then
			red = exports['cr_core']:getServerColor("red", true)
			r,g,b = exports['cr_core']:getServerColor('red', false)
			syntaxSuccess = exports['cr_core']:getServerSyntax(false, "success")
			syntaxError = exports['cr_core']:getServerSyntax(false, "error")
		end
	end
)
local sx,sy = guiGetScreenSize()
local screenSource = dxCreateScreenSource(sx, sy)

blackWhiteShader, blackWhiteTec = dxCreateShader("files/blackwhite.fx")

function black()
    if (blackWhiteShader) then
        dxUpdateScreenSource(screenSource)     
        dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
        dxDrawImage(0, 0, sx, sy, blackWhiteShader)
    end
end

local white = "#ffffff"
local fontsize = 1

local questions = {
    --[id] = {"Válasz?","válasz1","válasz2","válasz3",helyes válasz1-3},
    [1] = {"Mi az a Meta Gaming?","IC információ felhasználása OOC","OOC információ felhasználása IC","IC információ felhasználása PG",2},
    [2] = {"Mit teszel, ha bugot találsz?","Jelentem azonnal egy adminnak.","Szólok egy havernak.","Kihasználom.",1},
    [3] = {"Mit teszel, ha valaki szid téged IC?","Szólok egy adminnak.","Felteszem PK-ra.","IC kezelem a konfliktust.",3},
}

local question = false
local gSelected = 0
local panel = false
local sound = false
local sound2 = false
local jailTimer = false
local min = 0
local ped = nil
local jailed_panel = false
local counted_jailed = false
local jailed_size = 0
local col = nil

local fucker = {}
local jailed_players = {}

local size = {
    ["qBox2"] = {250, 30},
    ["qBox3"] = {160, 30},
}

local buttons = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false
}

function drawBorder(x,y,w,h,c)
    dxDrawRectangle(x - 2,y - 2,w + 4,2,c)
    dxDrawRectangle(x - 2,y + h,w + 4,2,c)
    dxDrawRectangle(x - 2,y,2,h,c)
    dxDrawRectangle(x + w,y,2,h,c)
end

function generate_question()
    selected = 0
    gSelected = 0
    local random = math.random(1,#questions)
    question = random
 	if not panel then
 		panel = true
    	addEventHandler("onClientRender",root,draw_questions)
   	end
end

function onStart()
    if getElementData(localPlayer,"loggedIn") and getElementData(localPlayer,"char >> ajail") then
        changeJail()
    end
end
addEventHandler("onClientResourceStart",resourceRoot,onStart)

function generate_fucker()
    selected = 0
    gSelected = 0
    fucker["1"] = math.random(math.random(1,50),math.random(51,99))
    fucker["2"] = math.random(math.random(1,50),math.random(51,99))
    fucker["3"] = math.random(math.random(1,50),math.random(51,99))
    fucker["4"] = math.random(math.random(1,50),math.random(51,99))
    fucker[1] = "Mennyi "..fucker["4"].."+"..fucker["1"].."x"..fucker["2"].."-"..fucker["3"].."?"

    fucker[2] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] + math.random(1,5)
    fucker[3] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] - math.random(1,9)
    fucker[4] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] + math.random(6,9)

    fucker[5] = math.random(1,3)
    fucker[(1+fucker[5])] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"]
    if not panel then
        panel = true
        addEventHandler("onClientRender",root,draw_fucker)
    end
end

function colLeave(theElement)
    if (theElement == localPlayer) and getElementData(localPlayer,"char >> ajail") then
        if source == col then
        	changeJail()
        end
    end
end
addEventHandler("onClientColShapeLeave", root, colLeave)

setTimer(
    function()
        if getElementData(localPlayer,"char >> ajail") then
            if not isElementWithinColShape(localPlayer, col) then
                changeJail()
            end
        end
    end, 1000, 0
)

function runTest()
    if gSelected ~= 0 and panel then
        panel = false
        removeEventHandler("onClientRender",root,draw_questions)
        if questions[question][5] == gSelected then -- ide kell típus szerinti + vagy - percre
            outputChatBox(syntaxSuccess.."Jó válasz, ezért 3 percet levonunk a büntetésedből!",0,0,0,true)
            local min1 = tonumber(getElementData(localPlayer,"char >> ajail >> time"))
            if min1 <= 3 then
                unJail(localPlayer)
            else
                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) - 3))
            end
        else
            outputChatBox(syntaxError.."Rossz válasz, ezért plusz 5 perc a büntetésed!",0,0,0,true)
            setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 5))
        end
        question = false
        gSelected = 0
    end
end

function runFucker()
    if gSelected ~= 0 and panel then
        panel = false
        removeEventHandler("onClientRender",root,draw_fucker)
        if fucker[5] == gSelected then
            outputChatBox(syntaxSuccess.."Jó válasz!",0,0,0,true)
        else
            outputChatBox(syntaxError.."Rossz válasz, ezért plusz 5 perc a büntetésed!",0,0,0,true)
            setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 5))
        end
        fucker = {}
        gSelected = 0
    end
end

local c_roll = 1

function draw_jailed_roll()
    local sy = sy + 40
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 300/2 - 100, 250 + jailed_size, 400, tocolor(0,0,0,140), tocolor(0,0,0,200))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 300/2 - 100, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) 
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 300/2 - 60, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 300/2 - 20, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 300/2 + 20, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 10, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 50, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 - 90, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 + 30, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 + 70, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    linedRectangle(sx/2 - (250 + jailed_size)/2, sy/2 + 110, 250 + jailed_size, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))
    dxDrawText("Karakter név",sx/2 - (250 + jailed_size)/2 + 5, sy/2 - 300/2 - 100 + 10,sx/2 - 600/2, sy/2 - 300/2 - 100 + 10,tocolor(255,255,255),1,"default-bold","left","center")
    dxDrawText("Indok",sx/2, sy/2 - 300/2 - 100 + 10,sx/2, sy/2 - 300/2 - 100 + 10,tocolor(255,255,255),1,"default-bold","center","center")
    dxDrawText("Idő",sx/2 + (250 + jailed_size)/2 - 5, sy/2 - 300/2 - 100 + 10,sx/2 + (250 + jailed_size)/2 - 5, sy/2 - 300/2 - 100 + 10,tocolor(255,255,255),1,"default-bold","right","center")
    for k,v in pairs(jailed_players) do
        if getElementData(v,"char >> ajail")and k >= c_roll and k <= (c_roll + 18) then
            k = k - c_roll + 1
            dxDrawText(getElementData(v,"char >> name"),sx/2 - (250 + jailed_size)/2 + 5, sy/2 - 300/2 - 100 + 10 + 20*k,sx/2 - (250 + jailed_size)/2 + 5, sy/2 - 300/2 - 100 + 10 + 20*k,tocolor(255,255,255),1,"default-bold","left","center")
            dxDrawText(getElementData(v,"char >> ajail >> reason").." - "..(getElementData(v,"char >> ajail >> admin") or ""),sx/2, sy/2 - 300/2 - 100 + 10 + 20*k,sx/2, sy/2 - 300/2 - 100 + 10 + 20*k,tocolor(255,255,255),1,"default-bold","center","center")
            dxDrawText(getElementData(v,"char >> ajail >> time").." perc",sx/2 + (250 + jailed_size)/2 - 5, sy/2 - 300/2 - 100 + 10 + 20*k ,sx/2 + (250 + jailed_size)/2 - 5, sy/2 - 300/2 - 100 + 10 + 20*k,tocolor(255,255,255),1,"default-bold","right","center")
        elseif not getElementData(v,"char >> ajail") then
            table.remove(jailed_players,k)
            if c_roll > 1 then c_roll = c_roll - 1 end
            if #jailed_players == 0 then
                c_roll = 1
                jailed_panel = false
                removeEventHandler("onClientRender",root,draw_jailed_roll)
            end
        end
    end
    dxDrawRectangle(sx/2 - 100/2,sy/2 + 160,100,20,tocolor(0,0,0,120))
    drawBorder(sx/2 - 100/2,sy/2 + 160,100,20,tocolor(20,20,20,250))
    dxDrawText(red.."Bezárás",sx/2,sy/2 + 160 + 20/2,sx/2,sy/2 + 160 + 20/2,isMouseInPosition(sx/2 - 100/2,sy/2 + 160,100,20) and tocolor(204, 51, 51,255) or tocolor(204, 51, 51,200),1,font,"center","center",false,false,false,true)
end

function draw_jailed()
    local sy = sy + 40
    local player = jailed_players[1]

    linedRectangle(sx/2 - 400/2, sy/2 - 20, 400, 40, tocolor(0,0,0,140), tocolor(0,0,0,200))
	linedRectangle(sx/2 - 400/2, sy/2, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120))

	dxDrawText("Karakter név",sx/2 - 400/2 + 5, sy/2 - 20 + 10,sx/2 - 400/2, sy/2 - 20 + 10,tocolor(255,255,255),1,"default-bold","left","center")
	dxDrawText("Indok",sx/2 - 400/2 + 200, sy/2 - 20 + 10,sx/2 - 400/2 + 200, sy/2 - 20 + 10,tocolor(255,255,255),1,"default-bold","center","center")
	--dxDrawText("Idő",sx/2 + 400/2 - 5, sy/2 - 20 + 10,sx/2 + 400/2 - 5, sy/2 - 20 + 10,tocolor(255,255,255),1,"default-bold","right","center") 
    dxDrawText("Idő",sx/2 - 400/2, sy/2 - 20 + 10,sx/2 + 400/2, sy/2 - 20 + 10,tocolor(255,255,255),1,"default-bold","right","center") 
	        
	dxDrawRectangle(sx/2 - 100/2,sy/2 + 30,100,20,tocolor(0,0,0,120))
	drawBorder(sx/2 - 100/2,sy/2 + 30,100,20,tocolor(20,20,20,250))
	dxDrawText(red.."Bezárás",sx/2,sy/2 + 30 + 20/2,sx/2,sy/2 + 30 + 20/2,isMouseInPosition(sx/2 - 100/2,sy/2 + 30,100,20) and tocolor(204, 51, 51,255) or tocolor(204, 51, 51,200),1,font,"center","center",false,false,false,true)
    if type(player) == "table" then
	    dxDrawText(player[6],sx/2 - 400/2 + 5, sy/2 + 10 ,sx/2 - 400/2, sy/2 + 10,tocolor(255,255,255),1,"default-bold","left","center")
	    dxDrawText(player[2].." - "..player[4],sx/2 - 400/2 + 200, sy/2 + 10,sx/2 - 400/2 + 200, sy/2 + 10,tocolor(255,255,255),1,"default-bold","center","center")
	    dxDrawText(player[5].." perc",sx/2 + 400/2 - 5, sy/2 + 10,sx/2 + 400/2 - 5, sy/2 + 10,tocolor(255,255,255),1,"default-bold","right","center") 
	else
	    if getElementData(player,"char >> ajail") then
	        dxDrawText(getElementData(player,"char >> name"),sx/2 - 400/2 + 5, sy/2 + 10 ,sx/2 - 400/2, sy/2 + 10,tocolor(255,255,255),1,"default-bold","left","center")
	        dxDrawText((getElementData(player,"char >> ajail >> reason") or "Nincs már adminjailba").." - "..(getElementData(player,"char >> ajail >> admin") or ""),sx/2 - 400/2 + 200, sy/2 + 10,sx/2 - 400/2 + 200, sy/2 + 10,tocolor(255,255,255),1,"default-bold","center","center")
	        dxDrawText((getElementData(player,"char >> ajail >> time") or "0").." perc",sx/2 + 400/2 - 5, sy/2 + 10,sx/2 + 400/2 - 5, sy/2 + 10,tocolor(255,255,255),1,"default-bold","right","center") 
		else
	        table.remove(jailed_players,1)
	        if c_roll > 1 then c_roll = c_roll - 1 end
	        c_roll = 1
	        jailed_panel = false
	        counted_jailed = false
	        removeEventHandler("onClientRender",root,draw_jailed) 
	    end
	end
end

function onKey(k,s)
    if jailed_panel then
        if k == "mouse_wheel_up" and s then
            if c_roll == 1 then return end
            c_roll = c_roll - 1
        elseif k == "mouse_wheel_down" and s then
            if c_roll == #jailed_players then return end
            if jailed_players > 19 then end
            c_roll = c_roll + 1
        elseif k == "backspace" then
            c_roll = 1
            jailed_panel = false
            counted_jailed = false
            removeEventHandler("onClientRender",root,draw_jailed)
            removeEventHandler("onClientRender",root,draw_jailed_roll)
        end
    end
end
addEventHandler("onClientKey",root,onKey)

function draw_timer()
    local minutesS = getElementData(localPlayer,"char >> ajail >> time")
    local reason = getElementData(localPlayer,"char >> ajail >> reason")
    local admin = getElementData(localPlayer,"char >> ajail >> admin")
    local x, y = sx - 20, sy - 70
    dxDrawText(minutesS.." perc",x,y+1,x,y+1,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS.." perc",x,y-1,x,y-1,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS.." perc",x-1,y,x-1,y,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS.." perc",x+1,y,x+1,y,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Jobb
    dxDrawText("#ff3333"..minutesS.."#ffffff perc", x, y, x, y, tocolor(255,255,255,255),1, font1, "right", "top",false,false,false,true)
    local x, y = sx - 20, sy - 40
    dxDrawText(reason.." ("..admin..")",x,y+1,x,y+1,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Fent
    dxDrawText(reason.." ("..admin..")",x,y-1,x,y-1,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Lent
    dxDrawText(reason.." ("..admin..")",x-1,y,x-1,y,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Bal
    dxDrawText(reason.." ("..admin..")",x+1,y,x+1,y,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Jobb
    dxDrawText(reason.." (#ff9933"..admin.."#ffffff)", x, y, x, y, tocolor(255,255,255,255),1, font2, "right", "top", false, false, false, true)
end

function draw_reason()
    local reason = getElementData(localPlayer,"char >> ajail >> reason")
    local time = getElementData(localPlayer,"char >> ajail >> time")
    local x, y = sx/2, sy/2
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..time.." percre!",x,y+1,x,y+1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Fent
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..time.." percre!",x,y-1,x,y-1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Lent
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..time.." percre!",x-1,y,x-1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Bal
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..time.." percre!",x+1,y,x+1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Jobb
    dxDrawText("#ff9933Adminjail#ffffff-ba kerültél #ff9933"..getElementData(localPlayer,"char >> ajail >> admin").." #ffffffáltal #ff3333"..time.." #ffffffpercre!", x, y, x, y, tocolor(255,255,255,255,255),1, font1, "center","center",false,false,false,true)
    local x, y = sx/2, sy/2 + 50
    dxDrawText("Indok: "..reason,x,y+1,x,y+1,tocolor(0,0,0,245),1, font3, "center", "center", false, false, false, true) -- Fent
    dxDrawText("Indok: "..reason,x,y-1,x,y-1,tocolor(0,0,0,245),1, font3, "center", "center", false, false, false, true) -- Lent
    dxDrawText("Indok: "..reason,x-1,y,x-1,y,tocolor(0,0,0,245),1, font3, "center", "center", false, false, false, true) -- Bal
    dxDrawText("Indok: "..reason,x+1,y,x+1,y,tocolor(0,0,0,245),1, font3, "center", "center", false, false, false, true) -- Jobb
    dxDrawText("Indok: #ff9933"..reason, x, y, x, y, tocolor(255,255,255,255),1, font3, "center","center",false,false,false,true)
end

function draw_questions()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    local w,h = 300, 300
    
    local biggest = dxGetTextWidth(questions[question][1], 1, font, true)
    if biggest <= dxGetTextWidth(questions[question][2], 1, font2, true) then
        biggest = dxGetTextWidth(questions[question][2], 1, font2, true)
    end
    if biggest <= dxGetTextWidth(questions[question][3], 1, font2, true) then
        biggest = dxGetTextWidth(questions[question][3], 1, font2, true)
    end
    if biggest <= dxGetTextWidth(questions[question][4], 1, font2, true) then
        biggest = dxGetTextWidth(questions[question][4], 1, font2, true)
    end
    local w = biggest + 40
    --local sx, sy = pose["x"], pose["y"]
    local x,y = sx/2 - w/2, sy/2 - h/2
    local color = exports['cr_core']:getServerColor(nil, true)

    local w2, h2 = w - 20, 40
    selected = nil
    
    dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
    local _y = y
    local y = y - 40
    dxDrawText(questions[question][1], x + 20, _y, x + w - 20, y + h/2 - 10, tocolor(255,255,255,255), 1, font, "center", "center", true, true)
    if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) or gSelected == 1 then
        selected = 1
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(questions[question][2], x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(questions[question][2], x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
    
    if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) or gSelected == 2 then
        selected = 2
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 40,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(questions[question][3], x + w/2 - w2/2,y + h/2 + 40, x + w/2 - w2/2 + w2,y + h/2 + 40 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 40,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(questions[question][3], x + w/2 - w2/2,y + h/2 + 40, x + w/2 - w2/2 + w2,y + h/2 + 40 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
    
    if isInSlot(x + w/2 - w2/2,y + h/2 + 90,w2,h2) or gSelected == 3 then
        selected = 3
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 90,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(questions[question][4], x + w/2 - w2/2,y + h/2 + 90, x + w/2 - w2/2 + w2,y + h/2 + 90 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 90,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(questions[question][4], x + w/2 - w2/2,y + h/2 + 90, x + w/2 - w2/2 + w2,y + h/2 + 90 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end

    if isInSlot(x + w/2 - w2/2,y + h/2 + 140,w2,h2) then
        selected = 4
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 140,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText("Tovább", x + w/2 - w2/2,y + h/2 + 140, x + w/2 - w2/2 + w2,y + h/2 + 140 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 140,w2,h2, tocolor(51, 255, 51,120))
        dxDrawText("Tovább", x + w/2 - w2/2,y + h/2 + 140, x + w/2 - w2/2 + w2,y + h/2 + 140 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
end

function draw_fucker()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    local w,h = 300, 300
    
    local biggest = dxGetTextWidth(fucker[1], 1, font, true)
    if biggest <= dxGetTextWidth(fucker[2], 1, font2, true) then
        biggest = dxGetTextWidth(fucker[2], 1, font2, true)
    end
    if biggest <= dxGetTextWidth(fucker[3], 1, font2, true) then
        biggest = dxGetTextWidth(fucker[3], 1, font2, true)
    end
    if biggest <= dxGetTextWidth(fucker[4], 1, font2, true) then
        biggest = dxGetTextWidth(fucker[4], 1, font2, true)
    end
    local w = biggest + 40
    --local sx, sy = pose["x"], pose["y"]
    local x,y = sx/2 - w/2, sy/2 - h/2
    local color = exports['cr_core']:getServerColor(nil, true)

    local w2, h2 = w - 20, 40
    selected = nil
    
    dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
    local _y = y
    local y = y - 40
    dxDrawText(fucker[1], x + 20, _y, x + w - 20, y + h/2 - 10, tocolor(255,255,255,255), 1, font, "center", "center", true, true)
    if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) or gSelected == 1 then
        selected = 1
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(fucker[2], x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(fucker[2], x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
    
    if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) or gSelected == 2 then
        selected = 2
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 40,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(fucker[3], x + w/2 - w2/2,y + h/2 + 40, x + w/2 - w2/2 + w2,y + h/2 + 40 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 40,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(fucker[3], x + w/2 - w2/2,y + h/2 + 40, x + w/2 - w2/2 + w2,y + h/2 + 40 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
    
    if isInSlot(x + w/2 - w2/2,y + h/2 + 90,w2,h2) or gSelected == 3 then
        selected = 3
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 90,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText(fucker[4], x + w/2 - w2/2,y + h/2 + 90, x + w/2 - w2/2 + w2,y + h/2 + 90 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 90,w2,h2, tocolor(51, 51, 51,120))
        dxDrawText(fucker[4], x + w/2 - w2/2,y + h/2 + 90, x + w/2 - w2/2 + w2,y + h/2 + 90 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end

    if isInSlot(x + w/2 - w2/2,y + h/2 + 140,w2,h2) then
        selected = 4
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 140,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText("Tovább", x + w/2 - w2/2,y + h/2 + 140, x + w/2 - w2/2 + w2,y + h/2 + 140 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + 140,w2,h2, tocolor(51, 255, 51,120))
        dxDrawText("Tovább", x + w/2 - w2/2,y + h/2 + 140, x + w/2 - w2/2 + w2,y + h/2 + 140 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
end

function onClick(b, s, aX, aY, wX, wY, wZ, e)
    if b == "left" and s == "down" and panel then
        if selected == 1 then
            if gSelected == 1 then
                gSelected = 0
            else
                gSelected = 1
            end
        elseif selected == 2 then
            if gSelected == 2 then
                gSelected = 0
            else
                gSelected = 2
            end
        elseif selected == 3 then
            if gSelected == 3 then
                gSelected = 0
            else
                gSelected = 3
            end
        elseif selected == 4 then
            if not question then
                runFucker()
            else
                runTest()
            end
        end
        selected = nil
    elseif b == "left" and s == "down" and jailed_panel then
        local sy = sy + 40
        if isMouseInPosition(sx/2 - 100/2,sy/2 + 160,100,20) then
            if not counted_jailed then
                removeEventHandler("onClientRender",root,draw_jailed_roll)
                c_roll = 1
                jailed_panel = false
            end
        elseif isMouseInPosition(sx/2 - 100/2,sy/2 + 30,100,20) then
            if counted_jailed then
                jailed_panel = false
                counted_jailed = false
                removeEventHandler("onClientRender",root,draw_jailed)
                c_roll = 1
            end
        end
    end
end
addEventHandler("onClientClick", root,onClick)

function changeJail(skip)
    local aj = getElementData(localPlayer,"char >> ajail")
    if aj then
        if isElement(localPlayer.vehicle) then
        end
        if skip then
        	if not sound then
            	sound = playSound("files/sadmusic.mp3",true)
            end
            setSoundVolume(sound, 0.5)
            addEventHandler("onClientRender",root,draw_timer)
            addEventHandler("onClientPreRender",root,black)
            setTimer(function()
                triggerServerEvent("preparePlayerToJail",localPlayer,localPlayer)
            end,1000,1)
        else
            setElementData(localPlayer, "hudVisible",false)
            showChat(false)
            fadeCamera(false)
            addEventHandler("onClientRender",root,draw_reason)
            sound2 = playSound("files/bebortonozve.mp3")
            setTimer(function ()
                fadeCamera(true)
                removeEventHandler("onClientRender",root,draw_reason)
                showChat(true)
                setElementData(localPlayer, "hudVisible",true)
                if getElementData(localPlayer,"char >> ajail") then
                    sound = playSound("files/sadmusic.mp3",true)
                    setSoundVolume(sound, 0.5)
                    addEventHandler("onClientRender",root,draw_timer)
                    addEventHandler("onClientPreRender",root,black)
                end
            end,6000,1)
            setTimer(function()
                triggerServerEvent("preparePlayerToJail",localPlayer,localPlayer)
            end,2000,1)
        end
        setTimer(function()
            local x,y,z = getElementPosition(localPlayer)
                if isElement(col) then destroyElement(col) end
            col = createColSphere(x,y,z,20)
        end,3000,1)
        if isTimer(jailTimer) then
            killTimer(jailTimer)
        end
        min = 0
        jailTimer = setTimer(
            function ()
                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) - 1))
                local time2 = tonumber(getElementData(localPlayer,"char >> ajail >> time"))
                if time2 <= 1 then
                    unJail(localPlayer)
                    if isTimer(jailTimer) then
                        killTimer(jailTimer)
                    end
                else
                    min = min + 1
                    if min == 3 then
                        if tonumber(getElementData(localPlayer,"char >> ajail >> type")) == 1 then
                            playSound("files/jailtext.mp3")
                            if not panel then
                                generate_question()
                            else
                                --generate_question()
                                removeEventHandler("onClientRender",root,draw_questions)
                                outputChatBox(syntaxError.."Nem válaszoltál a kérdésre! Ezért plusz 3 perc a büntetésed!",0,0,0,true)
                                panel = false
                                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 4))    
                            end
                        elseif tonumber(getElementData(localPlayer,"char >> ajail >> type")) == 2 then
                            playSound("files/jailtext.mp3")
                            if not panel then
                                generate_fucker()
                            else
                                --generate_fucker()
                                removeEventHandler("onClientRender",root,draw_fucker)
                                outputChatBox(syntaxError.."Nem válaszoltál a kérdésre! Ezért plusz 3 perc a büntetésed!",0,0,0,true)
                                panel = false
                                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 4))    
                            end
                         end
                        min = 0
                    end
                end
            end,60000,0
        )
    elseif not aj then
        --Output kiszabadultál a börtönből... blabla bal
        if isElement(sound) then
            destroyElement(sound)
            sound = false
        end
        if isTimer(jailTimer) then
            killTimer(jailTimer)
        end
        panel = false
        min = 0
        outputChatBox(syntaxSuccess.."Kiszabadultál a jailból! Máskor vigyázz magadra!",0,0,0,true)
        removeEventHandler("onClientPreRender",root,black)
        removeEventHandler("onClientRender",root,draw_fucker)
        removeEventHandler("onClientRender",root,draw_questions)
        removeEventHandler("onClientRender",root,draw_timer)
        triggerServerEvent("releasePlayer",localPlayer,localPlayer)
    end
end

addEventHandler("onClientElementDataChange",localPlayer,
    function (dname)
        if source == localPlayer then
            if dname == "char >> ajail" then
                --outputChatBox("eDataChange")
                changeJail()
            end
        end
    end
)

function setJail(target,time,reason,type,admin)
    setElementData(target,"char >> ajail >> time", time)
    setElementData(target,"char >> ajail >> admin",getElementData(admin,"admin >> name"))
    setElementData(target,"char >> ajail >> type",type)
    setElementData(target,"char >> ajail", true)
    setElementData(target,"char >> ajail >> aLevel", getElementData(admin,"admin >> level"))
    setElementData(target,"char >> ajail >> reason", tostring(reason))

    triggerServerEvent("saveLog",localPlayer,target)
    --output.....
end

function unJail(target)
    if isTimer(jailTimer) then
        killTimer(jailTimer)
    end
    setElementData(target,"char >> ajail >> admin",nil)
    setElementData(target,"char >> ajail >> type",0)
    setElementData(target,"char >> ajail", false)
    setElementData(target,"char >> ajail >> time", 0)
    setElementData(target,"char >> ajail >> aLevel", nil)
    setElementData(target,"char >> ajail >> reason", nil)
end

addEvent("returnOffjailed",true)
addEventHandler("returnOffjailed",root,
	function (table)
		jailed_panel = true
        counted_jailed = true
        jailed_players[1] = table
        addEventHandler("onClientRender",root,draw_jailed)	
	end
)

function jailed_sc(cmd,target)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
        jailed_players = {}
        if not jailed_panel then
            if target then
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    if getElementData(target,"char >> ajail") then
                        jailed_panel = true
                        counted_jailed = true
                        jailed_players[1] = target
                        addEventHandler("onClientRender",root,draw_jailed)
                    else
                        outputChatBox(syntaxError.."#ffffffNincs a játékos adminjailban!",255,255,255,true)
                    end
                else noOnline() end
                return
            end
            local null = false
            local max = 0
        	for k,v in pairs(getElementsByType("player")) do
        		if getElementData(v,"char >> ajail") then
        			local l = dxGetTextWidth (getElementData(v,"char >> ajail >> reason").." - "..getElementData(v,"char >> ajail >> admin"),1, "default")
        			if l > max then
        				max = l
        			end
                    jailed_panel = true
                    null = true
        			jailed_players[#jailed_players + 1] = v
        		end
        	end
            if not null then
                outputChatBox(syntaxError.."#ffffffNincs egy játékos sem adminjailban!",255,255,255,true)
            else
            	jailed_size = max
            	addEventHandler("onClientRender",root,draw_jailed_roll)
            end
        else
            c_roll = 1
            jailed_panel = false
            removeEventHandler("onClientRender",root,draw_jailed)
            removeEventHandler("onClientRender",root,draw_jailed_roll)
        end
    end
end
addCommandHandler("jailed",jailed_sc)

function unjail_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if not getElementData(target, "loggedIn") then outputChatBox(syntaxError..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                    
                if getElementData(target, "char >> ajail") then
                    if exports['cr_permission']:hasPermission(localPlayer, "forceajail") or tonumber(getElementData(target, "char >> ajail >> aLevel") or 2) <= getElementData(localPlayer, "admin >> level") then
                        unJail(target)
                        outputChatBox(syntaxSuccess.."Sikeresen kivetted az adminjailből. ("..getElementData(target,"char >> name")..")",0,0,0,true)
                    else
                        outputChatBox(syntaxError.."Nincs meg a szükséges adminszinted a kivételhez!",0,0,0,true)
                    end
                else
                    outputChatBox(syntaxError..getElementData(target,"char >> name").." nincs adminjailben.",0,0,0,true)
                    --nincs jailba
                end
            else noOnline() end
        end
    end
end
addCommandHandler("unjail", unjail_sc)

function ajail_sc(cmd, target, time,type,...)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
    	if not (target) or not (time) or not (...) or not(type) then
    		local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos] [Idő] [Típus(0-sima,1-kérdegetős,2-szívatós)] [Indok]",0,0,0,true)
    	else
    		local target = exports['cr_core']:findPlayer(localPlayer, target)
    		if target then
    			if not getElementData(target, "loggedIn") then outputChatBox(syntaxError..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local time = tonumber(time)
                if time > 0 then
                	if not getElementData(target, "char >> ajail")then
                        local tALevel = target:getData("admin >> level")
                        local p = localPlayer
                        local pALevel = p:getData("admin >> level") 

                        if tALevel >= pALevel then
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            outputChatBox(syntax .. "Magadnál csak kisebb admint jailezhetsz!", 255,255,255,true)
                            --outputChatBox(syntax .. orange..aName..white.." ki akart bannolni!", target, 255,255,255,true)
                            return
                        end
                        local reason = table.concat({...}, " ")
                        triggerServerEvent("vehCheck", target, target)
                        setJail(target,math.floor(time),reason,type,localPlayer)
                        outputChatBox(syntaxSuccess.."Sikeresen berakva adminjailbe. ("..getElementData(target,"char >> name")..")",0,0,0,true)
                        local maxHasFix = getMaxJailCount() or 0
                        local thePlayer = localPlayer
                        local hasFIX = getElementData(thePlayer, "jail >> using") or 0
                        local hasFIX = hasFIX + 1
                        setElementData(thePlayer, "jail >> using", hasFIX)
                        if hasFIX > maxHasFix then
                            local green = exports['cr_core']:getServerColor("orange", true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            --local vehicleName = getVehicleName(target)
                            outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Jail limitet! (Limit: "..green..maxHasFix..white..") (Jailek száma: "..green..hasFIX..white..")", 255,255,255,true)
                        end
                        local adminName = getAdminName(localPlayer, true)
                        local jatekosName = getAdminName(target)
                        local jailTime = math.floor(time)
                        triggerServerEvent("showAdminBox",localPlayer, "#ff751a"..adminName.."#ffffff bebörtönözte#ff751a "..jatekosName.."#ffffff játékost\n#ff751aIndok:#ffffff "..reason.."\n#ff751aIdő:#ffffff "..jailTime .. " perc", "info", {adminName.." bebörtönözte "..jatekosName .. " játékost", "Indok: "..reason, "Idő: "..jailTime.." perc"})
                        
                	else
                	   outputChatBox(syntaxError..white.."A játékos már adminjailben van!",255,255,255,true)
                	end
            	else
            		outputChatBox(syntaxError..white.."Az idő nem lehet 0 vagy kevesebb!",255,255,255,true)
            	end
    		else noOnline() end
    	end
    end
end
addCommandHandler("ajail", ajail_sc)

function offjail_sc(cmd, id, time, type,...)
    if exports['cr_permission']:hasPermission(localPlayer, "offjail") then
        if not (id) or not (time) or not (...) or not(type) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Karakter Név] [Idő] [Típus(0-sima,1-kérdegetős,2-szívatós)] [Indok]",0,0,0,true)
        else
            for k,v in pairs(getElementsByType("player")) do
                if getElementData(v,"acc >> id") == tonumber(id) then
                    outputChatBox(syntaxError..white.."A játékos online! Használd a /ajail-t!",255,255,255,true)
                    return 
                end
            end
            local time = tonumber(time)
            if time > 0 then
                local reason = table.concat({...}, " ")
                --local id = tonumber(id)
                local data = {true,reason,type,getAdminName(localPlayer, true),math.floor(time), localPlayer:getData("admin >> level")}
                local data = toJSON(data)
                local perm = false
	        	if exports['cr_permission']:hasPermission(localPlayer, "forceajail") then
	        		perm = true
	        	end
                triggerServerEvent("offJail",localPlayer,localPlayer,id,data,"jail")
                local maxHasFix = getMaxJailCount() or 0
                local thePlayer = localPlayer
                local hasFIX = getElementData(thePlayer, "jail >> using") or 0
                local hasFIX = hasFIX + 1
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = tostring(id):gsub("_", " ")
                local jailTime = math.floor(time)
                --triggerServerEvent("showAdminBox",localPlayer,"#ff751a"..adminName.."#ffffff bebörtönözte#ff751a "..jatekosName.."#ffffff játékost #ff751a[Offline]#ffffff\n#ff751aIndok:#ffffff "..reason.."\n#ff751aIdő:#ffffff "..jailTime.." perc", "info", {adminName.." bebörtönözte "..jatekosName .. " játékost [Offline]", "Indok: "..reason, "Idő: "..jailTime .. " perc"})
            else
                outputChatBox(syntaxError..white.."Az idő nem lehet 0 vagy kevesebb!",255,255,255,true)
            end
        end
    end
end
addCommandHandler("offjail", offjail_sc)
addCommandHandler("ojail", offjail_sc)

function offjailed_sc(cmd, id)
    if exports['cr_permission']:hasPermission(localPlayer, "offjail") then
        if not (id) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Account ID]",0,0,0,true)
        else
            triggerServerEvent("offJailed",localPlayer,id,localPlayer)
        end
    end
end
addCommandHandler("offjailed", offjailed_sc)
addCommandHandler("ojailed", offjailed_sc)

function offunjail_sc(cmd, id)
    if exports['cr_permission']:hasPermission(localPlayer, "offjail") then
        if not (id)  then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos Név _-al]",0,0,0,true)
        else
            for k,v in pairs(getElementsByType("player")) do
                if getElementData(v,"acc >> id") == tonumber(id) then
                    outputChatBox(syntaxError..white.."A játékos online! Használd a /unjail-t!",255,255,255,true)
                    return 
                end
            end
            local data = {true,"Míg nem voltál fenn, ki lettél véve a jailból!","0","",1, 0}
            local data = toJSON(data)
            local id = tostring(id)
            triggerServerEvent("offJail",localPlayer,localPlayer,id,data, "unjail")
        end
    end 
end
addCommandHandler("offunjail", offunjail_sc)
addCommandHandler("ounjail", offunjail_sc)

function isMouseInPosition( x, y, width, height )
    if ( not isCursorShowing( ) ) then
        return false
    end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
        return true
    else
        return false
    end
end

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