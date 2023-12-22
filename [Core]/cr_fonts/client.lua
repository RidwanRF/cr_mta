local fonts = {}
local fontsSource = {
    --["fontName"] = "source"
	["Rubik-Black"] = "files/Rubik-Bold.ttf",
    ["Rubik-Regular"] = "files/Rubik-Regular.ttf",
    ["Rubik"] = "files/Rubik-Regular.ttf",
    ["Rubik-Light"] = "files/Rubik-Light.ttf",
	["gotham_light"] = "files/gotham_light.ttf",
	["Roboto"] = "files/Roboto.ttf", 
    --["AwesomeFont"] = "files/FontAwesome.otf",
    ["AwesomeFont2"] = "files/FontAwesome.ttf",
    ["gtaFont"] = "files/gtaFont.ttf",
    ["LoginFont"] = "files/loginfont.ttf",
	["Yantramanav-Black"] = "files/Yantramanav-Black.ttf",
	["Yantramanav-Regular"] = "files/Yantramanav-Regular.ttf",
    ["Azzardo-Regular"] = "files/Azzardo-Regular.ttf",
}

function getFont(font, size, bold, quality)
    if not font then return end
    if not size then return end
    if string.lower(font) == "fontawesome" then font = "AwesomeFont" end
    if string.lower(font) == "fontawesome2" then font = "AwesomeFont" end
    if string.lower(font) == "awesomefont" then font = "AwesomeFont2" end
    --local size = math.floor(size)
    local fontE = false
    local _font = font
    
    if bold then
        font = font .. "-bold"
    end
    
    if quality then
        font = font .. "-" .. quality 
    end
    
    if font and size then
	    local subText = font .. size
	    local value = fonts[subText]
	    if value then
		    fontE = value
		end
	end
    
    if not fontE then
        local v = fontsSource[_font]
        fontE = DxFont(v, size, bold, quality)
        local subText = font .. size
        fonts[subText] = fontE
        outputDebugString("Font:" ..font.. ", Size: "..size.." created!", 0, 255, 255, 255)
    end
    
	return fontE
end