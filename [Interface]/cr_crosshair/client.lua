local sx, sy = 210, 210

local x, y = guiGetScreenSize()

function boneBreaked(e)
    --char >> bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[2] or not bone[3] then 
        return true
    end
    return false
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "char >> bone" then
            local value = getElementData(source, dName)
            if not value[2] or not value[3] then
                if state then
                    removeEventHandler("onClientRender", root, drawnCrosshair)
                    local weapon = getPedWeapon(localPlayer)
                    if weapon == 34 then
                        setElementData(localPlayer, "hudVisible", true)
                        setElementData(localPlayer, "keysDenied", false)
                    end
                elseif rstatus then
                    if isElement(shader) or isElement(texture) then
                        setPlayerHudComponentVisible("crosshair", false)
                        destroyElement(shader)
                        destroyElement(texture)
                        local weapon = getPedWeapon(localPlayer)
                        if weapon == 34 then
                            setElementData(localPlayer, "hudVisible", true)
                            setElementData(localPlayer, "keysDenied", false)
                        end
                        rstatus = false
                        removeEventHandler("onClientPlayerVehicleExit", localPlayer, disableCrosshair)
                    end
                end
            end    
        end
    end
)

setPlayerHudComponentVisible("crosshair", false)

local disabledWeapon = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [39] = true,
    [41] = true,
    [42] = true,
    [43] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [14] = true,
    [15] = true,
    [44] = true,
    [45] = true,
    [46] = true,
    [40] = true,
}

local wx, wy = x/2 + 38, y/2-72

function drawnCrosshair()
	if not getElementData(localPlayer, "loggedIn") then return end
    --if not getElementData(localPlayer, "hudVisible") then return end
	local weapon = getPedWeapon(localPlayer)
    if weapon == 34 then
        dxDrawImage(0, 0, x, y, "files/snipercrosshair.png")
    elseif not disabledWeapon[weapon] then
        --dxDrawImage(wx-sx/2,wy-sy/2,sx,sy,"files/crosshair.png", 0,0,0, tocolor(255,51,51,255))
		local hX,hY,hZ = getPedTargetEnd(localPlayer)
		local wx, wy = getScreenFromWorldPosition(hX,hY,hZ)
		if(wx and wy) then
            local target = getPedTarget(localPlayer)
            if target and getElementType(target) == "player" and target ~= localPlayer then
                dxDrawImage(wx-sx/2,wy-sy/2,sx,sy,"files/crosshair.png", 0,0,0, tocolor(255,51,51,255))
            elseif target and getElementType(target) == "vehicle" then
                dxDrawImage(wx-sx/2,wy-sy/2,sx,sy,"files/crosshair.png", 0,0,0, tocolor(124, 197, 11,255))    
            else
			    dxDrawImage(wx-sx/2,wy-sy/2,sx,sy,"files/crosshair.png", 0,0,0, tocolor(255,255,255,255))
            end
		end
        --local x, y = exports['cr_core']:getCursorPosition()
        --dxDrawRectangle(x - 20/2, y - 20/2, 20, 20)
	end
end

function toggleCrosshair(_, status)
	if status == "down" then 
        if boneBreaked(localPlayer) then return end
		addEventHandler("onClientRender", root, drawnCrosshair, true, "low-5")
        state = true
        local weapon = getPedWeapon(localPlayer)
        if weapon == 34 then
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "keysDenied", true)
        end
	else 
        if state then
            removeEventHandler("onClientRender", root, drawnCrosshair)
            local weapon = getPedWeapon(localPlayer)
            if weapon == 34 then
                setElementData(localPlayer, "hudVisible", true)
                setElementData(localPlayer, "keysDenied", false)
            end
        end    
	end
end

function toggleCrosshairVehicle(_, status)
    if not getPedOccupiedVehicle(localPlayer) then return end
    local weaponSlot = getPedWeaponSlot(localPlayer)
    --outputChatBox(weaponSlot)
	if not rstatus and getElementData(localPlayer, "pulling") then
        if boneBreaked(localPlayer) then return end
		--addEventHandler("onClientRender", root, drawnCrosshair, true, "low-5")
        setPlayerHudComponentVisible("crosshair", true)
        texture = dxCreateTexture("files/crosshair2.png")
        shader = dxCreateShader("shaders/shader.fx")
        dxSetShaderValue(shader, "gTexture", texture)
        engineApplyShaderToWorldTexture(shader, "sitem16")
        local weapon = getPedWeapon(localPlayer)
        if weapon == 34 then
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "keysDenied", true)
        end
        rstatus = true
        addEventHandler("onClientPlayerVehicleExit", localPlayer, disableCrosshair)
	elseif rstatus then
		--removeEventHandler("onClientRender", root, drawnCrosshair)
        if isElement(shader) or isElement(texture) then
            setPlayerHudComponentVisible("crosshair", false)
            destroyElement(shader)
            destroyElement(texture)
            local weapon = getPedWeapon(localPlayer)
            if weapon == 34 then
                setElementData(localPlayer, "hudVisible", true)
                setElementData(localPlayer, "keysDenied", false)
            end
            rstatus = false
            removeEventHandler("onClientPlayerVehicleExit", localPlayer, disableCrosshair)
        end
	end
end

function disableCrosshair()
    if isElement(shader) or isElement(texture) then
        setPlayerHudComponentVisible("crosshair", false)
        destroyElement(shader)
        destroyElement(texture)
        local weapon = getPedWeapon(localPlayer)
        if weapon == 34 then
            setElementData(localPlayer, "hudVisible", true)
            setElementData(localPlayer, "keysDenied", false)
        end
        rstatus = false
        removeEventHandler("onClientPlayerVehicleExit", localPlayer, disableCrosshair)
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function() 
		bindKey("aim_weapon", "both", toggleCrosshair)
        bindKey("x", "down", toggleCrosshairVehicle)
	end
)
	
addEventHandler("onClientResourceStop", resourceRoot,
    function()
        unbindKey("aim_weapon", "both", toggleCrosshair)
        unbindKey("x", "down", toggleCrosshairVehicle)
    end
)