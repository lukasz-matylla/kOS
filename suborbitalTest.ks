parameter minAlt.
parameter maxAlt.
parameter minSpeed is 0.
parameter maxSpeed is 1000.
parameter stageForTest is true. // If false, 
parameter useChutes is true.

local apoMargin is 0.1.

local targetAlt is (minAlt + maxAlt) / 2.
local targetSpeed is (minSpeed + maxSpeed) / 2.
local g is ship:body:mu / ship:body:radius^2.
local apoSmooth is apoMargin * (maxAlt - minAlt).

local targetApo is targetAlt + 0.5 * targetSpeed^2 / g.

run once lib_vectors.
run once lib_actions.
run once lib_save.
run once lib_notify.

if (useChutes)
{
	run once lib_chutes.
}

SaveGame(test).

lock steering to up.
lock thr to Bound((targetApo - alt:apoapsis) / apoSmooth).
stage. // Launch
notify("Launch").

wait until ship:altitude > targetAlt. // At this point the speed should also be in the correct range

if ship:altitude > minAlt and ship:altitude < maxAlt and ship:velocity:surface > minSpeed and ship:velocity:surface < maxSpeed
{
	// Run the test
	notify("Running tests").
	DoPartEvent("", "run test").
	if stageForTest
	{
		stage.
	}
}
else
{
	notify("Not in the correct altitude and velocity range! Interrupting.").
}

wait 10.

notify("Returning home").
lock thr to 0.
lock steering to retrograde.

if useChutes
{
	wait until alt:radar < 10000.
	lock thr to Bound((-ship:verticalSpeed - 200) / 50).
	notify("Slowing down and using up fuel").
	
	wait until alt:radar < 5500.
	lock thr to 0.
	
	wait until alt:radar < 100.
	gear on.
	lock steering to up.
	lock thr to Bound((-ship:verticalSpeed - 2) / 5).
	notify("Ready for landing").
	
	wait until ship:status = "Landed" or ship:status = "Splashed".
	notify("Landed").
}
else
{
	run vacLanding.
}