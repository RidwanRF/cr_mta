local loadingGlobal = {
    --[[
    [type] = {
        {Szöveg, Multipler},
    },
    ]]
    ["Login"] = {
        {"Karakter adatok összegyűjtése", 7},
        {"Karakter adatok betöltése", 9},
        {"Karakter spawnolása", 15},
    },
    ["Char-Reg"] = {
        {"Adatok összegyűjtése", 3},
        {"Karakter létrehozása", 8},
        {"Bejelentkezés", 13},
    },
}

local sound

function startLoadingScreen(id, id2)
    now = 1
    showCursor(false)
    animX = 0
    alpha = 0
    multipler = 1
    textID = id or 1
    funcID = id2 or 1
    sound = playSound("files/loading.mp3", true)
    page = "LoadingScreen"
    addEventHandler("onClientRender", root, drawnLoadingScreen, true, "low-5")
end

function linedRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(0,0,0,180)
    end
    if not color2 then
        color2 = color
    end
    if not size then
        size = 3
    end
	dxDrawRectangle(x, y, w, h, color) -- Háttér
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color2) -- felső
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color2) -- alsó
	dxDrawRectangle(x - size, y, size, h, color2) -- bal
	dxDrawRectangle(x + w, y, size, h, color2) -- jobb
end

function stopLoadingScreen()
    removeEventHandler("onClientRender", root, drawnLoadingScreen)
end


function drawnLoadingScreen()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawRectangle(0,0,sx,sy, tocolor(15,15,15,255))
    linedRectangle(20, sy - 30, sx - 40, 10, tocolor(255, 255, 255, 100), tocolor(10, 10, 10, 255), 3)
    
    local text, multipler = unpack(loadingGlobal[textID][now])
    if animX + multipler <= sx - 40 then
        animX = animX + multipler
    else
        if loadingGlobal[textID][now + 1] then
            now = now + 1
            animX = 0
        else
            -- Full vége
            if funcID == 1 then
                stopLoadingScreen()
                --triggerServerEvent("idg.login", localPlayer, localPlayer)
                --toggleAllControls(true, true)
                --stopLogoAnimation()
                --exports['ax_custom-chat']:showChat(true)
                --showChat(true)
                destroyElement(sound)
                local id, username = getElementData(localPlayer, "acc >> id"), getElementData(localPlayer, "acc >> username")
                fadeCamera(false, 0)
                setTimer(setCameraTarget, 350, 1, localPlayer, localPlayer)
                triggerServerEvent("loadCharacter", localPlayer, localPlayer, id, username)
            elseif funcID == 2 then
                fadeCamera(false, 0)
                stopLoadingScreen()
                local id, username = getElementData(localPlayer, "acc >> id"), getElementData(localPlayer, "acc >> username")
                triggerServerEvent("loadCharacter", localPlayer, localPlayer, id, username)
                setTimer(setCameraTarget, 350, 1, localPlayer, localPlayer)
                --toggleAllControls(true, true)
                --stopLogoAnimation()
                --toggleAllControls(true, true)
                --exports['ax_custom-chat']:showChat(true)
                --showCursor(false)
                destroyElement(sound)
                --exports["ax_infobox"]:addBox("success", "Sikeres bejelentkezés. Jó játékot!")
                --stopLoginPanel()
            end
        end
    end
    dxDrawText(text, sx/2, sy - 40, sx/2, sy - 40, tocolor(255,255,255,255), 1, fonts["default-regular"], "center", "center")
    dxDrawRectangle(20, sy - 30, animX, 10, tocolor(255, 255, 255, 220))
end