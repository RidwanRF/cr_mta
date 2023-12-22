x, y, z = 1559.9270019531, -2302.3791503906, 13.559377670288
c1, c2, c3, c4, c5, c6 =  1556.2392578125, -2302.6806640625, 14.623900413513, 1557.2102050781, -2302.6303710938, 14.390191078186, 0, 70
v1, v2, v3, v4, v5, v6 = 1552.0268554688, -2307.0544433594, 17.576999664307, 1552.8103027344, -2307.5212402344, 17.166814804077, 0, 70

local renterPed = createPed(100,x, y, z)
setElementRotation(renterPed, 0, 0, 90)
setElementFrozen(renterPed, true)
setElementData(renterPed, "ped >> carRent", true)
setElementData(renterPed, "ped.name", "John")
setElementData(renterPed, "ped.type", "Autóbérlő")

local show = false 
selected_veh = 1
can_press = true
show_rent_panel = false

white = tocolor(255, 255, 255, 220)
white_hex = "#FFFFFF"
sx, sy = guiGetScreenSize()
local submenu_show = false

function disablePedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", renterPed, disablePedDamage)

function addRentPedClick(button, state, x, y, wx, wy, wz, clickedElement)
	if clickedElement and getElementType(clickedElement) == "ped" and getElementData(renterPed, "ped >> carRent") and not show then
		if button=="left" and state=="down" then
			local lx, ly, lz = getElementPosition(localPlayer)
			local px, py, pz = getElementPosition(renterPed)
			if getDistanceBetweenPoints3D(lx, ly, lz, px, py, pz) <= 3 then
			
				setCameraToPed()
				setElementData(localPlayer, "hudVisible", false)
				show = true
				addEventHandler("onClientRender",root, createPedChat, false, "low-1")
				
				can_press = false
				setTimer(function()
					can_press = true
				end, 1100, 1)
			end		
		end
	end
	if button=="left" and state=="down" and show and show_rent_panel then
		if exports['cr_network']:getNetworkStatus() then return end
		if not getElementData(localPlayer,"carrent >> on_rent") or nil then
			for k,v in ipairs(rent_time) do
				if isInBox(px - 110 + (k*115) , py + 95, 110, 40, x, y) then
					local count_rent_price = (v.tim/60) * vehicle_list[selected_veh][3]
					count_price = count_rent_price + vehicle_list[selected_veh][4]
					if exports['cr_core']:takeMoney(localPlayer, count_price, false) then
						exports['cr_infobox']:addBox("success", "Sikeresen kibéreltél egy járművet!")
						triggerServerEvent("carrent >> giveRentCar", resourceRoot, localPlayer, vehicle_list[selected_veh][1], v.tim, vehicle_list[selected_veh][4])
						exitRentPanel()
					else
						exports['cr_infobox']:addBox("error", "Sajnálom, de nincs elég pénzed a bérléshez!")
					end  			 			
				end
			end
		else
			exports['cr_infobox']:addBox("error", "Ameddig van járműved bérelve, nem tudsz újat bérelni!")
		end
	end		
end
addEventHandler ("onClientClick", root, addRentPedClick)

function exitRentPanel()
		setCameraTarget(localPlayer)		
		setElementFrozen(localPlayer, false)
		setElementData(localPlayer, "hudVisible", true)
		toggleAllControls(true)		
		show = false
		removeEventHandler("onClientRender", root, createPedChat)
		removeEventHandler("onClientRender", root, vehicleAnimationAndShow)
		removeEventHandler("onClientRender", root, createPanelForRent)
		exports.cr_blur:removeBlur("cr_carrent")
		rot = 0
		selected_veh = 1
		submenu_show = false
		show_rent_panel = false	
		if veh then
			destroyElement(veh)
			veh = nil
		end
end

function pressedKey(button, press)
	if press and button == "backspace" and show and can_press then
	
		exitRentPanel()
		
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)		
		
	end	
	
	if press and button == "arrow_r" and show and submenu_show and not show_rent_panel then
		selected_veh = selected_veh + 1
		if selected_veh >= #vehicle_list then
			selected_veh = #vehicle_list
		end
		setElementModel(veh,vehicle_list[selected_veh][1])		
	end	
	
	if press and button == "arrow_l" and show and submenu_show and not show_rent_panel then
		selected_veh = selected_veh - 1
		if selected_veh < 1 then
			selected_veh = 1
		end	
		setElementModel(veh,vehicle_list[selected_veh][1])
	end
	
	if press and button == "enter" and show and not submenu_show and can_press then
	
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)	
		
		setCameraToVeh()
		createVehicleToPos()
		submenu_show = true
		
		exports.cr_blur:removeBlur("cr_carrent")
		removeEventHandler("onClientRender", root, createPedChat)
		addEventHandler("onClientRender",root, vehicleAnimationAndShow, false, "low-1")

	end
	
	if press and button == "enter" and show and submenu_show and can_press then
	
		can_press = false
		setTimer(function()
			can_press = true
		end, 1100, 1)
		
		show_rent_panel = true
		
		addEventHandler("onClientRender",root, createPanelForRent, false, "low-1")
		exports.cr_blur:createBlur("cr_carrent", 15)
		
	end
end
addEventHandler("onClientKey", root, pressedKey)