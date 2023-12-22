local furnitures = {};
local mysql = exports.cr_mysql;

addEventHandler("onResourceStart", resourceRoot, function()
	local start = getTickCount();

	dbQuery(function(queryHandler)
		local results, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

		if numAffectedRows > 0 then
			for key, value in pairs(results) do
				local position = fromJSON(value.positions);
				local rotation = fromJSON(value.rotations);

				local this = Object(value.objectId, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3]);
				this.interior = position[4];
				this.dimension = position[5];

				setElementData(this, "furniture->Id", value.id);

				table.insert(furnitures, {["id"] = value.id, ["object"] = this});
			end
		end

		outputDebugString("Loaded " .. numAffectedRows .. " furniture(s) in " .. getTickCount() - start .. "ms");
	end, mysql:requestConnection(), "SELECT * FROM furnitures");
end);

addEvent("furniture->CreateNew", true);
addEventHandler("furniture->CreateNew", root, function(player, id, x, y, z, rx, ry, rz)
	if client and client == player then
		local this = Object(id, x, y, z, rx, ry, rz);
		this.interior = player.interior;
		this.dimension = player.dimension;

		dbExec(mysql:requestConnection(), "INSERT INTO furnitures SET objectId=?, positions=?, rotations=?, interiorId=?", id, toJSON({x, y, z, this.interior, this.dimension}), toJSON({rx, ry, rz}), 1);

		dbQuery(function(queryHandler)
			local results, numAffectedRows, errorMsg = dbPoll(queryHandler, 0);

			if numAffectedRows > 0 then
				for key, value in pairs(results) do
					setElementData(this, "furniture->Id", value["id"]);
					table.insert(furnitures, {["id"] = value["id"], ["object"] = this});
				end
			end
		end, mysql:requestConnection(), "SELECT id FROM furnitures WHERE id=LAST_INSERT_ID()");
	end
end);

addEvent("furniture->ModifyFurn", true);
addEventHandler("furniture->ModifyFurn", root, function(player, id, element, x, y, z, rx, ry, rz)
	if client and client == player then
		setElementPosition(element, x, y, z);
		setElementRotation(element, rx, ry, rz);

		dbExec(mysql:requestConnection(), "UPDATE furnitures SET positions=?, rotations=? WHERE id=?", toJSON({x, y, z, element.interior, element.dimension}), toJSON({rx, ry, rz}), id);
	end
end);

addEvent("furniture->RemoveFurn", true);
addEventHandler("furniture->RemoveFurn", root, function(player, element)
	if client and client == player then
		dbExec(mysql:requestConnection(), "DELETE FROM furnitures WHERE id=?", getElementData(element, "furniture->Id"));

		destroyElement(element);
	end
end);