local vas = 0;
local vasak = {};
conn = exports['cr_mysql']:getConnection(getThisResource());

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query) 
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			Async:foreach(query, function(row)
				vas = tonumber(row["data"])
				outputDebugString("#"..vas.." hulladék fém betöltve.")
			end)
		end
	end, conn, "SELECT * FROM cartrans")
	reloadVas()
end)

addEventHandler("onResourceStop", resourceRoot, function() 
	dbExec(conn, "UPDATE cartrans SET data = ? WHERE id = '1'", vas)
end)

local reloadTimer = nil
function reloadVas()
	-- outputChatBox(vas.." "..#vasak.." "..tostring(isTimer(reloadTimer)))
	if(vas > 0 and #vasak == 0 and not isTimer(reloadTimer)) then
		local quantity =0
		if(vas >= 4) then
			quantity = 4
			vas = vas-4
		else
			quantity = vas
			vas = 0
		end
		reloadTimer = setTimer(function()
			local obj = createObject(7955,-1826.3395996094, -1670.6499023438, 40, -20, 0, 30)
			table.insert(vasak, obj)
			moveObject(obj, 5000, -1845.5904541016, -1644.1906738281, 21.888626098633)
			setTimer(function(o)
				local x, y, z, rx, ry, rz = unpack(vasPositions[#vasak])
				o:setPosition(x, y, z)
				o:setRotation(rx, ry, rz)
				o:setData("job >> data", {["job"] = 3, ["feldolgozottVas"] = true, ["id"] = #vasak})
			end, 5400, 1, obj)
		end, 10000, quantity)
	end
end

setTimer(function()
	reloadVas()
end, 10000, 0)

addEvent("addWreckageToVehicle", true)
addEventHandler("addWreckageToVehicle", root, function(player) 
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 578)
	veh:setFrozen(false)
	local pos = veh:getPosition()
	local rakomany = exports.cr_objects:createObj(3593, pos.x, pos.y, pos.z)
	rakomany:setCollisionsEnabled(false)
	rakomany:attach(veh, 0, -2, 0.3)
	rakomany:setData("job >> data", {["job"] = 3, ["wreckageObject"] = true})
	setElementJobData(veh, "wreckage", rakomany)
end)

addEvent("destroyWreckage", true)
addEventHandler("destroyWreckage", root, function(player, rakomany) 
	if(isElement(rakomany)) then
		rakomany:destroy()
	end
end)

addEvent("pickUpVas", true)
addEventHandler("pickUpVas", root, function(player, obj) 
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 530)
	obj:setCollisionsEnabled(false)
	obj:attach(veh, 0, 0.7, 0.4)
	setElementJobData(veh, "vas", obj)
	setElementJobData(obj, "feldolgozottVas", false)
	setElementJobData(obj, "taken", true)
	local count = 0
	for i, v in pairs(vasak) do
		if(getElementJobData(v, "taken")) then
			count = count+1
		end
	end
	if(count == #vasak) then
		vasak = {}
	end
end)
 
addEvent("createForklift", true)
addEventHandler("createForklift", root, function(player) 
	local pos = player:getPosition()
	local veh = exports.cr_temporaryvehicle:createJobVehicle(player, 530, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, true)
	veh:setData("job >> data", {["job"] = 3, ["vas"] = false, ["forklift"] = true})
end)

addEvent("deletedForklift", true)
addEventHandler("deletedForklift", root, function(player, data) 
	if(data["job"] == 3 and isElement(data["vas"])) then
		data["vas"]:destroy()
		vas = vas+1
	end
end)

addEvent("loadVas", true)
addEventHandler("loadVas", root, function(player) 
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 578)
	local veh2 = exports.cr_temporaryvehicle:getJobVehicle(player, 530)
	local obj = getElementJobData(veh2, "vas")
	local boxes = getElementJobData(veh, "wreckageBoxes") or {}
	if(#boxes < 4) then
		table.insert(boxes, obj)
		setElementJobData(veh, "wreckageBoxes", boxes)
		local x, y, z = unpack(slotPositions[#boxes])
		obj:attach(veh, x, y, z)
		player:outputChat(msgs["success"].."Felpakoltál egy feldolgozott vasat a munkajárművedre. ("..#boxes.."/4)", 255, 255, 255, true)
		if(#boxes == 4) then
			player:outputChat(msgs["info"].."Járműved meg lett pakolva teljesen. Most szállítsd le a feldolgozott roncsokat a Roncstelepre! #008000(Zöld blip)", 255, 255, 255, true)
		end
		setElementJobData(veh2, "vas", false)
	else
		player:outputChat(msgs["error"].."Ez a jármű teljesen meg lett pakolva. (4/4)", 255, 255, 255, true)
	end
end)

local spamTimers = {}
addEvent("putdownWreckage", true)
addEventHandler("putdownWreckage", root, function(player) 
	local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 578)
	veh:setFrozen(false)
	local rakomany = getElementJobData(veh, "wreckage")
	if(isElement(rakomany)) then
		rakomany:destroy()
	end
	local HPbonus = 200*((player.health/100)-0.5)
	local HPvehBonus = 200*((veh.health/1000)-0.5)
	local money = player:getData("char >> money")
	local fSalary = math.floor(salary*exports.cr_jobpanel:getPaymentMultiplier()+HPbonus+HPvehBonus)
	player:setData("char >> money", money+fSalary)
	player:outputChat(msgs["success"].."Leszállítottad a roncsot, fizetésed: #008000$"..fSalary, 255, 255, 255, true)
	setElementJobData(veh, "wreckage", false)
	vas = vas+1
end)

addEvent("giveCartransFinishSalary", true)
addEventHandler("giveCartransFinishSalary", root, function(player, endTime) 
	if(not isTimer(spamTimers[player:getData("acc >> id")])) then
		local veh = exports.cr_temporaryvehicle:getJobVehicle(player, 578)
		local boxes = getElementJobData(veh, "wreckageBoxes") or {}
		local timeBonus = 200*(1-((endTime)/(3*60*1000)))
		local HPbonus = 200*((player.health/100)-0.5)
		local HPvehBonus = 200*((veh.health/1000)-0.5)
		timeBonus = timeBonus > 200 and 200 or timeBonus < -50 and -50 or timeBonus
		if(#boxes > 0) then
			for index, value in pairs(boxes) do
				if(isElement(value)) then
					value:destroy()
				end
			end
			setElementJobData(veh, "wreckageBoxes", {})
			local fSalary = 0
			for i, v in pairs(boxes) do 
				fSalary = fSalary+finishSalary
			end
			local money = player:getData("char >> money")
			local totalSalary = math.floor(fSalary*exports.cr_jobpanel:getPaymentMultiplier()+timeBonus+HPbonus+HPvehBonus)
			player:setData("char >> money", money+totalSalary)
			player:outputChat(msgs["info"].."Végeztél a munkáddal. Fizetésed: #008000$"..totalSalary, 255, 255, 255, true)
			veh:setFrozen(false)
			toggleAllControls(player, true, true, true)
		end
	end
	spamTimers[player:getData("acc >> id")] = setTimer(function() end, 15000, 1)
end)

addEvent("deleteWreckageBoxes", true)
addEventHandler("deleteWreckageBoxes", root, function(player, data)
	if(#data["wreckageBoxes"] > 0) then
		for i, v in pairs(data["wreckageBoxes"]) do
			v:destroy()
		end
	end
end)

addCommandHandler("setscrapcount", function(player, cmd, amount)
	amount = tonumber(amount)
	if(amount) then
		if(amount >= 0) then
			vas = amount
			dbExec(conn, "UPDATE cartrans SET data = ? WHERE id = '1'", amount)
			player:outputChat(msgs["info"].."Érték beállítva: "..amount, 255, 255, 255, true)
		else	
			player:outputChat(msgs["error"].."Használat: /"..cmd.." [Darabszám]", 255, 255, 255, true)
		end
	else
		player:outputChat(msgs["error"].."Használat: /"..cmd.." [Darabszám]", 255, 255, 255, true)
	end
end)