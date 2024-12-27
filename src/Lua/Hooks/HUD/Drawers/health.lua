local function HUD_HealthDrawer(v,p)
	if not MM:isMM() then return end
	if not (p.mm) then return end
	
	local x,y = 160*FU, 125*FU + MMHUD.xoffset
	local scale = FU/2
	local flags = V_SNAPTOBOTTOM
	local back = v.cachePatch("MMGG_HP_BACK")
	local fillper = FixedDiv(p.mm.hp*FU,MM_PLAYER_MAXHEALTH*FU)
	local fillpatch = v.cachePatch((fillper <= FU/2) and "MMGG_HP_RED" or "MMGG_HP_FILL")
	local crop = FixedMul(fillpatch.height*FU, FU - fillper)
	crop = max($,0)
	x = $ - FixedMul(back.width*FU/2,scale)
	
	v.drawScaled(x,y,
		scale,
		back,
		flags
	)
	v.drawCropped(x,y + FixedMul(crop,scale),
		scale,scale,
		fillpatch,
		flags,nil,
		0,crop,
		fillpatch.width*FU,
		fillpatch.height*FU
	)

	v.drawString(x + FixedMul(back.width*FU/2,scale),
		y + FixedMul(back.height*FU/2,scale) - 4*FU,
		p.mm.hp,
		flags,
		"thin-fixed-center"
	)
end

return HUD_HealthDrawer