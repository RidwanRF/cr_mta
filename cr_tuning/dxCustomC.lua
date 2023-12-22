-->> CUSTOM DX FUNCTIONS

colors = {
	bg = tocolor(0, 0, 0, 180),
	slot = tocolor(40, 40, 40, 200),
	hover = tocolor(255, 153, 51, 180),
	second = tocolor(74, 158, 222, 180),
	cancel = tocolor(243, 85, 85, 180),
	white = tocolor(255, 255, 255),
	black = tocolor(0, 0, 0),
	orangehex = "#ff9933",
};

function getFont(font, size)
	return exports.cr_fonts:getFont(font, math.floor(size));
end

local _dxDrawRectangle = dxDrawRectangle;
function dxDrawRectangle(left, top, width, height, color, postgui)
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

function isCursorHover(startX, startY, width, height, multipler)
	if isCursorShowing() then
		local cursorX, cursorY = getCursorPosition();
		cursorX, cursorY = cursorX * screenW, cursorY * screenH;

		if not multipler then
			multipler = 1;
		end

		width = width * multipler;
		height = height * multipler;

		if cursorX >= startX and cursorX <= startX + width and cursorY >= startY and cursorY <= startY + height then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end