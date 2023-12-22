shopDatas = {
    {
        ["Name"] = "?",
        ["Ped"] = {
            ["pos"] = {1746.1309814453, -1122.3411865234, 24.078125}, 
            ["rot"] = 259.66766357422, 
            ["dim"] = 0, 
            ["model"] = 299, 
            ["int"] = 0, 
            ["name"] = "Dwayne",
            ["type"] = "Gépjármű kereskedő"
        }, -- pozi, rot, dim, int, name
        ["Vehicles"] = {411, 602, 419, 526, 600, 491},
        ["Vehicle_pos"] = {1735.7209472656, -1135.0657958984, 24.085935592651},
        ["Vehicle_spawn"] = {1735.7209472656, -1135.0657958984, 24.085935592651},
    },
};

vehicleDatas = {
    --kocsi ID -- $, pp, limit(-1 = nincs), logo
    [411] = {1500, 20000, 0, "?"},
    [602] = {1501, 20001, -1, "?"},
    [419] = {1502, 20002, 500, "?"},
    [526] = {1503, 20003, 1500, "?"},
    [600] = {1504, 20004, 421, "?"},
    [491] = {1505, 20005, 321, "?"},
    [580] = {80000, 20005, 100, "?"},
};

function getVehiclePrice(e, type)
    if not type then type = 1 end
    if type == 1 then
        --$
        local data = vehicleDatas[e.model] or {0}
        local price = data[1]
        return price
    else
        --PP
        local data = vehicleDatas[e.model] or {0}
        local price = data[1]
        return price
    end
end

components = {
    ["door_lf_dummy"] = {"Bal első ajtó", 2},
    ["door_rf_dummy"] = {"Jobb első ajtó", 3},
    ["door_rr_dummy"] = {"Jobb hátsó ajtó", 5},
    ["door_lr_dummy"] = {"Bal hátsó ajtó", 4},
    ["bonnet_dummy"] = {"Motorháztető", 0},
    ["boot_dummy"] = {"Csomagtartó", 1},
};