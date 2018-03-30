run once lib_notify.
run once lib_vectors.
run once lib_arrows.
run once lib_staging.
run once lib_orbit.

local warpMargin is 30.
local orbitMargin is 0.001.
local bigJump is 50.
local smallJump is 0.1.
local speedMargin is 10.
local speedTolerance is 0.1.
local speedScale is 20.
local angleMargin is 0.1.
local eccentricityMargin is 0.05.

function StageStats
{
	local data is lexicon().
	
	// Thrust and ISP calculations
	list engines in allEngines.
	local activeEngines is list().
	local totalThrust is 0.
	local totalDm is 0.

	for en in allEngines 
	{
		if en:ignition = true and en:flameout = false and en:availableThrust > 0 and en:isp > 0
		{
			activeEngines:add(en).
	    }
	}

	for en in activeEngines 
	{
		set totalThrust to totalThrust + en:availableThrust.
		set totalDm to totalDm + en:availableThrust / en:isp.
	}
	
	// Fuel mass calculations
	// Assumes that the stage does not consume several resources at the same time
	local fuels is list().
    fuels:add("LiquidFuel").
    fuels:add("Oxidizer").
    fuels:add("SolidFuel").
    fuels:add("MonoPropellant").
	
	local fuelMass is 0.
	for r in stage:resources
    {
        for f in fuels
        {
            if f = r:name
            {
                set fuelMass to fuelMass + r:amount*r:density.
            }.
        }.
    }
	
	set data["fuel"] to fuelMass.
	set data["fuelPercent"] to 100 * fuelMass / (ship:wetmass + fuelMass - ship:mass).
	
	if totalDm > 0
	{
		local g is kerbin:mu/kerbin:radius^2.
		local isp is totalThrust / totalDm.
	
		set data["thrust"] to totalThrust.
		set data["isp"] to isp.
		set data["dv"] to isp * g * ln(ship:mass / (ship:mass - fuelMass)).
	}
	else
	{
		// This is possible when there are no active engines
		set data["thrust"] to 0.
		set data["isp"] to 0.001. // to prevent division by zero
		set data["dv"] to 0.
	}	
	
	return data.
}

// Time to complete a maneuver
function MnvTime
{
	parameter dv.
	parameter stats is StageStats().

	if stats["thrust"] = 0 
	{
		// May happen if staging during a maneuver
		return 1000000.
	}
	else 
	{
		local f is stats["thrust"] * 1000. // engine thrust (kg * m/s²)
		local m is ship:mass * 1000. // starting mass (kg)
		local e is constant():e. // base of natural log
		local g is kerbin:mu/kerbin:radius^2. // gravitational acceleration constant (m/s^2)
		local p is stats["isp"]. // engine isp
					
		return g * m * p * (1 - e^(-dv/(g*p))) / f.
	}
}

// Delta v requirements for Hohmann Transfer
function HoffmanDv
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

function SetupHoffmanTo
{
	parameter myTarget is target.
	parameter maxPhasing is 5.
	
	if not myTarget:isType("Orbitable")
	{
		notify("Cannot perform a Hoffman transfer to " + myTarget).
		return.
	}
	
	// This function assumes coplanar, circular initial and final orbit
	if RelativeInclination(ship, myTarget) > angleMargin
	{
		notify("Relative inclination too big: " + RelativeInclination(ship, myTarget)).
		return.
	}
	
	if ship:orbit:eccentricity > eccentricityMargin
	{
		notify("Initial orbit is not circular, eccentricity " + ship:orbit:eccentricity).
		return.
	}
	
	if myTarget:orbit:eccentricity > eccentricityMargin
	{
		notify("Target orbit is not circular, eccentricity " + myTarget:orbit:eccentricity).
		return.
	}
	
	local dvs is HoffmanDv(myTarget:altitude).
	local on is OrbitNortmal(ship).
	local angleToTarget is SignedAngle(-ship:body:position, myTarget:position - ship:body:position).
	local wMe is 360 / ship:orbit:period.
	local wTarg is 360 / myTarget:orbit:period.
	local relativeAngVel is wMe - wTarg.
	local goUp is relativeAngVel > 0.
	
	if abs(relativeAngVel) < 0.000001
	{
		notify("Already very close to target orbit, can't time Hoffman transfer correctly").
		return.
	}
	
	// Create transfer node, without set time yet
	if goUp
	{
		local n is node(time:seconds, 0, 0, dvs[0]). 
	}
	else
	{
		local n is node(time:seconds, 0, 0, -dvs[0]).
	}
	add n.
	local transferTime is n:orbit:period / 2. // Time spent on the transfer orbit
	
	local phaseDif is mod(angleToTarget + wTarg*transferTime + 180, 360).

	if relativeAngVel > 0 // Transferring up, gaining on target
	{
		set n:eta to phaseDif / relativeAngVel.
	}
	else // Transferring down, target gaining on ship
	{
		set n:eta to (phaseDif - 360) / relativeAngVel.
	}
	
	if n:eta > maxPhasing * ship:orbit:period
	{
		notify("Required phasing time " + round(n:eta, 0) + "s is greater than the allowed " + maxPhasing + "phasing orbits (" + maxPhasing * ship:orbit:period + "s)").
		remove n.
		return.
	}
	
	if myTarget:isType("Vessel")
	{
		// Circularize close to the target
		notify("Setting circularization node close to the target").
		if goUp
		{
			local m is node(time:seconds + n:eta + transferTime, 0, 0, dvs[1]).
		}
		else
		{
			local m is node(time:seconds + n:eta + transferTime, 0, 0, -dvs[1]).
		}
		
		add m.
	}
	else if myTarget:isType("Body")
	{
		// Going to a celestial body - no circularization, but set up a node at SOI entry
		if n:orbit:transition <> "Encounter" or n:orbit:nextpatch:body:name <> myTarget:name
		{
			notify("Something went wrong. Transfer orbit does not end in an encounter with target: " + n:orbit + ". Aborting transfer.").
			return.
		}
		
		notify("Setting empty maneuver node just after SOI switch").
		local m is node(time:seconds + n:orbit:nextPatchEta + warpMargin, 0, 0, 0).
		add m.
	}
}

// Execute the next node
function ExecNode
{
	parameter allowStaging is true.
	parameter autoWarp is true.
	
	if not HasNode // no node planned
	{
		return.
	}

	local n is NextNode.
	local v is n:burnvector.
	local data is StageStats().
	
	if (not allowStaging) and (data["dv"] < v:mag)
	{
		notify("Current stage does not have enough delta-V to perform the maneuver. Staging.").
		SafeStage().
	}

	local startTime is time:seconds + n:eta - mnvTime(v:mag/2, data).
	notify("Node in " + round(n:eta) + "s. Estimated burn time: " + round(mnvTime(v:mag, data)) + "s. Burn starts " + 
		round(mnvTime(v:mag/2, data)) + "s before node.").
	notify("Aligning for maneuver").
	lock steering to lookdirup(v, ship:up:vector).
	waitForAlignment().

	if autoWarp and startTime - time:seconds > warpMargin
	{
		notify("Warping").
		warpTo(startTime - warpMargin). 
	}

	wait until time:seconds >= startTime.

	notify("Maneuver burn").
	lock thr to min(speedScale * vdot(n:burnvector, v:normalized) / v:mag, 1).
	wait until vdot(n:burnvector, v:normalized) < 0.
	lock thr to 0.

	notify("Maneuver done").
	remove n.
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
	lock thr to relVel:mag / speedMargin.
	wait until relVel:mag < speedTolerance.
	lock thr to 0.
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

function setPeriodChange
{
	parameter n.
	parameter per.
	parameter currentPer is ship:orbit:period.
	
	set n:prograde to 0.
	set n:radialout to 0.
	set n:normal to 0.
	
	if per > currentPer
	{
		until n:orbit:apoapsis < 0 or n:orbit:period > per
		{
			set n:prograde to n:prograde + bigJump.
		}
		until n:orbit:apoapsis > 0 and n:orbit:period < per
		{
			set n:prograde to n:prograde - smallJump.
		}
	}
	else
	{
		until n:orbit:period < per
		{
			set n:prograde to n:prograde - bigJump.
		}
		until n:orbit:period > per
		{
			set n:prograde to n:prograde + smallJump.
		}
	}
}