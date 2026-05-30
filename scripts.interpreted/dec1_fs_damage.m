inherits globals;

trigger creation {
	callback(this, 0x01, 0x3D);
	return(0x01);
}

trigger objectloaded {
	callback(this, 0x01, 0x3D);
	return(0x01);
}

trigger callback(0x3D) {
	list mobs;
	if (!hasObjVar(this, "disarmed")) {
		getMobsInRange(mobs, getLocation(this), 0x00);
		for (int i = 0x00; i < numInList(mobs); i++) {
			loseHP(mobs[i], dice(0x14, 0x05));
		}
	}
	callback(this, 0x01, 0x3D);
	return(0x01);
}
