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

function showTargetingArrows
{
	if not hasTarget
	{
		return.
	}
	
	if target:isType("DockingPort")
	{
		lock dir to target:portFacing.
	}
	else
	{
		lock dir to target:facing.
	}

	local arTargFore is VecDraw(target:position, dir:vector * 5, white, "Target Front", 1, true).
	set arTargFore:startUpdater to target:position.
	set arTargFore:vecUpdater to dir:vector * 5.
	
	local arTargUp is VecDraw(target:position, dir:upvector * 5, yellow, "Target Up", 1, true).
	set arTargUp:startUpdater to target:position.
	set arTargUp:vecUpdater to dir:upvector * 5.
	
	local arMyFore is VecDraw(v(0, 0, 0), ship:facing:vector * 5, green, "My Front", 1, true).
	set arMyFore:vecUpdater to ship:facing:vector * 5.
	
	local arMyUp is VecDraw(v(0, 0, 0), ship:facing:upvector * 5, blue, "My Up", 1, true).
	set arMyUp:vecUpdater to ship:facing:upvector * 5.
	
	local arVel is VecDraw(v(0, 0, 0), ship:velocity:orbit - target:velocity:orbit, red, "V", 1, true).
	set arMyUp:vecUpdater to ship:velocity:orbit - target:velocity:orbit.
}

function hideArrows
{
	clearVecDraws().
}