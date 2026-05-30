inherits globals;

trigger use {
	loc dest = 0x15A5, 0xAD, 0x00;
	list f_args;
	if (!hasObjVar(this, "working")) {
		if (!hasObjVar(this, "allow")) {
			systemMessage(user, "The lever seems to be blocked by a mechanism of some sort.");
			messageToRange(getLocation(this), 0x08, "showoff", f_args);
			return(0x00);
		}
		setObjVar(this, "working", 0x01);
		messageToRange(dest, 0x0A, "vanish", f_args);
		setType(this, 0x108D);
		callback(this, 0x01, 0x24);
	}
	return(0x00);
}

trigger callback(0x24) {
	int cur_type = getObjType(this);
	int newType;
	switch(cur_type) {
	case 0x108D
		newType = 0x108C;
		callback(this, 0x01, 0x24);
		break;
	case 0x108C
		newType = 0x108E;
		removeObjVar(this, "working");
		break;
	}
	setType(this, newType);
	return(0x00);
}
