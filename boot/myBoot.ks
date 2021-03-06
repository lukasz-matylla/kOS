copypath("0:/my/lib/lib_arrows.ks", "").
copypath("0:/my/lib/lib_staging.ks", ""). 
copypath("0:/my/lib/lib_chutes.ks", ""). 
copypath("0:/my/lib/lib_notify.ks", ""). 
copypath("0:/my/lib/lib_vectors.ks", ""). 
copypath("0:/my/lib/lib_warp.ks", ""). 
copypath("0:/my/lib/lib_pid.ks", ""). 
copypath("0:/my/lib/lib_maneuver.ks", ""). 
copypath("0:/my/lib/lib_arrows.ks", "").
copypath("0:/my/lib/lib_staging.ks", ""). 
copypath("0:/my/lib/lib_chutes.ks", ""). 
copypath("0:/my/lib/lib_orbit.ks", ""). 
copypath("0:/my/lib/lib_asyncLoop.ks", "").
copypath("0:/my/lib/lib_lists.ks", "").
copypath("0:/my/lib/lib_actions.ks", "").
copypath("0:/my/lib/lib_solve.ks", "").
copypath("0:/my/lib/lib_save.ks", "").

copypath("0:/my/timedLaunch.ks", "").
copypath("0:/my/ascent.ks", "").
copypath("0:/my/align.ks", "").
copypath("0:/my/intercept.ks", "").
copypath("0:/my/approach.ks", "").
copypath("0:/my/atmoLanding.ks", "").
copypath("0:/my/wingedLanding.ks", "").
copypath("0:/my/vacLanding.ks", "").
copypath("0:/my/telemetry.ks", "").
copypath("0:/my/dock.ks", "").
copypath("0:/my/listParts.ks", "").
copypath("0:/my/dockingArrows.ks", "").
copypath("0:/my/runScience.ks", "").
copypath("0:/my/waypointArrow.ks", "").
copypath("0:/my/execute.ks", "").
copypath("0:/my/suborbitalTest.ks", "").

run once lib_notify.
run once lib_save.
run once telemetry.

global thr is 0.
lock throttle to thr.

SaveGame("script startup").

on abort // Allow user to interrupt any script using Abort action group
{
	notify("Abort requested by user. Shutting down").
	shutdown.
}

local missionName is "0:/" + ship:name + ".mission.ks".
if exists(missionName)
{
	notify("Running mission script: " + missionName).
	deletepath("mission.ks").
	copypath(missionName, "mission.ks").
	run mission.
	deletepath(missionName).
}
else if exists("startup.ks")
{
	notify("Running onboard startup script").
	run startup.
}