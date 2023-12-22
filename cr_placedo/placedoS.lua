addCommandHandler("placedo", function(player, cmd, ...)
	if getElementData(player, "loggedIn") then
		if ... then
			local text = table.concat({...}, " ");

			if text:gsub(" ", ""):len() > 50 then
				exports.cr_infobox:addBox(player, "error", "Túl hosszú szöveg");
			else
				addPlaceDo(player, text);
			end
		else
			local syntax = exports.cr_core:getServerSyntax(false, "warning");
            outputChatBox(syntax .. "/" .. cmd .. " [üzenet]", player, 255, 255, 255, true);
		end
	end
end);

local placeDos = {};
local index = 1;

function addPlaceDo(player, message)
	local id = getElementData(player, "acc >> id");

	if not placeDos[id] then
		placeDos[id] = {};
	end

	if #placeDos[id] < 3 then
		local time = getRealTime();
        time.hour = time.hour + 10
		local created = ("%02d"):format(time.hour  - 1 < 0 and time.hour + 23 or time.hour - 1) .. ":" .. ("%02d"):format(time.minute) .. ":" .. ("%02d"):format(time.second);

		marker = exports.cr_elements:createMarker(player.position, "cylinder", 0, 0, 0, 0, 0);
		marker.interior = player.interior;
		marker.dimension = player.dimension;
		setElementData(marker, "marker->Datas", {
			owner = id,
			id = index,
			player = getElementData(player, "char >> name"):gsub("_", " "),
			msg = message:gsub("^%l", string.upper),
			position = player.position,
			interior = player.interior,
			dimension = player.dimension,
			created = created,
			delete = 60
		});
		
		table.insert(placeDos[id], marker);

		print(getElementData(player, "char >> name"):gsub("_", " ") .. " created a placedo with '" .. message .. "' message (ID: " .. index .. ")");
		index = index + 1;
	end
end

addCommandHandler("delplacedo", function(player, cmd, placedoId)
	if exports.cr_permission:hasPermission(player, cmd) then
		if tonumber(placedoId) then
			for id, placedos in pairs(placeDos) do
				for key, marker in pairs(placedos) do
					if isElement(marker) then
						local value = getElementData(marker, "marker->Datas");

						if value.id == tonumber(placedoId) then
							destroyElement(marker);

							table.remove(placeDos[id], key);
						end
					end
				end
			end
		else
			local syntax = exports.cr_core:getServerSyntax(false, "warning");
            outputChatBox(syntax .. "/" .. cmd .. " [id]", player, 255, 255, 255, true);
		end
	end
end);

function delplacedo(placedoId)
    if tonumber(placedoId) then
        for id, placedos in pairs(placeDos) do
            for key, marker in pairs(placedos) do
                if isElement(marker) then
                    local value = getElementData(marker, "marker->Datas");

                    if value.id == tonumber(placedoId) then
                        destroyElement(marker);

                        table.remove(placeDos[id], key);
                    end
                end
            end
        end
    end
end
addEvent("delplacedo", true)
addEventHandler("delplacedo", root, delplacedo)

function updatePlacedoPos(placedoId, pos)
    if tonumber(placedoId) then
        for id, placedos in pairs(placeDos) do
            for key, marker in pairs(placedos) do
                if isElement(marker) then
                    local value = getElementData(marker, "marker->Datas");

                    if value.id == tonumber(placedoId) then
                        --destroyElement(marker);

                        --table.remove(placeDos[id], key);
                        marker.position = Vector3(unpack(pos))
                        marker:setData("editing", false)
                        --outputChatBox("sync")
                    end
                end
            end
        end
    end
end
addEvent("updatePlacedoPos", true)
addEventHandler("updatePlacedoPos", root, updatePlacedoPos)

addEventHandler("onResourceStart", resourceRoot, function()
	for key, value in pairs(getElementsByType("marker"), getResourceFromName("cr_elements")) do
		if getElementData(value, "marker->Datas") then
			local id = getElementData(value, "marker->Datas").owner;
			index = getElementData(value, "marker->Datas").id + 1;

			if not placeDos[id] then
				placeDos[id] = {};
			end

			table.insert(placeDos[id], value);
		end
	end
end);

setTimer(function()
	for id, placedos in pairs(placeDos) do
		for key, marker in pairs(placedos) do
			if isElement(marker) then
				local value = getElementData(marker, "marker->Datas");
				value.delete = value.delete - 1;

				setElementData(marker, "marker->Datas", value);

				if value.delete == 0 then
					destroyElement(marker);

					table.remove(placeDos[id], key);
				end
			end
		end
	end
end, 1000 * 60, 0);