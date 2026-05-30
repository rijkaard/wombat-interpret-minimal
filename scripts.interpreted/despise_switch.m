inherits globals;

trigger use {
	list f_args;
	if (!hasObjVar(this, "trapLocation")) {
		systemMessage(this, "No Trap Location Variable.");
		return(0x00);
	}
	loc trapLocation = getObjVar(this, "trapLocation");
	messageToRange(trapLocation, 0x02, "disarm", f_args);
	callback(this, 0x3C, 0x26);
	return(0x01);
}

trigger callback(0x26) {
	list f_args;
	loc trapLocation = getObjVar(this, "trapLocation");
	messageToRange(trapLocation, 0x02, "reset", f_args);
	return(0x00);
}
