local showWarning = false;
local otherVehicle = false;
function renderWarning()
	if(isTimer(showWarning)) then
        local x, y, w, h = sx/2-800/2, sy - 100 - 30, 800, 30
        local font = exports['cr_fonts']:getFont("Roboto", 10)
		dxDrawText("Figyelem! Ez a jármű nem a te munkakocsid! Kérlek erősítsd meg, a felpakolást, azzal, hogy újra lenyomva tartod az 'E' gombot!", x, y, x+w, y+h, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
        dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 100))
	end
end

function loadRockKeyHandler(key, press)
	if(not isCursorShowing() and not isChatBoxInputActive() and not isPedInVehicle(localPlayer)) then
		if(getElementJobData(localPlayer, "started")) then
			if(getElementJobData(localPlayer, "rockInHand")) then
				if(not isTimer(showWarning)) then
					if(key == "e") then
						if(press) then
							local veh = getNearestVehicle(localPlayer, 5)
							if(veh) then
								if(veh:getData("veh >> job") == 1) then
									local bags = getElementJobData(veh, "refinedRocks")
									if(#bags == 0) then
										if(not isTimer(functionTimer)) then
											vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
											local pos = localPlayer:getPosition()
											if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) <= 1) then
												if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
													exports.cr_progressbar:createProgressbar("miner >> felpakolas", tocolor(0, 150, 0, 255), "Felpakolás...", 2000)
													addEventHandler("onClientRender", root, renderRockAction, true, "low-5")
													functionTimer = setTimer(function(v) 
														triggerServerEvent("addRockToVehicle", localPlayer, localPlayer, v)
														if(tutorialState == 2) then
															nextTutorial()
														end
														vcX, vcY, vcZ = false, false, false
														removeEventHandler("onClientRender", root, renderRockAction)
														removeEventHandler("onClientKey", root, loadRockKeyHandler)
													end, 2000, 1, veh)
												else
													otherVehicle = veh:getData("veh >> id")
													addEventHandler("onClientRender", root, renderWarning, true, "low-5")
													showWarning = setTimer(function() 
														removeEventHandler("onClientRender", root, renderWarning)
													end, 5000, 1)
												end
											end
										end
									end
								end
							end
						else
							if(isTimer(functionTimer)) then
								exports.cr_progressbar:deleteProgressbar("miner >> felpakolas")
								killTimer(functionTimer)
							end
							removeEventHandler("onClientRender", root, renderRockAction)
						end
					end
				else
					if(key == "e") then
						if(press) then
							killTimer(showWarning)
							removeEventHandler("onClientRender", root, renderWarning)
							local veh = getNearestVehicle(localPlayer, 5)
							if(veh) then
								if(otherVehicle == veh:getData("veh >> id")) then
									vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
									local pos = localPlayer:getPosition()
									if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) <= 1) then
										addEventHandler("onClientRender", root, renderRockAction, true, "low-5")
										exports.cr_progressbar:createProgressbar("miner >> felpakolas", tocolor(0, 150, 0, 255), "Felpakolás...", 2000)
										functionTimer = setTimer(function(v) 
											triggerServerEvent("addRockToVehicle", localPlayer, localPlayer, v)
											otherVehicle = false
											vcX, vcY, vcZ = false, false, false
											removeEventHandler("onClientRender", root, renderRockAction)
											removeEventHandler("onClientKey", root, loadRockKeyHandler)
										end, 2000, 1, veh)
									end
								end
							end
						else
							if(isTimer(functionTimer)) then
								exports.cr_progressbar:deleteProgressbar("miner >> felpakolas")
								killTimer(functionTimer)
								removeEventHandler("onClientRender", root, renderRockAction)
							end
						end
					end
				end
			end
		end
	end
end

function pickupRockFromVehicleHandler(key, press)
	if(not isCursorShowing() and not isChatBoxInputActive() and not isPedInVehicle(localPlayer)) then
		if(localPlayer:getData("char >> job") == 1) then
			if(getElementJobData(localPlayer, "started")) then
				if(not getElementJobData(localPlayer, "rockInHand")) then
					-- if(getElementJobData(localPlayer, "enablePickup")) then
					if(key == "e") then
						if(press) then
							local veh = getNearestVehicle(localPlayer, 5)
							if(veh) then
								if(veh:getData("veh >> job") == 1) then
									if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
										local rocks = getElementJobData(veh, "rocks")
										if(#rocks > 0) then
											if(not isTimer(actionTimer)) then
												vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
												local pos = localPlayer:getPosition()
												if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) <= 1) then
													addEventHandler("onClientRender", root, renderAction, true, "low-5")
													exports.cr_progressbar:createProgressbar("miner >> felvetel", tocolor(0, 0, 150, 255), "Levétel...", 2000)
													actionTimer = setTimer(function() 
														if(tutorialState == 4) then
															nextTutorial()
														end
														triggerServerEvent("pickUpRock", localPlayer, localPlayer, veh)
														toggleControl("sprint", false)
														toggleControl("jump", false)
														removeEventHandler("onClientRender", root, renderAction)
														exports.cr_progressbar:deleteProgressbar("miner >> felvetel")
													end, 2000, 1)
												end
											end
										else
											removeEventHandler("onClientKey", root, pickupRockFromVehicleHandler)
										end
									else
										outputChatBox(msgs["error"].."Ez nem a te munkajárműved.", 255, 255, 255, true)
									end
								end
							end
						else
							if(isTimer(actionTimer)) then
								killTimer(actionTimer)
								removeEventHandler("onClientRender", root, renderAction)
								exports.cr_progressbar:deleteProgressbar("miner >> felvetel")
							end
						end
					end
					-- end
				end
			end
		end
	end
end

function minigameKeyHandler(key, press)
	if(key == "e") then
		if(press) then
			if(localPlayer:getData("job >> refineryMarker")) then
				local rock = getElementJobData(localPlayer, "rockInHand")
				if(isElement(rock)) then
					if(tutorialState == 5) then
						nextTutorial()
					end
					triggerServerEvent("showRefineryMinigame", localPlayer, localPlayer)
					mData["spin"] = 0
					mData["health"] = 0
					mData["type"] = getElementJobData(rock, "type")
					mData["spinning"] = false
					mData["done"] = false
					mData["slot"] = localPlayer:getData("job >> refineryMarkerSlot")
					showCursor(true)
					addEventHandler("onClientRender", root, renderRefineryMinigame, true, "low-5")
					addEventHandler("onClientClick", root, doRefineryMinigame)
					addEventHandler("onClientCursorMove", root, onMoveCursor)
				end
			end
		end
	end
end

function loadBagKeyHandler(key, press)
	if(not isCursorShowing() and not isChatBoxInputActive() and not isPedInVehicle(localPlayer)) then
		if(key == "e") then
			if(press) then
				if(not getElementJobData(localPlayer, "putdown")) then
					if(not getElementJobData(localPlayer, "deposited")) then
						local veh = getNearestVehicle(localPlayer, 5)
						if(veh) then
							if(veh:getData("veh >> job") == 1) then
								if(not isTimer(putOnTimer)) then
									vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
									local pos = localPlayer:getPosition()
									if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) <= 1) then
										local rocks = getElementJobData(veh, "rocks") or {}
										if(#rocks == 0) then
											exports.cr_progressbar:createProgressbar("miner >> felpakolas", tocolor(0, 150, 0, 255), "Felpakolás...", 2000)
											addEventHandler("onClientRender", root, renderAction, true, "low-5")
											putOnTimer = setTimer(function(v) 
												if(not getElementJobData(v, "deposited")) then
													local bags = getElementJobData(v, "refinedRocks") or {}
													if(#bags < 6) then
														local sprint = isControlEnabled("sprint")
														local jump = isControlEnabled("jump")
														toggleControl("sprint", sprint)
														toggleControl("jump", jump)
														triggerServerEvent("addBagToVehicle", localPlayer, localPlayer, v)
														removeEventHandler("onClientRender", root, renderAction)
														localPlayer:setData("forceAnimation", {"", ""})
														removeEventHandler("onClientKey", root, loadBagKeyHandler)
													else
														outputChatBox(msgs["error"].." A jármű tele van.", 255, 255, 255, true)
													end
												else
													outputChatBox(msgs["error"].." Ez a jármű épp lepakolásra vár.", 255, 255, 255, true)
												end
											end, 2000, 1, veh)
										end
									end
								end
							end
						end
					end
				end
			else
				if(isTimer(putOnTimer)) then
					killTimer(putOnTimer)
					removeEventHandler("onClientRender", root, renderAction)
					exports.cr_progressbar:deleteProgressbar("miner >> felpakolas")
				end
			end
		end
	end
end

function pickupBagFromVehicleKeyHandler(key, pressed)
	if(not isCursorShowing() and not isChatBoxInputActive() and not isPedInVehicle(localPlayer)) then
		if(localPlayer:getData("char >> job") == 1) then
			if(getElementJobData(localPlayer, "started")) then
				if(not getElementJobData(localPlayer, "bagInHand")) then
					if(getElementJobData(localPlayer, "enablePickupBag")) then
						if(key == "e") then
							if(pressed) then
								local veh = getNearestVehicle(localPlayer, 5)
								if(veh) then
									if(veh:getData("veh >> job") == 1) then
										if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
											local bags = getElementJobData(veh, "refinedRocks")
											if(#bags > 0) then
												if(not isTimer(actionTimer)) then
													vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
													local pos = localPlayer:getPosition()
													if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) <= 1) then
														addEventHandler("onClientRender", root, renderAction, true, "low-5")
														exports.cr_progressbar:createProgressbar("miner >> felvetelKocsirol", tocolor(0, 0, 150, 255), "Levétel...", 2000)
														actionTimer = setTimer(function(v) 
															triggerServerEvent("pickUpBagFromVehicle", localPlayer, localPlayer, v)
															toggleControl("sprint", false)
															toggleControl("jump", false)
															removeEventHandler("onClientRender", root, renderAction)
														end, 2000, 1, veh)
													end
												end
											end
										else
											outputChatBox(msgs["error"].." Ez nem a te munkajárműved.", 255, 255, 255, true)
										end
									end
								end
							else
								if(isTimer(actionTimer)) then
									killTimer(actionTimer)
									removeEventHandler("onClientRender", root, renderAction)
									exports.cr_progressbar:deleteProgressbar("miner >> felvetelKocsirol")
								end
							end
						end
					end
				end
			end
		end
	end
end

function putdownBagKeyHandler(key, press)
	if(not isCursorShowing() and not isChatBoxInputActive() and not isPedInVehicle(localPlayer)) then
		if(key == "e") then
			if(press) then
				if(getElementJobData(localPlayer, "bagInHand")) then
					if(getElementJobData(localPlayer, "deposited")) then
						exports.cr_progressbar:createProgressbar("miner >> lerakas", tocolor(0, 0, 150, 255), "Lerakás...", 2000)
						addEventHandler("onClientRender", root, renderAction, true, "low-5")
						local pos = localPlayer:getPosition()
						vcX, vcY, vcZ = pos.x, pos.y, pos.z
						putDownTimer = setTimer(function() 
							local sprint = isControlEnabled("sprint")
							local jump = isControlEnabled("jump")
							toggleControl("sprint", sprint)
							toggleControl("jump", jump)
							triggerServerEvent("addBagToGlobal", localPlayer, localPlayer)
							removeEventHandler("onClientRender", root, renderAction)
							localPlayer:setData("forceAnimation", {"", ""})
						end, 2000, 1)
					end
				end
			else
				if(isTimer(putDownTimer)) then
					killTimer(putDownTimer)
					removeEventHandler("onClientRender", root, renderAction)
					exports.cr_progressbar:deleteProgressbar("miner >> lerakas")
				end
			end
		end
	end
end

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
					local blip = createBlip(336.34429931641, -65.439849853516, 1.5544219017029)
					exports.cr_radar:createStayBlip("Kő feldolgozó", blip, 1, "kek", 15, 15, 255, 255, 255, false)
					blip = createBlip(-1745.3931884766, -110.01053619385, 3.5546875)
					exports.cr_radar:createStayBlip("Zsák leadó", blip, 1, "zold", 15, 15, 255, 255, 255, false)
					showPanel(1, false)
					triggerServerEvent("startedMiner", localPlayer, localPlayer)
					for i, v in pairs(putdowns) do
						local x, y, z = unpack(v)
						local putdownMarker = createMarker(x, y, z-1, "cylinder", 0.7, 100, 100, 0, 100)
						putdownMarker:setData("job >> data", {["job"] = 1, ["putdownMarker"] = true, ["starter"] = localPlayer:getData("acc >> id"),})
					end
					removeEventHandler("onClientKey", root, startPanelKeyHandler)
					startTime = getTickCount()
					if(checkboxes["tutorial"]) then
						setTimer(function()
							setElementJobData(localPlayer, "tutorial", true)
							nextTutorial()
						end, 100, 1)
					end
				end, 1500, 1)
			else
				panelKeys["start"] = false
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