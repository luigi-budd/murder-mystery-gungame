return {
	spectator = false,
	got_weapon = false,

	joinedmidgame = false,

	selected_map = false,
	cur_map = 1,

	forwardmove = 0,
	sidemove = 0,
	lastforward = 0,
	lastside = 0,
	buttons = 0,
	
	afktimer = 0,
	afkhelpers = {
		timedout = false,
		timeuntilreset = 0,
		lastangle = 0,
		lastaiming = 0,
		keepalive = false,
	},
	
	interact = {
		--the actual points of interests
		points = {},
		interacted = false,
	},
	
	hp = MM_PLAYER_MAXHEALTH,
	inventory = {
		items = {},
		hidden = false,
		cur_sel = 1,
		count = 4
	}
}