--Tömbök
local gates = {
    --{group,x,y,z}
    {1,38.40, -1533.92285,4.2},
    {1,38.33, -1534.92285,4.2},
    {1,38.26, -1535.92285,4.2},
    {1,38.19, -1536.92285,4.2},
    {1,38.12, -1537.92285,4.2},
    {1,38.05, -1538.92285,4.2},
    {1,37.98, -1539.92285,4.2},
    
    {2,58.81, -1528, 3.9},
    {2,58.96, -1527, 3.9},
    {2,59.11, -1526, 3.9},
    {2,59.26, -1525, 3.9},
    {2,59.41, -1524, 3.9},
    {2,59.56, -1523, 3.9},
    {2,59.71, -1522, 3.9},
    
    {3,-5.46, -1362.33, 9.5},
    {3,-4.86, -1363.13, 9.5},
    {3,-4.26, -1363.93, 9.5},
    {3,-3.66, -1364.73, 9.5},
    {3,-3.06, -1365.53, 9.5},
    {3,-2.46, -1366.33, 9.5},
    {3,-1.86, -1367.13, 9.5},
    
    {4,-22.23, -1341.13, 9.9},
    {4,-22.83, -1340.33, 9.9},
    {4,-23.43, -1339.53, 9.9},
    {4,-24.03, -1338.73, 9.9},
    {4,-24.63, -1337.93, 9.9},
    {4,-25.23, -1337.13, 9.9},
    {4,-25.83, -1336.33, 9.9},
    
    {5,-68.5, -891.51, 14.5},
    {5,-69.5, -891.01, 14.5},
    {5,-70.5, -890.51, 14.5},
    {5,-71.5, -890.01, 14.5},
    {5,-72.5, -889.51, 14.5},
    {5,-73.5, -889.01, 14.5},
    
    {6,-91.6, -911.90200, 16.9},
    {6,-90.6, -912.40200, 16.9},
    {6,-89.6, -912.90200, 16.9},
    {6,-88.6, -913.40200, 16.9},
    {6,-87.6, -913.90200, 16.9},
    {6,-86.6, -914.40200, 16.9},
    
    {7,-962.26, -318.85, 35.1},
    {7,-961.26, -319.05, 35.1},
    {7,-960.26, -319.25, 35.1},
    {7,-959.26, -319.45, 35.1},
    {7,-958.26, -319.65, 35.1},
    {7,-957.26, -319.85, 35.1},
    
    {8,-972.77, -340.35, 35.25},
    {8,-971.77, -340.55, 35.25},
    {8,-970.77, -340.75, 35.25},
    {8,-969.77, -340.95, 35.25},
    {8,-968.77, -341.15, 35.25},
    {8,-967.77, -341.35, 35.25},
}

local ped = {
    {281,37.8, -1531.08, 5.4,85},
    {282,59.66, -1530.78, 5.2,0},
    {280,-20.534, -1341.14, 10.981491088867,40},
    {266,-1.84, -1358.26, 10.624231338501,220},
    {265,-92.681915283203, -912.86389160156, 18.402801513672,333},
    {283,-68.021575927734, -893.24273681641, 15.717777252197,148},
    {281, -956.02325439453, -321.25155639648, 36.471641540527,170},
    {266,-973.90539550781, -340.76232910156, 36.775466918945,343},
}

local weapon = {
    24,
    25,
    29,
    31
}

local names = {
	"Jack_Gordon",
	"Aaron_White",
    "Jason_Gates",
    "Bill_Fox",
    "Manuel_Johns",
    "Craig_Johnson",
    "Walter_Mahone",
    "Diego_Specter",
}

--Üres tömbök
local placed_gates = {}
local placed_peds = {}

local gates_state = {}
local gates_nowmoving = {}
local gates_manual = {false,false,false,false,false,false,false,false}

--For ciklusok
for k,v in pairs(gates) do
    placed_gates[#placed_gates + 1] = {v[1],createObject(1214,v[2],v[3],v[4])}
    setElementFrozen(placed_gates[#placed_gates][2],true)
end

for k,v in pairs(ped) do --placed_peds[#placed_peds]
    placed_peds[#placed_peds + 1] = createPed(v[1],v[2],v[3],v[4])
    setElementRotation(placed_peds[#placed_peds],0,0,v[5])
    setElementFrozen(placed_peds[#placed_peds],true)
    setElementData(placed_peds[#placed_peds],"ped.name", names[#placed_peds])
    setElementData(placed_peds[#placed_peds],"ped.type","Határőr")
    setElementData(placed_peds[#placed_peds],"ped.id","DriverLicense")
    setElementData(placed_peds[#placed_peds],"char >> noDamage","true")
    giveWeapon(placed_peds[#placed_peds],weapon[math.random(1,4)],10000,true)
end

--Egyéb funkciók
addEvent("toggleManual",true)
addEventHandler("toggleManual",root,
	function(element)
		for k,v in pairs(placed_gates) do
	        if v[2] == element then
	            local x,y,z = getElementPosition(element)
	            local px,py,pz = getElementPosition(source)
	            local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
	            if dist > 5 then return end
	            gates_manual[v[1]] = not gates_manual[v[1]]
	            if gates_manual[v[1]] == true then
	                triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen bekapcsoltad a manuális határt! Használat(/hatarkezel)","success")
                    triggerClientEvent(source,"writeInChat",source,"me","átállítja a határ működési módját")
	            else
	            	triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen kikapcsoltad a manuális határt!","success")
                    triggerClientEvent(source,"writeInChat",source,"me","átállítja a határ működési módját")
	            end
	            break
	        end
    	end
	end
)

addEvent("refreshManual",true)
addEventHandler("refreshManual",root,
    function ()
        triggerClientEvent(source,"sendManuals",source,gates_manual)
    end
)

addEvent("checkManualEnable",true)
addEventHandler("checkManualEnable",root,
	function(key)
		if gates_manual[key] then
			triggerClientEvent(source,"toggleHatar",source,1)
		end
	end
)

--Mozgási funkció
function moveGate(key,value,two,pl)
	local key = tonumber(key)
	if gates_nowmoving[key] then return end
    if value then -- lefele
    	if gates_state[key] then return end
        if gates_manual[key] and two then return end
    	gates_nowmoving[key] = true
    	gates_state[key] = true
    	for k,v in pairs(placed_gates) do
            if key == v[1] then
                local x,y,z = getElementPosition(v[2])
                moveObject(v[2],1000,x,y,z-1.4,0,0,0)
            end
        end
        for k,v in pairs(placed_gates) do
            if v[1] == key then
                triggerClientEvent(root,"playSound",source,v[2])
                break
            end
        end
        if two then
        	triggerClientEvent(source,"money",source,source)
        	triggerClientEvent(source,"writeInChat",source,"outputChatBox","Sikeresen kifizetted a határdíjat!","success")
        	triggerClientEvent(source,"writeInChat",source,"me","kifizeti a határdíjat")
            local syntax = exports['cr_core']:getServerSyntax("Határ", "info")
            local color = exports['cr_core']:getServerColor(nil, true)
            local white = "#ffffff"
            local r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = source.vehicle:getColor(true)
            local hex1 = RGBToHex(r1,g1,b1)
            local hex2 = RGBToHex(r2,g2,b2)
            local hex3 = RGBToHex(r3,g3,b3)
            local hex4 = RGBToHex(r4,g4,b4)
            local wanted = false
            local reason = ""
        	triggerClientEvent(root,"writeInChat",source,"faction",{syntax .. "Egy jármű átlépte a határt ("..color..getZoneName(source.vehicle.position)..white..") | "..white.."Típus:"..color.." "..exports['cr_vehicle']:getVehicleName(source.vehicle.model), syntax .. "Rendszám: "..color..source.vehicle.plateText..white.." | "..hex1.."Szín1"..white.." - "..hex2.."Szín2"..white.." - "..hex3.."Szín3"..white.." - "..hex4.."Szín4", syntax .. "Körözés: ".. (wanted and ("#ff3333Van#ffffff, Indok: "..color..reason) or "#33ff33Nincs")})
        	setTimer(
        		function(key,pl)
        			gates_nowmoving[key] = false
        			moveGate(key,false,true,pl)
        		end
        	,3000,1,key,source,true)
        else
            triggerClientEvent(source,"writeInChat",source,"me","megnyom egy gombot a határkezelőn")
        	setTimer(
        		function(key)
        			gates_nowmoving[key] = false
        		end
        	,1200,1,key)
        end
    elseif not value then -- felfele
    	if not gates_state[key] then return end
    	gates_nowmoving[key] = true
    	gates_state[key] = false
    	for k,v in pairs(placed_gates) do
            if key == v[1] then
                local x,y,z = getElementPosition(v[2])
                moveObject(v[2],1000,x,y,z+1.4,0,0,0)
            end
        end
        for k,v in pairs(placed_gates) do
            if v[1] == key then
                triggerClientEvent(root,"playSound",pl,v[2])
                break
            end
        end
        if not two then
            triggerClientEvent(source,"writeInChat",source,"me","megnyom egy gombot a határkezelőn")
        end
        setTimer(
        	function(key)
        		gates_nowmoving[key] = false
        	end
        ,1200,1,key)
    end
end
addEvent("moveSync",true)
addEventHandler("moveSync",root,moveGate)
    
function RGBToHex(red, green, blue, alpha)

	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end