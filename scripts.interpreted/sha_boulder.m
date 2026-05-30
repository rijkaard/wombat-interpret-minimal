inherits globals;

member int move_dir;

trigger creation {
	setType(this, 0x11B6);
	move_dir = 0x01;
	callback(this, 0x01, 0x24);
	return(0x00);
}

trigger objectloaded {
	callback(this, 0x01, 0x24);
	return(0x00);
}

trigger callback(0x24) {
	loc location = getLocation(this);
	int x = getX(location);
	int y = getY(location);
	int z = getZ(location);
	int new_x;
	loc toLocation;
	if ((move_dir == 0x01) && (x < 0x1596)) {
		new_x = x + 0x01;
	}
	if (x == 0x1596) {
		move_dir = 0x00;
	}
	if ((move_dir == 0x00) && (x > 0x1593)) {
		new_x = x - 0x01;
	}
	if (x == 0x1593) {
		move_dir = 0x01;
	}
	toLocation = new_x, y, z;
	int ok = teleport(this, toLocation);
	callback(this, 0x01, 0x24);
	return(0x00);
}
