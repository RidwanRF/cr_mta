
addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 3980)
	
	local dff = engineLoadDFF("models/vh.dff", 3980) -- dff neve
	engineReplaceModel(dff, 3980, true)
	
	local col = engineLoadCOL("models/vh.col") -- col neve
	engineReplaceCOL(col, 3980)
	
	engineSetModelLODDistance(3980, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 11609)
	
	local dff = engineLoadDFF("models/lift.dff", 11609) -- dff neve
	engineReplaceModel(dff, 11609, true)
	
	local col = engineLoadCOL("models/lift.col") -- col neve
	engineReplaceCOL(col, 11609)
	
	engineSetModelLODDistance(11609, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 13863)
	
	local dff = engineLoadDFF("models/door.dff", 13863) -- dff neve
	engineReplaceModel(dff, 13863, true)
	
	local col = engineLoadCOL("models/door.col") -- col neve
	engineReplaceCOL(col, 13863)
	
	engineSetModelLODDistance(13863, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/texture.txd") -- txd neve
	engineImportTXD(txd, 3053)
	
	local dff = engineLoadDFF("models/table.dff", 3053) -- dff neve
	engineReplaceModel(dff, 3053, true)
	
	local col = engineLoadCOL("models/table.col") -- col neve
	engineReplaceCOL(col, 3053)
	
	engineSetModelLODDistance(3053, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		createObject(11609, 1465.235, -1800.31, 18.975, 0, 0, 0)
		createObject(11609, 1465.235, -1800.31, 22.6, 0, 0, 0)
	end
)

setOcclusionsEnabled( false )
engineSetAsynchronousLoading ( true, true )