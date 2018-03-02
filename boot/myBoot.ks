copypath("0:/my/lib/lib_notify.ks", ""). run lib_notify.
copypath("0:/my/lib/lib_staging.ks", ""). run lib_staging.
copypath("0:/my/lib/lib_chutes.ks", ""). run lib_chutes.
copypath("0:/my/lib/lib_vectors.ks", ""). run lib_vectors.
copypath("0:/my/lib/lib_warp.ks", ""). run lib_warp.
copypath("0:/my/lib/lib_pid.ks", ""). run lib_pid.
copypath("0:/my/lib/lib_maneuver.ks", ""). run lib_maneuver.
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
	delete("mission.ks").
	copypath(missionName, "mission.ks").
	delete(missionName).
	run mission.
}
else if exists("startup.ks")
{
	notify("Running onboard startup script").
	run startup.
}