local models = {
    --{source = "files/asd", modelID},
    {"files/vgsn_billboard", 7310},
}

local textures = {
    "cj_sprunk_f",
    "cj_sprunk_front2",
    "cj_sprunk_front",
    "cj_porno_vids",
    "cj_sprunk_dirty",
    "sunbillb03",
    "sprunk_postersign1",
    "chillidog_sign",
    "iceysign",
    "iceyside",
    "redwhite_stripe",
    "cj_painting1",
    "gb_magazine01",
    "bigsprunkcan",
    "sprunk_temp",
    --"monitor",
    --"fam3",
}

local protect = {
    ["cj_porno_vids"] = true,
    ["cj_painting1"] = true,
    ["gb_magazine01"] = true,
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(models) do
            local source, id = unpack(v)
            txd = engineLoadTXD(source .. ".txd")
            engineImportTXD(txd, id)
        end
        
        for k,v in pairs(textures) do
            texElement = dxCreateTexture("files/"..v..".png", textureQuality or "dxt1")
            local protected = protect[v]
            if protected then
                fileDelete("files/"..v..".png")
            end    
            local shadElement = dxCreateShader("files/replace.fx", 0, 100, false, "all")
            engineApplyShaderToWorldTexture(shadElement, v)
            dxSetShaderValue(shadElement, "gTexture", texElement)
        end
    end
)

