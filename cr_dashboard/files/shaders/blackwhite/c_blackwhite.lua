local screenX, screenY = guiGetScreenSize()
local screenSource = dxCreateScreenSource(screenX, screenY)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function()
    if getVersion ().sortable < "1.1.0" then
        return
	else
		blackWhiteShader, blackWhiteTec = dxCreateShader("files/shaders/blackwhite/fx/blackwhite.fx")
    end
end)

function enableBlackWhite()
    addEventHandler("onClientPreRender", getRootElement(), drawShader)
end

function disableBlackWhite()
    removeEventHandler("onClientPreRender", getRootElement(), drawShader)
end

function drawShader()
    if (blackWhiteShader) then
        dxUpdateScreenSource(screenSource)     
        dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
        dxDrawImage(0, 0, screenX, screenY, blackWhiteShader)
    end
end