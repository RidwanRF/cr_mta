addEvent("createDutyPoint", true)
addEventHandler("createDutyPoint", root, function(player, faction, factionName)
	faction = tonumber(faction)
	local success = exports['cr_core']:getServerSyntax(false, "success")
	local error = exports['cr_core']:getServerSyntax(false, "error")
	local pos = player:getPosition()
	local name = factionName
	local int, dim = player:getInterior(), player:getDimension()
	local data = {["faction"] = faction, ["pos"] = {pos.x, pos.y, pos.z}, ["world"] = {int, dim}, ["name"] = name}
	local _, _, id = dbPoll(dbQuery(connection:requestConnection(), "INSERT INTO dutypoints SET data = ?", toJSON(data)), -1)
	setTimer(function(d, i) 
		loadDutyPoint(i, d)
		player:outputChat(success.."Duty point sikeresen létrehozva. ID: "..i, 255, 255, 255, true)
	end, 250, 1, data, id)
end)

addCommandHandler("deletedutypoint", function(player, cmd, id)
	id = tonumber(id)
	local success = exports['cr_core']:getServerSyntax(false, "success")
	local error = exports['cr_core']:getServerSyntax(false, "error")
	if(id) then
		if(dutyPoints[id]) then
			dutyPoints[id] = nil
			dbExec(connection:requestConnection(), "DELETE FROM dutypoints WHERE id = ?", id)
			triggerClientEvent(root, "receiveDutyPoints", resourceRoot, dutyPoints)
			triggerClientEvent(root, "deleteDutyPoint", resourceRoot, id)
			player:outputChat(success.."Duty point törölve. ID: "..id, 255, 255, 255, true)
		else
			player:outputChat(error.."Nincs ilyen duty point", 255, 255, 255, true)
		end
	else
		player:outputChat(error.."Használat: /"..cmd.." [ID]", 255, 255, 255, true)
	end
end)


