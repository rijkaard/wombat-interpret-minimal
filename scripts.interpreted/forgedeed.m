inherits globals;

trigger use {
	systemMessage(user, "Choose a location to create your forge.");
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
	int forge_height = getTileHeight(0x0FB1);
	setZ(target_loc, getZ(target_loc) + getHeight(usedon));
	int can_exist = canExistAt(target_loc, forge_height, 0x01);
	obj forge;
	if (can_exist == 0x07) {
		forge = requestCreateObjectAt(0x0FB1, target_loc);
		if (forge != NULL()) {
			deleteObject(this);
		} else {
			systemMessage(user, "Can't create an forge there.");
			return(0x00);
		}
	} else {
		systemMessage(user, "Can't create an forge there.");
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
		int tile_height = getTileHeight(0x0FB1);
		int can_exist = canExistAt(place, tile_height, 0x01);
		obj forge;
		if (can_exist == 0x07) {
			forge = requestCreateObjectAt(0x0FB1, place);
			if (forge != NULL()) {
				deleteObject(this);
			} else {
				systemMessage(user, "Can't create an forge there.");
				return(0x00);
			}
		} else {
			systemMessage(user, "Can't create an forge there.");
			return(0x00);
		}
	}
	removeObjVar(this, "ObjSelected");
	return(0x01);
}
