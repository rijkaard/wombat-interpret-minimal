inherits globals;

trigger creation {
	int obj_type = getObjType(this);
	setObjVar(this, "myObjType", obj_type);
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x02) {
	if (isDead(target)) {
		return(0x01);
	}
	int obj_type = getObjVar(this, "myObjType");
	if (getObjType(this) != obj_type) {
		setType(this, obj_type);
		setObjVar(this, "working", 0x01);
		callback(this, 0x03, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	clearList(mobs);
	getMobsInRange(mobs, getLocation(this), 0x03);
	if (numInList(mobs) == 0x00) {
		setType(this, 0x01);
		removeObjVar(this, "working");
		return(0x00);
	}
	callback(this, 0x03, 0x24);
	return(0x00);
}
