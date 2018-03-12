run once lib_warp.
run once lib_notify.

set target to vessel("<name>").

notify("Targeting " + target:name).
notify("Launching into target's plane").
local safePeri is min(target:orbit:periapsis, ship:body:atm:height * 1.1).
run timedLaunch(target, safePeri).

notify("In orbit. Aligning planes.").
run align(target).

notify("Setting up intercept").
run intercept(target).

notify("Initial intercept complete. Closing up.").
approach(target).

notify("Visual contact achieved.").