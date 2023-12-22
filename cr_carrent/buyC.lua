ps, ph = 465, 140
px, py = sx/2 - ps/2, sy/2 - ph/2

function createPanelForRent()
	font = exports['cr_fonts']:getFont("Rubik-Regular", 10)
	orange = exports['cr_core']:getServerColor("orange", true)
	
	dxDrawRectangle(px, py, ps, ph, tocolor(0,0,0,255/100*75))
	dxDrawRectangle(px, py, ps, 25, tocolor(0,0,0,255/100*75))
	
	dxDrawText("Jármű kibérlése", px, py, ps + px , 25 + py, white, 1, font, "center", "center", false, false, false, true, false)
	local text = "Biztos vagy benne, hogy szeretnéd kibérelni az alábbi járművet? \n A "..orange.."'backspace'"..white_hex.." billentyű segítségével visszatudod vonni a döntésed. \n A bérleti díj mellé kauciót számolunk fel! \nA kaució visszajár, ha sértetlen állapotban kerül vissza a jármű!"
	dxDrawText(text, px, py, ps + px , ph + py - 20, white, 1, font, "center", "center", false, false, false, true, false)
	
	for k,v in ipairs(rent_time) do
		dxDrawRectangle(px - 110 + (k*115) , py + 95, 110, 40, tocolor(0,0,0,255/100*50))
		count_rent_price = (v.tim/60) * vehicle_list[selected_veh][3]
		dxDrawText(v.tim.." perc ("..orange.."$"..count_rent_price..white_hex..")", px , py + 95, 110 + px - 200 + (k*235) - 25, 40 + (py + 95), white, 1, font, "center", "center", false, false, false, true, false)
	end
end