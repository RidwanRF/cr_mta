addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "forceAnimation" then
            local value = getElementData(source, dName)
            --iprint(value)
            if value[1] == "" and value[2] == "" then
                --setPedAnimation(source, "ped", "WOMAN_walknorm")
                setPedAnimation(source, "ped", "WOMAN_walknorm")
                setTimer(setPedAnimation, 50, 1, source, "", "")
            else
                setPedAnimation(source, value[1], value[2], -1, true, false, true)
            end
        end
    end
)