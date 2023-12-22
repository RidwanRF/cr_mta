function playSoundServer(element, url)
    triggerClientEvent(element, "playSoundClient", element, element, url)
end
addEvent("playSoundServer", true)
addEventHandler("playSoundServer", root, playSoundServer)

function setElementArmor(element, armor)
    setPedArmor(element, tonumber(armor))
end
addEvent("setElementArmor", true)
addEventHandler("setElementArmor", root, setElementArmor)

function setPlayerAlpha(element, alpha)
    setElementAlpha(element, tonumber(alpha))
end
addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", root, setPlayerAlpha)

function setPlayerCol(element, types)
    setElementCollisionsEnabled(element, types)
end
addEvent("setPlayerCol", true)
addEventHandler("setPlayerCol", root, setPlayerCol)
--[[
addEvent("glue_attach",true)
addEventHandler("glue_attach",root,
    function(e,x, y, z, rotX, rotY, rotZ)
        attachElements(source, e, x, y, z, rotX, rotY, rotZ)
    end
)

addEvent("glue_deatach",true)
addEventHandler("glue_deatach",root,
    function()
        detachElements(source)
    end
)
--]]

function toName(element, target, name)
	local color = exports['cr_core']:getServerColor(nil, true)
	local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
	if exports["cr_account"]:getNames(target,name) then
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		outputChatBox(syntax.."Sikeresen megváltoztattad "..color..jatekosName.."#ffffff nevét!",element,255,255,255,true)
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		outputChatBox(syntax.."#ffffffA karakter név már foglalt!",element,255,255,255,true)
	end
end
addEvent("toName",true)
addEventHandler("toName",root,toName)

-----|| PARANCSOK ||-----
--NEM tom kiírta ezt a fost de a kurva anyád!

function freeze_sc(player, cmd, target)
    if exports['cr_permission']:hasPermission(player, "freeze") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Admin ID/Név]",player,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(player, target)
            if target then
                local color = exports['cr_core']:getServerColor(nil, true)
                local adminName = getAdminName(player, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")

                local veh = getPedOccupiedVehicle(target)
                if (veh) then
                    setElementFrozen(veh, true)
                    toggleAllControls(target, false, true, false)
                    setElementData(target, "freeze", true)
                    outputChatBox(color..adminName.."#ffffff lefagysztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen lefagyasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                else
                    setElementFrozen(target, true)
                    setPedWeaponSlot(target, 0)
                    setElementData(target, "freeze", true)
                    outputChatBox(color..adminName.."#ffffff lefagysztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen lefagyasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."#ffffffNincs ilyen játékos!",player,0,0,0,true)
            end
        end
    end
end
addCommandHandler("freeze", freeze_sc)


function unfreeze_sc(player, cmd, target)
    if exports['cr_permission']:hasPermission(player, "unfreeze") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Admin ID/Név]",player,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(player, target)
            if target then
                local adminName = getAdminName(player, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local color = exports['cr_core']:getServerColor(nil, true)
                local veh = getPedOccupiedVehicle(target)
                if (veh) then
                    setElementFrozen(veh, false)
                    toggleAllControls(target, true, true, true)
                    setElementData(target, "freeze", false)
                    outputChatBox(color..adminName.."#ffffff felolvasztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen felolvasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                else
                    setElementFrozen(target, false)
                    setElementData(target, "freeze", false)
                    outputChatBox(color..adminName.."#ffffff felolvasztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen felolvasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."#ffffffNincs ilyen játékos!",player,0,0,0,true)
            end
        end
    end
end
addCommandHandler("unfreeze", unfreeze_sc)


--[[function player_Wasted ( ammo, attacker, weapon, bodypart )
    
    local time = getRealTime()
    local hours = time.hour
    local minutes = time.minute
    
    if minutes < 10 then
        minutes = "0" .. minutes
    end
    if hours < 10 then
        hours = "0" .. hours
    end
    
    local killog
    
    if (attacker) then
        if (getElementType(attacker) == "player") then 
            if getWeaponNameFromID(weapon) == "Explosion" then
                allapot = "Felrobbantotta"
            else
                allapot = "Fegyver: " .. getWeaponNameFromID(weapon)
            end
            killog = "[" .. hours .. ":" .. minutes .. "] ".. getPlayerName(attacker):gsub("_"," ")   .. " megölte " .. getPlayerName(source):gsub("_"," ") .. " játékost. (" .. allapot .. ")"
            if (bodypart) == 9 then
                killog = killog .. " (Fejbelövés)"
            elseif (bodypart) == 4 then
                killog = killog .. " (Seggbelőtték)"
            end
        elseif (getElementType(attacker) == "vehicle") then
            if getWeaponNameFromID(weapon) == "Rammed" then
                allapot = "Elütötte"
            elseif getWeaponNameFromID(weapon) == "Ranover" then
                allapot = "Ráállt DB"
            end
            killog = "[" .. hours .. ":" .. minutes .. "] " .. getPlayerName(getVehicleController(attacker)):gsub("_"," ") .. " elütötte " .. getPlayerName(source):gsub("_"," ") .. " játékost. (Járművel: " .. allapot .. ")"
        elseif (getElementType(attacker) == "ped") then 
            allapot = "( PET )"
            killog = "[" .. hours .. ":" .. minutes .. "] ".. (getElementData(attacker, "ped:name") or "Ismeretlen") .. " "..allapot .. " megölte " .. getPlayerName(source):gsub("_"," ") .. " játékost."
        end
    else
        killog = "[" .. hours .. ":" .. minutes .. "] " .. getPlayerName(source):gsub("_", " ") .. " meghalt."
    end
end
addEventHandler ( "onPlayerWasted", getRootElement(), player_Wasted )--]]

function getKillLog(player, cmd, target, skipTimer)
	if exports['cr_permission']:hasPermission(player, "getkilllog") then
		skipTimer = tonumber(skipTimer)
		if skipTimer == 1 then skipTimer = true else skipTimer = false end
		if not target then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
			outputChatBox(syntax .. "/" .. cmd .. " [target] [skipTimer (1 = igaz, más = hamis)]", player, 255, 255, 255, true)
			return
		end
		target = exports['cr_core']:findPlayer(player, target)
		if not target then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "A játékos nem található.", player, 255, 255, 255, true)
			return
		end
		local targetName = tostring(getElementData(target, "char >> name"):gsub("_", " ") or "Ismeretlen")
		local realTable = exports['cr_logs']:getLog(target, "Kills", "kill")
        if not realTable then 
            realTable = {}
        end
		local realTableCount = 0
        for k,v in pairs(realTable) do 
            realTableCount = 1 
            break   
        end
        
		if realTableCount == 0 then
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			outputChatBox(syntax .. "A játékosról nem található kill log.", player, 255, 255, 255, true)
			return
		end
		local syntax = exports['cr_core']:getServerSyntax(false, "info")
		outputChatBox(syntax .. "A játékosról a következő kill logok találhatóak:", player, 255, 255, 255, true)
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		if skipTimer then
			for id, value in pairs(realTable) do
				outputChatBox(syntax .. "Dátum: (" .. value[1] .. ") Szöveg: (" .. value[2] ..")", player, 255, 255, 255, true)
			end
		else
			local timerCount = 1
			for id, value in pairs(realTable) do
				setTimer(outputChatBox, timerCount * 500, 1, syntax .. "Dátum: (" .. value[1] .. ") Szöveg: (" .. value[2] ..")", player, 255, 255, 255, true)
				timerCount = timerCount + 1
			end
		end
	end
end
addCommandHandler("getkilllog",getKillLog)

addCommandHandler("asay", function(player, cmd, ...)
    if exports.cr_permission:hasPermission(player, cmd) then
        if ... then
            local msg = table.concat({...}, " ");
            local level = getElementData(player, "admin >> level") or 0    
            outputChatBox("#cc0000 ~-~ Felhívás ~-~#ffffff", root, 0, 0, 0, true);
            outputChatBox(getAdminColorByLevel(level, true) .. "[" .. getAdminTitle(player) .. " - " .. getAdminName(player, true) .. "]: #ffffff"..msg, root, 0, 0, 0, true);
        end
    end
end);