trigger time("min:**") {
	int obj_type = getObjType(this);
	loc location = getLocation(this);
	obj target;
	list mobs;
	int dmg;
	if (!hasObjVar(this, "working")) {
		setObjVar(this, "working", 0x01);
		switch(obj_type) {
		case 0x10FC
			doLocAnimation(location, 0x10FE, 0x02, 0x20, 0x00, 0x00);
			break;
		case 0x1110
			doLocAnimation(location, 0x1111, 0x02, 0x20, 0x00, 0x00);
			break;
		default
			break;
		}
		getMobsInRange(mobs, getLocation(this), 0x01);
		if (numInList(mobs) != 0x00) {
			target = mobs[0x00];
			dmg = dice(0x03, 0x0F);
			loseHP(target, dmg);
		}
	}
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	return(0x01);
}
