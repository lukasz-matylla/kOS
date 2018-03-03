clearLog().
lock steering to heading(90, 90).
stage.

run once lib_staging.
run once lib_arrows.

notify("Launch").
wait until ship:altitude > 100.

lock steering to heading(90, 45).
notify("Entering trajectory").
waitForAlignment().

lock steering to withAngleOfAttack(ship:velocity:surface, 0).
notify("Ballistic trajectory").
wait until ship:verticalSpeed < -10.

lock steering to withAngleOfAttack(ship:velocity:surface, min(20, -angleToHorizon(ship:velocity:surface) / 2)).
notify("Gliding").
wait until alt:radar < 1500.

run once lib_chutes.
lock steering to withAngleToHorizon(ship:velocity:surface, 0).

notify("Landing").
wait until ship:status = "Landed" or ship:status = "Splashed".

notify("Landed").