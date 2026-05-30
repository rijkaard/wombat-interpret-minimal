inherits housestuff;

member obj crafter;

member obj material_obj;

member int material_type;

member int item_type;

member int material_amount;

member int material_cost;

member int is_metal;

member int craft_ready;

member int trap_mode;

member int trap_type;

forward void craft_item();

function int wear_tool(obj user, obj tool) {
	if (hasObjVar(tool, "lifeRemaining")) {
		int lifeRemaining = getObjVar(tool, "lifeRemaining");
		if (lifeRemaining > 0x01) {
			setObjVar(tool, "lifeRemaining", (lifeRemaining - 0x01));
		} else {
			string name = getNameByType(getObjType(this));
			systemMessage(user, "You destroyed the " + name + ".");
			return(0x01);
		}
	} else {
		setObjVar(tool, "lifeRemaining", 0x32);
	}
	return(0x00);
}

function void place_item(obj user_obj, obj item, string msg) {
	obj pack = getBackpack(user_obj);
	string full_msg = msg;
	if (isValid(pack) && canHold(pack, item)) {
		concat(full_msg, " in your backpack.");
		int result = putObjContainer(item, pack);
	} else {
		concat(full_msg, " at your feet.");
	}
	systemMessage(user_obj, full_msg);
	return();
}

trigger creation {
	trap_mode = 0x00;
	trap_type = 0x00;
	return(0x00);
}

trigger use {
	int obj_type = getObjType(this);
	if (obj_type != 0x1EBC) {
		if (isAtHome(this)) {
			systemMessage(user, "You can't use that, it belongs to someone else.");
			return(0x00);
		}
	}
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone else is using that");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x00);
		callback(this, 0x1E, 0x1B);
	}
	loc tool_loc = getLocation(this);
	obj new_item;
	int new_type;
	switch(obj_type) {
	case 0x1059
	case 0x105A
		new_type = random(0x00, 0x01) + 0x1057;
		new_item = createNoResObjectAt(new_type, getLocation(user));
		place_item(user, new_item, "You assemble the parts, and put the sextant");
		destroyOne(this);
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	case 0x1053
	case 0x1054
		systemMessage(user, "Use that on an axle to make an axle with gears.");
		break;
	case 0x105D
	case 0x105E
		systemMessage(user, "Use that on an axle with gears to make clock parts.");
		break;
	case 0x1055
	case 0x1056
		systemMessage(user, "Use that on an axle with gears to make sextant parts.");
		break;
	case 0x105B
	case 0x105C
		systemMessage(user, "Use that on gears to make an axle with gears.");
		break;
	case 0x104D
	case 0x104E
		systemMessage(user, "Use that on clock parts to make a clock.");
		break;
	case 0x1051
	case 0x1052
		systemMessage(user, "Use that on springs to make clock parts, or a hinge to make sextant parts.");
		break;
	case 0x104F
	case 0x1050
		systemMessage(user, "Use that on a clock frame to make a clock.");
		break;
	}
	targetObj(user, this);
	return(0x01);
}

trigger targetobj {
	if (usedon == NULL()) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	if (!isFreelyUsable(usedon, user)) {
		systemMessage(user, "That is inacessable.");
		return(0x00);
	}
	if (trap_mode) {
		trap_mode = 0x00;
		if (trap_type == 0x00) {
			systemMessage(user, "BUG!");
			return(0x00);
		}
		if (hasObjVar(usedon, "isLocked")) {
			int lock = getObjVar(usedon, "isLocked");
			if (lock) {
				systemMessage(user, "You can only trap an unlocked object.");
				return(0x00);
			}
		}
		if (hasObjVar(usedon, "trapLevel")) {
			systemMessage(user, "You can only place one trap on an object at a time.");
			return(0x00);
		}
		int targetType = getObjType(usedon);
		if (isAtHome(usedon)) {
			systemMessage(user, "That belongs to someone else.");
			return(0x00);
		}
		switch(targetType) {
		case 0x0E7C
		case 0x09AB
		case 0x0E40
		case 0x0E41
		case 0x0E42
		case 0x0E43
		case 0x09AA
		case 0x0E7D
		case 0x0E80
		case 0x09A8
			int trap_level = getSkillLevelRealStat(user, 0x25);
			trap_level = trap_level / 0x64;
			int ingot_count = getGeneric(user, 0x1BF2);
			if (ingot_count < 0x01) {
				systemMessage(user, "You need an ingot to make a trap.");
				break;
			}
			switch(trap_type) {
			case 0x01
				int bolt_count = getGeneric(user, 0x1BFB);
				if (bolt_count < 0x01) {
					systemMessage(user, "You need a crossbow bolt to make that trap!");
					break;
				}
				destroyGeneric(user, 0x1BFB, 0x01);
				destroyGeneric(user, 0x1BF2, 0x01);
				attachScript(usedon, "trap_dart");
				systemMessage(user, "You carefully place a dart trap on " + getName(usedon) + ".");
				break;
			case 0x02
				obj purple_potion = mobileContainsObjType(user, 0x0F0D);
				if (purple_potion == NULL()) {
					systemMessage(user, "You need a purple potion to make that trap!");
					break;
				}
				deleteObject(purple_potion);
				destroyGeneric(user, 0x1BF2, 0x01);
				attachScript(usedon, "trap_explosion");
				systemMessage(user, "You carefully place an explosion trap on " + getName(usedon) + ".");
				break;
			case 0x03
				obj green_potion = mobileContainsObjType(user, 0x0F0A);
				if (green_potion == NULL()) {
					systemMessage(user, "You need a green potion to make that trap!");
					break;
				}
				deleteObject(green_potion);
				destroyGeneric(user, 0x1BF2, 0x01);
				attachScript(usedon, "trap_poison");
				systemMessage(user, "You carefully place a poison trap on " + getName(usedon) + ".");
				break;
			}
			setObjVar(usedon, "trapLevel", trap_level);
			obj house = isAnyMultiBelow(getLocation(usedon));
			int has_key = 0x00;
			if (house != NULL()) {
				if (mobile_owns_house(house, user)) {
					has_key = 0x01;
				}
			}
			if (!has_key) {
				copyControllerInfo(usedon, user);
			}
			break;
		default
			systemMessage(user, "You cannot place a trap on that.");
		}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	craft_ready = 0x00;
	crafter = user;
	material_obj = usedon;
	material_type = getObjType(usedon);
	int tool_type = getObjType(this);
	int resource_result;
	int result_type = 0x00;
	loc usedon_loc = getLocation(usedon);
	obj new_obj;
	string description;
	switch(tool_type) {
	case 0x1053
	case 0x1054
		switch(material_type) {
		case 0x105B
		case 0x105C
			result_type = 0x1051;
			description = "an axle with gears and put it";
		}
		break;
	case 0x105D
	case 0x105E
		switch(material_type) {
		case 0x1051
		case 0x1052
			result_type = 0x104F;
			description = "some clock parts and put them";
		}
		break;
	case 0x1055
	case 0x1056
		switch(material_type) {
		case 0x1051
		case 0x1052
			result_type = 0x1059;
			description = "some sextant parts and put them";
		}
		break;
	case 0x105B
	case 0x105C
		switch(material_type) {
		case 0x1053
		case 0x1054
			result_type = 0x1051;
			description = "an axle with gears and put it";
		}
		break;
	case 0x104D
	case 0x104E
		switch(material_type) {
		case 0x104F
		case 0x1050
			result_type = random(0x00, 0x01) + 0x104B;
			description = "a clock and put it";
		}
		break;
	case 0x1051
	case 0x1052
		switch(material_type) {
		case 0x1055
		case 0x1056
			result_type = 0x1059;
			description = "some sextant parts and put them";
			break;
		case 0x105D
		case 0x105E
			result_type = 0x104F;
			description = "some clock parts and put them";
			break;
		}
		break;
	case 0x104F
	case 0x1050
		switch(material_type) {
		case 0x104D
		case 0x104E
			result_type = random(0x00, 0x01) + 0x104B;
			description = "a clock and put it";
		}
		break;
	case 0x1EBC
		switch(material_type) {
		case 0x1BEF
		case 0x1BF0
		case 0x1BF1
		case 0x1BF2
		case 0x1BF3
		case 0x1BF4
			if (isAtHome(usedon)) {
				systemMessage(user, "That metal belongs to someone else.");
				if (hasObjVar(this, "inUse")) {
					removeObjVar(this, "inUse");
				}
				return(0x00);
			}
			if (hasObjVar(material_obj, "inUse")) {
				barkTo(this, user, "Someone is using that metal.");
				return(0x00);
			}
			if (testSkill(user, 0x25)) {
				is_metal = 0x01;
				resource_result = getResource(material_amount, usedon, "metal", 0x03, 0x02);
				list craft_options = 0x112D, "Dart Trap", 0x10F8, "Explosion Trap", 0x1148, "Poison Trap", 0x0F9D, 0x1053, 0x105D, 0x1055, 0x10E4, 0x10E5, 0x10E6, 0x10E7, 0x13F6, 0x0F9E, 0x0FBC, 0x1028, 0x1034, 0x102A, 0x13E4, 0x0FB5, 0x0F3A;
				selectType(crafter, this, 0x18, "Choose an item.", craft_options);
			} else {
				systemMessage(user, "Tinkering failed.");
				if (hasObjVar(this, "inUse")) {
					removeObjVar(this, "inUse");
				}
				return(0x00);
			}
			break;
		case 0x1BD7
		case 0x1BD8
		case 0x1BD9
		case 0x1BDA
		case 0x1BDB
		case 0x1BDC
		case 0x1BDD
		case 0x1BDE
		case 0x1BDF
		case 0x1BE0
		case 0x1BE1
		case 0x1BE2
			if (isAtHome(usedon)) {
				systemMessage(user, "That wood belongs to someone else.");
				if (hasObjVar(this, "inUse")) {
					removeObjVar(this, "inUse");
				}
				return(0x00);
			}
			if (testSkill(user, 0x25)) {
				resource_result = getResource(material_amount, usedon, "wood", 0x03, 0x02);
				list wood = 0x105B, 0x102C, 0x1032, 0x1030, 0x104D;
				selectType(crafter, this, 0x19, "Choose an item.", wood);
			} else {
				systemMessage(user, "Tinkering failed.");
				if (hasObjVar(this, "inUse")) {
					removeObjVar(this, "inUse");
				}
				return(0x00);
			}
			break;
		default
			systemMessage(user, "Use raw material.");
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			break;
		}
	}
	if (result_type != 0x00) {
		destroyOne(usedon);
		if (hasObjVar(usedon, "inUse")) {
			removeObjVar(usedon, "inUse");
		}
		new_obj = requestCreateObjectAt(result_type, getLocation(user));
		place_item(user, new_obj, "You create " + description);
		destroyOne(this);
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	return(0x00);
}

trigger typeselected(0x18) {
	item_type = objtype;
	switch(objtype) {
	case 0x112D
	case 0x10F8
	case 0x1148
		systemMessage(crafter, "What would you like to set a trap on?");
		trap_mode = 0x01;
		trap_type = listindex;
		targetObj(crafter, this);
		return(0x00);
		break;
	case 0x0F9D
	case 0x1053
	case 0x105D
	case 0x1055
	case 0x10E4
	case 0x10E5
	case 0x10E6
	case 0x10E7
	case 0x13F6
		material_cost = 0x02;
		break;
	case 0x0F9E
	case 0x0FBC
	case 0x1028
	case 0x1034
	case 0x102A
	case 0x13E4
	case 0x0FB5
	case 0x0F3A
		material_cost = 0x04;
		break;
	default
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (!isFreelyUsable(material_obj, crafter)) {
		barkTo(material_obj, crafter, "You can no longer access the metal.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	int resource_result = getResource(material_amount, material_obj, "metal", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough metal to make this.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	craft_ready = 0x01;
	if (objtype != 0x00) {
		craft_item();
	}
	return(0x00);
}

trigger typeselected(0x19) {
	item_type = objtype;
	switch(objtype) {
	case 0x105B
		material_cost = 0x02;
		break;
	case 0x102C
	case 0x1032
	case 0x1030
		material_cost = 0x04;
		break;
	case 0x104D
		material_cost = 0x06;
		break;
	default
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (!isFreelyUsable(material_obj, crafter)) {
		barkTo(material_obj, crafter, "You can no longer access the wood.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	int resource_result = getResource(material_amount, material_obj, "wood", 0x03, 0x02);
	if (material_cost > material_amount) {
		barkTo(material_obj, crafter, "There's not enough wood to make this.");
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	craft_ready = 0x01;
	if (objtype != 0x00) {
		craft_item();
	}
	return(0x00);
}

function void craft_item() {
	craft_ready = 0x00;
	obj new_item;
	list resource_list;
	int remaining;
	int count;
	int resource_result;
	obj backpack = getBackpack(crafter);
	string name;
	string item_pronoun = "it";
	if (is_metal) {
		is_metal = 0x00;
		new_item = createNoResObjectAt(item_type, getLocation(crafter));
		transferResources(new_item, material_obj, material_cost, "metal");
		name = getName(new_item);
		switch(item_type) {
		case 0x1053
		case 0x105D
		case 0x0F9E
		case 0x0FBC
			item_pronoun = "them";
			break;
		default
			break;
		}
		place_item(crafter, new_item, "You create " + name + " and put " + item_pronoun);
		resource_result = getResource(remaining, material_obj, "metal", 0x03, 0x02);
	} else {
		new_item = createNoResObjectAt(item_type, getLocation(crafter));
		transferResources(new_item, material_obj, material_cost, "wood");
		name = getName(new_item);
		place_item(crafter, new_item, "You create " + name + " and put it");
		resource_result = getResource(remaining, material_obj, "wood", 0x03, 0x02);
	}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	if (remaining < 0x01) {
		deleteObject(material_obj);
	}
	if (wear_tool(crafter, this)) {
		deleteObject(this);
	}
	return();
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}
