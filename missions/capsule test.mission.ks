stage.
notify("Launch").
wait until ship:altitude > 100.

lock steering to heading(90, 45).
notify("Entering trajectory").
waitForAlignment().

lock steering to withAngleOfAttack(ship:velocity:surface, 0).
notify("Ballistic trajectory").
wait until ship:verticalSpeed < -10.

lock steering to withAngleOfAttack(ship:velocity:surface, 20).
notify("Gliding").
wait until chutes.

notify("Landing").
wait until ship:status = "Landed".

notify("Landed").