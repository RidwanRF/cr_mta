addEventHandler("onClientResourceStart", resourceRoot, function()
	setElementData(localPlayer, "char->Fishing", false);

	engineImportTXD(engineLoadTXD("files/fishingrod.txd"), 338);
	engineReplaceModel(engineLoadDFF("files/fishingrod.dff"), 338);

	tick = getTickCount() - 2500;

	floats = {};
	moves = {};

	check = false;
end);

local c = exports.cr_core:getServerSyntax("Horgászat", "lightyellow");

local _outputChatBox = outputChatBox;
local outputChatBox = function(str)
	_outputChatBox(c .. str, 0, 0, 0, true);
end

local ped = Ped(259, 148.58955383301, -1919.2985839844, 3.7734375, 270);
setElementData(ped, "ped.name", "Peter Griffin");
setElementData(ped, "ped.type", "Halfelvásárló");
ped.frozen = true;

function createFishingRod()
	if not localPlayer.vehicle then
		if isTimer(receiveTimer) then
			killTimer(receiveTimer);
		end

		if try then 
            return false
        end

		triggerServerEvent("fishing->CreateRod", localPlayer, localPlayer);
		exports.cr_chat:createMessage(localPlayer, (getElementData(localPlayer, "char->Fishing") and "elrak" or "elővesz") .. " egy horgászbotot", 1);
        
        return not getElementData(localPlayer, "char->Fishing");
	else
        local syntax = exports['cr_core']:getServerSyntax(nil, "error");
		outputChatBox(syntax .. "Kocsiban ülve nem veheted elő", 255, 255, 255, true); --ne gondolj rosszra :c
        
        return false
	end
end

addEvent("fishing->Sync", true);
addEventHandler("fishing->Sync", root, function(f, r)
	floats = f;
	rods = r;

	check = true;
end);

addEventHandler("onClientRender", root, function()
	for key, value in pairs(floats) do
		if check and key == localPlayer and getDistanceBetweenPoints3D(unpack({startPosition}), unpack({localPlayer.position})) > 4 then
			triggerServerEvent("fishing->CreateFloat", localPlayer, localPlayer, _, _);
			exports.cr_chat:createMessage(localPlayer, "kiveszi a vízből a úszót", 1);

			if isTimer(receiveTimer) then
				killTimer(receiveTimer);
			end
			
			check = false;
		end

		local px, py, pz = getPositionFromElementOffset(rods[key], 0.01, 0, 1.84);

		if isElement(value) then
			dxDrawLine3D(px, py, pz, unpack({value.position}), tocolor(255, 255, 255, 128), 0.5, false);
		end
	end
end);

setTimer(function()
	for key, value in pairs(floats) do
		if not moves[value] then
			moves[value] = "-";
		end

		b = math.random(0, 2) == 1;
		count = b and 0.03 or 0.007;

		if moves[value] == "-" then
			z = value.position.z - count;
		else
			z = value.position.z + count
		end

		if z >= 0 then
			moves[value] = "-";
		elseif (b and z <= -0.20) or (not b and z <= -0.05) then
			moves[value] = "+";
		end

		setElementPosition(value, value.position.x, value.position.y, z);
	end
end, 95, 0);

addEventHandler("onClientClick", root, function(button, state, x, y, wx, wy, wz, element)
	if button == "left" and state == "down" and getElementData(localPlayer, "char->Fishing") and getTickCount() - 1500 > tick then
		if testLineAgainstWater(wx, wy, wz, wx, wy, wz + 500) then
			wx, wy, wz = getWorldFromScreenPosition(x, y, 20);
			
			if isLineOfSightClear(wx, wy, wz, wx, wy, wz + 500) then
				if isTimer(receiveTimer) then
					triggerServerEvent("fishing->CreateFloat", localPlayer, localPlayer, _, _);
					exports.cr_chat:createMessage(localPlayer, "kiveszi a vízből a úszót", 1);

					killTimer(receiveTimer);
				else
					triggerServerEvent("fishing->CreateFloat", localPlayer, localPlayer, wx, wy);
					exports.cr_chat:createMessage(localPlayer, "bedobja a vízbe a úszót", 1);
					startPosition = localPlayer.position;

					receiveTimer = setTimer(function()
						try = true;

						triggerServerEvent("fishing->AnimPlayer", localPlayer, localPlayer, "SWORD", "sword_IDLE");
						fishSound = playSound("files/reel.mp3", true);

						exports.cr_chat:createMessage(localPlayer, "Kapása van", "do");
						exports.cr_minigame:createMinigame(localPlayer, 2, "cr_fishing");
					end, math.random(10, 300) * 1000, 1); --> 10 sec <--> 5 min
				end
			end
		end
	end
end);

addEvent("[Minigame - StopMinigame]", true);
addEventHandler("[Minigame - StopMinigame]", root, function(player, array)
	if player == localPlayer and array[1] == 2 and array[2] == "cr_fishing" then
		try = false;

		stopSound(fishSound);

		triggerServerEvent("fishing->AnimPlayer", localPlayer, localPlayer, false, false);

		if array[3] >= array[5] then
			local fish = math.random(86, 96);

			exports.cr_infobox:addBox("success", "Sikeresen kifogtál valamit: " .. exports.cr_inventory:getItemName(fish));
			exports.cr_chat:createMessage(localPlayer, "kifog valamit (" .. exports.cr_inventory:getItemName(fish) .. ")", 1);

			exports.cr_inventory:giveItem(localPlayer, fish, fish);
		
			triggerServerEvent("fishing->CreateFloat", localPlayer, localPlayer, _, _);
		else
			triggerServerEvent("fishing->CreateFloat", localPlayer, localPlayer, _, _);

			if isTimer(receiveTimer) then
				killTimer(receiveTimer);
			end
			
			check = false;
			
			exports.cr_infobox:addBox("error", "Sajnos nem sikerült kifognod a halat");
			exports.cr_chat:createMessage(localPlayer, "kiveszi a vízből a úszót", 1);
		end
	end
end);

function getPositionFromElementOffset(element, offX, offY, offZ)
	if element then
		local m = getElementMatrix(element);

		local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1];
		local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2];
		local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3];

		return x, y, z;
	end
end