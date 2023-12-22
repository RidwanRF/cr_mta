msgs = {
	["info"] = exports['cr_core']:getServerSyntax("Miner", "info"),
	["error"] = exports['cr_core']:getServerSyntax("Miner", "error"),
	["success"] = exports['cr_core']:getServerSyntax("Miner", "success"),
	["warning"] = exports['cr_core']:getServerSyntax("Miner", "warning"),
}

value = {
	[1] = 50,
	[2] = 100,
	[3] = 150,
	[4] = 250,
}

rockStateValues = {
	[1] = 2,
	[2] = 1.5,
	[3] = 1,
	[4] = 0.5,
}

rockRespawnTimes = {
	[1] = 450,
	[2] = 900,
	[3] = 1800,
	[4] = 3600,
}

stonePositionsOnVehicle = {
	[1] = {-0.5, -0.8, 0, 0, 0, 0},
	[2] = {-0.5, -1.5, 0, 0, 0, 0},
	[3] = {-0.5, -2.1, 0, 0, 0, 0},
	[4] = {0.5, -0.8, 0, 0, 0, 0},
	[5] = {0.5, -1.5, 0, 0, 0, 0},
	[6] = {0.5, -2.1, 0, 0, 0, 0},
}

bagPositionsOnVehicle = {
	[1] = {-0.25, -0.8, -0.15, 0, 0, 0},
	[2] = {0.25, -0.8, -0.15, 0, 0, 0},
	[3] = {-0.25, -1.5, -0.15, 0, 0, 90},
	[4] = {0.25, -1.5, -0.15, 0, 0, 90},
	[5] = {-0.25, -2.1, -0.15, 0, 0, 0},
	[6] = {0.25, -2.1, -0.15, 0, 0, 0},
}

rockTypeText = {
	[1] = "Kő",
	[2] = "Vas",
	[3] = "Arany",
	[4] = "Gyémánt",
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