local screenW, screenH = guiGetScreenSize();

local renderDatas = {
	width = 320,
	height = 80,
	left = screenW / 2 - 125,
	top = screenH / 2 - 30,

	payPrice = 0,

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
	counter = dxCreateFont("files/Counter.ttf", 18),
};

local lampPos = {
	[426] = {-0.2, -0.14, 0.93, 0, 0, -90}, -- crown vic
};

local _outputChatBox = outputChatBox;
local outputChatBox = function(str)
	_outputChatBox(exports.cr_core:getServerSyntax("Taxi", "lightyellow") .. str, 0, 0, 0, true);
end

function createLamp()
	if localPlayer.vehicle and lampPos[localPlayer.vehicle.model] then
		triggerServerEvent("lamp->ChangeState", localPlayer, localPlayer, lampPos[localPlayer.vehicle.model]);
	end

	if localPlayer.vehicle and not lampPos[localPlayer.vehicle.model] then
		exports.cr_infobox:addBox("error", "Erre az autóra nem szerelheted fel");
	end
end

function calculatePrice()
	if getElementData(localPlayer.vehicle, "taxi->MeterOn") then
		local km = math.floor(getElementData(localPlayer.vehicle, "veh >> odometer")) - math.floor(getElementData(localPlayer.vehicle, "taxi->MeterState"));
		local price = km * 2;
		local str = "";

		for key = 1, 8 - #tostring(price) do
			str = str .. "0";
		end

		return price == 0 and "00000000" or str .. "#f35555" .. price;
	else
		return "00000000";
	end
end

addEventHandler("onClientRender", root, function()
	if localPlayer.vehicle and lampPos[localPlayer.vehicle.model] and getElementData(localPlayer.vehicle, "lamps->State") then
		dxDrawWindow(renderDatas.left, renderDatas.top, renderDatas.width, renderDatas.height, colors.bg, "Taximeter - KM díj: $2" , fonts.title);

		if localPlayer.vehicleSeat == 0 then
			dxDrawRectangle(renderDatas.left + 5, renderDatas.top + 35, 200, renderDatas.height - 40, colors.slot);
			dxDrawText(calculatePrice(), renderDatas.left + 5, renderDatas.top + 35, renderDatas.left + 205, renderDatas.top + renderDatas.height - 5, colors.white, 1, fonts.counter, "center", "center", false, false, false, true);

			if getElementData(localPlayer.vehicle, "taxi->MeterOn") then
				dxDrawButton(renderDatas.left + 210, renderDatas.top + 35, 105, 20, colors.cancel, "Leállítás", "Leállítás", fonts.normal);
			else
				dxDrawButton(renderDatas.left + 210, renderDatas.top + 35, 105, 20, colors.hover, "Indítás", "Indítás", fonts.normal);
			end

			dxDrawButton(renderDatas.left + 210, renderDatas.top + 55, 105, 20, colors.second, "Csekk kiadás", "Csekk kiadás", fonts.normal);
		else
			dxDrawRectangle(renderDatas.left + 5, renderDatas.top + 35, renderDatas.width - 10, renderDatas.height - 40, colors.slot);
			dxDrawText(calculatePrice(), renderDatas.left, renderDatas.top + 30, renderDatas.left + renderDatas.width, renderDatas.top + renderDatas.height, colors.white, 1, fonts.counter, "center", "center", false, false, false, true);
		end
			
		if getElementData(localPlayer, "taxi->NeedPay") and isElement(getElementData(localPlayer, "taxi->NeedPay").driver) then
			dxDrawButton(renderDatas.left - 1, renderDatas.top + renderDatas.height + 5, renderDatas.width + 2, 30, colors.second, "Fizetés", "Fizetés", fonts.title);
		end

		if isCursorShowing() and renderDatas.offset.move then
			renderDatas.left = Vector2(getCursorPosition()).x * screenW - renderDatas.offset.x;
			renderDatas.top = Vector2(getCursorPosition()).y * screenH - renderDatas.offset.y;
		end
	end
end);

addEventHandler("onClientKey", root, function(button, pressed)
	if localPlayer.vehicle and lampPos[localPlayer.vehicle.model] and getElementData(localPlayer.vehicle, "lamps->State") then
		if button == "mouse1" then
			if pressed and isCursorHover(renderDatas.left, renderDatas.top, renderDatas.width, 30) then
				renderDatas.offset = {move = true, x = Vector2(getCursorPosition()).x * screenW - renderDatas.left, y = Vector2(getCursorPosition()).y * screenH - renderDatas.top};
			else
				renderDatas.offset = {move = false, x = 0, y = 0};
			end
		end

		if pressed then
			if button == "mouse1" and localPlayer.vehicleSeat == 0 then
				if isCursorHover(renderDatas.left + 210, renderDatas.top + 35, 105, 20) then
					setElementData(localPlayer.vehicle, "taxi->MeterOn", not getElementData(localPlayer.vehicle, "taxi->MeterOn"));

					if getElementData(localPlayer.vehicle, "taxi->MeterOn") then
						setElementData(localPlayer.vehicle, "taxi->MeterState", math.floor(getElementData(localPlayer.vehicle, "veh >> odometer")));
					else
						renderDatas.payPrice = (math.floor(getElementData(localPlayer.vehicle, "veh >> odometer")) - math.floor(getElementData(localPlayer.vehicle, "taxi->MeterState"))) * 2;
					end
				end

				if isCursorHover(renderDatas.left + 210, renderDatas.top + 55, 105, 20) then
					if getElementData(localPlayer.vehicle, "taxi->MeterOn") then
						exports.cr_infobox:addBox("error", "Előbb állítsd le az órát");
					else
						outputChatBox("Kiállítottál egy számlát " .. renderDatas.payPrice .. " dollár értékben");

						for key, value in pairs(localPlayer.vehicle.occupants) do
							if value ~= localPlayer then
								setElementData(value, "taxi->NeedPay", {driver = localPlayer, price = renderDatas.payPrice});
							end
						end
					end
				end
			end

			if button == "mouse1" and localPlayer.vehicleSeat ~= 0 then
				if getElementData(localPlayer, "taxi->NeedPay") and isElement(getElementData(localPlayer, "taxi->NeedPay").driver) then
					if isCursorHover(renderDatas.left - 1, renderDatas.top + renderDatas.height + 5, renderDatas.width + 2, 30) then
						if exports.cr_core:takeMoney(localPlayer, getElementData(localPlayer, "taxi->NeedPay").price, false) then
							exports.cr_infobox:addBox("Sikeresen kifizetted a taxit");

							exports.cr_core:giveMoney(getElementData(localPlayer, "taxi->NeedPay").driver, math.ceil(getElementData(localPlayer, "taxi->NeedPay").price * 0.3), false);
						
							for key, value in pairs(localPlayer.vehicle.occupants) do
								setElementData(value, "taxi->NeedPay", false);
							end
						else
							exports.cr_infobox:addBox("Nincs elég pénzed a taxi kifizetésére");
						end
					end
				end
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