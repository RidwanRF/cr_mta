size = {
    ["bank-bg-X"] = 1920,
    ["bank-bg-Y"] = 1080,
    ["keypad-bg-X"] = 1920,
    ["keypad-bg-Y"] = 1080,    
	["createAccount-bg-X"] = 1920,
    ["createAccount-bg-Y"] = 1080,
    ["keypad-size"] = 35,
}

colors = {
	bg = tocolor(0, 0, 0, 255/100*75),
	hover = tocolor(255, 153, 51, 180),
	second = tocolor(74, 158, 222, 180),
	delete = tocolor(215, 151, 68, 180),
	logout = tocolor(215, 68, 68, 180),
	white = tocolor(255, 255, 255),
	orange = tocolor(255, 153, 51),
	black = tocolor(0, 0, 0),
};

bankPedPos = {
	-- {skinid,x, y, z, rotz, dim, int, c1, c2, c3, c4, c5, c6 (c = camera matrix)}
	[1] = {51,1949.537109375,-1765.1444091797,13.546875,90,0,0, "Isabelle", "Banki magánszemély ügyintéző"},
	[2] = {40,1949.3972167969, -1766.7486572266, 13.546875,90,0,0, "DeAnté", "Banki magánszemély ügyintéző"},
};

corpBankPedPos = {
	-- {skinid,x, y, z, rotz, dim, int, c1, c2, c3, c4, c5, c6 (c = camera matrix)}
	[1] = {56,1949.3006591797, -1768.6307373047, 13.546875,90,0,0, "Francesco", "Banki céges ügyintéző"},
	[2] = {53,1949.0874023438, -1769.9323730469, 13.546875,90,0,0, "Madyson", "Banki céges ügyintéző"},
};

bankPedCamPos = {
	[1] = {1945.3067626953,-1765.2231445313,15.369899749756,1946.2437744141,-1765.2225341797,15.020463943481,0,70},
	[2] = {1944.7325439453,-1767.0313720703,15.028100013733,1945.6938476563,-1766.9818115234,14.757305145264,0,70},
};

function loadCamTables()
	return bankPedCamPos
end	
loadCamTables()

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
     if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
          local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
          if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
               for i, v in ipairs( aAttachedFunctions ) do
                    if v == func then
        	         return true
        	    end
	       end
	  end
     end
     return false
end
