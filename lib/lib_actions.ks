run once lib_notify.

function DoPartEvent
{
	parameter partType.
	parameter eventName.
	
	local done is false.
	
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
					set done to true.
					break.
				}
			}
		}
	}
	
	return done.
}

function DoPartAction
{
	parameter partType.
	parameter actionName.
	parameter val.
	
	local done is false.
	
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
					set done to true.
					break.
				}
			}
		}
	}
	
	return done.
}

function SetPartField
{
	parameter partType.
	parameter fieldName.
	parameter val.
	
	local done is false.
	
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
					set done to true.
					break.
				}
			}
		}
	}
	
	return done.
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

function DoAllScience
{
	parameter trans is true.
	parameter doOneShots is false.
	parameter waitTime is 30.
	
	local scienceModules is list().
	list parts in partList.
	for p in partList
	{
		if p:hasModule("ModuleScienceExperiment")
		{
			local m is p:getModule("ModuleScienceExperiment").
			if (doOneShots or m:rerunnable) and not m:inoperable
			{
				scienceModules:add(m).
			}
		}
	}
	
	for sm in scienceModules
	{
		if not sm:hasData
		{
			sm:deploy.
			notify("Running experiment: " + sm:part:name).
		}
	}
	
	wait waitTime.
	
	if trans
	{
		for sm in scienceModules
		{
			if sm:hasData
			{
				for d in sm:data
				{
					if d:transmitValue > 0
					{
						if not (ship:electricCharge > d:dataAmount * 6)
						{
							notify("Waiting until " + d:dataAmount * 6 + " electricity available for transfer from " + sm:part:name).
							wait until ship:electricCharge > d:dataAmount * 6.
						}
						sm:transmit.
						notify("Transmitting '" + d:title +  "' from " + sm:part:name).
					}
					else
					{
						sm:dump.
						notify("Dumping data from " + sm:part:name).
					}
				}
			}
		}
	}
}