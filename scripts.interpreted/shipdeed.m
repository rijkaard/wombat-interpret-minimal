inherits shipstuff;

function int create_ship_key(obj deed, obj user, obj ship, int bank) {
	loc user_loc = getLocation(user);
	list key_types = 0x100E, 0x100F, 0x1010, 0x1013;
	int num = random(0x00, (numInList(key_types) - 0x01));
	int key_type = key_types[num];
	obj container = NULL();
	if (bank) {
		fixBank(user);
		container = getItemAtSlot(user, 0x1D);
		if (container == NULL()) {
			container = getBackpack(user);
			bank = 0x00;
		}
	} else {
		container = getBackpack(user);
	}
	obj key = NULL();
	if (container == NULL()) {
		key = createGlobalObjectAt(key_type, user_loc);
		barkTo(user, user, "A ship's key is now at my feet.");
	} else {
		key = createGlobalObjectIn(key_type, container);
		if (bank) {
			barkTo(user, user, "A ship's key is now in my safety deposit box.");
		} else {
			barkTo(user, user, "A ship's key is now in my backpack.");
		}
	}
	if (key == NULL()) {
		barkTo(user, user, "Ack, a key could not be created!");
		return(0x00);
	}
	attachScript(key, "key");
	attachScript(key, "shipkey");
	list doors;
	if (hasObjVar(ship, "myhousedoors")) {
		getObjListVar(doors, ship, "myhousedoors");
	}
	obj door;
	int num_doors = numInList(doors);
	for (int i = 0x00; i < num_doors; i++) {
		door = doors[i];
		attach_lockable_to_key(door, key);
	}
	return(0x01);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	if (!check_deed_place_allowed(user, this)) {
		return(0x00);
	}
	int ship_type;
	if (getDistanceInTiles(place, getLocation(user)) > 0x06) {
		barkTo(user, user, "That location is too far away.");
		return(0x01);
	}
	if (!hasObjVar(this, "myshiptype")) {
		ship_type = 0x00;
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	placement_elev = 0x00 - 0x05;
	obj ship = create_ship_at(ship_type, place);
	if (ship == NULL()) {
		string error_msg = get_placement_error_msg(placement_elev, "ship", "water");
		barkTo(user, user, error_msg);
		return(0x01);
	}
	transferAllResources(ship, this);
	obj tillerman = NULL();
	if (hasObjVar(ship, "myshiptillerman")) {
		tillerman = getObjVar(ship, "myshiptillerman");
	}
	if (tillerman != NULL()) {
		setObjVar(tillerman, "creatorId", user);
		string creator_name = getName(user);
		setObjVar(tillerman, "creatorName", creator_name);
	}
	int key_result = create_ship_key(this, user, ship, 0x00);
	key_result = create_ship_key(this, user, ship, 0x01);
	deleteObject(this);
	return(0x01);
}

trigger use {
	if (!check_deed_place_allowed(user, this)) {
		return(0x00);
	}
	int ship_type;
	if (!hasObjVar(this, "myshiptype")) {
		ship_type = 0x00;
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	int multi = calc_multi_index(ship_type, 0x00);
	barkTo(user, user, "Where do you wish to place the ship?");
	targetlocmulti(user, this, multi, 0x00, 0x00, 0x00);
	return(0x01);
}

trigger creation {
	int ship_type = 0x00;
	if (!hasObjVar(this, "myshiptype")) {
		setObjVar(this, "myshiptype", ship_type);
	} else {
		ship_type = getObjVar(this, "myshiptype");
	}
	setObjVar(this, "mybasevalue", calc_ship_value(ship_type));
	return(0x01);
}

trigger canbuy {
	if (!getCompileFlag(0x02)) {
		return(0x01);
	}
	if (!check_deed_buy_allowed(buyer, this)) {
		return(0x00);
	}
	return(0x01);
}
