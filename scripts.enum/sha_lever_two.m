inherits globals;

trigger use {
	loc broadcast_loc = 0x158D, 0xB2, 0x00;
	list f_args;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		messageToRange(broadcast_loc, 0x0A, "unlock", f_args);
		setType(this, 0x108D);
		callback(this, 0x01, 0x24);
	}
	return(0x00);
}

trigger callback(0x24) {
	int cur_type = getObjType(this);
	int newType;
	loc range_loc = 0x158D, 0xB2, 0x00;
	list f_args;
	switch(cur_type) {
	case 0x108D
		newType = 0x108C;
		callback(this, 0x01, 0x24);
		break;
	case 0x108C
		newType = 0x108E;
		callback(this, 0x3C, 0x24);
		break;
	case 0x108E
		newType = cur_type;
		removeObjVar(this, "working");
		messageToRange(range_loc, 0x01, "reset", f_args);
		break;
	}
	setType(this, newType);
	return(0x00);
}
