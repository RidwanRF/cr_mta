--[[

	1. triggerhack minden mappába - done
	2. decompile újraírása - done
	3. check h compilálva van e - done
	4. recompile - done
	5. metaba shared kerüljön előre - done
	6. decompileban megnézni h compiled e - done
    7. file-t beleírni metaba - done
]]



local LUAC_URL = "http://luac.mtasa.com/?compile=1&debug=0&obfuscate=1";
local config = {};
local compileDone = 0;
local path = "";

local moduleStart = "(function()\n";
local moduleEnd = "\nend)();\n\n";

local configJSON = loadFile("config.json");
if not configJSON then
    outputDebugString("Failed to open config.json");
    return;
end

config = fromJSON(configJSON);
if not config then
    outputDebugString("Failed to read config.json");
    return;
end

config.only = config.only or {};
config.include = config.include or {};
config.pathEncryptExclude = config.pathEncryptExclude or {};

local function compileScript(path)
    local data = loadFile(path);

    fetchRemote(LUAC_URL, function (data, err)
        if not data or err > 0 then
            return;
        end

        saveFile(path, data);
        compileDone = compileDone + 1;
    end, data, false);
end

function processResource(resource)
    outputDebugString("compiling: "..resource.name);

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'");
        return;
    end
    
    local concatScripts = {};

    local buildPath = resourcePath;
    if config.enablePathEncrypt then
        table.insert(concatScripts, {"shared", "builder.lua", "".. loadFile("files/export_decrypt.lua") .. "\n\n"});
    end

    local compiled = false;

    local files = {};

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
    		outputDebugString(resource.name.." already compiled!");
        	compiled = true;
        	return false;
    	else
	        if child.name == "script" then
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");

	            local scriptData = loadFile(resourcePath .. scriptPath);
	            table.insert(concatScripts, {scriptType, scriptPath, "-- " .. scriptPath .. "\n "..moduleStart .. scriptData .. moduleEnd});
            elseif child.name == "file" then
                local scriptPath = child:getAttribute("src");
                table.insert(files, scriptPath);
	        end
        end
    end);

    local scripts = {};

    for i, k in pairs(concatScripts) do
    	if k[1] == "shared" then
    		table.insert(scripts, 1, k);
    	else
			table.insert(scripts, k);
    	end
    end

    resourceMeta:unload();

    if compiled then return; end

    local buildMeta = XML(buildPath .. "meta.xml", "meta")
    if not buildMeta then
        return;
    end

    buildMeta:createChild("compiled").value = "true";
    buildMeta:createChild("oop").value = "true";

    for i, k in pairs(scripts) do
    	local data = k[3];
    	local type = k[1];
        if #data > 0 then
            local child = buildMeta:createChild("script");
            
            local filename = tostring(k[2]) .. ".lua";

            if config.enablePathEncrypt then
                --filename = sha256(math.random(1, 999999).."" .. tostring(type)) .. ".bin";
                filename =  tostring(k[2]):gsub(".lua", "").. ".stayscript";
            end

            child:setAttribute("src", filename);
            child:setAttribute("type", type);
            child:setAttribute("cache", tostring(not not config.enableScriptCache));

            local save = saveFile(buildPath .. filename, data);
            
            if save then
                if config.enableCompilation then
                    compileScript(buildPath .. filename);
                end
            end
        end
    end

    for i, k in pairs(files) do
        local child = buildMeta:createChild("file");
        child:setAttribute("src", k);
    end

    if config.enableReadmeFiles then
        copyFile("files/readme.txt", buildPath .. "readme.txt");
        
        if config.enableExportEncrypt then
            local file = fileOpen(buildPath .. "readme.txt");
            if file then
                fileWrite(file, "\n"..resource.name);
                fileFlush(file);
                fileClose(file);
            else
                outputDebugString(resource.name .. " readme.txt can't read");
            end
        end
        
        local child = buildMeta:createChild("file");
        child:setAttribute("src", "readme.txt");
        child:setAttribute("readme", "true");
    end
    
    buildMeta:saveFile();
    buildMeta:unload();
    restartResource(getResourceFromName(resource.name));
    outputDebugString(resource.name.." has been compiled and restarted.")
end

function unbuildResource(resource)
	outputDebugString("uncompiling: "..resource.name);

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'")
        return;
    end

    local notcompiled = true;

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
    		notcompiled = false;
    		child:destroy();
    	end

    	if not notcompiled then
    		if child and child.name == "script" then
	            local scriptType = child:getAttribute("type") or "server";
	            local scriptPath = child:getAttribute("src");

	        	if fileExists(resourcePath..scriptPath:gsub(".stayscript", "")..".lua") then
	        		child:setAttribute("src", scriptPath:gsub(".stayscript", ".lua"));
	        		
	        		fileDelete(resourcePath..scriptPath);
	        	elseif fileExists(resourcePath..scriptPath:gsub(".staymap", "")) then
                    child:setAttribute("src", scriptPath:gsub(".staymap", ""));
                    
                    fileDelete(resourcePath..scriptPath);
                else
	        		child:destroy();
	        		fileDelete(resourcePath..scriptPath);
	        	end
	        elseif child and child.name == "file" then
	        	if child:getAttribute("readme") then
	        		local scriptPath = child:getAttribute("src");
	        		fileDelete(resourcePath..scriptPath);
	        		child:destroy();
	        	end
	        end
    	end
    end);

    if notcompiled then
    	outputDebugString(resource.name.." not compiled.");
    	return false;
    end
    
    resourceMeta:saveFile();
    resourceMeta:unload();
    restartResource(getResourceFromName(resource.name));
    outputDebugString(resource.name.." has been uncompiled and restarted.");

    return true;
end

function rebuildResource(resource)
	outputDebugString("rebuilding: "..resource.name);

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'")
        return;
    end

    local notcompiled = true;
    local concatScripts = {};

    if config.enablePathEncrypt then
        table.insert(concatScripts, {"shared", "builder.lua", "".. loadFile("files/export_decrypt.lua") .. "\n\n"});
    end

    underscore.each(resourceMeta.children, function (child)
    	if child.name == "compiled" then
    		notcompiled = false;
    	end

    	if child.name == "script" then
            local scriptType = child:getAttribute("type") or "server";
            local scriptPath = child:getAttribute("src");
            local scriptData = loadFile(resourcePath .. scriptPath);

            if fileExists(resourcePath..scriptPath:gsub(".stayscript", "")..".lua") then
            	local scriptData = loadFile(resourcePath .. scriptPath:gsub(".stayscript", "")..".lua");
            	table.insert(concatScripts, {scriptType, scriptPath:gsub(".stayscript", "")..".lua", "-- " .. scriptPath:gsub(".stayscript", "")..".lua" .. "\n "..moduleStart .. scriptData .. moduleEnd});
            end
        end
    end);

    if notcompiled then
    	outputDebugString(resource.name.." not compiled.");
    	return;
    end

    for i, k in pairs(concatScripts) do
    	local data = k[3];
    	local type = k[1];
        if #data > 0 then
            local filename = tostring(k[2]) .. ".lua";
            if config.enablePathEncrypt then
                --filename = sha256(math.random(1, 999999).."" .. tostring(type)) .. ".bin";
                filename =  tostring(k[2]):gsub(".lua", "").. ".bin";
            end

            local save = saveFile(resourcePath .. filename, data);
            
            if save then
                if config.enableCompilation then
                    compileScript(resourcePath .. filename);
                end
            end
        end
    end

    resourceMeta:saveFile();
    resourceMeta:unload();
    restartResource(getResourceFromName(resource.name));
    outputDebugString(resource.name.." has been recompiled.");
end

addCommandHandler("build", function(player, cmd, name)
    if exports['cr_core']:getPlayerDeveloper(player) then
            
        if not name then
            outputChatBox("Adj meg resource nevet(all = összes resource)", player, 255, 0, 0, true);    
        else
            local resources = getResources();
                
            if name == "cr_mysql" or name == "cr_logs" then
                return;
            end
                
            name = tostring(name);
                
            if name == "all" then
                resources = underscore.filter(resources, function (resource)
                    return resource.name;
                end)
            else
                if getResourceFromName(name) then
                    resources = underscore.filter(resources, function (resource)
                        if resource.name == name then
                            path = ":"..resource.name.."/";
                            return resource.name;
                        end
                    end)
                else
                	return;
                end
            end
                
            outputDebugString("Found " .. #resources .. " resource(s) to build");
            underscore.each(resources, processResource);
            if config.enableCompilation then
                outputDebugString("Compiling " .. compileDone .. " scripts...");
            end
        end
    end
end);

addCommandHandler("unbuild", function(player, cmd, res)
	if exports['cr_core']:getPlayerDeveloper(player) then
		if not res then
			outputChatBox("Adj meg resource nevet(all = összes resource)", player, 255, 0, 0, true); 
		else
			local resources = getResources();
			name = tostring(res);

			if name == "all" then
                resources = resources;
            else
                if getResourceFromName(name) then
                    resources = underscore.filter(resources, function (resource)
                        if resource.name == name then
                            return resource.name;
                        end
                    end)
                else
                	return;
                end
            end

            outputDebugString("Found " .. #resources .. " resource(s) to unbuild");
            underscore.each(resources, unbuildResource);
		end
	end
end);

addCommandHandler("rebuild", function(player, cmd, res)
	if exports['cr_core']:getPlayerDeveloper(player) then
		if not res then
			outputChatBox("Adj meg resource nevet", player, 255, 0, 0, true); 
		else
			local resources = getResources();
			name = tostring(res);

            if getResourceFromName(name) then
                resources = underscore.filter(resources, function (resource)
                    if resource.name == name then
                        return resource.name;
                    end
                end)
            else
            	return;
            end

            outputDebugString("Found " .. #resources .. " resource(s) to unbuild");
            underscore.each(resources, rebuildResource);
		end
	end
end);
