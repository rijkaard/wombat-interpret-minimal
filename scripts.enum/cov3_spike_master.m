inherits globals;

member int phase;

trigger creation {
	setType(this, 0x01);
	phase = 0x01;
	callback(this, 0x01, 0x24);
	return(0x00);
}

trigger objectloaded {
	callback(this, 0x01, 0x24);
	return(0x00);
}

trigger message("doAnimation") {
	list mobs;
	doLocAnimation(getLocation(this), 0x111C, 0x02, 0x10, 0x00, 0x00);
	getMobsInRange(mobs, getLocation(this), 0x01);
	for (int i = 0x00; i < numInList(mobs); i++) {
		loseHP(mobs[i], dice(0x14, 0x05));
	}
	return(0x00);
}

trigger callback(0x24) {
	list f_args;
	loc loc_b = 0x15C3, 0x0754, 0x07;
	loc loc_c = 0x15BF, 0x0754, 0x07;
	if (phase == 0x01) {
		messageToRange(getLocation(this), 0x02, "doAnimation", f_args);
	}
	if (phase == 0x02) {
		messageToRange(loc_b, 0x02, "doAnimation", f_args);
	}
	if (phase == 0x03) {
		messageToRange(loc_c, 0x02, "doAnimation", f_args);
	}
	if (phase == 0x04) {
		phase = 0x01;
	} else {
		phase = phase + 0x01;
	}
	callback(this, 0x01, 0x24);
	return(0x00);
}
