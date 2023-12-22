function isKnow(who, id)
    local friendTable = who:getData("friends") or {}
    if friendTable[tonumber(id)] then
        return true
    else
        return false
    end
end

addEvent("nametag->goToServer", true)
addEventHandler("nametag->goToServer", root, 
    function(e, id, e2)
        triggerClientEvent(e, "nametag->goToClient", e, id, e2)
    end
)