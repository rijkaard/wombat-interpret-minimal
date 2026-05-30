trigger creation {
	setType(this, 0x07A3);
	return(0x00);
}

trigger enterrange(0x03) {
	list msg_args;
	loc above_loc = getX(getLocation(this)), getY(getLocation(this)), (getZ(getLocation(this)) + 0x01);
	if (getObjType(this) == 0x07A3) {
		callback(this, 0x02, 0x01);
		setType(this, 0x01);
		messageToRange(getLocation(this), 0x05, "blowUp", msg_args);
		doLocAnimation(getLocation(this), 0x3709, 0x02, 0x38, 0x00, 0x00);
	}
	return(0x01);
}

trigger leaverange(0x07) {
	list mobs_in_range;
	list msg_args;
	loc loc_below = getX(getLocation(this)), getY(getLocation(this)), (getZ(getLocation(this)) - 0x01);
	getMobsInRange(mobs_in_range, getLocation(this), 0x05);
	if ((numInList(mobs_in_range) == 0x00)) {
		if (getObjType(this) == 0x1228) {
			doLocAnimation(getLocation(this), 0x3709, 0x02, 0x38, 0x00, 0x00);
			setType(this, 0x01);
			callback(this, 0x02, 0x02);
		}
	}
	return(0x01);
}

trigger message("blowUp") {
	loc loc_above = getX(getLocation(this)), getY(getLocation(this)), (getZ(getLocation(this)) + 0x01);
	if (!(sender == this) && (getObjType(this) == 0x07A3)) {
		callback(this, 0x02, 0x01);
		setType(this, 0x01);
		doLocAnimation(getLocation(this), 0x3709, 0x02, 0x38, 0x00, 0x00);
	}
	return(0x00);
}

trigger callback(0x01) {
	if (getObjType(this) == 0x01) {
		setType(this, 0x1228);
	}
	return(0x00);
}

trigger callback(0x02) {
	if (getObjType(this) == 0x01) {
		setType(this, 0x07A3);
	}
	return(0x00);
}
