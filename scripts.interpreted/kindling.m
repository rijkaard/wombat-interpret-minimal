inherits sk_table;

trigger creation {
	callback(this, 0x02, 0x66);
	return(0x00);
}

trigger callback(0x66) {
	if (hasObjVar(this, "valueless")) {
		removeObjVar(this, "valueless");
	}
	return(0x00);
}

function int ignite(obj user) {
	loc user_loc = getLocation(user);
	loc there = getLocation(this);
	loc fire_loc = getLocation(user);
	obj backpack = getBackpack(user);
	if (isAtHome(this)) {
		systemMessage(user, "You can't ignite that, it belongs to someone else.");
		return(0x00);
	}
	if (isInContainer(this)) {
		if (!findGoodSpotNearWithElev(fire_loc, getZ(user_loc) - 0x08, getZ(user_loc) + 0x08, 0x02, 0x02, 0x01)) {
			systemMessage(user, "There is not a spot nearby to place your campfire.");
			return(0x00);
		}
	} else {
		fire_loc = there;
	}
	if (!testSkill(user, 0x0A)) {
		barkTo(this, user, "You fail to ignite the campfire.");
		return(0x00);
	}
	obj fire = createGlobalObjectAt(0x0DE3, fire_loc);
	setObjVar(fire, "campfire_burning", 0x01);
	attachScript(fire, "campfire");
	destroyOne(this);
	if (!isInContainer(this)) {
		if (canHold(backpack, this)) {
			int ok = putObjContainer(this, backpack);
		} else {
			deleteObject(this);
		}
	}
	return(0x00);
}

trigger use {
	return(ignite(user));
}

trigger message("ignite") {
	obj user_obj = args[0x00];
	int result = ignite(user_obj);
	return(0x00);
}
