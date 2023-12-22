local connection = exports['cr_mysql']:getConnection(getThisResource())
local orange = exports['cr_core']:getServerColor("orange", true)

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

local function loadElevator(row)
	local id = tonumber(row["id"])
	local cacheValue = cache[id]
	if(cacheValue) then
		cache[id] = nil
		loadElevator(id)
		return
	end
	
	local position, size = fromJSON(row["position"]), tonumber(row["size"])
	local x1, y1, z1, rx1, ry1, rz1, int1, dim1, x2, y2, z2, rx2, ry2, rz2, int2, dim2 = unpack(position)
	local marker1 = createMarker(x1, y1, z1, "cylinder", size, r, g, b, a, getRootElement())
	setElementInterior(marker1, int1)
	setElementDimension(marker1, dim1)
    marker1.alpha = 0
	local marker2 = createMarker(x2, y2, z2, "cylinder", size, r, g, b, a, getRootElement())
	setElementInterior(marker2, int2)
	setElementDimension(marker2, dim2)
    marker2.alpha = 0
	setElementData(marker1, "elevator >> targetPosition", {x2, y2, z2, rx2, ry2, rz2, int2, dim2})
	setElementData(marker2, "elevator >> targetPosition", {x1, y1, z1, rx1, ry1, rz1, int1, dim1})
	setElementData(marker1, "elevator >> id", id)
	setElementData(marker2, "elevator >> id", id)
	cache[id] = {marker1, marker2}
	return true
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		dbQuery(
			function(query)
				local query, lines = dbPoll(query, 0)
				if lines > 0 then
					Async:foreach(query, function(row)
						loadElevator(row)
					end)
				end
			end, connection, "SELECT * FROM `elevator`"
		)
	end
)

function createElevator(player, cmd, x2, y2, z2, rx2, ry2, rz2, int2, dim2)
    if exports['cr_permission']:hasPermission(player, "createelevator") then
        size, x2, y2, z2, rx2, ry2, rz2, int2, dim2 = tonumber(size), tonumber(x2), tonumber(y2), tonumber(z2), tonumber(rx2), tonumber(ry2), tonumber(rz2), tonumber(int2), tonumber(dim2)
        size = 0.8
        if not size or not x2 or not y2 or not z2 or not rx2 or not ry2 or not rz2 or not int2 or not dim2 then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/" .. cmd .. " [x] [y] [z] [rx] [ry] [rz] [int] [dim]", player, 255, 255, 255, true)
            return
        end
        local x1, y1, z1 = getElementPosition(player)
        z1 = z1 - 0.95
        local rx1, ry1, rz1 = getElementRotation(player)
        local int1, dim1 = getElementInterior(player), getElementDimension(player)
        local position = toJSON({x1, y1, z1, rx1, ry1, rz1, int1, dim1, x2, y2, z2, rx2, ry2, rz2, int2, dim2})
        dbExec(connection, "INSERT INTO `elevator`(`position`,`size`) VALUES (?,?)", position, size)
        dbQuery(
            function(query)
                local query, lines = dbPoll(query, 0)
                if lines > 0 then
                    Async:foreach(query, function(row)
                        local id = tonumber(row["id"])
                        loadElevator(row)
                        local syntax = exports['cr_core']:getServerSyntax(false, "success")
                        outputChatBox(syntax .. "Sikeresen létrehoztál egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
                        local syntax = exports['cr_admin']:getAdminSyntax()
                        local aName = exports['cr_admin']:getAdminName(player, true)
                        exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF létrehozott egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 8)
                    end)
                end
            end, connection, "SELECT * FROM `elevator` WHERE `position`=? and `size`=?", position, size
        )
    end
end
addCommandHandler("createelevator", createElevator)
addCommandHandler("createlevator", createElevator)
addCommandHandler("addelevator", createElevator)

function deleteElevator(player, cmd, id)
    if exports['cr_permission']:hasPermission(player, "deleteelevator") then
        id = tonumber(id)
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
            return
        end
        local marker = cache[id]
        if not marker then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs elevator ilyen id-vel.", player, 255, 255, 255, true)
            return
        end
        for _, element in pairs(cache[id]) do
            if isElement(element) then
                destroyElement(element)
            end
        end
        dbExec(connection, "DELETE FROM `elevator` WHERE `id`=?", id)
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Sikeresen töröltél egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
        local syntax = exports['cr_admin']:getAdminSyntax()
        local aName = exports['cr_admin']:getAdminName(player, true)
        exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF törölt egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 8)
    end
end
addCommandHandler("deleteelevator", deleteElevator)
addCommandHandler("deletelevator", deleteElevator)
addCommandHandler("delelevator", deleteElevator)

-- addCommandHandler("loadelevator",
	-- function(player, cmd, id)
		-- if exports['cr_permission']:hasPermission(player, "loadelevator") then
			-- id = tonumber(id)
			-- if not id then
				-- local syntax = exports['cr_core']:getServerSyntax(false, "warning")
				-- outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true)
				-- return
			-- end
			-- local qh = dbPoll(dbQuery(conn, "SELECT * FROM elevator WHERE id = ?", id), 0)
			-- local result = false
			-- Async:foreach(qh, function(row)
				-- result = loadElevator(row)
			-- end)
			-- if result then
				-- local syntax = exports['cr_core']:getServerSyntax(false, "success")
				-- outputChatBox(syntax .. "Sikeresen betöltöttél egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
				-- local syntax = exports['cr_admin']:getAdminSyntax()
				-- local aName = exports['cr_admin']:getAdminName(player, true)
				-- exports['cr_core']:sendMessageToAdmin(player, syntax .. orange .. aName .. "#FFFFFF betöltött egy elevator-t (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", 9)
			-- else
				-- local syntax = exports['cr_core']:getServerSyntax(false, "error")
				-- outputChatBox(syntax .. "Hiba történt az elevator betöltése közben (ID: " .. orange .. tostring(id) .. "#FFFFFF" .. ").", player, 255, 255, 255, true)
			-- end
		-- end
	-- end
-- )

addCommandHandler("thiselevator",
	function(player)
		for id, elementTable in pairs(cache) do
			for key, element in pairs(elementTable) do
				if isElementWithinMarker(player, element) then
					local syntax = exports['cr_core']:getServerSyntax(false, "success")
					outputChatBox(syntax .. "Az elevator id-je: " .. orange .. tostring(id), player, 255, 255, 255, true)
					break
				end
			end
		end
	end
)

addEvent("elevator >> enter", true)
addEventHandler("elevator >> enter", root,
	function(hitElement)
		if client and getElementType(client) == "player" then
            if client:getData("ghostMode")then return end
			if not isPedInVehicle(client) then
				local position = getElementData(hitElement, "elevator >> targetPosition")
				if position then
					local x, y, z, rx, ry, rz, int, dim = unpack(position)
					setElementFrozen(client, true)
					--toggleAllControls(client, false)
					--fadeCamera(client, false)
					--showChat(client, false)
					--setElementData(client, "hudVisible", false)
                    local element = client
                    
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
				end
			end
		end
	end
)
