inherits globals;

trigger message("vanish") {
	int obj_type = getObjType(this);
	if (obj_type == 0x01) {
		return(0x00);
	} else {
		setObjVar(this, "vanished", obj_type);
		setType(this, 0x01);
		callback(this, 0x1E, 0x24);
	}
	return(0x00);
}

trigger callback(0x24) {
	int saved_type = getObjVar(this, "vanished");
	setType(this, saved_type);
	return(0x00);
}
