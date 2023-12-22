local rockData = false;
local cache = {}
local displayCache = {}
rockDisplay = {}
local extraDMG = 0;

local ImageMaterials = {
	dxCreateTexture("images/1.png","dxt5", true, "wrap"),
	dxCreateTexture("images/2.png","dxt5", true, "wrap"),
	dxCreateTexture("images/3.png","dxt5", true, "wrap"),
	dxCreateTexture("images/4.png","dxt5", true, "wrap"),
}

addEventHandler("onClientResourceStart", root, function() 
    if(localPlayer:getData("char >> job") == 1) then
        for i, v in pairs(getElementsByType("object")) do
            if(getElementJobData(v, "rockObjective")) then
                cache[getElementJobData(v, "rockID")] = {v, getElementJobData(v, "rockType")}     
            end
        end
    end	
end)

addEventHandler("onClientElementStreamIn", getRootElement(), function() 
    if(localPlayer:getData("char >> job") == 1) then
        if(getElementJobData(source, "rockObjective")) then
            cache[getElementJobData(source, "rockID")] = {source, getElementJobData(source, "rockType")}     
        end
    end
end)

addEventHandler("onClientElementStreamOut", getRootElement(), function() 
    if(getElementJobData(source, "rockObjective")) then
        cache[getElementJobData(source, "rockID")] = nil
    end
end)

setTimer(
    function()
        displayCache = {}
        for k,v in pairs(cache) do
            local element = v[1]
            --outputChatBox(tostring(isElementOnScreen(element)))
            if isElementOnScreen(element) then
                local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
                --outputChatBox(distance)
                if distance <= 20 then
                    --outputChatBox(distance)
                    --local line = isLineOfSightClear(localPlayer.position, element.position, true, false, false, true, false, false, false, element)
                    --if line then
                        displayCache[k] = v
                        displayCache[k]["distance"] = distance
                    --end
                end
            end
        end
    end, 50, 0
)

addEventHandler("onClientRender", root, 
    function()
        for i, v in pairs(displayCache) do
            local distance = v["distance"]
            if distance < 20 then 
			--local size = 1 - (distance / 10)
				local x,y,z = getElementPosition(v[1])
            --local screenX, screenY = getScreenFromWorldPosition(x, y, z + 2)
           -- if screenX and screenY then
               -- local a = 100
                --dxDrawImage(screenX - ((a*size)/2), screenY - ((a*size)/2), a * size, a * size, ImageMaterials[v[2]])
					
				dxDrawImage3D(x,y,z+3.5,0.5,0.5,ImageMaterials[v[2]],tocolor(255,255,255,255-(12.75*distance))) 
            end
        end
    end
)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, oldValue)
	if(dataName == "job >> leftRock") then
		if(source:getData("job >> leftRock") == 0) then
			rockData = false
		end
    elseif dataName == "char >> job" then
        if source == localPlayer then
            if(source:getData("char >> job") ~= 1) then
                displayCache = {}
            else
                for i, v in pairs(getElementsByType("object")) do
                    if(getElementJobData(v, "rockObjective")) then
                        cache[getElementJobData(v, "rockID")] = {v, getElementJobData(v, "rockType")}     
                    end
                end
            end        
        end
	end
end)

local activityTimer = false
local functionTimer = nil
local vcX, vcY, vcZ = false, false, false
function renderRockAction()
	if(rockData) then
		local pos = localPlayer:getPosition()
		local opos = rockData[1]:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, opos.x, opos.y, opos.z) >= 6) then
			if(isTimer(activityTimer)) then
				killTimer(activityTimer)
			end
			rockData = false
			removeEventHandler("onClientRender", root, renderRockAction)
			exports.cr_progressbar:deleteBar("miner >> rockHP")
		end
	end
	if(isTimer(functionTimer)) then
		local pos = localPlayer:getPosition()
		if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, vcX, vcY, vcZ) > 1) then
			killTimer(functionTimer)
			removeEventHandler("onClientRender", root, renderRockAction)
			exports.cr_progressbar:deleteProgressbar("miner >> felpakolas")
		end
	end
end

local cooldown = nil
addEventHandler("onClientObjectDamage", root, function(loss, attacker)
	if(attacker == localPlayer) then
        if(localPlayer:getData("char >> job") == 1) then
            if(getElementJobData(localPlayer, "started")) then
                if(not getElementJobData(localPlayer, "rockInHand")) then
                    if(getElementJobData(source, "rockObjective") and not isTimer(cooldown)) then
                        local weapon = localPlayer:getWeapon()
                        if(weapon == 11) then
							cooldown = setTimer(function() end, 500, 1)
                            local state
							if(tutorialState < 2 and tutorialState == 1) then
								nextTutorial()
							end
                            if(not rockData) then
                                state = 0
                                addEventHandler("onClientRender", root, renderRockAction)
								exports.cr_progressbar:createBar("miner >> rockHP", tocolor(150, 0, 0, 255), 0, 100)
                            else
                                if(getElementJobData(rockData[1], "rockID") == getElementJobData(source, "rockID")) then
                                    state = rockData[2]
                                else
                                    rockData = false
                                    state = 0
									exports.cr_progressbar:deleteBar("miner >> rockHP")
									exports.cr_progressbar:createBar("miner >> rockHP", tocolor(150, 0, 0, 255), 0, 100)
                                end
                            end
                            if(isTimer(activityTimer)) then
                                killTimer(activityTimer)
                            end
                            state = state+rockStateValues[getElementJobData(source, "rockType")]+extraDMG
							exports.cr_progressbar:updateBar("miner >> rockHP", state)
							
                            if(state >= 100) then
                                state = 100
								exports.cr_progressbar:updateBar("miner >> rockHP", 100)
                            end
                            rockData = {source, state}
                            if(state >= 100) then
                                triggerServerEvent("updateLeftRocks", localPlayer, localPlayer, source)
								exports['cr_infobox']:addBox("info", "A követ a jármű hátuljánál az 'E' gombbal tudod felpakolni.")
								exports.cr_inventory:putdownWeapon()
                                toggleControl("sprint", false)
                                toggleControl("jump", false)
                                rockData = false
								addEventHandler("onClientKey", root, loadRockKeyHandler)
                            end
                            activityTimer = setTimer(function() 
                                rockData = false
                                removeEventHandler("onClientRender", root, renderRockAction)
								exports.cr_progressbar:deleteBar("miner >> rockHP")
                            end, 15000, 1)
							
							localPlayer:setFrozen(true)
							setTimer(function()
								localPlayer:setFrozen(false)
							end, 1000, 1)
                        end
                    end
                end
            end
        end
	end
end)

addCommandHandler("toggledmg", function() 
	if(localPlayer:getSerial() == "15E87BED3CB80510B121B451A1026E52") then
		if(extraDMG == 0) then
			extraDMG = 100
		else
			extraDMG = 0
		end
	end
end)

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end

addEventHandler("onClientVehicleEnter", root, function(p) 
	if(p == localPlayer) then
		if(localPlayer:getData("char >> job") == 1) then
			if(getTickCount()-startTime > 60000) then
				if(source:getData("veh >> job") and source:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
					local rocks = getElementJobData(source, "rocks") or {}
					local bags = getElementJobData(source, "refinedRocks") or {}
					if(#rocks > 0) then
						exports.cr_radar:setGPSDestination(336.34429931641, -65.439849853516)
					end
					if(#bags > 0) then
						exports.cr_radar:setGPSDestination(-1745.3931884766, -110.01053619385)
					end
					if(#bags == 0 and #rocks == 0) then
						exports.cr_radar:setGPSDestination(-2119.4011230469, -1070.8062744141)
					end
				end
			end
		end
	end
end)