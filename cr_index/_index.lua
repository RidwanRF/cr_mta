local indexSound
local vehTimers = {}
--[[local customIndex = {
	[546] = true,
	[543] = true,
	[494] = true
}
]]
local reverseCompNames = {
	[546] = true
}

local cache = {}

function customIndex(veh)
	local result = false
	local modelid = getElementModel(veh)
	if cache[modelid] then
		result = cache[modelid]
	else
		for k in pairs ( getVehicleComponents ( veh ) ) do
			if k == "indicator_lf" then
				result = true
				cache[modelid] = true
				break
			end
		end
		if not result then
			cache[modelid] = "none"
		end
	end
	if result == "none" then
		result = false
	end
	return result
end

function getBoolean(vehicle, bool, lights)
	local modelid = getElementModel(vehicle)
	if reverseCompNames[modelid] and lights then
		return not bool
	else
		return bool
	end
end

local specialTimers = {}
local tick = 0
addEventHandler("onClientPreRender", root, function()
	if(tick%25==0)then
		for i, v in pairs(specialTimers) do
			v()
		end
	end
	tick = tick + 1
	if(tick>=1000)then
		tick = 0
	end
end)

function setSpecialTimer(func)
	local h = hash("md5", tostring(func))
	specialTimers[h] = func
	return h
end

function isSpecialTimer(id)
	return specialTimers[id] or false
end

function killSpecialTimer(id)
	if isElement(indexSound) then destroyElement(indexSound) end
	specialTimers[id] = nil
end

function setVehicleIndicator(vehicle, state)
	if(isSpecialTimer(vehTimers[vehicle]))then killSpecialTimer(vehTimers[vehicle]) end
	if not isElement(vehicle) then return end
	local model = getElementModel(vehicle)
	local left = state.left
	local right = state.right
	local all = state.lights
	local modelid = model

	local custom = customIndex(vehicle)

	if not custom then
		if(not all)then
			setVehicleOverrideLights(vehicle, 2)
			setVehicleLightState ( vehicle, 0, left == true and 0 or 1)
			setVehicleLightState ( vehicle, 1, right == true and 0 or 1)
			setVehicleLightState ( vehicle, 2, right == true and 0 or 1)
			setVehicleLightState ( vehicle, 3, left == true and 0 or 1)
		else
			setVehicleLightState ( vehicle, 0, left == true and 1 or 0)
			setVehicleLightState ( vehicle, 1, right == true and 1 or 0)
			setVehicleLightState ( vehicle, 2, right == true and 1 or 0)
			setVehicleLightState ( vehicle, 3, left == true and 1 or 0)
		end
	end
	
	if(left or right)then
		vehTimers[vehicle] = setSpecialTimer(function()
			if not isElement(vehicle) then killSpecialTimer(vehTimers[vehicle]) return end
			if not isElementStreamedIn(vehicle) then killSpecialTimer(vehTimers[vehicle]) return end
			if not custom then
				if(state.left)then
					setVehicleLightState ( vehicle, 0, left == true and 0 or 1)
					setVehicleLightState ( vehicle, 3, left == true and 0 or 1)
					left = not left
				else
					setVehicleLightState ( vehicle, 0, all == true and 0 or 1)
					setVehicleLightState ( vehicle, 3, all == true and 0 or 1)
				end
				if(state.right)then
					setVehicleLightState ( vehicle, 1, right == true and 0 or 1)
					setVehicleLightState ( vehicle, 2, right == true and 0 or 1)
					right = not right
				else
					setVehicleLightState ( vehicle, 1, all == true and 0 or 1)
					setVehicleLightState ( vehicle, 2, all == true and 0 or 1)
				end
			else
				if(state.left)then
					setVehicleComponentVisible(vehicle, "indicator_lf", getBoolean(vehicle, left, all))
					setVehicleComponentVisible(vehicle, "indicator_rl", getBoolean(vehicle, left, all))
					left = not left
				else
					setVehicleComponentVisible(vehicle, "indicator_lf", getBoolean(vehicle, false, all))
					setVehicleComponentVisible(vehicle, "indicator_rl", getBoolean(vehicle, false, all))
				end
				if(state.right)then
					setVehicleComponentVisible(vehicle, "indicator_rf", getBoolean(vehicle, right, all))
					setVehicleComponentVisible(vehicle, "indicator_rr", getBoolean(vehicle, right, all))
					right = not right
				else
					setVehicleComponentVisible(vehicle, "indicator_rf", getBoolean(vehicle, false, all))
					setVehicleComponentVisible(vehicle, "indicator_rr", getBoolean(vehicle, false, all))
				end
			end
			if right == true or left == true or all == true then
				if getPedOccupiedVehicle ( localPlayer ) == vehicle then
					--indexSound = playSound("index.mp3")
				end
			else
				if isElement(indexSound) then destroyElement(indexSound) end
			end
		end)
	end
	if custom then
		if not state.left then
			setVehicleComponentVisible(vehicle, "indicator_lf", getBoolean(vehicle, false, all))
			setVehicleComponentVisible(vehicle, "indicator_rl", getBoolean(vehicle, false, all))
		end
		if not state.right then		
			setVehicleComponentVisible(vehicle, "indicator_rf", getBoolean(vehicle, false, all))
			setVehicleComponentVisible(vehicle, "indicator_rr", getBoolean(vehicle, false, all))
		end
	end
end

function getVehicleIndicatorState(vehicle)
	local state = getElementData(vehicle, "veh:IndicatorState") or {left = false, right = false, lights = tonumber(getElementData(vehicle, "veh:Lights") or 0)==1}
	return state
end

function setVehicleIndicatorState(vehicle, order, state)
	local nowState = getVehicleIndicatorState(vehicle)
	nowState[order] = state
	setElementData(vehicle, "veh:IndicatorState", nowState)
end

addEventHandler("onClientResourceStart", root, function()
	for i, v in ipairs(getElementsByType("vehicle", root, true)) do
		local state = getVehicleIndicatorState(v, data)
		setVehicleIndicator(v, state)
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if(getElementType(source)=="vehicle")then
		local state = getVehicleIndicatorState(source, data)
		setVehicleIndicator(source, state)
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if(getElementType(source)=="vehicle" and isSpecialTimer(vehTimers[source]))then
		killSpecialTimer(vehTimers[source])
	end
end)

addEventHandler("onClientElementDataChange", root, function(data)
	if(getElementType(source)=="vehicle" and isElementStreamedIn(source))then
		if(data=="veh:IndicatorState")then
			local state = getVehicleIndicatorState(source)
			setVehicleIndicator(source, state)
		elseif(data=="veh:Lights")then
			setVehicleIndicatorState(source, "lights", tonumber(getElementData(source, data) or 0)==1)
		end
	end
end)

local floodTimer = nil
addEventHandler("onClientKey", root, function(key, press)
	if(press and (key=="mouse1" or key=="mouse2"))then
		local v = getPedOccupiedVehicle(localPlayer)
		if v then
			if not isCursorShowing() then
				if getVehicleType(v) == "Automobile" or getVehicleType(v) == "Bike" or getVehicleType(v) == "Quad" then
					if getVehicleOccupant(v, 0) == localPlayer then
						cancelEvent() -- nitro miatt
						if isTimer(floodTimer) then return end
						floodTimer = setTimer(function() end, 300, 1)
						if key == "mouse1" then
							setVehicleIndicatorState(v, "left", not getVehicleIndicatorState(v).left)
						else
							setVehicleIndicatorState(v, "right", not getVehicleIndicatorState(v).right)
						end
					end
				end
			end
		end
	end
end)

