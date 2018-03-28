local stagingDelay is 0.5.
local thrustMargin is 0.8.
local fullThrust is 0.
local stagingFreezed is false.

function SafeStage
{
	lock throttle to 0.
	
	wait until stage:ready. // Make sure that staging is possible now
	wait stagingDelay.
	stage.
	wait stagingDelay.
	
	if ship:maxThrust > 0
	{
		set fullThrust to ship:maxThrust.
		lock throttle to thr.
		return true.
	}
	else
	{
		notify("No more powered stages").
		return false.
	}
}

function FreezeStaging
{
	set stagingFreezed to true.
}

function UnfreezeStaging
{
	set stagingFreezed to false.
}

when ship:maxThrust > 0 then // Launched
{
	set fullThrust to ship:maxThrust.

	when ship:maxThrust < fullThrust*thrustMargin and not stagingFreezed then // Something ran out of fuel
	{
		notify("Staging").
		if SafeStage()
		{
			preserve.
		}
	}
}