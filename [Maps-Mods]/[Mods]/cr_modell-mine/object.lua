local replaceModels = {
	{
		["txd"] = "models/des_stownw.txd",
		["dff"] = "models/bridge.dff",
		["col"] = "models/bridge.col",
		["replaceObject"] = 16029,
	},
	{
		["txd"] = "models/des_stownw.txd",
		["dff"] = "models/bridge.dff",
		["col"] = "models/bridge.col",
		["replaceObject"] = 16524,
	},
	
	{
		["txd"] = "models/cs_mountain.txd",
		["dff"] = "models/mine.dff",
		["col"] = "models/mine.col",
		["replaceObject"] = 18299,
	},
	{
		["txd"] = "models/cs_mountain.txd",
		["dff"] = "models/mine.dff",
		["col"] = "models/mine.col",
		["replaceObject"] = 18587,
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
	
	objNormal = createObject ( 16029, -2192.2998046875, -1109.2998046875, 21.89999961853,0,0,209.49279785156 )
	objLowLOD = createObject ( 16524, -2192.2998046875, -1109.2998046875, 21.89999961853,0,0,209.49279785156,true )
	
	objNormal:setDimension(-1)
	objLowLOD:setDimension(-1)	
	
	objNormal = createObject ( 18299, -2186.7500, -1147.7344, 108.1563,0,0,0)
	objLowLOD = createObject ( 18587, -2186.7500, -1147.7344, 108.1563,0,0,0,true )
	
	setLowLODElement ( objNormal, objLowLOD )
	
	objNormal:setDimension(-1)
	objLowLOD:setDimension(-1)	
	
	engineSetModelLODDistance ( 16524, 3000 )
	engineSetModelLODDistance ( 18587, 3000 )
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

RemoveBuildingForPlayer(playerid, 785, -2231.6172, -1113.8125, 13.5625, 0.25);
RemoveBuildingForPlayer(playerid, 784, -2209.0078, -1142.4531, 18.3359, 0.25);
RemoveBuildingForPlayer(playerid, 791, -2231.6172, -1113.8125, 13.5625, 0.25);
RemoveBuildingForPlayer(playerid, 694, -2209.0078, -1142.4531, 18.3359, 0.25);
RemoveBuildingForPlayer(playerid, 18587, -2186.7500, -1147.7344, 108.1563, 0.25);
RemoveBuildingForPlayer(playerid, 18299, -2186.7500, -1147.7344, 108.1563, 0.25);


