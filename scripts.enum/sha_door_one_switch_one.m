inherits globals;

member loc door_loc;

member list msg_args;

trigger creation {
	door_loc = 0x15C2, 0xC6, 0x00;
	return(0x00);
}

trigger use {
	if (!hasObjVar(this, "doorSwitchWorking")) {
		setObjVar(this, "doorSwitchWorking", 0x01);
		messageToRange(door_loc, 0x01, "unlock", msg_args);
		callback(this, 0x1E, 0x26);
		return(0x01);
	}
	return(0x00);
}

trigger callback(0x26) {
	if (hasObjVar(this, "doorSwitchWorking")) {
		removeObjVar(this, "doorSwitchWorking");
		messageToRange(door_loc, 0x01, "lockup", msg_args);
	}
	return(0x00);
}
