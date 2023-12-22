local sx,sy = guiGetScreenSize()

local oldRandom = 0
local currentQuestion
local currentMarker
local currentCorrect
local currentTask
local currentPed
local curentText
local currentCP
local placedCP

function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 100
        else
            return ( x ^ 2 + y ^ 2 + z ^ 2 ) ^ 0.5 * 1.8 * 100
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

function shadowedText(text,x,y,w,h,color,fontsize,font)
    exports['cr_core']:shadowedText(text,x,y,w,h,color,fontsize,font,"center","center")
end

function dxDrawnBorder(x, y, w, h, color2, color1)
    exports['cr_core']:roundedRectangle(x,y,w,h,color1,color2)
end

local render1 = {0,0,0,0}

if getResourceState(getResourceFromName("cr_core")) == "running" then
    serverName = exports['cr_core']:getServerData('name')
    r,g,b = exports['cr_core']:getServerColor('red', false)
    gr,gg,gb = exports['cr_core']:getServerColor('green', false)
    hexColor = exports['cr_core']:getServerColor(nil, true)
    or1, og, ob = exports['cr_core']:getServerColor(nil, false)
    version = exports['cr_core']:getVersion()
end

if getResourceState(getResourceFromName("cr_fonts")) == "running" then
    font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
    font2 = exports['cr_fonts']:getFont("Yantramanav-Black", 11)
    awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 13)
end

addEventHandler("onClientResourceStart", root,
    function(startedRes)
    	local startedResName = getResourceName(startedRes)
        if startedResName == "cr_core" then
            serverName = exports['cr_core']:getServerData('name')
            r,g,b = exports['cr_core']:getServerColor('red', false)
            gr,gg,gb = exports['cr_core']:getServerColor('green', false)
            hexColor = exports['cr_core']:getServerColor(nil, true)
            or1, og, ob = exports['cr_core']:getServerColor(nil, false)
            version = exports['cr_core']:getVersion()
        elseif startedResName == "cr_fonts" then
	        font = exports['cr_fonts']:getFont("Yantramanav-Regular", 12)
            font2 = exports['cr_fonts']:getFont("Yantramanav-Black", 11)
            awesomeFont = exports['cr_fonts']:getFont("AwesomeFont", 13)
        end
	end
)

local size = {
    ["LoginBG"] = {300, 340},
    ["LoginBox1"] = {180, 30},
    ["LoginBox2"] = {500, 30},
    ["LoginBox3"] = {200, 30},
}

local pedtext = {}

function getPedText(id, price)
    local text = {}
    if id == 1 then
        text = {
            "Üdvözlöm Autóiskolában! Ha jogosítványt szeretne akkor jó helyen jár! * mosolyog a vizsgabiztos * (nyomj egy ENTER-t vagy BACKSPACE-t)",
            "Biztos benne uram? A vizsga ára $"..price.." lesz! (nyomj egy ENTER-t vagy BACKSPACE-t)",
            "Remek hozzá is láthat a teszthez! (nyomj ENTER-t a továbblépéshez)",
        }
	elseif id == 2 then
		text = {
			"Adj' Isten komé! Ha jogost szeretnél akkor biza jó helyen jársz. * e-közben rágcsálja a bagót * (nyomj egy ENTER-t vagy BACKSPACE-t)",
            "Aszondja hogy, az annyi vóna mint "..price.."$ zöldhasú bankártya tabu! (nyomj egy ENTER-t vagy BACKSPACE-t)",
			"Hát akkó had szóljon, aztat sok szerencsét! (nyomj ENTER-t a továbblépéshez)",
		}
	elseif id == 3 then
		text = {
			"Szevasz haver. Hallom rónád az utakat, a legjob helyre jöttél * e-közben hangosan nevet * (nyomj egy ENTER-t vagy BACKSPACE-t)",
            "Hát tesó, a vizsga ára az "..price.."$ lesz, sajnálom de nekem is meg kell élni! (nyomj egy ENTER-t vagy BACKSPACE-t)",
			"Na jólvan csapasd neki a tesztet! (nyomj ENTER-t a továbblépéshez)",
		}
    end
    return text
end

local questions = {
    --{"Kérdés?","Válasz1","válasz2","válasz3",nil,helyesválaszidje}
    {"Hol adhat hangjelzést balesetveszély esetében?","Lakott területen belül és kívül egyaránt.","Csak lakott területen kívül.","Csak lakott területen.",nil,1},
    {"Sűrű köd miatt korlátozottak a látási viszonyok. Ki kell-e világítani a forgalomban részt vevő gépkocsit?","Csak éjszaka.","Csak lakott területen kívül.","Igen.",nil,3},
	{"Mennyi a megengedett sebesség autópályán?","50 km/h","90 km/h.","130 km/h.",nil,3},
    {"Hogyan kell beállítani a vezetőnek a belső tükröt?","Úgy, hogy lássa a tükör közepén az út jobb szélét.","Úgy, hogy lássa a tükör közepén a hátsó ablak közepét.","Úgy, hogy lássa a tükör közepén a hátsó ablak felső harmadát.",nil,2},
    {"Az úttest széléről elindulva?","számíthat arra, hogy az úttesten haladó járművek elsőbbséget adnak Önnek.","nem zavarhatja az úttesten haladó járműveket.","elsőbbséget kell adnia az úttesten haladó gyalogosok és járművek részére.",nil,3},
    {"Kell-e irányjelzéssel jelezni az irányváltoztatás nélkül végrehajtott kikerülést?","Nem.","Igen.","Nem tudom.",nil,1},
    {"Közlekedhet-e gyalogosként autóút útpadkáján?","Igen.","Nem.","Nem tudom.",nil,2},
    {"Mennyi a megengedett sebesség lakott területen belül?","50 km/h","90 km/h.","110 km/h.",nil,1},
    {"Az alábbiak közül melyik jármű előzhető meg gépjárművel a vasúti átjáróban?","A lovas kocsi.","A lassú jármű.","A kétkerekű motorkerékpár.",nil,3},
    {"Milyen sebességgel közlekedhet a mezőgazdasági vontató?","Legfeljebb 40 km/h sebességgel.","Legfeljebb 30 km/h sebességgel.","Legfeljebb 50 km/h sebességgel.",nil,1},
    {"Hol köteles-e a forgalomban részt vevő személygépkocsi vezetője magát becsatolt biztonsági övvel rögzíteni?","Csak lakott területen.","Lakott területen belül és kívül egyaránt.","Csak lakott területen kívül.",nil,2},
    {"A balesetről a rendőrhatóságot értesíteni kell, ha?","az halált vagy személyi sérülést okozott.","a keletkezett dologi kár az 50 dollárt nyilvánvalóan meghaladja.","a balesetben kettőnél több jármű érintett.",nil,1},
    {"Meg kell-e jelölni elakadást jelző háromszöggel az úttesten vagy a leállósávon levő elromlott gépkocsit?","Lakott területen kívül és belül egyaránt.","Csak lakott területen belül.","Csak lakott területen kívül.",nil,3},
    {"Hogyan kell lefékezni a gépkocsit, ha menet közben az üzemi fék hatástalanná válik?","Az I. sebességfokozatba kapcsolva, motorfékkel.","A kézifékkel és motorfékkel.","A legnagyobb sebességfokozatba kapcsolva, motorfékkel.",nil,2},
    {"Mennyi a megengedett sebesség lakott területen kívül/egyéb utakon?","50 km/h","90 km/h.","130 km/h.",nil,2},
}

local npcs = {
    --[[ [id] = {x,y,z,rot,dim,int,skin,cost, 
    {
        [1] = {model, startx, starty, startz, startdim, startint, {vehrot}}, 
        [2] = {model, startx, starty, startz, startdim, startint, {vehrot}}, 
    }
    {camerax, cameray, camerz}},
    ]]
    [1] = {1852.3791503906, -1145.2113037109, 23.834257125854,-90,0,0,295, 200, 
    {
        [1] = {436, 1801.1702880859, -1038.6640625, 23.55237197876, 0,0, {0,0,32}}, 
        [2] = {436, 1864.8475341797, -1145.0666503906, 23.741874694824, 0,0, {0,0,180}}, 
    },
    {1853.9765625, -1145.1911621094, 24.254602813721}},
	
    [2] = {-2105.9028320313, -2480.6062011719, 30.625,230,0,0,161, 125, 
    {
        [1] = {605, -2108.625, -2488.54296875, 30.625, 0,0, {0,0,145}}, 
        [2] = {605, -2092.3288574219, -2491.6728515625, 30.235929489136, 0,0, {0,0,320}}, 
    },
    {-2104.798828125, -2481.4418945313, 30.925}},
	
    [3] = {-2664.2993164063, -8.9520225524902, 6.1328125,85,0,0,59, 125, 
    {
        [1] = {480, -2656.7526855469, -55.496654510498, 4.3359375, 0,0, {0,0,360}}, 
        [2] = {480, -2704.4948730469, -6.2590804100037, 3.8366529941559, 0,0, {0,0,360}}, 
    },
    {-2665.5202636719, -8.9318332672119, 6.6328125}},
}

local peds = {}

--ide spawnolja a playert alap : x,y,z kocsival ez kell nekem később mikor spawnolja
local markers = {
    --[[
    [id] = {
        [1] = {
            {x,y,z},
        },
        [2] = {
            {x,y,z},
        },
    },
    ]]
    [1] = {
        [1] = {
            {1776.5045166016, -1028.6662597656, 23.547315597534},
            {1767.947265625, -1016.6766357422, 23.55454826355},
            {1756.9968261719, -1038.4494628906, 23.552278518677},
            {1765.8902587891, -1041.9050292969, 23.553972244263},
            {1778.505859375, -1045.9899902344, 23.565065383911},
            {1775.8559570313, -1039.3149414063, 23.556701660156},
            {1771.005859375, -1043.8791503906, 23.561019897461},
            {1778.8916015625, -1045.1916503906, 23.560617446899},
            {1777.8342285156, -1039.7548828125, 23.558471679688},
            {1771.2489013672, -1042.3087158203, 23.561603546143},
            {1779.7354736328, -1054.7459716797, 23.552274703979},
            {1780.1029052734, -1061.6827392578, 23.553606033325},
            {1792.9184570313, -1055.2043457031, 23.55624961853},
            {1802.4158935547, -1071.2845458984, 23.55838394165},
            {1783.4910888672, -1080.3314208984, 23.555847167969},
            {1775.0606689453, -1069.6563720703, 23.55411529541},
            {1771.3309326172, -1086.6890869141, 23.55326461792},
            {1766.0886230469, -1069.4052734375, 23.554191589355},
            {1762.2344970703, -1086.2095947266, 23.552700042725},
            {1778.8591308594, -1079.3596191406, 23.549259185791},
            {1796.3344726563, -1085.8178710938, 23.554740905762},
            {1807.9471435547, -1074.9422607422, 23.553178787231},
            {1802.5268554688, -1058.5010986328, 23.547842025757},
            {1800.9787597656, -1038.3909912109, 23.554183959961},
        },
        [2] = {
            {1864.5131835938, -1160.5739746094, 23.682647705078},
            {1850.2579345703, -1178.5749511719, 23.23357963562},
            {1822.6663818359, -1179.0008544922, 23.214315414429},
            {1757.3397216797, -1162.4666748047, 23.234760284424},
            {1688.5004882813, -1159.0009765625, 23.251377105713},
            {1530.6851806641, -1158.9403076172, 23.502727508545},
            {1454.9295654297, -1158.7374267578, 23.261394500732},
            {1452.7055664063, -1261.0810546875, 12.975581169128},
            {1452.8935546875, -1381.1301269531, 12.979950904846},
            {1452.9925537109, -1432.6655273438, 12.975529670715},
            {1422.8859863281, -1431.7338867188, 12.977278709412},
            {1371.5786132813, -1393.5093994141, 13.035922050476},
            {1359.5270996094, -1280.2546386719, 12.952201843262},
            {1273.3041992188, -1279.1407470703, 12.89870262146},
            {1197.2072753906, -1324.0059814453, 12.991264343262},
            {1196.9860839844, -1381.8940429688, 12.878623962402},
            {1194.5328369141, -1477.0283203125, 12.97922706604},
            {1272.1115722656, -1573.9876708984, 12.979421615601},
            {1295.2727050781, -1693.2718505859, 12.976426124573},
            {1295.3991699219, -1838.7468261719, 12.976016044617},
            {1311.9451904297, -1855.4318847656, 12.97584438324},
            {1313.9028320313, -1737.6810302734, 12.97323513031},
            {1407.8740234375, -1734.0701904297, 12.981648445129},
            {1431.2886962891, -1676.326171875, 12.975317955017},
            {1454.8605957031, -1594.5189208984, 12.973835945129},
            {1527.8907470703, -1607.2520751953, 12.975261688232},
            {1534.5875244141, -1734.7263183594, 12.974869728088},
            {1672.9224853516, -1734.2994384766, 12.974032402039},
            {1750.9487304688, -1678.4404296875, 12.979440689087},
            {1764.5526123047, -1606.6596679688, 12.968647956848},
            {1823.2780761719, -1597.4866943359, 12.951598167419},
            {1924.8653564453, -1520.1408691406, 2.8812172412872},
            {2308.220703125, -1614.3610839844, 4.3279814720154},
            {2708.814453125, -1627.2097167969, 12.790900230408},
            {2788.2487792969, -1659.2850341797, 10.482273101807},
            {2891.9172363281, -1618.1052246094, 10.468263626099},
            {2916.0727539063, -1324.1574707031, 10.471550941467},
            {2885.6931152344, -1140.9084472656, 10.468414306641},
            {2775.7993164063, -1144.6910400391, 31.45770072937},
            {2578.1047363281, -1149.8759765625, 47.091663360596},
            {2298.9509277344, -1149.0325927734, 26.364429473877},
            {2223.4291992188, -1147.0771484375, 25.401168823242},
            {2227.7785644531, -1176.9047851563, 25.318159103394},
            {2217.3596191406, -1141.1209716797, 25.393520355225},
            {2097.3618164063, -1099.1066894531, 24.580018997192},
            {2066.4340820313, -1254.9803466797, 23.418140411377},
            {1993.0606689453, -1275.0872802734, 23.415409088135},
            {1971.8857421875, -1187.2625732422, 25.398170471191},
            {1902.6011962891, -1134.1458740234, 23.972360610962},
            {1863.8824462891, -1165.4161376953, 23.261405944824},
        }
    },
    [2] = {
        [1] = {
            {-2112.7822265625, -2493.4904785156, 30.625},
            {-2125.7243652344, -2487.8264160156, 30.386547088623},
            {-2121.5451660156, -2472.3586425781, 30.380170822144},
            {-2113.501953125, -2467.6130371094, 30.390741348267},
            {-2128.3955078125, -2482.4936523438, 30.390247344971},
            {-2129.2158203125, -2492.0791015625, 30.390880584717},
            {-2122.4304199219, -2492.4350585938, 30.393329620361},
            {-2110.2770996094, -2489.1643066406, 30.388229370117},
            {-2117.6689453125, -2499.4545898438, 30.389934539795},
            {-2117.6169433594, -2483.9536132813, 30.391241073608},
        },
        [2] = {
            {-2082.1481933594, -2478.2678222656, 30.232172012329},
            {-2099.0341796875, -2445.4594726563, 30.233360290527},
            {-2159.8627929688, -2497.7666015625, 30.236068725586},
            {-2190.6274414063, -2487.94140625, 30.231565475464},
            {-2154.0190429688, -2423.6838378906, 30.232082366943},
            {-2109.009765625, -2367.3627929688, 30.229890823364},
            {-2141.6108398438, -2322.9931640625, 30.229887008667},
            {-2266.4382324219, -2220.9638671875, 29.978607177734},
            {-2149.9514160156, -2136.2338867188, 54.023700714111},
            {-2062.7475585938, -1972.8870849609, 57.090637207031},
            {-1937.0811767578, -1804.4002685547, 32.189712524414},
            {-1891.4088134766, -1719.4281005859, 21.510799407959},
            {-1895.9464111328, -1671.5769042969, 22.777008056641},
            {-1903.7297363281, -1682.7436523438, 22.778987884521},
            {-1917.4353027344, -1747.6416015625, 22.425092697144},
            {-1689.8309326172, -1650.2326660156, 36.017799377441},
            {-1579.5267333984, -1607.5329589844, 36.618957519531},
            {-1445.498046875, -1629.5786132813, 44.412826538086},
            {-1223.1597900391, -1772.3984375, 46.952556610107},
            {-1094.2034912109, -1905.9130859375, 76.196914672852},
            {-984.07550048828, -1944.4697265625, 78.76636505127},
            {-1014.7303466797, -2004.7943115234, 68.789215087891},
            {-1114.8952636719, -2177.6184082031, 33.116569519043},
            {-1185.7052001953, -2489.6096191406, 61.270637512207},
            {-1038.3604736328, -2615.4582519531, 80.978408813477},
            {-878.03485107422, -2559.5964355469, 90.221366882324},
            {-792.69482421875, -2477.3728027344, 78.309440612793},
            {-715.48394775391, -2350.7124023438, 40.839691162109},
            {-627.09893798828, -2361.3215332031, 31.241611480713},
            {-578.76818847656, -2369.4274902344, 28.066923141479},
            {-668.00036621094, -2499.2336425781, 39.146392822266},
            {-719.07257080078, -2623.1853027344, 76.873908996582},
            {-773.29931640625, -2685.7102050781, 83.862884521484},
            {-902.24932861328, -2664.3625488281, 90.665397644043},
            {-987.10198974609, -2680.1782226563, 60.766540527344},
            {-1041.1981201172, -2680.6477050781, 45.943607330322},
            {-1119.3494873047, -2655.6750488281, 17.084228515625},
            {-1282.1185302734, -2641.04296875, 6.3653697967529},
            {-1441.1958007813, -2633.001953125, 35.493560791016},
            {-1580.8629150391, -2634.017578125, 53.426853179932},
            {-1677.1507568359, -2603.7780761719, 37.200687408447},
            {-1750.3283691406, -2527.513671875, 3.1641807556152},
            {-1822.2191162109, -2462.8891601563, 24.641019821167},
            {-1896.3748779297, -2416.513671875, 32.234199523926},
            {-1966.7026367188, -2479.0290527344, 30.631776809692},
            {-2021.8160400391, -2505.1706542969, 32.353393554688},
            {-2065.9946289063, -2470.7905273438, 30.46875},
            {-2100.9970703125, -2477.0512695313, 30.625},
        }
    },
    [3] = {
        [1] = {
            {-2649.7802734375, -45.250354766846, 4.3359375},
            {-2646.6704101563, -37.961776733398, 3.9906642436981},
            {-2635.4079589844, -43.460269927979, 3.9895453453064},
            {-2633.86328125, -34.815399169922, 3.9908423423767},
            {-2637.2023925781, -55.500221252441, 3.9909703731537},
            {-2627.7951660156, -34.822246551514, 3.9907903671265},
            {-2620.4733886719, -40.626613616943, 3.9889659881592},
            {-2620.6574707031, -31.544540405273, 3.9899454116821},
            {-2617.5734863281, -21.833335876465, 3.990939617157},
            {-2617.3381347656, -43.409896850586, 3.9894125461578},
            {-2617.3103027344, -55.232833862305, 3.9914364814758},
            {-2623.2145996094, -50.316577911377, 3.9909195899963},
            {-2623.1213378906, -55.5124168396, 3.9909303188324},
            {-2620.25390625, -50.346374511719, 3.9909701347351},
            {-2627.8566894531, -50.108512878418, 3.9908828735352},
            {-2633.5920410156, -54.274955749512, 3.9902627468109},
            {-2640.0830078125, -50.364273071289, 3.9897437095642},
            {-2646.9599609375, -54.13069152832, 3.9889175891876},
            {-2654.0085449219, -50.305023193359, 3.9896545410156},
            {-2657.0710449219, -55.657405853271, 3.9920711517334},
        },
        [2] = {
            {-2704.5205078125, 26.711536407471, 3.8396909236908},
            {-2645.7219238281, 37.349514007568, 3.845155954361},
            {-2545.5, 37.149749755859, 16.100019454956},
            {-2419.1572265625, 100.69857788086, 34.670406341553},
            {-2416.4426269531, 178.05218505859, 34.669860839844},
            {-2452.4853515625, 178.46775817871, 34.621501922607},
            {-2460.8017578125, 151.10841369629, 34.614883422852},
            {-2430.6186523438, 137.7621307373, 34.665992736816},
            {-2412.4973144531, 282.49530029297, 34.651679992676},
            {-2317.8308105469, 409.12768554688, 34.675956726074},
            {-2364.0634765625, 492.67037963867, 30.146152496338},
            {-2383.1418457031, 652.29553222656, 34.670818328857},
            {-2281.7983398438, 666.46203613281, 48.692356109619},
            {-2253.3117675781, 746.91558837891, 48.952030181885},
            {-2209.1345214844, 806.337890625, 49.026802062988},
            {-2140.4711914063, 905.55267333984, 79.507537841797},
            {-2099.2534179688, 926.88488769531, 74.712677001953},
            {-2087.5986328125, 915.61993408203, 67.571708679199},
            {-2064.26171875, 947.849609375, 59.678756713867},
            {-2042.1293945313, 923.12261962891, 52.207336425781},
            {-1988.9791259766, 916.12115478516, 44.950721740723},
            {-1733.3321533203, 914.95812988281, 24.396945953369},
            {-1716.8804931641, 865.21301269531, 24.398061752319},
            {-1574.6231689453, 835.70159912109, 6.7735729217529},
            {-1562.5362548828, 703.02160644531, 6.6916918754578},
            {-1621.9938964844, 435.63333129883, 6.6874938011169},
            {-1668.7086181641, 407.53530883789, 6.8362512588501},
            {-1814.4697265625, 379.72131347656, 16.667104721069},
            {-1902.4398193359, 345.59539794922, 28.119358062744},
            {-1989.9484863281, 349.17510986328, 34.604312896729},
            {-2009.0903320313, 186.73997497559, 27.194625854492},
            {-2008.7635498047, -54.566257476807, 34.822834014893},
            {-2153.62890625, -68.343307495117, 34.827472686768},
            {-2174.7678222656, -175.26820373535, 34.82413482666},
            {-2260.1401367188, -280.61270141602, 44.995513916016},
            {-2206.4382324219, -462.24783325195, 49.419193267822},
            {-2231.7333984375, -737.42681884766, 64.932403564453},
            {-2342.8586425781, -715.14581298828, 108.77158355713},
            {-2455.8701171875, -524.83117675781, 113.9701461792},
            {-2627.2580566406, -490.86853027344, 69.633316040039},
            {-2369.7060546875, -446.08813476563, 81.198837280273},
            {-2676.8666992188, -460.46450805664, 27.299007415771},
            {-2819.3549804688, -438.25567626953, 6.6947903633118},
            {-2807.8022460938, -76.328109741211, 6.6843137741089},
            {-2704.0495605469, -48.570152282715, 3.8413693904877},
            {-2690.1630859375, -22.752908706665, 3.9895241260529},
        }
    },
}

local messages1 = {
    --[[
    [id] = {
        "Text",
    },
    ]]
    [1] = {
        "Figyelj arra, hogy óvatosan vezes ne kapkodj és légy figyelmes!",
        "Mindig nézz körbe, mielőtt kikanyarodsz és indexelni se felejts el!",
        "A sebesség határt azért tartsd be, mert simán küldenek egy olyan csekket, hogy abban a hónapban nem tankolsz!",
        "Rágyújtok egy szálra, nem zavar? *előveszi a zippo-t a zsebéből*",
        "Ebben a városban minden lehetőség adott, de azért ne keveredj bajba.",
        "15-éve tanítok már kreszt de úgy érzem kezdek már kiöregedni.",
        "A sikátorokkal vigyázz, hiába szeretem ezt a város sajnos vannak sittes alakok.",
        "Remélem te nem valami drogos kattant alak vagy, jó embernek tűnsz.",
        "Mindig figyelj az útra, egy rosz tekintet és már a nyakadban a baleset.",
        "Na mostmár figyelj a vezetésre rendesen, nincs több beszéd.",
        ["SpeedLimitReached"] = "Nagyon gyorsan kezdj el fékezni mert ebből jogsi nem lesz...((Maximum 70km/h))",
    },
    [2] = {
        "Hallod-e azé ilyen fisfos roncsal ne mönjé az utakra, me gyün a sün oszt bekaszliz!",
        "Ha nem menekűsz akkó ne hagyjtsá gyorsan me estibö nem lesz kocsma!",
        "Osztan hova valósi vagyol-e, én má frütykös korom óta itt retkelem az utaköt! *halkan felnevet*",
        "Há remélem nincs bajud a cigivő me rágyujtok a kis pipámra de azonnal.",
        "Némá ott a seriff komém, ja nem csak kicsit kancsalítok oszt félre néztöm.",
        "Bözzeg az én időmbe míg jogsi se köllöt hogy csotrogányt vözessünk.",
        "Aztán a nevemöt el ne felítsed tudd ki adta a vastat a kezedbö.",
        "Van a városkánkba egy csudijó örömlányt házinnyó, ha gondolod bemutatlak nékik *felnevet hangosan*.",
        "Nemám a kolbászra bukol, nincs níkem bajum völük de azé mégis csak.",
        "Na jóvan fiam nincs több dumaragu csak vözessé.",
        ["SpeedLimitReached"] = "Csapjá rá a fíkre de izibö, há nem akarok én meghóni...((Maximum 70km/h))",
    },
    [3] = {
        "Hallod haver, én elhiszem hogy yolo vagy meg minden de azért figyelmesen vezessél!",
        "Vigyázz mert a yardok nagyon kapósak nem csak San Fierro-ban hanem mindenhol!",
        "Idegen lányokat ne túl gyakran szedj össze, nagy részűktől elkapsz valami retket aztán baszhatod!",
        "Tesó, nagyon pangok kicsapom a cigit ha nem probléma * kivesz egy szál cigarettát majd a szájába teszi *",
        "Az izom autókhoz hogy viszonyulsz? A nők döglenek érte a teljesítményről meg ne is beszéljünk.",
        "Meggyőgztem a főgórét hogy vegyünk pár porsche-t tréning autónka hamár megtehetjük.",
        "Tudod nem mindenhol ilyen nagy arcok ám az emberek, nekem ez a másod szakmám * halkan felnevet *.",
        "Egy kis eki nem érdekel? Fű vagy gomba? Csak vicceltem tesó nem vagyok én ám rossz ember.",
        "Kezdem úgy érezni hog ez a meló felemészt engem, de máshol nem érezném otthon magam.",
        "Csak ügyesen, ma még szeretnék a saját ágyamban aludni.",
        ["SpeedLimitReached"] = "Haver mit csinálsz? Lassaban ha lehet...((Maximum 70km/h))",
    },
}

function start()
    for k,v in pairs(npcs) do
        local x,y,z,rot,dim,int,skinid,cost,startpos,camerapos = unpack(v)
        local ped = createPed(skinid,x,y,z,rot)
        setElementInterior(ped,int)
        setElementDimension(ped,dim)
        setElementFrozen(ped,true)
        local name = generateRandomName()
        --local skinid = giveARandomSkin()
        --ped[player] = createPed(skinid,0,0,0)
        setElementData(ped,"ped.name", name)
        setElementData(ped,"ped.type","Oktató")
        setElementData(ped,"ped.id","DriverLicense")
        setElementData(ped,"char >> noDamage",true)
        setElementData(ped,"driverlicense.ped",true)
        setElementData(ped,"driverlicense.cost",cost)
        setElementData(ped,"driverlicense.id",k)
        setElementData(ped,"driverlicense.startPos",startpos)
        setElementData(ped,"driverlicense.cameraPos",camerapos)
        peds[ped] = true
        setTimer(
            function()
                --createStayBlip(name,element,visible,image,imgw,imgh,imgr,imgg,imgb)
                local blip = createBlip(x,y,z)
                -- exports['cr_radar']:createStayBlip("Autósiskola " .. k,blip,0,"driverlicense",32,32,255, 255, 255)
				exports.cr_radar:createStayBlip("Autósiskola " .. k, blip, 0, "driving_license", 32, 32, 255, 255, 255)
            end, 
        1000, 1) 
    end
end
addEventHandler("onClientResourceStart",resourceRoot,start)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		for id, _ in pairs(npcs) do
			exports['cr_radar']:destroyStayBlip("Autósiskola " .. id)
		end
	end
)

local maxWarning = 5

setTimer(
    function()
        if currentTask == "cp" or currentTask == "cp2" then
            if isTimer(speedMessageTimer) then return end
            local veh = getPedOccupiedVehicle(localPlayer)
            if not veh then return end
            local speed = getElementSpeed(veh)
            if speed > 90 then
                messages(true)
                warning = warning + 2
                speedMessageTimer = setTimer(function() end, 2000, 1)
            elseif speed > 73 then
                messages(true)
                warning = warning + 1
                speedMessageTimer = setTimer(function() end, 2000, 1)
            end
            if warning > maxWarning then
                triggerServerEvent("destroyCar",localPlayer,localPlayer)
                exports['cr_infobox']:addBox("error", "A vizsgád sikertelen lett, túl sokszor lettél figyelmeztetve hogy gyorsan mész.")
                 --kedvezményes panel 120$-ért
                isHavePricable = true
                currentQuestion = 0
                currentCorrect = 0
                currentTask = nil
                render1 = {0,0,0,0}
                setElementData(currentPed, "driverlicense.using", false)
                currentPed = nil
                currentCP = nil
                destroyElement(placedCP)
                exports['cr_radar']:destroyStayBlip("Marker")
            end
        end
    end, 2000, 0
)

function messages(speed)
    if isTimer(speedMessageTimer) then return end
    local currentPed = getElementData(localPlayer, "driverlicense.ped")
    if not isElement(currentPed) then
        return
    end
    --local id = getElementData(currentPed,"driverlicense.id")
    local random = math.random(1,#messages1[id]) 
    if random == oldRandom then
        messages(speed)
        return
    end
    oldRandom = random
    local message = messages1[id][random]
    if speed then
        message = messages1[id]["SpeedLimitReached"]
    end
    local veh = getPedOccupiedVehicle(localPlayer)
    local isWindowableVeh = false
    if veh then
        isWindowableVeh = exports['cr_vehicle']:isWindowableVeh(getElementModel(veh)) or true
    end
    --outputChatBox("isWindowableVeh: " .. tostring(isWindowableVeh))
    --outputChatBox("VEH: " .. tostring(isElement(veh)))
    if veh and isWindowableVeh then
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end

        local name = getElementData(currentPed, "ped.name"):gsub("_", " ")
        if not getElementData(veh, "veh >> windowState") then
            outputChatBox(name.." mondja: "..message, 255,255,255)
        else
            outputChatBox(name.." mondja (járműben): "..message, 255,255,255)
        end

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(currentPed)
        for k,v in pairs(getElementsByType("player")) do
            if v ~= localPlayer and getElementInterior(v) == getElementInterior(localPlayer) and getElementDimension(v) == getElementDimension(localPlayer) then
                local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                if veh2 and veh == veh2 then
                    local r,g,b = 255,255,255
                    if not getElementData(veh, "veh >> windowState") then
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                    else    
                        triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja (járműben): "..message, r,g,b)
                    end    
                elseif distance <= 8 and not getElementData(veh, "veh >> windowState") then
                    local r,g,b = 255,255,255
                    --outputChatBox(distance)
                    if distance <= 2 then
                        r,g,b = 255,255,255
                    elseif distance <= 4 then
                        r,g,b = 191, 191, 191 --75% white
                    elseif distance <= 6 then
                        r,g,b = 166, 166, 166 --65% white
                    elseif distance <= 8 then
                        r, g, b = 115, 115, 115 --45% white
                    else
                        r, g, b = 95, 95, 95 --?% white
                    end

                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                end
            end
        end
    else
        --local message
        if string.len(message) > 1 then
            message = string.upper(string.sub(message, 1, 1)) .. string.sub(message, 2, string.len(message))
        elseif string.len(message) < 1 or string.len(message) == 0 then
            return
        elseif string.sub(message, 1, 1) == " " then
            return    
        elseif string.len(message) > maxLength then
            return
        else
            message = string.upper(string.sub(message, 1, 1))
        end
        
        local name = getElementData(currentPed, "ped.name"):gsub("_", " ")
        outputChatBox(name.." mondja: "..message, 255,255,255)

        spamTimer = setTimer(function() end, 300, 1)

        local x,y,z = getElementPosition(currentPed)
        for k,v in pairs(getElementsByType("player")) do
            if v ~= localPlayer and getElementInterior(v) == getElementInterior(localPlayer) and getElementDimension(v) == getElementDimension(localPlayer) then
                local x1, y1, z1 = getElementPosition(v)
                local distance = math.floor(getDistanceBetweenPoints3D(x, y, z, x1, y1, z1))
                local veh2 = getPedOccupiedVehicle(v)
                --outputChatBox("WINDOWSTATE: " .. tostring(getElementData(veh, "veh >> windowState")))
                local nowVeh = veh
                if not nowVeh then
                    nowVeh = veh2
                end
                if distance <= 8 and not veh2 or distance <= 8 and veh2 and not getElementData(nowVeh, "veh >> windowState") then
                    local r,g,b = 255,255,255
                    if distance <= 2 then
                        r,g,b = 255,255,255
                    elseif distance <= 4 then
                        r,g,b = 191, 191, 191 --75% white
                    elseif distance <= 6 then
                        r,g,b = 166, 166, 166 --65% white
                    elseif distance <= 8 then
                        r, g, b = 115, 115, 115 --45% white
                    else
                        r, g, b = 95, 95, 95 --?% white
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                elseif veh2 and distance <= 4 and getElementData(veh2, "veh >> windowState") then
                    local r,g,b = 255,255,255
                    if distance <= 2 then
                        r,g,b = 166, 166, 166 --65% white
                    elseif distance <= 4 then
                        r, g, b = 115, 115, 115 --45% white
                    else
                        r, g, b = 95, 95, 95 --?% white
                    end
                    triggerServerEvent("giveMessageToClient", localPlayer,  localPlayer, v, name.." mondja: "..message, r,g,b)
                end
            end
        end
    end
    --outputChatBox(messages1[random])
    --[[if speed > 70 then
        
    elseif speed < 10 then
        
    end]]--
end

function renderPedpanel()
    if render1[1] < 100 then
        render1[1] = render1[1] +1
    end
    
    dxDrawnBorder(0,0,sx,render1[1],tocolor(0,0,0))
    dxDrawnBorder(0,sy-render1[1],sx,render1[1],tocolor(0,0,0))
    
    if render1[1] == 100 then
        local length = dxGetTextWidth(pedtext[currentText], 1.3, "default-bold", false)
        if render1[currentText+1] < length + 40 then
            render1[currentText+1] = render1[currentText+1] +3
        end
        dxDrawText(pedtext[currentText],30,sy-100,render1[currentText+1],sy,tocolor(255,255,255,255),1.3,"default-bold","left","center",true)
    end    
end

function renderTest()
    --[[
    dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2,400,75,tocolor(0,0,0,200))
    
    for i = 1, 4 do
       dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2 + 77*i,400,75,isInSlot(sx/2 - 400/2,sy/2 - (77*5)/2 + 77*i,400,75) and tocolor(255,125,25,150) or tocolor(0,0,0,150))
    end
    --]]
    
    --dxDrawnBorder(sx/2 - 400/2-2,sy/2 - (77*5)/2 - 2,404,2,tocolor(0,0,0,230))
    --dxDrawnBorder(sx/2 - 400/2-2,sy/2 + (77*5)/2,404,2,tocolor(0,0,0,230))
    --dxDrawnBorder(sx/2 - 400/2-2,sy/2 - (77*5)/2,2,(77*5),tocolor(0,0,0,230))
    --dxDrawnBorder(sx/2 + 400/2,sy/2 - (77*5)/2,2,(77*5),tocolor(0,0,0,230))
    
    --dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2 + 75,400,2,tocolor(0,0,0,230)) 
    --dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2 + 202,400,2,tocolor(0,0,0,230)) 
    --dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2 + 304,400,2,tocolor(0,0,0,230)) 
    --dxDrawnBorder(sx/2 - 400/2,sy/2 - (77*5)/2 + 406,400,2,tocolor(0,0,0,230))
    
    --[[
    local table = questions[currentQuestion]
    for k,v in pairs(table) do
        if k > 5 then break end
        local a = {"","A. ","B. ","C. ","D. "}
        dxDrawText(a[k]..v,sx/2 - 150,sy/2 - (77*5)/2 + 75/2 + (k-1)*77,sx/2 + 150,sy/2 - (77*5)/2 + 75/2 + (k-1)*77,tocolor(255,255,255),1.4,"default-bold","center","center",false,true) 
    end 
    --]]
    
    shadowedText(questions[currentQuestion][1], sx/2, sy/2 - (size["LoginBox2"][2] * 2 + 30), sx/2, sy/2 - (size["LoginBox2"][2] * 2 + 30), tocolor(255,255,255,255),fontsize, font, "center", "center")
    if selectedQuestion == 1 or isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 - (size["LoginBox2"][2] + 40), size["LoginBox2"][1], size["LoginBox2"][2]) then
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 - (size["LoginBox2"][2] + 40), size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(r,g,b,220)) -- Felhasználónév
        shadowedText(questions[currentQuestion][2], sx/2, sy/2 - (size["LoginBox2"][2] + 40), sx/2, sy/2 - (size["LoginBox2"][2] + 40 - size["LoginBox2"][2]), tocolor(r,g,b,255),fontsize, font, "center", "center")
    else
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 - (size["LoginBox2"][2] + 40), size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Felhasználónév
        shadowedText(questions[currentQuestion][2], sx/2, sy/2 - (size["LoginBox2"][2] + 40), sx/2, sy/2 - (size["LoginBox2"][2] + 40 - size["LoginBox2"][2]), tocolor(255,255,255,255),fontsize, font, "center", "center")
    end
        
    if selectedQuestion == 2 or isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 - size["LoginBox2"][2]/2, size["LoginBox2"][1], size["LoginBox2"][2]) then
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 - size["LoginBox2"][2]/2, size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(r,g,b,220)) -- Jelszó
        shadowedText(questions[currentQuestion][3], sx/2, sy/2 - size["LoginBox2"][2]/2, sx/2, sy/2 - size["LoginBox2"][2]/2 + size["LoginBox2"][2], tocolor(r,g,b,255),fontsize, font, "center", "center")
    else
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 - size["LoginBox2"][2]/2, size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Jelszó
        shadowedText(questions[currentQuestion][3], sx/2, sy/2 - size["LoginBox2"][2]/2, sx/2, sy/2 - size["LoginBox2"][2]/2 + size["LoginBox2"][2], tocolor(255,255,255,255),fontsize, font, "center", "center")
    end
        
    if selectedQuestion == 3 or isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 + (size["LoginBox2"][2]/2 + 25), size["LoginBox2"][1], size["LoginBox2"][2]) then
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 + (size["LoginBox2"][2]/2 + 25), size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(r,g,b,220)) -- Password 2
        shadowedText(questions[currentQuestion][4], sx/2, sy/2 + (size["LoginBox2"][2]/2 + 25), sx/2, sy/2 + (size["LoginBox2"][2]/2 + 25 + size["LoginBox2"][2]), tocolor(r,g,b,255),fontsize, font, "center", "center")
    else
        dxDrawnBorder(sx/2 - size["LoginBox2"][1]/2, sy/2 + (size["LoginBox2"][2]/2 + 25), size["LoginBox2"][1], size["LoginBox2"][2], tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Password 2
        shadowedText(questions[currentQuestion][4], sx/2, sy/2 + size["LoginBox2"][2]/2 + 25, sx/2, sy/2 + size["LoginBox2"][2]/2 + 25 + size["LoginBox2"][2], tocolor(255,255,255,255),fontsize, font, "center", "center")
    end
    
    if isInSlot(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 3), size["LoginBox3"][1], size["LoginBox3"][2]) then
        dxDrawnBorder(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 3), size["LoginBox3"][1], size["LoginBox3"][2], tocolor(0,0,0,180), tocolor(0, 0, 0,220)) -- Bejelentkezés
        dxDrawText("Tovább", sx/2, sy/2 + (size["LoginBox2"][2] * 3), sx/2, sy/2 + (size["LoginBox2"][2] * 3) + size["LoginBox3"][2], tocolor(gr,gg,gb,255),fontsize, font, "center", "center")
    else
        dxDrawnBorder(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 3), size["LoginBox3"][1], size["LoginBox3"][2], tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Bejelentkezés
        dxDrawText("Tovább", sx/2, sy/2 + (size["LoginBox2"][2] * 3), sx/2, sy/2 + (size["LoginBox2"][2] * 3) + size["LoginBox3"][2], tocolor(255,255,255,255),fontsize, font, "center", "center")
    end
    
    dxDrawnBorder(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 4 + 10), size["LoginBox3"][1], 15, tocolor(0,0,0,180), tocolor(0,0,0,220)) -- Bejelentkezés
    local multipler = currentQuestion / (#questions)
    local sizeWithMultipler = size["LoginBox3"][1] * multipler
    dxDrawnBorder(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 4 + 10), sizeWithMultipler, 15, tocolor(87,87,87,180), tocolor(0,0,0,220)) -- Bejelentkezés
    dxDrawText(currentQuestion .. "/" .. #questions, sx/2, sy/2 + (size["LoginBox2"][2] * 4 + 10), sx/2, sy/2 + (size["LoginBox2"][2] * 4 + 10) + 15, tocolor(255,255,255,255),fontsize, font, "center", "center")
end

local time = 750

function click(key,state,x,y,wx,wy,wz,element)
    if key == "left" and state == "down" then
        if currentTask == nil then
            if element and isElement(element) then
                if peds[element] and not getElementData(element, "driverlicense.using") then
                    local px,py,pz = unpack{getElementPosition(localPlayer)}
                    local ex,ey,ez = unpack{getElementPosition(element)}
                    local distance = getDistanceBetweenPoints2D(ex,ey,px,py)
                    if distance > 2 then return end
                    local price = getElementData(element, "driverlicense.cost") or 200
                    if isHavePricable then
                        price = price * 0.75
                    end
                    if exports['cr_core']:hasMoney(localPlayer, price, false) then
                        setElementData(localPlayer, "keysDenied", true)
                        setElementData(localPlayer, "hudVisible", false)
                        showChat(false)
                        currentTask = "pedpanel"
                        currentPed = element
                        currentText = 1
                        currentCorrect = 0
                        currentCP = nil
                        setElementFrozen(localPlayer, true)
                        toggleAllControls(false)
                        setElementData(element, "driverlicense.using", true)
                        local x1,y1,z1,x2,y2,z2 = getCameraMatrix()
                        local x3,y3,z3 = unpack(getElementData(element, "driverlicense.cameraPos"))
                        exports['cr_core']:smoothMoveCamera(x1,y1,z1,x2,y2,z2,x3,y3,z3,ex,ey,ez+0.5, time)
                        setTimer(
                            function()
                                local id = getElementData(element, "driverlicense.id") or 1
                                pedtext = getPedText(id, price)
                                --[[
                                pedtext = {
                                    "Üdvözöllek az Autóiskolában! Ha jogsit szeretnél akkor jó helyen jársz! * Kacsint a vizsgabiztos * (nyomj egy ENTER-t vagy BACKSPACE-t)",
                                    "Biztos vagy benne? A vizsga ára "..price.."$ lesz! (nyomj egy ENTER-t vagy BACKSPACE-t)",
                                    "Remek hozzá is láthatsz a teszthez! (nyomj egy ENTER-t)"
                                }
                                ]]
                                if not getElementData(localPlayer, "char >> vanish") then
                                    setElementAlpha(localPlayer, 0)
                                end
                                addEventHandler("onClientRender",root,renderPedpanel, true, "low-5")
                            end, time, 1
                        )
                    end
                    return
                end
            end 
        elseif currentTask == "test" then
            if isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 - (size["LoginBox2"][2] + 40), size["LoginBox2"][1], size["LoginBox2"][2]) then
                right = 1
                if selectedQuestion == 1 then
                    selectedQuestion = 0
                else
                    selectedQuestion = 1
                end
                return
            elseif isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 - size["LoginBox2"][2]/2, size["LoginBox2"][1], size["LoginBox2"][2]) then
                right = 2
                if selectedQuestion == 2 then
                    selectedQuestion = 0
                else
                    selectedQuestion = 2
                end
                return
            elseif isInSlot(sx/2 - size["LoginBox2"][1]/2, sy/2 + (size["LoginBox2"][2]/2 + 25), size["LoginBox2"][1], size["LoginBox2"][2]) then
                right = 3
                if selectedQuestion == 3 then
                    selectedQuestion = 0
                else
                    selectedQuestion = 3
                end
                return
            elseif isInSlot(sx/2 - size["LoginBox3"][1]/2, sy/2 + (size["LoginBox2"][2] * 3), size["LoginBox3"][1], size["LoginBox3"][2]) then
                if not selectedQuestion or selectedQuestion == 0 then
                    return
                end
                if checkCorrent(right,currentQuestion) then
                    currentCorrect = currentCorrect + 1
                    --exports['cr_infobox']:addBox("success", "A válasz helyes")
                    if currentQuestion + 1 <= #questions then
                        currentQuestion = currentQuestion + 1
                    else
                        checkEnd()
                    end
                else
                    --exports['cr_infobox']:addBox("success", "A válasz helytelen")
                    if currentQuestion + 1 <= #questions then
                        currentQuestion = currentQuestion + 1
                    else
                        checkEnd()
                    end
                end
                right = 0
                selectedQuestion = 0
            end
        end
    end
end
addEventHandler("onClientClick",root,click)

function checkEnd()
    removeEventHandler("onClientRender",root,renderTest)
    exports['cr_infobox']:addBox("warning", "A vizsgád "..(math.floor(100/(#questions)*currentCorrect)).."%-os lett!")
    if (math.floor(100/(#questions)*currentCorrect)) >= 75 then
        id = getElementData(currentPed,"driverlicense.id")
        exports['cr_infobox']:addBox("success", "Sikeresen teljesítetted az írásbeli vizsgát! Most jöhet a rutinpálya!")
        local modelID,x,y,z,dim,int,vehRot = unpack(getElementData(currentPed, "driverlicense.startPos")[1])
        triggerServerEvent("spawnPlayerWithStudentVehicle",localPlayer,localPlayer,modelID,x,y,z,dim,int,vehRot)
        messages()
        messagetimer = setTimer(messages,20000,0)
        --tesztvezetésre vigye el
    else
        exports['cr_infobox']:addBox("error", "A vizsgád sikertelen lett, minimum 75%-ot kell elérned!")
         --kedvezményes panel 120$-ért
        isHavePricable = true
        currentQuestion = 0
        currentCorrect = 0
        currentTask = nil
        render1 = {0,0,0,0}
        local x1,y1,z1 = getElementPosition(localPlayer)
        local x2,y2,z2 = getElementPosition(localPlayer)
        local x3,y3,z3 = unpack(getElementData(currentPed, "driverlicense.cameraPos"))
        local ex, ey, ez = getElementPosition(currentPed)
        setElementData(currentPed, "driverlicense.using", false)
        currentPed = nil
        if not getElementData(localPlayer, "char >> vanish") then
            setElementAlpha(localPlayer, 255)
        end
        removeEventHandler("onClientRender",root,renderPedpanel)
        exports['cr_core']:smoothMoveCamera(x3,y3,z3,ex,ey,ez+0.5, x1,y1,z1,x2,y2,z2, time)
        setTimer(
            function()
                setElementFrozen(localPlayer, false)
                toggleAllControls(true)
                local oldBone = getElementData(localPlayer, "char >> bone")
                setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
                setElementData(localPlayer, "char >> bone", oldBone)
                setCameraTarget(localPlayer, localPlayer)
                setElementData(localPlayer, "keysDenied", false)
                setElementData(localPlayer, "hudVisible", true)
                showChat(true)
            end, time, 1
        )
        return
    end
    currentQuestion = 0
    currentCorrect = 0
    currentTask = "cp"
    warning = 0
    nextCP()
    local x1,y1,z1 = getElementPosition(localPlayer)
    local x2,y2,z2 = getElementPosition(localPlayer)
    local x3,y3,z3 = unpack(getElementData(currentPed, "driverlicense.cameraPos"))
    local ex, ey, ez = getElementPosition(currentPed)
    setElementData(currentPed, "driverlicense.using", false)
    --currentPed = nil
    if not getElementData(localPlayer, "char >> vanish") then
        setElementAlpha(localPlayer, 255)
    end
    removeEventHandler("onClientRender",root,renderPedpanel)
    exports['cr_core']:smoothMoveCamera(x3,y3,z3,ex,ey,ez+0.5, x1,y1,z1,x2,y2,z2, time)
    setTimer(
        function()
            setElementFrozen(localPlayer, false)
            toggleAllControls(true)
            local oldBone = getElementData(localPlayer, "char >> bone")
            setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
            setElementData(localPlayer, "char >> bone", oldBone)
            setCameraTarget(localPlayer, localPlayer)
            setElementData(localPlayer, "keysDenied", false)
            setElementData(localPlayer, "hudVisible", true)
            showChat(true)
        end, time, 1
    )
    render1 = {0,0,0,0}
end

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        exports['cr_radar']:destroyStayBlip("Marker")
    end
)

function markerhit(player,matchingDimension)
    if player == localPlayer and matchingDimension and source == placedCP then
        nextCP()
    end
end
addEventHandler("onClientMarkerHit",root,markerhit)

function nextCP()
    --local id = getElementData(currentPed,"driverlicense.id")
    if currentTask == "cp" then
        if currentCP == nil then
            currentCP = 1
        elseif currentCP == #markers[id][1] then
            currentCP = nil
            currentTask = "cp2"
            destroyElement(placedCP)
            exports['cr_infobox']:addBox("success", "Sikeresen teljesítetted a rutin vizsgát. Jöhet a teszt vezetés! (Maximum sebesség: 70km/h)!")
            local modelID,x,y,z,dim,int,vehRot = unpack(getElementData(currentPed, "driverlicense.startPos")[2])
            triggerServerEvent("destroyCar",localPlayer,localPlayer)
            triggerServerEvent("spawnPlayerWithStudentVehicle",localPlayer,localPlayer,modelID,x,y,z,dim,int,vehRot)
            killTimer(messagetimer)
            messages()
            messagetimer = setTimer(messages,20000,0)
            nextCP()
            return
        elseif currentCP > 0 then
            currentCP = currentCP + 1
        end

        if isElement(placedCP) then 
            destroyElement(placedCP) 
            exports['cr_radar']:destroyStayBlip("Marker")
        end
        --local id = getElementData(currentPed,"driverlicense.id")

        local x, y = markers[id][1][currentCP][1],markers[id][1][currentCP][2]
		local blip = createBlip(markers[id][1][currentCP][1],markers[id][1][currentCP][2],markers[id][1][currentCP][3])
        -- exports['cr_radar']:createStayBlip("Marker",x,y,1,"munka",32,32,255,255,255)
		exports.cr_radar:createStayBlip("Marker", blip, 1, "piros", 10, 10, 255, 255, 255, true)
        placedCP = createMarker(markers[id][1][currentCP][1],markers[id][1][currentCP][2],markers[id][1][currentCP][3],"checkpoint",2.0,255,50,50,100)
    elseif currentTask == "cp2" then
        if currentCP == nil then
            currentCP = 1
        elseif currentCP == #markers[id][2] then
            if getElementHealth(getPedOccupiedVehicle(localPlayer)) >= 800 then
                exports['cr_infobox']:addBox("success", "Sikeresen leraktad a jogosítványt, aztán ügyesen az utakon!")
				triggerServerEvent("giveLicense", resourceRoot)
                killTimer(messagetimer)
                currentQuestion = 0
                curentCorrect = 0
                currentTask = nil
                exports['cr_radar']:destroyStayBlip("Marker")
                messagetimer = nil
            else
                currentQuestion = 0
                curentCorrect = 0
                currentTask = nil
                exports['cr_radar']:destroyStayBlip("Marker")
                exports['cr_infobox']:addBox("error", "Nem sikerült a vizsga, túlságosan összetörted a járművet!")
            end
            destroyElement(placedCP)
            triggerServerEvent("destroyCar",localPlayer,localPlayer)
            return
        elseif currentCP > 0 then
            currentCP = currentCP + 1
        end

        if isElement(placedCP) then 
            destroyElement(placedCP) 
            exports['cr_radar']:destroyStayBlip("Marker")
        end
        --local id = getElementData(currentPed,"driverlicense.id")

        local x, y = markers[id][2][currentCP][1],markers[id][2][currentCP][2]
        local blip = createBlip(markers[id][2][currentCP][1],markers[id][2][currentCP][2],markers[id][2][currentCP][3])
        exports.cr_radar:createStayBlip("Marker", blip, 1, "piros", 10, 10, 255, 255, 255, true)
        placedCP = createMarker(markers[id][2][currentCP][1],markers[id][2][currentCP][2],markers[id][2][currentCP][3],"checkpoint",2.0,255,50,50,100)
    end
end
    
function checkCorrent(a,current)
    if questions[current][6] == a then
        return true
    else
        return false
    end
end

function press(key,state)
    if key == "enter" and state then
        if currentTask == "pedpanel" then
            if currentText < 3 then
                if isTimer(noSpeedClickTimer) then return end
                local length = dxGetTextWidth(pedtext[currentText], 1.3, "default-bold", false)
                if render1[currentText+1] >= length + 20 then
                    noSpeedClickTimer = setTimer(function() end, math.random(250,500), 1)
                    currentText = currentText + 1 
                end
            elseif currentText == 3 then
                local price = getElementData(currentPed, "driverlicense.cost") or 200
                if isHavePricable then
                    price = price * 0.75
                end
                if exports['cr_core']:takeMoney(localPlayer, price, false) then
                    removeEventHandler("onClientRender",root,renderPedpanel)
                    addEventHandler("onClientRender",root,renderTest,true,"low-5")
                    currentTask = "test"
                    setElementData(localPlayer, "keysDenied", true)
                    currentQuestion = 1
                else
                    exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                end
                --pénzlevonás
            end
        end
    elseif key == "backspace" and state then
        if currentTask == "pedpanel" then
            local x1,y1,z1 = getElementPosition(localPlayer)
            local x2,y2,z2 = getElementPosition(localPlayer)
            local x3,y3,z3 = unpack(getElementData(currentPed, "driverlicense.cameraPos"))
            local ex, ey, ez = getElementPosition(currentPed)
            currentTask = nil
            render1 = {0,0,0,0}
            setElementData(currentPed, "driverlicense.using", false)
            currentPed = nil
            if not getElementData(localPlayer, "char >> vanish") then
                setElementAlpha(localPlayer, 255)
            end
            removeEventHandler("onClientRender",root,renderPedpanel)
            exports['cr_core']:smoothMoveCamera(x3,y3,z3,ex,ey,ez+0.5, x1,y1,z1,x2,y2,z2, time)
            setTimer(
                function()
                    setElementFrozen(localPlayer, false)
                    toggleAllControls(true)
                    local oldBone = getElementData(localPlayer, "char >> bone")
                    setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
                    setElementData(localPlayer, "char >> bone", oldBone)
                    setCameraTarget(localPlayer, localPlayer)
                    setElementData(localPlayer, "keysDenied", false)
                    setElementData(localPlayer, "hudVisible", true)
                    showChat(true)
                end, time, 1
            )
        end
    end
end
addEventHandler("onClientKey", root, press)

local cursorState = isCursorShowing()
local cursorX, cursorY = sx/2, sy/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if getElementType(source) == "ped" then
            if dName == "driverlicense.using" then
                local value = getElementData(source, dName)
                if value then
                    setPedAnimation(source, "GHANDS", "gsign3", -1, true, false, false)
                else
                    setPedAnimation(source)
                end
            end
        end
    end
)