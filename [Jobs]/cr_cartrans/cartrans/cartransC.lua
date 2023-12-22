local darutalp = createObject(1383,2807.7487792969, -2431.5500488281, 24.628788948059)
setObjectScale(darutalp, 0.4)
local daruforgo = createObject(1388, 2807.8, -2431.5, 37.529577636719)
setObjectScale(daruforgo, 0.5) 
local darumagnes = createObject(1381, 2807.8686523438, -2416.0529785156, 38.929574584961) 
setObjectScale(darumagnes, 0.4)
attachElements(darumagnes, daruforgo, 0, 19, 1.8)

local darutalp2 = createObject(1383,-1833.8673095703, -1694.7796630859, 35.75,0,0,34) 
setObjectScale(darutalp2, 0.5)
local daruforgo2 = createObject(1388,-1833.8673095703, -1694.7796630859, 52)
setElementRotation(daruforgo2, 0, 0, 30)
setObjectScale(daruforgo2, 0.5)
local darumagnes2 = createObject(1381,-1819.6516113281, -1682.8406982422, 53.8)
setObjectScale(darumagnes2, 0.4)
attachElements(darumagnes2, daruforgo2, 0, 19, 1.8)

local daru3talp = createObject(1383,2808.15625, -2485.1657714844, 24.6328125) 
setObjectScale(daru3talp, 0.4)
local daru3forgo = createObject(1388,2808.2221679688, -2485.171875, 37.529577636719)
setObjectScale(daru3forgo, 0.5)
local daru3magnes = createObject(1381,2808.2272949219, -2466.123046875, 38.929574584961)
setObjectScale(daru3magnes, 0.4)
attachElements(daru3magnes, daru3forgo, 0, 19, 1.8)

local daru4magnes = createObject(1381, 1295.6427001953, 171.86511230469, 33.4609375)
setObjectScale(daru4magnes, 0.4)

local daruRot = 0 --Daru forgása
local daru2Rot = 0
local daru3Rot = 0

local Mx,My,Mz 
local Mx2,My2,Mz2
local Mx3,My3,Mz3

local tempCar 

function d3HajoFele()
	if(daru3Rot < 90) then
		daru3Rot = daru3Rot + 1
	elseif(daru3Rot >= 90) then
		daru3Rot = 90
		
		local attachedElements = getAttachedElements(daru3forgo)  --daruhoz kapcsolt cuccok lekérése
		for i, v in ipairs(attachedElements) do
			detachElements(v, daru3forgo)
		end
		Mx3, My3, Mz3 = getElementPosition(daru3magnes)
		removeEventHandler("onClientRender", root, d3HajoFele)
		removeEventHandler("onClientRender", root, drawMLine4) --Vonal rajzolása a mágneshez
		addEventHandler("onClientRender", root, drawMLine4) --Vonal rajzolása a mágneshez
		if(moveObject(daru3magnes, 3000, Mx3, My3, Mz3-27)) then --Mágnes mozgatása lefele
			setTimer(function()
				attachElements(tempCar, daru3magnes, 0, 0, -0.1)
				if moveObject(daru3magnes, 3000, Mx3, My3, Mz3) then
					setTimer(function()
					attachElements(daru3magnes, daru3forgo, 0, 19, 1, 0, 0, 90)
					daru3Rot = 90
					removeEventHandler("onClientRender", root, drawMLine4)
					removeEventHandler("onClientRender", root, d3PartFele)
					addEventHandler("onClientRender", root, d3PartFele)
					end,3100,1)
				end
			end,3200,1)
		end
	end
	setElementRotation(daru3forgo, 0, 0, -daru3Rot)
end

function d3PartFele()
	if(daru3Rot > -90) then
		daru3Rot = daru3Rot - 1
	elseif(daru3Rot <= -90) then
		daru3Rot = -90
		local attachedElements = getAttachedElements(daru3forgo)  --daruhoz kapcsolt cuccok lekérése
		for i,v in ipairs(attachedElements) do
			detachElements(v, daru3forgo)
		end
		Mx3, My3, Mz3 = getElementPosition(daru3magnes)
		removeEventHandler("onClientRender", root, d3PartFele)
		addEventHandler("onClientRender",root,drawMLine5) --Vonal rajzolása a mágneshez
		if moveObject(daru3magnes,3000,Mx3,My3,Mz3-23) then --Mágnes mozgatása lefele
		setTimer(function()
			local attachedElements = getAttachedElements(daru3forgo)  --daruhoz kapcsolt cuccok lekérése
			for i,v in ipairs(attachedElements) do
				detachElements(v, daru3forgo)
			end
			if isElement(tempCar) then
				destroyElement(tempCar)
			end
			triggerServerEvent("addWreckageToVehicle", localPlayer, localPlayer)
			toggleControl("enter_exit", true)
			toggleControl("accelerate", true)
			toggleControl("brake_reverse", true)
			initializePutdownPlace()
			toggleAllControls(true, true, true)

			if moveObject(daru3magnes, 3000, Mx3, My3, Mz3) then
				setTimer(function()
					attachElements(daru3magnes, daru3forgo, 0, 19, 1.8, 0, 0, 90)
					daru3Rot = -90
					setElementRotation(daru3forgo, 0, 0, -daru3Rot)
					removeEventHandler("onClientRender", root, drawMLine5)
					removeEventHandler("onClientRender", root, d3Alapra)
					addEventHandler("onClientRender", root, d3Alapra)
				end, 3100, 1)
			end
			if(tutorialState == 1) then
				nextTutorial()
			end
			outputChatBox(msgs["success"].."Sikeresen felpakolták a roncsot a járművedre.",255,255,255,true)
			timeChallenge = getTickCount()
			outputChatBox(msgs["info"].."Vidd el a megjelölt helyre. #0000FF(Kék blip)",255,255,255,true)
			exports.cr_radar:setGPSDestination(-1858.8732910156, -1650.6628417969)
			toggleControl("enter_exit", true)
			toggleControl("accelerate", true)
			toggleControl("brake_reverse", true)
			-- local veh = localPlayer:getOccupiedVehicle()
			-- veh:setFrozen(false)
		end,3000,1)
	end
	end
	setElementRotation(daru3forgo,0,0,-daru3Rot)
end

function d3Alapra()
	if(daru3Rot < 0) then
		daru3Rot = daru3Rot + 1
	elseif(daru3Rot <= 0) then
		daru3Rot = 0
		removeEventHandler("onClientRender", root, d3Alapra)
	end
	setElementRotation(daru3forgo, 0, 0, -daru3Rot)
end

function addCarToDFT2()
	daru3Rot = 0
	removeEventHandler("onClientRender", root, d3HajoFele)
	addEventHandler("onClientRender", root, d3HajoFele)
	tempCar = createObject(3593,2829.0783691406, -2484.4389648438, 11.973110198975)
end


function removeCarToDFT()
	daru2Rot = 0
	removeEventHandler("onClientRender", root, d2Korigalas)
	addEventHandler("onClientRender", root, d2Korigalas)
	if isElement(finishMarker) then
		--exports.cr_interface:destroyStayBlip("Lerakodás")
		destroyElement(finishMarker)
	end
	INfinishMarker = false
end

function d2Korigalas()
	if(daru2Rot < 30) then
		daru2Rot = daru2Rot + 1
	elseif(daru2Rot <= 30) then
		daru2Rot = 30
		local attachedElements = getAttachedElements(daruforgo2)  --daruhoz kapcsolt cuccok lekérése
		for i,v in ipairs(attachedElements) do
			detachElements(v, daruforgo2)
		end
		Mx2, My2, Mz2 = getElementPosition(darumagnes2)
		removeEventHandler("onClientRender", root, drawMLine2)
		addEventHandler("onClientRender", root, drawMLine2)
		if moveObject(darumagnes2,3000, Mx2, My2, Mz2-27) then --Mágnes mozgatása lefele
			setTimer(function()
				triggerServerEvent("putdownWreckage", localPlayer, localPlayer)
				exports.cr_radar:setGPSDestination(2768.033203125, -2392.8449707031)
				if(tutorialState == 2) then
					nextTutorial()
				end
				toggleControl("enter_exit", true)
				toggleControl("accelerate", true)
				toggleControl("brake_reverse", true)
				initializeLoadMarkers()
				if(isElement(tempCar)) then
					destroyElement(tempCar)
				end
				tempCar = createObject(3593, Mx2, My2, Mz2, 0, 0, -55)
				attachElements(tempCar, darumagnes2, 0, 0, -0.1, 0, 0, -55)
				if moveObject(darumagnes2, 3000, Mx2, My2, Mz2-1) then
					setTimer(function()
					attachElements(darumagnes2, daruforgo2, 0, 19, 1)
					removeEventHandler("onClientRender", root, drawMLine2)
					daru2Rot = 330
					removeEventHandler("onClientRender", root, d2FeldolgozoFele)
					addEventHandler("onClientRender", root, d2FeldolgozoFele)
					end, 3020, 1)
				end
			end, 3200, 1)
		end
		removeEventHandler("onClientRender", root, d2Korigalas)
	end
	setElementRotation(daruforgo2, 0, 0, daru2Rot)
end

function d2FeldolgozoFele()
	if(daru2Rot < 410) then
		daru2Rot = daru2Rot + 1
	elseif(daru2Rot >= 410) then
		daru2Rot = 410
		local attachedElements = getAttachedElements(daruforgo2)  --daruhoz kapcsolt cuccok lekérése
		for i,v in ipairs(attachedElements) do
			detachElements(v, daruforgo2)
		end
		Mx2, My2, Mz2 = getElementPosition(darumagnes2)
		removeEventHandler("onClientRender", root, drawMLine3)
		addEventHandler("onClientRender", root, drawMLine3)
		if moveObject(darumagnes2, 2000, Mx2, My2, Mz2-10) then
			setTimer(function()
				if isElement(tempCar) then
					destroyElement(tempCar)
				end
				if moveObject(darumagnes2, 2000, Mx2, My2, Mz2+0.8) then
					setTimer(function()
						attachElements(darumagnes2, daruforgo2, 0, 19, 1.8)
						removeEventHandler("onClientRender", root, drawMLine3)
						daru2Rot = 301
						removeEventHandler("onClientRender", root, d2VisszaAlapra)
						addEventHandler("onClientRender", root, d2VisszaAlapra)
					end,2000,1)
				end
			end,3200,1)
		end
		removeEventHandler("onClientRender",root,d2FeldolgozoFele)
	end
	setElementRotation(daruforgo2,0,0,-daru2Rot)
end

function d2VisszaAlapra()
	if(daru2Rot > 300 and daru2Rot < 360) then
		daru2Rot = daru2Rot + 1
	elseif(daru2Rot >= 360) then
		daru2Rot = 360
		removeEventHandler("onClientRender", root, d2VisszaAlapra)
		daru2Rot = 0
		local veh = false
		for i, v in pairs(getElementsByType("vehicle")) do
			if(v:getData("veh >> owner") == localPlayer:getData("acc >> id") and v:getData("veh >> job") == 3) then
				veh = v
				break
			end
		end
		
		veh:setFrozen(false)
		toggleAllControls(true, true, true)
		toggleControl("enter_exit", true)
		toggleControl("accelerate", true)
		toggleControl("brake_reverse", true)
		setElementFrozen(localPlayer, false)
		-- triggerServerEvent("putdownWreckage", resourceRoot)
		toggleAllControls(true, true, true)
		veh:setFrozen(false)
		
		for i, v in pairs(getElementsByType("marker")) do
			if(getElementJobData(v, "putDown") and getElementJobData(v, "starter") == localPlayer:getData("acc >> id")) then
				v:destroy()
			end
		end
		
		-- if(isElement(pickupMarker)) then
			--exports.cr_interface:destroyStayBlip("Rakodás")
			-- destroyElement(pickupMarker)
		-- end
		-- pickupMarker = createMarker(2788.6672363281, -2431.3232421875, 13.13526725769,"checkpoint",1,255,0,0)
		-- setElementData(pickupMarker, "carJob:pickupMarker", true)
		--exports.cr_interface:createStayBlip("Rakodás",2788.6672363281, -2431.3232421875, 1,"loader",25,25,255,255,255)
	end
	setElementRotation(daruforgo2, 0, 0, daru2Rot)
end


function drawMLine()
	local x1, y1, z1 = getElementPosition(darumagnes)
	dxDrawLine3D(Mx, My, Mz, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function drawMLine2()
	local x1, y1, z1 = getElementPosition(darumagnes2)
	dxDrawLine3D(Mx2, My2, Mz2, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function drawMLine3()
	local x1, y1, z1 = getElementPosition(darumagnes2)
	dxDrawLine3D(Mx2, My2, Mz2+1.5, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function drawMLine4()
	local x1, y1, z1 = getElementPosition(daru3magnes)
	dxDrawLine3D(Mx3, My3, Mz3, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function drawMLine5()
	local x1,y1,z1 = getElementPosition(daru3magnes)
	dxDrawLine3D(Mx3, My3, Mz3+1.5, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function drawMLine6()
	local x1,y1,z1 = getElementPosition(daru4magnes)
	dxDrawLine3D(Mx4, My4, Mz4+1.5, x1, y1, z1, tocolor(0, 0, 0, 255), 6)
end

function addCarToDFT()
	daruRot = 0
	removeEventHandler("onClientRender", root, dHajoFele)
	addEventHandler("onClientRender", root, dHajoFele)
	tempCar = createObject(3593,2826.8962402344, -2431.5356445313, 12.087331771851)
end

function dHajoFele()
	if daruRot < 90 then
		daruRot = daruRot + 1
	elseif daruRot >= 90 then
		daruRot = 90
		
		local attachedElements = getAttachedElements(daruforgo)  --daruhoz kapcsolt cuccok lekérése
		for i,v in pairs(attachedElements) do
			detachElements(v, daruforgo)
		end
		Mx,My,Mz = getElementPosition(darumagnes)
		removeEventHandler("onClientRender", root, dHajoFele)
		addEventHandler("onClientRender", root, drawMLine) --Vonal rajzolása a mágneshez
		if moveObject(darumagnes, 3000, Mx, My, Mz-27) then --Mágnes mozgatása lefele
			setTimer(function()
				attachElements(tempCar, darumagnes, 0, 0, -0.1)
				if moveObject(darumagnes, 3000, Mx, My, Mz) then
					setTimer(function()
						attachElements(darumagnes, daruforgo, 0, 19, 1, 0, 0, 90)
						daruRot = 90
						removeEventHandler("onClientRender", root, drawMLine)
						removeEventHandler("onClientRender", root, dPartFele)
						addEventHandler("onClientRender", root, dPartFele)
					end, 3100, 1)
				end
			end, 3200, 1)
		end
	end
	setElementRotation(daruforgo, 0, 0, -daruRot)
end

function dPartFele()
	if(daruRot > -90) then
		daruRot = daruRot - 1
	elseif(daruRot <= -90) then
		daruRot = -90
		local attachedElements = getAttachedElements(daruforgo)  --daruhoz kapcsolt cuccok lekérése
		for i,v in ipairs(attachedElements) do
			detachElements(v, daruforgo)
		end
		Mx, My, Mz = getElementPosition(darumagnes)
		removeEventHandler("onClientRender", root, dPartFele)
		
		addEventHandler("onClientRender", root, drawMLine) --Vonal rajzolása a mágneshez
		if moveObject(darumagnes, 3000, Mx, My, Mz-23) then --Mágnes mozgatása lefele
			setTimer(function()
				local attachedElements = getAttachedElements(daruforgo)  --daruhoz kapcsolt cuccok lekérése
				for i,v in ipairs(attachedElements) do
					detachElements(v, daruforgo)
				end
				if isElement(tempCar) then
					destroyElement(tempCar)
				end
				triggerServerEvent("addWreckageToVehicle", localPlayer, localPlayer)
				initializePutdownPlace()
				toggleAllControls(true, true, true)
				
				if moveObject(darumagnes, 3000, Mx, My, Mz) then
					setTimer(function()
						attachElements(darumagnes, daruforgo, 0, 19, 1, 0, 0, 90)
						daruRot = -90
						setElementRotation(daruforgo, 0, 0, -daruRot)
						removeEventHandler("onClientRender", root, drawMLine)
						removeEventHandler("onClientRender", root, dAlapra)
						addEventHandler("onClientRender", root, dAlapra)
					end, 3100, 1)
				end
				if(tutorialState == 1) then
					nextTutorial()
				end
				outputChatBox(msgs["success"].."Sikeresen felpakolták a roncsot a járművedre.", 255, 255,255, true)
				outputChatBox(msgs["info"].."Vidd el a megjelölt helyre. #0000FF(Kék blip)", 255, 255, 255, true)
				exports.cr_radar:setGPSDestination(-1858.8732910156, -1650.6628417969)
				toggleControl("enter_exit", true)
				toggleControl("accelerate", true)
				toggleControl("brake_reverse", true)
			end, 3000, 1)
		end
	end
	setElementRotation(daruforgo, 0, 0, -daruRot)
end


function dAlapra()
	if(daruRot < 0) then
		daruRot = daruRot + 1
	elseif(daruRot <= 0) then
		daruRot = 0
		removeEventHandler("onClientRender", root, dAlapra)
	end
	setElementRotation(daruforgo, 0, 0, -daruRot)
end

addEventHandler("onClientResourceStart", resourceRoot, function()   
	local txd = engineLoadTXD("model/feldolgozott.txd", true) 
	engineImportTXD(txd, 7955) 

	local dff = engineLoadDFF("model/feldolgozott.dff", 0)  
	engineReplaceModel(dff, 7955) 

	local col = engineLoadCOL("model/feldolgozott.col")  
	engineReplaceCOL(col, 7955) 
	engineSetModelLODDistance(7955, 500) 
end) 

checkTimer = nil
function setUpCheckTimer()
	checkTimer = setTimer(function() 
		if(localPlayer:getData("char >> job") == 3) then
			local veh = localPlayer:getOccupiedVehicle()
			if(isElement(veh)) then
				if(veh:getModel() == 530) then
					if(not getElementJobData(veh, "vas")) then
						local x, y, z = veh:getComponentPosition("misc_a", "world")
						for i, v in pairs(getElementsByType("object")) do
							if(getElementJobData(v, "feldolgozottVas")) then
								local pos = v:getPosition()
								if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, x, y, z) <= 1) then
									waitData["start"] = getTickCount()
									waitData["end"] = getTickCount()+2000
									waitData["pos"] = {pos.x, pos.y, pos.z}
									addEventHandler("onClientRender", root, renderWait)
									waitTimer = setTimer(function(object) 
										triggerServerEvent("pickUpVas", localPlayer, localPlayer, object)
										setUpCheckTimer()
										removeEventHandler("onClientRender", root, renderWait)
										if(tutorialState == 4) then
											nextTutorial()
										end
									end, 2000, 1, v)
									killTimer(checkTimer)
									break
								end 
							end
						end
					end
				end
			end
		end
	end, 1000, 0)
end
setUpCheckTimer()

function getNearestCheckPosition(x, y, z, x2, y2, z2)
	local nearest = 1
	local record = 999.999
	local px, py, pz = unpack(checkPositions[nearest])
	for i, v in pairs(checkPositions) do
		if(getDistanceBetweenPoints3D(x, y, z, x2+v[1], y2+v[2], z2) < record) then
			px, py, pz = unpack(checkPositions[nearest])
			nearest = i
			record = getDistanceBetweenPoints3D(x, y, z, x2+v[1], y2+v[2], z2)
		end
	end
	return x2+px, y2+py, z2
end

checkTrailer = nil
function setUpCheckTrailer()
	checkTrailer = setTimer(function() 
		if(localPlayer:getData("char >> job") == 3) then
			local veh = localPlayer:getOccupiedVehicle()
			if(isElement(veh)) then
				if(veh:getModel() == 530) then
					if(getElementJobData(veh, "vas")) then
						local x, y, z = veh:getComponentPosition("misc_a", "world")
						for i, v in pairs(getElementsByType("vehicle")) do
							if(v:getData("veh >> owner") == localPlayer:getData("acc >> id") and v:getData("veh >> job") and v:getModel() == 578) then
								local x2, y2, z2 = v:getComponentPosition("chassis_dummy", "world")
								x2, y2, z2 = getNearestCheckPosition(x, y, z, x2, y2, z2)
								if(getDistanceBetweenPoints3D(x2, y2, z2, x, y, z) <= 3) then
									waitData["start"] = getTickCount()
									waitData["end"] = getTickCount()+2000
									waitData["pos"] = {x2, y2, z2}
									addEventHandler("onClientRender", root, renderWait)
									waitTimer = setTimer(function() 
										triggerServerEvent("loadVas", localPlayer, localPlayer)
										setUpCheckTrailer()
										removeEventHandler("onClientRender", root, renderWait)
										if(tutorialState == 5) then
											nextTutorial()
										end
									end, 2000, 1)
									killTimer(checkTrailer)
									break
								end 
							end 
						end
					end
				end
			end
		end
	end, 1000, 0) 
end
setUpCheckTrailer()

function startPutDown()
	Mx4, My4, Mz4 = getElementPosition(daru4magnes)
	removeEventHandler("onClientRender", root, drawMLine6)
	addEventHandler("onClientRender", root, drawMLine6)
	moveObject(daru4magnes, 3000, Mx4, My4, Mz4-10)
	local endTime = getTickCount()-timeChallenge
	setTimer(function() 
		exports.cr_tutorial:hidePanel()
		toggleControl("enter_exit", true)
		toggleControl("accelerate", true)
		toggleControl("brake_reverse", true)
		moveObject(daru4magnes, 3000, Mx4, My4, 33.4609375)
		local tempObject = createObject(7955, Mx4, My4, 14.2)
		tempObject:setCollisionsEnabled(false)
		tempObject:setScale(2)
		tempObject:attach(daru4magnes, 0, 0, -1.5)
		setTimer(function(t)
			t:destroy()
			removeEventHandler("onClientRender", root, drawMLine6)
		end, 3100, 1, tempObject)
		-- if not exports.cr_network:getNetworkStatus() then return end
		triggerServerEvent("giveCartransFinishSalary", localPlayer, localPlayer, endTime)
		exports.cr_radar:setGPSDestination(2768.033203125, -2392.8449707031)
	end, 3100, 1)
end
-- addCommandHandler("startputdown", startPutDown)

addEventHandler("onClientVehicleEnter", root, function(p) 
	if(p == localPlayer) then
		if(localPlayer:getData("char >> job") == 3) then
			if(source:getData("veh >> job") and source:getData("veh >> owner") == localPlayer:getData("acc >> id") and source.model ~= 530) then
				if(getTickCount()-startTime > 180000) then
					local wreckage = getElementJobData(source, "wreckage")
					local wBoxes = getElementJobData(source, "wreckageBoxes") or {}
					if(isElement(wreckage)) then
						exports.cr_radar:setGPSDestination(-1858.8732910156, -1650.6628417969)
					end
					if(#wBoxes > 0) then
						exports.cr_radar:setGPSDestination(1295.0541992188, 166.92585754395)
					end
					if(not isElement(wreckage) and #wBoxes == 0) then
						exports.cr_radar:setGPSDestination(2768.033203125, -2392.8449707031)
					end
				end
			end
		end
	end
end)