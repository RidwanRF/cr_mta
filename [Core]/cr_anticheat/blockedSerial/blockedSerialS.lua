local blockedSerials = {}
local white = "#ffffff"

addEventHandler('onResourceStart', resourceRoot,
    function()		
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local serial = row["serial"]
                    blockedSerials[serial] = true
                end
            end
			outputDebugString("[Success] Loading blockedserials has finished successfuly. Loaded: " .. query_lines .. " serials!")
        end, connection, "SELECT * FROM `blockedserials`")
	end
)

addEventHandler("onPlayerConnect", root,
    function(_,_,_,serial)
        --outputChatBox(serial)
        if blockedSerials[serial] then
            cancelEvent(true, "Sikertelen csatlakozás (Error: C20)")
        end
    end
)

addCommandHandler("createblockedserial", 
    function(thePlayer, cmd, serial)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if blockedSerials[serial] then
                outputChatBox(syntax3 .. "A serial melyet blockolni szeretnél már blockolva van", thePlayer, 255, 255, 255, true)
                return
            end
            
            dbExec(connection, "INSERT INTO `blockedserials` SET `serial` = ?", serial)
            blockedSerials[serial] = true
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen hozzáadtad a(z) "..green..serial..white.."-t a blockedserialokhoz!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." hozzáadta a(z) "..green..serial..white.."-t a blockedserialokhoz!", 9)
            local time = exports['cr_core']:getTime() .. " "
            exports['cr_logs']:addLog(thePlayer, "Admin", "createblockedserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." hozzáadta a(z) "..serial.."-t a blockedserialokhoz!")
        end
    end
)

addCommandHandler("removeblockedserial", 
    function(thePlayer, cmd, serial)
        --local playerSerial = getPlayerSerial(thePlayer)
        if exports['cr_core']:getPlayerDeveloper(thePlayer) then
            if not serial then
                outputChatBox(syntax2 .. "/"..cmd.." [serial]", thePlayer, 255, 255, 255, true)
                return
            end
            
            if not blockedSerials[serial] then
                outputChatBox(syntax3 .. "A törlendő serialnak blockedserialnak kell lennie (Ez a serial nem blockedserial!)", thePlayer, 255, 255, 255, true)
                return
            end
            dbExec(connection, "DELETE FROM `blockedserials` WHERE `serial` = ?", serial)
            blockedSerials[serial] = false
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            local aName = exports['cr_admin']:getAdminName(thePlayer, true)
            outputChatBox(syntax .. "Sikeresen törölted a(z) "..green..serial..white.."-t a blockedserialokból!", thePlayer, 255, 255, 255, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(thePlayer, syntax..green..aName..white.." törölte a(z) "..green..serial..white.."-t a blockedserialokból!", 9)
            local time = exports['cr_core']:getTime() .. " "
            exports['cr_logs']:addLog(thePlayer, "Admin", "removeblockedserial", (tonumber(getElementData(thePlayer, "acc >> id")) or inspect(thePlayer)) .." törölte a(z) "..serial.."-t a blockedserialokból!")
        end
    end
)