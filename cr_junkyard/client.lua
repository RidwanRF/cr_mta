local material = dxCreateTexture("files/image.png")
local sx, sy = guiGetScreenSize()
local white = "#ffffff"

function hitJunkCP(hitPlayer, matchingDimension)
    if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 3 then
        if getElementData(source, "junkyard") then
            local veh = getPedOccupiedVehicle(localPlayer)
            if getPedOccupiedVehicle(localPlayer) then
                local vehId = veh:getData("veh >> owner") or -1
                local vehId2 = veh:getData("veh >> id") or -1
                local accId = localPlayer:getData("acc >> id") or -2
                if vehId == accId and vehId2 >= 1 then
                    gVeh = veh
                    --outputChatBox("asd")
                    --setElementFrozen(gVeh, true)
                    addEventHandler("onClientRender", root, renderPanel, true, "low-5")
                    addEventHandler("onClientClick", root, panelClick)
                    --oState = isCursorShowing()
                    --showCursor(true)
                    vehid = getElementModel(gVeh)
                    vehiclePrice = exports['cr_carshop']:getVehiclePrice(veh, 1) or 0
                    local carHealthMp = getElementHealth(gVeh) / 1000 -- azért 1000 mert a mostani hp-t elosszuk a maxhpval
                    ----outputChatBox(vehiclePrice)
                    ----outputChatBox(vehiclePr)
                    vehiclePrice = math.floor(vehiclePrice*multipler*carHealthMp)
                else
                    exports['cr_infobox']:addBox("error", "Ez nem a te járműved!")
                end
            end
        end
    end
end
addEventHandler("onClientMarkerHit", root, hitJunkCP)

function leaveJunkCP(hitPlayer, matchingDimension)
    if hitPlayer == localPlayer and matchingDimension then
        if getElementData(source, "junkyard") then
            local veh = getPedOccupiedVehicle(localPlayer)
            if getPedOccupiedVehicle(localPlayer) then
                local vehId = veh:getData("veh >> owner") or -1
                local vehId2 = veh:getData("veh >> id") or -1
                local accId = localPlayer:getData("acc >> id") or -2
                if vehId == accId and vehId2 >= 1 then
                    --gVeh = veh
                    --outputChatBox("asd")
                    --setElementFrozen(gVeh, true)
                    removeEventHandler("onClientRender", root, renderPanel, true, "low-5")
                    removeEventHandler("onClientClick", root, panelClick)
                    
                end
            end
        end
    end
end
addEventHandler("onClientMarkerLeave", root, leaveJunkCP)

function renderPanel()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
    local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
    local w,h = 300, 200
    local x,y = sx/2 - w/2, sy/2 - h/2
    local color = exports['cr_core']:getServerColor(nil, true)
    dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
    dxDrawText("Be szeretnéd zuzatni \na járművedet "..color..vehiclePrice..white.."-ért?!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)

    local w2, h2 = 280, 40
    selected = nil
    if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
        selected = 1
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
        dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
        dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end

    if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
        selected = 2
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
        dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
    else
        dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
        dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
    end
end

addEvent("changeMultipler", true)
addEventHandler("changeMultipler", root, 
    function(mp)
        ----outputChatBox("kliens: " .. mp)
        multipler = mp
    end
)    

addEvent("getData", true)
addEventHandler("getData", root, 
        function(datas)
        ----outputChatBox("kliens: " .. mp)
        gMarker = datas[1]
        craneObj = datas[2]
        crObj = datas[3]


        addEventHandler("onClientElementDataChange", craneObj,
            function(dName)
                if source == craneObj then
                    if dName == "startPos" then
                        local val = source:getData(dName)
                        if val then
                            if not lineState then
                                start = val
                                lineState = true
                                addEventHandler("onClientRender", root, drawnLines, true, "low-5")
                            end
                        else
                            if lineState then
                                lineState = false
                                removeEventHandler("onClientRender", root, drawnLines)
                            end
                        end
                    end
                end
            end
        )
    end
)    


function onStart()
    triggerServerEvent("requestMultipler", localPlayer, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

lastClickTick = 0

function panelClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then
        if selected == 2 then
            if lastClickTick + 600 > getTickCount() then
                return
            end
            lastClickTick = getTickCount()
            --outputChatBox("Kilépés")
            removeEventHandler("onClientRender", root, renderPanel)
            removeEventHandler("onClientClick", root, panelClick)
            --showCursor(oState)
            --setElementFrozen(gVeh, false)
        elseif selected == 1 then
            if lastClickTick + 600 > getTickCount() then
                return
            end
            lastClickTick = getTickCount()
            
            if exports['cr_network']:getNetworkStatus() then return end
            --givePlayerMoney(vehiclePrice)
            exports['cr_core']:giveMoney(localPlayer, vehiclePrice)
            --outputChatBox("Kilépés")
            removeEventHandler("onClientRender", root, renderPanel)
            removeEventHandler("onClientClick", root, panelClick)
            --showCursor(false)
            triggerServerEvent("acceptOffer", localPlayer, localPlayer)
        end
        selected = nil
    end
end

--Render

local screenSize = {guiGetScreenSize()}
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

_dxDrawRectangle = dxDrawRectangle;
dxDrawRectangle = function(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
end
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

function drawnOctagon()
    local x,y,z = getElementPosition(gMarker)
    cx, cy, cz = x,y,z + 3
    ----outputChatBox("asd")
    ----outputChatBox(x)
    z = z + 0.399
    local now = getTickCount()
    local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve")
    dxDrawOctagon3D(x,y,z, 1, 3, tocolor(255,51,51,alpha))
    z = z + multipler
    dxDrawImage3D(x, y, z+2, 1, 1, material,tocolor(255,51,51,alpha))
end

setTimer(
    function()
        if isElement(gMarker) and isElementStreamedIn(gMarker) then
            if getDistanceBetweenPoints3D(localPlayer.position, gMarker.position) <= 60 and localPlayer.dimension == gMarker.dimension and localPlayer.interior == gMarker.interior then
                if not state then
                    state = true
                    addEventHandler("onClientRender", root, drawnOctagon, true, "low-5")

                end
            else
                if state then
                    state = false
                    removeEventHandler("onClientRender", root, drawnOctagon)
                end    
            end
        end
    end, 300, 0
)
-- #optimizált

--3dLine
function drawnLines()
    dxDrawLine3D(start[1], start[2], start[3], craneObj.position, tocolor(0,0,0,255), 10)
    ----outputChatBox("asd")
end


function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end