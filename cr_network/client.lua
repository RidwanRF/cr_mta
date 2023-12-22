local networkStatus = false -- // TRUE = szar, FALSE = JÓ

addEventHandler("onClientRender", root,
    function()
        local network = getNetworkStats()
        local breaked = false
        
        --outputChatBox(("packetlossTotal:"..network["packetlossTotal"])
        if network["packetlossTotal"] > 3 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to packetloss!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("packetlossLastSecond:"..network["packetlossLastSecond"])
        if network["packetlossLastSecond"] >= 1.6 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to packetloss!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("messagesInResendBuffer:"..network["messagesInResendBuffer"])
        if network["messagesInResendBuffer"] >= 2 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to messagesInResendBuffer!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("isLimitedByCongestionControl:"..network["isLimitedByCongestionControl"])
        if network["isLimitedByCongestionControl"] > 0 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to isLimitedByCongestionControl!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("isLimitedByOutgoingBandwidthLimit:"..network["isLimitedByOutgoingBandwidthLimit"])
        if network["isLimitedByOutgoingBandwidthLimit"] > 0 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to isLimitedByOutgoingBandwidthLimit!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        --outputChatBox(("Ping:" .. localPlayer.ping)
        if localPlayer.ping > 220 then
            if not networkStatus then
                outputConsole("[Network] Switched off due to ping!")
                networkStatus = true
                --localPlayer:setData("toggleCursor", true)
                lastBreakedTick = getTickCount()
                return
            end
            
            breaked = true
        end
        
        if networkStatus and not breaked then
            if lastBreakedTick + 3000 <= getTickCount() then
                outputConsole("[Network] Switched on!")
                localPlayer:setData("toggleCursor", false)
                networkStatus = false
                return
            end
        end
    end, true, "high+55"
)

function getNetworkStatus()
    return networkStatus
end