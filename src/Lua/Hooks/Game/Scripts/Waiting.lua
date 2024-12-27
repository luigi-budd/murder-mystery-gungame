local MUSIC = false

return function()
	if CV_MM.debug.value 
		MM_N.waiting_for_players = false
		return
	end
	
	local playersIn = 0
	for p in players.iterate do
		playersIn = $+1
	end

	if isserver
	and CV_FindVar("restrictskinchange").value
		CV_Set(CV_FindVar("restrictskinchange"),0)
	end

	MM_N.found_player = playersIn >= 2

	if not MM_N.found_player then
		MM_N.waiting_start_time = 1
		if MUSIC then
			S_ChangeMusic(mapmusname, true)
			MUSIC = false
		end
		return
	end

	MM_N.waiting_start_time = max(0, $-1)

	if not (MM_N.waiting_start_time) then
		COM_BufInsertText(server, "map "..G_BuildMapName(gamemap).." -f")
		MM_N.waiting_for_players = false
	end
end, "waiting"