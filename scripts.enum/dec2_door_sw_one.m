inherits sndfx;

trigger creation {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	setType(this, 0x108C);
	return(0x00);
}

trigger use {
	loc msg_loc = 0x14A4, 0x0227, 0x00;
	list f_args;
	int flag;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", flag);
		sfx(getLocation(this), 0x4B, 0x00);
		messageToRange(msg_loc, 0x01, "unlocked", f_args);
		setType(this, 0x108D);
		callback(this, 0x01, 0x27);
	}
	return(0x00);
}

trigger callback(0x27) {
	setType(this, 0x108E);
	callback(this, 0x01, 0x28);
	return(0x00);
}

trigger callback(0x28) {
	setType(this, 0x108C);
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	return(0x00);
}
