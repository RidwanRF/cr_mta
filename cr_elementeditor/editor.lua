-- By Jayceon

local screenX, screenY = guiGetScreenSize()
local editorFont = dxCreateFont("files/Roboto.ttf", 8, false, "antialiased")
local editorTable = nil

local editorMenu = {
	{"move", "Mozgatás"},
	{"rotate", "Forgatás"},
	-- {"scale", "Méret"},
	{"reset", "Reset"},
	{"save", "Mentés"},
	{"delete", "Törlés"},
}

local iconSize = 16
local iconHalfSize = iconSize / 2

local axisLineThickness = 1.5

local editorColors = {
	axisX = {82, 136, 216},
	axisY = {255, 100, 100},
	axisZ = {88, 226, 90},
	
	activeMode = {255, 150, 0},
	inactiveMode = {255, 150, 0, 100}
}

--[[local editedObject
bindKey("F4", "down", function()
	if not isElement(editedObject) then
		local x, y, z = getElementPosition(localPlayer)
		editedObject = createObject(1663, x, y, z)
			
		setElementCollisionsEnabled(editedObject, false)
		toggleEditor(editedObject, "saveObject")
	end
end)

addEvent("saveObject", true)
addEventHandler("saveObject", root, function(obj)
	if obj == editedObject then
		destroyElement(editedObject)
		outputChatBox("save")
	end
end)]]

addEventHandler("onClientRender", getRootElement(),
	function ()
		if not editorTable then
			return
		end
		
		local absX, absY = 0, 0
			
		if isCursorShowing() then
			if not isMTAWindowActive() then
				local relX, relY = getCursorPosition()
				
				absX, absY = relX * screenX, relY * screenY
			end
		end
		
		local elementX, elementY, elementZ = getElementPosition(editorTable["element"])
		
		local startX, startY = getScreenFromWorldPosition(elementX, elementY, elementZ, 128)
		
		local xX, xY, xZ = getPositionFromElementOffset(editorTable["element"], editorTable["elementRadius"], 0, 0)
		local yX, yY, yZ = getPositionFromElementOffset(editorTable["element"], 0, editorTable["elementRadius"], 0)
		local zX, zY, zZ = getPositionFromElementOffset(editorTable["element"], 0, 0, editorTable["elementRadius"])
		
		endXX, endXY = getScreenFromWorldPosition(xX, xY, xZ, 128)
		endYX, endYY = getScreenFromWorldPosition(yX, yY, yZ, 128)
		endZX, endZY = getScreenFromWorldPosition(zX, zY, zZ, 128)
		
		if not endXX or not endYX or not endZX or not endXY or not endYY or not endZY then
			return
		end
		
		dxDrawLine(startX, startY, endXX, endXY, tocolor(editorColors["axisX"][1], editorColors["axisX"][2], editorColors["axisX"][3], 255), axisLineThickness, false)
		dxDrawLine(startX, startY, endYX, endYY, tocolor(editorColors["axisY"][1], editorColors["axisY"][2], editorColors["axisY"][3], 255), axisLineThickness, false)
		dxDrawLine(startX, startY, endZX, endZY, tocolor(editorColors["axisZ"][1], editorColors["axisZ"][2], editorColors["axisZ"][3], 255), axisLineThickness, false)
		
		dxDrawRectangle(endXX - iconHalfSize, endXY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisX"][1], editorColors["axisX"][2], editorColors["axisX"][3], 255))
		dxDrawRectangle(endYX - iconHalfSize, endYY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisY"][1], editorColors["axisY"][2], editorColors["axisY"][3], 255))
		dxDrawRectangle(endZX - iconHalfSize, endZY - iconHalfSize, iconSize, iconSize, tocolor(editorColors["axisZ"][1], editorColors["axisZ"][2], editorColors["axisZ"][3], 255))
		
		dxDrawImage(endXX - iconHalfSize, endXY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		dxDrawImage(endYX - iconHalfSize, endYY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		dxDrawImage(endZX - iconHalfSize, endZY - iconHalfSize, iconSize, iconSize, "files/" .. editorTable["currentMode"] .. ".png")
		
		if editorTable["hoveredMenuIcon"] then
			editorTable["hoveredMenuIcon"] = false
		end
		
		if not editorTable["activeAxis"] then
			for i = 1, #editorMenu do
				local currentColor = editorColors["inactiveMode"]
				
				if editorMenu[i][1] == "save" then
					if editorTable["currentMode"] == editorMenu[i][1] then
						currentColor = {66, 244, 72}
					else
						currentColor = {66, 244, 72, 100}
					end
				elseif editorMenu[i][1] == "reset" then
					if editorTable["currentMode"] == editorMenu[i][1] then
						currentColor = {200, 0, 0}
					else
						currentColor = {200, 0, 0, 100}
					end
				elseif editorMenu[i][1] == "delete" then
					currentColor = {243, 85, 85, 100}
				elseif editorTable["currentMode"] == editorMenu[i][1] then
					currentColor = editorColors["activeMode"]
				end
				
				local iconX = ((startX - iconHalfSize) + ((i - 1) * (iconSize + 5))) + 32
				local iconY = (startY - iconHalfSize) + 32
				
				dxDrawRectangle(iconX, iconY, iconSize, iconSize, tocolor(currentColor[1], currentColor[2], currentColor[3], currentColor[4] or 255))
				dxDrawImage(iconX, iconY, iconSize, iconSize, "files/" .. editorMenu[i][1] .. ".png")
				
				if absX >= iconX and absX <= iconX + iconSize and absY >= iconY and absY <= iconY + iconSize then
					editorTable["hoveredMenuIcon"] = i
				end
			end
		end
		
		if editorTable["hoveredMenuIcon"] then
			local tooltipWidth = dxGetTextWidth(editorMenu[editorTable["hoveredMenuIcon"]][2], 1.0, editorFont) + 10
			local tooltipHeight = dxGetFontHeight(1.0, editorFont) + 10
				
			dxDrawRectangle(absX + 10, absY, tooltipWidth, tooltipHeight, tocolor(0, 0, 0, 200))
			dxDrawText(editorMenu[editorTable["hoveredMenuIcon"]][2], absX + 10, absY, absX + 10 + tooltipWidth, absY + tooltipHeight, tocolor(255, 255, 255, 255), 1.0, editorFont, "center", "center")
		
			if getKeyState("mouse1") then
				local hoveredMenuIcon = editorMenu[editorTable["hoveredMenuIcon"]][1]
			
				if editorTable["currentMode"] ~= hoveredMenuIcon then
					if hoveredMenuIcon == "reset" then
						resetEditorElementChanges()
					elseif hoveredMenuIcon == "save" then
						saveEditorElementChanges()
					elseif hoveredMenuIcon == "delete" then
						quitEditor()
					else
						editorTable["currentMode"] = hoveredMenuIcon
					end
				end
			end
		end
		
		if editorTable and editorTable["hoveredMode"] then
			editorTable["hoveredMode"] = false
		end
		
		if absX >= endXX - iconHalfSize and absX <= endXX - iconHalfSize + iconSize and absY >= endXY - iconHalfSize and absY <= endXY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "X"
		elseif absX >= endYX - iconHalfSize and absX <= endYX - iconHalfSize + iconSize and absY >= endYY - iconHalfSize and absY <= endYY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "Y"
		elseif absX >= endZX - iconHalfSize and absX <= endZX - iconHalfSize + iconSize and absY >= endZY - iconHalfSize and absY <= endZY - iconHalfSize + iconSize then
			editorTable["hoveredMode"] = "Z"
		end
		
		-- OBJECT MOVE BY AXLES/CURSOR
		if editorTable and editorTable["activeAxis"] then
			if isCursorShowing() and getKeyState("mouse1") then
				local relX, relY = getCursorPosition()
				local cameraRotation = getCameraRotation()

				local elementX, elementY, elementZ = 0, 0, 0
				local elementRX, elementRY, elementRZ = 0, 0, 0
				local elementSX, elementSY, elementSZ = 0, 0, 0
				
				if isElementAttached(editorTable["element"]) then
					elementX, elementY, elementZ, elementRX, elementRY, elementRZ = getElementAttachedOffsets(editorTable["element"])
					
					local attachedElementRX, attachedElementRY, attachedElementRZ = getElementRotation(getElementAttachedTo(editorTable["element"]))
					
					cameraRotation = cameraRotation + attachedElementRZ
				else
					elementX, elementY, elementZ = getElementPosition(editorTable["element"])
					elementRX, elementRY, elementRZ = getElementRotation(editorTable["element"])
				end
				
				if getElementType(editorTable["element"]) == "object" then
					elementSX, elementSY, elementSZ = getObjectScale(editorTable["element"])
				end
				
				if editorTable["currentMode"] == "move" then
					if editorTable["activeAxis"] == "X" then
						elementX = getInFrontOf(elementX, false, -(cameraRotation + 90), ((relX - 0.5) * 5))
					elseif editorTable["activeAxis"] == "Y" then
						elementY = getInFrontOf(false, elementY, -cameraRotation, -((relY - 0.5) * 5))
					elseif editorTable["activeAxis"] == "Z" then
						elementZ = elementZ - ((relY - 0.5) * 5)
					end
				elseif editorTable["currentMode"] == "rotate" then
					if editorTable["activeAxis"] == "X" then
						elementRX = getInFrontOf(elementRX, false, -(cameraRotation + 90), ((relY - 0.5) * 100))
					elseif editorTable["activeAxis"] == "Y" then
						elementRY = getInFrontOf(false, elementRY, -cameraRotation, ((relX - 0.5) * 100))
					elseif editorTable["activeAxis"] == "Z" then
						elementRZ = getInFrontOf(elementRZ, false, -(cameraRotation + 90), -((relX - 0.5) * 100))
					end
				elseif editorTable["currentMode"] == "scale" then
					if editorTable["activeAxis"] == "X" then
						elementSX = getInFrontOf(elementSX, false, -(cameraRotation + 90), ((relX - 0.5) * 5))
					elseif editorTable["activeAxis"] == "Y" then
						elementSY = getInFrontOf(false, elementSY, -cameraRotation, ((relY - 0.5) * 5))
					elseif editorTable["activeAxis"] == "Z" then
						elementSZ = elementSZ - ((relY - 0.5) * 5)
					end
				end
				
				if isElementAttached(editorTable["element"]) then
					setElementAttachedOffsets(editorTable["element"], elementX, elementY, elementZ, elementRX, elementRY, elementRZ)
				else
					setElementPosition(editorTable["element"], elementX, elementY, elementZ)
					setElementRotation(editorTable["element"], elementRX, elementRY, elementRZ)
				end
				
				if getElementType(editorTable["element"]) == "object" then
					elementSX = math.max(0.25, math.min(3.0, elementSX))
					elementSY = math.max(0.25, math.min(3.0, elementSY))
					elementSZ = math.max(0.25, math.min(3.0, elementSZ))
					
					setObjectScale(editorTable["element"], elementSX, elementSY, elementSZ)
				end
				
				setCursorPosition(screenX / 2, screenY / 2)
				setCursorAlpha(0)
			else
				if editorTable["activeAxis"] then
					editorTable["activeAxis"] = false
					setCursorAlpha(255)
				end
			end
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY)
		if not editorTable then
			return
		end
		
		if button == "left" then
			if state == "down" then
				if editorTable["hoveredMode"] then
					setCursorPosition(screenX / 2, screenY / 2)
					setCursorAlpha(0)
					
					editorTable["activeAxis"] = editorTable["hoveredMode"]
				end
			elseif state == "up" then
				local oldActiveAxis = editorTable["activeAxis"]
				
				if oldActiveAxis then
					editorTable["activeAxis"] = false
					
					if oldActiveAxis == "X" then
						setCursorPosition(endXX, endXY)
					elseif oldActiveAxis == "Y" then
						setCursorPosition(endYX, endYY)
					elseif oldActiveAxis == "Z" then
						setCursorPosition(endZX, endZY)
					end
					
					setCursorAlpha(255)
				end
			end
		end
	end
)

function toggleEditor(element, saveFunction, removeFunction, ...)
	if element then
		local x, y, z = getElementPosition(element)
		local rx, ry, rz = getElementRotation(element)
		local scale = getObjectScale(element)
		local radius = getElementRadius(element) * 1.25
		if radius >= 2 then
			radius = 2
		end
		editorTable = {
			element = element,
			elementRadius = radius,
			
			defaultX = x,
			defaultY = y,
			defaultZ = z,
			defaultRX = rx,
			defaultRY = ry,
			defaultRZ = rz,
			defaultScale = scale,
			
			saveFunction = saveFunction,
			removeFunction = removeFunction,
			others = {...},

			currentMode = "move",
			hoveredMode = false,
			hoveredMenuIcon = false,
			activeAxis = false,
		}
	else
		editorTable = nil
		setCursorAlpha(255)
	end
end

function resetEditorElementChanges(quit)
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
	
	setElementPosition(editorTable["element"], editorTable.defaultX, editorTable.defaultY, editorTable.defaultZ)
	setElementRotation(editorTable["element"], editorTable.defaultRX, editorTable.defaultRY, editorTable.defaultRZ)
	setObjectScale(editorTable["element"], editorTable.defaultScale)
	
	if quit then
		toggleEditor(false)
	end
end

function saveEditorElementChanges()
    outputChatBox("asd")
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
	
	if editorTable["saveFunction"] then
		if isElementAttached(editorTable["element"]) then
			local x, y, z, rx, ry, rz = getElementAttachedOffsets(editorTable["element"])
			
            --outputChatBox(editorTable["saveFunction"])
			triggerEvent(editorTable["saveFunction"], localPlayer, editorTable["element"], x, y, z, rx, ry, rz, getObjectScale(editorTable["element"]), unpack(editorTable["others"]))
		else
			local x, y, z = getElementPosition(editorTable["element"])
			local rx, ry, rz = getElementRotation(editorTable["element"])
            
--            outputChatBox(editorTable["saveFunction"])
			triggerEvent(editorTable["saveFunction"], localPlayer, editorTable["element"], x, y, z, rx, ry, rz, getObjectScale(editorTable["element"]), unpack(editorTable["others"]))
			outputChatBox( "triggered save event->"..editorTable["saveFunction"] ) 
		end
	end
	
	toggleEditor(false)
end

function quitEditor()
	if not editorTable then
		return
	end
	
	if not editorTable["element"] or not isElement(editorTable["element"]) then
		return
	end
	
	if editorTable["removeFunction"] then
		triggerEvent(editorTable["removeFunction"], localPlayer, editorTable["element"])
	end
	
	toggleEditor(false)
end

function getPositionFromElementOffset(element, offsetX, offsetY, offsetZ)
	local elementMatrix = getElementMatrix(element, false)
	
    local elementX = offsetX * elementMatrix[1][1] + offsetY * elementMatrix[2][1] + offsetZ * elementMatrix[3][1] + elementMatrix[4][1]
    local elementY = offsetX * elementMatrix[1][2] + offsetY * elementMatrix[2][2] + offsetZ * elementMatrix[3][2] + elementMatrix[4][2]
    local elementZ = offsetX * elementMatrix[1][3] + offsetY * elementMatrix[2][3] + offsetZ * elementMatrix[3][3] + elementMatrix[4][3]
	
    return elementX, elementY, elementZ
end

function getInFrontOf(x, y, angle, distance)
	distance = distance or 1
	
	if x and not y then
		return x + distance * math.sin(math.rad(-angle))
	elseif not x and y then
		return y + distance * math.cos(math.rad(-angle))
	elseif x and y then
		return x + distance * math.sin(math.rad(-angle)), y + distance * math.cos(math.rad(-angle))
	end
end

function getCameraRotation()
	local cx, cy, _, tx, ty = getCameraMatrix()
	
	return math.deg(math.atan2(tx - cx, ty - cy))
end
