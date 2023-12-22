
radarBlips = --- name : name,blip element,type,image,r,g,b
{
	
	["cityhall"]={"Városháza",createBlip (1481,-1790,0,0,2,255,0,0,255,0,0),0,"city_hall",32,32,255,255,255},
	["carshop"]={"Autószalon",createBlip (1747,-1106,0,0,2,255,0,0,255,0,0),0,"car_shop",24,24,255, 255, 255},
	["plaza"]={"Pláza",createBlip (1090,-1619,0,0,2,255,0,0,255,0,0),0,"shopping_mall",24,24,255,255,255},
	["oil1"]={"Benzinkút",createBlip (1923,-1777,0,0,2,255,0,0,255,0,0),0,"gas_station",24,24,255, 255, 255},
	["oil2"]={"Benzinkút",createBlip (1004,-925,0,0,2,255,0,0,255,0,0),0,"gas_station",24,24,255, 255, 255},
	["oil3"]={"Benzinkút",createBlip (-1681,420,0,0,2,255,0,0,255,0,0),0,"gas_station",24,24,255, 255, 255},
	["carshop2"]={"Autószalon",createBlip (-1955,286,0,0,2,255,0,0,255,0,0),0,"car_shop",24,24,255, 255, 255},
	["fly1"]={"Repülőtér",createBlip (1627,-2287,0,0,2,255,0,0,255,0,0),0,"airport",24,24,255,255,255},
	["fly2"]={"Repülőtér",createBlip (-1487,-2287,0,0,2,255,0,0,255,0,0),0,"airport",24,24,255,255,255},
	["binco"]={"Ruhabolt",createBlip (1125,-1588.12,0,0,2,255,0,0,255,0,0),0,"clothes_shop",24,24,255,255,255},
	["hospital"]={"Kórház",createBlip (1224,-1767,0,0,2,255,0,0,255,0,0),0,"hospital",24,24,255,255,255},
	["border1"]={"Határ",createBlip (48,-1531,0,0,2,255,0,0,255,0,0),0,"border_crossing",32,32,255,255,255},
	["border2"]={"Határ",createBlip (-10,-1350,0,0,2,255,0,0,255,0,0),0,"border_crossing",32,32,255,255,255},
	["pd"]={"Rendőrség",createBlip (1564,-1675,0,0,2,255,0,0,255,0,0),0,"police_hq",24,24,255, 255, 255},
	["service"]={"Szerelőtelep",createBlip (2786.3154296875, -1766.3331298828,0,0,2,255,0,0,255,0,0),0,"car_repair",24,24,255,255,255},
	["racing"]={"Versenypálya",createBlip (295.43103027344, 797.59057617188, 0,0,2,255,0,0,255,0,0),0,"racingtrack",24,24,255,255,255},
	["destroyer"]={"Autóbontó",createBlip (-2100.72265625, 208.4828338623, 0,0,2,255,0,0,255,0,0),0,"car_destroyer",24,24,255,255,255},


}

radarOwnBlips = {}


local free_id = 1
function createOwnBlip(type,word_x,word_y)
	local name = ""
	if type == "mark_1" or type == "mark_2" or type == "mark_3" or type == "mark_4" then name = "Jelölés"
	elseif type == "garage" then name = "Garázs"
	elseif type == "house" then name = "Ház"
	elseif type == "vehicle" then name = "Jármű" end
	if not radarOwnBlips[name.." "..tostring(free_id)] then
		local element = createBlip (word_x,word_y,0,0,2,255,0,0,255,0,0)
		radarOwnBlips[name.." "..tostring(free_id)] = {name.." "..tostring(free_id),word_x,word_y,0,type,12,12,255,255,255}
		createStayBlip(name.." "..tostring(free_id),element,0,type,12,12,255,255,255)
		free_id = 1 
	else
		free_id = free_id+1
		createOwnBlip(type,word_x,word_y)
	end
end

function deleteOwnBlip(name)
	if radarOwnBlips[name] then
		destroyStayBlip(name)
		radarOwnBlips[name] = nil
	end
end

function jsonLoad()
	local json = fileOpen(":cr_radar/blips.json")
	local json_string = ""
	while not fileIsEOF(json) do
		json_string = json_string..""..fileRead(json,500)
	end
	fileClose(json)
	return fromJSON(json_string)
end

function jsonSave()
	if fileExists(":cr_radar/blips.json") then fileDelete(":cr_radar/blips.json") end
	local json = fileCreate(":cr_radar/blips.json")
		local json_string = toJSON(radarOwnBlips)
		fileWrite(json,json_string)
		fileClose(json)
end

addEventHandler( "onClientResourceStart",resourceRoot,function()
	if fileExists(":cr_radar/blips.json") then

		local blip_table = nil
		local json = fileOpen(":cr_radar/blips.json")
		local json_string = ""
		while not fileIsEOF(json) do
			json_string = json_string..""..fileRead(json,500)
		end
		fileClose(json)
		blip_table = fromJSON( json_string )
		for k, values in pairs(blip_table) do
			radarOwnBlips[values[1]] = {values[1],values[2],values[3],values[4],values[5],values[6],values[7],values[8],values[9],values[10]}
			createStayBlip(values[1],createBlip (values[2],values[3],0,0,2,255,0,0,255,0,0),values[4],values[5],values[6],values[7],values[8],values[9],values[10])
		end
	end
end)

addEventHandler( "onClientResourceStop",resourceRoot,function()
	 jsonSave()
end)



function createStayBlip(name,element,visible,image,imgw,imgh,imgr,imgg,imgb,no3d)
    radarBlips[name] = {name,element,visible,image,imgw,imgh,imgr,imgg,imgb,no3d}
end


function destroyStayBlip(name)
	radarBlips[name] = nil
end
