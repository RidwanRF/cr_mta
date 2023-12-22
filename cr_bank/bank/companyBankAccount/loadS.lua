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

local companybankaccounts = {}
--[[
Tábla felépítése:
companybankaccounts[company_id] = {id, company_id, account_number, pincode, owner_id, bank_ammount, is_frozen}
]]

-- addEventHandler("onResourceStart", resourceRoot,
    -- function()
        -- dbQuery(function(query)
            -- local query, query_lines = dbPoll(query, 0)
            -- if query_lines > 0 then
                -- Async:foreach(query, function(row)
                    -- local id = tonumber(row["id"])
                    -- local company_id = tonumber(row["company_id"])
                    -- local account_number = tonumber(row["account_number"])
					-- local pincode = tonumber(row["pincode"])
					-- local owner_id = tonumber(row["owner_id"])
                    -- local bank_ammount = tonumber(row["bank_ammount"])
                    -- local is_frozen = tostring(row["is_frozen"])
					-- table.insert(companybankaccounts[company_id], id, company_id, account_number, pincode, owner_id, bank_ammount, is_frozen)
                -- end)
            -- end   
			-- outputDebugString("[Success] Loading companybankaccounts has finished successfuly. Loaded: " .. query_lines .. " bankaccounts!")
        -- end, connection, "SELECT * FROM `bankaccounts_company`")
    -- end
-- )

function getCompanyDatas(company_id)
	if client and client.type == "player" then
		if sourceElement and sourceElement.type == "player" and sourceElement == client then
			if tonumber(company_id) then
				
			end
		end
	end
end
addEvent("bank >> getCompanyBankAccount", true)
addEventHandler("bank >> getCompanyBankAccount", root, getCompanyDatas)