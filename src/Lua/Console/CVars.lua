rawset(_G,"CV_MM",{})

CV_MM.afkkickmode = CV_RegisterVar({
	name = "mm_afkmode",
	defaultvalue = "Kill",
	flags = CV_NETVAR,
	PossibleValue = {Off = 0, Kick = 1, Kill = 2}
})

CV_MM.debug = CV_RegisterVar({
	name = "mm_debug",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})
