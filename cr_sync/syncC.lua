local old = -500;
local gear = -1;

setTimer(function()
    --outputChatBox(old)
    --outputChatBox(localPlayer.armor)
    if old ~= localPlayer.armor then
        old = localPlayer.armor;
        triggerServerEvent("sync->Armor", localPlayer, localPlayer);
    end
end, 500, 0);