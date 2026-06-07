inherits globals;

trigger use {
	list f_args;
	if (random(0x00, 0x0A) > 0x05) {
		messageToRange(getLocation(this), 0x03, "blades", f_args);
	}
	return(0x01);
}
