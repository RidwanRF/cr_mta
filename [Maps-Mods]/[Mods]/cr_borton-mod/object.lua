local replaceModels = {
	{
		["txd"] = "models/borton.txd",
		["dff"] = "models/borton.dff",
		["col"] = "models/borton.col",
		["replaceObject"] = 9206,
	},
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	for index, value in pairs(getElementsByType("player")) do
		setElementFrozen(value, true)
		setTimer(function() 
			setElementFrozen(value, false)
		end, 5000, 1)
	end
	for i, v in pairs(replaceModels) do
		local txd = engineLoadTXD(v["txd"])
		engineImportTXD(txd, v["replaceObject"])
		local dff = engineLoadDFF(v["dff"], v["replaceObject"])
		engineReplaceModel(dff, v["replaceObject"], true)
		local col = engineLoadCOL(v["col"])
		engineReplaceCOL(col, v["replaceObject"])
		-- setElementStreamable(v["replaceObject"], false)
	end
	
	objNormal = createObject ( 9206, -3978.8994, 1332.7002, 30,0,0,179.995 ) --1
	
	objLowLOD = createObject ( 9206, -3978.8994, 1332.7002, 30,0,0,179.995 ,true )

	
	
	setLowLODElement ( objNormal, objLowLOD )
	
	engineSetModelLODDistance ( 9206, 3000 )
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end