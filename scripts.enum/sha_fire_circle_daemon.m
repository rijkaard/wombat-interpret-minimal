inherits globals;

trigger creation {
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x00) {
	list f_args;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		messageToRange(getLocation(this), 0x0A, "poof", f_args);
		callback(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	int teleport_result;
	loc dest;
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
		getMobsInRange(mobs, getLocation(this), 0x04);
		for (int i = 0x00; i < numInList(mobs); i++) {
			dest = (0x1647 + i), 0x20, 0x00;
			teleport_result = teleport(mobs[i], dest);
		}
	}
	return(0x00);
}
