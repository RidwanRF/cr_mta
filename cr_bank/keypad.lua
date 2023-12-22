sx, sy = guiGetScreenSize()
f = "files/"
alpha = 0
multipler = 2

local oSaveValues = {}
page_name = ""

max_column = 3
keyPadding = 3
column = 0
row = 0
local buttons = {"1","2","3","4","5","6","7","8","9","#","0","*"}

draw_keypad = false

entered_password = {}
max_password_long = 6

local fonts = {};
lastTick = -1000
tickTime = 1

function drawKeyPad()
	fonts.normal = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-bg.png", 0,0,0, tocolor(255,255,255,alpha))	
    dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-textarea.png", 0,0,0, tocolor(255,255,255,alpha))	
	if isInSlot(sx/2 - 294/2, sy/2 + 82, 294, 25) then
		dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-login-active.png", 0,0,0, tocolor(255,255,255,alpha))
	else
		dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-login.png", 0,0,0, tocolor(255,255,255,alpha))
	end	
	if isInSlot(sx/2 - 294/2, sy/2 + 82 + 25 + 3, 294, 25) then
		dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-exit-active.png", 0,0,0, tocolor(255,255,255,alpha))
	else
		dxDrawImage(sx/2 - size["keypad-bg-X"]/2, sy/2 - size["keypad-bg-Y"]/2, size["keypad-bg-X"], size["keypad-bg-Y"], f .. "keypad-exit.png", 0,0,0, tocolor(255,255,255,alpha))	
	end
	
	local column = 0
	local row = 0
	
	if #entered_password > 0 then
		local original = table.concat(entered_password)
		local new_hashed_passwd = string.rep( "*", string.len(original))
		dxDrawText(new_hashed_passwd, sx/2 - 290/2,sy/2 - 25/2 - 94, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 - 94, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
	end
	
	for i=1,12 do
		if(column > max_column - 1)then
			column = 0
			row = row + 1
		end	
		local x = sx/2 - size["keypad-size"]/2
		local y = sy/2 - size["keypad-size"]/2
		local kx = (x + (column * (size["keypad-size"] + keyPadding))) - size["keypad-size"] - keyPadding
		local ky = (y + (row * (size["keypad-size"] + keyPadding))) - ((size["keypad-size"] * 1.5) + keyPadding )
		if isInSlot(kx, ky, size["keypad-size"], size["keypad-size"]) then
			dxDrawImage(kx, ky, size["keypad-size"], size["keypad-size"], f .. "keypad-button-hover.png", 0,0,0, tocolor(255,255,255,alpha))
			dxDrawText(buttons[i], kx, ky, size["keypad-size"] + kx, size["keypad-size"] + ky, colors.black, 1, fonts.normal, "center", "center", false, false, false, true, false)
		else
			dxDrawImage(kx, ky, size["keypad-size"], size["keypad-size"], f .. "keypad-button.png", 0,0,0, tocolor(255,255,255,alpha))
			dxDrawText(buttons[i], kx, ky, size["keypad-size"] + kx, size["keypad-size"] + ky, colors.white, 1, fonts.normal, "center", "center", false, false, false, true, false)
		end		
		column = column + 1	
	end
end


function createKeyPad(name)
	if not tostring(name) then return end
    addEventHandler("onClientRender",root, drawKeyPad, false, "low-1")
    draw_keypad = true
    page_name = tostring(name)


    oSaveValues = {getElementData(localPlayer, "hudVisible"), getElementData(localPlayer, "keysDenied")}
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    setElementFrozen(localPlayer, true)
    --setElementData(localPlayer, "hudVisible", false)
    toggleAllControls(false)			
end

function clickToKeyPad (button, state,clickedElement)
	if exports['cr_network']:getNetworkStatus() then return end
	if isPedInVehicle(localPlayer) then return end
	if clickedElement and button =="left" and state =="down" and draw_keypad then
		local column = 0
		local row = 0
		local max_column = 3
		local keyPadding = 3		
		
		for i=1,12 do
			if(column > max_column - 1)then
				column = 0
				row = row + 1
			end	
			local x = sx/2 - size["keypad-size"]/2
			local y = sy/2 - size["keypad-size"]/2
			local kx = (x + (column * (size["keypad-size"] + keyPadding))) - size["keypad-size"] - keyPadding
			local ky = (y + (row * (size["keypad-size"] + keyPadding))) - ((size["keypad-size"] * 1.5) + keyPadding )
			
			if isInSlot(kx, ky, size["keypad-size"], size["keypad-size"]) and not show_loader then		
				if buttons[i] ~= "" then
					if #entered_password + 1 > max_password_long then return end
						table.insert(entered_password, buttons[i])
						playSound("files/songs/keypad.wav")								
						return
				end
			end
			column = column + 1		
		end	
		if isInSlot(sx/2 - 22/2 + 132,sy/2 - 20/2 - 95, 22, 20) and not show_loader then			
			if table.concat(entered_password) ~= "" then
				table.remove(entered_password, #entered_password)
				playSound("files/songs/keypad.wav")
			end
		elseif isInSlot(sx/2 - 294/2, sy/2 + 82, 294, 25) and not show_loader then
			if page_name == "enter_pin_bank" then --// BANK
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()
				if tostring(entered_password[1]) == "#" or tostring(entered_password[1]) == "*" then
					return exports["cr_infobox"]:addBox("error", "Hibás számot adtál meg. Nem lehet speciális karakter a jelszóban!")
				end					
				if #entered_password == 0 then
					exports['cr_infobox']:addBox("error", "Nem lehet üresen a jelszó(pincode) rész! Add meg a pincoded!")
					entered_password = {}
				elseif tonumber(table.concat(entered_password)) ~= (bankAccountData[4]) then
					exports['cr_infobox']:addBox("error", "Hibás jelszót(pincode) adtál meg! Próbálkozz újra.")
					entered_password = {}
				elseif tonumber(table.concat(entered_password)) == (bankAccountData[4]) then	
					exports['cr_infobox']:addBox("success", "Sikeresen beléptél a számládhoz. Az adatok betöltése után továbbítunk a kezelő felületre.")
					showBankLoader(true)
					setTimer(function() 
						showBankLoader(false) 
						addEventHandler("onClientRender",root, drawMainPanel, false, "low-1")
						exitForSubPanel()
					end, 4000, 1)					
				end
			elseif page_name == "enter_pin_bank_to_atm" then --// ATM
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()			
				if #entered_password == 0 then
					exports['cr_infobox']:addBox("error", "Nem lehet üresen a pincoded! Add meg a pincoded!")
					entered_password = {}
				elseif tonumber(table.concat(entered_password)) ~= (bankAccountData[4]) then
					exports['cr_infobox']:addBox("error", "Hibás pincoded adtál meg! Próbálkozz újra.")
					entered_password = {}
				elseif tonumber(table.concat(entered_password)) == (bankAccountData[4]) then	
					exports['cr_infobox']:addBox("success", "Sikeresen beléptél a számládhoz. Az adatok betöltése után továbbítunk a kezelő felületre.")
					showBankLoader(true)
					setTimer(function() 
						showBankLoader(false) 
						show_atm_panel = true
						addEventHandler("onClientRender",root, drawATMselector, false, "low-1")
						exitForSubPanel()
					end, 5000, 1)	
					entered_password = {}					
				end			
			end
		elseif isInSlot(sx/2 - 294/2, sy/2 + 82 + 25 + 3, 294, 25) and not show_loader then
			if page_name == "enter_pin_bank" then --// BANK
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()			
				show = false
				exitKeyPadPanel()
			elseif page_name == "enter_pin_bank_to_atm" then --// ATM	
				local now = getTickCount()
				if now <= lastTick + (tickTime * 1000) then
					exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
					return
				end
				lastTick = getTickCount()			
				show = false
				exitKeyPadPanel()			
			end
		end
    end
end
addEventHandler ( "onClientClick", root, clickToKeyPad )

function exitForSubPanel()
	entered_password = {}
	draw_keypad = false
	alpha = 0
	
	if page_name == "enter_pin_bank_to_atm" then
		atm_state = false
	end
	
	removeEventHandler("onClientRender", root, drawKeyPad)
end

function exitKeyPadPanel()
	if draw_keypad then
		setCameraTarget(localPlayer)
	end
	entered_password = {}
	draw_keypad = false
	alpha = 0
	
	if page_name == "enter_pin_bank_to_atm" then
		atm_state = false
	end
	
	removeEventHandler("onClientRender", root, drawKeyPad)
	exports.cr_blur:removeBlur("cr_bank_blur")


	
	setTimer(function() show_bank_panel = false end, 1000, 1)	
	setElementFrozen(localPlayer, false)
    setElementData(localPlayer, "hudVisible", oSaveValues[1])
    setElementData(localPlayer, "keysDenied", oSaveValues[2])

    toggleAllControls(true)
    local bones = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true}
    setElementData(localPlayer, "char >> bone", {false, false, false, false, false})
    setElementData(localPlayer, "char >> bone", bones)
    --exports.cr_blur:removeBlur("cr_bank_blur")
	
end

addEventHandler( "onClientResourceStop", resourceRoot,
    function ()
        exitKeyPadPanel();
    end
);

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