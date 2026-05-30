inherits sndfx;

trigger creation {
	setObjVar(this, "isDown", 0x01);
	loc location = getLocation(this);

member int z_down = getZ(location);

member int z_up = z_down + 0x14;
	return(0x01);
}

trigger message("portcullisdown") {
	removeObjVar(this, "isUp");
	setObjVar(this, "isDown", 0x01);
	setObjVar(this, "isInMotion", 0x01);
	callback(this, 0x01, 0x45);
	return(0x01);
}

trigger message("portcullisup") {
	removeObjVar(this, "isDown");
	setObjVar(this, "isUp", 0x01);
	setObjVar(this, "isInMotion", 0x01);
	callback(this, 0x01, 0x45);
	return(0x01);
}

trigger use {
	if (hasObjVar(this, "isLocked")) {
		bark(this, "It is locked.");
		return(0x00);
	}
	list f_args;
	if (hasObjVar(this, "isInMotion")) {
		barkTo(user, user, "The portcullis is in motion. You can't stop it now.");
		return(0x01);
	}
	if (hasObjVar(this, "isDown")) {
		removeObjVar(this, "isDown");
		setObjVar(this, "isUp", 0x01);
		setObjVar(this, "isInMotion", 0x01);
		messageToRange(getLocation(this), 0x05, "portcullisup", f_args);
		callback(this, 0x01, 0x45);
		return(0x01);
	}
	if (hasObjVar(this, "isUp")) {
		setObjVar(this, "isDown", 0x01);
		messageToRange(getLocation(this), 0x05, "portcullisdown", f_args);
		setObjVar(this, "isInMotion", 0x01);
		removeObjVar(this, "isUp");
		callback(this, 0x01, 0x45);
		return(0x01);
	}
	return(0x01);
}

trigger callback(0x45) {
	if (!hasObjVar(this, "isInMotion")) {
		return(0x00);
	}
	int tmp;
	int tp_result;
	loc pos = getLocation(this);
	int z = getZ(pos);
	if (hasObjVar(this, "isUp")) {
		if (z == z_up) {
			removeObjVar(this, "isInMotion");
			sfx(getLocation(this), 0xEE, 0x00);
			return(0x00);
		}
		setZ(pos, z + 0x01);
		sfx(getLocation(this), 0xEF, 0x00);
		tp_result = teleport(this, pos);
		shortCallback(this, 0x01, 0x45);
		return(0x00);
	}
	if (hasObjVar(this, "isDown")) {
		if (z == z_down) {
			sfx(getLocation(this), 0xEE, 0x00);
			removeObjVar(this, "isInMotion");
			return(0x00);
		}
		setZ(pos, z - 0x01);
		sfx(getLocation(this), 0xF0, 0x00);
		tp_result = teleport(this, pos);
		shortCallback(this, 0x01, 0x45);
		return(0x00);
	}
	return(0x01);
}
