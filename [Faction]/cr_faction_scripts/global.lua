permissions = {
	["ticket"] = {1, 6},
	["jail"] = {1, 3, 6},
	["release"] = {1, 3, 6},
	["backup"] = {1, 3, 6},
	["cancelbackup"] = {1, 3, 6},
	["mdc"] = {1, 6},
	["cuff"] = {1, 3, 6},
	["uncuff"] = {1, 3, 6},
	["visz"] = {1, 3, 6},
	["elenged"] = {1, 3, 6},
	["gov"] = {1, 3, 5, 6},
	["d"] = {1, 2, 3, 6}, -- sürgősségi rádió // kész
	["jelvenyadas"] = {1, 3, 6},
	["rbs"] = {1, 3, 6},
	["delallrbs"] = {1, 3, 6},
	["delrbs"] = {1, 3, 6},
	["lefoglal"] = {1, 3, 6},
	["alnev"] = {6},
	["lenyomoz"] = {6},
	["acceptmedic"] = {2},
	["gyogyit"] = {2},
	["felemel"] = {2},
	["mutet"] = {2},
	["accepttaxi"] = {2},
	["adopanel"] = {3},
	["acceptmechanic"] = {5},
	["unflip"] = {5},
};

reportTable = {
	["pd"] = {1, },
};

radioColor = "#77A8AB";
dRadioColor = "#fd4c00";

function getCommandFactions(cmd)
	return permissions[cmd] or false
end

function hasFactionPermission(cmd, faction)
	if(permissions[cmd]) then
		for index, value in pairs(permissions[cmd]) do
			if(value == faction) then
				return true
			end
		end
	end
	return false
end