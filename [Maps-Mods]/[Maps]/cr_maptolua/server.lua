function readFile(path)
    local file = fileOpen(path) -- attempt to open the file
    if not file then
        return false -- stop function on failture
    end
    local count = fileGetSize(file) -- get file's total size
    local data = fileRead(file, count) -- read whole file
    fileClose(file) -- close the file once we're done with it
    --outputConsole(data) -- output code in console
    
    return data
end

function convertMapToLua(resName, spec)
    if not resName then return end
    
    local res = getResourceFromName(resName)
    if res then
        local xml = xmlLoadFile(":"..resName.."/meta.xml")
        local node = xmlFindChild(xml, "map", 0)
        --local attrs = xmlNodeGetAttributes(node)
        local src = xmlNodeGetAttribute(node, "src")
        xmlDestroyNode(node)
        
        local node = xmlFindChild(xml, "info", 0)
        xmlDestroyNode(node)
        
        local node = xmlFindChild(xml, "script", 0)
        xmlDestroyNode(node)
        
        local node = xmlFindChild(xml, "script", 0)
        xmlDestroyNode(node)
        
        local node = xmlFindChild(xml, "settings", 0)
        xmlDestroyNode(node)
        
        local node = xmlCreateChild(xml, "file")
        xmlNodeSetAttribute(node, "src", "map.xml")
        
        local node = xmlCreateChild(xml, "script")
        xmlNodeSetAttribute(node, "src", "map.lua")
        xmlNodeSetAttribute(node, "type", "server")
        
        xmlSaveFile(xml)
        xmlUnloadFile(xml)
        
        --XML Done
        
        --local data = readFile(":"..resName.."/"..src)
        fileRename(":"..resName.."/"..src, ":"..resName.."/".."map.xml")
        
        --local file = fileCreate(":"..resName.."/map.lua")
        if spec then
            fileCopy("str1.lua", ":"..resName.."/map.lua")
        else
            fileCopy("str2.lua", ":"..resName.."/map.lua")
        end
        --fileClose(file)
        
        setTimer(restartResource, 200, 1, res)
        
        outputDebugString(resName .. " map succesfuly converted into lua!")
    end
end
--convertMapToLua("cr_delimap", true)

addCommandHandler("convertmap", 
    function(p, cmd, val, val2)
        if not val then return end
        if val2 then val2 = true end
        if exports['cr_permission']:hasPermission(p, cmd) then
            convertMapToLua(tostring(val), val2)
        end
    end
)
--outputChatBox(str1)