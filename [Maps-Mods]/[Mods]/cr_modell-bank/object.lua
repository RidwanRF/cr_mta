addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/alap.txd") -- txd neve
	engineImportTXD(txd, 6340)
	local dff = engineLoadDFF("models/alap.dff", 6340) -- dff neve
	engineReplaceModel(dff, 6340)
	local col = engineLoadCOL("models/alap.col") -- col neve
	engineReplaceCOL(col, 6340)
	engineSetModelLODDistance(6340, 500)
	
	objNormal = createObject ( 6340, 588.1797, -1530.4688, 25.5938, 0,0,0 )
	--objLowLOD = createObject ( 6480, 588.1797, -1530.4688, 25.5938, 0,0,0,true )
	
	--setLowLODElement ( objNormal, objLowLOD )
	
	objNormal:setDimension(-1)	
	
	engineSetModelLODDistance ( 6340, 3000 )
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/bank.txd") -- txd neve
	engineImportTXD(txd, 10040)
	local dff = engineLoadDFF("models/bank.dff", 10040) -- dff neve
	engineReplaceModel(dff, 10040)
	local col = engineLoadCOL("models/bank.col") -- col neve
	engineReplaceCOL(col, 10040)
	engineSetModelLODDistance(10040, 500)
	
	objNormal = createObject ( 10040, 588.1797, -1530.4688, 25.5938, 0,0,0 )
	--objLowLOD = createObject ( 3831, 588.1797, -1530.4688, 25.5938, 0,0,0,true )
	
	--setLowLODElement ( objNormal, objLowLOD )
	objNormal:setDimension(-1)	
	
	engineSetModelLODDistance ( 10040, 3000 )
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/jammer.txd") -- txd neve
	engineImportTXD(txd, 16044)
	local dff = engineLoadDFF("models/jammer.dff", 16044) -- dff neve
	engineReplaceModel(dff, 16044)
	local col = engineLoadCOL("models/jammer.col") -- col neve
	engineReplaceCOL(col, 16044)
	engineSetModelLODDistance(16044, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/laptop.txd") -- txd neve
	engineImportTXD(txd, 1277)
	local dff = engineLoadDFF("models/laptop.dff", 1277) -- dff neve
	engineReplaceModel(dff, 1277)
	local col = engineLoadCOL("models/laptop.col") -- col neve
	engineReplaceCOL(col, 1277)
	engineSetModelLODDistance(1277, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/adam_v_door.txd") -- txd neve
	engineImportTXD(txd, 2944)
	local dff = engineLoadDFF("models/adam_v_door.dff", 2944) -- dff neve
	engineReplaceModel(dff, 2944)
	local col = engineLoadCOL("models/adam_v_door.col") -- col neve
	engineReplaceCOL(col, 2944)
	engineSetModelLODDistance(2944, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/drill.txd") -- txd neve
	engineImportTXD(txd, 2061)
	local dff = engineLoadDFF("models/drill.dff", 2061) -- dff neve
	engineReplaceModel(dff, 2061)
	local col = engineLoadCOL("models/drill.col") -- col neve
	engineReplaceCOL(col, 2061)
	engineSetModelLODDistance(2061, 500)     
end
)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	
	local txd = engineLoadTXD("models/rcbandit.txd") -- txd neve
	engineImportTXD(txd, 441)
	local dff = engineLoadDFF("models/rcbandit.dff", 441) -- dff neve
	engineReplaceModel(dff, 441)
	engineSetModelLODDistance(441, 500)     
end
)


function RemoveBuildingForPlayer (player, id, x, y, z, radius)
	removeWorldModel(id,radius,x,y,z)
end

RemoveBuildingForPlayer(playerid, 6480, 588.1797, -1530.4688, 25.5938, 0.25);
RemoveBuildingForPlayer(playerid, 1529, 583.4609, -1502.1094, 16.0000, 0.25);
RemoveBuildingForPlayer(playerid, 1266, 591.7266, -1508.9297, 25.3125, 0.25);
RemoveBuildingForPlayer(playerid, 673, 559.6719, -1569.0000, 12.1719, 0.25);
RemoveBuildingForPlayer(playerid, 700, 558.7656, -1556.6641, 15.0703, 0.25);
RemoveBuildingForPlayer(playerid, 625, 557.2578, -1548.9141, 15.1719, 0.25);
RemoveBuildingForPlayer(playerid, 625, 557.2578, -1532.7734, 14.7188, 0.25);
RemoveBuildingForPlayer(playerid, 6340, 588.1797, -1530.4688, 25.5938, 0.25);
RemoveBuildingForPlayer(playerid, 6370, 570.2031, -1530.4141, 23.6641, 0.25);
RemoveBuildingForPlayer(playerid, 625, 557.1016, -1523.8125, 14.3828, 0.25);
RemoveBuildingForPlayer(playerid, 625, 556.2109, -1516.7813, 14.3438, 0.25);
RemoveBuildingForPlayer(playerid, 625, 556.2109, -1500.3906, 14.3438, 0.25);
RemoveBuildingForPlayer(playerid, 625, 557.1016, -1490.0156, 14.2031, 0.25);
RemoveBuildingForPlayer(playerid, 1260, 591.7266, -1508.9297, 25.3047, 0.25);
