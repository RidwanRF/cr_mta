local sx, sy = guiGetScreenSize();
local browser = createBrowser(sx, sy, true, true);
local ready = false;

setDevelopmentMode(true, true)

function renderPanel()
	if(state) then
		dxDrawImage(0, 0, sx, sy, browser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	end
end

function clickEventHandler(b, s)
	if(s == "down") then
		injectBrowserMouseDown(browser, b)
	else
		injectBrowserMouseUp(browser, b)
	end
end

function moveEventHandler(_, _, x, y)
	injectBrowserMouseMove(browser, x, y) 
end

local refreshTimer = setTimer(function() 
	if(ready) then
		if(not state) then
			local factionVehs = {};
			for i, k in pairs(getElementsByType("vehicle")) do
				local faction = tonumber(getElementData(k, "veh >> faction")) or 0;
				if faction > 0 then
					if not factionVehs[faction] then
						factionVehs[faction] = {};
					end
					local x, y, z = k:getPosition()
					table.insert(factionVehs[faction], {exports.cr_vehicle:getVehicleName(k:getModel()), getZoneName(x, y, z), k:getData("veh >> id"), math.floor(k:getHealth()/10)});
				end
			end
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
				executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..", '"..tonumber(localPlayer:getData("acc >> id")).."');")
				if(factionVehs[i] and #factionVehs[i] > 0) then
					executeBrowserJavascript(browser, "refreshFactionVehicles("..i..", "..toJSON(factionVehs[i])..");")
				end
			end
			executeBrowserJavascript(browser, "receiveItemNames("..toJSON(exports.cr_inventory:getAllItems())..");")
		end
	end
end, 5000, 0)

local hudOState = nil;
addEvent("kickedFromFaction", true)
addEventHandler("kickedFromFaction", root, function() 
	if state then
		removeEventHandler("onClientRender", root, renderPanel)
		removeEventHandler("onClientClick", root, clickEventHandler)
		removeEventHandler("onClientCursorMove", root, moveEventHandler)
		--hudOState = localPlayer:getData("hudVisible")
        --outputChatBox("keysDenied:"..tostring(keysDeniedOState))
        --outputChatBox("Hud:"..tostring(hudOState))
        --outputChatBox("Chat:"..tostring(chatOState))
		setElementData(localPlayer, "hudVisible", hudOState);
		setElementData(localPlayer, "keysDenied", keysDeniedOState);
		showCursor(false)
		showChat(chatOState)
		--outputChatBox("KURVA ANYÁD BEZÁRTA: 2")
		state = false
	end
end)

function closeFactionPanel()
    if state then
		removeEventHandler("onClientRender", root, renderPanel)
		removeEventHandler("onClientClick", root, clickEventHandler)
		removeEventHandler("onClientCursorMove", root, moveEventHandler)
		--hudOState = localPlayer:getData("hudVisible")
        --outputChatBox("keysDenied:"..tostring(keysDeniedOState))
        --outputChatBox("Hud:"..tostring(hudOState))
        --outputChatBox("Chat:"..tostring(chatOState))
		setElementData(localPlayer, "hudVisible", hudOState);
		setElementData(localPlayer, "keysDenied", keysDeniedOState);
		showCursor(false)
		showChat(chatOState)
		--outputChatBox("KURVA ANYÁD BEZÁRTA: 2")
		state = false
	end
end

function isChatVisible(...)
    return exports['cr_custom-chat']:isChatVisible(...)
end

function showChat(...)
    return exports['cr_custom-chat']:showChat(...)
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	if state then
		removeEventHandler("onClientRender", root, renderPanel)
		removeEventHandler("onClientClick", root, clickEventHandler)
		removeEventHandler("onClientCursorMove", root, moveEventHandler)
		--hudOState = localPlayer:getData("hudVisible")
		setElementData(localPlayer, "hudVisible", hudOState);
		setElementData(localPlayer, "keysDenied", keysDeniedOState);
		showCursor(false)
		showChat(chatOState)
		
		state = false
        --outputChatBox("KURVA ANYÁD BEZÁRTA: 3")
	end
end)

local loadTimer, spamTimer = nil, nil, nil;
addEventHandler("onClientKey", root, function(k, s)
	if(localPlayer:getData("loggedIn")) then
		if(state) then
			if(k == "mouse_wheel_down") then
				injectBrowserMouseWheel(browser, -40, 0)
			elseif(k == "mouse_wheel_up") then
				injectBrowserMouseWheel(browser, 40, 0)
			end
		end
		if(k == "F3") then
			if(not isTimer(spamTimer)) then
				spamTimer = setTimer(function() end, 1000, 1)
				local factions = getPlayerFactions(localPlayer)
				if(#factions > 0) then
					if(s) then
						state = not state
						--localPlayer:setData("factionPanel", state)
						-- toggleBrowserDevTools(browser, state)
						if(not isTimer(loadTimer)) then
							if(state) then
                                exports['cr_dashboard']:closeDashboard()
								triggerServerEvent("server->getFactionDatas", localPlayer);
								chatOState = isChatVisible()
								--cursorOState = isCursorShowing()
								showChat(false)
								showCursor(true)
								-- setTimer(function()
									-- outputChatBox("ASD")
									-- local factionVehs = {};
									-- for i, k in pairs(getElementsByType("vehicle")) do
										-- local faction = tonumber(getElementData(k, "veh >> faction")) or 0;
										-- if faction > 0 then
											-- if not factionVehs[faction] then
												-- factionVehs[faction] = {};
											-- end
											-- local x, y, z = k:getPosition()
											-- table.insert(factionVehs[faction], {exports.cr_vehicle:getVehicleName(k:getModel()), getZoneName(x, y, z), k:getData("veh >> id"), math.floor(k:getHealth()/10)});
										-- end
									-- end
									-- for i, v in pairs(getPlayerFactions(localPlayer)) do
										-- executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
										-- executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..", '"..tonumber(localPlayer:getData("acc >> id")).."');")
										-- if(factionVehs[i] and #factionVehs[i] > 0) then
											-- executeBrowserJavascript(browser, "refreshFactionVehicles("..i..", "..toJSON(factionVehs[i])..");")
										-- end
									-- end
									-- executeBrowserJavascript(browser, "receiveItemNames("..toJSON(exports.cr_inventory:getAllItems())..");")
									loadTimer = setTimer(function() 
										focusBrowser(browser)
										addEventHandler("onClientRender", root, renderPanel)
										addEventHandler("onClientClick", root, clickEventHandler)
										addEventHandler("onClientCursorMove", root, moveEventHandler)
									end, 100, 1)
								-- end, 200, 1)
								loadBrowserURL(browser, "http://mta/local/html/faction.html")
								playerCache = getOnlinePlayerCache();
								hudOState = getElementData(localPlayer, "hudVisible") --localPlayer:getData("hudVisible")
								setElementData(localPlayer, "hudVisible", false);
								keysDeniedOState = getElementData(localPlayer, "keysDenied")
								--outputChatBox("keysDenied:"..tostring(keysDeniedOState))
								--outputChatBox("Hud:"..tostring(hudOState))
								--outputChatBox("Chat:"..tostring(chatOState))
								setElementData(localPlayer, "keysDenied", true);
							else
                                --outputChatBox("KURVA ANYÁD BEZÁRTA: 4")
								removeEventHandler("onClientRender", root, renderPanel)
								removeEventHandler("onClientClick", root, clickEventHandler)
								removeEventHandler("onClientCursorMove", root, moveEventHandler)
								--hudOState = localPlayer:getData("hudVisible")
								setElementData(localPlayer, "hudVisible", hudOState);
								setElementData(localPlayer, "keysDenied", keysDeniedOState);
								showCursor(false)
								showChat(chatOState)
							end
						end
					end
				else
					if(s) then
						exports.cr_infobox:addBox("error", "Nem vagy tagja egy frakciónak sem.")
					end
				end
			else
				if(s) then
					exports.cr_infobox:addBox("error", "Ne ilyen gyorsan!")
				end
			end
		end
	end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dName) 
	if dName == "loggedIn" and getElementData(source, dName) then 
		triggerServerEvent("server->getFactionDatas", localPlayer, true) 
	end 
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	if(localPlayer:getData("loggedIn")) then
		loadBrowserURL(browser, "http://mta/local/html/faction.html")
		triggerServerEvent("server->getFactionDatas", localPlayer, true);
	end
end);

addEvent("client->getFactionDatas", true);
addEventHandler("client->getFactionDatas", getRootElement(), function(datas1, datas2, update, shit)
    local dbid = getElementData(localPlayer, "acc >> id");
    local updateDatas = {};
    factions = {};
    faction_members = {};
    faction_members_online = {};
    faction_members_position = {};
    faction_vehicles = {};
    factions_def = datas1;
    faction_members_def = datas2;
    local cache = getOnlinePlayerCache();
    
    for i, k in pairs(datas1) do
        local id = i;
        faction_vehicles[k["id"]] = {};
        faction_members_online[k["id"]] = {};
        if datas2[id][dbid] then
            local count = #factions+1;
            factions[count] = datas1[i];
                
            if not faction_members[count] then
                faction_members[count] = {};
            end
                
            for j, l in pairs(datas2[id]) do
                table.insert(faction_members[count], l);
                    
                if cache[l[5]] or cache[l[2]] then
                    local element = cache[l[5]] and cache[l[5]] or cache[l[2]];
                    table.insert(faction_members_online[k["id"]], l[2]);
                    faction_members_position[l[2]] = {getElementPosition(element)};
                end
            end
            
            if datas2[id][dbid][6] ~= getElementData(localPlayer, "lastLogin") then
                table.insert(updateDatas, {"lastlogin", datas1[i]["id"], getElementData(localPlayer, "lastLogin")});
            end
                
            if datas2[id][dbid][5] ~= getElementData(localPlayer, "char >> name") then
                table.insert(updateDatas, {"name", datas1[i]["id"], getElementData(localPlayer, "char >> name")});
            end
                
            table.sort(faction_members[count], function(a, b)
                if a[4] > b[4] then
                    return b[4];  
                end
            end);
        end
    end
        
    if #updateDatas > 0 then
        triggerServerEvent("server->updateDatas", localPlayer, updateDatas);    
    end
        
    if #factions < 1 then
        if state then
            removeEventHandler("onClientRender", root, renderPanel)
            removeEventHandler("onClientClick", root, clickEventHandler)
            removeEventHandler("onClientCursorMove", root, moveEventHandler)
            --hudOState = localPlayer:getData("hudVisible")
            setElementData(localPlayer, "hudVisible", hudOState);
            setElementData(localPlayer, "keysDenied", keysDeniedOState);
            showCursor(false)
            showChat(chatOState)
            state = false
                
            resetFaction();
        end
            
        if not update then
            exports.cr_infobox:addBox("error", "Nem vagy egy frakció tagja sem!");
        end
    else
        for i, k in pairs(getElementsByType("vehicle")) do
            local faction = tonumber(getElementData(k, "veh >> faction")) or 0;
            if faction > 0 then
                if not faction_vehicles[faction] then
                    faction_vehicles[faction] = {};
                end
                    
                table.insert(faction_vehicles[faction], {k, getElementData(k, "veh >> id"), getElementHealth(k)});
            end
        end
    end
end);

_addEvent("getPlayers", true)
_addEventHandler("getPlayers", browser, function() 
	local temp = {};
	for i, v in pairs(getElementsByType("player")) do
		if(v:getData("loggedIn")) then
			table.insert(temp, {v:getData("char >> name"):gsub("_", " "), v:getData("char >> id")})
		end
	end
	executeBrowserJavascript(browser, "receivePlayers("..toJSON(temp)..");")
end)

_addEvent("showBox", true)
_addEventHandler("showBox", browser, function(type, msg) 
	exports.cr_infobox:addBox(type, msg)
end)

_addEvent("addToFaction", true)
_addEventHandler("addToFaction", browser, function(id, sf)
	id, sf = tonumber(id), tonumber(sf)
	local p = false;
	for i, v in pairs(getElementsByType("player")) do
		if(tonumber(v:getData("char >> id")) == id) then
			p = v
			break;
		end
	end
	if(not isPlayerInFaction(p, sf)) then
		triggerServerEvent("server->addToFaction", localPlayer, p:getData("acc >> id"), factions[sf]["id"]);
       _triggerServerEvent("addBox", p, p, "info", "Felvettek téged a(z) "..factions[sf]["name"].." frakcióba!");
		exports.cr_infobox:addBox("success", p:getData("char >> name"):gsub("_", " ").." sikeresen felvéve a(z) "..factions[sf]["name"].." frakcióba.")
		triggerServerEvent("server->getFactionDatas", localPlayer);
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..");")
			end
		end, 500, 1)
		executeBrowserJavascript(browser, "closeInvitePanel();")
	else
		exports.cr_infobox:addBox("error", "Ő már tagja ennek a frakciónak!")
	end
end)

_addEvent("promoteMember", true)
_addEventHandler("promoteMember", browser, function(sf, se)
	sf, se = tonumber(sf), tonumber(se)
	local p = false;
	for i, v in pairs(getElementsByType("player")) do
		if(tonumber(v:getData("acc >> id")) == faction_members[sf][se][2]) then
			p = v
			break;
		end
	end
	if(faction_members[sf][se][3] < #factions[sf]["ranks"]) then
		faction_members[sf][se][3] = faction_members[sf][se][3]+1
		exports.cr_infobox:addBox("success", "A kiválasztott tag előléptetve.")
		if(p) then
			_triggerServerEvent("addBox", p, p, "info", "Elő lettél léptetve a(z) "..factions[sf]["name"].." frakcióban!")
		end
		triggerServerEvent("server->changeRank", localPlayer, faction_members[sf][se][2], factions[sf]["id"], faction_members[sf][se][3])
		triggerServerEvent("server->getFactionDatas", localPlayer);
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..");")
			end
		end, 500, 1)
	else
		exports.cr_infobox:addBox("error", "Ő már a legmagasabb rangon van!")
	end
end)

_addEvent("demoteMember", true)
_addEventHandler("demoteMember", browser, function(sf, se)
	sf, se = tonumber(sf), tonumber(se)
	local p = false;
	for i, v in pairs(getElementsByType("player")) do
		if(tonumber(v:getData("acc >> id")) == faction_members[sf][se][2]) then
			p = v
			break;
		end
	end
	if(faction_members[sf][se][3] > 1) then
		faction_members[sf][se][3] = faction_members[sf][se][3]-1
		exports.cr_infobox:addBox("success", "A kiválasztott tag lefokozva.")
		if(p) then
			_triggerServerEvent("addBox", p, p, "info", "Le lettél fokozva a(z) "..factions[sf]["name"].." frakcióban!")
		end
		triggerServerEvent("server->changeRank", localPlayer, faction_members[sf][se][2], factions[sf]["id"], faction_members[sf][se][3])
		triggerServerEvent("server->getFactionDatas", localPlayer);
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..");")
			end
		end, 500, 1)
	else
		exports.cr_infobox:addBox("error", "Ő már a legkisebb rangon van!")
	end
end)

_addEvent("toggleLeader", true)
_addEventHandler("toggleLeader", browser, function(sf, se)
	sf, se = tonumber(sf), tonumber(se)
	local p = false;
	for i, v in pairs(getElementsByType("player")) do
		if(tonumber(v:getData("acc >> id")) == faction_members[sf][se][2]) then
			p = v
			break;
		end
	end
	faction_members[sf][se][4] = faction_members[sf][se][4] == 0 and 1 or 0;
	if(p) then
		_triggerServerEvent("addBox", p, p, "info", (faction_members[sf][se][4] == 1 and "Leader jogot kaptál" or "Elvették a leader jogodat").." a(z) "..factions[sf]["name"].." frakcióban!")
	end
	exports.cr_infobox:addBox("success", (faction_members[sf][se][4] == 1 and "Leader jogot adtál" or "Elvetted a leader jogát").." a kiválasztott tagnak.")
	triggerServerEvent("server->changeLeader", localPlayer, faction_members[sf][se][2], factions[sf]["id"], faction_members[sf][se][4])
	triggerServerEvent("server->getFactionDatas", localPlayer)
	setTimer(function()
		for i, v in pairs(getPlayerFactions(localPlayer)) do
			executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(factions[i])..", "..localPlayer:getData("acc >> id")..");")
			executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..");")
		end
	end, 500, 1)
end)

_addEvent("kickMember", true)
_addEventHandler("kickMember", browser, function(sf, se)
	sf, se = tonumber(sf), tonumber(se)
	local p = false;
	for i, v in pairs(getElementsByType("player")) do
		if(tonumber(v:getData("acc >> id")) == faction_members[sf][se][2]) then
			p = v
			break;
		end
	end
	if(p) then
		_triggerServerEvent("addBox", p, p, "error", "Ki lettél rúgva a(z) "..factions[sf]["name"].." frakcióból, "..localPlayer:getData("char >> name"):gsub("_", " ").." által.")
	end
	exports.cr_infobox:addBox("success", faction_members[sf][se][5].." kirúgva a(z) "..factions[sf]["name"].." frakcióból.")
	triggerServerEvent("server->removeFromFaction", localPlayer, faction_members[sf][se][2], factions[sf]["id"]);
	
	if(p == localPlayer) then
		removeEventHandler("onClientRender", root, renderPanel)
		removeEventHandler("onClientClick", root, clickEventHandler)
		removeEventHandler("onClientCursorMove", root, moveEventHandler)
		--hudOState = localPlayer:getData("hudVisible")
		setElementData(localPlayer, "hudVisible", hudOState);
		setElementData(localPlayer, "keysDenied", keysDeniedOState);
		showCursor(false)
		showChat(chatOState)
		
		state = false
        --outputChatBox("KURVA ANYÁD BEZÁRTA: 1")
	else
		triggerServerEvent("kickedFaction", p, p)
		triggerServerEvent("server->getFactionDatas", localPlayer)
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..");")
			end
		end, 500, 1)
	end
end)

local keyTimer = nil;
_addEvent("getKey", true)
_addEventHandler("getKey", browser, function(vehID)
	if(not isTimer(keyTimer)) then
		triggerServerEvent("server->giveKey", localPlayer, vehID);
		keyTimer = setTimer(function() end, 60000, 1)
	else
		exports.cr_infobox:addBox("error", "Kulcsot percenként csak egyszer tudsz igényelni.")
	end
end)

_addEvent("createRank", true)
_addEventHandler("createRank", browser, function(sf, rankName, rankSalary, permissions) 
	if(not isTimer(spamTimer)) then
		spamTimer = setTimer(function() end, 1000, 1)
		sf, rankName, rankSalary, permissions = tonumber(sf), tostring(rankName), tonumber(rankSalary), fromJSON("["..permissions.."]")
		
		if #factions[sf]["ranks"] >= 25 then
			exports.cr_infobox:addBox("error", "Maximum 25 rang!");
			return;
		end
		table.insert(factions[sf]["ranks"], {rankName, rankSalary});
		factions[sf]["permissions"][#factions[sf]["ranks"]] = permissions
		triggerServerEvent("server->updateRankPermissions", localPlayer, factions[sf]["id"], factions[sf]["permissions"])

		triggerServerEvent("server->updateRankDatas", localPlayer, factions[sf]["id"], factions[sf]["ranks"]);

		exports.cr_infobox:addBox("success", "Sikeres létrehoztál egy új rangot a(z) "..factions[sf]["name"].." frakcióban!");
		
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
			end
			executeBrowserJavascript(browser, "closeRankPanel();")
		end, 500, 1)
	else
		exports.cr_infobox:addBox("error", "Ne ilyen gyorsan!");
	end
end)

_addEvent("editRank", true)
_addEventHandler("editRank", browser, function(sf, se, rankName, rankSalary, permissions)
	if(not isTimer(spamTimer)) then
		spamTimer = setTimer(function() end, 1000, 1)	
		sf, se, rankName, rankSalary, permissions = tonumber(sf), tonumber(se), tostring(rankName), tonumber(rankSalary), fromJSON("["..permissions.."]")
		factions[sf]["ranks"][se] = {rankName, rankSalary}
		if(not factions[sf]["permissions"][se]) then
			factions[sf]["permissions"][se] = {};
		end
		factions[sf]["permissions"][se] = permissions
		triggerServerEvent("server->updateRankPermissions", localPlayer, factions[sf]["id"], factions[sf]["permissions"])
		triggerServerEvent("server->updateRankDatas", localPlayer, factions[sf]["id"], factions[sf]["ranks"]);
		exports.cr_infobox:addBox("success", "Sikeres adatváltoztatás!");
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
			end
			executeBrowserJavascript(browser, "closeRankPanel();")
		end, 500, 1)
	else
		exports.cr_infobox:addBox("error", "Ne ilyen gyorsan!");
	end
end)

_addEvent("deleteRank", true)
_addEventHandler("deleteRank", browser, function(sf, se) 
	if(not isTimer(spamTimer)) then
		spamTimer = setTimer(function() end, 1000, 1)	
		sf, se = tonumber(sf), tonumber(se)
		if #factions[sf]["ranks"] > 10 then
			table.remove(factions[sf]["ranks"], se);
			triggerServerEvent("server->updateRankDatas", localPlayer, factions[sf]["id"], factions[sf]["ranks"], se);
			exports.cr_infobox:addBox("success", "Sikeres töröltél egy rangot a(z) "..factions[sf]["name"].." frakcióban!");
			setTimer(function()
				for i, v in pairs(getPlayerFactions(localPlayer)) do
					executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
				end
			end, 500, 1)
		else
			exports.cr_infobox:addBox("error", "10 rangnál nem lehet kevesebb!");
		end
	else
		exports.cr_infobox:addBox("error", "Ne ilyen gyorsan!");
	end
end)

_addEvent("deleteStorageItem", true)
_addEventHandler("deleteStorageItem", browser, function(sf, se) 
	sf, se = tonumber(sf), tonumber(se)
	triggerServerEvent("removeStorageItem", localPlayer, localPlayer, sf, se, true)
	exports.cr_infobox:addBox("success", "Sikeres töröltél egy tárgyat a(z) "..factions[sf]["name"].." frakcióban!");
	setTimer(function()
		for i, v in pairs(getPlayerFactions(localPlayer)) do
			executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
		end
	end, 500, 1)
end)


_addEvent("createDuty", true)
_addEventHandler("createDuty", browser, function(sf, dutyName, dutyRank, data) 
	data = "["..data.."]"
	sf, dutyName, dutyRank, data = tonumber(sf), tostring(dutyName), tonumber(dutyRank)+1, fromJSON(data)
	local temp = {};
	-- if(#data > 0) then
		for i, v in pairs(data) do
			table.insert(temp, {["quantity"] = v[2], ["itemDetails"] = {v[1]}})
		end
		local t = {["name"] = dutyName, ["rank"] = dutyRank, ["skin"] = 1, ["created"] = getRealTime().timestamp, ["items"] = temp};
		table.insert(factions[sf]["dutys"], t);
		exports.cr_infobox:addBox("success", "Sikeresen létrehoztál egy duty-t a(z) "..factions[sf]["name"].." frakcióban!");
		triggerServerEvent("server->updateDutys", localPlayer, factions[sf]["id"], factions[sf]["dutys"]);
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
			end
			executeBrowserJavascript(browser, "closeDutyPanel();")
		end, 500, 1)
	-- else
		-- exports.cr_infobox:addBox("error", "A dutykhoz kötelező tárgyat is rendelni!");
	-- end
end)

_addEvent("editDuty", true)
_addEventHandler("editDuty", browser, function(sf, se, dutyName, dutyRank, data) 
	data = "["..data.."]"
	sf, se, dutyName, dutyRank, data = tonumber(sf), tonumber(se), tostring(dutyName), tonumber(dutyRank)+1, fromJSON(data)
	local temp = {};
	-- if(#data > 0) then
		for i, v in pairs(data) do
			table.insert(temp, {["quantity"] = v[2], ["itemDetails"] = {v[1]}})
		end
		local t = {["name"] = dutyName, ["rank"] = dutyRank, ["skin"] = 1, ["created"] = getRealTime().timestamp, ["items"] = temp};
		-- table.insert(factions[sf]["dutys"], t);
		factions[sf]["dutys"][se] = t
		exports.cr_infobox:addBox("success", "Sikeresen szerkesztettél egy duty-t a(z) "..factions[sf]["name"].." frakcióban!");
		triggerServerEvent("server->updateDutys", localPlayer, factions[sf]["id"], factions[sf]["dutys"]);
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
			end
			executeBrowserJavascript(browser, "closeDutyPanel();")
		end, 500, 1)
	-- else
		-- exports.cr_infobox:addBox("error", "A dutykhoz kötelező tárgyat is rendelni!");
	-- end
end)

_addEvent("deleteDuty", true)
_addEventHandler("deleteDuty", browser, function(sf, se)
	sf, se = tonumber(sf), tonumber(se)
	exports.cr_infobox:addBox("success", "Sikeresen törölted a kijelölt duty-t a(z) "..factions[sf]["name"].." frakcióban!");
	table.remove(factions[sf]["dutys"], se);
	triggerServerEvent("server->updateDutys", localPlayer, factions[sf]["id"], factions[sf]["dutys"]);
	setTimer(function()
		for i, v in pairs(getPlayerFactions(localPlayer)) do
			executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
		end
	end, 500, 1)
end)

function sendData()
	local factionVehs = {};
	for i, k in pairs(getElementsByType("vehicle")) do
		local faction = tonumber(getElementData(k, "veh >> faction")) or 0;
		if faction > 0 then
			if not factionVehs[faction] then
				factionVehs[faction] = {};
			end
			local x, y, z = k:getPosition()
			table.insert(factionVehs[faction], {exports.cr_vehicle:getVehicleName(k:getModel()), getZoneName(x, y, z), k:getData("veh >> id"), math.floor(k:getHealth()/10)});
		end
	end
	for i, v in pairs(getPlayerFactions(localPlayer)) do
		executeBrowserJavascript(browser, "loadFactionData("..i..", "..toJSON(v)..");")
		executeBrowserJavascript(browser, "loadFactionMembers("..i..", "..toJSON(faction_members[i])..", "..toJSON(faction_members_online[i])..", '"..tonumber(localPlayer:getData("acc >> id")).."');");
		if(factionVehs[i] and #factionVehs[i] > 0) then
			-- outputDebugString(toJSON(factionVehs[i]))
			executeBrowserJavascript(browser, "loadFactionVehicles("..i..", "..toJSON(factionVehs[i])..");")
		end
	end
	executeBrowserJavascript(browser, "receiveItemNames("..toJSON(exports.cr_inventory:getAllItems())..");")
end

_addEvent("requestData", true)
_addEventHandler("requestData", browser, function() 
	sendData()
end)

addEventHandler("onClientBrowserDocumentReady", browser , function (url) 
	ready = true
end)

_addEvent("saveMessage", true)
_addEventHandler("saveMessage", browser, function(sf, msg) 
	sf,  msg = tonumber(sf), tostring(msg)
	factions[sf]["msg"] = msg
	triggerServerEvent("server->updateFactionMessage", localPlayer, sf, msg)
	exports.cr_infobox:addBox("success", "Frakció üzenet módosítva a(z) "..factions[sf]["name"].." frakcióban!");
	setTimer(function()
		for i, v in pairs(getPlayerFactions(localPlayer)) do
			executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
		end
		executeBrowserJavascript(browser, "closeMessage();")
	end, 500, 1)
end)

_addEvent("changeMoney", true)
_addEventHandler("changeMoney", browser, function(sf, mode, money) 
	sf, mode, money = tonumber(sf), tonumber(mode) == 1 and true or false, tonumber(money)
	if(money > 0) then
		triggerServerEvent("changeFactionMoney", localPlayer, localPlayer, sf, mode, money)
		setTimer(function()
			for i, v in pairs(getPlayerFactions(localPlayer)) do
				executeBrowserJavascript(browser, "refreshFactionData("..i..", "..toJSON(v)..");")
			end
			executeBrowserJavascript(browser, "closeDepositPanel();")
			executeBrowserJavascript(browser, "closeWithdrawPanel();")
		end, 500, 1)
	else
		exports.cr_infobox:addBox("error", "Az értéknek nagyobbnak kell lennie nullánál!")
	end
end)