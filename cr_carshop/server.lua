local mysql = exports.cr_mysql;

local countedModels = {};

addEventHandler("onResourceStart", resourceRoot, function()
	countVehicles();
    spawnPeds();
end);

function countVehicles()
    local startTick = getTickCount();

    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, k in pairs(query) do
                local model = k["modelid"];
                local count = k["counted"];
                    
                if vehicleDatas[model] then
                    if vehicleDatas[model][4] and vehicleDatas[model][4] > -1 then
                        countedModels[model] = count;
                    end
                end
            end
        end
            
        outputDebugString("Loaded " .. query_lines .. " model(s) to carshop in " .. getTickCount() - startTick .. " ms");
    end, mysql:requestConnection(), "SELECT modelid, count(modelid) as counted FROM vehicle WHERE owner > 0 GROUP BY modelid");
end

function spawnPeds()
    for i, k in pairs(shopDatas) do
        local data = k["Ped"];
        
        local pos, name, rot, int, dim, model, type= data["pos"], data["name"], data["rot"], data["int"], data["dim"], data["model"], data["type"] or "Kereskedő";
        
        local ped = createPed(model, pos[1], pos[2], pos[3], rot);
        if ped then
            setElementFrozen(ped, true);
            setElementDimension(ped, dim);
            setElementInterior(ped, int);
            
            setElementData(ped, "ped.name", name);
            setElementData(ped, "ped.type", type);
            setElementData(ped, "ped.type.type", "carshop");
            setElementData(ped, "ped.id", i);
            setElementData(ped, "parent", false);
        end
    end
end

function addNewVehicleToCount(model)
    if vehicleDatas[model] then
        if vehicleDatas[model][3] and vehicleDatas[model][3] > -1 then
            countedModels[model] = countedModels[model] and countedModels[model] + 1 or 1;
        end
    end
end

function minusCount(model)
    if countedModels[model] then
        countedModels[model] = countedModels[model] > 0 and countedModels[model] - 1 or 0;
    end
end

addEvent("server->getModelCount", true);
addEventHandler("server->getModelCount", getRootElement(), function()
    if client then
        triggerClientEvent(client, "client->getModelCount", client, countedModels);
    end
end);

local carParkPositions = {
	{1695.5714111328, -1148.3677978516, 23.902391433716, 90},
	{1695.8585205078, -1143.3187255859, 24.052852630615, 90},
	{1697.8881835938, -1133.4914550781, 24.078125, 90},
	{1696.7185058594, -1128.3134765625, 24.078125, 90},
	{1696.6461181641, -1123.1038818359, 24.078125, 90},
	{1696.3785400391, -1117.9625244141, 24.078125, 90},
	{1697.1593017578, -1112.8516845703, 24.078125, 90},
	{1697.0028076172, -1102.8381347656, 24.078125, 90},
	{1696.7124023438, -1097.9711914063, 24.078125, 90},
}

addEvent("carshop->BuyVehicle", true);
addEventHandler("carshop->BuyVehicle", root, function(player, priceTable, model, colorTable)
    if client and client == player then
        if priceTable[1] == "pp" then
            setElementData(player, "char >> premiumPoints", getElementData(player, "char >> premiumPoints") - priceTable[2])
        else
			setElementData(player, "char >> money", getElementData(player, "char >> money") - priceTable[2])
        end
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		outputChatBox(syntax.."Sikeresen megvetted a kiválasztott járművet, megtalálod a parkolóban.", player, 255, 255, 255, true)
		local r, g, b = unpack(colorTable)
		local x, y, z, r = unpack(carParkPositions[math.random(1, #carParkPositions)])
		local pos = {x, y, z, 0, 0, r, 0, 0}
		exports.cr_vehicle:makeVehicle(player, model, pos, {r, g, b})
    end
end);