

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local dff = engineLoadDFF("models/int3int_carupg_int.dff", 14776) -- dff neve
	engineReplaceModel(dff, 14776)
	
	local col = engineLoadCOL("models/int3int_carupg_int.col") -- col neve
	engineReplaceCOL(col, 14776)
	
	engineSetModelLODDistance(14776, 500)     
end
)
