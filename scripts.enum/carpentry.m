inherits itemmanip;

member obj crafter;

member obj wood_source;

member int item_type;

member int wood_cost;

member int wood_qty;

member int placement_ready;

forward void select_chairs();

forward void select_tables();

forward void select_misc();

trigger use {
	if (hasObjVar(this, "inUse")) {
		systemMessage(user, "Someone else is using that.");
		return(0x00);
	} else {
		setObjVar(this, "inUse", 0x00);
		callback(this, 0x3C, 0x1B);
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
	placement_ready = 0x00;
	crafter = user;
	wood_source = usedon;
	int res_ok;
	res_ok = getResource(wood_qty, wood_source, "wood", 0x03, 0x02);
	int src_type = getObjType(wood_source);
	switch(src_type) {
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
			systemMessage(user, "You can't use that wood, it belongs to someone else.");
			return(0x00);
		}
		if (hasObjVar(wood_source, "inUse")) {
			barkTo(wood_source, crafter, "Someone is using that wood.");
			return(0x00);
		} else {
			setObjVar(wood_source, "inUse", 0x01);
			attachscript(wood_source, "removeinuse");
			callback(wood_source, 0x3C, 0x1B);
		}
		int skill_ok = testSkillReal(user, SKILL_CARPENTRY);
		if (skill_ok > 0x00) {
			list carpentry = 0x0B56, "chairs", 0x0B7C, "tables", 0x0E42, "miscellaneous";
			selectType(crafter, this, 0x04, "choose a category", carpentry);
		} else {
			systemMessage(user, "Carpentry failed.");
			if (hasObjVar(wood_source, "inUse")) {
				removeObjVar(wood_source, "inUse")}
			if (hasObjVar(this, "inUse")) {
				removeObjVar(this, "inUse");
			}
			return(0x00);
		}
		break;
	default
		barkTo(wood_source, crafter, "can't make anything from that");
		break;
	}
	return(0x00);
}

trigger typeselected(0x04) {
	switch(listindex) {
	case 0x01
		select_chairs();
		break;
	case 0x02
		select_tables();
		break;
	case 0x03
		select_misc();
		break;
	default
		if (hasObjVar(wood_source, "inUse")) {
			removeObjVar(wood_source, "inUse")}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (hasObjVar(wood_source, "inUse")) {
		removeObjVar(wood_source, "inUse")}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}

function void select_chairs() {
	list chairs = 0x0B5E, "stool takes 9 wood", 0x0A2A, "stool takes 9 wood", 0x0B5A, "chair takes 13 wood", 0x0B56, "chair takes 13 wood", 0x0B4E, "chair takes 15 wood", 0x0B52, "chair takes 15 wood", 0x0B2C, "bench takes 17 wood", 0x0B2F, "chair takes 17 wood", 0x0B33, "throne takes 19 wood";
	selectType(crafter, this, 0x05, "choose a chair", chairs);
	return();
}

function void select_tables() {
	list tables = 0x0B34, "table takes 17 wood", 0x0B4A, "writing table takes 17 wood", 0x0B7C, "table takes 23 wood", 0x0B7D, "table takes 27 wood";
	selectType(crafter, this, 0x06, "choose a table", tables);
	return();
}

function void select_misc() {
	list items = 0x1B7A, "wooden shield takes 9 wood"0x0E7D, "box takes 9 wood", 0x0E7E, "small crate takes 9 wood", 0x0E3E, "crate takes 11 wood", 0x0E3C, "crate takes 13 wood", 0x0E42, "chest takes 15 wood", 0x0A9E, "shelf takes 21 wood", 0x0A51, "armoire takes 25 wood", 0x0A53, "armoire takes 25 wood";
	selectType(crafter, this, 0x07, "choose an item", items);
	return();
}

trigger typeselected(0x05) {
	item_type = objtype;
	switch(objtype) {
	case 0x0B5E
	case 0x0A2A
		wood_cost = 0x08;
		break;
	case 0x0B5A
	case 0x0B56
		wood_cost = 0x0C;
		break;
	case 0x0B4E
	case 0x0B52
		wood_cost = 0x0E;
		break;
	case 0x0B2C
	case 0x0B2F
		wood_cost = 0x10;
		break;
	case 0x0B33
		wood_cost = 0x12;
		break;
	default
		if (hasObjVar(wood_source, "inUse")) {
			removeObjVar(wood_source, "inUse")}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (wood_cost + 0x01 > wood_qty) {
		barkTo(wood_source, crafter, "Not enough wood to make that.");
		select_chairs();
		return(0x00);
	}
	placement_ready = 0x01;
	sfx(getLocation(this), 0x023D, 0x00);
	systemMessage(crafter, "Put it where?");
	targetLoc(crafter, this);
	return(0x00);
}

trigger typeselected(0x06) {
	item_type = objtype;
	switch(objtype) {
	case 0x0B34
	case 0x0B4A
		wood_cost = 0x10;
		break;
	case 0x0B7C
		wood_cost = 0x16;
		break;
	case 0x0B7D
		wood_cost = 0x1A;
		break;
	default
		if (hasObjVar(wood_source, "inUse")) {
			removeObjVar(wood_source, "inUse")}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (wood_cost + 0x01 > wood_qty) {
		barkTo(wood_source, crafter, "Not enough wood to make that.");
		select_tables();
		return(0x00);
	}
	placement_ready = 0x01;
	sfx(getLocation(this), 0x023D, 0x00);
	systemMessage(crafter, "Put it where?");
	targetLoc(crafter, this);
	return(0x00);
}

trigger typeselected(0x07) {
	item_type = objtype;
	switch(objtype) {
	case 0x1B7A
	case 0x0E7D
	case 0x0E7E
		wood_cost = 0x08;
		break;
	case 0x0E3E
		wood_cost = 0x0A;
		break;
	case 0x0E3C
		wood_cost = 0x0C;
		break;
	case 0x0E42
		wood_cost = 0x0E;
		break;
	case 0x0A9E
		wood_cost = 0x14;
		break;
	case 0x0A51
	case 0x0A53
		wood_cost = 0x18;
		break;
	default
		if (hasObjVar(wood_source, "inUse")) {
			removeObjVar(wood_source, "inUse")}
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
		break;
	}
	if (wood_cost + 0x01 > wood_qty) {
		barkTo(wood_source, crafter, "Not enough wood to make that.");
		select_misc();
		return(0x00);
	}
	placement_ready = 0x01;
	sfx(getLocation(this), 0x023D, 0x00);
	systemMessage(crafter, "Put it where?");
	targetLoc(crafter, this);
	return(0x00);
}

trigger targetloc {
	if (!isInMap(place)) {
		if (hasObjVar(this, "inUse")) {
			removeObjVar(this, "inUse");
		}
		return(0x00);
	}
	if (placement_ready) {
		placement_ready = 0x00;
		debugMessage("before canExistAt");
		if (canExistAt(place, getTileHeight(item_type), 0x00) != 0x07) {
			debugMessage("inside canExistAt");
			systemMessage(user, "You cannot create that there.");
			return(0x00);
		}
		if (getDistanceInTiles(place, getLocation(user)) > 0x03) {
			systemMessage(user, "That is too far away.");
			return(0x00);
		}
		int avail_wood = 0x00;
		int ret = getResource(avail_wood, wood_source, "wood", 0x03, 0x02);
		if (avail_wood < (wood_cost + 0x01)) {
			systemMessage(user, "You don't have enough wood to make that.");
			return(0x00);
		}
		obj item = createNoResObjectAt(item_type, place);
		transferResources(item, wood_source, wood_cost, "wood");
		setObjVar(item, "chopable", 0x01);
		switch(item_type) {
		case 0x0E7D
		case 0x0E7E
			overloadWeight(item, 0x01);
			break;
		case 0x0B5E
		case 0x0A2A
		case 0x0B5A
		case 0x0B56
		case 0x0B4E
		case 0x0B52
		case 0x0B2F
		case 0x0B33
			overloadWeight(item, 0x01);
			break;
		case 0x0B2C
		case 0x0B34
		case 0x0B4A
		case 0x0B7C
		case 0x0B7D
			overloadWeight(item, 0x01);
			break;
		case 0x0E3E
		case 0x0E3C
		case 0x0E42
		case 0x0A9E
		case 0x0A51
		case 0x0A53
			overloadWeight(item, 0x01);
			break;
		default
			break;
		}
		switch(item_type) {
		case 0x0E7D
		case 0x0E42
			if (testSkill(user, SKILL_TINKERING)) {
				int tinker_skill = getSkillLevel(user, SKILL_TINKERING);
				systemMessage(user, "Your tinker skill was sufficient to make the item lockable.");
				attachScript(item, "locked");
				setObjVar(item, "lockLevel", (tinker_skill * 0x02));
				setObjVar(item, "playerMade", 0x01);
				obj key = createNoResObjectIn(0x100E, item);
				list unlock_list = item;
				setObjVar(key, "whatIUnlock", unlock_list);
			}
		}
		obj kindling = createNoResObjectAt(0x0DE1, place);
		transferResources(kindling, wood_source, 0x01, "wood");
		int remaining_wood;
		ret = getResource(remaining_wood, wood_source, "wood", 0x03, 0x02);
		if (remaining_wood < 0x01) {
			deleteObject(wood_source);
		}
	}
	if (hasObjVar(wood_source, "inUse")) {
		removeObjVar(wood_source, "inUse")}
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	if (drain_tool_life(user, this)) {
		deleteObject(this);
	}
	return(0x00);
}

trigger callback(0x1B) {
	if (hasObjVar(this, "inUse")) {
		removeObjVar(this, "inUse");
	}
	return(0x00);
}
