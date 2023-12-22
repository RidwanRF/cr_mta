local cache = {}

local connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

Async:setPriority("high")
Async:setDebug(true)

addEventHandler("onResourceStart", resourceRoot, 
    function()
        dbQuery(function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                --for i, row in pairs(query) do
                Async:foreach(query, function(row)
                    --local id = tonumber(row["id"])
                    loadSpeedCam(row)
                end) 
            end
			outputDebugString("[Success] Loading speedcams has finished successfuly. Loaded: " .. query_lines .. " speedcams!")
        end, connection, "SELECT * FROM `speedcams`")
    end
)

function loadSpeedCam(details)
    local id = tonumber(details["id"])
    local type = tonumber(details["type"])
    local pos = fromJSON(tostring(details["pos"]))
    local colpos = fromJSON(tostring(details["colpos"]))
    local modelid = 1331
    if type == 1 then
        modelid = 1372
    end
    local x,y,z,int,dim,rot,speedLimit = unpack(pos)
    local object = createObject(modelid, x,y,z)
    setElementDimension(object, dim)
    setElementInterior(object, int)
    setElementRotation(object, 0,0,rot)
    setElementFrozen(object, true)
    setElementData(object, "traffipax.id", id)
    setElementData(object, "traffipax.type", type)
    setElementData(object, "traffipax.object", true)
    setElementData(object, "traffipax.speedLimit", speedLimit)
    --setElementData(object, "traffipax.pairObject", col)
    
    --[[
        Cuboid sizeok:
        Type 1: 4, 15, 2
        Type 2: 4, 30, 2
    ]]
    
    local cx,cy,cz,cint,cdim,cw,cd,ch = unpack(colpos)
    local col = createColCuboid(cx, cy, cz, cw, cd, ch)
    setElementInterior(col, cint)
    setElementDimension(col, cdim)
    setElementData(col, "traffipax.id", id)
    setElementData(col, "traffipax.type", type)
    setElementData(col, "traffipax.object", true)
    setElementData(col, "traffipax.speedLimit", speedLimit)
    setElementData(col, "traffipax.pairObject", object)
    setElementData(object, "traffipax.pairObject", col)
end

function createTraffiPax(table1, table2, type, sourceElement)
    local a1 = toJSON(table1)
    local a2 = toJSON(table2)
    dbExec(connection, "INSERT INTO `speedcams` SET `pos`=?, `colpos`=?, `type`=?", a1, a2, type)
    
    dbQuery(function(query)
        local query, query_lines = dbPoll(query, 0)
        if query_lines > 0 then
            --for i, row in pairs(query) do
            Async:foreach(query, function(row)
                local id = tonumber(row["id"])
                local syntax = exports['cr_core']:getServerSyntax("Traffipax", "success")
                local green = exports['cr_core']:getServerColor(nil, true)        
                outputChatBox(syntax .. "Sikeresen létrehoztál egy traffipaxot, #ID: "..green..id, sourceElement, 255,255,255,true)
                loadSpeedCam(row)
            end) 
        end
        --outputDebugString("[Success] Loading speedcams has finished successfuly. Loaded: " .. query_lines .. " speedcams!")
    end, connection, "SELECT * FROM `speedcams` WHERE `pos`=?", a1)
end
addEvent("createTraffiPax", true)
addEventHandler("createTraffiPax", root, createTraffiPax)

function deleteTraffipax(object)
    local id = getElementData(object, "traffipax.id") or 0
    local pairObject = getElementData(object, "traffipax.pairObject") or 0
    
    destroyElement(object)
    destroyElement(pairObject)
    
    dbExec(connection, "DELETE FROM `speedcams` WHERE `id`=?", id)
end
addEvent("deleteTraffipax", true)
addEventHandler("deleteTraffipax", root, deleteTraffipax)

addEvent("ticket", true)
addEventHandler("ticket", root,
    function(e, m)
        exports['cr_faction_scripts']:createTicket(e, "Traffipax sebesség átlépés", m, getRealTime()["timestamp"] + (7 * 24 * 60 * 60))
    end
)