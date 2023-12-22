
timerHandler = nil
function startPanelKeyHandler(key, state)
	if(key == "e") then
		if(state) then
			panelKeys["start"] = true
			keyDatas["start"]["start"] = getTickCount()
			keyDatas["start"]["stop"] = getTickCount()+1500
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
			timerHandler = setTimer(function() 
				triggerServerEvent("startedWastetrans", localPlayer, localPlayer)
				setTimer(function() 
					local r = math.random(1, #wastePoints)
					local x, y, z = unpack(wasteAreaPoints[r]["gps"])
					selectedArea = wastePoints[r]
					setElementJobData(localPlayer, "selectedArea", selectedArea)
					exports.cr_radar:setGPSDestination(x, y)
				end, 250, 1)
				addEventHandler("onClientRender", root, checkWaste)
				-- addEventHandler("onClientKey", root, onHitWaste)
				bindKey("e", "down", onHitWaste)
				removeEventHandler("onClientKey", root, startPanelKeyHandler)
				showPanel(1, false)
				setTimer(function() 
					if(checkboxes["tutorial"]) then
						setElementJobData(localPlayer, "tutorial", true)
						nextTutorial()
					end
					
					startTime = getTickCount()
				
					keyDatas["start"]["start"] = 0
					keyDatas["start"]["stop"] = 0
					panelKeys["start"] = false
				end, 100, 1)
			end, 1500, 1)
		else
			panelKeys["start"] = false
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
		end
	end
end

function stopPanelKeyHandler(key, state)
	if(key == "e") then
		if(state) then
			panelKeys["stop"] = true
			keyDatas["stop"]["start"] = getTickCount()
			keyDatas["stop"]["stop"] = getTickCount()+1500
			timerHandler = setTimer(function() 
				endJob()
			end, 1500, 1)
		else
			panelKeys["stop"] = false
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
		end
	end
end