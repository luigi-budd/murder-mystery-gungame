-- SAXAS MURDER MYSTERY

rawset(_G, "MM_N", {})
rawset(_G, "MM", {})
freeslot("TOL_SAXAMM")

G_AddGametype({
    name = "Murder Mystery",
    identifier = "SAXAMM",
    typeoflevel = TOL_SAXAMM,
    rules = GTR_FRIENDLYFIRE|GTR_SPAWNINVUL,
    intermissiontype = int_match,
    headerleftcolor = 222,
    headerrightcolor = 84,
	description = "Who murdered this guy? It's a mystery!"
})

for i = 0,1
	freeslot("sfx_mmste"..i)
	sfxinfo[sfx_mmste0 + i].caption = "\x89".."Entered storm!\x80"
end
for i = 0,2
	freeslot("sfx_mmstl"..i)
	sfxinfo[sfx_mmstl0 + i].caption = "\x89".."Exited storm\x80"
end
sfxinfo[freeslot("sfx_mmsmig")].caption = "\x89".."Storm migrating\x80"

freeslot("SPR_BGLS")
freeslot("S_MM_TEAMMATE1")
states[S_MM_TEAMMATE1] = {
	sprite = SPR_BGLS,
	frame = E|FF_SEMIBRIGHT,
	tics = 2
}
freeslot("S_MM_TEAMMATE2")
states[S_MM_TEAMMATE2] = {
	sprite = SPR_BGLS,
	frame = F|FF_SEMIBRIGHT,
	tics = 2
}

MM.require = dofile "Libs/require"
dofile "Libs/CustomHud.lua"

dofile "events"
dofile "Constants.lua"

dofile "Variables/main"
dofile "Functions/main"
dofile "Console/main"
dofile "Interactions/main"
dofile "Hooks/main"
dofile "Clues/main"
dofile "Items/main"
dofile "Cameras/run"

-- fool-proofing
-- basically if you reference a variable thats not in the local table
-- it corrects itself to get the variable in the network table
-- ofc, its faster to reference the correct tables
-- so dont use this too much
setmetatable(MM, {
	__index = function(self, key)
		if rawget(self, key) ~= nil then
			return rawget(self, key)
		end

		if MM_N[key] ~= nil then
			return MM_N[key]
		end
	end,
	__newindex = function(self, key, value)
		if MM_N[key] ~= nil then
			MM_N[key] = value
			return
		end

		rawset(self, key, value)
	end
})
