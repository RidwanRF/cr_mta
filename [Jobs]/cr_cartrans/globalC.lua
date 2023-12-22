sx, sy = guiGetScreenSize();
panelData = {
	["start"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["show"] = false,
		["hide"] = false,
	},
	["stop"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["show"] = false,
		["hide"] = false,
	},
	["forklift"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["show"] = false,
		["hide"] = false,
	},
	["forkliftDespawn"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["show"] = false,
		["hide"] = false,
	},
};
startMarker = nil;
timeChallenge = 0;
startTime = 0;

tutorialTexts = {
	[1] = "#FFFFFFÁllj be párhuzamosan a #FF9933daru#FFFFFF mellé, majd miután érzékelt, várj míg felpakolja a #FF9933roncsot#FFFFFF munkajárművedre a daru.",
	[2] = "#FFFFFFMost menj a #3232FFkék#FFFFFF bliphez #FF9933(térkép ikonhoz)#FFFFFF, majd add le a roncsot!",
	[3] = "#FFFFFFMost pedig már csak rajtad áll, hogy folytatni szeretnéd-e a munkát vagy sem, az esetben ha igen, akkor menj a szemétdomb mögé, és ott menj bele a #3232FFkék#FFFFFF markerbe és igényelj egy targoncát. Ellenkező esetben menj vissza a roncsszállító telepre és állítsd le munkádat, vagy szállíts le mégegy roncsot!",
	[4] = "#FFFFFFHajts a fémtömbökhöz, majd szimplán a targonca villáját told be a fém alá és várj pár másodpercet.",
	[5] = "#FFFFFFMost vidd a tömböt #FF9933munkajárművedhez (teherautó)#FFFFFF és emeld meg a targonca villáját a #FF9933'NUM_8'#FFFFFF billentyűvel és told a villát a munkakocsid platója fölé, pár másodpercen belül ez a vastömb fel lesz pakolva munkajárművedre!",
	[6] = "#FFFFFFSzállítsd le a fémtömböket mikor számodra elegendőt pakoltál fel a munkajárművedre a #00FF00zöld#FFFFFF bliphez (térkép ikonhoz), ott majd egy daru leszedi kocsidról a fémtömböket.",
};
tutorialState = 0;
tutorialTitle = "#FF9933Feladat - Roncsszállító";

function nextTutorial()
	tutorialState = tutorialState+1
	exports.cr_tutorial:showPanel(tutorialTitle, tutorialTexts[tutorialState])
	setElementJobData(localPlayer, "tutorialState", tutorialState)
end

removeWorldModel(3761, 1000, 2793.7990722656, -2448.3559570313, 13.283630371094)

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

function showPanel(panel, state)
	-- outputChatBox(panel.." "..tostring(state))
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
	elseif(panel == 3) then
		if(state) then
			panelData["forklift"]["startTime"] = getTickCount()
			panelData["forklift"]["endTime"] = getTickCount() + 500
			panelData["forklift"]["hide"] = false
			panelData["forklift"]["show"] = true
		else
			panelData["forklift"]["startTime"] = getTickCount()
			panelData["forklift"]["endTime"] = getTickCount() + 500
			panelData["forklift"]["hide"] = true
			setTimer(function() 
				panelData["forklift"]["show"] = false
			end, 500, 1)
		end
	elseif(panel == 4) then
		if(state) then
			panelData["forkliftDespawn"]["startTime"] = getTickCount()
			panelData["forkliftDespawn"]["endTime"] = getTickCount() + 500
			panelData["forkliftDespawn"]["hide"] = false
			panelData["forkliftDespawn"]["show"] = true
		else
			panelData["forkliftDespawn"]["startTime"] = getTickCount()
			panelData["forkliftDespawn"]["endTime"] = getTickCount() + 500
			panelData["forkliftDespawn"]["hide"] = true
			setTimer(function() 
				panelData["forkliftDespawn"]["show"] = false
			end, 500, 1)
		end
	end
end

function destroyJobMarkers()
	for i, v in pairs(getElementsByType("marker"), resourceRoot) do
		-- outputChatBox("asd")
		if(getElementJobData(v, "starter") == localPlayer:getData("acc >> id")) then
			v:destroy()
		end
	end 
end

function initializeJobStarter()
	startMarker = createMarker(2768.8474121094, -2385.4724121094, 12.6328125, "cylinder", 1.2, 255, 165, 0, 0)
	startMarker:setData("job >> data", {["job"] = 3, ["start"] = true, ["account"] = localPlayer:getData("acc >> id")})
	local blip = createBlip(2768.033203125, -2392.8449707031, 13.6328125)
	exports.cr_radar:createStayBlip("Roncs szállító telephely", blip, true, "sarga", 15, 15, 255, 255, 255)
end

function initializePutdownPlace()
	local pdMarker = createMarker(-1843.6262207031, -1678.4150390625, 22.261032104492, "checkpoint", 1, 0, 150, 0, 150)
	pdMarker:setData("job >> data", {["job"] = 3, ["starter"] = localPlayer:getData("acc >> id"), ["putDown"] = true})
end

addEventHandler("onClientResourceStart", resourceRoot, function() 
	if(getElementJobData(localPlayer, "tutorial")) then
		tutorialState = tonumber(getElementJobData(localPlayer, "tutorialState"))
		tutorialState = tutorialState-1
		nextTutorial()
	end
end)

local material = dxCreateTexture("images/truck.png")

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
		z = z + 0.03
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