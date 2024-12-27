local weapon = {}

local MAX_COOLDOWN = 3*TICRATE
local MAX_ANIM = TICRATE

weapon.id = "revolver"
weapon.category = "Weapon"
weapon.display_name = "Revolver"
weapon.display_icon = "MM_REVOLVER"
weapon.state = dofile "Items/Weapons/Revolver/freeslot"
weapon.timeleft = -1
weapon.hit_time = TICRATE/3
weapon.animation_time = TICRATE/2
weapon.cooldown_time = TICRATE
weapon.range = FU*2
weapon.position = {
	x = FU,
	y = 0,
	z = 0
}
weapon.animation_position = {
	x = FU,
	y = -FU/2,
	z = 0
}
weapon.stick = true
weapon.animation = true
weapon.damage = false
weapon.weaponize = true
weapon.droppable = true
weapon.shootable = true
weapon.shootmobj = dofile("Items/Weapons/Revolver/bullet")
weapon.pickupsfx = sfx_gnpick
weapon.equipsfx = sfx_gequip
weapon.attacksfx = sfx_revlsh
weapon.allowdropmobj = true
weapon.bulletdamage = 50

return weapon