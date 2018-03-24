run once lib_actions.
run once lib_notify.

parameter transmittable is true.
parameter checkPeriod is 30.

if transmittable
{
	until false
	{
		notify("Running science").
		DoAllScience().
		notify("Waiting for " + checkPeriod + "s").
		wait checkPeriod.
	}
}
else
{
	DoAllScience(false, true).
}
