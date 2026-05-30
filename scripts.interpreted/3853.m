inherits spelskil;

trigger creation {
	return(0x00);
}

trigger use {
	setObjVar(this, "thrower", user);
	if (!hasObjVar(this, "countDown")) {
		setObjVar(this, "countDown", 0x04);
		callback(this, 0x01, 0x1B);
		systemMessage(user, "You should throw it now!");
	}
	targetLoc(user, this);
	return(0x00);
}

trigger targetobj {
	if (!check_visible_range(user, usedon, 0x0C)) {
		return(0x00);
	}
	setObjVar(this, "thrower", user);
	setInvisible(user, 0x00);
	if (isMobile(usedon)) {
		int ok = putObjContainer(this, user);
		doMissile_Mob2Mob(user, usedon, 0x0F0D, 0x07, 0x00, 0x00);
		setObjVar(this, "thrownAt", usedon);
		callback(this, 0x01, 0x19);
		return(0x00);
	}
	return(0x01);
}

trigger targetloc {
	setObjVar(this, "thrower", user);
	if (!canSeeLoc(user, place)) {
		systemMessage(user, "Target can not be seen.");
		return(0x00);
	}
	setInvisible(user, 0x00);
	int ok = putObjContainer(this, user);
	doMissile_Mob2Loc(user, place, 0x0F0D, 0x07, 0x00, 0x00);
	setObjVar(this, "thrownTo", place);
	callback(this, 0x01, 0x19);
	return(0x00);
}

trigger callback(0x19) {
	int ok;
	if (hasObjVar(this, "thrownTo")) {
		ok = teleport(this, getObjVar(this, "thrownTo"));
	} else {
		ok = teleport(this, getLocation(getObjVar(this, "thrownAt")));
	}
	return(0x00);
}

trigger callback(0x1B) {
	obj thrower = getObjVar(this, "thrower");
	if (thrower != NULL()) {
		setInvisible(thrower, 0x00);
	}
	int countDown = getObjVar(this, "countDown");
	countDown--;
	setObjVar(this, "countDown", countDown);
	if (countDown > 0x00) {
		bark(this, "" + countDown);
		callback(this, 0x01, 0x1B);
		return(0x00);
	}
	if (countDown == 0x00) {
		doLocAnimation(getLocation(this), 0x36B0, 0x0A, 0x09, 0x00, 0x00);
		shortCallback(this, 0x01, 0x1B);
		return(0x00);
	}
	sfx(getLocation(this), 0x0207, 0x00);
	list nearby;
	getMobsInRange(nearby, getLocation(this), 0x02);
	int origin_z = getZ(getLocation(this));
	int power = 0x19;
	if (hasObjVar(this, "power")) {
		power = getObjVar(this, "power");
	}
	int target_z;
	for (int i = 0x00; i < numInList(nearby); i++) {
		obj it = nearby[i];
		target_z = getZ(getLocation(it));
		if ((target_z >= origin_z) && (target_z <= (origin_z + 0x05))) {
			report_obj_aggression(thrower, it, 0x01, 0x00);
			int damage = random(power / 0x02, power);
			apply_typed_damage_clamped(thrower, it, damage, 0x04, 0x00);
		}
	}
	clearList(nearby);
	getObjectsInRangeOfType(nearby, getLocation(this), 0x02, 0x0F0D);
	for (int j = 0x00; j < numInList(nearby); j++) {
		obj item = nearby[j];
		target_z = getZ(getLocation(item));
		if ((target_z >= origin_z) && (target_z <= (origin_z + 0x05))) {
			setObjVar(item, "thrower", thrower);
			setObjVar(item, "countDown", 0x01);
			int delay = 0x01 + getDistanceInTiles(getLocation(this), getLocation(item));
			shortCallback(item, delay, 0x1B);
		}
	}
	deleteObject(this);
	return(0x00);
}
