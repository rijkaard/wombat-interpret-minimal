inherits shipstuff;

trigger objectloaded {
	if (hasScript(this, "spellbook")) {
		detachScript(this, "spellbook");
	}
	return(0x01);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	if (hasObjVar(this, "claimloc")) {
		loc claimloc = getObjVar(this, "claimloc");
		if (getDistanceInTiles(place, claimloc) > 0x64) {
			barkTo(user, user, "You are too far away from the location at which the ship was docked.");
			return(0x01);
		}
	}
	int ship_type = 0x00;
	if (getDistanceInTiles(place, getLocation(user)) > 0x06) {
		barkTo(user, user, "That location is too far away.");
		return(0x01);
	}
	if (!hasObjVar(this, "myshiptype")) {
		ship_type = 0x00;
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	obj ship = NULL();
	if (hasObjVar(this, "shipobj")) {
		ship = getObjVar(this, "shipobj");
	}
	placement_elev = 0x00 - 0x05;
	int can_place = 0x00 - 0x01;
	if (ship != NULL()) {
		can_place = canMultiExistAt(ship, place, multi_check_flags);
	}
	if (can_place <= 0x00) {
		string err_msg = get_placement_error_msg(placement_elev, "ship", "water");
		barkTo(user, user, err_msg);
		return(0x01);
	}
	int teleport_result = teleport(ship, place);
	deleteObject(this);
	return(0x01);
}

trigger use {
	int ship_type;
	if (!hasObjVar(this, "myshiptype")) {
		ship_type = 0x00;
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	int multi = calc_multi_index(ship_type, 0x00);
	barkTo(user, user, "Where do you wish to place the ship?");
	targetlocmulti(user, this, multi, 0x00, 0x00, 0x00);
	return(0x00);
}

trigger creation {
	int ship_type = 0x00;
	if (!hasObjVar(this, "myshiptype")) {
		setObjVar(this, "myshiptype", ship_type);
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	setObjVar(this, "mybasevalue", calc_ship_value(ship_type));
	setObjVar(this, "fakeCont", 0x01);
	return(0x01);
}

trigger give {
	return(0x00);
}

trigger decay {
	return(0x00);
}

trigger shop {
	obj ship = NULL();
	if (hasObjVar(this, "shipobj")) {
		ship = getObjVar(this, "shipobj");
	}
	if (isValid(ship)) {
		deleteObject(ship);
	}
	return(0x01);
}
