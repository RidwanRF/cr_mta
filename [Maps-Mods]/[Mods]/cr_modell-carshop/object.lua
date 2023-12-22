local replaceModels = {
	{
		["txd"] = "models/carshop.txd",
		["dff"] = "models/carshop.dff",
		["col"] = "models/carshop.col",
		["replaceObject"] = 7554,
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
	objNormal = createObject ( 7554, 1950.6999511719, -2381.8999023438, 16.4,0,0,0 )
	--objLowLOD = createObject ( 6335, 472.4375, -1509.4453, 30.1250,0,0,0,true )
	
	--setLowLODElement ( objNormal, objLowLOD )
	
	engineSetModelLODDistance ( 7554, 3000 )
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

