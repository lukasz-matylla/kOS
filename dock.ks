parameter tar is target.

run once lib_pid.
run once lib_vectors.

local posMargin is 0.1.
local safetyMargin is 50.
local closeUp is 5.

function AlignToDock
{
	parameter d.
	lock steering to lookdirup(-d:forevector, d:upvector).
	WaitForAlignment().
	notify("Aligned for docking").
}

function GoToRelavive
{
	parameter tar. 
	parameter offset.
	parameter dir is tar:facing.
	
	notify("Moving to " + offset + " relative to target (" + tar:name + ")").
	
	local posPid is initPidVector(0.1, 0.001, 1, 1).
	
	lock ship:control to pidVector(posPid, dir*offset, -tar:position).
	
	until (d*tr + t:position:x):mag < posMargin
	{
		local arTargFore is VecDraw(tar:position, dir:vector * 5, yellow, "Target Front", 1, true).
		local arTargUp is VecDraw(tar:position, dir:upvector * 5, yellow, "Target Up", 1, true).
		local arMyFore is VecDraw(v(0, 0, 0), ship:facing:vector * 5, purple, "My Front", 1, true).
		local arMyUp is VecDraw(v(0, 0, 0), ship:facing:upvector * 5, purple, "My Up", 1, true).
		local arTarg is VecDraw(tar:position, dir*offset, white, "Waypoint", 1, true).
		local arVel is VecDraw(v(0, 0, 0), ship:velocity:orbit - tar:velocity:orbit, green, "V", 1, true).
		wait 0.1.
	}
	
	notify("Arrived at " + tr + " relative to target").
	ClearVecDraws().
}


rcs on.
sas off.

if tar:isType("DockingPort")
{
	notify("Docking to " + tar:name + " of " + tar:ship:name).
	local d is tar:portfacing.
}
else
{
	notify("Docking to " tar:ship:name + " with a Klaw").
	local d is tar:facing.
	// TODO: Activate Klaw
}

lock relPos to -target:position.

AlignToDock(d).

if (relPos * d:vector < 0)
{
	notify("On wrong side of the target. Moving around.").
	GoToRelative(tar, d, v(0, safetyMargin, -safetyMargin)).
	GoToRelative(tar, d, v(0, safetyMargin, safetyMargin)).
}

notify("Aligning for approach").
GoToRelative(tar, d, v(0, 0, safetyMargin)).
notify("Closing up").
GoToRelative(tar, d, v(0, 0, closeUp)).

if tar:isType("DockingPort")
{
	notify("Going in for contact").
	GoToRelative(tar, d, v(0, 0, 0)).
	wait until tar:state <> "Ready" and tar:state <> "PreAttached".
}
else
{
	// TODO: Move forward fast to have the Klaw contact
	// TODO: How to detect that Klaw connected?
}

unlock all.
rcs off.
set ship:control:neutralize to true.