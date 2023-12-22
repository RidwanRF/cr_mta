addEvent("switchBlackWhite", true);
addEventHandler("switchBlackWhite", root, function(state)
	if state then
		enableBlackWhite();
	else
		disableBlackWhite();
	end
end);