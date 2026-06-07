trigger message("fireInTheHole") {
	int wall_type = getObjType(this);
	loc location = getLocation(this);
	list mobs;
	getMobsInRange(mobs, location, 0x01);
	if (numInList(mobs) != 0x00) {
		obj target = mobs[0x00];
	}
	if (!hasObjVar(this, "disarmed")) {
		switch(wall_type) {
		case 0x10FC
			doLocAnimation(location, 0x10FE, 0x02, 0x10, 0x00, 0x00);
			break;
		case 0x1110
			doLocAnimation(location, 0x1111, 0x02, 0x10, 0x00, 0x00);
			break;
		default
			break;
		}
		int dmg = dice(0x03, 0x0F);
		loseHP(target, dmg);
	}
	return(0x01);
}
