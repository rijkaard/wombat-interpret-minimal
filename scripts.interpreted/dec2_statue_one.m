inherits globals;

trigger use {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int z_up = z + 0x01;
	loc dest = x, y, z_up;
	loc trapLocation = 0x14CB, 0x023C, 0x00;
	list f_args;
	if (!hasObjVar(this, "working")) {
		callback(this, 0x05, 0x24);
		int ok = teleport(this, dest);
		messageToRange(trapLocation, 0x0A, "disarm", f_args);
		setObjVar(this, "working", 0x01);
	}
	return(0x01);
}

trigger callback(0x24) {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	int target_z = z - 0x01;
	loc dest = x, y, target_z;
	if (hasObjVar(this, "working")) {
		removeObjVar(this, "working");
	}
	int result = teleport(this, dest);
	return(0x01);
}
