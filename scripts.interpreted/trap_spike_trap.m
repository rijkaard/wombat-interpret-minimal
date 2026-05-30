inherits globals;

trigger enterrange(0x00) {
	if (isDead(target)) {
		return(0x01);
	}
	int trap_type = getObjType(this);
	loc trap_loc = getLocation(this);
	if (!hasObjVar(this, "disarmed")) {
		switch(trap_type) {
		case 0x1108
			doLocAnimation(trap_loc, 0x1109, 0x01, 0x10, 0x00, 0x00);
			break;
		case 0x111B
			doLocAnimation(trap_loc, 0x111C, 0x01, 0x10, 0x00, 0x00);
			break;
		case 0x119A
			doLocAnimation(trap_loc, 0x119B, 0x01, 0x0E, 0x00, 0x00);
			break;
		case 0x11A0
			doLocAnimation(trap_loc, 0x11A1, 0x01, 0x0E, 0x00, 0x00);
			break;
		default
			break;
		}
		int dmg = dice(0x03, 0x0A);
		loseHP(target, dmg);
	}
	return(0x01);
}
