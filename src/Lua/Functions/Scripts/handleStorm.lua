local numtotrans = {
	[9] = FF_TRANS90,
	[8] = FF_TRANS80,
	[7] = FF_TRANS70,
	[6] = FF_TRANS60,
	[5] = FF_TRANS50,
	[4] = FF_TRANS40,
	[3] = FF_TRANS30,
	[2] = FF_TRANS20,
	[1] = FF_TRANS10,
	[0] = 0,
}

local function onPoint(point1,point2)
	/*
	print(string.format(
		"onPoint(): x1 = %f y1 = %f, x2 = %f y2 = %f",
		FixedFloor(point1.x),FixedFloor(point1.y),
		FixedFloor(point2.x),FixedFloor(point2.y)
		)
	)
	*/
	local x1,y1 = FixedFloor(point1.x),FixedFloor(point1.y)
	local x2,y2 = FixedFloor(point2.x),FixedFloor(point2.y)
	return (x1 >= x2 - FU and x1 <= x2 + FU) and (y1 >= y2 - FU and y1 <= y2 + FU)
end

local function SetDestRadius(point, time, dest)
	point.storm_destradius = dest
	point.storm_incre = point.storm_radius - ease.linear(FU/time,
		point.storm_radius,
		dest
	)
	
end

local function Init(point)
	if point.init then return end
	
	point.storm_radius = MM_N.storm_startingdist
	point.storm_destradius = MM_N.storm_usedpoints and MM_N.storm_startingdist/8 or 1028*FU
	point.storm_ticker = 0
	point.storm_timesmigrated = 0
	
	local totaltime = 45*TICRATE
	if (MM_N.overtime and not MM_N.showdown)
	or (MM_N.dueling)
		totaltime = $/3
	end
	SetDestRadius(point, totaltime, point.storm_destradius)
	
	point.init = true
end

local function SpawnLaser(point,i, debug, x,y, ang, scale, clr)
	local mastertable = debug and point.debuglasers or point.lasers
	
	if (mastertable[i] == nil)
		local laser = P_SpawnMobjFromMobj(point,
			x - point.x,
			y - point.y,
			0,
			MT_THOK
		)
		if debug
			point.debuglasers[i] = laser
		else
			point.lasers[i] = laser
		end
		laser.myindex = i
		laser.tics = -1
		laser.fuse = -1
		laser.renderflags = $|RF_PAPERSPRITE|RF_NOCOLORMAPS
		laser.blendmode = AST_ADD
		laser.sprite = SPR_BGLS
		laser.frame = A|FF_FULLBRIGHT
		laser.scale = scale
		laser.angle = ang + ANGLE_90
	end
	local laser = mastertable[i]
	P_MoveOrigin(laser, x,y, point.z)
	laser.angle = ang + ANGLE_90
	laser.color = clr
	laser.scale = scale
	
	laser.z = P_FloorzAtPos(
		laser.x,
		laser.y,
		laser.floorz, 10*scale
	) + FU
	do
		local cz = laser.subsector.sector and laser.subsector.sector.ceilingheight or P_CeilingzAtPos(laser.x,laser.y,laser.ceilingz, 20*FU)
		local fz = laser.z --P_FloorzAtPos(laser.x,laser.y,20*FU)
		laser.spriteyscale = FixedDiv(cz - fz, 10*laser.scale)
	end
	
	--okay ig... there could be a better way to do this
	if not S_SoundPlaying(laser,sfx_laser)
		S_StartSound(laser,sfx_laser)
	end
end

local function SpawnDebugLasers(point,dist)
	if not CV_MM.debug.value
		if (point.debuglasers ~= nil)
			for k,laser in ipairs(point.debuglasers)
				P_RemoveMobj(laser)
			end
			point.debuglasers = nil
		end
		return
	end
	
	point.debuglasers = $ or {}
	
	local numlasers = 32
	local angoff = 360*FU / numlasers
	local laserspace = 110
	
	local circ = FixedMul((22*FU/7), dist*2)
	local scale = circ / laserspace / numlasers
	scale = max(abs($),FU/50)
	
	for i = 1,numlasers
		local ang = FixedAngle((i-1)*angoff) - FixedAngle((leveltime*FU)/2)
		local x = point.x + P_ReturnThrustX(nil,ang, dist)
		local y = point.y + P_ReturnThrustY(nil,ang, dist)
		
		SpawnLaser(point,i, true, x,y, ang, scale, SKINCOLOR_GREEN)
	end
end

local function SpawnAllLasers(point,dist)
	if dist <= 0
		if (point.lasers ~= nil)
			for k,laser in ipairs(point.lasers)
				P_RemoveMobj(laser)
			end
			point.lasers = nil
		end
		return
	end
	
	point.lasers = $ or {}
	
	local numlasers = 32
	local angoff = 360*FU / numlasers
	local laserspace = 110
	
	local circ = FixedMul((22*FU/7), dist*2)
	local scale = circ / laserspace / numlasers
	scale = max(abs($),FU/50)
	
	local color = P_RandomRange(SKINCOLOR_GALAXY,SKINCOLOR_NOBLE)
	for i = 1,numlasers
		local ang = FixedAngle((i-1)*angoff) + FixedAngle((leveltime*FU)/2)
		local x = point.x + P_ReturnThrustX(nil,ang, dist)
		local y = point.y + P_ReturnThrustY(nil,ang, dist)
		
		SpawnLaser(point,i, false, x,y, ang, scale, color)
	end
end

local function FXHandle(point,dist)
	
	SpawnAllLasers(point,dist)
	SpawnDebugLasers(point,MM_N.storm_startingdist)
	
	if not (point.laser_eye and point.laser_eye.valid)
		point.laser_eye = P_SpawnMobjFromMobj(point,0,0,0,MT_THOK)
		local laser = point.laser_eye
		laser.tics = -1
		laser.fuse = -1
		laser.renderflags = $|RF_NOCOLORMAPS
		laser.sprite = SPR_BGLS
		laser.frame = A|FF_FULLBRIGHT
		laser.scale = $
	end
	
	if not (point.laser_splat and point.laser_splat.valid)
		point.laser_splat = P_SpawnMobjFromMobj(point,0,0,0,MT_THOK)
		local laser = point.laser_splat
		laser.tics = -1
		laser.fuse = -1
		laser.renderflags = $|RF_FLOORSPRITE|RF_NOCOLORMAPS
		laser.sprite = SPR_BGLS
		laser.frame = B|FF_FULLBRIGHT
		laser.scale = $
	end
	
	--people like to hide behind these so dont let em do that
	local mysin = sin(FixedAngle(MM_N.storm_ticker*5*FU))
	local fade = numtotrans[mysin*6 / FU] or 0
	do
		local laser = point.laser_eye
		do
			local cz = laser.subsector.sector and laser.subsector.sector.ceilingheight or P_CeilingzAtPos(laser.x,laser.y,laser.ceilingz, 20*FU)
			local fz = laser.z --P_FloorzAtPos(laser.x,laser.y,20*FU)
			laser.spriteyscale = FixedDiv(cz - fz, 10*laser.scale)
		end
		laser.spritexscale = FU + mysin/5
		laser.color = SKINCOLOR_GALAXY
		laser.dispoffset = -4
		laser.frame = ($ &~FF_TRANSMASK)|fade
		P_MoveOrigin(laser,
			point.x,
			point.y,
			point.z
		)
	end
	do
		local laser = point.laser_splat
		laser.spritexscale = FU + mysin/5
		laser.spriteyscale = laser.spritexscale
		laser.color = SKINCOLOR_GALAXY
		laser.dispoffset = -5
		laser.frame = ($ &~FF_TRANSMASK)|fade
		P_MoveOrigin(laser,
			point.x,
			point.y,
			point.z + (FU/20)
		)
	end
	if (point.garg and point.garg.valid)
		point.garg.spriteyoffset = ease.inoutquad(FU/4,$, 32*FU + (mysin/3)*20)
		P_MoveOrigin(point.garg,
			point.x,
			point.y,
			point.z
		)
		point.garg.angle = point.angle
		point.garg.pitch = 0
		point.garg.roll = 0
	else
		local garg = P_SpawnMobjFromMobj(
			point,
			0,0,0,
			MT_GARGOYLE
		)
		garg.flags = MF_NOCLIPTHING
		garg.colorized = true
		garg.color = SKINCOLOR_GALAXY
		garg.scale = $*2
		garg.angle = point.angle
		point.garg = garg
	end

end

return function(self)
	local point = MM_N.storm_point
	
	--Uh oh
	if not (point and point.valid)
		MM_N.storm_ticker = 0
		return
	end
	
	if (MM:pregame()) then return end
	Init(point)
	
	MM_N.storm_ticker = $+1
	if not (MM_N.time)
	and not MM_N.showdown
		MM_N.storm_ticker = $+2
	end
	
	if (point.storm_radius ~= point.storm_destradius)
	and (MM_N.overtime or MM_N.showdown)
		local storm_incre = point.storm_incre
		if not (MM_N.time)
		and not MM_N.showdown
			storm_incre = $*2
		end
		point.storm_radius = max($ - storm_incre, point.storm_destradius)
	end
	
	local dist = point.storm_radius
	FXHandle(point,dist)
	
	for p in players.iterate
		if not p.mm then continue end
		if p.spectator
		or (p.playerstate ~= PST_LIVE)
		or not (p.mo and p.mo.valid)
		--Move this here because otherwise we would never be considered
		--in bounds during the endcam, eventually killing us
		or MM_N.gameover
			p.mm.outofbounds = false
			p.mm.oob_dist = 0
			continue
		end
		
		p.mm.lastoob = p.mm.outofbounds
		p.mm.ouofbounds = false
		
		local me = p.mo
		
		local pDist = R_PointToDist2(me.x,me.y, point.x,point.y)
		p.mm.oob_dist = pDist
		
		if pDist > dist
			p.mm.outofbounds = true
			
			if not p.mm.lastoob
				S_StartSound(me,P_RandomRange(sfx_mmste0,sfx_mmste1),p)
			end
		else
			if p.mm.lastoob
				S_StartSound(me,P_RandomRange(sfx_mmstl0,sfx_mmstl2),p)
			end
			
			p.mm.outofbounds = false
		end
	end

	if point.storm_radius ~= point.storm_destradius then return end
	if point.otherpoints == nil or #point.otherpoints < 2 then return end
		
	if point.movecooldown ~= nil
		if point.movecooldown
			point.movecooldown = $-1
			if point.movecooldown == 0
				MMHUD:PushToTop(8*TICRATE,
					"\x89Storm eye Migrating"
				)
				S_StartSound(nil,sfx_mmsmig)
			else
				return
			end
		end
	else
		point.movecooldown = 20*TICRATE
		MMHUD:PushToTop(8*TICRATE,
			"\x89Storm eye Migrates in",
			"\x82".."20\x80 seconds"
		)
		S_StartSound(nil,sfx_alarm)
		return
	end
	
	if not (point.destpoint)
		point.eased = 0
		point.destpoint = point.otherpoints[P_RandomRange(1,#point.otherpoints)]
		point.startpoint = {
			x = point.x,
			y = point.y,
			z = point.z,
			a = point.angle
		}
	end
	if onPoint(point,point.destpoint)
	and not point.movecooldown
		repeat
			point.destpoint = point.otherpoints[P_RandomRange(1,#point.otherpoints)]
		until not onPoint(point,point.destpoint)
		point.eased = 0
		point.startpoint = {
			x = point.x,
			y = point.y,
			z = point.z,
			a = point.angle
		}
		
		--wait before moving again...
		point.movecooldown = 20*TICRATE
		MMHUD:PushToTop(8*TICRATE,
			"\x89Storm eye Migrates in",
			"\x82".."20\x80 seconds"
		)
		S_StartSound(nil,sfx_alarm)
		
		SetDestRadius(point, 5*TICRATE, point.storm_destradius/2)
		return
	end
	
	local nextpoint = point.destpoint
	local easetics = 35*TICRATE
	local frac = min((FU/easetics)*point.eased,FU)
	local x = ease.inoutquad(frac, point.startpoint.x, nextpoint.x)
	local y = ease.inoutquad(frac, point.startpoint.y, nextpoint.y)
	local z = ease.inoutquad(frac, point.startpoint.z, nextpoint.z)
	P_MoveOrigin(point,
		x,y,z
	)
	point.angle = FixedAngle(
		ease.inoutquad(frac,
			AngleFixed(point.startpoint.a),
			AngleFixed(nextpoint.a)
		)
	)
	point.eased = $+1
	
end