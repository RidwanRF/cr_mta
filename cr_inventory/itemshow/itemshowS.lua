function itemShowTrigger(sourceElement, v, data)
    triggerClientEvent(v, "itemShowTrigger", v, sourceElement, v, data)
end
addEvent("itemShowTrigger", true)
addEventHandler("itemShowTrigger", root, itemShowTrigger)