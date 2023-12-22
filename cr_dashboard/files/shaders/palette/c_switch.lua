addEvent("switchPalette", true)
addEventHandler("switchPalette", root, function(x)
	if tonumber(x) then
		enablePalette(x);
	else
		disablePalette();
	end
end)