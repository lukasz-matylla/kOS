local shipFront is 0.
local shipUp is 0.
local steeringFront is 0.
local steeringUp is 0.
local vSurface is 0.
local vOrbit is 0.

// debug arrows
function showBasicArrows
{
	set shipFront to vecdrawargs(v(0, 0, 0), ship:facing:vector*20, red, "ship:forward", 1, true, 0.2).
	set shipFront:vecUpdater to { return ship:facing:vector*20. }.
	set shipUp to vecdrawargs(v(0, 0, 0), ship:facing:upvector*20, green, "ship:up", 1, true, 0.2).
	set shipUp:vecUpdater to { return ship:facing:upvector*20. }.
	set steeringFront to vecdrawargs(v(0, 0, 0), steering:vector*20, blue, "steering:forward", 1, true, 0.2).
	set steeringFront:vecUpdater to { return steering:vector*20. }.
	set steeringUp to vecdrawargs(v(0, 0, 0), steering:upvector*20, yellow, "steering:up", 1, true, 0.2).
	set steeringUp:vecUpdater to { return steering:upvector*20. }.
	set vSurface to vecdrawargs(v(0, 0, 0), ship:velocity:surface:normalized*20, white, "velocity:surface", 1, true, 0.2).
	set vSurface:vecUpdater to { return ship:velocity:surface:normalized*20. }.
	set vOrbit to vecdrawargs(v(0, 0, 0), ship:velocity:orbit:normalized*20, purple, "velocity:orbit", 1, true, 0.2).
	set vOrbit:vecUpdater to { return ship:velocity:orbit:normalized*20. }.
}

function hideArrows
{
	set shipFront to 0.
	set shipUp to 0.
	set steeringFront to 0.
	set steeringUp to 0.
	set vSurface to 0.
	set vOrbit to 0.
}