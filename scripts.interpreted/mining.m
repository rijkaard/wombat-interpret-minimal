inherits itemmanip;

forward void prepare_mining_at(obj , loc );

trigger use {
	systemMessage(user, "Where do you wish to dig?");
	targetLoc(user, this);
	return(0x00);
}

trigger targetloc {
	if (!isInMap(place)) {
		return(0x00);
	}
	if (getDistanceInTiles(getLocation(user), place) > 0x04) {
		systemMessage(user, "That is too far away.");
		return(0x00);
	}
	if (objtype == 0x00) {
		int tile_type = getTileAt(place);
		if (is_minable_tile(tile_type)) {
			prepare_mining_at(user, place);
		} else {
			systemMessage(user, "You can't mine there.");
		}
	} else {
		if (is_minable_object(objtype)) {
			prepare_mining_at(user, place);
		} else {
			systemMessage(user, "You can't mine that.");
		}
	}
	return(0x00);
}

function void start_mine_animation(obj user) {
	if (getItemAtSlot(user, 0x19) != NULL()) {
		systemMessage(user, "You can't mine while riding.");
		return();
	}
	if (getObjType(user) < 0x0190) {
		systemMessage(user, "You can't mine while polymorphed.");
		return();
	}
	animateMobile(user, 0x0B, 0x14, 0x01, 0x00, 0x00);
	shortCallback(this, 0x04, 0x73);
	return();
}

function void prepare_mining_at(obj user, loc place) {
	obj chunk_egg = getChunkEgg(place);
	int metal_amount = 0x00;
	int ok = getResource(metal_amount, chunk_egg, "metal", 0x03, 0x02);
	if (metal_amount <= 0x00) {
		systemMessage(user, "There is no metal here to mine.");
		return();
	}
	setObjVar(this, "user", user);
	setObjVar(this, "mineLoc", place);
	removeCallback(this, 0x72);
	removeCallback(this, 0x73);
	start_mine_animation(user);
	return();
}

trigger callback(0x73) {
	obj user = getObjVar(this, "user");
	sfx(getLocation(user), 0x0125, 0x00);
	if (getDistanceInTiles(getLocation(user), getObjVar(this, "mineLoc")) > 0x04) {
		systemMessage(user, "You have moved too far away to continue mining.");
	} else {
		shortCallback(this, 0x04, 0x72);
	}
	return(0x00);
}

trigger callback(0x72) {
	obj user = getObjVar(this, "user");
	obj chunk_egg = getChunkEgg(getObjVar(this, "mineLoc"));
	int metal_amount = 0x00;
	int ok = getResource(metal_amount, chunk_egg, "metal", 0x03, 0x02);
	removeObjVar(this, "user");
	removeObjVar(this, "mineLoc");
	if (metal_amount <= 0x00) {
		systemMessage(user, "Someone has gotten to the metal before you.");
		return(0x00);
	}
	if (!testSkill(user, 0x2D)) {
		systemMessage(user, "You loosen some rocks but fail to find any useable ore.");
		return(0x00);
	}
	int ore_type;
	switch(metal_amount / 0x02) {
	case 0x00
		ore_type = 0x19B7;
		break;
	case 0x01
		ore_type = 0x19B8 + (0x02 * random(0x00, 0x01));
		metal_amount = 0x02;
		break;
	default
		ore_type = 0x19B9;
		metal_amount = 0x04;
		break;
	}
	obj ore = createNoResObjectAt(ore_type, getLocation(user));
	transferResources(ore, chunk_egg, metal_amount, "metal");
	obj backpack = getBackpack(user);
	if (canHold(backpack, ore)) {
		systemMessage(user, "You dig some ore and put it in your backpack.");
		ok = putObjContainer(ore, backpack);
	} else {
		systemMessage(user, "You dig some ore and put it at your feet.");
	}
	if (drain_tool_life(user, this)) {
		deleteObject(this);
	}
	return(0x00);
}
