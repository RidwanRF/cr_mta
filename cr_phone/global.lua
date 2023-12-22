screenW, screenH = guiGetScreenSize();
multipler = 0.725;
page = 2;
width, height = 328*multipler, 638*multipler;
positions = {screenW - width - 150, screenH/2 - height/2};
pages = {"Lockscreen", "Menu"}

times = {
    ["week"] = {
        "Hétfő", "Kedd", "Szerda", "Csütörtök", "Péntek", "Szombat", "Vasárnap"
    },
    ["month"] = {
        "Január", "Február", "Március", "Április", "Május", "Június", "Július", "Augusztus", "Szeptember", "Október", "November", "December"
    }
}

icons = {{"signal.png", 14, 9}, {"wifi.png", 13, 9}, {"battery.png", 19, 9}};

function getTime(date)
    local time = getRealTime();
    local minute = time.minute;
    local hours = time.hour;
    local weekday = time.weekday;
    local month = time.month + 1;
    local day = time.monthday;
    
    
    if hours < 10 then hours = "0"..hours; end
    if minute < 10 then minute = "0"..minute; end
    if day < 10 then day = "0"..day; end
    
    return date and times["week"][weekday]..", "..times["month"][month].." "..day or (hours.." : "..minute);
end

shop_datas = {
    -- Bolt neve, hívás ára, sms ára, szolgáltatás ára
    ["types"] = {
        {"AT&T", 1, 2, 200},
        {"Verizon", 3, 4, 300},
        {"T-Mobile", 0, 0, 750},
    },
    ["positions"] = {
        {-2612.3139648438, -200.94068908691, 4.3359375, 0, 0, 0, "Ped 1"},
        {-2611.7614746094, -196.71270751953, 4.3359375, 0, 0, 0, "Ped 2"},
        {-2611.4841308594, -194.17037963867, 4.3359375, 0, 0, 0, "Ped 3"},
    },
};

fonts = {
    ["SFUIDisplay-Light-22"] = dxCreateFont("files/fonts/SFUIDisplay-Light.otf", 22),
    ["SFUIDisplay-Regular-9"] = dxCreateFont("files/fonts/SFUIDisplay-Regular.otf", 9),
    ["SFUIDisplay-Semibold-7"] = dxCreateFont("files/fonts/SFUIDisplay-Regular.otf", 7),
    ["SFUIDisplay-Semibold-5"] = dxCreateFont("files/fonts/SFUIDisplay-Regular.otf", 6),
}