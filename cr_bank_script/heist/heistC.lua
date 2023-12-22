local isPlayerInBank, isBankUnderRobbing, isPlayerInStartCol, startTimer, alarm, alarmSound, conversationTimer, drillPoint, drillerSound, guardNPCS, guardCheckTimer, isPlayerInStealthStart, stealthStartMarker, stealthStartMarkerID, isPlayerInEscape, escapeMarker, escapeID = false, false, false, nil, false, false, nil, false, false, {}, nil, false, false, false, false, false, false;
local sx, sy = guiGetScreenSize();

function startAlarm(e)
	if(not alarmSound) then
		local pos = e:getPosition()
		alarmSound = playSound3D("files/alarm.mp3", pos.x, pos.y, pos.z, true, true)
		setSoundMaxDistance(alarmSound, 125)
	end
end

function stopAlarm()
	if(alarmSound) then
		stopSound(alarmSound)
	end
end

addEventHandler("onClientElementDataChange", root, function(dName) 
	if(source and source:getData("bank >> radius")) then
		if(dName == "bank >> alarm") then
			if(source:getData(dName)) then
				startAlarm(source)
			else
				stopAlarm()
			end
		elseif(dName == "bank >> underRobbing") then
			isBankUnderRobbing = source:getData("bank >> underRobbing")
		end
	end
end)

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end

local ImageMaterials = {
	dxCreateTexture("files/laptop1.png","dxt5", true, "wrap"),
	dxCreateTexture("files/laptop2.png","dxt5", true, "wrap"),
}
function renderSecurityRoom()
	local x, y, z = unpack(securityPoint)
	local pos = localPlayer:getPosition()
	local distance = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, x, y, z)
	if(distance <= 10) then
		dxDrawImage3D(x, y, z+1, 0.5, 0.5, ImageMaterials[isBankUnderRobbing and 2 or 1], tocolor(255, 255, 255, 255)) 
	end
end

addEventHandler("onClientColShapeHit", resourceRoot, function(e, md) 
	if(e == localPlayer and md) then
		if(source:getData("bank >> radius")) then
			isPlayerInBank = true
			isBankUnderRobbing = source:getData("bank >> underRobbing")
			triggerServerEvent("getGuardNPCS", resourceRoot)
			alarm = source:getData("bank >> alarm")
			addEventHandler("onClientRender", root, renderSecurityRoom, true, "low-5")
			if(not isTimer(guardCheckTimer)) then
				guardCheckTimer = setTimer(function() 
					if(guardNPCS) then
						for i, v in pairs(guardNPCS) do
							local pos, ppos = localPlayer:getPosition(), v[1]:getPosition()
							if(isLineOfSightClear(pos.x, pos.y, pos.z+1, ppos.x, ppos.y, ppos.z+1, true, true, true, true, true, false, false, nil) and getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 12) then
								-- outputChatBox("1 oké")
								triggerServerEvent("setupGuardShottingToPlayer", resourceRoot, v[1]:getData("bank >> guardID"))
							end
						end
					else
						triggerServerEvent("getGuardNPCS", resourceRoot)
					end
				end, 1000, 0)
			end
			if(not isTimer(startTimer)) then
				startTimer = setTimer(function(s) 
					if(isPlayerInStartCol) then
						local target = getPedTarget(localPlayer)
						if(target and target:getData("bank >> startNPC") and not s:getData("bank >> underRobbing")) then
							isBankUnderRobbing = true
							s:setData("bank >> underRobbing", true)
							local tbl = getNearbyPlayers(20)
							triggerServerEvent("NPCOpenDoor", resourceRoot, tbl)
							conversationTimer = setTimer(function() 
								if(isPlayerInStartCol) then
									setTimer(function() 
										s:setData("bank >> alarm", true)
									end, 50000, 1)
								else
									s:setData("bank >> alarm", true)
								end
							end, 10000, 1)
							
						end
					end
				end, 500, 0, source)
			end
			if(alarm and not alarmSound) then
				startAlarm(source)
			end
		elseif(source:getData("bank >> robStart")) then
			isPlayerInStartCol = true
		end
	end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(e, md) 
	if(e == localPlayer and md) then
		if(source:getData("bank >> radius")) then
			removeEventHandler("onClientRender", root, renderSecurityRoom)
			isPlayerInBank = false
			isBankUnderRobbing = false
			alarm = false
			if(isTimer(startTimer)) then
				killTimer(startTimer)
			end
			if(isTimer(guardCheckTimer)) then
				killTimer(guardCheckTimer)
			end
		elseif(source:getData("bank >> robStart")) then
			isPlayerInStartCol = false
		end
	end
end)

addEventHandler("onClientPlayerWeaponFire", localPlayer, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement) 
	if(weapon and not exceptions[weapon]) then
		if(isPlayerInBank) then
			if(not alarm) then
				for i, v in pairs(getElementsByType("colshape"), resourceRoot) do
					if(v:getData("bank >> radius")) then
						alarm = true
						setTimer(function() 
							startAlarm(v)
						end, 10000, 1)
						triggerServerEvent("setNPCSafeAnim", resourceRoot)
						break
					end
				end
			end
		end
	end
end)

local startTime, endTime = 0, 0
local doors = {}
function renderDoorOpen()
	local now = getTickCount()
	local elapsedTime = now - startTime
	local duration = endTime - startTime
	local progress = elapsedTime / duration
	for i, v in pairs(doors) do
		local newRot = interpolateBetween(v[2], 0, 0, v[3], 0, 0, progress, "Linear")
		v[1]:setData("bank >> doorRot", newRot)
	end
	if(progress == 1.1) then
		removeEventHandler("onClientRender", root, renderDoorOpen)
	end
end

addEvent("NPCRunToOpenDoor", true)
addEventHandler("NPCRunToOpenDoor", resourceRoot, function(npc) 
	setPedLookAt(npc, 573.84582519531, -1528.3387451172, 16.39599609375, 100)
	setPedAnimation(npc, "ped", "handsup", 9000, false, false, true, true)
	setTimer(function(n)
		setPedAnimation(npc, nil, nil)
	end, 9000, 1, npc)
	setTimer(function(np) 
		setPedControlState(np, "forwards", true)
		setPedControlState(np, "sprint", true)
		setTimer(function(n) 
			setPedControlState(n, "forwards", false)
			setPedControlState(n, "sprint", false)
			n:setData("char >> noDamage", false)
			triggerServerEvent("syncNPC", resourceRoot, n, n:getPosition())
			setTimer(function()
				triggerServerEvent("openStartDoors", resourceRoot)
			end, 10000, 1)
		end, 1750, 1, np)
	end, 10000, 1, npc)
end)

addEvent("toggleDoors", true)
addEventHandler("toggleDoors", resourceRoot, function(d) 
	doors = d
	startTime, endTime = getTickCount(), getTickCount()+1000
	addEventHandler("onClientRender", root, renderDoorOpen, true, "low-5")
end)

addEventHandler("onClientMarkerHit", resourceRoot, function(e, md) 
	if(e == localPlayer and md) then
		local pos = source:getPosition()
		local lpos = localPlayer:getPosition()
		local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, lpos.x, lpos.y, lpos.z)
		if(source:getData("bank >> drillPoint") and dist <= 3.5) then
			drillPoint = tonumber(source:getData("bank >> drillPoint"))
			-- outputChatBox(drillPoint)
		elseif(source:getData("bank >> stealthStart")) then
			isPlayerInStealthStart = true
			stealthStartMarker = source
			stealthStartMarkerID = source:getData("bank >> stealthStartID")
		elseif(source:getData("bank >> escapeMarker")) then
			isPlayerInEscape = true
			escapeMarker = source
			escapeID = source:getData("bank >> escapeID")
		elseif(source:getData("bank >> securityRoom")) then
			localPlayer:setData("bank >> inSecurityPoint", true)
		end
	end
end)

addEventHandler("onClientMarkerLeave", resourceRoot, function(e, md) 
	if(e == localPlayer and md) then
		if(source:getData("bank >> drillPoint") and drillPoint == source:getData("bank >> drillPoint")) then
			drillPoint = false
		elseif(source:getData("bank >> stealthStart")) then
			isPlayerInStealthStart = false
			stealthStartMarker = false
			stealthStartMarkerID = false
		elseif(source:getData("bank >> escapeMarker")) then
			isPlayerInEscape = false
			escapeMarker = false
			escapeID = false
		elseif(source:getData("bank >> securityRoom")) then
			localPlayer:setData("bank >> inSecurityPoint", false)
		end
	end
end)

addEvent("startDrillerSound", true)
addEventHandler("startDrillerSound", resourceRoot, function(x, y, z) 
	if(not drillerSound) then
		drillerSound = playSound3D("files/driller.mp3", x, y, z, true, true)
		setSoundMaxDistance(drillerSound, 75)
		setSoundVolume(drillerSound, 1)
	end
end)

addEvent("stopDrillerSound", true)
addEventHandler("stopDrillerSound", resourceRoot, function(x, y, z) 
	if(drillerSound) then
		stopSound(drillerSound)
		drillerSound = false
	end
end)

addEvent("receiveGuardNPCS", true)
addEventHandler("receiveGuardNPCS", resourceRoot, function(tbl)
	guardNPCS = tbl
end)

local guardFollowingTimers = {};
local shootDelay = nil;
local shootTimeout = nil;

addEvent("guardStartShootingToPlayer", true)
addEventHandler("guardStartShootingToPlayer", resourceRoot, function(gu, el) 
	-- outputChatBox("a kis geci")
	if(not isTimer(guardFollowingTimers[gu:getData("bank >> guardID")])) then
		local timer = setTimer(function(g, e) 
			local pos, ppos = e:getPosition(), g:getPosition()
			local _, _, rot = findRotation3D(ppos.x, ppos.y, ppos.z, pos.x, pos.y, pos.z)
			if(isLineOfSightClear(pos.x, pos.y, pos.z+1, ppos.x, ppos.y, ppos.z+1, true, true, true, true, true, false, false, nil) and getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 20) then
				-- outputChatBox("súúúúúút te geci")
				if(g:getHealth() > 0) then
					setPedAimTarget(g, pos.x, pos.y, pos.z)
					setPedCameraRotation(g, rot)
					setPedControlState(g, "fire", true)
					g:setRotation(0, 0, rot)
					if(not isTimer(shootTimeout)) then
						shootTimeout = setTimer(function() 
							if(not alarm and not isTimer(shootDelay)) then 
								shootDelay = setTimer(function()
									for i, v in pairs(getElementsByType("colshape", resourceRoot)) do
										if(v:getData("bank >> radius")) then
											v:setData("bank >> alarm", true)
											break
										end
									end
								end, 3000, 1)
							end
						end, 300, 1)
					end
				else
					setPedControlState(g, "fire", false)
					g:setData("bank >> guardShootingTo", false)
					killTimer(guardFollowingTimers[g:getData("bank >> guardID")])
					if(isTimer(shootTimeout)) then
						killTimer(shootTimeout)
					end
				end
			else
				setPedControlState(g, "fire", false)
				g:setData("bank >> guardShootingTo", false)
				killTimer(guardFollowingTimers[g:getData("bank >> guardID")])
			end
		end, 250, 0, gu, el)
		guardFollowingTimers[gu:getData("bank >> guardID")] = timer
	end
end)

addEventHandler("onClientPedDamage", getRootElement(), function(a, w, b, l) 
	if(source:getData("bank >> guardNPC") or source:getData("bank >> startNPC") and not source:getData("char >> noDamage")) then
		if(w and b == 9) then
			triggerServerEvent("headShotPed", resourceRoot, source)
		end
	end
end)

addCommandHandler("createdrill", function(cmd) 
	if(tonumber(drillPoint) and isBankUnderRobbing) then
		triggerServerEvent("createDrill", resourceRoot, drillPoint)
	end
end)

local showPanel = false
local selectedSlot = 1
function renderControlPanel()
	local w, h = 750, 500
	local x, y = sx/2-w/2, sy/2-h/2
	dxDrawRectangle(x, y, w, h, tocolor(100, 100, 100, 175))
end

function controlPanelKey(key, press)
	if(key == "arrow_u" and press) then
		
	elseif(key == "arrow_d" and press) then
		
	elseif(key == "arrow_l" and press) then
		
	elseif(key == "arrow_r" and press) then
		
	elseif(key == "enter" and press) then
		
	elseif(key == "backspace" and press) then
		closeControlPanel()
	end
end

function showControlPanel()
	if(not showPanel) then
		setTimer(function() 
			addEventHandler("onClientRender", root, renderControlPanel, true, "low-5")
			addEventHandler("onClientKey", root, controlPanelKey)
		end, 500, 1)
		fadeCamera(false, 0.5)
		showPanel = true
		toggleAllControls(false, false, false)
		showCursor(true)
	end
end

function closeControlPanel()
	if(showPanel) then
		removeEventHandler("onClientRender", root, renderControlPanel)
		removeEventHandler("onClientKey", root, controlPanelKey)
		fadeCamera(true, 0.5)
		showPanel = false
		toggleAllControls(true, true, true)
		showCursor(false)
	end
end

addEventHandler("onClientPlayerDamage", root, function()
	if(source == localPlayer) then
		if(showPanel) then
			closeControlPanel()
		end
	end
end)

local st, et, usedRope, pX, pY, pZ, o, tp = 0, 0, false, 0, 0, 0, false, 0;
function renderUseRope()
	local now = getTickCount()
	local elapsedTime = now - st
	local duration = et - st
	local progress = elapsedTime / duration
	local z = interpolateBetween(pZ, 0, 0, tp, 0, 0, progress, "Linear")
	localPlayer:setRotation(0, 0, 180)
	if(progress < 1.1) then
		o:setPosition(pX, pY, z)
	end
end

function useRope(id, isUp, marker)
	if(not usedRope) then
		if(not marker:getData("bank >> usedRope")) then
			if(isUp) then
				stealthStartMarker:setData("bank >> usedRope", true)
				usedRope = id
				st, et = getTickCount(), getTickCount()+5000
				local pos = localPlayer:getPosition()
				pX, pY, pZ = stealthRopePositions[usedRope]["start"][1], stealthRopePositions[usedRope]["start"][2], pos.z
				tp = stealthRopePositions[tonumber(usedRope)]["start"][3]-0.25
				o = createObject(1271, pX, pY, pZ-1)
				o:setCollisionsEnabled(false)
				o:setAlpha(0)
				localPlayer:attach(o)
				toggleAllControls(false, false, false)
				addEventHandler("onClientRender", root, renderUseRope, true, "low-5")
				localPlayer:setData("Actionbar.enabled", false)
				localPlayer:setData("enabledInventory", false)
				setTimer(function(s) 
					toggleAllControls(true, true, true)
					removeEventHandler("onClientRender", root, renderUseRope)
					local lx, ly, lz = stealthRopePositions[usedRope]["inside"][1], stealthRopePositions[usedRope]["inside"][2], stealthRopePositions[usedRope]["inside"][3]
					localPlayer:setPosition(lx, ly, lz)
					usedRope = false
					o:destroy()
					localPlayer:setFrozen(false)
					localPlayer:setCollisionsEnabled(true)
					s:setData("bank >> usedRope", false)
					localPlayer:setData("Actionbar.enabled", true)
					localPlayer:setData("enabledInventory", true)
				end, 7000, 1, stealthStartMarker)
				setTimer(function() 
					localPlayer:detach(o)
					localPlayer:setFrozen(true)
					localPlayer:setCollisionsEnabled(false)
					setTimer(function() 
						triggerServerEvent("dodgeWindow", resourceRoot)
					end, 150, 1)
				end, 5000, 1)
				triggerServerEvent("addRopeAnimToPlayer", resourceRoot)
			else
				for i, v in pairs(getElementsByType("marker", resourceRoot)) do
					if(v:getData("bank >> stealthStartID") == escapeMarker:getData("bank >> escapeID")) then
						v:setData("bank >> usedRope", true)
						usedRope = id
						localPlayer:setData("Actionbar.enabled", false)
						localPlayer:setData("enabledInventory", false)
						localPlayer:setRotation(0, 0, 0)
						setTimer(function(sss) 
							localPlayer:setRotation(0, 0, 0)
							triggerServerEvent("dodgeWindow", resourceRoot)
							setTimer(function(ss) 
								triggerServerEvent("addRopeAnimToPlayer", resourceRoot)
								local pos = localPlayer:getPosition()
								tp = stealthRopePositions[tonumber(usedRope)]["end"][3]
								pX, pY, pZ = stealthRopePositions[usedRope]["start"][1], stealthRopePositions[usedRope]["start"][2], stealthRopePositions[tonumber(usedRope)]["start"][3]
								o = createObject(1271, pX, pY, pZ)
								o:setCollisionsEnabled(false)
								o:setAlpha(0)
								localPlayer:setRotation(0, 0, 180)
								localPlayer:attach(o)
								toggleAllControls(false, false, false)
								st, et = getTickCount(), getTickCount()+5000
								addEventHandler("onClientRender", root, renderUseRope, true, "low-5")
								setTimer(function(s) 
									toggleAllControls(true, true, true)
									removeEventHandler("onClientRender", root, renderUseRope)
									-- local lx, ly, lz = stealthRopePositions[usedRope]["start"][1], stealthRopePositions[usedRope]["start"][2], stealthRopePositions[usedRope]["start"][3]
									-- localPlayer:setPosition(lx, ly, lz)
									usedRope = false
									o:destroy()
									localPlayer:setCollisionsEnabled(true)
									s:setData("bank >> usedRope", false)
									localPlayer:setData("Actionbar.enabled", true)
									localPlayer:setData("enabledInventory", true)
								end, 5000, 1, ss)
							end, 2150, 1, sss)
						end, 150, 1, v)
						break
					end
				end
			end
		end
	end
end

local ropeCooldown = nil
addEventHandler("onClientKey", root, function(key, press)
	if(isPlayerInBank) then
		if(isPlayerInStealthStart and not isTimer(ropeCooldown)) then
			if(key == "e" and press) then
				if(not stealthStartMarker:getData("bank >> occupiedRope")) then
					if(localPlayer:getData("weaponInHand") == 0 or localPlayer:getData("weaponInHand") == false) then
						triggerServerEvent("showRopeToEveryoneS", resourceRoot, stealthStartMarkerID)
						triggerServerEvent("startedStealthRobbing", resourceRoot, stealthStartMarkerID)
						stealthStartMarker:setData("bank >> occupiedRope", true)
						ropeCooldown = setTimer(function() end, 10000, 1)
						useRope(stealthStartMarkerID, true, stealthStartMarker)
						if(not isBankUnderRobbing) then 
							for i, v in pairs(getElementsByType("colshape", resourceRoot)) do
								if(v:getData("bank >> radius")) then
									v:setData("bank >> underRobbing", true)
									break
								end
							end
							triggerServerEvent("spawnStealthGuards", resourceRoot)
						end
					end
				else
					if(localPlayer:getData("weaponInHand") == 0 or localPlayer:getData("weaponInHand") == false) then
						ropeCooldown = setTimer(function() end, 10000, 1)
						useRope(stealthStartMarkerID, true, stealthStartMarker)
					end
				end
			end
		elseif(isPlayerInEscape and not isTimer(ropeCooldown)) then
			if(key == "e" and press) then
				-- outputChatBox("asd")
				for i, v in pairs(getElementsByType("marker", resourceRoot)) do
					if(v:getData("bank >> stealthStartID") == escapeMarker:getData("bank >> escapeID")) then
						if(not v:getData("bank >> occupiedRope")) then
							if(localPlayer:getData("weaponInHand") == 0 or localPlayer:getData("weaponInHand") == false) then
								v:setData("bank >> occupiedRope", true)
								triggerServerEvent("showRopeToEveryoneS", resourceRoot, escapeID)
								ropeCooldown = setTimer(function() end, 10000, 1)
								useRope(escapeID, false, v)
							end
						else
							if(localPlayer:getData("weaponInHand") == 0 or localPlayer:getData("weaponInHand") == false) then
								ropeCooldown = setTimer(function() end, 10000, 1)
								useRope(escapeID, false, v)
							end
						end
						break
					end
				end
			end
		elseif(localPlayer:getData("bank >> inSecurityPoint")) then
			if(key == "e" and press) then
				showControlPanel()
			end
		end
	end
end)

local ropePositions = {};
local ropeTimers = {};
local rendered = false;
function renderRopes()
	for i, v in pairs(ropePositions) do
		local x, y, z, x2, y2, z2 = stealthRopePositions[v]["start"][1], stealthRopePositions[v]["start"][2], stealthRopePositions[v]["start"][3], stealthRopePositions[v]["end"][1], stealthRopePositions[v]["end"][2], stealthRopePositions[v]["end"][3]
		dxDrawLine3D(x, y, z, x2, y2, z2, tocolor(25, 25, 25, 255), 1)
	end
	if(#ropePositions == 0) then
		removeEventHandler("onClientRender", root, renderRopes)
		rendered = false
	end
end
addEvent("showRopeToEveryone", true)
addEventHandler("showRopeToEveryone", resourceRoot, function(id)
	id = tonumber(id)
	-- ropePositions[id] = id
	table.insert(ropePositions, id)
	-- ropeTimers[id] = setTimer(function(i) 
		-- table.remove(ropePositions, i)
		-- table.remove(ropeTimers, i)
	-- end, 60000, 1, id)
	if(not rendered) then
		addEventHandler("onClientRender", root, renderRopes, true, "low-5")
		rendered = true
	end
end)