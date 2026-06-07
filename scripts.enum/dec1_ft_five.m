inherits sndfx;

trigger enterrange(0x00) {
	list f_args;
	sfx(getLocation(this), 0x0122, 0x00);
	messageToRange(getLocation(this), 0x05, "saws_on", f_args);
	doLocAnimation(getLocation(this), 0x1123, 0x02, 0x08, 0x00, 0x00);
	return(0x01);
}
