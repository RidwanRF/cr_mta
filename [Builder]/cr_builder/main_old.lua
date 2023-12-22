local LUAC_URL = "http://luac.mtasa.com/?compile=1&debug=0&obfuscate=1";
local config = {};
local compileDone = 0;
local compileTotal = 0;

local moduleStart = "(function()\n";
local moduleEnd = "\nend)();\n\n";

local datas = {};

local function compileScript(path)
    compileTotal = compileTotal + 1;
    local data = loadFile(path);

    fetchRemote(LUAC_URL, function (data, err)
        if not data or err > 0 then
            return
        end

        saveFile(path, data);
        compileDone = compileDone + 1;
        if compileDone >= compileTotal then
            --print("Compiled all scripts")
        else
            --print("Progress: " .. math.floor(compileDone / compileTotal * 100) .. "%")
        end
    end, data, false);
end

local function isPathExcluded(path)
    return underscore.any(config.pathEncryptExclude, function (pattern)
        return not not string.find(path, pattern, 1, true);
    end)
end

local function processResource(resource)
    outputDebugString("compiling: "..resource.name);

    local resourcePath = ":" .. resource.name .. "/";
    local resourceMeta = XML.load(resourcePath .. "meta.xml");

    if not resourceMeta then
        outputDebugString("Failed to open resource '" .. tostring(resource.name) .. "'")
        return;
    end
    
    local concatScripts = {
        client = "",
        server = "",
        shared = ""
    };

    local buildPath = "build/" .. resource.name .. "/";
    if config.enablePathEncrypt then
        concatScripts.shared = concatScripts.shared .. "_exclude_paths=" .. arrayToString(config.pathEncryptExclude) .. ";\n";
        concatScripts.shared = concatScripts.shared .. loadFile("files/path_decrypt.lua") .. "\n\n";
    end

    local buildMeta = XML(buildPath .. "meta.xml", "meta")
    if not buildMeta then
        return;
    end

    local resourceHasClientFiles = false;
    underscore.each(resourceMeta.children, function (child)
        if child.name == "script" then
            local scriptType = child:getAttribute("type") or "server";
            local scriptPath = child:getAttribute("src");
            local scriptData = loadFile(resourcePath .. scriptPath);
            concatScripts[scriptType] = concatScripts[scriptType] .. "-- " .. scriptPath .. "\n".. moduleStart .. scriptData .. moduleEnd;
        else
            local buildChild = buildMeta:createChild(child.name);
            buildChild.value = child.value;
                
            for name, value in pairs(child.attributes) do
                buildChild:setAttribute(name, value);
            end
                
            local sourcePath = buildChild:getAttribute("src");
            if sourcePath then
                local targetPath = sourcePath
                if not config.enableShaderCache and sourcePath:find(".fx") then
                    buildChild:setAttribute("cache", "false");
                end
                                    
                if config.enablePathEncrypt then
                    if isPathExcluded(sourcePath) then
                        if sourcePath:find(".fx") then
                            targetPath = sourcePath:match(".+/(.+)");

                            if not targetPath then
                                targetPath = sourcePath;
                            end
                        end
                    else
                        targetPath = base64Encode("cr-" .. sourcePath);
                    end
                    buildChild:setAttribute("src", targetPath);
                end
                    
                if not png then
                    copyFile(resourcePath .. sourcePath, buildPath .. targetPath);
                end
            end

            if child.name == "file" then
                resourceHasClientFiles = true;
            end

            if config.enableExportEncrypt and child.name == "include" then
                local name = buildChild:getAttribute("resource")
                if name then
                    buildChild:setAttribute("resource", sha256(name));
                end
            end
        end
    end)
    
    resourceMeta:unload();

    local scriptsIncludeOrder = {"shared", "server", "client"};
    underscore.each(scriptsIncludeOrder, function(type)
        local data = concatScripts[type];
        if #data > 0 then
            local child = buildMeta:createChild("script");
            
            local filename = tostring(type) .. ".lua";
            if config.enablePathEncrypt then
                filename = sha256(math.random(1, 999999).."" .. tostring(type)) .. ".bin";
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
    end)

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
        
        if resourceHasClientFiles then
            local child = buildMeta:createChild("file");
            child:setAttribute("src", "readme.txt");
        end
    end
    
    buildMeta:saveFile();
    buildMeta:unload();
end

addCommandHandler("compiles", function(player, cmd, name)
    if exports['cr_core']:getPlayerDeveloper(player) then
        outputDebugString("Start building...2");
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
            
        if not name then
            outputChatBox("Adj meg resource nevet(all = összes resource)", player, 255, 0, 0, true);    
        else
            local resources = getResources();
            config.only = config.only or {};
            config.include = config.include or {};
            config.pathEncryptExclude = config.pathEncryptExclude or {};
                
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
                            outputDebugString(resource.name)
                            return resource.name;
                        end
                    end)
                end
            end
                
            outputDebugString("Found " .. #resources .. " resource(s) to build");
            underscore.each(resources, processResource);
            if config.enableCompilation then
                outputDebugString("Compiling " .. compileTotal .. " scripts...");
            end
        end
    end
end);




