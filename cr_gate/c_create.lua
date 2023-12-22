-----   StaY Mta -----
-----  	  Gate   -----
-----   Made by  -----
-----    Awang   -----
-----   Version  -----
-----     0.1    -----
--- Here I'm again ---
----------------------



--- TODO 06.19 : 
--- now editing: convert to class <-> save opened, closed positions for type 1
--- Type 2 : create the changer
--- Server: Check the saving, loading on the start
--- Question: place owner to the commandHandler or create a DX field for it?




--In order to render the browser on the full screen, we need to know the dimensions.
local screenWidth, screenHeight = guiGetScreenSize()

--Let's create a new browser in local mode. We will not be able to load an external URL.
local webBrowser = createBrowser(screenWidth, screenHeight, true, true)
	
--This is the function to render the browser.
function webBrowserRender()
	--Render the browser on the full size of the screen.
	dxDrawImage(0, 0, screenWidth, screenHeight, webBrowser, 0, 0, 0, tocolor(255,255,255,255), true)
end

--The event onClientBrowserCreated will be triggered, after the browser has been initialized.
--After this event has been triggered, we will be able to load our URL and start drawing.
addEventHandler("onClientBrowserCreated", webBrowser, 
	function()
		--After the browser has been initialized, we can load our file.
		loadBrowserURL(webBrowser, "http://mta/local/assets/web/panel.html")
		--Now we can start to render the browser.
		
	end
)


function setElementMatrix(element,matrix)
	local pos = matrix:getPosition()
	setElementPosition(element,pos:getX(),pos:getY(),pos:getZ())
	local rot = matrix:getRotation()
	setElementRotation(element,rot:getX(),rot:getY(),rot:getZ())
end

function unpackMatrix(mx)
	local pos = mx:getPosition()
	local rot = mx:getRotation()
	return {pos:getX(),pos:getY(),pos:getZ(),rot:getX(),rot:getY(),rot:getZ()}
end

local white = tocolor(255,255,255)
local black = tocolor(0,0,0)
local orange = tocolor(242, 96, 0)

local Editing = {}
Editing.__index = Editing
Editing.now = nil
Editing.object = nil
Editing.attached = nil
Editing.type = 1
Editing.positions = {}

local EditPanel = {}
local ExitState = "editor"

EditPanel.__index = EditPanel
EditPanel.x,EditPanel.y,EditPanel.w,EditPanel.h = 
{1800*DX.x,1750*DX.x},300*DX.y,75*DX.x,275*DX.y

local table_index = 1

EditPanel.animation = {nil,2500,0,0}
EditPanel.icons = 32
EditPanel.lock = "assets/images/lock.png"
EditPanel.selected = 0
EditPanel.selected_old = 0
function EditPanel:change(value)
	EditPanel.selected_old = EditPanel.selected
	EditPanel.selected = value
	EditPanel.colors = {white,white,white,white,white,white}
	EditPanel.colors[EditPanel.selected] = orange
end

function EditPanel:check()
	if EditPanel.selected ~= EditPanel.selected_old then
		if EditPanel.selected_old == 3 then
			Editing.positions[1] = Editing.object.matrix
		elseif EditPanel.selected_old == 4 then
			Editing.positions[2] = Editing.object.matrix
		elseif EditPanel.selected_old == 5 then
			Editing.positions[3] = Editing.attached.matrix
		elseif EditPanel.selected_old == 6 then
			Editing.positions[4] = Editing.attached.matrix
		end
	end
end

EditPanel.boxes_y = {
	EditPanel.y+5*DX.x,
    EditPanel.y+75*DX.y,
    EditPanel.y+145*DX.x,
    EditPanel.y+215*DX.y,

}
EditPanel.colors = {white,white,white,white,white,white} 


function Editing:createGate(id,mx)
	Editing.object = createObject(enable_gates[id][1],0,0,-100)
	setElementMatrix(Editing.object,mx)
	Editing.type = enable_gates[id][2]
	Editing.positions[1] = Editing.object.matrix
	Editing.positions[2] = Editing.object.matrix
	if Editing.type == 2 then
		mx = mx:transformPosition(gate_datas[enable_gates[id][1]][Editing.type][3])
		Editing.attached = createObject(enable_gates[id][1],mx:getX(),mx:getY(),mx:getZ())
		Editing.positions[3] = Editing.attached.matrix
		Editing.positions[4] = Editing.attached.matrix
	end
	table_index = id
	Editing.now = Editing.object
	EditPanel:change(3)
end

function Editing:deleteGate()
	local mx = Editing.object.matrix
	ExitState = "forced"
	exports["cr_elementeditor"]:quitEditor()
	ExitState = "editor"
	destroyElement(Editing.object)
	if Editing.type == 2 then
		destroyElement(Editing.attached)
	end
	return mx
end


function editRender()
	--[[local mover =  Animation:call(EditPanel.animation[1],EditPanel.animation[2],EditPanel.animation[3], 0, 0, EditPanel.animation[4], 0, 0,"OutBounce")
	Animation:dxDrawRoundedRectangle(EditPanel.x[Editing.type]+mover,EditPanel.y,EditPanel.w,EditPanel.h,   tocolor(exports['cr_core']:getServerColor(100, false)))
		dxDrawImage(EditPanel.x[Editing.type]+mover+15*DX.x,EditPanel.boxes_y[1],EditPanel.icons,EditPanel.icons,"assets/images/gate.png",0,0,0,EditPanel.colors[1])
		dxDrawImage(EditPanel.x[Editing.type]+mover+15*DX.x,EditPanel.boxes_y[2],EditPanel.icons,EditPanel.icons,EditPanel.lock ,0,0,0,EditPanel.colors[2])
		dxDrawImage(EditPanel.x[Editing.type]+mover+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons,"assets/images/edit_1.png",0,0,0,EditPanel.colors[3])
		dxDrawImage(EditPanel.x[Editing.type]+mover+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons,"assets/images/edit_2.png",0,0,0,EditPanel.colors[4])
	if Editing.type == 2 then
		Animation:dxDrawRoundedRectangle(EditPanel.x[Editing.type]+80*DX.x+mover,EditPanel.y+140*DX.y,EditPanel.w,EditPanel.h-140*DX.y,   tocolor(exports['cr_core']:getServerColor(100, false)))
		dxDrawImage(EditPanel.x[Editing.type]+80*DX.x+mover+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons,"assets/images/edit_1.png",0,0,0,EditPanel.colors[5])
		dxDrawImage(EditPanel.x[Editing.type]+80*DX.x+mover+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons,"assets/images/edit_2.png",0,0,0,EditPanel.colors[6])
	end
	]]--
	
end


function editClick(button,state,aX,aY)
	if button == "left" and state == "down" then
		if inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[1],EditPanel.icons,EditPanel.icons) then
			EditPanel:change(1)
			EditPanel:check()
			if table_index ~= #enable_gates then table_index = table_index + 1 
			else table_index = 1 end
			
			local del_mx = Editing.deleteGate()
						
            Editing:createGate(table_index,del_mx)
			
            exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
				
		elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[2],EditPanel.icons,EditPanel.icons) then
			EditPanel:change(2)
			EditPanel:check()
			if EditPanel.lock == "assets/images/lock.png" then 
				EditPanel.lock = "assets/images/unlock.png" 
					setElementMatrix(Editing.object,Editing.positions[1])
					local mx_table = unpackMatrix(Editing.positions[2])
					moveObject(Editing.object,2000,mx_table[1],mx_table[2],mx_table[3])
					if Editing.type == 2 then
						setElementMatrix(Editing.object,Editing.positions[3])
						local a_mx_table= unpackMatrix(Editing.positions[4])
						moveObject(Editing.attached,2000,a_mx_table[1],a_mx_table[2],a_mx_table[3])
					end
			else 
				EditPanel.lock = "assets/images/lock.png"
					setElementMatrix(Editing.object,Editing.positions[2])
					local mx_table = unpackMatrix(Editing.positions[1])
					moveObject(Editing.object,2000,mx_table[1],mx_table[2],mx_table[3])
				if Editing.type == 2 then
					setElementMatrix(Editing.object,Editing.positions[4])
					local a_mx_table= unpackMatrix(Editing.positions[3])
						moveObject(Editing.attached,2000,a_mx_table[1],a_mx_table[2],a_mx_table[3])
				end
			end
			
		elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons) then
			EditPanel:change(3)
			EditPanel:check()
			if Editing.now == Editing.attached then
					ExitState = "forced"
					exports["cr_elementeditor"]:quitEditor()
					ExitState = "editor"
					Editing.now = Editing.object
					exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
			end
			setElementMatrix(Editing.now,Editing.positions[1])
			
			
		elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons) then
			EditPanel:change(4)
			EditPanel:check()
			if Editing.now == Editing.attached then
					ExitState = "forced"
					exports["cr_elementeditor"]:quitEditor()
					ExitState = "editor"
					Editing.now = Editing.object
					exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
			end
			setElementMatrix(Editing.now,Editing.positions[2])
		else
			
		end
		if Editing.type == 2 then
			if inArea(aX,aY,EditPanel.x[Editing.type]+80*DX.x+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons) then
				EditPanel:change(5)
				EditPanel:check()
				if Editing.now == Editing.object then
					ExitState = "forced"
					exports["cr_elementeditor"]:quitEditor()
					ExitState = "editor"
					Editing.now = Editing.attached
					exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
				end
				setElementMatrix(Editing.now,Editing.positions[3])
			elseif inArea(aX,aY,EditPanel.x[Editing.type]+80*DX.x+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons) then
				EditPanel:change(6)
				EditPanel:check()
				if Editing.now == Editing.object then
					ExitState = "forced"
					exports["cr_elementeditor"]:quitEditor()
					ExitState = "editor"
					Editing.now = Editing.attached
					exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
				end
				setElementMatrix(Editing.now,Editing.positions[4])
			end
		end
	end
end

function editHoover(_,_,aX,aY) 
	if inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[1],EditPanel.icons,EditPanel.icons) then
        EditPanel.colors = {black,white,white,white}			
    elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[2],EditPanel.icons,EditPanel.icons) then
        EditPanel.colors = {white,black,white,white}
    elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons) then
        EditPanel.colors = {white,white,black,white}
    elseif inArea(aX,aY,EditPanel.x[Editing.type]+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons) then
        EditPanel.colors = {white,white,white,black}
    else
        EditPanel.colors = {white,white,white,white}
    end
	if Editing.type == 2 then
		if inArea(aX,aY,EditPanel.x[Editing.type]+80*DX.x+15*DX.x,EditPanel.boxes_y[3],EditPanel.icons,EditPanel.icons) then
			EditPanel.colors = {white,white,white,white,black,white}
		elseif inArea(aX,aY,EditPanel.x[Editing.type]+80*DX.x+15*DX.x,EditPanel.boxes_y[4],EditPanel.icons,EditPanel.icons) then
			EditPanel.colors = {white,white,white,white,white,black}
		else
			EditPanel.colors[5],EditPanel.colors[6] = white,white
		end
	end
	if EditPanel.selected ~= 0 then EditPanel.colors[EditPanel.selected] = orange end
end

function editHandler(state)
	if state then
		EditPanel.animation = {getTickCount(),2500,EditPanel.w*2,0}
		addEventHandler("onClientRender",root,editRender) 
		setTimer(function()
			addEventHandler("onClientClick",root,editClick)
			addEventHandler("onClientCursorMove",root,editHoover)
		end,EditPanel.animation[2],1)		
	else
		if Editing.type == 1 then EditPanel.animation = {getTickCount(),1000,0,EditPanel.w*2}
		else EditPanel.animation = {getTickCount(),1000,0,EditPanel.w*3} end
		removeEventHandler("onClientClick",root,editClick)
		removeEventHandler("onClientCursorMove",root,editHoover)
		setTimer(function()
			removeEventHandler("onClientRender",root,editRender)
		end,EditPanel.animation[2],1)	
	end 
end




addEvent("onCliensGateEditorSaveCall",true)
addEventHandler("onCliensGateEditorSaveCall",root, function()

	local opened = unpackMatrix(Editing.positions[1])
	local closed = unpackMatrix(Editing.positions[2])
	local marker_1 = Editing.positions[1]
	marker_1 = marker_1:transformPosition(gate_datas[Editing.object.model][Editing.type][1])
	marker_1 = {marker_1:getX(),marker_1:getY(),marker_1:getZ()+3}
	marker_1[3] = getGroundPosition(marker_1[1],marker_1[2],marker_1[3])-0.05
	
	local marker_2 = Editing.positions[1]
	marker_2 = marker_2:transformPosition(gate_datas[Editing.object.model][Editing.type][2])
	marker_2 = {marker_2:getX(),marker_2:getY(),marker_2:getZ()+3}
	marker_2[3] = getGroundPosition(marker_2[1],marker_2[2],marker_2[3])-0.05
	
	if Editing.type == 1 then
		triggerServerEvent("onGateNew",localPlayer,Editing.object.model,Editing.type,{closed,opened},{marker_1,marker_2},nil)
	else
		local a_opened = unpackMatrix(Editing.positions[4])
		local a_closed = unpackMatrix(Editing.positions[3])
		triggerServerEvent("onGateNew",localPlayer,Editing.object.model,Editing.type,{closed,opened},{marker_1,marker_2},{a_closed,a_opened})
	end
	Editing:deleteGate()
    editHandler(false)
end)

addEvent("onCliensGateEditorDeleteCall",true)
addEventHandler("onCliensGateEditorDeleteCall",root,
    function(element,x,y,z,rx,ry,rz)
		if ExitState == "editor" then
			destroyElement(Editing.object)
			Editing.object = nil
			if Editing.type == 2 then
				destroyElement(Editing.attached)
				Editing.attached = nil
			end
			
			editHandler(false)
		elseif ExitState == "forced" then
		end
	end
)

addEvent("onGateCreateCallBack",true)
addEventHandler("onGateCreateCallBack",root,
    function(element)
	
    end
)


addCommandHandler("creategate",
    function()
    	--guiSetAlpha( window, 255 )
        local mx = localPlayer.matrix
        mx = Matrix(mx:transformPosition(0,5,0))
		Editing:createGate(2,mx)
		Editing.now = Editing.object
        exports["cr_elementeditor"]:toggleEditor(Editing.now,"onCliensGateEditorSaveCall","onCliensGateEditorDeleteCall")
        editHandler(true)
    end
)



function onCursorMove ( relativeX , relativeY , absoluteX , absoluteY ) 
	injectBrowserMouseMove ( webBrowser , absoluteX , absoluteY ) 
	end 

function onKey(button)
	if button == "mouse_wheel_down" then
		injectBrowserMouseWheel(webBrowser, -40, 0)
	elseif button == "mouse_wheel_up" then
		injectBrowserMouseWheel(webBrowser, 40, 0)
	end
end

addCommandHandler("gatepanel",function()
	outputChatBox("true")
	addEventHandler("onClientClick", root,
	function(button, state)
	if state == "down" then
		injectBrowserMouseDown(webBrowser, button)
	else
		injectBrowserMouseUp(webBrowser, button)
	end 
	end)
	 focusBrowser(webBrowser)
	addEventHandler ( "onClientCursorMove" , root , onCursorMove )
	addEventHandler("onClientRender", root, webBrowserRender)
	addEventHandler("onClientKey", root, onKey)
end)



