mobjinfo[freeslot "MT_MM_BULLET"] = {
	radius = 8*FU,
	height = 16*FU,
	spawnstate = S_MM_REVOLV_B,
	flags = MF_NOGRAVITY,
	deathstate = S_SMOKE1,
	speed = 32*FU
}

addHook("MobjThinker", MM.BulletThinker, MT_MM_BULLET)

addHook("MobjMoveCollide", MM.BulletCollide, MT_MM_BULLET)

addHook("MobjMoveBlocked", MM.BulletBlocked, MT_MM_BULLET)

return MT_MM_BULLET