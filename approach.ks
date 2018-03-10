// Starting from a distance much smaller than orbit diameter, approach to direct contact range

parameter ves is target.
parameter finalDistance is 200.
parameter maxSpeed is 100.

run once lib_maneuver.
run once lib_notify.

notify("Beginning approach").

lock relPos to ves:position.
lock relVel to ves:velocity:orbit - ship:velocity:orbit.

lock targetVelMag to min(relPos:mag / speedScale, maxSpeed).
lock targetVel to relPos:normalized * targetVelMag.

lock velCorrection to targetVel - relVel.

lock steering to lookdirup(velCorrection, ship:up:vector).
lock throttle to relVel:mag / speedMargin.
wait until relPos:mag < finalDistance.
lock throttle to 0.

notify("Killing relative velocity").
relativeStop(ves).

notify("Approach complete").