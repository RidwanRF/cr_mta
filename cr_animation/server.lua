function applyAnimation(element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
    if time == nil then 
        time = -1 
    end
    if loop == nil then
        loop = true 
    end
    if updatePosition == nil then 
        updatePosition = true
    end
    setPedAnimation(element, block, anim, time, loop, updatePosition, interruptable)
    if time > 100 then
        setTimer(setPedAnimation, 50, 2, element, block, anim, time, loop, updatePosition, interruptable)
    end
    if time > 50 then
        setTimer(removeAnimation, time, 1, element)
    end
    setElementData(element, "realAnimation", true)
end
addEvent("applyAnimation", true)
addEventHandler("applyAnimation", root, applyAnimation)

function removeAnimation(element)
    setPedAnimation(element)
    setElementData(element, "realAnimation", false)
end
addEvent("removeAnimation", true)
addEventHandler("removeAnimation", root, removeAnimation)