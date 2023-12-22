local datas = {
    ["database"] = "mta.logs",
    ["host"] = "localhost",
    ["name"] = "root",
    ["password"] = "",
}

local connection

local firstConnection = true

local tables = {}

function connectToMySQL()
    connection = dbConnect("mysql", "dbname="..datas["database"]..";host="..datas["host"].."", datas["name"], datas["password"], "log=1")
    if connection then
        outputDebugString("Sikeres MYSQL kapcsolat!")
        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    for i, row in pairs(query) do
                        local table = fromJSON(tostring(row["table"]))
                        if table then
                            tables = table
                        end
                    end
                end
            end, connection, "SELECT `table` FROM `logs.tableSave` WHERE `ID`=1"
        )
        if not firstConnection then
            restartResource(getThisResource())
            firstConnection = true
        end
    else
        outputDebugString("Sikertelen MYSQL kapcsolat!, (Result: Timer started)", 2)    
        setTimer(connectToMySQL, 10000, 1)
        firstConnection = false
    end
end
addEventHandler("onResourceStart", resourceRoot, connectToMySQL)

addEventHandler("onResourceStop", resourceRoot,
    function()
        dbExec(connection, "UPDATE `logs.tableSave` SET `table`=? WHERE `ID`=1", toJSON(tables))
    end
)

function addLog(sourceElement, folder, type, text)
    if not sourceElement then return end
    if not folder then return end
    if not type then return end
    if not text then return end
    
    
    local sourceID
    if isElement(sourceElement) then
        sourceID = (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement))
    else
        sourceID = tonumber(sourceElement)
    end
    
    if not sourceID then return end
    
    if not tables[type.."-logs"] then
        dbExec(connection, "CREATE TABLE IF NOT EXISTS `"..type.."-logs` (`id` INTEGER NOT NULL primary key AUTO_INCREMENT, `datum` varchar(255) NOT NULL, `text` varchar(255) NOT NULL, `sourceID` varchar(255) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;")
        tables[type.."-logs"] = true
    end
    
    dbExec(connection, "INSERT INTO `"..type.."-logs` SET `datum`=NOW(), `text`=?, `sourceID`=?", text, sourceID)
    
end
addEvent("addLog", true)
addEventHandler("addLog", root, addLog)

function clearLog(folder, type)
    if tables[type.."-logs"] then
        dbExec(connection, "DROP TABLE `"..type.."-logs`")
        tables[type.."-logs"] = nil
        addLog(-1, folder, type, "StartLog")
        return true, "Törölve"
    end
    
    return false, "Nincs ilyen tábla"
end
addEvent("clearLog", true)
addEventHandler("clearLog", root, clearLog)

function getLog(sourceElement, folder, type)
    if not sourceElement then return end
    if not folder then return end
    if not type then return end
    
    local sourceID
    if isElement(sourceElement) then
        sourceID = (tonumber(getElementData(sourceElement, "acc >> id")) or inspect(sourceElement))
    else
        sourceID = tonumber(sourceElement)
    end
    
    if not sourceID then return end
    
   if tables[type.."-logs"] then
        local returnTable = {}
        --[[dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then
                    for i, row in pairs(query) do
                        local id = tonumber(row["id"])
                        local datum = tostring(row["datum"])
                        local text = tostring(row["text"])
                        returnTable[id] = {datum, text}
                    end
                end
            end, connection, "SELECT * FROM `" .. type .. "-logs`"
        )]]
        local query = dbQuery(connection, "SELECT * FROM `" .. type .. "-logs` WHERE `sourceID`=?", sourceID)
        local queryhandle, query_lines = dbPoll(query, -1)
        if query_lines > 0 then
            for i, row in pairs(queryhandle) do
                local id = tonumber(row["id"])
                local datum = tostring(row["datum"])
                local text = tostring(row["text"])
                local sourceID = tonumber(row["sourceID"])
                returnTable[id] = {datum, text, sourceID}
            end
        end
        return returnTable
    end
    return false
end
addEvent("getLog", true)
addEventHandler("getLog", root, getLog)