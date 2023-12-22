ped = {}
local number = ""

addEventHandler( "onClientResourceStart", resourceRoot,
	function ()
		for k,v in ipairs(bankPedPos) do
			ped[k] = createPed(bankPedPos[k][1],bankPedPos[k][2],bankPedPos[k][3],bankPedPos[k][4])	
			setElementRotation(ped[k], 0, 0, v[5])
			setElementDimension(ped[k], v[6])
			setElementInterior(ped[k], v[7])
			setElementFrozen(ped[k], true)
			setElementData(ped[k], "ped >> bankAdministrator", true)
			setElementData(ped[k], "bank >> bankAdministratorID", k)
			setElementData(ped[k], "ped.name", v[8])
			setElementData(ped[k], "ped.type", v[9])			
			setElementData(ped[k], "char >> noDamage", true)			
		end
	end
)
local sw, sh = guiGetScreenSize()
show_bank_panel = false

local pw, ph = 300, 280
local x, y = sw / 2 - pw / 2, sh / 2 - ph / 2

local w, h = 612, 360
local mx, my = sw / 2 - w / 2, sh / 2 - h / 2

can_press = true

local log_value = 800

local main_menu = {
	--Oldal neve, Icon neve, tab neve
	{"Áttekintés", "list-menu", "main"};
	{"Utalás", "money-reference", "reference"};
	{"Pénz felvétel", "money-out", "money-out"};
	{"Pénz befizetés", "money-in", "money-in"};
	{"Kezelés", "settings-gears", "settings"};
};

local lastTick = -1000
local tickTime = 3

--[[
	Loader deffinition
]]
f = "files/"
fonts = {};

--[[
	Keypad deffinition
]]
local atm_keypad_text = {}
local maxLength = 6
local can_use_keypad = true

local tab = ""
local sub_tab = "main"
local selected_page = 1

local sub_max_column = 3
local sub_keyPadding = 3
local sub_column = 0
local sub_row = 0
local buttons = {"1","2","3","4","5","6","7","8","9","#","0","*"}

local entered_money_amount = {}
local entered_account_number = {}
local entered_reference_message = {}

bankAccountData = {}
--[[
Tábla felépítése:
bankAccountData = {id, owner_id, account_number, pincode, bank_money, is_frozen}
]]
requestSuccess = false
function getPlayerDatas(data)
	bankAccountData = data
	requestSuccess = true
end
addEvent("bank >> sendBankAccountData", true)
addEventHandler("bank >> sendBankAccountData", root, getPlayerDatas)

function refreshMoneyData(data)
	bankAccountData[5] = data
end
addEvent("bank >> refreshBankMoneyData", true)
addEventHandler("bank >> refreshBankMoneyData", root, refreshMoneyData)

newCardNumber = ""
function getPlayerNumber(data)
	newCardNumber = data	
end
addEvent("bank >> sendBankAccountNumberData", true)
addEventHandler("bank >> sendBankAccountNumberData", root, getPlayerNumber)

function insertToSQL()
	triggerServerEvent("bank >> createNewBankAccount", localPlayer, localPlayer, newCardNumber, 1234)
end

local bank_logs = {}
--[[
Tábla felépítése:
bank_logs = {id, log_type, owner, log_date, sender, host, amount, comment}

log_type = 1 Pénz felvétel, 2 Pénz berakás, 3 Készpénz felvétel ATMből, 4 Utalás
]]
function getPlayerNewLogs(data)
	bank_logs = data
	if not bank_logs then bank_logs = {} end
	if #bank_logs > 0 then
		table.sort(bank_logs, function(a, b) return a[1] > b[1] end)
	end
end
addEvent("bank >> getPlayerNewLogs", true)
addEventHandler("bank >> getPlayerNewLogs", root, getPlayerNewLogs)

local oSaveValues = {}

function addBankPedClick(button, state, absoluteX, absoluteY, wx, wy, wz, clickedElement)
	if exports['cr_network']:getNetworkStatus() then return end
	if isPedInVehicle(localPlayer) then return end
	if clickedElement and getElementType(clickedElement) == "ped" and not isEventHandlerAdded("onClientRender", root, drawKeyPad) and can_press and not show_bank_panel then
	local isBankPed = getElementData(clickedElement, "ped >> bankAdministrator")
		if button=="left" and state=="down" and isBankPed then
			for k,v in ipairs(ped) do
				pedID = getElementData(clickedElement, "bank >> bankAdministratorID")
				if pedID == k then
					local lx, ly, lz = getElementPosition(localPlayer)
					local px, py, pz = getElementPosition(v)
					if getDistanceBetweenPoints3D(lx, ly, lz, px, py, pz) <= 3 then
					
						local now = getTickCount()
						if now <= lastTick + (tickTime * 1000) then
							exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
							return
						end
						lastTick = getTickCount()	
						
						triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer) -- Adatok elkérése a szerver oldaltól
						triggerServerEvent("bank >> getPlayerLogs", localPlayer, localPlayer) -- LOGOK elkérése a szerver oldalról
						if not bank_logs then bank_logs = {} end
						if not bankAccountData then bankAccountData = {} end
						setCameraToPed(pedID)
                        
						show_bank_panel = true
						selected_page = 1
						
                        oSaveValues = {getElementData(localPlayer, "hudVisible"), getElementData(localPlayer, "keysDenied")}
						if #bankAccountData > 0 then
							exports["cr_infobox"]:addBox("info", "Üdvözöllek a banki kezelő felületen. Kérlek add meg a bankkártyádhoz tartozó maximum 6 számjegyű jelszavad(pincode)!")
							createKeyPad("enter_pin_bank")
						elseif #bankAccountData == 0  then
							tab = "create_acc"
							triggerServerEvent("bank >> getNewAccountNumber", localPlayer, localPlayer)
							createAccountPanel("create_personal_account")
							exports["cr_infobox"]:addBox("info", "Üdvözöllek a banki kezelő felületen. Mivel te még nem rendelkezel magánszámlával, kérlek készítsd el azt az alábbi felületen.")
						end
                        --inspect(oSaveValues)
						setElementData(localPlayer, "hudVisible", false)
						setElementData(localPlayer, "keysDenied", true)
						exports.cr_blur:createBlur("cr_bank_blur", 15)
					end
				end
			end
		end
	elseif button=="left" and state=="down" and sub_tab and show_bank_panel and can_press then	
		if isInSlot(mx + w - 120,my - 35 - 3,120,35) then
			local now = getTickCount()
			if now <= lastTick + (tickTime * 1000) then
				exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
				return
			end
            
            --outputChatBox("bezárás")
			lastTick = getTickCount()
			removeEventHandler("onClientRender", root, drawMainPanel)
			
			setCameraTarget(localPlayer)		
			setElementFrozen(localPlayer, false)
			setElementData(localPlayer, "hudVisible", oSaveValues[1])
			setElementData(localPlayer, "keysDenied", oSaveValues[2])
            
			toggleAllControls(true)
            local bones = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true}
            setElementData(localPlayer, "char >> bone", {false, false, false, false, false})
            setElementData(localPlayer, "char >> bone", bones)
			exports.cr_blur:removeBlur("cr_bank_blur")
	
			sub_tab = "main"
			show_bank_panel = false			
		end
		for k,v in ipairs(main_menu) do
			if isInSlot(mx + (k* (120 + 3)) - 123,my,120,35) then
				sub_tab = tostring(main_menu[k][3])
				selected_page = k
				if sub_tab == "money-out" then entered_money_amount = {} end
				if sub_tab == "money-in" then entered_money_amount = {} end
				if sub_tab == "settings" then entered_new_password = {} end
				if sub_tab == "reference" then entered_money_amount = {} entered_account_number = {}  entered_reference_message = {} end
				if sub_tab == "main" then triggerServerEvent("bank >> getPlayerLogs", localPlayer, localPlayer) end
			end
		end
		
		-- ***********************	
		-- Pénz kifizetés kezelése			
		if sub_tab == "money-out" and show_bank_panel then
		
			local sub_max_column = 3
			local sub_keyPadding = 3
			local sub_column = 0
			local sub_row = 0

			for i=1,12 do 
				if (sub_column > sub_max_column - 1) then
					sub_column = 0
					sub_row = sub_row + 1
				end	
				local x = sw/2 - size["keypad-size"]/2	
				local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
				local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
				if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
					if buttons[i] ~= "" then
						if buttons[i] == "#" or buttons[i] == "*" then
							return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
						end						
						if #entered_money_amount + 1 > 23 then return end
						table.insert(entered_money_amount, buttons[i])
						playSound("files/songs/keypad.wav")
						return
					end
				end
				sub_column = sub_column + 1		
			end	
			if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) and #entered_money_amount > 0 then
				if tostring(entered_money_amount[1]) == "#" or tostring(entered_money_amount[1]) == "*" then
					return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
				end
                if tonumber(table.concat(entered_money_amount)) <= 0 then return end
				if tonumber(table.concat(entered_money_amount)) > bankAccountData[5] then
					exports["cr_infobox"]:addBox("error", "Nincs ennyi pénzed a bankszámlán!")
				elseif entered_money_amount[1] == 0 then
					exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg.")
				else
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()				
					local money = tonumber(table.concat(entered_money_amount))
					exports["cr_infobox"]:addBox("success", "Sikeresen felvettél "..money.." dollár készpénzt a számládról!")
					triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, money, "removeMoneyFromBank")
					triggerServerEvent("bank >> createPlayerLog", localPlayer, localPlayer, 1, getElementData(localPlayer,"acc >> id"), getElementData(localPlayer,"char >> name"), "", money, "")
					playSound("files/songs/transfer.mp3")
					
					local player_id = tonumber(getElementData(localPlayer, "acc >> id"))
					local serverlog_text = player_id.."kivett egy összeget a számlájáról! ($"..money..")"
					exports['cr_logs']:addLog(localPlayer, "Bank", "kifizetes", serverlog_text)
					
					if money >= log_value then --Log készítés az adminok felé
						local syntax = exports['cr_admin']:getAdminSyntax()
						local aName = exports['cr_admin']:getAdminName(localPlayer)
						local orange = exports['cr_core']:getServerColor(nil, true)
						local white = "#FFFFFF"
						local text2 = orange..aName..white.." kivett a számlájáról egy olyan összeget mely során már lehetséges, hogy a játékos buggoltat! ("..orange.."$"..money..white..")"
						exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. text2, 3)
					end
					
					entered_money_amount = {}
					
				end
			end
			
			if isInSlot(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16) then
				if table.concat(entered_money_amount) ~= "" then
					table.remove(entered_money_amount, #entered_money_amount)
					playSound("files/songs/keypad.wav")
				end			
			end
		--	VÉGE
		-- ***********************	
		
		-- ***********************	
		-- Pénz befizetés kezelése				
		elseif sub_tab == "money-in" and show_bank_panel then
		
			local sub_max_column = 3
			local sub_keyPadding = 3
			local sub_column = 0
			local sub_row = 0

			for i=1,12 do 
				if (sub_column > sub_max_column - 1) then
					sub_column = 0
					sub_row = sub_row + 1
				end	
				local x = sw/2 - size["keypad-size"]/2	
				local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
				local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
				if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
					if buttons[i] ~= "" then
						if buttons[i] == "#" or buttons[i] == "*" then
							return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
						end						
						if #entered_money_amount + 1 > 23 then return end
						table.insert(entered_money_amount, buttons[i])
						playSound("files/songs/keypad.wav")
						return
					end
				end
				sub_column = sub_column + 1		
			end			
			if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) and #entered_money_amount > 0 then
				if tostring(entered_money_amount[1]) == "#" or tostring(entered_money_amount[1]) == "*" then
					return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
				end			
				if tonumber(table.concat(entered_money_amount)) > getElementData(localPlayer,"char >> money") then
					exports["cr_infobox"]:addBox("error", "Nincs nálad elég pénz a befizetéshez!")
				elseif entered_money_amount[1] == 0 then
					exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg.")					
				else
					local now = getTickCount()
					if now <= lastTick + (tickTime * 1000) then
						exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
						return
					end
					lastTick = getTickCount()				
				    
                    if tonumber(table.concat(entered_money_amount)) <= 0 then return end
                    
					local money = tonumber(table.concat(entered_money_amount))
					exports["cr_infobox"]:addBox("success", "Sikeresen befizettél "..money.." dollár készpénzt a számládra!")
					triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, money, "addMoneyToBank")
					triggerServerEvent("bank >> createPlayerLog", localPlayer, localPlayer, 2, getElementData(localPlayer,"acc >> id"), getElementData(localPlayer,"char >> name"), "", money, "")
					playSound("files/songs/transfer.mp3")
					
					local player_id = tonumber(getElementData(localPlayer, "acc >> id"))
					local serverlog_text = player_id.."befizetett egy összeget a számlájára! ($"..money..")"
					exports['cr_logs']:addLog(localPlayer, "Bank", "befizetes", serverlog_text)
					
					if money >= log_value then --Log készítés az adminok felé
						local syntax = exports['cr_admin']:getAdminSyntax()
						local aName = exports['cr_admin']:getAdminName(localPlayer)
						local orange = exports['cr_core']:getServerColor(nil, true)
						local white = "#FFFFFF"
						local text2 = orange..aName..white.." befizetett a számlájára egy olyan összeget mely során már lehetséges, hogy a játékos buggoltat! ("..orange.."$"..money..white..")"
						exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. text2, 3)
					end
					
					entered_money_amount = {}
					
				end
			end
			
			if isInSlot(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16) then
				if table.concat(entered_money_amount) ~= "" then
					table.remove(entered_money_amount, #entered_money_amount)
					playSound("files/songs/keypad.wav")
				end			
			end	
		--	VÉGE
		-- ***********************	
		
		-- ***********************	
		-- Utalás kezelése				
		elseif sub_tab == "reference" and show_bank_panel then
			local sub_max_column = 3
			local sub_keyPadding = 3
			local sub_column = 0
			local sub_row = 0
			local padding = 3  
			local bg_width = 300
			local bg_height = 223
			local button_height = 30
			local button_width = 300 - 6
			local def_x = mx + w - bg_width - padding
			local def_y = my + 35 + padding + 5			

			for i=1,12 do 
				if (sub_column > sub_max_column - 1) then
					sub_column = 0
					sub_row = sub_row + 1
				end	
				local x = def_x + bg_width/2 - size["keypad-size"]/2	
				local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
				local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
				if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
					if buttons[i] ~= "" then
						if buttons[i] == "#" or buttons[i] == "*" then
							return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
						end						
						if #entered_money_amount + 1 > 23 then return end
						table.insert(entered_money_amount, buttons[i])
						playSound("files/songs/keypad.wav")
						return
					end
				end
				sub_column = sub_column + 1		
			end	

			if isInSlot(def_x + padding + bg_width - 6 - 22,def_y + padding + 7,16,16) then
				if table.concat(entered_money_amount) ~= "" then
					table.remove(entered_money_amount, #entered_money_amount)
					playSound("files/songs/keypad.wav")
				end			
			end				
			
			if isInSlot(mx + (padding*2),def_y + 20,bg_width - 6, button_height) then
				if not isEventHandlerAdded( 'onClientKey', root, pressNumberValue) then
					addEventHandler("onClientKey", root, pressNumberValue)
				end	
			else
				if isEventHandlerAdded( 'onClientKey', root, pressNumberValue) then
					removeEventHandler("onClientKey", root, pressNumberValue)
				end
			end				
			
			if isInSlot(mx + (padding*2),def_y + 55 + padding + 20,bg_width - 6, 246) then
				if not isEventHandlerAdded( 'onClientKey', root, removeCharacter) then
					addEventHandler("onClientCharacter", root, pressMessageValue)
					addEventHandler("onClientKey", root, removeCharacter)				
				end
			else
				if isEventHandlerAdded( 'onClientKey', root, removeCharacter) then
					removeEventHandler("onClientCharacter", root, pressMessageValue)
					removeEventHandler("onClientKey", root, removeCharacter)
				end	
			end	

			if isInSlot(def_x + (padding*2),def_y + 190,button_width, button_height	) and #entered_money_amount > 0 and #entered_account_number > 0 then
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
				elseif tonumber(table.concat(entered_account_number)) == bankAccountData[3] then
					return exports["cr_infobox"]:addBox("error", "Magadnak nem utalhatsz összeget.")	
				else
					local money = tonumber(table.concat(entered_money_amount))
					local acc_numb = tonumber(table.concat(entered_account_number))
					local comment = tonumber(table.concat(entered_reference_message)) or ""
                    
                    if tonumber(table.concat(entered_money_amount)) <= 0 then return end
					
					triggerServerEvent("bank >> sendMoneyToPlayer", localPlayer, localPlayer, money, acc_numb, comment)
					exports["cr_infobox"]:addBox("success", "Sikeresen elutaltad a kívánt összeget! ($"..money..")")
					triggerServerEvent("bank >> createPlayerLog", localPlayer, localPlayer, 4, getElementData(localPlayer,"acc >> id"), getElementData(localPlayer,"char >> name"), "", money, "Számlaszám: "..acc_numb) -- log

					playSound("files/songs/transfer.mp3")
					
					local player_id = tonumber(getElementData(localPlayer, "acc >> id"))
					local serverlog_text = player_id.."elutalt egy összeget a számlájáról erre a számlára: "..acc_numb.."! ($"..money..")"
					exports['cr_logs']:addLog(localPlayer, "Bank", "utalas", serverlog_text)
					
					if money >= log_value then --Log készítés az adminok felé
						local syntax = exports['cr_admin']:getAdminSyntax()
						local aName = exports['cr_admin']:getAdminName(localPlayer)
						local orange = exports['cr_core']:getServerColor(nil, true)
						local white = "#FFFFFF"
						local text2 = orange..aName..white.." elutalt egy összeget erre a számlára: "..orange..acc_numb..white..". Lehetséges bugg veszély! ("..orange.."$"..money..white..")"
						exports['cr_core']:sendMessageToAdmin(localPlayer, syntax .. text2, 3)
					end	
					
					entered_account_number = {}
					entered_money_amount = {}					
				end
			end
		--	VÉGE
		-- ***********************	
		
		-- ***********************	
		-- Beállítások kezelése	
		elseif sub_tab == "settings" and show_bank_panel then
			local sub_max_column = 3
			local sub_keyPadding = 3
			local sub_column = 0
			local sub_row = 0

			for i=1,12 do 
				if (sub_column > sub_max_column - 1) then
					sub_column = 0
					sub_row = sub_row + 1
				end	
				local x = sw/2 - size["keypad-size"]/2	
				local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
				local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
				if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
					if buttons[i] ~= "" then
						if buttons[i] == "#" or buttons[i] == "*" then
							return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter a jelszóban!")
						end						
						if #entered_new_password + 1 > 6 then return end
						table.insert(entered_new_password, buttons[i])
						playSound("files/songs/keypad.wav")
						return
					end
				end
				sub_column = sub_column + 1		
			end
			
			if isInSlot(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16) then
				if table.concat(entered_new_password) ~= "" then
					table.remove(entered_new_password, #entered_new_password)
					playSound("files/songs/keypad.wav")
				end			
			end	
			
			if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) and #entered_new_password > 0 then
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()	
				if tostring(entered_new_password[1]) == "#" or tostring(entered_new_password[1]) == "*" then
					return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter az összegben!")
				end					
				triggerServerEvent("bank >> setNewPassword", localPlayer, localPlayer, entered_new_password)
				entered_new_password = {}
				exports["cr_infobox"]:addBox("success", "Sikeresen megváltoztattad a jelszavad!")
			end
			
			if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6, 30) then
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()				
				if exports["cr_inventory"]:hasItem(localPlayer,97,bankAccountData[3]) then
					return exports["cr_infobox"]:addBox("warning", "Te rendelkezel már kártyával a számládhoz, így nem tudsz újat igényelni!")
				else
					exports["cr_inventory"]:giveItem(localPlayer, 97, bankAccountData[3], 1, 100, 0, 0, 0)
					exports["cr_infobox"]:addBox("success", "Sikeresen igényeltél egy új bankkártyát a számládhoz!")
				end
			end
		end
		--	VÉGE
		-- ***********************			
	end	
end
addEventHandler ("onClientClick", root, addBankPedClick)

function drawMainPanel()
	fonts.small = exports['cr_fonts']:getFont("Rubik-Regular", 10)
	fonts.normal = exports['cr_fonts']:getFont("Rubik-Regular", 12)
	for k,v in ipairs(main_menu) do
	
		if selected_page == k then
			dxDrawRoundedRectangle(mx + (k* (120 + 3)) - 123,my,120,35,tocolor(255,153,51,255/100*75))
			dxDrawText(main_menu[k][1], mx + (k* (120 + 3)) - 123,my,120 + mx + (k* (120 + 3)) - 123 + 2,35 + my, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)
			dxDrawImage(mx + (k* (120 + 3)) - 123 + 2,my + 9, 16,16, f ..main_menu[k][2] .. ".png", 0,0,0, tocolor(0,0,0,255))	
		else	
			dxDrawRoundedRectangle(mx + (k* (120 + 3)) - 123,my,120,35,tocolor(0,0,0,255/100*75))
			dxDrawText(main_menu[k][1], mx + (k* (120 + 3)) - 123,my,120 + mx + (k* (120 + 3)) - 123 + 2,35 + my, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)
			dxDrawImage(mx + (k* (120 + 3)) - 123 + 2,my + 9, 16,16, f ..main_menu[k][2] .. ".png", 0,0,0, tocolor(255,255,255,255))			
		end
	
		if isInSlot(mx + (k* (120 + 3)) - 123,my,120,35) then
			dxDrawRoundedRectangle(mx + (k* (120 + 3)) - 123,my,120,35,tocolor(255,153,51,255/100*75))
			dxDrawText(main_menu[k][1], mx + (k* (120 + 3)) - 123,my,120 + mx + (k* (120 + 3)) - 123 + 2,35 + my, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)
			dxDrawImage(mx + (k* (120 + 3)) - 123 + 2,my + 9, 16,16, f ..main_menu[k][2] .. ".png", 0,0,0, tocolor(0,0,0,255))		
		end
		
	end
	dxDrawRoundedRectangle(mx, my + 35 + 3, w, h, tocolor(0,0,0,255/100*75))
	if isInSlot(mx + w - 120,my - 35 - 3,120,35) then
		dxDrawRoundedRectangle(mx + w - 120,my - 35 - 3,120,35,tocolor(255,153,51,255/100*75))
		dxDrawImage(mx + w - 120 + 3,my - 35 + 7, 16,16,f.."close-browser.png",0,0,0,tocolor(0,0,0,255))
		dxDrawText("Kilépés", mx + w - 120,my - 35,120 + mx + w - 120,35 + my - 35 - 3, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)
	else
		dxDrawRoundedRectangle(mx + w - 120,my - 35 - 3,120,35,tocolor(0,0,0,255/100*75))
		dxDrawImage(mx + w - 120 + 3,my - 35 + 7, 16,16,f.."close-browser.png",0,0,0,tocolor(255,255,255,255))
		dxDrawText("Kilépés", mx + w - 120,my - 35,120 + mx + w - 120,35 + my - 35 - 3, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)
	end
	if sub_tab == "main" then
		mainTab()
	elseif sub_tab == "reference" then
		reference()
	elseif sub_tab == "money-out" then		
		moneyOut()
	elseif sub_tab == "money-in" then	
		moneyIn()
	elseif sub_tab == "settings" then	
		settings()
	end
end

--[[
	*************************************************
	*					Kezdőoldal					*
	*************************************************
]]
local maxLogShow = 5
local logScroll = 0
-- local 

function mainTab()
	local x = sw / 2 - 550 / 2
	dxDrawText("Üdvözöllek a kezelőfelületen kedves, #ffdb33"..getPlayerName(localPlayer):gsub("_", " ").."#FFFFFF!", mx, my + 35 + 3 + 5, w + mx, h, colors.white, 1, fonts.small, "center", "top", false, false, false, true, false)
	dxDrawRoundedRectangle(x,my + 35 + 3 + 25,550,90,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(x + 3,my + 35 + 3 + 25 + 3,543,55,tocolor(52,52,52,255/100*25))
	dxDrawRoundedRectangle(x,my + 35 + 3 + 25 + 90 - 35,550,35,tocolor(0,0,0,255/100*25))
	
	dxDrawText("Banki információk",x,my + 35 + 3 + 25 + 90 - 35,543 + x + 3,35 + my + 35 + 3 + 25 + 90 - 35, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	dxDrawText("Számlaszámod: #ff9933"..sep(tostring(bankAccountData[3]), "%x%x%x%x", "-"),x + 3 + 5,my + 3 + 35 + 3 + 25 + 3,543,82, colors.white, 1, fonts.small, "left", "top", false, false, false, true, false)
	dxDrawText("Számla egyenlege: #ff9933$"..bankAccountData[5],x + 3 + 5,my + 3 + 35 + 3 + 25 + 3 + 15 ,543,82, colors.white, 1, fonts.small, "left", "top", false, false, false, true, false)
	dxDrawText("Számla jelszava: #ff9933"..bankAccountData[4],x + 3 +5,my + 3 + 35 + 3 + 25 + 3 +15*2,543,82, colors.white, 1, fonts.small, "left", "top", false, false, false, true, false)
	
	-- Logok kirajzolása
	dxDrawRoundedRectangle(x,my + 35 + 3 + 25 + 3 + 55 + 35 + 3,550,230,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(x,my + 35 + 3 + 25 + 3 + 55 + 35 + 3 + 230 - 35,550,35,tocolor(0,0,0,255/100*25))
	dxDrawText("Tranzakciók",x,my + 35 + 3 + 25 + 3 + 55 + 35 + 3 + 230 - 35,550 + x,35 + my + 35 + 3 + 25 + 3 + 55 + 35 + 3 + 230 - 35, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	for i=1,5 do 
		local y = my + 35 + 3 + 25 + 3 + 55 + 35 + 3 + 3
		dxDrawRoundedRectangle(x + 3,y + (i * (35 + 3)) - 35 - 3,543,35,tocolor(52,52,52,255/100*25))
	end
	local line = 0
	
	for k,v in ipairs(bank_logs) do
		if (k > logScroll and line < maxLogShow) then
				line = line + 1	
			if #bank_logs > 0 then
				local log_type = setLogTypeName(bank_logs[k][2])
				local log_text = ""
				if bank_logs[k][8] ~= "" then
					log_comment = " (#ff9933"..bank_logs[k][8].."#ffffff) "
				else
					log_comment = ""
				end
				log_text = bank_logs[k][4].." "..log_type..log_comment.. " (#ff9933$"..bank_logs[k][7].."#ffffff)"

				local y = my + 35 + 3 + 25 + 3 + 55 + 35 + 3 + 3
				dxDrawText(log_text,x + 10,y + (line - 1) * (35 + 3) ,496,35 + y + (line - 1) * (35 + 3), colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
			end
		end
	end
end

function setLogTypeName(typ)
	if typ == 1 then
		return "Pénz felvétel"
	elseif typ == 2 then	
		return "Pénz berakás"
	elseif typ == 3 then	
		return "Készpénz felvétel ATM-ből"
	elseif typ == 4 then	
		return "Utalás"
	elseif typ == 5 then	
		return "Készpénz befizetés ATM-ből"		
	else	
		return "Ismeretlen művelet"
	end
end

function keyHandler(key, state)
	if not show_bank_panel then return end
	if not sub_tab == "main" then return end
	if key == "mouse_wheel_down" and isInSlot(x,my + 35 + 3 + 25 + 3 + 55 + 35 + 3,550,230) and sub_tab == "main" then
		if logScroll < #bank_logs - maxLogShow then
			logScroll = logScroll + 1	
		end
	end
	if key == "mouse_wheel_up" and isInSlot(x,my + 35 + 3 + 25 + 3 + 55 + 35 + 3,550,230) and sub_tab == "main" then
		if logScroll > 0 then
			logScroll = logScroll - 1	
		end
	end	
end
addEventHandler("onClientKey", root, keyHandler)


--[[
	*************************************************
	*					Utalás						*
	*************************************************
]]

function reference()
	local x = sw / 2 - w / 2
	local sub_column = 0
	local sub_row = 0
	local padding = 3  
	local bg_width = 300
	local bg_height = 223
	local button_height = 30
	local button_width = 300 - 6
	local def_x = mx + w - bg_width - padding
	local def_y = my + 35 + padding + 5

	dxDrawRoundedRectangle(def_x ,def_y ,bg_width, bg_height,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(def_x + padding,def_y + padding,bg_width - 6, button_height,tocolor(52,52,52,255/100*25))
	dxDrawImage(def_x + padding + bg_width - 6 - 22,def_y + padding + 7,16,16,f.."delete.png",0,0,0,tocolor(255,255,255,255))
	
	if isInSlot(def_x + (padding*2),def_y + 190,button_width, button_height) then
		dxDrawRoundedRectangle(def_x + (padding*2),def_y + 190,button_width, button_height,tocolor(51, 133, 255,255/100*50))
		dxDrawText("Átutalás",def_x + (padding*2),def_y + 190,button_width + def_x + (padding*2), button_height + def_y + 190, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
	else
		dxDrawRoundedRectangle(def_x + (padding*2),def_y + 190,button_width, button_height,tocolor(0,0,0,255/100*25))
		dxDrawText("Átutalás",def_x + (padding*2),def_y + 190,button_width + def_x + (padding*2), button_height + def_y + 190, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
	end

	if #entered_money_amount > 0 then
		local entered_money_amount = table.concat(entered_money_amount)
		dxDrawText(entered_money_amount, def_x + padding,def_y + padding,button_width - 6 + def_x + padding, button_height + def_y + padding, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	end	
	
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = def_x + bg_width/2 - size["keypad-size"]/2
		local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
		local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*25))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
	
	-- ***********************
	-- Jelenlegi vagyon
	dxDrawRoundedRectangle(def_x,def_y + 225,bg_width, 102,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(def_x + padding,def_y + 225 + padding,button_width, button_height,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(def_x + padding,def_y + 225 + (padding*2) + button_height,button_width, button_height,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(def_x + padding,def_y + 225 + (padding*3) + (button_height*2),button_width, button_height,tocolor(0,0,0,255/100*50))
	
	local money = getElementData(localPlayer,"char >> money")
	dxDrawText("Készpénz: #ff9933$"..money,def_x + (padding*2),def_y + 225 + padding,button_width, button_height + def_y + 225 + padding, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Banki egyenleg: #ff9933$"..bankAccountData[5],def_x + (padding*2),def_y + 225 + (padding*2) + button_height,button_width, button_height + def_y + 225 + (padding*2) + button_height, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Jelenlegi vagyon",def_x + padding,def_y + 225 + (padding*3) + (button_height*2),button_width + def_x + padding, button_height + def_y + 225 + (padding*3) + (button_height*2), colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)	
	
	-- ***********************
	-- Számlaszám beírása	
	dxDrawRoundedRectangle(mx + padding,def_y,bg_width, 55,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(mx + (padding*2),def_y + 20,bg_width - 6, button_height,tocolor(52,52,52,255/100*50))
	
	dxDrawImage(mx + (padding*2),def_y + padding,16,16,f.."money-reference.png",0,0,0,tocolor(255,255,255,255))
	dxDrawText("Számlaszám megadása:",mx + (padding*3) + 16,def_y,button_width, button_height + def_y - 8, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	
	if #entered_account_number > 0 then
	local entered_account_number = table.concat(entered_account_number)
		dxDrawText(entered_account_number,mx + (padding*4),def_y + 20,bg_width - 6, button_height + def_y + 20, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	end
	
	
	-- ***********************
	-- Üzenet beírása	
	dxDrawRoundedRectangle(mx + padding,def_y + 55 + padding,bg_width, 269,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(mx + (padding*2),def_y + 55 + padding + 20,bg_width - 6, 246,tocolor(52,52,52,255/100*50))
	
	dxDrawImage(mx + (padding*2),def_y + 55 + padding,16,16,f.."message.png",0,0,0,tocolor(255,255,255,255))
	dxDrawText("Üzenet megadása:",mx + (padding*3) + 16,def_y + 55 + padding,button_width, button_height + def_y + 55 + padding - 8, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	
	if #entered_reference_message > 0 then
	local entered_reference_message = table.concat(entered_reference_message)
		dxDrawText(entered_reference_message,mx + (padding*4) - 6,def_y + 55 + padding + 20,mx + (padding*4) - 6 + bg_width - 6, def_y + 55 + padding + 20 + 246, colors.white, 1, fonts.small, "left", "top", false, true, false, false)
        --dxDrawRectangle(mx + (padding*4),def_y + 55 + padding + 20,bg_width - 6, 246)
	end	
end

local allowedCharacter = {
	["0"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true,
}
function pressNumberValue(key, press)
	if show_bank_panel and sub_tab == "reference" then
		if press then
			if key == "backspace" and table.concat(entered_account_number) ~= "" then
				table.remove(entered_account_number, #entered_account_number)
			end	
			if allowedCharacter[key] then
			if #entered_account_number + 1 > 12 then return end
				table.insert(entered_account_number,key)
			end
		end
	end
end

function removeCharacter(key, press)
	if show_bank_panel and sub_tab == "reference" then
		if press then
			if key == "backspace" and table.concat(entered_reference_message) ~= "" then
				table.remove(entered_reference_message, #entered_reference_message)
			end	
		end
	end
end

function pressMessageValue(character)
	if show_bank_panel and sub_tab == "reference" then
		if #entered_reference_message + 1 > 255 then return end		
		table.insert(entered_reference_message,character)
	end
end

--[[
	*************************************************
	*					Pénz felvétel				*
	*************************************************
]]
function moneyOut()
	local x = sw / 2 - w / 2
	local sub_column = 0
	local sub_row = 0
	
	dxDrawRoundedRectangle(mx + 300/2,my + 35 + 3 + 5,300, 220,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 3,300 - 6, 30,tocolor(52,52,52,255/100*25))
	dxDrawImage(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16,f.."delete.png",0,0,0,tocolor(255,255,255,255))

	
	if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) then
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(51,133,255,255/100*50))
		dxDrawText("Pénz felvétel",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
	else
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(0,0,0,255/100*25))
		dxDrawText("Pénz felvétel",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
	end

	if #entered_money_amount > 0 then
		local entered_money = table.concat(entered_money_amount)
		dxDrawText(entered_money, mx + 300/2 + 3,my + 35 + 3 + 8,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 8, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	end	
	
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = sw/2 - size["keypad-size"]/2	
		local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
		local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*25))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
	
	dxDrawRoundedRectangle(sw / 2 - 400 / 2,my + 35 + 3 + 5 + 225,400, 105,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3,400 - 6, 30,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + 30 + 3,400 - 6, 30,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2 ,400 - 6, 30,tocolor(0,0,0,255/100*50))
	
	local money = getElementData(localPlayer,"char >> money")
	dxDrawText("Készpénz: #ff9933$"..money,sw / 2 - 400 / 2 + 3 + 5,my + 35 + 3 + 5 + 225 + 3,400 - 6, 30 + my + 35 + 3 + 5 + 225 + 3, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Banki egyenleg: #ff9933$"..bankAccountData[5],sw / 2 - 400 / 2 + 3 + 5,my + 35 + 3 + 5 + 225 + 3 + 30 + 3,400 - 6, 30 + my + 35 + 3 + 5 + 225 + 3 + 30 + 3, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Jelenlegi vagyon",sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2,400 - 6 + sw / 2 - 400 / 2 + 3, 30 + my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	
end

--[[
	*************************************************
	*					Pénz betétel				*
	*************************************************
]]
function moneyIn()
	local x = sw / 2 - w / 2
	local sub_column = 0
	local sub_row = 0
	
	dxDrawRoundedRectangle(mx + 300/2,my + 35 + 3 + 5,300, 220,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 3,300 - 6, 30,tocolor(52,52,52,255/100*25))
	dxDrawImage(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16,f.."delete.png",0,0,0,tocolor(255,255,255,255))

	
	if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) then
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(51,133,255,255/100*50))
		dxDrawText("Pénz befizetés",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
	else
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(0,0,0,255/100*25))
		dxDrawText("Pénz befizetés",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
	end

	if #entered_money_amount > 0 then
		local entered_money = table.concat(entered_money_amount)
		dxDrawText(entered_money, mx + 300/2 + 3,my + 35 + 3 + 8,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 8, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	end	
	
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = sw/2 - size["keypad-size"]/2	
		local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
		local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*25))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
	
	dxDrawRoundedRectangle(sw / 2 - 400 / 2,my + 35 + 3 + 5 + 225,400, 105,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3,400 - 6, 30,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + 30 + 3,400 - 6, 30,tocolor(52,52,52,255/100*50))
	dxDrawRoundedRectangle(sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2 ,400 - 6, 30,tocolor(0,0,0,255/100*50))
	
	local money = getElementData(localPlayer,"char >> money")
	dxDrawText("Készpénz: #ff9933$"..money,sw / 2 - 400 / 2 + 3 + 5,my + 35 + 3 + 5 + 225 + 3,400 - 6, 30 + my + 35 + 3 + 5 + 225 + 3, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Banki egyenleg: #ff9933$"..bankAccountData[5],sw / 2 - 400 / 2 + 3 + 5,my + 35 + 3 + 5 + 225 + 3 + 30 + 3,400 - 6, 30 + my + 35 + 3 + 5 + 225 + 3 + 30 + 3, colors.white, 1, fonts.small, "left", "center", false, false, false, true, false)
	dxDrawText("Jelenlegi vagyon",sw / 2 - 400 / 2 + 3,my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2,400 - 6 + sw / 2 - 400 / 2 + 3, 30 + my + 35 + 3 + 5 + 225 + 3 + (30 + 3) * 2, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
end

--[[
	*************************************************
	*					Beállítások					*
	*************************************************
]]

function settings()
	local x = sw / 2 - w / 2
	local sub_column = 0
	local sub_row = 0
	local padding = 3  
	
	dxDrawRoundedRectangle(mx + 300/2,my + 35 + 3 + 5,300, 253,tocolor(0,0,0,255/100*50))
	dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 3,300 - 6, 30,tocolor(52,52,52,255/100*25))
	dxDrawImage(mx + 300/2 + 3 + 300-6 - 22,my + 35 + 3 + 5 + 3 + 7,16,16,f.."delete.png",0,0,0,tocolor(255,255,255,255))


	if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6, 30) then
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6, 30,tocolor(94, 255, 51,255/100*50))
		dxDrawText("Bankkártya igénylése",mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190 + 30 + 3, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
	else
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6, 30,tocolor(0,0,0,255/100*25))
		dxDrawText("Bankkártya igénylése",mx + 300/2 + 3,my + 35 + 3 + 5 + 190 + 30 + 3,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190 + 30 + 3, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
	end
	
	if isInSlot(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30) then
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(255, 209, 51,255/100*50))
		dxDrawText("Jelszó megváltoztatás",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.black, 1, fonts.small, "center", "center", false, false, false, true, false)	
	else
		dxDrawRoundedRectangle(mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6, 30,tocolor(0,0,0,255/100*25))
		dxDrawText("Jelszó megváltoztatás",mx + 300/2 + 3,my + 35 + 3 + 5 + 190,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 5 + 190, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)	
	end

	if #entered_new_password > 0 then
		local entered_new_password = table.concat(entered_new_password)
		dxDrawText(string.rep( "*", string.len(entered_new_password)), mx + 300/2 + 3,my + 35 + 3 + 8,300 - 6 + mx + 300/2 + 3, 30 + my + 35 + 3 + 8, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	end	
	
	
	for i=1,12 do 
		if (sub_column > sub_max_column - 1) then
			sub_column = 0
			sub_row = sub_row + 1
		end	
		local x = sw/2 - size["keypad-size"]/2	
		local kx = x + (sub_column * (size["keypad-size"] + sub_keyPadding)) - size["keypad-size"] - keyPadding
		local ky = my + 35 + 3 + (sub_row * (size["keypad-size"] + sub_keyPadding)) + 35 + 5 + keyPadding
		if isInSlot(kx,ky,size["keypad-size"],size["keypad-size"]) then
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(255,153,51,255/100*75))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(kx,ky,size["keypad-size"],size["keypad-size"],tocolor(0,0,0,255/100*25))
			dxDrawText(buttons[i],kx,ky,size["keypad-size"] + kx,size["keypad-size"] + ky, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
		end
		sub_column = sub_column + 1		
	end	
end

--[[
	*************************************************
	*					Kacatok						*
	*************************************************
]]
function dxDrawRoundedRectangle(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	dxDrawRectangle(left + width, top, 2, height, color, postgui);
	dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	dxDrawRectangle(left, top + height, width, 2, color, postgui);

	dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	dxDrawRectangle(left, top, width, height, color, postgui);
end

function sep (str, patt, re)
    return str:gsub(patt, '%' .. re .. '%1'):sub(1 + #re)
end

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

function setCameraToPed(id)
	local p1, p2, p3, p4, p5, p6 = getCameraMatrix()
	for k,v in ipairs(bankPedCamPos) do
		if k == id then
			smoothMoveCamera(p1,p2,p3,p4,p5,p6,v[1],v[2],v[3],v[4],v[5],v[6],1000)	
			setElementFrozen(localPlayer, true)
			toggleAllControls(false)			
		end	
	end	

end

addEventHandler("onClientPlayerSpawn", localPlayer,
	function()
		loadCamTables()
		triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer)
	end
);

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer)
	end
);

function setBankMoney(newValue, state)
	if tonumber(newValue) and tostring(state) then
		triggerServerEvent("bank >> setPlayerBankMoney", localPlayer, localPlayer, newValue, state)
	end
end

function getPlayerBankMoney()
	triggerServerEvent("bank >> getPlayerBankAccount", localPlayer, localPlayer) -- Adatok elkérése a szerver oldaltól
	return bankAccountData[5]
end

function searchPlayerByAccID(id)
	local id = tonumber(id)
	if id then
		for k,v in pairs(getElementsByType("player")) do 
			if tonumber(v:getData("acc >> id")) then
				if tonumber(v:getData("acc >> id")) == id then
					triggerServerEvent("resultPlayer", localPlayer, localPlayer, v)
					return
				end
			end
		end
	end
end
addEvent("searchPlayerByAccID", true)
addEventHandler("searchPlayerByAccID", root, searchPlayerByAccID)

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
     if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
          local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
          if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
               for i, v in ipairs( aAttachedFunctions ) do
                    if v == func then
        	         return true
        	    end
	       end
	  end
     end
     return false
end