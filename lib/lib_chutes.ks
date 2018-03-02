local maxAlt is 20000.

when ship:status = "Flying" and ship:maxThrust = 0 and ship:altitude < maxAlt and ship:verticalSpeed < 0 then
{
	notify("Arming chutes").

	when not chutesSafe then // some chutes may be safely deployed
	{
		notify("Deploying chutes").
		chutesSafe on.

		if chutes
		{
			notify("All chutes deployed").
		}
		else
		{
			preserve.
		}
	}        
}