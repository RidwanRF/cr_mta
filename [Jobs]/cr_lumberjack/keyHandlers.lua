function pilePickupKeyHandler(key, pressed)
	if(not getElementJobData(localPlayer, "deposit")) then
		if(not getElementJobData(localPlayer, "enablePickUp")) then
			if(not getElementJobData(localPlayer, "pileInHand")) then
				if(key == "e") then
					if(pressed) then
						if(not isTimer(pickUpTimer)) then
							local pile = getNearestPile(localPlayer, 1.75)
							if(isElement(pile)) then
								local pos = pile:getPosition()
								vcX, vcY, vcZ = pos.x, pos.y, pos.z
								exports.cr_progressbar:createProgressbar("lumberjack >> pilePickup", tocolor(0, 0, 150, 255), "Felvétel...", 2000)
								addEventHandler("onClientRender", root, renderAction, true, "low-5")
								pickUpTimer = setTimer(function() 
									if(getElementJobData(pile, "owner") == localPlayer:getData("acc >> id") or getElementJobData(pile, "owner") == false) then
										removeEventHandler("onClientRender", root, renderAction)
										vcX, vcY, vcZ = false, false, false
										local left = getElementJobData(pile, "leftPiles")-1
										setElementJobData(pile, "leftPiles", left)
										exports.cr_inventory:putdownWeapon()
										triggerServerEvent("pickUpPile", localPlayer, localPlayer, pile, left)
										setElementJobData(pile, "owner", localPlayer:getData("acc >> id"))
										addEventHandler("onClientKey", root, loadPileToVehicleKeyHandler)
									else
										outputChatBox(msgs["error"].."Ez a farakás nem a tiéd, vagy már felvették.", 255, 255, 255, true)
									end
								end, 2000, 1)
							end
						end
					else
						if(isTimer(pickUpTimer)) then
							killTimer(pickUpTimer)
							removeEventHandler("onClientRender", root, renderAction)
							exports.cr_progressbar:deleteProgressbar("lumberjack >> pilePickup")
							vcX, vcY, vcZ = false, false, false
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientKey", root, pilePickupKeyHandler)

function loadPileToVehicleKeyHandler(key, pressed)
	if(not getElementJobData(localPlayer, "deposit")) then
		if(not getElementJobData(localPlayer, "enablePickUp")) then
			if(getElementJobData(localPlayer, "pileInHand")) then
				if(not isTimer(warningTimer)) then
					if(key == "e") then
						if(pressed) then
							if(not isTimer(loadTimer) and not isTimer(pickUpTimer)) then
								local veh = getNearestVehicle(localPlayer, 5)
								if(isElement(veh)) then
									local pos = localPlayer:getPosition()
									vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
									if(getDistanceBetweenPoints3D(vcX, vcY, vcZ, pos.x, pos.y, pos.z) <= 1) then
										if(isTimer(warningTimer)) then
											killTimer(warningTimer)
											removeEventHandler("onClientRender", root, renderWarning)
										end
										if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id") and not isTimer(warningTimer)) then
											exports.cr_progressbar:createProgressbar("lumberjack >> pileLoad", tocolor(0, 150, 0, 255), "Felpakolás...", 2000)
											addEventHandler("onClientRender", root, renderAction, true, "low-5")
											loadTimer = setTimer(function() 
												local piles = getElementJobData(veh, "piles") or {}
												if(#piles < 6) then 
													triggerServerEvent("loadPileToVehicle", localPlayer, localPlayer, veh)
													removeEventHandler("onClientKey", root, loadPileToVehicleKeyHandler)
													if(tutorialState == 3) then
														nextTutorial()
													end
												else
													outputChatBox(msgs["error"].."A jármű teljesen meg van pakolva. (6/6)", 255, 255, 255, true)
												end
											end, 2000, 1)
										else
											addEventHandler("onClientRender", root, renderWarning, true, "low-5")
											warningTimer = setTimer(function() 
												removeEventHandler("onClientRender", root, renderWarning)
											end, 5000, 1)
										end
									end
								end
							end
						else
							if(isTimer(loadTimer)) then
								killTimer(loadTimer)
								removeEventHandler("onClientRender", root, renderAction)
								exports.cr_progressbar:deleteProgressbar("lumberjack >> pileLoad")
								vcX, vcY, vcZ = false, false, false
							end
						end
					end
				else
					if(key == "e") then
						if(pressed) then
							if(not isTimer(loadTimer) and not isTimer(pickUpTimer)) then
								local veh = getNearestVehicle(localPlayer, 5)
								if(isElement(veh)) then
									local pos = localPlayer:getPosition()
									vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
									if(getDistanceBetweenPoints3D(vcX, vcY, vcZ, pos.x, pos.y, pos.z) <= 1) then
										if(isTimer(warningTimer)) then
											killTimer(warningTimer)
											removeEventHandler("onClientRender", root, renderWarning)
											exports.cr_progressbar:createProgressbar("lumberjack >> pileLoad", tocolor(0, 150, 0, 255), "Felpakolás...", 2000)
											addEventHandler("onClientRender", root, renderAction, true, "low-5")
											loadTimer = setTimer(function() 
												local piles = getElementJobData(veh, "piles") or {}
												if(#piles < 6) then 
													triggerServerEvent("loadPileToVehicle", localPlayer, localPlayer, veh)
													removeEventHandler("onClientKey", root, loadPileToVehicleKeyHandler)
												else
													outputChatBox(msgs["error"].."A jármű teljesen meg van pakolva. (6/6)", 255, 255, 255, true)
												end
											end, 2000, 1)
										end
									end
								end
							end
						else
							if(isTimer(loadTimer)) then
								killTimer(loadTimer)
								removeEventHandler("onClientRender", root, renderAction)
								exports.cr_progressbar:deleteProgressbar("lumberjack >> pileLoad")
								vcX, vcY, vcZ = false, false, false
							end
						end
					end
				end
			end
		end
	end
end

function pickupFromVehicleKeyHandler(key, pressed)
	if(getElementJobData(localPlayer, "started") and localPlayer:getData("char >> job") == 2) then
		if(not getElementJobData(localPlayer, "deposit")) then
			if(getElementJobData(localPlayer, "enablePickUp")) then
				if(not getElementJobData(localPlayer, "pileInHand")) then
					if(key == "e") then
						if(pressed) then
							if(not isTimer(pickUpFromVehicleTimer)) then
								local veh = getNearestVehicle(localPlayer, 5)
								if(isElement(veh)) then
									local pos = localPlayer:getPosition()
									vcX, vcY, vcZ = veh:getComponentPosition("boot_dummy", "world")
									if(getDistanceBetweenPoints3D(vcX, vcY, vcZ, pos.x, pos.y, pos.z) <= 1) then
										if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
											local piles = getElementJobData(veh, "piles") or {}
											if(#piles > 0) then
												exports.cr_progressbar:createProgressbar("lumberjack >> pilePickupFromVehicle", tocolor(0, 0, 150, 255), "Levétel...", 2000)
												addEventHandler("onClientRender", root, renderAction, true, "low-5")
												pickUpFromVehicleTimer = setTimer(function() 
													triggerServerEvent("pilePickupFromVehicle", localPlayer, localPlayer, veh)
													removeEventHandler("onClientRender", root, renderAction)
													vcX, vcY, vcZ = false, false, false
												end, 2000, 1)
											end
										else
											outputChatBox(msgs["error"].."Ez nem a te munkakocsid.", 255, 255, 255, true)
										end
									end
								end
							end
						else
							if(isTimer(pickUpFromVehicleTimer)) then
								killTimer(pickUpFromVehicleTimer)
								removeEventHandler("onClientRender", root, renderAction)
								exports.cr_progressbar:deleteProgressbar("lumberjack >> pilePickupFromVehicle")
								vcX, vcY, vcZ = false, false, false
							end
						end
					end
				end
			end
		end
	end
end

function pilePutDownKeyHandler(key, pressed)
	if(getElementJobData(localPlayer, "started") and localPlayer:getData("char >> job") == 2) then
		if(getElementJobData(localPlayer, "deposit")) then
			if(getElementJobData(localPlayer, "pileInHand")) then
				if(key == "e") then
					if(pressed) then
						if(getElementJobData(localPlayer, "pileInHand")) then
							if(not isTimer(putDownTimer)) then
								exports.cr_progressbar:createProgressbar("lumberjack >> pilePutDown", tocolor(0, 0, 150, 255), "Lerakás...", 2000)
								putDownTimer = setTimer(function() 
									removeEventHandler("onClientRender", root, renderAction)
									exports.cr_tutorial:hidePanel()
									-- if not exports.cr_network:getNetworkStatus() then return end
									triggerServerEvent("addPileToGlobal", localPlayer, localPlayer)
								end, 2000, 1)
							end
						end
					else
						if(isTimer(putDownTimer)) then
							killTimer(putDownTimer)
							removeEventHandler("onClientRender", root, renderAction)
							exports.cr_progressbar:deleteProgressbar("lumberjack >> pilePutDown")
						end
					end
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
					local blip = createBlip(-2010.587890625, -2402.61328125, 31.492992401123)
					exports.cr_radar:createStayBlip("Fa leadó telep", blip, 1, "zold", 15, 15, 255, 255, 255, false)
					showPanel(1, false)
					if(isTimer(removeTimer)) then
						killTimer(removeTimer)     
					end
					removeTimer = setTimer(function()
						removeEventHandler("onClientRender", root, renderPanels)
					end, 500, 1)
					triggerServerEvent("startLumberjack", localPlayer, localPlayer)
					removeEventHandler("onClientKey", root, startPanelKeyHandler)
					
					setTimer(function() 
						if(checkboxes["tutorial"]) then
							setElementJobData(localPlayer, "tutorial", true)
							nextTutorial()
						end
					end, 100, 1)
					
					startTime = getTickCount()
				
					keyDatas["start"]["start"] = 0
					keyDatas["start"]["stop"] = 0
					panelKeys["start"] = false
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
			if(not isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
			timerHandler = setTimer(function() 	
				exports.cr_radar:destroyStayBlip("Fa leadó telep")
				showPanel(2, false)
				destroyElementJobData(localPlayer)
                triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
                if(isTimer(removeTimer)) then
                    killTimer(removeTimer)     
                end
                removeTimer = setTimer(function()
                    removeEventHandler("onClientRender", root, renderPanels)
					exports.cr_tutorial:hidePanel()
                end, 500, 1)
                outputChatBox(msgs["info"].." Befejezted a munkádat.", 255, 255, 255, true)
				removeEventHandler("onClientKey", root, stopPanelKeyHandler)
				
				keyDatas["stop"]["start"] = 0
				keyDatas["stop"]["stop"] = 0
				panelKeys["stop"] = false
			end, 1500, 1)
		else
			panelKeys["stop"] = false
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
		end
	end
end