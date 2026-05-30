inherits sndfx;

member obj range_intruder;

trigger enterrange(0x00) {
	if (isDead(target)) {
		return(0x01);
	}
	range_intruder = target;
	list args;
	message(this, "activate", args);
	return(0x01);
}

trigger message("activate") {
	int obj_type = getObjType(this);
	loc location = getLocation(this);
	if (!hasObjVar(this, "disarmed")) {
		switch(obj_type) {
		case 0x10F5
			doLocAnimation(location, 0x10F6, 0x09, 0x10, 0x00, 0x00);
			break;
		case 0x10FC
			doLocAnimation(location, 0x10FD, 0x09, 0x10, 0x00, 0x00);
			break;
		case 0x110F
			doLocAnimation(location, 0x1110, 0x09, 0x10, 0x00, 0x00);
			break;
		default
			break;
		}
		sfx(location, 0x54, 0x05);
		shortCallback(this, 0x02, 0x2F);
	}
	return(0x01);
}

trigger callback(0x2F) {
	loc location = getLocation(this);
	list mobs;
	getMobsInRange(mobs, location, 0x01);
	int count = numInList(mobs);
	for (int i = 0x00; i < count; i++) {
		int dmg = dice(0x03, 0x0F);
		obj victim = mobs[i];
		sfx(location, 0x42, 0x05);
		loseHP(victim, dmg);
	}
	return(0x00);
}
