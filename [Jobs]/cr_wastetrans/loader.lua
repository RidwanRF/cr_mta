connection = exports.cr_mysql:requestConnection();
wasteTable = {};

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(query) 
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			Async:foreach(query, function(v) 
				loadWaste(v)
			end)
			outputDebugString(query_lines.." szemétdomb betöltve.")
		end
	end, connection, "SELECT * FROM wastetrans")
end)

function loadWaste(data)
	local id = data["id"]
	local data = fromJSON(data["data"])
	if(id) then
		local x, y, z = unpack(data["pos"])
		local obj = createObject(10985, x, y, z)
		obj:setData("job >> data", {["wasteID"] = id, ["job"] = 4, ["waste"] = true})
		wasteTable[id] = obj
	end
end

addCommandHandler("addwaste", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		local pos = player:getPosition()
		local data = {["pos"] = {pos.x, pos.y, pos.z}} 
		dbExec(connection, "INSERT INTO wastetrans SET data = ?", toJSON(data))
		dbQuery(function(query) 
			local query, query_lines = dbPoll(query, 0)
			if(query_lines > 0) then
				for i, v in pairs(query) do
					loadWaste(v)
					player:outputChat(msgs["success"].."Szemétdomb létrehozva. ID: "..v["id"], 255, 255, 255, true)
				end
			end
		end, connection, "SELECT * FROM wastetrans WHERE data = ?", toJSON(data))
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("delwaste", function(player, cmd, id)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		if(id ~= nil and tonumber(id)) then
			id = tonumber(id)
			if(isElement(wasteTable[id])) then
				dbExec(connection, "DELETE FROM wastetrans WHERE id = ?", id)
				wasteTable[id]:destroy()
				player:outputChat(msgs["success"].."#"..id.." szemétdomb törölve.", 255, 255, 255, true)
			else
				player:outputChat(msgs["error"].."Nem létező szemétdomb.", 255, 255, 255, true)
			end
		else
			player:outputChat(msgs["info"].."Használat: /"..cmd.." [ID]", 255, 255, 255, true)
		end
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("nearbywaste", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		player:outputChat(msgs["info"].." Közeli szemétdombok:", 255, 255, 255, true)
		Async:foreach(getElementsByType("object"), function(val)
			if(getElementJobData(val, "waste")) then
				local pos1, pos2 = val:getPosition(), player:getPosition()
				if(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z) <= 20) then
					player:outputChat("#"..getElementJobData(val, "wasteID").." | Távolság: "..math.floor(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)).." yard", 255, 255, 255, true)
				end
			end
		end)
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)