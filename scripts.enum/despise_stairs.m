inherits globals;

trigger enterrange(0x01) {
	loc dest;
	loc my_loc = getLocation(this);
	loc stair_a = 0x15C4, 0x0275, 0x2D;
	loc stair_b = 0x15C3, 0x0278, 0x0A;
	loc stair_c = 0x1581, 0x023A, 0x27;
	loc stair_d = 0x1593, 0x02A1, 0x23;
	if (my_loc == stair_a) {
		dest = 0x157A, 0x023A, 0x3B;
	}
	if (my_loc == stair_b) {
		dest = 0x158E, 0x02A0, 0x14;
	}
	if (my_loc == stair_c) {
		dest = 0x15C8, 0x0275, 0x1E;
	}
	if (my_loc == stair_d) {
		dest = 0x15C8, 0x0279, 0x1E;
	}
	if (!teleport(target, dest)) {
		return(0x01);
	}
	return(0x00);
}
