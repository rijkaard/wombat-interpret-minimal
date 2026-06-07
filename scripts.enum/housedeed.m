inherits housestuff;

function void setup_extras(obj house, loc place) {
	return();
}

function obj place_house_from_deed(obj deed, obj user, loc place) {
	int house_type;
	if (!isHousingOkay(place, 0x01)) {
		barkTo(user, user, "Housing can not be created in this area.");
		return(NULL());
	}
	if (!hasObjVar(deed, "myhousetype")) {
		house_type = 0x00;
	} else {
		house_type = getobjvar_int(deed, "myhousetype");
	}
	loc adjusted_loc = adjust_placement_loc(house_type, place);
	placement_z_offset = (0x00 - 0x07);
	obj house = place_house(house_type, adjusted_loc);
	if (house == NULL()) {
		string error_msg = get_placement_error_msg(placement_z_offset, "house", "valid terrain");
		barkTo(user, user, error_msg);
		return(house);
	}
	setup_extras(house, adjusted_loc);
	setObjVar(house, "mydeed", deed);
	return(house);
}

function int create_and_assign_key(obj user, obj house, obj door, obj sign, int bank) {
	loc user_loc = getLocation(user);
	loc door_loc = getLocation(door);
	moveDir(door_loc, DIR_SOUTH);
	list key_types = 0x100E, 0x100F, 0x1010, 0x1013;
	int num = random(0x00, (numInList(key_types) - 0x01));
	int key_type = key_types[num];
	obj key = NULL();
	obj container = NULL();
	if (bank) {
		fixBank(user);
		container = getItemAtSlot(user, EQUIP_BANK);
		if (container == NULL()) {
			container = getBackpack(user);
			bank = 0x00;
		}
	} else {
		container = getBackpack(user);
	}
	if (container == NULL()) {
		key = createGlobalObjectAt(key_type, user_loc);
		barkTo(user, user, "A house key is now at my feet.");
	} else {
		key = createGlobalObjectIn(key_type, container);
		if (bank) {
			barkTo(user, user, "A house key is now in my safety deposit box.");
		} else {
			barkTo(user, user, "A house key is now in my backpack.");
		}
	}
	if (key == NULL()) {
		bark(user, "Ack, a key could not be created!");
		deleteObject(house);
		return(0x00);
	}
	attachScript(key, "key");
	list doors;
	if (hasObjVar(house, "myhousedoors")) {
		getObjListVar(doors, house, "myhousedoors");
	}
	int count = numInList(doors);
	for (int i = 0x00; i < count; i++) {
		door = doors[i];
		attach_lockable_to_key(door, key);
	}
	if (sign != NULL()) {
		attach_lockable_to_key(sign, key);
	}
	attachScript(key, "housekey");
	return(0x01);
}

function int initialize_placed_house(obj house, obj deed, obj user) {
	transferAllResources(house, deed);
	reset_decay(house);
	obj door = NULL();
	if (hasObjVar(house, "myhousedoor")) {
		door = getobjvar_obj(house, "myhousedoor");
	}
	obj sign = NULL();
	if (hasObjVar(house, "myhousesign")) {
		sign = getobjvar_obj(house, "myhousesign");
	}
	string creator_name = getName(user);
	if (sign != NULL()) {
		setObjVar(sign, "creatorId", user);
		setObjVar(sign, "creatorName", creator_name);
	} else {
		setObjVar(house, "creatorId", user);
		setObjVar(house, "creatorName", creator_name);
	}
	int key_result = create_and_assign_key(user, house, door, sign, 0x00);
	key_result = create_and_assign_key(user, house, door, sign, 0x01);
	if (house != NULL()) {
		deleteObject(deed);
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
	obj house = place_house_from_deed(this, user, place);
	if (house != NULL()) {
		int result = initialize_placed_house(house, this, user);
	}
	return(0x01);
}

trigger use {
	if (!check_deed_place_allowed(user, this)) {
		return(0x00);
	}
	int house_type;
	if (!hasObjVar(this, "myhousetype")) {
		house_type = 0x00;
	} else {
		house_type = getobjvar_int(this, "myhousetype");
	}
	loc min_extent;
	loc max_extent;
	int lock_obj = get_multi_type_id(house_type, 0x00);
	int y_offset = 0x00;
	if (getMultiExtents(lock_obj, min_extent, max_extent)) {
		y_offset = getY(max_extent);
	}
	barkTo(user, user, "Where do you wish to build the house?");
	targetlocmulti(user, this, lock_obj, 0x00, y_offset, 0x00);
	return(0x01);
}

trigger creation {
	int house_type = 0x00;
	if (!hasObjVar(this, "myhousetype")) {
		setObjVar(this, "myhousetype", house_type);
	} else {
		house_type = getobjvar_int(this, "myhousetype");
	}
	setObjVar(this, "mybasevalue", get_house_base_value(house_type));
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
