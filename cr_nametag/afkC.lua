--

afk = false
lastClickTick = -5000

function startAfkTimer()
    stopAfkTimer()
    --outputChatBox("Afk start: "..tostring(afk))
    if afk then
        seconds = 0
        setElementData(localPlayer, "afk.seconds", "00")
        minutes = 0
        setElementData(localPlayer, "afk.minutes", "00")
        hours = 0
        setElementData(localPlayer, "afk.hours", "00")
        afkTimer = setTimer(
            function()
                seconds = seconds + 1
                setElementData(localPlayer, "afk.seconds", formatString(seconds))
                if seconds >= 60 then
                    seconds = 0 
                    setElementData(localPlayer, "afk.seconds", formatString(seconds))
                    minutes = minutes + 1
                    setElementData(localPlayer, "afk.minutes", formatString(minutes))

                    if minutes >= 30 then
                        --triggerServerEvent("acheat:kick", localPlayer, localPlayer, "Túl sokat afkoltál (Átlépted a 30 perces korlátot)!")
                    end

                    if minutes >= 60 then
                        minutes = 0
                        setElementData(localPlayer, "afk.minutes", formatString(minutes))
                        hours = hours + 1
                        setElementData(localPlayer, "afk.hours", formatString(hours))
                    end
                end
            end, 1000, 0
        )
    end
end

function stopAfkTimer()
    --outputChatBox("Afk stop: "..tostring(afk))
    if isTimer(afkTimer) then
        killTimer(afkTimer)
        seconds, minutes, hours = 0,0,0
        setElementData(localPlayer, "afk.seconds", nil)
        setElementData(localPlayer, "afk.minutes", nil)
        setElementData(localPlayer, "afk.hours", nil)
    end
end
--

local lastClickTick = getTickCount()

addEventHandler("onClientKey", root, 
    function()
        lastClickTick = getTickCount()
        if afk then
            --outputChatBox("asd")
            stopAfkTimer()
            setElementData(localPlayer, "char >> afk", false)
            afk = false
        end
    end
)

setTimer( 
    function()
	    local nowTick = getTickCount()
        if nowTick - lastClickTick >= 30000 then
            if not afk then
                afk = true
                startAfkTimer()
                setElementData(localPlayer, "char >> afk", true)
            end
        end
    end, 300, 0
)
	
addEventHandler("onClientRestore", root, 
    function()
        lastClickTick = getTickCount()
        if afk then
            setElementData(localPlayer, "char >> afk", false)
            stopAfkTimer()
            afk = false
        end
    end
)

addEventHandler("onClientMinimize", root, 
    function()
        if not afk then
            afk = true
            startAfkTimer()
            setElementData(localPlayer, "char >> afk", true)
        end
    end
)
	
addEventHandler("onClientCursorMove", root, 
    function()
	    lastClickTick = getTickCount()
        if afk then
            setElementData(localPlayer, "char >> afk", false)
            stopAfkTimer()
            afk = false
        end
    end
)

local seconds,minutes,hours = 0, 0, 0

function formatString(s)
    if s < 10 then
        return "0" .. tostring(s)
    end
    return tostring(s)
end

if getElementData(localPlayer, "char >> afk") then
    afk = true
    startAfkTimer()
end