inherits globals;

trigger use {
	systemMessage(user, "Choose a location to create your spinning wheel.");
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
	loc target_loc = getLocation(usedon);
	int tile_height = getTileHeight(0x1019);
	setZ(target_loc, getZ(target_loc) + getHeight(usedon));
	int can_place = canExistAt(target_loc, tile_height, 0x01);
	obj wheel;
	if (can_place == 0x07) {
		wheel = requestCreateObjectAt(0x1019, target_loc);
		if (wheel != NULL()) {
			deleteObject(this);
		} else {
			systemMessage(user, "Can't create a spinning wheel there.");
			return(0x00);
		}
	} else {
		systemMessage(user, "Can't create a spinning wheel there.");
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
		int tile_height = getTileHeight(0x1019);
		int can_exist = canExistAt(place, tile_height, 0x01);
		obj created_obj;
		if (can_exist == 0x07) {
			created_obj = requestCreateObjectAt(0x1019, place);
			if (created_obj != NULL()) {
				deleteObject(this);
			} else {
				systemMessage(user, "Can't create a spinning wheel there.");
				return(0x00);
			}
		} else {
			systemMessage(user, "Can't create a spinning wheel there.");
			return(0x00);
		}
	}
	removeObjVar(this, "ObjSelected");
	return(0x01);
}
