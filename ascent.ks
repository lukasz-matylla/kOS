parameter orbitHeight is 80000.
parameter orbitAngle is 90.
parameter initialTurn is 30.
parameter turnSpeed is 100.
parameter gtSpeed is 250.

local pThreshold is 0.01.
local hThreshold is 0.5.
local orbitMargin is 0.1.
local warpMargin is 30.
local circMargin is 5.

is ship:status <> "Prelaunch"
{
	notify("Incorrect ship state for this script: " + ship:status).
}

local currentV is 0. 
lock currentV to ship:velocity:surface.
when ship:altitude > ship:body:atm:height*hThreshold and ship:q < pThreshold then
{
    lock currentV to ship:velocity:orbit.
	notify("Switching reference to orbit").
}

// Launch
notify("Initiating launch").
lock steering to up.
lock throttle to 1.
until false
{
    stage.
	wait 1.
	if ship:verticalSpeed > 0
	{
		break.
	}
}

// Initial ascent
notify("Initial ascent").
wait until ship:verticalSpeed > turnSpeed.

// Initial turn
notify("Initial turn").
lock steering to withAngleToHorizon(heading(orbitAngle, 0):vector, 90 - initialTurn).
wait until currentV:mag > gtSpeed.

// Gravity turn
notify("Gravity turn").
lock steering to withAngleOfAttack(currentV, 0).
wait until alt:apoapsis > orbitHeight * (1 - orbitMargin).

// Fine-tuning apoapsis
notify("Fine-tuning apoapsis").
lock throttle to 0.1.
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
        lock throttle to 0.1.
		wait until alt:apoapsis > orbitHeight.
		lock throttle to 0.
		notify("Apoapsis correction complete").
	}
}

// Circularization
notify("Preparing for circularization").
add periChangeNode(). // get peri up to apo
execNode().

// Finish
notify("In orbit").
lock steering to lookdirup(body("Sun"):position, body("Sun"):north:vector).
panels on.
waitForAlignment().
notify("Aligned towards the Sun, panels deployed").
wait 5.
set ship:control:pilotmainthrottle to 0.
unlock steering.
notify("Ascent procedure finished").