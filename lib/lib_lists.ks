function filter
{
	parameter l.
	parameter f.
	
	local result is list().
	for x in l
	{
		if f(x)
		{
			result:add(x).
		}
	}
	
	return result.
}

function apply
{
	parameter l.
	parameter f.
	
	local result is list().
	for x in l
	{
		result:add(f(x)).
	}
	
	return result.
}

function all
{
	parameter l.
	parameter f.
	
	for x in l
	{
		if not f(x)
		{
			return false.
		}
	}
	
	return true.
}

function any
{
	parameter l.
	parameter f.
	
	for x in l
	{
		if f(x)
		{
			return true.
		}
	}
	
	return false.
}

function first
{
	parameter l.
	parameter f.
	parameter default is 0.
	
	for x in l
	{
		if f(x)
		{
			return x.
		}
	}
	
	return default.
}

function sum
{
	parameter l.
	
	local s is 0.
	for x in l
	{
		set s to s + x.
	}
	
	return s.
}

function accumulate
{
	parameter l.
	parameter f.
	parameter x0 is 0.
	
	local s is x0.
	for x in l
	{
		set s to f(s, x).
	}
	
	return s.
}