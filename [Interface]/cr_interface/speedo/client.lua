
-- Változók --
local widht,height = (1920/3.7),(1080/3.7)
local iconSize = 182/3.3
local rmp_state = false
local rotation = 0
local frot = 0
local font = dxCreateFont("speedo/files/fontawesome.otf",32)
local state = true
local font2 = dxCreateFont("hud/files/font2.ttf", 20)
local state = false


-- Funkciók --
function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+2,w,h+2,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Fent
    dxDrawText(text,x,y-2,w,h-2,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Lent
    dxDrawText(text,x-2,y,w-2,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Bal
    dxDrawText(text,x+2,y,w+2,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) -- Jobb
end

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName)
        local value = getElementData(source, dName)
        if dName == "inDeath" then
            if value then
                if state then
                    removeEventHandler("onClientRender", root, drawnKm)
                    state = false
                end
                if state2 then
                    removeEventHandler("onClientRender", root, drawnIcons)
                    state2 = false
                end
                if state3 then
                    removeEventHandler("onClientRender", root, drawnSpeedo)
                    state3 = false
                end
                if state4 then
                    removeEventHandler("onClientRender", root, drawnVehName)
                    state4 = false
                end
            end
        end
    end
)

addEventHandler("onClientElementDestroy", root,
    function()
        if getElementType(source) == "vehicle" then
            local veh = getPedOccupiedVehicle(localPlayer)
            if veh == source then
                if state then
                    removeEventHandler("onClientRender", root, drawnKm)
                    state = false
                end
                if state2 then
                    removeEventHandler("onClientRender", root, drawnIcons)
                    state2 = false
                end
                if state3 then
                    removeEventHandler("onClientRender", root, drawnSpeedo)
                    state3 = false
                end
                if state4 then
                    removeEventHandler("onClientRender", root, drawnVehName)
                    state4 = false
                end
            end
        end
    end
)

function removeRenders()
	--if source == localPlayer then
		removeEventHandler("onClientRender", root, drawnKm)
		removeEventHandler("onClientRender", root, drawnIcons)
		removeEventHandler("onClientRender", root, drawnSpeedo)
		removeEventHandler("onClientRender", root, drawnVehName)
		state = false
		state2 = false
		state3 = false
		state4 = false
	--end
end

addEventHandler("onClientPlayerVehicleExit", root,
    function(veh, seat)
        if source == localPlayer then
            if state then
                removeEventHandler("onClientRender", root, drawnKm)
                state = false
            end
            if state2 then
                removeEventHandler("onClientRender", root, drawnIcons)
                state2 = false
            end
            if state3 then
                removeEventHandler("onClientRender", root, drawnSpeedo)
                state3 = false
            end
            if state4 then
                removeEventHandler("onClientRender", root, drawnVehName)
                state4 = false
            end
        end
    end
)

addEventHandler("onClientPlayerVehicleEnter", root,
    function(veh, seat)
        if source == localPlayer then
            if getElementData(localPlayer, "km counter.enabled") then
                if getVehicleType(veh) == "BMX" then return end
                if seat == 0 or seat == 1 then
                    addEventHandler("onClientRender", root, drawnKm, true, "low-5")
                    state = true
                    sourceVeh = getPedOccupiedVehicle(localPlayer)
                end
            end
            if getElementData(localPlayer, "speedo_icon.enabled") then
                if seat == 0 or seat == 1 then
                    addEventHandler("onClientRender", root, drawnIcons, true, "low-5")
                    state2 = true
                    sourceVeh = getPedOccupiedVehicle(localPlayer)
                end
            end
            if getElementData(localPlayer, "speedo.enabled") then
                if getVehicleType(veh) == "BMX" then return end
                if seat == 0 or seat == 1 then
                    addEventHandler("onClientRender", root, drawnSpeedo, true, "low-5")
                    state3 = true
                    sourceVeh = getPedOccupiedVehicle(localPlayer)
                end
            end
            if getElementData(localPlayer, "vehname.enabled") then
                if getVehicleType(veh) == "BMX" then return end
                if seat == 0 or seat == 1 then
                    addEventHandler("onClientRender", root, drawnVehName, true, "low-5")
                    state4 = true
                    sourceVeh = getPedOccupiedVehicle(localPlayer)
                end
            end
        end
    end
)


-- Render Funkciók --
function drawnKm()
	if not getPedOccupiedVehicle(localPlayer) then removeRenders() return end
    if not getElementData(localPlayer, "hudVisible") then return end
    if not getElementData(localPlayer, "km counter.enabled") then return end
    if getPedOccupiedVehicleSeat(localPlayer) <= 1 then
        local enabled,x,y,w,h,sizable,turnable = getDetails("km counter")
        local veh = getPedOccupiedVehicle(localPlayer)
        local khm = math.floor(getElementData(veh, "veh >> odometer"))

        dxDrawText(khm.." km", x+(w/2),y+(h/2),x+(w/2),y+(h/2),tocolor(255,255,255,255),0.6,font,"center","center", false, false, false, true) -- Megtett km
    end
end

function drawnIcons()
	if not getPedOccupiedVehicle(localPlayer) then removeRenders() return end
    if not getElementData(localPlayer, "hudVisible") then return end
    if not getElementData(localPlayer, "speedo_icon.enabled") then return end
    if getPedOccupiedVehicleSeat(localPlayer) <= 1 then
        local enabledIcon,dx,hy,dw,dh,dsizable,dturnable = getDetails("speedo_icon")
        local veh = getPedOccupiedVehicle(localPlayer)
        local alpha = getTickCount()/3
        local iC1, iC2, iC3, iC4, iC5, iC6, iC7 = colorIcons()
        local dy = hy-15

        local state = getElementData(veh, "veh:IndicatorState") or {left = false, right = false};

        if state.left or state.right then
            if alpha == 255 then
                playSound("files/index.mp3");
            end
        end

        dxDrawImage(dx, dy+iconSize/3, iconSize, iconSize, "speedo/files/index_b.png", 0, 0, 0,state.left and tocolor(124, 197, 11, alpha) or iC5) -- Bal index
        dxDrawImage(dx+((iconSize)*2)-27, dy+iconSize/3,iconSize,iconSize,"speedo/files/index_j.png",0,0,0,state.right and tocolor(124, 197, 11, alpha) or iC7) -- Jobb index

        --dxDrawImage(dx, dy+iconSize/3,iconSize,iconSize,"speedo/files/index_b.png",0,0,0, state.left and  iC5) -- Bal index
        --dxDrawImage(dx+((iconSize)*2)-27, dy+iconSize/3,iconSize,iconSize,"speedo/files/index_j.png",0,0,0,iC7) -- Jobb index

        dxDrawImage(dx+((iconSize)*1)-15, dy+iconSize/3,iconSize,iconSize,"speedo/files/kezifek.png",0,0,0,iC6) -- Kézifék

        dxDrawImage(dx, dy+iconSize,iconSize,iconSize,"speedo/files/motor.png",0,0,0,iC4) -- Motor
        dxDrawImage(dx+((iconSize)*1)-15, dy+iconSize,iconSize,iconSize,"speedo/files/lampa.png",0,0,0,iC2) -- Lámpa
        dxDrawImage(dx+((iconSize)*2)-27, dy+iconSize,iconSize,iconSize,"speedo/files/ajto.png",0,0,0,iC1) -- Ajtó
    end
end

function drawnFuel()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,aX,aY,w,h,sizable,turnable = getDetails("speedo")
    local veh = getPedOccupiedVehicle(localPlayer)
    local fuelAlap = getElementData(veh,"veh >> fuel")
    local maxFuel = exports["cr_vehicle"]:getVehicleMaxFuel(getElementModel(veh))
    local fuel = fuelAlap/maxFuel * 100
    local x = aX - 60
    local y = aY - 10

    frot = fuel * 1

    dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",0) 
    if getElementData(veh,"veh >> engine") then
        if frot < 0 then 
            local frot = 0
        elseif frot >= 11 then
            local frot = 11
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        end -- 157nél megy át pirosba
        if frot >= 22 then
            local frot = 22
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 11 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 33 then
            local frot = 33
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 22 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 44 then
            local frot = 44
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 33 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 55 then
            local frot = 55
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 44 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end

        if frot >= 66 then
            local frot = 66
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 55 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 77 then
            local frot = 77
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 66 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 88 then
            local frot = 88
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 77 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
        if frot >= 99 then
            local frot = 99
            dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
        else
            if frot >= 88 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/benzin.png",frot,0,0,tocolor(255,255,255))
            end
        end
    end
end

function drawnSpeedo()
	if not getPedOccupiedVehicle(localPlayer) then removeRenders() return end
    if not getElementData(localPlayer, "hudVisible") then return end
    if not getElementData(localPlayer, "speedo.enabled") then return end
    if getPedOccupiedVehicleSeat(localPlayer) <= 1 then
        local enabled,aX,aY,w,h,sizable,turnable = getDetails("speedo")
        local enabledIcon,dx,hy,dw,dh,dsizable,dturnable = getDetails("speedo_icon")
        local veh = getPedOccupiedVehicle(localPlayer)
        local gear = getVehicleCurrentGear(veh)
        local speed = math.floor(getVehicleSpeed())
        local rot = (speed * 1.2)
        local alpha = getTickCount()/3
        local iC1, iC2, iC3, iC4, iC5, iC6, iC7 = colorIcons()
        --Icons
        local dy = hy-15
        local x = aX - 60
        local y = aY - 10

        dxDrawImage(x-60,y,widht,height,"speedo/files/alap.png")


        if not getElementData(veh,"veh >> engine") then return end
        drawnFuel()

        dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",0) 
        if gear == 0 then gear = "N" end
        if speed == 0 then
            gear = "0"
            if rmp_state == false then
                rmp_state = true
                rot = 5
            else
                rmp_state = false
                rot = 2 
            end
        end
        if gear == 2 then
            rot = rot - 50
        elseif gear == 3 then
            rot = rot - 50
        elseif gear == 4 then
            rot = rot - 50
        elseif gear == 5 then
            rot = rot - 50
        end

        dxDrawText(gear, x+(w/2)+50*2.7, y+(h/2.5)*1.35, x+(w/2)+50*2.7, y+(h/2.5)*1.35,white,0.9,font,"center","center") -- Váltó
        dxDrawText(speed, x+(w/2)+10*8.3, y+(h/3.4)*1.2, x+(w/2)+10*8.3, y+(h/3.4)*1.2,white,1,font,"right") -- Sebesség

        if rot >= rotation then
            if (rot - rotation) < 3 then
                rotation = rotation + (rot - rotation)
            else
                rotation = rotation + 3
            end
        else
            if (rotation - rot) < 3 then
                rotation = rotation - (rotation - rot)
            else
                rotation = rotation - 3
            end
        end

        
    
        if rotation < 0 then 
            local rotation = 0
        elseif rotation >= 22 then
            local rotation = 22
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        end -- 157nél megy át pirosba
        if rotation >= 44 then
            local rotation = 44
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 22 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        if rotation >= 66 then
            local rotation = 66
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 44 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        if rotation >= 88 then
            local rotation = 88
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 66 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        if rotation >= 110 then
            local rotation = 110
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 88 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        if rotation >= 132 then
            local rotation = 132
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 110 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        if rotation >= 154 then
            local rotation = 154
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 132 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
        --pirosak
        if rotation >= 179 then
            local rotation = 179
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
        else
            if rotation >= 157 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
            end
        end
        if rotation >= 201 then
            local rotation = 201
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
        else
            if rotation >= 179 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
            end
        end
        if rotation >= 220 then
            local rotation = 220
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
        else
            if rotation >= 201 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation,0,0,tocolor(255, 26, 26))
            end
        end
        --fedés pirosra
        if rotation >= 157 then
            local rotation = 157
            dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
        else
            if rotation >= 154 then
                dxDrawImage(x-60,y,widht,height,"speedo/files/f.png",rotation)
            end
        end
    end
end


function colorIcons()
    local car = getPedOccupiedVehicle(localPlayer)
    local color = tocolor(255,255,255)
    local color1 = tocolor(255,255,255)
    local color2 = tocolor(255,255,255)
    local color3 = tocolor(255,255,255)
    local color4 = tocolor(255,255,255)
    local color5 = tocolor(255,255,255)
    local color6 = tocolor(255,255,255)
    local color7 = tocolor(255,255,255)
    local alpha = getTickCount()/3

    if not getElementData(car, "veh >> locked") then
        color = tocolor(255,255,255)
    else
        color = tocolor(255,51,51)
    end

    if not getElementData(car, "veh >> light") then
        color1 = tocolor(255,255,255)
    else
        color1 = tocolor(21,129,211)
    end

    local breakelve = false
    local occupants = getVehicleOccupants(car)
    for k,v in pairs(occupants) do
        if not getElementData(v, "char >> belt") then
            breakelve = true
        end
    end
    if breakelve then
        color2 = tocolor(255, 51, 51, alpha)
    else
        color2 = tocolor(255,255,255)
    end

    if(getElementData(car, "veh >> odometer") - getElementData(car,"veh >> lastOilRecoil") >= 988)then
        color3 = tocolor(255, 51, 51)
    elseif(getElementHealth(car) >= 500 and getElementHealth(car) <= 750)then
        color3 = tocolor(255,204,0)
    elseif(getElementHealth(car) >= 400 and getElementHealth(car) <= 499)then
        color3 = tocolor(255, 133, 51)
    elseif(getElementHealth(car) <= 399)then
        color3 = tocolor(255, 51, 51)
    end

    if not getElementData(car, "index.left") then
        color4 = tocolor(255,255,255)
    else
        color4 = tocolor(124, 197, 11, alpha)
    end

    if not getElementData(car, "veh >> handbrake") then
        color5 = tocolor(255,255,255)
    else
        color5 = tocolor(255, 51, 51, alpha)
    end

    if not getElementData(car, "index.right") then
        color6 = tocolor(255,255,255)
    else
        color6 = tocolor(124, 197, 11)
    end

    return color, color1, color2, color3, color4, color5, color6
end

function getSpeedColor(s)
    local color = "#ffffff"
    
    if s <= 75 then -- zöld
        color = "#7cc576"
    elseif s <= 120 then -- sárga
        color = "#d09924"
    elseif s > 12 then -- piros
        color = "#d02424"
    end
    
    return color
end


function drawnVehName()
    if not getElementData(localPlayer, "hudVisible") then return end
    if not getPedOccupiedVehicle(localPlayer) then removeRenders() return end
    if not getElementData(localPlayer, "vehname.enabled") then return end
    local sourceVeh = getPedOccupiedVehicle(localPlayer)
    --vehname
    local enabled,x,y,w,h,sizable,turnable = getDetails("vehname")
    local text = exports['cr_vehicle']:getVehicleName(sourceVeh) .. " "
    if getElementData(sourceVeh, "tempomat") then
        local tempomatSpeed = getElementData(sourceVeh, "tempomat.speed")
        local speedColor = getSpeedColor(tempomatSpeed)
        text = text .. speedColor .."(" ..math.floor(tempomatSpeed).." km/h)"
    end
    local text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
    shadowedText(text2, x, y, x + w, y + h, tocolor(255,255,255,255), 1, font2, "center", "center", false, false, false, true)
    dxDrawText(text, x, y, x + w, y + h, tocolor(255,255,255,255), 1, font2, "center", "center", false, false, false, true)
end


function getVehicleSpeed()
	local vehicle = getPedOccupiedVehicle(localPlayer)
    if isPedInVehicle(localPlayer) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 180		
	end
    return 0
end