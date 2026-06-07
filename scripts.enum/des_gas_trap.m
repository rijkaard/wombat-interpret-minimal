inherits sndfx;

member loc user_loc;

trigger creation {
	user_loc = getLocation(this);
	return(0x00);
}

trigger enterrange(0x02) {
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		doLocAnimation(user_loc, 0x11A7, 0x05, 0x17, 0x00, 0x00);
		callback(this, 0x01, 0x24);
		sfx(user_loc, 0x0230, 0x00);
	}
	removeObjVar(this, "working");
	return(0x01);
}

trigger enterrange(0x00) {
	int damage;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		doLocAnimation(user_loc, 0x11A7, 0x05, 0x17, 0x00, 0x00);
		sfx(user_loc, 0x0230, 0x00);
	}
	damage = random(0x02, 0x08);
	loseHP(target, damage);
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	int damage;
	getMobsInRange(mobs, user_loc, 0x03);
	if (numInList(mobs) == 0x00) {
		if (hasObjVar(this, "working")) {
			removeObjVar(this, "working");
		}
		return(0x00);
	}
	doLocAnimation(user_loc, 0x11A7, 0x05, 0x17, 0x00, 0x00);
	sfx(user_loc, 0x0230, 0x00);
	callback(this, 0x01, 0x24);
	clearList(mobs);
	getMobsInRange(mobs, user_loc, 0x02);
	if (numInList(mobs) > 0x00) {
		for (int i = 0x00; i < numInList(mobs); i++) {
			damage = random(0x02, 0x08);
			loseHP(mobs[i], damage);
		}
	}
	return(0x01);
}
