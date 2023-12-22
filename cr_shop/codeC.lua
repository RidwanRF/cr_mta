local playerShop = false;
local refreshTimer = nil;
local x, y, z = 0, 0, 0
local nearbyItems = {};
local renderTarget = false;
local selectedItem = 0;
local streamedShelves = {}
local nearbyShelf = nil;
local nearbyDistance = 0;
local playerCart = {};
local cartWeight = 0;
local isCart = false
local sx, sy = guiGetScreenSize();
local shopcart_x,shopcart_y,shopcart_w,shopcart_h = sx-200, sy-200, 150, 150
local startTime, endTime, startTime2, endTime2 = 0, 0, 0, 0
local hexCode = exports['cr_core']:getServerColor(nil, true)

addEventHandler("onClientResourceStart", resourceRoot, function()
	local txd = engineLoadTXD("files/basket.txd")
	engineImportTXD(txd, 324)
	local dff = engineLoadDFF("files/basket.dff")
	engineReplaceModel(dff, 324)
end)

function getMatrixLeft(m)
    return m[1][1], m[1][2], m[1][3]
end
function getMatrixForward(m)
    return m[2][1], m[2][2], m[2][3]
end
function getMatrixUp(m)
    return m[3][1], m[3][2], m[3][3]
end
function getMatrixPosition(m)
    return m[4][1], m[4][2], m[4][3]
end

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end

function isInSlot(x, y, w, h)
    return exports.cr_core:isInSlot(x, y, w, h);
end
isCursorHover = isInSlot

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

local payMenu, ppos, selectedPayment, totalPrice, hoveredSlot = false, false, 1, 0, 0;
local font = exports['cr_fonts']:getFont("Roboto", 11)
local font2 = exports['cr_fonts']:getFont("Roboto", 9)

local actionTimer, actionType = nil, 0
function shopKey(key, press) 
	if(key == "space") then
		if(press) then
			if(not isTimer(actionTimer)) then
				actionType = 1
				startTime2, endTime2 = getTickCount(), getTickCount()+1500
				actionTimer = setTimer(function() 
					triggerServerEvent("buyItems", resourceRoot, playerCart, selectedPayment, totalPrice, cartWeight)
					removeEventHandler("onClientKey", root, shopKey)
					startTime2, endTime2 = 0, 0
					actionType = 0
					payMenu = false
				end, 1500, 1)
			end
		else
			if(isTimer(actionTimer)) then
				killTimer(actionTimer)
				actionType = 0
				startTime2, endTime2 = 0, 0
			end
		end
	elseif(key == "backspace") then
		if(press) then
			if(not isTimer(actionTimer)) then
				actionType = 2
				startTime2, endTime2 = getTickCount(), getTickCount()+1500
				actionTimer = setTimer(function() 
					playerCart = {}
					cartWeight = 0
					removeEventHandler("onClientKey", root, shopKey)
					payMenu = false
					startTime2, endTime2 = 0, 0
					actionType = 0
				end, 1500, 1)
			end
		else
			if(isTimer(actionTimer)) then
				killTimer(actionTimer)
				actionType = 0
				startTime2, endTime2 = 0, 0
			end
		end
	end
end

local textures = {}
function returnTexture(path)
	if not textures[path] then
		textures[path] = dxCreateTexture(path)
		return textures[path] 
	else
		return textures[path]
	end
end
local dot = dxCreateTexture("files/dot.png")

local hoverItem = 0

function renderItems()
	if  nearbyShelf and nearbyItems then 
		hoverItem = 0
		local pos = streamedShelves[nearbyShelf].pos
		local i = 1
		local distance_alpha = 0
		if nearbyDistance > 5 then
			distance_alpha = ((nearbyDistance-5)/2)*-170
		end

		for _,value in pairs(nearbyItems) do 
			
			local alpha = 0
			local cursorX,cursorY = getCursorPosition()
			if nearbyDistance <= 3 and cursorX and cursorY then
				cursorX,cursorY = sx*cursorX,sy*cursorY
				local start_screenx,start_screeny = getScreenFromWorldPosition( pos[i][1].x, pos[i][1].y+0.14, pos[i][1].z+0.16)
				local end_screenx,end_screeny =  getScreenFromWorldPosition( pos[i][1].x, pos[i][1].y-0.14,pos[i][1].z-0.16)
				if start_screenx and start_screeny and end_screenx and end_screeny  and cursorX >= start_screenx and cursorX <= end_screenx and cursorY >= start_screeny and cursorY <= end_screeny then
					alpha = 85
					hoverItem = i
					dxDrawMaterialLine3D(pos[i][1].x, pos[i][1].y, pos[i][1].z+0.16, pos[i][1].x, pos[i][1].y,pos[i][1].z-0.16, dot, 0.32,tocolor(255, 255, 255, 170), pos[i][2].x,pos[i][2].y,pos[i][2].z)
				end
			end
			local texture = returnTexture(":cr_inventory/assets/items/"..value[1]..".png")
			dxDrawMaterialLine3D(pos[i][1].x, pos[i][1].y, pos[i][1].z+0.15, pos[i][1].x, pos[i][1].y,pos[i][1].z-0.15, texture, 0.3,tocolor(255, 255, 255, 170+alpha+distance_alpha), pos[i][2].x,pos[i][2].y,pos[i][2].z)
			
			

			i = i+1			
		end
	end

	if(payMenu) then
		local pos2 = localPlayer:getPosition()
		local x, y, w, h = sx/2-150, 0, 300, 550
		local now = getTickCount()
		local elapsedTime = now - startTime
		local duration = endTime - startTime
		local progress = elapsedTime / duration
		_, y, _ = interpolateBetween(0, 0, 0, 0, sy/2-275, 0, progress, "OutBack")
		exports['cr_core']:roundedRectangle(x, y, w, h, tocolor(0, 0, 0, 200))
		exports['cr_core']:roundedRectangle(x, y, w, 30, tocolor(0, 0, 0, 200))
		
		exports['cr_core']:roundedRectangle(x+10, y+250, w-20, 275, tocolor(0, 0, 0, 200))
		
		exports['cr_core']:roundedRectangle(x+10, y+80, 25, 25, tocolor(100, 100, 100, 200))
		exports['cr_core']:roundedRectangle(x+15, y+85, 15, 15, tocolor(100, 255, 100, (selectedPayment == 1 and 200 or 0)))
		dxDrawText("Készpénz", x+70, y+90, x+80, y+95, (selectedPayment == 1 and tocolor(100, 255, 100, 255) or tocolor(255, 255, 255, 255)), 1, font, "center", "center", false, false, true, true) 
		
		exports['cr_core']:roundedRectangle(x+w-35, y+80, 25, 25, tocolor(100, 100, 100, 200))
		dxDrawText("Bankkártya", x+w-140, y+90, x+w-18, y+95, (selectedPayment == 2 and tocolor(100, 255, 100, 255) or tocolor(255, 255, 255, 255)), 1, font, "center", "center", false, false, true, true) 
		exports['cr_core']:roundedRectangle(x+w-30, y+85, 15, 15, tocolor(100, 255, 100, (selectedPayment == 2 and 200 or 0)))
		
		dxDrawRectangle(x+10, y+270, w-20, 1, tocolor(255, 255, 255, 200))
		dxDrawRectangle(x+10, y+500, w-20, 1, tocolor(255, 255, 255, 200))
		
		dxDrawText("Bolt - Fizetés", x, y, x+w, y+30, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
		dxDrawText("Tétel", x+15, y+250, x+60, y+270, tocolor(255, 255, 255, 255), 1, font, "left", "center", false, false, true, true)
		dxDrawText("Ár", x+w-70, y+250, x+w-20, y+270, tocolor(255, 255, 255, 255), 1, font, "right", "center", false, false, true, true)
		dxDrawText("Kérlek válassz fizetési módot!", x+10, y+30, 0, 0, tocolor(255, 255, 255, 255), 1, font, nil, nil, false, false, true, true)
		dxDrawText("A fizetés megkezdéséhez,\ntartsd nyomva a 'SPACE' gombot!\nA megszakításhoz,\ntartsd nyomva a 'BACKSPACE' gombot!", x+10, y+125, 0, 0, tocolor(255, 255, 255, 255), 1, font, nil, nil, false, false, true, true)
		
		local allPrice = 0
		for i, v in pairs(playerCart) do
			local iName = exports.cr_inventory:getItemName(v[1]) or "Ismeretlen"
			local iPrice = v[2]
			allPrice = allPrice+iPrice
			dxDrawText(iName.." (x"..v[3]..")", x+65, y+290+((i-1)*37), x+85, y+300+((i-1)*37), tocolor(255, 255, 255, 255), 1, font, "left", "center", false, false, true, true)
			dxDrawText("$"..iPrice, x+w-70, y+290+((i-1)*37), x+w-20, y+300+((i-1)*37), tocolor(100, 255, 100, 255), 1, font, "right", "center", false, false, true, true)
			dxDrawImage(x+15, y+275+((i-1)*37), 35, 35, ":cr_inventory/assets/items/"..v[1]..".png")
		end
		dxDrawText("$"..allPrice, x+w-70, y+290+((7-1)*37), x+w-20, y+290+((7-1)*37), tocolor(100, 255, 100, 255), 1, font, "right", "center", false, false, true, true)
		dxDrawText("Összesen:", x+15, y+290+((7-1)*37), x+65, y+290+((7-1)*37), tocolor(255, 255, 255, 255), 1, font, "left", "center", false, false, true, true)
		
		totalPrice = allPrice
		
		if(actionType ~= 0) then
			if(actionType == 1 or actionType == 2) then
				exports['cr_core']:roundedRectangle(x+10, y+h-20, w-20, 15, tocolor(0, 0, 0, 200))
				local now2 = getTickCount()
				local elapsedTime2 = now2 - startTime2
				local duration2 = endTime2 - startTime2
				local progress2 = elapsedTime2 / duration2
				local pSize, _, _ = interpolateBetween(0, 0, 0, w-20, 0, 0, progress2, "Linear")
				exports['cr_core']:roundedRectangle(x+10, y+h-20, pSize, 15, (actionType == 1 and tocolor(100, 255, 100, 200) or actionType == 2 and tocolor(255, 100, 100, 200)))
				dxDrawText((actionType == 1 and "Fizetés..." or actionType == 2 and "Megszakítás..."), x+10, y+h-20, x+w-20, y+h-5, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
			end
		end
		if(getDistanceBetweenPoints3D(ppos.x, ppos.y, ppos.z, pos2.x, pos2.y, pos2.z) > 4) then
			payMenu = false
			ppos = false
			removeEventHandler("onClientKey", root, shopKey)
		end
	end
	
	if(#playerCart > 0 and not payMenu) then	

		hoveredSlot = 0
		local allPrice = 0
		for i, v in pairs(playerCart) do
			allPrice = allPrice+v[2]
		end
		if isCart then
			dxDrawImage(shopcart_x+shopcart_w/2-30, shopcart_y+45, 60, 60, "files/basket.png", 0, 0, 0, tocolor(255, 255, 255, 175))
			dxDrawRoundedRectangle(shopcart_x,shopcart_y,shopcart_w,shopcart_h,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
			dxDrawRoundedRectangle(shopcart_x,shopcart_y,shopcart_w,30,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
			dxDrawText(hexCode.."Kosár",shopcart_x,shopcart_y,shopcart_x+shopcart_w,shopcart_y+30,tocolor(255,255,255),1,font2,"center","center",false,false,false,true)
		
			dxDrawText(hexCode.."Tömeg:\nÖsszérték:", shopcart_x+10, shopcart_y+120, shopcart_x+shopcart_w-10, shopcart_y+120+20, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, true, true)
			dxDrawText(cartWeight.." kg\n#64ff64$"..math.floor(allPrice), shopcart_x+10, shopcart_y+120, shopcart_x+shopcart_w-10, shopcart_y+120+20, tocolor(255,255,255, 255), 1, font2, "right", "center", false, false, true, true)
	
			for i=1, 6 do
				if(i <= 3) then 
					if(isCursorHover(shopcart_x+((i-1)*32)+25, shopcart_y+40, 30, 30)) then
						hoveredSlot = i
					end
					dxDrawRectangle(shopcart_x+((i-1)*32)+25, shopcart_y+40, 30, 30, tocolor(0, 0, 0, 100))
					if(playerCart[i]) then
						dxDrawImage(shopcart_x+((i-1)*32)+25, shopcart_y+40, 30, 30, ":cr_inventory/assets/items/"..playerCart[i][1]..".png", 0, 0, 0, tocolor(255, 255, 255, (hoveredSlot == i) and 100 or 255))
						if(hoveredSlot == i) then
							dxDrawImage(shopcart_x+((i-1)*32)+25+1, shopcart_y+40, 28, 30, "files/minus.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
					end
				else
					if(isCursorHover(shopcart_x+((i-4)*32)+25, shopcart_y+72, 30, 30)) then
						hoveredSlot = i
					end
					dxDrawRectangle(shopcart_x+((i-4)*32)+25, shopcart_y+72, 30, 30, tocolor(0, 0, 0, 100))
					if(playerCart[i]) then
						dxDrawImage(shopcart_x+((i-4)*32)+25, shopcart_y+72, 30, 30, ":cr_inventory/assets/items/"..playerCart[i][1]..".png", 0, 0, 0, tocolor(255, 255, 255, (hoveredSlot == i) and 100 or 255))
						if(hoveredSlot == i) then
							dxDrawImage(shopcart_x+((i-4)*32)+25+1, shopcart_y+72, 28, 30, "files/minus.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
					end
				end
			end
		else

			dxDrawImage(shopcart_x+shopcart_w/2-30, shopcart_y+45, 60, 60, "files/hand.png", 0, 0, 0, tocolor(255, 255, 255, 175))
			dxDrawRoundedRectangle(shopcart_x,shopcart_y,shopcart_w,shopcart_h,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
			dxDrawRoundedRectangle(shopcart_x,shopcart_y,shopcart_w,30,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
			dxDrawText(hexCode.."Kézben",shopcart_x,shopcart_y,shopcart_x+shopcart_w,shopcart_y+30,tocolor(255,255,255),1,font2,"center","center",false,false,false,true)
		
			dxDrawText(hexCode.."Tömeg:\nÖsszérték:", shopcart_x+10, shopcart_y+120, shopcart_x+shopcart_w-10, shopcart_y+120+20, tocolor(255, 255, 255, 255), 1, font2, "left", "center", false, false, true, true)
			dxDrawText(cartWeight.." kg\n#64ff64$"..math.floor(allPrice), shopcart_x+10, shopcart_y+120, shopcart_x+shopcart_w-10, shopcart_y+120+20, tocolor(255,255,255, 255), 1, font2, "right", "center", false, false, true, true)
	
			for i=1, 2 do
					if(isCursorHover(shopcart_x+((i-1)*32)+42, shopcart_y+60, 30, 30)) then
						hoveredSlot = i
					end
					dxDrawRectangle(shopcart_x+((i-1)*32)+42, shopcart_y+60, 30, 30, tocolor(0, 0, 0, 100))
					if(playerCart[i]) then
						dxDrawImage(shopcart_x+((i-1)*32)+42, shopcart_y+60, 30, 30, ":cr_inventory/assets/items/"..playerCart[i][1]..".png", 0, 0, 0, tocolor(255, 255, 255, (hoveredSlot == i) and 100 or 255))
						if(hoveredSlot == i) then
							dxDrawImage(shopcart_x+((i-1)*32)+42+1, shopcart_y+60, 28, 30, "files/minus.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
					end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderItems, true, "low-5")

local move_x,move_y = 0,0 

function panelMoove()
	local x,y = getCursorPosition()
	if x and y then
		x,y = sx*x,sy*y
		shopcart_x, shopcart_y = x-move_x,y-move_y
	end
end

function shopClick(button, state, ax, ay, wx, wy, wz, e)
	if(playerShop) then
		if(button == "left" and state == "down") then
			if(e and e:getData("shop >> shopBasket")) then
				local pos = localPlayer:getPosition()
				local epos = e:getPosition()
				local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, epos.x, epos.y, epos.z)
				if(dist <= 1.5) then
					if(not isElement(localPlayer:getData("shop >> basket"))) then
						triggerServerEvent("pickupBasket", resourceRoot)
						isCart = true
					else
						triggerServerEvent("destroyBasket", resourceRoot)
						isCart = false
						if(#playerCart > 2) then
							cartWeight = 0
							playerCart = {}
						end
					end
				end
			elseif(e and e:getData("shop >> npc") and not payMenu) then
				if(#playerCart > 0) then
					local pos = localPlayer:getPosition()
					local _pos = e:getPosition()
					if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, _pos.x, _pos.y, _pos.z) <= 3) then
						startTime, endTime = getTickCount(), getTickCount()+500
						payMenu = true
						ppos = localPlayer:getPosition()
						addEventHandler("onClientKey", root, shopKey)
					end
				else
					local syntax = exports['cr_core']:getServerSyntax(false, "error")
					outputChatBox(syntax.."A kezed/kosarad üres.", 255, 255, 255, true)
				end
			elseif(payMenu) then
				local x, y, w, h = sx/2-150, sy/2-275, 300, 550
				if(isCursorHover(x+10, y+80, 25, 25)) then
					selectedPayment = 1
				elseif(isCursorHover(x+w-35, y+80, 25, 25)) then
					selectedPayment = 2
				end
			elseif(hoverItem > 0) then
				if(localPlayer:getData("shop >> basket")) then
					if(#playerCart < 6) then
						local w = exports.cr_inventory:getItemWeight(nearbyItems[hoverItem][1]) or 0
						if(cartWeight+w <= 5) then
							table.insert(playerCart, nearbyItems[hoverItem])
							cartWeight = cartWeight+w
							exports.cr_infobox:addBox("info", "Beraktál a kosaradba egy tételt: "..exports.cr_inventory:getItemName(nearbyItems[hoverItem][1]))
						else
							local syntax = exports['cr_core']:getServerSyntax(false, "error")
							outputChatBox(syntax.."A kosarad súlya nem lehet nagyobb 5kg -nál.", 255, 255, 255, true)
						end
					else
						local syntax = exports['cr_core']:getServerSyntax(false, "error")
						outputChatBox(syntax.."A kosaradban egyszerre csak 6 darab tétel lehet.", 255, 255, 255, true)
					end
				else
					if(#playerCart < 2) then
						local w = exports.cr_inventory:getItemWeight(nearbyItems[hoverItem][1]) or 0
						if(cartWeight+w <= 2) then
							table.insert(playerCart, nearbyItems[hoverItem])
							cartWeight = cartWeight+w
							exports.cr_infobox:addBox("info", "Kezedbe vettél egy tételt: "..exports.cr_inventory:getItemName(nearbyItems[hoverItem][1]))
						else
							local syntax = exports['cr_core']:getServerSyntax(false, "error")
							outputChatBox(syntax.."A kezedben nem bírsz 2 kg -nál többet vinni.", 255, 255, 255, true)
						end
					else
						local syntax = exports['cr_core']:getServerSyntax(false, "error")
						outputChatBox(syntax.."A kezedben nem bírsz 2 tételnél többet vinni.", 255, 255, 255, true)
					end
				end
			elseif(hoveredSlot > 0) then
				if(playerCart[hoveredSlot]) then
					table.remove(playerCart, hoveredSlot)
					local totalWeight = 0
					for i, v in pairs(playerCart) do
						totalWeight = totalWeight+exports.cr_inventory:getItemWeight(v[1])
					end
					cartWeight = totalWeight
					exports.cr_infobox:addBox("info", "Tétel törölve.")
				end
			end
			if(isCursorHover(shopcart_x, shopcart_y, shopcart_w, 30) and #playerCart) then 
				move_x,move_y = ax-shopcart_x,ay-shopcart_y
				addEventHandler( "onClientRender", root, panelMoove )
			end
		elseif(button == "left" and state == "up" and isCursorHover(shopcart_x, shopcart_y, shopcart_w, 30)) then 
				removeEventHandler( "onClientRender", root, panelMoove )
		end
	end
end

addEventHandler("onClientColShapeHit", root, function(hit, md)
	if(hit == localPlayer and md) then
		if(source:getData("shop >> id")) then
			playerShop = tonumber(source:getData("shop >> id"))
			addEventHandler("onClientClick", root, shopClick)
			cartWeight = 0
			playerCart = {}
			
			if(not isTimer(refreshTimer)) then
				refreshTimer = setTimer(function()
					local nearbyNow = {nil,8}
					for i, v in pairs(streamedShelves) do
						if(isElement(v.element)) then
							local pos = v.element:getPosition()
							local _pos = localPlayer:getPosition()
							local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, _pos.x, _pos.y, _pos.z)
							if dist < 7 and dist < nearbyNow[2] then
								nearbyNow = {v.element,dist}
							end
						end
					end
					if nearbyNow[1] then
						nearbyItems = streamedShelves[nearbyNow[1]].element:getData("shop >> items")
						nearbyShelf = nearbyNow[1]
						nearbyDistance = nearbyNow[2]
					else
						nearbyItems = nil
						nearbyShelf = nil 
					end
				end, 50, 0)
			end
		end
	end
end)

addEventHandler("onClientResourceStart",resourceRoot,function()
	setTimer(function()
		for _,value in pairs(getElementsByType("object",root,true)) do
			if value:getData("shop >> shopObject") then
				local matrix = value.matrix
				local _pos = {
					{matrix:transformPosition(Vector3(1.2,0.35,1.6)),matrix:transformPosition(Vector3(1.2,1,1.8))},
					{matrix:transformPosition(Vector3(0.8,0.35,1.6)),matrix:transformPosition(Vector3(0.8,1,1.8))},
					{matrix:transformPosition(Vector3(0.4,0.35,1.6)),matrix:transformPosition(Vector3(0.4,1,1.8))},
					{matrix:transformPosition(Vector3(0,0.35,1.6)),matrix:transformPosition(Vector3(0,1,1.8))},
					{matrix:transformPosition(Vector3(-0.4,0.35,1.6)),matrix:transformPosition(Vector3(-0.4,1,1.8))},
					{matrix:transformPosition(Vector3(-0.8,0.35,1.6)),matrix:transformPosition(Vector3(-0.8,1,1.8))},
					{matrix:transformPosition(Vector3(-1.2,0.35,1.6)),matrix:transformPosition(Vector3(-1.2,1,1.8))},
					{matrix:transformPosition(Vector3(1.2,0.35,1.2)),matrix:transformPosition(Vector3(1.2,1,1.4))},
					{matrix:transformPosition(Vector3(0.8,0.35,1.2)),matrix:transformPosition(Vector3(0.8,1,1.4))},
					{matrix:transformPosition(Vector3(0.4,0.35,1.2)),matrix:transformPosition(Vector3(0.4,1,1.4))},
					{matrix:transformPosition(Vector3(0,0.35,1.2)),matrix:transformPosition(Vector3(0,1,1.4))},
					{matrix:transformPosition(Vector3(-0.4,0.35,1.2)),matrix:transformPosition(Vector3(-0.4,1,1.4))},
					{matrix:transformPosition(Vector3(-0.8,0.35,1.2)),matrix:transformPosition(Vector3(-0.8,1,1.4))},
					{matrix:transformPosition(Vector3(-1.2,0.35,1.2)),matrix:transformPosition(Vector3(-1.2,1,1.4))},

				}
				
				streamedShelves[value] = {element = value,pos = _pos}
			end
		end
	end,500,1)
end)

addEventHandler("onClientElementStreamIn", root, function()
	if source:getData("shop >> shopObject") then
			local matrix = source.matrix
			local _pos = {
					{matrix:transformPosition(Vector3(1.2,0.35,1.6)),matrix:transformPosition(Vector3(1.2,1,1.8))},
					{matrix:transformPosition(Vector3(0.8,0.35,1.6)),matrix:transformPosition(Vector3(0.8,1,1.8))},
					{matrix:transformPosition(Vector3(0.4,0.35,1.6)),matrix:transformPosition(Vector3(0.4,1,1.8))},
					{matrix:transformPosition(Vector3(0,0.35,1.6)),matrix:transformPosition(Vector3(0,1,1.8))},
					{matrix:transformPosition(Vector3(-0.4,0.35,1.6)),matrix:transformPosition(Vector3(-0.4,1,1.8))},
					{matrix:transformPosition(Vector3(-0.8,0.35,1.6)),matrix:transformPosition(Vector3(-0.8,1,1.8))},
					{matrix:transformPosition(Vector3(-1.2,0.35,1.6)),matrix:transformPosition(Vector3(-1.2,1,1.8))},
					{matrix:transformPosition(Vector3(1.2,0.35,1.2)),matrix:transformPosition(Vector3(1.2,1,1.4))},
					{matrix:transformPosition(Vector3(0.8,0.35,1.2)),matrix:transformPosition(Vector3(0.8,1,1.4))},
					{matrix:transformPosition(Vector3(0.4,0.35,1.2)),matrix:transformPosition(Vector3(0.4,1,1.4))},
					{matrix:transformPosition(Vector3(0,0.35,1.2)),matrix:transformPosition(Vector3(0,1,1.4))},
					{matrix:transformPosition(Vector3(-0.4,0.35,1.2)),matrix:transformPosition(Vector3(-0.4,1,1.4))},
					{matrix:transformPosition(Vector3(-0.8,0.35,1.2)),matrix:transformPosition(Vector3(-0.8,1,1.4))},
					{matrix:transformPosition(Vector3(-1.2,0.35,1.2)),matrix:transformPosition(Vector3(-1.2,1,1.4))},

			} 
		
		streamedShelves[source] = {element = source,pos = _pos}
		--{toward = _toward,pos = _pos}
	end	
end)

addEventHandler("onClientElementStreamOut", root, function()
	if source:getData("shop >> shopObject") then
		streamedShelves[source] = nil
	end	
end)


addEventHandler("onClientColShapeLeave", root, function(hit, md)
	if(hit == localPlayer and md) then
		if(source:getData("shop >> id")) then
			playerShop = false
			removeEventHandler("onClientClick", root, shopClick)
			cartWeight = 0
			playerCart = {}
			if(isElement(localPlayer:getData("shop >> basket"))) then
				triggerServerEvent("destroyBasket", resourceRoot)
				isCart = false
			end
			if(isTimer(refreshTimer)) then
				killTimer(refreshTimer)
			end
			renderTarget = false
			nearbyShelf = false
		end
	end
end)

addEvent("clearBasket", true)
addEventHandler("clearBasket", resourceRoot, function() 
	playerCart = {}
	cartWeight = 0
end)


function dxDrawRoundedRectangle(left, top, width, height, color, color2)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;
    dxDrawRectangle(left - 2, top, 2, height, color2, postgui);
	dxDrawRectangle(left + width, top, 2, height, color2, postgui);
	dxDrawRectangle(left, top - 2, width, 2, color2, postgui);
	dxDrawRectangle(left, top + height, width, 2, color2, postgui);

	dxDrawRectangle(left - 1, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left - 1, top + height, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top + height, 1, 1, color2, postgui)
	dxDrawRectangle(left,top,width,height,color)
end
