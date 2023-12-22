addEventHandler("onDebugMessage", root, function(dbMsg, dbLevel, dbFile, dbLine)
	triggerClientEvent(root, "debug->Add", root, dbMsg or "", dbLevel or 0, dbFile or 0, dbLine or 0)
end)