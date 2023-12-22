-- 14802
--local kreszid = 14802

function addkreszobject(dffneve,txdneve,kreszid)
	--outputDebugString("TXD: " .. txdneve .. " ~ DFF: " .. dffneve .. " ~ ID: " .. kreszid .. "", 3)
	--[[	outputDebugString('CONF: removeWorldModel(' .. tonumber(kreszid) .. ',10000,0,0,0) -- először töröljük!', 3)
		outputDebugString('CONF: ', 3)
		outputDebugString('CONF: txd = engineLoadTXD("files/' .. tostring(txdneve) .. '.txd")', 3)
		outputDebugString('CONF: engineImportTXD(txd, ' .. tonumber(kreszid) .. ')', 3)
		outputDebugString('CONF: col = engineLoadCOL("files/kresz.col")', 3)
		outputDebugString('CONF: ', 3)
		outputDebugString('CONF: engineReplaceCOL(col, ' .. tonumber(kreszid) .. ')', 3)
		outputDebugString('CONF: engineSetModelLODDistance(' .. tonumber(kreszid) .. ', 100)', 3)
		outputDebugString('CONF: ', 3)
		outputDebugString('CONF: engineLoadDFF("files/' .. tostring(dffneve) .. '.dff", ' .. tonumber(kreszid) .. ')', 3)
		outputDebugString('CONF: engineReplaceModel(dff, ' .. tonumber(kreszid) ..')', 3)
		outputDebugString('CONF: ', 3)
		outputDebugString('CONF: ', 3) ]]--
	removeWorldModel(tonumber(kreszid),10000,0,0,0) -- először töröljük!
	--setOcclusionsEnabled(false)
	local txd = engineLoadTXD("files/" .. tostring(txdneve) .. ".txd")
    engineImportTXD(txd, tonumber(kreszid))
	
    local col = engineLoadCOL("files/kresz.col")
    engineReplaceCOL(col, tonumber(kreszid))
    engineSetModelLODDistance(tonumber(kreszid), 150)
	
    local dff = engineLoadDFF("files/" .. tostring(dffneve) .. ".dff", tonumber(kreszid))
    engineReplaceModel(dff, tonumber(kreszid))
end

function replaceut(id,txdnev)
	local txd = engineLoadTXD("files/utak/"..txdnev..".txd")
    engineImportTXD(txd, id)
end

addEventHandler( "onClientResourceStop", getResourceRootElement(),
    function ()
		--restoreAllWorldModels()
		--outputChatBox("Kresz táblák kikapcsolva")
    end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
    function()
		engineSetAsynchronousLoading(true,true)
		setTrafficLightState(9)
		removeWorldModel(1262,10000,0,0,0)
		removeWorldModel(1283,10000,0,0,0)
		removeWorldModel(1284,10000,0,0,0)
		removeWorldModel(1350,10000,0,0,0)
		removeWorldModel(1315,10000,0,0,0)
		removeWorldModel(3516,10000,0,0,0)
		removeWorldModel(3855,10000,0,0,0)
		removeWorldModel(1352,10000,0,0,0)
		removeWorldModel(1351,10000,0,0,0)
		removeWorldModel(1676,10000,0,0,0)
		removeWorldModel(1686,10000,0,0,0)
		removeWorldModel(1244,10000,0,0,0)
		removeWorldModel(3465,10000,0,0,0)
        --outputChatBox("Kresz")
		
		for i=1, 55 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz5"
			
			if(i == 1) then
				kreszid = 11453 -- Behajtani tilos mindkét irányból
			end
			if(i == 2) then
				kreszid = 11461 -- személygépjárművel behajtanitilos
			end
			if(i == 3) then
				kreszid = 11543 -- motorkerékpárral behajtani tilos
			end
			if(i == 4) then
				kreszid = 11544 -- busz behajtani tilos
			end
			if(i == 5) then
				kreszid = 14886 -- teherautó behajtani tilos
			end
			if(i == 6) then
				kreszid = 14887 -- 3,5 tonna fölött teherautó behajtani tilos
			end
			if(i == 7) then
				kreszid = 1601 -- 5 tonna fölött teherautó behajtani tilos
			end
			if(i == 8) then
				kreszid = 16095 --10 tonna fölött behajtani tilos
			end
			if(i == 9) then
				kreszid = 16323 -- traktorral behajtani tilos
			end
			if(i == 10) then
				kreszid = 16396 -- jobb bal sáv
			end
			if(i == 11) then
				kreszid = 3064 -- kamion vontatmány behajtani tilos
			end
			if(i == 12) then
				kreszid = 3277 -- motorkerékpárral behajtani tilos
			end
			if(i == 13) then
				kreszid = 3432 -- kerékpárral behajtani tilos
			end
			if(i == 14) then
				kreszid = 3433 -- talicskával behajtani tilos
			end
			if(i == 15) then
				kreszid = 3435 -- lovaskocsival behajtani tilos
			end
			if(i == 16) then
				kreszid = 3438 -- sárga teherótó
			end
			if(i == 17) then
				kreszid = 3444 -- behajtani tilos egyirányú 
			end
			if(i == 18) then
				kreszid = 3466 -- motorkerékpárral és személygépjárművel behajtani tilos
			end
			if(i == 19) then
				kreszid = 7978 -- traktor motorkerékpár lovaskocsival behajtani tilos
			end
			if(i == 20) then
				kreszid = 7984 -- 2,2 m szélesség 
			end
			if(i == 21) then
				kreszid = 8037 -- 3,2 magasság
			end
			if(i == 22) then
				kreszid = 8038 -- 10 méter hosszúság
			end
			if(i == 23) then
				kreszid = 8040 -- 5,5 tonna felett behajtani tilos
			end
			if(i == 24) then
				kreszid = 8067 -- 2,5 tengelysúly
			end
			if(i == 25) then
				kreszid = 8081 -- jobbra kanyarodni tilos
			end
			if(i == 26) then
				kreszid = 8082 -- balra kanyarodni tilos
			end
			if(i == 27) then
				kreszid = 8083 -- vám/zoll
			end
			if(i == 28) then
				kreszid = 8084 -- visszafordulni tilos
			end
			if(i == 29) then
				kreszid = 8085 -- 5 km/h
			end
			if(i == 30) then
				kreszid = 8086 -- 10 km/h
			end
			if(i == 31) then
				kreszid = 8087 -- 20 km/h
			end
			if(i == 32) then
				kreszid = 8134 -- 30 km/h
			end
			if(i == 33) then
				kreszid = 8201 -- 40 km/h
			end
			if(i == 34) then
				kreszid = 8245 -- 50 km/h
			end
			if(i == 35) then
				kreszid = 8247 -- 60 km/h
			end
			if(i == 36) then
				kreszid = 8249 -- 70 km/h
			end
			if(i == 37) then
				kreszid = 8251 -- 80 km/h
			end
			if(i == 38) then
				kreszid = 8283 -- 90 km/h
			end
			if(i == 39) then
				kreszid = 8286 -- 100 km/h
			end
			if(i == 40) then
				kreszid = 8287 -- 110 km/h
			end
			if(i == 41) then
				kreszid = 8333 -- 120 km/h
			end
			if(i == 42) then
				kreszid = 8370 -- 130 km/h
			end
			if(i == 43) then
				kreszid = 8371 -- 70 méter követési távolság
			end
			if(i == 44) then
				kreszid = 8391 -- teherautó 30 méter követési távolság
			end
			if(i == 45) then
				kreszid = 8392 -- előzési tilalom
			end
			if(i == 46) then
				kreszid = 8393 -- teherautó előzési tilalom
			end
			if(i == 47) then
				kreszid = 8394 -- 30 as övezet
				dffneve = "kresz1"
			end
			if(i == 48) then
				kreszid = 8396 -- 40 es övezet
				dffneve = "kresz1"
			end
			if(i == 49) then
				kreszid = 8397 -- 30 as övezet vége
				dffneve = "kresz1"
			end
			if(i == 50) then
				kreszid = 8399 -- 40 es övezet vége
				dffneve = "kresz1"
			end
			if(i == 51) then
				kreszid = 8400 -- korlátozás feloldás
			end
			if(i == 52) then
				kreszid = 8402 -- várakozni és megállni tilos
			end
			if(i == 53) then
				kreszid = 8404 -- várakozni tilos
			end
			if(i == 54) then
				kreszid = 8405 -- négyzet várakozni tilos
				dffneve = "kresz1"
			end
			if(i == 55) then
				kreszid = 8408 -- négyzet várakozni tilos vége
				dffneve = "kresz1"
			end
			if(i <= 9) then
				txdneve = "kresz_ti0".. i
			else
				txdneve = "kresz_ti".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		for i=1, 37 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz6"
			
			if(i == 1) then
				kreszid = 8409 --bal éles kanyar
			end
			if(i == 2) then
				kreszid = 8411 --jobb éles kanyar
			end
			if(i == 3) then
				kreszid = 8412 -- dupla bal kanyar
			end
			if(i == 4) then
				kreszid = 8416 -- dupla jobb kanyar
			end
			if(i == 5) then
				kreszid = 8419 --12%os lejtő
			end
			if(i == 6) then
				kreszid = 8421 --12%os emelkedő
			end
			if(i == 7) then
				kreszid = 8422 -- sávszűkület
			end
			if(i == 8) then
				kreszid = 8423 --jobbsávszűkület
			end
			if(i == 9) then
				kreszid = 8425 --balsávszűkület
			end
			if(i == 10) then
				kreszid = 8426 --kétirányú forgalom
			end
			if(i == 11) then
				kreszid = 8427 --önműködő híd
			end
			if(i == 12) then
				kreszid = 8428 --leesés veszély
			end
			if(i == 13) then
				kreszid = 8429 --fekvő rendőr
			end
			if(i == 14) then
				kreszid = 8430 --emelkedő bukkanó
			end
			if(i == 15) then
				kreszid = 8431 --csúszós út
			end
			if(i == 16) then
				kreszid = 8435 --kavicsfelverődés
			end
			if(i == 17) then
				kreszid = 8436 --omlásveszély
			end
			if(i == 18) then
				kreszid = 8437 --építési munkálatok
			end
			if(i == 19) then
				kreszid = 8460 --útzárlat
			end
			if(i == 20) then
				kreszid = 8461 --alacsonyan repülő repülő
			end
			if(i == 21) then
				kreszid = 8462 --nagy szél
			end
			if(i == 22) then
				kreszid = 8468 --gyalogátkelő
			end
			if(i == 23) then
				kreszid = 8480 --gyerek anya vigyázz
			end
			if(i == 24) then
				kreszid = 8482 --gyerekek vigyázz
			end
			if(i == 25) then
				kreszid = 8483 -- vigyázz biciklis
			end
			if(i == 26) then
				kreszid = 8489 -- vigyázz tehén
			end
			if(i == 27) then
				kreszid = 8491 --szarvas vigyázz
			end
			if(i == 28) then
				kreszid = 8492 --vigyázz lámpa
			end
			if(i == 29) then
				kreszid = 8493 -- egyenrangú útkereszteződés
			end
			if(i == 30) then
				kreszid = 8494 -- alárendelt útkereszteződés
			end
			if(i == 31) then
				kreszid = 8495 -- alárendelt útkereszteződés balról
			end
			if(i == 32) then
				kreszid = 8496 -- alárendelt útkereszteződés jobbról
			end
			if(i == 33) then
				kreszid = 8497 -- körforgalom
			end
			if(i == 34) then
				kreszid = 8498 -- villamos
			end
			if(i == 35) then
				kreszid = 8499 -- vonat
			end
			if(i == 36) then
				kreszid = 8501 -- vasúti kereszteződés	jelzőőr nélkül
			end
			if(i == 37) then
				kreszid = 8503 -- figyelmeztetés
			end
			if(i <= 9) then
				txdneve = "kresz_ve0".. i
			else
				txdneve = "kresz_ve".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		for i=1, 29 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz5"
			
			if(i == 1) then
				kreszid = 8504 -- kötelező haladási irány egyenes
			end
			if(i == 2) then
				kreszid = 8505 -- haladási irány jobbra és egyenes
			end
			if(i == 3) then
				kreszid = 8506 -- kötelező haladási egyenes és balra
			end
			if(i == 4) then
				kreszid = 8507 -- kötelező haladási irány balra
			end
			if(i == 5) then
				kreszid = 8508 -- kötelező haladási irány jobbra
			end
			if(i == 6) then
				kreszid = 8509 -- kötelező haladási irány balra és balra vissza
			end
			if(i == 7) then
				kreszid = 8516 -- kötelező haladási irány jobbra és jobbra vissza
			end
			if(i == 8) then
				kreszid = 8526 -- bal irány
			end
			if(i == 9) then
				kreszid = 8527 -- jobbra lehetőség csak
			end
			if(i == 10) then
				kreszid = 8528 -- jobb bal lehetőség
			end
			if(i == 11) then
				kreszid = 8530 -- 30 minimum
			end
			if(i == 12) then
				kreszid = 8532 -- 40 minimum
			end
			if(i == 13) then
				kreszid = 8534 -- 50 minimum
			end
			if(i == 14) then
				kreszid = 8535 -- 30 minimum vége
			end
			if(i == 15) then
				kreszid = 8536 -- 40 minimum vége 
			end
			if(i == 16) then
				kreszid = 8537 -- 50 minimum vége
			end
			if(i == 17) then
				kreszid = 8547 -- bicikliút
			end
			if(i == 18) then
				kreszid = 8548 -- bicikliút vége
			end
			if(i == 19) then
				kreszid = 8549 -- vigyázz gyerek felnőtt
			end
			if(i == 20) then
				kreszid = 8551 -- vigyázz gyerek felnőtt vége
			end
			if(i == 21) then
				kreszid = 8553 -- gyerek felnőtt biciklis
			end
			if(i == 22) then
				kreszid = 8554 -- gyerek felnőtt biciklis párhuzamos
			end
			if(i == 23) then
				kreszid = 8563 -- gyalogos biciklis párhuzamos vége
			end
			if(i == 24) then
				kreszid = 8564 -- gyerek felnőtt biciklis párhuzamos vége
			end
			if(i == 25) then
				kreszid = 8565 -- gyerek felnőtt zóna
				dffneve = "kresz1"
			end
			if(i == 26) then
				kreszid = 8566 -- gyerek felnőtt zóna vége
				dffneve = "kresz1"
			end
			if(i == 27) then
				kreszid = 8567 --  gyerek felnőtt zóna bicikli
				dffneve = "kresz1"
			end
			if(i == 28) then
				kreszid = 8568 -- gyerek felnőtt zóna bicikli vége
				dffneve = "kresz1"
			end
			if(i == 29) then
				kreszid = 8589 -- körforgalom
			end
			
			if(i <= 9) then
				txdneve = "kresz_us0".. i
			else
				txdneve = "kresz_us".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		
		for i=1, 4 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz1"
			
			if(i == 1) then
				kreszid = 8591 -- autópálya
			end
			if(i == 2) then
				kreszid = 8593 -- autópálya vége
			end
			if(i == 3) then
				kreszid = 8594 -- autóút
			end
			if(i == 4) then
				kreszid = 8595 -- autóút vége
			end
			
			if(i <= 9) then
				txdneve = "kresz_ut0".. i
			else
				txdneve = "kresz_ut".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		
		for i=1, 48 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz1"
			
			if(i == 1) then
				kreszid = 8596 -- gyalogátkelő
			end
			if(i == 2) then
				kreszid = 8607 -- lépcső
			end
			if(i == 3) then
				kreszid = 8608 -- egyirányú
			end
			if(i == 4) then
				kreszid = 8618 -- egyirányú bal irány
			end
			if(i == 5) then
				kreszid = 8620 -- zsákutca
			end
			if(i == 6) then
				kreszid = 8639 -- zsákutca biciklivel
			end
			if(i == 7) then
				kreszid = 8641 -- buszmegálló
			end
			if(i == 8) then
				kreszid = 8643 -- troli megálló
			end
			if(i == 9) then
				kreszid = 8644 -- villamos megálló
			end
			if(i == 10) then
				kreszid = 8654 -- taxi
			end
			if(i == 11) then
				kreszid = 8655 -- parkoló
			end
			if(i == 12) then
				kreszid = 8663 -- nyomorék parkoló
			end
			if(i == 13) then
				kreszid = 8664 -- parkoló zóna
			end
			if(i == 14) then
				kreszid = 8666 -- parkoló zóna vége
			end
			if(i == 15) then
				kreszid = 8667 -- vöröskereszt
			end
			if(i == 16) then
				kreszid = 8668 -- kórház
			end
			if(i == 17) then
				kreszid = 8669 -- szerelőműhely
			end
			if(i == 18) then
				kreszid = 8671 -- telefon
			end
			if(i == 19) then
				kreszid = 8676 -- benzinkút
			end
			if(i == 20) then
				kreszid = 8677 -- benzinkút +
			end
			if(i == 21) then
				kreszid = 8678 -- benzinkút ++
			end
			if(i == 22) then
				kreszid = 8680 -- traffic control
			end
			if(i == 23) then
				kreszid = 8681 -- Rendőrség
			end
			if(i == 24) then
				kreszid = 8682 -- információ
			end
			if(i == 25) then
				kreszid = 8683 -- túrista információ
			end
			if(i == 26) then
				kreszid = 8684 -- múzeum
			end
			if(i == 27) then
				kreszid = 8685 -- műemlék
			end
			if(i == 28) then
				kreszid = 8686 -- műemlék 2
			end
			if(i == 29) then
				kreszid = 8687 -- műemlék 3
			end
			if(i == 30) then
				kreszid = 8688 -- pihenő ágy
			end
			if(i == 31) then
				kreszid = 8689 -- ház fenyő
			end
			if(i == 32) then
				kreszid = 8710 -- kemping
			end
			if(i == 33) then
				kreszid = 8833 -- lakókocsi
			end
			if(i == 34) then
				kreszid = 8834 -- lakókocsi kemping
			end
			if(i == 35) then
				kreszid = 8840 -- p + r
			end
			if(i == 36) then
				kreszid = 8842 -- vonat
			end
			if(i == 37) then
				kreszid = 8845 -- hajó
			end
			if(i == 38) then
				kreszid = 8849 -- repülő
			end
			if(i == 39) then
				kreszid = 8881 -- önműködő híd
			end
			if(i == 40) then
				kreszid = 8882 -- erdő
			end
			if(i == 41) then
				kreszid = 8969 -- ember pálcával
			end
			if(i == 42) then
				kreszid = 8981 -- síelő
			end
			if(i == 43) then
				kreszid = 9037 -- úszás
			end
			if(i == 44) then
				kreszid = 9039 -- lovaglás
			end
			if(i == 45) then
				kreszid = 9044 -- étterem
			end
			if(i == 46) then
				kreszid = 9045 -- kávé
			end
			if(i == 47) then
				kreszid = 9046 -- ívóvíz
			end
			if(i == 48) then
				kreszid = 9054 -- wc
			end
--[[			if(i == 49) then
				kreszid = 8534 -- 
			end
			if(i == 50) then
				kreszid = 8535 -- 
			end
			if(i == 51) then
				kreszid = 8536 -- 
			end
			if(i == 52) then
				kreszid = 8537 -- 
			end
			if(i == 53) then
				kreszid = 8547 -- 
			end
			if(i == 54) then
				kreszid = 8548 -- 
			end
			if(i == 55) then
				kreszid = 8551 -- 
			end ]]--
			
			if(i <= 9) then
				txdneve = "kresz_tj0".. i
			else
				txdneve = "kresz_tj".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		
		for i=1, 4 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "vel"
			
			if(i == 1) then
				kreszid = 9055 -- STOP
				dffneve = "kresz3"
			end
			if(i == 2) then
				kreszid = 9066 -- elsőbbségadás kötelező
				dffneve = "kresz4"
			end
			if(i == 3) then
				kreszid = 9070 -- elsőbbség a szembből érkezőnek
				dffneve = "kresz5"
			end
			if(i == 4) then
				kreszid = 9071 -- elsőbbség nekem
				dffneve = "kresz1"				
			end
			
			if(i <= 9) then
				txdneve = "kresz_es0".. i
			else
				txdneve = "kresz_es".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		
		for i=1, 12 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz7"
			
			if(i == 1) then
				kreszid = 9072 -- balra kanyarodó főút
			end
			if(i == 2) then
				kreszid = 9076 -- stop 100 m
			end
			if(i == 3) then
				kreszid = 9078 -- 100 m
			end
			if(i == 4) then
				kreszid = 9080 -- kivéve célforgalom
			end
			if(i == 5) then
				kreszid = 9132 -- kivéve áruszállítás
			end
			if(i == 6) then
				kreszid = 9159 -- 09-19h
			end
			if(i == 7) then
				kreszid = 9162 -- kivéve engedéllyel
			end
			if(i == 8) then
				kreszid = 9163 -- kivéve taxi
			end
			if(i == 9) then
				kreszid = 9174 -- kivéve célforgalom 09-19h
			end
			if(i == 10) then
				kreszid = 9036 -- kivéve áruszállítás 07-19h
			end
			if(i == 11) then
				kreszid = 8132 -- kivéve bicikli
			end
			if(i == 12) then
				kreszid = 8034 -- kivéve autóbusz
			end
			
			if(i <= 9) then
				txdneve = "kresz_ki0".. i
			else
				txdneve = "kresz_ki".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
		
		for i=1, 2 do
			local txdneve = " "
			local kreszid = 0
			local dffneve = "kresz2"
			
			if(i == 1) then
				kreszid = 8079 -- főútvonal
			end
			if(i == 2) then
				kreszid = 8675 -- főútvonal vége
			end
			
			if(i <= 9) then
				txdneve = "kresz_fu0".. i
			else
				txdneve = "kresz_fu".. i
			end
			addkreszobject(dffneve,txdneve,kreszid)
		end
    end
)