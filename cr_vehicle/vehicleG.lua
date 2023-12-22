allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } }; -- numbers/lowercase chars/uppercase chars

function generateString(len, onlyNumber, onlyString)
    if tonumber(len) then
        math.randomseed(getTickCount());

        local str = "";

        for i = 1, len do
            local charlist = allowed[math.random(1,3)];
            if onlyNumber then
                charlist = allowed[math.random(1,1)];
            end
            
            if onlyString then
                charlist = allowed[math.random(3,3)];
            end

            str = str .. string.upper(string.char(math.random(charlist[1], charlist[2])));
        end

        return str;
    end

    return false;
end

function dxDrawnBorder(x, y, w, h, color2, color1)
    exports['cr_core']:roundedRectangle(x,y,w,h,color1,color2);
end

function linedRectangle(x,y,w,h, color, color2)
    return exports['cr_core']:linedRectangle(x,y,w,h, color, color2, 2);
end

disabledType = {
    ["BMX"] = true,
};

windowNames = {
    [2] = "jobb első",
    [4] = "bal első",
    [3] = "jobb hátsó",
    [5] = "bal hátsó",
};

windowNames2 = {
    [2] = "Jobb első",
    [4] = "Bal első",
    [3] = "Jobb hátsó",
    [5] = "Bal hátsó",
};

convert = {
    [0] = 4,
    [1] = 2,
    [2] = 5,
    [3] = 3,
};

doorNames = {
    [0] = "Motorháztető",
    [1] = "Csomagtartó",
    [2] = "Bal első",
    [3] = "Jobb első",
    [4] = "Bal hátsó",
    [5] = "Jobb hátsó",
};

doorNames2 = {
    [0] = "motorháztető",
    [1] = "csomagtartó",
    [2] = "bal első",
    [3] = "jobb első",
    [4] = "bal hátsó",
    [5] = "jobb hátsó",
};

function getVehicleHandlingProperty ( element, property )
    if isElement ( element ) and getElementType ( element ) == "vehicle" and type ( property ) == "string" then -- Make sure there's a valid vehicle and a property string
        local handlingTable = getVehicleHandling ( element );
        local value = handlingTable[property];
        
        if value then
            return value;
        end
    end
    
    return false;
end

keyItem = 16;

local serverSide = false;
addEventHandler("onResourceStart", resourceRoot, function()
    serverSide = true;
end);

hasBelt = {
    --[modelID] = true,
	[560] = true, --sultan
    [400] = true, --Tanulókocsi
    [480] = true, --comet
    [411] = true, --infernus
    [451] = true, --turismo
    [602] = true, --alpha
    [494] = true, --hotring racer 1
    [496] = true, --blistacompact
    [503] = true, --hotring racer 3
    [402] = true, --buffalo
    [551] = true, --merit
    [587] = true, --euros
    [533] = true, --feltzer
    [421] = true, --washington
    [506] = true, --supergt
    [527] = true, --cadrona
    [445] = true, --admiral
    [415] = true, --cheetah
    [502] = true, --hotring racer 2
    [419] = true, --esperanto
    [562] = true, --elegy
    [526] = true, --fortune
    [529] = true, --willard
    [550] = true, --sunrise
    [507] = true, --elegant
    [489] = true, --rancher 1
    [505] = true, --rancher 2
    [543] = true, --sadler
    [554] = true, --yosemite
    [585] = true, --yosemite
	[565] = true, --flash
	[559] = true, --jester
	[558] = true, --uranus
	[479] = true, --regina
	[405] = true, --sentinel
};

vehicleNames = {
    --[modelID] = name,
    [560] = "Mitsubishi Lancer Evolution X", --sultan
    [411] = "411", --infernus
    [451] = "Lamborghini Huracan", --turismo
    [436] = "Ford Mustang", --previon
    [429] = "Dodge Viper GTS", --banshee
    [480] = "Porsche 718 Boxster S", --comet
    [541] = "Chevrolet Corvette C7", --bullet
    [475] = "475", --sabre
    [602] = "Nissan GTR", --alpha
    [542] = "Chevrolet Chevelle SS", --clover
    [483] = "483", --camper
    [527] = "527", --cadrona
    [494] = "Mercedes-Benz SLS", --hotring racer 1
    [596] = "Ford Interceptor", --police ls
    [597] = "Dodge Charger RT", --police sf
    [598] = "Ford Interceptor", --police lv
    [416] = "Ambulance", --ambulance
    [496] = "496", --blistacompact
    [589] = "589", --club
    [410] = "410", --manana
    [503] = "Formula F1", --hotring racer 3
    [402] = "402", --hotring racer 3buffalo
    [551] = "BMW M5 F10", --merit
    [587] = "587", --euros
    [533] = "533", --feltzer
    [421] = "421", --washington
    [506] = "McLaren P1", --supergt
    [605] = "Chevrolet El Camino SS", --sadshit
    [604] = "604", --glenshit
    [466] = "466", --glenshit
    [401] = "401", --bravura
    [525] = "Chevrolet Silverado Vontató", --towtruck
    [555] = "555", --windsor
    [445] = "445", --admiral
    [415] = "Bugatti Veyron", --cheetah
    [502] = "Bugatti Chiron", --hotring racer 2
    [566] = "566", --tahmoma
    [518] = "518", --buccaneer
    [419] = "419", --esperanto
    [562] = "Nissan Skyline R34", --elegy
    [526] = "526", --fortune
    [580] = "Dodge Challenger SRT-8", --stafford
    [426] = "Ford Crown Victoria", --premier
    [529] = "529", --willard
    [474] = "474", --hermes
    [545] = "545", --hustler
    [517] = "517", --majestic
    [600] = "GMC Syclone", --picador
    [439] = "AMC Javelin", --stallion
    [491] = "Chevrolet Camaro SS", --virgo
    [546] = "546", --intruder
    [550] = "550", --sunrise
    [507] = "507", --elegant
    [603] = "603", --phoenix
    [477] = "BMW 850i", --zr350
    [413] = "Ford E150", --pony
    [482] = "GMC Vandura G1500", --burrito
    [579] = "Mercedes G500", --huntley
    [400] = "Subaru Forester XT", --landstalker
    [489] = "489", --rancher 1
    [505] = "Audi Q7", --rancher 2
    [500] = "500", --mesa
    [543] = "Ford F-350", --sadler
    [554] = "Dodge Ram 3500", --yosemite
    [585] = "Audi RS4", --emperor
    [516] = "516", --nebula
    [468] = "Suzuki RM-Z450", --sanchez
    [462] = "Honda Click", --faggio
    [581] = "Honda CB750", --bf-400
    [521] = "Ducati Desmosedici RR", --fcr-900
    [463] = "Harley-Davidson Springer Softail", --freeway
    [461] = "Yamaha XJ6", --pcj-600
    [586] = "Harley Davidson Fatboy", --wayfarer
    [522] = "BMW S1000 RR", --nrg-500
	[565] = "Volkswagen Golf GTI", --flash
	[559] = "Ford Focus", --jester
	[558] = "BMW M3", --uranus
	[561] = "Nissan Sentra", --stratum
	[535] = "Chevrolet C10", --slamvan
	[536] = "Dodge Coronet", --blade
	[575] = "Cadillac Eldorado", --broadway
	[576] = "Chevrolet Bel Air", --tornado
	[534] = "Lincoln Continental", --remington
	[567] = "Chevrolet Impala", --savana
	[578] = "Iveco Stralis", --dft30
	[479] = "Dodge Neon", --regina
	[467] = "Seat Leon Cupra R", --oceanic
	[405] = "Porsche Panamera Turbo", --sentinel
	[492] = "BMW M5 E34", --greenwood
	[599] = "Ford Ranger", --policeranger
	[478] = "478", --policeranger
	[422] = "Bobcat", --policeranger
};

TwoDoorVehicles = {
    --[modelID] = true,
    [605] = true, -- tanuló törött kocsi/sadshit
    [436] = true, -- previon
    [451] = true, -- turismo
    [429] = true, -- banshee
    [480] = true, -- comet
    [541] = true, -- bullet
    [411] = true, -- infernus
    [451] = true, -- turismo
    [475] = true, -- sabre
    [602] = true, -- alpha
    [542] = true, -- clover
    [483] = true, -- camper
    [527] = true, -- cadrona
    [494] = true, -- hotring racer 1
    [416] = true, -- ambulance
    [496] = true, -- blistacompact
    [589] = true, -- club
    [410] = true, -- manana
    [503] = true, -- hotring racer 3
    [402] = true, -- buffalo
    [533] = true, -- feltzer
    [506] = true, -- supergt
    [401] = true, -- bravura
    [525] = false, -- towtruck
    [555] = true, -- windsor
    [415] = true, -- cheetah
    [502] = true, -- hotring racer 2
    [518] = true, -- buccaneer
    [419] = true, -- esperanto
    [562] = true, -- elegy
    [526] = true, -- fortune
    [474] = true, -- hermes
    [545] = true, -- hustler
    [600] = true, -- picador
    [439] = true, -- stallion
    [491] = true, -- virgo
    [603] = true, -- phoenix
    [466] = true, -- zr350
    [489] = true, -- rancher
    [500] = true, -- mesa
    [543] = true, -- sadler
    [554] = true, -- yosemite
	[565] = true, -- flash
	[558] = true, --uranus
	[535] = true, --slamvan
	[536] = true, --blade
	[575] = true, --broadway
	[576] = true, --tornado
	[534] = true, --remington
	[567] = true, --savana
	[578] = true, --dft30
	[599] = true, --policeranger
	[478] = true, --policeranger
	[422] = true, --bobcat
};

function getVehicleName(model)
    if isElement(model) then
        model = getElementModel(model);
    end
    
    local vehName = vehicleNames[model];
    if not vehName or vehName == tostring(model) then
        vehName = getVehicleNameFromModel(model);
    end
    
    return vehName;
end

DisableWindowableVehs = {
    --[modelID] = true,
    [555] = true,
};

kmMultipler = {
    --[ModelID] = KM kénti minusz
    [560] = 0.5,
    [605] = 0.2, -- Tanulókocsi törött/sadshit
    [543] = 1.0, -- Tanulókocsi v2
    [451] = 1.0, -- turismo
    [411] = 1.2, -- infernus
    [420] = 1.0,
    [556] = 2.0,
    [436] = 0.2, -- previon
    [429] = 0.4, -- banshee
    [480] = 0.3, -- comet
    [541] = 0.6, -- bullet
    [475] = 0.7, -- sabre
    [602] = 0.9, -- alpha
    [542] = 0.2, -- clover
    [483] = 0.2, -- camper
    [527] = 0.4, -- cadrona
    [494] = 1.1, -- hotring racer 1
    [596] = 0.3, -- police ls
    [597] = 0.6, -- police sf
    [598] = 0.8, -- police lv
    [416] = 0.8, -- ambulance
    [496] = 0.3, -- blistacompact
    [589] = 0.2, -- club
    [410] = 0.2, -- manana
    [503] = 1.0, -- hotring racer 3
    [402] = 0.7, -- buffalo
    [551] = 0.5, -- merit
    [587] = 0.6, -- euros
    [533] = 0.9, -- feltzer
    [421] = 0.7, -- washington
    [506] = 1.0, -- supergt
    [604] = 0.4, -- glenshit
    [466] = 0.5, -- willard
    [401] = 0.3, -- bravura
    [525] = 0.6, -- towtruck
    [555] = 1.5, -- windsor
    [445] = 0.8, -- admiral
    [415] = 1.3, -- cheetah
    [502] = 1.4, -- hotring racer 2
    [566] = 0.2, -- tahoma
    [518] = 0.2, -- buccaneer
    [419] = 0.5, -- esperanto
    [562] = 0.6, -- elegy
    [526] = 0.7, -- fortune
    [580] = 0.4, -- stafford
    [426] = 0.6, -- premier
    [529] = 0.3, -- willard
    [474] = 0.3, -- hermes
    [545] = 0.2, -- huster
    [517] = 0.5, -- majestic
    [600] = 0.5, -- picador
    [439] = 0.6, -- stallion
    [491] = 0.5, -- virgo
    [546] = 0.2, -- intruder
    [550] = 0.4, -- sunrise
    [507] = 0.5, -- elegant
    [603] = 0.7, -- elegant
    [477] = 0.8, -- zr350
    [413] = 0.4, -- pony
    [482] = 0.6, -- burrito
    [400] = 0.6, -- landstalker
    [579] = 0.5, -- huntley
    [489] = 0.4, -- rancher
    [505] = 0.7, -- rancher 2
    [500] = 0.3, -- mesa
    [543] = 0.6, -- sadler
    [554] = 0.8, -- yosemite
    [585] = 0.6, -- emperor
    [516] = 0.4, -- nebula
    [468] = 0.08, -- sanchez
    [462] = 0.06, -- faggio
    [581] = 0.1, -- bf-400
    [521] = 0.2, -- fcr-900
    [463] = 0.2, -- freeway
    [461] = 0.3, -- pcj-600
    [586] = 0.1, -- wayfarer
    [522] = 0.3, -- nrg-500
	[565] = 0.4, -- flash
	[559] = 0.5, -- jester
	[558] = 0.6, --uranus
	[561] = 0.7, --stratum
	[535] = 0.9, --slamvan
	[536] = 1.0, --blade
	[575] = 1.0, --broadway
	[576] = 1.0, --tornado
	[534] = 1.0, --remington
	[567] = 1.0, --savana
	[578] = 2.0, --dft30
	[479] = 0.6, --regina
	[467] = 0.5, --oceanic
	[405] = 0.8, --sentinel
	[492] = 0.5, --greenwood
	[599] = 0.7, --policeranger
	[478] = 0.7, --policeranger
	[422] = 0.5, --policeranger
};

for i = 300, 700 do
    if not kmMultipler[i] then
        kmMultipler[i] = 0.3
    end
end

maxFuel = {
	[514] = 100,
	[515] = 100,
    [560] = 80,
    [605] = 40, -- Tanulókocsi törött
    [543] = 125, -- Tanulókocsi v2
    [411] = 95, -- infernus
    [451] = 79, -- turismo
    [533] = 100,
    [420] = 50,
    [556] = 500,
    [436] = 38, -- previon
    [429] = 72, -- banshee
    [480] = 64, -- comet
    [541] = 74, -- bullet
    [475] = 68, -- sabre
    [602] = 72, -- alpha
    [542] = 52, -- clover
    [483] = 42, -- camper
    [527] = 71, -- cadrona
    [494] = 89, -- hotring racer 1
    [596] = 62, -- police ls
    [597] = 80, -- police sf
    [598] = 70, -- police lv
    [416] = 100, -- ambulance
    [496] = 48, -- blicstacompact
    [589] = 44, -- club
    [410] = 36, -- manana
    [503] = 85, -- hotring racer 3
    [402] = 60, -- buffalo
    [551] = 75, -- merit
    [587] = 70, -- euros
    [533] = 79, -- feltzer
    [421] = 90, -- washington
    [506] = 74, -- supergt
    [604] = 94, -- glenshit
    [466] = 95, -- willard
    [401] = 45, -- bravura
    [525] = 94, -- towtruck
    [555] = 130, -- windsor
    [445] = 74, -- admiral
    [415] = 100, -- cheetah
    [502] = 100, -- hotring racer 2
    [566] = 68, -- tahoma
    [518] = 56, -- buccaneer
    [419] = 72, -- esperanto
    [562] = 70, -- elegy
    [526] = 60, -- fortune
    [580] = 63, -- stafford
    [426] = 64, -- premier
    [529] = 55, -- willard
    [474] = 75, -- hermes
    [545] = 39, -- hustler
    [517] = 88, -- majestic
    [600] = 100, -- majestic
    [439] = 75, -- stallion
    [491] = 55, -- virgo
    [546] = 39, -- intruder
    [550] = 85, -- sunrise
    [507] = 80, -- elegant
    [603] = 64, -- phoenix
    [477] = 82, -- zr350
    [413] = 83, -- pony
    [482] = 115, -- burrito
    [400] = 93, -- landstalker
    [579] = 74, -- huntley
    [489] = 54, -- rancher
    [505] = 100, -- rancher 2
    [500] = 50, -- mesa
    [543] = 109, -- sadler
    [554] = 120, -- yosemite
    [585] = 70, -- emperor
    [516] = 60, -- nebula
    [468] = 7, -- sanchez
    [462] = 5, -- faggio
    [581] = 18, -- bf-400
    [521] = 15, -- fcr-900
    [463] = 19, -- freeway
    [461] = 16, -- pcj-600
    [586] = 18, -- wayfarer
    [522] = 17, -- nrg-500
	[565] = 65, --flash
	[559] = 70, --jester
	[558] = 75, --uranus
	[561] = 85, --stratum
	[535] = 90, --slamvan
	[536] = 90, --blade
	[575] = 90, --broadway
	[576] = 95, --tornado
	[534] = 100, --remington
	[478] = 100, --remington
	[567] = 85, --savana
	[578] = 100, --dft30
	[479] = 60, --regina
	[467] = 55, --oceanic
	[405] = 90, --sentinel
	[492] = 60, --greenwood
	[599] = 65, --policeranger
	[422] = 100, --bobcat
};

for i = 300, 700 do
    if not maxFuel[i] then
        maxFuel[i] = 0.3
    end
end

function getMaxFuel()
    return maxFuel
end

function getVehicleMaxFuel(model)
    if isElement(model) then
        model = getElementModel(model);
    end

    local num = maxFuel[model];
    if not num then
        num = maxFuel[model];
    end

    return num or 100;
end

function isWindowableVeh(model)
    if isElement(model) then
        model = getElementModel(model);
    end

    return not DisableWindowableVehs[model];
end

function getTime()
    local time = getRealTime();
    local hour = time.hour;
    local minute = time.minute;
    local month = time.month;
    local monthday = time.monthday + 1;
    local year = 1900 + time.year;

    if hour < 10 then
        hour = "0" .. tostring(hour);
    end

    if minute < 10 then
        minute = "0" .. tostring(minute);
    end

    if month < 10 then
        month = "0" .. tostring(month);
    end

    if monthday < 10 then
        monthday = "0" .. tostring(monthday);
    end

    return "["..year.."."..month.."."..monthday.." "..hour..":"..minute.."]";
end