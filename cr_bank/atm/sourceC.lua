atm_state = false
local check_range 

local bank_card_id = 97

local sw, sh = guiGetScreenSize()
local pw, ph = 300, 193
local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2
local fonts = {}

local sub_max_column = 3
local sub_keyPadding = 3
local sub_column = 0
local sub_row = 0
local buttons = {"1","2","3","4","5","6","7","8","9","#","0","*"}

local entered_money_amount = {}

local welcome_text = {
	[1] = "Üdvözöllek az ATM felületen!",
	[2] = "Kérlek válassz az alábbi menüpontok közül, \nhogy mit szeretnél tenni.";
};

local seleted_atm_page = 1

local atm_menus = {
	[1] = {"Pénz felvétel","money-out", 51,133,255},
	[2] = {"Pénz befizetés","money-in", 51,133,255},
	[3] = {"Bezárás","close-browser", 255,51,51},
};
local padding = 3;
local button = {300-6,30};

local lastTick = -1000
local tickTime = 3

show_atm_panel = false

function clickInATM(button_name, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if exports['cr_network']:getNetworkStatus() then return end
	if isPedInVehicle(localPlayer) then return end
	
			-- -- /* Check Range */
			-- check_range = setTimer (function()
				-- local p_pos_x, p_pos_y, p_pos_z = getElementPosition(localPlayer)
				-- local o_pos_x, o_pos_y, o_pos_z = getElementPosition(clickedElement)
				-- if getDistanceBetweenPoints3D(p_pos_x, p_pos_y, p_pos_z, o_pos_x, o_pos_y, o_pos_z) > 2 then
					-- exitATMPanel();
					-- exitKeyPadPanel();
				-- end
			-- end, 100, 0)	
			
	if button_name=="left" and state=="down" and show_atm_panel and seleted_atm_page == 1 then		
		for i=1,3 do		
			if isInSlot(x+padding,y+60+(i * (button[2] + padding)),button[1],button[2]) then
				if tonumber(i) == 1 then -- Pénz felvétel
					seleted_atm_page = i+1
					if not entered_money_amount or #entered_money_amount > 0 then entered_money_amount = {} end
                    return
				elseif tonumber(i) == 2 then -- Pénz befizetés
					seleted_atm_page = i+1
                    return
				elseif tonumber(i) == 3 then -- Bezárás
					seleted_atm_page = i+1
					exitATMPanel()
					exitKeyPadPanel()
                    return
				end
			end
		end
	end
	
	--[[***********************************************************************************************************]]
	
	if button_name=="left" and state=="down" and seleted_atm_page == 2 and show_atm_panel then -- Pénz felvétel		
		local sub_column = 0
		local sub_row = 0
		local padding = 3	
		local pw, ph = 300, 312
		local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2
			
		for i=1,12 do 
			if (sub_column > sub_max_column - 1) then
				sub_column = 0
				sub_row = sub_row + 1
			end	
			local x = x + pw/2 - size["keypad-size"]/2
			local kx = x + (sub_column * (size["keypad-size"] + padding)) + padding - (size["keypad-size"] + padding)
			local ky = y + (sub_row * (size["keypad-size"] + padding)) + padding + 88 + padding
			if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then -- insert number				
				if buttons[i] ~= "" then
					if buttons[i] == "#" or buttons[i] == "*" then
						return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter a jelszóban!")
					end						
					if #entered_money_amount + 1 > 23 then return end					
					table.insert(entered_money_amount, buttons[i])
					playSound("files/songs/keypad.wav")
					return
				end					
			end
			sub_column = sub_column + 1		
		end				
			
		if isInSlot(x+padding+pw-25,y + 55 + padding + 7,16,16) then -- törlés
			if table.concat(entered_money_amount) ~= "" then
				table.remove(entered_money_amount, #entered_money_amount)
				playSound("files/songs/keypad.wav")
			end	
		elseif isInSlot(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2]) and #entered_money_amount > 0 then -- Pénz felvétel
			local now = getTickCount()
			if now <= lastTick + (tickTime * 1000) then
				exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
				return
			end
			lastTick = getTickCount()
				
			if tonumber(table.concat(entered_money_amount)) > bankAccountData[5] then
				return exports["cr_infobox"]:addBox("error", "Nem rendelkezel elég pénzzel a tranzakció végrehajtásához!")
			elseif entered_money_amount[1] == 0 then
				return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg.")		
			else	
				local money = tonumber(table.concat(entered_money_amount))
				triggerServerEvent("atm >> setPlayerMoney", localPlayer, localPlayer,money,"money-out")
				triggerServerEvent("bank >> createPlayerLog", localPlayer, localPlayer, 3, getElementData(localPlayer,"acc >> id"), getElementData(localPlayer,"char >> name"), "", money)
				entered_money_amount = {}
				playSound("files/songs/transfer.mp3")
			end
		elseif isInSlot(x+padding,y + ph - (button[2]) - padding,button[1],button[2]) then -- Visszalépés
			seleted_atm_page = 1
			entered_money_amount = {}
		end	
		
	--[[***********************************************************************************************************]]	
	
	elseif button_name=="left" and state=="down" and seleted_atm_page == 3 and show_atm_panel then	-- Pénz befizetés	
		local sub_column = 0
		local sub_row = 0
		local padding = 3	
		local pw, ph = 300, 312
		local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2
			
		for i=1,12 do 
			if (sub_column > sub_max_column - 1) then
				sub_column = 0
				sub_row = sub_row + 1
			end	
			local x = x + pw/2 - size["keypad-size"]/2
			local kx = x + (sub_column * (size["keypad-size"] + padding)) + padding - (size["keypad-size"] + padding)
			local ky = y + (sub_row * (size["keypad-size"] + padding)) + padding + 88 + padding
			if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then -- insert number				
				if buttons[i] ~= "" then
					if buttons[i] == "#" or buttons[i] == "*" then
						return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter a jelszóban!")
					end						
					if #entered_money_amount + 1 > 23 then return end					
					table.insert(entered_money_amount, buttons[i])
					playSound("files/songs/keypad.wav")
					return
				end					
			end
			sub_column = sub_column + 1		
		end				
			
		if isInSlot(x+padding+pw-25,y + 55 + padding + 7,16,16) then -- törlés
			if table.concat(entered_money_amount) ~= "" then
				table.remove(entered_money_amount, #entered_money_amount)
				playSound("files/songs/keypad.wav")
			end	
		elseif isInSlot(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2]) and #entered_money_amount > 0 then -- Pénz befizetés
			local now = getTickCount()
			if now <= lastTick + (tickTime * 1000) then
				exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
				return
			end
			lastTick = getTickCount()
			
			local money = getElementData(localPlayer,"char >> money")	
			if tonumber(table.concat(entered_money_amount)) > tonumber(money) then
				return exports["cr_infobox"]:addBox("error", "Nem rendelkezel elég pénzzel a tranzakció végrehajtásához!")
			elseif entered_money_amount[1] == 0 then
				return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg.")		
			else	
				local money = tonumber(table.concat(entered_money_amount))
				triggerServerEvent("atm >> setPlayerMoney", localPlayer, localPlayer,money,"money-in")
				triggerServerEvent("bank >> createPlayerLog", localPlayer, localPlayer, 5, getElementData(localPlayer,"acc >> id"), getElementData(localPlayer,"char >> name"), "", money)
				entered_money_amount = {}
				playSound("files/songs/transfer.mp3")
			end
		elseif isInSlot(x+padding,y + ph - (button[2]) - padding,button[1],button[2]) then -- Visszalépés
			seleted_atm_page = 1
			entered_money_amount = {}
		end
	end	
end
addEventHandler("onClientClick", root, clickInATM)

function openATM(details, worldE)
	if exports['cr_network']:getNetworkStatus() then return end
	if isPedInVehicle(localPlayer) then return end
    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(details)	
	if tonumber(itemid) and not atm_state then
		local p_pos_x, p_pos_y, p_pos_z = getElementPosition(localPlayer)
		local o_pos_x, o_pos_y, o_pos_z = getElementPosition(worldE)
		if getDistanceBetweenPoints3D(p_pos_x, p_pos_y, p_pos_z, o_pos_x, o_pos_y, o_pos_z) < 2 then	
			if tonumber(itemid) == tonumber(bank_card_id) then
				--triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer)
				if value == bankAccountData[3] then		
					createKeyPad("enter_pin_bank_to_atm")
					exports.cr_blur:createBlur("cr_bank_blur", 15)
					exports["cr_infobox"]:addBox("info", "Üdvözöllek az ATM kezelő felületén. Kérlek add meg a bankkártyádhoz tartozó maximum 6 számjegyű pincodet!")
				else
					exports["cr_infobox"]:addBox("error", "Az alábbi kártyához nem található számla, így nem is tudod kezelni azt!")
				end
			elseif tonumber(itemid) == tonumber(bank_card_id) then
					createKeyPad("enter_pin_bank_to_atm")
					triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer)
					exports.cr_blur:createBlur("cr_bank_blur", 15)
					exports["cr_infobox"]:addBox("info", "[DEBUG->CÉGES SZÁMLA] Üdvözöllek az ATM kezelő felületén. Kérlek add meg a bankkártyádhoz tartozó maximum 6 számjegyű pincodet!")	
			end
		end
	end
end

function drawATMselector()
	fonts.small = exports['cr_fonts']:getFont("Rubik-Regular", 10)
	fonts.normal = exports['cr_fonts']:getFont("Rubik-Regular", 10)	
	fonts.title = exports['cr_fonts']:getFont("Rubik-Black", 10)	
		
	if seleted_atm_page == 1 then
		drawFirstPanel()
	elseif seleted_atm_page == 2 then
		drawMoneyOut()
	elseif seleted_atm_page == 3 then
		drawMoneyIn()
	end	
	
end

function drawFirstPanel()
	dxDrawRoundedRectangle(x,y,pw,ph,tocolor(0,0,0,255/100*75))
	dxDrawRoundedRectangle(x,y,pw,35,tocolor(0,0,0,255/100*50))
	dxDrawText("ATM",x,y,pw+x,35+y, colors.white, 1, fonts.title, "center", "center", false, false, false, true, false)
	dxDrawImage(x + pw/2 - 36,y + 8,16,16,f.."numpad.png",0,0,0,tocolor(255,255,255,255))
	
	dxDrawText(welcome_text[1],x,y+35,pw+x,25+y+35, colors.white, 1, fonts.title, "center", "center", false, false, false, true, false)
	dxDrawText(welcome_text[2],x,y+35+25,pw+x,25+y+35+25, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)

	for i=1,3 do
		if isInSlot(x+padding,y+60+(i * (button[2] + padding)),button[1],button[2]) then
			dxDrawRoundedRectangle(x+padding,y+60+(i * (button[2] + padding)),button[1],button[2],tocolor(atm_menus[i][3],atm_menus[i][4],atm_menus[i][5],255/100*50))
			dxDrawText(atm_menus[i][1],x+padding,y+60+(i * (button[2] + padding)),button[1]+x+padding,button[2]+y+60+(i * (button[2] + padding)), colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)	
			dxDrawImage(x+padding+button[1]/2 - 65,y+60+(i * (button[2] + padding)) + 8,16,16,f..atm_menus[i][2]..".png",0,0,0,tocolor(0,0,0,255))
		else
			dxDrawRoundedRectangle(x+padding,y+60+(i * (button[2] + padding)),button[1],button[2],tocolor(0,0,0,255/100*50))
			dxDrawText(atm_menus[i][1],x+padding,y+60+(i * (button[2] + padding)),button[1]+x+padding,button[2]+y+60+(i * (button[2] + padding)), colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
			dxDrawImage(x+padding+button[1]/2 - 65,y+60+(i * (button[2] + padding)) + 8,16,16,f..atm_menus[i][2]..".png")
		end
	end
end

function drawMoneyOut()
	fonts.num = exports['cr_fonts']:getFont("Rubik-Regular", 12)	
	local sub_column = 0
	local sub_row = 0
	local padding = 3	
	local pw, ph = 300, 312
	local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2
	
	dxDrawRoundedRectangle(x,y,pw,ph,tocolor(0,0,0,255/100*75))
	dxDrawRoundedRectangle(x,y,pw,35,tocolor(0,0,0,255/100*50))
	dxDrawText("ATM",x,y,pw+x,35+y, colors.white, 1, fonts.title, "center", "center", false, false, false, true, false)
	dxDrawImage(x + pw/2 - 36,y + 8,16,16,f.."numpad.png",0,0,0,tocolor(255,255,255,255))
	
	
	dxDrawText("Kérlek írd be a felvenni kívánt összeget!",x,y + 30,pw + x,35 + y + 30, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	dxDrawRoundedRectangle(x+padding,y+55+padding,button[1],button[2],tocolor(52,52,52,255/100*50))
	dxDrawImage(x+padding+pw-25,y + 55 + padding + 7,16,16,f.."delete.png")

	if #entered_money_amount > 0 then
		local entered_money_amount = table.concat(entered_money_amount)
		dxDrawText(entered_money_amount,x+padding,y+55+padding,button[1]+x+padding,button[2]+y+55+padding, colors.white, 1, fonts.num, "center", "center", false, false, false, true, false)
	end	
	
	if isInSlot(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2]) then
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2],tocolor(51, 133, 255,255/100*50))
		dxDrawText("Pénz felvétele",x+padding,y + ph - (button[2]*2) - padding*2,button[1] + x+padding,button[2] + y + ph - (button[2]*2) - padding*2, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 60,y + ph - (button[2]*2) - padding*2 + 7,16,16,f.."atm-money-out.png",0,0,0,tocolor(0,0,0,255))
	else
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2],tocolor(0,0,0,255/100*25))
		dxDrawText("Pénz felvétele",x+padding,y + ph - (button[2]*2) - padding*2,button[1] + x+padding,button[2] + y +ph - (button[2]*2) - padding*2, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 60,y + ph - (button[2]*2) - padding*2 + 7,16,16,f.."atm-money-out.png")
	end
	
	if isInSlot(x+padding,y + ph - (button[2]) - padding,button[1],button[2]) then
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]) - padding,button[1],button[2],tocolor(255,51,51,255/100*50))
		dxDrawText("Visszalépés",x+padding,y + ph - (button[2]) - padding,button[1] + x+padding,button[2] + y + ph - (button[2]) - padding, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 60,y + ph - (button[2]) - padding + 7,16,16,f.."close-browser.png",0,0,0,tocolor(0,0,0,255))
	else
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]) - padding,button[1],button[2],tocolor(0,0,0,255/100*25))
		dxDrawText("Visszalépés",x+padding,y + ph - (button[2]) - padding,button[1] + x+padding,button[2] + y +ph - (button[2]) - padding, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 60,y + ph - (button[2]) - padding + 7,16,16,f.."close-browser.png")
	end
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = x + pw/2 - size["keypad-size"]/2
		local kx = x + (sub_column * (size["keypad-size"] + padding)) + padding - (size["keypad-size"] + padding)
		local ky = y + (sub_row * (size["keypad-size"] + padding)) + padding + 88 + padding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.num, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*50))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.num, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
end

function drawMoneyIn()
	fonts.num = exports['cr_fonts']:getFont("Rubik-Regular", 12)	
	local sub_column = 0
	local sub_row = 0
	local padding = 3	
	local pw, ph = 300, 312
	local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2
	
	dxDrawRoundedRectangle(x,y,pw,ph,tocolor(0,0,0,255/100*75))
	dxDrawRoundedRectangle(x,y,pw,35,tocolor(0,0,0,255/100*50))
	dxDrawText("ATM",x,y,pw+x,35+y, colors.white, 1, fonts.title, "center", "center", false, false, false, true, false)
	dxDrawImage(x + pw/2 - 36,y + 8,16,16,f.."numpad.png",0,0,0,tocolor(255,255,255,255))
	
	
	dxDrawText("Kérlek írd be a befizetni kívánt összeget!",x,y + 30,pw + x,35 + y + 30, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	dxDrawRoundedRectangle(x+padding,y+55+padding,button[1],button[2],tocolor(52,52,52,255/100*50))
	dxDrawImage(x+padding+pw-25,y + 55 + padding + 7,16,16,f.."delete.png")

	if #entered_money_amount > 0 then
		local entered_money_amount = table.concat(entered_money_amount)
		dxDrawText(entered_money_amount,x+padding,y+55+padding,button[1]+x+padding,button[2]+y+55+padding, colors.white, 1, fonts.num, "center", "center", false, false, false, true, false)
	end	
	
	if isInSlot(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2]) then
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2],tocolor(51, 133, 255,255/100*50))
		dxDrawText("Pénz befizetése",x+padding,y + ph - (button[2]*2) - padding*2,button[1] + x+padding,button[2] + y + ph - (button[2]*2) - padding*2, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 65,y + ph - (button[2]*2) - padding*2 + 7,16,16,f.."atm-money-out.png",0,0,0,tocolor(0,0,0,255))
	else
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]*2) - padding*2,button[1],button[2],tocolor(0,0,0,255/100*25))
		dxDrawText("Pénz befizetése",x+padding,y + ph - (button[2]*2) - padding*2,button[1] + x+padding,button[2] + y +ph - (button[2]*2) - padding*2, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 65,y + ph - (button[2]*2) - padding*2 + 7,16,16,f.."atm-money-out.png")
	end
	
	if isInSlot(x+padding,y + ph - (button[2]) - padding,button[1],button[2]) then
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]) - padding,button[1],button[2],tocolor(255,51,51,255/100*50))
		dxDrawText("Visszalépés",x+padding,y + ph - (button[2]) - padding,button[1] + x+padding,button[2] + y + ph - (button[2]) - padding, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 65,y + ph - (button[2]) - padding + 7,16,16,f.."close-browser.png",0,0,0,tocolor(0,0,0,255))
	else
		dxDrawRoundedRectangle(x+padding,y + ph - (button[2]) - padding,button[1],button[2],tocolor(0,0,0,255/100*25))
		dxDrawText("Visszalépés",x+padding,y + ph - (button[2]) - padding,button[1] + x+padding,button[2] + y +ph - (button[2]) - padding, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
		dxDrawImage(x+padding+(pw/2 - 8)- 65,y + ph - (button[2]) - padding + 7,16,16,f.."close-browser.png")
	end
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = x + pw/2 - size["keypad-size"]/2
		local kx = x + (sub_column * (size["keypad-size"] + padding)) + padding - (size["keypad-size"] + padding)
		local ky = y + (sub_row * (size["keypad-size"] + padding)) + padding + 88 + padding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.num, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*50))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.num, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
end

function exitATMPanel()
	if show_atm_panel then
		show_atm_panel = false
		removeEventHandler("onClientRender", root, drawATMselector)
		seleted_atm_page = 1
	end
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
        return true
    else
        return false
    end
end

addEventHandler("onClientObjectBreak", root,
function()
	if getElementType(source) == "object" and getElementData(source, "bank >> isValidATM") and getElementModel(source) == 2942 then
		setObjectBreakable(source, false)
		cancelEvent()
	end
end
);

function getServerSyntax(...)
    return exports['cr_core']:getServerSyntax(...)
end

function getServerColor(...)
    return exports['cr_core']:getServerColor(...)
end

local maxDist = 16
local white = "#ffffff"

addCommandHandler("nearbyatm", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, "nearbyatm") then
            local syntax = getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Közeledben lévő atm-k: ",255,255,255,true)
            local green = getServerColor(nil, true)
            for k,v in pairs(getElementsByType("object",_,true)) do
                local id = v:getData("bank >> id")
                if id then
                    local yard = getDistanceBetweenPoints3D(localPlayer.position, v.position)
                    if yard <= maxDist then
                        outputChatBox("#"..id..", "..green..yard..white.." (yard)",255,255,255,true)
                    end
                end
            end
        end
    end
)