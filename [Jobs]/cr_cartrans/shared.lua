msgs = {
	["info"] = exports['cr_core']:getServerSyntax("Cartransporter", "info"),
	["error"] = exports['cr_core']:getServerSyntax("Cartransporter", "error"),
	["success"] = exports['cr_core']:getServerSyntax("Cartransporter", "success"),
	["warning"] = exports['cr_core']:getServerSyntax("Cartransporter", "warning"),
}

salary = 450

finishSalary = 100

vasPositions = {
	[1] = {-1845.5064697266, -1642.4097900391, 21.5, 0, 0, 30},
	[2] = {-1847.2543945313, -1643.6243896484, 21.8, 0, 0, 30},
	[3] = {-1847.2606201172, -1639.7784423828, 21.7, 0, 0, 30},
	[4] = {-1849.0667724609, -1640.9661865234, 21.8, 0, 0, 30},
}

checkPositions = {
	[1] = {0, 0},
	[2] = {0.35, -1},
	[3] = {0.9, -3},
	[3] = {1.75, -5},
}

slotPositions = {
	-- [1] = {0, 1, 0.5},
	-- [2] = {0, -0.55, 0.5},
	-- [3] = {0, -3, 0.5},
	-- [4] = {0, -4.5, 0.5},
	[1] = {0.6, 0, 0.5},
	[2] = {-0.6, 0, 0.5},
	[3] = {-0.6, -2, 0.5},
	[4] = {0.6, -2, 0.5},
}

function getElementJobData(element, data)
	if(isElement(element)) then
		local d = element:getData("job >> data")
		if(d) then
			if(d[data]) then
				return d[data]
			end
		end
		return false
	end
end

function setElementJobData(element, data, value)
	if(isElement(element)) then
		local d = element:getData("job >> data")
		if(d) then
			d[data] = value
			element:setData("job >> data", d)
		end
	end
end

function removeElementJobData(element, data)
	if(isElement(element)) then
		local d = element:getData("job >> data")
		if(d) then
			d[data] = nil
			element:setData("job >> data", d)
		end
	end
end

function destroyElementJobData(element)
	if(isElement(element)) then
		element:setData("job >> data", false)
	end
end

