local sx, sy = guiGetScreenSize()

local plane_id = 577
local plane_pos = {
			-- x, y, z, rotx, roty, rotz
	[1] = {-1336.296875, -221.44393920898, 14.1484375, 0, 0, 315},
	[2] = {-1336.296875, -221.44393920898, 14.1484375, 0, 0, 315},
	[3] = {-1656.5775146484, -163.86363220215, 14.1484375, 0, 0, 315},
	[4] = {1649.3438720703, -2593.2211914063, 13.546875, 0, 0, 270},
	[5] = {1901.3, -2390.6, 13.5546875, 0, 0, 90},
}
local cam_pos = {
	[1] = {-1301.7354736328, -214.44549560547, 17.390600204468, -1302.6909179688, -214.49052429199, 17.09881401062},
	[2] = {-1283.9250488281, -197.25160217285, 27.339399337769, -1284.7592773438, -197.56370544434, 26.884841918945},
	[3] = {-1635.8018798828, -112.89260101318, 23.571699142456, -1634.9552001953, -112.385597229, 23.409914016724},
	[4] = {1676.7258300781, -2635.9384765625, 28.377700805664, 1677.3839111328, -2635.2727050781, 28.026012420654},
	[5] = {1892.8656005859, -2409.7883300781, 17.065799713135, 1892.3504638672, -2408.9731445313, 16.801027297974},
}

local ped_pos = {
	-- skinid , x, y, z, rot
	{61, -1314.7160644531, -212.28829956055, 14.1484375, 180, "COP_AMBIENT", "Coplook_think"},
	{76, -1313.3597412109, -212.09132385254, 14.1484375, 160, "COP_AMBIENT", "Coplook_loop"},
	{91, -1312.2592773438, -212.82049560547, 14.1484375, 100, "COP_AMBIENT", "Coplook_loop"},
	{16, -1329.1708984375, -231.74711608887, 14.1484375, 20, "LOWRIDER", "RAP_B_Loop"},
}

local baggages = {
	-- id, x, y, z, rot
	{606, -1319.2740478516, -224.43322753906, 14.1484375, 160},
	{606, -1320.8917236328, -227.95037841797, 14.1484375, 140},
	{606, -1323.9517822266, -230.29293823242, 14.1484375, 125},
	{583, -1327, -232.62112426758, 14.1484375, 130},
}
local ped = {}
local vehs_bag = {}

function startVideo(cmd) 
    fadeCamera(false)
    text = "Készen állsz egy új életre?"
    alpha = 0
    multipler = 1
    addEventHandler("onClientRender", root, drawnText, true, "low-5") 
    setTimer(function() 
        text = "San Fierro Reptér napjainkban..."
        alpha = 0
        multipler = 1
            setTimer(function() 
                removeEventHandler("onClientRender", root, drawnText)
                alpha = 0
                multipler = 1			
                first_position()			
            end, 1000*5, 1)			
    end, 1000*5, 1)
end

function drawnText()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    dxDrawText(text, sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,alpha), 1, fonts["default-regular-bigger"], "center", "center")
end

function first_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	setCameraMatrix(cam_pos[1][1], cam_pos[1][2], cam_pos[1][3], cam_pos[1][4], cam_pos[1][5], cam_pos[1][6]) 
	plane = createVehicle(plane_id, plane_pos[1][1], plane_pos[1][2], plane_pos[1][3], plane_pos[1][4], plane_pos[1][5], plane_pos[1][6])
    setElementDimension(plane, getElementDimension(localPlayer))
	stair = createObject(3663, -1319, -212, 15.2)
    setElementDimension(stair, getElementDimension(localPlayer))
	setElementRotation(stair, 0, 0, 320)
	
	for k,v in ipairs(ped_pos) do
		ped[k] = createPed(v[1], v[2], v[3], v[4])
		setElementRotation(ped[k], 0, 0, v[5])
		setPedAnimation(ped[k], v[6], v[7], -1, true, false, false)
		setElementFrozen(ped[k], true)
        setElementDimension(ped[k], getElementDimension(localPlayer))
	end	
	
	for k,v in ipairs(baggages) do
		vehs_bag[k] = createVehicle(v[1], v[2], v[3], v[4])
		setElementRotation(vehs_bag[k], 0, 0, v[5])
        setElementDimension(vehs_bag[k], getElementDimension(localPlayer))
	end	

	
	briefcase = createObject(1210, -1315, -212, 13.4)
    setElementDimension(briefcase, getElementDimension(localPlayer))
	setElementRotation(briefcase, 0, 0, 90)
	
	bar = createObject(2773, -1316.3431396484, -216.61393737793, 13.65)
    setElementDimension(bar, getElementDimension(localPlayer))
	setElementRotation(bar, 0, 0, 50)
	
	player_ped = createPed(details["skin"],-1305.0849609375, -224.77209472656, 14.1484375)
    setElementDimension(player_ped, getElementDimension(localPlayer))
	setElementRotation(player_ped, 0, 0, 50)
	setPedAnimation(player_ped, "ped", "walk_gang1")
	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Negyedórával később..."
        alpha = 0
        multipler = 1
        addEventHandler("onClientRender", root, drawnText, true, "low-5") 		
		setTimer(function() 
			destroyElement(briefcase)
			destroyElement(bar)
			destroyElement(player_ped)
			destroyElement(stair)		
			for k,v in ipairs(ped_pos) do
				destroyElement(ped[k])
			end			
			for k,v in ipairs(baggages) do
				destroyElement(vehs_bag[k])
			end
            removeEventHandler("onClientRender", root, drawnText)
            alpha = 0
            multipler = 1			
			second_position() 			
		end, 1000*5, 1)
	end, 1000*12, 1)
end

function second_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	setCameraMatrix(cam_pos[2][1], cam_pos[2][2], cam_pos[2][3], cam_pos[2][4], cam_pos[2][5], cam_pos[2][6])
	plane_driver = createPed(61, 0, 0, 0)
    setElementDimension(plane_driver, getElementDimension(localPlayer))
	warpPedIntoVehicle (plane_driver, plane)
	setTimer(function() setPedControlState(plane_driver, "accelerate", true) end, 1000*6, 1)
	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Felszállásra felkészülni..."
        alpha = 0
        multipler = 1
        addEventHandler("onClientRender", root, drawnText, true, "low-5")		
		setTimer(function() 
            removeEventHandler("onClientRender", root, drawnText)
            alpha = 0
            multipler = 1		
			third_position()			
		end, 1000*4, 1)
	end, 1000*7.5, 1)
end

function third_position()
	setTimer(function() fadeCamera(true) end, 1000*2, 1)
	-- setCameraTarget(localPlayer)
	setCameraMatrix(cam_pos[3][1], cam_pos[3][2], cam_pos[3][3], cam_pos[3][4], cam_pos[3][5], cam_pos[3][6]) 
	setElementFrozen(plane,true)
	setElementPosition(plane, plane_pos[3][1], plane_pos[3][2], plane_pos[3][3])
	setElementRotation(plane, plane_pos[3][4], plane_pos[3][5], plane_pos[3][6])
	setTimer(function() setElementFrozen(plane,false) end, 1000*2.5, 1)
	
	
	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Három órával később..."
        alpha = 0
        multipler = 1
        addEventHandler("onClientRender", root, drawnText, true, "low-5") 			
		setTimer(function() 
            removeEventHandler("onClientRender", root, drawnText)
            alpha = 0
            multipler = 1			
			fourth_position()
		end, 1000*4, 1)
	end, 1000*12, 1)	
end

function fourth_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	setCameraMatrix(cam_pos[4][1], cam_pos[4][2], cam_pos[4][3], cam_pos[4][4], cam_pos[4][5], cam_pos[4][6])
	
	setElementFrozen(plane,true)
	setElementPosition(plane, plane_pos[4][1], plane_pos[4][2], plane_pos[4][3])
	setElementRotation(plane, plane_pos[4][4], plane_pos[4][5], plane_pos[4][6])
	setElementFrozen(plane,false)
	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Sikeres landolás Los Santos városában."
        alpha = 0
        multipler = 1
        addEventHandler("onClientRender", root, drawnText, true, "low-5") 		
		setTimer(function() 
            removeEventHandler("onClientRender", root, drawnText)
            alpha = 0
            multipler = 1			
			fifth_position()
		end, 1000*5, 1)
	end, 1000*4, 1)	
end

function fifth_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	setCameraMatrix(cam_pos[5][1], cam_pos[5][2], cam_pos[5][3], cam_pos[5][4], cam_pos[5][5], cam_pos[5][6])
	setElementFrozen(plane,true)
	setElementPosition(plane, plane_pos[5][1], plane_pos[5][2], plane_pos[5][3])
	setElementRotation(plane, plane_pos[5][4], plane_pos[5][5], plane_pos[5][6])
	removePedFromVehicle(plane_driver)	
	destroyElement(plane_driver)

	bar = createObject(2773, 1880.3184814453, -2401.4951171875, 13.1)
    setElementDimension(bar, getElementDimension(localPlayer))
	bar2 = createObject(2773, 1883.880859375, -2401.4951171875, 13.1)
    setElementDimension(bar2, getElementDimension(localPlayer))
	setElementRotation(bar, 0, 0, 180)
	setElementRotation(bar2, 0, 0, 180)
	
	left_ped = createPed(76, 1884.2854003906, -2399.5693359375, 13.5546875)
    setElementDimension(left_ped, getElementDimension(localPlayer))
	setElementRotation(left_ped, 0, 0, 90)
	setPedAnimation(left_ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)	
	
	right_ped = createPed(91, 1880.0570068359, -2399.3674316406, 13.5546875)
    setElementDimension(right_ped, getElementDimension(localPlayer))
	setElementRotation(right_ped, 0, 0, 270)
	setPedAnimation(right_ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
	
	player_ped = createPed(details["skin"], 1882.1234130859, -2394.3156738281, 16.320375442505)
    setElementDimension(player_ped, getElementDimension(localPlayer))
	setElementRotation(player_ped, 0, 0, 180)
	setPedAnimation(player_ped, "ped", "walk_gang1")	

	
	-- Go to Next Situation
	setTimer(function()
		fadeCamera(false)
	    text = "Akkor kezdődjön egy új élet..."
        alpha = 0
        multipler = 1
		addEventHandler("onClientRender", root, drawnText, true, "low-5") 		
		setTimer(function()
			destroyElement(bar)
			destroyElement(bar2)
			destroyElement(left_ped)
			destroyElement(right_ped)
			destroyElement(player_ped)
			destroyElement(plane)
            removeEventHandler("onClientRender", root, drawnText)
            alpha = 0
            multipler = 1				
			sixth_position()
		end, 1000*5, 1)
	end, 1000*5, 1)		
end

function sixth_position()
	setTimer(function() fadeCamera(true) end, 1000, 1)
	--setCameraTarget(localPlayer)
	startTour()
end

