local whitelist = {}
local connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
	        connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
	end
)

--local blockedSerials = {}
local white = "#ffffff"
local syntax = exports['cr_core']:getServerSyntax(false, "success")
local syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
local syntax3 = exports['cr_core']:getServerSyntax(false, "error")
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
	        syntax = exports['cr_core']:getServerSyntax(false, "success")
            syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
            syntax3 = exports['cr_core']:getServerSyntax(false, "error")
        end
	end
)

addEventHandler('onResourceStart', resourceRoot,
    function()		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    local name = row["name"]
                    --outputChatBox(name .. "->"..serial)
                    whitelist[serial] = name
                end
            end
			outputDebugString("[Success] Loading whitelist has finished successfuly. Loaded: " .. query_lines .. " serials!")
        end, connection, "SELECT * FROM `whitelist`")
	end
)

addEventHandler("onPlayerConnect", root,
    function(_,_,_,serial)
        if not whitelist[serial] then
            cancelEvent(true, "Rendszer \n A te serialod nincs engedélyezve ezen a szerveren! (Whitelist)")
        end
    end
)

addCommandHandler("addWhitelist", 
    function(thePlayer, cmd, serial, name)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial or not name then
                outputChatBox(syntax2 .. "/"..cmd.." [serial] [name]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if whitelist[serial] then
                outputChatBox(syntax3 .. "Ez a serial már hozzá lett adva whitelisthez!", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `whitelist` SET `serial` = ?, `name` = ?", serial, name)
            whitelist[serial] = true
            local aName = exports['cr_admin']:getAdminName(thePlayer, false)
            local green = exports['cr_core']:getServerColor(nil, true)
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." hozzáadta a(z) "..green..name..white.."-t a whitelisthez!", 9)
            outputChatBox(syntax .. "Sikeresen hozzáadtad "..name.."-t a whitelisthez!", thePlayer, 255, 255, 255, true)
            exports['cr_logs']:addLog(thePlayer, "Admin", "addWhitelist", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." hozzáadta a(z) "..name.."-t ("..serial..") a whitelisthez!")
        end
    end
)

addCommandHandler("removeWhitelist", 
    function(thePlayer, cmd, serial)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not whitelist[serial] then
                outputChatBox(syntax3 .. "Ez a serial nem szerepel a whitelisten!", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `whitelist` WHERE `serial` = ?", serial)
            outputChatBox(syntax .. "Sikeresen kitörölted a "..whitelist[serial].."-t a whitelistből!", thePlayer, 255, 255, 255, true)
            local aName = exports['cr_admin']:getAdminName(thePlayer, false)
            local green = exports['cr_core']:getServerColor(nil, true)
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." törölte a(z) "..green..whitelist[serial]..white.."-t a whitelistből!", 9)
            exports['cr_logs']:addLog(thePlayer, "Admin", "removeWhitelist", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." törölte a(z) "..whitelist[serial].."-t a whitelistből!")
            whitelist[serial] = nil
        end
    end
)