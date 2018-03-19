parameter ves is target.

run once lib_vectors.
run once lib_maneuver.
run once lib_notify.
run once lib_orbit.

local angleTolerance is 0.01.

local nor is orbitNormal(ship).
local pc is planeCross(ves, ship).

local n1 is orbitNormal(ship).
local n2 is orbitNormal(ves).

if vang(n1, n2) < angleTolerance
{
	notify("Orbits already aligned. Nothing to do.").
}
else
{
	notify("Preparing for alignment maneuver").
	local dt is min(timeToDirection(pc, ship), timeToDirection(-pc, ship)).
	local t is time:seconds + dt.

	local p is positionat(ship, t).
	local alfa is signedAngle(n1, n2, p).
	local v1 is velocityAt(ship, t):orbit.
	local v2 is angleaxis(alfa, p) * v1.
	local dv is v2 - v1.

	notify("Setting up maneuver").
	local n is node(t, 0, dv * n1, dv * v1:normalized).
	add n.
	execNode().
	
	set n1 to orbitNormal(ship).
	set alfa to signedAngle(n1, n2, p).
	notify("Alignment complete. Relative inclination is " + alfa).
}






