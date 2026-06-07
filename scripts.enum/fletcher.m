inherits itemmanip;

trigger use {
	if (isAtHome(this)) {
		systemMessage(user, "You can't use that, it belongs to someone else.");
		return(0x00);
	}
	int obj_type = getObjType(this);
	loc item_loc = getLocation(this);
	switch(obj_type) {
	case 0x1BD1
		systemMessage(user, "Select the shafts you wish to use this on.");
		break;
	case 0x1BD4
		systemMessage(user, "Select the feathers you wish to use this on.");
		break;
	}
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (isAtHome(usedon)) {
		systemMessage(user, "That belongs to someone else.");
		return(0x00);
	}
	int this_type = getObjType(this);
	int usedon_type = getObjType(usedon);
	loc user_loc = getLocation(user);
	loc this_loc = getLocation(this);
	loc usedon_loc = getLocation(usedon);
	obj result_obj;
	list args;
	if (testAndLearnSkill(user, SKILL_BOWCRAFT, 0x00, 0x50) > 0x00) {
		switch(this_type) {
		case 0x1BD1
			switch(usedon_type) {
			case 0x1BD4
				attachScript(user, "makingarrows");
				args = this, usedon;
				message(user, "makearrows", args);
				break;
			default
				systemMessage(user, "Can't use feathers on that.");
				return(0x00);
				break;
			}
			break;
		case 0x1BD4
			switch(usedon_type) {
			case 0x1BD1
				attachScript(user, "makingarrows");
				args = usedon, this;
				message(user, "makearrows", args);
				break;
			default
				systemMessage(user, "Can't use shafts on that.");
				return(0x00);
				break;
			}
			break;
		default
			return(0x00);
			break;
		}
	} else {
		systemMessage(user, "Fletching failed.");
		int remaining;
		int ok;
		if (!random(0x00, 0x03)) {
			debugMessage("!rand");
			debugMessage("thistype = " + this_type);
			if (this_type == 0x1BD1) {
				systemMessage(user, "A feather was destroyed.");
				returnResourcesToBank(this, 0x01, "feathers");
				ok = getResource(remaining, this, "feathers", 0x03, 0x02);
			}
			if (this_type == 0x1BD4) {
				systemMessage(user, "A shaft was destroyed.");
				returnResourcesToBank(this, 0x01, "wood");
				ok = getResource(remaining, this, "wood", 0x03, 0x02);
			}
			if (remaining < 0x01) {
				deleteObject(this);
			}
		}
	}
	return(0x01);
}
