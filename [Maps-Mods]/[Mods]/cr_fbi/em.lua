function replaceModel()
	txd = engineLoadTXD("fbihq.txd", 4000)
	engineImportTXD(txd, 4000)
	dff = engineLoadDFF("fbihq.dff", 4000)
	engineReplaceModel(dff, 4000)
	col = engineLoadCOL ("fbihq.col", 4000)
	engineReplaceCOL (col, 4000)

end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)