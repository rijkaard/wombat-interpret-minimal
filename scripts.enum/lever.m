inherits sndfx;

trigger message("activate") {
	loc location = getLocation(this);
	int obj_type = getObjType(this);
	int newType;
	switch(obj_type) {
	case 0x108C
		sfx(location, 0x4B, 0x00);
		newType = 0x108E;
		break;
	case 0x1090
		sfx(location, 0x4A, 0x00);
		newType = 0x108F;
		break;
	case 0x1091
		sfx(location, 0x4A, 0x00);
		newType = 0x1092;
		break;
	case 0x1093
		sfx(location, 0x4B, 0x00);
		newType = 0x1095;
		break;
	default
		newType = obj_type;
		break;
	}
	setType(this, newType);
	processTriggerCmds(this, "a");
	return(0x00);
}

trigger message("deactivate") {
	loc location = getLocation(this);
	int obj_type = getObjType(this);
	int newType;
	switch(obj_type) {
	case 0x108E
		sfx(location, 0x4B, 0x00);
		newType = 0x108C;
		break;
	case 0x108F
		sfx(location, 0x4A, 0x00);
		newType = 0x1090;
		break;
	case 0x1092
		sfx(location, 0x4A, 0x00);
		newType = 0x1091;
		break;
	case 0x1095
		sfx(location, 0x4B, 0x00);
		newType = 0x1093;
		break;
	default
		newType = obj_type;
		break;
	}
	sfx(location, 0x51, 0x05);
	setType(this, newType);
	processTriggerCmds(this, "d");
	return(0x00);
}

trigger use {
	list args;
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x108C
	case 0x1090
	case 0x1091
	case 0x1093
		message(this, "activate", args);
		break;
	case 0x108E
	case 0x108F
	case 0x1092
	case 0x1095
		message(this, "deactivate", args);
		break;
	}
	return(0x00);
}
