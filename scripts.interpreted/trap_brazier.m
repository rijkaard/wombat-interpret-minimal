inherits sndfx;

trigger use {
	if (hasObjVar(this, "brazierTrapInUse")) {
		return(0x00);
	}
	loc brazier_loc = getLocation(this);
	setObjVar(this, "brazierTrapInUse", 0x00);
	loc anim_loc = getX(getLocation(this)), getY(getLocation(this)), (getZ(getLocation(this)) + 0x05);
	doLocAnimation(anim_loc, 0x3709, 0x0A, 0x1E, 0x00, 0x00);
	sfx(brazier_loc, 0x54, 0x05);
	callback(this, 0x04, 0x41);
	return(0x00);
}

trigger callback(0x41) {
	removeObjVar(this, "brazierTrapInUse");
	return(0x00);
}
