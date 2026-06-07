inherits globals;

trigger use {
	string trap_msg;
	if (hasObjVar(this, "TrapMessageRange")) {
		int range = getObjVar(this, "TrapMessageRange");
		if (hasObjVar(this, "TrapTheMessage")) {
			trap_msg = getObjVar(this, "TrapTheMessage");
		} else {
			trap_msg = "blah";
		}
		list trap_args = user, trap_msg;
		messageToRange(getLocation(this), range, "TRAP", trap_args);
	}
	if (hasObjVar(this, "isLocked")) {
		if (getDistanceInTiles(getLocation(this), getLocation(user)) < 0x04) {
			if (isEditing(user)) {
				barkTo(this, user, "It appears to be locked, but you open it with your godly powers.");
			} else {
				barkTo(this, user, "It appears to be locked.");
				return(0x00);
			}
		}
	}
	return(0x01);
}

trigger callback(0x25) {
	if (hasObjVar(this, "lockLevel")) {
		int lockLevel = getObjVar(this, "lockLevel");
		if (!hasObjVar(this, "isLocked")) {
			setObjVar(this, "isLocked", lockLevel);
		}
	}
	return(0x00);
}

trigger give {
	if (hasObjVar(this, "isLocked")) {
		bark(this, "It appears to be locked.");
		return(0x00);
	}
	return(0x01);
}
