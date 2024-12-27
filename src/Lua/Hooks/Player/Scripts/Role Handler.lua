return function(p) -- Role handler
	if not MM:pregame()
	and not p.mm.got_weapon
		MM:GiveItem(p, "revolver")
		MM:GiveItem(p, "knife")
		p.mm.got_weapon = true
	end
end