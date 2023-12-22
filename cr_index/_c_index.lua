local streamed_vehicles_left = {}
local streamed_vehicles_right = {}

addEventHandler("onClientPreRender", root, function()
	
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
							local state = getElementData(v,"vehicle.index.left")
							setElementData(v,"vehicle.index.left",not state)
							if(state) setElementData( v, "vehicle.index.timer", getTickCount())
							else setElementData( v, "vehicle.index.timer", nil)
						else
							local state = getElementData(v,"vehicle.index.right")
							setElementData(v,"vehicle.index.right",not state)
							if(state) setElementData( v, "vehicle.index.timer", getTickCount())
							else setElementData( v, "vehicle.index.timer", nil)
						end
						
					end
				end
			end
		end
	end
end)

addEventHandler( "onCLientElementDataChange", root, function(data,old)
	if data == "vehicle.index.left" and  isElementStreamedIn(source) then
		streamed_vehicles_left[source] = source
	elseif data == "vehicle.index.right" and  isElementStreamedIn(source) 
		streamed_vehicles_right[source] = source
	end
end)



addEventHandler("onClientElementStreamIn", root, function()
	if(getElementType(source)=="vehicle") then
		if(getElementData(source,"vehicle.index.left")) then streamed_vehicles_left[source] = source end
		if(getElementData(source,"vehicle.index.right")) then streamed_vehicles_right[source] = source end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if(getElementType(source)=="vehicle" then 
		streamed_vehicles_left[source] = nil
		streamed_vehicles_right[source] = nil
	end
end)