local cache = {}

local server = true
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        server = false
    end
)

function getTriggerName(triggerName)
	return exports['cr_protect']:getTriggerName(getThisResource(), triggerName)
end

_addEvent = addEvent
function addEvent(eventName, allowRemoteTrigger)
	cache[eventName] = true
    eventName = getTriggerName(eventName)
	_addEvent(eventName, allowRemoteTrigger)
end

_addEventHandler = addEventHandler
function addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	if cache[eventName] then
		eventName = getTriggerName(eventName)
		_addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	else
		_addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	end
end

_removeEventHandler = removeEventHandler
function removeEventHandler(eventName, attachedTo, functionVar)
	if cache[eventName] then
        eventName = getTriggerName(eventName)
		cache[eventName] = nil
	end
	_removeEventHandler(eventName, attachedTo, functionVar)
end

_triggerEvent = triggerEvent
function triggerEvent(eventName, ...)
    eventName = getTriggerName(eventName)
	_triggerEvent(eventName, ...)
end

if type(triggerServerEvent) == "function" then
	_triggerServerEvent = triggerServerEvent
	function triggerServerEvent(eventName, ...)
        eventName = getTriggerName(eventName)
		_triggerServerEvent(eventName, ...)
	end
end

if type(triggerClientEvent) == "function" then
	_triggerClientEvent = triggerClientEvent
	function triggerClientEvent(sourceElement, eventName, ...)
        eventName = getTriggerName(eventName)
		_triggerClientEvent(sourceElement, eventName, ...)
	end
end