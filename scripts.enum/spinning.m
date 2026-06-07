inherits itemmanip;

trigger use {
	if (!canSeeObj(user, this)) {
		return(0x00);
	}
	if (isAtHome(this)) {
		systemMessage(user, "You can't use that, it belongs to someone else.");
		return(0x00);
	}
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone is using that.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x01);
		callback(this, 0x1E, 0x1B);
	}
	systemMessage(user, "What spinning wheel do you wish to spin this on?");
	targetObj(user, this);
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

function void start_spinning(obj user, obj wheel, string product, int spin_value, int hue) {
	loc wheel_loc = getLocation(wheel);
	loc loc_copy = wheel_loc;
	int orig_type;
	obj wheel_ref;
	int rc;
	int wheel_type = getObjType(wheel);
	switch(wheel_type) {
	case 0x1015
		orig_type = 0x1015;
		wheel_ref = wheel;
		setType(wheel_ref, 0x1016);
		break;
	case 0x1019
		orig_type = 0x1019;
		wheel_ref = wheel;
		setType(wheel_ref, 0x101A);
		break;
	case 0x101C
		orig_type = 0x101C;
		wheel_ref = wheel;
		setType(wheel_ref, 0x101D);
		break;
	}
	setObjVar(wheel_ref, "SOURCE", this);
	setObjVar(wheel_ref, "CREATE_THIS", product);
	setObjVar(wheel_ref, "HUE", hue);
	setObjVar(wheel_ref, "USER", user);
	setObjVar(wheel_ref, "ORIGINAL_TYPE", orig_type);
	setObjVar(wheel_ref, "SPINVALUE", spin_value);
	callback(wheel_ref, 0x05, 0x20);
	return();
}

trigger targetobj {
	if (usedon == NULL()) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	if (!canSeeObj(user, usedon)) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	int wheel_type = getObjType(usedon);
	int fiber_type = getObjType(this);
	int unused;
	int hue;
	int ok;
	int cloth_remaining;
	hue = getHue(this);
	switch(wheel_type) {
	case 0x1015
	case 0x1019
	case 0x101C
		if (hasObjVar(usedon, "inUse")) {
			systemMessage(user, "That spinning wheel is being used.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		} else {
			setObjVar(usedon, "inUse", 0x01);
		}
		int spin_amount;
		string product;
		switch(fiber_type) {
		case 0x0DF8
			spin_amount = 0x1E;
			product = "yarn";
			break;
		case 0x101F
			spin_amount = 0x0A;
			product = "yarn";
			break;
		case 0x0DF9
		case 0x1A9C
		case 0x1A9D
			spin_amount = 0x3C;
			product = "thread";
			break;
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		transferResources(usedon, this, spin_amount, "cloth");
		start_spinning(user, usedon, product, spin_amount, hue);
		break;
	case 0x1016
	case 0x101A
	case 0x101D
		systemMessage(user, "That spinning wheel is being used.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	default
		systemMessage(user, "Use that on a spinning wheel.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	ok = getResource(cloth_remaining, this, "cloth", 0x03, 0x02);
	if ((cloth_remaining < 0x01) && (getQuantity(this) == 0x01)) {
		deleteObject(this);
	}
	return(0x00);
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x01);
}
