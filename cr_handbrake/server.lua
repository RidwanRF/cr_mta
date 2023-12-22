addEventHandler("onElementDataChange", root,
    function(dName)
        if getElementType(source) == "vehicle" then
            if dName == "veh >> handbrake" then
                local value = getElementData(source, dName)
                if value then
                    setElementFrozen(source, true)
                else
                    setElementFrozen(source, false)
                end
            end
        end
    end
)