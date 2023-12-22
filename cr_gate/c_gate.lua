-----   StaY Mta -----
-----  	  Gate   -----
-----   Made by  -----
-----    Awang   -----
-----   Version  -----
-----     0.1    -----
--- Here I'm again ---
----------------------

now_gate = nil

local auto_gates = {}

DX = {}
DX.__index = DX
DX.x_root,DX.y_root = guiGetScreenSize()
DX.x,DX.y = DX.x_root / 1920, DX.y_root/1080

Animation = {}
Animation.__index = Animation
function Animation:call(mstart,duration,sn1, sn2, sn3, fn1, fn2, fn3,animtype)
	local now = getTickCount()
	local elapsedTime = now - mstart
	local progress = elapsedTime / duration
	if progress ~= 0 or progress ~= 1 then
		local num1, num2, num3 = interpolateBetween ( sn1, sn2, sn3, fn1, fn2, fn3, progress, ""..tostring(animtype).."")
		return num1, num2,num3
	elseif progress == 1 then
		return fn1, fn2, fn3
	elseif progress == 0 then
		return  sn1, sn2, sn3
	end	
end

local Panel = {}
Panel.__index = Panel
Panel.animation = {}
Panel.x,Panel.y,Panel.w,Panel.h = 0,0,100,100



function Animation:dxDrawRoundedRectangle(left, top, width, height, color, postgui)
    if not postgui then
        postgui = false
    end
    local left, top = left + 2, top + 2
    local width, height = width - 4, height - 4
	
    dxDrawRectangle(left - 2, top, 2, height, color, postgui)
    dxDrawRectangle(left + width, top, 2, height, color, postgui)
    dxDrawRectangle(left, top - 2, width, 2, color, postgui)
    dxDrawRectangle(left, top + height, width, 2, color, postgui)

    dxDrawRectangle(left - 1, top - 1, 1, 1, color, postgui)
    dxDrawRectangle(left + width, top - 1, 1, 1, color, postgui)
    dxDrawRectangle(left - 1, top + height, 1, 1, color, postgui)
    dxDrawRectangle(left + width, top + height, 1, 1, color, postgui)
    dxDrawRectangle(left, top, width, height, color, postgui)
end

function gateServerMove(gate)
	triggerServerEvent("onGateMove",root,gate)
end

function panelRender()
	local mover =  Animation:call(Panel.animation[1],Panel.animation[2],Panel.animation[3], 0, 0, Panel.animation[4], 0, 0,"OutBounce")
	--local boxY = interpolateBetween(-screenH - 175, 0, 0, screenH - 175, 0, 0, progress, "OutBounce")
	Animation:dxDrawRoundedRectangle(500, 500, 500, 500, tocolor(0,0,255), false)
end

function panelClick()

end

function panelHoover()

end

function panelKey(button,state)
	if button == "e" and state then
		gateServerMove(now_gate)
	end
end

function panelHandler(state)
	if state then
		Panel.animation = {getTickCount(),2500,Panel.w*2,0}
		addEventHandler("onClientRender",root,panelRender)
		setTimer(function()
			addEventHandler("onClientClick",root,panelClick)
			addEventHandler("onClientCursorMove",root,panelHoover)
			addEventHandler("onClientKey",root,panelKey)			
		end,Panel.animation[2],1)		
	else
		Panel.animation = {getTickCount(),1000,0,Panel.w*2}
		removeEventHandler("onClientClick",root,panelClick)
		removeEventHandler("onClientCursorMove",root,panelHoover)
		removeEventHandler("onClientKey",root,panelKey)		
		setTimer(function()
			removeEventHandler("onClientRender",root,panelRender)
		end,Panel.animation[2],1)	
	end 
end

function autoGateAll()
	auto_gates[now_gate:getData("id")] = 1
end

function autoGateCar()
	auto_gates[now_gate:getData("id")] = 2
end

function autoGateFoot()
	auto_gates[now_gate:getData("id")] = 3
end

function autoGateRemove()
	auto_gates[now_gate:getData("id")] = nil
end


addEventHandler("onClientMarkerHit",root,function(player,dim)
	if player == localPlayer and dim and source:getData("is_gate_marker") then
		now_gate = source:getData("root_gate")
		--[[if auto_gates[source:getData("id")]["type"] == 1 then
			gateServerMove(now_gate)
		elseif auto_gates[source:getData("id")]["type"] == 2 and localPlayer.vehicle then
			gateServerMove(now_gate)
		elseif auto_gates[source:getData("id")]["type"] == 3 and not localPlayer.vehicle then
			gateServerMove(now_gate)
		else]]--
			panelHandler(true)
		--end
		addCommandHandler("autogate",autoGateAll)
		addCommandHandler("autogatecar",autoGateCar)
		addCommandHandler("autogatefoot",autoGateFoot)
		addCommandHandler("autogateremove",autoGateRemove)
		
	end
end)



addEventHandler("onClientMarkerLeave",root,function(player,dim)
	if player == localPlayer and dim  and source:getData("is_gate_marker") then
		--[[if auto_gates[source:getData("id")]["type"] == 1 then
			gateServerMove(now_gate)
		elseif auto_gates[source:getData("id")]["type"] == 2 and localPlayer.vehicle then
			gateServerMove(now_gate)
		elseif auto_gates[source:getData("id")]["type"] == 3 and not localPlayer.vehicle then
			gateServerMove(now_gate)
		else]]--
			panelHandler(false)
		--end
		now_gate = nil
		removeCommandHandler("autogate",autoGateAll)
		removeCommandHandler("autogatecar",autoGateCar)
		removeCommandHandler("autogatefoot",autoGateFoot)
		removeCommandHandler("autogateremove",autoGateRemove)
	end
end)


addEventHandler("onClientResourceStart",resourceRoot,function()
	jsonCheck(auto_gates)
	auto_gates = jsonLoad()
end)

addEventHandler("onClientResourceStop",resourceRoot,function()
	jsonSave(auto_gates)
end)

function jsonCheck(_default_data)	
	if not fileExists(":cr_gate/data.json") then
		local json = fileCreate(":cr_gate/data.json")
		local json_string = toJSON(_default_data)
		fileWrite(json,json_string)
		fileClose(json)
	end
end

function jsonLoad()
	local json = fileOpen(":cr_gate/data.json")
	local json_string = ""
	while not fileIsEOF(json) do
		json_string = json_string..""..fileRead(json,500)
	end
	fileClose(json)
	return fromJSON(json_string)
end

function jsonSave(_table)
	fileDelete(":cr_gate/data.json")
	local json = fileCreate(":cr_gate/data.json")
		local json_string = toJSON(_table)
		fileWrite(json,json_string)
		fileClose(json)
end


function inArea(aX,aY,x,y,w,h)
	if aX > x and aX < x+w and aY > y and aY < y+h then return true end
	return false
end