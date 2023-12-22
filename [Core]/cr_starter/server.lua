local subTag = "cr_"
local importantResources = {subTag .. "protect", subTag .. "mysql", subTag .. "core", subTag .. "anticheat", subTag .. "whitelist", subTag .. "network", subTag .. "fonts", subTag .. "interface"}
local excludeResources = {
    [subTag .. "protect"] = true,
    [subTag .. "network"] = true,
    [subTag .. "fonts"] = true,
    [subTag .. "mysql"] = true,
    [subTag .. "core"] = true,
    [subTag .. "whitelist"] = true,
    [subTag .. "anticheat"] = true,
    [subTag .. "interface"] = true,
}
local threadTimer
local threads = {}
local load_speed = 1000 -- Hány másodpercenként töltsön be load_speed_multipler számú resourceot
local load_speed_multipler = 2 -- Hány resource-t töltsön be load_speed időnként
local canConnect = false

addEventHandler("onResourceStart", resourceRoot,
    function()
        
        for v, k in ipairs(importantResources) do
            local res = getResourceFromName(k)
            if res then
                startResource(res)
                outputDebugString(k.. " resource has started! (Important resource)", 2)
            end
        end
        
        for k,v in pairs(getResources()) do
            local subText = utfSub(getResourceName(v), 1, #subTag)
            if subText == subTag and not excludeResources[getResourceName(v)] and v ~= getThisResource() then 
                threads[v] = true
            end
        end
        
        threadTimer = setTimer(
            function()
                local num = 0
                
                for k,v in pairs(threads) do
                    num = num + 1
                    
                    if num > load_speed_multipler then
                        break
                    end
                    
                    startResource(k)
                    
                    threads[k] = nil
                    
                    outputDebugString(getResourceName(k).. " resource has started!", 2)
                end
                
                local length = 0
                for k,v in pairs(threads) do length = length + 1 end
                if length == 0 then
                    killTimer(threadTimer)
                    outputDebugString("All resource started!", 3)
                    threadTimer = nil
                    canConnect = true
                end
            end, load_speed, 0
        )
    end
)

addEventHandler("onPlayerConnect", root,
    function()
        if not canConnect then
            cancelEvent(true, "Rendszer \n Nem tudsz felcsatlakozni míg a resourceok nem töltődtek be!")
        end
    end
)

function hasPermission(element)
    return exports['cr_core']:getPlayerDeveloper(element)
end

--[[
addCommandHandler("stopResources",
    function(source, cmd)
        
        if not hasPermission(source) then return end
        
        for k,v in pairs(getResources()) do
            if getResourceState(v) == "running" and not v == getThisResource() then
                threads[v] = true
            end
        end
        
        threadTimer = setTimer(
            function()
                local num = 0
                
                for k,v in pairs(threads) do
                    num = num + 1
                    
                    if num > load_speed_multipler then
                        break
                    end
                    
                    stopResource(k)
                    
                    threads[k] = nil
                    
                    outputDebugString(getResourceName(k).. " resource has stopped!", 2)
                end
                
                local length = 0
                for k,v in pairs(threads) do length = length + 1 end
                if length == 0 then
                    killTimer(threadTimer)
                    outputDebugString("All resource stopped!", 3)
                    threadTimer = nil
                    canConnect = true
                end
            end, load_speed, 0
        )
    end
)
]]