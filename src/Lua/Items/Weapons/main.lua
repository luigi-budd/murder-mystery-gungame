local path = "Items/Weapons/"

local spread = 10
local function BulletDies(mo)
	for i = 0, P_RandomRange(2,5)
		P_SpawnMobjFromMobj(mo,
			P_RandomRange(-spread,spread)*FU,
			P_RandomRange(-spread,spread)*FU,
			P_RandomRange(-spread,spread)*FU,
			MT_SMOKE
		)
	end
	
	local sfx = P_SpawnGhostMobj(mo)
	sfx.flags2 = $|MF2_DONTDRAW
	sfx.fuse = TICRATE
	S_StartSound(sfx,sfx_turhit)
end

MM.BulletThinker = function(mo)
	if not mo.valid then return end
	
	local speed = mo.bullspeed or mo.origin.bulletspeed
	mo.momx = FixedMul(speed*cos(mo.angle), cos(mo.aiming))
	mo.momy = FixedMul(speed*sin(mo.angle), cos(mo.aiming))
	mo.momz = speed*sin(mo.aiming)
	mo.bullframe = A
	
	for i = 1,256 do
		if not (mo and mo.valid) then
			return
		end
		
		--drop off
		if (i >= 192)
			if mo.origin.state ~= S_MM_LUGER
				mo.momz = $ - (mo.scale/3)*P_MobjFlip(mo)
			else
				mo.momz = $ - (mo.scale/2)*P_MobjFlip(mo)
			end
		end
		if (i >= 64)
		and mo.origin.state ~= S_MM_LUGER
			mo.momz = $ - (mo.scale/2)*P_MobjFlip(mo)
		end

		if mo.z <= mo.floorz
		or mo.z+mo.height >= mo.ceilingz then
			BulletDies(mo)
			P_RemoveMobj(mo)
			return
		end

		if i % 3 == 0 then
			local ghs = P_SpawnGhostMobj(mo)
			ghs.frame = (mo.bullframe % E)|FF_SEMIBRIGHT
			ghs.fuse = $*2
			mo.bullframe = $ + 1
		end
		
		P_XYMovement(mo)
		
		if not (mo and mo.valid) then
			return
		end
		
		P_ZMovement(mo)
	end

	if mo and mo.valid then
		BulletDies(mo)
		P_RemoveMobj(mo)
	end
end

MM.BulletCollide = function(ring,pmo)
	if not (ring and ring.valid) then return end
	if (pmo == ring.target) then return end
	
	if ring.z > pmo.z+pmo.height then return end
	if pmo.z > ring.z+ring.height then return end
	
	if (pmo.flags & MF_SHOOTABLE)
	and not (pmo.player and pmo.player.valid)
		P_DamageMobj(pmo, ring, (ring.target and ring.target.valid) and ring.target or ring, 2)
		BulletDies(ring)
		P_RemoveMobj(ring)
		return
	end
	
	if not (pmo and pmo.valid and pmo.player and pmo.health and pmo.player.mm) then return end
	
	local p = pmo.player
	p.mm.hp = $ - ring.damage
	
	if (p.mm.hp <= 0)
		P_KillMobj(pmo, ring, (ring.target and ring.target.valid) and ring.target or ring, 999)
		p.mm.hp = 0
	end
	
	BulletDies(ring)
	P_RemoveMobj(ring)
end
MM.BulletBlocked = function(ring)
	if not (ring and ring.valid) then return end
	
	BulletDies(ring)
	P_RemoveMobj(ring)
end  


MM:CreateItem(dofile(path.."Revolver/def"))
MM:CreateItem(dofile(path.."Gun/def"))
MM:CreateItem(dofile(path.."Luger/def"))
MM:CreateItem(dofile(path.."Knife/def"))
MM:CreateItem(dofile(path.."Burger/def"))
MM:CreateItem(dofile(path.."Uno_Reverse/def"))
