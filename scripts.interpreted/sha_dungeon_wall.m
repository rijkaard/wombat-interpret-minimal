inherits globals;

trigger enterrange(0x01) {
	int obj_type = getObjType(this);
	if (obj_type == 0x01) {
		return(0x01);
	} else {
		setObjVar(this, "vanished", obj_type);
		setType(this, 0x01);
		callback(this, 0x1E, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	int vanished_type = getObjVar(this, "vanished");
	setType(this, vanished_type);
	return(0x00);
}
