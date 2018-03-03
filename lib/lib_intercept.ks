run once lib_notify.
run once lib_maneuver.
run once lib_vector.

local speedMargin is 10.
local speedTolerance is 0.1.
local speedScale is 20.

function relativeStop
{
	if not hastarget
	{
		notify("No target selected").
		return.
	}
	
	lock relVel to target:velocity:orbit - ship:velocity:orbit.
	
	lock steering to lookdirup(-relVel, ship:up:vector).
	waitForAlignment().
	lock throttle to relVel:mag / speedMargin.
	wait until relVel:mag < speedTolerance.
	lock throttle to 0.
}

function intercept
{
	parameter finalDistance is 200.

	if not hastarget
	{
		notify("No target selected").
		return.
	}

	lock relPos to target:position.
	lock relVel to target:velocity:orbit - ship:velocity:orbit.
	
	lock targetVel to relPos / speedScale.
	
	lock velCorrection to targetVel - relVel.
	
	lock steering to lookdirup(velCorrection, ship:up:vector).
	lock throttle to relVel:mag / speedMargin.
	wait until relPos:mag < finalDistance.
	lock throttle to 0.
}

function approach
{
	parameter finalDistance is 20000.
	
	if not hastarget
	{
		notify("No target selected").
		return.
	}
	
	if target:orbit:apoapsis - target:orbit:periapsis > finalDistance / 2
	{
		notify("Target orbit is too eccentric").
		return.
	}
	
	// 
	lock r1 to target:position - ship:body:position.	
	lock r2 to -ship:body:position.
	lock v1 to target:velocity:orbit.
	lock v2 to ship:velocity:orbit.
	lock targetAngle to vang(r1, r2).
	
	if vang(vcrs(v1, r2), vcrs(v2, x2)) > inclTolerance
	{
		notify("Relative inclination too big").
		return.
	}
	
	// Circular orbit a little above target
	notify("Setting up intercept orbit").
	local interceptHeight is target:orbit:apoapsis + finalDistance / 2.
	apoChangeNode(interceptHeight).
	execNode().
	periChangeNode().
	execNode().
	wait 5.
	
	local angSpeedRel is 360/(1/ship:orbit:period - 1/target:orbit:period).
	
	// Warp to the point where the ship is close to the target
	// If we end up on the wrong side after the first warp, correct with a second one
	notify("Waiting for synchronization").
	local dt is targetAngle / angRelSpeed.
	warpFor(dt).
	wait 5.
	if targetAngle > 10 // If we end up on the wrong side after the first warp, correct with a second one
	{
		set dt to (360 - targetAngle) / angRelSpeed.
		warpFor(dt).
		wait 5.
	}
	
	// Wait until the distance starts increasing
	notify("Waiting for closest approach").
	local dist is target:position:mag.
	until target:position:mag > dist
	{
		set dist to target:position:mag.
		wait 1.
	}
	
	notify("Initial approach complete").
}	