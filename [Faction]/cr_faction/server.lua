local connection = exports.cr_mysql;
local factions = {};
local faction_members = {};

addEventHandler("onResourceStart", resourceRoot, function()
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, k in pairs(query) do
                loadFaction(k["id"]);
            end
            outputDebugString(query_lines.." faction(s) loaded");
        end
    end, connection:requestConnection(), "SELECT id FROM factions");
end)

--local storage = {{["name"] = "duty1", ["rank"] = 1, ["items"] = {{12, 1}, {13, 1}, {15, 1}}, ["created"] = getRealTime().timestamp, ["skin"] = 12}};
--dbExec(connection:requestConnection(), "UPDATE factions SET dutys = ?", toJSON(storage))

function loadFaction(id)
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            for i, k in pairs(query) do
                factions[id] = {};
                faction_members[id] = {};

                loadFactionMembers(id);

                factions[id]["name"] = k["name"];
                factions[id]["id"] = k["id"];
                factions[id]["type"] = k["type"];
                factions[id]["money"] = k["money"];
                factions[id]["msg"] = k["msg"];
                factions[id]["created"] = k["created"];
                    
                factions[id]["ranks"] = {};
                factions[id]["storage"] = {};
                factions[id]["dutys"] = {};
                factions[id]["permissions"] = {};
                    
				local ranks = fromJSON(k["ranks"])
                for h, j in pairs(ranks) do
                    table.insert(factions[id]["ranks"], j);
					if(not factions[id]["permissions"][h]) then
						factions[id]["permissions"][h] = {}
					end
					local perm = fromJSON(k["permissions"])
					if(perm) then
						if(perm[h]) then
							factions[id]["permissions"][h] = perm[h]
						end
					end
                end
                    
				local storage = fromJSON(k["storage"]) or {}
                for h, j in pairs(storage) do
                    table.insert(factions[id]["storage"], j);
                end
                
                if fromJSON(k["dutys"]) then
					local dutys = fromJSON(k["dutys"])
                    for h, j in pairs(dutys) do
                        table.insert(factions[id]["dutys"], j);
                    end
                end
            end
        end
    end, connection:requestConnection(), "SELECT * FROM factions WHERE id = ?", id);
end

function loadFactionMembers(id)
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0);
        if query_lines > 0 then
            local co = coroutine.create(function()
                for i, k in pairs(query) do
                    faction_members[id][k["account"]] = {k["id"], k["account"], k["rank"], k["leader"], k["charname"], k["lastlogin"]};
                end
            end);
            coroutine.resume(co);
        end
    end, connection:requestConnection(), "SELECT faction_members.account as account, faction_members.id as id, faction_members.leader as leader, faction_members.rank as rank, characters.charname as charname, accounts.lastlogin as lastlogin FROM faction_members INNER JOIN characters ON faction_members.account = characters.id INNER JOIN accounts ON accounts.id = faction_members.account WHERE faction_members.faction = ?", id);
end

addEvent("server->getFactionDatas", true);
addEventHandler("server->getFactionDatas", getRootElement(), function(update)
    if client then
        triggerClientEvent(client, "client->getFactionDatas", client, factions, faction_members, update);
    end
end);

addEvent("server->updateDatas", true);
addEventHandler("server->updateDatas", getRootElement(), function(table)
    if client then
        local dbid = getElementData(client, "acc >> id") or 0;
        if dbid > 0 then
            for i, k in pairs(table) do
                if k[1] == "lastlogin" then
                    faction_members[k[2]][dbid][6] = k[3];
                elseif k[1] == "name" then
                    faction_members[k[2]][dbid][5] = k[3];
                end
            end
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true, true);
        end
    end
end);

addEvent("server->updateDutys", true);
addEventHandler("server->updateDutys", getRootElement(), function(faction, dutys, updatedIndex)
    if client then
        if factions[faction] then
            factions[faction]["dutys"] = dutys;
            dbExec(connection:requestConnection(), "UPDATE factions SET dutys = ? WHERE id = ?", toJSON(dutys), faction);
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true); 
        end
    end
end);

addEvent("server->changeRank", true);
addEventHandler("server->changeRank", getRootElement(), function(playerID, faction, rank)
    if client then
        local dbid = faction_members[faction][playerID][1];
        if dbid then
            dbExec(connection:requestConnection(), "UPDATE faction_members SET rank = ? WHERE id = ?", rank, dbid);
            faction_members[faction][playerID][3] = rank;
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);  
        end
    end
end);

addEvent("server->updateRankPermissions", true)
addEventHandler("server->updateRankPermissions", root, function(faction, permissions)
	if client then
        if factions[faction] then
            factions[faction]["permissions"] = permissions;
            dbExec(connection:requestConnection(), "UPDATE factions SET permissions = ? WHERE id = ?", toJSON(permissions), faction);
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
        end
    end
end)

addEvent("server->updateRankDatas", true);
addEventHandler("server->updateRankDatas", getRootElement(), function(faction, ranks, rank)
    if client then
        if factions[faction] then
            factions[faction]["ranks"] = ranks;
            dbExec(connection:requestConnection(), "UPDATE factions SET ranks = ? WHERE id = ?", toJSON(ranks), faction);
            if rank then
                dbQuery(function(query)
                    local query, query_lines = dbPoll(query, 0);
                    if query_lines > 0 then
                        for i, k in pairs(query) do
                            dbExec(connection:requestConnection(), "UPDATE faction_members SET rank = 1 WHERE id = ?", k["id"]);
                            faction_members[faction][k["account"]][3] = 1;
                        end
                    end
                end, connection:requestConnection(), "SELECT id, account FROM faction_members WHERE rank = ? AND faction = ?", rank, faction); 
            end
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
        end
    end
end);

addEvent("server->updateFactionMessage", true);
addEventHandler("server->updateFactionMessage", getRootElement(), function(faction, msg)
    if client then
        if factions[faction] then
            factions[faction]["msg"] = msg;
            dbExec(connection:requestConnection(), "UPDATE factions SET msg = ? WHERE id = ?", msg, faction);
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
        end
    end
end);

addEvent("server->changeLeader", true);
addEventHandler("server->changeLeader", getRootElement(), function(playerID, faction, leader)
    if client then
        local dbid = faction_members[faction][playerID][1];
        if dbid then
            dbExec(connection:requestConnection(), "UPDATE faction_members SET leader = ? WHERE id = ?", leader, dbid);
            faction_members[faction][playerID][4] = leader;
            triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
        end
    end
end);

addEvent("server->removeFromFaction", true);
addEventHandler("server->removeFromFaction", getRootElement(), function(playerID, faction)
    if client then
        local dbid = faction_members[faction][playerID][1];
        if dbid then
            local query = dbExec(connection:requestConnection(), "DELETE FROM faction_members WHERE id = ?", dbid);
            if query then
                faction_members[faction][playerID] = nil;
                triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
            end
        end
    end
end);

addEvent("server->addToFaction", true);
addEventHandler("server->addToFaction", getRootElement(), function(playerID, faction)
    if client then
        local state = faction_members[faction][playerID];
        if not state then
            dbExec(connection:requestConnection(), "INSERT INTO faction_members SET account = ?, faction = ?", playerID, faction);
            client2 = client;
            dbQuery(function(query)
                local query, query_lines = dbPoll(query, 0);
                if query_lines > 0 then
                    local co = coroutine.create(function()
                        for i, k in pairs(query) do
                            faction_members[faction][k["account"]] = {k["id"], k["account"], k["rank"], k["leader"], k["charname"], k["lastlogin"]};
                        end
                        
                        triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
                    end);
                    coroutine.resume(co);
                end
            end, connection:requestConnection(), "SELECT faction_members.account as account, faction_members.id as id, faction_members.leader as leader, faction_members.rank as rank, characters.charname as charname, accounts.lastlogin as lastlogin FROM faction_members INNER JOIN characters ON faction_members.account = characters.id INNER JOIN accounts ON accounts.id = faction_members.account WHERE faction_members.account = ?", playerID);
        else
            outputDebugString("ERROR: cr_faction:server:server->addToFaction:alreadyInFaction");
            outputChatBox("Keress fel egy fejlesztőt! Hiba: cr_faction:server:server->addToFaction:alreadyInFaction -> dbid: "..playerID.." faction: "..faction, client, 255, 0, 0, true);
        end
    end
end);

addEvent("server->giveKey", true);
addEventHandler("server->giveKey", getRootElement(), function(itemValue)
    if client then
        exports['cr_inventory']:giveItem(client, 16, itemValue);
       _triggerEvent("addBox", client, client, "info", "Adtál magadnak egy jármű kulcsot!");
    end
end);

addEvent("kickedFaction", true)
addEventHandler("kickedFaction", root, function(e)
	triggerClientEvent(e, "kickedFromFaction", e)
end)

addCommandHandler("createfaction", function(me, cmd, type, ...)
    if exports['cr_permission']:hasPermission(me, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        if not ... or not type then
            local code = "";
            for i, k in pairs(types) do
                if #code > 0 then
                    code = code..", (#3399ff"..i.."#FFFFFF): #ff9933"..k.."#FFFFFF";
                else
                    code = code.."(#3399ff"..i.."#FFFFFF): #ff9933"..k.."#FFFFFF";   
                end
            end
            outputChatBox(syntax.."Parancs használata: /"..cmd.." [típus] [név]", me, 255, 255, 255, true); 
            outputChatBox(syntax.."Típusok -> "..code, me, 255, 255, 255, true); 
        else
            local name = table.concat({...}, " ") or "?";
            type = tonumber(type) or 1;
            if name ~= "?" then
                if type > 0 then
                    dbQuery(function(query)
                        local query, query_lines = dbPoll(query, 0);
                        if query_lines > 0 then
                            outputChatBox(syntax.."Ez a frakció már létezik!", me, 255, 255, 255, true);
                            return
                        end
                    end, connection:requestConnection(), "SELECT name FROM factions WHERE name = ?", name);
                        
                    dbQuery(function(query)
                        local res, rows, last_id = dbPoll(query, 0);
                        if last_id > 0 then
                            outputChatBox(syntax.."Sikeresen létrehoztál egy frakciót "..name.." névvel!", me, 255, 255, 255, true);
                            loadFaction(last_id);
                        end
                    end, connection:requestConnection(), "INSERT INTO factions SET name = ?, type = ?", name, type);
                end
            end
        end
    end
end);

addCommandHandler("deletefaction", function(me, cmd, id)
    if exports['cr_permission']:hasPermission(me, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        if not id then
            outputChatBox(syntax.."Parancs használata: /"..cmd.." [id]", me, 255, 255, 255, true); 
        else
            id = tonumber(id) or 0;
            if id > 0 then
                if factions[id] then
                    local q1 = dbExec(connection:requestConnection(), "DELETE FROM factions WHERE id = ?", id);
                    dbExec(connection:requestConnection(), "DELETE FROM faction_members WHERE faction = ?", id);
                    if q1 then
                        outputChatBox(syntax.."Sikeresen töröltél egy frakciót! ("..factions[id]["name"]..")", me, 255, 255, 255, true);    
                    end
                    factions[id] = nil;
                    faction_members[id] = nil;
                else
                    outputChatBox(syntax.."Nincs ilyen frakció!", me, 255, 255, 255, true);  
                end
                    
                triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
            end
        end
    end
end);

addCommandHandler("showfactions", function(player, cmd)
    if exports['cr_permission']:hasPermission(player, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "warning");
        local syntax_info = exports['cr_core']:getServerSyntax(false, "info");
            
        outputChatBox(syntax_info.."Frakció lista: ", player, 255, 255, 255, true);  
        
        local count = 0;
        for i, k in pairs(factions) do
            outputChatBox(syntax.."ID: "..k["id"].." -> "..k["name"].." -> típus: "..k["type"], player, 255, 255, 255, true);
            count = count + 1;
        end
        
        outputChatBox(syntax_info.."Összesen: "..count.."db frakció", player, 255, 255, 255, true);
    end
end);

addCommandHandler("setfaction", function(me, cmd, player, faction, rank, leader)
    if exports['cr_permission']:hasPermission(me, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        if not player or not faction then
            outputChatBox(syntax.."Parancs használata: /"..cmd.." [Játékos] [frakcióID] [Rang] [leader(0=nem, 1=leader, 2=fő-leader)]", me, 255, 255, 255, true); 
        else
            local target = exports['cr_core']:findPlayer(me, player);
            if target then
                local playerID = getElementData(target, "acc >> id");
                faction = tonumber(faction) or 0;
                rank = tonumber(rank) or 1;
                leader = tonumber(leader) or 0;
                if factions[faction] then
                    if faction_members[faction][playerID] then
                        local id = faction_members[faction][playerID][1];
                                                    
                        if target ~= me then
                            local adminName = exports.cr_admin:getAdminName(me, true);
                            outputChatBox(syntax..adminName.." kivett téged egy frakcióból!", target, 255, 255, 255, true);
                            outputChatBox(syntax.."Kivetted a kiválasztott játékost a frakcióból!", me, 255, 255, 255, true);
                        else
                            outputChatBox(syntax.."Kivetted magad a kiválasztott frakcióból!", me, 255, 255, 255, true);
                        end
                            
                        faction_members[faction][playerID] = nil;
                        dbExec(connection:requestConnection(), "DELETE FROM faction_members WHERE id = ?", id);
                        triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
                    else
                        if rank <= 10 and rank >= 0 then
                            dbQuery(function(qh)
                                local res, rows, last_id = dbPoll(qh, 0);
                                if last_id > 0 then
                                    faction_members[faction][playerID] = {last_id, playerID, rank, leader, getElementData(target, "char >> name"), "?"};
                                    if target ~= me then
                                        local adminName = exports.cr_admin:getAdminName(me, true);
                                        outputChatBox(syntax..adminName.." berakott téged egy frakcióba!", target, 255, 255, 255, true);
                                        outputChatBox(syntax.."Beraktad a kiválasztott játékost egy frakcióba!", me, 255, 255, 255, true);
                                    else
                                        outputChatBox(syntax.."Beraktad magad a kiválasztott frakcióba!", me, 255, 255, 255, true);
                                    end
                                            
                                    triggerClientEvent(root, "client->getFactionDatas", root, factions, faction_members, true);
                                end
                            end, connection:requestConnection(), "INSERT INTO faction_members SET faction = ?, account = ?, rank = ?, leader = ?", faction, playerID, rank, leader);
                        else
                            outputChatBox(syntax.."rank <= 10 and rank >= 0", me, 255, 255, 255, true);  
                        end 
                    end
                else
                    outputChatBox(syntax.."Nincs ilyen frakció!", me, 255, 255, 255, true);  
                end
            else
                outputChatBox(syntax.."Nincs ilyen játékos!", me, 255, 255, 255, true);
            end
        end
    end
end);

addCommandHandler("setfactionrank", function(me, cmd, player, faction, rank)
    if exports['cr_permission']:hasPermission(me, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        if not player or not faction or not rank then
            outputChatBox(syntax.."Parancs használata: /"..cmd.." [Játékos] [frakcióID] [Rang]", me, 255, 255, 255, true);
        else
            local target = exports['cr_core']:findPlayer(me, player);
            if target then
                local playerID = getElementData(target, "acc >> id");
                faction = tonumber(faction) or 0;
                rank = tonumber(rank) or 1;
                if factions[faction] then
                    if faction_members[faction][playerID] then
                        if leader > 1 or leader > 0 then
                            outputChatBox(syntax.."leader > 1 or leader > 0", me, 255, 255, 255, true);
                            return
                        end
                        if rank <= 10 and rank >= 0 then
                            if faction_members[faction][playerID][3] == rank then
                                outputChatBox(syntax.."A játékos már ezen a rangon van!", me, 255, 255, 255, true);
                            else
                                local query = dbExec(connection:requestConnection(), "UPDATE faction_members SET rank = ? WHERE id = ?", rank, faction_members[faction][playerID][1]);
                                if query then
                                    if target ~= me then
                                        local adminName = exports.cr_admin:getAdminName(me, true);
                                        outputChatBox(syntax..adminName.." megváltoztatta a frakció rangodat! ("..faction_members[faction][playerID][3].." -> "..rank..")", target, 255, 255, 255, true);
                                        outputChatBox(syntax.."Megváltoztattad a kiválasztott játékos frakció rangját! ("..faction_members[faction][playerID][3].." -> "..rank..")", me, 255, 255, 255, true);
                                    else
                                        outputChatBox(syntax.."Megváltoztattad a frakció rangodat! ("..faction_members[faction][playerID][3].." -> "..rank..")", me, 255, 255, 255, true);  
                                    end
                                        
                                    faction_members[faction][playerID][3] = rank;
                                end
                            end
                        else
                            outputChatBox(syntax.."rank <= 10 and rank >= 0", me, 255, 255, 255, true);
                        end
                    else
                        outputChatBox(syntax.."A játékos nem a frakció tagja!", me, 255, 255, 255, true);
                    end
                else
                    outputChatBox(syntax.."Nincs ilyen frakció!", me, 255, 255, 255, true);
                end
            else
                outputChatBox(syntax.."Nincs ilyen játékos!", me, 255, 255, 255, true);    
            end
        end
    end
end);

addCommandHandler("setfactionleader", function(me, cmd, player, faction, leader)
    if exports['cr_permission']:hasPermission(me, cmd) then
        local color = exports['cr_core']:getServerColor(nil, true);
        local syntax = exports['cr_core']:getServerSyntax(false, "error");
        if not player or not faction or not leader then
            outputChatBox(syntax.."Parancs használata: /"..cmd.." [Játékos] [frakcióID] [Leader(0=nem, 1=igen)]", me, 255, 255, 255, true);
        else
            local target = exports['cr_core']:findPlayer(me, player);
            if target then
                local playerID = getElementData(target, "acc >> id");
                faction = tonumber(faction) or 0;
                leader = tonumber(leader) or 0;
                if factions[faction] then
                    if faction_members[faction][playerID] then
                        if leader <= 1 or leader >= 0 then
                            if faction_members[faction][playerID][4] == leader then
                                outputChatBox(syntax.."A játékos már ezen a leader jogon van!", me, 255, 255, 255, true);
                            else
                                local query = dbExec(connection:requestConnection(), "UPDATE faction_members SET leader = ? WHERE id = ?", leader, faction_members[faction][playerID][1]);
                                if query then
                                    if target ~= me then
                                        local adminName = exports.cr_admin:getAdminName(me, true);
                                        outputChatBox(syntax..adminName.." megváltoztatta a leader jogodat egy frakcióban! ("..faction_members[faction][playerID][4].." -> "..leader..")", target, 255, 255, 255, true);
                                        outputChatBox(syntax.."Megváltoztattad a kiválasztott játékos leader jogát! ("..faction_members[faction][playerID][4].." -> "..rank..")", me, 255, 255, 255, true);
                                    else
                                        outputChatBox(syntax.."Megváltoztattad a leader jogodat egy frakcióban! ("..faction_members[faction][playerID][4].." -> "..leader..")", me, 255, 255, 255, true);  
                                    end
                                        
                                    faction_members[faction][playerID][4] = leader;
									-- triggerClientEvent(target, "client->getFactionDatas", target, factions, faction_members, update);
									exports.cr_logs:addLog(player, _, "faction", "Frakció leader kinevezés/megvonás. (Frakció: "..faction..", Típus: "..leader..")")
                                end
                            end
                        else
                            outputChatBox(syntax.."leader > 1 or leader > 0", me, 255, 255, 255, true);
                        end
                    else
                        outputChatBox(syntax.."A játékos nem a frakció tagja!", me, 255, 255, 255, true);
                    end
                else
                    outputChatBox(syntax.."Nincs ilyen frakció!", me, 255, 255, 255, true);
                end
            else
                outputChatBox(syntax.."Nincs ilyen játékos!", me, 255, 255, 255, true);    
            end
        end
    end
end);

local depositNPCS = {};

addEventHandler("onResourceStart", resourceRoot, function() 
	dbQuery(function(query)
		local query, query_lines = dbPoll(query, 0)
		if(query_lines > 0) then
			for i, v in pairs(query) do
				local data = fromJSON(v["data"])
				if(data) then
					local id = tonumber(v["id"])
					local x, y, z, r = unpack(data["pos"])
					local name = data["name"]
					local skin = tonumber(data["skin"])
					local npc = createPed(skin, x, y, z, r)
					local faction = tonumber(data["faction"])
					depositNPCS[id] = npc
					npc:setData("faction >> depositID", id)
					npc:setData("faction >> depositFaction", faction)
					npc:setData("faction >> depositNPC", true)
					npc:setData("ped.name", name)
					npc:setData("ped.type", "Raktáros #"..id)
					npc:setData("char >> noDamage", true)
				end
			end
		end
	end, connection:requestConnection(), "SELECT * FROM factiondeposit")
end)

addCommandHandler("createdepositnpc", function(player, cmd, faction, skin, name) 
	local color = exports['cr_core']:getServerColor(nil, true);
    local error = exports['cr_core']:getServerSyntax(false, "error");
    local success = exports['cr_core']:getServerSyntax(false, "success");
	faction, skin = tonumber(faction), tonumber(skin), tostring(name)
	if(faction and skin and name) then
		local pos = player:getPosition()
		local rot = player:getRotation()
		local data = {["pos"] = {pos.x, pos.y, pos.z, rot.z}, ["name"] = name, ["skin"] = skin, ["faction"] = faction}
		local _, _, i = dbPoll(dbQuery(connection:requestConnection(), "INSERT INTO factiondeposit SET data = ?", toJSON(data)), -1)
		setTimer(function(p, id, f, n, s, po, ro) 
			local npc = createPed(skin, po.x, po.y, po.z, ro.z)
			depositNPCS[id] = npc
			npc:setData("faction >> depositID", id)
			npc:setData("faction >> depositFaction", f)
			npc:setData("faction >> depositNPC", true)
			npc:setData("ped.name", n)
			npc:setData("ped.type", "Raktáros #"..id)
			npc:setData("char >> noDamage", true)
			p:outputChat(success.."Raktáros NPC létrehozva.", 255, 255, 255, true)
			exports.cr_logs:addLog(player, _, "faction", "Frakció raktáros NPC létrehozás. (Frakció: "..faction..", Skin: "..skin..", Név: "..name..", ID: "..id..")")
		end, 250, 1, player, i, faction, name, skin, pos, rot)
	else
		player:outputChat(error.."Használat: /"..cmd.." [Frakció ID] [Skin] [Név]", 255, 255, 255, true)
	end
end)

addCommandHandler("deletedepositnpc", function(player, cmd, id) 
	local color = exports['cr_core']:getServerColor(nil, true);
    local error = exports['cr_core']:getServerSyntax(false, "error");
    local success = exports['cr_core']:getServerSyntax(false, "success");
	id = tonumber(id)
	if(id) then
		if(depositNPCS[id]) then
			dbExec(connection:requestConnection(), "DELETE FROM factiondeposit WHERE id = ?", id)
			depositNPCS[id]:destroy()
			depositNPCS[id] = nil
			player:outputChat(success.."NPC törölve.", 255, 255, 255, true)
			exports.cr_logs:addLog(player, _, "faction", "Frakció raktáros NPC törlés. (NPC: "..id..")")
		else
			player:outputChat(error.."Nem létező NPC.", 255, 255, 255, true)
		end
	else
		player:outputChat(error.."Használat: /"..cmd.." [ID]", 255, 255, 255, true)
	end
end)

function isItemInStorage(faction, item)
	for i, v in pairs(factions[faction]["storage"]) do
		if(v["item"] == item) then
			return true, i
		end
	end
end

addEvent("removeStorageItem", true)
function removeStorageItem(player, faction, item, all)
	faction, item, all = tonumber(faction), tonumber(item), all and true or all == nil and false or not all and false
	if(isItemInStorage(faction, item)) then
		for i, v in pairs(factions[faction]["storage"]) do
			if(v["item"] == item) then
				if(all) then
					table.remove(factions[faction]["storage"], i)
					exports.cr_logs:addLog(player, _, "faction", "Frakció raktár tárgy törlés. (Frakció: "..faction..", Tárgy: "..item..")")
				else
					factions[faction]["storage"][i]["quantities"][1][3] = factions[faction]["storage"][i]["quantities"][1][3]-1
					if(factions[faction]["storage"][i]["quantities"][1][3] == 0) then
						table.remove(factions[faction]["storage"][i]["quantities"], 1)
					end
				end
			end
		end
	end
	dbExec(connection:requestConnection(), "UPDATE factions SET storage = ? WHERE id = ?", toJSON(factions[faction]["storage"]), factions[faction]["id"])
	-- if(player:getData("factionPanel")) then
		triggerClientEvent(player, "client->getFactionDatas", player, factions, faction_members, update)
	-- end
end
addEventHandler("removeStorageItem", getRootElement(), removeStorageItem)


addEvent("depositItemToFaction", true)
function depositItemToFaction(player, faction, item, value, count, status)
	faction, item, value, count = tonumber(faction), tonumber(item), tonumber(value), tonumber(count)
	local bool, index = isItemInStorage(faction, item)
	if(not bool) then
		table.insert(factions[faction]["storage"], {["item"] = item, ["quantities"] = {}})
	end
	bool, index = isItemInStorage(faction, item)
	table.insert(factions[faction]["storage"][index]["quantities"], {item, value, count, status})
	dbExec(connection:requestConnection(), "UPDATE factions SET storage = ? WHERE id = ?", toJSON(factions[faction]["storage"]), factions[faction]["id"])
	exports.cr_logs:addLog(player, _, "faction", "Frakció raktár hozzáadás. (Frakció: "..faction..", Tárgy: "..item..", Érték: "..value..", Darabszám: "..count..", Status: "..status..")")
	-- if(player:getData("factionPanel")) then
		triggerClientEvent(player, "client->getFactionDatas", player, factions, faction_members, update)
	-- end
end
addEventHandler("depositItemToFaction", getRootElement(), depositItemToFaction)

addEvent("giveDutyItems", true)
addEventHandler("giveDutyItems", getRootElement(), function(player, faction, duty)
	faction, duty = tonumber(faction), tostring(duty)
	for i, v in pairs(factions[faction]["dutys"]) do
		if(v["name"] == duty) then
			for index, k in pairs(v["items"]) do
				local given = 0
				local quantity = k["quantity"]
				for ind, val in pairs(factions[faction]["storage"]) do
					if(tonumber(val["item"]) == k["itemDetails"][1]) then
						for i, v in pairs(val["quantities"]) do
							if(given < quantity) then
								local item, value, count, status = unpack(v)
								if(count <= quantity-given) then
									exports.cr_inventory:giveItem(player, item, value, count, status, 1, 0)
									table.remove(val["quantities"], i)
									given = given+count
								else
									exports.cr_inventory:giveItem(player, item, value, quantity-given, status, 1, 0)
									factions[faction]["storage"][ind]["quantities"][i][3] = count-(quantity-given)
									given = quantity
								end
							end
						end
					end
				end
			end
		end
	end
	exports.cr_logs:addLog(player, _, "faction", "Frakció duty tárgyak igénylése. (Frakció: "..faction..", Duty: "..duty..")")
	dbExec(connection:requestConnection(), "UPDATE factions SET storage = ? WHERE id = ?", toJSON(factions[faction]["storage"]), factions[faction]["id"])
	triggerClientEvent(player, "client->getFactionDatas", player, factions, faction_members, update)
end)

addEvent("removeDutyItems", true)
addEventHandler("removeDutyItems", getRootElement(), function(player, faction)
	for i=1, 3 do
		local items = exports.cr_inventory:getItems(player, i);
		for slot, data in pairs(items) do
			local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data);
			if dutyitem == 1 then
				exports.cr_inventory:deleteItem(player, slot, itemid);
				depositItemToFaction(player, faction, itemid, value, count, status)
				exports.cr_logs:addLog(player, _, "faction", "Frakció duty tárgyak visszaadása. (Frakció: "..faction..")")
			end
		end
	end
end)

local moneySpamTimers = {};
addEvent("changeFactionMoney", true)
addEventHandler("changeFactionMoney", getRootElement(), function(player, faction, mode, money) 
	if(not isTimer(moneySpamTimers[faction])) then
		faction, money = tonumber(faction), tonumber(money)
		local fMoney = factions[faction]["money"]
		local pMoney = player:getData("char >> money")
		local change = false
		if(mode) then
			if(fMoney-money >= 0) then
				player:setData("char >> money", pMoney+money)
				fMoney = fMoney-money
				change = true
			else
				_triggerEvent("addBox", player, player, "error", "Nincs a frakcióban elegendő pénz!");
			end
		else
			if(pMoney-money >= 0) then
				player:setData("char >> money", pMoney-money)
				fMoney = fMoney+money
				change = true
			else
				_triggerEvent("addBox", player, player, "error", "Nincs nálad elegendő pénz!");
			end
		end
		if(change) then
			factions[faction]["money"] = fMoney
			dbExec(connection:requestConnection(), "UPDATE factions SET money = ? WHERE id = ?", fMoney, faction)
			_triggerEvent("addBox", player, player, "success", "Frakció pénz módosítva a(z) "..factions[faction]["name"].." frakcióban!");
			exports.cr_logs:addLog(player, _, "faction", "Frakció pénz változtatása. (Frakció: "..faction..", Tranzakció: "..(mode and "Kifizetés" or "Befizetés")..", Összeg: "..money..")")
			triggerClientEvent(player, "client->getFactionDatas", player, factions, faction_members, update)
		end
		moneySpamTimers[faction] = setTimer(function() end, 1500, 1)
	end
end)

function minusFactionMoney(player, faction, money)
	faction, money = tonumber(faction), tonumber(money)
	if(factions[faction]["money"]-money >= 0) then
		factions[faction]["money"] = factions[faction]["money"]-money
		dbExec(connection:requestConnection(), "UPDATE factions SET money = ? WHERE id = ?", factions[faction]["money"], faction)
		exports.cr_logs:addLog(player, _, "faction", "Frakció pénz változtatása. (Frakció: "..faction..", Tranzakció: Kifizetés, Összeg: "..money..")")
		return true
	end
	return false
end