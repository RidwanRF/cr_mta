addEvent("switchContrast", true);
addEventHandler("switchContrast", root, function(state)
	if state then
		enableContrast();
	else
		disableContrast();
	end
end);