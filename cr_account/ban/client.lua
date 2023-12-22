local ban = {}
lastClickTick = getTickCount()

function startBanPanel()
    --requestTextBars
    page = "Ban"
    addEventHandler("onClientRender", root, drawnBan, true, "low-5")
    Clear()
    --toggleAllControls(false, false)
    --exports['ax_custom-chat']:showChat(false)
    showChat(false)
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    accName = getElementData(localPlayer, "ban.accountName")
    id = getElementData(localPlayer, "ban.id")
    reason = getElementData(localPlayer, "ban.reason")
    aName = getElementData(localPlayer, "ban.aName")
    startDate = getElementData(localPlayer, "ban.startDate")
    endDate = getElementData(localPlayer, "ban.endDate")
    alpha = 0
    multipler = 1
end

function stopBanPanel()
    if page == "Ban" then
        removeEventHandler("onClientRender", root, drawnBan)
        stopLogoAnimation()
    end
end

function drawnBan()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    dxDrawImage(sx/2 - size["login-bg-X"]/2, sy/2 - size["login-bg-Y"]/2, size["login-bg-X"], size["login-bg-Y"], f .. "ban-bg.png", 0,0,0,tocolor(255,255,255,alpha))
    dxDrawText(aName .. " #ffffffáltal bannolva", sx/2, sy/2 - 33, sx/2, sy/2 - 33, tocolor(203,14,14,alpha), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
    dxDrawText("Indok: #ffffff" .. reason, sx/2, sy/2 - 10, sx/2, sy/2 - 10, tocolor(203,14,14,alpha), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
    dxDrawText("Bannolási nap: #ffffff" .. startDate, sx/2, sy/2 + 15, sx/2, sy/2 + 15, tocolor(185,105,12,alpha), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
    dxDrawText("Lejárat: #ffffff" .. endDate, sx/2, sy/2 + 40, sx/2, sy/2 + 40, tocolor(185,105,12,alpha), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
    dxDrawText("BanID: #ffffff" .. id .. " (#0D7CCBAccountNév: #ffffff"..accName..")", sx/2, sy/2 + 63, sx/2, sy/2 + 63, tocolor(13,124,203,alpha), 1, fonts["default-regular-small"], "center", "center", false, false, false, true)
end