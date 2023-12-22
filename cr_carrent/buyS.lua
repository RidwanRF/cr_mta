veh_rent_timer = {}
create_veh = {}
rent_id = 0
minutes = {}
notify = {}

random_rent_pos = {
	{1560.2202148438, -2318.7575683594, 13.545438766479, 0, 0, 90},
	{1559.9974365234, -2322.0893554688, 13.546875, 0, 0, 90},
	{1560.2559814453, -2325.4924316406, 13.546875, 0, 0, 90},
	{1560.2680664063, -2328.5131835938, 13.546875, 0, 0, 90},
	{1560.2813720703, -2331.6647949219, 13.546875, 0, 0, 90},
	{1560.2956542969, -2335.0871582031, 13.546875, 0, 0, 90},
}

-- sqlbe menteni kell, hogy van -e bérlése + betöltése ennek!

function randomPlateNumbers()
	local temp = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	return temp[math.random(1, #temp)]..temp[math.random(1, #temp)]..temp[math.random(1, #temp)]
end

function spawnRentedVehicle(player, vehid, rent_time, bail)
	local random_pos = math.random(1,#random_rent_pos)
	local rented_veh_pos = {random_rent_pos[random_pos][1], random_rent_pos[random_pos][2], random_rent_pos[random_pos][3], 0, 0, 90}
	local accountID = getElementData(player, "acc >> id")
	local rot = {rented_veh_pos[4], rented_veh_pos[5], rented_veh_pos[6]}
	
	rent_id = rent_id + 1
	-- create_veh[rent_id] = exports['cr_vehicle']:createTemporaryVehicle(tonumber(vehid), player, rented_veh_pos[1], rented_veh_pos[2], rented_veh_pos[3], 0, 0, rot, false, false, false, 1000)
	-- local plate = "RENT-"..randomString()
	create_veh[rent_id] = exports.cr_temporaryvehicle:createTemporaryVehicle(player, tonumber(vehid), rented_veh_pos[1], rented_veh_pos[2], rented_veh_pos[3], rot[1], rot[2], rot[3], 255, 255, "RENT-"..randomPlateNumbers(), true)
	setElementData(player,"carrent >> on_rent", true)
	
	-- start Timer
	if not minutes[rent_id] then
		minutes[rent_id] = 0
	end
	veh_rent_timer[rent_id] = setTimer(function(r_id)
		minutes[r_id] = minutes[r_id] + 1

		if tonumber(minutes[r_id]) >= tonumber(rent_time - 10) and not notify[create_veh[rent_id]] or nil then
			notify[create_veh[rent_id]] = true
			exports['cr_infobox']:addBox(player, "warning", "Figyelem. 5 perc múlva lejár a bérelt jármű bérleti ideje!")
		end
		
		if tonumber(minutes[r_id]) >= tonumber(rent_time) then
			killTimer(veh_rent_timer[r_id])
			setElementData(create_veh[r_id], "veh >> engine", false)
			notify[create_veh[rent_id]] = false
			exports['cr_infobox']:addBox(player, "warning", "A bérleti időd lejárt a járműre. A jármű 5 percen belül törlésre kerül.")
			
			setTimer(function(r_id)
				if create_veh[r_id] then
					if getElementHealth(create_veh[r_id]) >= 1000/100*80 then
						exports['cr_infobox']:addBox(player, "error", "A bérelt járműved törlésre került! Mivel sérülés nélkül adtad vissza, így a kaució visszajár.")
						local oldMoney = getElementData(player, "char >> money") or 0
						setElementData(player, "char >> money", oldMoney + bail)
					else
						exports['cr_infobox']:addBox(player, "error", "A bérelt járműved törlésre került! Sajnos a jármű sérült, így a kauciót elbuktad.")
					end
					setElementData(player,"carrent >> on_rent", false)
					-- exports['cr_vehicle']:deleteVehicle(getElementData(create_veh[r_id], "veh >> id"))		
					exports.cr_temporaryvehicle:deleteTemporaryVehicle(player)
				end				
			end, 1000*60*5,1, rent_id)

		end
	end, 1000*60, 0, rent_id)
end
addEvent("carrent >> giveRentCar", true)
addEventHandler("carrent >> giveRentCar", resourceRoot, spawnRentedVehicle)

addEventHandler ("onResourceStop", resourceRoot, 
    function (resource)
		if getResourceName(resource) == "cr_carrent" then
			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v,"carrent >> on_rent") then
					setElementData(v,"carrent >> on_rent", false)
					exports.cr_temporaryvehicle:deleteTemporaryVehicle(v)
				end
			end
		end 
   end 
)