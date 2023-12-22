local tickets = {};
local ticketPeds = {};
local orange = exports['cr_core']:getServerColor("orange", true);

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, v in pairs(query) do
				local id = v["id"]
				local data = fromJSON(v["data"])
				if(data) then
					if(not tickets[tonumber(data["account"])]) then
						tickets[tonumber(data["account"])] = {}
					end
					table.insert(tickets[tonumber(data["account"])], {["id"] = tonumber(id), ["title"] = tostring(data["title"]), ["cost"] = tonumber(data["cost"]), ["timestamp"] = tonumber(data["timestamp"]), ["date"] = tostring(data["date"]), ["account"] = tonumber(data["account"])}) 
				end
			end
		end
	end, connection:requestConnection(), "SELECT * FROM ticket")
	
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, v in pairs(query) do
				loadPed(tonumber(v["id"]), fromJSON(v["data"]))
			end
		end
	end, connection:requestConnection(), "SELECT * FROM ticketped")
end)

function loadPed(id, data)
	if(data ~= nil) then
		if(not ticketPeds[data["id"]]) then
			local x, y, z, r = unpack(data["pos"])
			local ped = createPed(data["skin"], x, y, z, r)
			
			ped:setInterior(data["world"][1])
			ped:setDimension(data["world"][2])
			
			ped:setData("faction >> ticketNPC", true)
			
			ped:setData("ped.name", data["name"])
			ped:setData("ped.type", "Csekk #"..id)
			ped:setData("char >> noDamage", true)
			
			ticketPeds[id] = ped
		end
	elseif(tonumber(data)) then
		dbQuery(function(query)
			local query, query_lines = dbPoll(query, 0)
			if(query_lines > 0) then
				for i, v in pairs(query) do
					loadPed(tonumber(v["id"]), fromJSON(v["data"]))
				end
			end
		end, connection:requestConnection(), "SELECT * FROM ticketped WHERE id = ?", data)
	end
end

function formatTimeStamp(t)
	local time = getRealTime(t)
	local year = time.year
	local month = time.month+1
	local day = time.monthday
	local hours = time.hour+1
	local minutes = time.minute
	local seconds = time.second
	if(month < 10) then
		month = "0"..month
	end
	if(day < 10) then
		day = "0"..day
	end
	if (hours < 10) then
		hours = "0"..hours
	end
	if (minutes < 10) then
		minutes = "0"..minutes
	end
	if (seconds < 10) then
		seconds = "0"..seconds
	end
	return 1900+year, month, day, hours, minutes, seconds
end

function createTicket(player, title, cost, expiration)
	title, cost, expiration = tostring(title), tonumber(cost), tonumber(expiration)
	local id = tonumber(player:getData("acc >> id"))
	if(id > 0) then
		if(not tickets[id]) then
			tickets[id] = {}
		end
		local year, month, day, hours, minutes, seconds = formatTimeStamp(expiration)
		local data = {["id"] = 0, ["title"] = title, ["cost"] = cost, ["timestamp"] = expiration, ["account"] = id, ["date"] = year.."."..(month).."."..day..". "..(hours)..":"..minutes..":"..seconds}
		dbExec(connection:requestConnection(), "INSERT INTO ticket SET data = ?", toJSON(data))
		dbQuery(function(query)
			local query, query_lines = dbPoll(query, 0)
			if(query_lines > 0) then
				for i, v in pairs(query) do
					data["id"] = v["id"]
					table.insert(tickets[id], data)
                    --if not exports['cr_inventory']:getFreeSlot(player, 2) then
--                        exports['cr_infobox']:addBox(source, "error", "Mivel nincs hely az inventorydban ezért automatikusan levonta a bírság 200%-t a rendszer!")
--                        triggerEvent("payTicketBank", player, player, data, _)
--                    else
                    exports.cr_inventory:giveItem(player, 128, data, 1, 100, 0, 0)
--                    end
				end
			end
		end, connection:requestConnection(), "SELECT * FROM ticket WHERE data = ?", toJSON(data))
		exports.cr_infobox:addBox(player, "warning", "Kaptál egy csekket, "..data["title"].." indokkal. Befizetési határidő: "..year.."."..month.."."..day..". "..(hours-2)..":"..minutes..":"..seconds)
	end
end

addEventHandler("onElementDataChange", root, function(dName, dValue) 
	if(source:getType() == "player") then
		if(dName == "loggedIn") then
			local id = source:getData("acc >> id")
			local time = getRealTime()["timestamp"]
			if(tickets[id]) then
				local warning = exports['cr_core']:getServerSyntax(false, "warning")
				local expired = 0
				for i, v in pairs(tickets[id]) do
					if(tonumber(v["timestamp"]) < time) then
						expired = expired+1
					end
				end
				source:outputChat(warning..#tickets[id].." db befizetetlen csekked van. Ebből "..expired.."db lejárt.", 255, 255, 255, true)
			end
		end
	end
end)

addCommandHandler("createticketnpc", function(player, cmd, name) 
	local success = exports.cr_core:getServerSyntax(nil, "success")
	local error = exports.cr_core:getServerSyntax(nil, "error")
	if(exports.cr_faction:isPlayerInFaction(player, 1)) then
		if(exports.cr_faction:isPlayerMainLeader(player, 1)) then
			local pos = player:getPosition()
			if(name == nil or not name or name:len() <= 0) then
				name = "Ferenc"
			end
			local int, dim = player:getInterior(), player:getDimension()
			local rot = player:getRotation()
			local data = {["name"] = name, ["skin"] = 280, ["pos"] = {pos.x, pos.y, pos.z, rot.z}, ["world"] = {int, dim}}
			dbExec(connection:requestConnection(), "INSERT INTO ticketped SET data = ?", toJSON(data))
			dbQuery(function(query) 
				local query, query_lines = dbPoll(query, 0)
				if(query_lines > 0) then
					loadPed(v["id"], data)
				end
			end, connection:requestConnection(), "SELECT * FROM ticketped WHERE data = ?", toJSON(data))
		else
			player:outputChat(error.."Neked nincs jogod ehhez!", 255, 255, 255, true)
		end
	else
		player:outputChat(error.."Nem taltozol a(z) "..tostring(exports.cr_faction:getFactionName(player, 1)).." frakcióba.", 255, 255, 255, true)
	end
end)

addCommandHandler("deleteticketnpc", function(player, cmd, id)
	local success = exports.cr_core:getServerSyntax(nil, "success")
	local error = exports.cr_core:getServerSyntax(nil, "error")
	id = tonumber(id)
	if(exports.cr_faction:isPlayerInFaction(player, 1)) then
		if(exports.cr_faction:isPlayerMainLeader(player, 1)) then
			if(ticketPeds[id]) then
				ticketPeds[id]:destroy()
				dbExec(connection:requestConnection(), "DELETE FROM ticketped WHERE id = ?", id)
				table.remove(ticketPeds, id)
				player:outputChat(success.."NPC törölve.", 255, 255, 255, true)
			else
				player:outputChat(error.."Nem létező NPC!", 255, 255, 255, true)
			end
		else
			player:outputChat(error.."Neked nincs jogod ehhez!", 255, 255, 255, true)
		end
	else
		player:outputChat(error.."Nem taltozol a(z) "..tostring(exports.cr_faction:getFactionName(player, 1)).." frakcióba.", 255, 255, 255, true)
	end
end)

local spamTimers = {};
addEvent("payTicket", true)
addEventHandler("payTicket", getRootElement(), function(e, ticket, slot) 
	if(not isTimer(spamTimers[e])) then
		--local money = e:getData("char >> money")
		local cost = ticket["cost"]
		local time = getRealTime()["timestamp"]
		local id = e:getData("acc >> id")
		--if(ticket["timestamp"] < time) then
--			cost = cost*2
		--end
		--if(money >= cost) then
			--e:setData("char >> money", money-cost)
			exports.cr_infobox:addBox(e, "success", "A csekk sikeresen kifizetve.")
			--exports.cr_inventory:deleteItem(e, slot, 128);
			for i, v in pairs(tickets[id]) do
				if(v["id"] == ticket["id"]) then
					table.remove(tickets[id], i)
                    dbExec(connection:requestConnection(), "DELETE FROM ticket WHERE id = ?", ticket["id"])
				end
			end
			spamTimers[e] = setTimer(function() end, 3000, 1)
		--else
		--	exports.cr_infobox:addBox(e, "error", "Nincs elegendő pénzed, hogy kifizesd ezt a csekket. "..(ticket["timestamp"] < time and "(Ez a csekk lejárt, ezért 2x a bűntetés!)" or ""))
		--end
	end
end)

addEvent("payTicketBank", true)
addEventHandler("payTicketBank", getRootElement(), function(e, ticket, slot) 
	--if(not isTimer(spamTimers[e])) then
		--local money = e:getData("char >> money")
		local cost = ticket["cost"]
		local time = getRealTime()["timestamp"]
		local id = e:getData("acc >> id")
		--if(ticket["timestamp"] < time) then
--			cost = cost*2
		--end
		--if(money >= cost) then
			--e:setData("char >> money", money-cost)
            --triggerEvent("")
			--exports.cr_infobox:addBox(e, "success", "A csekk sikeresen kifizetve.")
			--exports.cr_inventory:deleteItem(e, slot, 128);
			for i, v in pairs(tickets[id]) do
				if(v["id"] == ticket["id"]) then
					table.remove(tickets[id], i)
                    dbExec(connection:requestConnection(), "DELETE FROM ticket WHERE id = ?", ticket["id"])
				end
			end
			--spamTimers[e] = setTimer(function() end, 3000, 1)
		--else
		--	exports.cr_infobox:addBox(e, "error", "Nincs elegendő pénzed, hogy kifizesd ezt a csekket. "..(ticket["timestamp"] < time and "(Ez a csekk lejárt, ezért 2x a bűntetés!)" or ""))
		--end
	--end
end)