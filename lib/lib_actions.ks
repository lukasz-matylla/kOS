function DoPartEvent
{
	parameter partType.
	parameter eventName.
	
	for p in ship:partsDubbedPattern(partType)
	{
		for modName in p:allModules
		{
			local mod is p:getModule(modName).
			
			for ev in mod:alleventNames
			{
				if ev:contains(eventName)
				{
					mod:doEvent(ev).
					break.
				}
			}
		}
	}
}

function DoPartAction
{
	parameter partType.
	parameter actionName.
	parameter val.
	
	for p in ship:partsDubbedPattern(partType)
	{
		for modName in p:allModules
		{
			local mod is p:getModule(modName).
			
			for ac in mod:allActionNames
			{
				if ac:contains(actionName)
				{
					mod:doAction(ac, val).
					break.
				}
			}
		}
	}
}

function SetPartField
{
	parameter partType.
	parameter fieldName.
	parameter val.
	
	for p in ship:partsDubbedPattern(partType)
	{
		for modName in p:allModules
		{
			local mod is p:getModule(modName).
			
			for f in mod:allFieldNames
			{
				if f:contains(fieldName)
				{
					mod:setField(f, val).
					break.
				}
			}
		}
	}
}

function GetPartField
{
	parameter partType.
	parameter fieldName.
	
	for p in ship:partsDubbedPattern(partType)
	{
		for modName in p:allModules
		{
			local mod is p:getModule(modName).
			
			for f in mod:allFieldNames
			{
				if f:contains(fieldName)
				{
					return mod:getField(f).
				}
			}
		}
	}
}

function GetAllPartFields
{
	parameter partType.
	parameter fieldName.
	
	local res is list().
	
	for p in ship:partsDubbedPattern(partType)
	{
		for modName in p:allModules
		{
			local mod is p:getModule(modName).
			
			for f in mod:allFieldNames
			{
				if f:contains(fieldName)
				{
					res:add(mod:getField(f)).
				}
			}
		}
	}
	
	return res.
}