inherits shipstuff;

member int nav_point_index;

member obj nav_map;

member int ship_width;

member int ship_height;

member int ship_max_dimension;

member int callback_active;

member int anchor_down;

forward int exec_ship_command(obj tillerman, int command, int continuous);

forward void set_nav_point(int ship_id);

forward int get_nav_point();

function int has_ship_key(obj house, obj mobile) {
	if (!hasObjVar(house, "myhousedoors")) {
		return(0x00);
	}
	list doors;
	getObjListVar(doors, house, "myhousedoors");
	if (numInList(doors) < 0x01) {
		return(0x00);
	}
	obj door = doors[0x00];
	obj key = mobileHasObjWithListObjOfObj(mobile, "whatIUnlock", door);
	if (key == NULL()) {
		return(0x00);
	}
	return(0x01);
}

function int is_plank_deployed(obj ship) {
	int plank_status = getObjVar(ship, "shiprightplank");
	if (plank_status == 0x01) {
		return(0x01);
	}
	plank_status = getObjVar(ship, "shipleftplank");
	if (plank_status == 0x01) {
		return(0x01);
	}
	return(0x00);
}

function void clear_queued_command(obj tillerman) {
	if (hasObjVar(tillerman, "shipqueuedcommand")) {
		removeObjVar(tillerman, "shipqueuedcommand");
	}
	return;
}

function int get_direction_delta(int target_dir, int ship_dir) {
	int delta = target_dir - ship_dir;
	if (delta > 0x04) {
		delta = delta + (0x00 - 0x08);
	} else {
		if (delta < (0x00 - 0x04)) {
			delta = delta + 0x08;
		}
	}
	return(delta);
}

function void update_ship_dimensions(obj ship) {
	int multi_type = getMultiType(ship);
	loc min_loc;
	loc max_loc;
	int result = getMultiExtents(multi_type, min_loc, max_loc);
	ship_width = getX(max_loc) - getX(min_loc) + 0x01;
	ship_height = getY(max_loc) - getY(min_loc) + 0x01;
	ship_max_dimension = ship_width;
	if (ship_height > ship_max_dimension) {
		ship_max_dimension = ship_height;
	}
	return;
}

trigger creation {
	anchor_down = 0x01;
	callback_active = 0x00;
	obj ship = getMultiSlaveId(this);
	if (ship == NULL()) {
		bark(this, "Ar, I have no ship!");
		return(0x01);
	}
	setObjVar(ship, "myshiptillerman", this);
	set_nav_point((0x00 - 0x01));
	nav_map = NULL();
	update_ship_dimensions(ship);
	return(0x01);
}

function int pop_ship_command(obj tillerman) {
	if (hasObjVar(tillerman, "shipcommand")) {
		int cmd = getObjVar(tillerman, "shipcommand");
		removeObjVar(tillerman, "shipcommand");
		return(cmd);
	}
	return((0x00 - 0x01));
}

function void save_ship_command(obj tillerman) {
	if (hasObjVar(tillerman, "shipcommand")) {
		setObjVar(tillerman, "oldshipcommand", getobjvar_int(tillerman, "shipcommand"));
	}
	return;
}

function void set_ship_command(obj tillerman, int command) {
	if ((command >= 0x08) && (command <= 0x0A)) {
		if (hasObjVar(tillerman, "shipcommand")) {
			int prev_command = getObjVar(tillerman, "shipcommand");
			if (((prev_command <= 0x07) || (prev_command >= 0x0B)) && (prev_command != 0x1B) && (prev_command != 0x1C)) {
				setObjVar(tillerman, "shipqueuedcommand", prev_command);
			}
		}
	}
	int cleared_command = pop_ship_command(tillerman);
	setObjVar(tillerman, "shipcommand", command);
	if (callback_active == 0x00) {
		callback_active = 0x01;
		shortCallback(this, 0x02, 0x31);
	}
	return;
}

trigger serverswitch {
	if (containedBy(this) != NULL()) {
		return(0x01);
	}
	if (hasObjVar(this, "oldshipcommand")) {
		int command = getobjvar_int(this, "oldshipcommand");
		removeObjVar(this, "oldshipcommand");
		set_ship_command(this, command);
	}
	return(0x01);
}

function int rotate_ship_delta(obj ship, int rotation_type) {
	int new_dir = getObjVar(ship, "myshipdir");
	int rotation_angle = 0x00;
	new_dir = new_dir + 0x04;
	if (rotation_type == 0x01) {
		new_dir = new_dir + 0x01;
		rotation_angle = 0x02;
	}
	if (rotation_type == 0x02) {
		new_dir = new_dir - 0x01;
		rotation_angle = 0x06;
	}
	if (rotation_type == 0x03) {
		new_dir = new_dir - 0x02;
		rotation_angle = 0x04;
	}
	if (new_dir > 0x03) {
		new_dir = new_dir - 0x04;
	}
	if (new_dir > 0x03) {
		new_dir = new_dir - 0x04;
	}
	int result = rotate_ship(ship, new_dir, rotation_angle);
	update_ship_dimensions(ship);
	return(result);
}

function int nav_to_waypoint(obj tillerman, int single_step) {
	string msg;
	string num_str;
	obj ship = getMultiSlaveId(tillerman);
	if (ship == NULL()) {
		bark(tillerman, "Blimey, I have no ship!");
		return(0x00);
	}
	if ((!isValid(nav_map)) || (!isMap(nav_map))) {
		bark(tillerman, "I have seen no map, sir.");
		nav_map = NULL();
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(nav_map), getLocation(tillerman)) > 0x0F) {
		bark(tillerman, "The map is too far away from me, sir.");
		nav_map = NULL();
		return(0x00);
	}
	loc nav_loc;
	if (!getMapPoint(nav_loc, nav_map, nav_point_index)) {
		msg = "Nav point ";
		num_str = nav_point_index + 0x01;
		concat(msg, num_str);
		concat(msg, " is invalid, sir.");
		bark(tillerman, msg);
		nav_point_index = (0x00 - 0x01);
		return(0x00);
	}
	loc ship_loc = getLocation(ship);
	if (getDistanceInTiles(ship_loc, nav_loc) <= ship_max_dimension) {
		if (single_step) {
			msg = "We have arrived at nav ";
			num_str = nav_point_index + 0x01;
			concat(msg, num_str);
			concat(msg, ", sir.");
			bark(tillerman, msg);
			nav_point_index++;
			int cleared_cmd = pop_ship_command(tillerman);
			return(0x00);
		}
		nav_point_index++;
		if (!getMapPoint(nav_loc, nav_map, nav_point_index)) {
			nav_point_index = (0x00 - 0x01);
			bark(tillerman, "The course is completed, sir.");
			cleared_cmd = pop_ship_command(tillerman);
			return(0x00);
		}
		msg = "Heading to nav point ";
		num_str = nav_point_index + 0x01;
		concat(msg, num_str);
		concat(msg, ", sir.");
		bark(tillerman, msg);
	}
	int target_dir = getDirectionInternal(ship_loc, nav_loc);
	int ship_dir = getObjVar(ship, "myshipdir");
	ship_dir = ship_dir * 0x02;
	int dir_diff = get_direction_delta(target_dir, ship_dir);
	int command = 0x00;
	if ((dir_diff > 0x01) || (dir_diff < (0x00 - 0x01))) {
		if (dir_diff < 0x00) {
			command = 0x09;
		} else {
			command = 0x08;
		}
	} else {
		if (dir_diff == 0x01) {
			command = 0x01;
		} else {
			if (dir_diff == (0x00 - 0x01)) {
				command = 0x07;
			} else {
				command = 0x00;
			}
		}
	}
	return(exec_ship_command(tillerman, command, 0x01));
}

function int exec_ship_command(obj tillerman, int cmd, int continuous) {
	int result;
	obj ship = getMultiSlaveId(this);
	if (ship == NULL()) {
		int cleared_cmd = pop_ship_command(tillerman);
		bark(this, "Ar, I have no ship!");
		return(0x00);
	}
	if (anchor_down == 0x01) {
		bark(this, "Ar, the anchor is down sir!");
		return(0x00);
	}
	if ((cmd >= 0x08) && (cmd <= 0x0A)) {
		int rotation_type = cmd - 0x07;
		result = rotate_ship_delta(ship, rotation_type);
		if (result > 0x00) {
			if (!continuous) {
				bark(tillerman, "Yes, sir.");
			}
		} else {
			if (result < 0x00) {
				bark(tillerman, "Arr, the water is too turbulent to turn sir!");
			} else {
				bark(tillerman, "Ar, can't turn sir.");
			}
			cleared_cmd = pop_ship_command(tillerman);
			return(0x00);
		}
		if (!continuous) {
			cleared_cmd = pop_ship_command(tillerman);
			return(0x00);
		}
		return(0x01);
	}
	if (((cmd >= 0x00) && (cmd <= 0x07)) || ((cmd >= 0x0B) && (cmd <= 0x1A)) || ((cmd >= 0x1D) && (cmd <= 0x24))) {
		int speed = 0x01;
		int dir = 0x00;
		if ((cmd >= 0x00) && (cmd <= 0x07)) {
			dir = cmd;
			if ((cmd == 0x00) || (cmd == 0x01) || (cmd == 0x07)) {
				speed = 0x03;
			}
		}
		if ((cmd >= 0x0B) && (cmd <= 0x12)) {
			dir = cmd - 0x0B;
		}
		if ((cmd >= 0x13) && (cmd <= 0x1A)) {
			dir = cmd - 0x13;
			if ((dir == 0x00) || (dir == 0x01) || (dir == 0x07)) {
				speed = 0x03;
			}
		}
		if ((cmd >= 0x1D) && (cmd <= 0x24)) {
			dir = cmd - 0x1D;
		}
		result = move_ship_relative(ship, dir, speed);
		if (result == 0x00) {
			bark(tillerman, "Ar, we've stopped sir.")cleared_cmd = pop_ship_command(tillerman);
			clear_queued_command(tillerman);
			return(0x00);
		} else {
			if (result < 0x00) {
				bark(tillerman, "Ar, turbulent water!")save_ship_command(tillerman);
				result = move_ship_or_map_switch(ship, dir, tillerman);
				if (!continuous) {
					if (!did_normal_move) {
						cleared_cmd = pop_ship_command(tillerman);
					} else {
						did_normal_move = 0x00;
					}
				}
				return(0x00);
			} else {
				if (((cmd >= 0x13) && (cmd <= 0x1A)) || ((cmd >= 0x1D) && (cmd <= 0x24))) {
					if (!continuous) {
						cleared_cmd = pop_ship_command(tillerman);
					}
				}
			}
		}
		return(0x01);
	}
	if (cmd == 0x1B) {
		return(nav_to_waypoint(tillerman, 0x00));
	}
	if (cmd == 0x1C) {
		return(nav_to_waypoint(tillerman, 0x01));
	}
	if (cmd >= 0x25) {
		bark(this, "Ar, I don't know how to do that, sir.");
		cleared_cmd = pop_ship_command(tillerman);
		return(0x00);
	}
	return(0x00);
}

trigger callback(0x31) {
	callback_active = 0x00;
	if (containedBy(this) != NULL()) {
		return(0x01);
	}
	if (hasObjVar(this, "shipcommand")) {
		int command = getObjVar(this, "shipcommand");
		if (exec_ship_command(this, command, 0x00)) {
			shortCallback(this, 0x02, 0x31);
			callback_active = 0x01;
			return(0x01);
		}
		if (hasObjVar(this, "shipqueuedcommand")) {
			int queued_cmd = getObjVar(this, "shipqueuedcommand");
			removeObjVar(this, "shipqueuedcommand");
			set_ship_command(this, queued_cmd);
		}
	}
	return(0x01);
}

trigger speech("*") {
	if (containedBy(this) != NULL()) {
		return(0x01);
	}
	obj ship = getMultiSlaveId(this);
	if (isDead(speaker) && (!isManifesting(speaker))) {
		return(0x01);
	}
	if (!isOnMulti(speaker, ship)) {
		return(0x01);
	}
	if ((!has_ship_key(ship, speaker)) && (!isEditing(speaker))) {
		obj closest_player = getClosestVisibleOnlinePlayer(getLocation(this), 0x0F);
		if ((closest_player == NULL()) || ((closest_player != speaker))) {
			return(0x01);
		}
		list players;
		getPlayersOnMulti(players, ship);
		int count = numInList(players);
		int i;
		for (i = 0x00; i < count; i++) {
			obj player = players[i];
			if (has_ship_key(ship, player)) {
				return(0x01);
			}
		}
	}
	list args;
	split(args, arg);
	string msg;
	string word1;
	string word2;
	string word3;
	int num = numInList(args);
	if (num > 0x02) {
		word1 = args[0x00];
		word2 = args[0x01];
		if ((word1 == "set") && (word2 == "name")) {
			string ship_name;
			string word;
			for (int j = 0x02; j < num; j++) {
				if (j != 0x02) {
					concat(ship_name, " ");
				}
				word = args[j];
				concat(ship_name, word);
			}
			msg = "This ship is now called the ";
			concat(msg, ship_name);
			concat(msg, ".");
			set_name(ship, ship_name);
			barkTo(this, speaker, msg);
			return(0x01);
		}
	}
	if (num == 0x01) {
		word1 = args[0x00];
		if (word1 == "name") {
			if (has_name(ship)) {
				msg = "This is the ";
				concat(msg, get_custom_multi_name(ship));
				concat(msg, ".");
				bark(this, msg);
			} else {
				bark(this, "Ar, this ship has no name.");
			}
			return(0x01);
		}
		if (word1 == "forward") {
			set_ship_command(this, 0x00);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if ((word1 == "backwards") || (word1 == "backward") || (word1 == "back")) {
			set_ship_command(this, 0x04);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "left") {
			set_ship_command(this, 0x06);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "right") {
			set_ship_command(this, 0x02);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "stop") {
			int prev_cmd = pop_ship_command(this);
			bark(this, "Yes, sir.");
			return(0x01);
		}
		if (word1 == "starboard") {
			set_ship_command(this, 0x08);
			return(0x01);
		}
		if (word1 == "port") {
			set_ship_command(this, 0x09);
			return(0x01);
		}
		if (word1 == "nav") {
			int nav_idx = get_nav_point();
			string nav_msg;
			if (nav_idx < 0x00) {
				concat(nav_msg, "I have no current nav point.");
			} else {
				concat(nav_msg, "My current destination navpoint is nav ");
				nav_msg = nav_msg + (nav_idx + 0x01);
				concat(nav_msg, ".");
			}
			bark(this, nav_msg);
			return(0x01);
		}
		if (word1 == "start") {
			set_nav_point(0x00);
			set_ship_command(this, 0x1B);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "continue") {
			set_ship_command(this, 0x1B);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		return(0x01);
	}
	if (num == 0x02) {
		word1 = args[0x00];
		word2 = args[0x01];
		if ((word1 == "remove") && (word2 == "name")) {
			if (has_name(ship)) {
				clear_name(ship);
				bark(this, "This ship now has no name.");
			} else {
				bark(this, "This ship has no name.");
			}
			return(0x01);
		}
		if ((word1 == "unfurl") && (word2 == "sail")) {
			set_ship_command(this, 0x00);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if ((word1 == "furl") && (word2 == "sail")) {
			prev_cmd = pop_ship_command(this);
			if (prev_cmd >= 0x00) {
				bark(this, "Yes sir.");
			} else {
				bark(this, "Er, the ship is not moving sir.");
			}
			return(0x01);
		}
		if (((word1 == "drop") && (word2 == "anchor")) || ((word1 == "lower") && (word2 == "anchor"))) {
			if (anchor_down != 0x01) {
				anchor_down = 0x01;
				bark(this, "Ar, anchor dropped sir.");
				prev_cmd = pop_ship_command(this);
			} else {
				bark(this, "Ar, the anchor was already dropped sir.");
			}
			return(0x01);
		}
		if (((word1 == "raise") && (word2 == "anchor")) || ((word1 == "lift") && (word2 == "anchor")) || ((word1 == "hoist") && (word2 == "anchor"))) {
			if (anchor_down != 0x00) {
				anchor_down = 0x00;
				bark(this, "Ar, anchor raised sir.");
			} else {
				bark(this, "Ar, the anchor has not been dropped sir.");
			}
			return(0x01);
		}
		if ((word1 == "forward") && (word2 == "left")) {
			set_ship_command(this, 0x07);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if ((word1 == "forward") && (word2 == "right")) {
			set_ship_command(this, 0x01);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (((word1 == "backward") && (word2 == "left")) || ((word1 == "backwards") && (word2 == "left")) || ((word1 == "back") && (word2 == "left"))) {
			set_ship_command(this, 0x05);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (((word1 == "backward") && (word2 == "right")) || ((word1 == "backwards") && (word2 == "right")) || ((word1 == "back") && (word2 == "right"))) {
			set_ship_command(this, 0x03);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if ((word1 == "turn") && (word2 == "right")) {
			set_ship_command(this, 0x08);
			return(0x01);
		}
		if ((word1 == "turn") && (word2 == "left")) {
			set_ship_command(this, 0x09);
			return(0x01);
		}
		if ((word1 == "turn") && (word2 == "around")) {
			set_ship_command(this, 0x0A);
			return(0x01);
		}
		if ((word1 == "come") && (word2 == "about")) {
			set_ship_command(this, 0x0A);
			return(0x01);
		}
		if ((word1 == "drift") && (word2 == "left")) {
			set_ship_command(this, 0x06);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if ((word1 == "drift") && (word2 == "right")) {
			set_ship_command(this, 0x02);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "slow") {
			if (word2 == "left") {
				set_ship_command(this, 0x11);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word2 == "right") {
				set_ship_command(this, 0x0D);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word2 == "forward") {
				set_ship_command(this, 0x0B);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if ((word2 == "back") || (word2 == "backward") || (word2 == "backwards")) {
				set_ship_command(this, 0x0F);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
		}
		if (word1 == "one") {
			if (word2 == "left") {
				set_ship_command(this, 0x23);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word2 == "right") {
				set_ship_command(this, 0x1F);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word2 == "forward") {
				set_ship_command(this, 0x1D);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if ((word2 == "back") || (word2 == "backward") || (word2 == "backwards")) {
				set_ship_command(this, 0x21);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
		}
		if (word2 == "one") {
			if (word1 == "left") {
				set_ship_command(this, 0x23);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word1 == "right") {
				set_ship_command(this, 0x1F);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if (word1 == "forward") {
				set_ship_command(this, 0x1D);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
			if ((word1 == "back") || (word1 == "backward") || (word1 == "backwards")) {
				set_ship_command(this, 0x21);
				bark(this, "Aye aye sir.");
				return(0x01);
			}
		}
		if (word1 == "goto") {
			set_nav_point(strtoi(word2) - 0x01);
			set_ship_command(this, 0x1B);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		if (word1 == "single") {
			set_nav_point(strtoi(word2) - 0x01);
			set_ship_command(this, 0x1C);
			bark(this, "Aye aye sir.");
			return(0x01);
		}
		return(0x01);
	}
	if (num == 0x03) {
		word1 = args[0x00];
		word2 = args[0x01];
		word3 = args[0x02];
		if (word1 == "slow") {
			if (word2 == "forward") {
				if (word3 == "left") {
					set_ship_command(this, 0x12);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word3 == "right") {
					set_ship_command(this, 0x0C);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
			if ((word2 == "back") || (word2 == "backward") || (word2 == "backwards")) {
				if (word3 == "left") {
					set_ship_command(this, 0x10);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word3 == "right") {
					set_ship_command(this, 0x0E);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
		}
		if (word1 == "one") {
			if (word2 == "forward") {
				if (word3 == "left") {
					set_ship_command(this, 0x24);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word3 == "right") {
					set_ship_command(this, 0x1E);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
			if ((word2 == "back") || (word2 == "backward") || (word2 == "backwards")) {
				if (word3 == "left") {
					set_ship_command(this, 0x22);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word3 == "right") {
					set_ship_command(this, 0x20);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
		}
		if (word3 == "one") {
			if (word1 == "forward") {
				if (word2 == "left") {
					set_ship_command(this, 0x24);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word2 == "right") {
					set_ship_command(this, 0x1E);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
			if ((word1 == "back") || (word1 == "backward") || (word1 == "backwards")) {
				if (word2 == "left") {
					set_ship_command(this, 0x22);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
				if (word2 == "right") {
					set_ship_command(this, 0x20);
					bark(this, "Aye aye sir.");
					return(0x01);
				}
			}
		}
	}
	return(0x01);
}

trigger give {
	int result;
	if (isMap(givenobj)) {
		if (!isValidMap(givenobj)) {
			bark(this, "Ar, that is not a map, tis but a blank piece of paper!");
		} else {
			loc map_point;
			if (!getMapPoint(map_point, givenobj, 0x00)) {
				bark(this, "Arrrr, this map has no course on it!");
			} else {
				bark(this, "A map!");
				nav_map = givenobj;
			}
		}
	} else {
		bark(this, "Rrrrr, I don't want that!  Show me a map!");
	}
	return(0x00);
}

function void set_nav_point(int index) {
	nav_point_index = index;
	return;
}

function int get_nav_point() {
	return(nav_point_index);
}

trigger objectloaded {
	if (containedBy(this) == NULL()) {
		int cmd = pop_ship_command(this);
	}
	return(0x01);
}

trigger lookedat {
	obj ship = getMultiSlaveId(this);
	if (has_name(ship)) {
		string msg = "the tillerman of the ";
		concat(msg, get_custom_multi_name(ship));
		barkTo(this, looker, msg);
		bark_decay_status(this, looker, "ship");
		return(0x00);
	}
	bark_decay_status(this, looker, "ship");
	return(0x01);
}

trigger use {
	obj ship = getMultiSlaveId(this);
	if (has_house_key(ship, user)) {
		systemMessage(user, "What dost thou wish to name thy ship?");
		textEntry(this, user, 0x18, 0x00, "");
	} else {
		string reply;
		int num = random(0x00, 0x0F);
		switch(num) {
		case 0x00
		case 0x01
		case 0x02
			reply = "Arr, don't do that!";
			break;
		case 0x03
		case 0x04
		case 0x05
			reply = "Arr, leave me alone!";
			break;
		case 0x06
		case 0x07
		case 0x08
			reply = "Arr, watch what thou'rt doing, matey!";
			break;
		case 0x09
		case 0x0A
			reply = "Arr!  Do that again and I'll throw ye overboard!";
			break;
		case 0x0B
		case 0x0C
		case 0x0D
		case 0x0E
		case 0x0F
			default
			reply = "Arr!  Only the owner of the ship may change its name!";
			break;
		}
		bark(this, reply);
	}
	return(0x00);
}

trigger textentry(0x18) {
	if (button == 0x00) {
		return(0x00);
	}
	obj ship = getMultiSlaveId(this);
	if (has_house_key(ship, sender)) {
		if (text == "") {
			if (has_name(ship)) {
				clear_name(ship);
				barkTo(this, sender, "This ship now has no name.");
			}
		} else {
			string msg = "This ship is now called the ";
			concat(msg, text);
			concat(msg, ".");
			barkTo(this, sender, msg);
			set_name(ship, text);
		}
	}
	return(0x00);
}
