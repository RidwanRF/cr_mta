local screenW, screenH = guiGetScreenSize();

local ped = Ped(69, 1482.3715820313, -1785.7553710938, 18.25);
ped.frozen = true;
setElementData(ped, "ped.name", "Jessica Smith");
setElementData(ped, "ped.type", "Munkáltató");

local opened = false;
local browser = createBrowser(screenW, screenH, true, true);

addEventHandler("onClientBrowserCreated", browser, function()
	loadBrowserURL(browser, "http://mta/local/html/index.html");

	addEventHandler("onClientCursorMove", root, function(_, _, x, y)
		injectBrowserMouseMove(browser, x, y);
	end);

	addEventHandler("onClientClick", root, function(button, state)
		if state == "down" and opened then
			injectBrowserMouseDown(browser, button);
		else
			injectBrowserMouseUp(browser, button);
		end
	end);
end);

addEventHandler("onClientClick", root, function(button, state, x, y, wx, wy, wz, element)
	if button == "left" and state == "down" and element and element == ped and not opened and getDistanceBetweenPoints3D(localPlayer.position, element.position) < 5 then
        local items = exports['cr_inventory']:getItems(localPlayer, 2)
        for k,v in pairs(items) do
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)
            local time = getRealTime();

            local now = 1900 + time.year .. ". " .. ("%02d"):format(time.month + 1) .. ". " .. ("%02d"):format(time.monthday) .. ".";    
            if itemid == 78 then
                if value["id"] == localPlayer:getData("acc >> id") then
                    if value["expired"] >= now then
                        setTimer(function() opened = true end, 100, 1)
                        return
                    end
                end
            end
        end
            
        exports['cr_infobox']:addBox("error", "Ahhoz, hogy megnyithasd a munkapanelt érvényes személyigazolványodnak kell legyen!")    
	end
end);

addEventHandler("onClientRender", root, function()
	if opened then
		dxDrawImage(0, 0, screenW, screenH, browser, 0, 0, 0, tocolor(255, 255, 255), true);
	end
end);

addEvent("js->SelectJob", true);
addEventHandler("js->SelectJob", root, function(jobId)
	if not opened then return end

	if getElementData(localPlayer, "char >> job") ~= 0 then
		exports.cr_infobox:addBox("error", "Előbb mondj fel");
	else
		jobId = tonumber(jobId);
		
		exports.cr_infobox:addBox("success", "Sikeresen felvetted a " .. getJobName(jobId):lower() .. " munkát");
		setElementData(localPlayer, "char >> job", jobId);
	end
end);

addEvent("js->QuitJob", true);
addEventHandler("js->QuitJob", root, function()
	if not opened then return end

	if getElementData(localPlayer, "char >> job") == 0 then
		exports.cr_infobox:addBox("error", "Jelenleg is munkanélküli vagy");
	else
		exports.cr_infobox:addBox("success", "Sikeresen felmondtál");
		setElementData(localPlayer, "char >> job", 0);
	end
end);

addEvent("js->ClosePanel", true);
addEventHandler("js->ClosePanel", root, function()
	if not opened then return end

	opened = false;
end);