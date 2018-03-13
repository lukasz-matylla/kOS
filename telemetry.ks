run once lib_asyncLoop.
run once lib_vectors.

function getTemp
{
	if ship:sensors:hassuffix("Temp")
	{
		return ship:sensors:temp.
	}
	
	return 0.
}

function getPres
{
	if ship:sensors:hassuffix("Pres")
	{
		return ship:sensors:pres.
	}
	
	return 0.
}

function getLight
{
	if ship:sensors:hassuffix("Light")
	{
		return ship:sensors:light.
	}
	
	return 0.
}

function getAcc
{
	if ship:sensors:hassuffix("Acc")
	{
		return ship:sensors:acc:mag.
	}
	
	return 0.
}

function getGrav
{
	if ship:sensors:hassuffix("Grav")
	{
		return ship:sensors:grav:mag * 9.81.
	}
	
	return 0.
}

function getAoA
{
	return vang(ship:facing:vector, ship:velocity:surface).
}

function getThrustAngle
{
	return vang(ship:facing:vector, ship:velocity:orbit).
}

function getAscentAngle
{
	return vang(-ship:body:position, ship:velocity:surface).
}

function logLine
{
	local logString is 
		round(missionTime, 2) + "," +
		ship:status + "," +
		ship:body:name + "," +
		round(ship:altitude, 2) + "," +
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
		round(getLight(), 2) + "," +
		round(getAoA(), 2) + "," +
		round(getThrustAngle(), 2) + "," +
		round(getAscentAngle(), 2) + "," +
		round(ship:mass, 2) + "," +
		round(ship:wetMass, 2) + "," +
		round(stage:availableThrust, 2) + "," +
		round(throttle, 3) + "," +
		round(ship:orbit:apoapsis, 2) + "," +
		round(ship:orbit:periapsis, 2) + "," +
		round(ship:orbit:inclination, 2).
	
	log logString to "0:/logs/telemetry.csv".
	
	return true.
}

// Get rid of the old log file
deletePath("0:/logs/telemetry.csv").

// First lines with basic information and column identifiers
log "Telemetry for " + ship:name to "0:/logs/telemetry.csv".
log "T,Status,Body,Altitude,AltitudeAGL,VerticalSpeed,GroundSpeed,AirSpeed,OrbitalSpeed,Q,Pres,Temp,Acceleration,Gravity,LightLevel,AoA,ThrustAngle,AscentAngle,Mass,WetMass,AvailableThrust,Throttle,Apoapsis,Periapsis,Inclination" to "0:/logs/telemetry.csv".

RunLoop(logLine@, 1).