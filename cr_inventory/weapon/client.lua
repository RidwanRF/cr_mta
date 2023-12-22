local started = false
local id = getPedWeapon(localPlayer)
setTimer(
    function()
        id = getPedWeapon(localPlayer)
    end, 100, 0
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "loggedIn") then
            if getElementData(localPlayer, "weapon.enabled") then
                addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
            end
        end
    end
)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "loggedIn" then        
            --id = getElementData(localPlayer, "id") or -1
            if getElementData(localPlayer, "weapon.enabled") then
                addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
            end
        elseif dName == "weapon.enabled" then
            local value = getElementData(source, dName)
            if value then
                addEventHandler("onClientRender", root, drawnWeapon, true, "low-1")
            else
                removeEventHandler("onClientRender", root, drawnWeapon)
            end 
        end
    end
)

local nodes = {}
local nodesT = {}

function getDetails(...)
    return exports['cr_interface']:getDetails(...)
    
    --[[
    if nodes[name] then
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    else
        nodes[name] = {exports['cr_interface']:getDetails(name)}
        if not (nodesT[name]) then
            nodesT[name] = setTimer(
                function()
                    if nodes[name] ~= {exports['cr_interface']:getDetails(name)} then
                        nodes[name] = {exports['cr_interface']:getDetails(name)}
                    end
                end, 50, 0
            )
            --nodesT[name] = true
        end
        return nodes[name][1], nodes[name][2], nodes[name][3], nodes[name][4], nodes[name][5], nodes[name][6], nodes[name][7], nodes[name][8], nodes[name][9], nodes[name][10]
    end
    
    return exports['cr_interface']:getDetails(name)]]
end

--[[
local lastUpdate = -500
addEventHandler("onClientRender", root,
    function()
        
        if lastUpdate + 25 <= getTickCount() then
            for name,v in pairs(nodesT) do
                nodes[name] = {exports['cr_interface']:getDetails(name)}
            end
            lastUpdate = getTickCount()
        end
        
    end, true, "low-5"
)]]

gwMultipler = 1

function drawnWeapon()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,sx,sy,sw,sh,sizable,turnable = getDetails("weapon")
    if not enabled then return end

    --local id = getPedWeapon(localPlayer)
    dxDrawImage(sx, sy, 256/1.2, 128/1.2, ":cr_interface/weapon/files/weapon"..id..".png")
    
    if disabled then return end
    if weaponInHand then
        font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
        
        local a2 = gwMultipler
        if a2 ~= wMultipler then
            if not aAnimating then
                animate(gwMultipler, wMultipler, "Linear", 100, 
                    function(v)
                        gwMultipler = v
                    end,

                    function()
                        aAnimating = false
                    end, "animating"
                )

                aAnimating = true
            end
        end
        
        local _id = id
        local slot, id, itemid, value, count, status, dutyitem, premium, nbt, ammo, hasData = unpack(weaponDatas)
        local slot2, data = unpack(hasData)

        local maximum_clip_ammo = getWeaponProperty(_id, "poor", "maximum_clip_ammo") or 30
        local x, y = sx, sy + sh
        local x2, y2 = x + sw, y + 20
        dxDrawText(ammo .. "/" .. maximum_clip_ammo, x, y - 10, x2, y2 - 10, tocolor(255,255,255,255), 1, font, "right", "center")
        
        local y = y + 15
        dxDrawRectangle(sx, y, sw, 10, tocolor(90,90,90,120))
        local color = {} 
        if wMultipler <= 0.25 then
            color = {253, 0, 0}
        elseif wMultipler <= 0.5 then
            color = {253, 105, 0}
        elseif wMultipler <= 0.75 then
            color = {253, 168, 0} 
        elseif wMultipler <= 1 then 
            color = {106, 253, 0}
        end    
        dxDrawRectangle(sx, y, sw * gwMultipler, 10, tocolor(color[1],color[2],color[3],120))
        dxDrawRectangle3(sx,y,sw, 10, tocolor(90,90,90,0), tocolor(0,0,0,180), 2)
        
        if recailing then
            --outputChatBox(tostring(started))
            if not started then
                local between = (1 - wMultipler) * 50
                started = true
                animate(wMultipler, 1, "Linear", between * 250, 
                    function(v)
                        wMultipler = v
                    end,

                    function()
                        started = false
                    end
                )
            end
        end
    end
end    

--
local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function animate(f, t, easing, duration, onChange, onEnd, boolean)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    if boolean then
        anims[boolean] = {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd}
    else
	   table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
    end
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
    started = false
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in pairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
            if type(k) == "number" then
			    table.remove(anims, k)
            else
                anims[k] = nil
            end
		end
	end
end)

screenSize = {guiGetScreenSize()}
local cursorState = isCursorShowing()
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2]
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

function getCursorPosition()
    return cursorX, cursorY
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end