trigger use {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int z_up = z + 0x01;
	loc dest = x, y, z_up;
	loc trapLocation = 0x14CB, 0x023C, 0x00;
	list f_args;
	if (!hasObjVar(this, "working")) {
		bark(this, "SOUND EFFECT");
		callback(this, 0x05, 0x01);
		int ok = teleport(this, dest);
		messageToRange(trapLocation, 0x0A, "disarm", f_args);
		setObjVar(this, "working", 0x01);
	}
	return(0x01);
}

trigger callback(0x01) {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int z_orig = z - 0x01;
	loc orig_loc = x, y, z_orig;
	bark(this, "SOUND EFFECT");
	bark(this, "returning");
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	int result = teleport(this, orig_loc);
	return(0x01);
}
