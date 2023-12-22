local skinData = {
    --[id] = {nationality, nem (1 - férfi/2 - nő)}
    [1] = {"*", "*"},
    [102] = {1, 1},
    [103] = {1, 1},
}

local skinByNationality = {}

local permData = {
    --[id] = serial / table with serials such as: {["asd"] = true, ["asd"] = true}
    [102] = "E390110EEECD9A0FBB825258639EF334"
}

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if dName == "char >> skin" then
            checkSkin(source, dName, oValue)
        end
    end
)

function checkSkin(source, dName, oValue)
    if not oValue then
        oValue = source:getData(dName) or source.model
    end
    --outputChatBox(dName)
    local value = source:getData(dName) or source.model
    local a = source:getData("char >> details")
    local nationality = a["nationality"]
    local typ = a["neme"]
    --outputChatBox(typ)
    --outputChatBox(value)
    if not skinData[value] then return end
    
    local a2 = skinData[value][1] or 0
    local a3 = skinData[value][2] or 0
    if a2 ~= nationality and a2 ~= "*" then
        local syntax = exports['cr_core']:getServerSyntax("SkinProtect", "error")
        outputChatBox(syntax .. "A kinézeted (model) vissza lett változtatva a régire, hisz az új nem használható a jelenlegi nemzetiségednél.", 255,255,255,true)
        source:setData(dName, oValue)
        return
    elseif a3 ~= typ and a3 ~= "*" then
        local syntax = exports['cr_core']:getServerSyntax("SkinProtect", "error")
        outputChatBox(syntax .. "A kinézeted (model) vissza lett változtatva a régire, hisz az új nem használható a jelenlegi nemeddel.", 255,255,255,true)
        source:setData(dName, oValue)
        return
    end

    local perm = permData[value]
    if perm then
        local serial = perm
        if type(serial) == "table" then
            local hasPerm = perm[getElementData(localPlayer, "mtaserial")]
            if exports['cr_core']:getPlayerDeveloper(localPlayer) then
                hasPerm = true
            end

            if not hasPerm then
                local syntax = exports['cr_core']:getServerSyntax("SkinProtect", "error")
                outputChatBox(syntax .. "A kinézeted (model) vissza lett változtatva a régire, hisz az új nem használható mert nincs megfelelő jogosultságod a használatára.", 255,255,255,true)
                source:setData(dName, oValue)
            end
        elseif type(serial) == "number" then
            local hasPerm = getElementData(localPlayer, "mtaserial") == serial
            if exports['cr_core']:getPlayerDeveloper(localPlayer) then
                hasPerm = true
            end

            if not hasPerm then
                local syntax = exports['cr_core']:getServerSyntax("SkinProtect", "error")
                outputChatBox(syntax .. "A kinézeted (model) vissza lett változtatva a régire, hisz az új nem használható mert nincs megfelelő jogosultságod a használatára.", 255,255,255,true)
                source:setData(dName, oValue)
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if localPlayer:getData("loggedIn") then
            local a = localPlayer:getData("char >> details")
            local nationality = a["nationality"]
            checkSkin(localPlayer, "char >> skin", 1)
        end
    end
)