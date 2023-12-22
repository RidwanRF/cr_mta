local replaceModels = {
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/winewood.dff",
		["col"] = "models/winewood.col",
		["replaceObject"] = 13722,
	},
	{
		["txd"] = "models/texture.txd",
		["dff"] = "models/winewood.dff",
		["col"] = "models/winewood.col",
		["replaceObject"] = 13759,
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
	objNormal = createObject ( 13722, 1413.4141, -804.7422, 83.4375,0,0,0 )
	objLowLOD = createObject ( 13759, 1413.4141, -804.7422, 83.4375,0,0,0,true )
	setLowLODElement ( objNormal, objLowLOD )
	engineSetModelLODDistance ( 13759, 3000 )
end
)



function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

RemoveBuildingForPlayer(playerid, 13759, 1413.4141, -804.7422, 83.4375, 0.25);
RemoveBuildingForPlayer(playerid, 13722, 1413.4141, -804.7422, 83.4375, 0.25);
RemoveBuildingForPlayer(playerid, 13831, 1413.4141, -804.7422, 83.4375, 0.25);