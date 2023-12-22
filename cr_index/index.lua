local cache = {};
local lights = {};

addEventHandler("onClientResourceStart", resourceRoot, function()
	for key, value in pairs(getElementsByType("vehicle")) do
		local array = getElementData(value, "veh:IndicatorState") or {left = false, right = false};

		if isElementStreamedIn(value) then
			if not array.left and getVehicleComponentVisible(value, "indicator_lf") then
				setVehicleComponentVisible(value, "indicator_lf", false);
				setVehicleComponentVisible(value, "indicator_rl", false);
			end

			if not array.right and getVehicleComponentVisible(value, "indicator_rf") then
				setVehicleComponentVisible(value, "indicator_rf", false);
				setVehicleComponentVisible(value, "indicator_rr", false);
			end
		end

		if isElementStreamedIn(value) and (array.left or array.right) then
			cache[value] = {left = array.left, right = array.right};
		end
	end
end);

addEventHandler("onClientElementDataChange", root, function(data, old, new)
	if source and source.type == "vehicle" and data == "veh:IndicatorState" then
		local vehicle = source;

		if not cache[vehicle] then
			if isElementStreamedIn(vehicle) then
				cache[vehicle] = {left = new.left, right = new.right};
			end
		else
			if old.left and not new.left then
				setVehicleComponentVisible(vehicle, "indicator_lf", false);
				setVehicleComponentVisible(vehicle, "indicator_rl", false);

				if isElement(lights[vehicle][1]) then
					destroyElement(lights[vehicle][1]);
				end

				if isElement(lights[vehicle][2]) then
					destroyElement(lights[vehicle][2]);
				end
			end

			if old.right and not new.right then
				setVehicleComponentVisible(vehicle, "indicator_rf", false);
				setVehicleComponentVisible(vehicle, "indicator_rr", false);

				if isElement(lights[vehicle][3]) then
					destroyElement(lights[vehicle][3]);
				end

				if isElement(lights[vehicle][4]) then
					destroyElement(lights[vehicle][4]);
				end
			end

			if not new.left and not new.right then
				cache[vehicle] = nil;
			else
				cache[vehicle] = {left = new.left, right = new.right};
			end
		end
	end
end);

addEventHandler("onClientElementStreamedIn", root, function()
	if source.type == "vehicle" then
		if not getElementData(source, "veh:IndicatorState").left and getVehicleComponentVisible(source, "indicator_lf") then
			setVehicleComponentVisible(source, "indicator_lf", false);
			setVehicleComponentVisible(source, "indicator_rl", false);
		end

		if not getElementData(source, "veh:IndicatorState").right and getVehicleComponentVisible(source, "indicator_rf") then
			setVehicleComponentVisible(source, "indicator_rf", false);
			setVehicleComponentVisible(source, "indicator_rr", false);
		end

		if getElementData(source, "veh:IndicatorState").left or getElementData(source, "veh:IndicatorState").right then
			cache[source] = {left = getElementData(value, "veh:IndicatorState").left, right = getElementData(value, "veh:IndicatorState").right};
		end
	end
end);

addEventHandler("onClientElementStreamedOut", root, function()
	if cache[source] then
		cache[source] = nil;
	end
end);

addEventHandler("onClientElementDestroy", root, function()
	if cache[source] then
		cache[source] = nil;
	end
end);

setTimer(function()
	for vehicle, array in pairs(cache) do
		if isElement(vehicle) and isElementStreamedIn(vehicle) then
			if not lights[vehicle] then
				lights[vehicle] = {};
			end

			if array.left then
				setVehicleComponentVisible(vehicle, "indicator_lf", not getVehicleComponentVisible(vehicle, "indicator_lf"));
				setVehicleComponentVisible(vehicle, "indicator_rl", not getVehicleComponentVisible(vehicle, "indicator_rl"));

				if getVehicleComponentVisible(vehicle, "indicator_lf") then
					local x, y, z = getVehicleComponentPosition(vehicle, "indicator_lf", "root");
					lights[vehicle][1] = Light(0, 0, 0, 0, 0.6, 245, 81, 0, _, _, _, true);
					attachElements(lights[vehicle][1], vehicle, x, y, z + 0.5);

					x, y, z = getVehicleComponentPosition(vehicle, "indicator_rl", "root");
					lights[vehicle][2] = Light(0, 0, 0, 0, 0.6, 245, 81, 0, _, _, _, true);
					attachElements(lights[vehicle][2], vehicle, x, y, z + 0.5);
				else
					if isElement(lights[vehicle][1]) then
						destroyElement(lights[vehicle][1]);
					end

					if isElement(lights[vehicle][2]) then
						destroyElement(lights[vehicle][2]);
					end
				end
			else
				if isElement(lights[vehicle][1]) then
					destroyElement(lights[vehicle][1]);
				end

				if isElement(lights[vehicle][2]) then
					destroyElement(lights[vehicle][2]);
				end
			end

			if array.right then
				setVehicleComponentVisible(vehicle, "indicator_rf", not getVehicleComponentVisible(vehicle, "indicator_rf"));
				setVehicleComponentVisible(vehicle, "indicator_rr", not getVehicleComponentVisible(vehicle, "indicator_rr"));
			
				if getVehicleComponentVisible(vehicle, "indicator_rf") then
					local x, y, z = getVehicleComponentPosition(vehicle, "indicator_rf", "root");
					lights[vehicle][3] = Light(0, 0, 0, 0, 0.6, 245, 81, 0, _, _, _, true);
					attachElements(lights[vehicle][3], vehicle, x, y, z + 0.5);

					x, y, z = getVehicleComponentPosition(vehicle, "indicator_rr", "root");
					lights[vehicle][4] = Light(0, 0, 0, 0, 0.6, 245, 81, 0, _, _, _, true);
					attachElements(lights[vehicle][4], vehicle, x, y, z + 0.5);
				else
					if isElement(lights[vehicle][3]) then
						destroyElement(lights[vehicle][3]);
					end

					if isElement(lights[vehicle][4]) then
						destroyElement(lights[vehicle][4]);
					end
				end
			else
				if isElement(lights[vehicle][3]) then
					destroyElement(lights[vehicle][3]);
				end

				if isElement(lights[vehicle][4]) then
					destroyElement(lights[vehicle][4]);
				end
			end
		else
			cache[vehicle] = nil;
		end
	end
end, 300, 0);

local timer = nil;
addEventHandler("onClientKey", root, function(button, pressed)
	if pressed and (button == "mouse1" or button == "mouse2") and not isCursorShowing() and not isConsoleActive() and not isChatBoxInputActive() then
		if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then
			if isTimer(timer) then return false; end
			timer = setTimer(function() end, 300, 1);

			cancelEvent();

			local state = getElementData(localPlayer.vehicle, "veh:IndicatorState") or {left = false, right = false};

			if button == "mouse1" then
				if state.right then
					if not state.left then
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = false, right = false}); --egy időben való villogás miatt
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = true, right = true});
					else
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = false, right = true});
					end
				else
					setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = not state.left, right = false});
				end
			elseif button == "mouse2" then
				if state.left then
					if not state.right then
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = false, right = false}); --egy időben való villogás miatt
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = true, right = true});
					else
						setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = true, right = false});
					end
				else
					setElementData(localPlayer.vehicle, "veh:IndicatorState", {left = false, right = not state.right});
				end
			end
		end
	end
end);