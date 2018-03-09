run once lib_warp.
run once lib_notify.

set target to vessel("<name>").

run ascent. // replace with timedLaunch(target) when it is implemented
notify("In orbit. Aligning planes.").
run align(target).
notify("Setting up intercept").
run intercept(target).
notify("Initial intercept complete. Closing up.").
approach(target).
notify("Visual contact achieved.").