
addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 5708)
	
	local dff = engineLoadDFF("models/hospital.dff", 5708) -- dff neve
	engineReplaceModel(dff, 5708)
	
	local col = engineLoadCOL("models/hospital.col") -- col neve
	engineReplaceCOL(col, 5708)
	
	engineSetModelLODDistance(5708, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local col = engineLoadCOL("models/roadFix.col") -- col neve
	engineReplaceCOL(col, 5808)
	
	engineSetModelLODDistance(5808, 500)     
end
)

setOcclusionsEnabled( false )
engineSetAsynchronousLoading ( true, true )