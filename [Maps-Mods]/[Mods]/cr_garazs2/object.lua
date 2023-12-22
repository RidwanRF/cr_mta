

addEventHandler("onClientResourceStart", resourceRoot,
function()

	local txd = engineLoadTXD("models/garazs.txd") -- txd neve
	engineImportTXD(txd, 14798)	
	
	local dff = engineLoadDFF("models/garazs.dff", 14798) -- dff neve
	engineReplaceModel(dff, 14798)
	
	local col = engineLoadCOL("models/garazs.col") -- col neve
	engineReplaceCOL(col, 14798)
	
	engineSetModelLODDistance(14798, 10000)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/tolo.txd") -- txd neve
	engineImportTXD(txd, 14797)	
	
	local dff = engineLoadDFF("models/tolo.dff", 14797) -- dff neve
	engineReplaceModel(dff, 14797)
	
	local col = engineLoadCOL("models/tolo.col") -- col neve
	engineReplaceCOL(col, 14797)	
	
	engineSetModelLODDistance(14797, 1)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()

	local txd = engineLoadTXD("models/nagygarazs.txd") -- txd neve
	engineImportTXD(txd, 14783)	
	
	local dff = engineLoadDFF("models/nagygarazs.dff", 14783) -- dff neve
	engineReplaceModel(dff, 14783)
	
	local col = engineLoadCOL("models/nagygarazs.col") -- col neve
	engineReplaceCOL(col, 14783)
	
	engineSetModelLODDistance(14783, 10000)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/tolo.txd") -- txd neve
	engineImportTXD(txd, 14796)	
	
	local dff = engineLoadDFF("models/tolo.dff", 14796) -- dff neve
	engineReplaceModel(dff, 14796)
	
	local col = engineLoadCOL("models/tolo.col") -- col neve
	engineReplaceCOL(col, 14796)
	
	
	engineSetModelLODDistance(14796, 1)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()

	
	local txd = engineLoadTXD("models/tolo.txd") -- txd neve
	engineImportTXD(txd, 14826)	
	
	local dff = engineLoadDFF("models/tolo.dff", 14826) -- dff neve
	engineReplaceModel(dff, 14826)
	
	local col = engineLoadCOL("models/tolo.col") -- col neve
	engineReplaceCOL(col, 14826)
	
	
	engineSetModelLODDistance(14826, 1)     
end
)