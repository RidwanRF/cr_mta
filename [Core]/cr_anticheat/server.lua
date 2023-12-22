addEvent("acheat:kick", true)
addEventHandler("acheat:kick", root,
    function(e, reason)
	    kickPlayer(e, "Rendszer", reason)
	end
)

white = "#ffffff"

connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
	        connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
	end
)

local blockedSerials = {}
local res = Resource.getFromName("cr_core") 
if res and res.state == "running" then
    syntax = exports['cr_core']:getServerSyntax(false, "success")
    syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
    syntax3 = exports['cr_core']:getServerSyntax(false, "error")
end

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
	        syntax = exports['cr_core']:getServerSyntax(false, "success")
            syntax2 = exports['cr_core']:getServerSyntax(false, "warning")
            syntax3 = exports['cr_core']:getServerSyntax(false, "error")
        end
	end
)

function debugOnResourceStart(startedRes)
    local time = exports['cr_core']:getTime() .. " "
    local resName = getResourceName(startedRes)
    exports['cr_logs']:addLog(-1, "ResourceStart", "start", resName .. " - started!")
    outputDebugString(time .. "" .. resName .. " - started!", 0, 20,20,20)
end
addEventHandler("onResourceStart", root, debugOnResourceStart)

function debugOnResourceStop(stoppedRes)
    local time = exports['cr_core']:getTime() .. " "
    local resName = getResourceName(stoppedRes)
    exports['cr_logs']:addLog(-1, "ResourceStop", "stop", resName .. " - stopped!")
    outputDebugString(time .. "" .. resName .. " - stopped!", 0, 20,20,20)
end
addEventHandler("onResourceStop", root, debugOnResourceStop)