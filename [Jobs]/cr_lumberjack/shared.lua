msgs = {
	["info"] = exports['cr_core']:getServerSyntax("Lumberjack", "info"),
	["error"] = exports['cr_core']:getServerSyntax("Lumberjack", "error"),
	["success"] = exports['cr_core']:getServerSyntax("Lumberjack", "success"),
	["warning"] = exports['cr_core']:getServerSyntax("Lumberjack", "warning"),
}

salaryPerPile = 75;

treeStateValue = {
    [1] = 3,
    [2] = 1,
}

pilePositions = {
	[1] = {-0.35, -0.8, -0.15, 0, 0, 0},
	[2] = {0.35, -0.8, -0.15, 0, 0, 0},
	[3] = {-0.35, -1.5, -0.15, 0, 0, 90},
	[4] = {0.35, -1.5, -0.15, 0, 0, 90},
	[5] = {-0.35, -2.1, -0.15, 0, 0, 0},
	[6] = {0.35, -2.1, -0.15, 0, 0, 0},
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
		removeEventHandler("onClientKey", root, loadRockKeyHandler)
		removeEventHandler("onClientKey", root, loadBagKeyHandler)
	end
end