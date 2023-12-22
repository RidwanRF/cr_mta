-- default functions -> 
function lineddRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180);
    end
    if not color2 then
        color2 = color;
    end
    if not size then
        size = 1.7;
    end
	dxDrawRectangle(x, y, w, h, color);
	dxDrawRectangle(x - size, y - size, w + (size*2), size, color2);
	dxDrawRectangle(x - size, y + h, w + (size*2), size, color2);
	dxDrawRectangle(x - size, y, size, h, color2);
	dxDrawRectangle(x + w, y, size, h, color2);
end

function drawnIcon(x, y, icon)
    dxDrawImage(x - 30/2, y - 30/2, 30, 30, "hud/files/"..icon..".png");
end

local function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
end

function stringBoolean(string)
    if string == "true" then
        return true;
    else
        return false;
    end
end

local logged = getElementData(localPlayer, "loggedIn");
local hudVisible = getElementData(localPlayer, "hudVisible");

local ping = getPlayerPing(localPlayer);
local hexColor = "#7cc576";
function getPingColor(ping)
    local color = "#ffffff";
    
    if ping <= 60 then
        color = hexColor;
    elseif ping <= 130 then
        color = "#d09924";
    elseif ping >= 130 then
        color = "#d02424";
    end
    
    return color;
end

function convertNumber(number)  
	local formatted = number;
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2'); 
		if (k == 0) then      
			break;
		end  
	end  
	return formatted;
end
---------------------------------------------------

local id = getElementData(localPlayer, "char >> id") or -1;
local sx, sy = guiGetScreenSize();

local pingColor = getPingColor(ping)
if getResourceState(getResourceFromName("cr_fonts")) == "running" then
    pingFont = exports['cr_fonts']:getFont("Yantramanav-Black", 15)
end
addEventHandler("onClientResourceStart", root, function(startedRes)
    if getResourceName(startedRes) == "cr_fonts" then
        pingFont = exports['cr_fonts']:getFont("Yantramanav-Black", 15)
    end
end);

local money = getElementData(localPlayer, "char >> money");
local moneyChanging = false;
local newMoney = 0;
local maxNuls = 10;
local nulsText = "000000000000000000000000000000000000000000000000";
local nuls = utfSub(nulsText, 1, math.max(0, maxNuls - string.len(tostring(money))));
local typeColors = {
    ["+"] = "#7cc576",
    ["-"] = "#d02424",
};

local nameFont = dxCreateFont("hud/files/font2.ttf", 22);

local level = getElementData(localPlayer, "char >> level") or 1;
local name = tostring(getElementData(localPlayer, "char >> name") or "Invalid"):gsub("_", " ");

function getFPSColor(num)
    local num = tonumber(num) or 0;
    local color = "#ffffff";
    
    if num >= 45 then
        color = hexColor;
    elseif num >= 25 then
        color = "#d09924";
    elseif num <= 25 then
        color = "#d02424";
    end
    
    return color .. num .. " #ffffffFPS";
end

local counter = 0;
local rfps = "80 FPS";
local starttick = false;
 
fps = getFPSColor(80);

local time = getRealTime();
local time1 = time.hour;
if time1 < 10 then
    time1 = "0" .. tostring(time1);
end
local time2 = time.minute;
if time2 < 10 then
    time2 = "0" .. tostring(time2);
end

local time = getRealTime();
local month = time.month + 1;
local str = tostring(month);
if month < 10 then
    str = "0" .. str;
end
local monthday = time.monthday;
local str2 = tostring(monthday);
if monthday < 10 then
    str2 = "0" .. str2;
end
local year = tostring(tonumber(time.year) + 1900)
local datum =  year.."."..str.."."..str2;
local datum2 =  year..hexColor..".#ffffff"..str..hexColor..".#ffffff"..str2;

local premiumPoints = convertNumber(tonumber(getElementData(localPlayer, "char >> premiumPoints") or 0));
local maxNuls = 10;
local nulsText = "000000000000000000000000000000000000000000000000";
local nuls = utfSub(nulsText, 1, math.max(0, maxNuls - string.len(tostring(premiumPoints))));

local details = dxGetStatus();
local cardDatas = {
    ["vname"] = details["VideoCardName"],
    ["vram"] = details["VideoCardRAM"],
    ["vfram"] = details["VideoMemoryFreeForMTA"],
    ["vfont"] = details["VideoMemoryUsedByFonts"],
    ["vtexture"] = details["VideoMemoryUsedByTextures"],
    ["vtarget"] = details["VideoMemoryUsedByRenderTargets"],
    ["vratio"] = details["SettingAspectRatio"],
    ["vcolor"] = details["Setting32BitColor"],
};

local packetloss = getNetworkStats()["packetlossTotal"];
local packetloss = math.floor(packetloss);
if cardDatas["vcolor"] then
    cardDatas["vcolor"] = 32;
else 
    cardDatas["vcolor"] = 16;
end

local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};

-- draws ->

local widgets = {};

function drawWidgets()
    if not hudVisible then return end
    
    if widgets["ping"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("ping");
        shadowedText(ping .. " ms", x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true); 
        dxDrawText(pingColor .. ping .. " #ffffffms", x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["money"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("money");
        if moneyChanging then
            shadowedText(moneyChangeType .. newMoney .. " $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
            dxDrawText(moneyChangeType .. typeColors[moneyChangeType] .. newMoney .. " #ffffff$", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
        else
            if money < 0 then
                shadowedText(nuls .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
                dxDrawText(nuls .. typeColors["-"] .. money .." #ffffff$", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
            else
                shadowedText(nuls .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
                dxDrawText(nuls .. hexColor .. money .." #ffffff$", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
            end
        end
    end
    
    if widgets["name"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("name");
        shadowedText(name .. " ("..id..") - lvl:" .. level, x, y, x + w, y + h, tocolor(255,255,255,255), 1, nameFont, "center", "center", false, false, false, true);
        dxDrawText(name .. " #ffffff("..hexColor..id.."#ffffff) - lvl:" .. hexColor .. level, x, y, x + w, y + h, tocolor(255,255,255,255), 1, nameFont, "center", "center", false, false, false, true);
    end
    
    if widgets["fps"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("fps");
        shadowedText(rfps, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText(fps, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["time"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("time");
        shadowedText(time1 .. ":" .. time2, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText(time1 .. hexColor .. ":#ffffff" .. time2, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["datum"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("datum");
        shadowedText(datum, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText(datum2, x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["videocard"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("videocard");
        shadowedText(cardDatas["vname"] .. "\nVRAM: "..cardDatas["vram"] - cardDatas["vfram"].."/" .. cardDatas["vram"] .. " MB, FONT: " .. cardDatas["vfont"] .. " MB \nTEXTURE: "  .. cardDatas["vtexture"] .. " MB, RTARGET: " .. cardDatas["vtarget"] .. " MB\nRATIO: " .. cardDatas["vratio"] .. ", SIZE: "..sx.."x"..sy.."x"..cardDatas["vcolor"], x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "left", "top", false, false, false, true);
        dxDrawText(hexColor .. cardDatas["vname"] .. "#ffffff\nVRAM: "..hexColor..cardDatas["vram"] - cardDatas["vfram"].."/" .. cardDatas["vram"] .. "#ffffff MB, FONT: " .. hexColor .. cardDatas["vfont"] .. "#ffffff MB \nTEXTURE: " .. hexColor .. cardDatas["vtexture"] .. " #ffffffMB, RTARGET: " .. hexColor .. cardDatas["vtarget"] .. "#ffffff MB\nRATIO: " .. hexColor .. cardDatas["vratio"] .. "#ffffff, SIZE: "..hexColor..sx.."#ffffffx"..hexColor..sy.."#ffffffx"..hexColor..cardDatas["vcolor"], x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "left", "top", false, false, false, true);
    end
                    
    if widgets["packetloss"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("packetloss");
        shadowedText("Adatveszteség: "..packetloss.." %", x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText("Adatveszteség: "..hexColor..packetloss.." #ffffff%", x, y, x + w, y + h, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["premiumPoints"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("premiumPoints");
        shadowedText(nuls .. premiumPoints .. " PP", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
        dxDrawText(nuls .. hexColor .. premiumPoints .. " #ffffffPP", x, y, x + w, y + h, tocolor(255,255,255,255), 1, "pricedown", "center", "center", false, false, false, true);
    end
    
    if widgets["bone"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("bone")
        local w,h = 18, 46
        local x, y = x, y
        dxDrawImage(x, y, w, h, "hud/files/bone.png", 0,0,0, tocolor(255,255,255,255));
        if not bone[2] then
            dxDrawImage(x, y, w, h, "hud/files/injureLeftArm.png", 0,0,0, tocolor(255,255,255,200));
        end
        if not bone[3] then
            dxDrawImage(x, y, w, h, "hud/files/injureRightArm.png", 0,0,0, tocolor(255,255,255,200));
        end
        if not bone[4] then
            dxDrawImage(x-0.5, y, w, h, "hud/files/injureLeftFoot.png", 0,0,0, tocolor(255,255,255,200));
        end
        if not bone[5] then
            dxDrawImage(x, y, w, h, "hud/files/injureRightFoot.png", 0,0,0, tocolor(255,255,255,200));
        end
    end
end
---------------------------------------------------------------

-- timers ->
setTimer(
    function()
        if not logged then return end
        if getElementData(localPlayer, "inDeath") then return end
        --if getElementData(localPlayer, "char >> tazed") then return end
        if getElementData(localPlayer, "char >> ajail") then return end
        --if getElementData(localPlayer, "char >> cuffed") then return end
        if not exports.cr_admin:getAdminDuty(localPlayer) then
            local oldFood = (tonumber(getElementData(localPlayer, "char >> food")) or 100);
            local foodNull = false;
            --local drinkNull = false;

            if oldFood - 0.05 >= 0 then
                setElementData(localPlayer, "char >> food", oldFood - 0.05);

                if oldFood - 0.05 <= 20 then
                    if not isTimer(foodWarningTimer) then
                        foodWarningTimer = setTimer(function()
                            exports['cr_infobox']:addBox("warning", "Kezdesz éhes lenni, egyél valamit!");
                        end, 15 * 60000, 0);
                    end
                else
                    if isTimer(foodWarningTimer) then killTimer(foodWarningTimer) end
                end
            else
                if isTimer(foodWarningTimer) then killTimer(foodWarningTimer) end

                setElementData(localPlayer, "char >> food", 0);
                foodNull = true;
            end

            local oldDrink = (tonumber(getElementData(localPlayer, "char >> drink")) or 100);
            local drinkNull = false;

            if oldDrink - 0.25 >= 0 then
                setElementData(localPlayer, "char >> drink", oldDrink - 0.25);
                if oldDrink - 0.25 <= 20 then
                    if not isTimer(drinkWarningTimer) then
                        drinkWarningTimer = setTimer(function()
                            exports['cr_infobox']:addBox("warning", "Kezdesz szomjas lenni, igyál valamit!");
                        end, 15 * 60000, 0);
                    end
                else
                    if isTimer(drinkWarningTimer) then killTimer(drinkWarningTimer) end
                end
            else
                if isTimer(drinkWarningTimer) then killTimer(drinkWarningTimer) end
                setElementData(localPlayer, "char >> drink", 0);
                drinkNull = true;
            end

            if drinkNull and not foodNull then
                local health = getElementHealth(localPlayer);
                setElementHealth(localPlayer, health - 20);

                if health - 20 <= 0 then
                    if not getElementData(localPlayer, "char >> death") then
                        setElementData(localPlayer, "char >> death", true);
                    end
                end
            elseif drinkNull and foodNull then
                if not getElementData(localPlayer, "char >> death") then
                    setElementData(localPlayer, "char >> death", true);
                end
            elseif not drinkNull and foodNull then
                local health = getElementHealth(localPlayer);
                setElementHealth(localPlayer, health - 50);
                if health - 50 <= 0 then
                    if not getElementData(localPlayer, "char >> death") then
                        setElementData(localPlayer, "char >> death", true);
                    end
                end
            end
        end
    end, 
40 * 1000, 0);

setTimer(function()
    if widgets and widgets["ping"] then
        ping = getPlayerPing(localPlayer);
        pingColor = getPingColor(ping);
    end
end, 2000, 0);

setTimer(function()
    if widgets and widgets["time"] then
        time = getRealTime()
        time1 = time.hour
        if time1 < 10 then
            time1 = "0" .. tostring(time1)
        end
        time2 = time.minute
        if time2 < 10 then
            time2 = "0" .. tostring(time2)
        end
    end
end, 2000, 0);

setTimer(function()
    if widgets and widgets["datum"] then
        local time = getRealTime();
        local month = time.month + 1;
        local str = tostring(month);
        if month < 10 then
            str = "0" .. str;
        end
        local monthday = time.monthday;
        local str2 = tostring(monthday);
        if monthday < 10 then
            str2 = "0" .. str2;
        end
        local year = tostring(tonumber(time.year) + 1900)
        datum = year.."."..str.."."..str2;
        datum2 = year..hexColor..".#ffffff"..str..hexColor..".#ffffff"..str2;
    end
end, 60 * (60 * 1000), 0);

setTimer(function()
    if widgets and widgets["videocard"] then
        details = dxGetStatus();
        cardDatas = {
            ["vname"] = details["VideoCardName"],
            ["vram"] = details["VideoCardRAM"],
            ["vfram"] = details["VideoMemoryFreeForMTA"],
            ["vfont"] = details["VideoMemoryUsedByFonts"],
            ["vtexture"] = details["VideoMemoryUsedByTextures"],
            ["vtarget"] = details["VideoMemoryUsedByRenderTargets"],
            ["vratio"] = details["SettingAspectRatio"],
            ["vcolor"] = details["Setting32BitColor"],
        };
        packetloss = getNetworkStats()["packetlossTotal"];
        packetloss = math.floor(packetloss);
        if cardDatas["vcolor"] then
            cardDatas["vcolor"] = 32;
        else 
            cardDatas["vcolor"] = 16;
        end
    end
end, 1000, 0);

addEventHandler("onClientRender",root, function()
    if widgets and widgets["fps"] then
        if not starttick then
            starttick = getTickCount();
        end
        counter = counter + 1;
        currenttick = getTickCount ();
        if currenttick - starttick >= 1000 then
            rfps = counter .. " FPS";
            fps = getFPSColor(counter);
            counter = 0;
            starttick = false;
        end
    end
end, true, "low");
---------------------------------------------------------------

local datas = {
    ["name.enabled"] = "name",
    ["fps.enabled"] = "fps",
    ["time.enabled"] = "time",
    ["datum.enabled"] = "datum",
    ["premiumPoints.enabled"] = "premiumPoints",
    ["videocard.enabled"] = "videocard",
    ["packetloss.enabled"] = "packetloss",
    ["bone.enabled"] = "bone",
    ["ping.enabled"] = "ping",
};

function checkDatas(dataName)
    if dataName and datas[dataName] then
        local state = getElementData(localPlayer, dataName);
        if state then
            widgets[datas[dataName]] = true;
        else
            widgets[datas[dataName]] = false;
        end
    else
        for i, k in pairs(datas) do
            local state = getElementData(localPlayer, i);
            if state then
                widgets[k] = true;
            else
                widgets[k] = false;
            end
        end
    end
end

addEventHandler("onClientElementDataChange", localPlayer, function(dName, oValue)
    if dName == "char >> id" then
    	id = tonumber(getElementData(localPlayer, dName)) or 1
    end
        
    if dName == "char >> level" then
        level = tonumber(getElementData(localPlayer, dName)) or 1;
        return;
    end
        
    if dName == "char >> name" then
        name = tostring(getElementData(localPlayer, dName) or "Invalid"):gsub("_", " ");
        return;
    end
    if dName == "loggedIn" then
        checkDatas();
        logged = getElementData(localPlayer, dName);
        addEventHandler("onClientRender", getRootElement(), drawWidgets, true, "low");
        return;
    end
    if dName == "char >> bone" then
        bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
        return
    end
        
    if dName == "hudVisible" then
        hudVisible = getElementData(localPlayer, dName);
        return;
    end
        
    if datas[dName] then
        checkDatas(dName);
    end
        
    if dName == "char >> premiumPoints" then
        premiumPoints = convertNumber(getElementData(source, dName));
        nuls = utfSub(nulsText, 1, math.max(0, maxNuls - string.len(tostring(premiumPoints))));
        return;
    end
        
    if oValue == nil or not oValue then oValue = 0 end
    if dName == "char >> money" then
        local value = getElementData(source, dName);
        nuls = utfSub(nulsText, 1, maxNuls - string.len(tostring(value)));
        money = convertNumber(value);
        if value > oValue then
            moneyChangeType = "+";
            newMoney = value - oValue;
            money = typeColors[moneyChangeType] .. money;
        elseif oValue > value then
            moneyChangeType = "-";
            newMoney = oValue - value;
            money = typeColors[moneyChangeType] .. money;
        end
        if logged then
            playSound("files/moneychange.mp3");
        end
        money = convertNumber(money);
        moneyChanging = true;
        setTimer(function()
            moneyChanging = false;
            money = getElementData(localPlayer, "char >> money");
            nuls = utfSub(nulsText, 1, math.max(0, maxNuls - string.len(tostring(money))));
        end, 2500, 1);
        return;
    end
end, true, "low");

addEventHandler("onClientResourceStart", resourceRoot,function()
    if getElementData(localPlayer, "loggedIn") then
        checkDatas();
        addEventHandler("onClientRender", getRootElement(), drawWidgets, true, "low");
    end
end);