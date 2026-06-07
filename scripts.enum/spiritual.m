inherits sndfx;

member obj teleport_target;

trigger speech("Om Om Om") {
	list mobs;
	setObjVar(speaker, "spokeMantra", 0x01);
	getMobsAt(mobs, getLocation(this));
	for (int i = 0x00; i < numInList(mobs); i++) {
		if (hasObjVar(mobs[i], "spokeMantra")) {
			removeObjVar(mobs[i], "spokeMantra");
			teleport_target = mobs[i];
			callback(this, 0x01, 0x2F);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeMantra");
	}
	return(0x00);
}

trigger speech("om om om") {
	list mobs_at_loc;
	setObjVar(speaker, "spokeMantra", 0x01);
	getMobsAt(mobs_at_loc, getLocation(this));
	for (int i = 0x00; i < numInList(mobs_at_loc); i++) {
		if (hasObjVar(mobs_at_loc[i], "spokeMantra")) {
			removeObjVar(mobs_at_loc[i], "spokeMantra");
			teleport_target = mobs_at_loc[i];
			callback(this, 0x01, 0x2F);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeMantra");
	}
	return(0x00);
}

trigger speech("OM OM OM") {
	list mobs;
	setObjVar(speaker, "spokeMantra", 0x01);
	getMobsAt(mobs, getLocation(this));
	for (int i = 0x00; i < numInList(mobs); i++) {
		if (hasObjVar(mobs[i], "spokeMantra")) {
			removeObjVar(mobs[i], "spokeMantra");
			teleport_target = mobs[i];
			callback(this, 0x01, 0x2F);
		}
	}
	if (isValid(speaker)) {
		removeObjVar(speaker, "spokeMantra");
	}
	return(0x00);
}

trigger callback(0x2F) {
	loc destination = getObjVar(this, "dest");
	if (teleport(teleport_target, destination)) {
		doLocAnimation(getLocation(this), 0x3728, 0x0A, 0x0A, 0x00, 0x00);
		doLocAnimation(destination, 0x3728, 0x0A, 0x0A, 0x00, 0x00);
		sfx(destination, 0x01FE, 0x00);
	} else {
		bark(teleport_target, "The spirits are not intune to your desires as of yet.");
	}
	return(0x00);
}
