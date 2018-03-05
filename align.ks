parameter ves is target.

run once lib_vectors.
run once lib_maneuver.
run once lib_notify.

local angleTolerance is 0.5.

local nor is orbitNormal(ship).
local pc is planeCross(ves, ship).
local angleToCross is signedAngle(-ship:body:position, pc, nor).
if angleToCross > 180 // Get the closer of AN and DN
{
	set angleToCross to angleToCross - 180.
}

local dt is timeToAngle(angleToCross).
local t is time:seconds + dt.
local n1 is orbitNormal(ship).
local n2 is orbitNormal(ves).
local p is positionat(ship, t).
local alfa is signedAngle(n1, n2, p).
local v1 is velocityAt(ship, t).
local v2 is angleaxis(alfa, p) * v1.
local dv is v2 - v1.

if vang(n1, n2) < angleTolerance
{
	notify("Orbits already aligned. Nothing to do.").
}
else
{
	notify("Preparing for alignment maneuver").
	local n is node(t, 0, dv * n1, dv * v1:normalized).
	add n.
	execNode().
	
	set n1 to orbitNormal(ship).
	set alfa to signedAngle(n1, n2, p).
	notify("Alignment complete. Relative inclination is " + alfa).
}


