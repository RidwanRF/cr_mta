local function drawnIcon(x, y, icon)
    dxDrawImage(x - 30/2, y - 30/2, 30, 30, "stamina/files/"..icon..".png");
end

local id = getElementData(localPlayer, "id") or -1;

local sx, sy = guiGetScreenSize();

local staminaIcon = "";
local stamina = 100;
local staminaMultipler = stamina / 100;

function getElementSpeed2(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")");
    local elementType = getElementType(theElement);
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")");
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)");
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit));
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456);
    return math.floor((Vector3(getElementVelocity(theElement)) * mult).length);
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "loggedIn") then
        addEventHandler("onClientPreRender", root, staminaCheck, true, "low-1");
    end
end);

addEventHandler("onClientElementDataChange", localPlayer, function(dName, oValue)
    if dName == "loggedIn" then
        addEventHandler("onClientPreRender", root, staminaCheck, true, "low-1");
    end
end);

local animed = false
local oneRevive = false
function staminaCheck()
    if getElementData(localPlayer, "inDeath") then return end
    local speed = getElementSpeed2(localPlayer, "m/s");
    if speed >= 5 then
        if not exports.cr_admin:getAdminDuty(localPlayer) then
            if getPedOccupiedVehicle(localPlayer) then return end
            if stamina >= 0 then
                if speed >= 2 and speed <= 6 then
                    stamina = stamina - 0.05;
                    if stamina <= 0 then
                        stamina = 0
                        if not animed then
                            animed = true;
                            setElementData(localPlayer, "stamina.freeze", true);
                            toggleAllControls(false);
                            setTimer(function()
                                setElementData(localPlayer, "forceAnimation", {" ", " "});
                                setElementData(localPlayer, "forceAnimation", {"ped", "idle_tired"});
                            end, 200, 1);
                        end
                    end
                elseif speed >= 11 and speed <= 11.5 then
                    stamina = stamina - 0.05
                    if not oneRevive then
                        oneRevive = true
                        stamina = stamina - 2.5
                        if stamina <= 0 then
                            stamina = 0
                            if not animed then
                                animed = true;
                                toggleAllControls(false);
                                setTimer(function()
                                    setElementData(localPlayer, "forceAnimation", {" ", " "});
                                    setElementData(localPlayer, "forceAnimation", {"ped", "idle_tired"});
                                end, 500, 1);
                                setElementData(localPlayer, "stamina.freeze", true);
                            end
                        end    
                        setTimer(function()
                            oneRevive = false;
                        end, 1000, 0);
                    end
                end
            end
        end    
    else
        if stamina >= 20 and stamina <= 100 then
            stamina = stamina + 0.05
            if animed then
                local oldBone = getElementData(localPlayer, "char >> bone");
                setElementData(localPlayer, "char >> bone", {true, true, true, true});
                toggleAllControls(true)
                setElementData(localPlayer, "char >> bone", oldBone);
                animed = false
                setElementData(localPlayer, "stamina.freeze", false);
                setTimer(function()
                    setElementData(localPlayer, "forceAnimation", {" ", " "});
                    setElementData(localPlayer, "forceAnimation", {"", ""});
                end, 200, 1);
            end
        elseif stamina <= 20 then
            stamina = stamina + 0.05;
        end
    end
end

function drawnStamina()
    if not getElementData(localPlayer, "hudVisible") then return end
    local enabled,x,y,w,h,sizable,turnable = getDetails("stamina");
    drawnIcon(x - 18, y + h/2, "stamina");
    dxDrawRectangle(x,y, w,h, tocolor(90,90,90,180));
    lineddRectangle(x,y, w,h, tocolor(0,0,0,0), tocolor(0,0,0,200));
    staminaMultipler = (stamina / 100);
    dxDrawRectangle(x, y, w * staminaMultipler, h, tocolor(255, 255, 255,200));
end

function getStamina()
    return stamina;
end

setTimer(function()
    setControlState("walk", true);
end, 500, 0);

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "forceAnimation" then
            local value = getElementData(source, dName)
            --iprint(value)
            if value[1] == "" and value[2] == "" then
                --setPedAnimation(source, "ped", "WOMAN_walknorm")
                setPedAnimation(source, "ped", "WOMAN_walknorm")
                setTimer(setPedAnimation, 50, 1, source, "", "")
            else
                setPedAnimation(source, value[1], value[2], -1, true, false, true)
            end
        end
    end
)