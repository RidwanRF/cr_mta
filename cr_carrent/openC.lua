function setCameraToPed()
	local p1, p2, p3, p4, p5, p6 = getCameraMatrix()	
	smoothMoveCamera(p1,p2,p3,p4,p5,p6,c1,c2,c3,c4,c5,c6,1000)	
	setElementFrozen(localPlayer, true)
	toggleAllControls(false)
end



function createPedChat()
	font = exports['cr_fonts']:getFont("Rubik-Regular", 10)
	orange = exports['cr_core']:getServerColor("orange", true)
	
	local pedMessages = {
		"Üdvözöllek a John&Smith autóbérlőnél. Ha járművet szeretnél bérelni, nyomd meg az ".. orange .."'enter' ".. white_hex .."gombot, ha pedig folytatnád az utad tovább, nyomd meg a ".. orange .."'backspace' ".. white_hex .."billentyűt!"
	}	
	
	dxDrawRectangle(0, sy - 80, sx, 80, tocolor(0,0,0,255/100*75))
	dxDrawText(pedMessages[1], 0, sy, sx + 0, 80 + (sy - 150), white, 1, font, "center", "center", false, false, false, true, false)
end



function createVehicleToPos()
	veh = createVehicle(vehicle_list[selected_veh][1],car_pos[1], car_pos[2], car_pos[3])
	setElementFrozen(veh, true)
end

local rot = 0
function vehicleAnimationAndShow()
	font = exports['cr_fonts']:getFont("Rubik-Regular", 10)
	orange = exports['cr_core']:getServerColor("orange", true)
		if rot > 360 then
			rot = 0
		end
		rot = rot + 0.5
		setElementRotation(veh, 0 , 0, rot)	
		
		local veh_info = white_hex.."Jármű megnevezése: "..orange..vehicle_list[selected_veh][2]..white_hex.." | Bérleti díja: "..orange.."$"..vehicle_list[selected_veh][3].."/óra".. white_hex.." | Kaució: "..orange.."$"..vehicle_list[selected_veh][4]..white_hex.." | A bérléshez használd az "..orange.."'enter'"..white_hex.." billentyűt! A kilépéshez használd a ".. orange .."'backspace' ".. white_hex .."billentyűt!"
		
		dxDrawRectangle(0, sy - 80, sx, 80, tocolor(0,0,0,255/100*75))
		dxDrawText(veh_info, 0, sy, sx + 0, 80 + (sy - 150), white, 1, font, "center", "center", false, false, false, true, false)
end

function setCameraToVeh()
	local p1, p2, p3, p4, p5, p6 = getCameraMatrix()
	smoothMoveCamera(c1,c2,c3,c4,c5,c6,v1,v2,v3,v4,v5,v6,1000)
end