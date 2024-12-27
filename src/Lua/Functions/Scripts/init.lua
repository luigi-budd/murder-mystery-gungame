local matchVars = MM.require "Variables/Data/Match"
local shallowCopy = MM.require "Libs/shallowCopy"
local randomPlayer = MM.require "Libs/getRandomPlayer"

return function(self, maploaded)
	if maploaded then
		if not MM:isMM() then return end
		
		MM_N.lastmap = gamemap
		MM.runHook("PostMapLoad")
		return
	end
	
	MM_N = shallowCopy(matchVars)
	if (MM_N.end_camera and MM_N.end_camera.valid) then
		P_RemoveMobj(MM_N.end_camera)
		MM_N.end_camera = nil
	end

	local count = 0
	for p in players.iterate do
		self:playerInit(p, true)
		count = $+1
	end

	MM_N.waiting_for_players = count < 2

	if not (self:isMM() and count >= 2) then return end

	if isserver then
		CV_Set(CV_FindVar("restrictskinchange"),0)
	end
	
	MM.runHook("Init")
end
