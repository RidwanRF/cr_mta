local corp_ped = {}
addEventHandler( "onClientResourceStart", resourceRoot,
	function ()
		for k,v in ipairs(corpBankPedPos) do
			corp_ped[k] = createPed(corpBankPedPos[k][1],corpBankPedPos[k][2],corpBankPedPos[k][3],corpBankPedPos[k][4])	
			setElementRotation(corp_ped[k], 0, 0, v[5])
			setElementDimension(corp_ped[k], v[6])
			setElementInterior(corp_ped[k], v[7])
			setElementFrozen(corp_ped[k], true)
			setElementData(corp_ped[k], "ped >> bankAdministrator", true)
			setElementData(corp_ped[k], "bank >> bankAdministratorID", k)
			setElementData(corp_ped[k], "ped.name", v[8])
			setElementData(corp_ped[k], "ped.type", v[9])			
			setElementData(corp_ped[k], "char >> noDamage", true)			
		end
	end
)