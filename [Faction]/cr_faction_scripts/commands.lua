function sendRadio(cmd, ...)
	local error = exports.cr_core:getServerSyntax("Rádió", "error")
	local success = exports.cr_core:getServerSyntax("Rádió", "success")
	local info = exports.cr_core:getServerSyntax("Rádió", "info")
	local msg = table.concat({...}, " ")
	if(tostring(msg)) then
		if(localPlayer:getData("usingRadio")) then
			local freq = tonumber(localPlayer:getData("usingRadio.frekv"))
			local pos = localPlayer:getPosition()
			for i, v in pairs(getElementsByType("player")) do
				local pos2 = v:getPosition()
				local dist = getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
				if(v:getData("usingRadio") and v:getData("usingRadio.frekv") == freq) then
					local text = radioColor.."[Rádió - "..freq.." Hz] "..localPlayer:getData("char >> name"):gsub("_", " ").." mondja: #FFFFFF"..msg
					triggerServerEvent("sendMessageToPlayer", localPlayer, v, text, 255, 255, 255)
					triggerServerEvent("playRadioSound", localPlayer, v)
				elseif(dist <= 10) then
					if(isPedInVehicle(localPlayer)) then
						local veh = localPlayer:getOccupiedVehicle()
						local windowState = veh:getData("veh >> window2State") or veh:getData("veh >> window3State") or veh:getData("veh >> window4State") or veh:getData("veh >> window5State")
						if(not windowState) then
							local occupants = veh:getOccupants()
							for i, v in pairs(occupants) do
								if(v ~= localPlayer) then
									local text = "#FFFFFF[Rádióba] "..localPlayer:getData("char >> name"):gsub("_", " ").." mondja: #FFFFFF"..msg
									triggerServerEvent("sendMessageToPlayer", localPlayer, v, text, 255, 255, 255)
								end
							end
						else
							local text = "[Rádióba] "..localPlayer:getData("char >> name"):gsub("_", " ").." mondja: "..msg
							local r, g, b = 255, 255, 255
							if(dist <= 2) then
								r, g, b = 191, 191, 191
							elseif(dist <= 4) then
								r, g, b = 166, 166, 166
							elseif(dist <= 6) then	
								r, g, b = 115, 115, 115
							elseif(dist <= 8) then
								r, g, b = 95, 95, 95
							end
							triggerServerEvent("sendMessageToPlayer", localPlayer, v, text, r, g, b)
						end
					else
						if(not isPedInVehicle(v)) then
							local text = "[Rádióba] "..localPlayer:getData("char >> name"):gsub("_", " ").." mondja: "..msg
							local r, g, b = 255, 255, 255
							if(dist <= 2) then
								r, g, b = 191, 191, 191
							elseif(dist <= 4) then
								r, g, b = 166, 166, 166
							elseif(dist <= 6) then	
								r, g, b = 115, 115, 115
							elseif(dist <= 8) then
								r, g, b = 95, 95, 95
							end
							triggerServerEvent("sendMessageToPlayer", localPlayer, v, text, r, g, b)
						end
					end
				end
			end
		else
			outputChatBox(error.."Nincs aktív rádiód! A rádió bekapcsolásához, kattints a rádió tárgyra az inventoryban.", 255, 255, 255, true)
		end
	end
end
addCommandHandler("Rádió", sendRadio)
addCommandHandler("r", sendRadio)

local cooldown = nil;
addCommandHandler("tuneradio", function(cmd, freq)
	local error = exports.cr_core:getServerSyntax("Rádió", "error")
	local success = exports.cr_core:getServerSyntax("Rádió", "success")
	local info = exports.cr_core:getServerSyntax("Rádió", "info")
	freq = tonumber(freq)
	if(freq) then
		if(localPlayer:getData("usingRadio")) then
			if(freq >= 0 and freq <= 1000000) then
				if(not isTimer(cooldown)) then
					localPlayer:setData("usingRadio.frekv", freq)
					outputChatBox(success.."Rádió frekvenciája sikeresen beállítva: "..freq.." Hz", 255, 255, 255, true)
					cooldown = setTimer(function() end, 30000, 1)
				else
					local remaining, executesRemaining, totalExecutes = getTimerDetails(cooldown)
					outputChatBox(error.."Nem használhatod újra ezt a parancsot még "..math.floor(remaining/1000).." másodpercig.", 255, 255, 255, true)
				end
			else
				outputChatBox(error.."A frekvencia minimum 0 Hz, maximum 1 Mhz (1 millió).", 255, 255, 255, true)
			end
		else
			outputChatBox(error.."Nincs aktív rádiód! A rádió bekapcsolásához, kattints a rádió tárgyra az inventoryban.", 255, 255, 255, true)
		end
	else
		outputChatBox(error.."Használat: /"..cmd.." [Szám érték]", 255, 255, 255, true)
	end
end)

addCommandHandler("d", function(cmd, ...) 
	local error = exports.cr_core:getServerSyntax("Sürgősségi Rádió", "error")
	local success = exports.cr_core:getServerSyntax("Sürgősségi Rádió", "success")
	local info = exports.cr_core:getServerSyntax("Sürgősségi Rádió", "info")
	local dutyFaction = localPlayer:getData("player >> duty >> state") or false
	if(dutyFaction) then
		local faction = localPlayer:getData("player >> duty >> faction")
		local isLeader = exports.cr_faction:isPlayerLeader(localPlayer, faction)
		if(isLeader) then
			local msg = table.concat({...}, " ")
			if(tostring(msg)) then
				local factionName, rankName = exports.cr_faction:getFactionName(player, faction), exports.cr_faction:getRankName(faction, exports.cr_faction:getPlayerFactionRank(localPlayer, faction))
				for i, v in pairs(getElementsByType("player")) do
					local factions = exports.cr_faction:getPlayerFactions(v)
					for index, value in pairs(factions) do
						if(hasFactionPermission(cmd, value["id"])) then
							local text = dRadioColor.."[Sürgősségi rádió] "..radioColor..factionName.." - "..rankName.." : #FFFFFF"..localPlayer:getData("char >> name"):gsub("_", " ").." mondja: #FFFFFF"..msg
							triggerServerEvent("sendMessageToPlayer", localPlayer, v, text, 255, 255, 255)
							triggerServerEvent("playRadioSound", localPlayer, v)
						end
					end
				end
			end
		else
			outputChatBox(error.."Nincs jogod a sürgősségi rádió használatához.", 255, 255, 255, true)
		end
	else
		outputChatBox(error.."Nem vagy szolgálatban semmilyen frakcióban.", 255, 255, 255, true)
	end
end)

addCommandHandler("createdutypoint", function(cmd, faction)
	local error = exports.cr_core:getServerSyntax("Frakció", "error")
	local success = exports.cr_core:getServerSyntax("Frakció", "success")
	local info = exports.cr_core:getServerSyntax("Frakció", "info")
	if(faction) then
		faction = tonumber(faction)
		local factionName = exports.cr_faction:getFactionName(localPlayer, faction)
		triggerServerEvent("createDutyPoint", localPlayer, localPlayer, faction, factionName)
	else
		outputChatBox(error.."Használat: /"..cmd.." [Frakció]", 255, 255, 255, true)
	end
end)