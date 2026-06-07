trigger creation {
	int next_type;
	if (getObjType(this) == 0x06) {
		setType(this, 0x01);
		next_type = 0x0E5C;
	}
	if (getObjType(this) == 0x07) {
		setType(this, 0x01);
		next_type = 0x0E5F;
	}
	if (getObjType(this) == 0x08) {
		setType(this, 0x01);
		next_type = 0x0E62;
	}
	if (getObjType(this) == 0x0C) {
		setType(this, 0x01);
		next_type = 0x0E65;
	}
	if (getObjType(this) == 0x0E5C) {
		next_type = 0x0E5F;
	}
	if (getObjType(this) == 0x0E5F) {
		next_type = 0x0E62;
	}
	if (getObjType(this) == 0x0E62) {
		next_type = 0x0E65;
	}
	if (getObjType(this) == 0x0E65) {
		next_type = 0x0E5F;
	}
	setObjVar(this, "myNextObjType", next_type);
	return(0x00);
}

trigger message("switchType") {
	int next_type;
	if (getObjType(this) == 0x01) {
		next_type = getObjVar(this, "myNextObjType");
		setType(this, next_type);
		return(0x00);
	}
	if (getObjType(this) == 0x0E5C) {
		next_type = 0x0E5F;
	}
	if (getObjType(this) == 0x0E5F) {
		next_type = 0x0E62;
	}
	if (getObjType(this) == 0x0E62) {
		next_type = 0x0E65;
	}
	if (getObjType(this) == 0x0E65) {
		next_type = 0x0E5C;
	}
	setObjVar(this, "myNextObjType", next_type);
	setType(this, 0x01);
	return(0x00);
}
