local steeringMargin is 2.

function waitForAlignment
{
	wait until vang(steering:vector, ship:facing:vector) < steeringMargin.
}

function waitForAlignmentWith
{
	parameter v is ship:velocity:surface.
	//wait until SteeringManager:angleError < steeringMargin.
	wait until vang(steering:vector, v) < steeringMargin.
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
	return lookdirup(angleaxis(alfa, vcrs(ship:up:vector, hrs))*hrs, ship:up:vector).
}

function withAngleOfAttack
{
	parameter v.
	parameter alfa.
	
	local hrs is horizon(v).
	return lookdirup(angleaxis(alfa, vcrs(ship:up:vector, hrs))*v, ship:up:vector).
}