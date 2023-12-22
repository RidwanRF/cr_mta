local material_type = 1
local editing_table = nil
local materials = {}
local shader = dxCreateShader("fx.fx")
local x_screen,y_screen = guiGetScreenSize()

local hexCode = exports['cr_core']:getServerColor(nil, true)

function keyHandler(button,state)
	if isChatBoxInputActive() then return end
	if button == "q" and state then
		if material_type > 1 then
			material_type = material_type-1
		else
			material_type = 28
		end
		if editing_table then
			engineRemoveShaderFromWorldTexture(materials[material_type], "tabla" ,editing_table)
			engineApplyShaderToWorldTexture( materials[material_type], "tabla" ,editing_table)
		end
	elseif button == "e" and state then
		if material_type < 28 then
			material_type = material_type+1
		else
			material_type = 1
		end
		if editing_table then
			engineRemoveShaderFromWorldTexture(materials[material_type], "tabla" ,editing_table)
			engineApplyShaderToWorldTexture( materials[material_type], "tabla" ,editing_table)
		end
	end	
end

local p_x, p_y = 10,y_screen/2-100
local move_x,move_y = 0,0 

function renderChoose()
	dxDrawRoundedRectangle(p_x,p_y,175,200,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
	dxDrawRoundedRectangle(p_x,p_y,175,30,tocolor(0, 0, 0,170),tocolor(0, 0, 0,255))
	dxDrawText(hexCode.."Tábla szerkeztés",p_x,p_y,p_x+175,p_y+30,tocolor(255,255,255),1,"default","center","center",false,false,false,true)
	dxDrawText("Kiválasztott plakát:",p_x,p_y+35,p_x+175,p_y+55,tocolor(255,255,255),1,"default","center","center")
	dxDrawImage(p_x+40,p_y+40,100,100,"textures/"..material_type..".png")
	dxDrawText(hexCode.."Tipp:\n #ffffffq ~ e billenytűket használd",p_x,p_y+170,p_x+175,p_y+170,tocolor(255,255,255),1,"default","center","center",false,false,false,true)
	
end

function moveHandler()
	local x,y = getCursorPosition()
	x,y = x_screen*x,y_screen*y
	p_x, p_y = x-move_x,y-move_y
end

function clickChoose(button,state,aX,aY)
	if button == "left" and state == "down" and aX>p_x and aX<p_x+175 and aY>p_y and aY<p_y+30 then
		move_x,move_y = aX-p_x,aY-p_y
		addEventHandler( "onClientRender",root,moveHandler)
	elseif button == "left" and state == "up" then
		removeEventHandler( "onClientRender",root,moveHandler)
	end
end

function tableDelete()
	local nearestTableDist = 1000
	local nearestTable = nil
	local px,py,pz = getElementPosition( localPlayer )
	for k, object in ipairs(getElementsByType("object",root,true)) do
		if object.model == 9055 then
			local ox,oy,oz = getElementPosition( object )
			local dist = getDistanceBetweenPoints3D( px, py,pz, ox,oy,oz)
			if dist < nearestTableDist then
				nearestTableDist = dist
				nearestTable = object
			end
		end
	end	
	if nearestTable then
		triggerServerEvent("onTrafficTableDelete",root,nearestTable)
	end
end

function createTable()
	if not exports["cr_permission"]:hasPermission(localPlayer,"createtables") then return end
	local pos = localPlayer.matrix
	outputChatBox("true")
	pos = pos:transformPosition(Vector3(1,0,0))
	local x,y,z = pos:getX(),pos:getY(),pos:getZ()
	editing_table = createObject(9055,x,y,z)
	engineApplyShaderToWorldTexture( materials[material_type], "tabla" ,editing_table)
	exports["cr_elementeditor"]:toggleEditor(editing_table,"onTableSave","onTableDelete")
end



addCommandHandler( "edittables", function() 	
	if exports["cr_permission"]:hasPermission(localPlayer,"edittables") then
        addEventHandler( "onClientRender", root, renderChoose)
        addEventHandler( "onClientKey", root,keyHandler)
        addEventHandler( "onClientClick",root,clickChoose)
        addCommandHandler( "deletetable", tableDelete)
        addCommandHandler( "createtable", createTable)
    end            
end)

addCommandHandler( "stopedittable", function() 
	if not exports["cr_permission"]:hasPermission(localPlayer,"stopedittables") then return end
	removeEventHandler( "onClientRender", root, renderChoose)
	removeEventHandler( "onClientKey", root,keyHandler)
	removeCommandHandler( "deletetable", tableDelete)
	removeCommandHandler( "createtable", createTable)
end)

addEvent("onTableSave",true)
addEventHandler( "onTableSave", root, function()
	local pos = editing_table.position
	local pos2 = editing_table.rotation
	local dim = getElementDimension( localPlayer )
	local int = getElementInterior( localPlayer )
	triggerServerEvent( "onTablePlace", localPlayer, pos.x,pos.y,pos.z,pos2.x,pos2.y,pos2.z,int,dim,material_type)
	destroyElement( editing_table )
	editing_table = nil
end)

addEvent("onTableDelete",true) 

addEventHandler( "onTableDelete", root, function()
	destroyElement( editing_table )
end)


addEventHandler( "onClientResourceStart", resourceRoot, function()
	engineImportTXD(engineLoadTXD("files/tabla.txd"), 9055)
	engineReplaceCOL(engineLoadCOL("files/tabla.col"), 9055)
	engineSetModelLODDistance(9055, 150)
	engineReplaceModel(engineLoadDFF("files/tabla.dff", 9055), 9055)
	for i=1,28 do
		materials[i] = dxCreateShader("fx.fx")
		local texture = dxCreateTexture("textures/"..i..".png")
		dxSetShaderValue( materials[i] , "gTexture",texture)
	end
	setTimer(function()
		triggerServerEvent( "onClientLoadTable", root) 
	end,5050,1)
 end)

addEvent("onClientLoadTableCallBack",true)

addEventHandler("onClientLoadTableCallBack",root,function(table)
	if not table then return end
	for k ,values in pairs(table) do
		loadTableTexture(k)
	end
end)

function loadTableTexture(element)
	local type_id = element:getData("table.type")
	engineRemoveShaderFromWorldTexture(materials[type_id], "tabla" ,element)
	engineApplyShaderToWorldTexture( materials[type_id], "tabla" ,element)
end

addEvent("onLoadTableMaterial",true)
addEventHandler( "onLoadTableMaterial", root,loadTableTexture)


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
	dxDrawRectangle(left,top,width,height,color)
end





