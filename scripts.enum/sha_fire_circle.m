trigger message("poof") {
	list mobs;
	obj mob;
	loc location = getLocation(this);
	doLocAnimation(location, 0x3709, 0x01, 0x0100, 0x00, 0x00);
	getMobsInRange(mobs, location, 0x01);
	if (numInList(mobs) != 0x00) {
		for (int i = 0x00; i < numInList(mobs); i++) {
			mob = mobs[i];
			loseHP(mob, dice(0x08, 0x08));
		}
	}
	return(0x00);
}
