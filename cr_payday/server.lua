local spamTimers = {};

addEvent("payDay", true)
function payDay(player, vehs, interiors)
	local relief = minimumSalary
	local salary = 0
	local multiplier = 0.01
	local vehicleTaxes = 0
	local interiorTaxes = 0
	for i, v in pairs(vehs) do
		vehicleTaxes = vehicleTaxes+exports.cr_carshop:getVehiclePrice(v, 1)
	end
	vehicleTaxes = vehicleTaxes*multiplier
	for i, v in pairs(interiors) do
		interiorTaxes = interiorTaxes+tonumber(v:getData("interior >> cost"))
	end
	interiorTaxes = interiorTaxes*multiplier
	for i, v in pairs(exports.cr_faction:getPlayerFactions(player)) do
		local rank = exports.cr_faction:getPlayerFactionRank(player, i)
		local rankSalary = exports.cr_faction:getRankSalary(i, rank)
		local factionTransaction = exports.cr_faction:minusFactionMoney(player, i, rankSalary)
		if(factionTransaction) then
			salary = salary+rankSalary
		end
	end
	local totalSalary = relief+salary-vehicleTaxes-interiorTaxes
	triggerClientEvent(player, "showSumary", player, totalSalary, salary, relief, interiorTaxes, vehicleTaxes)
end
addEventHandler("payDay", root, payDay)

addEvent("payTotal", true)
addEventHandler("payTotal", root, function(player, total) 
	if(not isTimer(spamTimers[player:getData("acc >> id")])) then
		local totalSalary = tonumber(total)
		if(totalSalary < 0) then
			triggerEvent("bank >> setPlayerBankMoney", player, player, (-1)*totalSalary, "removeMoneyFromBank2")
		else
			triggerEvent("bank >> setPlayerBankMoney", player, player, totalSalary, "addMoneyToBank2")
		end
		spamTimers[player:getData("acc >> id")] = setTimer(function() end, 15000, 1)
	end
end)