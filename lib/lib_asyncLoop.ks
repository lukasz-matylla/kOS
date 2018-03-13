function RunLoop
{
	parameter loopAction. // should return bool; loop ends when it returns false
	parameter loopPeriod is 10.
	
	local t0 is time:seconds.
	when time:seconds > t0 + loopPeriod
	{
		if loopAction()
		{
			RunLoop(loopAction, loopPeriod).
		}
	}
}