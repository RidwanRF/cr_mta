local sx, sy = guiGetScreenSize()

function findPlayer(id)
	for i, v in pairs(getElementsByType("player")) do
		if(v:getData("char >> id") == id) then
			return v
		end
	end
	return false
end

function checkType(t, t2)
	t = tonumber(t)
	if(t == 1) then
		local temp = {"Autó", "autó", "Auto", "auto", "Kocsi", "kocsi"}
		for i, v in pairs(temp) do
			if(v == t2) then
				return true
			end
		end
		return false
	elseif(t == 2) then
		local temp = {"Ház", "ház", "Haz", "haz"}
		for i, v in pairs(temp) do
			if(v == t2) then
				return true
			end
		end
		return false
	end
	return false
end

addCommandHandler("adasveteli", function(cmd, type, id, price)
	id, price, type = tonumber(id), tonumber(price), tostring(type)
	local error = exports['cr_core']:getServerSyntax(false, "error")
	if(id and price) then
		if(checkType(1, type)) then
			local target = findPlayer(id)
			if(target) then
				if(target ~= localPlayer) then
					local pos = target:getPosition()
					local p_pos = localPlayer:getPosition()
					if(getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, p_pos.x, p_pos.y, p_pos.z) <= 3) then
						local t_contractData = target:getData("contract >> data")
						local p_contractData = localPlayer:getData("contract >> data")
						if(not t_contractData and not p_contractData) then
							if(isPedInVehicle(localPlayer)) then
								local veh = localPlayer:getOccupiedVehicle()
								if(veh:getData("veh >> owner") == localPlayer:getData("acc >> id")) then
									triggerServerEvent("sendVehicleContract", resourceRoot, target, veh, price)
								else
									outputChatBox(error.."Ez a jármű nem a te neveden van.", 255, 255, 255, true)
								end
							else
								outputChatBox(error.."Nem ülsz egy járműben sem.", 255, 255, 255, true)
							end
						elseif(t_contractData) then
							outputChatBox(error.."A célszemélynek folyamatban van éppen egy adásvételi.", 255, 255, 255, true)
						elseif(p_contractData) then
							outputChatBox(error.."Már van aktív adásvételid.", 255, 255, 255, true)
						end
					else
						outputChatBox(error.."Túl messze vagy a célszemélytől.", 255, 255, 255, true)
					end
				else
					outputChatBox(error.."Magadnak nem küldhetsz adásvételi ajánlatot.", 255, 255, 255, true)
				end
			else
				outputChatBox(error.."A célszemély nem található.", 255, 255, 255, true)
			end
		end
	elseif(type == "törlés") then
		triggerServerEvent("deleteContract", resourceRoot)
	else
		outputChatBox(error.."Használat: /"..cmd.." [Típus (Autó/Ház)] [ID] [Ár]", 255, 255, 255, true)
	end
end)

function roundedBorder(x, y, w, h, borderColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(255, 255, 255, 230)
		end

		dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI); -- right
		dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI); -- bottom

		dxDrawRectangle(x, y, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI);
		dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI);
	end
end

local contractData = {}

local oranger, orangeg, orangeb = exports['cr_core']:getServerColor("orange", false)

local font = dxCreateFont("files/Awesome.ttf", 18)
local ticketFont = dxCreateFont("files/fake-receipt.ttf", 9)
function renderContractDetails()
	local now = getTickCount()
	local endTime = start + 1000
	local elapsedTime = now - start
	local duration = endTime - start
	local progress = elapsedTime / duration
	local panelX = (sx/2)-320
	y = sy/2-(300/2)
	y = interpolateBetween(-1000, 0, 0, y, 0, 0, progress, "OutBounce")
	textPos = {panelX+50, y+175} 
	dxDrawImage(panelX, y, 640, 300, "files/adasveteli.png", 0, 0, 0, tocolor(255,255,255,255))
	dxDrawText(contractData["title"], textPos[1]+40, textPos[2], x, y, tocolor(oranger, orangeg, orangeb, 220), 1, ticketFont, "left", "center", false, false, false, true)
	
	dxDrawText("$"..contractData["price"], textPos[1]+225, textPos[2]+178, x, y, tocolor(0, 200, 0, 220), 0.7, font, "left", "center", false, false, false, true)
	
	if exports['cr_core']:isInSlot(textPos[1], textPos[2], 100, 25) then
		dxDrawText("Elfogadás", textPos[1]+12.5, textPos[2]+200, x, y, tocolor(0, 200, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		roundedBorder(textPos[1], textPos[2], 100, 25, tocolor(0, 200, 0, 220))
	else
		dxDrawText("Elfogadás", textPos[1]+12.5, textPos[2]+200, x, y, tocolor(0, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		roundedBorder(textPos[1], textPos[2], 100, 25, tocolor(0, 0, 0, 220))
	end
	
	if exports['cr_core']:isInSlot(textPos[1]+430, textPos[2], 100, 25) then
		dxDrawText("Elutasítás", textPos[1]+442.5, textPos[2]+200, x, y, tocolor(200, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		roundedBorder(textPos[1]+430, textPos[2], 100, 25, tocolor(200, 0, 0, 220))
	else
		dxDrawText("Elutasítás", textPos[1]+442.5, textPos[2]+200, x, y, tocolor(0, 0, 0, 220), 1, ticketFont, "left", "center", false, false, false, true)
		roundedBorder(textPos[1]+430, textPos[2], 100, 25, tocolor(0, 0, 0, 220))
	end
end

local cooldown = nil
function contractClickHandler(button, state)
	if(not isTimer(cooldown)) then
		if(button == "left" and state == "down") then
			if exports['cr_core']:isInSlot(textPos[1], textPos[2], 100, 25) then
				if(localPlayer:getData("char >> money") >= tonumber(contractData["price"])) then
					triggerServerEvent("completeContract", resourceRoot)
				else
					local syntax = exports['cr_core']:getServerSyntax(false, "error")
					outputChatBox(syntax.."Nincs elegendő pénzed az adásvételi teljesítéséhez.", 255, 255, 255, true)
					exports.cr_infobox:addBox("error", "Nincs elegendő pénzed az adásvételi teljesítéséhez.")
				end
				cooldown = setTimer(function() end, math.random(2, 5)*1000, 1)
			end
			
			if exports['cr_core']:isInSlot(textPos[1]+430, textPos[2], 100, 25) then
				triggerServerEvent("deleteContract2", resourceRoot)
				cooldown = setTimer(function() end, math.random(2, 5)*1000, 1)
			end
		end
	end
end

addEvent("showVehicleContractDetails", true)
addEventHandler("showVehicleContractDetails", resourceRoot, function() 
	contractData = localPlayer:getData("contract >> data")
	contractData["title"] = exports.cr_vehicle:getVehicleName(contractData["vehicle"]:getModel())
	addEventHandler("onClientRender", root, renderContractDetails)
	addEventHandler("onClientClick", root, contractClickHandler)
	start = getTickCount()
end)

addEvent("hideVehicleContractDetails", true)
addEventHandler("hideVehicleContractDetails", resourceRoot, function() 
	removeEventHandler("onClientRender", root, renderContractDetails)
	removeEventHandler("onClientClick", root, contractClickHandler)
	contractData = {}
end)