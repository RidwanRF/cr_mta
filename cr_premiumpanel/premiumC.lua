local screenW, screenH = guiGetScreenSize();

local renderDatas = {
	opened = false,
	selected = 1,

	panel = {
		left = screenW / 2 - 750 / 2,
		top = screenH / 2 - 500 / 2,
		width = 750,
		height = 500,

		menuWidth = 750 / 3,
		menus = {" Fegyverek / töltények", " Pénz", " Item kártyák"},
	},
};

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
	title = dxCreateFont("files/Roboto.ttf", 12),
	normal = dxCreateFont("files/Roboto.ttf", 9),
	awesome = dxCreateFont(":cr_fonts/files/FontAwesome.otf", 10),
};

addEventHandler("onClientRender", root, function()
	if renderDatas.opened then
		dxDrawWindow(renderDatas.panel.left, renderDatas.panel.top, renderDatas.panel.width, renderDatas.panel.height, colors.bg, "Prémium panel", fonts.title);
	
		for key, value in pairs(renderDatas.panel.menus) do
			local forX = renderDatas.panel.left + (key - 1) * renderDatas.panel.menuWidth;

			dxDrawText(value, forX, renderDatas.panel.top + 32, forX + renderDatas.panel.menuWidth, renderDatas.panel.top + 57, colors.white, 1, fonts.awesome, "center", "center");
		end
	end
end);

addEventHandler("onClientKey", root, function(button, pressed)
	if pressed then
		if button == "F6" then
			renderDatas.opened = not renderDatas.opened;

			if renderDatas.opened then
				renderDatas.selected = 1;
			end
		end
	end
end);

function dxDrawWindow(left, top, width, height, color, title, font)
	dxDrawRectangle(left, top, width, 30, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left - 1, top, 1, height, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left + width, top, 1, height, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left - 1, top + height, width + 2, 1, tocolor(0, 0, 0, 220));

	dxDrawRectangle(left, top + 30, width,  height - 30, color);

	dxDrawText(title, left, top, left + width, top + 30, colors.white, 1, font, "center", "center");
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