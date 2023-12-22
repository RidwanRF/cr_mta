wasteInFrontOfPlayer = false;

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX-math.sin(math.rad(rotation))*meters
    posY = posY+math.cos(math.rad(rotation))*meters
    rot = rotation+math.cos(math.rad(rotation))
    return posX, posY, posZ, rot
end

local updateTime = getTickCount()+500
function checkWaste() 
	if(isElement(selectedArea)) then
		if(isElementWithinColShape(localPlayer, selectedArea)) then
			if(updateTime < getTickCount()) then
				updateTime = getTickCount()+500
				local pos = localPlayer:getPosition()
				local x, y, z = getPositionInfrontOfElement(localPlayer, 0.5)
				local hit, _, _, _, hitElement = processLineOfSight(pos.x, pos.y-1, pos.z, x, y, z-1, false, false, false, true, false, false, false, false, nil, false, false)
				if(hit) then
					if(getElementJobData(hitElement, "waste")) then
						if(not wasteInFrontOfPlayer) then
							toggleControl("fire", false)
						end
						wasteInFrontOfPlayer = true;
					else
						if(wasteInFrontOfPlayer) then
							toggleControl("fire", true)
						end
						wasteInFrontOfPlayer = false;
					end
				else
					if(wasteInFrontOfPlayer) then
						toggleControl("fire", true)
					end
					wasteInFrontOfPlayer = false;
				end
			end
		end
	end
end

local spamTimer = nil;
function onHitWaste()
	if(isElement(selectedArea)) then
		if(isElementWithinColShape(localPlayer, selectedArea)) then
			if(not isTimer(spamTimer)) then
				if(not isCursorShowing()) then
					if(wasteInFrontOfPlayer) then
						spamTimer = setTimer(function() end, 2000, 1)
					end
				end
			end
		end
	end
end