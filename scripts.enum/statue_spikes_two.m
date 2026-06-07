inherits sndfx;

trigger message("disarm") {
	if (!hasObjVar(this, "disarmed")) {
		setObjVar(this, "disarmed", 0x01);
		callBack(this, 0x3C, 0x24);
	}
	return(0x00);
}

trigger callback(0x24) {
	if (hasObjVar(this, "disarmed")) {
		removeObjVar(this, "disarmed");
	}
	return(0x00);
}

trigger enterrange(0x01) {
	if (isDead(target)) {
		return(0x01);
	}
	if (!hasObjVar(this, "disarmed")) {
		loc trap_loc - getLocation(this);
		sfx(trap_loc, 0x022D, 0x00);
		doLocAnimation(trap_loc, 0x1109, 0x01, 0x10, 0x00, 0x00);
	}
	return(0x01);
}

trigger enterrange(0x00) {
	if (isDead(target)) {
		return(0x01);
	}
	if (!hasObjVar(this, "disarmed")) {
		loc pos - getLocation(this);
		sfx(pos, 0x022D, 0x00);
		doLocAnimation(pos, 0x1109, 0x01, 0x10, 0x00, 0x00);
		loseHP(target, dice(0x0A, 0x05));
	}
	return(0x01);
}
