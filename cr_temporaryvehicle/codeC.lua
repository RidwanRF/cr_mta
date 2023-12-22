addEvent("endJob", true)
function endJob()
	localPlayer:setData("job >> data", false)
	for i, v in pairs(getElementsByType("marker")) do
		local jobData2 = v:getData("job >> data")
		if(jobData2) then
			if(jobData2["starter"] == localPlayer:getData("acc >> id")) then
				triggerServerEvent("deleteJobVehicle", resourceRoot)
			end
		end
	end
	local prefix = exports['cr_core']:getServerSyntax("Job", "warning")
	outputChatBox(prefix.."A munkajárműved törölve lett és a munkád meg lett szakítva.", 255, 255, 255, true)
end
addEventHandler("endJob", resourceRoot, endJob)