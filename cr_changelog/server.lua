local connection = exports.cr_mysql;
local changes = {};

addEventHandler("onResourceStart", resourceRoot, function()
    dbQuery(function(queryHandler)
        local results, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

        if numAffectedRows > 0 then
            for key, value in pairs(results) do
                table.insert(changes, {value.id, value.created, value.added_by, value.script_name, value.msg});
            end
        end
        outputDebugString(numAffectedRows .. " changelog(s) loaded");
    end, connection:requestConnection(), "SELECT * FROM changelog");
end);

addCommandHandler("addnote", function(player, cmd, scriptname, name, ...)
    if exports.cr_permission:hasPermission(player, cmd) then
        local syntax = exports.cr_core:getServerSyntax(false, "error");

        if not ... then
            outputChatBox(syntax.."Parancs használata: /" .. cmd .. " [Script neve] [Készítő] [Leírás]", player, 255, 255, 255, true); 
        else
            dbExec(connection:requestConnection(), "INSERT INTO changelog SET added_by=?, script_name=?, msg=?", name, scriptname, table.concat({...}, " "));
            outputChatBox("#cc0000[STAYMTA] #ffffffÚj fejlesztési jegyzet lett hozzáadva #cc0000" .. name .. " #ffffffáltal.", root, 0, 0, 0, true);
        end
    end
end);