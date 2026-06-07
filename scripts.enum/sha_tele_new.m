inherits globals;

trigger creation {
	setType(this, 0x01);
	return(0x00);
}

trigger enterrange(0x01) {
	if (!hasObjVar(this, "working")) {
		obj mob = target;
		setObjVar(this, "working", mob);
		setType(this, 0x373A);
		callBack(this, 0x05, 0x24);
	}
	return(0x01);
}

trigger callback(0x24) {
	obj mob;
	list mobs;
	loc dest;
	int ok = 0x01;
	loc here = getLocation(this);
	if (!hasObjVar(this, "working")) {
		ok = 0x00;
	}
	mob = getObjVar(this, "working");
	removeObjVar(this, "working");
	clearList(mobs);
	getMobsInRange(mobs, here, 0x02);
	if (!isInList(mobs, mob)) {
		ok = 0x00;
	}
	if (!hasObjVar(this, "toLocation")) {
		ok = 0x00;
	}
	if (ok) {
		dest = getObjVar(this, "toLocation");
		if (!teleport(mob, dest)) {
			setType(this, 0x01);
			return(0x01);
		}
		setType(this, 0x01);
		return(0x00);
	}
	setType(this, 0x01);
	return(0x00);
}
