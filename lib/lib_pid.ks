function initPid 
{
	parameter Kp is 1.      // gain of position
	parameter Ki is 0.0001.      // gain of integral
	parameter Kd is 0.0001.      // gain of derivative
	parameter cMin is -100.  // the bottom limit of the control range (to protect against integral windup)
	parameter cMax is 100.  // the the upper limit of the control range (to protect against integral windup)

	local SeekP is 0. // desired value for P (will get set later).
	local P is 0.     // phenomenon P being affected.
	local I is 0.     // crude approximation of Integral of P.
	local D is 0.     // crude approximation of Derivative of P.
	local oldT is -1. // (old time) start value flags the fact that it hasn't been calculated
	local oldInput is 0. // previous return value of PID controller.

	 // I'll store the PID tracking values in a list like so:
	local PID_array is list(Kp, Ki, Kd, cMin, cMax, SeekP, P, I, D, oldT, oldInput).
	return PID_array.
}.

function pid
{
	parameter PID_array. // array built with PID_init.
	parameter seekVal.   // value we want.
	parameter curVal.    // value we currently have.
        
	// Using LIST() as a poor-man's struct.
	local Kp   is PID_array[0].
	local Ki   is PID_array[1].
	local Kd   is PID_array[2].
	local cMin is PID_array[3].
	local cMax is PID_array[4].
	local oldS   is PID_array[5].
	local oldP   is PID_array[6].
	local oldI   is PID_array[7].
	local oldD   is PID_array[8].
	local oldT   is PID_array[9]. // old time
	local oldInput is PID_array[10]. // prev return value

	local P is seekVal - curVal.
	local D is oldD. // default if we do no work this time.
	local I is oldI. // default if we do no work this time.
	local newInput is oldInput. // default if we do no work this time.

	local t is time:seconds.
	local dT is t - oldT.

	if oldT < 0 
	{
		// I have never been called yet - so don't trust any of the settings yet.
	}	 
	else 
	{
		if dT > 0 
		{ 
			// Do nothing if no physics tick has passed from prev call to now.
			set D to (P - oldP)/dT. // crude fake derivative of P
			local onlyPD is Kp*P + Kd*D.

			if (oldI > 0 or onlyPD > cMin) and (oldI < 0 or onlyPD < cMax) 
			{ 
				// only do the I turm when within the control range
				set I to oldI + P*dT. // crude fake integral of P
			}

			set newInput to onlyPD + Ki*I.
		}
	}

	set newInput to max(cMin,min(cMax,newInput)).

	// remember old values for next time.
	set PID_array[5] to seekVal.
	set PID_array[6] to P.
	set PID_array[7] to I.
	set PID_array[8] to D.
	set PID_array[9] to t.
	set PID_array[10] to newInput.

	return newInput.
}

function initPidVector 
{
	parameter Kp is 1.      // gain of position
	parameter Ki is 0.0001.      // gain of integral
	parameter Kd is 0.0001.      // gain of derivative
	parameter Lim is 100.  // maximum control magnitude (to protect against integral windup)

	local SeekP is v(0, 0, 0). // desired value for P (will get set later).
	local P is v(0, 0, 0).     // phenomenon P being affected.
	local I is v(0, 0, 0).     // crude approximation of Integral of P.
	local D is v(0, 0, 0).     // crude approximation of Derivative of P.
	local oldT is -1. // (old time) start value flags the fact that it hasn't been calculated
	local oldInput is v(0, 0, 0). // previous return value of PID controller.

	 // I'll store the PID tracking values in a list like so:
	local PID_array is list(Kp, Ki, Kd, Lim, SeekP, P, I, D, oldT, oldInput).
	return PID_array.
}.

function pidVector
{
	parameter PID_array. // array built with PID_init.
	parameter seekVal.   // value we want.
	parameter curVal.    // value we currently have.
        
	// Using LIST() as a poor-man's struct.
	local Kp is PID_array[0].
	local Ki is PID_array[1].
	local Kd is PID_array[2].
	local Lim is PID_array[3].
	local oldS is PID_array[4].
	local oldP is PID_array[5].
	local oldI is PID_array[6].
	local oldD is PID_array[7].
	local oldT is PID_array[8]. // old time
	local oldInput is PID_array[9]. // prev return value

	local P is seekVal - curVal.
	local D is oldD. // default if we do no work this time.
	local I is oldI. // default if we do no work this time.
	local newInput is oldInput. // default if we do no work this time.

	local t is time:seconds.
	local dT is t - oldT.

	if oldT < 0 
	{
		// I have never been called yet - so don't trust any of the settings yet.
	}	 
	else 
	{
		if dT > 0 
		{ 
			// Do nothing if no physics tick has passed from prev call to now.
			set D to (P - oldP)/dT. // crude fake derivative of P
			local onlyPD is Kp*P + Kd*D.

			if (onlyPD:mag < lim or onlyPd*oldI < 0)
			{ 
				// only do the I turm when within the control range
				set I to oldI + P*dT. // crude fake integral of P
			}

			set newInput to onlyPD + Ki*I.
		}
	}

	if newInput:mag > lim
	{
		set newInput to newInput * lim / newINput:mag.
	}

	// remember old values for next time.
	set PID_array[5] to seekVal.
	set PID_array[6] to P.
	set PID_array[7] to I.
	set PID_array[8] to D.
	set PID_array[9] to t.
	set PID_array[10] to newInput.

	return newInput.
}