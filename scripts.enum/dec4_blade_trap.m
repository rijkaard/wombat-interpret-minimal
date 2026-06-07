inherits globals;

trigger message("blades") {
	list mobs;
	getMobsInRange(mobs, getLocation(this), 0x01);
	doLocAnimation(getLocation(this), 0x11AD, 0x02, 0x0A, 0x00, 0x00);
	if (!numInList(mobs) == 0x00) {
		for (int i = 0x00; i < numInList(mobs); i++) {
			loseHP(mobs[i], dice(0x0A, 0x05));
		}
	}
	return(0x00);
}
