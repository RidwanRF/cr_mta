local lastClickTick = -1500

function payCommand(cmd, target, amount)
    local player = localPlayer
	if not target or not tonumber(amount) then 
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [target] [összeg]", 255,255,255,true)
        return	
	end
	if lastClickTick + 1500 > getTickCount() then
		return
	end
	lastClickTick = getTickCount()	
	
	local target = exports['cr_core']:findPlayer(player, target)
	if target then
		local localplayer_money = player:getData("char >> money")
		local target_money = target:getData("char >> money")
		local amount = math.floor(math.abs(tonumber(amount)))
		
		local x,y,z = getElementPosition(player)
		local tx,ty,tz = getElementPosition(target)
		local local_dim = getElementDimension(player)
		local local_int = getElementInterior(player)
		local target_dim = getElementDimension(target)
		local target_int = getElementInterior(target)
		local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
		
        if isTimer(payTimer) then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Folyamatban van 1 tranzakciód!", 255,255,255,true)
            return
        elseif exports['cr_network']:getNetworkStatus() then
            return
        elseif player == target then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Hogy akarnál már magadnak pénzt adni?!", 255,255,255,true)
			return 
		elseif amount > localplayer_money then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Túl nagy összeget szeretnél átadni. Előbb rendelkezz a kívánt összeggel!", 255,255,255,true)
			return 	
		elseif distance > 2 then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Túl messze van tőled a célpont!", 255,255,255,true)
			return 	
		elseif local_dim ~= target_dim then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Nem egy dimenzióban tartózkodtok!", 255,255,255,true)
			return 			
		elseif local_int ~= target_int then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "Nem egy interiorban tartózkodtok!", 255,255,255,true)
			return 			
		else
            
            local player_old_money = getElementData(player,"char >> money")
			local target_old_money = getElementData(target,"char >> money")
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "A pénz hamarosan átadásra kerül.",255,255,255,true)
            
            payTimer = setTimer(
                function()
                    if player_old_money ~= getElementData(player,"char >> money") then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
			            outputChatBox(syntax .. "A vagyonod változott így a tranzakció meghiúsult!", 255,255,255,true)
                        return
                    elseif target_old_money ~= getElementData(target,"char >> money") then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
			            outputChatBox(syntax .. "A célpont vagyona változott így a tranzakció meghiúsult!", 255,255,255,true)
                        return
                    end
                    
                    local x,y,z = getElementPosition(player)
                    local tx,ty,tz = getElementPosition(target)
                    local local_dim = getElementDimension(player)
                    local local_int = getElementInterior(player)
                    local target_dim = getElementDimension(target)
                    local target_int = getElementInterior(target)
                    local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

                    if exports['cr_network']:getNetworkStatus() then
                        return
                    elseif player == target then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Hogy akarnál már magadnak pénzt adni?!", 255,255,255,true)
                        return
                    elseif amount > player_old_money then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Túl nagy összeget szeretnél átadni. Előbb rendelkezz a kívánt összeggel!", 255,255,255,true)
                        return 	
                    elseif distance > 2 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Túl messze van tőled a célpont!", 255,255,255,true)
                        return 	
                    elseif local_dim ~= target_dim then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Nem egy dimenzióban tartózkodtok!", 255,255,255,true)
                        return 			
                    elseif local_int ~= target_int then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Nem egy interiorban tartózkodtok!", 255,255,255,true)
                        return 	
                    end
                    
                    exports['cr_core']:setElementData(player, "char >> money", player_old_money - amount)
                    exports['cr_core']:setElementData(target, "char >> money", target_old_money + amount)

                    local player_name = exports['cr_admin']:getAdminName(player, false) --player:getName():gsub("_"," ")
                    local target_name = exports['cr_admin']:getAdminName(target, false) --target:getName():gsub("_"," ")

                    local syntax = exports['cr_core']:getServerSyntax(false, "success")
                    outputChatBox(syntax.."Sikeresen pénzt adtál neki: #ff9933"..target_name.."#ffffff. (Összeg: #ff9933$"..amount.."#ffffff)", 255,255,255,true)			
                    triggerServerEvent("outputChatBox", localPlayer, target, syntax ..player_name.." sikeresen pénzt adott a kezedbe! (Összeg: #ff9933$"..amount.."#ffffff)", target, 255,255,255,true)
                    
                    exports['cr_chat']:createMessage(localPlayer, "átad $"..amount.."-t "..target_name.."-nak/nek", 1)

                    if not player:isInVehicle() then
                        player:setData("forceAnimation", {"dealer","shop_pay",-1,false,true,true,false})	
                        setTimer(setElementData, 3500, 1, player, "forceAnimation", {"", ""})
                    end			
                    if not target:isInVehicle() then
                        target:setData("forceAnimation", {"dealer","shop_pay",-1,false,true,true,false})	
                        setTimer(setElementData, 3500, 1, target, "forceAnimation", {"", ""})
                    end
                end, 1000, 1
            )
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		outputChatBox(syntax .. "Ez a játékos nem található meg a szerveren!", 255,255,255,true)
		return 		
	end
end
addCommandHandler("pay", payCommand)