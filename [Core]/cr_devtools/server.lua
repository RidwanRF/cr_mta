--[[
local connection = exports['cr_mysql']:getConnection

addEventHandler("onResourceStart", resourceRoot, function()
	-- törölt kocsik tisztítása
		dbQuery(function(qh)
			local res, rows, err = dbPoll(qh, 0)
			if rows > 0 then
				local itemsToDelete = ""
				local itemCount = 0
				
				for k, v in pairs(res) do
					local id = v["id"]
					exports.al_vehicle:removeDeletedVehicle(id)
					itemCount = itemCount + 1
					if itemCount == 1 then
						itemsToDelete = id
					else
						itemsToDelete = itemsToDelete .. ", "..id
					end
				end
				dbExec(connection, "DELETE FROM items WHERE itemID = 29 and itemValue IN("..itemsToDelete..")")
				dbExec(connection, "DELETE FROM items WHERE `type` = 2 and owner IN("..itemsToDelete..")")
				dbExec(connection, "DELETE FROM kocsik WHERE deleted = 1 AND UNIX_TIMESTAMP(deletedOn) <= UNIX_TIMESTAMP()-15552000")
			end
			outputDebugString("[VEHICLE-CLEAR] Successful cleared "..rows.." deleted vehicles.")
		end, connection, "SELECT id, deleted, deletedOn, deletedBy FROM kocsik WHERE deleted = 1 AND UNIX_TIMESTAMP(deletedOn) <= UNIX_TIMESTAMP()-15552000") -- 6 hónapos törlés (3600*24*30*6)
	-- vége
	
	-- report ürítés 4 hetente
		dbExec(connection, "DELETE FROM reportok WHERE datum < DATE_SUB(NOW(), INTERVAL 1 MONTH)")
		outputDebugString("[REPORT-CLEAR] Successful cleared.")
	-- vége
	
	-- adminchat ürítés 2 hetente
		dbExec(connection, "DELETE FROM adminchat WHERE datum < DATE_SUB(NOW(), INTERVAL 2 WEEK)")
		outputDebugString("[ADMINCHAT-CLEAR] Successful cleared.")
	-- vége
	
	-- ban ürítés ha lejárt
		dbExec(connection, "SELECT * FROM tiltasok WHERE lejar < NOW()")
		outputDebugString("[BAN-CLEAR] Successful cleared.")
	-- vége
end)]]

local resCount = {}
local addedToDebug = {}
addDebugHook("preFunction", function(sourceResource, functionName)
	if sourceResource and functionName then
		local resname = sourceResource and getResourceName(sourceResource)
		if not resCount[sourceResource] then
			resCount[sourceResource] = {}
		end
		if not resCount[sourceResource][functionName] then
			resCount[sourceResource][functionName] = 0
		end
		resCount[sourceResource][functionName] = resCount[sourceResource][functionName] + 1
		if resCount[sourceResource][functionName] > 15 and not addedToDebug["preFunction"..resname..functionName] then
			addedToDebug["preFunction"..resname..functionName] = true
			outputDebugString("1mp alatt 10szer lefutott -> preFunction => "..resname.." => "..functionName)
		end
	end
end)

addDebugHook("postFunction", function(sourceResource)
	if sourceResource and functionName then
		local resname = sourceResource and getResourceName(sourceResource)
		if not resCount[sourceResource] then
			resCount[sourceResource] = {}
		end
		if not resCount[sourceResource][functionName] then
			resCount[sourceResource][functionName] = 0
		end
		resCount[sourceResource][functionName] = resCount[sourceResource][functionName] + 1
		if resCount[sourceResource][functionName] > 15 and not addedToDebug["postFunction"..resname..functionName] then
			addedToDebug["postFunction"..resname..functionName] = true
			outputDebugString("1mp alatt 10szer lefutott -> postFunction => "..resname.." => "..functionName)
		end
	end
end)

setTimer(function()
	addedToDebug = {}
	resCount = {}
end, 1000, 1)