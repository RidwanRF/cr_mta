dutyPoints = {};
connection = exports.cr_mysql;

local loadTimer = nil;
function loadDutyPoint(id, data)
	dutyPoints[id] = data
	if(isTimer(loadTimer)) then killTimer(loadTimer) end
	loadTimer = setTimer(triggerClientEvent, 1000, 1, root, "receiveDutyPoints", resourceRoot, dutyPoints)
end

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, v in pairs(query) do
				local id = tonumber(v["id"])
				local data = fromJSON(v["data"])
				loadDutyPoint(id, data)
			end
		end
	end, connection:requestConnection(), "SELECT * FROM dutypoints")
end)


addEvent("sendMessageToPlayer", true)
addEventHandler("sendMessageToPlayer", root, function(e, msg, r, g, b)
	if(e and tostring(msg)) then
		if(not r and not g and not b) then
			r, g, b = 255, 255, 255
		else
			r, g, b = tonumber(r), tonumber(g), tonumber(b)
		end
		e:outputChat(msg, r, g, b, true)
	end
end)

addEvent("getDutyPoints", true)
addEventHandler("getDutyPoints", resourceRoot, function() 
	triggerClientEvent(client, "receiveDutyPoints", resourceRoot, dutyPoints)
end)

addEvent("playRadioSound", true)
addEventHandler("playRadioSound", root, function(e) 
	triggerClientEvent(e, "playRadioSoundClient", e)
end)