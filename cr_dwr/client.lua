addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        shader = dxCreateShader("files/texturechanger.fx")
        texture = dxCreateTexture("files/waterclear256.png")
        dxSetShaderValue(shader, "gTexture", texture)
        engineApplyShaderToWorldTexture(shader, "waterclear256")
        
        shader = dxCreateShader("files/texturechanger.fx")
        texture = dxCreateTexture("files/waterwake.png")
        dxSetShaderValue(shader, "gTexture", texture)
        engineApplyShaderToWorldTexture(shader, "waterwake")
    end
)