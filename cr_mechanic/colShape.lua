local positions = {
    --{Vector(x,y,z),Vector(dim,int, 50)},
    {Vector3(1923.9403076172, -1791.5081787109, 13), Vector3(0,0,50)},
}

local elementCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(positions) do
            local pos, pos2 = unpack(v)
            local mark = createColSphere(pos, pos.z)
            mark.interior = pos2.y
            mark.dimension = pos2.x
            elementCache[mark] = true
        end
    end
)

function inAnyColShape()
    for k,v in pairs(elementCache) do
        if isElementWithinColShape(localPlayer, k) then
            return true
        end
    end
    
    return false
end