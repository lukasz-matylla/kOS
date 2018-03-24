parameter pointName.

function FindPoints
{
	parameter n.

	local ps is AllWayPoints().
	local result is list().
	
	for p in ps
	{
		if (p:body:name = ship:body:name) and (p:name:contains(n))
		{
			result:add(p).
		}
	}
	
	return result.
}

function ArrowTo
{
	parameter p.
	
	local arr is vecdraw(v(0, 0, 0), p:position:normalized * 10, white, "" + round(p:position:mag, 0) + "m", 1, true, 0.2).
}

local l is FindPoints(pointName).

until false
{
	ClearVecDraws().
	
	for p in l
	{
		ArrowTo(p).
	}
	
	wait 1.
}
