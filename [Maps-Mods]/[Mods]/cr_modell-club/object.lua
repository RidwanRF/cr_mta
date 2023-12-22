local replaceModels = {
	{
		["txd"] = "models/rodeo01_law2.txd",
		["dff"] = "models/club.dff",
		["col"] = "models/club.col",
		["replaceObject"] = 6334,
	},
	{
		["txd"] = "models/rodeo01_law2.txd",
		["dff"] = "models/club.dff",
		["col"] = "models/club.col",
		["replaceObject"] = 6335,
	},
	{
		["txd"] = "models/club_interior.txd",
		["dff"] = "models/club_interior.dff",
		["col"] = "models/club_interior.col",
		["replaceObject"] = 3469,
	},
	{
		["txd"] = "models/club_interior.txd",
		["dff"] = "models/club_interior.dff",
		["col"] = "models/club_interior.col",
		["replaceObject"] = 3523,
	},
}

--[[
removeWorldModel(3469, 10000, 2562.0000, 2210.1875, 12.9375,);--club a levegoben lv vizben
removeWorldModel(3469, 10000, 2617.4609, 2147.9688, 12.9375,);--club a levegoben lv vizben
removeWorldModel(3469, 10000, 2626.1016, 2192.6719, 12.9375,);--club a levegoben lv vizben
removeWorldModel(3469, 10000, 2594.5078, 2198.3125, 12.9375,);--club a levegoben lv vizben
removeWorldModel(3469, 10000, 2650.0000, 2250.7734, 12.9375,);--club a levegoben lv vizben
--]]

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
	objNormal = createObject ( 6334, 472.4375, -1509.4453, 30.1250,0,0,0 )
	objLowLOD = createObject ( 6335, 472.4375, -1509.4453, 30.1250,0,0,0,true )
	
	objNormal:setDimension(-1)
	objLowLOD:setDimension(-1)
	
	objNormal = createObject ( 3469, 472.4375, -1509.4453, 30.1250,0,0,0 )
	objLowLOD = createObject ( 3523, 472.4375, -1509.4453, 30.1250,0,0,0,true )
	setLowLODElement ( objNormal, objLowLOD )
	
	objNormal:setDimension(-1)
	objLowLOD:setDimension(-1)
	
	engineSetModelLODDistance ( 6335, 3000 )
	engineSetModelLODDistance ( 3523, 3000 )
end
)



function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

RemoveBuildingForPlayer(playerid, 6335, 472.4375, -1509.4453, 30.1250, 0.25);
RemoveBuildingForPlayer(playerid, 6334, 472.4375, -1509.4453, 30.1250, 0.25);
RemoveBuildingForPlayer(playerid, 3469, 472.4375, -1509.4453, 30.1250, 0.25);
RemoveBuildingForPlayer(playerid, 3523, 472.4375, -1509.4453, 30.1250, 0.25);


