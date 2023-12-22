local screenW, screenH = guiGetScreenSize();

local markers = {
	
}

local colors = {
	bg = tocolor(0, 0, 0, 180),
	slot = tocolor(40, 40, 40, 200),
	hover = tocolor(255, 153, 51, 180),
	second = tocolor(74, 158, 222, 180),
	cancel = tocolor(243, 85, 85, 180),
	white = tocolor(255, 255, 255),
	black = tocolor(0, 0, 0),
};

local fonts = {
	title = exports.cr_fonts:getFont("Roboto.ttf", 12),
	normal = exports.cr_fonts:getFont("Roboto.ttf", 9),
	awesome = exports.cr_fonts:getFont("AwesomeFont2", 9),
};

local _dxDrawRectangle = dxDrawRectangle;
local dxDrawRectangle = function(left, top, width, height, color, postgui)
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

function dxDrawButton(left, top, width, height, color, title, hovertitle, font)
	dxDrawRectangle(left, top, width, height, color);

	if isCursorHover(left, top, width, height) then
		dxDrawText(hovertitle, left, top, left + width, top + height, colors.black, 1, font, "center", "center");
	else
		dxDrawText(title, left, top, left + width, top + height, colors.white, 1, font, "center", "center");
	end
end

function isCursorHover(startX, startY, width, height)
	if isCursorShowing() then
		local cursorX, cursorY = getCursorPosition();
		cursorX, cursorY = cursorX * screenW, cursorY * screenH;

		if cursorX >= startX and cursorX <= startX + width and cursorY >= startY and cursorY <= startY + height then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

----
function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false;
	end

	local radius = radius or 1;
	local radius2 = radius / math.sqrt(2);
	local width = width or 1;
	local color = color or tocolor(255, 255, 255, 150);

	point = {}

	for i = 1, 8 do
		point[i] = {};
	end

	point[1].x = x;
	point[1].y = y - radius;
	point[2].x = x + radius2;
	point[2].y = y - radius2;
	point[3].x = x + radius;
	point[3].y = y;
	point[4].x = x + radius2;
	point[4].y = y + radius2;
	point[5].x = x;
	point[5].y = y + radius;
	point[6].x = x - radius2;
	point[6].y = y + radius2;
	point[7].x = x - radius;
	point[7].y = y;
	point[8].x = x - radius2;
	point[8].y = y - radius2;
		
	for i = 1, 8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x, point[i].y, z, point[i + 1].x, point[i + 1].y, z;
		else
			x, y, z, x2, y2, z2 = point[i].x, point[i].y, z, point[1].x, point[1].y, z;
		end

		dxDrawLine3D(x, y, z, x2, y2, z2, color, width);
	end

	return true;
end

--local material = dxCreateTexture("assets/image/image.png")

function drawnOctagon()
    for gMarker, v in pairs(renderCache) do 
        local x, y, z = getElementPosition(gMarker);
        cx, cy, cz = x, y, z + 3;

        local r, g, b = v[1], v[2], v[3];
        if r == 51 and g == 255 and b == 51 then
            z = z + 0.05;
        end

        local now = getTickCount();
        local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve");

        dxDrawOctagon3D(x, y, z, 0.8, 3, tocolor(r, g, b, alpha));
        z = z + multipler;

        dxDrawImage3D(x, y, z + 2, 1, 1, material, tocolor(r, g, b, alpha));
    end
end

setTimer(function()
    renderCache = {}
    last = nil
    for element, value in pairs(cache) do
        if isElement(element) and isElementStreamedIn(element) then
            local int, dim = value["int"], value["dim"]
            local localInt, localDim = getElementInterior(localPlayer), getElementDimension(localPlayer)
            if int == localInt and dim == localDim then
                local maxDistance = 60
                local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
                if distance <= maxDistance then
                    local r,g,b = unpack(types[value["color"]])
                    local interiorOwner = getElementData(element, "interior >> owner")
				    if not interiorOwner or interiorOwner == 0 then
                        if value["color"] <= 3 then
                            r,g,b = 51,255,51
                        end
                    end
                        
                    renderCache[element] = {r,g,b}
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
end, 300, 0);