copypath("0:/my/lib/lib_notify.ks", ""). run once lib_notify.
copypath("0:/my/lib/lib_vectors.ks", ""). run once lib_vectors.
copypath("0:/my/lib/lib_warp.ks", ""). run once lib_warp.
copypath("0:/my/lib/lib_pid.ks", ""). run once lib_pid.
copypath("0:/my/lib/lib_maneuver.ks", ""). run once lib_maneuver.
copypath("0:/my/lib/lib_intercept.ks", ""). run once intercept.

copypath("0:/my/lib/lib_arrows.ks", "").
copypath("0:/my/lib/lib_staging.ks", ""). 
copypath("0:/my/lib/lib_chutes.ks", ""). 

// copypath("0:/my/lib_asyncloop.ks", ""). run lib_asyncloop.

copypath("0:/my/ascent.ks", "").
// copypath("0:/my/align.ks", "").
// copypath("0:/my/transfer.ks", "").
// copypath("0:/my/intercept.ks", "").
copypath("0:/my/atmoLanding.ks", "").
copypath("0:/my/wingedLanding.ks", "").
copypath("0:/my/vacLanding.ks", "").

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