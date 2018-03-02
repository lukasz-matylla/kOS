parametrer deorbitPeriapsis is 45000.
parameter atmosphereMargin is 0.9.
parameter glideQ is 0.1.
parameter entryAoA is 50.
parameter glideAoA is 20.

local warpMargin is 30.
local currentV is 0.

is ship:status <> "Orbiting" and ship:status <> "Escaping"
{
	notify("Incorrect ship state for this script: " + ship:status).
}

// Deorbit
if alt:periapsis > deorbitPeriapsis // need to burn to deorbit
{
    if alt:apoapsis > 0 // not an escape trajectory
	{
		notify("Coasting to apoapsis").

		if eta:apoapsis > warpMargin
		{
			notify("Warping").
			warpFor(eta:apoapsis - warpMargin).
			notify("End warp").
		}

		wait until eta:apoapsis < 5.
	}
	
	lock steering to ship:retrograde.
	waitForAlignment().
	notify("Deorbit burn").
	lock throttle to 1.
	wait until alt:periapsis < deorbitPeriapsis.
	lock throttle to 0.
	notify("Descending from orbit").
}
else
{
	notify("Coasting towards atmosphere").
}

// Prepare for reentry
notify("Aligning for slowdown").
lock steering to ship:srfretrograde.

// Descent
if eta:periapsis > warpMargin
{
	notify("Warping").
	warpFor(eta:periapsis).
	// will exit warp automatically when hitting atmosphere
	notify("End warp").
}

// Entering atmosphere
notify("Descending into atmosphere").
panels off.
wait until ship:altitude < ship:body:atm:height * atmosphereMargin.

// Final burn
notify("Using up fuel").
lock throttle to 1.
wait until ship:liquidfuel < 1.

// Winged aerobraking
notify("Aerobraking").
lock steering to withAngleOfAttack(ship:velocity:surface, entryAoA).

when ship:q > glideQ then
{
	notify("Gliding").
	brakes on.
	lock steering to withAngleOfAttack(ship:velocity:surface, glideAoA).
}

// Landing gear
wait until alt:radar < 100.
notify("Preparing for landing").
lock steering to horizon(ship:velocity:surface).
gear on.
legs on.

// Landing
wait until ship:status = "LANDED".
notify("Landed").