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
	list mobs;
	getObjListVar(mobs, this, "working");
	obj m_target = mobs[0x00];
	loc here = getLocation(this);
	loc dest;
	loc loc_a = 0x161D, 0x74, 0x0F;
	loc loc_b = 0x162A, 0x0C, (0x00 - 0x05);
	removeObjVar(this, "working");
	clearList(mobs);
	getMobsInRange(mobs, here, 0x01);
	if (!isInList(mobs, m_target) || (getZ(getLocation(m_target)) != getZ(here))) {
		setType(this, 0x01);
		return(0x00);
	}
	if (here == loc_a) {
		dest = loc_b;
	}
	if (here == loc_b) {
		dest = loc_a;
	}
	if (!teleport(m_target, dest)) {
		return(0x01);
	}
	setType(this, 0x01);
	return(0x00);
}
