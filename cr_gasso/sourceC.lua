local dir = "mods"
function loadMod(f, m)
	if fileExists(dir..'/'.. f ..'.txd') then
		txd = engineLoadTXD(dir ..'/'.. f ..'.txd')
		engineImportTXD(txd, m)
	end
	if fileExists(dir..'/'.. f ..'.dff') then
		dff = engineLoadDFF(dir..'/'.. f ..'.dff', m)
		engineReplaceModel(dff, m, true)
	end
	if fileExists(dir..'/'.. f ..'.col') then
		col = engineLoadCOL(dir..'/'.. f ..'.col')
		engineReplaceCOL(col,m)
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	loadMod("sw_gas01", 12853 )
end)
engineSetAsynchronousLoading ( true, false )

removeWorldModel(12853, 1000, 666.7109, -565.1328, 17.3359);
removeWorldModel(13245, 1000, 666.7109, -565.1328, 17.3359);
createObject ( 12853, 666.7109, -565.1328, 17.3359,0,0,0 )
