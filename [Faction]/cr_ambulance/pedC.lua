local screenW, screenH = guiGetScreenSize();
local sx, sy = guiGetScreenSize();
local selected

local renderDatas = {
	--request panel
	opened = false,

	left = screenW / 2 - 200,
	top = screenH / 2 - 100,
	width = 400,
	height = 200,

	--itemshow
	showcard = false,

	ileft = screenW / 2 - 204,
	itop = screenH / 2 - 124,
	iwidth = 408,
	iheight = 248,
};

local colors = {
	bg = tocolor(0, 0, 0, 180),
	slot = tocolor(40, 40, 40, 200),
	hover = tocolor(255, 153, 51, 180),
	second = tocolor(74, 158, 222, 180),
	cancel = tocolor(243, 85, 85, 180),
	white = tocolor(255, 255, 255),
	black = tocolor(0, 0, 0),
	orangehex = "#ff9933",
};

local cardPed = Ped(107, 1183.2250976563, -1326.4635009766, 13.574112892151);
setElementData(cardPed, "ped.name", "Joe Black");
setElementData(cardPed, "ped.type", "Mentőszolgálat - Helyi ügyintéző");
setElementData(cardPed, "char >> noDamage", true);
cardPed.frozen = true;

local cardPed2 = Ped(107, -2661.7424316406, 637.06030273438, 14.453125);
setElementData(cardPed2, "ped.name", "Black Joe");
setElementData(cardPed2, "ped.type", "Mentőszolgálat - Helyi ügyintéző");
setElementData(cardPed2, "char >> noDamage", true);
cardPed2.frozen = true;

addEventHandler("onClientRender", root, function()
	if renderDatas.opened then
            
        if getDistanceBetweenPoints3D(localPlayer.position, cardPed.position) > 2 and getDistanceBetweenPoints3D(localPlayer.position, cardPed2.position) > 2 or localPlayer:getData("char >> tazed") then
            renderDatas.opened = false
        end

        local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
        local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
        local white = "#ffffff"
        local w,h = 300, 200
        local x,y = sx/2 - w/2, sy/2 - h/2
        local color = exports['cr_core']:getServerColor(nil, true)
        dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
        dxDrawText("Megszeretnéd gyógyítatni magadat? \n"..color..tonumber(50)..white.."$-ba(be) fog kerülni!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)

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
end);

addEventHandler("onClientKey", root, function(key, pressed)
	if key == "backspace" and pressed then
		if renderDatas.opened then
			renderDatas.opened = false;
		end
	end
end);

addEventHandler("onClientClick", root, function(button, state, x, y, wx, wy, wz, element)
	if button == "left" and state == "down" and element and element == cardPed or button == "left" and state == "down" and element and element == cardPed2 then
		if not renderDatas.opened then
			if getDistanceBetweenPoints3D(localPlayer.position, element.position) <= 2 and not localPlayer:getData("char >> tazed") then
                local bone = localPlayer:getData("char >> bone") or {true, true, true, true, true}
                if not bone[1] or not bone[2] or not bone[3] or not bone[4] or not bone[5] or localPlayer.health < 100 then
                    renderDatas.opened = true;
                    return
                else
                    exports['cr_infobox']:addBox("error", "Semmid sincs megsérülve!")
                end
			end
		end
	end

	if button == "left" and state == "down" and renderDatas.opened then
		if selected == 1 then
			if exports.cr_core:takeMoney(localPlayer, 50, false) then
                triggerServerEvent("health - give", localPlayer, localPlayer, true);
                renderDatas.opened = false;
                localPlayer:setData("char >> bone", {true, true, true, true, true})
                
                exports.cr_infobox:addBox("success", "Sikeres gyógyítás");
			else
                exports.cr_infobox:addBox("error", "Nincs elég pénzed");
			end
		end

		if selected == 2 then
			renderDatas.opened = false;
		end
        
        selected = nil
	end
end);

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