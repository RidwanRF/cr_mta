local skins = {}
local disable = {
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [8] = true,
    [42] = true,
}
addEventHandler("onClientResourceStart", getResourceRootElement(),
    function()
        for i = 1, 320 do
            if fileExists("skins/"..i..".dff") and fileExists("skins/"..i..".txd") then
                --outputChatBox(i)
                if not disable[i] then
                    local txd = engineLoadTXD("skins/"..i..".txd")
                    engineImportTXD(txd, i)
                    local dff = engineLoadDFF("skins/"..i..".dff")
                    engineReplaceModel(dff, i)
                    if not engineReplaceModel(dff, i) then
                        outputChatBox(i.."!")
                    end
                    skins[#skins + 1] = {i, txdSize = fileGetSize(fileOpen("skins/"..i..".txd")) , dffSize = fileGetSize(fileOpen("skins/"..i..".dff"))}
                end
            end
        end      
    end 
)

