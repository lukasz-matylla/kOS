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
	parameter t. 
	parameter d.
	parameter tr.
	
	notify("Moving to " + tr + " relative to target").
	
	//Consider using one PID and control:translate (vector). 
	// First make sure how directions and vectors multiply, that is, what what are d*v(1, 0, 0), d*v(0, 1, 0) and d*v(0, 0, 1) 
	// compared to d:vector, d:upvector and d:starvector
	
	local xPid is initPid(0.1, 0.001, 1, -1, 1).
	local yPid is initPid(0.1, 0.001, 1, -1, 1).
	local zPid is initPid(0.1, 0.001, 1, -1, 1).
	
	lock ship:control:fore to pid(xPid, (d*tr):x, -t:position:x).
	lock ship:control:top to pid(yPid, (d*tr):y, -t:position:y).
	lock ship:control:starboard to pid(zPid, (d*tr):z, -t:position:z).
	
	until (d*tr + t:position:x):mag < posMargin
	{
		local arTargFore is VecDraw(t:position, d:vector * 5, yellow, "Target Front", 1, true).
		local arTargUp is VecDraw(t:position, d:upvector * 5, yellow, "Target Up", 1, true).
		local arMyFore is VecDraw(v(0, 0, 0), ship:facing:vector * 5, purple, "My Front", 1, true).
		local arMyUp is VecDraw(v(0, 0, 0), ship:facing:upvector * 5, purple, "My Up", 1, true).
		local arTarg is VecDraw(t:position, d*tr, white, "Waypoint", 1, true).
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

lock resPos to -target:position.

AlignToDock(d).

if (relPos * d:vector < 0)
{
	notify("On wrong side of the target. Moving around.").
	GoToRelative(tar, d, v(-safetyMargin, safetyMargin, 0)).
	GoToRelative(tar, d, v(safetyMargin, safetyMargin, 0)).
}

notify("Beginning approach").
GoToRelative(tar, d, v(safetyMargin, 0, 0)).
notify("Closing up").
GoToRelative(tar, d, v(closeUp, 0, 0)).
notify("Going for contact").
GoToRelative(tar, d, v(0, 0, 0)).

if tar:isType("DockingPort")
{
	wait until tar:state <> "Ready" and tar:state <> "PreAttached".
}
else
{
	// TODO: How to detect that Klaw connected
}

unlock all.
rcs off.
set ship:control:neutralize to true.