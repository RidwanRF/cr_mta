cache = {}
white = "#ffffff"
options = {}
screen = Vector2(guiGetScreenSize())
center = Vector2(screen.x/2, screen.y/2)
size = Vector2(200, 500)
sizes = {
    ["top"] = Vector2(496, 68),
    ["center"] = Vector2(496, 32),
    ["bottom"] = Vector2(496, 32),
    ["staymta"] = Vector2(496, 30),
    ["search"] = Vector2(180, 25),
}
a = "files/"
sources = {
    ["top"] = a .. "top.png",
    ["center"] = a .. "center.png",
    ["bottom"] = a .. "bottom.png",
    ["staymta"] = a .. "staymta.png",
}

minLines = 1
maxLines = math.floor((screen.y - 150 - (sizes["top"].y + sizes["bottom"].y)) / 35)
_maxLines = maxLines

--
import("*"):from("cr_core")

addEventHandler("onClientResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_core" then
            import("*"):from("cr_core")
            --startCustomChat()
        end
    end
)

bindKey("tab", "down",
    function()
        if not localPlayer:getData("loggedIn") then return end
        if not freezeInteract then
            sTimer = setTimer(
                function()
                    if getKeyState("tab") then
                        freezeInteract = true
                    end
                end, 2000, 1
            )
            startScore()
        else
            freezeInteract = false
            stopScore()
        end
    end
)

bindKey("tab", "up",
    function()
        if not localPlayer:getData("loggedIn") then return end
        if not freezeInteract then
            stopScore()
        end
    end
)

bindKey("mouse_wheel_up", "down",
    function()
        if state then
            if minLines - 1 >= 1 then
                playSound("files/wheel.wav")
                minLines = minLines - 1
                maxLines = maxLines - 1
            end
        end
    end
)

bindKey("mouse_wheel_down", "down",
    function()
        if state then
            local text = "" 
            if textbars["search"] then
                text = textbars["search"][2][2]
            end
            local count = #cache

            if #text > 0 then
                count = #searchCache
            end
            if maxLines + 1 <= count then
                playSound("files/wheel.wav")
                minLines = minLines + 1
                maxLines = maxLines + 1
            end
        end
    end
)

function startScore()
    if not localPlayer:getData("loggedIn") then return end   
    _state = state
    state = true
    slots = localPlayer:getData("serverslot") or 512
    multipler = 20
    alpha = 0
    cacheCreate()
    if not _state then
        addEventHandler("onClientRender", root, drawnScoreboard, true, "low-5")
    end
    start = true
    bar = false
end

function stopScore()
    if not localPlayer:getData("loggedIn") then return end
    if isTimer(sTimer) then
        killTimer(sTimer)
    end
--  Clear()
    --removeEventHandler("onClientRender", root, drawnScoreboard)
    --state = false
    start = false
--    cacheDestroy()
end

function drawnScoreboard()
    if start then
        if alpha + multipler <= 255 then
            alpha = alpha + multipler
        elseif alpha >= 255 then
            alpha = 255
        end
    else
        if alpha - multipler >= 0 then
            alpha = alpha - multipler
        elseif alpha <= 0 then
            alpha = 0
            Clear()
            cacheDestroy()
            state = false
            removeEventHandler("onClientRender", root, drawnScoreboard)
            return
        end
    end
    
    font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    --local count = #cache
    local text = "" 
    if textbars["search"] then
        text = textbars["search"][2][2]
    end
    local count = count
    local _count = count
    
    if #text > 0 then
        count = #searchCache
        _count = count
    end
    --outputChatBox("countStart: " .. count)
    if count >= _maxLines then
        count = _maxLines
    end
    
    --outputChatBox("count: " .. count)
    --outputChatBox("maxLines: " .. maxLines)
    local y = center.y - ((((count) * sizes["center"].y) + (sizes["top"].y + sizes["bottom"].y)) / 2)
    dxDrawImage(center.x - sizes["top"].x/2, y, sizes["top"].x, sizes["top"].y, sources["top"], 0,0,0, tocolor(255,255,255,alpha))
    y = y + sizes["top"].y
    --local count = 0
    
    for i = minLines, maxLines do
        --count = count + 1
        if #text > 0 then
            if searchCache[i] then
                local v = searchCache[i]
                local loggedin = v["loggedin"]
                local id = v["id"]
                local aduty = v["aduty"]
                local aColor = v["aColor"]
                local aTitle = v["aTitle"]
                local name = v["name"]
                local lvl = v["lvl"]
                local ping = v["ping"]
                local pingColor = v["pingColor"]
                dxDrawImage(center.x - sizes["center"].x/2, y, sizes["center"].x, sizes["center"].y, sources["center"], 0,0,0, tocolor(255,255,255,alpha))

                local rx = center.x - sizes["center"].x/2 + 19
                dxDrawText(id, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                if loggedin then

                    local rx = center.x - sizes["center"].x/2 + 409
                    dxDrawText(lvl, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                    local rx = center.x - sizes["center"].x/2 + 462
                    dxDrawText(pingColor .. ping, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)
                end

                if aduty then
                    name = aColor .. "[" .. aTitle .. "] " .. white .. name
                end

                if not loggedin then
                    name = "#9c9c9c" .. name .. " (Nincs bejelentkezve)"
                end

                local rx = center.x - sizes["center"].x/2 + 211
                dxDrawText(name, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                y = y + sizes["center"].y
            end
        else
            if cache[i] then
                local v = cache[i]
                local loggedin = v["loggedin"]
                local id = v["id"]
                local aduty = v["aduty"]
                local aColor = v["aColor"]
                local aTitle = v["aTitle"]
                local name = v["name"]
                local lvl = v["lvl"]
                local ping = v["ping"]
                local pingColor = v["pingColor"]
                dxDrawImage(center.x - sizes["center"].x/2, y, sizes["center"].x, sizes["center"].y, sources["center"], 0,0,0, tocolor(255,255,255,alpha))

                local rx = center.x - sizes["center"].x/2 + 19
                dxDrawText(id, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                if loggedin then

                    local rx = center.x - sizes["center"].x/2 + 409
                    dxDrawText(lvl, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                    local rx = center.x - sizes["center"].x/2 + 462
                    dxDrawText(pingColor .. ping, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)
                end

                if aduty then
                    name = aColor .. "[" .. aTitle .. "] " .. white .. name
                end

                if not loggedin then
                    name = "#9c9c9c" .. name .. " (Nincs bejelentkezve)"
                end

                local rx = center.x - sizes["center"].x/2 + 211
                dxDrawText(name, rx, y, rx, y + 36, tocolor(255,255,255,alpha), 1, font, "center", "center",false,false,false,true)

                y = y + sizes["center"].y
            end
        end
    end
    y = math.floor(y)
    dxDrawImage(center.x - sizes["bottom"].x/2, y, sizes["bottom"].x, sizes["bottom"].y, sources["bottom"], 0,0,0, tocolor(255,255,255,alpha))
    local rx = center.x - sizes["bottom"].x/2 + 10
    local ry = y + 5
    if not bar then
        CreateNewBar("search", {rx, ry, sizes["search"].x, sizes["search"].y}, {15, "", false, tocolor(255,255,255,255), font, 1, "center", "center"}, 1)
        bar = true
    else
        UpdatePos("search", {rx, ry, sizes["search"].x, sizes["search"].y})
    end
    --dxDrawRectangle(rx - sizes["search"].x/2, ry - sizes["search"].y/2, sizes["search"].x, sizes["search"].y)
    
    local rx = center.x + sizes["center"].x/2 - 10
    
    dxDrawText("Online játékosok: #d97c0e"..#cache.."/"..slots, rx, y, rx, y + sizes["center"].y, tocolor(255,255,255,alpha), 1, font, "right", "center",false,false,false,true)
    y = y + sizes["bottom"].y
    dxDrawImage(center.x - sizes["staymta"].x/2, y, sizes["staymta"].x, sizes["staymta"].y, sources["staymta"], 0,0,0, tocolor(255,255,255,alpha))
end

--Cache Function
function cacheCreate()
    if state then
        cacheDestroy()

        local a = 1
        for k,v in pairs(getElementsByType("player")) do
            if v ~= localPlayer then
                local details = cacheGetDetails(v)
                table.insert(cache, details)
                a = a + 1
            end
        end

        --[[
        for i = 2, 30 do
            local details = cacheGetDetails(createPed(107, 0,0,0), "Random_Name")
            table.insert(cache, details)
            a = a + 1
        end
        ]]
        count = a

        local details = cacheGetDetails(localPlayer)
        table.insert(cache, 1, details)
        
        table.sort(cache, function(a, b)
            if a["element"] and b["element"] and a["element"] ~= localPlayer and b["element"] ~= localPlayer and a["id"] and b["id"] then
                return tonumber(a["id"]) < tonumber(b["id"])
            end
        end);

        if maxLines > #cache then
            minLines = 1
            maxLines = (screen.y - 150 - (sizes["top"].y + sizes["bottom"].y)) / 35
        end

        if isTimer(pingUpdateTimer) then destroyElement(pingUpdateTimer) end
        pingUpdateTimer = setTimer(
            function()
                --cacheCreate()
                for i = minLines, maxLines do
                    if cache[i] then
                        local _i = i
                        local i = cache[i]
                        local v = i["element"]
                        if isElement(v) then
                            cache[_i]["ping"] = v.ping or -1
                            cache[_i]["pingColor"] = getPingColor(v.ping or -1)
                        else
                            cacheCreate()
                        end
                    end
                end
            end, 1000, 0
        )

        --outputDebugString("Score: Cache - created")
    end
end

addEventHandler("onClientPlayerJoin", root, cacheCreate)
addEventHandler("onClientPlayerQuit", root, cacheCreate)

function cacheGetDetails(v, a2)
    local a = {}
    a["loggedin"] = v:getData("loggedIn") or false
    a["id"] = v:getData("char >> id") or 0
    a["aduty"] = v:getData("admin >> duty") or false
    a["aColor"] = exports['cr_admin']:getAdminColor(v, nil, true) or "#ffffff"
    a["aTitle"] = exports['cr_admin']:getAdminTitle(v) or "Ismeretlen"
    local name = a2 or exports['cr_admin']:getAdminName(v) or "Ismeretlen"
    name = string.gsub(name, "_", " ")
    a["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
    a["lvl"] = v:getData("char >> level") or 1
    a["ping"] = v.ping or -1
    a["pingColor"] = getPingColor(v.ping or -1)
    a["element"] = v
    return a
end

function cacheDestroy()
    cache = {}
    
    if isTimer(pingUpdateTimer) then
        killTimer(pingUpdateTimer)
    end
end

function search(e)
    for a, b in pairs(cache) do
        local x = b["element"]
        if x == e then
            return a
        end
    end
    
    --outputChatBox(i)
    return false
end

function getPingColor(ping)
    local color = "#ffffff"
    
    if ping <= 60 then -- zöld
        color = "#7cc576"
    elseif ping <= 130 then -- sárga
        color = "#d09924"
    elseif ping >= 130 then -- piros
        color = "#d02424"
    end
    
    return color
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue)
        if state then
            if dName == "loggedIn" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["loggedin"] = value
                end
            elseif dName == "char >> id" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["id"] = value
                end
            elseif dName == "admin >> duty" or "admin >> nick" or "admin >> name" or "admin >> level" then
                local k = search(source)
                if source == localPlayer then
                    cacheCreate()
                end
                
                if k then
                    local value = source:getData(dName)
                    if dName == "admin >> duty" then
                        cache[k]["aduty"] = value
                    end
                    
                    local name = exports['cr_admin']:getAdminName(source)
                    name = string.gsub(name, "_", " ")
                    cache[k]["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
                    cache[k]["aColor"] = exports['cr_admin']:getAdminColor(source, nil, true)
                    cache[k]["aTitle"] = exports['cr_admin']:getAdminTitle(source)
                    searchCache = {}
                    if textbars["search"] and textbars["search"][2] and textbars["search"][2] then
                        local text = string.lower(textbars["search"][2][2])
                        if #text > 0 then
                            for k,v in pairs(cache) do
                                local text2 = v["name"]
                                local e = v["element"]
                                if text == string.lower(utfSub(text2, 1, #text)) then
                                    if e == localPlayer then
                                        table.insert(searchCache, 1, v)
                                    else
                                        table.insert(searchCache, v)
                                    end
                                end
                            end
                            if maxLines > #searchCache then
                                minLines = 1
                                maxLines = (screen.y - 150 - (sizes["top"].y + sizes["bottom"].y)) / 35
                            end
                        end
                    end
                end
            elseif dName == "char >> name" then
                local k = search(source)
                if k then
                    local name = exports['cr_admin']:getAdminName(source)
                    name = string.gsub(name, "_", " ")
                    cache[k]["name"] = string.gsub(name, "#%x%x%x%x%x%x", "")
                    searchCache = {}
                    local text = string.lower(textbars["search"][2][2])
                    if #text > 0 then
                        for k,v in pairs(cache) do
                            local text2 = v["name"]
                            local e = v["element"]
                            if text == string.lower(utfSub(text2, 1, #text)) then
                                if e == localPlayer then
                                    table.insert(searchCache, 1, v)
                                else
                                    table.insert(searchCache, v)
                                end
                            end
                        end
                        if maxLines > #searchCache then
                            minLines = 1
                            maxLines = (screen.y - 150 - (sizes["top"].y + sizes["bottom"].y)) / 35
                        end
                    end
                end
            elseif dName == "char >> level" then
                local k = search(source)
                if k then
                    local value = source:getData(dName)
                    cache[k]["lvl"] = value
                end
            end
        end
    end
)