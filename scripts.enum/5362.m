inherits shipstuff;

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	int ship_type;
	if (getDistanceInTiles(place, getLocation(user)) > 0x0F) {
		bark(user, "That location is too far away.");
		return(0x01);
	}
	if (!hasObjVar(this, "myshiptype")) {
		ship_type = 0x00;
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	obj ship = create_ship_at(ship_type, place);
	if (ship != NULL()) {
		deleteObject(this);
		return(0x01);
	} else {
		bark(user, "A ship can not be created here.");
	}
	return(0x01);
}

trigger use {
	targetloc(user, this);
	return(0x01);
}

trigger creation {
	int default = 0x00;
	if (!hasObjVar(this, "myshiptype")) {
		setObjVar(this, "myshiptype", default);
	}
	return(0x01);
}
