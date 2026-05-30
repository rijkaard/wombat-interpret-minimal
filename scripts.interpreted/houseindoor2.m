inherits housestuff;

trigger creation {
	int lock_level = set_lock_level(this, 0x0100, 0x0100);
	obj house = getMultiSlaveId(this);
	setObjVar(house, "myhousedoor", this);
	list doors;
	if (hasObjVar(house, "myhousedoors")) {
		getObjListVar(doors, house, "myhousedoors");
	}
	appendToList(doors, this);
	setObjVar(house, "myhousedoors", doors);
	return(0x01);
}

trigger use {
	if (hasObjVar(this, "isLocked")) {
		int on_multi = isOnMulti(user, getMultiSlaveId(this));
		int dir = getDirectionInternal(getLocation(user), getLocation(this));
		if ((on_multi) && (dir >= 0x03) && (dir <= 0x05)) {
			barkTo(user, user, "That is locked, but is usable from the inside.");
			return(0x01);
		}
		barkTo(user, user, "That is locked.");
		return(0x00);
	}
	return(0x01);
}
