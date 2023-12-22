local screenW, screenH = guiGetScreenSize()
local cache = {}
local image = "assets/image/elevator.png"

local function elevator_callDatas(element)
	if not isElement(element) or not getElementType(element) == "marker" then return end
	if getElementData(element, "elevator >> id") then
		local x, y, z = getElementPosition(element)
		local int, dim = getElementInterior(element), getElementDimension(element)
		cache[element] = {
			["position"] = {x, y, z + 0.5},
			["int"] = int,
			["dim"] = dim,
		}
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in pairs(getElementsByType("marker", _, true)) do
			if isElementStreamedIn(value) then
				elevator_callDatas(value)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		elevator_callDatas(source)
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		cache[source] = nil
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		cache[source] = nil
	end
)

local showTimer = nil
addEventHandler("onClientMarkerHit", root,
	function(player, mD)
		if player == localPlayer and mD and getElementData(source, "elevator >> id") then
			local pos = source:getPosition()
			local ppos = localPlayer:getPosition()
			if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, ppos.x, ppos.y, ppos.z) <= 2) then
				hitElement = source
				if(not isTimer(showTimer)) then
					exports['cr_infobox']:addBox("info", "A lift alkalmazásához használd az 'E' gombot!")
					showTimer = setTimer(function() end, 20000, 1)
				end
			end
		end
	end
)

addEventHandler("onClientMarkerLeave", root,
	function(player, mD)
		if player == localPlayer and source == hitElement then
			hitElement = nil
		end
	end
)

addEventHandler("onClientMinimize", root,
	function()
		if hitElement then
			hitElement = nil
		end
	end
)

local cooldown = nil
addEventHandler("onClientKey", root,
	function(b, s)
		if not keyBlock and s and b == "e" and hitElement then
			if(not isTimer(cooldown)) then
				cancelEvent()
				keyBlock = true
				triggerServerEvent("elevator >> enter", localPlayer, hitElement)
				setTimer(
					function()
						keyBlock = nil
					end, 1000, 1
				)
				cooldown = setTimer(function() end, 2000, 1)
			end
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

local material = dxCreateTexture("assets/image/elevator.png")

function drawnOctagon()
    for gMarker, v in pairs(renderCache) do 
        local x,y,z = getElementPosition(gMarker)
        cx, cy, cz = x,y,z + 3
        ----outputChatBox("asd")
        ----outputChatBox(x)
        --z = z + 0.399
        local now = getTickCount()
        local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve")
        dxDrawOctagon3D(x,y,z, 0.8, 3, tocolor(255,51,51,alpha))
        z = z + multipler
        dxDrawImage3D(x, y, z+2, 1, 1, material,tocolor(255,51,51,alpha))
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
                        renderCache[element] = 1 - (distance / 50)
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

addEvent("ghostMode", true)
addEventHandler("ghostMode", root,
    function(element, state)
        if not isElement(element) then return end
        if not state then return end
        if state == "on" then
            --outputChatBox("ye")
            if element.type == "vehicle" then
                --outputChatBox("ye2")
                if localPlayer.vehicle and localPlayer.vehicle == element then
                    --outputChatBox("ye3")
                    oControlState = isControlEnabled("enter_exit")
                    getBackControl = true
                    toggleControl("enter_exit", false)
                end
            end
            for k,v in pairs(getElementsByType(element.type)) do
                setElementCollidableWith(element, v, false)
            end
            if element.type ~= "player" then
                for k,v in pairs(getElementsByType("player")) do
                    setElementCollidableWith(element, v, false)
                end
            end
            setElementCollidableWith(element, localPlayer, false)
            element.alpha = 150
            element:setData("ghostMode", true)
        elseif state == "off" then
            if getBackControl then 
                toggleControl("enter_exit", oControlState)
                getBackControl = false
                oControlState = nil
            end
            for k,v in pairs(getElementsByType(element.type)) do
                if not v:getData("ghostMode") then
                    setElementCollidableWith(element, v, true)
                end
            end
            if element.type ~= "player" then
                for k,v in pairs(getElementsByType("player")) do
                    if not v:getData("ghostMode") then
                        setElementCollidableWith(element, v, true)
                    end
                end
            end
            setElementCollidableWith(element, localPlayer, true)
            element.alpha = 255
            element:setData("ghostMode", false)
        end
    end
)