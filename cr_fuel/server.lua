local connection = exports['cr_mysql']:getConnection(getThisResource())

local orange = exports['cr_core']:getServerColor("orange", true)

addEventHandler("onResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_core" then
			orange = exports['cr_core']:getServerColor("orange", true)
		elseif sResourceName == "cr_mysql" then
			connection = exports['cr_mysql']:getConnection(getThisResource())
		end
	end
)

-- construction : [id] = element
local cache = {}

-- construction : [ped] = element
local fuelgunElements = {}
local fuelgunObjects = {}
local colSpheres = {}
local fuelGuns = {}
local subModels = {}

local white = "#FFFFFF"

local loaded = false

local modelid = 3465

local fuelgunModel = 321

local sphereSize = 2

local fuelCost

local submodelDiesel = 7585
local submodelPetrol = 7584

-- construction : [id] = {modelid, name, {x, y, z, rot, int, dim}}
local peds = {
	{60, "Joshua", {1916.8038330078, -1776.0279541016, 13.65625, 270, 0, 0}},
}

addEventHandler("onResourceStart", resourceRoot,
	function()
		if loaded then return end
		loaded = true
		setFuelCost()
		dbQuery(function(query)
	        local query, query_lines = dbPoll(query, 0)
	        if query_lines > 0 then
	            for i,row in pairs(query) do
	            	local id, position = tonumber(row["id"]), fromJSON(row["position"])
	            	local x, y, z, rx, ry, rz, int, dim = unpack(position)
	            	local element = createObject(modelid, x, y, z, rx, ry, rz, false)
	            	local sphere = createColSphere(x, y, z, sphereSize)
	            	--létrehozás genyók!!
	            	for i = 1, 4 do
	            		if i == 1 or i == 3 then
	            			subModels[i] = createObject(submodelPetrol, x, y, z, rx, ry, rz, false)
	            		end
	            		if i == 2 or i == 4 then
	            			subModels[i] = createObject(submodelDiesel, x, y, z, rx, ry, rz, false)
	            		end
	            	end
	               	--létrehozásos genyók!! #összevisszaság
	            	fuelGuns[subModels[1]] = createObject(fuelgunModel, x, y, z)
	            	fuelGuns[subModels[2]] = createObject(fuelgunModel, x, y, z)
	            	setElementData(subModels[1], "fuel >> parent", element)
	            	setElementData(subModels[2], "fuel >> parent", element)
	            	setElementData(element, "fuel >> sphere", sphere)
	            	attachElements(subModels[1], element, 0.32, 0, -0.2)
	            	attachElements(subModels[2], element, 0.12, 0, -0.2)
	            	setElementData(subModels[1], "fuel >> id", id)
	            	setElementData(subModels[2], "fuel >> id", id)
	            	setElementData(subModels[1], "fuel >> usedBy", false)
	            	setElementData(subModels[2], "fuel >> usedBy", false)
	            	setElementData(subModels[2], "fuel >> fuelElement", element)
                    setElementData(subModels[1], "fuel >> fuelElement", element)

                   	setElementData(subModels[1], "fuel >> monitor", "bal")
                    setElementData(subModels[2], "fuel >> monitor", "bal")
                   	setElementData(subModels[3], "fuel >> monitor", "jobb")
                    setElementData(subModels[4], "fuel >> monitor", "jobb")



                    setElementData(element, "fuel >> fuelElement", element)
	            	setElementData(subModels[1], "fuel >> petrolElement", subModels[1])
                    setElementData(subModels[2], "fuel >> dieselElement", subModels[2])
					
                    -- setElementData(element, "fuel >> fuelType", "petrol")
                    -- setElementData(element, "fuel >> fuelType", "diesel")
	            	--setElementData(dieselElement, "fuel >> dieselElement", dieselElement)
                    --setElementData(petrolElement, "fuel >> petrolElement", petrolElement)

	            	fuelgunObjects[subModels[1]] = attachElements(fuelGuns[subModels[1]], subModels[1], 0.01, -0.40, 0.04, 90, 90, 0)
	            	fuelgunObjects[subModels[2]] = attachElements(fuelGuns[subModels[2]], subModels[2], 0.01, -0.40, 0.04, 90, 90, 0)
	            	--	            	
	            	fuelGuns[subModels[3]] = createObject(fuelgunModel, x, y, z)
	            	fuelGuns[subModels[4]] = createObject(fuelgunModel, x, y, z)
	            	setElementData(subModels[3], "fuel >> parent", element)
	            	setElementData(subModels[4], "fuel >> parent", element)
	            	attachElements(subModels[3], element, 0.32, 0.02, -0.2, 0, 0, 180)
	            	attachElements(subModels[4], element, 0.12, 0.02, -0.2, 0, 0, 180)
	            	setElementData(subModels[3], "fuel >> id", id)
	            	setElementData(subModels[4], "fuel >> id", id)
	            	setElementData(subModels[3], "fuel >> usedBy", false)
	            	setElementData(subModels[4], "fuel >> usedBy", false)
	            	setElementData(subModels[4], "fuel >> fuelElement", element)
                    setElementData(subModels[3], "fuel >> fuelElement", element)
	            	setElementData(subModels[3], "fuel >> petrolElement", subModels[3])
                    setElementData(subModels[4], "fuel >> dieselElement", subModels[4])
	            	--setElementData(dieselElement, "fuel >> dieselElement", dieselElement)
                    --setElementData(petrolElement, "fuel >> petrolElement", petrolElement)

	            	fuelgunObjects[subModels[3]] = attachElements(fuelGuns[subModels[3]], subModels[3], 0.01, -0.40, 0.04, 90, 90, 0)
	            	fuelgunObjects[subModels[4]] = attachElements(fuelGuns[subModels[4]], subModels[4], 0.01, -0.40, 0.04, 90, 90, 0)

	            	setElementInterior(element, int)
	            	setElementDimension(element, dim)
	            	cache[id] = element
	            end
	        end
	        outputDebugString("[Success] Loading fuels has finished successfuly. Loaded: " .. query_lines .. " fuels!")
	    end, connection, "SELECT * FROM `fuels`")
	    local count	= 0
	    for k,v in ipairs(peds) do
	    	local modelid, name, position = unpack(v)
	    	local x, y, z, rot, int, dim = unpack(position)
	    	local element = createPed(modelid, x, y, z, rot, true)
	    	local sphere = createColSphere(x, y, z, sphereSize)
	    	setElementData(element, "fuel >> pedsphere", sphere)
	    	setElementData(element, "fuel >> pedid", k)
	    	setElementData(element, "ped.name", name)
	    	setElementData(element, "ped.type", "Benzinkutas")
	    	setElementFrozen(element, true)
	    	count = count + 1
	    end
	    outputDebugString("[Success] Loading fuelpeds has finished successfuly. Loaded: " .. count .. " fuelpeds!")
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		if getElementData(source, "fuel >> hasFuelGun") then
			for k,v in pairs(cache) do
				if getElementData(v, "fuel >> usedBy") == source then
					setElementData(v, "fuel >> usedBy", false)
				end
			end
		end
		if getElementData(source, "fuel >> gunElement") then
			local element = getElementData(source, "fuel >> gunElement")
			if isElement(element) then
				destroyElement(element)
				fuelgunElements[source] = nil
			end
		end
	end
)

addEventHandler("onElementDataChange", root,
	function(dName)
		local value = getElementData(source, dName)
		if dName == "fuel >> hasFuelGun" then
			if value == true then
				toggleControl(source, "fire", false)
				local x, y, z = getElementPosition(source)
				local element = createObject(fuelgunModel, x, y, z)
				setElementData(source, "fuel >> gunElement", element)
				setElementInterior(element, getElementInterior(source))
				setElementDimension(element, getElementDimension(source))
				fuelgunElements[source] = element
				exports['cr_bone_attach']:attachElementToBone(element, source, 12, 0.04, 0.04, 0.04, 200, 0, 0)
			else
				if fuelgunElements[source] then
					if isElement(fuelgunElements[source]) then
						toggleControl(source, "fire", true)
						local element = fuelgunElements[source]
						setElementData(source, "fuel >> gunElement", false)
						fuelgunElements[source] = nil
						exports['cr_bone_attach']:detachElementFromBone(element)
						destroyElement(element)
					else
						setElementData(source, "fuel >> gunElement", false)
						fuelgunElements[source] = nil
					end
				end
			end
		elseif dName == "fuel >> fueling" then
			if value == true then
				exports['cr_animation']:applyAnimation(source, "SWORD", "sword_IDLE", 1000000, true, true, true, true, true)
			else
				exports['cr_animation']:removeAnimation(source)
			end
		end
	end
)

addEvent("fuel >> getFuelCost", true)
addEventHandler("fuel >> getFuelCost", root,
	function(source)
		if isElement(source) then
			triggerClientEvent("sendFuelCostDatas", source, fuelCost)
		end
	end
)

addEvent("fuel >> takeMoney", true)
addEventHandler("fuel >> takeMoney", root,
	function(amount,source)
		if isElement(source) then
			setElementData(source, "char >> money", getElementData(source, "char >> money") - (amount*amount))
		end
	end
)

addCommandHandler("createfuel",
	function(player, cmd)
		if exports['cr_permission']:hasPermission(player, "createfuel") then
				local x, y, z = getElementPosition(player)
				local rx, ry, rz = getElementRotation(player)
				local int = getElementInterior(player)
				local dim = getElementDimension(player)
				local position = toJSON({x, y, z, rx, ry, rz, int, dim})
				dbExec(connection, "INSERT INTO `fuels` SET `position`=?, `type`=?", position, type)
				dbQuery(function(query)
			        local query, query_lines = dbPoll(query, 0)
			        if query_lines > 0 then
			            for i,row in pairs(query) do
			            	local id, position = tonumber(row["id"]), fromJSON(row["position"])
			            	local fueltype = tostring(row["type"])
			            	local x, y, z, rx, ry, rz, int, dim = unpack(position)
			            	local element = createObject(modelid, x, y, z, rx, ry, rz, false)
			            	local sphere = createColSphere(x, y, z, sphereSize)
	            	--létrehozás genyók!!
	            	for i = 1, 4 do
	            		if i == 1 or i == 3 then
	            			subModels[i] = createObject(submodelPetrol, x, y, z, rx, ry, rz, false)
	            		end
	            		if i == 2 or i == 4 then
	            			subModels[i] = createObject(submodelDiesel, x, y, z, rx, ry, rz, false)
	            		end
	            	end
	               	--létrehozásos genyók!! #összevisszaság
	               	local sphere = createColSphere(x, y, z, sphereSize)
	               	setElementData(element, "fuel >> sphere", sphere)
	               	setElementData(element, "fuel >> id", id)

	            	fuelGuns[subModels[1]] = createObject(fuelgunModel, x, y, z)
	            	fuelGuns[subModels[2]] = createObject(fuelgunModel, x, y, z)
	            	fuelGuns[subModels[3]] = createObject(fuelgunModel, x, y, z)
	            	fuelGuns[subModels[4]] = createObject(fuelgunModel, x, y, z)

	            	setElementData(subModels[1], "fuel >> parent", element)
	            	setElementData(subModels[2], "fuel >> parent", element)
	            	setElementData(subModels[3], "fuel >> parent", element)
	            	setElementData(subModels[4], "fuel >> parent", element)
	            	setElementData(element, "fuel >> parent", element)

	            	attachElements(subModels[1], element, 0.32, 0, -0.2)
	            	attachElements(subModels[2], element, 0.12, 0, -0.2)
	            	attachElements(subModels[3], element, 0.32, 0.02, -0.2, 0, 0, 180)
	            	attachElements(subModels[4], element, 0.12, 0.02, -0.2, 0, 0, 180)

	            	setElementData(subModels[1], "fuel >> id", id)
	            	setElementData(subModels[2], "fuel >> id", id)
	            	setElementData(subModels[3], "fuel >> id", id)
	            	setElementData(subModels[4], "fuel >> id", id)

	            	setElementData(subModels[1], "fuel >> usedBy", false)
	            	setElementData(subModels[2], "fuel >> usedBy", false)
	            	setElementData(subModels[3], "fuel >> usedBy", false)
	            	setElementData(subModels[4], "fuel >> usedBy", false)

	            	setElementData(subModels[1], "fuel >> fuelElement", element)
                    setElementData(subModels[2], "fuel >> fuelElement", element)
                   	setElementData(subModels[3], "fuel >> fuelElement", element)
                    setElementData(subModels[4], "fuel >> fuelElement", element)
                    setElementData(element, "fuel >> fuelElement", element)

	            	setElementData(subModels[1], "fuel >> petrolElement", subModels[1])
                    setElementData(subModels[2], "fuel >> dieselElement", subModels[2])
                    setElementData(subModels[3], "fuel >> petrolElement", subModels[3])
                    setElementData(subModels[4], "fuel >> dieselElement", subModels[4])
	            	--setElementData(dieselElement, "fuel >> dieselElement", dieselElement)
                    --setElementData(petrolElement, "fuel >> petrolElement", petrolElement)

	            	fuelgunObjects[subModels[1]] = attachElements(fuelGuns[subModels[1]], subModels[1], 0.01, -0.40, 0.04, 90, 90, 0)
	            	fuelgunObjects[subModels[2]] = attachElements(fuelGuns[subModels[2]], subModels[2], 0.01, -0.40, 0.04, 90, 90, 0)

	            	fuelgunObjects[subModels[3]] = attachElements(fuelGuns[subModels[3]], subModels[3], 0.01, -0.40, 0.04, 90, 90, 0)
	            	fuelgunObjects[subModels[4]] = attachElements(fuelGuns[subModels[4]], subModels[4], 0.01, -0.40, 0.04, 90, 90, 0)

	            	setElementInterior(element, int)
	            	setElementDimension(element, dim)
	            	cache[id] = element
							local syntax = exports['cr_core']:getServerSyntax(false, "success")
							outputChatBox(syntax.."Sikeresen létrehoztál egy benzinkutat (ID: "..orange..tostring(id)..white..")", player, 255, 255, 255, true)
							local syntax = exports['cr_admin']:getAdminSyntax()
							local aName = exports['cr_admin']:getAdminName(player, true)
	                    	exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..orange..aName..white.." létrehozott egy benzinkutat (ID: "..orange..tostring(id)..white..")", 8)
	                    	local time = getTime() .. " "
	                    	exports['cr_logs']:addLog("Admin", "createFuel", time .. aName .. " létrehozott egy benzinkutat (ID: "..orange..tostring(id)..white..")")
			            end
			        end
			    end, connection, "SELECT * FROM `fuels` WHERE `position`=?", position)	
			end
	end
)

addCommandHandler("deletefuel",
	function(player, cmd, argid)
		if exports['cr_permission']:hasPermission(player, "deletefuel") then
			if not argid then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax.."/"..cmd.." [id]", player, 255, 255, 255, true)
				return
			end
			if not tonumber(argid) then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax.."Valós ID-t adj meg!", player, 255, 255, 255, true)
				return
			end
			argid = tonumber(argid)
			if cache[argid] then
				dbExec(connection, "DELETE FROM `fuels` WHERE `id`=?", argid)
				local element = cache[argid]
				local sphere = getElementData(element, "fuel >> sphere")
				cache[argid] = nil
				destroyElement(getElementData(element, "fuel >> petrolElement"))
				destroyElement(getElementData(element, "fuel >> dieselElement"))
				destroyElement(element)
				destroyElement(sphere)
				local syntax = exports['cr_core']:getServerSyntax(false, "success")
				outputChatBox(syntax.."Sikeresen töröltél egy benzinkutat (ID: "..orange..tostring(argid)..white..")", player, 255, 255, 255, true)
				local syntax = exports['cr_admin']:getAdminSyntax()
				local aName = exports['cr_admin']:getAdminName(player, true)
            	exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..orange..aName..white.." törölt egy benzinkutat (ID: "..orange..tostring(argid)..white..")", 8)
            	local time = getTime() .. " "
            	exports['cr_logs']:addLog("Admin", "deleteFuel", time .. aName .. " törölt egy benzinkutat (ID: "..orange..tostring(argid)..white..")")
			else
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax.."Nincs benzinkút ilyen ID-vel!", player, 255, 255, 255, true)
				return
			end
		end
	end
)

addCommandHandler("thisfuel",
	function(player)
		local targetFuel
		for k,v in pairs(cache) do
			if isElement(v) then
				if isElementWithinColShape(player, getElementData(v, "fuel >> sphere")) then
					targetFuel = v
				end
			end
		end
		if targetFuel then
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			outputChatBox(syntax.."Benzinkút ID-je: "..tostring(getElementData(targetFuel, "fuel >> id")), player, 255, 255, 255, true)
		end
	end
)

addCommandHandler("setfuelcost",
	function(player, cmd, type, argcost)
		if exports['cr_permission']:hasPermission(player, "createfuel") then
			local type = tostring(type)
			if not argcost or not type then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax.."/"..cmd.." [benzin/diesel] [cost]", player, 255, 255, 255, true)
				return
			end
			if not tonumber(argcost) or tonumber(argcost) <= 0 then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax.."Valós, 0 feletti árat adj meg!", player, 255, 255, 255, true)
				return
			end
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax.."Sikeresen megváltoztattad az üzemanyag árát "..orange..argcost..white.."-ra/re", player, 255, 255, 255, true)
			setFuelCost(argcost,type)
		end
	end
)

function setFuelCost(argcost, type)
	local value = {}
	local text
	if not argcost then
		value = {math.random(5, 10), math.random(1,3)}
	end
		if type == "diesel" then
			value[2] = tonumber(argcost)
			text = "Dízel:"..orange..fuelCost[2]..white.." $"
		elseif type == "petrol" then
			value[1] = tonumber(argcost)
			text = "Benzin:"..orange..fuelCost[1]..white.." $"
		end
	fuelCost = {value[1],value[2]}
	if type == "diesel" then
	text = "Dízel: "..orange..fuelCost[2]..white.." $"
	elseif type == "petrol" then
	text = "Benzin: "..orange..fuelCost[1]..white.." $"
	end
	local syntax = exports['cr_core']:getServerSyntax(false, "info")
	if type == "petrol" or type == "diesel" then
		outputChatBox(syntax.."Az üzemanyag ára megváltozott. Új ár: "..text, root, 255, 255, 255, true)
	else
		outputChatBox(syntax.."Az üzemanyag ára megváltozott. Új ár: Benzin: "..orange..fuelCost[1]..white.." $  Dízel: "..orange..fuelCost[2]..white.." $", root, 255, 255, 255, true)
	end
end

function getFuelCost()
	return fuelCost
end

setTimer(
	function()
		setFuelCost()
	end, 3600000, 0
)
function changeFuelGunElement(element, type)
	if element then
		if type == "delete" then

			destroyElement(fuelGuns[element])

		elseif type == "create" then
				local x,y,z = getElementPosition(element)
				fuelGuns[element] = createObject(fuelgunModel, x, y, z)
				fuelgunObjects[element] = attachElements(fuelGuns[element], element,0.01, -0.40, 0.04, 90, 90, 0)
		end
	end
end
addEvent("changeFuelGunElement", true)
addEventHandler("changeFuelGunElement", root, changeFuelGunElement)

function getFuelTypeToMonitor(element, player)

	if element and player then
		local monitor = getElementData(element, "fuel >> monitor")
		if monitor == "bal" then
			triggerClientEvent("setMonitorElement", player, "monitor")

		elseif monitor == "jobb" then
			triggerClientEvent("setMonitorElement", player, "monitor2")
		end

	end
end
addEvent("getFuelTypeToMonitor", true)
addEventHandler("getFuelTypeToMonitor", root, getFuelTypeToMonitor)