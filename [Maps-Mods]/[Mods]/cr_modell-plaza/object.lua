
addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/shops2_law.txd") -- txd neve
	engineImportTXD(txd, 6061)
	
	local dff = engineLoadDFF("models/plaza.dff", 6061) -- dff neve
	engineReplaceModel(dff, 6061, true)
	
	local col = engineLoadCOL("models/plaza.col") -- col neve
	engineReplaceCOL(col, 6061)
	
	engineSetModelLODDistance(6061, 500)
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/shops2_law.txd") -- txd neve
	engineImportTXD(txd, 6060)
	
	local dff = engineLoadDFF("models/plazasecondfloor.dff", 6060) -- dff neve
	engineReplaceModel(dff, 6060, true)
	
	local col = engineLoadCOL("models/plazasecondfloor.col") -- col neve
	engineReplaceCOL(col, 6060)
	
	engineSetModelLODDistance(6060, 500)
end
)

setOcclusionsEnabled( false )
engineSetAsynchronousLoading ( true, true )