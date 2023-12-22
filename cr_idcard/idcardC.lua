local sx, sy = guiGetScreenSize();

local renderDatas = {
	--request panel
	opened = false,

	left = sx / 2 - 200,
	top = sy / 2 - 100,
	width = 400,
	height = 200,

	--itemshow
	showcard = false,

	img = dxCreateTexture("files/idcard.png", "dxt5", true, "clamp"),
	font = dxCreateFont("files/lunabar.ttf", 20),
	ileft = sx / 2 - 204,
	itop = sy / 2 - 124,
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

local cardPed = Ped(180, 1480.0194091797, -1785.7547607422, 18.25);
setElementData(cardPed, "ped.name", "Denzel Jackson");
setElementData(cardPed, "ped.type", "Okmányirodai dolgozó");
setElementData(cardPed, "char >> noDamage", true);
cardPed.frozen = true;

function changeCardState(json, id)
    if array then
        --outputChatBox(iprint(array))
        --outputChatBox(iprint(fromJSON(json)))
        if gID ~= id then
            exports['cr_infobox']:addBox("error", "Csak azt a személyigazolványt zárhatod be amelyiket megnyitottad, egyszerre kettőt pedig nem nyithatsz meg.")
            return
        end
    end
	renderDatas.showcard = not renderDatas.showcard;

	if renderDatas.showcard then
		array = json;
        gID = id
        exports['cr_chat']:createMessage(localPlayer, "elővesz egy személyi igazolványt", 1)
    else
        array = nil
        gID = nil
        exports['cr_chat']:createMessage(localPlayer, "elrak egy személyi igazolványt", 1)
	end
    
    return renderDatas.showcard
end

addEventHandler("onClientRender", root, function()
	if renderDatas.opened then
        if getDistanceBetweenPoints3D(localPlayer.position, cardPed.position) > 5 then
            renderDatas.opened = false
        end
            
		local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
        local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
        local white = "#ffffff"
        local w,h = 300, 200
        local x,y = sx/2 - w/2, sy/2 - h/2
        local color = exports['cr_core']:getServerColor(nil, true)
        dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
        dxDrawText("Szeretnél személyigazolványt igényelni? \n"..color..tonumber(25)..white.."$-ba(be) fog kerülni!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)

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

	if renderDatas.showcard then
		dxDrawImage(renderDatas.ileft, renderDatas.itop, renderDatas.iwidth, renderDatas.iheight, renderDatas.img);

		dxDrawText("Név: " .. array.name, renderDatas.ileft + 135, renderDatas.itop + 95, 0, 0, colors.white, 1, getFont("Rubik-Regular", 11));
		dxDrawText("\nAzonosító: " .. array.id, renderDatas.ileft + 135, renderDatas.itop + 95, 0, 0, colors.white, 1, getFont("Rubik-Regular", 11));
		dxDrawText("\n\n\nKiállítás dátuma: " .. array.start, renderDatas.ileft + 135, renderDatas.itop + 95, 0, 0, colors.white, 1, getFont("Rubik-Regular", 11));
		dxDrawText("\n\n\n\nÉrvenyesség: " .. array.expired, renderDatas.ileft + 135, renderDatas.itop + 95, 0, 0, colors.white, 1, getFont("Rubik-Regular", 11));
	
		dxDrawText("Aláírás", renderDatas.ileft + 25, renderDatas.itop + renderDatas.iheight - 50, 0, 0, colors.hover, 1, getFont("Rubik-Regular", 9));
		dxDrawText(array.name, renderDatas.ileft + 25, renderDatas.itop + renderDatas.iheight - 40, 0, 0, colors.white, 1, renderDatas.font);
	end
end);

addEventHandler("onClientKey", root, function(key, pressed)
	if key == "backspace" and pressed then
		if renderDatas.showcard then
			renderDatas.showcard = false;
		end
            
        if renderDatas.opened then
			renderDatas.opened = false;
		end
	end
end);

addEventHandler("onClientClick", root, function(button, state, x, y, wx, wy, wz, element)
	if button == "left" and state == "down" and element and element == cardPed then
		if not renderDatas.opened then
			if getDistanceBetweenPoints3D(localPlayer.position, element.position) <= 5 then
                local items = exports['cr_inventory']:getItems(localPlayer, 2)
                for k,v in pairs(items) do
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                    if itemid == 97 then
                        renderDatas.opened = true;    
                        return
                    end
                end
                    
                exports['cr_infobox']:addBox("error", "Ahhoz, hogy személyigazolványt tudj igényelni érvényes bankkártyádnak kell legyen!")
                return
			end
		end
	end

	if button == "left" and state == "down" and renderDatas.opened then
		if selected == 1 then
            local items = exports['cr_inventory']:getItems(localPlayer, 2)
            for k,v in pairs(items) do
                local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
                if itemid == 78 then
                    if value["id"] == localPlayer:getData("acc >> id") then
                        renderDatas.opened = false;
                        selected = nil
                        exports['cr_infobox']:addBox("error", "Már van személyigazolványod!")
                        return
                    end
                end
            end

			if exports.cr_core:takeMoney(localPlayer, 25, false) then
                    
				triggerServerEvent("idCard->Request", localPlayer, localPlayer);
				renderDatas.opened = false;

				exports.cr_infobox:addBox("success", "Sikeres igénylés");
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

function getFont(font, size)
	return exports.cr_fonts:getFont(font, math.floor(size));
end