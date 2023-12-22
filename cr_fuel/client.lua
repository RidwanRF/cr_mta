local font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)

local oranger, orangeg, orangeb = exports['cr_core']:getServerColor("orange", false)

local greenr, greeng, greenb = exports['cr_core']:getServerColor("green", false)

local redr, redg, redb = exports['cr_core']:getServerColor("red", false)

local orange = exports['cr_core']:getServerColor("orange", true)

addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
		elseif sResourceName == "cr_core" then
			oranger, orangeg, orangeb = exports['cr_core']:getServerColor("orange", false)
			greenr, greeng, greenb = exports['cr_core']:getServerColor("green", false)
			redr, redg, redb = exports['cr_core']:getServerColor("red", false)
			orange = exports['cr_core']:getServerColor("orange", true)
		end
	end
)

local sx, sy = guiGetScreenSize()

local white = "#FFFFFF"

local fuelElement
local fuelObject = false

local fuelTimer
local benzincost = 0
local benzintipus = 0

local fuelSound

local amountTimer

local fuelAmount = 0

local start

local y
local textPos

local triggerBlockTime = 500
local triggerBlock = false
local componentPositions = {
	[503] = "wheel_lb_dummy",
	[463] = "handlebars",
	[415] = "wheel_lb_dummy",
	[585] = "wheel_rb_dummy",
	[565] = "wheel_rb_dummy",
}

addEventHandler("onClientClick", root,
	function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
		if state == "down" then
			if clickedElement and not triggerBlock then
						if getElementData(clickedElement, "fuel >> id") then
							--distance figyelő
							local ex, ey, ez = getElementPosition(clickedElement)
							local px, py, pz = getElementPosition(localPlayer)
							local distance = getDistanceBetweenPoints3D(ex, ey, ez, px, py, pz)
							if distance > 1 then return end
							--TriggerBlock
							triggerBlock = true 
							setTimer(function() 
							triggerBlock = false 
							end,triggerBlockTime,1)
							--TriggerBlock 
							if not getElementData(localPlayer, "fuel >> hasFuelGun") then
								if getElementData(clickedElement, "fuel >> usedBy") then return end
								if not getElementData(clickedElement, "fuel >> usedBy") then
									setElementData(localPlayer, "fuel >> hasFuelGun", true)
									setElementData(clickedElement, "fuel >> usedBy", localPlayer)
									setElementData(localPlayer, "fuel >> clickedElement", clickedElement)
									if getElementData(clickedElement, "fuel >> dieselElement") then
										triggerEvent("createMessage", localPlayer, localPlayer, "leakasztja a dízel pisztolyt a tartóról", 1)
										setElementData(localPlayer, "fuel >> fueltype", "diesel")
									elseif getElementData(clickedElement, "fuel >> petrolElement") then
										triggerEvent("createMessage", localPlayer, localPlayer, "leakasztja a benzin pisztolyt a tartóról", 1)
										setElementData(localPlayer, "fuel >> fueltype", "petrol")
									end
									triggerServerEvent("changeFuelGunElement",localPlayer, clickedElement, "delete")
									--Kijelző shader rész
									triggerServerEvent("getFuelTypeToMonitor", localPlayer, clickedElement, localPlayer)
									--
									if not (getElementData(localPlayer, "fuel >> fueltype") == getElementData(clickedElement, "fuel >> fueltype")) then
										fuelAmount = 0
									end
									-- setElementData(localPlayer, "fuel >> fueltype", getElementData(clickedElement, "fuel >> fueltype"))
									-- outputChatBox(tostring(getElementData(localPlayer, "fuel >> fueltype")))
									start = getTickCount()
									getFuelCost()
								else
									exports['cr_infobox']:addBox("error", "Ez a kút már használatban van más által!")
								end
							else
								if localPlayer == getElementData(clickedElement, "fuel >> usedBy") then
									setElementData(localPlayer, "fuel >> hasFuelGun", false)
									setElementData(clickedElement, "fuel >> usedBy", false)
									setElementData(localPlayer, "fuel >> clickedElement", false)
									-- setElementData(localPlayer, "fuel >> fueltype", nil)
									if getElementData(clickedElement, "fuel >> dieselElement") == clickedElement then
									triggerEvent("createMessage", localPlayer, localPlayer, "visszaakasztja a dízel pisztolyt a tartóra", 1)
									elseif getElementData(clickedElement, "fuel >> petrolElement") == clickedElement then
									triggerEvent("createMessage", localPlayer, localPlayer, "visszaakasztja a benzin pisztolyt a tartóra", 1)
									end
									triggerServerEvent("changeFuelGunElement",localPlayer, clickedElement, "create")
									start = nil
								end
							end
				elseif getElementData(clickedElement, "fuel >> pedid") then
					if isElementWithinColShape(localPlayer, getElementData(clickedElement, "fuel >> pedsphere")) then
						if fuelAmount > 0 and fuelElement then
							setElementData(localPlayer, "fuel >> paying", true)
							setElementData(localPlayer, "fuel >> payElement", clickedElement)
							start = getTickCount()
						else
							exports['cr_infobox']:addBox("error", "Nincs kifizetetlen tankolásod!")
						end
					end
				elseif getElementType(clickedElement) == "vehicle" then
					if getElementData(localPlayer, "fuel >> hasFuelGun") then
						if not getElementData(localPlayer, "fuel >> fueling") then
							local model = getElementModel(clickedElement)
							local component
							if componentPositions[model] then
								component = componentPositions[model]
							else
								component = "wheel_lb_dummy"
							end
							local ex, ey, ez = getVehicleComponentPosition(clickedElement, component, "world")
							local px, py, pz = getElementPosition(localPlayer)
							local distance = getDistanceBetweenPoints3D(ex, ey, ez, px, py, pz)
							if distance < 1 then
								if not fuelElement then fuelElement = clickedElement end
								if getElementData(fuelElement, "veh >> fuel") + fuelAmount >= exports['cr_vehicle']:getVehicleMaxFuel(getElementModel(fuelElement)) then exports['cr_infobox']:addBox("error", "A jármű üzemanyag tartálya tele van!") return end
								if getVehicleEngineState(fuelElement) then exports['cr_infobox']:addBox("error", "Először állítsd le a jármű motorját!") return end
								if triggerBlock then return end 
								if (getElementData(clickedElement, "veh >> fueltype") ~= getElementData(clickedElement, "veh >> oldfueltype")) then
								--TriggerBlock
								triggerBlock = true 
								setTimer(function() 
								triggerBlock = false 
								end,triggerBlockTime,1)
								--TriggerBlock 
								end
								local r = findRotation(px, py, ex, ey)
								setPedRotation(localPlayer, r)
								setElementData(localPlayer, "fuel >> fueling", true)
								setElementData(localPlayer, "fuel >> gunAlone", true)
								setTimer(
									function()
										exports['cr_bone_attach']:detachElementFromBone(getElementData(localPlayer, "fuel >> gunElement"))
										exports['cr_animation']:removeAnimation(localPlayer)
									end, 500, 1
								)
							end
						else
							setElementData(localPlayer, "fuel >> fueling", false)
							setElementData(localPlayer, "fuel >> gunAlone", false)
							exports['cr_bone_attach']:attachElementToBone(getElementData(localPlayer, "fuel >> gunElement"), localPlayer, 12, 0.04, 0.04, 0.04, 180, 0, 0)
							exports['cr_animation']:removeAnimation(localPlayer)
						end
					end
				end
			end
			if getElementData(localPlayer, "fuel >> paying") then
				if exports['cr_core']:isInSlot(textPos[1]-126, y+268, 74, 25) then
					if exports['cr_core']:hasMoney(localPlayer, fuelAmount*benzintipus, false) then
						setElementData(fuelElement, "veh >> fuel", getElementData(fuelElement, "veh >> fuel") + fuelAmount)
						setElementData(fuelElement, "veh >> oldfueltype", getElementData(fuelElement, "veh >> fueltype"))
						setElementData(fuelElement, "veh >> fueltype", getElementData(localPlayer, "fuel >> fueltype"))
						if (getElementData(fuelElement, "veh >> fueltype") ~= getElementData(fuelElement, "veh >> oldfueltype")) then
							setElementData(fuelElement, "veh >> maxkm", getElementData(fuelElement, "veh >> odometer")+math.random(1,10))
						end
						triggerServerEvent("fuel >> takeMoney", localPlayer, fuelAmount, localPlayer)
						setElementData(localPlayer, "fuel >> paying", false)
						setElementData(localPlayer, "fuel >> payElement", false)
						start = nil
						fuelElement = nil
						fuelAmount = 0
						exports['cr_infobox']:addBox("success", "Sikeresen kifizetted a tankolásodat!")
						if isElement(renderTarget) then
							delMonitorElements()
						end
						setElementData(localPlayer, "fuel >> fueltype", nil)
					else
						exports['cr_infobox']:addBox("error", "Nincs elég pénzed ("..fuelAmount*benzintipus.." $) a tankolás kifizetéséhez!")
					end
				elseif exports['cr_core']:isInSlot(textPos[1]-26, y+268, 115, 25) then
					setElementData(localPlayer, "fuel >> paying", false)
					setElementData(localPlayer, "fuel >> payElement", false)
					setElementData(localPlayer, "fuel >> fueltype", false)
					start = nil
					fuelElement = nil
					fuelAmount = 0
					exports['cr_infobox']:addBox("success", "Sikeresen visszavontad a tankolásodat!")
				end
			end
		end
	end
)

local font = dxCreateFont("files/Awesome.ttf", 18)
local ticketFont = dxCreateFont("files/fake-receipt.ttf", 9)
addEventHandler("onClientRender", root, function()
	for k,v in ipairs(getElementsByType("player")) do
		if getElementData(v, "fuel >> hasFuelGun") then
			if isElement(getElementData(v, "fuel >> gunElement")) then
				local element = getElementData(v, "fuel >> clickedElement")
				local ex, ey, ez = getElementPosition(element)
				--local hx, hy, hz = getPedBonePosition(v, 25)
				local hx, hy, hz = getElementPosition(getElementData(v, "fuel >> gunElement"))
				dxDrawLine3D(ex, ey, ez, hx, hy, hz, tocolor(0, 0, 0, 255), 1.5)
			end
		end
	end
	if getElementData(localPlayer, "fuel >> hasFuelGun") then
		local element = getElementData(localPlayer, "fuel >> clickedElement")
		local ex, ey, ez = getElementPosition(element)
		local px, py, pz = getElementPosition(localPlayer)
		local distance = getDistanceBetweenPoints3D(ex, ey, ez, px, py, pz)
		if distance > 5 and not getElementData(localPlayer, "fuel >> gunAlone") then
			setElementData(localPlayer, "fuel >> hasFuelGun", false)
			setElementData(element, "fuel >> usedBy", false)
			setElementData(localPlayer, "fuel >> clickedElement", false)
			if getElementData(element, "fuel >> petrolElement") then
			triggerServerEvent("changeFuelGunElement",localPlayer, element, "create")
			triggerEvent("createMessage", localPlayer, localPlayer, "visszaakasztja a benzin pisztolyt a tartóra", 1)
			elseif	getElementData(element, "fuel >> dieselElement") then
			triggerServerEvent("changeFuelGunElement",localPlayer, element, "create")
			triggerEvent("createMessage", localPlayer, localPlayer, "visszaakasztja a dízel pisztolyt a tartóra", 1)
			end
			delMonitorElements()
		end
		if fuelElement and getElementData(localPlayer, "fuel >> fueling") and getElementData(fuelElement, "veh >> fuel") + fuelAmount > exports['cr_vehicle']:getVehicleMaxFuel(getElementModel(fuelElement)) then
			-- fuelAmount = fuelAmount - 1
			setElementData(localPlayer, "fuel >> fueling", false)
			exports['cr_infobox']:addBox("info", "Megtelt a jármű üzemanyag tartálya, most fizesd ki a tankolást!")
		end
		if isElement(renderTarget) then
		dxSetRenderTarget(renderTarget, true)

		dxDrawRectangle(0, 0, 200, 200, tocolor(0, 0, 0))
		dxDrawText(""..orange..fuelAmount..white.." Liter\n"..orange..fuelAmount*benzintipus..white.." $", 400, 160, 0, 0, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)

		dxSetRenderTarget()
	end
	end
	if getElementData(localPlayer, "fuel >> paying") then
		local ex, ey, ez = getElementPosition(getElementData(localPlayer, "fuel >> payElement"))
		local px, py, pz = getElementPosition(localPlayer)
		local distance = getDistanceBetweenPoints3D(ex, ey, ez, px, py, pz)
		if distance > 5 then
			setElementData(localPlayer, "fuel >> paying", false)
			setElementData(localPlayer, "fuel >> payElement", false)
		end
		local now = getTickCount()
		local endTime = start + 1000
		local elapsedTime = now - start
		local duration = endTime - start
		local progress = elapsedTime / duration
		local panelX = (sx/2)-150
		y = sy/2-(423/2)
		y = interpolateBetween(-1000, 0, 0, y, 0, 0, progress, "OutBounce")
		textPos = {panelX+173, y+433} 
		dxDrawImage( panelX, y, 300, 423,"files/fuelreceipt.png", 0, 0, 0, tocolor(255,255,255,255))
		dxDrawText("$   100  L\n$   "..benzintipus.."/L\n$   "..benzintipus*fuelAmount.."", textPos[1], textPos[2], x, y, tocolor(0, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		if exports['cr_core']:isInSlot(textPos[1]-126, y+268, 74, 25) then
			dxDrawText("Kifizetem", textPos[1]-125, textPos[2]+125, x, y, tocolor(112, 164, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
			roundedBorder(textPos[1]-126, y+268, 74, 25, tocolor(151, 253, 0, 220))
		else
			dxDrawText("Kifizetem", textPos[1]-125, textPos[2]+125, x, y, tocolor(0, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
			roundedBorder(textPos[1]-126, y+268, 74, 25, tocolor(0, 0, 0, 220))
		end
		if exports['cr_core']:isInSlot(textPos[1]-26, y+268, 115, 25) then
			roundedBorder(textPos[1]-26, y+268, 115, 25, tocolor(255, 59, 0, 220))
			dxDrawText("Nem fizetem ki", textPos[1]-25, textPos[2]+125, x, y, tocolor(255, 59, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		else
			roundedBorder(textPos[1]-26, y+268, 115, 25, tocolor(0, 0, 0, 220))
			dxDrawText("Nem fizetem ki", textPos[1]-25, textPos[2]+125, x, y, tocolor(0, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		end
	end
end)

addEventHandler("onClientKey", root,
	function(b, s)
		if getElementData(localPlayer, "fuel >> hasFuelGun") then
			if b == "e" and not isChatBoxInputActive() then
				if getElementData(localPlayer, "fuel >> gunAlone") then return end
				if s then
					local element
					for k,v in ipairs(getElementsByType("vehicle", root, true)) do
						local model = getElementModel(v)
						local component
						if componentPositions[model] then
							component = componentPositions[model]
						else
							component = "wheel_lb_dummy"
						end
						local ex, ey, ez = getVehicleComponentPosition(v, component, "world")
						local px, py, pz = getElementPosition(localPlayer)
						if tonumber(ex) and tonumber(ey) and tonumber(ez) then
							if getDistanceBetweenPoints3D(ex, ey, ez, px, py, pz) < 1 then
								element = v
							end
						end
					end
					if not fuelElement then fuelElement = element end
					if element == fuelElement then
						if not fuelElement then return end
						if getElementData(fuelElement, "veh >> fuel") + fuelAmount >= exports['cr_vehicle']:getVehicleMaxFuel(getElementModel(fuelElement)) then exports['cr_infobox']:addBox("error", "A jármű üzemanyag tartálya tele van!") return end
						if getVehicleEngineState(fuelElement) then exports['cr_infobox']:addBox("error", "Először állítsd le a jármű motorját!") return end
						local model = getElementModel(fuelElement)
						local component
						if componentPositions[model] then
							component = componentPositions[model]
						else
							component = "wheel_lb_dummy"
						end
						local ex, ey = getVehicleComponentPosition(fuelElement, component, "world")
						local px, py = getElementPosition(localPlayer)
						local r = findRotation(px, py, ex, ey)
						setPedRotation(localPlayer, r)
						setElementData(localPlayer, "fuel >> fueling", true)
					end
				else
					setTimer(
						function()
							if getElementData(localPlayer, "fuel >> fueling") then
								setElementData(localPlayer, "fuel >> fueling", false)
							end
						end, 500, 1
					)
				end
			end
		end
		if getElementData(localPlayer, "fuel >> paying") then
			if b == "backspace" then
				if s then
					setElementData(localPlayer, "fuel >> paying", false)
					setElementData(localPlayer, "fuel >> payElement", false)
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dName)
		local value = getElementData(source, dName)
		if dName == "fuel >> usedBy" then
			local x, y, z = getElementPosition(source)
			local sound = playSound3D("files/fuelgunmove.wav", x, y, z)
			setSoundMaxDistance(sound, 30)
		elseif dName == "fuel >> fueling" and source == localPlayer then
			if value then
				local sound = playSound("files/fuel.mp3")
				fuelSound = sound
				local timer = setTimer(
					function()
						local sound = playSound("files/fuel.mp3")
						fuelSound = sound
					end, 8000, 0
				)
				fuelTimer = timer
				local timer = setTimer(
					function()
						fuelAmount = fuelAmount + 1
					end, 800, 0
				)
				amountTimer = timer
			else
				if fuelSound then
					stopSound(fuelSound)
				end
				if isTimer(fuelTimer) then
					killTimer(fuelTimer)
				end
				if isTimer(amountTimer) then
					killTimer(amountTimer)
				end
			end
		end
	end
)

addEventHandler("onClientPedDamage", root,
	function()
		if getElementData(source, "fuel >> pedid") then cancelEvent() end
	end
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		local clickedElement = getElementData(localPlayer, "fuel >> clickedElement")
		setElementData(localPlayer, "fuel >> hasFuelGun", false)
		if isElement(clickedElement) then
			setElementData(clickedElement, "fuel >> usedBy", false)
		end
		setElementData(localPlayer, "fuel >> clickedElement", false)
		setElementData(localPlayer, "fuel >> fueling", false)
		setElementData(localPlayer, "fuel >> paying", false)
		setElementData(localPlayer, "fuel >> payElement", false)
		setElementData(localPlayer, "fuel >> gunAlone", false)
	end
)

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getFuelCost()
	triggerServerEvent("fuel >> getFuelCost", localPlayer, localPlayer)
end

function fuelCostReceive(datas)
	benzincost = datas
	setClientCost()
end
addEvent("sendFuelCostDatas", true)
addEventHandler("sendFuelCostDatas", getRootElement(),fuelCostReceive)

function setClientCost()
	local value = getElementData(localPlayer,"fuel >> clickedElement")
	local petrol = getElementData(value,"fuel >> petrolElement")
	local diesel = getElementData(value,"fuel >> dieselElement")
	if value == diesel then
		benzintipus = tonumber(benzincost[2])
	elseif value == petrol then
		benzintipus = tonumber(benzincost[1])
	end
end

function delMonitorElements()
	if isElement(renderTarget) then
		destroyElement(shader)
		destroyElement(renderTarget)
		fuelObject = false
	end
end

function setMonitorElement(state)
	if state then
		delMonitorElements()
		fuelObject = getElementData(getElementData(localPlayer, "fuel >> clickedElement"), "fuel >> fuelElement")
		if state == "monitor2" then
			renderTarget = dxCreateRenderTarget(400, 150)
			if isElement(shader) then
				destroyElement(shader)
			end
			shader = dxCreateShader("FX/texturechanger.fx")
			dxSetShaderValue(shader, "textureFile", renderTarget)
			engineApplyShaderToWorldTexture(shader, "de40a_2", fuelObject)
		elseif state == "monitor" then
			renderTarget = dxCreateRenderTarget(400, 150)
			if isElement(shader) then
				destroyElement(shader)
			end
			shader = dxCreateShader("FX/texturechanger.fx")
			dxSetShaderValue(shader, "textureFile", renderTarget)
			engineApplyShaderToWorldTexture(shader, "de40a_2(1)", fuelObject)
		end
	end
end
addEvent("setMonitorElement", true)
addEventHandler("setMonitorElement", getRootElement(), setMonitorElement)



function roundedBorder(x, y, w, h, borderColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(255, 255, 255, 230)
		end

		dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI); -- right
		dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI); -- bottom

		dxDrawRectangle(x, y, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI);
	end
end