inherits globals;

trigger use {
	systemMessage(user, "Choose a location to create your anvil.");
	systemMessage(user, "You will not be able to put it in your backpack afterwards.");
	targetLoc(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		return(0x00);
	}
	systemMessage(user, "Targetobj called");
	setObjVar(this, "ObjSelected", 0x01);
	loc placement_loc = getLocation(usedon);
	int anvil_height = getTileHeight(0x0FB0);
	setZ(placement_loc, getZ(placement_loc) + getHeight(usedon));
	int can_place = canExistAt(placement_loc, anvil_height, 0x01);
	obj anvil;
	if (can_place == 0x07) {
		anvil = requestCreateObjectAt(0x0FB0, placement_loc);
		if (anvil != NULL()) {
			deleteObject(this);
		} else {
			systemMessage(user, "Can't create an anvil there.");
			return(0x00);
		}
	} else {
		systemMessage(user, "Can't create an anvil there.");
		return(0x00);
	}
	return(0x01);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	systemMessage(user, "Targetloc called");
	if (!(hasObjVar(this, "ObjSelected"))) {
		int tile_height = getTileHeight(0x0FB0);
		int can_place = canExistAt(place, tile_height, 0x01);
		obj anvil;
		if (can_place == 0x07) {
			anvil = requestCreateObjectAt(0x0FB0, place);
			if (anvil != NULL()) {
				deleteObject(this);
			} else {
				systemMessage(user, "Can't create an anvil there.");
				return(0x00);
			}
		} else {
			systemMessage(user, "Can't create an anvil there.");
			return(0x00);
		}
	}
	removeObjVar(this, "ObjSelected");
	return(0x01);
}
