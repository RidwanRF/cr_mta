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
	["changingRoom"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["hide"] = false,
		["show"] = false,
	},
	["depositPanel"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["hide"] = false,
		["show"] = false,
	},
	["decisionPanel"] = {
		["startTime"] = 0,
		["endTime"] = 0,
		["hide"] = false,
		["show"] = false,
	}
};
startMarker = nil;
startTime = 0;

putdowns = {
	{-1756.6903076172, -169.5675201416, 3.5},
	{-1754.3308105469, -171.8871307373, 3.5},
	{-1756.3474121094, -171.5724029541, 3.5},
	{-1737.3240966797, -154.37734985352, 3.5},
	{-1739.6566162109, -152.10806274414, 3.5},
	{-1720.3922119141, -137.05490112305, 3.5},
	{-1722.6512451172, -134.62351989746, 3.5},
	{-1705.6455078125, -117.46018981934, 3.5},
	{-1703.3306884766, -119.69247436523, 3.5},
};

tutorialTexts = {
	[1] = "#FFFFFFHajts a munkajárműveddel a bányába, majd a kiválasztott ércnél #FF9933(A kő, mely felett egy ikon található.) #FFFFFFa csákányoddal kezd meg a bányászatot!#FF9933 (Üsd a követ!)",
	[2] = "#FFFFFFMikor egy ércet elkezdesz kibányászni, egy folyamat jelző megjelenik, melynek a #FF9933100%#FFFFFF-ára érve #FF9933kibányásztad#FFFFFF az ércet. A kézben lévő ércet a kocsi hátuljánál tudod az #FF9933'E'#FFFFFF billentyű lenyomásával felpakolni.",
	[3] = "#FFFFFFMunkajárműveden maximum egyszerre #FF99336db#FFFFFF érc lehet. Az érceket a #3232FFkék #FFFFFFblipnél #FF9933(Térkép ikon)#FFFFFF tudod feldolgozni, tehát  miután számodra megfelelő mennyiségű ércet pakoltál fel a kocsira szállítsd a feldolgozóhoz!",
	[4] = "#FFFFFFÉrceket levenni a platóról, az #FF9933'E'#FFFFFF billentyű lenyomásával tudsz a jármű hátuljánál, azonban csak a kőfejtő területén tudod ezt megtenni.",
	[5] = "#FFFFFFMost vidd az ércet a feldolgozóhoz, #FFFFFF(sárga marker)#FFFFFF, majd használd az #FFFFFF'E'#FFFFFF billentyűt!",
	[6] = "#FFFFFFMitán végeztél a minigame-el és rákattintottál az #FF9933Kész#FFFFFF gombra, várd meg míg, végigér a futószalagon a zsák, majd a futószalag alatt megtalálod. A zsákot, az #FF9933'E'#FFFFFF billentyű lenyomásával tudod felvenni a zsák előtt, #FF9933a a kocsin már nincs több érc#FFFFFF!",
	[7] = "#FFFFFFA felvett zsákot a kocsi hátuljánál az #FF9933'E'#FFFFFF billentyű lenyomásával tudod felpakolni. Ezek után pedig szállítsd a #32FF32zöld#FFFFFF térkép ikonhoz a felpakolt zsákokat, fontos, hogy a fehér markeren hajts keresztül, és menj rá az Igen gombra mikor megkérdezi, hogy valóban le szeretnél-e pakolni!",
	[8] = "#FFFFFFEzek után az autó hátuljánál az #FF9933'E'#FFFFFF billentyű lenyomásával vegyél le egy zsákot a kocsiról, majd vidd a kis sárga markerhez, és ott tartsd lenyomva az #FF9933'E'#FFFFFF billentyűt!",
};
tutorialState = 0;
tutorialTitle = "#FF9933Feladat - Bányász";

function nextTutorial()
	tutorialState = tutorialState+1
	exports.cr_tutorial:showPanel(tutorialTitle, tutorialTexts[tutorialState])
	setElementJobData(localPlayer, "tutorialState", tutorialState)
end

addEventHandler("onClientVehicleStartEnter", root, function(player, seat, door)
	if (player == localPlayer)then
		if(getElementJobData(localPlayer, "started")) then
			if(getElementJobData(localPlayer, "rockInHand") or getElementJobData(localPlayer, "bagInHand")) then
				cancelEvent(true)
				outputChatBox(msgs["error"].."Előbb használd a /eldob parancsot, vagy pakold fel a kezedbenlévőt a platóra.", 255, 255, 255, true)
			end
		end
	end
end)

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
	elseif(panel == 4) then
		if(state) then
			panelData["depositPanel"]["startTime"] = getTickCount()
			panelData["depositPanel"]["endTime"] = getTickCount() + 500
			panelData["depositPanel"]["hide"] = false
			panelData["depositPanel"]["show"] = true
		else
			panelData["depositPanel"]["startTime"] = getTickCount()
			panelData["depositPanel"]["endTime"] = getTickCount() + 500
			panelData["depositPanel"]["hide"] = true
			setTimer(function() 
				panelData["depositPanel"]["show"] = false
			end, 500, 1)
		end
	elseif(panel == 5) then
		if(state) then
			panelData["decisionPanel"]["startTime"] = getTickCount()
			panelData["decisionPanel"]["endTime"] = getTickCount() + 500
			panelData["decisionPanel"]["hide"] = false
			panelData["decisionPanel"]["show"] = true
		else
			panelData["decisionPanel"]["startTime"] = getTickCount()
			panelData["decisionPanel"]["endTime"] = getTickCount() + 500
			panelData["decisionPanel"]["hide"] = true
			setTimer(function() 
				panelData["decisionPanel"]["show"] = false
			end, 500, 1)
		end
	end
end

function deleteJobMarkers()
	for i, v in pairs(getElementsByType("marker"), resourceRoot) do
		if(getElementJobData(v, "starter") == localPlayer:getData("acc >> id")) then
			v:destroy()
		end
	end
end

function getNearestVehicle(player, distance)
	local tempTable = {}
	local lastMinDis = distance-0.0001
	local nearestVeh = false
	local px, py, pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)
	for _,v in pairs(getElementsByType("vehicle")) do
		local vint,vdim = getElementInterior(v), getElementDimension(v)
		if(vint == pint and vdim == pdim) then
			local vx, vy, vz = getElementPosition(v)
			local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
			if(dis < distance)then
				if(dis < lastMinDis) then 
					lastMinDis = dis
					nearestVeh = v
				end
			end
		end
	end
	return nearestVeh
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
	if(animBlock[1] == "MinerJob->Carry" or animBlock[2] == "MinerJob->Carry")then
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
	triggerServerEvent("destroyVehicleRocks", localPlayer, localPlayer)
	setTimer(function()
		triggerServerEvent("deleteJobVehicle", getRootElement(), localPlayer, 422)
		destroyElementJobData(localPlayer)
		exports.cr_tutorial:hidePanel()
		tutorialState = 0
	end, 250, 1)
	destroyBagsInGround()
	deleteJobMarkers()
	outputChatBox(msgs["info"].."Befejezted a munkádat.", 255, 255, 255, true)
	removeEventHandler("onClientKey", root, stopPanelKeyHandler)
	exports.cr_radar:destroyStayBlip("Kő feldolgozó")
	exports.cr_radar:destroyStayBlip("Zsák leadó")
	keyDatas["start"]["start"] = 0
	keyDatas["start"]["stop"] = 0
	panelKeys["start"] = false
end
addEventHandler("endJob", root, endJob)

local material = dxCreateTexture("images/suitcase.png")

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
		z = z
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