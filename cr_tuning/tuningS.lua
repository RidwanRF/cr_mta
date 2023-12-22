local mysql = exports.cr_mysql;

local cloneVehicles = {};

addEventHandler("onResourceStart", resourceRoot, function()
	local r, g, b = exports.cr_core:getServerColor("orange");

	for key, value in pairs(markerPositions) do
		table.insert(tuningMarkers, Marker(Vector3(value), "cylinder", 4, r, g, b, 100));
	end
end);

addEventHandler("onMarkerHit", root, function(element)
	if element.type == "player" and element.vehicle and element.vehicleSeat == 0 then
		if allowedTypes[element.vehicle.vehicleType] and checkMarker(source) then
			source.dimension = 1;

			element.vehicle.frozen = true;
			element.vehicle.position = Vector3(source.position.x, source.position.y, source.position.z + 2.3);

			setTimer(function()
				element.vehicle.frozen = false;
			end, 150, 1);

			cloneVehicles[element] = element.vehicle:clone(Vector3(clonePosition));
			cloneVehicles[element].dimension = getElementData(element, "acc >> id") + 1;
			element.dimension = getElementData(element, "acc >> id") + 1;
			setCameraMatrix(element, unpack(cameraPosition));

			triggerClientEvent(element, "onClientTuningMarkerHit", element, element, source, cloneVehicles[element]);
		end
	end
end);

addEvent("onTuningMarkerLeave", true);
addEventHandler("onTuningMarkerLeave", root, function(player, marker, vehicle)
	if client and client == player and marker and vehicle then
		player.dimension = 0;
		setCameraTarget(player);

		destroyElement(vehicle);
		cloneVehicles[player] = nil;

		setTimer(function()
			marker.dimension = 0;
		end, 2000, 1);
	end
end);

function setVehicleHandlingFlags(vehicle, byte, value)
	if vehicle then
		local handlingFlags = string.format("%X", getVehicleHandling(vehicle)["handlingFlags"])
		local reversedFlags = string.reverse(handlingFlags) .. string.rep("0", 8 - string.len(handlingFlags))
		local currentByte, flags = 1, ""
		
		for values in string.gmatch(reversedFlags, ".") do
			if type(byte) == "table" then
				for _, v in ipairs(byte) do
					if currentByte == v then
						values = string.format("%X", tonumber(value))
					end
				end
			else
				if currentByte == byte then
					values = string.format("%X", tonumber(value))
				end
			end
			
			flags = flags .. values
			currentByte = currentByte + 1
		end
		
		setVehicleHandling(vehicle, "handlingFlags", tonumber("0x" .. string.reverse(flags)), false)
	end
end

function checkMarker(marker)
	for key, value in pairs(tuningMarkers) do
		if value == marker then
			return true;
		end
	end

	return false;
end