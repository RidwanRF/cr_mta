local sx, sy = guiGetScreenSize();

local getFont = function(font, size)
	return exports.cr_fonts:getFont(font, math.floor(size));
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

function getVehicles()
	local vehs = {}
	for i, v in pairs(getElementsByType("vehicle")) do
		if(v:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
			table.insert(vehs, v)
		end
	end
	return vehs
end

function getInteriors()
	local interiors = {}
	for i, v in pairs(getElementsByType("marker")) do
		if(v:getData("interior >> name") and v:getData("interior >> owner") == localPlayer:getData("acc >> id")) then
			table.insert(interiors, v)
		end
	end
	return interiors
end

addEventHandler("onClientElementDataChange", root, function(k, o, n) 
	if(source == localPlayer) then
		if(k == "char >> playedtime") then
			if(tonumber(o) and tonumber(o or 0)+1 == tonumber(n)) then
				local hours = n/60
				if(hours == math.floor(hours) and math.floor(hours) >= 1) then
					triggerServerEvent("payDay", localPlayer, localPlayer, getVehicles(), getInteriors())
				end
			end
		end
	end
end)

addCommandHandler("testpayday", function() 
	triggerServerEvent("payDay", localPlayer, localPlayer, getVehicles(), getInteriors())
end)

local sumaryDetails = {};
function renderSumary()
	local font = getFont("Rubik-Regular", 13)
	local w, h = 275, 30+(#sumaryDetails["infos"]+1)*27.5
	local x, y = sx/2-w/2, -sy/2-h/2
	local fontsize = 0.65
	local now = getTickCount()
	local elapsedTime = now-sumaryDetails["start"]
	local duration = sumaryDetails["end"]-sumaryDetails["start"]
	local progress = elapsedTime/duration
	if(not sumaryDetails["hide"]) then
		y = interpolateBetween(y, 0, 0, sy/2-h/2, 0, 0, progress, "OutBack")
	else
		elapsedTime = now-sumaryDetails["start2"]
		duration = sumaryDetails["end2"]-sumaryDetails["start2"]
		progress = elapsedTime/duration
		y = interpolateBetween(sy/2-h/2, 0, 0, -sy/2-h/2, 0, 0, progress, "OutBack")
	end
	
	-- Panel body
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 175))
	-- Panel title
	dxDrawRectangle(x, y, w, 35, tocolor(0, 0, 0, 175))
	dxDrawText("Fizetés", x, y, x+w, y+35, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, true, true)
	-- Panel content
	for i=0, #sumaryDetails["infos"]-1 do
		dxDrawRectangle(x+2.5, y+37.5+(i*27.5), w-5, 25, tocolor(0, 0, 0, 175))
		dxDrawText(sumaryDetails["infos"][i+1], x+2.5, y+37.5+(i*27.5), x+w-5, y+37.5+(i*27.5)+25, tocolor(255, 255, 255, 255), fontsize, font, "center", "center", false, false, true, true)
	end
	
	-- Progressbar
	dxDrawRectangle(x+5, y+h-20, w-10, 15, tocolor(0, 0, 0, 175))
	if(sumaryDetails["pressed"]) then
		local elapsedTime2 = now-sumaryDetails["keyStart"]
		local duration2 = sumaryDetails["keyStop"]-sumaryDetails["keyStart"]
		local progress2 = elapsedTime2/duration2
		local p = interpolateBetween(0, 0, 0, 100, 0, 0, progress2, "Linear")
		dxDrawRectangle(x+5, y+h-20, ((w-10)/100)*p, 15, tocolor(255, 153, 51, 175))
		dxDrawText("Bezárás...", x+5, y+h-20, x+w-10, y+h-20+15, tocolor(255, 255, 255, 255), fontsize, font, "center", "center", false, false, true, true)
	else
		dxDrawText("A bezáráshoz használd a '#FF9933BACKSPACE#FFFFFF' billentyűt!", x+5, y+h-20, x+w-10, y+h-20+15, tocolor(255, 255, 255, 255), fontsize, font, "center", "center", false, false, true, true)
	end
	
end

local timerHandler = nil;
function sumaryKeys(key, state)
	if(key == "backspace") then
		if(state) then
			sumaryDetails["pressed"] = true
			sumaryDetails["keyStart"] = getTickCount()
			sumaryDetails["keyStop"] = getTickCount()+2000
			timerHandler = setTimer(function() 
				sumaryDetails["hide"] = true
				sumaryDetails["start2"] = getTickCount()
				sumaryDetails["end2"] = getTickCount()+750
				removeEventHandler("onClientKey", root, sumaryKeys)
				triggerServerEvent("payTotal", localPlayer, localPlayer, sumaryDetails["total"])
				setTimer(function() 
					sumaryDetails = {}
					removeEventHandler("onClientRender", root, renderSumary)
				end, 750, 1)
			end, 2000, 1)
		else
			if(sumaryDetails["pressed"]) then
				sumaryDetails["pressed"] = false
			end
			if(isTimer(timerHandler)) then
				killTimer(timerHandler)
			end
		end
	end
end

addEvent("showSumary", true)
addEventHandler("showSumary", root, function(totalSalary, salary, relief, interiorTaxes, vehicleTaxes) 
	local sound = playSound("notification.mp3")
	setSoundVolume(sound, 0.5)
	sumaryDetails = {
		["total"] = totalSalary,
		["infos"] = {"Állami segély: #FF9933$"..relief, "Fizetés: #FF9933$"..salary, "Jármű adó: #FF9933$"..vehicleTaxes, "Ingatlan adó: #FF9933$"..interiorTaxes, "Összesen: #FF9933"..(tonumber(totalSalary) > 0 and "$"..totalSalary or "-$".. ((-1)*tonumber(totalSalary)))},
		["start"] = getTickCount(),
		["end"] = getTickCount()+500,
		["hide"] = false,
		["pressed"] = false,
		["start2"] = 0,
		["end2"] = 0,
		["keyStart"] = 0,
		["keyStop"] = 0,
	}
	addEventHandler("onClientRender", root, renderSumary)
	addEventHandler("onClientKey", root, sumaryKeys)
end)