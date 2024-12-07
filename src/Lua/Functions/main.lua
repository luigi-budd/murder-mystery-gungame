local function doAndInsert(file)
	MM[file] = dofile("Functions/Scripts/"..file)
end

doAndInsert("isMM")
doAndInsert("init")
doAndInsert("playerInit")
doAndInsert("assignRoles")
doAndInsert("canGameEnd")
doAndInsert("endGame")
doAndInsert("pingMurderers")
doAndInsert("playerWithGun")
doAndInsert("startVote")
doAndInsert("startTransition")
doAndInsert("startEndCamera")
doAndInsert("handleStorm")
doAndInsert("startShowdown")
doAndInsert("startOvertime")
doAndInsert("discordMessage")
doAndInsert("getpermlevel")
doAndInsert("pregame")
