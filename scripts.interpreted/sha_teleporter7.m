inherits globals;

trigger creation {
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x01) {
	if (!hasObjVar(this, "working")) {
		list targets = target;
		setObjVar(this, "working", targets);
		setType(this, 0x373A);
		callback(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	list mobs;
	getObjListVar(mobs, this, "working");
	obj mob = mobs[0x00];
	loc self_loc = getLocation(this);
	loc dest;
	loc loc_a = 0x16AA, 0x11, 0x05;
	loc loc_b = 0x1644, 0x15, 0x0F;
	removeObjVar(this, "working");
	clearList(mobs);
	getMobsInRange(mobs, self_loc, 0x01);
	if (!isInList(mobs, mob) || (getZ(getLocation(mob)) != getZ(self_loc))) {
		setType(this, 0x01);
		return(0x00);
	}
	if (self_loc == loc_a) {
		dest = loc_b;
	}
	if (self_loc == loc_b) {
		dest = loc_a;
	}
	if (!teleport(mob, dest)) {
		return(0x01);
	}
	setType(this, 0x01);
	return(0x00);
}
