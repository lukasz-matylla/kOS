// Example mission - tourists

run once lib_warp.
run once lib_notify.

run ascent.
notify("Let's go a few times around").
warpFor(0.75*ship:orbit:period).
notify("Returning home").
run atmoLanding.