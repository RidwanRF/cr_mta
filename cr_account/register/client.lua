local reg = {}

function startRegisterPanel()
    --requestTextBars
    alpha = 0
    multipler = 2
    page = "Register"
    addEventHandler("onClientRender", root, drawnRegister, true, "low-5")
    createTextBars(page)
    stopLogoAnimation()
    createLogoAnimation(1, {sx/2, sy/2 - 245})
end

function stopRegisterPanel()
    if page == "Register" then
        removeEventHandler("onClientRender", root, drawnRegister)
        Clear()
        --stopLogoAnimation()
    end
end

function drawnRegister()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg.png", 0,0,0, tocolor(255,255,255,alpha))
    
    if isInSlot(sx/2 - 320/2 - 3, sy/2 - (88 + 66), 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg-boxes-user-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 - 320/2 - 3, sy/2 - 88, 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg-boxes-pw2-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 - 320/2 - 3, sy/2 - 22, 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg-boxes-pw-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 - 320/2 - 3, sy/2 + 48, 320, 50) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg-boxes-email-active.png", 0,0,0, tocolor(255,255,255,alpha))
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-bg-boxes-all-gray.png", 0,0,0, tocolor(255,255,255,alpha))
    end    
    --dxDrawRectangle(sx/2 - 220/2 - 3, sy/2 - 22, 270, 50)
    
    if isInSlot(sx/2 - 116 - 32, sy/2 + 115, 116, 34) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-buttons-log-active.png", 0,0,0, tocolor(255,255,255,alpha))
    elseif isInSlot(sx/2 + 28, sy/2 + 115, 116, 34) then
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-buttons-reg-active.png", 0,0,0, tocolor(255,255,255,alpha))
    else
        dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "reg-buttons-all-gray.png", 0,0,0, tocolor(255,255,255,alpha))
    end    
    --dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], "files/login-bg.png")
end

function reg.onClick(b, s)
--    outputChatBox(page)
    if page == "Register" then
        if b == "left" and s == "down" then
            if isInSlot(sx/2 - 116 - 32, sy/2 + 115, 116, 34) then
                if lastClickTick + 2550 > getTickCount() then
                    --outputChatBox("return > fastClick")
                    return
                end
                playSound("files/bubble.mp3")
                
                stopRegisterPanel()
                stopLogoAnimation()
                page = "Unknown"
                local time = 2500
                changeCameraPos(1, 2, 1, time)
                setTimer(
                    function()
                        startLoginPanel()
                        createLogoAnimation(1, {sx/2, sy/2 - 190})
                        --outputChatBox("go > Login")
                    end, time, 1
                )
                
                lastClickTick = getTickCount()
            elseif isInSlot(sx/2 + 28, sy/2 + 115, 116, 34) then
                if lastClickTick + 1550 > getTickCount() then
                    --outputChatBox("return > fastClick")
                    return
                end

                --outputChatBox("go > Register")
                lastClickTick = getTickCount()
                
                playSound("files/bubble.mp3")
                local username = textbars["Register.Name"][2][2]
                local email = textbars["Register.Email"][2][2]
                local password = textbars["Register.Password1"][2][2]
                local password2 = textbars["Register.Password2"][2][2]
                
                if #username < 6 then
                    exports["cr_infobox"]:addBox("error", "Túl rövid a felhasználónév, minimum 6 karakterből kell álljon!")
                    return
                end
                
                if #password < 6 or #password2 < 6 then
                    exports["cr_infobox"]:addBox("error", "Túl rövid a jelszó, minimum 6 karakterből kell álljon!")
                    return
                end
                
                if not email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
                    exports["cr_infobox"]:addBox("error", "Használj rendes emailcímet (Pld: xyz@gmail.com)!")
                    return
                end
                
                if string.lower(password) ~= string.lower(password2) then
                    exports["cr_infobox"]:addBox("error", "A 2 jelszó nem egyezik!")
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

                local serial = getElementData(localPlayer, "mtaserial")
                triggerServerEvent("reg.goRegister", localPlayer, localPlayer, username, password, email, serial)
            end
        end
    end
end
addEventHandler("onClientClick", root, reg.onClick)

addEvent("goBackToLogin", true)
addEventHandler("goBackToLogin", localPlayer,
    function()
        playSound("files/bubble.mp3")
                
        stopRegisterPanel()
        stopLogoAnimation()
        page = "Unknown"
        local time = 2500
        changeCameraPos(1, 2, 1, time)
        setTimer(
            function()
                startLoginPanel()
                createLogoAnimation(1, {sx/2, sy/2 - 190})
                --outputChatBox("go > Login")
            end, time, 1
        )

        lastClickTick = getTickCount()
    end
)