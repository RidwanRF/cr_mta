local tips = {
    --"Tipp", 
    "A #ff9933/elrejt#ffffff parancs használatával eltudod rejteni az éppen kezedben lévő kiskaliberű fegyvert!",   
    "A #ff9933/togdescriptions#ffffff parancs használatával eltudod tűntetni a játékosok leírásait! (Descriptionst a nametagből)",
    "Egyes widgeteket (Pld: #ff9933Inventory#ffffff) anélkül tudsz mozgatni, hogy megnyisd a hud szerkesztést!",
    "#ff9933Tudtad?#ffffff Ha #ff99331#ffffff másodpercig tartod lenyomva a #ff9933'TAB'#ffffff gombot a scoreboard nem tűnik el csak újbóli lenyomás után!"
}

local blue = "#4d79ff"
local syntax = blue .. "[Tipp] #ffffff"
local oldTipp = 0

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        createTipp()
    end
)

function createTipp()
    local newTipp = math.random(1, #tips)
    if newTipp == oldTipp then
        return createTipp
    end
    local text = tips[newTipp]
    outputChatBox(syntax .. text, 255,255,255,true)
    return true
end

local seconds = 15 * 60
setTimer(createTipp, seconds * 10000, 0)