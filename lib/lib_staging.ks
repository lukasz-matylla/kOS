local stagingDelay is 0.5.
local thrustMargin is 0.8.
local fullThrust is 0.

when ship:maxThrust > 0 then // Launched
{
	set fullThrust to ship:maxThrust.

	when ship:maxThrust < fullThrust*thrustMargin then // Something ran out of fuel
	{
		notify("Staging").
		set lastThrottle to throttle.
		lock throttle to 0.
		wait stagingDelay.
		stage.
		wait stagingDelay.
		
		if ship:maxThrust > 0
		{
			set fullThrust to ship:maxThrust.
			lock throttle to lastThrottle.
			preserve.
		}
		else
		{
			notify("No more powered stages").
		}
	}
}