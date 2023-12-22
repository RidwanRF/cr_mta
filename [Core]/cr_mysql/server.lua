local datas = {
    ["database"] = "mtadev",
    ["host"] = "localhost",
    ["name"] = "root",
    ["password"] = "",
}

local connection

local firstConnection = true

function connectToMySQL()
    connection = dbConnect("mysql", "dbname="..datas["database"]..";host="..datas["host"].."", datas["name"], datas["password"], "log=1")
    if connection then
        outputDebugString("Sikeres MYSQL kapcsolat!")
        if not firstConnection then
            restartResource(getThisResource())
            firstConnection = true
        end
    else
        outputDebugString("Sikertelen MYSQL kapcsolat!, (Result: Timer started)", 1)    
        setTimer(connectToMySQL, 10000, 1)
        firstConnection = false
    end
end
addEventHandler("onResourceStart", resourceRoot, connectToMySQL)

function getConnection(res)
    if res then
        local resName = getResourceName(res)
        if resName then
            outputDebugString("Connection requested by resource "..resName.."!")
            return connection
        end
    end
end
--getConnection("ASD")

function requestConnection()
	if not connection then
		outputChatBox("[StayMTA - Connection] Kapcsolat megszakadt!")
		return
	end
	return connection
end