function warpFor
{
	parameter dt is 0.

	local endTime is time:seconds + dt.
	warpTo(endTime).
	wait until time:seconds > endTime.
}