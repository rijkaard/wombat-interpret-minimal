inherits globals;

trigger creation {
	callback(this, 0x02, 0x3E);
	return(0x01);
}

trigger callback(0x3E) {
	list mobs;
	getMobsInRange(mobs, getLocation(this), 0x00);
	for (int i = 0x00; i < numInList(mobs); i++) {
		loseHP(mobs[i], dice(0x14, 0x05));
	}
	callback(this, 0x02, 0x3E);
	return(0x01);
}
