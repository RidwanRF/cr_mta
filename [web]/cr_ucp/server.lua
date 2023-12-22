local spamPrevent = {};
local tokenTimer = nil;
local elapsedMins = 0;
local players = {};

function callback() 
	-- outputDebugString("UCP timer végrehajtva.")
end

function callback2(res) 
	-- outputDebugString(tostring(res))
end

addEventHandler("onResourceStart", resourceRoot, function() 
	tokenTimer = setTimer(function() 
		callRemote("https://ucp.staymta.com/timers.php", callback)
		elapsedMins = elapsedMins+1
		if(elapsedMins/60 == math.floor(elapsedMins/60)) then
			table.insert(players, getPlayerCount())
		end
	end, 60000, 0)
	for i=1, 24 do
		table.insert(players, 0)
	end
	table.insert(players, getPlayerCount())
end)

function sendUCPMessage(msg)
	outputChatBox(tostring(msg), root, 255, 255, 255, true)
end

function changePassword(uname, newpw)
	if(not spamPrevent[uname]) then
		spamPrevent[uname] = setTimer(function(u) 
			spamPrevent[u] = nil
		end, 2000, 1, uname)
		if getPlayerCount() > 0 then
			triggerEvent("change.accpw", getRandomPlayer(), uname, newpw)
		else
			triggerEvent("change.accpw", root, uname, newpw)
		end
		return "1"
	end
	return "0"
end

function changeMail(uname, newmail)
	if(not spamPrevent[uname]) then
		spamPrevent[uname] = setTimer(function(u) 
			spamPrevent[u] = nil
		end, 2000, 1, uname)
		if getPlayerCount() > 0 then
			triggerEvent("change.accemail", getRandomPlayer(), uname, newmail)
		else
			triggerEvent("change.accemail", root, uname, newmail)
		end
		return "1"
	end
	return "0"
end

function changeSerial(uname)
	if(not spamPrevent[uname]) then
		spamPrevent[uname] = setTimer(function(u) 
			spamPrevent[u] = nil
		end, 2000, 1, uname)
		if getPlayerCount() > 0 then
			triggerEvent("change.accserial", getRandomPlayer(), uname)
		else
			triggerEvent("change.accserial", root, uname)
		end
		return "1"
	end
	return "0"
end

function deactivateUnbanRequest(id)
	callRemote("https://ucp.staymta.com/deactivateUnbanRequest.php", callback2, id)
end

function banPlayer(accID, adminName, accID2, aLevel)
	if getPlayerCount() > 0 then
		triggerEvent("ucpBan", getRandomPlayer(), accID, adminName, accID2, aLevel)
	else
		triggerEvent("ucpBan", root, accID, adminName, accID2, aLevel)
	end
end 

function unbanPlayer(banID, accID, adminName, accID2, aLevel)
	if getPlayerCount() > 0 then
		triggerEvent("ucpUnban", getRandomPlayer(), banID, accID, adminName, accID2, aLevel)
	else
		triggerEvent("ucpUnban", root, banID, accID, adminName, accID2, aLevel)
	end
end

function getServerDetails()
	players[#players] = getPlayerCount()
	return elapsedMins, #getElementsByType("player"), exports.cr_account:getCharacterCount(), exports.cr_sync:getTemperature(), toJSON(players)
end