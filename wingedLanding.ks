parameter deorbitPeriapsis is 45000.
parameter atmosphereMargin is 0.9.
parameter glideQ is 0.1.
parameter glideMargin is 0.3.
parameter entryAoA is 50.
parameter glideAoA is 20.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.
run once lib_chutes.
run once lib_arrows.

local warpMargin is 30.
local currentV is 0.

if ship:status <> "Orbiting" and ship:status <> "Escaping" and ship:status <> "Sub_Orbital"
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
	wait 2.
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
	set warp to 8.
	wait 3.
	// will exit warp automatically when hitting atmosphere
	wait until ship:altitude < ship:body:atm:height.
	set warp to 0.
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
wait 5.

// Winged aerobraking
notify("Aerobraking").
lock steering to withAngleOfAttack(ship:velocity:surface, 50).
wait until ship:q > glideQ or ship:altitude < ship:body:atm:height * glideMargin.

// Glide
notify("Gliding").
lock steering to withAngleOfAttack(ship:velocity:surface, 20).
wait until ship:groundSpeed < abs(ship:verticalSpeed).

// Fall on chutes
notify("Gently falling down").
lock steering to heading(0, 0).
wait until alt:radar < 100.

// Landing
notify("Landing").
hideArrows().
gear on.
legs on.
wait until ship:status = "Landed" or ship:status = "Splashed".

notify("Landed").