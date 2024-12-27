local scripts = {}
local global_scripts = {}

function MM:addPlayerScript(file, global)
	local func = file

	if global then
		global_scripts[#global_scripts+1] = func
		return
	end
	scripts[#scripts+1] = func
end

addHook("PlayerThink", function(p)
	if not MM:isMM() then return end

	if not p.mm then
		MM:playerInit(p)
	end

	for _,script in ipairs(global_scripts) do
		script(p)
	end

	if not (p.mo and p.mo.valid and p.mo.health) then
		--Force a respawn
		if p.deadtimer >= 3*TICRATE
		and p.playerstate == PST_DEAD
			G_DoReborn(#p)
			p.deadtimer = 0
		end
		p.mm.oob_ticker = 0
		
		MM.runHook("DeadPlayerThink", p)
		
		return
	end

	p.spectator = p.mm.spectator
	if p.mm.spectator then
		MM.runHook("DeadPlayerThink", p)
		return
	end
	
	for _,script in ipairs(scripts) do
		script(p)
	end

	MM.runHook("PlayerThink", p)
	
end)

addHook("PlayerSpawn",function(p)
	MM:playerInit(p)
end)

addHook("MobjDeath",function(me,inf,sor)
	local p = me.player
	if not (p and p.valid) then return end
	if not (p.mm) then return end
	
	p.mm.hp = 0
	
end,MT_PLAYER)

MM:addPlayerScript(dofile("Hooks/Player/Scripts/Role Handler"))
MM:addPlayerScript(dofile("Hooks/Player/Scripts/Nerfs"))
MM:addPlayerScript(dofile("Hooks/Player/Scripts/Map Vote"), true)
MM:addPlayerScript(dofile("Hooks/Player/Scripts/AFKHandle"))
MM:addPlayerScript(dofile("Hooks/Player/Scripts/InteractHandler"))
