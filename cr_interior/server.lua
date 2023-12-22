local connection = exports['cr_mysql']:getConnection(getThisResource())

addEventHandler("onResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_mysql" then
			connection = exports['cr_mysql']:getConnection(getThisResource())
		elseif sResourceName == "cr_core" then
			orange = exports['cr_core']:getServerColor("orange", true)
		end
	end
)

addEventHandler("onResourceStart", resourceRoot, function() 
	Async:setPriority("high")
	Async:setDebug(true) 
end)

local cache = {}

local function loadInterior(id, value)
	local cacheValue = cache[id]
	if cacheValue then
		if isElement(cacheValue) then
			destroyElement(cacheValue)
		end
		cache[id] = nil
		loadInterior(id)
		return true
	else
		--for key, value in pairs(table) do
			local name, interior, cost, lock, owner, type, position, size = tostring(value["name"]), tonumber(value["interior"]), tonumber(value["cost"]), tonumber(value["lock"]), tonumber(value["owner"]), tonumber(value["type"]), fromJSON(value["position"]), tonumber(value["size"])
			local x, y, z, rotx, roty, rotz, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim = unpack(position)
			local r, g, b, a = unpack(globalTypeTable[type])
			local marker = createMarker(x, y, z, "cylinder", size, r, g, b, a, getRootElement())
			local exitmarker = createMarker(exitx, exity, exitz, "cylinder", size, 208, 36, 36, 100, getRootElement())
            marker.alpha = 0
            exitmarker.alpha = 0
			setElementInterior(marker, int)
			setElementDimension(marker, dim)
			setElementInterior(exitmarker, globalInteriorTable[interior][7] or 0)
			setElementDimension(exitmarker, id)
			setElementData(marker, "interior >> exitMarker", exitmarker)
			setElementData(exitmarker, "interior >> enterMarker", marker)
			setElementData(marker, "interior >> position", position)
			setElementData(marker, "interior >> lock", booleanFromNumber(lock))
			setElementData(marker, "interior >> owner", owner)
			setElementData(marker, "interior >> type", type)
			setElementData(marker, "interior >> cost", cost)
			setElementData(marker, "interior >> name", name)
			cache[id] = marker
			setElementData(marker, "interior >> id", id)
			if triggerLoad then
				triggerClientEvent(root, "onClientInteriorLoad", marker)
			end
			return true
		--end
		--dbQuery(
			--function(query)
				--local query, lines = dbPoll(query, 0)
				--if lines > 0 then
					-- for _, row in pairs(query) do
					--[[Async:foreach(table, function(row)
						local name, interior, cost, lock, owner, type, position, size = tostring(row["name"]), tonumber(row["interior"]), tonumber(row["cost"]), tonumber(row["lock"]), tonumber(row["owner"]), tonumber(row["type"]), fromJSON(row["position"]), tonumber(row["size"])
						local x, y, z, rotx, roty, rotz, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim = unpack(position)
						local r, g, b, a = unpack(globalTypeTable[type])
						local marker = createMarker(x, y, z, "cylinder", size, r, g, b, a, getRootElement())
						local exitmarker = createMarker(exitx, exity, exitz, "cylinder", size, 208, 36, 36, 100, getRootElement())
						setElementInterior(marker, int)
						setElementDimension(marker, dim)
						setElementInterior(exitmarker, globalInteriorTable[interior][7] or 0)
						setElementDimension(exitmarker, id)
						setElementData(marker, "interior >> exitMarker", exitmarker)
						setElementData(exitmarker, "interior >> enterMarker", marker)
						setElementData(marker, "interior >> position", position)
						setElementData(marker, "interior >> lock", booleanFromNumber(lock))
						setElementData(marker, "interior >> owner", owner)
						setElementData(marker, "interior >> type", type)
						setElementData(marker, "interior >> cost", cost)
						setElementData(marker, "interior >> name", name)
						cache[id] = marker
						setElementData(marker, "interior >> id", id)
						if triggerLoad then
							triggerClientEvent(root, "onClientInteriorLoad", marker)
						end
						return true
					end)]]
					-- end
				--end
			--end, connection, "SELECT * FROM `interior` WHERE `id`=?", id
		--)
	end
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		--[[dbQuery(
			function(query)
				local query, lines = dbPoll(query, 0)
				if lines > 0 then
					Async:foreach(query, function(row)
						loadInterior(row["id"], row)
					end)
				end
				triggerLoad = true
			end, connection, "SELECT * FROM `interior`"
		)]]

		dbQuery(function(queryHandler)
			local startTick = getTickCount();

			local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

			if numAffectedRows > 0 then
				for key, value in pairs(result) do
					loadInterior(value["id"], value);
				end
			end

			print("Loaded " .. numAffectedRows .. " interior(s) in " .. getTickCount() - startTick .. "ms");
		end, exports.cr_mysql:requestConnection(), "SELECT * FROM interior");
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for id, element in pairs(cache) do
			dbExec(connection, "UPDATE `interior` SET `lock`=?, `owner`=?, `position`=?, `cost`=?, `name`=? WHERE `id`=?", numberFromBoolean(getElementData(element, "interior >> lock")), tonumber(getElementData(element, "interior >> owner")), toJSON(getElementData(element, "interior >> position")), tonumber(getElementData(element, "interior >> cost")), tostring(getElementData(element, "interior >> name")), id)
		end
	end
)

addEvent("interior >> enter", true)
addEventHandler("interior >> enter", root,
	function(hitElement)
		if client and getElementType(client) == "player" then
            if client:getData("ghostMode") then return end
			local interiorID = getElementData(hitElement, "interior >> id")
			local parentMarker = getElementData(hitElement, "interior >> enterMarker")
			local lock
			if parentMarker then
				lock = getElementData(parentMarker, "interior >> lock")
			elseif interiorID then
				lock = getElementData(hitElement, "interior >> lock")
			end
			if not lock then
				local vehicle = getPedOccupiedVehicle(client)
				local markerElement = hitElement
				if parentMarker then
					markerElement = parentMarker
				end
                if vehicle and vehicle:getData("ghostMode") then return end
				if vehicle and getElementData(markerElement, "interior >> type") ~= 2 then
					exports['cr_infobox']:addBox(client, "error", "Járművel csak garázs interior-ba léphetsz be")
					return
				end
				if vehicle and getPedOccupiedVehicleSeat(client) ~= 0 then
					exports['cr_infobox']:addBox(client, "error", "Járművel csak a sofőr léphet be interior-ba")
					return
				end
				local x, y, z, rx, ry, rz, int, dim
				if interiorID then
					local childMarker = getElementData(hitElement, "interior >> exitMarker")
					_, _, _, _, _, _, x, y, z, rx, ry, rz = unpack(getElementData(hitElement, "interior >> position"))
					int, dim = getElementInterior(childMarker), getElementDimension(childMarker)
				elseif parentMarker then
					x, y, z, rx, ry, rz, _, _, _, _, _, _, int, dim = unpack(getElementData(parentMarker, "interior >> position"))
				end
                
                setElementFrozen(client, true)
				--toggleAllControls(client, false)
				--fadeCamera(client, false)
				triggerClientEvent(client, "interior >> enterResult", resourceRoot)
				--showChat(client, false)
				--setElementData(client, "hudVisible", false)
				--setElementData(client, "keysDenied", true)
				local element = client
                if vehicle then
                    setElementPosition(vehicle, x, y, z + 1.5)
                    setElementInterior(vehicle, int)
                    setElementDimension(vehicle, dim)
                    setElementRotation(vehicle, rx, ry, rz, "default", false)
                    for seat, element in pairs(getVehicleOccupants(vehicle)) do
                        --setElementPosition(element, x, y, z + 1.5)
                        setElementInterior(element, int)
                        setElementDimension(element, dim)
                        warpPedIntoVehicle(element, vehicle, seat)
                    end
                    
                    local element = vehicle
                    triggerClientEvent(root, "ghostMode", element, vehicle, "on")
                    
                    setTimer(
						function()
							--fadeCamera(element, true)
							--showChat(element, true)
							--setElementData(element, "hudVisible", true)
							setElementFrozen(element, false)
							--toggleAllControls(element, true)
						end, 3000, 1
					)
                    
                    setTimer(
						function()
							--fadeCamera(element, true)
							--showChat(element, true)
							--setElementData(element, "hudVisible", true)
							triggerClientEvent(root, "ghostMode", element, vehicle, "off")
							--toggleAllControls(element, true)
						end, 8000, 1
					)
                else
                    setElementPosition(element, x, y, z + 1.5)
                    setElementInterior(element, int)
                    setElementDimension(element, dim)
                    setElementRotation(element, rx, ry, rz, "default", true)
                    triggerClientEvent(root, "ghostMode", element, element, "on")
                    
                    setTimer(
						function()
							--fadeCamera(element, true)
							--showChat(element, true)
							--setElementData(element, "hudVisible", true)
							setElementFrozen(element, false)
							--toggleAllControls(element, true)
						end, 3000, 1
					)
                    
                    setTimer(
						function()
							--fadeCamera(element, true)
							--showChat(element, true)
							--setElementData(element, "hudVisible", true)
							triggerClientEvent(root, "ghostMode", element, element, "off")
							--toggleAllControls(element, true)
						end, 8000, 1
					)

                    setElementData(element, "interior->Datas", {
                        ["interior"] = int,
                        ["dimension"] = dim,
                        ["owner"] = getElementData(hitElement, "interior >> owner")
                    }); ---> cr_furniture
                end
                
				setTimer(
					function(element, interiorType, hitElement)
						--fadeCamera(element, true)
						--showChat(element, datas.hud)
						--setElementData(element, "hudVisible", datas.hud)
						--setElementData(element, "keysDenied", datas.keysDenied)
						--setElementFrozen(element, datas.freeze)
						--toggleAllControls(element, true)
                        --setElementData(element, "char >> bone", {true, true, true, true, true})
                        --setElementData(element, "char >> bone", datas.bone)
						if interiorType then
							if interiorType ~= 3 and interiorType ~= 4 then
								local interiorOwner = getElementData(hitElement, "interior >> owner")
								if not interiorOwner or interiorOwner == 0 then
									local interiorCost = getElementData(hitElement, "interior >> cost")
									exports['cr_infobox']:addBox(element, "info", "Ez az interior megvásárolható, megvásárolni a 'buyinterior' paranccsal tudod '" .. interiorCost .. "' dollárért")
								end
							end
						end
					end, 3000, 1, client, getElementData(hitElement, "interior >> type"), hitElement
				)
			else
				exports['cr_infobox']:addBox(client, "error", "Az interior be van zárva")
			end
		end
	end
)

addEvent("interior >> lock", true)
addEventHandler("interior >> lock", root,
	function(hitElement)
		if client and getElementType(client) == "player" then
			if not isPedInVehicle(client) then
				local markerElement = hitElement
				local parentMarker = getElementData(hitElement, "interior >> enterMarker")
				if parentMarker then
					markerElement = parentMarker
				end
				local interiorID = getElementData(markerElement, "interior >> id")
				local interiorType = getElementData(markerElement, "interior >> type")
				if exports['cr_inventory']:hasItem(client, 17, interiorID) or exports['cr_permission']:hasPermission(client, "forceInteriorLock") and not exports['cr_core']:getPlayerDeveloper(client) or exports['cr_core']:getPlayerDeveloper(client) and getElementData(client, "admin >> duty") then
					local newState = not getElementData(markerElement, "interior >> lock")
					if newState then
						exports['cr_chat']:createMessage(client, "behelyezi a kulcsot a zárba, majd bezárja az ajtót", 1)
					else
						exports['cr_chat']:createMessage(client, "behelyezi a kulcsot a zárba, majd kinyitja az ajtót", 1)
					end
					setElementData(markerElement, "interior >> lock", newState)
					triggerClientEvent(client, "interior >> lockResult", resourceRoot)
				else
					exports['cr_infobox']:addBox(client, "error", "Nincs kulcsod ehhez a(z) interior-hoz")
				end
			else
				exports['cr_infobox']:addBox(client, "error", "Járműben ülve nem zárhatod be az interior-t")
			end
		end
	end
)

addEvent("interior >> sendNot", true)
addEventHandler("interior >> sendNot", root,
	function(notType, hitElement)
		if client and getElementType(client) == "player" then
			local interiorID = getElementData(hitElement, "interior >> id")
			local x1, y1, z1, x2, y2, z2, dim1, dim2
			if not interiorID then
				local parentMarker = getElementData(hitElement, "interior >> enterMarker")
				interiorType = getElementData(parentMarker, "interior >> type")
				x1, y1, z1 = getElementPosition(parentMarker)
				dim1 = getElementDimension(parentMarker)
				x2, y2, z2 = getElementPosition(hitElement)
				dim2 = getElementDimension(hitElement)
			else
				local childMarker = getElementData(hitElement, "interior >> exitMarker")
				x1, y1, z1 = getElementPosition(hitElement)
				dim1 = getElementDimension(hitElement)
				x2, y2, z2 = getElementPosition(childMarker)
				dim2 = getElementDimension(childMarker)
			end
			setElementData(hitElement, "interior >> notTemp", {notType, x1, y1, z1, x2, y2, z2, dim1, dim2})
			setElementData(hitElement, "interior >> notTemp", false)
		end
	end
)

addCommandHandler("createinterior",
	function(player, cmd, type, interior, cost)
        local size = 0.8
		if exports['cr_permission']:hasPermission(player, "createinterior") then
			type, interior, cost, size = tonumber(type), tonumber(interior), tonumber(cost), tonumber(size)
			if not type or not interior or not size then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [type] [interior] [cost]", player, 255, 255, 255, true)
				return
			end
			if not globalTypeTable[type] then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Ilyen típussal nem lehet interiort létrehozni.", player, 255, 255, 255, true)
				return
			end
			if not globalInteriorTable[interior] then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Ilyen interior id-vel nem lehet interiort létrehozni.", player, 255, 255, 255, true)
				return
			end
			if cost < 0 then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Az interior cost-nak legalább 0-nak kell lennie.", player, 255, 255, 255, true)
				return
			end
			local name = getElementZoneName(player, false)
			local count = 1
			for id, element in pairs(cache) do
				if isElement(element) and getElementZoneName(element, false) == name then
					count = count + 1
				end
			end
			name = name .. " " .. tostring(count)
			local x, y, z = getElementPosition(player)
			z = z - 0.95
			local rotx, roty, rotz = getElementRotation(player)
			local exitx, exity, exitz, exitrotx, exitroty, exitrotz = unpack(globalInteriorTable[interior]) 
			local int, dim = getElementInterior(player), getElementDimension(player)
			local position = toJSON({x, y, z, rotx, roty, rotz, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim})
			dbExec(connection, "INSERT INTO `interior`(`name`,`interior`,`cost`,`lock`,`owner`,`type`,`position`,`size`) VALUES (?,?,?,?,?,?,?,?)", name, interior, cost, 0, 0, type, position, size)
            --outputChatBox("asd")
			dbQuery(
				function(query)
					local query, lines = dbPoll(query, 0)
					if lines > 0 then
						Async:foreach(query, function(row)
							local id = tonumber(row["id"])
							loadInterior(id, row)
							local syntax = exports['cr_core']:getServerSyntax(false, "success")
							outputChatBox(syntax .. "Sikeresen létrehoztál egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
							local syntax = exports['cr_admin']:getAdminSyntax()
							local aName = exports['cr_admin']:getAdminName(player, true)
							exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF létrehozott egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 8)
						end)
					end
				end, connection, "SELECT * FROM `interior` WHERE `name`=? and `interior`=? and `cost`=? and `type`=? and `position`=?", name, interior, cost, type, position
			)
		end
	end
)

addCommandHandler("deleteinterior",
	function(player, cmd, id)
		if exports['cr_permission']:hasPermission(player, "deleteinterior") then
			id = tonumber(id)
			if not id then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
				return
			end
			local marker = cache[id]
			if not marker then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			local exitmarker = getElementData(marker, "interior >> exitMarker")
			if isElement(exitmarker) then
				destroyElement(exitmarker)
			end
			if isElement(marker) then
				destroyElement(marker)
			end
			cache[id] = nil
			dbExec(connection, "DELETE FROM `interior` WHERE `id`=?", id)
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen töröltél egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF törölt egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 8)
		end
	end
)

addCommandHandler("buyinterior",
	function(player)
		if not getElementData(player, "loggedIn") then return end
		local dimension = getElementDimension(player)
		if dimension == 0 then
			exports['cr_infobox']:addBox(player, "error", "Nem vagy interior-ban")
			return
		end
		local interior = getElementInterior(player)
		local markerElement
		local interiorCount = 0
		local accountID = getElementData(player, "acc >> id")
		for id, element in pairs(cache) do
			local exitMarker = getElementData(element, "interior >> exitMarker")
			if getElementDimension(exitMarker) == dimension and getElementInterior(exitMarker) == interior then
				markerElement = element
			end
			if getElementData(element, "interior >> owner") == accountID then
				interiorCount = interiorCount + 1
			end
		end
		if interiorCount < getElementData(player, "char >> interiorLimit") then
			if markerElement then
				local interiorType = getElementData(markerElement, "interior >> type")
				if interiorType ~= 3 and interiorType ~= 4 then
					local interiorOwner = getElementData(markerElement, "interior >> owner")
					if not interiorOwner or interiorOwner == 0 then
						local interiorCost = getElementData(markerElement, "interior >> cost")
						if interiorCost then
							local currentMoney = getElementData(player, "char >> money")
							local newMoney = currentMoney - interiorCost
							if newMoney >= 0 then
								setElementData(player, "char >> money", newMoney)
								local accountID = getElementData(player, "acc >> id")
								setElementData(markerElement, "interior >> owner", accountID)
								exports['cr_inventory']:giveItem(player, 17, getElementData(markerElement, "interior >> id"))
								exports['cr_infobox']:addBox(player, "success", "Sikeresen megvásároltad az interior-t")

								setElementData(player, "interior->Datas", {
									["interior"] = player.interior,
									["dimension"] = player.dimension,
									["owner"] = accountID
								}); ---> cr_furniture
							else
								exports['cr_infobox']:addBox(player, "error", "Nincs elég pénzed az interior megvásárlásához")
							end
						end
					else
						exports['cr_infobox']:addBox(player, "error", "Ez az interior nem eladó")
					end
				else
					exports['cr_infobox']:addBox(player, "error", "Ez az interior nem eladó")
				end
			else
				exports['cr_infobox']:addBox(player, "error", "Nem vagy interior-ban")
			end
		else
			exports['cr_infobox']:addBox(player, "error", "Nincs elég szabad slotod az interior megvásárlásához")
		end
	end
)

addCommandHandler("loadinterior",
	function(player, cmd, id)
		if exports['cr_permission']:hasPermission(player, "loadinterior") then
			id = tonumber(id)
			if not id then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
				return
			end
			local result = loadInterior(id)
			if result then
				local syntax = exports['cr_core']:getServerSyntax(false, "success")
				outputChatBox(syntax .. "Sikeresen betöltöttél egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
				local syntax = exports['cr_admin']:getAdminSyntax()
				local aName = exports['cr_admin']:getAdminName(player, true)
				exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF betöltött egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 9)
			else
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Hiba történt az interior betöltése közben (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
			end
		end
	end
)

addCommandHandler("renameinterior",
	function(player, cmd, id, name)
		if exports['cr_permission']:hasPermission(player, "renameinterior") then
			id, name = tonumber(id), tostring(name)
			if not id or not name or string.len(name) == 0 then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id] [name]", player, 255, 255, 255, true)
				return
			end
			local element = cache[id]
			if not element then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			setElementData(element, "interior >> name", name)
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen átneveztél egy interiort (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új név: " .. orange .. name .. "#FFFFFF).", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF átnevezett egy interior-t (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új név: " .. orange .. name .. "#FFFFFF).", 8)
		end
	end
)

addCommandHandler("setinteriorcost",
	function(player, cmd, id, cost)
		if exports['cr_permission']:hasPermission(player, "setinteriorcost") then
			id, cost = tonumber(id), tonumber(cost)
			if not id or not cost or cost < 0 then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id] [cost]", player, 255, 255, 255, true)
				return
			end
			local element = cache[id]
			if not element then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			setElementData(element, "interior >> cost", cost)
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen megváltoztattad egy interior árát (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új ár: " .. orange .. tostring(cost) .. "#FFFFFF).", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF megváltoztatta egy interior árát (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új ár: " .. orange .. tostring(cost) .. "#FFFFFF).", 8)
		end
	end
)

addCommandHandler("setinteriorowner",
	function(player, cmd, id, target)
		if exports['cr_permission']:hasPermission(player, "setinteriorcost") then
			id, target = tonumber(id), tostring(target)
			if not id or not target then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id] [target]", player, 255, 255, 255, true)
				return
			end
			local element = cache[id]
			if not element then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			target = exports['cr_core']:findPlayer(player, target)
			if not target then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs ilyen játékos.", player, 255, 255, 255, true)
				return
			end
			local accountID = getElementData(target, "acc >> id")
			if not accountID then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "A játékosnak nincs 'acc >> id' értéke.", player, 255, 255, 255, true)
				return
			end
			setElementData(element, "interior >> owner", accountID)
			local charName = getElementData(target, "char >> name") or "Ismeretlen"
			charName = charName:gsub("_", " ")
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen megváltoztattad egy interior tulajdonosát (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új tulajdonos: " .. orange .. charName .. "#FFFFFF).", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF megváltoztatta egy interior tulajdonosát (ID: " .. orange .. tostring(id) .. "#FFFFFF, Új tulajdonos: " .. orange .. charName .. "#FFFFFF).", 8)
		end
	end
)

addCommandHandler("thisinterior",
	function(player)
		for id, element in pairs(cache) do
			if isElementWithinMarker(player, element) then
				local syntax = exports['cr_core']:getServerSyntax(false, "success")
				outputChatBox(syntax .. "Az interior id-je: " .. orange .. tostring(id), player, 255, 255, 255, true)
				break
			end
		end
	end
)

addCommandHandler("moveinteriorenter",
	function(player, cmd, id)
		if exports['cr_permission']:hasPermission(player, "moveinteriorenter") then
			id = tonumber(id)
			if not id then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
				return
			end
			local element = cache[id]
			if not element then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			local playerX, playerY, playerZ = getElementPosition(player)
			playerZ = playerZ - 0.95
			local rotX, rotY, rotZ = getElementRotation(player)
			setElementPosition(element, playerX, playerY, playerZ)
			local x, y, z, rotx, roty, rotz, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim = unpack(getElementData(element, "interior >> position"))
			setElementData(element, "interior >> position", {playerX, playerY, playerZ, rotX, rotY, rotZ, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim})
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen megváltoztattad egy interior enter pozícióját (ID: " .. orange .. tostring(id) .. "#FFFFFF).", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF megváltoztatta egy interior enter pozícióját (ID: " .. orange .. tostring(id) .. "#FFFFFF).", 8)
		end
	end
)

addCommandHandler("moveinteriorexit",
	function(player, cmd, id)
		if exports['cr_permission']:hasPermission(player, "moveinteriorexit") then
			id = tonumber(id)
			if not id then
				local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
				return
			end
			local element = cache[id]
			if not element then
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				outputChatBox(syntax .. "Nincs interior ilyen id-vel.", player, 255, 255, 255, true)
				return
			end
			local childMarker = getElementData(element, "interior >> exitMarker")
			local playerX, playerY, playerZ = getElementPosition(player)
			playerZ = playerZ - 0.95
			local rotX, rotY, rotZ = getElementRotation(player)
			setElementPosition(childMarker, playerX, playerY, playerZ)
			local x, y, z, rotx, roty, rotz, exitx, exity, exitz, exitrotx, exitroty, exitrotz, int, dim = unpack(getElementData(element, "interior >> position"))
			setElementData(element, "interior >> position", {x, y, z, rotx, roty, rotz, playerX, playerY, playerZ, rotX, rotY, rotZ, int, dim})
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			outputChatBox(syntax .. "Sikeresen megváltoztattad egy interior exit pozícióját (ID: " .. orange .. tostring(id) .. "#FFFFFF).", player, 255, 255, 255, true)
			local syntax = exports['cr_admin']:getAdminSyntax()
			local aName = exports['cr_admin']:getAdminName(player, true)
			exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF megváltoztatta egy interior exit pozícióját (ID: " .. orange .. tostring(id) .. "#FFFFFF).", 8)
		end
	end
)

function booleanFromNumber(num)
	local num = tonumber(num)
	if num then
		if num == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function numberFromBoolean(bool)
	if bool then
		return 1
	else
		return 0
	end
end