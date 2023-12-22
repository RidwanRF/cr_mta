function addLog(sourceElement, folder, type, text)
    triggerServerEvent("addLog", localPlayer, sourceElement, folder, type, text)
    return true
end

function clearLog(folder, type)
    triggerServerEvent("clearLog", localPlayer, folder, type)
    return true
end