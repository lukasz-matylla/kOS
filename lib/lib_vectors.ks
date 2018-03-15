function waitForAlignment
{
	parameter margin is 1.
	
	wait until vang(steering:vector, ship:facing:vector) < margin.
}

function horizon
{
	parameter v.
	return vxcl(ship:up:vector, v).
}

function angleToHorizon
{
	parameter v.
	return 90 - vang(ship:up:vector, v).
}

function horizonMirror
{
	parameter v.
	local u is ship:up:vector.
	return v - 2*u*(u*v).
}

function withAngleToHorizon
{
	parameter v.
	parameter alfa.
	
	local hrs is horizon(v).
	return lookdirup(angleaxis(-alfa, vcrs(ship:up:vector, hrs))*hrs, ship:up:vector).
}

function withAngleOfAttack
{
	parameter v.
	parameter alfa.
	
	local hrs is horizon(v).
	return lookdirup(angleaxis(-alfa, vcrs(ship:up:vector, hrs))*v, ship:up:vector).
}

function SignedAngle
{
	parameter v1.
	parameter v2.
	parameter n.
	
	if vcrs(v1, v2) * n > 0
	{
		return vang(v1, v2).
	}
	
	return 360 - vang(v1, v2).
}

function GreatCircleNormal
{
	parameter initialAngle is 0.
	parameter initialPos is -ship:body:position.
	
	local vRot is vcrs(ship:body:angularvelocity, initialPos).
	local vInit is angleaxis(-initialAngle, initialPos) * vRot.
	
	return vcrs(initialPos, vInit):normalized.
}

function GreatCircleForward
{
	parameter circleNormal.
	parameter pos is -ship:body:position.
	
	return vcrs(circleNormal, pos):normalized.
}