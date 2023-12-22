_xmlNodeGetAttribute = xmlNodeGetAttribute
function xmlNodeGetAttribute(...)
    local val = _xmlNodeGetAttribute(...)
    
    if tonumber(val) then
        return tonumber(val)
    else
        return val
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        local xml = xmlLoadFile("map.xml")
        local nodes = xmlNodeGetChildren(xml)
        for k,v in ipairs(nodes) do
            local name = string.lower(xmlNodeGetName(v))
            
            if name == "object" then
                local x = xmlNodeGetAttribute(v, "posX")
                local y = xmlNodeGetAttribute(v, "posY")
                local z = xmlNodeGetAttribute(v, "posZ")
                local rx = xmlNodeGetAttribute(v, "rotX")
                local ry = xmlNodeGetAttribute(v, "rotY")
                local rz = xmlNodeGetAttribute(v, "rotZ")
                local alpha = xmlNodeGetAttribute(v, "alpha")
                local model = xmlNodeGetAttribute(v, "model")
                local scale = xmlNodeGetAttribute(v, "scale")
                local interior = xmlNodeGetAttribute(v, "interior")
                local dimension = xmlNodeGetAttribute(v, "dimension")
                local collisions = xmlNodeGetAttribute(v, "collisions")
                local breakable = xmlNodeGetAttribute(v, "breakable")
                local doublesided = xmlNodeGetAttribute(v, "doublesided")
                
                local obj = createObject(model, x,y,z,rx,ry,rz)
                setElementCollisionsEnabled(obj, collisions == "true")
                --setObjectBreakable(obj, breakable == "true")
                setElementDoubleSided(obj, doublesided == "true")
                setElementInterior(obj, interior)
                setElementDimension(obj, dimension)
                setObjectScale(obj, scale)
                setElementAlpha(obj, alpha)
            elseif name == "removeworldobject" then
                local x = xmlNodeGetAttribute(v, "posX")
                local y = xmlNodeGetAttribute(v, "posY")
                local z = xmlNodeGetAttribute(v, "posZ")
                local rx = xmlNodeGetAttribute(v, "rotX")
                local ry = xmlNodeGetAttribute(v, "rotY")
                local rz = xmlNodeGetAttribute(v, "rotZ")
                local interior = xmlNodeGetAttribute(v, "interior")
                local dimension = xmlNodeGetAttribute(v, "dimension")
                local radius = xmlNodeGetAttribute(v, "radius")
                local model = xmlNodeGetAttribute(v, "model")
                local lodModel = xmlNodeGetAttribute(v, "lodModel")
                
                if lodModel ~= 0 then
                    removeWorldModel(lodModel, radius, x,y,z, interior)
                end
                
                if model ~= 0 then
                    removeWorldModel(model, radius, x,y,z, interior)
                end
            end
        end
    end
)
