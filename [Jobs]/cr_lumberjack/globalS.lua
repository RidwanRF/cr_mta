function destroyPileInHand(player)
	local pile = getElementJobData(player, "pileInHand")
	if(pile) then
		pile:destroy()
		setElementJobData(player, "pileInHand", false)
	end
end