local jobVehicles = {};
local vehicleDestroyTimers = {};
local temporaryVehicles = {};
local jobDatas = {};
local jobDataTimers = {};

addEventHandler("onResourceStart", resourceRoot, function()
	Async:setPriority("high")
	Async:setDebug(true)
end)

addEvent("createJobVehicle", true)
function createJobVehicle(player, model, x, y, z, rx, ry, rz, v1, v2, warp)
	if(player and model and x and y and z and rx and ry and rz and v1 and v2) then
		model = tonumber(model)
		local owner, job = player:getData("acc >> id"), player:getData("char >> job")
		local plateText = exports.cr_vehicle:generatePlateText()
		local veh = createVehicle(model, x, y, z, rx, ry, rz, plateText)
		local id = player:getData("acc >> id") * -1
		veh:setVariant(v1, v2)
		-- jobVehicles[id] = {veh, owner, job}
		if(not jobVehicles[owner]) then
			jobVehicles[owner] = {}
		end
		-- table.insert(jobVehicles[id], {veh, owner, job})
		jobVehicles[owner][model] = {veh, owner, job}
		veh:setData("veh >> id", id)
		veh:setData("veh >> job", job)
		veh:setData("veh >> fuel", 99999)
		veh:setData("veh >> locked", false)
		veh:setData("veh >> owner", owner)
		veh:setData("veh >> light", false)
		veh:setData("veh >> engine", false) 
		veh:setData("veh >> handbrake", false)
		veh:setData("veh >> faction", 0)
		veh:setData("veh >> odometer", 0)
		veh:setData("veh >> lastOilRecoil", 0)
		if(warp) then
			if(player) then
				player:warpIntoVehicle(veh)
			end
		end
		return veh
	end
	return false
end
addEventHandler("createJobVehicle", getRootElement(), createJobVehicle)

function getJobVehicle(player, model)
	model = tonumber(model)
	local owner = player:getData("acc >> id")
	if(not model) then
		if(jobVehicles[owner]) then
			Async:foreach(jobVehicles[owner], function(val)
				return val[1]
			end)
		end
	else
		return jobVehicles[owner][model][1]
	end
end

addEvent("deleteJobVehicle", true)
function deleteJobVehicle(player, model)
	model = tonumber(model)
	local owner = player:getData("acc >> id")
	if(not model) then
		if(jobVehicles[owner]) then
			for i, val in pairs(jobVehicles[owner]) do
				if(val[1] and isElement(val[1])) then
					local jobData = val[1]:getData("job >> data")
					if(jobData) then
						triggerClientEvent(player, "deletedJobVehicle", getRootElement(), jobData)
						val[1]:destroy()
					end
				end
			end
		end
		jobVehicles[owner] = {}
	else
		if(jobVehicles[owner]) then
			if(jobVehicles[owner][model]) then
				local jobData = jobVehicles[owner][model][1]:getData("job >> data")
				triggerClientEvent(player, "deletedJobVehicle", getRootElement(), jobData)
				jobVehicles[owner][model][1]:destroy()
				jobVehicles[owner][model] = false
			end
		end
	end
end
addEventHandler("deleteJobVehicle", getRootElement(), deleteJobVehicle)

addCommandHandler("nearbyjobvehicle", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		local prefix = exports['cr_core']:getServerSyntax("Job", "info")
		player:outputChat(prefix.."Közeli munkajárművek:", 255, 255, 255, true)
		for i, v in pairs(getElementsByType("vehicle")) do
			if(v:getData("veh >> job")) then
				local pos = v:getPosition()
				local ppos = player:getPosition()
				local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z)
				if(dist <= 20) then
					player:outputChat("#"..v:getData("veh >> id").." | Távolság: "..math.floor(dist).." yard | Model: "..v:getModel(), 255, 255, 255, true)
				end
			end
		end
	else
		local prefix = exports['cr_core']:getServerSyntax("Job", "error")
		player:outputChat(prefix.."Neked ehhez nincs jogod!", 255, 255, 255, true)
	end
end)

addEventHandler("onPlayerVehicleEnter", root, function(v)
	if(tonumber(v:getData("veh >> job")) and v:getData("veh >> owner") == source:getData("acc >> id")) then
		local owner = source:getData("acc >> id")
		if(vehicleDestroyTimers[owner]) then
			if(isTimer(vehicleDestroyTimers[owner][v:getModel()])) then
				killTimer(vehicleDestroyTimers[owner][v:getModel()])
			end
		end
	end
end)

addEventHandler("onPlayerVehicleExit", root, function(v) 
	if(tonumber(v:getData("veh >> job")) and v:getData("veh >> owner") == source:getData("acc >> id")) then
		local owner = source:getData("acc >> id")
		if(not vehicleDestroyTimers[owner]) then
			vehicleDestroyTimers[owner] = {}
		end
		vehicleDestroyTimers[owner][v:getModel()] = setTimer(function(veh, player) 
			if(isElement(veh)) then
				veh:destroy()
				endJob(player)
			end
		end, 1800000, 1, v, source)
		local prefix = exports['cr_core']:getServerSyntax("Job", "warning")
		source:outputChat(prefix.."Elhagytad munkajárművedet, amennyiben nem szállsz vissza a jármű 30 percen belül törlődik.", 255, 255, 255, true)
	end
end)

function endJob(player)
	triggerClientEvent(player, "endJob", resourceRoot)
	jobDatas[player:getData("acc >> id")] = false
end

addEventHandler("onElementDataChange", getRootElement(), function(dataName, oldValue) 
	if(dataName == "acc >> id") then
		local veh = getJobVehicle(source)
		if(jobDatas[source:getData("acc >> id")]) then
			source:setData("job >> data", jobDatas[source:getData("acc >> id")])
			jobDatas[source:getData("acc >> id")] = false
			source:triggerEvent("restoreJobStatus", getRootElement())
		end
	elseif(dataName == "char >> job" and tonumber(oldValue)) then
		deleteJobVehicle(source, false)
	end
end)

addEventHandler("onPlayerQuit", root, function() 
	local player = source
	local jobveh = getJobVehicle(player)
	jobDatas[player:getData("acc >> id")] = player:getData("job >> data")
	jobDataTimers[player:getData("acc >> id")] = setTimer(function(i) 
		jobDatas[i] = false
	end, 1800000, 1, player:getData("acc >> id"))
	if(isPedInVehicle(player)) then
		local veh = player:getOccupiedVehicle()
		if(veh:getData("veh >> owner") == player:getData("acc >> id") and tonumber(veh:getData("veh >> job"))) then
			vehicleDestroyTimers[player:getData("acc >> id")][veh:getModel()] = setTimer(function(v) 
				v:destroy()
			end, 1800000, 1, veh)
		end
	end
end)

function createTemporaryVehicle(player, model, x, y, z, rx, ry, rz, v1, v2, plate, warp)
	if(player and model and x and y and z and rx and ry and rz and v1 and v2) then
		model = tonumber(model)
		local owner = player:getData("acc >> id")
		local plateText = exports.cr_vehicle:generatePlateText()
		if(plate) then
			plateText = plate
		end
		local veh = createVehicle(model, x, y, z, rx, ry, rz, plateText)
		local id = player:getData("acc >> id")*-1
		veh:setVariant(v1, v2)
		temporaryVehicles[owner] = {veh, owner, id}
		veh:setData("veh >> id", id)
		veh:setData("veh >> temporaryVehicle", true)
		veh:setData("veh >> fuel", 99999)
		veh:setData("veh >> locked", false)
		veh:setData("veh >> owner", owner)
		veh:setData("veh >> light", false)
		veh:setData("veh >> engine", false) 
		veh:setData("veh >> handbrake", false)
		veh:setData("veh >> faction", 0)
		veh:setData("veh >> odometer", 0)
		veh:setData("veh >> lastOilRecoil", 0)
		if(warp) then
			if(player) then
				player:warpIntoVehicle(veh)
			end
		end
		return veh
	end
	return false
end

function deleteTemporaryVehicle(player)
	local owner = player:getData("acc >> id")
	if(isElement(temporaryVehicles[owner][1])) then
		temporaryVehicles[owner][1]:destroy()
		temporaryVehicles[owner] = nil
	end
end

addEventHandler("onVehicleStartEnter", getRootElement(), function(player, seat, jacked)
	if(seat == 0) then
		if(source:getData("veh >> owner") ~= player:getData("acc >> id")) then
			if(source:getData("veh >> job") or source:getData("veh >> temporaryVehicle")) then
				cancelEvent()
				local prefix = exports['cr_core']:getServerSyntax("Vehicle", "error")
				player:outputChat(prefix.."Ez a jármű nem általad lett lekérve illetve nem a te nevedre szól.", 255, 255, 255, true)
			end
		end
	end
end)

addCommandHandler("eldob", function(player, cmd, type)
	if(type == "ko" or type == "Ko" or type == "Kő" or type == "kő") then
		local jobData = player:getData("job >> data")
		if(jobData) then
			if(jobData["rockInHand"]) then
				local prefix = exports['cr_core']:getServerSyntax("Job", "info")
				player:outputChat(prefix.." Eldobtad a kezedből a követ!", 255, 255, 255, true)
				toggleControl(player, "fire", true)
				player:setData("forceAnimation", {"", ""})
				exports.cr_miner:destroyRockInHand(player)
				jobData["rockInHand"] = false
				player:setData("job >> data", jobData)
                local sprintState = isControlEnabled(player, "sprint")
                local jumpState = isControlEnabled(player, "jump")
                toggleControl(player, "sprint", sprintState)
                toggleControl(player, "jump", jumpState)
			else
				local prefix = exports['cr_core']:getServerSyntax("Job", "error")
				player:outputChat(prefix.."Nincs kő a kezedben.", 255, 255, 255, true)
			end
		else
			local prefix = exports['cr_core']:getServerSyntax("Job", "error")
			player:outputChat(prefix.."Nincs kő a kezedben.", 255, 255, 255, true)
		end
	elseif(type == "zsak" or type == "Zsak" or type == "zsák" or type == "Zsák") then
		local jobData = player:getData("job >> data")
		if(jobData) then
			if(jobData["bagInHand"]) then
				local prefix = exports['cr_core']:getServerSyntax("Job", "info")
				player:outputChat(prefix.."Eldobtad a kezedből a zsákot!", 255, 255, 255, true)
				toggleControl(player, "fire", true)
				player:setData("forceAnimation", {"", ""})
				exports.cr_miner:destroyBagInHand(player)
				jobData["bagInHand"] = false
				player:setData("job >> data", jobData)
                local sprintState = isControlEnabled(player, "sprint")
                local jumpState = isControlEnabled(player, "jump")
                toggleControl(player, "sprint", sprintState)
                toggleControl(player, "jump", jumpState)
				local jobData = player:getData("job >> data")
				local bagDatas = jobData["refinedRockData"] or {}
				if(#bagDatas > 0) then
					table.remove(bagDatas, #bagDatas)
					local jobData = player:getData("job >> data")
					jobData["refinedRockData"] = bagDatas
					player:setData("job >> data", jobData)
				end
			else
				local prefix = exports['cr_core']:getServerSyntax("Job", "error")
				player:outputChat(prefix.."Nincs zsák a kezedben.", 255, 255, 255, true)
			end
		else
			local prefix = exports['cr_core']:getServerSyntax("Job", "error")
			player:outputChat(prefix.."Nincs zsák a kezedben.", 255, 255, 255, true)
		end
	elseif(type == "fa" or type == "Fa") then
		local jobData = player:getData("job >> data")
		if(jobData) then
			if(jobData["pileInHand"]) then
				local prefix = exports['cr_core']:getServerSyntax("Job", "info")
				player:outputChat(prefix.."Eldobtad a kezedből a fát!", 255, 255, 255, true)
				toggleControl(player, "fire", true)
				player:setData("forceAnimation", {"", ""})
				exports.cr_lumberjack:destroyPileInHand(player)
				jobData["pileInHand"] = false
				player:setData("job >> data", jobData)
                local sprintState = isControlEnabled(player, "sprint")
                local jumpState = isControlEnabled(player, "jump")
                toggleControl(player, "sprint", sprintState)
                toggleControl(player, "jump", jumpState)
			else
				local prefix = exports['cr_core']:getServerSyntax("Job", "error")
				player:outputChat(prefix.."Nincs fa a kezedben.", 255, 255, 255, true)
			end
		else
			local prefix = exports['cr_core']:getServerSyntax("Job", "error")
			player:outputChat(prefix.."Nincs fa a kezedben.", 255, 255, 255, true)
		end
	else
		local prefix = exports['cr_core']:getServerSyntax("Job", "error")
		player:outputChat(prefix.."Használat: /"..cmd.." [Ko/Zsak/Fa]", 255, 255, 255, true)
	end
end
)