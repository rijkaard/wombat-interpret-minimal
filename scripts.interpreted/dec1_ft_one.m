inherits sndfx;

trigger creation {
	setType(this, 0x1122);
	return(0x00);
}

trigger enterrange(0x00) {
	loc range_loc = 0x1430, 0x0257, 0x00;
	list f_args;
	sfx(getLocation(this), 0x0122, 0x00);
	messageToRange(range_loc, 0x01, "wall_trap_disarm", f_args);
	callback(this, 0x02, 0x23);
	setType(this, 0x1123);
	callback(this, 0x3C, 0x24);
	return(0x01);
}

trigger callback(0x23) {
	setType(this, 0x1122);
	return(0x00);
}

trigger callback(0x24) {
	loc trap_loc = 0x1430, 0x0257, 0x00;
	list f_args;
	messageToRange(trap_loc, 0x01, "wall_trap_reload", f_args);
	return(0x00);
}
