local specialElementData = {
    ["acc >> id"] = true,
    ["char >> id"] = true,
    ["admin >> level"] = true,
    ["char >> money"] = true,
    ["char >> premiumPoints"] = true,
    ["player >> id"] = true,
    ["loggedIn"] = true,
}

addEventHandler("onElementDataChange", root,
    function(dName, oValue)
        if client then
            if specialElementData[dName] then
                local element = exports['cr_admin']:getAdminName(client, false)
                local target = exports['cr_admin']:getAdminName(source, false)
                local elementtype = exports['cr_core']:getElementType(source)
                outputDebugString("[FEDC] Client: '"..element.."', Target: '"..target.."'!", 0, 255, 0, 0)
                setElementData(source, dName, oValue)
                if getElementType(source) == "player" then
                    outputChatBox(syntax3 .. "Elementdata változtatása hiba! (Jelentsd fejlesztőnek a szituációt!)", source, 255, 255, 255, true)
                end
                local clientUsername = exports['cr_admin']:getAdminName(client, false) or inspect(client)
                local clientIP = getPlayerIP(client) or "Unknown"
                local clientSerial = getElementData(client, "mtaserial") or getPlayerSerial(client) or "Unknown"
                outputDebugString("[FEDC] Client Details: (IP: "..clientIP.."), Serial: "..clientSerial..", Username: "..clientUsername, 0, 255, 0, 0)
                local targetUsername = exports['cr_admin']:getAdminName(source, false) or inspect(source)
                local targetIP = getPlayerIP(source) or "Unknown"
                local targetSerial = getElementData(source, "mtaserial") or getPlayerSerial(source) or "Unknown"
                outputDebugString("[FEDC] Target Details: (IP: "..targetIP.."), Serial: "..targetSerial..", Username: "..targetUsername, 0, 255, 0, 0)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(element, "FEDC", "logs", "Client: '"..(tonumber(getElementData(element, "acc >> id")) or inspect(element)).."' (Client Details: (IP: "..clientIP.."), Serial: "..clientSerial..", Username: "..clientUsername.."), Target: '"..(tonumber(getElementData(target, "acc >> id")) or inspect(target)).."' (Target Details: (IP: "..targetIP.."), Serial: "..targetSerial..", Username: "..targetUsername..")")
            end
        end
    end
)