local progressbars = {};
local bars = {};
local sx, sy = guiGetScreenSize();

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

function renderProgressbars()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	local x,y,w,h = sx/2-600/2, sy - 80 - 30, 600, 30
	for i, v in pairs(progressbars) do
		local now = getTickCount()
		local elapsedTime = now - v["start"]
		local duration = v["end"] - v["start"]
		local progress = elapsedTime / duration
		local posX, posY = interpolateBetween(0, 0, 0, w, 0, 0, progress, "OutQuad")
		dxDrawRectangle(x,y,w,h, tocolor(0, 0, 0, 175))
		dxDrawRectangle(x,y, posX, h, v["color"])
		dxDrawText(v["text"], x,y,x+w,y+h, tocolor(255, 255, 255, 255), 0.8, font, "center", "center", false, false, true, true)
		if(progress >= 1.00625) then
			deleteProgressbar(v["name"])
		end
	end
end

function createProgressbar(name, color, text, time)
	progressbars[name] = {
		["color"] = color,
		["text"] = text,
		["start"] = getTickCount(),
		["end"] = getTickCount()+time,
	}
	-- if(#progressbars == 1) then
		addEventHandler("onClientRender", root, renderProgressbars, true, "low-5")
	-- end
end

function deleteProgressbar(name)
	if(progressbars[name]) then
		for i, v in pairs(progressbars) do
			if(i == name) then
				v = nil
			end
		end
	end
	if(#progressbars == 0) then
		removeEventHandler("onClientRender", root, renderProgressbars)
		progressbars = {}
	end
end

function renderBars()
	local font = exports['cr_fonts']:getFont("Roboto", 10)
	local x,y,w,h = sx/2-600/2, sy - 80 - 30, 600, 30
	for i, v in pairs(bars) do
		if(v["value"] ~= v["newValue"]) then
			local now = getTickCount()
			local elapsedTime = now - v["start"]
			local duration = v["end"] - v["start"]
			local progress = elapsedTime / duration
			v["value"] = interpolateBetween(v["value"], 0, 0, v["newValue"], 0, 0, progress, "OutQuad")
		end
		dxDrawRectangle(x,y,w,h, tocolor(0, 0, 0, 175))
		dxDrawRectangle(x,y, (w/100*v["value"]), h, v["color"])
		dxDrawText(tostring(math.floor(v["value"])).."%", x,y,x+w,y+h, tocolor(255, 255, 255, 255), 0.8, font, "center", "center", false, false, true, true)
		if((v["max"]/100)*v["value"] >= 100) then
			deleteBar(v["name"])
		end
	end
end

function createBar(name, color, value, max)
	bars[name] = {
		["color"] = color,
		["value"] = 0,
		["newValue"] = value,
		["max"] = max,
		["start"] = getTickCount(),
		["end"] = getTickCount()+500,
	}
	-- if(#bars == 1) then
		addEventHandler("onClientRender", root, renderBars, true, "low-5")
	-- end
end

function updateBar(name, newValue)
	if(bars[name]) then
		bars[name]["newValue"] = tonumber(newValue)
		bars[name]["start"] = getTickCount()
		bars[name]["end"] = getTickCount()+500
	end
end

function deleteBar(name)
	if(bars[name]) then
		for i, v in pairs(bars) do
			if(i == name) then
				v = nil
			end
		end
	end
	if(#bars == 0) then
		removeEventHandler("onClientRender", root, renderBars)
		bars = {}
	end
end