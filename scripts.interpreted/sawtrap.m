inherits sndfx;

member int is_active;

member int obj_type;

member loc blade_east_loc;

member loc blade_south_loc;

trigger creation {
	setObjVar(this, "isTrapped", 0x01);
	loc here = getLocation(this);
	int x = getX(here);
	int y = getY(here);
	obj_type = getObjType(this);
	switch(obj_type) {
	case 0x1116
		blade_east_loc = here;
		setX(blade_east_loc, getX(here) + 0x01);
		x = getX(blade_east_loc);
		y = getY(blade_east_loc);
		break;
	case 0x1103
		blade_south_loc = here;
		setY(blade_south_loc, getY(here) + 0x01);
		break;
	}
	return(0x00);
}

trigger message("activate") {
	obj_type = getObjType(this);
	loc location = getLocation(this);
	is_active = 0x01;
	if (hasObjVar(this, "disarmed")) {
		switch(obj_type) {
		case 0x1117
			setType(this, 0x1116);
			break;
		case 0x1104
			setType(this, 0x1103);
			break;
		case 0x11AD
			setType(this, 0x11AC);
			break;
		case 0x11B2
			setType(this, 0x11B1);
			break;
		default
			break;
		}
		callback(this, 0x64, 0x2F);
	} else {
		switch(obj_type) {
		case 0x1103
			doLocAnimation(location, 0x1104, 0x03, 0x06, 0x00, 0x00);
			break;
		case 0x1116
			doLocAnimation(location, 0x1117, 0x03, 0x06, 0x00, 0x00);
			break;
		case 0x11AC
			doLocAnimation(location, 0x11AD, 0x03, 0x06, 0x00, 0x00);
			break;
		case 0x11B1
			doLocAnimation(location, 0x11B2, 0x03, 0x06, 0x00, 0x00);
			break;
		default
			break;
		}
		sfx(location, 0x021C, 0x00);
		shortcallback(this, 0x02, 0x23);
	}
	return(0x00);
}

trigger message("deactivate") {
	obj_type = getObjType(this);
	loc trap_loc = getLocation(this);
	is_active = 0x00;
	switch(obj_type) {
	case 0x1107
		setType(this, 0x1103);
		doLocAnimation(trap_loc, 0x1106, 0x03, 0x05, 0x00, 0x00);
		break;
	case 0x111A
		setType(this, 0x1116);
		doLocAnimation(trap_loc, 0x1119, 0x03, 0x05, 0x00, 0x00);
		break;
	case 0x11B0
		setType(this, 0x11AC);
		doLocAnimation(trap_loc, 0x11AF, 0x03, 0x05, 0x00, 0x00);
		break;
	case 0x11B5
		setType(this, 0x11B1);
		doLocAnimation(trap_loc, 0x11B4, 0x03, 0x05, 0x00, 0x00);
		break;
	default
		break;
	}
	return(0x00);
}

trigger enterrange(0x01) {
	list mobs;
	int i;
	obj_type = getObjType(this);
	loc location = getLocation(this);
	if (hasObjVar(this, "disarmed")) {
		callback(this, 0x64, 0x2F);
	} else {
		switch(obj_type) {
		case 0x1116
			getMobsAt(mobs, blade_east_loc);
			int mob_count = numInList(mobs);
			if (numInList(mobs) > 0x00) {
				setType(this, 0x1117);
				for (i = 0x00; i < numInList(mobs); i++) {
					loseHP(mobs[i], dice(0x02, 0x14));
				}
				sfx(location, 0x021C, 0x00);
				shortcallback(this, 0x02, 0x24);
			}
			break;
		case 0x1103
			getMobsAt(mobs, blade_south_loc);
			if (numInList(mobs) > 0x00) {
				setType(this, 0x1102);
				for (i = 0x00; i < numInList(mobs); i++) {
					loseHP(mobs[i], dice(0x02, 0x14));
				}
				sfx(location, 0x021C, 0x00);
				shortcallback(this, 0x02, 0x24);
			}
			break;
		case 0x11AC
			break;
		case 0x11B2
			break;
		default
			break;
		}
	}
	return(0x01);
}

trigger enterrange(0x00) {
	loc pos = getLocation(this);
	if (!hasObjVar(this, "disarmed")) {
		switch(obj_type) {
		case 0x1116
			break;
		case 0x1103
			break;
		case 0x11AC
			setType(this, 0x11AD);
			loseHP(target, dice(0x02, 0x14));
			sfx(pos, 0x021C, 0x00);
			shortcallback(this, 0x02, 0x24);
			break;
		case 0x11B2
			setType(this, 0x11B3);
			loseHP(target, dice(0x02, 0x14));
			sfx(pos, 0x021C, 0x00);
			shortcallback(this, 0x02, 0x24);
			break;
		default
			break;
		}
	} else {
		callback(this, 0x64, 0x2F);
	}
	return(0x01);
}

trigger callback(0x23) {
	obj_type = getObjType(this);
	switch(obj_type) {
	case 0x1103
		setType(this, 0x1107);
		break;
	case 0x1116
		setType(this, 0x111A);
		break;
	case 0x11AC
		setType(this, 0x11B0);
		break;
	case 0x11B1
		setType(this, 0x11B5);
		break;
	default
		break;
	}
	callback(this, 0x05, 0x24);
	return(0x00);
}

trigger callback(0x24) {
	loc pos = getLocation(this);
	list mobs;
	switch(obj_type) {
	case 0x1117
		getMobsAt(mobs, pos);
		break;
	case 0x1104
		getMobsAt(mobs, pos);
		break;
	case 0x11AD
		getMobsAt(mobs, pos);
		break;
	case 0x11B2
		getMobsAt(mobs, pos);
		break;
	default
		break;
	}
	if (numInList(mobs) > 0x00) {
		for (int i = 0x00; i < numInList(mobs); i++) {
			if (!hasObjVar(this, "disarmed")) {
				loseHP(mobs[i], dice(0x02, 0x14));
			}
		}
		shortcallback(this, 0x02, 0x24);
		return(0x00);
	}
	if ((is_active == 0x00) || (numInList(mobs) == 0x00)) {
		list args;
		message(this, "deactivate", args);
		return(0x00);
	}
	sfx(getLocation(this), 0x021C, 0x00);
	return(0x00);
}

trigger callback(0x2F) {
	removeObjVar(this, "disarmed");
	return(0x00);
}
