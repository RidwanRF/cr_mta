-- connection = exports['cr_mysql']:getConnection(getThisResource())
-- addEventHandler("onResourceStart", root, 
    -- function(startedRes)
        -- if getResourceName(startedRes) == "cr_mysql" then
            -- connection = exports['cr_mysql']:getConnection(getThisResource())
            -- restartResource(getThisResource())
        -- end
    -- end
-- )

-- Async:setPriority("high")
-- Async:setDebug(true)

-- local factionbankaccounts = {}
-- --[[
-- Tábla felépítése:
-- factionbankaccounts[faction_id] = {id, faction_id, account_number, pincode, owner_id, bank_ammount, is_frozen}
-- ]]

-- addEventHandler("onResourceStart", resourceRoot,
    -- function()
        -- dbQuery(function(query)
            -- local query, query_lines = dbPoll(query, 0)
            -- if query_lines > 0 then
                -- Async:foreach(query, function(row)
                    -- local id = tonumber(row["id"])
                    -- local faction_id = tonumber(row["faction_id"])
                    -- local account_number = tonumber(row["account_number"])
					-- local pincode = tonumber(row["pincode"])
					-- local owner_id = tonumber(row["owner_id"])
                    -- local bank_ammount = tonumber(row["bank_ammount"])
                    -- local is_frozen = tostring(row["is_frozen"])
					-- table.insert(factionbankaccounts[faction_id], id, faction_id, account_number, pincode, owner_id, bank_ammount, is_frozen)
                -- end)
            -- end   
			-- outputDebugString("[Success] Loading factionbankaccounts has finished successfuly. Loaded: " .. query_lines .. " bankaccounts!")
        -- end, connection, "SELECT * FROM `bankaccounts_faction`")
    -- end
-- )

-- function getfactionDatas(faction_id)
	-- if client and client.type == "player" then
		-- if sourceElement and sourceElement.type == "player" and sourceElement == client then
			-- if tonumber(faction_id) then
				
			-- end
		-- end
	-- end
-- end
-- addEvent("bank >> getFactionBankAccount", true)
-- addEventHandler("bank >> getFactionBankAccount", root, getfactionDatas)

--[[ local factions = {}
function getPlayerDatas(player)

	factions = exports['cr_faction']:getPlayerFactions(source)
	outputChatBox(#factions)
	
end
addCommandHandler("bankdatas",getPlayerDatas)]]