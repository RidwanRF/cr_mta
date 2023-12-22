addEventHandler("onResourceStart", resourceRoot, function() 
	local refineryColShape = createColSphere(337.29629516602, -63.977931976318, 1.541362285614, 200)
	refineryColShape:setData("job >> data", {["job"] = 1, ["refinery"] = true,})
	
	local refineryMarkers = {
		[1] = {314.34030151367, -9.6059064865112, 5.2750940322876},
		[2] = {325.18090820313, -9.9067401885986, 5.2750940322876},
		[3] = {335.67538452148, -9.4879817962646, 5.1750946044922},
		[4] = {346.98425292969, -58.152576446533, 5.1750946044922},
		[5] = {356.81365966797, -57.506172180176, 5.0750942230225},
		[6] = {366.6962890625, -57.525375366211, 5.0750942230225},
		[7] = {375.91479492188, -57.951988220215, 5.0750942230225},
		[8] = {357.38446044922, -129.70742797852, 4.9750947952271},
		[9] = {344.55413818359, -129.71141052246, 5.0750942230225},
	} 
	local index = 0
	Async:foreach(refineryMarkers, function(val)
		index = index+1
		local x, y, z = unpack(val)
		local marker = createMarker(x, y, z-1, "cylinder", 0.8, 255, 100, 0, 150)
		marker:setData("job >> data", {["job"] = 1, ["refineryMarker"] = true, ["slot"] = index})
	end)
	
	local depositMarker = createMarker(-1741.3436279297, -116.33634185791, 2.5, "cylinder", 2, 100, 100, 100, 150)
	depositMarker:setData("job >> data", {["job"] = 1, ["depositMarker"] = true,})
	
	local depositColShape = createColSphere(-1721.6226806641, -135.95895385742, 0, 100)
	depositColShape:setData("job >> data", {["job"] = 1, ["deposit"] = true,})
end)

addEvent("carry->anim", true)
addEventHandler("carry->anim", root, function(e)
	local player = e
	player:setAnimation("CARRY", "crry_prtial", 1, true, true, false) 
end)

function destroyRockInHand(player)
	if(isElement(getElementJobData(player, "rockInHand"))) then
		getElementJobData(player, "rockInHand"):destroy()
		setElementJobData(player, "rockInHand", false)
	end
end

function destroyBagInHand(player)
	if(isElement(getElementJobData(player, "bagInHand"))) then
		getElementJobData(player, "bagInHand"):destroy()
		setElementJobData(player, "bagInHand", false)
	end
end

addEvent("destroyRockInHand", true)
addEventHandler("destroyRockInHand", getRootElement(), function(player) 
	destroyRockInHand(player)
end)

addEvent("destroyBagInHand", true)
addEventHandler("destroyBagInHand", getRootElement(), function(player) 
	destroyBagInHand(player)
end)

addEventHandler("onPlayerVehicleEnter", getRootElement(), function(veh, seat, jacked)
	if(getElementJobData(source, "started")) then
		destroyRockInHand(source)
		destroyBagInHand(source)
	end
end)