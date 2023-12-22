timerHandler = nil
function startPanelKeyHandler(key, pressed)
	if(not getElementJobData(localPlayer, "started")) then
		if(key == "e") then
			if(pressed) then
				panelKeys["start"] = true
				keyDatas["start"]["start"] = getTickCount()
				keyDatas["start"]["stop"] = getTickCount()+1500
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
				timerHandler = setTimer(function() 
					local blip = createBlip(-1858.8732910156, -1650.6628417969, 26.690162658691)
					exports.cr_radar:createStayBlip("Roncsfeldolgozó", blip, 1, "kek", 15, 15, 255, 255, 255, false)
					
					blip = createBlip(1295.0541992188, 166.92585754395, 20.4609375)
					exports.cr_radar:createStayBlip("Roncstelep", blip, 1, "zold", 15, 15, 255, 255, 255, false)
					
					showPanel(1, false)
					initializeLoadMarkers()
					triggerServerEvent("startedCartrans", localPlayer, localPlayer)
					removeEventHandler("onClientKey", root, startPanelKeyHandler)
					startTime = getTickCount()
					
					local m = createMarker(-1855.9727783203, -1627.8669433594, 20.75, "cylinder", 2, 0, 0, 150, 100)
					m:setData("job >> data", {["job"] = 3, ["starter"] = localPlayer:getData("acc >> id"), ["forkliftStarter"] = true})
					
					m = createMarker(1295.6427001953, 171.86511230469, 19.4609375, "checkpoint", 1, 0, 150, 0, 150)
					m:setData("job >> data", {["job"] = 3, ["starter"] = localPlayer:getData("acc >> id"), ["putdownMarker"] = true})
					
					if(checkboxes["tutorial"]) then
						setTimer(function() 
							setElementJobData(localPlayer, "tutorial", true)
						end, 150, 1)
						nextTutorial()
					end
				end, 1500, 1)
			else
				panelKeys["start"] = false
				keyDatas["start"]["start"] = 0
				keyDatas["start"]["stop"] = 0
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
			end
		end 
	end
end

function stopPanelKeyHandler(key, pressed)
	if(key == "e") then
		if(pressed) then
			panelKeys["stop"] = true
			keyDatas["stop"]["start"] = getTickCount()
			keyDatas["stop"]["stop"] = getTickCount()+1500
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
			
			timeChallenge = 0
			startTime = 0
			
			timerHandler = setTimer(function() 
				exports.cr_radar:destroyStayBlip("Roncsfeldolgozó")
				exports.cr_radar:destroyStayBlip("Roncstelep")
				showPanel(2, false)
				setTimer(function()
					local veh = getElementJobData(localPlayer, "jobVehicle")
					triggerServerEvent("destroyWreckage", localPlayer, localPlayer, getElementJobData(veh, "wreckage"))
					triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 530)
					triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 578)
					destroyElementJobData(localPlayer)
				end, 250, 1)
				destroyJobMarkers()
				outputChatBox(msgs["info"].."Befejezted a munkádat.", 255, 255, 255, true)
				exports.cr_tutorial:hidePanel()
				removeEventHandler("onClientKey", root, stopPanelKeyHandler)
				removeEventHandler("onClientKey", root, stopPanelKeyHandler)
			end, 1500, 1)
		else
			panelKeys["stop"] = false
			keyDatas["stop"]["start"] = 0
			keyDatas["stop"]["stop"] = 0
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
		end
	end
end

function preventForkliftDetach()
	local veh = localPlayer:getOccupiedVehicle()
	local x, y, z = veh:getComponentPosition("misc_a")
	if(x and y and z) then
		if(z <= -0.28) then
			toggleControl("special_control_down", false)
		else 
			toggleControl("special_control_down", true)
		end
	end
end

local used = false
addEventHandler("onClientKey", root, function(key, press)
	local veh = localPlayer:getOccupiedVehicle()
	if(isElement(veh)) then
		if(veh:getModel() == 530) then
			if(used == key or not used) then
				if(key == "num_2" or key == "end") then
					if(press) then
						addEventHandler("onClientRender", root, preventForkliftDetach)
						used = key
					else
						removeEventHandler("onClientRender", root, preventForkliftDetach)
						used = false
					end
				elseif(key == "num_8" or key == "delete") then
					if(press) then
						addEventHandler("onClientRender", root, preventForkliftDetach)
						used = key
					else
						removeEventHandler("onClientRender", root, preventForkliftDetach)
						used = false
					end
				end
			end
		end
	end
end)

function forkliftPanelKeyHandler(key, pressed)
	if(getElementJobData(localPlayer, "started")) then
		if(key == "e") then
			if(pressed) then
				panelKeys["request"] = true
				keyDatas["request"]["start"] = getTickCount()
				keyDatas["request"]["stop"] = getTickCount()+1500
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
				timerHandler = setTimer(function() 
					showPanel(3, false)
					triggerServerEvent("createForklift", localPlayer, localPlayer)
					removeEventHandler("onClientKey", root, forkliftPanelKeyHandler)
					if(tutorialState == 3) then
						nextTutorial()
					end
				end, 1500, 1)
			else
				panelKeys["request"] = false
				keyDatas["request"]["start"] = 0
				keyDatas["request"]["stop"] = 0
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
			end
		end
	end
end

function forkliftDespawnPanelKeyHandler(key, pressed)
	if(getElementJobData(localPlayer, "started")) then
		if(key == "e") then
			if(pressed) then
				panelKeys["despawnRequest"] = true
				keyDatas["despawnRequest"]["start"] = getTickCount()
				keyDatas["despawnRequest"]["stop"] = getTickCount()+1500
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
				timerHandler = setTimer(function() 
					showPanel(4, false)
					triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 530)
					removeEventHandler("onClientKey", root, forkliftPanelKeyHandler)
				end, 1500, 1)
			else
				panelKeys["despawnRequest"] = false
				keyDatas["despawnRequest"]["start"] = 0
				keyDatas["despawnRequest"]["stop"] = 0
				if(isTimer(timerHandler)) then
					killTimer(timerHandler)
				end
			end
		end
	end
end

-- function renderTeszt()
	-- local veh = localPlayer:getOccupiedVehicle()
	-- if(isElement(veh)) then
		-- for i, v in pairs(veh:getComponents()) do
			-- if(i == "chassis_dummy") then
				-- local x, y, z = veh:getComponentPosition(i, "world")
				-- local px, py = getScreenFromWorldPosition(x+1.75, y-5, z)
				-- dxDrawRectangle(px, py, 10, 10, tocolor(0, 0, 0, 100))
			-- end
		-- end
	-- end
-- end
-- addEventHandler("onClientRender", root, renderTeszt)

-- addCommandHandler("addbox", function() 
	-- local veh = localPlayer:getOccupiedVehicle()
	-- local e = createObject(7955,0,0,0)
	-- e:setCollisionsEnabled(false)
	-- e:attach(veh, 0, -4.5, 0.5)
	
-- end)

-- addCommandHandler("targoncateszt2", function() 
	-- local veh = localPlayer:getOccupiedVehicle()
	-- for i, v in pairs(veh:getComponents()) do
		-- if(i == "misc_a") then
			-- local x, y, z = veh:getComponentPosition(i)
			-- if(x and y and z) then
				-- outputChatBox(z)
			-- end
		-- end
	-- end
-- end)