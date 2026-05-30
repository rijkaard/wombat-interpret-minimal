inherits globals;

member int original_tile_type;

trigger creation {
	original_tile_type = getObjType(this);
	setObjVar(this, "statueTileNumberFlag", original_tile_type);
	return(0x00);
}

trigger leaverange(0x01) {
	if (isDead(target)) {
		return(0x01);
	}
	int triggered = 0x00;
	int damage;
	list mobs;
	if (getObjType(this) == 0x1508) {
		setType(this, 0x1509);
		triggered = 0x01;
	}
	if (getObjType(this) == 0x1512) {
		setType(this, 0x1513);
		triggered = 0x01;
	}
	if (getObjType(this) == 0x151A) {
		setType(this, 0x151B)triggered = 0x01;
	}
	if (getObjType(this) == 0x151C) {
		setType(this, 0x151D);
		triggered = 0x01;
	}
	if (triggered == 0x01) {
		getMobsInRange(mobs, getLocation(this), 0x00);
		if (!numInList(mobs) == 0x00) {
			damage = dice(0x0A, 0x0A);
			for (int i = 0x00; i < numInList(mobs); i++) {
				if (random(0x00, 0x64) > getDexterity(mobs[i])) {
					damage = damage * 0x02;
				}
				loseHP(mobs[i], damage);
			}
		}
		if (!hasObjVar(this, "statueDown")) {
			setObjVar(this, "statueDown", 0x01);
			callback(this, 0x05, 0x24);
		}
		loseHP(this, damage);
	}
	return(0x01);
}

trigger callback(0x24) {
	list players;
	getPlayersInRange(players, getLocation(this), 0x1E);
	if (!numInList(players) == 0x00) {
		callback(this, 0x05, 0x24);
	} else {
		int tile_type = getObjVar(this, "statueTileNumberFlag");
		setType(this, tile_type);
	}
	return(0x00);
}
