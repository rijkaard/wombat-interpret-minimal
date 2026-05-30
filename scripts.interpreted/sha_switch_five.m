inherits globals;

trigger use {
	list f_args;
	loc trapLocation = 0x1548, 0xC2, 0x00;
	if (!hasObjVar(this, "switchWorking")) {
		setObjVar(this, "switchWorking", 0x01);
		messageToRange(trapLocation, 0x05, "disarm", f_args);
		callback(this, 0x1E, 0x26);
		return(0x01);
	}
	return(0x00);
}

trigger callback(0x26) {
	list f_args;
	loc trapLocation = 0x1548, 0xC2, 0x00;
	if (hasObjVar(this, "switchWorking")) {
		removeObjVar(this, "switchWorking");
		messageToRange(trapLocation, 0x05, "reset", f_args);
	}
	return(0x00);
}
