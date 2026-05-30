trigger use {
	int x = getX(getLocation(this)) + 0x01;
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	loc location = x, y, z;
	if (!hasObjVar(this, "not_trapped")) {
		doLocAnimation(location, 0x372A, 0x02, 0x14, 0x00, 0x00);
		return(0x00);
	}
	return(0x01);
}
