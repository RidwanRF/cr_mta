local _createVehicle = createVehicle;
function createVehicle(...)
	return _createVehicle(...);
end

function destroyVehicles()
	for key, value in ipairs(getElementsByType("vehicle", resourceRoot)) do
		destroyElement(value);
	end
end

local _createPickup = createPickup;
function createPickup(...)
	return _createPickup(...);
end

function destroyPickups()
	for key, value in ipairs(getElementsByType("pickup", resourceRoot)) do
		destroyElement(value);
	end
end

local _createMarker = createMarker;
function createMarker(...)
	return _createMarker(...)
end