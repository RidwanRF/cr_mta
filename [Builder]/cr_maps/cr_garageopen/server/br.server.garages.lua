addEventHandler("onResourceStart", getResourceRootElement(),
function (resource)
	for i=0,49 do
		--outputChatBox("opening garage " .. i)
		if (not isGarageOpen(i)) then
			setGarageOpen(i, true)
		end
	end
end
)