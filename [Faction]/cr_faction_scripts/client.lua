sx, sy = guiGetScreenSize();
radioSound = false;

addEvent("playRadioSoundClient", true)
addEventHandler("playRadioSoundClient", root, function() 
	if(not radioSound) then
		radioSound = playSound("files/radioSound.mp3")
		setSoundVolume(radioSound, 1)
		setTimer(function() 
			radioSound = false
		end, 1500, 1)
	end
end)