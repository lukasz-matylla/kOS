parameter orbitHeight is 80000.
parameter orbitInclination is 0.
parameter initialTurn is 30.
parameter turnSpeed is 50.
parameter etaGt is 20.

run once lib_notify.
run once lib_vectors.
run once lib_maneuver.
run once lib_warp.
run once lib_staging.

local pThreshold is 0.02.
local hThreshold is 0.6.
local orbitMargin is 0.1.
local warpMargin is 30.
local circMargin is 5.
local minThrottle is 0.1.

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
wait 5.
if kuniverse:canquicksave
{
	set saveName to "Before launch of " + ship:name.
	kuniverse:quicksaveto(saveName).
	notify("Saved as '" + saveName + "'").
}

// Launch
clearLog().
notify("Initiating launch").

lock throttle to 1.

until false
{
    stage.
	wait 0.5.
	if ship:verticalSpeed > 0.1
	{
		break.
	}
}

// Initial ascent
notify("Initial ascent").
// lock steering to lookdirup(ship:up:vector, heading(orbitAngle + 180, 0):vector).
wait until ship:verticalSpeed > turnSpeed.

// Initial turn
notify("Initial turn").
lock steering to heading(90 - orbitInclination, 90 - initialTurn * eta:apoapsis / etaGt).
wait until eta:apoapsis > etaGt.

// Gravity turn
notify("Gravity turn").
lock optimalAngle to angleToHorizon(optimalBurnDirection:vector).
lock apoCorrection to max(optimalAngle, 90*(1 - eta:apoapsis/etaGt) + optimalAngle*eta:apoapsis/etaGt).
lock steering to WithAngleToHorizon(optimalBurnDirection:vector, apoCorrection).
wait until alt:apoapsis > orbitHeight * (1 - orbitMargin).


// Fine-tuning apoapsis
notify("Fine-tuning apoapsis").
lock throttle to minThrottle + (orbitHeight - alt:apoapsis) / (orbitHeight * orbitMargin).
wait until alt:apoapsis > orbitHeight.
lock throttle to 0.

// Exiting atmosphere
if ship:altitude < ship:body:atm:height
{
    notify("Coasting to the end of atmosphere").
    wait until ship:altitude > ship:body:atm:height.

    if alt:apoapsis < orbitHeight
    {
        notify("Correcting apoapsis").
        lock throttle to minThrottle + (orbitHeight - alt:apoapsis) / (orbitHeight * orbitMargin).
		wait until alt:apoapsis > orbitHeight.
		lock throttle to 0.
		notify("Apoapsis correction complete").
	}
}

// Circularization
PeriChangeNode(). // get peri up to apo
notify("Execute circularization").
ExecNode(true).

// Finish
notify("In orbit").
panels on.
wait 5.
set ship:control:pilotmainthrottle to 0.
unlock steering.
notify("Ascent procedure finished").