-----   StaY Mta -----
-----  	  Gate   -----
-----   Made by  -----
-----    Awang   -----
-----   Version  -----
-----     0.1    -----
--- Here I'm again ---
----------------------

local connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
end)

Async:setPriority("high")
Async:setDebug(true)


function createGate(model,_type,opened,closed,marker_1_pos,marker_2_pos,attached_opened,attached_closed) -- DONE
	local positions = {closed,opened}
	local element = createObject(model,closed[1],closed[2],closed[3],closed[4],closed[5],closed[6])
	local attached_element = nil
	element:setData("opened",opened)
	element:setData("closed",closed)
	element:setData("type",_type)
	element:setData("moving",false)
	element:setData("statement","closed")
	
	
	local marker_1 = createMarker(marker_1_pos[1],marker_1_pos[2],marker_1_pos[3],"cylinder",gate_datas[model][_type][4],0,200,0,100)
	marker_1:setData("root_gate",element)
	marker_1:setData("is_gate_marker",true)
	
	local marker_2 = createMarker(marker_2_pos[1],marker_2_pos[2],marker_2_pos[3],"cylinder",gate_datas[model][_type][4],0,200,0,100)
	marker_2:setData("root_gate",element)
	marker_2:setData("is_gate_marker",true)
	
	
	if _type == 2 then
		local pos = element.matrix:transformPosition(gate_datas[model][_type][3])
		positions = {closed,opened,attached_closed,attach_opened}
		attached_element = createObject(model,attached_closed[1],attached_closed[2],attached_closed[3],attached_closed[4],attached_closed[5],attached_closed[6])
		element:setData("attached_gate",attached_element)
		attached_element:setData("opened",attached_opened)
		attached_element:setData("closed",attached_closed)
	end
	
	element:setData("marker_1",marker_1)
	element:setData("marker_2",marker_2)
	local marker_positions = {marker_1_pos,marker_2_pos}
	
	if _type == 1 then
		return {_type,toJSON(positions),toJSON(marker_positions),model},element,nil
	else
		return {_type,toJSON(positions),toJSON(marker_positions),model},element,attached_element
	end
end                            


addEvent("onGateMove",true)

function moveGate(gate) -- DONE
	if  gate:getData("statement") == "closed" then
		local rot = gate.matrix:getRotation()
		local opened = gate:getData("opened")
		
		local offsetRX = fixRotation(rot:getX() - opened[4])
		local offsetRY = fixRotation(rot:getY() - opened[5])
		local offsetRZ = fixRotation(rot:getZ() - opened[6])
		outputChatBox(""..offsetRX)
		moveObject(gate,2000,opened[1],opened[2],opened[3],offsetRX,offsetRY,offsetRZ)
		
		
		if gate:getData("type") == 2 then
			local attach = gate:getData("attached_gate")
			local attach_opened = getData("opened")
			local offsetRX = fixRotation(rot:getX() - attach_opened[4])
			local offsetRY = fixRotation(rot:getY() - attach_opened[5])
			local offsetRZ = fixRotation(rot:getZ() - attach_opened[6])
			moveObject(attach,2000,unpack(attach_opened),offsetRX, offsetRY, offsetRZ)
		end
		gate:setData("statement","opened")
	elseif gate:getData("statement") == "opened" then
		local rot = gate.matrix:getRotation()
		local closed = gate:getData("closed")
		local offsetRX = fixRotation(rot:getX() - closed[4])
		local offsetRY = fixRotation(rot:getY() - closed[5])
		local offsetRZ = fixRotation(rot:getZ() - closed[6])
		moveObject(gate,2000,closed[1],closed[2],closed[3],offsetRX,offsetRY,offsetRZ)
		if gate:getData("type") == 2 then
			local attach = gate:getData("attached_gate")
			local attach_closed = getData("closed")
			local offsetRX = fixRotation(rot:getX() - attach_closed[4])
			local offsetRY = fixRotation(rot:getY() - attach_closed[5])
			local offsetRZ = fixRotation(rot:getZ() - attach_closed[6])
			moveObject(attach,2000,unpack(attach_closed),offsetRX, offsetRY, offsetRZ)
		end
		gate:setData("statement","closed")
	end
end
 

addEventHandler("onGateMove",getRootElement(),moveGate)


addEvent("onGateNew",true) -- DONE

function newGate(model,_type,mx,marker_mx,mx_attached)
	
	local data,element,attached_element = nil,nil,nil
	
	if _type == 2 then
		data,element,attached_element = createGate(model,_type,mx[1],mx[2],marker_mx[1],marker_mx[2],mx_attached[1],mx_attached[2])
	else data,element,attached_element = createGate(model,_type,mx[1],mx[2],marker_mx[1],marker_mx[2],nil,nil) end
	
	dbExec(connection, "INSERT INTO `gates` SET `type`=?, `positions`=?,`marker_positions`=? ,`model`=?", unpack(data))
	local last_id = nil
	dbQuery(
		function(query)
			local query, query_lines = dbPoll(query, 0)
			if query_lines > 0 then
				Async:foreach(query, 
					function(row) 
						last_id = tonumber(row["id"])
				end)
			end
		end, 
	connection, "SELECT `id` FROM `gates` WHERE id = LAST_INSERT_ID()")
	element:setData("id",last_id)
	if attached_element ~= nil then attached_element:setData("id",last_id) end
	exports["cr_infobox"]:addBox(source,"succes","Sikeresen lehelyezted a kaput/ajtót!")
end

addEventHandler("onGateNew",getRootElement(),newGate)

addEvent("onGateSave",true)

function saveGate(gate) -- DONE
	local id = gate:getData("id")
	local _type = gate:getData("type")
	local model = gate.model
	local positions = nil
	if _type == 1 then
		positions = {
			gate:getData("opened"),
			gate:getData("closed")
		}
	elseif _type == 2 then
		local attached = gate:getData("attached_gate")
		positions = {
			gate:getData("opened"),
			gate:getData("closed"),
			attached:getData("opened"),
			attached:getData("closed"),
		}
	end
	dbExec(connection, "UPDATE `gates` SET `type`=?,`owner`=?, `positions`=?,`statement`=? WHERE `id`=?",_type,toJSON(positions),model,id)
end

addEventHandler("onGateSave",getRootElement(),saveGate)

addEvent("onGateDelete",true)

function deleteGate(gate) -- DONE
	local id = gate:getData("id")
	if gate:getData("type") == 2 then destroyElement(gate:getData("attached_gate"))	end
	destroyElement(gate:getData("marker_1"))
	destroyElement(gate:getData("marker_2"))
	destroyElement(gate)
	dbExec(connection, "DELETE FROM `gates` WHERE `id`=?",id)
end

addEventHandler("onGateDelete",getRootElement(),deleteGate)


addEventHandler("onResourceStart",resourceRoot,function()
	dbQuery(
		function(query)
			local query, query_lines = dbPoll(query, 0)
			if query_lines > 0 then
				Async:foreach(query, 
					function(row) 
						local mx = fromJSON(row["positions"])
						local marker_mx = fromJSON(row["marker_positions"])
						if tonumber(row["type"]) == 1 then
							createGate(tonumber(row["model"]),tonumber(row["type"]),mx[1],mx[2],marker_mx[1],marker_mx[2],nil,nil)
						else
							createGate(tonumber(row["model"]),tonumber(row["type"]),mx[1],mx[2],marker_mx[1],marker_mx[2],mx[3],mx[4])
						end
					end
				)
				 
			end
			outputDebugString("Succesfully loaded "..query_lines.." gates!")
		end, 
	connection, "SELECT * FROM `gates`")
end)


function fixRotation(value)
	local invert = true
	if value < 0 then
		while value < -360 do
			value = value + 360
		end
		if value < -180 then
			value = value + 180
			value = value - value - value
		end
	else
		while value > 360 do
			value = value - 360
		end
		if value > 180 then
			value = value - 180
			value = value - value - value
		end
	end
	return value
end



