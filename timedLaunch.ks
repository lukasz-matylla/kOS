parameter ves is target.
parameter orbitHeight is ves:orbit:periapsis.
parameter initialTurn is 30.
parameter angleMargin is 1.

run once lib_vectors.
run once lib_notify.
run once lib_orbit.

local warpMargin is 15.

notify("Timing launch into plane and direction of " + ves:name).

local targetNorm is orbitNormal(ves).
local planetAxis is ship:body:angularvel:normalized.

if vang(targetNorm, planetAxis) < angleMargin
{
	if targetNorm*planetAxis > 0
	{
		notify("Launching into a simple equatorial orbit").
		run ascent(orbitHeight, 0, initialTurn).
	}
	else
	{
		notify("Launching into a reverse equatorial orbit").
		run ascent(orbitHeight, 180, initialTurn).
	}
}
else
{
	notify("Launching into an inclined orbit").
	
	// Find the angle from current position to the AN/DN
	local crossDirection is vcrs(targetNorm, planetAxis):normalized.
	lock myR to -ship:body:position.
	lock angleToCross to signedAngle(myR, crossDirection, planetAxis).
	
	// Get the nearest of AN and DN
	if angleToCross > 180
	{
		set angleToCross to angleToCross - 180.
	}
	
	local timeToLaunch is ship:body:rotationPeriod * angleToCross / 360.
	local launchTime is time:seconds + timeToLaunch.
	notify("Launching in " + timeToLaunch + seconds).
	
	if (timeToLaunch > warpMargin)
	{
		warpFor(timeToLaunch - warpMargin).
	}
	wait until abs(angleToCross) < angleMargin.
	
	local inc is signedAngle(targetNorm, planetAxis, myR).
	notify("Launching into inclination of " + inc + " degrees").
	
	ascent(orbitHeight, inc, initialTurn, turnSpeed, gtSpeed).
}