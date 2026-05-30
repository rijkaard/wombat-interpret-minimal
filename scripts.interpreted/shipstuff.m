inherits multistuff;

member int multi_check_flags;

member int initialized;

member int placement_elev;

member int did_normal_move;

trigger creation {
	if (!initialized) {
		multi_check_flags = 0x03;
		initialized = 0x01;
	}
	return(0x01);
}

function void attach_naked_hack_to_crew(obj ship) {
	list players;
	getPlayersOnMulti(players, ship);
	int num = numInList(players);
	for (int i = 0x00; i < num; i++) {
		obj player = players[i];
		attachScript(player, "shipnakedhack");
	}
	return();
}

function int check_move_steps(obj ship, int dir, int steps) {
	loc location;
	int result;
	location = getLocation(ship);
	for (int i = steps; i > 0x00; i--) {
		moveDir(location, dir);
	}
	result = moveMultiCheck(ship, location, multi_check_flags);
	if (result <= 0x00) {
		int reverse_dir = (dir + 0x04) % 0x08;
		while ((result <= 0x00) && (steps > 0x01)) {
			steps--;
			moveDir(location, reverse_dir);
			result = moveMultiCheck(ship, location, multi_check_flags);
		}
	}
	return(result);
}

function int resolve_move_dir(obj ship, int rel_dir) {
	int ship_dir = getObjVar(ship, "myshipdir");
	return((((ship_dir * 0x02) + rel_dir) % 0x08));
}

function int move_ship_relative(obj ship, int direction_offset, int move_distance) {
	return(check_move_steps(ship, resolve_move_dir(ship, direction_offset), move_distance));
}

function int calc_multi_index(int myshiptype, int dir) {
	return(0x00 + (myshiptype * 0x04) + (dir * 0x01));
}

function int rotate_ship(obj ship, int dir, int rot_type) {
	string name;
	int myshiptype = getObjVar(ship, "myshiptype");
	int multi_idx = 0x00 + (myshiptype * 0x04) + (dir * 0x01);
	int result = recycleMultiCheckRotate(ship, multi_idx, multi_check_flags, rot_type);
	if (result > 0x00) {
		setObjVar(ship, "myshipdir", dir);
	}
	return(result);
}

function obj try_place_ship(int ship_type, int dir, loc place) {
	placement_elev = (0x00 - 0x06);
	int z_offset = 0x00;
	z_offset--;
	int multi_idx = 0x00 + (ship_type * 0x04) + (dir * 0x01);
	obj ship = NULL();
	if (areMobilesInMultiArea(multi_idx, place)) {
		placement_elev = (0x00 - 0x09);
		return(NULL());
	}
	ship = makeMultiInstCheck(place, multi_idx, multi_check_flags, 0x00, placement_elev, 0x00, z_offset, z_offset);
	return(ship);
}

function obj create_ship_at(int ship_size, loc place) {
	obj ship;
	int initial_dir = 0x05;
	ship = try_place_ship(ship_size, 0x00, place);
	if (ship != NULL()) {
		initial_dir = 0x00;
	}
	if (initial_dir != 0x05) {
		setObjVar(ship, "myshipdir", initial_dir);
		setObjVar(ship, "myshiptype", ship_size);
		string creation_time;
		getCurrentTimeStr(creation_time);
		setObjVar(ship, "creationtime", creation_time);
	}
	return(ship);
}

function int has_ship_command(obj tillerman) {
	return(hasObjVar(tillerman, "shipcommand"));
}

function int is_ship_moving(obj ship) {
	obj tillerman = getObjVar(ship, "myshiptillerman");
	if (tillerman == NULL()) {
		return(0x00);
	}
	return(has_ship_command(tillerman));
}

function int move_ship_or_map_switch(obj ship, int direction_offset, obj tillerman) {
	int direction = resolve_move_dir(ship, direction_offset);
	int multi_type = getMultiType(ship);
	loc min_bounds;
	loc max_bounds;
	int extents_result = getMultiExtents(multi_type, min_bounds, max_bounds);
	int width = getX(max_bounds) - getX(min_bounds) + 0x01;
	int height = getY(max_bounds) - getY(min_bounds) + 0x01;
	loc dest = getLocation(ship);
	int x_steps = 0x00;
	int y_steps = 0x00;
	switch(direction) {
	case 0x00
	case 0x04
		y_steps = height;
		break;
	case 0x01
	case 0x03
	case 0x05
	case 0x07
		x_steps = width;
		y_steps = height;
		break;
	case 0x02
	case 0x06
		x_steps = width;
		break;
	default
		x_steps = width;
		y_steps = height;
		break;
	}
	int x_dir = 0x00;
	int y_dir = 0x00;
	switch(direction) {
	case 0x00
		y_dir = 0x00;
		break;
	case 0x01
		x_dir = 0x02;
		y_dir = 0x00;
		break;
	case 0x02
		x_dir = 0x02;
		break;
	case 0x03
		x_dir = 0x02;
		y_dir = 0x04;
		break;
	case 0x04
		y_dir = 0x04;
		break;
	case 0x05
		x_dir = 0x06;
		y_dir = 0x04;
		break;
	case 0x06
		x_dir = 0x06;
		break;
	case 0x07
		x_dir = 0x06;
		y_dir = 0x00;
		break;
	default
		break;
	}
	for (; x_steps > 0x00; x_steps--) {
		moveDir(dest, x_dir);
	}
	for (; y_steps > 0x00; y_steps--) {
		moveDir(dest, y_dir);
	}
	if (isInMap(dest)) {
		if (hasObjVar(tillerman, "oldshipcommand")) {
			removeObjVar(tillerman, "oldshipcommand");
		}
		int move_result = moveMultiCheck(ship, dest, multi_check_flags);
		did_normal_move = 0x01;
		return(move_result);
	}
	attach_naked_hack_to_crew(ship);
	return(moveMultiMapSwitch(ship, dest, multi_check_flags));
}

function int calc_ship_value(int ship_type) {
	int multi_type_idx = 0x00 + (ship_type * 0x04);
	return(getNumInMultiType(multi_type_idx) * 0xDC);
}
