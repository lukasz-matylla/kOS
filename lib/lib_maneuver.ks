local warpMargin is 30.

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
		notify("ERROR: No engines available!").
		return 0.
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
	lock steering to n:burnvector.
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