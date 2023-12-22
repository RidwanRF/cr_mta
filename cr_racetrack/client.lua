local cache = {}
local sx, sy = guiGetScreenSize()
local white = "#ffffff"
lastClickTick = -500
gPrice = 100
gPrice2 = 50

lastFrame = 0

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        gMarker = Marker(434.70611572266, 598.26989746094, 17.6, "cylinder", 3.3)
        gMarker.alpha = 0
        cache[gMarker] = 2
        gMarker5 = Marker(429.21499633789, 606.33648681641, 17.6, "cylinder", 3.3)
        gMarker5.alpha = 0
        cache[gMarker5] = 2
        
        function returnData(d)
            gObj = d[1]
            --bestSectorDetails = d[2]
            playerTimes = d[2]
            --outputChatBox(playerTimes[1][5])
            local table = {}
            if playerTimes[1] and playerTimes[1][2] then
                for k, v in pairs(playerTimes[1][2]) do
                    if k ~= "last" then
                        table[tonumber(k)] = v
                    else
                        table[k] = v
                    end
                end
            end
            --outputChatBox(playerTimes[1][5])
            bestSectorDetails = table
            --outputDebugString(inspect(bestSectorDetails))
            if not bestSectorDetails then
                bestSectorDetails = {}
            end
            addEventHandler("onClientElementDataChange", gObj,
                function(dName)
                    if dName == "moveState" then
                        if source:getData(dName) then
                            gMarker.position = Vector3(434.70611572266, 598.26989746094, -17.6)
                            gMarker5.position = Vector3(429.21499633789, 606.33648681641, -17.6)
                        else
                            gMarker.position = Vector3(434.70611572266, 598.26989746094, 17.6)
                            gMarker5.position = Vector3(429.21499633789, 606.33648681641, 17.6)
                        end
                    end
                end
            )
            
            if isElement(texElement) then destroyElement(texElement) end
            if isElement(shadElement) then destroyElement(shadElement) end
            if isElement(shader) then
                destroyElement(shader)
            end
            if isElement(renderTarget) then
                destroyElement(renderTarget)
            end
            if isThisRace or isTryThisRace then return end
            renderTarget = dxCreateRenderTarget(420, 10 * 20)
            shader = dxCreateShader("files/texturechanger.fx")
            dxSetShaderValue(shader, "nTexture", renderTarget)
            engineApplyShaderToWorldTexture(shader, "monitor")
            --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
            if isTimer(renderTimer) then killTimer(renderTimer) end
            renderTopList()
            renderTimer = setTimer(renderTopList, 2000, 0)
        end
        addEvent("returnData", true)
        addEventHandler("returnData", localPlayer, returnData)
        
        triggerServerEvent("returnData", localPlayer, localPlayer)
        
        function onStartMarkerHit(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel()
            
            if isElement(gMarker) and getDistanceBetweenPoints3D(gMarker.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent1)
                end
            end
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
            local w,h = 300, 200
            local x,y = sx/2 - w/2, sy/2 - h/2
            local color = exports['cr_core']:getServerColor(nil, true)
            dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
            dxDrawText("A versenypályára való belépéshez \n"..color..gPrice..white.."$-t kell fizess!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
            
            local w2, h2 = 280, 40
            selected = nil
            if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
                selected = 1
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
                dxDrawText("Befizetés", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
                dxDrawText("Befizetés", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
            
            if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
                selected = 2
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
                dxDrawText("Bezárás", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
                dxDrawText("Bezárás", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
        end
        
        function onClickEvent1(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if exports['cr_core']:takeMoney(localPlayer, gPrice) then
                        if panelState then
                            exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent1)
                            triggerServerEvent("gateOpen", localPlayer, localPlayer)
                            removeEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
                            removeEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)    
                            addEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
                            addEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)    
                            gMarker2 = Marker(398.60223388672, 607.67535400391, 7.9, "cylinder", 3.3)
                            gMarker2.alpha = 0
                            cache[gMarker2] = 2
                            
                            addEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                            addEventHandler("onClientMarkerLeave", gMarker2, onStartMarkerLeave2)    
                            
                            gMarker3 = Marker(396.60668945313, 611.68218994141, 7.95, "cylinder", 3.3)
                            gMarker3.alpha = 0
                            cache[gMarker3] = 2
                            
                            addEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                            addEventHandler("onClientMarkerLeave", gMarker3, onStartMarkerLeave3)    
                        end
                    else
                        if panelState then
                            exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent1)
                        end
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent1)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit5(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
        
        function onStartMarkerLeave5(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
            end
        end
        addEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)
        
        function drawnPanel5()
            if isElement(gMarker5) and getDistanceBetweenPoints3D(gMarker5.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    --outputChatBox("asd")
                    removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent5)
                end
            end
            
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
            local w,h = 300, 200
            local x,y = sx/2 - w/2, sy/2 - h/2
            local color = exports['cr_core']:getServerColor(nil, true)
            dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
            dxDrawText("Elszeretnéd hagyni a versenypályát?", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
            
            local w2, h2 = 280, 40
            selected = nil
            if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
                selected = 1
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
            
            if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
                selected = 2
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
        end
        
        function onClickEvent5(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                        triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
                        addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)    
                        removeEventHandler("onClientMarkerHit", gMarker5, onStartMarkerHit5)        
                        removeEventHandler("onClientMarkerLeave", gMarker5, onStartMarkerLeave5)    

                        --DESTROY
                        
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                        --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    

                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    

                        if isElement(gMarker2) then
                            destroyElement(gMarker2)
                            renderCache[gMarker2] = nil
                            cache[gMarker2] = nil
                        end

                        if isElement(gMarker3) then
                            destroyElement(gMarker3)
                            renderCache[gMarker3] = nil
                            cache[gMarker3] = nil
                        end

                        if isElement(gMarker4) then
                            destroyElement(gMarker4)
                            renderCache[gMarker4] = nil
                            cache[gMarker4] = nil
                        end
                        
                        if oStates then
                            localPlayer:setData("hudVisible", oStates[1])
                            localPlayer:setData("keysDenied", oStates[2])
                            exports['cr_custom-chat']:showChat(oStates[3])
                        end
                        --triggerAFrissítésre!!

                        removeEventHandler("onClientRender", root, drawnHud)

                        if isElement(shader) then
                            destroyElement(shader)
                        end

                        if isElement(renderTarget) then
                            destroyElement(renderTarget)
                        end

                        if isElement(texElement) then
                            destroyElement(texElement)
                        end

                        if isElement(shadElement) then
                            destroyElement(shadElement)
                        end

                        if isElement(texElement) then destroyElement(texElement) end
                        if isElement(shadElement) then destroyElement(shadElement) end
                        if isElement(shader) then
                            destroyElement(shader)
                        end
                        if isElement(renderTarget) then
                            destroyElement(renderTarget)
                        end
                        renderTarget = dxCreateRenderTarget(420, 10 * 20)
                        shader = dxCreateShader("files/texturechanger.fx")
                        dxSetShaderValue(shader, "nTexture", renderTarget)
                        engineApplyShaderToWorldTexture(shader, "monitor")
                        --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
                        
                        if isThisRace then
                            isThisRace = nil
                        end
                        
                        if isTryThisRace then
                            isTryThisRace = nil
                        end
                        
                        triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off")
                        
                        if isTimer(renderTimer) then killTimer(renderTimer) end
                        renderTopList()
                        renderTimer = setTimer(renderTopList, 2000, 0)
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel5, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent5)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit2(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave2(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel2()
            if isElement(gMarker2) and getDistanceBetweenPoints3D(gMarker2.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent2)
                end
            end
            
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
            local w,h = 300, 200
            local x,y = sx/2 - w/2, sy/2 - h/2
            local color = exports['cr_core']:getServerColor(nil, true)
            dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
            dxDrawText("Szeretnél menni egy kört?\n"..color..gPrice2..white.."$-ba fog kerülni!", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
            
            local w2, h2 = 280, 40
            selected = nil
            if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
                selected = 1
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
            
            if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
                selected = 2
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
        end
        
        function onClickEvent2(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        if exports['cr_core']:takeMoney(localPlayer, gPrice2) then
                            localPlayer.vehicle.position = Vector3(398.60223388672, 607.67535400391, 9.25)
                            localPlayer.vehicle.rotation = Vector3(0, 0, 296)
                            --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                            panelState = false
                            removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                            removeEventHandler("onClientClick", root, onClickEvent2)
                            --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                            removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                            removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    

                            removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                            removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    

                            destroyElement(gMarker2)
                            renderCache[gMarker2] = nil
                            cache[gMarker2] = nil
                            
                            isThisRace = true
                            
                            triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "on")

                            destroyElement(gMarker3)
                            renderCache[gMarker3] = nil
                            cache[gMarker3] = nil

                            localPlayer.vehicle.frozen = true
                            if isElement(texElement) then destroyElement(texElement) end
                            if isElement(shadElement) then destroyElement(shadElement) end
                            
                            local v = "monitor"
                            texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                            shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                            engineApplyShaderToWorldTexture(shadElement, v)
                            dxSetShaderValue(shadElement, "gTexture", texElement)

                            oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), exports['cr_custom-chat']:isChatVisible()}
                            localPlayer:setData("hudVisible", false)
                            localPlayer:setData("keysDenied", true)
                            exports['cr_custom-chat']:showChat(false)

                            local i = 1
                            startTimer = setTimer(
                                function()
                                    if isElement(texElement) then destroyElement(texElement) end
                                    if isElement(shadElement) then destroyElement(shadElement) end

                                    local v = "monitor-" .. i
                                    i = i + 1
                                    texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                                    shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                                    engineApplyShaderToWorldTexture(shadElement, "monitor")
                                    dxSetShaderValue(shadElement, "gTexture", texElement)

                                    if i == 5 then
                                        --outputChatBox("Start")
                                        startTime = getTickCount()
                                        localPlayer.vehicle.frozen = false
                                        if isTimer(startTimer) then killTimer(startTimer) end

                                        addEventHandler("onClientRender", root, drawnHud, true, "low-5")
                                        sector = 0
                                        sectorTimes = {}
                                        generateNextSector()

                                        startingGridTimer = setTimer(
                                            function()
                                                if isElement(texElement) then destroyElement(texElement) end
                                                if isElement(shadElement) then destroyElement(shadElement) end
                                                if isElement(shader) then
                                                    destroyElement(shader)
                                                end
                                                if isElement(renderTarget) then
                                                    destroyElement(renderTarget)
                                                end
                                                if isTimer(renderTimer) then killTimer(renderTimer) end
                                                renderTarget = dxCreateRenderTarget(400/2, 150/2)
                                                shader = dxCreateShader("files/texturechanger.fx")
                                                dxSetShaderValue(shader, "nTexture", renderTarget)
                                                engineApplyShaderToWorldTexture(shader, "monitor")
                                            end, 2000, 1
                                        )
                                    end
                                end, 2000, 0
                            )
                        else
                            if panelState then
                                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                                panelState = false
                                removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                                removeEventHandler("onClientClick", root, onClickEvent2)
                            end
                        end
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel2, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent2)
                    end
                end
                selected = nil
            end
        end
        
        function onStartMarkerHit3(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension and getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 4 then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if not panelState then
                        panelState = true
                        addEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        addEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerHit", gMarker, onStartMarkerHit)        
        
        function onStartMarkerLeave3(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local veh = getPedOccupiedVehicle(localPlayer)
                if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if panelState then
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
            end
        end
        --addEventHandler("onClientMarkerLeave", gMarker, onStartMarkerLeave)
        
        function drawnPanel3()
            if isElement(gMarker3) and getDistanceBetweenPoints3D(gMarker3.position, localPlayer.position) >= 5 or not localPlayer.vehicle then
                if panelState then
                    panelState = false
                    removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                    removeEventHandler("onClientClick", root, onClickEvent3)
                end
            end
            
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 9)
            local w,h = 300, 200
            local x,y = sx/2 - w/2, sy/2 - h/2
            local color = exports['cr_core']:getServerColor(nil, true)
            dxDrawRectangle(x,y,w,h, tocolor(0,0,0,150))
            dxDrawText("Szeretnél menni egy próbakört?", x, y, x + w, y + h/2, tocolor(255,255,255,255), 1, font, "center", "center", _, _, _, true)
            
            local w2, h2 = 280, 40
            selected = nil
            if isInSlot(x + w/2 - w2/2,y + h/2 - 10,w2,h2) then
                selected = 1
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,180))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 - 10,w2,h2, tocolor(51, 255, 51,120))
                dxDrawText("Igen", x + w/2 - w2/2,y + h/2 - 10, x + w/2 - w2/2 + w2,y + h/2 - 10 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
            
            if isInSlot(x + w/2 - w2/2,y + h/2 + 40,w2,h2) then
                selected = 2
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,180))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,255), 1, font2, "center", "center")
            else
                dxDrawRectangle(x + w/2 - w2/2,y + h/2 + h2,w2,h2, tocolor(255, 51, 51,120))
                dxDrawText("Nem", x + w/2 - w2/2,y + h/2 + h2, x + w/2 - w2/2 + w2,y + h/2 + h2 + h2, tocolor(255,255,255,180), 1, font2, "center", "center")
            end
        end
        
        function onClickEvent3(b, s)
            if b == "left" and s == "down" then
                if selected == 1 then
                    if getTickCount() <= lastClickTick + 1000 then
                        return
                    end
                    lastClickTick = getTickCount()
                    
                    if panelState then
                        localPlayer.vehicle.position = Vector3(396.81677246094, 611.85760498047, 9.25)
                        localPlayer.vehicle.rotation = Vector3(0, 0, 296)
                        --exports['cr_infobox']:addBox("info", "Menj a kezdőrácsoknál található jelzéshez a kezdéshez!")
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                        --triggerServerEvent("gateOpen", localPlayer, localPlayer)
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                        removeEventHandler("onClientMarkerHit", gMarker2, onStartMarkerLeave2)    
                        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                        removeEventHandler("onClientMarkerHit", gMarker3, onStartMarkerLeave3)    
                        
                        destroyElement(gMarker2)
                        renderCache[gMarker2] = nil
                        cache[gMarker2] = nil
                        
                        destroyElement(gMarker3)
                        renderCache[gMarker3] = nil
                        cache[gMarker3] = nil
                        
                        isTryThisRace = true
                        
                        triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "on")
                        
                        localPlayer.vehicle.frozen = true
                        local v = "monitor"
                        texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                        shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                        engineApplyShaderToWorldTexture(shadElement, v)
                        dxSetShaderValue(shadElement, "gTexture", texElement)
                        
                        oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied"), exports['cr_custom-chat']:isChatVisible()}
                        localPlayer:setData("hudVisible", false)
                        localPlayer:setData("keysDenied", true)
                        
                        local i = 1
                        startTimer = setTimer(
                            function()
                                if isElement(texElement) then destroyElement(texElement) end
                                if isElement(shadElement) then destroyElement(shadElement) end
                                
                                local v = "monitor-" .. i
                                i = i + 1
                                texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
                                shadElement = dxCreateShader(":cr_texture/files/replace.fx", 0, 100, false, "all")
                                engineApplyShaderToWorldTexture(shadElement, "monitor")
                                dxSetShaderValue(shadElement, "gTexture", texElement)
                                
                                if i == 5 then
                                    --outputChatBox("Start")
                                    startTime = getTickCount()
                                    localPlayer.vehicle.frozen = false
                                    if isTimer(startTimer) then killTimer(startTimer) end
                                    
                                    addEventHandler("onClientRender", root, drawnHud, true, "low-5")
                                    sector = 0
                                    sectorTimes = {}
                                    generateNextSector()
                                    
                                    startingGridTimer = setTimer(
                                        function()
                                            if isElement(texElement) then destroyElement(texElement) end
                                            if isElement(shadElement) then destroyElement(shadElement) end
                                            if isElement(shader) then
                                                destroyElement(shader)
                                            end
                                            if isElement(renderTarget) then
                                                destroyElement(renderTarget)
                                            end
                                            if isTimer(renderTimer) then killTimer(renderTimer) end
                                            renderTarget = dxCreateRenderTarget(400/2, 150/2)
                                            shader = dxCreateShader("files/texturechanger.fx")
                                            dxSetShaderValue(shader, "nTexture", renderTarget)
                                            engineApplyShaderToWorldTexture(shader, "monitor")
                                        end, 2000, 1
                                    )
                                end
                            end, 2000, 0
                        )
                    end
                elseif selected == 2 then
                    if panelState then
                        if getTickCount() <= lastClickTick + 500 then
                            return
                        end
                        lastClickTick = getTickCount()
                        panelState = false
                        removeEventHandler("onClientRender", root, drawnPanel3, true, "low-5")
                        removeEventHandler("onClientClick", root, onClickEvent3)
                    end
                end
                selected = nil
            end
        end
        
        --sector = 0
        function drawnHud()
            local font = exports['cr_fonts']:getFont("Rubik-Regular", 13, true)
            --local font = exports['cr_fonts']:getFont("Rubik-Regular", 14, true)
            local font2 = exports['cr_fonts']:getFont("Rubik-Regular", 11)
            local text1 = "S ".. sector .. "/" .. #sectorDetails + 1
            local x, y = sx - 350, 100
            dxDrawText(text1, x, y - 40, x + 300 - 10, y - 20, tocolor(255,255,255,255), 1, font, "right", "center")
            _dxDrawRectangle(x, y, 300, 20, tocolor(0,0,0,150)) -- Alsó
            _dxDrawRectangle(x, y - 20, 300, 20, tocolor(0,0,0,150)) -- Felső
            dxDrawText("Best", x, y - 20, x + 300 - 10, y, tocolor(255,255,255,255), 1, font2, "right", "center")
            dxDrawText((bestSectorDetails[sector + 1] and formatIntoTime(bestSectorDetails[sector + 1])) or "-----", x + 10, y - 20, x + 300, y, tocolor(255,255,255,255), 1, font2, "left", "center")
            dxDrawLine(x, y, x + 300, y, tocolor(255,255,255,150))
            dxDrawText("Now", x, y, x + 300 - 10, y + 20, tocolor(255,255,255,255), 1, font2, "right", "center")
            local text1 = formatIntoTime(getTickCount() - startTime)
            dxDrawText(text1, x + 10, y, x + 300, y + 20, tocolor(255,255,255,255), 1, font2, "left", "center")
            
            if (bestSectorDetails[sector + 1]) then
                if anim then
                    local now = getTickCount()
                    local elapsedTime = now - animStart
                    local duration = animEnd - animStart
                    local progress = elapsedTime / duration
                    local alpha, _, _ = interpolateBetween ( 
                        0, 0, 0,
                        255, 0, 0, 
                        progress, "OutBounce")
                    if tonumber(animText) <= 0 then
                        _dxDrawRectangle(x, y + 20, 300, 20, tocolor(51,255,51,math.min(alpha, 150))) -- Felső
                    else
                        _dxDrawRectangle(x, y + 20, 300, 20, tocolor(255,51,51,math.min(alpha, 150))) -- Felső
                    end
                    if progress >= 1 then
                        anim = false    
                    end
                    dxDrawText(formatIntoTime(animText, true), x + 10, y + 20, x + 300, y + 40, tocolor(255,255,255,alpha), 1, font2, "left", "center")
                end

                if not isTimer(startingGridTimer) and isElement(renderTarget) then
                    if getTickCount() >= lastFrame + 2000 then
                        dxSetRenderTarget(renderTarget, true)

                        _dxDrawRectangle(0, 0, 400/2, 150/2, tocolor(54, 54, 54, 255))
                        dxDrawText(text1, 0, 0, 400/2, 150/2, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)

                        dxSetRenderTarget()
                        lastFrame = getTickCount()
                    end
                end
            end
        end
        
--        addEventHandler("onClientRender", root, drawnHud)
        
        function func(hitPlayer, matchingDimension)
            if hitPlayer == localPlayer and matchingDimension then
                local num2 = getTickCount() - startTime
                if (bestSectorDetails[sector + 1]) then
                    alpha = 0
                    anim = true
                    animStart = getTickCount()
                    animEnd = animStart + 1000
                    local num = bestSectorDetails[sector + 1]
                    --num2 = getTickCount() - startTime
                    animText = num2 - num
                end
                removeEventHandler("onClientMarkerHit", source, func)    
                sectorTimes[sector] = num2
                destroyElement(gMarker4)
                cache[gMarker4] = nil
                renderCache[gMarker4] = nil
                generateNextSector()
            end
        end
        
        function generateNextSector()
            sector = sector + 1
            --sectorTimes[sector] = getTickCount()
            
            if not sectorDetails[sector] then -- last
                sectorTimes[sector] = getTickCount()  - startTime
                sectorTimes["last"] = getTickCount()  - startTime
                --outputDebugString(inspect(sectorTimes))
                --outputChatBox("Vége")
                
                exports['cr_infobox']:addBox("info", "Sikeresen futam! Idő: ".. formatIntoTime(sectorTimes["last"]))
                
                --oStates = {localPlayer:getData("hudVisible"), localPlayer:getData("keysDenied")}
                if oStates then
                    localPlayer:setData("hudVisible", oStates[1])
                    localPlayer:setData("keysDenied", oStates[2])
                    exports['cr_custom-chat']:showChat(oStates[3])
                end
                
                --triggerAFrissítésre!!
                
                removeEventHandler("onClientRender", root, drawnHud)
                
                if isElement(shader) then
                    destroyElement(shader)
                end
                
                if isElement(renderTarget) then
                    destroyElement(renderTarget)
                end
                
                if isElement(texElement) then
                    destroyElement(texElement)
                end
                
                if isElement(shadElement) then
                    destroyElement(shadElement)
                end
                
                if isElement(texElement) then destroyElement(texElement) end
                if isElement(shadElement) then destroyElement(shadElement) end
                if isElement(shader) then
                    destroyElement(shader)
                end
                if isElement(renderTarget) then
                    destroyElement(renderTarget)
                end
                renderTarget = dxCreateRenderTarget(420, 10 * 20)
                shader = dxCreateShader("files/texturechanger.fx")
                dxSetShaderValue(shader, "nTexture", renderTarget)
                engineApplyShaderToWorldTexture(shader, "monitor")
                --addEventHandler("onClientRender", root, renderTopList, true, "low-5")
                if isTimer(renderTimer) then killTimer(renderTimer) end
                renderTopList()
                renderTimer = setTimer(renderTopList, 2000, 0)
                
                if isThisRace then
                    --TRIGGER
                    isThisRace = nil
                    triggerServerEvent("playerTime", localPlayer, localPlayer, sectorTimes)
                end
                
                if isTryThisRace then
                    isTryThisRace = nil
                end
                
                triggerServerEvent("ghostMode", localPlayer, localPlayer.vehicle, "off")
                
                gMarker2 = Marker(398.60223388672, 607.67535400391, 7.9, "cylinder", 3.3)
                gMarker2.alpha = 0
                cache[gMarker2] = 2

                addEventHandler("onClientMarkerHit", gMarker2, onStartMarkerHit2)        
                addEventHandler("onClientMarkerLeave", gMarker2, onStartMarkerLeave2)    

                gMarker3 = Marker(396.60668945313, 611.68218994141, 7.95, "cylinder", 3.3)
                gMarker3.alpha = 0
                cache[gMarker3] = 2

                addEventHandler("onClientMarkerHit", gMarker3, onStartMarkerHit3)        
                addEventHandler("onClientMarkerLeave", gMarker3, onStartMarkerLeave3)    
                return
            end
            
            local x,y,z = unpack(sectorDetails[sector])
            gMarker4 = Marker(x,y,z, "cylinder", 9)
            gMarker4.alpha = 0
            cache[gMarker4] = 7

            addEventHandler("onClientMarkerHit", gMarker4, func)    
        end
    end
)

function renderTopList()
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    
    dxSetRenderTarget(renderTarget, true)
    
    _dxDrawRectangle(0, 0, 420, 10 * 20, tocolor(54, 54, 54, 255))
    local startY = 0
    for i = 1, 10 do
        local v = playerTimes[i]
        if v then
            local modelid = playerTimes[i][5]
            local time, sectorDetails, playerName, playerID = unpack(v)
            --modelid = 502
            local time = formatIntoTime(time)
            dxDrawText("#"..i.." > "..time .. " - "..playerName .. " - " .. exports['cr_vehicle']:getVehicleName(modelid), 10, startY, 420, startY + 20, tocolor(255,255,255,255), 1, font, "left", "center")
            startY = startY + 20
        end
    end
    
    dxSetRenderTarget()
end

--Render
        
local screenSize = {guiGetScreenSize()}
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

_dxDrawRectangle = dxDrawRectangle;
dxDrawRectangle = function(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
end

local material = dxCreateTexture("files/racing-flag.png")
function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

function drawnOctagon()
    for gMarker, v in pairs(renderCache) do 
        local x,y,z = getElementPosition(gMarker)
        if not isElement(gMarker) then
            renderCache[gMarker] = nil
        end
        cx, cy, cz = x,y,z + 3
        ----outputChatBox("asd")
        ----outputChatBox(x)
        z = z + 0.399
        local now = getTickCount()
        local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve")
        dxDrawOctagon3D(x,y,z, v, v >= 6 and 6 or 3, tocolor(255,51,51,alpha))
        z = z + multipler
        dxDrawImage3D(x, y, z+2, 1, 1, material,tocolor(255,51,51,alpha))
    end
end

setTimer(
    function()
        renderCache = {}
        last = nil
        for element, value in pairs(cache) do
            if isElement(element) and isElementStreamedIn(element) then
                local int, dim = element.interior, element.dimension
                local localInt, localDim = getElementInterior(localPlayer), getElementDimension(localPlayer)
                if int == localInt and dim == localDim then
                    --local elementX, elementY, elementZ = unpack(value["position"])
                    --local cameraX, cameraY, cameraZ = getCameraMatrix()
                    local maxDistance = 60
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
                    if distance <= maxDistance then
                        renderCache[element] = value
                        last = element

                        if not state then
                            state = true
                            addEventHandler("onClientRender", root, drawnOctagon, true, "low-5")
                        end
                    end
                end
            end
        end
        
        if not last and state then
            state = false
            removeEventHandler("onClientRender", root, drawnOctagon)
        end
    end, 300, 0
)
-- #optimizált


function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end