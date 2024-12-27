local TR = TICRATE

local vowels = {
	["a"] = true,
	["e"] = true,
	["i"] = true,
	["o"] = true,
	["u"] = true,
}

local teammates

local function HUD_TimeForWeapon(v,p)
	if not MM:isMM() then return end
	if not (p.mo and p.mo.health and p.mm) then return end
	
	MMHUD.interpolate(v,true)
	if MM_N.waiting_for_players then
		v.drawString(160*FU,
			40*FU - MMHUD.weaponslidein,
			"Waiting for players...",
			V_SNAPTOTOP|V_ALLOWLOWERCASE,
			"fixed-center"
		)
		return
	end
	
	if leveltime >= MM_N.pregame_time + 5 then return end
	
	local time = (MM_N.pregame_time)-leveltime
	if (leveltime < TR)
		teammates = nil
	end

	v.drawString(160*FU,
		40*FU - MMHUD.weaponslidein,
		"Round starts in",
		V_SNAPTOTOP|V_ALLOWLOWERCASE,
		"fixed-center"
	)
	do
		local letterpatch = v.cachePatch("STTNUM"..(time/TR))
		local letteroffset = v.cachePatch("STTNUM0").width*FU * tostring(time/TR):len()
		local yoff = 0
		if time/TR <= 3
			letterpatch = v.cachePatch("RACE"..(time/TR == 0 and "GO" or (time/TR)))
			letteroffset = letterpatch.width*FU
			if (time % TR) > TR*3/4
				yoff = 9*FU - (TR - (time % TR))*FU
				yoff = ease.linear(FU*3/4,$,0)
			end

			if (MM_N.dueling and time/TR == 0)
				v.drawString(160*FU,
					50*FU - MMHUD.weaponslidein - yoff,
					"DUEL!!",
					V_SNAPTOTOP|V_YELLOWMAP,
					"fixed-center"
				)
			else
				v.drawScaled(160*FU - letteroffset/2,
					50*FU - MMHUD.weaponslidein - yoff,
					FU,
					letterpatch,
					V_SNAPTOTOP
				)
			end

		else
			local work = 0
			local tstr = tostring(time/TR)
			for i = 1,string.len(tstr)
				v.drawScaled(160*FU - letteroffset/2 + work,
					50*FU - MMHUD.weaponslidein - yoff,
					FU,
					v.cachePatch("STTNUM"..string.sub(tstr,i,i)),
					V_SNAPTOTOP
				)
				work = $ + v.cachePatch("STTNUM0").width*FU
			end

		end
		
	end
	
end

return HUD_TimeForWeapon