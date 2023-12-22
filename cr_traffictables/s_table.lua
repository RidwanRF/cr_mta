connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)

local created_table = {}



function tablePlace(_id,_x,_y,_z,_rx,_ry,_rz,_int,_dim,material_type)
	local element = createObject( 9055, _x,_y,_z,_rx,_ry,_rz,true)
	element:setData("table.type",material_type)
	element:setData("table.id",_id)
	created_table[element] = {id = _id,x = _x, y = _y, z = _z, rx = _rx,ry = _ry,rz = _rz,int = _int, dim = _dim, board_type = material_type}
	triggerClientEvent( root, "onLoadTableMaterial",element,element)
end

function tableRemove(element)
	created_table[element] = nil
	local id = element:getData("table.id")
	dbExec( connection, "DELETE FROM traffic_tables  WHERE id = ?", id)
	destroyElement(element)
end

function saveTable(_x,_y,_z,_rx,_ry,_rz,int,dim,material_type)
	local position = {x = _x,y = _y,z = _z}
	position = toJSON( position )
	local rotation = {rx = _rx,ry = _ry,rz = _rz}
	rotation = toJSON( rotation )
	local id = nil
	dbExec( connection, "INSERT INTO traffic_tables  SET position = ?, rot = ?, interior = ?, dimension = ?, board_type = ?", position, rotation,tonumber(int),tonumber(dim), material_type)

	dbQuery(
       		 function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                      id =  tonumber(row["id"])
                    end
                )
            end
        end, 
  	  connection, "SELECT id FROM `traffic_tables` WHERE position = ?",position)
	tablePlace(id,_x,_y,_z,_rx,_ry,_rz,int,dim,material_type)
end


addEvent("onTrafficTableDelete",true)
addEventHandler( "onTrafficTableDelete",root,tableRemove)

addEvent("onTablePlace",true)
addEventHandler("onTablePlace",root,saveTable) 





addEventHandler("onResourceStart",resourceRoot,function()
		dbQuery(
       		 function(query)
            local query, query_lines = dbPoll(query, 0)
            if query_lines > 0 then
                Async:foreach(query, 
                    function(row)
                        local position = fromJSON(row["position"])
                        local rotation = fromJSON( row["rot"] )
                        tablePlace(tonumber(row["id"]),tonumber(position["x"]),tonumber(position["y"]),position["z"],tonumber(rotation["rx"]),tonumber(rotation["ry"]),tonumber(rotation["rz"]),row["interior"],row["dimension"],tonumber(row["board_type"]))
                    end
                )
            end
        end, 
  	  connection, "SELECT * FROM `traffic_tables`")			
end)

addEvent("onClientLoadTable",true)

addEventHandler( "onClientLoadTable", root,function() 
	triggerClientEvent( source, "onClientLoadTableCallBack", source, created_table )
end)

function jsonLoad()
	local json = fileOpen("tables.json")
	local json_string = ""
	while not fileIsEOF(json) do
		json_string = json_string..""..fileRead(json,500)
	end
	fileClose(json)
	return fromJSON(json_string)
end