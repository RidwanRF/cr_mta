local cache = {}
local hitCache = {}
local hitTimerCache = {}
local myname = false
local orangehex = exports['cr_core']:getServerColor("orange", true)
local refreshDatas = {
	["char >> name"] = true,
	["char >> afk"] = true,
    ["afk.seconds"] = true,
    ["afk.minutes"] = true,
    ["respawn.min"] = true,
    ["respawn"] = true,
    ["afk.hours"] = true,
    ["char >> chat"] = true,
	["char >> console"] = true,
	["char >> description"] = true,
	["admin >> name"] = true,
	["admin >> duty"] = true,
	["admin >> level"] = true,
	["char >> id"] = true,
	["ped.name"] = true,
	["ped.type"] = true,
	["parent"] = true,
	["deathReason"] = true,
	["deathReason >> admin"] = true,
    ["bubbleOn"] = true,
    ["char >> tazed"] = true,
    ["char >> cuffed"] = true,
}

addCommandHandler("myname", function()
    myname = not myname;
    --by royalf -> akarom látni a saját logom bocsi :c
end);

local lastTick = getTickCount()

local logo = dxCreateTexture("logos/logo.png", "dxt5", true, "clamp")
local logos = {
	["JeSuS"] = dxCreateTexture("logos/jesus.png", "dxt5", true, "clamp"),
	["YxngBones"] = dxCreateTexture("logos/royalf.png", "dxt5", true, "clamp"),
	["THMMS"] = dxCreateTexture("logos/thmms.png", "dxt5", true, "clamp"),
}

local images = {
	["afk"] = dxCreateTexture("files/afk.png", "dxt5", true, "clamp"),
	["chat"] = dxCreateTexture("files/write.png", "dxt5", true, "clamp"),
	["console"] = dxCreateTexture("files/console.png", "dxt5", true, "clamp"),
    ["dead"] = dxCreateTexture("files/skull.png", "dxt5", true, "clamp"),
    ["taser"] = dxCreateTexture("files/taser.png", "dxt5", true, "clamp"),
    ["respawn"] = dxCreateTexture("files/respawn.png", "dxt5", true, "clamp"),
}

function getLogo(charid)
	return logos[charid] or logo
end

addEventHandler("onClientResourceStart", root,
	function(sResource)
		local sResourceName = getResourceName(sResource)
		if sResourceName == "cr_core" then
			orangehex = exports['cr_core']:getServerColor("orange", true)
		end
	end
)

function hex2rgb(hex) 
    if hex then
        hex = hex:gsub("#","") 
        return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
    end
end 

local function nametag_callDatas(element)
	if not isElement(element) then return end
	local type = getElementType(element)
	if type == "player" then
		if source ~= localPlayer or myname then
			local charID = getElementData(element, "char >> id") or 0
			local charName = getElementData(element, "char >> name") or "Ismeretlen"
			charName = charName:gsub("_", " ")
			local adminDuty = getElementData(element, "admin >> duty")
			local adminColor = exports['cr_admin']:getAdminColor(element, false, true) or "#FFFFFF"
			local adminName = getElementData(element, "admin >> name") or "Ismeretlen"
			local adminTitle = exports['cr_admin']:getAdminTitle(element) or "Ismeretlen"
			adminTitle = adminTitle == "Fejlesztő" and "<Fejlesztő />" or "(" .. adminTitle .. ")"
            local description = getElementData(element, "char >> description")
            local a = 38
            if description then
                description = addCharToString(description, a, "\n", math.floor(#description / a))
            end
			local charNameColor
			if hitCache[element] then
				charNameColor = "#ff0000"
			else
				charNameColor = "#ffffff"
			end
			local extraText = ""
			--if getElementData(element, "char >> afk") then
			--	extraText = " "
			--end
			--if getElementData(element, "char >> chat") then
			--	extraText = extraText .. " "
			--end
			--if getElementData(element, "char >> console") then
			--	extraText = extraText .. " "
			--end
			local text = orangehex .. "(" .. charID .. ")" .. charNameColor .. " " .. charName
			if adminDuty or ((getElementData(element, "admin >> level") or 0) > 0 and (getElementData(element, "admin >> level") or 0) <= 2) then
				text = orangehex .. "(" .. charID .. ") " .. charNameColor .. (adminTitle:find("Adminsegéd") and charName or adminName) .. " " .. adminColor .. adminTitle
			end
            local dbid = getElementData(element, "acc >> id")
			cache[element] = {
                ["dbid"] = dbid,
				["text"] = text,
				["gText"] = string.gsub(text, "#%x%x%x%x%x%x", ""),
				["aduty"] = adminDuty,
				["rgb"] = {hex2rgb(adminColor)},
				["aname"] = adminName,
				["ishelper"] = getElementData(element, "admin >> level") == 1 or getElementData(element, "admin >> level") == 2,
				["afk"] = getElementData(element, "char >> afk"),
                ["afkData"] = {getElementData(element, "afk.seconds"), getElementData(element, "afk.minutes"), getElementData(element, "afk.hours")},
                ["respawnData"] = getElementData(element, "respawn.min"),
                ["respawn"] = getElementData(element, "respawn"),
				["chat"] = getElementData(element, "char >> chat"),
				["console"] = getElementData(element, "char >> console"),
                ["tazzed"] = getElementData(element, "char >> tazed"),
                ["cuffed"] = getElementData(element, "char >> cuffed"),
				["description"] = description,
                ["death"] = inDeath,
                ["bubbleOn"] = getElementData(element, "bubbleOn"),
			}
		end
	elseif type == "ped" then
		local pedParent = getElementData(element, "parent")
		if pedParent ~= localPlayer then
			local pedID = getElementData(element, "ped.id")
			local pedName = getElementData(element, "ped.name")
			if pedName then
				pedName = tostring(pedName):gsub("_", " ")
			end
			local pedType = getElementData(element, "ped.type")
			local pedParent = getElementData(element, "parent")
			local blockInsert
			local text
            local charID
            local charName
            local adminDuty
            local adminColor
            local adminName
            local adminTitle
            local inDeath
            local dbid
			if pedParent then
                dbid = getElementData(element, "acc >> id")
                charID = getElementData(pedParent, "char >> id") or 0
                charName = getElementData(pedParent, "char >> name") or "Ismeretlen"
                charName = charName:gsub("_", " ")
                adminDuty = getElementData(pedParent, "admin >> duty")
                adminColor = exports['cr_admin']:getAdminColor(pedParent, false, true) or "#FFFFFF"
                adminName = getElementData(pedParent, "admin >> name") or "Ismeretlen"
                adminTitle = exports['cr_admin']:getAdminTitle(pedParent) or "Ismeretlen"
                inDeath = getElementData(pedParent, "inDeath")
				extraText = ""
                --[[
				if getElementData(pedParent, "char >> afk") then
					extraText = " [AFK]"
				end
				if getElementData(pedParent, "char >> chat") then
					extraText = extraText .. " [Chat]"
				end
				if getElementData(pedParent, "char >> console") then
					extraText = extraText .. " [Console]"
				end
                ]]
				local hex = "#FFFFFF"
				if inDeath then
					hex = "#262626"
				end
				text = orangehex .. "(" .. charID .. ")" .. hex .. " " .. charName .. "#FFFFFF" .. extraText
				if adminDuty then
					text = adminColor .. adminName .. " " .. "(" .. adminTitle .. ")#FFFFFF\n" .. text
				end
				if inDeath then
					local deathReason
					if anames then
						deathReason = getElementData(pedParent, "deathReason >> admin") or "Ismeretlen"
					else
						deathReason = getElementData(pedParent, "deathReason") or "Ismeretlen"
					end
					text =  text .. "\n#FF0000" .. deathReason
				end
			else
				if pedName and pedType then
					local pedNameColor = "#ffffff"
					if isPedDead(element) then
						pedNameColor = "#262626"
					elseif hitCache[element] then
						pedNameColor = "#ff0000"
					end
					text = pedNameColor .. pedName .. " " .. orangehex .. "(" .. pedType .. ")"
				else
					blockInsert = true
				end
			end
			if not blockInsert then
                local pedParent = pedParent or element
                local description = getElementData(pedParent, "char >> description")
                local a = 38
                if description then
                    description = addCharToString(description, a, "\n", math.floor(#description / a))
                end
				cache[element] = {
                    ["dbid"] = dbid,
					["text"] = text,
					["gText"] = string.gsub(text, "#%x%x%x%x%x%x", ""),
                    ["aduty"] = adminDuty,
                    ["rgb"] = {hex2rgb(adminColor)},
                    ["aname"] = adminName,
                    ["afk"] = getElementData(pedParent, "char >> afk"),
                    ["afkData"] = {getElementData(pedParent, "afk.seconds"), getElementData(pedParent, "afk.minutes"), getElementData(pedParent, "afk.hours")},
                    ["respawnData"] = getElementData(pedParent, "respawn.min"),
                    ["respawn"] = getElementData(pedParent, "respawn"),
                    ["chat"] = getElementData(pedParent, "char >> chat"),
                    ["console"] = getElementData(pedParent, "char >> console"),
                    ["tazzed"] = getElementData(pedParent, "char >> tazed"),
                    ["cuffed"] = getElementData(pedParent, "char >> cuffed"),     
                    ["description"] = description,
                    ["dead"] = inDeath,
                    ["bubbleOn"] = getElementData(pedParent, "bubbleOn"),
				}
			end
		end
	end
end

pAduty = getElementData(localPlayer, "admin >> duty")
anames = getElementData(localPlayer, "admin >> duty")
friends = getElementData(localPlayer, "friends") or {}

local function nametag_hitElement()
	if isTimer(hitTimerCache[source]) then
		killTimer(hitTimerCache[source])
	end
	hitCache[source] = true
	nametag_callDatas(source)
	hitTimerCache[source] = setTimer(
		function(source)
			hitCache[source] = nil
			nametag_callDatas(source)
		end, 3000, 1, source
	)
end
addEventHandler("onClientPedDamage", root, nametag_hitElement)
addEventHandler("onClientPlayerDamage", root, nametag_hitElement)

setTimer(
    function()
        if not friends then
            friends = getElementData(localPlayer, "friends") or {}
        end
        cameraX, cameraY, cameraZ = getCameraMatrix()
        for k,v in pairs(cache) do
            local boneX, boneY, boneZ = getPedBonePosition(k, 5)
            if isElementOnScreen(k) then
                cache[k]["sightLine"] = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, localPlayer)
                cache[k]["distance"] = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                cache[k]["alpha"] = k.alpha >= 255
                --local sx, sy = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.25)
                --cache[k]["screenX"] = sx
                --cache[k]["screenY"] = sy
                cache[k]["isKnow"] = friends[v["dbid"]]
                if localPlayer.vehicle then
                    if not k.vehicle or k.vehicle ~= localPlayer.vehicle then
                        cache[k]["isKnow"] = false
                    end
                elseif k.vehicle then
                    if not localPlayer.vehicle or localPlayer.vehicle ~= k.vehicle then
                        cache[k]["isKnow"] = false
                    end
                end
            end
        end
    end, 100, 0
)

renderCache = {}

setTimer(
    function()
        renderCache = {}
        for k,v in pairs(cache) do
            if isElement(k) then
                if (k ~= localPlayer or myname) and isElementStreamedIn(k) and isElementOnScreen(k) then
                    renderCache[k] = v
                end
            end
        end
    end, 100, 0
)

local _maxDist = 42
local function nametag_handleRender(timeSlice)
    font = exports['cr_fonts']:getFont("Roboto", 15)
    font2 = exports['cr_fonts']:getFont("Roboto", 11)
    color = exports['cr_core']:getServerColor(nil, true)
    white = "#ffffff"
    now = getTickCount()
    --cameraX, cameraY, cameraZ = getCameraMatrix()
	for element, value in pairs(renderCache) do
        if isElement(element) then
		--if (element ~= localPlayer or myname) and isElementOnScreen(element) then
			--local currentInt, currentDim = getElementInterior(localPlayer), getElementDimension(localPlayer)
			--local targetInt, targetDim = getElementInterior(element), getElementDimension(element)
			if value["alpha"] then
				local boneX, boneY, boneZ = getPedBonePosition(element, 5)
				local sightLine = value["sightLine"]
				if anames then
					sightLine = true
				end
				if sightLine then
					local maxDistance = _maxDist
					if anames and getElementType(element) == "player" then
						maxDistance = 1000
					end
					local distance = value["distance"]
					if distance <= maxDistance then
                        local size = 1 - (distance / maxDistance)
						local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + (0.25 * size))
						if screenX and screenY then
							local text = value["text"]
							local gText = value["gText"]
                            local dbid = value["dbid"]
                            local afk = value["afk"]
                            local respawn = value["respawn"]
                            local alpha = 255*size
                            
                            if afk then
                                local afkData = value["afkData"]
                                local sec, min, hour = afkData[1], afkData[2], afkData[3]
                                if not sec then sec = 0 end
                                if not min then min = 0 end
                                if not hour then hour = 0 end
                                --if not afkData[1] or tonumber(afkData[1] or 0) < 1 then sec = "00" end
                                --if not afkData[2] or tonumber(afkData[2] or 0) < 1 then min = "00" end
                                --if not afkData[3] or tonumber(afkData[3] or 0) < 1 then hour = "00" end
                                --outputChatBox(tonumber(sec))
                                if tonumber(sec) >= 1 or tonumber(min) >= 1 or tonumber(hour) >= 1 then
                                    local size = 1 - (distance / _maxDist)
                                    if size > 0 then
                                        screenY = screenY - (30 * size)
                                        text = color .. hour .. white ..":" .. color .. min .. white ..":" .. color .. sec .. white .."\n" .. text
                                        gText = hour ..":" .. min ..":" .. sec .."\n" .. gText
                                    else
                                        afk = false
                                    end
                                else
                                    afk = false
                                end
                            end
                            
                            --outputChatBox(tostring(value["dead"]))
                            if value["dead"] then
                                screenY = screenY + (30 * size)
                            end
                            
                            if respawn then
                                local min = value["respawnData"]
                                if tonumber(min) then
                                    local size = 1 - (distance / _maxDist)
                                    if size > 0 then
                                        screenY = screenY - (30 * size)
                                        text = color .. min .. white .. " perce éledt újra!\n" .. text
                                        gText = min .." perce éledt újra!\n" .. gText
                                    else
                                        respawn = false
                                    end
                                else
                                    respawn = false
                                end
                            end
                            --dxDrawText(gText,screenX,screenY+1,screenX,screenY+1,tocolor(0,0,0,200),size, font, "center", "center", false, false, false, true, true)
                            --dxDrawText(gText,screenX,screenY-1,screenX,screenY-1,tocolor(0,0,0,200),size, font, "center", "center", false, false, false, true, true)
                            --dxDrawText(gText,screenX-1,screenY,screenX-1,screenY,tocolor(0,0,0,200),size, font, "center", "center", false, false, false, true, true)
                            --outputChatBox(tostring(exports['cr_elementbox']:isKnow(localPlayer, dbid)))
                            
                            --#3fc424

                            if value["isKnow"] or value["aduty"] or pAduty or getElementType(element) ~= "player" or element == localPlayer then
                                dxDrawText(gText,screenX+1,screenY+1,screenX+1,screenY+1,tocolor(0,0,0,alpha <= 200 and alpha or 200),size, font, "center", "center", false, false, false, true, true)
                                dxDrawText(text, screenX, screenY, screenX, screenY, tocolor(255, 255, 255, alpha), size, font, "center", "center", false, false, false, true, true)
                            else
                                dxDrawText(gText,screenX+1,screenY+1,screenX+1,screenY+1,tocolor(0,0,0,alpha <= 50 and alpha or 50),size, font, "center", "center", false, false, false, true, true)
                                dxDrawText(text, screenX, screenY, screenX, screenY, tocolor(255, 255, 255, alpha <= 100 and alpha or 100), size, font, "center", "center", false, false, false, true, true)
                            end
                            
                            if not descriptionsDisabled then
                                local size = 1 - (distance / _maxDist)
                                if size > 0 then
                                    if value["description"] then
                                        local x2,y2,z2 = element:getBonePosition(3)
                                        local x3, y3 = getScreenFromWorldPosition(x2,y2,z2,25,false)
                                        if x3 and y3 then
                                            --dxDrawText(description, x3+1,y3+1, x3+1,y3+1, tocolor(0, 0, 0,255), multipler, font,"center","center",false,false,false,true,true)
                                            dxDrawText(value["description"], x3 + (50 * size)/2,y3, x3 - (50 * size)/2,y3, tocolor(194, 162, 218,255), size, font2,"center","center",false,false,false,true,true)
                                        end
                                    end
                                end
                            end
                            
                            if anames and element.type == "player" then
                                --local x2,y2,z2 = element:getBonePosition(3)
                                --local x3, y3 = getScreenFromWorldPosition(x2,y2,z2,25,false)
                                --if x3 and y3 then
                                local x3, y3 = screenX, screenY + (30 * size)+ (30 * size)
                                --local size = 1 - (distance / 200)
                                if size > 0 then
                                    local multipler = element.health / 100
                                    local w, h = 200 * size, 20 * size
                                    dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w, h, tocolor(0,0,0,180))
                                    dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w * multipler, h, tocolor(255,87,87,180))

                                    local multipler = element.armor / 100
                                    local w, h = 200 * size, 20 * size
                                    dxDrawRectangle(x3 - w/2, y3 + (10 * size) - h/2, w, h, tocolor(0,0,0,180))
                                    dxDrawRectangle(x3 - w/2, y3 + (10 * size) - h/2, w * multipler, h, tocolor(87,87,255,180))
                                end
                                --end
                            end

                            
                            --local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                            --dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), 50 * size, 50 * size, images["respawn"], 0, 0, 0, tocolor(255,255,255, alpha))
                            if not value["bubbleOn"] then
                                if value["chat"] then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["chat"], 0, 0, 0, tocolor(217, 124, 14, alpha))
                                elseif value["console"] then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["console"], 0, 0, 0, tocolor(217, 124, 14, alpha))
                                elseif afk then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["afk"], 0, 0, 0, tocolor(255,87,87, alpha))
                                elseif value["tazzed"] then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["taser"], 0, 0, 0, tocolor(255,87,87, alpha))
                                elseif respawn then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["respawn"], 0, 0, 0, tocolor(255,255,255, alpha))
                                elseif value["dead"] then
                                    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["dead"], 0, 0, 0, tocolor(20,20,20, alpha))
                                elseif value["aduty"] or value["ishelper"] then
                                    local y, alpha = interpolateBetween(-5, 0, 0, 5, 255, 0, now / 2500, "CosineCurve")
                                    --local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
                                    dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size) + (y * size), 50 * size, 50 * size, getLogo(value["aname"]), 0, 0, 0, logos[value["aname"]] and tocolor(255, 255, 255, alpha) or tocolor(value["rgb"][1], value["rgb"][2], value["rgb"][3], alpha))
                                end
                            end
						end
					end
				end
			end
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(value) then
				nametag_callDatas(value)
				setPlayerNametagShowing(value, false)
			end
		end
		for key, value in ipairs(getElementsByType("ped")) do
			if isElementStreamedIn(value) then
				nametag_callDatas(value)
			end
		end
		hudVisible = getElementData(localPlayer, "hudVisible")
		if hudVisible then
			addEventHandler("onClientRender", root, nametag_handleRender, true, "low-5")
		else
			removeEventHandler("onClientRender", root, nametag_handleRender)
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		nametag_callDatas(source)
		setPlayerNametagShowing(source, false)
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		cache[source] = nil
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dName)
        if dName == "admin >> duty" and source == localPlayer then
            pAduty = getElementData(localPlayer, "admin >> duty")
            anames = pAduty
        elseif dName == "friends" and source == localPlayer then
            friends = getElementData(localPlayer, "friends") or {}
        end
        local source = source
        local _source = source
        if source.type == "player" and source:getData("clone") then source = source:getData("clone") or source end
		if cache[source] and refreshDatas[dName] then
            if dName == "afk.seconds" or dName == "afk.minutes" or dName == "afk.hours" then
                local element = source
                --if source.type == "ped" and source:getData("parent") then element = source:getData("parent") or source end
                --if source.type == "player" and source:getData("clone") then element = source:getData("clone") or source end
                --outputChatBox("asd"..inspect(element))
                cache[element]["afkData"] = {getElementData(_source, "afk.seconds"), getElementData(_source, "afk.minutes"), getElementData(_source, "afk.hours")}
                return
            elseif dName == "respawn.min" then
                local element = source
                --if source.type == "ped" and source:getData("parent") then element = source:getData("parent") or source end
                --if source.type == "player" and source:getData("clone") then element = source:getData("clone") or source end
                --outputChatBox("asd"..inspect(element))
                cache[element]["respawnData"] = getElementData(_source, "respawn.min")
                return
            end
            --outputChatBox("asd-"..dName)
			nametag_callDatas(source)
		end
		if source == localPlayer and dName == "hudVisible" then
			hudVisible = getElementData(localPlayer, "hudVisible")
			if hudVisible then
				addEventHandler("onClientRender", root, nametag_handleRender, true, "low-5")
			else
				removeEventHandler("onClientRender", root, nametag_handleRender)
			end
		end
		if source == localPlayer and dName == "admin >> duty" and not getElementData(source, dName) then
			anames = false
		end
	end
)

addEventHandler("onClientPlayerQuit", root,
	function()
		cache[source] = nil
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		cache[source] = nil
	end
)

setTimer( 
    function()  
        if isChatBoxInputActive() then
            setElementData(localPlayer, "char >> chat", true)
            return
        else
            setElementData(localPlayer, "char >> chat", false)
        end

        if isConsoleActive() then
            setElementData(localPlayer, "char >> console", true)	
            return
        else
            setElementData(localPlayer, "char >> console", false)
        end
        
        if isMTAWindowActive() then
            if not afk then
                afk = true
                startAfkTimer()
                setElementData(localPlayer, "char >> afk", true)
            end
        end
    end    
, 350, 0)

function toggleANames(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "anames") then
        anames = not anames
        for element, _ in pairs(cache) do
        	nametag_callDatas(element)
        end
        if anames then
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen bekapcsoltad az adminisztrátori nametaget!", 255,255,255,true)
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Sikeresen kikapcsoltad az adminisztrátori nametaget!", 255,255,255,true)
        end
    end
end
addCommandHandler("anames", toggleANames)
addCommandHandler("nevek", toggleANames)

addCommandHandler("refreshnametag",
	function()
		for _, element in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(element) then
				nametag_callDatas(element)
			end
		end
		for _, element in ipairs(getElementsByType("ped")) do
			if isElementStreamedIn(element) then
				nametag_callDatas(element)
			end
		end
		for element, _ in pairs(cache) do
			nametag_callDatas(element)
		end
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Sikeresen frissítetted a nametag adatokat!", 255,255,255,true)
	end
)

function addCharToString(str, pos, chr, howMany, origPos)
    if howMany == 0 then return str end
    if not origPos then origPos = pos end
    local stringVariation = str:sub(1, pos) .. chr .. str:sub(pos + 1)
    howMany = howMany - 1
    return addCharToString(stringVariation, pos + origPos, chr, howMany, origPos)
end

function jsonGETT(file)
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        --local num = originalMaxLines
        --local x, y = sx/2, sy/2
        fileWrite(fileHandle, toJSON({false}))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVET(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        descriptionsDisabled = unpack(jsonGETT("@option.json"))
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        jsonSAVET("@option.json", {descriptionsDisabled})
    end
)

function togdescriptions()
    descriptionsDisabled = not descriptionsDisabled
end
addCommandHandler("togdescriptions", togdescriptions)
addCommandHandler("togdescription", togdescriptions)
addCommandHandler("togdesc", togdescriptions)
addCommandHandler("tdesc", togdescriptions)
addCommandHandler("tdescription", togdescriptions)