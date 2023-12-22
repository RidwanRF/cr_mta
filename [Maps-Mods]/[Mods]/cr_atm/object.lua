

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/ATM.txd") -- txd neve
	engineImportTXD(txd, 2942)
	
	local dff = engineLoadDFF("models/ATM.dff", 2942) -- dff neve
	engineReplaceModel(dff, 2942)
	
	local col = engineLoadCOL("models/ATM.col") -- col neve
	engineReplaceCOL(col, 2942)
	
	engineSetModelLODDistance(2942, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/ATM2.txd") -- txd neve
	engineImportTXD(txd, 2943)
	
	local dff = engineLoadDFF("models/ATM2.dff", 9169) -- dff neve
	engineReplaceModel(dff, 2943)
	
	local col = engineLoadCOL("models/ATM2.col") -- col neve
	engineReplaceCOL(col, 2943)
	
	engineSetModelLODDistance(2943, 500)     
end
)
