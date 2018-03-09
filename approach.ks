// Starting from a distance much smaller than orbit diameter, approach to direct contact range

parameter ves is target.
parameter finalDistance is 200.

run once lib_maneuver.
run once lib_notify.

notify("Beginning approach").

lock relPos to ves:position.
lock relVel to ves:velocity:orbit - ship:velocity:orbit.

lock targetVel to relPos / speedScale.

lock velCorrection to targetVel - relVel.

lock steering to lookdirup(velCorrection, ship:up:vector).
lock throttle to relVel:mag / speedMargin.
wait until relPos:mag < finalDistance.
lock throttle to 0.

notify("Killing relative velocity").
relativeStop(ves).

notify("Approach complete").