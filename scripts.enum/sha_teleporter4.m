inherits globals;

trigger creation {
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x01) {
	if (!hasObjVar(this, "working")) {
		list working_list = target;
		setObjVar(this, "working", working_list);
		setType(this, 0x373A);
		callback(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	getObjListVar(mobs, this, "working");
	obj m_target = mobs[0x00];
	loc self_loc = getLocation(this);
	loc dest;
	loc loc_a = 0x1583, 0xA2, 0x05;
	loc loc_b = 0x157A, 0xB2, 0x05;
	removeObjVar(this, "working");
	clearList(mobs);
	getMobsInRange(mobs, self_loc, 0x02);
	if (!isInList(mobs, m_target)) {
		setType(this, 0x01);
		return(0x00);
	}
	if (self_loc == loc_a) {
		dest = loc_b;
	}
	if (self_loc == loc_b) {
		dest = loc_a;
	}
	if (!teleport(m_target, dest)) {
		return(0x01);
	}
	setType(this, 0x01);
	return(0x00);
}
