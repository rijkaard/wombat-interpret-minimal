inherits globals;

trigger enterrange(0x03) {
	int obj_type = getObjType(this);
	string type_str = obj_type;
	bark(this, type_str);
	if (!(getObjType(this) == 0x11A6)) {
		setType(this, 0x11A6);
		callback(this, 0x03, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	getMobsInRange(mobs, getLocation(this), 0x05);
	if (numInList(mobs) == 0x00) {
		setType(this, 0x01);
	} else {
		callback(this, 0x03, 0x24);
	}
	return(0x00);
}
