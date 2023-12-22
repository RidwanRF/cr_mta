local font = exports['cr_fonts']:getFont("Roboto", 11)
local oranger, orangeg, orangeb = exports['cr_core']:getServerColor("orange", false)
addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_fonts" then
			font = exports['cr_fonts']:getFont("Roboto", 11)
		elseif sResourceName == "cr_core" then
			orange = exports['cr_core']:getServerColor("orange", true)
			oranger, orangeg, orangeb = exports['cr_core']:getServerColor("orange", false)
		end
	end
)
local screenW, screenH = guiGetScreenSize()
local cache = {}
local idgelements = {}
local imagePath = "assets/image/"
local refreshDatas = {
	["interior >> id"] = true,
	["interior >> enterMarker"] = true,
	["interior >> position"] = true,
}
local lockSoundPaths = {
	[1] = {"assets/sound/locktype1.mp3", 5, 1},
	[2] = {"assets/sound/locktype2.wav", 10, 1},
	[3] = {"assets/sound/locktype3.mp3", 5, 1},
	[4] = {"assets/sound/locktype4.wav", 3, 1},
}

--[[
{149, 244, 65, 100, "Ház"},
{65, 190, 244, 100, "Garázs"},
{244, 184, 65, 100, "Bolt"},
{244, 229, 65, 100, "Önkormányzati tulajdon"},]]

local types = {
    [1] = {255, 166, 77},
    [2] = {51,152,255},
    [3] = {255, 255, 102},
    [4] = {255,255,255},
    [5] = {255,51,51},
}

addEvent("onClientInteriorLoad", true)
local function interior_callDatas(element)
	if not isElement(element) or getElementType(element) ~= "marker" then return end
	if getElementData(element, "interior >> id") then
		local type = getElementData(element, "interior >> type")
		local image = imagePath .. "type" .. tostring(type) .. ".png"
		local int, dim = getElementInterior(element), getElementDimension(element)
		local x, y, z = getElementPosition(element)
		local r, g, b = unpack(globalTypeTable[type])
        if not idgelements[element] then
            local obj = createObject(1823, getElementPosition(element))
            setElementAlpha(obj, 0)
            setObjectScale(obj, 0.01)
            setElementCollisionsEnabled(obj, false)
            idgelements[element] = obj
        end
        --local r,g,b = unpack(types[type])
		cache[element] = {
			--["image"] = imagePat,
			["int"] = int,
			["dim"] = dim,
			--["position"] = {x, y, z + 0.5},
			["color"] = type
		}
	elseif getElementData(element, "interior >> enterMarker") then
		local image = imagePath .. "exit.png"
        --local type = getElementData(element, "interior >> type")
		local int, dim = getElementInterior(element), getElementDimension(element)
		local x, y, z = getElementPosition(element)
        if not idgelements[element] then
            local obj = createObject(1823, getElementPosition(element))
            setElementAlpha(obj, 0)
            setObjectScale(obj, 0.01)
            setElementCollisionsEnabled(obj, false)
            idgelements[element] = obj
        end
        local r, g, b = 255, 51, 51
		cache[element] = {
			--["image"] = image,
			["int"] = int,
			["dim"] = dim,
			--["position"] = {x, y, z + 0.5},
			["color"] = 5
		}
	end
end

local function interior_handlePanelRender()
	local now = getTickCount()
	local elapsedTime = now - hitStart
	local duration = hitEnd - hitStart
	local progress = elapsedTime / duration
	local boxY = interpolateBetween(-screenH - 175, 0, 0, screenH - 200, 0, 0, progress, "OutBack")
	local textW = dxGetTextWidth(hitText, 1, font, true)
	local boxX, boxW, boxH = screenW / 2 - textW / 2 - 10, textW + 20, 150
	exports['cr_core']:roundedRectangle(boxX, boxY, boxW, boxH, tocolor(0, 0, 0, 180), tocolor(0, 0, 0, 220))
	dxDrawText(hitText, boxX + boxW / 2, boxY + boxH / 2, boxX + boxW / 2, boxY + boxH / 2, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true, false)
	local text = "Belépéshez használd a(z) " .. orange .. "'E'" .. "#FFFFFF" .. " billentyűt"
	local textW = dxGetTextWidth(text, 1, font, true)
	local boxX, boxY, boxW, boxH = screenW / 2 - textW / 2 - 10, boxY - 40, textW + 20, 30
	exports['cr_core']:roundedRectangle(boxX, boxY, boxW, boxH, tocolor(0, 0, 0, 180), tocolor(0, 0, 0, 220))
	dxDrawText(text, boxX + boxW / 2, boxY + boxH / 2, boxX + boxW / 2, boxY + boxH / 2, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true, false)
	if interiorType == 1 then
		buttonX, buttonY, buttonW, buttonH = screenW / 2 - 60, boxY - 50, 120, 40
		exports['cr_core']:roundedRectangle(buttonX, buttonY, buttonW, buttonH, tocolor(0, 0, 0, 180), tocolor(0, 0, 0, 220))
		local color = tocolor(255, 255, 255, 220)
		if exports['cr_core']:isInSlot(buttonX + 10, buttonY + 5, 30, 30) then
			color = tocolor(oranger, orangeg, orangeb, 220)
		end
		dxDrawImage(buttonX + 10, buttonY + 5, 30, 30, "assets/image/ring.png", 0, 0, 0, color, true)
		local color = tocolor(255, 255, 255, 220)
		if exports['cr_core']:isInSlot(buttonX + 80, buttonY + 5, 30, 30) then
			color = tocolor(oranger, orangeg, orangeb, 220)
		end
		dxDrawImage(buttonX + 80, buttonY + 5, 30, 30, "assets/image/knock.png", 0, 0, 0, color, true)
	end
end

local function interior_callHitDatas()
	if hitElement then
		local extraText = ""
		local interiorName = getElementData(hitElement, "interior >> name")
		interiorType = getElementData(hitElement, "interior >> type")
		local interiorTypeName = globalTypeTable[interiorType][5] or "Ismeretlen"
		local interiorLock = getElementData(hitElement, "interior >> lock")
		if interiorLock then
			interiorLock = "Zárva"
		else
			interiorLock = "Nyitva"
		end
		local forSale = getElementData(hitElement, "interior >> owner")
		local interiorType = getElementData(hitElement, "interior >> type")
		if forSale == 0 and interiorType ~= 3 and interiorType ~= 4 then
			forSale = "Igen"
			local interiorCost = getElementData(hitElement, "interior >> cost")
			extraText = "\nÁr: " .. orange .. interiorCost .. " $"
		else
			forSale = "Nem"
		end
		hitText = "Cím: " .. orange .. interiorName .. "#FFFFFF" .. "\nTípus: " .. orange .. interiorTypeName .. "#FFFFFF" .. "\nZár állapota: " .. orange .. interiorLock .. "#FFFFFF" .. "\nMegvásárolható: " .. orange .. forSale .. "#FFFFFF"  .. extraText
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in ipairs(getElementsByType("marker")) do
			if isElementStreamedIn(value) then
				interior_callDatas(value)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		interior_callDatas(source)
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		cache[source] = nil
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dName)
		if refreshDatas[dName] and cache[source] then
			interior_callDatas(source)
			return
		end
		local interiorType = getElementData(source, "interior >> type")
		if dName == "interior >> lock" and getElementData(source, "interior >> id") or getElementData(source, "interior >> enterMarker") then
			local x1, y1, z1, x2, y2, z2, dim1, dim2
			if not interiorType then
				local parentMarker = getElementData(source, "interior >> enterMarker")
				interiorType = getElementData(parentMarker, "interior >> type")
				x1, y1, z1 = getElementPosition(parentMarker)
				dim1 = getElementDimension(parentMarker)
				x2, y2, z2 = getElementPosition(source)
				dim2 = getElementDimension(source)
			else
				local childMarker = getElementData(source, "interior >> exitMarker")
				x1, y1, z1 = getElementPosition(source)
				dim1 = getElementDimension(source)
				x2, y2, z2 = getElementPosition(childMarker)
				dim2 = getElementDimension(childMarker)
			end
			if interiorType then
				local soundPath, soundDistance, soundVolume = unpack(lockSoundPaths[interiorType])
				local sound = playSound3D(soundPath, x1, y1, z1)
				setElementDimension(sound, dim1)
				setSoundMaxDistance(sound, soundDistance)
				setSoundVolume(sound, soundVolume)
				local sound = playSound3D(soundPath, x2, y2, z2)
				setElementDimension(sound, dim2)
				setSoundMaxDistance(sound, soundDistance)
				setSoundVolume(sound, soundVolume)
			end
			return
		end
		if dName == "interior >> notTemp" then
			local value = getElementData(source, dName)
			if value then
				local notType, x1, y1, z1, x2, y2, z2, dim1, dim2 = unpack(value)
				local soundPath = "assets/sound/knock.wav"
				if notType == "ring" then
					soundPath = "assets/sound/ring.wav"
				end
				local soundDistance = 10
				local soundVolume = 1
				local sound = playSound3D(soundPath, x1, y1, z1)
				setElementDimension(sound, dim1)
				setSoundMaxDistance(sound, soundDistance)
				setSoundVolume(sound, soundVolume)
				local sound = playSound3D(soundPath, x2, y2, z2)
				setElementDimension(sound, dim2)
				setSoundMaxDistance(sound, soundDistance)
				setSoundVolume(sound, soundVolume)
			end
		end
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		cache[source] = nil
		if hitElement == source then
			if getElementData(hitElement, "interior >> id") then
				hitElement = nil
				removeEventHandler("onClientRender", root, interior_handlePanelRender)
				hitText = nil
				hitStart = nil
				HitEnd = nil
			elseif getElementData(hitElement, "interior >> enterMarker") then
				hitElement = nil
			end
		end
	end
)

addEventHandler("onClientMarkerHit", root,
	function(player, mD)
		if player == localPlayer and mD then
            local pos = source:getPosition()
			local ppos = localPlayer:getPosition()
			if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 2) then
                if getElementData(source, "interior >> id") then
                    hitElement = source
                    interior_callHitDatas()
                    hitStart = getTickCount()
                    hitEnd = hitStart + 1000
                    removeEventHandler("onClientRender", root, interior_handlePanelRender)
                    addEventHandler("onClientRender", root, interior_handlePanelRender, true, "low-5")
                elseif getElementData(source, "interior >> enterMarker") then
                    hitElement = source
                end
            end
		end
	end
)

addEventHandler("onClientMarkerLeave", root,
	function(player, mD)
		if player == localPlayer and source == hitElement then
			if getElementData(source, "interior >> id") then
				hitElement = nil
				removeEventHandler("onClientRender", root, interior_handlePanelRender)
				hitText = nil
				hitStart = nil
				HitEnd = nil
			elseif getElementData(source, "interior >> enterMarker") then
				hitElement = nil
			end
		end
	end
)

addEventHandler("onClientMinimize", root,
	function()
		if hitElement then
			if getElementData(hitElement, "interior >> id") then
				hitElement = nil
				removeEventHandler("onClientRender", root, interior_handlePanelRender)
				hitText = nil
				hitStart = nil
				HitEnd = nil
			elseif getElementData(hitElement, "interior >> enterMarker") then
				hitElement = nil
			end
		end
	end
)

addEventHandler("onClientClick", root,
	function(b, s)
		if not keyBlock and b == "left" and s == "down" then
			if hitElement and interiorType and interiorType == 1 then
				if exports['cr_core']:isInSlot(buttonX + 10, buttonY + 5, 30, 30) then
					keyBlock = true
					triggerServerEvent("interior >> sendNot", localPlayer, "ring", hitElement)
					setTimer(
						function()
							keyBlock = nil
						end, 1000, 1
					)
				elseif exports['cr_core']:isInSlot(buttonX + 80, buttonY + 5, 30, 30) then
					keyBlock = true
					triggerServerEvent("interior >> sendNot", localPlayer, "knock", hitElement)
					setTimer(
						function()
							keyBlock = nil
						end, 1000, 1
					)
				end
			end
		end
	end
)

addEventHandler("onClientKey", root,
	function(b, s)
		if not keyBlock and s then
			if b == "e" then
				if hitElement then
					cancelEvent()
					keyBlock = true
					triggerServerEvent("interior >> enter", localPlayer, hitElement)
					setTimer(
						function()
							keyBlock = nil
						end, 1000, 1
					)
				end
			elseif b == "k" then
				if hitElement then
					cancelEvent()
					keyBlock = true
					triggerServerEvent("interior >> lock", localPlayer, hitElement)
					setTimer(
						function()
							keyBlock = nil
						end, 1000, 1
					)
				end
			end
		end
	end
)

addEvent("interior >> enterResult", true)
addEventHandler("interior >> enterResult", root,
	function()
		if hitElement then
			if getElementData(hitElement, "interior >> id") then
				hitElement = nil
				removeEventHandler("onClientRender", root, interior_handlePanelRender)
				hitText = nil
				hitStart = nil
				HitEnd = nil
			elseif getElementData(hitElement, "interior >> enterMarker") then
				hitElement = nil
			end
		end
	end
)

addEvent("interior >> lockResult", true)
addEventHandler("interior >> lockResult", root,
	function()
		if hitElement and getElementData(hitElement, "interior >> id") then
			interior_callHitDatas()
		end
	end
)

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

local material = dxCreateTexture("assets/image/image.png")

function drawnOctagon()
    for gMarker, v in pairs(renderCache) do 
        local x,y,z = getElementPosition(gMarker)
        cx, cy, cz = x,y,z + 3
        ----outputChatBox("asd")
        ----outputChatBox(x)
        local r,g,b = v[1], v[2], v[3]
        if r == 51 and g == 255 and b == 51 then
            z = z + 0.05
        end
        local now = getTickCount()
        local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve")
        dxDrawOctagon3D(x,y,z, 0.8, 3, tocolor(r,g,b,alpha))
        z = z + multipler
        dxDrawImage3D(x, y, z+2, 1, 1, material,tocolor(r,g,b,alpha))
    end
end

setTimer(
    function()
        renderCache = {}
        last = nil
        for element, value in pairs(cache) do
            if isElement(element) and isElementStreamedIn(element) then
                local int, dim = value["int"], value["dim"]
                local localInt, localDim = getElementInterior(localPlayer), getElementDimension(localPlayer)
                if int == localInt and dim == localDim then
                    --local elementX, elementY, elementZ = unpack(value["position"])
                    --local cameraX, cameraY, cameraZ = getCameraMatrix()
                    local maxDistance = 60
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
                    if distance <= maxDistance then
                        local r,g,b = unpack(types[value["color"]])
                        local interiorOwner = getElementData(element, "interior >> owner")
					    if not interiorOwner or interiorOwner == 0 then
                            if value["color"] <= 3 then
                                r,g,b = 51,255,51
                            end
                        end
                            
                        renderCache[element] = {r,g,b}
                        last = element

                        if not state then
                            state = true
                            addEventHandler("onClientRender", root, drawnOctagon, true, "low-5")
                        end
                    end
                end
            end
        end
        
        if not last and state then
            state = false
            removeEventHandler("onClientRender", root, drawnOctagon)
        end
    end, 300, 0
)
-- #optimizált


function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end
