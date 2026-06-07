inherits globals;

trigger use {
	loc broadcast_loc = 0x14AF, 0x0244, 0x00;
	list f_args;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		messageToRange(broadcast_loc, 0x02, "unlocked", f_args);
		setType(this, 0x1090);
		callback(this, 0x02, 0x24);
	}
	return(0x00);
}

trigger callback(0x24) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	if (getObjType(this) == 0x1090) {
		setType(this, 0x108F);
	}
	return(0x00);
}
