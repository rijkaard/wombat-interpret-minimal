inherits sndfx;

member int is_active;

member int obj_type;

member loc east_hit_loc;

member loc south_hit_loc;

member loc user_loc;

trigger creation {
	setObjVar(this, "isTrapped", 0x01);
	user_loc = getLocation(this);
	obj_type = getObjType(this);
	switch(obj_type) {
	case 0x1108
		east_hit_loc = user_loc;
		setX(east_hit_loc, getX(user_loc) + 0x01);
		break;
	case 0x111B
		south_hit_loc = user_loc;
		setY(south_hit_loc, getY(user_loc) + 0x01);
		break;
	}
	return(0x00);
}

trigger message("activate") {
	obj_type = getObjType(this);
	is_active = 0x01;
	if (hasObjVar(this, "disarmed")) {
		switch(obj_type) {
		case 0x1109
			setType(this, 0x1108);
			break;
		case 0x111C
			setType(this, 0x111B);
			break;
		case 0x11A1
			setType(this, 0x11A0);
			break;
		case 0x119B
			setType(this, 0x119A);
			break;
		default
			break;
		}
		callback(this, 0x64, 0x2F);
	} else {
		switch(obj_type) {
		case 0x1108
			doLocAnimation(user_loc, 0x1109, 0x06, 0x0C, 0x00, 0x00);
			break;
		case 0x111B
			doLocAnimation(user_loc, 0x111C, 0x06, 0x0C, 0x00, 0x00);
			break;
		case 0x11A0
			doLocAnimation(user_loc, 0x11A1, 0x06, 0x0C, 0x00, 0x00);
			break;
		case 0x119A
			doLocAnimation(user_loc, 0x119B, 0x06, 0x0C, 0x00, 0x00);
			break;
		default
			break;
		}
		sfx(user_loc, 0x022C, 0x00);
		list mobs;
		getMobsInRange(mobs, user_loc, 0x01);
		int mob_count = numInList(mobs);
		for (int i = 0x00; i < mob_count; i++) {
			obj victim = mobs[i];
			loseHP(victim, dice(0x01, 0x06) * 0x06);
		}
		shortcallback(this, 0x04, 0x23);
	}
	return(0x00);
}

trigger message("deactivate") {
	obj_type = getObjType(this);
	is_active = 0x00;
	switch(obj_type) {
	case 0x1109
		setType(this, 0x1108);
		break;
	case 0x110E
		setType(this, 0x1108);
		break;
	case 0x111C
		setType(this, 0x111B);
		break;
	case 0x1121
		setType(this, 0x111B);
		break;
	case 0x11A1
		setType(this, 0x11A0);
		break;
	case 0x11A5
		setType(this, 0x11A0);
		break;
	case 0x119B
		setType(this, 0x119A);
		break;
	case 0x119F
		setType(this, 0x119A);
		break;
	default
		break;
	}
	return(0x00);
}

trigger enterrange(0x00) {
	if (!hasObjVar(this, "disarmed")) {
		list args;
		message(this, "activate", args);
	} else {
		callback(this, 0x64, 0x2F);
	}
	return(0x01);
}

trigger callback(0x23) {
	obj_type = getObjType(this);
	switch(obj_type) {
	case 0x1108
	case 0x1109
		setType(this, 0x110E);
		break;
	case 0x111B
	case 0x111C
		setType(this, 0x1121);
		break;
	case 0x11A0
	case 0x11A1
		setType(this, 0x11A5);
		break;
	case 0x119A
	case 0x119B
		setType(this, 0x119F);
		break;
	default
		break;
	}
	setObjVar(this, "disarmed", 0x01);
	callback(this, 0x05, 0x24);
	return(0x00);
}

trigger callback(0x24) {
	obj_type = getObjType(this);
	switch(obj_type) {
	case 0x110E
		setType(this, 0x1108);
		doLocAnimation(user_loc, 0x110D, 0x05, 0x09, 0x01, 0x00);
		break;
	case 0x1121
		setType(this, 0x111B);
		doLocAnimation(user_loc, 0x1120, 0x05, 0x09, 0x01, 0x00);
		break;
	case 0x11A5
		setType(this, 0x11A0);
		doLocAnimation(user_loc, 0x11A4, 0x05, 0x09, 0x01, 0x00);
		break;
	case 0x119F
		setType(this, 0x119A);
		doLocAnimation(user_loc, 0x119E, 0x05, 0x09, 0x01, 0x00);
		break;
	default
		break;
	}
	removeObjVar(this, "disarmed");
	return(0x00);
}

trigger callback(0x2F) {
	if (hasObjVar(this, "disarmed")) {
		removeObjVar(this, "disarmed");
	}
	return(0x00);
}
