conn = exports['cr_mysql']:getConnection(getThisResource());
rocks = {};

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query) 
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			Async:foreach(query, function(row)
				local id, data = tonumber(row["id"]), fromJSON(row["data"])
				loadRock(id, data)
			end)
		end
	end, conn, "SELECT * FROM miner")
end)

addCommandHandler("addrock", function(player, cmd, t)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		if(t ~= nil and tonumber(t) > 0 and tonumber(t) < 5) then  
			local pos = player:getPosition()
			local data = {["type"] = tonumber(t), ["pos"] = {pos.x, pos.y, pos.z-1.25}}
			dbExec(conn, "INSERT INTO miner SET data = ?", toJSON(data))
			dbQuery(function(query)
				local query, query_lines = dbPoll(query, 0)
				if(query_lines > 0) then
					for i, v in pairs(query) do
						loadRock(v["id"], data)
						player:outputChat(msgs["info"].."Kő létrehozva. ID: #"..v["id"], 255, 255, 255, true)
					end
				end
			end, conn, "SELECT * FROM miner WHERE data = ?", toJSON(data))
		else
			player:outputChat(msgs["error"].."Használat: /"..cmd.." [Típus (1-4)]", 255, 255, 255, true)
		end
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("delrock", function(player, cmd, id) 
	if(exports.cr_permission:hasPermission(player, cmd)) then
		if(isElement(rocks[tonumber(id)]) or not id or id == nil) then
			rocks[tonumber(id)]:destroy()
			dbExec(conn, "DELETE FROM miner WHERE id = ?", tonumber(id))
			player:outputChat(msgs["info"].."Kő kitörölve: #"..id, 255, 255, 255, true)
		else
			player:outputChat(msgs["error"].."Nem létező kő.", 255, 255, 255, true)	
		end
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("nearbyrocks", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		player:outputChat(msgs["info"].." Közeli kövek:", 255, 255, 255, true)
		Async:foreach(getElementsByType("object"), function(val)
			if(getElementJobData(val, "rockObjective")) then
				local pos1, pos2 = val:getPosition(), player:getPosition()
				if(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z) <= 5) then
					player:outputChat("#"..getElementJobData(val, "rockID").." | Típus: "..getElementJobData(val, "rockType").." | Távolság: "..math.floor(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)).." yard", 255, 255, 255, true)
				end
			end
		end)
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

function loadRock(id, data)
	if(tonumber(id)) then
		local x, y, z = unpack(data["pos"])
		rocks[id] = createObject(758, x, y, z)
		rocks[id]:setData("job >> data", {["job"] = 1, ["rockObjective"] = true, ["rockID"] = id, ["rockType"] = tonumber(data["type"])})
		rocks[id]:setData("job >> leftRock", math.random(2, 10))
	end
end