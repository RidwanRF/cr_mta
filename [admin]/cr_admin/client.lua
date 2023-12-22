sx, sy = guiGetScreenSize();

function setElementData(element, dataName, value)
    exports['cr_core']:setElementData(element, dataName, value)
end

function removeElementData(element, dataName)
    exports['cr_core']:removeElementData(element, dataName)
end

addEventHandler("onClientResourceStart", root, function(sResource)
    local sResourceName = getResourceName(sResource)

    if getElementData(localPlayer, "admin >> level") or 0 > 7 then
        --outputChatBox("#cc0000[STAYMTA] #00cc00" .. sResourceName .. " #ffffffresource elindítva.", 255, 255, 255, true)
    end
end)

addEventHandler("onClientResourceStop", root, function(sResource)
    local sResourceName = getResourceName(sResource)

    if getElementData(localPlayer, "admin >> level") or 0 > 7 then
        --outputChatBox("#cc0000[STAYMTA] #00cc00" .. sResourceName .. " #ffffffresource leállítva.", 255, 255, 255, true)
    end
end)

local glue_vehs = {
	[508] = true
}

local white = "#ffffff"

function aTitle(player)
    local title = getAdminTitle(localPlayer)

    if title == "Ideiglenes Adminsegéd" then
        title = "IDG.Adminsegéd"
    elseif title == "Admin 1" then
        title = "Admin[1]"
    elseif title == "Admin 2" then
        title = "Admin[2]"
    elseif title == "Admin 3" then
        title = "Admin[3]"
    elseif title == "Admin 4" then
        title = "Admin[4]"
    elseif title == "Admin 5" then
        title = "Admin[5]"
    end

    return title
end

-- /togalog
function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON({["disabled"] = false}))
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

function noOnline()
    local syntax = exports['cr_core']:getServerSyntax(false, "error")
    outputChatBox(syntax..white.."Nincs ilyen játékos!",0,0,0,true)
end

local value = {}
value["disabled"] = false

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        value = jsonGET("files/@alog.json")
        setElementData(localPlayer, "admin >> alogDisabled", value["disabled"])
    end
)

addEventHandler("onClientResourceStop", resourceRoot, 
    function()
        jsonSAVE("files/@alog.json", value)
    end
)

addEventHandler("onClientVehicleStartEnter", getRootElement(),
    function(thePlayer, seat)
        if thePlayer == getLocalPlayer() then
            if getElementData(localPlayer, "freeze") then
                cancelEvent()
            end
        end
    end
)

function pressedKey(button, press)
    if not (button == "b") then
    	if not (button == "t") then
	        if getElementData(localPlayer, "freeze") then
	            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
	            --outputChatBox(syntax.."#ffffffLefagyasztva semmit nem csinálhatsz!",255,255,255,true)
	            cancelEvent()
	        end
	    end
    end
end
addEventHandler("onClientKey", root, pressedKey)


function togAlog(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "togalog") then
        value["disabled"] = not value["disabled"]
        setElementData(localPlayer, "admin >> alogDisabled", value["disabled"])
        if not value["disabled"] then
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax.. "Sikeresen bekapcsoltad az admin logokat!", 255,255,255,true)
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax.. "Sikeresen kikapcsoltad az admin logokat!", 255,255,255,true)
        end
    end
end
addCommandHandler("togalog", togAlog)

-- /setadminlevel, setalevel

function setAdminLevel(cmd, target, level)
    if exports['cr_permission']:hasPermission(localPlayer, "setadminlevel") then
        if not level or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [szint]", 255,255,255,true)
            return
        elseif tonumber(level) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek egy számnak kell lennie!", 255,255,255,true)
            return    
        elseif tonumber(level) > 10 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek kisebbnek kell lennie 10-nél!", 255,255,255,true)
            return
        elseif tonumber(level) < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek nagyobbnak kell lennie 0-nál!", 255,255,255,true)
            return    
        end
        
        level = tonumber(math.floor(level))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local newLevel = level + 2
                if newLevel == 2 then
                    newLevel = 0
                end
                local oValue = getElementData(target, "admin >> level")
                if target == localPlayer then
                    if newLevel > oValue and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Magadnak nem állíthasz nagyobb adminszintet!", 255,255,255,true)
                        return
                    end
                else
                    local adminlevel = getElementData(localPlayer, "admin >> level") - 1
                    local adminlevel2 = getElementData(target, "admin >> level")
                    local adminlevel3 = getElementData(localPlayer, "admin >> level")
                    if newLevel > adminlevel and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Másnak nem állíthasz nagyobb adminszintet a FőAdminnál!", 255,255,255,true)
                        return
                    elseif adminlevel2 >= adminlevel3 and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Nagyobb admin szintjét nem változtathatod!", 255,255,255,true)
                        return    
                    end
                end
                if newLevel == 0 then
                    setElementData(target, "admin >> duty", false)
                end
                setElementData(target, "admin >> level", newLevel)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target, true)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                local oValue = oValue - 2
                if oValue < 0 then oValue = 0 end
                local newLevel = newLevel - 2
                if newLevel < 0 then newLevel = 0 end
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info") ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminisztrátori szintjét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..newLevel.."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setadminlevel", setAdminLevel)
addCommandHandler("setalevel", setAdminLevel)

-- /setanick, setadminname

function setAdminNick(cmd, target, nick)
    if exports['cr_permission']:hasPermission(localPlayer, "setadminnick") then
        if not nick or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [Nick]", 255,255,255,true)
            return
        end
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local adminlevel = getElementData(localPlayer, "admin >> level")
                local adminlevel2 = getElementData(target, "admin >> level")
                if adminlevel2 > adminlevel then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "Nagyobb adminnak nem állíthatsz adminnevet!", 255,255,255,true)
                    return 
                end
                setElementData(target, "admin >> name", nick)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target, true)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info") ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminisztrátori nevét "..hexColor..nick.."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setanick", setAdminNick)
addCommandHandler("setadminnick", setAdminNick)

-- /sethelperlevel, sethlevel, setaslevel

function setHelperLevel(cmd, target, level)
    if exports['cr_permission']:hasPermission(localPlayer, "sethelperlevel") then
        if not level or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [szint ([1] = Ideiglenes, [2] = Örök)]", 255,255,255,true)
            return
        elseif tonumber(level) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek egy számnak kell lennie!", 255,255,255,true)
            return    
        elseif tonumber(level) == 2 then
            local adminlevel = getElementData(localPlayer, "admin >> level")
            if adminlevel < 8 and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Te nem adhatsz örök adminsegédet!", 255,255,255,true)
                return
            end
        elseif tonumber(level) > 2 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek kisebbnek kell lennie 2-nél!", 255,255,255,true)
            return
        elseif tonumber(level) < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek nagyobbnak kell lennie 0-nál!", 255,255,255,true)
            return    
        end
        
        level = tonumber(math.floor(level))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local newLevel = level
                local oValue = getElementData(target, "admin >> level")
                if target == localPlayer then
                    if oValue > 2 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Adminnak nem állíthasz AdminSegéd szintet!", 255,255,255,true)
                        return
                    end
                else
                    if oValue > 2 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Adminnak nem állíthasz AdminSegéd szintet!", 255,255,255,true)
                        return
                    end
                end
                setElementData(target, "admin >> level", newLevel)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info")..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminsegéd szintjét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..newLevel.."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("sethelperlevel", setHelperLevel)
addCommandHandler("sethlevel", setHelperLevel)
addCommandHandler("setaslevel", setHelperLevel)

-- /adminduty, aduty
function adminDuty(cmd, target)
    if isTimer(adutyTimer) then return end
    if exports['cr_permission']:hasPermission(localPlayer, "aduty") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            
            if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            
            if target and exports['cr_permission']:hasPermission(localPlayer, "forceaduty") then
                if getElementData(target, "loggedIn") then
                    local oValue = getElementData(target, "admin >> duty")
                    setElementData(target, "admin >> duty", not oValue)
                    local aName1 = getAdminName(localPlayer, true)
                    local aName2 = getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local newValue = not oValue
                    if newValue then
                        if not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                            adutyTimer = setTimer(function() end, 60 * 1000, 1)
                        end
                        exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." beléptette "..hexColor..aName2..white.."-t az adminszolgálatba", 8)
                    else
                        exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." kiléptette "..hexColor..aName2..white.."-t az adminszolgálatból", 8)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        else
            target = localPlayer
            local oValue = getElementData(target, "admin >> duty")
            setElementData(target, "admin >> duty", not oValue)
            local newValue = not oValue
            if newValue then
                if not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                    adutyTimer = setTimer(function() end, 60 * 1000, 1)
                end
            end
            local aName1 = getAdminName(localPlayer, true)
            local aName2 = getAdminName(target, true)
            local hexColor = exports['cr_core']:getServerColor(nil, true)
        end
    end
end
addCommandHandler("aduty", adminDuty)
addCommandHandler("adminduty", adminDuty)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "admin >> duty") then
            adminTimer = setTimer(
                function()
                    if not getElementData(localPlayer, "char->afk") then
                        local oAdminTime = getElementData(localPlayer, "admin >> time")
                        setElementData(localPlayer, "admin >> time", oAdminTime + 1)
                    end
                end, 60 * 1000, 0
            )
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if source == localPlayer then
            if dName == "admin >> duty" then
                local value = getElementData(source, dName)
                if value then
                    adminTimer = setTimer(
                        function()
                            if not getElementData(localPlayer, "char->afk") then
                                local oAdminTime = getElementData(localPlayer, "admin >> time") or 0
                                setElementData(localPlayer, "admin >> time", oAdminTime + 1)
                            end
                        end, 60 * 1000, 0
                    )
                else
                    if isTimer(adminTimer) then
                        killTimer(adminTimer)
                    end
                end
            end
        end
        if dName == "admin >> duty" then
            local value = getElementData(source, dName)
            local adminlevel = getElementData(source, "admin >> level") or 0
            if adminlevel > 2 and adminlevel < 10 then
                if value then
                    --Belépés
                    local id = getElementData(source, "char >> id") or 0
                    exports['cr_infobox']:addBox("aduty", getAdminName(source, true) .. " adminszolgálatba lépett! /pm "..id)
                else
                    --Kilépés
                    exports['cr_infobox']:addBox("aduty", getAdminName(source, true) .. " kilépett az adminszolgálatból!")
                end
            end
        end
    end
)

-- /fly

addCommandHandler("fly", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            toggleFly()
        end
    end
)

-- /getpos

addCommandHandler("getpos", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            local x,y,z = getElementPosition(localPlayer)
            local dim, int = getElementDimension(localPlayer), getElementInterior(localPlayer)
            local a, a, rot = getElementRotation(localPlayer)
            setClipboard(x .. ", " .. y .. ", " .. z)
            local syntax = exports['cr_core']:getServerSyntax("Position", "warning")
            local green = exports['cr_core']:getServerColor("green", true)
            --outputChatBox(syntax .. ": ",255,255,255,true)
            outputChatBox(syntax .. "XYZ" .. ": ".. green .. x .. white ..", " .. green .. y .. white .. ", " .. green .. z,255,255,255,true)
            outputChatBox(syntax .. "Interior" .. ": ".. green .. int,255,255,255,true)
            outputChatBox(syntax .. "Dimension" .. ": ".. green .. dim,255,255,255,true)
            outputChatBox(syntax .. "Rotation" .. ": ".. green .. rot,255,255,255,true)
        end
    end
)

local flyingState = false
local keys = {}
keys.up = "up"
keys.down = "up"
keys.f = "up"
keys.b = "up"
keys.l = "up"
keys.r = "up"
keys.a = "up"
keys.s = "up"
keys.m = "up"

function toggleFly()
	flyingState = not flyingState	
	if flyingState then
		addEventHandler("onClientRender",getRootElement(),flyingRender, true, "low-5")
		bindKey("lshift","both",keyH)
		bindKey("rshift","both",keyH)
		bindKey("lctrl","both",keyH)
		bindKey("rctrl","both",keyH)
		
		bindKey("forwards","both",keyH)
		bindKey("backwards","both",keyH)
		bindKey("left","both",keyH)
		bindKey("right","both",keyH)
		
		bindKey("lalt","both",keyH)
		bindKey("space","both",keyH)
		bindKey("ralt","both",keyH)
		bindKey("mouse1","both",keyH)
        if not localPlayer.vehicle then
		    setElementCollisionsEnabled(getLocalPlayer(),false)
        end
        setElementData(localPlayer, "keysDenied", true)
	else
		removeEventHandler("onClientRender",getRootElement(),flyingRender)
		unbindKey("mouse1","both",keyH)
		unbindKey("lshift","both",keyH)
		unbindKey("rshift","both",keyH)
		unbindKey("lctrl","both",keyH)
		unbindKey("rctrl","both",keyH)
		
		unbindKey("forwards","both",keyH)
		unbindKey("backwards","both",keyH)
		unbindKey("left","both",keyH)
		unbindKey("right","both",keyH)
		
		unbindKey("space","both",keyH)
		
		keys.up = "up"
		keys.down = "up"
		keys.f = "up"
		keys.b = "up"
		keys.l = "up"
		keys.r = "up"
		keys.a = "up"
		keys.s = "up"
        if not localPlayer.vehicle then
		    setElementCollisionsEnabled(getLocalPlayer(),true)
        end
        setElementData(localPlayer, "keysDenied", false)
	end
end

function flyingRender()
	local x,y,z = getElementPosition(localPlayer.vehicle or getLocalPlayer())
	local speed = 10
    --outputChatBox(speed)
	if keys.a=="down" then
		speed = 3
	elseif keys.s=="down" then
		speed = 50
	elseif keys.m=="down" then
		speed = 300
	end
    --outputChatBox(speed)
	
	if keys.f=="down" then
		local a = rotFromCam(0)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	elseif keys.b=="down" then
		local a = rotFromCam(180)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	end
	
	if keys.l=="down" then
		local a = rotFromCam(-90)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	elseif keys.r=="down" then
		local a = rotFromCam(90)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	end
	
	if keys.up=="down" then
		z = z + 0.1*speed
	elseif keys.down=="down" then
		z = z - 0.1*speed
	end
	
    --outputChatBox(inspect(localPlayer.vehicle or getLocalPlayer()))
    --outputChatBox(x..y..z)
	setElementPosition(localPlayer.vehicle or getLocalPlayer(),x,y,z)
end

function keyH(key,state)
	if key=="lshift" or key=="rshift" then
		keys.s = state
	end	
	if key=="lctrl" or key=="rctrl" then
		keys.down = state
	end	
	if key=="forwards" then
		keys.f = state
	end	
	if key=="backwards" then
		keys.b = state
	end	
	if key=="left" then
		keys.l = state
	end	
	if key=="right" then
		keys.r = state
	end	
	if key=="lalt" or key=="ralt" then
		keys.a = state
	end	
	if key=="space" then
		keys.up = state
	end	
	if key=="mouse1" then
		keys.m = state
	end	
end

function rotFromCam(rzOffset)
	local cx,cy,_,fx,fy = getCameraMatrix(getLocalPlayer())
	local deltaY,deltaX = fy-cy,fx-cx
	local rotZ = math.deg(math.atan((deltaY)/(deltaX)))
	if deltaY >= 0 and deltaX <= 0 then
		rotZ = rotZ+180
	elseif deltaY <= 0 and deltaX <= 0 then
		rotZ = rotZ+180
	end
	return -rotZ+90 + rzOffset
end

function dirMove(a)
	local x = math.sin(math.rad(a))
	local y = math.cos(math.rad(a))
	return x,y
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "keysDenied" and flyingState then
            local value = getElementData(source, dName)
            if not value then
                setElementData(source, dName, true)
            end
        elseif dName == "admin >> duty" and flyingState then
            local value = getElementData(source, dName)
            if not value then
                toggleFly()
            end
        end
    end
)

-- // Hallhatatlanság (God)
addEventHandler("onClientPlayerDamage", root,
    function()
        local adminduty = getAdminDuty(source)
        local adminlevel = getElementData(source, "admin >> level")
        if adminduty and adminlevel >= 3 then
            cancelEvent()
        end
    end
)

addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        local adminduty = getAdminDuty(target)
        local adminlevel = getElementData(target, "admin >> level")
        if adminduty and adminlevel >= 3 then
            cancelEvent()
        end
    end
)

function playSoundClient(player, music)
    if player == localPlayer then
        playSound(music)
    end    
end
addEvent("playSoundClient", true)
addEventHandler("playSoundClient", root, playSoundClient)


--KURVA ANYÁD TE DEBIL MOCSKOS IDIÓTA AKI EZT íRTA!
setElementData(localPlayer, "admin >> togvá", true)
function valaszAdmin(message)
    local pair = {}
    for k,v in pairs(getElementsByType("player")) do
        local adminlevel = getElementData(v, "admin >> level") or 0
        if adminlevel >= 3 then
            if getElementData(v, "admin >> togvá") then
                pair[v] = true
            end
        end
    end
    
    for k,v in pairs(pair) do
        triggerServerEvent("outputChatBox", localPlayer, k, message)
    end
end

--------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------[[ Parancsok ]]--------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

function pm_sc(cmd, target, ...)
    if not (target) or not (...) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Admin ID/Név] [Üzenet]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "pm") then
            if getElementData(target, "loggedIn") then
                if localPlayer == target then 
                    exports['cr_infobox']:addBox("error", "Magadnak nem írhatsz pm-et!")
                    return 
                end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(target)
                local jatekosName = getAdminName(localPlayer) --getElementData(localPlayer,"char >> name"):gsub("_", " ")
                local adminID = getElementData(target, "char >> id")
                local localID = getElementData(localPlayer, "char >> id")
                local adminDuty = exports['cr_admin']:getAdminDuty(target)
                local forcePM = exports['cr_permission']:hasPermission(localPlayer, "forcepm")
                local text = table.concat({...}, " ")

                if not adminDuty then
                	if not forcePM then
	                    exports['cr_infobox']:addBox("error", "Csak szolgálatban lévő adminnak írhatsz!")
	                    return
	                end
                end

                outputChatBox(color.."[PM - Tőled]#ffffff "..adminName..color.." ["..adminID.."]:#ffffff "..text,0,0,0,true)
                playSound("files/enter.mp3")
                local message = color.."[PM - Neked]#ffffff "..jatekosName..color.." ["..localID.."]:#ffffff "..text
                triggerServerEvent("outputChatBox", localPlayer, target, message)
                triggerServerEvent("playSoundServer", localPlayer, target, "files/pm.mp3")
            end
        else noOnline() end
    end
end
addCommandHandler("pm", pm_sc)


function valasz_sc(cmd, target, ...)
    if not (target) or not (...) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Üzenet]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "vá") then
            if getElementData(target, "loggedIn") then
                if localPlayer == target then 
                    exports['cr_infobox']:addBox("error", "Magadnak nem bírsz választ adni!")
                    return 
                end
                local color = exports['cr_core']:getServerColor(nil, true)
                local color2 = exports['cr_core']:getServerColor('red', true)
                local adminName = getAdminName(localPlayer)
                local jatekosName = getAdminName(target) --getElementData(target,"char >> name"):gsub("_", " ")
                local adminID = getElementData(localPlayer, "char >> id")
                local playerID = getElementData(target, "char >> id")
                local text = table.concat({...}, " ")

                valaszAdmin(color2.."[Segítségnyújtás] "..color..adminName.."#ffffff válaszolt "..color..jatekosName.."#ffffff-nak")
                valaszAdmin(color2.."[Segítségnyújtás] "..color.."szöveg:#ffffff "..text)

                local message = color.."[Segítség]#ffffff "..adminName..color.." ("..adminID.."):#ffffff "..text
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                outputChatBox(color.."[Válasz]#ffffff "..jatekosName..color.." ("..playerID.."):#ffffff "..text,0,0,0,true)
            else
                exports['cr_infobox']:addBox("error", "Nincs belépve a játékos!")
            end
        else noOnline() end
    end
end
addCommandHandler("va", valasz_sc)
addCommandHandler("vá", valasz_sc)
addCommandHandler("valasz", valasz_sc)
addCommandHandler("válasz", valasz_sc)


function togva_sc(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "togvá") then
        if getElementData(localPlayer, "admin >> togvá") then
            setElementData(localPlayer, "admin >> togvá", false)
            local colorTag = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(colorTag.."#ffffff Kikapcsoltad az admin válaszokat!",0,0,0,true)
        else
            setElementData(localPlayer, "admin >> togvá",true)
            local colorTag = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(colorTag.."#ffffff Bekapcsoltad az admin válaszokat!",0,0,0,true)
        end
    end
end
addCommandHandler("togva",togva_sc)
addCommandHandler("togvá",togva_sc)


function asChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "asChat") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = "Ismeretlen"
            
            if getElementData(localPlayer, "admin >> level") <= 2 then
                adminName = getElementData(localPlayer, "char >> name")
            else
                adminName = getAdminName(localPlayer, true)
            end
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getElementData(localPlayer, "admin >> level"), true)
            local title = getAdminTitle(localPlayer)
            title = aTitle(localPlayer)
            

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#ff66d9[AS] #7cc576"..title.." "..adminName.."#ffffff: "..text, 1)
        end
    end
end
addCommandHandler("as",asChat_sc)

function adminChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "adminChat") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getElementData(localPlayer, "admin >> level"), true)
            local title = getAdminTitle(localPlayer)
            title = aTitle(localPlayer)

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#ff751a[AdminChat] #7cc576"..title.." "..adminName.."#ffffff: "..text, 3)
        end
    end
end
addCommandHandler("a",adminChat_sc)

function vhspawn_sc(cmd, target, types)
    if not (target) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "vhSpawn") then
            if getElementData(target, "loggedIn") then
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local adminName = getAdminName(localPlayer, true)
                local color = exports['cr_core']:getServerColor(nil, true)

                if getPedOccupiedVehicle(target) then
	                triggerServerEvent("setElementPosition", localPlayer, getPedOccupiedVehicle(target), 1468.4044189453, -1718.8636474609, 14.046875, 0, 0)
	                setElementRotation(target, 0.0, 0.0, 177.04724121094)
	            else
	            	triggerServerEvent("setElementPosition", localPlayer, target, 1468.4044189453, -1718.8636474609, 14.046875, 0, 0)
	                setElementRotation(target, 0.0, 0.0, 177.04724121094)
	            end

                local message = color..adminName.."#ffffff a városházára teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..jatekosName.."#ffffff VH spawn-t kapott "..color..adminName.."#ffffff által!", 3)
            end
        else noOnline() end
    end
end
addCommandHandler("vhspawn",vhspawn_sc)

function recon_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "recon") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            local color = exports['cr_core']:getServerColor(nil, true)
            local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")

            if target then
                if getElementData(target,"loggedIn") then
                    if not getElementData(target, "player >> recon") then
                        if getElementData(localPlayer, "player >> recon") then
                            local x,y,z = getElementPosition(localPlayer)
                            local dim = getElementDimension(localPlayer)
                            local int = getElementInterior(localPlayer)
                            setElementData(localPlayer,"recon >> tarX", x)
                            setElementData(localPlayer,"recon >> tarY", y)
                            setElementData(localPlayer,"recon >> tarZ", z)
                            setElementData(localPlayer,"recon >> dim", dim)
                            setElementData(localPlayer,"recon >> int", int)
                        end
                        triggerServerEvent("setPlayerCol", localPlayer, localPlayer, false)
                        triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 0)
                        setElementData(localPlayer, "player >> recon", true)
                        setElementData(localPlayer, "player >> recon >> target", target)
                        setElementFrozen(localPlayer, true)
                        setCameraTarget(target)   
                        exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megfigyeli "..color..jatekosName.."#ffffff játékost!", 8)                    
                    else
                        exports["cr_infobox"]:addBox("error","A játékos már reconol valakit!");
                    end
                end
            else noOnline() end
        end
    end
end
addCommandHandler("recon", recon_sc)

function stopRecon_sc(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "recon") then
        local color = exports['cr_core']:getServerColor(nil, true)

        local tarX = getElementData(localPlayer,"recon >> tarX")
        local tarY = getElementData(localPlayer,"recon >> tarY")
        local tarZ = getElementData(localPlayer,"recon >> tarZ")
        local dim = getElementData(localPlayer,"recon >> dim")
        local int = getElementData(localPlayer,"recon >> int")

        setCameraTarget(localPlayer)
        setElementPosition(localPlayer,tarX,tarY,tarZ)
        setElementDimension(localPlayer, dim)
        setElementInterior(localPlayer, int)
        setElementData(localPlayer, "player >> recon", false)
        setElementData(localPlayer, "player >> recon >> target", nil)
        setElementFrozen(localPlayer, false)

        triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255)
        triggerServerEvent("setPlayerCol", localPlayer, localPlayer, true)

        exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff befejezte a megfigyelést!", 8)
    end
end
addCommandHandler("stoprecon", stopRecon_sc)


function goto_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "goto") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z
	            local dim
	            local int
                if getElementData(target,"clone") then
                	local target2 = getElementData(target,"clone")
                	x,y,z = getElementPosition(target2)
	                dim = getElementDimension(target2)
	                int = getElementInterior(target2)
                else
	                x,y,z = getElementPosition(target)
	                dim = getElementDimension(target)
	                int = getElementInterior(target)
	            end


                if not getPedOccupiedVehicle(localPlayer) then
                    triggerServerEvent("setElementPosition", localPlayer, localPlayer, x,y+1,z, dim, int)
                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz!",0,0,0,true)
                    local message = color..adminName.."#ffffff hozzád teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local veh = getPedOccupiedVehicle(localPlayer)
                    setElementInterior(veh, int)
                    setElementDimension(veh, dim)
                    setElementPosition(veh, x+2, y, z+1)

                    setElementInterior(localPlayer, int)
                    setElementDimension(localPlayer, dim)

                    warpPedIntoVehicle(localPlayer, veh)

                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz!",0,0,0,true)
                    local message = color..adminName.."#ffffff hozzád teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("goto",goto_sc)

function gethere_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "gethere") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z = getElementPosition(localPlayer)
                local dim = getElementDimension(localPlayer)
                local int = getElementInterior(localPlayer)

                if getPedOccupiedVehicle(target) then
                    local veh = getPedOccupiedVehicle(target)
                    triggerServerEvent("setElementPosition", localPlayer, veh, x,y+1,z, dim, int)
                    outputChatBox(white.."#ffffff Sikeresen magadhoz teleportáltad "..color..jatekosName.."#ffffff játékost!",0,0,0,true)
                    local message = color..adminName.."#ffffff magához teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                	if getElementData(target,"char >> death") then
                    	triggerServerEvent("setElementPosition", localPlayer, getElementData(target,"clone"), x,y+1,z, dim, int)
                    else
                    	triggerServerEvent("setElementPosition", localPlayer, target, x,y+1,z, dim, int)
                    end
                    outputChatBox(white.."#ffffff Sikeresen magadhoz teleportáltad "..color..jatekosName.."#ffffff játékost!",0,0,0,true)
                    local message = color..adminName.."#ffffff magához teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("gethere",gethere_sc)
addCommandHandler("get",gethere_sc)

function sethp_sc(cmd,target,health)
    if exports['cr_permission']:hasPermission(localPlayer, "sethp") then
        if not (target) or not (health) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Élet]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                health = tonumber(health)
                if(health >= 0 and health <= 100)then
                	if getElementData(localPlayer, "admin >> level") >= getElementData(target, "admin >> level") then
	                    triggerServerEvent("setElementHealth", localPlayer, target, health)
	                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff életét. ("..color..health.."#ffffff)", 7)
	                    local message = color..adminName.."#ffffff megváltoztatta az életerőd! ("..color..health.."#ffffff)"
	                    triggerServerEvent("outputChatBox", localPlayer, target, message)
	                else
	                	outputChatBox(getAdminSyntax().."#ffffffNagyobb admin életét nem változtathatod meg!",0,0,0,true)
	                end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("sethp",sethp_sc)


function setarmor_sc(cmd,target,armor)
    if exports['cr_permission']:hasPermission(localPlayer, "setarmor") then
        if not (target) or not (armor) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Armor]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                armor = tonumber(armor)
                if(armor >= 0 and armor <= 100)then
                    triggerServerEvent("setElementArmor", localPlayer, target, armor)
                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff páncélszintjét. ("..color..armor.."#ffffff)", 7)
                    local message = color..adminName.."#ffffff megváltoztatta az páncélszinted! ("..color..armor.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("setarmor",setarmor_sc)

setElementData(localPlayer, "player >> vanish", false) -- Ha újraindítsuk a resourcet akkor újra láthatatlan legyen!
triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255) -- ez is azért xD
function vanish_sc()
    if exports['cr_permission']:hasPermission(localPlayer, "vanish") then
        if not getElementData(localPlayer, "player >> vanish") then
            triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 0)
            setElementData(localPlayer, "player >> vanish", true)
        else
            triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255)
            setElementData(localPlayer, "player >> vanish", false)
        end
    end
end
addCommandHandler("vanish", vanish_sc)
addCommandHandler("disappear", vanish_sc)


function hunger_sc(cmd, target, hunger)
	if exports['cr_permission']:hasPermission(localPlayer, "sethunger") then
		if not (target) or not (hunger) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Hunger]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                hunger = tonumber(hunger)
                if(hunger >= 0 and hunger <= 100)then
                    setElementData(localPlayer, "char >> food", hunger)

                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff éhség szintjét. ("..color..hunger.."#ffffff)", 7)
                    local message = color..adminName.."#ffffff megváltoztatta az éhség szintedet! ("..color..hunger.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
		end
	end
end
addCommandHandler("sethunger", hunger_sc)

function water_sc(cmd, target, water)
	if exports['cr_permission']:hasPermission(localPlayer, "setwater") then
		if not (target) or not (water) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Water]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                water = tonumber(water)
                if(water >= 0 and water <= 100)then
                    setElementData(localPlayer, "char >> drink", water)

                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff szomjúság szintjét. ("..color..water.."#ffffff)", 7)
                    local message = color..adminName.."#ffffff megváltoztatta az szomjúság szintedet! ("..color..water.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
		end
	end
end
addCommandHandler("setwater", water_sc)
addCommandHandler("setwaterlevel", water_sc)
addCommandHandler("setthirsty", water_sc)
addCommandHandler("setthirst", water_sc)


function kick_sc(cmd,target,...)
	if exports['cr_permission']:hasPermission(localPlayer, "kick") then
		if not (target) or not (...) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Indok]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local text = table.concat({...}, " ")
                local color = exports['cr_core']:getServerColor(nil, true)
                
                if localPlayer == target then return end
                if tonumber(getElementData(localPlayer, "admin >> level") or 0) > tonumber(getElementData(target, "admin >> level") or 0) then
    				triggerServerEvent("kickedPlayer",localPlayer,target,adminName,text)
                    local maxHasFix = getMaxKickCount() or 0
                    local thePlayer = localPlayer
                    local hasFIX = getElementData(thePlayer, "kick >> using") or 0
                    local hasFIX = hasFIX + 1
                    setElementData(thePlayer, "kick >> using", hasFIX)
                    if hasFIX > maxHasFix then
                        local green = exports['cr_core']:getServerColor("orange", true)
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        --local vehicleName = getVehicleName(target)
                        outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Kick limitet! (Limit: "..green..maxHasFix..white..") (Kickek száma: "..green..hasFIX..white..")", 255,255,255,true)
                    end
                    --triggerServerEvent("showInfo",localPlayer,target,"kick",text, "#ff751a"..adminName.."#ffffff kickelte#ff751a "..jatekosName.."#ffffff játékost.")
                    
                    triggerServerEvent("showAdminBox",localPlayer,"#ff751a"..adminName.."#ffffff kickelte#ff751a "..jatekosName.."#ffffff játékost\n#ff751aIndok:#ffffff "..text, "warning", {adminName.." kickelte "..jatekosName .. " játékost", "Indok: "..text})
                else
                	outputChatBox(getAdminSyntax().."#ffffffNagyobb admin-t nem kickelhetsz!",0,0,0,true)
                end
			else noOnline() end
		end
	end
end
addCommandHandler("kick",kick_sc)
addCommandHandler("akick",kick_sc)

local togSkin = {
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [8] = true,
    [42] = true,
    [65] = true,
    [74] = true,
    [86] = true,
    [119] = true,
    [149] = true,
    [208] = true,
    [289] = true,
}
function setskin_sc(cmd, target, skin)
    if exports['cr_permission']:hasPermission(localPlayer, "setskin") then
        if not (target) or not (skin) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Skin]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local color = exports['cr_core']:getServerColor(nil, true)
                skin = tonumber(skin)

                if not togSkin[skin] and skin >= 0 and skin <= 312 then
                    triggerServerEvent("setElementModelSpecial",localPlayer, target, skin)
                    setElementData(target, "char >> skin", skin)

                    local message = color..adminName.."#ffffff megváltoztatta a kinézeted! (Új skin ID:"..color..skin.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                    outputChatBox("#ffffffSikeresen megváltoztattad "..color..jatekosName.."#ffffff kinézetét! ("..color..skin.."#ffffff)",0,0,0,true)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Hibás Skin ID!",0,0,0,true)
                end 
            else noOnline() end
        end
    end
end
addCommandHandler("setskin",setskin_sc)


function simgoto_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "sgoto") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z = getElementPosition(target)
                local dim = getElementDimension(target)
                local int = getElementInterior(target)

                if not getPedOccupiedVehicle(localPlayer) then
                    triggerServerEvent("setElementPosition", localPlayer, localPlayer, x,y+1,z, dim, int)
                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz! ("..color.."Rejtett#ffffff)",0,0,0,true)
                else
                    local veh = getPedOccupiedVehicle(localPlayer)
                    setElementInterior(veh, int)
                    setElementDimension(veh, dim)
                    setElementPosition(veh, x+2, y, z+1)

                    setElementInterior(localPlayer, int)
                    setElementDimension(localPlayer, dim)

                    warpPedIntoVehicle(localPlayer, veh)

                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz! ("..color.."Rejtett#ffffff)",0,0,0,true)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("sgoto",simgoto_sc)

--[[
local glue = false
local glue_e = false
function glue_sc(cmd)
	local entry = false
	if getPedOccupiedVehicle(localPlayer) then return end
	local e = getPlayerContactElement(localPlayer)
	if exports['cr_permission']:hasPermission(localPlayer, "glue") then
		entry = true
	else
		if isElement(e) then
			local mID = getElementModel(e)
			if glue_vehs[mID] then
				entry = true
			end
		end
	end
	if not glue then
		if not isElement(e) then return end
		if not entry then return end
		if getElementType(e) == "vehicle" then
			local px, py, pz = getElementPosition(localPlayer)
			local vx, vy, vz = getElementPosition(e)
			local sx = px - vx
			local sy = py - vy
			local sz = pz - vz
			
			local rotpX = 0
			local rotpY = 0
			local a,b,rotpZ = getElementRotation(localPlayer)     
				
			local rotvX,rotvY,rotvZ = getElementRotation(e)
			
			local t = math.rad(rotvX)
			local p = math.rad(rotvY)
			local f = math.rad(rotvZ)
				
			local ct = math.cos(t)
			local st = math.sin(t)
			local cp = math.cos(p)
			local sp = math.sin(p)
			local cf = math.cos(f)
			local sf = math.sin(f)
				
			local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
			local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
			local y = st*sz - sf*ct*sx + cf*ct*sy
			
			local rotX = rotpX - rotvX
			local rotY = rotpY - rotvY
			local rotZ = rotpZ - rotvZ

			glue = true
			glue_e = e

			triggerServerEvent("glue_attach",localPlayer,e,x, y, z, rotX, rotY, rotZ)
		end
	else
		glue = false
		glue_e = false

		triggerServerEvent("glue_deatach",localPlayer)
	end
end
addCommandHandler("glue",glue_sc)

addEventHandler("onClientElementDestroy",root,
	function()
		if glue_e == source then
			glue = false
			glue_e = false
			triggerServerEvent("glue_deatach",localPlayer)
		end
	end
)

addEventHandler("onClientElementDataChange",root,
	function(dName)
		if getElementType(source) == "vehicle" and dName == "veh >> loaded" then
			if glue_e == source then
				local bool = getElementData(source,dName)
				if not bool then
					glue = false
					glue_e = false
					triggerServerEvent("glue_deatach",localPlayer)
				end
			end
		end
	end
)]]

function accinfo_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "accinfo") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local color = exports['cr_core']:getServerColor(nil, true)
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            if target then
            	local username = getElementData(target, "acc >> username")
            	local accid = getElementData(target, "acc >> id")
                local serial = getElementData(target, "mtaserial")

                --local ip level 9admin felett + kellenek a targeteg

            	local gamename = getElementData(target, "char >> name")
            	--local regdate
            	--local lastplayed
            	local playedtime = getElementData(target, "char >> playedtime")
            	--local ajk
            	--local bannok
            	local money = getElementData(target, "char >> money")
            	local bankmoney = getElementData(target, "char >> bankmoney")
            	local pp = getElementData(target, "char >> premiumPoints")
            	local health = getElementHealth(target)
        		local armor = getPedArmor(target)
            	local food = getElementData(target, "char >> food")
        		local drink = getElementData(target, "char >> drink")
        		local level = getElementData(target, "char >> level")
            	local skinid = getElementData(target, "char >> skin")
            	--local hazakidk
            	local vehicles = "Jármű ID-k: "
            	for k,v in pairs(getElementsByType("vehicle"))do
            		local vid = getElementData(v,"veh >> owner")
            		if vid == accid then
            			vehicles = getElementData(v,"veh >> id")..", "
            		end
            	end
            	--local fraki

            else noOnline() end
        end
    end
end
addCommandHandler("accinfo", accinfo_sc)

function faChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "af") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getElementData(localPlayer, "admin >> level"), true)

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#3385ff[FAChat]#7cc576 "..getAdminTitle(localPlayer).." "..adminName.."#ffffff : "..text, 8)
        end
    end
end
addCommandHandler("fc",faChat_sc)

function devChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "dev") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getElementData(localPlayer, "admin >> level"), true)

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#D35400[Developer]#7cc576 "..getAdminTitle(localPlayer).." "..adminName.."#ffffff: "..text, 11)
        end
    end
end
addCommandHandler("dc",devChat_sc)

local deathTime = false
function player_Wasted(attacker, weapon, bodypart)

    local time = getRealTime()
    local hours = time.hour
    local minutes = time.minute
    
    if minutes < 10 then minutes = "0" .. minutes end
    if hours < 10 then hours = "0" .. hours end

    if deathTime == false then
    	deathTime = true
    	setTimer(function() deathTime = false end,5000,1)
    else
    	return
    end
    local text
    if attacker then
        if getElementType(attacker) == "player" then
        	if(bodypart == 9) then
				if not getElementData(localPlayer, "char >> headless") then
            	    setElementData(localPlayer, "char >> headless", true)
            	end
            	local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
            	local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
            	text = hours..":"..minutes.."] "..killerName.. " fejbelőtte "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost! (Fegyver: "..weaponName.." - FEJLÖVÉS)"
            	exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
        	elseif (bodypart == 4) then
        		local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
	            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
	            text = hours..":"..minutes.."] "..killerName.. " megölte "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost! (Fegyver: "..weaponName.." - SEGGBELŐTTÉK)"
	            exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
        	else
	            local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
	            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
	            text = hours..":"..minutes.."] "..killerName.. " megölte "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost! (Fegyver: "..weaponName.." )"
	            
	            exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
        	end
        elseif getElementType(attacker) == "vehicle" then

            local killerName = "Ismeretlen, Kocsi id: " .. tonumber(getElementData(attacker, "dbid") or -1)
            local killer = getVehicleController(attacker)
            if killer then
                killerName = getElementData(killer, "char >> name"):gsub("_", " ") or getPlayerName(killer):gsub("_", " ")
            end
            text = hours..":"..minutes.."] "..killerName.. " elütötte "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost! [DB gyanúja]"
            exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
        end
        --[[if ( bodypart == 9 ) then
            if not getElementData(localPlayer, "char >> headless") then
                setElementData(localPlayer, "char >> headless", true)
            end
            local weaponName = getWeaponNameFromID(weapon)
            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
            exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..hours..":"..minutes.."] "..killerName.. " fejbelőtte "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost! (Fegyver: "..weaponName.." - FEJLÖVÉS)",1)
        end]]--
        if getWeaponNameFromID(weapon) == "Explosion" then
            local killerName = getElementData(attacker, "char >> name"):gsub("_", " ") or getPlayerName(attacker):gsub("_", " ")
            text = hours..":"..minutes.."] "..killerName.. " felrobbantotta "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." játékost!"
            exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
        end
    else
    	text = hours..":"..minutes.."] "..getElementData(localPlayer, "char >> name"):gsub("_"," ").." meghalt!"
        exports['cr_core']:sendMessageToAdmin(localPlayer,"#dcdcdc["..text,1)
    end
    local time = getRealTime()
    local date = "["..((time.year)-100+2000).."."..((time.month)+1).."."..time.monthday.."]"
    exports['cr_logs']:addLog(isElement(attacker) and attacker or -2, "Kills","kill",date.."["..text)
end
addEventHandler("onClientPlayerWasted", localPlayer, player_Wasted)

-- /setmoney, /setpp, /givemoney, /givepp

function setMoney(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setmoney") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> money")
                setElementData(target, "char >> money", amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax() ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." pénzének mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..amount.."#ffffff-ra/re.", 3)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setmoney", setMoney)

function setPP(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setpp") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> premiumPoints")
                setElementData(target, "char >> premiumPoints", amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." prémium pontjainak mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..amount.."#ffffff-ra/re.", 3)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setpp", setPP)

function giveMoney(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setmoney") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> money")
                setElementData(target, "char >> money", oValue + amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." pénzének mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..oValue+amount.."#ffffff-ra/re.", 3)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("givemoney", giveMoney)

function givePP(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setpp") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> premiumPoints")
                setElementData(target, "char >> premiumPoints", oValue + amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor(nil, true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." prémium pontjának mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..oValue+amount.."#ffffff-ra/re.", 3)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("givepp", givePP)

--
-- /resetfix
function resetFix(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetfix") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fix >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." FIX számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetfix", time .. aName1.." nullázta "..aName2.." FIX számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetfix", resetFix)

-- /resetrtc
function resetRTC(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetrtc") then
        if target then
            if getElementData(target, "loggedIn") then
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    setElementData(target, "rtc >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." RTC számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetrtc", time .. aName1.." nullázta "..aName2.." RTC számait")
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("resetrtc", resetRTC)

-- /resetfuel
function resetFUEL(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetfuel") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fuel >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." FUEL számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetfuel", time .. aName1.." nullázta "..aName2.." FUEL számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetfuel", resetFUEL)



-- /getAdminStats
function getAdminStats(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if vehStatPanel then return end
    if exports['cr_permission']:hasPermission(localPlayer, "getadminstats") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    local time = getTime() .. " "
                    local fix = getElementData(target, "fix >> using") or 0
                    local fuel = getElementData(target, "fuel >> using") or 0
                    local rtc = getElementData(target, "rtc >> using") or 0
                    local ban = getElementData(target, "ban >> using") or 0
                    local kick = getElementData(target, "kick >> using") or 0
                    local jail = getElementData(target, "jail >> using") or 0
                    local dutyMinutes = getElementData(target, "admin >> time") or 0
                    local dutyMinutes = math.floor(dutyMinutes / 60)
                    local maxJail = exports['cr_admin']:getMaxJailCount() or 0
                    local maxKick = exports['cr_admin']:getMaxKickCount() or 0
                    local maxBan = exports['cr_admin']:getMaxBanCount() or 0
                    local maxHasRTC = exports['cr_admin']:getMaxRTCCount() or 0
                    local maxHasFuel = exports['cr_admin']:getMaxFuelCount() or 0
                    local maxHasFix = exports['cr_admin']:getMaxFixCount() or 0
                    --[[
                    outputChatBox(syntax .. hexColor .. aName2 .. white .. " Statisztikái:",255,255,255,true)
                    outputChatBox(syntax .. "AdminDutyban töltött órák: "..hexColor..dutyMinutes,255,255,255,true)
                    outputChatBox(syntax .. "AdminDutyban töltött percek: "..hexColor..math.floor(dutyMinutes*60),255,255,255,true)
                    outputChatBox(syntax .. "Fixek: "..hexColor..fix..white.."/"..hexColor..maxHasFix,255,255,255,true)
                    outputChatBox(syntax .. "RTC-k: "..hexColor..rtc..white.."/"..hexColor..maxHasRTC,255,255,255,true)
                    outputChatBox(syntax .. "Fuelek: "..hexColor..fuel..white.."/"..hexColor..maxHasFuel,255,255,255,true)
                    outputChatBox(syntax .. "Jailek: "..hexColor..jail..white.."/"..hexColor..maxJail,255,255,255,true)
                    outputChatBox(syntax .. "Kickek: "..hexColor..kick..white.."/"..hexColor..maxKick,255,255,255,true)
                    outputChatBox(syntax .. "Bannok: "..hexColor..ban..white.."/"..hexColor..maxBan,255,255,255,true)
                    ]]
                    stats = {}
                    rr, rg, rb = exports['cr_core']:getServerColor("red", false)
                    stats["Name"] = hexColor .. aName2 .. white .. " Statisztikái:"
                    stats["aDutyMin"] = "AdminDutyban töltött órák: "..hexColor..dutyMinutes
                    stats["aDutyHour"] = "AdminDutyban töltött percek: "..hexColor..math.floor(dutyMinutes*60)
                    stats["Fix"] = "Fixek: "..hexColor..fix..white.."/"..hexColor..maxHasFix
                    stats["RTC"] = "RTC-k: "..hexColor..rtc..white.."/"..hexColor..maxHasRTC
                    stats["Fuel"] = "Fuelek: "..hexColor..fuel..white.."/"..hexColor..maxHasFuel
                    stats["Jail"] = "Jailek: "..hexColor..jail..white.."/"..hexColor..maxJail
                    stats["Kick"] = "Kickek: "..hexColor..kick..white.."/"..hexColor..maxKick
                    stats["Ban"] = "Bannok: "..hexColor..ban..white.."/"..hexColor..maxBan
                    if not adminStatPanel then
                        addEventHandler("onClientRender", root, renderAdminStatPanel, true, "low-5")
                    end
                    adminStatPanel = true
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("getadminstats", getAdminStats)

-- /resetadminstats
function resetAdminStats(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetadminstats") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fuel >> using", 0)
                    setElementData(target, "rtc >> using", 0)
                    setElementData(target, "fix >> using", 0)
                    setElementData(target, "jail >> using", 0)
                    setElementData(target, "ban >> using", 0)
                    setElementData(target, "kick >> using", 0)
                    setElementData(target, "jail >> using", 0)
                    setElementData(target, "admin >> time", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." összes statisztikáját", 8)
                    exports['cr_logs']:addLog("Admin", "resetadminstats", time .. aName1.." nullázta "..aName2.." összes statisztikáját")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetadminstats", resetAdminStats)

-- /resetjail
function resetJail(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetjail") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "jail >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Jail számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetjail", time .. aName1.." nullázta "..aName2.." Jail számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetjail", resetJail)

-- /resetkick
function resetKick(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "kick >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Kick számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetkick", time .. aName1.." nullázta "..aName2.." Kick számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetkick", resetKick)

-- /resetban
function resetBan(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "ban >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Ban számait", 8)
                    exports['cr_logs']:addLog("Admin", "resetban", time .. aName1.." nullázta "..aName2.." Ban számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetban", resetBan)

-- /resetatime
function resetAtime(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "admin >> time", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." AdminDuty perceit", 8)
                    exports['cr_logs']:addLog("Admin", "resetatime", time .. aName1.." nullázta "..aName2.." AdminDuty perceit")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetatime", resetAtime)

font2 = exports['cr_fonts']:getFont("Roboto", 12)

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
	        font2 = exports['cr_fonts']:getFont("Roboto", 12)
        end
	end
)

addEventHandler("onClientClick", root,
    function(b, s)
        if b == "left" and s == "down" then
            if vehStatPanel then
                if isInSlot(sx/2 - 100/2, sy/2 + 120, 100, 20) then
                    removeEventHandler("onClientRender", root, renderVehStatPanel)
                    vehStatPanel = false
                end
            elseif adminStatPanel then
                if isInSlot(sx/2 - 100/2, sy/2 + 120, 100, 20) then
                    removeEventHandler("onClientRender", root, renderAdminStatPanel)
                    adminStatPanel = false
                end
            end
        end
    end
)

function renderAdminStatPanel()
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2 - 80, 400, 380, tocolor(0,0,0,140), tocolor(0,0,0,200))
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Név
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2 - 40, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Név
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2 - 80, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Név
    linedRectangle(sx/2 - 400/2, sy/2 - 30, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- SkinID
    linedRectangle(sx/2 - 400/2, sy/2 - 70, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Játszott Óra
    linedRectangle(sx/2 - 400/2, sy/2 - 110, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Készpénz
    linedRectangle(sx/2 - 400/2, sy/2 + 10, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- premiumPoints
    linedRectangle(sx/2 - 400/2, sy/2 + 50, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Banki
    linedRectangle(sx/2 - 400/2, sy/2 + 90, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- regisztráció dátumja
    dxDrawnBorder(sx/2 - 100/2, sy/2 + 120, 100, 20, tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Tovább
    
    dxDrawText(stats["Name"], sx/2, sy/2 - 300/2 - 80, sx/2, sy/2 - 300/2 - 80 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["aDutyMin"], sx/2, sy/2 - 300/2 - 40, sx/2, sy/2 - 300/2 - 40 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["aDutyHour"], sx/2, sy/2 - 300/2, sx/2, sy/2 - 300/2 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Fix"], sx/2, sy/2 - 30, sx/2, sy/2 - 30 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["RTC"], sx/2, sy/2 - 70, sx/2, sy/2 - 70 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Fuel"], sx/2, sy/2 - 110, sx/2, sy/2 - 110 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Jail"], sx/2, sy/2 + 10, sx/2, sy/2 + 10 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Kick"], sx/2, sy/2 + 50, sx/2, sy/2 + 50 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Ban"], sx/2, sy/2 + 90, sx/2, sy/2 + 90 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    
    if isInSlot(sx/2 - 100/2, sy/2 + 120, 100, 20) then
        dxDrawText("Bezárás", sx/2, sy/2 + 120, sx/2, sy/2 + 120 + 20, tocolor(rr,rg,rb,255),fontsize, font2, "center", "center")
    else
        dxDrawText("Bezárás", sx/2, sy/2 + 120, sx/2, sy/2 + 120 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center")
    end
end


function getVehicleStats(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id) == nil and id ~= "*" then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    if adminStatPanel then return end
    local target = false
    if exports['cr_permission']:hasPermission(localPlayer, "getvehiclestats") then
        if id then
            for k,v in pairs(getElementsByType("vehicle")) do
                local id2 = getElementData(v, "veh >> id") or 0
                if id2 == tonumber(id) then
                    target = v
                end
            end
            if target then
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local vehicleName = getVehicleName(target)
                local health = math.floor(getElementHealth(target))
                local a1, a2, a3 = getElementRotation(target)
                local text1 = green..(math.floor(a1))..white..", "..green..(math.floor(a2))..white..", "..green..(math.floor(a3))..white
                local odometer = math.floor(getElementData(target, "veh >> odometer"))
                local lastOilRecoil = math.floor(getElementData(target, "veh >> lastOilRecoil"))
                local fuel = math.floor(getElementData(target, "veh >> fuel"))
                local engine = getElementData(target, "veh >> engine")
                local engineColor = exports['cr_core']:getServerColor("red", true)
                local engineString = "Nincs elindítva"
                if engine then
                    engineColor = exports['cr_core']:getServerColor("green", true)
                    engineString = "Elindítva"
                end
                local light = getElementData(target, "veh >> light")
                local lightColor = exports['cr_core']:getServerColor("red", true)
                local lightString = "Nincs elindítva"
                if light then
                    lightColor = exports['cr_core']:getServerColor("green", true)
                    lightString = "Elindítva"
                end
                local ownerID = getElementData(target, "veh >> owner")
                stats = {}
                rr, rg, rb = exports['cr_core']:getServerColor("red", false)
                stats["ID"] = "ID ".. green .. id .. white .. " ("..green..vehicleName..white..") Statisztikái:"
                stats["Health"] = "Állapot: "..green..health..white.."/"..green.."1000"..white.." ("..green..math.floor(health/10).." %"..white..")"
                stats["Rot"] = "Rotáció: "..text1
                stats["Odometer"] = "Megtett út: "..green..odometer..white.." KM"
                stats["lastOilRecoil"] = "Utolsó Olajcsere: "..green..lastOilRecoil..white.." KMnél"
                stats["Engine"] = "Motor: "..engineColor..engineString
                local maxFuel = exports['cr_vehicle']:getMaxFuel()
                stats["Fuel"] = "Benzin: "..green..fuel..white.."/"..green..maxFuel[getElementModel(target)].." liter"
                stats["Owner"] = "Tulajdonos: @4 ("..green..ownerID..white..")"
                triggerServerEvent("receiveOwnerNameForStats.server", localPlayer, localPlayer, stats["Owner"], ownerID, green, white)
            else
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("getvehiclestats", getVehicleStats)

addEvent("receiveOwnerNameForStats.client", true)
addEventHandler("receiveOwnerNameForStats.client", root,
    function(sourceE, text)
        if sourceE == localPlayer then
            stats["Owner"] = text
            if not vehStatPanel then
                addEventHandler("onClientRender", root, renderVehStatPanel, true, "low-5")
                vehStatPanel = true
            end
        end
    end
)

function renderVehStatPanel()
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2 - 40, 400, 340, tocolor(0,0,0,140), tocolor(0,0,0,200))
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2 - 40, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Név
    linedRectangle(sx/2 - 400/2, sy/2 - 300/2, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Név
    linedRectangle(sx/2 - 400/2, sy/2 - 30, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- SkinID
    linedRectangle(sx/2 - 400/2, sy/2 - 70, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Játszott Óra
    linedRectangle(sx/2 - 400/2, sy/2 - 110, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Készpénz
    linedRectangle(sx/2 - 400/2, sy/2 + 10, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- premiumPoints
    linedRectangle(sx/2 - 400/2, sy/2 + 50, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- Banki
    linedRectangle(sx/2 - 400/2, sy/2 + 90, 400, 20, tocolor(108,108,108,30), tocolor(0,0,0,120)) -- regisztráció dátumja
    dxDrawnBorder(sx/2 - 100/2, sy/2 + 120, 100, 20, tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Tovább
    
    dxDrawText(stats["ID"], sx/2, sy/2 - 300/2 - 40, sx/2, sy/2 - 300/2 - 40 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Owner"], sx/2, sy/2 - 300/2, sx/2, sy/2 - 300/2 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Health"], sx/2, sy/2 - 30, sx/2, sy/2 - 30 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Rot"], sx/2, sy/2 - 70, sx/2, sy/2 - 70 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Odometer"], sx/2, sy/2 - 110, sx/2, sy/2 - 110 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["lastOilRecoil"], sx/2, sy/2 + 10, sx/2, sy/2 + 10 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Engine"], sx/2, sy/2 + 50, sx/2, sy/2 + 50 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    dxDrawText(stats["Fuel"], sx/2, sy/2 + 90, sx/2, sy/2 + 90 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center", false, false, false, true)
    
    if isInSlot(sx/2 - 100/2, sy/2 + 120, 100, 20) then
        dxDrawText("Bezárás", sx/2, sy/2 + 120, sx/2, sy/2 + 120 + 20, tocolor(rr,rg,rb,255),fontsize, font2, "center", "center")
    else
        dxDrawText("Bezárás", sx/2, sy/2 + 120, sx/2, sy/2 + 120 + 20, tocolor(255,255,255,255),fontsize, font2, "center", "center")
    end
end

local cursorState = isCursorShowing()
cursorX, cursorY = 0,0
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
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
