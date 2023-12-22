screenW, screenH = guiGetScreenSize();

renderDatas = {
	opened = false,

	screenDatas = {},

	selection = false,
	page = 1,
	submenu = 1,
	tuningkey = 1,

	hitElement = nil,
	cloneElement = nil,
};

addEvent("onClientTuningMarkerHit", true);
addEventHandler("onClientTuningMarkerHit", root, function(player, marker, vehicle)
	if player and player == localPlayer and marker then
		renderDatas.opened = true;

		renderDatas.page = 1;
		renderDatas.submenu = 1;
		renderDatas.tuningkey = 1;

		renderDatas.hitElement = marker;
		renderDatas.cloneElement = vehicle;
		renderDatas.rotation = 0;

        renderDatas.screenDatas = {chat = isChatVisible(), hud = getElementData(localPlayer, "hudVisible"), keysDenied = getElementData(localPlayer, "keysDenied")};
		showChat(false);
		setElementData(localPlayer, "hudVisible", false);
		setElementData(localPlayer, "keysDenied", true);
	end
end);

addEventHandler("onClientRender", root, function()
	if renderDatas.opened then
		if isElement(renderDatas.cloneElement) then
			renderDatas.rotation = renderDatas.rotation < 360 and renderDatas.rotation + 1 or 0;

			renderDatas.cloneElement.rotation = Vector3(0, 0, renderDatas.rotation);
		end

		-->> Left side menu
		dxDrawRectangle(100, screenH / 2 - 110, 210, 105, colors.bg);

		for key, value in pairs(availableTunings) do
			local forY = screenH / 2 - 105 + (key - 1) * 25;

			dxDrawRectangle(105, forY, 200, 20, colors.slot);
			dxDrawText(value["categoryName"], 105, forY, 305, forY + 20, colors.white, 1, getFont("Roboto", 10), "center", "center");
		
			if key == renderDatas.page then
				dxDrawRectangle(105, forY, 200, 20, colors.hover);
				dxDrawText(value["categoryName"], 105, forY, 305, forY + 20, colors.black, 1, getFont("Roboto", 10), "center", "center");
			end
		end

		dxDrawImage(197, screenH / 2 - 7, 16, 16, "files/triangle.png", 180, 0, 0, colors.bg);

		dxDrawRectangle(100, screenH / 2 + 10, 210, 105, colors.bg);

		dxDrawText(exports.cr_vehicle:getVehicleName(renderDatas.cloneElement.model), 105, screenH / 2 + 15, 305, 0, colors.white, 1, getFont("Azzardo-Regular", 16), "center");
	
		-->> Bottom text (2k18 meme kveliti kontent) menu
		local width = #availableTunings[renderDatas.page]["subMenu"] * 105 + 5;

		dxDrawRectangle(screenW / 2 - width / 2, screenH - 130, width, 110, colors.bg);

		for key, value in pairs(availableTunings[renderDatas.page]["subMenu"]) do
			local forX = screenW / 2 - width / 2 + 5 + (key - 1) * 105;

			dxDrawRectangle(forX, screenH - 125, 100, 100, colors.slot);
			dxDrawText(value["categoryName"], forX, screenH - 125, forX + 100, screenH - 30, colors.white, 1, getFont("Roboto", 10), "center", "bottom");
		
			if key == renderDatas.submenu then
				dxDrawRectangle(forX, screenH - 125, 100, 100, colors.hover);
				dxDrawText(value["categoryName"], forX, screenH - 125, forX + 100, screenH - 30, colors.black, 1, getFont("Roboto", 10), "center", "bottom");
		
				if renderDatas.selection then
					dxDrawRectangle(forX - 25, screenH - 225, 150, 80, colors.bg);
				end
			end
		end
	end
end);

addEventHandler("onClientKey", root, function(button, pressed)
	if renderDatas.opened and pressed then
		if button == "enter" then
			cancelEvent();

			if not renderDatas.selection then
				renderDatas.selection = true;
			end
		end

		if button == "arrow_u" then
			if renderDatas.page > 1 then
				renderDatas.page = renderDatas.page - 1;

				renderDatas.submenu = 1;
				renderDatas.tuningkey = 1;
			end
		end

		if button == "arrow_d" then
			if renderDatas.page < #availableTunings then
				renderDatas.page = renderDatas.page + 1;

				renderDatas.submenu = 1;
				renderDatas.tuningkey = 1;
			end
		end

		if button == "arrow_l" then
			if not renderDatas.selection then
				if renderDatas.submenu > 1 then
					renderDatas.submenu = renderDatas.submenu - 1;

					renderDatas.tuningkey = 1;
				end
			else
				if renderDatas.tuningkey > 1 then
					renderDatas.tuningkey = renderDatas.tuningkey - 1;
				end
			end
		end

		if button == "arrow_r" then
			if not renderDatas.selection then
				if renderDatas.submenu < #availableTunings[renderDatas.page]["subMenu"] then
					renderDatas.submenu = renderDatas.submenu + 1;

					renderDatas.tuningkey = 1;
				end
			else
				if renderDatas.tuningkey < #availableTunings[renderDatas.page]["subMenu"][renderDatas.submenu]["subMenu"] then
					renderDatas.tuningkey = renderDatas.tuningkey + 1;
				end
			end
		end

		if button == "backspace" then
			if not renderDatas.selection then
				renderDatas.opened = false;

				showChat(renderDatas.screenDatas.chat);
				setElementData(localPlayer, "hudVisible", renderDatas.screenDatas.hud);
				setElementData(localPlayer, "keysDenied", renderDatas.screenDatas.keysDenied);

				triggerServerEvent("onTuningMarkerLeave", localPlayer, localPlayer, renderDatas.hitElement, renderDatas.cloneElement);
			else
				renderDatas.selection = false;
			end
		end
	end
end);