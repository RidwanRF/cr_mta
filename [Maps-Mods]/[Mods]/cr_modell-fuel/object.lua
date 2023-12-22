

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 5409)
	
	local dff = engineLoadDFF("models/deli.dff", 5409) -- dff neve
	engineReplaceModel(dff, 5409)
	
	local col = engineLoadCOL("models/deli.col") -- col neve
	engineReplaceCOL(col, 5409)
	
	engineSetModelLODDistance(5409, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 9169)
	
	local dff = engineLoadDFF("models/eszaki.dff", 9169) -- dff neve
	engineReplaceModel(dff, 9169)
	
	local col = engineLoadCOL("models/deli.col") -- col neve
	engineReplaceCOL(col, 9169)
	
	engineSetModelLODDistance(9169, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/pumpfix.txd") -- txd neve
	engineImportTXD(txd, 3465)
	
	local dff = engineLoadDFF("models/pumpfix.dff", 3465) -- dff neve
	engineReplaceModel(dff, 3465)
	
	local col = engineLoadCOL("models/pumpfix.col") -- col neve
	engineReplaceCOL(col, 3465)
	
	engineSetModelLODDistance(3465, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/pumpbenzin.txd") -- txd neve
	engineImportTXD(txd, 7584)
	
	local dff = engineLoadDFF("models/pump.dff", 7584) -- dff neve
	engineReplaceModel(dff, 7584)
	
	local col = engineLoadCOL("models/pump.col") -- col neve
	engineReplaceCOL(col, 7584)
	
	engineSetModelLODDistance(7584, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/pumpdiesel.txd") -- txd neve
	engineImportTXD(txd, 7585)
	
	local dff = engineLoadDFF("models/pump.dff", 7585) -- dff neve
	engineReplaceModel(dff, 7585)
	
	local col = engineLoadCOL("models/pump.col") -- col neve
	engineReplaceCOL(col, 7585)
	
	engineSetModelLODDistance(7585, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/tesla.txd") -- txd neve
	engineImportTXD(txd, 3464)
	
	local dff = engineLoadDFF("models/tesla.dff", 3464) -- dff neve
	engineReplaceModel(dff, 3464)
	
	local col = engineLoadCOL("models/tesla.col") -- col neve
	engineReplaceCOL(col, 3464)
	
	engineSetModelLODDistance(3464, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/tesla.txd") -- txd neve
	engineImportTXD(txd, 3460)
	
	local dff = engineLoadDFF("models/tesla_place.dff", 3460) -- dff neve
	engineReplaceModel(dff, 3460)
	
	local col = engineLoadCOL("models/tesla_place.col") -- col neve
	engineReplaceCOL(col, 3460)
	
	engineSetModelLODDistance(3460, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local col = engineLoadCOL("models/roadFix.col") -- col neve
	engineReplaceCOL(col, 5489)
	
	engineSetModelLODDistance(5489, 500)     
end
)