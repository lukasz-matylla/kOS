function notify
{
	parameter message.
	
	local logText is ship:name + ", T+" + round(missionTime, 2) + ": " + message.
	
	print logText.
	hudText(logText, 10, 2, 25, green, false).
	log logText to "0:/logs/missionLog.txt".
}

function clearLog
{
	deletepath("0:/logs/missionLog.txt").
}