inherits multistuff;

member int placement_z_offset;

function int get_multi_type_id(int house_type, int state) {
	return(0x64 + (house_type * 0x02) + state);
}

function int set_house_state(obj house, int state) {
	string msg;
	int myhousetype = getObjVar(house, "myhousetype");
	int gump_id = get_multi_type_id(myhousetype, state);
	int result = recycleMulti(house, gump_id);
	if (result > 0x00) {
		setObjVar(house, "myhousestate", state);
	}
	return(result);
}

function obj place_house(int house_type, loc place) {
	placement_z_offset = (0x00 - 0x06);
	int gump_id = get_multi_type_id(house_type, 0x00);
	if (areMobilesInMultiArea(gump_id, place)) {
		placement_z_offset = (0x00 - 0x09);
		return(NULL());
	}
	obj house = makeMultiInstCheck(place, gump_id, 0x08, (0x00 - 0x03), placement_z_offset, 0x00, 0x00, 0x00);
	if (house != NULL()) {
		setObjVar(house, "myhousetype", house_type);
		setObjVar(house, "myhousestate", 0x00);
		string time_str;
		getCurrentTimeStr(time_str);
		setObjVar(house, "creationtime", time_str);
	}
	return(house);
}

function int change_house_state(obj house, int new_state) {
	int current_state = getObjVar(house, "myhousestate");
	if (new_state != current_state) {
		return(set_house_state(house, new_state));
	}
	return(0x00);
}

function int get_house_base_value(int house_type) {
	int gump_id = get_multi_type_id(house_type, 0x00);
	return(getNumInMultiType(gump_id) * 0xC8);
}

function loc adjust_placement_loc(int house_type, loc place) {
	loc min_extent;
	loc max_extent;
	int gump_id = get_multi_type_id(house_type, 0x00);
	if (getMultiExtents(gump_id, min_extent, max_extent)) {
		setY(place, getY(place) - getY(max_extent));
	}
	return(place);
}

function void mark_for_multi_delete(obj it) {
	setObjVar(it, "multiDelete", 0x01);
	return();
}
