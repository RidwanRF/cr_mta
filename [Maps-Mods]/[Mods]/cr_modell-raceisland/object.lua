local replaceModels = {
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/1.dff",
		["col"] = "models/1.col",
		["replaceObject"] = 16199,
	},
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/2.dff",
		["col"] = "models/2.col",
		["replaceObject"] = 16205,
	},
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/3.dff",
		["col"] = "models/3.col",
		["replaceObject"] = 16198,
	},
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/4.dff",
		["col"] = "models/4.col",
		["replaceObject"] = 16102,
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
	
	objNormal = createObject ( 16199, 261.7002, 638.40039, 0.5,0,0,123.997 ) --1
	objNormal = createObject ( 16205, 468.79004, 778.09961, 0.509,0,0,123.997 ) --2
	objNormal = createObject ( 16198, 329.09961, 985.2002, 0.5,0,0,124 ) --3
	objNormal = createObject ( 16102, 121.90039, 845.59961, 0.5,0,0,123.997 ) --4
	
	objLowLOD = createObject ( 16199, 261.7002, 638.40039, 0.5,0,0,123.997,true )
	objLowLOD = createObject ( 16205, 468.79004, 778.09961, 0.509,0,0,123.997,true )
	objLowLOD = createObject ( 16198, 329.09961, 985.2002, 0.5,0,0,124,true )
	objLowLOD = createObject ( 16102, 121.90039, 845.59961, 0.5,0,0,123.997,true )
	
	
	setLowLODElement ( objNormal, objLowLOD )
	
	engineSetModelLODDistance ( 16199, 3000 )
	engineSetModelLODDistance ( 16205, 3000 )
	engineSetModelLODDistance ( 16198, 3000 )
	engineSetModelLODDistance ( 16102, 3000 )
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

