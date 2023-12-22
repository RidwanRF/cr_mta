local removedWorldModels = {};
local infos = {};
infos["create"] = 0;
infos["remove"] = 0;

addEventHandler("onClientResourceStart", resourceRoot, function()
	setOcclusionsEnabled(false);
	engineSetAsynchronousLoading(true, false);
	
	local startTick = getTickCount();

	outputDebugString("Starting map create...");

	for i, k in pairs(mapsdatas) do
		if k[1] == "remove" then
			local x, y, z = k.posX, k.posY, k.posZ;
			local interior = k.interior;
			local radius = k.radius;
			local model = k.model;

			local remove = removeWorldModel(model, radius, x, y, z, interior);
			if remove then
				infos["remove"] = infos["remove"] + 1;

				table.insert(removedWorldModels, {model, radius, x, y, z, interior});
			end
		elseif k[1] == "create" then
			local x, y, z = k.posX, k.posY, k.posZ;
			local interior = k.interior;
			local model = k.model;
			local rotx, roty, rotz = k.rotX, k.rotY, k.rotZ;
			local alpha = k.alpha;
			local scale = k.scale;
			local dimension = k.dimension;
			local collisions = k.collisions;
			local breakable = k.breakable;
			local doublesided = k.doublesided;

			local object = createObject(model, x, y, z, rotx, roty, rotz);
			if object then
				setElementAlpha(object, alpha);
				setObjectScale(object, scale);
				setElementDoubleSided(object, doublesided and true or false);
				setElementCollisionsEnabled(object, collisions and true or false);
				setObjectBreakable(object, breakable and true or false);
				setElementInterior(object, interior);
				setElementDimension(object, dimension);

				infos["create"] = infos["create"] + 1;
			end
		end
	end

	local endTick = getTickCount();
	outputDebugString("Map loaded in "..((endTick-startTick)).."ms. ("..infos["remove"].." remove & "..infos["create"].." create)");
end);

addEventHandler("onClientResourceStop", resourceRoot, function()
	for i, k in pairs(removedWorldModels) do
		local x, y, z = k[3], k[4], k[5];
		local interior = k[6];
		local radius = k[2];
		local model = k[1];

		local restore = restoreWorldModel(model, radius, x, y, z, interior);
		if restore then
			table.remove(removedWorldModels, i);
		end
	end
end);