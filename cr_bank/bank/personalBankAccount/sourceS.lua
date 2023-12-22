connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

Async:setPriority("high")
Async:setDebug(true)

local spam = {}

local bankaccounts = {}
--[[
Tábla felépítése:
bankaccounts[owner_id] = {id, owner_id, account_number, pincode, bank_money, is_frozen}
]]

local ownerByNumber = {}

function getPlayerAccount(player)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then
			--local lastClickTick = spam[player] or 0
			--if lastClickTick + 500 > getTickCount() then
--				return
			--end
			--spam[player] = getTickCount()		
			local ownerid = getElementData(player, "acc >> id") or 0
			triggerClientEvent(player, "bank >> sendBankAccountData", player, bankaccounts[ownerid])
		end
    end
end
addEvent("bank >> getPlayerBankAccount", true)
addEventHandler("bank >> getPlayerBankAccount", root, getPlayerAccount)

addEventHandler("onResourceStart", resourceRoot,
    function()
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, function(row)
                    local id = tonumber(row["id"])
                    local owner_id = tonumber(row["owner_id"])
                    local account_number = tonumber(row["account_number"])
                    local bank_money = tonumber(row["bank_money"])
                    local pincode = tonumber(row["pincode"])
                    local is_frozen = tostring(row["is_frozen"])
                    bankaccounts[owner_id] = {id, owner_id, account_number, pincode, bank_money, is_frozen}
					ownerByNumber[account_number] = owner_id
                end)
            end   
			outputDebugString("[Success] Loading bankaccounts has finished successfuly. Loaded: " .. query_lines .. " bankaccounts!")
        end, connection, "SELECT * FROM `bankaccounts`")
    end
)

local number = ""
function createAccountNumber(player)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then
			-- local lastClickTick = spam[player] or 0
			-- if lastClickTick + 550 > getTickCount() then
				-- return
			-- end
			-- spam[player] = getTickCount()		
			local number = ""
			for i = 1, 12 do number = number .. math.random(0,9) end
			if tonumber(string.sub(number,1,1)) == 0 then
				number = ""
				for i = 1, 12 do number = number .. math.random(1,9) end
			end
			
			dbQuery(function(query)
				local query, query_lines = dbPoll(query, 0)
				if query_lines > 0 then
					Async:foreach(query, function(row)
						account_number = tonumber(row["account_number"])
						if account_number == number then
							number = ""
							for i = 1, 12 do number = number .. math.random(1,9) end
						end
					end) 
				end   
			end, connection, "SELECT `account_number` FROM `bankaccounts`")	
			triggerClientEvent(player, "bank >> sendBankAccountNumberData", player, number)
		end
	end
end
addEvent("bank >> getNewAccountNumber", true)
addEventHandler("bank >> getNewAccountNumber", root, createAccountNumber)

function insertNewAccountToSQL(player, number, pincode)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then	
			local lastClickTick = spam[player] or 0
			if lastClickTick + 550 > getTickCount() then
				return
			end
			spam[player] = getTickCount()
		
			local owner_id = getElementData(player, "acc >> id") or 0
			dbExec(connection, "INSERT INTO bankaccounts SET owner_id = ?, account_number = ?, bank_money = ?, pincode = ? ", tonumber(owner_id), tonumber(number), 0, tonumber(pincode))
			exports["cr_inventory"]:giveItem(player, 97, number, 1, 100, 0, 0, 0)
			dbQuery(function(query)
				local query, query_lines = dbPoll(query, 0)
				if query_lines > 0 then
					Async:foreach(query, function(row)
						local id = tonumber(row["id"])
                        local owner_id = tonumber(row["owner_id"])
                        local account_number = tonumber(row["account_number"])
                        local bank_money = tonumber(row["bank_money"])
                        local pincode = tonumber(row["pincode"])
                        local is_frozen = tostring(row["is_frozen"])
                        bankaccounts[owner_id] = {id, owner_id, account_number, pincode, bank_money, is_frozen}
                        ownerByNumber[account_number] = owner_id
                        triggerClientEvent(player, "bank >> sendBankAccountData", player, bankaccounts[owner_id])
					end) 
				end   
			end, connection, "SELECT * FROM `bankaccounts` WHERE `owner_id`=?",tonumber(owner_id))	
		end
	end
end
addEvent("bank >> createNewBankAccount", true)
addEventHandler("bank >> createNewBankAccount", root, insertNewAccountToSQL)

local logs = {}
--[[
Tábla felépítése:
logs[owner] = {id, log_type, owner, log_date, sender, host, amount, comment}

log_type = 1 Pénz felvétel, 2 Pénz berakás, 3 Utalás, 4 Adat módosítás
]]
addEventHandler("onResourceStart", resourceRoot,
function()
	dbQuery(function(query)
	local query, query_lines = dbPoll(query, 0)
		if query_lines > 0 then
			Async:foreach(query, function(row)
				id = tonumber(row["id"])
				log_type = tonumber(row["type"])
				owner = tonumber(row["log_owner"])
				log_date = tostring(row["date"])
				sender_vs_host = fromJSON(row["sender_vs_host"])
				sender, host = unpack(sender_vs_host)
				amount = tonumber(row["amount"])
				comment = tostring(row["comment"])
				if not logs[owner] then logs[owner] = {} end
				table.insert(logs[owner], {id, log_type, owner, log_date, sender, host, amount, comment})
			end) 
		end   
	outputDebugString("[Success] Loading bank_logs has finished successfuly. Loaded: " .. query_lines .. " logs!")	
	end, connection, "SELECT * FROM `bank_transferlogs`")	
end
)

function getPlayerBankMoney(player)
local ownerid = getElementData(player, "acc >> id")
	if tonumber(ownerid) > 0 then
		--local lastClickTick = spam[player] or 0
		--if lastClickTick + 550 > getTickCount() then
--			return
		--end
		--spam[player] = getTickCount()
		return bankaccounts[ownerid][5]
	end
end

function setBankMoney(player, newValue, state)
	local ownerid = getElementData(player, "acc >> id")
	local old_hand_money = getElementData(player,"char >> money")
	local oldValue = bankaccounts[ownerid][5]
	local newValueSet = 0
	local new_hand_money = 0
    local lastClickTick = spam[player] or 0
    if lastClickTick + 550 > getTickCount() then
        return
    end
    spam[player] = getTickCount()
	if player and tonumber(newValue) then
		if(tostring(state)) then
			if state == "addMoneyToBank" then
				newValueSet = (oldValue + newValue)
				new_hand_money = (old_hand_money - newValue)
            elseif state == "addMoneyToBank2" then
				newValueSet = (oldValue + newValue)
				--new_hand_money = (old_hand_m-ney - newValue)    
			elseif state == "removeMoneyFromBank" then
				newValueSet = (oldValue - newValue)
				new_hand_money = (old_hand_money + newValue)
            elseif state == "removeMoneyFromBank2" then
                newValueSet = (oldValue - newValue)
				--new_hand_money = (old_hand_money + newValue)
			end
			if(state ~= "removeMoneyFromBank2" and state ~= "addMoneyToBank2") then
				setElementData(player,"char >> money", new_hand_money)
			end
		else
			newValueSet = newValue
		end
		dbExec(connection,"UPDATE bankaccounts SET bank_money = ? WHERE owner_id = ?",tonumber(newValueSet), ownerid)
		bankaccounts[ownerid][5] = newValueSet
		triggerClientEvent(player, "bank >> refreshBankMoneyData", player, newValueSet)
	end
end
addEvent("bank >> setPlayerBankMoney", true)
addEventHandler("bank >> setPlayerBankMoney", root, setBankMoney, true, "low")

function refreshPlayerMoney(player, newValue)
	if player and tonumber(newValue) then
		local ownerid = getElementData(player, "acc >> id")
		bankaccounts[ownerid][5] = newValue
		dbExec(connection,"UPDATE bankaccounts SET bank_money = ? WHERE owner_id = ?",tonumber(newValue), ownerid)
		triggerClientEvent(player, "bank >> refreshBankMoneyData", player, newValue)
	end
end

function createLog(player, log_type, log_owner, sender, host, amount, comment)		
	if log_owner then
		local time = getRealTime()
		local year = 1900 + time.year
		local month = time.month
		local monthday = time.monthday
		local hours = time.hour - 1
		local minutes = time.minute
		
		if month <= 9 then
			month = "0"..month
		else
			month = month
		end	
		if monthday <= 9 then
			monthday = "0"..monthday
		else
			monthday = monthday
		end		
		if hours <= 9 then
			hours = "0"..hours
		else
			hours = hours
		end		
		if minutes <= 9 then
			minutes = "0"..minutes
		else
			minutes = minutes
		end
		
		sender_vs_host = toJSON({sender, host})
		local log_date = "["..year.."."..month.."."..monthday..". - "..hours..":"..minutes.."]"
		if host then host = host else host = "" end
		if not comment then  comment = "" end
		if not log_type then log_type = 1 end
		dbExec(connection,"INSERT INTO bank_transferlogs SET type = ?, log_owner = ?, date = ?, sender_vs_host = ?, amount = ?, comment = ?",log_type, log_owner, log_date, sender_vs_host, amount, comment)
		
		dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
			Async:foreach(query, function(row)
				last_insert_id = tonumber(row["id"])
				if not (logs[log_owner]) then logs[log_owner] = {} end
				table.insert(logs[log_owner], {last_insert_id, log_type, log_owner, log_date, sender, host, amount, comment})			
			end) 
			triggerClientEvent(player, "bank >> getPlayerNewLogs", player, logs[log_owner])	  	
		end, connection, "SELECT id FROM `bank_transferlogs` WHERE id = LAST_INSERT_ID()")	
	end
end
addEvent("bank >> createPlayerLog", true)
addEventHandler("bank >> createPlayerLog", root, createLog, true, "normal")

function getPlayerLogs(player)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then		
			local log_owner = getElementData(player, "acc >> id") or 0
			triggerClientEvent(player, "bank >> getPlayerNewLogs", player, logs[log_owner])
		end
    end
end
addEvent("bank >> getPlayerLogs", true)
addEventHandler("bank >> getPlayerLogs", root, getPlayerLogs)

function setNewPassword(player, newValue)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then	
			local lastClickTick = spam[player] or 0
			if lastClickTick + 550 > getTickCount() then
				return
			end
			spam[player] = getTickCount()	
			
			local owner_id = getElementData(player, "acc >> id") or 0
			if newValue and owner_id > 0 then
				local value = table.concat(newValue)
				bankaccounts[owner_id][4] = tonumber(value)
				dbExec(connection,"UPDATE bankaccounts SET pincode = ? WHERE owner_id = ?",tonumber(value), owner_id)
			end
		end
    end
end
addEvent("bank >> setNewPassword", true)
addEventHandler("bank >> setNewPassword", root, setNewPassword)


local foundedPlayerAccount = {}
function sendMoneyToPlayer(player, money, account_number, comment)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then	
			local lastClickTick = spam[player] or 0
			if lastClickTick + 550 > getTickCount() then
				return
			end
			spam[player] = getTickCount()	
			
			if tonumber(money) then	
				if searchBankAccount(account_number) then 
					local owner_id = getElementData(player, "acc >> id") or 0
					local newSenderValue = bankaccounts[owner_id][5] - money
					local foundedPlayerAccount = searchBankAccount(account_number)
					local newValue = foundedPlayerAccount[5] + money
					bankaccounts[owner_id][5] = newSenderValue
					foundedPlayerAccount[5] = newValue
					
					-- // Pénzek módosítása
					dbExec(connection,"UPDATE bankaccounts SET bank_money = ? WHERE owner_id = ?",tonumber(newSenderValue), owner_id)
					dbExec(connection,"UPDATE bankaccounts SET bank_money = ? WHERE owner_id = ?",tonumber(newValue), foundedPlayerAccount[2])
					
					-- // Triggerek leküldése
					triggerClientEvent(player, "bank >> sendBankAccountData", player, bankaccounts[owner_id])
					local target = getRandomPlayer()
					triggerClientEvent(target, "searchPlayerByAccID", target, bankaccounts[foundedPlayerAccount[2]])
				else
					exports["cr_infobox"]:addBox(player, "error", "A kiválasztott számlaszám nem létezik!")	
				end
			end
		end
	end
end
addEvent("bank >> sendMoneyToPlayer", true)
addEventHandler("bank >> sendMoneyToPlayer", root, sendMoneyToPlayer)

function resultPlayer(player, element)
	if client and client.type == "player" then
		if player and player.type == "player" and player == client then	
			if isElement(player) and isElement(element) then
				local accID = tonumber(element:getData("acc >> id"))
				if accID then
					triggerClientEvent(element, "bank >> sendBankAccountData", element, bankaccounts[accID])
				end
			end
		end
	end
end
addEvent("resultPlayer", true)
addEventHandler("resultPlayer", root, resultPlayer)

function searchBankAccount(account_number)
	if tonumber(account_number) then
		local owner = ownerByNumber[tonumber(account_number)]
		if owner then
			local foundedPlayerAccount = bankaccounts[owner]
			return foundedPlayerAccount
		end		
	end
end