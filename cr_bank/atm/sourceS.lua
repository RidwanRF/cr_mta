connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

function getServerSyntax(...)
    return exports['cr_core']:getServerSyntax(...)
end
function getServerColor(...)
    return exports['cr_core']:getServerColor(...)
end


local atmCache = {}
local spam = {}

local white = "#ffffff"

Async:setPriority("high")
Async:setDebug(true)

function loadAllATMFromDatabase()
    dbQuery(function(query)
    local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then        
	            Async:foreach(query, function(row)
	            	local id = tonumber(row["id"])
	            	local x = tonumber(row["x"])
	            	local y = tonumber(row["y"])
	            	local z = tonumber(row["z"])
	            	local rotx = tonumber(row["rotx"])
	            	local roty = tonumber(row["roty"])
	            	local rotz = tonumber(row["rotz"])
	            	local int = tonumber(row["int"])
	            	local dim = tonumber(row["dim"])
					local atmObject = createObject(2942, x, y, z, rotx, roty, rotz)
					setElementDimension(atmObject, dim)
					setElementInterior(atmObject, int)
					setElementData(atmObject, "bank >> id", tonumber(id))
					setElementData(atmObject, "bank >> isValidATM", true)
					atmCache[id] = atmObject
	            end) 
        end
		outputDebugString("[Success] Loading atms has finished successfuly. Loaded: " .. query_lines .. " atms!") 
    end, connection, "SELECT * FROM atms")
end
addEventHandler("onResourceStart", resourceRoot, loadAllATMFromDatabase)

function createATM(sourceElement, cmd)
    if exports['cr_permission']:hasPermission(sourceElement, "addatm") then
        local x,y,z = getElementPosition(sourceElement)
        z = z - 0.35
        local rot = sourceElement.rotation.z
        rot = rot - 180
        if rot <= 0 then
            rot = 360 + rot
        end
        --sourceElement.position.z = z + 1
        local dim = sourceElement.dimension
        local int = sourceElement.interior
        --local t = {x,y,z,rot,int,dim}
        
        sourceElement.position = Vector3(x, y,z+2)
        
        dbExec(connection, "INSERT INTO `atms` SET `x`=?,`y`=?,`z`=?,`rotx`=?,`roty`=?,`rotz`=?,`int`=?,`dim`=?", x,y,z,0,0,rot,int,dim)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    Async:foreach(query, 
                        function(row)
                            local id = tonumber(row["id"])
                            local x = tonumber(row["x"])
                            local y = tonumber(row["y"])
                            local z = tonumber(row["z"])
                            local rotx = tonumber(row["rotx"])
                            local roty = tonumber(row["roty"])
                            local rotz = tonumber(row["rotz"])
                            local int = tonumber(row["int"])
                            local dim = tonumber(row["dim"])
                            local atmObject = createObject(2942, x, y, z, rotx, roty, rotz)
                            setElementDimension(atmObject, dim)
                            setElementInterior(atmObject, int)
                            setElementData(atmObject, "bank >> id", tonumber(id))
                            setElementData(atmObject, "bank >> isValidATM", true)
                            atmCache[id] = atmObject
                            
                            local green = exports['cr_core']:getServerColor("orange", true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "success")
                            outputChatBox(syntax .. "Sikeresen létrehoztál egy atm-t (#"..green..id..white..")", sourceElement, 255,255,255,true)
                            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
                            local syntax = exports['cr_admin']:getAdminSyntax()
                            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." létrehozott egy atm-t (#"..green..id..white..")", 8)
                            
                            exports['cr_logs']:addLog(sourceElement, "ATM", "addatm", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " létrehozott egy atm-t (#"..id..")")
                            --dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)
                        end
                    )
                end
            end, 
        connection, "SELECT * FROM `atms` WHERE `x`=? AND `y`=? AND `z`=? AND `rotx`=? AND `roty`=? AND `rotz`=? AND `int`=? AND `dim`=?", x,y,z,0,0,rot,int,dim)
    end
end
addCommandHandler("addatm", createATM)
addCommandHandler("createatm", createATM)
addCommandHandler("makeatm", createATM)

function deleteATM(sourceElement, cmd, id)
    if exports['cr_permission']:hasPermission(sourceElement, "delatm") then
        if not id then
            local syntax = exports['cr_core']:getServerSyntax(nil, "warning")
            outputChatBox(syntax .. "/"..cmd.." [id]", sourceElement, 255,255,255,true)
            return
        end
        
        id = tonumber(id)
        if atmCache[id] then
            local obj = atmCache[id]
            --outputChatBox(t)
            dbExec(connection, "DELETE FROM `atms` WHERE `id`=?", tonumber(id))
            destroyElement(obj)
            atmCache[id] = nil
            local green = exports['cr_core']:getServerColor("orange", true)
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen töröltél egy atm-t (#"..green..id..white..")", sourceElement, 255,255,255,true)
            local aName = exports['cr_admin']:getAdminName(sourceElement, true)
            local syntax = exports['cr_admin']:getAdminSyntax()
            exports['cr_core']:sendMessageToAdmin(sourceElement, syntax..green..aName..white.." törölt egy atm-t (#"..green..id..white..")", 8)
            
            exports['cr_logs']:addLog(sourceElement, "ATM", (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement)) .. " törölt egy atm-t (#"..id..")")
            --dbExec(connection, "INSERT INTO `trash` SET `pos`=?", t)
        end
    end
end
addCommandHandler("delatm", deleteATM)
addCommandHandler("deleteatm", deleteATM)

function setPlayerATMMoney(player,newValue, state)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then
			if not player or not tonumber(newValue) or not tostring(state) then return end
			local lastClickTick = spam[player] or 0
			if lastClickTick + 1500 > getTickCount() then
				return
			end
			spam[player] = getTickCount()
			
			local ownerid = getElementData(player, "acc >> id")
			local old_hand_money = getElementData(player,"char >> money")
			local old_bank_money = getPlayerBankMoney(player)
			
			if state == "money-out" then
				newValueSet = tonumber(old_bank_money - newValue)
				newHandMoney = tonumber(old_hand_money + newValue)
			elseif state == "money-in" then
				newValueSet = tonumber(old_bank_money + newValue)
				newHandMoney = tonumber(old_hand_money - newValue)				
			end
			refreshPlayerMoney(player,newValueSet)
			setElementData(player,"char >> money", newHandMoney)
		end
	end
end
addEvent("atm >> setPlayerMoney", true)
addEventHandler("atm >> setPlayerMoney", root, setPlayerATMMoney)

-- function setBankMoney(player, newValue, state)
	-- if client and client.type == "player" then
		-- if player and player.type == "player" and player == client then
		-- local ownerid = getElementData(player, "acc >> id")
		-- local old_hand_money = getElementData(player,"char >> money")
		-- local oldValue = bankaccounts[ownerid][5]
		-- local newValueSet = 0
		-- local new_hand_money = 0
		
		-- local lastClickTick = spam[player] or 0
		-- if lastClickTick + 1500 > getTickCount() then
			-- return
		-- end
		-- spam[player] = getTickCount()		
		
			-- if player and tonumber(newValue) and tostring(state) then
				-- if state == "addMoneyToBank" then
					-- newValueSet = (oldValue + newValue)
					-- new_hand_money = (old_hand_money - newValue)
				-- elseif state == "removeMoneyFromBank" then
					-- newValueSet = (oldValue - newValue)
					-- new_hand_money = (old_hand_money + newValue)
				-- end
				-- dbExec(connection,"UPDATE bankaccounts SET bank_money = ? WHERE owner_id = ?",tonumber(newValueSet), ownerid)
				-- bankaccounts[ownerid][5] = newValueSet
				-- setElementData(player,"char >> money", new_hand_money)
				-- triggerClientEvent(player, "bank >> refreshBankMoneyData", player, newValueSet)
			-- end
		-- end
	-- end
-- end
-- addEvent("bank >> setPlayerBankMoney", true)
-- addEventHandler("bank >> setPlayerBankMoney", root, setBankMoney, true, "low")


-- function checkChange(dataName, oldValue)
	-- if (dataName == "bank >> isValidATM") then
		-- local newValue = true
		-- if oldValue then
			-- newValue = false
		-- else
			-- newValue = true
		-- end
		-- setElementData(source, dataName, newValue)
	-- end
-- end
-- addEventHandler("onElementDataChange", root, checkChange)

