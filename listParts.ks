log "<Vessel name='" + ship:name + "'>" to "0:/logs/parts.xml".

for p in ship:parts
{
	log "  <Part name='" + p:name + "' title='" + p:title + "' tag='" + p:tag + "'>" to "0:/logs/parts.xml".
	
	for mName in p:modules
	{
		local m is p:getmodule(mName).
		
		log "    <Module name='" + mName + "'>" to "0:/logs/parts.xml".
		
		for f in m:allfieldnames
		{
			log "      <Field name='" + f + "' type='" + m:getfield(f):typename + "'>" to "0:/logs/parts.xml".
		}
		log "" to "0:/logs/parts.xml".
		
		for ev in m:alleventnames
		{
			log "      <Event name='" + ev + "'>" to "0:/logs/parts.xml".
		}
		log "" to "0:/logs/parts.xml".
		
		for ac in m:allactionnames
		{
			log "      <Action name='" + ac + "'>" to "0:/logs/parts.xml".
		}
		
		log "    </Module>" to "0:/logs/parts.xml".
		log "" to "0:/logs/parts.xml".
	}
	
	log "  </Part>" to "0:/logs/parts.xml".
	log "" to "0:/logs/parts.xml".
}

log "</Vessel>" to "0:/logs/parts.xml".
log "" to "0:/logs/parts.xml".
log "" to "0:/logs/parts.xml".