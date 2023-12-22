sx, sy = guiGetScreenSize()
f = "files/"
loader_alpha = 0
multipler = 4
r = 0

local fonts = {};
show_loader = false

function createLoaderAnimation()
	if show_loader then
		fonts.normal = exports['cr_fonts']:getFont("Rubik-Regular", 12)
		if loader_alpha + multipler <= 204 then
			loader_alpha = loader_alpha + multipler
		elseif loader_alpha >= 204 then
			loader_alpha = 204
		end	
		r = r + 1.5 

		
		dxDrawRectangle(0,0,sx,sy, tocolor(0,0,0,loader_alpha))
		if loader_alpha == 204 then
			dxDrawImage(sx / 2 - 64 / 2, sy / 2 - 64 / 2, 64,64,f.."loader.png", r, 0, 0, tocolor(255,255,255,255))
			
			dxDrawText("Bejelentkezés folyamatban...", 0, 0, sx, 0 + sy + 90, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)		
			
		end
	end
end


function showBankLoader(start)
	if start then
		show_loader = true
		addEventHandler("onClientRender",root, createLoaderAnimation, false, "low-1")
		playSound("files/songs/login.mp3")	
	elseif not start then
		removeEventHandler("onClientRender",root, createLoaderAnimation)
		show_loader = false
		loader_alpha = 0
		multipler = 4
		r = 0		
	end
end