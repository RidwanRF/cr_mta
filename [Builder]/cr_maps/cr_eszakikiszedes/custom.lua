addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	
	local dff = engineLoadDFF("sunset21_lawn.dff", 5853)
	engineReplaceModel(dff, 5853)
	
	local col = engineLoadCOL("sunset21_lawn.col")
	engineReplaceCOL(col, 5853)
	
	engineSetModelLODDistance(5853, 500)
end
)



