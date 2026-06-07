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
	int cur_type = getObjType(this);
	int toggle_id = get_toggled_type(getObjType(this));
	setType(this, toggle_id);
	return(0x01);
}
