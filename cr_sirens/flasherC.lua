local screenW, screenH = guiGetScreenSize();

local renderDatas = {
	width = 230,
	height = 80,
	left = screenW / 2 - 125,
	top = screenH / 2 - 30,

	offset = {move = false, x = 0, y = 0},
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
};

local sirenCars = {
    --[carid] = {sirentype 1/2/3 rendőr mentő tűzoltó}
    [416] = 2,
    [427] = 1,
    [596] = 1,
    [597] = 1,
    [598] = 1,
    [599] = 1,
};

local flasherPos = {
	[551] = {-0.45, -0.14, 0.78}, -- BMW M5
	[579] = {-0.6, -0.01, 1.08}, --G65
	[426] = {-0.45, -0.14, 0.84}, -- crown vic
	[492] = {-0.4, -0.02, 0.75}, -- Bmw M5 regi
	[585] = {-0.45, -0.14, 0.84}, -- rs4
	[413] = {-0.6, 0.3, 0.94}, -- ford ecoline
	[604] = {-0.6, 0.2, 1.02}, -- meg kerdeses
	[436] = {-0.45, -0.14, 0.62}, -- ford mustang
	[559] = {-0.45, -0.14, 0.77}, -- ford focus
	[467] = {-0.45, -0.01, 0.73}, -- seat leon
	[580] = {-0.45, -0.1, 0.845}, -- dodge srt
	[565] = {-0.45, -0.01, 0.78}, -- vw gti
};

local horns = {};
local sirens = {};
local sounds = {};
local sounds3d = {};

function createSiren()
	if localPlayer.vehicle and flasherPos[localPlayer.vehicle.model] then
		triggerServerEvent("flasher->ChangeState", localPlayer, localPlayer, flasherPos[localPlayer.vehicle.model]);
	end

	if localPlayer.vehicle and not flasherPos[localPlayer.vehicle.model] then
		exports.cr_infobox:addBox("error", "Erre az autóra nem szerelheted fel");
	end
end

addEventHandler("onClientRender", root, function()
	if localPlayer.vehicle and (sirenCars[localPlayer.vehicle.model] or (flasherPos[localPlayer.vehicle.model] and getElementData(localPlayer.vehicle, "sirens->State"))) then
		dxDrawWindow(renderDatas.left, renderDatas.top, renderDatas.width, renderDatas.height, colors.bg, "Sziréna panel", fonts.title)

		if getElementData(localPlayer.vehicle, "sirens->Flasher") then
			dxDrawImage(renderDatas.left + 5, renderDatas.top + 35, 40, 40, "files/light.png", 0, 0, 0, unpack({getVehicleHeadLightColor(localPlayer.vehicle)}) == 255 and colors.cancel or colors.second);
		elseif isCursorHover(renderDatas.left + 5, renderDatas.top + 35, 40, 40) then
			dxDrawImage(renderDatas.left + 5, renderDatas.top + 35, 40, 40, "files/light.png", 0, 0, 0, colors.hover);
		else
			dxDrawImage(renderDatas.left + 5, renderDatas.top + 35, 40, 40, "files/light.png");
		end

		for index = 1, 3 do
			if sounds[localPlayer.vehicle] == index then
				dxDrawImage(renderDatas.left + 5 + index * 45, renderDatas.top + 35, 40, 40, "files/sound_on.png", 0, 0, 0, colors.cancel);
			elseif isCursorHover(renderDatas.left + 5 + index * 45, renderDatas.top + 35, 40, 40) then
				dxDrawImage(renderDatas.left + 5 + index * 45, renderDatas.top + 35, 40, 40, "files/sound_on.png", 0, 0, 0, colors.second);
			else
				dxDrawImage(renderDatas.left + 5 + index * 45, renderDatas.top + 35, 40, 40, "files/sound_on.png");
			end
		end

		if isCursorHover(renderDatas.left + 5 + 4 * 45, renderDatas.top + 35, 40, 40) then
			dxDrawImage(renderDatas.left + 5 + 4 * 45, renderDatas.top + 35, 40, 40, "files/sound_off.png", 0, 0, 0, colors.cancel);
		else
			dxDrawImage(renderDatas.left + 5 + 4 * 45, renderDatas.top + 35, 40, 40, "files/sound_off.png");
		end
	
		if isCursorShowing() and renderDatas.offset.move then
			renderDatas.left = Vector2(getCursorPosition()).x * screenW - renderDatas.offset.x;
			renderDatas.top = Vector2(getCursorPosition()).y * screenH - renderDatas.offset.y;
		end
	end
end);

addEventHandler("onClientKey", root, function(button, pressed)
	if localPlayer.vehicle and (sirenCars[localPlayer.vehicle.model] or flasherPos[localPlayer.vehicle.model] and getElementData(localPlayer.vehicle, "sirens->State")) then
		if button == "h" and not isChatBoxInputActive() then
			if pressed then
				cancelEvent();

			    if not isElement(horns[localPlayer.vehicle]) then
				    horns[localPlayer.vehicle] = playSound3D("files/horn.wav", unpack({localPlayer.vehicle.position}), true);
				    setSoundMaxDistance(horns[localPlayer.vehicle], 150);
				    attachElements(horns[localPlayer.vehicle], localPlayer.vehicle);
				end
			else
				if isElement(horns[localPlayer.vehicle]) then
					destroyElement(horns[localPlayer.vehicle]);
				end
			end
		end

		if button == "mouse1" then
			if pressed and isCursorHover(renderDatas.left, renderDatas.top, renderDatas.width, 30) then
				renderDatas.offset = {move = true, x = Vector2(getCursorPosition()).x * screenW - renderDatas.left, y = Vector2(getCursorPosition()).y * screenH - renderDatas.top};
			else
				renderDatas.offset = {move = false, x = 0, y = 0};
			end
		end

		if button == "mouse1" and pressed then
			if isCursorHover(renderDatas.left + 5, renderDatas.top + 35, 40, 40) then
				if localPlayer.vehicleSeat <= 1 then
					setElementData(localPlayer.vehicle, "sirens->Flasher", not getElementData(localPlayer.vehicle, "sirens->Flasher"));
				end
			end

			for index = 1, 3 do
				if isCursorHover(renderDatas.left + 5 + index * 45, renderDatas.top + 35, 40, 40) then
					if getElementData(localPlayer.vehicle, "sirens->Sound") == index then
						setElementData(localPlayer.vehicle, "sirens->Sound", 0);
					else
						setElementData(localPlayer.vehicle, "sirens->Sound", index);
					end
				end
			end

			if isCursorHover(renderDatas.left + 5 + 4 * 45, renderDatas.top + 35, 40, 40) then
				setElementData(localPlayer.vehicle, "sirens->Sound", 0);
			end
		end
	end
end);

addEventHandler("onClientElementDataChange", root, function(data)
	if data == "sirens->Flasher" then
		if getElementData(source, data) then
			sirens[source] = true;

			setElementData(source, "veh >> lightDamage", {
				getVehicleLightState(source, 0);
				getVehicleLightState(source, 1);
				getVehicleLightState(source, 2);
				getVehicleLightState(source, 3);		
			});

			setElementData(source, "veh >> light", true);

			setVehicleLightState(source, 0, 0);
			setVehicleLightState(source, 1, 0);
			setVehicleLightState(source, 2, 0);
			setVehicleLightState(source, 3, 0);

			source.sirensOn = true;
		else
			if sirens[source] then
				sirens[source] = nil;
			end

			source.sirensOn = false;

			setVehicleLightState(source, 0, getElementData(source, "veh >> lightDamage")[1]);
			setVehicleLightState(source, 1, getElementData(source, "veh >> lightDamage")[2]);
			setVehicleLightState(source, 2, getElementData(source, "veh >> lightDamage")[3]);
			setVehicleLightState(source, 3, getElementData(source, "veh >> lightDamage")[4]);

			setVehicleHeadLightColor(source, 255, 255, 255);
		end
	end

	if data == "sirens->State" and not getElementData(source, data) then
		sounds[source] = 0;
		
		if isElement(sounds3d[source]) then
			destroyElement(sounds3d[source]);
		end	
	end

	if data == "sirens->Sound" then
		if getElementData(source, data) == 0 then
			sounds[source] = 0;

			if isElement(sounds3d[source]) then
				destroyElement(sounds3d[source]);
			end
		else
			if isElement(sounds3d[source]) then
				destroyElement(sounds3d[source]);
			end

			sounds[source] = getElementData(source, data);

			sounds3d[source] = playSound3D("files/siren" .. getElementData(source, data) .. ".wav", unpack({source.position}), true);
			setSoundMaxDistance(sounds3d[source], 150);
			attachElements(sounds3d[source], source);
		end
	end
end);

addEventHandler("onClientElementDestroy", root, function()
	if sirens[source] then
		sirens[source] = 0;
	end

	if isElement(sounds3d[source]) then
		destroyElement(sounds3d[source]);
	end
end);

setTimer(function()
	for vehicle, value in pairs(sirens) do
		if not isElement(vehicle) then
			sirens[vehicle] = nil;
		end

		if value and isElement(vehicle) then
			local state = getVehicleLightState(vehicle, 0);

			if state == 0 then
				setVehicleHeadLightColor(vehicle, 0, 0, 255);
			else
				setVehicleHeadLightColor(vehicle, 255, 0, 0);
			end

			setVehicleLightState(vehicle, 0, 1 - state);
			setVehicleLightState(vehicle, 1, state);
			setVehicleLightState(vehicle, 2, 1 - state);
			setVehicleLightState(vehicle, 3, state);
		else
			sirens[vehicle] = nil
		end
	end
end, 150, 0);

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