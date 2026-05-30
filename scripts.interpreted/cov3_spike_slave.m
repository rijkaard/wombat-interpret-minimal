inherits globals;

member int phase;

trigger creation {
	setType(this, 0x01);
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
