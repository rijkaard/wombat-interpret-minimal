inherits spelskil;

function int is_rune(obj it) {
	int objtype = getObjType(it);
	switch(objtype) {
	case 0x1F14
	case 0x1F15
	case 0x1F16
	case 0x1F17
		return(0x01);
		break;
	default
		return(0x00);
		break;
	}
	return(0x00);
}

function int validate_mark_target(obj user, obj usedon) {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (!isValid(usedon)) {
		bark(user, "I cannot mark that object.");
		return(0x00);
	}
	if ((containedBy(usedon) == NULL()) && (canSeeObj(user, usedon) != 0x01)) {
		bark(user, "I cannot see that object.");
		return(0x00);
	}
	if (isMobile(usedon) || (!is_rune(usedon))) {
		bark(user, "I cannot mark that object.");
		return(0x00);
	}
	if (isOnAnyMulti(user)) {
		bark(user, "You can not mark an object at that location.");
		return(0x00);
	}
	return(0x01);
}

function int apply_mark(obj user, obj usedon) {
	int success = 0x00;
	if (validate_mark_target(user, usedon)) {
		loc user_loc = getLocation(user);
		if (can_teleport_in(user_loc)) {
			success = 0x01;
			setObjVar(usedon, "markLoc", user_loc);
			list f_args;
			message(usedon, "marked", f_args);
			doLocAnimation(getLocation(usedon), 0x3779, 0x0A, 0x0F, 0x00, 0x00);
			sfx(user_loc, 0x01FA, 0x00);
		} else {
			systemMessage(user, "Thy spell doth not appear to work...");
		}
	}
	schedule_cleanup(this);
	return(success);
}
