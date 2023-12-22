conn = exports['cr_mysql']:getConnection(getThisResource());
trees = {};

addEventHandler("onResourceStart", resourceRoot, function()
	Async:setPriority("high")
	Async:setDebug(true) 
	setTimer(function() 
		dbQuery(function(query) 
			local query, query_lines = dbPoll(query, 0)
			if(query_lines > 0) then
				Async:foreach(query, function(row)
					local id, data = tonumber(row["id"]), fromJSON(row["data"])
					loadTree(id, data)
				end)
				-- dbFree(query)
			end
		end, conn, "SELECT * FROM lumberjack")
	end, 1000, 1)
end)

addCommandHandler("addtree", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		local pos = player:getPosition()
		local data = {["pos"] = {pos.x, pos.y, pos.z-1.25}}
		local qh = dbExec(conn, "INSERT INTO lumberjack SET data = ?", toJSON(data))
		dbQuery(function(query) 
			local query, query_lines = dbPoll(query, 0)
			if(query_lines > 0) then
				for i, v in pairs(query) do
					loadTree(v["id"], data)
					player:outputChat(msgs["info"].."Fa létrehozva. ID: #"..v["id"], 255, 255, 255, true)
				end
			end
		end, conn, "SELECT * FROM lumberjack WHERE data = ?", toJSON(data))
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("deltree", function(player, cmd, id)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		if(isElement(trees[tonumber(id)]) or not id or id == nil) then
			trees[tonumber(id)]:destroy()
			dbExec(conn, "DELETE FROM lumberjack WHERE id = ?", tonumber(id))
			player:outputChat(msgs["info"].."Fa kitörölve: #"..id, 255, 255, 255, true)
		else
			player:outputChat(msgs["error"].."Nem létező fa.", 255, 255, 255, true)	
		end
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

addCommandHandler("nearbytrees", function(player, cmd)
	if(exports.cr_permission:hasPermission(player, cmd)) then
		player:outputChat(msgs["info"].." Közeli fák:", 255, 255, 255, true)
		Async:foreach(getElementsByType("object"), function(val)
			if(getElementJobData(val, "treeObjective")) then
				local pos1, pos2 = val:getPosition(), player:getPosition()
				if(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z) <= 5) then
					player:outputChat("#"..getElementJobData(val, "treeID").." | Távolság: "..math.floor(getDistanceBetweenPoints3D(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)).." yard", 255, 255, 255, true)
				end
			end
		end)
	else
		player:outputChat(msgs["error"].."Neked nincs ehhez jogod.", 255, 255, 255, true)
	end
end)

function loadTree(id, data)
	if(tonumber(id)) then
		local x, y, z = unpack(data["pos"])
		trees[id] = createObject(618, x, y, z)
		trees[id]:setData("job >> data", {["job"] = 2, ["treeObjective"] = true, ["treeID"] = id, ["treeType"] = 1, ["z"] = z})
	end
end