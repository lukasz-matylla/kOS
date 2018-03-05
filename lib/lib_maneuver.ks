run once lib_notify.
run once lib_vectors.
run once lib_arrows.

local warpMargin is 30.
local orbitMargin is 0.001.
local bigJump is 50.
local smallJump is 0.1.
local speedMargin is 10.
local speedTolerance is 0.1.
local speedScale is 20.
local angleMargin is 0.1.

// Time to complete a maneuver
function mnvTime
{
	parameter dv.
        
	local ens is list(). ens:clear.
	local ens_thrust is 0.
	local ens_dm is 0.
        
	list engines in myengines.

	for en in myengines 
	{
		if en:ignition = true and en:flameout = false and en:availablethrust > 0 and en:isp > 0
		{
			ens:add(en).
	    }
	}

	for en in ens 
	{
		set ens_thrust to ens_thrust + en:availablethrust.
		set ens_dm to ens_dm + en:availablethrust / en:isp.
	}

	if ens_thrust = 0 or ens_dm = 0 
	{
		// May happen if staging during a maneuver
		return 1000000.
	}
	else 
	{
		local f is ens_thrust * 1000. // engine thrust (kg * m/s²)
		local m is ship:mass * 1000. // starting mass (kg)
		local e is constant():e. // base of natural log
		local g is kerbin:mu/kerbin:radius^2. // gravitational acceleration constant (m/s^2)
		local p is ens_thrust / ens_dm. // engine isp (s) support to average different isp values
					
		return g * m * p * (1 - e^(-dv/(g*p))) / f.
	}
}

// Delta v requirements for Hohmann Transfer
function hoffmanDv
{
	parameter desiredAltitude.

	local u is ship:body:mu.
	local r1 is ship:obt:semimajoraxis.
	local r2 is desiredAltitude + ship:body:radius.

	// v1
	local v1 is sqrt(u / r1) * (sqrt((2 * r2) / (r1 + r2)) - 1).

	// v2
	local v2 is sqrt(u / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

	return list(v1, v2).
}

// Execute the next node
function execNode
{
	parameter autoWarp is true.
	
	if not hasnode // no node planned
	{
		return.
	}

	local n is nextnode.
	local v is n:burnvector.

	notify("Aligning for maneuver").
	local startTime is time:seconds + n:eta - mnvTime(v:mag/2).
	lock steering to lookdirup(n:burnvector, ship:up:vector).
	waitForAlignment().

	 if autoWarp and startTime - time:seconds > warpMargin
	{
		notify("Warping").
		warpTo(startTime - warpMargin). 
		notify("Warp finished").
	}

	wait until time:seconds >= startTime.

	notify("Maneuver burn").
	lock throttle to min(mnvTime(n:burnvector:mag), 1).
	wait until n:burnvector * v < 0.
	lock throttle to 0.

	notify("Maneuver done").
	remove n.
	set ship:control:pilotmainthrottle to 0.
	unlock steering.
}

// Time to impact
function timeToImpact
{
	parameter margin is 100.

	local d is alt:radar - margin.
	local v is ship:verticalSpeed.
	local g is ship:body:mu / ship:body:radius^2.

	return (sqrt(v^2 + 2 * g * d) + v) / g.
}

function periChangeNode
{
	parameter h is alt:apoapsis.
	set h to min(h, alt:apoapsis * (1 - orbitMargin)).
	
	local n is node(time:seconds + eta:apoapsis, 0, 0, 0).
	add n.
	
	if h > alt:periapsis * (1 + orbitMargin)
	{
		notify("Creating prograde burn at apoapsis").
		
		until n:orbit:periapsis > h
		{
			set n:prograde to n:prograde + bigJump.
		}
		until n:orbit:periapsis < h
		{
			set n:prograde to n:prograde - smallJump.
		}
	}
	else if h < alt:periapsis * (1 - orbitMargin)
	{
		notify("Creating retrograde burn at apoapsis").
		
		until n:orbit:periapsis < h
		{
			set n:prograde to n:prograde - bigJump.
		}
		until n:orbit:periapsis > h
		{
			set n:prograde to n:prograde + smallJump.
		}
	}
	else
	{
		notify("No burn necessary").
		remove n.
	}
}

function apoChangeNode
{
	parameter h is alt:periapsis.
	set h to max(h, alt:periapsis * (1 + orbitMargin)).
	
	local n is node(time:seconds + eta:periapsis, 0, 0, 0).
	add n.
	
	if h > alt:apoapsis * (1 + orbitMargin)
	{
		notify("Creating prograde burn at periapsis").
		
		until n:orbit:apoapsis > h
		{
			set n:prograde to n:prograde + bigJump.
		}
		until n:orbit:apoapsis < h
		{
			set n:prograde to n:prograde - smallJump.
		}
	}
	else if h < alt:apoapsis * (1 - orbitMargin)
	{
		notify("Creating retrograde burn at periapsis").
		
		until n:orbit:apoapsis < h
		{
			set n:prograde to n:prograde - bigJump.
		}
		until n:orbit:apoapsis > h
		{
			set n:prograde to n:prograde + smallJump.
		}
	}
	else
	{
		notify("No burn necessary").
		remove n.
	}
}

function relativeStop
{
	parameter ves is target.
	
	lock relVel to ves:velocity:orbit - ship:velocity:orbit.
	
	lock steering to lookdirup(-relVel, ship:up:vector).
	waitForAlignment().
	lock throttle to relVel:mag / speedMargin.
	wait until relVel:mag < speedTolerance.
	lock throttle to 0.
}

function timeToAngle
{
	parameter tang is 0.
	
	local nor is orbitNormal(ship).
	
	// Iteratively find the time of crossing
	local t0 is time:seconds.
	local t is 0.
	until false
	{
		local p is positionat(ship, t0+t) - ship:body:position. // ship's position after time t, in planet's reference
		local ang is signedAngle(-ship:body:position, p, nor).
		local err is ang - tang.
		
		if abs(err) < angleMargin
		{
			return t - t0.
		}
		else
		{
			local speedratio is p:mag / ship:orbit:semimajoraxis.
			set t to t - speedratio * err * ship:orbit:period / 360.
		}
	}
}

function resizeOrbit
{
	parameter r is alt:apoapsis.
	
	if r > alt:periapsis
	{
		notify("Adjusting apoapsis to " + r).
		apoChangeNode(r).
		execNode().
		notify("Circularizing").
		periChangeNode().
		execNode().
	}
	else
	{
		notify("Adjusting apoapsis to " + r).
		periChangeNode().
		execNode().
		notify("Circularizing").
		apoChangeNode(r).
		execNode().
	}
	
	notify("Resizing orbit complete").
}