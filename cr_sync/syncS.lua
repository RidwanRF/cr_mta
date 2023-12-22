addEventHandler("onResourceStart", resourceRoot, function()
	updateTime();
end);

function updateTime()
	local realTime = getRealTime();
	hour = realTime.hour - 1;

	if hour >= 24 then
		hour = hour - 24;
	elseif hour < 0 then
		hour = hour + 24;
	end

	setTime(hour, realTime.minute);
	setMinuteDuration(60000);

	outputDebugString("Real time: " .. ("%02d"):format(realTime.hour - 1) .. ":" .. ("%02d"):format(realTime.minute));
	outputDebugString("Server time: " .. ("%02d"):format(hour) .. ":" .. ("%02d"):format(realTime.minute));

	changeTrafficControl();
	fetchWeather();
end
setTimer(updateTime, 1000 * 60 * 10, 0);

function changeTrafficControl()
	if (hour >= 22 and #getElementsByType("player") < 20) or (hour < 9 and #getElementsByType("player") < 20) then
		if not isTimer(trafficTimer) then
			trafficTimer = setTimer(function()
                setTrafficLightState((getTrafficLightState() == 9) and 6 or 9);
			end, 500, 0);
		end
	else
		if isTimer(trafficTimer) then
			killTimer(trafficTimer);
			setTrafficLightState("auto");
		end
	end
end

addEventHandler("onPlayerJoin", root, function()
	changeTrafficControl();
end);

addEventHandler("onPlayerQuit", root, function()
	changeTrafficControl();
end);

local gtaNames = {
    ["Haze"] = math.random(12, 15),
    ["Mostly Cloudy"] = 2,
    ["Clear"] = 10,
    ["Cloudy"] = math.random(0, 7),
    ["Flurries"] = 32,
    ["Fog"] = math.random(0, 7),
    ["Mostly Sunny"] = math.random(0, 7),
    ["Partly Cloudy"] = math.random(0, 7),
    ["Partly Sunny"] = math.random(0, 7),
    ["Freezing Rain"] = 16,
    ["Rain"] = 16,
    ["Sleet"] = 16,
    ["Snow"] = 31,
    ["Sunny"] = 11,
    ["Thunderstorms"] = 8,
    ["Thunderstorm"] = 8,
    ["Unknown"] = 0,
    ["Overcast"] = 7,
    ["Scattered Clouds"] = 7,
};

local temperature = 0;
function fetchWeather()
    setRainLevel(0);
 
    fetchRemote("http://api.wunderground.com/api/11a4253885543613/conditions/q/zmw:00000.38.12843.json", function(data)
        local new = fromJSON(data);
        local wind = tonumber(new["current_observation"]["wind_kph"]) / 4 or 0;
        local weather = tostring(new["current_observation"]["weather"]);
		temperature = tonumber(new["current_observation"]["temp_c"]) or 0;

        if wind > 5 then
            wind = 3;
        end
 
        setWindVelocity(wind, wind, wind);
        setWaveHeight(wind < 2 and 0.1 or 0.6);
 
        if gtaNames[weather] then
            setWeather(gtaNames[weather]);
        else
            setWeather(31);
        end
 
        outputDebugString("weather - " .. weather .. "  | wind - " .. wind);
    end, nil, true);
end

local armors = {};

addEvent("sync->Armor", true);
addEventHandler("sync->Armor", root, function(player)
    --if client and client == player then
    --outputChatBox("sa")
    if isElement(armors[player]) and player.armor < 40 then
        destroyElement(armors[player]);
    else
        if player.armor >= 40 then
            armors[player] = Object(1242, 0, 0, 0);
            armors[player].collisions = false
            armors[player].scale = 1.85;
            exports.cr_bone_attach:attachElementToBone(armors[player], player, 3, 0, 0.035, 0.025, 0, 0, 0);
        end
    end
    --end
end);

addEventHandler("onPlayerQuit", root, function()
    if isElement(armors[source]) then
        destroyElement(armors[source]);
    end
end);

function getTemperature()
	return temperature;
end