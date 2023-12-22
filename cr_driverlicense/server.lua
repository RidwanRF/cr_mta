local veh = {}
local ped = {}

function spawnPlayerWithStudentVehicle(player,modelID,x,y,z,dim,int,vehRot)
    if veh[player] then return end
    if ped[player] then return end
    -- veh[player] = exports['cr_vehicle']:createTemporaryVehicle(modelID, player, x,y,z,dim,int, vehRot, true, true, false, 350)
	local rx, ry, rz = unpack(vehRot)
    veh[player] = exports.cr_temporaryvehicle:createTemporaryVehicle(player, modelID, x, y, z, rx, ry, rz, 255, 255, false, true)
    local name = generateRandomName()
    local skinid = giveARandomSkin()
    ped[player] = createPed(skinid,0,0,0)
    setElementData(player, "driverlicense.ped", ped[player])
    setElementData(ped[player],"ped.name", name)
    setElementData(ped[player],"ped.type","Oktató")
    setElementData(ped[player],"ped.id","DriverLicense")
    setElementData(ped[player], "char >> noDamage", true)
    warpPedIntoVehicle(ped[player],veh[player],1)
    setElementData(ped[player], "char >> belt", true)
    --warpPedIntoVehicle(player,veh[player])      
end
addEvent("spawnPlayerWithStudentVehicle",true)
addEventHandler("spawnPlayerWithStudentVehicle",root,spawnPlayerWithStudentVehicle)

function destroyCar(player)
    if veh[player] then
        -- local id = getElementData(veh[player], "veh >> id") or 0
        -- exports['cr_vehicle']:deleteVehicle(id)
		exports.cr_temporaryvehicle:deleteTemporaryVehicle(player)
        veh[player] = nil
    end
    if ped[player] then
        destroyElement(ped[player])
        ped[player] = nil
    end
end
addEvent("destroyCar",true)
addEventHandler("destroyCar",root,destroyCar)

addEventHandler("onPlayerQuit", root,
    function()
        destroyCar(source)
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        for k,v in pairs(veh) do
            exports.cr_temporaryvehicle:deleteTemporaryVehicle(k)
        end
    end
)

addEvent("giveLicense", true)
addEventHandler("giveLicense", resourceRoot, function() 
	local player = client
	exports.cr_inventory:giveItem(player, 77, 0, 1, 100, 0, 0)
end)