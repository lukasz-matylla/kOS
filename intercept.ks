run once lib_vectors.
run once lib_notify.
run once lib_orbit.
run once lib_maneuver.

parameter ves is target.
parameter maxDv is 100.

local periSafetyMargin is 1.1.
local inclinationMargin is 1.
local warpMargin is 60.

function performIntercept
{
	parameter interceptDir.
	
	// Find the time to closest pass of the intercept point
	local timeToManeuver is timeToDirection(interceptDir, ship).
	local targetTime is timeToDirection(interceptDir, ves).
	local targetPeriod is ves:orbit:period.
	local myPeriod is ship:orbit:period.
	local delta is targetTime - timeToManeuver.
	
	// Set up a maneuver to change orbit period to meet with the target at this point
	local n is node(timeToManeuver, 0, 0, 0).
	add n.
	
	// How many my and target's orbits will pass until intercept
	local myMult is 1.
	local targetMult is 0.
	
	until false
	{
		until delta + targetMult*targetPeriod > myMult * myPeriod
		{
			set targetMult to targetMult + 1.
		}
		
		local timeToIntercept is delta + targetMult*targetPeriod.
		setPeriodChange(n, timeToIntercept / myMult, myPeriod).
		
		if (n:deltav:mag < maxDv)
		{
			// We can get the intercept with acceptable dV expenditure - we'll use the current node
			break.
		}
		else
		{
			// Let's try doing it in more orbits
			set myMult to myMult + 1.
		}
	}
	
	notify("Setting up intercept after " + myMult + " orbits").
	execNode().
	
	notify("Warping close to the intercept point").
	warpFor(ship:orbit:period*myMult - warpMargin).
	
}

local minOrbitHeight is ves:body:atm:height * periSafetyMargin.
if relativeInclination(ship, ves) > inclinationMargin
{
	notify("Relative inclination too big " + relativeInclination(ship, ves)).
}

notify("Preparing to intercept " + ves:name).

if ves:orbit:periapsis < minOrbitHeight or abs(ves:orbit:periapsis - alt:apoapsis) > abs(ves:orbit:apoapsis - alt:periapsis)
{
	notify("Intercepting at apoapsis").
	
	// Get to circular orbit that touches target's orbit at apoapsis
	resizeOrbit(ves:orbit:apoapsis).
	
	// Direction from planet to the intercept point
	local apoDir is -periDirection(ves).
	
	// Calculate and execute intercept maneuver
	performIntercept(apoDir).
}
else
{
	notify("Intercepting at periapsis").
	
	// Get to circular orbit that touches target's orbit at apoapsis
	resizeOrbit(ves:orbit:periapsis).
	
	// Direction from planet to the intercept point
	local periDir is periDirection(ves).
	
	// Calculate and execute intercept maneuver
	performIntercept(periDir).
}

notify("Waiting for closest approach").
	
local dist is ship:orbit:semimajoraxis * 2.
until ves:position:mag > dist
{
	set dist to ves:position:mag.
	wait 1.
}

notify("Killing relative velocity").
relativeStop(ves).

notify("Intercept achieved at distance of " + ves:position:mag + "m").