local loadedMarkers = {};

addEventHandler("onClientRender", root, function()
    if not localPlayer:getData("loggedIn") then return end
	local font = exports.cr_fonts:getFont("Roboto", 13);

    selected = nil
    val = nil    
        
	for key, value in pairs(loadedMarkers) do
		if isElement(key) then 
		    if getDistanceBetweenPoints3D(localPlayer.position, key.position) <= 32 then 
		        local distance = getDistanceBetweenPoints3D(localPlayer.position, key.position);
		        local sx, sy = getScreenFromWorldPosition(key.position, 30);
		        
		        if sx and sy then
			        local scale = 1 - (distance / 30);

			        if getElementData(localPlayer, "admin >> duty") then
			        	dxDrawText("* " .. value.msg .. "\n((" .. value.player .. "))\n((" .. value.created .. ")) ((ID: " .. value.id .. "))", sx + 1, sy + 1, sx + 1, sy + 1, tocolor(0, 0, 0), scale, font, "center", "center");
			        	dxDrawText("* " .. value.msg .. "\n((" .. value.player .. "))\n((" .. value.created .. ")) ((ID: " .. value.id .. "))", sx, sy, sx, sy, tocolor(255, 51, 102), scale, font, "center", "center");
			        else
			        	dxDrawText("* " .. value.msg .. "\n((" .. value.player .. "))\n((" .. value.created .. "))", sx + 1, sy + 1, sx + 1, sy + 1, tocolor(0, 0, 0), scale, font, "center", "center");
			        	dxDrawText("* " .. value.msg .. "\n((" .. value.player .. "))\n((" .. value.created .. "))", sx, sy, sx, sy, tocolor(255, 51, 102), scale, font, "center", "center");
			        end 
                        
                    if value["owner"] == tonumber(localPlayer:getData("acc >> id")) and distance <= 3 or getElementData(localPlayer, "admin >> duty") and distance <= 3 then
                        --outputChatBox(tostring(key:getData("editing")))
                        if not key:getData("editing") then
                            if isInSlot(sx - (5 * scale) - (25 * scale), sy + (10 * scale) + (25*scale), 25 * scale, 25 * scale) then
                                dxDrawImage(sx - (5 * scale) - (25 * scale), sy + (10 * scale) + (25*scale), 25 * scale, 25 * scale, "files/bin.png", 0, 0, 0, tocolor(255, 51, 51, 255))
                                selected = 1
                                val = key
                            else
                                dxDrawImage(sx - (5 * scale) - (25 * scale), sy + (10 * scale) + (25*scale), 25 * scale, 25 * scale, "files/bin.png", 0, 0, 0, tocolor(255, 51, 51, 100))
                            end

                            if isInSlot(sx + (5 * scale), sy + (10 * scale) + (8 * scale) + (20*scale), 20 * scale, 20 * scale) then
                                dxDrawImage(sx + (5 * scale), sy + (10 * scale) + (8 * scale) + (20*scale), 20 * scale, 20 * scale, "files/scale.png", 45, 0, 0, tocolor(51, 255, 51, 255))        
                                selected = 2
                                val = key    
                            else        
                                dxDrawImage(sx + (5 * scale), sy + (10 * scale) + (8 * scale) + (20*scale), 20 * scale, 20 * scale, "files/scale.png", 45, 0, 0, tocolor(51, 255, 51, 100))    
                            end        
                        end
                    end
		    	end
		    end 
		else
			loadedMarkers[key] = nil;
		end
	end
end);

addEventHandler("onClientClick", root,
    function(b,s)
        if b == "left" and s == "down" then
            if selected then
                if selected == 1 then
                    local v = loadedMarkers[val]["id"]
                    triggerServerEvent("delplacedo", localPlayer, v)
                elseif selected == 2 then
                    if not val:getData("editing") then
                        val:setData("editing", true)
                        obj = createObject(2081, val.position)
                        obj.alpha = 0
                        obj.collisions = false
                        obj:setData("marker->Datas", val:getData("marker->Datas"))
                        obj:setData("val", val)
                        attachElements(val, obj)
                        exports["cr_elementeditor"]:toggleEditor(obj, "onSavePlacedoPositionEditor", "onSavePlacedoPositionEditor")
                    end
                end    
                selected, val = nil, nil
            end
        end
    end
)

addEvent("onSavePlacedoPositionEditor",true)
addEventHandler("onSavePlacedoPositionEditor",root,
    function(element, x, y, z, rx, ry, rz, scale, array)
--        triggerServerEvent("onHifiSetPosition",element,element, x, y, z, rx, ry, rz)
        --outputChatBox("awsd")
        --tputChatBox(exports['cr_core']:getServerSyntax("Hifi", "success") .. "sikeresen megváltoztattad egy hifi pozicióját!")
        local id = element:getData("marker->Datas")["id"]
        local val = element:getData("val")
        --outputChatBox(id)
        detachElements(val, obj)
        obj:destroy()
        triggerServerEvent("updatePlacedoPos", localPlayer, id, {x,y,z})
        --triggerServerEvent("updateHifiRotation", localPlayer, element, {rx,ry,rz})
        --triggerServerEvent("hifiChangeState", localPlayer, element, 255)
        --is_lines_rendered = true
    end
)

addEventHandler("onClientResourceStart", resourceRoot, function()
	for key, value in pairs(getElementsByType("marker")) do
		if getElementData(value, "marker->Datas") then
			loadedMarkers[value] = getElementData(value, "marker->Datas");
		end
	end
end);

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "marker" and getElementData(source, "marker->Datas") then
		loadedMarkers[source] = getElementData(source, "marker->Datas");
	end
end);

addEventHandler("onClientElementStreamOut", root, function()
	if loadedMarkers[source] then
		loadedMarkers[source] = nil;
	end
end);

addEventHandler("onClientElementDestroy", root, function()
	if loadedMarkers[source] then
		loadedMarkers[source] = nil;
	end
end)

local screenSize = {guiGetScreenSize()}
local cursorState = isCursorShowing()
local cursorX, cursorY = screenSize[1]/2, screenSize[2]/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * screenSize[1], cursorY * screenSize[2]
end

addEventHandler("onClientCursorMove", root, 
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end