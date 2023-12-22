addEvent("switchWaterRefract", true);
addEventHandler("switchWaterRefract", root, function(state)
	if state then
		startWaterRefract()
	else
		stopWaterRefract()
	end
end);