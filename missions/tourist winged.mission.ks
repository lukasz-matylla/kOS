// Example mission - tourists

run once lib_warp.
run once lib_notify.

run ascent(80000, 0, 25, 100, 300).
notify("Let's go a few times around").
warpFor(0.75*ship:orbit:period).
wait 10.
notify("Returning home").
run wingedLanding.