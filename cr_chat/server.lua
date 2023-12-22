function playerChat(message, messageType)
	cancelEvent()
    triggerClientEvent(source, "onClientMessage", source, source, message, messageType)

    if messageType == 0 and getElementData(source, "gameSettings->ChatStyle") then
        setPedAnimation(source, "gangs", getElementData(source, "gameSettings->ChatStyle"), #message:gsub(" ", "") * 145, true, true, false, false);
    end
end
addEventHandler("onPlayerChat", root, playerChat)

function createMessage(element, message, mtype)
    triggerClientEvent(element, "createMessage", element, element, message, mtype)
end

addEvent("giveMessageToClient", true)
addEventHandler("giveMessageToClient", root, 
    function(sElement, e, text, r,g,b, whisper, ooc)
        if not whisper then whisper = false end
        if not ooc then ooc = false end
        triggerClientEvent(e, "chat -- receive", e, e, text, r,g,b, whisper, ooc)
        
        if ooc then
            outputServerLog("[OOC] " .. text)
        else
            outputServerLog(text)
            triggerClientEvent(e, "addBubble", e, sElement, text, r,g,b)
        end
    end
)

local cache = {}
 
function blockFlood()
	if not cache[source] then
        cache[source] = {}
        cache[source]["num"] = 1
        local source = source
        if not isTimer(cache[source]["timer"]) then
            cache[source]["timer"] = setTimer(
                function()
                    if cache[source]["num"] - 1 >= 1 then
                        cache[source]["num"] = cache[source]["num"] - 1 
                    else
                        cache[source]["num"] = 0
                        killTimer(cache[source]["timer"])
                    end
                end, 500, 0
            )
        end
	else
        local source = source
        cache[source]["num"] = cache[source]["num"] + 1
        if cache[source]["num"] >= 5 and cache[source]["num"] <= 20 then
            cancelEvent()
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. " 1 másodpercen belül csak 5 parancs használható!", source, 255,255,255,true)
        elseif cache[source]["num"] >= 20 then
            cancelEvent()
            setElementData(source, "specialKick", true)
            setElementData(source, "specialKickReason", "Floodolás miatt!")
            kickPlayer(source, "Rendszer", "Túl sok parancsot használtál 1 másodpercen belül! (Flood érzékelve, feltüntetve!)")
        end
        if not isTimer(cache[source]["timer"]) then
            cache[source]["timer"] = setTimer(
                function()
                    if cache[source]["num"] - 1 >= 1 then
                        cache[source]["num"] = cache[source]["num"] - 1 
                    else
                        cache[source]["num"] = 0
                        killTimer(cache[source]["timer"])
                    end
                end, 500, 0
            )
        end
	end
end
addEventHandler("onPlayerCommand", root, blockFlood)

addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "animation" then
            local forceAnim = false
            local forceAnimation = getElementData(source, "forceAnimation") or {"", ""}
            if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
                forceAnim = true
            end
            if forceAnim then
                return
            end
            local value = getElementData(source, dName)
            if value[2] == "shout_01" then
                setPedAnimation(source, value[1], value[2], 1000,false,false,false,false)
            else
                setPedAnimation(source, value[1], value[2], 3000,false,false,false,false)
            end
        end
    end
)