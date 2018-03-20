parameter deorbitPeriapsis is 40000.
parameter atmosphereMargin is 0.8.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.
run once lib_chutes.
run once lib_arrows.

local warpMargin is 30.

sas off.

if kuniverse:canquicksave
{
	set saveName to "Before landing of " + ship:name.
	kuniverse:quicksaveto(saveName).
	notify("Saved as '" + saveName + "'").
}

lock steering to lookdirup(-ship:velocity:orbit, ship:up:vector).
when ship:altitude < ship:body:atm:height then
{
	lock steering to lookdirup(-ship:velocity:surface, ship:up:vector).
	
	when ship:groundSpeed < 20 then
	{
		unlock steering.
	}
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
		
        wait until eta:apoapsis < 5.
	}
	
	waitForAlignment().
	notify("Deorbit burn").
	lock throttle to 1.
	wait until alt:periapsis < deorbitPeriapsis.
	lock throttle to 0.
	notify("Descending from orbit").
	wait 5.
}
else
{
    notify("Coasting towards atmosphere").
}

// Prepare for reentry
notify("Aligning for reentry").
lock steering to ship:srfretrograde.
waitForAlignment().

// Descent
if eta:periapsis > warpMargin
{
	notify("Warping").
	set warp to 5.
	wait 3.
	// will exit warp automatically when hitting atmosphere
	wait until ship:altitude < ship:body:atm:height.
	set warp to 0.
	notify("End warp").
}

// Entering atmosphere
notify("Initial aerobraking").
panels off.
wait until ship:altitude < ship:body:atm:height * atmosphereMargin.

// Final burn
notify("Using up fuel").
lock throttle to 1.
wait until ship:liquidfuel < 1.
notify("Aerobraking").

// Landing gear
wait until alt:radar < 100.
notify("Preparing for landing").
gear on.
legs on.

// Landing
wait until ship:status = "Landed" or ship:status = "Splashed".
notify("Landed").
sas on.