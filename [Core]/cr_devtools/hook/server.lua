local debugResoruce = nil
_G["postEvent"] = function( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
    local args = { ... }
    local srctype = eventSource and getElementType(eventSource)
    local resname = sourceResource and getResourceName(sourceResource)
    local plrname = eventClient and getPlayerName(eventClient)
    outputDebugString( "postEvent"
        .. " " .. tostring(resname)
        .. " " .. tostring(eventName)
        .. " source:" .. tostring(srctype)
        .. " player:" .. tostring(plrname)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["preEvent"] = function( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
    local args = { ... }
    local srctype = eventSource and getElementType(eventSource)
    local resname = sourceResource and getResourceName(sourceResource)
    local plrname = eventClient and getPlayerName(eventClient)
    outputDebugString( "preEvent"
        .. " " .. tostring(resname)
        .. " " .. tostring(eventName)
        .. " source:" .. tostring(srctype)
        .. " player:" .. tostring(plrname)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["preFunction"] = function( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
    local args = { ... }
    local resname = sourceResource and getResourceName(sourceResource)
    outputDebugString( "preFunction"
        .. " " .. tostring(resname)
        .. " " .. tostring(functionName)
        .. " allowed:" .. tostring(isAllowedByACL)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["postFunction"] = function( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
    local args = { ... }
    local resname = sourceResource and getResourceName(sourceResource)
	if resname == "devtools" then return end
    outputDebugString( "postFunction"
        .. " " .. tostring(resname)
        .. " " .. tostring(functionName)
        .. " allowed:" .. tostring(isAllowedByACL)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

local types = {}
types[1] = "preFunction"
types[2] = "preEvent"
types[3] = "postEvent"
types[4] = "postFunction"
types[5] = "all"

local debugEnabled = false
local actualDebug = 0
local syntax = exports['cr_core']:getServerSyntax("Developer")

function disableDebug(player)
	if debugEnabled then
		debugEnabled = false
		local str = types[actualDebug]
		if str == "all" then
			for i=1,4 do
				removeDebugHook(types[i], _G[types[i]])
			end
		else
			removeDebugHook(str, _G[str])
		end
		outputChatBox(syntax..""..str.." debughook removed! ("..getResourceName(debugResoruce)..")", player, 255, 0, 0, true)
		debugResoruce = nil
	end
end

addCommandHandler("sdebughook", 
    function(player,cmd,debug_type,res)
        disableDebug(player)
        if not exports['cr_core']:isPlayerDeveloper(player) then return end
        debug_type = tonumber(debug_type)
        if not debug_type or not types[debug_type] or not res then
            outputChatBox(syntax.."/"..cmd.." [1:preFunction | 2:preEvent | 3:postEvent | 4:postFunction | 5:all] [Resource]", player, 255, 0, 0, true)
        else
            local resourceName = res
            local res = getResourceFromName(resourceName)
            if not res then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")    
                outputChatBox(syntax.."#FFFFFFHibás resource: "..resourceName, player)
                return
            end
            debugResoruce = res
            debugEnabled = true
            actualDebug = debug_type
            local str = types[actualDebug]
            local syntax = exports['cr_core']:getServerSyntax(false, "success")        
            outputChatBox(syntax..""..str.." horog hozzáadva! ("..resourceName.." | SERVER)", player, 255, 0, 0, true)

            if str == "all" then
                for i=1,4 do
                    addDebugHook(types[i], _G[types[i]])
                end
            else
                addDebugHook(str, _G[str])
            end
        end
    end
)