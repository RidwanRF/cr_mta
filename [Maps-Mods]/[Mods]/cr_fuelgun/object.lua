

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/fuelgun.txd") -- txd neve
	engineImportTXD(txd, 321)
	
	local dff = engineLoadDFF("models/fuelgun.dff", 321) -- dff neve
	engineReplaceModel(dff, 321)

	
	engineSetModelLODDistance(321, 500)     
end
)
