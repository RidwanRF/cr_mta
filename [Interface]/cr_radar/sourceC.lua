local screenW,screenH = guiGetScreenSize()
local mapTextureSize = 3072
local mapRatio = 6000 / mapTextureSize

toggleControl("radar", false)

local texture = nil

local minimap = 1



local hudVisible_ostate = getElementData( localPlayer, "hudVisible")
local keys_denied_ostate = getElementData( localPlayer, "keysDenied")

local textures = {}
_dxDrawImage = dxDrawImage
local function dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
    if type(img) == "string" then
        if not textures[img] then
            textures[img] = dxCreateTexture(img, "dxt5", true, "wrap")
        end
        img = textures[img]
    end
    return _dxDrawImage(x,y,w,h,img, r, rx, ry, color, postgui)
end

local Map_blips_timer = false
local Map_blips = {}
local Map_blips_radar = {}
local now_time = 0

local gps_anim_start = nil

local custom_blip_choosed_type = 0
local custom_blip_choosed = {"mark_1", "mark_2", "mark_3", "mark_4", "garage", "house", "vehicle"}

local hexCode = exports['cr_core']:getServerColor(nil, true)
local hovered_blip = nil
local gps_icon_x,gps_icon_y = 20,10

local minimapPosX = 0
local minimapPosY = 0
local minimapWidth = 320
local minimapHeight = 225
local minimapCenterX = minimapPosX + minimapWidth / 2
local minimapCenterY = minimapPosY + minimapHeight / 2
local minimapRenderSize = 400
local minimapRenderHalfSize = minimapRenderSize * 0.5
local minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
local playerMinimapZoom = 0.5
local minimapZoom = playerMinimapZoom
local minimapIsVisible = false

local bigmapPosX = 30
local bigmapPosY = 30
local bigmapWidth = screenW - 60
local bigmapHeight = screenH - 100
local bigmapCenterX = bigmapPosX + bigmapWidth / 2
local bigmapCenterY = bigmapPosY + bigmapHeight / 2
local bigmapZoom = 0.5
bigmapIsVisible = false

local lastCursorPos = false
local mapDifferencePos = false
local mapMovedPos = false
local lastDifferencePos = false
local mapIsMoving = false
local lastMapPosX, lastMapPosY = 0, 0
local mapPlayerPosX, mapPlayerPosY = 0, 0

local zoneLineHeight = 25
local screenSource = dxCreateScreenSource(screenW, screenH)

local gpsLineWidth = 60
local gpsLineIconSize = 30
local gpsLineIconHalfSize = gpsLineIconSize / 2

occupiedVehicle = nil

local way_say ={
	["left"] = {" után ","forduljon balra"},
	["right"] = {" után ","forduljon jobbra"},
	["forward"] = {"t haladjon tovább ","egyenesen"},
	["finish"] = {" után megérkezik ","az úticélhoz"},
	["around"] = {"Forduljon vissza ","ahol lehetséges!"},
}

local renderWidget = {}
renderWidget.__index = renderWidget

.minimap

createdBlips = {}
local mainBlips = {

}

local blipTooltips = {
	
}

local hoveredWaypointBlip = false

local farshowBlips = {}
local farshowBlipsData = {}

carCanGPSVal = 1
local gpsHello = false
local gpsLines = {}
local gpsRouteImage = false
local gpsRouteImageData = {}

local state3DBlip = true
local hover3DBlipCb = false

local playerCanSeePlayers = false

local getZoneNameEx = getZoneName
function getZoneName(x, y, z, citiesonly)
	local zoneName = getZoneNameEx(x, y, z, citiesonly)
	end
end

addCommandHandler("showplayers",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 3 then
			playerCanSeePlayers = not playerCanSeePlayers
		end
	end
)


function textureLoading()
	texture = dxCreateTexture( "assets/images/map.png")
	if not texture then
		setTimer(textureLoading,500,1)
	end
end


addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		textureLoading()
		if getPedOccupiedVehicle( localPlayer ) then
			occupiedVehicle = getPedOccupiedVehicle( localPlayer )
		end
		if texture then
			dxSetTextureEdge(texture, "border", tocolor(110, 158, 204,255))
		end

		if texture then
			dxSetTextureEdge(texture, "border", tocolor(110, 158, 204,255))
		end
		
		for k,v in ipairs(getElementsByType("blip")) do
			blipTooltips[v] = getElementData(v, "tooltipText")
		end
		

		if getElementData( localPlayer, "loggedIn") then
			minimapIsVisible = true
		else
			minimapIsVisible = false
		end

		if getElementData( localPlayer, "hudVisible") then
			minimapIsVisible = true
		else
			minimapIsVisible = false
		end
		
		
		if occupiedVehicle then
			carCanGPS()
		end		
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if source == occupiedVehicle then
			if dataName == "vehicle.GPS" then
				local dataValue = getElementData(source, dataName) or false
				
				if dataValue then
					carCanGPSVal = dataValue
				else
					if oldValue then
						carCanGPSVal = false
					end
				end
				
				if not carCanGPSVal then
					if getElementData(source, "gpsDestination") then
						endRoute()
					end
				end
			elseif dataName == "gpsDestination" then
				local dataValue = getElementData(source, dataName) or false
				
				if dataValue then
					
					gpsThread = coroutine.create(makeRoute)
					coroutine.resume(gpsThread, unpack(dataValue))
					waypointInterpolation = false
				else
					endRoute()
				end
			end
		elseif source == localPlayer and dataName == "hudVisible"then
			minimapIsVisible = getElementData( localPlayer, "hudVisible")
		elseif source == localPlayer and dataName == "loggedIn"then
			minimapIsVisible = true
		elseif source == localPlayer and dataName == "inDeath" then
			if occupiedVehicle and getElementData( localPlayer,"inDeath") then
				occupiedVehicle = nil
			end
		end
		
		if getElementType(source) == "blip" and dataName == "tooltipText" then
			blipTooltips[source] = getElementData(source, dataName)
		end
	end
)



function getHudCursorPos()
	if isCursorShowing() then
		return getCursorPosition()
	end
	return false
end



reMap = function(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end


local w_x, w_y, w_w, w_h = 0,0,0,0
local diagonal = 0


function renderWidget.minimap(x, y, w, h)
	local font = exports['cr_fonts']:getFont("Rubik", 10)
	
	enabled, w_x, w_y, w_w, w_h, sizable, turnable = exports["cr_interface"]:getDetails("radar")
	 x, y, minimapWidth, minimapHeight = w_x, w_y, w_w, w_h -zoneLineHeight
	 diagonal =  math.sqrt((w_w/2)^2+(w_h/2)^2)


	 local playerDimension = getElementDimension(localPlayer)

	 if playerDimension == 0 or playerDimension == 65000 or playerDimension == 33333 then
	

		 if getPedOccupiedVehicle(localPlayer) then occupiedVehicle = getPedOccupiedVehicle(localPlayer)
		 else occupiedVehicle = nil end

		if not minimapIsVisible or not enabled then return end 


	if (minimapWidth > 445 or minimapHeight > 400) and minimapRenderSize < 800 then
		minimapRenderSize = 800
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	if minimapWidth <= 445 and minimapHeight <= 400 and minimapRenderSize > 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end 
	if (minimapWidth > 325 or minimapHeight > 235) and minimapRenderSize < 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	if minimapWidth <= 325 and minimapHeight <= 235 and minimapRenderSize > 400 then
		minimapRenderSize = 400
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize,true)
	end
	
	if minimapPosX ~= x or minimapPosY ~= y then
		minimapPosX = x
		minimapPosY = y
	end
	
		minimapCenterX = minimapPosX + minimapWidth / 2
		minimapCenterY = minimapPosY + minimapHeight / 2
		local minimapRenderSizeOffset = minimapRenderSize * 0.75

		dxUpdateScreenSource(screenSource, true)

		if getKeyState("num_add") and playerMinimapZoom < 1.2 then
		if not occupiedVehicle then
			playerMinimapZoom = playerMinimapZoom + 0.01
			---calculateBlip() 
		end
		elseif getKeyState("num_sub") and playerMinimapZoom > 0.31 then
			if not occupiedVehicle then
				playerMinimapZoom = playerMinimapZoom - 0.01
				--calculateBlip() 
			end
		end

		minimapZoom = playerMinimapZoom

		if occupiedVehicle then
			local vehicleZoom = getVehicleSpeed(occupiedVehicle) / 1300
			if vehicleZoom >= 0.4 then
				vehicleZoom = 0.4
			end
			minimapZoom = minimapZoom - vehicleZoom
		end

		playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
		
		local cameraX, cameraY, _, faceTowardX, faceTowardY = getCameraMatrix()
		cameraRotation = math.deg(math.atan2(faceTowardY - cameraY, faceTowardX - cameraX)) + 360 + 90
	
		remapPlayerPosX, remapPlayerPosY = remapTheFirstWay(playerPosX), remapTheFirstWay(playerPosY)
		

		dxDrawImageSection(minimapPosX - minimapRenderSize / 2 + minimapWidth / 2, minimapPosY - minimapRenderSize / 2 + minimapHeight / 2, minimapRenderSize, minimapRenderSize, remapTheSecondWay(playerPosX) - minimapRenderSize / minimapZoom / 2, remapTheFirstWay(playerPosY) - minimapRenderSize / minimapZoom / 2, minimapRenderSize / minimapZoom, minimapRenderSize / minimapZoom, texture,cameraRotation - 180)  
		
		if gpsRouteImage then
			dxSetRenderTarget(minimapRender,true)
			dxSetBlendMode("add")
				dxDrawImage(minimapRenderSize / 2 + (remapTheFirstWay(playerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * minimapZoom - gpsRouteImageData[3] * minimapZoom / 2, minimapRenderSize / 2 - (remapTheFirstWay(playerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * minimapZoom + gpsRouteImageData[4] * minimapZoom / 2, gpsRouteImageData[3] * minimapZoom, -(gpsRouteImageData[4] * minimapZoom), gpsRouteImage, 180, 0, 0, tocolor(220, 163, 30))
			dxSetBlendMode("blend")
			dxSetRenderTarget()

			dxSetBlendMode("add")
			dxDrawImage(minimapPosX - minimapRenderSize / 2 + minimapWidth / 2, minimapPosY - minimapRenderSize / 2 + minimapHeight / 2, minimapRenderSize, minimapRenderSize, minimapRender, cameraRotation - 180)
			dxSetBlendMode("blend")
		end	
		
		dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
		dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
		dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
		dxDrawImageSection(minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
		
		local playerArrowSize = 60 / (4 - minimapZoom) + 3
		local playerArrowHalfSize = playerArrowSize / 2
		_, _, playerRotation = getElementRotation(localPlayer)


		dxDrawRectangle(minimapPosX, minimapPosY + minimapHeight, minimapWidth, zoneLineHeight, tocolor(0, 0, 0, 175))
		dxDrawRoundedRectangle(w_x-2,w_y-2,w_w+4,w_h+4,tocolor(0,0,0,255),tocolor( 0,0,0,255))
		local zoneName = getZoneName(playerPosX, playerPosY, playerPosZ)
		local text_width = dxGetTextWidth( "Location  "..zoneName, 1, font )
		if w_w > text_width + 5 then 
			--dxDrawText(hexCode.." Location: #ffffff"..zoneName, minimapPosX, minimapPosY + minimapHeight, minimapPosX + minimapWidth - 10, minimapPosY + minimapHeight+zoneLineHeight, tocolor(255, 255, 255, 255), 1, font, "left", "center",false,false,false,true)
			dxDrawText(hexCode.." Location: #ffffff"..zoneName, minimapPosX, minimapPosY + minimapHeight, minimapPosX + minimapWidth - 10, minimapPosY + minimapHeight+zoneLineHeight, tocolor(255, 255, 255, 255), 1, font, "left", "center",false,false,false,true)
		end

		if now_time <= getTickCount() then
			now_time = getTickCount()+30
			calculateBlip() 
		end

		renderBlip()
		dxDrawImage(minimapCenterX - playerArrowHalfSize, minimapCenterY - playerArrowHalfSize, playerArrowSize, playerArrowSize, "assets/images/arrow.png", math.abs(360 - playerRotation) + (cameraRotation - 180))
		
		
		---
		-- GPS irányzék
		---

		if w_x+gps_icon_x+gpsLineIconSize <= w_x+w_w then
			if gpsRoute or (not gpsRoute and waypointEndInterpolation) then
			
				if waypointEndInterpolation then
					local interpolationProgress = (getTickCount() - waypointEndInterpolation) / 1550
					local interpolatePosition,interpolateAlpha = interpolateBetween(0, 255, 0, 75, 0, 0, interpolationProgress, "Linear") 
					
					dxDrawImageSection( w_x, w_y, w_w,65,0,10, w_w, 65, "assets/images/gps/gpsline.png",0,0,0,tocolor(255,255,255,interpolateAlpha))
					
					dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/finish.png", 0, 0, 0, tocolor(255, 255, 255, interpolateAlpha))
					
					if interpolationProgress > 1 then
						waypointEndInterpolation = false
					end
				elseif nextWp then
					dxDrawImageSection( w_x, w_y, w_w,65, 0, 10, w_w, 65, "assets/images/gps/gpsline.png")
					if currentWaypoint ~= nextWp and not tonumber(reRouting) then
						if nextWp > 1 then
							waypointInterpolation = {getTickCount(), currentWaypoint}
						end

						currentWaypoint = nextWp
					end
					
					if tonumber(reRouting) then
						currentWaypoint = nextWp
					

						local reRouteProgress = (getTickCount() - reRouting) / 1250
						local refreshAngle_1, refreshAngle_2 = interpolateBetween(360, 0, 0, 0, 360, 0, reRouteProgress, "Linear")

						dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/circleout.png", refreshAngle_1,0,0,tocolor( 255,255,255,firstAlpha))
						dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/circlein.png", refreshAngle_2,0,0,tocolor( 255,255,255,firstAlpha))
					
						
						if reRouteProgress > 1 then
							reRouting = getTickCount()
						end
					elseif turnAround then
						currentWaypoint = nextWp
							if not gps_anim_start then gps_anim_start = getTickCount() end
						local startPolation, endPolation = (getTickCount() - gps_anim_start) / 600, 0
						local firstAlpha = interpolateBetween(0,0,0, 255,0,0,startPolation, "Linear")

						dxDrawImage(w_x+gps_icon_x , w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/around.png",0,0,0,tocolor( 255,255,255,firstAlpha))
						local msg_length = {dxGetTextWidth(way_say["around"][1]..""..way_say["around"][2], 1,font),dxGetTextWidth(way_say["around"][1].."\n"..way_say["around"][2], 1,font)}
						if  w_x+70+msg_length[1]+2 < w_x+w_w then
							dxDrawText(way_say["around"][1]..""..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255,255,255, firstAlpha), 1,1, font, "left", "center")
						elseif w_x+70+msg_length[2]+2 < w_x+w_w then
							dxDrawText(way_say["around"][1].."\n"..way_say["around"][2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255,255,255, firstAlpha), 1,1, font, "left", "center")
						end

						

					elseif not waypointInterpolation then
						dxDrawImage(w_x+gps_icon_x , w_y+gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[nextWp][2] .. ".png")
						if gps_anim_start then gps_anim_start = nil end
						
							local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
							local msg = {"",""}

							if root_distance >= 1000 then
								root_distance = math.round((root_distance/1000),1,"floor")
								msg[1] = root_distance.. " kilóméter"..way_say[gpsWaypoints[nextWp][2]][1]..""..way_say[gpsWaypoints[nextWp][2]][2]
								msg[2] = root_distance.. " kilóméter"..way_say[gpsWaypoints[nextWp][2]][1].."\n"..way_say[gpsWaypoints[nextWp][2]][2]
								msg[3] = root_distance.. " km"	
							else
								msg[1] = root_distance.. " méter"..way_say[gpsWaypoints[nextWp][2]][1]..""..way_say[gpsWaypoints[nextWp][2]][2]
								msg[2] = root_distance.. " méter"..way_say[gpsWaypoints[nextWp][2]][1].."\n"..way_say[gpsWaypoints[nextWp][2]][2]
								msg[3] = root_distance.. " m"
							end
							local msg_length = {dxGetTextWidth(msg[1], 1,font),dxGetTextWidth(msg[2], 1,font),dxGetTextWidth(msg[3], 1,font)}
							if w_x+70+msg_length[1]+2 < w_x+w_w then
								dxDrawText(msg[1],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
								dxDrawText(msg[2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
								dxDrawText(msg[3],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255), 1,1, font, "left", "center")
							end
						

					else
						local startPolation, endPolation = (getTickCount() - waypointInterpolation[1]) / 600, 0
						local firstAlpha,mover_x,mover_y = interpolateBetween(255,0,0, 0,gps_icon_x,gps_icon_y,startPolation, "Linear")
						
						dxDrawImage(w_x+gps_icon_x, w_y+ gps_icon_y-mover_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[waypointInterpolation[2]][2] .. ".png",0,0,0,tocolor(255,255,255,firstAlpha))
						
						local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
							local msg = {"",""}

							if root_distance >= 1000 then 
								root_distance = math.round((root_distance/1000),1,"floor")
								msg[1] = root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][1]..""..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
								msg[2] = root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][1].."\n"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
								msg[3] = root_distance.. " km"	
							else
								msg[1] = root_distance.. " méter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][1]..""..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
								msg[2] = root_distance.. " méter"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][1].."\n"..way_say[gpsWaypoints[waypointInterpolation[2]][2]][2]
								msg[3] = root_distance.. " m"
							end
							local msg_length = {dxGetTextWidth(msg[1], 1,font),dxGetTextWidth(msg[2], 1,font),dxGetTextWidth(msg[3], 1,font)}
							if w_x+70+msg_length[1]+2 < w_x+w_w then
								dxDrawText(msg[1],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
								dxDrawText(msg[2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
								dxDrawText(msg[3],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, firstAlpha), 1,1, font, "left", "center")
							end

						if gpsWaypoints[waypointInterpolation[2] + 1] then
												
							dxDrawImage(w_x+gps_icon_x-(gps_icon_x-mover_x), w_y+ gps_icon_y, gpsLineIconSize, gpsLineIconSize, "assets/images/gps/" .. gpsWaypoints[waypointInterpolation[2]+1][2] .. ".png",0,0,0,tocolor(255,255,255,255-firstAlpha))
							
							
							local root_distance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
							local msg = {"",""}

							if root_distance >= 1000 then 
								root_distance = math.round((root_distance/1000),1,"floor")
								msg[1] = root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1]..""..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
								msg[2] = root_distance.. " kilóméter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1].."\n"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
								msg[3] = root_distance.. " km"	
							else
								msg[1] = root_distance.. " méter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1]..""..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
								msg[2] = root_distance.. " méter"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][1].."\n"..way_say[gpsWaypoints[waypointInterpolation[2]+1][2]][2]
								msg[3] = root_distance.. " m"
							end
							local msg_length = {dxGetTextWidth(msg[1], 1,font),dxGetTextWidth(msg[2], 1,font),dxGetTextWidth(msg[3], 1,font)}
							if w_x+70+msg_length[1]+2 < w_x+w_w then
								dxDrawText(msg[1],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255-firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[2]+2 < w_x+w_w then
								dxDrawText(msg[2],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255-firstAlpha), 1,1, font, "left", "center")
							elseif  w_x+70+msg_length[3]+2 < w_x+w_w then
								dxDrawText(msg[3],  w_x+70,w_y,  w_x+70+100, w_y+55, tocolor(255, 255, 255, 255-firstAlpha), 1,1, font, "left", "center")
							end
						end
						
						if startPolation > 1 then
							endPolation = (getTickCount() - waypointInterpolation[1] - 750) / 500
						end
						
						if endPolation > 1 then
							waypointInterpolation = false
						end
					end
				end
			end
		end
	end
end



function renderTheBigmap()
	if not bigmapIsVisible then return end
	local font = exports['cr_fonts']:getFont("Rubik", 10)
	
	if hoveredWaypointBlip then
		hoveredWaypointBlip = false
	end
	
	 _, _, playerRotation = getElementRotation(localPlayer)
		
	
	if getElementDimension(localPlayer) == 0 then
		playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

		cursorX, cursorY = getHudCursorPos()
		if cursorX and cursorY then
			cursorX, cursorY = cursorX * screenW, cursorY * screenH

			
			if getKeyState("mouse1") and cursorX>= bigmapPosX and cursorX<= bigmapPosX+bigmapWidth and cursorY>= bigmapPosY and cursorY<= bigmapPosY+bigmapHeight then
				if not lastCursorPos then
					lastCursorPos = {cursorX, cursorY}
				end
				
				if not mapDifferencePos then
					mapDifferencePos = {0, 0}
				end
				
				if not lastDifferencePos then
					if not mapMovedPos then
						lastDifferencePos = {0, 0}
					else
						lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
					end
				end
				
				mapDifferencePos = {mapDifferencePos[1] + cursorX - lastCursorPos[1], mapDifferencePos[2] + cursorY - lastCursorPos[2]}
				
				if not mapMovedPos then
					if math.abs(mapDifferencePos[1]) >= 3 or math.abs(mapDifferencePos[2]) >= 3 then
						mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
						mapIsMoving = true
					end
				elseif mapDifferencePos[1] ~= 0 or mapDifferencePos[2] ~= 0 then
					mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
					mapIsMoving = true
				end
	
				lastCursorPos = {cursorX, cursorY}
			else
				if mapMovedPos then
					lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
				end
				
				lastCursorPos = false
				mapDifferencePos = false
			end
		end
		
		mapPlayerPosX, mapPlayerPosY = lastMapPosX, lastMapPosY
		
		if mapMovedPos then
			mapPlayerPosX = mapPlayerPosX + mapMovedPos[1]
			mapPlayerPosY = mapPlayerPosY + mapMovedPos[2]
		else
			mapPlayerPosX, mapPlayerPosY = playerPosX, playerPosY
			lastMapPosX, lastMapPosY = mapPlayerPosX, mapPlayerPosY
		end
		
		dxDrawImageSection(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2, remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2, bigmapWidth / bigmapZoom, bigmapHeight / bigmapZoom, texture)
		
		if gpsRouteImage then
			dxUpdateScreenSource(screenSource, true)
			dxSetBlendMode("add")
				dxDrawImage(bigmapCenterX + (remapTheFirstWay(mapPlayerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * bigmapZoom - gpsRouteImageData[3] * bigmapZoom / 2, bigmapCenterY - (remapTheFirstWay(mapPlayerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * bigmapZoom + gpsRouteImageData[4] * bigmapZoom / 2, gpsRouteImageData[3] * bigmapZoom, -(gpsRouteImageData[4] * bigmapZoom), gpsRouteImage, 180, 0, 0, tocolor(220, 163, 30))
			dxSetBlendMode("blend")
			dxDrawImageSection(0, 0, bigmapPosX, screenH, 0, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(screenW - bigmapPosX, 0, bigmapPosX, screenH, screenW - bigmapPosX, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
			dxDrawImageSection(bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
		end
					

		dxDrawRectangle(bigmapPosX, bigmapPosY + bigmapHeight, bigmapWidth, zoneLineHeight, tocolor(0, 0, 0, 175))
		dxDrawRoundedRectangle(bigmapPosX-2,bigmapPosY-2, bigmapWidth+4,bigmapHeight+zoneLineHeight+4,tocolor(0,0,0,255),tocolor( 0,0,0,255))



		if not Map_blips_timer then
			Map_blips_timer = setTimer( calculateBlipRadar, 50, 1) 
		end

		renderBlipRadar()

		
		cursorX, cursorY = getHudCursorPos()
		if cursorX and cursorY then cursorX, cursorY = cursorX * screenW, cursorY * screenH end

		if cursorX and cursorY and cursorX> bigmapPosX and cursorX< bigmapPosX+bigmapWidth and cursorY> bigmapPosY and cursorY< bigmapPosY+bigmapHeight then
			if getCursorAlpha() ~= 0 then setCursorAlpha(0) end
			if custom_blip_choosed_type == 0 then 	
				dxDrawImage( cursorX-128/2+4, cursorY-128/2-1, 128, 128, "assets/images/target.png")
			else
				local width,height = (12/ (4 - bigmapZoom) + 3) * 2.25,(12 / (4 - bigmapZoom) + 3) * 2.25
				dxDrawImage(cursorX-width/2, cursorY-height/2, width, height, "assets/images/blips/"..custom_blip_choosed[custom_blip_choosed_type]..".png")
			end
		elseif cursorX and cursorY then  
			if getCursorAlpha() == 0 then setCursorAlpha(255) end
		end


		


		if mapMovedPos then
			dxDrawText("Visszaállításához nyomd meg a 'SPACE' gombot.", bigmapPosX, bigmapPosY + bigmapHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight+zoneLineHeight, 0xFFFFFFFF, 1, font, "center", "center")
			if getKeyState("space") then
				mapMovedPos = false
				lastDifferencePos = false
				setCursorPosition(screenW/2,screenH/2)
			end
		end
	else
		return
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
	addEventHandler( "onClientRender", root, renderWidget.minimap )
end)

addEventHandler( "onClientResourceStart", resourceRoot, function()
	addEventHandler( "onClientRender", root, renderTheBigmap )
end)

addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		if key == "radar" then 
			setPlayerHudComponentVisible("radar", false)
            cancelEvent()
		end
		if key == "F11" and pressDown then
            custom_blip_choosed_type = 0
            bigmapIsVisible = not bigmapIsVisible
            minimapIsVisible = not bigmapIsVisible
            showChat( minimapIsVisible )
            --setElementData(localPlayer, "keysDenied", bigmapIsVisible)
            setElementData(localPlayer, "bigmapIsVisible", bigmapIsVisible, false)
            if bigmapIsVisible then
                hudVisible_ostate = getElementData( localPlayer, "hudVisible")
                keys_denied_ostate = getElementData( localPlayer, "keysDenied")
                setElementData( localPlayer,"hudVisible",false)
                setElementData( localPlayer, "keysDenied", true)
            else
                setElementData( localPlayer,"hudVisible",hudVisible_ostate)
                setElementData( localPlayer, "keysDenied",keys_denied_ostate)
            end

            if not getElementData(localPlayer,"hudVisible") and  minimapIsVisible then minimapIsVisible = false end 


            mapMovedPos = false
            lastDifferencePos = false
            bigmapZoom = 1
			cancelEvent()
		elseif key == "mouse_wheel_up" then
			if pressDown then
				if bigmapIsVisible and bigmapZoom + 0.1 <= 2.1 then
					bigmapZoom = bigmapZoom + 0.1
				end
			end
		elseif key == "mouse_wheel_down" then
			if pressDown then
				if bigmapIsVisible and bigmapZoom - 0.1 >= 0.1 then
					bigmapZoom = bigmapZoom - 0.1
				end
			end		
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, cursorX, cursorY)
			
	if getElementDimension( localPlayer ) ~= 0 then return end

		if state == "up" and mapIsMoving then
			mapIsMoving = false
			return
		end
		
		local gpsRouteProcess = false
		
		if button == "left" and state == "up" then
			if bigmapIsVisible and occupiedVehicle and carCanGPS() then
				if not getPedOccupiedVehicleSeat( localPlayer ) == 0 and  not getPedOccupiedVehicleSeat( localPlayer ) == 1 then return end
				if getElementData(occupiedVehicle, "gpsDestination") then
					setElementData(occupiedVehicle, "gpsDestination", false)
				else
					setElementData(occupiedVehicle, "gpsDestination", {
						reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000),
						reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					})
				end
				gpsRouteProcess = true
			end
		end
		
		if bigmapIsVisible then
			if button == "right" and state == "down" and custom_blip_choosed_type ~= 0 then
				if hovered_blip then
					deleteOwnBlip(hovered_blip)
				else
					local blipPosX = reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000)
					local blipPosY = reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					createOwnBlip(custom_blip_choosed[custom_blip_choosed_type],blipPosX,blipPosY)
					
				end
			elseif button == "middle" and state == "down" then
				if custom_blip_choosed_type < 7 then custom_blip_choosed_type = custom_blip_choosed_type +1 
				else custom_blip_choosed_type = 0 end
			end
		end
	end
)

function setGPSDestination(world_x,world_y)
	if occupiedVehicle and carCanGPS() then
		setElementData(occupiedVehicle, "gpsDestination", nil)
		setElementData(occupiedVehicle, "gpsDestination", {world_x,world_y})
	end
end


addEventHandler("onClientRestore", getRootElement(),
	function ()
		if gpsRoute then
			processGPSLines()
		end
	end
)


function calculateBlip()
	 Map_blips = {}
	for k,value in pairs(radarBlips) do
	 	local blip_x,blip_y,_ = getElementPosition(value[2])
        local blip_dis = getDistanceBetweenPoints2D(playerPosX, playerPosY, blip_x, blip_y)
        blip_dis = blip_dis/mapRatio*minimapZoom
        local dx_distance = diagonal*1.2
        if blip_dis < dx_distance or value[3]== 1 then 
            Map_blips[k] = value
            Map_blips[k]["blip_x"] = blip_x
            Map_blips[k]["blip_y"] = blip_y
            Map_blips[k]["blip_dis"] = blip_dis
            Map_blips[k]["blip_alpha"] = (1-((blip_dis-diagonal)/(diagonal*0.2)))*255

        else
        	Map_blips[k] = nil
        end
    end
	Map_blips_timer = nil
end




function renderBlip()
	for k , value in pairs(Map_blips) do
        local blip_x,blip_y, blip_dis = value["blip_x"], value["blip_y"], value["blip_dis"]
        local rotation = findRotation(blip_x, blip_y,playerPosX, playerPosY)-cameraRotation - 180
        blip_x, blip_y = getPointFromDistanceRotation(w_x+minimapWidth/2, w_y+minimapHeight/2, blip_dis, rotation)
       	blip_x,blip_y = math.max(w_x, math.min(w_x+minimapWidth,blip_x)),math.max(w_y, math.min(w_y+minimapHeight, blip_y))
       	local isPostGui = false
       	if blip_x == w_x or blip_x == w_x+minimapWidth or blip_y == w_y or blip_y == w_y+minimapHeight  then
       		isPostGui = true
       	end
       	


       	 local blip_alpha = 255	
       if blip_dis > diagonal and value[3] ~= 1 then
       	blip_alpha = math.max(0,math.min(255,value["blip_alpha"]))
       end

       local width,height = (value[5]/ (4 - minimapZoom) + 3) * 2.25,(value[6] / (4 - minimapZoom) + 3) * 2.25
       dxDrawImage(blip_x-(width/2),blip_y-(height/2),width,height,"assets/images/blips/"..value[4]..".png",0,0,0,tocolor(value[7],value[8],value[9],blip_alpha),isPostGui)
	end
end

function calculateBlipRadar()
	 Map_blips_radar = {}
	for k,value in pairs(radarBlips) do
	 	local blip_x,blip_y,_ = getElementPosition(value[2])
        Map_blips_radar[k] = value
        Map_blips_radar[k]["blip_x"] = blip_x
        Map_blips_radar[k]["blip_y"] = blip_y
    end
    Map_blips_radar["player"] = {"Játékos",localPlayer,0,"arrow",32,32,255,255,255} 
    local blip_x,blip_y,_ = getElementPosition(localPlayer)
    Map_blips_radar["player"]["blip_x"] = blip_x
    Map_blips_radar["player"]["blip_y"] = blip_y
	Map_blips_timer = nil
end



function renderBlipRadar()
	local blip_hoover = nil
	for k , value in pairs(Map_blips_radar) do
		width,height = (value[5]/ (4 - bigmapZoom) + 3) * 2.25,(value[6] / (4 - bigmapZoom) + 3) * 2.25
		local map_x,map_y =  Map_blips_radar[k]["blip_x"], Map_blips_radar[k]["blip_y"]
		map_x =  bigmapCenterX + (remapTheFirstWay(mapPlayerPosX) - remapTheFirstWay(map_x)) * bigmapZoom
		map_y =  bigmapCenterY - (remapTheFirstWay(mapPlayerPosY) - remapTheFirstWay(map_y)) * bigmapZoom
		if evisible == 0 then
			if map_x > bigmapPosX + bigmapWidth or map_y > bigmapCenterY + bigmapHeight then 
				return			
			elseif map_x < bigmapPosX or map_y < bigmapCenterY then
				return
			end 
		end
		local blip_x = math.max(bigmapPosX,math.min(bigmapPosX + bigmapWidth,map_x))
		local blip_y =  math.max(bigmapPosX,math.min(bigmapPosY + bigmapHeight,map_y))
		
		if value[4] == "arrow" then
			dxDrawImage(blip_x - width/2, blip_y - height/2, width, height, "assets/images/arrow.png", math.abs(360 - playerRotation))
		else
			dxDrawImage(blip_x - width/2, blip_y - height/2, width, height, "assets/images/blips/" .. value[4]..".png",0,0,0,tocolor(value[7],value[8],value[9])) 
		end

		local cursorX,cursorY = getCursorPosition()
		if cursorX and cursorY then
			cursorX,cursorY = cursorX*screenW,cursorY*screenH  
		else
			cursorX,cursorY = -10,-10
		end


		if cursorX > blip_x - width/2 and cursorX < blip_x - width/2+width and cursorY >  blip_y - height/2 and cursorY <  blip_y - height/2+height then
			local font = exports['cr_fonts']:getFont("Rubik", 10)
			local text_width = dxGetTextWidth(value[1],1,font)
			blip_hoover = value[1]
			dxDrawRectangle(blip_x - width/2-text_width/2-1,blip_y - height/2+height+1,text_width+3,18,tocolor(0, 0, 0,170))
			dxDrawRoundedRectangle(blip_x - width/2-text_width/2-2,blip_y - height/2+height,text_width+4,20,tocolor(0, 0, 0),tocolor(0, 0,0))
			dxDrawText( value[1], blip_x + width/2-text_width/2-2, blip_y - height/2+height+5,blip_x + width/2-text_width/2-2+text_width+4,blip_y - height/2+height+18, tocolor(255,255,255),1,font,"center","center")
		end	

	end
	if blip_hoover then hovered_blip = blip_hoover
	else hovered_blip = nil end
end



function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle) 
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist 
    return x+dx, y+dy
end

function remapTheFirstWay(coord)
	return (-coord + 3000) / mapRatio
end

function remapTheSecondWay(coord)
	return (coord + 3000) / mapRatio
end

function carCanGPS()
		carCanGPSVal = getElementData(occupiedVehicle, "vehicle.GPS") or 1
	return carCanGPSVal
end

function addGPSLine(x, y)
	table.insert(gpsLines, {remapTheFirstWay(x), remapTheFirstWay(y)})
end

function processGPSLines()
	local routeStartPosX, routeStartPosY = 99999, 99999
	local routeEndPosX, routeEndPosY = -99999, -99999
	
	for i = 1, #gpsLines do
		if gpsLines[i][1] < routeStartPosX then
			routeStartPosX = gpsLines[i][1]
		end
		
		if gpsLines[i][2] < routeStartPosY then
			routeStartPosY = gpsLines[i][2]
		end
		
		if gpsLines[i][1] > routeEndPosX then
			routeEndPosX = gpsLines[i][1]
		end
		
		if gpsLines[i][2] > routeEndPosY then
			routeEndPosY = gpsLines[i][2]
		end
	end
	
	local routeWidth = (routeEndPosX - routeStartPosX) + 16
	local routeHeight = (routeEndPosY - routeStartPosY) + 16
	
	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end
	
	gpsRouteImage = dxCreateRenderTarget(routeWidth, routeHeight, true)
	gpsRouteImageData = {routeStartPosX - 8, routeStartPosY - 8, routeWidth, routeHeight}
	
	dxSetRenderTarget(gpsRouteImage)
	dxSetBlendMode("modulate_add")
	
	--dxDrawImage(gpsLines[1][1] - routeStartPosX + 8 - 4, gpsLines[1][2] - routeStartPosY + 8 - 4, 8, 8, "gps/images/dot.png")
	
	for i = 2, #gpsLines do
		if gpsLines[i - 1] then
			local startX = gpsLines[i][1] - routeStartPosX + 8
			local startY = gpsLines[i][2] - routeStartPosY + 8
			local endX = gpsLines[i - 1][1] - routeStartPosX + 8
			local endY = gpsLines[i - 1][2] - routeStartPosY + 8
			
			--dxDrawImage(startX - 4, startY - 4, 8, 8, "gps/images/dot.png")

			dxDrawLine(startX, startY, endX, endY, tocolor(255, 255, 255), 9)
		end
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function clearGPSRoute()
	gpsLines = {}
	
	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end
	gpsRouteImage = false
end

addEventHandler( "onClientVehicleEnter", root, function(player) 
	if player == localPlayer then
		occupiedVehicle = source
	end	
end)


function getVehicleSpeed(vehicle)
	local velocityX, velocityY, velocityZ = getElementVelocity(vehicle)
	return ((velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ) ^ 0.5) * 187.5
end


function dxDrawRoundedRectangle(left, top, width, height, color, color2)
	if not postgui then
		postgui = false;
	end

	left, top = left + 2, top + 2;
	width, height = width - 4, height - 4;
    dxDrawRectangle(left - 2, top, 2, height, color2, postgui);
	dxDrawRectangle(left + width, top, 2, height, color2, postgui);
	dxDrawRectangle(left, top - 2, width, 2, color2, postgui);
	dxDrawRectangle(left, top + height, width, 2, color2, postgui);

	dxDrawRectangle(left - 1, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top - 1, 1, 1, color2, postgui);
	dxDrawRectangle(left - 1, top + height, 1, 1, color2, postgui);
	dxDrawRectangle(left + width, top + height, 1, 1, color2, postgui)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end