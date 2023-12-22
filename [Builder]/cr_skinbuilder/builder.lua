local path = "";

local builtModels = {};

local function randomBytes(count, seed)
	if seed then
		math.randomseed(seed);
	end

	local str = "";
	for i = 1, count do
		str = str .. string.char(math.random(0, 255));
	end

	return str;
end


function copyFile(path1, path2)
    return fileCopy(path1, path2, true);
end

function encryptModels(resource, model, filename, hascol)
	local resourcePath = ":" .. resource.name .. "/"
	local resourceMeta = XML.load(resourcePath .. "meta.xml")
    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'");
        return;
    end

    local paths = {};
    underscore.each(resourceMeta.children, function (child)
    	if child.name ~= "file" then
    		return;
    	end

    	local path = child:getAttribute("src");
    	if not path then
    		return;
    	end

    	if filename == path:gsub(".txd", ""):gsub(".dff", ""):gsub(".col", ""):gsub("files/", "") then
    		if string.find(path, "dff") then
	    		paths.dff = path;
	    	elseif string.find(path, "txd") then
	    		paths.txd = path;
	    	elseif string.find(path, "col") and hascol then
	    		paths.col = path;
	    	end
    	end
    end);

    if not paths.dff then 
		outputDebugString("Missing DFF for '" .. filename .. "'")
		return false;
	end

	if hascol and not paths.col then
		outputDebugString("Missing col for '" .. filename .. "'")
		return false;
	end

	if not paths.txd then 
		outputDebugString("Missing TXD for '" .. filename .. "'")
		return false;
	end

	local buildPath = ":cr_models/";
    local dff = loadFile(resourcePath .. paths.dff);
    local txd = loadFile(resourcePath .. paths.txd);

    local col = nil;
    if paths.col and hascol then
    	col = loadFile(resourcePath .. paths.col);
    end

    local seed = #dff + #txd;

    local randomHeader = randomBytes(8, seed) .. "STAYMTA" .. randomBytes(math.random(512, 512 * 4), seed);

    local outputFileData = randomHeader .. dff .. txd .. (hascol and col or "");
    local outputFileName = tostring("" .. tostring(model)) .. ".staymodel";

    saveFile(buildPath .. outputFileName, outputFileData);

    table.insert(builtModels, {
    	model,
    	outputFileName,
    	#randomHeader,
    	#dff,
    	#txd,
    	hascol and #col or 0,
    });

    return true;
end

addCommandHandler("encrypt", function()
	builtModels = {};
	local count = {};
	count["fail"] = 0;
	count["success"] = 0;

	for i, k in pairs(cache) do
		local resource = getResourceFromName("cr_modpanel");
		if encryptModels(resource, i, k[1], k[3]) then
			count["success"] = count["success"] + 1;
		else
			count["fail"] = count["fail"] + 1;
		end
	end

	local buildPath = ":cr_models/";
    local meta =  XML(buildPath .. "meta.xml", "meta");

    local resource = getResourceFromName("cr_models");
    if resource then
        local state = exports.cr_builder:unbuildResource(resource);
    end

    meta:createChild("oop").value = "true";

    local vehiclesArrayString = "{\n";
    for i, info in ipairs(builtModels) do
    	local fileChild = meta:createChild("file");
    	fileChild:setAttribute("src", info[2]);
    	--vehiclesArrayString = vehiclesArrayString .. "\t" .. arrayToString(info) .. ",\n";
        vehiclesArrayString = vehiclesArrayString .. "\t" .. "["..info[1].."] = {\""..tostring(info[2]).."\", "..info[3]..", "..info[4]..", "..info[5]..", "..info[6].."}" .. ",\n";
    end

    vehiclesArrayString = vehiclesArrayString .. "};";

    local scriptChild = meta:createChild("script");
    local loaderFile = "";

    loaderFile = loaderFile .. "VEHICLES_LIST = " .. vehiclesArrayString .. "\n\n";
    loaderFile = loaderFile .. loadFile("files/loader.lua") .. "\n";
    local loaderFilePath = "loader.lua";

    saveFile(buildPath .. loaderFilePath, loaderFile);
    scriptChild:setAttribute("type", "client");
    scriptChild:setAttribute("src", loaderFilePath);
    scriptChild:setAttribute("cache", "false");

    copyFile("files/client.lua", buildPath .. "client.lua");
    local scriptChild = meta:createChild("script");
    scriptChild:setAttribute("type", "client");
    scriptChild:setAttribute("src", "client.lua");
    scriptChild:setAttribute("cache", "false");

    copyFile("global.lua", buildPath .. "global.lua");
    local scriptChild = meta:createChild("script");
    scriptChild:setAttribute("type", "shared");
    scriptChild:setAttribute("src", "global.lua");
    scriptChild:setAttribute("cache", "false");

    meta:saveFile();
    meta:unload();
    exports.cr_builder:processResource(resource);

    outputDebugString("Done building (" .. tostring(count["success"]) .. "/" .. tostring(count["fail"] + count["success"]) .. ")");
end);