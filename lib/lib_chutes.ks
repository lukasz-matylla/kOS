local maxAlt is 5000.

when ship:status = "Flying" and ship:altitude < maxAlt and ship:verticalSpeed < 0 then
{
	notify("Arming chutes").
	
	lock throttle to 0.

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