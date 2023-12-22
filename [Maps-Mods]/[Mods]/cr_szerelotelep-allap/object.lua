local replaceModels = {
	{
		["txd"] = "models/szertep.txd",
		["dff"] = "models/szertep.dff",
		["col"] = "models/szertep.col",
		["replaceObject"] = 17582,
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
	
	objNormal = createObject ( 17582, 2739.2188, -1770.0859, 17.55469,0,0,175 ) --1
	
	objLowLOD = createObject ( 17582, 2739.2188, -1770.0859, 17.55469,0,0,175 ,true )

	objNormal:setDimension(-1)
	objLowLOD:setDimension(-1)	
	
	setLowLODElement ( objNormal, objLowLOD )
	
	
	
	engineSetModelLODDistance ( 17582, 3000 )
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

RemoveBuildingForPlayer(playerid, 17582, 2739.2188, -1770.0859, 17.55469, 0.25);