commandDetails = {
    --["commandNév"] = {minAdminlevel, specialAdminLevels (Ez olyan pld: -1s rang az a mapperé és ez a command csak a mappernek müködjön), requestAdminDuty, minimumNoDutyLevel}
    ["forcepm"] = {8, {[0]=false},false},
    ["fly"] = {3, {
            [-6] = true, 
            [-5] = true, 
            --[-4] = true, 
            --[-3] = true, 
            --[-2] = true, 
            [-1] = true, 
            [0] = false
        }, 
    true, 5},
    ["anames"] = {3, {[-1] = true, [0] = false}, true, 7},
    ["showWaterXYZ"] = {10, {[-1] = false, [0] = false}, true, 10},
    ["setadminlevel"] = {9, {[0] = false}, false},
    ["vehBoot"] = {9, {[0] = false}, false},
    ["safeBoot"] = {9, {[0] = false}, false},
    --exports['cr_permission']:hasPermission(localPlayer, "vehBoot")
    ["sethelperlevel"] = {5, {[0] = false}, false},
    ["stats"] = {8, {[0] = false}, false},
    ["stat"] = {5, {[0] = false}, false},
    ["asegit"] = {3, {[0] = false}, false},
    ["agyogyit"] = {3, {[0] = false}, false},
    ["aduty"] = {3, {[0] = false}, false},
    ["resetserial"] = {5, {[0] = false}, false},
    ["forceaduty"] = {8, {[0] = false}, false},
    ["togalog"] = {3, {[0] = false}, false},
    ["getpos"] = {8, {[0] = false}, false},
    ["forceVehicleOpen"] = {4, {[0] = false}, true, 9},
    ["forceVehicleStart"] = {4, {[0] = false}, true, 9},
    ["setvehint"] = {5, {[0] = false}, false},
    ["setvehdim"] = {5, {[0] = false}, false},
    ["setvehcolor"] = {8, {[0] = false}, false},
    ["forcePark"] = {8, {[0] = false}, false},
    ["gotocar"] = {3, {[0] = false, [-6] = true, [-1] = true}, false},
    ["getcar"] = {3, {[0] = false, [-6] = true, [-1] = true}, false},
    ["nearbyvehicle"] = {3, {[0] = false}, false},
    --["nearbyjobvehicle"] = {3, {[0] = false}, false},
    ["deljobvehicle"] = {3, {[0] = false}, false},
    ["fixveh"] = {3, {[0] = false, [-1] = true}, false},
    ["unflipVehicle"] = {3, {[0] = false}, false},
    ["setcarhp"] = {4, {[0] = false}, false},
    ["rtc"] = {4, {[0] = false}, false},
    ["fuelveh"] = {4, {[0] = false, [-1] = true}, false},
    ["setfuelveh"] = {4, {[0] = false}, false},
    ["resetvehoil"] = {5, {[0] = false, [-1] = true}, false},
    ["setvehoil"] = {5, {[0] = false}, false},
    ["resetfix"] = {9, {[0] = false}, false},
    ["resetrtc"] = {9, {[0] = false}, false},
    ["resetfuel"] = {9, {[0] = false}, false},
    ["resetatime"] = {9, {[0] = false}, false},
    ["resetban"] = {9, {[0] = false}, false},
    ["resetkick"] = {9, {[0] = false}, false},
    ["resetjail"] = {9, {[0] = false}, false},
    ["setvehicleplatetext"] = {8, {[0] = false}, false},
    ["resetadminstats"] = {9, {[0] = false}, false},
    ["achangelock"] = {8, {[0] = false}, false},
    ["makeveh"] = {9, {[0] = false}, false},
    ["delthisveh"] = {8, {[0] = false}, false},
    ["delveh"] = {8, {[0] = false}, false},
    ["movecarfaction"] = {8, {[0] = false}, false},
    ["removecarfaction"] = {8, {[0] = false}, false},
    ["protect"] = {8, {[0] = false}, false},
    ["unprotect"] = {8, {[0] = false}, false},
    ["blowvehicle"] = {9, {[0] = false}, false},
    ["startvehengine"] = {8, {[0] = false}, false},
    ["stopvehengine"] = {8, {[0] = false}, false},
    ["getadminstats"] = {8, {[0] = false}, false},
    ["getvehiclestats"] = {3, {[0] = false}, false},
    ["setadminnick"] = {8, {[0] = false}, false},
    ["debug"] = {9, {[0] = false, [-1] = true}, false},
    ["addspeedcam"] = {9, {[0] = false}, false},
    ["getnearbyspeedcams"] = {9, {[0] = false}, false},
    ["delspeedcam"] = {9, {[0] = false}, false},
    ["glue"] = {3, {[0] = false}, true, 8},
    ["getkilllog"] = {3, {[0] = false}, true, 8},
    ["loadvehicle"] = {8, {[0] = false}, true, 9},
    ["savevehicle"] = {8, {[0] = false}, true, 9},
    ["unloadvehicle"] = {8, {[0] = false}, true, 9},

    ["ajail"] = {3, {[0] = false, [-3] = true, [-4] = true}, false},
    ["offjail"] = {5, {[0] = false, [-4] = true}, false},
    ["forceajail"] = {8, {[0] = false, [-4] = true}, false},
    
    ["showinventory"] = {3, {[0] = false}, false},
    ["itemlist"] = {8, {[0] = false}, false},
    ["deltrash"] = {8, {[0] = false}, false},
    ["addtrash"] = {8, {[0] = false}, false},
    ["nearbytrash"] = {8, {[0] = false}, false},
    ["nearbysafe"] = {8, {[0] = false}, false},
    ["addsafe"] = {8, {[0] = false}, false},
    ["delsafe"] = {8, {[0] = false}, false},
    ["convertmap"] = {9, {[0] = false}, false},

    ["pm"] = {0, {[1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = true, [8] = true, [9] = true, [10] = true}, false},
    ["vá"] = {1, {[0] = false}, true, 8},
    ["asay"] = {7, {[0] = false}, false},
    ["togvá"] = {3, {[0] = false}, false},
    ["asChat"] = {1, {[0] = false}, false},
    ["adminChat"] = {3, {[0] = false}, false},
    ["vhSpawn"] = {3, {[0] = false}, false},
    ["recon"] = {3, {[0] = false}, true, 8},
    ["goto"] = {3, {[0] = false}, false},
    ["gethere"] = {3, {[0] = false}, false},
    ["sethp"] = {3, {[0] = false}, true, 7},
    ["setarmor"] = {3, {[0] = false}, true, 7},
    ["vanish"] = {3, {[0] = false}, true, 7},
    ["sethunger"] = {3, {[0] = false}, false},
    ["setwater"] = {3, {[0] = false}, false},
    ["kick"] = {3, {[0] = false, [-2] = true, [-3] = true, [-4] = true}, false},
    ["setskin"] = {3, {[0] = false}, false},
    ["freeze"] = {3, {[0] = false}, false},
    ["unfreeze"] = {3, {[0] = false}, false},

    ["sgoto"] = {4, {[0] = false}, false}, -- ADMIN 2 --
    ["setname"] = {4, {[0] = false}, false},
    ["accinfo"] = {9, {[0] = false}, false},

    ["setmoney"] = {9, {[0] = false}, true, 10},
    ["setbankmoney"] = {9, {[0] = false}, true, 10},
    ["setpp"] = {9, {[0] = false}, true, 10},

    ["forceInteriorLock"] = {3, {[0] = false}, true, 8},
    ["createinterior"] = {8, {[0] = false}, false},
    ["deleteinterior"] = {8, {[0] = false}, false},
    ["loadinterior"] = {9, {[0] = false}, false},
    ["renameinterior"] = {8, {[0] = false}, false},
    ["setinteriorcost"] = {8, {[0] = false}, false},
    ["setinteriorowner"] = {8, {[0] = false}, false},
    ["moveinteriorenter"] = {8, {[0] = false}, false},
    ["moveinteriorexit"] = {8, {[0] = false}, false},

    ["createelevator"] = {8, {[0] = false}, false},
    ["deleteelevator"] = {8, {[0] = false}, false},
    ["loadelevator"] = {9, {[0] = false}, false},

    ["creategate"] = {8, {[0] = false}, false},
    ["deletegate"] = {8, {[0] = false}, false},

    ["createfuel"] = {8, {[0] = false}, false},
    ["deletefuel"] = {8, {[0] = false}, false},
    ["setfuelcost"] = {9, {[0] = false}, false},

    ["createshopobject"] = {9, {[0] = false}, false},
    ["createshopbasket"] = {9, {[0] = false}, false},
    ["createshopped"] = {9, {[0] = false}, false},
    ["insertshopobjectitem"] = {9, {[0] = false}, false},
    ["deleteshopobject"] = {9, {[0] = false}, false},
    ["deleteshopbasket"] = {9, {[0] = false}, false},
    ["deleteshopped"] = {9, {[0] = false}, false},
    ["removeshopobjectitem"] = {9, {[0] = false}, false},

    ["createlicenseped"] = {9, {[0] = false}, false},
    ["deletelicenseped"] = {9, {[0] = false}, false},

    ["createticketped"] = {9, {[0] = false}, false},
    ["deleteticketped"] = {9, {[0] = false}, false},

    ["af"] = {8, {[0] = false}, false}, -- FŐ ADMIN --
    ["dev"] = {11, {[0] = false}, false}, -- FEJLESZTŐ --
	
    ["giveitem"] = {8, {[0] = false}, false}, -- SUPER ADMIN --	

    
    ["setfaction"] = {8, {[0] = false}, false}, -- SUPER ADMIN --	
    ["setfactionrank"] = {8, {[0] = false}, false}, -- SUPER ADMIN --	
    ["setfactionleader"] = {8, {[0] = false}, false}, -- SUPER ADMIN --	
    ["createfaction"] = {9, {[0] = false}, false}, -- SUPER ADMIN --	
    ["deletefaction"] = {9, {[0] = false}, false}, -- SUPER ADMIN --	
    ["showfactions"] = {8, {[0] = false}, false}, -- SUPER ADMIN --	
    
    ["addnote"] = {11, {[0] = false}, false}, -- FEJLESZTŐ --	
    
    ["ban"] = {5, {[0] = false}, false},
    ["oban"] = {6, {[0] = false}, false},
    ["unban"] = {7, {[0] = false}, false},
    ["changeaccname"] = {9, {[0] = false}, false},
    ["changeaccpw"] = {9, {[0] = false}, false},
    ["changeaccemail"] = {9, {[0] = false}, false},
    ["changeaccserial"] = {9, {[0] = false}, false},

    ["delplacedo"] = {3, {[0] = false}, false},
	
	["addrock"] = {11, {[0] = false}, false},
	["delrock"] = {11, {[0] = false}, false},
	["nearbyrocks"] = {11, {[0] = false}, false},
	
	["addtree"] = {11, {[0] = false}, false},
	["deltree"] = {11, {[0] = false}, false},
	["nearbytrees"] = {11, {[0] = false}, false},
	
	["addwaste"] = {11, {[0] = false}, false},
	["delwaste"] = {11, {[0] = false}, false},
	["nearbywaste"] = {11, {[0] = false}, false},

    ["createtable"] = {8, {[0] = false}, false}, -- SUPER ADMIN -- 
    ["edittable"] = {8, {[0] = false}, false}, -- SUPER ADMIN -- 
    ["stopedittable"] = {8, {[0] = false}, false}, -- SUPER ADMIN --  
	
    
    ["addatm"] = {9, {[0] = false}, false},
	["delatm"] = {9, {[0] = false}, false},
	["nearbyatm"] = {9, {[0] = false}, false},
	
	["nearbyjobvehicle"] = {3, {[0] = false}, false},
    
    ["createtables"] = {3, {[3] = true}, false}, -- SUPER ADMIN -- 
    ["edittables"] = {3, {[3] = true}, false}, -- SUPER ADMIN -- 
    ["stopedittables"] = {3, {[3] = true}, false}, -- SUPER ADMIN --
}

local serverside = false
addEventHandler("onResourceStart", resourceRoot,
    function()
        serverSide = true
        --On clientSide event onResourceStart doesnt work.
    end
)

function hasPermission(element, command)
    local data = commandDetails[command]
    if not isElement(element) then return false end
    if not getElementData(element, "loggedIn") then
        return false
    end
    if data then
        local adminlevel = getElementData(element, "admin >> level") or 0
        if adminlevel >= data[1] then
            if data[3] then
                local adminduty = exports['cr_admin']:getAdminDuty(element) --getElementData(element, "admin >> duty")
                if adminlevel >= data[4] then
                    adminduty = true
                end
                
                if adminduty or exports['cr_core']:getPlayerDeveloper(element) then
                    return true
                end
            else
                return true
            end
        elseif data[2][adminlevel] then
            if data[3] then
                local adminduty = exports['cr_admin']:getAdminDuty(element) --getElementData(element, "admin >> duty")
                if adminduty or exports['cr_core']:getPlayerDeveloper(element) then
                    return true
                end
            else
                return true
            end
        elseif exports['cr_core']:getPlayerDeveloper(element) then
            return true
        end
    end
    return false
end

function getRequiredLevel(command)
    return commandDetails[command][1]
end