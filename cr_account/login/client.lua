local login = {}
f = "files/"
lastClickTick = getTickCount()

function startLoginPanel()
    --requestTextBars
    alpha = 0
    multipler = 2
    showCursor(true)
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    page = "Login"
    addEventHandler("onClientRender", root, drawnLogin, true, "low-5")
    createTextBars(page)
end

function stopLoginPanel()
    if page == "Login" then
        removeEventHandler("onClientRender", root, drawnLogin)
        Clear()
        --stopLogoAnimation()
    end
end

function drawnLogin()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg.png", 0,0,0, tocolor(255,255,255,alpha))
    if isInSlot(sx/2 - 320/2 - 3, sy/2 - 88, 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg-boxes-user-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 - 320/2 - 3, sy/2 - 22, 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg-boxes-pw-active.png", 0,0,0, tocolor(255,255,255,alpha))
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg-boxes-all-gray.png", 0,0,0, tocolor(255,255,255,alpha))
    end    
    --dxDrawRectangle(sx/2 - 145, sy/2 + 32, 15, 15)
    
    if isInSlot(sx/2 + 28, sy/2 + 54, 116, 34) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-buttons-log-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 - 116 - 32, sy/2 + 54, 116, 34) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-buttons-reg-active.png", 0,0,0, tocolor(255,255,255,alpha))
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-buttons-all-gray.png", 0,0,0, tocolor(255,255,255,alpha))
    end    
    
    if isInSlot(sx/2 - 145, sy/2 + 32, 15, 15) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg-passwordSave-active.png", 0,0,0, tocolor(255,255,255,alpha))
    else 
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "login-bg-passwordSave-deactive.png", 0,0,0, tocolor(255,255,255,alpha))
    end
    
    if saveJSON["Clicked"] then
        dxDrawText("", sx/2 - 145, sy/2 + 32, sx/2 - 145 + 15, sy/2 + 32 + 15, tocolor(87,255,87,alpha), 1, fonts["awesomeFont3"], "center", "center")
    end
    --dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], "files/login-bg.png")
end

function login.onClick(b, s)
--    outputChatBox(page)
    if page == "Login" then
        if b == "left" and s == "down" then
            if isInSlot(sx/2 - 145, sy/2 + 32, 15, 15) then
                if lastClickTick + 500 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                lastClickTick = getTickCount()
                
                playSound("files/bubble.mp3")
                
                saveJSON["Clicked"] = not saveJSON["Clicked"]
            elseif isInSlot(sx/2 + 28, sy/2 + 54, 116, 34) then
                if lastClickTick + 1550 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                
                lastClickTick = getTickCount()
                
                --[[if not localPlayer:getData("modsLoaded") then 
                    exports['cr_infobox']:addBox("warning", "Míg a szerver nem töltötte be a modelleket addig nem tudsz bejelentkezni!")
                    return
                end--]]
                
                playSound("files/bubble.mp3")
                
                local username = textbars["Login.Name"][2][2]
                local password = textbars["Login.Password"][2][2]
                
                if #username < 6 then
                    exports["cr_infobox"]:addBox("error", "Túl rövid a felhasználónév, minimum 6 karakterből kell álljon!")
                    return
                end
                
                if #password < 6 then
                    exports["cr_infobox"]:addBox("error", "Túl rövid a jelszó, minimum 6 karakterből kell álljon!")
                    return
                end

                if saveJSON["Clicked"] then
                    local hashedPassword = hash("sha512", username .. password .. username)
                    local hashedPassword2 = hash("md5", salt .. hashedPassword .. salt)
                    saveJSON["Username"] = username
                    if saveJSON["Password"] ~= password then
                        saveJSON["Password"] = hashedPassword2
                    end
                end
                
                --outputChatBox(password)
                
                --outputChatBox("Login")
                triggerServerEvent("login.goLogin", localPlayer, localPlayer, username, password)
            elseif isInSlot(sx/2 - 116 - 32, sy/2 + 54, 116, 34) then
                if lastClickTick + 2550 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                lastClickTick = getTickCount()
                playSound("files/bubble.mp3")
                
                if not localPlayer:getData("modsLoaded") then 
                    exports['cr_infobox']:addBox("warning", "Míg a szerver nem töltötte be a modelleket addig nem tudsz regisztrálni!")
                    return
                end
                
                --local time = 2500
                changeCameraPos(1, 1, 2, 2500)
                
                --smoothMoveCamera(2075.4697265625, -1220.9239501953, 23.4, 2256.162109375, -1220.7332763672, 31.479625701904, 2084.0437011719, -1224.5490722656, 32.802700042725, 2084.8530273438, -1224.9874267578, 32.411842346191, 2500)
                stopLoginPanel()
                stopLogoAnimation()
                page = "Unknown"
                setTimer(
                    function()
                        if not saveJSON["haveRPTest"] then
                            -- outputChatBox("go > RPTest")
                            startRPTest()
                            lastClickTick = getTickCount()
                            return
                        end

                        -- outputChatBox("go > Register")
                        startRegisterPanel()
                    end, 2500, 1
                )
            end
        end
    end
end
addEventHandler("onClientClick", root, login.onClick)

function idgLoading()
    stopLoginPanel()
    stopLogoAnimation()
    stopLoginSound()
    page = "InGame"
    startLoadingScreen("Login", 1)
    lastClickTick = getTickCount()
end
addEvent("idgLoading", true)
addEventHandler("idgLoading", root, idgLoading)

function cameraSpawn()
    --showCursor(false)
    setFarClipDistance(farclip)
    local x1, y1, z1 = getElementPosition(localPlayer)
    local x2, y2, z2 = x1, y1, z1
    z1 = z1 + 150
    local x3, y3, z3 = getElementPosition(localPlayer)
    z3 = z3 + 1.5
    local x4, y4, z4 = x3, y3, z3
    local time = 6500
    setCameraMatrix(x1, y1, z1, x2, y2, z2)
    setTimer(
        function()
            exports['cr_core']:smoothMoveCamera(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, time)
            fadeCamera(true, 0)
            setTimer(
                function()
                    --toggleAllControls(true, true)
                    --exports['cr_custom-chat']:showChat(true)
                    showChat(true)
                    setElementData(localPlayer, "keysDenied", false)
                    setElementData(localPlayer, "hudVisible", true)
                    page = "InGame"
                    triggerServerEvent("unFreeze", localPlayer, localPlayer)
                    setCameraTarget(localPlayer, localPlayer)
                    accID = getElementData(localPlayer, "acc >> id")
                    version = exports['cr_core']:getServerData('version')
                    datum = exports['cr_core']:getTime()
                    addEventHandler("onClientRender", root, drawnDetails, true, "low-5")
                end, time, 1
            )
        end, 500, 1
    )
end
addEvent("cameraSpawn", true)
addEventHandler("cameraSpawn", root, cameraSpawn)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if farclip then
            setFarClipDistance(farclip)
        end
    end
)

addEvent("loadScreen", true)
addEventHandler("loadScreen", root,
    function()
        stopSituations()
        stopLogoAnimation()
        stopLoginPanel()
        stopLoginSound()
        startLoadingScreen("Login", 1)
    end
)

addEvent("searchPlayer.addPP", true)
addEventHandler("searchPlayer.addPP", root,
    function(id, value)
        for k,v in pairs(getElementsByType("player")) do
            if v and getElementData(v, "loggedIn") then
                local id2 = getElementData(v, "acc >> id")
                if id == id2 then
                    setElementData(v, "char >> premiumPoints", value)
                end
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if getElementData(localPlayer, "loggedIn") then
            accID = getElementData(localPlayer, "acc >> id")
            version = exports['cr_core']:getServerData('version')
            datum = exports['cr_core']:getTime()
            addEventHandler("onClientRender", root, drawnDetails, true, "low-5")
        end
    end
)

setTimer(
    function()
        datum = exports['cr_core']:getTime()
    end, (30 * 1000), 0
)

function drawnDetails()
    --dxDrawRectangle(sx - 85, sy - 14, 85, 14) , clear
    dxDrawText("StayMTA ["..version.."] - AccountID: "..accID.." - "..datum, sx - 90, sy - 6, sx - 90, sy - 6, tocolor(255, 255, 255, 110), 1, "ariel", "right", "center", false, false, false, true)
end