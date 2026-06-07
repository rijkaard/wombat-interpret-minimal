inherits globals;

function int get_toggled_type(int obj_type) {
	int toggled_type;
	if (obj_type == 0x1092) {
		toggled_type = 0x1091;
	}
	if (obj_type == 0x1091) {
		toggled_type = 0x1092;
	}
	if (obj_type == 0x108F) {
		toggled_type = 0x1090;
	}
	if (obj_type == 0x1090) {
		toggled_type = 0x108F;
	}
	return(toggled_type);
}

trigger message("showoff") {
	int current_type = getObjType(this);
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		int new_type = get_toggled_type(getObjType(this));
		setType(this, new_type);
		callback(this, 0x05, 0x25);
	}
	return(0x01);
}

trigger callback(0x25) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	int new_state = get_toggled_type(getObjType(this));
	setType(this, new_state);
	return(0x00);
}
