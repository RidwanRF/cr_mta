addEvent("switchDoF", true);
addEventHandler("switchDoF", root, function(state)
	if state then
		enableDoF();
	else
		disableDoF();
	end
end);