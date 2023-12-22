addEvent("killPedByTaser", true)
addEventHandler("killPedByTaser", root,
    function(sourceElement, attacker, weapon, bodypart)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                --outputCh
                killPed(sourceElement, attacker, weapon, bodypart)
            end
        end
    end
)

addEvent("hpDmgByTaser", true)
addEventHandler("hpDmgByTaser", root,
    function(sourceElement, loss)
        ----outputChatBox("asd")
        if client and client.type == "player" then
            ----outputChatBox("asd2")
            if sourceElement and sourceElement.type == "player" and sourceElement == client then
                --outputChatBox(loss)
                setElementHealth(sourceElement, loss)
            end
        end
    end
)

function taserDamageSync(attacker, weapon, bodypart)
    --outputChatBox(weapon)
	if weapon == 24 and attacker and isElement(attacker) and isElement(attacker:getData("taser>obj")) then
        if getDistanceBetweenPoints3D(source.position, attacker.position) <= 10 and not source.vehicle then
            if not source:getData("admin >> duty") then
                local hp = source.health
                --outputChatBox(hp)
                if bodypart == 9 then
                    --triggerServerEvent("killPedByTaser", source, source, attacker, weapon, bodypart)
                    --setElementHealth()
                    killPed(source, attacker, weapon, bodypart)
                elseif source:getData("char >> tazed") then -- -40hp
                    --outputChatBox(hp - 20)
                    if hp - 40 <= 0 then
                        --triggerServerEvent("killPedByTaser", source, source, attacker, weapon, bodypart)
                        killPed(source, attacker, weapon, bodypart)
                    else
                        setElementHealth(source, hp-40)
                        --triggerServerEvent("hpDmgByTaser", source, source, hp-40)
                    end
                else -- -10hp
                    if hp - 10 <= 0 then
                        --triggerServerEvent("killPedByTaser", source, source, attacker, weapon, bodypart)
                        killPed(source, attacker, weapon, bodypart)
                    else
                        --triggerServerEvent("hpDmgByTaser", source, source, hp-10)
                        setElementHealth(source, hp-10)
                    end
                end

                --outputChatBox(getDistanceBetweenPoints3D(source.position, attacker.position))
                if not source:getData("char >> tazed") and getDistanceBetweenPoints3D(source.position, attacker.position) >= 1 then
                    source:setData("char >> tazed", true)
                    source:setData("char >> tazedBy", {attacker, bodypart})
                    triggerClientEvent(source, "startTazedEffect", source)
                    triggerClientEvent(attacker, "startTazedEffectAttacker", attacker, source)
                    source:setData("forceAnimation", {"_Tazer", "_Tazer"})
                    setPedAnimation(source, "ped", "KO_shot_front", 500, false, true, true)
                end
            end
        end

        cancelEvent()
	end
end
addEventHandler("onPlayerDamage", root, taserDamageSync)