sx, sy = guiGetScreenSize()
f = "files/"
alpha = 0
multipler = 2

create_page_name = ""

draw_createAccount = false

local fonts = {};
lastTick = -1000
tickTime = 1

local create_help_text = "Kérjük, hogy az első bejelentkezés után \nváltoztassa meg a belépési kódját!"
function drawCreateAccountPanel()
	fonts.small = exports['cr_fonts']:getFont("Rubik-Regular", 10)
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawImage(sx/2 - size["createAccount-bg-X"]/2, sy/2 - size["createAccount-bg-Y"]/2, size["createAccount-bg-X"], size["createAccount-bg-Y"], f .. "create_account_bg.png", 0,0,0, tocolor(255,255,255,alpha))
	if isInSlot(sx/2 - 294/2, sy/2 + 44, 294, 25) then
		dxDrawImage(sx/2 - size["createAccount-bg-X"]/2, sy/2 - size["createAccount-bg-Y"]/2, size["createAccount-bg-X"], size["createAccount-bg-Y"], f .. "create_account_btn_create_hover.png", 0,0,0, tocolor(255,255,255,alpha))
	else
		dxDrawImage(sx/2 - size["createAccount-bg-X"]/2, sy/2 - size["createAccount-bg-Y"]/2, size["createAccount-bg-X"], size["createAccount-bg-Y"], f .. "create_account_btn_create.png", 0,0,0, tocolor(255,255,255,alpha))
	end	
	if isInSlot(sx/2 - 294/2, sy/2 + 44 + 25 + 3, 294, 25) then
		dxDrawImage(sx/2 - size["createAccount-bg-X"]/2, sy/2 - size["createAccount-bg-Y"]/2, size["createAccount-bg-X"], size["createAccount-bg-Y"], f .. "create_account_btn_exit_hover.png", 0,0,0, tocolor(255,255,255,alpha))
	else
		dxDrawImage(sx/2 - size["createAccount-bg-X"]/2, sy/2 - size["createAccount-bg-Y"]/2, size["createAccount-bg-X"], size["createAccount-bg-Y"], f .. "create_account_btn_exit.png", 0,0,0, tocolor(255,255,255,alpha))	
	end
	
	local clear_number = newCardNumber:gsub("....", "%1 ")
	dxDrawText("Számlaszámod:", sx/2 - 290/2,sy/2 - 25/2 - 60, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 - 60, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)
	dxDrawText(clear_number, sx/2 - 290/2,sy/2 - 25/2 - 45, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 - 45, colors.orange, 1, fonts.small, "center", "center", false, false, false, true, false)
	
	dxDrawText("Pincode (alapértelmezett):", sx/2 - 290/2,sy/2 - 25/2 - 20, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 - 20, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)
	dxDrawText("1234", sx/2 - 290/2,sy/2 - 25/2 - 5, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 - 5, colors.orange, 1, fonts.small, "center", "center", false, false, false, true, false)	
	
	dxDrawText(create_help_text, sx/2 - 290/2,sy/2 - 25/2 + 23, 290 + sx/2 - 290/2, 25 + sy/2 - 25/2 + 23, colors.white, 1, fonts.small, "center", "center", false, false, false, true, false)
	
end


function createAccountPanel(name)
	if not tostring(name) then return end
		addEventHandler("onClientRender",root, drawCreateAccountPanel, false, "low-1")
		draw_createAccount = true
		create_page_name = tostring(name)
end

function clickToCreatePanel (button, state,clickedElement)
	if exports['cr_network']:getNetworkStatus() then return end
	if isPedInVehicle(localPlayer) then return end
	if clickedElement and button =="left" and state =="down" and draw_createAccount then
		if isInSlot(sx/2 - 294/2, sy/2 + 44, 294, 25) then
			local now = getTickCount()
			if now <= lastTick + (tickTime * 1000) then
				exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
				return
			end
			lastTick = getTickCount()			
			if create_page_name == "create_personal_account" then --// BANK ACCOUNT CREATE
				exports['cr_infobox']:addBox("success", "Sikeresen létrehoztad a magánszámládat!")
				insertToSQL()
				exitCreateAccountPanel()
			end
		elseif isInSlot(sx/2 - 294/2, sy/2 + 44 + 25 + 3, 294, 25) then
			local now = getTickCount()
			if now <= lastTick + (tickTime * 1000) then
				exports['cr_infobox']:addBox("error", "Csak "..tickTime .." másodpercenként használhatod!")
				return
			end
			lastTick = getTickCount()		
			if create_page_name == "create_personal_account" then --// BANK ACCOUNT EXIT
				exitCreateAccountPanel()
			end
		end
    end
end
addEventHandler ( "onClientClick", root, clickToCreatePanel )

function exitCreateAccountPanel()
	if draw_createAccount then
		setCameraTarget(localPlayer)
	end
	draw_createAccount = false
	alpha = 0
	
	removeEventHandler("onClientRender", root, drawCreateAccountPanel)
	exports.cr_blur:removeBlur("cr_bank_blur")
	
	setTimer(function() show_bank_panel = false end, 1000, 1)
	setElementFrozen(localPlayer, false)
	setElementData(localPlayer, "hudVisible", true)
	toggleAllControls(true)	
end

addEventHandler( "onClientResourceStop", resourceRoot,
    function ()
        exitCreateAccountPanel();
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