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

trigger use {
	int current_type = getObjType(this);
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		int toggled_type = get_toggled_type(getObjType(this));
		setType(this, toggled_type);
		callback(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	int toggle_id = get_toggled_type(getObjType(this));
	setType(this, toggle_id);
	return(0x00);
}
