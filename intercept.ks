parameter ves is target.
parameter finalDistance is 20000.

local inclTolerance is 1.
local timeMargin is 120.

if relativeInclination(ship, ves) > inclTolerance
{
	notify("Relative inclination too big: " + relativeInclination(ship, ves)).
}

lock r1 to relToBody(ship).
lock r2 to relToBody(ves).	
lock v1 to ship:velocity:orbit.
lock v2 to ves:velocity:orbit.

lock orbitNormal to orbitNormal(ship).
lock targetAngle to signedAngle(r1, r2, orbitNormal).

local interceptHeight is 0.
if ves:orbit:apoapsis - ves:orbit:periapsis > finalDistance / 2
{
	notify("Eccentric orbit - approaching at apoapsis").
	set interceptHeight to ves:orbit:apoapsis.
}
else
{
	notify("Circular orbit - approaching at apoapsis").
	set interceptHeight to ves:orbit:apoapsis + finalDistance / 2.
}

// Enter intercept orbit
apoChangeNode(interceptHeight).
execNode().
periChangeNode().
execNode().
wait 5.
notify("In intercept orbit, waiting for encounter").

local angSpeedRel is 360 * (1/ves:orbit:period - 1/ship:orbit:period).
notify("Relative angual speed: " + angSpeedRel + ", Angle to target: targetAngle").

until ves:position:mag < finalDistance
{
	// Warp to the point where the ship is close to the target
	local dt is (360 - targetAngle) / angSpeedRel.
	notify("Time until synchronization: " + dt).
	warpFor(dt - timeMargin).
	wait 5.

	// Wait until the distance starts increasing
	notify("Waiting for closest approach").
	local dist is ves:position:mag.
	until ves:position:mag > dist
	{
		set dist to ves:position:mag.
		wait 1.
	}
}


notify("Orbital encounter complete").