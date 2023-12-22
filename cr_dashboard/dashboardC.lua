local screenW, screenH = guiGetScreenSize();
local dashElement = localPlayer;

local renderDatas = {
	opened = false,
	page = 1,

	myGroup = {},
	myGroupId = nil,
	myGroupDatas = {},

	lastTick = getTickCount() - 2000,

	start = getTickCount(),
	elapsed = nil,
    duration = nil,
   	progress = nil,

	fontSizeMultipler = screenW / 1920,
	dxDrawMultipler = (screenW / 1920) * 1.75,

	left = screenW / 2 - ((800 * (screenW / 1920) * 1.75) / 2),
	top = screenH / 2 - ((500 * (screenW / 1920) * 1.75) / 2),
	width = 800 * ((screenW / 1920) * 1.75),
	height = 450 * ((screenW / 1920) * 1.75),

	menus = {
		"\nÁttekintés",
		"\nVagyon",
		"\nBeállítások",
		"\nAdminisztrátorok",
		"\nPrémium",
		"\nCsoportok",
	},

	screenDatas = {},

	circleBrowser = nil,
	circleBrowserReady = false,

	screenSource = dxCreateScreenSource(screenW, screenH),
	shader = dxCreateShader("files/shaders/shader.fx"),

	myAccountId = nil,

	pedPreview = nil,
	playerData = {},
	factionInfos = {},
	availableAdmins = {},
	myVehicles = {},
	myInteriors = {},

	slotBuy = {},
	groupAlert = {},

	shaderSettings = {
		file = nil,

		json = {
			["carreflect"] = {"Karosszéria tükröződés", false, "switchCarPaintReflect"},
			["hdwater"] = {"HD Víz", false, "switchWaterRefract"},
			["hdtexture"] = {"HD Textura", false, "switchHdTextures"},
			["blackwhite"] = {"Fekete fehér", false, "switchBlackWhite"},
			["dof"] = {"Mélységélesség", false, "switchDoF"},
			["hdr"] = {"HDR", false, "switchContrast"},
			["palette"] = {"Szín paletta", false, "switchPalette"},
			["clipdist"] = {"Látótávolság", 300, false},
		},
	},

	gameSettings = {
		json = {
			["3dblip"] = {"3D Blipek", true, nil},
			["walkstyle"] = {"Séta stílus", 118, nil, {118, 119, 120, 121, 122, 123, 124, 125, 126, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137}},
			["fightstyle"] = {"Harc stílus", 4, nil, {4, 5, 6, 7, 15, 16}},
			["chatstyle"] = {"Beszéd stílus", false, nil, {false, "prtial_gngtlka", "prtial_gngtlkb", "prtial_gngtlkc", "prtial_gngtlkd", "prtial_gngtlke", "prtial_gngtlkf", "prtial_gngtlkg", "prtial_gngtlkh", "prtial_hndshk_01", "prtial_hndshk_biz_01"}},
            ["hud"] = {"HUD Típus", 1, nil, {1, 2}},
		},1
	},
};

local colors = {
	bg = tocolor(0, 0, 0, 180),
	slot = tocolor(40, 40, 40, 200),
	hover = tocolor(255, 153, 51, 180),
	second = tocolor(74, 158, 222, 180),
	cancel = tocolor(243, 85, 85, 180),
	white = tocolor(255, 255, 255),
	black = tocolor(0, 0, 0),
	orangehex = "#ff9933",
};

local adminLevesNames = {"Idg. Adminsegéd", "Adminsegéd", "Admin 1", "Admin 2", "Admin 3", "Admin 4", "Admin 5", "FőAdmin", "SuperAdmin"};

if screenW >= 1920 then
	renderDatas.dxDrawMultipler = 1.2;

	renderDatas.left = screenW / 2 - 800 * 1.2 / 2;
	renderDatas.top = screenH / 2 - 500 * 1.2 / 2;
	renderDatas.width = 800 * 1.2;
	renderDatas.height = 450 * 1.2;
end

--if fileExists("files/shaders/settings.json") then
--	fileDelete("files/shaders/settings.json");
--end

function loadGameSettings()
    if fileExists("files/shaders/settings.json") then
        renderDatas.shaderSettings.file = fileOpen("files/shaders/settings.json");

        if renderDatas.shaderSettings.file then
            local buffer = nil;

            while not fileIsEOF(renderDatas.shaderSettings.file) do
                buffer = fileRead(renderDatas.shaderSettings.file, 500);
            end

            for key, value in pairs(fromJSON(buffer)) do
                if renderDatas.shaderSettings.json[key] then
                    renderDatas.shaderSettings.json[key][2] = value;
                elseif renderDatas.gameSettings.json[key] then
                    renderDatas.gameSettings.json[key][2] = value;
                end
            end

            fileClose(renderDatas.shaderSettings.file);

            setTimer(function()
                for key, value in pairs(renderDatas.shaderSettings.json) do
                    if value[3] then
                        triggerEvent(value[3], localPlayer, value[2]);
                    end

                    if key == "clipdist" then
                        setFarClipDistance(value[2]);
                    end
                end

                for key, value in pairs(renderDatas.gameSettings.json) do
                    if key == "3dblip" then
                        exports.cr_radar:toggle3DBlip(value[2]);
                    end

                    if key == "walkstyle" then
                        triggerServerEvent("gameSettings->WalkStyle", localPlayer, localPlayer, value[2]);
                    end

                    if key == "fightstyle" then
                        triggerServerEvent("gameSettings->FightStyle", localPlayer, localPlayer, value[2]);
                    end

                    if key == "chatstyle" then
                        setElementData(localPlayer, "gameSettings->ChatStyle", value[2]);
                    end

                    if key == "hud" then
                        setElementData(localPlayer, "gameSettings->HUD", value[2]);
                    end
                end
            end, 1000, 1);
        else
            exports.cr_infobox:addBox("error", "Hiba a beállítások betöltése közben");
        end	
    else
        renderDatas.shaderSettings.file = fileCreate("files/shaders/settings.json");
        fileWrite(renderDatas.shaderSettings.file, toJSON({["3dblip"] = true, ["walkstyle"] = 118, ["fightstyle"] = 4, ["chatstyle"] = false, ["hud"] = 1, ["carreflect"] = false, ["hdwater"] = false, ["hdtexture"] = false, ["blackwhite"] = false, ["dof"] = false, ["hdr"] = false, ["palette"] = false, ["clipdist"] = 300}, true));
        fileClose(renderDatas.shaderSettings.file);
    end
end

renderDatas.circleBrowser = createBrowser(600, 150, true, true);
addEventHandler("onClientBrowserCreated", renderDatas.circleBrowser, function()
	loadBrowserURL(renderDatas.circleBrowser, "http://mta/local/files/html/progress.html");
end);

addEventHandler("onClientBrowserDocumentReady", renderDatas.circleBrowser, function()
	renderDatas.circleBrowserReady = true;
end);

local _dxDrawRectangle = dxDrawRectangle;
local dxDrawRectangle = function(left, top, width, height, color, postgui)
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

local getFont = function(font, size)
	return exports.cr_fonts:getFont(font, math.floor(size));
end

function getPlayerInformations()
	-->> Ped preview
	if isElement(renderDatas.pedPreview) then
		destroyElement(renderDatas.pedPreview);
	end

	local imgH = renderDatas.height - 60 - dxGetFontHeight(1, getFont("Azzardo-Regular", 18 * renderDatas.dxDrawMultipler)) - dxGetFontHeight(1, getFont("AwesomeFont2", 11 * renderDatas.dxDrawMultipler));

	renderDatas.pedPreview = createPed(dashElement.model, 0, 0, 0);
	exports.object_preview:createObjectPreview(renderDatas.pedPreview, 0, 0, 180, renderDatas.left + 22, renderDatas.top + renderDatas.height - 20 - imgH + 2, imgH * (345 / 689) - 4, imgH - 4, false, true);

	-->> Browser stats
	executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('health', " .. math.floor(dashElement.health + 0.5) .. ");");
	executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('armor', " .. math.floor(dashElement.armor + 0.5) .. ");");
	executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('food', " .. math.floor(getElementData(dashElement, "char >> food") + 0.5) .. ");");
	executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('drink', " .. math.floor(getElementData(dashElement, "char >> drink") + 0.5) .. ");")

	-->> Char datas
	renderDatas.myAccountId = getElementData(dashElement, "acc >> id");
	renderDatas.myGroupId = getElementData(dashElement, "char >> groupId");

	renderDatas.playerData = {
		"Karakter név: " .. exports.cr_admin:getAdminName(dashElement),
		"Szint: " .. getElementData(dashElement, "char >> level"),
		"Pénz: " .. getElementData(dashElement, "char >> money"),
		"Karakter ID: " .. getElementData(dashElement, "acc >> id"),
		"Prémium pont: " .. getElementData(dashElement, "char >> premiumPoints"),
		"Játszott perc: " .. getElementData(dashElement, "char >> playedtime"),
		"Skin: " .. dashElement.model,
		"Kor: " .. getElementData(dashElement, "char >> details")["age"],
		"Jármű slot: " .. getElementData(dashElement, "char >> vehicleLimit"),
		"Interior slot: " .. getElementData(dashElement, "char >> interiorLimit"),
		"Leírás: " .. getElementData(dashElement, "char >> description"),
		" " .. getElementData(dashElement, "char >> details")["age"] .. colors.orangehex .. " éves  #ffffff " .. getElementData(dashElement, "char >> money") .. colors.orangehex .. " dollár  #ffffff " .. getElementData(dashElement, "char >> level") .. colors.orangehex .. " LVL", 
	};

	-->> Faction infos
    if dashElement == localPlayer then
        renderDatas.factionInfos = {count = 0, selected = 1, datas = {}};

        for key, value in pairs(exports.cr_faction:getPlayerFactions() or {}) do
            local rank, payment = exports.cr_faction:getPlayerDatas(localPlayer, key);
            local rankName = value["ranks"][rank][1] or "";

            table.insert(renderDatas.factionInfos.datas, {
                factionName = value["name"] or "#none",
                rank = "Rang: " .. rankName or "#none",
                payment = "Fizetés: $" .. payment or 0
            });

            renderDatas.factionInfos.count = renderDatas.factionInfos.count + 1;
        end
    else
        renderDatas.factionInfos = {count = 0, selected = 1, datas = {}};
    end
end

function getAvailableAdmins()
	renderDatas.availableAdmins = {selected = 1, table = {}};
	
	for index = 1, 9 do
		renderDatas.availableAdmins.table[index] = {
			name = adminLevesNames[index],
			admins = {},
		};
	end

	for key, value in pairs(getElementsByType("player")) do
		if getElementData(value, "loggedIn") then
			if getElementData(value, "admin >> level") > 0 and getElementData(value, "admin >> level") <= 9 then
				table.insert(renderDatas.availableAdmins.table[getElementData(value, "admin >> level")].admins, {
					leftText = (getElementData(value, "admin >> level") <= 2 and exports.cr_admin:getAdminName(value) or exports.cr_admin:getAdminName(value, true)) .. " (ID: " .. getElementData(value, "char >> id") .. ")",
					rightText = exports.cr_admin:getAdminDuty(value) and "#7cc576Szolgálatban" or "#cc0000Nincs szolgálatban"
				});
			end
		end
	end
end

function getPlayerVehicles()
	renderDatas.myVehicles = {scroll = {max = 8, last = 1, current = 1}, vehs = {}, selected = 1, slot = getElementData(dashElement, "char >> vehicleLimit")};
	
	for key, value in pairs(getElementsByType("vehicle"), getResourceFromName("cr_elements")) do
		if (getElementData(value, "veh >> id") or 0) > 0 and getElementData(value, "veh >> owner") == getElementData(dashElement, "acc >> id") and getElementData(value, "veh >> faction") == 0 then
			table.insert(renderDatas.myVehicles.vehs, {
				element = value,
				name = "(#" .. getElementData(value, "veh >> id") .. ") " .. exports.cr_vehicle:getVehicleName(value.model),
				hp = "Állapot: " .. colors.orangehex .. math.floor(value.health / 10) .. "%#ffffff",
				locked = getElementData(value, "veh >> locked") and "#cc0000" or "#7cc576",
				odometer = colors.orangehex .. math.floor(getElementData(value, "veh >> odometer")) .. " km",
				position = colors.orangehex .. getZoneName(value.position) .. "#ffffff"
			});
		end
	end
end

function getPlayerInteriors()
	renderDatas.myInteriors = {scroll = {max = 10, last = 1, current = 1}, ints = {}, selected = 1, slot = getElementData(dashElement, "char >> interiorLimit")};
	
	for key, value in pairs(getElementsByType("marker"), getResourceFromName("cr_interior")) do
		if getElementData(value, "interior >> name") and getElementData(value, "interior >> owner") == getElementData(dashElement, "acc >> id") then
			table.insert(renderDatas.myInteriors.ints, {
				element = value,
				name = "(#" .. getElementData(value, "interior >> id") .. ") " .. getElementData(value, "interior >> name"),
				locked = getElementData(value, "interior >> lock ") and "#cc0000" or "#7cc576",
				position = {area = getZoneName(value.position), city = getZoneName(value.position, true)}
			});
		end
	end
end

function changeState(page, element)
    dashElement = isElement(element) and element or localPlayer;

	renderDatas.slotBuy = {state = false, type = nil};
	renderDatas.groupAlert = {state = false, type = nil};

	if getTickCount() - renderDatas.lastTick <= 2000 and not renderDatas.opened then
		exports.cr_infobox:addBox("warning", "Csak 2 másodpercenként nyithatod meg a dashboardot");

		cancelEvent();
		return false;
	end

	renderDatas.opened = not renderDatas.opened;

	--showChat(not renderDatas.opened);
	--setElementData(localPlayer, "hudVisible", not renderDatas.opened);

	if renderDatas.opened then
        exports.cr_faction:closeFactionPanel();

        if dashElement == localPlayer then
            triggerServerEvent("server->getFactionDatas", localPlayer, true)
        end
        
        if getElementData(dashElement, "char >> groupId") > 0 then
            renderDatas.myGroupId = getElementData(dashElement, "char >> groupId");

            triggerServerEvent("group->GetData", localPlayer, localPlayer, renderDatas.myGroupId);

            for key, value in pairs(getElementsByType("player")) do
                if value ~= dashElement and (getElementData(value, "char >> groupId") or 0) > 0 then
                    if getElementData(value, "char >> groupId") == (getElementData(dashElement, "char >> groupId") or 0) then
                        renderDatas.myGroup[value] = getElementData(value, "char >> name"):gsub("_", " ");
                    else
                        if renderDatas.myGroup[value] then
                            renderDatas.myGroup[value] = nil;
                        end
                    end
                end
            end
        else
            renderDatas.myGroupId = 0;
            renderDatas.myGroup = {};
        end
        
		renderDatas.lastTick = getTickCount();
		renderDatas.start = getTickCount();

		renderDatas.page = tonumber(page) and page or 1;

		-->> Save interface position
        renderDatas.screenDatas = {chat = exports["cr_custom-chat"]:isChatVisible(), hud = getElementData(localPlayer, "hudVisible"), keysDenied = getElementData(localPlayer, "keysDenied")};
		exports["cr_custom-chat"]:showChat(false);
		setElementData(localPlayer, "hudVisible", false);
		setElementData(localPlayer, "keysDenied", true);
        
        -->> Player infos
		getPlayerInformations();

		-->> Available admins
		getAvailableAdmins();

		-->> Owned vehicles
		getPlayerVehicles();

		-->> Owned interiors
		getPlayerInteriors();
	else
		exports["cr_custom-chat"]:showChat(renderDatas.screenDatas.chat);
		setElementData(localPlayer, "hudVisible", renderDatas.screenDatas.hud);
		setElementData(localPlayer, "keysDenied", renderDatas.screenDatas.keysDenied);

		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('health', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('armor', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('food', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('drink', 0);")
	end
end

function closeDashboard()
    if renderDatas.opened then
        renderDatas.open = false;

        exports["cr_custom-chat"]:showChat(renderDatas.screenDatas.chat);
		setElementData(localPlayer, "hudVisible", renderDatas.screenDatas.hud);
		setElementData(localPlayer, "keysDenied", renderDatas.screenDatas.keysDenied);

		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('health', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('armor', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('food', 0);");
		executeBrowserJavascript(renderDatas.circleBrowser, "setProgress('drink', 0);")
    end
end

addEventHandler("onClientElementDataChange", root, function(data, old)
	if source == localPlayer and data == "loggedIn" and getElementData(localPlayer, data) then
		loadGameSettings();
	end

	if source == dashElement and data == "char >> groupId" and getElementData(dashElement, data) == 0 then
		renderDatas.myGroupId = getElementData(dashElement, data);

		renderDatas.myGroup = {};
	end

	if source == dashElement and data == "char >> groupId" and getElementData(dashElement, data) > 0 then
		renderDatas.myGroupId = getElementData(dashElement, data);

		triggerServerEvent("group->GetData", localPlayer, localPlayer, renderDatas.myGroupId);

		for key, value in pairs(getElementsByType("player")) do
			if value ~= dashElement and (getElementData(value, "char >> groupId") or 0) > 0 then
				if getElementData(value, "char >> groupId") == (getElementData(dashElement, "char >> groupId") or 0) then
					renderDatas.myGroup[value] = getElementData(value, "char >> name"):gsub("_", " ");
				else
					if renderDatas.myGroup[value] then
						renderDatas.myGroup[value] = nil;
					end
				end
			end
		end
	end

	if source ~= dashElement and data == "char >> groupId" and getElementData(source, data) > 0 and getElementData(source, data) == getElementData(dashElement, data) then
		renderDatas.myGroup[source] = getElementData(source, "char >> name"):gsub("_", " ");
	end

	if renderDatas.myGroup[source] and data == "char >> groupId" and getElementData(source, data) ~= getElementData(dashElement, data) then
		renderDatas.myGroup[source] = nil;
	end
end);

addEvent("group->CallbackData", true);
addEventHandler("group->CallbackData", root, function(table)
	renderDatas.myGroupDatas = table;
end);

addEvent("group->invite", true);
addEventHandler("group->invite", root, function(table)
	inviteGroupDatas = table;
    oldStateOpenedInvite = renderDatas.opened;

    renderDatas.opened = false;
    renderDatas.groupAlert = {state = true, type = "invite"};
end);

addEventHandler("onClientPlayerQuit", root, function()
	if renderDatas.myGroup[source] then
		renderDatas.myGroup[source] = nil;
	end
end);

addEventHandler("onClientResourceStart", resourceRoot, function()
	loadGameSettings();

	if (getElementData(dashElement, "char >> groupId") or 0) > 0 then
		renderDatas.myGroupId = getElementData(dashElement, "char >> groupId");

		triggerServerEvent("group->GetData", localPlayer, localPlayer, renderDatas.myGroupId);

		for key, value in pairs(getElementsByType("player")) do
			if value ~= dashElement and (getElementData(value, "char >> groupId") or 0) > 0 then
				if getElementData(value, "char >> groupId") == getElementData(dashElement, "char >> groupId") then
					renderDatas.myGroup[value] = getElementData(value, "char >> name"):gsub("_", " ");
				end
			end
		end
	end
end);

addEventHandler("onClientResourceStart", root, function(resource)
    if resource == getResourceFromName("cr_radar") then
        setTimer(loadGameSettings, 500, 1);
    end
end);

addEventHandler("onClientRender", root, function()
	if renderDatas.slotBuy.state then
		if renderDatas.shader then
			dxUpdateScreenSource(renderDatas.screenSource);

			dxSetShaderValue(renderDatas.shader, "ScreenSource", renderDatas.screenSource);
			dxSetShaderValue(renderDatas.shader, "BlurStrength", 5);
			dxSetShaderValue(renderDatas.shader, "UVSize", screenW, screenH);

			dxDrawImage(-5, -5, screenW + 10, screenH + 10, renderDatas.shader);
		end

		dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 80, 400, 160, colors.bg);

		dxDrawText("Biztosan megveszel egy " .. (renderDatas.slotBuy.type == "vehicle" and "jármű" or "interior") .. " slotot\n" .. colors.orangehex .. " 100 Prémium pontért #ffffffcserébe?", screenW / 2 - 200, screenH / 2 - 80, screenW / 2 + 200, screenH / 2 + 25, colors.white, 1, getFont("Rubik-Regular", 13), "center", "center", false, false, false, true);

		dxDrawButton(screenW / 2 - 195, screenH / 2 + 25, 190, 50, colors.hover, "Megvétel", "Megvétel", getFont("Rubik-Regular", 12));
		dxDrawButton(screenW / 2 + 5, screenH / 2 + 25, 190, 50, colors.cancel, "Mégse", "Mégse", getFont("Rubik-Regular", 12));
	elseif renderDatas.groupAlert.state then
		if renderDatas.shader then
            if renderDatas.groupAlert.type ~= "invite" or oldStateOpenedInvite then
                dxUpdateScreenSource(renderDatas.screenSource);

                dxSetShaderValue(renderDatas.shader, "ScreenSource", renderDatas.screenSource);
                dxSetShaderValue(renderDatas.shader, "BlurStrength", 5);
                dxSetShaderValue(renderDatas.shader, "UVSize", screenW, screenH);

                dxDrawImage(-5, -5, screenW + 10, screenH + 10, renderDatas.shader);
            end
		end

		if renderDatas.groupAlert.type == "addmember" then
			dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 80, 400, 160, colors.bg);

			dxDrawText("Add meg a játékos nevét", 0, screenH / 2 - 80, screenW, screenH / 2 - 45, colors.white, 1, getFont("Rubik-Regular", 12), "center", "center");

			createEdit("addmemberBox", screenW / 2 - 195, screenH / 2 - 45, 390, 60, "Játékos neve", getFont("Rubik-Regular", 12), 35);

			dxDrawButton(screenW / 2 - 195, screenH / 2 + 25, 190, 50, colors.hover, "Felvétel", "Felvétel", getFont("Rubik-Regular", 12));
			dxDrawButton(screenW / 2 + 5, screenH / 2 + 25, 190, 50, colors.cancel, "Mégse", "Mégse", getFont("Rubik-Regular", 12));
		end

		if renderDatas.groupAlert.type == "kickmember" then
			dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 300, 400, 600, colors.bg);

			local index = 0;
			for key, value in pairs(renderDatas.myGroupDatas["members"]) do
				if value["charId"] ~= renderDatas.myAccountId then
					local forY = screenH / 2 - 300 + 5 + index * 30;

					dxDrawRectangle(screenW / 2 - 195, forY, 390, 25, colors.slot);
					dxDrawText(value["charName"], screenW / 2 - 190, forY, 0, forY + 25, colors.white, 1, getFont("Rubik-Regular", 10), "left", "center");
				
					dxDrawButton(screenW / 2 + 92, forY + 2, 100, 21, colors.second, "Kirúgás", "Kirúgás", getFont("Rubik-Regular", 9));

					index = index + 1;
				end
			end

			dxDrawButton(screenW / 2 - 195, screenH / 2 + 300 - 55, 390, 50, colors.cancel, "Mégse", "Mégse", getFont("Rubik-Regular", 12));
		end

		if renderDatas.groupAlert.type == "rename" then
			dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 80, 400, 160, colors.bg);

			dxDrawText("Add meg a csoportod új nevét", 0, screenH / 2 - 80, screenW, screenH / 2 - 45, colors.white, 1, getFont("Rubik-Regular", 12), "center", "center");

			createEdit("renameBox", screenW / 2 - 195, screenH / 2 - 45, 390, 60, "Csoport neve", getFont("Rubik-Regular", 12), 35);

			dxDrawButton(screenW / 2 - 195, screenH / 2 + 25, 190, 50, colors.hover, "Átnevezés", "Átnevezés", getFont("Rubik-Regular", 12));
			dxDrawButton(screenW / 2 + 5, screenH / 2 + 25, 190, 50, colors.cancel, "Mégse", "Mégse", getFont("Rubik-Regular", 12));
		end

		if renderDatas.groupAlert.type == "delete" then
			dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 80, 400, 160, colors.bg);

			dxDrawText("Biztosan törölni szeretnéd a\n" .. colors.orangehex .. renderDatas.myGroupDatas["name"] .. "\n#ffffffnevű csoportodat?", screenW / 2 - 200, screenH / 2 - 80, screenW / 2 + 200, screenH / 2 + 25, colors.white, 1, getFont("Rubik-Regular", 13), "center", "center", false, false, false, true);

			dxDrawButton(screenW / 2 - 195, screenH / 2 + 25, 190, 50, colors.hover, "Törlés", "Törlés", getFont("Rubik-Regular", 12));
			dxDrawButton(screenW / 2 + 5, screenH / 2 + 25, 190, 50, colors.cancel, "Mégse", "Mégse", getFont("Rubik-Regular", 12));
		end
            
        if renderDatas.groupAlert.type == "invite" then
			dxDrawRectangle(screenW / 2 - 200, screenH / 2 - 80, 400, 160, colors.bg);

			dxDrawText("Meghívták a(z)\n" .. colors.orangehex .. inviteGroupDatas["name"] .. "\n#ffffffnevű csoportba!", screenW / 2 - 200, screenH / 2 - 80, screenW / 2 + 200, screenH / 2 + 25, colors.white, 1, getFont("Rubik-Regular", 13), "center", "center", false, false, false, true);

			dxDrawButton(screenW / 2 - 195, screenH / 2 + 25, 190, 50, colors.hover, "Elfogadás", "Elfogadás", getFont("Rubik-Regular", 12));
			dxDrawButton(screenW / 2 + 5, screenH / 2 + 25, 190, 50, colors.cancel, "Elutasítás", "Elutasítás", getFont("Rubik-Regular", 12));
		end
	else
		if not renderDatas.opened then
			if not getElementData(localPlayer, "hudVisible") then return end

			-->> DRAW PLAYER GROUP
			local _, x, y, w, h = exports.cr_interface:getDetails("groupinfo");

			local key = 0;
			for player, name in pairs(renderDatas.myGroup) do
				local forY = y + key * 35;

				dxDrawText(name .. " (" .. math.floor(player.health + 0.5) .. "%)\n└ (" .. getZoneName(player.position) .. ")", x + 1, forY + 1, 0, 0, colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "top");
				dxDrawText(colors.orangehex .. name .. " #ffffff(" .. math.floor(player.health + 0.5) .. "%)\n└ (" .. getZoneName(player.position) .. ")", x, forY, 0, 0, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "top", false, false, false, true);

				key = key + 1;
			end
		end
	end

	if renderDatas.opened then
		dxDrawRectangle(renderDatas.left, renderDatas.top, renderDatas.width, renderDatas.height, colors.bg);

		dxDrawImage(screenW / 2 - 248 / 4, renderDatas.top + renderDatas.height + 10, 248 / 2, 175 / 2, "files/images/logo.png");

		-->> MENU
		renderDatas.now = getTickCount();
		renderDatas.elapsed = renderDatas.now - renderDatas.start;
        renderDatas.duration = 1000;
        renderDatas.progress = renderDatas.elapsed / renderDatas.duration;

        local leftX, rightX = interpolateBetween(-(renderDatas.width / 2 - 248 / 4 - 10), screenW + (renderDatas.width / 2 - 248 / 4 - 10), 0, renderDatas.left, screenW / 2 + 248 / 4 + 10, 0, renderDatas.progress, "OutBack");

		dxDrawRectangle(leftX, renderDatas.top + renderDatas.height + 10 + 175 / 8, renderDatas.width / 2 - 248 / 4 - 10, 175 / 4, colors.bg);

		dxDrawRectangle(rightX, renderDatas.top + renderDatas.height + 10 + 175 / 8, renderDatas.width / 2 - 248 / 4 - 10, 175 / 4, colors.bg);

		for key = 1, 3 do
			local forX = leftX + (key - 1) * ((renderDatas.width / 2 - 248 / 4 - 10) / 3);

			local color = colors.white;
			if isCursorHover(forX, renderDatas.top + renderDatas.height + 10 + 175 / 8, (renderDatas.width / 2 - 248 / 4 - 10) / 3, 175 / 4) or renderDatas.page == key then
				color = colors.hover;
			end
			dxDrawText(renderDatas.menus[key], forX, renderDatas.top + renderDatas.height + 13 + 175 / 8, forX + ((renderDatas.width / 2 - 248 / 4 - 10) / 3), renderDatas.top + renderDatas.height + 10 + 175 / 8 + 175 / 4, color, 1, getFont("AwesomeFont2", 11), "center", "center");
		end

		for key = 4, 6 do
			local forX = rightX + (key - 4) * ((renderDatas.width / 2 - 248 / 4 - 10) / 3);

			local color = colors.white;
			if isCursorHover(forX, renderDatas.top + renderDatas.height + 10 + 175 / 8, (renderDatas.width / 2 - 248 / 4 - 10) / 3, 175 / 4) or renderDatas.page == key then
				color = colors.hover;
			end
			dxDrawText(renderDatas.menus[key], forX, renderDatas.top + renderDatas.height + 13 + 175 / 8, forX + ((renderDatas.width / 2 - 248 / 4 - 10) / 3), renderDatas.top + renderDatas.height + 10 + 175 / 8 + 175 / 4, color, 1, getFont("AwesomeFont2", 11), "center", "center");
		end

		if renderDatas.page == 1 then
			-->> NAME AND INFOS
			dxDrawText(exports.cr_admin:getAdminName(dashElement), renderDatas.left + 20, renderDatas.top + 20, 0, 0, colors.white, 1, getFont("Azzardo-Regular", 18 * renderDatas.dxDrawMultipler));

			dxDrawText(renderDatas.playerData[#renderDatas.playerData], renderDatas.left + 20, renderDatas.top + dxGetFontHeight(1, getFont("Azzardo-Regular", 18 * renderDatas.dxDrawMultipler)) + 20, 0, 0, colors.white, 1, getFont("AwesomeFont2", 11 * renderDatas.dxDrawMultipler), "left", "top", false, false, false, true);

			-->> SKIN IMAGE
			imgH = renderDatas.height - 60 - dxGetFontHeight(1, getFont("Azzardo-Regular", 18 * renderDatas.dxDrawMultipler)) - dxGetFontHeight(1, getFont("AwesomeFont2", 11 * renderDatas.dxDrawMultipler));

			dxDrawRectangle(renderDatas.left + 20, renderDatas.top + renderDatas.height - 20 - imgH, imgH * (345 / 689), imgH, isCursorHover(renderDatas.left + 20, renderDatas.top + renderDatas.height - 20 - imgH, imgH * (345 / 689), imgH) and colors.hover or colors.slot);
			--dxDrawImage(renderDatas.left + 22, renderDatas.top + renderDatas.height - 20 - imgH + 2, imgH * (345 / 689) - 4, imgH - 4, "files/skins/0.jpg");

			-->> DETAILED INFOS
			local startX = renderDatas.left + 40 + imgH * (345 / 689);
			local width = (renderDatas.width - (startX - renderDatas.left)) / 2 - 20;

			dxDrawRectangle(startX, renderDatas.top + renderDatas.height - 20 - imgH, width, imgH, colors.bg);

			for key = 1, 10 do
				local forY = renderDatas.top + renderDatas.height - 20 - imgH + (key - 1) * (imgH / 14 + 2) + 2;

				dxDrawRectangle(startX + 2, forY, width - 4, imgH / 14, colors.slot);
				dxDrawText(renderDatas.playerData[key], startX + 7, forY, startX + width - 2, forY + imgH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");

				if isCursorHover(startX + 2, forY, width - 4, imgH / 14) then
					dxDrawRectangle(startX + 2, forY, width - 4, imgH / 14, colors.hover);
					dxDrawText(renderDatas.playerData[key], startX + 7, forY, startX + width - 2, forY + imgH / 14, colors.black, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");
				end

				if key == 10 then
					dxDrawRectangle(startX + 2, forY + imgH / 14 + 2, width - 4, 3 * imgH / 14 + 5, colors.slot);
					dxDrawText(renderDatas.playerData[11], startX + 7, forY + imgH / 14 + 7, startX + width - 7, forY + imgH / 14 + 3 * imgH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "top", false, true);

					if isCursorHover(startX + 2, forY + imgH / 14 + 2, width - 4, 3 * imgH / 14 + 5) then
						dxDrawRectangle(startX + 2, forY + imgH / 14 + 2, width - 4, 3 * imgH / 14 + 5, colors.hover);
						dxDrawText(renderDatas.playerData[11], startX + 7, forY + imgH / 14 + 7, startX + width - 7, forY + imgH / 14 + 3 * imgH / 14, colors.black, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "top", false, true);
					end
				end
			end

			-->> FACTION INFOS
			startX = startX + width + 20;

			dxDrawRectangle(startX, renderDatas.top + renderDatas.height - 20 - imgH, width, imgH / 14 * 3 + 4, colors.bg);

			if renderDatas.factionInfos.count == 0 then
				dxDrawText("Nem vagy egy frakció tagja sem!", startX, renderDatas.top + renderDatas.height - 20 - imgH, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14 * 3, colors.cancel, 1, getFont("Rubik-Regular", 12 * renderDatas.dxDrawMultipler), "center", "center", false, true);
			else
				dxDrawText(renderDatas.factionInfos.datas[renderDatas.factionInfos.selected].factionName, startX, renderDatas.top + renderDatas.height - 20 - imgH, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");

				if renderDatas.factionInfos.count > 1 then
					if renderDatas.factionInfos.selected > 1 then
						dxDrawText("", startX + 8, renderDatas.top + renderDatas.height - 20 - imgH, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, colors.white, 1, getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler), "left", "center");

						if isCursorHover(startX, renderDatas.top + renderDatas.height - 20 - imgH, imgH / 14, imgH / 14) then
							dxDrawText("", startX + 8, renderDatas.top + renderDatas.height - 20 - imgH, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, colors.second, 1, getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler), "left", "center");
						end
					end

					if renderDatas.factionInfos.selected < renderDatas.factionInfos.count then
						dxDrawText("", startX, renderDatas.top + renderDatas.height - 20 - imgH, startX + width - 8, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, colors.white, 1, getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler), "right", "center");

						if isCursorHover(startX + width - imgH / 14, renderDatas.top + renderDatas.height - 20 - imgH, imgH / 14, imgH / 14) then
							dxDrawText("", startX, renderDatas.top + renderDatas.height - 20 - imgH, startX + width - 8, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, colors.second, 1, getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler), "right", "center");
						end
					end
				end

				dxDrawRectangle(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, width - 4, imgH / 14, colors.slot);
				dxDrawText(renderDatas.factionInfos.datas[renderDatas.factionInfos.selected].rank, startX, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14), colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");

				if isCursorHover(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, width - 4, imgH / 14) then
					dxDrawRectangle(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, width - 4, imgH / 14, colors.hover);
					dxDrawText(renderDatas.factionInfos.datas[renderDatas.factionInfos.selected].rank, startX, renderDatas.top + renderDatas.height - 20 - imgH + imgH / 14, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14), colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");
				end

				dxDrawRectangle(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14) + 2, width - 4, imgH / 14, colors.slot);
				dxDrawText(renderDatas.factionInfos.datas[renderDatas.factionInfos.selected].payment, startX, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14) + 2, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + 3 * (imgH / 14) + 2, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");

				if isCursorHover(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14) + 2, width - 4, imgH / 14) then
					dxDrawRectangle(startX + 2, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14) + 2, width - 4, imgH / 14, colors.hover);
					dxDrawText(renderDatas.factionInfos.datas[renderDatas.factionInfos.selected].payment, startX, renderDatas.top + renderDatas.height - 20 - imgH + 2 * (imgH / 14) + 2, startX + width, renderDatas.top + renderDatas.height - 20 - imgH + 3 * (imgH / 14) + 2, colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");
				end
			end

			-->> CHARACTER DATAS HTML (hp, armor etc..)
			if renderDatas.circleBrowserReady then
				dxDrawImage(startX, renderDatas.top + renderDatas.height - 20 - imgH + 4 * (imgH / 14) + 2, width * 1.25, (150 / 600) * width * 1.25, renderDatas.circleBrowser);
			end
		end

		if renderDatas.page == 2 then
			local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
			local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

			-->> DRAW VEHICLES
			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
			dxDrawText("Saját járművek", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");

			dxDrawButton(startX + 5, startY + 5, boxW / 4, boxH / 14 - 10, colors.second, "Slot vásárlás", "Slot vásárlás ", getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler));

			dxDrawText("Slot: " .. colors.orangehex .. #renderDatas.myVehicles.vehs .. "/" .. renderDatas.myVehicles.slot, startX, startY, startX + boxW - 7, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "right", "center", false, false, false, true);

			if #renderDatas.myVehicles.vehs == 0 then
				dxDrawText("Nincs egyetlen járműved sem!", startX, startY, startX + boxW, startY + boxH, colors.cancel, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center", false, true)
			else
				renderDatas.myVehicles.scroll.last = renderDatas.myVehicles.scroll.current + renderDatas.myVehicles.scroll.max - 1;
				for key, value in pairs(renderDatas.myVehicles.vehs) do
					if key >= renderDatas.myVehicles.scroll.current and key <= renderDatas.myVehicles.scroll.last then
						key = key - renderDatas.myVehicles.scroll.current + 1;
						local forY = startY + key * (boxH / 14 + 2);

						dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);
						dxDrawText(value.locked, startX + 7, forY, startX + 47, forY + boxH / 14, colors.white, 1, getFont("AwesomeFont2", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
						dxDrawText(value.name, startX + 47, forY, startX + boxW, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);

						if isCursorHover(startX + 2, forY, boxW - 4, boxH / 14) or renderDatas.myVehicles.selected - renderDatas.myVehicles.scroll.current + 1 == key then
							dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.hover);
							dxDrawText(value.locked, startX + 7, forY, startX + 47, forY + boxH / 14, colors.white, 1, getFont("AwesomeFont2", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
							dxDrawText(value.name, startX + 47, forY, startX + boxW, forY + boxH / 14, colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);
						end
					end
				end

				local infoH = boxH - (renderDatas.myVehicles.scroll.max + 1) * (boxH / 14 + 2) - 6;

				dxDrawRectangle(startX + 2, startY + (renderDatas.myVehicles.scroll.max + 1) * (boxH / 14 + 2) + 4, boxW - 4, infoH, colors.slot);

				local veh = renderDatas.myVehicles.vehs[renderDatas.myVehicles.selected];
				dxDrawText(veh.hp .. "\nPozíció: " .. veh.position .. "\nKilóméteróra állása: " .. veh.odometer .. "\n#ffffffMeg majd a tuningok", startX, startY + (renderDatas.myVehicles.scroll.max + 1) * (boxH / 14 + 2), startX + boxW, startY + (renderDatas.myVehicles.scroll.max + 1) * (boxH / 14 + 2) + infoH, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
			end

			-->> DRAW INTERIORS
			startX = startX + boxW + 20;

			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
			dxDrawText("Saját ingatlanok", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");
		
			dxDrawButton(startX + 5, startY + 5, boxW / 4, boxH / 14 - 10, colors.second, "Slot vásárlás", "Slot vásárlás ", getFont("AwesomeFont2", 8 * renderDatas.dxDrawMultipler));

			dxDrawText("Slot: " .. colors.orangehex .. #renderDatas.myInteriors.ints .. "/" .. renderDatas.myInteriors.slot, startX, startY, startX + boxW - 7, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "right", "center", false, false, false, true);

			if #renderDatas.myInteriors.ints == 0 then
				dxDrawText("Nincs egyetlen ingatlanod sem!", startX, startY, startX + boxW, startY + boxH, colors.cancel, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center", false, true)
			else
				renderDatas.myInteriors.scroll.last = renderDatas.myInteriors.scroll.current + renderDatas.myInteriors.scroll.max - 1;
				for key, value in pairs(renderDatas.myInteriors.ints) do
					if key >= renderDatas.myInteriors.scroll.current and key <= renderDatas.myInteriors.scroll.last then
						key = key - renderDatas.myInteriors.scroll.current + 1;
						local forY = startY + 2 + key * (boxH / 14 + 2);

						dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);
						dxDrawText(value.locked, startX + 7, forY, startX + 47, forY + boxH / 14, colors.white, 1, getFont("AwesomeFont2", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
						dxDrawText(value.name, startX + 47, forY, startX + boxW, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);

						if isCursorHover(startX + 2, forY, boxW - 4, boxH / 14) or renderDatas.myInteriors.selected - renderDatas.myInteriors.scroll.current + 1 == key then
							dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.hover);
							dxDrawText(value.locked, startX + 7, forY, startX + 47, forY + boxH / 14, colors.white, 1, getFont("AwesomeFont2", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
							dxDrawText(value.name, startX + 47, forY, startX + boxW, forY + boxH / 14, colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);
						end
					end
				end

				infoH = boxH - (renderDatas.myInteriors.scroll.max + 1) * (boxH / 14 + 2) - 6;

				dxDrawRectangle(startX + 2, startY + (renderDatas.myInteriors.scroll.max + 1) * (boxH / 14 + 2) + 4, boxW - 4, infoH, colors.slot);
				
				local int = renderDatas.myInteriors.ints[renderDatas.myInteriors.selected];
				dxDrawText("Pozíció: " .. colors.orangehex .. int.position.area .. " (" .. int.position.city .. ")", startX, startY + (renderDatas.myInteriors.scroll.max + 1) * (boxH / 14 + 2), startX + boxW, startY + (renderDatas.myInteriors.scroll.max + 1) * (boxH / 14 + 2) + infoH, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
			end
		end

		if renderDatas.page == 3 then
			local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
			local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

			-->> SHADER SETTINGS
			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
			dxDrawText("Grafikai beállítások", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");
                
            if getKeyState("mouse1") then
                local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
                local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

                local forY = startY + 8 * (boxH / 14 + 2);

                if isCursorHover(startX + boxW / 2 - 10, forY + 5, boxW / 2, boxH / 14 - 10) and dashElement == localPlayer then
                    local cx, cy = exports.cr_core:getCursorPosition()

                    local distance = math.floor((cx - startX) / (boxW/2) * 3000 - 2800);
                    if distance <= 100 then
                    	distance = 100;
                    end

                    if distance >= 3000 then
                    	distance = 3000;
                    end

                    if distance ~= renderDatas.shaderSettings.json["clipdist"][2] then
                        saveSettings();
                        renderDatas.shaderSettings.json["clipdist"][2] = distance;

                        setFarClipDistance(renderDatas.shaderSettings.json["clipdist"][2]);
                    end
                end
            end    

			local index = 1;
			for key, value in pairs(renderDatas.shaderSettings.json) do
				if key ~= "clipdist" and key ~= "palette" then
					local forY = startY + index * (boxH / 14 + 2);

					dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);

					dxDrawText(value[1], startX + 7, forY, startX + boxW - 7, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");

					dxDrawRectangle(startX + boxW - 65, forY + 5, 55, boxH / 14 - 10, colors.bg);
					if value[2] then
						dxDrawButton(startX + boxW - 65 + 20, forY + 7, 33, boxH / 14 - 14, colors.hover, "", "Ki", getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler));
					else
						dxDrawButton(startX + boxW - 65 + 2, forY + 7, 33, boxH / 14 - 14, colors.cancel, "", "Be", getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler));
					end

					index = index + 1;
				end
			end

			local forY = startY + 7 * (boxH / 14 + 2);

			-->> PALETTE
			dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);

			dxDrawText(renderDatas.shaderSettings.json["palette"][1], startX + 7, forY, startX + boxW - 7, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");

			dxDrawRectangle(startX + boxW / 2 - 10, forY + 5, boxW / 2, boxH / 14 - 10, colors.bg);
			dxDrawButton(startX + boxW / 2 - 10 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14, colors.hover, "", "", getFont("AwesomeFont2", 7 * renderDatas.dxDrawMultipler));
			dxDrawButton(startX + boxW - boxH / 14 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14, colors.hover, "", "", getFont("AwesomeFont2", 7 * renderDatas.dxDrawMultipler));

			if renderDatas.shaderSettings.json["palette"][2] then
				dxDrawText("Paletta " .. renderDatas.shaderSettings.json["palette"][2], startX + boxW / 2 - 10, forY, startX + boxW - 10, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "center", "center");
			else
				dxDrawText("Paletta kikapcsolva", startX + boxW / 2 - 10, forY, startX + boxW - 10, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "center", "center");
			end

			-->> CLIP DISTANCE
			forY = forY + boxH / 14 + 2;

			dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);

			dxDrawText(renderDatas.shaderSettings.json["clipdist"][1], startX + 7, forY, startX + boxW - 7, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");

			dxDrawRectangle(startX + boxW / 2 - 10, forY + 5, boxW / 2, boxH / 14 - 10, colors.bg);
			dxDrawRectangle(startX + boxW / 2 - 10 + 2, forY + 7, (boxW / 2 - 4) / 3000 * renderDatas.shaderSettings.json["clipdist"][2], boxH / 14 - 14, colors.hover);
			dxDrawText(renderDatas.shaderSettings.json["clipdist"][2] .. " yard", startX + boxW / 2 - 10, forY, startX + boxW - 10, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "center", "center");
		
			-->> GAME SETTINGS
			startX = startX + boxW + 20;

			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
			dxDrawText("Játék beállítások", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");
		
			index = 1;
			for key, value in orderedPairs(renderDatas.gameSettings.json) do
				local forY = startY + index * (boxH / 14 + 2);

				dxDrawRectangle(startX + 2, forY, boxW - 4, boxH / 14, colors.slot);

				dxDrawText(value[1], startX + 7, forY, startX + boxW - 7, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "left", "center");

				if key == "3dblip" then
					dxDrawRectangle(startX + boxW - 65, forY + 5, 55, boxH / 14 - 10, colors.bg);
					if value[2] then
						dxDrawButton(startX + boxW - 65 + 20, forY + 7, 33, boxH / 14 - 14, colors.hover, "", "Ki", getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler));
					else
						dxDrawButton(startX + boxW - 65 + 2, forY + 7, 33, boxH / 14 - 14, colors.cancel, "", "Be", getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler));
					end
				else
					dxDrawRectangle(startX + boxW / 2 - 10, forY + 5, boxW / 2, boxH / 14 - 10, colors.bg);
					dxDrawButton(startX + boxW / 2 - 10 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14, colors.hover, "", "", getFont("AwesomeFont2", 7 * renderDatas.dxDrawMultipler));
					dxDrawButton(startX + boxW - boxH / 14 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14, colors.hover, "", "", getFont("AwesomeFont2", 7 * renderDatas.dxDrawMultipler));

					if value[2] then
						dxDrawText(value[1] .. " " .. (key == "chatstyle" and findKey(value[4], value[2]) - 1 or findKey(value[4], value[2])), startX + boxW / 2 - 10, forY, startX + boxW - 10, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "center", "center");
					else
						dxDrawText(value[1] .. " kikapcsolva", startX + boxW / 2 - 10, forY, startX + boxW - 10, forY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "center", "center");
					end
				end

				index = index + 1;
			end
		end

		if renderDatas.page == 4 then
			local boxW, boxH = renderDatas.width / 3 - 30, renderDatas.height - 40;
			local startX, startY = renderDatas.left + renderDatas.width - 20 - boxW, renderDatas.top + 20;
			local forH = ((boxH - 2) / 9) - 2;

			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);

			for key, value in pairs(renderDatas.availableAdmins.table) do
				local forY = startY + 2 + (key - 1) * (forH + 2);

				dxDrawRectangle(startX + 2, forY, boxW - 4, forH, colors.slot);
				dxDrawText(value.name .. "\n(" .. #renderDatas.availableAdmins.table[key].admins .. " elérhető)", startX, forY, startX + boxW, forY + forH, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");

				if key == renderDatas.availableAdmins.selected or isCursorHover(startX + 2, forY, boxW - 4, forH) then
					dxDrawRectangle(startX + 2, forY, boxW - 4, forH, colors.hover);
					dxDrawText(value.name .. "\n(" .. #renderDatas.availableAdmins.table[key].admins .. " elérhető)", startX, forY, startX + boxW, forY + forH, colors.black, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center");
				end
			end

			boxW = renderDatas.width / 3 * 2 - 30;
			startX = renderDatas.left + 20;
			forH = ((boxH - 2) / 13) - 2;

			dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);

			if #renderDatas.availableAdmins.table[renderDatas.availableAdmins.selected].admins == 0 then
				dxDrawText("Nincs egy elérhető admin sem!", startX, startY, startX + boxW, startY + boxH, colors.cancel, 1, getFont("Rubik-Regular", 11 * renderDatas.dxDrawMultipler), "center", "center", false, false, true);
			else
				for key, value in pairs(renderDatas.availableAdmins.table[renderDatas.availableAdmins.selected].admins) do
					local forY = startY + 2 + (key - 1) * (forH + 2);

					dxDrawRectangle(startX + 2, forY, boxW - 4, forH, colors.slot);
					dxDrawText(value.leftText, startX + 7, forY, startX + boxW, forY + forH, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);
					dxDrawText(value.rightText, startX, forY, startX + boxW - 7, forY + forH, colors.white, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "right", "center", false, false, false, true);
				
					if isCursorHover(startX + 2, forY, boxW - 4, forH) then
						dxDrawRectangle(startX + 2, forY, boxW - 4, forH, colors.hover);
						dxDrawText(value.leftText, startX + 7, forY, startX + boxW, forY + forH, colors.black, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "left", "center", false, false, false, true);
						dxDrawText(value.rightText, startX, forY, startX + boxW - 7, forY + forH, colors.black, 1, getFont("Rubik-Regular", 8 * renderDatas.dxDrawMultipler), "right", "center", false, false, false, true);
					end
				end
			end
		end

		if renderDatas.page == 6 then
			-->> GROUP INFOS
			if renderDatas.myGroupId == 0 then
				dxDrawButton(renderDatas.left + renderDatas.width / 2 - renderDatas.width * 0.2, renderDatas.top + renderDatas.height / 2 - renderDatas.height * 0.05, renderDatas.width * 0.4, renderDatas.height * 0.1, colors.second, "Csoport létrehozása", "Csoport létrehozása", getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler));
			else
				local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
				local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

				dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
				dxDrawText("Csoport információk", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");
			
				dxDrawText("Csoport neve: " .. colors.orangehex .. renderDatas.myGroupDatas["name"] .. "\n#ffffffCsoport azonosító: " .. colors.orangehex .. renderDatas.myGroupDatas["id"] .. "\n#ffffffCsoport vezető: " .. colors.orangehex .. renderDatas.myGroupDatas["ownername"] .. "\n#ffffffLétrehozva: " .. colors.orangehex .. (renderDatas.myGroupDatas["created"] or "") .. "\n#ffffffOnline tagok: " .. colors.orangehex .. countTable(renderDatas.myGroup) + 1, startX, startY, startX + boxW, startY + boxH, colors.white, 1, getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler), "center", "center", false, false, false, true);
			
				-->> GROUP OWNER FUNCTIONS
				startX = startX + boxW + 20;

				dxDrawRectangle(startX, startY, boxW, boxH, colors.bg);
				dxDrawText("Vezetői funkciók", startX, startY, startX + boxW, startY + boxH / 14, colors.white, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center");
			
				if renderDatas.myGroupDatas["owner"] ~= renderDatas.myAccountId then
					dxDrawText("Nem vagy a csoport vezetője, így nincs jogosultságod az oldal megtekintéséhez!", startX + 50, startY, startX + boxW - 50, startY + boxH, colors.cancel, 1, getFont("Rubik-Regular", 10 * renderDatas.dxDrawMultipler), "center", "center", false, true);
				else
					local buttonX = startX + boxW / 2 - boxW / 4;
					local buttonY = startY + boxH / 2 - (4 * (boxH / 7) + 3 * 30) / 2;
					local buttonH = boxH / 7;

					dxDrawButton(buttonX, buttonY, boxW / 2, boxH / 7, colors.hover, "Tag felvétele", "Tag felvétele", getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler));
					
					dxDrawButton(buttonX, buttonY + buttonH + 30, boxW / 2, buttonH, colors.cancel, "Tag eltávolítása", "Tag eltávolítása", getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler));

					dxDrawButton(buttonX, buttonY + (buttonH + 30) * 2, boxW / 2, buttonH, colors.second, "Csoport átnevezése", "Csoport átnevezése", getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler));
				
					dxDrawButton(buttonX, buttonY + (buttonH + 30) * 3, boxW / 2, buttonH, colors.cancel, "Csoport törlése", "Csoport törlése", getFont("Rubik-Regular", 9 * renderDatas.dxDrawMultipler));				
				end
			end
		end
	end
end);

addCommandHandler("dash", function()
	changeState(1, localPlayer);
end);

addCommandHandler("dashboard", function()
	changeState(1, localPlayer);
end);

addCommandHandler("stats", function(command, target)
    if not command or not target then
        outputChatBox(exports.cr_core:getServerSyntax(nil, "error") .. "/" .. command .. " [ID/Név]", 0, 0, 0, true);
        return false;
    end
    
    target = exports.cr_core:findPlayer(localPlayer, target);
    if target then
        if exports.cr_permission:hasPermission(localPlayer, "stats") then
	        changeState(1, target);
        end
    else
        outputChatBox(exports.cr_core:getServerSyntax(nil, "error") .. "Nincs találat a keresett játékosra", 0, 0, 0, true);
    end
end);


addEventHandler("onClientKey", root, function(button, pressed)
	if pressed and getElementData(localPlayer, "loggedIn") then
		if button == "home" then
			changeState(1, localPlayer);
			cancelEvent();
		end

		if button == "F7" then
			changeState(4, localPlayer);
		end

		if renderDatas.slotBuy.state then
			if isCursorHover(screenW / 2 - 195, screenH / 2 + 25, 190, 50) then
				if getElementData(localPlayer, "char >> premiumPoints") >= 100 then
                    if exports.cr_network:getNetworkStatus() then return end

					triggerServerEvent("dashboard->SlotBuy", localPlayer, localPlayer, renderDatas.slotBuy.type);
					exports.cr_infobox:addBox("success", "Sikeres slot vásárlás");

					setTimer(function()
						getPlayerVehicles();
						getPlayerInteriors();
						getPlayerInformations();
					end, 200, 1);
				else
					exports.cr_infobox:addBox("error", "Nincs elég Prémium pontod");
				end

				renderDatas.slotBuy = {state = false, type = nil};
				renderDatas.opened = true;
			end

			if isCursorHover(screenW / 2 + 5, screenH / 2 + 25, 190, 50) then
				renderDatas.slotBuy = {state = false, type = nil};
				renderDatas.opened = true;
			end
		elseif renderDatas.groupAlert.state then
			if renderDatas.groupAlert.type == "addmember" then
				if isCursorHover(screenW / 2 - 195, screenH / 2 + 25, 190, 50) then
					local player = exports.cr_core:findPlayer(localPlayer, getEditText("addmemberBox"));

					if isElement(player) then
						if getElementData(player, "char >> groupId") > 0 then
							exports.cr_infobox:addBox("error", "A játékos már tagja egy másik csoportnak");
						elseif getDistanceBetweenPoints3D(localPlayer.position, player.position) > 10  then
							exports.cr_infobox:addBox("error", "A játékos túl messze van tőled");
						elseif countTable(renderDatas.myGroupDatas["members"]) == 10 then
							exports.cr_infobox:addBox("error", "Nincs több szabad hely a csoportban");
						else
							--triggerServerEvent("group->AddPlayerToGroup", localPlayer, localPlayer, renderDatas.myGroupId, player);inviteGroupDatas
							triggerServerEvent("group->InvitePlayerToGroup", localPlayer, localPlayer, renderDatas.myGroupId, player);

							removeEdit("addmemberBox");
							exports.cr_infobox:addBox("success", "Sikeresen meghívtad " .. exports['cr_admin']:getAdminName(player) .. " játékost");

							renderDatas.groupAlert = {state = false, type = nil};
							renderDatas.opened = true;
						end
					else
						exports.cr_infobox:addBox("error", "Nem található ilyen játékos");
					end
				end

				if isCursorHover(screenW / 2 + 5, screenH / 2 + 25, 190, 50) then
					removeEdit("addmemberBox");

					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end
			end

			if renderDatas.groupAlert.type == "kickmember" then
				local index = 0;
				for key, value in pairs(renderDatas.myGroupDatas["members"]) do
					if value["charId"] ~= renderDatas.myAccountId then
						local forY = screenH / 2 - 300 + 5 + index * 30;

						if isCursorHover(screenW / 2 + 92, forY + 2, 100, 21) then
							local result = false;

							for _, player in pairs(getElementsByType("player")) do
								if (getElementData(player, "acc >> id") or 0) == value["charId"] then
									result = player;
									break;
								end
							end

							triggerServerEvent("group->RemovePlayerFromGroup", localPlayer, localPlayer, renderDatas.myGroupId, value["charId"], result);
							exports.cr_infobox:addBox("success", "Sikeresen eltávolítottad a játékost");
						end

						index = index + 1;
					end
				end

				if isCursorHover(screenW / 2 - 195, screenH / 2 + 300 - 55, 390, 50) then
					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end
			end

			if renderDatas.groupAlert.type == "rename" then
				if isCursorHover(screenW / 2 - 195, screenH / 2 + 25, 190, 50) then
					triggerServerEvent("group->RenameById", localPlayer, localPlayer, renderDatas.myGroupId, getEditText("renameBox"));

					removeEdit("renameBox");
					exports.cr_infobox:addBox("success", "Sikeresen átnevezted a csoportodat");

					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end

				if isCursorHover(screenW / 2 + 5, screenH / 2 + 25, 190, 50) then
					removeEdit("renameBox");

					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end
			end

			if renderDatas.groupAlert.type == "delete" then
				if isCursorHover(screenW / 2 - 195, screenH / 2 + 25, 190, 50) then
					triggerServerEvent("group->DeleteById", localPlayer, localPlayer, renderDatas.myGroupId);

					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end

				if isCursorHover(screenW / 2 + 5, screenH / 2 + 25, 190, 50) then
					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = true;
				end
			end
                
            if renderDatas.groupAlert.type == "invite" then
				if isCursorHover(screenW / 2 - 195, screenH / 2 + 25, 190, 50) then
					--triggerServerEvent("group->DeleteById", localPlayer, localPlayer, renderDatas.myGroupId);
                        
                    triggerServerEvent("group->AddPlayerToGroup", localPlayer, localPlayer, tonumber(inviteGroupDatas["id"]), localPlayer);    

					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = oldStateOpenedInvite;
				end

				if isCursorHover(screenW / 2 + 5, screenH / 2 + 25, 190, 50) then
					renderDatas.groupAlert = {state = false, type = nil};
					renderDatas.opened = oldStateOpenedInvite;
				end
			end    
		end

		if renderDatas.opened then
			if button == "mouse1" then
				for key = 1, 3 do
					local forX = renderDatas.left + (key - 1) * ((renderDatas.width / 2 - 248 / 4 - 10) / 3);

					if isCursorHover(forX, renderDatas.top + renderDatas.height + 10 + 175 / 8, (renderDatas.width / 2 - 248 / 4 - 10) / 3, 175 / 4) then
                        if dashElement == localPlayer or key < 3 then
						    renderDatas.page = key;
                        end
					end
				end

				for key = 4, 6 do
					local forX = screenW / 2 + 248 / 4 + 10 + (key - 4) * ((renderDatas.width / 2 - 248 / 4 - 10) / 3);

					if isCursorHover(forX, renderDatas.top + renderDatas.height + 10 + 175 / 8, (renderDatas.width / 2 - 248 / 4 - 10) / 3, 175 / 4) then
                        if dashElement == localPlayer or key > 5 then    
						    renderDatas.page = key;
                        end
					end
				end
			end

			if renderDatas.page == 1 then
				if button == "mouse1" then
					local startX = renderDatas.left + 40 + imgH * (345 / 689);
					local width = (renderDatas.width - (startX - renderDatas.left)) / 2 - 20;

					startX = startX + width + 20;

					if isCursorHover(startX, renderDatas.top + renderDatas.height - 20 - imgH, imgH / 14, imgH / 14) then
						if renderDatas.factionInfos.selected > 1 then
							renderDatas.factionInfos.selected = renderDatas.factionInfos.selected - 1;
						end
					end

					if isCursorHover(startX + width - imgH / 14, renderDatas.top + renderDatas.height - 20 - imgH, imgH / 14, imgH / 14) then
						if renderDatas.factionInfos.selected < renderDatas.factionInfos.count then
							renderDatas.factionInfos.selected = renderDatas.factionInfos.selected + 1;
						end
					end
				end
			end

			if renderDatas.page == 2 then
				local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
				local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

                if dashElement == localPlayer then
                    if button == "mouse1" and isCursorHover(startX + 5, startY + 5, boxW / 4, boxH / 14 - 10) then
                        if not renderDatas.slotBuy.state and not renderDatas.groupAlert.state then
                            renderDatas.opened = false
                            renderDatas.slotBuy = {state = true, type = "vehicle"};
                        end
                    end
                end

				if button == "mouse1" then
					for key, value in pairs(renderDatas.myVehicles.vehs) do
						if key >= renderDatas.myVehicles.scroll.current and key <= renderDatas.myVehicles.scroll.last then
							key = key - renderDatas.myVehicles.scroll.current + 1;
							local forY = startY + key * (boxH / 14 + 2);

							if isCursorHover(startX + 2, forY, boxW - 4, boxH / 14) then
								renderDatas.myVehicles.selected = key + renderDatas.myVehicles.scroll.current - 1;
							end
						end
					end
				end

				if isCursorHover(startX, startY, boxW, boxH) then
					if button == "mouse_wheel_down" then
						if renderDatas.myVehicles.scroll.current < #renderDatas.myVehicles.vehs - (renderDatas.myVehicles.scroll.max - 1) then
							renderDatas.myVehicles.scroll.current = renderDatas.myVehicles.scroll.current + 1;
						end
					elseif button == "mouse_wheel_up" then
						if renderDatas.myVehicles.scroll.current > 1 then
							renderDatas.myVehicles.scroll.current = renderDatas.myVehicles.scroll.current - 1;
						end
					end
				end

				startX = startX + boxW + 20;

                if dashElement == localPlayer then
                    if button == "mouse1" and isCursorHover(startX + 5, startY + 5, boxW / 4, boxH / 14 - 10) then
                        if not renderDatas.slotBuy.state then
                            renderDatas.opened = false
                            renderDatas.slotBuy = {state = true, type = "interior"};
                        end
                    end
                end
                        
				if button == "mouse1" then
					for key, value in pairs(renderDatas.myInteriors.ints) do
						if key >= renderDatas.myInteriors.scroll.current and key <= renderDatas.myInteriors.scroll.last then
							key = key - renderDatas.myInteriors.scroll.current + 1;
							local forY = startY + key * (boxH / 14 + 2);

							if isCursorHover(startX + 2, forY, boxW - 4, boxH / 14) then
								renderDatas.myInteriors.selected = key + renderDatas.myInteriors.scroll.current - 1;
							end
						end
					end
				end

				if isCursorHover(startX, startY, boxW, boxH) then
					if button == "mouse_wheel_down" then
						if renderDatas.myInteriors.scroll.current < #renderDatas.myInteriors.ints - (renderDatas.myInteriors.scroll.max - 1) then
							renderDatas.myInteriors.scroll.current = renderDatas.myInteriors.scroll.current + 1;
						end
					elseif button == "mouse_wheel_up" then
						if renderDatas.myInteriors.scroll.current > 1 then
							renderDatas.myInteriors.scroll.current = renderDatas.myInteriors.scroll.current - 1;
						end
					end
				end
			end

            if dashElement ~= localPlayer then return end        
			if renderDatas.page == 3 then
				if button == "mouse1" then
					local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
					local startX, startY = renderDatas.left + 20, renderDatas.top + 20;

					local index = 1;
					for key, value in pairs(renderDatas.shaderSettings.json) do
						if key ~= "clipdist" and key ~= "palette" then
							local forY = startY + index * (boxH / 14 + 2);

							if value[3] then
								if value[2] and isCursorHover(startX + boxW - 65 + 20, forY + 7, 33, boxH / 14 - 14) then
									value[2] = not value[2];
									triggerEvent(value[3], localPlayer, value[2]);

									saveSettings();
								elseif not value[2] and isCursorHover(startX + boxW - 65 + 2, forY + 7, 33, boxH / 14 - 14) then
									value[2] = not value[2];
									triggerEvent(value[3], localPlayer, value[2]);

									saveSettings();
								end
							end

							index = index + 1;
						end
					end

					local forY = startY + 7 * (boxH / 14 + 2);

					if isCursorHover(startX + boxW / 2 - 10 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14) then
						if renderDatas.shaderSettings.json["palette"][2] then
							if renderDatas.shaderSettings.json["palette"][2] > 1 then
								renderDatas.shaderSettings.json["palette"][2] = renderDatas.shaderSettings.json["palette"][2] - 1;

								triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

								saveSettings();
							elseif renderDatas.shaderSettings.json["palette"][2] == 1 then
								renderDatas.shaderSettings.json["palette"][2] = false;

								triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

								saveSettings();
							end
						else
							renderDatas.shaderSettings.json["palette"][2] = 14;

							triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

							saveSettings();
						end
					end

					if isCursorHover(startX + boxW - boxH / 14 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14) then
						if renderDatas.shaderSettings.json["palette"][2] then
							if renderDatas.shaderSettings.json["palette"][2] < 14 then
								renderDatas.shaderSettings.json["palette"][2] = renderDatas.shaderSettings.json["palette"][2] + 1;

								triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

								saveSettings();
							elseif renderDatas.shaderSettings.json["palette"][2] == 14 then
								renderDatas.shaderSettings.json["palette"][2] = false;

								triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

								saveSettings();
							end
						else
							renderDatas.shaderSettings.json["palette"][2] = 1;

							triggerEvent(renderDatas.shaderSettings.json["palette"][3], localPlayer, renderDatas.shaderSettings.json["palette"][2]);

							saveSettings();
						end
					end
				end

				if button == "mouse1" then
					local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
					local startX, startY = renderDatas.left + 20 + boxW + 20, renderDatas.top + 20;

					local index = 1;
					for key, value in orderedPairs(renderDatas.gameSettings.json) do
						local forY = startY + index * (boxH / 14 + 2);

						if key == "3dblip" then
							if value[2] and isCursorHover(startX + boxW - 65 + 20, forY + 7, 33, boxH / 14 - 14) then
								value[2] = not value[2];
								exports.cr_radar:toggle3DBlip(value[2]);

								saveSettings();
							elseif not value[2] and isCursorHover(startX + boxW - 65 + 2, forY + 7, 33, boxH / 14 - 14) then
								value[2] = not value[2];
								exports.cr_radar:toggle3DBlip(value[2]);

								saveSettings();
							end	
						else
							if isCursorHover(startX + boxW / 2 - 10 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14) then
								if value[2] == value[4][1] then
									value[2] = value[4][#value[4]];
								else
									value[2] = value[4][findKey(value[4], value[2]) - 1];
								end

								if key == "walkstyle" then
									triggerServerEvent("gameSettings->WalkStyle", localPlayer, localPlayer, value[2]);
								end

								if key == "fightstyle" then
									triggerServerEvent("gameSettings->FightStyle", localPlayer, localPlayer, value[2]);
								end

								if key == "chatstyle" then
									setElementData(localPlayer, "gameSettings->ChatStyle", value[2]);
								end

								saveSettings();
							end

							if isCursorHover(startX + boxW - boxH / 14 + 2, forY + 7, boxH / 14 - 14, boxH / 14 - 14) then
								if value[2] == value[4][#value[4]] then
									value[2] = value[4][1];
								else
									value[2] = value[4][findKey(value[4], value[2]) + 1];
								end

								if key == "walkstyle" then
									triggerServerEvent("gameSettings->WalkStyle", localPlayer, localPlayer, value[2]);
								end

								if key == "fightstyle" then
									triggerServerEvent("gameSettings->FightStyle", localPlayer, localPlayer, value[2]);
								end

								if key == "chatstyle" then
									setElementData(localPlayer, "gameSettings->ChatStyle", value[2]);
								end

								saveSettings();
							end
						end

						index = index + 1;
					end
				end
			end

			if renderDatas.page == 4 then
				local boxW, boxH = renderDatas.width / 3 - 30, renderDatas.height - 40;
				local startX, startY = renderDatas.left + renderDatas.width - 20 - boxW, renderDatas.top + 20;
				local forH = ((boxH - 2) / 9) - 2;

				if button == "mouse1" then
					for key, value in pairs(renderDatas.availableAdmins.table) do
						local forY = startY + 2 + (key - 1) * (forH + 2);

						if isCursorHover(startX + 2, forY, boxW - 4, forH) then
							renderDatas.availableAdmins.selected = key;
						end
					end
				end
			end

			if renderDatas.page == 6 then
				if renderDatas.myGroupId == 0 then			
					if button == "mouse1" then
						if isCursorHover(renderDatas.left + renderDatas.width / 2 - renderDatas.width * 0.2, renderDatas.top + renderDatas.height / 2 - renderDatas.height * 0.05, renderDatas.width * 0.4, renderDatas.height * 0.1) then
							triggerServerEvent("group->Create", localPlayer, localPlayer, getElementData(localPlayer, "acc >> id"));
						end
					end
				else
					if button == "mouse1" then
						local boxW, boxH = renderDatas.width / 2 - 30, renderDatas.height - 40;
						local startX, startY = renderDatas.left + 20 + boxW + 20, renderDatas.top + 20;

						if renderDatas.myGroupDatas["owner"] == renderDatas.myAccountId then
							local buttonX = startX + boxW / 2 - boxW / 4;
							local buttonY = startY + boxH / 2 - (4 * (boxH / 7) + 3 * 30) / 2;
							local buttonH = boxH / 7;

							if isCursorHover(buttonX, buttonY, boxW / 2, boxH / 7) then
								if not renderDatas.slotBuy.state and not renderDatas.groupAlert.state then
									renderDatas.opened = false
									renderDatas.groupAlert = {state = true, type = "addmember"};
								end
							end

							if isCursorHover(buttonX, buttonY + buttonH + 30, boxW / 2, buttonH) then
								if not renderDatas.slotBuy.state and not renderDatas.groupAlert.state then
									renderDatas.opened = false
									renderDatas.groupAlert = {state = true, type = "kickmember"};
								end
							end
						
							if isCursorHover(buttonX, buttonY + (buttonH + 30) * 2, boxW / 2, buttonH) then
								if not renderDatas.slotBuy.state and not renderDatas.groupAlert.state then
									renderDatas.opened = false
									renderDatas.groupAlert = {state = true, type = "rename"};
								end
							end

							if isCursorHover(buttonX, buttonY + (buttonH + 30) * 3, boxW / 2, buttonH) then
								if not renderDatas.slotBuy.state and not renderDatas.groupAlert.state then
									renderDatas.opened = false
									renderDatas.groupAlert = {state = true, type = "delete"};
								end
							end				
						end
					end
				end
			end
		end
	end
end);

function saveSettings()
	renderDatas.shaderSettings.file = fileOpen("files/shaders/settings.json", false);

	if renderDatas.shaderSettings.file then
		local array = {};

		for key, value in pairs(renderDatas.shaderSettings.json) do
			array[key] = value[2];
		end

		for key, value in pairs(renderDatas.gameSettings.json) do
			array[key] = value[2];
		end

		fileWrite(renderDatas.shaderSettings.file, toJSON(array));
		fileClose(renderDatas.shaderSettings.file);
	end
end

function findKey(array, searched)
	for key, value in pairs(array) do
		if value == searched then
			return key;
		end
	end

	return -1;
end

function dxDrawWindow(left, top, width, height, color, title, font)
	dxDrawRectangle(left, top, width, 30, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left - 1, top, 1, height, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left + width, top, 1, height, tocolor(0, 0, 0, 220));
	dxDrawRectangle(left - 1, top + height, width + 2, 1, tocolor(0, 0, 0, 220));

	dxDrawRectangle(left, top + 30, width,  height - 30, color);

	dxDrawText(title, left, top, left + width, top + 30, colors.white, 1, font, "center", "center");
end

function dxDrawButton(left, top, width, height, color, title, hovertitle, font)
	dxDrawRectangle(left, top, width, height, color);

	if isCursorHover(left, top, width, height) then
		dxDrawText(hovertitle, left, top, left + width, top + height, colors.black, 1, font, "center", "center");
	else
		dxDrawText(title, left, top, left + width, top + height, colors.white, 1, font, "center", "center");
	end
end

function isCursorHover(startX, startY, width, height, multipler)
	if isCursorShowing() then
		local cursorX, cursorY = getCursorPosition();
		cursorX, cursorY = cursorX * screenW, cursorY * screenH;

		if not multipler then
			multipler = 1;
		end

		width = width * multipler;
		height = height * multipler;

		if cursorX >= startX and cursorX <= startX + width and cursorY >= startY and cursorY <= startY + height then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

-->> LUA USEFUL FUNCTIONS
function countTable(t)
	local s = 0;

	for key, value in pairs(t) do
		s = s + 1;
	end

	return s;
end

function __genOrderedIndex(t)
    local orderedIndex = {};

    for key in pairs(t) do
        table.insert(orderedIndex, key);
    end

    table.sort(orderedIndex);

    return orderedIndex;
end

function orderedNext(t, state)
    local key = nil;

    if state == nil then
        t.__orderedIndex = __genOrderedIndex(t);
        key = t.__orderedIndex[1];
    else
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1];
            end
        end
    end

    if key then
        return key, t[key];
    end

    t.__orderedIndex = nil;
    
    return;
end

function orderedPairs(t)
    return orderedNext, t, nil;
end

-->> CUSTOM DXDRAW EDITBOX
Edits = {}

selectedEdit = false
guiSetInputMode("allow_binds")

function dxDrawEdit(startX, startY, width, height, text, font, isActive)
	dxDrawRectangle(startX, startY, width, height, colors.slot)
    
	if isActive and getTickCount() - countL < 500 and isCursorShowing() then
		text = text .. "|"
	end
    
	dxDrawText(text, startX, startY, startX + width, startY + height, tocolor(255, 255, 255), 1, font, "center", "center")
end

setTimer(function()
	countL = getTickCount()
end, 1000, 0)

function createEdit(Name, posX, posY, sizeX, sizeY, text, font, length)
	if not Edits[Name] then
		Edits[Name] = {}
		Edits[Name].Name = Name

		Edits[Name].PosX, Edits[Name].PosY = posX, posY
		Edits[Name].SizeX, Edits[Name].SizeY = sizeX, sizeY

		Edits[Name].Visible = true
		Edits[Name].Text = text
		Edits[Name].DefaultText = text
		Edits[Name].Length = length

		Edits[Name].Font = font
	end
end

function removeEdit(Name)
	if Edits[Name] then
		Edits[Name] = {}
		Edits[Name] = nil
	end
end

function getEditText(Name)
	return Edits[Name].Text or ""
end

function setEditVisible(Name, state)
	if Edits[Name] then
		Edits[Name].Visible = state
	end
end

function getEditVisible(Name)
	return Edits[Name].Visible or false
end

addEventHandler("onClientRender", root, function()
    --if not renderDatas.opened then return end
	for key, value in pairs(Edits) do
		if value.Visible then
			dxDrawEdit(value.PosX, value.PosY, value.SizeX, value.SizeY, value.Text, value.Font, selectedEdit == value)
		end
	end
end)

local availableKeys = "abcdefghijklmnopqrstuvwxyzöüóőúűáéí0123456789ÁÉŰÚŐÓÜÖÍ"

local transferKeys = {
	["#"] = {"á", "Á"},
	[";"] = {"é", "É"},
	["]"] = {"ú", "Ú"},
	["'"] = {"ö", "Ö"},
	["/"] = {"ü", "Ü"},
	["="] = {"ó", "Ó"}
}

addEventHandler("onClientKey", root, function(button, pressed)
	if pressed and button == "mouse1" then
		for key, value in pairs(Edits) do
			if isCursorHover(value.PosX, value.PosY, value.SizeX, value.SizeY) and value.Visible then
				selectedEdit = value
				guiSetInputMode("no_binds")

				if selectedEdit.Text == selectedEdit.DefaultText then
					selectedEdit.Text = ""
				end

				return
			end
		end

		selectedEdit = false
		guiSetInputMode("allow_binds")
	elseif pressed and button ~= "mouse2" then
		if selectedEdit and selectedEdit.Visible and isCursorShowing() then			
			if button == "backspace" then
				selectedEdit.Text = selectedEdit.Text:sub(1, -2)
			end

			button = button:gsub("num_", "")

			if button == "[" then
				button = "ő"

				if getKeyState("lshift") or getKeyState("rshift") then
					button = "Ő"
				end
			elseif button == "\\" then
				button = "ű"

				if getKeyState("lshift") or getKeyState("rshift") then
					button = "Ű"
				end
			end

			if transferKeys[button] then
				if getKeyState("lshift") or getKeyState("rshift") then
					button = transferKeys[button][2]
				else
					button = transferKeys[button][1]
				end
			else
				if getKeyState("lshift") or getKeyState("rshift") then
					button = button:upper()
				end
			end

			if (string.find(availableKeys, button:lower()) or button == "space") and #selectedEdit.Text < selectedEdit.Length then
				if button == "space" then
					selectedEdit.Text = selectedEdit.Text .. " "
				else
					selectedEdit.Text = selectedEdit.Text .. button
				end
			end

			if button:lower() == "m" or button:lower() == "t" or button:lower() == "i" or button:lower() == "b" then
				cancelEvent()
			end
		end
	end
end)