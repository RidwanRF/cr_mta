local phoneData = {};
local sim = false;

if getPlayerSerial() ~= "9AEFA61ED63E3215DBD86EC95FD264B3" then return end

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("server -> requestPhoneDatas", localPlayer, "111-111-111");
end);

addEvent("client -> requestPhoneDatas", true);
addEventHandler("client -> requestPhoneDatas", root, function(datas)
    if datas then
        phoneData = datas;
        addEventHandler("onClientRender", root, renderPhone);
    else
        outputDebugString("PHONE: NO DATAS");    
    end
end);

function renderPhone()
    dxDrawImage(positions[1], positions[2], width, height, "files/bg.png", 0, 0, 0, tocolor(255, 255, 255, 255), true);
    
    if pages[page] == "Lockscreen" then
        dxDrawImage(positions[1] + 15, positions[2] + 13, 286*multipler, 602*multipler, "files/screen.png", 0, 0, 0, tocolor(255, 255, 255, 255), true);

        dxDrawText(getTime(false), positions[1] + 20, positions[2] - 130, positions[1] + 20 + 286*multipler, positions[2] - 130 + 602*multipler, tocolor(255, 255, 255, 255), 1, fonts["SFUIDisplay-Light-22"], "center", "center", false, false, true);
        dxDrawText(getTime(true), positions[1] + 20, positions[2] - 105, positions[1] + 20 + 286*multipler, positions[2] - 105 + 602*multipler, tocolor(255, 255, 255, 255), 1, fonts["SFUIDisplay-Regular-9"], "center", "center", false, false, true);

        dxDrawText(getTime(false), positions[1] + 27, positions[2] + 18, positions[1] + 27 + 286*multipler, positions[2] + 18 + 602*multipler, tocolor(255, 255, 255, 255), 1, fonts["SFUIDisplay-Semibold-7"], "left", "top", false, false, true);
    elseif pages[page] == "Menu" then
        dxDrawImage(positions[1] + 15, positions[2] + 13, 286*multipler, 602*multipler, "files/menu/bg.png", 0, 0, 0, tocolor(255, 255, 255, 255), true);
        dxDrawImage(positions[1] + 20, positions[2] + 13 + height - 82, 270*multipler, 69*multipler, "files/menu/doc_bg.png", 0, 0, 0, tocolor(255, 255, 255, 255), true);
            
        for i=1, 4 do
            dxDrawImage(positions[1] + 32.5 + (i-1)*46, positions[2] + 20 + height - 81, 47*multipler, 46*multipler, "files/menu/icons/"..i..".png", 0, 0, 0, tocolor(255, 255, 255, 255), true);
        end
            
        dxDrawText(getTime(false), positions[1] + 27, positions[2] + 18, positions[1] + 27 + 286*multipler, positions[2] + 18 + 602*multipler, tocolor(255, 255, 255, 255), 1, fonts["SFUIDisplay-Semibold-7"], "left", "top", false, false, true);
    end
    
    local w = positions[1];
    for i=1, 3 do
        --if i == 1 and not sim then break; end
        if i == 1 and not sim then
            dxDrawText("No SIM", positions[1] + 78, positions[2] + 27, positions[1] + width + 78, positions[2] + height + 27, tocolor(200, 200, 200, 200), 1, fonts["SFUIDisplay-Semibold-5"], "center", "top", false, false, true)
        else
            dxDrawImage(w + 177.5, positions[2] + 18, icons[i][2]*multipler, icons[i][3]*multipler, "files/menu/icons/"..icons[i][1], 0, 0, 0, tocolor(255, 255, 255, 255), true);
        end
        
        w = w + 3 + (icons[i][2]*multipler);
    end
end