inherits globals;

member int was_jailed;

trigger creation {
	callback(this, 0x0708, 0x74);
	return(0x01);
}

function int is_in_jail(obj mobile) {
	loc jail_loc = 0x14AB, 0x0496, 0x00;
	loc pos = getLocation(mobile);
	if (getDistanceInTiles(jail_loc, pos) < 0x32) {
		return(0x01);
	}
	return(0x00);
}

function void release_from_jail(obj mobile) {
	loc dest = 0x05E0, 0x05F9, 0x28;
	if (hasObjVar(mobile, "UnJailLoc")) {
		dest = getObjVar(mobile, "UnJailLoc");
		removeObjVar(mobile, "UnJailLoc");
	}
	int ok = teleport(mobile, dest);
	return();
}

trigger callback(0x74) {
	shortcallback(this, 0x01, 0x75);
	if (is_in_jail(this)) {
		was_jailed = 0x01;
		release_from_jail(this);
	}
	return(0x01);
}

trigger callback(0x75) {
	if (was_jailed) {
		systemMessage(this, "You have been released from jail");
	}
	if (hasObjVar(this, "UnJailLoc")) {
		removeObjVar(this, "UnJailLoc");
	}
	if (hasObjVar(this, "NoLogOut")) {
		removeObjVar(this, "NoLogOut");
	}
	detachScript(this, "jailcheck");
	return(0x01);
}
