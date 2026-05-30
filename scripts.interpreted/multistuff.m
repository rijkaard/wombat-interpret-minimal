inherits add_door_to_key;

function int mobile_owns_house(obj house, obj mobile) {
	obj door = NULL();
	if (hasObjVar(house, "myhousedoor")) {
		door = getObjVar(house, "myhousedoor");
	}
	if (door == NULL()) {
		if (hasObjListVar(house, "myhousedoors")) {
			list doors;
			getObjListVar(doors, house, "myhousedoors");
			if (numInList(doors) > 0x00) {
				door = doors[0x00];
			}
		}
	}
	if (door == NULL()) {
		return(0x00);
	}
	obj key = mobileHasObjWithListObjOfObj(mobile, "whatIUnlock", door);
	if (key == NULL()) {
		return(0x00);
	}
	return(0x01);
}

function int has_house_key(obj house, obj mobile) {
	return(mobile_owns_house(house, mobile));
}

function string get_placement_error_msg(int num, string name, string terrain) {
	string msg = "A ";
	concat(msg, name);
	concat(msg, " can not be created here.");
	if (num == (0x00 - 0x09)) {
		msg = "A ";
		concat(msg, name);
		concat(msg, " can not be created here.  A living creature is blocking the ");
		concat(msg, name);
		concat(msg, ".");
		return(msg);
	}
	if (num == (0x00 - 0x05)) {
		msg = "A ";
		concat(msg, name);
		concat(msg, " can not be created here.  Either something is blocking the ");
		concat(msg, name);
		concat(msg, " or part of the ");
		concat(msg, name);
		concat(msg, " would not be on ");
		concat(msg, terrain);
		concat(msg, ".");
		return(msg);
	}
	if (num <= (0x00 - 0x02)) {
		msg = "An internal error occured.  Please notify a game master that you received this message.");
		return(msg);
	}
	if (num == (0x00 - 0x01)) {
		msg = "A ";
		concat(msg, name);
		concat(msg, " can not be created here.");
		return(msg);
	}
	if (num == 0x00) {
		msg = "A ";
		concat(msg, name);
		concat(msg, " can not be created here.  Either something is blocking the ");
		concat(msg, name);
		concat(msg, " or part of the ");
		concat(msg, name);
		concat(msg, " would not be on ");
		concat(msg, terrain);
		concat(msg, ".");
		return(msg);
	}
	if (num > 0x00) {
		msg = "";
		return(msg);
	}
	return(msg);
}

function void reset_decay(obj multi) {
	if (getDecayMax(multi) == 0xFFFF) {
		return;
	}
	int prev_count = setDecayCount(multi, 0x00);
	setObjVar(multi, "decayvisits", 0x00);
	return;
}

function int is_decayed(obj multi) {
	int decay_count = getDecayCount(multi);
	if (decay_count > 0x00) {
		return(0x01);
	}
	return(0x00);
}

function int reset_decay_if_active(obj me) {
	obj multi = getMultiSlaveId(me);
	int decay_count = getDecayCount(multi);
	if (getDecayMax(multi) == 0xFFFF) {
		resetMultiCarriedDecay(multi);
		return(0x00);
	}
	if (decay_count > 0x00) {
		reset_decay(multi);
		resetMultiCarriedDecay(multi);
		return(0x01);
	}
	return(0x00);
}

function int has_name(obj multi) {
	return(hasObjVar(multi, "mymultiname"));
}

function string get_custom_multi_name(obj multi) {
	string name = getObjVar(multi, "mymultiname");
	return(name);
}

function void set_name(obj multi, string name) {
	setObjVar(multi, "mymultiname", name);
	return;
}

function void clear_name(obj multi) {
	removeObjVar(multi, "mymultiname");
	return;
}

function int refresh_decay_if_key_holder(obj house, obj mobile, string name) {
	if (has_house_key(house, mobile)) {
		if (reset_decay_if_active(house)) {
			string msg = "Your ";
			concat(msg, name);
			concat(msg, "'s age and its contents have been refreshed.");
			systemMessage(mobile, msg);
			string time_str;
			getCurrentTimeStr(time_str);
			setObjVar(house, "refreshtime", time_str);
			return(0x01);
		}
	}
	return(0x00);
}

function int refresh_decay_for_key_holders(obj house, list mobiles, string type_name) {
	int count = numInList(mobiles);
	obj mobile;
	for (int i = 0x00; i < count; i++) {
		mobile = mobiles[i];
		if (refresh_decay_if_key_holder(house, mobile, type_name)) {
			return(0x01);
		}
	}
	return(0x00);
}

function void try_refresh_decay_on_use(obj me, obj mobile, string type_name) {
	obj multi = getMultiSlaveId(me);
	if (is_decayed(multi)) {
		int refreshed = refresh_decay_if_key_holder(multi, mobile, type_name);
	}
	return();
}

function void bark_decay_status(obj me, obj looker, string type_name) {
	string condition_str;
	obj multi = getMultiSlaveId(me);
	int decay_max = getDecayMax(multi);
	if (decay_max == 0xFFFF) {
		condition_str = " is ageless.";
	} else {
		int decay_count = getDecayCount(multi);
		if (decay_count == 0x00) {
			condition_str = " is like new.";
		} else {
			if (decay_count < (decay_max / 0x04)) {
				condition_str = " is slightly worn.";
			} else {
				if (decay_count < (0x02 * decay_max / 0x04)) {
					condition_str = " is somewhat worn.";
				} else {
					if (decay_count < (0x03 * decay_max / 0x04)) {
						condition_str = " is fairly worn.";
					} else {
						if (decay_count < (0x13 * decay_max / 0x14)) {
							condition_str = " is greatly worn.";
						} else {
							condition_str = " is in danger of collapsing.";
						}
					}
				}
			}
		}
	}
	string msg = "This ";
	concat(msg, type_name);
	concat(msg, condition_str);
	barkTo(me, looker, msg);
	return();
}

function int reset_decay_if_mobs_nearby(obj multi) {
	list mobs;
	loc where = getLocation(multi);
	getMobsInRange(mobs, where, 0x07);
	int num = numInList(mobs);
	if (num > 0x00) {
		reset_decay_if_active(multi);
		return(0x01);
	}
	return(0x00);
}

function int get_structure_type(obj multi) {
	if (hasScript(multi, "housedecay")) {
		return(0x00);
	} else {
		if (hasScript(multi, "shipdecay")) {
			return(0x01);
		}
	}
	return(0x02);
}

function obj get_nearby_house_for_user(obj user, loc where) {
	list objs;
	getObjectsInRange(objs, where, 0x02);
	int num = numInList(objs);
	for (int i = 0x00; i < num; i++) {
		obj it = objs[i];
		if (isMultiComp(it)) {
			obj multi = getMultiSlaveId(it);
			if (get_structure_type(multi) == 0x00) {
				if (has_house_key(multi, user)) {
					return(multi);
				}
			}
		}
	}
	return(NULL());
}

function void add_vendor_to_house(obj house, obj it) {
	list vendors;
	if (hasObjListVar(house, "vendors")) {
		getObjListVar(vendors, house, "vendors");
	}
	appendToList(vendors, it);
	setObjVar(house, "vendors", vendors);
	return();
}

function int house_can_add_vendor(obj house) {
	list vendors;
	if (hasObjListVar(house, "vendors")) {
		getObjListVar(vendors, house, "vendors");
	}
	if (numInList(vendors) >= 0x01) {
		return(0x00);
	}
	return(0x01);
}

function void get_house_vendors(obj house, list vendors) {
	if (hasObjListVar(house, "vendors")) {
		getObjListVar(vendors, house, "vendors");
	}
	return();
}

function void remove_vendor_from_house(obj house, obj vendor) {
	if (hasObjListVar(house, "vendors")) {
		list vendors;
		getObjListVar(vendors, house, "vendors");
		removeSpecificItem(vendors, vendor);
		if (numInList(vendors) > 0x00) {
			setObjVar(house, "vendors", vendors);
		} else {
			removeObjVar(house, "vendors");
		}
	}
	return();
}

function void evict_vendors_on_decay(obj house) {
	list vendors;
	get_house_vendors(house, vendors);
	obj vendor;
	int num = numInList(vendors);
	for (int i = 0x00; i < num; i++) {
		vendor = vendors[i];
		if (isValid(vendor)) {
			list args;
			appendToList(args, house);
			message(vendor, "housedecay", args);
		}
	}
	removeObjVar(house, "vendors");
	return();
}

function void clear_guildstone(obj multi) {
	removeObjVar(multi, "guildstone");
	return();
}

function void set_guildstone(obj multi, obj guildstone) {
	setObjVar(multi, "guildstone", guildstone);
	return();
}

function int has_guildstone(obj multi) {
	return(hasObjVar(multi, "guildstone"));
}

function obj get_guildstone(obj multi) {
	obj guildstone = NULL();
	if (hasObjVar(multi, "guildstone")) {
		guildstone = getObjVar(multi, "guildstone");
	}
	return(guildstone);
}

function int try_set_guildstone(obj multi, obj guildstone) {
	if (has_guildstone(multi)) {
		return(0x00);
	}
	set_guildstone(multi, guildstone);
	return(0x01);
}

function int get_ship_type(obj deed) {
	if (!hasObjVar(deed, "myshiptype")) {
		return(0x00 - 0x01);
	}
	return(getobjvar_int(deed, "myshiptype"));
}

function int get_house_type(obj deed) {
	if (!hasObjVar(deed, "myhousetype")) {
		return(0x00 - 0x01);
	}
	return(getobjvar_int(deed, "myhousetype"));
}

function int meets_fame_requirement(obj user_obj, int required_level) {
	if (getFameLevel(user_obj) < required_level) {
		return(0x00);
	}
	return(0x01);
}

function int check_house_fame_requirement(obj mobile, int house_type) {
	int required_level = 0x00;
	switch(house_type) {
	case 0x00
	case 0x01
	case 0x02
	case 0x03
	case 0x04
	case 0x05
	case 0x14
		required_level = 0x02;
		break;
	case 0x06
	case 0x07
		required_level = 0x01;
		break;
	case 0x08
	case 0x09
	case 0x0A
		required_level = 0x03;
		break;
	case 0x0B
	case 0x0C
	case 0x0D
		required_level = 0x04;
		break;
	}
	return(meets_fame_requirement(mobile, required_level));
}

function int check_ship_fame_requirement(obj mobile, int ship_type) {
	int required_level = 0x00;
	switch(ship_type) {
	case 0x00
	case 0x01
		required_level = 0x02;
		break;
	case 0x02
	case 0x03
		required_level = 0x03;
		break;
	case 0x04
	case 0x05
		required_level = 0x04;
		break;
	}
	return(meets_fame_requirement(mobile, required_level));
}

function int check_fame_for_deed(obj mobile, obj deed) {
	int type = get_house_type(deed);
	if (type >= 0x00) {
		return(check_house_fame_requirement(mobile, type));
	} else {
		type = get_ship_type(deed);
		if (type >= 0x00) {
			return(check_ship_fame_requirement(mobile, type));
		}
	}
	return(0x01);
}

function int get_multi_category(obj deed) {
	int type = get_house_type(deed);
	if (type >= 0x00) {
		return(0x00);
	} else {
		type = get_ship_type(deed);
		if (type >= 0x00) {
			return(0x01);
		}
	}
	return(0x02);
}

function void set_owner(obj multi, obj user_obj) {
	return();
}

function obj get_owner(obj multi) {
	return(NULL());
}

function void register_with_owner(obj user_obj, obj multi) {
	return();
}

function void unregister_from_owner(obj user_obj, obj multi) {
	return();
}

function obj get_owned_ship(obj user_obj) {
	return(NULL());
}

function obj get_owned_house(obj user_obj) {
	return(NULL());
}

function obj get_owned_multi_by_type(obj user_obj, int type) {
	switch(type) {
	case 0x00
		return(get_owned_house(user_obj));
		break;
	case 0x01
		return(get_owned_ship(user_obj));
		break;
	}
	return(NULL());
}

function int can_own_multi_of_type(obj user_obj, int type) {
	obj multi = get_owned_multi_by_type(user_obj, type);
	if (multi != NULL()) {
		return(0x00);
	}
	return(0x01);
}

function int check_deed_buy_allowed(obj user, obj deed) {
	if (getCompileFlag(0x02)) {
		if (!check_fame_for_deed(user, deed)) {
			barkTo(deed, user, "You are not famous enough to buy this!");
			return(0x00);
		}
	}
	return(0x01);
}

function int check_deed_place_allowed(obj user, obj deed) {
	if (getCompileFlag(0x02)) {
		if (!check_fame_for_deed(user, deed)) {
			barkTo(deed, user, "You are not famous enough to build this!");
			return(0x00);
		}
		if (!can_own_multi_of_type(user, get_multi_category(deed))) {
			barkTo(deed, user, "You already own one of those!");
			return(0x00);
		}
	}
	return(0x01);
}
