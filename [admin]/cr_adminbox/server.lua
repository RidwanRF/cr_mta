function showAdminBox(text, type, consoleText)
    --outputChatBox("")
    triggerClientEvent(root, "showAdminBox", root, text, type)
    for k,v in pairs(consoleText) do
        outputConsole(v)
    end
end
addEvent("showAdminBox", true)
addEventHandler("showAdminBox", root, showAdminBox)