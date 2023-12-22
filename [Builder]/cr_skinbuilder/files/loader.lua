local loadFromRAM = true;

local function saveFile(path, data)
    if not path then
        return false;
    end

    if fileExists(path) then
        fileDelete(path);
    end

    local file = fileCreate(path);
    fileWrite(file, data);
    fileClose(file);

    return true
end

function loadModel(model, fileName, headerLength, dffLength, txdLength, colLenght)
	local file = fileOpen(fileName);
	if not file then
		return;
	end

	file.pos = headerLength;
	local dffData = file:read(dffLength);
	local txdData = file:read(txdLength);

	local colData = nil;
	if colLenght > 0 then
		colData = file:read(colLenght);
	end

	-- TXD
	local txd;
	if not loadFromRAM then
		txd = engineLoadTXD(txdData);
	else
		saveFile("tmp", txdData);
		txd = engineLoadTXD("tmp");			
	end
	if txd then		
		engineImportTXD(txd, model);
	end

	-- DFF
	local dff;
	if loadFromRAM then
		dff = engineLoadDFF(dffData);
	else
		saveFile("tmp", dffData);
		dff = engineLoadDFF("tmp");
	end

	if dff then
		engineReplaceModel(dff, model);
	end

	local col;
	if colData then
		if loadFromRAM then
			col = engineLoadCOL(colData);
		else
			saveFile("tmp", colData);
			col = engineLoadCOL("tmp");
		end

		if col then
			engineReplaceCOL(col, model);
			outputDebugString(model)
		end
	end

	if fileExists("tmp") then
		fileDelete("tmp");
	end

	file:close();
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if not VEHICLES_LIST then
		outputDebugString("cr_modpanel error: no VEHICLES_LIST")
		cancelEvent();
	end

	engineSetAsynchronousLoading(false, false);

	for i, info in ipairs(VEHICLES_LIST) do
		--loadModel(unpack(info));
	end
end)

