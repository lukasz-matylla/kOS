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

function relToBody
{
	parameter ves is target.
	
	return ves:position - ship:body:position.
}

function orbitNormal
{
	parameter ves.
	return vcrs(relToBody(ves), ves:velocity:orbit):normalized.
}

function relativeInclination
{
	parameter ves1 is target.
	parameter ves2 is ship.
	
	return vang(orbitNormal(ves1), orbitNormal(ves2)).
}

function signedAngle
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

function planeCross
{
	parameter ves1 is target.
	parameter ves2 is ship.
	
	return vcrs(orbitNormal(ves1), orbitNormal(ves2)):normalized.
}