addEvent("gameSettings->WalkStyle", true);
addEventHandler("gameSettings->WalkStyle", root, function(player, style)
	if client and client == player and style then
		player.walkingStyle = style;
	end
end);

addEvent("gameSettings->FightStyle", true);
addEventHandler("gameSettings->FightStyle", root, function(player, style)
	if client and client == player and style then
		setPedFightingStyle(player, style);
	end
end);

addEvent("dashboard->SlotBuy", true);
addEventHandler("dashboard->SlotBuy", root, function(player, type)
	if client and client == player and type then
		local now = getElementData(player, "char >> " .. type .. "Limit");

		setElementData(player, "char >> premiumPoints", getElementData(player, "char >> premiumPoints") - 100);
		setElementData(player, "char >> " .. type .. "Limit", now + 1);
	end
end);

local mysql = exports.cr_mysql;
local groups = {};

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(queryHandler)
		local startTick = getTickCount();

		local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

		if numAffectedRows > 0 then
			for key, value in pairs(result) do
                value["owner"] = tonumber(value["owner"]);

                local ownerName, ownerID = exports.cr_account:getCharacterNameByID(value["owner"]);
                ownerName = ownerName:gsub("_", " ");

				groups[value["id"]] = {
					["id"] = value["id"],
					["owner"] = value["owner"],
					["ownername"] = ownerName,
					["name"] = value["name"],
					["created"] = value["created"],
					["members"] = {},
				};    
			end
		end

		print("Loaded " .. numAffectedRows .. " group(s) in " .. getTickCount() - startTick .. " ms");
	end, mysql:requestConnection(), "SELECT * FROM groups");
        
    dbQuery(function(queryHandler)
        local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

        if numAffectedRows > 0 then
            for key, value in pairs(result) do
                local charId = value["id"];
                local groupId = value["charGroup"];
                        
                if groups[groupId] then
                    local ownerName, ownerID = exports.cr_account:getCharacterNameByID(charId);
                    ownerName = ownerName:gsub("_", " ");

                    table.insert(groups[groupId]["members"], {
                        ["charId"] = charId,
                        ["charName"] = ownerName,
                    });
                end
            end
        end
    end, mysql:requestConnection(), "SELECT id, charGroup FROM characters WHERE charGroup>0");    
end);

addEvent("group->Create", true);
addEventHandler("group->Create", root, function(player)
	local id = getElementData(player, "acc >> id");

	if client and client == player and id then
		dbExec(mysql:requestConnection(), "INSERT INTO groups SET owner=?", id);

		setTimer(function()
			dbQuery(function(queryHandler)
				local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

				if numAffectedRows > 0 then
					for key, value in pairs(result) do
						print("Group created with id " .. value["id"] .. " (Owner: " .. id .. ")");
						setElementData(player, "char >> groupId", value["id"]);

						groups[value["id"]] = {
							["id"] = value["id"],
							["owner"] = id,
							["ownername"] = exports.cr_account:getCharacterNameByID(id):gsub("_", " "),
							["name"] = value["name"],
							["created"] = value["created"],
							["members"] = {
								{["charId"] = id, ["charName"] = exports.cr_account:getCharacterNameByID(id):gsub("_", " ")},
							},
						};
					end
				end
			end, mysql:requestConnection(), "SELECT id, name, created FROM groups WHERE id=LAST_INSERT_ID()");
		end, 200, 1);
	end
end);

addEvent("group->DeleteById", true);
addEventHandler("group->DeleteById", root, function(player, id)
	if client and client == player and id then
		if groups[id] then
			for key, value in pairs(getElementsByType("player")) do
				if getElementData(value, "char >> groupId") == id then
					setElementData(value, "char >> groupId", 0);
				end
			end

			exports.cr_account:updateRemovedGroup(id);

			dbExec(mysql:requestConnection(), "DELETE FROM groups WHERE id=?", id);
			dbExec(mysql:requestConnection(), "UPDATE characters SET charGroup=0 WHERE charGroup=?", id);

			groups[id] = nil;
		end
	end
end);

addEvent("group->RenameById", true);
addEventHandler("group->RenameById", root, function(player, id, name)
	if client and client == player and id and name then
		if groups[id] then
			print("Group " .. groups[id]["name"] .. " renamed to " .. name .. " (id: " .. id .. ")");

			dbExec(mysql:requestConnection(), "UPDATE groups SET name=? WHERE id=?", name, id);
			groups[id]["name"] = name;

			triggerClientEvent(player, "group->CallbackData", player, groups[id] or {});
		end
	end
end);

addEvent("group->AddPlayerToGroup", true);
addEventHandler("group->AddPlayerToGroup", root, function(player, id, newplayer)
	if client and client == player and id and newplayer then
        if getElementData(newplayer, "char >> groupId") <= 0 then
            setElementData(newplayer, "char >> groupId", id);

            table.insert(groups[id]["members"], {
                ["charId"] = getElementData(newplayer, "acc >> id"),
                ["charName"] = exports.cr_account:getCharacterNameByID(getElementData(newplayer, "acc >> id")):gsub("_", " "),
            });

            triggerClientEvent(player, "group->CallbackData", player, groups[id] or {});
            triggerClientEvent(player, "group->CallbackData", newplayer, groups[id] or {});
                
            dbExec(mysql:requestConnection(), "UPDATE characters SET charGroup=? WHERE id=?", id, getElementData(newplayer, "acc >> id"));    
        else
            exports.cr_infobox:addBox("error", "Már egy csoport tagja vagy!");
        end
	end
end);

addEvent("group->InvitePlayerToGroup", true);
addEventHandler("group->InvitePlayerToGroup", root, function(player, id, newplayer)
	if client and client == player and id and newplayer then
        if getElementData(newplayer, "char >> groupId") <= 0 then
		    triggerClientEvent(newplayer, "group->invite", newplayer, groups[id] or {});
        else
            exports.cr_infobox:addBox("error", exports.cr_admin:getAdminName(newplayer) .. " már egy csoport tagja!");
        end
	end
end);

addEvent("group->RemovePlayerFromGroup", true);
addEventHandler("group->RemovePlayerFromGroup", root, function(player, id, charId, removed)
	if client and client == player and id and charId then
		dbExec(mysql:requestConnection(), "UPDATE characters SET charGroup=0 WHERE id=?", charId);

		for key, value in pairs(groups[id]["members"]) do
			if value["charId"] == charId then
				table.remove(groups[id]["members"], key);
			end
		end

		if isElement(removed) then
			setElementData(removed, "char >> groupId", 0);
		end

		triggerClientEvent(player, "group->CallbackData", player, groups[id] or {});
	end
end);

addEvent("group->GetData", true);
addEventHandler("group->GetData", root, function(player, id)
	if client and client == player and id then
        --outputChatBox(groups[id]["ownername"])
		triggerClientEvent(player, "group->CallbackData", player, groups[id] or {});
	end
end);