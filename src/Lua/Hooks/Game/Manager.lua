local randomPlayer = MM.require "Libs/getRandomPlayer"

local funcs = {gameover = {}, ongoing = {}, waiting = {}, global = {}}
local function addScript(name)
	local func, type = dofile("Hooks/Game/Scripts/"..name)
	table.insert(funcs[type or "ongoing"], func)
end

addHook("PreThinkFrame", function()
	if not MM:isMM() then return end
	if not MM.gameover then return end

	for p in players.iterate do
		if (p and p.mm) then
			p.mm.lastside = p.mm.sidemove or 0
			p.mm.lastforward = p.mm.forwardmove or 0
	
			p.mm.forwardmove = p.cmd.forwardmove
			p.mm.sidemove = p.cmd.sidemove
	
			p.mm.buttons = p.cmd.buttons
		end
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = 0
		p.powers[pw_underwater] = underwatertics*2
		p.powers[pw_spacetime] = spacetimetics*2
	end
end)

addHook("ThinkFrame", function()
	if not MM:isMM() then return end

	for k,func in pairs(funcs.global) do
		func()
	end

	if MM_N.gameover then
		for k,func in pairs(funcs.gameover) do
			func()
		end
		
		return
	end

	if MM_N.waiting_for_players then
		for k,func in pairs(funcs.waiting) do
			func()
		end
		return --ends the function early
	end
	
	for k,func in pairs(funcs.ongoing) do
		func()
	end
end)

addScript "Waiting"
addScript "Game Over"
addScript "Theme Transition"

addScript "Overtime"
--addScript "Game End"
// addScript "Restrict"
