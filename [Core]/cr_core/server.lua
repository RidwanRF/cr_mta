local ids = {}
white = "#ffffff"
local connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)
local devSerials = {}
local devNames = {}
local syntax = getServerSyntax(false, "success")
local syntax2 = getServerSyntax(false, "warning")
local syntax3 = getServerSyntax(false, "error")
local slot = getMaxPlayers()
local startTime = getRealTime()["timestamp"]

addEventHandler('onResourceStart', resourceRoot,
    function()
	    aclReload()
        
        local res = getResourceFromName("cr_interface")
        if res then
            if getResourceState(res) == "running" then
                restartResource(res)
            elseif getResourceState(res) == "loaded" then
                startResource(res)
            end
        end
        
	    setMapName(serverData['city'])
		setGameType(serverData['mod'] .. " " .. serverData['version'])
		setRuleValue('modversion', serverData['version'])
		setRuleValue('designer', serverData['designer'])
		setRuleValue('developer', serverData['developer'])
        triggerClientEvent(root, "client >> devserials >> saveCache", root, devSerials, devNames)
		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    local name = row["name"]
                    devSerials[serial] = true
                    devNames[serial] = name
                end
            end
			outputDebugString("[Success] Loading devserials has finished successfuly. Loaded: " .. query_lines .. " serials!")
        end, connection, "SELECT * FROM `devserials`")   
	end
)

addEvent("server >> devserials >> getCacheToReturnClient", true)
addEventHandler("server >> devserials >> getCacheToReturnClient", root,
    function(sourcePlayer)
        triggerClientEvent(sourcePlayer, "client >> devserials >> saveCache", sourcePlayer, devSerials, devNames)
    end
)

addEvent("core >> setElementData", true)
addEventHandler("core >> setElementData", root,
    function(element, dataName, value)
        setElementData(element, dataName, value)
    end
)

addEvent("core >> removeElementData", true)
addEventHandler("core >> removeElementData", root,
    function(element, dataName, value)
        removeElementData(element, dataName)
    end
)

function getPlayerDeveloper(player)
    if getElementData(player, "loggedIn") then
        local serial = getPlayerSerial(player)
        if devSerials[serial] then
            return true, devNames[serial]
        else
            return false
        end
    end
end

addEventHandler("onPlayerConnect", root,
    function(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber)
        exports['cr_logs']:addLog(0, "Connect", "connect", playerNick.." connected (IP: "..playerIP..", Username: "..playerUsername..", Serial: "..playerSerial..", Version: "..playerVersionNumber..")")
    end
)

addEventHandler("onPlayerJoin", root,
    function()
        local serial = getPlayerSerial(source)
        setElementData(source, "loggedIn", false)
        setElementData(source, "mtaserial", serial)
        setElementData(source, "serverslot", getMaxPlayers())
        setElementData(source, "startTime", startTime)
        setElementDimension(source, math.random(2, 2000) * math.random(1,5))
        setElementAlpha(source, 0)
        setElementCollisionsEnabled(source, false)
        triggerClientEvent(source, "client >> devserials >> saveCache", source, devSerials, devNames)
        if devSerials[serial] then
            local playerNick = getPlayerName(source)
            local playerUsername = exports['cr_admin']:getAdminName(source, false)
            local playerIP = getPlayerIP(source)
            local playerSerial = serial
            exports['cr_logs']:addLog(0, "Connect", "devconnect", playerNick.."-dev ("..devNames[serial]..") connected (IP: "..playerIP..", Username: "..playerUsername..", Serial: "..playerSerial)
            outputChatBox(syntax .. "Developer serial érzékelve! Üdv a szerveren "..devNames[serial].."!", source, 255, 255, 255, true)
        end
    end
)

addCommandHandler("createdevserial", 
    function(thePlayer, cmd, serial, name)
        local playerSerial = getPlayerSerial(thePlayer)
        if devSerials[playerSerial] then
            if not serial or not name then
                outputChatBox(syntax2 .. "/"..cmd.." [serial] [name]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if devSerials[serial] then
                outputChatBox(syntax3 .. "Ez a serial már rögzítve van devserialként!", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `devserials` SET `serial` = ?, `name` = ?", serial, name)
            devSerials[serial] = true
            devNames[serial] = name
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen hozzáadtad "..green..name..white.."-t ("..green..serial..white..") a devserialokhoz!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." hozzáadta "..green..name..white.."-t ("..green..serial..white..") a devserialokhoz!", 9)
            exports['cr_logs']:addLog(thePlayer, "Admin", "createdevserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." hozzáadta "..name.."-t ("..serial..") a devserialokhoz!")
            triggerClientEvent(root, "client >> devserials >> saveCache", root, devSerials, devNames)
        end
    end
)

addCommandHandler("removedevserial", 
    function(thePlayer, cmd, serial)
        local playerSerial = getPlayerSerial(thePlayer)
        if devSerials[playerSerial] then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not devSerials[serial] then
                outputChatBox(syntax3 .. "A törlendő serialnek devserialnak kell lennie (Ez a serial nem devserial!)", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `devserials` WHERE `serial` = ?", serial)
            local name = devNames[serial]
            devSerials[serial] = false
            devNames[serial] = nil
            triggerClientEvent(root, "client >> devserials >> saveCache", root, devSerials, devNames)
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen kitörölted "..green..name..white.."-t ("..green..serial..white..") a devserialokból!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." kitörölte "..green..name..white.."-t ("..green..serial..white..") a devserialokból!", 9)
            exports['cr_logs']:addLog(thePlayer, "Admin", "removedevserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." kitörölte "..name.."-t ("..serial..") a devserialokból!")
            triggerClientEvent(root, "client >> devserials >> saveCache", root, devSerials, devNames)
        end
    end
)

local _addCommandHandler = addCommandHandler
function addCommandHandler(source, cmd, ...)
	if type(cmd) == "table" then
		for k, v in ipairs(cmd) do
			_addCommandHandler(source, v, ...)
		end
	else
		_addCommandHandler(source, cmd, ...)
	end
end

function outputChatBoxSpecial(element, text)
    if getElementData(element, "admin >> alogDisabled") then
        outputConsole(string.gsub(text, "#%x%x%x%x%x%x", ""), element)
    else
        outputChatBox(text, element, 255,255,255,true)
    end
end
addEvent("outputChatBox", true)
addEventHandler("outputChatBox", root, outputChatBoxSpecial)

function setElementModelSpecial(element, model)
    setElementModel(element, model)
end
addEvent("setElementModelSpecial", true)
addEventHandler("setElementModelSpecial", root, setElementModelSpecial)

function kickedPlayer(element, player, reason)
    kickPlayer(element, player, reason)
end
addEvent("kickedPlayer", true)
addEventHandler("kickedPlayer", root, kickedPlayer)

addEvent("setElementPosition", true)
addEventHandler("setElementPosition", root,
    function(e, x,y,z, dim, int)
        setElementPosition(e, x,y,z)
        if dim then
            setElementDimension(e, dim)
        end
        if int then
            setElementInterior(e, int)
        end
    end
)

addEvent("setElementHealth", true)
addEventHandler("setElementHealth", root,
    function(e, health)
        setElementHealth(e, health)
    end
)

addEvent("destroyElement", true)
addEventHandler("destroyElement", root,
    function(e)
        destroyElement(e)
    end
)

function setPedArmor(element, armor)
    setPedArmor(element, armor)
end

function sendMessageToAdmin(element, text, neededLevel)
    local pair = {}
    for k,v in pairs(getElementsByType("player")) do
        local adminlevel = getElementData(v, "admin >> level") or 0
        if adminlevel >= neededLevel then
            pair[v] = true
        end
    end
    
    for k,v in pairs(pair) do
        outputChatBoxSpecial(k, text)
    end
end

--// MoneyGlobal

function hasMoney(element, money, bankMoney)
    if bankMoney then
        local oldMoney = getElementData(element, "char >> money") or 0
        if oldMoney - money > 0 then
            return true
        else
            return false
        end
    else
        local oldMoney = getElementData(element, "char >> bankmoney") or 0
        if oldMoney - money > 0 then
            return true
        else
            return false
        end
    end
end

function takeMoney(element, money, bankMoney)
    if bankMoney then
        if hasMoney(element, money, false) then
            local oldMoney = getElementData(element, "char >> money") or 0
            setElementData(element, "char >> money", oldMoney - money)
            return true
        else
            return false
        end
    else
        if hasMoney(element, money, true) then
            local oldMoney = getElementData(element, "char >> bankmoney") or 0
            setElementData(element, "char >> bankmoney", oldMoney - money)
            return true
        else
            return false
        end
    end
end

function giveMoney(element, money, bankMoney)
    if bankMoney then
        local oldMoney = getElementData(element, "char >> money") or 0
        setElementData(element, "char >> money", oldMoney + money)
        return true
    else
        local oldMoney = getElementData(element, "char >> bankmoney") or 0
        setElementData(element, "char >> bankmoney", oldMoney + money)
        return true
    end
end