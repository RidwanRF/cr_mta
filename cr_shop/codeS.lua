local mysql = exports.cr_mysql;
local npcs = {};
local objects = {};
local carts = {};

addEventHandler("onResourceStart", resourceRoot, function() 
	Async:setPriority("high")
	Async:setDebug(true)
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			Async:foreach(query, function(val)
				local id = tonumber(val["id"])
				local row = fromJSON(val["data"])
				if(row["type"] == 1) then
					loadNPC(id, row)
				elseif(row["type"] == 2) then
					loadObject(id, row)
				elseif(row["type"] == 3) then
					loadCart(id, row)
				end
			end)
		end
	end, mysql:requestConnection(), "SELECT * FROM shop")
end)

function nextID(type)
	local id = 0
	if(type == 1) then
		for i, v in pairs(npcs) do
			id = i
		end
		return id+1
	elseif(type == 2) then
		for i, v in pairs(objects) do
			id = i
		end
		return id+1
	elseif(type == 3) then
		for i, v in pairs(carts) do
			id = i
		end
		return id+1
	end
	return false
end

function loadNPC(dbid, row)
	dbid = tonumber(dbid)
	local id = tonumber(row["id"])
	local model = tonumber(row["model"])
	local x, y, z, r = unpack(row["pos"])
	local int, dim = unpack(row["world"])
	local name = tostring(row["name"])
	local npc = createPed(model, x, y, z, r)
	local col = createColSphere(x, y, z, 17)
	npc:setInterior(int)
	npc:setDimension(dim)
	col:setInterior(int)
	col:setDimension(dim)
	col:setData("shop >> dbid", dbid)
	col:setData("shop >> id", id)
	npc:setData("shop >> dbid", dbid)
	npc:setData("shop >> id", id)
	npc:setData("shop >> npc", true)
	npc:setData("ped.name", name)
	npc:setData("ped.type", "Eladó")
	npc:setData("char >> noDamage", true)
    npc.frozen = true
	npcs[id] = {npc, dbid, col}
end

function loadObject(dbid, row)
	dbid = tonumber(dbid)
	local id = tonumber(row["id"])
	local model = tonumber(row["model"])
	local x, y, z, rx, ry, rz = unpack(row["pos"])
	local int, dim = unpack(row["world"])
	local object = createObject(model, x, y, z-1, rx, ry, rz)
	object:setInterior(int)
	object:setDimension(dim)
	object:setData("shop >> dbid", dbid)
	object:setData("shop >> id", id)
	object:setData("shop >> shopObject", true)
	object:setData("shop >> pos", {x, y, z})
	object:setData("shop >> rot", {rx, ry, rz})
	object:setData("shop >> items", row["items"])
	objects[id] = {object, dbid}

end

function loadCart(dbid, row)
	dbid = tonumber(dbid)
	local id = tonumber(row["id"])
	local x, y, z, rx, ry, rz = unpack(row["pos"])
	local int, dim = unpack(row["world"])
	local cart = createObject(1885, x, y, z-1, rx, ry, rz)
	cart:setInterior(int)
	cart:setDimension(dim)
	cart:setData("shop >> dbid", dbid)
	cart:setData("shop >> id", id)
	cart:setData("shop >> shopBasket", true)
	if(not carts[id]) then
		carts[id] = {}
	end
	table.insert(carts[id], {cart, dbid})
end

addCommandHandler("createshopnpc", function(player, cmd, name)
	if(name) then
		local pos, rot, int, dim = player:getPosition(), player:getRotation(), player:getInterior(), player:getDimension()
		local newID = nextID(1)
		name = tostring(name)
		local data = {["id"] = newID, ["model"] = 41, ["type"] = 1, ["world"] = {int, dim}, ["name"] = name, ["pos"] = {pos.x, pos.y, pos.z, rot.z}}
		local _, _, dbid = dbPoll(dbQuery(mysql:requestConnection(), "INSERT INTO shop SET data = ?", toJSON(data)), 0)
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		player:outputChat(syntax.."Shop NPC sikeresen létrehozva! SHOP ID: "..newID, 255, 255, 255, true)
		setTimer(function(did, d) 
			loadNPC(did, d)
		end, 1000, 1, dbid, data)
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat: /"..cmd.." [Név]", 255, 255, 255, true)
	end
end)

addCommandHandler("deleteshopnpc", function(player, cmd, id)
	id = tonumber(id)
	if(id) then
		if(npcs[id]) then
			npcs[id][1]:destroy()
			local dbid = npcs[id][2]
			npcs[id] = nil
			dbExec(mysql:requestConnection(), "DELETE FROM shop WHERE id = ?", dbid)
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			player:outputChat(syntax.."NPC törölve! ID: "..id, 255, 255, 255, true)
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			player:outputChat(syntax.."Nincs ilyen npc.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat: /"..cmd.." [ID]", 255, 255, 255, true)
	end
end)

addCommandHandler("createshopobject", function(player, cmd, id)
	if(id) then
		local pos, rot, int, dim = player:getPosition(), player:getRotation(), player:getInterior(), player:getDimension()
		local newID = nextID(2)
		local data = {["id"] = newID, ["model"] = 1884, ["pos"] = {pos.x, pos.y, pos.z, rot.x, rot.y, rot.z}, ["world"] = {int, dim}, ["type"] = 2, ["shop"] = id, ["items"] = {}}
		local _, _, dbid = dbPoll(dbQuery(mysql:requestConnection(), "INSERT INTO shop SET data = ?", toJSON(data)), 0)
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		player:outputChat(syntax.."Új shop object létrehozva. ID: "..newID, 255, 255, 255, true)
		setTimer(function(did, d)
			loadObject(did, d)
		end, 2000, 1, dbid, data)
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [Shop ID]", 255, 255, 255, true)
	end
end)

addCommandHandler("addshopobjectitem", function(player, cmd, id, item, price, amount)
	id = tonumber(id)
	item = tonumber(item)
	price = tonumber(price)
	amount = tonumber(amount)
	if(not amount) then
		amount = 1
	end
	if(id and item and price) then
		price = math.floor(price)
		if(objects[id]) then
			local items = objects[id][1]:getData("shop >> items") or {}
			if(#items < 30) then
				table.insert(items, {item, price, amount})
				objects[id][1]:setData("shop >> items", items)
				local dbid = objects[id][2]
				local int, dim = objects[id][1]:getInterior(), objects[id][1]:getDimension()
				local pos, rot = objects[id][1]:getData("shop >> pos"), objects[id][1]:getData("shop >> rot")
				local data = {["id"] = id, ["model"] = 1884, ["pos"] = {pos[1], pos[2], pos[3], rot[1], rot[2], rot[3]}, ["world"] = {int, dim}, ["type"] = 2, ["shop"] = dbid, ["items"] = items}
				dbExec(mysql:requestConnection(), "UPDATE shop SET data = ? WHERE id = ?", toJSON(data), dbid)
				local syntax = exports['cr_core']:getServerSyntax(false, "success")
				player:outputChat(syntax.."Tárgy hozzáadva a polchoz. Polc id: "..id.." Tárgy id: "..item.." Ára: $"..price, 255, 255, 255, true)
			else
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				player:outputChat(syntax.."Ez a polc tele.", 255, 255, 255, true)
			end
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			player:outputChat(syntax.."Nem létező polc.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [Polc ID] [Item] [Ár] (Opcionális [Darabszám])", 255, 255, 255, true)
	end
end)

addCommandHandler("removeshopobjectitem", function(player, cmd, id, slot)
	id = tonumber(id)
	slot = tonumber(slot)
	if(id and slot) then
		if(slot > 0 and slot <= 6) then
			if(objects[id]) then
				local items = objects[id][1]:getData("shop >> items") or {}
				if(#items > 0) then
					if(items[slot]) then
						table.remove(items, slot)
						objects[id][1]:setData("shop >> items", items)
						local syntax = exports['cr_core']:getServerSyntax(false, "success")
						player:outputChat(syntax.."Tárgy a polcról törölve", 255, 255, 255, true)
						local dbid = objects[id][2]
						local int, dim = objects[id][1]:getInterior(), objects[id][1]:getDimension()
						local pos, rot = objects[id][1]:getData("shop >> pos"), objects[id][1]:getData("shop >> rot")
						local data = {["id"] = id, ["model"] = 1884, ["pos"] = {pos[1], pos[2], pos[3], rot[1], rot[2], rot[3]}, ["world"] = {int, dim}, ["type"] = 2, ["shop"] = dbid, ["items"] = items}
						dbExec(mysql:requestConnection(), "UPDATE shop SET data = ? WHERE id = ?", toJSON(data), id)
					else
						local syntax = exports['cr_core']:getServerSyntax(false, "error")
						player:outputChat(syntax.."Nincs ilyen tárgy a polcon.", 255, 255, 255, true)
					end
				else
					local syntax = exports['cr_core']:getServerSyntax(false, "error")
					player:outputChat(syntax.."Ez a polc üres.", 255, 255, 255, true)
				end
			else
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				player:outputChat(syntax.."Nem létező polc.", 255, 255, 255, true)
			end
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [Polc ID] [Item]", 255, 255, 255, true)
	end
end)

addCommandHandler("deleteshopobject", function(player, cmd, id)
	id = tonumber(id)
	if(id) then 
		if(objects[id]) then
			objects[id][1]:destroy()
			local dbid = objects[id][2]
			dbExec(mysql:requestConnection(), "DELETE FROM shop WHERE id = ?", dbid)
			objects[id] = nil
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			player:outputChat(syntax.."Kitöröltél egy shop objectet. ID: "..id, 255, 255, 255, true)
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			player:outputChat(syntax.."Nem létező object.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [ID]", 255, 255, 255, true)
	end
end)

addCommandHandler("createshopbasket", function(player, cmd, id)
	id = tonumber(id)
	if(id) then
		if(npcs[id]) then
			local newID = nextID(3)
			local pos, rot, int, dim = player:getPosition(), player:getRotation(), player:getInterior(), player:getDimension()
			local data = {["id"] = newID, ["type"] = 3, ["world"] = {int, dim}, ["pos"] = {pos.x, pos.y, pos.z, rot.x, rot.y, rot.z}, ["shop"] = id}
			local _, _, dbid = dbPoll(dbQuery(mysql:requestConnection(), "INSERT INTO shop SET data = ?", toJSON(data)), 0)
			local syntax = exports['cr_core']:getServerSyntax(false, "success")
			player:outputChat(syntax.."Új bevásárlókosár hozzáadva! BOLT ID: "..id.." Kosár id: "..newID..". Betöltés 2mp múlva.", 255, 255, 255, true)
			setTimer(function(did, d) 
				loadCart(did, d)
			end, 2000, 1, dbid, data)
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			player:outputChat(syntax.."Nem létező bolt.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [SHOP ID]", 255, 255, 255, true)
	end
end)

addCommandHandler("deleteshopbasket", function(player, cmd, id, p)
	id = tonumber(id)
	p = tonumber(p)
	if(id and p) then
		if(carts[id]) then
			if(carts[id][p] or p == 0) then
				for i, v in pairs(carts[id]) do
					if(i == p or p == 0) then
						if(p == 0) then
							v[1]:destroy()
							local dbid = carts[id][1][2]
							table.remove(carts[id], p)
							dbExec(mysql:requestConnection(), "DELETE FROM shop WHERE id = ?", dbid)
						else
							v[1]:destroy()
							local dbid = carts[id][p][2]
							table.remove(carts[id], p)
							dbExec(mysql:requestConnection(), "DELETE FROM shop WHERE id = ?", dbid)
						end
					end
				end
				local syntax = exports['cr_core']:getServerSyntax(false, "success")
				if(p == 0) then p = "Összes" end
				player:outputChat(syntax.."Kosár törölve. ID: "..id.." Kosár: "..p, 255, 255, 255, true)
			else
				local syntax = exports['cr_core']:getServerSyntax(false, "error")
				player:outputChat(syntax.."Nem létező kosár.", 255, 255, 255, true)
			end
		else
			local syntax = exports['cr_core']:getServerSyntax(false, "error")
			player:outputChat(syntax.."Nem létező kosár.", 255, 255, 255, true)
		end
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		player:outputChat(syntax.."Használat /"..cmd.." [Kosár ID] [Kosár, 0 = összes]", 255, 255, 255, true)
	end
end)

addEvent("pickupBasket", true)
addEventHandler("pickupBasket", resourceRoot, function() 
	local pos = client:getPosition()
	local element = createObject(324, pos.x, pos.y, pos.z)
	element:setDoubleSided(true)
	local attach = exports['cr_bone_attach']:attachElementToBone(element, client, 12, 0, 0, 0.05, 180, 0, 0)
	client:setData("shop >> basket", element)
	if(attach)then
		exports['cr_chat']:createMessage(client, "kézhez vesz egy bevásárló kosarat.", 1)
	else
		element:destroy()
	end
end)

addEvent("destroyBasket", true)
addEventHandler("destroyBasket", resourceRoot, function() 
	local element = client:getData("shop >> basket")
	exports['cr_bone_attach']:detachElementFromBone(element)
	element:destroy()
	exports['cr_chat']:createMessage(client, "elrak egy bevásárló kosarat.", 1)
	client:setData("shop >> basket", false)
end)

addEvent("buyItems", true)
addEventHandler("buyItems", resourceRoot, function(cart, method, price, totalweight) 
	local player = client
	totalweight, price, method = tonumber(totalweight), tonumber(price), tonumber(method)
	if(method == 1) then
		local money = player:getData("char >> money")
		if(money >= price) then
			if(exports.cr_inventory:getWeight(player, 1)+totalweight <= exports.cr_inventory:getMaxWeight(1)) then
				player:setData("char >> money", money-price)
				triggerClientEvent(player, "addBox", player, "success", "Sikeresen kifizetted a tételeket.")
				triggerClientEvent(player, "clearBasket", resourceRoot)
				Async:foreach(cart, function(item)
					exports.cr_inventory:giveItem(player, item[1], 0, item[3], 100, 0, 0)
				end)
			else
				triggerClientEvent(player, "addBox", player, "error", "Nem fér el több tárgy nálad.")
			end
		else
			triggerClientEvent(player, "addBox", player, "error", "Nincs elegendő pénzed, hogy kifizesd a tételeket.")
		end
	elseif(method == 2) then
		local money = exports.cr_bank:getPlayerBankMoney(player)
		if(money >= price) then
			exports.cr_bank:setBankMoney(player, money-price)
			triggerClientEvent(player, "clearBasket", resourceRoot)
			Async:foreach(cart, function(item)
				exports.cr_inventory:giveItem(player, item[1], 0, item[3], 100, 0, 0)
			end)
			triggerClientEvent(player, "addBox", player, "success", "Sikeresen kifizetted a tételeket.")
		else
			triggerClientEvent(player, "addBox", player, "error", "Nincs elegendő pénz a kártyádon.")
		end
	end
end)