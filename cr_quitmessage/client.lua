local reasons = {
    ["Unknown"] = "Ismeretlen",
    ["Quit"] = "Kilépett",
    ["Kicked"] = "Kirúgva",
    ["Banned"] = "Kitiltva",
    ["Bad Connection"] = "Rossz kapcsolat",
    ["Timed out"] = "Időtúllépés",
}

local maxDist = 80

addEventHandler("onClientPlayerQuit", root,
    function(reason)
        local x1, y1, z1 = getElementPosition(localPlayer)
        local x2, y2, z2 = getElementPosition(source)
        local dim1 = getElementDimension(localPlayer)
        local dim2 = getElementDimension(source)
        if dim1 ~= dim2 then return end
        local int1 = getElementInterior(localPlayer)
        local int2 = getElementInterior(source)
        if int1 ~= int2 then return end
        local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
        if dist <= maxDist then
            local name = getElementData(source, "char >> name"):gsub("_", " ") or getPlayerName(source):gsub("_", " ")
            local reason = reasons[reason]
            if not reason then
                reason = "Időtúlépés"
            end
            local low = exports['cr_core']:getServerSyntax("Quit", "warning")
            if reason == "Kicked" and getElementData(source, "specialKick") then
                if tostring(getElementData(source, "specialKickReason") or "") == "Floodolás" or tostring(getElementData(source, "specialKickReason") or "") == "Floodolás miatt!" then
                    outputChatBox(low .. " "..name.." #ff3333kilépett #ffffffa közeledben ("..math.floor(dist).." yard) ["..reason.." - Floodolás miatt]", 255,255,255,true)
                end
            else
                outputChatBox(low .. " "..name.." #ff3333kilépett #ffffffa közeledben ("..math.floor(dist).." yard) ["..reason.."]", 255,255,255,true)
            end
        end
    end
)