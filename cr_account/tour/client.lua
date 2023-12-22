local global = {
    --[[
    {"Név", {cameraMatrix(6 pos)}, "Leírás", lines, multipler, time},
    ]]
    {"Benzinkút", {1917.5059814453, -1751.4389648438, 24.140399932861, 1918.1678466797, -1752.0614013672, 23.722612380981}, "Ez a benzinkút. \n Itt tudsz tankolni!", 2, 0.2, 15000},
    {"Városháza", {1480.6335449219 , -1712.9239501953 , 21.746000289917 , 1480.6358642578 , -1713.9143066406 , 21.607625961304 , 0 , 70}, "Ez a városháza. \n Itt tudsz munkát vállalni és különböző iratokat megszerezni.", 2, 0.2, 15000},
    {"Pláza", {1163.2646484375 , -1639.6114501953 , 31.360300064087 , 1162.3751220703 , -1639.2794189453 , 31.046407699585 , 0 , 70 }, "Ez a pláza. \n Itt különböző boltokat találhatsz, ahol tudsz vásárolni. \nPéldául ruhát venni vagy éppen elektronikai eszközt tudsz vásárolni itt.", 3, 0.2, 15000},
    {"Kórház", {1223.6270751953 , -1286.3737792969 , 32.342098236084 , 1222.8918457031 , -1286.9771728516 , 32.033401489258 , 0 , 70 }, "Ez a kórház. \n Ha bármilyen egészségügyi problémád van itt biztosan segítenek rajtad.", 2, 0.2, 15000},
}

function startTour()
    _dim = getElementDimension(localPlayer)
    setElementDimension(localPlayer, 0)
    fadeCamera(true)
    tourSound = playSound("files/our-town.mp3", true)
    setSoundVolume(tourSound, 0.5)
    now = 1
    name, matrix, text, lines, multipler, time = unpack(global[now])
    setCameraMatrix(unpack(matrix))
    --exports['ax_custom-chat']:showChat(false)
    showChat(false)
    --toggleAllControls(false, false)
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    page = "Tour"
    o = 1
    addEventHandler("onClientRender", root, drawnTour, true, "low-5")
    setTimer(change, global[now][6], 1)
end

local i = 5000
function change()
    if global[now + 1] then
        now = now + 1
        name, matrix, text, lines, multipler, time = unpack(global[now])
        local x1, y1, z1, x2, y2, z2 = unpack(global[now - 1][2])
        local x3, y3, z3, x4, y4, z4 = unpack(matrix)
        exports['cr_core']:smoothMoveCamera(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, i)
        removeEventHandler("onClientRender", root, drawnTour)
        setTimer(
            function()
                o = 1
                addEventHandler("onClientRender", root, drawnTour, true, "low-5")
                setTimer(
                    function()
                        change()
                    end, global[now][6], 1
                )
            end, i, 1
        )
    else
        -- Vége
        stopTour()
    end
end

function stopTour()
    startLoadingScreen("Char-Reg", 2)
    setElementDimension(localPlayer, _dim or 1)
    destroyElement(tourSound)
    removeEventHandler("onClientRender", root, drawnTour)
end


function drawnTour()
    o = o + multipler
    dxDrawRectangle(0,sy - lines * 20,sx,lines * 20, tocolor(15,15,15,220))
    dxDrawText(utfSub(text, 1, math.floor(o)), 5, sy - lines * 20 + 5, sx, sy, tocolor(255,255,255,255), 1, fonts["default-regular"], "left", "center")
end
--startTour()