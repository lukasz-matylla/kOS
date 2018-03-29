run once lib_notify.

function SaveGame
{
	parameter eventName is "<something>".
	
	wait 3.
	
	if kuniverse:canquicksave
	{
		set saveName to ship:name + " before " + eventName.
		kuniverse:quicksaveto(saveName).
		notify("Saved as '" + saveName + "'").
	}
	else
	{
		notify("Cannot save '" + saveName + "' at this time").
	}
}