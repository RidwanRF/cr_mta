local syntax = exports['cr_core']:getServerSyntax(nil, "success")
local syntax2 = exports['cr_core']:getServerSyntax(nil, "warning")
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
	        syntax = exports['cr_core']:getServerSyntax(nil, "success")
            syntax2 = exports['cr_core']:getServerSyntax(nil, "warning")
        end
	end
)

local resources = {}
local lastResource = 0
function compileResource(res, bool, resource)
	local xmlPatch = ":"..res.."/meta.xml"
	local xmlFile = xmlLoadFile(xmlPatch)
	if xmlFile then
		outputDebugString("RESOURCE: "..res,0,55,167,220)
		local index = 0
		local scriptNode = xmlFindChild(xmlFile,'script',index)
		if scriptNode then
			repeat
                local scriptPath = xmlNodeGetAttribute(scriptNode,'src') or false
                local scriptType = xmlNodeGetAttribute(scriptNode,'type') or "server"
                local serverEncypt = xmlNodeGetAttribute(scriptNode,'encypt') or "null"
                if scriptPath and (scriptType:lower() == "client" or serverEncypt:lower() == "true") then
                    if string.find(scriptPath:lower(), "luac") then
                        outputDebugString("LEVÉDÉS: Fájl "..scriptPath.." már levan védve!",3,220,20,20)
                    else
                        local FROM=":"..res.."/"..scriptPath
                        local TO= ":"..res.."/"..scriptPath.."c"
                        fetchRemote("http://luac.mtasa.com/?compile=1&debug=0&obfuscate=1", function(data) fileSave(TO,data) end, fileLoad(FROM), true)
                        xmlNodeSetAttribute(scriptNode,'src',scriptPath..'c')
                        if serverEncypt:lower() == "true" then
                            if fileExists(FROM) then
                                outputDebugString("LEVÉDÉS: ".. FROM.." törölve. (encypt = true)",3,0,255,0)
                                fileDelete(FROM)
                            end
                        end
                        outputDebugString("LEVÉDÉS: ".. TO.." Levédve és elmentve",3,0,255,0)
                    end
                end
                index = index + 1
                scriptNode = xmlFindChild(xmlFile,'script',index)
                if not scriptNode then
                    if bool then
                        setTimer(
                            function(resource)
                                refreshResources(true, resource)
                                setTimer(
                                    function(resource)
                                        startResource(resource)
                                        outputChatBox(syntax .. "Resource elindítva.", player, 255, 0, 0, true)
                                    end, 1000, 1, resource
                                )
                            end, 2000, 1, getResourceFromName(res)
                        )
                    end
                end
			until not scriptNode
		end
		xmlSaveFile(xmlFile)
		xmlUnloadFile(xmlFile)
	else
		outputDebugString("LEVÉDÉS: Nem olvasható: meta.xml",3,220,20,20)
		return false
	end
end

--[[addEventHandler("onResourceStart", resourceRoot,
	function()
		for key, resource in ipairs(getResources()) do
			local xmlFile = xmlLoadFile(":" .. getResourceName(resource) .. "/meta.xml")
			if xmlFile then
				local index = 0
				local node = xmlFindChild(xmlFile, "script", index)
				repeat
					local type = xmlNodeGetAttribute(node, "type") or "server"
					if type == "client" then
						xmlNodeSetAttribute(node, "cache", "false")
					end
					index = index + 1
					node = xmlFindChild(xmlFile, "script", index)
				until not node
				xmlSaveFile(xmlFile)
				xmlUnloadFile(xmlFile)
			end
		end
	end
)]]

function uncompileResource(res, bool, resource)
    if bool then
        stopResource(resource)
        outputChatBox(syntax .. "Resource leállítva.", player, 255, 0, 0, true)
    end
	local xmlPatch = ":"..res.."/meta.xml"
	local xmlFile = xmlLoadFile(xmlPatch)
	if xmlFile then
		outputDebugString("RESOURCE: "..res,0,55,167,220)
		local index = 0
		local scriptNode = xmlFindChild(xmlFile,'script',index)
		if scriptNode then
			repeat
			local scriptPath = xmlNodeGetAttribute(scriptNode,'src') or false
			local scriptType = xmlNodeGetAttribute(scriptNode,'type') or "server"
			if scriptPath and scriptType:lower() == "client" then
				if string.find(scriptPath:lower(), "luac") then
					fileDelete(":"..res.."/"..scriptPath)
					xmlNodeSetAttribute(scriptNode,'src',scriptPath:gsub("luac","lua"))
					outputDebugString("LEVÉDÉS: "..res.."/"..scriptPath .." már nem védett!",0,255,0,0)
				else
					outputDebugString("LEVÉDÉS: Fájl "..scriptPath.." már nincs levédve védett!",3,220,20,20)
				end
			end
			index = index + 1
			scriptNode = xmlFindChild(xmlFile,'script',index)
            if not scriptNode then
                if bool then
                    setTimer(
                        function()
                            compileResource(res, true, resource)
                            outputChatBox(syntax .. "Resource levédve.", player, 255, 0, 0, true)
                        end, 1000, 1
                    )
                end
            end
			until not scriptNode
		end
		xmlSaveFile(xmlFile)
		xmlUnloadFile(xmlFile)
	else
		outputDebugString("LEVÉDÉS: Nem olvasható: meta.xml",3,220,20,20)
		return false
	end
end

addCommandHandler("compileall", function(player,cmd)
	if exports['cr_core']:getPlayerDeveloper(player) or getElementType(player) == "console" then
		resources = getResources()
		lastResource = 0
		compileNextResource()
	end
end)

function compileNextResource()
	if lastResource < #resources then
		lastResource = lastResource + 1
		compileResource(getResourceName(resources[lastResource]))
		setTimer(compileNextResource, 1000, 1)
	end
end

addCommandHandler("compile", function(player,cmd,res)
	if exports['cr_core']:getPlayerDeveloper(player) or getElementType(player) == "console" then
        if not res then
            outputChatBox(syntax2 .. "/" .. cmd .. " [resname]", player, 0, 255, 0, true)
            return
        end
		local resource = getResourceFromName(res)
		if resource then
			outputChatBox(syntax .. "Resource levédése folyamatban ...", player, 0, 255, 0, true)
			compileResource(res)
			outputChatBox(syntax .. "Resource levédve!", player, 0, 255, 0, true)
		else
			outputChatBox(syntax .. "Nem található ilyen resource!", player, 255, 0, 0, true)
		end
	end
end)

addCommandHandler("recompile", function(player,cmd,res)
	if exports['cr_core']:getPlayerDeveloper(player) or getElementType(player) == "console" then
        if not res then
            outputChatBox(syntax2 .. "/" .. cmd .. " [resname]", player, 0, 255, 0, true)
            return
        end
		local resource = getResourceFromName(res)
		if resource then
            uncompileResource(res, true, resource)
            outputChatBox(syntax .. "Resource levédése feloldva.", player, 255, 0, 0, true)
		else
			outputChatBox(syntax .. "Nem található ilyen resource!", player, 255, 0, 0, true)
		end
	end
end)

addCommandHandler("uncompile", function(player,cmd,res)
	if exports['cr_core']:getPlayerDeveloper(player) or getElementType(player) == "console" then
        if not res then
            outputChatBox(syntax2 .. "/" .. cmd .. " [resname]", player, 0, 255, 0, true)
            return
        end
		local resource = getResourceFromName(res)
		if resource then
			outputChatBox(syntax .. "Resource levédés levétel folyamatban ...", player, 0, 255, 0, true)
			uncompileResource(res)
			outputChatBox(syntax .. "Resource levédés levéve!", player, 0, 255, 0, true)
		else
			outputChatBox(syntax .. "Nem található ilyen resource!", player, 255, 0, 0, true)
		end
	end
end)

function fileLoad(path)
    local File = fileOpen(path, true)
    if File then
        local data = fileRead(File, 500000000)
        fileClose(File)
        return data
    end
end
 
function fileSave(path, data)
    local File = fileCreate(path)
    if File then
        fileWrite(File, data)
        fileClose(File)
    end
end