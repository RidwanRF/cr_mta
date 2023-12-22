msgs = {
	["info"] = exports['cr_core']:getServerSyntax("Wastetrans", "info"),
	["error"] = exports['cr_core']:getServerSyntax("Wastetrans", "error"),
	["success"] = exports['cr_core']:getServerSyntax("Wastetrans", "success"),
	["warning"] = exports['cr_core']:getServerSyntax("Wastetrans", "warning"),
}

basicSalary = 350;

markers = {
	["start"] = { -1977.2550048828, 883.75762939453, 45.203125},
};

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