_destroyElement = destroyElement
function destroyElement(e)
    if isElement(e) then
        _destroyElement(e)
    end
end

local client = true
addEventHandler("onResourceStart", resourceRoot,
    function()
        client = false
    end
)

t, a = "assets/images", ".png"

disabledWeight = {
    [97] = true,
    [25] = true,
    [76] = true,
    [77] = true,
    [78] = true,
    [79] = true,
    [80] = true,
    [131] = true,
    [132] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [128] = true,
}

local itemWeights = {
    --[itemid] = súly
    [1] = 0.25,
    [2] = 0.75,
    [3] = 0.85,
    [4] = 0.35,
    [5] = 0.1,
    [6] = 0.1,
    [7] = 0.25,
    [8] = 0.5,
    [9] = 0.35,
    [10] = 0.7,
    [11] = 0.7,
    [12] = 0.001,
    [13] = 0.001,
    [14] = 0.015,
    [15] = 0.175,
    [16] = 0.05,
    [17] = 0.05,
    [18] = 0.05,
    [19] = 0.3,
    [20] = 0.05,
    [21] = 0.001,
    [22] = 2.5,
    [23] = 0.05,
    [24] = 0.05,
    [25] = 0.005,
    [26] = 0.001,
    [27] = 0.001,
    [28] = 0.001,
    [29] = 0.05,
    [30] = 0.3,
    [31] = 0.1,
    [32] = 0.1,
    [33] = 5,
    [34] = 0.3,
    [35] = 0.05,
    [36] = 0.05,
    [37] = 0.2,
    [38] = 0.4,
    [39] = 2.5,
    [40] = 1.5,
    [41] = 0.85,
    [42] = 3,
    [43] = 3.5,
    [44] = 2.5,
    [45] = 2,
    [46] = 0.3,
    [47] = 0.85,
    [48] = 0.65,
    [49] = 1.4,
    [50] = 1.8,
    [51] = 2.1,
    [52] = 3.8,
    [53] = 3.4,
    [54] = 4.1,
    [55] = 3.5,
    [56] = 2.54,
    [57] = 3.6,
    [58] = 2.68,
    [59] = 1.35,
    [60] = 4.3,
    [61] = 6,
    [62] = 0.3,
    [63] = 1.8,
    [64] = 0.3,
    [65] = 1,
    [66] = 0.02,
    [67] = 0.02,
    [68] = 0.02,
    [69] = 0.02,
    [70] = 0.02,
    [71] = 0.02,
    [72] = 5,
    [73] = 0.3,
    [74] = 0.1,
    [75] = 0.3,
    [76] = 0.05,
    [77] = 0.05,
    [78] = 0.05,
    [79] = 0.05,
    [80] = 0.05,
    [81] = 0.08,
    [82] = 0.05,
    [83] = 0.004,
    [84] = 0.05,
    [85] = 2.5,
    [86] = 0.4,
    [87] = 0.3,
    [88] = 0.2,
    [89] = 7,
    [90] = 0.1,
    [91] = 2,
    [92] = 4.2,
    [93] = 3.8,
    [94] = 5,
    [95] = 3,
    [96] = 0.5,
    [97] = 0.05,
    [98] = 0.05,
    [99] = 4,
    [100] = 0,
    [101] = 0,
    [102] = 0,
    [103] = 0,
    [104] = 0,
    [105] = 0,
    [106] = 0,
    [107] = 0,
    [108] = 0,
    [109] = 0,
    [110] = 0.4,
    [111] = 0.3,
    [112] = 0.3,
    [113] = 0.1,
    [114] = 0.35,
    [115] = 0.2,
    [116] = 0.3,
    [117] = 0.2,
    [118] = 0.45,
    [119] = 0.003,
    [120] = 0.002,
    [121] = 0.008,
    [122] = 0.06,
    [123] = 2.3,
    [124] = 0.001,
    [125] = 0.003,
    [126] = 2,
    [127] = 2.3,
    [128] = 0.005,
    [129] = 0.3,
    [130] = 2,
    [131] = 0.09,
    [132] = 0.09,
    [133] = 1,
    [134] = 0.5,
}

items = {
    --[itemid] = {Név, iType [1 = Hátizsák, 3 = Kulcsok, 2 = Iratok], Súly, Stackelhető, MaxStack, isWeapon, isStatus, átadható, weaponID(Ha Weapon), lőszerItemID(Ha fegyver -2 = Érték alapú lőszerhasználat, -3 = Egyszerhasználatos, -4 = korlátlan )},
    [1] = {"Hot-dog", 1, 0.25, true, 5, false, true, true},
	[2] = {"Hamburger", 1, 0.75, true, 5, false, true, true},
	[3] = {"Taco", 1, 0.65, true, 5, false, true, true},
	[4] = {"Szendvics", 1, 0.35, true, 5, false, true, true},
	[5] = {"Fánk", 1, 0.1, true, 5, false, true, true},
	[6] = {"Süti", 1, 0.1, true, 5, false, true, true},
	[7] = {"Üdítőital", 1, 0.25, true, 5, false, true, true},
	[8] = {"Víz", 1, 0.5, true, 5, false, true, true},
	[9] = {"Sör", 1, 0.35, true, 5, false, true, true},
	[10] = {"Vodka", 1, 0.7, true, 5, false, true, true},
	[11] = {"Whiskey", 1, 0.7, true, 5, false, true, true},
	[12] = {"Heroin", 1, 0.01, true, 50, false, false, true},
	[13] = {"Kokain", 1, 0.01, true, 50, false, false, true},
	[14] = {"Füves cigi", 1, 0.015, true, 20, false, false, true},
	[15] = {"Okos telefon", 1, 0.3, false, 0, false, false, true},
	[16] = {"Jármű kulcs", 3, 0.05, false, 0, false, false, true},
	[17] = {"Lakás Kulcs", 3, 0.05, false, 0, false, false, true},
	[18] = {"Biznisz Kulcs", 3, 0.05, false, 0, false, false, true},
	[19] = {"Rádió", 1, 0.3, false, 0, false, false, true},
	[20] = {"Kapu távirányító", 2, 0.07, false, 0, false, false, true},
	[21] = {"Kocka", 1, 0.001, false, 0, false, false, true},
	[22] = {"Hifi", 1, 2.5, false, 0, false, false, true},
	[23] = {"Vitamin", 1, 0.1, true, 20, false, true, true},
	[24] = {"Gyógyszer", 1, 0.1, true, 20, false, true, true},
	[25] = {"Fegyverengedély", 1, 0.01, false, 0, false, false, true},
	[26] = {"Insant Gyógyítás", 1, 0.001, true, 20, false, false, true},
	[27] = {"Instant Fix Kártya", 1, 0.001, true, 20, false, false, true},
	[28] = {"Instant Üzemanyag Kártya", 1, 0.001, true, 20, false, false, true},
	[29] = {"Széf kulcs", 3, 0.06, false, 0, false, false, true},
	[30] = {"Gáz Maszk", 1, 0.3, false, 0, false, false, true},
	[31] = {"Flashbang", 1, 0.1, false, 0, false, false, true},
	[32] = {"Füstgránát", 1, 0.1, false, 0, true, false, true, 17, -3},
	[33] = {"Faltörő kos", 1, 1.0, false, 0, false, false, true},
	[34] = {"Bilincs", 1, 0.1, false, 0, false, false, true},
	[35] = {"Bilincs kulcs", 2, 0.1, false, 0, false, false, true},
	[36] = {"Jelvény", 1, 0.1, false, 0, false, false, true},
	[37] = {"Villogó", 1, 0.3, false, 0, false, false, true},
	[38] = {"Boxer", 1, 0.6, false, 0, true, true, true, 1, -1},
	[39] = {"Golf Ütő", 1, 3.0, false, 0, true, true, true, 2, -1},
	[40] = {"Gumibot", 1, 1.5, false, 0, true, true, true, 3, -1},
	[41] = {"Kés", 1, 1.6, false, 0, true, true, true, 4, -1},
	[42] = {"Baseball Ütő", 1, 2.6, false, 0, true, true, true, 5, -1},
	[43] = {"Ásó", 1, 3.0, false, 0, true, true, true, 6, -1},
	[44] = {"Katana", 1, 3.5, false, 0, true, true, true, 8, -1},
	[45] = {"Balta", 1, 3.6, false, 0, true, true, true, 12, -1},
	[46] = {"Virág", 1, 0.2, false, 0, true, true, true, 14, -1},
	[47] = {"Sétabot", 1, 0.6, false, 0, true, true, true, 15, -1},
	[48] = {"Molotov-koktél", 1, 1.0, false, 0, true, false, true, 18, -3},
	[49] = {"Glock-18", 1, 1.6, false, 0, true, true, true, 22, 66},
	[50] = {"Hangtompítós Colt-45", 1, 2.0, false, 0, true, true, true, 23, 66},
	[51] = {"Desert Eagle pisztoly", 1, 2.6, false, 0, true, true, true, 24, 66},
	[52] = {"Sörétes puska", 1, 5.6, false, 0, true, true, true, 25, 69},
	[53] = {"Rövid csövű sörétes puska", 1, 4.6, false, 0, true, true, true, 26, 69},
	[54] = {"SPAZ-12 taktikai sörétes puska", 1, 5.6, false, 0, true, true, true, 27, 69},
	[55] = {"Uzi", 1, 3.0, false, 0, true, true, true, 28, 67},
	[56] = {"MP5", 1, 3.0, false, 0, true, true, true, 29, 67},
	[57] = {"AK-47", 1, 5.0, false, 0, true, true, true, 30, 71},
	[58] = {"M4", 1, 5.0, false, 0, true, true, true, 31, 68},
	[59] = {"TEC-9", 1, 3.0, false, 0, true, true, true, 32, 67},
	[60] = {"Vadász puska", 1, 5.0, false, 0, true, true, true, 33, 70},
	[61] = {"Mesterlövész", 1, 6.0, false, 0, true, true, true, 34, 70},
	[62] = {"Spray", 1, 0.6, false, 0, true, true, true, 41, -1},
	[63] = {"Poroltó", 1, 1.6, false, 0, true, true, true, 42, -1},
	[64] = {"Kamera", 1, 0.1, false, 0, true, true, true, 43, -1},
	[65] = {"Ejtőernyő", 1, 1.5, false, 0, true, true, true, 46, -1},
	[66] = {"5x9mm-es töltény", 1, 0.02, true, 1000, false, false, true},
	[67] = {"Kis gépfegyver töltények", 1, 0.02, true, 1000, false, false, true},
	[68] = {"M4 lőszer", 1, 0.02, true, 1000, false, false, true},
	[69] = {"Sörétes töltény", 1, 0.02, true, 1000, false, false, true},
	[70] = {"Vadászpuska töltény", 1, 0.02, true, 1000, false, false, true},
	[71] = {"AK-47 Lőszer", 1, 0.02, true, 1000, false, false, true},
	[72] = {"Széf", 1, 0.0, false, 0, false, false, true},
	[73] = {"Elsősegély doboz", 1, 0.2, true, 10, false, false, true},
	[74] = {"Öngyújtó", 1, 0.1, false, 0, false, false, true},
	[75] = {"Taxi tábla", 1, 0.3, false, 0, false, false, true},
	[76] = {"Pilóta engedély", 2, 0.0, false, 0, false, false, true},
	[77] = {"Vezetői engedély", 2, 0.0, false, 0, false, false, true},
	[78] = {"Személyi igazolvány", 2, 0.0, false, 0, false, false, true},
	[79] = {"Forgalmi engedély", 2, 0.0, false, 0, false, false, true},
	[80] = {"Adásvételi szerződés", 2, 0.0, false, 0, false, false, true},
	[81] = {"Toll", 1, 0.1, false, 0, false, false, true},
	[82] = {"Fegyvertartási engedély", 2, 0.0, false, 0, false, false, true},
	[83] = {"Cigaretta", 1, 0.1, true, 20, false, false, true},
	[84] = {"Távvezérlő jármű kulcs", 3, 0.05, false, 0, false, false, true},
	[85] = {"Horgászbot", 1, 2, false, 0, false, false, true},
	[86] = {"Bakancs", 1, 0.2, false, 0, false, false, true},
	[87] = {"Döglött hal", 1, 0.2, false, 0, false, false, true},
	[88] = {"Konzervdoboz", 1, 0.1, false, 0, false, false, true},
	[89] = {"Cápa", 1, 4, false, 0, false, false, true},
	[90] = {"Hínár", 1, 0.2, false, 0, false, false, true},
	[91] = {"Tonhal", 1, 3, false, 0, false, false, true},
	[92] = {"Polip", 1, 2, false, 0, false, false, true},
	[93] = {"Ördöghal", 1, 1, false, 0, false, false, true},
	[94] = {"Kardhal", 1, 2, false, 0, false, false, true},
	[95] = {"Szamuráj rák", 1, 0.5, false, 0, false, false, true},
	[96] = {"Csillag", 1, 0.1, false, 0, false, false, true},
	[97] = {"Bankkártya", 2, 0.0, false, 0, false, false, false},
	[98] = {"SIM kártya", 2, 0.0, false, 0, false, false, false},
	[99] = {"Csákány", 1, 1.5, false, 0, true, true, true, 11, -1},
	
    [100] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [101] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [102] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [103] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [104] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [105] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [106] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [107] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [108] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    [109] = {"Ismeretlen", 1, 0, false, 0, false, false, true},
    
	[110] = {"Kő", 1, 0, false, 0, false, false, true},
	[111] = {"Alumínium", 1, 0, false, 0, false, false, true},
	[112] = {"Homokkő", 1, 0, false, 0, false, false, true},
	[113] = {"Szén", 1, 0, false, 0, false, false, true},
	[114] = {"Vas", 1, 0, false, 0, false, false, true},
	[115] = {"Titán", 1, 0, false, 0, false, false, true},
	[116] = {"Ólom", 1, 0, false, 0, false, false, true},
	[117] = {"Vörösréz", 1, 0, false, 0, false, false, true},
	
	[118] = {"Fa", 1, 0, false, 0, false, false, true},
	[119] = {"Kén", 1, 0, false, 0, false, false, true},
	[120] = {"Salétrom", 1, 0, false, 0, false, false, true},
	[121] = {"Gumi", 1, 0, false, 0, false, false, true},
	[122] = {"Acél", 1, 0, false, 0, false, false, true},
	[123] = {"Kalapács", 1, 0, false, 0, false, false, true},
	[124] = {"Papir", 1, 0, false, 0, false, false, true},
	[125] = {"Sav", 1, 0, false, 0, false, false, true},
	[126] = {"Drón", 1, 2, false, 0, false, false, true},
	[127] = {"Spark - Sokkoló pisztoly", 1, 2.6, false, 0, true, true, true, 24, -4},
	
	[128] = {"Csekk", 2, 0, false, 0, false, false, false},
	[129] = {"Célzólézer", 1, 0, false, 0, false, false, true},
	[130] = {"Esettáska", 1, 0, false, 0, false, false, true},
	[131] = {"Ismeretlen lőszermaradvány", 1, 0, false, 0, false, false, true},
	[132] = {"Lőszermaradvány", 1, 0, false, 0, false, false, true},
    [133] = {"Övelvágó kés", 1, 0, false, 0, false, false, true},
    [134] = {"Megafon", 1, 0, false, 0, false, false, true},
}

for k,v in pairs(itemWeights) do
    items[k][3] = v
end

foodDetails = {
    --[foodID] = {Mennyit tölt 1 harapás, Hány harapás 1 kaja},
    [1] = {8, 5},
    [2] = {11, 4},
    [3] = {12, 5},
    [4] = {8, 4},
    [5] = {4, 3},
    [6] = {5, 3},
    [7] = {4, 3},
    [8] = {12, 4},
    [9] = {4, 5},
    [10] = {6, 4},
    [11] = {6, 5},
}

function getAllItems()
	return items
end

function getItemWeight(item)
	if(items[item]) then
		return items[item][3]
	end
	return false
end

foodTypes = {
    [1] = "food",
	[2] = "food",
	[3] = "food",
	[4] = "food",
	[5] = "food",
	[6] = "water",
	[7] = "water",
	[8] = "water",
	[9] = "water",
	[10] = "water",
	[11] = "water",
    
}

craftG = {
    --[[
    {"type", false, 
        {
            {{itemid, value, count, status, dutyitem, premium, nbt}, craftIdő (másodperc), {Faction: (false or such :)
                    {
                        [1] = true,
                        [2] = true,
                    }, 
                    Location: (false or such :)
                    {
                        {Vector3(x,y,z)},
                    },
                    Blueprint: (false or such:)
                    {
                        ["ak47"] = true,
                    },
                }, 
                {
                    [x] = {itemid, value, count, status, dutyitem, premium, nbt = unpack(data)},
                },
            }
        },
    },
    ]]
    {"Műszaki cikkek", false,
        {
            {{5000, 1, 1, 1, 100, false, false, 0}, 30, {true, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
            {{5000, 2, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
        },
    },
    {"Fegyver alkatreszek", false,
        {
            {{5000, 1, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
            {{5000, 2, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
        },
    },
    {"Fegyverek", false,
        {
            {{5000, 1, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
            {{5000, 2, 1, 1, 100, false, false, 0}, 30, {false, false, {["ak47"] = true}}, 
                {
                    [13] = {5000, 2, 1, 1, 100, false, false, 0},
                    [12] = {5000, 85, 1, 1, 100, false, false, 0},
                    [14] = {5000, 1, 1, 1, 100, false, false, 0},
                },
            },
        },
    },
}

function getItemName(itemid, itemValue, nbt)
    --itemid = itemid - 1
    if not items[itemid] or not items[itemid][1] then
        return "Ismeretlen tárgy"
    else
        return items[itemid][1], items[itemid]
    end
end

local keyTable = {
    [16] = "vehicle", -- [ItemID] = type,
    [84] = "vehicleremote",
    [29] = "safe",
	[17] = "house",
	[18] = "busines",
}

function isKey(itemid)
    if keyTable[itemid] then
        return true
    end
    return false
end

function convertKey(t)
    local table = {}
    for k,v in pairs(keyTable) do table[v] = k end
    
    if table[t] then
        return table[t]
    end
    return false
end

function isWeapon(itemid)
    if items[itemid] then
        return items[itemid][6]
    end
    return false
end

function convertIdToWeapon(itemid)
    if isWeapon(itemid) then
        if itemid == 127 then -- Sokkoló
            return -1
        end
        return items[itemid][9]
    end
    return false
end

local gTex = {}

if type(triggerServerEvent) == "function" then
    for i = 1, #items do
        --gTex[i] = dxCreateTexture("assets/items/"..i..".png", "argb", true, "clamp")
    end
    
    noPicture = dxCreateTexture("assets/items/0.png", "argb", true, "clamp")

    function getItemPNG(itemid, value, nbt, status)
        --if fileExists(":cr_inventory/assets/items/"..itemid..".png") then
        --[[
        IDG OFF
        if tonumber(status) and tonumber(status) <= 0 then
            local tex = gTex[itemid .. "-black"]
            if tex then
                return tex
            else
                tex = dxCreateTexture("assets/items/"..itemid.."-black.png", "argb", true, "clamp")
                gTex[itemid .. "-" ..value] = tex
                return tex
            end
        end]]
        
        if tonumber(value) and tonumber(value) > 1 then
            --local testTex = dxCreateTexture("assets/items/"..itemid.."/"..value..".png", "argb", true, "clamp")
            if isWeapon(itemid) and items[itemid][3] >= 1 then
                local tex = gTex[itemid .. "-" ..value]
                if tex then
                    return tex
                else
                    if fileExists("assets/items/"..itemid.."/"..value..".png") then
                        tex = dxCreateTexture("assets/items/"..itemid.."/"..value..".png", "argb", true, "clamp")
                    end
                    if not tex then
                        if fileExists("assets/items/"..itemid..".png") then
                            tex = dxCreateTexture("assets/items/"..itemid..".png", "argb", true, "clamp")
                        end
                        if not tex then
                            tex = noPicture
                        end
                    end
                    gTex[itemid .. "-" ..value] = tex
                    return tex
                end
            end
        end
        
        
        local tex = gTex[itemid]
        if tex then
            return tex
        else
            if fileExists("assets/items/"..itemid..".png") then
                tex = dxCreateTexture("assets/items/"..itemid..".png", "argb", true, "clamp")
            end
            if not tex then
                tex = noPicture
            end
            gTex[itemid] = tex
            return tex
        end
        --end
        --return ":cr_inventory/assets/items/0.png"
    end
end

itemDescriptions = {
    --[itemid] = "ASD", ha replaceAble stringed van such as @r akkor az helyére behelyetesíti a cuccot pld. Ez a @r pizza nagyon finom
    [1] = "Amerikai hot-dog",
    [2] = "Dupla húsos hamburger",
    [3] = "Egy igazi, mexikói, ízletes Taco",
    [4] = "Finom sajtos szendvics",
    [5] = "Cukorral bevont édes fánk",
    [6] = "Finom csokis süti",
	[7] = "Frissítő üdítőital",
	[8] = "Egy flakon ásványvíz",
	[9] = "Egy hideg sör",
	[10] = "Egy igazi orosz vodka",
	[11] = "A legjobb skót Whiskey a környéken",
	[12] = "Heroin",
	[13] = "Kokain",
	[14] = "Füves cigi",
	[15] = "Apple iPhone X",
	[16] = "Jármű kezeléséhez kellő eszköz",
	[17] = "Lakás Kulcs",
	[18] = "Biznisz Kulcs",
	[19] = "Fekete színű rádiókészülék",
	[20] = "Kapu távirányító",
	[21] = "Fehér szinű kocka fekete pontokkal",
	[22] = "A jó bulihoz elengedhetetlen a zene",
	[23] = "Fő az egészség",
	[24] = "Életmentő kapszula",
	[25] = "Egy kitöltetlen fegyvertartási engedély",
	[26] = "Insant Gyógyítás",
	[27] = "Instant Fix Kártya",
	[28] = "Instant Üzemanyag Kártya",
	[29] = "Széfhez tartozó kulcs",
	[30] = "Fekete szinű gáz maszk, blokkolja a flasbanget és a gázokat",
	[31] = "Flashbang",
	[32] = "Füstgránát",
	[33] = "Faltörő kos",
	[34] = "1 pár acél bilincs",
	[35] = "Egy apró pár bilincs kulcs",
	[36] = "Jelvény",
	[37] = "Kattints rá és felrakja a kocsidra",
	[38] = "Boxer",
	[39] = "Golf Ütő",
	[40] = "Gumibot",
	[41] = "Egy fegyvernek minősülő kés",
	[42] = "Baseball Ütő",
	[43] = "Ásó",
	[44] = "Ősi japán ereklye",
	[45] = "Balta",
	[46] = "Virágok",
	[47] = "Sétabot",
	[48] = "Molotov-koktél",
	[49] = "Egy Glock-18-as",
	[50] = "Halk, és csendes",
	[51] = "Nagy kaliberű Desert Eagle pisztoly",
	[52] = "Nagy kaliberű sörétes puska",
	[53] = "Nagy kaliberű sörétes puska levágott csővel",
	[54] = "SPAZ-12 taktikai sörétes puska",
	[55] = "Uzi géppisztoly",
	[56] = "MP5-ös fegyver",
	[57] = "AK-47-es gépfegyver",
	[58] = "M4-es gépfegyver",
	[59] = "TEC-9-es fegyver",
	[60] = "Vadász puska",
	[61] = "Mesterlövész puska",
	[62] = "Spray",
	[63] = "Poroltó",
	[64] = "Kamera",
	[65] = "Ejtőernyő",
	[66] = "Colt45, Desert 5x9mm",
	[67] = "Kis gépfegyver töltények (UZI, TEC9, MP5)",
	[68] = "M4 gépfegyver töltény",
	[69] = "Sörétes töltény",
	[70] = "Hosszú vadászpuska töltény",
	[71] = "AK gépfegyver töltény",
	[72] = "Biztonságos házi széf",
	[73] = "Életet menthet",
	[74] = "Szélálló öngyújtó",
	[75] = "Taxi tábla",
	[76] = "Pilóta engedély",
	[77] = "Vezetői engedély",
	[78] = "Személyi igazolvány",
	[79] = "Forgalmi engedély",
	[80] = "Adásvételi szerződés",
	[81] = "Toll , szükséges iratokhoz",
	[82] = "Fegyvertartási engedély",
	[83] = "Cigaretta",
	--[84] = "teszt item",
	[85] = "Egy új pecabot",
	[86] = "Egy büdös bakancs",
	[87] = "Evésre alkalmatlan hal",
	[88] = "Üres konzervdoboz",
	[89] = "Bébicápa",
	[90] = "Tenyérnyi maszat",
	[91] = "Igazi aranyfogás",
	[92] = "Polip",
	[93] = "Ördöghal",
	[94] = "Kardhal",
	[95] = "Igazi ritkaság",
	[96] = "Csillag",
	[97] = "Bankkártya a számládhoz",
	[98] = "Egy sim kártya , szükséges a telefonodhoz",
	[99] = "Csakany",	
}
for i = #itemDescriptions + 1, 1000 do 
    itemDescriptions[i] = "Ez egy alap leírás"
end

typeDetails = {
    --[typeID] = {imgSource, name, maxSuly},
    [1] = {"Hátizsák", 15},
    [2] = {"Iratok", 2},
    [3] = {"Kulcsok", 3},
    [4] = {"Craft", 0},
    [5] = {"Csomagtartó", 70},
    [6] = {"Széf", 100},
    [7] = {"Műszerfal", 3},
    [8] = {"Kuka", 5},
}

worldInteract = {
    --[itemid] = true
    [-10000] = true,
}

weapDmgs = {
    --[gta-s weaponid] = sebzés (ezt megszorozza math.random 50-120%-al),
    [29] = 0.055,
	[30] = 0.05,
	[22] = 0.05,
	[23] = 0.05,
	[24] = 0.05,
	[25] = 0.05,
	[26] = 0.05,
	[27] = 0.05,
	[28] = 0.05,
	[31] = 0.05,
	[32] = 0.05,
	[33] = 0.05,
	[34] = 0.05,
}

specTypes = {
    ["vehicle"] = 5,
    ["object"] = 6,
    ["vehicle.in"] = 7,
    ["trash"] = 8,
}

function getWeaponAmmoItemID(itemid)
    if items[itemid] then
        local ammoItemID = items[itemid][10]
        return ammoItemID
    end
    return false
end

function getMaxWeight(type)
	type = tonumber(type)
	if(not type) then
		type = 1
	end
	return typeDetails[type][2]
end

if type(triggerServerEvent) == "function" then
    textures = {
        ["bg"] = dxCreateTexture("assets/images/bg.png", "argb", true, "clamp"), --"assets/images/bg.png", -- Replace with texture or not.
        ["icons"] = dxCreateTexture("assets/images/icons.png", "argb", true, "clamp"),--"assets/images/icons.png",
        ["vehicons"] = dxCreateTexture("assets/images/vehicons.png", "argb", true, "clamp"),--"assets/images/vehicons.png",
        ["safeicons"] = dxCreateTexture("assets/images/safeicons.png", "argb", true, "clamp"),--"assets/images/safeicons.png",
        ["weight"] = dxCreateTexture("assets/images/weight.png", "argb", true, "clamp"),--"assets/images/weight.png",
        ["craftBG"] = dxCreateTexture("assets/craft/bg.png", "argb", true, "clamp"),--"assets/craft/bg.png",
    }
    
    _dxDrawImage = dxDrawImage
    function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
        if type(img) == "string" then
            if not textures[img] then
                textures[img] = dxCreateTexture(img, "argb", true, "clamp")
            end
            img = textures[img]
        end
        return _dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
    end
end

iconPositions = {
    [1] = {418 - 110, 185 - 174},
    [2] = {438 - 110, 185 - 174},
    [3] = {458 - 110, 185 - 174},
    [4] = {476 - 110, 185 - 174},
}

drawnSize = {
    ["bg"] = {600, 600},
    ["icons"] = {600, 600},
    ["vehicons"] = {600, 600},
    ["weight"] = {600, 600},
    ["ac.left/right"] = {14, 80},
    ["bg_cube"] = {36,36},
    ["bg_cube_img"] = {34, 34},
    ["left/right"] = {14, 80}, -- 72 Y
}

realSize = {
    ["bg"] = {382, 256},
    ["icons"] = drawnSize["bg"],
    ["vehicons"] = drawnSize["bg"],
    ["weight"] = drawnSize["weight"],
    ["ac.left/right"] = drawnSize["ac.left/right"],
    ["bg_cube"] = drawnSize["bg_cube"],
    ["bg_cube_img"] = drawnSize["bg_cube_img"],
    ["left/right"] = drawnSize["left/right"],
}

cache = {}
--Tábla felépítése: cache[elementtype][elementid][itemtype][slot] = {id, itemid, value, count, status, dutyitem}

function getEType(e)
    if e.type == "player" then
        return 1
    elseif e.type == "object" then
        return 2
    elseif e.type == "vehicle" then
        return 3
    elseif e.type == "ped" then
        return 4
    else
        return 5
    end
end

function getEID(e)
    if e.type == "player" then
        return getElementData(e, "acc >> id") or -1
    elseif e.type == "object" then
        return getElementData(e, "safe.id") or -1
    elseif e.type == "vehicle" then
        return getElementData(e, "veh >> id") or -1
    elseif e.type == "ped" then
        return getElementData(e, "ped >> id") or -1
    else
        return 5
    end
end

function getWeight(e, i)
    local elementID = getEID(e)
    local elementType = getEType(e)
    checkTableArray(elementType, elementID, i)

    local weight = 0
    local data = cache[elementType][elementID][i]
    for slot = 1, maxLines * maxColumn do
        if data and data[slot] then
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data[slot])
            if not count then
                count = 1
            end
            
            if items[itemid] then
                local nw = items[itemid][3]
                nw = nw * count
                weight = weight + nw
            end
        end
    end

    return weight
end

function getFreeSlot(e, invType)
    --outputChatBox(tostring(invType))
    local elementID = getEID(e)
    local elementType = getEType(e)
    checkTableArray(elementType, elementID, invType)
    local data = cache[elementType][elementID][invType]
    
    if not data then
        return 1
    end
    for slot = 1, maxLines * maxColumn do
        if not data[slot] then
            return slot
        end
    end
    
    return false
end

maxLines = 5
maxColumn = 10
breakColumn = 10
between = 1

function checkTableArray(eType, eId, iType, slot)
    if eType then
        if not cache[eType] then
            cache[eType] = {}
        end
    end
    
    if eId then
        if not cache[eType][eId] then
            cache[eType][eId] = {}
        end
    end
    
    if iType then
        if not cache[eType][eId][iType] then
            cache[eType][eId][iType] = {}
        end
    end
    
    if slot then
        if not cache[eType][eId][iType][slot] then
            cache[eType][eId][iType][slot] = {}
        end
    end
end

colors = {
    --['colorname'] = {r, g, b, hex},
    ['red'] = {208, 36, 36, "#d02424"},
	['green'] = {113, 208, 36, "#71d024"},
    ['blue'] = {51, 153, 255,"#3399ff"},
	['blue2'] = {36, 109, 208, "#246dd0"},
	['yellow'] = {208, 153, 36, "#d09924"},
    ["orange"] = {255, 153, 51, "#ff9933"},
    ['lightyellow'] = {255, 209, 26, "#ffd11a"},
}

serverColor = 'orange'
serverName = 'StayMTA'
hexCode = colors[serverColor][4]
low = hexCode .. '[' .. serverName .. '] #FFFFFF'

function converType(t)
    if t == "error" then
        return 'red'
    elseif t == "info" then
        return 'blue'
    elseif t == "warning" then
        return serverColor
    elseif t == "success" then
        return 'green'
    end
    
    return nil
end

function getServerSyntax(extra, t)
    if extra and type(extra) == "string" then
        if t then
            if colors[t] then
                return colors[t][4] .. '[' .. serverName .. ' - ' .. extra .. '] #FFFFFF'
            else
                return colors[converType(t)][4] .. '[' .. serverName .. ' - ' .. extra .. '] #FFFFFF'
            end
        else
            return hexCode .. '[' .. serverName .. ' - ' .. extra .. '] #FFFFFF'
        end
    else
        if t then
            if colors[t] then
                return colors[t][4] .. '[' .. serverName .. '] #FFFFFF'
            else
                return colors[converType(t)][4] .. '[' .. serverName .. '] #FFFFFF'
            end
        else
            return serverData['syntax']
        end
    end
end

function getServerColor(color, hexCode)
    if not hexCode then
	    local r,g,b = colors[serverColor][1], colors[serverColor][2], colors[serverColor][3]
		if color and colors[color] then
		    r,g,b = colors[color][1], colors[color][2], colors[color][3]
		end
		return r,g,b
	else
	    local hex = colors[serverColor][4]
		if color and colors[color] then
		    hex = colors[color][4]
		end
		return hex
	end
end