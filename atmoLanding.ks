parameter deorbitPeriapsis is 40000.
parameter finalBurnPeriapsis is 35000.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.
run once lib_chutes.
run once lib_arrows.

local warpMargin is 30.

if ship:status <> "Orbiting" and ship:status <> "Escaping"
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
			wait until ship:altitude > ship:body:atm:height.
			notify("Warping").
			warpFor(eta:apoapsis - warpMargin).
			notify("End warp").
		}
		
		lock steering to ship:retrograde.
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
notify("Aligning for reentry").
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
notify("Initial aerobraking").
panels off.
wait until eta:periapsis < 5 or alt:periapsis < finalBurnPeriapsis.

// Final burn
notify("Using up fuel").
lock throttle to 1.
wait until ship:liquidfuel < 1.
notify("Aerobraking").

// Landing gear
wait until alt:radar < 100.
notify("Preparing for landing").
lock steering to up.
gear on.
legs on.

// Landing
wait until ship:status = "Landed" or ship:status = "Splashed".
notify("Landed").