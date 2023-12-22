sx, sy = guiGetScreenSize();
panelData = {
	["start"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["hide"] = false,
		["show"] = false,	
	},
	["stop"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["hide"] = false,
		["show"] = false,
	},
};
startMarker = nil;
startTime = 0;

tutorialTexts = {
	[1] = "",
};
tutorialState = 0;
tutorialTitle = "#FF9933Feladat - Törmelékszállító";

wasteAreaPoints = {
	{["center"] = {-2680.8061523438, 1307.3132324219, 55.784564971924}, ["gps"] = {-2682.3249511719, 1294.5238037109, 55.607391357422}, ["rad"] = 20},
	{["center"] = {-438.185546875, -645.41027832031, 14.374366760254}, ["gps"] = {-439.05953979492, -639.47662353516, 13.039823532104}, ["rad"] = 19},
	{["center"] = {-1073.5495605469, -1325.3443603516, 130.41041564941}, ["gps"] = {-1078.4821777344, -1342.3610839844, 129.42279052734}, ["rad"] = 16},
};
wastePoints = {};
selectedArea = nil;

addEventHandler("onClientResourceStart", resourceRoot, function() 
	for i, v in pairs(wasteAreaPoints) do
		local x, y, z = unpack(v["center"])
		local m = createColSphere(x, y, z, v["rad"])
		wastePoints[i] = m
	end
	
	selectedArea = getElementJobData(localPlayer, "selectedArea") or nil
end)

function nextTutorial()
	tutorialState = tutorialState+1
	exports.cr_tutorial:showPanel(tutorialTitle, tutorialTexts[tutorialState])
	setElementJobData(localPlayer, "tutorialState", tutorialState)
end

function isCursorHover(startX, startY, sizeX, sizeY)
    if(isCursorShowing()) then
        local cursorPosition = {getCursorPosition()} 
        cursorPosition.x, cursorPosition.y = cursorPosition[1] * sx, cursorPosition[2] * sy
        if(cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function showPanel(panel, state)
	if(state) then
		addEventHandler("onClientRender", root, renderPanels)
	else
		setTimer(function() 
			removeEventHandler("onClientRender", root, renderPanels)
		end, 500, 1)
	end
	if(panel == 1) then
		if(state) then
			panelData["start"]["startTime"] = getTickCount()
			panelData["start"]["endTime"] = getTickCount() + 500
			panelData["start"]["hide"] = false
			panelData["start"]["show"] = true
			
		else
			panelData["start"]["startTime"] = getTickCount()
			panelData["start"]["endTime"] = getTickCount() + 500
			panelData["start"]["hide"] = true
			setTimer(function() 
				panelData["start"]["show"] = false
			end, 500, 1)
		end
	elseif(panel == 2) then
		if(state) then
			panelData["stop"]["startTime"] = getTickCount()
			panelData["stop"]["endTime"] = getTickCount() + 500
			panelData["stop"]["hide"] = false
			panelData["stop"]["show"] = true
		else
			panelData["stop"]["startTime"] = getTickCount()
			panelData["stop"]["endTime"] = getTickCount() + 500
			panelData["stop"]["hide"] = true
			setTimer(function() 
				panelData["stop"]["show"] = false
			end, 500, 1)
		end
	end
end

_dxDrawRectangle = dxDrawRectangle;
dxDrawRectangle = function(left, top, width, height, color, postgui)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;

	_dxDrawRectangle(left - 2, top, 2, height, color, postgui);
	_dxDrawRectangle(left + width, top, 2, height, color, postgui);
	_dxDrawRectangle(left, top - 2, width, 2, color, postgui);
	_dxDrawRectangle(left, top + height, width, 2, color, postgui);

	_dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui);
	_dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui);
	_dxDrawRectangle(left + width, top + height, 1, 1, color, postgui);

	_dxDrawRectangle(left, top, width, height, color, postgui);
end

setTimer(function()
	local animBlock = localPlayer:getData("forceAnimation") or {"", ""}
	if(animBlock[1] == "WasteJob->Carry" or animBlock[2] == "WasteJob->Carry")then
		local block, anim = getPedAnimation(localPlayer)
		if(block ~= "CARRY" or anim ~= "crry_prtial") then
			triggerServerEvent("carry->anim", localPlayer, localPlayer)
		end
	end
end, 500, 0)

function getPlayerJobVehicle()
	return getElementJobData(localPlayer, "jobVehicle")
end

addEvent("endJob", true)
function endJob()
	showPanel(2, false)
	setTimer(function()
		triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
		destroyElementJobData(localPlayer)
		exports.cr_tutorial:hidePanel()
		tutorialState = 0
	end, 250, 1)
	outputChatBox(msgs["info"].."Befejezted a munkádat.", 255, 255, 255, true)
	removeEventHandler("onClientKey", root, stopPanelKeyHandler)
	exports.cr_tutorial:hidePanel()
	-- exports.cr_radar:destroyStayBlip("Kő feldolgozó")
	-- exports.cr_radar:destroyStayBlip("Zsák leadó")
	removeEventHandler("onClientRender", root, checkWaste)
	-- removeEventHandler("onClientKey", root, onHitWaste)
	unbindKey("e", "down", onHitWaste)
	wasteInFrontOfPlayer = false
	keyDatas["stop"]["start"] = 0
	keyDatas["stop"]["stop"] = 0
	panelKeys["stop"] = false
	keyDatas["start"]["start"] = 0
	keyDatas["start"]["stop"] = 0
	panelKeys["start"] = false
end
addEventHandler("endJob", root, endJob)

function initializeJobStarter()
	local x, y, z = unpack(markers["start"])
	startMarker = createMarker(x, y, z, "cylinder", 1.5, 255, 255, 255, 0)
	startMarker:setData("job >> data", {["job"] = 4, ["start"] = true, ["account"] = localPlayer:getData("acc >> id")})
end

function restoreJobData()
	addEventHandler("onClientRender", root, checkWaste)
	-- addEventHandler("onClientKey", root, onHitWaste)
	bindKey("e", "down", onHitWaste)
end

function destroyJobMarkers()
	for i, v in pairs(getElementsByType("marker"), resourceRoot) do
		if(getElementJobData(v, "job") == 4) then
			v:destroy()
		end
	end
end

local material = dxCreateTexture("images/shovel.png")

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

	for i=1,8 do
		point[i] = {}
	end

	point[1].x = x
	point[1].y = y-radius
	point[2].x = x+radius2
	point[2].y = y-radius2
	point[3].x = x+radius
	point[3].y = y
	point[4].x = x+radius2
	point[4].y = y+radius2
	point[5].x = x
	point[5].y = y+radius
	point[6].x = x-radius2
	point[6].y = y+radius2
	point[7].x = x-radius
	point[7].y = y
	point[8].x = x-radius2
	point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

function drawnOctagon()
	if(isElement(startMarker)) then
		local x,y,z = getElementPosition(startMarker)
		cx, cy, cz = x,y,z + 3
		----outputChatBox("asd")
		----outputChatBox(x)
		z = z-0.95
		local now = getTickCount()
		local multipler, alpha = interpolateBetween(-0.5, 0, 0, 0.1, 255, 0, now / 2500, "CosineCurve")
		dxDrawOctagon3D(x,y,z, 1, 3, tocolor(255, 153, 51,alpha))
		z = z + multipler
		dxDrawImage3D(x, y, z+2, 1, 1, material, tocolor(255, 153, 51,alpha))
	end
end

setTimer(function()
	if isElement(startMarker) and isElementStreamedIn(startMarker) then
		if getDistanceBetweenPoints3D(localPlayer.position, startMarker.position) <= 60 and localPlayer.dimension == startMarker.dimension and localPlayer.interior == startMarker.interior then
			if not state then
				state = true
				addEventHandler("onClientRender", root, drawnOctagon, true, "low-5")

			end
		else
			if state then
				state = false
				removeEventHandler("onClientRender", root, drawnOctagon)
			end    
		end
	else
		removeEventHandler("onClientRender", root, drawnOctagon)
	end
end, 300, 0)
-- #optimizált

--3dLine
function drawnLines()
    dxDrawLine3D(start[1], start[2], start[3], craneObj.position, tocolor(0,0,0,255), 10)
    ----outputChatBox("asd")
end


function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end