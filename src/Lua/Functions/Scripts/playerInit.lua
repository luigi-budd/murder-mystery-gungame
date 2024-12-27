local shallowCopy = MM.require "Libs/shallowCopy"
local playerVars = MM.require "Variables/Data/Player"

return function(self, p, mapchange)
	p.mm = shallowCopy(playerVars)
end