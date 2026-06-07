inherits shipstuff;

member obj pending_close_plank;

member int pending_close_plank_type;

function void register_plank(obj plank) {
	obj ship = getMultiSlaveId(plank);
	list doors;
	if (hasObjVar(ship, "myhousedoors")) {
		getObjListVar(doors, ship, "myhousedoors");
	}
	appendToList(doors, plank);
	setObjVar(ship, "myhousedoors", doors);
	return;
}

trigger creation {
	int lock_level = set_lock_level(this, 0x0100, 0x0100);
	apply_lock(this);
	pending_close_plank = NULL();
	pending_close_plank_type = 0x00;
	register_plank(this);
	return(0x01);
}

function int is_raised_plank_type(int side, int obj_type) {
	switch(side) {
	case 0x00
		switch(obj_type) {
		case 0x3EB2
		case 0x3E85
		case 0x3EB1
		case 0x3E8A
			return(0x01);
		}
		break;
	case 0x01
		switch(obj_type) {
		case 0x3EB1
		case 0x3E8A
		case 0x3EB2
		case 0x3E85
			return(0x01);
		}
		break;
	case 0x01
		break;
	}
	return(0x00);
}

function int is_open_plank_type(int side, int obj_type) {
	switch(side) {
	case 0x00
		switch(obj_type) {
		case 0x3ED4
		case 0x3E84
		case 0x3ED5
		case 0x3E89
			return(0x01);
		}
		break;
	case 0x01
		switch(obj_type) {
		case 0x3ED5
		case 0x3E89
		case 0x3ED4
		case 0x3E84
			return(0x01);
		}
		break;
	}
	return(0x00);
}

function int get_toggled_plank_type(int side, int obj_type) {
	switch(side) {
	case 0x00
		switch(obj_type) {
		case 0x3ED4
			return(0x3EB2);
		case 0x3E84
			return(0x3E85);
		case 0x3ED5
			return(0x3EB1);
		case 0x3E89
			return(0x3E8A);
		case 0x3EB2
			return(0x3ED4);
		case 0x3E85
			return(0x3E84);
		case 0x3EB1
			return(0x3ED5);
		case 0x3E8A
			return(0x3E89);
		}
		break;
	case 0x01
		switch(obj_type) {
		case 0x3ED5
			return(0x3EB1);
		case 0x3E89
			return(0x3E8A);
		case 0x3ED4
			return(0x3EB2);
		case 0x3E84
			return(0x3E85);
		case 0x3EB1
			return(0x3ED5);
		case 0x3E8A
			return(0x3E89);
		case 0x3EB2
			return(0x3ED4);
		case 0x3E85
			return(0x3E84);
		}
		break;
	}
	return(obj_type);
}

function void update_plank_state(int plank_type, obj plank) {
	setType(plank, get_toggled_plank_type(plank_type, getObjType(plank)));
	int not_lockable = hasObjVar(plank, "notLockable");
	int is_open = is_open_plank_type(plank_type, getObjType(plank));
	if ((is_open) && (!not_lockable)) {
		int val = 0x01;
		setObjVar(plank, "notLockable", val);
	}
	if ((!is_open) && (not_lockable)) {
		removeObjVar(plank, "notLockable");
	}
	return;
}

function void toggle_plank_and_schedule_close(int plank_type, obj plank, int is_locked) {
	update_plank_state(plank_type, plank);
	if ((is_locked) && (pending_close_plank == NULL())) {
		pending_close_plank_type = plank_type;
		pending_close_plank = plank;
		callback(plank, 0x03, 0x55);
	}
	return;
}

function int handle_plank_use(int plank_type, obj plank, obj user) {
	try_refresh_decay_on_use(plank, user, "ship");
	reveal_impl(user, 0x00);
	int on_ship = isOnMulti(user, getMultiSlaveId(plank));
	int is_locked = hasObjVar(plank, "isLocked");
	int is_editing = isEditing(user);
	if (is_editing && is_locked && !on_ship) {
		barkTo(user, user, "That is locked, but you open it with your godly powers.");
	} else {
		if (is_locked && !on_ship) {
			barkTo(user, user, "That is locked.");
			return(0x00);
		}
	}
	if (is_open_plank_type(plank_type, getObjType(plank))) {
		loc plank_loc = getLocation(plank);
		if (getDistanceInTiles(plank_loc, getLocation(user)) > 0x09) {
			return(0x00);
		}
		loc board_loc = getLocation(plank);
		setZ(board_loc, getZ(board_loc) + getSurfaceHeight(plank));
		if ((!on_ship) && (getDistanceInTiles(plank_loc, getLocation(user)) > 0x01) && canSeeLoc(user, board_loc)) {
			int tele_result = teleport(user, board_loc);
			return(0x00 - 0x01);
		}
		if (areObjectsOn(plank)) {
			return(0x00);
		}
	}
	toggle_plank_and_schedule_close(plank_type, plank, is_locked);
	return(0x01);
}

function void update_plank_on_recycle(int plank_type, obj plank, int oldtype) {
	if (is_open_plank_type(plank_type, oldtype)) {
		update_plank_state(plank_type, plank);
	}
	return;
}

function int teleport_off_plank(obj mobile, loc place, int dir, int num) {
	int result;
	loc candidate_loc = place;
	setZ(candidate_loc, getZ(candidate_loc) + 0x0F);
	for (int i = 0x00; i < num; i++) {
		if (canSeeLoc(mobile, candidate_loc)) {
			obj multi = get_multi_at(candidate_loc);
			if ((multi == NULL()) && (dropCheck(candidate_loc, mobile, getHeight(mobile)))) {
				if (i == 0x00) {
					int z_delta = getZ(candidate_loc) - getZ(place);
					if (z_delta < 0x00) {
						z_delta = z_delta * (0x00 - 0x01);
					}
					if (z_delta <= 0x03) {
						return(0x00);
					}
				}
				return(teleport(mobile, candidate_loc));
			}
		}
		moveDir(candidate_loc, dir);
	}
	return(0x00);
}

function int handle_plank_enter(int plank_type, obj plank, obj mobile) {
	obj ship = getMultiSlaveId(plank);
	int ship_dir = getObjVar(ship, "myshipdir");
	ship_dir = ship_dir * 0x02;
	int mobile_facing = getFacing(mobile);
	int dir_delta = ship_dir - mobile_facing;
	if (dir_delta < 0x00) {
		dir_delta = 0x08 + dir_delta;
	}
	int eject_threshold = 0x06;
	if (plank_type == 0x01) {
		eject_threshold = 0x02;
	}
	if (dir_delta == eject_threshold) {
		loc exit_loc = getLocation(mobile);
		moveDir(exit_loc, mobile_facing);
		moveDir(exit_loc, mobile_facing);
		return(!teleport_off_plank(mobile, exit_loc, mobile_facing, 0x09));
	} else {
		if (isNPC(mobile)) {
			if (!isOwnedPet(mobile)) {
				return(0x00);
			}
		}
	}
	return(0x01);
}

function int set_plank_state_var(obj plank, int plank_type, string var_name) {
	obj ship = getMultiSlaveId(plank);
	if (is_open_plank_type(plank_type, getObjType(plank))) {
		setObjVar(ship, var_name, 0x01);
		return(0x01);
	} else {
		setObjVar(ship, var_name, 0x00);
		return(0x00);
	}
	return(0x00);
}

function void play_music_to_crew(obj ship) {
	loc ship_loc = getLocation(ship);
	list players;
	getPlayersInRange(players, ship_loc, 0x07);
	for (int i = 0x00; i < numInList(players); i++) {
		obj player = players[i];
		if (isOnMulti(player, ship)) {
			musicTo(player, 0x20);
		}
	}
	return;
}

trigger callback(0x55) {
	int plank_type = pending_close_plank_type;
	obj plank = pending_close_plank;
	if (pending_close_plank != NULL()) {
		if (is_open_plank_type(plank_type, getObjType(plank))) {
			if (areObjectsOn(plank)) {
				callback(plank, 0x03, 0x55);
				return(0x01);
			}
			update_plank_state(plank_type, plank);
			string var_name = "shiprightplank";
			if (plank_type) {
				var_name = "shipleftplank";
			}
			int result = set_plank_state_var(this, plank_type, var_name);
		}
		pending_close_plank = NULL();
		pending_close_plank_type = 0x00;
	}
	return(0x01);
}

function void handle_ghost_plank_use(int plank_type, obj plank, obj user) {
	if (isDead(user) && isManifesting(user)) {
		int is_open = is_open_plank_type(plank_type, getObjType(plank));
		if (!is_open) {
			int on_ship = isOnMulti(user, getMultiSlaveId(plank));
			int is_locked = hasObjVar(plank, "isLocked");
			if ((!on_ship) && (is_locked)) {
				barkTo(user, user, "That is locked.");
			} else {
				toggle_plank_and_schedule_close(plank_type, plank, is_locked);
			}
		}
	}
	return();
}
