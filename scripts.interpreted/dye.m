inherits globals;

member obj dye_tub;

function int is_dye_tub(obj it) {
	int type = getObjType(it);
	if (type == 0x0FAB) {
		return(0x01);
	}
	return(0x00);
}

trigger creation {
	setObjVar(this, "usesLeft", 0x19);
	return(0x01);
}

trigger use {
	dye_tub = NULL();
	systemMessage(user, "Select the dye tub to use the dyes on.");
	targetObj(user, this);
	return(0x00);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	if (is_dye_tub(usedon)) {
		dye_tub = usedon;
		selectHue(user, this, 0x00, 0x0FAB);
	} else {
		dye_tub = NULL();
		systemMessage(user, "Use that on a dye tub.");
	}
	return(0x00);
}

trigger hueselected(0x00) {
	if (!is_dye_tub(dye_tub)) {
		dye_tub = NULL();
		return(0x00);
	}
	if (objhue < 0x02) {
		objhue = 0x02;
	}
	if (objhue > 0x03E9) {
		objhue = 0x03E9;
	}
	setHue(dye_tub, objhue);
	dye_tub = NULL();
	int usesLeft = getObjVar(this, "usesLeft");
	if (usesLeft == 0x01) {
		systemMessage(user, "You used up the dye.");
		deleteObject(this);
	} else {
		setObjVar(this, "usesLeft", usesLeft - 0x01);
	}
	return(0x00);
}
