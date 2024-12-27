return function()
	--starting countdown
	if (leveltime >= (MM_N.pregame_time - 4*TICRATE - 1) and leveltime <= MM_N.pregame_time - TICRATE)
	and (leveltime % TICRATE == 0)
		S_StartSound(nil,leveltime == MM_N.pregame_time - TICRATE and sfx_s3kad or sfx_s3ka7)
	end
	
	-- time management
	MM_N.time = max(0, $-1)
	if not (MM_N.time)
		MM:endGame()
	end

end