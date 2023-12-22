-- nem tudom kiírta, de én csak használhatóvá tettem --Jack
-- a kód full szarul van felépítve, idegrendszerem hozzá nincs --Royalf&Jack
-- mindenesetre rohadjon meg aki ezt írta -- Royalf
-- megcsináltam egy rakás szarásgot őszíntén az ideg szétbaszott, xanax volt a vacsorám aznap este -- THMMS

function setElementHealthDriving(e, h, l)
    setElementHealth(e, h);
        
    if l > 3 then
        triggerClientEvent(localPlayer, "onDamage", localPlayer);
    end
end
addEvent("setElementHealthDriving", true)
addEventHandler("setElementHealthDriving", root, setElementHealthDriving)

local mysql = exports.cr_mysql;

addEventHandler("onResourceStart", resourceRoot,
    function()
        startResource(getResourceFromName("cr_tempomat"))
        startResource(getResourceFromName("cr_index"))
        startResource(getResourceFromName("cr_elements"))
		Async:setPriority("high")
		Async:setDebug(true)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        stopResource(getResourceFromName("cr_tempomat"))
        stopResource(getResourceFromName("cr_index"))
        stopResource(getResourceFromName("cr_elements"))
    end
)

local loadedVehicles = {};
local loader = {};
local loaderTimer;
local cache = {};
local plateTexts = {};
local owned_vehicles = {};

function generatePlateText()
    local plate1 = generateString(3, false, true);
    local plate2 = generateString(3, true, false);
    local plate = tostring(plate1) .. "-" .. tostring(plate2);
    if plateTexts[plate] then
        plate = generatePlateText();
    end
    return string.upper(plate);
end

function generateChassisNumber()
    local chassis = "";

    chassis = chassis .. generateString(10, false, true);
    chassis = chassis .. generateString(3, true, false);
    chassis = chassis .. generateString(4, false, true);

    --print(chassis)
    return string.upper(chassis);
end

addEventHandler("onResourceStart", resourceRoot, function()
    local loaded_vehicles = getElementData(root, "vehicles:loadedVehicles");
    local plates = getElementData(root, "vehicles:plateTexts");
    local cache_save = getElementData(root, "vehicles:cache");
        
	for i, v in pairs(getElementsByType("player")) do
		dbQuery(function(query)
			local query, query_lines = dbPoll(query, 0);
			if query_lines > 0 then
				for i, row in pairs(query) do
					local id = row["id"];
					local owner = row["owner"];
					if not loadedVehicles[id] then
						rowToTable(row);
						-- outputChatBox("Nem, nem basz szét az ideg... xanax beüt, nem kell sok", root)
						table.insert(loader, row);	
						if not isTimer(loaderTimer) then
							loaderTimer = setTimer(function() loadOneVehicle() end, 50, 1);
						end
					end
				end
			end
			outputDebugString("Loaded "..query_lines.." player vehicle's"); 
		end, mysql:requestConnection(), "SELECT * FROM vehicle WHERE faction = 0 AND owner = ?", v:getData("acc >> id"));    
	end
	
    loadDefaultVehicles(true);
end);

addEventHandler("onPlayerQuit", getRootElement(), function()
	local id = tonumber(source:getData("acc >> id"))
	if(owned_vehicles[id]) then
		for i, v in pairs(owned_vehicles[id]) do
			saveVehicle(tonumber(v:getData("veh >> id")))
			setTimer(function()
				loadedVehicles[tonumber(v:getData("veh >> id"))] = false
				v:destroy()
				table.remove(owned_vehicles[id], i)
			end, 100, 1)
		end
	end
end);

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(loaderTimer) then
        killTimer(loaderTimer);
    end
    loader = {};
end);

function rowToTable(row)
    local id = tonumber(row["id"]);
    local modelid = tonumber(row["modelid"]);
    local pos = tostring(row["pos"]);
    local owner = tonumber(row["owner"]);
    local fuel = tonumber(row["fuel"]);
    local engine = tostring(row["engine"]);    
    local engineBroken = tostring(row["engineBroken"]);
    local light = tostring(row["light"]);
    local plate = tostring(row["plate"]);
    local odometer = tonumber(row["odometer"]);
    local locked = tostring(row["locked"]);    
    local health = tonumber(row["health"]);    
    local colors = tostring(row["colors"]);
    local windows = tostring(row["windows"]);    
    local panels = tostring(row["panels"]);
    local wheels = tostring(row["wheels"]);
    local lights = tostring(row["lights"]);
    local doors = tostring(row["doors"]);
    local handbrake = tostring(row["handbrake"]);
    local damageProof = tostring(row["damageProof"]);
    local lastOilRecoil = tonumber(row["lastOilRecoil"]);
    local variant = tostring(row["variant"]);
    local headlight = tostring(row["headlight"]);
    local kmColor = tostring(row["kmColor"]);
    local parkPos = tostring(row["parkPos"]);
    local protect = tostring(row["protect"]);
    local faction = tonumber(row["faction"]);
    local fueltype = tostring(row["fueltype"]);
    local maxkm = tonumber(row["maxkm"]);
    local chassis = row["chassis"];

    cache[id] = {
        ["modelid"] = modelid,
        ["pos"] = pos,
        ["owner"] = owner,
        ["fuel"] = fuel,
        ["engine"] = engine,
        ["engineBroken"] = engineBroken,
        ["light"] = light,
        ["plate"] = plate,
        ["odometer"] = odometer,
        ["locked"] = locked,
        ["health"] = health,
        ["colors"] = colors,
        ["windows"] = windows,
        ["panels"] = panels,
        ["wheels"] = wheels,
        ["lights"] = lights,
        ["doors"] = doors,
        ["handbrake"] = handbrake,  
        ["damageProof"] = damageProof,
        ["lastOilRecoil"] = lastOilRecoil,
        ["variant"] = variant,
        ["headlight"] = headlight,
        ["kmColor"] = kmColor,
        ["parkPos"] = parkPos,
        ["protect"] = protect,
        ["faction"] = faction,
        ["fueltype"] = fueltype,
        ["maxkm"] = maxkm,
        ["chassis"] = chassis,
    };
    
    return true;
end

function setVehicleOwner(player, veh, target)
	local id = tonumber(player:getData("acc >> id"))
	if(owned_vehicles[id]) then
		for i, v in pairs(owned_vehicles[id]) do
			if(v == veh) then
				table.remove(owned_vehicles[id], i)
			end
		end
	end
	local t_id = tonumber(target:getData("acc >> id"))
	if(not owned_vehicles[t_id]) then
		owned_vehicles[t_id] = {}
	end
	table.insert(owned_vehicles[t_id], veh)
	dbExec(mysql:requestConnection(), "UPDATE vehicle SET owner = ? WHERE id = ?", t_id, tonumber(veh:getData("veh >> owner")))
	veh:setData("veh >> owner", t_id)
	-- exports.cr_inventory:giveItem(target, 16, tonumber(veh:getData("veh >> owner")), 1, 100)
end

addEvent("server->loadPlayerVehicles", true);
addEventHandler("server->loadPlayerVehicles", getRootElement(), function(dbid)
    if client and dbid then
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0);
            if query_lines > 0 then
                for i, row in pairs(query) do
                    local id = row["id"];
                    local owner = row["owner"];
                    if not loadedVehicles[id] then
                        rowToTable(row);
						-- outputChatBox("Nem, nem basz szét az ideg... xanax beüt, nem kell sok", root)
						table.insert(loader, row);	
                        if not isTimer(loaderTimer) then
                            loaderTimer = setTimer(function() loadOneVehicle() end, 50, 1);
                        end
                    end
                end
            end
            outputDebugString("Loaded "..query_lines.." player vehicle's"); 
        end, mysql:requestConnection(), "SELECT * FROM vehicle WHERE faction = 0 AND owner = ?", dbid);    
    end
end);

function loadDefaultVehicles()
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, row in pairs(query) do
                local id = row["id"];
                if not loadedVehicles[id] then
                    rowToTable(row);
                    table.insert(loader, row);
                    if not isTimer(loaderTimer) then
                        loaderTimer = setTimer(function() loadOneVehicle() end, 50, 1);
                    end
                end
            end
        end
        outputDebugString("Loaded "..query_lines.." faction vehicle's");
    end, mysql:requestConnection(), "SELECT * FROM vehicle WHERE faction > 0 AND owner = 0");
end

function findVehicle(id)
	id = tonumber(id)
	for i, v in pairs(getElementsByType("vehicle")) do 
		if(v:getData("veh >> id") == id) then
			return v
		end
	end 
	return false
end

local loaderTimers = {}
function loadOneVehicle(data, fade)
    if #loader > 0 or data then
        local row = data and data or loader[1];
        if row then
            local id = tonumber(row["id"]);
            
            if loadedVehicles[id] then
                -- if not data then
                    table.remove(loader, 1);
                    return;
                -- end
            end
            
            local data = cache[id];
            
            if data then
                local modelid = data["modelid"];
                local pos = fromJSON(data["pos"]);
                local owner = data["owner"];
                local fuel = data["fuel"];
                local engine = data["engine"];
                local engineBroken = data["engineBroken"];
                local light = data["light"];
                local plate = data["plate"];
                local chassis = data["chassis"];
                
                if not plate or plate == "" or plate == " " then
                    local newPlate = generatePlateText();
                    cache[id]["plate"] = newPlate;
                    plate = newPlate;
                end
                
                local plate = string.upper(plate);
                plateTexts[plate] = true;
                
                local odometer = data["odometer"];
                local locked = data["locked"];
                local health = data["health"];
                local colors = fromJSON(data["colors"]);
                local windows = fromJSON(data["windows"]);
                local panels = fromJSON(data["panels"]);
                local wheels = fromJSON(data["wheels"]);
                local lights = fromJSON(data["lights"]);
                local doors = fromJSON(data["doors"]);
                local handbrake = data["handbrake"];
                local damageProof = data["damageProof"];
                local lastOilRecoil = data["lastOilRecoil"];
                local variant = fromJSON(data["variant"]);
                local headlight = fromJSON(data["headlight"]);
                local hr, hg, hb = unpack(headlight);
                local variant1, variant2 = unpack(variant);
                local x,y,z,rx,ry,rz,int,dim,dim2 = unpack(pos);
                local kmColor = fromJSON(data["kmColor"]);
                local parkPos = fromJSON(data["parkPos"]);
                local protect = data["protect"];
                local faction = data["faction"];
                local fueltype;
                local maxkm;
                
				local foundVehicle = findVehicle(id)
                
				--outputChatBox(tostring(foundVehicle).." "..id)
				if(isElement(foundVehicle)) then
                    if modelid == 416 then
                        local veh = foundVehicle
                        local obj = createObject(11625, 0,0,0)
                        attachElements(obj, veh, 0, -1, 0.35)
                        veh:setData("veh >> ambulanceBed", true)
                        veh:setData("veh >> ambulanceBedE", obj)
                    end
                    
					table.remove(loader, 1);
					-- outputChatBox(id)
				else
					local vehicle = exports.cr_elements:createVehicle(modelid, x, y, z, rx, ry, rz);
                    
                    if modelid == 416 then
                        local veh = vehicle
                        local obj = createObject(11625, 0,0,0)
                        attachElements(obj, veh, 0, -1, 0.35)
                        veh:setData("veh >> ambulanceBed", true)
                        veh:setData("veh >> ambulanceBedE", obj)
                    end
                    
					if vehicle then
						if(not fade) then
							vehicle:setAlpha(0)
							vehicle:setCollisionsEnabled(false)
							vehicle:setFrozen(true)
							loaderTimers[id] = setTimer(function(v) 
								vehicle:setFrozen(true)
								local alpha = v:getAlpha()
								v:setAlpha(alpha+63.75)
								if(alpha+63.75 >= 250) then
									v:setFrozen(false)
									v:setAlpha(255)
									v:setCollisionsEnabled(true)
								end
							end, 2500, 4, vehicle)
						end
						
						local oldfueltype = tostring(getVehicleHandlingProperty(vehicle, "engineType"));
						local handling = getModelHandling(getElementModel(vehicle))
						if(not data["fueltype"] or data["fueltype"] == nil or data["fueltype"] == "" or data["fueltype"] == "false" or data["fueltype"] == "nil") then
							fueltype = tostring(getVehicleHandlingProperty(vehicle, "engineType"));
						else
							fueltype = data["fueltype"];
						end

						if fueltype == tostring(getVehicleHandlingProperty(vehicle, "engineType")) then
							maxkm = 0;
						else
							maxkm = data["maxkm"];
						end
						
						loadedVehicles[id] = vehicle;
						setVehiclePlateText(vehicle, plate);
						setVehicleRespawnPosition(vehicle, x,y,z,rx,ry,rz);
						
						setElementDimension(vehicle, dim);
						setElementInterior(vehicle, int);
						setElementData(vehicle, "veh >> loaded", true);
						setElementData(vehicle, "veh >> id", id);
						setElementData(vehicle, "veh >> owner", owner);
						setElementData(vehicle, "veh >> fuel", fuel);
						setElementData(vehicle, "veh >> oldfueltype", oldfueltype);
						setElementData(vehicle, "veh >> fueltype", fueltype);
						setElementData(vehicle, "veh >> maxkm", maxkm);
						setElementData(vehicle, "veh >> chassis", chassis);
						
						if(faction == 0) then
							if(not owned_vehicles[owner]) then
								owned_vehicles[owner] = {}
							end
							table.insert(owned_vehicles[owner], vehicle)
						end
						
						if engine == "true" then
							engine = true;
						else
							engine = false;
						end
						
						setElementData(vehicle, "veh >> engine", engine);
						
						if getVehicleType(vehicle) == "Bike" then
							setElementData(vehicle, "veh >> engine", false);
						end
						
						if handbrake == "true" then
							handbrake = true;
						else
							handbrake = false;
						end
						
						setElementData(vehicle, "veh >> handbrake", handbrake);
						
						if damageProof == "true" then
							damageProof = true;
						else
							damageProof = false;
						end
						setElementData(vehicle, "veh >> damageProof", damageProof);
						setElementData(vehicle, "veh >> odometer", odometer);
						setElementData(vehicle, "veh >> lastOilRecoil", lastOilRecoil);
						
						if locked == "true" then
							locked = true;
						else
							locked = false;
						end
						
						setElementData(vehicle, "veh >> locked", locked);
						setElementData(vehicle, "veh >> KM/H Color", kmColor);
						setElementData(vehicle, "veh >> park", parkPos);
						
						if protect == "true" then
							protect = true;
						else
							protect = false;
						end
						
						setElementData(vehicle, "veh >> protect", protect);
						setElementData(vehicle, "veh >> faction", faction);
						
						setVehicleVariant(vehicle, variant1, variant2);
						
						for k,v in pairs(lights) do
							local k = k - 1;
							setElementData(vehicle, "veh >> light"..k.."State", v);
						end
						
						if light == "true" then
							light = true;
						else
							light = false;
						end
						
						setElementData(vehicle, "veh >> light", light);
						
						setElementFrozen(vehicle, getElementData(vehicle, "veh >> handbrake"));
						if getVehicleType(vehicle) ~= "Bike" and getVehicleType(vehicle) ~= "BMX" and getVehicleType(vehicle) ~= "Quad" then
							local window = false;
							
							for k,v in pairs(windows) do
								local state = v;
								if state == "true" then
									state = true;
								else
									state = false;
								end
								
								local k = k + 1;
								window = true;
								setElementData(vehicle, "veh >> window"..k.."State", state);
							end
							if window then
								setElementData(vehicle, "veh >> windowState", true);
							end
						end
						
						for k,v in pairs(doors) do
							local k = k - 1;
							setVehicleDoorState(vehicle, k, v);
						end
						
						for k,v in pairs(panels) do
							local num = k - 1;
							setVehiclePanelState(vehicle, num, v);
						end
						
						local frontLeft, rearLeft, frontRight, rearRight = unpack(wheels);
						setVehicleWheelStates(vehicle, frontLeft, rearLeft, frontRight, rearRight);
						setVehicleColor(vehicle, unpack(colors));
						setVehicleHeadLightColor(vehicle, hr, hg, hb);
						setElementHealth(vehicle, health);
						
						if health <= 300 then
							setElementHealth(vehicle, 300);
						end
						
						if engineBroken == "true" then
							engineBroken = true;
						else
							engineBroken = false;
						end
						
						setElementData(vehicle, "veh >> engineBroken", engineBroken);
						
						table.remove(loader, 1);
						if #loader > 0 then
							loaderTimer = setTimer(function() loadOneVehicle() end, 50, 1);
						end
						
						
						
						return true;
					-- else
						-- outputChatBox("KIBASZOTT AUTÓ RENDSZER NEM TÖLTI BE A KURVA KOCSIKAT HEHEH AZ IDEG PEDIG NEM BASZ SZÉT!!!!", root)
					end
				end
            end
        end
    end
end

function makeVehicle(e, model, pos, color)
    dbExec(mysql:requestConnection(), "INSERT INTO `vehicle` SET `modelid`=?, `owner`=?, `faction`=?, `pos`=?, `parkPos`=?, `colors`=?, `chassis`=?", model, e:getData("acc >> id"), 0, toJSON(pos), toJSON(pos), toJSON(color),generateChassisNumber());
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, row in pairs(query) do
                if rowToTable(row) then
                    table.insert(loader, row);
                    local id = row["id"]; 
					-- outputChatBox(id)
                    if not isTimer(loaderTimer) then
                        loaderTimer = setTimer(function(r) loadOneVehicle(r) end, 50, 1, row);
                    end
                    exports['cr_inventory']:giveItem(e, keyItem, id, 1, 100, 0, 0, model);
                        --giveItem(sourceElement, itemid, value, count, status, dutyitem, premium, nbt)
                    exports.cr_carshop:addNewVehicleToCount(model);
                end
            end
        end
    end, mysql:requestConnection(), "SELECT * FROM vehicle WHERE id=LAST_INSERT_ID()");
end

function onLock(source, state)
    local left, right, middle = getElementData(source, "index.left"), getElementData(source, "index.right"), getElementData(source, "index.middle");
    local l0, l1, l2, l3 = getVehicleLightState(source, 0), getVehicleLightState(source, 1), getVehicleLightState(source, 2), getVehicleLightState(source, 3);
    local light1 = getElementData(source, "veh >> light");
    
    setElementData(source, "veh >> light", true);
    
    setTimer(function()
        setElementData(source, "veh >> light", false);
            
        setTimer(function()
            setVehicleLightState(source, 0, l0);
            setVehicleLightState(source, 1, l1);
            setVehicleLightState(source, 2, l2);
            setVehicleLightState(source, 3, l3);
                    
            setElementData(source, "veh >> light",  light1);
            setElementData(source, "index.left", left);
                    
            if left then
                exports["cr_index"]:startIndex(source, "index.left");
            end
            setElementData(source, "index.right",right);

            if right then
                exports["cr_index"]:startIndex(source, "index.right");
            end
            setElementData(source, "index.middle",middle);

            if middle then
                exports["cr_index"]:startIndex(source, "index.middle");
            end
        end, 400, 1);
    end, 400, 1);
end
addEvent("onLock", true);
addEventHandler("onLock", root, onLock);

addEventHandler("onElementDataChange", root, function(dName)
    if getElementType(source) == "vehicle" then
        local value = getElementData(source, dName);
        if dName == "veh >> engine" then
            setVehicleEngineState(source, value);
        elseif dName == "veh >> damageProof" then
            setVehicleDamageProof(source, value);
        elseif dName == "veh >> light" then
            if value then
                setVehicleOverrideLights(source, 2);
            else
                setVehicleOverrideLights(source, 1);
            end
        elseif utfSub(dName, 1, 12) == "veh >> light" and #dName > 12 then
            local num = tonumber(utfSub(dName, 13, 13));
                
            if num then
                setVehicleLightState(source, num, value);
            end
        elseif dName == "veh >> locked" then
            setVehicleLocked(source, value);
        end
    end
end);

addEventHandler("onVehicleDamage", root, function(loss)
    if getElementData(source, "veh >> engineBroken") then
        if getElementData(source, "veh >> engine") then
            setElementData(source, "veh >> engine", false);
        end
            
        if getVehicleEngineState(source) then
            setVehicleEngineState(source, false);
        end
            
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        cancelEvent();
    end

    if getElementHealth(source) <= 300 then
        if getVehicleType(source) == "BMX" then return; end
            
        if getElementHealth(source) <= 300 then
            setElementHealth(source, 300);
        end
            
        if not getElementData(source, "veh >> engineBroken") then
            setElementData(source, "veh >> engineBroken", true);
                
            if getElementData(source, "veh >> engine") then
                setElementData(source, "veh >> engine", false);
            end
                
            if getVehicleEngineState(source) then
                setVehicleEngineState(source, false);
            end
        end
        cancelEvent();
    end
end);

addEventHandler("onVehicleStartExit", root, function(player, seat, jacked)
    if getElementData(source, "veh >> locked") and not jacked then
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. "A jármű jelenleg zárva van!", player, 255,255,255,true);
        cancelEvent();
            
        return;
    elseif getElementData(player, "char >> belt") then
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. "Addig nem tudsz kiszállni, míg be van kötve a biztonsági öved (F5)!", player, 255,255,255,true);
        cancelEvent();
            
        return;
    end
end);

addEventHandler("onResourceStop", resourceRoot, function()
    for k,v in pairs(getElementsByType("vehicle")) do
        local id = getElementData(v, "veh >> id");
        if id then
            saveVehicle(id);
        end
    end
end);

addEvent("kickPlayerFromVeh", true)
addEventHandler("kickPlayerFromVeh", root, function(e, comPos)
    local veh = e.vehicle
    removePedFromVehicle(e);

    local x, y, z = e.position;
    if comPos and type(comPos) == "table" then
        x,y,z = unpack(comPos)
    end
    setElementPosition(e, x, y, z);
end);

addEvent("changeDoorState", true)
addEventHandler("changeDoorState", root, function(veh, num, oldState)
    local oldState = not oldState;
    local openRatio = 0
        
    if oldState then
        openRatio = 1;
    end
        
    setVehicleDoorOpenRatio(veh, num, openRatio, 500);
end);

addEvent("fixVehicle", true)
addEventHandler("fixVehicle", root, function(e)
    setElementData(e, "veh >> engineBroken", false);
    fixVehicle(e);
end);

addEvent("unflipVehicle", true)
addEventHandler("unflipVehicle", root, function(e)
    local a1, a2, a3 = getElementRotation(e);
    setElementRotation(e, 0, a2, a3);
end);

addEvent("setElementPosition", true)
addEventHandler("setElementPosition", root, function(e, x,y,z, dim, int)
    setElementPosition(e, x,y,z);
    setElementData(e,"veh >> oldDim",getElementDimension(e));
        
    if dim then
        setElementDimension(e, dim);
    end
            
    if int then
        setElementInterior(e, int);
    end
end);

addEvent("setElementHealth", true)
addEventHandler("setElementHealth", root, function(e, health)
    setElementHealth(e, health);
end);
    
addEvent("destroyElement", true)
addEventHandler("destroyElement", root, function(e)
    destroyElement(e);
end);

addEvent("setVehicleColor", true)
addEventHandler("setVehicleColor", root, function(e, r,g,b,r1,g1,b1)
    local a;
    if not r1 or not b1 or not g1 or tonumber(r1) == nil or tonumber(g1) == nil or tonumber(b1) == nil then 
        a, a, a, r1, g1, b1 = getVehicleColor(e, true);
    end
            
    setVehicleColor(e, r,g,b, r1, g1, b1);
end);

addEvent("respawnThisCar", true)
addEventHandler("respawnThisCar", root, function(e, x,y,z,rx,ry,rz,int,dim)
    local occupants = getVehicleOccupants(e);
    for k,v in pairs(occupants) do
        removePedFromVehicle(v);
    end
            
    setElementData(e, "veh >> engineBroken", false);
    fixVehicle(e);
    setElementFrozen(e, true);
    setElementPosition(e, x,y,z);
    setElementDimension(e, dim);
    setElementInterior(e, int);
    setElementRotation(e, rx,ry,rz);
    setElementData(e, "veh >> handbrake", true);
    setElementData(e, "veh >> locked", true);
    setElementData(e, "veh >> engine", false);
            
    if getVehicleType(e) == "Bike" then
        setElementData(e, "veh >> engine", false);
    end
end);

addEvent("setVehiclePlateText", true)
addEventHandler("setVehiclePlateText", root, function(e, target, id, text)
    if text == "Rand" or text == "rand" then
        text = generatePlateText();
    end
            
    text = string.upper(text);
            
    if plateTexts[text] then
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        outputChatBox(syntax .. "Ez a rendszám már használatban van!",e,255,255,255,true);
        return;
    end
            
    plateTexts[text] = true;
    setVehiclePlateText(target, text);
    local id = getElementData(target, "veh >> id") or 0;
    cache[id]["plate"] = text;
            
    local green = exports['cr_core']:getServerColor("orange", true);
    local syntax = exports['cr_core']:getServerSyntax(false, "success");
    local vehicleName = getVehicleName(target);
            
    outputChatBox(syntax .. "Sikeresen átírtad egy jármű rendszámtábláját ("..text..") (ID: "..green..id..white..")", e, 255,255,255,true);
            
    local aName = exports['cr_admin']:getAdminName(e, true);
    local syntax = exports['cr_admin']:getAdminSyntax();
            
    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." átírta egy jármű rendszámtábláját ("..text..") (ID: "..green..id..white..")", 3);
            
    local time = getTime() .. " ";
    exports['cr_logs']:addLog("Admin", "setvehplatetext", time .. aName .. " átírta egy jármű rendszámtábláját ("..text..") (ID: "..id..")");
end);

addEvent("deleteVehicle", true)
addEventHandler("deleteVehicle", root, function(e, vehicle, id)
    deleteVehicle(id, getElementModel(vehicle));
end);

addEvent("nearbyVehicleOutput", true)
addEventHandler("nearbyVehicleOutput", root, function(e, text, ownerID, green, white)
    local ownerName = exports['cr_account']:getCharacterNameByID(ownerID);
    local ownerName = ownerName:gsub("_", " ");
    local text = text:gsub("@4", green..ownerName..white);
            
    outputChatBox(text, e, 255,255,255, true);
end);

addEvent("receiveOwnerNameForStats.server", true)
addEventHandler("receiveOwnerNameForStats.server", root, function(e, text, ownerID, green, white)
    local ownerName = exports['cr_account']:getCharacterNameByID(ownerID);
    local ownerName = ownerName:gsub("_", " ");
    local text = text:gsub("@4", green..ownerName..white);
    triggerClientEvent(e, "receiveOwnerNameForStats.client", e, e, text);
end);

addEvent("blowVehicle", true)
addEventHandler("blowVehicle", root, function(vehicle)
    blowVehicle(vehicle, true);
end);

function saveVehicle(id)
    local vehicle = loadedVehicles[id];
    if vehicle then
        local modelid = getElementModel(vehicle);
        local x,y,z = getElementPosition(vehicle);
        local rx,ry,rz = getElementRotation(vehicle);
        local int, dim = getElementInterior(vehicle), getElementDimension(vehicle);
        local dim2 = false;
        
        if not getElementData(vehicle, "veh >> loaded") then
            dim2 = getElementData(vehicle, "veh >> oldDim");
        end
        
        local pos = toJSON({x,y,z,rx,ry,rz,int,dim,dim2});
        local owner = getElementData(vehicle, "veh >> owner");
        local fuel = getElementData(vehicle, "veh >> fuel");
        local engine = tostring(getElementData(vehicle, "veh >> engine"));
        local engineBroken = tostring(getElementData(vehicle, "veh >> engineBroken"));
        local light = tostring(getElementData(vehicle, "veh >> light"));
        local plate = getVehiclePlateText(vehicle);
        local odometer = getElementData(vehicle, "veh >> odometer");
        local locked = tostring(getElementData(vehicle, "veh >> locked"));
        local health = getElementHealth(vehicle);
		local fueltype = tostring(getElementData(vehicle, "veh >> fueltype"));
		local maxkm = tonumber(getElementData(vehicle, "veh >> maxkm"));
        
        setVehicleFuelTankExplodable(vehicle, false);
        
        local a1 = {getVehicleColor(vehicle, true)};
        local colors = toJSON(a1);
        local a1 = {};
        
        for i = 1, 4 do
            local num = i + 1;
            a1[i] = tostring(getElementData(vehicle, "veh >> window"..num.."State"));
        end
        
        local windows = toJSON(a1);
        local a1 = {};
        
        for i = 0, 6 do
            local num = i + 1;
            a1[num] = getVehiclePanelState(vehicle, i);
        end
        
        local panels = toJSON(a1);
        local a1 = {getVehicleWheelStates(vehicle)};
        local wheels = toJSON(a1);
        local a1 = {};
        
        for i = 0, 3 do
            local num = i + 1
            a1[num] = getVehicleLightState(vehicle, i);
        end
        
        local lights = toJSON(a1);
        local a1 = {};
        
        for i = 0, 5 do
            local num = i + 1;
            a1[num] = getVehicleDoorState(vehicle, i);
        end
        
        local doors = toJSON(a1);
        local handbrake = tostring(getElementData(vehicle, "veh >> handbrake"));
        local damageProof = tostring(isVehicleDamageProof(vehicle));
        local lastOilRecoil = getElementData(vehicle, "veh >> lastOilRecoil");
        local a1, a2 = getVehicleVariant(vehicle);
        local variant = toJSON({a1, a2});
        local r,g,b = getVehicleHeadLightColor(vehicle);
        local headlight = toJSON({r,g,b});
        local kmColor = toJSON(getElementData(vehicle, "veh >> KM/H Color") or {255,255,255});
        local parkPos = toJSON(getElementData(vehicle, "veh >> park") or {x,y,z,rx,ry,rz,int,dim});
        local protect = tostring(getElementData(vehicle, "veh >> protect"));
        local faction = getElementData(vehicle, "veh >> faction");
        
        cache[id] = {
            ["modelid"] = modelid,
            ["pos"] = pos,
            ["owner"] = owner,
            ["fuel"] = fuel,
            ["engine"] = engine,
            ["engineBroken"] = engineBroken,
            ["light"] = light,
            ["plate"] = plate,
            ["odometer"] = odometer,
            ["locked"] = locked,
            ["health"] = health,
            ["colors"] = colors,
            ["windows"] = windows,
            ["panels"] = panels,
            ["wheels"] = wheels,
            ["lights"] = lights,
            ["doors"] = doors,
            ["handbrake"] = handbrake,
            ["damageProof"] = damageProof,
            ["lastOilRecoil"] = lastOilRecoil,
            ["variant"] = variant,
            ["headlight"] = headlight,
            ["kmColor"] = kmColor,
            ["parkPos"] = parkPos,
            ["protect"] = protect,
            ["faction"] = faction,
			["fueltype"] = fueltype,
			["maxkm"] = maxkm,
        };
        
        dbExec(mysql:requestConnection(), "UPDATE `vehicle` SET `modelid`=?, `pos`=?, `owner`=?, `fuel`=?, `engine`=?, `engineBroken`=?, `light`=?, `plate`=?, `odometer`=?, `locked`=?, `health`=?, `colors`=?, `windows`=?, `panels`=?, `wheels`=?, `lights`=?, `doors`=?, `handbrake`=?, `damageProof`=?, `lastOilRecoil`=?, `variant`=?, `headlight`=?, `kmColor`=?, `parkPos`=?, `protect`=?, `faction`=?, `fueltype`=?, `maxkm`=? WHERE `id`=? ", modelid, pos, owner, fuel, engine, engineBroken, light, plate, odometer, locked, health, colors, windows, panels, wheels, lights, doors, handbrake, damageProof, lastOilRecoil, variant, headlight, kmColor, parkPos, protect, faction, fueltype, maxkm, id);
    end
end

local white = "#ffffff"

addEvent("makeVeh", true)
addEventHandler("makeVeh", root, function(e, model, target, id, factionID, playerID, pos, colors, playerName, e2)
    if factionID > 0 then
        playerID = 0;
    end
        
    dbExec(mysql:requestConnection(), "INSERT INTO `vehicle` SET `modelid`=?, `owner`=?, `faction`=?, `pos`=?, `parkPos`=?, `colors`=?, `chassis`=?", model, playerID, factionID, pos, pos, colors, generateChassisNumber());
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, row in pairs(query) do
                if rowToTable(row) then
                    table.insert(loader, row);
                    local id = row["id"];
                    --outputDebugString(row["faction"]);
                    --outputDebugString(row["owner"]);

                    print("Created vehicle to accountid " .. row["owner"] .. " (chassis: " .. row["chassis"] .. ")");
                            
                    if not isTimer(loaderTimer) then
                        loaderTimer = setTimer(function() loadOneVehicle() end, 50, 1);
                    end
                
                    exports['cr_inventory']:giveItem(e, keyItem, id, 1, 100, 0, 0, model);
                    local vehicleName = getVehicleName(model);
                    local green = exports['cr_core']:getServerColor("orange", true);
                    local syntax = exports['cr_core']:getServerSyntax(false, "success");
                    local vehicleName = getVehicleName(model);
                    local faction = factionID;
                            
                    if factionID == 0 then
                        faction = "0";
                    end
                            
                    outputChatBox(syntax .. "Sikeresen létrehoztál egy járművet (ID: "..green..id..white..")", e, 255,255,255,true);
                            
                    local aName = exports['cr_admin']:getAdminName(e, true);
                    local syntax = exports['cr_admin']:getAdminSyntax();
                    local playerName = exports['cr_account']:getCharacterNameByID(playerID);
                            
                    playerName = playerName:gsub("_", " ");
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax..green..aName..white.." létrehozott egy járművet (Tulajdonos: "..green..playerName..white..", Model: "..green..vehicleName..white..", FrakcióID: "..green..faction..white..") (ID: "..green..id..white..")", 8);
                    
                    local time = getTime() .. " ";
                    exports['cr_logs']:addLog("Admin", "makeveh", time .. aName .. " létrehozott egy járművet (Tulajdonos: "..playerName..", Model: "..vehicleName..", FrakcióID: "..faction..") (ID: "..id..")");
                            
                    exports.cr_carshop:addNewVehicleToCount(model);
                end
            end
        end
    end, mysql:requestConnection(), "SELECT * FROM vehicle WHERE id=LAST_INSERT_ID()");
    --end, mysql:requestConnection(), "SELECT * FROM `vehicle` WHERE `pos`=? and `parkPos`=? and `modelid`=? and `owner`=?", pos, pos, model, playerID)
end) 

function deleteVehicle(id, model)
    dbExec(mysql:requestConnection(), "DELETE FROM `vehicle` WHERE `id`=?", id);
    local vehicle = loadedVehicles[id];
    
    exports.cr_carshop:minusCount(model);
    
    if vehicle then
        local occupants = getVehicleOccupants(vehicle) or {};
        
        for k,v in pairs(occupants) do
            removePedFromVehicle(v);
        end
        
        local obj = vehicle:getData("veh >> ambulanceBedE")
        
        if obj and isElement(obj) then
            destroyElement(obj)
        end
        
        destroyElement(vehicle);
        loadedVehicles[id] = nil;
    end
    
    if cache[id] then
        cache[id] = nil;
    end
end