function SolveIncremental
{
	parameter f.
	parameter initValue is 0.
	parameter initStep is 10.
	parameter tol is 1.
	parameter reduction is 0.5.
	
	local x is initValue.
	local s is initStep.
	local y is f(x).
	local prevY is y.
	
	until abs(y) < tol
	{
		local x1 is x + s.
		local y1 is f(x1).
		
		if abs(y1) < abs(y)
		{
			set x to x1.
			set y to y1.
		}
		else
		{
			set s to -s * reduction.
		}
	} 
	
	return x.
}

function SolveBisect
{
	parameter f.
	parameter lower.
	parameter upper.
	parameter tol is 1.
	
	local x1 is lower.
	local y1 is f(x1).
	local x2 is upper.
	local y2 is f(x2).
	
	until abs(y1) < tol
	{
		local x is (x1 + x2) / 2.
		local y is f(x).
		
		if y*y1 > 0
		{
			set x1 to x.
			set y1 to y.
		}
		else
		{
			set x2 to x.
			set y2 to y.
		}
	}
	
	return x1.
}