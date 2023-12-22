function ChangeObjectModel (filename,id)
	if id and filename then
		if fileExists(filename..".txd") then
			txd = engineLoadTXD(filename..".txd")
			engineImportTXD(txd, id)
		end

		if fileExists(filename..".dff") then
			dff = engineLoadDFF(filename..".dff", 0)
			engineReplaceModel(dff, id)
		end

		if fileExists(filename..".col") then
			col = engineLoadCOL(filename..".col")
			engineReplaceCOL(col, id)
		end

		engineSetModelLODDistance(id, 300)
	end
end

ChangeObjectModel("files/taxilamp", 16307)