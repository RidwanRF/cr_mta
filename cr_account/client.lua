sx, sy = guiGetScreenSize()
screenSize = {sx, sy}
saveJSON = {}

function jsonGET(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON({["Username"] = "", ["Password"] = "", ["Clicked"] = false, ["haveRPTest"] = false, ["haveFirstTour"] = false, ["soundVolume"] = 1}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

function onLoginStart()
    local data = jsonGET("data/@details.json")
    saveJSON = data
    --Fontok, színek lekérdezése és táblába foglalása, Szituáció elkezdése, login beindítása
    if language == "Unknown" then
        language = getElementData(localPlayer, "language") or "HU"
    end
    local res = Resource.getFromName("cr_fonts")
    if res and res.state == "running" then
        fonts["default-regular"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
        fonts["default-regular-small"] = exports['cr_fonts']:getFont("Rubik-Regular", 11)
        fonts["default-regular-bigger"] = exports['cr_fonts']:getFont("Rubik-Regular", 14)
        fonts["default-bold"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
        fonts["awesomeFont"] = exports['cr_fonts']:getFont("AwesomeFont", 13)
        fonts["awesomeFont2"] = exports['cr_fonts']:getFont("AwesomeFont", 14)
        fonts["awesomeFont3"] = exports['cr_fonts']:getFont("AwesomeFont", 11)
        setTimer(
            function()
                triggerServerEvent("player.banCheck", localPlayer, localPlayer)
            end, 1000, 1
        )
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onLoginStart)

function banResult(boolean)
    if boolean then
        --CreateBan
        if not getElementData(localPlayer, "loggedIn") then
            exports['cr_blur']:createBlur("Loginblur", 5)
            showCursor(true)
            createSituation(1, true)
            fadeCamera(true)
            --toggleAllControls(false, false)
            --exports['cr_custom-chat']:showChat(false)
            showChat(false)
            startBanPanel()
            playSound("files/bansound.mp3", true)
        else
            triggerServerEvent("acheat:kick", localPlayer, localPlayer)
        end
    else
        if not getElementData(localPlayer, "loggedIn") then
            exports['cr_blur']:createBlur("Loginblur", 5)
            startLoginPanel()
            fadeCamera(true)
            --toggleAllControls(false, false)
            --exports['cr_custom-chat']:showChat(false)
            showChat(false)
            createLogoAnimation(1, {sx/2, sy/2 - 190})
            createSituation(1, true)
            startLoginSound()
        else
            setTimer(
                function()
                    if not getElementData(localPlayer, "char >> afk") then
                        local oPlayTime = getElementData(localPlayer, "char >> playedtime")
                        setElementData(localPlayer, "char >> playedtime", oPlayTime + 1)
                    end
                end, 60 * 1000, 0
            )
        end
    end
end
addEvent("banResult", true)
addEventHandler("banResult", root, banResult)

function onCoreStart(startedRes)
    if getResourceName(startedRes) == "cr_fonts" then
        if not getElementData(localPlayer, "loggedIn") then
            fonts["default-regular"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
            fonts["default-regular-bigger"] = exports['cr_fonts']:getFont("Rubik-Regular", 14)
            fonts["default-regular-small"] = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            fonts["default-bold"] = exports['cr_fonts']:getFont("Rubik-Regular", 12)
            fonts["awesomeFont"] = exports['cr_fonts']:getFont("AwesomeFont", 13)
            fonts["awesomeFont2"] = exports['cr_fonts']:getFont("AwesomeFont", 14)
            fonts["awesomeFont3"] = exports['cr_fonts']:getFont("AwesomeFont", 11)
            if page == "Login" then
                createTextBars(page)
            end
            setTimer(
                function()
                    triggerServerEvent("player.banCheck", localPlayer, localPlayer)
                end, 1000, 1
            )
        end
    end
end
addEventHandler("onClientResourceStart", root, onCoreStart)

function onLoginStop()
    jsonSAVE("data/@details.json", saveJSON)
    exports['cr_blur']:removeBlur("Loginblur")
end
addEventHandler("onClientResourceStop", resourceRoot, onLoginStop)

local cursorState = isCursorShowing()
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2]
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

function createTextBars(type)
    Clear()
    if type == "Login" then
        CreateNewBar("Login.Name", {sx/2 - 220/2 - 3, sy/2 - 88, 270, 50}, {20, saveJSON["Username"], false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 1)
        CreateNewBar("Login.Password", {sx/2 - 220/2 - 3, sy/2 - 22, 270, 50}, {20, saveJSON["Password"], false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", true}, 2)
    elseif type == "Register" then
        CreateNewBar("Register.Name", {sx/2 - 220/2 - 3, sy/2 - (88 + 66), 270, 50}, {20, saveJSON["Username"], false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 1)
        CreateNewBar("Register.Password1", {sx/2 - 220/2 - 3, sy/2 - 88, 270, 50}, {20, saveJSON["Password"], false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", true}, 2)
        CreateNewBar("Register.Password2", {sx/2 - 220/2 - 3, sy/2 - 22, 270, 50}, {20, saveJSON["Password"], false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", true}, 3)
        CreateNewBar("Register.Email", {sx/2 - 220/2 - 3, sy/2 + 48, 270, 50}, {25, "", false, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 4)
    elseif type == "Age" then
        CreateNewBar("Char-Reg.Age", {sx/2 - 300/2, sy/2 - 40/2, 300, 40}, {2, "", true, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 1)
    end
end