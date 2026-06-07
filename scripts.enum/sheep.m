inherits globals;

trigger creation {
	setObjVar(this, "woolOnSheep", 0x1E);
	return(0x01);
}

trigger time("hour:**") {
	int value = 0x00;
	int new_wool = 0x00;
	int max_wool = 0x1D;
	if (!hasObjVar(this, "woolOnSheep")) {
		return(0x01);
	}
	value = getObjVar(this, "woolOnSheep");
	if (value < max_wool) {
		new_wool = value + 0x01;
		setObjVar(this, "woolOnSheep", new_wool);
	} else {
		if (getObjType(this) == 0xDF) {
			obj wool_obj = requestCreateObjectIn(0x0DF8, this);
			transferResources(this, wool_obj, 0x1E, "cloth");
			setObjVar(this, "woolOnSheep", 0x1E);
			setType(this, 0xCF);
			deleteObject(wool_obj);
		}
	}
	return(0x01);
}
