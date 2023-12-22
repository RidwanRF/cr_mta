addEvent("switchCarPaintReflect", true);
addEventHandler("switchCarPaintReflect", root, function(state)	
	if state then
		startCarPaintReflect();
	else
		stopCarPaintReflect();
	end
end);