screenW, screenH = guiGetScreenSize();
width, height = 860, 450;
state = false;
selectedFaction = 1;
selectedPage = 6;
selectedElement = 1;
lineMembers = 1;
lineVehicles = 1;
lineRanks = 1;
lineStorage = 1;
lineDutys = 1;
lineDutyStorage = 1;
menuCount = 0;
timers = {};
inviteState = false;
dutyState = false;
dutySkinState = false;
dutyStatus = "Create";
selectedDutyRank = 1;
selectedStorage = 0;
selectedDutyStorage = 0;
selectedDutySkin = 1;
dutyStorage = {};
positions = {screenW/2 - width/2, screenH/2 - height/2};
menus_default = {{"Áttekintés"}, {"Tagok"}, {"Járművek"}, {"Rangok kezelése"}, {"Raktár", {[1] = true, [2] = true}}, {"Duty kezelés", {[1] = true, [2] = true}}};
menus = {{" Áttekintés"}, {" Tagok"}, {" Járművek"}, {" Rangok kezelése"}, {" Raktár", {[1] = true, [2] = true}}, {" Duty kezelés", {[1] = true, [2] = true}}};
newmenus = {};
playerCache = {};

actionTexts = {
    ["members"] = {
        " Játékos meghívása", " Előléptetés", " Lefokozás", " Leader jog változtatás", " Kirúgás"
    },
    ["ranks"] = {
        " Rang mentése", " Rang hozzáadása", " Rang törlése",
    },
    ["duty"] = {
        " Duty létrehozása", " Duty szerkesztése", " Duty törlése",
    }
};

--fonts = {};
--fonts["Rubik-10"] = exports['cr_fonts']:getFont("Rubik-Regular", 10);
--fonts["Rubik-9"] = exports['cr_fonts']:getFont("Rubik-Regular", 9);
--fonts["Rubik-11"] = exports['cr_fonts']:getFont("Rubik-Regular", 11);
--fonts["Awesome-9"] = dxCreateFont("files/FontAwesome.ttf", 9);
--fonts["Awesome-10"] = dxCreateFont("files/FontAwesome.ttf", 10);
--fonts["Awesome-11"] = dxCreateFont("files/FontAwesome.ttf", 11);
--fonts["Awesome-13"] = dxCreateFont("files/FontAwesome.ttf", 13);
--fonts["Awesome-15"] = dxCreateFont("files/FontAwesome.ttf", 15);

function isCursorHover(startX, startY, sizeX, sizeY)
    if isCursorShowing() then
        local cursorPosition = {getCursorPosition()};
        cursorPosition.x, cursorPosition.y = cursorPosition[1] * screenW, cursorPosition[2] * screenH;

        if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
            return true;
        else
            return false;
        end
    else
        return false;
    end
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end
		
		if (not bgColor) then
			bgColor = borderColor;
		end
        
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
	end
end

function resetFaction()
    --outputChatBox("KURVA ANYÁDAT BEZÁROM: 5")
    selectedFaction = 0;
    dutyStorage = {};
    selectedPage = 1;
    selectedElement = 0;
    selectedDutyRank = 0;
    selectedStorage = 0;
    selectedDutyStorage = 0;
    selectedDutySkin = 0;
    lineMembers = 1;
    lineRanks = 1;
    lineDutyStorage = 1;
    lineStorage = 1;
    dutyStatus = "";
    inviteState = false;
    dutyState = false;
    dutySkinState = false;
    removeEdits();
end

function getOnlinePlayerCache()
	local pCache = {}
	for k,v in ipairs(getElementsByType("player")) do
		if getElementData(v, "loggedIn") then
			local name = tostring(getElementData(v, "char >> name")) or "Ismeretlen";
			local dbid = tonumber(getElementData(v, "acc >> id")) or 0;
			pCache[name] = v;
			pCache[dbid] = v;
		end
	end
	return pCache
end

function isLeader()
    local dbid = getElementData(localPlayer, "acc >> id");
    if selectedFaction > 0 then
        if factions[selectedFaction] then
            if faction_members[selectedFaction] then
                for i, k in pairs(faction_members[selectedFaction]) do
                    if k[2] == dbid then
                        if k[4] > 0 then
                            return true;
                        end
                    end
                end
            end
        end
    end
    return false;
end

function isMainLeader()
    local dbid = getElementData(localPlayer, "acc >> id");
    if selectedFaction > 0 then
        if factions[selectedFaction] then
            if faction_members[selectedFaction] then
                for i, k in pairs(faction_members[selectedFaction]) do
                    if k[2] == dbid then
                        if k[4] == 2 then
                            return true;
                        end
                    end
                end
            end
        end
    end
    return false;
end


Edits = {}

selectedEdit = false
guiSetInputMode("allow_binds")

function dxDrawEdit(startX, startY, width, height, text, font, isActive, pos, color)
	--[[dxDrawRectangle(startX - 1, startY, 1, height, tocolor(0, 0, 0, 180), true) --left
	dxDrawRectangle(startX + width, startY, 1, height, tocolor(0, 0, 0, 180), true) --right
	dxDrawRectangle(startX - 1, startY - 1, width + 2, 1, tocolor(0, 0, 0, 180), true) --top
	dxDrawRectangle(startX - 1, startY + height, width + 2, 1, tocolor(0, 0, 0, 180), true) --bottom

	dxDrawRectangle(startX, startY, width, height, tocolor(40, 40, 40, 200), true)--]]
    
	if isActive and getTickCount() - countL < 500 and isCursorShowing() then
		text = text .. "|"
	end
    
    local left, right = "left", "center";
    
    if pos then
        left = pos[1];
    else
        left = "left";
    end
	if(not color) then
		color = tocolor(255, 255, 255, 255)
	end
	
	if(not font) then
		font = fonts["Rubik-10"]
	end
    
	dxDrawText(text, startX + 6, startY, startX + width, startY + height, color, 1, font, left, "center", false, false, true);
end

setTimer(function()
	countL = getTickCount()
end, 1000, 0)

function createEdit(Name, posX, posY, sizeX, sizeY, text, font, length, left, right, color)
	if not Edits[Name] then
		Edits[Name] = {};
		Edits[Name].Name = Name;

		Edits[Name].PosX, Edits[Name].PosY = posX, posY;
		Edits[Name].SizeX, Edits[Name].SizeY = sizeX, sizeY;

		Edits[Name].Visible = true;
		Edits[Name].Text = text;
		Edits[Name].DefaultText = text;
		Edits[Name].Length = length;
		Edits[Name].positions = {left, right};
		Edits[Name].color = color

		if font == "Rubik-9" then
			Edits[Name].Font = fonts["Roboto-9"];
		elseif font == "big" then
			Edits[Name].Font = Fonts.RobotoBig;
		else
			Edits[Name].Font = fonts["Rubik-10"];
		end
	end
end

function removeEdit(Name)
	if Edits[Name] then
		Edits[Name] = {}
		Edits[Name] = nil
	end
end

function removeEdits()
    for i, k in pairs(Edits) do
        Edits[k.Name] = {}
		Edits[k.Name] = nil
    end
end

function getEditText(Name)
	return Edits[Name].Text or ""
end

function setEditText(Name, text)
    if Edits[Name] then
        Edits[Name].Text = text;
    end
	return true;
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
	for key, value in pairs(Edits) do
		if value.Visible then
			dxDrawEdit(value.PosX, value.PosY, value.SizeX, value.SizeY, value.Text, value.Font, selectedEdit == value, value.positions, value.color)
		end
	end
end)

--local availableKeys = "abcdefghijklmnopqrstuvwxyzöüóőúűáéí0123456789ÁÉŰÚŐÓÜÖÍ"
local availableKeys = "abcdefghijklmnopqrstuvwxyzöüóőúűáéíÁÉŰÚŐÓÜÖÍ_123456789, "

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
            elseif button == "space" then
                if selectedEdit.Name == "invite" then
                    button = "_";
                else
                    button = " ";
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
            
            if selectedEdit.Name == "rank_money" or selectedEdit.Name == "money" then
                if (tonumber(button:lower()) or -1 > 0) and string.len(selectedEdit.Text) < selectedEdit.Length then
                    selectedEdit.Text = selectedEdit.Text .. button;
                end
            else
                if selectedEdit.Name == "rank_name" then
                    if (tonumber(button:lower()) or -1 >= 0) then return end
                end
                
                if string.find(availableKeys, button:lower()) and #selectedEdit.Text < selectedEdit.Length then
                    selectedEdit.Text = selectedEdit.Text .. button;
                end 
            end

			if button:lower() == "m" or button:lower() == "t" or button:lower() == "i" or button:lower() == "b" then
				cancelEvent();
			end
		end
	end
end)