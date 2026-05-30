trigger creation {
	setType(this, 0x11B6);
	return(0x00);
}

trigger speech("*") {
	int x = getX(getLocation(this));
	int y = getY(getLocation(this));
	int z = getZ(getLocation(this));
	loc dest;
	if (arg == "w" || (arg == "west")) {
		dest = (x - 0x01), y, z;
	}
	if (arg == "e" || (arg == "east")) {
		dest = (x + 0x01), y, z;
	}
	if (arg == "n" || (arg == "north")) {
		dest = x, (y - 0x01), z;
	}
	if (arg == "s" || (arg == "south")) {
		dest = x, (y + 0x01), z;
	}
	if (arg == "implode" || (arg == "Andrew")) {
		setType(this, 0x11A6);
		return(0x00);
	}
	if (arg == "boulder") {
		setType(this, 0x11B6);
		return(0x00);
	}
	if (!teleport(this, dest)) {
		return(0x00);
	}
	return(0x01);
}
