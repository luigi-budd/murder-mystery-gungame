local strings = {
	"storm.starting_dist",
	"storm.usedpoints",
	"storm.ticker",
	"storm.radius",
	"storm.dest_radius",
	"storm.movecooldown",
	"storm.canmigrate",
	"#storm.otherpoints",
	"interact.interacted",
}

return function(v,p)
	if not CV_MM.debug.value then return end
	
	local x = 5
	local y = 50
	local work = 0
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP|V_ALLOWLOWERCASE
	
	v.drawString(x,y - 4,
		"Debug",
		flags|V_YELLOWMAP,
		"small"
	)
	
	local values = {
		[1] = string.format("%f",MM_N.storm_startingdist),
		[2] = MM_N.storm_usedpoints,
		[3] = MM_N.storm_ticker,
		[4] = string.format("%f",MM_N.storm_point.storm_radius or 0),
		[5] = string.format("%f",MM_N.storm_point.storm_destradius or 0),
		[6] = MM_N.storm_point.movecooldown,
		[7] = not (MM_N.storm_point.otherpoints == nil or #MM_N.storm_point.otherpoints < 2),
		[8] = (MM_N.storm_point.otherpoints == nil) and -1 or #MM_N.storm_point.otherpoints,
		[9] = p.mm.interact.interacted,
	}
	
	for k,str in ipairs(strings)
		v.drawString(x,y + work,
			str.." = \x84"..tostring(values[k]),
			flags,
			"small"
		)
		
		work = $+4
	end
	
end