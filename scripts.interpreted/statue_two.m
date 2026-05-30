trigger use {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int z_up = z + 0x01;
	loc dest = x, y, z_up;
	loc broadcast_loc = 0x14AF, 0x0244, 0x00;
	list range_list;
	if (!hasObjVar(this, "working")) {
		bark(this, "SOUND EFFECT");
		callback(this, 0x05, 0x01);
		int result = teleport(this, dest);
		messageToRange(broadcast_loc, 0x02, "unlocked", range_list);
		setObjVar(this, "working", 0x01);
	}
	return(0x01);
}

trigger callback(0x01) {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int z_down = z - 0x01;
	loc dest = x, y, z_down;
	bark(this, "SOUND EFFECT");
	bark(this, "returning");
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	int result = teleport(this, dest);
	return(0x01);
}
