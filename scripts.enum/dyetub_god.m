inherits sndfx;

trigger use {
	systemMessage(user, "Select the clothing to dye.");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	int obj_type = getObjType(usedon);
	int hue = getHue(this);
	loc target_loc = getLocation(usedon);
	sfx(target_loc, 0x023E, 0x00);
	setHue(usedon, hue);
	return(0x00);
}
