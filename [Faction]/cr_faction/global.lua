factions = {};
faction_members = {};
faction_members_online = {};
faction_vehicles = {};
factions_def = {};
faction_members_def = {};

types = {"Rendvédelem", "Legális szerveret", "Maffia", "Banda", "Cartel"};

faction_skins = {
    [1] = {1, 2, 3, 4, 5, 6, 7},
};

function isPlayerInFaction(player, faction)
    if factions_def[faction] and faction_members_def[faction] then
        local dbid = getElementData(player, "acc >> id") or 0;
        if dbid > 0 then
            if faction_members_def[faction][dbid] then
                return true, "Frakció tagja";
            end
            return false, "Nem a frakció tagja!";
        end
        return false, "Nincs bejelentkezve!";
    end
    return false, "Nem létező frakció!";
end

function getPlayerFactions(player)
    return factions;
end

function getPlayerDatas(player, faction)
    if factions_def[faction] and faction_members_def[faction] then
        local dbid = getElementData(player, "acc >> id") or 0;
        if dbid > 0 then
            if faction_members_def[faction][dbid] then
                return faction_members_def[faction][dbid][3], factions_def[faction]["ranks"][faction_members_def[faction][dbid][3]][2];
            end
            return false, "Nem a frakció tagja!";
        end
        return false, "Nincs bejelentkezve!";
    end
    return false, "Nem létező frakció!";
end

function isPlayerLeader(player, faction)
    if factions_def[faction] and faction_members_def[faction] then
        local dbid = getElementData(player, "acc >> id") or 0;
        if dbid > 0 then
            if faction_members_def[faction][dbid] then
                if faction_members_def[faction][dbid][4] > 0 then
                    return true, "Leader";
                end
            end
            return false, "Nem a frakció tagja!";
        end
        return false, "Nincs bejelentkezve!";
    end
    return false, "Nem létező frakció!";
end

function isPlayerMainLeader(player, faction)
    if factions_def[faction] and faction_members_def[faction] then
        local dbid = getElementData(player, "acc >> id") or 0;
        if dbid > 0 then
            if faction_members_def[faction][dbid] then
                if faction_members_def[faction][dbid][4] == 2 then
                    return true, "Fő-leader";
                end
            end
            return false, "Nem a frakció tagja!";
        end
        return false, "Nincs bejelentkezve!";
    end
    return false, "Nem létező frakció!";
end

function getFactionName(player, faction)
    if factions_def[faction] then
        return factions_def[faction]["name"];
    end
    return false, "Nem létező frakció!";
end

function getFactionMoney(player, faction)
    if factions_def[faction] then
        return factions_def[faction]["money"];
    end
    return false, "Nem létező frakció!";
end

function getFactionDutys(player, faction)
    if factions_def[faction] then
        return factions_def[faction]["dutys"];
    end
    return false, "Nem létező frakció";
end

function getFactionStorage(player, faction)

end

function updateFactionStorage(player, faction, data)

end

function getPlayerFactionRank(player, faction)
    if factions_def[faction] and faction_members_def[faction] then
        local dbid = getElementData(player, "acc >> id") or 0;
        if dbid > 0 then
            if faction_members_def[faction][dbid] then
                return faction_members_def[faction][dbid][3];
            end
            return false, "Nem a frakció tagja!";
        end
        return false, "Nincs bejelentkezve!";
    end
    return false, "Nem létező frakció!";
end

function getRankName(faction, rank)
	if(factions_def[faction]) then
		if(factions_def[faction]["ranks"]) then
			if(factions_def[faction]["ranks"][rank]) then
				return factions_def[faction]["ranks"][rank][1]
			end
		end
	end
	return "Ismeretlen"
end