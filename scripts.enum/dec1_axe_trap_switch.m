inherits globals;

trigger creation {
	int switchState = 0x00;
	setType(this, 0x1092);
	setObjVar(this, "switchState", switchState);
	return(0x00);
}

trigger use {
	loc trap_loc = 0x1458, 0x022D, (0x00 - 0x14);
	list f_args;
	int switchState = getObjVar(this, "switchState");
	if (switchState == 0x00) {
		setObjVar(this, "switchState", 0x01);
		callback(this, 0x1E, 0x24);
		setType(this, 0x1091);
		messageToRange(trap_loc, 0x01, "axe_disarm", f_args);
		return(0x00);
	} else {
		setObjVar(this, "switchState", 0x00);
		setType(this, 0x1092);
		messageToRange(trap_loc, 0x01, "axe_reload", f_args);
		return(0x00);
	}
	return(0x00);
}

trigger callback(0x24) {
	loc trap_loc = 0x1458, 0x022D, (0x00 - 0x14);
	list f_args;
	setObjVar(this, "switchState", 0x00);
	setType(this, 0x1092);
	messageToRange(trap_loc, 0x01, "axe_reload", f_args);
	return(0x00);
}
