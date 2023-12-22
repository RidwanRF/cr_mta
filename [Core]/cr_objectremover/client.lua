local removableObjects = {
    --{modelID, radius, x,y,z},
    {4003, 100, 1481.1242675781,-1744.3240966797,40.015785217285},
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(removableObjects) do
            local id, radius, x,y,z = unpack(v)
            removeWorldModel(id, radius, x,y,z)
        end
    end
)