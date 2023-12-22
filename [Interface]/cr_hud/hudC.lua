local screenW, screenH = guiGetScreenSize();

local hp = 0;
local armor = 0;
local hunger = 0;
local thirsty = 0;
local stamina = 0;
local money = "";

--browser = createBrowser(440, 240, true, true);

local gtafont = DxFont("gtaFont.ttf", 18, false, "proof");

function refreshStats()
	if getElementData(localPlayer, "loggedIn") then
		hp = localPlayer.health;
		executeBrowserJavascript(browser, 'change("hp", ' .. hp .. ');');

		armor = localPlayer.armor;
		executeBrowserJavascript(browser, 'change("armor", ' .. armor .. ');');

		hunger = getElementData(localPlayer, "char >> food");
		executeBrowserJavascript(browser, 'change("hunger", ' .. hunger .. ');');

		thirsty = getElementData(localPlayer, "char >> drink");
		executeBrowserJavascript(browser, 'change("thirsty", ' .. thirsty .. ');');

		stamina = exports.cr_interface:getStamina();
		executeBrowserJavascript(browser, 'change("stamina", ' .. stamina .. ');');

		money = getMoney();
	end
end
addEvent("js->Request", true);
addEventHandler("js->Request", root, refreshStats);

_createBrowser = createBrowser
function createBrowser()
    browser = _createBrowser(440, 240, true, true);

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/html/index.html");
            
        --[[ executeBrowserJavascript(browser, 'change("hp", ' .. 0 .. ');');    
        executeBrowserJavascript(browser, 'change("armor", ' .. 0 .. ');');    
        executeBrowserJavascript(browser, 'change("hunger", ' .. 0 .. ');');    
        executeBrowserJavascript(browser, 'change("thirsty", ' .. 0 .. ');');    
        executeBrowserJavascript(browser, 'change("stamina", ' .. 0 .. ');'); ]]

        --[[ setTimer(function()
           refreshStats();
        end, 1500, 1); ]]
    end);
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if getElementData(localPlayer, "loggedIn") then
		createBrowser();
	end
end);

addEventHandler("onClientElementDataChange", root, function(data, old)
    if source == localPlayer then
        if data == "loggedIn" then
            if getElementData(localPlayer, data) then
                createBrowser();
            end
        end

        if getElementData(localPlayer, "loggedIn") then
            if data == "char >> food" then
                hunger = getElementData(localPlayer, "char >> food");
                executeBrowserJavascript(browser, 'change("hunger", ' .. hunger .. ');');
            end

            if data == "char >> drink" then
                thirsty = getElementData(localPlayer, "char >> drink");
                executeBrowserJavascript(browser, 'change("thirsty", ' .. thirsty .. ');');
            end

            if data == "char >> money" then
                money = getMoney();
            end
        end
    end
end);

function getMoney()
	local maxDrawNull = 8;
	local actualCharMoney = maxDrawNull - string.len(tostring(getElementData(localPlayer, "char >> money")));
	local finalConvert = "";
			 
	for i = 0, actualCharMoney, 1 do
		finalConvert = finalConvert .. "0";
	end

	if getElementData(localPlayer, "char >> money") >= 0 then
		finalConvert = finalConvert .. "#7cc576" .. getElementData(localPlayer, "char >> money");
	else
		finalConvert = "-" .. finalConvert .. "#d24d57" .. math.abs(getElementData(localPlayer, "char >> money"));
	end

	return finalConvert;
end

local components = {"hp", "armor", "hunger", "thirsty", "stamina"};

addEventHandler("onClientRender", root, function()
	if not getElementData(localPlayer, "loggedIn") then return false; end
	if not getElementData(localPlayer, "hudVisible") then return false; end

	-->> HEXAGON PROGRESS & STAMINA
	--[[local enabled, startX, startY, width, height, sizable, turnable = getDetails("hudbars");

	if enabled then
		dxDrawImage(startX, startY, 400, 240, browser);
	end]]

	-->> HEXAGON BARS
	for key, value in pairs(components) do
		local enabled, startX, startY = getDetails(value);

		if enabled then
			dxDrawImageSection(startX, startY, 80, 80, 5 + 85 * (key - 1), 5, 80, 80, browser);
		end
	end

	-->> PLAYER MONEY
	local enabled, startX, startY, width, height, sizable, turnable = getDetails("hudmoney");

	if enabled then
		dxDrawText("$" .. money:gsub("#%x%x%x%x%x%x", ""), startX + 1, startY + 1, startX + width + 1, startY + height + 1, tocolor(0, 0, 0), 1, gtafont, "left", "center", false, false, false, true);
		dxDrawText("$" .. money:gsub("#%x%x%x%x%x%x", ""), startX + 1, startY - 1, startX + width + 1, startY + height - 1, tocolor(0, 0, 0), 1, gtafont, "left", "center", false, false, false, true);
		dxDrawText("$" .. money:gsub("#%x%x%x%x%x%x", ""), startX - 1, startY + 1, startX + width - 1, startY + height + 1, tocolor(0, 0, 0), 1, gtafont, "left", "center", false, false, false, true);
		dxDrawText("$" .. money:gsub("#%x%x%x%x%x%x", ""), startX - 1, startY - 1, startX + width - 1, startY + height - 1, tocolor(0, 0, 0), 1, gtafont, "left", "center", false, false, false, true);

		dxDrawText("$" .. money, startX, startY, startX + width, startY + height, tocolor(255, 255, 255), 1, gtafont, "left", "center", false, false, false, true);
	end
        
    if localPlayer.health ~= hp then
		hp = localPlayer.health;
		executeBrowserJavascript(browser, 'change("hp", ' .. hp .. ');');
	end

	if localPlayer.armor ~= armor then
		armor = localPlayer.armor;
		executeBrowserJavascript(browser, 'change("armor", ' .. armor .. ');');
	end

	if math.floor(exports.cr_interface:getStamina() or 100) ~= math.floor(stamina) then
		stamina = exports.cr_interface:getStamina();
		executeBrowserJavascript(browser, 'change("stamina", ' .. stamina .. ');');
	end    
end);

function getDetails(component)
    return exports.cr_interface:getDetails(component);
end