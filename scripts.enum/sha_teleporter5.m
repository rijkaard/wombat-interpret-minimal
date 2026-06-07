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
	getObjListVar(mobs, this, getObjVar(this, "working"));
	obj m_target = mobs[0x00];
	loc tile_loc = getLocation(this);
	loc dest;
	loc loc_a = 0x16BC, 0x33, 0x1B;
	loc loc_b = 0x16B9, 0x4F, 0x05;
	removeObjVar(this, "working");
	clearList(mobs);
	getMobsInRange(mobs, tile_loc, 0x01);
	if (!isInList(mobs, m_target) || (getZ(getLocation(m_target)) != getZ(tile_loc))) {
		setType(this, 0x01);
		return(0x00);
	}
	if (tile_loc == loc_a) {
		dest = loc_b;
	}
	if (tile_loc == loc_b) {
		dest = loc_a;
	}
	if (!teleport(m_target, dest)) {
		return(0x01);
	}
	setType(this, 0x01);
	return(0x00);
}
