local followingCamera = {};
local initializeTimer = nil;
local rotation = 0;
local startTime, endTime = 0, 0;
local sx, sy = guiGetScreenSize();
local jammers = {};
local jammerDist = 9999
local look = 0
local inJammerRange = false

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end

local rotateTimer = nil
local effect = 1
local rotateLeft, rotateRight, recTimer, rec, signal, lookUp, lookDown = false, false, nil, false, 4, false, false
function updateCam()
	if(followingCamera) then
		if(not isTimer(initializeTimer)) then
			local pos = followingCamera[3]:getPosition()
			local rot = followingCamera[3]:getRotation()
			local px, py, pz = getPositionInfrontOfElement(followingCamera[3], 0.25)
			local px2, py2, pz2 = getPositionInfrontOfElement(followingCamera[3], -0.125)
			setCameraMatrix(px2, py2, pz2+0.15, px, py, pz+0.15+look)
			if(rotateLeft) then
				local rot = followingCamera[3]:getRotation()
				if(rotation < 45) then
					rotation = rotation+1
					followingCamera[3]:detach()
					followingCamera[3]:attach(followingCamera[1], 0, 0, 0, 0, 0, rotation)
				end
			elseif(rotateRight) then
				local rot = followingCamera[3]:getRotation()
				if(rotation > -45) then
					rotation = rotation-1
					followingCamera[3]:detach()
					followingCamera[3]:attach(followingCamera[1], 0, 0, 0, 0, 0, rotation)
				end
			end
			
			if(rec) then
				dxDrawImage(100, 100, 50, 40, "drone/files/rec.png")
			end
			dxDrawRectangle(85, 85, 2, 75, tocolor(255, 255, 255, 255))
			dxDrawRectangle(85, 85, 75, 2, tocolor(255, 255, 255, 255))
			
			dxDrawRectangle(sx-160, 85, 75, 2, tocolor(255, 255, 255, 255))
			dxDrawRectangle(sx-85, 85, 2, 75, tocolor(255, 255, 255, 255))
			
			dxDrawRectangle(85, sy-160, 2, 75, tocolor(255, 255, 255, 255))
			dxDrawRectangle(85, sy-85, 75, 2, tocolor(255, 255, 255, 255))
			
			dxDrawRectangle(sx-160, sy-85, 75, 2, tocolor(255, 255, 255, 255))
			dxDrawRectangle(sx-87, sy-160, 2, 75, tocolor(255, 255, 255, 255))
			
			dxDrawText("Camera: "..(effect == 1 and "Normal" or effect == 2 and "Night vision" or effect == 3 and "Thermal vision"), sx-(effect == 1 and 200 or effect == 2 and 210 or effect == 3 and 220), 95, sx-85, 100, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "center", false, false, true, true)
			dxDrawText("A speciális kamera effektusokért használd a 'NUM_5' gombot!", sx/2-250, sy-90, sx/2+250, sy-85, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center", false, false, true, true)
			dxDrawText("Kamera balra forgatása: 'NUM_4'", 300, sy-90, 400, sy-85, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center", false, false, true, true)
			dxDrawText("Kamera jobbra forgatása: 'NUM_6'", sx-400, sy-90, sx-300, sy-85, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center", false, false, true, true)
			dxDrawText(rotation.."°", sx/2, sy-200, sx/2, sy-200, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center", false, false, true, true)
			for i=1, signal do
				local color = tocolor(255, 255, 255, 255)
				if(signal <= 2) then
					if(i == 1) then
						color = tocolor(255, 100, 100, 255)
					end
					if(i == 2) then
						color = tocolor(255, 100, 100, 255)
					end
				end
				dxDrawRectangle(sx/2-2.5+((i-1)*6), 100, 5, 5+i*2, color)
			end
			if(jammerDist <= 35) then
				dxDrawRectangle(0, 0, sx, sy, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(100-jammerDist*2, 255)))
			end
			if(lookUp and not lookDown) then
				if(look < 0.25) then
					look = look+0.01
				end
			elseif(lookDown and not lookUp) then
				if(look > 0) then
					look = look-0.01
				end
			end
		end
		
		if(isTimer(initializeTimer)) then
			local now = getTickCount()
			local elapsedTime = now - startTime
			local duration = endTime - startTime
			local progress = elapsedTime / duration
			local status = interpolateBetween(0, 0, 0, 500, 0, 0, progress, "Linear")
			local text = "Initializing system..."
			if(progress > 0.5 and progress < 0.75) then
				text = "Initializing camera..."
			elseif(progress > 0.75) then
				text = "Initializing controls..."
			end
			dxDrawText(text, sx/2-250, sy-175, sx/2+250, sy-160, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center", false, false, true, true)
			dxDrawRectangle(sx/2-250, sy-200, status, 15, tocolor(255, 255, 255, 255))
		end
	end
end

addEventHandler("onClientKey", root, function(key, press)
	if(followingCamera) then
		if(key == "num_4") then
			rotateLeft = press
		elseif(key == "num_6") then
			rotateRight = press
		elseif(key == "num_5" and press) then
			local temp = {"normal", "nightvision", "thermalvision"}
			if(effect < 3) then
				effect = effect+1
			else
				effect = 1
			end
			setCameraGoggleEffect(temp[effect], true)
		elseif(key == "num_8") then
			lookUp = press
		elseif(key == "num_2") then
			lookDown = press
		end
	end
end)

function cancelPedDamage(attacker)
	if(source:getData("drone >> controller")) then
		cancelEvent()
	end
end
addEventHandler("onClientPedDamage", getRootElement(), cancelPedDamage)

addEvent("accelerateDrone", true)
addEventHandler("accelerateDrone", resourceRoot, function(ped, state)
	if(not isTimer(initializeTimer)) then
		setPedControlState(ped, "accelerate", state)
	end
end)

addEvent("reverseDrone", true)
addEventHandler("reverseDrone", resourceRoot, function(ped, state)
	if(not isTimer(initializeTimer)) then
		setPedControlState(ped, "brake_reverse", state)
	end
end)

addEvent("leftDrone", true)
addEventHandler("leftDrone", resourceRoot, function(ped, state)
	if(not isTimer(initializeTimer)) then
		setPedControlState(ped, "vehicle_left", state)
	end
end)

addEvent("rightDrone", true)
addEventHandler("rightDrone", resourceRoot, function(ped, state)
	if(not isTimer(initializeTimer)) then
		setPedControlState(ped, "vehicle_right", state)
	end
end)

function getClosestJammerDistance()
	local pos = followingCamera[1]:getPosition()
	local closest = 9999
	for i, v in pairs(jammers) do
		local pos2 = v[1]:getPosition()
		local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
		if(dist < closest) then
			closest = dist
		end
	end
	return closest
end

local updateTimer = nil
addEvent("intializeCamera", true)
addEventHandler("intializeCamera", resourceRoot, function(veh, ped) 
	local cameraObject = createObject(1337, 0, 0, 0, 0, 0, 0)
	cameraObject:attach(veh)
	cameraObject:setCollisionsEnabled(false)
	cameraObject:setAlpha(0)
	cameraObject:setScale(0.01)
	cameraObject:setRotation(0, 0, 0)
	followingCamera = {veh, ped, cameraObject}
	addEventHandler("onClientRender", root, updateCam, true, "low-5")
	setElementData(localPlayer, "hudVisible", false);
	setElementData(localPlayer, "script >> visible", false);
	showChat(false)
	setTimer(function() 
		startTime, endTime = getTickCount(), getTickCount()+3000
	end, 250, 1)
	initializeTimer = setTimer(function()
		fadeCamera(true, 1)
	end, 3000, 1)
	fadeCamera(false, 0.25, 0, 0, 0)
	updateTimer = setTimer(function() 
		triggerServerEvent("updateDronePositionToNotSyncedPlayers", resourceRoot, followingCamera[1]:getData("drone >> id"), followingCamera[1]:getPosition(), followingCamera[1]:getRotation())
	end, 2000, 1)
	jX, jY, jz = 9999, 9999, 9999
	recTimer = setTimer(function(d) 
		rec = not rec
		local pos = localPlayer:getPosition()
		local dronePos = d:getPosition()
		if(inJammerRange or isElement(inJammerRange)) then
			local jammerPos = inJammerRange:getPosition()
			if(jammerPos and dronePos) then
				jammerDist = getDistanceBetweenPoints3D(dronePos.x, dronePos.y, dronePos.z, jammerPos.x, jammerPos.y, jammerPos.z) 
			else
				jammerDist = 9999
			end
		else
			jammerDist = 9999
		end
		if(jammerDist < 15) then
			fadeCamera(false, 0.5)
			setTimer(function() 
				fadeCamera(true, 1.5)
				if(not isTimer(initializeTimer)) then
					local pos = followingCamera[1]:getPosition()
					local blip = createBlip(pos.x, pos.y, pos.z)
					blip:attach(followingCamera[1])
					exports.cr_radar:createStayBlip("Drone", blip, 1, "piros", 10, 10, 255, 255, 255, true)
					setPedControlState(followingCamera[2], "accelerate", false)
					setPedControlState(followingCamera[2], "brake_reverse", false)
					setPedControlState(followingCamera[2], "vehicle_left", false)
					setPedControlState(followingCamera[2], "vehicle_right", false)
					followingCamera[3]:destroy()
					followingCamera = {}
					removeEventHandler("onClientRender", root, updateCam, true, "low-5")
					setElementData(localPlayer, "hudVisible", true);
					setElementData(localPlayer, "script >> visible", true);
					showChat(true)
					setCameraTarget(localPlayer)
					toggleAllControls(true, true, true)
					startTime, endTime = 0, 0
					if(isTimer(recTimer)) then
						killTimer(recTimer)
					end
					setCameraGoggleEffect("normal", true)
					triggerServerEvent("exitDrone", resourceRoot, localPlayer)
				end
			end, 500, 1)
		end
		local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, dronePos.x, dronePos.y, dronePos.z)
		if(dist < 25) then
			signal = 4
		elseif(dist > 25 and dist < 50) then
			signal = 3
		elseif(dist > 50 and dist < 75) then
			signal = 2
		elseif(dist > 75 and dist < 100) then
			signal = 1
		elseif(dist > 100) then
			fadeCamera(false, 0.5)
			setTimer(function() 
				fadeCamera(true, 1.5)
				if(not isTimer(initializeTimer)) then
					setPedControlState(followingCamera[2], "accelerate", false)
					setPedControlState(followingCamera[2], "brake_reverse", false)
					setPedControlState(followingCamera[2], "vehicle_left", false)
					setPedControlState(followingCamera[2], "vehicle_right", false)
					followingCamera[3]:destroy()
					followingCamera = {}
					removeEventHandler("onClientRender", root, updateCam, true, "low-5")
					setElementData(localPlayer, "hudVisible", true);
					setElementData(localPlayer, "script >> visible", true);
					showChat(true)
					setCameraTarget(localPlayer)
					toggleAllControls(true, true, true)
					startTime, endTime = 0, 0
					if(isTimer(recTimer)) then
						killTimer(recTimer)
					end
					setCameraGoggleEffect("normal", true)
					triggerServerEvent("exitDrone", resourceRoot, localPlayer)
				end
			end, 500, 1)
		end
	end, 750, 0, veh)
end)

addEvent("exitDrone", true)
addEventHandler("exitDrone", resourceRoot, function() 
	if(not isTimer(initializeTimer)) then
		setCameraGoggleEffect("normal", true)
		fadeCamera(false, 0.5)
		setTimer(function() 
			fadeCamera(true, 1.5)
			local pos = followingCamera[1]:getPosition()
			local blip = createBlip(pos.x, pos.y, pos.z)
			blip:attach(followingCamera[1])
			exports.cr_radar:createStayBlip("Drone", blip, 1, "piros", 10, 10, 255, 255, 255, true)
			setPedControlState(followingCamera[2], "accelerate", false)
			setPedControlState(followingCamera[2], "brake_reverse", false)
			setPedControlState(followingCamera[2], "vehicle_left", false)
			setPedControlState(followingCamera[2], "vehicle_right", false)
			followingCamera[3]:destroy()
			followingCamera = {}
			removeEventHandler("onClientRender", root, updateCam, true, "low-5")
			setElementData(localPlayer, "hudVisible", true);
			setElementData(localPlayer, "script >> visible", true);
			showChat(true)
			setCameraTarget(localPlayer)
			toggleAllControls(true, true, true)
			startTime, endTime = 0, 0
			if(isTimer(recTimer)) then
				killTimer(recTimer)
			end
		end, 500, 1)
	end
end)

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, e)
	if(#followingCamera == 0) then
		if(button == "left" and state == "down") then
			if(e and e:getData("drone >> isDrone") and not (e:getHealth() <= 290)) then
				if(e:getData("drone >> owner") == false) then
					triggerServerEvent("initializeDroneControls", resourceRoot, e)
				else
					outputChatBox("Ez a drón éppen használatban van.", 255, 0, 0, true)
				end
			end
		end
	end
end)

function createDrone()
	triggerServerEvent("createDrone", resourceRoot, localPlayer)
end

addEventHandler("onClientPlayerDamage", root, function() 
	if(source == localPlayer) then
		if(#followingCamera > 0) then
			fadeCamera(false, 0.5)
			setTimer(function() 
				fadeCamera(true, 1.5)
				if(not isTimer(initializeTimer)) then
					local pos = followingCamera[1]:getPosition()
					local blip = createBlip(pos.x, pos.y, pos.z)
					blip:attach(followingCamera[1])
					exports.cr_radar:createStayBlip("Drone", blip, 1, "piros", 10, 10, 255, 255, 255, true)
					setPedControlState(followingCamera[2], "accelerate", false)
					setPedControlState(followingCamera[2], "brake_reverse", false)
					setPedControlState(followingCamera[2], "vehicle_left", false)
					setPedControlState(followingCamera[2], "vehicle_right", false)
					followingCamera[3]:destroy()
					followingCamera = {}
					removeEventHandler("onClientRender", root, updateCam, true, "low-5")
					setElementData(localPlayer, "hudVisible", true);
					setElementData(localPlayer, "script >> visible", true);
					showChat(true)
					setCameraTarget(localPlayer)
					toggleAllControls(true, true, true)
					startTime, endTime = 0, 0
					if(isTimer(recTimer)) then
						killTimer(recTimer)
					end
					setCameraGoggleEffect("normal", true)
					triggerServerEvent("exitDrone", resourceRoot, localPlayer)
				end
			end, 500, 1)
		end
	end
end)

addEvent("sendJammersToClient", true)
addEventHandler("sendJammersToClient", resourceRoot, function(table) 
	jammers = table
end)

function handleDamage(attacker, weapon, loss, x, y, z, tire)
	if(weapon) then
		if(source:getData("drone >> isDrone")) then
			source:setHealth(300)
			if(#followingCamera > 0) then
				fadeCamera(false, 0.5)
				setTimer(function() 
					fadeCamera(true, 1.5)
					if(not isTimer(initializeTimer)) then
						local pos = followingCamera[1]:getPosition()
						local blip = createBlip(pos.x, pos.y, pos.z)
						exports.cr_radar:createStayBlip("Drone", blip, 1, "piros", 10, 10, 255, 255, 255, true)
						setPedControlState(followingCamera[2], "accelerate", false)
						setPedControlState(followingCamera[2], "brake_reverse", false)
						setPedControlState(followingCamera[2], "vehicle_left", false)
						setPedControlState(followingCamera[2], "vehicle_right", false)
						followingCamera[3]:destroy()
						followingCamera = {}
						removeEventHandler("onClientRender", root, updateCam, true, "low-5")
						setElementData(localPlayer, "hudVisible", true);
						setElementData(localPlayer, "script >> visible", true);
						showChat(true)
						setCameraTarget(localPlayer)
						toggleAllControls(true, true, true)
						startTime, endTime = 0, 0
						if(isTimer(recTimer)) then
							killTimer(recTimer)
						end
						setCameraGoggleEffect("normal", true)
						triggerServerEvent("exitDrone", resourceRoot, localPlayer)
					end
				end, 500, 1)
			end
		end
	end
end
addEventHandler("onClientVehicleDamage", root, handleDamage)

addEventHandler("onClientColShapeHit", root, function(e, md) 
	if(e == followingCamera[1] and md) then
		for i, v in pairs(jammers) do
			if(v[3] == source) then
				inJammerRange = source:getData("signal >> jammer")
				break
			end
		end
	end
end)

addEventHandler("onClientColShapeLeave", root, function(e, md) 
	if(e == followingCamera[1] and md) then
		inJammerRange = false
		jammerPos = 9999
	end
end)