inherits globals;

trigger creation {
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x01) {
	if (!hasObjVar(this, "working")) {
		list target_list = target;
		setObjVar(this, "working", target_list);
		setType(this, 0x373A);
		callback(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list working;
	getObjListVar(working, this, "working");
	obj mob = working[0x00];
	loc my_loc = getLocation(this);
	loc dest;
	loc loc_a = 0x15D0, 0xBB, 0x05;
	loc loc_b = 0x1548, 0xB3, 0x05;
	removeObjVar(this, "working");
	clearList(working);
	getMobsInRange(working, my_loc, 0x02);
	if (!isInList(working, mob)) {
		return(0x00);
	}
	if (my_loc == loc_a) {
		dest = loc_b;
	}
	if (my_loc == loc_b) {
		dest = loc_a;
	}
	if (!teleport(mob, dest)) {
		return(0x01);
	}
	setType(this, 0x01);
	return(0x00);
}
