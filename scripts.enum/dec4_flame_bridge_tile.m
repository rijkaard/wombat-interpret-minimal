inherits globals;

trigger leaverange(0x02) {
	int target_x = getX(getLocation(target));
	int tile_x = getX(getLocation(this));
	list mobs;
	if (!hasObjVar(this, "working") && (target_x < tile_x)) {
		setObjVar(this, "working", 0x01);
		doLocAnimation(getLocation(this), 0x3709, 0x02, 0x38, 0x00, 0x00);
		setType(this, 0x3727);
		callback(this, 0x01, 0x24);
		clearList(mobs);
		getMobsAt(mobs, getLocation(this));
		for (int i = 0x00; i < numInList(mobs); i++) {
			loseHP(mobs[i], 0x03E8);
		}
	}
	return(0x01);
}

trigger callback(0x24) {
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	deleteObject(this);
	return(0x00);
}
