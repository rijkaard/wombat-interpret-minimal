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
	try_refresh_decay_on_use(this, user, "house");
	if (hasObjVar(this, "isLocked")) {
		obj multi = getMultiSlaveId(this);
		int on_multi = isOnMulti(user, multi);
		int dir = getDirectionInternal(getLocation(user), getLocation(this));
		if ((on_multi) && (dir >= 0x03) && (dir <= 0x05)) {
			barkTo(user, user, "That is locked, but is usable from the inside.");
			return(0x01);
		}
		if (has_house_key(multi, user)) {
			barkTo(user, user, "You quickly unlock, use, and relock the door.");
			return(0x01);
		}
		if (isEditing(user)) {
			barkTo(user, user, "That is locked, but you open it with your godly powers.");
			return(0x01);
		}
		barkTo(user, user, "That is locked.");
		return(0x00);
	}
	return(0x01);
}
