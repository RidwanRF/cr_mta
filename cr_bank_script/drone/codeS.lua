local drones = {};
local jammers = {};

function accelerateDrone(player, key, state)
	state = state == "down" and true or false
	local ped = drones[player:getData("drone >> controlled")][2]
	if(isElement(ped)) then
		triggerClientEvent(root, "accelerateDrone", resourceRoot, ped, state)
	end
end

function reverseDrone(player, key, state)
	state = state == "down" and true or false
	local ped = drones[player:getData("drone >> controlled")][2]
	if(isElement(ped)) then
		triggerClientEvent(root, "reverseDrone", resourceRoot, ped, state)
	end
end

function leftDrone(player, key, state)
	state = state == "down" and true or false
	local ped = drones[player:getData("drone >> controlled")][2]
	if(isElement(ped)) then
		triggerClientEvent(root, "leftDrone", resourceRoot, ped, state)
	end
end

function rightDrone(player, key, state)
	state = state == "down" and true or false
	local ped = drones[player:getData("drone >> controlled")][2]
	if(isElement(ped)) then
		triggerClientEvent(root, "rightDrone", resourceRoot, ped, state)
	end
end

addEvent("exitDrone", true)
function exitDrone(player)
	unbindKey(player, "w", "down", accelerateDrone)
	unbindKey(player, "w", "up", accelerateDrone)
	unbindKey(player, "s", "down", reverseDrone)
	unbindKey(player, "s", "up", reverseDrone)
	unbindKey(player, "a", "down", leftDrone)
	unbindKey(player, "a", "up", leftDrone)
	unbindKey(player, "d", "down", rightDrone)
	unbindKey(player, "d", "up", rightDrone)
	unbindKey(player, "backspace", "down", exitDrone)
	triggerClientEvent(player, "exitDrone", resourceRoot)
	local veh = drones[player:getData("drone >> controlled")][1]
	veh:setData("drone >> owner", false)
	player:setData("drone >> controlled", false)
end
addEventHandler("exitDrone", resourceRoot, exitDrone)

addEvent("createDrone", true)
function createDrone(player)
	if(not player:getData("drone >> controlled")) then
		local pos = player:getPosition()
		local veh = createVehicle(vehicleID, pos.x, pos.y, pos.z)
		veh:setColor(0, 0, 0)
		veh:setData("drone >> id", #drones+1)
		veh:setData("drone >> isDrone", true)
		veh:setData("drone >> owner", player:getData("acc >> id"))
		local ped = createPed(1, 0, 0, 0)
		ped:setAlpha(0)
		ped:warpIntoVehicle(veh)
		ped:setData("drone >> id", #drones+1)
		ped:setData("drone >> controller", true)
		table.insert(drones, {veh, ped, timer})
		player:setData("drone >> controlled", #drones)
		bindKey(player, "w", "down", accelerateDrone)
		bindKey(player, "w", "up", accelerateDrone)
		bindKey(player, "s", "down", reverseDrone)
		bindKey(player, "s", "up", reverseDrone)
		bindKey(player, "a", "down", leftDrone)
		bindKey(player, "a", "up", leftDrone)
		bindKey(player, "d", "down", rightDrone)
		bindKey(player, "d", "up", rightDrone)
		setTimer(function(p) 
			bindKey(p, "backspace", "down", exitDrone)
		end, 3500, 1, player)
		triggerClientEvent(player, "intializeCamera", resourceRoot, veh, ped)
		toggleAllControls(player, false, true, true)
		-- player:setFrozen(true)
	else
		player:outputChat("Neked már van drónod.", 255, 0, 0, true)
	end
end
addEventHandler("createDrone", getRootElement(), createDrone)
addCommandHandler("createdrone", createDrone)

addEvent("initializeDroneControls", true)
addEventHandler("initializeDroneControls", resourceRoot, function(drone)
	local player = client
	local veh, ped = unpack(drones[drone:getData("drone >> id")])
	player:setData("drone >> controlled", drone:getData("drone >> id"))
	veh:setData("drone >> owner", player:getData("acc >> id"))
	bindKey(player, "w", "down", accelerateDrone)
	bindKey(player, "w", "up", accelerateDrone)
	bindKey(player, "s", "down", reverseDrone)
	bindKey(player, "s", "up", reverseDrone)
	bindKey(player, "a", "down", leftDrone)
	bindKey(player, "a", "up", leftDrone)
	bindKey(player, "d", "down", rightDrone)
	bindKey(player, "d", "up", rightDrone)
	bindKey(player, "backspace", "down", exitDrone)
	triggerClientEvent(player, "intializeCamera", resourceRoot, veh, ped)
	toggleAllControls(player, false, true, true)
end)

addEvent("updateDronePositionToNotSyncedPlayers", true)
addEventHandler("updateDronePositionToNotSyncedPlayers", resourceRoot, function(id, pos, rot)
	local player = client
	drones[id]:setPosition(pos.x, pos.y, pos.z)
	drones[id]:setRotation(rot.x, rot.y, rot.z)
end)

function createJammer(player)
	local pos = player:getPosition()
	local rot = player:getRotation()
	local jammer = createObject(jammerID, pos.x, pos.y, pos.z-1, rot.x, rot.y, rot.z)
	jammer:setData("signal >> jammer", true)
	local cs = createColSphere(pos.x, pos.y, pos.z, 100)
	cs:setData("signal >> jammerCol", true)
	cs:setData("signal >> jammer", jammer)
	local timer = setTimer(function(j, c) 
		j:destroy()
		c:destroy()
	end, 30000, 1, jammer, cs)
	table.insert(jammers, {jammer, timer, cs})
	triggerClientEvent(root, "sendJammersToClient", resourceRoot, jammers)
end
addCommandHandler("createjammer", createJammer)