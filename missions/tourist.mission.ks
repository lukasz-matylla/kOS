// Example mission - tourists
run ascent.
notify("Let's go a few times around").
warpFor(2*ship:orbit:period).
notify("Returning home").
run atmoLanding.