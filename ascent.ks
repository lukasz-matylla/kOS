parameter orbitHeight is 80000.
parameter orbitInclination is 0.
parameter initialTurn is 30.
parameter turnSpeed is 50.
parameter etaGt is 30.
parameter discardFuel is 1000.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.

local pThreshold is 0.02.
local hThreshold is 0.7.
local thrReductionMargin is 2.5.
local orbitMargin is 0.1.
local warpMargin is 30.
local circMargin is 5.
local minThr is 0.05.
local angleMargin is 3.

local currentV is 0. 
lock currentV to ship:velocity:surface.
local optimalBurnDirection is 0.
lock optimalBurnDirection to withAngleOfAttack(currentV, 0).
when ship:altitude > ship:body:atm:height*hThreshold and ship:q < pThreshold then
{
    lock currentV to ship:velocity:orbit.
	lock optimalBurnDirection to withAngleToHorizon(currentV, 0).
	notify("Switching reference to orbit").
}

// Save before launching
lock steering to heading(90 - orbitInclination, 90).
wait 2.
if kuniverse:canquicksave
{
	set saveName to "Before launch of " + ship:name.
	kuniverse:quicksaveto(saveName).
	notify("Saved as '" + saveName + "'").
}

// Launch
clearLog().
notify("Initiating launch").

lock thr to 1.
wait 1.
stage.

// Initial ascent
notify("Initial ascent").
wait until ship:verticalSpeed > turnSpeed.

// Initial turn
notify("Initial turn").
lock steering to heading(90 - orbitInclination, 90 - initialTurn * min(1, eta:apoapsis / etaGt)).
wait until (angleToHorizon(ship:facing:vector) < 90 - initialTurn / 2 and verticalAoA(currentV, ship:facing:vector) > 0) or
	angleToHorizon(ship:facing:vector) < 90.5 - initialTurn.

notify("Stabilizing ascent").
lock thr to min(1, minThr + max(0, thrReductionMargin - eta:apoapsis / etaGt)). // Do not move apoapsis too far
wait until verticalAoA(currentV, ship:facing:vector) > 0. // When AoA becomes zero

notify("Gravity turn").
lock optimalAngle to angleToHorizon(optimalBurnDirection:vector).
lock apoCorrection to max(optimalAngle, 90*(1 - eta:apoapsis/etaGt) + optimalAngle*eta:apoapsis/etaGt).
lock steering to WithAngleToHorizon(optimalBurnDirection:vector, apoCorrection). // Increase angle if apoapsis is too close
when apoCorrection < angleMargin then
{
	notify("Gravity turn finished, burning horizontally").
	set thrReductionMargin to 1e9. // When we start burning horizontally, don't keep the throttle down anymore
}
wait until alt:apoapsis > orbitHeight * (1 - orbitMargin).

lock thr to (orbitHeight - alt:apoapsis) / (orbitHeight * orbitMargin).

// Exiting atmosphere
if ship:altitude < ship:body:atm:height
{
    notify("Power-coasting to the end of atmosphere").
	set warp to 3.
    wait until ship:altitude > ship:body:atm:height.
	set warp to 0.
}

// Fine-tuning apoapsis
notify("Fine-tuning apoapsis").
lock thr to minThr + (orbitHeight - alt:apoapsis) / (orbitHeight * orbitMargin).
wait until alt:apoapsis > orbitHeight.
lock thr to 0.

// Discard launcher stage if it's nearly empty
local circularized is false.
when alt:periapsis > ship:body:atm:height * (1 - orbitMargin) and StageStats()["dv"] < discardFuel then
{
	if not circularized
	{
		notify("Current stage only has " + StageStats()["dv"] + "m/s deltaV left. Discarding before getting to orbit.").
		SafeStage().
	}
}

// Circularization
PeriChangeNode(). // get peri up to apo
notify("Execute circularization").
ExecNode(true).
set circularized to true.

// Finish
notify("In orbit").
panels on.
wait 5.
set ship:control:pilotmainthrottle to 0.
unlock steering.
notify("Ascent procedure finished").