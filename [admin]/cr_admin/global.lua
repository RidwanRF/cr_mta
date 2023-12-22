local aTitles = {
    --[level] = "Text"
    [-6] = "Bugteszter",
    [-5] = "Mapper/Modellező",
    [-4] = "RP Őr 1",
    [-3] = "RP Őr 2",
    [-2] = "RP Őr 3",
    [-1] = "Segédfejlesztő",
    [0] = "Játékos",
    [1] = "Ideiglenes Adminsegéd",
    [2] = "S.A.S Adminsegéd",
    [3] = "Admin 1",
    [4] = "Admin 2",
    [5] = "Admin 3",
    [6] = "Admin 4",
    [7] = "Admin 5",
    [8] = "FőAdmin",
    [9] = "SuperAdmin",
    [10] = "Rendszergazda",
    [11] = "Fejlesztő",
    [12] = "Tulajdonos",
}

function getMaxKickCount()
    return 1
end

function getMaxBanCount()
    return 1
end

function getMaxJailCount()
    return 1
end

function getMaxRTCCount()
    return 1
end

function getMaxFuelCount()
    return 1
end

function getMaxFixCount()
    return 1
end

function getAdminTitle(e)
    local level = getElementData(e, "admin >> level") or 0
    local title = aTitles[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
    return title
end

function getAdminTitleByLevel(level)
    local title = aTitles[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
    return title
end

local aColors = {
    --[level] = {hexColor, r,g,b}
    [-6] = {"#ff751a", 255,117,26},
    [-5] = {"#ff751a", 255,117,26},
    [-4] = {"#ff751a", 255,117,26},
    [-3] = {"#ff751a", 255,117,26},
    [-2] = {"#ff751a", 255,117,26},
    [-1] = {"#ff751a", 255,117,26},
    [0] = {"#ffffff", 255,255,255},
    [1] = {"#ff66d9", 255,102,217},
    [2] = {"#ff66d9", 255,102,217},
    [3] = {"#55c371", 85,195,113},
    [4] = {"#55c371", 85,195,113},
    [5] = {"#55c371", 85,195,113},
    [6] = {"#55c371", 85,195,113},
    [7] = {"#55c371", 85,195,113},
    [8] = {"#3460e5", 52,96,229},
    [9] = {"#ffd11a", 255,209,26},
    [10] = {"#ff33ff", 255,51,255},
    [11] = {"#ff751a", 255,117,26},
    [12] = {"#ff3333", 255,51,51},
}

function getAdminColor(e, level, hexColor)
    if level then
        if hexColor then
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[1]
        else
            local level = getElementData(e, "admin >> level") or 0
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[2], color[3], color[4]
        end
    else
        local level = getElementData(e, "admin >> level") or 0
        if hexColor then
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[1]
        else
            local level = getElementData(e, "admin >> level") or 0
            local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
            return color[2], color[3], color[4]
        end
    end
end

function getAdminColorByLevel(level, hexColor)
    if hexColor then
        local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
        return color[1]
    else
        local color = aColors[level] or "Ismeretlen (Jelentsd fejlesztőnek!)"
        return color[2], color[3], color[4]
    end
end

function getAdminDuty(e)
    local duty = getElementData(e, "admin >> duty")
    local adminlevel = getElementData(e, "admin >> level")
    if adminlevel == 1 or adminlevel == 2 then
        duty = true
    elseif adminlevel == 0 then
        duty = false
    end
    return duty
end

function getAdminName(e, onlyAdminName)
    local name = getElementData(e, "char >> name") or getPlayerName(e)
    name = name:gsub("_", " ")
    if getElementData(e, "admin >> duty") or onlyAdminName then
        name = getElementData(e, "admin >> name") or name
    end
    
    if not name then
        name = inspect(name)
    end
    return name
end

local white = "#ffffff"

function getAdminSyntax(commandSyntax, specialColor)
    if not commandSyntax then
        commandSyntax = "Admin"
    end
    if not specialColor then
        specialColor = "red"
    end
    local hexColor = exports['cr_core']:getServerColor(specialColor, true)
    local text = hexColor.."["..commandSyntax.."] "..white
    return text
end