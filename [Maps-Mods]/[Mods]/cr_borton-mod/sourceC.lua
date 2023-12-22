

addEventHandler("onClientResourceStart", resourceRoot,
function()

local txd = engineLoadTXD("mods/borton.txd") -- txd neve
	engineImportTXD(txd, 9206)
	
	local dff = engineLoadDFF("mods/borton.dff", 9206) -- dff neve
	engineReplaceModel(dff, 9206)
	
	local col = engineLoadCOL("mods/borton.col") -- col neve
	engineReplaceCOL(col, 9206)
	
	

	engineSetModelLODDistance(modelid, 9206)     
end
)

