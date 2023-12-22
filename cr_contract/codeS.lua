connection = exports['cr_mysql']:getConnection(getThisResource());

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

addEvent("sendVehicleContract", true)
addEventHandler("sendVehicleContract", resourceRoot, function(target, veh, price) 
	local player = client
	local timer = setTimer(function(p, t) 
		local p_data = p:getData("contract >> data")
		local t_data = t:getData("contract >> data")
		if(p_data["opponent"] == t or t_data["sender"] == p) then
			p:setData("contract >> data", false)
			t:setData("contract >> data", false)
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			p:outputChat(syntax..t:getData("char >> name").." -nak/nek küldött adásvételi ajánlatod lejárt.", 255, 255, 255, true)
			t:outputChat(syntax..p:getData("char >> name").." adásvételi ajánlata lejárt.", 255, 255, 255, true)
			triggerClientEvent(t, "hideVehicleContractDetails", resourceRoot)
		end
	end, 60000, 1, player, target)
	local data = {["sender"] = player, ["opponent"] = target, ["vehicle"] = veh, ["price"] = math.floor(tonumber(price)), ["timer"] = timer}
	local syntax = exports['cr_core']:getServerSyntax(false, "info")
	target:outputChat(syntax..player:getData("char >> name").." adásvételi ajánlatot küldött!", 255, 255, 255, true)
	player:outputChat(syntax.."Adásvételi ajánlatot küldtél "..target:getData("char >> name").." -nak/nek. Érték: #008000$"..price, 255, 255, 255, true)
	player:outputChat(syntax.."Adásvételi törlése: /adasveteli törlés", 255, 255, 255, true)
	player:setData("contract >> data", data)
	target:setData("contract >> data", data)
	triggerClientEvent(target, "showVehicleContractDetails", resourceRoot)
end)

addEvent("deleteContract", true)
addEventHandler("deleteContract", resourceRoot, function() 
	local player = client
	local p_data = player:getData("contract >> data")
	if(p_data) then
		if(p_data["sender"] == player) then
			local target = p_data["opponent"]
			if(isTimer(p_data["timer"])) then
				p_data["timer"]:destroy()
			end
			player:setData("contract >> data", false)
			target:setData("contract >> data", false)
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			player:outputChat(syntax.."Az adásvételid törölve lett.", 255, 255, 255, true)
			target:outputChat(syntax..player:getData("char >> name").." adásvételije törölve lett", 255, 255, 255, true)
			triggerClientEvent(target, "hideVehicleContractDetails", resourceRoot)
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			player:outputChat(syntax.."Nincs aktív általad létrehozott adásvételid.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "info")
		player:outputChat(syntax.."Nincs aktív adásvételid.", 255, 255, 255, true)
	end
end)

addEvent("deleteContract2", true)
addEventHandler("deleteContract2", resourceRoot, function() 
	local player = client
	local data = player:getData("contract >> data")
	if(isTimer(data["timer"])) then
		data["timer"]:destroy()
	end
	for i, v in pairs(data) do
		if(i == "sender" or i == "opponent") then
			triggerClientEvent(v, "hideVehicleContractDetails", resourceRoot)
			v:setData("contract >> data", false)
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			if(v ~= player) then
				v:outputChat(syntax..player:getData("char >> name").." elutasította az ajánlatod.", 255, 255, 255, true)
				player:outputChat(syntax.."Elutasítottad "..v:getData("char >> name").." adásveteli ajánlatát.", 255, 255, 255, true)
			end
		end
	end
end)

addEvent("completeContract", true)
addEventHandler("completeContract", resourceRoot, function() 
	local player = client
	local data = player:getData("contract >> data")
	local money = tonumber(data["sender"]:getData("char >> money"))
	local money2 = tonumber(data["opponent"]:getData("char >> money"))
	data["sender"]:setData("char >> money", money+tonumber(data["price"]))
	data["opponent"]:setData("char >> money", money2-tonumber(data["price"]))
	local veh = data["vehicle"]
	exports.cr_vehicle:setVehicleOwner(player, veh, data["opponent"])
	if(isTimer(data["timer"])) then
		data["timer"]:destroy()
	end
	for i, v in pairs(data) do
		if(i == "sender" or i == "opponent") then
			triggerClientEvent(v, "hideVehicleContractDetails", resourceRoot)
			v:setData("contract >> data", false)
			local syntax = exports['cr_core']:getServerSyntax(false, "info")
			if(v ~= player) then
				v:outputChat(syntax..player:getData("char >> name").." elfogadta az ajánlatod.", 255, 255, 255, true)
				player:outputChat(syntax.."Elfogadtad "..v:getData("char >> name").." adásveteli ajánlatát.", 255, 255, 255, true)
			end
		end
	end
end)