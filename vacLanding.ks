local retrogradeThreshold is 1.
local radarMargin is 100.
local touchDownV is 2.
local speedScale is 0.2.
local thrScale is 0.2.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.
run once lib_pid.
run once lib_save.

SaveGame("vacuum landing").

sas off.

// Retrograde, but prevent instabilities at low speed
function upwards
{
	if ship:verticalSpeed < -retrogradeThreshold 
	{
		return ship:srfretrograde.
	}

	return ship:up.
}

// Deorbit
if alt:periapsis > 0 // need to burn to deorbit
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
	lock thr to 1.
	wait until alt:periapsis < 0.
	lock thr to 0.
	notify("Descending from orbit").
}
else
{
	notify("Coasting towards landing point").
}

// Prepare for burn
notify("Aligning for suicide burn").
lock steering to upwards().
waitForAlignment().

// Wait to begin burn
wait until timeToImpact(radarMargin) <= mnvTime(ship:velocity:surface:mag).

// Suicide burn
notify("Suicide burn").
lock descentTarget to alt:radar*speedScale + touchDownV.
lock thr to (ship:velocity:surface:mag - descentTarget) * thrScale.
wait until alt:radar < radarMargin.

// Redying landing gear
notify("Preparing for landing").
lock steering to up.
gear on.
legs on.


//Controlled descent
notify("Beginning controlled descent").
set hoverPid to initPid(0.05, 0.005, 0.01, 0, 1).
local pidthr is 0.
lock thr to pidthr.

until ship:status = "Landed" or ship:status = "Splashed"
{
	set pidthr TO pid(hoverPID, -descentTarget, ship:verticalSpeed).
	WAIT 0.01.
}

// Landing
lock thr to 0.
wait 5.
unlock steering.
set ship:control:pilotmainthr to 0.
unlock thr.
notify("Landed").