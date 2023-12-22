addEventHandler("onDebugMessage", root, 
    function(message, level, file, line, r,g,b)
        triggerClientEvent(root, "addDebugText", root, message, level, file, line, "server", r,g,b)
    end
)
