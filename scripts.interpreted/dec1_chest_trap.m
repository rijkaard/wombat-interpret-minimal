inherits globals;

trigger use {
	list f_args;
	if (!hasObjVar(this, "unlocked")) {
		bark(this, "This chest seems to be locked.");
		return(0x00);
	}
	messageToRange(getLocation(this), 0x03, "chest_wall_fire_check", f_args);
	return(0x01);
}

trigger message("chest_unlocked") {
	int val;
	if (!hasObjVar(this, "unlocked")) {
		setObjVar(this, "unlocked", val);
	}
	return(0x00);
}

trigger message("chest_locked") {
	if (hasObjVar(this, "unlocked")) {
		removeObjVar(this, "unlocked");
	}
	return(0x00);
}
