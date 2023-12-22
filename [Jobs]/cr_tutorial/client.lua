local sx, sy = guiGetScreenSize();
local title = false;
local text = false;
local show = false;
local w, h = 250, 55;
local pX, pY = sx/2+275, 50;
local ft, st = "", 0

function isCursorHover(startX, startY, sizeX, sizeY)
    if(isCursorShowing()) then
        local cursorPosition = {getCursorPosition()}
        cursorPosition.x, cursorPosition.y = cursorPosition[1] * sx, cursorPosition[2] * sy

        if(cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY) then
            return true
        else
            return false
        end
    else
        return false
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

function breakLine(text)
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	local currentText = ""
	local ignoreNextChars = 0
	local lines = {};
	local words = {}
	local wordT = ""
	for i = 1, #text do
		local c = text:sub(i,i)
		wordT = wordT..c
		if(text:sub(i+1,i+1) == " ") then
			table.insert(words, wordT)
			wordT = ""
		end
	end
	table.insert(words, wordT)
	for i, v in pairs(words) do
		local width = dxGetTextWidth(currentText..v, 1, font, true)
		if(width >= w-20) then
			table.insert(lines, currentText)
			currentText = v
		else
			currentText = currentText..v
		end
	end
	table.insert(lines, currentText)
	for i, v in pairs(lines) do
		if(v:sub(1, 1) == " ") then
			lines[i] = v:sub(2, v:len())
		end
	end
	return table.concat(lines, "\n"), #lines-1
end

function renderTutorial()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
    local font2 = exports['cr_fonts']:getFont("gotham_light", 10)
    local font3 = exports['cr_fonts']:getFont("Roboto", 10)
	dxDrawRectangle(pX, pY, w, h+(st*18), tocolor(0, 0, 0, 175))
	dxDrawRectangle(pX, pY, w, 25, tocolor(0, 0, 0, 175))
	dxDrawText(title, pX, pY, pX+w, pY+25, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	dxDrawText(ft, pX+5, pY+30, 0, 0, tocolor(255, 255, 255, 255), 1, font, nil, nil, false, false, true, true)
end

local offsetX, offsetY
function panelMoveCursor(_, _, x, y)
	if(show) then
		pX, pY = x-offsetX, y-offsetY 
	end
end

function panelClick(b, s, absoluteX, absoluteY)
	if(show) then
		if(b == "left") then
			if(s == "down") then
				if(isCursorHover(pX, pY, w, 25)) then
					offsetX, offsetY = absoluteX-pX, absoluteY-pY
					addEventHandler("onClientCursorMove", root, panelMoveCursor)
				end
			else
				removeEventHandler("onClientCursorMove", root, panelMoveCursor)
			end
		end
	else
		removeEventHandler("onClientClick", root, panelClick)
	end
end

function showPanel(ti, te)
	title, text = ti, te
	ft, st = breakLine(text)
	if(not show) then
		show = true
		addEventHandler("onClientRender", root, renderTutorial)
		addEventHandler("onClientClick", root, panelClick)
	end
end

function hidePanel()
	if(show) then
		title, text, show = false, false, false
		ft, st = "", 0
		show = false
		removeEventHandler("onClientRender", root, renderTutorial)
		removeEventHandler("onClientClick", root, panelClick)
		removeEventHandler("onClientCursorMove", root, panelMoveCursor)
	end
end
