local texturesimg = {
{"img/1.png", "collisionsmoke"},
{"img/2.png", "particleskid"},
{"img/4.png", "headlight1"},
{"img/5.png", "headlight"},
{"img/moon.png", "coronamoon"}}
addEventHandler("onClientResourceStart", resourceRoot, function()
  -- upvalues: texturesimg
  for i = 1, #texturesimg do
    local shader = dxCreateShader("chaticon.fx")
    engineApplyShaderToWorldTexture(shader, texturesimg[i][2])
    dxSetShaderValue(shader, "gTexture", dxCreateTexture(texturesimg[i][1]))
  end
end
)




