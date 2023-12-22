local screenW, screenH = guiGetScreenSize();

addEventHandler("onClientResourceStart", resourceRoot, function()
	for key = 0, 4 do
		setInteriorFurnitureEnabled(key, false);
	end
end);

local renderDatas = {
	opened = false,
	hidden = false,
	state = "menu",
	selected = 1,

	menu = {
		left = screenW / 2 - 400 / 2,
		top = screenH / 2 - 186 / 2,
		width = 400,
		height = 230,
	},

	list = {
		element = nil,
		price = nil,

		left = screenW / 2 - 600 / 2,
		top = screenH / 2 - 420 / 2,
		width = 600,
		height = 428,

		maxRow = 18,
		latestRow = 1,
		currentRow = 1,
	},

	selection = {
		element = nil,

		left = nil,
		top = nil,
		width = 220,
		height = 98,
	}
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
	title = dxCreateFont("editor/files/Roboto.ttf", 12),
	normal = dxCreateFont("editor/files/Roboto.ttf", 9),
	awesome = exports.cr_fonts:getFont("AwesomeFont2", 9),
};

addEventHandler("onClientRender", root, function()
	if renderDatas.opened and not renderDatas.hidden then
		if localPlayer.interior == datas.interior and localPlayer.dimension == datas.dimension and getElementData(localPlayer, "acc >> id") == datas.owner then
			if renderDatas.state == "menu" then
				dxDrawWindow(renderDatas.menu.left, renderDatas.menu.top, renderDatas.menu.width, renderDatas.menu.height, colors.bg, "StayMTA - Bútorok", fonts.title);
			
				for key, value in pairs(furnitures) do
					local forY = renderDatas.menu.top + 32 + (key - 1) * 22;

					dxDrawRectangle(renderDatas.menu.left + 2, forY, renderDatas.menu.width - 4, 20, colors.slot);
					dxDrawText(value["name"], renderDatas.menu.left, forY, renderDatas.menu.left + renderDatas.menu.width, forY + 20, colors.white, 1, fonts.normal, "center", "center"); 
				
					if isCursorHover(renderDatas.menu.left + 2, forY, renderDatas.menu.width - 4, 20) then
						dxDrawRectangle(renderDatas.menu.left + 2, forY, renderDatas.menu.width - 4, 20, colors.hover);
						dxDrawText(value["name"], renderDatas.menu.left, forY, renderDatas.menu.left + renderDatas.menu.width, forY + 20, colors.black, 1, fonts.normal, "center", "center"); 
					end
				end
			elseif renderDatas.state == "list" then
				dxDrawWindow(renderDatas.list.left, renderDatas.list.top, renderDatas.list.width, renderDatas.list.height, colors.bg, furnitures[renderDatas.selected]["name"], fonts.title);
			
				renderDatas.list.latestRow = renderDatas.list.currentRow + renderDatas.list.maxRow - 1;
				for key, value in pairs(furnitures[renderDatas.selected]["furns"]) do
					if key >= renderDatas.list.currentRow and key <= renderDatas.list.latestRow then
		        		key = key - renderDatas.list.currentRow + 1;

						local forY = renderDatas.list.top + 32 + (key - 1) * 22;

						dxDrawRectangle(renderDatas.list.left + 2, forY, renderDatas.list.width - 4, 20, colors.slot);
						dxDrawText(value["name"] .. " | Ár: $" .. value["price"], renderDatas.list.left + 6, forY, _, forY + 20, colors.white, 1, fonts.normal, "left", "center");
					
						dxDrawButton(renderDatas.list.left + renderDatas.list.width - 206, forY + 2, 100, 16, colors.second, "Előnézet", "Előnézet ", fonts.awesome);
						dxDrawButton(renderDatas.list.left + renderDatas.list.width - 104, forY + 2, 100, 16, colors.hover, "Vásárlás", "Vásárlás ", fonts.awesome);
					end
				end
			elseif renderDatas.state == "selection" then
				renderDatas.selection.left, renderDatas.selection.top = getScreenFromWorldPosition(unpack({renderDatas.selection.element.position}));
		
				if renderDatas.selection.left and renderDatas.selection.top then
					dxDrawWindow(renderDatas.selection.left, renderDatas.selection.top, renderDatas.selection.width, renderDatas.selection.height, colors.bg, "Bútor", fonts.title);
				
					dxDrawButton(renderDatas.selection.left + 2, renderDatas.selection.top + 32, renderDatas.selection.width - 4, 20, colors.hover, "Szerkesztés", "Szerkesztés ", fonts.awesome);
					dxDrawButton(renderDatas.selection.left + 2, renderDatas.selection.top + 54, renderDatas.selection.width - 4, 20, colors.second, "Felvétel", "Felvétel ", fonts.awesome);
					dxDrawButton(renderDatas.selection.left + 2, renderDatas.selection.top + 76, renderDatas.selection.width - 4, 20, colors.cancel, "Bezárás", "Bezárás ", fonts.awesome);
				end
			end
		end
	end
end);

addCommandHandler("butorok", function()
	datas = getElementData(localPlayer, "interior->Datas") or {};

	if localPlayer.interior == datas.interior and localPlayer.dimension == datas.dimension and getElementData(localPlayer, "acc >> id") == datas.owner then
		renderDatas.opened = not renderDatas.opened;

		if renderDatas.opened then
			renderDatas.state = "menu";
		end
	end
end);

addEventHandler("onClientKey", root, function(button, pressed)
	if pressed and button == "F7" then
		datas = getElementData(localPlayer, "interior->Datas") or {};

		if localPlayer.interior == datas.interior and localPlayer.dimension == datas.dimension and getElementData(localPlayer, "acc >> id") == datas.owner then
			renderDatas.opened = not renderDatas.opened;

			if renderDatas.opened then
				renderDatas.state = "menu";
			end
		end
	end

	if pressed and renderDatas.opened and not renderDatas.hidden then
		if button == "mouse1" then
			if renderDatas.state == "menu" then
				for key, value in pairs(furnitures) do
					local forY = renderDatas.menu.top + 32 + (key - 1) * 22;

					if isCursorHover(renderDatas.menu.left + 2, forY, renderDatas.menu.width - 4, 20) then
						renderDatas.state = "list";
						renderDatas.selected = key;
					end
				end
			elseif renderDatas.state == "list" then
				for key, value in pairs(furnitures[renderDatas.selected]["furns"]) do
					local forY = renderDatas.list.top + 32 + (key - 1) * 22;

					if isCursorHover(renderDatas.list.left + renderDatas.list.width - 206, forY + 2, 100, 16) and not isElement(renderDatas.list.element) then
						renderDatas.hidden = true;

						renderDatas.list.element = Object(value["id"], localPlayer.position);
						renderDatas.list.element.interior = localPlayer.interior;
						renderDatas.list.element.dimension = localPlayer.dimension;
						renderDatas.list.element.collisions = false;
						renderDatas.list.element.alpha = 150;

						setTimer(function()
							if isElement(renderDatas.list.element) then
								renderDatas.hidden = false;

								destroyElement(renderDatas.list.element);
							end
						end, 5000, 1);
					end

					if isCursorHover(renderDatas.list.left + renderDatas.list.width - 104, forY + 2, 100, 16) and not isElement(renderDatas.list.element) then
						renderDatas.list.element = Object(value["id"], localPlayer.position);
						renderDatas.list.element.interior = localPlayer.interior;
						renderDatas.list.element.dimension = localPlayer.dimension;
						renderDatas.list.element.collisions = false;
						renderDatas.list.element.alpha = 150;

						renderDatas.list.price = value["price"];

						toggleEditor(renderDatas.list.element, "createFurniture", "deleteFurniture");

						renderDatas.opened = false;
					end
				end
			elseif renderDatas.state == "selection" then
				if isCursorHover(renderDatas.selection.left + 2, renderDatas.selection.top + 32, renderDatas.selection.width - 4, 20) then
					toggleEditor(renderDatas.selection.element, "modifyFurniture", "cancelModify");
					renderDatas.opened = false;
				end

				if isCursorHover(renderDatas.selection.left + 2, renderDatas.selection.top + 54, renderDatas.selection.width - 4, 20) then
					for key, value in pairs(furnitures) do
						for index, list in pairs(value["furns"]) do
							if list["id"] == renderDatas.selection.element.model then
								exports.cr_core:giveMoney(localPlayer, list["price"], false);

								triggerServerEvent("furniture->RemoveFurn", localPlayer, localPlayer, renderDatas.selection.element);
								renderDatas.opened = false;

								break;
							end
						end
					end
				end

				if isCursorHover(renderDatas.selection.left + 2, renderDatas.selection.top + 76, renderDatas.selection.width - 4, 20) then
					renderDatas.opened = false;
				end
			end
		elseif button == "backspace" then
			if renderDatas.state == "menu" then
				renderDatas.opened = false;
			elseif renderDatas.state == "list" then
				renderDatas.state = "menu";
			end
		elseif button == "mouse_wheel_down" then
			if renderDatas.state == "list" then
	    		if renderDatas.list.currentRow < #furnitures[renderDatas.selected]["furns"] - (renderDatas.list.maxRow - 1) then
		            renderDatas.list.currentRow = renderDatas.list.currentRow + 1;
		        end
		    end
	    elseif button == "mouse_wheel_up" then
	    	if renderDatas.state == "list" then
		    	if renderDatas.list.currentRow > 1 then
		    		renderDatas.list.currentRow = renderDatas.list.currentRow - 1;
		    	end
		    end
		end
	end
end);

addEventHandler("onClientClick", root, function(button, state, x, y, wx, wy, wz, element)
	if button == "right" and state == "down" and element and (getElementData(element, "furniture->Id") or 0) >= 1 then
		datas = getElementData(localPlayer, "interior->Datas") or {};

		if localPlayer.interior == datas.interior and localPlayer.dimension == datas.dimension and getElementData(localPlayer, "acc >> id") == datas.owner then		
			if not renderDatas.opened then
				renderDatas.opened = true;
				renderDatas.state = "selection";
				renderDatas.selection.element = element;
			end
		end
	end
end);

addEvent("createFurniture", true);
addEventHandler("createFurniture", root, function(element, x, y, z, rx, ry, rz, scale, array)
	if isElement(element) then
		if exports.cr_core:takeMoney(localPlayer, renderDatas.list.price, false) then
			id = element.model;
			destroyElement(element);	

			triggerServerEvent("furniture->CreateNew", localPlayer, localPlayer, id, x, y, z, rx, ry, rz);
			exports.cr_infobox:addBox("success", "Sikeresen megvásároltad a bútort");
		else
			exports.cr_infobox:addBox("error", "Nincs elég pénzed ($" .. renderDatas.list.price .. ")");
		end
	end
end);

addEvent("modifyFurniture", true);
addEventHandler("modifyFurniture", root, function(element, x, y, z, rx, ry, rz, scale, array)
	if isElement(element) then
		id = getElementData(element, "furniture->Id");	

		triggerServerEvent("furniture->ModifyFurn", localPlayer, localPlayer, id, element, x, y, z, rx, ry, rz);
		exports.cr_infobox:addBox("success", "Sikeresen áthelyezted a bútort");
	end
end);

addEvent("deleteFurniture", true);
addEventHandler("deleteFurniture", root, function(element)
	if isElement(element) then
		destroyElement(element);	
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