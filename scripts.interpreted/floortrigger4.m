inherits sndfx;

trigger enterrange(0x00) {
	loc chest_loc = 0x1431, 0x0257, 0x00;
	list f_args;
	sfx(getLocation(this), 0x0122, 0x00);
	messageToRange(chest_loc, 0x01, "chest_unlocked", f_args);
	messageToRange(getLocation(this), 0x03, "wall_trap_check", f_args);
	callback(this, 0x02, 0x01);
	setType(this, 0x1123);
	callback(this, 0x1E, 0x02);
	return(0x01);
}

trigger callback(0x01) {
	setType(this, 0x1122);
	return(0x00);
}

trigger callback(0x02) {
	loc msg_loc = 0x1431, 0x0257, 0x00;
	list f_args;
	messageToRange(msg_loc, 0x01, "chest_locked", f_args);
	return(0x00);
}
