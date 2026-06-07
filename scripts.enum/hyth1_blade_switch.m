inherits globals;

trigger use {
	list f_args;
	int obj_type = getObjType(this);
	loc trapLocation = 0x1764, 0x20, 0x16;
	switch(obj_type) {
	case 0x1093
		messageToRange(trapLocation, 0x01, "disarm", f_args);
		callback(this, 0x3C, 0x24);
		break;
	case 0x1095
		messageToRange(trapLocation, 0x01, "reset", f_args);
		break;
	default
		break;
	}
	return(0x01);
}

trigger callback(0x24) {
	list f_args;
	loc trapLocation = 0x1764, 0x20, 0x16;
	int obj_type = getObjType(this);
	if (obj_type == 0x1095) {
		setType(this, 0x1093);
		messageToRange(trapLocation, 0x01, "reset", f_args);
	}
	return(0x00);
}
