run once lib_vectors.
run once lib_notify.

function relToBody
{
	parameter ves.
	
	return ves:position - ship:body:position.
}

function orbitNormal
{
	parameter ves.
	return vcrs(relToBody(ves), ves:velocity:orbit):normalized.
}

function relativeInclination
{
	parameter ves1.
	parameter ves2.
	
	return vang(orbitNormal(ves1), orbitNormal(ves2)).
}

function planeCross
{
	parameter ves1.
	parameter ves2.
	
	return vcrs(orbitNormal(ves1), orbitNormal(ves2)):normalized.
}

function meanAnomaly
{
	parameter ves.
	
	return mod(ves:orbit:meananomalyatepoch + 360 * (time:seconds - ves:orbit:epoch) /  ves:orbit:period, 360).
}

function timeToPeriapsis
{
	parameter ves.
	
	local anom is meanAnomally(ves).
	
	return (360 - anom) * ves:orbit:period / 360.
}

function timeToApoapsis
{
	parameter ves.
	
	local anom is meanAnomally(ves).
	
	return mod(540 - anom, 360) * ves:orbit:period / 360.
}

function timeToDirection
{
	parameter r.
	parameter ves.
	
	
	local nor is orbitNormal(ves).
	local tang is signedAngle(-ves:body:position, r, nor).
	
	// Iteratively find the time of crossing
	local t0 is time:seconds.
	local t is 0.
	until false
	{
		local p is positionat(ves, t0+t) - ves:body:position. // vessel's position after time t, in planet's reference
		local ang is signedAngle(-ves:body:position, p, nor).
		local err is ang - tang.
		
		//print "t=" + t + ", ang=" + ang + ", err=" + err.
		
		if abs(err) < 0.01
		{
			return t - t0.
		}
		else
		{
			local speedratio is p:mag / ves:orbit:semimajoraxis.
			set t to t - speedratio * err * ves:orbit:period / 360.
		}
	}
}

function periDirection
{
	parameter ves.
	
	local n is orbitNormal(ves).
	
	local r is ves:position - ship:body:position.
	local anom is mod((ves:orbit:meananomalyatepoch + 360 * (time:seconds - ves:orbit:epoch) /  ves:orbit:period), 360).
	return angleAxis(-anom, n) * r:normalized.
}

function PositiveApo
{
	parameter obt is ship:orbit.
	
	if obt:apoapsis > 0
	{
		return obt:apoapsis.
	}
	
	// If it's not a closed orbit, return a value higher than any possible closed orbit apo
	return 2 * obt:body:soiradius.
}