run once lib_asyncLoop.
run once lib_vectors.

function getTemp
{
	if ship:partsdubbedpattern("thermometer"):length > 0
	{
		return ship:sensors:temp.
	}
	
	return 0.
}

function getPress
{
	if ship:partsdubbedpattern("barometer"):length > 0
	{
		return ship:sensors:pres.
	}
	
	return 0.
}

function getAcc
{
	if ship:partsdubbedpattern("accelerometer"):length > 0
	{
		local aCoord is ship:sensors:acc.
		local r is ship:body:radius + ship:altitude.
		local grav is ship:body:mu / (r^2).
		local aProper is aCoord - ship:body:position:normalized*grav.
		
		return aProper:mag.
	}
	
	return 0.
}

function getGrav
{
	if ship:partsdubbedpattern("gravioli"):length > 0
	{
		return ship:sensors:grav:mag * 9.81.
	}
	
	return 0.
}

function getAoA
{
	return vang(ship:facing:vector, ship:velocity:surface).
}

function getVerticalAoA
{
	return angleToHorizon(ship:facing:vector) - angleToHorizon(ship:velocity:surface).
}

function getThrustAngle
{
	return vang(ship:facing:vector, ship:velocity:orbit).
}

function getAscentAngle
{
	return angleToHorizon(ship:velocity:surface).
}

function getThrust
{
	if stage:hassuffix("availableThrust")
	{
		return stage:availableThrust.
	}
	
	return 0.
}

function logLine
{
	local logString is 
		round(missionTime, 2) + "," +
		ship:status + "," +
		stage:number + "," +
		ship:body:name + "," +
		round(ship:altitude / 1000, 2) + "," +
		round(alt:radar, 2) + "," +
		round(ship:verticalspeed, 2) + "," +
		round(ship:groundspeed, 2) + "," +
		round(ship:airspeed, 2) + "," +
		round(ship:velocity:orbit:mag, 2) + "," +
		round(ship:q, 3) + "," +
		round(getPress(), 3) + "," +
		round(getTemp(), 2) + "," +
		round(getAcc(), 2) + "," +
		round(getGrav(), 2) + "," +
		round(getAoA(), 2) + "," +
		round(getVerticalAoA(), 2) + "," +
		round(getThrustAngle(), 2) + "," +
		round(getAscentAngle(), 2) + "," +
		round(ship:mass, 2) + "," +
		round(ship:wetMass, 2) + "," +
		round(getThrust(), 2) + "," +
		round(throttle * 100, 3) + "," +
		round(ship:orbit:apoapsis / 1000, 2) + "," +
		round(ship:orbit:periapsis / 1000, 2) + "," +
		round(ship:orbit:inclination, 2).
	
	log logString to "0:/logs/telemetry.csv".
	
	return true.
}

// Get rid of the old log file
deletePath("0:/logs/telemetry.csv").

// First lines with basic information and column identifiers
log "Telemetry for " + ship:name to "0:/logs/telemetry.csv".
log "T,Status,Stage,Body,Altitude,AltitudeAGL,VerticalSpeed,GroundSpeed,AirSpeed,OrbitalSpeed,Q,Pres,Temp,Acceleration,Gravity,AoA,VerticalAoA,ThrustAngle,AscentAngle,Mass,WetMass,AvailableThrust,Throttle,Apoapsis,Periapsis,Inclination" to "0:/logs/telemetry.csv".

RunLoop(logLine@, 1).