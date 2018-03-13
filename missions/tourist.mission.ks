// Example mission - tourists

run once lib_warp.
run once lib_notify.

run once telemetry.

run ascent(80000, 0, 25, 100, 300).
notify("Let's go a few times around").
warpFor(1.75*ship:orbit:period).
notify("Returning home").
run atmoLanding.