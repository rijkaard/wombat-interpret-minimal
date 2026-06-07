inherits sndfx;

trigger creation {
	callback(this, 0x02, 0x66);
	return(0x00);
}

trigger callback(0x66) {
	if (hasObjVar(this, "valueless")) {
		removeObjVar(this, "valueless");
	}
	return(0x00);
}

trigger use {
	if (isInContainer(this)) {
		return(0x00);
	}
	loc location = getLocation(this);
	int newType;
	obj new_obj;
	int obj_type = getObjType(this);
	switch(obj_type) {
	case 0x0A55
	case 0x0A56
		if (hasObjVar(user, "timeInCamp")) {
			int time_in_camp = getObjVar(user, "timeInCamp");
			if (time_in_camp > 0x0F) {
				list options;
				appendToList(options, 0x00);
				appendToList(options, "Using a bedroll in the safety of a camp will log you out of the game safely. If this is what you wish to do, click in the box at left, and then select Continue. Otherwise, hit the Cancel button to avoid logging out.");
				selectType(user, this, 0x39, "Logging out via camping.", options);
			}
		}
		int bedroll = getObjType(this);
		sfx(location, 0x57, 0x00);
		if (bedroll == 0x0A55) {
			if (random(0x01, 0x02) == 0x01) {
				newType = 0x0A58;
			} else {
				newType = 0x0A57;
			}
		}
		if (bedroll == 0x0A56) {
			if (random(0x01, 0x02) == 0x01) {
				newType = 0x0A59;
			} else {
				newType = 0x0A57;
			}
		}
		setType(this, newType);
		break;
	case 0x0A57
	case 0x0A58
	case 0x0A59
		sfx(location, 0x57, 0x00);
		if (random(0x01, 0x02) == 0x01) {
			new_obj = createNoResObjectAt(0x0A55, location);
			attachScript(new_obj, "2645");
		} else {
			new_obj = createNoResObjectAt(0x0A56, location);
			attachScript(new_obj, "2646");
		}
		deleteObject(this);
		break;
	}
	return(0x00);
}

trigger typeselected(0x39) {
	if (listindex == 0x00) {
		return(0x00);
	}
	switch(objtype) {
	case 0x00
		if (hasObjVar(user, "campFireId")) {
			removeObjVar(user, "campFireId");
		}
		if (hasObjVar(user, "timeInCamp")) {
			removeObjVar(user, "timeInCamp");
		}
		setType(this, 0x0A58);
		int put_result = putObjContainer(this, getBackpack(user));
		safeLogOut(user);
		return(0x00);
		break;
	default
		return(0x00);
	}
	return(0x00);
}
