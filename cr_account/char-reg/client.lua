local charReg = {}
--local details = {}
local se = 0
local iState = "?"

local skins = {
    ["Girls"] = {
        [1] = 199, 
        [2] = 233,
        [3] = 225,
        [4] = 13,
    },
    ["Doctor"] = {
        [1] = 274, 
        [2] = 275,
        [3] = 276,
    },
}

function startCharReg()
    --requestTextBars
    stopSituations()
    details = {}
    stopLoginPanel()
    stopLoginSound()
    stopLogoAnimation()
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    page = "CharReg"
    iState = "start"
    exports['cr_blur']:removeBlur("Loginblur")
    fadeCamera(false, 1)
    setTimer(
        function()
            text = "Kezdődhet valami új..."
            alpha = 0
            multipler = 1
            addEventHandler("onClientRender", root, drawnText, true, "low-5")       
            setTimer(
                function()
                    exports['cr_infobox']:addBox("info", "Az interakcióhoz használd az 'Enter' billentyűt!")
                    exports['cr_infobox']:addBox("warning", "Minden döntésednek súlya van. Úgy dönts, hogy tényleg azt kellesz rp-zd amit kiválasztol!")
                    exports['cr_infobox']:addBox("warning", "Ezek az adatok később csak FőAdmin által lehetnek módosítva!")
                    removeEventHandler("onClientRender", root, drawnText)
                    alpha = 0
                    multipler = 1
                    iState = "Neme"
                    fadeCamera(true)
                    bindKey("enter", "down", boxNext)
                    setCameraMatrix(1190.2514648438, -1742.5526123047, 18.152200698853, 1191.0794677734, -1743.0394287109, 17.873893737793)
                    addEventHandler("onClientRender", root, drawnBoxType, true, "low-5")
                end, 5000, 1
            )
        end, 1000, 1
    )
end
addEvent("Start.Char-Register", true)
addEventHandler("Start.Char-Register", root, startCharReg)

function stopCharReg()
    if page == "CharReg" then
        removeEventHandler("onClientRender", root, drawnLogin)
        --stopLogoAnimation()
    end
end

function drawnText()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText(text, sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

function drawnBoxType()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawRectangle(sx/2 - 240/2, sy/2 - (30*3), 240, 30*3 + 12, tocolor(0,0,0,math.min(alpha, 204))) -- // BG
    local posY = 10
    dxDrawText("Válaszd ki a karaktered nemét!", sx/2, sy/2 - (30*3) + posY, sx/2, sy/2 - (30*3) + posY, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    posY = posY + 15
    
    if isInSlot(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30) or se == 1 then
        dxDrawRectangle(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30, tocolor(87,255,87,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Férfi", sx/2, sy/2 - (30*3) + posY, sx/2, sy/2 - (30*3) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Férfi", sx/2, sy/2 - (30*3) + posY, sx/2, sy/2 - (30*3) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
    
    posY = posY + 40
    if isInSlot(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30) or se == 2 then
        dxDrawRectangle(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30, tocolor(255,87,87,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Nő", sx/2, sy/2 - (30*3) + posY, sx/2, sy/2 - (30*3) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 230/2, sy/2 - (30*3) + posY, 230, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Nő", sx/2, sy/2 - (30*3) + posY, sx/2, sy/2 - (30*3) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
end

addEventHandler("onClientClick", root,
    function(b,s)
        if page == "CharReg" then
            if iState == "Neme" then
                if b == "left" and s == "down" then
                    if isInSlot(sx/2 - 230/2, sy/2 - (30*3) + 25, 230, 30) then
                        if se == 1 then
                            se = 0
                        else
                            se = 1
                        end
                    elseif isInSlot(sx/2 - 230/2, sy/2 - (30*3) + 65, 230, 30) or se == 2 then
                        if se == 2 then
                            se = 0
                        else
                            se = 2
                        end
                    end
                end
            elseif iState == "Nationality" then
                if b == "left" and s == "down" then
                    if isInSlot(sx/2 - 230/2, sy/2 - (30*4) + 25, 230, 30) then
                        if se == 1 then
                            se = 0
                        else
                            se = 1
                        end
                    elseif isInSlot(sx/2 - 230/2, sy/2 - (30*4) + 65, 230, 30) or se == 2 then
                        if se == 2 then
                            se = 0
                        else
                            se = 2
                        end
                    elseif isInSlot(sx/2 - 230/2, sy/2 - (30*4) + 105, 230, 30) or se == 2 then
                        if se == 3 then
                            se = 0
                        else
                            se = 3
                        end  
                    elseif isInSlot(sx/2 - 230/2, sy/2 - (30*4) + 145, 230, 30) or se == 2 then
                        if se == 4 then
                            se = 0
                        else
                            se = 4
                        end   
                    end
                end
            end
        end
    end
)

function boxNext()
    if se == 0 then
        exports['cr_infobox']:addBox("error", "Válassz ki egy nemet!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    unbindKey("enter", "down", boxNext)
    removeEventHandler("onClientRender", root, drawnBoxType)
    alpha = 0
    multipler = 1
    details["neme"] = se
    se = 0
    iState = "Nationality"
    bindKey("enter", "down", nationalityNext)
    addEventHandler("onClientRender", root, drawnBoxNationality, true, "low-5")
end

function drawnBoxNationality()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawRectangle(sx/2 - 290/2, sy/2 - (30*4), 290, 30*4 + (12 * 4) + 18, tocolor(0,0,0,math.min(alpha, 204))) -- // BG Rectanglénként 12-s hibapont
    local posY = 10
    dxDrawText("Válaszd ki a karaktered nemzetiségét!", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
    posY = posY + 15
    
    if isInSlot(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30) or se == 1 then
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(87,255,87,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Európai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Európai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
    
    posY = posY + 40
    if isInSlot(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30) or se == 2 then
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(87,87,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Amerikai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Amerikai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
    
    posY = posY + 40
    if isInSlot(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30) or se == 3 then
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(255, 237, 32,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Ázsiai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Ázsiai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
    
    posY = posY + 40
    if isInSlot(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30) or se == 4 then
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(217, 124, 14,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Afrikai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    else
        dxDrawRectangle(sx/2 - 280/2, sy/2 - (30*4) + posY, 280, 30, tocolor(255,255,255,math.min(alpha, 51))) -- // Vezeték Név
        dxDrawText("Afrikai", sx/2, sy/2 - (30*4) + posY, sx/2, sy/2 - (30*4) + posY + 30, tocolor(255,255,255,alpha), 1, fonts["default-regular-small"], "center", "center")
    end
end

function nationalityNext()
    if se == 0 then
        exports['cr_infobox']:addBox("error", "Válasz ki egy nemzetiséget!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    unbindKey("enter", "down", nationalityNext)
    removeEventHandler("onClientRender", root, drawnBoxNationality)
    alpha = 0
    multipler = 1
    details["nationality"] = se
    se = 0
    iState = "Age"
    bindKey("enter", "down", ageNext)
    fadeCamera(false, 1)
    setTimer(
        function()
            createTextBars(iState)
            exports['cr_infobox']:addBox("info", "Gépeld be az életkorod!")
            addEventHandler("onClientRender", root, drawnAge, true, "low-5")
        end, 1000, 1
    )
end

function drawnAge()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText("Életkorom: "..textbars["Char-Reg.Age"][2][2] .. " év", sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

--
function getBornTime(age)
    local time = getRealTime()
    local month = time.month + 1
    local monthday = time.monthday
    local year = 1900 + time.year
    if month < 10 then
        month = "0" .. tostring(month)
    end
    if monthday < 10 then
        monthday = "0" .. tostring(monthday)
    end
    local year = year - age
    return year.."."..month.."."..monthday
end
--

function ageNext()
    local age = tonumber(textbars["Char-Reg.Age"][2][2])
    if age == nil or age < 18 or age > 80  then
        exports['cr_infobox']:addBox("error", "Az életkorodnak egy számnak kell lennie mely 18 - 80 között van!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    Clear()
    unbindKey("enter", "down", ageNext)
    removeEventHandler("onClientRender", root, drawnAge)
    alpha = 0
    multipler = 1
    details["age"] = age
    se = 0
    iState = "BackWheel"
    fadeCamera(false, 1)
    local time = getBornTime(age)
    details["born"] = time
    setTimer(
        function()
            addEventHandler("onClientRender", root, drawnBornDate, true, "low-5")
            setTimer(
                function()
                    fadeCamera(true, 1)
                    removeEventHandler("onClientRender", root, drawnBornDate, true, "low-5")
                    iState = "Doctor"
                    setCameraMatrix(1173.2569580078, -1581.15234375, 26.746099472046, 1172.6384277344, -1581.833984375, 26.355241775513)
                    local nationality = details["nationality"] or 1
                    
                    local dSkin = skins["Doctor"][math.random(1, #skins["Doctor"])]
                    dPed = createPed(dSkin, 1164.9268798828, -1590.3551025391, 24.2)
                    dPed:setFrozen(true)
                    dPed:setDimension(localPlayer:getDimension())
                    dPed:setInterior(localPlayer:getInterior())
                    --details["doctor"] = dPed
                    
                    local skin = skins["Girls"][nationality]
                    gPed = createPed(skin, 1167.2143554688, -1585.2435302734, 24.2, 180)
                    --gPed:setFrozen(true)
                    gPed:setDimension(localPlayer:getDimension())
                    gPed:setInterior(localPlayer:getInterior())
                    setPedAnimation(gPed, "CRACK", "crckidle1", -1, true, false, false)
                    --details["Girl"] = gPed
                    
                    
                    setTimer(
                        function()
                            destroyElement(gPed)
                            destroyElement(dPed)
                            fadeCamera(false, 1)
                            setTimer(
                                function()
                                    iState = "DoctorShow"
                                    fadeCamera(true, 1)
                                    dPed = createPed(dSkin, 1164.3518066406, -1585.9930419922, 24.5, 230)
                                    dPed:setCollisionsEnabled(false)
                                    dPed:setFrozen(true)
                                    dPed:setDimension(localPlayer:getDimension())
                                    dPed:setInterior(localPlayer:getInterior())
                                    setPedAnimation(dPed, "carry", "crry_prtial", -1, true, false, false)
                                    local x,y,z = 1164.6, -1585.9930419922, 24.8
                                    handPed = createPed(107, x,y,z, 0)
                                    handPed:setCollisionsEnabled(false)
                                    handPed:setFrozen(true)
                                    handPed:setRotation(Vector3(90,130,130))
                                    handPed:setDimension(localPlayer:getDimension())
                                    handPed:setInterior(localPlayer:getInterior())
                                    setCameraMatrix(1168.3315429688, -1590.2834472656, 27, 1164.3518066406, -1585.9930419922, 24.2)
                                    --setCMatrix
                                    --Doctor
                                    --Puja
                                    --Attach
                                    setTimer(
                                        function()
                                            details["DXPOS"] = Vector2(getScreenFromWorldPosition(x,y,z + 0.2))
                                            alpha = 0
                                            multipler = 1
                                            CreateNewBar("Char-Reg.Name", {details["DXPOS"].x - 300/2, details["DXPOS"].y - 40/2, 300, 40}, {20, "Az én nevem...", false, tocolor(255,255,255,255), fonts["default-regular"], 1, "center", "center", false}, 1)
                                            exports['cr_infobox']:addBox("info", "Gépeld be a neved!")
                                            addEventHandler("onClientRender", root, drawnName, true, "low-5")
                                            bindKey("enter", "down", nameNext)
                                        end, 1000, 1
                                    )
                                end, 2000, 1
                            )
                        end, 6000, 1
                    )
                end, 8000, 1
            )
        end, 1000, 1
    )
end

function drawnBornDate()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText(details["born"], sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

function drawnName()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText(textbars["Char-Reg.Name"][2][2],details["DXPOS"].x, details["DXPOS"].y, details["DXPOS"].x, details["DXPOS"].y, tocolor(255,255,255,alpha), 1, fonts["default-regular"], "center", "center")
end

function searchSpace(a)
    local match = {}
    local d = 0
    local s = 0
   
    while true do
        local b, c = utf8.find(a, "%s", s)
        if b then
            s = b + 1
            d = d + 1
            match[d] = b
        else
            break
        end
    end
   
    return match
end
 
function matchConvertToString(text, matchTable)
    local args = {}
    local d = 0
    for i = 1, #matchTable do
        local v = matchTable[i] + 1
        if matchTable[i+1] then
            local v2 = matchTable[i+1] + 1
            local e = utfSub(text, v, v2)
            args[d] = e
        else
            e = eutfSub(text, v, #text)
            args[d] = e
        end
    end
   
    return args
    --Használatkor: executeCommandHandler("asd", source, unpack(table))
end

function nameNext()
    local name = textbars["Char-Reg.Name"][2][2]
    local fullName = ""
    local count = 1
    
    while true do
        local a = gettok(name, count, string.byte(' '))
        if a then
            if #a < 2 then
                exports['cr_infobox']:addBox("error", "A név amit megadtál hibás!")
                return
            end
            count = count + 1
            a = a .. "_"
            a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
            fullName = fullName .. a
        else
            break
        end
    end
    
    if count < 2 then
        exports['cr_infobox']:addBox("error", "A névnek minimum 2 részletből kell álljon!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    local b = fullName --name3 and name1 .. "_" .. name2 .. "_" .. name3 or name1 .. "_" .. name2
    --outputChatBox(b)
    
    triggerServerEvent("checkNameRegistered", localPlayer, localPlayer, b)
end

addEvent("receiveNameRegisterable", true)
addEventHandler("receiveNameRegisterable", root,
    function(a, b)
        if a then
            details["name"] = b
            --outputChatBox(b)
            Clear()
            destroyElement(dPed)
            destroyElement(handPed)
            removeEventHandler("onClientRender", root, drawnName, true, "low-5")
            details["DXPOS"] = nil
            unbindKey("enter", "down", nameNext)
            iState = "Height"
            bindKey("enter", "down", heightNext)
            fadeCamera(false, 1)
            setTimer(
                function()
                    alpha = 0
                    multipler = 1
                    exports['cr_infobox']:addBox("info", "Gépeld be a magasságod!")
                    CreateNewBar("Char-Reg.Height", {sx/2 - 300/2, sy/2 - 40/2, 300, 40}, {3, "", true, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 1)
                    addEventHandler("onClientRender", root, drawnHeight, true, "low-5")
                end, 1000, 1
            )
        else
            exports['cr_infobox']:addBox("error", "A név amit megadtál már foglalt!")
            return
        end
    end
)

function drawnHeight()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText("Magasságom: "..textbars["Char-Reg.Height"][2][2] .. " cm", sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

function heightNext()
    local height = tonumber(textbars["Char-Reg.Height"][2][2])
    if height == nil or height < 150 or height > 220  then
        exports['cr_infobox']:addBox("error", "A magasságodnak egy számnak kell lennie mely 150 - 220 között van!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    Clear()
    unbindKey("enter", "down", heightNext)
    removeEventHandler("onClientRender", root, drawnHeight)
    alpha = 0
    multipler = 1
    details["height"] = height
    se = 0
    
    iState = "weight"
    bindKey("enter", "down", weightNext)
    fadeCamera(false, 1)
    setTimer(
        function()
            alpha = 0
            multipler = 1
            CreateNewBar("Char-Reg.Weight", {sx/2 - 300/2, sy/2 - 40/2, 300, 40}, {3, "", true, tocolor(255,255,255,255), fonts["default-bold"], 1, "center", "center", false}, 1)
            addEventHandler("onClientRender", root, drawnWeight, true, "low-5")
        end, 1000, 1
    )
end

function drawnWeight()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText("Súlyom: "..textbars["Char-Reg.Weight"][2][2] .. " kg", sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

pSkins = {
    --[[
    [Nemzetiség (A panel sorrendje alapján)] = {
        [1 = FÉRFI] = {Skinek pld: 107, 109},
        [2 = NŐ] = {Skinek pld: 107, 109},
    },
    ]]
    [1] = { -- európai
        [1] = {10,11,12},
        [2] = {15,16,17},
    },
    [2] = { -- amerikai
        [1] = {20, 21, 22},
        [2] = {25,26,27},
    },
    [3] = { -- ázsiai
        [1] = {30, 31, 32},
        [2] = {35, 36, 37},    
    },
    [4] = { -- afrikai
        [1] = {40, 41, 42},
        [2] = {45, 46, 47},
    },
}	

anims = {
    {"DANCING", "DAN_Right_A", -1, true, false, false},
    {"DANCING", "DAN_Down_A", -1, true, false, false},
    {"DANCING", "dnce_M_d", -1, true, false, false},
    {"DANCING", "dance_loop", -1, true, false, false},
    {"DANCING", "dnce_m_c", -1, true, false, false},
    {"DANCING", "dnce_m_e", -1, true, false, false},
    {"DANCING", "dnce_m_a", -1, true, false, false},
    {"DANCING", "bd_clap", -1, true, false, false},
    {"DANCING", "dan_up_a", -1, true, false, false},
    {"DANCING", "dan_left_a", -1, true, false, false},
}

function weightNext()
    local weight = tonumber(textbars["Char-Reg.Weight"][2][2])
    if weight == nil or weight < 60 or weight > 120  then
        exports['cr_infobox']:addBox("error", "A magasságodnak egy számnak kell lennie mely 60 - 120 között van!")
        return
    end
    
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    Clear()
    unbindKey("enter", "down", weightNext)
    removeEventHandler("onClientRender", root, drawnWeight)
    alpha = 0
    multipler = 1
    details["weight"] = weight
    se = 0
    
    iState = "now"
    fadeCamera(false, 1)
    setTimer(
        function()
            alpha = 0
            multipler = 1
            addEventHandler("onClientRender", root, drawnNow, true, "low-5")
            setTimer(
                function()
                    removeEventHandler("onClientRender", root, drawnNow, true, "low-5")
                    iState = "Skin"
                    --EU, Amerikai, Ázsai, Afrika
                    fadeCamera(true, 1)
                    neme = details["neme"] or 1
                    nationality = details["nationality"] or 1
                    id = 1
                    exports['cr_infobox']:addBox("info", "Válasz skint. Az interakció a bal, jobb nyilakkal illetve az enterrel végezhető!")
                    local skin = pSkins[nationality][neme][id]
                    skinPed = createPed(skin, 2007.5072021484, -1440.5102539063, 13, 135)
                    skinPed:setFrozen(true)
                    skinPed:setDimension(localPlayer:getDimension())
                    skinPed:setInterior(localPlayer:getInterior())
                    local anim = unpack(anims[math.random(1,#anims)])
                    skinPed:setAnimation(anim)
                    setCameraMatrix(2004.4909667969, -1444.2305908203, 14.347200393677, 2007.5072021484, -1440.5102539063, 13)
                    --SCmatrix
                    setTimer(
                        function()
                            bindKey("arrow_l", "down", LeftSkinC)
                            bindKey("arrow_r", "down", RightSkinC)
                            bindKey("enter", "down", endSkinS)
                        end, 1000, 1
                    )
                end, 6000, 1
            )
        end, 1000, 1
    )
end

function drawnNow()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText("Jelenben", sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

function LeftSkinC()
    if id - 1 >= 1 then
        id = id - 1
        local skin = pSkins[nationality][neme][id]
        skinPed:setModel(skin)
        local anim = unpack(anims[math.random(1,#anims)])
        skinPed:setAnimation(anim)
    end
end

function RightSkinC()
    if id + 1 <= #pSkins[nationality][neme] then
        id = id + 1
        local skin = pSkins[nationality][neme][id]
        skinPed:setModel(skin)
        local anim = unpack(anims[math.random(1,#anims)])
        skinPed:setAnimation(anim)
    end
end

function endSkinS()
    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()
    
    unbindKey("arrow_l", "down", LeftSkinC)
    unbindKey("arrow_r", "down", RightSkinC)
    unbindKey("enter", "down", endSkinS)
    details["skin"] = getElementModel(skinPed) or 1
    skinPed:destroy()
    exports['cr_infobox']:addBox("success", "Sikeres karakterkészítés!")
    
    local t = {getElementData(localPlayer, "acc >> username"), getElementData(localPlayer, "acc >> id")}
    triggerServerEvent("character.Register", localPlayer, localPlayer, details, t)
    --startTour()
    startVideo()
end

function nationalityNumToString(e)
    e = tonumber(e)
    if e == 1 then
        return "európai"
    elseif e == 2 then
        return "amerikai"
    elseif e == 3 then
        return "ázsiai"
    else
        return "afrikai"
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
addEvent("loadCharacter", true)
addEventHandler("loadCharacter", localPlayer,
    function(data)
        exports['cr_blur']:removeBlur("Loginblur")
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        fadeCamera(false, 0)
        local position = data[3]
        if type(position) == "string" then
            position = fromJSON(position)
        end
        local x,y,z, dim,int,rot = unpack(position)
        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)
        dim = tonumber(dim)
        int = tonumber(int)
        rot = tonumber(rot)
        
        local details = data[4]
        if type(details) == "string" then
            details = fromJSON(details)
        end
        local Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink, vehicleLimit, interiorLimit, avatar, isKnow, Bones, isHidden, BankMoney = unpack(details)
        Health = tonumber(Health)
        Armor = tonumber(Armor)
        SkinID = tonumber(SkinID)
        Money = tonumber(Money)
        PlayedTime = tonumber(PlayedTime)
        Level = tonumber(Level)
        premiumPoints = tonumber(premiumPoints)
        job = tonumber(job)
        food = tonumber(food)
        drink = tonumber(drink)
        interiorLimit = tonumber(interiorLimit)
        vehicleLimit = tonumber(vehicleLimit)
        avatar = tonumber(avatar)
        BankMoney = tonumber(BankMoney)
        
        setElementData(localPlayer, "char >> interiorLimit", interiorLimit)
        setElementData(localPlayer, "char >> vehicleLimit", vehicleLimit)
        setElementData(localPlayer, "char >> avatar", avatar)
        
        if Bones and type(Bones) == "string" then Bones = fromJSON(Bones) end
        if not Bones then 
            Bones = {true, true, true, true, true} 
        end
        setElementData(localPlayer, "char >> bone", Bones)
        
        if isHidden and type(isHidden) == "string" then isHidden = fromJSON(isHidden) end
        if not isHidden then 
            isHidden = {} 
        end
        setElementData(localPlayer, "weapons >> hidden", isHidden)
        
        --outputChatBox(tostring(isKnow) .. "-asd-" .. inspect(isKnow))
        if isKnow and type(isKnow) == "string" then isKnow = fromJSON(isKnow) end
        if not isKnow then 
            isKnow = {{["-5000"] = true}, {["-5000"] = true}} 
        end
        local debuts, friends = unpack(isKnow)
    
        local friend = {}
        if not friends then friends = {} end
        for k,v in pairs(friends) do
            friend[tonumber(k)] = v
        end

        local debut = {}
        if not debuts then debuts = {} end
        for k,v in pairs(debuts) do
            debuts[tonumber(k)] = v
        end

        setElementData(localPlayer, "friends", friend)
        setElementData(localPlayer, "debuts", debut)
            
        localPlayer.position = Vector3(x,y,z)
        localPlayer:setDimension(dim)
        localPlayer:setInterior(int)
        
        local a = data[5]
        if type(a) == "string" then
            a = fromJSON(a)
        end
        if not a then
            a = {}
            a["neme"] = 1
            a["nationality"] = 1
            a["age"] = 18
            a["born"] = "2000.06.18"
            a["height"] = 180
            a["weight"] = 80
            a["fightStyle"] = 5
            a["walkStyle"] = 121
        end
        setElementData(localPlayer, "char >> details", a)
        local neme, nationality, age, born, height, weight, fightStyle, walkStyle, description = a["neme"], a["nationality"], a["age"], a["born"], a["height"], a["weight"], a["fightStyle"], a["walkStyle"], a["description"]
        if not description then
            local a = "Ő egy XX cm magas, XY kg súlyú, XZ éves, XO nemzetiségű ember!"
            a = a:gsub("XX", height)
            a = a:gsub("XY", weight)
            a = a:gsub("XZ", age)
            a = a:gsub("XO", nationalityNumToString(nationality))
            description = a
        end
        setElementData(localPlayer, "char >> description", description)
        
        local name = data[2]
        name = tostring(name)
        
        local a2 = data[6]
        if type(a2) == "string" then
            a2 = fromJSON(a2)
        end
        local dead, reason, headless, bulletsInBody = unpack(a2)
        dead = stringToBoolean(dead)
        if type(reason) == "string" then
            reason = fromJSON(reason)
        end
        headless = stringToBoolean(headless)
        bulletsInBody = tostring(bulletsInBody) or toJSON({})
        bulletsInBody = fromJSON(bulletsInBody)
        
        local a3 = data[7]
        if type(a3) == "string" then
            a3 = fromJSON(a3)
        end
        local alevel, nick, aTime, usedCmds, ajail = unpack(a3)
        if not ajail then ajail = toJSON({}) end
        local ajail = fromJSON(ajail)
        alevel = tonumber(alevel)
        nick = tostring(nick)
        aTime = tonumber(aTime)
        
        if not usedCmds then
            usedCmds = {}
            for i = 1, 100 do 
                usedCmds[i] = 0
            end
        else
            for i = 1, 100 do
                if not usedCmds[i] then
                    usedCmds[i] = 0
                end
            end
        end
        rtc, fix, fuel, jail, ban, kick = unpack(usedCmds)
        
        local groupID = tonumber(data[9] or 0)
        setElementData(localPlayer, "char >> groupId", groupID)
        
        setElementData(localPlayer, "rtc >> using", rtc)
        setElementData(localPlayer, "fix >> using", fix)
        setElementData(localPlayer, "fuel >> using", fuel)
        setElementData(localPlayer, "ban >> using", ban)
        setElementData(localPlayer, "kick >> using", kick)
        setElementData(localPlayer, "jail >> using", jail)
        
        if ajail and #ajail > 0 then
            if ajail[1] and type(ajail[1]) == "boolean" then
                setElementData(localPlayer,"char >> ajail >> admin",ajail[4])
                setElementData(localPlayer,"char >> ajail >> type",ajail[3])
                setElementData(localPlayer,"char >> ajail >> time", ajail[5])
                setElementData(localPlayer,"char >> ajail >> aLevel", ajail[6])
                if ajail[1] then
                    setElementData(localPlayer,"char >> ajail", ajail[1])
                end
                setElementData(localPlayer,"char >> ajail >> reason", ajail[2])
            end
        end
        
        triggerServerEvent("spawnPl", localPlayer, localPlayer, SkinID, x,y,z, rot, dim,int, Health, Armor, fightStyle, walkStyle)
        
        exports['cr_core']:setElementData(localPlayer, "loggedIn", false)
        exports['cr_core']:setElementData(localPlayer, "char >> money", Money)
        exports['cr_core']:setElementData(localPlayer, "char >> bank_money", BankMoney)
        setElementData(localPlayer, "char >> playedtime", PlayedTime)
        setElementData(localPlayer, "char >> level", Level)
        exports['cr_core']:setElementData(localPlayer, "char >> premiumPoints", premiumPoints)
        setElementData(localPlayer, "char >> job", job)
        setElementData(localPlayer, "char >> food", food)
        setElementData(localPlayer, "char >> drink", drink)
        
        local fullName = ""
        local count = 1
        name = name:gsub("_", " ")

        while true do
            local a = gettok(name, count, string.byte(' '))
            if a then
                count = count + 1
                if gettok(name, count, string.byte(' ')) then
                    a = a .. "_"
                end
                a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
                fullName = fullName .. a
            else
                break
            end
        end
        
        setElementData(localPlayer, "char >> name", fullName)
        setElementData(localPlayer, "destroyLV", true)

        setTimer(
            function()
                if not getElementData(localPlayer, "char >> afk") then
                    local oPlayTime = getElementData(localPlayer, "char >> playedtime")
                    setElementData(localPlayer, "char >> playedtime", oPlayTime + 1)
                end
            end, 60 * 1000, 0
        )

        exports['cr_core']:setElementData(localPlayer, "admin >> level", alevel)
        setElementData(localPlayer, "admin >> name", nick)
        setElementData(localPlayer, "admin >> time", aTime)
        
        local deathReasons = reason
        setElementData(localPlayer, "char >> death", dead)
        setElementData(localPlayer, "deathReason", deathReasons[1])
        setElementData(localPlayer, "deathReason >> admin", deathReasons[2])
        setElementData(localPlayer, "char >> headless", headless)
        setElementData(localPlayer, "bulletsInBody", bulletsInBody)
    end
)